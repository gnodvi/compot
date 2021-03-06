# /**********************************************************************
#   ga_select.c
#  **********************************************************************

#   ga_select - Genetic algorithm selection operators.
#   Copyright б╘2000-2006, Stewart Adcock <stewart@linux-domain.com>
#   All rights reserved.

#   Synopsis:     Routines for performing GA selection operations.

# 		This selection routines return TRUE if the selection
# 		procedure has run to completion, otherwise they return
# 		FALSE.  They may potentially return NULL for the
# 		selected entities.  This is valid behaviour and doesn't
# 		necessarily indicate that the selection producedure is
# 		complete.

# 		On the first call to these routines in a given
# 		generation, pop->select_state is guaranteed to be set
# 		to zero.  These routines are then free to modify this
# 		value, for example, to store the number of selections
# 		performed in this generation.

# 		The ga_select_one_xxx() functions are intended for
# 		asexual selections.
# 		The ga_select_two_xxx() functions are intended for
# 		sexual selections.  Checking whether the mother and
# 		father are different entities is optional.

# 		The calling code is welcome to not use any of these
# 		functions.

# 		These functions return a pointer to the entity instead
# 		of an id because, potentially, the entities may come
# 		from a different population.

# 		It may be important to use the value held in the
# 		pop->orig_size field instead of the pop->size field
# 		because the population size is liable to increase
# 		between calls to these functions!  (Although, of course,
# 		you are free to use whichever value you like in
# 		user-defined functions.)

#  **********************************************************************/

# //#include "ga_core.h"
# #include "gaul.h"

# /**********************************************************************
#   synopsis:     Determine mean and standard deviation (and some other
#                 potentially useful junk) of the fitness scores.
#   parameters:	population *pop
#   return:	TRUE
#  **********************************************************************/
# boolean 
# gaul_select_stats (population *pop,
#                    double *average, double *stddev, double *sum)
#   {
#   int           i;                      /* Loop over all entities. */
#   double        fsum=0.0, fsumsq=0.0;   /* Sum and sum squared. */

#   //#if 0
#   /*
#     * Checks not needed for this static function unless used by
#     * external code... which it isn't.
#     */
#   //if (!pop) die("Null pointer to population structure passed.");
#   //if (pop->size < 1) die("Pointer to empty population structure passed.");
#   //#endif

#   for (i=0; i<pop->orig_size; i++)
#     {
#     fsum += pop->entity_iarray[i]->fitness;
#     fsumsq += SQU(pop->entity_iarray[i]->fitness);
#     }

#   *sum = fsum;
#   *average = fsum / pop->orig_size;
#   *stddev = (fsumsq - fsum*fsum/pop->orig_size)/pop->orig_size;

#   return TRUE;
#   }
#-------------------------------------------------------------------------------
#   synopsis:	Determine sum of entity fitnesses.
#   parameters:	population *pop
#   return:	double sum
#-------------------------------------------------------------------------------
# double 
# gaul_select_sum_fitness (population *pop)
#-------------------------------------------------------------------------------
proc gaul_select_sum_fitness {pop}  {

  #   int           i;		/* Loop over all entities. */
  #   double        sum=0.0;	/* Sum and sum squared. */
  
  set sum 0

  for {set i 0} {$i < [$pop cget -orig_size]} {incr i} \
  {
    # sum += pop->entity_iarray[i]->fitness;
    #set f [$pop get_entity_fitness $i]
    set f [pop_get_entity_fitness_ $pop  $i]

    set sum [expr $sum + $f]
  }

  return $sum
}
#-------------------------------------------------------------------------------
# /**********************************************************************
#   synopsis:	Determine sum of squared entity fitnesses.
#   parameters:	population *pop
#   return:	double sum
#  **********************************************************************/
# double 
# gaul_select_sum_sq_fitness (population *pop)
# {
#   int           i;		/* Loop over all entities. */
#   double        sum=0.0;	/* Sum and sum squared. */

#   for (i=0; i<pop->orig_size; i++)
#   {
#     sum += ( pop->entity_iarray[i]->fitness * pop->entity_iarray[i]->fitness );
#   }

#   return sum;
# }
# /**********************************************************************
#   synopsis:	Select a single random entity.  Selection stops when
# 		(population size)*(mutation ratio)=(number selected)
#  **********************************************************************/
# boolean 
# ga_select_one_random (population *pop, entity **mother)
# {

#   if (!pop) die("Null pointer to population structure passed.");

#   if (pop->orig_size < 1)
#   {
#     *mother = NULL;
#     return TRUE;
#   }

#   *mother = pop->entity_iarray[random_int(pop->orig_size)];

#   pop->select_state++;

#   return pop->select_state>(pop->orig_size*pop->mutation_ratio);
# }
# /**********************************************************************
#   synopsis:	Select a pair of random entities.  Selection stops when
# 		(population size)*(crossover ratio)=(number selected)
#  **********************************************************************/
# boolean 
# ga_select_two_random (population *pop, entity **mother, entity **father)
# {

#   if (!pop) die("Null pointer to population structure passed.");

#   if (pop->orig_size < 2)
#   {
#     *mother = NULL;
#     *father = NULL;
#     return TRUE;
#   }

#   *mother = pop->entity_iarray[random_int(pop->orig_size)];
#   do 
#   {
#     *father = pop->entity_iarray[random_int(pop->orig_size)];
#   } while (*mother == *father);

#   pop->select_state++;

#   return pop->select_state>(pop->orig_size*pop->crossover_ratio);
# }
# /**********************************************************************
#   synopsis:	Select every entity.
#  **********************************************************************/
# boolean 
# ga_select_one_every (population *pop, entity **mother)
# {

#   if (!pop) die("Null pointer to population structure passed.");

#   *mother = NULL;

#   if ( pop->orig_size <= pop->select_state )
#   {
#     return TRUE;
#   }

#   *mother = pop->entity_iarray[pop->select_state];

#   pop->select_state++;

#   return FALSE;
# }
# /**********************************************************************
#   synopsis:	Select every possible pair of parents.
#  **********************************************************************/
# boolean 
# ga_select_two_every (population *pop, entity **mother, entity **father)
# {

#   if (!pop) die("Null pointer to population structure passed.");

#   *mother = NULL;
#   *father = NULL;

#   if ( SQU(pop->orig_size) <= pop->select_state )
#   {
#     return TRUE;
#   }

#   *mother = pop->entity_iarray[pop->select_state%pop->orig_size];
#   *father = pop->entity_iarray[pop->select_state/pop->orig_size];

#   pop->select_state++;

#   return FALSE;
# }
#-------------------------------------------------------------------------------
# /**********************************************************************
#   synopsis:	Select a single entity by my rank-based method.
#  **********************************************************************/
# boolean 
# ga_select_one_randomrank (population *pop, entity **mother)

#-------------------------------------------------------------------------------
proc ga_select_one_randomrank {pop &mother} {

  USE_REFS

  #   if (!pop) die("Null pointer to population structure passed.");
  
  #   pop->select_state++;
  $pop configure -select_state [expr [$pop cget -select_state] + 1]
  
  #   *mother = NULL;
  
  set orig_size    [$pop cget -orig_size]
  set select_state [$pop cget -select_state]

  if {$orig_size < $select_state} \
  {
    return true
  }
  
  if {[random_boolean_prob [$pop cget -mutation_ratio]]} \
  {
     # *mother = pop->entity_iarray[random_int(pop->select_state)];
    #set mother [$pop get_entity [random_int $select_state]]
    set mother [pop_get_entity_ $pop [random_int $select_state]]

    return false
  } else {
    return true
  }
  
  #return false
}
#-------------------------------------------------------------------------------
# /**********************************************************************
#   synopsis:	Select a pair of entities by my rank-based method.
# 		Basically, I loop through all entities, and each is
# 		paired with a random, fitter, partner.
#  **********************************************************************/
# boolean 
# ga_select_two_randomrank (population *pop, entity **mother, entity **father)

#-------------------------------------------------------------------------------
proc ga_select_two_randomrank {pop &mother &father} {

  USE_REFS

  #   if (!pop) die("Null pointer to population structure passed.");
  
  #   pop->select_state++;
  $pop configure -select_state [expr [$pop cget -select_state] + 1]
  
  #set mother "NULL"
  #set father "NULL"
  
  set orig_size    [$pop cget -orig_size]
  set select_state [$pop cget -select_state]

  if {$::is_print} {
    puts "ga_select_two_randomrank: "
    puts "orig_size = $orig_size   select_state = $select_state"
  }

  if {$orig_size < $select_state} \
  {
    #puts "!!!!!!!!!!!!!????????????"
    return true
  }

  #   if ( random_boolean_prob (pop->crossover_ratio) )
  #   {
  #     *mother = pop->entity_iarray[random_int(pop->select_state)];
  #     *father = pop->entity_iarray[pop->select_state];
  #   }
  
  if {[random_boolean_prob [$pop cget -crossover_ratio]]} \
  {
    #set mother [$pop get_entity [random_int $select_state]]
    #set father [$pop get_entity             $select_state]

    set mother [pop_get_entity_ $pop  [random_int $select_state]]
    set father [pop_get_entity_ $pop              $select_state]

    return false
  } else {
    return true
  }
  
  #return false
}
#-------------------------------------------------------------------------------
# /**********************************************************************
#   synopsis:	Kind of tournament selection.  Choose three random
# 		entities, return the best as the selection.  Selection
# 		stops when
# 		(population size)*(mutation ratio)=(number selected)
#  **********************************************************************/
# boolean 
# ga_select_one_bestof3 (population *pop, entity **mother)
# {
#   entity	*mother2, *mother3;	/* Random competitors. */

#   if (!pop) die("Null pointer to population structure passed.");

#   if (pop->orig_size < 1)
#   {
#     *mother = NULL;
#     return TRUE;
#   }

#   *mother = pop->entity_iarray[random_int(pop->orig_size)];
#   mother2 = pop->entity_iarray[random_int(pop->orig_size)];
#   mother3 = pop->entity_iarray[random_int(pop->orig_size)];

#   if (mother2->fitness > (*mother)->fitness)
#     *mother = mother2;
#   if (mother3->fitness > (*mother)->fitness)
#     *mother = mother3;

#   pop->select_state++;

#   return pop->select_state>(pop->orig_size*pop->mutation_ratio);
# }
# /**********************************************************************
#   synopsis:	Kind of tournament selection.  For each parent, choose
# 		three random entities, return the best as the
# 		selection.
# 		The two parents will be different.  Selection
# 		stops when
# 		(population size)*(crossover ratio)=(number selected)
#  **********************************************************************/
# boolean 
# ga_select_two_bestof3 (population *pop, entity **mother, entity **father)
# {
#   entity	*challenger1, *challenger2;	/* Random competitors. */

#   if (!pop) die("Null pointer to population structure passed.");

#   if (pop->orig_size < 2)
#   {
#     *mother = NULL;
#     *father = NULL;
#     return TRUE;
#   }

#   *mother = pop->entity_iarray[random_int(pop->orig_size)];
#   challenger1 = pop->entity_iarray[random_int(pop->orig_size)];
#   challenger2 = pop->entity_iarray[random_int(pop->orig_size)];

#   if (challenger1->fitness > (*mother)->fitness)
#     *mother = challenger1;
#   if (challenger2->fitness > (*mother)->fitness)
#     *mother = challenger2;

#   do 
#   {
#     *father = pop->entity_iarray[random_int(pop->orig_size)];
#   } while (*mother == *father);

#   challenger1 = pop->entity_iarray[random_int(pop->orig_size)];
#   challenger2 = pop->entity_iarray[random_int(pop->orig_size)];

#   if (challenger1 != *mother && challenger1->fitness > (*father)->fitness)
#     *father = challenger1;

#   if (challenger2 != *mother && challenger2->fitness > (*father)->fitness)
#     *father = challenger2;

#   pop->select_state++;

#   return pop->select_state>(pop->orig_size*pop->crossover_ratio);
# }
#-------------------------------------------------------------------------------
#   synopsis:	Kind of tournament selection.  Choose two random
# 		entities, return the best as the selection.  Selection
# 		stops when
# 		(population size)*(mutation ratio)=(number selected)

# boolean 
# ga_select_one_bestof2 (population *pop, entity **mother)

#-------------------------------------------------------------------------------
proc ga_select_one_bestof2 {pop &mother} {

  USE_REFS
  #   entity	*mother2;	/* Random competitor. */
  
  #   if (!pop) die ("Null pointer to population structure passed.");
  
  #   if (pop->orig_size < 1)
  #   {
  #     *mother = NULL;
  #     return TRUE;
  #   }
  
  set orig_size [$pop cget -orig_size]

  #   *mother = pop->entity_iarray[random_int(pop->orig_size)];
  #   mother2 = pop->entity_iarray[random_int(pop->orig_size)];

  #set mother1 [$pop get_entity [random_int $orig_size]]
  #set mother2 [$pop get_entity [random_int $orig_size]]
  
  set mother1 [pop_get_entity_ $pop  [random_int $orig_size]]
  set mother2 [pop_get_entity_ $pop  [random_int $orig_size]]
  
  #   if (mother2->fitness > (*mother)->fitness)
  #     *mother = mother2;
  
  if {[$mother1 cget -fitness] > [$mother2 cget -fitness]} {
    set mother $mother1
  } else {
    set mother $mother2
  }

  #   pop->select_state++;
  $pop configure -select_state [expr [$pop cget -select_state] + 1]

  set ret [expr [$pop cget -select_state] > ($orig_size * [$pop cget -mutation_ratio]) ]

  #   return pop->select_state>(pop->orig_size*pop->mutation_ratio);
  return $ret
}
#-------------------------------------------------------------------------------
#   synopsis:	Kind of tournament selection.  For each parent, choose
# 		two random entities, return the best as the selection.
# 		The two parents will be different.  Selection
# 		stops when
# 		(population size)*(crossover ratio)=(number selected)

# boolean 
# ga_select_two_bestof2 (population *pop, entity **mother, entity **father)

#-------------------------------------------------------------------------------
proc ga_select_two_bestof2 {pop &mother &father} {

  USE_REFS

  #   entity	*challenger;	/* Random competitor. */
  
  #   if (!pop) die("Null pointer to population structure passed.");
  
  #   if (pop->orig_size < 2)
  #   {
  #     *mother = NULL;
  #     *father = NULL;
  #     return TRUE;
  #   }
  
  set orig_size [$pop cget -orig_size]
  set c_ratio   [$pop cget -crossover_ratio] 

  set moth_i [random_int $orig_size]
  #set mother [$pop get_entity $moth_i]
  set mother [pop_get_entity_ $pop  $moth_i]

  set moth_fitness [$mother cget -fitness]

  set chal_i [random_int $orig_size]
  #set challenger [$pop get_entity $chal_i]
  set challenger [pop_get_entity_ $pop  $chal_i]

  set chal_fitness [$challenger cget -fitness]
  

  if {$chal_fitness > $moth_fitness} {
    #puts "  chal_fitness > moth_fitness"
    set mother $challenger
    set moth_i $chal_i ;# // сделаем это по факту !?
  }

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  while {1} {
    set fath_i [random_int $orig_size]
    if {$moth_i != $fath_i}  {break}
  }

  #set father  [$pop get_entity $fath_i]
  set father  [pop_get_entity_ $pop  $fath_i]

  set fath_fitness  [$father cget -fitness]
  

  set chal_i [random_int $orig_size]
  #set challenger   [$pop get_entity $chal_i];
  set challenger   [pop_get_entity_ $pop  $chal_i];

  set chal_fitness [$challenger cget -fitness]
 
  #puts "  moth_i= $moth_i  fath_i= $fath_i  chth_i= $chal_i  chal_fitness= $chal_fitness  fath_fitness= $fath_fitness"

  if {$chal_i != $moth_i  &&  $chal_fitness > $fath_fitness} {
    #puts "  ....."
    set father $challenger
    set fath_i $chal_i ;# // сделаем это по факту !?
  }
  
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  if {$::is_print} {
    puts "  ga_select_two_bestof2 :"
    print_entit  $mother "mother = ($moth_i) ="
    print_entit  $father "father = ($fath_i) ="
  }
  

  #   pop->select_state++;
  #
  set  s_state [$pop cget -select_state]
  incr s_state
  $pop configure -select_state $s_state

  # истина, если закончился перебор (селекция пар) ?
  # 
  set ret [expr {$s_state > 1.0 * $orig_size * $c_ratio} ]
  
  if {$::is_print} {
    puts "  s_state= $s_state  orig_size= $orig_size  c_ratio= $c_ratio   ret = $ret" 
    puts ""
  }

  #   return pop->select_state>(pop->orig_size*pop->crossover_ratio);
  return $ret
}
#-------------------------------------------------------------------------------
# /**********************************************************************
#   synopsis:	Fitness-proportionate roulette wheel selection.
# 		If pop->mutation_ratio is 1.0, the wheel will be spun
# 		pop->orig_size times, which matches Holland's original
# 		implementation.
# 		This version is for fitness values where 0.0 is bad and
# 		large positive values are good.  Negative values will
# 		severely mess-up the algorithm.
#  **********************************************************************/
# boolean 
# ga_select_one_roulette (population *pop, entity **mother)
# {
#   double	selectval;		/* Select when this reaches zero. */

#   if (!pop) die("Null pointer to population structure passed.");

#   *mother = NULL;

#   if (pop->orig_size < 1 ||
#       pop->select_state+1 > (pop->orig_size * pop->mutation_ratio))
#   {
#     return TRUE;
#   }

#   if (pop->select_state == 0)
#   { /* First call of this generation. */
#     gaul_select_stats(pop, &(pop->selectdata.mean), &(pop->selectdata.stddev), &(pop->selectdata.sum));
#     pop->selectdata.current_expval = pop->selectdata.sum/pop->selectdata.mean;
#     pop->selectdata.marker = random_int(pop->orig_size);
#   }

#   selectval = random_double(pop->selectdata.current_expval)*pop->selectdata.mean;

#   do
#   {
#     pop->selectdata.marker++;

#     if (pop->selectdata.marker >= pop->orig_size)
#       pop->selectdata.marker=0;

#     selectval -= pop->entity_iarray[pop->selectdata.marker]->fitness;

#   } while (selectval>0.0);

#   pop->select_state++;

#   *mother = pop->entity_iarray[pop->selectdata.marker];

#   return FALSE;
# }
# /**********************************************************************
#   synopsis:	Fitness-proportionate roulette wheel selection.
# 		If pop->mutation_ratio is 1.0, the wheel will be spun
# 		pop->orig_size times, which matches Holland's original
# 		implementation.
# 		This version can cope with a mixture of positive and
# 		negative fitness scores.  The single least fit entity
# 		will never be selected, but this is not considered a
# 		problem.
#  **********************************************************************/
# boolean 
# ga_select_one_roulette_rebased (population *pop, entity **mother)
# {
#   double	selectval;		/* Select when this reaches zero. */

#   if (!pop) die("Null pointer to population structure passed.");

#   *mother = NULL;

#   if (pop->orig_size < 1 ||
#       pop->select_state+1 > (pop->orig_size * pop->mutation_ratio))
#   {
#     return TRUE;
#   }

#   if (pop->select_state == 0)
#   { /* First call of this generation. */
#     gaul_select_stats(pop, &(pop->selectdata.mean), &(pop->selectdata.stddev), &(pop->selectdata.sum));
#     pop->selectdata.marker = random_int(pop->orig_size);
#     pop->selectdata.minval = pop->entity_iarray[pop->orig_size-1]->fitness;
#     pop->selectdata.mean -= pop->selectdata.minval;
#     if (ISTINY(pop->selectdata.mean)) die("Degenerate population?");
#     pop->selectdata.current_expval = (pop->selectdata.sum-pop->selectdata.minval*pop->orig_size)/pop->selectdata.mean;
#   }

#   selectval = random_double(pop->selectdata.current_expval);

#   do
#   {
#     pop->selectdata.marker++;

#     if (pop->selectdata.marker >= pop->orig_size)
#       pop->selectdata.marker=0;

#     selectval -= (pop->entity_iarray[pop->selectdata.marker]->fitness-pop->selectdata.minval)/pop->selectdata.mean;

#   } while (selectval>0.0);

#   pop->select_state++;

#   *mother = pop->entity_iarray[pop->selectdata.marker];

#   return FALSE;
# }
# /**********************************************************************
#   synopsis:	Fitness-proportionate roulette wheel selection.
# 		If pop->mutation_ratio is 1.0, the wheel will be spun
# 		pop->orig_size times, which matches Holland's original
# 		implementation.
# 		This version is for fitness values where 0.0 is bad and
# 		large positive values are good.  Negative values will
# 		severely mess-up the algorithm.
#         Mother and father may be the same.
#  **********************************************************************/
# boolean 
# ga_select_two_roulette (population *pop,
#                         entity **mother, entity **father)
# {
#   double	selectval;		/* Select when this reaches zero. */

#   if (!pop) die("Null pointer to population structure passed.");

#   *mother = NULL;
#   *father = NULL;

#   if (pop->orig_size < 1 ||
#       pop->select_state+1 > (pop->orig_size * pop->mutation_ratio))
#   {
#     return TRUE;
#   }

#   if (pop->select_state == 0)
#   { /* First call of this generation. */
#     gaul_select_stats(pop, &(pop->selectdata.mean), &(pop->selectdata.stddev), &(pop->selectdata.sum));
#     pop->selectdata.current_expval = pop->selectdata.sum/pop->selectdata.mean;
#     pop->selectdata.marker = random_int(pop->orig_size);
#     /*
#       printf("Mean fitness = %f stddev = %f sum = %f expval = %f\n", mean, stddev, sum, current_expval);
#       */
#   }

#   pop->select_state++;

#   selectval = random_double(pop->selectdata.current_expval)*pop->selectdata.mean;

#   do
#   {
#     pop->selectdata.marker++;

#     if (pop->selectdata.marker >= pop->orig_size)
#       pop->selectdata.marker=0;

#     selectval -= pop->entity_iarray[pop->selectdata.marker]->fitness;

#   } while (selectval>0.0);

#   *mother = pop->entity_iarray[pop->selectdata.marker];

#   selectval = random_double(pop->selectdata.current_expval)*pop->selectdata.mean;

#   do
#   {
#     pop->selectdata.marker++;

#     if (pop->selectdata.marker >= pop->orig_size)
#       pop->selectdata.marker=0;

#     selectval -= pop->entity_iarray[pop->selectdata.marker]->fitness;

#   } while (selectval>0.0);

#   *father = pop->entity_iarray[pop->selectdata.marker];

#   return FALSE;
# }
# /**********************************************************************
#   synopsis:	Fitness-proportionate roulette wheel selection.
# 		If pop->mutation_ratio is 1.0, the wheel will be spun
# 		pop->orig_size times, which matches Holland's original
# 		implementation.
# 		This version can cope with a mixture of positive and
# 		negative fitness scores.  The single least fit entity
# 		will never be selected, but this is not considered a
# 		problem.
#         Mother and father may be the same.
#  **********************************************************************/
# boolean 
# ga_select_two_roulette_rebased (population *pop,
#                                 entity **mother, entity **father)
# {
#   double	selectval;		/* Select when this reaches zero. */

#   if (!pop) die("Null pointer to population structure passed.");

#   *mother = NULL;

#   if (pop->orig_size < 1 ||
#       pop->select_state+1 > (pop->orig_size * pop->mutation_ratio))
#   {
#     return TRUE;
#   }

#   if (pop->select_state == 0)
#   { /* First call of this generation. */
#     gaul_select_stats(pop, &(pop->selectdata.mean), &(pop->selectdata.stddev), &(pop->selectdata.sum));
#     pop->selectdata.marker = random_int(pop->orig_size);
#     pop->selectdata.minval = pop->entity_iarray[pop->orig_size-1]->fitness;
#     pop->selectdata.mean -= pop->selectdata.minval;
#     if (ISTINY(pop->selectdata.mean)) die("Degenerate population?");
#     pop->selectdata.current_expval = (pop->selectdata.sum-pop->selectdata.minval*pop->orig_size)/pop->selectdata.mean;
#   }

#   pop->select_state++;

#   selectval = random_double(pop->selectdata.current_expval);

#   do
#   {
#     pop->selectdata.marker++;

#     if (pop->selectdata.marker >= pop->orig_size)
#       pop->selectdata.marker=0;

#     selectval -= (pop->entity_iarray[pop->selectdata.marker]->fitness-pop->selectdata.minval)/pop->selectdata.mean;

#   } while (selectval>0.0);

#   *mother = pop->entity_iarray[pop->selectdata.marker];

#   selectval = random_double(pop->selectdata.current_expval);

#   do
#   {
#     pop->selectdata.marker++;

#     if (pop->selectdata.marker >= pop->orig_size)
#       pop->selectdata.marker=0;

#     selectval -= (pop->entity_iarray[pop->selectdata.marker]->fitness-pop->selectdata.minval)/pop->selectdata.mean;

#   } while (selectval>0.0);

#   *father = pop->entity_iarray[pop->selectdata.marker];

#   return FALSE;
# }
#-------------------------------------------------------------------------------
#   synopsis:	Stochastic Universal Sampling selection.
#   		pop->mutation_ratio multiplied by pop->orig_size gives
# 		the number of selections which will be performed.
# 		This version is for fitness values where 0.0 is bad and
# 		large positive values are good.  Negative values will
# 		severely mess-up the algorithm.
#-------------------------------------------------------------------------------
# boolean 
# ga_select_one_sus (population *pop, entity **mother)

#-------------------------------------------------------------------------------
proc ga_select_one_sus {pop &mother}  {

  USE_REFS

  #   double	sum;			/* Fitness total. */
  
  #   if (!pop) die("Null pointer to population structure passed.");  
  #   *mother = NULL;
  
  set orig_size       [$pop cget -orig_size]
  set select_state    [$pop cget -select_state]
  set mutation_ratio  [$pop cget -mutation_ratio]

  set num_to_select   [$pop cget -selectdata_num_to_select]

  if {$orig_size < 1} \
  {
      return true
  }
  
  if {$select_state == 0} \
  { 
    # First call of this generation.

    # pop->selectdata.num_to_select = max(1,(int)floor(pop->orig_size*pop->mutation_ratio));
    $pop configure -selectdata_num_to_select \
      [expr max (1, int (floor ($orig_size * $mutation_ratio)))]

    set sum [gaul_select_sum_fitness $pop]

    # pop->selectdata.step = sum/(pop->orig_size*pop->mutation_ratio);
    set selectdata_step [expr $sum / ($orig_size * $mutation_ratio)]
    $pop configure -selectdata_step $selectdata_step

    # pop->selectdata.offset1 = random_double(pop->selectdata.step);
    $pop configure -selectdata_offset1 [random_double $selectdata_step]

    # pop->selectdata.current1=0;
    $pop configure -selectdata_current1  0

  } elseif {$select_state > [$pop cget -selectdata_num_to_select]} {

    return true ;# признак окончания

  } else {
    #     pop->selectdata.offset1 += pop->selectdata.step;
    set step [$pop cget -selectdata_step]
    $pop configure -selectdata_offset1 [expr [$pop cget -selectdata_offset1] + $step]
  }
  

  #   while (pop->selectdata.offset1 > pop->entity_iarray[pop->selectdata.current1]->fitness)
  #
  while {1} \
  {

    set off1 [$pop cget -selectdata_offset1 ]
    set cur1 [$pop cget -selectdata_current1]
    #set fit1 [$pop get_entity_fitness $cur1]
    set fit1 [pop_get_entity_fitness_ $pop  $cur1]

    if {$off1 <= $fit1} {break}

    # pop->selectdata.offset1 -= pop->entity_iarray[pop->selectdata.current1]->fitness;
    $pop configure -selectdata_offset1 [expr $off1 - $fit1]

    # pop->selectdata.current1++;
    incr cur1

    # if (pop->selectdata.current1 >= pop->orig_size)
    #    pop->selectdata.current1-=pop->orig_size;

    if {$cur1 >= $orig_size} {
      set cur1 [expr $cur1 - $orig_size]
    }    
    $pop configure -selectdata_current1 $cur1
  }
  
  #   *mother = pop->entity_iarray[pop->selectdata.current1];
  set cur1 [$pop cget -selectdata_current1]
  #set mother [$pop get_entity $cur1]
  set mother [pop_get_entity_ $pop  $cur1]

  
  #   pop->select_state++;
  $pop configure -select_state [expr [$pop cget -select_state] + 1]
  
  return false
}
#-------------------------------------------------------------------------------
# /**********************************************************************
#   synopsis:	Stochastic Universal Sampling selection.
#
#   		pop->mutation_ratio multiplied by pop->orig_size gives
# 		the number of selections which will be performed.
#
# 		This version is for fitness values where 0.0 is bad and
# 		large positive values are good.  Negative values will
# 		severely mess-up the algorithm.
#  **********************************************************************/
# boolean 
# ga_select_two_sus (population *pop, entity **mother, entity **father)
#-------------------------------------------------------------------------------
proc ga_select_two_sus {pop &mother &father}  {

  USE_REFS

  #   double	sum;			/* Fitness total. */
  #   int	*ordered;		/* Ordered indices. */
  #   int	i;			/* Loop variable over indices. */
  
  #   if (!pop) die("Null pointer to population structure passed.");  
  #   *mother = NULL;
  
  set orig_size       [$pop cget -orig_size]
  set select_state    [$pop cget -select_state]
  set crossover_ratio [$pop cget -crossover_ratio]

  set num_to_select [$pop cget -selectdata_num_to_select]

  #puts "select_state  = $select_state"
  #puts "num_to_select = $num_to_select"
  #puts ""

  if {$orig_size < 1} \
  {
      return true
  }
  
  if {$::is_print} {
    puts stderr "ga_select_two_sus ........ "
  }

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  if {$select_state == 0} {
 
    if {$::is_print} {puts stderr "1 ... "}

    # First call of this generation

    $pop configure -selectdata_num_to_select \
      [expr max (1, int (floor ($orig_size * $crossover_ratio)))]

    set sum [gaul_select_sum_fitness  $pop]

    set selectdata_step [expr $sum / [$pop cget -selectdata_num_to_select]]
    $pop configure -selectdata_step $selectdata_step

    $pop configure -selectdata_offset1 [random_double $selectdata_step]
    $pop configure -selectdata_offset2 [$pop cget -selectdata_offset1]

    #puts  stderr [format "sum = %f  step = %f  off1 = %f " $sum $selectdata_step [$pop cget -selectdata_offset1]]

    $pop configure -selectdata_current1  0
    $pop configure -selectdata_current2  0
    $pop configure -selectdata_permutation "" ;# NULL
    
    #     if ( !(pop->selectdata.permutation = s_malloc(sizeof(int)*pop->orig_size)) )
    #       die("Unable to allocate memory");
    #     if ( !(ordered = s_malloc(sizeof(int)*pop->orig_size)) )
    #       die("Unable to allocate memory");

    for {set i 0} {$i < $orig_size} {incr i} {
      # ordered[i]=i;
      lappend  ordered $i
    }
    #  int    *iarray, // Source array.
    #  int    *oarray  // Destination array.

    #puts stderr "ordered = $ordered"

    #random_int_permutation  $orig_size $ordered oarray ;# перемешали числа
    #
    # вообще-то в оригинале массив "ordered" тоже портится, но здесь незаметно
    # поскольку вызывается один раз
    #
    random_int_permutation  $orig_size  ordered oarray ;# перемешали числа

    
    $pop configure -selectdata_permutation $oarray     ;# записаил перемешку
    #     s_free (ordered);
    #puts stderr "permuta = $oarray"

  } elseif {$select_state > [$pop cget -selectdata_num_to_select]} {

    if {$::is_print} {puts stderr "2 ... "}

    # эта ветка для окончания пеербора (селекции) пар ?
    #     s_free (pop->selectdata.permutation);
    #     pop->selectdata.permutation = NULL;

    $pop configure -selectdata_permutation ""
    return true ;# признак окончания

  } else {
    if {$::is_print} {puts stderr "3 ... "}

    set step [$pop cget -selectdata_step]
    $pop configure -selectdata_offset1 [expr [$pop cget -selectdata_offset1] + $step]
    $pop configure -selectdata_offset2 [expr [$pop cget -selectdata_offset2] + $step]
  }
  

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #   while (pop->selectdata.offset1 > pop->entity_iarray[pop->selectdata.current1]->fitness)
  #while {$off1 > $fit1} 
  while {1} \
  {
    set off1 [$pop cget -selectdata_offset1 ]
    set cur1 [$pop cget -selectdata_current1]
    #set fit1 [$pop get_entity_fitness $cur1 ]
    set fit1 [pop_get_entity_fitness_ $pop  $cur1 ]

    if {$off1 <= $fit1} {break}

    #puts "off1 > fit1"
    #exit

    # pop->selectdata.offset1 -= pop->entity_iarray[pop->selectdata.current1]->fitness;
    $pop configure -selectdata_offset1 [expr $off1 - $fit1]

    # pop->selectdata.current1++;
    incr cur1

    # if (pop->selectdata.current1 >= pop->orig_size) pop->selectdata.current1 -= pop->orig_size;
    if {$cur1 >= $orig_size} {
      set cur1 [expr $cur1 - $orig_size]
    }
    
    $pop configure -selectdata_current1 $cur1
  }
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #   while (pop->selectdata.offset2 > pop->entity_iarray[pop->selectdata.permutation[pop->selectdata.current2]]->fitness)
  #while {$off2 > $fit2} 
  while {1} \
  {
    set off2 [$pop cget -selectdata_offset2 ]
    set cur2 [$pop cget -selectdata_current2]
    set perm [$pop cget -selectdata_permutation]
    #set fit2 [$pop get_entity_fitness [lindex $perm $cur2]]
    set fit2 [pop_get_entity_fitness_ $pop  [lindex $perm $cur2]]

    if {$off2 <= $fit2} {break}

    #puts "off2 > fit2"
    #exit

    #     pop->selectdata.offset2 -= pop->entity_iarray[pop->selectdata.permutation[pop->selectdata.current2]]->fitness;
    $pop configure -selectdata_offset2 [expr $off2 - $fit2]

    #     pop->selectdata.current2++;
    incr cur2

    #     if (pop->selectdata.current2 >= pop->orig_size) pop->selectdata.current2 -= pop->orig_size;
    if {$cur2 >= $orig_size} {
      set cur2 [expr $cur2 - $orig_size]
    }    
    $pop configure -selectdata_current2 $cur2
  }
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  
  set cur1 [$pop cget -selectdata_current1]
  set cur2 [$pop cget -selectdata_current2]
  set perm [$pop cget -selectdata_permutation]

  if {$::is_print} {
    puts stderr "cur1 = $cur1"
    puts stderr "cur2 = $cur2"
    puts stderr "perm = $perm"
  }

  #   *mother = pop->entity_iarray[pop->selectdata.current1];
  #   *father = pop->entity_iarray[pop->selectdata.permutation[pop->selectdata.current2]];

  #set mother [$pop get_entity $cur1]
  set mother [pop_get_entity_ $pop  $cur1]

  #set father [$pop get_entity [lindex $perm $cur2]]
  set father [pop_get_entity_ $pop  [lindex $perm $cur2]]
  
  #   pop->select_state++;
  #$pop configure -select_state [expr [$pop cget -select_state] + 1]
  $pop configure -select_state [expr $select_state + 1]

  return false
}
#-------------------------------------------------------------------------------
# /**********************************************************************
#   synopsis:	Stochastic Universal Sampling selection using
# 		squared fitnesses.
#   		pop->mutation_ratio multiplied by pop->orig_size gives
# 		the number of selections which will be performed.
# 		This version is for fitness values where 0.0 is bad and
# 		large positive values are good.  Negative values will
# 		severely mess-up the algorithm.
#  **********************************************************************/
# boolean 
# ga_select_one_sussq (population *pop, entity **mother)
# {
#   double	sum;			/* Fitness total. */

#   if (!pop) die("Null pointer to population structure passed.");

#   *mother = NULL;

#   if (pop->orig_size < 1)
#   {
#     return TRUE;
#   }

#   if (pop->select_state == 0)
#   { /* First call of this generation. */
#     pop->selectdata.num_to_select = max(1,(int)floor(pop->orig_size*pop->mutation_ratio));
#     sum = gaul_select_sum_sq_fitness(pop);
#     pop->selectdata.step = sum/(pop->orig_size*pop->mutation_ratio);
#     pop->selectdata.offset1 = random_double(pop->selectdata.step);
#     pop->selectdata.current1=0;
#   }
#   else if (pop->select_state>pop->selectdata.num_to_select)
#   {
#     return TRUE;
#   }
#   else
#   {
#     pop->selectdata.offset1 += pop->selectdata.step;
#   }

#   while (pop->selectdata.offset1 > pop->entity_iarray[pop->selectdata.current1]->fitness * pop->entity_iarray[pop->selectdata.current1]->fitness)
#   {
#     pop->selectdata.offset1 -= (pop->entity_iarray[pop->selectdata.current1]->fitness * pop->entity_iarray[pop->selectdata.current1]->fitness);
#     pop->selectdata.current1++;
#     if (pop->selectdata.current1>=pop->orig_size) pop->selectdata.current1-=pop->orig_size;
#   }

#   *mother = pop->entity_iarray[pop->selectdata.current1];

#   pop->select_state++;

#   return FALSE;
# }
# /**********************************************************************
#   synopsis:	Stochastic Universal Sampling selection.
#   		pop->mutation_ratio multiplied by pop->orig_size gives
# 		the number of selections which will be performed.
# 		This version is for fitness values where 0.0 is bad and
# 		large positive values are good.  Negative values will
# 		severely mess-up the algorithm.
#  **********************************************************************/
# boolean 
# ga_select_two_sussq (population *pop, entity **mother, entity **father)
# {
#   double	sum;			/* Fitness total. */
#   int		*ordered;		/* Ordered indices. */
#   int		i;			/* Loop variable over indices. */

#   if (!pop) die("Null pointer to population structure passed.");

#   *mother = NULL;

#   if (pop->orig_size < 1)
#   {
#     return TRUE;
#   }

#   if (pop->select_state == 0)
#   { /* First call of this generation. */
#     pop->selectdata.num_to_select = max(1,(int)floor(pop->orig_size*pop->crossover_ratio));
#     sum = gaul_select_sum_sq_fitness(pop);
#     pop->selectdata.step = sum/pop->selectdata.num_to_select;
#     pop->selectdata.offset1 = pop->selectdata.offset2 = random_double(pop->selectdata.step);
#     pop->selectdata.current1=0;
#     pop->selectdata.current2=0;
#     pop->selectdata.permutation=NULL;

#     /*
#       if (pop->selectdata.permutation!=NULL)
#       die("Internal error.  Permutation buffer not NULL.");
#       */

#     if ( !(pop->selectdata.permutation = s_malloc(sizeof(int)*pop->orig_size)) )
#       die("Unable to allocate memory");
#     if ( !(ordered = s_malloc(sizeof(int)*pop->orig_size)) )
#       die("Unable to allocate memory");
#     for (i=0; i<pop->orig_size;i++)
#       ordered[i]=i;
#     random_int_permutation(pop->orig_size, ordered, pop->selectdata.permutation);
#     s_free(ordered);
#   }
#   else if (pop->select_state>pop->selectdata.num_to_select)
#   {
#     s_free(pop->selectdata.permutation);
#     pop->selectdata.permutation=NULL;
#     return TRUE;
#   }
#   else
#   {
#     pop->selectdata.offset1 += pop->selectdata.step;
#     pop->selectdata.offset2 += pop->selectdata.step;
#   }

#   while (pop->selectdata.offset1 > pop->entity_iarray[pop->selectdata.current1]->fitness * pop->entity_iarray[pop->selectdata.current1]->fitness)
#   {
#     pop->selectdata.offset1 -= (pop->entity_iarray[pop->selectdata.current1]->fitness * pop->entity_iarray[pop->selectdata.current1]->fitness);
#     pop->selectdata.current1++;
#     if (pop->selectdata.current1>=pop->orig_size)
#       pop->selectdata.current1-=pop->orig_size;
#   }

#   while (pop->selectdata.offset2 > pop->entity_iarray[pop->selectdata.current2]->fitness * pop->entity_iarray[pop->selectdata.current2]->fitness)
#   {
#     pop->selectdata.offset2 -= (pop->entity_iarray[pop->selectdata.current2]->fitness * pop->entity_iarray[pop->selectdata.current2]->fitness);
#     pop->selectdata.current2++;
#     if (pop->selectdata.current2>=pop->orig_size) pop->selectdata.current2-=pop->orig_size;
#   }

#   *mother = pop->entity_iarray[pop->selectdata.current1];
#   *father = pop->entity_iarray[pop->selectdata.permutation[pop->selectdata.current2]];

#   pop->select_state++;

#   return FALSE;
# }
# /**********************************************************************
#   synopsis:	Select an entity using a very aggressive procedure.
#  **********************************************************************/
# boolean 
# ga_select_one_aggressive (population *pop, entity **mother)
# {

#   if (!pop) die("Null pointer to population structure passed.");

#   pop->select_state++;

#   *mother = pop->entity_iarray[random_int(1+pop->select_state%(pop->orig_size-1))];

#   return pop->select_state>(pop->orig_size*pop->mutation_ratio);
# }
# /**********************************************************************
#   synopsis:	Select a pair of entities, both by a very aggressive
# 		procedure.  The entities may be the same.
#  **********************************************************************/
# boolean 
# ga_select_two_aggressive (population *pop, entity **mother, entity **father)
# {

#   if (!pop) die("Null pointer to population structure passed.");

#   pop->select_state++;

#   *father = pop->entity_iarray[random_int(1+pop->select_state%(pop->orig_size-1))];
#   *mother = pop->entity_iarray[random_int(1+pop->select_state%(pop->orig_size-1))];

#   return pop->select_state>(pop->orig_size*pop->crossover_ratio);
# }
# /**********************************************************************
#   synopsis:	Select the best entity only.
#  **********************************************************************/
# boolean 
# ga_select_one_best (population *pop, entity **mother)
# {

#   if (!pop) die("Null pointer to population structure passed.");

#   pop->select_state++;

#   *mother = pop->entity_iarray[0];

#   return pop->select_state>(pop->orig_size*pop->mutation_ratio);
# }
# /**********************************************************************
#   synopsis:	Select a pair of entities, one of which is random, the
#                 other is the best entity.
#  **********************************************************************/
# boolean 
# ga_select_two_best (population *pop, entity **mother, entity **father)
# {

#   if (!pop) die("Null pointer to population structure passed.");

#   pop->select_state++;

#   *mother = pop->entity_iarray[random_int(pop->orig_size)];
#   *father = pop->entity_iarray[0];

#   return pop->select_state>(pop->orig_size*pop->crossover_ratio);
# }
# /**********************************************************************
#   synopsis:	Select an entity based on linear probability
# 		distribution with respect to rank.
#  **********************************************************************/
# boolean 
# ga_select_one_linearrank (population *pop, entity **mother)
# {

#   if (!pop) die("Null pointer to population structure passed.");

#   pop->select_state++;

#   *mother = pop->entity_iarray[(int)((1.0-sqrt(random_unit_uniform()))*pop->orig_size)];

#   return pop->select_state>(pop->orig_size*pop->mutation_ratio);
# }
# /**********************************************************************
#   synopsis:	Select two entities based on linear probability
# 		distribution with respect to rank.
#  **********************************************************************/
# boolean 
# ga_select_two_linearrank (population *pop, entity **mother, entity **father)
# {

#   if (!pop) die("Null pointer to population structure passed.");

#   pop->select_state++;

#   *mother = pop->entity_iarray[(int)((1.0-sqrt(random_unit_uniform()))*pop->orig_size)];
#   do
#   {
#     *father = pop->entity_iarray[(int)((1.0-sqrt(random_unit_uniform()))*pop->orig_size)];
#   } while (*mother == *father);

#   return pop->select_state>(pop->orig_size*pop->crossover_ratio);
# }
# /**********************************************************************
#   synopsis:	Select an entities in a round-robin fashion.
#  **********************************************************************/
# boolean 
# ga_select_one_roundrobin( population *pop, entity **mother)
# {

#   if (!pop) die("Null pointer to population structure passed.");

#   *mother = pop->entity_iarray[pop->select_state%pop->orig_size];

#   pop->select_state++;

#   return pop->select_state>=(pop->orig_size*pop->mutation_ratio);
# }
# //******************************************************************************


