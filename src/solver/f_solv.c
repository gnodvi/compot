// -*-  mode: c    ; coding: koi8   -*- ----------------------------------------

/*******************************************************************************/
/*  S O L V E R                                                                */
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

/*******************************************************************************/

#include "f-kern.h"


/*******************************************************************************/
/*                            M I N F U N C                                    */
/*-----------------------------------------------------------------------------*/


/*******************************************************************************/

typedef double (*YT_FUNC) (int message, long long1, long long2, long long3, long long4);

typedef struct {
  YT_FUNC  func;      // указатель на функцию для YCALC и YTRUE
  char     name[80];  // имя функции-проекта 
  //int      full_mode; // тип уравнений газодинамики SIMP or FULL

  int      xnum;      // параметры по x-оси
  double   xmin, xmax, xstep;
  int      tnul, tnum;// параметры по t-оси
  double   tmin, tmax, tstep;

  int      fnum;      // количество неизвестных функций системы
  char     fimq[20][80]; // 
  double   fmin[20];  // ожидаемые границы решения
  double   fmax[20];  // ожидаемые границы решения
  double   ferr[20];  // допускаемая погрешность решения (на каждую функцию???)
  double  *rval[20];  // точное решение

  double  *fval[20];  // текущие значения функций
  int     *mval[20];  // признак неизменяемости значений

  BOOL     xleft_flag[20], xright_flag[20];
  double   xleft_dval[20], xright_dval[20];

  // нужно сделать массив, но как? по шагам ?
  double  *rezi;      // невязка (текущая и конечная)
  YT_GSLSPUSK *gslspusk;

  //  рабочая область для расчетов:
  YT_TIMER *solv_timer;
  double   *r1[20], *r2;
  int       x_calc_beg, x_calc_end, t_calc_beg, t_calc_end; 
  int       x_work_beg, x_work_end, t_work_beg, t_work_end; 
  int       x_diff_beg, x_diff_end, t_diff_beg, t_diff_end; 
} YT_MINFUNC;

#define X_CALC_BEG (minfunc->x_calc_beg)
#define X_CALC_END (minfunc->x_calc_end)
#define T_CALC_BEG (minfunc->t_calc_beg) 
#define T_CALC_END (minfunc->t_calc_end)

#define X_WORK_BEG (minfunc->x_work_beg) 
#define X_WORK_END (minfunc->x_work_end)
#define T_WORK_BEG (minfunc->t_work_beg)
#define T_WORK_END (minfunc->t_work_end)

#define X_DIFF_BEG (minfunc->x_diff_beg) 
#define X_DIFF_END (minfunc->x_diff_end)
#define T_DIFF_BEG (minfunc->t_diff_beg) 
#define T_DIFF_END (minfunc->t_diff_end)

#define XNUM  (minfunc->xnum)
#define XMIN  (minfunc->xmin)
#define XMAX  (minfunc->xmax)
#define XSTEP (minfunc->xstep)

#define TNUL  (minfunc->tnul)
#define TNUM  (minfunc->tnum)

#define TMIN  (minfunc->tmin)
#define TMAX  (minfunc->tmax)
#define TSTEP (minfunc->tstep)

#define XVAL(xi) (minfunc->xmin + minfunc->xstep * (xi))
#define TVAL(ti) (minfunc->tmin + minfunc->tstep * (ti))

#define FNUM     (minfunc->fnum)
#define FMIN(fi) (minfunc->fmin[(fi)])
#define FMAX(fi) (minfunc->fmax[(fi)])
#define FERR(fi) (minfunc->ferr[(fi)])

// массивы записываются послойно по времени 
#define FVAL(fi,xi,ti) ((minfunc->fval[(fi)])[(ti)*XNUM+(xi)])
#define FMOD(fi,xi,ti) ((minfunc->mval[(fi)])[(ti)*XNUM+(xi)])
#define RVAL(fi,xi,ti) ((minfunc->rval[(fi)])[(ti)*XNUM+(xi)])
#define REZI(ti)        (minfunc->rezi[(ti)])
  

typedef  double (*YT_SUBFUNC) (YT_MINFUNC*, int, long,long,long);
typedef  double (*YT_FUNC_NEW) (YT_MINFUNC *minfunc, int,int,int, long,long,long);

YT_MINFUNC* minfunc_create (int fnum, YT_FUNC, const char*, 
                            double xmin, double xmax, int xnum, double tmin, double tmax, int tnum);
void minfunc_fmin_fmax_ferr (int n, YT_MINFUNC *minfunc, double fmin, double fmax, double ferr);
void minfunc_put (int n, YT_MINFUNC *t, int xi, int ti, double val, int mod);
void minfunc_put_all (int n, char *name, YT_MINFUNC *minfunc, double all_val);
void minfunc_xleft (int n, YT_MINFUNC *minfunc, double one_val);

//void minfunc_solver (YT_MINFUNC *minfunc, int x_sxema, int t_sxema);
void minfunc_print (YT_BOOL, YT_BOOL, YT_MINFUNC *t);

void minfunc_solver_beg_end (YT_PROC proc, int p_power, int s_power, YT_MINFUNC *minfunc);
BOOL minfunc_to_minproc (YT_MINFUNC *minfunc, YT_MINPROC *minproc);
void minproc_to_minfunc (YT_MINPROC *minproc, YT_MINFUNC *minfunc, double *xyz_cur);

#define FUNC_VARS  int fi, xi, ti; /* double x, f; */ static YT_MINFUNC *minfunc
#define FUNC_GETS  {xi = long1; minfunc = (YT_MINFUNC*) long2; fi = long3; ti = long4;}
#define X (XVAL (xi))
#define T (TVAL (ti))
#define Fn(fi) ((minfunc->fval[(fi)])[(ti)*(minfunc->xnum)+(xi)])
#define G_INT(fi) (minfunc_gint(minfunc,(fi),(xi),(ti)))

#define F (Fn(0))
#define G (Fn(1))

/*******************************************************************************/
/*                                                                             */
/*-----------------------------------------------------------------------------*/
#define LAST_SOL "sol-LAST.sol"
#define KILL_PID "sol-LAST.pid"

void   test_siman (void);
/* double proc01 (PROC_VAR); */
/* double proc05 (PROC_VAR); */
double gazodin_func (int message, long long1, long long2, long long3, long long4);
void   minfunc_put_xleft (int fi, YT_MINFUNC *minfunc, double val);
void   minfunc_put_xright (int fi, YT_MINFUNC *minfunc, double val);

/*******************************************************************************/
//                               M I N F U N C
/*******************************************************************************/
/*  Библиотека MINFUNC - метод минимизации функционала                         */
/*                                                                             */
/*******************************************************************************/
 

/*------------------------------minfunc_print----------------------------------*/
void
minfunc_print (BOOL is_win, BOOL is_gnu, YT_MINFUNC *minfunc)
{
  int  ti, ch, ti_incr = +1;
  char buff[80];
  //char title[80];
  static YT_PLOT *plot;
  int fi, xi;

  is_win = 0;
#ifdef CYGWIN
  is_win = 1;
  is_gnu = 0;
#endif

  plot = plot_create (FNUM, XNUM, /* TNUM */TNUL);
  plot->tnul = TNUL;
	
  for (xi=0 ; xi<plot->xnum ; xi++) 
    plot->x[xi] = XVAL (xi);
	
  for (fi=0 ; fi<plot->fnum ; fi++) {
    plot->f[fi][0] = /* plot->f_calc[fi] = */ minfunc->fval[fi];
    plot->f[fi][1] = /* plot->f_true[fi] = */ minfunc->rval[fi];

    //plot->f_name[fi] = minfunc->fimq[fi];

    //if (plot->f_true[fi]) 
    if (plot->f[fi][1]) 
    plot->l_name[fi][1] = "TRUE";
    plot->l_name[fi][0] = minfunc->fimq[fi];
  }
	
  for (ti=0 ; ti<=TNUL ; ti++) 
    sprintf (plot->title[ti], "MINFUNC_PRINT:  %s (t = %d/%d  rezi = %f)", 
             minfunc->name, ti, TNUL, REZI(ti));


  plot_print (plot, is_win, is_gnu);

  return;
}
/*-----------------------------------YDataRW-----------------------------------*/
void
YDataRW (int num, int act, void *ptr, int size, FILE *stream)
{

  if (act == YSEEK) { 
    if (fseek (stream, size, SEEK_CUR) != 0) {printf("%d ", num); Error ("YDataRW-fseek"); }
  }
  else if      (act == YREAD) { 
    if (fread (ptr, size, 1, stream) != 1)   {printf("%d ", num); Error ("YDataRW-read");}
  }
  else if (act == YWRITE) { 
    if (fwrite(ptr, size, 1, stream) != 1)   {printf("%d ", num); Error ("YDataRW-write");}
  }

  return;
}
/*----------------------------------proc_FTAB----------------------------------*/
double
proc_FTAB (int message, double *xyz, double *fun, long long1, long long2, void *ptr)
{
  // стандартная процедура для решения систем уравнений 
     
  static YT_MINPROC *minproc;
  static YT_MINFUNC *minfunc;
  double rezi;
  int    fi, xi, ti;
  double eqv;


  switch (message) {
  case YINIT:
    minproc = (YT_MINPROC*) ptr;
    minfunc = (YT_MINFUNC*) long1;
    //break;
    break;

  case YCALC:
    //minproc_print (minproc, "proc_FTAB: YCALC: ");
    minproc_to_minfunc (minproc, minfunc, xyz);

    // подсчитаем невязку, т.е. расстояние до точного решения
    rezi = 0;

    for (fi=0; fi<FNUM; fi++) 
    for (ti=T_WORK_BEG; ti<=T_WORK_END; ti++) 
    for (xi=X_WORK_BEG; xi<=X_WORK_END; xi++) {

      // для расчета функции надо передать: xi и fi и ti
      eqv = minfunc->func (YCALC, (long)xi, (long)minfunc, (long)fi, (long)ti);
      rezi += (eqv*eqv);
    }

    rezi = sqrt(rezi);		
    return (rezi);
  }

  RETURN;
}
/*------------------------------minfunc_create---------------------------------*/
YT_MINFUNC*
minfunc_create (int fnum, YT_FUNC func, const char *name, 
                double xmin, double xmax, int xnum, double tmin, double tmax, int tnum)
{
  YT_MINFUNC *minfunc;
  int fi;
  int n;
  char fi_name[80];
  double *pnew;

  YMALLOC (minfunc, YT_MINFUNC, 1);

  minfunc->func  = func;
  strncpy (minfunc->name, name, 80);
  /* 	minfunc->end_status = ""; */
  /* 	minfunc->end_niters = 0; */

  FNUM  = fnum;
  XNUM  = xnum;

  TNUL  = 0; //!!!!!!!!!!!!!!!!!!!!!!1
  TNUM  = tnum;

  for (n=0; n < FNUM; n++)
    YMALLOC (minfunc->fval[n], double, xnum*tnum);

  for (fi=0; fi < fnum; fi++)
    YMALLOC (minfunc->mval[fi], int, xnum*tnum);

  XMIN  = xmin;
  XMAX  = xmax;
  XSTEP = (xmax - xmin) / (XNUM - 1);

  for (fi=0; fi < fnum; fi++) {
    // установить пока нулевыми массивы ТОЧНЫХ решений
    minfunc->rval[fi] = NULL;

    // значения fmin_fmax нужны только для PEREBOR
    minfunc_fmin_fmax_ferr (fi, minfunc, -5.0, 5.0, 0.1);

    sprintf (fi_name, "%d", fi);
    minfunc_put_all (fi, fi_name, minfunc, 0.0);

    // установить параметры граничных условий
    minfunc->xleft_flag[fi]  = FALSE;
    minfunc->xright_flag[fi] = FALSE;
  }
		
  YMALLOC (minfunc->rezi, double, tnum);
  REZI(0) = 0.0;

  TMIN  = tmin;
  TMAX  = tmax;
  if (TNUM == 1) TSTEP = 0; //??????????????????????????
  else           TSTEP = (tmax - tmin) / (TNUM - 1);

  return (minfunc);
}
/*----------------------------------minfunc_put--------------------------------*/
void
minfunc_put (int fi, YT_MINFUNC *minfunc, int xi, int ti, double val, int mod)
{

  FVAL (fi, xi, ti) = val;
  FMOD (fi, xi, ti) = mod;

  return;
}
/*---------------------------------minfunc_named-------------------------------*/
void
minfunc_named (int fi, YT_MINFUNC *minfunc, char *name)
{

  strncpy (minfunc->fimq[fi], name, 80);

}
/*--------------------------------minfunc_put_all------------------------------*/
void
minfunc_put_all (int fi, char *name, YT_MINFUNC *minfunc, double all_val)
{
  int xi, ti;

  minfunc_named (fi, minfunc, name);

  for (xi=0; xi < XNUM; xi++)
  for (ti=0; ti < TNUM; ti++)
    minfunc_put (fi, minfunc, xi, ti, all_val, FALSE);

  return;
}
/*-----------------------------minfunc_set_xleft-------------------------------*/
void
minfunc_set_xleft (int fi, YT_MINFUNC *minfunc, double dval)
{

  minfunc->xleft_flag[fi] = TRUE;
  minfunc->xleft_dval[fi] = dval;

  return;
}
/*-----------------------------minfunc_set_xright------------------------------*/
void
minfunc_set_xright (int fi, YT_MINFUNC *minfunc, double dval)
{

  minfunc->xright_flag[fi] = TRUE;
  minfunc->xright_dval[fi] = dval;

  return;
}
/*-----------------------------minfunc_put_xleft-------------------------------*/
void
minfunc_put_xleft (int fi, YT_MINFUNC *minfunc, double val)
{
  int xi, ti;

  xi = 0;

  for (ti=TNUL; ti < TNUM; ti++)
    minfunc_put (fi, minfunc, xi, ti, val, TRUE);

  minfunc_set_xleft (fi, minfunc, val); //??? дублирование

  return;
}
/*-----------------------------minfunc_put_xright------------------------------*/
void
minfunc_put_xright (int fi, YT_MINFUNC *minfunc, double val)
{
  int xi, ti;

  xi = XNUM-1;

  for (ti=TNUL; ti < TNUM; ti++)
    minfunc_put (fi, minfunc, xi, ti, val, TRUE);

  minfunc_set_xright (fi, minfunc, val); //??? дублирование

  return;
}
/*----------------------------minfunc_put_tstart-------------------------------*/
void
minfunc_put_tstart (int fi, YT_MINFUNC *minfunc, double val)
{
  int xi;

  for (xi=0; xi < XNUM; xi++)
    minfunc_put (fi, minfunc, xi, 0, val, TRUE);

  return;
}
/*--------------------------minfunc_fmin_fmax_ferr-----------------------------*/
void
minfunc_fmin_fmax_ferr (int n, YT_MINFUNC *minfunc, double fmin, double fmax, double ferr)
{

  FMIN(n) = fmin;
  FMAX(n) = fmax;
  FERR(n) = ferr;

  return;
}
/*------------------------------minfunc_add_true-------------------------------*/
void
  minfunc_add_true (YT_MINFUNC *minfunc)
{
  int fi;

  for (fi=0; fi < FNUM; fi++)
    YMALLOC (minfunc->rval[fi], double, XNUM*TNUM);

  return;
}
/*******************************************************************************/
/*-------------------------------minfunc_to_minproc----------------------------*/
BOOL
minfunc_to_minproc (YT_MINFUNC *minfunc, YT_MINPROC *minproc)
{
  int    ind, size;
  int    fi, xi, ti = 0;

  // сформировать основные константы
  ind = 0;

  for (fi=0;    fi <  FNUM; fi++)
  for (ti=T_CALC_BEG; ti <= T_CALC_END; ti++) 
  for (xi=X_CALC_BEG; xi <= X_CALC_END; xi++) {
    if (FMOD(fi, xi, ti) == TRUE) // значение постоянно
      continue;

    XYZ_MIN[ind] = FMIN(fi);
    XYZ_MAX[ind] = FMAX(fi);
    XYZ_ERR[ind] = FERR(fi);
    ind++;
  }

  DIM  = size = ind;
  //printf ("XBEG=%d XEND=%d  TBEG=%d TEND=%d \n", XBEG, XEND, TBEG, TEND);
  //OUTD(DIM); //!!!!!
  if (!DIM) return FALSE;

  NAME = minfunc->name;

  // представить неизвестную функцию в виде пространства для минимизации
  ind = 0;

  for (fi=0;    fi <  FNUM; fi++)
  for (ti=T_CALC_BEG; ti <= T_CALC_END; ti++) 
  for (xi=X_CALC_BEG; xi <= X_CALC_END; xi++) {
    if (FMOD(fi, xi, ti) == TRUE) // значение постоянно
      continue;

    // задать одно начальное приближение
    XYZ_BEG[0][ind++] = FVAL (fi, xi, ti);
  }

  NUM_BEG = 1;

  return TRUE;
}
/*-------------------------------minproc_to_minfunc----------------------------*/
void
minproc_to_minfunc (YT_MINPROC *minproc, YT_MINFUNC *minfunc, double *xyz_cur)
{
  int    ind;
  int    fi, xi, ti;


  if (!xyz_cur) { // окончательное (а не текущее) решение
    if (NUM_END != 1) {
      printf ("NUM_END != 1  Don't solver!!! \n");
      //minproc_print (minproc, "minproc: ");
    }
    xyz_cur = XYZ_END[0]; 
    REZI(T_CALC_BEG) = FUN_END-0.0; // в пошаговой схеме: T_CALC_BEG==T_CALC_END
/* 		minfunc->end_status = minproc->end_status; */
/* 		minfunc->end_niters = minproc->end_niters; */
  }

  ind = 0;
  for (fi=0;          fi <  FNUM;       fi++)
  for (ti=T_CALC_BEG; ti <= T_CALC_END; ti++) 
  for (xi=X_CALC_BEG; xi <= X_CALC_END; xi++) {
    if (FMOD (fi, xi, ti) == TRUE) // значение постоянно
      continue;

    FVAL (fi, xi, ti) = xyz_cur[ind++];
  }

  //REZI = FUN_END - 0.0;
  return;
}
/*******************************************************************************/
/*                                                                             */
/*  Тестовые и расчетные задачи (MINPROC+MINFUNC, etc)                         */
/*                                                                             */
/*******************************************************************************/

/*----------------------------------minfunc_integral---------------------------*/
double
minfunc_integral (YT_MINFUNC *minfunc, int xi_min, int xi_max, YT_SUBFUNC func, double x_param)
{
  int    xi;
  double sum, val, k;
  int mode = 2;
  //XSTEP???

  sum = 0;

  switch (mode) {
  case 1: // прямоугольники
    for (xi=xi_min; xi <= xi_max; xi++) {
      val = func (minfunc, xi, (long)(&x_param), 0,0);
      sum += val;
    }
    sum = sum * XSTEP;
    break;

  case 2: // тпапеции
    for (xi=xi_min; xi <= xi_max; xi++) {
      val = func (minfunc, xi, (long)(&x_param), 0,0);
      if (xi==xi_min && xi==xi_max) k = 1;
      else                          k = 2;
      sum += (k*val);
    }
    sum = sum * XSTEP/2;
    break;

  default: ;;;;;
  }

  return (sum);
}
/*-------------------------------minfunc_test----------------------------------*/
void
minfunc_test (YT_MINFUNC *minfunc, double sum_max)
{
  int fi, ti, xi;
  double sub, sum = 0;


  FOR (fi, FNUM) 
    FOR (ti, TNUM) 
    FOR (xi, XNUM) {
    sub = RVAL(fi, xi,ti) - FVAL(fi, xi,ti);
    sum += sub*sub; 
  }

  sum = sqrt (sum);

  if (sum < sum_max) printf ("   O-KEY! .... ");
  else               printf ("   ERROR! .... "); 

  printf ("[%s] %f \n", minfunc->name, sum);
  return;
}
/*----------------------------minfunc_pik_tstart-------------------------------*/
void
minfunc_pik_tstart (int fi, YT_MINFUNC *minfunc, double w, double fc)
{
  int hand = w / 2 * XNUM; 
  int xi;
  double ret, a, b, xc, x1, x2, f;
  int xi_c, xi_1, xi_2, i;

  xi_c = XNUM / 2; 
  xi_1 = xi_c - hand + 1;
  xc = XVAL (xi_c);
  x1 = XVAL (xi_1);
  a  = fc / (xc - x1); b = - x1 / (xc - x1) * fc;
	
  minfunc_put_tstart (fi, minfunc, 0);

  minfunc_put (fi, minfunc, xi_c, 0, fc, TRUE);
  for (i=1; i<hand; i++) {
    xi = xi_c-i;
    f  = a*X+b;
    minfunc_put (fi, minfunc, xi, 0, f, TRUE);
    minfunc_put (fi, minfunc, xi_c+i, 0, f, TRUE);
  }
	
  return;
}
/*-----------------------------minfunc_cos_tstart------------------------------*/
void
minfunc_cos_tstart (int fi, YT_MINFUNC *minfunc, double v_null, double v_pike)
{
  //double v_null = 0.0;
  double v_diff = v_pike-v_null;

  double w = 0.5; 
  int hand = w / 2 * XNUM; 
  int xi;
  double ret, xc, x2, f, dhand;
  int xi_c, xi_2, i;

  xi_c = XNUM / 2; 
  xi_2 = xi_c + hand - 1;
  xc = XVAL (xi_c);
  x2 = XVAL (xi_2);
  dhand = x2-xc;
	
  minfunc_put_tstart (fi, minfunc, v_null);

  // задать центральную точку
  minfunc_put (fi, minfunc, xi_c, 0, v_pike, TRUE);

  // задать саму "горку"
  for (i=1; i<hand; i++) {
    xi = xi_c+i;
    f  = v_null + 0.5*v_diff*(cos(X*YPI/dhand)+1);

    minfunc_put (fi, minfunc, xi,     0, f, TRUE);
    minfunc_put (fi, minfunc, xi_c-i, 0, f, TRUE);
  }
	
  return;
}
/*------------------------------minfunc_lef_tstart-----------------------------*/
void
minfunc_lef_tstart (int fi, YT_MINFUNC *minfunc, double w, double fc)
{
  // сделать ступеньку                                                         
  int i, i_right;

  i_right = XNUM / w; 

  for (i=0; i<i_right; i++)
    minfunc_put (0, minfunc, i, 0, fc, TRUE);

  for (i=i_right; i<XNUM; i++)
    minfunc_put (0, minfunc, i, 0, 0.0, TRUE);
	
  return;
}
/*-----------------------------------------------------------------------------*/
/*                            F U N C  T E S T S                               */
/*-----------------------------------------------------------------------------*/


/*--------------------------------kill_pid_save--------------------------------*/
void
kill_pid_save ()
{
  FILE *fp;
  int   pid = getpid();

  if (!(fp = fopen (KILL_PID, "w"))) Error ("Cannot open file");

  fprintf (fp, "%d \n", pid);

  fclose (fp);
  return;
}
/*--------------------------------kill_pid_free--------------------------------*/
void
kill_pid_free ()
{
  char command[80];

  sprintf (command, "rm %s", KILL_PID);
  system (command);

  return;
}
/*--------------------------------kill_pid_make--------------------------------*/
void
kill_pid_make ()
{
  FILE *fp;
  char  command[80];
  int   pid = getpid();

  if (!(fp = fopen (KILL_PID, "r"))) Error ("Cannot open file");

  fscanf (fp, "%d", &pid);
  sprintf(command, "kill -9 %d", pid);
  system (command);

  kill_pid_free ();

  fclose (fp);
  return;
}
/*-------------------------------minfunc_info----------------------------------*/
void
minfunc_info (YT_MINFUNC *minfunc)
{

  fprintf (stderr, "xx= %3d  dx= %g  \n", XNUM-1, XSTEP);
  fprintf (stderr, "t0= %3d  dt= %g  \n", TNUL, TSTEP);

  /* 	fprintf (stderr, "XX  = %3d  XSTEP = %g  \n", XNUM-1, XSTEP); */
  /* 	fprintf (stderr, "TNUL= %3d  TSTEP = %g  \n", TNUL, TSTEP); */

  return;
}
/*-----------------------------minfunc_add_tt----------------------------------*/
void
minfunc_add_tt (YT_MINFUNC *minfunc, int tnul, int tt, double tstep)
{
  int  fi, ti, xi;
  double *fval, *rezi;
  int    *mval;

  if (tnul > TNUL) {
    fprintf (stderr, "tnul > TNUL \n"); 
    tnul = TNUL;
  }
  TNUL = tnul;

  TSTEP= tstep;
  TNUM = TNUL + tt + 1;

  for (fi=0; fi < FNUM; fi++) {
    YMALLOC (fval, double, XNUM*TNUM);
    YMALLOC (mval, int,    XNUM*TNUM);
    YMALLOC (rezi, double, TNUM);

    for (ti=0; ti <=TNUL; ti++) 
    for (xi=0; xi < XNUM; xi++) {
      fval[ti*XNUM+xi] = FVAL (fi, xi, ti); 
      mval[ti*XNUM+xi] = FMOD (fi, xi, ti); 
    }

    free (minfunc->fval[fi]);
    free (minfunc->mval[fi]);

    minfunc->fval[fi] = fval;
    minfunc->mval[fi] = mval;

    for (ti=0; ti <=TNUL; ti++) 
      rezi[ti] = REZI(ti);
    free (minfunc->rezi);
    minfunc->rezi = rezi;

    if (minfunc->xleft_flag [fi]) minfunc_put_xleft  (fi, minfunc, minfunc->xleft_dval[fi]); 
    if (minfunc->xright_flag[fi]) minfunc_put_xright (fi, minfunc, minfunc->xright_dval[fi]); 
  }

  return;
}
/*----------------------------minfunc_read_save--------------------------------*/
YT_MINFUNC *
minfunc_read_save (char *fname, int act, YT_MINFUNC *minfunc_old)
{
  FILE *fp;
  char *open_type;
  int  fi, ti, xi, i;
  double f;
  YT_MINFUNC *minfunc;
  double *pd_new;
  int *pi_new;

  if      (act == YREAD)   open_type = "r";
  else if (act == YWRITE)  open_type = "w";
  else Error("act");

  if ((fp = fopen (fname, open_type)) == NULL) {
    //OUTS(fname);
    //Error ("Cannot open file");
    fprintf (stderr, "Cannot open file:  %s \n", fname);
    return (NULL);
  }
  //------------------------------
  minfunc = minfunc_old;

  if (act == YREAD) { 
    YMALLOC (minfunc, YT_MINFUNC, 1);
  }

  YDataRW (1, act, minfunc->name, 80, fp);

  YDataRW (2, act, &XNUM,  sizeof(int), fp);
  YDataRW (3, act, &XMIN,  sizeof(double), fp);
  YDataRW (4, act, &XMAX,  sizeof(double), fp);
  YDataRW (5, act, &XSTEP, sizeof(double), fp);

  YDataRW (6, act, &TNUL,  sizeof(int), fp);

  YDataRW (7, act, &TMIN,  sizeof(double), fp);
  YDataRW (8, act, &TMAX,  sizeof(double), fp);
  YDataRW (9, act, &TSTEP, sizeof(double), fp);

  YDataRW (10, act, &FNUM, sizeof(int), fp);

  if (act == YREAD)
    for (fi=0; fi < FNUM; fi++) {
      YMALLOC  (minfunc->fval[fi], double, XNUM*(TNUL+1));
      YMALLOC  (minfunc->mval[fi], int,    XNUM*(TNUL+1));

    }

  for (fi=0; fi < FNUM; fi++) 
  for (ti=0; ti <=TNUL; ti++) 
  for (xi=0; xi < XNUM; xi++) {
    if (act == YWRITE) f = FVAL (fi, xi, ti);  // FVAL
    YDataRW (11, act, &f, sizeof(double), fp);
    if (act == YREAD)  FVAL (fi, xi, ti) = f;

    if (act == YWRITE) i = FMOD (fi, xi, ti);  // FMOD
    YDataRW (11, act, &i, sizeof(int), fp);
    if (act == YREAD)  FMOD (fi, xi, ti) = i;
  }

  for (fi=0; fi < FNUM; fi++) 
    YDataRW (12, act, minfunc->fimq[fi], 80, fp);

  if (act == YREAD)  
    //YMALLOC (minfunc->rezi, double, TNUM);
    YMALLOC (minfunc->rezi, double, TNUL+1);
  for (ti=0; ti <= TNUL; ti++) 
    YDataRW (13, act, &(REZI(ti)), sizeof(double), fp);

  // записать/прочитать граничные условия 
  for (fi=0; fi < FNUM; fi++) {
    YDataRW (12, act, &(minfunc->xleft_flag[fi]), sizeof(BOOL), fp);
    YDataRW (12, act, &(minfunc->xleft_dval[fi]), sizeof(double), fp);
		
    YDataRW (12, act, &(minfunc->xright_flag[fi]), sizeof(BOOL), fp);
    YDataRW (12, act, &(minfunc->xright_dval[fi]), sizeof(double), fp);
  }

  // записать/прочитать fmin_fmax_ferr
  for (fi=0; fi < FNUM; fi++) {
    YDataRW (12, act, &(FMIN(fi)), sizeof(double), fp);
    YDataRW (12, act, &(FMAX(fi)), sizeof(double), fp);
    YDataRW (12, act, &(FERR(fi)), sizeof(double), fp);
  }

  // окончательные установки для чтения
  if (act == YREAD)  
    minfunc->func  = gazodin_func;

  fclose (fp);
  return (minfunc);
}
//******************************************************************************
/*-----------------------------------------------------------------------------*/
/*                       G A Z O D I N A M I K A                               */
/*-----------------------------------------------------------------------------*/

#define INT_EILLER 1 // интегральные эйлеровы уравнения
#define INT_LAGR_M 2 // интегральные лагранжево-массовые уравнения

#define RO    (Fn(0))
#define U     (Fn(1))
#define P     (Fn(2))
#define E     (Fn(3))

/*---------------------------------fulle---------------------------------------*/
double
fulle (YT_MINFUNC *minfunc, int fi, int xi, int ti, 
       long long1, long long2, long long3)
{

  return (E + U*U/2);

}
/*-----------------------------------pu----------------------------------------*/
double
pu (YT_MINFUNC *minfunc, int fi, int xi, int ti, long long1, long long2, long long3)
{

  return (P*U);

}
/*--------------------------------gazodin_R_calc-------------------------------*/
double
gazodin_R_calc (YT_MINFUNC *minfunc, int fi, int xi_left, int xi_right, int ti)
{
  int xi, xi_steps = (xi_right - xi_left); // количество интервалов
  double v_left, v_mid, v_right;
  double R;

  v_left = minfunc->func (YRINT, xi_left,  (long)minfunc, (long)fi, ti);
  v_right= minfunc->func (YRINT, xi_right, (long)minfunc, (long)fi, ti);

  v_mid = 0;
  for (xi=xi_left+1; xi<xi_right; xi++)
    v_mid += minfunc->func (YRINT, xi, (long)minfunc, (long)fi, ti);

  R  = 0.5*XSTEP*(v_left + 2*v_mid + v_right);

  return (R);
}
/*-------------------------------gazodin_Q_calc--------------------------------*/
double
gazodin_Q_calc (YT_MINFUNC *minfunc, int fi, int xi, int ti_0)
{
  double v1, v2;
  double Q;

  v1 = minfunc->func (YQINT, xi, (long)minfunc, (long)fi, ti_0-1);
  v2 = minfunc->func (YQINT, xi, (long)minfunc, (long)fi, ti_0);

  Q  = 0.5*TSTEP*(v1+v2);

  return (Q);
}
/*-------------------------------gazodin_q_make--------------------------------*/
double*
gazodin_q_make (YT_MINFUNC *minfunc, int fi, int xi_beg, int xi_end, int ti)
{
  double *q;
  int     xi;

  YMALLOC (q, double, xi_end-xi_beg+1);
		
  for (xi=xi_beg; xi <= xi_end; xi++)
    q[xi] = gazodin_Q_calc (minfunc, fi, xi, ti);

  return (q);
}
/*----------------------------gazodin_r_make_old-------------------------------*/
double*
gazodin_r_make_old (YT_MINFUNC *minfunc, int fi, int xi_beg, int xi_end, int ti)
{
  double *r;
  int     xi;

  YMALLOC (r, double, xi_end-xi_beg+1);
		
  r[xi_beg] = 0;
  for (xi=xi_beg+1; xi <= xi_end; xi++)
    r[xi] = gazodin_R_calc (minfunc, fi, xi_beg, xi, ti);

  return (r);
}
/*-------------------------------gazodin_r_make--------------------------------*/
double*
gazodin_r_make (YT_MINFUNC *minfunc, int fi, int xi_beg, int xi_end, int ti)
{
  double *r;
  int     xi;
  double  v1, v2, R;

  YMALLOC (r, double, xi_end-xi_beg+1);
		
  r[xi_beg] = 0;
  v1 = minfunc->func (YRINT, xi_beg,  (long)minfunc, (long)fi, ti);

  for (xi=xi_beg+1; xi <= xi_end; xi++) {
    v2 = minfunc->func (YRINT, xi,  (long)minfunc, (long)fi, ti);

    r[xi] = r[xi-1] + 0.5*XSTEP*(v1+v2);
    v1 = v2;
  }

  return (r);
}
/*-----------------------------gazodin_hintegral-------------------------------*/
double
gazodin_hintegral (int mode, YT_MINFUNC *minfunc, int fi, int xi_1, int xi_2, int ti_work)
{
  double R1, R2, Q1, Q2;

  static double *q, *r1, *r2;

  //  Вычисление интеграла (одного из цикла) по шаблону:
  //       o-*-*-*-o                                  <-R2<-  
  //       |       |  Обход с левого нижнего угла   Q2      Q1
  //       *-*-*-*-*  против часовой стрелки:         ->R1->  


  if (mode == 0) { // инициализация и вычисление чего можно
    // xi_1 = X_CALC_BEG; 
    // xi_2 = X_CALC_END; 
    q  = gazodin_q_make (minfunc, fi, xi_1, xi_2, ti_work);
    r1 = minfunc->r1[fi];
    r2 = gazodin_r_make (minfunc, fi, xi_1, xi_2, ti_work);

    return(0);
  } //-----------------------------------------------------

  if (mode == 2) { // завершение и очистка памяти
    free (q);
    free (r2);

    return(0);
  } //-----------------------------------------------------
 
  // основной счетный режим

  R1 = r1[xi_2] - r1[xi_1];
  R2 = r2[xi_2] - r2[xi_1];

  Q1 = q[xi_2];
  Q2 = q[xi_1];

  return (R1 - R2 - Q1 + Q2);
}
/*--------------------------------gazodin_proc---------------------------------*/
double
gazodin_proc (int message, double *xyz, double *fun, long long1, long long2, void *ptr)
{
  // процедура для минимизации GazoDin  
                                       
  static YT_MINPROC *minproc;
  static YT_MINFUNC *minfunc;
  double rezi;
  int    fi, xi, ti, ti_work, xi_left, xi_right;
  double eqv;
  static fnum_integral;


  switch (message) {
  case YINIT:
    // пока это расчет одного шага по времени ?
    minproc = (YT_MINPROC*) ptr;
    minfunc = (YT_MINFUNC*) long1;

    minproc->gslspusk = minfunc->gslspusk;

    if (FNUM>2) fnum_integral = FNUM-1;
    else        fnum_integral = FNUM;

    // предварительный расчет r1:
    for (fi=0; fi<fnum_integral; fi++) 
      minfunc->r1[fi] = gazodin_r_make (minfunc, fi, X_CALC_BEG, X_CALC_END, T_WORK_BEG-1);
    break;
  case YFREE:
    for (fi=0; fi<fnum_integral; fi++) 
      free (minfunc->r1[fi]);
    break;
  case YCALC:
    // оптимизировать по времени !!!!!!!!!!!!!!!!!!!!!!!!!!!
    // а это расчет одной итерации спуска 
    minproc_to_minfunc (minproc, minfunc, xyz);

    // подсчитаем невязку, т.е. расстояние до точного решения
    rezi = 0;
    ti_work = T_WORK_BEG = T_WORK_END;

    // для интегральных уравнений - перебор всех контуров
    for (fi=0; fi<fnum_integral; fi++) {
      gazodin_hintegral (0, minfunc, fi, X_CALC_BEG, X_CALC_END, ti_work);

      for (xi_left =X_CALC_BEG; xi_left  <  X_CALC_END; xi_left++) 
      for (xi_right=xi_left+1;  xi_right <= X_CALC_END; xi_right++) {

        eqv = gazodin_hintegral (1, minfunc, fi, xi_left, xi_right, ti_work);
        rezi += (eqv*eqv);
      }

      gazodin_hintegral (2, minfunc, 0, 0, 0, 0);
    }

    // для уравнения состояния - поточечный перебор
    if (FNUM > 2) {
      fi = FNUM-1;
      for (xi=X_CALC_BEG; xi <= X_CALC_END; xi++) {
        eqv = minfunc->func (YCALC, (long)xi, (long)minfunc, (long)fi, (long)ti_work);
        rezi += (eqv*eqv);
      }
    }

    rezi = sqrt (rezi);
    //if (rezi > 0.0001) fprintf (stderr, "r= %g \n", rezi);
    //check_inf_nan (rezi);
    return (rezi);
  }

  RETURN;
}
/*-----------------------------minfunc_solver_beg_end--------------------------*/
void
minfunc_solver_beg_end (YT_PROC proc, int p_power, int s_power, YT_MINFUNC *minfunc)
{
  YT_MINPROC *minproc;

  minproc = minproc_init (/* proc_FTAB */proc, (long)minfunc, 0);

  if (p_power != POWER_NOT) {
    if (!minfunc_to_minproc (minfunc, minproc)) return;
    minproc_calc (minproc, p_power, Y_PEREBOR, 0, 0);
    minproc_to_minfunc (minproc, minfunc, NULL);
  }
	
  if (s_power != POWER_NOT) {
    if (!minfunc_to_minproc (minfunc, minproc)) return;
    minproc_calc (minproc, s_power, YGSLSPUSK, 0, 0);
    minproc_to_minfunc (minproc, minfunc, NULL);
  }
	
  minproc_free (minproc);

  return;
}
/*-----------------------------gazodin_solver_beg------------------------------*/
void
gazodin_solver_beg (int argc, char *argv[], YT_MINFUNC *minfunc)
{
  int i;
  time_t t;

  fprintf (stderr, "---------------------------------------------- \n");
  t = time (NULL);
  fputs (ctime(&t), stderr);

  fprintf (stderr, "> ");
  for (i=0; i<argc; i++)
    fprintf (stderr, "%s ", argv[i]);
  fprintf (stderr, "\n");


  fprintf (stderr, "\n");
  minfunc_info (minfunc);
  fprintf (stderr, "\n");

  kill_pid_save ();
  minfunc->solv_timer = timer_beg ();

  return;
}
/*-----------------------------gazodin_solver_end------------------------------*/
void
gazodin_solver_end (YT_MINFUNC *minfunc)
{
  char solv_hms_time[80];

  fprintf (stderr, "\n");

  timer_end (minfunc->solv_timer, solv_hms_time);
  fprintf (stderr, "Solv-Elapsed Time = %s \n", solv_hms_time);

  kill_pid_free ();
  fprintf (stderr, "---------------------------------------------- \n");

  return;
}
/*-------------------------------gazodin_solver--------------------------------*/
void
gazodin_solver (/* int argc, char *argv[], */ YT_MINFUNC *minfunc, int saveN)
{
  int      fi, ti, xi, i;
  time_t   tim_beg, tim_end, tim_all, tim_min, tim_sec, tim_hor;
  YT_TIMER *step_timer;
  char fname[80];
  char solv_hms_time[80], step_hms_time[80];
  YT_GSLSPUSK *gslspusk = minfunc->gslspusk;

  //gazodin_solver_beg (argc, argv, minfunc);
  //-------------------------

  //if (saveN && TNUL==0) {
  //	sprintf (fname, "s%03d.sol", TNUL);
  //	minfunc_read_save (fname, YWRITE, minfunc);
  //}

  fprintf (stderr, "%strue ti=%3d  r= %.8f  \n", LEFT, TNUL, REZI(TNUL));

  for (ti=TNUL+1; ti <= TNUM-1; ti++) {
    step_timer = timer_beg ();
    X_CALC_BEG = 0;  
    X_CALC_END = XNUM-1;
    X_WORK_BEG = 1;  
    X_WORK_END = XNUM-2;

    // начальное приближение с предыдущего слоя
    for (fi=0;          fi <  FNUM;       fi++)
    for (xi=X_CALC_BEG; xi <= X_CALC_END; xi++) 
      FVAL (fi, xi, ti) = FVAL (fi, xi, ti-1);

    T_CALC_BEG = T_WORK_BEG = 
      T_CALC_END = T_WORK_END = ti;

    //minfunc_prepare_tnull (TNUL, minfunc, );
    minfunc_solver_beg_end (gazodin_proc, POWER_NOT, 1, /*  0, POWER_NOT, */ minfunc);

    // фиксируем уже посчитанное
    for (fi=0;          fi <  FNUM;       fi++)
    for (xi=X_CALC_BEG; xi <= X_CALC_END; xi++) 
      FMOD (fi, xi, ti) = TRUE;

    TNUL++;
    if (saveN && ((TNUL%saveN)==0) /* || timer_hor(minfunc->solv_timer) */) {
      //sprintf (fname, "s%03d.sol", TNUL);
      // иногда записывать резервный (на случай сбоя записи основного)
      strcpy (fname, "sol-COPY.sol");
      minfunc_read_save (fname, YWRITE, minfunc);
    }
    // всегда записывать основной файл
    minfunc_read_save (LAST_SOL, YWRITE, minfunc);

    timer_end (step_timer, step_hms_time);
    fprintf (stderr, "%scalc ti=%3d  r= %.8f  t= %s  %s  niters=%4d  \n", LEFT, 
             TNUL, REZI(TNUL), step_hms_time, gslspusk->end_status, gslspusk->end_niters);
  }

  //-------------------------
  //gazodin_solver_end (minfunc);
	
  return;
}
/*----------------------------gazodin_set_null_beg-----------------------------*/
YT_MINFUNC*
gazodin_set_null_beg (int fnum, int xx)
{
  YT_MINFUNC *minfunc;
  double  xmin, xmax, xstep, xnum, p;
  int     xcenter, xi;


  xnum = xx+1;
  xcenter = xnum/2;

  xmin = -0.5;
  xmax = +0.5;
  xstep = (xmax-xnum)/xx;

  minfunc = minfunc_create (fnum, gazodin_func, "GazoDin", 
                            xmin, xmax, xnum,  0.0, 0.0, 1);

  minfunc_named (0, minfunc, "RO");
  minfunc_named (1, minfunc, "U" );
  if (fnum>2) 
    minfunc_named (2, minfunc, "P" );
  if (fnum>3) 
    minfunc_named (3, minfunc, "E" );
	
  //minfunc_fmin_fmax_ferr (0, minfunc, -0.1, 0.5, 0.0001);
  //minfunc_fmin_fmax_ferr (1, minfunc, -0.1, 0.5, 0.0001);
  // переборный тест
  //minfunc_fmin_fmax_ferr (0, minfunc, -0.1, 0.2, 0.1);
  //minfunc_fmin_fmax_ferr (1, minfunc, -0.1, 0.1, 0.1);

  return (minfunc);
}
/*----------------------------------p_from_urs---------------------------------*/
double
p_from_urs (YT_MINFUNC *minfunc)
{
  int    xi;
  double p;

  for (xi=0; xi<XNUM;xi++) {
    p = minfunc->func (YCALC, xi, (long)minfunc, -1, 0);
    minfunc_put (2, minfunc, xi, 0, p, TRUE);
  }

  return (p);
}
/*----------------------------gazodin_set_null_pik-----------------------------*/
YT_MINFUNC *
gazodin_set_null_pik (int fnum, int xx, char *mode, double r0, double r1)
{
  YT_MINFUNC *minfunc;
  double  xmin, xmax, xstep, xnum, p;
  int     xcenter, xi;

  minfunc = gazodin_set_null_beg (fnum, xx);
  xcenter = XNUM/2;

  // распределение плотности
  minfunc_put_tstart (0, minfunc, r0); 
  if      (YStrCmp (mode, "pik")) 
    minfunc_put (0, minfunc, xcenter, 0, r1, TRUE);
  else if (YStrCmp (mode, "cos"))
    minfunc_cos_tstart (0, minfunc, r0, r1);
  else 
    Error ("mode");

  // U=0 - неподвижный газ
  minfunc_put_tstart (1, minfunc, 0.0); 
  // E=0  - холодный газ ??
  if (FNUM==4) 
    minfunc_put_tstart (3, minfunc, 1.0); 
  // начальное давление - из уравнения состояния!!
  if (FNUM >= 3) 
    p_from_urs (minfunc);

  // граничные условия (сплошные неподвижные стенки)
  minfunc_put_xleft  (1, minfunc, 0.0); 
  minfunc_put_xright (1, minfunc, 0.0); 

  return (minfunc);
}
/*----------------------------gazodin_set_null_koh-----------------------------*/
YT_MINFUNC *
gazodin_set_null_koh (int fnum, int xx, double r0, double u0)
{
  /* 	double  r0 =  0.1; */
  /* 	double  u0 = -0.1; */

  YT_MINFUNC *minfunc;
  int    xi;
  double p;

  minfunc = gazodin_set_null_beg (fnum, xx);

  // распределение плотности
  minfunc_put_tstart (0, minfunc, r0); 

  // U - всеобщее движение
  minfunc_put_tstart (1, minfunc, u0); 
  // E=0  - холодный газ ??
  if (FNUM==4) 
    minfunc_put_tstart (3, minfunc, 1.0); 
  // начальное давление - из уравнения состояния!!
  if (FNUM >= 3) 
    p_from_urs (minfunc);

  // граничные условия (сплошные неподвижные стенки)
  minfunc_put_xleft  (1, minfunc, 0.0); 
  //minfunc_put_xright (1, minfunc, 0.0); 

  return (minfunc);
}
/*----------------------------------parse_read---------------------------------*/
char*
parse_read (char *name, int argc, char *argv[])
{
  char *ptr;
  int   len, i;

  for (i=0; i < argc; i++) {
    ptr = argv[i];
    len = strlen(name);

    if (strncmp (ptr, name, len) == 0)
      return (ptr+len+1);    
  }

  return (NULL);
}
/*-----------------------------------parse_m-----------------------------------*/
int
parse_m (BOOL real_work, int argc, char *argv[])
{
  int    xx, fnum;
  YT_MINFUNC *minfunc;
  char  *ptr, *mode;
  double r0, r1, u0;

  fnum = 2;
  if (ptr = parse_read ("fnum", argc, argv)) 
    fnum = atoi (ptr);

  xx = 10;
  if (ptr = parse_read ("xx", argc, argv)) 
    xx = atoi (ptr);

  mode = "cos";
  if      (parse_read ("cos", argc, argv)) mode = "cos";
  else if (parse_read ("pik", argc, argv)) mode = "pik";
  else if (parse_read ("koh", argc, argv)) mode = "koh";

  r0 = 0.1;
  r1 = 0.11;
  u0 = -0.1;

  if (!real_work) 
    goto print;

  if (YStrCmp (mode, "koh"))
    minfunc = gazodin_set_null_koh (fnum, xx, r0, u0);
  else 
    minfunc = gazodin_set_null_pik (fnum, xx, mode, r0, r1);

  minfunc_read_save (LAST_SOL, YWRITE, minfunc);
  return 0;

 print:
  fprintf (stderr, "> solver -m fnum=%d xx=%d \n", fnum, xx);
  return 0;
}
/*-----------------------------------parse_c-----------------------------------*/
int
parse_c (BOOL real_work, int argc, char *argv[])
{
  YT_MINFUNC *minfunc;
  char   *ptr;
  int    tnul, tt, saveN;
  double tstep, stop_func;

  minfunc = minfunc_read_save (LAST_SOL, YREAD, NULL);

  if (minfunc) tnul = TNUL; 
  else         tnul = 0;
  if (ptr = parse_read ("t0", argc, argv)) 
    tnul = atoi (ptr);

  tt = 10;
  if (ptr = parse_read ("tt", argc, argv)) 
    tt = atoi (ptr);

  tstep = 0.005;
  if (ptr = parse_read ("dt", argc, argv))
    tstep = atof (ptr);

  stop_func = 0.0001;
  if (ptr = parse_read ("er", argc, argv))
    stop_func = atof (ptr);

  saveN = 3; 

  if (!real_work) 
    goto print;
	
  if (!minfunc) Error ("parse_c: minfunc");
  minfunc_add_tt (minfunc, tnul, tt, tstep); // расшрить задачу дальше на tt шагов !!!

  minfunc->gslspusk = minproc_gslspusk_set 
    (
     TRUE, 0.00000001, //FALSE, 0.000001, 
     gsl_multimin_fdfminimizer_vector_bfgs,
     /* размер первого пробного шага  */ 0.000001, 
     /* точность линейной минимизации */ 0.000001, 

     //        критерии останова :::::::
     /* по норме градиента     */ 0.001, 
     /* по количеству итераций */ 5000,
     /* по значению функции    */ stop_func
     );

  gazodin_solver_beg (argc, argv, minfunc);
  gazodin_solver (minfunc, saveN);
  gazodin_solver_end (minfunc);

  return 0;

 print:
  fprintf (stderr, "> solver -c t0=%d tt=%d dt=%g er=%g \n", tnul, tt, tstep, stop_func);
  return 0;
}
/*---------------------------------gazodin_main--------------------------------*/
void
gazodin_main (int argc, char *argv[])
{
  char  *fname;
  YT_MINFUNC *minfunc;
  int i;

  if (argc == 1) {
    parse_m (FALSE, argc, argv);
    parse_c (FALSE, argc, argv);
    fprintf (stderr, "> solver -k \n");
    fprintf (stderr, "> solver -p \n");
    fprintf (stderr, "> solver -i \n");
    return;
  }
	
  if (YStrCmp (argv[1], "-i")) {
    fname = LAST_SOL;
    minfunc = minfunc_read_save (fname, YREAD, NULL);
    minfunc_info (minfunc);
    return;
  }
  if (YStrCmp (argv[1], "-p")) {
    fname = LAST_SOL;
    minfunc = minfunc_read_save (fname, YREAD, NULL);
    minfunc_print (1,1, minfunc);
    return;
  }
  if (YStrCmp (argv[1], "-k")) {
    kill_pid_make ();
    // надо перехватить сигнал SIGKILL -9 и вызвать:
    // gazodin_solver_end (minfunc);
    return;
  }
	
  // ----------------------------------
  if (YStrCmp (argv[1], "-c")) {
    parse_c (TRUE, argc, argv);
    return;
  }
	
  if (YStrCmp (argv[1], "-m")) {
    i = parse_m (TRUE, argc, argv);
		
    if (parse_read ("-c", argc, argv)) 
      parse_c (TRUE, argc, argv);
  }
  // ----------------------------------
	
  return;
}
/*---------------------------------gazodin_func--------------------------------*/
double
gazodin_func (int message, long long1, long long2, long long3, long long4)
{

  FUNC_VARS;
  double p, gamma = 5.0/3;

  switch (message) {
  case YTRUE:
    break;
  case YCALC: // для уравнения состояния (последнее fi)
    FUNC_GETS;

    if (FNUM==3) p = RO;
    if (FNUM==4) p = RO*E*(gamma-1);

    if (fi < 0) return (p);
    else        return (P - p);
    break;
  case YRINT:// dx
    FUNC_GETS;
    if (fi == 0) return (RO);     // dx сохранение массы
    if (fi == 1) return (RO*U);   // dx сохранение импульса
    if (fi == 2) return (RO*(E+U*U/2));
  case YQINT:// dt
    FUNC_GETS;
    if (fi == 0) return (RO*U);
    if (FNUM==2 && fi==1) return (RO + RO*U*U);
    if (FNUM >2 && fi==1) return (P  + RO*U*U);
    if (fi == 2) return (RO*U*(E+U*U/2+P/RO));

  default: ;;;;;;;;;;
  }

  return (TRUE);
}
/*******************************************************************************/

#undef RO 
#undef U
#undef E 
#undef P 
 
/*******************************************************************************/
/*                                                                             */
/*-----------------------------------------------------------------------------*/
#ifdef COMMENT 
 
План: 

- для расчета градиента использовать (также) gsl_diff_central
- масштабные коеффициенты для разных уравнений
- свести к решению нелинейного уравнения (multidimensional Root-Finding)
- максимально точное интегрирование (numerical integration)
  //- введение лагранжевых (и массовых) координат
  //- сделать иерархический вывод test_print()
  //- максимальная скорость, сейчас:
  //solver -m fnum4 20 -c 20 0.005  [Solv-Elapsed Time = 0:02:39] [0:00:01-0:00:16]
  //solver -m fnum4 10 -c 10 0.005  [Solv-Elapsed Time = 0:00:18] [0:00:01-0:00:04]
- разные режимы перебора контуров
- оптимизировать само суммирование по контурам
- грубый расчет начального приближения (измельчение сетки)
- упрощенный расчет невязки (другая метрика?)
- исключить или оптимизировать minfunc<->minproc
  //- попробовать где-то OpenMP
- тесты и преимущесво интегр-го подхода
- учет смесей (РТ-неустойчивости)
  //- возможно добавить генетические алгоритмы
  //- поиск минимума с отжигом (simulated annealing)
 
#endif
/*******************************************************************************/
/*                                                                             */
/*-----------------------------------------------------------------------------*/
  int
  main (int argc, char *argv[]){

  YT_PLOT *plot;
  BOOL is_win = TRUE, is_gnu = TRUE;

  left_num = 0;
  LEFT_BEG;
  fprintf (stderr, "\n");
	

  if (1) gazodin_main (argc, argv);

  fprintf (stderr, "\n");
  LEFT_END; 
  return 1;
}
/*******************************************************************************/
/*******************************************************************************/
 
