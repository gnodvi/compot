/**********************************************************************
  gaul_util.h
 **********************************************************************

  gaul_util.h - General header to define a few useful things
  Copyright ©1999-2006, Stewart Adcock <stewart@linux-domain.com>
  All rights reserved.

  Synopsis:	Define some common macros, constants, etc.

 **********************************************************************/

#ifndef GAUL_UTIL_H_INCLUDED
#define GAUL_UTIL_H_INCLUDED

/*
 * _GNU_SOURCE includes the _POSIX_SOURCE and _ISOC99_SOURCE
 * C extensions, which are normally fairly useful!
 * This has to be defined prior to the inclusion of any of the 
 * standard C headers.
 */
#if defined(__GNUC__) && !defined(_GNU_SOURCE)
# define _GNU_SOURCE
#endif

/*
 * Include the platform specific configuration file:
 */
/* #ifdef WIN32 */
/* # include "gaul/gaul_config_win.h" */
/* #else */
//# include "gaul_config.h"
//--------------------------------------------------------------------------------
//# include "c_00_config.h"
//--------------------------------------------------------------------------------


/********************************************************************
 *
 * DO NOT EDIT THIS FILE!  It was automatically generated from:
 *    configure.in and gaul_config.h.in
 *    on host: is7
 *
 ********************************************************************/

//#ifndef GAUL_CONFIG_H_INCLUDED
//#define GAUL_CONFIG_H_INCLUDED

/***********************************************************************
## gaul_config.h.in -- Process this file with configure to produce gaul_config.h
##  
## This file contains platform specific magic.
##  
 **********************************************************************/

/* #if defined __CYGWIN32__ && !defined __CYGWIN__ */
/* #  define __CYGWIN__ __CYGWIN32__ */
/* #endif */
/* #if defined __CYGWIN__ && !defined WIN32 */
/* #  define WIN32 */
/* #endif */

/**********************************************************************
 * Preparation for Windows DLL generation.
 **********************************************************************/

/* #ifdef WIN32 */
/* #  ifdef BUILDING_DLL */
/* #    define GAULFUNC __declspec (dllexport) */
/* #  else */
/* #    define GAULFUNC __declspec (dllimport) */
/* #  endif */
/* #else */
#  define GAULFUNC
/* #endif */

/* util/gaul/gaul_config.h.in */
#include <pwd.h>
#include <sys/select.h>
#include <sys/signal.h>
#include <sys/time.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <limits.h>
#include <unistd.h>
#include <string.h>

#ifndef errno
/* Some sytems #define this! */
extern int errno;
#endif

#define HAVE_STDBOOL_H 1
#define HAVE__BOOL 1

/*
 * Explicitly tested functions for this platform:
 */

#define HAVE_MEMCPY 1
/* #undef HAVE_MIN */
/* #undef HAVE_MAX */
#define HAVE_SINCOS 1
#define HAVE_STRDUP 1
#define HAVE_STRNDUP 1
#define HAVE_STRCPY 1
#define HAVE_STRNCPY 1
#define HAVE_STRCMP 1
#define HAVE_STRNCMP 1
#define HAVE_STRLEN 1
#define HAVE_STRPBRK 1
#define HAVE_STRSEP 1
#define HAVE_STRCASECMP 1
#define HAVE_STRNCASECMP 1
#define HAVE_USLEEP 1
/* #undef HAVE_SNOOZE */
#define HAVE_INDEX 1
#define HAVE_WAITPID 1
#define HAVE_GETHOSTNAME 1
#define HAVE_BCMP 1
#define HAVE_BCOPY 1
/* #undef MEMORY_CHUNKS_MIMIC */

/*
 * Explicitly tested headers for this platform:
 */
#define HAVE_LIMITS_H 1

//#define HAVE_PTHREADS 1

/* #undef USE_OPENMP */
/* #undef HAVE_MPI */
/* #undef MEMORY_ALLOC_DEBUG */
#define MEMORY_ALLOC_SAFE 1
/* #undef W32_CRIPPLED */
/* #undef HAVE_SLANG */
/* #undef USE_CHROMO_CHUNKS */

/*
 * These functions were not explicitely tested.
 * The probably will be tested in future versions, but
 * for now they are not needed.
 */
#define HAVE_MEMCMP  1
#define HAVE_STRCHR  1
#define HAVE_STRLEN  1
#define HAVE_STRNCPY 1
#define HAVE_MEMSET  1

#define HAVE_IPOW 0
#define HAVE_DPOW 0

#define GA_MAJOR_VERSION 0
#define GA_MINOR_VERSION 1850
#define GA_LT_MINOR_VERSION 50
#define GA_PATCH_VERSION 0
#define GA_VERSION_STRING "0.1850-0"
#define GA_UNAME_STRING "Linux is7 2.6.9-42.0.3.ELsmp #1 SMP Tue Oct 24 09:49:45 YEKST 2006 x86_64 x86_64 x86_64 GNU/Linux"
#define GA_BUILD_DATE_STRING "11/01/08"

#define V3_QUICK 
#define GAUL_DETERMINISTIC_OPENMP 1
#define AVLTREE_KEY_TYPE unsigned long
#define GA_NUM_PROCESSES_ENVVAR_STRING "GA_NUM_PROCESSES"
#define GA_NUM_THREADS_ENVVAR_STRING "GA_NUM_THREADS"
#define USE_OPTIMISED_MEMSET 1

//#endif /* GAUL_CONFIG_H_INCLUDED */
//--------------------------------------------------------------------------------




/* #endif */

/*
 * Handle threading includes.
 */
/* #ifdef HAVE_PTHREADS */
/* # include <pthread.h> */
/* # ifndef _REENTRANT */
/* #  define _REENTRANT */
/* # endif */
/* #endif */

/*
 * For OpenMP code, USE_OPENMP must be defined and 
 * ga_init_openmp() must be called prior to any
 * other function.
 */
/* #ifdef USE_OPENMP */
/* # include <omp.h> */
/* #endif */

/* #ifdef HAVE_PTHREADS */
/* # define THREAD_LOCK_DECLARE(name)	pthread_mutex_t (name) */
/* # define THREAD_LOCK_DEFINE_STATIC(name)       static pthread_mutex_t (name) = PTHREAD_MUTEX_INITIALIZER */
/* # define THREAD_LOCK_DEFINE(name)	pthread_mutex_t (name) = PTHREAD_MUTEX_INITIALIZER */
/* # define THREAD_LOCK_EXTERN(name)	extern pthread_mutex_t (name) */
/* # define THREAD_LOCK(name)		pthread_mutex_lock(&(name)) */
/* # define THREAD_UNLOCK(name)		pthread_mutex_unlock(&(name)) */
/* # define THREAD_TRYLOCK(name)		pthread_mutex_trylock(&(name)) */
/* # define THREAD_LOCK_NEW(name)		pthread_mutex_init(&(name), NULL) */
/* # define THREAD_LOCK_FREE(name)		pthread_mutex_destroy(&(name)) */
/* #else */
/* # ifdef USE_OPENMP */
/* #  define THREAD_LOCK_DECLARE(name)      omp_lock_t (name) */
/* #  define THREAD_LOCK_DEFINE_STATIC(name)       static omp_lock_t (name) */
/* #  define THREAD_LOCK_DEFINE(name)      omp_lock_t (name) */
/* #  define THREAD_LOCK_EXTERN(name)      extern omp_lock_t (name) */
/* #  define THREAD_LOCK(name)             omp_set_lock(&(name)) */
/* #  define THREAD_UNLOCK(name)           omp_unset_lock(&(name)) */
/* #  define THREAD_TRYLOCK(name)          omp_test_lock(&(name)) */
/* #  define THREAD_LOCK_NEW(name)		omp_init_lock(&(name)) */
/* #  define THREAD_LOCK_FREE(name)	omp_destroy_lock(&(name)) */
/*
 * If threads are used, these must be properly defined somewhere.
 * Unfortunately empty macros cause splint parse errors.  They
 * also cause lots of warnings when using Sun's and Compaq's
 * compilers.
 * In addition, ISO C99 standard doesn't allow extraneous ';'s
 * so we must define some dummy expressions.
 */
/* # else */
#  if defined(__GNUC__) && !defined(_ISOC99_SOURCE)
#   define THREAD_LOCK_DECLARE(name)
#   define THREAD_LOCK_DEFINE_STATIC(name)
#   define THREAD_LOCK_DEFINE(name)
#   define THREAD_LOCK_EXTERN(name)
#   define THREAD_LOCK(name)
#   define THREAD_UNLOCK(name)
#   define THREAD_TRYLOCK(name)		0
#   define THREAD_LOCK_NEW(name)
#   define THREAD_LOCK_FREE(name)
#  else
#   define THREAD_LOCK_DECLARE(name)	int (name)
#   define THREAD_LOCK_DEFINE_STATIC(name)	static int (name) = 0
#   define THREAD_LOCK_DEFINE(name)	int (name) = 0
#   define THREAD_LOCK_EXTERN(name)	extern int (name)
#   define THREAD_LOCK(name)		(name) = 1
#   define THREAD_UNLOCK(name)		(name) = 0
#   define THREAD_TRYLOCK(name)		0
#   define THREAD_LOCK_NEW(name)	(name) = 0
#   define THREAD_LOCK_FREE(name)	(name) = 0
#  endif
/* # endif */
/* #endif */

/*
 * Includes needed for this stuff.
 */
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>

/*
 * Me.
 */
#define AUTHOR	"Stewart Adcock"
#define EMAIL	"<stewart@linux_domain.com>"

/*
 * Define boolean type sensibly.
 */
#ifndef HAVE__BOOL
# define HAVE__BOOL 0
#endif
 
#if HAVE_STDBOOL_H == 1
# include <stdbool.h>
#else
 
# if !defined(__bool_true_false_are_defined)
#  if HAVE__BOOL != 1
typedef short _Bool;
#   undef HAVE__BOOL
#   define HAVE__BOOL 1
#  endif

#  if !defined(true)
#   define true  (_Bool) 1
#   define false (_Bool) 0
#  endif

/* According to ISO C99, the boolean stuff must be available
 * in preprocessor directives and __bool_true_false_are_defined
 * should be true.
 */
#  define __bool_true_false_are_defined 1
# endif

# if !defined(bool)
#  define bool _Bool
# endif
#endif

#if HAVE__BOOL != 1
typedef short _Bool;
#endif

#define boolean _Bool

#if !defined(TRUE)
#define TRUE	(0==0)
#define FALSE	(0!=0)
#endif

/*
 * Additional types.
 */
#ifndef SUN_FORTE_C
# define SUN_FORTE_C 0
#endif

#if SUN_FORTE_C==0
typedef void* vpointer;
#else
#define vpointer void*
#endif

typedef const void *constvpointer;
typedef unsigned char gaulbyte;

/* byte is already defined on win32 systems. */
//typedef unsigned char byte;

#ifdef BITSPERBYTE
# define BYTEBITS	BITSPERBYTE
#else
# ifdef CHARBITS
#  define BYTEBITS	CHARBITS
# else
/* Guess! */
#  define BYTEBITS	8
# endif
#endif

/*
 * Useful constants
 */
#ifndef PI
#define PI              3.1415926536
#endif
#define	TWO_PI		6.2831853072
#define SQRT_PI		1.7724538509
#define SQRT_TWO	1.4142135624
#define ROOT_TWO	1.4142135624
#define	INV_SQRT_3	(1.0/sqrt(3.0))
#define PI_OVER_TWO	(3.1415926536/2.0)
#ifndef NULL
#define NULL		((void*)0)
#endif
#define NULL_CHAR	('\0')
#define OKAY		2
#define TINY            (1.0e-8)
#define ONE_MINUS_TINY  (1.0 - TINY)
#define MAX_LINE_LENGTH 1024
#define MAX_LINE_LEN	1024
#define MAX_FNAME_LEN	256
#define LARGE_AMOUNT	(1.0e38)
#define ApproxZero      (1e-18)
#define IsApproxZero(x) (fabs(x)<=ApproxZero)
#define RAD2DEG		57.2957795128		/* 180.0/PI */
#define DEG2RAD		0.01745329252		/* PI/180.0 */

/*
 * Useful macros
 */
#define SQU(x)          ((x)*(x))		/* Square */
#define CUBE(x)         ((x)*(x)*(x))		/* Cube */
#define FOURTH_POW(x)	((x)*(x)*(x)*(x))	/* Guess ;) */
#define FIFTH_POW(x)	((x)*(x)*(x)*(x)*(x))	/*  - " - */
#define DEG(x)		((x)*RAD2DEG)		/* Radians -> Degrees */
#define RAD(x)		((x)*DEG2RAD)		/* Degress -> Radians */
#define DNEAR(x,y)	(!((x)>y+TINY||(x)<y-TINY))	/* Are two doubles/floats very nearly equal? */
#define NDNEAR(x,y)	(((x)>y+TINY||(x)<y-TINY))	/* Are two doubles/floats not nearly equal? */
#define ISTINY(x)	(((x)<TINY)&&((x)>-TINY))	/* Near zero? */

#define ISODD(x)	(((x)&1))		/* True if x is odd */
#define ISEVEN(x)	(!((x)&1))		/* True if x is even */

#ifndef MIN
#define MIN(x,y)	(((x)<(y))?(x):(y))	/* Return smallest */
#define MAX(x,y)	(((x)>(y))?(x):(y))	/* Return largest */
#endif
#define MIN3(x,y,z)	(((x)<(y))?(((x)<(z))?(x):(z)):(((z)<(y))?(z):(y)))	/* Return smallest */
#define MAX3(x,y,z)	(((x)>(y))?(((x)>(z))?(x):(z)):(((z)>(y))?(z):(y)))	/* Return largest */
#define MINMAX(a,z,x,y) {if((x)<(y)){a=x;z=y;}else{z=x;a=y;}}

/* Swap primitives */
#define SWAP_INT(x,y)		{int t; t = x; x = y; y = t; }
#define SWAP_CHAR(x,y)		{char t; t = x; x = y; y = t; }
#define SWAP_FLOAT(x,y)		{float t; t = x; x = y; y = t; }
#define SWAP_DOUBLE(x,y)	{double t; t = x; x = y; y = t; }
#define SWAP_BOOLEAN(x,y)	{boolean t; t = x; x = y; y = t; }

/* Working with bitvectors. c is the vector, n is the bit index */
#define	GET_BIT(c,n)		(*((c)+((n)>>3)) >> (7-((n)&7))&1)
#define	SET_BIT(c,n)		(*((c)+((n)>>3)) |=   1<<(7-((n)&7)))
#define	CLEAR_BIT(c,n)		(*((c)+((n)>>3)) &= ~(1<<(7-((n)&7))))
#define	ISSET_BIT(c,n)		(*((c)+((n)>>3)) &    1<<(7-((n)&7)))

/* These macros clash with glib: */
#ifndef ABS
# define ABS(x)		(((x)>0)?(x):-(x))	/* Return absolute value */
#endif
#ifndef CLAMP
# define CLAMP(x,l,h)	(((x)>(h))?(h):(((x)>(l))?(x):(l)))	/* Return clamped value */
#endif

/* Rounding.
 * FLOOR() rounds to nearest integer towards 0.
 * CEILING() rounds to nearest integer away from 0.
 * ROUND() rounds to the nearest integer.
 */
#define FLOOR(X)	((X)>0 ? (int)(X) : -(int)(-(X)))
#define CEILING(X)	((X)==(int)(X) ? (X) : (X)>0 ? 1+(int)(X) : -(1+(int)(-(X))))
#define ROUND(X)        ((X)>0?(int)(0.5+(X)):-(int)(0.5-(X)))

#define SIGN(X)		(((X)<0) ? -1 : 1)		/* get sign, -1, or 1 if >= 0 */
#define SIGNZ(X)	(((X)<0) ? -1 : (X)>0 ? 1 : 0)	/* get sign, -1, 0, or 1 */

/*
 * Linear interpolation from l (at x=0) to h (at x=1).
 * This is equivalent to (x*h)+((1-x)*l).
 */
#define LERP(x,l,h)	((l)+(((h)-(l))*(x)))

/* Is this a GNU system? */
#if !defined(__GNUC__) && !defined(__INTEL_COMPILER)
/* No. */
#define __PRETTY_FUNCTION__ "<unavailable>"
#endif

/*
 * Wrappers around nasty, unportable, harsh breakpoints.
 */
#ifdef __GNUC__
# ifdef __i386__
#  define s_breakpoint	__asm__ __volatile__ ("int $03")
# else
#  ifdef __alpha__
#   define s_breakpoint	__asm__ __volatile__ ("bpt")
#  else
#   define s_breakpoint	abort()
#  endif
# endif
#else
# ifdef __INTEL_COMPILER
#  ifdef __i386__
#   define s_breakpoint	asm volatile ("int $03")
#  else
#   define s_breakpoint	abort()
#  endif
# else
#  define s_breakpoint	abort()
# endif
#endif

/*
 * Wrappers for multi-statement macros.
 */
#if defined(__GNUC__) || defined(__INTEL_COMPILER) || defined(_MSC_VER)
#define MWRAP_BEGIN
#define MWRAP_END
#else
#define MWRAP_BEGIN	do
#define MWRAP_END	while(FALSE);
#endif

/*
 * Development message macros
 */
#define message(X)	MWRAP_BEGIN {					\
			printf("MESSAGE: %s\n", (X));			\
			printf("(\"%s\", %s, line %d)\n",		\
			__FILE__, __PRETTY_FUNCTION__, __LINE__);	\
			} MWRAP_END

#define message_if(X,Y)	if ((X)) {					\
			printf("MESSAGE: %s\n", (X));			\
			printf("(\"%s\", %s, line %d)\n",		\
			__FILE__, __PRETTY_FUNCTION__, __LINE__);	\
			}

#define message_if_else(X,Y,Z)	MWRAP_BEGIN {				\
			printf("MESSAGE: %s\n", (X)?(Y):(Z));		\
			printf("(\"%s\", %s, line %d)\n",		\
			__FILE__, __PRETTY_FUNCTION__, __LINE__);	\
			} MWRAP_END

#define s_assert(X)     MWRAP_BEGIN { if(!(X)) { 			\
			printf("Assertion \"%s\" failed:\n", (#X));	\
			printf("(\"%s\", %s, line %d)\n",		\
			__FILE__, __PRETTY_FUNCTION__, __LINE__);	\
			s_breakpoint;					\
                        } } MWRAP_END

/*
 * die() macro, inspired by perl!
 */
#define die(X)	MWRAP_BEGIN {						\
                printf("FATAL ERROR: %s\nin %s at \"%s\" line %d\n",	\
		(X),					\
                __PRETTY_FUNCTION__,			\
                __FILE__,				\
                __LINE__);				\
		fflush(NULL);				\
                s_breakpoint;				\
		} MWRAP_END

/*
 * Implement my dief macro where possible.
 */
#if ( defined(__GNUC__) || defined(__INTEL_COMPILER) ) && !defined(__APPLE_CPP__) && !defined(__APPLE_CC__)
#  define dief(format, ...)	MWRAP_BEGIN {			\
			printf("FATAL ERROR: ");		\
			printf(format , ##__VA_ARGS__);		\
			printf("\nin %s at \"%s\" line %d\n",	\
			__PRETTY_FUNCTION__,			\
			__FILE__,				\
			__LINE__);				\
			fflush(NULL);				\
			s_breakpoint;                           \
			} MWRAP_END
# define HAVE_DIEF	1
#else
/*
 * void dief(const char *format, ...);
 * is defined in compatibility.c because vararg macros are not
 * implemented in many inferior compilers ;)
 */
# define HAVE_DIEF	0
#endif
		

/*
 * Portable programming utilities.
 */

//------------------------------------------------------------------------------
//#include "c_compatibility.h"      /* For portability stuff. */
//------------------------------------------------------------------------------
/*******************************************************************************
 *                                                                             *
 *  ��� ����� �����: compatibility.h                                           *
 *                                                                             *
  ******************************************************************************
 */  
                                                                            
//#ifndef COMPATIBILITY_H_INCLUDED
//#define COMPATIBILITY_H_INCLUDED

//#include "c_all_util.h"

/* Includes */
#include <assert.h>
#include <ctype.h>
#include <errno.h>
#include <math.h>
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/*----------------------------------------------------------------------------*/

#ifdef HAVE_UNISTD_H
#include <unistd.h>		/* usleep, fcntl */
#endif
#ifdef HAVE_SYS_TIME_H
#include <sys/time.h>
#endif
#ifdef HAVE_SYS_TYPES_H
#include <sys/types.h>
#endif
#ifdef HAVE_FCNTL_H
#include <fcntl.h>
#endif
#ifdef HAVE_SYS_IOCTL_H
#include <sys/ioctl.h>
#endif
#ifdef HAVE_SYS_SELECT_H
#include <sys/select.h>
#endif
#ifdef HAVE_SYS_WAIT_H
#include <sys/wait.h>
#endif

#include "c_memory_util.h"

/*----------------------------------------------------------------------------*/
/*
 * Debugging
 */

#ifndef COMPAT_DEBUG
#define COMPAT_DEBUG   2
#endif

/*----------------------------------------------------------------------------*/
/*
 * Prototypes
 */

#if HAVE_IPOW != 1
GAULFUNC int ipow(int n, int e);
#endif

#if HAVE_DPOW != 1
GAULFUNC double dpow(double n, int e);
#endif

/* #if !defined(HAVE_STRCHR) */
/* # if defined(HAVE_INDEX) */
/* #  define strchr index */
/* # else */
/* GAULFUNC char *strchr(const char *str, int c); */
/* # endif */
/* #endif */

/* #if !defined(HAVE_STRLEN) */
/* GAULFUNC size_t strlen(const char *str); */
/* #endif */

/* #if !defined(HAVE_STRCMP) */
/* GAULFUNC int strcmp(const char *str1, const char *str2); */
/* #endif */

/* #if !defined(HAVE_STRNCMP) */
/* GAULFUNC int strncmp(const char *str1, const char *str2, size_t len); */
/* #endif */

/* #if !defined(HAVE_STRCPY) */
/* GAULFUNC char *strcpy(char *str1, const char *str2); */
/* #endif */

/* #if !defined(HAVE_STRNCPY) */
/* GAULFUNC char *strncpy(char *str1, const char *str2, size_t len); */
/* #endif */

/* #if !defined(HAVE_STRPBRK) */
/* GAULFUNC char *strpbrk(const char *s, const char *accept); */
/* #endif */

/* #if !defined(HAVE_STRSEP) */
/* GAULFUNC char *strsep(char **str, const char *delim); */
/* #endif */

/* #if !defined(HAVE_STRCASECMP) */
/* GAULFUNC int strcasecmp(const char *str0, const char *str1); */
/* #endif */

/* #if !defined(HAVE_STRNCASECMP) */
/* GAULFUNC int strncasecmp(const char *str0, const char *str1, size_t n); */
/* #endif */

#if !defined(HAVE_USLEEP)
GAULFUNC void usleep(unsigned long usec);
#endif

#if !defined(HAVE_MEMCPY)
/* Some systems, such as SunOS do have BCOPY instead. */
# if defined(HAVE_BCOPY)
#  define memcpy(A, B, C) bcopy((B), (A), (C))
# else
GAULFUNC void memcpy(char *dest, const char *src, size_t len);
# endif
#endif

//#if !defined(HAVE_MEMCMP)
///* Some systems, such as SunOS do have BCMP instead. */
//# if defined(HAVE_BCMP)
//#  define memcmp(A, B, C) bcmp((B), (A), (C))
//# else
//GAULFUNC int memcmp(const void *src1, const void *src2, size_t n);
//# endif
//#endif

#if !defined(HAVE_STRDUP)
GAULFUNC char *strdup(const char *str);
#endif

#if !defined(HAVE_STRNDUP)
GAULFUNC char *strndup(const char *str, size_t n);
#endif

#if HAVE_DIEF != 1
/*
 * HAVE_DIEF is set in "SAA_header.h", not "config.h"
 */
GAULFUNC void dief(const char *format, ...);
#endif

#if !defined(HAVE_WAITPID) && !defined( W32_CRIPPLED )
/* FIXME: Need to add a Windows compatible version of this function. */
GAULFUNC pid_t waitpid(pid_t pid, int *pstatus, int options);
#endif

#if !defined(HAVE_MIN)
GAULFUNC int min(int a, int b);
#endif

#if !defined(HAVE_MAX)
GAULFUNC int max(int a, int b);
#endif

#if !defined(HAVE_SINCOS)
GAULFUNC void sincos( double radians, double *s, double *c );
#endif

#if !defined(HAVE_GETHOSTNAME)
GAULFUNC int gethostname(char *name, size_t len);
#endif

/*----------------------------------------------------------------------------*/
//#endif /* COMPATIBILITY_H_INCLUDED */
/*============================================================================*/


//------------------------------------------------------------------------------
//#include "c_log_util.h"           /* For logging facilities. */
//------------------------------------------------------------------------------

/*******************************************************************************
 *                                                                             *
 *  ��� ����� �����: c_log_util.h                                              *
 *                                                                             *
  ******************************************************************************
 */  
                                                                            
//#ifndef LOG_UTIL_H_INCLUDED
//#define LOG_UTIL_H_INCLUDED

//#include "c_all_util.h"

#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <time.h>

#include "c_memory_util.h"

/* #ifdef HAVE_MPI */
/* #include <mpi.h> */
/* #endif */

/*----------------------------------------------------------------------------*/
/*
 * Constants
 */
#define	LOG_MAX_LEN	160

/*----------------------------------------------------------------------------*/
/*
 * Log message type tags.
 */
enum log_level_type {
  LOG_NONE=0,	/* No messages - I recommend that this isn't used! */
  LOG_FATAL,	/* Fatal errors only */
  LOG_WARNING,	/* Warning messages */
  LOG_QUIET=3,	/* Normal messages */
  LOG_NORMAL=3,	/*  - " - */
  LOG_VERBOSE,	/* Verbose messages */
  LOG_FIXME,	/* Development reminders */
  LOG_DEBUG	/* Debugging messages */
  };

/*----------------------------------------------------------------------------*/
/*
 * Function prototypes
 */
/* Function definition for custom output function: */
typedef void  (*log_func)(const enum log_level_type level,
                                   const char *func_name,
                                   const char *file_name,
                                   const int line_num,
                                   const char *message);

void	log_init (enum log_level_type level, char *fname, log_func func, boolean date);
void	log_set_level(enum log_level_type level);
void	log_set_file (const char *fname);
enum log_level_type  log_get_level (void);

/*----------------------------------------------------------------------------*/
/*
 * This is the actual logging function, but isn't intended to be used
 * directly.
 */
void	log_output( const enum log_level_type level,
                          const char *func_name,
                          const char *file_name,
                          const int line_num,
                          const char *format, ... );

/*----------------------------------------------------------------------------*/
/*
 * Main plog macro.  Should replace this with an inline
 * function?  Especially since log_get_level() is an
 * inline function anyway.
 *
 * Unfortunately, this nice macro will only work on GNU systems.
 * We have a less-functional replacement for other systems.
 */
/*----------------------------------------------------------------------------*/
#if ( defined(__GNUC__) || defined(__INTEL_COMPILER) ) && !defined(__APPLE_CPP__) && !defined(__APPLE_CC__)
#define	plog( level, ... ) { 	\
	if ( (level) <= log_get_level() ) 	\
	  log_output(level, __PRETTY_FUNCTION__,	\
	                   __FILE__, __LINE__,		\
	                   ##__VA_ARGS__); }
#else
void plog( const enum log_level_type level, const char *format, ... );
#endif

/*----------------------------------------------------------------------------*/
/*
 * SLang intrinsic function with equivalent functionality.
 */
/* #ifdef HAVE_SLANG */
/* void	log_wrapper(int *level, char *message); */
/* #endif */

/*----------------------------------------------------------------------------*/
//#endif /* LOG_UTIL_H_INCLUDED */
/*----------------------------------------------------------------------------*/


//------------------------------------------------------------------------------
#include "c_linkedlist.h"         /* For linked lists. */
#include "c_memory_util.h"        /* Memory handling. */
#include "c_random_util.h"        /* For PRNGs. */
#include "c_table_util.h"         /* Handling unique integer ids. */
#include "c_bitstring.h"

//------------------------------------------------------------------------------
#endif
//------------------------------------------------------------------------------

