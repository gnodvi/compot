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

/*******************************************************************************/

#include "p_gnup.h"

#include "e-comm.h"

/*-----------------------------------------------------------------------------*/
/*                                                                             */
/*                              C O M M O N . C                                */
/*                                                                             */
/*-----------------------------------------------------------------------------*/ 


/*----------------------------------YRandF-------------------------------------*/
/*                                                                             */
/*-----------------------------------------------------------------------------*/ 
double
YRandF (double fmin, double fmax)
{
  double   choise;
  choise = drand48 ();

  return (fmin + choise * (fmax - fmin));
}
/*------------------------------------YInt-------------------------------------*/
/*  Округление до ближайшего целого                                            */
/*-----------------------------------------------------------------------------*/ 
int
YInt (double f)
{
  int     i;
  double  o;

  i = (int) f;
  o = f - i;
  if      (o >  0.5 + EPS)  i++;
  else if (o < -0.5 - EPS)  i--;

  return (i);
}
/*------------------------------------Error------------------------------------*/
/*  Аварийный выход с сообщением                                               */
/*-----------------------------------------------------------------------------*/ 
void
Error (const char *string)
{

  printf ("Error : %s \n", string);
  exit (EXIT_FAILURE);

}
/*-----------------------------------Rand123-----------------------------------*/
/*                                                                             */
/*-----------------------------------------------------------------------------*/
int
Rand123 (double p1, double p2, double p3)
{

  // идея хорошая, но нет проверки на кооректность интервалов!
  // 

  int yrand;
  
  yrand = YRAND (1, 100);
  
  if      (yrand < p1) return (1);
  else if (yrand > p3) return (3);
  else                 return (2);
  
  p2++; // не используется
}
/*-----------------------------------RandYes-----------------------------------*/
/*                                                                             */
/*-----------------------------------------------------------------------------*/
BOOL
RandYes (double procent)
{

  if (Rand123 (procent, 0.0, 100.0-procent)==1)
    return (TRUE);
  else
    return (FALSE);
  
}
/*-----------------------------------FRavno------------------------------------*/
/*                                                                             */
/*-----------------------------------------------------------------------------*/
BOOL
FRavno (double d1, double d2, double eps)
{

  if (fabs(d1-d2) < eps) return TRUE;
  else                   return FALSE;

}
/*------------------------------------str_cmp----------------------------------*/
/*                                                                             */
/*-----------------------------------------------------------------------------*/
BOOL
str_cmp (const char *str1, const char *str2)
{
  if (!str1 || !str2) return (FALSE);


  return (!(strcmp(str1, str2)));
}
/*------------------------------------YStrCmp----------------------------------*/
/*                                                                             */
/*-----------------------------------------------------------------------------*/
BOOL                                                                         
YStrCmp (char *str1, char *str2)                                                
{                                                                               
  if (!str1 || !str2) return (FALSE);                                           
                                                                                
  return (!(strcmp(str1, str2)));                                               
}                                                                               
/*-----------------------------------Numer-------------------------------------*/
/*                                                                             */
/*-----------------------------------------------------------------------------*/
int
Numer (int dim, int *ijk, int *IJK)
{
  int numer, i;

  numer = ijk[dim-1];

  for (i=0; i < dim-1; i++) {
    numer = numer + (ijk[i] * IJK[i]);
  }

  return (numer);
}
/*---------------------------------Out-----------------------------------------*/
/*                                                                             */
/*-----------------------------------------------------------------------------*/ 
ZT_OUT *
Out (ZT_OUT *p_out, const char *legend)
{

  ZT_OUT *p;
  
  for (p=p_out; p->numw!=0; p++) {
    
    if (strcmp(legend, p->legend)==0) {
      return (p);
    }
  }
  
  return (NULL);
}
/*-------------------------------Get_N_Plot------------------------------------*/
/*                                                                             */
/*-----------------------------------------------------------------------------*/ 
int
Get_N_Plot (ZT_OUT *p_out)
{

  int n_plot;
  
  n_plot = 0;
  
  for ( ; p_out->numw != 0; p_out++) {
    if (!(p_out->val)) continue;
    
    if (p_out->numw > n_plot)
      n_plot = p_out->numw;
  }
  
  return (n_plot);
}
/*-----------------------------Do_Open_Close-----------------------------------*/
/*                                                                             */
/*-----------------------------------------------------------------------------*/ 
void
Do_Open_Close (ZT_OUT *p_out, int mod, int xnum)
{

  //int xnum = 2000;
  static YT_PLOT *plot;
  static int step, n_line[MAX_OUT], numw, max_numw;

  ZT_OUT *p_out_tmp;
  
  if (mod == 1) {
    max_numw = -10;
    for (p_out_tmp=p_out; p_out_tmp->numw != 0; p_out_tmp++) {
      if (!(p_out_tmp->val)) continue;
      max_numw = YMAX(max_numw, p_out_tmp->numw);
    }
    
    plot = plot_create (max_numw, xnum, 1);
    strcpy (plot->title[0], "Test for GRAF");
    
    plot->f[0][1] = NULL;
    plot->f[1][1] = NULL;
    step = 0;
    n_line[0] = n_line[1] = n_line[2] = n_line[3] = 0;
    
    for ( ; p_out->numw != 0; p_out++) {
      if (!(p_out->val)) continue;
      
      numw = p_out->numw-1;
      plot->f[numw][n_line[numw]] = p_out->f = (double*) malloc (xnum * sizeof(double));
			plot->l_name[numw][n_line[numw]++] = p_out->legend;
                        
    }
  }
  
  if (mod == 2) {
    plot->x[step] = step;
    step++;
  }
  
  if (mod == 3) {
    plot->xnum = step;
    plot_print (plot, TRUE, TRUE);
  } 
  
  return;
}
/*******************************************************************************/
/*-----------------------------------------------------------------------------*/
/*                                                                             */
/*                              P L O T E R . C                                */
/*                                                                             */
/*-----------------------------------------------------------------------------*/ 

/*---------------------------------plot_create---------------------------------*/
/*                                                                             */
/*-----------------------------------------------------------------------------*/
YT_PLOT*
plot_create (int fnum, int xnum, int tnum)
{

  int fi, ti, li;
  YT_PLOT *plot;
  
  plot = (YT_PLOT*) malloc (sizeof(YT_PLOT));
  
  plot->x = (double*) malloc (xnum * sizeof(double));
  
  plot->fnum = fnum;
  plot->xnum = xnum;
  plot->tnum = tnum;
  
  for (fi=0; fi<fnum; fi++)
    for (li=0; li<20;   li++)
      plot->f[fi][li] = NULL;
  
  //plot->title = (char**) malloc (TNUL+10);
  for (ti=0; ti<=/* TNUL */tnum; ti++) 
    plot->title[ti] = (char*) malloc (80*sizeof(char));
  
  
  return (plot);
}
/*---------------------------plot_min_max_local--------------------------------*/
/*                                                                             */
/*-----------------------------------------------------------------------------*/
void
plot_min_max_local (int fi, int ti, YT_PLOT *plot, double *p_xmin, double *p_ymin, 
							double *p_xmax, double *p_ymax)
{

	double  xmin, ymin, xmax, ymax;
	int     i, li;
	double  *x, *f_line;

  x = plot->x;

	xmin = ymin = /*  10000 */ YMAXDOUBLE;
	xmax = ymax = /* -10000 */ YMINDOUBLE;

	for (i=0 ; i<plot->xnum ; i++) {
		if (x[i] < xmin) xmin = x[i];
		if (x[i] > xmax) xmax = x[i];

		for (li=0; plot->f[fi][li] != NULL; li++) {
			f_line = plot->f[fi][li] + ti*(plot->xnum);
			if (f_line[i] < ymin) ymin = f_line[i];
			if (f_line[i] > ymax) ymax = f_line[i];
		}
	}

	*p_xmin = xmin;
	*p_ymin = ymin;
	*p_xmax = xmax;
	*p_ymax = ymax;

	return;
}
/*--------------------------------plot_min_max---------------------------------*/
/*                                                                             */
/*-----------------------------------------------------------------------------*/
void
plot_min_max (int fi, YT_PLOT *plot)
{

  double  xmin, ymin, xmax, ymax;
  int     ti;
  
  plot->xmin[fi] = plot->ymin[fi] = /*  10000 */  YMAXDOUBLE;
  plot->xmax[fi] = plot->ymax[fi] = /* -10000 */  YMINDOUBLE;
  
  //for (ti=0; ti<plot->tnum; ti++) {
  for (ti=0; ti<=plot->tnul; ti++) {
    plot_min_max_local (fi, ti, plot, &xmin, &ymin, &xmax, &ymax);
    
    plot->xmin[fi] = YMIN (xmin, plot->xmin[fi]);
    plot->xmax[fi] = YMAX (xmax, plot->xmax[fi]);
    
    plot->ymin[fi] = YMIN (ymin, plot->ymin[fi]);
    plot->ymax[fi] = YMAX (ymax, plot->ymax[fi]);
  }
  
  if (FRavno(plot->ymin[fi], plot->ymax[fi], EPS)) {
    // !!!!!!!!!!!!!!!????
    plot->ymin[fi] -= 10.0;
    plot->ymax[fi] += 10.0;
  }
  
  return;
}
/*--------------------------------plot_gnu---------------------------------*/
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
/*---------------------------------plot_print----------------------------------*/
/*                                                                             */
/*-----------------------------------------------------------------------------*/
void
plot_print (YT_PLOT *plot, BOOL is_win, BOOL is_gnu)
{

  int  ti, ch, ti_incr = +1;
  char buff[80];
  
  
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
  
  
  return;
}
/*-----------------------------------win_sgr-----------------------------------*/
/*                                                                             */
/*-----------------------------------------------------------------------------*/
void
win_sgr (int par)
{

	printf ("\033[ %d m", par);

}
/*******************************************************************************/
// -----------------------------------------------------------------------------
