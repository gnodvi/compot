//------------------------------------------------------------------------------
//
/**********************************************************************
  fitting.c

  Synopsis:	Test/example program for GAUL.

		This program aims to fit a function of the form
		y = Ax exp{Bx+C} + D
		through an input dataset.

  Last Updated:	19 Mar 2004 SAA	Custom mutation function since existing 
  function produced mutations that were far too significant.
		21 Nov 2002 SAA	New seeding function.
		17 Nov 2002 SAA	Initial version.

 **********************************************************************/

#include "gaul.h"

/*
 * Datastructure used to demonstrate attachment of data to specific
 * populations.
 * It is used to store the training data.
 */

typedef struct
  {
  int		num_data;
  int		max_data;
  double	*x;
  double	*y;
  } fitting_data_t;

/**********************************************************************
  fitting_score()
  synopsis:	Fitness function.
  parameters:
  return:
  updated:	19 Mar 2004
 **********************************************************************/

boolean fitting_score (population *pop, entity *entity)
  {
  int			i;		/* Loop variable over training points. */
  double		score=0.0;	/* Mean of squared deviations. */
  double		*params;	/* Fitting parameters. */
  fitting_data_t	*data;		/* Training data. */

  entity->fitness = 0;

  data = (fitting_data_t *)pop->data;
  params = (double *)entity->CH;

  for (i=0; i<data->num_data; i++)
    {
    score += SQU(data->y[i]-(data->x[i]*params[0]*exp(data->x[i]*params[1]+params[2])+params[3]));
    }

  entity->fitness = -sqrt(score / data->num_data);
  
  return TRUE;
  }


/**********************************************************************
  fitting_generation_callback()
  synopsis:	Generation callback
  parameters:
  return:
  updated:	17 Nov 2002
 **********************************************************************/

boolean fitting_generation_callback(int generation, population *pop)
  {

  printf( "%d: y = %fx exp(%fx + %f) + %f  [fitness = %f]\n",
            generation,
            ((double *)pop->entity_iarray[0]->CH)[0],
            ((double *)pop->entity_iarray[0]->CH)[1],
            ((double *)pop->entity_iarray[0]->CH)[2],
            ((double *)pop->entity_iarray[0]->CH)[3],
            pop->entity_iarray[0]->fitness );

  return TRUE;
  }


/**********************************************************************
  fitting_seed()
  synopsis:	Seed genetic data.
  parameters:	population *pop
		entity *adam
  return:	success
  last updated: 21 Nov 2002
 **********************************************************************/

boolean fitting_seed(population *pop, entity *adam)
  {

/* Checks. */
  if (!pop) die("Null pointer to population structure passed.");
  if (!adam) die("Null pointer to entity structure passed.");

/* Seeding. */
  ((double *)adam->CH)[0] = random_double(2.0);
  ((double *)adam->CH)[1] = random_double(2.0);
  ((double *)adam->CH)[2] = random_double(2.0);
  ((double *)adam->CH)[3] = random_double(4.0)-2.0;

  return TRUE;
  }


/**********************************************************************
  ga_mutate_double_singlepoint_drift()
  synopsis:	Cause a single mutation event in which a single
		allele is adjusted.  (0.1*Unit Gaussian distribution.)
  parameters:
  return:
  last updated: 19 Mar 2004
 **********************************************************************/

void fitting_mutate_double_singlepoint_drift( population *pop,
                                          entity *father, entity *son )
  {
  int		i;		/* Loop variable over all chromosomes */
  int		chromo;		/* Index of chromosome to mutate */
  int		point;		/* Index of allele to mutate */
  double	amount=random_unit_gaussian()*0.1;	/* The amount of drift. */

/* Checks */
  if (!father || !son) die("Null pointer to entity structure passed");

/* Select mutation locus. */
  chromo = (int) random_int (1/* pop->num_chromosomes */);
  point  = (int) random_int (pop->len_chromosomes);

/*
 * Copy unchanged data.
 */
  for (i=0; i<1/* pop->num_chromosomes */; i++)
    {
    memcpy(son->chromosome[i], father->chromosome[i], pop->len_chromosomes*sizeof(double));
    if (i!=chromo)
      {
      ga_copy_data(pop, son, father, i);
      }
    else
      {
      ga_copy_data(pop, son, NULL, i);
      }
    }

/*
 * Mutate by tweaking a single allele.
 */
  ((double *)son->chromosome[chromo])[point] += amount;

  if (((double *)son->chromosome[chromo])[point]>DBL_MAX-1.0) ((double *)son->chromosome[chromo])[point]=DBL_MIN+1.0;
  if (((double *)son->chromosome[chromo])[point]<DBL_MIN+1.0) ((double *)son->chromosome[chromo])[point]=DBL_MAX-1.0;

  return;
  }
//------------------------------------------------------------------------------
void set_data (fitting_data_t *data)
{
  int num = 41;
  double x;

  double x_min = - 2.5;
  double x_max = + 2.5;
  int A = 1;
  int B = 1;
  int C = 1;
  int D = 0;

  data->num_data = num;

  data->x = malloc (sizeof(double) * num);
  data->y = malloc (sizeof(double) * num);

  int i;
  double step = (x_max - x_min) / (num-1);

  for (i=0; i<num; i++) {
    x = data->x[i] = x_min + i * step;
    data->y[i] = A*x * exp (B*x + C) + D;
  }

  return;
}
//------------------------------------------------------------------------------

/**********************************************************************
  get_data()
  synopsis:	Read training data from standard input.
  parameters:
  return:
  updated:	17 Nov 2002
 **********************************************************************/

//------------------------------------------------------------------------------
void 
get_data (fitting_data_t *data)
  {
  int           line_count=0;                   /* Number of lines read from stdin. */
  char          buffer[MAX_LINE_LEN], *line;    /* Buffer for input. */

  if (!data) die("Null pointer to data structure passed.");

/*
 * Read lines.  Each specifies one x,y pair except those starting with '#'
 * or '!' which are comment lines and are ignored.  Don't bother parsing
 * blank lines either.
 */
  while ( !feof(stdin) && fgets(buffer, MAX_LINE_LEN, stdin)!=NULL )
    {
    line = buffer;

    /* Skip leading whitespace. */
    while (*line == ' ' || *line == '\t') line++;

    if (*line == '#' || *line == '!' || *line == '\n')
      { /* Ignore this line */
/*    printf("Ignoring line: %s\n", line);*/
      }
    else
      {
/* Ensure sufficient memory is available. */
      if (data->num_data == data->max_data)
        {
        data->max_data += 256;
        data->x = s_realloc(data->x, sizeof(double)*data->max_data);
        data->y = s_realloc(data->y, sizeof(double)*data->max_data);
        }

      sscanf(line, "%lf %lf", &(data->x[data->num_data]), &(data->y[data->num_data]));
      printf("Read %d: %f %f\n", data->num_data, data->x[data->num_data], data->y[data->num_data]);

      data->num_data++;
      }

    line_count++;
    }

  plog(LOG_NORMAL, "Read %f data points from %d lines.\n", data->num_data, line_count);

  return;
  }
//------------------------------------------------------------------------------


/**********************************************************************
  main()
  synopsis:	Main function.
  parameters:
  return:
  updated:	17 Nov 2002
 **********************************************************************/

//------------------------------------------------------------------------------
//int 
void
  //main (int argc, char **argv)
fitting_ (int argc, char **argv)
  {
  population		*pop;			/* Population of solutions. */
  fitting_data_t	data={0,0,NULL,NULL};	/* Training data. */

  random_seed (23091975);

  pop = ga_genesis_double(
       200,				/* const int              population_size */
       1,				/* const int              num_chromo */
       4,				/* const int              len_chromo */
       fitting_generation_callback,	/* GAgeneration_hook      generation_hook */
       NULL,				/* GAiteration_hook       iteration_hook */
       NULL,				/* GAdata_destructor      data_destructor */
       NULL,				/* GAdata_ref_incrementor data_ref_incrementor */
       fitting_score,			/* GAevaluate             evaluate */
       fitting_seed,			/* GAseed                 seed */
       NULL,				/* GAadapt                adapt */
       ga_select_one_linearrank,	/* GAselect_one           select_one */
       ga_select_two_linearrank,	/* GAselect_two           select_two */
       fitting_mutate_double_singlepoint_drift,	/* GAmutate               mutate */
       ga_crossover_double_mean,	/* GAcrossover            crossover */
       NULL,				/* GAreplace              replace */
       NULL				/* vpointer	User data */
            );

  ga_population_set_parameters(
       pop,				/* population      *pop */
       GA_SCHEME_DARWIN,		/* const ga_scheme_type     scheme */
       GA_ELITISM_PARENTS_DIE,		/* const ga_elitism_type   elitism */
       0.8,				/* double  crossover */
       0.8,				/* double  mutation */
       0.0      		        /* double  migration */
                              );

  //printf ("mgena-00 \n");
  //get_data (&data);
  set_data (&data);
 
  pop->data = &data;

  //printf ("mgena-01 \n");
  ga_evolution(
       pop,				/* population	*pop */
       200				/* const int	max_generations */
              );
  //printf ("mgena-02 \n");

  ga_extinction(pop);
  //printf ("mgena-03 \n");

  //exit(EXIT_SUCCESS);
  return;
  }
//******************************************************************************


/**********************************************************************
  fitting_double_to_double()
  synopsis:     Convert to double array.
  parameters:
  return:
  last updated: 21 Nov 2002
 **********************************************************************/

boolean fitting_to_double(population *pop, entity *entity, double *array)
  {

  if (!pop) die("Null pointer to population structure passed.");
  if (!entity) die("Null pointer to entity structure passed.");

  array[0] = ((double *)entity->CH)[0];
  array[1] = ((double *)entity->CH)[1];
  array[2] = ((double *)entity->CH)[2];
  array[3] = ((double *)entity->CH)[3];

  return TRUE;
  }


/**********************************************************************
  fitting_from_double()
  synopsis:     Convert from double array.
  parameters:
  return:
  last updated: 21 Nov 2002
 **********************************************************************/

boolean fitting_from_double(population *pop, entity *entity, double *array)
  {

  if (!pop) die("Null pointer to population structure passed.");
  if (!entity) die("Null pointer to entity structure passed.");

  if (!entity->chromosome) die("Entity has no chromsomes.");

  ((double *)entity->CH)[0] = array[0];
  ((double *)entity->CH)[1] = array[1];
  ((double *)entity->CH)[2] = array[2];
  ((double *)entity->CH)[3] = array[3];

  return TRUE;
  }


/**********************************************************************
  fitting_score()
  synopsis:	Fitness function.
  parameters:
  return:
  updated:	17 Nov 2002
 **********************************************************************/

boolean fitting_score_sd (population *pop, entity *entity)
  {
  int			i;		/* Loop variable over training points. */
  double		score=0.0;	/* Mean of squared deviations. */
  double		*params;	/* Fitting parameters. */
  fitting_data_t	*data;		/* Training data. */

  entity->fitness = 0;

  data = (fitting_data_t *)pop->data;
  params = (double *)entity->CH;

  for (i=0; i<data->num_data; i++)
    {
    score += SQU(data->y[i]-(data->x[i]*params[0]*exp(params[1]*data->x[i]+params[2])+params[3]));
    }

  entity->fitness = -score/data->num_data;
  
  return TRUE;
  }


/**********************************************************************
  fitting_analytical_gradient()
  synopsis:     Calculate gradients analytically.
		FIXME: Not correct!
  parameters:
  return:
  last updated: 21 Nov 2002
 **********************************************************************/

double fitting_analytical_gradient(population *pop, entity *entity, double *params, double *grad)
  {
  int			i;		/* Loop variable over training points. */
  fitting_data_t	*data;		/* Training data. */
  double		E, F;		/* Intermediate values. */
  double		grms=0.0;	/* RMS gradient. */

  if (!pop) die("Null pointer to population structure passed.");
  if (!entity) die("Null pointer to entity structure passed.");

  data = (fitting_data_t *)pop->data;

  grad[0] = 0.0;
  grad[1] = 0.0;
  grad[2] = 0.0;
  grad[3] = 0.0;

  for (i=0; i<data->num_data; i++)
    {
    E = data->x[i]*params[0]*exp(params[1]);
    F = 2*E - 2*data->y[i] - 2*params[2];

    grad[0] += -data->x[i]*exp(data->x[i]*params[1]+params[2])*F;

    grad[1] += data->x[i]*E*F;

    grad[2] += 2*data->y[i] + 2*params[2] - 2*E;

    grad[3] += 0.0;
    }

  grad[0] /= SQU(data->num_data);
  grad[1] /= SQU(data->num_data);
  grad[2] /= SQU(data->num_data);
  grad[3] /= SQU(data->num_data);

  grms = sqrt(grad[0]*grad[0]+grad[1]*grad[1]+grad[2]*grad[2]+grad[3]*grad[3]);

  return grms;
  }


/**********************************************************************
  fitting_numerical_gradient()
  synopsis:     Calculate gradients numerically.
  parameters:
  return:
  last updated: 21 Nov 2002
 **********************************************************************/

#define DELTA		1.0e-6

double fitting_numerical_gradient(population *pop, entity *entity, double *params, double *grad)
  {
  int			i;		/* Loop variable over training points. */
  fitting_data_t	*data;		/* Training data. */
  double		grms=0.0;	/* RMS gradient. */

  if (!pop) die("Null pointer to population structure passed.");
  if (!entity) die("Null pointer to entity structure passed.");

  data = (fitting_data_t *)pop->data;

  grad[0] = 0.0;
  grad[1] = 0.0;
  grad[2] = 0.0;
  grad[3] = 0.0;

  for (i=0; i<data->num_data; i++)
    {
    grad[0] += SQU(data->y[i]-(data->x[i]*(params[0]+DELTA)*exp(params[1]*data->x[i]+params[2])+params[3]))
               - SQU(data->y[i]-(data->x[i]*(params[0]-DELTA)*exp(params[1]*data->x[i]+params[2])+params[3]));
    grad[1] += SQU(data->y[i]-(data->x[i]*params[0]*exp((params[1]+DELTA)*data->x[i]+params[2])+params[3]))
               - SQU(data->y[i]-(data->x[i]*params[0]*exp((params[1]-DELTA)*data->x[i]+params[2])+params[3]));
    grad[1] += SQU(data->y[i]-(data->x[i]*params[0]*exp(params[1]*data->x[i]+params[2]-DELTA)+params[3]))
               - SQU(data->y[i]-(data->x[i]*params[0]*exp(params[1]*data->x[i]+params[2]+DELTA)+params[3]));
    grad[3] += SQU(data->y[i]-(data->x[i]*params[0]*exp(params[1]*data->x[i]+params[2])+params[3]+DELTA))
               - SQU(data->y[i]-(data->x[i]*params[0]*exp(params[1]*data->x[i]+params[2])+params[3]-DELTA));
    }

  grad[0] /= -2*data->num_data*DELTA;
  grad[1] /= -2*data->num_data*DELTA;
  grad[2] /= -2*data->num_data*DELTA;
  grad[3] /= -2*data->num_data*DELTA;

  grms = sqrt(grad[0]*grad[0]+grad[1]*grad[1]+grad[2]*grad[2]+grad[3]*grad[3]);

  return grms;
  }

/**********************************************************************
  fitting_iteration_callback()
  synopsis:	Generation callback
  parameters:
  return:
  updated:	21 Nov 2002
 **********************************************************************/

boolean fitting_iteration_callback(int iteration, entity *solution)
  {

  printf( "%d: y = %f x exp(%f x + %f) + %f (fitness = %f)\n",
            iteration,
            ((double *)solution->CH)[0],
            ((double *)solution->CH)[1],
            ((double *)solution->CH)[2],
            ((double *)solution->CH)[3],
            solution->fitness );

  return TRUE;
  }


//******************************************************************************
void
fitting_sd (int argc, char **argv)
{

  population		*pop;			/* Population of solutions. */
  fitting_data_t	data={0,0,NULL,NULL};	/* Training data. */
  entity		*solution;		/* Optimised solution. */

  random_seed(23091975);

  pop = ga_genesis_double(
       50,				/* const int              population_size */
       1,				/* const int              num_chromo */
       4,				/* const int              len_chromo */
       NULL,				/* GAgeneration_hook      generation_hook */
       fitting_iteration_callback,	/* GAiteration_hook       iteration_hook */
       NULL,				/* GAdata_destructor      data_destructor */
       NULL,				/* GAdata_ref_incrementor data_ref_incrementor */
       fitting_score_sd,		/* GAevaluate             evaluate */
       fitting_seed,			/* GAseed                 seed */
       NULL,				/* GAadapt                adapt */
       NULL,				/* GAselect_one           select_one */
       NULL,				/* GAselect_two           select_two */
       NULL,				/* GAmutate               mutate */
       NULL,				/* GAcrossover            crossover */
       NULL,				/* GAreplace              replace */
       NULL				/* vpointer		User data */
            );

  ga_population_set_gradient_parameters(
       pop,				/* population		*pop */
       fitting_to_double,		/* const GAto_double	to_double */
       fitting_from_double,		/* const GAfrom_double	from_double */
#if 0
       fitting_analytical_gradient,	/* const GAgradient	gradient */
#endif
       fitting_numerical_gradient,	/* const GAgradient	gradient */
       4,				/* const int		num_dimensions */
       0.1				/* const double		step_size */
                       );

  //get_data(&data);
  set_data (&data);
  pop->data = &data;

  /* Evaluate and sort the initial population members (i.e. select best of 50 random solutions. */
  ga_population_score_and_sort(pop);

  /* Use the best population member. */
  solution = ga_get_entity_from_rank(pop, 0);

  ga_steepestascent(
       pop,				/* population		*pop */
       solution,			/* entity		*solution */
       2000				/* const int		max_iterations */
            );

  ga_extinction(pop);

  return;
}
//******************************************************************************
//******************************************************************************
void
fitting_simplex (int argc, char **argv)
{

  population		*pop;			/* Population of solutions. */
  fitting_data_t	data={0,0,NULL,NULL};	/* Training data. */
  entity		*solution;		/* Optimised solution. */

  random_seed(23091975);

  pop = ga_genesis_double(
       50,				/* const int              population_size */
       1,				/* const int              num_chromo */
       4,				/* const int              len_chromo */
       NULL,				/* GAgeneration_hook      generation_hook */
       fitting_iteration_callback,	/* GAiteration_hook       iteration_hook */
       NULL,				/* GAdata_destructor      data_destructor */
       NULL,				/* GAdata_ref_incrementor data_ref_incrementor */
       fitting_score,			/* GAevaluate             evaluate */
       fitting_seed,			/* GAseed                 seed */
       NULL,				/* GAadapt                adapt */
       NULL,				/* GAselect_one           select_one */
       NULL,				/* GAselect_two           select_two */
       NULL,				/* GAmutate               mutate */
       NULL,				/* GAcrossover            crossover */
       NULL,				/* GAreplace              replace */
       NULL				/* vpointer	User data */
            );

  ga_population_set_simplex_parameters(
       pop,				/* population		*pop */
       4,				/* const int		num_dimensions */
       0.5,				/* const double         Initial step size. */
       fitting_to_double,		/* const GAto_double	to_double */
       fitting_from_double		/* const GAfrom_double	from_double */
                       );

  //get_data(&data);
  set_data(&data);
  pop->data = &data;

  /* Evaluate and sort the initial population members (i.e. select best of 50 random solutions. */
  ga_population_score_and_sort(pop);

  /* Use the best population member. */
  solution = ga_get_entity_from_rank(pop, 0);

  ga_simplex(
       pop,				/* population		*pop */
       solution,			/* entity		*solution */
       1000				/* const int		max_iterations */
            );

  ga_extinction(pop);

  return;
}
//------------------------------------------------------------------------------
int 
main (int argc, char **argv)
{

  if (argc !=2 ) 
    exit (EXIT_SUCCESS);

  if (!strcmp(argv[1], "0")) fitting_   (argc, argv);
  if (!strcmp(argv[1], "1")) fitting_sd (argc, argv);
  if (!strcmp(argv[1], "2")) fitting_simplex (argc, argv); 

  exit (EXIT_SUCCESS);
}
//------------------------------------------------------------------------------
//******************************************************************************
//------------------------------------------------------------------------------


