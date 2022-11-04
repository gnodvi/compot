/*
 * tensorOps.c --
 *
 *	Code that implements tensor operations - copying,
 *	multiplying, adding, contracting, etc.
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

static char rcsid[] = "$Header: /home/neil/src/tcl/tensor/generic/RCS/tensorOps.c,v 1.7 2008/06/07 21:36:10 neil Exp $";

#endif

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>
#include <ctype.h>
#include "tcl.h"
#include "tensorInt.h"

/*
 *---------------------------------------------------------------
 *
 * TensorSectionDims --
 *
 *      determines the dimensions of a section of a tensor,
 *	given the order of the original tensor and the low
 *	and high indices of the section.
 *
 * Results:
 *      The function returns the order of the section in *outOrderPtr;
 *	sectionSize gives the size of the section, and indexMap
 *	maps the section dimension to the corresponding dimension
 *	in the original tensor.
 *
 * Side effects:
 *      None.
 *
 *---------------------------------------------------------------
 */

void 
TensorSectionDims (

    int inOrder,		/* Order of tensor we're taking
				 * section of			*/
    Tensor_Index lowIndices,	/* Low indices of section	*/
    Tensor_Index highIndices,	/* High indices of section	*/
    int *outOrderPtr,		/* Order of section (output)	*/
    Tensor_Index sectionSize,	/* Dimensions of section	*/
    Tensor_Index indexMap)	/* Map from index of section
				 * to index of original tensor	*/
{
    int i, j;

    for (i = 0, j = 0; i < inOrder; i++) {
	if (highIndices[i] < lowIndices[i]) {
	    *outOrderPtr = 1;
	    sectionSize[0] = 0;
	    indexMap[0] = 0;
	    return;
	}

	if (highIndices[i] > lowIndices[i]) {
	    indexMap[j] = i;
	    sectionSize[j] = highIndices[i] - lowIndices[i] + 1;
	    j++;
	}
    }

    *outOrderPtr = j;
}

/*
 *---------------------------------------------------------------
 *
 * TensorCopySection --
 *
 *      copies a section of one tensor into a section of
 *	another tensor.
 *
 * Results:
 *      returns a standard TCL result.
 *
 * Side effects:
 *      Contents of the destination tensor are changed.
 *
 *---------------------------------------------------------------
 */


int 
TensorCopySection(
    Tcl_Interp *interp,		/* For error messages		*/
    Tensor_Descrip *destTensorPtr,/* Tensor we're copying into	*/
    Tensor_Index destLowIndices,/* Low indices of section we're
				 * copying data into		*/
    Tensor_Index destHighIndices,/* High indices of section we're
				 * copying data into		*/
    Tensor_Descrip *srcTensorPtr,/* Tensor we're copying from	*/
    Tensor_Index srcLowIndices,	/* Low indices of section we're
				 * copying data from		*/
    Tensor_Index srcHighIndices)/* High indices of section we're
				 * copying data from		*/
{
    int i;
    VOID *src_el, *dest_el;
    int dest_order, src_order;
    Tensor_Index dest_index, src_index, index_map;
    char junkstr[32];
    Tcl_Obj *result;

    /* Make sure our indices are OK. */

    TensorSectionDims(destTensorPtr->order,
	    destLowIndices, destHighIndices,
	    &dest_order, dest_index, index_map);
    TensorSectionDims(srcTensorPtr->order,
	    srcLowIndices, srcHighIndices,
	    &src_order, src_index, index_map);

    if (dest_order != src_order) {
	result = Tcl_NewStringObj("destination section order (", -1);
	Tcl_AppendObjToObj(result, Tcl_NewIntObj(dest_order));
	Tcl_AppendToObj(result, ") does not match source section order (", -1);
	Tcl_AppendObjToObj(result, Tcl_NewIntObj(src_order));
	Tcl_AppendToObj(result, ")", -1);
	Tcl_SetObjResult(interp, result);

	return (TCL_ERROR);
    }
    for (i = 0; i < dest_order; i++) {
	if (dest_index[i] != src_index[i]) {
	    Tcl_ResetResult(interp);
	    sprintf(junkstr, "%1d", i);

	    result = Tcl_NewStringObj("dimension of index ", -1);
	    Tcl_AppendObjToObj(result, Tcl_NewIntObj(i));
	    Tcl_AppendToObj(result, " of destination tensor section (=", -1);
	    Tcl_AppendObjToObj(result, Tcl_NewIntObj(dest_index[i]));
	    Tcl_AppendToObj(result, ") is not equal to corresponding dimension of source tensor section (=", -1);
	    Tcl_AppendObjToObj(result, Tcl_NewIntObj(src_index[i]));
	    Tcl_AppendToObj(result, ")", -1);
	    Tcl_SetObjResult(interp, result);

	    return (TCL_ERROR);
	}
    }

    /* Just return if there's nothing to copy. */

    if(srcTensorPtr->data == (VOID *) NULL
	    ||  destTensorPtr->data == (VOID *) NULL) {
	return(TCL_OK);
    }

    for(i = 0; i < dest_order; i++) {
	if(dest_index[i] <= 0) {
	    return(TCL_OK);
	}
    }

    /* Copy the tensor data. */

    for (i = 0; i < srcTensorPtr->order; i++) {
	src_index[i] = srcLowIndices[i];
    }
    for (i = 0; i < destTensorPtr->order; i++) {
	dest_index[i] = destLowIndices[i];
    }

    for (;;) {
	/* Copy tensor elemnts. */

	src_el = Tensor_GetElemPtr(srcTensorPtr, src_index);
	dest_el = Tensor_GetElemPtr(destTensorPtr, dest_index);

#ifdef DEBUG
	/* Check array bounds */

	if(Tensor_CheckIndex(interp, destTensorPtr, dest_index) != TCL_OK) {
	    return (TCL_ERROR);
	}
#endif

	Tensor_SetElemValue(dest_el, destTensorPtr->type,
		     Tensor_GetElemValue(src_el, srcTensorPtr->type));

	/* Update indices, exit if done. */

	if(!Tensor_NextIndex(srcTensorPtr->order,
		srcLowIndices, srcHighIndices, src_index)) {
	    break;
	}

	if(!Tensor_NextIndex(destTensorPtr->order,
		destLowIndices, destHighIndices, dest_index)) {
	    break;
	}
    }

    return (TCL_OK);
}


/*
 *---------------------------------------------------------------
 *
 * TensorOpScalar --
 *
 *      performs an arithmetic operation between a tensor
 *	and a scalar operand.
 *
 * Results:
 *      returns a standard TCL result.
 *
 * Side effects:
 *      Contents of the destination tensor are changed.
 *
 *---------------------------------------------------------------
 */

int 
TensorOpScalar(
    Tcl_Interp *interp,		/* For error messages		*/
    Tensor_Descrip *destTensorPtr,/* Tensor we're operating on	*/
    Tensor_Index destLowIndices,/* Low indices of tensor
				 * section we're operating on	*/
    Tensor_Index destHighIndices,/* High indices of tensor
				 * section we're operating on	*/
    int op,			/* Operation: '+', '-', '*',
				 * '/', or 'c' (copy)		*/
    double s)			/* Scalar operand		*/
{
    int i;
    VOID *dest_el;
    Tensor_Index dest_index;
    double d;

    /* Don't allow division by zero - leave the tensor unchanged. */

    if (op == '/' && s == 0.0) {
	return(TCL_OK);
    }

    /* Return if there's no data to opertate on. */

    if (destTensorPtr == (VOID *) NULL) {
	return(TCL_OK);
    }

    /* Return if the section is of zero size. */

    for (i = 0; i < destTensorPtr->order; i++) {
	if(destLowIndices[i] > destHighIndices[i]) {
	    return(TCL_OK);
	}
    }

    /* Operate on the tensor data. */

    for (i = 0; i < destTensorPtr->order; i++) {
	dest_index[i] = destLowIndices[i];
    }

    for (;;) {
#ifdef DEBUG
	/* Check array bounds */

	if(Tensor_CheckIndex(interp, destTensorPtr, dest_index) != TCL_OK) {
	    return (TCL_ERROR);
	}
#endif

	/* Copy tensor elements. */

	dest_el = Tensor_GetElemPtr(destTensorPtr, dest_index);

	d = Tensor_GetElemValue(dest_el, destTensorPtr->type);
	switch (op) {
	    case 'c':
		d = s;
		break;

	    case '+':
		d += s;
		break;

	    case '-':
		d -= s;
		break;

	    case '*':
		d *= s;
		break;

	    case '/':
		d /= s;
		break;

	}

	Tensor_SetElemValue(dest_el, destTensorPtr->type, d);

	/* Update indices, exit if done. */

	if(!Tensor_NextIndex(destTensorPtr->order,
		destLowIndices,destHighIndices,dest_index)) {
	    break;
	}

    }

    return (TCL_OK);
}


/*
 *---------------------------------------------------------------
 *
 * TensorOpTensor --
 *
 *      performs an arithmetic operation between a tensor
 *	and a tensor operand.
 *
 * Results:
 *      returns a standard TCL result.
 *
 * Side effects:
 *      Contents of the destination tensor are changed.
 *
 *---------------------------------------------------------------
 */


int 
TensorOpTensor(
    Tcl_Interp *interp,		/* For error messages		*/
    Tensor_Descrip *destTensorPtr,/* Tensor we're operating on	*/
    Tensor_Index destLowIndices,/* Low indices of tensor
				 * section we're operating on	*/
    Tensor_Index destHighIndices,/* High indices of tensor
				 * section we're operating on	*/
    int op,
    Tensor_Descrip *srcTensorPtr,/* Operand tensor		*/
    Tensor_Index srcLowIndices,	/* Low indices of section of
				 * operand tensor		*/
    Tensor_Index srcHighIndices)/* High indices of section of
				 * operand tensor		*/
{
    int i;
    VOID *src_el, *dest_el;
    int dest_order, src_order;
    Tensor_Index dest_index, src_index, index_map;
    char junkstr[32];
    Tcl_Obj *result;
    double d, s;

    /* Make sure our indices are OK. */

    TensorSectionDims(destTensorPtr->order,
	    destLowIndices, destHighIndices,
	    &dest_order, dest_index, index_map);
    TensorSectionDims(srcTensorPtr->order,
	    srcLowIndices, srcHighIndices,
	    &src_order, src_index, index_map);

    if (dest_order != src_order) {
	result = Tcl_NewStringObj("destination section order (", -1);
	Tcl_AppendObjToObj(result, Tcl_NewIntObj(dest_order));
	Tcl_AppendToObj(result, ") does not match source section order (", -1);
	Tcl_AppendObjToObj(result, Tcl_NewIntObj(src_order));
	Tcl_AppendToObj(result, ")", -1);
	Tcl_SetObjResult(interp, result);
	return (TCL_ERROR);
    }
    for (i = 0; i < dest_order; i++)
	if (dest_index[i] != src_index[i]) {
	    Tcl_ResetResult(interp);
	    sprintf(junkstr, "%1d", i);

	    result = Tcl_NewStringObj("dimension of index ", -1);
	    Tcl_AppendObjToObj(result, Tcl_NewIntObj(i));
	    Tcl_AppendToObj(result, " of destination tensor section (=", -1);
	    Tcl_AppendObjToObj(result, Tcl_NewIntObj(dest_index[i]));
	    Tcl_AppendToObj(result, ") is not equal to corresponding dimension of source tensor section (=", -1);
	    Tcl_AppendObjToObj(result, Tcl_NewIntObj(src_index[i]));
	    Tcl_AppendToObj(result, ")", -1);
	    Tcl_SetObjResult(interp, result);

	    return (TCL_ERROR);
	}

    /* Return if there's no data to operate on. */

    if(destTensorPtr->data == (VOID *) NULL
	    || srcTensorPtr->data == (VOID *) NULL) {
	return(TCL_OK);
    }

    /* Return if the section's empty. */

    for (i = 0; i < dest_order; i++) {
	if (dest_index[i] <= 0) {
	    return(TCL_OK);
	}
    }

    /* Operate on the tensor data. */

    for (i = 0; i < srcTensorPtr->order; i++) {
	src_index[i] = srcLowIndices[i];
    }
    for (i = 0; i < destTensorPtr->order; i++) {
	dest_index[i] = destLowIndices[i];
    }

    for (;;) {
#ifdef DEBUG
	/* Check array bounds */

	if(Tensor_CheckIndex(interp, destTensorPtr, dest_index) != TCL_OK) {
	    return (TCL_ERROR);
	}
#endif

	/* Copy tensor elemnts. */

	src_el = Tensor_GetElemPtr(srcTensorPtr, src_index);
	dest_el = Tensor_GetElemPtr(destTensorPtr, dest_index);

	d = Tensor_GetElemValue(dest_el, destTensorPtr->type);
	s = Tensor_GetElemValue(src_el, srcTensorPtr->type);
	switch (op) {
	    case 'c':
		d = s;
		break;

	    case '+':
		d += s;
		break;

	    case '-':
		d -= s;
		break;

	    case '*':
		d *= s;
		break;

	    case '/':
		if (s != 0.0) {
		    d /= s;
		}
		break;

	}

	Tensor_SetElemValue(dest_el, destTensorPtr->type, d);

	/* Update indices, exit if done. */

	if(!Tensor_NextIndex(srcTensorPtr->order,
		srcLowIndices,srcHighIndices,src_index)) {
	    break;
	}

	if(!Tensor_NextIndex(destTensorPtr->order,
		destLowIndices,destHighIndices,dest_index)) {
	    break;
	}
    }

    return (TCL_OK);
}

/*
 *---------------------------------------------------------------
 *
 * CompInt --
 *
 *      compares two integers (referenced as pointers).
 *
 * Results:
 *      returns a number greater than 0, equal to 0, or less
 *	than 0, depending upon whether the first integer is
 *	less than, equal to, or greater than the second.
 *
 * Side effects:
 *      None.
 *
 *---------------------------------------------------------------
 */


static int 
CompInt(void *i1, void *i2)
{
    return (*((int *) i1) - *((int *) i2));
}


/*
 *---------------------------------------------------------------
 *
 * TensorContract --
 *
 *      contracts a tensor, i.e. creates a new tensor by
 *	summing all elements along given dimensions.
 *
 * Results:
 *      returns the contracted tensor in "result". The
 *	function returns a standard TCL result.
 *
 * Side effects:
 *      The result tensor's size is set, and its data is
 *	allocated and set. NOTE: the result tensor
 *	should NOT have had its data allocated before
 *	this routine is called, as the old data will
 *	NOT be freed.
 *
 *---------------------------------------------------------------
 */

int 
TensorContract(
    Tcl_Interp *interp,		/* For error messages		*/
    Tensor_Descrip *operandPtr,	/* Tensor we're contracting	*/
    int llength,		/* Number of dimensions to
				 * sum along			*/
    int idxList[TENSOR_MAX_ORDER],/* Indices to sum along	*/
    Tensor_Descrip *resultPtr)	/* Contracted tensor goes here	*/
{
    int i, j;
    int t_idx, idx_max;
    Tensor_Index idx_map, src_idx, p_idx;
    Tcl_Obj *result;
    double sum;
    VOID *el;
    int is_in_list[TENSOR_MAX_ORDER];

    if (llength > operandPtr->order) {
	Tcl_SetObjResult(interp, Tcl_NewStringObj(
	     "Length of index list is greater than tensor order", -1));
	return (TCL_ERROR);
    }
    /* Make sure the indices are in range, and that none are duplicated. */

    for (i = 0; i < llength; i++) {
	if (idxList[i] < 0 || idxList[i] >= operandPtr->order) {
	    result = Tcl_NewStringObj("Index #", -1);
	    Tcl_AppendObjToObj(result, Tcl_NewIntObj(i));
	    Tcl_AppendToObj(result, " is out of range", -1);
	    Tcl_SetObjResult(interp, result);

	    return (TCL_ERROR);
	}
	for (j = i - 1; j >= 0; j--) {
	    if (idxList[i] == idxList[j]) {
		result = Tcl_NewStringObj("Index #", -1);
		Tcl_AppendObjToObj(result, Tcl_NewIntObj(i));
		Tcl_AppendToObj(result, " is a duplicate of a previous index", -1);
		Tcl_SetObjResult(interp, result);

		return (TCL_ERROR);
	    }
	}
    }

    /* Make sure all indices have the same dimension. */

    idx_max = operandPtr->dims[idxList[0]];
    for (i = 1; i < llength; i++) {
	if (operandPtr->dims[idxList[i]] != idx_max) {
	    Tcl_SetObjResult(interp, Tcl_NewStringObj(
			"selected indices do not all have the same dimension",
			  -1));
	    return (TCL_ERROR);
	}
    }

    /* Set the tensor order and type. */

    resultPtr->order = operandPtr->order - llength;
    resultPtr->type = TENSOR_DOUBLE;

    /* Make a map that indicates what indices we're deleting. */

    for(i = 0; i < TENSOR_MAX_ORDER; i++) {
	is_in_list[i] = 0;
    }
    for(i = 0; i < llength; i++) {
	is_in_list[idxList[i]] = 1;
    }

    /* Set the tensor dimensions, and build the map from old to new indices. */

    for (i = 0, t_idx = 0; i < operandPtr->order; i++) {
	if (!is_in_list[i]) {
	    resultPtr->dims[t_idx] = operandPtr->dims[i];
	    idx_map[t_idx] = i;
	    t_idx++;
	}
    }

    if (Tensor_AllocData(interp, resultPtr) != TCL_OK) {
	return (TCL_ERROR);
    }

    /* Exit if there's no data in the contraction. */

    if(resultPtr->data == (VOID *) NULL) {
	return(TCL_OK);
    }

    /* Compute the contraction. */

    for (i = 0; i < resultPtr->order; i++) {
	src_idx[i] = 0;
    }

    for (;;) {
	for (i = 0; i < operandPtr->order; i++) {
	    p_idx[i] = 0;
	}
	for (i = 0; i < resultPtr->order; i++) {
	    p_idx[idx_map[i]] = src_idx[i];
	}
	sum = 0.0;
	for (i = 0; i < idx_max; i++) {
	    for (j = 0; j < llength; j++) {
		p_idx[idxList[j]] = i;
	    }
	    el = Tensor_GetElemPtr(operandPtr, p_idx);
	    sum += Tensor_GetElemValue(el, operandPtr->type);
	}

	el = Tensor_GetElemPtr(resultPtr, src_idx);
	Tensor_SetElemValue(el, resultPtr->type, sum);

	/* Update indices. */


	for (i = resultPtr->order - 1; i >= 0; i--) {
	    if (src_idx[i] < resultPtr->dims[i] - 1) {
		(src_idx[i])++;
		break;
	    }
	    src_idx[i] = 0;
	}

	if (i < 0) {
	    break;
	}
    }

    return (TCL_OK);
}
//------------------------------------------------------------------------------
/*
 *---------------------------------------------------------------
 *
 * TensorMultiply --
 *
 *      multiplies two tensors using a specified pair of indices.
 *
 * Results:
 *      returns the tensor product in "result". The
 *	function returns a standard TCL result.
 *
 * Side effects:
 *      The result tensor's size is set, and its data is
 *	allocated and set. NOTE: the result tensor
 *	should NOT have had its data allocated before
 *	this routine is called, as the old data will
 *	NOT be freed.
 *
 *---------------------------------------------------------------
 */
//------------------------------------------------------------------------------
int 
TensorMultiply (

                Tcl_Interp *interp,			/* For error messages		*/
    Tensor_Descrip *tensorPtrArray[2],	/* Tensors to multiply		*/
    int idxList[2],			/* Indices to sum over		*/
    Tensor_Descrip *resultPtr)		/* Product goes here		*/
{

    int i, j, k;
    int idx_max;
    double sum, op_d[2];
    Tensor_Index op_idx[2], res_idx;
    VOID *el;
    double *dblPtr1, *dblPtr2;
    float *fltPtr1, *fltPtr2;
    int *intPtr1, *intPtr2;
    unsigned char *bytePtr1, *bytePtr2;
    unsigned short *shortPtr1, *shortPtr2;
    unsigned int *uintPtr1, *uintPtr2;
    Tcl_Obj *result;

    for (i = 0; i < 2; i++) {
	if (idxList[i] < 0 || idxList[i] >= tensorPtrArray[i]->order) {
	    Tcl_ResetResult(interp);

	    result = Tcl_NewStringObj("Index # out of range for ", -1);

	    if (i == 0) {
		Tcl_AppendToObj(result, "first", -1);
	    } else {
		Tcl_AppendToObj(result, "second", -1);
	    }

	    Tcl_AppendToObj(result, " tensor", -1);
	    Tcl_SetObjResult(interp, result);

	    return (TCL_ERROR);
	}
    }

    /* Allocate storage. */

    if (tensorPtrArray[0]->type == tensorPtrArray[1]->type) {
	resultPtr->type = tensorPtrArray[0]->type;
    } else {
	resultPtr->type = TENSOR_DOUBLE;
    }

    resultPtr->order = tensorPtrArray[0]->order + tensorPtrArray[1]->order - 2;
    if (resultPtr->order > TENSOR_MAX_ORDER) {
	Tcl_SetObjResult(interp, Tcl_NewStringObj(
		      "Order of tensor product exceeds limit", -1));
	return (TCL_ERROR);
    }
    k = 0;
    for (i = 0; i < 2; i++) {
	for (j = 0; j < idxList[i]; j++) {
	    resultPtr->dims[k++] = tensorPtrArray[i]->dims[j];
	}
	for (j = idxList[i] + 1; j < tensorPtrArray[i]->order; j++) {
	    resultPtr->dims[k++] = tensorPtrArray[i]->dims[j];
	}
    }

    if (Tensor_AllocData(interp, resultPtr) != TCL_OK) {
	return (TCL_ERROR);
    }

    /* Exit if the result contains no data. */

    if(resultPtr->data == (VOID *) NULL) {
	return(TCL_OK);
    }

    /* Perform the multiplication and summation. */

    for (i = 0; i < resultPtr->order; i++) {
	res_idx[i] = 0;
    }

    idx_max = tensorPtrArray[0]->dims[idxList[0]];

    /*
     * First we'll handle the special case where the types are the same.
     * Treating this as a special case can give big efficiency gains.
     */

    if (tensorPtrArray[0]->type == tensorPtrArray[1]->type) {
	switch(tensorPtrArray[0]->type) {
	    case TENSOR_DOUBLE:
		for (;;) {
		    k = 0;
		    for (i = 0; i < 2; i++) {
			for (j = 0; j < idxList[i]; j++) {
			    op_idx[i][j] = res_idx[k++];
			}
			op_idx[i][idxList[i]] = 0;
			for (j = idxList[i] + 1; j < tensorPtrArray[i]->order; j++) {
			    op_idx[i][j] = res_idx[k++];
			}
		    }

		    sum = 0.0;
		    for (i = 0; i < idx_max; i++) {
			op_idx[0][idxList[0]] = i;
			op_idx[1][idxList[1]] = i;
			dblPtr1 = (double *) Tensor_GetElemPtr(tensorPtrArray[0], op_idx[0]);
			dblPtr2 = (double *) Tensor_GetElemPtr(tensorPtrArray[1], op_idx[1]);
			sum += (*dblPtr1) * (*dblPtr2);
		    }

		    dblPtr1 = (double *) Tensor_GetElemPtr(resultPtr, res_idx);
		    *dblPtr1 = sum;

		    /* Update indices. */

		    for (i = resultPtr->order - 1; i >= 0; i--) {
			if (res_idx[i] < resultPtr->dims[i] - 1) {
			    (res_idx[i])++;
			    break;
			}
			res_idx[i] = 0;
		    }

		    if (i < 0) {
			break;
		    }
		}

		break;

	    case TENSOR_FLOAT:
		for (;;) {
		    k = 0;
		    for (i = 0; i < 2; i++) {
			for (j = 0; j < idxList[i]; j++) {
			    op_idx[i][j] = res_idx[k++];
			}
			op_idx[i][idxList[i]] = 0;
			for (j = idxList[i] + 1; j < tensorPtrArray[i]->order; j++) {
			    op_idx[i][j] = res_idx[k++];
			}
		    }

		    sum = 0.0;
		    for (i = 0; i < idx_max; i++) {
			op_idx[0][idxList[0]] = i;
			op_idx[1][idxList[1]] = i;
			fltPtr1 = (float *) Tensor_GetElemPtr(tensorPtrArray[0], op_idx[0]);
			fltPtr2 = (float *) Tensor_GetElemPtr(tensorPtrArray[1], op_idx[1]);
			sum += (*fltPtr1) * (*fltPtr2);
		    }

		    fltPtr1 = (float *) Tensor_GetElemPtr(resultPtr, res_idx);
		    *fltPtr1 = sum;

		    /* Update indices. */

		    for (i = resultPtr->order - 1; i >= 0; i--) {
			if (res_idx[i] < resultPtr->dims[i] - 1) {
			    (res_idx[i])++;
			    break;
			}
			res_idx[i] = 0;
		    }

		    if (i < 0) {
			break;
		    }
		}

		break;

	    case TENSOR_BYTE:
		for (;;) {
		    k = 0;
		    for (i = 0; i < 2; i++) {
			for (j = 0; j < idxList[i]; j++) {
			    op_idx[i][j] = res_idx[k++];
			}
			op_idx[i][idxList[i]] = 0;
			for (j = idxList[i] + 1; j < tensorPtrArray[i]->order; j++) {
			    op_idx[i][j] = res_idx[k++];
			}
		    }

		    sum = 0.0;
		    for (i = 0; i < idx_max; i++) {
			op_idx[0][idxList[0]] = i;
			op_idx[1][idxList[1]] = i;
			bytePtr1 = (unsigned char *) Tensor_GetElemPtr(tensorPtrArray[0], op_idx[0]);
			bytePtr2 = (unsigned char *) Tensor_GetElemPtr(tensorPtrArray[1], op_idx[1]);
			sum += ((double) (*bytePtr1)) * ((double) (*bytePtr2));
		    }

		    bytePtr1 = (unsigned char *) Tensor_GetElemPtr(resultPtr, res_idx);
		    *bytePtr1 = sum;

		    /* Update indices. */

		    for (i = resultPtr->order - 1; i >= 0; i--) {
			if (res_idx[i] < resultPtr->dims[i] - 1) {
			    (res_idx[i])++;
			    break;
			}
			res_idx[i] = 0;
		    }

		    if (i < 0) {
			break;
		    }
		}

		break;

	    case TENSOR_SHORT:
		for (;;) {
		    k = 0;
		    for (i = 0; i < 2; i++) {
			for (j = 0; j < idxList[i]; j++) {
			    op_idx[i][j] = res_idx[k++];
			}
			op_idx[i][idxList[i]] = 0;
			for (j = idxList[i] + 1; j < tensorPtrArray[i]->order; j++) {
			    op_idx[i][j] = res_idx[k++];
			}
		    }

		    sum = 0.0;
		    for (i = 0; i < idx_max; i++) {
			op_idx[0][idxList[0]] = i;
			op_idx[1][idxList[1]] = i;
			shortPtr1 = (unsigned short *) Tensor_GetElemPtr(tensorPtrArray[0], op_idx[0]);
			shortPtr2 = (unsigned short *) Tensor_GetElemPtr(tensorPtrArray[1], op_idx[1]);
			sum += ((double) (*shortPtr1))
					* ((double) (*shortPtr2));
		    }

		    shortPtr1 = (unsigned short *) Tensor_GetElemPtr(resultPtr, res_idx);
		    *shortPtr1 = sum;

		    /* Update indices. */

		    for (i = resultPtr->order - 1; i >= 0; i--) {
			if (res_idx[i] < resultPtr->dims[i] - 1) {
			    (res_idx[i])++;
			    break;
			}
			res_idx[i] = 0;
		    }

		    if (i < 0) {
			break;
		    }
		}

		break;

	    case TENSOR_INT:
		for (;;) {
		    k = 0;
		    for (i = 0; i < 2; i++) {
			for (j = 0; j < idxList[i]; j++) {
			    op_idx[i][j] = res_idx[k++];
			}
			op_idx[i][idxList[i]] = 0;
			for (j = idxList[i] + 1; j < tensorPtrArray[i]->order; j++) {
			    op_idx[i][j] = res_idx[k++];
			}
		    }

		    sum = 0.0;
		    for (i = 0; i < idx_max; i++) {
			op_idx[0][idxList[0]] = i;
			op_idx[1][idxList[1]] = i;
			intPtr1 = (int *) Tensor_GetElemPtr(tensorPtrArray[0], op_idx[0]);
			intPtr2 = (int *) Tensor_GetElemPtr(tensorPtrArray[1], op_idx[1]);
			sum += (*intPtr1) * (*intPtr2);
		    }

		    intPtr1 = (int *) Tensor_GetElemPtr(resultPtr, res_idx);
		    *intPtr1 = sum;

		    /* Update indices. */

		    for (i = resultPtr->order - 1; i >= 0; i--) {
			if (res_idx[i] < resultPtr->dims[i] - 1) {
			    (res_idx[i])++;
			    break;
			}
			res_idx[i] = 0;
		    }

		    if (i < 0) {
			break;
		    }
		}

		break;

	    case TENSOR_UNSIGNED:
		for (;;) {
		    k = 0;
		    for (i = 0; i < 2; i++) {
			for (j = 0; j < idxList[i]; j++) {
			    op_idx[i][j] = res_idx[k++];
			}
			op_idx[i][idxList[i]] = 0;
			for (j = idxList[i] + 1; j < tensorPtrArray[i]->order; j++) {
			    op_idx[i][j] = res_idx[k++];
			}
		    }

		    sum = 0.0;
		    for (i = 0; i < idx_max; i++) {
			op_idx[0][idxList[0]] = i;
			op_idx[1][idxList[1]] = i;
			uintPtr1 = (unsigned int *) Tensor_GetElemPtr(tensorPtrArray[0], op_idx[0]);
			uintPtr2 = (unsigned int *) Tensor_GetElemPtr(tensorPtrArray[1], op_idx[1]);
			sum += (*uintPtr1) * (*uintPtr2);
		    }

		    uintPtr1 = (unsigned int *) Tensor_GetElemPtr(resultPtr, res_idx);
		    *uintPtr1 = sum;

		    /* Update indices. */

		    for (i = resultPtr->order - 1; i >= 0; i--) {
			if (res_idx[i] < resultPtr->dims[i] - 1) {
			    (res_idx[i])++;
			    break;
			}
			res_idx[i] = 0;
		    }

		    if (i < 0) {
			break;
		    }
		}

		break;
	}

	return(TCL_OK);
    }

    /* Now handle the general case. */

    for (;;) {
	k = 0;
	for (i = 0; i < 2; i++) {
	    for (j = 0; j < idxList[i]; j++) {
		op_idx[i][j] = res_idx[k++];
	    }
	    op_idx[i][idxList[i]] = 0;
	    for (j = idxList[i] + 1; j < tensorPtrArray[i]->order; j++) {
		op_idx[i][j] = res_idx[k++];
	    }
	}

	sum = 0.0;
	for (i = 0; i < idx_max; i++) {
	    for (j = 0; j < 2; j++) {
		op_idx[j][idxList[j]] = i;
		el = Tensor_GetElemPtr(tensorPtrArray[j], op_idx[j]);
		op_d[j] = Tensor_GetElemValue(el, tensorPtrArray[j]->type);
	    }

	    sum += op_d[0] * op_d[1];
	}

	el = Tensor_GetElemPtr(resultPtr, res_idx);
	Tensor_SetElemValue(el, resultPtr->type, sum);

	/* Update indices. */

	for (i = resultPtr->order - 1; i >= 0; i--) {
	    if (res_idx[i] < resultPtr->dims[i] - 1) {
		(res_idx[i])++;
		break;
	    }
	    res_idx[i] = 0;
	}

	if (i < 0) {
	    break;
	}
    }

    return (TCL_OK);
}
//------------------------------------------------------------------------------


/*
 *---------------------------------------------------------------
 *
 * TensorOuterProduct --
 *
 *      multiplies two tensors in all possible
 *	pairwise combinations.
 *
 * Results:
 *      returns the outer product in "resultPtr". The
 *	function returns a standard TCL result.
 *
 * Side effects:
 *      The result tensor's size is set, and its data is
 *	allocated and set. NOTE: the result tensor
 *	should NOT have had its data allocated before
 *	this routine is called, as the old data will
 *	NOT be freed.
 *
 *---------------------------------------------------------------
 */

int 
TensorOuterProduct(
    Tcl_Interp *interp,			/* For error messages	*/
    Tensor_Descrip *tensorPtrArray[2],	/* Array of operands	*/
    Tensor_Descrip *resultPtr)		/* Outer product	*/
{
    int i, j, k;
    Tensor_Index src_idx, op_idx[2];
    VOID *el;
    double op_d[2];

    /* Check indices and allocate storage. */

    resultPtr->order = tensorPtrArray[0]->order + tensorPtrArray[1]->order;
    if (resultPtr->order > TENSOR_MAX_ORDER) {
	Tcl_SetObjResult(interp, Tcl_NewStringObj(
		      "dimension of outer product is too large", -1));
	return (TCL_ERROR);
    }
    k = 0;
    for (i = 0; i < 2; i++) {
	for (j = 0; j < tensorPtrArray[i]->order; j++) {
	    resultPtr->dims[k] = tensorPtrArray[i]->dims[j];
	    k++;
	}
    }

    resultPtr->type = TENSOR_DOUBLE;
    if (Tensor_AllocData(interp, resultPtr) != TCL_OK) {
	return (TCL_ERROR);
    }

    /* Return if there's no data. */

    if(resultPtr->data == (VOID *) NULL) {
	return(TCL_OK);
    }

    /* Perform the multiplication. */

    for (i = 0; i < resultPtr->order; i++) {
	src_idx[i] = 0;
    }

    for (;;) {
	k = 0;
	for (i = 0; i < 2; i++) {
	    for (j = 0; j < tensorPtrArray[i]->order; j++) {
		op_idx[i][j] = src_idx[k];
		k++;
	    }
	}

	for (j = 0; j < 2; j++) {
	    el = Tensor_GetElemPtr(tensorPtrArray[j], op_idx[j]);
	    op_d[j] = Tensor_GetElemValue(el, tensorPtrArray[j]->type);
	}

	el = Tensor_GetElemPtr(resultPtr, src_idx);
	Tensor_SetElemValue(el, resultPtr->type, op_d[0] * op_d[1]);

	/* Update indices. */

	for (i = resultPtr->order - 1; i >= 0; i--) {
	    if (src_idx[i] < resultPtr->dims[i] - 1) {
		(src_idx[i])++;
		break;
	    }
	    src_idx[i] = 0;
	}

	if (i < 0) {
	    break;
	}
    }

    return (TCL_OK);
}


/*
 *---------------------------------------------------------------
 *
 * TensorFlipIndices --
 *
 *      inverts the indexing order of a tensor for
 *	specified dimensions, i.e. what used to be
 *	stored at index 0 will be stored at index D-1,
 *	and vice-versa. (D is the extent of the tensor
 *	in the specified dimension.)
 *
 * Results:
 *      returns a standard TCL result.
 *
 * Side effects:
 *      The tensor's data storage is rearranged.
 *
 *---------------------------------------------------------------
 */


int 
TensorFlipIndices(
    Tcl_Interp *interp,		/* For error messages		*/
    Tensor_Descrip *tensorPtr,	/* Tensor we're gonna flip	*/
    Tensor_Index idxList,	/* List of indices to flip	*/
    int nIndices)		/* # of indices in list		*/
{
    Tensor_Index src_idx, dest_idx;
    Tensor_Index flip_index;
    Tensor_Descrip destTensor;
    int i;
    char junkstr[32];
    Tcl_Obj *result;

    VOID *src_el_ptr, *dest_el_ptr;

    /* Make sure everything in "idxList" is in range and not duplicated. */

    if (nIndices > tensorPtr->order) {
	Tcl_SetObjResult(interp, Tcl_NewStringObj(
		"number of flipped indices exceeds tensor order", -1));
	return (TCL_ERROR);
    }
    for (i = 0; i < tensorPtr->order; i++) {
	flip_index[i] = 0;
    }

    for (i = 0; i < nIndices; i++) {
	if (idxList[i] < 0 || idxList[i] >= tensorPtr->order) {
	    Tcl_SetObjResult(interp, Tcl_NewStringObj(
			  "indices to be flipped must be >= 0 and less than the tensor order",
			  -1));
	    return (TCL_ERROR);
	}
	if (flip_index[idxList[i]]) {
	    sprintf(junkstr, "%1d", idxList[i]);
	    Tcl_ResetResult(interp);
	    result = Tcl_NewStringObj("Index ", -1);
	    Tcl_AppendObjToObj(result, Tcl_NewIntObj(idxList[i]));
	    Tcl_AppendToObj(result,
		" is repeated in list of indices to be flipped", -1);
	    Tcl_SetObjResult(interp, result);
	    return (TCL_ERROR);
	}
	flip_index[idxList[i]] = 1;
    }

    /* If there's no data, skip out. */

    if(tensorPtr->data == (VOID *) NULL) {
	return(TCL_OK);
    }

    /* Allocate storage for flipped tensor. */

    destTensor.type = tensorPtr->type;
    destTensor.order = tensorPtr->order;
    for (i = 0; i < destTensor.order; i++) {
	destTensor.dims[i] = tensorPtr->dims[i];
    }
    if (Tensor_AllocData(interp, &destTensor) != TCL_OK) {
	return (TCL_ERROR);
    }

    /* Copy with indices flipped. */

    for (i = 0; i < destTensor.order; i++) {
	src_idx[i] = 0;
	if (flip_index[i]) {
	    dest_idx[i] = destTensor.dims[i] - 1;
	} else {
	    dest_idx[i] = 0;
	}
    }

    for (;;) {
	src_el_ptr = Tensor_GetElemPtr(tensorPtr, src_idx);
	dest_el_ptr = Tensor_GetElemPtr(&destTensor, dest_idx);

	switch (destTensor.type) {
	    case TENSOR_DOUBLE:
		*((double *) dest_el_ptr) = *((double *) src_el_ptr);
		break;

	    case TENSOR_FLOAT:
		*((float *) dest_el_ptr) = *((float *) src_el_ptr);
		break;

	    case TENSOR_INT:
		*((int *) dest_el_ptr) = *((int *) src_el_ptr);
		break;

	    case TENSOR_BYTE:
		*((unsigned char *) dest_el_ptr) = *((unsigned char *) src_el_ptr);
		break;

	    case TENSOR_SHORT:
		*((unsigned short *) dest_el_ptr) = *((unsigned short *) src_el_ptr);
		break;

	    case TENSOR_UNSIGNED:
		*((unsigned int *) dest_el_ptr) = *((unsigned int *) src_el_ptr);
		break;

	}

	/* Update indices. */

	for (i = destTensor.order - 1; i >= 0; i--) {
	    if (src_idx[i] < destTensor.dims[i] - 1) {
		(src_idx[i])++;
		if (flip_index[i]) {
		    (dest_idx[i])--;
		} else {
		    dest_idx[i] = src_idx[i];
		}
		break;
	    }
	    src_idx[i] = 0;
	    if (flip_index[i]) {
		dest_idx[i] = destTensor.dims[i] - 1;
	    } else {
		dest_idx[i] = 0;
	    }
	}

	if (i < 0) {
	    break;
	}
    }

    /* Clean up and exit. */

    Tensor_FreeData(tensorPtr);
    tensorPtr->type = destTensor.type;
    tensorPtr->order = destTensor.order;
    for (i = 0; i < destTensor.order; i++) {
	tensorPtr->dims[i] = destTensor.dims[i];
    }
    tensorPtr->data = destTensor.data;

    return (TCL_OK);
}

/*
 *---------------------------------------------------------------
 *
 * TensorPermuteIndices --
 *
 *      permutes the order of the indices for a tensor,
 *	as specified by an index list. For example, specifying
 *	an index list of {1 0} will make the new index 0
 *	be the same as the old index 1, and will make the
 *	new index 1 be the same as the old index 0, i.e.
 *	it does a matrix transpose.
 *
 * Results:
 *      returns a standard TCL result.
 *
 * Side effects:
 *      The tensor's data storage is rearranged.
 *
 *---------------------------------------------------------------
 */

int 
TensorPermuteIndices(
    Tcl_Interp *interp,		/* For error messages		*/
    Tensor_Descrip *tensorPtr,	/* Tensor whose indices
				 * we'll permute		*/
    Tensor_Index idxList,	/* List of indices to permute	*/
    int nIndices)		/* # of indices in list	- must
				 * be equal to tensor order	*/
{
    Tensor_Index src_idx, dest_idx;
    Tensor_Index found_index;
    Tensor_Index zero_index, last_src;
    Tensor_Descrip destTensor;
    int i, advanced;
    Tcl_Obj *result;
    VOID *src_el_ptr, *dest_el_ptr;

    /* Make sure everything in "idxList" is in range and not duplicated. */

    if (nIndices != tensorPtr->order) {
	Tcl_SetObjResult(interp, Tcl_NewStringObj(
		      "length of list of permuted indices must equal tensor order", -1));
	return (TCL_ERROR);
    }
    for (i = 0; i < nIndices; i++) {
	found_index[i] = 0;
    }

    for (i = 0; i < nIndices; i++) {
	if (idxList[i] < 0 || idxList[i] >= tensorPtr->order) {
	    Tcl_SetObjResult(interp, Tcl_NewStringObj(
			  "indices in permutation list must be >= 0 and less than the tensor order",
			  -1));
	    return (TCL_ERROR);
	}
	if (found_index[idxList[i]]) {
	    result = Tcl_NewStringObj("Index ", -1);
	    Tcl_AppendObjToObj(result, Tcl_NewIntObj(idxList[i]));
	    Tcl_AppendToObj(result,
		" is repeated in list of indices to be flipped", -1);
	    Tcl_SetObjResult(interp, result);
	    return (TCL_ERROR);
	}
	found_index[idxList[i]] = 1;
    }

    /*
     * If there's no data, just permute the dimension
     * list and return.
     */

    if(tensorPtr->data == (VOID *) NULL) {
	for (i = 0; i < nIndices; i++) {
	    destTensor.dims[i] = tensorPtr->dims[idxList[i]];
	}

	for (i = 0; i < nIndices; i++) {
	    tensorPtr->dims[i] = destTensor.dims[i];
	}

	return(TCL_OK);
    }

    /* Allocate storage for permuted tensor. */

    destTensor.type = tensorPtr->type;
    destTensor.order = tensorPtr->order;
    for (i = 0; i < destTensor.order; i++) {
	destTensor.dims[i] = tensorPtr->dims[idxList[i]];
    }
    destTensor.data = NULL;

    if (Tensor_AllocData(interp, &destTensor) != TCL_OK) {
	return (TCL_ERROR);
    }

    /* Copy with indices permuted. */

    for (i = 0; i < destTensor.order; i++) {
	src_idx[i] = 0;
	dest_idx[i] = 0;
	zero_index[i] = 0;
	last_src[i] = tensorPtr->dims[i] - 1;
    }

    for (;;) {
	src_el_ptr = Tensor_GetElemPtr(tensorPtr, src_idx);
	dest_el_ptr = Tensor_GetElemPtr(&destTensor, dest_idx);

	switch (destTensor.type) {
	    case TENSOR_DOUBLE:
		*((double *) dest_el_ptr) = *((double *) src_el_ptr);
		break;

	    case TENSOR_FLOAT:
		*((float *) dest_el_ptr) = *((float *) src_el_ptr);
		break;

	    case TENSOR_INT:
		*((int *) dest_el_ptr) = *((int *) src_el_ptr);
		break;

	    case TENSOR_BYTE:
		*((unsigned char *) dest_el_ptr) = *((unsigned char *) src_el_ptr);
		break;

	    case TENSOR_SHORT:
		*((unsigned short *) dest_el_ptr) = *((unsigned short *) src_el_ptr);
		break;

	    case TENSOR_UNSIGNED:
		*((unsigned int *) dest_el_ptr) = *((unsigned int *) src_el_ptr);
		break;

	}

	/* Update indices. */

	advanced = Tensor_NextIndex(tensorPtr->order, zero_index, last_src, src_idx);
	for (i = 0; i < destTensor.order; i++) {
	    dest_idx[i] = src_idx[idxList[i]];
	}

	if (!advanced) {
	    break;
	}
    }

    /* Clean up and exit. */

    Tensor_FreeData(tensorPtr);
    tensorPtr->type = destTensor.type;
    tensorPtr->order = destTensor.order;
    for (i = 0; i < nIndices; i++) {
	tensorPtr->dims[i] = destTensor.dims[i];
    }
    tensorPtr->data = destTensor.data;

    return (TCL_OK);
}

/*
 *---------------------------------------------------------------
 *
 * TensorCmpScalar --
 *
 *      compares selected elements of a tensor with a scalar.
 *	If all specified elements of the tensor satisfy the
 *	specified condition, then the function returns "1",
 *	otherwise it returns "0". (If there's no data to compare,
 *	it returns "1" also.)
 *
 * Results:
 *      returns a standard TCL result.
 *
 * Side effects:
 *      None
 *
 *---------------------------------------------------------------
 */


int 
TensorCmpScalar(
    Tcl_Interp *interp,		/* Result returned here		*/
    Tensor_Descrip *tensorPtr,	/* Tensor to compare		*/
    Tensor_Index cmpLowIndices,	/* Low indices of section	*/
    Tensor_Index cmpHighIndices,/* High indices of section	*/
    int op,			/* Operation: '<', '=', '>',
				 * 'l' (for <=) 'g' (for >=)
				 * or '!' (for !=)		*/
    double s)			/* Number to compare to		*/
{
    int i, bool_result;
    VOID *cmp_el;
    Tensor_Index cmp_index;
    double d;

    /* If no data, just return "1". */

    if(tensorPtr->data == (VOID *) NULL) {
	Tcl_SetObjResult(interp, Tcl_NewBooleanObj(1));
	return(TCL_OK);
    }

    for (i = 0; i < tensorPtr->order; i++) {
	if(cmpLowIndices[i] > cmpHighIndices[i]) {
	    Tcl_SetObjResult(interp,Tcl_NewBooleanObj(1));
	    return(TCL_OK);
	}
    }

    /* Compare each tensor element. */

    for (i = 0; i < tensorPtr->order; i++) {
	cmp_index[i] = cmpLowIndices[i];
    }

    bool_result = 1;
    do {
	/* Get tensor element. */

	cmp_el = Tensor_GetElemPtr(tensorPtr, cmp_index);
	d = Tensor_GetElemValue(cmp_el, tensorPtr->type);

	switch (op) {
	    case '<':
		bool_result = (d < s);
		break;

	    case 'l':
		bool_result = (d <= s);
		break;

	    case '=':
		bool_result = (d == s);
		break;

	    case 'g':
		bool_result = (d >= s);
		break;

	    case '>':
		bool_result = (d > s);
		break;

	    case '!':
		bool_result = (d != s);
		break;

	}

	/* Return if condition not satisfied. */

	if (!bool_result) {
	    Tcl_SetObjResult(interp, Tcl_NewBooleanObj(0));
	    return (TCL_OK);
	}

    } while(Tensor_NextIndex(tensorPtr->order, cmpLowIndices, cmpHighIndices, cmp_index));

    if (bool_result) {
	Tcl_SetObjResult(interp, Tcl_NewBooleanObj(1));
    } else {
	Tcl_SetObjResult(interp, Tcl_NewBooleanObj(0));
    }

    return (TCL_OK);
}


/*
 *---------------------------------------------------------------
 *
 * TensorCmpTensor --
 *
 *      compares selected elements of a tensor with selected
 *	elements of another tensor. If all corresponding
 *	elements of the tensors satisfy the specified condition,
 *	then the function returns "1", otherwise it returns "0".
 *
 * Results:
 *      returns a standard TCL result.
 *
 * Side effects:
 *      None
 *
 *---------------------------------------------------------------
 */

int 
TensorCmpTensor(
    Tcl_Interp *interp,		/* Result goes here		*/
    Tensor_Descrip *firstTensorPtr,/* First tensor		*/
    Tensor_Index firstLowIndices,/* Low indices of section	*/
    Tensor_Index firstHighIndices,/* High indices of section	*/
    int op,			/* Operation - same as for
				 * TensorCmpScalar	*/
    Tensor_Descrip *secondTensorPtr,/*Second tensor		*/
    Tensor_Index secodLowIndices,/* Low indices of section of
				 * second tensor		*/
    Tensor_Index secondHighIndices)/* High indices of section	*/
{
    int i, bool_result;
    VOID *second_el, *first_el;
    int first_order, second_order;
    Tensor_Index first_index, second_index, index_map;
    Tcl_Obj *result;
    double d, s;

    /* Make sure our indices are OK. */

    TensorSectionDims(firstTensorPtr->order,
	    firstLowIndices, firstHighIndices,
	    &first_order, first_index, index_map);
    TensorSectionDims(secondTensorPtr->order,
	    secodLowIndices, secondHighIndices,
	    &second_order, second_index, index_map);

    if (first_order != second_order) {
	result = Tcl_NewStringObj("tensor section order (", -1);
	Tcl_AppendObjToObj(result, Tcl_NewIntObj(first_order));
	Tcl_AppendToObj(result,
		") does not match order of tensor being compared to (", -1);
	Tcl_AppendObjToObj(result, Tcl_NewIntObj(second_order));
	Tcl_AppendToObj(result, ")", -1);
	Tcl_SetObjResult(interp, result);
	return (TCL_ERROR);
    }
    for (i = 0; i < first_order; i++) {
	if (first_index[i] != second_index[i]) {
	    result = Tcl_NewStringObj("dimension of index ", -1);
	    Tcl_AppendObjToObj(result, Tcl_NewIntObj(i));
	    Tcl_AppendToObj(result, " of tensor section (=", -1);
	    Tcl_AppendObjToObj(result, Tcl_NewIntObj(first_index[i]));
	    Tcl_AppendToObj(result,
		" ) is not equal to corresponding dimension of tensor section being compared to (=", -1);
	    Tcl_AppendObjToObj(result, Tcl_NewIntObj(second_index[i]));
	    Tcl_AppendToObj(result, ")", -1);
	    Tcl_SetObjResult(interp, result);

	    return (TCL_ERROR);
	}
    }

    /* If no data, just return "1". */

    if(firstTensorPtr->data == (VOID *) NULL
	    || secondTensorPtr->data == (VOID *) NULL) {
	Tcl_SetObjResult(interp, Tcl_NewBooleanObj(1));
	return(TCL_OK);
    }

    for (i = 0; i < firstTensorPtr->order; i++) {
	if(firstLowIndices[i] > firstHighIndices[i]) {
	    Tcl_SetObjResult(interp, Tcl_NewBooleanObj(1));
	    return(TCL_OK);
	}
    }

    /* Compare the tensor data. */

    for (i = 0; i < secondTensorPtr->order; i++) {
	second_index[i] = secodLowIndices[i];
    }
    for (i = 0; i < firstTensorPtr->order; i++) {
	first_index[i] = firstLowIndices[i];
    }

    bool_result = 1;
    for (;;) {
	/* Copy tensor elemnts. */

	second_el = Tensor_GetElemPtr(secondTensorPtr, second_index);
	first_el = Tensor_GetElemPtr(firstTensorPtr, first_index);

	d = Tensor_GetElemValue(first_el, firstTensorPtr->type);
	s = Tensor_GetElemValue(second_el, secondTensorPtr->type);

	switch (op) {
	    case '<':
		bool_result = (d < s);
		break;

	    case 'l':
		bool_result = (d <= s);
		break;

	    case '=':
		bool_result = (d == s);
		break;

	    case 'g':
		bool_result = (d >= s);
		break;

	    case '>':
		bool_result = (d > s);
		break;

	    case '!':
		bool_result = (d != s);
		break;

	}

	/* Return if condition not satisfied. */

	if (!bool_result) {
	    Tcl_SetObjResult(interp, Tcl_NewBooleanObj(0));
	    return (TCL_OK);
	}

	/* Update indices, exit if done. */

	for (i = secondTensorPtr->order - 1; i >= 0; i--) {
	    if (second_index[i] < secondHighIndices[i]) {
		(second_index[i])++;
		break;
	    }
	    second_index[i] = secodLowIndices[i];
	}

	if (i < 0) {
	    break;
	}

	for (i = firstTensorPtr->order - 1; i >= 0; i--) {
	    if (first_index[i] < firstHighIndices[i]) {
		(first_index[i])++;
		break;
	    }
	    first_index[i] = firstLowIndices[i];
	}

    }

    Tcl_SetObjResult(interp, Tcl_NewBooleanObj(bool_result));

    return (TCL_OK);
}

/*
 *---------------------------------------------------------------
 *
 * AppendIndex --
 *
 *      Appends a tensor index onto a dynamic string. The
 *	string will be a list of lists; each index is
 *	represented as a sublist of the returned string.
 *
 * Results:
 *      None
 *
 * Side effects:
 *      None
 *
 *---------------------------------------------------------------
 */

static void
AppendIndex(
    Tcl_DString *dsPtr,		/* Dynamic string to append to	*/
    Tensor_Index cmp_index,	/* Index to append		*/
    int *componentList,		/* List of components to append	*/
    int nComponents)		/* Length of component list	*/
{
    int i;
    char junkStr[32];

    if (nComponents > 1) {
	Tcl_DStringStartSublist(dsPtr);
    }
    for(i = 0; i < nComponents; i++) {
	sprintf(junkStr, "%1d", cmp_index[componentList[i]]);
	Tcl_DStringAppendElement(dsPtr, junkStr);
    }
    if (nComponents > 1) {
	Tcl_DStringEndSublist(dsPtr);
    }
}


/*
 *---------------------------------------------------------------
 *
 * TensorListIndicesScalar --
 *
 *      compares selected elements of a tensor with a scalar,
 *	and returns a list of all the tensor indices that
 *	satisfy the selected inequality. The "componentList"
 *	argument indicates which components of the index to
 *	put in the result, and what order to write them in.
 *
 * Results:
 *      returns a standard TCL result.
 *
 * Side effects:
 *      None
 *
 *---------------------------------------------------------------
 */


int 
TensorListIndicesScalar(
    Tcl_Interp *interp,		/* Result returned here		*/
    Tensor_Descrip *tensorPtr,	/* Tensor to compare		*/
    Tensor_Index cmpLowIndices,	/* Low indices of section	*/
    Tensor_Index cmpHighIndices,/* High indices of section	*/
    int *componentList,		/* List of index components
				 * to return			*/
    int nComponents,		/* # of components in
				 * componentList		*/
    int op,			/* Operation: '<', '=', '>',
				 * 'l' (for <=) 'g' (for >=)
				 * or '!' (for !=)		*/
    double s)			/* Number to compare to		*/
{
    int i, bool_result;
    VOID *cmp_el;
    Tensor_Index cmp_index;
    double d;
    Tcl_DString dstr;

    /* If no data, just return an empty list. */

    if(tensorPtr->data == (VOID *) NULL) {
	Tcl_SetObjResult(interp, Tcl_NewObj());
	return(TCL_OK);
    }

    for (i = 0; i < tensorPtr->order; i++) {
	if(cmpLowIndices[i] > cmpHighIndices[i]) {
	    Tcl_SetObjResult(interp, Tcl_NewObj());
	    return(TCL_OK);
	}
    }

    /* Check the component list. */

    for(i = 0; i < nComponents; i++) {
	if(componentList[i] < 0 || componentList[i] >= tensorPtr->order) {
	    Tcl_SetObjResult(interp, Tcl_NewStringObj(
			"tensor index component number out of range", -1));
	    return TCL_ERROR;
	}
    }

    /* Compare each tensor element. */

    for (i = 0; i < tensorPtr->order; i++) {
	cmp_index[i] = cmpLowIndices[i];
    }

    Tcl_DStringInit(&dstr);
    bool_result = 1;
    do {
	/* Get tensor element. */

	cmp_el = Tensor_GetElemPtr(tensorPtr, cmp_index);
	d = Tensor_GetElemValue(cmp_el, tensorPtr->type);

	switch (op) {
	    case '<':
		bool_result = (d < s);
		break;

	    case 'l':
		bool_result = (d <= s);
		break;

	    case '=':
		bool_result = (d == s);
		break;

	    case 'g':
		bool_result = (d >= s);
		break;

	    case '>':
		bool_result = (d > s);
		break;

	    case '!':
		bool_result = (d != s);
		break;

	}

	/* Append the index if the condition is satisfied. */

	if (bool_result) {
	    AppendIndex(&dstr, cmp_index, componentList, nComponents);
	}

    } while(Tensor_NextIndex(tensorPtr->order, cmpLowIndices, cmpHighIndices, cmp_index));

    Tcl_DStringResult(interp, &dstr);
    return (TCL_OK);
}


/*
 *---------------------------------------------------------------
 *
 * TensorListIndicesTensor --
 *
 *      compares selected elements of a tensor with selected
 *	elements of another tensor, and returns a list of all
 *	the tensor indices that satisfy the selected inequality.
 *	The "componentList" argument indicates which components
 *	of the index to put in the result, and what order to
 *	write them in.
 *
 * Results:
 *      returns a standard TCL result.
 *
 * Side effects:
 *      None
 *
 *---------------------------------------------------------------
 */

int 
TensorListIndicesTensor(
    Tcl_Interp *interp,		/* Result goes here		*/
    Tensor_Descrip *firstTensorPtr,/* First tensor		*/
    Tensor_Index firstLowIndices,/* Low indices of section	*/
    Tensor_Index firstHighIndices,/* High indices of section	*/
    int *componentList,		/* List of index components to
				 * include in the result	*/
    int nComponents,		/* Length of component list	*/
    int op,			/* Operation - same as for
				 * TensorCmpScalar	*/
    Tensor_Descrip *secondTensorPtr,/*Second tensor		*/
    Tensor_Index secodLowIndices,/* Low indices of section of
				 * second tensor		*/
    Tensor_Index secondHighIndices)/* High indices of section	*/
{
    int i, bool_result;
    VOID *second_el, *first_el;
    int first_order, second_order;
    Tensor_Index first_index, second_index, index_map;
    Tcl_Obj *result;
    double d, s;
    Tcl_DString dstr;

    /* Make sure our indices are OK. */

    TensorSectionDims(firstTensorPtr->order,
	    firstLowIndices, firstHighIndices,
	    &first_order, first_index, index_map);
    TensorSectionDims(secondTensorPtr->order,
	    secodLowIndices, secondHighIndices,
	    &second_order, second_index, index_map);

    if (first_order != second_order) {
	result = Tcl_NewStringObj("tensor section order (", -1);
	Tcl_AppendObjToObj(result, Tcl_NewIntObj(first_order));
	Tcl_AppendToObj(result, ") does not match order of tensor being compared to (", -1);
	Tcl_AppendObjToObj(result, Tcl_NewIntObj(second_order));
	Tcl_AppendToObj(result, ")", -1);
	Tcl_SetObjResult(interp, result);

	return (TCL_ERROR);
    }
    for (i = 0; i < first_order; i++) {
	if (first_index[i] != second_index[i]) {
	    result = Tcl_NewStringObj("dimension of index ", -1);
	    Tcl_AppendObjToObj(result, Tcl_NewIntObj(i));
	    Tcl_AppendToObj(result, ") of tensor section (=", -1);
	    Tcl_AppendObjToObj(result, Tcl_NewIntObj(first_index[i]));
	    Tcl_AppendToObj(result, ") is not equal to corresponding dimension of tensor section being compared to (=", -1);
	    Tcl_AppendObjToObj(result, Tcl_NewIntObj(second_index[i]));
	    Tcl_AppendToObj(result, ")", -1);
	    Tcl_SetObjResult(interp, result);

	    return (TCL_ERROR);
	}
    }

    /* If no data, just return "". */

    if(firstTensorPtr->data == (VOID *) NULL
	    || secondTensorPtr->data == (VOID *) NULL) {
	Tcl_SetObjResult(interp, Tcl_NewObj());
	return(TCL_OK);
    }

    for (i = 0; i < firstTensorPtr->order; i++) {
	if(firstLowIndices[i] > firstHighIndices[i]) {
	    Tcl_SetObjResult(interp, Tcl_NewObj());
	    return(TCL_OK);
	}
    }

    /* Check the component list. */

    for(i = 0; i < nComponents; i++) {
	if(componentList[i] < 0 || componentList[i] >= firstTensorPtr->order) {
	    Tcl_SetObjResult(interp, Tcl_NewStringObj(
			"tensor index component number out of range", -1));
	    return TCL_ERROR;
	}
    }

    /* Compare the tensor data. */

    for (i = 0; i < secondTensorPtr->order; i++) {
	second_index[i] = secodLowIndices[i];
    }
    for (i = 0; i < firstTensorPtr->order; i++) {
	first_index[i] = firstLowIndices[i];
    }

    Tcl_DStringInit(&dstr);
    bool_result = 1;
    for (;;) {
	/* Copy tensor elemnts. */

	second_el = Tensor_GetElemPtr(secondTensorPtr, second_index);
	first_el = Tensor_GetElemPtr(firstTensorPtr, first_index);

	d = Tensor_GetElemValue(first_el, firstTensorPtr->type);
	s = Tensor_GetElemValue(second_el, secondTensorPtr->type);

	switch (op) {
	    case '<':
		bool_result = (d < s);
		break;

	    case 'l':
		bool_result = (d <= s);
		break;

	    case '=':
		bool_result = (d == s);
		break;

	    case 'g':
		bool_result = (d >= s);
		break;

	    case '>':
		bool_result = (d > s);
		break;

	    case '!':
		bool_result = (d != s);
		break;

	}

	/* Append index if condition is satisfied. */

	if (bool_result) {
	    AppendIndex(&dstr, first_index, componentList, nComponents);
	}

	/* Update indices, exit if done. */

	for (i = secondTensorPtr->order - 1; i >= 0; i--) {
	    if (second_index[i] < secondHighIndices[i]) {
		(second_index[i])++;
		break;
	    }
	    second_index[i] = secodLowIndices[i];
	}

	if (i < 0) {
	    break;
	}

	for (i = firstTensorPtr->order - 1; i >= 0; i--) {
	    if (first_index[i] < firstHighIndices[i]) {
		(first_index[i])++;
		break;
	    }
	    first_index[i] = firstLowIndices[i];
	}

    }

    Tcl_DStringResult(interp, &dstr);
    return (TCL_OK);
}



/*
 *----------------------------------------------------------------------
 *
 * SetResultToTwoIndices --
 *
 *	SetResultToTwoIndices sets the interpreter's result
 *	string to a list containing two tensor indices.
 *
 * Results:
 *	None.
 *
 * Side effects:
 *	The interpreter's result string is set.
 *
 *----------------------------------------------------------------------
 */

static void
SetResultToTwoIndices(
    Tcl_Interp *interp,	/* Result goes here	*/
    Tensor_Index idx1,	/* First index		*/
    Tensor_Index idx2,	/* Second index		*/
    int order)		/* # of items in index	*/
{
    char junkstr[64];
    Tcl_DString ds;
    int i;

    Tcl_DStringInit(&ds);
    Tcl_DStringStartSublist(&ds);
    for(i = 0; i < order; i++) {
	sprintf(junkstr, "%1d", idx1[i]);
	Tcl_DStringAppendElement(&ds,junkstr);
    }
    Tcl_DStringEndSublist(&ds);
    Tcl_DStringStartSublist(&ds);
    for(i = 0; i < order; i++) {
	sprintf(junkstr, "%1d", idx2[i]);
	Tcl_DStringAppendElement(&ds,junkstr);
    }
    Tcl_DStringEndSublist(&ds);
    Tcl_DStringResult(interp,&ds);
    Tcl_DStringFree(&ds);
}


/*
 *---------------------------------------------------------------
 *
 * TensorMinMax --
 *
 *      finds the minimum and maximum values in a
 *	section of a tensor, and/or their locations.
 *
 * Results:
 *      returns a standard TCL result.
 *
 * Side effects:
 *      The min. and max. values (or their locations in the
 *	tensor) are written (as a two-element Tcl list) into
 *	the interpreter's result string
 *
 *---------------------------------------------------------------
 */

int 
TensorMinMax(
    Tcl_Interp *interp,		/* Results go here		*/
    Tensor_Descrip *tensor,	/* Tensor we'll find min/max of	*/
    Tensor_Index low_indices,	/* Low indices of section	*/
    Tensor_Index high_indices,	/* High indices of section	*/
    int getIndices)		/* 0 means report values, non-
				 * zero means report indices.	*/
{
    int i;
    double d, minval, maxval;
    VOID *elptr;
    Tensor_Index index;
    Tensor_Index minIndex, maxIndex;
    int no_data;
    Tcl_Obj *result;

    /* If there's no data, return an appropriate result. */

    no_data = 0;

    for (i = 0; i < tensor->order; i++) {
	if(low_indices[i] > high_indices[i]) {
	    no_data = 1;
	    break;
	}
    }
    if(tensor->data == (VOID *) NULL) {
	no_data = 1;
    }

    if(no_data) {
	if(!getIndices) {
	    result = Tcl_NewObj();
	    Tcl_ListObjAppendElement(NULL, result, Tcl_NewDoubleObj(1.0));
	    Tcl_ListObjAppendElement(NULL, result, Tcl_NewDoubleObj(0.0));
	    Tcl_SetObjResult(interp, result);
	    return(TCL_OK);
	}

	for (i = 0; i < tensor->order; i++) {
	    minIndex[i] = -1;
	}
	SetResultToTwoIndices(interp,minIndex,minIndex,tensor->order);
	return(TCL_OK);
    }

    /* Find the min. and max. */

    for (i = 0; i < tensor->order; i++) {
	minIndex[i] = maxIndex[i] = index[i] = low_indices[i];
    }

    elptr = Tensor_GetElemPtr(tensor, index);
    minval = Tensor_GetElemValue(elptr, tensor->type);
    maxval = minval;

    do {
	/* Get tensor element. */

	elptr = Tensor_GetElemPtr(tensor, index);
	d = Tensor_GetElemValue(elptr, tensor->type);

	if (d > maxval) {
	    maxval = d;
	    for(i = 0; i < tensor->order; i++) {
		maxIndex[i] = index[i];
	    }
	}
	if (d < minval) {
	    minval = d;
	    for(i = 0; i < tensor->order; i++) {
		minIndex[i] = index[i];
	    }
	}

    } while(Tensor_NextIndex(tensor->order, low_indices, high_indices, index));

    /* Set the result string. */

    if(getIndices) {
	SetResultToTwoIndices(interp,minIndex,maxIndex,tensor->order);
    } else {
	result = Tcl_NewObj();
	Tcl_ListObjAppendElement(NULL, result, Tcl_NewDoubleObj(minval));
	Tcl_ListObjAppendElement(NULL, result, Tcl_NewDoubleObj(maxval));
	Tcl_SetObjResult(interp, result);
    }

    return (TCL_OK);
}

/*
 * Type FuncTransTableEntry defines an entry in a table that
 * translates a (string) function name to a function pointer.
 */

typedef struct {
    char *name;
    Tensor_DoubleFunc func;
} FuncTransTableEntry;

/*
 * defApplyFuncs is a table of default math functions that we'll
 * allways define for the "apply" command.
 */

static FuncTransTableEntry defApplyFuncs[] = {
    {"sin", sin},
    {"cos", cos},
    {"tan", tan},
    {"asin", asin},
    {"acos", acos},
    {"atan", atan},
    {"sinh", sinh},
    {"cosh", cosh},
    {"tanh", tanh},
    /*{"asinh", asinh},*/	/* Windows doesn't have this...	*/
    /*{"acosh", acosh},*/	/* ...or this...		*/
    /*{"atanh", atanh},*/	/* ...or this.			*/
    {"sqrt", sqrt},
    {"exp", exp},
    {"log", log},
    {"log10", log10},
    {"floor", floor},
    /*{"ceil", ceil},*/		/* Solaris doesn't have this...	*/
    /*{"trunc", trunc},*/	/* ...or this.			*/
    {"fabs", fabs},
    {NULL, NULL}
};

/*
 * funcTransTable is a hash table for translating from a function
 * name to a function pointer; funcTransTableInitialized is a
 * boolean that indicates whether or not the hash table has been
 * initialized. funcTransTableDefaultsAdded is a boolean indicating
 * whether or not the default functions have been added to the
 * hash table.
 */

static Tcl_HashTable funcTransTable;
static int funcTransTableInitialized = 0;
static int funcTransTableDefaultsAdded = 0;


/*
 *----------------------------------------------------------------------
 *
 * AddApplyFunc --
 *
 *	AddApplyFunc adds an entry to the function mapping table
 *	used by the tensor "apply" command. It assumes that the
 *	hash table has been initialized.
 *
 * Results:
 *	None.
 *
 * Side effects:
 *	A hash table enrty may be created in funcTransTable, and the
 *	value of the entry is modified.
 *
 *----------------------------------------------------------------------
 */

static void
AddApplyFunc(char *funcName, Tensor_DoubleFunc funcPtr)
{
    Tcl_HashEntry *e;
    int junk;

    e = Tcl_CreateHashEntry(&funcTransTable, funcName, &junk);
    Tcl_SetHashValue(e, funcPtr);
}


/*
 *----------------------------------------------------------------------
 *
 * AddApplyFuncDefaults --
 *
 *	AddApplyFuncDefaults adds the "default" functions to the
 *	tensor "apply" function mapping hash table (if this hasn't
 *	already been done).
 *
 * Results:
 *	None.
 *
 * Side effects:
 *	FUnction mappings get added the the hash table.
 *
 *----------------------------------------------------------------------
 */

static void
AddApplyFuncDefaults()
{
    int i;

    if (funcTransTableDefaultsAdded) {
	return;
    }

    if (!funcTransTableInitialized) {
	Tcl_InitHashTable(&funcTransTable, TCL_STRING_KEYS);
    }

    for(i = 0; defApplyFuncs[i].name != NULL; i++) {
	AddApplyFunc(defApplyFuncs[i].name,defApplyFuncs[i].func);
    }

    funcTransTableDefaultsAdded = 1;
}


/*
 *----------------------------------------------------------------------
 *
 * Tensor_AddApplyFunc --
 *
 *	Tensor_AddApplyFunc adds a name/function pair to the tensor
 *	"apply" function mapping table.
 *
 * Results:
 *	None.
 *
 * Side effects:
 *	An entry in the hash table gets added or changed.
 *
 *----------------------------------------------------------------------
 */

void
Tensor_AddApplyFunc(char *funcName, Tensor_DoubleFunc funcPtr)
{
    if (!funcTransTableInitialized) {
	Tcl_InitHashTable(&funcTransTable, TCL_STRING_KEYS);
    }

    if (!funcTransTableDefaultsAdded) {
	AddApplyFuncDefaults();
    }

    AddApplyFunc(funcName, funcPtr);
}


/*
 *----------------------------------------------------------------------
 *
 * MapNameToFunc --
 *
 *	MapNameToFunc maps a function name to a function pointer
 *	so that the function can be applied to a tensor.
 *
 * Results:
 *	Returns a function pointer.
 *
 * Side effects:
 *	None.
 *
 *----------------------------------------------------------------------
 */

static Tensor_DoubleFunc
MapNameToFunc(char *name)	/* Name that we map to a function pointer */
{
    Tcl_HashEntry *e;

    e = Tcl_FindHashEntry(&funcTransTable, name);
    if (e == (Tcl_HashEntry *) NULL) {
	return ((Tensor_DoubleFunc) NULL);
    }

    return ((Tensor_DoubleFunc) Tcl_GetHashValue(e));
}


/*
 *----------------------------------------------------------------------
 *
 * TensorApplyFunc --
 *
 *	TensorApplyFunc applies a given function to a section
 *	of a tensor.
 *
 * Results:
 *	Returns a standard Tcl result.
 *
 * Side effects:
 *	None.
 *
 *----------------------------------------------------------------------
 */

int 
TensorApplyFunc(
    Tcl_Interp *interp,		/* Results go here			*/
    Tensor_Descrip *tensorPtr,	/* Tensor we'll apply function to	*/
    Tensor_Index lowIndices,	/* Low indices of section		*/
    Tensor_Index highIndices,	/* High indices of section		*/
    char *funcName)		/* Name of function to apply		*/
{
    int i;
    double d;
    VOID *elptr;
    Tensor_Index index;
    int no_data;
    Tensor_DoubleFunc func;
    Tcl_Obj *result;

    /* If there's no data, we don't do anything. */

    no_data = 0;

    for (i = 0; i < tensorPtr->order; i++) {
	if(lowIndices[i] > highIndices[i]) {
	    no_data = 1;
	    break;
	}
    }

    if(tensorPtr->data == (VOID *) NULL) {
	no_data = 1;
    }

    if(no_data) {
	return(TCL_OK);
    }

    /* Make sure everything's properly initialized. */

    AddApplyFuncDefaults();

    /* Look up the function. */

    func = MapNameToFunc(funcName);
    if (func == (Tensor_DoubleFunc) NULL) {
	result = Tcl_NewStringObj("unknown function \"", -1);
	Tcl_AppendToObj(result, funcName, -1);
	Tcl_AppendToObj(result, "\" in tensor apply", -1);
	Tcl_SetObjResult(interp, result);
	return(TCL_ERROR);
    }

    /* Apply the function. */

    for (i = 0; i < tensorPtr->order; i++) {
	index[i] = lowIndices[i];
    }

    do {
	/* Get tensor element. */

	elptr = Tensor_GetElemPtr(tensorPtr, index);
	d = Tensor_GetElemValue(elptr, tensorPtr->type);

	/* Apply the function and update the tensor. */

	d = func(d);
	Tensor_SetElemValue(elptr, tensorPtr->type, d);

    } while(Tensor_NextIndex(tensorPtr->order,lowIndices, highIndices, index));

    return (TCL_OK);
}


/*
 *----------------------------------------------------------------------
 *
 * TensorSaturate --
 *
 *	TensorSaturate saturates a section of a tensor so that all
 *	its elements' values lie between a minimum and a maximum
 *	value.
 *
 * Results:
 *	None.
 *
 * Side effects:
 *	Values in the tensor may get changed.
 *
 *----------------------------------------------------------------------
 */

void
TensorSaturate(
    Tensor_Descrip *tensor,	/* Tensor to operate on		*/
    Tensor_Index lowIdx,	/* Low section index		*/
    Tensor_Index highIdx,	/* High section index		*/
    double minVal,		/* Low saturation value		*/
    double maxVal)		/* High saturation value	*/

{
    int i;
    Tensor_Index idx;
    VOID *elemPtr;
    double val;

    /* Exit if there's no data to operate on. */

    if(tensor->data == (VOID *) NULL) {
	return;
    }

    for(i = 0; i < tensor->order; i++) {
	if(lowIdx[i] > highIdx[i]) {
	    return;
	}
    }

    /* Do the saturate op... */

    for(i = 0; i < tensor->order; i++) {
	idx[i] = lowIdx[i];
    }

    do {
	elemPtr = Tensor_GetElemPtr(tensor, idx);
	val = Tensor_GetElemValue(elemPtr, tensor->type);
	if(val < minVal) {
	    Tensor_SetElemValue(elemPtr, tensor->type, minVal);
	} else if(val > maxVal) {
	    Tensor_SetElemValue(elemPtr, tensor->type, maxVal);
	}
    } while(Tensor_NextIndex(tensor->order, lowIdx, highIdx, idx));
}



/*
 *----------------------------------------------------------------------
 *
 * TensorSubst --
 *
 *	TensorSubst performs a table-lookup substitution on a section
 *	of a tensor. Each element of the tensor section has a new
 *	value substituted, chosen from the substitution table.
 *
 * Results:
 *	None.
 *
 * Side effects:
 *	Elements of the tensor get changed.
 *
 *----------------------------------------------------------------------
 */

void
TensorSubst(
    Tensor_Descrip *tensor,	/* Tensor to operate on		*/
    Tensor_Index lowIdx,	/* Low section index		*/
    Tensor_Index highIdx,	/* High section index		*/
    int tabSize,		/* Size of substitution table	*/
    double *substTab)		/* Substitution table		*/
{
    int i;
    Tensor_Index idx;
    VOID *elemPtr;
    int tabIdx;
    double val;

    /* Exit if there's no data to operate on. */

    if(tensor->data == (VOID *) NULL) {
	return;
    }

    for(i = 0; i < tensor->order; i++) {
	if(lowIdx[i] > highIdx[i]) {
	    return;
	}
    }

    /* Do the substitutions... */

    for(i = 0; i < tensor->order; i++) {
	idx[i] = lowIdx[i];
    }

    do {
	elemPtr = Tensor_GetElemPtr(tensor, idx);
	val = Tensor_GetElemValue(elemPtr, tensor->type);
#ifdef WIN32
	if(!_isnan(val)) {
#else
	if(!isnan(val)) {
#endif
	    if(val < 0) {
		tabIdx = 0;
	    } else if(val >= tabSize) {
		tabIdx = tabSize - 1;
	    } else {
		tabIdx = val;
	    }
	    Tensor_SetElemValue(elemPtr, tensor->type, substTab[tabIdx]);
	}
    } while(Tensor_NextIndex(tensor->order, lowIdx, highIdx, idx));
}


/*
 *----------------------------------------------------------------------
 *
 * TensorSequ --
 *
 *	TensorSequ puts a "sequence" into a section of a tensor,
 *	i.e. it sets elemnts to 0, 1, 2, ... in storage order.
 *
 * Results:
 *	None.
 *
 * Side effects:
 *	The tensor's contents change.
 *
 *----------------------------------------------------------------------
 */

void
TensorSequ(
    Tensor_Descrip *tensor,	/* Tensor to operate on		*/
    Tensor_Index lowIdx,	/* Low section index		*/
    Tensor_Index highIdx)	/* High section index		*/
{
    int i;
    Tensor_Index idx;
    VOID *elemPtr;

    /* Exit if there's no data to operate on. */

    if(tensor->data == (VOID *) NULL) {
	return;
    }

    for(i = 0; i < tensor->order; i++) {
	if(lowIdx[i] > highIdx[i]) {
	    return;
	}
    }

    /* Do the sequence op...... */


    for(i = 0; i < tensor->order; i++) {
	idx[i] = lowIdx[i];
    }

    i = 0;
    do {
	elemPtr = Tensor_GetElemPtr(tensor, idx);
	Tensor_SetElemValue(elemPtr, tensor->type, (double) i);
	i++;
    } while(Tensor_NextIndex(tensor->order, lowIdx, highIdx, idx));
}


/*
 *----------------------------------------------------------------------
 *
 * TensorPutIntoArray --
 *
 *	TensorPutIntoArray puts the contents of a tensor into a Tcl
 *	array.
 *
 * Results:
 *	None.
 *
 * Side effects:
 *	A Tcl array may be created, and its contents changed.
 *
 *----------------------------------------------------------------------
 */

void
TensorPutIntoArray(
    Tcl_Interp *interp,		/* Interpreter where we'll set
				 * variables			*/
    Tensor_Descrip *tensor,	/* Tensor to copy into array	*/
    Tensor_Index lowIdx,	/* Low section index		*/
    Tensor_Index highIdx,	/* High section index		*/
    Tcl_Obj *arrayName,		/* Name of target array		*/
    int arraySelCond,		/* Select condition		*/
    double arrayCompVal,	/* Comparison value for select
				 * condition			*/
    Tensor_Index offset)	/* Array index offset (origin)	*/
{
    int i, doIt;
    Tensor_Index idx;
    VOID *elemPtr;
    char arrayDim[32];
    char arrayIdx[256];

    /* Exit if there's no data to operate on. */

    if(tensor->data == (VOID *) NULL) {
	return;
    }

    for(i = 0; i < tensor->order; i++) {
	if(lowIdx[i] > highIdx[i]) {
	    return;
	}
    }

    /* Put stuff into the array... */

    for(i = 0; i < tensor->order; i++) {
	idx[i] = lowIdx[i];
    }

    do {
	/* Get the tensor value. */

	elemPtr = Tensor_GetElemPtr(tensor, idx);
	doIt = 0;
	switch(arraySelCond) {
	    case _TENSOR_ALWAYS:
		doIt = 1;
		break;
	    case _TENSOR_COMP_EQ:
		doIt = (Tensor_GetElemValue(elemPtr,tensor->type) == arrayCompVal);
		break;
	    case _TENSOR_COMP_NE:
		doIt = (Tensor_GetElemValue(elemPtr,tensor->type) != arrayCompVal);
		break;
	    case _TENSOR_COMP_GT:
		doIt = (Tensor_GetElemValue(elemPtr,tensor->type) > arrayCompVal);
		break;
	    case _TENSOR_COMP_GE:
		doIt = (Tensor_GetElemValue(elemPtr,tensor->type) >= arrayCompVal);
		break;
	    case _TENSOR_COMP_LT:
		doIt = (Tensor_GetElemValue(elemPtr,tensor->type) < arrayCompVal);
		break;
	    case _TENSOR_COMP_LE:
		doIt = (Tensor_GetElemValue(elemPtr,tensor->type) <= arrayCompVal);
		break;
	}

	if(!doIt) {
	    continue;
	}

	/* Construct the array index string. */

	arrayIdx[0] = '\0';
	if (tensor->order > 0) {
	    for (i = 0;;) {
		sprintf(arrayDim,"%1d",idx[i] + offset[i]);
		strcat(arrayIdx,arrayDim);
		i++;
		if(i >= tensor->order) {
		    break;
		}
		strcat(arrayIdx,",");
	    }
	}

	/* Set array value. */

	Tcl_ObjSetVar2(interp, arrayName, Tcl_NewStringObj(arrayIdx, -1),
			Tensor_GetElemObj(elemPtr, tensor->type), 0);

    } while(Tensor_NextIndex(tensor->order, lowIdx, highIdx, idx));
}


/*
 *----------------------------------------------------------------------
 *
 * TensorSwap --
 *
 *	TensorSwap swaps two sections of a tensor. The sections given
 *	by {* * ... * * idxList[0] * * ... * *} and
 *	{* * ... * * idxList[1] * * ... * *} get exchanged, where
 *	the non-* index is for dimension dimNo.
 *
 * Results:
 *	Returns a standard Tcl result.
 *
 * Side effects:
 *	Parts of the tensor get re-arranged.
 *
 *----------------------------------------------------------------------
 */

int
TensorSwap(
    Tcl_Interp *interp,		/* Error messages go here	*/
    Tensor_Descrip *tensorPtr,	/* Tensor we're operating on	*/
    int dimNo,			/* Dimension we're swapping on	*/
    int *idxList)		/* Index pair to be swapped	*/
{
    Tensor_Descrip tmpTensor;
    Tensor_Index lowIndex1, lowIndex2, lowIndexTmp;
    Tensor_Index highIndex1, highIndex2, highIndexTmp;
    int i;

    /* Exit if there's no data to operate on. */

    if(tensorPtr->data == (VOID *) NULL) {
	return(TCL_OK);
    }

    /* If the indices are equal, we don't need to do anything. */

    if(idxList[0] == idxList[1]) {
	return(TCL_OK);
    }

    /* Allocate temporary storage for swap. */

    for(i = 0; i < tensorPtr->order; i++) {
	tmpTensor.dims[i] = tensorPtr->dims[i];
    }
    tmpTensor.order = tensorPtr->order;
    tmpTensor.type = tensorPtr->type;

    if(Tensor_AllocData(interp, &tmpTensor) != TCL_OK) {
	return(TCL_ERROR);
    }

    /* Create indices. */

    for(i = 0; i < tensorPtr->order; i++) {
	lowIndex1[i] = lowIndex2[i] = lowIndexTmp[i] = 0;
	highIndex1[i] = highIndex2[i] = highIndexTmp[i] = tensorPtr->dims[i] - 1;
    }
    lowIndex1[dimNo] = highIndex1[dimNo] = idxList[0];
    lowIndex2[dimNo] = highIndex2[dimNo] = idxList[1];
    lowIndexTmp[dimNo] = highIndexTmp[dimNo] = 0;

    /* Copy first index to temp storage. */

    if(TensorCopySection(interp,&tmpTensor,lowIndexTmp,highIndexTmp,
		tensorPtr,lowIndex1,highIndex1) != TCL_OK) {
	Tensor_FreeData(&tmpTensor);
	return(TCL_ERROR);
    }

    /* Copy second index to first index. */

    if(TensorCopySection(interp,tensorPtr,lowIndex1,highIndex1,
		tensorPtr,lowIndex2,highIndex2) != TCL_OK) {
	Tensor_FreeData(&tmpTensor);
	return(TCL_ERROR);
    }

    /* Copy temp storage to second index. */

    if(TensorCopySection(interp,tensorPtr,lowIndex2,highIndex2,
		&tmpTensor,lowIndexTmp,highIndexTmp) != TCL_OK) {
	Tensor_FreeData(&tmpTensor);
	return(TCL_ERROR);
    }

    /* Clean up and return. */

    Tensor_FreeData(&tmpTensor);
    return(TCL_OK);
}


/*
 *----------------------------------------------------------------------
 *
 * TensorPermute --
 *
 *	TensorPermute permutes the contents of the input tensor. The new
 *	contents will be created by setting cross-section
 *	{* * ... * * i * * ... * *} of the new tensor to be equal to the
 *	contents of section {* * ... * * idxList[i] * * ... * *} of
 *	the old tensor. (The non-* section entries are for dimension
 *	dimNo.) It is assumed that idxList is a list of integers
 *	of length N, where N is the extent of dimension dimNo.
 *
 * Results:
 *	Returns a standard Tcl result.
 *
 * Side effects:
 *	The tensor's contents get rearranged.
 *
 *----------------------------------------------------------------------
 */

int
TensorPermute(
    Tcl_Interp *interp,		/* Error messages go here	*/
    Tensor_Descrip *tensorPtr,	/* Tensor we're operating on	*/
    int dimNo,			/* Dimension we're permuting on	*/
    int *idxList)		/* Permutation list		*/
{
    int i;
    VOID *tmpDataPtr;
    Tensor_Descrip tmpTensor;
    Tensor_Index srcLowIndex, destLowIndex, srcHighIndex, destHighIndex;

    /* Exit if there's no data to operate on. */

    if(tensorPtr->data == (VOID *) NULL) {
	return(TCL_OK);
    }

    /*
     * Allocate storage for the permuted tensor. The easiest
     * way to do this is to make a temporary tensor that's
     * identical in type and size to the original.
     */

    for(i = 0; i < tensorPtr->order; i++) {
	tmpTensor.dims[i] = tensorPtr->dims[i];
    }
    tmpTensor.order = tensorPtr->order;
    tmpTensor.type = tensorPtr->type;

    if(Tensor_AllocData(interp, &tmpTensor) != TCL_OK) {
	return(TCL_ERROR);
    }

    /* Initialize the indices. */

    for(i = 0; i < tensorPtr->order; i++) {
	srcLowIndex[i] = destLowIndex[i] = 0;
	srcHighIndex[i] = destHighIndex[i] = tensorPtr->dims[i] - 1;
    }

    /* Copy sections of the tensor. */

    for(i = 0; i < tmpTensor.dims[dimNo]; i++) {
	srcLowIndex[dimNo] = srcHighIndex[dimNo] = idxList[i];
	destLowIndex[dimNo] = destHighIndex[dimNo] = i;
	if(TensorCopySection(interp,&tmpTensor,destLowIndex,destHighIndex,
			tensorPtr,srcLowIndex,srcHighIndex) != TCL_OK) {
	    Tensor_FreeData(&tmpTensor);
	    return(TCL_ERROR);
	}
    }

    /* Swap the data for the original and permuted tensors. */

    tmpDataPtr = tmpTensor.data;
    tmpTensor.data = tensorPtr->data;
    tensorPtr->data = tmpDataPtr;

    /* Clean up and return. */

    Tensor_FreeData(&tmpTensor);
    return(TCL_OK);
}


/*
 *----------------------------------------------------------------------
 *
 * TensorDelete --
 *
 *	TensorDelete deletes selected rows/columns from a tensor.
 *	The dimension we'll delete sections along is given by dimNo,
 *	while the indices of the deleted rows/columns are given by
 *	idxList. It is assumed that the elements of idxList are
 *	unique.
 *
 * Results:
 *	Returns a standard Tcl result.
 *
 * Side effects:
 *	Parts of the tensor are deleted.
 *
 *----------------------------------------------------------------------
 */

int
TensorDelete(
    Tcl_Interp *interp,		/* Error messages go here	*/
    Tensor_Descrip *tensorPtr,	/* Tensor we're operating on	*/
    int dimNo,			/* Dimension we're deleting on	*/
    int nDel,			/* Length of delete list	*/
    int *idxList)		/* List of sections to delete	*/
{
    int i, delIdx, prevDelIdx;
    int delListIdx, newIdx, nCopied;
    VOID *tmpDataPtr;
    Tensor_Descrip tmpTensor;
    Tensor_Index srcLowIndex, destLowIndex, srcHighIndex, destHighIndex;

    /* Exit if there's no data to operate on. */

    if(tensorPtr->data == (VOID *) NULL) {
	return(TCL_OK);
    }

    /*
     * If we're going to wind up with no data, just free up
     * storage and change the apropriate dimension to 0.
     */

    if(tensorPtr->dims[dimNo] <= nDel) {
	Tensor_FreeData(tensorPtr);
	tensorPtr->dims[dimNo] = 0;
	return(TCL_OK);
    }

    /*
     * Allocate storage for the new tensor. The easiest
     * way to do this is to make a temporary tensor that's
     * the correct size.
     */

    for(i = 0; i < tensorPtr->order; i++) {
	tmpTensor.dims[i] = tensorPtr->dims[i];
    }
    tmpTensor.dims[dimNo] -= nDel;

    tmpTensor.order = tensorPtr->order;
    tmpTensor.type = tensorPtr->type;

    if(Tensor_AllocData(interp, &tmpTensor) != TCL_OK) {
	return(TCL_ERROR);
    }

    /* Initialize the indices. */

    for(i = 0; i < tensorPtr->order; i++) {
	srcLowIndex[i] = destLowIndex[i] = 0;
	srcHighIndex[i] = destHighIndex[i] = tensorPtr->dims[i] - 1;
    }

    /* Sort the index list in ascending order. */

    qsort(idxList, nDel, sizeof(int), CompInt);

    /* Copy sections of the tensor. We'll copy data between
     * the deleted rows/columns in one big chunk. delListIdx
     * is the index into the "delete" list; we use this to
     * get delIdx, the index of the deleted row/column.
     * prevDelIdx is the previously-deleted row/column. newIdx
     * is the index into the new (destination) tensor.
     */

    for(prevDelIdx = -1, delListIdx = 0, newIdx = 0; delListIdx < nDel; delListIdx++) {
	delIdx = idxList[delListIdx];
	nCopied = delIdx - prevDelIdx - 1;
	if(nCopied > 0) {
	    srcLowIndex[dimNo] = prevDelIdx + 1;
	    srcHighIndex[dimNo] = delIdx - 1;
	    destLowIndex[dimNo] = newIdx;
	    destHighIndex[dimNo] = newIdx + nCopied - 1;

	    if(TensorCopySection(interp,&tmpTensor,destLowIndex,destHighIndex,
			tensorPtr,srcLowIndex,srcHighIndex) != TCL_OK) {
		Tensor_FreeData(&tmpTensor);
		return(TCL_ERROR);
	    }
	}

	newIdx += nCopied;
	prevDelIdx = delIdx;
    }

    /*
     * Finish up by copying all the stuff that comes after the
     * last deleted row/column. We fake this by pretending that
     * the row/column AFTER the last one gets deleted.
     */

    delIdx = tensorPtr->dims[dimNo];
    nCopied = delIdx - prevDelIdx - 1;
    if(nCopied > 0) {
	srcLowIndex[dimNo] = prevDelIdx + 1;
	srcHighIndex[dimNo] = delIdx - 1;
	destLowIndex[dimNo] = newIdx;
	destHighIndex[dimNo] = newIdx + nCopied - 1;

	if(TensorCopySection(interp,&tmpTensor,destLowIndex,destHighIndex,
			tensorPtr,srcLowIndex,srcHighIndex) != TCL_OK) {
	    Tensor_FreeData(&tmpTensor);
	    return(TCL_ERROR);
	}
    }

    /* Swap the data for the original and modified tensors. */

    tmpDataPtr = tmpTensor.data;
    tmpTensor.data = tensorPtr->data;
    tensorPtr->data = tmpDataPtr;
    i = tmpTensor.dims[dimNo];
    tmpTensor.dims[dimNo] = tensorPtr->dims[dimNo];
    tensorPtr->dims[dimNo] = i;

    /* Clean up and return. */

    Tensor_FreeData(&tmpTensor);
    return(TCL_OK);
}


/*
 *----------------------------------------------------------------------
 *
 * TensorInsert --
 *
 *	TensorInsert inserts rows/columns into a tensor. The inserted
 *	data is set to zero. It inserts nItems row/columns/whatever,
 *	where dimNo specifies the dimension to insert into. The
 *	rows/columns are inserted before position pos.
 *
 * Results:
 *	None.
 *
 * Side effects:
 *	None.
 *
 *----------------------------------------------------------------------
 */

int
TensorInsert(
    Tcl_Interp *interp,		/* Error messages go here	*/
    Tensor_Descrip *tensorPtr,	/* Tensor we're operating on	*/
    int nItems,			/* # of rows/cols to insert	*/
    int dimNo,			/* Dimension we're deleting on	*/
    int pos)			/* Position to insert before	*/
{
    int i;
    VOID *tmpDataPtr;
    Tensor_Descrip tmpTensor;
    Tensor_Index srcLowIndex, destLowIndex, srcHighIndex, destHighIndex;

    /*
     * Allocate storage for the new tensor. The easiest
     * way to do this is to make a temporary tensor that's
     * the correct size.
     */

    for(i = 0; i < tensorPtr->order; i++) {
	tmpTensor.dims[i] = tensorPtr->dims[i];
    }
    tmpTensor.dims[dimNo] += nItems;

    tmpTensor.order = tensorPtr->order;
    tmpTensor.type = tensorPtr->type;

    if(Tensor_AllocData(interp, &tmpTensor) != TCL_OK) {
	return(TCL_ERROR);
    }

    /* Initialize the indices. */

    for(i = 0; i < tensorPtr->order; i++) {
	srcLowIndex[i] = destLowIndex[i] = 0;
	srcHighIndex[i] = destHighIndex[i] = tensorPtr->dims[i] - 1;
    }

    /* Copy everything that comes before the inserted stuff. */

    if(pos > 0) {
	srcLowIndex[dimNo] = 0;
	srcHighIndex[dimNo] = pos - 1;
	destLowIndex[dimNo] = 0;
	destHighIndex[dimNo] = pos - 1;

	if(TensorCopySection(interp,&tmpTensor,destLowIndex,destHighIndex,
			tensorPtr,srcLowIndex,srcHighIndex) != TCL_OK) {
	    Tensor_FreeData(&tmpTensor);
	    return(TCL_ERROR);
	}
    }

    /* Zero-out the inserted stuff. */

    if(nItems > 0) {
	destLowIndex[dimNo] = pos;
	destHighIndex[dimNo] = pos + nItems - 1;
	if(TensorOpScalar(interp,&tmpTensor,
			destLowIndex,destHighIndex,'c', 0.0) != TCL_OK) {
	    Tensor_FreeData(&tmpTensor);
	    return(TCL_ERROR);
	}
    }

    /* Copy everything that comes after the inserted stuff. */

    if(pos + nItems < tmpTensor.dims[dimNo]) {
	srcLowIndex[dimNo] = pos;
	srcHighIndex[dimNo] = tensorPtr->dims[dimNo] - 1;
	destLowIndex[dimNo] = pos + nItems;
	destHighIndex[dimNo] = tmpTensor.dims[dimNo] - 1;

	if(TensorCopySection(interp,&tmpTensor,destLowIndex,destHighIndex,
			tensorPtr,srcLowIndex,srcHighIndex) != TCL_OK) {
	    Tensor_FreeData(&tmpTensor);
	    return(TCL_ERROR);
	}
    }

    /* Swap the data for the original and modified tensors. */

    tmpDataPtr = tmpTensor.data;
    tmpTensor.data = tensorPtr->data;
    tensorPtr->data = tmpDataPtr;
    i = tmpTensor.dims[dimNo];
    tmpTensor.dims[dimNo] = tensorPtr->dims[dimNo];
    tensorPtr->dims[dimNo] = i;

    /* Clean up and return. */

    Tensor_FreeData(&tmpTensor);
    return(TCL_OK);
}


/*
 *----------------------------------------------------------------------
 *
 * TensorBoolScalar --
 *
 *	TensorBoolScalar constructs an operand tensor, given a comparison
 *	operation between a tensor and a scalar.
 *
 * Results:
 *	Returns a standard Tcl result.
 *
 * Side effects:
 *	*srcTensorPtr gets filled in.
 *
 *----------------------------------------------------------------------
 */

int
TensorBoolScalar(
    Tcl_Interp *interp,
    Tensor_Descrip *boolOp1Ptr,
    Tensor_Index op1LowIndices,
    Tensor_Index op1HighIndices,
    char boolOp,
    double compNo,
    Tensor_Descrip *srcTensorPtr)
{
    int i;
    double d;
    Tensor_Index indexMap;
    Tensor_Index inIndex, outIndex;
    Tensor_Index maxOutIndex;
    Tensor_Index zeroIndex;
    VOID *e_in, *e_out;

    /* Get the tensor section dimensions. */

    TensorSectionDims(boolOp1Ptr->order, op1LowIndices, op1HighIndices,
		     &(srcTensorPtr->order), srcTensorPtr->dims, indexMap);

    /* Allocate storage in srcTensorPtr. */

    srcTensorPtr->type = TENSOR_BYTE;
     if (Tensor_AllocData(interp, srcTensorPtr) != TCL_OK) {
	return(TCL_ERROR);
    }

    if (srcTensorPtr->data == (VOID *) NULL) {
	return(TCL_OK);
    }

    /* Fill in the Boolean values; first, initialize the indices. */

    for(i = 0; i < boolOp1Ptr->order; i++) {
	inIndex[i] = op1LowIndices[i];
    }

    for(i = 0; i < srcTensorPtr->order; i++) {
	if(srcTensorPtr->dims[i] == 0) {
	    return(TCL_OK);
	}
	zeroIndex[i] = 0;
	maxOutIndex[i] = srcTensorPtr->dims[i] - 1;
	outIndex[i] = 0;
    }

    /* Compute the Boolean values. */

    do {
	e_in = Tensor_GetElemPtr(boolOp1Ptr, inIndex);
	d = Tensor_GetElemValue(e_in, boolOp1Ptr->type);
	switch(boolOp) {
	    case '<':
		d = (d < compNo);
		break;

	    case '>':
		d = (d < compNo);
		break;

	    case 'l':
		d = (d <= compNo);
		break;

	    case 'g':
		d = (d >= compNo);
		break;

	    case '=':
		d = (d == compNo);
		break;

	    case '!':
		d = (d != compNo);
		break;
	}
	e_out = Tensor_GetElemPtr(srcTensorPtr, outIndex);
	Tensor_SetElemValue(e_out, srcTensorPtr->type, d);

	Tensor_NextIndex(srcTensorPtr->order, zeroIndex, maxOutIndex, outIndex);
    } while(Tensor_NextIndex(boolOp1Ptr->order, op1LowIndices, op1HighIndices, inIndex));

    return(TCL_OK);
}



/*
 *----------------------------------------------------------------------
 *
 * TensorBoolTensor --
 *
 *	TensorBoolTensor constructs an operand tensor, given a comparison
 *	operation between two tensors.
 *
 * Results:
 *	Returns a standard Tcl result.
 *
 * Side effects:
 *	*srcTensorPtr gets filled in.
 *
 *----------------------------------------------------------------------
 */

int
TensorBoolTensor(
    Tcl_Interp *interp,
    Tensor_Descrip *boolOp1Ptr,
    Tensor_Index op1LowIndices,
    Tensor_Index op1HighIndices,
    Tensor_Descrip *boolOp2Ptr,
    Tensor_Index op2LowIndices,
    Tensor_Index op2HighIndices,
    char boolOp,
    Tensor_Descrip *srcTensorPtr)
{
    int i;
    double d,d1,d2;
    Tensor_Index indexMap;
    Tensor_Index in1Index, in2Index, outIndex;
    Tensor_Index maxOutIndex;
    Tensor_Index zeroIndex;
    Tensor_Index op2dims;
    VOID *e1_in, *e2_in, *e_out;
    int op2order;

    /* Get the tensor section dimensions. */

    TensorSectionDims(boolOp1Ptr->order, op1LowIndices, op1HighIndices,
		     &(srcTensorPtr->order), srcTensorPtr->dims, indexMap);

    TensorSectionDims(boolOp2Ptr->order, op2LowIndices, op2HighIndices,
		     &op2order, op2dims, indexMap);

    /* Make sure the sections match. */

    if(srcTensorPtr->order != op2order) {
	Tcl_SetObjResult(interp, Tcl_NewStringObj(
		"Tensors in \"boolean\" comparison must be the same size", -1));
	return(TCL_ERROR);
    }

    for(i = 0; i < op2order; i++) {
	if(srcTensorPtr->dims[i] != op2dims[i]) {
	    Tcl_SetObjResult(interp, Tcl_NewStringObj(
		    "Tensors in \"boolean\" comparison must be the same size", -1));
	    return(TCL_ERROR);
	}
    }

    /* Allocate storage in srcTensorPtr. */

    srcTensorPtr->type = TENSOR_BYTE;
     if (Tensor_AllocData(interp, srcTensorPtr) != TCL_OK) {
	return(TCL_ERROR);
    }

    if (srcTensorPtr->data == (VOID *) NULL) {
	return(TCL_OK);
    }

    /* Fill in the Boolean values; first, initialize the indices. */

    for(i = 0; i < boolOp1Ptr->order; i++) {
	in1Index[i] = op1LowIndices[i];
    }

    for(i = 0; i < boolOp2Ptr->order; i++) {
	in2Index[i] = op2LowIndices[i];
    }

    for(i = 0; i < srcTensorPtr->order; i++) {
	if(srcTensorPtr->dims[i] == 0) {
	    return(TCL_OK);
	}
	zeroIndex[i] = 0;
	maxOutIndex[i] = srcTensorPtr->dims[i] - 1;
	outIndex[i] = 0;
    }

    /* Compute the Boolean values. */

    do {
	e1_in = Tensor_GetElemPtr(boolOp1Ptr, in1Index);
	e2_in = Tensor_GetElemPtr(boolOp2Ptr, in2Index);
	d1 = Tensor_GetElemValue(e1_in, boolOp1Ptr->type);
	d2 = Tensor_GetElemValue(e2_in, boolOp2Ptr->type);
	switch(boolOp) {
	    case '<':
		d = (d1 < d2);
		break;

	    case '>':
		d = (d1 < d2);
		break;

	    case 'l':
		d = (d1 <= d2);
		break;

	    case 'g':
		d = (d1 >= d2);
		break;

	    case '=':
		d = (d1 == d2);
		break;

	    case '!':
		d = (d1 != d2);
		break;

	    default:
		d = 0;
		break;
	}
	e_out = Tensor_GetElemPtr(srcTensorPtr, outIndex);
	Tensor_SetElemValue(e_out, srcTensorPtr->type, d);

	Tensor_NextIndex(srcTensorPtr->order, zeroIndex, maxOutIndex, outIndex);
	Tensor_NextIndex(boolOp2Ptr->order, op2LowIndices, op2HighIndices, in2Index);
    } while(Tensor_NextIndex(boolOp1Ptr->order, op1LowIndices, op1HighIndices, in1Index));

    return(TCL_OK);
}
