/*******************************************************************************
*******************************************************************************/

#include "gaul.h"

//#include "l_test_LIB.h"

//*****************************************************************************/

int population_size = 124;
int max_generations = 124;

int     dim;
int     fun;
double xmin;
double xmax;

#define x1 (((double *) this_entity->CH)[0])
#define x2 (((double *) this_entity->CH)[1])
#define x3 (((double *) this_entity->CH)[2])
#define x4 (((double *) this_entity->CH)[3])
#define x5 (((double *) this_entity->CH)[4])
#define x6 (((double *) this_entity->CH)[5])

#define xi(i) (((double *) this_entity->CH)[(i)-1])

/*----------------------------------------------------------------------------*/
//------------------------------------------------------------------------------
void
x_test_init ()
{

  switch (fun) {
  case 1: // De Jong
    dim  = 2;
    xmin = -2.048; xmax = +2.048;
    break;

  case 2: // Goldstein & Price
    dim  = 2;
    xmin =  -2.0; xmax = +2.0;
    break;

  case 3: // Branin
    dim  = 2;
    xmin = - 5.0; xmax = +10.0;
    break;

  case 4: // Martin & Gaddy
    dim  = 2;
    xmin = 0.0; xmax = +10.0;
    break;

  case 5: // Rosenbrock
    dim  = 2;
    xmin = -1.2; xmax = +1.2;
    break;

  case 6: // Rosenbrock
    dim  = 4;
    xmin = -1.2; xmax = +1.2;
    break;

  case 7: // Hyper sphere 
    dim  = 6;
    xmin = -5.12; xmax = +5.12;
    break;

  case 8: // Grienwank 
    dim  = 10;
    xmin = -512; xmax = +512;
    break;

  default:
    printf ("FUN - Error !!! \n");
    exit (0);
  }

  return;
}
//------------------------------------------------------------------------------
boolean 
x_test_score (population *pop, entity *this_entity)
{
  double  f, fitness, A, B, C, D, E, F, sum, mul;
  int     i;

  fitness = 0;

  // …›eÕ ÌÈÓÈÌıÌ˘ ∆’ŒÀ√…  ....
  switch (fun) {

  case 1: // De Jong  [-2.048, 2.048]       F(1, 1)=3905.93
    fitness = 3905.93 - 100*(x1*x1-x2)*(x1*x1-x2) - (1-x1)*(1-x1);
    fitness = - fitness;
    break;

  case 2: // Goldstein & Price  [-2, 2]     F(0,-1)=3
    A = 1 +  (x1+x2+1)*(x1+x2+1) * (19-14*x1 + 3*x1*x1 - 14*x2 + 6*x1*x2 + 3*x2*x2);
    B = 30 + (2*x1-3*x2)*(2*x1-3*x2) * (18 - 32*x1 + 12*x1*x1 + 48*x2 - 36*x1*x2 + 27*x2*x2);
    fitness = A * B;
    break;

  case 3: // Branin [-5,10]   X(-22/7,   12.275)  X(-22/7, 12.275)  X(-22/7,    12.275)
          //                  X(3.142857,12.275)  ................  X(9.428571, 12.275)
          //                  F=0
    A = 1;
    B = (5.1/4) * (7.0/22);
    C = 5.0 / 22 * 7;
    D = 6;
    E = 10;
    F = (1.0/8) * (7.0/22);
    fitness = A*(x2-B*x1*x1+C*x1-D)*(x2-B*x1*x1+C*x1-D) + E*(1-F)*cos(x1) + E;
    break;

  case 4: // Martin & Gaddy  [0, 10]     X(5,5)  F=0
    fitness = (x1-x2)*(x1-x2) + ((x1+x2-10)/3.0) * ((x1+x2-10)/3.0);
    break;

  case 5: // Rosenbrock(a) [-1.2, 1.2]   X(1,1)  F=0
    fitness = 100 * (x2-x1*x1)*(x2-x1*x1) + (1-x1)*(1-x1);
    break;

  case 6: // Rosenbrock [-1.2, 1.2]  X(1,1,1,1)  F=0
    for (i=1; i<=3; i++) {
      f = pow (xi(i), 2) - xi(i+1);
      fitness += (100 * f*f + pow (1-xi(i), 2));
    }
    break;

  case 7: // Hyper sphere [-5.12, 5.12]  X(0,0,0,0,0,0)  F=0
    for (i=1; i<=6; i++) {
      fitness += pow (xi(i), 2);
    }
    break;

  case 8: // Griewank [-512, 512],  F(0,0,0,0,0,0)=10
    sum = 0;
    mul = 1;
    for (i=1; i<=10; i++) {
      //xi(i) = 0;
      sum += pow (xi(i), 2);
      mul *= (cos(xi(i)/sqrt(i)));
    }
    
    fitness = (1 / (0.1 + sum/4000.0 - mul + 1));
    fitness = - fitness;
    break;
  }

  fitness = - fitness; // Œ¡€ ¡Ã«œ“…‘Õ …›e‘ Ì·ÎÛÈÌıÌ˘
  ga_entity_set_fitness (this_entity, fitness);

  return TRUE;
}
//------------------------------------------------------------------------------
boolean 
x_test_seed (population *pop, entity *adam)
{

/* Checks. */
  //if (!pop)  die ("Null pointer to population structure passed.");
  //if (!adam) die ("Null pointer to entity structure passed.");

/* Seeding. */
  double xint = xmax - xmin;
  int i;

  for (i=0; i<dim; i++)
    ((double *) adam->CH)[i] = random_double (xint) + xmin;

  return TRUE;
}
//------------------------------------------------------------------------------
boolean 
x_test_generation_callback (int generation, population *pop)
{
  entity  *best;   /* Fittest entity. */
  best = ga_get_entity_from_rank (pop, 0);
  int i;

  printf ("%3d: ", generation);

  for (i=0; i<dim; i++)
    printf ("x%d = %f  ", i+1, ((double *) best->CH)[i]);

  printf ("(fitness = %f) \n", ga_entity_get_fitness (best));

  return TRUE;
}
//******************************************************************************
//------------------------------------------------------------------------------
int 
main_x_mini (int population_size, int max_generations)
{
  population  *pop;  /* Population of solutions. */

  int dimm;

  if (dim == 1) dimm = 2;
  else          dimm = dim;

  //random_seed (23091975);
  random_seed (time (NULL));

  pop = ga_genesis_double (
       population_size/* 200 */,   /* const int              population_size      */
       1,			   /* const int              num_chromo           */
       //-----------------------
       dimm,			   /* const int              len_chromo           */
       //-----------------------
       x_test_generation_callback, /* GAgeneration_hook      generation_hook      */
       NULL,			   /* GAiteration_hook       iteration_hook       */
       NULL,			   /* GAdata_destructor      data_destructor      */
       NULL,			   /* GAdata_ref_incrementor data_ref_incrementor */
       x_test_score,		   /* GAevaluate             evaluate             */
       x_test_seed,		   /* GAseed                 seed                 */
       NULL,			   /* GAadapt                adapt                */
       ga_select_one_bestof2,	           /* GAselect_one           select_one   */
       ga_select_two_bestof2,	           /* GAselect_two           select_two   */
       ga_mutate_double_singlepoint_drift, /* GAmutate               mutate       */
       ga_crossover_double_doublepoints,   /* GAcrossover            crossover    */
       NULL,			           /* GAreplace              replace      */
       NULL			           /* vpointer	User data                 */
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
       pop,				/* population	*pop               */
       max_generations/* 500 */		/* const int	max_generations    */
       );

  ga_extinction (pop);

  exit (EXIT_SUCCESS);
}
//------------------------------------------------------------------------------
int 
main (int argc, char **argv)
{
  char *name;

  if (argc == 1) {
    name = "1";
    population_size = 124;
    max_generations = 124;
  }
  else {
    name = argv[1];
    population_size = atoi (argv[2]);
    max_generations = atoi (argv[3]);
  }

  fun = atoi (name);
  //---------------------------------------------

  x_test_init ();

  main_x_mini (population_size, max_generations);

  return 0;
}
//------------------------------------------------------------------------------
// 
//******************************************************************************

