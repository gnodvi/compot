/*
 * tensorStubLib.c --
 *
 *	Stub object that will be statically linked into extensions that want
 *	to access the Tcl Tensor extension.
 *
 * RCS: @(#) $Id: tensorStubLib.c,v 1.2 2008/05/31 21:06:33 neil Exp $
 */

/*
 * We need to ensure that we use the stub macros so that this file contains no
 * references to any of the stub functions. This will make it possible to
 * build an extension that references Tcl_InitStubs but doesn't end up
 * including the rest of the stub functions.
 */

#ifndef USE_TCL_STUBS
#define USE_TCL_STUBS
#endif
#undef USE_TCL_STUB_PROCS

#include "tcl.h"
#include "tensor.h"

/*
 * Tcl_InitStubs and stub table pointers are built as exported symbols.
 */

TensorStubs *tensorStubsPtr = NULL;


/*
 *----------------------------------------------------------------------
 *
 * Tensor_InitStubs --
 *
 *	Tries to initialise the stub table pointers and ensures that the
 *	correct version of Tcl is loaded.
 *
 * Results:
 *	The actual version of Tcl that satisfies the request, or NULL to
 *	indicate that an error occurred.
 *
 * Side effects:
 *	Sets the stub table pointers.
 *
 *----------------------------------------------------------------------
 */

#ifdef Tensor_InitStubs
#undef Tensor_InitStubs
#endif

CONST char *
Tensor_InitStubs(
    Tcl_Interp *interp,
    CONST char *version,
    int exact)
{
    CONST char *actualVersion = NULL;
    ClientData pkgData = NULL;

    actualVersion = Tcl_PkgRequireEx(interp, "Tensor", version, 0, &pkgData);
    if (actualVersion == NULL) {
	return NULL;
    }

    tensorStubsPtr = (TensorStubs *) pkgData;

    if(tensorStubsPtr != NULL) {
	Tcl_SetObjResult(interp, Tcl_NewStringObj(
		"Tensor extension doesn't support stubs", -1));
	return(NULL);
    }

    return actualVersion;
}

