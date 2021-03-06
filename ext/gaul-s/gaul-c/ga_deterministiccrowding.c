//------------------------------------------------------------------------------
/**********************************************************************
  ga_deterministiccrowding.c
 **********************************************************************

  ga_deterministiccrowding - Deterministic crowding.
  Copyright б╘2003-2006, Stewart Adcock <stewart@linux-domain.com>
  All rights reserved.

  Synopsis:     Deterministic crowding.

 **********************************************************************/

//#include "ga_deterministiccrowding.h"
#include "gaul.h"

//------------------------------------------------------------------------------
/**********************************************************************
  synopsis:     Sets the deterministic crowding parameters for a
		population.
  parameters:	population *pop		Population to set parameters of.
		const GAcompare		Callback to compare two entities.
  return:	none
 **********************************************************************/
//------------------------------------------------------------------------------
void 
ga_population_set_deterministiccrowding_parameters (population *pop,
                                                    const GAcompare compare)
{

  if (! pop)     die ("Null pointer to population structure passed.");
  if (! compare) die ("Null pointer to GAcompare callback passed."  );

  plog (LOG_VERBOSE, "Population's deterministic crowding parameters set");

  if (pop->dc_params == NULL)
  {
    if ( !(pop->dc_params = s_malloc(sizeof(ga_dc_t))) )
      die ("Unable to allocate memory");
  }

  pop->dc_params->compare = compare;

  return;
}
//------------------------------------------------------------------------------
/**********************************************************************
  synopsis:	Performs optimisation of the given population by a
		method known as determinstic crowding.
		ga_genesis(), or equivalent, must be called prior to
		this function.
		This approach is useful when you desire a
		significant amount of diversity in the resulting
		population.
		This was designed as a niching algorithm rather than
		an optimisation algorithm.

		During a generation, children potentially replace
		their parents as soon as they are created, rather
		than replacing them at the end of the generation.
		This differs slightly from the canonical
		deterministic crowding algorithm.
 **********************************************************************/
//------------------------------------------------------------------------------
void 
swap_i_rank (population *pop, int i, int rank)
{
  
  entity  *this_entity;	
      
  this_entity = pop->entity_iarray[i];
  pop->entity_iarray[i]    = pop->entity_iarray[rank];
  pop->entity_iarray[rank] = this_entity;

  return;
}
//------------------------------------------------------------------------------
void 
swap_one_child (population *pop, int i,  
                 entity *parent, entity *child, int ind)
{

  int  rank;  /* Rank of entity in population. */

  rank = ga_get_entity_rank (pop, child);

  if (child->fitness < parent->fitness)
  {
    swap_i_rank (pop, ind, rank);
  }

  ga_entity_dereference_by_rank (pop, rank);
  
  return;
}
//------------------------------------------------------------------------------
void 
main_swap_childs (population *pop, int i, 
                  entity *father, entity *mother, entity *son, entity *daughter,
                  int    *permutation)
{

  swap_one_child (pop, i, mother, daughter, i);

  swap_one_child (pop, i, father, son, permutation[i]);

  return;
}
//------------------------------------------------------------------------------
entity  *
mutation_step (population *pop, entity *child)
{

  entity  *this_entity;	

  if (random_boolean_prob (pop->mutation_ratio))
  {
    plog (LOG_VERBOSE, "Mutation of %d (rank %d)",
          ga_get_entity_id   (pop, child),
          ga_get_entity_rank (pop, child));
    
    this_entity = ga_get_free_entity (pop);
    pop->mutate (pop, child, this_entity);

    ga_entity_dereference (pop, child);
    child = this_entity;
  }
  
  return (child);
}
//------------------------------------------------------------------------------
int 
generation_hook_check (population *pop, int generation)
{

  return (pop->generation_hook?pop->generation_hook (generation, pop):TRUE);

}
//------------------------------------------------------------------------------
int *
ordered_make (int size)
{

  int  *ordered, i; 

  if (! (ordered = s_malloc (sizeof(int) * size)) )
    die ("Unable to allocate memory");

  for (i = 0; i < size;i++) {
    ordered[i] = i;
  }

  return (ordered);
}
//------------------------------------------------------------------------------
int 
ga_deterministiccrowding (population *pop, 
                          int max_generations)
{
  int		generation = 0;		/* Current generation number. */
  int		*permutation, *ordered;	/* Arrays of entities. */
  entity	*mother, *father;	/* Current entities. */
  entity	*son,    *daughter;	/* Current entities. */
  int		i;			/* Loop variable over entities. */
  double	dist1, dist2;		/* Genetic or phenomic distances. */
  //int		rank;			/* Rank of entity in population. */

  /* Checks. */

  if (! pop)
    die ("NULL pointer to population structure passed.");
  if (! pop->dc_params)
    die ("ga_population_set_deterministiccrowding_params(), or similar, must be used prior to ga_deterministiccrowding().");

  if (! pop->evaluate)  die ("Population's evaluation callback is undefined.");
  if (! pop->mutate)    die ("Population's mutation callback is undefined.");
  if (! pop->crossover) die ("Population's crossover callback is undefined.");

  if (! pop->dc_params->compare) die ("Population's comparison callback is undefined.");

  plog (LOG_VERBOSE, "The evolution by deterministic crowding has begun!");

  pop->generation = 0;

  //
  // Score the initial population members.
  //
  if (pop->size < pop->stable_size)
    gaul_population_fill (pop, pop->stable_size - pop->size);

  for (i = 0; i < pop->size; i++)
  {
    if (pop->entity_iarray[i]->fitness == GA_MIN_FITNESS)
      pop->evaluate (pop, pop->entity_iarray[i]);
  }

  sort_population (pop);
  ga_genocide_by_fitness (pop, GA_MIN_FITNESS);


  //
  // Prepare arrays to store permutations.
  //
  if (! (permutation = s_malloc (sizeof(int)*pop->size)) )
    die ("Unable to allocate memory");

  // ??
  ordered = ordered_make (pop->size);


  plog (LOG_VERBOSE,
       "Prior to the first generation, population has fitness scores between %f and %f",
       pop->entity_iarray[0]->fitness,
       pop->entity_iarray[pop->size-1]->fitness );

  //
  // Do all the generations:
  //
  // Stop when (a) max_generations reached, or
  //           (b) "pop->generation_hook" returns FALSE.
  //

  while (generation_hook_check (pop, generation))
  {

    if (generation >= max_generations) break;

    generation++;
    pop->generation = generation;
    pop->orig_size  = pop->size;

    plog (LOG_DEBUG,
         "Population size is %d at start of generation %d",
         pop->orig_size, generation );

    sort_population (pop);

    // почему-то не улучшилось (если здесь создавать по новой) ??
    //ordered = ordered_make (pop->size);

    if (is_print) 
      print_int_list ("ordered     = ", ordered, pop->orig_size);

    // вообще-то ordered здесь портится, а это плохо? 
    // хотя вроде строка выглядит более насыщенной !
    // 
    random_int_permutation (pop->orig_size, ordered, permutation);

    if (is_print) 
      print_int_list ("permutation = ", permutation, pop->orig_size);
    

   // FOR ........................................ BEG
    // 
    for (i = 0; i < pop->orig_size; i++ )
    {
      mother = pop->entity_iarray[i];
      father = pop->entity_iarray[permutation[i]];

      //if (is_print) {
      //  print_ch (mother, "mother= ", pop->len_chromosomes); // напечатали гены хромосомы
      //  printf  ("\n");
      //  print_ch (father, "father= ", pop->len_chromosomes); // напечатали гены хромосомы
      //  printf  ("\n");
      //}

      //
      // Crossover step.
      //
      plog (LOG_VERBOSE, "Crossover between %d (rank %d fitness %f) and %d (rank %d fitness %f)",
           ga_get_entity_id   (pop, mother),
           ga_get_entity_rank (pop, mother), mother->fitness,
           ga_get_entity_id   (pop, father),
           ga_get_entity_rank (pop, father), father->fitness);

      son = ga_get_free_entity (pop);
      daughter = ga_get_free_entity (pop);
      pop->crossover (pop, mother, father, daughter, son);

      //
      // Mutation step.
      //

      daughter = mutation_step (pop, daughter);
      son      = mutation_step (pop, son);

      //
      // Apply environmental adaptations, score entities, sort entities, etc.
      // FIXME: Currently no adaptation.
      //
      pop->evaluate (pop, daughter);
      pop->evaluate (pop, son);

      //
      // Evaluate similarities.
      //
      dist1 = pop->dc_params->compare (pop, mother, daughter) + 
              pop->dc_params->compare (pop, father, son);

      dist2 = pop->dc_params->compare (pop, mother, son) + 
              pop->dc_params->compare (pop, father, daughter);

      if (is_print) {
        printf ("i= %d  dist1= %7.2f  dist2= %7.2f \n", i, dist1, dist2);
      }

      //
      // Determine which entities will survive, and kill the others.
      //
      if (dist1 < dist2)
      {
        main_swap_childs (pop, i, father, mother, 
                            son, daughter, permutation);
      } else {
        main_swap_childs (pop, i, father, mother, 
                            daughter, son, permutation);
      }

    } 
    // FOR ........................................ END

    //if (is_print) {
    //  pop_print (pop);
    //}

    //
    // Use callback.
    //
    plog (LOG_VERBOSE,
         "After generation %d, population has fitness scores between %f and %f",
         generation,
         pop->entity_iarray[0]->fitness,
         pop->entity_iarray[pop->size-1]->fitness );

    if (is_print) {
      printf ("\n");
    }

  }  // Generation loop. 

  //
  // Ensure final ordering of population is correct.
  //
  sort_population (pop);

  //
  // Clean-up.
  //

  s_free (permutation);
  s_free (ordered);

  return generation;
}
//******************************************************************************
//------------------------------------------------------------------------------


