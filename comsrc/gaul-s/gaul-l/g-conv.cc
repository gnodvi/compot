//------------------------------------------------------------------------------
/*
    gaul - Genetic and other optimization algorighms for Tcl.
    A Tcl interface to the GAUL library.

    Copyright (C) 2008  Alexandros Stergiakis

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/
//------------------------------------------------------------------------------
/*
 * convert.c
 *
 */

#include <stdio.h> // snprintf

#include <tcl.h>
#include <gaul.h>

#include "g-conv.hh"

//------------------------------------------------------------------------------
/*
 * Function Bodies
 */
//------------------------------------------------------------------------------

/* convert int to string */
void itoa(int n, char *s) {
    snprintf(s, INT_LEN, "%d", n);
}

/* convert double to string */
void dtoa(double d, char *s) {
    snprintf(s, DOUBLE_LEN, "%lf", d);
}
//------------------------------------------------------------------------------

#define MGENA_STATIC const

//------------------------------------------------------------------------------
/* -1 indicates conversion error. error in interp result. */
//------------------------------------------------------------------------------
int convert_scheme (Tcl_Interp *interp, Tcl_Obj *string) {

  //static char* options[] = { 

  MGENA_STATIC char* options[] = { 
    "darwin",
    "lamarck_parents", 
    "lamarck_children", 
    "lamarck_all", 
    "baldwin_parents", 
    "baldwin_children", 
    "baldwin_all", 
    "lamarck_parents_baldwin_children", 
    "lamarck_children_baldwin_parents", 
    NULL 
  };

  int index;
  
  if (Tcl_GetIndexFromObj(interp, string, options, "scheme", 0, &index) != TCL_OK)
    return -1;
  
  switch (index) {
  case 0:
    return GA_SCHEME_DARWIN;
  case 1:
    return GA_SCHEME_LAMARCK_PARENTS;
  case 2:
    return GA_SCHEME_LAMARCK_CHILDREN;
  case 3:
    return GA_SCHEME_LAMARCK_ALL;
  case 4:
    return GA_SCHEME_BALDWIN_PARENTS;
  case 5:
    return GA_SCHEME_BALDWIN_CHILDREN;
  case 6:
    return GA_SCHEME_BALDWIN_ALL;
  case 7:
    return GA_SCHEME_LAMARCK_PARENTS|GA_SCHEME_BALDWIN_CHILDREN;
  case 8:
    return GA_SCHEME_LAMARCK_CHILDREN|GA_SCHEME_BALDWIN_PARENTS;
  }
  
  return -1;
}
//------------------------------------------------------------------------------
// NULL indicates conversion error. 
//------------------------------------------------------------------------------
Tcl_Obj * convert_from_scheme(int scheme) {

    switch (scheme) {
        case GA_SCHEME_DARWIN:
            return Tcl_NewStringObj("darwin", -1);
        case GA_SCHEME_LAMARCK_PARENTS:
            return Tcl_NewStringObj("lamarck_parents", -1);
        case GA_SCHEME_LAMARCK_CHILDREN:
            return Tcl_NewStringObj("lamarck_children", -1);
        case GA_SCHEME_LAMARCK_ALL:
            return Tcl_NewStringObj("lamarck_all", -1);
        case GA_SCHEME_BALDWIN_PARENTS:
            return Tcl_NewStringObj("baldwin_parents", -1);
        case GA_SCHEME_BALDWIN_CHILDREN:
            return Tcl_NewStringObj("baldwin_children", -1);
        case GA_SCHEME_BALDWIN_ALL:
            return Tcl_NewStringObj("baldwin_all", -1);
        case (GA_SCHEME_LAMARCK_PARENTS | GA_SCHEME_BALDWIN_CHILDREN):
            return Tcl_NewStringObj("lamarck_parents_baldwin_children", -1);
        case (GA_SCHEME_LAMARCK_CHILDREN | GA_SCHEME_BALDWIN_PARENTS):
            return Tcl_NewStringObj("lamarck_children_baldwin_parents", -1);
    }
    return NULL;
}


//------------------------------------------------------------------------------
// -1 indicates conversion error. error in interp result. 
//------------------------------------------------------------------------------
int convert_elitism(Tcl_Interp *interp, Tcl_Obj *string) {

  MGENA_STATIC  char* options[] = { 
    "parents",      /* All parents that rank sufficiently highly will pass to the next generation. */
    "one_parent",   /* The single fittest parent will pass to the next generation if it ranks sufficiently well. */
    "parents_die",     /* No parents pass to next generation, regardless of their fitness. */
    "rescore_parents", /* All parents are re-evalutated, and those that subsequently rank sufficiently highly will pass to the next generation. */
    NULL 
  };

  int index;
  
  if (Tcl_GetIndexFromObj(interp, string, options, "elitism", 0, &index) != TCL_OK)
    return -1;
  
  switch (index) {
  case 0:
    return GA_ELITISM_PARENTS_SURVIVE;
  case 1:
    return GA_ELITISM_ONE_PARENT_SURVIVES;
  case 2:
    return GA_ELITISM_PARENTS_DIE;
  case 3:
    return GA_ELITISM_RESCORE_PARENTS;
  }
  
  return -1;
}
//------------------------------------------------------------------------------
// NULL indicates conversion error. 
//------------------------------------------------------------------------------
Tcl_Obj * convert_from_elitism(int elitism) {
    switch (elitism) {
        case GA_ELITISM_PARENTS_SURVIVE:
            return Tcl_NewStringObj("parents", -1);
        case GA_ELITISM_ONE_PARENT_SURVIVES:
            return Tcl_NewStringObj("one_parent", -1);
        case GA_ELITISM_PARENTS_DIE:
            return Tcl_NewStringObj("parents_die", -1);
        case GA_ELITISM_RESCORE_PARENTS:
            return Tcl_NewStringObj("rescore_parents", -1);
        case GA_ELITISM_UNKNOWN:
            return Tcl_NewStringObj("unknown", -1);
    }
    return NULL;
}
//------------------------------------------------------------------------------
