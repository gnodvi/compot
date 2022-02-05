/*******************************************************************************
  ga_x_tester.c

*******************************************************************************/

//#include "c_all_util.h"
#include "gaul.h"

//#include "l_test_LIB.h"
//------------------------------------------------------------------------------

boolean _test_score (population *pop, entity *this_entity);
boolean _test_seed (population *pop, entity *adam);
boolean _test_generation_callback (int generation, population *pop);

boolean _test_to_double (population *pop, entity *this_entity, double *array);
boolean _test_from_double (population *pop, entity *this_entity, double *array);
boolean _test_iteration_callback (int iteration, entity *solution);

double 
_test_analytical_gradient (population *pop, entity *this_entity, double *params, double *grad);

/*******************************************************************************

*******************************************************************************/

//#include "gaul.h"
//#include "l_test_LIB.h"

//------------------------------------------------------------------------------
//  synopsis:	Fitness function.
//------------------------------------------------------------------------------
/* static */ boolean 
_test_score (population *pop, entity *this_entity)
{
  double    A, B, C, D;	/* Parameters. */

  A = ((double *) this_entity->chromosome[0]) [0];
  B = ((double *) this_entity->chromosome[0]) [1];
  C = ((double *) this_entity->chromosome[0]) [2];
  D = ((double *) this_entity->chromosome[0]) [3];

  ga_entity_set_fitness (this_entity, 
     - (fabs(0.75-A) + SQU(0.95-B) + fabs(CUBE(0.23-C)) + FOURTH_POW(0.71-D))
     );

  return TRUE;
}
//------------------------------------------------------------------------------
//  synopsis:	Seed genetic data.
//------------------------------------------------------------------------------
/* static */ boolean 
_test_seed (population *pop, entity *adam)
{

/* Checks. */
  if (!pop)  die ("Null pointer to population structure passed.");
  if (!adam) die ("Null pointer to entity structure passed.");

/* Seeding. */
  ((double *) adam->chromosome[0]) [0] = random_double (2.0);
  ((double *) adam->chromosome[0]) [1] = random_double (2.0);
  ((double *) adam->chromosome[0]) [2] = random_double (2.0);
  ((double *) adam->chromosome[0]) [3] = random_double (2.0);

  return TRUE;
}
//------------------------------------------------------------------------------
//  synopsis:	Generation callback
//------------------------------------------------------------------------------
/* static */ boolean 
_test_generation_callback (int generation, population *pop)
{
  entity  *best;   /* Fittest entity. */
  best = ga_get_entity_from_rank (pop, 0);

/*   printf ("%2d: A= % 4.2f B= % 4.2f C= % 4.2f D= % 4.2f :  fitness = % 4.2f \n", */
/*             generation, */
/*             ((double *) best->chromosome[0]) [0], */
/*             ((double *) best->chromosome[0]) [1], */
/*             ((double *) best->chromosome[0]) [2], */
/*             ((double *) best->chromosome[0]) [3], */
/*             ga_entity_get_fitness (best) */
/*           ); */

  printf ("%3d  : A = %f B = %f C = %f D = %f (fitness = %f)\n",
            generation,
            ((double *) best->chromosome[0]) [0],
            ((double *) best->chromosome[0]) [1],
            ((double *) best->chromosome[0]) [2],
            ((double *) best->chromosome[0]) [3],
            ga_entity_get_fitness (best)
          );

  return TRUE;
}
//------------------------------------------------------------------------------
//  synopsis:     Convert to double array.
//------------------------------------------------------------------------------
boolean 
_test_to_double (population *pop, entity *this_entity, double *array)
{

  if (!pop)         die ("Null pointer to population structure passed.");
  if (!this_entity) die ("Null pointer to entity structure passed.");

  array[0] = ((double *)this_entity->chromosome[0]) [0];
  array[1] = ((double *)this_entity->chromosome[0]) [1];
  array[2] = ((double *)this_entity->chromosome[0]) [2];
  array[3] = ((double *)this_entity->chromosome[0]) [3];

  return TRUE;
}
//------------------------------------------------------------------------------
//  synopsis:     Convert from double array.
//------------------------------------------------------------------------------
boolean 
_test_from_double (population *pop, entity *this_entity, double *array)
{

  if (!pop) die ("Null pointer to population structure passed.");
  if (!this_entity) die ("Null pointer to entity structure passed.");

  if (!this_entity->chromosome) die ("Entity has no chromsomes.");

  ((double *) this_entity->chromosome[0]) [0] = array[0];
  ((double *) this_entity->chromosome[0]) [1] = array[1];
  ((double *) this_entity->chromosome[0]) [2] = array[2];
  ((double *) this_entity->chromosome[0]) [3] = array[3];

  return TRUE;
}
//------------------------------------------------------------------------------
//  synopsis:	Generation callback
//------------------------------------------------------------------------------
boolean 
_test_iteration_callback (int iteration, entity *solution)
{

  printf ( "%d: A = %f B = %f C = %f D = %f (fitness = %f)\n",
          iteration,
          ((double *) solution->chromosome[0]) [0],
          ((double *) solution->chromosome[0]) [1],
          ((double *) solution->chromosome[0]) [2],
          ((double *) solution->chromosome[0]) [3],
          solution->fitness );
  
  return TRUE;
}
//------------------------------------------------------------------------------
//  synopsis:     Calculate gradients analytically.
//------------------------------------------------------------------------------
double 
_test_analytical_gradient (population *pop, entity *this_entity, double *params, double *grad)
{
  double    grms = 0.0;	 /* RMS gradient. */
  double    A, B, C, D;	 /* The parameters. */
  double    g0, g1, g2, g3;

  if (! pop)         die ("Null pointer to population structure passed.");
  if (! this_entity) die ("Null pointer to entity structure passed.");

  A = params[0];
  B = params[1];
  C = params[2];
  D = params[3];

  g0 = A > 0.75+TINY ? -1.0 : ( A < 0.75-TINY ? 1.0 : 0.0 );
  g1 = (0.95 - B);
  g2 = C > 0.23 ? -SQU(0.23 - C) : SQU(0.23 - C);
  g3 = CUBE (0.71 - D);

  grad[0] = g0 ;
  grad[1] = g1 ;
  grad[2] = g2 ;
  grad[3] = g3 ;

  grms = sqrt (g0*g0 + g1*g1 + g2*g2 + g3*g3);

  return grms;
}
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------


//******************************************************************************



//******************************************************************************
/* To test+time these functions, compile with something like:
   gcc ga_qsort.c -DGA_QSORT_TIME -DGA_QSORT_COMPILE_MAIN ga_core.o \
     -o qsort `gtk-config --cflags` \
     -DNO_TRACE -DMEMORY_ALLOC_DEBUG \
     -DQSORT_DEBUG=3
 */
//******************************************************************************
/* #ifdef GA_QSORT_COMPILE_MAIN */
/* int main(int argc, char **argv) */
/* #else */
//------------------------------------------------------------------------------
boolean ga_qsort_test (void)
  /* #endif */
{
  int		i;		/* Loop variable */
  population	*pop=NULL;	/* Test population */
  
  //plog(LOG_NORMAL, "GENNA");
  
  printf ("1... \n");
  pop = ga_population_new (50000, /* 4, !!!??? */ 32);
  
  printf ("2... \n");
  /* Randomly assigned fitnesses */
  for (i=0; i<50000; i++)
  {
    pop->entity_array[i]->fitness = (double) rand()/RAND_MAX;
    pop->entity_iarray[i] = pop->entity_array[i];
  }
  pop->size=50000;
  
  printf ("3... \n");
  plog(LOG_NORMAL, "Sorting random list.");
  sort_population (pop);
  
  plog(LOG_NORMAL, "Sorting ordered list.");
  sort_population(pop);
  
  /* Reverse population */
  for (i=0; i<50000/2; i++)
    swap_e(pop->entity_iarray[i],pop->entity_iarray[24999-i]);
  
  plog(LOG_NORMAL, "Sorting reverse-ordered list.");
  sort_population(pop);
  
  /* Write list */
  /*
    for (i=0; i<50000; i++)
    printf("%6d: %f\n", i, pop->entity_iarray[i]->fitness);
    */
  
  /* #ifdef GA_QSORT_COMPILE_MAIN */
  /*   exit(EXIT_SUCCESS); */
  /* #else */
  return TRUE;
  /* #endif */
}
//------------------------------------------------------------------------------
//  Synopsis:	Test program for GAUL's basic genetic algorithm.
//
//		This program aims to solve a function of the form
//		(0.75-A) + (0.95-B)^2 + (0.23-C)^3 + (0.71-D)^4 = 0
//------------------------------------------------------------------------------
void 
test_ga (int argc, char **argv)
{
  population		*pop;	  /* Population of solutions. */

  int  population_size;
  int  max_generations;

  parse_opts (argc, argv, &population_size, &max_generations,  200, 500);

  printf ("\n");  

  random_seed (23091975);


  pop = ga_genesis_double (
       population_size,		  /* const int              population_size      */
       1,			  /* const int              num_chromo           */
       4,			  /* const int              len_chromo           */
       _test_generation_callback, /* GAgeneration_hook      generation_hook      */
       NULL,			  /* GAiteration_hook       iteration_hook       */
       NULL,			  /* GAdata_destructor      data_destructor      */
       NULL,			  /* GAdata_ref_incrementor data_ref_incrementor */
       _test_score,		  /* GAevaluate             evaluate             */
       _test_seed,		  /* GAseed                 seed                 */
       NULL,			  /* GAadapt                adapt                */
       ga_select_one_bestof2,	           /* GAselect_one           select_one  */
       ga_select_two_bestof2,	           /* GAselect_two           select_two  */
       ga_mutate_double_singlepoint_drift, /* GAmutate               mutate      */
       ga_crossover_double_doublepoints,   /* GAcrossover            crossover   */
       NULL,			           /* GAreplace              replace     */
       NULL			           /* vpointer	User data                */
       );


  ga_population_set_parameters(
       pop,				/* population      *pop            */
       GA_SCHEME_DARWIN,		/* const ga_scheme_type     scheme */
       GA_ELITISM_PARENTS_SURVIVE,	/* const ga_elitism_type   elitism */
       0.8,				/* double  crossover               */
       0.2,				/* double  mutation                */
       0.0      		        /* double  migration               */
       );

  ga_evolution (
       pop,				/* population	*pop            */
       max_generations		       	/* const int	max_generations */
       );

  ga_extinction (pop);

  //if (is_print) {
  printf ("\n");  
  //}

  return;
  //exit (EXIT_SUCCESS);
}
//------------------------------------------------------------------------------
//******************************************************************************
/*
 * The solution string.
 */
static char *target_text="When we reflect on this struggle, we may console ourselves with the full belief, that the war of nature is not incessant, that no fear is felt, that death is generally prompt, and that the vigorous, the healthy, and the happy survive and multiply.";


//------------------------------------------------------------------------------
//  Score solution.
//------------------------------------------------------------------------------
boolean 
struggle_score (population *pop, entity *entity)
{
  int		k;		/* Loop variable over all alleles. */

  entity->fitness = 0.0;

  /* Loop over alleles in chromosome. */
  for (k = 0; k < pop->len_chromosomes; k++)
  {
    if ( ((char *)entity->chromosome[0])[k] == target_text[k])
      entity->fitness+=1.0;
    /*
      * Component to smooth function, which helps a lot in this case:
      * Comment it out if you like.
      */
    entity->fitness += (127.0-abs((int)((char *)entity->chromosome[0])[k]-target_text[k]))/50.0;
  }

  return TRUE;
}
//------------------------------------------------------------------------------
//  Write usage details.
//------------------------------------------------------------------------------
void 
write_usage (void)
{
  
  printf ("\n"
         "saveload ╘2002-2004, \"Stewart Adcock\" <stewart@linux-domain.com>\n"
         "\n");

  printf ("Usage: saveload [-n INTEGER] [-i FILENAME] -o FILENAME\n"
         "-o FILENAME   Write a population file to FILENAME.\n"
         "-i FILENAME   Read population from FILENAME, otherwise create a new population.\n"
         "-n INTEGER    Number of generations to perform.  [default=10]\n"
         "\n");

  return;
}
//------------------------------------------------------------------------------
void 
test_saveload (int argc, char **argv)
  {
  population	*pop=NULL;		/* Population of solutions. */
  char		*filename_in=NULL;	/* Input filename. */
  char		*filename_out=NULL;	/* Output filename. */
  int		i;			/* Loop variable over command-line arguments. */
  int		generations=10;		/* Number of generations to perform. */
  char		*beststring=NULL;	/* Human readable form of best solution. */
  size_t	beststrlen=0;		/* Length of beststring. */

  random_seed (42);

  /*
    * Parse command-line.  Expect '-i FILENAME' for a population to read,
    * otherwise a new population will be created.
    * '-o FILENAME' is absolutely required to specify a file to write to.
    * If we don't get these, then we will write the options.
    */
  if (argc < 2) {
    write_usage ();
    exit (0);
    }

  //printf ("1... \n");

  for (i=1; i<argc; i++) {

    //printf ("2... \n");

    if (strcmp(argv[i], "-i") == 0) { /* Read pop. */
      i++;
      if (i==argc) 
        {
        printf("Input filename not specified.\n");
        write_usage();
        exit(0);
        }
      filename_in = argv[i];
      printf ("Input filename set to \"%s\"\n", filename_in);
      }

    else if (strcmp(argv[i], "-o")==0)
      {	/* Out pop. */
      i++;
      if (i==argc) {
        printf ("Output filename not specified.\n");
        write_usage ();
        exit (0);
      }
      filename_out = argv[i];
      printf ("Output filename set to \"%s\"\n", filename_out);
      }

    else if (strcmp(argv[i], "-n")==0)
      { /* Number of generations requested. */
      i++;
      if (i==argc)
        {
        printf("Number of generations not specified.\n");
        write_usage();
        exit(0);
        }
      generations = atoi(argv[i]);
      printf("Number of generations set to %d.\n", generations);
      }

    else
      {	/* Error parsing args. */
      printf ("Unable to parse command-line argument \"%s\"\n", argv[i]);
      write_usage ();
      exit (0);
      }
    }

/*
 * Check that we had the required inputs.
 */
  if (filename_out == NULL)
    {
    printf("No output filename was specified.\n");
    write_usage();
    exit(0);
    }

/*
 * Read or create population.
 */
  if (filename_in == NULL)
    {
    pop = ga_genesis_char(
       100,			/* const int              population_size */
       1,			/* const int              num_chromo */
       strlen(target_text),	/* const int              len_chromo */
       NULL,		 	/* GAgeneration_hook      generation_hook */
       NULL,			/* GAiteration_hook       iteration_hook */
       NULL,			/* GAdata_destructor      data_destructor */
       NULL,			/* GAdata_ref_incrementor data_ref_incrementor */
       struggle_score,			/* GAevaluate             evaluate */
       ga_seed_printable_random,	/* GAseed                 seed */
       NULL,				/* GAadapt                adapt */
       ga_select_one_roulette,		/* GAselect_one           select_one */
       ga_select_two_roulette,		/* GAselect_two           select_two */
       ga_mutate_printable_singlepoint_drift,	/* GAmutate               mutate */
       ga_crossover_char_allele_mixing,	/* GAcrossover            crossover */
       NULL,			/* GAreplace replace */
       NULL			/* vpointer	User data */
            );

    ga_population_set_parameters(
       pop,				/* population      *pop */
       GA_SCHEME_DARWIN,		/* const ga_scheme_type    scheme */
       GA_ELITISM_PARENTS_SURVIVE,	/* const ga_elitism_type   elitism */
       1.0,				/* double  crossover */
       0.1,				/* double  mutation */
       0.0				/* double  migration */
                              );
    }
  else
    {
    pop = ga_population_read(filename_in);
    pop->evaluate = struggle_score;	/* Custom functions can't be saved and
                                         * therefore "pop->evaluate" must be
					 * defined manually.  Likewise, if a
					 * custom crossover routine was used, for
					 * example, then that would also need
					 * to be manually defined here.
					 */
    }

  ga_evolution(
       pop,				/* population              *pop */
       generations			/* const int               max_generations */
              );

  printf("The final solution with seed = %d was:\n", i);
  beststring = ga_chromosome_char_to_string (pop, ga_get_entity_from_rank(pop,0), 
                                             beststring, &beststrlen);
  printf("%s\n", beststring);
  printf("With score = %f\n", ga_entity_get_fitness(ga_get_entity_from_rank(pop,0)) );

  ga_population_write(pop, filename_out);

  printf("Population has been saved as \"%s\"\n", filename_out);

  ga_extinction(pop);

  s_free(beststring);

  return;
  //exit(EXIT_SUCCESS);
  }
//******************************************************************************
//******************************************************************************
//  Synopsis:	Test program for GAUL's simplex algorithm.
//
//		This program aims to solve a function of the form
//		(0.75-A) + (0.95-B)^2 + (0.23-C)^3 + (0.71-D)^4 = 0
//------------------------------------------------------------------------------
void 
test_simplex_1 ()
{
  population  *pop;			/* Population of solutions. */
  entity      *solution;		/* Optimised solution.      */

  random_seed (23091975);

  pop = ga_genesis_double (
       50,			 /* const int              population_size         */
       1,			 /* const int              num_chromo              */
       4,			 /* const int              len_chromo              */
       NULL,			 /* GAgeneration_hook      generation_hook         */
       _test_iteration_callback, /* GAiteration_hook       iteration_hook          */
       NULL,			 /* GAdata_destructor      data_destructor         */
       NULL,			 /* GAdata_ref_incrementor data_ref_incrementor    */
       _test_score,		 /* GAevaluate             evaluate                */
       _test_seed,		 /* GAseed                 seed                    */
       NULL,			 /* GAadapt                adapt                   */
       NULL,			 /* GAselect_one           select_one              */
       NULL,			 /* GAselect_two           select_two              */
       ga_mutate_double_singlepoint_drift, /* GAmutate	   mutate                  */
       NULL,			 /* GAcrossover            crossover               */
       NULL,			 /* GAreplace              replace                 */
       NULL			 /* vpointer	           User data               */
       );

  ga_population_set_simplex_parameters (
       pop,				/* population		*pop               */
       4,				/* const int		num_dimensions     */
       0.5,				/* const double         Initial step size. */
       _test_to_double,			/* const GAto_double	to_double          */
       _test_from_double		/* const GAfrom_double	from_double        */
       );

  /* Evaluate and sort the initial population members (i.e. select best of 50 random solutions. */
  ga_population_score_and_sort (pop);

  /* Use the best population member. */
  solution = ga_get_entity_from_rank (pop, 0);

  ga_simplex (
       pop,				/* population		*pop           */
       solution,			/* entity		*solution      */
       10000				/* const int		max_iterations */
       );

  ga_extinction (pop);

  return;
  //exit (EXIT_SUCCESS);
}
//------------------------------------------------------------------------------
void 
test_simplex_2 ()
{
  population		*pop;			/* Population of solutions.     */
  entity		*solution;		/* Optimised solution.          */

  random_seed (23091975);

  pop = ga_genesis_double (
       50,			 /* const int              population_size      */
       1,			 /* const int              num_chromo           */
       4,			 /* const int              len_chromo           */
       NULL,			 /* GAgeneration_hook      generation_hook      */
       _test_iteration_callback, /* GAiteration_hook       iteration_hook       */
       NULL,			 /* GAdata_destructor      data_destructor      */
       NULL,			 /* GAdata_ref_incrementor data_ref_incrementor */
       _test_score,		 /* GAevaluate             evaluate             */
       _test_seed,		 /* GAseed                 seed                 */
       NULL,			 /* GAadapt                adapt                */
       NULL,			 /* GAselect_one           select_one           */
       NULL,			 /* GAselect_two           select_two           */
       ga_mutate_double_singlepoint_drift,  /* GAmutate	mutate                  */
       NULL,			 /* GAcrossover            crossover            */
       NULL,			 /* GAreplace              replace              */
       NULL			 /* vpointer	           User data            */
       );

  ga_population_set_simplex_parameters (
       pop,			 /* population		   *pop                 */
       4,			 /* const int		   num_dimensions       */
       0.5,			 /* const double           Initial step size.   */
       _test_to_double,		 /* const GAto_double	   to_double            */
       _test_from_double	 /* const GAfrom_double	   from_double          */
       );

  /* Evaluate and sort the initial population members (i.e. select best of 50 random solutions. */
  ga_population_score_and_sort (pop);

  /* Use the best population member. */
  solution = ga_get_entity_from_rank (pop, 0);

  ga_simplex (
       pop,				/* population		*pop           */
       solution,			/* entity		*solution      */
       10000				/* const int		max_iterations */
       );

  ga_extinction (pop);

  return;
  //exit (EXIT_SUCCESS);
}
//******************************************************************************
//------------------------------------------------------------------------------
//  Synopsis:	Test program for GAUL's steepest ascent algorithm.
//
//		This program aims to solve a function of the form
//		(0.75-A) + (0.95-B)^2 + (0.23-C)^3 + (0.71-D)^4 = 0
//------------------------------------------------------------------------------
//
// в чем тут фишка конвертации from и to DOUBLE - не понял!
// 
//------------------------------------------------------------------------------
void 
main_sd1 (/* int argc, char **argv */)
{
  population		*pop;			/* Population of solutions. */
  entity		*solution;		/* Optimised solution.      */

  random_seed (23091975);

  pop = ga_genesis_double (
       50,			 /* const int              population_size      */
       1,			 /* const int              num_chromo           */
       4,			 /* const int              len_chromo           */
       NULL,			 /* GAgeneration_hook      generation_hook      */
       _test_iteration_callback, /* GAiteration_hook       iteration_hook       */
       NULL,			 /* GAdata_destructor      data_destructor      */
       NULL,			 /* GAdata_ref_incrementor data_ref_incrementor */
       _test_score,		 /* GAevaluate             evaluate             */
       _test_seed,		 /* GAseed                 seed                 */
       NULL,			 /* GAadapt                adapt                */
       NULL,			 /* GAselect_one           select_one           */
       NULL,			 /* GAselect_two           select_two           */
       NULL,			 /* GAmutate               mutate               */
       NULL,			 /* GAcrossover            crossover            */
       NULL,			 /* GAreplace              replace              */
       NULL			 /* vpointer               User data            */
       );

  ga_population_set_gradient_parameters (
       pop,				/* population		*pop           */
       _test_to_double,		        /* const GAto_double	to_double      */
       _test_from_double,		/* const GAfrom_double	from_double    */
       _test_analytical_gradient,	/* const GAgradient	gradient       */
       4,				/* const int		num_dimensions */
       0.1				/* const double		step_size      */
       );

  /* Evaluate and sort the initial population members (i.e. select best of 50 random 
    solutions. */

  ga_population_score_and_sort (pop);

  /* Use the best population member. */
  solution = ga_get_entity_from_rank (pop, 0);

  ga_steepestascent (
       pop,				/* population		*pop           */
       solution,			/* entity		*solution      */
       1000				/* const int		max_iterations */
       );

  ga_extinction (pop);

  exit (EXIT_SUCCESS);
}
//------------------------------------------------------------------------------
void 
main_sd2 (int argc, char **argv)
{
  population	 *pop;		  /* Population of solutions. */
  entity	 *solution;	  /* Optimised solution.      */

  random_seed (23091975);

  int population_size ;
  int max_iterations  ;

  parse_opts (argc, argv, &population_size, &max_iterations,  50, 1000);


  if (is_print) {
    printf ("\n");
  }

  pop = ga_genesis_double (
       population_size,		 /* const int              population_size      */
       1,			 /* const int              num_chromo           */
       4,			 /* const int              len_chromo           */
       NULL,			 /* GAgeneration_hook      generation_hook      */
       _test_iteration_callback, /* GAiteration_hook       iteration_hook       */
       NULL,			 /* GAdata_destructor      data_destructor      */
       NULL,			 /* GAdata_ref_incrementor data_ref_incrementor */
       _test_score,		 /* GAevaluate             evaluate             */
       _test_seed,		 /* GAseed                 seed                 */
       NULL,			 /* GAadapt                adapt                */
       NULL,			 /* GAselect_one           select_one           */
       NULL,			 /* GAselect_two           select_two           */
       NULL,			 /* GAmutate               mutate               */
       NULL,			 /* GAcrossover            crossover            */
       NULL,			 /* GAreplace              replace              */
       NULL			 /* vpointer	           User data            */
       );

  ga_population_set_gradient_parameters (
       pop,				/* population		*pop            */
       NULL,				/* const GAto_double	to_double       */
       NULL,				/* const GAfrom_double	from_double     */
       _test_analytical_gradient,	/* const GAgradient	gradient        */
       0,				/* const int		num_dimensions  */
       0.1				/* const double		step_size       */
       );

  //# тут надо так искуссствено?
  //# 
  //ga_population_seed (pop);

  // Evaluate and sort the initial population members (i.e. select best of 50 
  // random solutions.
  //
  ga_population_score_and_sort (pop);

  if (is_print) {
    pop_print (pop);
    printf ("\n");
  }

  // Use the best population member.
  //
  solution = ga_get_entity_from_rank (pop, 0);

  //if (is_print) {
  //  pop_print (pop);
  //  printf ("\n");
  //}

  ga_steepestascent_double (
       pop,			   /* population	*pop           */
       solution,		   /* entity		*solution      */
       max_iterations		   /* const int		max_iterations */
       );

  ga_extinction (pop);

  if (is_print) {
    printf ("\n");
  }

  exit (EXIT_SUCCESS);
}
//------------------------------------------------------------------------------
/*******************************************************************************
  test_de.c

  Synopsis:	Test program for GAUL's differential evolution algorithm.

		This program aims to solve a function of the form
		(0.75-A) + (0.95-B)^2 + (0.23-C)^3 + (0.71-D)^4 = 0

*******************************************************************************/

//#include "gaul.h"
//#include "l_test_LIB.h"

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

//------------------------------------------------------------------------------



//# это едиинчный тест для отладки
//# 
static struct strategies_t strategy_test[] = {
  { "DE/best/1/bin",           GA_DE_STRATEGY_BEST,       GA_DE_CROSSOVER_BINOMIAL,    1, 0.8, 0.5, 0.5 },
  { "DE/rand-to-best/1/bin",   GA_DE_STRATEGY_RANDTOBEST, GA_DE_CROSSOVER_BINOMIAL,    1, 0.8, 0.5, 0.5 },
  { NULL, 0, 0, 0, 0.0, 0.0 } 
};


//# это полный список тестов (оригинальный)
//# 
static struct strategies_t strategy_full_origin[] = {
  
  { "DE/best/1/exp (DE0)",     GA_DE_STRATEGY_BEST,       GA_DE_CROSSOVER_EXPONENTIAL, 1, 0.8, 0.5, 0.5 },
  { "DE/best/1/exp (DE0)",     GA_DE_STRATEGY_BEST,       GA_DE_CROSSOVER_EXPONENTIAL, 1, 0.8, 2.0, 0.0 },
  { "DE/best/2/exp",           GA_DE_STRATEGY_BEST,       GA_DE_CROSSOVER_EXPONENTIAL, 2, 0.8, 0.5, 0.5 },
  
  { "DE/best/2/exp",           GA_DE_STRATEGY_BEST,       GA_DE_CROSSOVER_EXPONENTIAL, 2, 0.8, 2.0, 0.0 },
  { "'DE/best/3/exp'",         GA_DE_STRATEGY_BEST,       GA_DE_CROSSOVER_EXPONENTIAL, 3, 0.8, 0.5, 0.5 },
  { "'DE/best/3/exp'",         GA_DE_STRATEGY_BEST,       GA_DE_CROSSOVER_EXPONENTIAL, 3, 0.8, 2.0, 0.0 },
  { "DE/rand/1/exp (DE1)",     GA_DE_STRATEGY_RAND,       GA_DE_CROSSOVER_EXPONENTIAL, 1, 0.8, 0.5, 0.5 },
  { "DE/rand/1/exp (DE1)",     GA_DE_STRATEGY_RAND,       GA_DE_CROSSOVER_EXPONENTIAL, 1, 0.8, 2.0, 0.0 },
  { "DE/rand/2/exp",           GA_DE_STRATEGY_RAND,       GA_DE_CROSSOVER_EXPONENTIAL, 2, 0.8, 0.5, 0.5 },
  { "DE/rand/2/exp",           GA_DE_STRATEGY_RAND,       GA_DE_CROSSOVER_EXPONENTIAL, 2, 0.8, 2.0, 0.0 },
  { "'DE/rand/3/exp'",         GA_DE_STRATEGY_RAND,       GA_DE_CROSSOVER_EXPONENTIAL, 3, 0.8, 0.5, 0.5 },
  { "'DE/rand/3/exp'",         GA_DE_STRATEGY_RAND,       GA_DE_CROSSOVER_EXPONENTIAL, 3, 0.8, 2.0, 0.0 },
  { "DE/rand-to-best/1/exp",   GA_DE_STRATEGY_RANDTOBEST, GA_DE_CROSSOVER_EXPONENTIAL, 1, 0.8, 0.5, 0.5 },
  { "DE/rand-to-best/1/exp",   GA_DE_STRATEGY_RANDTOBEST, GA_DE_CROSSOVER_EXPONENTIAL, 1, 0.8, 2.0, 0.0 },
  { "'DE/rand-to-best/2/exp'", GA_DE_STRATEGY_RANDTOBEST, GA_DE_CROSSOVER_EXPONENTIAL, 2, 0.8, 0.5, 0.5 },
  { "'DE/rand-to-best/2/exp'", GA_DE_STRATEGY_RANDTOBEST, GA_DE_CROSSOVER_EXPONENTIAL, 2, 0.8, 2.0, 0.0 },
  
  { "DE/best/1/bin",           GA_DE_STRATEGY_BEST,       GA_DE_CROSSOVER_BINOMIAL,    1, 0.8, 0.5, 0.5 },
  { "DE/best/1/bin",           GA_DE_STRATEGY_BEST,       GA_DE_CROSSOVER_BINOMIAL,    1, 0.8, 2.0, 0.0 },
  { "DE/best/2/bin",           GA_DE_STRATEGY_BEST,       GA_DE_CROSSOVER_BINOMIAL,    2, 0.8, 0.5, 0.5 },
  { "DE/best/2/bin",           GA_DE_STRATEGY_BEST,       GA_DE_CROSSOVER_BINOMIAL,    2, 0.8, 2.0, 0.0 },
  { "'DE/best/3/bin'",         GA_DE_STRATEGY_BEST,       GA_DE_CROSSOVER_BINOMIAL,    3, 0.8, 0.5, 0.5 },
  { "'DE/best/3/bin'",         GA_DE_STRATEGY_BEST,       GA_DE_CROSSOVER_BINOMIAL,    3, 0.8, 2.0, 0.0 },
  { "DE/rand/1/bin",           GA_DE_STRATEGY_RAND,       GA_DE_CROSSOVER_BINOMIAL,    1, 0.8, 0.5, 0.5 },
  { "DE/rand/1/bin",           GA_DE_STRATEGY_RAND,       GA_DE_CROSSOVER_BINOMIAL,    1, 0.8, 2.0, 0.0 },
  { "DE/rand/2/bin",           GA_DE_STRATEGY_RAND,       GA_DE_CROSSOVER_BINOMIAL,    2, 0.8, 0.5, 0.5 },
  { "DE/rand/2/bin",           GA_DE_STRATEGY_RAND,       GA_DE_CROSSOVER_BINOMIAL,    2, 0.8, 2.0, 0.0 },
  { "'DE/rand/3/bin'",         GA_DE_STRATEGY_RAND,       GA_DE_CROSSOVER_BINOMIAL,    3, 0.8, 0.5, 0.5 },
  { "'DE/rand/3/bin'",         GA_DE_STRATEGY_RAND,       GA_DE_CROSSOVER_BINOMIAL,    3, 0.8, 2.0, 0.0 },
  { "DE/rand-to-best/1/bin",   GA_DE_STRATEGY_RANDTOBEST, GA_DE_CROSSOVER_BINOMIAL,    1, 0.8, 0.5, 0.5 },
  { "DE/rand-to-best/1/bin",   GA_DE_STRATEGY_RANDTOBEST, GA_DE_CROSSOVER_BINOMIAL,    1, 0.8, 2.0, 0.0 },
  { "'DE/rand-to-best/2/bin'", GA_DE_STRATEGY_RANDTOBEST, GA_DE_CROSSOVER_BINOMIAL,    2, 0.8, 0.5, 0.5 },
  { "'DE/rand-to-best/2/bin'", GA_DE_STRATEGY_RANDTOBEST, GA_DE_CROSSOVER_BINOMIAL,    2, 0.8, 2.0, 0.0 },
  { NULL, 0, 0, 0, 0.0, 0.0 } 
};


//------------------------------------------------------------------------------
//  synopsis:	Generation callback
//------------------------------------------------------------------------------
static boolean 
test_generation_callback (int generation, population *pop)
{
  //entity	*this_entity;	/* Top ranked entity. */

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
    * Write top ranked solution every tenth generation.  Note, that this
    * is not neccesarily the best solution because DE doesn't require
    * the population to be sorted, as genetic algorithms usually do.
    */

  if ( generation%10 == 0)
  {
    _test_generation_callback (generation, pop);
  }
  
  return TRUE;
}
//******************************************************************************
//------------------------------------------------------------------------------
char *get_strategy_name (ga_de_strategy_type	strategy_type)
{

  if (strategy_type == 1) return ("GA_DE_STRATEGY_BEST"); 
  if (strategy_type == 2) return ("GA_DE_STRATEGY_RAND"); 
  if (strategy_type == 3) return ("GA_DE_STRATEGY_RANDTOBEST"); 

/*   GA_DE_STRATEGY_UNKNOWN    = 0, */
/*   GA_DE_STRATEGY_BEST       = 1, */
/*   GA_DE_STRATEGY_RAND       = 2, */
/*   GA_DE_STRATEGY_RANDTOBEST = 3 */

  return ("GA_DE_STRATEGY_UNKNOWN");
}
//------------------------------------------------------------------------------
char *get_crossover_name (ga_de_crossover_type	crossover)
{

/*   GA_DE_CROSSOVER_UNKNOWN     = 0, */
/*   GA_DE_CROSSOVER_BINOMIAL    = 1, */
/*   GA_DE_CROSSOVER_EXPONENTIAL = 2 */

  if (crossover == 1) return ("GA_DE_CROSSOVER_BINOMIAL"); 
  if (crossover == 2) return ("GA_DE_CROSSOVER_EXPONENTIAL"); 

  return ("GA_DE_CROSSOVER_UNKNOWN");
}
//------------------------------------------------------------------------------
// 
//------------------------------------------------------------------------------
void 
parse_opts (int argc, char **argv, 
            int *p_population_size,   int *p_max_generations,
            int def_population_size,  int def_max_generations
            )
{

  is_print = 0;

  if (argc == 2) { // вызов без параметров, только с одним  "ga_x_tester de"
    
    *p_population_size = def_population_size;
    *p_max_generations = def_max_generations;
    
  } else {
    
    *p_population_size = atoi (argv[2]);
    *p_max_generations = atoi (argv[3]);
    
    if (argc == 5) is_print = 1;    
  }
  
  return;
}
//------------------------------------------------------------------------------
void 
test_de (int argc, char **argv, struct strategies_t *strategy)
{

  int  population_size;
  int  max_generations;

  parse_opts (argc, argv, &population_size, &max_generations,  40, 50);


  population   	*pop;		/*  Population of solutions.       */
  entity       	*best_entity;  	/*  Fittest entity.                */
  int	       	i = 0;		/*  Loop variable over strategies. */

  random_seed (23091975);

  log_init (LOG_NORMAL, NULL, NULL, FALSE);

  printf ("\n");

  char			*label; 
  ga_de_strategy_type	strategy_type;
  ga_de_crossover_type	crossover;
  int			num_perturbed;
  double		crossover_factor;
  double		weighting_factor;
  double		weighting_factor2;

  while (strategy[i].label != NULL)
    {


      printf ( "Strategy %s ; C = %f ; ",
              strategy[i].label, strategy[i].crossover_factor);


      if (strategy[i].weighting_factor != strategy[i].weighting_factor2) {
        printf ( "F = rand( %f, %f )\n",
                strategy[i].weighting_factor, strategy[i].weighting_factor2 );
      } else {        
        printf ( "F = %f\n",
                strategy[i].weighting_factor );
      }
      
      
      // ....................................................................                        
      
      label               = strategy[i].label ; 
      strategy_type       = strategy[i].strategy ;
      crossover           = strategy[i].crossover ;
      num_perturbed       = strategy[i].num_perturbed ;
      crossover_factor    = strategy[i].crossover_factor ;
      weighting_factor    = strategy[i].weighting_factor ;
      weighting_factor2   = strategy[i].weighting_factor2;


      if (is_print) {
        printf ("strategy_parse_and_print ......... \n");
        printf ("\n");
        
        printf ("   label             =  %s \n", label            );  
        printf ("   strategy          =  %s \n", get_strategy_name (strategy_type)); 
        printf ("   crossover         =  %s \n", get_crossover_name (crossover) ); 
        printf ("   num_perturbed     =  %d \n", num_perturbed    ); 
        printf ("   crossover_factor  =  %f \n", crossover_factor ); 
        printf ("   weighting_factor  =  %f \n", weighting_factor );  
        printf ("   weighting_factor2 =  %f \n", weighting_factor2); 
        printf ("\n");
      }

      // ....................................................................                        

      pop = ga_genesis_double (
         population_size,	   /* const int              population_size      */
         1,			   /* const int              num_chromo           */
         4,			   /* const int              len_chromo           */
         test_generation_callback, /* GAgeneration_hook      generation_hook      */
         NULL,			   /* GAiteration_hook       iteration_hook       */
         NULL,			   /* GAdata_destructor      data_destructor      */
         NULL,			   /* GAdata_ref_incrementor data_ref_incrementor */
         _test_score,		   /* GAevaluate             evaluate             */
         _test_seed,		   /* GAseed                 seed                 */
         NULL,			   /* GAadapt                adapt                */
         NULL,			   /* GAselect_one           select_one           */
         NULL,			   /* GAselect_two           select_two           */
         NULL,			   /* GAmutate               mutate               */
         NULL,			   /* GAcrossover            crossover            */
         NULL,			   /* GAreplace              replace              */
         NULL			   /* vpointer               User data            */
         );


      /*     # пока здесь остановимся, осмотримся и распечатаемся: */
      /*     # (похоже инициация-seed еще не выполнялась ?) давай пока тут выполним: */
      // 
      ga_population_seed (pop);
      //
      /*     #exit */
      
      ga_population_set_differentialevolution_parameters (
                                                          pop, strategy_type, crossover,
        num_perturbed, weighting_factor, weighting_factor2,
        crossover_factor
                                                          );
      
      if (is_print) {
        printf ("\n");
      }
      
      //# выполняем основной расчет (поиск минимума)
      //#
      ga_differentialevolution (pop, max_generations);
      
      //# предполагаем, что уже отсортирована популяция ??
      // 
      int best = 0;
      
      best_entity = ga_get_entity_from_rank (pop, best); 
      
      double A = ((double *) best_entity->chromosome[0])[0];
      double B = ((double *) best_entity->chromosome[0])[1];
      double C = ((double *) best_entity->chromosome[0])[2];
      double D = ((double *) best_entity->chromosome[0])[3];

      double F = ga_entity_get_fitness (best_entity);

      if (is_print) {

        printf ("FINAL BEST : numer = %d  fitness = %f \n", best, F);
        printf ("\n");
        
        printf ("   A = %f  ( 0.75 ) \n", A);
        printf ("   B = %f  ( 0.95 ) \n", B);
        printf ("   C = %f  ( 0.23 ) \n", C);
        printf ("   D = %f  ( 0.71 ) \n", D);

      } else {
        
        //entity   *best;          /* Fittest entity. */
        //best = ga_get_entity_from_rank (pop, 0);
        //
        printf ( "Final: A = %f B = %f C = %f D = %f (fitness = %f)\n", A, B, C, D, F);
        printf ("\n");  
      }
      
      if (is_print) {
        printf ("\n");  
      }

      ga_extinction (pop);
      
      i++;
    }
  
  //printf ("\n");

  exit (EXIT_SUCCESS);
}
//------------------------------------------------------------------------------
/*******************************************************************************
  test_moga.c

  Synopsis:   Test program for GAUL's multiobjective genetic
	      algorithm.

	      This program aims to solve a function of the form
	      (0.75-A) + (0.95-B)^2 + (0.23-C)^3 + (0.71-D)^4 = 0

	      The values of the individual terms, A, B, C and D, are
	      the multiobjective terms.

*******************************************************************************/

//#include "gaul.h"
//#include "l_test_LIB.h"

//------------------------------------------------------------------------------
//  synopsis:	Fitness function.
//------------------------------------------------------------------------------
static boolean 
test_score (population *pop, entity *this_entity)
{
  double		A, B, C, D;	/* Parameters. */

  A = ((double *) this_entity->chromosome[0]) [0];
  B = ((double *) this_entity->chromosome[0]) [1];
  C = ((double *) this_entity->chromosome[0]) [2];
  D = ((double *) this_entity->chromosome[0]) [3];

  this_entity->fitvector[0] = fabs (0.75-A);
  this_entity->fitvector[1] = fabs (0.95-B);
  this_entity->fitvector[2] = fabs (0.23-C);
  this_entity->fitvector[3] = fabs (0.71-D);

  this_entity->fitness = 
    - (fabs(0.75-A) + SQU(0.95-B) + fabs(CUBE(0.23-C)) + FOURTH_POW(0.71-D));

  return TRUE;
}
//------------------------------------------------------------------------------
//  synopsis:	Generation callback
//------------------------------------------------------------------------------
static boolean 
moga_test_generation_callback (int generation, population *pop)
{

  entity   *this_entity = ga_get_entity_from_rank (pop, 0);	/* The best entity. */

  printf ("%d: A = %f B = %f C = %f D = %f (fitness = %f) pop_size %d\n",
          generation,
          ((double *)this_entity->chromosome[0]) [0],
          ((double *)this_entity->chromosome[0]) [1],
          ((double *)this_entity->chromosome[0]) [2],
          ((double *)this_entity->chromosome[0]) [3],
          
          ga_entity_get_fitness (this_entity),
          pop->size );
  
  return TRUE;
}
//------------------------------------------------------------------------------
void 
main_common (population *pop, ga_elitism_type elitism)
{

  pop = ga_genesis_double(
       100,			/* const int              population_size      */
       1,			/* const int              num_chromo           */
       4,			/* const int              len_chromo           */
       moga_test_generation_callback,/* GAgeneration_hook      generation_hook      */
       //mgena       _test_generation_callback,/* GAgeneration_hook      generation_hook */
       NULL,			/* GAiteration_hook       iteration_hook       */
       NULL,			/* GAdata_destructor      data_destructor      */
       NULL,			/* GAdata_ref_incrementor data_ref_incrementor */
       test_score,		/* GAevaluate             evaluate             */
       _test_seed,		/* GAseed                 seed                 */
       NULL,			/* GAadapt                adapt                */
       ga_select_one_bestof2,	/* GAselect_one           select_one           */
       ga_select_two_bestof2,	/* GAselect_two           select_two           */
       ga_mutate_double_singlepoint_drift,	/* GAmutate         mutate     */
       ga_crossover_double_doublepoints,	/* GAcrossover      crossover  */
       NULL,			/* GAreplace              replace              */
       NULL			/* vpointer	          User data            */
       );

  ga_population_set_parameters(
       pop,				/* population      *pop            */
       GA_SCHEME_DARWIN,		/* const ga_scheme_type     scheme */
       //GA_ELITISM_BEST_SET_SURVIVE,	/* const ga_elitism_type   elitism */
       elitism,	
       0.8,				/* double  crossover  */
       0.2,				/* double  mutation   */
       0.0      		        /* double  migration  */
       );

  ga_population_set_fitness_dimensions (pop, 4);

  ga_evolution(
       pop,				/* population	*pop            */
       200				/* const int	max_generations */
       );

  ga_extinction (pop);

}
//------------------------------------------------------------------------------
void 
test_moga (/* int argc, char **argv */)
{
  population   *pop = NULL;		/* Population of solutions. */

  random_seed (23091975);

  printf ("Using the Best Set Multiobjective GA varient.\n");
  main_common (pop, GA_ELITISM_BEST_SET_SURVIVE);

  printf ("Using the Pareto Set Multiobjective GA varient.\n");
  main_common (pop, GA_ELITISM_PARETO_SET_SURVIVE);

  return;
  //exit (EXIT_SUCCESS);
}
//------------------------------------------------------------------------------
int 
main (int argc, char **argv)
{

  if (argc < 2 ) {
    printf ("\n");
    printf ("argc < 2 .... \n");
    printf ("\n");
    exit (EXIT_SUCCESS);
  }

  if (0) {
  fprintf (stderr, "\n");
  fprintf (stderr, "DBL_MIN = %f \n", DBL_MIN);
  fprintf (stderr, "DBL_MAX = %f \n", DBL_MAX);
  fprintf (stderr, "\n");
  exit (EXIT_SUCCESS);
  }
  

  char *mode = argv[1];

  if      (! strcmp (mode, "qsort"))     ga_qsort_test ();
  else if (! strcmp (mode, "ga"))        test_ga (argc, argv);

  else if (! strcmp (mode, "io"))        test_saveload (argc-1, argv+1);

  else if (! strcmp (mode, "simplex1"))  test_simplex_1 ();
  else if (! strcmp (mode, "simplex2"))  test_simplex_2 ();

  else if (! strcmp (mode, "sd1"))       main_sd1 ();
  else if (! strcmp (mode, "sd2"))       main_sd2 (argc, argv);
 
  else if (! strcmp (mode, "de"))        test_de (argc, argv, strategy_full_origin);
  else if (! strcmp (mode, "de_test"))   test_de (argc, argv, strategy_test);

  else if (! strcmp (mode, "moga"))      test_moga ();
  else {
    printf ("\n");
    printf ("ERROR mode = %s \n", mode);
    printf ("\n");
  }

  exit (EXIT_SUCCESS);
}
//------------------------------------------------------------------------------

// ga_x_tester  de 
// ga_x_tester  ga 
// ga_x_tester  moga 
// ga_x_tester  sd1 
// ga_x_tester  sd2
// ga_x_tester  simplex1
// ga_x_tester  simplex2 

//******************************************************************************



