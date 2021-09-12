/*
 * tensorConv.c --
 *
 *      Utilities for converting various text structures
 *      into a corresponding internal form: TCL lists
 *      to arrays of numbers, etc.
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
static char rcsid[] = "$Header: /home/neil/src/tcl/tensor/generic/RCS/tensorConv.c,v 1.8 2008/05/31 18:42:34 neil Exp $";
#endif

#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include <string.h>
#include "tcl.h"
#include "tensorInt.h"

/*
 *---------------------------------------------------------------
 *
 * GetDimsOfArray --
 *
 *      determines the number of dimensions and the size of a
 *	tensor, when the tensor is represented as a nested
 *	TCL list; returns the number of dimensions, and the
 *	extent in each dimension.
 *
 * Results:
 *      The function returns the tensor order in *orderPtr,
 *	and returns the tensor dimensions in dims. The return
 *	value is a standard TCL result.
 *
 * Side effects:
 *      None.
 *
 *---------------------------------------------------------------
 */

static int 
GetDimsOfArray(
    Tcl_Interp *interp,	/* Interpreter, for errors	*/
    Tcl_Obj *obj,	/* Tcl_Obj to convert		*/
    int *orderPtr,	/* Pointer to tensor order	*/
    Tensor_Index dims)	/* Array of dimensions		*/
{
    int n, ord;
    double d;
    Tcl_Obj *objPtr1, **objPtrPtr2;

    ord = 0;
    objPtr1 = obj;

    for(;;) {
	if(ord >= TENSOR_MAX_ORDER) {
	    Tcl_SetObjResult(interp, Tcl_NewStringObj(
		    "Maximum tensor order exceeded", -1));
	    return(TCL_ERROR);
	}

	if(Tcl_ListObjLength(interp, objPtr1, &n) != TCL_OK) {
	    return(TCL_ERROR);
	}

	if(n == 0) {
	    dims[ord] = 0;
	    *orderPtr = ord;
	    return(TCL_OK);
	}

	if (Tcl_ListObjGetElements(interp, objPtr1, &n, &objPtrPtr2) != TCL_OK) {
	    return (TCL_ERROR);
	}

	if(n == 1 && Tcl_GetDoubleFromObj(interp,objPtrPtr2[0], &d) != TCL_ERROR) {
	    *orderPtr = ord;
	    return(TCL_OK);
	}

	objPtr1 = objPtrPtr2[0];
	objPtrPtr2 = (Tcl_Obj **) NULL;

	dims[ord] = n;
	ord++;
    }
}


/*
 *---------------------------------------------------------------
 *
 * TensorGetDims --
 *
 *      Interprets a Tcl_Obj as a one-dimensional array of tensor
 *	dimensions; returns the number of dimensions, and the
 *	extent in each dimension.
 *
 * Results:
 *      The function returns the tensor order in *orderPtr,
 *	and returns the tensor dimensions in dims. The return
 *	value is a standard TCL result.
 *
 * Side effects:
 *      None.
 *
 *---------------------------------------------------------------
 */

int 
TensorGetDims(
    Tcl_Interp *interp,		/* Interpreter, for errors	*/
    Tcl_Obj *listPtr,		/* Tcl_Obj to convert		*/
    int *orderPtr,		/* Pointer to tensor order	*/
    Tensor_Index indices)	/* Array of dimensions		*/
{
    int i;
    Tcl_Obj **dimArray;

    if (Tcl_ListObjGetElements(interp, listPtr, orderPtr, &dimArray) != TCL_OK) {
	return (TCL_ERROR);
    }

    if (*orderPtr > TENSOR_MAX_ORDER) {
	Tcl_SetObjResult(interp,
		Tcl_NewStringObj("too many tensor indices", -1));
	return (TCL_ERROR);
    }
    for (i = 0; i < *orderPtr; i++) {
	if (Tcl_GetIntFromObj(interp, dimArray[i], &(indices[i])) != TCL_OK) {
	    return (TCL_ERROR);
	}
	if (indices[i] < 0) {
	    Tcl_SetObjResult(interp, Tcl_NewStringObj(
			  "negative tensor indices not allowed", -1));
	    return (TCL_ERROR);
	}
    }
    return (TCL_OK);
}


/*
 *---------------------------------------------------------------
 *
 * TensorGetSectionIndex --
 *
 *      converts a tensor section description to a pair
 *	of tensor indices representing the low and high
 *	index values for the section. The section description
 *	is a TCL list consisting of N items, for a tensor
 *	of order N. Each item may be:
 *
 *		1) a pair of numbers {n1 n2},
 *		   specifying the low and high
 *		   index values
 *
 *		2) a single number n, which is
 *		   eqivalent to {n n}, or
 *
 *		3) an asterisk "*", representing
 *		   the range {0 d-1}, where "d"
 *		   is the size of the corresponding
 *		   dimension.
 *
 * Results:
 *      The function returns the low and high index values
 *	in lowIndices and highIndices; the return value is
 *	a standard TCL result.
 *
 * Side effects:
 *      None.
 *
 *---------------------------------------------------------------
 */

int 
TensorGetSectionIndex(
    Tcl_Interp *interp,		/* Interpreter, for errors	*/
    Tcl_Obj *idxObjPtr,		/* Tcl_Obj to translate		*/
    Tensor_Descrip *tensorPtr,	/* Tensor to take section of	*/
    Tensor_Index lowIndices,	/* low index values		*/
    Tensor_Index highIndices)	/* high index values		*/
{
    int i, n, ord;
    Tcl_Obj **idx_list;
    Tcl_Obj **hi_low;
    Tcl_Obj *result;

    if (Tcl_ListObjGetElements(interp, idxObjPtr, &ord, &idx_list) != TCL_OK) {
	return (TCL_ERROR);
    }

    if (ord != tensorPtr->order) {
	Tcl_SetObjResult(interp, Tcl_NewStringObj(
	 "order of cross-section does not match order of tensor", -1));
	return (TCL_ERROR);
    }
    for (i = 0; i < ord; i++) {
	if (!strcmp(Tcl_GetString(idx_list[i]), "*")) {
	    lowIndices[i] = 0;
	    highIndices[i] = tensorPtr->dims[i] - 1;
	} else {
	    if (Tcl_ListObjGetElements(interp, idx_list[i], &n, &hi_low) != TCL_OK) {
		return (TCL_ERROR);
	    }
	    if (n != 1 && n != 2) {
		Tcl_SetObjResult(interp, Tcl_NewStringObj(
			      "each item in a tensor cross-section must have one or two elements", -1));
		return (TCL_ERROR);
	    }
	    if (Tcl_GetIntFromObj(interp, hi_low[0], &(lowIndices[i])) != TCL_OK) {
		return (TCL_ERROR);
	    }
	    if (lowIndices[i] < 0 || lowIndices[i] >= tensorPtr->dims[i]) {
		result = Tcl_NewStringObj("low index ", -1);
		Tcl_AppendObjToObj(result, Tcl_NewIntObj(i));
		Tcl_AppendToObj(result,
			" in tensor cross-section is out of range", -1);
		Tcl_SetObjResult(interp, result);
		return (TCL_ERROR);
	    }
	    highIndices[i] = lowIndices[i];

	    if (n >= 2) {
		if (Tcl_GetIntFromObj(interp, hi_low[1], &(highIndices[i])) != TCL_OK) {
		    return (TCL_ERROR);
		}
		if (highIndices[i] < 0 || highIndices[i] >= tensorPtr->dims[i]) {
		    result = Tcl_NewStringObj("high index ", -1);
		    Tcl_AppendObjToObj(result, Tcl_NewIntObj(i));
		    Tcl_AppendToObj(result, " in tensor cross-section is out of range", -1);
		    Tcl_SetObjResult(interp, result);
		    return (TCL_ERROR);
		}
		if (highIndices[i] < lowIndices[i]) {
		    result = Tcl_NewStringObj("for index ", -1);
		    Tcl_AppendObjToObj(result, Tcl_NewIntObj(i));
		    Tcl_AppendToObj(result,
			" of tensor cross-section, high index is less than low index", -1);
		    Tcl_SetObjResult(interp, result);
		    return (TCL_ERROR);
		}
	    }
	}
    }

    return (TCL_OK);
}


/*
 *---------------------------------------------------------------
 *
 * RecursReadTensor --
 *
 *	RecursReadTensor recursively reads a tensor (in its
 *	TCL list form) from string "str" and puts its values in
 *	the tensor referenced by "tensorPtr". It is assumed that
 *	the order and dimensions of the tensor have already been
 *	put into "desc", and that data storage has been allocated.
 *	"order" is the current tensor dimension number; it should
 *	be 0 for a top-level call to RecursReadTensor. "index"
 *	keeps track of the current location where data should
 *	be put. NOTE: this routine would normally be called
 *	only by "TensorGet"
 *
 * Results:
 *      The function returns a standard TCL result.
 *
 * Side effects:
 *      The data in the tensor referenced by tensorPtr
 *	will change.
 *
 *---------------------------------------------------------------
 */

static int 
RecursReadTensor(
    Tcl_Interp *interp,
    Tcl_Obj *obj,
    int order,
    Tensor_Index index,
    Tensor_Descrip *tensorPtr)
{
    int i, n_items;
    Tcl_Obj **split;
    VOID *row_ptr;

    if (Tcl_ListObjGetElements(interp, obj, &n_items, &split) != TCL_OK) {
	return (TCL_ERROR);
    }

    if (n_items != tensorPtr->dims[order]) {
	Tcl_SetObjResult(interp, Tcl_NewStringObj(
		    "incorrect number of items in row of tensor", -1));
	return (TCL_ERROR);
    }

    if (order >= tensorPtr->order - 1) {

	/* Find the row in the data matrix. */

	row_ptr = Tensor_GetElemPtr(tensorPtr, index);

	/* Read a row. */

	switch (tensorPtr->type) {
	    case TENSOR_DOUBLE:
		{
		    double *ptr;

		    ptr = (double *) row_ptr;
		    for (i = 0; i < tensorPtr->dims[tensorPtr->order - 1]; i++)
			if (Tcl_GetDoubleFromObj(interp, split[i], &(ptr[i])) != TCL_OK) {
			    return (TCL_ERROR);
			}
		}
		break;

	    case TENSOR_FLOAT:
		{
		    float *ptr;
		    double d;

		    ptr = (float *) row_ptr;
		    for (i = 0; i < tensorPtr->dims[tensorPtr->order - 1]; i++) {
			if (Tcl_GetDoubleFromObj(interp, split[i], &d) != TCL_OK) {
			    return (TCL_ERROR);
			}
			ptr[i] = d;
		    }
		}
		break;

	    case TENSOR_INT:
		{
		    int *ptr;

		    ptr = (int *) row_ptr;
		    for (i = 0; i < tensorPtr->dims[tensorPtr->order - 1]; i++)
			if (Tcl_GetIntFromObj(interp, split[i], &(ptr[i])) != TCL_OK) {
			    return (TCL_ERROR);
			}
		}
		break;

	    case TENSOR_BYTE:
		{
		    unsigned char *ptr;
		    int j;

		    ptr = (unsigned char *) row_ptr;
		    for (i = 0; i < tensorPtr->dims[tensorPtr->order - 1]; i++) {
			if (Tcl_GetIntFromObj(interp, split[i], &j) != TCL_OK) {
			    return (TCL_ERROR);
			}
			ptr[i] = j;
		    }
		}
		break;

	    case TENSOR_SHORT:
		{
		    unsigned short *ptr;
		    int j;

		    ptr = (unsigned short *) row_ptr;
		    for (i = 0; i < tensorPtr->dims[tensorPtr->order - 1]; i++) {
			if (Tcl_GetIntFromObj(interp, split[i], &j) != TCL_OK) {
			    return (TCL_ERROR);
			}
			ptr[i] = j;
		    }
		}
		break;

	    case TENSOR_UNSIGNED:
		{
		    /* Using Tcl_GetInt to get an unsigned int	*/
		    /* is questionable, but I'll do it until	*/
		    /* I come up with a better idea.		*/

		    unsigned int *ptr;
		    int j;

		    ptr = (unsigned int *) row_ptr;
		    for (i = 0; i < tensorPtr->dims[tensorPtr->order - 1]; i++) {
			if (Tcl_GetIntFromObj(interp, split[i], &j) != TCL_OK) {
			    return (TCL_ERROR);
			}
			ptr[i] = j;
		    }
		}
		break;

	    default:
		fprintf(stderr,
			"Programming error: unknown tensor type \"%1d\"",
			tensorPtr->type);
		exit(1);
		break;
	}

	return (TCL_OK);
    }

    /* Recursively read the tensor. */

    for (i = 0; i < tensorPtr->dims[order]; i++) {
	index[order] = i;
	if (RecursReadTensor(interp, split[i], order + 1, index, tensorPtr) != TCL_OK) {
	    return (TCL_ERROR);
	}
    }

    return (TCL_OK);
}


/*
 *---------------------------------------------------------------
 *
 * TensorGet --
 *
 *      gets a tensor, written as a TCL list, and puts it
 *	into a tensor structure. NOTE: it is assumed that
 *	storage has not been allocated for tensorPtr.
 *
 * Results:
 *      The function returns the tensor data the data part
 *	of *tensorPtr. The return value is a standard TCL result.
 *
 * Side effects:
 *      *tensorPtr's data gets allocated and set.
 *
 *---------------------------------------------------------------
 */

int 
TensorGet(
    Tcl_Interp *interp,		/* Interpreter - for errors	 */
    Tcl_Obj *obj,		/* Tcl_Obj containing tensor
				 * data, formatted as a TCL list */
    Tensor_Descrip *tensorPtr)	/* Tensor we're gonna set	 */
{
    Tensor_Index index;
    int i, err_code;

    /* Bomb if the tensor type's invalid. */

    if (tensorPtr->type < 0
	|| tensorPtr->type > TENSOR_MAX_TYPE) {
	fprintf(stderr, "TensorGet called with tensor that has invalid type\n");
	abort();
    }

    /* Get array dimensions. */

    if (GetDimsOfArray(interp, obj,
			  &(tensorPtr->order), tensorPtr->dims) != TCL_OK) {
	return (TCL_ERROR);
    }

    /* Allocate data storage. */

    if (Tensor_AllocData(interp, tensorPtr) != TCL_OK) {
	return (TCL_ERROR);
    }

    /* Recursively read the tensor. */

    for (i = 0; i < tensorPtr->order; i++) {
	index[i] = 0;
    }

    err_code = RecursReadTensor(interp, obj, 0, index, tensorPtr);
    if (err_code != TCL_OK) {
	Tensor_FreeData(tensorPtr);
    }
    return (err_code);
}


/*
 *---------------------------------------------------------------
 *
 * RecursTensorToList --
 *
 *      recursively converts a tensor to a Tcl list, and
 *	returns the list as a Tcl_Obj pointer.
 *
 * Results:
 *      Returns a Tcl_Obj pointer
 *
 * Side effects:
 *      None
 *
 *---------------------------------------------------------------
 */

static Tcl_Obj *RecursTensorToList(
    Tensor_Descrip *tensorPtr,	/* Tensor we're converting	*/
    int ord,			/* Recursion depth		*/
    Tensor_Index idx)		/* Current index we're using	*/
{
    int i;
    VOID *data_ptr;
    Tcl_Obj *r, *r2;

    r = Tcl_NewObj();

    if (ord >= tensorPtr->order - 1) {
	for (i = 0; i < tensorPtr->dims[ord]; i++) {
	    idx[ord] = i;
	    data_ptr = Tensor_GetElemPtr(tensorPtr, idx);
	    r2 = Tensor_GetElemObj(data_ptr, tensorPtr->type);
	    Tcl_ListObjAppendElement(NULL, r, r2);
	}

	return(r);
    }

    for (i = 0; i < tensorPtr->dims[ord]; i++) {
	idx[ord] = i;
	r2 = RecursTensorToList(tensorPtr, ord + 1, idx);
	Tcl_ListObjAppendElement(NULL, r, r2);
    }

    return(r);
}


/*
 *---------------------------------------------------------------
 *
 * TensorPut --
 *
 *      writes a tensor's contents into "interp", formatted
 *	as a TCL-style list.
 *
 * Results:
 *      The function returns a standard TCL result.
 *
 * Side effects:
 *      None.
 *
 *---------------------------------------------------------------
 */

int 
TensorPut(
    Tcl_Interp *interp,		/* Result goes here	*/
    Tensor_Descrip *tensorPtr)	/* Tensor to translate	*/
{
    Tensor_Index idx;
    Tcl_Obj *result;

    Tcl_ResetResult(interp);
    if (tensorPtr->order == 0) {
	Tcl_SetObjResult(interp, Tensor_GetElemObj(tensorPtr->data,
							tensorPtr->type));
	return (TCL_OK);
    }

    result = RecursTensorToList(tensorPtr, 0, idx);
    Tcl_SetObjResult(interp, result);
    return(TCL_OK);
}


/*
 *---------------------------------------------------------------
 *
 * TensorPutSection --
 *
 *      writes part of a tensor's contents into "interp",
 *	formatted as a TCL-style list.
 *
 * Results:
 *      The function returns a standard TCL result.
 *
 * Side effects:
 *      None.
 *
 *---------------------------------------------------------------
 */


int 
TensorPutSection(
    Tcl_Interp *interp,		/* Result goes here		*/
    Tensor_Descrip *tensorPtr,	/* Tensor to translate		*/
    Tensor_Index lowIdx,	/* Low indices of section	*/
    Tensor_Index highIdx)	/* High indices of section	*/
{
    Tensor_Descrip copy;
    Tensor_Index copy_low_idx, copy_high_idx, idx_map;
    int i, retcode;

    /* Get the dimensions of the section. */

    TensorSectionDims( tensorPtr->order, lowIdx, highIdx,
	    &copy.order, copy.dims, idx_map);

    /* Copy tensor section into a tensor  */
    /* of the proper order and dimension. */

    copy.type = tensorPtr->type;
    if (Tensor_AllocData(interp, &copy) != TCL_OK)
	return (TCL_ERROR);

    for (i = 0; i < copy.order; i++) {
	copy_low_idx[i] = 0;
	copy_high_idx[i] = copy.dims[i] - 1;
    }

    retcode = TensorCopySection(interp,
				    &copy, copy_low_idx, copy_high_idx,
				    tensorPtr, lowIdx, highIdx);

    if (retcode != TCL_OK) {
	Tensor_FreeData(&copy);
	return (TCL_ERROR);
    }
    /* Put the copy into "interp". */

    retcode = TensorPut(interp, &copy);

    /* Clean up and return. */

    Tensor_FreeData(&copy);
    return (retcode);
}
