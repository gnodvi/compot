// -*-  mode: c    ; coding: koi8   -*- ----------------------------------------

//------------------------------------------------------------------------------

#include <stdio.h>
#include <stdlib.h>   
#include <string.h>
#include <math.h> 

#ifdef _JIM
#include <jim.h>
#else
#include <tcl.h>
#endif

//#include <tcl.h>
#include <fcntl.h>

#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>

//  #include "os.h"
//  #include "capture.h"
//  #include "misc.h"

//------------------------------------------------------------------------------

#include "e-0000.h"

// ---------------------------------------------

#define GET_ARG(I,FORMAT,PVAL) \
  {                                      \
    int len; const char *str;            \
    str = Jim_GetString (argv[I], &len); \
    sscanf (str, FORMAT, PVAL);          \
  }    

#define PUT_RESULT(FORMAT,VAL) \
  {                                      \
  char buf[80];                          \
  sprintf (buf, FORMAT, VAL);            \
  Jim_SetResultString (interp, buf, strlen (buf)); \
  }    


//------------------------------------------------------------------------------
static int  
mg_test_01 (Jim_Interp *interp,
		   int argc, Jim_Obj *const *argv) 
{

  test_01 ();
  
  return JIM_OK;
}
//------------------------------------------------------------------------------
static int  
mg_graf_create (Jim_Interp *interp, int argc, Jim_Obj *const *argv) 
{

  int  nn;

  GET_ARG (1, "%d", &nn);

  GRAF *gr = GrafCreate (nn);
 
 
  PUT_RESULT ("%p", (void*) gr);

  return JIM_OK;
}
//------------------------------------------------------------------------------
static int  
mg_graf_print (Jim_Interp *interp, int argc, Jim_Obj *const *argv) 
{

  GRAF *gr;

  GET_ARG (1, "%p", (void**) &gr);

  GrafPrint (gr);
  

  return JIM_OK;
}
//------------------------------------------------------------------------------
static int  
mg_graf_init (Jim_Interp *interp, int argc, Jim_Obj *const *argv) 
{

  GRAF *gr;

  GET_ARG (1, "%p", (void**) &gr);

  GrafInit (gr, YRAND, 0.0, 0.0, YRAND, NOT, NOT);
  

  return JIM_OK;
}
// -------------------------------------------------------------------------------
//proc EDGE_set {gr u v val} 
static int  
mg_EDGE_set (Jim_Interp *interp, int argc, Jim_Obj *const *argv) 
{ 

  GRAF *graf;
  int u, v;
  float val;
  
  GET_ARG (1, "%p", (void**) &graf);
  GET_ARG (2, "%d", &u);
  GET_ARG (3, "%d", &v);
  GET_ARG (4, "%f", &val);

  EDGE (graf, u, v) = val;

  return JIM_OK;  
}
// -------------------------------------------------------------------------------
//proc EDGE_get {gr u v} 
static int  
mg_EDGE_get (Jim_Interp *interp, int argc, Jim_Obj *const *argv) 
{ 

  GRAF *graf;
  int u, v;
  float val;

  GET_ARG (1, "%p", (void**) &graf);
  GET_ARG (2, "%d", &u);
  GET_ARG (3, "%d", &v);

  val = EDGE (graf, u, v);

  PUT_RESULT ("%f", val);

  return JIM_OK;  
}
//------------------------------------------------------------------------------
int 
Jim_e_jimInit (Jim_Interp *interp) 
{

  Jim_CreateCommand (interp, "mg_test_01", mg_test_01,
                     /* (ClientData) */ NULL, 
                     /* (Tcl_CmdDeleteProc *) */ NULL);

  Jim_CreateCommand (interp, "mg_graf_create", mg_graf_create, NULL, NULL);
  Jim_CreateCommand (interp, "mg_graf_print",  mg_graf_print,  NULL, NULL);
  Jim_CreateCommand (interp, "mg_graf_init",   mg_graf_init,   NULL, NULL);
  Jim_CreateCommand (interp, "mg_EDGE_set",    mg_EDGE_set,    NULL, NULL);
  Jim_CreateCommand (interp, "mg_EDGE_get",    mg_EDGE_get,    NULL, NULL);


  // если подготовить реализацию пакета, то можно будет
  // вызывать как package requare 

  Jim_PackageProvide (interp, "metagraph", "1.1", /* NULL */ 0);

  return JIM_OK;  
}
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
