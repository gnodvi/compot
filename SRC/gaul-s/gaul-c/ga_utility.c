/**********************************************************************
  ga_utility.c
 **********************************************************************

  ga_utility - High-level genetic algorithm routines.
  Copyright б╘2000-2006, Stewart Adcock <stewart@linux-domain.com>
  All rights reserved.

  Synopsis:     High-level GA functions and convenience functions.

  To do:	Population/entity iterator functions.
		On-line and off-line performance summaries.

 **********************************************************************/

#include "gaul.h"


/**********************************************************************
  synopsis:	Display diagnostics message.
 **********************************************************************/
void 
ga_diagnostics (void)
{
  int	num_pops;	/* Number of populations defined, or -1 for no table. */

  printf("=== GA utility library =======================================\n");
  printf("Version:                     %s\n", GA_VERSION_STRING);
  printf("Build date:                  %s\n", GA_BUILD_DATE_STRING);
  printf("Compilation machine characteristics:\n%s\n", GA_UNAME_STRING);
  printf("--- Constants ------------------------------------------------\n");
  printf("GA_DEBUG:                    %d\n", GA_DEBUG);
  printf("GA_BOLTZMANN_FACTOR:         %e\n", GA_BOLTZMANN_FACTOR);
  printf("GA_MIN_FITNESS:              %e\n", GA_MIN_FITNESS);
  printf("BYTEBITS:                    %d\n", BYTEBITS);
  printf("--- Defaults -------------------------------------------------\n");
  printf("GA_DEFAULT_CROSSOVER_RATIO:  %f\n", GA_DEFAULT_CROSSOVER_RATIO);
  printf("GA_DEFAULT_MUTATION_RATIO:   %f\n", GA_DEFAULT_MUTATION_RATIO);
  printf("GA_DEFAULT_MIGRATION_RATIO:  %f\n", GA_DEFAULT_MIGRATION_RATIO);
  printf("GA_DEFAULT_ALLELE_MUTATION_PROB: %f\n", GA_DEFAULT_ALLELE_MUTATION_PROB);
  printf("--- Data structures ------------------------------------------\n");
  printf("structure                    sizeof\n");
  printf("population                   %lu\n", (unsigned long) sizeof(population));
  printf("entity                       %lu\n", (unsigned long) sizeof(entity));
  printf("gaulbyte                     %lu\n", (unsigned long) sizeof(gaulbyte));
  printf("--- Current variables ----------------------------------------\n");
  num_pops = ga_get_num_populations();
  if (num_pops==-1)
    {
    printf("Population table:            undefined\n");
    }
  else
    {
    printf("Population table:            defined\n");
    printf("Size:                        %d\n", num_pops);
    }
  printf("==============================================================\n");

  return;
}
/**********************************************************************
  synopsis:	Return major version number.
 **********************************************************************/
int ga_get_major_version( void )
  {

  return GA_MAJOR_VERSION;
  }
/**********************************************************************
  synopsis:	Return major version number.
 **********************************************************************/
int 
ga_get_minor_version (void)
{

  return GA_MINOR_VERSION;
}
/**********************************************************************
  synopsis:	Return patch level (version) number.
 **********************************************************************/
int 
ga_get_patch_version (void)
{

  return GA_PATCH_VERSION;
}
/**********************************************************************
  synopsis:	High-level function to create a new population and
		perform the basic setup (i.e. initial seeding) required
		for further optimisation and manipulation.
		Assumes the use of integer chromosomes is desired.
		Integer-valued chromsomes.
 **********************************************************************/
population *
ga_genesis_integer (const int		population_size,
                      const int		num_chromo,
                      const int		len_chromo,
                      GAgeneration_hook	generation_hook,
                      GAiteration_hook	iteration_hook,
                      GAdata_destructor	data_destructor,
                      GAdata_ref_incrementor	data_ref_incrementor,
                      GAevaluate		evaluate,
                      GAseed			seed,
                      GAadapt			adapt,
                      GAselect_one		select_one,
                      GAselect_two		select_two,
                      GAmutate		mutate,
                      GAcrossover	crossover,
                      GAreplace		replace,
                      vpointer		userdata )
{
  population	*pop;	/* The new population structure. */

  plog(LOG_VERBOSE, "Genesis is beginning!");

  //
  // Initialise OpenMP code.
  //
  // ga_init_openmp();
  
  /*
    * Allocate and initialise a new population.
    * This call also sets this as the active population.
    */
  if ( !(pop = ga_population_new (population_size, /* num_chromo, */ len_chromo)) )
    return NULL;


  // будем отличать это !!
  pop->ch_form = CH_FORM_INT;

  //
  // Assign population's user data.
  //
  pop->data = userdata;

  //
  // Define some callback functions.
  //
  pop->generation_hook = generation_hook;
  pop->iteration_hook = iteration_hook;

  pop->data_destructor = data_destructor;
  pop->data_ref_incrementor = data_ref_incrementor;

  pop->chromosome_constructor = ga_chromosome_integer_allocate;
  pop->chromosome_destructor  = ga_chromosome_integer_deallocate;
  pop->chromosome_replicate   = ga_chromosome_integer_replicate;
  pop->chromosome_to_bytes    = ga_chromosome_integer_to_bytes;
  pop->chromosome_from_bytes  = ga_chromosome_integer_from_bytes;
  pop->chromosome_to_string   = ga_chromosome_integer_to_string;

  pop->evaluate = evaluate;
  pop->seed = seed;
  pop->adapt = adapt;
  pop->select_one = select_one;
  pop->select_two = select_two;
  pop->mutate = mutate;
  pop->crossover = crossover;
  pop->replace = replace;

  /*
    * Seed the population.
    */
#if 0
  if (seed==NULL)
    {
    plog(LOG_VERBOSE, "Entity seed function not defined.  Genesis can not occur.  Continuing anyway.");
    }
  else
    {
    ga_population_seed (pop);
    plog (LOG_VERBOSE, "Genesis has occured!");
    }
#endif

  return pop;
}
/**********************************************************************
  *** DEPRECATED FUNCTIONS! ***
  synopsis:	High-level function to create a new population and
		perform the basic setup (i.e. initial seeding) required
		for further optimisation and manipulation.
		Assumes the use of integer chromosomes is desired.
		This currently only exists for compatibility with
		older versions of GAUL.
		Integer-valued chromsomes.
 **********************************************************************/

#ifndef COMPILE_DEPRECATED_FUNCTIONS

population *
ga_genesis (const int		population_size,
              const int		num_chromo,
              const int		len_chromo,
              GAgeneration_hook	generation_hook,
              GAiteration_hook	iteration_hook,
              GAdata_destructor	data_destructor,
              GAdata_ref_incrementor	data_ref_incrementor,
              GAevaluate		evaluate,
              GAseed			seed,
              GAadapt			adapt,
              GAselect_one		select_one,
              GAselect_two		select_two,
              GAmutate		mutate,
              GAcrossover		crossover,
              GAreplace		replace,
              vpointer		userdata )
{
  plog(LOG_FIXME, "Use of ga_genesis() is deprecated.  Modify code to use ga_genesis_integer() instead.");

  return ga_genesis_integer( population_size, num_chromo, len_chromo,
                             generation_hook, iteration_hook,
                             data_destructor, data_ref_incrementor,
                             evaluate, seed, adapt,
                             select_one, select_two, mutate, crossover, replace,
                             userdata );
  }

population *ga_genesis_int(	const int		population_size,
			const int		num_chromo,
			const int		len_chromo,
			GAgeneration_hook	generation_hook,
			GAiteration_hook	iteration_hook,
			GAdata_destructor	data_destructor,
			GAdata_ref_incrementor	data_ref_incrementor,
			GAevaluate		evaluate,
			GAseed			seed,
			GAadapt			adapt,
			GAselect_one		select_one,
			GAselect_two		select_two,
			GAmutate		mutate,
			GAcrossover		crossover,
			GAreplace		replace,
			vpointer		userdata )
  {
  plog(LOG_FIXME, "Use of ga_genesis_int() is deprecated.  Modify code to use ga_genesis_integer() instead.");

  return ga_genesis_integer( population_size, num_chromo, len_chromo,
                             generation_hook, iteration_hook,
                             data_destructor, data_ref_incrementor,
                             evaluate, seed, adapt,
                             select_one, select_two, mutate, crossover, replace,
                             userdata );
  }
#endif
/**********************************************************************
  synopsis:	High-level function to create a new population and
		perform the basic setup (i.e. initial seeding) required
		for further optimisation and manipulation.
		Character-valued chromosomes.
 **********************************************************************/
population *
ga_genesis_char (const int		population_size,
                 const int		num_chromo,
                 const int		len_chromo,
                 GAgeneration_hook	generation_hook,
                 GAiteration_hook	iteration_hook,
                 GAdata_destructor	data_destructor,
                 GAdata_ref_incrementor	data_ref_incrementor,
                 GAevaluate		evaluate,
                 GAseed			seed,
                 GAadapt		adapt,
                 GAselect_one		select_one,
                 GAselect_two		select_two,
                 GAmutate		mutate,
                 GAcrossover		crossover,
                 GAreplace		replace,
                 vpointer		userdata )
{

  population  *pop;  /* The new population structure. */

  plog (LOG_VERBOSE, "Genesis is beginning!");

  /*
    * Initialise OpenMP code.
    */
  // ga_init_openmp();
  
  /*
    * Allocate and initialise a new population.
    * This call also sets this as the active population.
    */
  if (! (pop = ga_population_new (population_size, /* num_chromo, */ len_chromo)))
    return NULL;

  //
  //
  pop->ch_form = CH_FORM_CHAR;


  /*
    * Assign population's user data.
    */
  pop->data = userdata;

  /*
    * Define some callback functions.
    */
  pop->generation_hook = generation_hook;
  pop->iteration_hook  = iteration_hook;

  pop->data_destructor      = data_destructor;
  pop->data_ref_incrementor = data_ref_incrementor;

  pop->chromosome_constructor = ga_chromosome_char_allocate;
  pop->chromosome_destructor  = ga_chromosome_char_deallocate;
  pop->chromosome_replicate   = ga_chromosome_char_replicate;
  pop->chromosome_to_bytes    = ga_chromosome_char_to_bytes;
  pop->chromosome_from_bytes  = ga_chromosome_char_from_bytes;
  pop->chromosome_to_string   = ga_chromosome_char_to_string;

  pop->evaluate   = evaluate;
  pop->seed       = seed;
  pop->adapt      = adapt;
  pop->select_one = select_one;
  pop->select_two = select_two;
  pop->mutate     = mutate;
  pop->crossover  = crossover;
  pop->replace    = replace;

  /*
    * Seed the population.
    */
#if 0
  if (seed == NULL)
    {
    plog (LOG_VERBOSE, "Entity seed function not defined.  Genesis can not occur.  Continuing anyway.");
    }
  else
    {
    ga_population_seed (pop);
    plog (LOG_VERBOSE, "Genesis has occured!");
    }
#endif

  return pop;
}
/**********************************************************************
  synopsis:	High-level function to create a new population and
		perform the basic setup (i.e. initial seeding) required
		for further optimisation and manipulation.
		Boolean-valued chromosomes.
  return:	population, or NULL on failure.
 **********************************************************************/
population *
ga_genesis_boolean (const int		population_size,
                      const int		num_chromo,
                      const int		len_chromo,
                      GAgeneration_hook	generation_hook,
                      GAiteration_hook	iteration_hook,
                      GAdata_destructor	data_destructor,
                      GAdata_ref_incrementor	data_ref_incrementor,
                      GAevaluate		evaluate,
                      GAseed			seed,
                      GAadapt			adapt,
                      GAselect_one		select_one,
                      GAselect_two		select_two,
                      GAmutate		mutate,
                      GAcrossover		crossover,
                      GAreplace		replace,
                      vpointer		userdata )
{
  population	*pop;	/* The new population structure. */

  plog(LOG_VERBOSE, "Genesis is beginning!");

/*
 * Initialise OpenMP code.
 */
  //ga_init_openmp();

/*
 * Allocate and initialise a new population.
 * This call also sets this as the active population.
 */
  if ( !(pop = ga_population_new( population_size,/*  num_chromo, */ len_chromo )) )
    return NULL;

/*
 * Assign population's user data.
 */
  pop->data = userdata;

/*
 * Define some callback functions.
 */
  pop->generation_hook = generation_hook;
  pop->iteration_hook = iteration_hook;

  pop->data_destructor = data_destructor;
  pop->data_ref_incrementor = data_ref_incrementor;

  pop->chromosome_constructor = ga_chromosome_boolean_allocate;
  pop->chromosome_destructor = ga_chromosome_boolean_deallocate;
  pop->chromosome_replicate = ga_chromosome_boolean_replicate;
  pop->chromosome_to_bytes = ga_chromosome_boolean_to_bytes;
  pop->chromosome_from_bytes = ga_chromosome_boolean_from_bytes;
  pop->chromosome_to_string = ga_chromosome_boolean_to_string;

  pop->evaluate = evaluate;
  pop->seed = seed;
  pop->adapt = adapt;
  pop->select_one = select_one;
  pop->select_two = select_two;
  pop->mutate = mutate;
  pop->crossover = crossover;
  pop->replace = replace;

/*
 * Seed the population.
 */
#if 0
  if (seed==NULL)
    {
    plog(LOG_VERBOSE, "Entity seed function not defined.  Genesis can not occur.  Continuing anyway.");
    }
  else
    {
    ga_population_seed(pop);
    plog(LOG_VERBOSE, "Genesis has occured!");
    }
#endif

  return pop;
  }
/**********************************************************************
  synopsis:	High-level function to create a new population and
		perform the basic setup (i.e. initial seeding) required
		for further optimisation and manipulation.
		Double precision real-valued chromosomes.
  return:	population, or NULL on failure.
 **********************************************************************/
population *
ga_genesis_double (const int		population_size,
                     const int		num_chromo,
                     const int		len_chromo,
                     GAgeneration_hook	generation_hook,
                     GAiteration_hook	iteration_hook,
                     GAdata_destructor	data_destructor,
                     GAdata_ref_incrementor	data_ref_incrementor,
                     GAevaluate		evaluate,
                     GAseed			seed,
                     GAadapt			adapt,
                     GAselect_one		select_one,
                     GAselect_two		select_two,
                     GAmutate		mutate,
                     GAcrossover		crossover,
                     GAreplace		replace,
                     vpointer		userdata )
{
  population	*pop;	/* The new population structure. */

  plog (LOG_VERBOSE, "Genesis is beginning!");

  /*
    * Initialise OpenMP code.
    */
  //ga_init_openmp();
  
  /*
    * Allocate and initialise a new population.
    * This call also sets this as the active population.
    */
  if (! (pop = ga_population_new (population_size, /* num_chromo, */ len_chromo )))
    return NULL;
  
  // 
  pop->ch_form = CH_FORM_DOUBLE;

  /*
    * Assign population's user data.
    */
  pop->data = userdata;
  
  /*
    * Define some callback functions.
    */
  pop->generation_hook = generation_hook;
  pop->iteration_hook = iteration_hook;

  pop->data_destructor = data_destructor;
  pop->data_ref_incrementor = data_ref_incrementor;

  pop->chromosome_constructor = ga_chromosome_double_allocate;
  pop->chromosome_destructor = ga_chromosome_double_deallocate;
  pop->chromosome_replicate = ga_chromosome_double_replicate;
  pop->chromosome_to_bytes = ga_chromosome_double_to_bytes;
  pop->chromosome_from_bytes = ga_chromosome_double_from_bytes;
  pop->chromosome_to_string = ga_chromosome_double_to_string;

  pop->evaluate = evaluate;
  pop->seed = seed;
  pop->adapt = adapt;
  pop->select_one = select_one;
  pop->select_two = select_two;
  pop->mutate = mutate;
  pop->crossover = crossover;
  pop->replace = replace;

  /*
    * Seed the population.
    */
#if 0
  if (seed==NULL)
    {
    plog(LOG_VERBOSE, "Entity seed function not defined.  Genesis can not occur.  Continuing anyway.");
    }
  else
    {
    ga_population_seed(pop);
    plog(LOG_VERBOSE, "Genesis has occured!");
    }
#endif

  return pop;
}
/**********************************************************************
  synopsis:	High-level function to create a new population and
		perform the basic setup (i.e. initial seeding) required
		for further optimisation and manipulation.
		Bitstring-valued chromosomes.
  return:	population, or NULL on failure.
 **********************************************************************/
population *
ga_genesis_bitstring (const int		population_size,
                      const int		num_chromo,
                      const int		len_chromo,
                      GAgeneration_hook	generation_hook,
                      GAiteration_hook	iteration_hook,
                      GAdata_destructor	data_destructor,
                      GAdata_ref_incrementor	data_ref_incrementor,
                      GAevaluate		evaluate,
                      GAseed			seed,
                      GAadapt			adapt,
                      GAselect_one		select_one,
                      GAselect_two		select_two,
                      GAmutate		mutate,
                      GAcrossover		crossover,
                      GAreplace		replace,
                      vpointer		userdata )
{
  population	*pop;	/* The new population structure. */

  plog(LOG_VERBOSE, "Genesis is beginning!");

/*
 * Initialise OpenMP code.
 */
  //ga_init_openmp();

/*
 * Allocate and initialise a new population.
 * This call also sets this as the active population.
 */
  if (! (pop = ga_population_new (population_size, /* num_chromo, */ len_chromo )))
    return NULL;

/*
 * Assign population's user data.
 */
  pop->data = userdata;

/*
 * Define some callback functions.
 */
  pop->generation_hook = generation_hook;
  pop->iteration_hook = iteration_hook;

  pop->data_destructor = data_destructor;
  pop->data_ref_incrementor = data_ref_incrementor;

  pop->chromosome_constructor = ga_chromosome_bitstring_allocate;
  pop->chromosome_destructor = ga_chromosome_bitstring_deallocate;
  pop->chromosome_replicate = ga_chromosome_bitstring_replicate;
  pop->chromosome_to_bytes = ga_chromosome_bitstring_to_bytes;
  pop->chromosome_from_bytes = ga_chromosome_bitstring_from_bytes;
  pop->chromosome_to_string = ga_chromosome_bitstring_to_string;

  pop->evaluate = evaluate;
  pop->seed = seed;
  pop->adapt = adapt;
  pop->select_one = select_one;
  pop->select_two = select_two;
  pop->mutate = mutate;
  pop->crossover = crossover;
  pop->replace = replace;

/*
 * Seed the population.
 */
#if 0
  if (seed==NULL)
    {
    plog(LOG_VERBOSE, "Entity seed function not defined.  Genesis can not occur.  Continuing anyway.");
    }
  else
    {
    ga_population_seed(pop);
    plog(LOG_VERBOSE, "Genesis has occured!");
    }
#endif

  return pop;
}
/**********************************************************************
  synopsis:	Perform complete systematic search on a given allele
		in a given entity.  If initial solution is NULL, then
		a random solution is generated (but use of that feature
		is unlikely to be useful!).
		The original entity will not be munged.
                NOTE: max_val is the maximum value _+_ 1!
		WARNING: Now only works for integer array chromosomes!
		FIXME: Need to make chromosome datatype agnostic.
  return:	Best solution found.
 **********************************************************************/

#ifndef COMPILE_DEPRECATED_FUNCTIONS

entity *
ga_allele_search (population	*pop,
                  const int	chromosomeid,
                  const int	point,
                  const int 	min_val,
                  const int 	max_val,
                  entity		*initial )
{
  int		val;			/* Current value for point. */
  entity	*current, *best;	/* The solutions. */

/* Checks. */
/* FIXME: More checks needed. */
  if ( !pop ) die("Null pointer to population structure passed.");

  current = ga_get_free_entity(pop);	/* The 'working' solution. */
  best = ga_get_free_entity(pop);	/* The best solution so far. */

  plog(LOG_WARNING, "ga_allele_search() is a deprecated function!");

/* Do we need to generate a random solution? */
  if (initial==NULL)
    {
    plog(LOG_VERBOSE, "Will perform systematic allele search with random starting solution.");

    pop->seed(pop, best);
    }
  else
    {
    plog(LOG_VERBOSE, "Will perform systematic allele search.");

    ga_entity_copy(pop, best, initial);
    }

/*
 * Copy best solution over current solution.
 */
  ga_entity_copy(pop, current, best);
  best->fitness=GA_MIN_FITNESS;

/*
 * Loop over the range of legal values.
 */
  for (val = min_val; val < max_val; val++)
    {
    ((int *)current->chromosome[chromosomeid])[point] = val;
    ga_entity_clear_data(pop, current, chromosomeid);

    pop->evaluate(pop, current);

/*
 * Should we keep this solution?
 */
    if ( best->fitness < current->fitness )
      { /* Copy this solution best solution. */
      ga_entity_blank(pop, best);
      ga_entity_copy(pop, best, current);
      }
    else
      { /* Copy best solution over current solution. */
      ga_entity_blank(pop, current);
      ga_entity_copy(pop, current, best);
      }

    }

  plog(LOG_VERBOSE,
            "After complete search the best solution has fitness score of %f",
            best->fitness );

/*
 * Current no longer needed.  It is upto the caller to dereference the
 * optimum solution found.
 */
  ga_entity_dereference(pop, current);

  return best;
  }
#endif
/**********************************************************************
  synopsis:	Dump some statistics about a population.
 **********************************************************************/
void 
ga_population_dump (population	*pop)
{

  printf("Population id %d\n", (int) ga_get_population_id(pop));
  printf("Max size %d Stable size %d Current size %d\n", pop->max_size, pop->stable_size, pop->size);
  printf("Crossover %f Mutation %f Migration %f\n", 
         pop->crossover_ratio, pop->mutation_ratio, pop->migration_ratio);
  printf("Allele mutation prob %f\n", pop->allele_mutation_prob);
  printf("Allele ranges %d - %d %f - %f\n", 
         pop->allele_min_integer, pop->allele_max_integer, pop->allele_min_double, 
         pop->allele_max_double);

  printf("Chromosome length %d count %d\n", pop->len_chromosomes, 1/* pop->num_chromosomes */);
  printf("Best fitness %f\n", pop->entity_iarray[0]->fitness);

  return;
}
/**********************************************************************
  synopsis:	Dump some statistics about a entity.
 **********************************************************************/
void 
ga_entity_dump (population *pop, entity *john)
{
  printf( "Entity id %d rank %d\n",
         ga_get_entity_id(pop, john),
         ga_get_entity_rank(pop, john) );
  printf( "Fitness %f\n", john->fitness );
  printf( "data <%s> data0 <%s> chromo <%s> chromo0 <%s>\n",
         john->data?"defined":"undefined",
         john->data!=NULL&&((SLList *)john->data)->data!=NULL?"defined":"undefined",
         john->chromosome?"defined":"undefined",
         john->chromosome!=NULL&&john->CH!=NULL?"defined":"undefined" );

  return;
}
//******************************************************************************


