# -*-   mode: tcl  ; coding: koi8   -*- ----------------------------------------

# //------------------------------------------------------------------------------
#   ga_gradient.c

#   ga_gradient - Gradient methods for comparison and local search.

#   Synopsis:     Gradient methods for comparison and local search.

# 		Routines for local search and optimisation using
# 		non-evolutionary methods.  These methods are all
# 		first-order, that is, they require first derivatives.

# 		Note that, these algorithms require that chromosomes
# 		may be reversibly mapped to arrays of double-precision
# 		floating-point array chromsomes.  If this is not
# 		possible then, hmmm, tough luck.

# 		You might want to think carefully about your convergence
# 		criteria.

#   References:

#-------------------------------------------------------------------------------
#
# Gradient methods parameter structure.
# 

# dictrecord define GA_GR_T {

#   dimensions  ;#   int	        : Size of double array
#   step_size   ;#   double	: Step size, (or initial step size)
#   alpha       ;#   double	: Step size scale-down factor
#   beta        ;#   double	: Step size scale-up factor
#   to_double   ;#   GAto_double	: Convert chromosome to double array
#   from_double ;#   GAfrom_double: Convert chromosome from double array
#   gradient    ;#   GAgradient	: Return gradients array

# } 

# /**********************************************************************
#   synopsis:     Sets the gradient-search parameters for a population.
#   parameters:	population *pop		Population to set parameters of.
# 		const GAto_double	Map chromosomal data to array of doubles.
# 		const GAfrom_double	Map array of doubles to chromosomal data.
# 		const int		Number of dimensions for double array 
#                                         (Needn't match dimensions of chromosome.)
#   return:	none
#  **********************************************************************/
# //------------------------------------------------------------------------------
# void 
# ga_population_set_gradient_parameters (population		*pop,
#                                         const GAto_double	to_double,
#                                         const GAfrom_double	from_double,
#                                         const GAgradient	gradient,
# 					const int		dimensions,
# 					const double		step_size)
# //------------------------------------------------------------------------------
proc ga_population_set_gradient_parameters {pop          \
                                            to_double    \
                                            from_double  \
                                            gradient     \
                                            dimensions   \
                                            step_size}   \
{

   set GR [dict_create]


   SET $GR to_double    $to_double   ;#   GAto_double    /* Convert chromosome to double array.
   SET $GR from_double  $from_double ;#   GAfrom_double  /* Convert chromosome from double array. 
   SET $GR gradient     $gradient    ;#   GAgradient     /* Return gradients array. 
   SET $GR step_size    $step_size   ;#   double  /* Step size, (or initial step size).
   SET $GR dimensions   $dimensions  ;#   int     /* Size of double array. 
   SET $GR alpha        0.5          ;# /* Step-size scale-down factor. */
   SET $GR beta         1.2          ;# /* Step-size scale-up factor.   */
   

   SET $pop "gr_params"  $GR


  return
}
# //------------------------------------------------------------------------------
#   synopsis:	Performs optimisation on the passed entity by using a
#   		steepest ascents method (i.e. steepest descent, except
# 		maximising the fitness function).
# 		The passed entity will have its data overwritten.  The
# 		remainder of the population will be let untouched.
# 		Note that it is safe to pass a NULL initial structure,
# 		in which case a random starting structure wil be
# 		generated, however the final solution will not be
# 		available to the caller in any obvious way.
# //------------------------------------------------------------------------------
# entity *
# check_starting_solution (population *pop, entity *current) 

# //------------------------------------------------------------------------------
proc check_starting_solution {pop current} \
{

  if {$current == "NULL"} \
  {
    if {$::is_print} {
    puts "Will perform gradient search with RANDOM starting solution. \n"
    }
    
    set current [ga_get_free_entity  $pop]
    ga_entity_seed  $pop $current

  } else {   
    if {$::is_print} {
    puts "Will perform gradient search with SPECIFIED starting solution. \n"
    }
  }

  return $current
}
# //------------------------------------------------------------------------------
# int 
# check_gradient_loop (population *pop, boolean force_terminate, entity *current,
#                      int iteration, int max_iterations) 
# //------------------------------------------------------------------------------
proc check_gradient_loop {pop force_terminate current iteration max_iterations} \
{

  #   int ret =  (force_terminate == FALSE &&
  #               (pop->iteration_hook?pop->iteration_hook(iteration, current):TRUE) &&
  #               iteration < max_iterations );

  set r1 [expr {$force_terminate == false}]

  set hook_proc [GET $pop iteration_hook]

  if {$hook_proc == "NULL"} {
    set r2 true
  } else {
    set r2 [$hook_proc $iteration $current]
  }

  set r3 [expr {$iteration < $max_iterations}]

  if {$::is_print} {
    #puts "check_gradient_loop:  iteration= $iteration  max_iterations= $max_iterations"    
  }

  return [expr {$r1 && $r2 && $r3}]
}
# //------------------------------------------------------------------------------
# /**********************************************************************
#   synopsis:	Performs optimisation on the passed entity by using a
#   		steepest ascents method (i.e. steepest descent, except
# 		maximising the fitness function).
# 		The passed entity will have its data overwritten.  The
# 		remainder of the population will be let untouched.
# 		Note that it is safe to pass a NULL initial structure,
# 		in which case a random starting structure wil be
# 		generated, however the final solution will not be
# 		available to the caller in any obvious way.

# 		Only double chromosomes may be used in this optimised
# 		version of the algorithm.
#  **********************************************************************/
# //------------------------------------------------------------------------------
# void
# make_putative (population *pop, entity *current, double step_size, 
#                double	*current_g, entity *putative)
# //------------------------------------------------------------------------------
proc make_putative {pop current step_size current_g putative} \
{

  #   int i;
  
  for {set i 0} {$i < [GET $pop len_chromosomes]} {incr i} \
  {
    #  ((double *) putative->CH)[i] = ((double *) current->CH)[i] + 
    #                                step_size * current_g[i];

    set ci [ent_get_chromo_gen_ $current $i]
   
    #$putative set_chromo_gen $i [expr $ci + ($step_size * [lindex $current_g $i])]
    ent_set_chromo_gen_ $putative $i [expr {$ci + ($step_size * [lindex $current_g $i])}]
  }
 
  return
}
# //------------------------------------------------------------------------------
# int ga_steepestascent_double (population *pop,
#                               entity     *current,
#                               int  	  max_iterations)
# //------------------------------------------------------------------------------
proc ga_steepestascent_double {task pop current max_iterations} \
{

  set eval_proc [GET $task "fitness_proc"]


  set GR [GET $pop gr_params]


  #   int	iteration=0;		/* Current iteration number. */
  set iteration 0

  #   //int	i;			/* Index into arrays. */
  #   double	*current_g;		/* Current iteration gradient array. */
  #   entity	*putative;		/* New solution. */
  #   entity	*tmpentity;		/* Used to swap working solutions. */
  #   double	step_size;		/* Current step size. */
  #   double	grms;			/* Current RMS gradient. */

  #   boolean	force_terminate=FALSE;	/* Force optimisation to terminate. */
  set force_terminate false
  
  #   //
  #   // Checks ............................
  #   // 
  # check_pop_gradient $pop
  
  #   //
  #   // Prepare working entity and gradient array.
  #   //
  #   if (! (current_g = s_malloc (sizeof(double) * pop->len_chromosomes)))
  #     die ("Unable to allocate memory");
  
  set putative [ga_get_free_entity $pop]
  
  #   // Do we need to generate a random starting solution? 
  #   // 
  set current [check_starting_solution  $pop $current]
  
  #   GAgradient gradient_proc = pop->gradient_params->gradient; /* Return gradients array. */
  #   //
  set gradient_proc [GET $GR gradient]
  
  #   //
  #   // Get initial fitness and derivatives.
  #   //

  #set eval_proc [GET $pop evaluate]
  
  
  #$eval_proc $pop $current
  pop_eval_item $pop $current $eval_proc $task

  
  #   grms = gradient_proc (pop, current, (double *)current->CH, current_g);
  set current_CH [ent_CH_ $current]
  #set grms [gradient_proc  $pop $current $current_CH $current_g]
  set grms [$gradient_proc  $pop $current $current_CH current_g]
  
  
  #   plog (LOG_VERBOSE,
  #        "Prior to the first iteration, the current solution has fitness score of %f and a RMS gradient of %f",
  #        current->fitness, grms);
  
  #   // Adjust step size based on gradient.
  #   // This scales the step size according to the initial gradient so that the
  #   // calculation doesn't blow-up completely.
  #   //
  #   //  step_size = (pop->len_chromosomes*pop->gradient_params->step_size) / grms;
  
  set step_size [GET $GR step_size]
  
  #   /*
  #     * Do all the iterations:
  #     *
  #     * Stop when (a) max_iterations reached, or
  #     *           (b) "pop->iteration_hook" returns FALSE.
  #     * The iteration hook could evaluate the RMS gradient, or the maximum component
  #     * of the gradient, or any other termination criteria that may be desirable.
  #     */
  
  #if {$::is_print} {
  #  $pop print
  #  puts ""
  #}

  while {[check_gradient_loop  $pop $force_terminate $current $iteration $max_iterations]} \
  {
    #  iteration++;
    incr iteration

    if {$::is_print} {
      #puts "iteration = $iteration"
    }
  
    make_putative  $pop $current $step_size $current_g $putative
    #$eval_proc  $pop $putative
    pop_eval_item  $pop $putative $eval_proc $task
    
    if {[item_get_fitn $current] > [item_get_fitn $putative]} \
    {	
      #       // New solution is worse.
      while {1} {

        #         step_size *= pop->gradient_params->alpha;
        set step_size [expr {$step_size * [GET $GR alpha]}]
        
        make_putative  $pop $current $step_size $current_g $putative
        #$eval_proc  $pop $putative
        pop_eval_item $pop $putative $eval_proc $task 
        
        if {[item_get_fitn $current] <= [item_get_fitn $putative]} {break} 
        ;# // улучшили фитнес
        if {$step_size  <= $::ApproxZero}  {break} ;# // 
        
      } 
    
      if { [expr  {$step_size <= $::ApproxZero && $grms <= $::ApproxZero}] } {
        set force_terminate true
      }
      
    } else {	
      #       // New solution is an improvement.
      #       // 
      #       step_size *= pop->gradient_params->beta;
      set step_size [expr {$step_size * [GET $GR beta]}]
   }
    
    #  Store improved solution. 
    # 
    set tmpentity   $current
    set current    $putative
    set putative  $tmpentity
    
    #     grms = gradient_proc (pop, current, (double *)current->CH, current_g);
    set grms [$gradient_proc  $pop $current [ent_CH_ $current] current_g]
    
    #     //
    #     // Use the iteration callback.
    #     //
    #     plog (LOG_VERBOSE,
    #          "After iteration %d, the current solution has fitness score of %f and RMS gradient of %f (step_size = %f)",
    #          iteration, current->fitness, grms, step_size);
    
  }  ;# /* Iteration loop. */
  
  #   //
  #   // Cleanup.
  #   //
  pop_del_entity  $pop $putative
  
  return $iteration
}
# //******************************************************************************
# //------------------------------------------------------------------------------

