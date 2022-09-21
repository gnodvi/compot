/*******************************************************************************
  goldberg_ALL.c

  Synopsis:	Test/example program for GAUL.

		This program aims to solve the first example problem
		from Goldberg's book.

*******************************************************************************/

#include "gaul.h"


//  FIXME: This code is derived from the description
//  of the problem in Gallops, I need to acquire the
//  goldberg book and check this.
//------------------------------------------------------------------------------
boolean 
goldberg_score (population *pop, entity *entity)
{
  boolean	allele;
  double	coef;
  int		k;

  int len_chromo = pop->len_chromosomes;
  //fprintf (stderr, "len_chrom = %d \n", len_chromo);

  entity->fitness = 0.0;
  coef = pow (2.0, (double) len_chromo) - 1.0;
  coef = pow (coef, len_chromo);

  /* Loop over alleles in chromosome. */
  for (k = 0; k < len_chromo; k++)
  {
    /* Loop over bits in current byte. */
    allele = ((boolean *)entity->CH)[k];
    if (allele == 1)
    {	/* Bit is set. */
      entity->fitness += pow(2.0, (double) k);
    }
  }

  /* Raise x to the power of 10. */
  entity->fitness = pow (entity->fitness, len_chromo);

  /* Normalize fitness. */
  entity->fitness /= coef;
  
  return TRUE;
}
//------------------------------------------------------------------------------
boolean 
goldberg_ga_callback (int generation, population *pop)
{

  return TRUE;
}
//******************************************************************************
//------------------------------------------------------------------------------
int 
___main (int argc, char **argv, 
         int population_size, int len_chromo, int max_generations)
{
  //int  population_size = 20;
  //int  len_chromo = 10;
  //int  max_generations = 50;

  int		i;			/* Runs. */
  population	*pop=NULL;		/* Population of solutions. */
  char		*beststring=NULL;	/* Human readable form of best solution. */
  size_t	beststrlen=0;		/* Length of beststring. */

  random_init();

  for (i=0; i<50; i++)
  {
    if (pop) ga_extinction(pop);

    random_seed (i);

    pop = ga_genesis_boolean(
       /* 20 */population_size,	/* const int              population_size */
       1,			/* const int              num_chromo */
       /* 10 */len_chromo,	/* const int              len_chromo */
       NULL, /*goldberg1_ga_callback,*/	/* GAgeneration_hook      generation_hook */
       NULL,			/* GAiteration_hook       iteration_hook */
       NULL,			/* GAdata_destructor      data_destructor */
       NULL,			/* GAdata_ref_incrementor data_ref_incrementor */
       goldberg_score,		/* GAevaluate             evaluate */
       ga_seed_boolean_random,	/* GAseed                 seed */
       NULL,			/* GAadapt                adapt */
       ga_select_one_bestof2,	/* GAselect_one           select_one */
       ga_select_two_bestof2,	/* GAselect_two           select_two */
       ga_mutate_boolean_singlepoint,	  /* GAmutate     mutate */
       ga_crossover_boolean_singlepoints, /* GAcrossover  crossover */
       NULL,			/* GAreplace		replace */
       NULL			/* vpointer		User data */
       );

    ga_population_set_parameters(
       pop,			/* population      *pop */
       GA_SCHEME_DARWIN,	/* const ga_scheme_type     scheme */
       GA_ELITISM_PARENTS_SURVIVE,	/* const ga_elitism_type   elitism */
       0.5,			/* double  crossover */
       0.05,			/* double  mutation */
       0.0              	/* double  migration */
       );

    ga_evolution(
       pop,		         /* population              *pop */
       /* 50 */max_generations	 /* const int               max_generations */
       );

    goldberg_ga_callback (i, pop);

    printf ("The final solution with seed = %d was:\n", i);
    beststring = ga_chromosome_boolean_to_string (pop, ga_get_entity_from_rank(pop,0), 
                                                  beststring, &beststrlen);
    printf ("%s\n", beststring);
    printf ("With score = %f\n", ga_get_entity_from_rank(pop,0)->fitness);
  }

  ga_extinction (pop);
  s_free (beststring);

  exit (EXIT_SUCCESS);
}
//******************************************************************************
//------------------------------------------------------------------------------
int 
main (int argc, char **argv)
{

  if (argc !=2 ) 
    exit (EXIT_SUCCESS);

  //  Here a 10-bit chromosome is used to find the maximum
  //  of function f(x)=x^10, normalized to the range [0,1].
  if (!strcmp(argv[1], "1"))  ___main (argc, argv, 20, 10, 50);

  //  Here a 30-bit chromosome is used to find the maximum
  //  of function f(x)=x^30, normalized to the range [0,1].
  if (!strcmp(argv[1], "2"))  ___main (argc, argv, 60, 30, 100);

  exit (EXIT_SUCCESS);
}
//------------------------------------------------------------------------------
//******************************************************************************


