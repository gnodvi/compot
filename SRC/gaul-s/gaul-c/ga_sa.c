//------------------------------------------------------------------------------
//
//  ga_sa.c

//  ga_sa - A simulated annealling algorithm for comparison and search.
//  Copyright ©2002-2006, Stewart Adcock <stewart@linux-domain.com>
//  All rights reserved.

//  Synopsis:     A simulated annealling algorithm for comparison and search.

//------------------------------------------------------------------------------

//#include "ga_sa.h"
#include "gaul.h"

//------------------------------------------------------------------------------
//  synopsis:     Simulated annealling acceptance criterion.
//------------------------------------------------------------------------------
boolean 
ga_sa_boltzmann_acceptance (population	*pop,
			    entity	*original,
			    entity	*putative)
{

  double ofit = original->fitness;
  double pfit = putative->fitness;

  double d = GA_BOLTZMANN_FACTOR * pop->sa_params->temperature;

  if (ofit < pfit) return (true);

  boolean rand_prob = random_boolean_prob (exp ((pfit - ofit) / d ));

  return (rand_prob);

/*   return ( original->fitness < putative->fitness || */
/*           random_boolean_prob (exp((putative->fitness - original->fitness) */
/*                                   /(GA_BOLTZMANN_FACTOR*pop->sa_params->temperature))) ); */
}
//------------------------------------------------------------------------------
//  synopsis:     Simulated annealling acceptance criterion.
//------------------------------------------------------------------------------
boolean 
ga_sa_linear_acceptance (population  *pop,
                         entity	     *original,
                         entity	     *putative)
{

  return (original->fitness < putative->fitness+pop->sa_params->temperature);
}
//------------------------------------------------------------------------------
//  synopsis:   Sets the simulated annealling temperature.
//		Valid only for use during callbacks from
//		ga_simulated_annealling().
//------------------------------------------------------------------------------
void 
ga_population_set_sa_temperature (population  *pop,
                                  double       temp)
{

  if (! pop) die ("Null pointer to population structure passed.");
  if (! pop->sa_params)
    die ("ga_population_set_sa_parameters() must be called prior to ga_population_set_sa_temperature()");

  pop->sa_params->temperature = temp;

  return;
}
//------------------------------------------------------------------------------
//  synopsis:     Returns the current simulated annealling temperature.
//------------------------------------------------------------------------------
double 
ga_population_get_sa_temperature (population *pop)
{

  if (! pop) die("Null pointer to population structure passed.");
  if (! pop->sa_params)
    die ("ga_population_set_sa_parameters() must be called prior to ga_population_get_sa_temperature()");

  return pop->sa_params->temperature;
}
//------------------------------------------------------------------------------
//  synopsis:     Sets the simulated annealling parameters for a
//	    	  population.
//------------------------------------------------------------------------------
void 
ga_population_set_sa_parameters (population             *pop,
                                 GAsa_accept             sa_accept,
                                 const double            initial_temp,
                                 const double            final_temp,
                                 const double            temp_step,
                                 const int               temp_freq )
{

  if (! pop)       die ("Null pointer to population structure passed.");
  if (! sa_accept) die ("Null pointer to GAsa_accept callback passed.");

  plog ( LOG_VERBOSE,
       "Population's SA parameters: inital_temp = %f final_temp = %f temp_step = %f temp_freq = %d",
       initial_temp, final_temp, temp_step, temp_freq );

  if (pop->sa_params == NULL)
  {
    if (! (pop->sa_params = s_malloc(sizeof(ga_sa_t))))
      die ("Unable to allocate memory");
  }

  pop->sa_params->sa_accept    = sa_accept;
  pop->sa_params->initial_temp = initial_temp;
  pop->sa_params->final_temp   = final_temp;
  pop->sa_params->temp_step    = temp_step;
  pop->sa_params->temp_freq    = temp_freq;
  pop->sa_params->temperature  = 0.0;	/* Current temperature. */

  return;
}
//------------------------------------------------------------------------------
/**********************************************************************
  synopsis:	Performs optimisation on the passed entity by using a
  		simplistic simulated annealling protocol.  The local
		search and fitness evaluations are performed using the
		standard mutation and evaluation callback mechanisms,
		respectively.

		The passed entity will have its data overwritten.  The
		remainder of the population will be let untouched.  Note
		that it is safe to pass a NULL initial structure, in
		which case a random starting structure wil be generated,
		however the final solution will not be available to the
		caller in any obvious way.

		Custom cooling schemes may be introduced by using
		ga_population_set_sa_temperature() from within
		an iteration_hook callback.
 **********************************************************************/
//------------------------------------------------------------------------------

int 
ga_sa (population  *pop,
       entity	   *initial,
       const int    max_iterations)
{
  int		iteration=0;		/* Current iteration number. */
  entity	*putative;		/* Current solution. */
  entity	*best;			/* Current solution. */
  entity	*tmp;			/* Used to swap working solutions. */

  if (is_print) {
    printf ("> \n");
    printf ("> ga_sa ............................................. \n");
    printf ("> \n");
  }

  // Checks. 
  if (! pop)            die ("NULL pointer to population structure passed.");
  if (! pop->evaluate)  die ("Population's evaluation callback is undefined.");
  if (! pop->mutate)    die ("Population's mutation callback is undefined.");
  if (! pop->sa_params) die ("ga_population_set_sa_params(), or similar, must be used prior to ga_sa().");

  // Prepare working entities.
  putative = ga_get_free_entity (pop);
  best     = ga_get_free_entity (pop);

  // Do we need to generate a random starting solution?
  if (! initial)
  {
    if (is_print)
      printf ("> Will perform simulated annealling with random starting solution. \n");

    initial = ga_get_free_entity(pop);
    ga_entity_seed (pop, best);
  }
  else
  {   
    if (is_print)
      printf ("> Will perform simulated annealling with specified starting solution. \n");
    ga_entity_copy(pop, best, initial);
  }

  //
  // Ensure that initial solution is scored.
  //
  if (best->fitness==GA_MIN_FITNESS) pop->evaluate(pop, best);

  if (is_print) {
    printf ("> Prior to the first iteration, the current solution has fitness score of %f \n",
            best->fitness);
    printf ("> \n");

    pop_print (pop);    
    }

  //
  // Do all the iterations:
  // 
  // Stop when (a) max_iterations reached, or
  //           (b) "pop->iteration_hook" returns FALSE.
  //
  pop->sa_params->temperature = pop->sa_params->initial_temp;

  while ( (pop->iteration_hook?pop->iteration_hook(iteration, best):TRUE) &&
         iteration<max_iterations )
  {
    iteration++;

    if (pop->sa_params->temp_freq == -1)
    {
      pop->sa_params->temperature = pop->sa_params->initial_temp
        + ((double)iteration/max_iterations)
        * (pop->sa_params->final_temp-pop->sa_params->initial_temp);
    }
    else
    {
      if (    pop->sa_params->temperature > pop->sa_params->final_temp
          && iteration%pop->sa_params->temp_freq == 0 )
      {
        pop->sa_params->temperature -= pop->sa_params->temp_step;
      }
    }

    //
    // Generate and score a new solution.
    //
    pop->mutate  (pop, best, putative);
    pop->evaluate(pop, putative);

    //
    // Use the acceptance criterion to decide whether this new solution should
    // be selected or discarded.
    //
    if (pop->sa_params->sa_accept (pop, best, putative))
    {
      tmp      = best;
      best     = putative;
      putative = tmp;
    }

    //
    // Save the current best solution in the initial entity, if this
    // is now the best found so far.
    //
    if (initial->fitness<best->fitness)
    {
      ga_entity_blank(pop, initial);
      ga_entity_copy (pop, initial, best);
    }

    //
    // Use the iteration callback.
    //
    if (is_print) 
      printf ("> After iteration %2d, the current solution has fitness score of %f \n",
              iteration,
              best->fitness);

  }  // Iteration loop.

  if (is_print) {
    printf ("> \n");
    pop_print (pop);    
    }

  //
  // Cleanup.
  //
  ga_entity_dereference (pop, best);       //??
  ga_entity_dereference (pop, putative);

  return iteration;
}
//******************************************************************************
// 
//------------------------------------------------------------------------------



