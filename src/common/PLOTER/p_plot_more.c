// -*-  mode: c    ; coding: koi8   -*- ----------------------------------------

//------------------------------------------------------------------------------
// 
//------------------------------------------------------------------------------

#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include "glib.h"

//------------------------
//#include "glib/gstdio.h"

#include <unistd.h>

#define g_chdir chdir
//------------------------

//#include "burger.h"
#include "p_comm.h"
#include "p_gnup.h"

#include "p_plot.h"
#include "p_plot_more.h"

//------------------------------------------------------------------------------
int
calc_tnum (char *main_dir, char *dir_name)
{
  GDir*  dir;

  char buffer[200];

  strcpy (buffer, main_dir);
  strcat (buffer, "/");
  strcat (buffer, dir_name);

  //dir = g_dir_open (dir_name, 0, NULL);
  dir = g_dir_open (buffer, 0, NULL);

  if (dir == NULL) 
    g_error ("dir == NULL");

  const  gchar*  fname;
  int    num = 0;
  while ((fname = g_dir_read_name (dir)) != NULL) {

    //if (!g_file_test (fname, G_FILE_TEST_IS_REGULAR))
    //  continue;
    //printf ("fname= %s \n", fname);
    num ++;
  }

  return (num);
}
//------------------------------------------------------------------------------
char *
get_value_name (char *dir_name)
{
  char *name;
  char  buf[80];

  //fprintf (stderr, "get_value_name:  dir_name = %s \n", dir_name);

  strcpy (buf, dir_name);

  name = strtok (buf, "_");

  return (name);
}
//------------------------------------------------------------------------------
char *
set_full_file_name (char *dir_name, int num)
{
  char *value_name;
  char num_name[180];

  static char buffer[180];

  //fprintf (stderr, "set_full_file_name:  dir_name = %s \n", dir_name);

  // выделим из названия директории само имя переменной
  //
  value_name = get_value_name (dir_name);

  //fprintf (stderr, "value_name = %s \n", value_name);

  // теперь формируем буфер полного имени файла данных:

  strcpy (buffer, dir_name);
  strcat (buffer, "/");  

  strcat (buffer, value_name); // имя переменной
  strcat (buffer, "_");

  sprintf (num_name, "%d", num);
  strcat (buffer, num_name);

  return (buffer);
}
//------------------------------------------------------------------------------
int
calc_xnum (char *main_dir, char *dir_name)
{
  char *file_name;
  char buffer[200];

  //fprintf (stderr, "calc_xnum:  dir_name = %s \n", dir_name);

  //fprintf (stderr, "check_dir_files: ... 51 \n");

  file_name = set_full_file_name (dir_name, 0);

  //fprintf (stderr, "calc_xnum:  file_name = %s \n", file_name);

  //fprintf (stderr, "check_dir_files: ... 52 \n");

  // 
  strcpy (buffer, main_dir);
  strcat (buffer, "/");
  strcat (buffer, file_name);

  fprintf (stderr, "calc_xnum:  buffer = %s \n", buffer);

  //FILE  *file = fopen (file_name, "r");
  FILE  *file = fopen (buffer, "r");


  if (file == NULL) g_error ("calc_xnum: file == NULL");

  // просканируем файл данных и просто посчитаем сколько точек
  //char  buffer[80];
  strcpy (buffer, "");

  int   num = 0;
  while (fscanf (file, "%s ", buffer) != EOF) {
    num++;
  }

  return (num);
}
//------------------------------------------------------------------------------
double *
read_values_u (char *main_dir, char *dir_name, int xnum, int n_value)
{
  double *ptr;
  char *file_name = set_full_file_name (dir_name, n_value);

  ptr = malloc (xnum * sizeof (double));


  char    full_name[200];
  // 
  strcpy (full_name, main_dir);
  strcat (full_name, "/");
  strcat (full_name, file_name);
  // 

  //FILE  *file = fopen (file_name, "r");
  FILE  *file = fopen (full_name, "r");

  if (file == NULL) g_error ("read_values_u: file == NULL");

  char  buffer[80];
  float value;
  int   n = 0;
  while (fscanf (file, "%s ", buffer) != EOF) {

    value = atof (buffer);
    ptr[n] = value;

    n++;
  }

  return (ptr);
}
//------------------------------------------------------------------------------
double *
read_values_t (char *main_dir, char *dir_name, int tnum)
{
  double *ptr;
  int     n = 0;

  const   gchar*  fname;
  char    full_name[200];

  GDir*   dir;
  FILE   *file;
  char    buffer[180];
  float   value;

  ptr = malloc (tnum * sizeof (double));


  char    full_dir[200];
  // 
  strcpy (full_dir, main_dir);
  strcat (full_dir, "/");
  strcat (full_dir, dir_name);
  // 
  //dir = g_dir_open (dir_name, 0, NULL);
  dir  = g_dir_open (full_dir, 0, NULL);

  if (dir == NULL)  g_error ("dir == NULL");


  //fprintf (stderr, "read_values_t ... 111  \n");


  while ((fname = g_dir_read_name (dir)) != NULL) {

    strcpy (full_name, full_dir);
    //strcpy (full_name, dir_name);
    //strcat (full_name, dir_name);
    strcat (full_name, "/");
    strcat (full_name, fname);

    file = fopen (full_name, "r");

    if (file == NULL) {

      //fprintf (stderr, "full_name = %s \n", full_name);

      g_error ("read_values_t: file == NULL");
    }

    fgets (buffer, 80, file); 
    sscanf (buffer, "%f", &value);

    ptr[n] = value;

    fclose (file);
    n ++;
  }


  return (ptr);
}
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
void
check_dir_files (char *main_dir, int *p_fnum, char flist[FNUM_MAX][20])
{
  int fnum = 0;
  //static char flist[FNUM_MAX][20];
  char buffer[200];

  GDir*  dir = g_dir_open (main_dir, 0, NULL);

  if (dir == NULL) 
    g_error ("check_dir_files:  dir == NULL");

  //fprintf (stderr, "check_dir_files: ... 1 \n");

  // открыли директорию !!!


  const gchar*  name;

  //printf ("\n");
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  while ((name = g_dir_read_name (dir)) != NULL) {

    //fprintf (stderr, "check_dir_files: name= %s \n", name);

    strcpy (buffer, main_dir);
    strcat (buffer, "/");
    strcat (buffer, name);

    //if (! g_file_test (name, G_FILE_TEST_IS_DIR)) {
    if (! g_file_test (buffer, G_FILE_TEST_IS_DIR)) {

      // тетстирует в текущей папке !! а мне нужно в  "main_dir" !!
      continue; // eсли это нe дирeктория, то пропускаeм
    }

    if (! strcmp (name, "t_files")) 
      continue;

    printf ("name= %s \n", name);

    strcpy (flist[fnum] , name);

    fnum++;
  }

  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


  //fprintf (stderr, "check_dir_files: ... 2 \n");

  //printf ("fnum = %d \n", fnum);
  *p_fnum = fnum;

  //fprintf (stderr, "check_dir_files: ... 3 \n");

  //return (&flist[0]);
}
//------------------------------------------------------------------------------
void
tadmor_get_arrays (TADMOR *tad, char *main_dir)
{

  //if (g_chdir (main_dir) == -1)
  //if (g_chdir (".") == -1)
  //  g_error ("main_dir");

  //----------------------------------------------------
  int   fnum;
  static char f_list[FNUM_MAX][20];

  check_dir_files (main_dir,   &fnum, f_list);

  //char *flist[] = {"u_files"};

  //char *flist[] = {"rho_files", "p_files", "u1_files"};
  //char *flist[] = ;

  //----------------------------------------------------

  //fprintf (stderr, "check_dir_files: ... 4 \n");

  int tnum = calc_tnum (main_dir, "t_files");
  //int tnum = calc_tnum ("D/t_files");

  //fprintf (stderr, "check_dir_files: ... 5 \n");

  int xnum = calc_xnum (main_dir, f_list[0]); // u_files 

  //fprintf (stderr, "check_dir_files: ... 6 \n");

  int ti;
  int fi = 0;

  if (tnum > TNUM_MAX)  g_error ("tnum > TNUM_MAX");
  //
  // почeму здeсь заполняeтся мeньшний массив бeз ошибки ?

  tad->t = read_values_t (main_dir, "t_files", tnum);

  //fprintf (stderr, "check_dir_files: ... 7 \n");

  for (fi = 0; fi < fnum; fi++) {
    tad->names[fi] = f_list[fi];

    for (ti = 0; ti < tnum; ti++) {
      tad->u[fi][ti] = read_values_u (main_dir, f_list[fi], xnum, ti);
    }
  }

  //fprintf (stderr, "check_dir_files: ... 8 \n");

  //g_chdir (".."); // это что?

  tad->xnum = xnum; 
  tad->tnum = tnum; 
  tad->fnum = fnum; 

/*   printf ("\n"); */
/*   printf ("tnum = %d \n", tad->tnum); */
/*   printf ("xnum = %d \n", tad->xnum); */
/*   printf ("fnum = %d \n", tad->fnum); */
/*   printf ("\n"); */

  return;
}
//------------------------------------------------------------------------------
/* void */
/* tadmor_print (TADMOR *tad) */
/* { */

/*   printf ("tnum = %d \n", tad->tnum); */
/*   printf ("xnum = %d \n", tad->xnum); */
/*   printf ("\n"); */

/*   int ti, xi; */
/*   for (ti=0; ti< tad->tnum; ti++) { */
/*     printf ("%2d) ", ti); */

/*     for (xi=0; xi< 5; xi++) { */
/*       printf ("%f ", (tad->u[ti])[xi]); */
/*     } */
/*     printf ("\n"); */
/*   } */

/*   printf ("\n"); */
/*   return; */
/* } */
//------------------------------------------------------------------------------
/* void */
/* reader_test (char *main_dir) */
/* { */
/*   TADMOR tadmor, *tad = &tadmor; */

/*   tadmor_get_arrays (tad, main_dir); */

/*   tadmor_print (tad); */

/*   printf ("\n"); */
/*   return; */
/* } */
//------------------------------------------------------------------------------
// 
//
/*----------------------------------------------------------------------------*/
YT_PLOT *
tadmor_make_plot (TADMOR *tad)
{ 

  int xnum = tad->xnum; 
  int fnum = tad->fnum;
  int tnum = tad->tnum;

  // от куда брать эти парамeтры?
  double x_min  = 0; 
  double x_max  = 2*G_PI;
  double x_step = (x_max - x_min) / (xnum - 1);

  YT_PLOT *plot;
  int     i;

  plot = plot_create (fnum, xnum, tnum);

  // формируем "x"
  for (i=0 ; i < xnum ; i++) {
    plot->x[i] = x_min + x_step * i;
  }

  int ti, fi;

  for (fi=0; fi < fnum; fi++) 
  for (ti=0; ti < tnum; ti++) {

    // теперь сами графики:
    P_LINE (plot, fi, ti) = (tad->u[fi][ti]);
    P_NAME (plot, fi) = tad->names[fi];

    // общий титл ..
    sprintf (P_TITLE (plot,ti), "ti = %d", ti);
  }

  return (plot);  
}
/*----------------------------------------------------------------------------*/
void
plot_add_plot (YT_PLOT *plot, YT_PLOT *plot2)
{ 

  plot->fnum = plot->fnum + 1;

  int ti;
  for (ti=0 ; ti < plot->tnum ; ti++) {

    P_LINE (plot, /*fi*/1, ti) = P_LINE (plot2, /*fi*/0, ti);
    P_NAME (plot, /*fi*/1)     = P_NAME (plot2, /*fi*/0);

  }

  // в 1-м фрейме:
  //plot->fr[0][0] = 0/*fi*/;
  plot->fr[0][1] = 1/*fi*/; 

  return;  
}
//------------------------------------------------------------------------------
/******************************************************************************/
//
/*----------------------------------------------------------------------------*/
void
plot_frame_lines (YT_PLOT *p, int ti, int wi, gnuplot_ctrl *gp,
                  int is_color)
{
  int     fi, li;
  double *f_line;

  for (li=0; (fi = p->fr[wi][li]) != -1; li++) {		
    f_line = P_LINE (p, fi, ti);
    gnuplot_plot_xy (gp, p->x, f_line, p->xnum, P_NAME (p, fi), is_color);
  }

  return;
}
/*----------------------------------------------------------------------------*/
void
plot_gnu_new (char *title, int ti, YT_PLOT *p, void *void_gp,
              YT_BOOL is_first, int is_color)
{
  gnuplot_ctrl *gp = (gnuplot_ctrl *) void_gp;

  double  xmin, xmax, ymin, ymax;
  double  x, y, w, h;
  int     wi;

  // Resets a gnuplot session, i.e. the next plot will erase all previous
  gnuplot_resetplot (gp);  

  if (p->wnum != 1) // рисовать в одном фрейме, если это возможно
    gnuplot_cmd (gp, "set multiplot");

  ////if (is_first) {
  ////  gnuplot_cmd (gp, "set multiplot"); // заодно и перерисовывает 
  ////}
  double h_title = 0.1, h_frame;
  x = 0.0;
  w = 1.0;
  //h = 1.0 / p->wnum;
  h = (1.0 - h_title) / p->wnum;
  y = 1.0;

  // зачем мы все здесь перерисовываем ???????????????????
  for (wi=0; p->fr[wi][0] != -1; wi++) {

    ////if (is_first) {
    if (wi == 0) { // рисуем первый (верхний) график
      //if (p->wnum > 1) 
      //  gnuplot_cmd (gp, "set noxtics"); // если он (график) не один, то обрезаем низ
      gnuplot_cmd (gp, "set title '%s'", title); // но зато рисуем  полный заголовок
      y -= h_title;
      h_frame =  h + h_title;

    } else {
      //gnuplot_cmd (gp, "set xtics"); // для всех остальных обязательны метки внизу ???
      gnuplot_cmd (gp, "set title"); // но без заголовка (пустой)
      h_frame =  h;
    }
    ////}

    gnuplot_cmd (gp, "set noxtics");

    //y = 1.0 - (wi+1) * h;
    y -= h;

    //if (is_first) {   
    gnuplot_cmd (gp, "set size %.2f, %.2f", w, h_frame);       
    //}
    //printf ("origin: x=%f y=%f  w=%f h=%f \n", x, y, w, h);
    gnuplot_cmd (gp, "set origin %.2f, %.2f", x, y);

    // посчитаем габариты фрейма
    plot_get_minmax_frame (p, wi,
                           &xmin, &xmax, &ymin, &ymax);

/*     if (ERR_PRINT) { */
/*       printf ("wi= %d  xmin= %f  xmax= %f  ymin= %f  ymax= %f \n",  */
/*               wi, xmin, xmax, ymin, ymax); */
/*     } */

    //if (is_first) {   
    // установим найденные общие габариты
    gnuplot_cmd (gp, "set xrange [%f : %f]", xmin, xmax);          
    gnuplot_cmd (gp, "set yrange [%f : %f]", ymin, ymax);          
    //}

    //if (!is_first) {   
    // а теперь уже нарисуем сами графики
    plot_frame_lines (p, ti, wi, gp, is_color);
    //}

    gp->nplots = 0; //??
  }

  return;
}
/*----------------------------------------------------------------------------*/
void *
gnu_bigplot_init (void *plot)
{
  gnuplot_ctrl *gp;
  gp = gnuplot_init ();

  gnuplot_setstyle (gp, "lines"  /* "linespoints" */);
  gnuplot_cmd (gp, "set format y '%%8g'");           

  //plot_gnu_new (/* title */"GENA", /* ti */0, plot, gp, TRUE, 0); 

  return ((void*) gp);
}
/*----------------------------------------------------------------------------*/
void
gnu_bigplot_draw (void *gp, void *plot, char *title, int ti)
{

  //static int ti_old = -1;

  //plot_gnu_new (title, ti, plot, /* g */p, TRUE); 

/*   if (ti_old >= 0) { */
/*   printf ("ti_old= %d \n", ti_old); */
/*   plot_gnu_new (title, ti_old, plot, gp, FALSE, 0);  */
/*   } */

  // очень медленно перерисовывается по одному графику !!!
  // получается хуже, чем через "set multiplot"

  // !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  // сделаем пока по старому - рисуем в один этап (вместе с осями)
  
  plot_gnu_new (title, ti,     plot, gp, FALSE, 1); 

  //ti_old = ti;

  return;
}
/*----------------------------------------------------------------------------*/
void
gnu_bigplot_close (void *p)
{
  gnuplot_ctrl *gp = (gnuplot_ctrl *) p;

  gnuplot_close (gp);

  return;
}
/******************************************************************************/
// 
/*----------------------------------------------------------------------------*/
T_PLOTSTEP *
plotbig_step_beg (YT_PLOT *plot, int X, int Y, int W, int H)
{
  T_PLOTSTEP *ps;

  gnuplot_init_prepare (W, H, X, Y);

  //ps = plotstep_create (FALSE, TRUE, plot);
  ps = plotstep_create (/* 0, 0, */ plot);

  //winplot_init (ps, is_win, is_big);

  ps->gp = gnu_bigplot_init (plot);

  return (ps);
}
/*----------------------------------------------------------------------------*/
void
plotbig_step_end (T_PLOTSTEP *ps)
{

  //ps->plot->bigplot_close (ps->gp);
  gnu_bigplot_close (ps->gp);

  return;
}
/*----------------------------------------------------------------------------*/
void
plotbig_step_do (T_PLOTSTEP *ps, int ti)
{
  char *title = P_TITLE (ps->plot, ti);

  //ps->plot->bigplot_draw (ps->gp, ps->plot, title, ti);
  gnu_bigplot_draw (ps->gp, ps->plot, title, ti);

  return;
}
/******************************************************************************/
// 
/*----------------------------------------------------------------------------*/
