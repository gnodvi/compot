// -*-  mode: c    ; coding: koi8   -*- ----------------------------------------

//------------------------------------------------------------------------------

#include <stdio.h>
#include <stdlib.h>   
#include <string.h>
#include <math.h> 

#include <tcl.h>

//#include <tcl.h>
#include <fcntl.h>

#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>

//  #include "os.h"
//  #include "capture.h"
//  #include "misc.h"


//#define NO_CONST 1   ?????????
  

 
//------------------------------------------------------------------------------
int  
knuth_random_seed (ClientData clientData, Tcl_Interp *interp,
                 int argc, char **argv) 
{

  //if (argc != 2 && argc != 3) {
  //  Tcl_AppendResult(interp, "wrong # args: should be \"",
  //                   argv[0], " command ?varName?\"", NULL);
  //  return TCL_ERROR;
  //}
  
  int seed = atoi (argv[1]);

  usrand (seed);

  return TCL_OK;
}
//------------------------------------------------------------------------------
int  
knuth_random_rand (ClientData clientData, Tcl_Interp *interp,
                 int argc, char **argv) 
{
  char buf[80];

  int r = urand ();

  sprintf (buf, "%10u", r);

  Tcl_SetResult (interp, buf, NULL);
  
  return TCL_OK;
}
//------------------------------------------------------------------------------
int  
knuth_random_randint (ClientData clientData, Tcl_Interp *interp,
                      int argc, char **argv) 
{
  //int upto = 10;

  int upto = atoi (argv[1]);

  char buf[80];

  int r = randint (upto);

  sprintf (buf, "%10u", r);

  Tcl_SetResult (interp, buf, NULL);
  
  return TCL_OK;
}
//------------------------------------------------------------------------------
int 
Random_Init (Tcl_Interp *interp) 
{

  // инициализация интерфейса (обходился и без нее ?)
  // stub library - использование библиотеки-заглушки
  //
  char *version = "8.5";  // минимальная версия

  if (Tcl_InitStubs (interp, version, 0) == NULL) {
    return TCL_ERROR;
  }

  // регистрация команды


  Tcl_CreateCommand (interp, "knuth_random_seed", knuth_random_seed,
                     (ClientData) NULL, 
                     (Tcl_CmdDeleteProc *) NULL);


  Tcl_CreateCommand (interp, "knuth_random_rand", knuth_random_rand,
                     (ClientData) NULL, 
                     (Tcl_CmdDeleteProc *) NULL);


  Tcl_CreateCommand (interp, "knuth_random_randint", knuth_random_randint,
                     (ClientData) NULL, 
                     (Tcl_CmdDeleteProc *) NULL);


  usrand (0); // time

  // можно подготовить реализацию пакета, тогда можно будет
  // вызывать как package requare capture

  Tcl_PkgProvide (interp, "random", "1.1");

  return TCL_OK;  
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
