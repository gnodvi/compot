# /**********************************************************************
#   ga_seed.c
#  **********************************************************************

#   ga_seed - Genetic algorithm genome initialisation operators.
#   Copyright б╘2000-2006, Stewart Adcock <stewart@linux-domain.com>
#   All rights reserved.

#   Synopsis:     Routines for performing GA seeding operations.

# 		Seeding operations generate genetic data by some
# 		non-evolutionary means.  Typically, this is often
# 		just random generation.

#  **********************************************************************/

# //#include "ga_core.h"
# #include "gaul.h"

# /**********************************************************************
#   synopsis:	Seed genetic data for a single entity with a boolean
# 		chromosome by randomly setting each bit.
#   parameters:	population *pop
# 		entity *adam
#   return:	success
#  **********************************************************************/
# boolean 
# ga_seed_boolean_random (population *pop, entity *adam)
# {
#   //int		chromo;		/* Index of chromosome to seed */
#   int		point;		/* Index of allele to seed */

#   /* Checks. */
#   if (!pop) die("Null pointer to population structure passed.");
#   if (!adam) die("Null pointer to entity structure passed.");

#   /* Seeding. */
#   //chromo=0;
#   //for (chromo=0; chromo<pop->num_chromosomes; chromo++)
#   //{
#   for (point=0; point<pop->len_chromosomes; point++)
#   {
#     ((boolean *)adam->CH/* chromosome[chromo] */)[point] = random_boolean();
#   }
#   //}

#   return TRUE;
# }
# /**********************************************************************
#   synopsis:	Seed genetic data for a single entity with a boolean
# 		chromosome by setting each bit to zero.
#   parameters:	population *pop
# 		entity *adam
#   return:	success
#  **********************************************************************/
# boolean 
# ga_seed_boolean_zero (population *pop, entity *adam)
# {
#   //int		chromo;		/* Index of chromosome to seed */
#   int		point;		/* Index of allele to seed */

#   /* Checks. */
#   if (!pop) die("Null pointer to population structure passed.");
#   if (!adam) die("Null pointer to entity structure passed.");

#   /* Seeding. */
#   //chromo=0;
#   //for (chromo=0; chromo<pop->num_chromosomes; chromo++)
#   //{
#   for (point=0; point<pop->len_chromosomes; point++)
#   {
#     ((boolean *)adam->CH/* chromosome[chromo] */)[point] = 0;
#   }
#   //}

#   return TRUE;
# }
#------------------------------------------------------------------------------
#   synopsis:	Seed genetic data for a single entity with an integer
# 		chromosome by randomly setting each allele.
#   parameters:	population *pop
# 		entity *adam
#   return:	success
#------------------------------------------------------------------------------
# boolean 
# ga_seed_integer_random (population *pop, entity *adam)
#------------------------------------------------------------------------------
proc ga_seed_integer_random {pop adam}  {

  #   //int		chromo;		/* Index of chromosome to seed */
  #   int		point;		/* Index of allele to seed */
  
  #   /* Checks. */
  #   if (!pop) die("Null pointer to population structure passed.");
  #   if (!adam) die("Null pointer to entity structure passed.");
  
  #   /* Seeding. */
  #   //chromo=0;
  #   //for (chromo=0; chromo<pop->num_chromosomes; chromo++)
  #   //{

  set amin [$pop cget -allele_min_integer]
  set amax [$pop cget -allele_max_integer]

  for {set point 0} {$point < [$pop cget -len_chromosomes]} {incr point} \
  {
    # ((int *)adam->CH/* chromosome[chromo] */)[point] =
    #   random_int_range(pop->allele_min_integer,pop->allele_max_integer);

    set r [random_int_range  $amin $amax]

    #$adam set_chromo_gen $point $r 
    ent_set_chromo_gen_ $adam $point $r 
  }

  #   //}

  return true
}
#------------------------------------------------------------------------------
# /**********************************************************************
#   synopsis:	Seed genetic data for a single entity with an integer
# 		chromosome by setting each allele to zero.
#   parameters:	population *pop
# 		entity *adam
#   return:	success
#  **********************************************************************/
# boolean 
# ga_seed_integer_zero (population *pop, entity *adam)
# {
#   //int		chromo;		/* Index of chromosome to seed */
#   int		point;		/* Index of allele to seed */

#   /* Checks. */
#   if (!pop) die("Null pointer to population structure passed.");
#   if (!adam) die("Null pointer to entity structure passed.");

#   /* Seeding. */
#   //chromo=0;
#   //for (chromo=0; chromo<pop->num_chromosomes; chromo++)
#   //{
#   for (point=0; point<pop->len_chromosomes; point++)
#   {
#     ((int *)adam->CH/* chromosome[chromo] */)[point] = 0;
#   }
#   //}

#   return TRUE;
# }
# /**********************************************************************
#   synopsis:	Seed genetic data for a single entity with a character
# 		chromosome by randomly setting each allele.
#   parameters:	population *pop
# 		entity *adam
#   return:	success
#  **********************************************************************/
# boolean 
# ga_seed_char_random (population *pop, entity *adam)
# {
#   //int		chromo;		/* Index of chromosome to seed */
#   int		point;		/* Index of allele to seed */

#   /* Checks. */
#   if (!pop) die("Null pointer to population structure passed.");
#   if (!adam) die("Null pointer to entity structure passed.");

#   /* Seeding. */
#   //chromo=0;
#   //for (chromo=0; chromo<pop->num_chromosomes; chromo++)
#   //{
#   for (point=0; point<pop->len_chromosomes; point++)
#   {
#     ((char *)adam->CH/* chromosome[chromo] */)[point]
#       = (char)random_int(CHAR_MAX-CHAR_MIN)+CHAR_MIN;
#   }
#   //}

#   return TRUE;
# }
# /**********************************************************************
#   synopsis:	Seed genetic data for a single entity with a double-
# 		precision floating-point chromosome by randomly
# 		setting each allele.
#   parameters:	population *pop
# 		entity *adam
#   return:	success
#  **********************************************************************/
# boolean 
# ga_seed_double_random (population *pop, entity *adam)
# {
#   //int		chromo;		/* Index of chromosome to seed */
#   int		point;		/* Index of allele to seed */

#   /* Checks. */
#   if (!pop) die("Null pointer to population structure passed.");
#   if (!adam) die("Null pointer to entity structure passed.");

#   /* Seeding. */
#   //chromo=0;
#   //for (chromo=0; chromo<pop->num_chromosomes; chromo++)
#   //{
#   for (point=0; point<pop->len_chromosomes; point++)
#   {
#     ((double *)adam->CH/* chromosome[chromo] */)[point] =
#       random_double_range (pop->allele_min_double, pop->allele_max_double);
#   }
#   //}

#   return TRUE;
# }
# /**********************************************************************
#   synopsis:	Seed genetic data for a single entity with a double-
# 		precision floating-point chromosome by randomly
# 		setting each allele using a unit gaussian distribution.
#   parameters:	population *pop
# 		entity *adam
#   return:	success
#  **********************************************************************/
# boolean 
# ga_seed_double_random_unit_gaussian (population *pop, entity *adam)
# {
#   //int		chromo;		/* Index of chromosome to seed */
#   int		point;		/* Index of allele to seed */

#   /* Checks. */
#   if (!pop)  die ("Null pointer to population structure passed.");
#   if (!adam) die ("Null pointer to entity structure passed.");

#   /* Seeding. */
#   //chromo=0;
#   //for (chromo=0; chromo<pop->num_chromosomes; chromo++)
#   //{
#   for (point=0; point<pop->len_chromosomes; point++)
#   {
#     ((double *)adam->CH/* chromosome[chromo] */)[point] = random_unit_gaussian();
#   }
#   //}

#   return TRUE;
# }
# /**********************************************************************
#  **********************************************************************/
# boolean 
# ga_seed_double_zero (population *pop, entity *adam)
# {
#   //int		chromo;		/* Index of chromosome to seed */
#   int		point;		/* Index of allele to seed */

#   /* Checks. */
#   if (!pop)  die("Null pointer to population structure passed.");
#   if (!adam) die("Null pointer to entity structure passed.");

#   /* Seeding. */
#   //chromo=0;
#   //for (chromo=0; chromo<pop->num_chromosomes; chromo++)
#   //{
#   for (point=0; point<pop->len_chromosomes; point++)
#   {
#     ((double *)adam->CH/* chromosome[chromo] */)[point] = 0.0;
#   }
#   //}

#   return TRUE;
# }
# //------------------------------------------------------------------------------
# char
# get_random_wordchar ()

# //------------------------------------------------------------------------------
proc get_random_wordchar {} {

  #   GAULFUNC unsigned int char_num;
  #   char ch;  
  #   int randmax = '~' - ' ';
  
  set char_min [scan " " "%c"]
  set char_max [scan "~" "%c"] 
  
  set randmax [expr $char_max - $char_min]

  #   char_num = random_int (randmax) + ' ';
  set char_num [expr [random_int $randmax] + $char_min]
  
  #   ch = (char) char_num;
  #return (ch);

  # может лучше число просто возвращать? и формировать не строку, а список целых?
  return $char_num
}
# //------------------------------------------------------------------------------
# boolean 
# ga_seed_printable_random (population *pop, entity *adam)

# //------------------------------------------------------------------------------
proc ga_seed_printable_random {pop adam}  {

  #   //int		chromo;		/* Index of chromosome to seed */
  #   int		point;		/* Index of allele to seed */
  
  #   char ch;
  
  #   /* Checks. */
  #   if (!pop)  die ("Null pointer to population structure passed.");
  #   if (!adam) die ("Null pointer to entity structure passed.");
  
  #   /* Seeding. */
  #   //chromo=0;
  #   //for (chromo=0; chromo<pop->num_chromosomes; chromo++)
  #   //{


  #puts "ga_seed_printable_random : "
  #puts ""
  #$adam print
  #puts ""

  for {set point 0} {$point < [$pop cget -len_chromosomes]} {incr point}  \
  {
    # ch = get_random_wordchar (); 
    set ch [get_random_wordchar]

    # ((char *)adam->CH)[point] = ch ;

    #$adam set_chromo_gen $point $ch
    ent_set_chromo_gen_ $adam $point $ch
  }

  #   //}

  return true
}
# //------------------------------------------------------------------------------
# //  synopsis:	Randomly seed bitstring chromosomes.
# //  parameters:	population *pop
# //		entity *adam
# //  return:	success

# //------------------------------------------------------------------------------
# boolean 
# ga_seed_bitstring_random (population *pop, entity *adam)
# {
#   //int		chromo;		/* Index of chromosome to seed */
#   int		point;		/* Index of allele to seed */

#   /* Checks. */
#   if (!pop)  die("Null pointer to population structure passed.");
#   if (!adam) die("Null pointer to entity structure passed.");

#   /* Seeding. */
#   //chromo=0;
#   //for (chromo=0; chromo<pop->num_chromosomes; chromo++)
#   //{
#   for (point=0; point<pop->len_chromosomes; point++)
#   {
#     ga_bit_randomize (adam->CH/* chromosome[chromo] */,point);
#   }
#   //}

#   return TRUE;
# }
# //------------------------------------------------------------------------------
# /**********************************************************************
#   synopsis:	Seed bitstring chromosomes with zeros.
#   parameters:	population *pop
# 		entity *adam
#   return:	success
#  **********************************************************************/
# boolean 
# ga_seed_bitstring_zero (population *pop, entity *adam)
# {
#   //int  chromo;	/* Index of chromosome to seed */
#   int  point;	/* Index of allele to seed */

#   /* Checks. */
#   if (!pop) die("Null pointer to population structure passed.");
#   if (!adam) die("Null pointer to entity structure passed.");

#   /* Seeding. */
#   //chromo=0;
#   //for (chromo=0; chromo<pop->num_chromosomes; chromo++)
#   //{
#   for (point=0; point<pop->len_chromosomes; point++)
#   {
#     ga_bit_clear (adam->CH/* chromosome[chromo] */, point);
#   }
#   //}

#   return TRUE;
# }
# //******************************************************************************


