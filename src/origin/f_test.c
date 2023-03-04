// -*-  mode: c    ; coding: koi8   -*- ----------------------------------------

#include <stdio.h>
#include <stdlib.h> 
#include <string.h>
#include <math.h>
#include <time.h>

#include <unistd.h>
#include <getopt.h>    /* for getopt_long; POSIX standard getopt is in unistd.h */


/* #include <sys/time.h> */
/* #include <sys/param.h> */
/* #include <sys/timeb.h> */

/* #include <semaphore.h> */
/* #include <errno.h> */
/* #include <unistd.h> */
/* #include <limits.h> */
/* #include <libgen.h> */
/* #include <sys/types.h> */
/* #include <stdint.h> */

#include <igraph.h>


/*-----------------------------------------------------------------------------*/ 

//#include "e-0000.h"

//#include "e-graf.h"

/*-----------------------------------------------------------------------------*/ 
void
test_01 ()
{

  //GRAF *pg;
  //int   s, t, nn;
  //double  r, d;
  //int     num_r, num_d;

  igraph_t graph;

  printf ("\n");
  printf (".... test_01 .................... \n");

  //pg = GrafCreate (4);
  
  //GrafInit (pg, YRAND, 0.0, 0.0, YRAND, NOT, NOT);
  
  //EDGE (pg, 0, 1) = 1;
  //EDGE (pg, 1, 2) = 1;
  //EDGE (pg, 2, 3) = 1;
  //EDGE (pg, 0, 3) = 3.1 /* 2.9 */;
  

  igraph_integer_t edges[] = { 0,1, 1,2, 2,3, 0,3 };

  //VECTOR(edges)[0] = 1;

  //igraph_add_edges (&graph, &edges, NULL);


  //s = 0;
  //t = 3;
  
  //printf ("\n");
  //GrafPrint (pg);

  //GrafSmin (pg, s, t, NULL);
  //printf ("\n");

  //GrafMetrica (pg, &r, &d, &num_r, &num_d);

  //printf ("r = %.1f  num_r = %d \n", r, num_r);
  //printf ("d = %.1f  num_d = %d \n", d, num_d);

  printf ("\n");

  return;
}
/*-----------------------------------------------------------------------------*/ 
int
main (int argc, char *argv[])
{

  int test_num   = 1; // test_01

  //get_options (argc, argv, 
  //           NULL, NULL, 
  //           /* &interval_ms */ NULL, /* &count_max */ NULL, 

  //           NULL, NULL, &test_num, NULL);

  //int is_win = 0;
  //int is_gnu = 0;

  //---------------------------------------------


  optind = 1; // чтобы бы повторном (вложенном вызове) начать с начала 

  static struct option long_options[] = {
/*     {"verbose", no_argument,       NULL,   0}, */
/*     {"create",  required_argument, NULL, 'c'}, */
/*     {"win",     no_argument, NULL,   0}, */
/*     {"gnu",     no_argument, NULL,   0}, */
/*     {"test",    required_argument, NULL,   0}, */
/*     {"loop0",   no_argument,       NULL,   0}, */
/*     {"loop1",   no_argument,       NULL,   0}, */
    {NULL,      0,                 NULL,   0}
  };
  int option_index = 0;
  

  // перебираем все параметры:
  // (в QNX эти параметры должны идти первыми)

  //DAO_LOOP daoloop = dao_loop0;
  char c;
  const char *name;

  while ((c = getopt_long (argc, argv, "uha:p:i:n:o:vt:",
                      long_options, &option_index)) != -1) { 

    //fprintf (stderr, "get_options: optind = %d   c = %c \n", optind, c);

    switch (c) {

    case 0: // обработка длинных опций

      name = long_options[option_index].name;

      printf ("option %s", name);
      if (optarg)
        printf (" with arg %s", optarg);
      printf ("\n");

/*       if (! strcmp (name, "win"))   is_win  = 1; */
/*       if (! strcmp (name, "gnu"))   is_gnu  = 1; */

/*       if (! strcmp (name, "loop0")) daoloop = dao_loop0; */
/*       if (! strcmp (name, "loop1")) daoloop = dao_loop1; */

      break;
      
    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    case 't': 
      test_num = atoi (optarg); 
     break;

    case 'h': 
      //get_options_print_help (); 
      break;

      //default:      
      // exit( EXIT_FAILURE ); // сюда невозможно попасть!
    }
  }


  //YT_PLOT *plot;
  
  switch (test_num) {
    
  case 0:
    //daoloop (is_win, is_gnu); // вызываем уже заданную функцию
    break;

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  // а здесь вспомогательные тесты, например по графам 

  case 1:
    test_01 ();
    break;

  case 11:
    //test_11 ();
    break;

  case 2:
    //test_00 (4);
    break;


    //case 3:
    //dao_loop0 (/* argc, argv */is_win, is_gnu);
    //break;

    //case 4:
    //plot = make_plot_test (100, 0, 2*YPI);
    //plot_print (plot, FALSE, TRUE);
    //break;

  default:
    break;

  }

  printf ("\n");

  //return 1;
  return (0); // Tcl's exec treats any non-zero exit status as an exceptional 
  // situation. 
}
//------------------------------------------------------------------------------

// time e_meta -t3

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
//------------------------------------------------------------------------------
