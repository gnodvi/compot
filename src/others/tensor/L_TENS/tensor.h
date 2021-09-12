/*
 * tensor.h --
 *
 *	Header file that describes the externally-visible
 *	facilities of the "tensor" package
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
 *
 * $Header: /home/neil/src/tcl/tensor/generic/RCS/tensor.h,v 1.1 2008/05/10 19:18:07 neil Exp $
 *
 */

#ifndef _TENSOR
#define _TENSOR


#include "tcl.h"

#define	TENSOR_VERSION	"4.0"

/* Type Tensor_StringTransEntry is for translating strings to ints. */

typedef struct {
    char *name;
    int value;
} Tensor_StringTransEntry;


/* This is the type we use to index into a tensor. */

#define	TENSOR_MAX_ORDER	16
typedef int Tensor_Index[TENSOR_MAX_ORDER];

/* Tensor descriptor type. */

typedef struct {
    int type;			/* Tensor type: float, double,
				 * int, short, byte		*/
    int order;			/* Order = number of dimensions	*/
    Tensor_Index dims;		/* List of dimensions		*/
    VOID *data;			/* Actual tensor data		*/
} Tensor_Descrip;

/* These symbols denote the different tensor types. */

#define	TENSOR_DOUBLE	0
#define	TENSOR_FLOAT	1
#define	TENSOR_INT	2
#define	TENSOR_BYTE	3
#define	TENSOR_SHORT	4
#define	TENSOR_UNSIGNED	5
#define	TENSOR_MAX_TYPE	5

/* NULL tensor pointer */

#define	TENSOR_NULL	((Tensor_Descrip *) 0)

/* This type is used for "apply" functions. */

typedef double (*Tensor_DoubleFunc)();

/* Include all the external function declarations. */

#include "tensorDecls.h"

#endif



