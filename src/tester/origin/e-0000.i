/* File : example.i */

%module "e_0000"

%inline %{

#include "e-0000.h"

extern void  Error (const char *string);
extern int   Rand123 (double p1, double p2, double p3); 
extern void  test_00 (int);

extern GRAF  *GrafCreate (int);
extern void   GrafInit1 (GRAF *graf, double r_edge_all, double r_edge_two);
extern void   GrafPrint (GRAF *);

%}
