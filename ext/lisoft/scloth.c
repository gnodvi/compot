// -*-  mode: c    ; coding: koi8   -*- ----------------------------------------

/*-----------------------------------------------------------------------------*/
/*                                                                             */
/*                            S C L O T H . C                                  */
/*                                                                             */
/*-----------------------------------------------------------------------------*/ 

#include <stdio.h>
#include <stdlib.h>  
#include <string.h> 
#include <math.h>
#include <time.h>  
#include <ctype.h>  
  
#include <unistd.h> 
#include <sys/time.h>
#include <sys/param.h>
#include <sys/timeb.h>
#include <values.h>

#include <GL/glut.h>

#include <gsl/gsl_test.h>
#include <gsl/gsl_rng.h>
#include <gsl/gsl_siman.h>
#include <gsl/gsl_ieee_utils.h>
#include <gsl/gsl_multimin.h>
#include <gsl/gsl_blas.h>  // обязательно, а то идут "nun"                               
#include <gsl/gsl_vector.h>

/* #include <fpu_control.h>                               */
/* #ifndef _FPU_SETCW                                     */
/* #include <i386/fpu_control.h>                          */
/* #define _FPU_SETCW(cw) __setfpucw(cw)                  */
/* #endif                                                 */

/*-----------------------------------------------------------------------------*/
/*                                                                             */
/*                            C O M M O N . H                                  */
/*                                                                             */
/*-----------------------------------------------------------------------------*/ 

enum keywords {
	YMAIN, YINIT, YFREE, YCALC, YGINT, YRINT, YQINT, YTRUE, YRANDDIRS, YRANDCURS, 
	Y_PEREBOR, YGSLSPUSK, 
	Y_GENALGO, YCONST, YRAND, YSIMP, YLEFT, YNULL, YNULL_3, YNULL_2, YINTL, 
  YREAD, YWRITE, YSEEK,
	YDONE
};

enum {
  M_ITEM1, M_ITEM2, M_EXIT
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

//#define YMAXDOUBLE MAXDOUBLE  //DBL_MAX=1.7976931348623157e+308  values.h->float.h
//#define YMINDOUBLE MINDOUBLE  //DBL_MIN=2.2250738585072014e-308
#define YMAXDOUBLE 1.00e+100
#define YMINDOUBLE 1.00e-100

// ANSI  color-change escape sequences.
#define ED  printf("\x1b[2J") // стереть экран
#define EL  printf("\x1b[K")  // стереть строку
#define CUP(row,col) printf("\x1b[%d;%dH", row,col) // переместить курсор
#define CUU printf("\x1b[A")  // на одну строку вверх
#define CUD printf("\x1b[B")  // на одну строку вниз
#define CUF printf("\x1b[C")  // на одну строку вправо
#define CUB printf("\x1b[D")  // на одну строку влево
#define SCP printf("\x1b[s")  // считать текущую позицию курсора
#define RCP printf("\x1b[u")  // восстановит позицию курсора

typedef struct {
	time_t    tim_beg;
} YT_TIMER;

YT_TIMER* timer_beg (void);

#define LEFT left_buf
#define LEFT_BEG {LEFT[left_num]=' '; left_num+=2; LEFT[left_num]='\0';}
#define LEFT_END {LEFT[left_num]=' '; left_num-=2; LEFT[left_num]='\0';}

#define RETURN {fun++; long1++; long2++; return (1);}

#define  FALSE  0                                                              
#define  TRUE   1  
#define  YMAX(a,b)  (((a) > (b)) ? (a) : (b))
#define  YMIN(a,b)  (((a) < (b)) ? (a) : (b))
#define  YABS(x)    (((x) < (0)) ? (-x) : (x))

typedef  double  YT_SPACE;
#define  YMAXSPACE 1.00E+30
#define  YMINSPACE 1.00E-30 
#define  YLINER(x,x1,y1,x2,y2) ((y1)+(double)((x)-(x1))*((y2)-(y1))/((x2)-(x1)))
 
/*-----------------------------------------------------------------------------*/
/*                                                                             */
/*                            M I N M A X . H                                  */
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

/*-----------------------------------------------------------------------------*/
/*                                                                             */
/*                            V I S U A L . H                                  */
/*                                                                             */
/*-----------------------------------------------------------------------------*/ 

#define YKEY_LEVEL2  2000
enum keys_y_impr {
  YMORE_BEGIN = YKEY_LEVEL2, 
  YNONE, YRIGHT, YDOWN, YUP,
  YSTRING, 
  YRECTF, /* YARCB, YARCF, YPIXEL, */ YLINE, YPOLYF, 
  YNEW, YNORMAL, YBACKUP,
  YCOLORED, YGRAYED, YINVERSE,  YHORZ, YVERT, 

  YMORE_END 
}; 

typedef unsigned long YT_COLOR; 

#define  UNITX (YStringW("W"))
#define  UNITY (YStringH("H"))

#define  CLR_MAX     256
#define  CLR_DEF   CLR_MAX+1

#define  CLR_NULL  CLR_MAX+2	/*not real color! */
#define  CLR_XOR   CLR_MAX+3

typedef struct { 
  char   *name; 
  int     r, g, b; 
} YT_DEFCOLOR; 

typedef struct { 
  YT_BOOL exist; 
  char    name[30];  
  int     r, g, b; 
  YT_COLOR color; 
} YT_COLER; 

#define  NUM_KP 4 
typedef struct { 
  int     type, size; 
  int     kp[NUM_KP]; 
  int     rr[NUM_KP]; 
  int     gg[NUM_KP]; 
  int     bb[NUM_KP]; 
} YT_DEFPALETE; 
  
#define  SIZE_COLER  16

typedef struct { 
  YT_COLER     globcoller[SIZE_COLER]; 
  YT_DEFPALETE ds; 
  int          sizescale;
  YT_COLOR     colors[CLR_MAX];

} YT_NEWCOLOR;

extern YT_NEWCOLOR  newcolor;
extern int W, H;

#define  COLER(n)   (((newcolor).globcoller)[n]) 
#define  DEFPALETTE	 ((newcolor).ds)

#define  SIZE_SCALE   ((newcolor).sizescale)
#define  CLR_SCALE(n) ((newcolor).colors[(n)])

void     YInitCOLOR (void); 
void     YDrawLine (int, int, int, int, YT_COLOR);
void     YDrawRectF (int, int, int, int, YT_COLOR);
void     YDrawRectB (int, int, int, int, YT_COLOR);
void     YDrawRectFB (int, int, int, int, YT_COLOR, YT_COLOR);
void     YDrawString (char *, int, int, YT_COLOR);
void     YDrawVString (char *, int, int, YT_COLOR);
void     YDrawStringImp (char *, int, int, YT_COLOR, int, int);
void     YColorToRGB (YT_COLOR color, int *r, int *g, int *b);
YT_COLOR YColor (char *);
YT_COLOR YColer (int);
YT_COLOR YScale(int n);
YT_COLOR YGetColor (int x, int y);
int      YColorToScale (YT_COLOR);
void     YDrawScale (int xx, int yy, int ww, int hh, int style); 
void     YSetColors (int, int type_scale); 
YT_COLOR YColer (int n); 
void     YSetColler (void); 
void     YSetScale (int size_scale, int type_scale); 
void     YDefColor (YT_BOOL, int r, int g, int b, char *name);   
void     YGetDEFPALETE (int i, int *r, int *g, int *b); 
void     YSetDEFPALETE (int type, int size); 
int      YVertString (int x, int y, char *string, YT_COLOR color, YT_BOOL); 
void     YDefColors (YT_DEFCOLOR*); 
int      YVertStringH (char *);
YT_COLOR YSetRgbPalette (int index, int red, int green, int blue); 

/*-----------------------------------------------------------------------------*/
/*                                                                             */
/*                            S C L O T H . H                                  */
/*                                                                             */
/*-----------------------------------------------------------------------------*/ 

/* typedef struct { */
/* 	double x, y, z; */
/* } YT_P3D; */

typedef struct { 
	float x; 
	float y; 
	float z; 
} tVector; 
 
/* typedef struct  */
/* {  */
/* 	union {  */
/* 		float x;  */
/* 		float u;  */
/* 		float r;  */
/* 	};  */
/* 	union {  */
/* 		float y;  */
/* 		float v;  */
/* 		float g;  */
/* 	};  */
/* 	union {  */
/* 		float z;  */
/* 		float w;  */
/* 		float b;  */
/* 	};  */
/* } tVector;  */
 
// NOT DECLARED AS float[4][4] BECAUSE OPENGL ACCESSES THIS STRANGLY 
typedef struct 
{ 
	float m[16]; 
} tMatrix; 
 
// TYPE FOR A PHYSICAL PARTICLE IN THE SYSTEM 
typedef struct { 
	tVector pos;		// Position of Particle 
	tVector v;			// Velocity of Particle 
	tVector f;			// Force Acting on Particle 
	float	oneOverM;	// 1 / Mass of Particle 
} tParticle; 
 
// TYPE FOR SPRINGS IN SYSTEM 
typedef struct { 
	int		p1,p2;		// PARTICLE INDEX FOR ENDS 
	float	restLen;	// LENGTH OF SPRING AT REST 
	float	Ks;			  // SPRING CONSTANT 
	float	Kd;			  // SPRING DAMPING 
	int		type;		  // SPRING TYPE - USED FOR SPECIAL FEATURES 
} tSpring; 
 
#define MAKEVECTOR(a,vx,vy,vz)	a.x = vx; a.y = vy; a.z = vz; 
 

typedef struct {
	int ii, jj;
	double size_i, size_j;

	tParticle *s, *t;
	tParticle *array1, *array2;
	int	       m_ParticleCnt; 

/* 	tSpring		*m_Spring;		// VALID SPRINGS IN SYSTEM  */
/* 	int				 m_SpringCnt;		  */
} YT_CLOTH;

//#define  CLOP(clo,i,j)  (clo->p[(i)][(j)])                                   
#define  CLOP(clo,i,j)  (clo->s+((clo->jj)*(i)+(j)))                                   
#define  CLOX(clo,i,j)  ((CLOP(clo,i,j)->pos.x))                                   
#define  CLOY(clo,i,j)  ((CLOP(clo,i,j)->pos.y))                                   
#define  CLOZ(clo,i,j)  ((CLOP(clo,i,j)->pos.z))                                   

#define DEFAULT_DAMPING		0.002f 

/* enum tIntegratorTypes  */
/* {  */
/* 	EULER_INTEGRATOR,  */
/* 	MIDPOINT_INTEGRATOR,  */
/* 	RK4_INTEGRATOR  */
/* };  */
 
/*******************************************************************************/
/*-----------------------------------------------------------------------------*/
/*                                                                             */
/*-----------------------------------------------------------------------------*/ 

YT_NEWCOLOR  newcolor;
int W, H;

BOOL debug;
char left_buf[80] = "                 ";
int  left_num;

static GLfloat angle_x;   /* in degrees */
static GLfloat angle_y;   /* in degrees */
static int moving, startx, starty;

YT_CLOTH *clo;
GLuint All;                                                                    
float  siz, DeltaT;

tVector				 m_Gravity;				  // GRAVITY FORCE VECTOR 
tParticle			*m_TempSys[5];			// SETUP FOR TEMP PARTICLES USED WHILE INTEGRATING 
/*******************************************************************************/
/////////////////////////////////////////////////////////////////////////////// 
// 
// MathDefs.cpp : implementation file 
// 
// Purpose:	Implementation of Math Routines 
// 
// Created: 
//		JL  2/18/98 
// Revisions: 
// 
/////////////////////////////////////////////////////////////////////////////// 
// 
//	Copyright 1998 Jeff Lander, All Rights Reserved. 
//  For educational purposes only. 
//  Please do not republish in electronic or print form without permission 
//  Thanks - jeffl@darwin3d.com 
// 
/////////////////////////////////////////////////////////////////////////////// 
 
//#include "stdafx.h" 
//#include <math.h> 
//#include "mathdefs.h" 
 
/////////////////////////////////////////////////////////////////////////////// 
// Function:	MultVectorByMatrix 
// Purpose:		Multiplies a vector by a 4x4 Matrix in OpenGL Format 
// Arguments:	Matrix, Vector in, and result Vector 
// Notes:		This routing is tweaked to handle OpenGLs column-major format 
//				This is one obvious place for optimization perhaps asm code 
/////////////////////////////////////////////////////////////////////////////// 
void MultVectorByMatrix(tMatrix *mat, tVector *v,tVector *result) 
{ 
	result->x = (mat->m[0] * v->x) + 
			   (mat->m[4] * v->y) +	 
			   (mat->m[8] * v->z) + 
			   mat->m[12]; 
	result->y = (mat->m[1] * v->x) + 
			   (mat->m[5] * v->y) +	 
			   (mat->m[9] * v->z) + 
			   mat->m[13]; 
	result->z = (mat->m[2] * v->x) + 
			   (mat->m[6] * v->y) +	 
			   (mat->m[10] * v->z) + 
			   mat->m[14]; 
} 
//// MultVectorByMatrix ////////////////////////////////////////////////////// 
 
 
/* returns squared length of input vector */     
double VectorSquaredLength(tVector *v)  
{ 
	return((v->x * v->x) + (v->y * v->y) + (v->z * v->z)); 
} 
 
/* returns length of input vector */ 
double VectorLength(tVector *v)  
{ 
	return(sqrt(VectorSquaredLength(v))); 
} 
 
/* destructively normalizes the input vector */ 
void NormalizeVector(tVector *v)  
{ 
	float len = (float)VectorLength(v); 
    if (len != 0.0)  
	{  
		v->x /= len;   
		v->y /= len;  
		v->z /= len;  
	} 
} 
 
double DotProduct(tVector *v1, tVector *v2) 
{ 
	return ((v1->x * v2->x) + (v1->y * v2->y) + (v1->z * v2->z)); 
} 
 
/* return the cross product result = v1 cross v2 */ 
void CrossProduct(tVector *v1, tVector *v2, tVector *result) 
{ 
	result->x = (v1->y * v2->z) - (v1->z * v2->y); 
	result->y = (v1->z * v2->x) - (v1->x * v2->z); 
	result->z = (v1->x * v2->y) - (v1->y * v2->x); 
} 
 
double VectorSquaredDistance(tVector *v1, tVector *v2)  
{ 
	return(	((v1->x - v2->x) * (v1->x - v2->x)) +  
			((v1->y - v2->y) * (v1->y - v2->y)) + 	 
			((v1->z - v2->z) * (v1->z - v2->z)) ); 	 
} 
 
void ScaleVector(tVector *v, float scale, tVector *result)  
{ 
	result->x = v->x * scale; 
	result->y = v->y * scale; 
	result->z = v->z * scale; 
} 
 
void VectorSum(tVector *v1, tVector *v2, tVector *result)  
{ 
	result->x = v1->x + v2->x; 
	result->y = v1->y + v2->y; 
	result->z = v1->z + v2->z; 
} 
 
void VectorDifference(tVector *v1, tVector *v2, tVector *result)  
{ 
	result->x = v1->x - v2->x; 
	result->y = v1->y - v2->y; 
	result->z = v1->z - v2->z; 
} 
/*-----------------------------------------------------------------------------*/
/*                                                                             */
/*                            C O M M O N . C                                  */
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
/*******************************************************************************/
/*-----------------------------------------------------------------------------*/
/*                                                                             */
/*                            M I N M A X . C                                  */
/*                                                                             */
/*-----------------------------------------------------------------------------*/ 


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
/*-----------------------------------------------------------------------------*/
/*                                                                             */
/*                            V I S U A L . C                                  */
/*                                                                             */
/*-----------------------------------------------------------------------------*/ 


/*-------------------------------YDrawString-----------------------------------*/ 
/*                                                                             */
/*-----------------------------------------------------------------------------*/
void 
YDrawString (char *text, int x, int y, YT_COLOR color) 
{ 



 
} 
/*--------------------------------YDrawRectF-----------------------------------*/ 
/*                                                                             */
/*-----------------------------------------------------------------------------*/
void 
YDrawRectF (int x, int y, int w, int h, YT_COLOR f_color) 
{ 
	float xmin, ymin, xmax, ymax;
		
	xmin = (float)x / W;
	ymin = (float)y / H;
	xmax = xmin + (float)w / W;
	ymax = ymin + (float)h / H;
	
	glIndexi (f_color); 
		
	glBegin (GL_POLYGON);
	  glVertex2f (xmin, ymin);
		glVertex2f (xmax, ymin);
		glVertex2f (xmax, ymax);
		glVertex2f (xmin, ymax);
	glEnd ();
		
  return; 
} 
/*---------------------------------YDrawLine-----------------------------------*/ 
/*                                                                             */
/*-----------------------------------------------------------------------------*/
void 
YDrawLine (int x1, int y1, int x2, int y2, YT_COLOR color) 
{ 
	float xx1, yy1, xx2, yy2;

	xx1 = (float)x1 / W;
	yy1 = (float)y1 / H;
	xx2 = (float)x2 / W;
	yy2 = (float)y2 / H;
	
	glIndexi (color); 
	
	glBegin (GL_LINES);
	  glVertex2f (xx1, yy1);
		glVertex2f (xx2, yy2);
	glEnd ();
 
  return; 
} 
/*--------------------------------YDrawRectB-----------------------------------*/ 
/*                                                                             */
/*-----------------------------------------------------------------------------*/
void 
YDrawRectB (int x, int y, int w, int h, YT_COLOR color) 
{ 
  w--; 
  h--; 
  YDrawLine (x, y, x + w, y, color); 
  YDrawLine (x, y + h, x + w, y + h, color); 
  YDrawLine (x, y + h, x, y, color); 
  YDrawLine (x + w, y, x + w, y + h, color); 
} 
/*--------------------------------YDrawRectFB----------------------------------*/ 
/*                                                                             */
/*-----------------------------------------------------------------------------*/
void 
YDrawRectFB (int x, int y, int width, int height, YT_COLOR fcolor, YT_COLOR lcolor) 
{ 
  YDrawRectF (x, y, width, height, fcolor); 
  YDrawRectB (x, y, width, height, lcolor); 

  return; 
} 
/*-------------------------------YInitCOLOR------------------------------------*/ 
/*                                                                             */
/*-----------------------------------------------------------------------------*/
void   
YInitCOLOR () 
{ 

  YT_DEFCOLOR defcolors[] = { 
    { "black",       0,   0,   0},     { "green",     0, 128,   0}, 
    { "silver",    192, 192, 192},     { "lime",      0, 255,   0},
    { "gray",      128, 128, 128},     { "olive",   128, 128,   0}, 
    { "white",     255, 255, 255},     { "yellow",  255, 255,   0}, 
    { "maroon",    128,   0,   0},     { "navy",      0,   0, 128}, 
    { "red",       255,   0,   0},     { "blue",      0,   0, 255}, 
    { "purple",    128,   0, 128},     { "teal",      0 ,128, 128}, 
    { "fuchsia",   255,   0, 255},     { "aqua",      0, 255, 255}, 
    {NULL} 
  }; 
  int  i; 
 

  for (i = 0; i<SIZE_COLER; i++) { 
    COLER(i).exist = FALSE; 
    strcpy(COLER(i).name, ""); 
  } 
  YDefColors (defcolors); 
 
  YSetColors (30, YCOLORED); 
 
	return;
}
/*--------------------------------YColor---------------------------------------*/ 
/*                                                                             */
/*-----------------------------------------------------------------------------*/
YT_COLOR YColor(char *name) 
{ 
  int i; 
 
  if ((name==NULL) || !strcmp(name,""))  
    return(CLR_NULL); 
 
  for (i = 0; i<SIZE_COLER; i++) { 
    if (COLER(i).exist == FALSE) continue; 
    if (!strcmp(name, COLER(i).name)) return(COLER(i).color); 
  } 
 
  fprintf (stderr, "Dont' find color = %s", name); 

  return(CLR_NULL); 
} 
/*--------------------------------YScale---------------------------------------*/ 
/*                                                                             */
/*-----------------------------------------------------------------------------*/
YT_COLOR YScale(int n) 
{ 
 
  return(CLR_SCALE(n)); 
 
} 
/*-------------------------------YDefColor-------------------------------------*/ 
/*                                                                             */
/*-----------------------------------------------------------------------------*/
void 
YDefColor (YT_BOOL flag_add, int r, int g, int b, char *name) 
{ 
  YT_BOOL find = FALSE; 
  int i; 
 
  for (i=0; i<SIZE_COLER; i++) { 
    if (COLER(i).exist == FALSE) continue; 
/*     if (YStrCmp(name, COLER(i).name)) {find=TRUE; break;} */ 
    if (!strcmp(name, COLER(i).name)) {find=TRUE; break;} 
  } 
 
  if (!find) { 
    for (i=0; i<SIZE_COLER; i++) { 
      if (COLER(i).exist == FALSE) {find=TRUE; break;} 
    } 
  } 
  if (!find) return; 
 
  COLER(i).exist = TRUE; 
  strcpy(COLER(i).name, name); 
  COLER(i).r = r; 
  COLER(i).g = g; 
  COLER(i).b = b; 
 
  flag_add++; 
  return; 
} 
/*-------------------------------YDefColors------------------------------------*/ 
/*                                                                             */
/*-----------------------------------------------------------------------------*/
void 
YDefColors (YT_DEFCOLOR *df) 
{ 
 
  for ( ; df->name != NULL; df++)  
    YDefColor (TRUE, df->r, df->g, df->b, df->name); 
   
  return; 
} 
/*-------------------------------YSetColors------------------------------------*/ 
/*                                                                             */
/*-----------------------------------------------------------------------------*/
void 
YSetColors (int size_scale, int type_scale) 
{ 

  YSetColler (); 

  YSetScale (size_scale, type_scale); 
 
 return; 
} 
/*--------------------------------YSetColler-----------------------------------*/ 
/*                                                                             */
/*-----------------------------------------------------------------------------*/
void 
YSetColler () 
{ 
  int i; 
 
  for (i=0; i<SIZE_COLER; i++) { 
    if (COLER(i).exist == FALSE) continue; 
    COLER (i).color = YSetRgbPalette (i,  COLER (i).r, COLER (i).g, COLER (i).b); 
  } 
 
} 
/*-------------------------------YSetScale-------------------------------------*/ 
/*                                                                             */
/*-----------------------------------------------------------------------------*/
void 
YSetScale (int size, int type) 
{ 
  int     i; 
  int     r, g, b; 
 
  YSetDEFPALETE (type, size); 
 
  SIZE_SCALE = size; 

  for (i = 0; i < SIZE_SCALE; i++) { 
    YGetDEFPALETE (i, &r, &g, &b); 
    CLR_SCALE (i) = YSetRgbPalette (i+SIZE_COLER, r, g, b); 
  } 
 
	return;
}
/*--------------------------------YGetColorNear--------------------------------*/ 
/*                                                                             */
/*-----------------------------------------------------------------------------*/
YT_COLOR 
YGetColorNear (GLfloat r0, GLfloat g0, GLfloat b0)
{
	YT_COLOR  color;
	int i, size;
	double len, len_min;
	GLfloat r, g, b;

	size = glutGet (GLUT_WINDOW_COLORMAP_SIZE);
	len_min = YMAXSPACE;

	for (i=0; i < size; i++) {
		r = glutGetColor(i, GLUT_RED);
		g = glutGetColor(i, GLUT_GREEN);
    b = glutGetColor(i, GLUT_BLUE);

		len = sqrt ((r-r0)*(r-r0) + (g-g0)*(g-g0)+ (b-b0)*(b-b0));

		if (len < len_min) {
			len_min = len;
			color = i;
		}
	}
 
	return (color);
}
/*--------------------------------YSetRgbPalette-------------------------------*/ 
/*                                                                             */
/*-----------------------------------------------------------------------------*/
YT_COLOR 
YSetRgbPalette (int index, int red, int green, int blue) 
{ 
	YT_COLOR  color;
	GLfloat r, g, b;
	int base = 200;

	r = red/255.0;
	g = green/255.0;
	b = blue/255.0;

	color = base + index;
	glutSetColor (color, r, g, b);

	//color = YGetColorNear (r, g, b);
	// Для этого окна еще не установлена палитра!!

	return (color);
} 
/*------------------------------YSetDEFPALETE----------------------------------*/ 
/*                                                                             */
/*-----------------------------------------------------------------------------*/
void 
YSetDEFPALETE (int type, int size) 
{ 
  //YT_DEFPALETE *pdef, *p = &(KERN_S->ds); 
  YT_DEFPALETE *pdef, *p = &(DEFPALETTE); 

 
  YT_DEFPALETE colored = 
  {0, 0, 
   {0, 85, 170, 255}, 
   {0, 0, 255, 255}, 
   {0, 255, 255, 0}, 
   {255, 255, 0, 0}}; 
 
  YT_DEFPALETE grayed = 
  {0, 0, 
   {0, 85, 170, 255}, 
   {70, 150, 200, 255}, 
   {70, 150, 200, 255}, 
   {70, 150, 200, 255}}; 
 
  YT_DEFPALETE inverse = 
  {0, 0, 
   {0, 85, 170, 255}, 
   {255, 255, 0, 0}, 
   {0, 255, 255, 0}, 
   {0, 0, 255, 255}}; 
 
  if      (type == YGRAYED)   pdef = &grayed; 
  else if (type == YCOLORED)  pdef = &colored; 
  else if (type == YINVERSE)  pdef = &inverse; 
  else 
    YERROR ("type_scale"); 
 
  *p = *pdef; 
  p->type = type; 
  p->size = size; 
 
  return; 
} 
/*------------------------------YGetDEFPALETE----------------------------------*/ 
/*                                                                             */
/*-----------------------------------------------------------------------------*/
void 
YGetDEFPALETE (int i, int *r, int *g, int *b) 
{ 
  float   step_index; 
  int     index, j; 
  float   d; 
  //YT_DEFPALETE *p = &(KERN_S->ds); 
  YT_DEFPALETE *p = &(DEFPALETTE); 
 
  step_index = (float) 255 / (p->size); 
  index = (int) (step_index * i); 
 
  for (j = 0; p->kp[j + 1] <= index; j++) ;; 
 
  d = (float) (index - p->kp[j]) / (p->kp[j + 1] - p->kp[j]); 
  *r = (int) (p->rr[j] + d * (p->rr[j + 1] - p->rr[j])); 
  *g = (int) (p->gg[j] + d * (p->gg[j + 1] - p->gg[j])); 
  *b = (int) (p->bb[j] + d * (p->bb[j + 1] - p->bb[j])); 
 
} 
/*-----------------------------YColorToScale-----------------------------------*/ 
/*                                                                             */
/*-----------------------------------------------------------------------------*/
int 
YColorToScale (YT_COLOR color) 
{ 
  int     i; 
 
  for (i = 0; i < SIZE_SCALE; i++) 
    if (CLR_SCALE (i) == color) 
      return (i); 
 
  return (SIZE_SCALE / 2); 
} 
/*-------------------------------YColorToRGB-----------------------------------*/ 
/*                                                                             */
/*-----------------------------------------------------------------------------*/
void 
YColorToRGB (YT_COLOR color, int *r, int *g, int *b) 
{ 
  int     i; 
  YT_COLER *clr = &COLER (0); 
 
  for (i = 0; i < SIZE_COLER; i++) { 
    if (COLER(i).exist == FALSE) continue; 
    if ((clr + i)->color != color) 
      continue; 
    *r = (clr + i)->r; 
    *g = (clr + i)->g; 
    *b = (clr + i)->b; 
    return; 
  } 
 
  for (i = 0; i < SIZE_SCALE; i++) { 
    if (CLR_SCALE (i) != color) 
      continue; 
    YGetDEFPALETE (i, r, g, b); 
  } 
 
} 
/*----------------------------------YColer-------------------------------------*/ 
/*                                                                             */
/*-----------------------------------------------------------------------------*/
YT_COLOR 
YColer (int n) 
{ 
  if   ((n>=SIZE_COLER) || !(COLER(n).exist))  
    return (CLR_NULL); 
 
  return (COLER(n).color); 
} 
/*--------------------------------YDrawScale-----------------------------------*/ 
/*                                                                             */
/*-----------------------------------------------------------------------------*/
void 
YDrawScale (int xx, int yy, int ww, int hh, int style) 
{ 
  int     i, beg, end, size, beg0; 
  float   step; 
  int     itemp; 
  int     isize; 
  YT_COLOR color; 
  int     xx_old = xx, yy_old = yy, ww_old = ww, hh_old = hh; 
 
  isize = SIZE_SCALE/*  = 30 */; 
 
  if (style == YHORZ) { 
    itemp = xx;  xx = yy;  yy = itemp; 
    itemp = ww;  ww = hh;  hh = itemp; 
  } 
 
  step = (float) hh / isize; 
  beg = beg0 = yy; 
  for (i = 1; i <= isize; i++) { 
    end = beg0 + YInt (step * i); 
    size = end - beg + 1; 
    color = CLR_SCALE (isize - i); 

    if (style == YHORZ)  YDrawRectF (beg, xx, size, ww, color); 
    else                 YDrawRectF (xx, beg, ww, size, color); 

    beg = end; 
  } 
 
  YDrawRectB (xx_old, yy_old, ww_old, hh_old, YColor("black")); 
 
  return; 
} 
/*----------------------------D3_SetRotate-------------------------------------*/
/*                                                                             */
/*-----------------------------------------------------------------------------*/
D3_SetRotate (int alfa, int beta)
{

  glMatrixMode (GL_MODELVIEW);	
  glLoadIdentity ();
  glRotatef (alfa, 1, 0, 0);
  glRotatef (beta, 0, 1, 0);

}
/*-----------------------------D3_Perspectiv-----------------------------------*/
/*                                                                             */
/*-----------------------------------------------------------------------------*/
D3_Perspective (float eyez, float x0, float y0, float w, float h,
                float z_near, float z_far)
{
  float left, top, right, bottom, near, far;
  
  glMatrixMode (GL_MODELVIEW);	
  glLoadIdentity ();
  glTranslatef (0, 0, eyez);

  left   = x0 - w/2;
  top    = y0 + h/2;
  right  = x0 + w/2;
  bottom = y0 - h/2; 
  near = fabs (eyez - z_near);
  far  = fabs (eyez - z_far);

  glMatrixMode (GL_PROJECTION);	
  glLoadIdentity ();
  glFrustum (left, right, bottom, top, near, far);


}
/*------------------------------D3_Orthographic--------------------------------*/
/*                                                                             */
/*-----------------------------------------------------------------------------*/
D3_Orthographic (float eyez, float x0, float y0, float w, float h, float z_near, float z_far)
{
  float  left, top, right, bottom, near, far;

  /*glMatrixMode (GL_MODELVIEW);	
  glLoadIdentity ();
  glTranslatef (0, 0, eyez);*/

  left   = x0 - w/2;
  top    = y0 + h/2;
  right  = x0 + w/2;
  bottom = y0 - h/2; 

  glMatrixMode (GL_PROJECTION);	
  glLoadIdentity ();
  glOrtho (left, right, bottom, top, z_near, z_far);
    
  glDepthRange (z_near, z_far);

}  
/*---------------------------------YMaping-------------------------------------*/
/*                                                                             */
/*-----------------------------------------------------------------------------*/
void
YMaping (YT_SPACE hmin, YT_SPACE hmax, int xrel, int yrel, 
	 YT_SPACE *px, int *py, YT_BOOL direct)
{
  YT_SPACE x0, x;
  int      y0, y;
	int size_scale = SIZE_SCALE /*  20 */;
	YT_SPACE lin;

  x0 = hmin + (hmax - hmin) * xrel / 100.0;
  y0 = (int)(1 + (size_scale - 1) * yrel / 100.0);

  if (direct) {         
    x = *px;
    if (x < x0)  {
			lin = YLINER (x, hmin, 1, x0, y0);
			y = YInt (lin);
			//printf ("%f %d \n", lin, y);
			//printf ("%.1f %.1f %.1f %.1f  %ld %ld \n", lin, hmin, x0, x,  y0, y);
		}
    else         y = YInt (YLINER (x, x0, y0, hmax, size_scale));

    *py = y;

  } else {
    y = *py;
    if (y < y0)  x = YLINER (y, 1, hmin, y0, x0);
    else         x = YLINER (y, y0, x0, size_scale, hmax); 
    *px = x;
  }

  return;
}
/*------------------------------YCreateWindow----------------------------------*/
/*                                                                             */
/*-----------------------------------------------------------------------------*/
int
YCreateWindow (int argc, char** argv, char *title, int x, int y, int w, int h)
{
	int wnd;
	W = w; H = h;
	glutInit (&argc, argv);
	glutInitDisplayMode (GLUT_DOUBLE | GLUT_INDEX | GLUT_DEPTH);
	
	glutInitWindowSize (W, H); 
	glutInitWindowPosition (x, y);
	
	wnd = glutCreateWindow (title);

  YInitCOLOR ();                                                                 

	return (wnd);
}
/*******************************************************************************/
/*-----------------------------------------------------------------------------*/
/*                                                                             */
/*                               M A I N . C                                   */
/*                                                                             */
/*-----------------------------------------------------------------------------*/ 


/*******************************************************************************/
/*------------------------------------proc01-----------------------------------*/
/*  Простейшая парабола                                                        */
/*-----------------------------------------------------------------------------*/
double
proc01 (PROC_VAR)
{
  static YT_MINPROC *minproc;
	int    i, d;
	double s, sum;

	minproc = (YT_MINPROC *)ptr;  //???

  switch (message) {
  case YMAIN:
		minproc = minproc_init (proc01, 0, 0);
		DIM  = 1;
		minproc_set (minproc, -2.0, 2.0,  0.1);

		NUM_BEG = 1; // одно начальное приближение
		for (i=0; i<DIM; i++)  
			minproc->xyz_beg[0][i] = 1.0;

		minproc->gslspusk = minproc_gslspusk_set (
				 TRUE, 0.000001, 
				 //gsl_multimin_fdfminimizer_conjugate_fr,
			   gsl_multimin_fdfminimizer_vector_bfgs,
				 0.01,   // размер первого пробного шага
				 0.01,   // точность линейной минимизации
				 0.01,   // критерий останова (норма градиента)
				 500,   // критерий останова (максимум итераций)
				 0.01    // критерий останова ()
		);
		minproc_tests (minproc, POWER_DEF, 2);
    break;
  case YINIT:
    NAME = "x1^2+x2^2+...";

    break;
  case YTRUE:
    NUM_END = 1;
    for (d=0; d < DIM; d++)
      XYZ_END[0][d] = 0;

    break;
  case YCALC:
		sum = 0;
		for (i=1; i <= DIM; i++) {
			s = XN(i);
			sum += s*s;
		}
    return (sum);
  }

	RETURN;
}
/*----------------------------------proc02-------------------------------------*/
/*  Сложная синусоида                                                          */
/*-----------------------------------------------------------------------------*/
double
proc02 (PROC_VAR)
{
  YT_MINPROC *minproc;

	minproc = (YT_MINPROC *)ptr;

  switch (message) {
  case YMAIN:
		minproc = minproc_init (proc02, 0, 0);
		DIM = 1;

		//	minproc_set (minproc, -10, +10,  0.1); вправо уходит вниз!!!
		minproc_set (minproc, -10.0, +7.0,  0.1);

		minproc_tests (minproc, POWER_DEF, POWER_DEF);
    break;
  case YINIT:
    NAME = "sin(x)*x^2";

    break;
  case YCALC:
    return (sin(XN(1)) * XN(1)*XN(1));

  case YTRUE:
    NUM_END = 1;
		XYZ_END[0][0] = -8.1; //f= -63.63
    break;
  default:
		;;;;;;;;;;;;;;;;;;;;;
  }

	RETURN;
}
/*----------------------------------proc03-------------------------------------*/
/*  Функция Розенброка N-го порядка                                            */
/*  В 2-d случае это функция "Банана"                                          */
/*-----------------------------------------------------------------------------*/
double
proc03 (PROC_VAR)
{
  static YT_MINPROC *minproc;
	int    i, d;
	double s, sum, koef_100;

	minproc = (YT_MINPROC *)ptr;

  switch (message) {
  case YMAIN:
		minproc = minproc_init (proc03, 0, 0);

		DIM  = 2; // порядок функции
		minproc_set (minproc, 0.0, 24.0,  0.1);

		NUM_BEG = 1; // одно начальное приближение
		for (i=0; i < DIM; i++)
			XYZ_BEG[0][i] = 0.7;

		minproc_tests (minproc, POWER_DEF, 2);
    break;
  case YINIT:
    NAME = "Rozenbrok";

    break;
  case YTRUE:
    NUM_END = 1;
    for (d=0; d < DIM; d++) {
      XYZ_END[0][d] = 1;
    }

    break;
  case YCALC:
		sum = 0;
		for (i=2; i<=DIM; i++) {
			s = XN(i) - XN(i-1);
			sum += s*s;
		}

		koef_100 = 100;
    return (koef_100*sum + (1-XN(1))*(1-XN(1)));
  }

	RETURN;
}
/*-----------------------------------proc04------------------------------------*/
/*  Функция Пауэла                                                             */
/*-----------------------------------------------------------------------------*/ 
double
proc04 (PROC_VAR)
{
  YT_MINPROC *minproc;
	double s1, s2, s3, s4, sum;
	int    /* i, */ d;

	minproc = (YT_MINPROC *)ptr;

  switch (message) {
  case YMAIN:
		//proc04_main();

		minproc = minproc_init (proc04, 0, 0);

		DIM = 4;
		minproc_set (minproc, /* 5, */ -2.0, 2.0, 1.0);

		minproc_tests (minproc, POWER_DEF, POWER_DEF);

    break;
  case YINIT:
    minproc = (YT_MINPROC *)ptr;
    NAME = "Powell";

    break;
  case YCALC:
		s1 = XN(1)+10*XN(2);
		s2 = XN(3)-XN(4);
		s3 = XN(2)-2*XN(3);
		s4 = XN(1)-XN(4);

		sum = s1*s1 + 5*s2*s2 + s3*s3*s3*s3 + 10*s4*s4*s4*s4;

    return (sum);
  case YTRUE:
    NUM_END = 1;
    for (d=0; d < DIM; d++) {
      XYZ_END[0][d] = 0;
    }

    break;
  default:
		;;;
  }

	RETURN;
}
/*------------------------------------proc05-----------------------------------*/
/*  Пример из библиотеки GSL                                                   */
/*-----------------------------------------------------------------------------*/
double
proc05 (PROC_VAR)
{
	

  static YT_MINPROC *minproc;
	int    i, d;
	double s, sum;
	double x0=1, y0=2, x, y;
  /* Position of the minimum (1,2). */

	minproc = (YT_MINPROC *)ptr;  //???

  switch (message) {
  case YMAIN:
		minproc = minproc_init (proc05/*!!!*/, 0, 0);

		DIM  = 2;
		minproc_set (minproc, -10.0, 10.0,  0.1);

		NUM_BEG = 1;
	 	XYZ_BEG[0][0] = 5.0;
	 	XYZ_BEG[0][1] = 7.0;

		//*((YT_MINPROC **)ptr) = minproc;
		minproc_tests (minproc, POWER_DEF, POWER_DEF);

    break;
  case YINIT:
    NAME = "SGL-func";

    break;
  case YTRUE:
    NUM_END = 1;
		XYZ_END[0][0] = 1.0;
		XYZ_END[0][1] = 2.0;
		FUN_END = 30.0;
    break;
  case YCALC:
		x = XN(1);
		y = XN(2);

    return (10.0 * (x - x0) * (x - x0) +
						20.0 * (y - y0) * (y - y0) + 30.0);
  default: ;;
  }

	RETURN;
}
/*--------------------------------main_proc------------------------------------*/
/*                                                                             */
/*-----------------------------------------------------------------------------*/
void
main_proc ()
{

	proc01 (YMAIN, 0, 0, 0, 0, 0); // Простейшая парабола
	proc02 (YMAIN, 0, 0, 0, 0, 0); // Сложная синусоида
	proc03 (YMAIN, 0, 0, 0, 0, 0); // Функция Розенброка
	proc04 (YMAIN, 0, 0, 0, 0, 0); // Функция Пауэла
	proc05 (YMAIN, 0, 0, 0, 0, 0); // Пример из библиотеки GSL    

	printf ("\n");
	return;
}
/*---------------------------------check_inf_nan-------------------------------*/
/*                                                                             */
/*-----------------------------------------------------------------------------*/
void
check_inf_nan (double val)
{
	char buff[80];

	sprintf (buff, "%f", val);
	if ((strcmp(buff,"inf")==0) || (strcmp(buff,"-inf")==0) || (strcmp(buff,"nan")==0))
		Error (buff);

	return;
}
/*----------------------------------test_fpe-----------------------------------*/
/*                                                                             */
/*-----------------------------------------------------------------------------*/
void
test_fpe ()
{
 unsigned short mode = 0 ;                                                     
	double d_val;
	char buff[80];

	// Почему не вырабатывается сигнал SIGFPE ?????????????????
	// man strace,signal,... 
	// Ниже опции из файла : fpu_control.h

	//_FPU_GETCW(mode);
	//mode |= _FPU_SINGLE ;                                                 
	//mode |= _FPU_DOUBLE ;                                                 
	//mode |= _FPU_EXTENDED ; 
	//mode |= _FPU_MASK_ZM;                                                 
  //_FPU_SETCW(mode) ;                                                            
  //_FPU_SETCW(0x1372);                                                            
  //_FPU_SETCW(_FPU_DEFAULT);                                                            

	
	// GSL_IEEE_MODE=double-precision
	// Читается переменная окружения и устанавливаются значения
	//gsl_ieee_env_setup ();

	//d_val = 10.0 / 0;

	//d_val = YMAXDOUBLE * 1.1;
	//strcpy ((char*)(&d_val), "=-t\t999999\n=-");

	check_inf_nan (d_val);
	fprintf (stderr, "d_val = %f \n", d_val);

	return;
}
/*------------------------------test_siman_misc--------------------------------*/
/*                                                                             */
/*-----------------------------------------------------------------------------*/

/* set up parameters for this simulated annealing run */
#define N_TRIES   200		   /* how many points do we try before stepping */
#define ITERS_FIXED_T 1000 /* how many iterations for each T? */
#define STEP_SIZE 1.0		   /* max step size in random walk */
#define K         1.0			 /* Boltzmann constant */
#define T_INITIAL 0.008		 /* initial temperature */
#define MU_T      1.003		 /* damping factor for temperature */
#define T_MIN     2.0e-6

gsl_siman_params_t params = {N_TRIES, ITERS_FIXED_T, STEP_SIZE,
			     K, T_INITIAL, MU_T, T_MIN};

inline double square (double x) ;
inline double square (double x) { return x * x ; }

/* now some functions to test in one dimension */
double E1 (void *xp)
{
  double x = *((double*) xp);

  return exp(-square(x-1))*sin(8*x) - exp(-square(x-1000))*0.89;
}
//--------------------------
double M1 (void *xp, void *yp)
{
  double x = *((double*) xp);
  double y = *((double*) yp);

  return fabs(x - y);
}
//--------------------------
void S1 (const gsl_rng *r, void *xp, double step_size)
{
  double old_x = *((double*) xp);
  double new_x;

  new_x = gsl_rng_uniform(r) * 2*step_size - step_size + old_x;

  memcpy (xp, &new_x, sizeof(new_x));
}
/*--------------------------test_siman-----------------------------------------*/
/*                                                                             */
/*-----------------------------------------------------------------------------*/
void
test_siman ()
{

  double x_min = 1.36312999455315182;
  double x;

  gsl_rng * r = gsl_rng_alloc (gsl_rng_env_setup());
  gsl_ieee_env_setup ();

  x = +0.6 ;
  //gsl_siman_solve (r, &x, E1, S1, M1, NULL,NULL,NULL,NULL, sizeof(double), params);

  printf ("\n");
  gsl_test_rel (x, x_min, 1e-3, "f(x)= exp(-(x-1)^2) sin(8x), x0=0.6");
  printf ("\n");

	return;
}
/*-----------------------------------------------------------------------------*/
/*                                                                             */
/*-----------------------------------------------------------------------------*/
void 
init_2 ()
{


}
/*-----------------------------------------------------------------------------*/
/*                                                                             */
/*-----------------------------------------------------------------------------*/
void
draw_item ()
{
  int xrel=60, yrel=40;
  int xi, yi, fi;
  int  x0, y0, w, h, i=0, j=0, cellh;
  YT_COLOR color;
  YT_SPACE hmin, hmax;
  YT_SPACE hh;
  YT_SPACE x, y;

	x0=20; y0=50; w=60; h=60;
	
	YDrawRectB (x0, y0, w, h, YColor("black"));
	
	hmin = YMAXSPACE; hmax = YMINSPACE;
	for (i=0; i<w-2; i+=2) 
  for (j=0; j<h-2; j+=2) {
		x = i; y = j;
		hh = (x*x + y*y);
		if      (hh < hmin)  hmin = hh;
		else if (hh > hmax)  hmax = hh;
	}
	
	for (i=0; i<w-2; i+=2) 
  for (j=0; j<h-2; j+=2) {
		x = i; y = j;
		hh = (x*x + y*y);
		
		YMaping (hmin, hmax, xrel, yrel, &hh, &cellh, TRUE);

		color = YScale (cellh-1);
		//color = i+j;
		
		YDrawRectF (x0+1+i, y0+1+j, 2, 2, color);
	}
	
		return;
}
/*-----------------------------------------------------------------------------*/
/*                                                                             */
/*-----------------------------------------------------------------------------*/
void
test_picture ()
{

  YDrawRectF (40,20,  80,90, YColor("white"));

  YDrawRectFB(60,80,  80,90, YColor("aqua"), YColor("black"));
  YDrawLine  (10,10, 110,110,YColor("black"));
  YDrawLine  (5,100, 160,10, YColor("white"));
  YDrawRectFB(60,70,  70,40, YColor("silver"), YColor("white"));
  YDrawRectF (110,40, 60,80, YColor("red"));
  YDrawRectF (10,100, 90,50, YColor("fuchsia"));
  YDrawString("This is test", 20,60, YColor("black"));  
  YDrawLine  (25,25, 160,150, YColor("blue"));
  YDrawLine  (25,25, 160,152, YColor("blue"));
  YDrawLine  (25,25, 160,154, YColor("blue"));
  YDrawLine  (25,25, 160,156, YColor("blue"));

	YDrawScale (10, 10, 175, 20, YHORZ); 

	draw_item ();

  return;
}
/*-----------------------------------------------------------------------------*/
/*                                                                             */
/*-----------------------------------------------------------------------------*/
void 
display_1 (void)
{
  static void *meta = NULL;

	glClear (GL_COLOR_BUFFER_BIT);
	YDrawRectF (0, 0, W, H, YColor("yellow"));

	test_picture ();

	glFlush ();
  glutSwapBuffers(); 

	return;
}
/*-----------------------------------------------------------------------------*/
/*                                                                             */
/*-----------------------------------------------------------------------------*/
void
main_ogl_test1 (int argc, char** argv)
{

  YCreateWindow (argc, argv, "Hello Test1!", 100, 300, 450, 250);

  //OUTD (glutLayerGet(GLUT_OVERLAY_POSSIBLE));
  //OUTD (glutLayerGet(GLUT_TRANSPARENT_INDEX));                         
 	
  glMatrixMode (GL_PROJECTION);
  glLoadIdentity ();
  glOrtho (0.0, 1.0, 0.0, 1.0, -1.0, 1.0);

  glutDisplayFunc (display_1); 
	
  glutMainLoop ();

	return;
}
/*-----------------------------------------------------------------------------*/
/*-----------------------------------------------------------------------------*/
/*-----------------------------------------------------------------------------*/
/*                                                                             */
/*-----------------------------------------------------------------------------*/
void 
main_ogl_test2 (void)
{

  glClear (GL_COLOR_BUFFER_BIT);

  glIndexi (YColor("red")); 
  glBegin (GL_LINES);
  glVertex3f (0.0, 0.0, 0.0);
  glVertex3f (1.0, 0.0, 0.0);
  glEnd ();

  glIndexi (YColor("green")); 
  glBegin (GL_LINES);
  glVertex3f (0.0, 0.0, 0.0);
  glVertex3f (0.0, 1.0, 0.0);
  glEnd ();
  
  glIndexi (YColor("blue")); 
  glBegin (GL_LINES);
  glVertex3f (0.0, 0.0, 0.0);
  glVertex3f (0.0, 0.0, 1.0);
  glEnd ();

  glIndexi (YColor("aqua")); 
  glBegin (GL_POLYGON);
  glVertex3f (1.0, 0.0, 0.0);
  glVertex3f (0.0, 1.0, 0.0);
  glVertex3f (0.0, 0.0, 1.0);
  glEnd ();
  
  glFlush ();
  glutSwapBuffers (); 

  return;
}         
/*-----------------------------------------------------------------------------*/
/*                                                                             */
/*-----------------------------------------------------------------------------*/
void 
draw_cube (double siz, YT_COLOR color)
{

	glIndexi (color); 

  glBegin (GL_LINE_LOOP);
	  glVertex3f (-siz, -siz, -siz);
	  glVertex3f (+siz, -siz, -siz);
	  glVertex3f (+siz, -siz, +siz);
	  glVertex3f (-siz, -siz, +siz);
  glEnd ();

  glBegin (GL_LINE_LOOP);
	  glVertex3f (-siz, +siz, -siz);
	  glVertex3f (+siz, +siz, -siz);
	  glVertex3f (+siz, +siz, +siz);
	  glVertex3f (-siz, +siz, +siz);
  glEnd ();

  glBegin (GL_LINES);
	  glVertex3f (-siz, -siz, -siz);
	  glVertex3f (-siz, +siz, -siz);

	  glVertex3f (+siz, -siz, -siz);
	  glVertex3f (+siz, +siz, -siz);

	  glVertex3f (+siz, -siz, +siz);
	  glVertex3f (+siz, +siz, +siz);

	  glVertex3f (-siz, -siz, +siz);
	  glVertex3f (-siz, +siz, +siz);
  glEnd ();

  
	return;
}         
/*-----------------------------------------------------------------------------*/
/*                                                                             */
/*-----------------------------------------------------------------------------*/
void 
draw_axes (void)
{

	glIndexi (YColor("red")); 
  glBegin (GL_LINES);
	  glVertex3f (0, 0, 0);
	  glVertex3f (2, 0, 0);
  glEnd ();

	glIndexi (YColor("green")); 
  glBegin (GL_LINES);
	  glVertex3f (0, 0, 0);
	  glVertex3f (0, 2, 0);
  glEnd ();

	glIndexi (YColor("blue")); 
  glBegin (GL_LINES);
	  glVertex3f (0, 0, 0);
	  glVertex3f (0, 0, 2);
  glEnd ();

}
/*-----------------------------------------------------------------------------*/
/*                                                                             */
/*-----------------------------------------------------------------------------*/
void
clo_draw (YT_CLOTH *clo)
{
	int i, j;

	glIndexi (YColor("red")); 
  glBegin (GL_LINES);

	for (i=0; i < clo->ii; i++) 
	for (j=0; j < clo->jj; j++) {
		if (i != clo->ii-1) {
	  glVertex3f (CLOX(clo,i,j),   CLOY(clo,i,j),   CLOZ(clo,i,j));
	  glVertex3f (CLOX(clo,i+1,j), CLOY(clo,i+1,j), CLOZ(clo,i+1,j));
		}

		if (j != clo->jj-1) {
	  glVertex3f (CLOX(clo,i,j),   CLOY(clo,i,j),   CLOZ(clo,i,j));
	  glVertex3f (CLOX(clo,i,j+1), CLOY(clo,i,j+1), CLOZ(clo,i,j+1));
		}
	}

  glEnd ();
	return;
}
/*-----------------------------------------------------------------------------*/
/*                                                                             */
/*-----------------------------------------------------------------------------*/
void
draw_all (double siz)
{
	//double siz;

	//draw_axes ();

	draw_cube (siz, YColor("black"));

	glIndexi (YColor("aqua")); 
  glBegin (GL_POLYGON);
	  glVertex3f (-siz, -siz, -siz);
	  glVertex3f (+siz, -siz, -siz);
	  glVertex3f (+siz, -siz, +siz);
	  glVertex3f (-siz, -siz, +siz);
  glEnd ();
  
	clo_draw (clo);

	return;
}
/*-----------------------------------------------------------------------------*/
/*                                                                             */
/*-----------------------------------------------------------------------------*/
static GLuint
make_all ()
{

  static GLuint list;                                                                  

  list = glGenLists (1);                                                         
  glNewList (list, GL_COMPILE);                                                  

	draw_all (siz);

  glEndList ();                                                                  
                                                                                
  return list;                                                                  
}
/*-----------------------------------------------------------------------------*/
/*                                                                             */
/*-----------------------------------------------------------------------------*/
void 
display (void)
{

  /* Clear depth and color buffer. */
  glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

  glPushMatrix();

	/* Perform scene rotations based on user mouse input. */
	glRotatef(angle_x, 1.0, 0.0, 0.0);
	glRotatef(angle_y, 0.0, 1.0, 0.0);

	draw_all (siz);
  //glCallList (All);                                                             

  glPopMatrix();
	//glFlush ();
  glutSwapBuffers (); 

	return;
}         
/*-----------------------------------------------------------------------------*/
/*                                                                             */
/*-----------------------------------------------------------------------------*/
static void
mouse (int button, int state, int x, int y)
{

	//OUTD (x);
  /* Rotate the scene with the left mouse button. */

  if (button == GLUT_LEFT_BUTTON) {
    if (state == GLUT_DOWN) {
      moving = 1;
      startx = x;
      starty = y;
    }
    if (state == GLUT_UP) {
      moving = 0;
    }
  }

  if (button == GLUT_MIDDLE_BUTTON) {
    if (state == GLUT_DOWN) printf ("MIDDLE_BUTTON_DOWN \n");
    if (state == GLUT_UP)   printf ("MIDDLE_BUTTON_UP \n");
  }

	return;
}
/*-----------------------------------------------------------------------------*/
/*                                                                             */
/*-----------------------------------------------------------------------------*/
static void
motion (int x, int y)
{

	//OUTD (x);
  if (moving) {
    angle_y = angle_y + (x - startx);
    angle_x = angle_x + (y - starty);
    startx = x;
    starty = y;

    glutPostRedisplay();
  }

	return;
}
/*-----------------------------------------------------------------------------*/
/*                                                                             */
/*-----------------------------------------------------------------------------*/
void
clo_rand_noice (YT_CLOTH *clo)
{
	int i, j;

	for (i=0; i < clo->ii; i++) 
	for (j=0; j < clo->jj; j++) {
		CLOX(clo,i,j) += YRandF (-0.01, +0.01);
		CLOY(clo,i,j) += YRandF (-0.01, +0.01);
		CLOZ(clo,i,j) += YRandF (-0.001, +0.001);
	}

	return;
}
/*-----------------------------------------------------------------------------*/
/*                                                                             */
/*-----------------------------------------------------------------------------*/
static void
keyboard (unsigned char c, int x, int y)
{
  switch (c) {
  case 27:  /* Escape quits. */
    exit (0);
    break;
	default:
		printf ("Keyboard: %c \n", c);
  }
}
/*-----------------------------------------------------------------------------*/
/*                                                                             */
/*-----------------------------------------------------------------------------*/
void
menu (int value)
{
  switch (value) {
  case M_ITEM1:
    OUTD (1);
    break;
  case M_ITEM2:
    OUTD (2);
    break;
  case M_EXIT:
    exit (0);
    break;
  }

  //glutPostRedisplay();
}
/*-----------------------------------------------------------------------------*/
/*                                                                             */
/*-----------------------------------------------------------------------------*/
void
clo_swap (YT_CLOTH *clo)
{

	if      (clo->s == clo->array1) {/* OUTD (111); */ clo->s = clo->array2; clo->t = clo->array1;}
	else if (clo->s == clo->array2) {/* OUTD (222); */ clo->s = clo->array1; clo->t = clo->array2;} 
	else Error ("clo_swap");

	return;
}
/*-----------------------------------------------------------------------------*/
/*                                                                             */
/*-----------------------------------------------------------------------------*/
YT_CLOTH*
clo_create (int ii, int jj)
{
	YT_CLOTH *clo;
	int i, j, loop;
	tParticle *t, *s; // target, source

	YMALLOC (clo, YT_CLOTH, 1);
	clo->ii = ii;
	clo->jj = jj;
	clo->m_ParticleCnt = ii*jj;

	YMALLOC (clo->array1, tParticle, clo->m_ParticleCnt);
	YMALLOC (clo->array2, tParticle, clo->m_ParticleCnt);

	clo->s = clo->array1;
	clo->t = clo->array2;

	for (loop=0; loop < clo->m_ParticleCnt; loop++) {
		s = clo->s + loop;
		s->pos.x = s->v.x = s->f.x = 0.0; 
		s->pos.y = s->v.y = s->f.y = 0.0; 
		s->pos.z = s->v.z = s->f.z = 0.0; 
		s->oneOverM = 1.0;
	}

	// временные массивы для пошагового интегрирования
	for (i = 0; i < 5; i++) {
		//m_TempSys[i] = NULL; 
		YMALLOC (m_TempSys[i], tParticle, clo->m_ParticleCnt);
	}

	return (clo);
}
/*-----------------------------------------------------------------------------*/
/*                                                                             */
/*-----------------------------------------------------------------------------*/
void
clo_set_vert (YT_CLOTH *clo, double x, double y, double w, double h)
{
	int i, j;
	double size_i, size_j;

	clo->size_i = size_i = h / (clo->ii-1);
	clo->size_j = size_j = w / (clo->jj-1);

	for (i=0; i < clo->ii; i++) 
	for (j=0; j < clo->jj; j++) {
		CLOX(clo,i,j) = x + j*size_j;
		CLOY(clo,i,j) = y - i*size_i;
		CLOZ(clo,i,j) = 0.0;
	}

	CLOP(clo,0,0)->oneOverM = 0.0;
	CLOP(clo,0,clo->jj-1)->oneOverM = 0.0;

	return;
}
/*-----------------------------------------------------------------------------*/
/*                                                                             */
/*-----------------------------------------------------------------------------*/
void
clo_calc_springs (YT_CLOTH *clo, tParticle *p1, tParticle *p2, 
									float Ks, float Kd, float	restLen)
{

	float		dist, Hterm, Dterm; 
	tVector	F /* springForce */, deltaV, deltaP; 

/* 	VectorDifference (&(p1->pos), &(p2->pos), &F); */
/* 	dist = VectorLength (&F);	 */
/* 	ScaleVector (&F, (dist-restLen), &F);	 */

/* 	VectorSum (&(p2->f), &F, &(p2->f));			        */
/* 	VectorDifference (&(p1->f), &F, &(p1->f));			 */
/* 	return; */


	VectorDifference (&p1->pos, &p2->pos, &deltaP);    	 // Vector distance  
	dist = VectorLength (&deltaP);					             // Magnitude of deltaP 	

	Hterm = (dist - restLen) * Ks;	                     // Ks * (dist - rest) 

	VectorDifference (&p1->v, &p2->v, &deltaV);		       // Delta Velocity Vector 
	Dterm = (DotProduct (&deltaV, &deltaP) * Kd) / dist; // Damping Term 

	ScaleVector (&deltaP, 1.0f / dist, &F);	             // Normalize Distance Vector 
	ScaleVector (&F, -(Hterm + Dterm), &F);	             // Calc Force 

	VectorSum (&p1->f, &F, &p1->f);			                 // Apply to Particle 1 
	VectorDifference (&p2->f, &F, &p2->f);	             // - Force on Particle 2 

	//VectorSum (&(p2->f),&F, &(p2->f));			           // Apply to Particle 1 
	//VectorDifference (&(p1->f), &F, &(p1->f));	       // - Force on Particle 2 

	return;
}
/*-----------------------------------------------------------------------------*/
/*                                                                             */
/*-----------------------------------------------------------------------------*/
void 
ComputeForces (tParticle	*system) 
{ 
	int loop, i, j; 
	tParticle	*curParticle,*p1, *p2; 
	float size_shear;
	float	Ks, Kd; 
 
	curParticle = system; 
	for (loop = 0; loop < clo->m_ParticleCnt; loop++) 
	{ 
		MAKEVECTOR(curParticle->f, 0.0f,0.0f,0.0f)		// CLEAR FORCE VECTOR 
 
		if (curParticle->oneOverM != 0) 
		{ 
			curParticle->f.x += (m_Gravity.x / curParticle->oneOverM); 
			curParticle->f.y += (m_Gravity.y / curParticle->oneOverM); 
			curParticle->f.z += (m_Gravity.z / curParticle->oneOverM); 
		}
 
		curParticle->f.x += (-DEFAULT_DAMPING * curParticle->v.x); 
		curParticle->f.y += (-DEFAULT_DAMPING * curParticle->v.y); 
		curParticle->f.z += (-DEFAULT_DAMPING * curParticle->v.z); 

		curParticle++; 
	} 
 
	// STRUCTURAL springs 
	Ks = 4.0;
	Kd = 0.6;
	for (i=0; i < clo->ii; i++) 
	for (j=0; j < clo->jj; j++) {
		if (i != clo->ii-1) 
			clo_calc_springs (clo, CLOP(clo,i,j), CLOP(clo,i+1,j), Ks, Kd, clo->size_i);

		if (j != clo->jj-1) 
			clo_calc_springs (clo, CLOP(clo,i,j), CLOP(clo,i,j+1), Ks, Kd, clo->size_j);
	}

	// SHEAR springs 
	Ks = 4.0;
	Kd = 0.6;
	size_shear = sqrt (clo->size_i*clo->size_i + clo->size_j*clo->size_j);
	for (i=0; i < clo->ii-1; i++) 
	for (j=0; j < clo->jj-1; j++) {
		clo_calc_springs (clo, CLOP(clo,i,j), CLOP(clo,i+1,j+1), Ks, Kd, size_shear);
		clo_calc_springs (clo, CLOP(clo,i,j+1), CLOP(clo,i+1,j), Ks, Kd, size_shear);
	}
 
	// BEND springs 
	Ks = 2.4;
	Kd = 0.8;
	for (i=0; i < clo->ii; i++) 
	for (j=0; j < clo->jj; j++) {
		if ((i!=clo->ii-1)&&(i!=clo->ii-2)) // vertical
			clo_calc_springs (clo, CLOP(clo,i,j), CLOP(clo,i+2,j), Ks, Kd, 2*clo->size_i);

		if ((j!=clo->jj-1)&&(j!=clo->jj-2)) // gorizontal
			clo_calc_springs (clo, CLOP(clo,i,j), CLOP(clo,i,j+2), Ks, Kd, 2*clo->size_j);
	}


	return;
}    
/*-----------------------------------------------------------------------------*/
// Purpose:		Does the Integration for all the points in a system 
// Arguments:	Initial Position, Source and Target Particle Systems and Time 
// Notes:	  	Computes a single integration step 
/*-----------------------------------------------------------------------------*/
void
IntegrateSysOverTime (tParticle *initial,tParticle *source, tParticle *target, float deltaTime) 
{ 
	int loop; 
	float deltaTimeMass; 

	for (loop = 0; loop < clo->m_ParticleCnt; loop++) 
	{ 
		deltaTimeMass = deltaTime * initial->oneOverM; 

		// DETERMINE THE NEW VELOCITY FOR THE PARTICLE 
		target->v.x = initial->v.x + (source->f.x * deltaTimeMass); 
		target->v.y = initial->v.y + (source->f.y * deltaTimeMass); 
		target->v.z = initial->v.z + (source->f.z * deltaTimeMass); 
 
		target->oneOverM = initial->oneOverM; 
 
		// SET THE NEW POSITION 
		target->pos.x = initial->pos.x + (deltaTime * source->v.x); 
		target->pos.y = initial->pos.y + (deltaTime * source->v.y); 
		target->pos.z = initial->pos.z + (deltaTime * source->v.z); 
 
		initial++; 
		source++; 
		target++; 
	} 

	return;
} 
/*-----------------------------------------------------------------------------*/
// Purpose:		Calculate new Positions and Velocities given a deltatime 
// Arguments:	DeltaTime that has passed since last iteration 
// Notes:	  	This integrator uses Euler's method 
/*-----------------------------------------------------------------------------*/
void
EulerIntegrate (float DeltaTime) 
{ 

	// JUST TAKE A SINGLE STEP 
	IntegrateSysOverTime (clo->s, clo->s, clo->t, DeltaTime); 

	return;
} 
/*-----------------------------------------------------------------------------*/
// Purpose:		Calculate new Positions and Velocities given a deltatime 
// Arguments:	DeltaTime that has passed since last iteration 
// Notes:		  This integrator uses the Midpoint method 
/*-----------------------------------------------------------------------------*/
void 
MidPointIntegrate (float DeltaTime) 
{ 
	float		halfDeltaT; 
	halfDeltaT = DeltaTime / 2.0f; 
 
	// TAKE A HALF STEP AND UPDATE VELOCITY AND POSITION 
	IntegrateSysOverTime (clo->s, clo->s, m_TempSys[0], halfDeltaT); 
 
	// COMPUTE FORCES USING THESE NEW POSITIONS AND VELOCITIES 
	ComputeForces (m_TempSys[0]); 
 
	// TAKE THE FULL STEP WITH THIS NEW INFORMATION 
	IntegrateSysOverTime (clo->s, m_TempSys[0], clo->t, DeltaTime); 

	return;
} 
/*-----------------------------------------------------------------------------*/
// Purpose:		Calculate new Positions and Velocities given a deltatime 
// Arguments:	DeltaTime that has passed since last iteration 
// Notes:		This integrator uses the Runga-Kutta 4 method 
//			  	This could use a generic function 4 times instead of unrolled 
//				  but it was easier for me to debug.  Fun for you to optimize. 
/*-----------------------------------------------------------------------------*/
void 
RK4Integrate (float DeltaTime) 
{ 
	int loop; 
	float		halfDeltaT,sixthDeltaT; 
	tParticle	*source,*target,*accum1,*accum2,*accum3,*accum4; 
	//mgena
	tParticle	*m_CurrentSys = clo->s;
	tParticle	*m_TargetSys  = clo->t;
	int        m_ParticleCnt= clo->m_ParticleCnt;

	halfDeltaT = DeltaTime / 2.0f;		// SOME TIME VALUES I WILL NEED 
	sixthDeltaT = 1.0f / 6.0f; 
 


	// FIRST STEP 
	source = m_CurrentSys;	// CURRENT STATE OF PARTICLE 
	target = m_TempSys[0];	// TEMP STORAGE FOR NEW POSITION 
	accum1 = m_TempSys[1];	// ACCUMULATE THE INTEGRATED VALUES 
	for (loop = 0; loop < m_ParticleCnt; loop++) 
	{ 
		accum1->f.x = halfDeltaT * source->f.x * source->oneOverM; 
		accum1->f.y = halfDeltaT * source->f.y * source->oneOverM; 
		accum1->f.z = halfDeltaT * source->f.z * source->oneOverM; 
 
		accum1->v.x = halfDeltaT * source->v.x; 
		accum1->v.y = halfDeltaT * source->v.y; 
		accum1->v.z = halfDeltaT * source->v.z; 
		// DETERMINE THE NEW VELOCITY FOR THE PARTICLE OVER 1/2 TIME 
		target->v.x = source->v.x + (accum1->f.x); 
		target->v.y = source->v.y + (accum1->f.y); 
		target->v.z = source->v.z + (accum1->f.z); 
 
		target->oneOverM = source->oneOverM; 
 
		// SET THE NEW POSITION 
		target->pos.x = source->pos.x + (accum1->v.x); 
		target->pos.y = source->pos.y + (accum1->v.y); 
		target->pos.z = source->pos.z + (accum1->v.z); 
 
		source++; 
		target++; 
		accum1++; 
	} 
 
	ComputeForces(m_TempSys[0]);  // COMPUTE THE NEW FORCES 
 
	// SECOND STEP 
	source = m_CurrentSys;	// CURRENT STATE OF PARTICLE 
	target = m_TempSys[0];	// TEMP STORAGE FOR NEW POSITION 
	accum1 = m_TempSys[2];	// ACCUMULATE THE INTEGRATED VALUES 
	for (loop = 0; loop < m_ParticleCnt; loop++) 
	{ 
		accum1->f.x = halfDeltaT * target->f.x * source->oneOverM; 
		accum1->f.y = halfDeltaT * target->f.y * source->oneOverM; 
		accum1->f.z = halfDeltaT * target->f.z * source->oneOverM; 
		accum1->v.x = halfDeltaT * target->v.x; 
		accum1->v.y = halfDeltaT * target->v.y; 
		accum1->v.z = halfDeltaT * target->v.z; 
 
		// DETERMINE THE NEW VELOCITY FOR THE PARTICLE 
		target->v.x = source->v.x + (accum1->f.x); 
		target->v.y = source->v.y + (accum1->f.y); 
		target->v.z = source->v.z + (accum1->f.z); 
 
		target->oneOverM = source->oneOverM; 
 
		// SET THE NEW POSITION 
		target->pos.x = source->pos.x + (accum1->v.x); 
		target->pos.y = source->pos.y + (accum1->v.y); 
		target->pos.z = source->pos.z + (accum1->v.z); 
 
		source++; 
		target++; 
		accum1++; 
	} 
 
	ComputeForces(m_TempSys[0]);  // COMPUTE THE NEW FORCES 
 
	// THIRD STEP 
	source = m_CurrentSys;	// CURRENT STATE OF PARTICLE 
	target = m_TempSys[0];	// TEMP STORAGE FOR NEW POSITION 
	accum1 = m_TempSys[3];	// ACCUMULATE THE INTEGRATED VALUES 
	for (loop = 0; loop < m_ParticleCnt; loop++) 
	{ 
		// NOTICE I USE THE FULL DELTATIME THIS STEP 
		accum1->f.x = DeltaTime * target->f.x * source->oneOverM; 
		accum1->f.y = DeltaTime * target->f.y * source->oneOverM; 
		accum1->f.z = DeltaTime * target->f.z * source->oneOverM; 
		accum1->v.x = DeltaTime * target->v.x; 
		accum1->v.y = DeltaTime * target->v.y; 
		accum1->v.z = DeltaTime * target->v.z; 
 
		// DETERMINE THE NEW VELOCITY FOR THE PARTICLE 
		target->v.x = source->v.x + (accum1->f.x); 
		target->v.y = source->v.y + (accum1->f.y); 
		target->v.z = source->v.z + (accum1->f.z); 
 
		target->oneOverM = source->oneOverM; 
 
		// SET THE NEW POSITION 
		target->pos.x = source->pos.x + (accum1->v.x); 
		target->pos.y = source->pos.y + (accum1->v.y); 
		target->pos.z = source->pos.z + (accum1->v.z); 
 
		source++; 
		target++; 
		accum1++; 
	} 
 
	ComputeForces(m_TempSys[0]);  // COMPUTE THE NEW FORCES 
 
	// FOURTH STEP 
	source = m_CurrentSys;	// CURRENT STATE OF PARTICLE 
	target = m_TempSys[0];	// TEMP STORAGE FOR NEW POSITION 
	accum1 = m_TempSys[4];	// ACCUMULATE THE INTEGRATED VALUES 
	for (loop = 0; loop < m_ParticleCnt; loop++) 
	{ 
		// NOTICE I USE THE FULL DELTATIME THIS STEP 
		accum1->f.x = DeltaTime * target->f.x * source->oneOverM; 
		accum1->f.y = DeltaTime * target->f.y * source->oneOverM; 
		accum1->f.z = DeltaTime * target->f.z * source->oneOverM; 
 
		accum1->v.x = DeltaTime * target->v.x; 
		accum1->v.y = DeltaTime * target->v.y; 
		accum1->v.z = DeltaTime * target->v.z; 
 
		// THIS TIME I DON'T NEED TO COMPUTE THE TEMPORARY POSITIONS 
		source++; 
		target++; 
		accum1++; 
	} 
 
	source = m_CurrentSys;	// CURRENT STATE OF PARTICLE 
	target = m_TargetSys; 
	accum1 = m_TempSys[1]; 
	accum2 = m_TempSys[2]; 
	accum3 = m_TempSys[3]; 
	accum4 = m_TempSys[4]; 
	for (loop = 0; loop < m_ParticleCnt; loop++) 
	{ 
		// DETERMINE THE NEW VELOCITY FOR THE PARTICLE USING RK4 FORMULA 
		target->v.x = source->v.x + ((accum1->f.x + ((accum2->f.x + accum3->f.x) * 2.0f) + accum4->f.x) * sixthDeltaT); 
		target->v.y = source->v.y + ((accum1->f.y + ((accum2->f.y + accum3->f.y) * 2.0f) + accum4->f.y) * sixthDeltaT); 
		target->v.z = source->v.z + ((accum1->f.z + ((accum2->f.z + accum3->f.z) * 2.0f) + accum4->f.z) * sixthDeltaT); 
		// DETERMINE THE NEW POSITION FOR THE PARTICLE USING RK4 FORMULA 
		target->pos.x = source->pos.x + ((accum1->v.x + ((accum2->v.x + accum3->v.x) * 2.0f) + accum4->v.x) * sixthDeltaT); 
		target->pos.y = source->pos.y + ((accum1->v.y + ((accum2->v.y + accum3->v.y) * 2.0f) + accum4->v.y) * sixthDeltaT); 
		target->pos.z = source->pos.z + ((accum1->v.z + ((accum2->v.z + accum3->v.z) * 2.0f) + accum4->v.z) * sixthDeltaT); 
 
		source++; 
		target++; 
		accum1++; 
		accum2++; 
		accum3++; 
		accum4++; 
	} 
 
} 
/*-----------------------------------------------------------------------------*/
/*                                                                             */
/*-----------------------------------------------------------------------------*/
void 
Simulate (float DeltaTime) 
{ 

  ComputeForces (clo->s); 
 
  switch (1) 
  { 
  case 1: 
    EulerIntegrate (DeltaTime); 
    break; 
  case 2: 
    MidPointIntegrate (DeltaTime); 
    break; 
  case 3: 
    RK4Integrate (DeltaTime); 
    break; 
  } 
	
  // SWAP MY TWO PARTICLE SYSTEM BUFFERS SO I CAN DO IT AGAIN 
  clo_swap (clo);

  return;
} 
/*-----------------------------------------------------------------------------*/
/*                                                                             */
/*-----------------------------------------------------------------------------*/
static void  
idle (void) 
{ 
	static int index = 0;
	char title[100];
	
	sprintf (title, "SimCloth:  %d", index);

	glutSetWindowTitle(title); 
	glutSetIconTitle(title);
	
	//OUTD (index); 
	index++;  

	Simulate (DeltaT);

  if (!(index%10)) glutPostRedisplay(); 
	return;
} 
/*-----------------------------------------------------------------------------*/
/*                                                                             */
/*-----------------------------------------------------------------------------*/
void  
visible (int vis) 
{ 
  if (vis == GLUT_VISIBLE) 
    glutIdleFunc (idle); 
  else 
    glutIdleFunc (NULL); 
} 
/*-----------------------------------------------------------------------------*/
/*                                                                             */
/*-----------------------------------------------------------------------------*/
void
main_scloth (int argc, char** argv)
{
	int    ii, jj;
	double w, h;

	ii = jj = 9;
	siz   = 7.5; // полуширина ящика
	w = h = 8.0;

	m_Gravity.x =  0.0;
	m_Gravity.y = /* -0.001 */ -0.2;
	m_Gravity.z =  0.0;

	DeltaT = 0.1;

	//---------------------
	YCreateWindow (argc, argv, "Hello, Scloth !!", 100, 300, 600, 600);

  glClearIndex (YColor("white")); /* backgraund */
  glMatrixMode (GL_PROJECTION);
  glLoadIdentity ();

  glOrtho (-2*siz, 2*siz, -2*siz, 2*siz, -10*siz, 10*siz);
  glViewport (-2*siz, -2*siz, 4*siz, 4*siz);

	angle_x = 15;
	angle_y = 15;
	moving = 0;

	//gluLookAt (0.0, 0.0, 5.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0);
   
  /* Setup initial OpenGL rendering state. */
  glEnable (GL_DEPTH_TEST);
  glPointSize (2);
  glLineWidth (2);

  /* Register assorted GLUT callback routines. */
  glutDisplayFunc (display);
  glutMouseFunc (mouse);
  glutMotionFunc (motion);
  //glutVisibilityFunc (visible); 
	glutIdleFunc (idle); 
  glutKeyboardFunc (keyboard);

  /* Create a pop-up menu. */
  glutCreateMenu (menu);
  glutAddMenuEntry ("Menu_Item1", M_ITEM1);
  glutAddMenuEntry ("Menu_Item2", M_ITEM2);
  glutAddMenuEntry ("Exit",       M_EXIT);
  glutAttachMenu (GLUT_RIGHT_BUTTON);

	//----------------
	clo = clo_create (ii, jj);
	clo_set_vert (clo, -w/2, h/2, w, h);
	//clo_rand_noice (clo);

  All = make_all ();                                                           
	//----------------

	glutMainLoop ();

	return;
} 
/*-----------------------------------------------------------------------------*/
/*                                                                             */
/*-----------------------------------------------------------------------------*/
int 
main (int argc, char** argv)
{

  left_num = 0;
  LEFT_BEG;

  //-----------------------------
  //test_siman ();
  //test_fpe ();

  if (0) main_proc();
  if (0) proc01 (YMAIN, 0, 0, 0, 0, 0);
  if (0) proc03 (YMAIN, 0, 0, 0, 0, 0);
  //-----------------------------

  //main_ogl_test1 (argc, argv);
  //main_ogl_test2 ();

  main_scloth (argc, argv);
	

  return (0);
}
/*-----------------------------------------------------------------------------*/
/*                                                                             */
/*-----------------------------------------------------------------------------*/
