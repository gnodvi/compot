/*******************************************************************************

	   This program aims to solve a function of the form
	   (0.75-A)+(0.95-B)^2+(0.23-C)^3+(0.71-D)^4 = 0

*******************************************************************************/

#include "gaul.h"



//------------------------------------------------------------------------------
// Fitness function.
//------------------------------------------------------------------------------
boolean 
polynomial_score (population *pop, entity *entity)
{
  double    A, B, C, D;	/* Parameters. */

  A = ((double *) entity->CH)[0];
  B = ((double *) entity->CH)[1];
  C = ((double *) entity->CH)[2];
  D = ((double *) entity->CH)[3];

  entity->fitness = - (fabs(0.75-A) + SQU(0.95-B) + fabs(CUBE(0.23-C)) + FOURTH_POW(0.71-D));

  return TRUE;
}
//------------------------------------------------------------------------------
// Seed genetic data.
//------------------------------------------------------------------------------
boolean 
polynomial_seed (population *pop, entity *adam)
{

  /* Checks. */
  if (!pop)  die ("Null pointer to population structure passed.");
  if (!adam) die ("Null pointer to entity structure passed.");

  /* Seeding. */
  ((double *)adam->CH)[0] = random_double(2.0);
  ((double *)adam->CH)[1] = random_double(2.0);
  ((double *)adam->CH)[2] = random_double(2.0);
  ((double *)adam->CH)[3] = random_double(2.0);

  return TRUE;
}
//------------------------------------------------------------------------------
// Generation callback
//------------------------------------------------------------------------------
boolean 
polynomial_generation_callback (int generation, population *pop, int i_generation)
{

  if (generation % i_generation == 0)
    printf( "%d: A = %f B = %f C = %f D = %f (fitness = %f)\n",
           generation,
           ((double *)pop->entity_iarray[0]->CH)[0],
           ((double *)pop->entity_iarray[0]->CH)[1],
           ((double *)pop->entity_iarray[0]->CH)[2],
           ((double *)pop->entity_iarray[0]->CH)[3],
           pop->entity_iarray[0]->fitness );

  return TRUE;
}
//------------------------------------------------------------------------------
boolean 
polynomial_iteration_callback (int iteration, entity *solution, int i_print)
{
   
  if (iteration % i_print == 0)
  printf ("%d: A = %f B = %f C = %f D = %f (fitness = %f)\n",
          iteration,
          ((double *)solution->CH)[0],
          ((double *)solution->CH)[1],
          ((double *)solution->CH)[2],
          ((double *)solution->CH)[3],
          solution->fitness);

  return TRUE;
}
//------------------------------------------------------------------------------
// Convert to double array.
//------------------------------------------------------------------------------
boolean polynomial_to_double (population *pop, entity *entity, double *array)
{

  if (!pop) die("Null pointer to population structure passed.");
  if (!entity) die("Null pointer to entity structure passed.");

  array[0] = ((double *)entity->CH)[0];
  array[1] = ((double *)entity->CH)[1];
  array[2] = ((double *)entity->CH)[2];
  array[3] = ((double *)entity->CH)[3];

  return TRUE;
}
//------------------------------------------------------------------------------
// Convert from double array.
//------------------------------------------------------------------------------
boolean 
polynomial_from_double (population *pop, entity *entity, double *array)
{

  if (!pop)    die ("Null pointer to population structure passed.");
  if (!entity) die ("Null pointer to entity structure passed.");

  if (!entity->chromosome) die ("Entity has no chromsomes.");

  ((double *)entity->CH)[0] = array[0];
  ((double *)entity->CH)[1] = array[1];
  ((double *)entity->CH)[2] = array[2];
  ((double *)entity->CH)[3] = array[3];

  return TRUE;
}
//******************************************************************************



//******************************************************************************
//------------------------------------------------------------------------------
boolean 
_ga_polynomial_generation_callback (int generation, population *pop)
{
  int i_generation = 1;

  polynomial_generation_callback (generation, pop, i_generation);

  return TRUE;
}
//------------------------------------------------------------------------------
//  polynomial_ga.c
//  Synopsis:	An example program for GAUL demonstrating use
//		of the genetic algorithm.
//------------------------------------------------------------------------------
int 
_ga_main (int argc, char **argv)
{
  population	  *pop;		/* Population of solutions. */

  random_seed (23091975);

  pop = ga_genesis_double(
       200,			/* const int              population_size */
       1,			/* const int              num_chromo */
       4,			/* const int              len_chromo */
       _ga_polynomial_generation_callback,/* GAgeneration_hook      generation_hook */
       NULL,			/* GAiteration_hook       iteration_hook */
       NULL,			/* GAdata_destructor      data_destructor */
       NULL,			/* GAdata_ref_incrementor data_ref_incrementor */
       polynomial_score,		/* GAevaluate             evaluate */
       polynomial_seed,		/* GAseed                 seed */
       NULL,			/* GAadapt                adapt */
       ga_select_one_bestof2,	/* GAselect_one           select_one */
       ga_select_two_bestof2,	/* GAselect_two           select_two */
       ga_mutate_double_singlepoint_drift,	/* GAmutate               mutate */
       ga_crossover_double_doublepoints,	/* GAcrossover            crossover */
       NULL,			/* GAreplace              replace */
       NULL			/* vpointer	User data */
       );

  ga_population_set_parameters(
       pop,				/* population      *pop */
       GA_SCHEME_DARWIN,		/* const ga_scheme_type     scheme */
       GA_ELITISM_PARENTS_SURVIVE,	/* const ga_elitism_type   elitism */
       0.8,				/* double  crossover */
       0.2,				/* double  mutation */
       0.0      		        /* double  migration */
       );

  ga_evolution(
       pop,				/* population	*pop */
       500				/* const int	max_generations */
       );

  ga_extinction (pop);

  exit (EXIT_SUCCESS);
}
//******************************************************************************
//------------------------------------------------------------------------------
boolean 
_sa_polynomial_iteration_callback (int iteration, entity *solution)
{
  int i_print = 10; // Write solution every tenth iteration.
   
  polynomial_iteration_callback (iteration, solution, i_print);

  return TRUE;
}
//------------------------------------------------------------------------------
//  polynomial_sa.c
//  Synopsis:	An example program for GAUL demonstrating use
//		of the simulated annealling algorithm.
//------------------------------------------------------------------------------
int 
_sa_main (int argc, char **argv)
{
  population	  *pop;		/* Population of solutions. */

  random_seed (23091975);

  log_init (LOG_NORMAL, NULL, NULL, FALSE);

  pop = ga_genesis_double(
         40,			/* const int              population_size */
         1,			/* const int              num_chromo */
         4,			/* const int              len_chromo */
         NULL,			/* GAgeneration_hook      generation_hook */
         _sa_polynomial_iteration_callback,	/* GAiteration_hook       iteration_hook */
         NULL,			/* GAdata_destructor      data_destructor */
         NULL,			/* GAdata_ref_incrementor data_ref_incrementor */
         polynomial_score,		/* GAevaluate             evaluate */
         polynomial_seed,		/* GAseed                 seed */
         NULL,			/* GAadapt                adapt */
         NULL,			/* GAselect_one           select_one */
         NULL,			/* GAselect_two           select_two */
         ga_mutate_double_singlepoint_drift,	/* GAmutate               mutate */
         NULL,			/* GAcrossover            crossover */
         NULL,			/* GAreplace              replace */
         NULL			/* vpointer               User data */
         );

  ga_population_set_sa_parameters(
        pop, ga_sa_boltzmann_acceptance,
        100.0, 0.0, 1.0, 10
        );

  ga_sa(
        pop,				/* population	*pop */
        NULL,				/* entity       *initial */
        10000				/* const int	max_generations */
        );

  printf ( "Final: A = %f B = %f C = %f D = %f (fitness = %f)\n",
            ((double *)pop->entity_iarray[0]->CH)[0],
            ((double *)pop->entity_iarray[0]->CH)[1],
            ((double *)pop->entity_iarray[0]->CH)[2],
            ((double *)pop->entity_iarray[0]->CH)[3],
            pop->entity_iarray[0]->fitness );

  ga_extinction (pop);

  exit (EXIT_SUCCESS);
}
//******************************************************************************
//------------------------------------------------------------------------------
boolean 
_sd_polynomial_iteration_callback (int iteration, entity *solution)
{
  int i_print = 1; 

  polynomial_iteration_callback (iteration, solution, i_print);

  return TRUE;
}
//------------------------------------------------------------------------------
// Calculate gradients analytically.
//------------------------------------------------------------------------------
double 
_sd_polynomial_analytical_gradient (population *pop, entity *entity, double *params, double *grad)
{
  double		grms=0.0;	/* RMS gradient. */
  double		A, B, C, D;	/* The parameters. */

  if (!pop) die("Null pointer to population structure passed.");
  if (!entity) die("Null pointer to entity structure passed.");

  A = params[0];
  B = params[1];
  C = params[2];
  D = params[3];

  grad[0] = A > 0.75+TINY ? -1.0 : ( A < 0.75-TINY ? 1.0 : 0.0 );
  grad[1] = (0.95 - B);
  grad[2] = C > 0.23 ? -SQU(0.23 - C) : SQU(0.23 - C);
  grad[3] = CUBE(0.71 - D);

  grms = sqrt(grad[0]*grad[0]+grad[1]*grad[1]+grad[2]*grad[2]+grad[3]*grad[3]);

  return grms;
}
//------------------------------------------------------------------------------
// 
//------------------------------------------------------------------------------
int 
_sd_main (int argc, char **argv)
{
  population		*pop;			/* Population of solutions. */
  entity		*solution;		/* Optimised solution. */

  random_seed (23091975);

  pop = ga_genesis_double(
       50,			/* const int              population_size */
       1,			/* const int              num_chromo */
       4,			/* const int              len_chromo */
       NULL,			/* GAgeneration_hook      generation_hook */
       _sd_polynomial_iteration_callback,	/* GAiteration_hook       iteration_hook */
       NULL,			/* GAdata_destructor      data_destructor */
       NULL,			/* GAdata_ref_incrementor data_ref_incrementor */
       polynomial_score,		/* GAevaluate             evaluate */
       polynomial_seed,		/* GAseed                 seed */
       NULL,			/* GAadapt                adapt */
       NULL,			/* GAselect_one           select_one */
       NULL,			/* GAselect_two           select_two */
       NULL,			/* GAmutate               mutate */
       NULL,			/* GAcrossover            crossover */
       NULL,			/* GAreplace              replace */
       NULL			/* vpointer	User data */
       );

  ga_population_set_gradient_parameters(
       pop,				/* population		*pop */
       polynomial_to_double,		/* const GAto_double	to_double */
       polynomial_from_double,		/* const GAfrom_double	from_double */
       _sd_polynomial_analytical_gradient,	/* const GAgradient	gradient */
       4,				/* const int		num_dimensions */
       0.1				/* const double		step_size */
       );

  /* Evaluate and sort the initial population members (i.e. select best of 50 random solutions. */
  ga_population_score_and_sort (pop);

  /* Use the best population member. */
  solution = ga_get_entity_from_rank (pop, 0);

  ga_steepestascent (
       pop,				/* population		*pop */
       solution,			/* entity		*solution */
       1000				/* const int		max_iterations */
       );

  ga_extinction (pop);

  exit (EXIT_SUCCESS);
}
//******************************************************************************
//------------------------------------------------------------------------------
boolean 
_simplex_polynomial_iteration_callback (int iteration, entity *solution)
{
  int i_print = 1; 

  polynomial_iteration_callback (iteration, solution, i_print);

  return TRUE;
}
//******************************************************************************
//  polynomial_simplex.c
//  Synopsis:	An example program for GAUL demonstrating use
//		of the simplex algorithm.
//------------------------------------------------------------------------------
int 
_simplex_main (int argc, char **argv)
{
  population		*pop;			/* Population of solutions. */
  entity		*solution;		/* Optimised solution. */

  random_seed (23091975);

  pop = ga_genesis_double(
       50,			/* const int              population_size */
       1,			/* const int              num_chromo */
       4,			/* const int              len_chromo */
       NULL,			/* GAgeneration_hook      generation_hook */
       _simplex_polynomial_iteration_callback,	/* GAiteration_hook       iteration_hook */
       NULL,			/* GAdata_destructor      data_destructor */
       NULL,			/* GAdata_ref_incrementor data_ref_incrementor */
       polynomial_score,		/* GAevaluate             evaluate */
       polynomial_seed,		/* GAseed                 seed */
       NULL,			/* GAadapt                adapt */
       NULL,			/* GAselect_one           select_one */
       NULL,			/* GAselect_two           select_two */
       ga_mutate_double_singlepoint_drift,	/* GAmutate	mutate */
       NULL,			/* GAcrossover            crossover */
       NULL,			/* GAreplace              replace */
       NULL			/* vpointer	User data */
       );

  ga_population_set_simplex_parameters(
       pop,				/* population		*pop */
       4,				/* const int		num_dimensions */
       0.5,				/* const double         Initial step size. */
       polynomial_to_double,			/* const GAto_double	to_double */
       polynomial_from_double			/* const GAfrom_double	from_double */
       );

  /* Evaluate and sort the initial population members (i.e. select best of 50 random solutions. */
  ga_population_score_and_sort(pop);

  /* Use the best population member. */
  solution = ga_get_entity_from_rank(pop, 0);

  ga_simplex(
       pop,				/* population		*pop */
       solution,			/* entity		*solution */
       1000				/* const int		max_iterations */
       );

  ga_extinction (pop);

  exit (EXIT_SUCCESS);
}
//******************************************************************************

//------------------------------------------------------------------------------
struct strategies_t
  {
  char			*label; 
  ga_de_strategy_type	strategy;
  ga_de_crossover_type	crossover;
  int			num_perturbed;
  double		crossover_factor;
  double		weighting_factor;
  double		weighting_factor2;
  };

static struct strategies_t _de_strategy[]={
  {"DE/best/1/exp (DE0)",    GA_DE_STRATEGY_BEST,       GA_DE_CROSSOVER_EXPONENTIAL, 1, 0.8, 0.5, 0.5 },
  {"DE/best/1/exp (DE0)",    GA_DE_STRATEGY_BEST,       GA_DE_CROSSOVER_EXPONENTIAL, 1, 0.8, 2.0, 0.0 },
  {"DE/best/2/exp",          GA_DE_STRATEGY_BEST,       GA_DE_CROSSOVER_EXPONENTIAL, 2, 0.8, 0.5, 0.5 },
  {"DE/best/2/exp",          GA_DE_STRATEGY_BEST,       GA_DE_CROSSOVER_EXPONENTIAL, 2, 0.8, 2.0, 0.0 },
  {"'DE/best/3/exp'",        GA_DE_STRATEGY_BEST,       GA_DE_CROSSOVER_EXPONENTIAL, 3, 0.8, 0.5, 0.5 },
  {"'DE/best/3/exp'",        GA_DE_STRATEGY_BEST,       GA_DE_CROSSOVER_EXPONENTIAL, 3, 0.8, 2.0, 0.0 },
  {"DE/rand/1/exp (DE1)",    GA_DE_STRATEGY_RAND,       GA_DE_CROSSOVER_EXPONENTIAL, 1, 0.8, 0.5, 0.5 },
  {"DE/rand/1/exp (DE1)",    GA_DE_STRATEGY_RAND,       GA_DE_CROSSOVER_EXPONENTIAL, 1, 0.8, 2.0, 0.0 },
  {"DE/rand/2/exp",          GA_DE_STRATEGY_RAND,       GA_DE_CROSSOVER_EXPONENTIAL, 2, 0.8, 0.5, 0.5 },
  {"DE/rand/2/exp",          GA_DE_STRATEGY_RAND,       GA_DE_CROSSOVER_EXPONENTIAL, 2, 0.8, 2.0, 0.0 },
  {"'DE/rand/3/exp'",        GA_DE_STRATEGY_RAND,       GA_DE_CROSSOVER_EXPONENTIAL, 3, 0.8, 0.5, 0.5 },
  {"'DE/rand/3/exp'",        GA_DE_STRATEGY_RAND,       GA_DE_CROSSOVER_EXPONENTIAL, 3, 0.8, 2.0, 0.0 },
  {"DE/rand-to-best/1/exp",  GA_DE_STRATEGY_RANDTOBEST, GA_DE_CROSSOVER_EXPONENTIAL, 1, 0.8, 0.5, 0.5 },
  {"DE/rand-to-best/1/exp",  GA_DE_STRATEGY_RANDTOBEST, GA_DE_CROSSOVER_EXPONENTIAL, 1, 0.8, 2.0, 0.0 },
  {"'DE/rand-to-best/2/exp'",GA_DE_STRATEGY_RANDTOBEST, GA_DE_CROSSOVER_EXPONENTIAL, 2, 0.8, 0.5, 0.5 },
  {"'DE/rand-to-best/2/exp'",GA_DE_STRATEGY_RANDTOBEST, GA_DE_CROSSOVER_EXPONENTIAL, 2, 0.8, 2.0, 0.0 },
  {"DE/best/1/bin",          GA_DE_STRATEGY_BEST,       GA_DE_CROSSOVER_BINOMIAL,    1, 0.8, 0.5, 0.5 },
  {"DE/best/1/bin",          GA_DE_STRATEGY_BEST,       GA_DE_CROSSOVER_BINOMIAL,    1, 0.8, 2.0, 0.0 },
  {"DE/best/2/bin",          GA_DE_STRATEGY_BEST,       GA_DE_CROSSOVER_BINOMIAL,    2, 0.8, 0.5, 0.5 },
  {"DE/best/2/bin",          GA_DE_STRATEGY_BEST,       GA_DE_CROSSOVER_BINOMIAL,    2, 0.8, 2.0, 0.0 },
  {"'DE/best/3/bin'",        GA_DE_STRATEGY_BEST,       GA_DE_CROSSOVER_BINOMIAL,    3, 0.8, 0.5, 0.5 },
  {"'DE/best/3/bin'",        GA_DE_STRATEGY_BEST,       GA_DE_CROSSOVER_BINOMIAL,    3, 0.8, 2.0, 0.0 },
  {"DE/rand/1/bin",          GA_DE_STRATEGY_RAND,       GA_DE_CROSSOVER_BINOMIAL,    1, 0.8, 0.5, 0.5 },
  {"DE/rand/1/bin",          GA_DE_STRATEGY_RAND,       GA_DE_CROSSOVER_BINOMIAL,    1, 0.8, 2.0, 0.0 },
  {"DE/rand/2/bin",          GA_DE_STRATEGY_RAND,       GA_DE_CROSSOVER_BINOMIAL,    2, 0.8, 0.5, 0.5 },
  {"DE/rand/2/bin",          GA_DE_STRATEGY_RAND,       GA_DE_CROSSOVER_BINOMIAL,    2, 0.8, 2.0, 0.0 },
  {"'DE/rand/3/bin'",        GA_DE_STRATEGY_RAND,       GA_DE_CROSSOVER_BINOMIAL,    3, 0.8, 0.5, 0.5 },
  {"'DE/rand/3/bin'",        GA_DE_STRATEGY_RAND,       GA_DE_CROSSOVER_BINOMIAL,    3, 0.8, 2.0, 0.0 },
  {"DE/rand-to-best/1/bin",  GA_DE_STRATEGY_RANDTOBEST, GA_DE_CROSSOVER_BINOMIAL,    1, 0.8, 0.5, 0.5 },
  {"DE/rand-to-best/1/bin",  GA_DE_STRATEGY_RANDTOBEST, GA_DE_CROSSOVER_BINOMIAL,    1, 0.8, 2.0, 0.0 },
  {"'DE/rand-to-best/2/bin'",GA_DE_STRATEGY_RANDTOBEST, GA_DE_CROSSOVER_BINOMIAL,    2, 0.8, 0.5, 0.5 },
  {"'DE/rand-to-best/2/bin'",GA_DE_STRATEGY_RANDTOBEST, GA_DE_CROSSOVER_BINOMIAL,    2, 0.8, 2.0, 0.0 },
  { NULL, 0, 0, 0, 0.0, 0.0 } };

//------------------------------------------------------------------------------
// Generation callback
//------------------------------------------------------------------------------
boolean 
_de_polynomial_generation_callback (int generation, population *pop)
{
  /*
    * This is a easy method for implementing randomly selected
    * scaling factor (F in original paper) for each generation, as
    * suggested in:
    *
    * Karaboga D., Okdem, S. "A simple and global optimization algorithm
    * for engineering problems: differential evolution algorithm",
    * Elec. Engin. 12:53-60 (2004).
    *
    * Uncomment, if desired.
    */
  /*
    pop->de_params->weighting_factor = random_double_range(-2.0, 2.0);
    */

  /*
    * Write rank 1 solution every tenth generation.  Note, that this is
    * not neccesarily the best solution because DE doesn't require the
    * population to be sorted, as genetic algorithms usually do.
    */
  int i_generation = 10;

  polynomial_generation_callback (generation, pop, i_generation);

  return TRUE;
}
//------------------------------------------------------------------------------ 
//  polynomial_de.c
//  Synopsis:	An example program for GAUL demonstrating use
//		of the differential evolution algorithm.
//------------------------------------------------------------------------------
int 
_de_main (int argc, char **argv)
{
  population	*pop;		/* Population of solutions. */
  int		 i=0;		/* Loop variable over strategies. */

  random_seed (23091975);

  log_init (LOG_NORMAL, NULL, NULL, FALSE);

  while (_de_strategy[i].label != NULL) {

    if (_de_strategy[i].weighting_factor != _de_strategy[i].weighting_factor2) {
      printf ("Strategy %s ; C = %f ; F = rand( %f, %f )\n",
              _de_strategy[i].label,
              _de_strategy[i].crossover_factor,
              _de_strategy[i].weighting_factor, _de_strategy[i].weighting_factor2);
    } else {
      printf ("Strategy %s ; C = %f ; F = %f\n",
              _de_strategy[i].label,
              _de_strategy[i].crossover_factor,
              _de_strategy[i].weighting_factor);
    }

    pop = ga_genesis_double(
         40,			/* const int              population_size */
         1,			/* const int              num_chromo */
         4,			/* const int              len_chromo */
         _de_polynomial_generation_callback,/* GAgeneration_hook      generation_hook */
         NULL,			/* GAiteration_hook       iteration_hook */
         NULL,			/* GAdata_destructor      data_destructor */
         NULL,			/* GAdata_ref_incrementor data_ref_incrementor */
         polynomial_score,		/* GAevaluate             evaluate */
         polynomial_seed,		/* GAseed                 seed */
         NULL,			/* GAadapt                adapt */
         NULL,			/* GAselect_one           select_one */
         NULL,			/* GAselect_two           select_two */
         NULL,			/* GAmutate               mutate */
         NULL,			/* GAcrossover            crossover */
         NULL,			/* GAreplace              replace */
         NULL			/* vpointer               User data */
         );

    ga_population_set_differentialevolution_parameters(
        pop, _de_strategy[i].strategy, _de_strategy[i].crossover,
        _de_strategy[i].num_perturbed, _de_strategy[i].weighting_factor, 
        _de_strategy[i].weighting_factor2,
        _de_strategy[i].crossover_factor
        );

    ga_differentialevolution(
         pop,				/* population	*pop */
         50				/* const int	max_generations */
         );

    printf ( "Final: A = %f B = %f C = %f D = %f (fitness = %f)\n",
            ((double *)pop->entity_iarray[0]->CH)[0],
            ((double *)pop->entity_iarray[0]->CH)[1],
            ((double *)pop->entity_iarray[0]->CH)[2],
            ((double *)pop->entity_iarray[0]->CH)[3],
            pop->entity_iarray[0]->fitness );

    ga_extinction (pop);

    i++;
    }

  exit (EXIT_SUCCESS);
}
//------------------------------------------------------------------------------
// 
//------------------------------------------------------------------------------
int 
main (int argc, char **argv)
{

  if (argc !=2 ) 
    exit (EXIT_SUCCESS);

  if (!strcmp(argv[1], "ga"))  _ga_main (argc, argv);
  if (!strcmp(argv[1], "sa"))  _sa_main (argc, argv);
  if (!strcmp(argv[1], "sd"))  _sd_main (argc, argv);
  if (!strcmp(argv[1], "simplex"))  _simplex_main (argc, argv);
  if (!strcmp(argv[1], "de"))  _de_main (argc, argv);
  //else 
  //  printf ("RRRRRRRR \n");

  exit (EXIT_SUCCESS);
}
//------------------------------------------------------------------------------
//******************************************************************************


