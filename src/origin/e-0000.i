/* File : example.i */

%module "e_0000"

%inline %{

#include "c-0000.h"

extern void  Error (const char *string);
extern int   Rand123 (double p1, double p2, double p3); 
extern void  test_00 (int);

extern GRAF  *GrafCreate (int);
extern void   GrafInit1 (GRAF *graf, double r_edge_all, double r_edge_two);
extern void   GrafPrint (GRAF *);

extern void   GrafCheck (GRAF *graf);
extern void   GrafAddNode (GRAF *graf, int *pu, double node);

%}

%include cpointer.i
%pointer_functions(int, intp);
