# /**********************************************************************
#   ga_mutate.c
#  **********************************************************************

#   ga_mutate - Genetic algorithm mutation operators.
#   Copyright б╘2000-2006, Stewart Adcock <stewart@linux-domain.com>
#   All rights reserved.

#   Synopsis:     Routines for performing GA mutation operations.

# 		These functions should duplicate user data where
# 		appropriate.

#  **********************************************************************/

# //#include "ga_core.h"
# #include "gaul.h"

#-------------------------------------------------------------------------------
#   synopsis:	Cause a single mutation event in which a single
# 		allele is cycled.
#-------------------------------------------------------------------------------
proc ga_mutate_integer_singlepoint_drift {pop father son} {

  if {$::is_print} {
    puts "  ga_mutate_integer_singlepoint_drift : "
    #puts ""
  }

  #   //int		i;		/* Loop variable over all chromosomes */
  #   int		chromo;		/* Index of chromosome to mutate */
  #   int		point;		/* Index of allele to mutate */
  #   int		dir=random_boolean()?-1:1;	/* The direction of drift. */
  
  if {[random_boolean]} {
    set dir -1
  } else {
    set dir  1
  }

  #   /* Checks */
  #   if (!father || !son) die("Null pointer to entity structure passed");
  
  #   /* Select mutation locus. */
  #   random_int (1/* pop->num_chromosomes */);
  random_int 1

  set len_chromo [$pop cget -len_chromosomes]

  #   chromo =  0; 
  set chromo    0
  #   point  = (int) random_int (pop->len_chromosomes);
  set point [random_int  $len_chromo]
  
  #   /*
  #     * Copy unchanged data.
  #     */
  #   //i = 0;
  #   //for (i=0; i<pop->num_chromosomes; i++)
  #   //{

  #   memcpy (son->CH/* chromosome[i] */, father->CH/* chromosome[i] */, pop->len_chromosomes*sizeof(int));
  #$son set_chromosome [$father get_chromosome]
  #set_chromosome_ $son [$father get_chromosome]
  ent_set_chromosome_ $son [ent_get_chromosome_ $father]

  # /*   if (i!=chromo) */
  # /*   { */
  # /*     ga_copy_data(pop, son, father, i); */
  # /*   } */
  # /*   else */
  # /*   { */
  #   ga_copy_data (pop, son, NULL, 0/* i */); - надо ли это ???????????
  # /*   } */
  #   //}
  
  set allele_max_integer [$pop cget -allele_max_integer]
  set allele_min_integer [$pop cget -allele_min_integer]

  #   /*
  #     * Mutate by tweaking a single allele.
  #     */
  #   ((int *)son->chromosome[chromo])[point] += dir;
  #
  set point_gen [ent_get_chromo_gen_ $son  $point] ;# старое значение
  set point_gen [expr $point_gen + $dir]  ;# новое  значение

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #   if (((int *)son->chromosome[chromo])[point] > pop->allele_max_integer)
  #     ((int *)son->chromosome[chromo])[point] = pop->allele_min_integer;
  
  if {$point_gen > $allele_max_integer} {
    if {$::is_print} {
      puts "  > allele_max_integer"
    }
    set point_gen $allele_min_intege ;# скорректировали
  }

  #   if (((int *)son->chromosome[chromo])[point] < pop->allele_min_integer)
  #     ((int *)son->chromosome[chromo])[point] = pop->allele_max_integer;
  
  if {$point_gen < $allele_min_integer} {
    if {$::is_print} {
      puts "  < allele_min_integer"
    }
    set point_gen  $allele_max_intege ;# скорректировали
  }
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  #$son set_chromo_gen  $point $point_gen ;# записали новое значение
  ent_set_chromo_gen_ $son  $point $point_gen ;# записали новое значение

  return
}
#-------------------------------------------------------------------------------
# /**********************************************************************
#   synopsis:	Cause a single mutation event in which a single
# 		allele is randomized.
#  **********************************************************************/
# void 
# ga_mutate_integer_singlepoint_randomize (population *pop,
#                                          entity *father, entity *son )
# {
#   //int		i;		/* Loop variable over all chromosomes */
#   int		chromo;		/* Index of chromosome to mutate */
#   int		point;		/* Index of allele to mutate */

#   /* Checks */
#   if (!father || !son) die("Null pointer to entity structure passed");

#   /* Select mutation locus. */
#   /* chromo =  (int) */ random_int (1/* pop->num_chromosomes */);
#   chromo =  0; //(int) random_int (1/* pop->num_chromosomes */);
#   point  = (int) random_int (pop->len_chromosomes);

#   /* Copy unchanging data. */
#   //i = 0;
#   //for (i=0; i<pop->num_chromosomes; i++)
#   //{
#   memcpy(son->CH/* chromosome[i] */, father->CH/* chromosome[i] */, pop->len_chromosomes*sizeof(int));
# /*   if (i!=chromo) */
# /*   { */
# /*     ga_copy_data(pop, son, father, i); */
# /*   } */
# /*   else */
# /*   { */
#   ga_copy_data(pop, son, NULL, /* i */0);
# /*   } */
#   //}

#   ((int *)son->chromosome[chromo])[point] = (int) random_int_range(pop->allele_min_integer,pop->allele_max_integer+1);

#   return;
# }
# /**********************************************************************
#   synopsis:	Cause a number of mutation events.  This is equivalent
# 		to the more common 'bit-drift' mutation.
#  **********************************************************************/
# void 
# ga_mutate_integer_multipoint (population *pop, entity *father, entity *son)
# {
#   //int		i;		/* Loop variable over all chromosomes */
#   int		chromo;		/* Index of chromosome to mutate */
#   int		point;		/* Index of allele to mutate */
#   int		dir=random_boolean()?-1:1;	/* The direction of drift. */

#   /* Checks */
#   if (!father || !son) die("Null pointer to entity structure passed");

#   /* Copy chromosomes of parent to offspring. */
#   //i = 0;
#   //for (i=0; i<pop->num_chromosomes; i++)
#   //{
#   memcpy(son->CH, father->CH, pop->len_chromosomes*sizeof(int));
#   //}

#   /*
#     * Mutate by tweaking alleles.
#     */
#   chromo= 0;
#   //for (chromo=0; chromo<pop->num_chromosomes; chromo++)
#   //{
#   for (point=0; point<pop->len_chromosomes; point++)
#   {
#     if (random_boolean_prob(pop->allele_mutation_prob))
#     {
#       ((int *)son->chromosome[chromo])[point] += dir;

#       if (((int *)son->chromosome[chromo])[point] > pop->allele_max_integer)
#         ((int *)son->chromosome[chromo])[point] = pop->allele_min_integer;
#       if (((int *)son->chromosome[chromo])[point] < pop->allele_min_integer)
#         ((int *)son->chromosome[chromo])[point] = pop->allele_max_integer;
#     }
#   }
#   //}

#   return;
# }
# /**********************************************************************
#   synopsis:	Cause a number of mutation events.  Each allele has
# 		equal probability of being incremented, decremented, or
# 		remaining the same.
#  **********************************************************************/
# void 
# ga_mutate_integer_allpoint (population *pop, entity *father, entity *son)
# {
#   //int		i;		/* Loop variable over all chromosomes */
#   int		chromo;		/* Index of chromosome to mutate */
#   int		point;		/* Index of allele to mutate */

#   /* Checks */
#   if (!father || !son) die("Null pointer to entity structure passed");

#   /* Copy chromosomes of parent to offspring. */
#   //i = 0;
#   //for (i=0; i<pop->num_chromosomes; i++)
#   //{
#   memcpy(son->CH, father->CH, pop->len_chromosomes*sizeof(int));
#   //}

#   /*
#     * Mutate by incrementing or decrementing alleles.
#     */
#   chromo = 0;
#   //for (chromo=0; chromo<pop->num_chromosomes; chromo++)
#   //{
#   for (point=0; point<pop->len_chromosomes; point++)
#   {
#     switch (random_int(3))
#     {
#     case (1):
#       (((int *)son->chromosome[chromo])[point])++;

#       if (((int *)son->chromosome[chromo])[point] > pop->allele_max_integer)
#         ((int *)son->chromosome[chromo])[point] = pop->allele_min_integer;

#       break;

#     case (2):
#       (((int *)son->chromosome[chromo])[point])--;

#       if (((int *)son->chromosome[chromo])[point] < pop->allele_min_integer)
#         ((int *)son->chromosome[chromo])[point] = pop->allele_max_integer;

#       break;

#     default:
#       /* Do nothing. */
#       break;
#     }
#   }
#   //}

#   return;
# }
# /**********************************************************************
#   synopsis:	Cause a single mutation event in which a single
# 		allele is inverted.
#  **********************************************************************/
# void 
# ga_mutate_boolean_singlepoint (population *pop, entity *father, entity *son)
# {
#   //int		i;		/* Loop variable over all chromosomes */
#   int		chromo;		/* Index of chromosome to mutate */
#   int		point;		/* Index of allele to mutate */

#   /* Checks */
#   if (!father || !son) die("Null pointer to entity structure passed");

#   /* Select mutation locus. */
#   //chromo = (int) random_int (1/* pop->num_chromosomes */);
#   random_int (1/* pop->num_chromosomes */);
#   chromo = 0;
#   //fprintf (stderr, "chromo= %d \n", chromo);

#   point  = (int) random_int (pop->len_chromosomes);

#   /* Copy unchanging data. */
#   //i = 0;
#   //for (i=0; i<pop->num_chromosomes; i++)
#   //{
#   memcpy(son->CH, father->CH, pop->len_chromosomes*sizeof(boolean));
# /*   if (i!=chromo) */
# /*   { */
# /*     ga_copy_data(pop, son, father, i); */
# /*   } */
# /*   else */
# /*   { */
#     ga_copy_data(pop, son, NULL, /* i */0);
# /*   } */
#   //}

#   ((boolean *)son->chromosome[chromo])[point] = !((boolean *)son->chromosome[chromo])[point];

#   return;
# }
# /**********************************************************************
#   synopsis:	Cause a number of mutation events.
#  **********************************************************************/
# void 
# ga_mutate_boolean_multipoint (population *pop, entity *father, entity *son)
# {
#   //int		i;		/* Loop variable over all chromosomes */
#   int		chromo;		/* Index of chromosome to mutate */
#   int		point;		/* Index of allele to mutate */

#   /* Checks */
#   if (!father || !son) die("Null pointer to entity structure passed");

#   /* Copy chromosomes of parent to offspring. */
#   //i = 0;
#   //for (i=0; i<pop->num_chromosomes; i++)
#   //{
#   memcpy(son->CH, father->CH, pop->len_chromosomes*sizeof(boolean));
#   //}

#   /*
#     * Mutate by flipping random bits.
#     */
#   chromo=0;
#   //for (chromo=0; chromo<pop->num_chromosomes; chromo++)
#   //{
#   for (point=0; point<pop->len_chromosomes; point++)
#   {
#     if (random_boolean_prob(pop->allele_mutation_prob))
#     {
#       ((boolean *)son->chromosome[chromo])[point] = !((boolean *)son->chromosome[chromo])[point];
#     }
#   }
#   //}

#   return;
# }
# /**********************************************************************
#   synopsis:	Cause a single mutation event in which a single
# 		allele is cycled.
#  **********************************************************************/
# void 
# ga_mutate_char_singlepoint_drift (population *pop,
#                                   entity *father, entity *son)
# {
#   //int		i;		/* Loop variable over all chromosomes */
#   int		chromo;		/* Index of chromosome to mutate */
#   int		point;		/* Index of allele to mutate */
#   int		dir=random_boolean()?-1:1;	/* The direction of drift. */

#   /* Checks */
#   if (!father || !son) die("Null pointer to entity structure passed");

#   /* Select mutation locus. */
#   /* chromo =  (int) */ random_int (1/* pop->num_chromosomes */);
#   chromo = 0; // (int) random_int (1/* pop->num_chromosomes */);
#   point  = (int) random_int (pop->len_chromosomes);

#   /*
#     * Copy unchanged data.
#     */
#   //i = 0;
#   //for (i=0; i<pop->num_chromosomes; i++)
#   //{
#   memcpy(son->CH, father->CH, pop->len_chromosomes*sizeof(char));
# /*   if (i!=chromo) */
# /*   { */
# /*     ga_copy_data(pop, son, father, i); */
# /*   } */
# /*   else */
# /*   { */
#   ga_copy_data(pop, son, NULL, /* i */0);
# /*   } */
#   //}

#   /*
#     * Mutate by tweaking a single allele.
#     */
#   ((char *)son->chromosome[chromo])[point] += (char)dir;

#   /* Don't need these because char's **should** wrap safely.
#     if (((char *)son->chromosome[chromo])[point]>CHAR_MAX)
#     ((char *)son->chromosome[chromo])[point]=CHAR_MIN;
#     if (((char *)son->chromosome[chromo])[point]<CHAR_MIN)
#     ((char *)son->chromosome[chromo])[point]=CHAR_MAX;
#     */

#   return;
# }
# /**********************************************************************
#   synopsis:	Cause a number of mutation events.  Each allele has
# 		equal probability of being incremented, decremented, or
# 		remaining the same.
#  **********************************************************************/
# void 
# ga_mutate_char_allpoint (population *pop, entity *father, entity *son)
# {
#   //int		i;		/* Loop variable over all chromosomes */
#   int		chromo;		/* Index of chromosome to mutate */
#   int		point;		/* Index of allele to mutate */

#   /* Checks */
#   if (!father || !son) die("Null pointer to entity structure passed");

#   /* Copy chromosomes of parent to offspring. */
#   //i = 0;
#   //for (i=0; i<pop->num_chromosomes; i++)
#   //{
#   memcpy(son->CH, father->CH, pop->len_chromosomes*sizeof(int));
#   //}

#   /*
#     * Mutate by incrementing or decrementing alleles.
#     */
#   chromo=0;
#   //for (chromo=0; chromo<pop->num_chromosomes; chromo++)
#   //{
#   for (point=0; point<pop->len_chromosomes; point++)
#   {
#     switch (random_int(3))
#     {
#     case (1):
#       (((char *)son->chromosome[chromo])[point])++;

#       break;

#     case (2):
#       (((char *)son->chromosome[chromo])[point])--;

#       break;

#     default:
#       /* Do nothing. */
#       break;
#     }
#   }
#   //}

#   return;
# }
# /**********************************************************************
#   synopsis:	Cause a single mutation event in which a single
# 		allele is randomized.
#  **********************************************************************/
# void 
# ga_mutate_char_singlepoint_randomize (population *pop,
#                                       entity *father, entity *son)
# {
#   //int		i;		/* Loop variable over all chromosomes */
#   int		chromo;		/* Index of chromosome to mutate */
#   int		point;		/* Index of allele to mutate */

#   /* Checks */
#   if (!father || !son) die("Null pointer to entity structure passed");

#   /* Select mutation locus. */
#   /* chromo =  (int) */ random_int (1/* pop->num_chromosomes */);
#   chromo =  0; //(int) random_int (1/* pop->num_chromosomes */);
#   point  = (int) random_int (pop->len_chromosomes);

#   /* Copy unchanging data. */
#   //i = 0;
#   //for (i=0; i<pop->num_chromosomes; i++)
#   //{
#   memcpy(son->CH, father->CH, pop->len_chromosomes*sizeof(char));
# /*   if (i!=chromo) */
# /*   { */
# /*     ga_copy_data(pop, son, father, i); */
# /*   } */
# /*   else */
# /*   { */
#   ga_copy_data(pop, son, NULL, /* i */0);
# /*   } */
#   //}

#   ((char *)son->chromosome[chromo])[point] = (char) random_int(CHAR_MAX-CHAR_MIN)+CHAR_MIN;

#   return;
# }
# /**********************************************************************
#   synopsis:	Cause a number of mutation events.  This is equivalent
# 		to the more common 'bit-drift' mutation.
#  **********************************************************************/
# void 
# ga_mutate_char_multipoint (population *pop, entity *father, entity *son)
# {
#   //int		i;		/* Loop variable over all chromosomes */
#   int		chromo;		/* Index of chromosome to mutate */
#   int		point;		/* Index of allele to mutate */
#   int		dir=random_boolean()?-1:1;	/* The direction of drift. */

#   /* Checks */
#   if (!father || !son) die("Null pointer to entity structure passed");

#   /* Copy chromosomes of parent to offspring. */
#   //i = 0;
#   //for (i=0; i<pop->num_chromosomes; i++)
#   //{
#   memcpy(son->CH, father->CH, pop->len_chromosomes*sizeof(char));
#   //}

#   /*
#     * Mutate by tweaking alleles.
#     */
#   chromo=0;
#   //for (chromo=0; chromo<pop->num_chromosomes; chromo++)
#   //{
#   for (point=0; point<pop->len_chromosomes; point++)
#   {
#     if (random_boolean_prob(pop->allele_mutation_prob))
#     {
#       ((char *)son->chromosome[chromo])[point] += (char)dir;

#       /* Don't need these because char's **should** wrap safely.
#         if (((char *)son->chromosome[chromo])[point]>CHAR_MAX)
#         ((char *)son->chromosome[chromo])[point]=CHAR_MIN;
#         if (((char *)son->chromosome[chromo])[point]<CHAR_MIN)
#         ((char *)son->chromosome[chromo])[point]=CHAR_MAX;
#         */
#     }
#   }
#   //}

#   return;
# }
#-------------------------------------------------------------------------------
#   synopsis:	Cause a single mutation event in which a single
# 		allele is cycled.
#-------------------------------------------------------------------------------
# void 
# ga_mutate_printable_singlepoint_drift (population *pop,
#                                        entity *father, entity *son)
#-------------------------------------------------------------------------------
proc ga_mutate_printable_singlepoint_drift {pop father son}  {

  #if {$::is_print} {
  #  puts "  ga_mutate_printable_singlepoint_drift : "
  #}

  #   //int		i;		/* Loop variable over all chromosomes */
  #   int		chromo;		/* Index of chromosome to mutate */
  #   int		point;		/* Index of allele to mutate */

  #   int		dir=random_boolean()?-1:1;	/* The direction of drift. */
  
  if {[random_boolean]} {
    set dir -1
  } else {
    set dir  1
  }

  #   /* Checks */
  #   if (!father || !son) die ("Null pointer to entity structure passed");
  
  #   /* Select mutation locus. */
  #   /* chromo =  (int) */ random_int (1/* pop->num_chromosomes */);
  random_int 1

  set len_chromo [$pop cget -len_chromosomes]

  #   chromo = 0; // (int) random_int (1/* pop->num_chromosomes */);
  set chromo    0
  #   point  = (int) random_int (pop->len_chromosomes);
  set point [random_int  $len_chromo]
  
  #   /*
  #     * Copy unchanged data.
  #     */
  #   //i = 0;
  #   //for (i=0; i<pop->num_chromosomes; i++)
  #   //{

  #   memcpy(son->CH, father->CH, pop->len_chromosomes*sizeof(char));

  ent_set_chromosome_ $son [ent_get_chromosome_ $father]

  # /*   if (i!=chromo) */
  # /*   { */
  # /*     ga_copy_data(pop, son, father, i); */
  # /*   } */
  # /*   else */
  # /*   { */
  #   ga_copy_data(pop, son, NULL, /* i */0);
  # /*   } */
  #   //}
  
  #   /*
  #     * Mutate by tweaking a single allele.
  #     */

  #   ((char *)son->chromosome[chromo])[point] += (char)dir;
  set point_gen [ent_get_chromo_gen_ $son  $point] ;# старое значение
  set point_gen [expr $point_gen + $dir]  ;# новое  значение


  set char_min_num [scan " " "%c"]
  set char_max_num [scan "~" "%c"] 
    
  #   if (((char *)son->chromosome[chromo])[point] > '~')
  #     ((char *)son->chromosome[chromo])[point] = ' ';

  if {$point_gen > $char_max_num} {
    set point_gen $char_min_num ;# скорректировали
  }

  #   if (((char *)son->chromosome[chromo])[point] < ' ')
  #     ((char *)son->chromosome[chromo])[point] = '~';
  
  if {$point_gen < $char_min_num} {
    set point_gen $char_max_num ;# скорректировали
  }


  #$son set_chromo_gen  $point $point_gen ;# записали новое значение
  ent_set_chromo_gen_ $son  $point $point_gen ;# записали новое значение

  return
}
#-------------------------------------------------------------------------------
# /**********************************************************************
#   synopsis:	Cause a single mutation event in which a single
# 		allele is randomized.
#  **********************************************************************/
# void 
# ga_mutate_printable_singlepoint_randomize (population *pop,
#                                            entity *father, entity *son)
# {
#   //int		i;		/* Loop variable over all chromosomes */
#   int		chromo;		/* Index of chromosome to mutate */
#   int		point;		/* Index of allele to mutate */

#   /* Checks */
#   if (!father || !son) die("Null pointer to entity structure passed");

#   /* Select mutation locus. */
#   /* chromo = (int) */ random_int (1/* pop->num_chromosomes */);
#   chromo = 0; //(int) random_int (1/* pop->num_chromosomes */);
#   point  = (int) random_int (pop->len_chromosomes);

#   /* Copy unchanging data. */
#   //i = 0;
#   //for (i=0; i<pop->num_chromosomes; i++)
#   //{
#   memcpy(son->CH, father->CH, pop->len_chromosomes*sizeof(char));
# /*   if (i!=chromo) */
# /*   { */
# /*     ga_copy_data(pop, son, father, i); */
# /*   } */
# /*   else */
# /*   { */
#   ga_copy_data(pop, son, NULL, /* i */0);
# /*   } */
#   //}

#   ((char *)son->chromosome[chromo])[point] = (char) random_int('~'-' ')+' ';

#   return;
# }
# /**********************************************************************
#   synopsis:	Cause a number of mutation events.  This is equivalent
# 		to the more common 'bit-drift' mutation.
#  **********************************************************************/
# void 
# ga_mutate_printable_multipoint (population *pop, entity *father, entity *son)
# {
#   //int		i;		/* Loop variable over all chromosomes */
#   //int		chromo;		/* Index of chromosome to mutate */
#   int		point;		/* Index of allele to mutate */
#   int		dir=random_boolean()?-1:1;	/* The direction of drift. */

#   /* Checks */
#   if (!father || !son) die("Null pointer to entity structure passed");

#   /* Copy chromosomes of parent to offspring. */
#   //i = 0;
#   //for (i=0; i<pop->num_chromosomes; i++)
#   //{
#   memcpy(son->CH, father->CH, pop->len_chromosomes*sizeof(char));
#   //}

#   /*
#     * Mutate by tweaking alleles.
#     */
#   //chromo=0;
#   //for (chromo=0; chromo<pop->num_chromosomes; chromo++)
#   //{
#   for (point=0; point<pop->len_chromosomes; point++)
#   {
#     if (random_boolean_prob(pop->allele_mutation_prob))
#     {
#       ((char *)son->CH/* chromosome[0] */)[point] += (char)dir;

#       if (((char *)son->CH/* chromosome[0] */)[point]>'~')
#         ((char *)son->CH/* chromosome[0] */)[point]=' ';
#       if (((char *)son->CH/* chromosome[0] */)[point]<' ')
#         ((char *)son->CH/* chromosome[0] */)[point]='~';
#     }
#   }
#   //}

#   return;
# }
# /**********************************************************************
#   synopsis:	Cause a number of mutation events.  Each allele has
# 		equal probability of being incremented, decremented, or
# 		remaining the same.
#  **********************************************************************/
# void 
# ga_mutate_printable_allpoint (population *pop, entity *father, entity *son)
# {
#   //int		i;		/* Loop variable over all chromosomes */
#   //int		chromo;		/* Index of chromosome to mutate */
#   int		point;		/* Index of allele to mutate */

#   /* Checks */
#   if (!father || !son) die("Null pointer to entity structure passed");

#   /* Copy chromosomes of parent to offspring. */
#   //i = 0;
#   //for (i=0; i<pop->num_chromosomes; i++)
#   //{
#   memcpy(son->CH, father->CH, pop->len_chromosomes*sizeof(char));
#   //}

#   /*
#     * Mutate by incrementing or decrementing alleles.
#     */
#   //chromo=0;
#   //for (chromo=0; chromo<pop->num_chromosomes; chromo++)
#   //{
#   for (point=0; point<pop->len_chromosomes; point++)
#   {
#     switch (random_int(3))
#     {
#     case (1):
#       (((char *)son->CH/* chromosome[chromo] */)[point])++;

#       if (((char *)son->CH/* chromosome[chromo] */)[point]>'~')
#         ((char *)son->CH/* chromosome[chromo] */)[point]=' ';

#       break;

#     case (2):
#       (((char *)son->CH/* chromosome[chromo] */)[point])--;

#       if (((char *)son->CH/* chromosome[chromo] */)[point]<' ')
#         ((char *)son->CH/* chromosome[chromo] */)[point]='~';

#       break;

#     default:
#       /* Do nothing. */
#       break;
#     }
#   }
#   //}

#   return;
# }
# /**********************************************************************
#   synopsis:	Cause a single mutation event in which a single
# 		allele is flipped.
#  **********************************************************************/
# void 
# ga_mutate_bitstring_singlepoint (population *pop,
#                                  entity *father, entity *son)
# {
#   //int		i;		/* Loop variable over all chromosomes */
#   //int		chromo;		/* Index of chromosome to mutate */
#   int		point;		/* Index of allele to mutate */

#   /* Checks */
#   if (!father || !son) die("Null pointer to entity structure passed");

#   /* Select mutation locus. */
#   /* chromo =  (int) */ random_int (1/* pop->num_chromosomes */);
#   //chromo =  0;//(int) random_int (1/* pop->num_chromosomes */);
#   point  = (int) random_int (pop->len_chromosomes);

#   /* Copy unchanging data. */
#   //i = 0;
#   //for (i=0; i<pop->num_chromosomes; i++)
#   //{
#   ga_bit_clone(son->CH, father->CH, pop->len_chromosomes);

# /*   if (i!=chromo) */
# /*   { */
# /*     ga_copy_data(pop, son, father, i); */
# /*   } */
# /*   else */
# /*   { */
#   ga_copy_data(pop, son, NULL, /* i */0);
# /*   } */
#   //}

#   /* The singlepoint mutation. */
#   ga_bit_invert(son->CH/* chromosome[chromo] */, point);

#   return;
# }
# /**********************************************************************
#   synopsis:	Cause a number of mutation events.
#  **********************************************************************/
# void 
# ga_mutate_bitstring_multipoint (population *pop, entity *father, entity *son)
# {
#   //int		i;		/* Loop variable over all chromosomes */
#   //int		chromo;		/* Index of chromosome to mutate */
#   int		point;		/* Index of allele to mutate */

#   /* Checks */
#   if (!father || !son) die("Null pointer to entity structure passed");

#   /* Copy chromosomes of parent to offspring. */
#   //i = 0;
#   //for (i=0; i<pop->num_chromosomes; i++)
#   //{
#   ga_bit_clone(son->CH, father->CH, pop->len_chromosomes);
#   //}

#   /*
#     * Mutate by flipping random bits.
#     */
#   //chromo=0;
#   //for (chromo=0; chromo<pop->num_chromosomes; chromo++)
#   //{
#   for (point=0; point<pop->len_chromosomes; point++)
#   {
#     if (random_boolean_prob(pop->allele_mutation_prob))
#     {
#       ga_bit_invert(son->CH/* chromosome[chromo] */, point);
#     }
#   }
#   //}

#   return;
# }
#-------------------------------------------------------------------------------
#   synopsis:	Cause a single mutation event in which a single
# 		allele is adjusted.  (Unit Gaussian distribution.)

# void 
# ga_mutate_double_singlepoint_drift (population *pop,
#                                     entity *father, entity *son)

#-------------------------------------------------------------------------------
proc ga_mutate_double_singlepoint_drift {pop father son}  {

  if {$::is_print} {
    puts "  ga_mutate_double_singlepoint_drift : "
    #puts ""
  }

  #   //int		i;		/* Loop variable over all chromosomes */
  #   //int		chromo;		/* Index of chromosome to mutate */
  #   int		point;		/* Index of allele to mutate */
  #   double	amount=random_unit_gaussian();	/* The amount of drift. (FIXME: variance should be user-definable) */
  set amount [random_unit_gaussian]
  
  #   /* Checks */
  #   if (!father || !son) die("Null pointer to entity structure passed");
  
  set len_chromo [$pop cget -len_chromosomes]

  #   /* Select mutation locus. */
  #   /* chromo =  (int) */ random_int(1/* pop->num_chromosomes */);
  random_int 1

  #   //chromo = 0; // (int) random_int(1/* pop->num_chromosomes */);
  #   point  = (int) random_int(pop->len_chromosomes);
  set point [random_int  $len_chromo]

  #   /*
  #     * Copy unchanged data.
  #     */
  #   //i=0;
  #   //for (i=0; i<pop->num_chromosomes; i++)
  #   //{

  #   memcpy(son->CH, father->CH, pop->len_chromosomes*sizeof(double));
  #$son set_chromosome [$father get_chromosome]
  #ent_set_chromosome_ $son [$father get_chromosome]
  ent_set_chromosome_ $son [ent_get_chromosome_ $father]

  # /*   if (i!=chromo) */
  # /*   { */
  # /*     ga_copy_data(pop, son, father, i); */
  # /*   } */
  # /*   else */
  # /*   { */

  #   ga_copy_data(pop, son, NULL, /* i */0); - надо ли это ???????????

  # /*   } */
  #   //}
  
  set allele_max_double [$pop cget -allele_max_double]
  set allele_min_double [$pop cget -allele_min_double]

  #   /*
  #     * Mutate by tweaking a single allele.
  #     */
  #   ((double *)son->CH/* chromosome[chromo] */)[point] += amount;
  #
  set point_gen [ent_get_chromo_gen_ $son  $point] ;# старое значение
  set point_gen [expr $point_gen + $amount]  ;# новое  значение

  
  # вообще не понятно это зачем, но надо сделать, чтобы совпадать с си-шным
  # вариантом;
  #
  # кстати, после кооректировки срабатывает та самая дурацкая процедура
  # ga_genocide_by_fitness  !!!!!!!!!!!!!
  #
  # ну и здесь лучше разобраться окончательно со значением, а уж потом
  # записывать;

  set allele_correct [expr $allele_max_double - $allele_min_double]


  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #if (((double *)son->CH)[point] > allele_max_double)
  #  ((double *)son->CH)[point] -= (allele_max_double - allele_min_double);

  if {$point_gen > $allele_max_double} {
    if {$::is_print} {
      puts "  > allele_max_double"
    }
    set point_gen [expr $point_gen - $allele_correct] ;# скорректировали
  }

  #if (((double *)son->CH)[point] < allele_min_double)
  #  ((double *)son->CH)[point] += (allele_max_double - allele_min_double);
  
  if {$point_gen < $allele_min_double} {
    if {$::is_print} {
      puts "  < allele_min_double"
    }
    set point_gen [expr $point_gen + $allele_correct] ;# скорректировали
  }
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  
  #$son set_chromo_gen  $point $point_gen ;# записали новое значение
  ent_set_chromo_gen_ $son  $point $point_gen ;# записали новое значение

  return
}
#-------------------------------------------------------------------------------

# /**********************************************************************
#   synopsis:	Cause a single mutation event in which a single
# 		allele is randomized.  (Unit Gaussian distribution.)
#  **********************************************************************/
# void 
# ga_mutate_double_singlepoint_randomize (population *pop,
#                                         entity *father, entity *son)
# {
#   //int		i;		/* Loop variable over all chromosomes */
#   //int		chromo;		/* Index of chromosome to mutate */
#   int		point;		/* Index of allele to mutate */

#   /* Checks */
#   if (!father || !son) die("Null pointer to entity structure passed");

#   /* Select mutation locus. */
#   /* chromo =  (int) */ random_int(1/* pop->num_chromosomes */);
#   //chromo = 0; // (int) random_int(pop->num_chromosomes);
#   point  = (int) random_int(pop->len_chromosomes);

#   /* Copy unchanging data. */
#   //i=0;
#   //for (i=0; i<pop->num_chromosomes; i++)
#   //{
#   memcpy(son->CH, father->CH, pop->len_chromosomes*sizeof(double));
# /*   if (i!=chromo) */
# /*   { */
# /*     ga_copy_data(pop, son, father, i); */
# /*   } */
# /*   else */
# /*   { */
#   ga_copy_data(pop, son, NULL, /* i */0);
# /*   } */
#   //}

#   ((double *)son->CH/* chromosome[chromo] */)[point] = random_unit_gaussian();

#   return;
# }
# /**********************************************************************
#   synopsis:	Cause a number of mutation events.  This is equivalent
# 		to the more common 'bit-drift' mutation.
# 		(Unit Gaussian distribution.)
#  **********************************************************************/
# void 
# ga_mutate_double_multipoint (population *pop, entity *father, entity *son)
# {
#   //int		i;		/* Loop variable over all chromosomes */
#   //int		chromo;		/* Index of chromosome to mutate */
#   int		point;		/* Index of allele to mutate */

#   /* Checks */
#   if (!father || !son) die("Null pointer to entity structure passed");

#   /* Copy chromosomes of parent to offspring. */
#   //i=0;
#   //for (i=0; i<pop->num_chromosomes; i++)
#   //{
#   memcpy(son->CH, father->CH, pop->len_chromosomes*sizeof(double));
#   //}

#   /*
#     * Mutate by tweaking alleles.
#     */
#   //chromo=0;
#   //for (chromo=0; chromo<pop->num_chromosomes; chromo++)
#   //{
#   for (point=0; point<pop->len_chromosomes; point++)
#   {
#     if (random_boolean_prob(pop->allele_mutation_prob))
#     {
#       ((double *)son->CH/* chromosome[chromo] */)[point] += random_unit_gaussian();

#       if (((double *)son->CH/* chromosome[chromo] */)[point] > pop->allele_max_double)
#         ((double *)son->CH/* chromosome[chromo] */)[point] -= (pop->allele_max_double-pop->allele_min_double);
#       if (((double *)son->CH/* chromosome[chromo] */)[point] < pop->allele_min_double)
#         ((double *)son->CH/* chromosome[chromo] */)[point] += (pop->allele_max_double-pop->allele_min_double);
#     }
#   }
#   //}

#   return;
# }
# /**********************************************************************
#   synopsis:	Cause a number of mutation events.  Each allele's
# 		value will drift.
# 		(Unit Gaussian distribution.)
#  **********************************************************************/
# void 
# ga_mutate_double_allpoint (population *pop, entity *father, entity *son)
# {
#   //int		i;		/* Loop variable over all chromosomes */
#   //int		chromo;		/* Index of chromosome to mutate */
#   int		point;		/* Index of allele to mutate */

#   /* Checks */
#   if (!father || !son) die("Null pointer to entity structure passed");

#   /* Copy chromosomes of parent to offspring. */
#   //i=0; 
#   //for (i=0; i<pop->num_chromosomes; i++)
#   //{
#   memcpy(son->CH, father->CH, pop->len_chromosomes*sizeof(double));
#   //}

#   /*
#     * Mutate by adjusting all alleles.
#     */
#   //chromo=0;
#   //for (chromo=0; chromo<pop->num_chromosomes; chromo++)
#   //{
#   for (point=0; point<pop->len_chromosomes; point++)
#   {
#     (((double *)son->CH/* chromosome[chromo] */)[point]) += random_unit_gaussian();

#     if (((double *)son->CH/* chromosome[chromo] */)[point] > pop->allele_max_double)
#       ((double *)son->CH/* chromosome[chromo] */)[point] -= (pop->allele_max_double-pop->allele_min_double);
#     if (((double *)son->CH/* chromosome[chromo] */)[point] < pop->allele_min_double)
#       ((double *)son->CH/* chromosome[chromo] */)[point] += (pop->allele_max_double-pop->allele_min_double);
#   }
#   //}

#   return;
# }
# //******************************************************************************


