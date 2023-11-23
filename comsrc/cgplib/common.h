// -*-  mode: c    ; coding: koi8   -*- ----------------------------------------

/*******************************************************************************
 *                                                                             *
 *  Имя этого файла: common.h                                                  *
 *                                                                             *
 *******************************************************************************
 */  
   
#ifndef __A_COMM_H__
#define __A_COMM_H__

#include <stdio.h>
#include <stdlib.h>   
#include <string.h>
#include <math.h> 
#include <time.h>  
#include <unistd.h> 
#include <ctype.h>  
#include <dirent.h> 
#include <sys/time.h> 
#include <sys/param.h>
#include <sys/timeb.h>
#include <assert.h>
#include <stdarg.h>
                                                                             
//#include <glib.h>

//------------------------------------------------------------------------------

#define FALSE 0
#define TRUE  1

#define YRAND_F  srand48(time(0))
double  YRandF (double fmin, double fmax);

#define YRAND(imin,imax) (imin+random()%(imax-imin+1)) 
void srandom_set (int seed);

#define YRAND_S  srandom_set(-1)
#define YRAND_C  srandom_set(2010) 

typedef int YT_BOOL;                                                          
#define BOOL YT_BOOL
#define CHAR int

#define EPS  0.000001

#define UNUSED(x) (x=x)
#define YERROR(str)  {fprintf (stderr, "ERROR: %s \n", (str)); exit(0);}

int     YInt (double); 
void    Error (const char *msg);      

#define STDERR (stdout) 

#define  G_SUCCESS   0
#define  G_FAILURE  -1

extern BOOL ERR_PRINT;
extern BOOL debug;

int    Rand123 (double p1, double p2, double p3);
BOOL   RandYes (double procent);

BOOL   FRavno (double d1, double d2, double eps);

BOOL   str_cmp (const char *str1, const char *str2);
YT_BOOL  YStrCmp (char *str1, char *str2); 

#define SRAND_TIME -1
#define PRINT_LONGLINE printf ("------------------------------------------------------------------- \n");
  
char*   time_calc_printa (int mode);
long    YTimeGet (void);
double  TimeSec ();
 
typedef struct {
	time_t    tim_beg;
} YT_TIMER;

YT_TIMER* timer_beg (void);
void      timer_end (YT_TIMER *t, char *hms_time);


#define YMAX(a,b)  MAX(a,b)
#define YMIN(a,b)  MIN(a,b) 

//------------------------------------------------------------------------------

typedef  double (*YT_MAKEFUNC) (double);

#define NUMINPUTS    1
#define NUMOUTPUTS   1

#define NUMSAMPLES 101
#define INPUTRANGE 10.0

struct dataSet *make_data_function (YT_MAKEFUNC makefunc, int nums, double x_min, double x_max); 

extern int verbose; // немного больше печатать

//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

void
get_options_CGP (int argc, char **argv,
 
                 char   *p_buf,   // strcpy (p_buf, optarg);               
                 int    *seed,    // *seed = atoi (optarg); 
                 int    *data,
                 int    *update,  // updateFrequency
                 double *fitness, 
                 int    *nums, 
                 int    *verbose 
                 );

//------------------------------------------------------------------------------

#endif /* __COMMON_H__ */
//------------------------------------------------------------------------------
