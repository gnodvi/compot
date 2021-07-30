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

#include "k-main.h"

//#define NO_CONST 1   ?????????
 
#ifdef _JIM
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#define Gen_Interp Jim_Interp
#define Gen_CreateCommand Jim_CreateCommand
#define GEN_OK JIM_OK 
#define GEN_ERROR JIM_ERR 
#define Gen_PkgProvideEx Jim_PackageProvide
#define Gen_SetResult Jim_SetResultString 
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#else
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#define Gen_Interp        Tcl_Interp
#define Gen_CreateCommand Tcl_CreateCommand
#define GEN_OK            TCL_OK 
#define GEN_ERROR         TCL_ERROR 
#define Gen_PkgProvideEx  Tcl_PkgProvideEx
#define Gen_SetResult     Tcl_SetResult
//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#endif


//------------------------------------------------------------------------------
#ifdef _JIM
static int  
knuth_random_seed (/* ClientData clientData, */ Gen_Interp *interp,
		   int argc, Jim_Obj *const *argv) 
#else
int  
knuth_random_seed (ClientData clientData, Gen_Interp *interp, int argc, char **argv) 
#endif
{

  //if (argc != 2 && argc != 3) {
  //  Tcl_AppendResult(interp, "wrong # args: should be \"",
  //                   argv[0], " command ?varName?\"", NULL);
  //  return TCL_ERROR;
  //}
  
  const char *str;
  int len;

#ifdef _JIM
  str = Jim_GetString(argv[1], &len);
#else
  str = argv[1];
#endif

  //int seed = atoi (argv[1]);
  int seed = atoi (str);

  usrand (seed);

  return GEN_OK;
}
//------------------------------------------------------------------------------
#ifdef _JIM
static int  
knuth_random_rand (/* ClientData clientData, */ Gen_Interp *interp,
		   int argc, Jim_Obj *const *argv) 
#else
int  
knuth_random_rand (ClientData clientData, Gen_Interp *interp, int argc, char **argv) 
#endif
{
  char buf[80];

  int r = urand ();

  sprintf (buf,    "%10u", r);
  //fprintf (stderr, "%10u \n", r);

  
#ifdef _JIM
  int len = /* 10 */ strlen (buf);
  Jim_SetResultString (interp, buf, /* NULL */ len);
#else
  Tcl_SetResult (interp, buf, /* NULL */ 0); //??
#endif
  
  return GEN_OK;
}
//------------------------------------------------------------------------------
#ifdef _JIM
int  
knuth_random_randint (/* ClientData clientData, */ Gen_Interp *interp,
		      int argc, Jim_Obj *const *argv) 
#else
int  
knuth_random_randint (ClientData clientData, Gen_Interp *interp, int argc, char **argv) 
#endif
{
  const char *str;
  int len;

#ifdef _JIM
  str = Jim_GetString(argv[1], &len);
#else
  str = argv[1];
#endif

  //int upto = 10;
  int upto = atoi (/* argv[1] */ str);

  char buf[80];

  int r = randint (upto);

  sprintf (buf, "%10u", r);
  //sprintf (buf, "%d\n", r);

  //Gen_SetResult (interp, buf, /* NULL */ 10);
  
#ifdef _JIM
  /* int */ len = 10;
  Jim_SetResultString (interp, buf, /* NULL */ len);
#else
  Tcl_SetResult (interp, buf, /* NULL */ 0); //??
#endif

  return GEN_OK;
}
//------------------------------------------------------------------------------
#ifndef _JIM
int 
Random_Init (Gen_Interp *interp) 
#else
int 
Jim_k_jimInit (Gen_Interp *interp) 
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

  // регистрация команды


  Gen_CreateCommand (interp, "knut_random_seed", knuth_random_seed,
                     /* (ClientData) */ NULL, 
                     /* (Tcl_CmdDeleteProc *) */ NULL);


  Gen_CreateCommand (interp, "knut_random_rand", knuth_random_rand,
                     /* (ClientData) */ NULL, 
                     /* (Tcl_CmdDeleteProc *) */ NULL);


  Gen_CreateCommand (interp, "knut_random_int", knuth_random_randint,
                     /* (ClientData) */ NULL, 
                     /* (Tcl_CmdDeleteProc *) */ NULL);


  usrand (0); // time

  // можно подготовить реализацию пакета, тогда можно будет
  // вызывать как package requare 

  Gen_PkgProvideEx (interp, "random", "1.1", /* NULL */ 0);
  //Tcl_PkgProvideEx (interp, "random", "1.1", NULL);

  return GEN_OK;  
}
//------------------------------------------------------------------------------
// load a_capt.so Capture
// 
// package require capture
// 
//------------------------------------------------------------------------------
//int main () 
//{

//   puts ("");
//   printf ("@@@@@@@@@@@@@@@@ \n");
//   puts ("");

//   Tcl_Interp *interp;

//   interp = Tcl_CreateInterp ();

//   int ret = Tcl_Eval (interp, "exec ls -all");

//   if (ret == TCL_OK) {
//     puts ("OK!............");
//   } else {
//     puts ("NOT OK!............");
//   }

//   puts ("");

//   const char *str;

//   str = Tcl_GetStringResult (interp);
//   printf ("str1 = %s \n", str);

//   //-----------------------------------------------------------
//   Tcl_Obj *resobj = Tcl_GetObjResult (interp);

//   str = Tcl_GetString (resobj);
//   printf ("str2 = %s \n", str);

//   int l; //intPtr - куда положим результат (длину списка)
//   ret = Tcl_ListObjLength (interp, resobj, &l);

//   if (ret == TCL_OK) {
//     puts ("OK!............");
//   } else {
//     puts ("NOT OK!............");
//   }

//   puts ("");
//   printf ("l = %d", l);
//   puts ("");

//   Tcl_Obj  **objvPtr; // where Tcl_ListObjGetElements stores a 
//   // pointer to an array of pointers to the element objects of listPtr. 
//   ret = Tcl_ListObjGetElements (interp, resobj, &l, &objvPtr);

//   if (ret == TCL_OK) {
//     puts ("OK!............");
//   } else {
//     puts ("NOT OK!............");
//   }

//   int i;
//   for (i = 0; i < l; i++) {
//     str = Tcl_GetString (objvPtr[i]);
//     printf ("i= %d  str = %s \n", i, str);
//   }

//   puts ("");
//}
//------------------------------------------------------------------------------
