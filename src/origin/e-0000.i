/* File : example.i */
%module "e_0000"

%inline %{
extern void  Error (const char *string);
extern int   Rand123 (double p1, double p2, double p3); 
%}
