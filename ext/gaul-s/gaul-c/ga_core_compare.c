//------------------------------------------------------------------------------
/**********************************************************************
  ga_compare.c
 **********************************************************************

  ga_compare - Entity comparison routines.
  Copyright ©2003-2006, Stewart Adcock <stewart@linux-domain.com>
  All rights reserved.

  Synopsis:     Routines for comparing entities.

		These routines return a distance between two entities.

 **********************************************************************/

//#include "ga_core.h"
#include "gaul.h"

//------------------------------------------------------------------------------
/**********************************************************************
  synopsis:	Compares two char-array genomes and returns their
		hamming distance.
  parameters:	population *pop	Population of entities (you may use
			differing populations if they are "compatible")
		entity *alpha	Test entity.
		entity *beta	Test entity.
  return:	Returns Hamming distance between two entities' genomes.
 **********************************************************************/
//------------------------------------------------------------------------------
double 
ga_compare_char_hamming (population *pop, entity *alpha, entity *beta)
{
  int	 /* i, */j;	/* Loop variable over all chromosomes, alleles. */
  char	 *a, *b;	/* Pointers to chromosomes. */

  int	 dist = 0;	/* Genomic distance.        */
  int    aj, bj;

  /* Checks */
  if (!alpha || !beta) die ("Null pointer to entity structure passed");

  //i = 0;
  //for (i=0; i<pop->num_chromosomes; i++)
  //{

  a = (char *) (alpha->CH);
  b = (char *) ( beta->CH);

  for (j = 0; j < pop->len_chromosomes; j++)
  {
    aj = (int) a[j];
    bj = (int) b[j];

    //dist += abs ((int) a[j] - b[j]);
    dist += abs (aj - bj);
  }
  //}

  return (double) dist;
}
//------------------------------------------------------------------------------
/**********************************************************************
  synopsis:	Compares two char-array genomes and returns their
		euclidean distance.
  parameters:	population *pop	Population of entities (you may use
			differing populations if they are "compatible")
		entity *alpha	Test entity.
		entity *beta	Test entity.
  return:	Returns Euclidean distance between two entities' genomes.
 **********************************************************************/
//------------------------------------------------------------------------------
double 
ga_compare_char_euclidean (population *pop, entity *alpha, entity *beta)
{
  int	     /* i, */j;	      /* Loop variable over all chromosomes, alleles. */
  double     sqdistsum = 0.0; /* Genomic distance.        */
  char	     *a, *b;	      /* Pointers to chromosomes. */

  /* Checks */
  if (!alpha || !beta) die("Null pointer to entity structure passed");

  //i = 0;
  //for (i=0; i<pop->num_chromosomes; i++)
  //{
  a = (char *)(alpha->CH/* chromosome[i] */);
  b = (char *)( beta->CH/* chromosome[i] */);

  for (j = 0; j < pop->len_chromosomes; j++)
  {
    sqdistsum += SQU ((int) a[j] - b[j]);
  }
  //}

  return sqrt (sqdistsum);
}
//------------------------------------------------------------------------------
/**********************************************************************
  synopsis:	Compares two integer-array genomes and returns their
		hamming distance.
  parameters:	population *pop	Population of entities (you may use
			differing populations if they are "compatible")
		entity *alpha	Test entity.
		entity *beta	Test entity.
  return:	Returns Hamming distance between two entities' genomes.
 **********************************************************************/
//------------------------------------------------------------------------------
double 
ga_compare_integer_hamming (population *pop, entity *alpha, entity *beta)
{
  int	   /* i, */j;	  /* Loop variable over all chromosomes, alleles. */
  int	   dist = 0;	  /* Genomic distance.        */
  int	   *a, *b;	  /* Pointers to chromosomes. */

  /* Checks */
  if (!alpha || !beta) die ("Null pointer to entity structure passed");

  //i = 0;
  //for (i=0; i<pop->num_chromosomes; i++)
  //{
  a = (int *) (alpha->CH/* chromosome[i] */);
  b = (int *) ( beta->CH/* chromosome[i] */);

  for (j = 0; j < pop->len_chromosomes; j++)
  {
    dist += abs (a[j] - b[j]);
  }
  //}

  return (double) dist;
}
//------------------------------------------------------------------------------
/**********************************************************************
  synopsis:	Compares two integer-array genomes and returns their
		euclidean distance.
  parameters:	population *pop	Population of entities (you may use
			differing populations if they are "compatible")
		entity *alpha	Test entity.
		entity *beta	Test entity.
  return:	Returns Euclidean distance between two entities' genomes.
 **********************************************************************/
//------------------------------------------------------------------------------
double 
ga_compare_integer_euclidean (population *pop, entity *alpha, entity *beta)
{
  int	    /* i, */j;		/* Loop variable over all chromosomes, alleles. */
  double	sqdistsum=0.0;		/* Genomic distance. */
  int		*a, *b;			/* Pointers to chromosomes. */

  /* Checks */
  if (!alpha || !beta) die("Null pointer to entity structure passed");

  //i = 0;
  //for (i=0; i<pop->num_chromosomes; i++)
  //{
  a = (int *)(alpha->CH/* chromosome[i] */);
  b = (int *)( beta->CH/* chromosome[i] */);

  for (j=0; j<pop->len_chromosomes; j++)
  {
    sqdistsum += SQU(a[j]-b[j]);
  }
  //}

  return sqrt(sqdistsum);
}
/**********************************************************************
  synopsis:	Compares two double-array genomes and returns their
		hamming distance.
  parameters:	population *pop	Population of entities (you may use
			differing populations if they are "compatible")
		entity *alpha	Test entity.
		entity *beta	Test entity.
  return:	Returns Hamming distance between two entities' genomes.
 **********************************************************************/
double 
ga_compare_double_hamming (population *pop, entity *alpha, entity *beta)
{
  int	    /* i, */j;	/* Loop variable over all chromosomes, alleles. */
  double	dist=0.0;	/* Genomic distance. */
  double	*a, *b;		/* Pointers to chromosomes. */

  /* Checks */
  if (!alpha || !beta) die("Null pointer to entity structure passed");

  //i = 0;
  //for (i=0; i<pop->num_chromosomes; i++)
  //{
  a = (double *)(alpha->CH /* chromosome[i] */);
  b = (double *)( beta->CH /* chromosome[i] */);

  for (j=0; j<pop->len_chromosomes; j++)
  {
    dist += ABS (a[j]-b[j]);
  }
  //}

  return dist;
}
//------------------------------------------------------------------------------
/**********************************************************************
  synopsis:	Compares two double-array genomes and returns their
		euclidean distance.
  parameters:	population *pop	Population of entities (you may use
			differing populations if they are "compatible")
		entity *alpha	Test entity.
		entity *beta	Test entity.
  return:	Returns Euclidean distance between two entities' genomes.
 **********************************************************************/
double 
ga_compare_double_euclidean (population *pop, entity *alpha, entity *beta)
{
  int	    /* i, */j;	    /* Loop variable over all chromosomes, alleles. */
  double    sqdistsum=0.0;  /* Genomic distance. */
  double    *a, *b;	    /* Pointers to chromosomes. */

  /* Checks */
  if (!alpha || !beta) die("Null pointer to entity structure passed");

  //i = 0;
  //for (i=0; i<pop->num_chromosomes; i++)
  //{
  a = (double *)(alpha->CH /* chromosome[i] */);
  b = (double *)( beta->CH /* chromosome[i] */);

  for (j=0; j<pop->len_chromosomes; j++)
  {
    sqdistsum += SQU(a[j]-b[j]);
  }
  //}

  return sqrt(sqdistsum);
}
/**********************************************************************
  synopsis:	Compares two boolean-array genomes and returns their
		hamming distance.
  parameters:	population *pop	Population of entities (you may use
			differing populations if they are "compatible")
		entity *alpha	Test entity.
		entity *beta	Test entity.
  return:	Returns Hamming distance between two entities' genomes.
 **********************************************************************/
double 
ga_compare_boolean_hamming (population *pop, entity *alpha, entity *beta)
{
  int	    /* i, */j;	/* Loop variable over all chromosomes, alleles. */
  int		dist=0;		/* Genomic distance. */
  boolean	*a, *b;		/* Pointers to chromosomes. */

  /* Checks */
  if (!alpha || !beta) die("Null pointer to entity structure passed");

  //i = 0;
  //for (i=0; i<pop->num_chromosomes; i++)
  //{
  a = (boolean *)(alpha->CH /* chromosome[i] */);
  b = (boolean *)( beta->CH /* chromosome[i] */);

  for (j=0; j<pop->len_chromosomes; j++)
  {
    dist += (a[j]!=b[j]);
  }
  //}

  return (double) dist;
}
/**********************************************************************
  synopsis:	Compares two boolean-array genomes and returns their
		euclidean distance.
  parameters:	population *pop	Population of entities (you may use
			differing populations if they are "compatible")
		entity *alpha	Test entity.
		entity *beta	Test entity.
  return:	Returns Euclidean distance between two entities' genomes.
 **********************************************************************/
double 
ga_compare_boolean_euclidean (population *pop, entity *alpha, entity *beta)
{
  int	    /* i, */j;		/* Loop variable over all chromosomes, alleles. */
  double	sqdistsum=0.0;		/* Genomic distance. */
  boolean	*a, *b;			/* Pointers to chromosomes. */

  /* Checks */
  if (!alpha || !beta) die("Null pointer to entity structure passed");

  //i = 0;
  //for (i=0; i<pop->num_chromosomes; i++)
  //{
  a = (boolean *)(alpha->CH /* chromosome[i] */);
  b = (boolean *)( beta->CH /* chromosome[i] */);

  for (j=0; j<pop->len_chromosomes; j++)
  {
    sqdistsum += (a[j]!=b[j]);
  }
  //}

  return sqrt(sqdistsum);
}
/**********************************************************************
  synopsis:	Compares two bitstring-array genomes and returns their
		hamming distance.
  parameters:	population *pop	Population of entities (you may use
			differing populations if they are "compatible")
		entity *alpha	Test entity.
		entity *beta	Test entity.
  return:	Returns Hamming distance between two entities' genomes.
 **********************************************************************/
double 
ga_compare_bitstring_hamming (population *pop, entity *alpha, entity *beta)
{
  int	    /* i, */j;   /* Loop variable over all chromosomes, alleles. */
  int		dist=0;	     /* Genomic distance. */
  gaulbyte	*a, *b;	     /* Pointers to chromosomes. */

  /* Checks */
  if (!alpha || !beta) die("Null pointer to entity structure passed");

  //i = 0;
  //for (i=0; i<pop->num_chromosomes; i++)
  //{
  a = (gaulbyte *)(alpha->CH /* chromosome[i] */);
  b = (gaulbyte *)( beta->CH /* chromosome[i] */);

  for (j=0; j<pop->len_chromosomes; j++)
  {
    dist += (ga_bit_get(a,j)!=ga_bit_get(b,j));
  }
  //}

  return (double) dist;
}
/**********************************************************************
  synopsis:	Compares two bitstring-array genomes and returns their
		euclidean distance.
  parameters:	population *pop	Population of entities (you may use
			differing populations if they are "compatible")
		entity *alpha	Test entity.
		entity *beta	Test entity.
  return:	Returns Euclidean distance between two entities' genomes.
 **********************************************************************/
double 
ga_compare_bitstring_euclidean (population *pop, entity *alpha, entity *beta)
{
  int	    /* i, */j;	     /* Loop variable over all chromosomes, alleles. */
  double	sqdistsum=0.0;	     /* Genomic distance. */
  gaulbyte	*a, *b;		     /* Pointers to chromosomes. */

  /* Checks */
  if (!alpha || !beta) die("Null pointer to entity structure passed");

  //i = 0;
  //for (i=0; i<pop->num_chromosomes; i++)
  //{
  a = (gaulbyte *)(alpha->CH /* chromosome[i] */);
  b = (gaulbyte *)( beta->CH /* chromosome[i] */);

  for (j=0; j<pop->len_chromosomes; j++)
  {
    sqdistsum += (ga_bit_get(a,j)!=ga_bit_get(b,j));
  }
  //}

  return sqrt(sqdistsum);
}
//******************************************************************************
//------------------------------------------------------------------------------


