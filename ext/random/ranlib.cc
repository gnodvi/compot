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
tcl_capture (ClientData clientData, Tcl_Interp *interp,
                 int argc, char **argv) 
{
  int old_stdout;
  static int fd = 0;
  char *buf;

  struct stat statbuf;
  char *tmpfile;
  int result;
  
  if (argc != 2 && argc != 3) {
    Tcl_AppendResult(interp, "wrong # args: should be \"",
                     argv[0], " command ?varName?\"", NULL);
    return TCL_ERROR;
  }
  
  // File descriptor mangling
  if (!fd) {
    tmpfile = tmpnam(NULL);
    //warning: the use of `tmpnam' is dangerous, better use `mkstemp'
    fd = open (tmpfile, O_RDWR|O_CREAT|O_TRUNC, 0666);
  } else {
    lseek(fd, 0, SEEK_SET);
  }
  
  old_stdout = dup(1);
  close(1);
  dup2(fd, 1);
  
  // Run the command
  result = Tcl_Eval(interp, argv[1]);
  
  // Reset file descriptors
  dup2(old_stdout, 1);
  close(old_stdout);
  
  // Reload the output 
  fstat(fd, &statbuf);

  //if (NULL == (buf = (char *)xmalloc(statbuf.st_size+1)))
  //undefined reference to `xmalloc'
  //xmalloc is a non-standard function that has the motto "succeed or die". 
  //If it fails to allocate memory it will terminate your program and 
  //print an error message to stderr.

  if (NULL == (buf = (char *) malloc (statbuf.st_size+1)))
    return TCL_ERROR;

  lseek (fd, 0, SEEK_SET);
  read  (fd, buf, statbuf.st_size);
  buf[statbuf.st_size]=0;
  
  // Return it to Tcl 

  //---------------------------------------------------------
  if (argc == 3) {

    Tcl_ResetResult (interp);
    
    //sprintf (interp->result, "%d", result);
    //a_capt.cc:68: error: 'Tcl_Interp' has no member named 'result'
    
    return Tcl_SetVar (interp, argv[2], buf, 0) ? TCL_OK : TCL_ERROR;

  //---------------------------------------------------------
  } else {
  //---------------------------------------------------------

    // # alloc: invalid block: 0x875a90: f8 30
    // # аварийный останов
    // 
    // # исправил: TCL_DYNAMIC -> NULL

    // Tcl_SetResult (interp, buf, TCL_DYNAMIC);
    Tcl_SetResult (interp, buf, NULL);
  }
  //---------------------------------------------------------
  
  return TCL_OK;
}
//------------------------------------------------------------------------------
int  
knuth_random (ClientData clientData, Tcl_Interp *interp,
                 int argc, char **argv) 
{
  int old_stdout;
  static int fd = 0;
  char *buf;
  struct stat statbuf;

  char *tmpfile;
  int result;
  
  //if (argc != 2 && argc != 3) {
  //  Tcl_AppendResult(interp, "wrong # args: should be \"",
  //                   argv[0], " command ?varName?\"", NULL);
  //  return TCL_ERROR;
  //}
  


  if (NULL == (buf = (char *) malloc (20)))
    return TCL_ERROR;

  //sprintf ("", 22);
  strcpy (buf, "12345");
  
  // Return it to Tcl 

  Tcl_SetResult (interp, buf, NULL);
  
  return TCL_OK;
}
//------------------------------------------------------------------------------
int 
Capture_Init (Tcl_Interp *interp) 
{

  // инициализация интерфейса (обходился и без нее ?)
  // stub library - использование библиотеки-заглушки
  //
  char *version = "8.5";  // минимальная версия

  if (Tcl_InitStubs (interp, version, 0) == NULL) {
    return TCL_ERROR;
  }

  // регистрация команды

  Tcl_CreateCommand (interp, "tcl_capture", tcl_capture,
                     (ClientData) NULL, 
                     (Tcl_CmdDeleteProc *) NULL);

  Tcl_CreateCommand (interp, "knuth_random", knuth_random,
                     (ClientData) NULL, 
                     (Tcl_CmdDeleteProc *) NULL);



  // можно подготовить реализацию пакета, тогда можно будет
  // вызывать как package requare capture

  Tcl_PkgProvide (interp, "capture", "1.1");

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
