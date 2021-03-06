/**********************************************************************
  ga_mutate.c
 **********************************************************************

  ga_mutate - Genetic algorithm mutation operators.
  Copyright ©2000-2006, Stewart Adcock <stewart@linux-domain.com>
  All rights reserved.

  Synopsis:     Routines for performing GA mutation operations.

		These functions should duplicate user data where
		appropriate.

 **********************************************************************/

//#include "ga_core.h"
#include "gaul.h"

/**********************************************************************
  synopsis:	Cause a single mutation event in which a single
		allele is cycled.
 **********************************************************************/
void 
ga_mutate_integer_singlepoint_drift (population *pop,
                                     entity *father, entity *son)
{

  if (is_print) {
    printf ("  ga_mutate_integer_singlepoint_drift : \n");
  }

  //int		i;		/* Loop variable over all chromosomes */
  int		chromo;		/* Index of chromosome to mutate */
  int		point;		/* Index of allele to mutate */

  int		dir = random_boolean()?-1:1;	/* The direction of drift. */

  /* Checks */
  if (!father || !son) die ("Null pointer to entity structure passed");

  /* Select mutation locus. */
  random_int (1/* pop->num_chromosomes */);
  chromo =  0; 
  point  = (int) random_int (pop->len_chromosomes);

  /*
    * Copy unchanged data.
    */
  //i = 0;
  //for (i=0; i<pop->num_chromosomes; i++)
  //{
  memcpy (son->CH/* chromosome[i] */, father->CH/* chromosome[i] */, pop->len_chromosomes*sizeof(int));
/*   if (i!=chromo) */
/*   { */
/*     ga_copy_data(pop, son, father, i); */
/*   } */
/*   else */
/*   { */
  ga_copy_data (pop, son, NULL, 0/* i */);
/*   } */
  //}

  /*
    * Mutate by tweaking a single allele.
    */
  ((int *)son->chromosome[chromo])[point] += dir;

  if (((int *)son->chromosome[chromo])[point] > pop->allele_max_integer)
    ((int *)son->chromosome[chromo])[point] = pop->allele_min_integer;

  if (((int *)son->chromosome[chromo])[point] < pop->allele_min_integer)
    ((int *)son->chromosome[chromo])[point] = pop->allele_max_integer;

  return;
}
/**********************************************************************
  synopsis:	Cause a single mutation event in which a single
		allele is randomized.
 **********************************************************************/
void 
ga_mutate_integer_singlepoint_randomize (population *pop,
                                         entity *father, entity *son )
{
  //int		i;		/* Loop variable over all chromosomes */
  int		chromo;		/* Index of chromosome to mutate */
  int		point;		/* Index of allele to mutate */

  /* Checks */
  if (!father || !son) die("Null pointer to entity structure passed");

  /* Select mutation locus. */
  /* chromo =  (int) */ random_int (1/* pop->num_chromosomes */);
  chromo =  0; //(int) random_int (1/* pop->num_chromosomes */);
  point  = (int) random_int (pop->len_chromosomes);

  /* Copy unchanging data. */
  //i = 0;
  //for (i=0; i<pop->num_chromosomes; i++)
  //{
  memcpy(son->CH/* chromosome[i] */, father->CH/* chromosome[i] */, pop->len_chromosomes*sizeof(int));
/*   if (i!=chromo) */
/*   { */
/*     ga_copy_data(pop, son, father, i); */
/*   } */
/*   else */
/*   { */
  ga_copy_data(pop, son, NULL, /* i */0);
/*   } */
  //}

  ((int *)son->chromosome[chromo])[point] = (int) random_int_range(pop->allele_min_integer,pop->allele_max_integer+1);

  return;
}
/**********************************************************************
  synopsis:	Cause a number of mutation events.  This is equivalent
		to the more common 'bit-drift' mutation.
 **********************************************************************/
void 
ga_mutate_integer_multipoint (population *pop, entity *father, entity *son)
{
  //int		i;		/* Loop variable over all chromosomes */
  int		chromo;		/* Index of chromosome to mutate */
  int		point;		/* Index of allele to mutate */
  int		dir=random_boolean()?-1:1;	/* The direction of drift. */

  /* Checks */
  if (!father || !son) die("Null pointer to entity structure passed");

  /* Copy chromosomes of parent to offspring. */
  //i = 0;
  //for (i=0; i<pop->num_chromosomes; i++)
  //{
  memcpy(son->CH, father->CH, pop->len_chromosomes*sizeof(int));
  //}

  /*
    * Mutate by tweaking alleles.
    */
  chromo= 0;
  //for (chromo=0; chromo<pop->num_chromosomes; chromo++)
  //{
  for (point=0; point<pop->len_chromosomes; point++)
  {
    if (random_boolean_prob(pop->allele_mutation_prob))
    {
      ((int *)son->chromosome[chromo])[point] += dir;

      if (((int *)son->chromosome[chromo])[point] > pop->allele_max_integer)
        ((int *)son->chromosome[chromo])[point] = pop->allele_min_integer;
      if (((int *)son->chromosome[chromo])[point] < pop->allele_min_integer)
        ((int *)son->chromosome[chromo])[point] = pop->allele_max_integer;
    }
  }
  //}

  return;
}
/**********************************************************************
  synopsis:	Cause a number of mutation events.  Each allele has
		equal probability of being incremented, decremented, or
		remaining the same.
 **********************************************************************/
void 
ga_mutate_integer_allpoint (population *pop, entity *father, entity *son)
{
  //int		i;		/* Loop variable over all chromosomes */
  int		chromo;		/* Index of chromosome to mutate */
  int		point;		/* Index of allele to mutate */

  /* Checks */
  if (!father || !son) die("Null pointer to entity structure passed");

  /* Copy chromosomes of parent to offspring. */
  //i = 0;
  //for (i=0; i<pop->num_chromosomes; i++)
  //{
  memcpy(son->CH, father->CH, pop->len_chromosomes*sizeof(int));
  //}

  /*
    * Mutate by incrementing or decrementing alleles.
    */
  chromo = 0;
  //for (chromo=0; chromo<pop->num_chromosomes; chromo++)
  //{
  for (point=0; point<pop->len_chromosomes; point++)
  {
    switch (random_int(3))
    {
    case (1):
      (((int *)son->chromosome[chromo])[point])++;

      if (((int *)son->chromosome[chromo])[point] > pop->allele_max_integer)
        ((int *)son->chromosome[chromo])[point] = pop->allele_min_integer;

      break;

    case (2):
      (((int *)son->chromosome[chromo])[point])--;

      if (((int *)son->chromosome[chromo])[point] < pop->allele_min_integer)
        ((int *)son->chromosome[chromo])[point] = pop->allele_max_integer;

      break;

    default:
      /* Do nothing. */
      break;
    }
  }
  //}

  return;
}
/**********************************************************************
  synopsis:	Cause a single mutation event in which a single
		allele is inverted.
 **********************************************************************/
void 
ga_mutate_boolean_singlepoint (population *pop, entity *father, entity *son)
{
  //int		i;		/* Loop variable over all chromosomes */
  int		chromo;		/* Index of chromosome to mutate */
  int		point;		/* Index of allele to mutate */

  /* Checks */
  if (!father || !son) die("Null pointer to entity structure passed");

  /* Select mutation locus. */
  //chromo = (int) random_int (1/* pop->num_chromosomes */);
  random_int (1/* pop->num_chromosomes */);
  chromo = 0;
  //fprintf (stderr, "chromo= %d \n", chromo);

  point  = (int) random_int (pop->len_chromosomes);

  /* Copy unchanging data. */
  //i = 0;
  //for (i=0; i<pop->num_chromosomes; i++)
  //{
  memcpy(son->CH, father->CH, pop->len_chromosomes*sizeof(boolean));
/*   if (i!=chromo) */
/*   { */
/*     ga_copy_data(pop, son, father, i); */
/*   } */
/*   else */
/*   { */
    ga_copy_data(pop, son, NULL, /* i */0);
/*   } */
  //}

  ((boolean *)son->chromosome[chromo])[point] = !((boolean *)son->chromosome[chromo])[point];

  return;
}
/**********************************************************************
  synopsis:	Cause a number of mutation events.
 **********************************************************************/
void 
ga_mutate_boolean_multipoint (population *pop, entity *father, entity *son)
{
  //int		i;		/* Loop variable over all chromosomes */
  int		chromo;		/* Index of chromosome to mutate */
  int		point;		/* Index of allele to mutate */

  /* Checks */
  if (!father || !son) die("Null pointer to entity structure passed");

  /* Copy chromosomes of parent to offspring. */
  //i = 0;
  //for (i=0; i<pop->num_chromosomes; i++)
  //{
  memcpy(son->CH, father->CH, pop->len_chromosomes*sizeof(boolean));
  //}

  /*
    * Mutate by flipping random bits.
    */
  chromo=0;
  //for (chromo=0; chromo<pop->num_chromosomes; chromo++)
  //{
  for (point=0; point<pop->len_chromosomes; point++)
  {
    if (random_boolean_prob(pop->allele_mutation_prob))
    {
      ((boolean *)son->chromosome[chromo])[point] = !((boolean *)son->chromosome[chromo])[point];
    }
  }
  //}

  return;
}
/**********************************************************************
  synopsis:	Cause a single mutation event in which a single
		allele is cycled.
 **********************************************************************/
void 
ga_mutate_char_singlepoint_drift (population *pop,
                                  entity *father, entity *son)
{
  //int		i;		/* Loop variable over all chromosomes */
  int		chromo;		/* Index of chromosome to mutate */
  int		point;		/* Index of allele to mutate */
  int		dir=random_boolean()?-1:1;	/* The direction of drift. */

  /* Checks */
  if (!father || !son) die("Null pointer to entity structure passed");

  /* Select mutation locus. */
  /* chromo =  (int) */ random_int (1/* pop->num_chromosomes */);
  chromo = 0; // (int) random_int (1/* pop->num_chromosomes */);
  point  = (int) random_int (pop->len_chromosomes);

  /*
    * Copy unchanged data.
    */
  //i = 0;
  //for (i=0; i<pop->num_chromosomes; i++)
  //{
  memcpy(son->CH, father->CH, pop->len_chromosomes*sizeof(char));
/*   if (i!=chromo) */
/*   { */
/*     ga_copy_data(pop, son, father, i); */
/*   } */
/*   else */
/*   { */
  ga_copy_data(pop, son, NULL, /* i */0);
/*   } */
  //}

  /*
    * Mutate by tweaking a single allele.
    */
  ((char *)son->chromosome[chromo])[point] += (char)dir;

  /* Don't need these because char's **should** wrap safely.
    if (((char *)son->chromosome[chromo])[point]>CHAR_MAX)
    ((char *)son->chromosome[chromo])[point]=CHAR_MIN;
    if (((char *)son->chromosome[chromo])[point]<CHAR_MIN)
    ((char *)son->chromosome[chromo])[point]=CHAR_MAX;
    */

  return;
}
/**********************************************************************
  synopsis:	Cause a number of mutation events.  Each allele has
		equal probability of being incremented, decremented, or
		remaining the same.
 **********************************************************************/
void 
ga_mutate_char_allpoint (population *pop, entity *father, entity *son)
{
  //int		i;		/* Loop variable over all chromosomes */
  int		chromo;		/* Index of chromosome to mutate */
  int		point;		/* Index of allele to mutate */

  /* Checks */
  if (!father || !son) die("Null pointer to entity structure passed");

  /* Copy chromosomes of parent to offspring. */
  //i = 0;
  //for (i=0; i<pop->num_chromosomes; i++)
  //{
  memcpy(son->CH, father->CH, pop->len_chromosomes*sizeof(int));
  //}

  /*
    * Mutate by incrementing or decrementing alleles.
    */
  chromo=0;
  //for (chromo=0; chromo<pop->num_chromosomes; chromo++)
  //{
  for (point=0; point<pop->len_chromosomes; point++)
  {
    switch (random_int(3))
    {
    case (1):
      (((char *)son->chromosome[chromo])[point])++;

      break;

    case (2):
      (((char *)son->chromosome[chromo])[point])--;

      break;

    default:
      /* Do nothing. */
      break;
    }
  }
  //}

  return;
}
/**********************************************************************
  synopsis:	Cause a single mutation event in which a single
		allele is randomized.
 **********************************************************************/
void 
ga_mutate_char_singlepoint_randomize (population *pop,
                                      entity *father, entity *son)
{
  //int		i;		/* Loop variable over all chromosomes */
  int		chromo;		/* Index of chromosome to mutate */
  int		point;		/* Index of allele to mutate */

  /* Checks */
  if (!father || !son) die("Null pointer to entity structure passed");

  /* Select mutation locus. */
  /* chromo =  (int) */ random_int (1/* pop->num_chromosomes */);
  chromo =  0; //(int) random_int (1/* pop->num_chromosomes */);
  point  = (int) random_int (pop->len_chromosomes);

  /* Copy unchanging data. */
  //i = 0;
  //for (i=0; i<pop->num_chromosomes; i++)
  //{
  memcpy(son->CH, father->CH, pop->len_chromosomes*sizeof(char));
/*   if (i!=chromo) */
/*   { */
/*     ga_copy_data(pop, son, father, i); */
/*   } */
/*   else */
/*   { */
  ga_copy_data(pop, son, NULL, /* i */0);
/*   } */
  //}

  ((char *)son->chromosome[chromo])[point] = (char) random_int(CHAR_MAX-CHAR_MIN)+CHAR_MIN;

  return;
}
/**********************************************************************
  synopsis:	Cause a number of mutation events.  This is equivalent
		to the more common 'bit-drift' mutation.
 **********************************************************************/
void 
ga_mutate_char_multipoint (population *pop, entity *father, entity *son)
{
  //int		i;		/* Loop variable over all chromosomes */
  int		chromo;		/* Index of chromosome to mutate */
  int		point;		/* Index of allele to mutate */
  int		dir=random_boolean()?-1:1;	/* The direction of drift. */

  /* Checks */
  if (!father || !son) die("Null pointer to entity structure passed");

  /* Copy chromosomes of parent to offspring. */
  //i = 0;
  //for (i=0; i<pop->num_chromosomes; i++)
  //{
  memcpy(son->CH, father->CH, pop->len_chromosomes*sizeof(char));
  //}

  /*
    * Mutate by tweaking alleles.
    */
  chromo=0;
  //for (chromo=0; chromo<pop->num_chromosomes; chromo++)
  //{
  for (point=0; point<pop->len_chromosomes; point++)
  {
    if (random_boolean_prob(pop->allele_mutation_prob))
    {
      ((char *)son->chromosome[chromo])[point] += (char)dir;

      /* Don't need these because char's **should** wrap safely.
        if (((char *)son->chromosome[chromo])[point]>CHAR_MAX)
        ((char *)son->chromosome[chromo])[point]=CHAR_MIN;
        if (((char *)son->chromosome[chromo])[point]<CHAR_MIN)
        ((char *)son->chromosome[chromo])[point]=CHAR_MAX;
        */
    }
  }
  //}

  return;
}
/**********************************************************************
  synopsis:	Cause a single mutation event in which a single
		allele is cycled.
 **********************************************************************/
void 
ga_mutate_printable_singlepoint_drift (population *pop,
                                       entity *father, entity *son)
{

  //if (is_print) {
  //  printf ("  ga_mutate_printable_singlepoint_drift : \n");
  //}

  //int		i;		/* Loop variable over all chromosomes */
  int		chromo;		/* Index of chromosome to mutate */
  int		point;		/* Index of allele to mutate */
  int		dir=random_boolean()?-1:1;	/* The direction of drift. */

  /* Checks */
  if (!father || !son) die("Null pointer to entity structure passed");

  /* Select mutation locus. */
  /* chromo =  (int) */ random_int (1/* pop->num_chromosomes */);
  chromo = 0; // (int) random_int (1/* pop->num_chromosomes */);
  point  = (int) random_int (pop->len_chromosomes);

  /*
    * Copy unchanged data.
    */
  //i = 0;
  //for (i=0; i<pop->num_chromosomes; i++)
  //{
  memcpy(son->CH, father->CH, pop->len_chromosomes*sizeof(char));
/*   if (i!=chromo) */
/*   { */
/*     ga_copy_data(pop, son, father, i); */
/*   } */
/*   else */
/*   { */
  ga_copy_data(pop, son, NULL, /* i */0);
/*   } */
  //}

  /*
    * Mutate by tweaking a single allele.
    */
  ((char *)son->chromosome[chromo])[point] += (char)dir;

  if (((char *)son->chromosome[chromo])[point]>'~')
    ((char *)son->chromosome[chromo])[point]=' ';
  if (((char *)son->chromosome[chromo])[point]<' ')
    ((char *)son->chromosome[chromo])[point]='~';

  return;
}
/**********************************************************************
  synopsis:	Cause a single mutation event in which a single
		allele is randomized.
 **********************************************************************/
void 
ga_mutate_printable_singlepoint_randomize (population *pop,
                                           entity *father, entity *son)
{
  //int		i;		/* Loop variable over all chromosomes */
  int		chromo;		/* Index of chromosome to mutate */
  int		point;		/* Index of allele to mutate */

  /* Checks */
  if (!father || !son) die("Null pointer to entity structure passed");

  /* Select mutation locus. */
  /* chromo = (int) */ random_int (1/* pop->num_chromosomes */);
  chromo = 0; //(int) random_int (1/* pop->num_chromosomes */);
  point  = (int) random_int (pop->len_chromosomes);

  /* Copy unchanging data. */
  //i = 0;
  //for (i=0; i<pop->num_chromosomes; i++)
  //{
  memcpy(son->CH, father->CH, pop->len_chromosomes*sizeof(char));
/*   if (i!=chromo) */
/*   { */
/*     ga_copy_data(pop, son, father, i); */
/*   } */
/*   else */
/*   { */
  ga_copy_data(pop, son, NULL, /* i */0);
/*   } */
  //}

  ((char *)son->chromosome[chromo])[point] = (char) random_int('~'-' ')+' ';

  return;
}
/**********************************************************************
  synopsis:	Cause a number of mutation events.  This is equivalent
		to the more common 'bit-drift' mutation.
 **********************************************************************/
void 
ga_mutate_printable_multipoint (population *pop, entity *father, entity *son)
{
  //int		i;		/* Loop variable over all chromosomes */
  //int		chromo;		/* Index of chromosome to mutate */
  int		point;		/* Index of allele to mutate */
  int		dir=random_boolean()?-1:1;	/* The direction of drift. */

  /* Checks */
  if (!father || !son) die("Null pointer to entity structure passed");

  /* Copy chromosomes of parent to offspring. */
  //i = 0;
  //for (i=0; i<pop->num_chromosomes; i++)
  //{
  memcpy(son->CH, father->CH, pop->len_chromosomes*sizeof(char));
  //}

  /*
    * Mutate by tweaking alleles.
    */
  //chromo=0;
  //for (chromo=0; chromo<pop->num_chromosomes; chromo++)
  //{
  for (point=0; point<pop->len_chromosomes; point++)
  {
    if (random_boolean_prob(pop->allele_mutation_prob))
    {
      ((char *)son->CH/* chromosome[0] */)[point] += (char)dir;

      if (((char *)son->CH/* chromosome[0] */)[point]>'~')
        ((char *)son->CH/* chromosome[0] */)[point]=' ';
      if (((char *)son->CH/* chromosome[0] */)[point]<' ')
        ((char *)son->CH/* chromosome[0] */)[point]='~';
    }
  }
  //}

  return;
}
/**********************************************************************
  synopsis:	Cause a number of mutation events.  Each allele has
		equal probability of being incremented, decremented, or
		remaining the same.
 **********************************************************************/
void 
ga_mutate_printable_allpoint (population *pop, entity *father, entity *son)
{
  //int		i;		/* Loop variable over all chromosomes */
  //int		chromo;		/* Index of chromosome to mutate */
  int		point;		/* Index of allele to mutate */

  /* Checks */
  if (!father || !son) die("Null pointer to entity structure passed");

  /* Copy chromosomes of parent to offspring. */
  //i = 0;
  //for (i=0; i<pop->num_chromosomes; i++)
  //{
  memcpy(son->CH, father->CH, pop->len_chromosomes*sizeof(char));
  //}

  /*
    * Mutate by incrementing or decrementing alleles.
    */
  //chromo=0;
  //for (chromo=0; chromo<pop->num_chromosomes; chromo++)
  //{
  for (point=0; point<pop->len_chromosomes; point++)
  {
    switch (random_int(3))
    {
    case (1):
      (((char *)son->CH/* chromosome[chromo] */)[point])++;

      if (((char *)son->CH/* chromosome[chromo] */)[point]>'~')
        ((char *)son->CH/* chromosome[chromo] */)[point]=' ';

      break;

    case (2):
      (((char *)son->CH/* chromosome[chromo] */)[point])--;

      if (((char *)son->CH/* chromosome[chromo] */)[point]<' ')
        ((char *)son->CH/* chromosome[chromo] */)[point]='~';

      break;

    default:
      /* Do nothing. */
      break;
    }
  }
  //}

  return;
}
/**********************************************************************
  synopsis:	Cause a single mutation event in which a single
		allele is flipped.
 **********************************************************************/
void 
ga_mutate_bitstring_singlepoint (population *pop,
                                 entity *father, entity *son)
{
  //int		i;		/* Loop variable over all chromosomes */
  //int		chromo;		/* Index of chromosome to mutate */
  int		point;		/* Index of allele to mutate */

  /* Checks */
  if (!father || !son) die("Null pointer to entity structure passed");

  /* Select mutation locus. */
  /* chromo =  (int) */ random_int (1/* pop->num_chromosomes */);
  //chromo =  0;//(int) random_int (1/* pop->num_chromosomes */);
  point  = (int) random_int (pop->len_chromosomes);

  /* Copy unchanging data. */
  //i = 0;
  //for (i=0; i<pop->num_chromosomes; i++)
  //{
  ga_bit_clone(son->CH, father->CH, pop->len_chromosomes);

/*   if (i!=chromo) */
/*   { */
/*     ga_copy_data(pop, son, father, i); */
/*   } */
/*   else */
/*   { */
  ga_copy_data(pop, son, NULL, /* i */0);
/*   } */
  //}

  /* The singlepoint mutation. */
  ga_bit_invert(son->CH/* chromosome[chromo] */, point);

  return;
}
/**********************************************************************
  synopsis:	Cause a number of mutation events.
 **********************************************************************/
void 
ga_mutate_bitstring_multipoint (population *pop, entity *father, entity *son)
{
  //int		i;		/* Loop variable over all chromosomes */
  //int		chromo;		/* Index of chromosome to mutate */
  int		point;		/* Index of allele to mutate */

  /* Checks */
  if (!father || !son) die("Null pointer to entity structure passed");

  /* Copy chromosomes of parent to offspring. */
  //i = 0;
  //for (i=0; i<pop->num_chromosomes; i++)
  //{
  ga_bit_clone(son->CH, father->CH, pop->len_chromosomes);
  //}

  /*
    * Mutate by flipping random bits.
    */
  //chromo=0;
  //for (chromo=0; chromo<pop->num_chromosomes; chromo++)
  //{
  for (point=0; point<pop->len_chromosomes; point++)
  {
    if (random_boolean_prob(pop->allele_mutation_prob))
    {
      ga_bit_invert(son->CH/* chromosome[chromo] */, point);
    }
  }
  //}

  return;
}
//------------------------------------------------------------------------------
//  synopsis:	Cause a single mutation event in which a single
//		allele is adjusted.  (Unit Gaussian distribution.)
//------------------------------------------------------------------------------
void 
ga_mutate_double_singlepoint_drift (population *pop,
                                    entity *father, entity *son)
{
  //int	    i;		/* Loop variable over all chromosomes */
  //int	    chromo;    	/* Index of chromosome to mutate */
  int	    point;     	/* Index of allele to mutate */

  if (is_print) {
    printf ("  ga_mutate_double_singlepoint_drift : \n");
    //printf ("\n");
  }

  double    amount = random_unit_gaussian();   
  /* The amount of drift. (FIXME: variance should be user-definable) */

  /* Checks */
  if (!father || !son) die ("Null pointer to entity structure passed");

  /* Select mutation locus. */
  /* chromo =  (int) */ random_int (1/* pop->num_chromosomes */);

  //chromo = 0; // (int) random_int(1/* pop->num_chromosomes */);
  point  = (int) random_int (pop->len_chromosomes);

  /*
    * Copy unchanged data.
    */
  //i=0;
  //for (i=0; i<pop->num_chromosomes; i++)
  //{

  memcpy (son->CH, father->CH, pop->len_chromosomes*sizeof(double));

  /*   if (i!=chromo) */
  /*   { */
  /*     ga_copy_data(pop, son, father, i); */
  /*   } */
  /*   else */
  /*   { */
  
  ga_copy_data (pop, son, NULL, /* i */0);
  
  /*   } */
  //}
  
  double   allele_min_double, allele_max_double;   /* Range for "double" alleles. */

  allele_min_double = pop->allele_min_double;
  allele_max_double = pop->allele_max_double;

  /*
    * Mutate by tweaking a single allele.
    */
  ((double *)son->CH)[point] += amount;

  if (((double *)son->CH)[point] > allele_max_double) {
    ((double *)son->CH)[point] -= (allele_max_double - allele_min_double);
    if (is_print) {
      printf ("  > allele_max_double\n");
    }
  }

  if (((double *)son->CH)[point] < allele_min_double) {
    ((double *)son->CH)[point] += (allele_max_double - allele_min_double);
    if (is_print) {
      printf ("  < allele_min_double\n");
    }
  }

  return;
}
//------------------------------------------------------------------------------

/**********************************************************************
  synopsis:	Cause a single mutation event in which a single
		allele is randomized.  (Unit Gaussian distribution.)
 **********************************************************************/
void 
ga_mutate_double_singlepoint_randomize (population *pop,
                                        entity *father, entity *son)
{
  //int		i;		/* Loop variable over all chromosomes */
  //int		chromo;		/* Index of chromosome to mutate */
  int		point;		/* Index of allele to mutate */

  /* Checks */
  if (!father || !son) die("Null pointer to entity structure passed");

  /* Select mutation locus. */
  /* chromo =  (int) */ random_int(1/* pop->num_chromosomes */);
  //chromo = 0; // (int) random_int(pop->num_chromosomes);
  point  = (int) random_int(pop->len_chromosomes);

  /* Copy unchanging data. */
  //i=0;
  //for (i=0; i<pop->num_chromosomes; i++)
  //{
  memcpy(son->CH, father->CH, pop->len_chromosomes*sizeof(double));
/*   if (i!=chromo) */
/*   { */
/*     ga_copy_data(pop, son, father, i); */
/*   } */
/*   else */
/*   { */
  ga_copy_data(pop, son, NULL, /* i */0);
/*   } */
  //}

  ((double *)son->CH/* chromosome[chromo] */)[point] = random_unit_gaussian();

  return;
}
/**********************************************************************
  synopsis:	Cause a number of mutation events.  This is equivalent
		to the more common 'bit-drift' mutation.
		(Unit Gaussian distribution.)
 **********************************************************************/
void 
ga_mutate_double_multipoint (population *pop, entity *father, entity *son)
{
  //int		i;		/* Loop variable over all chromosomes */
  //int		chromo;		/* Index of chromosome to mutate */
  int		point;		/* Index of allele to mutate */

  /* Checks */
  if (!father || !son) die("Null pointer to entity structure passed");

  /* Copy chromosomes of parent to offspring. */
  //i=0;
  //for (i=0; i<pop->num_chromosomes; i++)
  //{
  memcpy(son->CH, father->CH, pop->len_chromosomes*sizeof(double));
  //}

  /*
    * Mutate by tweaking alleles.
    */
  //chromo=0;
  //for (chromo=0; chromo<pop->num_chromosomes; chromo++)
  //{
  for (point=0; point<pop->len_chromosomes; point++)
  {
    if (random_boolean_prob(pop->allele_mutation_prob))
    {
      ((double *)son->CH/* chromosome[chromo] */)[point] += random_unit_gaussian();

      if (((double *)son->CH/* chromosome[chromo] */)[point] > pop->allele_max_double)
        ((double *)son->CH/* chromosome[chromo] */)[point] -= (pop->allele_max_double-pop->allele_min_double);
      if (((double *)son->CH/* chromosome[chromo] */)[point] < pop->allele_min_double)
        ((double *)son->CH/* chromosome[chromo] */)[point] += (pop->allele_max_double-pop->allele_min_double);
    }
  }
  //}

  return;
}
/**********************************************************************
  synopsis:	Cause a number of mutation events.  Each allele's
		value will drift.
		(Unit Gaussian distribution.)
 **********************************************************************/
void 
ga_mutate_double_allpoint (population *pop, entity *father, entity *son)
{
  //int		i;		/* Loop variable over all chromosomes */
  //int		chromo;		/* Index of chromosome to mutate */
  int		point;		/* Index of allele to mutate */

  /* Checks */
  if (!father || !son) die("Null pointer to entity structure passed");

  /* Copy chromosomes of parent to offspring. */
  //i=0; 
  //for (i=0; i<pop->num_chromosomes; i++)
  //{
  memcpy(son->CH, father->CH, pop->len_chromosomes*sizeof(double));
  //}

  /*
    * Mutate by adjusting all alleles.
    */
  //chromo=0;
  //for (chromo=0; chromo<pop->num_chromosomes; chromo++)
  //{
  for (point=0; point<pop->len_chromosomes; point++)
  {
    (((double *)son->CH/* chromosome[chromo] */)[point]) += random_unit_gaussian();

    if (((double *)son->CH/* chromosome[chromo] */)[point] > pop->allele_max_double)
      ((double *)son->CH/* chromosome[chromo] */)[point] -= (pop->allele_max_double-pop->allele_min_double);
    if (((double *)son->CH/* chromosome[chromo] */)[point] < pop->allele_min_double)
      ((double *)son->CH/* chromosome[chromo] */)[point] += (pop->allele_max_double-pop->allele_min_double);
  }
  //}

  return;
}
//******************************************************************************


