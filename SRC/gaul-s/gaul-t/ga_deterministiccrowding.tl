# //------------------------------------------------------------------------------
# /**********************************************************************
#   ga_deterministiccrowding.c
#  **********************************************************************

#   ga_deterministiccrowding - Deterministic crowding.
#   Copyright б╘2003-2006, Stewart Adcock <stewart@linux-domain.com>
#   All rights reserved.

#   Synopsis:     Deterministic crowding.

#  **********************************************************************/

# //#include "ga_deterministiccrowding.h"
# #include "gaul.h"

# //------------------------------------------------------------------------------
# /**********************************************************************
#   synopsis:     Sets the deterministic crowding parameters for a
# 		population.
#   parameters:	population *pop		Population to set parameters of.
# 		const GAcompare		Callback to compare two entities.
#   return:	none
#  **********************************************************************/
# //------------------------------------------------------------------------------
# void 
# ga_population_set_deterministiccrowding_parameters (population *pop,
#                                                     const GAcompare compare)
# //------------------------------------------------------------------------------
proc ga_population_set_deterministiccrowding_parameters {pop compare} \
{

  #   if (! pop)     die ("Null pointer to population structure passed.");
  #   if (! compare) die ("Null pointer to GAcompare callback passed."  );
  
  #   plog (LOG_VERBOSE, "Population's deterministic crowding parameters set");
  
  #   if (pop->dc_params == NULL)
  #   {
  #     if ( !(pop->dc_params = s_malloc(sizeof(ga_dc_t))) )
  #       die ("Unable to allocate memory");
  #   }
  
  #   pop->dc_params->compare = compare;
  $pop configure -dc_params_compare  $compare

  return
}
# //------------------------------------------------------------------------------
# /**********************************************************************
#   synopsis:	Performs optimisation of the given population by a
# 		method known as determinstic crowding.
# 		ga_genesis(), or equivalent, must be called prior to
# 		this function.
# 		This approach is useful when you desire a
# 		significant amount of diversity in the resulting
# 		population.
# 		This was designed as a niching algorithm rather than
# 		an optimisation algorithm.

# 		During a generation, children potentially replace
# 		their parents as soon as they are created, rather
# 		than replacing them at the end of the generation.
# 		This differs slightly from the canonical
# 		deterministic crowding algorithm.
#  **********************************************************************/
# //------------------------------------------------------------------------------
# void 
# swap_i_rank (population *pop, int i, int rank)
# //------------------------------------------------------------------------------
proc swap_i_rank {pop i rank} \
{
  
  #   entity  *this_entity;	
  
  #   this_entity = pop->entity_iarray[i];
  #set this_entity [$pop get_entity $i]
  set this_entity [pop_get_entity_ $pop  $i]
  
  #   pop->entity_iarray[i]    = pop->entity_iarray[rank];
  #$pop set_entity  $i [$pop get_entity $rank] 
  #$pop set_entity  $i [pop_get_entity_ $pop  $rank] 
  pop_set_entity_ $pop   $i [pop_get_entity_ $pop  $rank] 
  
  #   pop->entity_iarray[rank] = this_entity;
  #$pop set_entity  $rank $this_entity
  pop_set_entity_ $pop   $rank $this_entity

  return
}
# //------------------------------------------------------------------------------
# void 
# swap_one_child (population *pop, int i,  
#                  entity *parent, entity *child, int ind)
# //------------------------------------------------------------------------------
proc swap_one_child {pop i parent child ind} \
{

  #   int  rank;  /* Rank of entity in population. */
  
  set rank [ga_get_entity_rank  $pop $child]
  
  if {[$child cget -fitness] < [$parent cget -fitness]} \
  {
    swap_i_rank  $pop $ind $rank
  }
  
  ga_entity_dereference_by_rank  $pop $rank
  
  return
}
# //------------------------------------------------------------------------------
# void 
# main_swap_childs (population *pop, int i, 
#                   entity *father, entity *mother, entity *son, entity *daughter,
#                   int    *permutation)
# //------------------------------------------------------------------------------
proc main_swap_childs {pop i father mother son daughter permutation} \
{

  swap_one_child  $pop $i $mother $daughter $i

  swap_one_child  $pop $i $father $son     [lindex $permutation $i]

  return
}
# //------------------------------------------------------------------------------
# entity  *
# mutation_step (population *pop, entity *child)
# //------------------------------------------------------------------------------
proc mutation_step {pop child} \
{

  #   entity  *this_entity;	
  
  if {[random_boolean_prob [$pop cget -mutation_ratio]]} \
  {
    #     plog (LOG_VERBOSE, "Mutation of %d (rank %d)",
    #           ga_get_entity_id   (pop, child),
    #           ga_get_entity_rank (pop, child));
    
    set this_entity [ga_get_free_entity $pop]
    [$pop cget -mutate]  $pop $child $this_entity
    
    ga_entity_dereference  $pop $child
    set child $this_entity
  }
  
  return $child
}
# //------------------------------------------------------------------------------
# int 
# generation_hook_check (population *pop, int generation)
# {

#   return (pop->generation_hook?pop->generation_hook (generation, pop):TRUE);

# }
# //------------------------------------------------------------------------------
# int 
# ga_deterministiccrowding (population *pop, 
#                           int max_generations)
# //------------------------------------------------------------------------------
proc ga_deterministiccrowding {pop max_generations} \
{

  #   int		generation = 0;		/* Current generation number. */
  set generation 0

  #   int		*permutation, *ordered;	/* Arrays of entities. */
  #   entity	*mother, *father;	/* Current entities. */
  #   entity	*son,    *daughter;	/* Current entities. */
  #   int		i;			/* Loop variable over entities. */
  #   double	dist1, dist2;		/* Genetic or phenomic distances. */
  #   //int		rank;			/* Rank of entity in population. */
  
  #   /* Checks. */
  
  #   if (! pop)
  #     die ("NULL pointer to population structure passed.");
  #   if (! pop->dc_params)
  #     die ("ga_population_set_deterministiccrowding_params(), or similar, must be used prior to ga_deterministiccrowding().");
  
  set evaluate_proc  [$pop cget -evaluate]
  set mutate_proc    [$pop cget -mutate]
  set crossover_proc [$pop cget -crossover]

  set compare_proc   [$pop cget -dc_params_compare]

  if {$evaluate_proc  == "NULL"}  {die "Population's evaluation callback is undefined."}
  if {$mutate_proc    == "NULL"}  {die "Population's mutation callback is undefined."}
  if {$crossover_proc == "NULL"}  {die "Population's crossover callback is undefined."}
  
  if {$compare_proc   == "NULL"}  {die "Population's comparison callback is undefined."}
  
  #   plog (LOG_VERBOSE, "The evolution by deterministic crowding has begun!");
  
  #   pop->generation = 0;
  $pop configure -generation 0
  
  #   //
  #   // Score the initial population members.
  #   //
  #   if (pop->size < pop->stable_size)
  #     gaul_population_fill (pop, pop->stable_size - pop->size);
  
  #   for (i = 0; i < pop->size; i++)
  #   {
  #     if (pop->entity_iarray[i]->fitness == GA_MIN_FITNESS)
  #       pop->evaluate (pop, pop->entity_iarray[i]);
  #   }
  
  #   sort_population (pop);
  #   ga_genocide_by_fitness (pop, GA_MIN_FITNESS);
  
  score_and_sort_initial_pop $pop
  

  #   //
  #   // Prepare arrays to store permutations.
  #   //
  #   if (! (permutation = s_malloc (sizeof(int)*pop->size)) )
  #     die ("Unable to allocate memory");
  #set permutation {}

  #   if (! (ordered = s_malloc (sizeof(int)*pop->size)) )
  #     die ("Unable to allocate memory");
  
  #   for (i = 0; i < pop->size;i++) {
  #     ordered[i] = i;
  #   }

  set size [$pop cget -size]

  for {set i 0} {$i < $size} {incr i} {
    lappend  ordered $i
  }
  

  #   plog (LOG_VERBOSE,
  #        "Prior to the first generation, population has fitness scores between %f and %f",
  #        pop->entity_iarray[0]->fitness,
  #        pop->entity_iarray[pop->size-1]->fitness );
  
  #   //
  #   // Do all the generations:
  #   //
  #   // Stop when (a) max_generations reached, or
  #   //           (b) "pop->generation_hook" returns FALSE.
  #   //
  
  while {[generation_hook_check  $pop $generation]} \
  {
  
    #     if (generation >= max_generations) break;
    if {$generation >= $max_generations} {break}
    
    #     generation++;
    incr generation

    $pop configure -generation  $generation
    $pop configure -orig_size $size ;# = pop->size;
    
    #     plog (LOG_DEBUG,
    #          "Population size is %d at start of generation %d",
    #          pop->orig_size, generation );
    
    sort_population  $pop
    
    #     random_int_permutation (pop->orig_size, ordered, permutation);
    #
    if {$::is_print} {
      puts "ordered     = $ordered"
    }
    #
    set permutation {}
    #random_int_permutation  $size $ordered  permutation ;# перемешали числа
    random_int_permutation  $size  ordered  permutation 
    #
    # сделаем как в оригинале пока, т.е. с изменением исходного ordered, но
    # это довольно странно !
    
    if {$::is_print} {
      puts "permutation = $permutation"
    }

    #     // FOR ........................................ BEG
    #     // 
    #for (i = 0; i < pop->orig_size; i++ )

    for {set i 0} {$i < $size} {incr i} \
    {
      set perm_i [lindex $permutation $i]
      
#       set mother [$pop get_entity      $i];
#       set father [$pop get_entity $perm_i];
      set mother [pop_get_entity_ $pop       $i];
      set father [pop_get_entity_ $pop  $perm_i];
    
      #$mother  print_ch "mother= "
      #puts ""
      #$father  print_ch "father= "
      #puts ""

      #  //
      #  // Crossover step.
      #  //
      #  plog (LOG_VERBOSE, "Crossover between %d (rank %d fitness %f) and %d (rank %d fitness %f)",
      #      ga_get_entity_id   (pop, mother),
      #      ga_get_entity_rank (pop, mother), mother->fitness,
      #      ga_get_entity_id   (pop, father),
      #      ga_get_entity_rank (pop, father), father->fitness);
      
      set son      [ga_get_free_entity  $pop]
      set daughter [ga_get_free_entity  $pop]

      $crossover_proc  $pop $mother $father $daughter $son
      
      #  //
      #  // Mutation step.
      #  //
      
      set daughter [mutation_step  $pop $daughter]
      set son      [mutation_step  $pop $son]
      
      #  //
      #  // Apply environmental adaptations, score entities, sort entities, etc.
      #  // FIXME: Currently no adaptation.
      #  //
      $evaluate_proc  $pop $daughter
      $evaluate_proc  $pop $son
      
      #  //
      #  // Evaluate similarities.
      #  //
      set md [$compare_proc  $pop $mother $daughter]
      set fs [$compare_proc  $pop $father $son]

      set dist1 [expr $md + $fs]
      
      set ms [$compare_proc  $pop $mother $son]
      set fd [$compare_proc  $pop $father $daughter]

      set dist2 [expr $ms + $fd]
      

      if {$::is_print} {
        puts [format "i= $i  dist1= %7.2f  dist2= %7.2f" $dist1 $dist2]
      }

      #  //
      #  // Determine which entities will survive, and kill the others.
      #  //
      if {$dist1 < $dist2} \
      {
        main_swap_childs  $pop $i $father $mother $son $daughter $permutation
      } else {
        main_swap_childs  $pop $i $father $mother $daughter $son $permutation
      }
      
    } 
    # // FOR ........................................ END
    
    #if {$::is_print} {
    #  $pop print
    #}

    #     //
    #     // Use callback.
    #     //
    #     plog (LOG_VERBOSE,
    #          "After generation %d, population has fitness scores between %f and %f",
    #          generation,
    #          pop->entity_iarray[0]->fitness,
    #          pop->entity_iarray[pop->size-1]->fitness );
    
    if {$::is_print} {
      puts ""
    }

  }  ;# // Generation loop. 
  
  #   //
  #   // Ensure final ordering of population is correct.
  #   //
  sort_population  $pop
  
  #   //
  #   // Clean-up.
  #   //
  
  #   s_free (permutation);
  #   s_free (ordered);
  
  return $generation
}
# //******************************************************************************
# //------------------------------------------------------------------------------


