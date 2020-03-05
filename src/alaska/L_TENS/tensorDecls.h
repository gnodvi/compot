/*
 * Declarations for the tensor package's externally-callable functions.
 */

#undef TCL_STORAGE_CLASS
#ifdef BUILD_tensor
#    define TCL_STORAGE_CLASS DLLEXPORT
#else
#    ifdef USE_TENSOR_STUBS
#	define TCL_STORAGE_CLASS
#    else
#	define TCL_STORAGE_CLASS DLLIMPORT
#    endif
#endif


/* !BEGIN!: Do not edit below this line. */

/*
 * Exported function declarations:
 */

#ifndef Tensor_Init_TCL_DECLARED
#define Tensor_Init_TCL_DECLARED
/* 0 */
EXTERN int		Tensor_Init (Tcl_Interp * interp);
#endif
#ifndef Tensor_ElemSize_TCL_DECLARED
#define Tensor_ElemSize_TCL_DECLARED
/* 1 */
EXTERN int		Tensor_ElemSize (int elemType);
#endif
#ifndef Tensor_GetElemValue_TCL_DECLARED
#define Tensor_GetElemValue_TCL_DECLARED
/* 2 */
EXTERN double		Tensor_GetElemValue (VOID * elemPtr, int elemType);
#endif
#ifndef Tensor_SetElemValue_TCL_DECLARED
#define Tensor_SetElemValue_TCL_DECLARED
/* 3 */
EXTERN void		Tensor_SetElemValue (VOID * elemPtr, int elemType, 
				double val);
#endif
#ifndef Tensor_NElements_TCL_DECLARED
#define Tensor_NElements_TCL_DECLARED
/* 4 */
EXTERN int		Tensor_NElements (Tensor_Descrip * tensorPtr);
#endif
#ifndef Tensor_GetElemPtr_TCL_DECLARED
#define Tensor_GetElemPtr_TCL_DECLARED
/* 5 */
EXTERN VOID *		Tensor_GetElemPtr (Tensor_Descrip * tensorPtr, 
				Tensor_Index index);
#endif
#ifndef Tensor_GetElemObj_TCL_DECLARED
#define Tensor_GetElemObj_TCL_DECLARED
/* 6 */
EXTERN Tcl_Obj *	Tensor_GetElemObj (VOID * elemPtr, int elemType);
#endif
#ifndef Tensor_AllocData_TCL_DECLARED
#define Tensor_AllocData_TCL_DECLARED
/* 7 */
EXTERN int		Tensor_AllocData (Tcl_Interp * interp, 
				Tensor_Descrip * tensorPtr);
#endif
#ifndef Tensor_FreeData_TCL_DECLARED
#define Tensor_FreeData_TCL_DECLARED
/* 8 */
EXTERN void		Tensor_FreeData (Tensor_Descrip * tensorPtr);
#endif
#ifndef Tensor_CheckIndex_TCL_DECLARED
#define Tensor_CheckIndex_TCL_DECLARED
/* 9 */
EXTERN int		Tensor_CheckIndex (Tcl_Interp * interp, 
				Tensor_Descrip * tensorPtr, 
				Tensor_Index index);
#endif
#ifndef Tensor_NextIndex_TCL_DECLARED
#define Tensor_NextIndex_TCL_DECLARED
/* 10 */
EXTERN int		Tensor_NextIndex (int order, Tensor_Index startIdx, 
				Tensor_Index endIdx, Tensor_Index elemIdx);
#endif
#ifndef Tensor_GetFloatArray_TCL_DECLARED
#define Tensor_GetFloatArray_TCL_DECLARED
/* 11 */
EXTERN int		Tensor_GetFloatArray (Tcl_Interp * interp, 
				char * str, float ** fltPtrPtr, 
				int * nFltsPtr, int * mustFreePtr);
#endif
#ifndef Tensor_GetDoubleArray_TCL_DECLARED
#define Tensor_GetDoubleArray_TCL_DECLARED
/* 12 */
EXTERN int		Tensor_GetDoubleArray (Tcl_Interp * interp, 
				char * str, double ** dblPtrPtr, 
				int * nDblsPtr, int * mustFreePtr);
#endif
#ifndef Tensor_AddApplyFunc_TCL_DECLARED
#define Tensor_AddApplyFunc_TCL_DECLARED
/* 13 */
EXTERN void		Tensor_AddApplyFunc (char * funcName, 
				Tensor_DoubleFunc funcPtr);
#endif
#ifndef Tensor_Lookup_TCL_DECLARED
#define Tensor_Lookup_TCL_DECLARED
/* 14 */
EXTERN Tensor_Descrip *	 Tensor_Lookup (Tcl_Interp * interp, char * name);
#endif
#ifndef Tensor_Register_TCL_DECLARED
#define Tensor_Register_TCL_DECLARED
/* 15 */
EXTERN void		Tensor_Register (Tcl_Interp * interp, 
				Tensor_Descrip * tensor, char * name);
#endif

typedef struct TensorStubs {
    int magic;
    struct TensorStubHooks *hooks;

    int (*tensor_Init) (Tcl_Interp * interp); /* 0 */
    int (*tensor_ElemSize) (int elemType); /* 1 */
    double (*tensor_GetElemValue) (VOID * elemPtr, int elemType); /* 2 */
    void (*tensor_SetElemValue) (VOID * elemPtr, int elemType, double val); /* 3 */
    int (*tensor_NElements) (Tensor_Descrip * tensorPtr); /* 4 */
    VOID * (*tensor_GetElemPtr) (Tensor_Descrip * tensorPtr, Tensor_Index index); /* 5 */
    Tcl_Obj * (*tensor_GetElemObj) (VOID * elemPtr, int elemType); /* 6 */
    int (*tensor_AllocData) (Tcl_Interp * interp, Tensor_Descrip * tensorPtr); /* 7 */
    void (*tensor_FreeData) (Tensor_Descrip * tensorPtr); /* 8 */
    int (*tensor_CheckIndex) (Tcl_Interp * interp, Tensor_Descrip * tensorPtr, Tensor_Index index); /* 9 */
    int (*tensor_NextIndex) (int order, Tensor_Index startIdx, Tensor_Index endIdx, Tensor_Index elemIdx); /* 10 */
    int (*tensor_GetFloatArray) (Tcl_Interp * interp, char * str, float ** fltPtrPtr, int * nFltsPtr, int * mustFreePtr); /* 11 */
    int (*tensor_GetDoubleArray) (Tcl_Interp * interp, char * str, double ** dblPtrPtr, int * nDblsPtr, int * mustFreePtr); /* 12 */
    void (*tensor_AddApplyFunc) (char * funcName, Tensor_DoubleFunc funcPtr); /* 13 */
    Tensor_Descrip * (*tensor_Lookup) (Tcl_Interp * interp, char * name); /* 14 */
    void (*tensor_Register) (Tcl_Interp * interp, Tensor_Descrip * tensor, char * name); /* 15 */
} TensorStubs;

#ifdef __cplusplus
extern "C" {
#endif
extern TensorStubs *tensorStubsPtr;
#ifdef __cplusplus
}
#endif

#if defined(USE_TENSOR_STUBS) && !defined(USE_TENSOR_STUB_PROCS)

/*
 * Inline function declarations:
 */

#ifndef Tensor_Init
#define Tensor_Init \
	(tensorStubsPtr->tensor_Init) /* 0 */
#endif
#ifndef Tensor_ElemSize
#define Tensor_ElemSize \
	(tensorStubsPtr->tensor_ElemSize) /* 1 */
#endif
#ifndef Tensor_GetElemValue
#define Tensor_GetElemValue \
	(tensorStubsPtr->tensor_GetElemValue) /* 2 */
#endif
#ifndef Tensor_SetElemValue
#define Tensor_SetElemValue \
	(tensorStubsPtr->tensor_SetElemValue) /* 3 */
#endif
#ifndef Tensor_NElements
#define Tensor_NElements \
	(tensorStubsPtr->tensor_NElements) /* 4 */
#endif
#ifndef Tensor_GetElemPtr
#define Tensor_GetElemPtr \
	(tensorStubsPtr->tensor_GetElemPtr) /* 5 */
#endif
#ifndef Tensor_GetElemObj
#define Tensor_GetElemObj \
	(tensorStubsPtr->tensor_GetElemObj) /* 6 */
#endif
#ifndef Tensor_AllocData
#define Tensor_AllocData \
	(tensorStubsPtr->tensor_AllocData) /* 7 */
#endif
#ifndef Tensor_FreeData
#define Tensor_FreeData \
	(tensorStubsPtr->tensor_FreeData) /* 8 */
#endif
#ifndef Tensor_CheckIndex
#define Tensor_CheckIndex \
	(tensorStubsPtr->tensor_CheckIndex) /* 9 */
#endif
#ifndef Tensor_NextIndex
#define Tensor_NextIndex \
	(tensorStubsPtr->tensor_NextIndex) /* 10 */
#endif
#ifndef Tensor_GetFloatArray
#define Tensor_GetFloatArray \
	(tensorStubsPtr->tensor_GetFloatArray) /* 11 */
#endif
#ifndef Tensor_GetDoubleArray
#define Tensor_GetDoubleArray \
	(tensorStubsPtr->tensor_GetDoubleArray) /* 12 */
#endif
#ifndef Tensor_AddApplyFunc
#define Tensor_AddApplyFunc \
	(tensorStubsPtr->tensor_AddApplyFunc) /* 13 */
#endif
#ifndef Tensor_Lookup
#define Tensor_Lookup \
	(tensorStubsPtr->tensor_Lookup) /* 14 */
#endif
#ifndef Tensor_Register
#define Tensor_Register \
	(tensorStubsPtr->tensor_Register) /* 15 */
#endif

#endif /* defined(USE_TENSOR_STUBS) && !defined(USE_TENSOR_STUB_PROCS) */

/* !END!: Do not edit above this line. */
