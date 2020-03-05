/*
 * Debugging code for the tensor expression stuff.
 */

static void PrintTensorIndex(int order, Tensor_Index idx)
{
    int i;

    for(i = 0; i < order; i++) {
	fprintf(stderr, " %1d", idx[i]);
    }
    fprintf(stderr, "\n");
}


static void PrintTokenList(int nTokens, char **tokenList)
{
    int i;

    for(i = 0; i < nTokens; i++) {
	fprintf(stderr, "%s\n", tokenList[i]);
    }
}

static void PrintIndexRange(IndexRange *rngPtr)
{
    if(rngPtr->first < 0) {
	fprintf(stderr, "end");
    } else {
	fprintf(stderr, "%1d", rngPtr->first);
    }

    if(rngPtr->last == rngPtr->first) {
	return;
    }

    fprintf(stderr, ":");
    if(rngPtr->last < 0) {
	fprintf(stderr, "end");
    } else {
	fprintf(stderr, "%1d", rngPtr->last);
    }

    if(rngPtr->step == 1) {
	return;
    }

    fprintf(stderr, ":");
    fprintf(stderr, "%1d", rngPtr->step);
}

static void PrintIndexSet(IndexSet *idxSetPtr)
{
    int i;

    if(idxSetPtr->nRanges > 1) {
	fprintf(stderr, "(");
    }

    for(i = 0; i < idxSetPtr->nRanges; i++) {
	if(i > 0) {
	    fprintf(stderr, ",");
	}
	PrintIndexRange(&(idxSetPtr->rangeList[i]));
    }

    if(idxSetPtr->nRanges > 1) {
	fprintf(stderr, ")");
    }
}

static void PrintTensorSection(TensorSection *secPtr)
{
    int i;

    fprintf(stderr, "%s(", secPtr->name);
    for(i = 0; i < secPtr->nIndices; i++) {
	if(i > 0) {
	    fprintf(stderr, ",");
	}
	fprintf(stderr, "%s=", secPtr->indexNames[i]);
	PrintIndexSet(&(secPtr->indexList[i]));
    }
    fprintf(stderr, ")");
}

static void PrintTensorExpr(TensorExpr *exprPtr);

static void PrintTensorFactor(TensorFactor *factPtr)
{
    switch(factPtr->factorType) {
	case FACTOR_TYPE_SCALAR:
	    fprintf(stderr, "%g", factPtr->factor.scalarValue);
	    break;

	case FACTOR_TYPE_TENSOR:
	    PrintTensorSection(factPtr->factor.section);
	    break;

	case FACTOR_TYPE_NEGFACT:
	    fprintf(stderr, "(-(");
	    PrintTensorFactor(factPtr->factor.negFactor);
	    fprintf(stderr, "))");
	    break;

	case FACTOR_TYPE_PAREXPR:
	    fprintf(stderr, "(");
	    PrintTensorExpr(factPtr->factor.parenExpr);
	    fprintf(stderr, ")");
	    break;
    }
}

static void PrintTensorTerm(TensorTerm *termPtr)
{
    if(termPtr == NULL) {
	fprintf(stderr, "termPtr == NULL!\n");
	return;
    }

    PrintTensorFactor(termPtr->firstFactor);
    if(termPtr->moreFactors != NULL) {
	fprintf(stderr, "%s", termPtr->op);
	PrintTensorTerm(termPtr->moreFactors);
    }
}

static void PrintTensorExpr(TensorExpr *exprPtr)
{
    if(exprPtr == NULL) {
	fprintf(stderr, "exprPtr == NULL!\n");
	return;
    }

    PrintTensorTerm(exprPtr->firstTerm);
    if(exprPtr->moreTerms != NULL) {
	fprintf(stderr, " %s ", exprPtr->op);
	PrintTensorExpr(exprPtr->moreTerms);
    }
}

static void PrintAssignment(Assignment *assignPtr)
{
    PrintTensorSection(assignPtr->lvalue);
    fprintf(stderr, " %s ", assignPtr->assignOp);
    PrintTensorExpr(assignPtr->expr);
}

static void PrintParseTree(int nAssigns, Assignment **assignList)
{
    int i;

    for(i = 0; i < nAssigns; i++) {
	PrintAssignment(assignList[i]);
	fprintf(stderr, "\n----------------\n");
    }
}

