// -*-  mode: c    ; coding: koi8   -*- ----------------------------------------

/*******************************************************************************
 *                                                                             *
 *  Имя этого файла: a_test.c                                                  *
 *                                                                             *
  ******************************************************************************
 */ 
                                                                             
 
#include "p_comm.h"
#include "p_gnup.h"
#include "p_plot.h"

#include "p_plot_more.h"


/*----------------------------------------------------------------------------*/
// 
/******************************************************************************/
void 
glib_test ()
{

  printf ("G_MININT= %d  G_MAXINT= %d  \n", G_MININT, G_MAXINT);
  printf ("MIN= %d  MAX= %d  \n", MIN (2, 5), MAX (2, 5));
  printf ("G_DIR_SEPARATOR_S= %s  \n", G_DIR_SEPARATOR_S);

  return;
}
/*----------------------------------------------------------------------------*/
void 
rand_test_0 ()
{

  int imin = 1;
  int imax = 4;
  int i;

  for (i=0; i<10; i++) {
    printf ("YRAND(1 4)= %ld  \n", YRAND(imin, imax));    
  }

}
/*----------------------------------------------------------------------------*/
void 
rand_test ()
{

  double v, vmin=-10, vmax=7;

  printf ("time(0)= %ld  \n", time(0));
  printf ("time(0)= %ld  \n", time(0));
  printf ("\n");

  YRAND_F;
  v = YRandF (vmin, vmax);
  printf ("v= %f  \n", v);

  YRAND_F;
  v = YRandF (vmin, vmax);
  printf ("v= %f  \n", v);

  return;
}
/*----------------------------------------------------------------------------*/
void
FOR_ALL_test (int dim)
{
#define MAX_DIM 1000 

  int    d/* , dim */;
  int    ijk[MAX_DIM], IJK[MAX_DIM]; // индекс и его граница

  //dim = 3;
  //dim = 12;

  for (d=0; d < dim; d++) {
    IJK[d] = 2; 
  }

  MF *mf = MFOR_create (dim, ijk, IJK);

  int index = 0;

  while (MFOR_todo (mf))  {    // просто переибраем

    index ++;
    MFOR_print_ijk (ijk, dim, index); // просто печатаем
  }

  return;
}
/*----------------------------------------------------------------------------*/
void 
plot_savedir (char *dirname) 
{

  //YT_PLOT *plot;
  //TADMOR tadmor, *tad = &tadmor;
  //tadmor_get_arrays (tad, main_dir);
  //plot = tadmor_make_plot (tad);
  //plotbig_print_gtk (plot, 0,0,0,0);


  YT_PLOT *plot2;
  TADMOR tadmor, *tad = &tadmor;
  
  tadmor_get_arrays (tad, dirname);
  
  plot2 = tadmor_make_plot (tad);
  
  //plotbig_print_gtk (plot2, 0,0,0,0);
  plot_print (plot2,   TRUE, FALSE /*is_gnu*/);

  return;
}
//------------------------------------------------------------------------------



//------------------------------------------------------------------------------
int 
main (int argc, char** argv) 
{
  char *name;
  int   j;
  YT_PLOT *plot;

  printf ("\n");

  //-------------------------

  printf ("argc = %d \n", argc);

  if (argc == 1) {
    name = "anim";
  } else {
    j = 1;
    name = argv[j++];
  }

  //-------------------------

  if (!strcmp (name, "glib"))    glib_test ();
  if (!strcmp (name, "rand"))    rand_test ();
  if (!strcmp (name, "rand_0"))  rand_test_0 ();
  if (!strcmp (name, "wint"))    win_test_old ();


  if (!strcmp (name, "fora"))    FOR_ALL_test (3);
  if (!strcmp (name, "for8"))    FOR_ALL_test (8);


  if (!strcmp (name, "anim"))   gnuplot_i_anim (); 
  if (!strcmp (name, "exam"))   gnuplot_i_example (); 
  if (!strcmp (name, "sine"))   gnuplot_i_sinepng (); 


  if (!strcmp (name, "plot"))    plot_test ();

  if (!strcmp (name, "plot_D"))      plot_savedir ("D");

  if (!strcmp (name, "plot_D_err"))  plot_savedir ("D_err");

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  if (!strcmp (name, "plot3")) {

    plot = make_plot_test_3 ();

    plot_print (plot,   TRUE, /* FALSE */ TRUE);
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  if (!strcmp (name, "plot3gnu"))  {

    plot = make_plot_test_3 ();

    int  X = 400; 
    int  Y = 100;  
    
    int  W = 620; 
    int  H = 500;
    
    T_PLOTSTEP *ps = plotbig_step_beg (plot, X, Y, W, H); 
    
    plotbig_step_do (ps, plot->ti);
    sleep (2);
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
     

  printf ("\n");

  return (0);
}
/*============================================================================*/

