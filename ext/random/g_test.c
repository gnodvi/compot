// -*-  mode: c    ; coding: koi8   -*- ----------------------------------------



#include "g-comm.h"

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
//------------------------------------------------------------------------------
void 
test_random_int ()
{
  random_init ();
  random_seed (12345);

  printf ("\n");

  int i, max = 2;
  
  for (i = 0; i < 30; i++) {
    
    int ret                   =  (int) random_int (max);
    /* GAULFUNC  */unsigned int rnd = random_rand ();

    printf ("i = %4d, max = %d,   i mod max = %d,   rnd = %10u, rnd mod max = %d,   ret = %2d \n",
	    i, max,  i % max,
	    rnd, rnd % max,
	    ret);
  }

  printf ("\n");

  return;
}
//------------------------------------------------------------------------------
int 
main (int argc, char **argv)
{

  //fprintf (stderr, "..00.. \n");

  if (argc !=2 ) 
    exit (EXIT_SUCCESS);

/*   if (!strcmp(argv[1], "bitstrings")) test_bitstrings (argc, argv); */
  if (!strcmp(argv[1], "prng"))       test_prng (argc, argv);
/*   if (!strcmp(argv[1], "utils"))      test_utils (argc, argv); */
  if (!strcmp(argv[1], "test"))       test_random_int ();

  exit (EXIT_SUCCESS);
}
//------------------------------------------------------------------------------

// c_x_tester test
// c_x_test_prng.sh 

// c_x_tester bitstrings
// c_x_tester utils

//******************************************************************************



