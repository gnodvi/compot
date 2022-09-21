/*******************************************************************************
  royalroad.c

  Synopsis:	Test/example program for GAUL.

		The scoring function was adapted from GAlib 2.45,
		which states:

		This is the objective function for computing Holland's
		1993 ICGA version of the Royal Road problem.  It has
		been corrected per GAList volume 7 number 23, 8/26/93.
		No bonus points are awarded for a given level until it
		has been achieved (this fixes Holland's coding error in
		GAList).  Holland posed this problem as a challenge to
		test the performance of genetic algorithms.  He
		indicated that, with the parameter settings of:

		schemata size = 8
		bits between schemata = 7
		m* = 4
		U* = 1.0
		u = 0.3
		v = 0.02

		Holland could attain royal_road_level 3 most of the time
		within 10,000 function evaluations.  He challenged other
		GA users to match or beat that performance.  He
		indicated that he used a population size of 512 to
		obtain his solutions, and did NOT use a "simple genetic
		algorithm."

		The genome for this problem is a single-dimension
		bitstring with length defined by the block size and gap
		size as:

		    length = (blocksize+gapsize) * (2^K)

		where K = 1,2,3, or 4.  Holland used K = 4.

*******************************************************************************/

/*
 * Includes
 */
#include "gaul.h"

/*
 * Hard-coded parameter settings.
 * FIXME: Should make these user options.
 */
#define NBLOCKS         16	/* this number is 2^K */

#define BLOCKSIZE	8	/* block size - length of target schemata */
#define GAPSIZE		7	/* gap size - number of bits between target schemata */
#define MSTAR		4	/* Holland's m* - up to this many bits in low level block rewarded */
#define USTAR		1.0	/* Holland's U* - first block earns this */
#define RR_U		0.3	/* Holland's u - increment for lowest level match */
#define RR_V		0.02	/* Holland's v - reward/penalty per bit */

#define NBITS	(BLOCKSIZE+GAPSIZE)*NBLOCKS	/* Number of 'bits' in chromosomes. */

/* Global variable. */
int highestlevel = 0;

//******************************************************************************
int
bit_value_int_ (entity *entity, int i)
{
  int ret = ((boolean *) entity->CH)[i] ? 1 : 0;

  return (ret);
}
//******************************************************************************
int
bit_value_int_bitstring (entity *entity, int i)
{
  int ret = ga_bit_get ((gaulbyte *) entity->CH, i) ? 1: 0;

  return (ret);
}
//------------------------------------------------------------------------------

BIT_PROC bit_proc;
int pnum;

//------------------------------------------------------------------------------
boolean 
royalroad_score (population *pop, entity *entity)
{
  double	score = 0.0;
  int		count, i, j, index, n;
  int		blockarray[NBLOCKS];
  int		proceed, level;

  /* do the lowest level blocks first. */

  n = 0;
  for (i=0; i<NBLOCKS; i++) {
    count = 0;

    for (j=i*(BLOCKSIZE + GAPSIZE); j<i*(BLOCKSIZE+GAPSIZE)+BLOCKSIZE; j++)
      /* count the bits in the block. */
      count += bit_proc (entity, j);

    if(count > MSTAR && count < BLOCKSIZE)
      score -= (count-MSTAR)*RR_V;
    else if(count <= MSTAR)
      score += count * RR_V;

    if (count == BLOCKSIZE) {
      blockarray[i] = 1;
      n++;
    }
    else{
      blockarray[i] = 0;
    }
  }

  /* bonus for filled low-level blocks. */

  if(n > 0) score += USTAR + (n-1)*RR_U;

  /* now do the higher-level blocks. */

  n = NBLOCKS;		/* n is now number of filled low level blocks. */
  proceed = 1;		/* should we look at the next higher level? */
  level = 0;
  while ((n > 1) && proceed) {
    proceed = 0;
    count = 0;
    /* there are n valid blocks in the blockarray each time */
    /* round, so n=2 is the last.                           */
    for(i=0,index=0; i<(n/2)*2; i+=2,index++) {
      if(blockarray[i] == 1 && blockarray[i+1] == 1) {
	count++;
	proceed = 1;
	blockarray[index] = 1;
      }
      else{
	blockarray[index] = 0;
      }
    }
    if (count > 0){
      score += USTAR + (count-1)*RR_U;
      level++;
    }
    n /= 2;
  }

  if (highestlevel < level) highestlevel = level;

  entity->fitness = score;

  return TRUE;
}
//------------------------------------------------------------------------------
boolean 
royalroad_ga_callback (int generation, population *pop)
{

  if (generation % pnum == 0)
  {
    printf ( "generation = %d best score = %f highestlevel = %d\n",
            generation,
            ga_get_entity_from_rank(pop,0)->fitness,
            highestlevel );
  }

  return TRUE;
}
//******************************************************************************
//------------------------------------------------------------------------------
void
write_extinction (population *pop, int seed)
{

  entity *final_entity = ga_get_entity_from_rank (pop,0);
  int	  i;		/* Loop over alleles. */

  printf ("The final solution with seed = %d was: \n", seed);
  for (i=0; i<NBITS; i++)
    printf ("%d", bit_proc (final_entity, i));

  printf ("\nscore = %f highestlevel = %d\n",
          final_entity->fitness,
          highestlevel);

  ga_extinction (pop);

  return;
}
//------------------------------------------------------------------------------
population *
royalroad (GENESIS_PROC genesis_proc,
           GAseed       ga_seed,
           GAmutate     ga_mutate,
           GAcrossover  ga_crossover,
           BIT_PROC     ga_bit_proc,
           int		seed,           // Random number seed
           GAreplace    replace
           )
{
  bit_proc = ga_bit_proc;

  population  *pop=NULL;	/* Population of solutions. */

  printf ("Running Holland's Royal Road test problem with a genome that\n");
  printf ("is %d bits long with %d blocks.  The parameters are:\n", NBITS, NBLOCKS);
  printf ("  block size: %d\n", BLOCKSIZE);
  printf ("  gap size  : %d\n", GAPSIZE);
  printf ("  m*        : %d\n", MSTAR);
  printf ("  u*        : %f\n", USTAR);
  printf ("  u         : %f\n", RR_U);
  printf ("  v         : %f\n", RR_V);
  printf ("\n");
  printf ("Random number seed is %d\n", seed);
  printf ("\n");

  random_seed (seed);

  pop = genesis_proc (
     512,			/* const int              population_size */
     1,				/* const int              num_chromo */
     NBITS,			/* const int              len_chromo */
     royalroad_ga_callback,	/* GAgeneration_hook      generation_hook */
     NULL,			/* GAiteration_hook       iteration_hook */
     NULL,			/* GAdata_destructor      data_destructor */
     NULL,			/* GAdata_ref_incrementor data_ref_incrementor */
     royalroad_score,		/* GAevaluate             evaluate */
     ga_seed,	                /* GAseed                 seed */
     NULL,			/* GAadapt                adapt */
     ga_select_one_bestof2,	/* GAselect_one           select_one */
     ga_select_two_bestof2,	/* GAselect_two           select_two */
     ga_mutate,	                /* GAmutate               mutate */
     ga_crossover,	        /* GAcrossover            crossover */
     replace,			/* GAreplace              replace */
     NULL			/* vpointer	User data */
     );

  ga_population_set_parameters(
       pop,			/* population      *pop */
       GA_SCHEME_DARWIN,	/* const ga_scheme_type     scheme */
       GA_ELITISM_PARENTS_DIE,	/* const ga_elitism_type   elitism */
       0.9,			/* double  crossover */
       0.1,			/* double  mutation */
       0.0              	/* double  migration */
       );


  return (pop);
}
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
//		This implementation uses a GAUL boolean chromosome
//		with a standard generational GA.
//------------------------------------------------------------------------------
void 
royalroad_main ()
{
  population *pop;
  int         seed = 12345678;

  pnum = 1;

  pop = royalroad (ga_genesis_boolean,
                   ga_seed_boolean_random,
                   ga_mutate_boolean_multipoint,
                   ga_crossover_boolean_doublepoints,
                   bit_value_int_, seed,
                   NULL
                   );

  ga_evolution (pop, /* population  *pop */
                100  /* const  int   max_generations */
                );

  write_extinction (pop, seed);
  return;
}
//------------------------------------------------------------------------------
//		This implementation uses a GAUL bitstring chromosome
//		with a standard generational GA.
//------------------------------------------------------------------------------
void 
royalroad_bitstring ()
{
  population *pop;
  int         seed = 12345678;

  pnum = 1;

  pop = royalroad (ga_genesis_bitstring,
                   ga_seed_bitstring_random,
                   ga_mutate_bitstring_singlepoint,
                   ga_crossover_bitstring_doublepoints,
                   bit_value_int_bitstring, seed,
                   NULL
                   );

  ga_evolution (pop, /* population  *pop */
                100  /* const  int   max_generations */
                );

  write_extinction (pop, seed);
  return;
}
//------------------------------------------------------------------------------
//		This implementation uses a GAUL boolean chromosome
//		with a standard steady-state GA.
//------------------------------------------------------------------------------
void 
royalroad_ss ()
{
  population *pop;
  int         seed = 1234;

  pnum = 1000;

  pop = royalroad (ga_genesis_boolean,
                   ga_seed_boolean_random,
                   ga_mutate_boolean_singlepoint,
                   ga_crossover_boolean_doublepoints,
                   bit_value_int_, seed,
                   ga_replace_by_fitness
                   );

  //ga_evolution (pop, /* population  *pop */
  //              100  /* const  int   max_generations */
  //              );
  ga_evolution_steady_state (
       pop,		/* population              *pop */
       50000		/* const int               max_iterations */
       );

  write_extinction (pop, seed);
  return;
}
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
void 
royalroad_demo ()
{
  population *pop;
  int         seed = 12345678;

  pnum = 1;

  pop = royalroad (ga_genesis_boolean,
                   ga_seed_boolean_random,
                   ga_mutate_boolean_multipoint,
                   ga_crossover_boolean_doublepoints,
                   bit_value_int_, seed,
                   NULL
                   );

  ga_population_set_allele_mutation_prob( pop, 0.6 );

  ga_evolution(
       pop,		/* population              *pop */
       100		/* const int               max_generations */
       );

  write_extinction (pop, seed);
  return;
}
//------------------------------------------------------------------------------
int 
main (int argc, char **argv)
{

  if (argc !=2 ) 
    exit (EXIT_SUCCESS);

  if (!strcmp(argv[1], "main"))      royalroad_main ();
  if (!strcmp(argv[1], "bitstring")) royalroad_bitstring ();
  if (!strcmp(argv[1], "ss"))        royalroad_ss ();
  if (!strcmp(argv[1], "demo"))      royalroad_demo ();

  exit (EXIT_SUCCESS);
}
//------------------------------------------------------------------------------
//******************************************************************************

