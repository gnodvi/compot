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

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

int len; const char *str; char buf[100];  


#ifdef _JIM
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#define Gen_Interp Jim_Interp
#define Gen_CreateCommand Jim_CreateCommand
#define GEN_OK JIM_OK 
#define GEN_ERROR JIM_ERR 
#define Gen_PkgProvideEx Jim_PackageProvide
#define Gen_SetResult Jim_SetResultString

#define GET_ARG(I,FORMAT,PVAL)		 \
  {                                      \
    str = Jim_GetString (argv[I], &len); \
    sscanf (str, FORMAT, PVAL);          \
  }    

#define PUT_RESULT(FORMAT,VAL) \
  {                                      \
  sprintf (buf, FORMAT, VAL);            \
  Jim_SetResultString (interp, buf, strlen (buf)); \
  }    

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#else
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#define Gen_Interp        Tcl_Interp
#define Gen_CreateCommand Tcl_CreateCommand
#define GEN_OK            TCL_OK 
#define GEN_ERROR         TCL_ERROR 
#define Gen_PkgProvideEx  Tcl_PkgProvideEx
#define Gen_SetResult     Tcl_SetResult

#define GET_ARG(I,FORMAT,PVAL)		 \
  {                                      \
    strcpy (buf, argv[I]);		 \
    sscanf (buf, FORMAT, PVAL);		 \
  }    

#define PUT_RESULT(FORMAT,VAL)           \
  {                                      \
  sprintf (buf, FORMAT, VAL);            \
  Tcl_SetResult (interp, buf, /* NULL */ 0); \
  }    

//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#endif


//------------------------------------------------------------------------------
#ifdef _JIM
static int mg_test_01 (                       Gen_Interp *interp, int argc, Jim_Obj *const *argv) 
#else
       int mg_test_01 (ClientData clientData, Gen_Interp *interp, int argc, char **argv) 
#endif
{

  test_01 ();
  
  return GEN_OK;
}
//------------------------------------------------------------------------------
#ifdef _JIM
static int mg_graf_create (Gen_Interp *interp, int argc, Jim_Obj *const *argv) 
#else
       int mg_graf_create (ClientData clientData, Gen_Interp *interp, int argc, char **argv) 
#endif
{

  int  nn;

  //printf ("mg_graf_create ... A argv[1] = %s \n", argv[1]);
  
  GET_ARG (1, "%d", &nn);

  //printf ("mg_graf_create ... B nn = %d \n", nn);

  GRAF *gr = GrafCreate (nn);
 
  //printf ("mg_graf_create ... C \n");

  PUT_RESULT ("%p", (void*) gr);

  //printf ("mg_graf_create ... D \n");

  return GEN_OK;
}
//------------------------------------------------------------------------------
#ifdef _JIM
static int mg_graf_print (Jim_Interp *interp, int argc, Jim_Obj *const *argv) 
#else
       int mg_graf_print (ClientData clientData, Gen_Interp *interp, int argc, char **argv) 
#endif
{

  GRAF *gr;

  GET_ARG (1, "%p", (void**) &gr);

  GrafPrint (gr);
  

  return GEN_OK;
}
//------------------------------------------------------------------------------
#ifdef _JIM
static int mg_graf_init (Jim_Interp *interp, int argc, Jim_Obj *const *argv) 
#else
       int mg_graf_init (ClientData clientData, Gen_Interp *interp, int argc, char **argv) 
#endif
{

  GRAF *gr;

  GET_ARG (1, "%p", (void**) &gr);

  GrafInit (gr, YRAND, 0.0, 0.0, YRAND, NOT, NOT);
  

  return GEN_OK;
}
// -------------------------------------------------------------------------------
//proc EDGE_set {gr u v val} 
#ifdef _JIM
static int mg_EDGE_set (Jim_Interp *interp, int argc, Jim_Obj *const *argv) 
#else
       int mg_EDGE_set (ClientData clientData, Gen_Interp *interp, int argc, char **argv) 
#endif
{ 

  GRAF *graf;
  int u, v;
  float val;
  
  GET_ARG (1, "%p", (void**) &graf);
  GET_ARG (2, "%d", &u);
  GET_ARG (3, "%d", &v);
  GET_ARG (4, "%f", &val);

  EDGE (graf, u, v) = val;

  return GEN_OK;  
}
// -------------------------------------------------------------------------------
//proc EDGE_get {gr u v} 
#ifdef _JIM
static int mg_EDGE_get (Jim_Interp *interp, int argc, Jim_Obj *const *argv) 
#else
       int mg_EDGE_get (ClientData clientData, Gen_Interp *interp, int argc, char **argv) 
#endif
{ 

  GRAF *graf;
  int u, v;
  float val;

  GET_ARG (1, "%p", (void**) &graf);
  GET_ARG (2, "%d", &u);
  GET_ARG (3, "%d", &v);

  val = EDGE (graf, u, v);

  PUT_RESULT ("%f", val);

  return GEN_OK;  
}
// -------------------------------------------------------------------------------
//proc EDGE_set {gr u v val} 
#ifdef _JIM
static int mg_GrafSmin (Jim_Interp *interp, int argc, Jim_Obj *const *argv) 
#else
       int mg_GrafSmin (ClientData clientData, Gen_Interp *interp, int argc, char **argv) 
#endif
{ 

  //BOOL
  //GrafSmin (GRAF *graf, int s, int t, double *smin)

  GRAF *graf;
  int s, t;
  double *smin;
  
  GET_ARG (1, "%p", (void**) &graf);
  GET_ARG (2, "%d", &s);
  GET_ARG (3, "%d", &t);
  //GET_ARG (4, "%f", &val);

  printf ("mg_GrafSmin: s = %d \n", s);
  printf ("mg_GrafSmin: t = %d \n", t);
  
  GrafSmin (graf, s, t, /* smin  */ NULL);

  return GEN_OK;  
}
//------------------------------------------------------------------------------
#ifndef _JIM
int Metagraph_Init   (Gen_Interp *interp) 
#else
int Jim_e_jimInit (Jim_Interp *interp) 
#endif
{

  // инициализация интерфейса (обходился и без нее ?)
  // stub library - использование библиотеки-заглушки
  //
  char *version = "8.5";  // минимальная версия

#ifndef _JIM
  if (Tcl_InitStubs (interp, version, 0) == NULL) {
    return GEN_ERROR;
  }
#endif

  // регистрация команд

  Gen_CreateCommand (interp, "mg_test_01", mg_test_01,
                     /* (ClientData) */ NULL, 
                     /* (Tcl_CmdDeleteProc *) */ NULL);

  Gen_CreateCommand (interp, "mg_graf_create", mg_graf_create, NULL, NULL);
  Gen_CreateCommand (interp, "mg_graf_print",  mg_graf_print,  NULL, NULL);
  Gen_CreateCommand (interp, "mg_graf_init",   mg_graf_init,   NULL, NULL);
  Gen_CreateCommand (interp, "mg_EDGE_set",    mg_EDGE_set,    NULL, NULL);
  Gen_CreateCommand (interp, "mg_EDGE_get",    mg_EDGE_get,    NULL, NULL);
  Gen_CreateCommand (interp, "mg_GrafSmin",    mg_GrafSmin,    NULL, NULL);


  // если подготовить реализацию пакета, то можно будет
  // вызывать как package requare 

  Gen_PkgProvideEx (interp, "metagraph", "1.1", /* NULL */ 0);

  return GEN_OK;  
}
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
