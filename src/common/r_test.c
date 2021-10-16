// -*-  mode: c    ; coding: koi8   -*- ----------------------------------------

/*******************************************************************************
 *                                                                             *
 *  Имя этого файла: r_test.c                                                  *
 *                                                                             *
  ******************************************************************************
 */ 
                                                                             

#include <stdlib.h>
#include <stdio.h>

#include "r-main.h"

 
//------------------------------------------------------------------------------
void 
test_random_int ()
{
  //random_init ();
  //random_seed (12345);

  printf ("\n");

  int i, max = 4;
  
  for (i = 0; i < 30; i++) {
    
    //int ret                   =  (int) random_int (max);
    ///* GAULFUNC  */unsigned int rnd = random_rand ();
    ///* GAULFUNC  */unsigned int rnd = random_rand ();

    int ret  =  (int) randint (max);
    unsigned int rnd = urand ();

    printf ("i = %4d, max = %d,   i mod max = %d,   rnd = %10u, rnd mod max = %d,   ret = %2d \n",
	    i, max,  i % max,
	    rnd, rnd % max,
	    ret);

  }

  printf ("\n");

  return;
}
//------------------------------------------------------------------------------
void 
test_random_float ()
{

  //printf ("\n");

  int i;
  float  max = 12;
  
  for (i = 0; i < 10; i++) {
    
    //int ret  =  (int) randint (max);
    //unsigned int rnd = urand ();

    //printf ("i = %4d, max = %d,   i mod max = %d,   rnd = %10u, 
    // rnd mod max = %d,   ret = %2d \n",
    //	    i, max,  i % max,
    //	    rnd, rnd % max,
    //	    ret);

    double ret  =  randreal (max /* 12.0 */);

    printf ("i = %4d  ret = %6.2f \n", i, ret);
  }

  printf ("\n");

  return;
}
/*----------------------------------------------------------------------------*/
// 
//------------------------------------------------------------------------------
int 
main (int argc, char** argv) 
{
  char *name;
  int   j;
  //YT_PLOT *plot;

  printf ("\n");

  //-------------------------

  printf ("argc = %d \n", argc); 
  
  /*   if (argc == 1) { */
  /*     name = "anim"; */
  /*   } else { */
  /*     j = 1; */
  /*     name = argv[j++]; */
  /*   } */

  if (argc == 1) 
    usrand (0); // time
  else
    usrand (2021); // time


  test_random_int ();

  printf ("\n");

  test_random_float ();


  return (0);
}
/*============================================================================*/

