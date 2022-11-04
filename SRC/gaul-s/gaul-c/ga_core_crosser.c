/**********************************************************************
  ga_crossover.c
 **********************************************************************

  ga_crossover - Genetic algorithm crossover operators.
  Copyright б╘2000-2006, Stewart Adcock <stewart@linux-domain.com>
  All rights reserved.

  Synopsis:     Routines for performing GA crossover operations.

		These functions should duplicate user data where
		appropriate.

  To do:	Merge static crossover functions by passing datatype size.

 **********************************************************************/

//#include "ga_core.h"
#include "gaul.h"

//------------------------------------------------------------------------------
//
//  INTEGER   INTEGER   INTEGER   INTEGER   INTEGER   INTEGER   INTEGER 
//
//------------------------------------------------------------------------------

//------------------------------------------------------------------------------
// `Mates' two chromosomes by single-point crossover.
//------------------------------------------------------------------------------
void 
ga_singlepoint_crossover_integer_chromosome (population *pop,
                                             int *father, int *mother,
                                             int *son, int *daughter )
{
  int  location; // Point of crossover

  if (!father || !mother || !son || !daughter)
    die ("Null pointer to integer-array chromosome structure passed.");

  /* Choose crossover point and perform operation */
  location = random_int (pop->len_chromosomes);

  memcpy (     son, mother, location*sizeof(int));
  memcpy (daughter, father, location*sizeof(int));

  memcpy (&(     son[location]), &(father[location]), (pop->len_chromosomes-location)*sizeof(int));
  memcpy (&(daughter[location]), &(mother[location]), (pop->len_chromosomes-location)*sizeof(int));

  return;
}
//------------------------------------------------------------------------------
//  `Mates' two chromosomes by double-point crossover.
//------------------------------------------------------------------------------
void 
ga_doublepoint_crossover_integer_chromosome (population *pop,
                                             int *father, int *mother,
                                             int *son, int *daughter)
{
  int	location1, location2;	/* Points of crossover. */
  int	tmp;			/* For swapping crossover loci. */

  if (!father || !mother || !son || !daughter)
    die ("Null pointer to integer-array chromosome structure passed.");

  /* Choose crossover point and perform operation */
  location1 = random_int (pop->len_chromosomes);
  do
  {
    location2 = random_int (pop->len_chromosomes);
  } while (location2 == location1);

  if (location1 > location2)
  {
    tmp = location1;
    location1 = location2;
    location2 = tmp;
  }

  memcpy (     son, father, location1*sizeof(int));
  memcpy (daughter, mother, location1*sizeof(int));

  memcpy (&(     son[location1]), &(mother[location1]), (location2-location1)*sizeof(int));
  memcpy (&(daughter[location1]), &(father[location1]), (location2-location1)*sizeof(int));

  memcpy (&(     son[location2]), &(father[location2]), (pop->len_chromosomes-location2)*sizeof(int));
  memcpy (&(daughter[location2]), &(mother[location2]), (pop->len_chromosomes-location2)*sizeof(int));

  return;
}
//------------------------------------------------------------------------------
//  `Mates' two genotypes by single-point crossover of
//   each chromosome.
//------------------------------------------------------------------------------
void 
ga_crossover_integer_singlepoints (CROSSOVER_VALS)
{

  if (!father || !mother || !son || !daughter)
    die ("Null pointer to entity structure passed");

  ga_singlepoint_crossover_integer_chromosome (pop,
                                               (int *)  father->CH,
                                               (int *)  mother->CH,
                                               (int *)     son->CH,
                                               (int *)daughter->CH);
  return;
}
//------------------------------------------------------------------------------
//  `Mates' two genotypes by double-point crossover of
//   each chromosome.
//------------------------------------------------------------------------------
void 
ga_crossover_integer_doublepoints (CROSSOVER_VALS)
{

  if (!father || !mother || !son || !daughter)
    die ("Null pointer to entity structure passed");

  ga_doublepoint_crossover_integer_chromosome (pop,
                                              (int *)  father->CH,
                                              (int *)  mother->CH,
                                              (int *)     son->CH,
                                              (int *)daughter->CH);
  return;
}
//------------------------------------------------------------------------------
//  `Mates' two genotypes by mixing parents chromsomes.
//   Keeps all chromosomes intact, and therefore do not
//   need to recreate structural data.
//------------------------------------------------------------------------------
void 
ga_crossover_integer_mixing (CROSSOVER_VALS)
{

  if (!father || !mother || !son || !daughter)
    die ("Null pointer to entity structure passed");

  if (random_boolean())
  {
    memcpy (     son->CH, father->CH, pop->len_chromosomes*sizeof(int));
    memcpy (daughter->CH, mother->CH, pop->len_chromosomes*sizeof(int));
    ga_copy_data (pop,      son, father, /* i */0);
    ga_copy_data (pop, daughter, mother, /* i */0);
  }
  else
  {
    memcpy (daughter->CH, father->CH, pop->len_chromosomes*sizeof(int));
    memcpy (     son->CH, mother->CH, pop->len_chromosomes*sizeof(int));
    ga_copy_data (pop, daughter, father, /* i */0);
    ga_copy_data (pop,      son, mother, /* i */0);
  }

  return;
}
//------------------------------------------------------------------------------
//  `Mates' two genotypes by averaging the parents
//   alleles.  son rounded down, daughter rounded up.
//   Keeps no chromosomes intact, and therefore will
//   need to recreate all structural data.
//------------------------------------------------------------------------------
void 
ga_crossover_integer_mean (CROSSOVER_VALS)
{
  int	/*  i, */ j;	  /* Loop over all chromosomes, alleles. */
  int	 sum;	  /* Intermediate value. */

  if (!father || !mother || !son || !daughter)
    die ("Null pointer to entity structure passed.");

  //i = 0;
  for (j=0; j<pop->len_chromosomes; j++)
  {
    sum = ((int *)father->CH)[j] + ((int *)mother->CH)[j];
    if ( sum > 0 )
    {
      ((int *)     son->CH)[j] = sum/2;
      ((int *)daughter->CH)[j] = (sum + 1)/2;
    }
    else
    {
      ((int *)     son->CH)[j] = (sum - 1)/2;
      ((int *)daughter->CH)[j] = sum/2;
    }
  }

  return;
}
//------------------------------------------------------------------------------
//  `Mates' two genotypes by randomizing the parents
//   alleles.
//   Keeps no chromosomes intact, and therefore will
//   need to recreate all structural data.
//------------------------------------------------------------------------------
void 
ga_crossover_integer_allele_mixing (CROSSOVER_VALS)
{
  int	j; /* Loop over all alleles. */

  if (!father || !mother || !son || !daughter)
    die ("Null pointer to entity structure passed.");

  for (j=0; j<pop->len_chromosomes; j++)
  {
    if (random_boolean())
    {
      ((int *)     son->CH)[j] = ((int *)father->CH)[j];
      ((int *)daughter->CH)[j] = ((int *)mother->CH)[j];
    }
    else
    {
      ((int *)daughter->CH)[j] = ((int *)father->CH)[j];
      ((int *)     son->CH)[j] = ((int *)mother->CH)[j];
    }
  }

  return;
}
//------------------------------------------------------------------------------
//
//  BOOLEAN   BOOLEAN   BOOLEAN   BOOLEAN   BOOLEAN   BOOLEAN   BOOLEAN 
//
//------------------------------------------------------------------------------


//------------------------------------------------------------------------------
//  `Mates' two chromosomes by single-point crossover.
//------------------------------------------------------------------------------
void 
ga_singlepoint_crossover_boolean_chromosome (population *pop,
                                             boolean *father, boolean *mother,
                                             boolean *son, boolean *daughter )
{
  int  location;  /* Point of crossover */

  if (!father || !mother || !son || !daughter)
    die ("Null pointer to boolean-array chromosome structure passed.");

  /* Choose crossover point and perform operation */
  location=random_int (pop->len_chromosomes);

  memcpy (son, mother, location*sizeof(boolean));
  memcpy (daughter, father, location*sizeof(boolean));

  memcpy (&(     son[location]), &(father[location]), (pop->len_chromosomes-location)*sizeof(boolean));
  memcpy (&(daughter[location]), &(mother[location]), (pop->len_chromosomes-location)*sizeof(boolean));

  return;
}
//------------------------------------------------------------------------------
//  `Mates' two chromosomes by double-point crossover.
//------------------------------------------------------------------------------
void 
ga_doublepoint_crossover_boolean_chromosome (population *pop,
                                             boolean *father, boolean *mother,
                                             boolean *son, boolean *daughter)
{
  int	location1, location2;	/* Points of crossover. */
  int	tmp;			/* For swapping crossover loci. */

  if (!father || !mother || !son || !daughter)
    die ("Null pointer to boolean-array chromosome structure passed.");

  /* Choose crossover point and perform operation */
  location1 = random_int (pop->len_chromosomes);
  do
  {
    location2 = random_int (pop->len_chromosomes);
  } while (location2==location1);

  if (location1 > location2)
  {
    tmp = location1;
    location1 = location2;
    location2 = tmp;
  }

  memcpy (son, father, location1*sizeof(boolean));
  memcpy (daughter, mother, location1*sizeof(boolean));

  memcpy (&(     son[location1]), &(mother[location1]), (location2-location1)*sizeof(boolean));
  memcpy (&(daughter[location1]), &(father[location1]), (location2-location1)*sizeof(boolean));

  memcpy (&(     son[location2]), &(father[location2]), 
          (pop->len_chromosomes-location2) * sizeof(boolean));
  memcpy (&(daughter[location2]), &(mother[location2]), 
          (pop->len_chromosomes-location2) * sizeof(boolean));

  return;
}
//------------------------------------------------------------------------------
//  `Mates' two genotypes by single-point crossover of
//   each chromosome.
//------------------------------------------------------------------------------
void 
ga_crossover_boolean_singlepoints (CROSSOVER_VALS)
{

  if (!father || !mother || !son || !daughter)
    die ("Null pointer to entity structure passed.");

  ga_singlepoint_crossover_boolean_chromosome (pop,
                                               (boolean *)  father->CH,
                                               (boolean *)  mother->CH,
                                               (boolean *)     son->CH,
                                               (boolean *)daughter->CH);

  return;
}
//------------------------------------------------------------------------------
//  `Mates' two genotypes by double-point crossover of
//  each chromosome.
//------------------------------------------------------------------------------
void 
ga_crossover_boolean_doublepoints (CROSSOVER_VALS)
{

  if (!father || !mother || !son || !daughter)
    die ("Null pointer to entity structure passed.");

  ga_doublepoint_crossover_boolean_chromosome (pop,
                                               (boolean *)  father->CH,
                                               (boolean *)  mother->CH,
                                               (boolean *)     son->CH,
                                               (boolean *)daughter->CH);

  return;
}
//------------------------------------------------------------------------------
//  `Mates' two genotypes by mixing parents chromsomes.
//   Keeps all chromosomes intact, and therefore do not
//   need to recreate structural data.
//------------------------------------------------------------------------------
void 
ga_crossover_boolean_mixing (CROSSOVER_VALS)
{

  if (!father || !mother || !son || !daughter)
    die ("Null pointer to entity structure passed.");

  if (random_boolean())
  {
    memcpy (     son->CH, father->CH, pop->len_chromosomes*sizeof(boolean));
    memcpy (daughter->CH, mother->CH, pop->len_chromosomes*sizeof(boolean));
    ga_copy_data (pop,      son, father, /* i */0);
    ga_copy_data (pop, daughter, mother, /* i */0);
  }
  else
  {
    memcpy (daughter->CH, father->CH, pop->len_chromosomes*sizeof(boolean));
    memcpy (     son->CH, mother->CH, pop->len_chromosomes*sizeof(boolean));
    ga_copy_data (pop, daughter, father, /* i */0);
    ga_copy_data (pop,      son, mother, /* i */0);
  }

  return;
}
//------------------------------------------------------------------------------
//  `Mates' two genotypes by randomizing the parents
//   alleles.
//   Keeps no chromosomes intact, and therefore will
//   need to recreate all structural data.
//------------------------------------------------------------------------------
void 
ga_crossover_boolean_allele_mixing (CROSSOVER_VALS)
{
  int	j;   /* Loop over all chromosomes, alleles. */

  if (!father || !mother || !son || !daughter)
    die ("Null pointer to entity structure passed.");

  for (j=0; j<pop->len_chromosomes; j++)
  {
    if (random_boolean())
    {
      ((boolean *)     son->CH)[j] = ((boolean *)father->CH)[j];
      ((boolean *)daughter->CH)[j] = ((boolean *)mother->CH)[j];
    }
    else
    {
      ((boolean *)daughter->CH)[j] = ((boolean *)father->CH)[j];
      ((boolean *)     son->CH)[j] = ((boolean *)mother->CH)[j];
    }
  }

  return;
}
//------------------------------------------------------------------------------
//
//  CHAR   CHAR   CHAR   CHAR   CHAR   CHAR   CHAR   CHAR   CHAR   CHAR   CHAR 
//
//------------------------------------------------------------------------------


//------------------------------------------------------------------------------
//  `Mates' two genotypes by mixing parents chromsomes.
//   Keeps all chromosomes intact, and therefore do not
//   need to recreate structural data.
//------------------------------------------------------------------------------
void 
ga_crossover_char_mixing (CROSSOVER_VALS)
{

  if (!father || !mother || !son || !daughter)
    die ("Null pointer to entity structure passed");

  if (random_boolean())
  {
    memcpy (     son->CH, father->CH, pop->len_chromosomes*sizeof(char) );
    memcpy (daughter->CH, mother->CH, pop->len_chromosomes*sizeof(char) );
    ga_copy_data (pop,      son, father, /* i */0);
    ga_copy_data (pop, daughter, mother, /* i */0);
  }
  else
  {
    memcpy (daughter->CH, father->CH, pop->len_chromosomes*sizeof(char) );
    memcpy (     son->CH, mother->CH, pop->len_chromosomes*sizeof(char) );
    ga_copy_data (pop, daughter, father, /* i */0);
    ga_copy_data (pop,      son, mother, /* i */0);
  }

  return;
}
//------------------------------------------------------------------------------
//  `Mates' two genotypes by randomizing the parents
//   alleles.
//   Keeps no chromosomes intact, and therefore will
//   need to recreate all structural data.
//------------------------------------------------------------------------------
void 
ga_crossover_char_allele_mixing (CROSSOVER_VALS)
{
  int	j;    /* Loop over all chromosomes, alleles. */

  if (!father || !mother || !son || !daughter)
    die ("Null pointer to entity structure passed.");

  for (j=0; j<pop->len_chromosomes; j++)
  {
    if (random_boolean())
    {
      ((char *)     son->CH)[j] = ((char *)father->CH)[j];
      ((char *)daughter->CH)[j] = ((char *)mother->CH)[j];
    }
    else
    {
      ((char *)daughter->CH)[j] = ((char *)father->CH)[j];
      ((char *)     son->CH)[j] = ((char *)mother->CH)[j];
    }
  }

  return;
}
//------------------------------------------------------------------------------
//  `Mates' two genotypes by single-point crossover of
//   each chromosome.
//------------------------------------------------------------------------------
void 
ga_crossover_char_singlepoints (CROSSOVER_VALS)
{
  int  location;  /* Point of crossover. */

  if (!father || !mother || !son || !daughter)
    die ("Null pointer to entity structure passed");

  /* Choose crossover point and perform operation */
  location = random_int(pop->len_chromosomes);

  memcpy (son->CH, mother->CH, location*sizeof(char) );
  memcpy (daughter->CH, father->CH, location*sizeof(char));

  memcpy (&(((char *)son->CH)[location]),
          &(((char *)father->CH)[location]),
          (pop->len_chromosomes-location)*sizeof(char) );
  memcpy (&(((char *)daughter->CH)[location]),
          &(((char *)mother->CH)[location]),
          (pop->len_chromosomes-location)*sizeof(char) );

  return;
}
//------------------------------------------------------------------------------
//  `Mates' two genotypes by double-point crossover of
//   each chromosome.
//------------------------------------------------------------------------------
void 
ga_crossover_char_doublepoints (CROSSOVER_VALS)
{
  int	location1, location2;	/* Points of crossover. */
  int	tmp;			/* For swapping crossover loci. */

  if (!father || !mother || !son || !daughter)
    die ("Null pointer to entity structure passed");

    /* Choose crossover point and perform operation */
    location1 = random_int (pop->len_chromosomes);
    do
    {
      location2 = random_int(pop->len_chromosomes);
    } while (location2==location1);

    if (location1 > location2)
    {
      tmp = location1;
      location1 = location2;
      location2 = tmp;
    }

    memcpy (     son->CH, father->CH, location1*sizeof(char));
    memcpy (daughter->CH, mother->CH, location1*sizeof(char));

    memcpy (&(((char *)   son->CH)[location1]),
            &(((char *)mother->CH)[location1]), (location2-location1)*sizeof(char));
    memcpy (&(((char *)daughter->CH)[location1]),
            &(((char *)  father->CH)[location1]), (location2-location1)*sizeof(char));

    memcpy (&(((char *)   son->CH)[location2]),
            &(((char *)father->CH)[location2]), 
            (pop->len_chromosomes-location2)*sizeof(char));

    memcpy (&(((char *)daughter->CH)[location2]),
            &(((char *)  mother->CH)[location2]),
            (pop->len_chromosomes-location2)*sizeof(char));
  //}

  return;
}
//------------------------------------------------------------------------------
//
//  DOUBLE   DOUBLE   DOUBLE   DOUBLE   DOUBLE   DOUBLE   DOUBLE   DOUBLE 
//
//------------------------------------------------------------------------------


//------------------------------------------------------------------------------
//  `Mates' two genotypes by mixing parents chromsomes.
//   Keeps all chromosomes intact, and therefore do not
//   need to recreate structural data.
//------------------------------------------------------------------------------
void 
ga_crossover_double_mixing (CROSSOVER_VALS)
{

  if (!father || !mother || !son || !daughter)
    die ("Null pointer to entity structure passed");

  if (random_boolean ())
  {
    memcpy (     son->CH, father->CH, pop->len_chromosomes*sizeof(double) );
    memcpy (daughter->CH, mother->CH, pop->len_chromosomes*sizeof(double) );
    ga_copy_data (pop,      son, father, 0/* i */);
    ga_copy_data (pop, daughter, mother, 0/* i */);
  }
  else
  {
    memcpy (daughter->CH, father->CH, pop->len_chromosomes*sizeof(double) );
    memcpy (     son->CH, mother->CH, pop->len_chromosomes*sizeof(double) );
    ga_copy_data (pop, daughter, father, 0/* i */);
    ga_copy_data (pop,      son, mother, 0/* i */);
  }

  return;
}
//------------------------------------------------------------------------------
//  `Mates' two genotypes by averaging the parents
//   alleles.
//   Keeps no chromosomes intact, and therefore will
//   need to recreate all structural data.
//   FIXME: Children are identical!
//------------------------------------------------------------------------------
void 
ga_crossover_double_mean (CROSSOVER_VALS)
{
  int  j;  /* Loop over all alleles. */

  if (!father || !mother || !son || !daughter)
    die ("Null pointer to entity structure passed.");

  for (j=0; j<pop->len_chromosomes; j++)
  {
    ((double *)     son->CH)[j] = 0.5 * (((double *)father->CH)[j] + ((double *)mother->CH)[j]);
    ((double *)daughter->CH)[j] = 0.5 * (((double *)father->CH)[j] + ((double *)mother->CH)[j]);
  }

  return;
}
//------------------------------------------------------------------------------
//  `Mates' two genotypes by randomizing the parents
//   alleles.
//   Keeps no chromosomes intact, and therefore will
//   need to recreate all structural data.
//------------------------------------------------------------------------------
void 
ga_crossover_double_allele_mixing (CROSSOVER_VALS)
{
  int  j;  /* Loop over all alleles. */

  if (!father || !mother || !son || !daughter)
    die ("Null pointer to entity structure passed.");

  for (j=0; j<pop->len_chromosomes; j++)
  {
    if (random_boolean())
    {
      ((double *)     son->CH)[j] = ((double *)father->CH)[j];
      ((double *)daughter->CH)[j] = ((double *)mother->CH)[j];
    }
    else
    {
      ((double *)daughter->CH)[j] = ((double *)father->CH)[j];
      ((double *)     son->CH)[j] = ((double *)mother->CH)[j];
    }
  }
  //}

  return;
}
//------------------------------------------------------------------------------
//  `Mates' two chromosomes by single-point crossover.
//------------------------------------------------------------------------------
void 
ga_singlepoint_crossover_double_chromosome (population *pop,
                                            double *father, double *mother,
                                            double *son, double *daughter)
{
  int	location;  /* Point of crossover */

  if (!father || !mother || !son || !daughter)
    die ("Null pointer to chromosome structure passed.");

  /* Choose crossover point and perform operation */
  location = random_int (pop->len_chromosomes);

  memcpy (     son, mother, location*sizeof(double));
  memcpy (daughter, father, location*sizeof(double));

  memcpy (&(     son[location]), &(father[location]), (pop->len_chromosomes-location)*sizeof(double));
  memcpy (&(daughter[location]), &(mother[location]), (pop->len_chromosomes-location)*sizeof(double));

  return;
}
//------------------------------------------------------------------------------
//  `Mates' two chromosomes by double-point crossover.
//------------------------------------------------------------------------------
void 
ga_doublepoint_crossover_double_chromosome (population *pop,
                                            double *father, double *mother,
                                            double    *son, double    *dau)
{
  int	location1, location2;	/* Points of crossover. */
  int	tmp;			/* For swapping crossover loci. */

  if (!father || !mother || !son || !dau)
    die ("Null pointer to chromosome structure passed.");

  /* Choose crossover point and perform operation */

  location1 = random_int(pop->len_chromosomes);
  do
  {
    location2 = random_int (pop->len_chromosomes);
  } while (location2 == location1); 

  // получили две несовпадающие точки (целочисленные)

  if (location1 > location2)
  {
    tmp = location1;
    location1 = location2;
    location2 = tmp;
  }

  //fprintf (stderr, "location1 = %d \n", location1);
  //fprintf (stderr, "location2 = %d \n", location2);

 // теперь они в нужном порядке (по возрастающей)  .....1.....2.....

  memcpy (son, father, location1 * sizeof(double)); // копируем в son первый кусок от отца
  memcpy (dau, mother, location1 * sizeof(double)); // копируем в dau первый кусок от матери

  memcpy (&(son[location1]), &(mother[location1]), (location2-location1)*sizeof(double));
  memcpy (&(dau[location1]), &(father[location1]), (location2-location1)*sizeof(double));

  memcpy (&(son[location2]), &(father[location2]), (pop->len_chromosomes-location2)*sizeof(double));
  memcpy (&(dau[location2]), &(mother[location2]), (pop->len_chromosomes-location2)*sizeof(double));

  return;
}
//------------------------------------------------------------------------------
//  `Mates' two genotypes by single-point crossover of
//   each chromosome.
//------------------------------------------------------------------------------
void 
ga_crossover_double_singlepoints (CROSSOVER_VALS)
{

  if (!father || !mother || !son || !daughter)
    die ("Null pointer to entity structure passed");

  ga_singlepoint_crossover_double_chromosome (pop,
                                              (double *) father->CH,
                                              (double *) mother->CH,
                                              (double *) son->CH,
                                              (double *) daughter->CH);
  return;
}
//------------------------------------------------------------------------------
//  `Mates' two genotypes by double-point crossover of
//   each chromosome.
//------------------------------------------------------------------------------
void 
ga_crossover_double_doublepoints (CROSSOVER_VALS)
{

  if (!father || !mother || !son || !daughter)
    die ("Null pointer to entity structure passed");

  ga_doublepoint_crossover_double_chromosome (pop,
                                              (double *) father->CH,
                                              (double *) mother->CH,
                                              (double *) son->CH,
                                              (double *) daughter->CH);
  return;
}
//------------------------------------------------------------------------------
//
//  BITSTRING   BITSTRING   BITSTRING   BITSTRING   BITSTRING   BITSTRING 
//
//------------------------------------------------------------------------------


//------------------------------------------------------------------------------
//  `Mates' two genotypes by single-point crossover of
//   each chromosome.
//------------------------------------------------------------------------------
void 
ga_crossover_bitstring_singlepoints (CROSSOVER_VALS)
{
  int		location;	/* Point of crossover. */

  if (!father || !mother || !son || !daughter)
    die ("Null pointer to entity structure passed");

  /* Choose crossover point and perform operation */
  location=random_int (pop->len_chromosomes);

  ga_bit_copy (son->CH, mother->CH,
              0, 0, location);
  ga_bit_copy (daughter->CH, father->CH,
              0, 0, location);

  ga_bit_copy (daughter->CH, mother->CH,
              location, location, pop->len_chromosomes-location);

  ga_bit_copy (son->CH, father->CH,
              location, location, pop->len_chromosomes-location);

  return;
}
//------------------------------------------------------------------------------
//  `Mates' two genotypes by double-point crossover of
//   each chromosome.
//   parameters:   population *pop	Population structure.
//		entity *father, *mother	Parent entities.
//		entity *son, *daughter	Child entities.
//------------------------------------------------------------------------------
void 
ga_crossover_bitstring_doublepoints (CROSSOVER_VALS)
{
  int	location1, location2;	/* Points of crossover. */
  int	tmp;			/* For swapping crossover loci. */

  if (!father || !mother || !son || !daughter)
    die ("Null pointer to entity structure passed");

  /* Choose crossover point and perform operation */
  location1=random_int(pop->len_chromosomes);
  do
  {
    location2=random_int(pop->len_chromosomes);
  } while (location2==location1);

  if (location1 > location2)
  {
    tmp = location1;
    location1 = location2;
    location2 = tmp;
  }

  ga_bit_copy (son->CH, mother->CH,
              0, 0, location1);
  ga_bit_copy (daughter->CH, father->CH,
              0, 0, location1);

  ga_bit_copy (son->CH, father->CH,
              location1, location1, location2-location1);
  ga_bit_copy (daughter->CH, mother->CH,
              location1, location1, location2-location1);

  ga_bit_copy (son->CH, mother->CH,
              location2, location2, pop->len_chromosomes-location2);
  ga_bit_copy (daughter->CH, father->CH,
              location2, location2, pop->len_chromosomes-location2);
  //}

  return;
}
//------------------------------------------------------------------------------
//  `Mates' two genotypes by mixing parents chromsomes.
//   Keeps all chromosomes intact, and therefore do not
//   need to recreate structural data.
//------------------------------------------------------------------------------
void 
ga_crossover_bitstring_mixing (CROSSOVER_VALS)
{

  if (!father || !mother || !son || !daughter)
    die ("Null pointer to entity structure passed");

  if (random_boolean())
  {
    ga_bit_clone (son->CH, father->CH, pop->len_chromosomes);
    ga_bit_clone (daughter->CH, mother->CH, pop->len_chromosomes);
    ga_copy_data (pop,      son, father, /* i */0);
    ga_copy_data (pop, daughter, mother, /* i */0);
  }
  else
  {
    ga_bit_clone (daughter->CH, father->CH, pop->len_chromosomes);
    ga_bit_clone (son->CH, mother->CH, pop->len_chromosomes);
    ga_copy_data (pop, daughter, father, /* i */0);
    ga_copy_data (pop,      son, mother, /* i */0);
  }

  return;
}
//------------------------------------------------------------------------------
//  `Mates' two genotypes by randomizing the parents
//   alleles.
//   Keeps no chromosomes intact, and therefore will
//   need to recreate all structural data.
//------------------------------------------------------------------------------
void 
ga_crossover_bitstring_allele_mixing (CROSSOVER_VALS)
{
  int	j;  /* Loop over all alleles. */

  /* Checks. */
  if (!father || !mother || !son || !daughter)
    die ("Null pointer to entity structure passed.");

  for (j=0; j<pop->len_chromosomes; j++)
  {
    if (random_boolean())
    {
      if (ga_bit_get (father->CH,j))  ga_bit_set  (son->CH, j);
      else                            ga_bit_clear(son->CH, j);

      if (ga_bit_get(mother->CH,j))  ga_bit_set   (daughter->CH, j);
      else                           ga_bit_clear (daughter->CH, j);
    }
    else
    {
      if (ga_bit_get (father->CH,j)) ga_bit_set   (daughter->CH, j);
      else                           ga_bit_clear (daughter->CH, j);

      if (ga_bit_get (mother->CH,j)) ga_bit_set   (son->CH,j);
      else                           ga_bit_clear (son->CH,j);
    }
  }

  return;
}
//******************************************************************************
//------------------------------------------------------------------------------


