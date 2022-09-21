/*******************************************************************************
 *                                                                             *
 *  Имя этого файла: c_timer_util.c                                            *
 *                                                                             *
  ******************************************************************************
 */  
                                                                            
/**********************************************************************

  timer_util - Useful timer routines with S-Lang intrinsics.
  Copyright б╘2002-2006, Stewart Adcock <stewart@linux-domain.com>
  All rights reserved.

  Synopsis:	Timer routines with S-Lang intrinsics which are
		helpful for code analysis.

		These functions are thread-safe.

  Bugs:		Note that the user time will be incorrect after about
		72 minutes.

 **********************************************************************/

#include "c_timer_util.h"

/*----------------------------------------------------------------------------*/
//  Display diagnostic information.
/*----------------------------------------------------------------------------*/
void 
timer_diagnostics (void)
{
  printf ("=== Timer diagnostics ========================================\n");
  printf ("Version:                   %s\n", GA_VERSION_STRING);
  printf ("Build date:                %s\n", GA_BUILD_DATE_STRING);
  printf ("Compilation machine characteristics:\n%s\n", GA_UNAME_STRING);

  printf ("--------------------------------------------------------------\n");
  printf ("structure                  sizeof\n");
  printf ("chrono_t                   %lu\n", (unsigned long) sizeof(chrono_t));
  printf ("==============================================================\n");

  return;
}
/*----------------------------------------------------------------------------*/
//  synopsis:	Set or reset timer.
//  parameters:	chrono_t	t	The timer
/*----------------------------------------------------------------------------*/
void 
timer_start (chrono_t *t)
{
  t->begin_clock = t->save_clock = clock();
  t->begin_time = t->save_time = time(NULL);

  plog (LOG_NORMAL, "Timer started: %d", t->begin_clock);

  return;
}
/*----------------------------------------------------------------------------*/
//  synopsis:	Read timer.
//  parameters:	chrono_t	t	The timer
//  return:	user time in seconds.
/*----------------------------------------------------------------------------*/
double 
timer_check (chrono_t *t)
{
  double        user_time, real_time;
  clock_t	curclock = clock();
  time_t	curtime = time(NULL);

  plog (LOG_NORMAL, "Timer checked: %d", curclock);

  user_time = (curclock - t->save_clock) / (double) CLOCKS_PER_SEC;
  real_time = difftime(curtime, t->save_time);
  t->save_clock = curclock;
  t->save_time = curtime;

  plog (LOG_NORMAL, "User time: %f seconds.", user_time);
  plog (LOG_NORMAL, "Real time: %f seconds.", real_time);

  return user_time;
}
/*----------------------------------------------------------------------------*/
//  SLang intrinsic wrappers.
//  We can't use pointers from S-Lang, and structures are a pain in the
//  posterior, so we use a 
/*----------------------------------------------------------------------------*/
//#ifdef HAVE_SLANG
/*----------------------------------------------------------------------------*/

/*----------------------------------------------------------------------------*/
//#endif	/* HAVE_SLANG */
/*----------------------------------------------------------------------------*/

