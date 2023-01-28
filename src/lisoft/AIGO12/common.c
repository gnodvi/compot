// -*-  mode: c    ; coding: koi8   -*- ----------------------------------------

/*******************************************************************************
 *                                                                             *
 *  Имя этого файла: common.c                                                  *
 *                                                                             *
  ******************************************************************************
 */ 
                                                                            
#include  <stdio.h>
#include  <stdlib.h>   
#include  <string.h>
#include  <math.h>
#include  <time.h>  
#include  <unistd.h> 
#include  <ctype.h>  
#include  <dirent.h> 
#include  <sys/time.h> 
#include  <sys/param.h>
#include  <assert.h>
#include  <stdarg.h>
                                                                             
#include "common.h"

/******************************************************************************/

char left_buf[80] = "\0                                          ";
int  left_num     = 0;

//YT_BOOL debuging = FALSE;

int   max_level = 0;
int   num_level = 0;
char  str_level[80][80];
int   sgr_level[80] = {SGR_DEFAULT, SGR_CYAN, SGR_WHITE, SGR_GREEN, SGR_CYAN, SGR_WHITE};


/*-----------------------------------win_init----------------------------------*/
void
win_init (YT_WIN *win, CHAR ch)
{
  int i, j;

  for (i=0; i<win->h; i++)
    for (j=0; j<win->w; j++)
      win->p[i][j] = ch;

  for (i=0; i<win->h; i++)
    win->p[i][win->w] = '\0';

  return;
}
/*----------------------------------win_create---------------------------------*/
YT_WIN*
win_create (int w, int h)
{
  YT_WIN *win;

  win = (YT_WIN*) malloc (sizeof(YT_WIN));
  win->w = w;
  win->h = h;

  win_init (win, ' ');

  return (win);
}
/*----------------------------------win_delete---------------------------------*/
void
win_delete (YT_WIN *win)
{

  free (win);

  return ;
}
/*-----------------------------------win_char----------------------------------*/
void
win_char (YT_WIN *win, CHAR ch, int x, int y)
{

  if ((x<0) || (x>=win->w) || (y<0) || (y>=win->h)) {

    fprintf (stderr, "win_char Error: ch=%c  x=%d y=%d  w=%d h=%d  \n", 
             ch, x, y, win->w, win->h);
    return;
  } 

  win->p[y][x] = ch;

  return;
}
/*----------------------------------win_text-----------------------------------*/
void
win_text (YT_WIN *win, const char *text, int x, int y)
{
  int  i;
  char ch;

  for (i=0; TRUE ;i++) {
    ch = text[i];
    if (ch == '\0')	break;
    win_char (win, ch, x+i, y);
  }

  return;
}
/*----------------------------------win_draw-----------------------------------*/
void
win_draw (YT_WIN *win, int x, int y)
{
  int i/* , j */;
  //char buff[100] = "";
  //char left[100] = "";

/*   for (i=0; i < y; i++) puts (""); */

/*   for (j=0; j<x; j++) */
/*     left[j] = ' '; */
/*   left[j] = '\0'; */

  for (i=0; i < win->h; i++) {
    //strcpy (buff, left);
    //strcat (buff, (char*)(&(win->p[i][0])));
    //puts (buff);
    puts ((char*)(&(win->p[i][0])));
  }


  return;
}
/*----------------------------------win_horz-----------------------------------*/
void
win_horz (YT_WIN *win, CHAR  ch, int y_horz, int x1, int x2)
{
  int x;

  for (x=x1; x<=x2; x++)
    win_char (win, ch, x, y_horz);

  return;
}
/*-----------------------------------win_ver-----------------------------------*/
void
win_vert (YT_WIN *win, CHAR ch, int x_vert, int my_y1, int y2)
{
  int y;

  for (y=my_y1; y<=y2; y++)
    win_char (win, ch, x_vert, y);

  return;
}
/*-----------------------------------win_rect----------------------------------*/
void
win_rect (YT_WIN *win, CHAR ch_horz, CHAR  ch_vert, int x, int y, int w, int h)
{

  w--;
  h--;

  win_horz (win, ch_horz, y,   x, x+w);
  win_horz (win, ch_horz, y+h, x, x+w);

  win_vert (win, ch_vert, x,   y, y+h);
  win_vert (win, ch_vert, x+w, y, y+h);

  return;
}
/*-----------------------------------win_sgr----------------------------------*/
void
win_sgr (int par)
{

  fprintf (stderr, "\033[ %d m", par);

}
//*****************************************************************************
//*****************************************************************************


/*----------------------------------------------------------------------------*/
void 
dbg_set_maxlevel (int mlevel)
{

  max_level = mlevel;

}
/*----------------------------------------------------------------------------*/
void 
dbg_proc_beg (char *str, int expression)
{
  assert (expression);

  num_level++;
  strcpy  (str_level[num_level], str);
  win_sgr (sgr_level[num_level]);

  //OUTD (strlen(LEFT));
  //DBG_PRINT ("|%s| beg: %s \n", LEFT, str);
  DBG_PRINT ("BEG: %s \n", str);
  //DBG_PRINT ("beg: %s ", str);
  //fprintf (stderr, "-----------------");
  //DBG_PRINT ("\n");

  LEFT_BEG; 
  return;
}
/*----------------------------------------------------------------------------*/
void 
dbg_proc_end ()
{
  LEFT_END; 

  DBG_PRINT ("END: %s \n", str_level[num_level]);
  //DBG_PRINT ("end: %s ", str_level[num_level]);
  //fprintf (stderr, "-----------------");
  //DBG_PRINT ("\n");

  num_level--;

  win_sgr (sgr_level[num_level]);

  return;
}
/*----------------------------------------------------------------------------*/
void 
DBG_PRINT (char *fmt, ...)
{
  //if (!DEBUGING) 
  //  return;
  if (num_level > max_level) 
    return;

  va_list argp;

  //OUTD (left_num);
  fprintf (stderr, "%s", LEFT);

  // стандартный прием вывода переменных <stdarg.h>
  va_start (argp, fmt);
  vfprintf (stderr, fmt, argp);
  va_end   (argp);

  return;
}
/*--------------------------------YInt--------------------------------------*/ 
int 
YInt (float f) 
{ 
  int     i; 
  float   o; 
 
  i = (int) f; 
  o = f - i; 
  if      (o > 0.5)   i++; 
  else if (o < -0.5)  i--; 
 
  return (i); 
} 
/*----------------------------------------------------------------------------*/
void
Error (const char *msg)      
{

  fprintf (stderr, "Error: %s\n", msg);

  exit (0);
}
/*----------------------------------------------------------------------------*/
void
MyError (const char *msg)      
{

  if (is_pri) 
    fprintf (STDERR, "MyError: %s\n", msg);

  exit (0);
}
/******************************************************************************/
/******************************************************************************/
/*--------------------------------ZSortStrings--------------------------------*/ 
int 
zsortstrings_func (const void *a, const void *b) 
{ 
  char   *string1, *string2; 
 
  string1 = *((char **) a); 
  string2 = *((char **) b); 
  return (strcmp (string1, string2)); 
} 
/*--------------------*/ 
void 
ZSortStrings (char **ptr) 
{ 
  int     nelem = 0; 
 
  while ((*(ptr + nelem)) != NULL) 
    nelem++; 
  qsort ((void *) ptr, nelem, sizeof (*ptr), zsortstrings_func); 
 
  return; 
} 
/*-------------------------------ZSortDirStrings------------------------------*/ 
int 
zsortdirstrings_func (const void *a, const void *b) 
{ 
  char   *string1, *string2; 
 
  string1 = *((char **) a); 
  string2 = *((char **) b); 
  if (string1[0] == '\\' && string2[0] != '\\')  return (-1); 
  if (string1[0] != '\\' && string2[0] == '\\')  return (1); 
 
  return (strcmp (string1, string2)); 
} 
/*--------------------------------------*/ 
void 
ZSortDirStrings (char **ptr) 
{ 
  int     nelem = 0; 
 
  while ((*(ptr + nelem)) != NULL) 
    nelem++; 
  qsort ((void *) ptr, nelem, sizeof (*ptr), zsortdirstrings_func); 
 
  return; 
} 
/*--------------------------------YDirRead------------------------------------*/ 
char  **  
YDirRead (void) 
{ 
#define YMAXNUMBER 200 
#define YMAXLENGHT 20 
  int     i; 
  static char *buffer[YMAXNUMBER]; 
  static char fnames[YMAXNUMBER][YMAXLENGHT]; 
 
#if defined(BORL_D) || defined(BORL_W) /*---------------------*/           
           
  struct ffblk ffblk;           
  int done;           
           
  i=0;           
  done = findfirst("*.*", &ffblk ,FA_DIREC);           
  while (!done) {           
    if (strcmp(ffblk.ff_name,".")==0)     goto NEXT;           
    if (ffblk.ff_attrib==FA_DIREC) fnames[i][0]='\\';           
    else                           fnames[i][0]=' ';           
    if (strlen(ffblk.ff_name)>YMAXLENGHT-2 || i>YMAXNUMBER-1)           
      YError("ZScanDir");           
    strcpy(&(fnames[i][1]),ffblk.ff_name);           
    buffer[i]=fnames[i];           
    i++;           
  NEXT:           
    done=findnext(&ffblk);           
}           
//emgena #elif defined(MICR_W) || defined(GCC__W) || defined(LCC__W) // Changes made by Ozerski 
#elif defined(GCC__W) 
#elif defined(MICR_W) || defined(LCC__W) // Changes made by Ozerski 
           
  struct _finddata_t ffblk; 
  long    hFile; 
  YT_BOOL done = FALSE; 
 
  i = 0; 
  hFile = _findfirst ("*.*", &ffblk); 
 
  if (hFile == -1L) 
    done = TRUE; 
  while (!done) { 
    if (strcmp (ffblk.name, ".") == 0) 
      goto NEXT; 
    if (ffblk.attrib & _A_SUBDIR)  fnames[i][0] = '\\'; 
    else                           fnames[i][0] = ' '; 
 
    if (strlen (ffblk.name) > YMAXLENGHT - 2 || i > YMAXNUMBER - 1) 
      YError ("YDirRead"); 
    strcpy (&(fnames[i][1]), ffblk.name); 
    buffer[i] = fnames[i]; 
    i++; 
  NEXT: 
    if (_findnext (hFile, &ffblk) == -1L) 
      done = TRUE; 
  } 
  _findclose (hFile); 
#else /*--------------------*/ 
 
  DIR    *dirp, *dirtemp; 
  struct dirent *direntp; 
  dirp = opendir ("."); 
  i = 0; 
  while ((direntp = readdir (dirp)) != NULL) { 
    if (!strcmp (direntp->d_name, ".")) 
      continue; 
    if ((dirtemp = opendir (direntp->d_name))) { 
      fnames[i][0] = '\\'; 
      closedir (dirtemp); 
    } else 
      fnames[i][0] = ' '; 
 
    if (strlen (direntp->d_name) > YMAXLENGHT - 2 || i > YMAXNUMBER - 1) 
      /* YError */YERROR ("YDirRead"); 
    strcpy (&(fnames[i][1]), direntp->d_name); 
    buffer[i] = &(fnames[i][0]); 
    i++; 
  } 
  closedir (dirp); 
 
  buffer[i] = NULL; 
  ZSortDirStrings (buffer); 
 
  return (buffer); 
#endif 
} 
/******************************************************************************/
/******************************************************************************/
