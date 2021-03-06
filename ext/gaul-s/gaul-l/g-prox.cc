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

//------------------------------------------------------------------------------
/*
 * proxy.c
 *
 */
//------------------------------------------------------------------------------

#include <tcl.h>
#include <gaul.h>

//#include "t_proxy.h"
#include "g-prox.hh"

  //#include "t_tclgaul.h"
#include "g-tclg.hh"

#include "g-conv.hh"


// TCL_EVAL_GLOBAL
//
// If this flag is set, the script is processed at global level. This 
// means that it is evaluated in the global namespace and its variable 
// context consists of global variables only (it ignores any Tcl 
// procedures that are active). 
//

int eval_flags = NULL ; // TCL_EVAL_GLOBAL; 

//------------------------------------------------------------------------------
/*
 * Function Bodies
 */

//------------------------------------------------------------------------------
/*
 * Proxy_generation_hook is called at the beginning of each generation by all 
 * evolutionary functions. If this callback function returns FALSE the 
 * evolution will terminate.
 */
//------------------------------------------------------------------------------
boolean Proxy_generation_hook (const int generation, population *pop) {

  struct pop_data *data = (struct pop_data *) pop->data;
  int newObjc = 3;
  int res = TRUE;
  
  Tcl_Obj *newObjv[newObjc];
  newObjv[0] = data->generation_hook;
  newObjv[1] = data->name;
  newObjv[2] = Tcl_NewIntObj(generation);
  
  int i;
  for(i = 0; i < newObjc; i++)
    Tcl_IncrRefCount(newObjv[i]);
  
  int code = Tcl_EvalObjv(data->interp, newObjc, newObjv, eval_flags);
  
  if (code == TCL_ERROR) {
    res = FALSE;
    Tcl_BackgroundError(data->interp);
  }
  
  for(i = 0; i < newObjc; i++)
    Tcl_DecrRefCount(newObjv[i]);
  
  return res;
}
//------------------------------------------------------------------------------
/*
  * Proxy_evaluate determines the fitness of an entity.
  */
//------------------------------------------------------------------------------
boolean Proxy_evaluate(population *pop, entity *entity) {
  
  struct pop_data *data = (struct pop_data *) pop->data;
  Tcl_Interp *interp = data->interp;
  int newObjc = 3;
  int res = TRUE;
  
  Tcl_Obj *newObjv[newObjc];
  newObjv[0] = data->evaluate;
  newObjv[1] = data->name;
  newObjv[2] = (Tcl_Obj *) entity->chromosome[0];

  int i;
  for(i = 0; i < newObjc; i++)
    Tcl_IncrRefCount(newObjv[i]);
  
  int code = Tcl_EvalObjv(interp, newObjc, newObjv, eval_flags);

  if (code == TCL_ERROR) {
    res = FALSE;
    Tcl_BackgroundError(interp);
  } else {
    double fitness;
    Tcl_Obj *result = Tcl_GetObjResult(interp);
    if (Tcl_GetDoubleFromObj(interp, result, &fitness) == TCL_ERROR) {
      res = FALSE;
      Tcl_BackgroundError(interp);
    } else {
      entity->fitness = fitness;
    } 
  }
  
  for(i = 0; i < newObjc; i++)
    Tcl_DecrRefCount(newObjv[i]);
  
  return res;
}
//------------------------------------------------------------------------------
/*
 * Proxy_seed initializes the genomic contents of an entity.
 */
//------------------------------------------------------------------------------
boolean Proxy_seed(population *pop, entity *adam) {

  struct pop_data *data = (struct pop_data *) pop->data;
  Tcl_Interp *interp = data->interp;
  int newObjc = 3;
  int res = TRUE;
  
  Tcl_Obj *newObjv[newObjc];
  newObjv[0] = data->seed;
  newObjv[1] = data->name;
  newObjv[2] = (Tcl_Obj *) adam->chromosome[0];
  
  int i;
  for(i = 0; i < newObjc; i++)
    Tcl_IncrRefCount(newObjv[i]);
  
  int code = Tcl_EvalObjv (interp, newObjc, newObjv, eval_flags);
  
  if (code == TCL_ERROR) {
    res = FALSE;
    Tcl_BackgroundError(interp);
  } else {
    Tcl_Obj *result = Tcl_GetObjResult(interp);
    Tcl_IncrRefCount(result);
    Tcl_DecrRefCount((Tcl_Obj *) adam->chromosome[0]);
    adam->chromosome[0] = result;
  }
  
  for(i = 0; i < newObjc; i++)
    Tcl_DecrRefCount(newObjv[i]);
  
  return res;
}
//------------------------------------------------------------------------------
/*
 * Proxy_adapt optimizes/performs learning for an entity.
 */
//------------------------------------------------------------------------------
entity *Proxy_adapt(population *pop, entity *child) {
  
  struct pop_data *data = (struct pop_data *) pop->data;
  Tcl_Interp *interp = data->interp;
  int newObjc = 3;

  entity *adult;
  adult = ga_entity_clone(pop, child);
  
  Tcl_Obj *newObjv[newObjc];
  newObjv[0] = data->adapt;
  newObjv[1] = data->name;
  newObjv[2] = (Tcl_Obj *) child->chromosome[0];
  
  int i;
  for(i = 0; i < newObjc; i++)
    Tcl_IncrRefCount(newObjv[i]);
  
  int code = Tcl_EvalObjv(interp, newObjc, newObjv, eval_flags);
  
  if (code == TCL_ERROR) {
    Tcl_BackgroundError(interp);
  } else {
    Tcl_Obj *result = Tcl_GetObjResult(interp);
    Tcl_IncrRefCount(result);
    Tcl_DecrRefCount((Tcl_Obj *) adult->chromosome[0]);
    adult->chromosome[0] = result;
    ga_entity_evaluate(pop, adult);
  }
  
  for(i = 0; i < newObjc; i++)
    Tcl_DecrRefCount(newObjv[i]);
  
  return adult;
}
//------------------------------------------------------------------------------
/*
 * Proxy_mutate introduces a mutation into an entity.
 */
//------------------------------------------------------------------------------
void Proxy_mutate(population *pop, entity *mother, entity *daughter) {

  struct pop_data *data = (struct pop_data *) pop->data;
  Tcl_Interp *interp = data->interp;
  int newObjc = 3;
  
  Tcl_Obj *newObjv[newObjc];
  newObjv[0] = data->mutate;
  newObjv[1] = data->name;
  newObjv[2] = (Tcl_Obj *) mother->chromosome[0];
  
  int i;
  for(i = 0; i < newObjc; i++)
    Tcl_IncrRefCount(newObjv[i]);
  
  int code = Tcl_EvalObjv(interp, newObjc, newObjv, eval_flags);
  
  if (code == TCL_ERROR) {
    Tcl_BackgroundError(interp);
  } else {
    Tcl_Obj *result = Tcl_GetObjResult(interp);
    Tcl_IncrRefCount(result);
    if (daughter->chromosome[0])
      Tcl_DecrRefCount((Tcl_Obj *) daughter->chromosome[0]);
    daughter->chromosome[0] = result;
  }

  for(i = 0; i < newObjc; i++)
    Tcl_DecrRefCount(newObjv[i]);
  
  return;
}
//------------------------------------------------------------------------------
/*
 * Proxy_crossover produces two new sets of chromosomes from two parent sets.
 */
//------------------------------------------------------------------------------
void Proxy_crossover(population *pop, entity *mother, entity *father, 
                     entity *daughter, entity *son) {

  struct pop_data *data = (struct pop_data *) pop->data;
  Tcl_Interp *interp = data->interp;
  int newObjc = 4;
  
  Tcl_Obj *newObjv[newObjc];
  newObjv[0] = data->crossover;
  newObjv[1] = data->name;
  newObjv[2] = (Tcl_Obj *) father->chromosome[0];
  newObjv[3] = (Tcl_Obj *) mother->chromosome[0];
  
  int i;
  for(i = 0; i < newObjc; i++)
    Tcl_IncrRefCount(newObjv[i]);
  
  int code = Tcl_EvalObjv(interp, newObjc, newObjv, eval_flags);

  if (code == TCL_ERROR) {
    Tcl_BackgroundError(interp);
  } else {
    Tcl_Obj *result = Tcl_GetObjResult(interp);
    
    Tcl_Obj **objv;
    int objc;
    if (Tcl_ListObjGetElements(interp, result, &objc, &objv) == TCL_ERROR) {
      Tcl_BackgroundError(interp);
    } else if (objc != 2) {
      Tcl_SetResult(interp, "returned value must be a list of two items", TCL_STATIC);
      Tcl_BackgroundError(interp);
    } else {
      Tcl_IncrRefCount(objv[0]);
      Tcl_IncrRefCount(objv[1]);
      
      if (son->chromosome[0])
        Tcl_DecrRefCount((Tcl_Obj *) son->chromosome[0]);
      if (daughter->chromosome[0])
        Tcl_DecrRefCount((Tcl_Obj *) daughter->chromosome[0]);
      
      daughter->chromosome[0] = objv[0];
      son->chromosome[0] = objv[1];
    }
  }
  
  for(i = 0; i < newObjc; i++)
    Tcl_DecrRefCount(newObjv[i]);

  return;
}
//------------------------------------------------------------------------------
void Proxy_chromosome_destructor(population *pop, entity *entity) {

  if (!pop) die("Null pointer to population structure passed.");
  if (!entity) die("Null pointer to entity structure passed.");
  
  if (entity->chromosome == NULL)
    die("This entity already contains no chromosomes.");
  
  // mgena
  //    if (pop->num_chromosomes != 1)
  //        die("This entity contains multiple chromosomes.");
  
  struct pop_data *data = (struct pop_data *) pop->data;
  int newObjc = 3;
  
  Tcl_Obj *newObjv[newObjc];
  newObjv[0] = data->destroy;
  newObjv[1] = data->name;
  newObjv[2] = entity->chromosome[0];
  
  int i;
  for(i = 0; i < newObjc; i++)
    Tcl_IncrRefCount(newObjv[i]);
  
  int code = Tcl_EvalObjv(data->interp, newObjc, newObjv, eval_flags);
  
  if (code == TCL_ERROR) {
    Tcl_BackgroundError(data->interp);
  }
  
  for(i = 0; i < newObjc; i++)
    Tcl_DecrRefCount(newObjv[i]);
  
  Tcl_DecrRefCount((Tcl_Obj *) entity->chromosome[0]);
  s_free(entity->chromosome);
  entity->chromosome = NULL;
  
  return;
}
//------------------------------------------------------------------------------
// 
//------------------------------------------------------------------------------
