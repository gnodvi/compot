/* 
 * tensorInt.h --
 *
 *	Header file for the Tensor package's internals.
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
 * $Header: /home/neil/src/tcl/tensor/generic/RCS/tensorInt.h,v 1.8 2008/07/04 20:04:59 neil Exp $
 */

#ifndef _TENSORINT
#define _TENSORINT

#include "tensor.h"


/* These are symbolic names for comparison operators. */

#define _TENSOR_ALWAYS	0
#define	_TENSOR_COMP_EQ	1
#define	_TENSOR_COMP_NE	2
#define	_TENSOR_COMP_GT	3
#define	_TENSOR_COMP_GE	4
#define	_TENSOR_COMP_LT	5
#define	_TENSOR_COMP_LE	6

/* tensorConv.c */
EXTERN int TensorGetDims (Tcl_Interp *interp, Tcl_Obj *obj, int *orderPtr, Tensor_Index indices);
EXTERN int TensorGetSectionIndex (Tcl_Interp *interp, Tcl_Obj *obj, Tensor_Descrip *tensorPtr, Tensor_Index lowIndices, Tensor_Index highIndices);
EXTERN int TensorGet (Tcl_Interp *interp, Tcl_Obj *obj, Tensor_Descrip *tensorPtr);
EXTERN int TensorPutSection (Tcl_Interp *interp, Tensor_Descrip *tensorPtr, Tensor_Index lowIdx, Tensor_Index highIdx);

/* tensorExpr.c */
EXTERN int TensorExprCmd (ClientData clientData, Tcl_Interp *interp, int objc, Tcl_Obj *CONST objv[]);

/* tensorOps.c */
EXTERN void TensorSectionDims (int inOrder, Tensor_Index lowIndices, Tensor_Index highIndices, int *outOrderPtr, Tensor_Index sectionSize, Tensor_Index indexMap);
EXTERN int TensorCopySection (Tcl_Interp *interp, Tensor_Descrip *destTensorPtr, Tensor_Index destLowIndices, Tensor_Index destHighIndices, Tensor_Descrip *srcTensorPtr, Tensor_Index srcLowIndices, Tensor_Index srcHighIndices);
EXTERN int TensorOpScalar (Tcl_Interp *interp, Tensor_Descrip *destTensorPtr, Tensor_Index destLowIndices, Tensor_Index destHighIndices, int op, double s);
EXTERN int TensorOpTensor (Tcl_Interp *interp, Tensor_Descrip *destTensorPtr, Tensor_Index destLowIndices, Tensor_Index destHighIndices, int op, Tensor_Descrip *srcTensorPtr, Tensor_Index srcLowIndices, Tensor_Index srcHighIndices);
EXTERN int TensorContract (Tcl_Interp *interp, Tensor_Descrip *operandPtr, int llength, int idxList[16 ], Tensor_Descrip *resultPtr);
EXTERN int TensorMultiply (Tcl_Interp *interp, Tensor_Descrip *tensorPtrArray[2], int idxList[2], Tensor_Descrip *resultPtr);
EXTERN int TensorOuterProduct (Tcl_Interp *interp, Tensor_Descrip *tensorPtrArray[2], Tensor_Descrip *resultPtr);
EXTERN int TensorFlipIndices (Tcl_Interp *interp, Tensor_Descrip *tensorPtr, Tensor_Index idxList, int nIndices);
EXTERN int TensorPermuteIndices (Tcl_Interp *interp, Tensor_Descrip *tensorPtr, Tensor_Index idxList, int nIndices);
EXTERN int TensorCmpScalar (Tcl_Interp *interp, Tensor_Descrip *tensorPtr, Tensor_Index cmpLowIndices, Tensor_Index cmpHighIndices, int op, double s);
EXTERN int TensorCmpTensor (Tcl_Interp *interp, Tensor_Descrip *firstTensorPtr, Tensor_Index firstLowIndices, Tensor_Index firstHighIndices, int op, Tensor_Descrip *secondTensorPtr, Tensor_Index secodLowIndices, Tensor_Index secondHighIndices);
EXTERN int TensorListIndicesScalar (Tcl_Interp *interp, Tensor_Descrip *tensorPtr, Tensor_Index cmpLowIndices, Tensor_Index cmpHighIndices, int *componentList, int nComponents, int op, double s);
EXTERN int TensorListIndicesTensor (Tcl_Interp *interp, Tensor_Descrip *firstTensorPtr, Tensor_Index firstLowIndices, Tensor_Index firstHighIndices, int *componentList, int nComponents, int op, Tensor_Descrip *secondTensorPtr, Tensor_Index secodLowIndices, Tensor_Index secondHighIndices);
EXTERN int TensorMinMax (Tcl_Interp *interp, Tensor_Descrip *tensor, Tensor_Index low_indices, Tensor_Index high_indices, int getIndices);
EXTERN int TensorApplyFunc (Tcl_Interp *interp, Tensor_Descrip *tensorPtr, Tensor_Index lowIndices, Tensor_Index highIndices, char *funcName);
EXTERN void TensorSaturate (Tensor_Descrip *tensor, Tensor_Index lowIdx, Tensor_Index highIdx, double minVal, double maxVal);
EXTERN void TensorSubst (Tensor_Descrip *tensor, Tensor_Index lowIdx, Tensor_Index highIdx, int tabSize, double *substTab);
EXTERN void TensorSequ (Tensor_Descrip *tensor, Tensor_Index lowIdx, Tensor_Index highIdx);
EXTERN int TensorFormatOK (char *format, int type);
EXTERN void TensorPutIntoArray (Tcl_Interp *interp, Tensor_Descrip *tensor, Tensor_Index lowIdx, Tensor_Index highIdx, Tcl_Obj *arrayName, int arraySelCond, double arrayCompVal, Tensor_Index offset);
EXTERN int TensorSwap (Tcl_Interp *interp, Tensor_Descrip *tensorPtr, int dimNo, int *idxList);
EXTERN int TensorPermute (Tcl_Interp *interp, Tensor_Descrip *tensorPtr, int dimNo, int *idxList);
EXTERN int TensorDelete (Tcl_Interp *interp, Tensor_Descrip *tensorPtr, int dimNo, int nDel, int *idxList);
EXTERN int TensorInsert (Tcl_Interp *interp, Tensor_Descrip *tensorPtr, int nItems, int dimNo, int pos);
EXTERN int TensorBoolScalar (Tcl_Interp *interp, Tensor_Descrip *boolOp1Ptr, Tensor_Index op1LowIndices, Tensor_Index op1HighIndices, char boolOp, double compNo, Tensor_Descrip *srcTensorPtr);
EXTERN int TensorBoolTensor (Tcl_Interp *interp, Tensor_Descrip *boolOp1Ptr, Tensor_Index op1LowIndices, Tensor_Index op1HighIndices, Tensor_Descrip *boolOp2Ptr, Tensor_Index op2LowIndices, Tensor_Index op2HighIndices, char boolOp, Tensor_Descrip *srcTensorPtr);

/* tensorIO.c */
EXTERN int TensorRead (Tcl_Interp *interp, Tensor_Descrip *tensorPtr, Tcl_Channel channel);
EXTERN int TensorWrite (Tcl_Interp *interp, Tensor_Descrip *tensorPtr, Tcl_Channel channel, int bin_format);
EXTERN int TensorWriteSection (Tcl_Interp *interp, Tensor_Descrip *tensorPtr, Tensor_Index lowIndices, Tensor_Index highIndices, Tcl_Channel channel, int bin_fmt);
EXTERN int TensorReadSection (Tcl_Interp *interp, Tensor_Descrip *tensorPtr, Tensor_Index lowIndices, Tensor_Index highIndices, Tcl_Channel channel);

#endif



