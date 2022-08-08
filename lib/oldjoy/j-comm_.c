// -*-  mode: c    ; coding: koi8   -*- ----------------------------------------

//------------------------------------------------------------------------------
// 
// Модуль   : i-comm.c
// Изменен  : 
// Автор    : 
// 
// Комментарии: 
// 
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

#include <stdio.h>    // printf
#include <string.h>   // memset
#include <stdlib.h>   // exit(0);
#include <arpa/inet.h>

#include <sys/socket.h>
#include <pthread.h>
#include <semaphore.h>

#include <math.h>
 
#include <stdlib.h>
#include <stdio.h>
#include <malloc.h>
#include <string.h>
#include <netinet/in.h>
#include <string.h>
#include <stdio.h>
#include <errno.h>
#include <unistd.h>
#include <limits.h>
#include <libgen.h>

#include <ctype.h>
#include <sys/time.h>
#include <sys/types.h>

#include <stdlib.h>
#include <unistd.h>
#include <stdio.h>
#include <signal.h>
#include <time.h>

  //#include <sys/socket.h>
#include <pthread.h>
#include <semaphore.h>
 
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------

#include "j-comm_.h"
 

//------------------------------------------------------------------------------
// 
//
//
//
//------------------------------------------------------------------------------
void
get_options_print_help () 
{

  printf ("\n");
  printf ("USE: \n");
  printf ("./s_dial -t* -p* -o* \n");
  printf ("\n");      
  
}
//------------------------------------------------------------------------------
void
options_warning_NULL (char c) {

  fprintf (stderr, "\n");
  fprintf (stderr, "WARNING OPTIONS: pointer to -%c == NUL !! \n", c);
  //fprintf (stderr, "\n");

  return;
}
//------------------------------------------------------------------------------
void
get_options_NVU (int argc, char **argv,
 
             char  *p_buf, 

             int *test_num,
             int *is_verbose, 
             int *user_flag)
{
  char c;

  // optarg - указатель на текущий аргумент, если таковой имеется
  // optind - индекс на след. указатель argv (будет обработан при след. вызове)
  optind = 1; // чтобы бы повторном (вложенном вызове) начать с начала 


  // перебираем все параметры:
  // (в QNX эти параметры должны идти первыми)

  while ((c = getopt (argc, argv, "uhvt:b:")) != -1) { 

    switch (c) {

    case 'b': // 
      if (p_buf) strcpy (p_buf, optarg); 
      else        options_warning_NULL (c);
      break;

    case 'v':     // verbose - многословный
      if (is_verbose) *is_verbose  = 1; // подробная печать 
      else             options_warning_NULL (c);
      break;

    case 't': 
      if (test_num) *test_num = atoi (optarg); 
       else          options_warning_NULL (c);
     break;

    case 'u':    
      if (user_flag) *user_flag  = 1;
      else           options_warning_NULL (c);
      break;

    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    case 'h': 
      get_options_print_help (); 
      break;


    default:      
      exit( EXIT_FAILURE ); // сюда невозможно попасть!
    }
  }


  return;
}
//------------------------------------------------------------------------------
// 
//------------------------------------------------------------------------------
void ERROR_ (char *message)
{

  printf ("\n");
  printf ("ERROR: %s \n", message);
  printf ("\n");

  exit (0);
}
//------------------------------------------------------------------------------
// 
//------------------------------------------------------------------------------
