/*******************************************************************************
  c_x_tester.c

*******************************************************************************/

#include "c_all_util.h"

//******************************************************************************
//  synopsis:	Test GAUL's bitstring routines.
//------------------------------------------------------------------------------
void 
test_bitstrings (int argc, char **argv)
{

  //fprintf (stderr, "..11.. \n");

  ga_bit_test ();

  return;
}
//******************************************************************************
//  Synopsis:	Test GAUL pseudo-random number generator.
//------------------------------------------------------------------------------
void 
test_prng (int argc, char **argv)
{
  //boolean  success;

  /* Usual initializations */
  random_init ();

  /* Run randomness test function */
  /* success = */ random_test ();

  //printf ("\n");

  //if (success == FALSE)
  //  printf ("*** Routines DO NOT produce sufficiently random numbers.\n");
  //else
  //  printf ("Routines produce sufficiently random numbers.\n");

  printf ("\n");

  return;
}
//******************************************************************************
//  synopsis:	Test GAUL's general support code.
//------------------------------------------------------------------------------
void 
test_utils (int argc, char **argv)
{

/*
 * Run utility test functions.
 */
  avltree_test ();

  table_test ();

  linkedlist_test ();

  return;
}
//------------------------------------------------------------------------------
void 
test_ ()
{
  //random_init ();
  random_seed (1234);

  int chromo =  (int) random_int (1/* pop->num_chromosomes */);

  printf ("chromo= %d \n", chromo);

  return;
}
//------------------------------------------------------------------------------
int 
main (int argc, char **argv)
{

  //fprintf (stderr, "..00.. \n");

  if (argc !=2 ) 
    exit (EXIT_SUCCESS);

  if (!strcmp(argv[1], "bitstrings")) test_bitstrings (argc, argv);
  if (!strcmp(argv[1], "prng"))       test_prng (argc, argv);
  if (!strcmp(argv[1], "utils"))      test_utils (argc, argv);
  if (!strcmp(argv[1], "_"))          test_ ();

  exit (EXIT_SUCCESS);
}
//------------------------------------------------------------------------------

// c_x_test_prng.sh 

// c_x_tester bitstrings
// c_x_tester utils

//******************************************************************************



