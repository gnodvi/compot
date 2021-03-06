/**********************************************************************
  ga_seed.c
 **********************************************************************

  ga_seed - Genetic algorithm genome initialisation operators.
  Copyright ©2000-2006, Stewart Adcock <stewart@linux-domain.com>
  All rights reserved.

  Synopsis:     Routines for performing GA seeding operations.

		Seeding operations generate genetic data by some
		non-evolutionary means.  Typically, this is often
		just random generation.

 **********************************************************************/

//#include "ga_core.h"
#include "gaul.h"

/**********************************************************************
  synopsis:	Seed genetic data for a single entity with a boolean
		chromosome by randomly setting each bit.
  parameters:	population *pop
		entity *adam
  return:	success
 **********************************************************************/
boolean 
ga_seed_boolean_random (population *pop, entity *adam)
{
  //int		chromo;		/* Index of chromosome to seed */
  int		point;		/* Index of allele to seed */

  /* Checks. */
  if (!pop) die("Null pointer to population structure passed.");
  if (!adam) die("Null pointer to entity structure passed.");

  /* Seeding. */
  //chromo=0;
  //for (chromo=0; chromo<pop->num_chromosomes; chromo++)
  //{
  for (point=0; point<pop->len_chromosomes; point++)
  {
    ((boolean *)adam->CH/* chromosome[chromo] */)[point] = random_boolean();
  }
  //}

  return TRUE;
}
/**********************************************************************
  synopsis:	Seed genetic data for a single entity with a boolean
		chromosome by setting each bit to zero.
  parameters:	population *pop
		entity *adam
  return:	success
 **********************************************************************/
boolean 
ga_seed_boolean_zero (population *pop, entity *adam)
{
  //int		chromo;		/* Index of chromosome to seed */
  int		point;		/* Index of allele to seed */

  /* Checks. */
  if (!pop) die("Null pointer to population structure passed.");
  if (!adam) die("Null pointer to entity structure passed.");

  /* Seeding. */
  //chromo=0;
  //for (chromo=0; chromo<pop->num_chromosomes; chromo++)
  //{
  for (point=0; point<pop->len_chromosomes; point++)
  {
    ((boolean *)adam->CH/* chromosome[chromo] */)[point] = 0;
  }
  //}

  return TRUE;
}
/**********************************************************************
  synopsis:	Seed genetic data for a single entity with an integer
		chromosome by randomly setting each allele.
  parameters:	population *pop
		entity *adam
  return:	success
 **********************************************************************/
boolean 
ga_seed_integer_random (population *pop, entity *adam)
{
  //int		chromo;		/* Index of chromosome to seed */
  int		point;		/* Index of allele to seed */

  /* Checks. */
  if (!pop) die("Null pointer to population structure passed.");
  if (!adam) die("Null pointer to entity structure passed.");

  /* Seeding. */
  //chromo=0;
  //for (chromo=0; chromo<pop->num_chromosomes; chromo++)
  //{
  for (point=0; point<pop->len_chromosomes; point++)
  {
    ((int *)adam->CH/* chromosome[chromo] */)[point] =
      random_int_range(pop->allele_min_integer,pop->allele_max_integer);
  }
  //}

  return TRUE;
}
/**********************************************************************
  synopsis:	Seed genetic data for a single entity with an integer
		chromosome by setting each allele to zero.
  parameters:	population *pop
		entity *adam
  return:	success
 **********************************************************************/
boolean 
ga_seed_integer_zero (population *pop, entity *adam)
{
  //int		chromo;		/* Index of chromosome to seed */
  int		point;		/* Index of allele to seed */

  /* Checks. */
  if (!pop) die("Null pointer to population structure passed.");
  if (!adam) die("Null pointer to entity structure passed.");

  /* Seeding. */
  //chromo=0;
  //for (chromo=0; chromo<pop->num_chromosomes; chromo++)
  //{
  for (point=0; point<pop->len_chromosomes; point++)
  {
    ((int *)adam->CH/* chromosome[chromo] */)[point] = 0;
  }
  //}

  return TRUE;
}
/**********************************************************************
  synopsis:	Seed genetic data for a single entity with a character
		chromosome by randomly setting each allele.
  parameters:	population *pop
		entity *adam
  return:	success
 **********************************************************************/
boolean 
ga_seed_char_random (population *pop, entity *adam)
{
  //int		chromo;		/* Index of chromosome to seed */
  int		point;		/* Index of allele to seed */

  /* Checks. */
  if (!pop) die("Null pointer to population structure passed.");
  if (!adam) die("Null pointer to entity structure passed.");

  /* Seeding. */
  //chromo=0;
  //for (chromo=0; chromo<pop->num_chromosomes; chromo++)
  //{
  for (point=0; point<pop->len_chromosomes; point++)
  {
    ((char *)adam->CH/* chromosome[chromo] */)[point]
      = (char)random_int(CHAR_MAX-CHAR_MIN)+CHAR_MIN;
  }
  //}

  return TRUE;
}
/**********************************************************************
  synopsis:	Seed genetic data for a single entity with a double-
		precision floating-point chromosome by randomly
		setting each allele.
  parameters:	population *pop
		entity *adam
  return:	success
 **********************************************************************/
boolean 
ga_seed_double_random (population *pop, entity *adam)
{
  //int		chromo;		/* Index of chromosome to seed */
  int		point;		/* Index of allele to seed */

  /* Checks. */
  if (!pop) die("Null pointer to population structure passed.");
  if (!adam) die("Null pointer to entity structure passed.");

  /* Seeding. */
  //chromo=0;
  //for (chromo=0; chromo<pop->num_chromosomes; chromo++)
  //{
  for (point=0; point<pop->len_chromosomes; point++)
  {
    ((double *)adam->CH/* chromosome[chromo] */)[point] =
      random_double_range (pop->allele_min_double, pop->allele_max_double);
  }
  //}

  return TRUE;
}
/**********************************************************************
  synopsis:	Seed genetic data for a single entity with a double-
		precision floating-point chromosome by randomly
		setting each allele using a unit gaussian distribution.
  parameters:	population *pop
		entity *adam
  return:	success
 **********************************************************************/
boolean 
ga_seed_double_random_unit_gaussian (population *pop, entity *adam)
{
  //int		chromo;		/* Index of chromosome to seed */
  int		point;		/* Index of allele to seed */

  /* Checks. */
  if (!pop)  die ("Null pointer to population structure passed.");
  if (!adam) die ("Null pointer to entity structure passed.");

  /* Seeding. */
  //chromo=0;
  //for (chromo=0; chromo<pop->num_chromosomes; chromo++)
  //{
  for (point=0; point<pop->len_chromosomes; point++)
  {
    ((double *)adam->CH/* chromosome[chromo] */)[point] = random_unit_gaussian();
  }
  //}

  return TRUE;
}
/**********************************************************************
 **********************************************************************/
boolean 
ga_seed_double_zero (population *pop, entity *adam)
{
  //int		chromo;		/* Index of chromosome to seed */
  int		point;		/* Index of allele to seed */

  /* Checks. */
  if (!pop)  die("Null pointer to population structure passed.");
  if (!adam) die("Null pointer to entity structure passed.");

  /* Seeding. */
  //chromo=0;
  //for (chromo=0; chromo<pop->num_chromosomes; chromo++)
  //{
  for (point=0; point<pop->len_chromosomes; point++)
  {
    ((double *)adam->CH/* chromosome[chromo] */)[point] = 0.0;
  }
  //}

  return TRUE;
}
//------------------------------------------------------------------------------
char
get_random_wordchar ()
{

  GAULFUNC unsigned int char_num;
  char ch;

  int randmax = '~' - ' ';

  char_num = random_int (randmax) + ' ';

  ch = (char) char_num;

  return (ch);
}
//------------------------------------------------------------------------------
boolean 
ga_seed_printable_random (population *pop, entity *adam)
{
  //int		chromo;		/* Index of chromosome to seed */
  int		point;		/* Index of allele to seed */

  char ch;

  /* Checks. */
  if (!pop)  die ("Null pointer to population structure passed.");
  if (!adam) die ("Null pointer to entity structure passed.");

  /* Seeding. */
  //chromo=0;
  //for (chromo=0; chromo<pop->num_chromosomes; chromo++)
  //{
  for (point = 0; point < pop->len_chromosomes; point++)
  {
    ch = get_random_wordchar ();

    ((char *)adam->CH)[point] = ch ;
  }
  //}

  return TRUE;
}
//------------------------------------------------------------------------------
//  synopsis:	Randomly seed bitstring chromosomes.
//  parameters:	population *pop
//		entity *adam
//  return:	success

//------------------------------------------------------------------------------
boolean 
ga_seed_bitstring_random (population *pop, entity *adam)
{
  //int		chromo;		/* Index of chromosome to seed */
  int		point;		/* Index of allele to seed */

  /* Checks. */
  if (!pop)  die("Null pointer to population structure passed.");
  if (!adam) die("Null pointer to entity structure passed.");

  /* Seeding. */
  //chromo=0;
  //for (chromo=0; chromo<pop->num_chromosomes; chromo++)
  //{
  for (point=0; point<pop->len_chromosomes; point++)
  {
    ga_bit_randomize (adam->CH/* chromosome[chromo] */,point);
  }
  //}

  return TRUE;
}
//------------------------------------------------------------------------------
/**********************************************************************
  synopsis:	Seed bitstring chromosomes with zeros.
  parameters:	population *pop
		entity *adam
  return:	success
 **********************************************************************/
boolean 
ga_seed_bitstring_zero (population *pop, entity *adam)
{
  //int  chromo;	/* Index of chromosome to seed */
  int  point;	/* Index of allele to seed */

  /* Checks. */
  if (!pop) die("Null pointer to population structure passed.");
  if (!adam) die("Null pointer to entity structure passed.");

  /* Seeding. */
  //chromo=0;
  //for (chromo=0; chromo<pop->num_chromosomes; chromo++)
  //{
  for (point=0; point<pop->len_chromosomes; point++)
  {
    ga_bit_clear (adam->CH/* chromosome[chromo] */, point);
  }
  //}

  return TRUE;
}
//******************************************************************************


