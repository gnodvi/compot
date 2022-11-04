//------------------------------------------------------------------------------
// 
//------------------------------------------------------------------------------

#include <stdio.h>
#include <stdlib.h>   
#include <string.h>
#include <math.h> 

#include <tcl.h>

#include <tcl.h>
#include <fcntl.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <unistd.h>

//------------------------------------------------------------------------------
int 
gaulgena_proc (ClientData clientData, Tcl_Interp *interp,
               int argc, const char **argv) 
{
  char *buf;
  
//   if (argc != 2 && argc != 3) {
//     Tcl_AppendResult(interp, "wrong # args: should be \"",
//                      argv[0], " command ?varName?\"", NULL);
//     return TCL_ERROR;
//   }
  
  if (0) {
  printf ("\n");
  printf ("~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ \n");
  printf ("argc  = %d \n", argc);
  printf ("argv0 = %s \n", argv[0]);
  printf ("argv1 = %s \n", argv[1]);
  printf ("argv2 = %s \n", argv[2]);
  printf ("\n");
  }

  if (strcmp (argv[1], "-seedrand") != -1) {
    //printf ("SEED_s = %s \n", argv[2]);
    //printf ("SEED_d = %d \n", atoi (argv[2]));
    
    random_seed (atoi (argv[2]));
  }


  if (NULL == (buf = (char *) malloc (20)))
    return TCL_ERROR;

  strcpy (buf, "RR");

  Tcl_SetResult (interp, buf, TCL_DYNAMIC);
  
  return TCL_OK;
}
//------------------------------------------------------------------------------
int 
Gaulgena_Init (Tcl_Interp *interp) 
{

  // регистрация команды

  Tcl_CreateCommand (interp, 
                     "gaulgena", 
                     gaulgena_proc,

                     (ClientData)NULL, 
                     (Tcl_CmdDeleteProc *)NULL);

  return TCL_OK;  
}
//------------------------------------------------------------------------------
// 
//------------------------------------------------------------------------------
