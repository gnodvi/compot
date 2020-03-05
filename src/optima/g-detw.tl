# -*-   mode: tcl  ; coding: koi8   -*- ----------------------------------------

# //------------------------------------------------------------------------------
#   ga_deterministiccrowding.c

#   ga_deterministiccrowding - Deterministic crowding.

#   synopsis:     Sets the deterministic crowding parameters for a
# 		population.
#   parameters:	population *pop		Population to set parameters of.
# 		const GAcompare		Callback to compare two entities.
#   return:	none
# //------------------------------------------------------------------------------
proc ga_population_set_deterministiccrowding_parameters {pop compare} \
{

  SET $pop dc_params_compare  $compare

  return
}
# //------------------------------------------------------------------------------

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

# //------------------------------------------------------------------------------
proc swap_i_rank {pop i rank} \
{
  
  set this_entity [pop_get_entity_ $pop  $i]
  
  pop_set_entity_ $pop   $i [pop_get_entity_ $pop  $rank] 
  
  pop_set_entity_ $pop   $rank $this_entity

  return
}
# //------------------------------------------------------------------------------
proc swap_one_child {pop i parent child ind} \
{

  set rank [pop_get_entity_id  $pop $child]
  
  if {[item_get_fitn $child] < [item_get_fitn $parent]} \
  {
    swap_i_rank  $pop $ind $rank
  }
  
  pop_del_entity_by_id $pop $rank
  
  return
}
# //------------------------------------------------------------------------------
proc main_swap_childs {pop i father mother son daughter permutation} \
{

  swap_one_child  $pop $i $mother $daughter $i

  swap_one_child  $pop $i $father $son     [lindex $permutation $i]

  return
}
# //------------------------------------------------------------------------------
proc mutation_step {pop child} \
{

  if {[random_boolean_prob [GET $pop mutation_ratio]]} \
  {
    
    set this_entity [ga_get_free_entity $pop]
    [GET $pop mutate]  $pop $child $this_entity
    
    pop_del_entity  $pop $child
    set child $this_entity
  }
  
  return $child
}
# //------------------------------------------------------------------------------
proc ga_deterministiccrowding {task pop max_generations} \
{

  set generation 0

  set eval_proc      [GET $task "fitness_proc"]
  set mutate_proc    [GET $pop  "mutate"]
  set crossover_proc [GET $pop  "crossover"]

  set compare_proc   [GET $pop  "dc_params_compare"]

  if {$eval_proc      == "NULL"}  {die "Population's evaluation callback is undefined."}
  if {$mutate_proc    == "NULL"}  {die "Population's mutation callback is undefined."}
  if {$crossover_proc == "NULL"}  {die "Population's crossover callback is undefined."}  
  if {$compare_proc   == "NULL"}  {die "Population's comparison callback is undefined."}
  

  SET $pop "generation" 0
  
  pop_initial_score_and_sort $pop $task
  
  set size [get_pop_size $pop]

  for {set i 0} {$i < $size} {incr i} {
    lappend  ordered $i
  }
  
  set fit_target [GET $task "fit_target"]
  set fit_error  [GET $task "fit_error"]

  # ---------------------------------------------------------------------
  # 
  while {1} \
  {
  
    set generation [GET $pop "generation"]
    
    sort_population  $pop
    
    # --------------------------------------------------

    if {0} {
      puts "generation= $generation, max_generations= $max_generations, fit_target= $fit_target, fit_error= $fit_error"
    }

    if [is_check_generation_break  $pop $generation $max_generations \
          $fit_target $fit_error \
          1] {
      
      return false
    }
  
    # --------------------------------------------------

    
    if {$::is_print} {
      puts "ordered     = $ordered"
    }
    
    set permutation {}
    random_int_permutation  $size  ordered  permutation 
    #
    # сделаем как в оригинале пока, т.е. с изменением исходного ordered, но
    # это довольно странно !
    
    if {$::is_print} {
      puts "permutation = $permutation"
    }

    for {set i 0} {$i < $size} {incr i} \
    {
      set perm_i [lindex $permutation $i]
      
      set mother   [pop_get_entity_    $pop       $i];
      set father   [pop_get_entity_    $pop  $perm_i];
    
      set son      [ga_get_free_entity $pop]
      set daughter [ga_get_free_entity $pop]

      $crossover_proc  $pop $mother $father $daughter $son
      
      #  // Mutation step.
      #  //
      
      set daughter [mutation_step  $pop $daughter]
      set son      [mutation_step  $pop $son]
      
      #  // Apply environmental adaptations, score entities, sort entities, etc.
      #  // FIXME: Currently no adaptation.
      #  //
      pop_eval_item  $pop $daughter $eval_proc $task
      pop_eval_item  $pop $son      $eval_proc $task
      
      #  // Evaluate similarities.
      #  //
      set md [$compare_proc  $pop $mother $daughter]
      set fs [$compare_proc  $pop $father $son]

      set dist1 [expr {$md + $fs}]
      
      set ms [$compare_proc  $pop $mother $son]
      set fd [$compare_proc  $pop $father $daughter]

      set dist2 [expr {$ms + $fd}]
      

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
      
    } ;# for {set i 0} {$i < $size} {incr i}

    # --------------------------------------------------
    
    incr generation
    SET $pop generation  $generation
    
  } ;# while
  # 
  # ---------------------------------------------------------------------
  
  #   // Ensure final ordering of population is correct.
  #   //
  sort_population  $pop
  
  
  return $generation
}
# //******************************************************************************
# //------------------------------------------------------------------------------


