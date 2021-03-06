//******************************************************************************
// 
// 
//******************************************************************************


#include <gaul.h>

//------------------------------------------------------------------------------
//  Score solution (Normalised RMSD deviation from values
//  of '5' for all parameters).
//------------------------------------------------------------------------------
static boolean 
all5s_score (population *pop, entity *entity)
{
  int		allele;
  int		k;

  entity->fitness = 0.0;

  // Loop over alleles in chromosome
  // 
  for (k = 0; k < pop->len_chromosomes; k++)
  {
    allele = ((int *) entity->CH)[k];
    entity->fitness += ((5-allele) * (5-allele));
  }

  entity->fitness = sqrt (entity->fitness);

  // Normalize fitness so larger positive values are better
  //
  entity->fitness = 1.0 / (1.0 + entity->fitness);

  return TRUE;
}
//------------------------------------------------------------------------------
// Entity initialisation.
//------------------------------------------------------------------------------
static boolean 
all5s_seed (population *pop, entity *entity)
{
  int  point;  /* Index of allele to seed */

  //printf ("all5s_seed ....... \n");

  for (point = 0; point < pop->len_chromosomes; point++)
  {
    ((int *) entity->CH)[point] = random_int (11);
    //entity->is_double = 0;
  }

  return TRUE;
}
//------------------------------------------------------------------------------
// Mutation of a single parameter with wrapping 0<->10.
//------------------------------------------------------------------------------
static void 
all5s_mutate (population *pop, entity *father, entity *son)
{
  int   i;                             /* Loop variable over all chromosomes */
  int   point;                         /* Index of allele to mutate          */
  int   dir = random_boolean()?-1:1;   /* The direction of drift.            */

  //fprintf (stderr, "  all5s_mutate : dir = %d \n", dir);

  // Sanity check
  // 
  if (!father || !son)
    die("Null pointer to entity structure passed");

  // Select mutation locus
  // 
  point = random_int(pop->len_chromosomes);

  // Copy genome from father
  // 
  for (i=0; i<pop->len_chromosomes; i++)
    ((int *)son->CH)[i] = ((int *)father->CH)[i];

  //
  // Mutate by tweaking a single allele.
  //
  ((int *)son->CH)[point] += dir;

  if      (((int *) son->CH)[point] > 10)
    ((int *) son->CH)[point] = 0;

  else if (((int *) son->CH)[point] < 0)
    ((int *) son->CH)[point] = 10;

  return;
}
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
void 
parse_opts_len (int argc, char **argv, 
                int  *p_len_chromo,   int *p_population_size,   int *p_max_generations,
                int def_len_chromo,  int def_population_size,  int def_max_generations
                )
{

  is_print = 0;

  if (argc == 2) { // вызов без параметров, только с одним  "l_all5s 2"
    
    *p_len_chromo      = def_len_chromo;
    *p_population_size = def_population_size;
    *p_max_generations = def_max_generations;
    
  } else {
    
    *p_len_chromo      = atoi (argv[2]);
    *p_population_size = atoi (argv[3]);
    *p_max_generations = atoi (argv[4]);
    
    if (argc == 6) is_print = 1;    
  }
  
  return;
}
//------------------------------------------------------------------------------
//  all5s.c

//		This searches for a set of values all equalling '5', 
//		with allowed bounds of 0 to 10 inclusive as imposed
//		by custom chromosomes.

//		It is an example to demonstrate how to impose bounds
//		on the chromosome values by using custom seed and
//		mutation operator functions.  Compare this to the
//		accompanying all5s_allele_ranges.c

//------------------------------------------------------------------------------
int 
_1_main (int argc, char **argv)
{
  population  *pop = NULL;	    /* Population of solutions.               */
  char        *beststring = NULL;   /* Human readable form of best solution.  */
  size_t       beststrlen = 0;	    /* Length of beststring.                  */


  int len_chromo, population_size, max_generations;

  parse_opts_len (argc, argv, &len_chromo, &population_size, &max_generations,  
                  100, 200, 250);


  random_seed (20092004);

  pop = ga_genesis_integer (
     population_size,	      	/* const int              population_size      */
     1,				/* const int              num_chromo           */
     len_chromo,		/* const int              len_chromo           */
     NULL,			/* GAgeneration_hook      generation_hook      */
     NULL,			/* GAiteration_hook       iteration_hook       */
     NULL,			/* GAdata_destructor      data_destructor      */
     NULL,			/* GAdata_ref_incrementor data_ref_incrementor */
     all5s_score,		/* GAevaluate             evaluate             */
     all5s_seed,		/* GAseed                 seed                 */
     NULL,			/* GAadapt                adapt                */
     ga_select_one_sus,		/* GAselect_one           select_one           */
     ga_select_two_sus,		/* GAselect_two           select_two           */
     all5s_mutate,		/* GAmutate               mutate               */
     ga_crossover_integer_singlepoints,	/* GAcrossover    crossover            */
     NULL,			/* GAreplace	  	  replace              */
     NULL			/* vpointer		  User data            */
     );

  //pop->is_double = 0;
  pop->ch_form = CH_FORM_DOUBLE;

  ga_population_set_parameters(
     pop,			/* population                 *pop */
     GA_SCHEME_DARWIN,		/* const ga_scheme_type     scheme */
     GA_ELITISM_PARENTS_SURVIVE,/* const ga_elitism_type   elitism */
     0.8,			/* double		 crossover */
     0.05,			/* double		  mutation */
     0.0              		/* double		 migration */
     );

  
  if (is_print) {

    ga_population_seed (pop); // вообще-то здесь это происходило дальше!

    pop_print (pop);
    //exit (0); // пока здесь остановимся !
  }


  ga_evolution(
     pop,			/* population                 *pop */
     max_generations		/* const int       max_generations */
     );

  // Display final solution
  // 
  printf ("The final solution was:\n");
  beststring = ga_chromosome_integer_to_string (pop, ga_get_entity_from_rank(pop,0), 
                                                beststring, &beststrlen);
  printf ("%s\n", beststring);
  printf ("With score = %f\n", ga_get_entity_from_rank(pop,0)->fitness);

  // Free memory
  //
  ga_extinction (pop);
  s_free (beststring);

  return 1;
}
//------------------------------------------------------------------------------
// 
//  all5s_allele_ranges.c
//
//		This searches for a set of values all equalling '5', 
//		with allowed bounds of 0 to 10 inclusive, using
//		built-in features only.
//
//		This example demonstrates the
//		ga_population_set_allele_min_integer() and
//		ga_population_set_allele_max_integer() functions.
// 
//******************************************************************************
int 
_2_main (int argc, char **argv)
{
  population  *pop = NULL;	   /* Population of solutions.                 */
  char	      *beststring = NULL;  /* Human readable form of best solution.    */
  size_t       beststrlen = 0;	   /* Length of beststring.                    */

  int len_chromo, population_size, max_generations;

  parse_opts_len (argc, argv, &len_chromo, &population_size, &max_generations,  
                  100, 200, 250);

  random_seed (20092004);

  pop = ga_genesis_integer (
     population_size,		/* const int              population_size      */
     1,				/* const int              num_chromo           */
     len_chromo,		/* const int              len_chromo           */
     NULL,			/* GAgeneration_hook      generation_hook      */
     NULL,			/* GAiteration_hook       iteration_hook       */
     NULL,			/* GAdata_destructor      data_destructor      */
     NULL,			/* GAdata_ref_incrementor data_ref_incrementor */
     all5s_score,		/* GAevaluate             evaluate             */
     ga_seed_integer_random,	/* GAseed                 seed                 */
     NULL,			/* GAadapt                adapt                */
     ga_select_one_sus,		/* GAselect_one           select_one           */
     ga_select_two_sus,		/* GAselect_two           select_two           */
     ga_mutate_integer_singlepoint_drift,  /* GAmutate               mutate    */
     ga_crossover_integer_singlepoints,    /* GAcrossover            crossover */
     NULL,			/* GAreplace		replace                */
     NULL			/* vpointer		User data              */
     );

  ga_population_set_allele_min_integer (pop, 0);
  ga_population_set_allele_max_integer (pop, 10);

  ga_population_set_parameters (
     pop,			/* population                 *pop */
     GA_SCHEME_DARWIN,		/* const ga_scheme_type     scheme */
     GA_ELITISM_PARENTS_SURVIVE,/* const ga_elitism_type   elitism */
     0.8,			/* double		 crossover */
     0.05,			/* double		  mutation */
     0.0              		/* double		 migration */
     );

  ga_evolution(
     pop,			/* population                 *pop */
     max_generations	        /* const int       max_generations */
     );

  // Display final solution
  // 
  printf ("The final solution was:\n");
  beststring = ga_chromosome_integer_to_string (pop, ga_get_entity_from_rank(pop,0), 
                                                beststring, &beststrlen);
  printf ("%s\n", beststring);
  printf ("With score = %f\n", ga_get_entity_from_rank(pop,0)->fitness);

  // Free memory
  // 
  ga_extinction (pop);
  s_free (beststring);

  return 1;
}
//******************************************************************************
//------------------------------------------------------------------------------
int 
main (int argc, char **argv)
{

  printf ("\n");

  if (argc < 2 ) 
    exit (EXIT_SUCCESS);

  char *mode = argv[1];

  if      (! strcmp (mode, "_1")) _1_main (argc, argv);
  else if (! strcmp (mode, "_2")) _2_main (argc, argv); 
  else {
    printf ("\n");
    printf ("ERROR mode = %s \n", mode);
    printf ("\n");
  }

  printf ("\n");

  exit (EXIT_SUCCESS);
}
//------------------------------------------------------------------------------
//******************************************************************************


