
/*
 * tensorCmd.c --
 *
 *      Code for the tensor command and tensor object commands.
 *
 *
 * OPEN SOURCE SOFTWARE COPYRIGHT NOTICE
 *
 *
 * Copyright 2002 by General Motors Corporation.  All rights reserved.
 *
 * The following terms apply to all files associated with the software
 * unless otherwise explicitly stated in the individual files.
 *
 * Permission to use, copy, modify, and distribute this software and its
 * documentation for any purpose and without fee is hereby granted, provided
 * that the above copyright notice appears in all copies, and that both
 * the copyright notice and warranty disclaimer appear verbatim in all
 * copies and supporting documentation, and that the name and trademarks
 * of General Motors Corporation or any of its entities not be used in
 * advertising or publicity pertaining to the software without specific,
 * written prior permission.
 *
 * No written agreement, license or royalty fee is required for any of the
 * authorized uses.  Modifications to the software may be copyrighted by
 * their authors and need not follow these licensing terms, provided the
 * new terms are clearly indicated on the first page of each file to which
 * they apply.
 *
 * GENERAL MOTORS CORPORATION DISCLAIMS ANY AND ALL EXPRESS OR IMPLIED
 * WARRANTIES AND CONDITIONS OF ANY KIND WITH REGARD TO THIS SOFTWARE,
 * INCLUDING, WITHOUT LIMITATION, THE IMPLIED WARRANTIES OF MERCHANTABILITY
 * AND FITNESS FOR A PARTICULAR PURPOSE, AND ANY WARRANTIES OR CONDITIONS
 * OF TITLE OR NON-INFRINGEMENT.  GENERAL MOTORS CORPORATION MAKES NO
 * REPRESENTATION THAT THE USE OF THE SOFTWARE OR DOCUMENTATION WILL NOT
 * INFRINGE ANY THIRD PARTY PATENTS, COPYRIGHTS, TRADEMARKS OR OTHER RIGHTS.
 * THIS SOFTWARE IS PROVIDED ON AN "AS IS" BASIS, AND GENERAL MOTORS HAS
 * NO OBLIGATION TO PROVIDE MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS,
 * OR MODIFICATIONS OF ANY KIND.
 *
 * IN NO EVENT SHALL GENERAL MOTORS CORPORATION BE LIABLE TO ANY PARTY FOR
 * ANY DIRECT, INDIRECT, SPECIAL, INCIDENTAL, EXEMPLARY, CONSEQUENTIAL,
 * OR OTHER DAMAGES WHATSOEVER ARISING OUT OF, OR IN CONNECTION WITH, THE
 * DISTRIBUTION, USE AND PERFORMANCE OF THIS SOFTWARE, ITS DOCUMENTATION, OR
 * ANY DERIVATIVES THEREOF, HOWEVER CAUSED, AND ON ANY THEORY OF LIABILITY,
 * WHETHER IN CONTRACT, STRICT LIABILITY OR TORT, EVEN IF GENERAL MOTORS
 * CORPORATION HAD BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 * Each recipient, user and distributee is solely responsible for determining
 * the appropriateness of using, copying, modifying and distributing this
 * software and assumes all risks associated with the exercise of the rights
 * granted herein.
 *
 */


#ifndef lint
static char rcsid[] = "$Header: /home/neil/src/tcl/tensor/generic/RCS/tensorCmd.c,v 1.13 2008/06/14 17:08:17 neil Exp $";
#endif

#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>
#include "tensorInt.h"


/* Define the default tensor type. */

#define	DEF_TENSOR_TYPE	TENSOR_DOUBLE

/* Forward declarations. */

static int TensorObjCmd(ClientData clientData, Tcl_Interp * interp, int objc, Tcl_Obj *CONST objv[]);

/*
 *---------------------------------------------------------------
 *
 * Tensor_Lookup --
 *
 *      finds the pointer to the tensor descriptor for
 *	a tensor with a given name.
 *
 * Results:
 *      the pointer to the Tensor_Descrip struct for the tensor,
 *	if the tensor exists; otherwise, NULL.
 *
 * Side effects:
 *      None.
 *
 *---------------------------------------------------------------
 */


Tensor_Descrip *
Tensor_Lookup(
    Tcl_Interp *interp,	/* Interpreter to look in	*/
    char *name)		/* Name to look for		*/
{
    Tcl_CmdInfo info;

    if (!Tcl_GetCommandInfo(interp, name, &info)) {
	return ((Tensor_Descrip *) NULL);
    }

    if (info.objProc != TensorObjCmd) {
	return ((Tensor_Descrip *) NULL);
    }

    return ((Tensor_Descrip *) info.objClientData);
}


/*
 *---------------------------------------------------------------
 *
 * FreeTensor --
 *
 *      frees all storage associated with a tensor.
 *
 * Results:
 *      None.
 *
 * Side effects:
 *      The tensor's data and the tensor descriptor struct
 *	are both freed.
 *
 *---------------------------------------------------------------
 */

static void
FreeTensor(Tensor_Descrip *tensorPtr)
{
    if (tensorPtr->data != ((VOID *) NULL)) {
	ckfree((ClientData) tensorPtr->data);
    }
    ckfree((ClientData) tensorPtr);
}



/* This is for translating a tensor type name	*/
/* to the corresponding integer.		*/

static char *type_to_name[TENSOR_MAX_TYPE + 1] = {
    "double", "float", "int", "byte", "short", "unsigned"
};


/*
 *---------------------------------------------------------------
 *
 * TensorObjUsage --
 *
 *      writes the tensor object usage message into the
 *	interpreter's result string.
 *
 * Results:
 *      None.
 *
 * Side effects:
 *      The interpreter's result is set.
 *
 *---------------------------------------------------------------
 */

static void 
TensorObjUsage(
    Tcl_Interp *interp,	/* Interpreter to write into	*/
    char *name)		/* Name of object		*/

{
    Tcl_Obj *result;

    result = Tcl_NewStringObj("Usage:\n", -1);

    Tcl_AppendToObj(result, "\t", -1);
    Tcl_AppendToObj(result, name, -1);
    Tcl_AppendToObj(result, " order\n", -1);
    Tcl_AppendToObj(result, "\t", -1);
    Tcl_AppendToObj(result, name, -1);
    Tcl_AppendToObj(result, " type\n", -1);
    Tcl_AppendToObj(result, "\t", -1);
    Tcl_AppendToObj(result, name, -1);
    Tcl_AppendToObj(result, " dimensions\n", -1);
    Tcl_AppendToObj(result, "\t", -1);
    Tcl_AppendToObj(result, name, -1);
    Tcl_AppendToObj(result, " flipindices <index_list>\n", -1);
    Tcl_AppendToObj(result, "\t", -1);
    Tcl_AppendToObj(result, name, -1);
    Tcl_AppendToObj(result, " permuteindices <index_list>\n", -1);
    Tcl_AppendToObj(result, "\t", -1);
    Tcl_AppendToObj(result, name, -1);
    Tcl_AppendToObj(result, " <cross_section> write <file>\n", -1);
    Tcl_AppendToObj(result, "\t", -1);
    Tcl_AppendToObj(result, name, -1);
    Tcl_AppendToObj(result, " <cross_section> op operand\n", -1);
    Tcl_AppendToObj(result, "The cross-section is optional. Legal valuse for \"op\"\n", -1);
    Tcl_AppendToObj(result, "are =, +=, -=, *=, /=, <, <=, >, >=, ==, and !=.\n", -1);
    Tcl_AppendToObj(result, "Legal forms for the operand are\n", -1);
    Tcl_AppendToObj(result, "\ttensor <tensor> cross_section\n", -1);
    Tcl_AppendToObj(result, "\tarray <array>\n", -1);
    Tcl_AppendToObj(result, "\tscalar <value>\n", -1);
    Tcl_AppendToObj(result, "\tfile <file_name>\n", -1);
    Tcl_AppendToObj(result, "\tcontraction <tensor> <index-pair>\n", -1);
    Tcl_AppendToObj(result, "\tmultensor <tensor> <tensor> <index-pair>\n", -1);
    Tcl_AppendToObj(result, "\touter <tensor> <tensor>\n", -1);

    Tcl_SetObjResult(interp, result);
}

/* Table for getting special-case dimension names. */

static char *GetDimNames[] = {
	"row", "rows",	
	"col", "cols", "column", "columns",
	NULL
};

static int rowColTrans[] = {0, 0, 1, 1, 1, 1, -1};


/*
 *----------------------------------------------------------------------
 *
 * GetDimensionNo --
 *
 *	GetDimensionNo gets a dimension number from a string.
 *
 * Results:
 *	Returns a standard Tcl result.
 *
 * Side effects:
 *	Puts the dimension number into *dimNo.
 *
 *----------------------------------------------------------------------
 */

static int
GetDimensionNo(
    Tcl_Interp *interp,	/* For error messages		*/
    Tcl_Obj *objPtr,	/* Tcl_Obj to interpret		*/
    int *dimNo)		/* Dimension number goies here	*/
{
    int errcode;
    int idx;

    /* See if it's an int. */

    errcode = Tcl_GetIntFromObj(interp,objPtr,dimNo);
    if(errcode == TCL_OK) {
	if (*dimNo >= 0 && *dimNo < TENSOR_MAX_ORDER) {
	    return(TCL_OK);
	}
	Tcl_SetObjResult(interp,
		Tcl_NewStringObj("Dimension number out of range", -1));
	return(TCL_ERROR);
    }

    /* Check the special cases. */

    errcode = Tcl_GetIndexFromObj(interp, objPtr, GetDimNames,
					"dimension name", TCL_EXACT, &idx);
    if(errcode != TCL_OK) {
	return(TCL_ERROR);
    }

    *dimNo = rowColTrans[idx];
    return(TCL_OK);
}


/*
 *----------------------------------------------------------------------
 *
 * IntInRange --
 *
 *	IntInRange determines whether a given integer lies between
 *	0 and max inclusive. If it doesn't, it generates an
 *	appropriate error message.
 *
 * Results:
 *	Returns a standard Tcl result.
 *
 * Side effects:
 *	None.
 *
 *----------------------------------------------------------------------
 */

static int
IntInRange(
    Tcl_Interp *interp,	/* Error message goes here	*/
    int i,		/* Number to check		*/
    int max,		/* Max. allowable value		*/
    int pos)		/* Position - used to generate
			 * error message		*/
{
    Tcl_Obj *result;

    if (i < 0 || i > max) {
	result = Tcl_NewStringObj("Index ", -1);
	Tcl_AppendObjToObj(result, Tcl_NewIntObj(i));
	Tcl_AppendToObj(result, " at position ", -1);
	Tcl_AppendObjToObj(result, Tcl_NewIntObj(pos));
	Tcl_AppendToObj(result, " is out of range", -1);
	Tcl_SetObjResult(interp, result);
	return(TCL_ERROR);
    }

    return(TCL_OK);
}


/*
 *----------------------------------------------------------------------
 *
 * GetIndexList --
 *
 *	GetIndexList interprets a string as a list of tensor indices.
 *	The input string may be either the name of an order-1 tensor
 *	or a Tcl list. The index list must be freed by the caller.
 *
 * Results:
 *	Returns a standard Tcl result.
 *
 * Side effects:
 *	*nIndices and *idxList may be set.
 *
 *----------------------------------------------------------------------
 */

static int
GetIndexList(
    Tcl_Interp *interp,	/* Error messages go here */
    Tcl_Obj *obj,	/* Tcl_Obj to interpret as
			 * index list		  */
    int *nIndices,	/* Number of indices in
			 * list returned here	  */
    int **idxList)	/* Index list returned
			 * here			  */
{
    Tensor_Descrip *tensorPtr;
    int i;
    Tensor_Index tensorIdx;
    Tcl_Obj **idxObjList;

    /* See if the index list is a tensor name. */

    tensorPtr = Tensor_Lookup(interp,Tcl_GetString(obj));
    if(tensorPtr != (Tensor_Descrip *) NULL) {
	/* Index list is a tensor. Check it out. */

	if(tensorPtr->order != 1) {
	    Tcl_SetObjResult(interp,
		Tcl_NewStringObj("index list must be order-one tensor", -1));
	    return(TCL_ERROR);
	}

	/* Allocate the (integer) index list and copy the tensor into it. */

	*nIndices = tensorPtr->dims[0];
	*idxList = (int *) ckalloc((*nIndices)*sizeof(int));
	if((*idxList) == (int *) NULL) {
	    Tcl_SetObjResult(interp, Tcl_NewStringObj("out of storage", -1));
	    return(TCL_ERROR);
	}

	for(i = 0; i < *nIndices; i++) {
	    tensorIdx[0] = i;
	    (*idxList)[i] = Tensor_GetElemValue(Tensor_GetElemPtr(tensorPtr,tensorIdx),
								tensorPtr->type);
	}

	return(TCL_OK);
    }

    /* Not a tensor, must be a list. */

    if(Tcl_ListObjGetElements(interp,obj,nIndices,&idxObjList) != TCL_OK) {
	return(TCL_ERROR);
    }

    /* Allocate storage for index list, and fill it. */

    *idxList = (int *) ckalloc((*nIndices)*sizeof(int));
    if((*idxList) == (int *) NULL) {
	Tcl_SetObjResult(interp, Tcl_NewStringObj("out of storage", -1));
	return(TCL_ERROR);
    }

    for(i = 0; i < (*nIndices); i++) {
	if(Tcl_GetIntFromObj(interp,idxObjList[i],&((*idxList)[i])) != TCL_OK) {
	    ckfree((VOID *) (*idxList));
	    return(TCL_ERROR);
	}
    }

    return(TCL_OK);
}


/*
 *----------------------------------------------------------------------
 *
 * IntListItemsUnique --
 *
 *	IntListItemsUnique determines whether the items in an array
 *	of integers are all unique. If they are unique, and all are
 *	between 0 and max, the function returns TCL_OK; otherwise,
 *	it returns TCL_ERROR and puts an error message in interp.
 *
 * Results:
 *	Returns a standard Tcl result.
 *
 * Side effects:
 *	None.
 *
 *----------------------------------------------------------------------
 */

static int
IntListItemsUnique(
    Tcl_Interp *interp,	/* Error messages go here	*/
    int nItems,		/* Number of items in list	*/
    int *idxList,	/* list of integers		*/
    int max)		/* Maximum value allowed in list*/
{
    char *found;
    int i, el;
    Tcl_Obj *result;

    /* Allocate storage for the "found" array. */

    found = (char *) ckalloc(max + 1);
    if (found == (char *) NULL) {
	Tcl_SetObjResult(interp, Tcl_NewStringObj("out of storage", -1));
	return(TCL_ERROR);
    }

    for(i = 0; i <= max; i++) {
	found[i] = 0;
    }

    for(i = 0; i < nItems; i++) {
	el = idxList[i];
	if(IntInRange(interp,el,max,i) != TCL_OK) {
	    ckfree((VOID *) found);
	    return(TCL_ERROR);
	}
	if(found[el]) {
	    ckfree((VOID *) found);
	    result = Tcl_NewStringObj("Index ", -1);
	    Tcl_AppendObjToObj(result, Tcl_NewIntObj(el));
	    Tcl_AppendToObj(result, " at position ", -1);
	    Tcl_AppendObjToObj(result, Tcl_NewIntObj(i));
	    Tcl_AppendToObj(result, " is a duplicate", -1);
	    Tcl_SetObjResult(interp, result);
	    return(TCL_ERROR);
	}
	found[el] = 1;
    }

    ckfree((VOID *) found);
    return(TCL_OK);
}


/* Table for getting comparison operators. */

static char *CompOpTab[] = {
	"true",
	"==",
	"!=",
	">",
	">=",
	"<",
	"<=",
	NULL
};

//------------------------------------------------------------------------------
/*
 *---------------------------------------------------------------
 *
 * TensorObjCmd --
 *
 *      executes the tensor's object command.
 *
 * Results:
 *      Standard TCL result.
 *
 * Side effects:
 *      Depends on which object command is executed.
 *
 *---------------------------------------------------------------
 */
//------------------------------------------------------------------------------

#define	TENSOR_OP_CLASS_OP	0	/* Tensor operation: +, -, *, /, assign	*/
#define	TENSOR_OP_CLASS_CMP	1	/* Tensor comparison: >, <, >=, <=, ...	*/
#define	TENSOR_OP_CLASS_LSTI	2	/* Conditionally list tensor indices	*/

static int 
TensorObjCmd(ClientData clientData, Tcl_Interp *interp, int objc, Tcl_Obj *CONST objv[])
{

    Tensor_Descrip *tensor;	/* This is the tensor we're     */
				/* operating on...              */
    Tensor_Index low_indices;	/* ...and these are the low and */
    Tensor_Index high_indices;	/* high indices of the section  */
				/* of that tensor we're using.  */

    Tensor_Descrip src_tensor;	/* This is the "source" tensor  */
				/* for the assignment operators */
				/* that require one...          */
    Tensor_Index src_low_indices;	/* ...and these define what	*/
    Tensor_Index src_high_indices;	/* portion we'll actually use.	*/

    Tensor_Descrip *boolOp1Ptr, *boolOp2Ptr;
    Tensor_Index op1_low_indices, op1_high_indices;
    Tensor_Index op2_low_indices, op2_high_indices;
    char bool_op;
    double comp_no;

    Tcl_Obj *result;
    int i, l, arg_no;
    int getIndices;
    int *listIndices;
    int nListIndices;
    Tcl_Obj **listIndexList;
    int write_binary;
    char op;
    char *str;
    int opClass;
    int index_map[TENSOR_MAX_ORDER];
    int idx_list[TENSOR_MAX_ORDER];
    double d;
    Tcl_Channel chan;
    int chanMode;
    Tensor_Descrip *tmp_tensor, *tensor_pt[2];
    int llength, err_code;
    Tcl_Obj **objPtrPtr;
    double lowSat, highSat;
    int freeTab;
    int substTabSize;
    double *substTab;
    int dimNo, nItems;
    int *idxList;
    int insAfter, insPos;
    Tcl_Obj *arrayName;
    int arraySelCond;
    double arrayCompVal;
    Tensor_Index arrayOffset;

    tensor = (Tensor_Descrip *) clientData;

    /* First, we handle the commands that operate only on entire	*/
    /* tensors, not on tensor sections: "order", "type", "is_empty",	*/
    /* "dimensions", "flipindices", and "permuteindices".		*/

    if (objc >= 2 && !strcmp(Tcl_GetString(objv[1]), "order")) {
	if (objc != 2) {
	    Tcl_SetObjResult(interp, Tcl_NewStringObj(
		    "tensor order command accepts no arguments", -1));
	    return (TCL_ERROR);
	}

	Tcl_SetObjResult(interp, Tcl_NewIntObj(tensor->order));
	return (TCL_OK);
    }

    if (objc >= 2 && !strcmp(Tcl_GetString(objv[1]), "type")) {
	if (objc != 2) {
	    Tcl_SetObjResult(interp, Tcl_NewStringObj(
		    "tensor type command accepts no arguments", -1));
	    return (TCL_ERROR);
	}
	Tcl_SetObjResult(interp,
		Tcl_NewStringObj(type_to_name[tensor->type], -1));
	return (TCL_OK);
    }

    if (objc >= 2 && !strcmp(Tcl_GetString(objv[1]), "is_empty")) {
	if (objc != 2) {
	    Tcl_SetObjResult(interp, Tcl_NewStringObj(
		    "tensor is_empty command accepts no arguments", -1));
	    return (TCL_ERROR);
	}

	Tcl_SetObjResult(interp,
		Tcl_NewBooleanObj(tensor->data == (VOID *) NULL));

	return (TCL_OK);
    }

    if (objc >= 2 && !strcmp(Tcl_GetString(objv[1]), "dimensions")) {
	if (objc != 2) {
	    Tcl_SetObjResult(interp, Tcl_NewStringObj(
		    "tensor dimensions command accepts no arguments", -1));
	    return (TCL_ERROR);
	}

	result = Tcl_NewObj();

	for(i = 0; i < tensor->order; i++) {
	    Tcl_ListObjAppendElement(NULL, result, Tcl_NewIntObj(tensor->dims[i]));
	}

	Tcl_SetObjResult(interp, result);

	return (TCL_OK);
    }

    if (objc >= 2 && !strcmp(Tcl_GetString(objv[1]), "flipindices")) {
	int n_indices;

	if (objc != 3) {
	    Tcl_SetObjResult(interp, Tcl_NewStringObj(
		    "tensor flipindices command must be followed by exactly one argument",
			     -1));
	    return (TCL_ERROR);
	}
	if (TensorGetDims(interp, objv[2], &n_indices, idx_list) != TCL_OK) {
	    return (TCL_ERROR);
	}
	if (TensorFlipIndices(interp, tensor, idx_list, n_indices) != TCL_OK) {
	    return (TCL_ERROR);
	}

	return (TCL_OK);
    }

    if (objc >= 2 && !strcmp(Tcl_GetString(objv[1]), "permuteindices")) {
	int n_indices;

	if (objc != 3) {
	    Tcl_SetObjResult(interp, Tcl_NewStringObj(
		    "tensor permuteindices command must be followed by exactly one argument",
		     -1));
	    return (TCL_ERROR);
	}

	if (TensorGetDims(interp, objv[2], &n_indices, idx_list) != TCL_OK) {
	    return (TCL_ERROR);
	}

	if (TensorPermuteIndices(interp, tensor, idx_list, n_indices) != TCL_OK) {
	    return (TCL_ERROR);
	}

	return (TCL_OK);
    }

    if (objc >= 2 && !strcmp(Tcl_GetString(objv[1]), "reshape")) {
	int n_indices, oldSize, newSize;

	if (objc != 3) {
	    Tcl_SetObjResult(interp, Tcl_NewStringObj(
		    "tensor reshape command must be followed by exactly one argument",
		     -1));
	    return (TCL_ERROR);
	}

	if (TensorGetDims(interp, objv[2], &n_indices, idx_list) != TCL_OK) {
	    return (TCL_ERROR);
	}

	for(i = 0, oldSize = 1; i < tensor->order; i++) {
	    oldSize *= tensor->dims[i];
	}

	for(i = 0, newSize = 1; i < n_indices; i++) {
	    newSize *= idx_list[i];
	}

	if(newSize != oldSize) {
	    Tcl_SetObjResult(interp, Tcl_NewStringObj(
			"reshape tensor command changes tensor size", -1));
	    return(TCL_ERROR);
	}

	tensor->order = n_indices;
	for(i = 0; i < n_indices; i++) {
	    tensor->dims[i] = idx_list[i];
	}

	return (TCL_OK);
    }


    if (objc >= 2 && !strcmp(Tcl_GetString(objv[1]), "swap")) {
	if (objc != 4) {
	    Tcl_SetObjResult(interp, Tcl_NewStringObj(
			"Usage: <tensor> swap <index> <swapList>", -1));
	    return(TCL_ERROR);
	}

	/* Get the dimension number. */

	if(GetDimensionNo(interp,objv[2],&dimNo) != TCL_OK) {
	    return(TCL_ERROR);
	}

	/* Get the swap list. */

	if(GetIndexList(interp,objv[3],&nItems,&idxList) != TCL_OK) {
	    return(TCL_ERROR);
	}

	if(nItems != 2) {
	    ckfree((VOID *) idxList);
	    Tcl_SetObjResult(interp, Tcl_NewStringObj(
		    "swap list must contain exactly two elements", -1));
	    return(TCL_ERROR);
	}

	/* Make sure the swap indices are distinct and within range. */

	if(IntListItemsUnique(interp,2,idxList,tensor->dims[dimNo] - 1) != TCL_OK) {
	    ckfree((VOID *) idxList);
	    return(TCL_ERROR);
	}

	/* DO it! */

	err_code = TensorSwap(interp,tensor,dimNo,idxList);
	ckfree((VOID *) idxList);
	return(err_code);
    }

    if (objc >= 2 && !strcmp(Tcl_GetString(objv[1]), "permute")) {
	if (objc != 4) {
	    Tcl_SetObjResult(interp, Tcl_NewStringObj(
		    "Usage: <tensor> permute <index> <permuteList>", -1));
	    return(TCL_ERROR);
	}

	/* Get the dimension number. */

	if(GetDimensionNo(interp,objv[2],&dimNo) != TCL_OK) {
	    return(TCL_ERROR);
	}

	/* Get the permute list. */

	if(GetIndexList(interp,objv[3],&nItems,&idxList) != TCL_OK) {
	    return(TCL_ERROR);
	}

	/* Make sure we have a valid permute list, i.e. that
	 * the list is the right length, and that the numbers
	 * 0 through nItems-1 occur exactly once.		*/

	if(nItems != tensor->dims[dimNo]) {
	    ckfree((VOID *) idxList);
	    Tcl_SetObjResult(interp, Tcl_NewStringObj(
		    "length of permute list doesn't match tensor size", -1));
	    return(TCL_ERROR);
	}

	if(IntListItemsUnique(interp,nItems,idxList,nItems - 1) != TCL_OK) {
	    ckfree((VOID *) idxList);
	    return(TCL_ERROR);
	}

	/* DO it! */

	err_code = TensorPermute(interp,tensor,dimNo,idxList);
	ckfree((VOID *) idxList);
	return(err_code);
    }

    if (objc >= 2 && !strcmp(Tcl_GetString(objv[1]), "delete")) {
	if (objc != 4) {
	    Tcl_SetObjResult(interp, Tcl_NewStringObj(
		    "Usage: <tensor> delete <index> <deleteList>", -1));
	    return(TCL_ERROR);
	}

	/* Get the dimension number. */

	if(GetDimensionNo(interp,objv[2],&dimNo) != TCL_OK) {
	    return(TCL_ERROR);
	}

	/* Get the delete list. */

	if(GetIndexList(interp,objv[3],&nItems,&idxList) != TCL_OK) {
	    return(TCL_ERROR);
	}

	/* Make sure that the delete list contains only numbers
	 * that are in range, and that they occur only once.	*/

	if(IntListItemsUnique(interp,nItems,idxList,tensor->dims[dimNo] - 1) != TCL_OK) {
	    ckfree((VOID *) idxList);
	    return(TCL_ERROR);
	}

	/* DO it! */

	err_code = TensorDelete(interp,tensor,dimNo,nItems,idxList);
	ckfree((VOID *) idxList);
	return(err_code);
    }

    if (objc >= 2 && !strcmp(Tcl_GetString(objv[1]), "insert")) {
	if (objc != 6) {
	    Tcl_SetObjResult(interp, Tcl_NewStringObj(
		"Usage: <tensor> insert <num> <index> {before|after} <pos>",
									-1));
	    return(TCL_ERROR);
	}

	/* Get the number of items to insert. */

	if(Tcl_GetIntFromObj(interp,objv[2],&nItems) != TCL_OK) {
	    return(TCL_ERROR);
	}

	if(nItems < 0) {
	    Tcl_SetObjResult(interp, Tcl_NewStringObj(
		    "Cannot insert a negative number of items!", -1));
	    return(TCL_ERROR);
	}

	if(nItems == 0) {
	    return(TCL_OK);
	}

	/* Get the dimension we're inserting along. */

	if(GetDimensionNo(interp,objv[3],&dimNo) != TCL_OK) {
	    return(TCL_ERROR);
	}

	if(dimNo < 0 || dimNo >= tensor->order) {
	    Tcl_SetObjResult(interp, Tcl_NewStringObj(
		    "out-of-range dimension number", -1));
	    return(TCL_ERROR);
	}

	/* Before or after? */

	if(!strcmp(Tcl_GetString(objv[4]),"before")) {
	    insAfter = 0;
	} else if (!strcmp(Tcl_GetString(objv[4]),"after")) {
	    insAfter = 1;
	} else {
	    Tcl_SetObjResult(interp, Tcl_NewStringObj(
		"Usage: <tensorName> insert <num> <dimNumber> {before|after} <pos>",
		    -1));
	    return(TCL_ERROR);
	}

	/* Get the insertion position. */

	if(!strcmp(Tcl_GetString(objv[5]),"end")) {
	    insPos = tensor->dims[dimNo] - 1;
	} else if(Tcl_GetIntFromObj(interp,objv[5],&insPos) != TCL_OK) {
	    return(TCL_ERROR);
	}

	if(insAfter) {
	    insPos++;
	}


	if(insPos < 0 || insPos > tensor->dims[dimNo]) {
	    Tcl_SetObjResult(interp, Tcl_NewStringObj(
		    "insertion position out of range", -1));
	    return(TCL_ERROR);
	}

	/* DO it! */

	return(TensorInsert(interp,tensor,nItems,dimNo,insPos));
    }

    /* Now we'll handle all the other tensor object commands. The	*/
    /* general approach is as follows:					*/
    /*									*/
    /* 1) Determine what portion of the tensor we're going to operate	*/
    /*	  on. We'll set "low_indices" and "high_indices" to indicate	*/
    /*	  this.								*/
    /*									*/
    /* 2) Determine what operation we're going to perform. If there	*/
    /*	  are no more operands, then just print the tensor. Otherwise,	*/
    /*	  the operation will either be a "write" or some sort of	*/
    /*	  assignment.							*/
    /*									*/
    /* 3) If we're doing a "write", get the file name or ID, and the	*/
    /*	  (optional) write mode (i.e. binary or ASCII), write the	*/
    /*	  specified tensor cross-section, and return.			*/
    /*									*/
    /* 4) Execute the "minmax", "saturate, or "substitute" command,	*/
    /*	  if that's what's called for.					*/
    /*									*/
    /* 5) Get the assignment or comparison operator.			*/
    /*									*/
    /* 6) If the operand type is "scalar", then get the scalar value,	*/
    /*	  perform the operation or comparison, and return		*/
    /*									*/
    /* 7) Otherwise, get the operand tensor, store it in "src_tensor",	*/
    /*	  perform the operation or comparison, clean up, and return.	*/


    /* Get the optional cross-section. */

    arg_no = 1;

    for (i = 0; i < tensor->order; i++) {
	low_indices[i] = 0;
	high_indices[i] = tensor->dims[i] - 1;
    }

    if (arg_no < objc && !strcmp(Tcl_GetString(objv[arg_no]), "section")) {
	arg_no++;
	if (arg_no >= objc) {
	    Tcl_SetObjResult(interp, Tcl_NewStringObj(
		"\"section\" must be followed by a tensor cross-section", -1));
	    return (TCL_ERROR);
	}
	if (TensorGetSectionIndex(interp, objv[arg_no],
				 tensor, low_indices, high_indices) != TCL_OK) {
	    return (TCL_ERROR);
	}
	arg_no++;
    }

    /* If we're out of arguments, print the cross-section. */

    if (arg_no >= objc) {
	TensorPutSection(interp, tensor, low_indices, high_indices);
	return (TCL_OK);
    }

    /* See if we're doing a write. */

    if (!strcmp(Tcl_GetString(objv[arg_no]), "write")) {
	arg_no++;

	if (arg_no >= objc) {
	    Tcl_SetObjResult(interp, Tcl_NewStringObj(
			"Missing file for tensor write", -1));
	    return (TCL_ERROR);
	}
	if (objc - arg_no > 2) {
	    Tcl_SetObjResult(interp, Tcl_NewStringObj(
		    "Too many args follow file for tensor write", -1));
	    return (TCL_ERROR);
	}

	/* Decide if we're writing in binary or ASCII format. */

	if (objc - arg_no <= 1) {
	    write_binary = 1;
	} else if (!strcmp(Tcl_GetString(objv[arg_no + 1]), "binary")) {
	    write_binary = 1;
	} else if (!strcmp(Tcl_GetString(objv[arg_no + 1]), "ascii")
		 || !strcmp(Tcl_GetString(objv[arg_no + 1]), "text")) {
	    write_binary = 0;
	} else {
	    result = Tcl_NewStringObj("Unknown tensor file format \"", -1);
	    Tcl_AppendObjToObj(result, objv[arg_no + 1]);
	    Tcl_SetObjResult(interp, result);
	    return (TCL_ERROR);
	}

	/* Open the file. */

	chan = Tcl_FSOpenFileChannel(interp, objv[arg_no], "w", 0777);
	if (chan == (Tcl_Channel) NULL) {
	    result = Tcl_NewStringObj("Couldn't open file \"", -1);
	    Tcl_AppendObjToObj(result, objv[arg_no]);
	    Tcl_AppendToObj(result, "\" for writing", -1);
	    Tcl_SetObjResult(interp, result);
	    return (TCL_ERROR);
	}

	/* Write the file. */

	err_code = TensorWriteSection(interp, tensor,
				 low_indices, high_indices, chan, write_binary);
	Tcl_Close(interp, chan);
	return (err_code);
    }

    /* See if we're doing a write. */

    if (!strcmp(Tcl_GetString(objv[arg_no]), "writechannel")) {
	arg_no++;

	if (arg_no >= objc) {
	    Tcl_SetObjResult(interp, Tcl_NewStringObj(
			"Missing channel for tensor writechannel", -1));
	    return (TCL_ERROR);
	}
	if (objc - arg_no > 2) {
	    Tcl_SetObjResult(interp, Tcl_NewStringObj(
		"Too many args follow channel for tensor writechannel", -1));
	    return (TCL_ERROR);
	}

	/* Decide if we're writing in binary or ASCII format. */

	if (objc - arg_no <= 1) {
	    write_binary = 1;
	} else if (!strcmp(Tcl_GetString(objv[arg_no + 1]), "binary")) {
	    write_binary = 1;
	} else if (!strcmp(Tcl_GetString(objv[arg_no + 1]), "ascii")
		 || !strcmp(Tcl_GetString(objv[arg_no + 1]), "text")) {
	    write_binary = 0;
	} else {
	    result = Tcl_NewStringObj("Unknown tensor file format \"", -1);
	    Tcl_AppendObjToObj(result, objv[arg_no + 1]);
	    Tcl_AppendToObj(result, "\"", -1);
	    Tcl_SetObjResult(interp, result);
	    return (TCL_ERROR);
	}

	/* Open the file. */

	chan = Tcl_GetChannel(interp, Tcl_GetString(objv[arg_no]), &chanMode);
	if(chan == (Tcl_Channel) NULL) {
	    result = Tcl_NewStringObj("Channel \"", -1);
	    Tcl_AppendObjToObj(result, objv[arg_no]);
	    Tcl_AppendToObj(result, "\" is not open", -1);
	    Tcl_SetObjResult(interp, result);
	    return (TCL_ERROR);
	}

	if(!(chanMode & TCL_WRITABLE)) {
	    result = Tcl_NewStringObj("Channel \"", -1);
	    Tcl_AppendObjToObj(result, objv[arg_no]);
	    Tcl_AppendToObj(result, "\" is not writable", -1);
	    Tcl_SetObjResult(interp, result);
	    return (TCL_ERROR);
	}

	/* Write the file. */

	err_code = TensorWriteSection(interp, tensor,
				 low_indices, high_indices, chan, write_binary);
	return (err_code);
    }

    /* See if we're doing a minmax. */

    if (!strcmp(Tcl_GetString(objv[arg_no]), "minmax")) {
	/* Check for the "-indices" switch. */

	getIndices = 0;
	arg_no += 1;
	if(arg_no < objc) {
	    if(!strcmp(Tcl_GetString(objv[arg_no]),"-indices")) {
		getIndices = 1;
	    } else {
		Tcl_SetObjResult(interp, Tcl_NewStringObj(
			"Illegal option to minmax tensor command", -1));
		return(TCL_ERROR);
	    }
	    arg_no += 1;
	}

	if (arg_no < objc) {
	    Tcl_SetObjResult(interp, Tcl_NewStringObj(
		    "extraneous arguments follow minmax tensor command", -1));
	    return (TCL_ERROR);
	}
	return(TensorMinMax(interp, tensor, low_indices, high_indices, getIndices));
    }

    if(Tcl_GetString(objv[arg_no])[0] == 's') {
	/* Check for the "saturate"  command. */

	if (!strcmp(Tcl_GetString(objv[arg_no]), "saturate")) {
	    if (objc != (arg_no + 3)) {
		TensorObjUsage(interp, Tcl_GetString(objv[0]));
		return (TCL_ERROR);
	    }

	    if(Tcl_GetDoubleFromObj(interp,objv[arg_no + 1], &lowSat) != TCL_OK) {
		return(TCL_ERROR);
	    }

	    if(Tcl_GetDoubleFromObj(interp,objv[arg_no + 2], &highSat) != TCL_OK) {
		return(TCL_ERROR);
	    }

	    TensorSaturate(tensor, low_indices, high_indices, lowSat, highSat);

	    return(TCL_OK);
        }

	/* Check for the "substitute"  command. */

	if (!strcmp(Tcl_GetString(objv[arg_no]), "substitute")) {
	    if (objc != (arg_no + 2)) {
		TensorObjUsage(interp, Tcl_GetString(objv[0]));
		return (TCL_ERROR);
	    }

	    tmp_tensor = Tensor_Lookup(interp, Tcl_GetString(objv[arg_no + 1]));
	    if(tmp_tensor != (Tensor_Descrip *) NULL) {
		if(tmp_tensor->order != 1) {
		    Tcl_SetObjResult(interp, Tcl_NewStringObj(
			"tensor substitution table must be order-1 tensor",
									-1));
		    return(TCL_ERROR);
		}

		substTabSize = tmp_tensor->dims[0];

		/* Don't allocate lookup table if we don't have to. */

		if(tmp_tensor->type == TENSOR_DOUBLE) {
		    freeTab = 0;
		    substTab = (double *) (tmp_tensor->data);
	        } else {
		    Tensor_Index tensorIdx;

		    freeTab = 1;
		    substTab = (double *) ckalloc(substTabSize*sizeof(double));
		    if(substTab == (double *) NULL) {
			Tcl_SetObjResult(interp,
				Tcl_NewStringObj("out of storage", -1));
			return(TCL_ERROR);
		    }
		    for(i = 0; i < substTabSize; i++) {
			tensorIdx[0] = i;
			substTab[i] = Tensor_GetElemValue(
					Tensor_GetElemPtr(tmp_tensor,tensorIdx),
					tmp_tensor->type);
		    }
		}
	    } else {
		if(Tcl_ListObjGetElements(interp, objv[arg_no + 1],
			&substTabSize, &objPtrPtr) != TCL_OK) {
		    return(TCL_ERROR);
		}

		freeTab = 1;
		substTab = (double *) ckalloc(substTabSize*sizeof(double));
		if(substTab == (double *) NULL) {
		    Tcl_SetObjResult(interp,
				Tcl_NewStringObj("out of storage", -1));
		    return(TCL_ERROR);
		}
		for(i = 0; i < substTabSize; i++) {
		    if(Tcl_GetDoubleFromObj(interp, objPtrPtr[i], &(substTab[i])) != TCL_OK) {
			ckfree((VOID *) substTab);
			return(TCL_ERROR);
		    }
		}
	    }

	    TensorSubst(tensor, low_indices, high_indices, substTabSize, substTab);

	    if(freeTab) {
		ckfree((VOID *) substTab);
	    }
	    return(TCL_OK);
	}

	if (!strcmp(Tcl_GetString(objv[arg_no]), "sequence")) {
	    if (objc != (arg_no + 1)) {
		TensorObjUsage(interp, Tcl_GetString(objv[0]));
		return (TCL_ERROR);
	    }

	    TensorSequ(tensor, low_indices, high_indices);
	    return(TCL_OK);
	}

	/* Unknown command beginning with "s". */

	TensorObjUsage(interp, Tcl_GetString(objv[0]));
	return(TCL_ERROR);
    }

    /* See if we're doing a "put" command. */

    if(!strcmp(Tcl_GetString(objv[arg_no]), "put")) {
	/* Check args. */

	if (objc < (arg_no + 3)) {
	    TensorObjUsage(interp, Tcl_GetString(objv[0]));
	    return (TCL_ERROR);
	}

	arg_no += 1;
	if(strcmp(Tcl_GetString(objv[arg_no]), "into")) {
	    Tcl_SetObjResult(interp, Tcl_NewStringObj(
		"\"put\" must be followed by \"into\" and an array name", -1));
	    return(TCL_ERROR);
	}

	arg_no += 1;

	/* Save the array name. */

	arrayName = objv[arg_no];
	arg_no += 1;

	/* Get the "if" clause, if any. */

	arraySelCond = _TENSOR_ALWAYS;
	if(arg_no < objc && !strcmp(Tcl_GetString(objv[arg_no]),"if")) {
	    arg_no += 1;
	    if(arg_no >= objc) {
		Tcl_SetObjResult(interp, Tcl_NewStringObj(
		    "\"if\" must be followed by a comparison operator", -1));
		return(TCL_ERROR);
	    }

	    err_code = Tcl_GetIndexFromObj(interp, objv[arg_no], CompOpTab,
		    "illegal comparison operator", TCL_EXACT, &arraySelCond);
	    if(err_code != TCL_OK) {
		return(TCL_ERROR);
	    }

	    arg_no += 1;
	    if(arg_no >= objc) {
		Tcl_SetObjResult(interp, Tcl_NewStringObj(
		    "comparison operator must be followed by a number", -1));
		return(TCL_ERROR);
	    }

	    if(Tcl_GetDoubleFromObj(interp, objv[arg_no], &arrayCompVal) != TCL_OK) {
		return(TCL_ERROR);
	    }

	    arg_no += 1;
	}

	/* Set options to default values. */

	for(i = 0; i < tensor->order; i++) {
	    arrayOffset[i] = 0;
	}

	/* Check out the other args, if there are any. */

	while(arg_no < objc) {
	    if(!strcmp(Tcl_GetString(objv[arg_no]),"-offset")) {
		arg_no += 1;
		if(arg_no >= objc) {
		    Tcl_SetObjResult(interp, Tcl_NewStringObj(
			    "-offset must be followed by an index offset", -1));
		    return(TCL_ERROR);
		}

		if(Tcl_ListObjGetElements(interp, objv[arg_no], &nItems, &objPtrPtr) != TCL_OK) {
		    return(TCL_ERROR);
		}

		if(nItems != tensor->order) {
		    Tcl_SetObjResult(interp, Tcl_NewStringObj(
			"offset vector length doesn't match tensor order", -1));
		    return(TCL_ERROR);
		}

		for(i = 0; i < nItems; i++) {
		    if(Tcl_GetIntFromObj(interp, objPtrPtr[i], &(arrayOffset[i])) != TCL_OK) {
			return(TCL_ERROR);
		    }
		}
		arg_no += 1;
	    } else {
		result = Tcl_NewStringObj("unknown option \"", -1);
		Tcl_AppendObjToObj(result, objv[arg_no]);
		Tcl_AppendToObj(result,
			"\" of tensor \"put into\" command", -1);
		Tcl_SetObjResult(interp, result);
		return(TCL_ERROR);
	    }
	}

	/* Put the tensor elements into the array. */

	TensorPutIntoArray(interp, tensor, low_indices, high_indices,
				arrayName, arraySelCond, arrayCompVal,
				arrayOffset);

	return(TCL_OK);
    }

    /* See if we're doing an "apply". */

    if (!strcmp(Tcl_GetString(objv[arg_no]), "apply")) {
	arg_no++;

	/* Get the name of the function we're supposed to apply. */

	if(arg_no >= objc) {
	    Tcl_SetObjResult(interp, Tcl_NewStringObj(
		    "\"apply\" must be followed by a function name", -1));
	    return(TCL_ERROR);
	}

	if ((objc - arg_no) > 1) {
	    Tcl_SetObjResult(interp, Tcl_NewStringObj(
		    "extraneous arguments follow apply tensor command", -1));
	    return (TCL_ERROR);
	}

	return(TensorApplyFunc(interp, tensor,
			low_indices, high_indices, Tcl_GetString(objv[arg_no])));
    }

    /* We've taken care of the write , minmax, etc. commands;	*/
    /* we must be dealing with an assignment, a comparison, or	*/
    /* the "listindices" command.				*/

    /*@@@ This code is pretty hacky; it should be cleaned up. @@@*/

    listIndices = (int *) NULL;
    str = Tcl_GetString(objv[arg_no]);
    l = strlen(str);
    if (strcmp(str, "listindices") == 0) {
	/* Get the component list. */

	arg_no++;
	if (arg_no >= objc) {
	    result = Tcl_NewStringObj(
			"Usage: tensor ?sectionSpec? listindices ", -1);
	    Tcl_AppendToObj(result,
		"?componentList? where comparisonOp operand", -1);

	    Tcl_SetObjResult(interp, result);
	    return TCL_ERROR;
	}

	if (strcmp(Tcl_GetString(objv[arg_no]), "where") == 0) {
	    nListIndices = tensor->order;
	    listIndices = (int *) ckalloc(nListIndices*sizeof(int));
	    if (listIndices == (int *) NULL) {
		Tcl_SetObjResult(interp,
			Tcl_NewStringObj("out of memory", -1));
		return TCL_ERROR;
	    }
	    for(i = 0; i < nListIndices; i++) {
		listIndices[i] = i;
	    }
	} else {
	    if (Tcl_ListObjGetElements(interp, objv[arg_no], &nListIndices, &listIndexList) != TCL_OK) {
		return TCL_ERROR;
	    }
	    listIndices = (int *) ckalloc(nListIndices*sizeof(int));
	    if (listIndices == (int *) NULL) {
		ckfree((VOID *) listIndexList);
		Tcl_SetObjResult(interp, Tcl_NewStringObj("out of memory", -1));
		return TCL_ERROR;
	    }

	    for (i = 0; i < nListIndices; i++) {
		if (Tcl_GetIntFromObj(interp, listIndexList[i], &(listIndices[i])) != TCL_OK) {
		    ckfree((VOID *) listIndices);
		    return TCL_ERROR;
		}
	    }

	    arg_no++;
	}

	/* Next we better have the "where" keyword. */

	if (strcmp(Tcl_GetString(objv[arg_no]), "where") != 0) {
	    ckfree((VOID *) listIndices);
	    Tcl_SetObjResult(interp, Tcl_NewStringObj(
				"missing \"where\" keyword", -1));
	    return TCL_ERROR;
	}
	arg_no++;

	/* Get the comparison operator. */

	if (arg_no >= objc) {
	    ckfree((VOID *) listIndices);
	    Tcl_SetObjResult(interp, Tcl_NewStringObj(
			"\"where\" should be followed by a comparison op", -1));
	    return TCL_ERROR;
	}

	str = Tcl_GetString(objv[arg_no]);
	l = strlen(str);
	if (l < 1 || l > 2) {
	    ckfree((VOID *) listIndices);
	    result = Tcl_NewStringObj("unknown comparison operator \"", -1);
	    Tcl_AppendObjToObj(result, objv[arg_no]);
	    Tcl_AppendToObj(result, "\"", -1);
	    Tcl_SetObjResult(interp, result);
	    return TCL_ERROR;
	}

	opClass = TENSOR_OP_CLASS_LSTI;
	if (l == 1) {
	    if (str[0] == '<' || str[0] == '>') {
		op = str[0];
	    } else {
		ckfree((VOID *) listIndices);
		result = Tcl_NewStringObj("unknown comparison operator \"", -1);
		Tcl_AppendObjToObj(result, objv[arg_no]);
		Tcl_AppendToObj(result, "\"", -1);
		Tcl_SetObjResult(interp, result);
		return TCL_ERROR;
	    }
	} else {
	    if (str[1] != '=') {
		ckfree((VOID *) listIndices);
		result = Tcl_NewStringObj("unknown comparison operator \"", -1);
		Tcl_AppendObjToObj(result, objv[arg_no]);
		Tcl_AppendToObj(result, "\"", -1);
		Tcl_SetObjResult(interp, result);
		return TCL_ERROR;
	    }

	    if (str[0] == '<') {
		op = 'l';
	    } else if (str[0] == '>') {
		op = 'g';
	    } else if (str[0] == '=') {
		op = '=';
	    } else if (str[0] == '!') {
		op = '!';
	    } else {
		ckfree((VOID *) listIndices);
		result = Tcl_NewStringObj("unknown comparison operator \"", -1);
		Tcl_AppendObjToObj(result, objv[arg_no]);
		Tcl_AppendToObj(result, "\"", -1);
		Tcl_SetObjResult(interp, result);
		return TCL_ERROR;
	    }
	}
    } else if (l == 0 || l > 2) {
	TensorObjUsage(interp, Tcl_GetString(objv[0]));
	return (TCL_ERROR);
    } else if (l == 1) {
	str = Tcl_GetString(objv[arg_no]);
	switch (str[0]) {
	    case '=':
		op = 'c';
		opClass = TENSOR_OP_CLASS_OP;
		break;

	    case '<':
	    case '>':
		op = str[0];
		opClass = TENSOR_OP_CLASS_CMP;
		break;

	    default:
		TensorObjUsage(interp, Tcl_GetString(objv[0]));
		return (TCL_ERROR);
		/* NOTREACHED */
		break;
	}
    } else if (str[1] != '=') {
	TensorObjUsage(interp, Tcl_GetString(objv[0]));
	return (TCL_ERROR);
    } else {
	switch (str[0]) {
	    case '+':
	    case '-':
	    case '*':
	    case '/':
		op = str[0];
		opClass = TENSOR_OP_CLASS_OP;
		break;

	    case '<':
		op = 'l';
		opClass = TENSOR_OP_CLASS_CMP;
		break;

	    case '>':
		op = 'g';
		opClass = TENSOR_OP_CLASS_CMP;
		break;

	    case '=':
	    case '!':
		op = str[0];
		opClass = TENSOR_OP_CLASS_CMP;
		break;

	    default:
		TensorObjUsage(interp, Tcl_GetString(objv[0]));
		return (TCL_ERROR);
		/* NOTREACHED */
		break;

	}
    }
    arg_no++;

    if (objc - arg_no < 2) {
	if (listIndices != (int *) NULL) {
	    ckfree((VOID *) listIndices);
	}
	TensorObjUsage(interp, Tcl_GetString(objv[0]));
	return (TCL_ERROR);
    }

    /* Now determine what kind of operand we have; we'll handle scalars *
     * first. */

    if (!strcmp(Tcl_GetString(objv[arg_no]), "scalar")) {
	arg_no++;
	if (Tcl_GetDoubleFromObj(interp, objv[arg_no], &d) != TCL_OK) {
	    if (listIndices != (int *) NULL) {
		ckfree((VOID *) listIndices);
	    }
	    return (TCL_ERROR);
	}
	arg_no++;
	if (arg_no < objc) {
	    if (listIndices != (int *) NULL) {
		ckfree((VOID *) listIndices);
	    }
	    Tcl_SetObjResult(interp, Tcl_NewStringObj(
		 "\"scalar\" keyword should be followed by only one argument",
			  -1));
	    return (TCL_ERROR);
	}

	switch (opClass) {
	    case TENSOR_OP_CLASS_OP:
		return (TensorOpScalar(interp,
				tensor, low_indices, high_indices, op, d));
	    case TENSOR_OP_CLASS_CMP:
		return (TensorCmpScalar(interp,
				tensor, low_indices, high_indices, op, d));
	    case TENSOR_OP_CLASS_LSTI:
		err_code = TensorListIndicesScalar(interp,
				tensor, low_indices, high_indices,
				listIndices, nListIndices, op, d);
		ckfree((VOID *) listIndices);
		return err_code;
	}

	if (listIndices != (int *) NULL) {
	    ckfree((VOID *) listIndices);
	}
	Tcl_SetObjResult(interp, Tcl_NewStringObj(
		"Internal error: operation unknown", -1));
	return TCL_ERROR;
    }

    /* Now we handle all the others, which produce tensor operands. We'll */
    /* put the operand in "src_tensor", regardless of how it's produced.  */

    if (!strcmp(Tcl_GetString(objv[arg_no]), "array")) {
	arg_no++;
	if (arg_no >= objc) {
	    if (listIndices != (int *) NULL) {
		ckfree((VOID *) listIndices);
	    }
	    Tcl_SetObjResult(interp,
		Tcl_NewStringObj("missing array operand", -1));
	    return (TCL_ERROR);
	}
	if (objc - arg_no > 1) {
	    if (listIndices != (int *) NULL) {
		ckfree((VOID *) listIndices);
	    }
	    Tcl_SetObjResult(interp, Tcl_NewStringObj(
		"only a single argument must follow the \"array\" keyword", -1));
	    return (TCL_ERROR);
	}

	/* Get the array. */

	src_tensor.type = TENSOR_DOUBLE;
	if (TensorGet(interp, objv[arg_no],
			  &src_tensor) != TCL_OK) {
	    if (listIndices != (int *) NULL) {
		ckfree((VOID *) listIndices);
	    }
	    return (TCL_ERROR);
	}
    } else if (!strcmp(Tcl_GetString(objv[arg_no]), "tensor")) {
	Tensor_Index tmp_low_indices, tmp_high_indices;

	arg_no++;
	if (arg_no >= objc) {
	    if (listIndices != (int *) NULL) {
		ckfree((VOID *) listIndices);
	    }
	    Tcl_SetObjResult(interp,
		Tcl_NewStringObj("missing tensor operand", -1));
	    return (TCL_ERROR);
	}

	/* Get the tensor descriptor. */

	tmp_tensor = Tensor_Lookup(interp, Tcl_GetString(objv[arg_no]));
	if (tmp_tensor == (Tensor_Descrip *) NULL) {
	    if (listIndices != (int *) NULL) {
		ckfree((VOID *) listIndices);
	    }
	    result = Tcl_NewStringObj("No such tensor \"", -1);
	    Tcl_AppendObjToObj(result, objv[arg_no]);
	    Tcl_AppendToObj(result, "\"", -1);
	    Tcl_SetObjResult(interp, result);
	    return (TCL_ERROR);
	}

	/* Copy the tensor type. */

	src_tensor.type = tmp_tensor->type;

	/* Now see what section of the tensor we have to use. */

	arg_no++;
	if (arg_no >= objc) {
	    /* Use entire tensor. */

	    src_tensor.order = tmp_tensor->order;
	    for (i = 0; i < tmp_tensor->order; i++) {
		src_low_indices[i] = 0;
		src_high_indices[i] = tmp_tensor->dims[i] - 1;
		tmp_low_indices[i] = 0;
		tmp_high_indices[i] = tmp_tensor->dims[i] - 1;
		src_tensor.dims[i] = tmp_tensor->dims[i];
	    }
	} else {
	    /* Look for "section" directive. */

	    if (strcmp(Tcl_GetString(objv[arg_no]), "section")) {
		if (listIndices != (int *) NULL) {
		    ckfree((VOID *) listIndices);
		}
		Tcl_SetObjResult(interp, Tcl_NewStringObj(
		   "Only a \"section\" directive may follow a tensor operand",
			      -1));
		return (TCL_ERROR);
	    }
	    arg_no++;
	    if (arg_no >= objc) {
		if (listIndices != (int *) NULL) {
		    ckfree((VOID *) listIndices);
		}
		Tcl_SetObjResult(interp, Tcl_NewStringObj(
		       "No section description follows \"section\" directive",
			      -1));
		return (TCL_ERROR);
	    }

	    /* Get the appropriate section of the tensor. */

	    if (TensorGetSectionIndex(interp, objv[arg_no],
		     tmp_tensor, tmp_low_indices, tmp_high_indices) != TCL_OK) {
		if (listIndices != (int *) NULL) {
		    ckfree((VOID *) listIndices);
		}
		return (TCL_ERROR);
	    }

	    TensorSectionDims( tmp_tensor->order,
		    tmp_low_indices, tmp_high_indices,
		    &src_tensor.order, src_tensor.dims,index_map);

	    for (i = 0; i < src_tensor.order; i++) {
		src_low_indices[i] = 0;
		src_high_indices[i] = src_tensor.dims[i] - 1;
	    }
	}

	/* Allocate storage and do the copy. */

	if (Tensor_AllocData(interp, &src_tensor) != TCL_OK) {
	    if (listIndices != (int *) NULL) {
		ckfree((VOID *) listIndices);
	    }
	    return (TCL_ERROR);
	}

	if (TensorCopySection(interp, &src_tensor,
				  src_low_indices, src_high_indices,
		   tmp_tensor, tmp_low_indices, tmp_high_indices) != TCL_OK) {
	    if (listIndices != (int *) NULL) {
		ckfree((VOID *) listIndices);
	    }
	    Tensor_FreeData(&src_tensor);
	    return (TCL_ERROR);
	}
    } else if (!strcmp(Tcl_GetString(objv[arg_no]), "file")) {
	arg_no++;
	if (arg_no >= objc) {
	    if (listIndices != (int *) NULL) {
		ckfree((VOID *) listIndices);
	    }
	    Tcl_SetObjResult(interp,
			Tcl_NewStringObj("missing file name", -1));
	    return (TCL_ERROR);
	}
	if (objc - arg_no > 1) {
	    if (listIndices != (int *) NULL) {
		ckfree((VOID *) listIndices);
	    }
	    Tcl_SetObjResult(interp,
			Tcl_NewStringObj("Only one file name allowed", -1));
	    return (TCL_ERROR);
	}

	/* Open the file. */

	chan = Tcl_FSOpenFileChannel(interp, objv[arg_no], "r", 0777);
	if (chan == (Tcl_Channel) NULL) {
		if (listIndices != (int *) NULL) {
		    ckfree((VOID *) listIndices);
		}
		result = Tcl_NewStringObj("Could not read file \"", -1);
		Tcl_AppendObjToObj(result, objv[arg_no]);
		Tcl_AppendToObj(result, "\"", -1);
		Tcl_SetObjResult(interp, result);
		return (TCL_ERROR);
	}

	/* Read the tensor. */

	err_code = TensorRead(interp, &src_tensor, chan);

	Tcl_Close(interp, chan);

	if (err_code != TCL_OK) {
	    if (listIndices != (int *) NULL) {
		ckfree((VOID *) listIndices);
	    }
	    return (TCL_ERROR);
	}

    } else if (!strcmp(Tcl_GetString(objv[arg_no]), "channel")) {
	arg_no++;
	if (arg_no >= objc) {
	    if (listIndices != (int *) NULL) {
		ckfree((VOID *) listIndices);
	    }
	    Tcl_SetObjResult(interp, Tcl_NewStringObj("missing file name", -1));
	    return (TCL_ERROR);
	}
	if (objc - arg_no > 1) {
	    if (listIndices != (int *) NULL) {
		ckfree((VOID *) listIndices);
	    }
	    Tcl_SetObjResult(interp,
			Tcl_NewStringObj("Only one file name allowed", -1));
	    return (TCL_ERROR);
	}

	/* Open the file. */

	chan = Tcl_GetChannel(interp, Tcl_GetString(objv[arg_no]), &chanMode);
	if(chan == (Tcl_Channel) NULL) {
	    if (listIndices != (int *) NULL) {
		ckfree((VOID *) listIndices);
	    }
	    result = Tcl_NewStringObj("Channel \"", -1);
	    Tcl_AppendObjToObj(result, objv[arg_no]);
	    Tcl_AppendToObj(result, "\" is not open", -1);
	    Tcl_SetObjResult(interp, result);
	    return (TCL_ERROR);
	}

	if(!(chanMode & TCL_READABLE)) {
	    if (listIndices != (int *) NULL) {
		ckfree((VOID *) listIndices);
	    }
	    result = Tcl_NewStringObj("Channel \"", -1);
	    Tcl_AppendObjToObj(result, objv[arg_no]);
	    Tcl_AppendToObj(result, "\" is not readable", -1);
	    Tcl_SetObjResult(interp, result);
	    return (TCL_ERROR);
	}

	/* Read the tensor. */

	err_code = TensorRead(interp, &src_tensor, chan);
	if (err_code != TCL_OK) {
	    if (listIndices != (int *) NULL) {
		ckfree((VOID *) listIndices);
	    }
	    return (TCL_ERROR);
	}
    } else if (!strcmp(Tcl_GetString(objv[arg_no]), "contraction")) {
	arg_no++;
	if (objc - arg_no != 2) {
	    if (listIndices != (int *) NULL) {
		ckfree((VOID *) listIndices);
	    }
	    Tcl_SetObjResult(interp, Tcl_NewStringObj(
			  "\"contraction\" keyword must be followed by a tensor name and a list of indices", -1));
	    return (TCL_ERROR);
	}
	/* Get the operand tensor. */

	tmp_tensor = Tensor_Lookup(interp, Tcl_GetString(objv[arg_no]));
	if (tmp_tensor == (Tensor_Descrip *) NULL) {
	    if (listIndices != (int *) NULL) {
		ckfree((VOID *) listIndices);
	    }
	    result = Tcl_NewStringObj("No such tensor \"", -1);
	    Tcl_AppendObjToObj(result, objv[arg_no]);
	    Tcl_AppendToObj(result, "\"", -1);
	    Tcl_SetObjResult(interp, result);
	    return (TCL_ERROR);
	}

	/* Get the list of indices. */

	arg_no++;
	if (Tcl_ListObjGetElements(interp,
			  objv[arg_no], &llength, &objPtrPtr) != TCL_OK) {
	    if (listIndices != (int *) NULL) {
		ckfree((VOID *) listIndices);
	    }
	    return (TCL_ERROR);
	}

	if (llength <= 0) {
	    if (listIndices != (int *) NULL) {
		ckfree((VOID *) listIndices);
	    }
	    Tcl_SetObjResult(interp,
			Tcl_NewStringObj("Empty index list", -1));
	    return (TCL_ERROR);
	}
	if (llength > tmp_tensor->order) {
	    if (listIndices != (int *) NULL) {
		ckfree((VOID *) listIndices);
	    }
	    Tcl_SetObjResult(interp, Tcl_NewStringObj(
	        "Length of index list is greater than tensor order", -1));
	    return (TCL_ERROR);
	}
	for (i = 0; i < llength; i++) {
	    /* Get the index. */

	    if (Tcl_GetIntFromObj(interp, objPtrPtr[i], &(idx_list[i])) != TCL_OK) {
		if (listIndices != (int *) NULL) {
		    ckfree((VOID *) listIndices);
		}
		return (TCL_ERROR);
	    }
	}

	if (TensorContract(interp, tmp_tensor,
			       llength, idx_list, &src_tensor) != TCL_OK) {
	    if (listIndices != (int *) NULL) {
		ckfree((VOID *) listIndices);
	    }
	    return (TCL_ERROR);
	}

    } else if (! strcmp (Tcl_GetString (objv[arg_no]), "multensor")) {

      //-----------------------------------------------------------------

      arg_no++;

      if (objc - arg_no != 3) {
        if (listIndices != (int *) NULL) {
          ckfree((VOID *) listIndices);
        }
        Tcl_SetObjResult(interp, Tcl_NewStringObj(
                                                  "multensor operation must be followed by two tensor operands and a pair of indices",
			  -1));
        return (TCL_ERROR);
      }

      /* Get the two operand tensors. */
      
      for (i = 0; i < 2; i++) {
        tensor_pt[i] = Tensor_Lookup(interp, Tcl_GetString(objv[arg_no + i]));
        if (tensor_pt[i] == (Tensor_Descrip *) NULL) {
          if (listIndices != (int *) NULL) {
            ckfree((VOID *) listIndices);
          }
          result = Tcl_NewStringObj("No such tensor \"", -1);
          Tcl_AppendObjToObj(result, objv[arg_no + i]);
          Tcl_AppendToObj(result, "\"", -1);
          Tcl_SetObjResult(interp, result);
          return (TCL_ERROR);
        }
      }
      
      arg_no += 2;
      
      /* Get the index pair for multiplication and summation. */
      
      if (Tcl_ListObjGetElements(interp,
                                 objv[arg_no], &llength, &objPtrPtr) != TCL_OK) {
        if (listIndices != (int *) NULL) {
          ckfree((VOID *) listIndices);
        }
        return (TCL_ERROR);
      }
      if (llength != 2) {
        if (listIndices != (int *) NULL) {
          ckfree((VOID *) listIndices);
        }
        Tcl_SetObjResult(interp, Tcl_NewStringObj(
                                                  "tensors must be followed by a pair of indices", -1));
        return (TCL_ERROR);
      }
      for (i = 0; i < 2; i++) {
        if (Tcl_GetIntFromObj(interp, objPtrPtr[i], &(idx_list[i])) != TCL_OK) {
          if (listIndices != (int *) NULL) {
            ckfree((VOID *) listIndices);
          }
          return (TCL_ERROR);
        }
      }
      

      if (TensorMultiply (interp,
                          tensor_pt, idx_list, &src_tensor) != TCL_OK) {

        if (listIndices != (int *) NULL) {
          ckfree((VOID *) listIndices);
        }
        return (TCL_ERROR);
      }
      
      //-----------------------------------------------------------------
      
    } else if (!strcmp(Tcl_GetString(objv[arg_no]), "outer")) {
      arg_no++;
      if (objc - arg_no != 2) {
        if (listIndices != (int *) NULL) {
          ckfree((VOID *) listIndices);
        }
	    Tcl_SetObjResult(interp, Tcl_NewStringObj(
	    "outer product operation must be followed by two tensor operands",
			  -1));
	    return (TCL_ERROR);
	}

	/* Get the two operand tensors. */

	for (i = 0; i < 2; i++) {
	    tensor_pt[i] = Tensor_Lookup(interp, Tcl_GetString(objv[arg_no + i]));
	    if (tensor_pt[i] == (Tensor_Descrip *) NULL) {
		if (listIndices != (int *) NULL) {
		    ckfree((VOID *) listIndices);
		}
		result = Tcl_NewStringObj("No such tensor \"", -1);
		Tcl_AppendObjToObj(result, objv[arg_no + i]);
		Tcl_AppendToObj(result, "\"", -1);
		Tcl_SetObjResult(interp, result);
		return (TCL_ERROR);
	    }
	}

	arg_no += 2;

	if (TensorOuterProduct(interp, tensor_pt,
			    &src_tensor) != TCL_OK) {
	    if (listIndices != (int *) NULL) {
		ckfree((VOID *) listIndices);
	    }
	    return (TCL_ERROR);
	}
    } else if (!strcmp(Tcl_GetString(objv[arg_no]), "boolean")) {
	/* Check the arg. list. */

	arg_no++;
	if (objc - arg_no < 4) {
	    if (listIndices != (int *) NULL) {
		ckfree((VOID *) listIndices);
	    }
	    Tcl_SetObjResult(interp, Tcl_NewStringObj(
		    "\"boolean\" clause syntax is \"boolean <tensor> ?<section>? <comparisonOp> <operand>\"", -1));
	    return (TCL_ERROR);
	}

	/* Get the first operand tensor. */

	boolOp1Ptr = Tensor_Lookup(interp, Tcl_GetString(objv[arg_no]));
	if (boolOp1Ptr == (Tensor_Descrip *) NULL) {
	    if (listIndices != (int *) NULL) {
		ckfree((VOID *) listIndices);
	    }
	    result = Tcl_NewStringObj("No such tensor \"", -1);
	    Tcl_AppendObjToObj(result, objv[arg_no]);
	    Tcl_AppendToObj(result, "\"", -1);
	    Tcl_SetObjResult(interp, result);
	    return (TCL_ERROR);
	}
	arg_no++;

	/* Get the optional tensor section. */

	for (i = 0; i < boolOp1Ptr->order; i++) {
	    op1_low_indices[i] = 0;
	    op1_high_indices[i] = boolOp1Ptr->dims[i] - 1;
	}

	if (arg_no < objc && !strcmp(Tcl_GetString(objv[arg_no]), "section")) {
	    arg_no++;
	    if (arg_no >= objc) {
		if (listIndices != (int *) NULL) {
		    ckfree((VOID *) listIndices);
		}
		Tcl_SetObjResult(interp, Tcl_NewStringObj(
			"\"section\" must be followed by a tensor cross-section",
			-1));
		return (TCL_ERROR);
	    }
	    if (TensorGetSectionIndex(interp, objv[arg_no],
				 boolOp1Ptr, op1_low_indices, op1_high_indices) != TCL_OK) {
		if (listIndices != (int *) NULL) {
		    ckfree((VOID *) listIndices);
		}
		return (TCL_ERROR);
	    }
	    arg_no++;
	}

	/* Get the comparison operator. */

	str = Tcl_GetString(objv[arg_no]);
	l = strlen(str);
	if (l == 0 || l > 2) {
	    if (listIndices != (int *) NULL) {
		ckfree((VOID *) listIndices);
	    }
	    TensorObjUsage(interp, Tcl_GetString(objv[0]));
	    return (TCL_ERROR);
	}

	if (l == 1) {
	    switch (str[0]) {
		case '<':
		case '>':
		    bool_op = str[0];
		    break;

		default:
		    if (listIndices != (int *) NULL) {
			ckfree((VOID *) listIndices);
		    }
		    TensorObjUsage(interp, Tcl_GetString(objv[0]));
		    return (TCL_ERROR);
		    /* NOTREACHED */
		    break;
	    }
	} else if (str[1] != '=') {
	    if (listIndices != (int *) NULL) {
		ckfree((VOID *) listIndices);
	    }
	    TensorObjUsage(interp, Tcl_GetString(objv[0]));
	    return (TCL_ERROR);
	} else {
	    switch (str[0]) {
		case '<':
		    bool_op = 'l';
		    break;

		case '>':
		    bool_op = 'g';
		    break;

		case '=':
		case '!':
		    bool_op = str[0];
		    break;

		default:
		    if (listIndices != (int *) NULL) {
			ckfree((VOID *) listIndices);
		    }
		    TensorObjUsage(interp, Tcl_GetString(objv[0]));
		    return (TCL_ERROR);
		    /* NOTREACHED */
		    break;

	    }
        }
        arg_no++;

	/* Get the second operand, and generate the source tensor. */

	if (arg_no >= objc) {
	    if (listIndices != (int *) NULL) {
		ckfree((VOID *) listIndices);
	    }
	    Tcl_SetObjResult(interp, Tcl_NewStringObj(
		    "comparison operator must be followed by \"scalar\" or \"tensor\"",
		    -1));
	    return (TCL_ERROR);
	}

	if (!strcmp(Tcl_GetString(objv[arg_no]), "scalar")) {
	    /* Second operand's a scalar; it should be followed by a single number. */

	    arg_no++;
	    if (objc - arg_no != 1) {
		if (listIndices != (int *) NULL) {
		    ckfree((VOID *) listIndices);
		}
		Tcl_SetObjResult(interp, Tcl_NewStringObj(
			"\"scalar\" must be followed by a single number", -1));
		return(TCL_ERROR);
	    }

	    if(Tcl_GetDoubleFromObj(interp, objv[arg_no], &comp_no) != TCL_OK) {
		if (listIndices != (int *) NULL) {
		    ckfree((VOID *) listIndices);
		}
		return(TCL_ERROR);
	    }

	    if(TensorBoolScalar(interp, boolOp1Ptr, op1_low_indices,
		    op1_high_indices, bool_op, comp_no, &src_tensor) != TCL_OK) {
		if (listIndices != (int *) NULL) {
		    ckfree((VOID *) listIndices);
		}
		return(TCL_ERROR);
	    }
	} else if (!strcmp(Tcl_GetString(objv[arg_no]), "tensor")) {
	    /* Second operand's a tensor; get it. */

	    arg_no++;
	    if (objc - arg_no < 1) {
		if (listIndices != (int *) NULL) {
		    ckfree((VOID *) listIndices);
		}
		Tcl_SetObjResult(interp, Tcl_NewStringObj(
			"\"tensor\" must be followed by a tensor name", -1));
		return(TCL_ERROR);
	    }

	    boolOp2Ptr = Tensor_Lookup(interp, Tcl_GetString(objv[arg_no]));
	    if(boolOp2Ptr == (Tensor_Descrip *) NULL) {
		if (listIndices != (int *) NULL) {
		    ckfree((VOID *) listIndices);
		}
		result = Tcl_NewStringObj("\"", -1);
		Tcl_AppendObjToObj(result, objv[arg_no]);
		Tcl_AppendToObj(result, "\" is not a tensor", -1);
		Tcl_SetObjResult(interp, result);
		return(TCL_ERROR);
	    }
	    arg_no++;

	    /* Get the optional tensor section. */

	    for (i = 0; i < boolOp2Ptr->order; i++) {
		op2_low_indices[i] = 0;
		op2_high_indices[i] = boolOp2Ptr->dims[i] - 1;
	    }

	    if (arg_no < objc && !strcmp(Tcl_GetString(objv[arg_no]), "section")) {
		arg_no++;
		if (arg_no >= objc) {
		    if (listIndices != (int *) NULL) {
			ckfree((VOID *) listIndices);
		    }
		    Tcl_SetObjResult(interp, Tcl_NewStringObj(
			    "\"section\" must be followed by a tensor cross-section",
					-1));
		    return (TCL_ERROR);
		}
		if (TensorGetSectionIndex(interp, objv[arg_no],
			    boolOp2Ptr, op2_low_indices, op2_high_indices) != TCL_OK) {
		    if (listIndices != (int *) NULL) {
			ckfree((VOID *) listIndices);
		    }
		    return (TCL_ERROR);
		}
		arg_no++;
	    }

	    if (objc > arg_no) {
		if (listIndices != (int *) NULL) {
		    ckfree((VOID *) listIndices);
		}
		Tcl_SetObjResult(interp, Tcl_NewStringObj(
			"Extraneous arguments after tensor", -1));
		return(TCL_ERROR);
	    }

	    /* Do it... */

	    if(TensorBoolTensor(interp, boolOp1Ptr, op1_low_indices,
		    op1_high_indices, boolOp2Ptr, op2_low_indices,
		    op2_high_indices, bool_op, &src_tensor) != TCL_OK) {
		if (listIndices != (int *) NULL) {
		    ckfree((VOID *) listIndices);
		}
		return(TCL_ERROR);
	    }
	} else {
	    if (listIndices != (int *) NULL) {
		ckfree((VOID *) listIndices);
	    }
	    Tcl_SetObjResult(interp, Tcl_NewStringObj(
		    "comparison operator must be followed by \"scalar\" or \"tensor\"",
				-1));
	    return (TCL_ERROR);
	}

    } else {
	if (listIndices != (int *) NULL) {
	    ckfree((VOID *) listIndices);
	}
	result = Tcl_NewStringObj("Unknown tensor operand type \"", -1);
	Tcl_AppendObjToObj(result, objv[arg_no]);
	Tcl_AppendToObj(result, "\"", -1);
	Tcl_SetObjResult(interp, result);
	return (TCL_ERROR);
    }

    /* Set the size of the source operand section. */

    for (i = 0; i < src_tensor.order; i++) {
	src_low_indices[i] = 0;
	src_high_indices[i] = src_tensor.dims[i] - 1;
    }

    /* Perform the operation or comparison. */

    switch (opClass) {
	case TENSOR_OP_CLASS_OP:
		err_code = TensorOpTensor(interp,
				tensor, low_indices, high_indices, op,
				&src_tensor, src_low_indices, src_high_indices);
		break;
 	case TENSOR_OP_CLASS_CMP:
		err_code = TensorCmpTensor(interp,
				tensor, low_indices, high_indices, op,
				&src_tensor, src_low_indices, src_high_indices);
		break;
	case TENSOR_OP_CLASS_LSTI:
		err_code = TensorListIndicesTensor(interp,
				tensor, low_indices, high_indices,
				listIndices, nListIndices, op,
				&src_tensor, src_low_indices, src_high_indices);
		break;
	default:
		err_code = TCL_ERROR;
		fprintf(stderr, "Unknown operator class\n");
		exit(1);
		break;
    }

    /* Clean up and exit. */

    if (listIndices != (int *) NULL) {
	ckfree((VOID *) listIndices);
    }
    Tensor_FreeData(&src_tensor);
    return (err_code);
}
//------------------------------------------------------------------------------


/*
 *---------------------------------------------------------------
 *
 * TensorCmdUsage --
 *
 *      writes the usage message for the "tensor" command.
 *
 * Results:
 *      None.
 *
 * Side effects:
 *      Sets the interpreter's result string.
 *
 *---------------------------------------------------------------
 */


static void 
TensorCmdUsage(Tcl_Interp *interp, char *cmdName)

{
    Tcl_Obj *result;

    result = Tcl_NewStringObj("usage: \n\t", -1);
    Tcl_AppendToObj(result, cmdName, -1);
    Tcl_AppendToObj(result, " tensorname ?opts?", -1);
    Tcl_AppendToObj(result, "\nwhere legal options are:\n", -1);
    Tcl_AppendToObj(result, "\t-type tensor_type\n", -1);
    Tcl_AppendToObj(result, "\t-size <vector>\n", -1);
    Tcl_AppendToObj(result, "\t-initial <init_value_matrix>\n", -1);
    Tcl_AppendToObj(result, "\t-initfile <file_name>\n", -1);
    Tcl_AppendToObj(result,
	"You must use exactly one -size, -initial, or -initfile option", -1);

    Tcl_SetObjResult(interp, result);
}


/*
 *---------------------------------------------------------------
 *
 * DeleteTensor --
 *
 *      deletes a tensor corresponding to a particular tensor
 *	descriptor pointer.
 *
 * Results:
 *      None.
 *
 * Side effects:
 *      Frees the tensor's storage.
 *
 *---------------------------------------------------------------
 */


static void 
DeleteTensor(ClientData clientData)

{
    FreeTensor((Tensor_Descrip *) clientData);
}



/*
 *---------------------------------------------------------------
 *
 * Tensor_Register --
 *
 *      registers a pointer to Tensor_Descrip in the tensor
 *	lookup table, and creates the tensor's object
 *	command.
 *
 * Results:
 *      None.
 *
 * Side effects:
 *      A command is added, and an entry is made in the
 *	tensor lookup table.
 *
 *---------------------------------------------------------------
 */


void 
Tensor_Register(Tcl_Interp *interp, Tensor_Descrip *tensor, char *name)	
{
    /* Create the tensor object command. */

    Tcl_CreateObjCommand(interp, name, TensorObjCmd,
			    (ClientData) tensor, DeleteTensor);
}


/* This is for translating a tensor type string	*/
/* into its internal form.			*/

static char *tensor_type_trans[] = {
    "double",
    "float",
    "int",
    "byte",
    "short",
    "unsigned",
    NULL
};


/*
 *---------------------------------------------------------------
 *
 * TensorCmd --
 *
 *      code to implement the "tensor" command.
 *
 * Results:
 *      returns a standard TCL result.
 *
 * Side effects:
 *      A tensor and its associated object command are created.
 *
 *---------------------------------------------------------------
 */


/*ARGSUSED */
static int 
TensorCmd(ClientData clientData, Tcl_Interp *interp,
				int objc, Tcl_Obj *CONST objv[])
{
    Tcl_CmdInfo infoStruct;
    Tensor_Descrip *tensor;
    Tcl_Obj *init_array;
    Tcl_Obj *init_file_name;
    char *init_channel_name;
    int i, arg_no;
    int size_set;
    Tcl_Channel chan;
    int chanMode;
    int err_code, retcode;
    Tcl_Obj *result;

    /* Make sure we have enough args. */

    if (objc < 4) {
	TensorCmdUsage(interp, Tcl_GetString(objv[0]));
	return (TCL_ERROR);
    }

    /* Don't clobber existing commands or existing tensors. */

    if (Tensor_Lookup(interp, Tcl_GetString(objv[1]))
				!= (Tensor_Descrip *) NULL) {
	result = Tcl_NewStringObj("A tensor named \"", -1);
	Tcl_AppendObjToObj(result, objv[1]);
	Tcl_AppendToObj(result, "\" already exists", -1);
	Tcl_SetObjResult(interp, result);
	return (TCL_ERROR);
    }

    if (Tcl_GetCommandInfo(interp, Tcl_GetString(objv[1]), &infoStruct)) {
	result = Tcl_NewStringObj("A command named \"", -1);
	Tcl_AppendObjToObj(result, objv[1]);
	Tcl_AppendToObj(result, "\" already exists", -1);
	Tcl_SetObjResult(interp, result);
	return (TCL_ERROR);
    }

    /* Make a new tensor. */

    tensor = (Tensor_Descrip *) ckalloc(sizeof(Tensor_Descrip));
    if (tensor == (Tensor_Descrip *) NULL) {
	Tcl_SetObjResult(interp,
		Tcl_NewStringObj("Out of storage", -1));
	return (TCL_ERROR);
    }
    tensor->order = -1;
    tensor->data = (VOID *) NULL;

    /* Set the defaults. */

    tensor->type = DEF_TENSOR_TYPE;
    init_array = (Tcl_Obj *) NULL;
    init_file_name = (Tcl_Obj *) NULL;
    init_channel_name = (char *) NULL;
    size_set = 0;

    /* Parse the options. */

    for (arg_no = 2; arg_no < objc; arg_no++) {
	if (!strcmp(Tcl_GetString(objv[arg_no]), "-type")) {
	    arg_no++;
	    if (arg_no >= objc) {
		FreeTensor(tensor);
		result = Tcl_NewStringObj(
				"-type must be followed by one of:\n", -1);
		for (i = 0; tensor_type_trans[i] != NULL; i++) {
		    Tcl_AppendToObj(result, "\t", -1);
		    Tcl_AppendToObj(result, tensor_type_trans[i], -1);
		    Tcl_AppendToObj(result, "\n", -1);
		}
		Tcl_SetObjResult(interp, result);
		return (TCL_ERROR);
	    }
	    retcode = Tcl_GetIndexFromObj(interp, objv[arg_no],
			tensor_type_trans, "Unknown tensor type",
					TCL_EXACT, &(tensor->type));
	    if (retcode != TCL_OK) {
		FreeTensor(tensor);
		return (TCL_ERROR);
	    }
	} else if (!strcmp(Tcl_GetString(objv[arg_no]), "-size")) {
	    if (size_set) {
		FreeTensor(tensor);
		Tcl_SetObjResult(interp, Tcl_NewStringObj(
			      "only one of -size, -initial, -initfile, and -initchannel may be used in a single tensor command", -1));
		return (TCL_ERROR);
	    }
	    arg_no++;
	    if (arg_no >= objc) {
		FreeTensor(tensor);
		Tcl_SetObjResult(interp, Tcl_NewStringObj(
		    "-size must be followed by an array of numbers", -1));
		return (TCL_ERROR);
	    }
	    if (tensor->order >= 0) {
		FreeTensor(tensor);
		Tcl_SetObjResult(interp, Tcl_NewStringObj(
			"illegal -size option: tensor size is already known.",
			      -1));
		return (TCL_ERROR);
	    } else if (TensorGetDims(interp, objv[arg_no],
				  &(tensor->order), tensor->dims) != TCL_OK) {
		FreeTensor(tensor);
		return (TCL_ERROR);
	    }
	    size_set = 1;
	} else if (!strcmp(Tcl_GetString(objv[arg_no]), "-initial")) {
	    if (size_set) {
		FreeTensor(tensor);
		Tcl_SetObjResult(interp, Tcl_NewStringObj(
			      "only one of -size, -initial, -initfile, and -initchannel may be used in a single tensor command", -1));
		return (TCL_ERROR);
	    }
	    arg_no++;
	    if (arg_no >= objc) {
		FreeTensor(tensor);
		Tcl_SetObjResult(interp, Tcl_NewStringObj(
		    "-initial must be followed by an array of numbers", -1));
		return (TCL_ERROR);
	    }
	    init_array = objv[arg_no];
	    size_set = 1;
	} else if (!strcmp(Tcl_GetString(objv[arg_no]), "-initfile")) {
	    if (size_set) {
		FreeTensor(tensor);
		Tcl_SetObjResult(interp, Tcl_NewStringObj(
			      "only one of -size, -initial, -initfile, and -initchannel may be used in a single tensor command", -1));
		return (TCL_ERROR);
	    }
	    arg_no++;
	    if (arg_no >= objc) {
		FreeTensor(tensor);
		Tcl_SetObjResult(interp, Tcl_NewStringObj(
		     "-initfile must be followed by a file name", -1));
		return (TCL_ERROR);
	    }
	    init_file_name = objv[arg_no];
	    size_set = 1;
	} else if (!strcmp(Tcl_GetString(objv[arg_no]), "-initchannel")) {
	    if (size_set) {
		FreeTensor(tensor);
		Tcl_SetObjResult(interp, Tcl_NewStringObj(
			      "only one of -size, -initial, -initfile, and -initchannel may be used in a single tensor command", -1));
		return (TCL_ERROR);
	    }
	    arg_no++;
	    if (arg_no >= objc) {
		FreeTensor(tensor);
		Tcl_SetObjResult(interp, Tcl_NewStringObj(
		     "-initchannel must be followed by a channel name", -1));
		return (TCL_ERROR);
	    }
	    init_channel_name = Tcl_GetString(objv[arg_no]);
	    size_set = 1;
	} else {
	    FreeTensor(tensor);
	    result = Tcl_NewStringObj("Unknown option \"", -1);
	    Tcl_AppendObjToObj(result, objv[arg_no]);
	    Tcl_AppendToObj(result, "\"", -1);
	    Tcl_SetObjResult(interp, result);
	    return (TCL_ERROR);
	}
    }

    if (!size_set) {
	FreeTensor(tensor);
	Tcl_SetObjResult(interp, Tcl_NewStringObj(
			      "tensor command must have exactly one -size, -initial, -initfile, or -initchannel option", -1));
	return (TCL_ERROR);
    }

    /* Allocate data storage, if necessary. */

    if (tensor->order >= 0) {
	if (Tensor_AllocData(interp, tensor) != TCL_OK) {
	    FreeTensor(tensor);
	    return (TCL_ERROR);
	}
    } else if (init_array != NULL) {
	if (TensorGet(interp, init_array, tensor) != TCL_OK) {
	    FreeTensor(tensor);
	    return (TCL_ERROR);
	}
    } else if (init_file_name != NULL) {
	/* Open the file. */

	chan = Tcl_FSOpenFileChannel(interp, init_file_name, "r", 0700);
	if (chan == (Tcl_Channel) NULL) {
		FreeTensor(tensor);
		result = Tcl_NewStringObj("Could not read file \"", -1);
		Tcl_AppendObjToObj(result, init_file_name);
		Tcl_AppendToObj(result, "\"", -1);
		Tcl_SetObjResult(interp, result);
		return (TCL_ERROR);
	}

	/* Read the tensor. */

	err_code = TensorRead(interp, tensor, chan);
	Tcl_Close(interp, chan);

	if (err_code != TCL_OK) {
	    FreeTensor(tensor);
	    return (TCL_ERROR);
	}
    } else if (init_channel_name != NULL) {
	chan = Tcl_GetChannel(interp, init_channel_name, &chanMode);
	if(chan == (Tcl_Channel) NULL) {
		FreeTensor(tensor);
		result = Tcl_NewStringObj("\"", -1);
		Tcl_AppendObjToObj(result, init_file_name);
		Tcl_AppendToObj(result,
			"\" is not an open I/O channel", -1);
		Tcl_SetObjResult(interp, result);
		return (TCL_ERROR);
	}
	if(!(chanMode & TCL_READABLE)){
		FreeTensor(tensor);
		result = Tcl_NewStringObj("channel \"", -1);
		Tcl_AppendToObj(result, init_channel_name, -1);
		Tcl_AppendToObj(result, "\" is not open for reading", -1);
		Tcl_SetObjResult(interp, result);
		return (TCL_ERROR);
	}

	/* Read the tensor. */

	err_code = TensorRead(interp, tensor, chan);

	if (err_code != TCL_OK) {
	    FreeTensor(tensor);
	    return (TCL_ERROR);
	}
    } else {
	fprintf(stderr, "No size for tensor! This shouldn't happen!\n");
	exit(1);
    }

    /* Register the tensor name and pointer. */

    Tensor_Register(interp, tensor, Tcl_GetString(objv[1]));

    return (TCL_OK);
}

/*
 *---------------------------------------------------------------
 *
 * IsTensorCmd --
 *
 *      code to implement the "is_tensor" command.
 *
 * Results:
 *      returns a standard TCL result.
 *
 * Side effects:
 *      None.
 *
 *---------------------------------------------------------------
 */


/*ARGSUSED */
static int 
IsTensorCmd(ClientData clientData, Tcl_Interp *interp,
				int objc, Tcl_Obj *CONST objv[])
{
    Tcl_Obj *result;

    /* Check args. */

    if (objc != 2) {
	result = Tcl_NewStringObj("Usage:\n\t", -1);
	Tcl_AppendObjToObj(result, objv[0]);
	Tcl_AppendToObj(result, " cmdName", -1);
	Tcl_SetObjResult(interp, result);
	return (TCL_ERROR);
    }

    /*
     * Return 0 if the command doesn't exist, or if
     * it's not a tensor object command.
     */

    if(Tensor_Lookup(interp,Tcl_GetString(objv[1]))
				== (Tensor_Descrip *) NULL) {
	Tcl_SetObjResult(interp,Tcl_NewBooleanObj(0));
    } else {
	Tcl_SetObjResult(interp,Tcl_NewBooleanObj(1));
    }

    return (TCL_OK);
}

/*
 *---------------------------------------------------------------
 *
 * Tensor_Init --
 *
 *      initializes the tensor package.
 *
 * Results:
 *      returns a standard TCL result.
 *
 * Side effects:
 *      Creates the "tensor::create" and "tensor::exists"
 *	commands, and provides the "tensor" package.
 *
 *---------------------------------------------------------------
 */

int 
Tensornew_Init(Tcl_Interp *interp)
{
#ifdef USE_TCL_STUBS
    if(Tcl_InitStubs(interp, "8", 0) == NULL) {
	return TCL_ERROR;
    }
#endif

    Tcl_CreateObjCommand(interp, "tensor::create", TensorCmd,
		 (ClientData) NULL, (void (*)_ANSI_ARGS_((ClientData))) NULL);
    Tcl_CreateObjCommand(interp, "tensor::exists", IsTensorCmd,
		 (ClientData) NULL, (void (*)_ANSI_ARGS_((ClientData))) NULL);
    Tcl_CreateObjCommand(interp, "tensor::expr", TensorExprCmd,
		 (ClientData) NULL, (void (*)_ANSI_ARGS_((ClientData))) NULL);

    Tcl_PkgProvide(interp, "TensorNew", TENSOR_VERSION);

    return (TCL_OK);
}
