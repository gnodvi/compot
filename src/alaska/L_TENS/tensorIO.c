
/*
 * tensorIO.c --
 *
 *	Code for reading tensors from, and writing
 *	them to, files.
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
static char rcsid[] = "$Header: /home/neil/src/tcl/tensor/generic/RCS/tensorIO.c,v 1.4 2008/05/31 19:09:56 neil Exp $";
#endif

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include "tcl.h"
#include "tensorInt.h"

#ifndef EOF
#define EOF -1
#endif

/*
 *---------------------------------------------------------------
 *
 * ReadBinTensorFile --
 *
 *      reads a binary-format tensor file. Note that this
 *	does NOT read the magic number: if the magic number
 *	had not already been read, we wouldn't know the
 *	file type.
 *
 * Results:
 *      The function returns a standard TCL result.
 *
 * Side effects:
 *      The target tensor's order, dimensions, and type are
 *	set, its data is allocated, and its contents are
 *	set. Data is consumed from the input channel. NOTE:
 *	the target tensor's data should NOT be allocated
 *	when it is passed to this routine. If it is, then
 *	the data will NOT be freed.
 *
 *---------------------------------------------------------------
 */


static int 
ReadBinTensorFile(
    Tcl_Interp *interp,		/* For error messages		*/
    Tensor_Descrip *tensorPtr,	/* Tensor we're gonna read	*/
    Tcl_Channel channel)	/* Channel we're reading from	*/
{
    int nElements, nBytes;
    Tcl_DString transModeSave;

    /* Save the current translation mode, and switch to binary. */

    Tcl_DStringInit(&transModeSave);
    if(Tcl_GetChannelOption(interp, channel, "-translation", &transModeSave) != TCL_OK) {
	Tcl_DStringFree(&transModeSave);
	return(TCL_ERROR);
    }
    if(Tcl_SetChannelOption(interp, channel, "-translation", "binary") != TCL_OK) {
	Tcl_DStringFree(&transModeSave);
	return(TCL_ERROR);
    }

    /* Read the tensor order. */

    if (Tcl_Read(channel, (char *) &(tensorPtr->order), sizeof(tensorPtr->order))
	    != sizeof(tensorPtr->order)) {
	Tcl_SetChannelOption(interp, channel,
		"-translation", Tcl_DStringValue(&transModeSave));
	Tcl_DStringFree(&transModeSave);
	Tcl_SetObjResult(interp, Tcl_NewStringObj(
	    "Error reading tensor order from binary tensor file", -1));
	return (TCL_ERROR);
    }

    if (tensorPtr->order > TENSOR_MAX_ORDER) {
	Tcl_SetChannelOption(interp, channel,
		"-translation", Tcl_DStringValue(&transModeSave));
	Tcl_DStringFree(&transModeSave);
	Tcl_SetObjResult(interp, Tcl_NewStringObj(
	     "Tensor order from binary tensor file is too large", -1));
	return (TCL_ERROR);
    }

    /* Read the tensor dimensions. */

    nBytes = sizeof(tensorPtr->dims[0])*(tensorPtr->order);
    if (Tcl_Read(channel, (char *) (tensorPtr->dims), nBytes) != nBytes) {
	Tcl_SetChannelOption(interp, channel,
		"-translation", Tcl_DStringValue(&transModeSave));
	Tcl_DStringFree(&transModeSave);
	Tcl_SetObjResult(interp, Tcl_NewStringObj(
	    "Error reading tensor dimensions from binary tensor file", -1));
	return (TCL_ERROR);
    }

    /* Allocate storage and read the tensor data. */

    if (Tensor_AllocData(interp, tensorPtr) != TCL_OK) {
	Tcl_SetChannelOption(interp, channel,
		"-translation", Tcl_DStringValue(&transModeSave));
	Tcl_DStringFree(&transModeSave);
	return (TCL_ERROR);
    }

    nElements = Tensor_NElements(tensorPtr);
    nBytes = nElements*Tensor_ElemSize(tensorPtr->type);
    if (Tcl_Read(channel, tensorPtr->data, nBytes) != nBytes) {
	Tensor_FreeData(tensorPtr);
	Tcl_SetChannelOption(interp, channel,
		"-translation", Tcl_DStringValue(&transModeSave));
	Tcl_DStringFree(&transModeSave);
	Tcl_SetObjResult(interp, Tcl_NewStringObj(
	     "Error reading tensor data from binary tensor file", -1));
	return (TCL_ERROR);
    }

    /* Clean up and return. */

    Tcl_SetChannelOption(interp, channel,
		"-translation", Tcl_DStringValue(&transModeSave));
    Tcl_DStringFree(&transModeSave);
    return (TCL_OK);
}

/*
 *---------------------------------------------------------------
 *
 * ChanGetc --
 *
 *      Reads a single character from a channel.
 *
 * Results:
 *      The function returns the character, or EOF.
 *
 * Side effects:
 *      Data gets read from "channel".
 *
 *---------------------------------------------------------------
 */

static int
ChanGetc(Tcl_Channel channel)
{
    char buf;

    if(Tcl_Eof(channel)) {
	return(EOF);
    }

    if(Tcl_Read(channel,&buf,1) != 1) {
	return(EOF);
    }

    return((int) buf);
}

/*
 *---------------------------------------------------------------
 *
 * ReadAnInt --
 *
 *      Reads an integer, written on a single line, from a
 *	Tcl file channel. The int is returned in *intPtr.
 *
 * Results:
 *      The function returns a standard TCL result.
 *
 * Side effects:
 *      Data gets read from "channel".
 *
 *---------------------------------------------------------------
 */

static int
ReadAnInt(
    Tcl_Interp *interp,
    Tcl_Channel channel,
    int *intPtr)
{
    Tcl_DString line;
    char **stringArray;
    int nStrings;
    int retcode;

    Tcl_DStringInit(&line);

    /* Read the tensor order. */

    if (Tcl_Gets(channel,&line) <= 0) {
	Tcl_DStringFree(&line);
	Tcl_SetObjResult(interp, Tcl_NewStringObj("Error reading integer", -1));
	return (TCL_ERROR);
    }

    if(Tcl_SplitList(interp,Tcl_DStringValue(&line),&nStrings,&stringArray) != TCL_OK) {
	Tcl_DStringFree(&line);
	return (TCL_ERROR);
    }

    Tcl_DStringFree(&line);

    if(nStrings != 1) {
	ckfree((VOID *) stringArray);
	Tcl_SetObjResult(interp, Tcl_NewStringObj(
	     "Error reading integer: should have 1 item per line", -1));
	return (TCL_ERROR);
    }


    retcode = Tcl_GetInt(interp,stringArray[0],intPtr);
    ckfree((VOID *) stringArray);
    return (retcode);
}

/*
 *---------------------------------------------------------------
 *
 * ReadADouble --
 *
 *      Reads a double, written on a single line, from a
 *	Tcl file channel. The double is returned in *dblPtr.
 *
 * Results:
 *      The function returns a standard TCL result.
 *
 * Side effects:
 *      Data gets read from "channel".
 *
 *---------------------------------------------------------------
 */

static int
ReadADouble(
    Tcl_Interp *interp,
    Tcl_Channel channel,
    double *dblPtr)
{
    Tcl_DString line;
    char **stringArray;
    int nStrings;
    int retcode;

    Tcl_DStringInit(&line);

    /* Read the tensor order. */

    if (Tcl_Gets(channel,&line) <= 0) {
	Tcl_DStringFree(&line);
	Tcl_SetObjResult(interp, Tcl_NewStringObj("Error reading double", -1));
	return (TCL_ERROR);
    }

    if(Tcl_SplitList(interp,Tcl_DStringValue(&line),&nStrings,&stringArray) != TCL_OK) {
	Tcl_DStringFree(&line);
	return (TCL_ERROR);
    }

    Tcl_DStringFree(&line);

    if(nStrings != 1) {
	ckfree((VOID *) stringArray);
	Tcl_SetObjResult(interp, Tcl_NewStringObj(
	     "Error reading double: should have 1 item per line", -1));
	return (TCL_ERROR);
    }


    retcode = Tcl_GetDouble(interp,stringArray[0],dblPtr);
    ckfree((VOID *) stringArray);
    return (retcode);
}

/*
 *---------------------------------------------------------------
 *
 * ReadAsciiTensorFile --
 *
 *      reads an ascii-format tensor file. Note that this
 *	does NOT read the magic number: if the magic number
 *	had not already been read, we wouldn't know the
 *	file type.
 *
 * Results:
 *      The function returns a standard TCL result.
 *
 * Side effects:
 *      The target tensor's order, dimensions, and type are
 *	set, its data is allocated, and its contents are
 *	set. Data is consumed from the input file. NOTE:
 *	the target tensor's data should NOT be allocated
 *	when it is passed to this routine. If it is, then
 *	the data will NOT be freed.
 *
 *---------------------------------------------------------------
 */


static int 
ReadAsciiTensorFile(
    Tcl_Interp *interp,		/* For error messages		*/
    Tensor_Descrip *tensorPtr,	/* Tensor we're reading into	*/
    Tcl_Channel channel)	/* Channel we're reading from	*/
{
    int i, j;
    double d;
    char *elPtr;
    int nElements, elSize;

    /* Read the tensor order. */

    if (ReadAnInt(interp,channel,&j) != TCL_OK) {
	return (TCL_ERROR);
    }

    if (j > TENSOR_MAX_ORDER || j < 0) {
	Tcl_SetObjResult(interp, Tcl_NewStringObj(
	      "Tensor order from ASCII tensor file is too large", -1));
	return (TCL_ERROR);
    }

    tensorPtr->order = j;

    /* Read the tensor dimensions. */

    for (i = 0; i < tensorPtr->order; i++) {
	if(ReadAnInt(interp,channel,&j) != TCL_OK) {
	    return(TCL_ERROR);
	}
	tensorPtr->dims[i] = j;
    }

    /* Allocate storage and read the tensor data. */

    if (Tensor_AllocData(interp, tensorPtr) != TCL_OK) {
	return (TCL_ERROR);
    }

    nElements = Tensor_NElements(tensorPtr);
    elSize = Tensor_ElemSize(tensorPtr->type);

    switch (tensorPtr->type) {
	case TENSOR_DOUBLE:
	    for (i = 0, elPtr = (char *) tensorPtr->data;
		    i < nElements; i++, elPtr += elSize) {
		if(ReadADouble(interp,channel,&d) != TCL_OK) {
		    return(TCL_ERROR);
		}
		*((double *) elPtr) = d;
	    }
	    break;

	case TENSOR_FLOAT:
	    for (i = 0, elPtr = (char *) tensorPtr->data;
		    i < nElements; i++, elPtr += elSize) {
		if(ReadADouble(interp,channel,&d) != TCL_OK) {
		    return(TCL_ERROR);
		}
		*((float *) elPtr) = d;
	    }
	    break;

	case TENSOR_INT:
	    for (i = 0, elPtr = (char *) tensorPtr->data;
		    i < nElements; i++, elPtr += elSize) {
		if(ReadAnInt(interp,channel,&j) != TCL_OK) {
		    return(TCL_ERROR);
		}
		*((int *) elPtr) = j;
	    }
	    break;

	case TENSOR_BYTE:
	    for (i = 0, elPtr = (char *) tensorPtr->data;
		    i < nElements; i++, elPtr += elSize) {
		if(ReadAnInt(interp,channel,&j) != TCL_OK) {
		    return(TCL_ERROR);
		}
		*((unsigned char *) elPtr) = j;
	    }
	    break;

	case TENSOR_SHORT:
	    for (i = 0, elPtr = (char *) tensorPtr->data;
		    i < nElements; i++, elPtr += elSize) {
		if(ReadAnInt(interp,channel,&j) != TCL_OK) {
		    return(TCL_ERROR);
		}
		*((unsigned short *) elPtr) = j;
	    }
	    break;

	case TENSOR_UNSIGNED:
	    for (i = 0, elPtr = (char *) tensorPtr->data;
		    i < nElements; i++, elPtr += elSize) {
		if(ReadAnInt(interp,channel,&j) != TCL_OK) {
		    return(TCL_ERROR);
		}
		*((unsigned int *) elPtr) = j;
	    }
	    break;
    }

    return (TCL_OK);
}

/*
 *---------------------------------------------------------------
 *
 * GetNumber --
 *
 *      reads an unsigned (ASCII-format) integer from a file,
 *	skipping leading whitespace and comments. (Comments
 *	begin with '#' and end with a newline.
 *
 * Results:
 *      The function returns a standard TCL result.
 *
 * Side effects:
 *      The input file is read, and the 1-character
 *	lookahead buffer (passed in as chPtr) changes.
 *
 *---------------------------------------------------------------
 */


static int 
GetNumber(
    Tcl_Interp *interp,	/* For error messages		*/
    char *msg,		/* Message to append to error
			 * message returned in interp	*/
    Tcl_Channel channel,/* Input channel		*/
    int *chPtr,		/* First character goes in,
			 * terminating non-digit comes
			 * out. (1-char lookahead)	*/
    int *numberPtr)	/* Number we read from file	*/
{
    Tcl_Obj *result;

    /* Skip whitespace and comments. */

    for (;;) {
	while (*chPtr == '#') {
	    while (*chPtr != '\n' && *chPtr != EOF) {
		*chPtr = ChanGetc(channel);
	    }
	    if(*chPtr == '\n') {
		*chPtr = ChanGetc(channel);
	    }
	}

	if (*chPtr == EOF) {
	    result = Tcl_NewStringObj("Premature EOF while reading ", -1);
	    Tcl_AppendToObj(result, msg, -1);
	    Tcl_SetObjResult(interp, result);
	    return (TCL_ERROR);
	}
	if (!isspace(*chPtr))
	    break;
	*chPtr = ChanGetc(channel);
    }

    /* Get a number. */

    if (!isdigit(*chPtr)) {
	result = Tcl_NewStringObj("Unexpected non-digit in ", -1);
	Tcl_AppendToObj(result, msg, -1);
	Tcl_SetObjResult(interp, result);
	return (TCL_ERROR);
    }
    *numberPtr = 0;
    for (;;) {
	*numberPtr = 10 * (*numberPtr) + *chPtr - '0';
	*chPtr = ChanGetc(channel);
	if (!isdigit(*chPtr)) {
	    break;
	}
    }

    return (TCL_OK);
}


/*
 *---------------------------------------------------------------
 *
 * ReadPmHeader --
 *
 *      reads the header of a pbm, pgm, or ppm file.
 *
 * Results:
 *	Gets the file type (an ascii digit between '1' and
 *	'6' inclusive; see the documentation for pbmPlus),
 *	the image width and height, and the maximum pixel
 *	value. The function returns a standard TCL result.
 *
 * Side effects:
 *      The input file is read.
 *
 *---------------------------------------------------------------
 */


static int 
ReadPmHeader(
    Tcl_Interp *interp,	/* For error messages		*/
    Tcl_Channel channel,/* Input channel		*/
    int *typePtr,	/* File type (image format)	*/
    int *widthPtr,	/* Image width			*/
    int *heightPtr,	/* Image height			*/
    int *maxvalPtr)	/* Maximum pizel value		*/
{
    Tcl_Obj *result;
    char junkstr[32];
    int ch;

    /* Read the file type. */

    *typePtr = ChanGetc(channel);
    if (*typePtr == EOF) {
	Tcl_SetObjResult(interp, Tcl_NewStringObj(
	  "Premature EOF in PM file: couldn't read magic number", -1));
	return (TCL_ERROR);
    }
    if (*typePtr < '1' || *typePtr > '6') {
	junkstr[0] = 'P';
	junkstr[1] = *typePtr;
	junkstr[2] = '\0';
	result = Tcl_NewStringObj("Unknown PM file magic number \"", -1);
	Tcl_AppendToObj(result, junkstr, -1);
	Tcl_SetObjResult(interp, result);
	return (TCL_ERROR);
    }
    ch = ChanGetc(channel);

    /* Read the width and height. */

    if (GetNumber(interp, "PM file header", channel,
		   &ch, widthPtr) != TCL_OK)
	return (TCL_ERROR);
    if (GetNumber(interp, "PM file header", channel,
		   &ch, heightPtr) != TCL_OK)
	return (TCL_ERROR);

    /* Read the maximum pixel value, if appropriate. */

    switch (*typePtr) {
	case '1':
	case '4':
	    break;

	case '2':
	case '3':
	case '5':
	case '6':
	    if (GetNumber(interp, "PM file header", channel,
			   &ch, maxvalPtr) != TCL_OK)
		return (TCL_ERROR);
	    break;
    }

    return (TCL_OK);
}

/*
 *---------------------------------------------------------------
 *
 * ReadBinPbmFile --
 *
 *      reads a binary-format PBM image file. Note that this
 *	does NOT read the file header: if the file header
 *	had not already been read, we wouldn't know the
 *	file type.
 *
 * Results:
 *      The function returns a standard TCL result.
 *
 * Side effects:
 *      The target tensor's order, dimensions, and type are
 *	set, its data is allocated, and its contents are
 *	set. Data is consumed from the input file. NOTE:
 *	the target tensor's data should NOT be allocated
 *	when it is passed to this routine. If it is, then
 *	the data will NOT be freed.
 *
 *---------------------------------------------------------------
 */


static int 
ReadBinPbmFile(
    Tcl_Interp *interp,		/* For error messages		*/
    Tensor_Descrip *tensorPtr,	/* Tensor we're reading		*/
    Tcl_Channel channel,	/* Input channel		*/
    int width,			/* Image width			*/
    int height)			/* Image height			*/
{
    int i, j;
    int n_elements;
    int n_complete_bytes, bits_left;
    unsigned char *el_ptr;
    int ch;

    /* Set the tensor type, order, and size. */

    tensorPtr->type = TENSOR_BYTE;
    tensorPtr->order = 2;
    tensorPtr->dims[0] = height;
    tensorPtr->dims[1] = width;

    /* Allocate storage. */

    if (Tensor_AllocData(interp, tensorPtr) != TCL_OK) {
	return (TCL_ERROR);
    }
    n_elements = Tensor_NElements(tensorPtr);

    /* Read complete bytes. */

    n_complete_bytes = n_elements / 8;
    for (i = 0, el_ptr = (unsigned char *) tensorPtr->data;
	 i < n_complete_bytes; i++, el_ptr += 8) {

	/* Get a byte. */

	ch = ChanGetc(channel);
	if (ch == EOF) {
	    Tensor_FreeData(tensorPtr);
	    Tcl_SetObjResult(interp, Tcl_NewStringObj(
		     "Error reading data from binary PBM file: premature EOF",
			  -1));
	    return (TCL_ERROR);
	}
	/* Unpack it. */

	for (j = 0; j < 8; j++) {
	    if (ch & 0x80) {
		el_ptr[j] = 0;
	    } else {
		el_ptr[j] = 255;
	    }
	    ch <<= 1;
	}
    }

    /* Read and unpack the last byte, if there's one left. */

    bits_left = n_elements % 8;
    if (bits_left > 0) {
	ch = ChanGetc(channel);
	if (ch == EOF) {
	    Tensor_FreeData(tensorPtr);
	    Tcl_SetObjResult(interp, Tcl_NewStringObj(
		 "Error reading data from binary PBM file: last byte missing",
			  -1));
	    return (TCL_ERROR);
	}
	for (i = 0; i < bits_left; i++) {
	    if (ch & 0x80) {
		el_ptr[i] = 0;
	    } else {
		el_ptr[i] = 255;
	    }
	    ch <<= 1;
	}
    }

    /* We're done! */

    return (TCL_OK);
}

/*
 *---------------------------------------------------------------
 *
 * ReadAsciiPbmFile --
 *
 *      reads an ascii-format PBM image file. Note that this
 *	does NOT read the file header: if the header had not
 *	already been read, we wouldn't know the file type.
 *
 * Results:
 *      The function returns a standard TCL result.
 *
 * Side effects:
 *      The target tensor's order, dimensions, and type are
 *	set, its data is allocated, and its contents are
 *	set. Data is consumed from the input file. NOTE:
 *	the target tensor's data should NOT be allocated
 *	when it is passed to this routine. If it is, then
 *	the data will NOT be freed.
 *
 *---------------------------------------------------------------
 */


static int 
ReadAsciiPbmFile(
    Tcl_Interp *interp,		/* For error messages		*/
    Tensor_Descrip *tensorPtr,	/* Tensor we're reading		*/
    Tcl_Channel channel,	/* Input channel		*/
    int width,			/* Image width			*/
    int height)			/* Image height			*/
{
    int i, n_elements;
    char junkstr[32];
    Tcl_Obj *result;
    unsigned char *el_ptr;
    int ch;

    /* Set the tensor type, order, and size. */

    tensorPtr->type = TENSOR_BYTE;
    tensorPtr->order = 2;
    tensorPtr->dims[0] = height;
    tensorPtr->dims[1] = width;

    /* Allocate storage. */

    if (Tensor_AllocData(interp, tensorPtr) != TCL_OK)
	return (TCL_ERROR);

    /* Read the data. */

    n_elements = Tensor_NElements(tensorPtr);
    for (i = 0, el_ptr = (unsigned char *) tensorPtr->data;
	 i < n_elements; i++, el_ptr++) {
	for (;;) {
	    ch = ChanGetc(channel);
	    if (ch == EOF) {
		Tensor_FreeData(tensorPtr);
		Tcl_SetObjResult(interp, Tcl_NewStringObj(
		      "Error reading data from ASCII PBM file: premature EOF",
			      -1));
		return (TCL_ERROR);
	    }
	    if (ch == '0' || ch == '1')
		break;

	    if (ch == '#') {
		while (ch != '\n' && ch != EOF)
		    ch = ChanGetc(channel);
	    } else if (!isspace(ch)) {
		Tensor_FreeData(tensorPtr);
		junkstr[0] = ch;
		junkstr[1] = '\0';
		result = Tcl_NewStringObj("Illegal character \"", -1);
		Tcl_AppendToObj(result, junkstr, -1);
		Tcl_AppendToObj(result, "\" encountered in PBM file data", -1);
		Tcl_SetObjResult(interp, result);
		return (TCL_ERROR);
	    }
	}

	if (ch == '0')
	    *el_ptr = 255;
	else
	    *el_ptr = 0;
    }

    return (TCL_OK);
}


/*
 *---------------------------------------------------------------
 *
 * ReadBinPgmFile --
 *
 *      reads a binary-format PGM image file. Note that this
 *	does NOT read the file header: if the header had not
 *	already been read, we wouldn't know the file type.
 *
 * Results:
 *      The function returns a standard TCL result.
 *
 * Side effects:
 *      The target tensor's order, dimensions, and type are
 *	set, its data is allocated, and its contents are
 *	set. Data is consumed from the input file. NOTE:
 *	the target tensor's data should NOT be allocated
 *	when it is passed to this routine. If it is, then
 *	the data will NOT be freed.
 *
 *---------------------------------------------------------------
 */

static int 
ReadBinPgmFile(
    Tcl_Interp *interp,		/* For error messages		*/
    Tensor_Descrip *tensorPtr,	/* Tensor we're reading		*/
    Tcl_Channel channel,	/* Input channel		*/
    int width,			/* Image width			*/
    int height,			/* Image height			*/
    int maxval)			/* Maximum pixel value		*/
{
    int i, n_elements;
    unsigned char *el_ptr;
    unsigned char bp;
    double dp;

    /* Sanity checks. */

    if (maxval <= 0) {
	Tcl_SetObjResult(interp, Tcl_NewStringObj(
		      "Binary PGM file has maxval <= 0!", -1));
	return (TCL_ERROR);
    }
    if (maxval > 255) {
	Tcl_SetObjResult(interp, Tcl_NewStringObj(
		      "Binary PGM file has maxval > 255!", -1));
	return (TCL_ERROR);
    }

    /* Set the tensor type, order, and size. */

    tensorPtr->type = TENSOR_BYTE;
    tensorPtr->order = 2;
    tensorPtr->dims[0] = height;
    tensorPtr->dims[1] = width;

    /* Allocate storage. */

    if (Tensor_AllocData(interp, tensorPtr) != TCL_OK) {
	return (TCL_ERROR);
    }
    n_elements = Tensor_NElements(tensorPtr);

    /* Read and rescale the data. */

    for (i = 0, el_ptr = (unsigned char *) tensorPtr->data;
	    i < n_elements; i++, el_ptr++) {
	if (Tcl_Read(channel,(char *) &bp, sizeof(bp)) != sizeof(bp)) {
	    Tensor_FreeData(tensorPtr);
	    Tcl_SetObjResult(interp, Tcl_NewStringObj(
		"Premature EOF while reading data from PGM file", -1));
	    return (TCL_ERROR);
	}
	dp = bp;
	dp = dp * 255.0 / maxval + 0.5;
	if (dp > 255) {
	    dp = 255.0;
	}

	*el_ptr = dp;
    }

    return (TCL_OK);
}

/*
 *---------------------------------------------------------------
 *
 * ReadAsciiPgmFile --
 *
 *      reads an ascii-format PGM image file. Note that this
 *	does NOT read the file header: if the header had not
 *	already been read, we wouldn't know the file type.
 *
 * Results:
 *      The function returns a standard TCL result.
 *
 * Side effects:
 *      The target tensor's order, dimensions, and type are
 *	set, its data is allocated, and its contents are
 *	set. Data is consumed from the input file. NOTE:
 *	the target tensor's data should NOT be allocated
 *	when it is passed to this routine. If it is, then
 *	the data will NOT be freed.
 *
 *---------------------------------------------------------------
 */


static int 
ReadAsciiPgmFile(
    Tcl_Interp *interp,		/* For error messages		*/
    Tensor_Descrip *tensorPtr,	/* Tensor we're reading		*/
    Tcl_Channel channel,	/* Input channel		*/
    int width,			/* Image width			*/
    int height,			/* Image height			*/
    int maxval)			/* Maximum pixel value		*/
{
    int i, ch, n_elements;
    unsigned char *el_ptr;
    int ip;
    double dp;

    /* Sanity checks. */

    if (maxval <= 0) {
	Tcl_SetObjResult(interp, Tcl_NewStringObj(
		      "Binary PGM file has maxval <= 0!", -1));
	return (TCL_ERROR);
    }
    /* Set the tensor type, order, and size. */

    tensorPtr->type = TENSOR_BYTE;
    tensorPtr->order = 2;
    tensorPtr->dims[0] = height;
    tensorPtr->dims[1] = width;

    /* Allocate storage. */

    if (Tensor_AllocData(interp, tensorPtr) != TCL_OK)
	return (TCL_ERROR);
    n_elements = Tensor_NElements(tensorPtr);

    /* Read and rescale the data. */

    ch = ChanGetc(channel);
    for (i = 0, el_ptr = (unsigned char *) tensorPtr->data;
	 i < n_elements; i++, el_ptr++) {
	if (GetNumber(interp, "ASCII PGM file data", channel,
		       &ch, &ip) != TCL_OK) {
	    Tensor_FreeData(tensorPtr);
	    return (TCL_ERROR);
	}
	dp = ip;
	dp = dp * 255.0 / maxval + 0.5;
	if (dp > 255.0)
	    dp = 255.0;

	*el_ptr = dp;
    }

    return (TCL_OK);
}

/*
 *---------------------------------------------------------------
 *
 * ReadBinPpmFile --
 *
 *      reads a binary-format PPM image file. Note that this
 *	does NOT read the file header: if the header had not
 *	already been read, we wouldn't know the file type.
 *
 * Results:
 *      The function returns a standard TCL result.
 *
 * Side effects:
 *      The target tensor's order, dimensions, and type are
 *	set, its data is allocated, and its contents are
 *	set. Data is consumed from the input file. NOTE:
 *	the target tensor's data should NOT be allocated
 *	when it is passed to this routine. If it is, then
 *	the data will NOT be freed.
 *
 *---------------------------------------------------------------
 */


static int 
ReadBinPpmFile(
    Tcl_Interp *interp,		/* For error messages		*/
    Tensor_Descrip *tensorPtr,	/* Tensor we're reading		*/
    Tcl_Channel channel,	/* Input channel		*/
    int width,			/* Image width			*/
    int height,			/* Image height			*/
    int maxval)			/* Maximum pixel value		*/
{
    int i, n_elements;
    unsigned char *el_ptr;
    unsigned char bp;
    double dp;

    /* Sanity checks. */

    if (maxval <= 0) {
	Tcl_SetObjResult(interp, Tcl_NewStringObj(
		      "Binary PPM file has maxval <= 0!", -1));
	return (TCL_ERROR);
    }
    if (maxval > 255) {
	Tcl_SetObjResult(interp, Tcl_NewStringObj(
		      "Binary PPM file has maxval > 255!", -1));
	return (TCL_ERROR);
    }
    /* Set the tensor type, order, and size. */

    tensorPtr->type = TENSOR_BYTE;
    tensorPtr->order = 3;
    tensorPtr->dims[0] = height;
    tensorPtr->dims[1] = width;
    tensorPtr->dims[2] = 3;

    /* Allocate storage. */

    if (Tensor_AllocData(interp, tensorPtr) != TCL_OK) {
	return (TCL_ERROR);
    }
    n_elements = Tensor_NElements(tensorPtr);

    /* Read and rescale the data. */

    for (i = 0, el_ptr = (unsigned char *) tensorPtr->data;
	    i < n_elements; i++, el_ptr++) {
	if (Tcl_Read(channel, (char *) &bp, sizeof(bp)) != sizeof(bp)) {
	    Tensor_FreeData(tensorPtr);
	    Tcl_SetObjResult(interp, Tcl_NewStringObj(
		"Premature EOF while reading data from PGM file", -1));
	    return (TCL_ERROR);
	}
	dp = bp;
	dp = dp * 255.0 / maxval + 0.5;
	if (dp > 255) {
	    dp = 255.0;
	}

	*el_ptr = dp;
    }

    return (TCL_OK);
}


/*
 *---------------------------------------------------------------
 *
 * ReadAsciiPpmFile --
 *
 *      reads an ascii-format PPM image file. Note that this
 *	does NOT read the file header: if the header had not
 *	already been read, we wouldn't know the file type.
 *
 * Results:
 *      The function returns a standard TCL result.
 *
 * Side effects:
 *      The target tensor's order, dimensions, and type are
 *	set, its data is allocated, and its contents are
 *	set. Data is consumed from the input file. NOTE:
 *	the target tensor's data should NOT be allocated
 *	when it is passed to this routine. If it is, then
 *	the data will NOT be freed.
 *
 *---------------------------------------------------------------
 */


static int 
ReadAsciiPpmFile(
    Tcl_Interp *interp,
    Tensor_Descrip *tensorPtr,
    Tcl_Channel channel,
    int width,
    int height,
    int maxval)
{
    int i, ch, n_elements;
    unsigned char *el_ptr;
    double dp;
    int ip;

    /* Sanity checks. */

    if (maxval <= 0) {
	Tcl_SetObjResult(interp, Tcl_NewStringObj(
		      "ASCII PPM file has maxval <= 0!", -1));
	return (TCL_ERROR);
    }
    /* Set the tensor type, order, and size. */

    tensorPtr->type = TENSOR_BYTE;
    tensorPtr->order = 3;
    tensorPtr->dims[0] = height;
    tensorPtr->dims[1] = width;
    tensorPtr->dims[2] = 3;

    /* Allocate storage. */

    if (Tensor_AllocData(interp, tensorPtr) != TCL_OK) {
	return (TCL_ERROR);
    }
    n_elements = Tensor_NElements(tensorPtr);

    /* Read and rescale the data. */

    ch = ChanGetc(channel);
    for (i = 0, el_ptr = (unsigned char *) tensorPtr->data;
	 i < n_elements; i++, el_ptr++) {
	if (GetNumber(interp, "ASCII PPM file data", channel,
		       &ch, &ip) != TCL_OK) {
	    Tensor_FreeData(tensorPtr);
	    return (TCL_ERROR);
	}
	dp = ip;
	dp = dp * 255.0 / maxval + 0.5;
	if (dp > 255.0) {
	    dp = 255.0;
	}

	*el_ptr = dp;
    }

    return (TCL_OK);
}


/*
 *---------------------------------------------------------------
 *
 * TensorRead --
 *
 *      reads a tensor from a file.
 *
 * Results:
 *      The function returns a standard TCL result.
 *
 * Side effects:
 *      The target tensor's order, dimensions, and type are
 *	set, its data is allocated, and its contents are
 *	set. Data is consumed from the input file. NOTE:
 *	the target tensor's data should NOT be allocated
 *	when it is passed to this routine. If it is, then
 *	the data will NOT be freed.
 *
 *---------------------------------------------------------------
 */


int 
TensorRead(
    Tcl_Interp *interp,		/* For error messages	*/
    Tensor_Descrip *tensorPtr,	/* Tensor we're reading	*/
    Tcl_Channel channel)	/* Input channel	*/
{
    char junkstr[32];
    Tcl_Obj *result;
    int first_char;
    int bin_format;
    int pm_file_type, width, height, maxval;
    int i;

    /* Read the magic number, and check it out. */

    first_char = ChanGetc(channel);
    if(first_char == EOF || first_char < 0 || first_char > 255) {
	Tcl_SetObjResult(interp, Tcl_NewStringObj(
		    "Could not read magic number of tensor file", -1));
	return (TCL_ERROR);
    }
    switch (first_char) {
	case 'T':
	    if (Tcl_Read(channel, junkstr, 2) != 2) {
		Tcl_SetObjResult(interp, Tcl_NewStringObj(
		    "Could not read magic number of tensor file", -1));
		return (TCL_ERROR);
	    }
	    junkstr[2] = '\0';
	    if (!isdigit(junkstr[0]) || !isdigit(junkstr[1])) {
		result = Tcl_NewStringObj("Bad magic number \"T", -1);
		Tcl_AppendToObj(result, junkstr, -1);
		Tcl_AppendToObj(result, "\" in tensor file", -1);
		Tcl_SetObjResult(interp, result);
		return (TCL_ERROR);
	    }
	    i = atoi(junkstr);
	    bin_format = i & 1;
	    tensorPtr->type = i >> 1;

	    if (tensorPtr->type > TENSOR_MAX_TYPE) {
		junkstr[2] = '\0';
		result = Tcl_NewStringObj("Bad magic number \"T", -1);
		Tcl_AppendToObj(result, junkstr, -1);
		Tcl_AppendToObj(result, "\" in tensor file", -1);
		Tcl_SetObjResult(interp, result);
		return (TCL_ERROR);
	    }

	    /* Read the rest of the file, either binary or ASCII. */

	    if (bin_format) {
		return (ReadBinTensorFile(interp, tensorPtr, channel));
	    } else {
		return (ReadAsciiTensorFile(interp, tensorPtr, channel));
	    }

	    /* NOTREACHED */
	    break;

	case 'P':
	    if (ReadPmHeader(interp, channel, &pm_file_type,
			       &width, &height, &maxval) != TCL_OK) {
		return (TCL_ERROR);
	    }

	    switch (pm_file_type) {
		case '1':
		    return (ReadAsciiPbmFile(interp, tensorPtr, channel, width, height));

		case '2':
		    return (ReadAsciiPgmFile(interp, tensorPtr, channel, width, height, maxval));

		case '3':
		    return (ReadAsciiPpmFile(interp, tensorPtr, channel, width, height, maxval));

		case '4':
		    return (ReadBinPbmFile(interp, tensorPtr, channel, width, height));

		case '5':
		    return (ReadBinPgmFile(interp, tensorPtr, channel, width, height, maxval));

		case '6':
		    return (ReadBinPpmFile(interp, tensorPtr, channel, width, height, maxval));

		default:
		    junkstr[0] = 'P';
		    junkstr[1] = pm_file_type;
		    junkstr[2] = '\0';
		    result = Tcl_NewStringObj(
				"Unknown PM file magic number \"T", -1);
		    Tcl_AppendToObj(result, junkstr, -1);
		    Tcl_SetObjResult(interp, result);
		    return (TCL_ERROR);
	    }
	    /* NOTREACHED */
	    break;

	default:
	    Tcl_SetObjResult(interp, Tcl_NewStringObj(
			  "Bad magic number in tensor file", -1));
	    return (TCL_ERROR);
	    /* NOTREACHED */
	    break;
    }

    /* NOTREACHED */
    return (TCL_ERROR);
}


/*
 *---------------------------------------------------------------
 *
 * WriteBinTensorFile --
 *
 *      writes a tensor to a file in binary format.
 *
 * Results:
 *      The function returns a standard TCL result.
 *
 * Side effects:
 *      Data is written to the output channel.
 *
 *---------------------------------------------------------------
 */


static int 
WriteBinTensorFile(
    Tcl_Interp *interp,		/* For error messages	*/
    Tensor_Descrip *tensorPtr,	/* Tensor we're writing	*/
    Tcl_Channel channel)	/* Output channel	*/
{
    char magic[8];
    int nBytes;

    /* Write the magic number. */

    sprintf(magic, "T%02d", 2 * (tensorPtr->type) + 1);
    if (Tcl_Write(channel, magic, 3) != 3) {
	Tcl_SetObjResult(interp, Tcl_NewStringObj(
		 "Error writing binary tensor file magic number", -1));
	return (TCL_ERROR);
    }

    /* Write tensor order. */

    if (Tcl_Write(channel, (char *) &(tensorPtr->order),
	    sizeof(tensorPtr->order)) != sizeof(tensorPtr->order)) {
	Tcl_SetObjResult(interp, Tcl_NewStringObj(
	      "Error writing tensor order to binary tensor file", -1));
	return (TCL_ERROR);
    }
    /* Write tensor dimensions. */

    nBytes = sizeof(tensorPtr->dims[0])*(tensorPtr->order);
    if (Tcl_Write(channel, (char *) (tensorPtr->dims), nBytes) != nBytes) {
	Tcl_SetObjResult(interp, Tcl_NewStringObj(
		"Error writing tensor dimensions to binary tensor file", -1));
	return (TCL_ERROR);
    }

    /* Write tensor data. */

    nBytes = Tensor_NElements(tensorPtr)*Tensor_ElemSize(tensorPtr->type);
    if (Tcl_Write(channel, tensorPtr->data, nBytes) != nBytes) {
	Tcl_SetObjResult(interp, Tcl_NewStringObj(
	       "Error writing tensor data to binary tensor file", -1));
	return (TCL_ERROR);
    }
    return (TCL_OK);
}


/*
 *---------------------------------------------------------------
 *
 * WriteAsciiTensorFile --
 *
 *      writes a tensor to a file in ascii format.
 *
 * Results:
 *      The function returns a standard TCL result.
 *
 * Side effects:
 *      Data is written to the output channel.
 *
 *---------------------------------------------------------------
 */


static int 
WriteAsciiTensorFile(
    Tcl_Interp *interp,		/* For error messages	*/
    Tensor_Descrip *tensorPtr,	/* Tensor we're writing	*/
    Tcl_Channel channel)	/* Output channel	*/
{
    char junkstr[64];
    Tcl_Obj *result;
    int i;
    int n_elements, el_size;
    char *el_ptr;

    /* Write the magic number. */

    sprintf(junkstr, "T%02d", 2 * (tensorPtr->type));
    if (strlen(junkstr) != 3) {
	Tcl_SetObjResult(interp, Tcl_NewStringObj(
	     "Error creating magic number for ASCII tensor file", -1));
	return (TCL_ERROR);
    }

    if (Tcl_Write(channel, junkstr, -1) < 0) {
	Tcl_SetObjResult(interp, Tcl_NewStringObj(
	       "Error writing magic number to ASCII tensor file", -1));
	return (TCL_ERROR);
    }

    /* Write tensor order. */

    sprintf(junkstr, "%1d\n",  tensorPtr->order);
    if (Tcl_Write(channel, junkstr, -1) < 0) {
	Tcl_SetObjResult(interp, Tcl_NewStringObj(
	       "Error writing tensor order to ASCII tensor file", -1));
	return (TCL_ERROR);
    }
    /* Write tensor dimensions. */

    for (i = 0; i < tensorPtr->order; i++) {
	sprintf(junkstr, "%1d\n",  tensorPtr->dims[i]);
	if (Tcl_Write(channel, junkstr, -1) < 0) {
	    result = Tcl_NewStringObj(
			"Error writing tensor dimension ", -1);
	    Tcl_AppendObjToObj(result, Tcl_NewIntObj(i));
	    Tcl_AppendToObj(result, " to ASCII tensor file", -1);
	    Tcl_SetObjResult(interp, result);
	    return (TCL_ERROR);
	}
    }

    /* Write tensor data. */

    n_elements = Tensor_NElements(tensorPtr);
    el_size = Tensor_ElemSize(tensorPtr->type);

    switch (tensorPtr->type) {
	case TENSOR_DOUBLE:
	    for (i = 0, el_ptr = (char *) tensorPtr->data;
		 i < n_elements; i++, el_ptr += el_size) {
		sprintf(junkstr, "%25.17g\n", *((double *) el_ptr));
		if (Tcl_Write(channel, junkstr, -1) < 0) {
		    Tcl_SetObjResult(interp, Tcl_NewStringObj(
				  "Error writing to tensor file", -1));
		    return (TCL_ERROR);
		}
	    }
	    break;

	case TENSOR_FLOAT:
	    for (i = 0, el_ptr = (char *) tensorPtr->data;
		 i < n_elements; i++, el_ptr += el_size) {
		sprintf(junkstr, "%15.8g\n", *((float *) el_ptr));
		if (Tcl_Write(channel, junkstr, -1) < 0) {
		    Tcl_SetObjResult(interp, Tcl_NewStringObj(
				  "Error writing to tensor file", -1));
		    return (TCL_ERROR);
		}
	    }
	    break;

	case TENSOR_INT:
	    for (i = 0, el_ptr = (char *) tensorPtr->data;
		 i < n_elements; i++, el_ptr += el_size) {
		sprintf(junkstr, "%1d\n", *((int *) el_ptr));
		if (Tcl_Write(channel, junkstr, -1) < 0) {
		    Tcl_SetObjResult(interp, Tcl_NewStringObj(
				  "Error writing to tensor file", -1));
		    return (TCL_ERROR);
		}
	    }
	    break;

	case TENSOR_BYTE:
	    for (i = 0, el_ptr = (char *) tensorPtr->data;
		 i < n_elements; i++, el_ptr += el_size) {
		sprintf(junkstr, "%1d\n", *((unsigned char *) el_ptr));
		if (Tcl_Write(channel, junkstr, -1) < 0) {
		    Tcl_SetObjResult(interp, Tcl_NewStringObj(
				  "Error writing to tensor file", -1));
		    return (TCL_ERROR);
		}
	    }
	    break;

	case TENSOR_SHORT:
	    for (i = 0, el_ptr = (char *) tensorPtr->data;
		    i < n_elements; i++, el_ptr += el_size) {
		sprintf(junkstr, "%1d\n", (int) *((unsigned short *) el_ptr));
		if (Tcl_Write(channel, junkstr, -1) < 0) {
		    Tcl_SetObjResult(interp, Tcl_NewStringObj(
				  "Error writing to tensor file", -1));
		    return (TCL_ERROR);
		}
	    }
	    break;

	case TENSOR_UNSIGNED:
	    for (i = 0, el_ptr = (char *) tensorPtr->data;
		    i < n_elements; i++, el_ptr += el_size) {
		sprintf(junkstr, "%1u\n",*((unsigned int *) el_ptr) );
		if (Tcl_Write(channel, junkstr, -1) < 0) {
		    Tcl_SetObjResult(interp, Tcl_NewStringObj(
				  "Error writing to tensor file", -1));
		    return (TCL_ERROR);
		}
	    }
	    break;
    }

    return (TCL_OK);
}


/*
 *---------------------------------------------------------------
 *
 * TensorWrite --
 *
 *      writes a tensor to a file.
 *
 * Results:
 *      The function returns a standard TCL result.
 *
 * Side effects:
 *      Data is written to the output file.
 *
 *---------------------------------------------------------------
 */

int 
TensorWrite(
    Tcl_Interp *interp,		/* For error messages		*/
    Tensor_Descrip *tensorPtr,	/* Tensor we're going to write	*/
    Tcl_Channel channel,	/* Channel we're writing to	*/
    int bin_format)		/* == 0 for ascii format,
				 * != 0 for binary format	*/
{
    int retcode;
    Tcl_DString transModeSave;

    if (!bin_format) {
	retcode = WriteAsciiTensorFile(interp, tensorPtr, channel);
    } else {
	/* Save the current translation mode, and switch to binary. */

	Tcl_DStringInit(&transModeSave);
	if(Tcl_GetChannelOption(interp, channel, "-translation", &transModeSave) != TCL_OK) {
	    Tcl_DStringFree(&transModeSave);
	    return(TCL_ERROR);
	}
	if(Tcl_SetChannelOption(interp, channel, "-translation", "binary") != TCL_OK) {
	    Tcl_DStringFree(&transModeSave);
	    return(TCL_ERROR);
	}

	retcode = WriteBinTensorFile(interp, tensorPtr, channel);

	/* Restore the original translation mode. */

	Tcl_SetChannelOption(interp, channel,
		"-translation", Tcl_DStringValue(&transModeSave));
	Tcl_DStringFree(&transModeSave);
    }

    return(retcode);
}


/*
 *---------------------------------------------------------------
 *
 * TensorWriteSection --
 *
 *      writes a section of a tensor to a file.
 *
 * Results:
 *      The function returns a standard TCL result.
 *
 * Side effects:
 *      Data is written to the output file.
 *
 *---------------------------------------------------------------
 */

int 
TensorWriteSection(
    Tcl_Interp *interp,		/* For error messages		*/
    Tensor_Descrip *tensorPtr,	/* Tensor we're writing		*/
    Tensor_Index lowIndices,	/* Low indices of section	*/
    Tensor_Index highIndices,	/* High indices of section	*/
    Tcl_Channel channel,	/* Output channel		*/
    int bin_fmt)		/* == 0 for ascii format,
				 * != 0 for binary format	*/
{
    Tensor_Descrip tensor_sec;
    Tensor_Index index_map, dest_low_index, dest_high_index;
    int i, err_code;

    /* Create a tensor of the appropriate type, order, and size. */

    tensor_sec.type = tensorPtr->type;
    tensor_sec.order = tensorPtr->order;
    for(i = 0; i < tensor_sec.order; i++) {
	tensor_sec.dims[i] = tensorPtr->dims[i];
    }
#if 0
    TensorSectionDims(tensorPtr->order, lowIndices, highIndices,
	    &(tensor_sec.order), tensor_sec.dims, index_map);
#endif

    if (Tensor_AllocData(interp, &tensor_sec) != TCL_OK) {
	return (TCL_ERROR);
    }

    /* Copy the specified section of "tensor". */

    for (i = 0; i < tensor_sec.order; i++) {
	dest_low_index[i] = 0;
	dest_high_index[i] = tensor_sec.dims[i] - 1;
    }

    if (TensorCopySection(interp, &tensor_sec, dest_low_index,
	      dest_high_index, tensorPtr, lowIndices, highIndices) != TCL_OK) {
	Tensor_FreeData(&tensor_sec);
	return (TCL_ERROR);
    }
    /* Write the tensor. */

    err_code = TensorWrite(interp, &tensor_sec, channel, bin_fmt);

    /* Clean up and exit. */

    Tensor_FreeData(&tensor_sec);
    return (err_code);
}


/*
 *---------------------------------------------------------------
 *
 * TensorReadSection --
 *
 *      reads a tensor file, and puts it into a specified
 *	section of the given tensor.
 *
 * Results:
 *      The function returns a standard TCL result.
 *
 * Side effects:
 *      Some of the tensor's data changes.
 *
 *---------------------------------------------------------------
 */

int 
TensorReadSection(
    Tcl_Interp *interp,		/* For error messages		*/
    Tensor_Descrip *tensorPtr,	/* Tensor we're reading into	*/
    Tensor_Index lowIndices,	/* Low indices of section	*/
    Tensor_Index highIndices,	/* High indices of section	*/
    Tcl_Channel channel)	/* Input channel		*/
{
    Tensor_Descrip inp_tensor;
    int section_order;
    Tensor_Index section_bounds, index_map;
    Tensor_Index src_low_index, src_high_index;
    int i, err_code;

    /* Read the tensor. */

    if (TensorRead(interp, &inp_tensor, channel) != TCL_OK) {
	return (TCL_ERROR);
    }

    /* Check order and dimensions. */

    TensorSectionDims(tensorPtr->order, lowIndices, highIndices,
	    &section_order, section_bounds, index_map);
    if (section_order != inp_tensor.order) {
	Tensor_FreeData(&inp_tensor);
	Tcl_SetObjResult(interp, Tcl_NewStringObj(
	    "Order of tensor section doesn't match order of tensor from file",
		      -1));
	return (TCL_ERROR);
    }
    /* Copy to the specified section of "tensor". */

    for (i = 0; i < section_order; i++) {
	src_low_index[i] = 0;
	src_high_index[i] = inp_tensor.dims[i] - 1;
    }

    err_code = TensorCopySection(interp, tensorPtr, lowIndices, highIndices,
				  &inp_tensor, src_low_index, src_high_index);

    /* Clean up and exit. */

    Tensor_FreeData(&inp_tensor);
    return (err_code);
}
