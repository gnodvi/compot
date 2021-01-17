# -*-   mode: tcl  ; coding: koi8   -*- ----------------------------------------

# ------------------------------------------------------------------------------

#   ga_tabu.c
#   ga_tabu - A tabu-search algorithm for comparison and local search.

#   Synopsis:     A tabu-search algorithm for comparison and local search.

#   		A novel population-based tabu-search is also provided.
# 		(Or at least it will be!)


#-------------------------------------------------------------------------------
# 
# Tabu-search parameter structure.
# 

# dictrecord define GA_TABU_T \
# {
#   list_length  ;# int	 /* Length of the tabu-list. */
#   search_count ;# int	 /* Number of local searches initiated at each iteration. */
#   tabu_accept  ;# GAtabu_accept /* Acceptance function. */
# }

# //------------------------------------------------------------------------------
# //  synopsis:   Compares two solutions with integer chromosomes and
# //	   	returns TRUE if, and only if, they are exactly
# //		identical.
# //------------------------------------------------------------------------------
# boolean 
# ga_tabu_check_integer (population *pop,
#                        entity	  *putative,
#                        entity	  *tabu)
# //------------------------------------------------------------------------------
# proc ga_tabu_check_integer {pop putative tabu} {


#   set a [ent_get_chromosome_ $putative]
#   set b [ent_get_chromosome_ $tabu]

#   set len  [GET $pop len_chromosomes]
  
#   for {set j 0} {$j < $len} {incr j} {

#     set a_gen [lindex $a $j]
#     set b_gen [lindex $b $j]

#     if {$a_gen != $b_gen}  {return "FALSE"}
#   }

#   return "TRUE"
# }
# //------------------------------------------------------------------------------
# //  synopsis:   Checks the tabu list verses the putative solutions and
# //		chooses an acceptable solution.  Returns -1 if all
# //		putative solutions are tabu.
# //------------------------------------------------------------------------------
# int 
# gaul_check_tabu_list (population  *pop,
#                       entity	  **putative,
#                       entity	  **tabu)
# //------------------------------------------------------------------------------
proc  gaul_check_tabu_list {pop &putative tabu} {

  #set tabu_params [$pop.tabu_params]
  set tabu_params [GET $pop algo_params]


  USE_REFS

  #   int	    i;		/* Loop variable over putative solutions. */
  #   int	    j;		/* Loop variable over tabu list.          */
  #   boolean   is_tabu;	/* Whether current solution is tabu.      */
  
  for {set i 0} {$i < [GET $tabu_params search_count]} {incr i} \
  {
    set is_tabu "FALSE"
    
    for {set j 0} {1} {incr j} \
    {
      set t [lindex $tabu $j]
      
      #puts "gaul_check_tabu_list: t = $t"
        
      if {$j >= [GET $tabu_params list_length]} {break}
      if {$t       ==  "NULL"} {break}
      if {$is_tabu != "FALSE"} {break}
      
      set is_tabu [[GET $tabu_params tabu_accept] $pop $putative($i) $t]
    }
    
    if {$is_tabu == "FALSE"} {
      #  /* This solution is not tabu. */
      return $i
    }
  }
  
  #   // All solutions are tabu.
  #   // 

  return -1  
}
# //------------------------------------------------------------------------------
# //  synopsis:     Sets the tabu-search parameters for a population.
# //------------------------------------------------------------------------------
# void 
# ga_population_set_tabu_parameters (population    *pop,
#                                    GAtabu_accept  tabu_accept,
#                                    const int      list_length,
#                                    const int      search_count)
# //------------------------------------------------------------------------------
proc ga_population_set_tabu_parameters {pop
                                        tabu_accept
                                        list_length
                                        search_count} \
{
  if {$::is_print} {
    puts "> "
    puts [format "> Population's tabu-search parameters: list_length = %d search_count = %d " \
            $list_length $search_count]
  }
  

  set tabu_params [dict_create]

  #set tabu_params [GA_TABU_T \#auto]

  #--------------------------------------------------

  SET $tabu_params tabu_accept   $tabu_accept
  SET $tabu_params list_length   $list_length
  SET $tabu_params search_count  $search_count

  #--------------------------------------------------

  SET $pop algo_params   $tabu_params

}
# //------------------------------------------------------------------------------
# void update_tabu_list (population *pop,
#                        entity	**tabu_list,    
#                        entity    *best, 
#                        int    *p_tabu_list_pos 
#                        )
# //------------------------------------------------------------------------------
proc update_tabu_list {pop  &tabu_list best &p_tabu_list_pos} {

  #set tabu_params [$pop.tabu_params]
  set tabu_params [GET $pop algo_params]

  USE_REFS

  set tabu_list_pos  $p_tabu_list_pos
  
  set t [lindex $tabu_list $tabu_list_pos] ;# это вообще-то "entity"

  #puts ""
  #puts "update_tabu_list:  tabu_list= $tabu_list"
  #puts "update_tabu_list:  tabu_list_pos= $tabu_list_pos t= $t"
  #puts ""

  if {$t == "NULL"} \
  {
    lset tabu_list $tabu_list_pos [ga_entity_clone  $pop $best]
  } else {
    ga_entity_blank  $pop $t

    ga_entity_copy   $pop  $t $best
  }

  incr tabu_list_pos
  
  if { $tabu_list_pos >= [GET $tabu_params list_length] } {
    set tabu_list_pos  0
  } 
  
  set p_tabu_list_pos $tabu_list_pos
  
  #   return;
}
# //------------------------------------------------------------------------------
# entity *
# swap_putative_to_index (entity   *best,
#                     entity  **putative, int index
# //------------------------------------------------------------------------------
proc swap_putative_to_index {best &putative index} {

  USE_REFS
  #   entity   *tmp; 
  
  set tmp $best

  #   best = putative[index];
  set best $putative($index)

  #   putative[index] = tmp;
  set putative($index) $tmp
  
  return $best
}
# //------------------------------------------------------------------------------
# //  synopsis:	Performs optimisation on the passed entity by using a
# //  		simplistic tabu-search.  The local search and fitness
# //	       	evaluations are performed using the standard mutation
# //	       	and evaluation callback mechanisms, respectively.
# //		The passed entity will have its data overwritten.  The
# //		remainder of the population will be let untouched.
# //		Note that it is safe to pass a NULL initial structure,
# //		in which case a random starting structure wil be
# //		generated, however the final solution will not be
# //		available to the caller in any obvious way.
# //------------------------------------------------------------------------------
# int 
# ga_tabu (population	*pop,
#          entity		*initial,
#          const int	 max_iterations )
## //------------------------------------------------------------------------------
proc ga_tabu {task pop initial max_iterations} {


  set tabu_params [GET $pop algo_params]

  set iteration 0 ;# 	/* Current iteration number. 

  #   int	i, j;			/* Index into putative solution array. */
  #   entity	*best;			/* Current best solution.              */
  #   entity	**putative;		/* Current working solutions.          */
  #   //entity	*tmp;			/* Used to swap working solutions.     */
  #   entity	**tabu_list;		/* Tabu list.                          */

  #   int	tabu_list_pos = 0;	/* Index into the tabu list.           */
  set tabu_list_pos 0
  
  if {$::is_print} {
      puts "> "
      puts "> ga_tabu ..................................................... "
      #puts "> max_iterations = $max_iterations"
      puts "> "
  }
  
  
  #   // Prepare working entities. 
  
  #set best [ga_get_free_entity $pop] ;#   // The best solution so far.
  set best [get_free_and_init $pop $task] ;#   // The best solution so far.
  
  set search_count [GET $tabu_params search_count]
  set list_length  [GET $tabu_params list_length]

  #   if (! (putative = s_malloc (sizeof(entity *) * pop->tabu_params->search_count)))
  #     die ("Unable to allocate memory");
  
  for {set i 0} {$i < $search_count} {incr i} \
  {
    #set putative($i) [ga_get_free_entity $pop] ;#    // The 'working' solutions.
    set putative($i) [get_free_and_init $pop $task] ;#    // The 'working' solutions.
  }
  
  #   // Allocate and clear an array for the tabu list.
  #   if (! (tabu_list = s_malloc (sizeof(vpointer) * pop->tabu_params->list_length)))
  #     die ("Unable to allocate memory");
  
  for {set i 0} {$i < $list_length} {incr i} \
  {
    # tabu_list[i] = NULL;
    #lappend  tabu_list  $i "NULL" ;# !!!????  tabu_list= 0 NULL 1 NULL 2 NULL 3 NULL
    lappend  tabu_list "NULL"
  }
  
  #   // Do we need to generate a random starting solution?
  #   if (! initial)
  if {$initial == "NULL"} \
  {
    if {$::is_print} {
      puts "> Will perform tabu-search with random starting solution."
    }
    
    #set initial [ga_get_free_entity $pop]
    set initial [get_free_and_init $pop $task]
    #ga_entity_seed  $pop $best

  } else {   
    if {$::s_print} { 
      puts "> Will perform tabu-search with specified starting solution."
    }
  
    ga_entity_copy $pop $best $initial
  }
  
  set eval_proc [GET $task "fit_func"]
  #-------------------------------------------------

  #   //
  #   // Ensure that initial solution is scored.
  #   //
  if {[string equal [item_get_fitn $best]  $::GA_NOT_FIT]} {
    #pop->evaluate (pop, best);
    #puts "!!!!!!!!!!!!!!!!!!!!!!!!"
    #$eval_proc $pop $best
    pop_eval_item $pop $best $eval_proc $task
  }
  
  if {$::is_print} { 
    puts "> "
    puts [format \
            "> Prior to the first iteration, the current solution has fitness score of %f " \
            [item_get_fitn $best]]

    pop_print $pop
  }
  
  #   //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #   //
  #   // Do all the iterations:
  #   //
  #   // Stop when (a) max_iterations reached, or
  #   //           (b) "pop->iteration_hook" returns FALSE.
  #   //
  #   //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  
  while (1) {
  
    if {$::is_print} {
      puts "> "
      puts [format "> ITERATION LOOP ......... iteration = %d (%d)" \
              $iteration $max_iterations]

    } else {
      
      # //  pop->generation_hook?pop->generation_hook(generation, pop):TRUE; // печать через 10
      # pop->iteration_hook?pop->iteration_hook (iteration, best):TRUE ;
    }
  
    if {$iteration >= $max_iterations} {break}
    
    # iteration++;
    incr iteration
    
    #     // 
    #     // Generate and score new solutions.
    #     //
    for {set i 0} {$i < $search_count} {incr i} {

      [GET $pop mutate]   $pop $best $putative($i)

      #set eval_proc [GET $pop evaluate]
      #$eval_proc  $pop  $putative($i)
      pop_eval_item $pop  $putative($i) $eval_proc $task
    }
    
#     if {$::is_print} { 
#       puts ""
#       puts "After MUTATE and EVALUATE: "
#       puts ""
      
#       pop_print $pop
#     }
    
    #     //
    #     // Sort new solutions (putative[0] will have highest rank).
    #     // We assume that there are only a small(ish) number of
    #     // solutions and, therefore, a simple bubble sort is adequate.
    #     //

    set rank_proc [GET $pop rank]

    for {set i 1} {$i < $search_count} {incr i} \
    {
      for {set j [expr {$search_count - 1}]} {$j >= $i} {incr j -1} \
        {
          #puts "i = $i  j = $j"
          #         if (pop->rank (pop, putative[j], pop, putative[j-1]) > 0 )
          if {[$rank_proc  $pop $putative($j) $pop $putative([expr {$j - 1}])] > 0 } \
          {	
            #           // Perform a swap.
            #           putative[j] = swap_putative_to_index (putative[j], putative, j-1);
            set putative($j) [swap_putative_to_index  $putative($j) putative [expr {$j - 1}] ]
          }
        }
    }
    
#     if {$::is_print} { 
#       puts ""
#       puts "POP_PRINT 11111111111 : "
#       puts ""
      
#       pop_print $pop
#     }

    #     //
    #     // Save best solution if it is an improvement, otherwise
    #     // select the best non-tabu solution (if any).
    #     // If appropriate, update the tabu list.
    #     //

    #     if (pop->rank (pop, putative[0], pop, best) > 0 )
    if {[$rank_proc  $pop $putative(0) $pop $best] > 0 } \
    {
      # best = swap_putative_to_index (best, putative, 0);
      set best [swap_putative_to_index  $best putative 0]

      # update_tabu_list (pop, tabu_list, best, &tabu_list_pos);
      update_tabu_list  $pop tabu_list $best tabu_list_pos

    } else {

      #set ::is_print 1
      #       if (-1 < (j = gaul_check_tabu_list (pop, putative, tabu_list)))
      if {-1 < [set j [gaul_check_tabu_list  $pop putative $tabu_list]] } \
      {
        #  best = swap_putative_to_index (best, putative, j);
        set best [swap_putative_to_index  $best putative $j]

        #  update_tabu_list (pop, tabu_list, best, &tabu_list_pos);
        update_tabu_list  $pop tabu_list $best tabu_list_pos

        #puts "111111111111111111111111111111111111111 j = $j"
        #puts "best = $best"
        #puts "tabu_list = $tabu_list"
      }
    }
    
    if {$::is_print} { 
      puts ""
      puts "POP_PRINT 22222222222 : "
      puts ""
      
      pop_print $pop
    }

    #     // Save the current best solution in the initial entity, if this
    #     // is now the best found so far.
    #     //

    #     if (pop->rank (pop, best, pop, initial) > 0)
    if {[$rank_proc  $pop $best  $pop $initial] > 0 } \
    {
      ga_entity_blank  $pop $initial
      ga_entity_copy   $pop $initial $best
    }
    
    if {$::is_print} { 
      puts ""
      puts "POP_PRINT 3333333333 : "
      puts ""
      
      pop_print $pop
    }


    #     // Use the iteration callback.
    #     //
    if {$::is_print} { 
      puts [format "> After iteration %d, the current solution has fitness score of %f" \
              $iteration [item_get_fitn $best]]
    }
    
    
  } ;#  // Iteration loop. 
  #   //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  
  
  if {$::is_print} { 
    puts ""
    puts "BEFORE CLEANUP: "
    puts ""

    pop_print $pop
  }
  #   //
  #   // Cleanup.
  #   //
  
  pop_del_entity  $pop $best
  
  for {set i 0} {$i < $search_count} {incr i} \
  {
    pop_del_entity $pop $putative($i)
  }
  
  if {$::is_print} { 
    puts ""
    puts "AFTER  CLEANUP part1: "
    puts ""

    pop_print $pop
  }

  if {1} {
  for {set i 0} {$i < $list_length} {incr i} \
  {
    #puts -nonewline [format "tabu_list: i= %2d  " $i ]

    set t [lindex $tabu_list $i]

    if {$t != "NULL"} {

      #ent_print_ch_ $t 

      pop_del_entity $pop $t

  } else {
    #puts -nonewline "t= NULL "
  }
    #puts ""

  }
  }

  if {$::is_print} { 
    puts ""
    puts "AFTER  CLEANUP part2: "
    puts ""

    pop_print $pop
  }

  #   s_free (putative);
  #   s_free (tabu_list);
  
  #   return iteration;
}
# //******************************************************************************
# //
# //------------------------------------------------------------------------------
  
  
