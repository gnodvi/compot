// -*-  mode: c    ; coding: koi8   -*- ----------------------------------------

/*-----------------------------------------------------------------------------*/
/*                                                                             */
/*                              K E R N E L . C                                */
/*                                                                             */
/*-----------------------------------------------------------------------------*/
 
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <math.h>
#include <time.h>
#include <unistd.h>
#include <sys/time.h>
#include <sys/param.h>
#include <sys/timeb.h>
#include <values.h>

//#include "gnuplot_i.h"  
//#include "b_gnup.h"  
#include "p_gnup.h"  

#include "sol-kernel.h"  

/*******************************************************************************/


BOOL debug;
char left_buf[80] = "                 ";
int  left_num;


/*******************************************************************************/
/*******************************************************************************/

/*----------------------------------YRandF-------------------------------------*/
/*                                                                             */
/*-----------------------------------------------------------------------------*/ 
double
  YRandF (double fmin, double fmax)
{
  #ifdef Y_UNIX
  double   choise;
  choise = drand48 ();
  return (fmin + choise * (fmax - fmin));
  #else
  int     irand, imax = 10000;
  irand = YRAND (0, imax);
  return (fmin + irand * ((fmax - fmin) / imax));
  #endif
}
/*------------------------------------YInt-------------------------------------*/
/*  Округление до ближайшего целого                                            */
/*-----------------------------------------------------------------------------*/ 
int
  YInt (double f)
{
  int     i;
  double   o;

  i = (int) f;
  o = f - i;
  /*   if      (o >  0.5)  i++; */
  /*   else if (o < -0.5)  i--; */
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
  int /* ret, */ yrand;

  yrand = YRAND (1,100);

  if      (yrand < p1) return (1);
  else if (yrand > p3) return (3);
  else                 return (2);

  p2++;
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
YT_BOOL                                                                         
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
/*******************************************************************************/
/****************************************************************************/
/***************************************************************************/
/*---------------------------------VHandPixel----------------------------------*/
/*                                                                             */
/*-----------------------------------------------------------------------------*/
BOOL
  VHandPixel (YT_WIN *win, int x, int y, CHAR ch)
{

  win_char (win, ch, x, y);

  return (TRUE);
}
/*---------------------------------VHandLineFunc-------------------------------*/
/*                                                                             */
/*-----------------------------------------------------------------------------*/
BOOL
  VHandLineFunc (VT_HANDLINE *p, BOOL flag, int *px1, int *pmy_y1,
                 int *px2, int *py2)
{
  int     x1, my_y1, x2, y2, delta;

  if (flag == FALSE) {
    x1 = *px1;
    my_y1 = *pmy_y1;
    x2 = *px2;
    y2 = *py2;

    p->delta_x = x2 - x1;
    p->delta_y = y2 - my_y1;
    p->x = x1;
    p->y = my_y1;

    if      (p->delta_x > 0)  p->incx = 1;
    else if (p->delta_x == 0) p->incx = 0;
    else                      p->incx = -1;

    if      (p->delta_y > 0)  p->incy = 1;
    else if (p->delta_y == 0) p->incy = 0;
    else                      p->incy = -1;

    p->delta_x = abs (p->delta_x);
    p->delta_y = abs (p->delta_y);
    if (p->delta_y > p->delta_x) {
      delta = p->delta_x;
      p->delta_x = p->delta_y;
      p->delta_y = delta;
      p->exchange = TRUE;
    } else
      p->exchange = FALSE;

    p->err = 2 * p->delta_y - p->delta_x;
    p->i = 1;
    return (TRUE);
  }

  if (p->i > p->delta_x)
    return (FALSE);
  *px1 = p->x;
  *pmy_y1 = p->y;
  while (p->err >= 0) {
    if (p->exchange)  p->x += p->incx;
    else              p->y += p->incy;
    p->err = p->err - 2 * p->delta_x;
  }

  if (p->exchange)  p->y += p->incy;
  else              p->x += p->incx;
  p->err += 2 * p->delta_y;
  p->i++;

  return (TRUE);
}
/*---------------------------------VHandLine-----------------------------------*/
/*                                                                             */
/*-----------------------------------------------------------------------------*/
void
VHandLine (YT_WIN *win, int x1, int my_y1, int x2, int y2, CHAR  ch)
{
  VT_HANDLINE line;
  int     x, y, dx, dy;
  //  YT_SPACE_NULL dz, z, koef;
  BOOL by_y;

  dx = x2 - x1;
  dy = y2 - my_y1;
  /*   dz = z2 - z1; */
  if (!dx && !dy)
    return;

  if (abs (dy) > abs (dx))  by_y = TRUE;
  else                      by_y = FALSE;

  VHandLineFunc (&line, FALSE, &x1, &my_y1, &x2, &y2);

  while (VHandLineFunc (&line, TRUE, &x, &y, NULL, NULL)) {
    //if (by_y)  koef = YABS ((double) (y - my_y1) / dy);
    //else       koef = YABS ((double) (x - x1) / dx);
    //z = z1 + dz * koef;
    VHandPixel (win, x, y, ch/* , z */);
  }

}
/*-----------------------------------win_init----------------------------------*/
/*                                                                             */
/*-----------------------------------------------------------------------------*/
void
win_init (YT_WIN *win, CHAR ch)
{
  int i, j;

  for (i=0; i<win->h; i++)
    for (j=0; j<win->w; j++)
      win->p[i][j] = ch;

  for (i=0; i<win->h; i++)
    win->p[i][win->w] = '\0';

  return;
}
/*----------------------------------win_create---------------------------------*/
/*                                                                             */
/*-----------------------------------------------------------------------------*/
YT_WIN*
win_create (int w, int h)
{
  YT_WIN *win;

  win = (YT_WIN*) malloc (sizeof(YT_WIN));
  win->w = w;
  win->h = h;

  win_init (win, ' ');

  return (win);
}
/*-----------------------------------win_char----------------------------------*/
/*                                                                             */
/*-----------------------------------------------------------------------------*/
void
win_char (YT_WIN *win, CHAR ch, int x, int y)
{

  if (x<0)       {printf("win_char: x<0 \n"); return;}
  if (x>=win->w) {printf ("win_char: x>=win->w \n"); return;}

  if (y<0)       {printf("win_char: y<0 \n"); return;}
  if (y>=win->h) {printf("win_char: y>=win->h \n"); return;}

  win->p[y][x] = ch;

  return;
}
/*----------------------------------win_text-----------------------------------*/
/*                                                                             */
/*-----------------------------------------------------------------------------*/
void
win_text (YT_WIN *win, const char *text, int x, int y)
{
  int  i;
  char ch;

  for (i=0; TRUE ;i++) {
    ch = text[i];
    if (ch == '\0')	break;
    win_char (win, ch, x+i, y);
  }


  return;
}
/*----------------------------------win_draw-----------------------------------*/
/*                                                                             */
/*-----------------------------------------------------------------------------*/
void
win_draw (YT_WIN *win, int x, int y)
{
  int i, j;
  char buff[100] = "";
  char left[100] = "";

  for (i=0; i<y; i++)
    puts ("");

  for (j=0; j<x; j++)
    left[j] = ' ';
  left[j] = '\0';

  for (i=0; i<win->h; i++) {
    strcpy (buff, left);
    strcat (buff, (char*)(&(win->p[i][0])));
    puts (buff);
  }


  return;
}
/*----------------------------------win_horz-----------------------------------*/
/*                                                                             */
/*-----------------------------------------------------------------------------*/
void
win_horz (YT_WIN *win, CHAR  ch, int y_horz, int x1, int x2)
{
  int x;

  for (x=x1; x<=x2; x++)
    win_char (win, ch, x, y_horz);

  return;
}
/*-----------------------------------win_ver-----------------------------------*/
/*                                                                             */
/*-----------------------------------------------------------------------------*/
void
win_vert (YT_WIN *win, CHAR ch, int x_vert, int my_y1, int y2)
{
  int y;

  for (y=my_y1; y<=y2; y++)
    win_char (win, ch, x_vert, y);

  return;
}
/*-----------------------------------win_line----------------------------------*/
/*                                                                             */
/*-----------------------------------------------------------------------------*/
void
win_line (YT_WIN *win, CHAR ch, int x1, int my_y1, int x2, int y2)
{

  VHandLine (win, x1, my_y1, x2, y2, ch);

  return;
}
/*-----------------------------------win_rect----------------------------------*/
/*                                                                             */
/*-----------------------------------------------------------------------------*/
void
win_rect (YT_WIN *win, CHAR ch_horz, CHAR  ch_vert, int x, int y, int w, int h)
{

  w--;
  h--;

  win_horz (win, ch_horz, y,   x, x+w);
  win_horz (win, ch_horz, y+h, x, x+w);

  win_vert (win, ch_vert, x,   y, y+h);
  win_vert (win, ch_vert, x+w, y, y+h);

  return;
}
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
/*----------------------------------print_tabl_one-----------------------------*/
/*                                                                             */
/*-----------------------------------------------------------------------------*/
void 
print_tabl_one (YT_WIN  *win, YT_PLOT *plot, int x, int y, 
                  double *f_calc, double *f_true, int i)
{
  char str[80];

  if (f_true) sprintf (str, "%7.2f % f % f", plot->x[i], f_calc[i], f_true[i]);
  else        sprintf (str, "%7.2f % f",     plot->x[i], f_calc[i]);

  win_text (win, str, x, y);

  return;
}
/*--------------------------------win_plot_tabl--------------------------------*/
/*                                                                             */
/*-----------------------------------------------------------------------------*/
void
win_plot_tabl (int fi, int ti, YT_WIN  *win, YT_PLOT *plot, int x, int y, int h)
{
  int     i, j, h_all, h_beg, h_end;
  char    str[80];
  double  *f_calc, *f_true;

  /* 	f_calc = plot->f_calc[fi] + ti*(plot->xnum); */
  /*   if (plot->f_true[fi]) f_true = plot->f_true[fi] + ti*(plot->xnum); */
  /* 	else                  f_true = NULL; */

  f_calc = plot->f[fi][0] + ti*(plot->xnum);
  if (plot->f[fi][1]) f_true = plot->f[fi][1] + ti*(plot->xnum);
  else                f_true = NULL;

  // печать таблицы значений графика
  h_all = h - 2;

  if (plot->xnum <= h_all) { // помещаются все значения

    for (i=0; i < plot->xnum; i++) 
      print_tabl_one (win, plot, x+2, y+i, f_calc, f_true, i);

  }else{
    h_end = h_all / 2 - 1; 
    h_beg = h_all - h_end - 1;

    for (i=0; i < h_beg; i++)  // верхняя часть таблицы
      print_tabl_one (win, plot, x+2, y+i, f_calc, f_true, i);
		

    win_text (win, "...............", x+2, y+i);

    y = y+i+1;
    for (i=0; i < h_end; i++) { // нижняя часть таблицы
      j = plot->xnum - h_end + i;
      print_tabl_one (win, plot, x+2, y+i, f_calc, f_true, j);
    }
  }

  return;
}
/*------------------------------win_plot_main----------------------------------*/
/*                                                                             */
/*-----------------------------------------------------------------------------*/
void
win_plot_main (int fi, int ti, YT_WIN *win, int ix_0, int iy_0, int iw, int ih, 
                 YT_PLOT *plot)
{
  int     ix_old, iy_old, iytrue_old, i, n, ix, iy, iytrue;
  double  x_step, y_step;
  double  *x,  *ycalc, *ytrue;
  double  xmin, ymin, xmax, ymax;


  n = plot->xnum;
  x = plot->x;

  /*   ycalc = plot->f_calc[fi] + ti*(plot->xnum); */
  /*   if (plot->f_true[fi]) ytrue = plot->f_true[fi] + ti*(plot->xnum); */
  /* 	else                  ytrue = NULL; */
  ycalc = plot->f[fi][0] + ti*(plot->xnum);
  if (plot->f[fi][1]) ytrue = plot->f[fi][1] + ti*(plot->xnum);
  else                ytrue = NULL;

  xmin = plot->xmin[fi];
  xmax = plot->xmax[fi];

  ymin = plot->ymin[fi];
  ymax = plot->ymax[fi];

  x_step = (xmax - xmin) / (iw - 1);
  y_step = (ymax - ymin) / (ih - 1);

  ix_old = 0;
  iy_old = 0;

  for (i=0; i < n; i++) {
    ix = YInt ((x[i] - xmin) / x_step);
    iy = YInt ((ycalc[i] - ymin) / y_step);

    win_char (win, '+', ix_0+ix, iy_0+ih-iy-1);

    if (ytrue) {
      iytrue = YInt ((ytrue[i] - ymin) / y_step);
      win_char (win, 'o', ix_0+ix, iy_0+ih-iytrue-1);
    }

    ix_old = ix;
    iy_old = iy;
    iytrue_old = iytrue;
  }

  return;
}
/*---------------------------------plot_win------------------------------------*/
/*                                                                             */
/*-----------------------------------------------------------------------------*/
void
plot_win (int ti, YT_PLOT *plot, int iw, int ih, int ih_one)
{
  int fi = 0;
  YT_WIN  *win;
  int yi;

  yi = 1;

  // создаем экранную форму и рисуем главную рамочку
  win = win_create (iw, ih);
  win_rect (win, '=', '|', 0, 0, iw, ih);

  for (fi=0; fi<plot->fnum; fi++) {
    plot_main (win, fi, ti, plot, 1, yi, iw-2, ih_one);
    yi += ih_one;
    win_horz (win, '=', yi, 2, iw-3);
    yi++;
  }

  // выводим экранную форму
  win_draw (win, 0, 0);

  //printf ("\n");
  return;
}
/*--------------------------------plot_main------------------------------------*/
/*                                                                             */
/*-----------------------------------------------------------------------------*/
void
plot_main (YT_WIN *win, int fi, int ti, YT_PLOT *plot, 
             int x_new, int y_new, int w_new, int h_new)
{

  int     w1, w2;
  double  xmin, ymin, xmax, ymax;
  char    str[80];

  // определяем размеры частей
  w2 = 21 + 10;
  w1 = w_new - w2+2;

  // рисуем перегородку
  win_vert (win, '|', w1, y_new, y_new+h_new);

  // рисуем левые графики
  win_plot_main (fi, ti, win, x_new,y_new, w1-1,h_new, plot);

  // рисуем правую таблицу

  //win_text (win, plot->f_name[fi], w1+2, y_new);
  win_text (win, plot->l_name[fi][0], w1+2, y_new);
  sprintf (str, "ymax =  % f", plot->ymax[fi]);
  win_text (win, str, w1+2, y_new+1);

  win_plot_tabl (fi, ti, win, plot,  w1,y_new+2, h_new-1);

  sprintf (str, "ymin =  % f", plot->ymin[fi]);
  win_text (win, str, w1+2, y_new+h_new-1);

  return;
}
/*--------------------------------plot_gnu---------------------------------*/
/*                                                                             */
/*-----------------------------------------------------------------------------*/
void
  plot_gnu(char *title, int ti, YT_PLOT *p, gnuplot_ctrl *gp)
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
      gnuplot_plot_xy (gp,  p->x, f_line, p->xnum, p->l_name[fi][li], 1);
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
  double /* *f_calc, *f_true, */ *f_line;

  x = 0.0;
  w = 1.0;
  h = 1.0 / p->fnum;

  for (fi=0 ; fi<p->fnum ; fi++) {
    //if (p->fnum != 1) 
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
		
    /* 		f_calc = p->f_calc[fi] + ti*(p->xnum); */
    /* 		if (p->f_true[fi]) f_true = p->f_true[fi] + ti*(p->xnum); */
    /* 		else               f_true = NULL; */
    /* 		gnuplot_plot_xy (gp, p->x, f_calc, p->xnum, p->f_name[fi]); */
    /* 		gnuplot_plot_xy (gp, p->x, f_true, p->xnum, "TRUE"); */
		
    //------------

    for (li=0; p->f[fi][li] != NULL; li++) {
      f_line = p->f[fi][li] + ti*(p->xnum);
      gnuplot_plot_xy (gp, p->x, f_line, p->xnum, p->l_name[fi][li], 1);
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

  if (is_win) {
    if (first2) first2 = FALSE;
    else for (i=0; i < ih; i++) CUU;
  }

  printf ("%s \n", title);
  if (is_win) {
    plot_win (ti, plot, iw, ih, ih_one);
  }
			
  if (is_gnu) {
    gnuplot_resetplot(gp); //??
    gnuplot_cmd (gp, "set multiplot"); // заодно и перерисовывает          
    //gnuplot_cmd (gp, "clear");        
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
/*******************************************************************************/
//                               M I N P R O C
/*******************************************************************************/
/*******************************************************************************/
/*----------------------------------minproc_set--------------------------------*/
/*                                                                             */
/*-----------------------------------------------------------------------------*/
void
  minproc_set (YT_MINPROC *minproc, double set_min, double set_max, double set_err)
{
  int i;

  for (i=0; i<DIM; i++) {
    XYZ_MIN[i] = set_min;
    XYZ_MAX[i] = set_max;
    XYZ_ERR[i] = set_err;
  }

  return;
}
/*------------------------------mm_initial_copy--------------------------------*/
/*                                                                             */
/*-----------------------------------------------------------------------------*/
void
mm_initial_copy (YT_MINPROC *to, YT_MINPROC *from)
{
  int d;

  to->name    = from->name;
  to->dim     = from->dim;
  to->proc    = from->proc;

  for (d=0; d<from->dim; d++) {
    to->xyz_min[d]  = from->xyz_min[d];
    to->xyz_max[d]  = from->xyz_max[d];
    to->xyz_err[d]  = from->xyz_err[d];
  }

  return;
}
/*-----------------------------mm_rezults_copy---------------------------------*/
/*                                                                             */
/*-----------------------------------------------------------------------------*/
void
mm_rezults_copy (YT_MINPROC *to, YT_MINPROC *from)
{
  int n, d;

  to->num_end = from->num_end;
  to->fun_end = from->fun_end;

  for (n=0; n < from->num_end; n++)
    for (d=0; d < from->dim; d++) {

      to->xyz_end[n][d]  = from->xyz_end[n][d];
    }

  return;
}
/*-----------------------------mm_all_copy-------------------------------------*/
/*                                                                             */
/*-----------------------------------------------------------------------------*/ 
void
mm_all_copy (YT_MINPROC *to, YT_MINPROC *from)
{

  mm_initial_copy (to, from);
  mm_rezults_copy (to, from);

  return;
}
/*--------------------------------IsXyzRavno-----------------------------------*/
/*                                                                             */
/*-----------------------------------------------------------------------------*/ 
BOOL
IsXyzRavno (int dim, double *xyz_one, double *xyz_two, double eps)
{
  int  i;

  for (i=0; i < dim; i++) {
    if (!(FRavno (xyz_one[i], xyz_two[i], eps))) {
      return (FALSE);
    }
  }

  return (TRUE);
}
/*----------------------------------FindXyzEnd---------------------------------*/
/*                                                                             */
/*-----------------------------------------------------------------------------*/
BOOL
FindXyzEnd (YT_MINPROC *minproc, double *xyz_cur, double eps)
{
  int  num;

  for (num=0; num < NUM_END; num++) {

    if (IsXyzRavno (DIM, &(XYZ_END[num][0]), xyz_cur, eps))
      return (TRUE);
  }

  return (FALSE);
}
/*----------------------------------calc_proc----------------------------------*/
/*                                                                             */
/*-----------------------------------------------------------------------------*/
double
calc_proc (YT_MINPROC *minproc, double *xyz_cur)
{

  //OUTD(1);
  return (PROC (YCALC, xyz_cur, NULL, 0,0, minproc));

}
/*--------------------------------minproc_setxyz-------------------------------*/
/*                                                                             */
/*-----------------------------------------------------------------------------*/
void
minproc_setxyz (YT_MINPROC *minproc, double *xyz, double *xyz_end)
{
  int i;

  for (i=0; i < DIM; i++)
    xyz_end[i] = xyz[i];

}
/*---------------------------------WriteNewXyz---------------------------------*/
/*                                                                             */
/*-----------------------------------------------------------------------------*/
void
WriteNewXyz (YT_MINPROC *minproc, double *xyz_cur)
{
  int  i;

  if (NUM_END >= MAXB) {
    //minproc_print (minproc, "minproc: \n");
    Error("WriteNewXyz: NUM_END >= MAXB");
  }

  for (i=0; i<DIM; i++) {
    XYZ_END[NUM_END][i] = xyz_cur[i];
  }

  NUM_END++;

  if (0) {
    printf ("F_NEW %s = %5.2f  x= ", LEFT, FUN_END);
    minproc_print_one (minproc, xyz_cur);
  }

}
/*--------------------------------CheckNewMinmax-------------------------------*/
/*                                                                             */
/*-----------------------------------------------------------------------------*/
void
CheckNewMinmax (YT_MINPROC *minproc, double *xyz_cur, double g)
{
  BOOL    find;
  // нужно соотнести с точностью поискового алгоритма !!!!
  double  eps = /* EPS  */0.0001;

  // три варианта для нового проверяемого значения :
  if (0) {
    printf ("%s f_cur = %f  x= ", LEFT, g);
    minproc_print_one (minproc, xyz_cur);
  }

  if      (g > FUN_END + eps)  return; // большее значение
  else if (g < FUN_END - eps) { // новый минимальный уровень
    FUN_END = g;
    NUM_END = 0;
    WriteNewXyz (minproc, xyz_cur);

  } else { // найдено еще одно значение этого уровня
    // проверить есть ли уже такой корень !!!!
    find = FindXyzEnd (minproc, xyz_cur, eps);

    if (!find) { // записать новое значение минимального уровня
      WriteNewXyz (minproc, xyz_cur);
    }
  }

  return;
}
/*-------------------------------print_fun_xyz---------------------------------*/
/*                                                                             */
/*-----------------------------------------------------------------------------*/
void
print_fun_xyz (int dim, const char *name, double fun, double *xyz)
{
  int i;

  if (name) printf ("%s %s ", LEFT, name);
  printf ("%s f= %6.2f  x= ", LEFT, fun);

  for (i=0; i < dim; i++)
    printf ("%6.2f ", xyz[i]);

  printf ("\n");

}
/*-------------------------------minproc_print_one-----------------------------*/
/*                                                                             */
/*-----------------------------------------------------------------------------*/
void
minproc_print_one (YT_MINPROC *minproc, double *xyz)
{
  int i;

  for (i=0; i<DIM; i++) {
    printf ("% f ", xyz[i]);
  }
  printf ("\n");

}
/*--------------------------------minproc_print--------------------------------*/
/*                                                                             */
/*-----------------------------------------------------------------------------*/
void
minproc_print (YT_MINPROC *minproc, const char *name)
{
  int   num;


  for (num = 0; num < NUM_END; num++) {
    if (name) printf ("%s %s ", LEFT, name);

    printf ("%s f= % f  x= ", LEFT, FUN_END);
    minproc_print_one (minproc, XYZ_END[num]);
  }

  return;
}
/*-------------------------------MultiFor_R------------------------------------*/
/*                                                                             */
/*-----------------------------------------------------------------------------*/
BOOL
MultiFor_R (int cur, int *ijk, int *IJK, int *smena)
{

  ijk[cur]++;

  if (ijk[cur] == IJK[cur]) {
    // smena teku]ego indeksa
    (*smena)++;
    if (cur == 0) return (FALSE);

    ijk[cur] = 0;
    if (!MultiFor_R (cur-1, ijk, IJK, smena)) return (FALSE);
  }

  return (TRUE);
}
/*---------------------------------MultiFor------------------------------------*/
/*                                                                             */
/*-----------------------------------------------------------------------------*/
BOOL
MultiFor (int dim, BOOL works, int *IJK, int *ijk_calc, int *p_smena)
{
  int smena_null, smena;

  static BOOL first;
  int   i/* , cur */;
  BOOL  konec;

  if (!works) {
    for (i=0; i<dim; i++)
      ijk_calc[i] = 0;

    first = TRUE;
    return (TRUE);
  }


  if (!p_smena) p_smena = &smena_null;
  smena = 0;

  if (first) first = FALSE;
  else {
    konec = !MultiFor_R (dim-1, &ijk_calc[0], IJK, &smena);
    if (konec) return FALSE;
  }

  *p_smena = smena;

  return (TRUE);
}
/*-----------------------------minproc_rand_init-------------------------------*/
/*                                                                             */
/*-----------------------------------------------------------------------------*/
void
  minproc_rand_init (YT_MINPROC *minproc, int num_multy)
{
  int n, i;

  YRAND_S;

  for (n = NUM_BEG; n < num_multy; n++) {

    for (i=0; i < DIM; i++)
      XYZ_BEG[n][i] = YRandF (XYZ_MIN[i], XYZ_MAX[i]);

    FUN_BEG[n] = calc_proc (minproc, XYZ_BEG[n]);
  }

  NUM_BEG = YMAX (NUM_BEG, num_multy);

  return;
}
/*-----------------------------minproc_gslspusk_s------------------------------*/
/*                                                                             */
/*-----------------------------------------------------------------------------*/
void
  minproc_gslspusk_s (YT_MINPROC *minproc, int algorifm, long long1, long long2)
{
  double g, xyz_cur[MAXA];
  int    n=0;
  BOOL   first;

  first = TRUE;
  NUM_END = 0; //!!!!!!!!!!

  for (n=0; n<NUM_BEG; n++) {

    g = minproc_gslspusk_1 (minproc, algorifm, long1, long2, XYZ_BEG[n], xyz_cur);
    if (first) {
      FUN_END = g;
      first = FALSE;
    }

    //fprintf (stderr, "%s g = %f  \n", LEFT, g);
    CheckNewMinmax (minproc, xyz_cur, g);
  }

  return;
}
/*******************************************************************************/
/*                                                                             */
/*-----------------------------------------------------------------------------*/
double
  my_f (const gsl_vector *v, void *params)
{
  double x, y;
  int    i;
  double xyz_cur[MAXA];
  YT_MINPROC *minproc = (YT_MINPROC *)params;
  

  for (i=0; i < DIM; i++) 
    xyz_cur[i] = gsl_vector_get (v, i);

  return (calc_proc (minproc, xyz_cur));
}
/*-----------------------------------------------------------------------------*/
//  double result, abserr;
//
//int
//gsl_diff_central (const gsl_function * f,
//		  double x, double *result, double *abserr)
//
//#define GSL_SQRT_DBL_EPSILON   1.4901161193847656e-08                           
//      h = 100.0 * GSL_SQRT_DBL_EPSILON;
//
double
  f1 (double x, void *params)
{
  return exp (x);
}
/*-----------------------------------------------------------------------------*/
/*                                                                             */
/*-----------------------------------------------------------------------------*/
double
  my_diff_central (const gsl_vector *v_null, int i, void *params)
{
  double f_plus, f_mins, df_dxyz;
  YT_MINPROC *minproc = (YT_MINPROC *)params;
  YT_GSLSPUSK *gslspusk = minproc->gslspusk;
  // !!!! 
  gsl_vector *v_plus = gsl_vector_alloc (DIM);
  gsl_vector *v_mins = gsl_vector_alloc (DIM);
  double diff_h = gslspusk->diff_h;


  // точка v_plus
  gsl_vector_memcpy (v_plus, v_null);
  gsl_vector_set (v_plus, i, gsl_vector_get(v_plus,i)+diff_h);
  f_plus = my_f (v_plus, params);
	
  // точка v_mins
  gsl_vector_memcpy (v_mins, v_null);
  gsl_vector_set (v_mins, i, gsl_vector_get(v_mins,i)-diff_h);
  f_mins = my_f (v_mins, params);
	
  df_dxyz = (f_plus - f_mins) / (2*diff_h);
	
  gsl_vector_free (v_plus);
  gsl_vector_free (v_mins);

  return (df_dxyz);
}
/*-----------------------------------------------------------------------------*/
/*  Вычисление градиента:  df = (df/dx, df/dy)                                 */
/*-----------------------------------------------------------------------------*/
void 
  my_df (const gsl_vector *v_null, void *params, gsl_vector *df)
{
  double df_dxyz;
  int    i;
  YT_MINPROC *minproc = (YT_MINPROC *)params;

  // формировать градиент, т.е. вектор производных
  for (i=0; i<DIM; i++) { // по каждой координате

    df_dxyz = my_diff_central (v_null, i, params);

    gsl_vector_set (df, i, df_dxyz);
  } 

  return;
}
/*-----------------------------------------------------------------------------*/
/*  Compute both f and df together                                             */
/*-----------------------------------------------------------------------------*/
void 
  my_fdf (const gsl_vector *x, void *params, double *f, gsl_vector *df) 
{

  *f = my_f (x, params); 
  my_df (x, params, df);

}
/*----------------------------minproc_gslspusk_set-----------------------------*/
/*                                                                             */
/*-----------------------------------------------------------------------------*/
YT_GSLSPUSK *
  minproc_gslspusk_set (BOOL diff2, double diff_h,
                        const gsl_multimin_fdfminimizer_type *min_type,
                        double step_size, double tol, 
                        double stop_grad,
                        int    stop_iter,
                        double stop_func)
{
  YT_GSLSPUSK *gslspusk;

  gslspusk = (YT_GSLSPUSK*) malloc(sizeof(YT_GSLSPUSK));

  gslspusk->diff2 = diff2;
  gslspusk->diff_h = diff_h;

  gslspusk->min_type = min_type;
  // gsl_multimin_fdfminimizer_conjugate_fr;     // Fletcher-Reeves
  // gsl_multimin_fdfminimizer_conjugate_pr;     // Polak-Ribiere
  // gsl_multimin_fdfminimizer_steepest_descent; // 

  // gsl_multimin_fdfminimizer_vector_bfgs;      // Broyden-Fletcher-Goldfarb-Shanno
  // очень хороший веторный квази-ньютоновский алгоритм (комбинация производных)

  gslspusk->step_size = step_size; // размер первого пробного шага
  gslspusk->tol	      = tol;       // точность линейной минимизации
  // критерий останова
  gslspusk->stop_grad	= stop_grad; // норма градиента
  gslspusk->stop_iter = stop_iter;
  gslspusk->stop_func = stop_func;

  return (gslspusk);
}
/*--------------------------------my_gsl_dnrm2---------------------------------*/
/*                                                                             */
/*-----------------------------------------------------------------------------*/
double
  my_gsl_dnrm2 (gsl_vector *x)
{
  double dnrm2, x_elem;
  int    i;

  //return (gsl_blas_dnrm2(x)); // портит сам вектор и все рядом ???

  for (dnrm2=0,i=0; i<x->size; i++) {
    x_elem = gsl_vector_get (x, i);
    dnrm2 += (x_elem*x_elem);
  }

  dnrm2 = sqrt (dnrm2);

  return (dnrm2);
}
/*-----------------------------------------------------------------------------*/
/*  Библиотечная функция (для примера)                                         */
/*-----------------------------------------------------------------------------*/
int                                                                             
  MY_gsl_multimin_test_gradient (const gsl_vector *g, double epsabs)                 
{                                                                               
  double norm;                                                                  
                                                                                
  if (epsabs < 0.0)                                                             
  {                                                                           
    GSL_ERROR ("absolute tolerance is negative", GSL_EBADTOL);                
  }                                                                           
                                                                                
  norm = gsl_blas_dnrm2(g);                                                     
                                                                                
  if (norm < epsabs)                                                            
  {                                                                           
    return GSL_SUCCESS;                                                       
  }                                                                           
                                                                                
  return GSL_CONTINUE;                                                          
}                                                                               
/*-----------------------------minproc_gslspusk_1------------------------------*/
/*  Градиентный спуск по программе GSL                                         */
/*-----------------------------------------------------------------------------*/
double
  minproc_gslspusk_1 (YT_MINPROC *minproc, int algorifm, long long1, long long2, 
                      double *xyz_beg, double *xyz_end)
{
  char *end_status;
  BOOL  test_print = FALSE /* TRUE */;
  int   i, iter, status;
  gsl_multimin_fdfminimizer *s;
  gsl_vector                *x;
  gsl_multimin_function_fdf  my_func;
  double minimum, g_norma=0, x_elem;
  // параметры спуска передаются извне 
  YT_GSLSPUSK *gslspusk = minproc->gslspusk;

  LEFT_BEG; 
  // задание самой минимизируемой функции
  my_func.f   = &my_f;
  my_func.df  = &my_df;
  my_func.fdf = &my_fdf;
  my_func.n   = DIM;
  my_func.params = minproc;
 
  // начальное приближения: точка инициализации спуска
  x = gsl_vector_alloc (DIM);
  for (i=0; i<DIM; i++) 
    gsl_vector_set (x, i, xyz_beg[i]);

  // создание и инициализация алгоритма
  s = gsl_multimin_fdfminimizer_alloc (gslspusk->min_type, DIM);
  gsl_multimin_fdfminimizer_set (s, &my_func, x, gslspusk->step_size, gslspusk->tol);
	
  iter = 0; // начинаем итерационный спуск -------------------------
  while (1) {
    if (test_print) { // тестовая печать текущего состояния
      fprintf (stderr, "%s iter= % 4d  f= %f  |g|= %f  |dx|= %f \n", 
               LEFT, iter, s->f, gsl_blas_dnrm2 (s->gradient), gsl_blas_dnrm2 (s->dx));
      //gsl_vector_fprintf (stderr, s->gradient, "%g");
    }

    // проверяем условие на количество итераций
    if (iter++ >= gslspusk->stop_iter) {
      end_status = "gsl_maxiter";
      break;
    }

    // выполнить одну итерацию
    status = gsl_multimin_fdfminimizer_iterate (s);
    if (status) { // неожиданные проблемы
      if (status == GSL_ENOPROG) end_status = "gsl_enoprog";
      else                       end_status = "gsl_problem";
      break;
    }
		
    // прверяем условие на норму градиента |g| < stop_grad 
    // т.е. близость к локальному минимуму 
    status = /* MY_ */gsl_multimin_test_gradient (s->gradient, gslspusk->stop_grad);
    if (status == GSL_SUCCESS) {
      end_status = "gsl_mingrad";
      break;
    }
   
    // проверяем условие на саму функцию f < stop_func
    if (s->f < gslspusk->stop_func) {
      end_status = "gsl_minfunc";
      break;
    }



  };
  // ---------------------------------------------------------------
  if (test_print) {
    fprintf (stderr, "%s iter= % 4d  f= %f  |g|= %f  |dx|= %f \n", 
             LEFT, iter, s->f, gsl_blas_dnrm2 (s->gradient), gsl_blas_dnrm2 (s->dx));
  }
  //fprintf (stderr, "%s%s  niters=%4d  \n", LEFT, end_status, iter);
	
  // записываем и возвращаем результаты
  gslspusk->end_status = end_status;
  gslspusk->end_niters = iter;
  for (i=0; i < DIM; i++)
    xyz_end[i] = gsl_vector_get (s->x, i);

  // уничтожить выделенные объекты
  gsl_multimin_fdfminimizer_free (s);
  gsl_vector_free (x);
	
  LEFT_END;
  return (s->f);
}
/*-------------------------------minproc_perebor-------------------------------*/
/*                                                                             */
/*-----------------------------------------------------------------------------*/
void
  minproc_perebor (YT_MINPROC *minproc, int num)
{
  int    i, ijk[MAXA], IJK[MAXA];
  double g, xyz_step[MAXA], xyz_cur[MAXA];
  BOOL   first;

  // дискретизация нужна здесь, при полном переборе!!!

  if (num == 0)
    for (i=0; i < DIM; i++) {
      xyz_step[i] = XYZ_ERR[i];
      IJK[i] = (int) ((XYZ_MAX[i] - XYZ_MIN[i]) / xyz_step[i] + 1);
    }
  else
    for (i=0; i < DIM; i++) {
      // другой способ: от количества точек, 
      // погрешность при этом не соответствует заданной
      IJK[i] = num;
      xyz_step[i] = (XYZ_MAX[i] - XYZ_MIN[i]) / (num - 1);
    }

  first = TRUE;

  MultiFor (DIM, FALSE, IJK, ijk, NULL);
  while (MultiFor (DIM, TRUE, IJK, ijk, NULL)) {

    for (i=0; i < DIM; i++) {
      xyz_cur[i] = XYZ_MIN[i] + ijk[i] * xyz_step[i];
    }

    g = calc_proc (minproc, xyz_cur);

    if (first) {
      FUN_END = g;
      first = FALSE;
    }

    CheckNewMinmax (minproc, xyz_cur, g);
  }

  return;
}
/*--------------------------------ga_selection---------------------------------*/
/*                                                                             */
/*-----------------------------------------------------------------------------*/
int
  ga_selection (YT_MINPROC *minproc)
{
  /*
    При турнирной селекции формируется случайное подмножество из элементов 
    популяции и среди них выбирается один элемент с наибольшим
    значением целевой функции.
    */
  int    n_best, n;
  double g_best, g;

  n_best = YRAND (0, NUM_BEG-1);
  g_best = FUN_BEG[n_best];

  for (n=0; n < NUM_BEG; n++) {
    if (YRAND (0,NUM_BEG-1) < NUM_BEG/2) continue;
    g = FUN_BEG[n];

    if (g < g_best) {
      n_best = n;
      g_best = g;
    }
  }

  return (n_best);
}
/*--------------------------------ga_crossover---------------------------------*/
/*                                                                             */
/*-----------------------------------------------------------------------------*/
void
  ga_crossover (YT_MINPROC *minproc, int mama, int papa, double *xyz_baby)
{
  /*
    По решениям i_1, i_2 он строит решение i' присваивая каждой координате этого 
    вектора с вероятностью 0,5 соответствующее значение одного из родителей. 
    Если вектора i_1, i_2 совпадали скажем по первой координате,
    то вектор i'  "унаследует" это значение.
    */
  int i;

  for (i=0; i < DIM; i++) {
    if (YRAND (0,100) < 50) xyz_baby[i] = XYZ_BEG[mama][i];
    else                    xyz_baby[i] = XYZ_BEG[papa][i];
  }


  return;
}
/*---------------------------------ga_mutation---------------------------------*/
/*                                                                             */
/*-----------------------------------------------------------------------------*/
void
  ga_mutation (YT_MINPROC *minproc, double *xyz_baby)
{
  /*
    Оператор мутации, применяемый к решению i' с заданной вероятностью  
    p_m |= (0, 1) меняет значение каждой координаты на противоположное.
    */


  minproc++;
  xyz_baby++;

  return;
}
/*---------------------------------ga_rotation---------------------------------*/
/*                                                                             */
/*-----------------------------------------------------------------------------*/
void
  ga_rotation (YT_MINPROC *minproc, double *xyz_baby)
{
  /*
    Затем решение добавляется в популяцию, а решение с наименьшим значением 
    целевой функции удаляется из популяции.
    */
  int    n, n_max, i;
  double g, g_max;

  n_max = 0;
  g_max = FUN_BEG[n_max];

  for (n=0; n < NUM_BEG; n++) {
    g = FUN_BEG[n];
    if (g > g_max) {
      n_max = n;
      g_max = g;
    }
  }

  for (i=0; i < DIM; i++)
    XYZ_BEG[n_max][i] = xyz_baby[i];

  return;
}
/*-----------------------------minproc_genalgo---------------------------------*/
/*                                                                             */
/*-----------------------------------------------------------------------------*/
void
  minproc_genalgo (YT_MINPROC *minproc)
{
  int i, mama, papa,/*  baby, */ n;
  double xyz_baby[MAXA];


  for (i = 0; i < 1000; i++) {
    // выбрать двух родителей из популяции (селекция)
    mama = ga_selection (minproc);
    papa = ga_selection (minproc);

    // сделать от родителей ребенка (скрещивание)
    ga_crossover (minproc, mama, papa, xyz_baby);

    // слегка модифицировать ребенка (мутация)
    ga_mutation (minproc, xyz_baby);

    // новый добавляется, а худший удаляется из популяции
    ga_rotation (minproc, xyz_baby);
  }


  FUN_END = FUN_BEG[0];
  for (n=0; n < NUM_BEG; n++)
    CheckNewMinmax (minproc, XYZ_BEG[n], FUN_BEG[n]);

  return;
}
/*------------------------------minproc_init-----------------------------------*/
/*                                                                             */
/*-----------------------------------------------------------------------------*/
YT_MINPROC*
  minproc_init (YT_PROC proc, long long1, long long2)
{
  YT_MINPROC *minproc;

  minproc = (YT_MINPROC *) malloc (sizeof(YT_MINPROC));

  PROC = proc;
  NUM_END = 0; //??!!
  NUM_BEG = 0;
  /* 	minproc->end_status = ""; */
  /* 	minproc->end_niters = 0; */

  minproc->gslspusk = minproc_gslspusk_set 
    (FALSE, 0.000001, 
     gsl_multimin_fdfminimizer_conjugate_fr,
     0.01, 1e-4, 
     0.001, 100, 0.001);

  proc (YINIT, NULL, NULL, long1, long2, minproc);

  return (minproc);
}
/*------------------------------minproc_free-----------------------------------*/
/*                                                                             */
/*-----------------------------------------------------------------------------*/
void
  minproc_free (YT_MINPROC *minproc)
{

  PROC (YFREE, NULL, NULL, 0, 0, minproc);
  free (minproc);

  return;
}
/*-------------------------------minproc_calc----------------------------------*/
/*                                                                             */
/*-----------------------------------------------------------------------------*/
void
  minproc_calc (YT_MINPROC *minproc, int power, int algorifm, long long1, long long2)
{
  int  i;

  switch (algorifm) {
  case Y_PEREBOR:
    minproc_perebor (minproc, power);
    break;
  case YGSLSPUSK:
    minproc_rand_init (minproc, power);
    minproc_gslspusk_s (minproc, algorifm, long1, long2);
    break;
  case Y_GENALGO:
    minproc_rand_init (minproc, power);
    minproc_genalgo (minproc);
    break;
  }

  return;
}
/*-------------------------------minproc_true----------------------------------*/
/*                                                                             */
/*-----------------------------------------------------------------------------*/
void
  minproc_true (YT_MINPROC *minproc)
{

  PROC (YTRUE, NULL, NULL, 0,0, minproc);

  return;
}
/*----------------------------minproc_init_true--------------------------------*/
/*                                                                             */
/*-----------------------------------------------------------------------------*/
YT_MINPROC*
  minproc_init_true (YT_PROC proc)
{

  YT_MINPROC *minproc;

  minproc = minproc_init (proc, 0, 0);

  minproc_true (minproc);

  return (minproc);
}
/*------------------------------mm_rezults_comp--------------------------------*/
/*                                                                             */
/*-----------------------------------------------------------------------------*/
BOOL
  mm_rezults_comp (YT_MINPROC *m_calc, YT_MINPROC *m_true)
{
  int    n;
  BOOL   find;
  double eps;

  if (m_calc->num_end != m_true->num_end) return (FALSE);
  eps = m_true->xyz_err[0]; //!!??

  for (n=0; n < m_calc->num_end; n++) {

    find = FindXyzEnd (m_true, &(m_calc->xyz_end[n][0]), eps);
    if (!find) return (FALSE);
  }

  return (TRUE);
}
/*----------------------------------YSecOfDay----------------------------------*/
/*                                                                             */
/*-----------------------------------------------------------------------------*/
double
  YSecOfDay ()
{
  struct timeb tb;

  ftime (&tb);
  return (tb.time + tb.millitm / 1000.0);

}
/*---------------------------------timer_beg-----------------------------------*/
/*                                                                             */
/*-----------------------------------------------------------------------------*/
YT_TIMER*
  timer_beg ()
{
  YT_TIMER *t = (YT_TIMER*) malloc (sizeof(YT_TIMER));

  t->tim_beg = time (NULL);

  return (t);
}
/*---------------------------------timer_hms-----------------------------------*/
/*                                                                             */
/*-----------------------------------------------------------------------------*/
void
  timer_hms (YT_TIMER *t, time_t *tim_hor, time_t *tim_min, time_t *tim_sec)
{
  time_t    tim_end, tim_all;

  tim_end = time (NULL);
  tim_all = tim_end - t->tim_beg;
  *tim_hor = tim_all / 3600;
  tim_all = tim_all % 3600;
  *tim_min = tim_all / 60;
  *tim_sec = tim_all % 60;

  return;
}
/*---------------------------------timer_end-----------------------------------*/
/*                                                                             */
/*-----------------------------------------------------------------------------*/
void
  timer_end (YT_TIMER *t, char *hms_time)
{
  time_t /* tim_end, tim_all,  */tim_min, tim_sec, tim_hor;

  timer_hms (t, &tim_hor, &tim_min, &tim_sec);

  sprintf (hms_time, "%d:%02d:%02d", tim_hor, tim_min, tim_sec);

  free (t);
  return;
}
/*---------------------------------timer_hor-----------------------------------*/
/*                                                                             */
/*-----------------------------------------------------------------------------*/
BOOL
  timer_hor (YT_TIMER *t)
{
  time_t  tim_min, tim_sec, tim_hor;
  static int save_count = 0;

  timer_hms (t, &tim_hor, &tim_min, &tim_sec);
  if (tim_hor > save_count) {		
    save_count++;
    return (TRUE);
  }

  return (FALSE);
}
/*-------------------------------test_algorifm---------------------------------*/
/*                                                                             */
/*-----------------------------------------------------------------------------*/
void
  test_algorifm (const char *name, YT_MINPROC *calc_rezults, YT_MINPROC *true_rezults,
                 int power, int algorifm, long long1, long long2)
{
  BOOL  print_error = TRUE;
  double time_sec = 0.0;
  LEFT_BEG;

  time_sec = YSecOfDay ();
  minproc_calc (calc_rezults, power, algorifm, long1, long2);
  time_sec = YSecOfDay () - time_sec;

  if (mm_rezults_comp (calc_rezults, true_rezults))
    printf ("%s O-KEY! .... %s long1=%2ld long2=%2ld   Time= %7.3f \n", 
            LEFT, name, long1, long2, time_sec);
  else {
    printf ("%s ERROR! .... %s long1=%2ld long2=%2ld   Time= %7.3f \n", 
            LEFT, name, long1, long2, time_sec);
    if (print_error) {
      minproc_print (calc_rezults, "calc: ");
      minproc_print (true_rezults, "true: ");
    }
  }

  LEFT_END;
  return;
}
/*-----------------------------minproc_tests-----------------------------------*/
/*  Простые тесты на минимизацию скалярных функций                             */
/*-----------------------------------------------------------------------------*/
void
  minproc_tests (YT_MINPROC *calc_rez, int p_power, int s_power)
{
  YT_MINPROC *true_rez;

  if (s_power == POWER_DEF) s_power = 10;

  true_rez = minproc_init (calc_rez->proc, 0, 0);
  mm_initial_copy (true_rez, calc_rez);

  minproc_true (true_rez);
  printf ("[%-13s]  DIM=%d  P_POWER=%d S_POWER=%d \n", true_rez->name, 
          true_rez->dim, p_power, s_power);

  //if (0) test_algorifm ("GenAlgos", calc_rez, true_rez, power, Y_GENALGO, 0, 0);
  if (true_rez->dim<=4)
    if (1) test_algorifm ("Perebors", calc_rez, true_rez, p_power, Y_PEREBOR, 0, 0);
  if (1) test_algorifm ("GSLspusk", calc_rez, true_rez, s_power, YGSLSPUSK, 0, 0);

  return;
}
/*******************************************************************************/

