// -*-  mode: c    ; coding: koi8   -*- ----------------------------------------

/*******************************************************************************
 *                                                                             *
 *  Имя этого файла: common.c                                                  *
 *                                                                             *
  ******************************************************************************
 */ 
// abvgdeewziklmnoprstufxch[]'=`\yq  
// это тест на русские БУКВЫ  русскиe \\\/////                                                       

#include "common.h"
#include "cgp.h"

/******************************************************************************/

//BOOL    ERR_PRINT = FALSE /* TRUE */;
//YT_BOOL debuging = FALSE;
//BOOL    debug = FALSE;

int verbose = 0;

/*----------------------------------------------------------------------------*/
/*----------------------------------------------------------------------------*/
int 
YInt (double f) 
{ 
  int     i; 
  double   o; 
 
  i = (int) f; 
  o = f - i; 
  if      (o > 0.5)   i++; 
  else if (o < -0.5)  i--; 
 
  return (i); // ближайшее целое
} 
/*----------------------------------------------------------------------------*/
void
Error (const char *msg)      
{

  fprintf (stderr, "Error: %s\n", msg);
  exit (EXIT_FAILURE);

}
/*----------------------------------------------------------------------------*/
void 
srandom_set (int seed)
{

  if (seed < 0) srandom (time(0)); // переменная псевдослучайность
  else          srandom (seed);    // фиксированная 

  return;
}
/*----------------------------------------------------------------------------*/
double
YRandF (double fmin, double fmax)
{
  double   choise;

  choise = drand48 ();

  return (fmin + choise * (fmax - fmin));
}
/*----------------------------------------------------------------------------*/
int
Rand123 (double p1, double p2, double p3)
{
  int yrand;

  yrand = YRAND (1,100);
  //fprintf (stderr, "Rand123: %d \n", yrand); 

  if      (yrand < p1) return (1);
  else if (yrand > p3) return (3);
  else                 return (2);

  p2++;
}
/*----------------------------------------------------------------------------*/
BOOL
RandYes (double procent)
{

  if (Rand123 (procent, 0.0, 100.0-procent)==1)
    return (TRUE);
  else
    return (FALSE);

}
/*----------------------------------------------------------------------------*/
BOOL
FRavno (double d1, double d2, double eps)
{

  if (fabs(d1-d2) < eps) return TRUE;
  else                   return FALSE;

}
/*----------------------------------------------------------------------------*/
BOOL
str_cmp (const char *str1, const char *str2)
{
  if (!str1 || !str2) return (FALSE);


  return (!(strcmp(str1, str2)));
}
/*----------------------------------------------------------------------------*/
BOOL                                                                         
YStrCmp (char *str1, char *str2)                                                
{                                                                               
  if (!str1 || !str2) return (FALSE);                                           
                                                                                
  return (!(strcmp(str1, str2)));                                               
}                                                                               
/*----------------------------------------------------------------------------*/
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
/******************************************************************************/
//   ВРЕМЯ: отсечка, формирование строк, печать

/*----------------------------------------------------------------------------*/
char*
time_calc_printa (int mode)
{
  static time_t    tim_beg, tim_end, tim_all, tim_min, tim_sec, tim_hor;
  static char   buffer[80];

  //-------------------------------
  if (mode==0) {
    tim_beg = time (NULL);

    printf ("Started Time = \n");
    return (buffer);
  }
  //-------------------------------

  tim_end = time (NULL);

  tim_all = tim_end - tim_beg;
  tim_hor = tim_all / 3600;
  tim_all = tim_all % 3600;
  tim_min = tim_all / 60;
  tim_sec = tim_all % 60;

  sprintf (buffer, "%ld:%2ld:%2ld", tim_hor, tim_min, tim_sec);

  //-------------------------------
  if (mode == -1) { // получить промежуточный результат в виде простой строки
    return (buffer);
  }
  //-------------------------------

  printf ("Elapsed Time = {%s} \n", buffer);
  printf ("\n");
  return (buffer);
}
/*----------------------------------------------------------------------------*/
long  
YTimeGet ()  
{			  
  struct timeval  tp;  
  struct timezone tz; 
 
  gettimeofday (&tp, &tz);  
  return (tp.tv_sec * 100 + tp.tv_usec / 10000);  

  return (100);  
}   
/*----------------------------------------------------------------------------*/
double
TimeSec () 
{	
  struct timeval tp; 
  struct timezone tz; 

  gettimeofday (&tp, &tz); 
  //printf ("tv_sec= %ld  tv_usec= %ld  \n", tp.tv_sec, tp.tv_usec);
  //return (tp.tv_sec * 100 + tp.tv_usec / 10000); 

  return (tp.tv_sec + tp.tv_usec / 1000000.0); 
} 
/*----------------------------------------------------------------------------*/
double
YSecOfDay ()
{
  struct timeb tb;

  ftime (&tb);
  return (tb.time + tb.millitm / 1000.0);

}
/*----------------------------------------------------------------------------*/
YT_TIMER*
timer_beg ()
{
  YT_TIMER *t = (YT_TIMER*) malloc (sizeof(YT_TIMER));

  t->tim_beg = time (NULL);

  return (t);
}
/*----------------------------------------------------------------------------*/
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
/*----------------------------------------------------------------------------*/
void
timer_end (YT_TIMER *t, char *hms_time)
{
  time_t /* tim_end, tim_all,  */tim_min, tim_sec, tim_hor;

  timer_hms (t, &tim_hor, &tim_min, &tim_sec);

  //sprintf (hms_time, "%d:%02d:%02d", (int)tim_hor, (int)tim_min, (int)tim_sec);
  sprintf (hms_time, "{%d:%02d:%02d}", (int)tim_hor, (int)tim_min, (int)tim_sec);

  //free (t); //???
  // ломается после записи 2-ных массивов (невыявленная ошибка);
  return;
}
/*----------------------------------------------------------------------------*/
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
/******************************************************************************/
/******************************************************************************/
/******************************************************************************/
//------------------------------------------------------------------------------
struct dataSet *make_data_function (YT_MAKEFUNC makefunc) 
{

  int i;
  struct dataSet *data = NULL;

  double inputs [NUMSAMPLES][NUMINPUTS];
  double outputs[NUMSAMPLES][NUMOUTPUTS];

  double inputTemp;
  double outputTemp;

  for(i=0; i<NUMSAMPLES; i++){

    inputTemp  = (i * (INPUTRANGE/(NUMSAMPLES-1))) - INPUTRANGE/2;
    //outputTemp = symbolicEq1 (inputTemp);
    outputTemp = makefunc (inputTemp);

    inputs [i][0] = inputTemp;
    outputs[i][0] = outputTemp;
  }

  data = initialiseDataSetFromArrays (NUMINPUTS, NUMOUTPUTS, NUMSAMPLES, 
                                     inputs[0], outputs[0]);

  return (data);
}
/******************************************************************************/
/******************************************************************************/
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
                 )
{
  char c;

  // optarg - указатель на текущий аргумент, если таковой имеется
  // optind - индекс на след. указатель argv (будет обработан при след. вызове)
  optind = 1; // чтобы бы повторном (вложенном вызове) начать с начала 


  // перебираем все параметры:
  // (в QNX эти параметры должны идти первыми)

  while ((c = getopt (argc, argv, "hvt:b:s:d:u:f:n:")) != -1) { 

    switch (c) {

    case 't': // 
      if (p_buf)   strcpy (p_buf, optarg); 
      break;

    case 's': 
      if (seed)    *seed = atoi (optarg); 
     break;

    case 'd': 
      if (data)    *data = atoi (optarg); 
      break;

    case 'u': 
      if (update)  *update= atoi (optarg); 
      break;

    case 'f': 
      if (fitness) *fitness = atof (optarg); 
      break;

    case 'n': 
      if (nums)    *nums = atoi (optarg); 
      break;

    case 'v':     // verbose - многословный
      if (verbose) *verbose  = 1; // подробная печать 
      break;

    default:      
      exit( EXIT_FAILURE ); // сюда невозможно попасть!
    }
  }


  return;
}
//------------------------------------------------------------------------------
/******************************************************************************/
/******************************************************************************/
