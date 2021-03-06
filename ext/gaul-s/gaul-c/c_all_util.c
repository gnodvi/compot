/*******************************************************************************
 *                                                                             *
 *  Имя этого файла: c_all_util.c                                              *
 *                                                                             *
  ******************************************************************************
 */  
                                                                            
#include "c_all_util.h"


/*******************************************************************************
 *  Имя этого файла: compatibility.c                                           *

  Synopsis:	Compatibility/portability functions.

		Note that some of these functions are POSIX
		compliant. Some are ANSI compliant.  Some are just
		plain non-standard.

 **********************************************************************/

//#include "c_compatibility.h"

/*----------------------------------------------------------------------------*/
#if HAVE_IPOW != 1
/*----------------------------------------------------------------------------*/
/*
 * Integer power.
 */
/*----------------------------------------------------------------------------*/
int ipow (int n, int e)
{
  int	result=1;	/* The answer. */

  while (e>0)
  {
    result*=n;
    e--;
  }

  return result;
}
/*----------------------------------------------------------------------------*/
#endif	/* HAVE_IPOW */
/*----------------------------------------------------------------------------*/


/*----------------------------------------------------------------------------*/
#if HAVE_DPOW != 1
/*----------------------------------------------------------------------------*/
/*
 * Double to integer power.
 */
/*----------------------------------------------------------------------------*/
double dpow (double n, int e)
{
  double	result=1.0;	/* The answer. */

  while (e>0)
  {
    result*=n;
    e--;
  }

  return result;
}
/*----------------------------------------------------------------------------*/
#endif	/* HAVE_DPOW */
/*----------------------------------------------------------------------------*/


/*----------------------------------------------------------------------------*/
/* #if !defined(HAVE_MEMCPY) */
/* #if !defined(HAVE_BCOPY) */
/*----------------------------------------------------------------------------*/
/*
 * Copy LEN characters from SRC to DEST
 * 
 * Some systems, such as SunOS do have BCOPY instead.
 * In which case this is defined as a macro in the header.
 */
/*----------------------------------------------------------------------------*/
/* void memcpy (char *dest, const char *src, size_t len) */
/* { */
/*   char		*dest_p; */
/*   const	char	*src_p; */
/*   int		byte_c; */
  
/*   if (len <= 0) */
/*     return; */
  
/*   src_p = src; */
/*   dest_p = dest; */
  
/*   if (src_p <= dest_p && src_p + (len - 1) >= dest_p) */
/*   { */
  ///*     /* overlap, must copy right-to-left. */ */
/*     src_p += len - 1; */
/*     dest_p += len - 1; */
/*     for (byte_c = 0; byte_c < len; byte_c++) */
/*       *dest_p-- = *src_p--; */
/*   } */
/*   else */
/*   { */
/*     for (byte_c = 0; byte_c < len; byte_c++) */
/*       *dest_p++ = *src_p++; */
/*   } */

/*   return; */
/* } */
/*----------------------------------------------------------------------------*/
//#endif /* !HAVE_BCOPY */
//#endif /* !HAVE_MEMCPY */
/*----------------------------------------------------------------------------*/


/*----------------------------------------------------------------------------*/
//#if !defined(HAVE_STRCHR)
//#if !defined(HAVE_INDEX)
/*----------------------------------------------------------------------------*/
/*
 * Find C in STR by searching through the string
 */
/*----------------------------------------------------------------------------*/
/* char *strchr (const char *str, int c) */
/* { */

/*   while ( *str != '\0' ) */
/*   { */
/*     if (*str == (char)c) */
/*       return (char *)str; */
/*     str++; */
/*   } */
  
/*   if (c == '\0') */
/*     return (char *)str; */

/*   return NULL; */
/* } */
/*----------------------------------------------------------------------------*/
//#endif /* !HAVE_INDEX */
//#endif /* !HAVE_STRCHR */
/*----------------------------------------------------------------------------*/


/*----------------------------------------------------------------------------*/
//#if !defined(HAVE_STRLEN)
/*----------------------------------------------------------------------------*/
/*
 * Return the length in characters of STR
 */
/*----------------------------------------------------------------------------*/
/* size_t strlen (const char *str) */
/* { */
/*   int	len=0; */
  
/*   while ( *str != '\0' ) */
/*   { */
/*     str++; */
/*     len++; */
/*   } */
  
/*   return len; */
/* } */
/*----------------------------------------------------------------------------*/
//#endif /* !HAVE_STRLEN */
/*----------------------------------------------------------------------------*/


/*----------------------------------------------------------------------------*/
//#if !defined(HAVE_STRCMP)
/*----------------------------------------------------------------------------*/
/*
 * Compare str1 and str2.
 *
 * It returns -1, 0 or 1 if str1 is found, to be less than, to be
 * equal to, or be greater than str2, respectively.
 */
/*----------------------------------------------------------------------------*/
/* int strcmp (const char *str1, const char *str2) */
/* { */

/*   while (*str1 != '\0' && *str1 == *str2) */
/*   { */
/*     str1++; */
/*     str2++; */
/*   } */

/*   return *str1 - *str2; */
/* } */
/*----------------------------------------------------------------------------*/
//#endif /* !HAVE_STRCMP */
/*----------------------------------------------------------------------------*/


/*----------------------------------------------------------------------------*/
//#if !defined(HAVE_STRNCMP)
/*----------------------------------------------------------------------------*/
/*
 * Compare at most len characters of str1 and str2.
 *
 * It returns -1, 0 or 1 if str1 is found, to be less than, to be
 * equal to, or be greater than str2, respectively.
 */
/*----------------------------------------------------------------------------*/
/* int strncmp (const char *str1, const char *str2, size_t len) */
/* { */
/*   int	c=0; */
  
/*   while ( c < len ) */
/*   { */
/*     if (*str1 != *str2 || *str1 == '\0') */
/*       return *str1 - *str2; */
/*     c++; */
/*     str1++; */
/*     str2++; */
/*   } */
  
/*   return 0; */
/* } */
/*----------------------------------------------------------------------------*/
//#endif /* !HAVE_STRNCMP */
/*----------------------------------------------------------------------------*/


/*----------------------------------------------------------------------------*/
//#if !defined(HAVE_STRCPY)
/*----------------------------------------------------------------------------*/
/*
 * Copies str2 to str1.
 *
 * Returns str1.
 */
/*----------------------------------------------------------------------------*/
/* char *strcpy(char *str1, const char *str2) */
/*   { */
/*   char	*str_p; */

/*   str_p = str1; */
/*   while (*str2 != '\0') */
/*     { */
/*     *str_p = *str2; */
/*     str_p++; */
/*     str2++; */
/*     } */

/*   *str_p = '\0'; */
  
/*   return str1; */
/*   } */
/*----------------------------------------------------------------------------*/
//#endif /* !HAVE_STRCPY */
/*----------------------------------------------------------------------------*/


/*----------------------------------------------------------------------------*/
/* #if !defined(HAVE_STRNCPY) */
/*----------------------------------------------------------------------------*/
/*
 * Copy str2 to str1 until len characters copied, or a null
 * character is found in str2.
 *
 * Returns str1.
 */
/*----------------------------------------------------------------------------*/
/* char *strncpy (char *str1, const char *str2, size_t len) */
/* { */
/*   char		*str1_p, null_reached = FALSE; */
/*   int		len_c; */
  
/*   for (len_c = 0, str1_p = str1; len_c < len && !null_reached; len_c++, str1_p++, str2++) */
/*   { */
/*     if (null_reached || *str2 == '\0') */
/*     { */
/*       null_reached = TRUE; */
/*       *str1_p = '\0'; */
/*     } */
/*     else */
/*     { */
/*       *str1_p = *str2; */
/*     } */
/*   } */
  
/*   return str1; */
/* } */
/*----------------------------------------------------------------------------*/
//#endif /* !HAVE_STRNCPY */
/*----------------------------------------------------------------------------*/


/*----------------------------------------------------------------------------*/
//#if !defined(HAVE_STRPBRK)
/*----------------------------------------------------------------------------*/
/*
 * Locate the first occurrence in the string s of any of the characters in the string accept.
 */
/*----------------------------------------------------------------------------*/
/* char *strpbrk(const char *s, const char *accept) */
/*   { */
/*   const char *s1; */
/*   const char *s2; */
 
/*   for (s1 = s; *s1 != '\0'; ++s1) */
/*     { */
/*     for (s2 = accept; *s2 != '\0'; ++s2) */
/*       { */
/*       if (*s1 == *s2) return (char *) s1; */
/*       } */
/*     } */
     
/*   return NULL; */
/*   } */
/*----------------------------------------------------------------------------*/
//#endif /* !HAVE_STRPBRK */
/*----------------------------------------------------------------------------*/


/*----------------------------------------------------------------------------*/
//#if !defined(HAVE_STRSEP)
/*----------------------------------------------------------------------------*/
/*
 * If *str is NULL, return NULL.  Otherwise, this find the first token
 * in the string *str, where tokens are delimited by symbols in the
 * string delim.  This token is terminated with a `\0' character (by
 * overwriting the delimiter) and *str is updated to point past the
 * token.  If no delimiter is found, the token is taken to be the
 * entire string *str, and *str is made NULL.
 *
 * Returns a pointer to the token (i.e returns the original value of *str)
 *
 * The strsep() function was introduced as a replacement for strtok(),
 * which cannot handle empty fields.
 */
/*----------------------------------------------------------------------------*/
/* char *strsep (char **str, const char *delim) */
/*   { */
/*   char *s = *str, *end; */

/*   if (!s) return NULL; */

/*   end = strpbrk(s, delim); */
/*   if (end) *end++ = '\0'; */
/*   *str = end; */

/*   return s; */
/*   } */
/*----------------------------------------------------------------------------*/
//#endif /* !HAVE_STRSEP */
/*----------------------------------------------------------------------------*/


/*----------------------------------------------------------------------------*/
//#if !defined(HAVE_STRCASECMP)
/*----------------------------------------------------------------------------*/
/*
 * Compare strings like strncmp(), but ignoring case.
 */
/*----------------------------------------------------------------------------*/
/* int strcasecmp (const char *str0, const char *str1) */
/*   { */

/*   while( tolower(*str0)==tolower(*str1) ) */
/*     { */
/*     if(*str0=='\0') */
/*       return 0; */
/*     str0++; */
/*     str1++; */
/*     } */

/*   return tolower(*str0)-tolower(*str1); */
/*   } */
/*----------------------------------------------------------------------------*/
//#endif /* !HAVE_STRCASECMP */
/*----------------------------------------------------------------------------*/


/*----------------------------------------------------------------------------*/
//#if !defined(HAVE_STRNCASECMP)
/*----------------------------------------------------------------------------*/
/*
 * Compare strings like strncmp(), but ignoring case.
 * ie, only compares first n chars.
 */
/*----------------------------------------------------------------------------*/
/* int strncasecmp (const char *str0, const char *str1, size_t n) */
/*   { */
/*   size_t i; */
  
/*   for(i=0; i<n && tolower(*str0)==tolower(*str1); i++, str0++, str1++) */
/*     if(*str0=='\0') */
/*       return 0; */

/*   return (i==n) ? 0 : (tolower(*str0)-tolower(*str1)); */
/*   } */
/*----------------------------------------------------------------------------*/
//#endif /* !HAVE_STRNCASECMP */
/*----------------------------------------------------------------------------*/


/*----------------------------------------------------------------------------*/
//#if !defined(HAVE_USLEEP)
/*
 * Sleep for a specified number of microseconds.
 * -- Should replace with the POSIX standard's nanosleep().
 */
/*----------------------------------------------------------------------------*/
//void usleep (unsigned long usec)
//{
//#ifdef W32_CRIPPLED
//# if USE_WINDOWS_H == 1
//  Sleep(usec/1000);		/* Windows sleep is in milliseconds. */
//#else
//  int	i;
//  for (i=0; i<usec*10; i++);	/* A completely dodgy kludge.  Just introduces an arbitrary length delay. */
//# endif
//#else
//# if defined(HAVE_SNOOZE)		/* i.e. BeOS, AtheOS, Syllable. */
//  snooze(usec/1000);		/* BeOS sleep is in milliseconds. */
//# else
//  struct timeval tv;
//  tv.tv_sec=0;
//  tv.tv_usec=usec;
//  select(0, NULL, NULL, NULL, &tv);
//# endif
//#endif

//  return;
//}
/*----------------------------------------------------------------------------*/
//#endif /* !HAVE_USLEEP */
/*----------------------------------------------------------------------------*/


/*----------------------------------------------------------------------------*/


/*----------------------------------------------------------------------------*/
//#if !defined(HAVE_MEMCMP)
//#if !defined(HAVE_BCMP)
/*
 * Some systems, such as SunOS do have BCMP instead.
 * In which case this is defined as a macro in the header.
 */
/*----------------------------------------------------------------------------*/
/* int memcmp (const void *src1, const void *src2, size_t n) */
/*   { */
/*   const unsigned char *cp1=src1; */
/*   const unsigned char *cp2=src2; */
   
/*   while (n-- > 0) if (*cp1++ != *cp2++) return (*--cp1 - *--cp2); */

/*   return 0; */
/*   } */
/*----------------------------------------------------------------------------*/
//#endif /* !HAVE_BCMP */
//#endif /* !HAVE_MEMCMP */
/*----------------------------------------------------------------------------*/


/*----------------------------------------------------------------------------*/
//#if !defined(HAVE_STRDUP)
/*----------------------------------------------------------------------------*/
/* char *strdup (const char *str) */
/*   { */
/*   char *new_str; */

/*   if (!str) return NULL; */

/*   new_str = s_malloc(sizeof(char)*(strlen(str)+1)); */
/*   strcpy(new_str, str); */

/*   return new_str; */
/*   } */
/*----------------------------------------------------------------------------*/
//#endif /* !HAVE_STRDUP */
/*----------------------------------------------------------------------------*/


/*----------------------------------------------------------------------------*/
//#if !defined(HAVE_STRNDUP)
/*----------------------------------------------------------------------------*/
/* char *strndup (const char *str, size_t n) */
/*   { */
/*   char *new_str=NULL; */

/*   if (str) */
/*     { */
/*     new_str = s_malloc(sizeof(char)*(n+1)); */
/*     strncpy(new_str, str, n); */
/*     new_str[n] = '\0'; */
/*     } */

/*   return new_str; */
/*   } */
/*----------------------------------------------------------------------------*/
//#endif /* !HAVE_STRNDUP */
/*----------------------------------------------------------------------------*/


/*----------------------------------------------------------------------------*/
#if HAVE_DIEF != 1
/*
 * Needed as a function because many compilers don't use vararg macros.
 * HAVE_DIEF is set in "SAA_header.h", not "config.h".
 */
/*----------------------------------------------------------------------------*/
void dief (const char *format, ...)
  {
  va_list       ap;                        /* variable args structure */

  printf("FATAL ERROR: ");
  va_start(ap, format);
  vprintf(format, ap);
  va_end(ap);
  printf("\n");

  abort();
  }
/*----------------------------------------------------------------------------*/
#endif /* HAVE_DIEF */
/*----------------------------------------------------------------------------*/


/*----------------------------------------------------------------------------*/
#if !defined(HAVE_WAITPID) && !defined(W32_CRIPPLED)
/*----------------------------------------------------------------------------*/
pid_t waitpid (pid_t pid, int *pstatus, int options)
  {
  pid_t result;

  do
    {
    result = wait(pstatus);
    } while (result >= 0 && result != pid);

  return result;
  }
/*----------------------------------------------------------------------------*/
#endif /* !HAVE_WAITPID */
/*----------------------------------------------------------------------------*/


/*----------------------------------------------------------------------------*/
#if !defined(HAVE_MIN)
/*----------------------------------------------------------------------------*/
int min (int a, int b)
  {
  return a <= b ? a : b;
  }
/*----------------------------------------------------------------------------*/
#endif
/*----------------------------------------------------------------------------*/


/*----------------------------------------------------------------------------*/
#if !defined(HAVE_MAX)
/*----------------------------------------------------------------------------*/
int max (int a, int b)
  {
  return a >= b ? a : b;
  }
/*----------------------------------------------------------------------------*/
#endif
/*----------------------------------------------------------------------------*/


/*----------------------------------------------------------------------------*/
#if !defined(HAVE_SINCOS)
/*----------------------------------------------------------------------------*/
/*
 * This is an undocumented GNU extension, which is actually fairly useful.
 */
/*----------------------------------------------------------------------------*/
void sincos (double radians, double *s, double *c)
  {

#ifdef __i386__
  __asm__ ("fsincos" : "=t" (*c), "=u" (*s) : "0" (radians));
#else
  *s = sin(radians);
  *c = cos(radians);
#endif

/*printf("DEBUG: sincos(%f) = %f %f\n", radians, *s, *c);*/

  return;
  }
/*----------------------------------------------------------------------------*/
#endif /* !HAVE_SINCOS */
/*----------------------------------------------------------------------------*/


/*----------------------------------------------------------------------------*/
#if !defined(HAVE_GETHOSTNAME)
/*----------------------------------------------------------------------------*/
/*
 * gethostname() - get host name

   This function is used to access the host name of the current processor.  It
   returns a NULL-terminated hostname by filling the array name with a length of
   len bytes.  In case the NULL-terminated hostname does not fit, no error is
   returned, but the hostname is truncated.  In the specification, it is
   unspecified whether the truncated hostname will be NULL-terminated, but here
   it is.

   What should happen is that upon success, zero is returned.  On error, -1 
   is returned, and errno is set to EINVAL.  But here the hostname is set to
   <unknown>.

  From the manpage:
       EINVAL len is negative or, for sethostname, len is larger than the
              maximum allowed size, or, for gethostname on Linux/i386, len
              is smaller than the actual size.  (In this last case glibc 2.1
              uses ENAMETOOLONG.)

   SUSv2 guarantees that host names are limited to 255 bytes.  POSIX
   1003.1-2006 guarantees that host names (not including the terminating
   NUL) are limited to HOST_NAME_MAX bytes.

 */
/*----------------------------------------------------------------------------*/
int gethostname (char *name, size_t len)
  {

  snprintf(name, len, "<unknown>");

  return TRUE;
  }
/*----------------------------------------------------------------------------*/
#endif /* !HAVE_GETHOSTNAME */
/*============================================================================*/

















/*******************************************************************************
 *                                                                             *
 *  Имя этого файла: c_log_util.c                                              *
 *                                                                             *

  Synopsis:	Portable routines for logging and debug messages.

		These functions can be tested by compiling with
		something like:
		gcc -o testlog log_util.c -DLOG_UTIL_TEST

		These functions are thread-safe.

  To do:	Seperate levels for callback, file, stderr outputs.
		Validate the logging level when set.
		Seperate levels/files/whatever possible for seperate files.
		Option for outputing the time.

 **********************************************************************/

//#include "c_all_util.h"
//#include "c_log_util.h"

/*
 * Global variables.
 *
 * NB/ log_filename and log_callback are meaningless on non-GNU C systems.
 */
static char		*log_filename=NULL;		/* Log filename */
static log_func		log_callback=NULL;		/* Callback function for log */
static enum log_level_type	log_level=LOG_NONE;	/* Logging level */
static boolean		log_date=TRUE;			/* Whether to display date in logs */

THREAD_LOCK_DEFINE_STATIC(gaul_log_callback_lock);
THREAD_LOCK_DEFINE_STATIC(gaul_log_global_lock);
THREAD_LOCK_DEFINE_STATIC(gaul_log_level_lock);

/*----------------------------------------------------------------------------*/
//#ifdef HAVE_MPI
/*----------------------------------------------------------------------------*/
/* static int mpi_get_rank(void) */
/*   { */
/*   int	rank; */

/*   MPI_Comm_rank(MPI_COMM_WORLD, &rank); */

/*   return rank; */
/*   } */
//#endif
/*----------------------------------------------------------------------------*/


/*----------------------------------------------------------------------------*/
//  synopsis:	Initialise logging facilities.  If func and fname are
//		both NULL, use stdout instead.
//  parameters:	int	level	Logging level.
//		char	*fname	Filename, or NULL.
//		log_func	func	Callback function, or NULL.
//  return:	none
/*----------------------------------------------------------------------------*/
void log_init (enum log_level_type	level,
               char			*fname,
               log_func		func,
               boolean			date)
{
  char	*oldfname=NULL;

  THREAD_LOCK (gaul_log_global_lock);

  log_level = level;
  if (fname)
  {
    if (log_filename != fname) oldfname = log_filename;
    log_filename = s_strdup (fname);
  }
  log_date = date;
  THREAD_UNLOCK (gaul_log_global_lock);

  THREAD_LOCK (gaul_log_callback_lock);
  log_callback = func;
  THREAD_UNLOCK (gaul_log_callback_lock);

  if (oldfname) s_free (oldfname);

  //#ifdef HAVE_MPI
  //  plog (LOG_VERBOSE, "Log started. (parallel with MPI)");
  //#else
  plog (LOG_VERBOSE, "Log started.");
  //#endif
  plog (LOG_DEBUG, "Debug output activated.");

  return;
}
/*----------------------------------------------------------------------------*/
//  synopsis:	Adjust logging level.
//  parameters:	int	level	New logging level.
//  return:	none
/*----------------------------------------------------------------------------*/
void 
log_set_level (const enum log_level_type level)
{
  THREAD_LOCK (gaul_log_level_lock);

  log_level = level;
  plog (LOG_VERBOSE, "Log level adjusted to %d.", level);

  THREAD_UNLOCK (gaul_log_level_lock);

  return;
}
/*----------------------------------------------------------------------------*/
//  synopsis:	Return logging level.
//  parameters:	none
//  return:	log_level
/*----------------------------------------------------------------------------*/
enum log_level_type log_get_level (void)
{

  return log_level;
}
/*----------------------------------------------------------------------------*/
//  synopsis:	Adjust log file.
//  parameters:	const char *fname	Filename for output.
//  return:	none
/*----------------------------------------------------------------------------*/
void 
log_set_file (const char *fname)
{
  char	*oldfname=NULL;

  THREAD_LOCK (gaul_log_global_lock);

  if (log_filename != fname) oldfname = log_filename;
  log_filename = s_strdup (fname);

  THREAD_UNLOCK (gaul_log_global_lock);

  if (oldfname) s_free (oldfname);

  plog (LOG_VERBOSE, "Log file adjusted to \"%s\".", fname);

  return;
}
/*----------------------------------------------------------------------------*/
//  synopsis:	If log level is appropriate, append message to log
//		file.  log_init() should really be called prior
//		to the first use of the function, although nothing will
//		break if you don't.
//  parameters:	int	level	Logging level.
//		char	format	Format string.
//		...		Variable args.
//  return:       none
/*----------------------------------------------------------------------------*/
void log_output (const enum	log_level_type level,
                 const char	*func_name,
                 const char	*file_name,
                 const int	line_num,
                 const char	*format, ...)
{
  va_list	ap;				/* variable args structure */
  char		message[LOG_MAX_LEN];	/* The text to write */
  FILE		*fh;				/* File handle */
  /* FIXME: Needs to be more general */
  const char	log_text[7][10] = {"?????: ", "FATAL: ", "WARNING: ",
                                   "",        "",
                                   "FIXME: ", "DEBUG: " };
  time_t	t;				/* Time structure */

  t = time(&t);	/* Less than optimal when no time display is required. */
  /* I tried variations on ctime(time()), withou success. */

  /*
    * Should message be dropped?
    * This test is only required if this function was called without the macro
    * wrapper - i.e. this is a non-GNU compiler.
    */
#if !defined(__GNUC__) && !defined(__INTEL_COMPILER)
  if (level > log_level) return;
#endif

  /* Generate actual message string */
  va_start(ap, format);
  vsnprintf(message, LOG_MAX_LEN, format, ap);
  va_end(ap);

  /* Call a callback? */
  THREAD_LOCK(gaul_log_callback_lock);
  if (log_callback)
    log_callback(level, func_name, file_name, line_num, message);
  THREAD_UNLOCK(gaul_log_callback_lock);

  /* Write to file? */
  THREAD_LOCK(gaul_log_global_lock);
  if (log_filename)
  {
    if ( !(fh=fopen(log_filename, "a+")) )
    {
      fprintf(stdout, "FATAL: Unable to open logfile \"%s\" for appending.\n", log_filename);
      abort();	/* FIXME: Find more elegant method */
    }

#ifdef HAVE_MPI
    fprintf(fh, "%d: %s%s%s%s\n",
            mpi_get_rank(),
            log_date?"":ctime(&t), log_date?"":" - ",
            log_text[level], message);
#else
    fprintf(fh, "%s%s%s%s\n",
            log_date?"":ctime(&t), log_date?"":" - ",
            log_text[level], message);
#endif

    if (level >= LOG_FIXME)
      fprintf(fh, "   in %s(), \"%s\", line %d\n",
              func_name, file_name, line_num);

    /*    fflush(fh);*/
    fclose(fh);
  }
  THREAD_UNLOCK(gaul_log_global_lock);

  /* Write to stdout? */
  if ( !(log_callback || log_filename) )
    {
#ifdef HAVE_MPI
      if (mpi_get_rank() >= 0)
        fprintf(stdout, "%d: %s%s%s%s\n", mpi_get_rank(),
                log_date?"":ctime(&t), log_date?"":" - ",
                log_text[level], message);
      else
#endif
        fprintf(stdout, "%s%s%s%s\n", 
                log_date?"":ctime(&t), log_date?"":" - ",
                log_text[level], message);

      if (level >= LOG_FIXME)
        fprintf(stdout, "   in %s(), \"%s\", line %d\n",
                func_name, file_name, line_num);

      /*fprintf(stderr, "%s%s\n", log_text[level], message);*/
      fflush(stdout);
    }

  return;
}
/*----------------------------------------------------------------------------*/


#if !( ( defined(__GNUC__) || defined(__INTEL_COMPILER) ) && !defined(__APPLE_CPP__) && !defined(__APPLE_CC__) )
/*----------------------------------------------------------------------------*/
/*
 * This is a reduced form of the above function for non-GNU systems.
 */
/*----------------------------------------------------------------------------*/
void 
plog (const enum log_level_type level, const char *format, ...)
{
  va_list       ap;                             /* variable args structure */
  char          message[LOG_MAX_LEN];     /* The text to write */
  const char    log_text[7][10] = {"?????: ", "FATAL: ", "WARNING: ",
                                   "",        "",
                                   "FIXME: ", "DEBUG: " };
  time_t        t;                              /* Time structure */

  t = time(&t);

  /* Call a callback? */
  THREAD_LOCK(gaul_log_callback_lock);
  if (log_callback)
    log_callback(level, "unknown", "unknown", 0, message);
  THREAD_UNLOCK(gaul_log_callback_lock);

  if ( (level) <= log_level )
  {
    va_start(ap, format);
    vsnprintf(message, LOG_MAX_LEN, format, ap);
    va_end(ap);

#ifdef HAVE_MPI
/*     if (mpi_get_rank() >= 0) */
/*       printf( "%d: %s%s%s%s\n", mpi_get_rank(), */
/*              log_date?"":ctime(&t), log_date?"":" - ", */
/*              log_text[level], message ); */
/*     else */
#endif
      printf( "%s%s%s%s\n",
             log_date?"":ctime(&t), log_date?"":" - ",
             log_text[level], message );
  }
  return;
}
/*----------------------------------------------------------------------------*/
#endif
/*----------------------------------------------------------------------------*/

/*----------------------------------------------------------------------------*/
/*
 * SLang intrinsic wrappers.
 */
/*----------------------------------------------------------------------------*/
//#ifdef HAVE_SLANG
/*----------------------------------------------------------------------------*/
/*----------------------------------------------------------------------------*/
//#endif	/* HAVE_SLANG */
/*============================================================================*/
