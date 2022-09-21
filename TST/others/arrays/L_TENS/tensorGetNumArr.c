/*
 * tensorGetNumArr.c --
 *
 *	This file contains code for converting the text
 *	form of a numeric array into a C array.
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
static char rcsid[] = "$Header: /home/neil/src/tcl/tensor/generic/RCS/tensorGetNumArr.c,v 1.3 2008/05/31 18:45:48 neil Exp $";
#endif

#include <tcl.h>
#include "tensor.h"


/*
 *---------------------------------------------------------------
 *
 * Tensor_GetFloatArray --
 *
 *	converts a string to a float array.
 *
 * Results:
 *	returns a standard TCL result.
 *
 * Side effects:
 *	None.
 *
 *---------------------------------------------------------------
 */

int
Tensor_GetFloatArray(
Tcl_Interp *interp,	/* Error messages go here	*/
char *str,		/* String to treat as array	*/
float **fltPtrPtr,	/* Array of floats returned here*/
int *nFltsPtr,		/* Number of floats in array
			 * returned here		*/
int *mustFreePtr)	/* Set to 1 if data must be
			 * freed by ckfree, 0 if it
			 * must NOT be freed		*/
{
    Tensor_Descrip *tensorPtr;
    int i;
    char **itemList;
    double *doublePtr;
    int *intPtr;
    unsigned char *bytePtr;
    unsigned short *shortPtr;
    double d;

    tensorPtr = Tensor_Lookup(interp,str);
    if(tensorPtr != (Tensor_Descrip *) NULL) {
	if(tensorPtr->order != 1) {
	    Tcl_SetObjResult(interp, Tcl_NewStringObj(
		    "array must be order 1 tensor", -1));
	    return(TCL_ERROR);
	}

	*nFltsPtr = tensorPtr->dims[0];
	if(tensorPtr->type == TENSOR_FLOAT) {
	    *fltPtrPtr = (float *) tensorPtr->data;
	    *mustFreePtr = 0;
	    return(TCL_OK);
	}

	*fltPtrPtr = (float *) ckalloc((*nFltsPtr)*sizeof(float));
	if((*fltPtrPtr) == (float *) NULL) {
	    Tcl_SetObjResult(interp,
		Tcl_NewStringObj("out of memory", -1));
	    *mustFreePtr = 0;
	    return(TCL_ERROR);
	}

	*mustFreePtr = 1;
	switch(tensorPtr->type) {
	    case TENSOR_DOUBLE:
		doublePtr = (double *) (tensorPtr->data);
		for(i = 0; i < *nFltsPtr; i++) {
		    (*fltPtrPtr)[i] = doublePtr[i];
		}
		break;

	    case TENSOR_INT:
		intPtr = (int *) (tensorPtr->data);
		for(i = 0; i < *nFltsPtr; i++) {
		    (*fltPtrPtr)[i] = intPtr[i];
		}
		break;

	    case TENSOR_BYTE:
		bytePtr = (unsigned char *) (tensorPtr->data);
		for(i = 0; i < *nFltsPtr; i++) {
		    (*fltPtrPtr)[i] = bytePtr[i];
		}
		break;

	    case TENSOR_SHORT:
		shortPtr = (unsigned short *) (tensorPtr->data);
		for(i = 0; i < *nFltsPtr; i++) {
		    (*fltPtrPtr)[i] = shortPtr[i];
		}
		break;
	}

	return(TCL_OK);
    }

    /* Treat the argument as a TCL list. */

    if(Tcl_SplitList(interp,str,nFltsPtr,&itemList) != TCL_OK) {
	return(TCL_ERROR);
    }

    *fltPtrPtr = (float *) ckalloc((*nFltsPtr)*sizeof(float));
    if((*fltPtrPtr) == (float *) NULL) {
	ckfree((VOID *) itemList);
	Tcl_SetObjResult(interp, Tcl_NewStringObj("out of memory", -1));
	return(TCL_ERROR);
    }
    *mustFreePtr = 1;

    for(i = 0; i < *nFltsPtr; i++) {
	if(Tcl_GetDouble(interp,itemList[i],&d) != TCL_OK) {
	    ckfree((VOID *) (*fltPtrPtr));
	    ckfree((VOID *) itemList);
	    *mustFreePtr = 0;
	    return(TCL_ERROR);
	}

	(*fltPtrPtr)[i] = d;
    }

    ckfree((VOID *) itemList);
    return(TCL_OK);
}


/*
 *---------------------------------------------------------------
 *
 * Tensor_GetDoubleArray --
 *
 *	converts a string to a double array.
 *
 * Results:
 *	returns a standard TCL result.
 *
 * Side effects:
 *	None.
 *
 *---------------------------------------------------------------
 */

int
Tensor_GetDoubleArray(
Tcl_Interp *interp,	/* Error messages go here	*/
char *str,		/* String to treat as array	*/
double **dblPtrPtr,	/* Array of doubles
			 * returned here		*/
int *nDblsPtr,		/* Number of doubles in array
			 * returned here		*/
int *mustFreePtr)	/* Set to 1 if data must be
			 * freed by ckfree, 0 if it
			 * must NOT be freed		*/
{
    Tensor_Descrip *tensorPtr;
    int i;
    char **itemList;
    float *floatPtr;
    int *intPtr;
    unsigned char *bytePtr;
    unsigned short *shortPtr;

    tensorPtr = Tensor_Lookup(interp,str);
    if(tensorPtr != (Tensor_Descrip *) NULL) {
	if(tensorPtr->order != 1) {
	    Tcl_SetObjResult(interp, Tcl_NewStringObj(
		    "array must be order 1 tensor", -1));
	    return(TCL_ERROR);
	}

	*nDblsPtr = tensorPtr->dims[0];
	if(tensorPtr->type == TENSOR_DOUBLE) {
	    *dblPtrPtr = (double *) tensorPtr->data;
	    *mustFreePtr = 0;
	    return(TCL_OK);
	}

	*dblPtrPtr = (double *) ckalloc((*nDblsPtr)*sizeof(double));
	if((*dblPtrPtr) == (double *) NULL) {
	    Tcl_SetObjResult(interp, Tcl_NewStringObj("out of memory", -1));
	    *mustFreePtr = 0;
	    return(TCL_ERROR);
	}

	*mustFreePtr = 1;
	switch(tensorPtr->type) {
	    case TENSOR_FLOAT:
		floatPtr = (float *) (tensorPtr->data);
		for(i = 0; i < *nDblsPtr; i++) {
		    (*dblPtrPtr)[i] = floatPtr[i];
		}
		break;

	    case TENSOR_INT:
		intPtr = (int *) (tensorPtr->data);
		for(i = 0; i < *nDblsPtr; i++) {
		    (*dblPtrPtr)[i] = intPtr[i];
		}
		break;

	    case TENSOR_BYTE:
		bytePtr = (unsigned char *) (tensorPtr->data);
		for(i = 0; i < *nDblsPtr; i++) {
		    (*dblPtrPtr)[i] = bytePtr[i];
		}
		break;

	    case TENSOR_SHORT:
		shortPtr = (unsigned short *) (tensorPtr->data);
		for(i = 0; i < *nDblsPtr; i++) {
		    (*dblPtrPtr)[i] = shortPtr[i];
		}
		break;
	}

	return(TCL_OK);
    }

    /* Treat the argument as a TCL list. */

    if(Tcl_SplitList(interp,str,nDblsPtr,&itemList) != TCL_OK) {
	return(TCL_ERROR);
    }

    *dblPtrPtr = (double *) ckalloc((*nDblsPtr)*sizeof(double));
    if((*dblPtrPtr) == (double *) NULL) {
	ckfree((VOID *) itemList);
	Tcl_SetObjResult(interp, Tcl_NewStringObj("out of memory", -1));
	return(TCL_ERROR);
    }
    *mustFreePtr = 1;

    for(i = 0; i < *nDblsPtr; i++) {
	if(Tcl_GetDouble(interp,itemList[i],&((*dblPtrPtr)[i])) != TCL_OK) {
	    ckfree((VOID *) (*dblPtrPtr));
	    ckfree((VOID *) itemList);
	    *mustFreePtr = 0;
	    return(TCL_ERROR);
	}
    }

    ckfree((VOID *) itemList);
    return(TCL_OK);
}

