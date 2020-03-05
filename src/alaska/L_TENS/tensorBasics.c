/*
 * tensorBasics.c --
 *
 *	This file contains "basic" tensor operations:
 *	storage allocation, storage reclamation, indexing,
 *	setting/retrieving the contents of a tensor element.
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
static char rcsid[] = "$Header: /home/neil/src/tcl/tensor/generic/RCS/tensorBasics.c,v 1.5 2008/05/31 21:09:56 neil Exp $";
#endif

#include <stdlib.h>
#include "tcl.h"
#include "tensorInt.h"

/* tensorElemSize contains the size of a    */
/* tensor element as a function of tensor type. */

static int tensorElemSize[] = {
    sizeof(double),
    sizeof(float),
    sizeof(int),
    sizeof(unsigned char),
    sizeof(unsigned short),
    sizeof(unsigned int)
};

/*
 * Note: we provide the function Tensor_ElemSize (rather than
 * making tensorElemSize global) because global variables
 * don't work in DLLs on the PC.
 */

/*
 *---------------------------------------------------------------
 *
 * Tensor_ElemSize --
 *
 *	Returns the size of a single tensor element
 *	given the tensor's type.
 *
 * Results:
 *	The function returns the element size, in bytes
 *
 * Side effects:
 *	None.
 *
 *---------------------------------------------------------------
 */

int
Tensor_ElemSize(int elemType)
{
    return(tensorElemSize[elemType]);
}

/*
 *---------------------------------------------------------------
 *
 * Tensor_GetElemValue --
 *
 *	Given a pointer to a tensor element and the tensor's
 *	type, find the value of the element.
 *
 * Results:
 *	The function returns the element value, converted
 *	to type "double".
 *
 * Side effects:
 *	None.
 *
 *---------------------------------------------------------------
 */

double 
Tensor_GetElemValue(
    VOID *elemPtr,	/* Pointer to tensor element		*/
    int elemType)	/* Tensor type- double, float, etc.	*/
{
    double d;

    switch (elemType) {
	case TENSOR_DOUBLE:
	    d = *((double *) elemPtr);
	    break;
	case TENSOR_FLOAT:
	    d = *((float *) elemPtr);
	    break;
	case TENSOR_INT:
	    d = *((int *) elemPtr);
	    break;
	case TENSOR_BYTE:
	    d = *((unsigned char *) elemPtr);
	    break;
	case TENSOR_SHORT:
	    d = *((unsigned short *) elemPtr);
	    break;
	case TENSOR_UNSIGNED:
	    d = *((unsigned int *) elemPtr);
	    break;

	default:
	    fprintf(stderr, "Invalid tensor type %1d\n", elemType);
	    abort();
	    break;
    }

    return (d);
}

/*
 *---------------------------------------------------------------
 *
 * Tensor_GetElemObj --
 *
 *	Given a pointer to a tensor element and the tensor's
 *	type, return a Tcl_Obj containing the element's value.
 *
 * Results:
 *	The function returns the element value, contained in
 *	a Tcl_Obj pointer.
 *
 * Side effects:
 *	None.
 *
 *---------------------------------------------------------------
 */

Tcl_Obj *Tensor_GetElemObj(
    VOID *elemPtr,	/* Pointer to tensor element		*/
    int elemType)	/* Tensor type- double, float, etc.	*/
{
    Tcl_Obj *result;

    switch (elemType) {
	case TENSOR_DOUBLE:
	    result = Tcl_NewDoubleObj(*((double *) elemPtr));
	    break;
	case TENSOR_FLOAT:
	    result = Tcl_NewDoubleObj((double) (*((float *) elemPtr)));
	    break;
	case TENSOR_INT:
	    result = Tcl_NewIntObj(*((int *) elemPtr));
	    break;
	case TENSOR_BYTE:
	    result = Tcl_NewIntObj((int) (*((unsigned char *) elemPtr)));
	    break;
	case TENSOR_SHORT:
	    result = Tcl_NewIntObj((int) (*((unsigned short *) elemPtr)));
	    break;
	case TENSOR_UNSIGNED:
	    result = Tcl_NewIntObj((int) (*((unsigned int *) elemPtr)));
	    break;

	default:
	    fprintf(stderr, "Invalid tensor type %1d\n", elemType);
	    abort();
	    break;
    }

    return (result);
}


/*
 *---------------------------------------------------------------
 *
 * Tensor_SetElemValue --
 *
 *	Given a pointer to a tensor element and the tensor's
 *	type, set the value of the element.
 *
 * Results:
 *	Nothing.
 *
 * Side effects:
 *	Sets the value of the tensor element.
 *
 *---------------------------------------------------------------
 */

void 
Tensor_SetElemValue(
    VOID *elemPtr,	/* Pointer to tensor element		*/
    int elemType,	/* Tensor type- double, float, etc.	*/
    double val)		/* Value to set tensor element to	*/
{
    switch (elemType) {
	case TENSOR_DOUBLE:
	    *((double *) elemPtr) = val;
	    break;
	case TENSOR_FLOAT:
	    *((float *) elemPtr) = val;
	    break;
	case TENSOR_INT:
	    *((int *) elemPtr) = val;
	    break;
	case TENSOR_BYTE:
	    *((unsigned char *) elemPtr) = val;
	    break;
	case TENSOR_SHORT:
	    *((unsigned short *) elemPtr) = val;
	    break;
	case TENSOR_UNSIGNED:
	    *((unsigned int *) elemPtr) = val;
	    break;

	default:
	    fprintf(stderr, "Invalid tensor type %1d\n", elemType);
	    abort();
	    break;
    }
}



/*
 *---------------------------------------------------------------
 *
 * Tensor_NElements --
 *
 *	Find the number of elements in a tensor, e.g. for
 *	a 3x5x2 tensor, return 30.
 *
 * Results:
 *	The number of elements in the tensor
 *
 * Side effects:
 *	None.
 *
 *---------------------------------------------------------------
 */

int 
Tensor_NElements(
    Tensor_Descrip *tensorPtr)
{
    int i, n_elements;

    n_elements = 1;
    for (i = 0; i < tensorPtr->order; i++)
	n_elements *= tensorPtr->dims[i];

    return (n_elements);
}



/*
 *---------------------------------------------------------------
 *
 * Tensor_GetElemPtr --
 *
 *	Given a tensor and an index, find the corresponding
 *	tensor element.
 *
 * Results:
 *	The function returns a pointer to the tensor element.
 *
 * Side effects:
 *	None.
 *
 *---------------------------------------------------------------
 */

VOID *
Tensor_GetElemPtr(
    Tensor_Descrip *tensorPtr,	/* Pointer to tensor		*/
    Tensor_Index index)		/* Index of desired element	*/
{
    int i, offset;
    char *cptr;

    offset = 0;
    for (i = 0; i < tensorPtr->order; i++)
	offset = offset * tensorPtr->dims[i] + index[i];

    cptr = (char *) (tensorPtr->data);
    cptr += tensorElemSize[tensorPtr->type] * offset;

    return ((VOID *) cptr);
}


/*
 *---------------------------------------------------------------
 *
 * Tensor_AllocData --
 *
 *	Allocate the data for a tensor, using the tensor's type,
 *	order, and dimensions.
 *
 * Results:
 *	Returns a standard TCL result.
 *
 * Side effects:
 *	Allocates data for the given tensor.
 *
 *---------------------------------------------------------------
 */

int 
Tensor_AllocData(
    Tcl_Interp *interp,		/* Tcl interpreter for errors	*/
    Tensor_Descrip *tensorPtr)	/* Pointer to tensor we're
				 * going to allocate data for	*/
{
    int i, entry_size;
    int n_entries, total_bytes;

    /* Sanity checks. */

    if (tensorPtr->type < 0
	|| tensorPtr->type > TENSOR_MAX_TYPE) {
	fprintf(stderr, "Invalid tensor type %1d\n", tensorPtr->type);
	abort();
    }
    if (tensorPtr->order < 0
	|| tensorPtr->order > TENSOR_MAX_ORDER) {
	fprintf(stderr, "Illegal tensor order %1d\n", tensorPtr->order);
	abort();
    }

    /* Find out how big the tensor is. */

    n_entries = 1;
    for (i = 0; i < tensorPtr->order; i++) {
	n_entries *= tensorPtr->dims[i];
    }
    if(n_entries < 0) {
	Tcl_SetObjResult(interp,
		Tcl_NewStringObj("Number of tensor elements is negative!", -1));
	return (TCL_ERROR);
    }

    /* Allocate storage. */

    if (n_entries == 0) {
	tensorPtr->data =(VOID *) NULL;
    } else {
	entry_size = tensorElemSize[tensorPtr->type];
	total_bytes = n_entries * entry_size;
	tensorPtr->data = (VOID *) ckalloc(total_bytes);
	if (tensorPtr->data == (VOID *) NULL) {
	    Tcl_SetObjResult(interp,
		Tcl_NewStringObj("couldn't allocate memory for tensor", -1));
	    return (TCL_ERROR);
	}

	/* Initialize. */

	for (i = 0; i < total_bytes; i++) {
	    ((char *) (tensorPtr->data))[i] = '\0';
	}
    }

    /* Done. */

    return (TCL_OK);
}



/*
 *---------------------------------------------------------------
 *
 * Tensor_FreeData --
 *
 *	Free a tensor's data. Note that this does NOT free
 *	the tensor descriptor structure itself, only the
 *	data it contains.
 *
 * Results:
 *	None.
 *
 * Side effects:
 *	Storage is freed and the tensor's "data" entry is
 *	set to NULL.
 *
 *---------------------------------------------------------------
 */

void 
Tensor_FreeData(
    Tensor_Descrip *tensorPtr)	/* Pointer to tensor we're
				 * going to free data for	*/
{
    if (tensorPtr->data != ((VOID *) NULL))
	ckfree((ClientData) tensorPtr->data);
    tensorPtr->data = (VOID *) NULL;
}



/*
 *---------------------------------------------------------------
 *
 * Tensor_CheckIndex --
 *
 *	See if a tensor index is within range for a
 *	given tensor.
 *
 * Results:
 *	Returns a standard TCL result.
 *
 * Side effects:
 *	None.
 *
 *---------------------------------------------------------------
 */

int 
Tensor_CheckIndex(
    Tcl_Interp *interp,		/* Tcl interpreter for errors	*/
    Tensor_Descrip *tensorPtr,	/* Pointer to tensor we're
				 * checking against		*/
    Tensor_Index index)		/* Index we're gonna check	*/
{
    int i;
    Tcl_Obj *result;

    for (i = 0; i < tensorPtr->order; i++)
	if (index[i] < 0 || index[i] >= tensorPtr->dims[i]) {
	    result = Tcl_NewStringObj("tensor index ", -1);
	    Tcl_AppendObjToObj(result, Tcl_NewIntObj(i));
	    Tcl_AppendToObj(result, " out of range", -1);
	    Tcl_SetObjResult(interp, result);
	    return (TCL_ERROR);
	}
    return (TCL_OK);
}

/*
 *---------------------------------------------------------------
 *
 * Tensor_NextIndex --
 *
 *	Generates the "next index" in a tensor section. The
 *	section is specified as a starting index (lower bounds)
 *	and an ending index (containing upper bounds).
 *
 * Results:
 *	Returns 1 if the index was successfully advanced,
 *	0 if it went past the ending index.
 *
 * Side effects:
 *	None.
 *
 *---------------------------------------------------------------
 */

int
Tensor_NextIndex(
    int order,			/* Tensor order			*/
    Tensor_Index startIdx,	/* First index in section	*/
    Tensor_Index endIdx,	/* Last index in section	*/
    Tensor_Index elemIdx)	/* Index to advance		*/
{
    int i;

    /*
     * Advance the index array; try the least-significant
     * index first, then the next-least, etc.
     */

    for(i = order - 1; i >= 0; i--) {
	if(elemIdx[i] < endIdx[i]) {
	    /*
	     * We're not at the end of the range for this
	     * index; advance it, and we're done.
	     */
	    elemIdx[i]++;
	    break;
	}
	elemIdx[i] = startIdx[i];
    }

    /*
     * If we didn't hit the end of the range,
     * return "success".
     */
    return(i >= 0);
}

