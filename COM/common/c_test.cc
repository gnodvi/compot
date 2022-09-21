// -*-  mode: c    ; coding: koi8   -*- ----------------------------------------

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

#include <stdio.h>
#include <stdlib.h>   
#include <string.h>
#include <math.h> 

#include <tcl.h>


//------------------------------------------------------------------------------
void print_by_listobj (Tcl_Interp *interp, Tcl_Obj *resobj) 
{

  int l; // куда положим результат (длину списка)

  int ret = Tcl_ListObjLength (interp, resobj, &l);

  if (ret == TCL_OK) {
    puts ("OK!...............................................");
  } else {
    puts ("NOT OK!............");
  }

  puts ("");
  printf ("Tcl_ListObjLength = %d", l);
  puts ("");
  puts ("");

 
  Tcl_Obj  **objvPtr; // where Tcl_ListObjGetElements stores a 
  // pointer to an array of pointers to the element objects of listPtr. 

  ret = Tcl_ListObjGetElements (interp, resobj, &l, &objvPtr);

  if (ret == TCL_OK) {
    puts ("OK!............");
  } else {
    puts ("NOT OK!............");
  }

  puts ("");

  const char *str;
  int i;

  for (i = 0; i < l; i++) {

    str = Tcl_GetString (objvPtr[i]);

    printf ("i= %d  str = %s \n", i, str);
  }

}
//------------------------------------------------------------------------------
void 
run_cmd_and_print (Tcl_Interp *interp, char *cmd) 
{

  int ret = Tcl_Eval (interp, cmd);

  //int ret = Tcl_EvalEx (interp, cmd, 100, TCL_EVAL_DIRECT);


  if (ret == TCL_OK) puts ("OK!.........................................");
  else               puts ("NOT OK!............");

  // возвращаемые Tcl_Eval значения, установленные процедурами 
  // Tcl_SetResult и Tcl_SetObjResult или другими (?) можно получить двумя 
  // способами:


  // 1) 
  const char *str = Tcl_GetStringResult (interp);

  printf ("\n");
  printf ("str1 = %s \n", str);

  printf ("\n");


  // 2) 
  Tcl_Obj *resobj = Tcl_GetObjResult (interp);

  str = Tcl_GetString (resobj);

  printf ("str2 = %s \n", str);
  printf ("\n");

  //----------------------------------------

  //print_by_listobj (interp, resobj); 

  return;
}
//------------------------------------------------------------------------------
void 
test_01 (Tcl_Interp *interp) 
{

  const char *str;

  //char *cmd = "pwd";
  //char *cmd = "exec ls -all a*";
  char *cmd = "exec ls -all";


  run_cmd_and_print (interp, cmd); 

  return;
}
//------------------------------------------------------------------------------
void 
test_02 (Tcl_Interp *interp) 
{

  Tcl_Obj *dict = Tcl_NewDictObj ();

  Tcl_DictObjPut (NULL, dict, 
                  Tcl_NewStringObj ("key", -1),
                  Tcl_NewStringObj ("val", -1)
                  );

  // int Tcl_DictObjPut(Tcl_Interp *interp, Tcl_Obj *dictPtr, 
  //                          Tcl_Obj *keyPtr, Tcl_Obj *valuePtr);
  // 
  // This function inserts a new key/value pair into a dictionary, or updates 
  // a key/value pair already in the dictionary. The dictionary object must be 
  // unshared. Note that both the key and value objects will have their 
  // reference count increased. The return value is a normal TCL_OK/TCL_ERROR 
  // result, with the interp for error reporting.


  // int Tcl_DictObjGet(Tcl_Interp *interp, Tcl_Obj *dictPtr, 
  //                           Tcl_Obj *keyPtr, Tcl_Obj **valuePtrPtr);
  // 
  // This function looks up the value for a key in a dictionary. The variable 
  // pointed to by the valuePtrPtr argument is updated to contain a reference 
  // to the value, or a NULL if there is no mapping for the key in the 
  // dictionary. No reference counts are manipulated by this function. The 
  // return value is a normal TCL_OK/TCL_ERROR result, with the interp for 
  // error reporting.


  char *str = Tcl_GetString (dict);

  printf ("\n");
  printf ("str = %s \n", str);
  printf ("\n");

  // Tcl_SetObjResult (interp, dict); // для возврата?
  // return TCL_OK; 

  return;
}
//------------------------------------------------------------------------------
int 
main (int argc, char *argv[]) 
{

  puts ("");


  Tcl_Interp *interp = Tcl_CreateInterp ();

  //Tcl_Init (interp);
  //TclInterpInit (interp);
  
  test_01 (interp); 

  test_02 (interp); 

  printf ("\n");

  
}
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
