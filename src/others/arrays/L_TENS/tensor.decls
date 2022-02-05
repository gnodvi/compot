
library tensor
interface tensor

declare 0 generic {
	int Tensor_Init(Tcl_Interp *interp)
}

declare 1 generic {
	int Tensor_ElemSize(int elemType)
}

declare 2 generic {
	double Tensor_GetElemValue(VOID *elemPtr, int elemType)
}

declare 3 generic {
	void Tensor_SetElemValue(VOID *elemPtr, int elemType, double val)
}

declare 4 generic {
	int Tensor_NElements(Tensor_Descrip *tensorPtr)
}

declare 5 generic {
	VOID *Tensor_GetElemPtr(Tensor_Descrip *tensorPtr, Tensor_Index index)
}

declare 6 generic {
	Tcl_Obj *Tensor_GetElemObj(VOID *elemPtr, int elemType)
}

declare 7 generic {
	int Tensor_AllocData(Tcl_Interp *interp, Tensor_Descrip *tensorPtr)
}

declare 8 generic {
	void Tensor_FreeData(Tensor_Descrip *tensorPtr)
}

declare 9 generic {
	int Tensor_CheckIndex(Tcl_Interp *interp, Tensor_Descrip *tensorPtr, Tensor_Index index)
}

declare 10 generic {
	int Tensor_NextIndex(int order, Tensor_Index startIdx, Tensor_Index endIdx, Tensor_Index elemIdx)
}

declare 11 generic {
	int Tensor_GetFloatArray(Tcl_Interp *interp, char *str, float **fltPtrPtr, int *nFltsPtr, int *mustFreePtr)
}

declare 12 generic {
	int Tensor_GetDoubleArray(Tcl_Interp *interp, char *str, double **dblPtrPtr, int *nDblsPtr, int *mustFreePtr)
}

declare 13 generic {
	void Tensor_AddApplyFunc(char *funcName, Tensor_DoubleFunc funcPtr)
}


declare 14 generic {
	Tensor_Descrip *Tensor_Lookup(Tcl_Interp *interp, char *name)
}

declare 15 generic {
	void Tensor_Register(Tcl_Interp *interp, Tensor_Descrip *tensor, char *name)
}

