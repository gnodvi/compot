// -*-  mode: c    ; coding: koi8   -*- ----------------------------------------


#include <stdio.h>
#include <stdlib.h> 
#include <string.h>
#include <math.h>
#include <time.h>

#include <unistd.h>
#include <getopt.h>    /* for getopt_long; POSIX standard getopt is in unistd.h */

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

/*******************************************************************************/

#ifdef _GNUPLOT
#include "p_gnup.h"
#endif

//#include "e-0000.h"
#include "e-1111.h"

// -----------------------------------------------------------------------------



#ifdef _GNUPLOT
/*--------------------------------plot_gnu-------------------------------------*/
/*                                                                             */
/*-----------------------------------------------------------------------------*/
void
plot_gnu (char *title, int ti, YT_PLOT *p, gnuplot_ctrl *gp)
{

  double x, y, w, h;
  int    fi, li;
  double /* *f_calc, *f_true, */ *f_line;
  
  x = 0.0;
  w = 1.0;
  h = 1.0 / p->fnum;
  
  for (fi=0 ; fi<p->fnum ; fi++) {

    if (fi == 0) {
      if (p->fnum != 1) 
        gnuplot_cmd (gp, "set noxtics"); 
      gnuplot_cmd (gp, "set title '%s'", title); 
    } else {
      gnuplot_cmd (gp, "set xtics"); 
      gnuplot_cmd (gp, "set title"); 
    }
    
    y = 1.0 - (fi+1) * h;
    
    gnuplot_cmd (gp, "set size %.2f, %.2f", w, h);       
    gnuplot_cmd (gp, "set origin %.2f, %.2f", x, y);     
    gnuplot_cmd (gp, "set xrange [%f : %f]", p->xmin[fi], p->xmax[fi]);          
    gnuplot_cmd (gp, "set yrange [%f : %f]", p->ymin[fi], p->ymax[fi]);          
    
    /* 		f_calc = p->f_calc[fi] + ti*(p->xnum); */
    /* 		if (p->f_true[fi]) f_true = p->f_true[fi] + ti*(p->xnum); */
    /* 		else               f_true = NULL; */
    /* 		gnuplot_plot_xy (gp, p->x, f_calc, p->xnum, p->f_name[fi]); */
    /* 		gnuplot_plot_xy (gp, p->x, f_true, p->xnum, "TRUE"); */
    
    //------------
    
    for (li=0; p->f[fi][li] != NULL; li++) {
      f_line = p->f[fi][li] + ti*(p->xnum);
      gnuplot_plot_xy (gp, p->x, f_line, p->xnum, p->l_name[fi][li],
                       0);
    }
    
    gp->nplots = 0;
  }
  
  return;
}
/*--------------------------------plot_gnu_new---------------------------------*/
/*                                                                             */
/*-----------------------------------------------------------------------------*/
void
plot_gnu_new (char *title, int ti, YT_PLOT *p, gnuplot_ctrl *gp)
{

  double x, y, w, h;
  int    fi, li;
  double *f_line;
  
  x = 0.0;
  w = 1.0;
  h = 1.0 / p->fnum;
  
  for (fi=0 ; fi<p->fnum ; fi++) {
    
    gnuplot_cmd (gp, "set noxtics"); 
    gnuplot_cmd (gp, "set title"); 
    
    if (fi == 0) {
      gnuplot_cmd (gp, "set title '%s'", title); 
    } else if (fi == p->fnum-1) {
      gnuplot_cmd (gp, "set xtics"); 
    }
    
    y = 1.0 - (fi+1) * h;
    
    gnuplot_cmd (gp, "set size %.2f, %.2f", w, h);       
    gnuplot_cmd (gp, "set origin %.2f, %.2f", x, y);     
    gnuplot_cmd (gp, "set xrange [%f : %f]", p->xmin[fi], p->xmax[fi]);          
    gnuplot_cmd (gp, "set yrange [%f : %f]", p->ymin[fi], p->ymax[fi]);          
    
    //------------
    for (li=0; p->f[fi][li] != NULL; li++) {
      f_line = p->f[fi][li] + ti*(p->xnum);
      gnuplot_plot_xy (gp, p->x, f_line, p->xnum, p->l_name[fi][li],
                       0);
    }
    
    gp->nplots = 0;
  }
  
  return;
}
/*-----------------------------------plot_step---------------------------------*/
/*                                                                             */
/*-----------------------------------------------------------------------------*/
void
plot_step (void *ptr, BOOL is_win, BOOL is_gnu, int mode)
{

  int  ti_incr = +1;
  char buff[80];
  int fi, xi, ti, i, height;
  char *title;
  static YT_PLOT *plot;
  static int ih_one, iw, ih;
  static gnuplot_ctrl *gp;
  static BOOL first1;
  static BOOL first2;
  
  
  //----------------------- подготовительная часть 
  if (mode == -1) {
    
    plot = (YT_PLOT*) ptr;
    
    if (plot->fnum == 1) ih_one = 18; 
    if (plot->fnum == 2) ih_one = 13; 
    if (plot->fnum == 3) ih_one = 9; 
    if (plot->fnum == 4) ih_one = 8; 
    ih = (plot->fnum * ih_one) + plot->fnum + 1;
    iw = 70;
    
    for (fi=0 ; fi<plot->fnum ; fi++) 
      plot_min_max (fi, plot);
    
    first1 = TRUE;
    first2 = TRUE;
    
    if (is_gnu) {
      gp = gnuplot_init ();
      gnuplot_setstyle (gp, "lines"  /* "linespoints" */);
      gnuplot_cmd (gp, "set format y '%%8g'");           
      gnuplot_cmd (gp, "set multiplot");           
    }
    
    return;
  }
  
  //----------------------- закрывающая часть 
  if (mode == -2) {
    if (is_gnu) gnuplot_close (gp);
    return;
  }
  
  //----------------------- основная часть 
  ti = mode;
  title = (char*)ptr;
  
  if (!first1) CUU;
  
  printf ("%s \n", title);
  
  if (is_gnu) {
    gnuplot_resetplot(gp); //??
    gnuplot_cmd (gp, "set multiplot"); // заодно и перерисовывает          
    plot_gnu (title, ti, plot, gp);
  }
  
  if (first1) {
    printf ("\n"); CUU; 
    first1 = FALSE;
  }

  printf ("Command: ");
  
  return;
  
}
/*-----------------------------------------------------------------------------*/
#endif  // #ifdef _GNUPLOT



/*---------------------------------plot_print----------------------------------*/
/*                                                                             */
/*-----------------------------------------------------------------------------*/
void
plot_print (YT_PLOT *plot, BOOL is_win, BOOL is_gnu)
{

  int  ti, ch, ti_incr = +1;
  char buff[80];
  
  //~~~~~~~~~~~~~~~~~~~~~~~~
#ifdef _GNUPLOT
  //~~~~~~~~~~~~~~~~~~~~~~~~
  
  plot_step (plot, is_win, is_gnu, -1);
  
  ti = 0;

  while (1) {
    plot_step (plot->title[ti], is_win, is_gnu, ti);
    
    while (1) { 

      fgets (buff, 50, stdin); CUU;

      if      (buff[0] == '\n') ti += ti_incr;
      else if (buff[0] ==  'g') ti = atoi(&(buff[1]));
      else if (buff[0] ==  '[') ti = 0;
      else if (buff[0] ==  ']') ti = plot->tnul;
      else if (buff[0] ==  'f') ti_incr = +1;
      else if (buff[0] ==  'b') ti_incr = -1;
      else if (buff[0] ==  ' ') ti_incr = -ti_incr;
      else if (buff[0] ==  'q') goto end;
      else continue;

      if (ti > plot->tnul) ti = plot->tnul;
      if (ti < 0)    ti = 0;
      break;
    }
  }
  
end:
  plot_step (NULL, is_win, is_gnu, -2);
  
  //~~~~~~~~~~~~~~~~~~~~~~~~
#endif  //ifdef _GNUPLOT
  //~~~~~~~~~~~~~~~~~~~~~~~~
  
  return;
}


//------------------------------------------------------------------------------
