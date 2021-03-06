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
 * tclgaul.c
 *
 */

#include <strings.h> // bzero

#include <tcl.h>
#include <gaul.h>

//#include "t_tclgaul.h"
//#include "g-tclg.h"
#include "g-tclg.hh"

#include "g-conv.hh"

//#include "t_proxy.h"
#include "g-prox.hh"

#include "g-chro.hh"

//------------------------------------------------------------------------------
/*
 * Function Prototypes
 */
//------------------------------------------------------------------------------

static int GaulCmd(ClientData clientData, Tcl_Interp *interp, int objc, Tcl_Obj *CONST objv[]);

static int PopulationCmd(ClientData clientData, Tcl_Interp *interp, int objc, Tcl_Obj *CONST objv[]);

static void PopulationCmd_CleanUp(ClientData clientData);

//------------------------------------------------------------------------------
/*
 * Function Bodies
 */

//------------------------------------------------------------------------------
int Gaul_Init (Tcl_Interp *interp) {

  if (Tcl_InitStubs(interp, "8.4", 0) == NULL) {
    return TCL_ERROR;
  }
  
  random_init  (); // начальная инициализация (random_seed (1);)

  // не, ну пока можно временно отключить (чтоб сделать фикс. тесты) ..
  // random_tseed (); // random_seed ((unsigned int) (time (NULL)%RANDOM_RAND_MAX));
 
  // регистрация команды (объектным способом)
  // 
  Tcl_CreateObjCommand (interp, "gaul", GaulCmd, (ClientData) NULL, NULL);
  
  Tcl_PkgProvide (interp, "gaul", "1.1");
  
  return TCL_OK;
}
//------------------------------------------------------------------------------
// эта процедура будет вызываться при вызове команды gaul
//------------------------------------------------------------------------------
static int GaulCmd(ClientData clientData, Tcl_Interp *interp, 
                   int objc, Tcl_Obj *CONST objv[]) {

  // static - внутри функции это сохранят значение переменной между вызовами, т.е.
  // можно изменять ??

  // mgena: static char* cmds[] = { 
  const char* cmds[] = { 
    "create", 
    "version", 
    "deserialize", 
    NULL 
  };

  // mgena: static char* ops[] = {
  const char* ops[] = {
    "-generation_hook", 
    "-evaluate", 
    "-seed", 
    "-adapt",
    "-mutate", 
    "-crossover", 
    "-select_one", 
    "-select_two", 
    "-destroy", 
    NULL
  };
  
  // static char* select_one[] = {
  const  char* select_one[] = {
    "RANDOM",
    "EVERY",
    "RANDOMRANK",
    "BESTOF2",
    "BESTOF3",
    "ROULETTE",
    "ROULETTE_REBASED",
    "SUS",
    "SUSSQ",
    "AGGRESSIVE",
    "BEST",
    "LINEARRANK",
    "ROUNDROBIN",
    NULL
  };
  
  //static char* select_two[] = {
  const  char* select_two[] = {
    "RANDOM",
    "EVERY",
    "RANDOMRANK",
    "BESTOF2",
    "BESTOF3",
    "ROULETTE",
    "ROULETTE_REBASED",
    "SUS",
    "SUSSQ",
    "AGGRESSIVE",
    "BEST",
    "LINEARRANK",
    NULL
  };

  int index;
  
  if (objc < 2) {
    Tcl_WrongNumArgs (interp, 1, objv, "option ?arg? ...");
    return TCL_ERROR;
  }
  
  if (Tcl_GetIndexFromObj (interp, objv[1], cmds, "option", 0, &index) != TCL_OK)
    return TCL_ERROR;
  

  switch (index) {

  // основная команда создания ..
  //
  case 0: /* create */
  {
    /*
      * Allocate population.
      */
    
    if (objc < 4) {
      Tcl_WrongNumArgs(interp, 2, objv, "name size ?options? ...");
      return TCL_ERROR;
    }
    
    int size;
    if (Tcl_GetIntFromObj(interp, objv[3], &size) == TCL_ERROR) return TCL_ERROR;
    
    population *pop = ga_population_new(size, /* mgena : 1, */ 0);

    if(!pop) {
      Tcl_SetResult(interp, "Failure to allocate population", TCL_STATIC);
      return TCL_ERROR;
    }
    
    /*
      * Set population parameters.
      */
    
    pop->chromosome_constructor = TclObj_chromosome_constructor;
    pop->chromosome_destructor  = TclObj_chromosome_destructor;
    pop->chromosome_replicate   = TclObj_chromosome_replicate;
    pop->chromosome_to_bytes    = TclObj_chromosome_to_bytes;
    pop->chromosome_from_bytes  = TclObj_chromosome_from_bytes;
    pop->chromosome_to_string   = TclObj_chromosome_to_string;
    
    /* Default. */
    pop->select_one = ga_select_one_sus;
    pop->select_two = ga_select_two_sus;
    pop->rank       = ga_rank_fitness;
    pop->replace    = ga_replace_by_fitness;
    
    /* Not used currently. */
    pop->data_destructor      = NULL;
    pop->data_ref_incrementor = NULL;
    pop->iteration_hook       = NULL;
    
    /* User data. */
    struct pop_data *data = (struct pop_data *) ckalloc(sizeof(struct pop_data));
    bzero ((void *) data, sizeof(struct pop_data));
    
    pop->data    = data;
    data->interp = interp;
    data->name   = objv[2];
    
    int i, option;

    for (i = 4; i < objc; i++) {
      if (Tcl_GetIndexFromObj (interp, objv[i], ops, "option", i - 1, &index) != TCL_OK) {
        ckfree ((char *) data);
        ga_extinction (pop);
        return TCL_ERROR; // error message is set
      }
      
      if (i == (objc - 1)) {
        Tcl_SetResult (interp, "missing value to parameter", TCL_STATIC);
        ckfree ((char *) data);
        ga_extinction (pop);
        return TCL_ERROR;
      }
      
      i++;

      switch (index) {

      case 0:
        pop->generation_hook  = Proxy_generation_hook;
        data->generation_hook = objv[i]; 
        break;
      case 1:
        pop->evaluate  = Proxy_evaluate;
        data->evaluate = objv[i]; 
        break;
      case 2:
        pop->seed  = Proxy_seed;
        data->seed = objv[i]; 
        break;
      case 3:
        pop->adapt  = Proxy_adapt;
        data->adapt = objv[i]; 
        break;
      case 4:
        pop->mutate  = Proxy_mutate;
        data->mutate = objv[i]; 
        break;
      case 5:
        pop->crossover  = Proxy_crossover;
        data->crossover = objv[i]; 
        break;
      case 6:
        if (Tcl_GetIndexFromObj(interp, objv[i], select_one, "option", i - 1, &option) != TCL_OK) {
          ckfree((char *) data);
          ga_extinction(pop);
          return TCL_ERROR;
        } else {

          switch (option) {
          case  0: pop->select_one = ga_select_one_random;     break;
          case  1: pop->select_one = ga_select_one_every;      break;
          case  2: pop->select_one = ga_select_one_randomrank; break;
          case  3: pop->select_one = ga_select_one_bestof2;    break;
          case  4: pop->select_one = ga_select_one_bestof3;    break;
          case  5: pop->select_one = ga_select_one_roulette;   break;
          case  6: pop->select_one = ga_select_one_roulette_rebased; break;
          case  7: pop->select_one = ga_select_one_sus;        break;
          case  8: pop->select_one = ga_select_one_sussq;      break;
          case  9: pop->select_one = ga_select_one_aggressive; break;
          case 10: pop->select_one = ga_select_one_best;       break;
          case 11: pop->select_one = ga_select_one_linearrank; break;
          case 12: pop->select_one = ga_select_one_roundrobin; break;
          }
        }
        data->select_one = objv[i]; 
        break;
      case 7:
        if (Tcl_GetIndexFromObj(interp, objv[i], select_two, "option", i - 1, &option) != TCL_OK) {
          ckfree((char *) data);
          ga_extinction(pop);
          return TCL_ERROR;
        } else {
          switch (option) {
          case  0: pop->select_two = ga_select_two_random;     break;
          case  1: pop->select_two = ga_select_two_every;      break;
          case  2: pop->select_two = ga_select_two_randomrank; break;
          case  3: pop->select_two = ga_select_two_bestof2;    break;
          case  4: pop->select_two = ga_select_two_bestof3;    break;
          case  5: pop->select_two = ga_select_two_roulette;   break;
          case  6: pop->select_two = ga_select_two_roulette_rebased; break;
          case  7: pop->select_two = ga_select_two_sus;        break;
          case  8: pop->select_two = ga_select_two_sussq;      break;
          case  9: pop->select_two = ga_select_two_aggressive; break;
          case 10: pop->select_two = ga_select_two_best;       break;
          case 11: pop->select_two = ga_select_two_linearrank; break;
          }
        }
        data->select_two = objv[i]; 
        break;
      case 8: /* destroy */
        pop->chromosome_destructor = Proxy_chromosome_destructor;
        data->destroy = objv[i]; 
        break;
      }
    }
    
    /*
      * Increase object references.
      */
    
    for (i = 5; i < objc; i += 2)
      Tcl_IncrRefCount(objv[i]);
    
    Tcl_IncrRefCount(objv[2]); // name
    
    /*
      * Create command for population.
      !! наконец в самом конце создаем по имени сам объект !!
      */
    
    char *name;
    name = Tcl_GetString(objv[2]);

    data->cmdtoken = Tcl_CreateObjCommand (interp, name, PopulationCmd, 
                                           (ClientData) pop, PopulationCmd_CleanUp);
    
    break;
  }
  
  case 1: /* version */
  {
    Tcl_Obj *dictPtr, *keyPtr, *objPtr;
    dictPtr = Tcl_NewDictObj();
    
    char s[INT_LEN];
    
    keyPtr = Tcl_NewStringObj("major", -1);
    itoa(ga_get_major_version(), s);
    objPtr = Tcl_NewStringObj(s, -1);
    if (Tcl_DictObjPut (interp, dictPtr, keyPtr, objPtr) != TCL_OK) {
      Tcl_DecrRefCount (keyPtr);
      Tcl_DecrRefCount (objPtr);
      Tcl_DecrRefCount (dictPtr);
      return TCL_ERROR;
    }
    
    keyPtr = Tcl_NewStringObj("minor", -1);
    itoa(ga_get_minor_version(), s);
    objPtr = Tcl_NewStringObj(s, -1);
    if (Tcl_DictObjPut (interp, dictPtr, keyPtr, objPtr) != TCL_OK) {
      Tcl_DecrRefCount (keyPtr);
      Tcl_DecrRefCount (objPtr);
      Tcl_DecrRefCount (dictPtr);
      return TCL_ERROR;
    }
    
    keyPtr = Tcl_NewStringObj("patch", -1);
    itoa(ga_get_patch_version(), s);
    objPtr = Tcl_NewStringObj(s, -1);
    if (Tcl_DictObjPut (interp, dictPtr, keyPtr, objPtr) != TCL_OK) {
      Tcl_DecrRefCount (keyPtr);
      Tcl_DecrRefCount (objPtr);
      Tcl_DecrRefCount (dictPtr);
      return TCL_ERROR;
    }
    
    Tcl_SetObjResult(interp, dictPtr);
    break;
  }
  case 2: /* deserialize */
  {
    Tcl_SetResult (interp, "Not implemented", TCL_STATIC);
    return TCL_ERROR;
    break;
  }
  } /* switch */
  
  return TCL_OK;
}
//------------------------------------------------------------------------------

//#define MGENA_STATIC static
  #define MGENA_STATIC const

//------------------------------------------------------------------------------
static int PopulationCmd(ClientData clientData, Tcl_Interp *interp, int objc, Tcl_Obj *CONST objv[]) {

  //static char* cmds[] = { 
  MGENA_STATIC char* cmds[] = { 
    "seed",         /* Initialize all entities of the population. */ 
    "params",       /* Set/Get population evolution parameters. */ 
    "evolve",       /* Evolve the population. */ 
    "solution",     /* Return the entify of best-fitness. */ 
    "stats",        /* Generate statistics meaningful only during or after an evolution. */ 
    "serialize",    /* Serialize the population data and entities. */ 
    "destroy",      /* Delete the population, the respective command, and free memory. */
    "list",         /* List all entities ordered from highest fitness to lowest. */
    "rank",         /* List all entities along with their fitness ordered from highest fitness to lowest. */
    NULL 
  };
  
  MGENA_STATIC char* params[] = { 
    "-scheme",          /* Evolutionary scheme. */
    "-elitism",         /* Elitism mode. */
    "-crossover",       /* Chance for crossover. */
    "-mutation",        /* Chance for mutation. */
    "-migration",       /* Chance for migration. */
    NULL 
  };
  
  MGENA_STATIC char* evolution[] = { 
    "-mpi",
    "-forked",
    "-threaded",
    "-steady_state",
    NULL 
  };
  
  int index;
  
  if (objc < 2) {
    Tcl_WrongNumArgs(interp, 1, objv, "option ?arg? ...");
    return TCL_ERROR;
  }
  
  if (Tcl_GetIndexFromObj(interp, objv[1], cmds, "option", 0, &index) != TCL_OK)
    return TCL_ERROR;
  
  population *pop = (population *) clientData;
  struct pop_data *data = (struct pop_data *) pop->data;
  
  switch (index) {
  case 0: /* seed */
  {
    fprintf (stderr, "SEEDDDDDDDDDDDDDDD ......... \n");
    ga_population_seed(pop);
    break;
  }
  case 1: /* params */
  {
    if (objc == 2) {
      /* 
        * Get Parameters 
        */
      
      Tcl_Obj *dictPtr, *keyPtr, *objPtr;
      dictPtr = Tcl_NewDictObj();
      
      char s[DOUBLE_LEN];
      
      keyPtr = Tcl_NewStringObj("-scheme", -1);
      objPtr = convert_from_scheme(ga_population_get_scheme(pop));
      if (Tcl_DictObjPut(interp, dictPtr, keyPtr, objPtr) != TCL_OK) {
        Tcl_DecrRefCount(keyPtr);
        Tcl_DecrRefCount(objPtr);
        Tcl_DecrRefCount(dictPtr);
        return TCL_ERROR;
      }
      
      keyPtr = Tcl_NewStringObj("-elitism", -1);
      objPtr = convert_from_elitism(ga_population_get_elitism(pop));
      if (Tcl_DictObjPut(interp, dictPtr, keyPtr, objPtr) != TCL_OK) {
        Tcl_DecrRefCount(keyPtr);
        Tcl_DecrRefCount(objPtr);
        Tcl_DecrRefCount(dictPtr);
        return TCL_ERROR;
      }
      
      keyPtr = Tcl_NewStringObj("-crossover", -1);
      dtoa(ga_population_get_crossover(pop), s);
      objPtr = Tcl_NewStringObj(s, -1);
      if (Tcl_DictObjPut(interp, dictPtr, keyPtr, objPtr) != TCL_OK) {
        Tcl_DecrRefCount(keyPtr);
        Tcl_DecrRefCount(objPtr);
        Tcl_DecrRefCount(dictPtr);
        return TCL_ERROR;
      }
      
      keyPtr = Tcl_NewStringObj("-mutation", -1);
      dtoa(ga_population_get_mutation(pop), s);
      objPtr = Tcl_NewStringObj(s, -1);
      if (Tcl_DictObjPut(interp, dictPtr, keyPtr, objPtr) != TCL_OK) {
        Tcl_DecrRefCount(keyPtr);
        Tcl_DecrRefCount(objPtr);
        Tcl_DecrRefCount(dictPtr);
        return TCL_ERROR;
      }
      
      keyPtr = Tcl_NewStringObj("-migration", -1);
      dtoa(ga_population_get_migration(pop), s);
      objPtr = Tcl_NewStringObj(s, -1);
      if (Tcl_DictObjPut(interp, dictPtr, keyPtr, objPtr) != TCL_OK) {
        Tcl_DecrRefCount(keyPtr);
        Tcl_DecrRefCount(objPtr);
        Tcl_DecrRefCount(dictPtr);
        return TCL_ERROR;
      }
      
      Tcl_SetObjResult(interp, dictPtr);
      
    } else {
      /* 
        * Set Parameters 
        */
      
      /* Default values. */
      ga_scheme_type scheme = GA_SCHEME_DARWIN;
      ga_elitism_type elitism = GA_ELITISM_PARENTS_DIE;
      double crossover = 0.9;
      double mutation = 0.1;
      double migration = 0.1;
      
      int i, option;
      for (i = 2; i < objc; i++) {
        if (Tcl_GetIndexFromObj(interp, objv[i], params, "parameter", i - 1, &option) != TCL_OK) {
          return TCL_ERROR; // error message is set
        }
        
        if (i == (objc - 1)) {
          Tcl_SetResult(interp, "missing value to parameter", TCL_STATIC);
          return TCL_ERROR;
        }
        
        i++;
        switch (option) {
        case 0: /* scheme */
          scheme = convert_scheme(interp, objv[i]);
          if(scheme == -1) return TCL_ERROR;
          break;
        case 1: /* elitism */
          elitism = convert_elitism(interp, objv[i]);
          if(elitism == -1) return TCL_ERROR;
          break;
        case 2: /* crossover */
          if (Tcl_GetDoubleFromObj(interp, objv[i], &crossover) == TCL_ERROR) return TCL_ERROR;
          break;
        case 3: /* mutation */
          if (Tcl_GetDoubleFromObj(interp, objv[i], &mutation) == TCL_ERROR) return TCL_ERROR;
          break;
        case 4: /* migration */
          if (Tcl_GetDoubleFromObj(interp, objv[i], &migration) == TCL_ERROR) return TCL_ERROR;
          break;
        }
      }
      
      ga_population_set_parameters(pop, scheme, elitism, crossover, mutation, migration);
    }
    break;
  }
  case 2: /* evolve */
  {
    if (objc < 3 || objc > 4) {
      Tcl_WrongNumArgs(interp, 2, objv, "generations ?type?");
      return TCL_ERROR;
    }
    
    int generations = 0, max_generations;
    if (Tcl_GetIntFromObj(interp, objv[2], &max_generations) == TCL_ERROR) return TCL_ERROR;
    
    if (objc == 4) {
      int option;
      if (Tcl_GetIndexFromObj(interp, objv[3], evolution, "type", 2, &option) != TCL_OK) {
        return TCL_ERROR; // error message is set
      }
      
      switch (option) {
      case 0: /* -mpi */
        #if USE_OPENMP == 1
        generations = ga_evolution_mpi(pop, max_generations); break;
        #else
        Tcl_SetResult(interp, "GAUL library is not compiled with OpenMP support", TCL_STATIC);
        return TCL_ERROR;
        #endif
      case 1: /* -forked */
        generations = ga_evolution_forked (pop, max_generations); break;
      case 2: /* -threaded */
        #if HAVE_PTHREADS == 1
        generations = ga_evolution_threaded (pop, max_generations); break;
        #else
        Tcl_SetResult(interp, "GAUL library is not compiled with pthreads support", TCL_STATIC);
        return TCL_ERROR;
                            #endif
      case 3: /* -steady_state */
        generations = ga_evolution_steady_state(pop, max_generations); break;
      }
    } else {
      generations = ga_evolution(pop, max_generations);
    }
    
    Tcl_Obj *result = Tcl_NewObj();
    Tcl_SetIntObj(result, generations);
    Tcl_SetObjResult(interp, result);
    break;
  }
  case 3: /* solution */
  {
    Tcl_SetObjResult(interp, ga_get_entity_from_rank(pop,0)->chromosome[0]);
    break;
  }
  case 4: /* stats */
  {
    /* This option may be used on-line or off-line (i.e. during and after evolution). */
    double max, min, mean, median, variance, stddev, kurtosis, skew;
    if (ga_fitness_stats(pop,
                         &min, &max,
                         &mean, &median,
                         &variance, &stddev,
                         &kurtosis, &skew) == FALSE) {
      Tcl_SetResult(interp, "Failed to generate statistics", TCL_STATIC);
      return TCL_ERROR;
    }
    
    Tcl_Obj *dictPtr, *keyPtr, *valPtr;
    dictPtr = Tcl_NewDictObj();
    
    keyPtr = Tcl_NewStringObj("max", -1);
    valPtr = Tcl_NewDoubleObj(max);
    if (Tcl_DictObjPut(interp, dictPtr, keyPtr, valPtr) != TCL_OK) {
      Tcl_DecrRefCount(keyPtr);
      Tcl_DecrRefCount(valPtr);
      Tcl_DecrRefCount(dictPtr);
      return TCL_ERROR;
    }
    
    keyPtr = Tcl_NewStringObj("min", -1);
    valPtr = Tcl_NewDoubleObj(min);
    if (Tcl_DictObjPut(interp, dictPtr, keyPtr, valPtr) != TCL_OK) {
      Tcl_DecrRefCount(keyPtr);
      Tcl_DecrRefCount(valPtr);
      Tcl_DecrRefCount(dictPtr);
      return TCL_ERROR;
    }
    
    keyPtr = Tcl_NewStringObj("mean", -1);
    valPtr = Tcl_NewDoubleObj(mean);
    if (Tcl_DictObjPut(interp, dictPtr, keyPtr, valPtr) != TCL_OK) {
      Tcl_DecrRefCount(keyPtr);
      Tcl_DecrRefCount(valPtr);
      Tcl_DecrRefCount(dictPtr);
      return TCL_ERROR;
    }
    
    keyPtr = Tcl_NewStringObj("median", -1);
    valPtr = Tcl_NewDoubleObj(median);
    if (Tcl_DictObjPut(interp, dictPtr, keyPtr, valPtr) != TCL_OK) {
      Tcl_DecrRefCount(keyPtr);
      Tcl_DecrRefCount(valPtr);
      Tcl_DecrRefCount(dictPtr);
      return TCL_ERROR;
    }
    
    keyPtr = Tcl_NewStringObj("variance", -1);
    valPtr = Tcl_NewDoubleObj(variance);
    if (Tcl_DictObjPut(interp, dictPtr, keyPtr, valPtr) != TCL_OK) {
      Tcl_DecrRefCount(keyPtr);
      Tcl_DecrRefCount(valPtr);
      Tcl_DecrRefCount(dictPtr);
      return TCL_ERROR;
    }
    
    keyPtr = Tcl_NewStringObj("stddev", -1);
    valPtr = Tcl_NewDoubleObj(stddev);
    if (Tcl_DictObjPut(interp, dictPtr, keyPtr, valPtr) != TCL_OK) {
      Tcl_DecrRefCount(keyPtr);
      Tcl_DecrRefCount(valPtr);
      Tcl_DecrRefCount(dictPtr);
      return TCL_ERROR;
    }
    
    keyPtr = Tcl_NewStringObj("kurtosis", -1);
    valPtr = Tcl_NewDoubleObj(kurtosis);
    if (Tcl_DictObjPut(interp, dictPtr, keyPtr, valPtr) != TCL_OK) {
      Tcl_DecrRefCount(keyPtr);
      Tcl_DecrRefCount(valPtr);
      Tcl_DecrRefCount(dictPtr);
      return TCL_ERROR;
    }

    keyPtr = Tcl_NewStringObj("skew", -1);
    valPtr = Tcl_NewDoubleObj(skew);
    if (Tcl_DictObjPut(interp, dictPtr, keyPtr, valPtr) != TCL_OK) {
      Tcl_DecrRefCount(keyPtr);
      Tcl_DecrRefCount(valPtr);
      Tcl_DecrRefCount(dictPtr);
      return TCL_ERROR;
    }
    
    Tcl_SetObjResult(interp, dictPtr);
    break;
  }
  case 5: /* serialize */
  {
    Tcl_SetResult(interp, "not implemented", TCL_STATIC);
    return TCL_ERROR;
    break;
  }
  case 6: /* destroy */
  {
    if(Tcl_DeleteCommandFromToken(interp, data->cmdtoken) != 0) {
      Tcl_SetResult(interp, "failed to destroy population", TCL_STATIC);
      return TCL_ERROR;
    }
    break;
  }
  case 7: /* list */
  {
    Tcl_Obj *listPtr = Tcl_NewListObj(0, NULL);
    Tcl_Obj *objPtr;
    
    int i;
    for (i = 0; i < pop->size; i++) {
      objPtr = ga_get_entity_from_rank(pop,i)->chromosome[0];
      if (Tcl_ListObjAppendElement(interp, listPtr, objPtr) != TCL_OK) {
        Tcl_DecrRefCount(listPtr);
        return TCL_ERROR;
      }
    }
    Tcl_SetObjResult(interp, listPtr);
    break;
  }
  case 8: /* rank */
  {
    Tcl_Obj *listPtr = Tcl_NewListObj(0, NULL);
    Tcl_Obj *objPtr;
    double fitness;
    
    int i;
    for (i = 0; i < pop->size; i++) {
      objPtr = ga_get_entity_from_rank(pop,i)->chromosome[0];
      if (Tcl_ListObjAppendElement(interp, listPtr, objPtr) != TCL_OK) {
        Tcl_DecrRefCount(listPtr);
        return TCL_ERROR;
      }
      
      fitness = ga_get_entity_from_rank(pop,i)->fitness;
      objPtr = Tcl_NewDoubleObj(fitness);
      if (Tcl_ListObjAppendElement(interp, listPtr, objPtr) != TCL_OK) {
        Tcl_DecrRefCount(objPtr);
        Tcl_DecrRefCount(listPtr);
        return TCL_ERROR;
      }
    }
    Tcl_SetObjResult(interp, listPtr);
    break;
  }
  } /* switch */
  
  return TCL_OK;
}
//------------------------------------------------------------------------------
// This is also executed automatically when the interpreter the command resied 
// is deleted. 
//------------------------------------------------------------------------------
static void PopulationCmd_CleanUp(ClientData clientData) {

  population *pop = (population *) clientData;
  struct pop_data *data = (struct pop_data *) pop->data;
  
  ga_extinction (pop);
  Tcl_DecrRefCount (data->name);

  if (data->generation_hook) Tcl_DecrRefCount(data->generation_hook);
  if (data->evaluate)   Tcl_DecrRefCount(data->evaluate);
  if (data->seed)       Tcl_DecrRefCount(data->seed);
  if (data->adapt)      Tcl_DecrRefCount(data->adapt);
  if (data->mutate)     Tcl_DecrRefCount(data->mutate);
  if (data->crossover)  Tcl_DecrRefCount(data->crossover);
  if (data->select_one) Tcl_DecrRefCount(data->select_one);
  if (data->select_two) Tcl_DecrRefCount(data->select_two);
  if (data->destroy)    Tcl_DecrRefCount(data->destroy);

  ckfree((char *) data);
}
//------------------------------------------------------------------------------
