// -*-  mode: c    ; coding: koi8   -*- ----------------------------------------

/*-----------------------------------------------------------------------------*/
/*                                                                             */
/*                            K E R N E L . H                                  */
/*                                                                             */
/*-----------------------------------------------------------------------------*/ 
/*******************************************************************************/

/* #include <fpu_control.h>                               */
/* #ifndef _FPU_SETCW                                     */
/* #include <i386/fpu_control.h>                          */
/* #define _FPU_SETCW(cw) __setfpucw(cw)                  */
/* #endif                                                 */

#ifdef NCURSES
//#include  <ncurses.h>
#include  <curses.h>
#endif

/*******************************************************************************/
/*                                                                             */
/*-----------------------------------------------------------------------------*/
#include <gsl/gsl_test.h> 
#include <gsl/gsl_rng.h>
#include <gsl/gsl_siman.h>
#include <gsl/gsl_ieee_utils.h>
#include <gsl/gsl_multimin.h>
#include <gsl/gsl_blas.h>  // обязательно, а то идут "nun"                               
#include <gsl/gsl_vector.h>

/*******************************************************************************/

enum keywords {
	YMAIN, YINIT, YFREE, YCALC, YGINT, YRINT, YQINT, YTRUE, YRANDDIRS, YRANDCURS, 
	Y_PEREBOR, YGSLSPUSK, 
	Y_GENALGO, YCONST, YRAND, YSIMP, YLEFT, YNULL, YNULL_3, YNULL_2, YINTL, 
  YREAD, YWRITE, YSEEK,
	YDONE
};


#define OUTD(val)  (fprintf(stderr,"out_%d \n",(val)))
#define OUTF(val)  (fprintf(stderr,"out_%f \n",(val)))
#define OUTS(val)  (fprintf(stderr,"out_%s \n",(val)))

#define YMAX(a,b)  (((a) > (b)) ? (a) : (b))
#define YMIN(a,b)  (((a) < (b)) ? (a) : (b))
#define YABS(x)    (((x) < (0)) ? (-x) : (x))
#define YRAND_S  srand((unsigned)time(NULL))
#define YRAND(imin,imax) (imin+rand()%(imax-imin+1))

#define YOVERFLOW(i) ( ((double)(i)) != (i) )
// calloc - с обнулением выделяемой памяти
#define CALLOC(p,conv,size) {if (YOVERFLOW(size)) p=NULL; else p=(conv)calloc(1,size);}
// malloc - без обнуления
#define MALLOC(p,conv,size) {if (YOVERFLOW(size)) p=NULL; else p=(conv)malloc(size);}
#define REALLOC(p_new,p_old,conv,size) \
               {if (YOVERFLOW(size)) p_new=NULL; else p_new=(conv)realloc(p_old,size);}

#define YMALLOC(pp,type,num) {MALLOC((pp),type*,(num)*sizeof(type)); \
               if (!(pp)) Error ("YMALLOC");}
#define YREALLOC(pp_new,pp_old,type,num) {REALLOC((pp_new),(pp_old),type*,(num)*sizeof(type)); \
               if (!(pp_new)) Error ("YREALLOC");}

typedef int BOOL;
#define YT_BOOL BOOL

#define YERROR(str)  {printf("ERR: %s \n",(str)); getchar(); exit(0);}
#define TRUE  1
#define FALSE 0

#define YPI (3.141592653589)
#define RAD(grad) ((double)(grad)*2.0*(YPI)/360.0)
#define GRAD(rad) ((double)(rad)*360.0/(2.0*YPI) )

#define FOR(i,ii) for ((i)=0; (i) < (ii); (i)++)

#define YPI (3.141592653589)
#define RAD(grad) ((double)(grad)*2.0*(YPI)/360.0)
#define GRAD(rad) ((double)(rad)*360.0/(2.0*YPI) )

#define CHAR int

#define  EPS  0.000001

int    Rand123 (double p1, double p2, double p3);
BOOL   RandYes (double procent);
BOOL   FRavno (double d1, double d2, double eps);
int    YInt (double f);
void   Error (const char *string);
double YRandF (double fmin, double fmax);
BOOL   str_cmp (const char *str1, const char *str2);

/*******************************************************************************/
/*                                                                             */
/*-----------------------------------------------------------------------------*/

typedef struct {
	int      fnum;
	int      xnum, tnum, tnul;
	double   xmin[20], ymin[20], xmax[20], ymax[20];

	double  *x;
	double  *f[20][20];
/* 	double  *f_calc[20]; */
/* 	double  *f_true[20]; */

	char    *title[1000];
	char    *l_name[20][20];
} YT_PLOT;


YT_PLOT* plot_create (int fnum, int xnum, int tnum);
void     plot_win (int, YT_PLOT *p, int, int, int ih_one);
void     plot_print (YT_PLOT *plot, BOOL is_win, BOOL is_gnu);

//-----------------------------------------------------
// ANSI  color-change escape sequences.
// Xterm Control Sequences (this is the file ctlseqs.ms)
// man console_codes

#define ED  printf("\x1b[2J") // стереть экран
#define EL  printf("\x1b[K")  // стереть строку
#define CUP(row,col) printf("\x1b[%d;%dH", row,col) // переместить курсор

#define CUU printf("\x1b[A")  // на одну строку вверх
#define CUD printf("\x1b[B")  // на одну строку вниз
#define CUF printf("\x1b[C")  // на одну строку вправо
#define CUB printf("\x1b[D")  // на одну строку влево

#define SCP printf("\x1b[s")  // считать текущую позицию курсора
#define RCP printf("\x1b[u")  // восстановит позицию курсора

#define SGR_DEFAULT  0
#define SGR_BOLD     1
#define SGR_BLACK   30    //set black foreground
#define SGR_RED     31    //set red foreground
#define SGR_GREEN   32    //set green foreground
#define SGR_BROWN   33    //set brown foreground
#define SGR_BLUE    34    //set blue foreground
#define SGR_MAGENTA 35    //set magenta foreground
#define SGR_CYAN    36    //set cyan foreground
#define SGR_WHITE   37    //set white foreground

/*******************************************************************************/
/*                                                                             */
/*-----------------------------------------------------------------------------*/

typedef struct {
	int  w, h;
	char p[100][100];
} YT_WIN;

typedef long  YT_SPACE_NULL;

typedef struct {
  int     i, x, y, delta_x, delta_y, exchange, err, incx, incy;
  int     x_old, y_old, x_left, x_right;
  BOOL    begin, end;
  int     align;
} VT_HANDLINE;

void plot_main (YT_WIN *win, int, int, YT_PLOT *plot, int x, int y, int w, int h);
void win_char (YT_WIN *win, CHAR ch, int x, int y);
void win_sgr (int par);
#define SKIP while(getchar()!='\n')
  
/*******************************************************************************/

//#define YMAXDOUBLE MAXDOUBLE  //DBL_MAX=1.7976931348623157e+308  values.h->float.h
//#define YMINDOUBLE MINDOUBLE  //DBL_MIN=2.2250738585072014e-308
#define YMAXDOUBLE 1.00e+100
#define YMINDOUBLE 1.00e-100

/*******************************************************************************/
/*                                                                             */
/*                            M I N P R O C                                    */
/*                                                                             */
/*-----------------------------------------------------------------------------*/
#define MAXA 1000 // ???
#define MAXB 100  // ???


#define STEPS_TO_MIN -1
#define JUMPS_TO_MIN -2

#define FN(n) (fun[(n)-1])
#define XN(n) (xyz[(n)-1])

#define PROC_VAR  int message, double *xyz, double *fun, long long1, long long2, void *ptr
#define PROC_PAR  message, xyz, fun, long1, long2, ptr

typedef double (*YT_PROC) (int, double *, double *, long, long, void *);

	typedef struct {
		BOOL   diff2;
		double diff_h;

		const  gsl_multimin_fdfminimizer_type *min_type;
		double step_size; 
		double tol;
 
		// критерии останова
		double stop_grad;
		int    stop_iter;
		double stop_func;

		char  *end_status;
		int    end_niters;
	} YT_GSLSPUSK;

typedef struct {
  const char   *name;
  int     dim;
  YT_PROC proc;

  double  xyz_min[MAXA], xyz_max[MAXA], xyz_err[MAXA];

  int     num_beg;
  double  xyz_beg[MAXB][MAXA];
  double  fun_beg[MAXB];

  int     num_end;
  double  xyz_end[MAXB][MAXA];
	double  fun_end;

	YT_GSLSPUSK *gslspusk;
} YT_MINPROC;

#define NAME    (minproc->name)
#define PROC    (minproc->proc)
#define DIM     (minproc->dim)
#define XYZ_MIN (minproc->xyz_min)
#define XYZ_MAX (minproc->xyz_max)
#define XYZ_ERR (minproc->xyz_err)
#define X_MIN   (XYZ_MIN[0])
#define X_MAX   (XYZ_MAX[0])
#define X_ERR   (XYZ_ERR[0])
#define Y_MIN   (XYZ_MIN[1])
#define Y_MAX   (XYZ_MAX[1])
#define Y_ERR   (XYZ_ERR[1])
#define Z_MIN   (XYZ_MIN[2])
#define Z_MAX   (XYZ_MAX[2])
#define Z_ERR   (XYZ_ERR[2])
#define NUM_BEG (minproc->num_beg)
#define XYZ_BEG (minproc->xyz_beg)
#define FUN_BEG (minproc->fun_beg)

#define NUM_END (minproc->num_end)
#define XYZ_END (minproc->xyz_end)
#define FUN_END (minproc->fun_end)

YT_MINPROC* minproc_init (YT_PROC proc, long, long);
void minproc_calc (YT_MINPROC *minproc, int, int, long, long);

void CheckNewMinmax (YT_MINPROC *minproc, double *xyz_tmp, double g);
void minproc_print (YT_MINPROC *minproc, const char *name);
void minproc_set (YT_MINPROC *minproc, double, double, double);

#define POWER_DEF 0
#define POWER_NOT -1

void   minproc_tests (YT_MINPROC *calc_rez, int p_power, int s_power);
double calc_proc (YT_MINPROC *minproc, double *xyz_cur);
double YSecOfDay (void);
void   minproc_gslspusk_s (YT_MINPROC *minproc, int algorifm, long, long);
double minproc_gslspusk_1 (YT_MINPROC *minproc, int algorifm, long, long, 
													 double *xyz_beg, double *xyz_end);
void   minproc_print_one (YT_MINPROC *minproc, double *xyz);

YT_GSLSPUSK *
minproc_gslspusk_set (BOOL diff2, double diff_h,
											const gsl_multimin_fdfminimizer_type *min_type,
											double step_size, double tol, 
											double stop_grad,
											int    stop_iter,
											double stop_func);
/*******************************************************************************/
typedef struct {
	time_t    tim_beg;
} YT_TIMER;

YT_TIMER* timer_beg (void);


#define LEFT left_buf
#define LEFT_BEG {LEFT[left_num]=' '; left_num+=2; LEFT[left_num]='\0';}
#define LEFT_END {LEFT[left_num]=' '; left_num-=2; LEFT[left_num]='\0';}

extern char left_buf[80];
extern int  left_num;
extern BOOL debug; 
 
#define RETURN {fun++; long1++; long2++; return (1);}

/*******************************************************************************/
