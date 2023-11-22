/*
 * tensorExpr.c --
 *
 *	Code for evaluating tensor expressions.
 */

#include <string.h>
#include <ctype.h>
#include "tcl.h"
#include "tensorInt.h"

/*
 * Structures for representing the Abstract Syntax Tree.
 */

/*
 * The IndexRange struct represents a range of tensor indices.
 * Indices range from first to last, incremented by step.
 * If step < 0, then we may have last < first. In general,
 * first and last must be >= 0; the one exception is that
 * they may have the value -1 to represent the end of the
 * tensor's range. (The actual end-of-range value wil be
 * substituted as soon as it is known.)
 */

typedef struct {
    int first, last, step;
} IndexRange;


/*
 * The IndexSet type represents a set of index ranges.
 */

typedef struct {
    int nRanges;		/* Number of ranges in the set		*/
    int maxNRanges;		/* Max. # of ranges we have		*/
				/* allocated storage for		*/
    IndexRange *rangeList;	/* List of ranges in the set		*/
} IndexSet;


/*
 * The IndexSetIterator type is used to run through all index
 * values in an IndexSet.
 */

typedef struct {
    int rangeNo;
    int idxInRange;
} IndexSetIterator;

/*
 * The TensorValue type is used to represent the value
 * of a tensor (or scalar) expression. TheScalar" element
 * is non-zero if the value is a scalar. In that case, the
 * value is contained in "scalarValue". Otherwise, the "tensor"
 * element contains the (tensor) data, while the "indexNames"
 * array contains the list of dummy index names for the tensor.
 */

typedef struct {
    int isScalar;
    double scalarValue;
    Tensor_Descrip *tensor;
    char *indexNames[TENSOR_MAX_ORDER];	/* List of index names		*/
} TensorValue;

/*
 * TensorSection represents a "section" of a tensor, i.e. a
 * rectangular (but perhaps sparse) subset of its elements.
 * The indexNames array contains the names of the dummy indices
 * used in the tensor equation. indexList contains the list
 * of numerical tensor indices. The "tensor" element is set to
 * the tensor whose name is "name".
 */

typedef struct {
    char *name;			/* Tensor name				*/
    Tensor_Descrip *tensor;	/* Pointer to tensor descrip.		*/
    int nIndices;		/* Number of indices			*/
    char *indexNames[TENSOR_MAX_ORDER];	/* List of index names		*/
    IndexSet indexList[TENSOR_MAX_ORDER];
    TensorValue value;
} TensorSection;

/*
 * There are four kinds of factors...
 */

#define	FACTOR_TYPE_SCALAR	0	/* Scalar (number)		*/
#define FACTOR_TYPE_TENSOR	1	/* Tensor section		*/
#define FACTOR_TYPE_NEGFACT	2	/* Something negated...		*/
#define FACTOR_TYPE_PAREXPR	3	/* Parenthesized expr.		*/

/*
 * The TensorFactor struct represents a factor.
 */

typedef struct TensorFactorStruct {
    int factorType;			/* Factor type			*/
    union {				/* Union to represent		*/
					/* the actual factor		*/
	double scalarValue;
	TensorSection *section;
	struct TensorFactorStruct *negFactor;
	struct TensorExprStruct *parenExpr;
    } factor;
    TensorValue value;			/* Value of this factor		*/
} TensorFactor;

/*
 * TensorTerm represents a tensor term in an expression.
 */

typedef struct TensorTermStruct {
    TensorFactor *firstFactor;		/* first factor			*/
    char op[4];				/* operation to perform  on	*/
					/* next factor (if any.)	*/
    struct TensorTermStruct *moreFactors;/* Remaining factors in this	*/
					/* term, or NULL if this is the	*/
					/* last factor.			*/
    TensorValue value;			/* Value of this term.		*/
} TensorTerm;


/*
 * TensorExpr represents a complete tensor expression.
 */

typedef struct TensorExprStruct {
    TensorTerm *firstTerm;		/* First term			*/
    char op[4];				/* Operation to perform on the	*/
					/* next term, if any.		*/
    struct TensorExprStruct *moreTerms;	/* Next term, or NULL if there	*/
					/* is none.			*/
    TensorValue value;			/* Value of this expr.		*/
} TensorExpr;

/*
 * Assignment represents a tensor assignment statement.
 */

typedef struct {
    TensorSection *lvalue;		/* Tensor to assign to		*/
    char assignOp[4];			/* Assignement operator		*/
    TensorExpr *expr;			/* Expression to evaluate	*/
} Assignment;

#if 1
//#include "exprDebug.c"
#include "tensorExprDebug.c"
#endif

/* Same as strdup, except it calls ckalloc instead of malloc. */

static char *dupstr(char *s)
{
    char *dup;

    dup = ckalloc(1 + strlen(s));
    strcpy(dup, s);
    return(dup);
}

/*
 *---------------------------------------------------------------
 *
 * InStr --
 *
 *	InStr returns 1 if character ch occurs somewhere in
 *	string str, 0 otherwise.
 *
 * Results:
 *
 *	Returns an int
 *
 * Side effects:
 *
 *	None
 *
 *---------------------------------------------------------------
 */

static int InStr(char ch, char *str)
{
    while(*str != '\0') {
	if(ch == *str) {
	    return(1);
	}

	str++;
    }

    return(0);
}


/*
 *---------------------------------------------------------------
 *
 * FreeTokenList --
 *
 *	FreeTokenList frees all storage associated with a token
 *	list.
 *
 * Results:
 *
 *	None
 *
 * Side effects:
 *
 *	Storage is freed.
 *
 *---------------------------------------------------------------
 */

static void FreeTokenList(int nTokens, char **tokenList)
{
    int i;

    for(i = 0; i < nTokens; i++) {
	ckfree(tokenList[i]);
    }

    ckfree((char *) tokenList);
}

/*
 *---------------------------------------------------------------
 *
 * GetNumberToken --
 *	GetNumberToken extracts a number token out string "str",
 *	starting at position *idxPtr.
 *
 * Results:
 *	Returns a standard Tcl result.
 *
 * Side effects:
 *	*idxPtr gets updated, *token is changed, and the result
 *	of interp is changed if an error occurs.
 *
 *---------------------------------------------------------------
 */

static int GetNumberToken(Tcl_Interp *interp, char *str,
					int *idxPtr, char *token)
{
    char junkStr[4];
    Tcl_Obj *result;

    /* Get initial digit string. */

    while(isdigit(str[*idxPtr])) {
	*token++ = str[(*idxPtr)++];
    }

    /* Get numbers following decimal point, if any. */

    if(str[*idxPtr] == '.') {
	*token++ = str[(*idxPtr)++];
	while(isdigit(str[*idxPtr])) {
	    *token++ = str[(*idxPtr)++];
	}
    }

    /* Get the 'E' exponent, if any. */

    if(tolower(str[*idxPtr]) == 'e') {
	*token++ = str[(*idxPtr)++];

	/* Look for the sign, if any. */

	if(InStr(str[*idxPtr], "+-")) {
	    *token++ = str[(*idxPtr)++];
	}

	/* There better be at least one digit in the exponent... */

	if(!isdigit(str[*idxPtr])) {
	    if(str[*idxPtr] == '\0') {
		Tcl_SetObjResult(interp, Tcl_NewStringObj(
				"Premature end of floating-point number", -1));
	    } else {
		junkStr[0] = str[*idxPtr];
		junkStr[1] = '\0';
		result = Tcl_NewStringObj("Illegal character \"", -1);
		Tcl_AppendToObj(result, junkStr, -1);
		Tcl_AppendToObj(result, "\" in float exponent", -1);
		Tcl_SetObjResult(interp, result);
	    }

	    return(TCL_ERROR);
	}

	/* Finally, get the rest of the exponent digits. */

	while(isdigit(str[*idxPtr])) {
	    *token++ = str[(*idxPtr)++];
	}
    }

    *token = '\0';
    return(TCL_OK);
}


/*
 *---------------------------------------------------------------
 *
 * GetWordToken --
 *
 *	GetWordToken gets a "word" token from string "str"
 *	starting at *idxPtr.
 *
 * Results:
 *
 *	Returns a standard Tcl result.
 *
 * Side effects:
 *
 *	*idxPtr gets updated, *token is changed, and the result
 *	of interp is changed if an error occurs.
 *
 *---------------------------------------------------------------
 */

static int GetWordToken(Tcl_Interp *interp, char *str, int *idxPtr, char *token)
{
    /* Get leading letter. ("_" is considered a letter here.) */

    if(str[*idxPtr] != '_' && !isalpha(str[*idxPtr])) {
	Tcl_SetObjResult(interp, Tcl_NewStringObj(
		"Word doesn't start with a letter", -1));
	return(TCL_ERROR);
    }

    *token++ = str[(*idxPtr)++];

    /* Get remaining letters/digits. */

    while(str[*idxPtr] == '_' || isalnum(str[*idxPtr])) {
	*token++ = str[(*idxPtr)++];
    }

    *token = '\0';
    return(TCL_OK);
}


/*
 *---------------------------------------------------------------
 *
 * GetToken --
 *
 *	GetToken returns the token contained in string "str"
 *	starting at position *idxPtr. It advances *idxPtr to
 *	point to the next token. The token itself is tored in
 *	"token", which must have enough storage allocated to
 *	hold th token.
 *
 * Results:
 *
 *	Returns a standard Tcl result.
 *
 * Side effects:
 *
 *	*idxPtr is updated, *token is modified, and interp's
 *	result string is set if an error occurred.
 *
 *---------------------------------------------------------------
 */

static int GetToken(Tcl_Interp *interp, char *str, int *idxPtr, char *token)
{
    char junkStr[4];
    Tcl_Obj *result;

    /* Skip blanks. */

    for(;;) {
	if(str[*idxPtr] == '\0') {
	    *token = '\0';
	    return(TCL_OK);
	}

	if(!isspace(str[*idxPtr])) {
	    break;
	}

	(*idxPtr) += 1;
    }

    /* Parse different kinds of tokens. Numbers first... */

    if(isdigit(str[*idxPtr])) {
	return(GetNumberToken(interp, str, idxPtr, token));
    }

    /* ...then words... */

    if(str[*idxPtr] == '_' || isalpha(str[*idxPtr])) {
	return(GetWordToken(interp, str, idxPtr, token));
    }

    /* ...then the single-character tokens... */

    if(InStr(str[*idxPtr], "():,;=")) {
	*token = str[*idxPtr];
	*(token + 1) = '\0';
	*idxPtr += 1;
	return(TCL_OK);
    }

    /* ...and finally the +/-/+=/-= tokens. */

    if(InStr(str[*idxPtr], "+-*/")) {
	*token = str[*idxPtr];
	*idxPtr += 1;
	token++;
	if(str[*idxPtr] == '=') {
	    *token  = '=';
	    *idxPtr += 1;
	    token++;
	}
	*token = '\0';
	return(TCL_OK);
    }

    /* If we get here, then we have an error. */

    result = Tcl_NewStringObj("Illegal character \"", -1);
    junkStr[0] = str[*idxPtr];
    junkStr[1] = '\0';
    Tcl_AppendToObj(result, junkStr, -1);
    Tcl_AppendToObj(result, "\"", -1);
    Tcl_SetObjResult(interp, result);
    return(TCL_ERROR);
}

/*
 *---------------------------------------------------------------
 *
 * GetTokenList --
 *	GetTokenList turns a list of Tcl_Obj's into a list
 *	of tokens suitable for parsing a tensor expression.
 *	The list of tokens is of length *nTokens, and is
 *	passed back to the caller in *tokenListPtr. The
 *	token list is allocated storage, and the caller must
 *	free it, along with all the strings it contains.
 *
 * Results:
 *	Returns a standard Tcl result.
 *
 * Side effects:
 *	*nTokens is set to the number of tokens scanned,
 *	*tokenListPtr is set to point to an array of strings.
 *	interp's result is set if an error occurs.
 *
 *---------------------------------------------------------------
 */

#define TOKEN_CHUNK	20

static int GetTokenList(Tcl_Interp *interp,
		int objc, Tcl_Obj *CONST objv[],
			int *nTokens, char ***tokenListPtr)
{
    int i, idx, strsize, argsize;
    int maxTokens;
    char *tokenStr, *argStr;

    /* Allocate initial storage. */

    strsize = 100;
    tokenStr = (char *) ckalloc(strsize);
    *tokenListPtr = (char **) ckalloc(TOKEN_CHUNK*sizeof(char *));
    *nTokens = 0;
    maxTokens = TOKEN_CHUNK;

    /* Loop through the arguments. */

    for(i = 1; i < objc; i++) {
	argStr = Tcl_GetString(objv[i]);
	argsize = strlen(argStr);
	if(argsize > strsize) {
	    strsize = argsize;
	    tokenStr = ckrealloc(tokenStr, strsize);
	}

	idx = 0;
	while(idx < argsize) {
	    if(GetToken(interp, argStr, &idx, tokenStr) != TCL_OK) {
		ckfree(tokenStr);
		FreeTokenList(*nTokens, *tokenListPtr);
		return(TCL_ERROR);
	    }

	    /* Make sure we have enough room to store tokens. */

	    if(*nTokens >= maxTokens) {
		maxTokens += TOKEN_CHUNK;
		*tokenListPtr = (char **) ckrealloc((char *) (*tokenListPtr), maxTokens*sizeof(char *));
	    }

	    /* Store the token in the list. */

	    (*tokenListPtr)[*nTokens] = dupstr(tokenStr);
	    *nTokens += 1;
	}
    }

    return(TCL_OK);
}

/* Forward declarations for storage-freeing routines. */

static void FreeTensorTerm(TensorTerm *termPtr);
static void FreeTensorExpr(TensorExpr *expr);

/*
 *---------------------------------------------------------------
 *
 * FreeTensorValue --
 *
 *	FreeTensorValue frees all storage associated with a
 *	tensor value.
 *
 * Results:
 *
 *	None.
 *
 * Side effects:
 *
 *	Storage is freed.
 *
 *---------------------------------------------------------------
 */

static void FreeTensorValue(TensorValue *valuePtr)
{
    int i;

    if(valuePtr->isScalar) {
	return;
    }

    if(valuePtr->tensor != NULL) {
	for(i = 0; i < valuePtr->tensor->order; i++) {
	    if(valuePtr->indexNames[i] != NULL) {
		ckfree((char *) (valuePtr->indexNames[i]));
	    }
	}

	Tensor_FreeData(valuePtr->tensor);
	ckfree((char *) (valuePtr->tensor));
	valuePtr->tensor = NULL;
    }
}

/*
 *---------------------------------------------------------------
 *
 * FreeTensorSection --
 *
 *	FreeTensorSection frees all storage associated with the
 *	given tensor section.
 *
 * Results:
 *
 *	None.
 *
 * Side effects:
 *
 *	Storage is freed.
 *
 *---------------------------------------------------------------
 */

static void FreeTensorSection(TensorSection *sectionPtr)
{
    int i;

    if(sectionPtr->name != NULL) {
	ckfree(sectionPtr->name);
    }

    for(i = 0; i < sectionPtr->nIndices; i++) {
	if(sectionPtr->indexNames[i] != NULL) {
	    ckfree(sectionPtr->indexNames[i]);
	}
    }
}

/*
 *---------------------------------------------------------------
 *
 * FreeTensorFactor --
 *
 *	FreeTensorFactor frees all storage associated with
 *	a factor in a tensor equation.
 *
 * Results:
 *
 *	None.
 *
 * Side effects:
 *
 *	Storage is freed.
 *
 *---------------------------------------------------------------
 */

static void FreeTensorFactor(TensorFactor *factorPtr)
{
    switch(factorPtr->factorType) {
	case FACTOR_TYPE_SCALAR:
	    /* No storage to free */
	    break;

	case FACTOR_TYPE_TENSOR:
	    if(factorPtr->factor.section != NULL) {
		FreeTensorSection(factorPtr->factor.section);
	    }
	    break;

	case FACTOR_TYPE_NEGFACT:
	    if(factorPtr->factor.negFactor != NULL) {
		FreeTensorFactor(factorPtr->factor.negFactor);
	    }
	    break;

	case FACTOR_TYPE_PAREXPR:
	    if(factorPtr->factor.parenExpr != NULL) {
		FreeTensorExpr(factorPtr->factor.parenExpr);
	    }
	    break;
    }

    FreeTensorValue(&(factorPtr->value));
}

/*
 *---------------------------------------------------------------
 *
 * FreeTensorTerm --
 *
 *	FreeTensorTerm frees a term of a tensor factor.
 *
 * Results:
 *
 *	None.
 *
 * Side effects:
 *
 *	Storage is freed.
 *
 *---------------------------------------------------------------
 */

static void FreeTensorTerm(TensorTerm *termPtr)
{
    FreeTensorValue(&(termPtr->value));

    if(termPtr->moreFactors != NULL) {
	FreeTensorTerm(termPtr->moreFactors);
    }

    if(termPtr->firstFactor != NULL) {
	FreeTensorFactor(termPtr->firstFactor);
    }
}

/*
 *---------------------------------------------------------------
 *
 * FreeTensorExpr --
 *
 *	FreeTensorExpr frees storage associated with a tensor
 *	expression.
 *
 * Results:
 *
 *	None.
 *
 * Side effects:
 *
 *	Storage is freed.
 *
 *---------------------------------------------------------------
 */

static void FreeTensorExpr(TensorExpr *expr)
{
    FreeTensorValue(&(expr->value));

    if(expr->moreTerms != NULL) {
	FreeTensorExpr(expr->moreTerms);
    }

    if(expr->firstTerm != NULL) {
	FreeTensorTerm(expr->firstTerm);
    }
}

/*
 *---------------------------------------------------------------
 *
 * FreeAssignment --
 *
 *	FreeAssignment frees all storage associated with an
 *	assignment statement.
 *
 * Results:
 *
 *	None.
 *
 * Side effects:
 *
 *	Storage is reclaimed.
 *
 *---------------------------------------------------------------
 */

static void FreeAssignment(Assignment *assignPtr)
{
    if(assignPtr->expr != NULL) {
	FreeTensorExpr(assignPtr->expr);
    }

    ckfree((char *) assignPtr);
}

/*
 *---------------------------------------------------------------
 *
 * FreeParseTree --
 *
 *	FreeParseTree frees all storage associated with a
 *	"parse tree". (A parse tree is just a list of tensor
 *	assignment statements.)
 *
 * Results:
 *
 *	None.
 *
 * Side effects:
 *
 *	Storage is freed.
 *
 *---------------------------------------------------------------
 */

static void FreeParseTree(int nAssigns, Assignment **assignList)
{
    int i;

    for(i = 0; i < nAssigns; i++) {
	FreeAssignment(assignList[i]);
    }

    if(assignList != NULL) {
	ckfree((char *) assignList);
    }
}

/*
 *---------------------------------------------------------------
 *
 * TokenIsWord --
 *
 *	TokenIsWord returns 1 if token is a "word", 0 otherwise.
 *
 * Results:
 *
 *	An integer
 *
 * Side effects:
 *
 *	None
 *
 *---------------------------------------------------------------
 */

static int TokenIsWord(char *token)
{
    int i;

    if(token[0] == '\0') {
	return(0);
    }

    if(token[0] != '_' && !isalpha(token[0])) {
	return(0);
    }

    for(i = 1; token[i] != '\0'; i++) {
	if(token[i] != '_' && !isalpha(token[i]) && !isdigit(token[i])) {
	    return(0);
	}
    }

    return(1);
}

/*
 *---------------------------------------------------------------
 *
 * AddRangeToIndexSet --
 *
 *	AddRangeToIndexSet adds a range to the end of an
 *	index set.
 *
 * Results:
 *
 *	None.
 *
 * Side effects:
 *
 *	A copy of *rngPtr is appended to *indexSetPtr.
 *
 *---------------------------------------------------------------
 */

#define RANGE_LIST_CHUNK	10

static void AddRangeToIndexSet(IndexSet *indexSetPtr, IndexRange *rngPtr)
{
    int newIdx;

    /* Make room for another index range, if necessary. */

    newIdx = indexSetPtr->nRanges;
    if(indexSetPtr->maxNRanges == 0) {
	indexSetPtr->rangeList = (IndexRange *) ckalloc(
					RANGE_LIST_CHUNK*sizeof(IndexRange));
	indexSetPtr->maxNRanges = RANGE_LIST_CHUNK;
    } else if(newIdx >= indexSetPtr->maxNRanges) {
	indexSetPtr->maxNRanges += RANGE_LIST_CHUNK;
	indexSetPtr->rangeList
		= (IndexRange *) ckrealloc((char *) (indexSetPtr->rangeList),
				(indexSetPtr->maxNRanges)*sizeof(IndexRange));
    }

    /* Add the range. */

    indexSetPtr->rangeList[newIdx].first = rngPtr->first;
    indexSetPtr->rangeList[newIdx].last = rngPtr->last;
    indexSetPtr->rangeList[newIdx].step = rngPtr->step;
    indexSetPtr->nRanges += 1;
}

/* Forward Declarations... */

static int ParseTensorExpr(Tcl_Interp *interp,
		int *curTokPtr, char **tokenList, int nTokens,
						TensorExpr **exprPtrPtr);

/*
 *---------------------------------------------------------------
 *
 * ParseRange --
 *
 *	ParseRange parses a range specification following
 *	an index of a tensor section.
 *
 * Results:
 *
 *	Returns a standard Tcl result.
 *
 * Side effects:
 *
 *	*curTokPtr is incremented to point past the tensor
 *	index, and the contents of *sectionPtr are changed.
 *
 *---------------------------------------------------------------
 */

static int ParseRange(Tcl_Interp *interp,
		int *curTokPtr, char **tokenList, int nTokens,
						IndexSet *indexSetPtr)
{
    int i, sign;
    IndexRange tmpRange;

    /* Set default values. */

    tmpRange.step = 1;

    /* Parse the range... */

    if(strcmp(tokenList[*curTokPtr], "end") == 0) {
	tmpRange.first = -1;
	tmpRange.last = -1;
    } else {
	if(Tcl_GetInt(interp, tokenList[*curTokPtr], &i) != TCL_OK) {
	    return(TCL_ERROR);
	}

	if(i < 0) {
	    Tcl_SetObjResult(interp, Tcl_NewStringObj(
				"Indices cannot be negative", -1));
	    return(TCL_ERROR);
	}

	tmpRange.first = i;
	tmpRange.last = i;
    }

    *curTokPtr += 1;
    if(*curTokPtr >= nTokens) {
	Tcl_SetObjResult(interp, Tcl_NewStringObj(
		"Premature end of index range", -1));
	return(TCL_ERROR);
    }

    if(strcmp(tokenList[*curTokPtr], ":") != 0) {
	AddRangeToIndexSet(indexSetPtr, &tmpRange);
	return(TCL_OK);
    }

    /* Skip the colon, get the end of the range. */

    *curTokPtr += 1;
    if(*curTokPtr >= nTokens) {
	Tcl_SetObjResult(interp, Tcl_NewStringObj(
		"Premature end of index range", -1));
	return(TCL_ERROR);
    }

    if(strcmp(tokenList[*curTokPtr], "end") == 0) {
	tmpRange.last = -1;
    } else {
	if(Tcl_GetInt(interp, tokenList[*curTokPtr], &i) != TCL_OK) {
	    return(TCL_ERROR);
	}

	if(i < 0) {
	    Tcl_SetObjResult(interp, Tcl_NewStringObj(
				"Indices cannot be negative", -1));
	    return(TCL_ERROR);
	}

	tmpRange.last = i;
    }

    *curTokPtr += 1;
    if(*curTokPtr >= nTokens) {
	Tcl_SetObjResult(interp, Tcl_NewStringObj(
		"Premature end of index range", -1));
	return(TCL_ERROR);
    }

    if(strcmp(tokenList[*curTokPtr], ":") != 0) {
	AddRangeToIndexSet(indexSetPtr, &tmpRange);
	return(TCL_OK);
    }

    /* Skip the colon, get the step size. */

    *curTokPtr += 1;
    if(*curTokPtr >= nTokens) {
	Tcl_SetObjResult(interp, Tcl_NewStringObj(
		"Premature end of index range", -1));
	return(TCL_ERROR);
    }

    /* If the step's negative, handle the minus sign. */

    sign = 1;
    if(strcmp(tokenList[*curTokPtr], "-") == 0) {
	sign = -1;
	*curTokPtr += 1;
	if(*curTokPtr >= nTokens) {
	    Tcl_SetObjResult(interp, Tcl_NewStringObj(
			"No number after \"-\" in index range step", -1));
	    return(TCL_ERROR);
	}
    }

    if(Tcl_GetInt(interp, tokenList[*curTokPtr], &i) != TCL_OK) {
	return(TCL_ERROR);
    }

    if(sign > 0) {
	tmpRange.step = i;
    } else {
	tmpRange.step = -i;
    }

    *curTokPtr += 1;

    AddRangeToIndexSet(indexSetPtr, &tmpRange);

    return(TCL_OK);
}

/*
 *---------------------------------------------------------------
 *
 * ParseIndex --
 *
 *	ParseIndex parses an index of a tensor section.
 *
 * Results:
 *
 *	Returns a standard Tcl result.
 *
 * Side effects:
 *
 *	*curTokPtr is incremented to point past the tensor
 *	index, and the contents of *sectionPtr are changed.
 *
 *---------------------------------------------------------------
 */

static int ParseIndex(Tcl_Interp *interp,
		int *curTokPtr, char **tokenList, int nTokens,
						TensorSection *sectionPtr)
{
    int indexIdx;
    IndexRange rng;

    if(*curTokPtr >= nTokens) {
	Tcl_SetObjResult(interp, Tcl_NewStringObj("Missing tensor index", -1));
	return(TCL_ERROR);
    }

    /* Get the word associated with this index. */

    if(!TokenIsWord(tokenList[*curTokPtr])) {
	Tcl_SetObjResult(interp, Tcl_NewStringObj(
				"Expected word, didn't get one", -1));
	return(TCL_ERROR);
    }

    indexIdx = sectionPtr->nIndices;
    sectionPtr->indexNames[indexIdx] = dupstr(tokenList[*curTokPtr]);
    sectionPtr->indexList[indexIdx].maxNRanges = 0;
    sectionPtr->indexList[indexIdx].nRanges = 0;
    *curTokPtr += 1;
    
    /* Check for index ranges. */

    if(*curTokPtr >= nTokens) {
	Tcl_SetObjResult(interp, Tcl_NewStringObj(
				"Premature end of index list", -1));
	return(TCL_ERROR);
    }

    if(strcmp(tokenList[*curTokPtr], "=") != 0) {
	rng.first = 0;
	rng.last = -1;
	rng.step = 1;
	AddRangeToIndexSet(&(sectionPtr->indexList[indexIdx]), &rng);
	sectionPtr->nIndices += 1;
	return(TCL_OK);
    }

    *curTokPtr += 1;
    if(*curTokPtr >= nTokens) {
	Tcl_SetObjResult(interp, Tcl_NewStringObj(
				"'=' not followed by index set", -1));
	return(TCL_ERROR);
    }

    /* Handle the single-range case. */

    if(strcmp(tokenList[*curTokPtr], "(") != 0) {
	if(ParseRange(interp, curTokPtr, tokenList, nTokens,
			&(sectionPtr->indexList[indexIdx])) != TCL_OK) {
	    return(TCL_ERROR);
	}

	sectionPtr->nIndices += 1;
	return(TCL_OK);
    }

    /* We may have multiple ranges... */

    *curTokPtr += 1;
    if(*curTokPtr >= nTokens) {
	Tcl_SetObjResult(interp, Tcl_NewStringObj(
				"'(' not followed by index set", -1));
	return(TCL_ERROR);
    }

    for(;;) {
	if(ParseRange(interp, curTokPtr, tokenList, nTokens,
			&(sectionPtr->indexList[indexIdx])) != TCL_OK) {
	    return(TCL_ERROR);
	}

	if(*curTokPtr < nTokens) {
	    Tcl_SetObjResult(interp, Tcl_NewStringObj(
				"Premature end of index set", -1));
	    return(TCL_ERROR);
	}

	if(strcmp(tokenList[*curTokPtr], ")") == 0) {
	    *curTokPtr += 1;
	    break;
	}

	if(strcmp(tokenList[*curTokPtr], ",") != 0) {
	    Tcl_SetObjResult(interp, Tcl_NewStringObj(
				"Expected comma, didn't get one", -1));
	    return(TCL_ERROR);
	}
    }

    return(TCL_OK);
}

/*
 *---------------------------------------------------------------
 *
 * ParseIndexList --
 *
 *	ParseIndexList parses the index list of a tensor section.
 *
 * Results:
 *
 *	Returns a standard Tcl result.
 *
 * Side effects:
 *
 *	*curTokPtr is incremented to point past the tensor
 *	index list, and the contents of *sectionPtr are changed.
 *
 *---------------------------------------------------------------
 */

static int ParseIndexList(Tcl_Interp *interp,
		int *curTokPtr, char **tokenList, int nTokens,
						TensorSection *sectionPtr)
{
    sectionPtr->nIndices = 0;

    if(*curTokPtr >= nTokens) {
	Tcl_SetObjResult(interp, Tcl_NewStringObj("Missing index", -1));
	return(TCL_ERROR);
    }

    if(strcmp(tokenList[*curTokPtr], ")") == 0) {
	return(TCL_OK);
    }

    for(;;) {
	if(sectionPtr->nIndices >= TENSOR_MAX_ORDER) {
	    Tcl_SetObjResult(interp, Tcl_NewStringObj("Too many indices", -1));
	    return(TCL_ERROR);
	}

	if(ParseIndex(interp, curTokPtr, tokenList, nTokens,
			sectionPtr) != TCL_OK) {
	    return(TCL_ERROR);
	}

	if(*curTokPtr >= nTokens) {
	    Tcl_SetObjResult(interp, Tcl_NewStringObj(
				"Premature end of index list", -1));
	    return(TCL_ERROR);
	}

	if(strcmp(tokenList[*curTokPtr], ")") == 0) {
	    break;
	}

	if(strcmp(tokenList[*curTokPtr], ",") != 0) {
	    Tcl_SetObjResult(interp, Tcl_NewStringObj(
				"Expected ',' or ')'", -1));
	    return(TCL_ERROR);
	}

	*curTokPtr += 1;

	if(*curTokPtr >= nTokens) {
	    Tcl_SetObjResult(interp, Tcl_NewStringObj(
				"Premature end of index list", -1));
	    return(TCL_ERROR);
	}
    }

    return(TCL_OK);
}

/*
 *---------------------------------------------------------------
 *
 * ParseTensorSection --
 *
 *	ParseTensorSection parses a "tensor section", which
 *	consists of a tensor name followed by a parenthesized
 *	list of index names. The index names may be followed
 *	by a list of index values.
 *
 * Results:
 *
 *	Returns a standard Tcl result.
 *
 * Side effects:
 *
 *	*curTokPtr is incremented to point past the tensor
 *	section, and the contents of *sectionPtr are changed.
 *
 *---------------------------------------------------------------
 */

static int ParseTensorSection(Tcl_Interp *interp,
		int *curTokPtr, char **tokenList, int nTokens,
					TensorSection **sectionPtrPtr)
{
    /* Make sure that *something* is there. */

    if(*curTokPtr >= nTokens) {
	Tcl_SetObjResult(interp, Tcl_NewStringObj(
				"No tensor section found.", -1));
	return(TCL_ERROR);
    }

    /* Get a word. */

    if(!TokenIsWord(tokenList[*curTokPtr])) {
	Tcl_SetObjResult(interp, Tcl_NewStringObj(
				"Expecting word, didn't get one.", -1));
	return(TCL_ERROR);
    }

    *sectionPtrPtr = (TensorSection *) ckalloc(sizeof(TensorSection));

    (*sectionPtrPtr)->name = dupstr(tokenList[*curTokPtr]);
    *curTokPtr += 1;

    /* Better get a left paren! */

    if(*curTokPtr >= nTokens) {
	Tcl_SetObjResult(interp, Tcl_NewStringObj("No \"(\" found.", -1));
	return(TCL_ERROR);
    }

    if(strcmp("(", tokenList[*curTokPtr]) != 0) {
	Tcl_SetObjResult(interp, Tcl_NewStringObj(
			"Expecting \"(\", got something else.", -1));
	return(TCL_ERROR);
    }

    *curTokPtr += 1;

    /* Parse an index list. */

    if(ParseIndexList(interp, curTokPtr, tokenList, nTokens,
						*sectionPtrPtr) != TCL_OK) {
	return(TCL_ERROR);
    }

    /* Eat up the final right paren. */

    if(*curTokPtr >= nTokens) {
	Tcl_SetObjResult(interp, Tcl_NewStringObj("No \")\" found.", -1));
	return(TCL_ERROR);
    }

    if(strcmp(")", tokenList[*curTokPtr]) != 0) {
	Tcl_SetObjResult(interp, Tcl_NewStringObj(
			"Expecting \")\", got something else.", -1));
	return(TCL_ERROR);
    }

    *curTokPtr += 1;

    return(TCL_OK);
}


/*
 *---------------------------------------------------------------
 *
 * ParseTensorFactor --
 *
 *	ParseTensorFactor parses a tensor factor.
 *
 * Results:
 *
 *	Returns a standard Tcl result.
 *
 * Side effects:
 *
 *	Increments *curTokPtr to point past the factor, and
 *	sets *factorPtrPtr.
 *---------------------------------------------------------------
 */

static int ParseTensorFactor(Tcl_Interp *interp,
		int *curTokPtr, char **tokenList, int nTokens,
					TensorFactor **factorPtrPtr)
{
    Tcl_Obj *result;

    *factorPtrPtr = NULL;
    if(*curTokPtr >= nTokens) {
	Tcl_SetObjResult(interp, Tcl_NewStringObj("Missing term", -1));
	return(TCL_ERROR);
    }

    *factorPtrPtr = (TensorFactor *) ckalloc(sizeof(TensorFactor));
    (*factorPtrPtr)->factorType = -1;

    /* Handle "factor ::= '-' factor". */

    if(strcmp(tokenList[*curTokPtr], "-") == 0) {
	(*factorPtrPtr)->factorType = FACTOR_TYPE_NEGFACT;
	*curTokPtr += 1;
	if(*curTokPtr >= nTokens) {
	    Tcl_SetObjResult(interp, Tcl_NewStringObj(
			"Expected factor after \"-\"", -1));
	    return(TCL_ERROR);
	}

	return(ParseTensorFactor(interp, curTokPtr, tokenList,
			nTokens, &((*factorPtrPtr)->factor.negFactor)));
    }

    /* Handle "factor ::= '(' tensorExpr ')'". */

    if(strcmp(tokenList[*curTokPtr], "(") == 0) {
	(*factorPtrPtr)->factorType = FACTOR_TYPE_PAREXPR;
	*curTokPtr += 1;
	if(*curTokPtr >= nTokens) {
	    Tcl_SetObjResult(interp, Tcl_NewStringObj(
			"Expected expression after \"(\"", -1));
	    return(TCL_ERROR);
	}
	if(ParseTensorExpr(interp, curTokPtr, tokenList, nTokens,
		&((*factorPtrPtr)->factor.parenExpr)) != TCL_OK) {
	    return(TCL_ERROR);
	}

	if(*curTokPtr >= nTokens) {
	    Tcl_SetObjResult(interp, Tcl_NewStringObj(
					"Missing right paren", -1));
	    return(TCL_ERROR);
	}

	if(strcmp(tokenList[*curTokPtr], ")") != 0) {
	    Tcl_SetObjResult(interp, Tcl_NewStringObj(
				"Expected right paren, didn't get one", -1));
	    return(TCL_ERROR);
	}

	*curTokPtr += 1;
	return(TCL_OK);
    }

    /* Handle "factor ::= tensorSection". */

    if(TokenIsWord(tokenList[*curTokPtr])) {
	(*factorPtrPtr)->factorType = FACTOR_TYPE_TENSOR;
	return(ParseTensorSection(interp, curTokPtr, tokenList, nTokens,
			&((*factorPtrPtr)->factor.section)));
    }

    /* Last possibility: "factor ::= scalar" */

    if(Tcl_GetDouble(interp, tokenList[*curTokPtr],
			&((*factorPtrPtr)->factor.scalarValue)) == TCL_OK) {
	(*factorPtrPtr)->factorType = FACTOR_TYPE_SCALAR;
	*curTokPtr += 1;
	return(TCL_OK);
    }

    result = Tcl_NewStringObj("Expecting factor, got \"", -1);
    Tcl_AppendToObj(result, tokenList[*curTokPtr], -1);
    Tcl_AppendToObj(result, "\"", -1);
    Tcl_SetObjResult(interp, result);
    return(TCL_ERROR);
}

/*
 *---------------------------------------------------------------
 *
 * ParseMoreTensorFactors --
 *
 *	ParseMoreTensorFactors looks for additional factors
 *	in a tensor expression.
 *
 * Results:
 *
 *	Returns a standard Tcl result.
 *
 * Side effects:
 *
 *	*curTokPtr is advanced to point past the last factor
 *	in the current term.
 *---------------------------------------------------------------
 */

static int ParseMoreTensorFactors(Tcl_Interp *interp,
		int *curTokPtr, char **tokenList, int nTokens,
						TensorTerm *mfPtr)
{
    mfPtr->moreFactors = NULL;
    if(*curTokPtr >= nTokens || strcmp(tokenList[*curTokPtr], ";") == 0) {
	return(TCL_OK);
    }

    if(strcmp(tokenList[*curTokPtr], "*") != 0
		&& strcmp(tokenList[*curTokPtr], "/") != 0) {
	return(TCL_OK);
    }

    mfPtr->op[0] = tokenList[*curTokPtr][0];
    mfPtr->op[1] = '\0';

    *curTokPtr += 1;
    if(*curTokPtr >= nTokens) {
	Tcl_SetObjResult(interp, Tcl_NewStringObj(
		"Expected another factor in expression", -1));
	return(TCL_ERROR);
    }

    mfPtr->moreFactors = (TensorTerm *) ckalloc(sizeof(TensorTerm));
    mfPtr->moreFactors->firstFactor = NULL;
    mfPtr->moreFactors->moreFactors = NULL;
    mfPtr->moreFactors->value.tensor = NULL;

    if(ParseTensorFactor(interp, curTokPtr, tokenList, nTokens,
				&(mfPtr->moreFactors->firstFactor)) != TCL_OK) {
	return(TCL_ERROR);
    }

    if(*curTokPtr >= nTokens) {
	return(TCL_OK);
    }

    if(strcmp(tokenList[*curTokPtr], "*") != 0
		&& strcmp(tokenList[*curTokPtr], "/") != 0) {
	return(TCL_OK);
    }

    if(ParseMoreTensorFactors(interp, curTokPtr, tokenList, nTokens,
				mfPtr->moreFactors) != TCL_OK) {
	return(TCL_ERROR);
    }

    return(TCL_OK);
}

/*
 *---------------------------------------------------------------
 *
 * ParseTensorTerm --
 *
 *	ParseTensorTerm parses a term of a tensor expression.
 *
 * Results:
 *
 *	Returns a standard Tcl result.
 *
 * Side effects:
 *
 *	Increments *curTokPtr to pint past the last token in
 *	the term. *termPtrPtr is set.
 *
 *---------------------------------------------------------------
 */

static int ParseTensorTerm(Tcl_Interp *interp,
		int *curTokPtr, char **tokenList, int nTokens,
						TensorTerm **termPtrPtr)
{
    if(*curTokPtr >= nTokens) {
	Tcl_SetObjResult(interp, Tcl_NewStringObj("Missing term", -1));
	return(TCL_ERROR);
    }

    *termPtrPtr = (TensorTerm *) ckalloc(sizeof(TensorTerm));
    (*termPtrPtr)->firstFactor = NULL;
    (*termPtrPtr)->moreFactors = NULL;
    (*termPtrPtr)->value.isScalar = 0;
    (*termPtrPtr)->value.tensor = NULL;

    if(ParseTensorFactor(interp, curTokPtr, tokenList, nTokens,
				&((*termPtrPtr)->firstFactor)) != TCL_OK) {
	return(TCL_ERROR);
    }

    if(*curTokPtr >= nTokens) {
	return(TCL_OK);
    }

    if(ParseMoreTensorFactors(interp, curTokPtr, tokenList, nTokens,
				*termPtrPtr) != TCL_OK) {
	return(TCL_ERROR);
    }

    return(TCL_OK);
}

/*
 *---------------------------------------------------------------
 *
 * ParseMoreTensorTerms --
 *
 *	ParseMoreTensorTerms looks for additional terms in
 *	a tensor expression, and parses them if they are
 *	present.
 *
 * Results:
 *
 *	Returns a standard Tcl result.
 *
 * Side effects:
 *
 *	*curTokPtr is incremented past all the parsed tokens.
 *	*mtPtr is set.
 *---------------------------------------------------------------
 */

static int ParseMoreTensorTerms(Tcl_Interp *interp,
		int *curTokPtr, char **tokenList, int nTokens,
						TensorExpr *mtPtr)
{
    mtPtr->moreTerms = NULL;
    if(*curTokPtr >= nTokens || strcmp(tokenList[*curTokPtr], ";") == 0) {
	return(TCL_OK);
    }

    if(strcmp(tokenList[*curTokPtr], "+") != 0
		&& strcmp(tokenList[*curTokPtr], "-") != 0) {
	return(TCL_OK);
    }

    mtPtr->op[0] = tokenList[*curTokPtr][0];
    mtPtr->op[1] = '\0';

    *curTokPtr += 1;
    if(*curTokPtr >= nTokens) {
	Tcl_SetObjResult(interp, Tcl_NewStringObj(
		"Expected another term in expression", -1));
	return(TCL_ERROR);
    }

    mtPtr->moreTerms = (TensorExpr *) ckalloc(sizeof(TensorExpr));
    mtPtr->moreTerms->firstTerm = NULL;
    mtPtr->moreTerms->moreTerms = NULL;
    mtPtr->moreTerms->value.tensor = NULL;

    if(ParseTensorTerm(interp, curTokPtr, tokenList, nTokens,
				&(mtPtr->moreTerms->firstTerm)) != TCL_OK) {
	return(TCL_ERROR);
    }

    if(*curTokPtr >= nTokens) {
	return(TCL_OK);
    }

    if(strcmp(tokenList[*curTokPtr], "+") != 0
		&& strcmp(tokenList[*curTokPtr], "-") != 0) {
	return(TCL_OK);
    }

    if(ParseMoreTensorTerms(interp, curTokPtr, tokenList, nTokens,
				mtPtr->moreTerms) != TCL_OK) {
	return(TCL_ERROR);
    }

    return(TCL_OK);
}


/*
 *---------------------------------------------------------------
 *
 * ParseTensorExpr --
 *
 *	ParseTensorExpr parses a tensor expression. The
 *	expression is returned in *exprPtrPtr; the return
 *	value is ckalloc'd.
 *
 * Results:
 *
 *	Returns a standard Tcl result.
 *
 * Side effects:
 *
 *	*curTokPtr is incremented to point past the expression.
 *
 *---------------------------------------------------------------
 */

static int ParseTensorExpr(Tcl_Interp *interp,
		int *curTokPtr, char **tokenList, int nTokens,
						TensorExpr **exprPtrPtr)
{
    if(*curTokPtr >= nTokens) {
	Tcl_SetObjResult(interp, Tcl_NewStringObj("Missing expression", -1));
	return(TCL_ERROR);
    }

    *exprPtrPtr = (TensorExpr *) ckalloc(sizeof(TensorExpr));
    (*exprPtrPtr)->firstTerm = NULL;
    (*exprPtrPtr)->moreTerms = NULL;
    (*exprPtrPtr)->value.isScalar = 0;
    (*exprPtrPtr)->value.tensor = NULL;

    if(ParseTensorTerm(interp, curTokPtr, tokenList, nTokens,
				&((*exprPtrPtr)->firstTerm)) != TCL_OK) {
	return(TCL_ERROR);
    }

    if(*curTokPtr >= nTokens) {
	return(TCL_OK);
    }

    if(ParseMoreTensorTerms(interp, curTokPtr, tokenList, nTokens,
				*exprPtrPtr) != TCL_OK) {
	return(TCL_ERROR);
    }

    return(TCL_OK);
}


/*
 *---------------------------------------------------------------
 *
 * ParseTensorAssignment --
 *
 *	ParseTensorAssignment parses a single tensor assignment
 *	statement. The parsed assignment is returned in
 *	*AssignPtr.
 *
 * Results:
 *
 *	Returns a standard Tcl result.
 *
 * Side effects:
 *
 *	*AssignPtr is set, *curTokPtr is incremented so that it
 *	points to the token after the assignment.
 *
 *---------------------------------------------------------------
 */

static int ParseTensorAssignment(Tcl_Interp *interp,
		int *curTokPtr, char **tokenList, int nTokens,
						Assignment **AssignPtr)
{
    int i;

    static char *assignOpList[] = {
	"=", "+=", "-=", "*=", "/=", NULL
    };

    *AssignPtr = (Assignment *) ckalloc(sizeof(Assignment));
    (*AssignPtr)->lvalue = NULL;
    (*AssignPtr)->expr = NULL;

    if(ParseTensorSection(interp, curTokPtr, tokenList, nTokens,
				&((*AssignPtr)->lvalue)) != TCL_OK) {
	return(TCL_ERROR);
    }

    if(*curTokPtr >= nTokens) {
	Tcl_SetObjResult(interp, Tcl_NewStringObj("No assignment operator", -1));
	return(TCL_ERROR);
    }

    (*AssignPtr)->assignOp[0] = '\0';
    for(i = 0; assignOpList[i] != NULL; i++) {
	if(strcmp(assignOpList[i], tokenList[*curTokPtr]) == 0) {
	    strcpy((*AssignPtr)->assignOp, assignOpList[i]);
	    (*curTokPtr) += 1;
	}
    }

    if((*AssignPtr)->assignOp[0] == '\0') {
	Tcl_SetObjResult(interp, Tcl_NewStringObj(
			"Expecting assignment op, didn't get one", -1));
	return(TCL_ERROR);
    }

    if(*curTokPtr >= nTokens) {
	Tcl_SetObjResult(interp, Tcl_NewStringObj(
			"No expression follows assignment operator", -1));
	return(TCL_ERROR);
    }

    if(ParseTensorExpr(interp, curTokPtr, tokenList, nTokens,
				&((*AssignPtr)->expr)) != TCL_OK) {
	return(TCL_ERROR);
    }

    return(TCL_OK);
}


/*
 *---------------------------------------------------------------
 *
 * ParseTokenList --
 *
 *	ParseTokenList parses a token list and returns a
 *	parse tree. The parse "tree" consists of an array of
 *	assignments. The number of assignments is returned
 *	in *nAssignsPtr, and the assignment list itself is
 *	returned in *AssignmentlistPtr. The assignment list
 *	is allocated with ckalloc, and should be freed by
 *	the caller.
 *
 * Results:
 *
 *	Returns a standard Tcl result.
 *
 * Side effects:
 *
 *	*nAssignsPtr and *AssignmentlistPtr are set.
 *
 *---------------------------------------------------------------
 */

#define ASSIGN_CHUNK 10

static int ParseTokenList(Tcl_Interp *interp,
			int nTokens, char **tokenList,
			int *nAssignsPtr, Assignment ***AssignmentListPtr)
{
    int curToken, assignNo, maxAssigns;

    /* Allocate storage. */

    *AssignmentListPtr = (Assignment **) ckalloc(ASSIGN_CHUNK*sizeof(Assignment *));
    assignNo = 0;
    *nAssignsPtr = 0;
    maxAssigns = ASSIGN_CHUNK;

    curToken = 0;
    for(;;) {
	/* Make sure there's enough storage. */

	if(assignNo >= maxAssigns) {
	    maxAssigns += ASSIGN_CHUNK;
	    *AssignmentListPtr = (Assignment **) ckrealloc((char *) (*AssignmentListPtr),
						maxAssigns*sizeof(Assignment *));
	}

	if(curToken >= nTokens) {
	    *nAssignsPtr = assignNo;
	    return(TCL_OK);
	}

	if(ParseTensorAssignment(interp, &curToken, tokenList, nTokens,
		&((*AssignmentListPtr)[assignNo])) != TCL_OK) {
	    /*@@@ Free Storage @@@*/
	    return(TCL_ERROR);
	}
	assignNo += 1;

	if(curToken >= nTokens) {
	    *nAssignsPtr = assignNo;
	    return(TCL_OK);
	}

	if(strcmp(tokenList[curToken], ";") != 0) {
	    /*@@@ Free Storage @@@*/
	    Tcl_SetObjResult(interp, Tcl_NewStringObj("Expecting \";\"", -1));
	    return(TCL_ERROR);
	}

	curToken += 1;
    }

}

/* Forward declarations required by CheckFactorForTensors */

static int CheckExprForTensors(Tcl_Interp *interp, TensorExpr *exprPtr);

/*
 *---------------------------------------------------------------
 *
 * CheckFactorForTensors --
 *
 *	CheckFactorForTensors ensures the existence of all
 *	tensors required to compute a given factor.
 *
 * Results:
 *
 *	Returns a standard Tcl result.
 *
 * Side effects:
 *
 *	The tensor value field of the tensor is set, if
 *	appropriate. The same is done for tensors in the
 *	factor's subexpressions (if any).
 *
 *---------------------------------------------------------------
 */

static int CheckFactorForTensors(Tcl_Interp *interp, TensorFactor *factorPtr)
{
    Tcl_Obj *result;

    switch(factorPtr->factorType) {
	case FACTOR_TYPE_SCALAR:
	    return(TCL_OK);
	    break;

	case FACTOR_TYPE_TENSOR:
	    factorPtr->factor.section->tensor
			= Tensor_Lookup(interp, factorPtr->factor.section->name);
	    if(factorPtr->factor.section->tensor == NULL) {
		result = Tcl_NewStringObj("Tensor \"", -1);
		Tcl_AppendToObj(result, factorPtr->factor.section->name, -1);
		Tcl_AppendToObj(result, "\" does not exist", -1);
		Tcl_SetObjResult(interp, result);
		return(TCL_ERROR);
	    }
	    return(TCL_OK);
	    break;

	case FACTOR_TYPE_NEGFACT:
	    return(CheckFactorForTensors(interp, factorPtr->factor.negFactor));
	    break;

	case FACTOR_TYPE_PAREXPR:
	    return(CheckExprForTensors(interp, factorPtr->factor.parenExpr));
	    break;

    }

    /*@@@ Shouldn't get here! Panic! @@@*/

    return(TCL_ERROR);
}

/*
 *---------------------------------------------------------------
 *
 * CheckTermForTensors --
 *
 *	CheckTermForTensors ensures the existence of all tensors
 *	required to compute a given term of a tensor expression.
 *
 * Results:
 *
 *	Returns a standard Tcl result.
 *
 * Side effects:
 *
 *	Tensor value fields may be set.
 *
 *---------------------------------------------------------------
 */

static int CheckTermForTensors(Tcl_Interp *interp, TensorTerm *termPtr)
{
    for(; termPtr != NULL; termPtr = termPtr->moreFactors) {
	if(CheckFactorForTensors(interp, termPtr->firstFactor) != TCL_OK) {
	    return(TCL_ERROR);
	}
    }

    return(TCL_OK);
}

/*
 *---------------------------------------------------------------
 *
 * CheckExprForTensors --
 *
 *	CheckExprForTensors ensures the existence of all tensors
 *	required to compute a given tensor expression.
 *
 * Results:
 *
 *	Returns a standard Tcl result.
 *
 * Side effects:
 *
 *	Tensors required to compute the expression are looked
 *	up, and pointers to their values are filled in in the
 *	parse tree.
 *
 *---------------------------------------------------------------
 */

static int CheckExprForTensors(Tcl_Interp *interp, TensorExpr *exprPtr)
{
    for(; exprPtr != NULL; exprPtr = exprPtr->moreTerms) {
	if(CheckTermForTensors(interp, exprPtr->firstTerm) != TCL_OK) {
	    return(TCL_ERROR);
	}
    }

    return(TCL_OK);
}

/*
 *---------------------------------------------------------------
 *
 * MaxIndexInRange --
 *
 *	MaxIndexInRange returns the largest index value in the
 *	given index range.
 *
 * Results:
 *
 *	Returns an int
 *
 * Side effects:
 *
 *	None.
 *
 *---------------------------------------------------------------
 */

static int MaxIndexInRange(IndexRange *idxRngPtr)
{
    int diff, m;

    if(idxRngPtr->step <= 0 || idxRngPtr->last <= idxRngPtr->first) {
	m = idxRngPtr->first;
    } else {
	diff = idxRngPtr->last - idxRngPtr->first;
	m = idxRngPtr->first + (diff /(idxRngPtr->step))*idxRngPtr->step;
    }

    return(m);
}

/*
 *---------------------------------------------------------------
 *
 * NIndicesInRange --
 *
 *	NIndicesInRange returns the number of indices in the
 *	given index range.
 *
 * Results:
 *
 *	Returns an int
 *
 * Side effects:
 *
 *	None.
 *
 *---------------------------------------------------------------
 */

static int NIndicesInRange(IndexRange *idxRngPtr)
{
    if(idxRngPtr->step > 0) {
	if(idxRngPtr->last < idxRngPtr->first) {
	    return(1);
	}

	return(1 + (idxRngPtr->last - idxRngPtr->first)/(idxRngPtr->step));
    }

    /* Must have step < 0. */

    if(idxRngPtr->last > idxRngPtr->first) {
	    return(1);
    }

    return(1 + (idxRngPtr->first - idxRngPtr->last)/(-(idxRngPtr->step)));
}

/*
 *---------------------------------------------------------------
 *
 * NIndicesInRangeSet --
 *
 *	NIndicesInRangeSet returns the total number of indices
 *	in the given range set.
 *
 * Results:
 *
 *	Returns an int
 *
 * Side effects:
 *
 *	None
 *
 *---------------------------------------------------------------
 */

static int NIndicesInRangeSet(IndexSet *idxSetPtr)
{
    int i, ni;

    for(i = 0, ni = 0; i < idxSetPtr->nRanges; i++) {
	ni += NIndicesInRange(&(idxSetPtr->rangeList[i]));
    }

    return(ni);
}

/*
 *---------------------------------------------------------------
 *
 * MaxIndexInRangeSet --
 *
 *	MaxIndexInRangeSet returns the largest index in the
 *	given range set.
 *
 * Results:
 *
 *	Returns an int
 *
 * Side effects:
 *
 *	None
 *
 *---------------------------------------------------------------
 */

static int MaxIndexInRangeSet(IndexSet *idxSetPtr)
{
    int i, m, mi;

    for(i = 0, mi = -1; i < idxSetPtr->nRanges; i++) {
	m = MaxIndexInRange(&(idxSetPtr->rangeList[i]));
	if(m > mi) {
	    mi = m;
	}
    }

    return(mi);
}


/*
 *---------------------------------------------------------------
 *
 * ReplaceEndValueInRange --
 *
 *	ReplaceEndValueInRange replaces the "first" and "last"
 *	elements in an IndexRange with a specified value, if
 *	those elements correspond to the "end" value for the
 *	tensor. (The "end" value is stored as -1.)
 *
 * Results:
 *
 *	None
 *
 * Side effects:
 *
 *	rangePtr->first and rangePtr->last may be changed.
 *
 *---------------------------------------------------------------
 */

static void ReplaceEndValueInRange(IndexRange *rangePtr, int endVal)
{
    if(rangePtr->first < 0) {
	rangePtr->first = endVal;
    }

    if(rangePtr->last < 0) {
	rangePtr->last = endVal;
    }
}


/*
 *---------------------------------------------------------------
 *
 * ReplaceEndValueInIndexSet --
 *
 *	ReplaceEndValueInIndexSet replaces the "end" value
 *	in an index range set with "endVal".
 *
 * Results:
 *
 *	None
 *
 * Side effects:
 *
 *	Some of the "first" and "last" elements of the ranges
 *	in *idxSetPtr may be changed.
 *
 *---------------------------------------------------------------
 */

static void ReplaceEndValueInIndexSet(IndexSet *idxSetPtr, int endVal)
{
    int i;

    for(i = 0; i < idxSetPtr->nRanges; i++) {
	ReplaceEndValueInRange(&(idxSetPtr->rangeList[i]), endVal);
    }
}


/*
 *---------------------------------------------------------------
 *
 * InitIndexSetIterator --
 *
 *	InitIndexSetIterator initializes an index set iterator
 *	to the start of the index sequence given by idxSetPtr.
 *	It returns the first index value.
 *
 * Results:
 *
 *	Returns an int.
 *
 * Side effects:
 *
 *	The index set iteration pointer is initialized.
 *
 *---------------------------------------------------------------
 */

static int InitIndexSetIterator(IndexSet *idxSetPtr, IndexSetIterator *iterPtr)
{
    iterPtr->rangeNo = 0;
    iterPtr->idxInRange = idxSetPtr->rangeList[0].first;
    return(iterPtr->idxInRange);
}

/*
 *---------------------------------------------------------------
 *
 * NextIndexInSet --
 *
 *	NextIndexInSet returns the next index in the given
 *	index set. State for the iteration is stored in *iterPtr.
 *	It returns -1 when there are no indices left.
 *
 * Results:
 *
 *	Returns an int.
 *
 * Side effects:
 *
 *---------------------------------------------------------------
 */

static int NextIndexInSet(IndexSet *idxSetPtr, IndexSetIterator *iterPtr)
{
    int curStep, curLast;

    curStep = idxSetPtr->rangeList[iterPtr->rangeNo].step;
    curLast = idxSetPtr->rangeList[iterPtr->rangeNo].last;
    iterPtr->idxInRange += curStep;
    if((curStep > 0 && iterPtr->idxInRange > curLast)
		|| (curStep < 0 && iterPtr->idxInRange < curLast)) {
	/* Shift to the next range, if there is one. */

	if(iterPtr->rangeNo >= (idxSetPtr->nRanges - 1)) {
	    iterPtr->idxInRange = -1;
	} else {
	    iterPtr->rangeNo += 1;
	    iterPtr->idxInRange = idxSetPtr->rangeList[iterPtr->rangeNo].first;
	}
    }

    return(iterPtr->idxInRange);
}

/*
 *---------------------------------------------------------------
 *
 * XferTensorValue --
 *
 *	XferTensorValue transfers a tensor value from *srcPtr
 *	to *destPtr. *destPtr is destroyed in the process.
 *
 * Results:
 *
 *	None
 *
 * Side effects:
 *
 *	Storage is transferred from *srcPtr to *destPtr.
 *
 *---------------------------------------------------------------
 */

static void XferTensorValue(TensorValue *destPtr, TensorValue *srcPtr)
{
    int i;

    destPtr->isScalar = srcPtr->isScalar;
    if(srcPtr->isScalar) {
	destPtr->scalarValue = srcPtr->scalarValue;
	destPtr->tensor = NULL;
    } else {
	destPtr->tensor = srcPtr->tensor;
	for(i = 0; i < srcPtr->tensor->order; i++) {
	    destPtr->indexNames[i] = srcPtr->indexNames[i];
	    srcPtr->indexNames[i] = NULL;
	}
	srcPtr->tensor = NULL;
    }
}

/*
 *---------------------------------------------------------------
 *
 * GenTensorValue --
 *
 *	GenTensorValue generates a tensor value in a tensor
 *	section. This value will be indexed straight through,
 *	that is, any jumps, omissions, or repetitions in
 *	the index range lists are reflected in the tensor
 *	value.
 *
 * Results:
 *
 *	Returns a standard Tcl result.
 *
 * Side effects:
 *
 *	secPtr->value is set.
 *
 *---------------------------------------------------------------
 */

static int GenTensorValue(Tcl_Interp *interp, TensorSection *secPtr)
{
    int i, j, succeeded;
    Tensor_Descrip *origTensor;
    Tcl_Obj *result;
    Tensor_Index idx, origIdx;
    IndexSetIterator idxIter[TENSOR_MAX_ORDER];
    VOID *dataPtr, *origDataPtr;

    /* Get the actual tensor, and make sure it's dimensionally correct. */

    secPtr->value.isScalar = 0;
    secPtr->tensor = origTensor = Tensor_Lookup(interp, secPtr->name);
    if(origTensor == NULL) {
	result = Tcl_NewStringObj("Tensor \"", -1);
	Tcl_AppendToObj(result, secPtr->name, -1);
	Tcl_AppendToObj(result, "\" does not exist", -1);
	Tcl_SetObjResult(interp, result);
	return(TCL_ERROR);
    }

    if(origTensor->order != secPtr->nIndices) {
	result = Tcl_NewStringObj("Order of tensor \"", -1);
	Tcl_AppendToObj(result, secPtr->name, -1);
	Tcl_AppendToObj(result, "\" (= ", -1);
	Tcl_AppendObjToObj(result, Tcl_NewIntObj(origTensor->order));
	Tcl_AppendToObj(result, "doesn't match number of indices (= ", -1);
	Tcl_AppendObjToObj(result, Tcl_NewIntObj(secPtr->nIndices));
	Tcl_AppendToObj(result, ")", -1);
	Tcl_SetObjResult(interp, result);
	return(TCL_ERROR);
    }

    for(i = 0; i < origTensor->order; i++) {
	ReplaceEndValueInIndexSet(&(secPtr->indexList[i]),
						(origTensor->dims[i]) - 1);
    }

    for(i = 0; i < origTensor->order; i++) {
	if(MaxIndexInRangeSet(&(secPtr->indexList[i])) >= origTensor->dims[i]) {
	    result = Tcl_NewStringObj("Index out of range (max = ", -1);
	    Tcl_AppendObjToObj(result,
		Tcl_NewIntObj(MaxIndexInRangeSet(&(secPtr->indexList[i]))));
	    Tcl_AppendToObj(result, ", max allowed =", -1);
	    Tcl_AppendObjToObj(result, Tcl_NewIntObj(origTensor->dims[i] - 1));
	    Tcl_AppendToObj(result, ")", -1);
	    Tcl_SetObjResult(interp, result);
	    return(TCL_ERROR);
	}
    }

    /* Figure out the dimensions of the value tensor. */

    secPtr->value.isScalar = 0;
    secPtr->value.tensor = (Tensor_Descrip *) ckalloc(sizeof(Tensor_Descrip));
    secPtr->value.tensor->type = TENSOR_DOUBLE;
    secPtr->value.tensor->order = origTensor->order;
    for(i = 0; i < origTensor->order; i++) {
	secPtr->value.tensor->dims[i]
			= NIndicesInRangeSet(&(secPtr->indexList[i]));
	secPtr->value.indexNames[i] = dupstr(secPtr->indexNames[i]);
    }

    /* Allocate tensor value. */

    if(Tensor_AllocData(interp, secPtr->value.tensor) != TCL_OK) {
	return(TCL_ERROR);
    }

    /* Copy from original tensor into value. */

    for(i = 0; i < origTensor->order; i++) {
	origIdx[i] = InitIndexSetIterator(&(secPtr->indexList[i]),
							&(idxIter[i]));
	/*idx[i] = idxIter[i].idxInRange;*/
	idx[i] = 0;
    }

    for(;;) {
	origDataPtr = Tensor_GetElemPtr(origTensor, origIdx);
	dataPtr = Tensor_GetElemPtr(secPtr->value.tensor, idx);
	Tensor_SetElemValue(dataPtr, TENSOR_DOUBLE,
			Tensor_GetElemValue(origDataPtr, origTensor->type));

	succeeded = 0;
	for(i = origTensor->order - 1; i >= 0; i--) {
	    idx[i] += 1;
	    origIdx[i] = NextIndexInSet(&(secPtr->indexList[i]), &(idxIter[i]));
	    if(origIdx[i] >= 0) {
		succeeded = 1;
		break;
	    }
	    for(j = i; j < origTensor->order; j++) {
		idx[j] = 0;
		origIdx[j] = InitIndexSetIterator(&(secPtr->indexList[j]),
								&(idxIter[j]));
	    }
	}

	if(!succeeded) {
	    break;
	}
    }

    return(TCL_OK);
}


/*
 *---------------------------------------------------------------
 *
 * ContractTensorValue --
 *
 *	ContractTensorValue performs a contraction on the
 *	tensor contained in *valPtr. It contracts with respect
 *	to the indices idx1 and idx2.
 *
 * Results:
 *
 *	Returns a standard Tcl result.
 *
 * Side effects:
 *
 *	*valPtr is modified.
 *
 *---------------------------------------------------------------
 */

static int ContractTensorValue(Tcl_Interp *interp, TensorValue *valPtr,
				int idx1, int idx2)
{
    int i, j, k, sumExtent, order;
    Tensor_Descrip *resultTensor;
    Tensor_Index lowResultIdx, highResultIdx, oldIdx, resultIdx;
    VOID *oldDataPtr, *resultDataPtr;
    double oldDataValue, resultDataValue;

    /* Check all the indices for proper values. */

    if(idx1 < 0 || idx2 < 0) {
	Tcl_SetObjResult(interp, Tcl_NewStringObj(
			"Invalid contraction index (< 0)", -1));
	return(TCL_ERROR);
    }

    if(idx1 == idx2) {
	Tcl_SetObjResult(interp, Tcl_NewStringObj(
		"Error: contraction with respect to a single index", -1));
	return(TCL_ERROR);
    }

    order = valPtr->tensor->order;
    if(idx1 >= order || idx2 >= order) {
	Tcl_SetObjResult(interp, Tcl_NewStringObj(
					"Contraction index too large", -1));
	return(TCL_ERROR);
    }

    if(valPtr->tensor->dims[idx1] != valPtr->tensor->dims[idx2]) {
	Tcl_SetObjResult(interp, Tcl_NewStringObj(
			"Contraction dimensions don't match", -1));
	return(TCL_ERROR);
    }

    sumExtent = valPtr->tensor->dims[idx1];

    /* Allocate the contracted tensor. */

    resultTensor = (Tensor_Descrip *) ckalloc(sizeof(Tensor_Descrip));
    resultTensor->order = 0;
    resultTensor->type = TENSOR_DOUBLE;

    for(i = 0; i < order; i++) {
	if(i != idx1 && i != idx2) {
	    resultTensor->dims[resultTensor->order] = valPtr->tensor->dims[i];
	    resultTensor->order += 1;
	}
    }

    if(Tensor_AllocData(interp, resultTensor) != TCL_OK) {
	ckfree((char *) resultTensor);
	return(TCL_ERROR);
    }

    /* Perform the contraction. */

    for(i = 0; i < resultTensor->order; i++) {
	resultIdx[i] = 0;
	lowResultIdx[i] = 0;
	highResultIdx[i] = resultTensor->dims[i] - 1;
    }

    do {
	/* Compute the index into the contracted tensor. */

	for(j = 0, k = 0; k < valPtr->tensor->order; k++) {
	    if(k != idx1 && k != idx2) {
		oldIdx[k] = resultIdx[j];
		j += 1;
	    }
	}

	/* Sum over the dummy index. */

	resultDataPtr = Tensor_GetElemPtr(resultTensor, resultIdx);
	resultDataValue = 0.0;
	for(j = 0; j < sumExtent; j++) {
	    oldIdx[idx1] = oldIdx[idx2] = j;

	    oldDataPtr = Tensor_GetElemPtr(valPtr->tensor, oldIdx);
	    oldDataValue = Tensor_GetElemValue(oldDataPtr, valPtr->tensor->type);
	    resultDataValue += oldDataValue; 
	}

	Tensor_SetElemValue(resultDataPtr, TENSOR_DOUBLE, resultDataValue);

    } while(Tensor_NextIndex(resultTensor->order,
				lowResultIdx, highResultIdx, resultIdx));

    /*
     * Replace the old tensor with the new one, and delete
     * the names of the indices used in the contraction.
     */

    for(i = 0, j = 0; i < order; i++) {
	if(i != idx1 && i != idx2) {
	    if(i != j) {
		valPtr->indexNames[j] = valPtr->indexNames[i];
	    }
	    j += 1;
	} else {
	    ckfree(valPtr->indexNames[i]);
	}
    }

    Tensor_FreeData(valPtr->tensor);
    ckfree((char *) valPtr->tensor);

    valPtr->tensor = resultTensor;

    return(TCL_OK);
}

/*
 *---------------------------------------------------------------
 *
 * TensorIndicesCompatible --
 *
 *	TensorIndicesCompatible indicates whether a tensor
 *	section and a tensor value have equivalent index lists.
 *	The index list are equivalent if and only if:
 *
 *		1. The index lists are the same length
 *		2. The index lists contain the same names
 *		3. Indices with the same name have the same
 *		   extents, i.e. the number of index values
 *		   is the same.
 *
 * Results:
 *
 *	Returns a standard Tcl result.
 *
 * Side effects:
 *
 *	None.
 *
 *---------------------------------------------------------------
 */

static int TensorIndicesCompatible(Tcl_Interp *interp,
				TensorSection *sPtr, TensorValue *vPtr)
{
    int i, j;
    int found_match;

    if(vPtr->isScalar) {
	return(TCL_OK);
    }

    if(sPtr->nIndices != vPtr->tensor->order) {
	Tcl_SetObjResult(interp, Tcl_NewStringObj(
			"Tensors are different order", -1));
	return(TCL_ERROR);
    }

    for(i = 0; i < sPtr->nIndices; i++) {
	found_match = 0;
	for(j = 0; j < vPtr->tensor->order; j++) {
	    if(strcmp(sPtr->indexNames[i], vPtr->indexNames[j]) == 0) {
		found_match = 1;
		break;
	    }
	}
	if(!found_match) {
	    Tcl_SetObjResult(interp, Tcl_NewStringObj(
			"Unmatched tensor index name!!!", -1));
	    return(TCL_ERROR);
	}

	if(NIndicesInRangeSet(&(sPtr->indexList[i]))
					!= vPtr->tensor->dims[j]) {
	    Tcl_SetObjResult(interp, Tcl_NewStringObj(
			"Range extents don't match", -1));
	    return(TCL_ERROR);
	}
    }

    return(TCL_OK);
}


/*
 *---------------------------------------------------------------
 *
 * GenIndexPermutation --
 *
 *	GenIndexPermutation generates a map from one set
 *	of tensor indices to another. The i'th index of *sPtr
 *	matches the idxMap[i]'th index of *vPtr.
 *
 * Results:
 *
 *	Returns a standard Tcl result.
 *
 * Side effects:
 *
 *	idxMap gets filled in.
 *
 *---------------------------------------------------------------
 */

static int GenIndexPermutation(Tcl_Interp *interp, TensorSection *sPtr,
				TensorValue *vPtr, Tensor_Index idxMap)
{
    int i, j;
    Tcl_Obj *result;

    /* Make sure we have equal-length index lists. */

    if(sPtr->nIndices != vPtr->tensor->order) {
	Tcl_SetObjResult(interp, Tcl_NewStringObj(
				"Section orders don't match", -1));
	return(TCL_ERROR);
    }

    for(i = 0; i < sPtr->nIndices; i++) {
	idxMap[i] = -1;

	/* Make sure that this isn't a duplicate. */

	for(j = 0; j < i; j++) {
	    if(strcmp(sPtr->indexNames[i], sPtr->indexNames[j]) == 0) {
		result = Tcl_NewStringObj("Duplicate index name \"", -1);
		Tcl_AppendToObj(result, sPtr->indexNames[i], -1);
		Tcl_AppendToObj(result, "\"", -1);
		Tcl_SetObjResult(interp, result);
		return(TCL_ERROR);
	    }
	}

	/* Find the match in the second list, if any. */

	for(j = 0; j < vPtr->tensor->order; j++) {
	    if(strcmp(sPtr->indexNames[i], vPtr->indexNames[j]) == 0) {
		idxMap[i] = j;
		break;
	    }
	}

	/* Did we get a match? */

	if(idxMap[i] < 0) {
	    result = Tcl_NewStringObj("No match for index name \"", -1);
	    Tcl_AppendToObj(result, sPtr->indexNames[i], -1);
	    Tcl_AppendToObj(result, "\"", -1);
	    Tcl_SetObjResult(interp, result);
	    return(TCL_ERROR);
	}
    }

    /* Whew! Everything's OK... */

    return(TCL_OK);
}

/*
 *---------------------------------------------------------------
 *
 * GenValueIndexMap --
 *
 *	GenValueIndexMap generates a map from one set of tensor
 *	indices to another, based on index names.
 *
 * Results:
 *
 *	Returns a standard Tcl result.
 *
 * Side effects:
 *
 *	idxMap is filled in.
 *
 *---------------------------------------------------------------
 */

static int GenValueIndexMap(Tcl_Interp *interp,
		TensorValue *dPtr, TensorValue *sPtr, Tensor_Index idxMap)
{
    int i, j, order;
    Tcl_Obj *result;

    /* Make sure the tensor orders are the same. */

    if(dPtr->tensor->order != sPtr->tensor->order) {
	Tcl_SetObjResult(interp, Tcl_NewStringObj(
					"Tensor orders don't match", -1));
	return(TCL_ERROR);
    }

    /* Find the matching indices, and make sure there are no duplicates. */

    order = dPtr->tensor->order;
    for(i = 0; i < order; i++) {
	/* Make sur ehtere are no duplicates. */

	for(j = i + 1; j < order; j++) {
	    if(strcmp(dPtr->indexNames[i], dPtr->indexNames[j]) == 0) {
		result = Tcl_NewStringObj("Duplicate index name \"", -1);
		Tcl_AppendToObj(result, dPtr->indexNames[i], -1);
		Tcl_AppendToObj(result, "\"", -1);
		Tcl_SetObjResult(interp, result);
		return(TCL_ERROR);
	    }
	}

	/* Find the match, if any. */

	idxMap[i] = -1;
	for(j = 0; j < order; j++) {
	    if(strcmp(dPtr->indexNames[i], sPtr->indexNames[j]) == 0) {
		idxMap[i] = j;
		break;
	    }
	}

	if(idxMap[i] < 0) {
	    result = Tcl_NewStringObj("Index \"", -1);
	    Tcl_AppendToObj(result, dPtr->indexNames[i], -1);
	    Tcl_AppendToObj(result, "\" has no match.", -1);
	    Tcl_SetObjResult(interp, result);
	    return(TCL_ERROR);
	}

	if(dPtr->tensor->dims[i] != sPtr->tensor->dims[j]) {
	    result = Tcl_NewStringObj("Dimension mismatch for index \"", -1);
	    Tcl_AppendToObj(result, dPtr->indexNames[i], -1);
	    Tcl_AppendToObj(result, "\"", -1);
	    Tcl_SetObjResult(interp, result);
	    return(TCL_ERROR);
	}
    }

    return(TCL_OK);
}

/*
 *---------------------------------------------------------------
 *
 * OperateOnTensorValue --
 *
 *	OperateOnTensorValue performs an element-by-element
 *	arithmetic operation on the values in *sPtr and *dPtr,
 *	and leaves the result in *dPtr. The operation performed
 *	is given by "op", which should be '+', '-', '*', or '/'.
 *
 * Results:
 *
 *	Returns a standard Tcl result.
 *
 * Side effects:
 *
 *	The contents of dPtr->tensor change.
 *
 *---------------------------------------------------------------
 */

static int OperateOnTensorValue(Tcl_Interp *interp,
				TensorValue *dPtr, TensorValue *sPtr, int op)
{
    int i;
    int order, dType, sType;
    Tensor_Index idxMap;
    Tensor_Index dIdx, sIdx, lowIdx, highIdx;
    VOID *destDataPtr, *srcDataPtr;
    double val, destVal, srcVal;

    /* Handle the cases involving scalars. */

    if(dPtr->isScalar && sPtr->isScalar) {
	switch(op) {
	    case '+':
		dPtr->scalarValue += sPtr->scalarValue;
		break;

	    case '-':
		dPtr->scalarValue -= sPtr->scalarValue;
		break;

	    case '*':
		dPtr->scalarValue *= sPtr->scalarValue;
		break;

	    case '/':
		if(sPtr->scalarValue != 0.0) {
		    dPtr->scalarValue /= sPtr->scalarValue;
		}
		break;

	}

	return(TCL_OK);
    }

    if(sPtr->isScalar) {
	/* Do nothing for division by zero. */

	if(op == '/' && sPtr->scalarValue == 0.0) {
	    return(TCL_OK);
	}

	/* Operate on all the elements of the destination. */

	order = dPtr->tensor->order;
	dType = dPtr->tensor->type;

	for(i = 0; i < order; i++) {
	    dIdx[i] = 0;
	    lowIdx[i] = 0;
	    highIdx[i] = dPtr->tensor->dims[i] - 1;
	}

	for(;;) {
	    destDataPtr = Tensor_GetElemPtr(dPtr->tensor, dIdx);
	    destVal = Tensor_GetElemValue(destDataPtr, dType);

	    switch(op) {
		case '+':
		    destVal += sPtr->scalarValue;
		    break;

		case '-':
		    destVal -= sPtr->scalarValue;
		    break;

		case '*':
		    destVal *= sPtr->scalarValue;
		    break;

		case '/':
		    destVal /= sPtr->scalarValue;
		    break;
	    }

	    Tensor_SetElemValue(destDataPtr, dType, destVal);

	    if(Tensor_NextIndex(order, lowIdx, highIdx, dIdx) == 0) {
		break;
	    }
	}

	return(TCL_OK);
    }

    if(dPtr->isScalar) {
	/*
	 * Replace the destination with a tensor the same size
	 * as the source, but filled with the destination's
	 * scalar value. Then we can execute the normal code
	 * for the two-tensor case.
	 */

	destVal = dPtr->scalarValue;
	dPtr->isScalar = 0;
	dPtr->tensor = (Tensor_Descrip *) ckalloc(sizeof(Tensor_Descrip));
	dPtr->tensor->order = sPtr->tensor->order;
	dPtr->tensor->type = TENSOR_DOUBLE;

	order = dPtr->tensor->order;
	for(i = 0; i < order; i++) {
	    dIdx[i] = 0;
	    lowIdx[i] = 0;
	    highIdx[i] = sPtr->tensor->dims[i] - 1;
	    dPtr->tensor->dims[i] = sPtr->tensor->dims[i];
	    dPtr->indexNames[i] = dupstr(sPtr->indexNames[i]);
	}

	if(Tensor_AllocData(interp, dPtr->tensor) != TCL_OK) {
	    ckfree((char *) dPtr->tensor);
	    dPtr->tensor = NULL;
	    return(TCL_ERROR);
	}

	for(;;) {
	    destDataPtr = Tensor_GetElemPtr(dPtr->tensor, dIdx);

	    Tensor_SetElemValue(destDataPtr, TENSOR_DOUBLE, destVal);

	    if(Tensor_NextIndex(order, lowIdx, highIdx, dIdx) == 0) {
		break;
	    }
	}
    }

    /* Check for conformability and generate an index map. */

    if(GenValueIndexMap(interp, dPtr, sPtr, idxMap) != TCL_OK) {
	return(TCL_ERROR);
    }

    /* A little shorthand... */

    order = dPtr->tensor->order;
    dType = dPtr->tensor->type;
    sType = sPtr->tensor->type;

    /* Add tensor values. */

    for(i = 0; i < order; i++) {
	dIdx[i] = 0;
	lowIdx[i] = 0;
	highIdx[i] = dPtr->tensor->dims[i] - 1;
    }

    for(;;) {
	/* Generate the source index from the destination index. */

	for(i = 0; i < order; i++) {
	    sIdx[idxMap[i]] = dIdx[i];
	}

	/* Index into the tensors, and do the addition. */

	destDataPtr = Tensor_GetElemPtr(dPtr->tensor, dIdx);
	srcDataPtr = Tensor_GetElemPtr(sPtr->tensor, sIdx);

	destVal = Tensor_GetElemValue(destDataPtr, dType);
	srcVal = Tensor_GetElemValue(srcDataPtr, sType);

	switch(op) {
	    case '+':
		val = destVal + srcVal;
		break;

	    case '-':
		val = destVal - srcVal;
		break;

	    case '*':
		val = destVal*srcVal;
		break;

	    case '/':
		if(srcVal == 0.0) {
		    srcVal = 1.0;
		}
		val = destVal/srcVal;
		break;
	}

	Tensor_SetElemValue(destDataPtr, dType, val);

	if(Tensor_NextIndex(order, lowIdx, highIdx, dIdx) == 0) {
	    break;
	}
    }

    return(TCL_OK);
}

/*
 *---------------------------------------------------------------
 *
 * OperateAndContractTensorValue --
 *
 *	OperateAndContractTensorValue either multiplies or
 *	divides the elements of two tensors. If an index is
 *	repeated, then summation is performed with respect
 *	to that index (or those indices). The result is
 *	returned in *dPtr. NOTE: it is assumed that *dPtr
 *	and *sPtr have no repeated indices.
 *
 * Results:
 *
 *	Returns a standard Tcl result.
 *
 * Side effects:
 *
 *	*dPtr gets a new value.
 *
 *---------------------------------------------------------------
 */

static int OperateAndContractTensorValue(Tcl_Interp *interp,
		TensorValue *dPtr, TensorValue *sPtr, int op)
{
    int i, j, repeat, alreadyRepeated, allIdx;
    TensorValue newValue;
    Tensor_Index valIdxMap, destIdxMap, srcIdxMap;
    int valOrder, destOrder, srcOrder;
    Tensor_Index destIndex, srcIndex, valIndex;
    VOID *destDataPtr, *srcDataPtr, *valDataPtr;
    double destVal, srcVal, valVal, val;
    int destType, srcType, valType;
    int nIndexNames, nRepeatedIndices;
    char *allIndexNames[TENSOR_MAX_ORDER];
    char *repeatedIndexNames[TENSOR_MAX_ORDER];
    Tensor_Index allIndexLow, allIndexHigh, allIndex;

    /* Handle the two-scalar case. */

    if(dPtr->isScalar && sPtr->isScalar) {
	switch(op) {
	    case '*':
		dPtr->scalarValue *= sPtr->scalarValue;
		break;

	    case '/':
		if(sPtr->scalarValue != 0.0) {
		    dPtr->scalarValue /= sPtr->scalarValue;
		}
		break;
	}

	return(TCL_OK);
    }

    /* If either factor is a scalar, do element-by-element ops. */

    if(dPtr->isScalar || sPtr->isScalar) {
	return(OperateOnTensorValue(interp, dPtr, sPtr, op));
    }

    /*
     * Make a list of *all* the index names that occur in the
     * two inputs, and a list of all the repeat indices. We'll
     * simultaneously create a map from the "all-indices" list
     * to the indices of the two inputs.
     */

    nIndexNames = 0;
    nRepeatedIndices = 0;

    /* Loop over the destination names. */

    for(i = 0; i < dPtr->tensor->order; i++) {
	/* See if this is a repeat name. */

	alreadyRepeated = 0;
	repeat = 0;
	for(allIdx = 0; allIdx < nIndexNames; allIdx++) {
	    if(strcmp(dPtr->indexNames[i], allIndexNames[allIdx]) == 0) {
		repeat = 1;
		break;
	    }
	}

	if(repeat) {
	    for(j = 0; j < nRepeatedIndices; j++) {
		if(strcmp(dPtr->indexNames[i], repeatedIndexNames[j]) == 0) {
		    alreadyRepeated = 1;
		    break;
		}
	    }
	}

	if(repeat) {
	    destIdxMap[i] = allIdx;
	    if(dPtr->tensor->dims[i] != (allIndexHigh[allIdx] + 1)) {
		Tcl_SetObjResult(interp, Tcl_NewStringObj(
			"Dimension mismatch", -1));
		return(TCL_OK);
	    }
	    if(!alreadyRepeated) {
		repeatedIndexNames[nRepeatedIndices]
					= dupstr(dPtr->indexNames[i]);
		nRepeatedIndices += 1;
	    }
	} else {
	    if(nIndexNames >= TENSOR_MAX_ORDER) {
		for(j = 0; j < nIndexNames; j++) {
		    ckfree(allIndexNames[j]);
		}
		for(j = 0; j < nRepeatedIndices; j++) {
		    ckfree(repeatedIndexNames[j]);
		}
		Tcl_SetObjResult(interp, Tcl_NewStringObj(
			"Too many index names in term", -1));
		return(TCL_ERROR);
	    }

	    destIdxMap[i] = nIndexNames;
	    allIndexLow[nIndexNames] = 0;
	    allIndexHigh[nIndexNames] = dPtr->tensor->dims[i] - 1;
	    allIndexNames[nIndexNames] = dupstr(dPtr->indexNames[i]);
	    nIndexNames += 1;
	}
    }

    /* Now do the same for the source. */

    for(i = 0; i < sPtr->tensor->order; i++) {
	/* See if this is a repeat name. */

	alreadyRepeated = 0;
	repeat = 0;
	for(allIdx = 0; allIdx < nIndexNames; allIdx++) {
	    if(strcmp(sPtr->indexNames[i], allIndexNames[allIdx]) == 0) {
		repeat = 1;
		break;
	    }
	}

	if(repeat) {
	    for(j = 0; j < nRepeatedIndices; j++) {
		if(strcmp(sPtr->indexNames[i], repeatedIndexNames[j]) == 0) {
		    alreadyRepeated = 1;
		    break;
		}
	    }
	}

	if(repeat) {
	    srcIdxMap[i] = allIdx;
	    if(sPtr->tensor->dims[i] != (allIndexHigh[allIdx] + 1)) {
		Tcl_SetObjResult(interp, Tcl_NewStringObj(
			"Dimension mismatch", -1));
		return(TCL_OK);
	    }
	    if(!alreadyRepeated) {
		repeatedIndexNames[nRepeatedIndices]
					= dupstr(sPtr->indexNames[i]);
		nRepeatedIndices += 1;
	    }
	} else {
	    if(nIndexNames >= TENSOR_MAX_ORDER) {
		for(j = 0; j < nIndexNames; j++) {
		    ckfree(allIndexNames[j]);
		}
		for(j = 0; j < nRepeatedIndices; j++) {
		    ckfree(repeatedIndexNames[j]);
		}
		Tcl_SetObjResult(interp, Tcl_NewStringObj(
			"Too many index names in term", -1));
		return(TCL_ERROR);
	    }

	    srcIdxMap[i] = nIndexNames;
	    allIndexLow[nIndexNames] = 0;
	    allIndexHigh[nIndexNames] = sPtr->tensor->dims[i] - 1;
	    allIndexNames[nIndexNames] = dupstr(sPtr->indexNames[i]);
	    nIndexNames += 1;
	}
    }

    /* Generate the index names and the tensor for the result. */

    newValue.isScalar = 0;
    newValue.tensor = (Tensor_Descrip *) ckalloc(sizeof(Tensor_Descrip));
    newValue.tensor->order = 0;
    newValue.tensor->type = TENSOR_DOUBLE;
    for(i = 0; i < nIndexNames; i++) {
	repeat = 0;
	for(j = 0; j < nRepeatedIndices; j++) {
	    if(strcmp(allIndexNames[i], repeatedIndexNames[j]) == 0) {
		repeat = 1;
		break;
	    }
	}

	if(!repeat) {
	    valIdxMap[newValue.tensor->order] = i;
	    newValue.indexNames[newValue.tensor->order]
					= dupstr(allIndexNames[i]);
	    newValue.tensor->dims[newValue.tensor->order]
					= 1 + allIndexHigh[i]; 
	    newValue.tensor->order += 1;
	}
    }

    if(Tensor_AllocData(interp, newValue.tensor) != TCL_OK) {
	for(i = 0; i < nIndexNames; i++) {
	    ckfree(allIndexNames[i]);
	}
	for(i = 0; i < nRepeatedIndices; i++) {
	    ckfree(repeatedIndexNames[i]);
	}
	for(i = 0; i < newValue.tensor->order; i++) {
	    ckfree(newValue.indexNames[i]);
	}
	ckfree((char *) newValue.tensor);

	return(TCL_ERROR);
    }

    /* Index over all combinations of all index values. */

    for(i = 0; i < nIndexNames; i++) {
	allIndex[i] = 0;
    }

    destOrder = dPtr->tensor->order;
    srcOrder = sPtr->tensor->order;
    valOrder = newValue.tensor->order;

    destType = dPtr->tensor->type;
    srcType = sPtr->tensor->type;
    valType = newValue.tensor->type;

    for(;;) {
	for(i = 0; i < destOrder; i++) {
	    destIndex[i] = allIndex[destIdxMap[i]];
	}

	for(i = 0; i < srcOrder; i++) {
	    srcIndex[i] = allIndex[srcIdxMap[i]];
	}

	for(i = 0; i < valOrder; i++) {
	    valIndex[i] = allIndex[valIdxMap[i]];
	}

	destDataPtr = Tensor_GetElemPtr(dPtr->tensor, destIndex);
	srcDataPtr = Tensor_GetElemPtr(sPtr->tensor, srcIndex);
	valDataPtr = Tensor_GetElemPtr(newValue.tensor, valIndex);

	destVal = Tensor_GetElemValue(destDataPtr, destType);
	srcVal = Tensor_GetElemValue(srcDataPtr, srcType);
	valVal = Tensor_GetElemValue(valDataPtr, TENSOR_DOUBLE);

	switch(op) {
	    case '*':
		val = destVal*srcVal;
		break;

	    case '/':
		if(srcVal == 0.0) {
		    val = destVal;
		} else {
		    val = destVal/srcVal;
		}
		break;
	}

	Tensor_SetElemValue(valDataPtr, valType, valVal + val);

	if(!Tensor_NextIndex(nIndexNames,
				allIndexLow, allIndexHigh, allIndex)) {
	    break;
	}
    }

    /* Put the new value into the destination. */

    for(i = 0; i < dPtr->tensor->order; i++) {
	ckfree(dPtr->indexNames[i]);
    }
    Tensor_FreeData(dPtr->tensor);
    dPtr->tensor->order = 0;
    ckfree((char *) (dPtr->tensor));

    dPtr->tensor = newValue.tensor;
    for(i = 0; i < dPtr->tensor->order; i++) {
	dPtr->indexNames[i] = newValue.indexNames[i];
    }

    return(TCL_OK);
}

static int EvalTensorExpr(Tcl_Interp *interp, TensorExpr *exprPtr);

/*
 *---------------------------------------------------------------
 *
 * EvalTensorFactor --
 *
 *	EvalTensorFactor computes the value of a factor in a
 *	tensor expression.
 *
 * Results:
 *
 *	Returns a standard Tcl result.
 *
 * Side effects:
 *
 *	factPtr->value is set.
 *
 *---------------------------------------------------------------
 */

static int EvalTensorFactor(Tcl_Interp *interp, TensorFactor *factPtr)
{
    int i, j, idx1, idx2;
    int order;
    int dType;
    double val, dVal;
    Tensor_Descrip *tensor;
    Tensor_Index dIdx, lowIdx, highIdx;
    VOID *dataPtr;

    if(factPtr->factorType == FACTOR_TYPE_SCALAR) {
	factPtr->value.isScalar = 1;
	factPtr->value.scalarValue = factPtr->factor.scalarValue;
	return(TCL_OK);
    }

    if(factPtr->factorType == FACTOR_TYPE_NEGFACT) {
	if(EvalTensorFactor(interp, factPtr->factor.negFactor) != TCL_OK) {
	    return(TCL_ERROR);
	}

	if(factPtr->factor.negFactor->value.isScalar) {
	    factPtr->value.isScalar = 1;
	    factPtr->value.scalarValue
			= -(factPtr->factor.negFactor->value.scalarValue);
	} else {
	    XferTensorValue(&(factPtr->value),
			&(factPtr->factor.negFactor->value));

	    order = factPtr->value.tensor->order;
	    for(i = 0; i < order; i++) {
		dIdx[i] = 0;
		lowIdx[i] = 0;
		highIdx[i] = factPtr->value.tensor->dims[i] - 1;
	    }

	    dType = factPtr->value.tensor->type;
	    for(;;) {
		dataPtr = Tensor_GetElemPtr(factPtr->value.tensor, dIdx);
		dVal = Tensor_GetElemValue(dataPtr, dType);
		Tensor_SetElemValue(dataPtr, dType, -dVal);

		if(!Tensor_NextIndex(order, lowIdx, highIdx, dIdx)) {
		    break;
		}
	    }
	}

	FreeTensorFactor(factPtr->factor.negFactor);
	factPtr->factor.negFactor = NULL;
 
	return(TCL_OK);
    }

    if(factPtr->factorType == FACTOR_TYPE_PAREXPR) {
	if(EvalTensorExpr(interp, factPtr->factor.parenExpr) != TCL_OK) {
	    return(TCL_ERROR);
	}

	XferTensorValue(&(factPtr->value),
			&(factPtr->factor.parenExpr->value));
	FreeTensorExpr(factPtr->factor.parenExpr);
	factPtr->factor.parenExpr = NULL;
	return(TCL_OK);
    }

    if(factPtr->factorType == FACTOR_TYPE_TENSOR) {
	/* Check out the tensor and allocate it. */

	if(GenTensorValue(interp, factPtr->factor.section) != TCL_OK) {
	    return(TCL_ERROR);
	}

	XferTensorValue(&(factPtr->value),
			&(factPtr->factor.section->value));

	/* Do any necessary contractions. */

	for(;;) {
	    /* Find matching indices. */

	    idx1 = -1;
	    idx2 = -1;
	    tensor = factPtr->value.tensor;
	    for(i = 0; i < tensor->order; i++) {
		for(j = i + 1; j < tensor->order; j++) {
		    if(strcmp(factPtr->value.indexNames[i],
			factPtr->value.indexNames[j]) == 0) {
			idx1 = i;
			idx2 = j;
			break;
		    }
		}

		if(idx1 >= 0) {
		    break;
		}
	    }

	    if(idx1 < 0) {
		break;
	    }

	    /* Do the contraction. */

	    if(ContractTensorValue(interp,
		    &(factPtr->value), idx1, idx2) != TCL_OK) {
		return(TCL_ERROR);
	    }
	}

	/* If the result is of order zero, change it to a scalar. */

	tensor = factPtr->value.tensor;
	if(tensor->order == 0) {
	    val = Tensor_GetElemValue(tensor->data, tensor->type);
	    factPtr->value.scalarValue = val;
	    factPtr->value.isScalar = 1;
	    Tensor_FreeData(tensor);
	    ckfree((char *) tensor);
	    factPtr->value.tensor = NULL;
	}

	return(TCL_OK);
    }

    Tcl_SetObjResult(interp, Tcl_NewStringObj(
		"INTERNAL ERROR: unknown factor type in EvalTensorFactor", -1));
    return(TCL_ERROR);
}

/*
 *---------------------------------------------------------------
 *
 * EvalTensorTerm --
 *
 *	EvalTensorTerm EvalTensorTermevaluates a term of a
 *	tensor expression.
 *
 * Results:
 *
 *	Returns a standard Tcl result.
 *
 * Side effects:
 *
 *	Sets the value of the term.
 *
 *---------------------------------------------------------------
 */

static int EvalTensorTerm(Tcl_Interp *interp, TensorTerm *termPtr)
{
    TensorTerm *ePtr;

    /* Get the first factor. */

    if(EvalTensorFactor(interp, termPtr->firstFactor) != TCL_OK) {
	return(TCL_ERROR);
    }

    /*
     * We can just take the value of the term from its
     * first factor; there's no need to make a copy. We just
     * have to make sure that we null out the first factor's
     * value, so that we don't accidentally free it.
     */

    XferTensorValue(&(termPtr->value),
			&(termPtr->firstFactor->value));

    FreeTensorFactor(termPtr->firstFactor);
    termPtr->firstFactor = NULL;

    /*
     * Evaluate the remaining factors in the term, and
     * incorporate them into the value. We have to contract
     * as we go.
     */

    while(termPtr->moreFactors != NULL) {
	if(EvalTensorFactor(interp,
			termPtr->moreFactors->firstFactor) != TCL_OK) {
	    return(TCL_ERROR);
	}

	if(OperateAndContractTensorValue(interp, &(termPtr->value),
		&(termPtr->moreFactors->firstFactor->value), termPtr->op[0]) != TCL_OK) {
	    return(TCL_ERROR);
	}

	/* Go on to the next term. */

	ePtr = termPtr->moreFactors;
	termPtr->moreFactors = ePtr->moreFactors;
	termPtr->op[0] = ePtr->op[0];

	/* Free the term we just handled. */

	ePtr->moreFactors = NULL;
	FreeTensorTerm(ePtr);
    }

    return(TCL_OK);
}

/*
 *---------------------------------------------------------------
 *
 * EvalTensorExpr --
 *
 *	EvalTensorExpr evaluates a tensor expression and puts
 *	it into the expression's value slot. It checks for
 *	conformability and frees storage as it goes.
 *
 * Results:
 *
 *	Returns a standard Tcl result.
 *
 * Side effects:
 *
 *	Lots: exprPtr->value is assigned, terms of the
 *	expression are evaluated, storage is freed.
 *
 *---------------------------------------------------------------
 */

static int EvalTensorExpr(Tcl_Interp *interp, TensorExpr *exprPtr)
{
    TensorExpr *ePtr;

    /* Evaluate the first term in the expression. */

    if(EvalTensorTerm(interp, exprPtr->firstTerm) != TCL_OK) {
	return(TCL_ERROR);
    }

    /*
     * We can just take the value of the expression from its
     * first term; there's no need to make a copy. We just
     * have to make sure that we null out the first term's
     * value, so that we don't accidentally free it.
     */

    XferTensorValue(&(exprPtr->value),
			&(exprPtr->firstTerm->value));

    FreeTensorTerm(exprPtr->firstTerm);
    exprPtr->firstTerm = NULL;

    /*
     * Evaluate the remaining terms in the expression, and
     * incorporate them into the value.
     */

    while(exprPtr->moreTerms != NULL) {
	if(EvalTensorTerm(interp, exprPtr->moreTerms->firstTerm) != TCL_OK) {
	    return(TCL_ERROR);
	}

	if(OperateOnTensorValue(interp, &(exprPtr->value),
		&(exprPtr->moreTerms->firstTerm->value), exprPtr->op[0]) != TCL_OK) {
	    return(TCL_ERROR);
	}

	/* Go on to the next term. */

	ePtr = exprPtr->moreTerms;
	exprPtr->moreTerms = ePtr->moreTerms;
	exprPtr->op[0] = ePtr->op[0];

	/* Free the term we just handled. */

	ePtr->moreTerms = NULL;
	FreeTensorExpr(ePtr);
    }

    return(TCL_OK);
}

/*
 * CheckLValue --
 *
 *	CheckLValue makes sure that an lvalue's description
 *	matches the associated tensor.
 *
 * Results:
 *
 *	Returns a standard Tcl result.
 *
 * Side effects:
 *
 *	The tensor element of *lvalue is filled in, and all
 *	the tensor's index ranges are corrected, in case they
 *	contained "end" symbols.
 */

static int CheckLValue(Tcl_Interp *interp, TensorSection *lvalue)
{
    int i;
    Tcl_Obj *result;

    /* Find the tensor in the lvalue. */

    lvalue->tensor = Tensor_Lookup(interp, lvalue->name);
    if(lvalue->tensor == NULL) {
	result = Tcl_NewStringObj("Tensor \"", -1);
	Tcl_AppendToObj(result, lvalue->name, -1);
	Tcl_AppendToObj(result, "\" does not exist", -1);
	Tcl_SetObjResult(interp, result);
	return(TCL_ERROR);
    }

    /* Make sure the number of dimensions matches. */

    if(lvalue->nIndices != lvalue->tensor->order) {
	result = Tcl_NewStringObj("Number of indices (=", -1);
	Tcl_AppendObjToObj(result, Tcl_NewIntObj(lvalue->nIndices));
	Tcl_AppendToObj(result, ") does not match tensor order (=", -1);
	Tcl_AppendObjToObj(result, Tcl_NewIntObj(lvalue->tensor->order));
	Tcl_AppendToObj(result, ")", -1);
	Tcl_SetObjResult(interp, result);
	return(TCL_ERROR);
    }

    /* Make sure that there are no out-of-bounds indices. */

    for(i = 0; i < lvalue->nIndices; i++) {
	if(MaxIndexInRangeSet(&(lvalue->indexList[i]))
				>= lvalue->tensor->dims[i]) {
	    result = Tcl_NewStringObj("Index ", -1);
	    Tcl_AppendObjToObj(result, Tcl_NewIntObj(i + 1));
	    Tcl_AppendToObj(result, " has an out-of-range index", -1);
	    Tcl_SetObjResult(interp, result);
	    return(TCL_ERROR);
	}
    }

    /* Make substitutions for the "end" value in index ranges. */

    for(i = 0; i < lvalue->nIndices; i++) {
	ReplaceEndValueInIndexSet(&(lvalue->indexList[i]),
					lvalue->tensor->dims[i] - 1);
    }

    return(TCL_OK);
}


/*
 * AssignScalarValue --
 *
 *	AssignScalarValue assigns a scalar value (val) to a given
 *	tensor section (*lvaluePtr). The tensor section's contents
 *	are set to "val" if "op" is '='. If "op" is '+', '-',
 *	'*', or '/', then the function acts like the "+=", "-=",
 *	"*=", or "/=" C assignment operators. If "val" is zero,
 *	then *lvaluePtr is left unchanged.
 *
 * Results:
 *
 *	None
 *
 * Side effects:
 *
 *	The contents of *lvalue are changed.
 */

static void AssignScalarValue(TensorSection *lvaluePtr, int op, double val) {
    int i, j, order;
    int lvalueType, succeeded;
    IndexSetIterator idxIter[TENSOR_MAX_ORDER];
    VOID *dataPtr;
    double curValue;
    Tensor_Index lvalueIdx;

    /* Special case: division by zero becomes a no-op. */

    if(val == 0.0 && op == '/') {
	return;
    }

    order = lvaluePtr->tensor->order;
    for(i = 0; i < order; i++) {
	lvalueIdx[i] = InitIndexSetIterator(&(lvaluePtr->indexList[i]), &(idxIter[i]));
    }

    lvalueType = lvaluePtr->tensor->type;
    for(;;) {
	dataPtr = Tensor_GetElemPtr(lvaluePtr->tensor, lvalueIdx);

	switch(op) {
	    case '=':
		Tensor_SetElemValue(dataPtr, lvalueType, val);
		break;

	    case '+':
		curValue = Tensor_GetElemValue(dataPtr, lvalueType);
		Tensor_SetElemValue(dataPtr, lvalueType, curValue + val);
		break;

	    case '-':
		curValue = Tensor_GetElemValue(dataPtr, lvalueType);
		Tensor_SetElemValue(dataPtr, lvalueType, curValue - val);
		break;

	    case '*':
		curValue = Tensor_GetElemValue(dataPtr, lvalueType);
		Tensor_SetElemValue(dataPtr, lvalueType, curValue*val);
		break;

	    case '/':
		curValue = Tensor_GetElemValue(dataPtr, lvalueType);
		if(val != 0) {
		    Tensor_SetElemValue(dataPtr, lvalueType, curValue/val);
		}
		break;
	}

	succeeded = 0;
	for(i = order - 1; i >= 0; i--) {
	    lvalueIdx[i]
		= NextIndexInSet(&(lvaluePtr->indexList[i]),
							&(idxIter[i]));
	    if(lvalueIdx[i] >= 0) {
		succeeded = 1;
		break;
	    }
	    for(j = i; j < order; j++) {
		lvalueIdx[i] = InitIndexSetIterator(&(lvaluePtr->indexList[j]),
								&(idxIter[j]));
	    }
	}

	if(!succeeded) {
	    break;
	}
    }
}

/*
 *---------------------------------------------------------------
 *
 * EvalTensorAssignment --
 *
 *	EvalTensorAssignment performs a tensor assignment.
 *
 * Results:
 *
 *	Returns a standard Tcl result.
 *
 * Side effects:
 *
 *	A tensor value is computed, and assigned to the lvalue
 *	for the assignment.
 *
 *---------------------------------------------------------------
 */

static int EvalTensorAssignment(Tcl_Interp *interp, Assignment *assignPtr)
{
    Tensor_Index idxMap, lvalueIdx, exprIdx;
    Tensor_Index unpermIdx, unpermLow, unpermHigh;
    IndexSetIterator idxIter[TENSOR_MAX_ORDER];
    int i, j, order, succeeded;
    int lvalueType, exprType;
    VOID *dataPtr, *exprDataPtr;
    float curValue, newValue;

    /* Evaluate the expression. */

    if(EvalTensorExpr(interp, assignPtr->expr) != TCL_OK) {
	return(TCL_ERROR);
    }

    /* Make sure that tensor exists in lvalue. */

    if(CheckLValue(interp, assignPtr->lvalue) != TCL_OK) {
	return(TCL_ERROR);
    }

    /* Handle the scalar assignment case. */

    if(assignPtr->expr->value.isScalar) {
	AssignScalarValue(assignPtr->lvalue, assignPtr->assignOp[0],
					assignPtr->expr->value.scalarValue);
	return(TCL_OK);
    }

    /* Make sure that the assignment is possible. */

    if(TensorIndicesCompatible(interp, assignPtr->lvalue,
				&(assignPtr->expr->value)) != TCL_OK) {
	return(TCL_ERROR);
    }

    /* Figure out how to map between indices. */

    if(GenIndexPermutation(interp, assignPtr->lvalue,
			&(assignPtr->expr->value), idxMap) != TCL_OK) {
	return(TCL_ERROR);
    }

    /* Do it... */

    order = assignPtr->lvalue->tensor->order;
    for(i = 0; i < order; i++) {
	lvalueIdx[i] = InitIndexSetIterator(&(assignPtr->lvalue->indexList[i]), &(idxIter[i]));
	unpermIdx[i] = 0;
	unpermLow[i] = 0;
	unpermHigh[i]
		= NIndicesInRangeSet(&(assignPtr->lvalue->indexList[i])) - 1; 
	exprIdx[i] = 0;
    }

    lvalueType = assignPtr->lvalue->tensor->type;
    exprType = assignPtr->expr->value.tensor->type;
    for(;;) {
	exprDataPtr
		= Tensor_GetElemPtr(assignPtr->expr->value.tensor, exprIdx);
	dataPtr = Tensor_GetElemPtr(assignPtr->lvalue->tensor, lvalueIdx);

	newValue = Tensor_GetElemValue(exprDataPtr, exprType);

	switch(assignPtr->assignOp[0]) {
	    case '=':
		Tensor_SetElemValue(dataPtr, lvalueType, newValue);
		break;

	    case '+':
		curValue = Tensor_GetElemValue(dataPtr, lvalueType);
		Tensor_SetElemValue(dataPtr, lvalueType, curValue + newValue);
		break;

	    case '-':
		curValue = Tensor_GetElemValue(dataPtr, lvalueType);
		Tensor_SetElemValue(dataPtr, lvalueType, curValue - newValue);
		break;

	    case '*':
		curValue = Tensor_GetElemValue(dataPtr, lvalueType);
		Tensor_SetElemValue(dataPtr, lvalueType, curValue*newValue);
		break;

	    case '/':
		curValue = Tensor_GetElemValue(dataPtr, lvalueType);
		if(newValue != 0) {
		    Tensor_SetElemValue(dataPtr, lvalueType, curValue/newValue);
		}
		break;
	}

	succeeded = 0;
	for(i = order - 1; i >= 0; i--) {
	    exprIdx[idxMap[i]] += 1;
	    lvalueIdx[i]
		= NextIndexInSet(&(assignPtr->lvalue->indexList[i]),
							&(idxIter[i]));
	    if(lvalueIdx[i] >= 0) {
		succeeded = 1;
		break;
	    }
	    for(j = i; j < order; j++) {
		exprIdx[idxMap[j]] = 0;
		lvalueIdx[i] = InitIndexSetIterator(&(assignPtr->lvalue->indexList[j]),
								&(idxIter[j]));
	    }
	}

	if(!succeeded) {
	    break;
	}
    }

    return(TCL_OK);
}


/*
 *---------------------------------------------------------------
 *
 * TensorExprCmd --
 *
 *	TensorExprCmd implements the tensor::expr command.
 *
 * Results:
 *
 *	Returns a standard Tcl result.
 *
 * Side effects:
 *
 *	Tensors' contents may change.
 *
 *---------------------------------------------------------------
 */

int TensorExprCmd(ClientData clientData,
			Tcl_Interp *interp, int objc, Tcl_Obj *CONST objv[])
{
    int i, nTokens;
    int errorCode;
    char **tokenList;
    int nAssigns;
    Assignment **assignmentList;

    /* Turn the tensor expressions into a token list. */

    if(GetTokenList(interp, objc, objv, &nTokens, &tokenList) != TCL_OK) {
	return(TCL_ERROR);
    }

    /* Parse the token list into a list of assignments. */

    errorCode = ParseTokenList(interp, nTokens, tokenList,
						&nAssigns, &assignmentList);
    FreeTokenList(nTokens, tokenList);
    if(errorCode != TCL_OK) {
	return(TCL_ERROR);
    }

    /* Evaluate the expressions. */

    for(i = 0; i < nAssigns; i++) {
	if(EvalTensorAssignment(interp, assignmentList[i]) != TCL_OK) {
	    FreeParseTree(nAssigns, assignmentList);
	    return(TCL_ERROR);
	}
    }

    /* Free all the working storage. */

    FreeParseTree(nAssigns, assignmentList);

    return(TCL_OK);
}

