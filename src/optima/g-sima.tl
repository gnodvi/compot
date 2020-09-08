# -*-   mode: tcl  ; coding: koi8   -*- ----------------------------------------

# ------------------------------------------------------------------------------
# ga_sa.c

# ga_sa - A simulated annealling algorithm for comparison and search.

# Synopsis:     A simulated annealling algorithm for comparison and search.

#-------------------------------------------------------------------------------
# 
# Simulated Annealling search parameter structure.
#  

# dictrecord define GA_SA_T {

#   initial_temp ;#   double         : Initial temperature; 
#   final_temp   ;#   double         : Final temperature; 
#   temp_step    ;#   double         : Increment of temperature updates;
#   temp_freq    ;#   int	temp_freq  : Frequency for temperature updates;
#   #                                * (Or, -1 for smooth transition between Ti and Tf)
#   temperature  ;#   double	   : Current temperature;
#   sa_accept    ;#   GAsa_accept sa_accept : Acceptance criterion function;
# }

# //------------------------------------------------------------------------------
# //  synopsis:     Simulated annealling acceptance criterion.
# //------------------------------------------------------------------------------
# boolean 
# ga_sa_boltzmann_acceptance (population	*pop,
# 			    entity	*original,
# 			    entity	*putative)
# //------------------------------------------------------------------------------
proc ga_sa_boltzmann_acceptance {pop original putative} {

  set SA [GET $pop sa_params]


  set ofit [item_get_fitn $original]
  set pfit [item_get_fitn $putative]

  set d [expr {$::GA_BOLTZMANN_FACTOR * [GET $SA temperature]}]

  if {$ofit < $pfit} {return true}

  set rand_prob [random_boolean_prob [expr {exp (($pfit - $ofit) / $d ) }]]

  return $rand_prob

  #   return ( original->fitness < putative->fitness ||
  #           random_boolean_prob (exp((putative->fitness - original->fitness)
  #                                   /(GA_BOLTZMANN_FACTOR*pop->sa_params->temperature))) );

}
# //------------------------------------------------------------------------------
# //  synopsis:     Sets the simulated annealling parameters for a
# //	    	  population.
# //------------------------------------------------------------------------------
# void 
# ga_population_set_sa_parameters (population             *pop,
#                                  GAsa_accept             sa_accept,
#                                  const double            initial_temp,
#                                  const double            final_temp,
#                                  const double            temp_step,
#                                  const int               temp_freq )
# //------------------------------------------------------------------------------
proc ga_population_set_sa_parameters { pop          
                                      sa_accept     
                                      initial_temp  
                                      final_temp    
                                      temp_step     
                                      temp_freq}    \
{

  set SA [dict_create]

  #----------------------------------------------

  SET $SA sa_accept     $sa_accept
  SET $SA initial_temp  $initial_temp
  SET $SA final_temp    $final_temp
  SET $SA temp_step     $temp_step
  SET $SA temp_freq     $temp_freq
  SET $SA temperature   0.0        ;#	/* Current temperature. */
  
  #----------------------------------------------

  SET $pop "sa_params"  $SA

}
# //------------------------------------------------------------------------------
# /**********************************************************************
#   synopsis:	Performs optimisation on the passed entity by using a
#   		simplistic simulated annealling protocol.  The local
# 		search and fitness evaluations are performed using the
# 		standard mutation and evaluation callback mechanisms,
# 		respectively.

# 		The passed entity will have its data overwritten.  The
# 		remainder of the population will be let untouched.  Note
# 		that it is safe to pass a NULL initial structure, in
# 		which case a random starting structure wil be generated,
# 		however the final solution will not be available to the
# 		caller in any obvious way.

# 		Custom cooling schemes may be introduced by using
# 		ga_population_set_sa_temperature() from within
# 		an iteration_hook callback.
#  **********************************************************************/

# ------------------------------------------------------------------------------
# int 
# ga_sa (population  *pop,
#        entity	   *initial,
#        const int    max_iterations)
# ------------------------------------------------------------------------------
proc  ga_sa {task pop 
             initial 
             max_iterations} {


  set SA [GET $pop sa_params]

  #   int	iteration = 0;		/* Current iteration number. */
  set iteration 0

  #   entity	*putative;		/* Current solution. */
  #   entity	*best;			/* Current solution. */
  #   entity	*tmp;			/* Used to swap working solutions. */
  
  if {$::is_print} {
    puts "> "
    puts "> ga_sa ............................................. "
    puts "> "
  }
  
  #   // Checks. 
  #   if (! pop)            die ("NULL pointer to population structure passed.");
  #   if (! pop->evaluate)  die ("Population's evaluation callback is undefined.");
  #   if (! pop->mutate)    die ("Population's mutation callback is undefined.");
  #   if (! pop->sa_params) die ("ga_population_set_sa_params(), or similar, must be used prior to ga_sa().");
  
  # Prepare working entities ...

  set putative [get_free_and_init $pop $task]

  #set best     [ga_get_free_entity  $pop] ;#  2-й
  set best     [get_free_and_init  $pop $task] ;#  2-й
  #
  #   // Do we need to generate a random starting solution?
  #   if (! initial)

  if {$initial == "NULL"} \
  {
    if {$::is_print} {
      puts "> Will perform simulated annealling with random starting solution. "
    }
    
    set initial [get_free_and_init $pop $task] ;#  3-й
    #set initial [ga_get_free_entity $pop] ;#  3-й
    #ga_entity_seed  $pop $initial

    #ga_entity_seed  $pop $best

  } else {   
    #     if (is_print)
    #       printf ("> Will perform simulated annealling with specified starting solution. \n");

    ga_entity_copy $pop  $best $initial ;# $best <-- $initial
  }
  
  #   //
  #   // Ensure that initial solution is scored.
  #   //
  #   if (best->fitness==GA_MIN_FITNESS) pop->evaluate(pop, best);
  #

  if {[string equal [item_get_fitn $best]  $::GA_MIN_FITNESS]} {item

    puts "...... GA_MIN_FITNESS ......................"

    set eval_proc [GET $task "fitness_proc"]
    #$eval_proc  $pop $best
    pop_eval_item $pop $best $eval_proc $task
    
  }
#   if {[ent_get_fitness $initial] == $::GA_MIN_FITNESS} {
#     [$pop.evaluate] $pop $initial
#   }
  
  #   if (is_print)
  #     printf ("> Prior to the first iteration, the current solution has fitness score of %f \n",
  #             best->fitness);
  
  if {$::is_print} { 
    puts "> "
    puts [format \
            "> Prior to the first iteration, the current solution has fitness score of %f " \
            [item_get_fitn $best]]
    puts "> "

    pop_print $pop
  }

  #   //
  #   // Do all the iterations:
  #   // 
  #   // Stop when (a) max_iterations reached, or
  #   //           (b) "pop->iteration_hook" returns FALSE.
  #   //

  SET $SA temperature   [GET $SA initial_temp]
  
  #   while ( (pop->iteration_hook?pop->iteration_hook(iteration, best):TRUE) &&
  #          iteration<max_iterations )

  while {1} {

    if {$iteration >= $max_iterations} {break}
    
    incr iteration
    #     iteration++;
    
    if {[GET $SA temp_freq] == -1} \
    {
      #       pop->sa_params->temperature = pop->sa_params->initial_temp
      #         + ((double)iteration/max_iterations)
      #         * (pop->sa_params->final_temp - pop->sa_params->initial_temp);

      puts stderr "55555555555555555555" ;# мы сюда не попадаем ????
    } else {

      #       if (    pop->sa_params->temperature > pop->sa_params->final_temp
      #           && iteration%pop->sa_params->temp_freq == 0 )
      #       {
      #         pop->sa_params->temperature -= pop->sa_params->temp_step;
      #       }

      set t [GET $SA temperature]
      set f [GET $SA final_temp]

      set q [expr {$iteration % [GET $SA temp_freq]}]

      if {$t > $f  && $q == 0} \
      {
        #[GET $SA temperature] = [expr {[GET $SA temperature] - $SA.temp_step}]
        [GET $SA temperature] = [expr {[GET $SA temperature] - [GET $SA temp_step]}]
      }

      puts stderr "6666666666666666666"
    }
    
    #  
    # Generate and score a new solution.
    # 
    [GET $pop mutate]   $pop $best $putative
    #[GET $pop evaluate] $pop       $putative
    
    #set task      [GET $pop  "TASK"]
    set eval_proc [GET $task "fitness_proc"]
    #$eval_proc $pop       $putative
    pop_eval_item $pop $putative $eval_proc $task

    #
    # Use the acceptance criterion to decide whether this new solution should
    # be selected or discarded.
    # 
    if {[[GET $SA sa_accept] $pop  $best $putative]} \
    {
      set   tmp    $best
      set  best    $putative
      set putative $tmp
    }
    
    # 
    # Save the current best solution in the initial entity, if this
    # is now the best found so far.
    # 

    if {[item_get_fitn $initial] < [item_get_fitn $best]} \
    {
      ga_entity_blank $pop $initial
      ga_entity_copy  $pop $initial $best
    }
    
    #     //
    #     // Use the iteration callback.
    #     //
    #     if (is_print)
    #       printf ("> After iteration %d, the current solution has fitness score of %f \n",
    #               iteration,
    #               best->fitness);
    
    if {$::is_print} { 
      puts [format "> After iteration %d, the current solution has fitness score of %f" \
              $iteration [item_get_fitn $best]]
    }

  }  ;# // Iteration loop.
  

  if {$::is_print} { 
    puts "> "

    pop_print $pop
  }

  #   //
  #   // Cleanup.
  #   //
  pop_del_entity  $pop $best     ;#       //??
  pop_del_entity  $pop $putative ;#
  
  return $iteration
}
# //******************************************************************************
# // 
# //------------------------------------------------------------------------------



