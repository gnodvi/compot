// -*-  mode: c    ; coding: koi8   -*- ----------------------------------------

#include <stdio.h>
#include <stdlib.h> 
#include <string.h>
#include <math.h>
#include <time.h>
#include <unistd.h>
#include <sys/time.h>
#include <sys/param.h>
#include <sys/timeb.h>

#include <semaphore.h>
#include <errno.h>
#include <unistd.h>
#include <limits.h>
#include <libgen.h>
#include <sys/types.h>
#include <stdint.h>

/*-----------------------------------------------------------------------------*/ 


#include "e-graf.h"


/*-----------------------------------------------------------------------------*/ 
int
main (int argc, char *argv[])
{

  int test_num   = 0;

  get_options (argc, argv, 
             NULL, NULL, 
             /* &interval_ms */ NULL, /* &count_max */ NULL, 

             NULL, NULL, &test_num, NULL);


  YT_PLOT *plot;
  
  switch (test_num) {
    
  case 0:
    dao_loop1 (argc, argv);
    break;


  case 1:
    test_01 ();
    break;

  case 11:
    test_11 ();
    break;

  case 2:
    test_00 (4);
    break;


  case 3:
    dao_loop0 (argc, argv);
    break;

  case 4:
    plot = make_plot_test (100, 0, 2*YPI);
    plot_print (plot, FALSE, TRUE);
    break;

  default:
    break;

  }

  printf ("\n");

  //return 1;
  return (0); // Tcl's exec treats any non-zero exit status as an exceptional 
  // situation. 
}
//------------------------------------------------------------------------------

// cl g~.cl GRAF test_01      
// c_graf -t1

// sl g~.cl GRAF test_11 

// cl g~.cl NETS amat_03 
// sl g~.cl META tao_loop0 500 1  1706 0 
// sl g~.cl META tao_loop1 200 2 3  1706 0


// g~.tl GRAF test_01 
// g~.tl GRAF test_11 
// g~.tl GRAF test_99 
// g~.tl META tao_loop0 5 1    1706 0 
// g~.tl META tao_loop1 3  2 3  1706 0 
// g~.tl META test_00 
// g~.tl META test_05 
// g~.tl NETS amat_03 

//------------------------------------------------------------------------------
