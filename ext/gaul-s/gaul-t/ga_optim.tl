# ------------------------------------------------------------------------------
#  
# ------------------------------------------------------------------------------
#   ga_optim.c

#   ga_optim - Optimisation and evolution routines.
#   Copyright б╘2000-2006, Stewart Adcock <stewart@linux-domain.com>
#   All rights reserved.

#   Synopsis:     Routines for optimisation and evolution.
# 
#                 Note that the temperatures in the simulated annealling
#                 and MC functions do not exactly run from the initial
#                 temperature to the final temperature.  They are offset
#                 slightly so that sequential calls to these functions
#                 will have a linear temperature change.  The SA and MC
# 		code in this file is deprecated anyway - these routines
# 		have been replaced with much more flexible alternatives
# 		and will be removed in the near future.
# 
#   To do:	Finish rewriting parallel versions, ga_evolution_mp() in particular.
# 		Write ga_evolution_pvm().
# 		Remove much duplicated code.
# 		OpenMOSIX fix.  See below.
# 		gaul_adapt_and_evaluate_forked() and gaul_adapt_and_evaluate_threaded() 
#                 are only parallelized for the case that no adaptation occurs.

# //------------------------------------------------------------------------------

# //#include "ga_optim.h"
# #include "gaul.h"

# /*
#  * Here is a kludge.
#  *
#  * This constant, if defined, causes a 10 microsecond delay to be
#  * inserted after each fork() call.  It shouldn't be needed, but
#  * apparently on OpenMOSIX lots of processes started at the same
#  * time cause all sorts of problems (mostly bus errors).  This
#  * delay gives OpenMOSIX a chance to migrate some processes to
#  * other nodes before this becomes a problem (hopefully).
#  *
#  * A long-term fix fix will be to check the return value from the
#  * forked processes and repeat them if they died.  This may be
#  * added... eventually.
#  *
#  * I don't think this is needed anymore for recent versions of
#  * OpenMOSIX.
#  */
# #define NEED_MOSIX_FORK_HACK 1

# //------------------------------------------------------------------------------
# //  synopsis:	Swap the ranks of a pair of entities.
# //  parameters: population *pop
# //		const int rank1
# //		const int rank2
# //  return:	none
# //------------------------------------------------------------------------------
proc gaul_entity_swap_rank {pop rank1 rank2} \
{
  #   entity	*tmp;		/* Swapped entity. */
  
  #   tmp = pop->entity_iarray[rank1];
  #set tmp [$pop get_entity $rank1]
  set tmp [pop_get_entity_ $pop  $rank1]

  #   pop->entity_iarray[rank1] = pop->entity_iarray[rank2];
  #$pop set_entity $rank1 [$pop get_entity $rank2]
  pop_set_entity_ $pop  $rank1 [pop_get_entity_ $pop  $rank2]

  #   pop->entity_iarray[rank2] = tmp;
  pop_set_entity_ $pop  $rank2 $tmp
  
  return
}
# //------------------------------------------------------------------------------
# //  synopsis:	Migration cycle.
# //  parameters:	population *pop
# //  return:	none
# //------------------------------------------------------------------------------
# void 
# gaul_migration (const int num_pops, population **pops)
# //------------------------------------------------------------------------------
proc gaul_migration {num_pops pops} \
{

  #   int  pop0_osize;	    /* Required for correct migration.  */
  #   int  current_island;  /* Current current_island number.   */
  #   int  i;		    /* Loop over members of population. */
  
  #   plog (LOG_VERBOSE, "*** Migration Cycle ***");
  
  if {$::is_print} {
    puts "gaul_migration : "
    puts ""
  }

  #   pop0_osize = pops[0]->size;
  set pop0 [lindex $pops 0]
  set pop0_osize [$pop0 cget -size]
  
  for {set current_island 1} {$current_island < $num_pops} {incr current_island} {
  
    set popcur   [lindex $pops $current_island]
    set popcur_1 [lindex $pops [expr $current_island - 1]]

    for {set i 0} {$i < [$popcur cget -size]} {incr i} {
    
      if {[random_boolean_prob [$popcur cget -migration_ratio]]} {
        
        #ga_entity_clone $popcur_1 [$popcur get_entity $i];
        ga_entity_clone $popcur_1 [pop_get_entity_ $popcur  $i];
        
        # /* printf ("%d, %d: Cloned %d %f\n", mpi_get_rank(), current_island, i, 
        #   pops[current_island]->entity_iarray[i]->fitness);*/
      }
    }
  }
  
  set popbeg  [lindex $pops 0]
  set popend  [lindex $pops [expr $num_pops - 1]]

  for {set i 0} {$i < $pop0_osize} {incr i} {
  
    if {[random_boolean_prob  [$popbeg cget -migration_ratio]]} {
      #ga_entity_clone $popend [popbeg get_entity $i]
      #ga_entity_clone $popend [$popbeg get_entity $i] ;# !!! одинаково
      ga_entity_clone $popend [pop_get_entity_ $popbeg  $i]
    }
    
    #     /*  printf("%d, 0: Cloned %d %f\n", mpi_get_rank(), i, 
    #       pops[current_island]->entity_iarray[i]->fitness);*/
  }
  
  #   /*
  #     * Sort the individuals in each population.
  #     * Need this to ensure that new immigrants are ranked correctly.
  #     * FIXME: It would be more efficient to insert the immigrants correctly.
  #     */
  
  for {set current_island 0} {$current_island < $num_pops} {incr current_island} \
  {
    sort_population [lindex $pops $current_island];
  }

  return
}
# //------------------------------------------------------------------------------
# //  synopsis:	Mating cycle. (i.e. Sexual reproduction).
# //  parameters:	population *pop
# //  return:	none
# //------------------------------------------------------------------------------
proc gaul_crossover {pop} {

  #   entity	*mother, *father;  /* Parent entities. */
  #   entity	*son, *dau;        /* Child entities.  */
  
  #   plog (LOG_VERBOSE, "*** Mating cycle ***");

  set select_two_proc [$pop cget -select_two]

  if {$::is_print} {
    puts "gaul_crossover : (select_two_proc = $select_two_proc)"
    #puts "gaul_crossover : "
    puts ""
  }
  
  if {[$pop cget -crossover_ratio] <= 0.0}  { 
    puts "!!!!!!!!!!!!!!!!!!!!"
    return 
  }
  
  # здесь обнуляем, т.е. начинаем процедуру выбора (селекции) сначала
  # 
  $pop configure -select_state 0
  
  #   /* Select pairs of entities to mate via crossover. */
  #   /* #pragma intel omp parallel taskq */
  
  while {! [$select_two_proc $pop  mother father]} {
  
    #if {$mother == "NULL"} {

    #       plog (LOG_VERBOSE, 
    #             "Crossover between %d (rank %d fitness %f) and %d (rank %d fitness %f)",
    #             ga_get_entity_id(pop, mother),
    #             ga_get_entity_rank(pop, mother), mother->fitness,
    #             ga_get_entity_id(pop, father),
    #             ga_get_entity_rank(pop, father), father->fitness);
    
    set son [ga_get_free_entity $pop]
    set dau [ga_get_free_entity $pop]

    # pop->crossover (pop, mother, father, dau, son); ??? почему перепутано ??
    [$pop cget -crossover] $pop  $mother $father $dau $son
    
    # перепутанный порядок даже с сишным вариантом!
    # однако

    if {$::is_print} {
      print_entit  $mother "mom ="
      print_entit  $father "dad ="
      print_entit  $dau    "dau ="
      print_entit  $son    "son ="       
    }

    #} else {
    #  plog LOG_VERBOSE "Crossover not performed."
    #}

    if {$::is_print} {
      puts ""
    }

  }
  
  return
}
# //------------------------------------------------------------------------------
# //  synopsis:	Mutation cycle.  (i.e. Asexual reproduction)
# //  parameters:	population *pop
# //  return:	none
# //------------------------------------------------------------------------------
proc gaul_mutation {pop} {

  #   entity    *mother;	    /* Parent entities. */
  #   entity    *daughter;	    /* Child entities.  */
  
  #   plog (LOG_VERBOSE, "*** Mutation cycle ***");
  
  if {$::is_print} {
    puts "gaul_mutation : "
    puts ""
  }
  
  #   if (pop->mutation_ratio <= 0.0) return;
  if {[$pop cget -mutation_ratio] <= 0.0}  { return }  
  
  #   pop->select_state = 0;
  $pop configure -select_state 0
  
  #   /*
  #     * Select entities to undergo asexual reproduction, in each case the child will
  #     * have a genetic mutation of some type.
  #     */
  
  #   while ( !(pop->select_one(pop, &mother)) )
  while { ! [[$pop cget -select_one] $pop mother] } {


    # в Си-шном варианте тут есть проблема, когда mother == NULL !!!!!
    # а здесь нет такого ??
    # 
    #if {$::is_print} {
    #  print_entit  $mother "mam ="
    #}

    #     if (mother)
    #     {
    #       //{
    #         plog(LOG_VERBOSE, "Mutation of %d (rank %d fitness %f)",
    #              ga_get_entity_id(pop, mother),
    #              ga_get_entity_rank(pop, mother), mother->fitness );
    
    #         daughter = ga_get_free_entity(pop);
    set dau [ga_get_free_entity $pop]

    #         pop->mutate(pop, mother, daughter);
    [$pop cget -mutate] $pop  $mother $dau
    
    #         if (is_print) print_entit (daughter, "dau =", pop->len_chromosomes);
    if {$::is_print} {
      print_entit  $dau "dau ="
      puts ""
    }

    #       //}
    #     } else {
    
    #       plog( LOG_VERBOSE, "Mutation not performed." );
    #     }
  }
  
  return
}
# //------------------------------------------------------------------------------
# //  synopsis:	Fitness evaluations.
# //		Evaluate all previously unevaluated entities.
# //		No adaptation.
# //  parameters:	population *pop
# //  return:	none
# //------------------------------------------------------------------------------
proc gaul_ensure_evaluations {pop} \
{
  #   int  i;	/* Loop variable over entity ranks. */
  
  for {set i 0} {$i < [$pop cget -size]} {incr i} {

    #     if (pop->entity_iarray[i]->fitness == GA_MIN_FITNESS)
    #     {
    #       if ( pop->evaluate(pop, pop->entity_iarray[i]) == FALSE )
    #         pop->entity_iarray[i]->fitness = GA_MIN_FITNESS;
    #     }
    
    #set entity [$pop get_entity $i]
    set entity [pop_get_entity_ $pop  $i]

    if {[$entity cget -fitness] == $::GA_MIN_FITNESS} {

      set ret [[$pop cget -evaluate] $pop $entity]

      if {$ret == false} {
        #  pop->entity_iarray[i]->fitness = GA_MIN_FITNESS;
        puts "ERROR ............. !!!!!!!!!!!!!!!!!!!!!!"
        exit ;# пока сделаем просто ошибку..
     }
    }

  }

  return
}
# //------------------------------------------------------------------------------
proc score_and_sort_initial_pop {pop} {

  set size        [$pop cget -size]
  set stable_size [$pop cget -stable_size]

  if {$size < $stable_size} {
    #gaul_population_fill (pop, pop->stable_size - pop->size);
    gaul_population_fill $pop [expr $stable_size - $size]
  }
  
  gaul_ensure_evaluations $pop
  sort_population         $pop
  
  ga_genocide_by_fitness  $pop $::GA_MIN_FITNESS

  return
}
# //------------------------------------------------------------------------------
# 
# лонгическая схема сделана так будто в перечисляемом типе "scheme" хранится
# несколько одновременно флажков, но нигде не нашел где это формируется, т.е.
# где эти битовые маски складываются ! наверное это лишнее !?
# 
# //------------------------------------------------------------------------------
# int 
# is_in_scheme (ga_scheme_type scheme, ga_scheme_type name)
# //------------------------------------------------------------------------------
proc is_in_scheme {scheme name} \
{

  #puts "is_in_scheme : scheme = $scheme"
  #puts ""

  #   //int ret = ((scheme & GA_SCHEME_BALDWIN_PARENTS) != 0);
  #   int ret = ((scheme & name) != 0);

  # пока предпологаем, что там не список:
  # 
  set ret [expr {$scheme == $name}]

  return $ret
}
# //------------------------------------------------------------------------------
# int 
# is_in_scheme_only (ga_scheme_type scheme, ga_scheme_type name)
# //------------------------------------------------------------------------------
proc is_in_scheme_only {scheme name} \
{

  #puts "is_in_scheme_only : scheme = $scheme"
  #puts ""

  # // (scheme == GA_SCHEME_DARWIN)
  # int ret = (scheme == name);

  # пока предпологаем, что там не список:
  # 
  set ret [expr {$scheme == $name}]

  return $ret
}
# //------------------------------------------------------------------------------
# void adapt_1 (population *pop, int ibeg, int iend)
# //------------------------------------------------------------------------------
proc adapt_1 {pop ibeg iend} \
{

  if {$::is_print} {
    puts "adapt_1 ... BEGIN : "
    puts ""
    #$pop print
    #puts ""
  }

  #   int	    i;			/* Loop variable over entity ranks. */
  #   entity    *adult = NULL;	/* Adapted entity.                  */
  
  # адаптируем новые элементы
  # 

  for {set i $ibeg} {$i < $iend} {incr i} \
  {
    #     adult = pop->adapt (pop, pop->entity_iarray[i]);
    #set adult [[$pop cget -adapt] $pop [$pop get_entity $i]]
    set adult [[$pop cget -adapt] $pop [pop_get_entity_ $pop  $i]]

    # выполнили адаптацию, т.е. "взрастили" особь (?)
    # и теперь ее фитнесс запишем младенцу (?)

    #     pop->entity_iarray[i]->fitness = adult->fitness;
    set fi [$adult cget -fitness]

    if {$::is_print} {
      puts [format "i = %2d  fi = $fi" $i]
    }

    #pop->entity_iarray[i]->fitness = fi;
    #$pop set_entity_fitness  $i $fi ;# не оказывает эффекта ??? просто ошибка
    pop_set_entity_fitness_ $pop   $i $fi ;# не оказывает эффекта ??? просто ошибка

    ga_entity_dereference  $pop $adult
  }

  if {$::is_print} {
    #puts ""
    #$pop print
    puts ""
    puts "adapt_1 ... FINAL ."
  }

  return
}
# //------------------------------------------------------------------------------
proc adapt_2 {pop ibeg iend} \
{

  #   int	    i;			/* Loop variable over entity ranks. */
  #   entity    *adult = NULL;	/* Adapted entity.                  */
  #   int	    adultrank;		/* Rank of adapted entity.          */
  
  for {set i $ibeg} {$i < $iend} {incr i} \
  {
    # adult     = pop->adapt (pop, pop->entity_iarray[i]);
    # set adult [[$pop cget -adapt] $pop [$pop get_entity $i]]
    set adult [[$pop cget -adapt] $pop [pop_get_entity_ $pop  $i]]
    
    set adultrank [ga_get_entity_rank  $pop $adult]
    
    gaul_entity_swap_rank  $pop $i $adultrank
    
    ga_entity_dereference_by_rank  $pop $adultrank
  }

  return
}
# //------------------------------------------------------------------------------
# //  synopsis:	Fitness evaluations.
# //		Evaluate the new entities produced in the current
# //		generation, whilst performing any necessary adaptation.
# //		Simple sequential version.
# //  parameters:	population *pop
# //  return:	none
# //------------------------------------------------------------------------------
proc gaul_adapt_and_evaluate {pop} \
{
  #   int  i;  /* Loop variable over entity ranks. */
  
  #   /* typedef enum ga_scheme_type_t     */
  #   /*   { */
  #   /*   GA_SCHEME_DARWIN           = 0, */
  #   /*   GA_SCHEME_LAMARCK_PARENTS  = 1, */
  #   /*   GA_SCHEME_LAMARCK_CHILDREN = 2, */
  #   /*   GA_SCHEME_LAMARCK_ALL      = 3, */
  #   /*   GA_SCHEME_BALDWIN_PARENTS  = 4, */
  #   /*   GA_SCHEME_BALDWIN_CHILDREN = 8, */
  #   /*   GA_SCHEME_BALDWIN_ALL      = 12 */
  #   /*   } ga_scheme_type; */
  
  #   ga_scheme_type scheme = pop->scheme;	/* Evolutionary scheme.    */
  set scheme [$pop cget -scheme]
  
  if {[is_in_scheme_only $scheme "GA_SCHEME_DARWIN"]} {
  
    #  // This is pure Darwinian evolution. Simply assess fitness of all children.
    
    #  plog (LOG_VERBOSE, "*** Fitness Evaluations ***");
    
    #  for (i = pop->orig_size; i < pop->size; i++)
    #  {
    #    if ( pop->evaluate (pop, pop->entity_iarray[i]) == FALSE )
    #      pop->entity_iarray[i]->fitness = GA_MIN_FITNESS;
    #  }
  
    for {set i [$pop cget -orig_size]} {$i < [$pop cget -size]} {incr i} \
    {
      #set entity [$pop get_entity $i]
      set entity [pop_get_entity_ $pop  $i]

      set ret   [[$pop cget -evaluate] $pop $entity]

      if {$ret == false} {
        #pop->entity_iarray[i]->fitness = GA_MIN_FITNESS;
        puts "ERROR ............. !!!!!!!!!!!!!!!!!!!!!!"
        exit ;# пока сделаем просто ошибку..
      }

    }
  
  } else {
  
    #  // Some kind of adaptation is required.  First reevaluate parents, as needed, 
    #  // then children. 
    
    #  plog (LOG_VERBOSE, "*** Adaptation and Fitness Evaluations ***");
    
    if       {[is_in_scheme $scheme "GA_SCHEME_BALDWIN_PARENTS"]} {
    
      adapt_1  $pop 0 [$pop cget -orig_size]
    
    } elseif {[is_in_scheme $scheme "GA_SCHEME_LAMARCK_PARENTS"]} {
      
      adapt_2  $pop 0 [$pop cget -orig_size]
    }
    
    
    if        {[is_in_scheme $scheme "GA_SCHEME_BALDWIN_CHILDREN"]} {
    
      adapt_1  $pop [$pop cget -orig_size] [$pop cget -size]
    
    } elseif {[is_in_scheme $scheme "GA_SCHEME_LAMARCK_CHILDREN"]} {
    
      adapt_2  $pop [$pop cget -orig_size] [$pop cget -size]
    }

  }
  
  return
}
# //------------------------------------------------------------------------------
# //------------------------------------------------------------------------------
proc sort_and_genocide_by_fitness {pop} \
{

  #   // Sort all population members by fitness.
  #   //
  sort_population $pop
  
  #   // Ensure that any very bad solutions are not retained.
  #   //
  ga_genocide_by_fitness $pop $::GA_MIN_FITNESS ;# - это имеет ли смысл?

  return
}
# //------------------------------------------------------------------------------
proc sort_and_genocide {pop} \
{

  sort_and_genocide_by_fitness  $pop


  #   // Least fit population members die to restore the
  #   // population size to its stable size.
  #   //

  ga_genocide $pop [$pop cget -stable_size]

  return
}
# //------------------------------------------------------------------------------
# void ga_elitism_parents_die_exept (population *pop, int num_parents_survives)
# //------------------------------------------------------------------------------
proc ga_elitism_parents_die_exept {pop num_parents_survives} \
{

  #   //int num_parents_survives = 1 (elitism == GA_ELITISM_ONE_PARENT_SURVIVES);
  #   //
  #   // эта хитрая конструкция означает сколько родителей оставить : 0 или 1
  
  while {[$pop cget -orig_size] > $num_parents_survives} \
  {
    #     pop->orig_size--;
    $pop configure -orig_size  [expr [$pop cget -orig_size] - 1]

    #ga_entity_dereference_by_rank (pop, pop->orig_size);
    ga_entity_dereference_by_rank $pop [$pop cget -orig_size]
  }
  
  sort_and_genocide $pop

  return
}
# //------------------------------------------------------------------------------
# void ga_elitism_rescore_parents (population *pop)
# {
#   int i;

#   plog (LOG_VERBOSE, "*** Fitness Re-evaluations ***");
  
#   for (i = pop->orig_size; i < pop->size; i++)
#   {
#     if ( pop->evaluate (pop, pop->entity_iarray[i]) == FALSE )
#       pop->entity_iarray[i]->fitness = GA_MIN_FITNESS;
#   }
  
#   sort_and_genocide (pop);
  
#   return;
# }
# //------------------------------------------------------------------------------
# void ga_elitism_best_set_survive (population *pop)
# {

#   int	    i, j, k;	 /* Loop variable over entity ranks.      */
#   boolean   save_entity; /* Whether entity should survive.        */
#   int	    *set;	 /* The best entities for each objective. */


#   // Find the best entities along each dimension of the fitness vector.

#   if (! (set = s_malloc (sizeof(int) * pop->fitness_dimensions)))
#     die ("Unable to allocate memory");

#   sort_and_genocide_by_fitness (pop);


#   for (i = 0; i < pop->fitness_dimensions; i++)
#     set[i] = 0;

#   for (j = 1; j < pop->size; j++) {

#     for (i = 0; i < pop->fitness_dimensions && set[i]==pop->orig_size; i++)
#     {
#       if ( pop->entity_iarray[j]->fitvector[i] >
#           pop->entity_iarray[set[i]]->fitvector[i] )
#         set[i] = j;
#     }
#   }

#   // Allow all parents in the best set to survive.  Make up to
#   // population's stable size with the fittest of the remainder.
#   //

#   k = pop->size;

#   while (k > 0 && pop->size > pop->stable_size) {

#     k--;
#     save_entity = FALSE;

#     for (i = 0; i < pop->fitness_dimensions; i++) {
#       if (set[i] == k) {
#         save_entity = TRUE;
#       }
#     }

#     if (save_entity == FALSE) {
#       ga_entity_dereference_by_rank (pop, k);
#     }
#   }

#   s_free (set);

#   return;
# }
# //------------------------------------------------------------------------------
# void ga_elitism_pareto_set_survive (population *pop)
# {

#   int	     i, j, k;	  /* Loop variable over entity ranks.         */
#   boolean    *dominated;  /* Whether each entity is Pareto dominated. */
#   int	     paretocount; /* Size of Pareto set.                      */
#   boolean    dominance;	  /* Used in determining dominance.           */
 
#   // Find the Pareto set (i.e., all non-dominated entities) according
#   // to the fitness vector.  An entity is dominated if at least one other
#   // entity is better in all objectives.
#   //

#   if (! (dominated = s_malloc (sizeof(int) * pop->size)))
#     die ("Unable to allocate memory");

#   sort_and_genocide_by_fitness (pop);


#   paretocount = pop->size;

#   for (j = 0; j<pop->size; j++) {
#     dominated[j] = FALSE;
#   }

#   for (j = 0; j < pop->size; j++) {

#     for (k = 0; k < pop->size && dominated[j] == FALSE; k++) {

#       if (k != j) {
#         /* Is k better than j in all dimensions? */
#         dominance = TRUE;

#         for (i = 0; i < pop->fitness_dimensions && dominance == TRUE; i++) 
#         {
#           if (pop->entity_iarray[j]->fitvector[i] >
#               pop->entity_iarray[k]->fitvector[i] )
#           {
#             dominance = FALSE;
#           }
#         }

#         if (dominance == TRUE) {
#           dominated[j] = TRUE;
#           paretocount--;
#         }
#       }
#     }
#   }

#   /* Debug message: */
#   /*
#     printf ("Pareto set contains %d entities: ", paretocount);
#     for (j=0; j<pop->size; j++)
#     {
#     if (dominated[j] == FALSE)
#     printf(" %d", j);
#     }
#     printf("\n");
#     */

#   /*
#     * Allow all entities in the Pareto set to survive.  Make up to
#     * population's stable size with the fittest of the remainder.
#     */

#   i = pop->size;

#   while (i > 0 && pop->size > pop->stable_size)
#   {
#     i--;
#     if ( dominated[i] )
#       ga_entity_dereference_by_rank (pop, i);
#   }

#   s_free (dominated);

#   return;
# }
# //------------------------------------------------------------------------------
# //  synopsis:	Survival of the fittest.
# //		Enforce elitism, reduce
# //		population back to its stable size and rerank entities,
# //		as required.
# //  parameters:	population *pop
# //  return:	none
# //------------------------------------------------------------------------------
proc gaul_survival {pop} \
{

  #   plog (LOG_VERBOSE, "*** Survival of the fittest ***");

  #   /* typedef enum ga_elitism_type_t */
  #   /*   { */
  #   /*   GA_ELITISM_UNKNOWN             = 0, */
  #   /*   GA_ELITISM_NULL                = 0, */
  #   /*   GA_ELITISM_PARENTS_SURVIVE     = 1, */
  #   /*   GA_ELITISM_ONE_PARENT_SURVIVES = 2, */
  #   /*   GA_ELITISM_PARENTS_DIE         = 3, */
  #   /*   GA_ELITISM_RESCORE_PARENTS     = 4, */
  #   /*   GA_ELITISM_BEST_SET_SURVIVE    = 5, */
  #   /*   GA_ELITISM_PARETO_SET_SURVIVE  = 6 */
  #   /*   } ga_elitism_type; */
  
  #   ga_elitism_type  elitism = pop->elitism;   /* Elitism mode. */
  set elitism [$pop cget -elitism]

  #puts "gaul_survival: elitism = $elitism"
  #puts ""
  
  if       {$elitism == "GA_ELITISM_PARENTS_SURVIVE"} {
  
    sort_and_genocide $pop
  
  } elseif {$elitism == "GA_ELITISM_PARENTS_DIE"} {
  
    ga_elitism_parents_die_exept  $pop 0
    
  } elseif {$elitism == "GA_ELITISM_ONE_PARENT_SURVIVES"} {
    
    ga_elitism_parents_die_exept  $pop 1
    
  } elseif {$elitism == "GA_ELITISM_RESCORE_PARENTS"}    {
    
    ga_elitism_rescore_parents $pop
    
  } elseif {$elitism == "GA_ELITISM_BEST_SET_SURVIVE"}   {
    
    ga_elitism_best_set_survive $pop
    
  } elseif {$elitism == "GA_ELITISM_PARETO_SET_SURVIVE"} {
    
    ga_elitism_pareto_set_survive $pop
    
  }
  
  return
}
# //------------------------------------------------------------------------------
proc crossover_mutation_adapt_survival {pop} {

  if {$::is_print} {
    pop_print $pop
  }
  
  #     // Crossover step.
  #     //
  gaul_crossover $pop
  
  if {$::is_print} {
    pop_print $pop
  }
  
  #     // Mutation step.
  #     //
  gaul_mutation $pop
  
  #if {$::is_print} {
  #  puts ""
  #  pop_print $pop
  #}
  
  #     // Apply environmental adaptations, score entities, sort entities, etc.
  #     //
  gaul_adapt_and_evaluate $pop
  
  #     // Survival of the fittest.
  #     //
  gaul_survival $pop
    
  return
}
# //------------------------------------------------------------------------------
# //  synopsis:	Main genetic algorithm routine.  Performs GA-based
# //		optimisation on the given population.
# //		This is a generation-based GA.
# //		ga_genesis(), or equivalent, must be called prior to
# //		this function.
# //  parameters:
# //  return:
# //------------------------------------------------------------------------------
proc ga_evolution {pop max_generations} {

  #   int  generation = 0;  /* Current generation number. */
  set generation 0

  #   /* Checks. */

  #   if (!pop)             die ("NULL pointer to population structure passed.");
  #   if (!pop->evaluate)   die ("Population's evaluation callback is undefined.");
  #   if (!pop->select_one) die ("Population's asexual selection callback is undefined.");
  #   if (!pop->select_two) die ("Population's sexual selection callback is undefined.");
  #   if (!pop->mutate)     die ("Population's mutation callback is undefined.");
  #   if (!pop->crossover)  die ("Population's crossover callback is undefined.");
  #   if (!pop->rank)       die ("Population's ranking callback is undefined.");
  
  #   if (pop->scheme != GA_SCHEME_DARWIN && !pop->adapt) 
  #     die ("Population's adaption callback is undefined.");
  
  #   plog (LOG_VERBOSE, "The evolution has begun!");
  
  #   pop->generation = 0;
  $pop configure -generation 0
  
  #   //
  #   // Score and sort the initial population members.
  #   //
  score_and_sort_initial_pop $pop
  
  #   plog (LOG_VERBOSE,
  #         "Prior to the first generation, population has fitness scores between %f and %f",
  #         pop->entity_iarray[0]->fitness,
  #         pop->entity_iarray[pop->size-1]->fitness);
  
  #   printf ("\n");  
  
  #   // Do all the generations:
  #   //
  #   // Stop when (a) max_generations reached, or
  #   //           (b) "pop->generation_hook" returns FALSE.
  
  #   // while ( (pop->generation_hook?pop->generation_hook(generation, pop):TRUE) && 
  #   //          generation < max_generations ) 
  
  #puts "ga_evolution : max_generations = $max_generations"
  #exit

  while {1} {

    if {$::is_print} {
      puts ""
      puts "GENERATION LOOP ......... generation = $generation"
      puts ""
    } else {
      set  g_hook [$pop cget -generation_hook]
      if {$g_hook != "NULL"} {
        [$pop cget -generation_hook]  $generation $pop ; #// печать через 10
      }
    }

    if {$generation >= $max_generations} {break}
  
    #     // сделали простой while .................    
    #     generation++;
    #     pop->generation = generation;
    incr generation
    $pop configure -generation $generation
    
    #     pop->orig_size = pop->size;
    $pop configure -orig_size  [$pop cget -size] 
    
    #     plog (LOG_DEBUG,
    #               "Population size is %d at start of generation %d",
    #               pop->orig_size, generation );
    
    crossover_mutation_adapt_survival $pop
    
    
    #     // End of generation.
    #     //
    #     plog (LOG_VERBOSE,
    #           "After generation %d, population has fitness scores between %f and %f",
    #           generation,
    #           pop->entity_iarray[0]->fitness,
    #           pop->entity_iarray[pop->size-1]->fitness);
  
  } ;# /* Generation loop. */
  
  
  if ($::is_print) {
    puts ""
    puts "FINAL RESULT: "
    puts ""
    #$pop print
    pop_print_ $pop
    puts ""
  }

  #exit
  return $generation
}
# //------------------------------------------------------------------------------
# //  synopsis:	Main genetic algorithm routine.  Performs GA-based
# //		optimisation on the given population.  This is a
# //		generation-based GA.  ga_genesis(), or equivalent,
# //		must be called prior to this function.

# //		This function is like ga_evolution(), except that all
# //		fitness evaluations will be performed in forked
# //		processes which is ideal for use on multiprocessor
# //		machines or Beowulf-style clusters with process
# //		migration e.g. Mosix ( http://www.mosix.org/ ) or
# //		openMosix ( http://openmosix.sourceforge.net/ )

# //		Thanks go to Syrrx, Inc. who, in essence, funded
# //		development of this function.

# //  parameters:
# //  return:	Number of generations performed.
# //------------------------------------------------------------------------------
# int 
# ga_evolution_forked (population	 *pop,
# 		     int	  max_generations)
# {
#   int	generation=0;  /* Current generation number. */

#   //
#   // это я все удалил  (и вызываемы форканутые процедуры тоеж)
#   // 

#   return generation;
# }
# //------------------------------------------------------------------------------
# void adapt_check_by_rank (population *pop, int ibeg, int iend)
# {

#   int	    i;			/* Loop variable over entity ranks. */
#   entity    *adult = NULL;	/* Adapted entity.                  */

#   //for (i = pop->orig_size; i < new_pop_size; i++)

#   for (i = ibeg; i < iend; i++)
#   {
#     adult = pop->adapt (pop, pop->entity_iarray[i]);
#     pop->entity_iarray[i]->fitness = adult->fitness;
#     /* check. */ s_assert (ga_get_entity_rank (pop, adult) == iend);
#     ga_entity_dereference_by_rank (pop, iend);
#   }

#   return;
# }

# //------------------------------------------------------------------------------
# void adapt_by_rank (population *pop, int ibeg, int iend)
# {

#   //entity  *adult = NULL;  /* Adapted entity.  */
#   // while (new_pop_size > pop->orig_size)

#   while (iend > ibeg)
#   {
#     iend--;
#     /* adult = */ pop->adapt (pop, pop->entity_iarray [iend]);
#     ga_entity_dereference_by_rank (pop, iend);
#   }
  
#   return;
# }
# //------------------------------------------------------------------------------
# void evaluate_ga_entity (population *pop, entity **p_e)
# {
#   entity *e = *p_e;

#   if (pop->evaluate (pop, e) == FALSE)
#   {
#     ga_entity_dereference (pop, e);
#     *p_e = NULL;
#   }

#   return;
# }
# //------------------------------------------------------------------------------
# void environmental_adaptation (population *pop)
# {

#   plog (LOG_VERBOSE, "*** Adaptation ***");

#   int  new_pop_size;   /* Population size prior to adaptation. */
#   new_pop_size = pop->size;


#   switch (pop->scheme)
#   {
#   case (GA_SCHEME_BALDWIN_CHILDREN):
#     /* Baldwinian evolution for children only. */

#     adapt_check_by_rank (pop, pop->orig_size, new_pop_size);
#     break;

#   case (GA_SCHEME_BALDWIN_ALL):
#     /* Baldwinian evolution for entire population. */
#     /* I don't recommend this, but it is here for completeness. */

#     adapt_check_by_rank (pop, 0, new_pop_size);
#     break;

#   case (GA_SCHEME_LAMARCK_CHILDREN):
#     /* Lamarckian evolution for children only. */

#     adapt_by_rank (pop,  pop->orig_size, new_pop_size);
#     break;

#   case (GA_SCHEME_LAMARCK_ALL):
#     /* Lamarckian evolution for entire population. */

#     adapt_by_rank (pop,  0, new_pop_size);
#     break;

#   default:
#     dief ("Unknown evolutionary scheme %d. \n", pop->scheme);
#   }


#   return;
# }
# //------------------------------------------------------------------------------
# //  synopsis:	Main genetic algorithm routine.  Performs GA-based
# //		optimisation on the given population.
# //		This is a steady-state GA.
# //		ga_genesis(), or equivalent, must be called prior to
# //		this function.
# //------------------------------------------------------------------------------
# int ga_evolution_steady_state (population  *pop,
# 			       const int    max_iterations)
# {

#   int		iteration=0;		/* Current iteration count. */
#   entity	*mother, *father;	/* Parent entities. */
#   entity	*son, *daughter, *child;	/* Child entities. */
#   //int		new_pop_size;		/* Population size prior to adaptation. */

#   /* Checks. */

#   if (!pop)             die ("NULL pointer to population structure passed.");
#   if (!pop->evaluate)   die ("Population's evaluation callback is undefined.");
#   if (!pop->select_one) die ("Population's asexual selection callback is undefined.");
#   if (!pop->select_two) die ("Population's sexual selection callback is undefined.");
#   if (!pop->mutate)     die ("Population's mutation callback is undefined.");
#   if (!pop->crossover)  die ("Population's crossover callback is undefined.");
#   if (!pop->replace)    die ("Population's replacement callback is undefined.");
#   if (!pop->rank)       die ("Population's ranking callback is undefined.");

#   if (pop->scheme != GA_SCHEME_DARWIN && !pop->adapt) 
#     die ("Population's adaption callback is undefined.");

#   plog (LOG_VERBOSE, "The evolution has begun!");

#   pop->generation = 0;

#   //
#   // Score and sort the initial population members.
#   //
#   score_and_sort_initial_pop (pop);

#   plog (LOG_VERBOSE,
#         "Prior to the first iteration, population has fitness scores between %f and %f",
#         pop->entity_iarray[0]->fitness,
#         pop->entity_iarray[pop->size-1]->fitness);

#   // Do all the iterations: 

#   //while ( (pop->generation_hook?pop->generation_hook(iteration, pop):TRUE) &&
#   //       iteration < max_iterations )

#   while (1)
#   {

#     pop->generation_hook?pop->generation_hook(iteration, pop):TRUE; // печать через 

#     if (iteration >= max_iterations) break;

#     iteration++;
#     pop->orig_size = pop->size;

#     son      = NULL;
#     daughter = NULL;
#     child    = NULL;

#     plog (LOG_DEBUG,
#           "Population size is %d at start of iteration %d",
#           pop->orig_size, iteration );

#     //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#     // Mating cycle.
#     // Select pairs of entities to mate via crossover. (Sexual reproduction).
#     // Score the new entities as we go.
#     //
#     plog (LOG_VERBOSE, "*** Mating ***");

#     pop->select_state = 0;

#     pop->select_two (pop, &mother, &father);

#     if (mother && father)
#     {
#       plog (LOG_VERBOSE, "Crossover between %d (%d = %f) and %d (%d = %f)",
#             ga_get_entity_id   (pop, mother),
#             ga_get_entity_rank (pop, mother), mother->fitness,
#             ga_get_entity_id   (pop, father),
#             ga_get_entity_rank (pop, father), father->fitness);

#       son      = ga_get_free_entity (pop);
#       daughter = ga_get_free_entity (pop);
#       pop->crossover (pop, mother, father, daughter, son);

#       evaluate_ga_entity (pop, &daughter);
#       evaluate_ga_entity (pop, &son);

#     } else {

#       plog (LOG_VERBOSE, "Crossover not performed.");
#     }

#     //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#     //
#     // Mutation cycle.
#     //
#     // Select entities to undergo asexual reproduction, in which case the child will
#     // have a genetic mutation of some type.
#     // 
#     // Score the new entities as we go.
#     //

#     plog (LOG_VERBOSE, "*** Mutation ***");

#     pop->select_state = 0;

#     pop->select_one (pop, &mother);

#     if (mother)
#     {
#       plog (LOG_VERBOSE, "Mutation of %d (%d = %f)",
#             ga_get_entity_id   (pop, mother),
#             ga_get_entity_rank (pop, mother), mother->fitness );
      
#       child = ga_get_free_entity (pop);
#       pop->mutate (pop, mother, child);

#       evaluate_ga_entity (pop, &child);

#     } else {

#       plog (LOG_VERBOSE, "Mutation not performed.");
#     }

#     //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#     //
#     // Environmental adaptation.
#     //
#     // Skipped in the case of Darwinian evolution.
#     // Performed in the case of Baldwinian evolution.
#     // Performed, and genes are modified, in the case of Lamarckian evolution.
#     //
#     // Maybe, could reoptimise all solutions at each generation.  This would allow
#     // a reduced optimisation protocol and only those solutions which are
#     // reasonable would survive for further optimisation.
#     //
#     // FIXME: This is wrong for GA_SCHEME_BALDWIN, GA_SCHEME_LAMARCK and may be
#     // optimised for GA_SCHEME_BALDWIN_ALL, GA_SCHEME_LAMARCK_ALL. 
#     //

#     if (pop->scheme != GA_SCHEME_DARWIN)
#     {
#       environmental_adaptation (pop);
#     }

#     //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#     // Insert new entities into population.
#     //
#     if (son)      pop->replace (pop, son);
#     if (daughter) pop->replace (pop, daughter);
#     if (child)    pop->replace (pop, child);
  
#     //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#     // End of generation.
#     //
#     plog (LOG_VERBOSE, "*** Analysis ***");
  
#     plog (LOG_VERBOSE,
#           "After iteration %d, population has fitness scores between %f and %f",
#           iteration,
#           pop->entity_iarray[0]->fitness,
#           pop->entity_iarray[pop->size-1]->fitness);
  
#   }	/* Iteration loop. */

  
#   return (iteration<max_iterations);
# }
# //------------------------------------------------------------------------------
# //  synopsis:	Main genetic algorithm routine.  Performs GA-based
# //		optimisation on the given populations using a simple
# //		island model.  Migration occurs around a cyclic
# //		topology only.  Migration causes a duplication of the
# //		respective entities.  This is a generation-based GA.
# //		ga_genesis(), or equivalent, must be called prior to
# //		this function.
# //  parameters:	const int	num_pops
# //		population	**pops
# //		const int	max_generations
# //
# //  return:	number of generation performed
# //------------------------------------------------------------------------------
proc generation_hook_check {pop generation} \
{

  #  if (pop->generation_hook?pop->generation_hook (generation, pop):TRUE)

  set  g_hook [$pop cget -generation_hook]

  if {$g_hook == "NULL"} {return true}

  #puts "9999999999999999.................."

  set ret [$g_hook  $generation $pop] 

  return $ret
}
# //------------------------------------------------------------------------------
# int 
# ga_evolution_archipelago (int  num_pops, population **pops,
#                           int  max_generations)
# //------------------------------------------------------------------------------
proc ga_evolution_archipelago {num_pops pops max_generations} \
{

  #   int		generation = 0;   /* Current generation number.       */
  set generation 0

  #   int		current_island;	  /* Current current_island number.   */
  #   population	*pop = NULL;	  /* Current population.              */

  #   boolean	complete = FALSE;	  /* Whether evolution is terminated. */
  set complete FALSE
  
  #   /* Checks. */
  
  #   if (! pops)
  #     die ("NULL pointer to array of population structures passed.");
  #   if (num_pops < 2)
  #     die ("Need at least two populations for the island model.");
  
  for {set current_island 0} {$current_island < $num_pops} {incr current_island} \
  {
    #     pop = pops[current_island];
    set pop [lindex $pops $current_island]
    
    #     if (!pop->evaluate)   die ("Population's evaluation callback is undefined.");
    #     if (!pop->select_one) die ("Population's asexual selection callback is undefined.");
    #     if (!pop->select_two) die ("Population's sexual selection callback is undefined.");
    #     if (!pop->mutate)     die ("Population's mutation callback is undefined.");
    #     if (!pop->crossover)  die ("Population's crossover callback is undefined.");
    #     if (!pop->rank)       die ("Population's ranking callback is undefined.");
    
    #     if (pop->scheme != GA_SCHEME_DARWIN && !pop->adapt) {
    #       die ("Population's adaption callback is undefined.");
    #     }
    
    #     /* Set current_island property. */
    #     pop->island = current_island;
    $pop configure -island $current_island
  }
  
  #   plog (LOG_VERBOSE, "The evolution has begun on %d islands!", num_pops);
  
  #// ?? к какой именно популяции ??
  #   pop->generation = 0;
  
  for {set current_island 0} {$current_island < $num_pops} {incr current_island} \
  {
    #     pop = pops[current_island];
    set pop [lindex $pops $current_island]
    
    #     //
    #     // Score and sort the initial population members.
    #     //
    score_and_sort_initial_pop $pop
    
    #     plog (LOG_VERBOSE, "Prior to the first generation, population on \
    #                        current_island %d has fitness scores between %f and %f",
    #           current_island,
    #           pop->entity_iarray[0]->fitness,
    #           pop->entity_iarray[pop->size-1]->fitness );
  }
  
  #   /* Do all the generations: ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
  
  while {1} {

    if {$generation >= $max_generations} {break}
    if {$complete   != FALSE}            {break}

    incr generation

    if {$::is_print} {
      puts ""
      puts "GENERATION LOOP ......... generation = $generation"
      puts ""
    } 

    #  pop->generation = generation;   $pop configure -generation $generation
    
    # // Migration step.
    # //
    gaul_migration  $num_pops $pops
    
    
    for {set current_island 0} {$current_island < $num_pops} {incr current_island} \
    {
      if {$::is_print} {
        puts ""
        puts "CURRENT ISLAND = $current_island"
        puts ""
      } 

      #   pop = pops[current_island];
      set pop [lindex $pops $current_island]
      
      #  plog (LOG_VERBOSE, "*** Evolution on current_island %d ***", current_island);
      
      if {[generation_hook_check $pop $generation]} {
      
        $pop configure -orig_size [$pop cget -size]
        
        #         plog (LOG_DEBUG,
        #               "Population %d size is %d at start of generation %d",
        #               current_island, pop->orig_size, generation );
        
        # //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        crossover_mutation_adapt_survival  $pop
        
        # //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        
      } else {
        
        set complete TRUE
      }
    }
    
    #     plog (LOG_VERBOSE,
    #           "After generation %d, population %d has fitness scores between %f and %f",
    #           generation,
    #           current_island,
    #           pop->entity_iarray[0]->fitness,
    #           pop->entity_iarray[pop->size-1]->fitness );
  
  } 
  
  return $generation
}
# //******************************************************************************
#   //
# //------------------------------------------------------------------------------


