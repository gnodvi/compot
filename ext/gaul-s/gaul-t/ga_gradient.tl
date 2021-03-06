# -*-   mode: tcl  ; coding: koi8   -*- ----------------------------------------

#-------------------------------------------------------------------------------
# //------------------------------------------------------------------------------
# /**********************************************************************
#   ga_gradient.c
#  **********************************************************************

#   ga_gradient - Gradient methods for comparison and local search.
#   Copyright б╘2002-2006, Stewart Adcock <stewart@linux-domain.com>
#   All rights reserved.

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

#  **********************************************************************/

# //#include "ga_gradient.h"
# #include "gaul.h"

# //------------------------------------------------------------------------------
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

  #   if (! pop ) die ("Null pointer to population structure passed.");
  #   /*
  #     if ( !to_double )   die("Null pointer to GAto_double callback passed.");
  #     if ( !from_double ) die("Null pointer to GAfrom_double callback passed.");
  #     */
  
  #   plog (LOG_VERBOSE, "Population's gradient methods parameters set");
  
  #   if (pop->gradient_params == NULL)
  #   {
  #     if (! (pop->gradient_params = s_malloc (sizeof(ga_gradient_t))) )
  #       die ("Unable to allocate memory");
  #   }
  
  #   pop->gradient_params->to_double   = to_double;
  #   pop->gradient_params->from_double = from_double;
  #   pop->gradient_params->gradient    = gradient;
  #   pop->gradient_params->step_size   = step_size;
  #   pop->gradient_params->dimensions  = dimensions;
  #   pop->gradient_params->alpha       = 0.5;    /* Step-size scale-down factor. */
  #   pop->gradient_params->beta        = 1.2;    /* Step-size scale-up factor.   */

  $pop configure -gr_to_double   $to_double
  $pop configure -gr_from_double $from_double
  $pop configure -gr_gradient    $gradient
  $pop configure -gr_step_size   $step_size
  $pop configure -gr_dimensions  $dimensions
  $pop configure -gr_alpha       0.5         ;# /* Step-size scale-down factor. */
  $pop configure -gr_beta        1.2         ;# /* Step-size scale-up factor.   */

  return
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
#  **********************************************************************/
# //------------------------------------------------------------------------------
# void check_pop_gradient (population *pop) {


#   if (! pop)                  die ("NULL pointer to population structure passed.");
#   if (! pop->evaluate)        die ("Population's evaluation callback is undefined.");

#   if (! pop->gradient_params) 
#     die ("ga_population_set_gradient_params(), or similar, must be used prior to ga_gradient().");
#   if (! pop->gradient_params->gradient)    
#     die ("Population's first derivatives callback is undefined.");

#   return;
# }
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

  set hook_proc [$pop cget -iteration_hook]

  if {$hook_proc == "NULL"} {
    set r2 true
  } else {
    set r2 [$hook_proc $iteration $current]
  }

  set r3 [expr $iteration < $max_iterations]

  if {$::is_print} {
    #puts "check_gradient_loop:  iteration= $iteration  max_iterations= $max_iterations"    
  }

  return [expr $r1 && $r2 && $r3]
}
# //------------------------------------------------------------------------------
# void
# make_putative_from_double (population *pop, double *current_d, double	*putative_d,
#                            double  step_size, 
#                            double  *current_g, entity *putative)
# {

#   int i;

#   //for (i = 0; i < pop->len_chromosomes; i++ )
#   //  ((double *) putative->CH)[i] = ((double *) current->CH)[i] + step_size * current_g[i];
  
#   for (i = 0; i < pop->gradient_params->dimensions; i++ ) {
#     putative_d[i] = current_d[i] + step_size * current_g[i];
#   }

#   pop->gradient_params->from_double (pop, putative, putative_d);

#   return;
# }
# //------------------------------------------------------------------------------
# int 
# ga_steepestascent (population *pop,
#                    entity     *current,
#                    int	       max_iterations)
# {
#   int		iteration=0;		/* Current iteration number. */
#   //int		i;			/* Index into arrays. */
#   double	*current_d;		/* Current iteration solution array. */
#   double	*current_g;		/* Current iteration gradient array. */
#   entity	*putative;		/* New solution. */
#   double	*putative_d;		/* New solution array. */
#   entity	*tmpentity;		/* Used to swap working solutions. */
#   double	*tmpdoubleptr;		/* Used to swap working solutions. */
#   double	*buffer;		/* Storage for double arrays. */
#   double	step_size;		/* Current step size. */
#   double	grms;			/* Current RMS gradient. */
#   boolean	force_terminate=FALSE;	/* Force optimisation to terminate. */

#   /*
#     * Checks.
#     */

#   check_pop_gradient (pop);


#   if (! pop->gradient_params->to_double)   
#     die ("Population's genome to double callback is undefined.");
#   if (! pop->gradient_params->from_double) 
#     die ("Population's genome from double callback is undefined.");

#   /* 
#     * Prepare working entity and double arrays.
#     */
#   if (! (buffer = s_malloc (sizeof(double) * pop->gradient_params->dimensions * 3)) )
#     die ("Unable to allocate memory");

#   current_d  = buffer;
#   putative_d = &(buffer[pop->gradient_params->dimensions]);
#   current_g  = &(buffer[pop->gradient_params->dimensions*2]);

#   putative = ga_get_free_entity (pop);

#   // Do we need to generate a random starting solution? 
#   //
#   current = check_starting_solution (pop, current);

#   GAgradient gradient_proc = pop->gradient_params->gradient; /* Return gradients array. */
#   // 

#   //
#   // Get initial fitness and derivatives.
#   //
#   pop->evaluate (pop, current);
#   pop->gradient_params->to_double (pop, current, current_d);

#   grms = gradient_proc (pop, current, current_d, current_g);

#   plog (LOG_VERBOSE,
#        "Prior to the first iteration, the current solution has fitness score of %f and a RMS gradient of %f",
#        current->fitness, grms);

#   /*
#     * Adjust step size based on gradient.
#     * This scales the step size according to the initial gradient so that the
#     * calculation doesn't blow-up completely.
#     */
#   //  step_size = (pop->gradient_params->dimensions*pop->gradient_params->step_size) / grms;

#   step_size = pop->gradient_params->step_size;

#   /*
#     * Do all the iterations:
#     *
#     * Stop when (a) max_iterations reached, or
#     *           (b) "pop->iteration_hook" returns FALSE.
#     * The iteration hook could evaluate the RMS gradient, or the maximum component
#     * of the gradient, or any other termination criteria that may be desirable.
#     */

#   while (check_gradient_loop (pop, force_terminate, current, iteration, max_iterations))
#   {
#     iteration++;

#     make_putative_from_double (pop, current_d, putative_d,
#                                step_size, 
#                                current_g, putative);

#     pop->evaluate (pop, putative);

#     if (current->fitness > putative->fitness)
#     {	
#       // New solution is worse.
#       do
#       {
#         step_size *= pop->gradient_params->alpha;

#         make_putative_from_double (pop, current_d, putative_d,
#                                    step_size, 
#                                    current_g, putative);

#         pop->evaluate (pop, putative);

#       } while (current->fitness > putative->fitness && step_size > ApproxZero);

#       if (step_size <= ApproxZero && grms <= ApproxZero) 
#         force_terminate=TRUE;

#     } else {	
#       // New solution is an improvement. 
#       //
#       step_size *= pop->gradient_params->beta;
#     }

#     // Store improved solution.
#     tmpentity = current;
#     current   = putative;
#     putative  = tmpentity;

#     tmpdoubleptr = current_d;
#     current_d    = putative_d;
#     putative_d   = tmpdoubleptr;

#     grms = pop->gradient_params->gradient (pop, current, current_d, current_g);

#     /*
#       * Use the iteration callback.
#       */
#     plog (LOG_VERBOSE,
#          "After iteration %d, the current solution has fitness score of %f and RMS gradient of %f (step_size = %f)",
#          iteration, current->fitness, grms, step_size );

#   }  /* Iteration loop. */

#   //
#   // Cleanup.
#   //
#   ga_entity_dereference (pop, putative);

#   s_free (buffer);

#   return iteration;
# }
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
  
  for {set i 0} {$i < [$pop cget -len_chromosomes]} {incr i} \
  {
    #  ((double *) putative->CH)[i] = ((double *) current->CH)[i] + 
    #                                step_size * current_g[i];

    set ci [ent_get_chromo_gen_ $current $i]
   
    #$putative set_chromo_gen $i [expr $ci + ($step_size * [lindex $current_g $i])]
    ent_set_chromo_gen_ $putative $i [expr $ci + ($step_size * [lindex $current_g $i])]
  }
 
  return
}
# //------------------------------------------------------------------------------
# int ga_steepestascent_double (population *pop,
#                               entity     *current,
#                               int  	  max_iterations)
# //------------------------------------------------------------------------------
proc ga_steepestascent_double {pop current max_iterations} \
{

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
  set gradient_proc [$pop cget -gr_gradient]
  
  #   //
  #   // Get initial fitness and derivatives.
  #   //
  set evaluate_proc [$pop cget -evaluate]

  $evaluate_proc $pop $current
  
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
  
  set step_size [$pop cget -gr_step_size]
  
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
    $evaluate_proc  $pop $putative
    
    if {[$current cget -fitness] > [$putative cget -fitness]} \
    {	
      #       // New solution is worse.
      while {1} {
        #         step_size *= pop->gradient_params->alpha;
        set step_size [expr $step_size * [$pop cget -gr_alpha]]
        
        make_putative  $pop $current $step_size $current_g $putative
        $evaluate_proc  $pop $putative
        
        if {[$current cget -fitness] <= [$putative cget -fitness]} {break} ;# // улучшили фитнес
        if {$step_size  <= $::ApproxZero}  {break} ;# // 
        
      } 
    
      if {[expr  $step_size <= $::ApproxZero && $grms <= $::ApproxZero]} {
        set force_terminate true
      }
      
    } else {	
      #       // New solution is an improvement.
      #       // 
      #       step_size *= pop->gradient_params->beta;
      set step_size [expr $step_size * [$pop cget -gr_beta]]
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
  ga_entity_dereference  $pop $putative
  
  return $iteration
}
# //******************************************************************************
# //------------------------------------------------------------------------------

