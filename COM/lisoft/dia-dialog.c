// -*-  mode: c    ; coding: koi8   -*- ----------------------------------------

/****************************************************************************
 *                                                                          *
 *  dialog.c  --  demo and examples;                                        *
 *                                                                          *
 *  Copyright (c) 2000, Life Software.                                      *
 *                                                                          *
 *  This program is free software; you can redistribute it and/or modify    *
 *  it under the terms of the GNU General Public License as published by    *
 *  the Free Software Foundation; either version 2 of the License, or       *
 *  (at your option) any later version.                                     *
 *                                                                          *
 *  This program is distributed in the hope that it will be useful,         *
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of          *
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the           *
 *  GNU General Public License for more details.                            *
 *                                                                          *
 *  You should have received a copy of the GNU General Public License       *
 *  along with this program; if not, write to the Free Software             *
 *  Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.               *
 *                                                                          *
 *                            Life Software,                                *
 *              [see file ADDRESS for more information]                     *
 *                                                                          *
 ****************************************************************************
 */                                                                          


#ifdef  D_MATFUN  
/*************************************************************************/

/* #include "y_open.h"  */
#include "dia-y_zone.h" 
/* #include "matfun.h"  */
#include "dia-svisor.h" 

/*-------------------------------main--------------------------------------*/
int
main (int argc, char *argv[])
{

 /*  YInitKernel (); */
  /* YInitCEXT (); */

  MGrafTest ();

  return (0);

}
/*-------------------------------------------------------------------------*/
/***************************************************************************/

#endif
#ifdef  D_STUDIO  

/*************************************************************************
 *                                                                       *
 *                     Demo for ""                                       *  
 *                                                                       *
 *************************************************************************
 */ 

/* #include "y_open.h"  */
/* #include "y_more.h"  */
#include "dia-y_zone.h" 


/*------------------------------studio_proc----------------------------------*/
long
studio_proc (PFUNC_VAR)       
{        

  static char *big_menu[] = {
    "Buffers",   
    "  New Window", 
    "  ---",  
    "  Open ...",
    "  Save",     
    "  Save All",     
    "  Save As ...",     
    "  ---",  
    "  Kill",     
    "  Split",     
    "  Unsplit",     
    "  List All",     
    "  ---",  
    "  Exit",     
    "Edit",
    "  Undo",
    "  Redo",
    "  ---",  
    "  Cut",
    "  Copy",
    "  Paste",

    "Search",
    "  Find ...",
    "  Find Again ...",
    "  ---",  
    "  Replace ...",
    "  Replace Again",
    "  ---",  
    "  Goto Line",
    "Project",
    "  Open ...",
    "  Close ...",
    "  New",
    "  ---",  
    "  Options ...",
    "  ---",  
    "  Run ...",
    "Compile",
    "  Make All",
    "  Make ...",
    "  ---",  
    "  Next Error",
    "  Prev Error",
    "  ---",  
    "  Help Error",
    "Debug",
    "  Run/Continue",
    "  Stack Next",
    "  Stack Prev",
    "  ---",  
    "  Goto",
    "  Step",
    "  Next",
    "  ---",  
    "  Set B-point",
    "  Del B-point",
    "  ---",  
    "  Stop",
    "Options",
    "  Big Menu",
    "  Min Menu",
    "  ---",  
    "  Text Font",
    "Help",
    "  About",
    "" 
  };

  static char *min_menu[] = {
    "Buffers",   
    "  New Window", 
    "  ---",  
    "  Open ...",
    "  Save",     
    "  Save All",     
    "  Save As ...",     
    "  ---",  
    "  Kill",     
    "  Split",     
    "  Unsplit",     
    "  List All",     
    "  ---",  
    "  Exit",     
    "Edit",
    "  Undo",
    "  Redo",
    "  ---",  
    "  Cut",
    "  Copy",
    "  Paste",
    "Search",
    "  Find ...",
    "  Find Again ...",
    "  ---",  
    "  Replace ...",
    "  Replace Again",
    "  ---",  
    "  Goto Line",
    "Options",
    "  Big Menu",
    "  Min Menu",
    "  ---",  
    "  Text Font",
    "Help",
    "  About",
    "" 
  };

  static char *multi_text[] = {
    "line1_ this is test line", 
    "line2_ this is test line", 
    "line3_ this is test line", 
    "line4_ this is test line", 
    "line5_ this is test line", 
    "line6_ this is test line", 
    NULL
  };

  static int hMenu, hText;
  static char **ptr_menu;
  char *str;
  int  h_menu = 30, x, y, w, h;


  switch (message) {       
  case YOPEN: 
    ptr_menu = big_menu;
  case YDRAW:       
    YDrawRectF (0,0, WND->w,WND->h, YColor("yellow"));        
  case YREDRAW:       
    YWnd (&hMenu, TOPMENU, "", 1, 1, WND->w-2, h_menu, (long) ptr_menu, 0, 0, 0, YColor("aqua")); 

    x = 20;
    y = 20+h_menu;
    w = WND->w-40;
    h = WND->h-h_menu-40;
    /* YWnd (&hText, EDIT, NULL,  x, y, w, h, (long)"string2",0,0,0, YColor("white")); */  
    YWnd (&hText, EDIT, NULL,  x, y, w, h, (long)multi_text[0],0,0,0, YColor("white"));  
    YDrawLine (x, y+h, x+w, y+h, YColor("black"));
    YDrawLine (x+w, y, x+w, y+h, YColor("black"));

    break;        
  case YMENU:
    str = (char *)mes3;
    YSWITCH (str) {
    YCASE ("Buffers/Exit")
      YExit (0);
    YCASE ("Options/Min Menu")
      YUnWnd (hMenu);
      ptr_menu = min_menu;
      YGoto (YREDRAW, 0, 0, 0, 0);
    YCASE ("Options/Big Menu")
      YUnWnd (hMenu);
      ptr_menu = big_menu;
      YGoto (YREDRAW, 0, 0, 0, 0);
    YDEFAULT
      YMessageBox ("Sorry, ...!", "Ok");
    }
    break;
  case YCLOSE:       
    YWndClose (id);        
    break; 
  default: ;;;
  }       
  
  RETURN_TRUE;
}
/*-------------------------------MAIN-----------------------------------*/
long
MAIN (PFUNC_VAR)
{

  switch (message) {
  case YCREATE:
    /* YInitDRAW (); */
    YInitWIND (); 

    YBigWindow (NULL, studio_proc, "Y-Studio", 0,0, 640,480, 0,0,0,0, CLR_DEF);     
    break; 
  }

  id++;
  RETURN_TRUE;
}
/*******************************************************************************/

#endif
#ifdef  D_SONGER  

/*=========================================================================*/


/* #include "y_open.h"  */
/* #include "y_more.h"  */
#include "dia-y_zone.h" 
    

/****************************************************************************/

enum ykeys_global {
  YAKKORD = YKEY_LEVEL4
}; 

#define SIZE_S     100
#define NUM_POROG  5
#define NUM_STRUN  6
#define NUM_LADS   12
#define AKK_LEN    7

#define NUM_SDEF       10
#define MAX_NUM_SHEMES 20
#define MAX_NUM_VARS   6

#define NUM_NOTES      12
#define NUM_OKTAV      5
#define NUM_SHEMENAMES 5
#define MAX_LINES      5000

typedef struct {
  int     akk[AKK_LEN];
} SN_AKK;

#define SIZE_ARXIV 100
typedef struct {
  int     type;
  char    aname[30];
  char   *paname;
  int     i, j;
} SN_ARXIV;

#define OFFSET_MAX 50
#define COL_SIZE_DARKS  9
typedef struct {
  int      grif[NUM_STRUN];
  int      absnot[NUM_STRUN];
  int      freq[NUM_OKTAV + 1];
  char    *sheme_list[MAX_NUM_SHEMES][NUM_SHEMENAMES];
  char    *notes_list[NUM_NOTES + 1];
  int      sdef[MAX_NUM_SHEMES][NUM_SDEF];
  SN_AKK   a[NUM_NOTES][MAX_NUM_SHEMES][MAX_NUM_VARS];
  int      num_shemes;
  SN_ARXIV ar[SIZE_ARXIV];
  int      num_arxiv;
  int      marg_left, marg_top, marg_bottom;
  int      offset[OFFSET_MAX][2];
  int      offset_num;
  char     fname[50];
  int      step_lines;
  int      w_akk, h_akk, uw, uh;
  char   **text;
  YT_COLOR clr_backgr, clr_foregr, clr_akkbackgr, clr_akkforegr;
  YT_COLOR darks[COL_SIZE_DARKS];
} SN_MUSIC;

long    SONGS      (PFUNC_PAR);
long    songs_proc (PFUNC_PAR);
long    songs_akk  (PFUNC_PAR);
long    songs_dlg  (PFUNC_PAR);

YT_BOOL SnDrawAkkord (SN_MUSIC*, char*, int, int, int, int, int, YT_COLOR, YT_COLOR);
void    SnDrawSetka (SN_AKK*, int, int, int, int, YT_COLOR);
void    SnBaseSave (SN_MUSIC*, char *);
void    SnReadBase (SN_MUSIC*, char *);
YT_BOOL SnAnameToAkk (SN_MUSIC*, char*, SN_AKK*, int);
void    SnCorrectBas (SN_MUSIC*, SN_AKK*, int);
void    SnReadFile (char*, char**, int*, int*);
void    SnSaveFile (char *, char**, int);
YT_BOOL SnSnoteToNote (SN_MUSIC*, char *, int *);
void    SnBnameToAkk (char*, SN_AKK*);
YT_BOOL SnAnameToIndex (SN_MUSIC *, char *, int *, int *, int *, int *);
void    StringDelLimits (char *);
void    SnAkkToBaza (SN_MUSIC *, SN_AKK *, int, int, int);
void    SnArxivInit (SN_MUSIC *);
void    SnArxivAdd (SN_MUSIC *, int , char *, int , int , int , int);
void    SnArxivDraw (SN_MUSIC *);
void    SnArxivSave (SN_MUSIC *);
void    SnArxivGetXY (SN_MUSIC *, SN_ARXIV *, int *, int *);
SN_ARXIV *SnFindAkk (SN_MUSIC *, int , int );
void    SnPlayAkkord (SN_MUSIC *, char *, int);
int     SnGetFreq (SN_MUSIC *, int , int );
void    SnDrawStroka (SN_MUSIC *, char *, int, int);
void    SnDrawPage (SN_MUSIC *, char **, int, int, int);
void    SnPrint (SN_MUSIC *, char **, int);
void    SnDrawOffset (SN_MUSIC *, int, int, int, int);
YT_BOOL SnVarChange (SN_MUSIC *, SN_ARXIV *);
YT_BOOL SnTnChange (SN_MUSIC *, SN_ARXIV *, int);
void    SnTnMake (SN_MUSIC *, char **, int);
int     SnTnGet (SN_MUSIC *, int );
void    SnItemDraw (SN_MUSIC *, SN_ARXIV *);
void    SnSetNullakk (SN_AKK *);
YT_BOOL SnIsNullakk (SN_AKK *);
void    SnParseSheme (SN_MUSIC *, int, char *);
void    SnTnZanull (SN_MUSIC *, char **, int);
void    SnSetkaDraw (char *, int, int, int, int, int, int, YT_COLOR);


/*---------------------------------MAIN---------------------------------------*/
long
MAIN (PFUNC_VAR)
{
  int    argc, index; 
  char **argv;

  switch (message) {
  case YCREATE:
    /* YInitDRAW (); */

    argc = mes2;
    argv = (char**) mes3;
    for (index = 1; index < argc; index++) 
      if (strcmp (argv[index], "-font") == 0) 
/* 	YSet ("font", (long)(argv[++index])); */
	Y_FONT = argv[++index];
    
    YInitWIND ();    
    YBigWindow (NULL, songs_proc, NULL, 0,0, 0,0, 0,0,0,0, CLR_DEF);     
    break;   
  case YFINAL:
    /*YBeep();*/
    YFinalYlib ();
    break; 
  default:;;;
  }
  
  id++;  
  RETURN_TRUE;
}
/*-------------------------------songs_proc-----------------------------------*/
long
songs_proc (PFUNC_VAR)
{
  int     W, H;
  float   koef = 1.0  /* 0.85 */; 

  switch (message) {
  case YGET:
    W = YLINER (YGet("wdisplay"), 640, 640, 1280, 800);
    H = YLINER (YGet("hdisplay"), 480, 480, 1024, 650);
    if      (id == 1) return (W*koef);
    else if (id == 2) return (H*koef);
    else if (id == 3) return ((long)"Songster");
  case YOPEN:
  case YDRAW:
    YWnd (Ph(), RAMKA, "My love songs", 0,0, WND->w,WND->h, 0 ,TRUE, 
                                          (long)SONGS,0, YColor("aqua"));
    break;
  case YCLOSE:
    YWndClean (id);
    break;
  default:;;;
  }

  RETURN_TRUE;
}
/*------------------------------SONGS---------------------------------------*/
long
SONGS (PFUNC_VAR)
{
  int     i, j, line_top_new;
  SN_ARXIV *par;
  long    ff;
  static char *butts[] = {
    "Open", "Update", "Save", "Options", "Chords", "Null", "Exit",
    NULL
  };

  static int num_lines = 0, num_chars, line_top, line_top_max, line_bot,
          numstr;
  static char *text[MAX_LINES];
  static SN_MUSIC *mus;
  static SN_MUSIC music =
  {
    {4, 11, 7, 2, 9, 4},
    {0, 5, 10, 15, 19, 24},
    {100, 200, 300, 400, 500, 600}
  };
  static int uw, uh;

  switch (message) {
  case YGETCOMS:
    *((long*)mes3) = (long)butts;
    break;
  case YOPEN:
    mus = &music;
    for (i = 0; i < MAX_LINES; i++)
      text[i] = NULL;
    uw = YStringW ("W");
    uh = YStringH ("W");
    mus->marg_top = mus->marg_bottom = 2 * uh;
    mus->w_akk = 5.6 * uw;
    mus->h_akk = 2.3 * uh;
    mus->step_lines = 2.7 * uw;
    mus->uw = uw;
    mus->uh = uh;
    mus->text = text;
    mus->clr_backgr = YColor("silver");
    mus->clr_foregr = YColor("black");
    mus->clr_akkbackgr = YColor("yellow");
    mus->clr_akkforegr = YColor("red");

    mus->darks[0] = YColor("black");
    mus->darks[1] = YColor("red");
    mus->darks[2] = YColor("green");
    mus->darks[3] = YColor("blue");
    mus->darks[4] = YColor("yellow");
    mus->darks[5] = YColor("green");
    mus->darks[6] = YColor("fuchsia");
    mus->darks[7] = YColor("olive");
    mus->darks[8] = YColor("purple");

    for (i = 0; i < MAX_NUM_SHEMES; i++)
    for (j = 0; j < NUM_SHEMENAMES; j++)
      (mus->sheme_list)[i][j] = NULL;
    SnReadBase (mus, "dia-snbase.txt");
    YGoto (YREAD, 0, 0, (long)"dia-snbook.txt", 0);
    YGoto (YDRAW, 0, 0, 0, 0);
    break;
  case YDRAW:
    numstr = (WND->h - mus->marg_top - mus->marg_bottom) / mus->step_lines + 1;
    line_top_max = (num_lines - 1) - (numstr - 1);
    YGoto (YREDRAW, 0, 0, 0, 0);
    YSetFocus (id);
    break;
  case YREDRAW:
    mus->marg_left = YMAX (20, (WND->w - num_chars * uw) / 2);
    YDrawRectF (0, 0, WND->w, WND->h, mus->clr_backgr);
    YSetCliping (TRUE, 0, 0, WND->w, WND->h);
    SnDrawPage (mus, text, line_top, numstr, num_lines);
    YSetCliping (FALSE, 0, 0, 0, 0);
    line_bot = line_top + numstr - 1;
    YSend (WND->parent, YSC_SET, num_lines, numstr, line_top, 0);
    break;
  case YLBUTT:
    YSWITCH ((char*)mes3) {
    YCASE ("Open")
      if (!(ff = YFindFile ())) 
	break;
      YGoto (YREAD, 0, 0, ff, 0);
      YGoto (YDRAW, 0, 0, 0, 0);
    YCASE ("Update")
      YGoto (YUPDATE, 0, 0, 0, 0);
      YGoto (YDRAW,  0, 0, 0, 0);
    YCASE ("Save")
      if (YMessageBox ("You are sure?", "Yes_No") == 2) 
	break;
      SnSaveFile (mus->fname, text, num_lines);
    YCASE ("Options")
      if (!YDlg (songs_dlg, "Options", 0,0,0,0, (long)mus,0,0,0, CLR_DEF, TRUE)) 
	break;
      YGoto (YDRAW, 0, 0, 0, 0);
    YCASE ("Chords")
      YDlg (songs_akk, "Chords builder", 0,0,0,0, (long)mus,0,0,0, CLR_DEF, TRUE);
    YCASE ("Null")
      if (YMessageBox ("You are sure?", "Yes_No") == 2) 
	break;
      SnTnZanull (mus, text, num_lines);
      YGoto (YREDRAW, 0, 0, 0, 0);
    YCASE ("Exit")
      YExit (FALSE);
    YDEFAULT
      YBeep ();
    }
    break;
  case YREAD:
    if (num_lines != 0)
      for (i = 0; i < num_lines; i++)
	free (text[i]);
    strcpy (mus->fname, (char *) mes3);
    YGoto (YUPDATE, 0, 0, 0, 0);
    line_top = line_bot = 0;
    break;
  case YUPDATE:
    SnReadFile (mus->fname, text, &num_lines, &num_chars);
    SnTnMake (mus, text, num_lines);
    break;
  case YKEYBOARD:
    switch (mes1) {
    case YK_PAGEDOWN:
      YGoto (YNEXT, 0, 0, 0, 0);
      break;
    case YK_PAGEUP:
      YGoto (YPREV, 0, 0, 0, 0);
      break;
    case YK_DOWN:
      YGoto (YDOWN, 0, 0, 0, 0);
      break;
    case YK_UP:
      YGoto (YUP, 0, 0, 0, 0);
      break;
    case YK_HOME:
      YGoto (YHOME, 0, 0, 0, 0);
      break;
    case YK_END:
      YGoto (YEND, 0, 0, 0, 0);
      break;
    default:
      YBeep ();
    }
    break;
  case YDOWN:
    YGoto (YKEYWORD1, YMIN (line_top_max, line_top + 1), 0, 0, 0);
    break;
  case YUP:
    YGoto (YKEYWORD1, YMAX (0, line_top - 1), 0, 0, 0);
    break;
  case YNEXT:
    YGoto (YKEYWORD1, YMIN (line_top_max, line_bot), 0, 0, 0);
    break;
  case YPREV:
    YGoto (YKEYWORD1, YMAX (0, line_top - numstr + 1), 0, 0, 0);
    break;
  case YHOME:
    YGoto (YKEYWORD1, 0, 0, 0, 0);
    break;
  case YEND:
    YGoto (YKEYWORD1, line_top_max, 0, 0, 0);
    break;
  case YKEYWORD1:
    line_top_new = mes1;
    if (line_top_new == line_top)
      break;
    line_top = line_top_new;
    YGoto (YREDRAW, 0, 0, 0, 0);
    break;
  case YLMOUSEDOWN:
    if (!(par = SnFindAkk (mus, mes1, mes2)))
      break;
    if (par->type == YAKKORD)
      SnPlayAkkord (mus, par->aname, SnTnGet (mus, par->j));
    else if (par->type == YOFFSET) {
      SnTnChange (mus, par, -1);
      SnArxivSave (mus);
      SnTnMake (mus, text, num_lines);
      SnArxivDraw (mus);
    } else
      YError ("type");
    break;
  case YRMOUSEDOWN:
    if (!(par = SnFindAkk (mus, mes1, mes2)))
      break;
    if (par->type == YAKKORD) {
      SnVarChange (mus, par);
      SnArxivSave (mus);
      SnItemDraw (mus, par);
    } else if (par->type == YOFFSET) {
      SnTnChange (mus, par, 1);
      SnArxivSave (mus);
      SnTnMake (mus, text, num_lines);
      SnArxivDraw (mus);
    } else
      YError ("type");
    break;
  case YSCROLL:
    line_top = mes1;
    YGoto (YREDRAW, 0, 0, 0, 0);
    break;
  case YCLOSE:
    YWndClean (id);
    break;
  }

  RETURN_TRUE;
}
/*----------------------------SnTnZanull------------------------------------*/
void
SnTnZanull (SN_MUSIC *mus, char **text, int num_lines)
{
  int     i;
  char    str[3] =
  {'0', '0', '\0'};
  int     offset;

  for (i = 0; i < num_lines; i++) {
    if (strncmp (text[i], "[tn=", 4) == 0) {
      str[0] = text[i][4];
      str[1] = text[i][5];
      offset = atoi (str);
    }
  }

  offset++;
  mus++;
}
/*------------------------------SnTnMake------------------------------------*/
void
SnTnMake (SN_MUSIC *mus, char **text, int num_lines)
{
  int     i, j;
  char    str[3] =
  {'0', '0', '\0'};

  j = 1;
  for (i = 0; i < num_lines; i++)
    if (strncmp (text[i], "[tn=", 4) == 0) {
      if (j == OFFSET_MAX) 
	YError ("SnTnMake");
      str[0] = text[i][4];
      str[1] = text[i][5];
      mus->offset[j - 1][0] = i;
      mus->offset[j - 1][1] = atoi (str);
      j++;
    }
  mus->offset_num = j;

}
/*----------------------------SnTnGet---------------------------------------*/
int
SnTnGet (SN_MUSIC *mus, int j0)
{
  int     i, j, offset = 0;

  for (i = 0; i < mus->offset_num; i++) {
    j = mus->offset[i][0];
    offset = mus->offset[i][1];
    if (j0 > j) 
      break;
  }

  return (offset);
}
/*------------------------------SnTnChange----------------------------------*/
YT_BOOL
SnTnChange (SN_MUSIC *mus, SN_ARXIV *par, int delta)
{
  char    str[10];
  int     tn;
  char   *offset = "tn=";
  int     l_offset = strlen (offset);

  tn = atoi (&(par->aname[l_offset]));
  tn += delta;
  sprintf (str, "%s%02d", offset, tn);
  strcpy (par->aname, str);

  mus++;
  return (TRUE);
}
/*------------------------------SnVarChange---------------------------------*/
YT_BOOL
SnVarChange (SN_MUSIC *mus, SN_ARXIV *par)
{
  int     note, sheme, var;
  char    ch[2] =
  {'a', '\0'};
  SN_AKK *akkord;

  if (!SnAnameToIndex (mus, par->aname, &note, &sheme, &var, NULL))
    return (FALSE);
  var++;
  if (var > MAX_NUM_VARS - 1) 
    var = 0;

  akkord = &((mus->a)[note][sheme][var]);
  if (SnIsNullakk (akkord))
    var = 0;

  sprintf (ch, "%d", var + 1);
  par->aname[strlen (par->aname) - 1] = ch[0];

  return (TRUE);
}
/*------------------------------SnReadFile----------------------------------*/
void
SnReadFile (char *fname, char **text, int *num_lines, int *num_chars)
{
  FILE   *in;
  int     i, l, lmax = 0;
  char    stroka[SIZE_S];

  if (!(in = fopen (fname, "r"))) {
    *num_lines = 0;
    *num_chars = 0;
    return;
  }
  i = 0;
  while (fgets (stroka, SIZE_S - 5, in)) {
    l = strlen (stroka);
    text[i] = (char *) malloc (l + 10);
    stroka[l - 1] = '\0';
    lmax = YMAX (lmax, l - 1);
    strcpy (text[i], stroka);
    if (++i >= MAX_LINES)
      break;
  };
  fclose (in);

  *num_lines = i;
  *num_chars = lmax;
  return;
}
/*----------------------------SnSaveFile------------------------------------*/
void
SnSaveFile (char *fname, char **text, int num_lines)
{
  FILE   *out;
  int     i;

  if (!(out = fopen (fname, "w")))
    return;

  for (i = 0; i < num_lines; i++)
    fprintf (out, "%s\n", text[i]);

  fclose (out);
  return;
}
/*-----------------------------SnArxivInit----------------------------------*/
void
SnArxivInit (SN_MUSIC *mus)
{

  mus->num_arxiv = 0;

}
/*------------------------------SnFindAkk-----------------------------------*/
SN_ARXIV *
SnFindAkk (SN_MUSIC *mus, int x0, int y0)
{
  int     k, x, y;
  int     wakk = mus->w_akk, hakk = mus->h_akk;
  SN_ARXIV *par;

  for (k = 0; k < mus->num_arxiv; k++) {
    par = &((mus->ar)[k]);
    SnArxivGetXY (mus, par, &x, &y);
    if (YPtInRect (x0, y0, x, y, wakk, hakk))
      return (&((mus->ar)[k]));
  }

  return (NULL);
}
/*-----------------------------SnArxivGetXY---------------------------------*/
void
SnArxivGetXY (SN_MUSIC *mus, SN_ARXIV *par, int *x, int *y)
{

  *x = mus->marg_left + par->i * mus->uw - mus->w_akk / 2;
  *y = mus->marg_top + par->j * mus->step_lines - mus->h_akk / 2;

}
/*----------------------------SnAnameToAkk----------------------------------*/
YT_BOOL
SnAnameToAkk (SN_MUSIC *mus, char *aname, SN_AKK *akkord, int offset)
{
  int     note, sheme, var, bas;
  SN_AKK *akkord_b;

  if (!SnAnameToIndex (mus, aname, &note, &sheme, &var, &bas))
    return (FALSE);

  note += offset;
  note = YPutInCicl (note, 0, NUM_NOTES - 1);

  akkord_b = &((mus->a)[note][sheme][var]);
  if (SnIsNullakk (akkord_b))
    var = 0;
  akkord_b = &((mus->a)[note][sheme][var]);

  memcpy (akkord, akkord_b, sizeof (SN_AKK));
  SnCorrectBas (mus, akkord, bas);

  return (TRUE);
}
/*---------------------------SnCorrectBas-----------------------------------*/
void
SnCorrectBas (SN_MUSIC *mus, SN_AKK *akkord, int bas)
{
  mus++;
  akkord++;
  bas++;
}
/*----------------------------SnReadBase------------------------------------*/
void
SnReadBase (SN_MUSIC *mus, char *fname)
{
#define STROKA_SIZE 140
#define N_STROK 7
  FILE   *in;
  char    stroka[STROKA_SIZE];
  char   *str;
  int     note, sheme, var;
  SN_AKK  akkord;
  int     i, j, n;
  char    a[N_STROK][20];
  char   *razd = "**";
  char   *sfind[] =
  {
    "notes:", "shemes:", "vars:", NULL
  };
  int     ff;

  if (!(in = fopen (fname, "r")))
    YError ("SnReadBase");

  while (fgets (stroka, STROKA_SIZE - 5, in)) {
    for (i = 0; i < N_STROK; i++) 
      strcpy (a[i], "");
    n = sscanf (stroka, "%s %s %s %s %s", a[0],a[1],a[2],a[3],a[4],a[5],a[6]);

    if (n < 0)          continue;
    if (a[0][0] == '-') continue;

    for (ff = 0; sfind[ff] != NULL && !YStrCmp (sfind[ff], a[0]); ff++) 
      ;;;

    switch (ff) {
    case 0:			/*notes: */
      str = strtok (stroka, " ");
      for (i = 0; i < NUM_NOTES; i++) {
	str = strtok (NULL, " ");
	mus->notes_list[i] = (char *) malloc (50);
	strcpy (mus->notes_list[i], str);
      }
      mus->notes_list[NUM_NOTES] = NULL;
      break;
    case 1:			/*shemes: */
      mus->num_shemes = atoi (a[1]);
      if (mus->num_shemes > MAX_NUM_SHEMES)
	YError ("MAX_NUM_SHEMES");
      for (i = 0; i < mus->num_shemes; i++) {
	fgets (stroka, STROKA_SIZE - 5, in);

	for (j = 0; TRUE; j++) {
	  if (j == 0) str = strtok (stroka, " ");
	  else        str = strtok (NULL, " ");
	  if (YStrCmp (str, razd)) {
	    mus->sheme_list[i][j] = NULL;
	    break;
	  }
	  mus->sheme_list[i][j] = (char *) malloc (50);
	  strcpy (mus->sheme_list[i][j], str);
	}

	SnParseSheme (mus, i, strtok (NULL, " "));
      }
      break;
    case 2:			/*vars: */
      if (MAX_NUM_VARS != N_STROK - 1) YError ("MAX_NUM_VARS");
      break;
    default:
      if (!SnAnameToIndex (mus, a[0], &note, &sheme, &var, NULL))
	YError ("Aname");
      for (i = 1; i <= MAX_NUM_VARS; i++) {
	StringDelLimits (a[i]);
	SnBnameToAkk (a[i], &akkord);
	SnAkkToBaza (mus, &akkord, note, sheme, i - 1);
      }
      break;
    }

  };

  fclose (in);
}
/*----------------------------SnParseSheme----------------------------------*/
void
SnParseSheme (SN_MUSIC *mus, int i, char *sheme_def)
{
  char    string[30];
  int     j, delta, num, num_old, def;
  char   *str;
  static int tabl[10] =
  {
    0, 4, 7, 10, 14, 17, 21
  };

  strcpy (string, sheme_def);

  if (string[0] == '=') {
    num_old = 0;
    for (j = 1; j < strlen (string); j++) {
      switch (string[j]) {
      case '-':
	delta = -1;
	break;
      case '=':
	delta = 0;
	break;
      case '+':
	delta = 1;
	break;
      default:
	YError ("SnParseSheme");
      }
      num = tabl[j] + delta;
      def = num - num_old;
      num_old = num;
      mus->sdef[i][j - 1] = def;
    }
    mus->sdef[i][j] = 0;
  } else {
    j = 0;
    mus->sdef[i][j++] = atoi (strtok (string, "_"));
    while (str = strtok (NULL, "_"))
      mus->sdef[i][j++] = atoi (str);
    mus->sdef[i][j] = 0;
  }

}
/*----------------------------SnAnameToIndex--------------------------------*/
YT_BOOL
SnAnameToIndex (SN_MUSIC *mus, char *akk_name, int *pnote, int *psheme, 
		int *pvar, int *pbas)
{
  int     note, sheme, var, j, bas = 0;
  char   *sheme_name;
  char    aname[30];
  char    s_var[2] =  {'0', '\0'};
  char    s_note[3] = {'0', '0', '\0'};
  char    s_sheme[10];
  int     l_sheme;
  char   *bas_pstr = NULL;

  strcpy (aname, akk_name);
  if (aname[strlen (aname) - 2] != '_')
    return (FALSE);

  s_var[0] = aname[strlen (aname) - 1];
  var = atoi (s_var) - 1;

  s_note[0] = aname[0];
  s_note[1] = aname[1];
  if (s_note[1] == '_')
    s_note[1] = '\0';
  if (!SnSnoteToNote (mus, s_note, &note)) return (FALSE);

  l_sheme = strlen (aname) - 4;
  if (l_sheme == 0)
    sheme_name = "dmaj";
  else {
    strncpy (s_sheme, aname + 2, l_sheme);
    s_sheme[l_sheme] = '\0';

    if (s_sheme[0] == '/') {
      sheme_name = "dmaj";
      bas_pstr = s_sheme + 1;
    } else {
      sheme_name = strtok (s_sheme, "/");
      bas_pstr = strtok (NULL, "/");
    }
  }

  for (sheme = 0; sheme < mus->num_shemes; sheme++)
  for (j = 0; j < NUM_SHEMENAMES; j++) {
    if ((mus->sheme_list)[sheme][j] == NULL)
      break;
    if (YStrCmp (sheme_name, (mus->sheme_list)[sheme][j]))
      goto metka;
  }
  return (FALSE);

metka:

  *pnote = note;
  *psheme = sheme;
  *pvar = var;
  if (pbas) {
    if (!SnSnoteToNote (mus, bas_pstr, &bas))
      bas = -1;
    *pbas = bas;
  }
  return (TRUE);
}
/*----------------------------SnSnoteToNote---------------------------------*/
YT_BOOL
SnSnoteToNote (SN_MUSIC *mus, char *snote, int *pnote)
{
  int     note;

  if (!snote) return (FALSE);

  for (note = 0; note < NUM_NOTES; note++)
    if (YStrCmp (snote, (mus->notes_list)[note]))
      break;

  if (note == NUM_NOTES) return (FALSE);

  *pnote = note;
  return (TRUE);
}
/*-----------------------------SnAkkToBaza----------------------------------*/
void
SnAkkToBaza (SN_MUSIC *mus, SN_AKK *akkord, int note, int sheme, int var)
{

  memcpy (&((mus->a)[note][sheme][var]), akkord, sizeof (SN_AKK));

}
/*-----------------------------StringDelLimits------------------------------*/
void
StringDelLimits (char *string)
{
  int  l = strlen (string);

  if (l < 2) return;
  strcpy (string, &(string[1]));
  string[l - 2] = '\0';

}
/*-----------------------------SnBnameToAkk---------------------------------*/
void
SnBnameToAkk (char *chars, SN_AKK *akkord)
{
  int     k;
  char    str[2] = "s";
  int    *akk = &(akkord->akk[0]);

  if (strlen (chars) < AKK_LEN) {
    SnSetNullakk (akkord);
    return;
  }
  for (k = 0; k < AKK_LEN; k++) {
    str[0] = chars[k];
    akk[k] = atoi (str);
  }

}
/*---------------------------SnSetNullakk-----------------------------------*/
void
SnSetNullakk (SN_AKK *akkord)
{
  SN_AKK  akk0 = {{-1, 0, 0, 0, 0, 0, 0}};

  memcpy (akkord, &akk0, sizeof (SN_AKK));
  return;
}
/*----------------------------SnIsNullakk-----------------------------------*/
YT_BOOL
SnIsNullakk (SN_AKK *akkord)
{
  if (akkord->akk[0] == -1) return (TRUE);
  else                      return (FALSE);
}
/*---------------------------SnPlayAkkord-----------------------------------*/
void
SnPlayAkkord (SN_MUSIC *mus, char *aname, int offset)
{
  SN_AKK  akkord;
  int     k, lad, struna;
  int     freq;

  if (!SnAnameToAkk (mus, aname, &akkord, offset))
    return;

  for (k = 1; k <= NUM_STRUN; k++) {
    struna = k - 1;
    lad = akkord.akk[k];
    freq = SnGetFreq (mus, struna, lad);
    freq++;
  }

}
/*----------------------------SnGetFreq-------------------------------------*/
int
SnGetFreq (SN_MUSIC *mus, int struna, int lad)
{
  static float dfreq;
  int     freq, freq_begin;

  dfreq = pow (2, 1 / 12.0);
  freq_begin = mus->freq[struna];
  freq = freq_begin * (pow (dfreq, lad));

  return (freq);
}
/*-----------------------------SnDrawPage-----------------------------------*/
void
SnDrawPage (SN_MUSIC *mus, char **text, int line_top, int numstr, int num_lines)
{
  int     i, j;
  static char s[SIZE_S];

  if (text != NULL && num_lines != 0) {
    SnArxivInit (mus);
    for (j = 0; j < numstr; j++) {
      i = line_top + j;
      if (i >= num_lines)  
	break;
      strcpy (s, text[i]);
      SnDrawStroka (mus, s, j, line_top);
    }
  }
  SnArxivDraw (mus);

  return;
}
/*----------------------------SnDrawStroka----------------------------------*/
void
SnDrawStroka (SN_MUSIC *mus, char *s, int j, int line_top)
{
  static YT_BOOL akkord;
  static char aname[20];
  int     i, k, imin;
  int     type;
  char   *offset = "tn=";
  int     l_offset = strlen (offset);

  akkord = FALSE;
  for (i = 0; i < strlen (s); i++) {
    switch (s[i]) {
    case '[':
      s[i] = ' ';
      akkord = TRUE;
      k = 0;
      imin = i;
      break;
    case ']':
      s[i] = ' ';
      akkord = FALSE;
      aname[k] = '\0';
      if (strncmp (offset, aname, l_offset) == 0) type = YOFFSET;
      else                                        type = YAKKORD;
      SnArxivAdd (mus, type, aname, imin + 1, imin + (i - imin) / 2, j, line_top);
      break;
    default:
      if (!akkord) 
	break;
      if (s[i] != ' ')
	aname[k++] = s[i];
      s[i] = ' ';
    }
  }
  YDrawString (s, mus->marg_left, mus->marg_top + j * mus->step_lines, mus->clr_foregr);

  return;
}
/*----------------------------SnArxivAdd------------------------------------*/
void
SnArxivAdd (SN_MUSIC *mus, int type, char *aname, int i0, int i, int j, int line_top)
{
  int     n = mus->num_arxiv;

  if (n >= SIZE_ARXIV)  YError ("SIZE_ARXIV");

  (mus->ar)[n].type = type;
  strcpy ((mus->ar)[n].aname, aname);
  (mus->ar)[n].paname = (mus->text)[line_top + j] + i0;
  (mus->ar)[n].i = i;
  (mus->ar)[n].j = j;

  mus->num_arxiv++;
}
/*----------------------------SnArxivDraw-----------------------------------*/
void
SnArxivDraw (SN_MUSIC *mus)
{
  int     k;
  SN_ARXIV *par;

  for (k = 0; k < mus->num_arxiv; k++) {
    par = &((mus->ar)[k]);
    SnItemDraw (mus, par);
  }

}
/*-----------------------------SnItemDraw-----------------------------------*/
void
SnItemDraw (SN_MUSIC *mus, SN_ARXIV *par)
{
  int     x, y, tn;

  SnArxivGetXY (mus, par, &x, &y);
  tn = SnTnGet (mus, par->j);
  SnDrawAkkord (mus, par->aname, tn, x, y, mus->w_akk, mus->h_akk,
		mus->clr_akkbackgr, mus->clr_akkforegr);

}
/*----------------------------SnArxivSave-----------------------------------*/
void
SnArxivSave (SN_MUSIC *mus)
{
  int     k, l;

  for (k = 0; k < mus->num_arxiv; k++) {
    l = strlen ((mus->ar)[k].aname);
    strncpy ((mus->ar)[k].paname, (mus->ar)[k].aname, l);
  }

}
/*----------------------------SnPrint---------------------------------------*/
void
SnPrint (SN_MUSIC *mus, char **text, int num_lines)
{
  int     line_top = 0, numstr;

  numstr = 5;
  while (TRUE) {
    if (line_top > num_lines - 1)  
      break;
    line_top += numstr;
  }

  mus++;
  text++;
}
/*----------------------------SnDrawAkkord----------------------------------*/
YT_BOOL
SnDrawAkkord (SN_MUSIC *mus, char *akk_name, int offset,
	   int xx, int yy, int ww, int hh, YT_COLOR backgr, YT_COLOR foregr)
{
  SN_AKK  akkord;
  YT_BOOL flag = TRUE;

  if (isdigit (akk_name[0]))
    SnBnameToAkk (akk_name, &akkord);
  else
    flag = SnAnameToAkk (mus, akk_name, &akkord, offset);

  YDrawRectF (xx, yy, ww, hh, backgr);

  if (flag)  SnDrawSetka (&akkord, xx, yy, ww, hh, foregr);
  else       YDrawRectText (akk_name, xx, yy, ww, hh, YColor("black"));

  return (TRUE);
}
/*----------------------------SnDrawSetka-----------------------------------*/
void
SnDrawSetka (SN_AKK *akkord, int xx, int yy, int ww, int hh, YT_COLOR color)
{
  int     j, k, num;
  char    lad[5];
  int    *defa = &(akkord->akk[0]);
  int     left, top, right, bottom;

  left = 9;
  top = 4;
  right = 1;
  bottom = 4;

  xx += left;
  yy += top;
  ww -= left + right;
  hh -= top + bottom;
  SnSetkaDraw (NULL, NUM_POROG, NUM_STRUN, xx, yy, ww, hh, color);

  if (defa[0] == 0) {
    defa[0] = 1;
    for (j = 1; j <= NUM_STRUN; j++)
      defa[j] = defa[j] - 1;
  }
  if (defa[0] != 1) {
    sprintf (lad, "%d", defa[0]);
    SnSetkaDraw (lad, 0, 1, 0, 0, 0, 0, color);
  }

  for (j = 0; j < NUM_STRUN; j++) {
    k = NUM_STRUN - j;
    num = defa[k];
    if (num == 0)  continue;
    if (num == 9)  SnSetkaDraw ("&krest", 0, j, 0, 0, 0, 0, color);
    else           SnSetkaDraw ("&rect", num, j, TRUE, 0, 0, 0, color);
  }

  return;
}
/*---------------------------SnSetkaDraw------------------------------------*/
void
SnSetkaDraw (char *str, int horz, int vert, int int1, int int2, int int3, 
                                                int int4, YT_COLOR color)
{
  int     i, j, x, y;
  static float w, h;
  static int nvert, nhorz, xx, yy, ww, hh, r, wint, hint;
  int     l;

  if (str == NULL) {
    nhorz = horz;
    nvert = vert;
    xx = int1;
    yy = int2;
    ww = int3;
    hh = int4;
    w = (float) ww / (nhorz - 1);
    h = (float) hh / (nvert - 1);
    wint = YInt (w);
    hint = YInt (h);
    ww = (nhorz - 1) * wint;
    hh = (nvert - 1) * hint;

    for (i = 0; i < nhorz; i++)
      YDrawLine (xx + i * wint, yy, xx + i * wint, yy + hh, color);
    for (j = 0; j < nvert; j++)
      YDrawLine (xx, yy + j * hint, xx + ww, yy + j * hint, color);

    r = YMIN (wint, hint);
    return;
  }

  x = xx + YInt (w / 2) + wint * (horz - 1);
  y = yy + vert * hint;

  if (YStrCmp (str, "&freq")) {
  } else if (YStrCmp (str, "&rect")) {
    l = YInt (0.8 * r);
    if (l >= r)  l--;
    if (int1)
      YDrawRectF (x - l / 2, y - l / 2, l, l, color);
    else {
      YDrawRectB (x - l / 2, y - l / 2, l, l, color);
      YDrawRectB (x - l / 2 + 1, y - l / 2 + 1, l - 2, l - 2, color);
    }
  } else if (YStrCmp (str, "&krest")) {
    x += w / 6;
    l = YInt (0.5 * r);
    YDrawLine (x - l, y - l, x + l, y + l, color);
    YDrawLine (x - l, y + l, x + l, y - l, color);
  } else {
    YDrawStringImp (str, x, y, color, YNONE, YNONE);
  }

}
/*------------------------------songs_dlg-----------------------------------*/
long
songs_dlg (PFUNC_VAR)
{
  static int hOk, hCancel;
  static SN_MUSIC *mus;
  static int v1 = 1, v50 = 50;

  switch (message) {
  case YGETSIZE:
    MYSIZE_IS (250, 200);
    break;
  case YOPEN:
    mus = (SN_MUSIC *) YGet("wlong1");
  case YDRAW:
    YDrawRectF (0, 0, WND->w, WND->h, WIN->color);

    YBeginGroup ("Colors", 10,30, 120,120, YColor(""));
    YWnd (Ph(), COLORS, "Background", 10,10, 20,20, LP(mus->clr_backgr),0,0,0, CLR_DEF);
    YWnd (Ph(), COLORS, "Foreground", 10,35, 20,20, LP(mus->clr_foregr),0,0,0, CLR_DEF);
    YWnd (Ph(), COLORS, "Back-chord", 10,60, 20,20, LP(mus->clr_akkbackgr),0,0,0, CLR_DEF);
    YWnd (Ph(), COLORS, "Fore-chord", 10,85, 20,20, LP(mus->clr_akkforegr),0,0,0, CLR_DEF);
    YEndGroup ();

    YWnd (Ph(),     DECIMAL, "Step: ", 180,30, 40,20, 0,v1,v50,LP(mus->step_lines), CLR_DEF);
    YWnd (&hOk,     PUSH,    "OK",     WND->w/2-70,170, 60,20, 0,0,0,0, YColor("yellow"));
    YWnd (&hCancel, PUSH,    "Cancel", WND->w/2+10,170, 60,20, 0,0,0,0, YColor("yellow"));
    break;
  case YPUSH:
    if      (mes1 == hCancel)  YDlgEnd (FALSE);
    else if (mes1 == hOk)      YDlgEnd (TRUE);
    break;
  case YCLOSE:
    YWndClean (id);
    break;
  }

  RETURN_TRUE;
}
/*------------------------------songs_akk-----------------------------------*/
long
songs_akk (PFUNC_VAR)
{
  static int hAplay, hExit, hNote, hShem;
  static int note, sheme;
  static SN_MUSIC *mus;
  static char *sheme_list[MAX_NUM_SHEMES + 1];
  static YT_BOOL stupeni[10];
  static int n = 1, s = 1;

  int     i, j, k;
  int     delta;
  int     nott;
  int     y;

  int     num_lads = 12;
  int     xx = 10, yy = 10, ww = 180, hh = 70;
  char    strtmp[20];

  switch (message) {
  case YGETSIZE:
    MYSIZE_IS (250, 200);
    break;
  case YOPEN:
    mus = (SN_MUSIC *) YGet("wlong1");
    for (i = 0; i < mus->num_shemes; i++)
      sheme_list[i] = mus->sheme_list[i][0];
    sheme_list[i] = NULL;
  case YDRAW:
    YDrawRectF (0,0, WND->w,WND->h, WIN->color);
    YWnd (&hNote, LIST, "", 130,85, 45,80, (long)(mus->notes_list),0,LP(n),0, CLR_DEF);
    YWnd (&hShem, LIST, "", 180,85, 55,80, (long)(sheme_list),0,LP(s),0, CLR_DEF);
    YGoto (YREDRAW, 0, 0, 0, 0);
    YWnd (&hAplay, PUSH, "Draw",   130,175, 55,20, 0,0,0,0, YColor("yellow"));
    YWnd (&hExit,  PUSH, "Cancel", 190,175, 55,20, 0,0,0,0, YColor("yellow"));
    break;
  case YREDRAW:
    YGoto (YDRAWITEM, 0, 0, 0, 0);
    YGoto (YKEYWORD1, 0, 0, 0, 0);
    break;
  case YCHECK:
  case YKEYWORD1:
    YDrawRectF (xx, yy, ww, hh, YColor("white"));
    SnSetkaDraw (NULL, num_lads + 1, NUM_STRUN, xx + 10, yy + 5, ww - 20, hh - 10, 
                                                                       YColor("black"));
    note = YGetData (hNote) - 1;
    k = 0;
    while (TRUE) {
      for (i = 0; i < NUM_STRUN; i++)
      for (j = 0; j <= num_lads; j++) {
	nott = mus->grif[i] + j;
	nott = YPutInCicl (nott, 0, NUM_NOTES - 1);
	if (nott != note)  
	  continue;
	SnSetkaDraw ("&rect", j, i, stupeni[k], 0, 0, 0, mus->darks[k]);
      }
      delta = mus->sdef[sheme][k++];
      if (delta == 0)  
	break;
      note += delta;
      note = YPutInCicl (note, 0, NUM_NOTES - 1);
    };
    break;
  case YDRAWITEM:
    sheme = YGetData (hShem) - 1;
    for (k = 0; mus->sdef[sheme][k] != 0; k++) 
      ;;;;
    k++;

    for (i = 0; i < k; i++)
      stupeni[i] = TRUE;

    if (k >= 5)  stupeni[2] = FALSE;	/* A9 , A11 , A13 */
    if (k == 6)  stupeni[4] = FALSE;	/* A11 */
    if (k == 7) {                       /* A13 */
      stupeni[4] = FALSE;
      stupeni[5] = FALSE;
    }
				
    YBeginGroup ("Stages", 10,85, 110,114, YColor(""));
    YDrawRectF (5, 5, 100, 105, YColor("white"));
    for (i = 0; i < k; i++) {
      sprintf (strtmp, "%2d-nd", 2 * i + 1);
      y = 15 + i * 17;
      YDrawString (strtmp, 5, y, YColor("black"));
      YWnd (Ph(), CHECK, "", 50,y-7, 14,14, 0,LP(stupeni[i]),0,0, CLR_DEF);
      YDrawRectF (70, y - 7, 14, 14, mus->darks[i]);
    }
    YEndGroup ();
    break;
  case YPUSH:
    if      (mes1 == hAplay)  YGoto (YREDRAW, 0, 0, 0, 0);
    else if (mes1 == hExit)   YDlgEnd (TRUE);
    break;
  case YLMOUSEDOWN:
    SnSetkaDraw ("&freq", mes1, mes2, 0, 0, 0, 0, YColor("white"));
    break;
  case YCLOSE:
    YWndClean (id);
    break;
  }

  RETURN_TRUE;
}

/***************************************************************************/

#endif
#if defined(D_SVMIX3)

/*************************************************************************/

#include "dia-y_zone.h" 

#include "dia-algols.h" 

#include "dia-svisor.h" 

#include "dia-svmix3.h" 

/*==========================================================================*/
long     mRoad  (PFUNC_PAR);
long     mRW_max (PFUNC_PAR);
long     mConver (PFUNC_PAR);
long     mToLat (PFUNC_PAR);
long     mRmix3  (PFUNC_PAR);
long     mWmix3  (PFUNC_PAR);
long     mDcalc (PFUNC_PAR); 

typedef struct {
  YT_BOOL  geodez, horizon, cutvis;
  YT_BOOL  kleying;
/*   YT_SPACE elipse_a, elipse_b; */
} VT_ROAD;


typedef struct {
  /* float   l; */
  YT_SPACE   l;
  long    uzel;
  VT_P3D *t;
} VT_RAYS;

YT_BOOL  VRoadCalc (VT_ROAD *, VT_SURF *, VT_P3D *, VT_P3D *, YT_SPACE *);
int      VRoadFindRays (VT_ROAD *, VT_P3D *, VT_SURF *, VT_RAYS **);
VT_GV   *VRoadFullGraf (VT_GRAF *, VT_RAYS *, int);

/*==========================================================================*/

void IntrStart(void);
extern int  *bin__off;
#define  YBIN_OFF *bin__off

typedef struct {
  char *type;
  int   num;
  char *name;
  int   offset;
  int   size;
} IT_VALUE;

#define VALUE_NUM 30
typedef struct {
  char *name;
  IT_VALUE val[VALUE_NUM];
  IT_VALUE *new_values;
} IT_TYPE;

int      YBinoffTest (void);
void     YBinoffSet (int bin_off);
int      YBinoffGet (void);
void     IntrDoTypes (IT_TYPE *types);
void     YDataRW (int act, int mode, void *ptr, IT_TYPE *types, char *type, int size, FILE *stream);

void      Yfprintf (FILE *stream, char *type, void *ptr);
void      Yfscanf  (FILE *stream, char *type, void *ptr);

#define DATAS_NUM 30
typedef struct {
  char *name_type;
  char *name_data;
  void *ptr;
  int   size;
} IT_DATA;

IT_VALUE *IntrValByName (IT_TYPE *, char *name);
void     *IntrGetPtr(char *name1, char *name2, int*);
void      IntrSetDatas(void);
int       IntrRead (FILE *fp,char *name); 
int       IntrDataByName (char *name_data);
void      IntrGetVal (void *val, char *name1, char *name2);
int       IntrSize(IT_TYPE *types, char *type);
IT_TYPE  *IntrFindType (IT_TYPE *types, char *type);

/*=========================================================================*/

static IT_TYPE mix3_types[] = {
  {"vector",{
    {"double", 3},
    {NULL}}},
  {"REGION_T",{
    {"short",  1},
    {"int",  3},
    {"long",   1},
    {NULL}}},
  {"M3_POINT",{
    {"vector", 1},
    {"vector", 1},
    {"double", 3},
    {NULL}}},
  {"CELL",{
    {"short", 3},
    {"long",  1},
    {NULL}}},
  {NULL}
};

/**************************************************************************/

typedef struct {
	YT_BOOL ro, e, p, vx, vy, vz, v, nn, dot;

} YT_MIX3_WANT;

YT_BOOL  Mix3PreloadFile (char *file,  int *ii, int *jj, int *kk);
YT_BOOL  Mix3RW (char *fname, VT_MIX3 **pm, int act, int mode);


YT_SPACE  DugaOnSphere (YT_SPACE r, VT_P3D *, VT_P3D *);
YT_SPACE  SwayOnSphere (YT_SPACE r, VT_P3D *p1, VT_P3D *p2);

/**************************************************************************/


int      *bin__off;


/*--------------------------------VCalcUgol----------------------------------*/
float
VCalcUgol (VT_P3D *m, VT_P3D *o, VT_P3D *n)
{
  VT_VECTOR a, b;
  float   angl;

  a.x = m->x - o->x;
  a.y = m->y - o->y;
  a.z = m->z - o->z;

  b.x = n->x - o->x;
  b.y = n->y - o->y;
  b.z = n->z - o->z;

  angl = acos (VVecMult (&a, &b) / (VVecLenght (&a) * VVecLenght (&b)));

  return (angl);
}
/*---------------------------SwayOnSphere--------------------------------*/
YT_SPACE
SwayOnSphere (YT_SPACE r, VT_P3D *p1, VT_P3D *p2)
{
  YT_SPACE s, t, ugol = YPI/*???*/, a1, a2, a3, road;
  VT_P3D  o;

  VSetPoint3D (&o, 0, 0, 0);

  ugol = VCalcUgol (p1, &o, p2);
  s = VLenOtrezok (&o, p1);
  t = VLenOtrezok (&o, p2);

  if (s < r) s = r;
  if (t < r) t = r;

  a1 = acos (r / s);
  a3 = acos (r / t);

  a2 = ugol - a1 - a3;

  if (a2 <= 0) road = VLenOtrezok (p1, p2);
  else         road = sqrt (s * s - r * r) + sqrt (t * t - r * r) + r * a2;

  return (road);
}
/*---------------------------DugaOnSphere--------------------------------*/
YT_SPACE
DugaOnSphere (YT_SPACE r, VT_P3D *p1, VT_P3D *p2)
{
  YT_SPACE ugol, l;
  VT_P3D  o;

  VSetPoint3D (&o, 0, 0, 0);
  ugol = VCalcUgol (p1, &o, p2);
  l = ugol*r;

  return (l);
}
/*==========================================================================*/
/*            Binary Reading and Writing;     INTERPRETATOR                 */
/*                                                                          */
/*---------------------------------------------------------------------------*/
void 
IntrStart()
{

	bin__off = (int*) malloc(sizeof(int));

}
/*--------------------------------Yfprintf_old----------------------------------*/
void 
Yfprintf_old (FILE *stream, char *type, void *ptr)
{
  char    c;
  float   f;
  double  d;
  int     i;
  short   s;
  long    l;

  if      (YStrCmp(type,"char"))   { c= *((char*)  ptr);      fprintf (stream, "%c ", c); }
  else if (YStrCmp(type,"float"))  { f= *((float*) ptr);      fprintf (stream, "%f ", f); }
  else if (YStrCmp(type,"double")) { d= *((double*)ptr); f=d; fprintf (stream, "%f ", f); } 
  else if (YStrCmp(type,"int"))    { i= *((int*)   ptr);      fprintf (stream, "%d ", i); }
  else if (YStrCmp(type,"short"))  { s= *((short*) ptr); i=s; fprintf (stream, "%d ", i); }
  else if (YStrCmp(type,"long"))   { l= *((long*)  ptr); i=l; fprintf (stream, "%d ", i); }
  else {
    YWarningS ("Yfprintf", type);
  }

  return;
}
/*--------------------------------Yfprintf----------------------------------*/
void 
Yfprintf (FILE *stream, char *type, void *ptr)
{
  char    c;
  float   f;
  double  d;
  int     i;
  short   s;
  long    l;

  if      (YStrCmp(type,"char"))   { c= *((char*)  ptr);      fprintf (stream, "%c ", c); }
  else if (YStrCmp(type,"float"))  { f= *((float*) ptr);      fprintf (stream, "%.10f ", f); }
  else if (YStrCmp(type,"double")) { d= *((double*)ptr); f=d; fprintf (stream, "%.10f ", f); } 
  else if (YStrCmp(type,"int"))    { i= *((int*)   ptr);      fprintf (stream, "%d ", i); }
  else if (YStrCmp(type,"short"))  { s= *((short*) ptr); i=s; fprintf (stream, "%d ", i); }
  else if (YStrCmp(type,"long"))   { l= *((long*)  ptr); i=l; fprintf (stream, "%d ", i); }
  else {
    YWarningS ("Yfprintf", type);
  }

  return;
}
/*--------------------------------Yfscanf_old-----------------------------------*/
void 
Yfscanf_old (FILE *stream, char *type, void *ptr)
{
  char    *pc;  char    c;
  float   *pf;  float   f;
  double  *pd;  double  d;
  int     *pi;  int     i;
  short   *ps;  short   s; 
  long    *pl;  long    l;

  if      (YStrCmp(type,"char"))  {pc= (char*)  ptr; fscanf (stream, "%c ", &c);      *pc=c;}
  else if (YStrCmp(type,"float")) {pf= (float*) ptr; fscanf (stream, "%f ", &f);      *pf=f;}
  else if (YStrCmp(type,"double")){pd= (double*)ptr; fscanf (stream, "%f ", &f); d=f; *pd=d;}
  else if (YStrCmp(type,"int"))   {pi= (int*)   ptr; fscanf (stream, "%d ", &i);      *pi=i;}
  else if (YStrCmp(type,"short")) {ps= (short*) ptr; fscanf (stream, "%d ", &i); s=i; *ps=s;}
  else if (YStrCmp(type,"long"))  {pl= (long*)  ptr; fscanf (stream, "%d ", &i); l=i; *pl=l;}
  else {
    YWarningS ("Yfscanf", type);
  }

  return;
}
/*--------------------------------Yfscanf-----------------------------------*/
void 
Yfscanf (FILE *stream, char *type, void *ptr)
{
  char    *pc, c;
  float   *pf, f;
  double  *pd, d;
  int     *pi, i;
  short   *ps, s; 
  long    *pl, l;

  if      (YStrCmp(type,"char"))  {pc= (char*)  ptr; fscanf (stream, "%c ",  &c);  *pc=c;}
  else if (YStrCmp(type,"float")) {pf= (float*) ptr; fscanf (stream, "%f ",  &f);  *pf=f;}
  else if (YStrCmp(type,"double")){pd= (double*)ptr; fscanf (stream, "%lf ", &d);  *pd=d;}
  else if (YStrCmp(type,"int"))   {pi= (int*)   ptr; fscanf (stream, "%d ",  &i);  *pi=i;}
  else if (YStrCmp(type,"short")) {ps= (short*) ptr; fscanf (stream, "%hd ", &s);  *ps=s;}
  else if (YStrCmp(type,"long"))  {pl= (long*)  ptr; fscanf (stream, "%ld ", &l);  *pl=l;}
  else {
    YWarningS ("Yfscanf", type);
  }

  return;
}
/*---------------------------------ReadWrite----------------------------------*/
void
ReadWrite (int act, void *ptr, int size, FILE *stream)
{


  if      (act == YREAD) { 
    if (fread (ptr, size, 1, stream) != 1) YError ("YDataRW-read");
  }
  else if (act == YWRITE) { 
    if (fwrite(ptr, size, 1, stream) != 1) YError ("YDataRW-write");
  }

	return;
}
/*----------------------------------YDataRW-----------------------------------*/
void 
YDataRW (int act, int mode, void *ptr, IT_TYPE *types, char *type, int size, FILE *stream)
{
  int  size_type;
  IT_VALUE *val;

	if (mode == YBIN)
		ReadWrite (act, ptr, size, stream);
	else {
		size_type = IntrSize (types, type);
		/*   if    (size != size_type)   OUTS (type); */
		/*   else    */
		size = size_type;

		if      (act == YREAD) { 
			for (val=IntrFindType(types,type)->new_values; val->type!=NULL; val++) 
				Yfscanf (stream, val->type, (char*)ptr + val->offset);
		}
		else if (act == YWRITE) { 
			for (val=IntrFindType(types,type)->new_values; val->type!=NULL; val++) 
				Yfprintf (stream, val->type, (char*)ptr + val->offset);
		}
	}

  return; 
}
/*-------------------------------IntrSizeof---------------------------------*/
int            
IntrSizeof (char *type)
{
  int size;

  if      (YStrCmp(type,"char"))   size = sizeof(char)  ;
  else if (YStrCmp(type,"float"))  size = sizeof(float) ;
  else if (YStrCmp(type,"double")) size = sizeof(double);
  else if (YStrCmp(type,"int"))    size = sizeof(int)   ;
  else if (YStrCmp(type,"short"))  size = sizeof(short) ;
  else if (YStrCmp(type,"long"))   size = sizeof(long)  ;
  else {
   YWarningS ("IntrSizeof", type);
    size = 0;
  }

  return (size);
}
/*-------------------------------IntrValByName--------------------------------*/
IT_VALUE *
IntrValByName (IT_TYPE *types, char *name)
{
IT_VALUE *values;
int i;

 for (i=0; TRUE; i++) {
   if (types[i].name == NULL) return(NULL);
   if (YStrCmp(name,types[i].name)) break;
 }

 values=types[i].val; 

 return(values);
}
/*--------------------------------IntrDoValues-------------------------------*/
void IntrDoValues (int *num, IT_VALUE *new_values, IT_TYPE *types, char *type, int max_off)
{
  IT_VALUE  *values, *val;
  int   i, offset, off, ost, add;

  values = IntrValByName (types, type);

  if (!values) {
    if (new_values!=NULL) {
      new_values[*num].type = type;
      new_values[*num].size = IntrSizeof(type);
      if   (*num == 0) { 
	new_values[*num].offset = 0;
      } else {
	offset = new_values[(*num)-1].offset + new_values[(*num)-1].size;
	                  /* IntrSizeof(new_values[(*num)-1].type); */
	off = YMIN (max_off, IntrSizeof(type));

	if (off == 0)    ost = 0;
	else             ost = offset % off;
	if   (ost == 0)  add = 0;
	else             add = off - ost;

	new_values[*num].offset = offset + add;
      }
    }
    (*num)++;
    return;
  }

  for (val=values; val->type!=NULL; val++) 
  for (i = 1; i <= val->num; i++) 
      IntrDoValues (num, new_values, types, val->type, max_off);

  return;
}
/*--------------------------------IntrFindType-----------------------------*/
IT_TYPE *IntrFindType (IT_TYPE *types, char *type)
{
  IT_TYPE  *tp;

	/* printf("IntrFindType-1 \n", tp->name); */

  for (tp=types; tp->name!=NULL; tp++) {
		/* printf("%s \n", tp->name); */
    if (YStrCmp(tp->name, type))  break;
	}


	/* printf("IntrFindType-2 \n", tp->name); */
  if (tp->name==NULL) YErrorS("IntrFindType:", type);

  return (tp);
}
/*-------------------------------IntrDoCalc--------------------------------*/
IT_VALUE *
IntrDoCalc (IT_TYPE *types, char *type, int max_off)
{
  IT_VALUE *new_values;
  static int num;

  num = 0;
  IntrDoValues (&num, NULL, types, type, max_off);
  YMALLOC (new_values, IT_VALUE, num+1);
  
  num = 0;
  IntrDoValues (&num, new_values, types, type, max_off);
  new_values[num].type = NULL;  
  
 return (new_values);
}
/*-------------------------------IntrDoType--------------------------------*/
void
IntrDoType (IT_TYPE *types, char *type, int max_off)
{
  IT_VALUE *new_values;
  IT_TYPE  *tp;
 
  new_values = IntrDoCalc (types, type, max_off);
  
  tp = IntrFindType (types, type);
  tp->new_values = new_values;

 return;
}
/*--------------------------------IntrDoTypes------------------------------*/
void
IntrDoTypes (IT_TYPE *types)
{
  IT_VALUE *new_values;
  IT_TYPE  *tp;

  for (tp=types; tp->name!=NULL; tp++) {
    new_values = IntrDoCalc (types, tp->name, YBIN_OFF);
    tp->new_values = new_values;
  }

 return;
}
/*--------------------------------IntrSize-----------------------------------*/
int IntrSize(IT_TYPE *types, char *type)
{
  IT_VALUE *val;
  
  for (val=IntrFindType(types,type)->new_values; val->type!=NULL; val++) {
		;;;
	}
  val--;

  return (val->offset + val->size);
}
/*--------------------------------YBinoffGet---------------------------------*/
int YBinoffGet ()
{

  return (YBIN_OFF);

}
/*--------------------------------YBinoffSet---------------------------------*/
void YBinoffSet (int bin_off)
{


  if ((bin_off != 0) && (bin_off != 4) && (bin_off != 8)) {
   YWarning ("YBinoffSet");
    return;
  }

  YBIN_OFF = bin_off;

  return;
}
/*--------------------------------YBinoffTest---=----------------------------*/
int YBinoffTest ()
{

  typedef struct {
    double  x,y,z;
  } vector;

  typedef struct {
    vector  r;
    short   typePOINT;
    vector  u;
    double  ro;
    double  e;
    double  p;
  } TEST_POINT;

  static IT_TYPE types[] = {
  {"vector",{
    {"double", 3},
    {NULL}}},
  {"TEST_POINT",{
    {"short",  1},
    {"vector", 1},
    {"short",  3},
    {"vector", 1},
    {"double", 3},
    {NULL}}},
  {NULL}};
  
  int   /* num,  */size_0, size_4, size_8, size_real, max_off;
/*   IT_VALUE *new_values, *val; */

  IntrDoType (types, "TEST_POINT", 0 );
  size_0 = IntrSize(types, "TEST_POINT");

  IntrDoType (types, "TEST_POINT", 4);
  size_4 = IntrSize(types, "TEST_POINT");

  IntrDoType (types, "TEST_POINT", 8);
  size_8 = IntrSize(types, "TEST_POINT");

  size_real = sizeof(TEST_POINT);

  if      (size_real == size_0) max_off = 0;
  else if (size_real == size_4) max_off = 4;
  else if (size_real == size_8) max_off = 8;
  else 
   YWarning ("max_off");

 /*  YBinoffSet (max_off); */

  return (max_off);
}

/*----------------------------------Mix3RW--------------------------------------*/
YT_BOOL
Mix3RW (char *fname, VT_MIX3 **pm, int act, int mode)
{

  int i, j, k; 
 
  int   ii, jj, kk;
  long  NUM;
  short type;
  FILE  *fp;
  char  *open_type;
  VT_MIX3 *m;

  if      (act == YREAD)  open_type = "rb";
  else if (act == YWRITE) open_type = "wb";
  else     return(FALSE);
 
  if ((fp = fopen (fname, open_type)) == NULL) {
    /* YMessageBox ("Cannot open file", "OK"); */
   YWarning ("Cannot open file");
    return(FALSE);
  }
  
  if (act == YREAD)  {
    YMALLOC (m, VT_MIX3, 1);
    if (!m)  {printf("666 \n"); return(FALSE);}
    *pm = m;
  } else {
    m = *pm;
  }

  
  /* OUTS (open_type); */

  YDataRW (act, mode, &m->def_region,  mix3_types, "REGION_T",  sizeof (REGION_T),  fp); 
  
  ii     = (m->def_region).III + 1;
  jj     = (m->def_region).JJJ + 1;
  kk     = (m->def_region).KKK + 1;
  /* fprintf (Y_STDERR, "%d %d %d \n", ii, jj, kk); */
  NUM    = (m->def_region).NUM;
  type   = (m->def_region).type;
  
  if (act == YREAD) {
    YMALLOC (m->m3_points,  M3_POINT, ii*jj*kk);
  }
  
  /* YWaitBegin (WAIT, ii*jj*kk, "Working  points"); */
  for (k = 0; k < kk; k++)
  for (j = 0; j < jj; j++)
  for (i = 0; i < ii; i++) {
    /* YWaitSend (TRUE); */
/*     YDataRW (act, mode, &(m->m3_points[BBB_old(ii,jj,kk, i,j,k)]), mix3_types, "M3_POINT", sizeof(M3_POINT), fp); */
    YDataRW (act, mode, &(m->m3_points[BBB(kk,jj,ii, k,j,i)]), mix3_types, "M3_POINT", sizeof(M3_POINT), fp);
  }
  /* YWaitEnd ();   */             
  
  if (act == YREAD) {
    YMALLOC (m->cells,  CELL,  NUM);
  }
  
  for(i = 0; i < NUM; i++){
    YDataRW (act, mode, &(m->cells[i]), mix3_types, "CELL", sizeof(CELL), fp);
  }
  
  if (type == 2  ) {
    if (act == YREAD)  YMALLOC (m->vals, double, (ii-1)*(jj-1)*(kk-1));
    
    for (k = 0; k < kk-1; k++) 
    for (j = 0; j < jj-1; j++) 
    for (i = 0; i < ii-1; i++) 
/*       YDataRW (act, mode, &(m->vals[BBB_old(ii-1,jj-1,kk-1, i,j,k)]), mix3_types, "double", sizeof(double), fp); */
      YDataRW (act, mode, &(m->vals[BBB(kk-1,jj-1,ii-1, k,j,i)]), mix3_types, "double", sizeof(double), fp);
    
  }
  
  fclose (fp);
  
  return (TRUE);
}
/*-------------------------------Mix3PreloadFile--------------------------------------*/
YT_BOOL            
Mix3PreloadFile (char *file,  int *ii, int *jj, int *kk)
{
  FILE  *fp;

  VT_MIX3  mix3, *m;

  int act  = YREAD;
  int mode = YBIN;

  if ((fp = fopen (file, "rb")) == NULL) {
    YMessageBox ("Cannot open input file", "OK");
    return (FALSE);
  }

  m = &mix3;

  YDataRW (act, mode, &m->def_region,  mix3_types, "REGION_T",  sizeof (REGION_T),  fp); 

	/* printf("%d %d %d \n", *ii, *jj, *kk); */
  *ii = m->def_region.III;
  *jj = m->def_region.JJJ;
  *kk = m->def_region.KKK;

  fclose (fp);

  return (TRUE);
}
/*-------------------------------Mix3TestBinoff---------------------------------*/
void            
Mix3TestBinoff (char *file)
{
  int cur_binoff;
  int ii, jj, kk;
  
  cur_binoff = YBinoffGet ();

  fprintf (Y_STDERR, "Mix3TestBinoff : %s \n", file);
  fprintf (Y_STDERR, "cur_binoff =  %d \n\n", cur_binoff);

  YBinoffSet (0);  IntrDoTypes (mix3_types); 
  Mix3PreloadFile (file, &ii, &jj, &kk);
  fprintf (Y_STDERR, "if  binoff = %d  then  ii,jj,kk = %d,%d,%d \n", YBinoffGet(), ii, jj, kk);

  YBinoffSet (4);  IntrDoTypes (mix3_types);
  Mix3PreloadFile (file, &ii, &jj, &kk);
  fprintf (Y_STDERR, "if  binoff = %d  then  ii,jj,kk = %d,%d,%d \n", YBinoffGet(), ii, jj, kk);

  YBinoffSet (8);  IntrDoTypes (mix3_types);
  Mix3PreloadFile (file, &ii, &jj, &kk);
  fprintf (Y_STDERR, "if  binoff = %d  then  ii,jj,kk = %d,%d,%d \n", YBinoffGet(), ii, jj, kk);

  YBinoffSet (cur_binoff);  IntrDoTypes (mix3_types); 
  return;
}
/*-----------------------------YAlgLoadUser---------------------------------*/
void 
YAlgLoadUser ()
{

  AT_PNAME1 pnames[] = {
    { "mRoad",    mRoad    },    
    { "mRmix3",   mRmix3   },  
    { "mWmix3",   mWmix3   }, 
    { "mRW_max",  mRW_max  },  
    { "mConver",  mConver  },  
    { "mToLat",   mToLat   },  
    { "mDcalc",   mDcalc   },  
    { NULL }
  }; 

  static char *def_map2[] = {

    "@MAP  MISC",
    "@MAP_plan   ",

    "11 YMOD mRW_max  NULL 150  40 WFU HFU  NULL | 12 | ",
    "12 YMOD mToLat   NULL 240  40 WFU HFU  NULL | 3  | ",

    " 1 YMOD mRmix3  NULL  60  80 WFU HFU  NULL | 2 | ",
    " 2 YMOD mDcalc  NULL 150  80 WFU HFU  NULL | 3 | ",
    " 3 YMAP Vizor   NULL 240  80 WFU HFU  NULL |   | ",
    " 4 YMOD mRotL   NULL  60 120 WFU HFU  NULL | 2 | ",
    /* " 7 YMOD mRmix3  NULL 240 130 WFU HFU  NULL | 3 | ", */

    " 6 YMAP Calcus  NULL        60 190 WFU HFU  NULL |   | ",
    "10 YMOD mConver NULL       150 190 WFU HFU  NULL |   | ",
    " 8 YMOD mRoad   pars_Road  240 190 WFU HFU  NULL | 3 | ",


    "@MAP  MIX3",
    "@MAP_plan   ",

    " 1 YMOD mRmix3  NULL 100  80  80 30  NULL | 2 | ",
    " 2 YMAP Vizor   NULL 210  80  80 30  NULL |   | ",
    " 3 YMAP MISC    NULL 150 160  80 30  NULL |   | ",


    "@PARS pars_mRmix3",
    "bool vx  TRUE ", 
    "bool vy  TRUE ", 
    "bool vz  TRUE ", 
    "bool ro  FALSE", 
    "bool e   FALSE", 
    "bool p   FALSE", 
    "bool v   TRUE ", 
    "bool nn  TRUE ", 
    "bool dot TRUE ", 
    "string fname 0000008.mix", 
    "@PARS pars_mDcalc",
    "space  p0_x  -12", 
    "space  p0_y    0", 
    "space  p0_z    0", 
    "@PARS pars_mWmix3",
    "string fname 0000009.mix", 
    "space  v     1.3        ", 
    "@MAP  Calcus",
    "30 30 | ..................................",
    "30 45 | ..................................", 
    "@MAP_plan   ",
    " 1 YMOD mRmix3 pars_mRmix3  60 100 WFU HFU  NULL | 2 | MM_APPLY",
    " 2 YMOD mDcalc pars_mDcalc 150 100 WFU HFU  NULL | 3 |       ",
    " 3 YMOD mWmix3 pars_mWmix3 240 100 WFU HFU  NULL |   |       ",


    "@PARS pars_R",
    "string fname 90000001.mix", 
    "string s_act YREAD", 
    "@PARS pars_W",
    "string fname 90000001.mix_t", 
    "string s_act YWRITE", 
    "@MAP  RW_mix3",
    "30 30 | ..................................",
    "30 45 | ..................................", 
    "@MAP_plan   ",
    " 1 YMOD mRW_max pars_R  60 100 WFU HFU  NULL | 3 | MM_APPLY",
    " 3 YMOD mRW_max pars_W 240 100 WFU HFU  NULL |   |       ",
    NULL};


  YSetPnames (pnames);
  YAlgReadAll (def_map2);

/*   YInitMISC (); */
	IntrStart ();
  YBinoffSet (YBinoffTest());

  return;
}
/*------------------------------mRoad---------------------------------------*/
long
mRoad (PFUNC_VAR)
{
  typedef struct {
    ABCD;
  } YT_USR;

  static YT_SPACE sway, test, d_otn, d_sum, d_mid, d_max, max_err;

  VT_SETKA setka={NULL};
  static VT_SURF *surf;
  static VT_ROAD ra;
  YT_BOOL   ret;
  int       i, j, k;
  YT_SPACE  u, v, r, ustep, vstep, rstep;

  static  int P1_x, P1_y, P1_z, P2_x, P2_y, P2_z, hSway, hTest, hDmid, hDmax, hErr,
             hR_sph, hR_max, hR_min;
  static  VT_P3D p1, p2;
  static  int ii, jj, kk, num_u, num_v, num_min = 3, num_max = 200;
  static  YT_SPACE rmin, rmax, r_sphere, full_rad,  p1x, p1y, p1z, p2x, p2y, p2z;
  static  YT_BOOL multi_s, polu, to_file, to_screen;
  static  char fname[80];
  static  VT_OBJ3D obj, obj_s, obj_err, obj_tru;
  static  VT_P3D *vis, *vis_cur, *vis1, *vis_cur1;
  static  int num, num1;
  static  YT_SPACE msize_min, msize_max, y_delta;

  static VT_PARS pars[] = {
    {"space",  "p1x",      "-15.0" }, 
    {"space",  "p1y",      " 15.0" }, 
    {"space",  "p1z",      "  0.0" }, 
    {"space",  "p2x",      " 17.45"}, 
    {"space",  "p2y",      "  0.0" }, 
    {"space",  "p2z",      " 17.46"}, 

    {"int",    "num_u",    "8"      }, 
    {"int",    "num_v",    "8"      }, 
    {"int",    "ii",       "5"       }, 
    {"int",    "jj",       "5"       }, 
    {"int",    "kk",       "5"       }, 
    {"space",  "r_sphere", "7.0"     }, 
    {"space",  "rmax",     "12.0"    }, 
    {"space",  "rmin",     "9.1"     }, 
    {"bool",   "multi_s",  "TRUE"    }, 
    {"bool",   "polu",     "TRUE"    }, 
    {"string", "fname",    "road_out"}, 
    {"bool",   "geodez",   "FALSE"   }, 
    {"bool",   "horizon",  "FALSE"   }, 
    {"bool",   "cutvis",   "FALSE"   }, 
    {"bool",   "kleying",  "FALSE"   }, 

    {"bool",   "to_screen", "TRUE"   }, 
    {"bool",   "to_file",   "FALSE"  }, 

    {"space",  "y_delta",   "1.0"    }, 
    {"space",  "max_err",   "2.0"    }, 
    {NULL}};

  switch (message) {
  case YCREATE:
    U_MALLOC;

    WND->name = "Road";

    PAR_INIT ("p1x",  &p1x);
    PAR_INIT ("p1y",  &p1y);
    PAR_INIT ("p1z",  &p1z);
    PAR_INIT ("p2x",  &p2x);
    PAR_INIT ("p2y",  &p2y);
    PAR_INIT ("p2z",  &p2z);

    PAR_INIT ("num_u",    &num_u);
    PAR_INIT ("num_v",    &num_v);
    PAR_INIT ("ii",       &ii);
    PAR_INIT ("jj",       &jj);
    PAR_INIT ("kk",       &kk);
    PAR_INIT ("multi_s",  &multi_s);
    PAR_INIT ("polu",     &polu);
    PAR_INIT ("r_sphere", &r_sphere);
    PAR_INIT ("rmin",     &rmin);
    PAR_INIT ("rmax",     &rmax);
    PAR_INIT ("fname",    fname); 
    PAR_INIT ("geodez",   &ra.geodez);
    PAR_INIT ("horizon",  &ra.horizon);
    PAR_INIT ("cutvis",   &ra.cutvis);
    PAR_INIT ("kleying",  &ra.kleying);

    PAR_INIT ("to_screen", &to_screen);
    PAR_INIT ("to_file",   &to_file);

    PAR_INIT ("y_delta",   &y_delta);
    PAR_INIT ("max_err",   &max_err);

    VSetPoint3D (&p1, p1x, p1y, p1z);
    VSetPoint3D (&p2, p2x, p2y, p2z);

    break;
  case MM_APPLY:
  case YAPPLY:
    YAlgOut (YSEND2FACE, MM_CLEAR_ALL,  0, 0, 0, 0);

    if (to_file) YPrintMode (fname, TRUE);
    sprintf  (Y_STR, "\n-----Road_Begin----- %s \n\n", YTimeString()); 
    YPrintDo (Y_STR);

    YGoto (YSCANF, 0,0,0, 0);

    msize_max = 0.05 * rmax; 
    msize_min = 0.5 * msize_max; 

    VSetkaMakeTest (&setka, (polu?0:1), num_u,num_v, r_sphere);
    surf = VSurfFromSetka (&setka, ra.kleying, -1);

    if (to_screen) {
      V3ObjInit (&obj_s, "MARKERS", "", &p1, 1, YCUBE, LP(msize_max), YColor("blue"));
      YAlgOut (YSEND2FACE, MM_OBJ3D_ADD,  0, 0, 0, LP(obj_s));
      V3ObjInit (&obj, "VSURF", "",  surf, 0, 0, YColor("yellow"), TRUE);
      YAlgOut (YSEND2FACE, MM_OBJ3D_ADD,  0, 0, 0, LP(obj));
    }

    if (multi_s) {
      ret = YGoto (YMAKE, 0, 0, 0, 0);
      if (!ret) {YWarning ("Don't calculate"); break;}
      test = sway = 0;
    } else {
      VRoadCalc ( &ra, surf,  &p1, NULL, &sway);
      VRoadCalc ( &ra, surf,  &p1,  &p2, &sway);
      VRoadCalc (NULL, NULL, NULL, NULL,  NULL);

      test = SwayOnSphere (r_sphere, &p1, &p2);
      d_mid = d_max = 100 * (sway - test) / sway;
    }

    YGoto (YPRINT, 0,0,0, 0);

    sprintf  (Y_STR, "\n-----Road_End------- %s \n", YTimeString());
    YPrintDo (Y_STR);
    YPrintMode (NULL, FALSE);
    break;
  case YMAKE:
    VRoadCalc (&ra, surf, &p1, NULL, &sway);

    YWaitBegin (WAIT, ii * jj * kk, "ii_jj_kk");
    
    if (polu) full_rad = YPI;
    else      full_rad = 2*YPI;

    ustep = full_rad / (ii - 1);
    vstep = full_rad / (jj - 1);
    rstep = (rmax - rmin) / (kk - 1);

    d_max = YMINSPACE;
    d_sum = 0;

    if (to_screen) {
      if (!(vis1 = (VT_P3D *) malloc (ii*jj*kk*sizeof(VT_P3D)))) YError ("008");
      vis_cur1 = vis1;  num1 = 0;
      if (!(vis = (VT_P3D *) malloc (ii*jj*kk*sizeof(VT_P3D))))  YError ("008");
      vis_cur  = vis;    num = 0;
    }

    for (k = 0; k < kk; k++)
    for (i = 0; i < ii; i++)
    for (j = 0; j < jj; j++) {
      u = ustep * i;
      v = vstep * j;
      r = rmin + rstep * k;

      p2.x = r * cos (u);
      p2.y = r * sin (u) * sin (v) + y_delta;
      p2.z = r * sin (u) * cos (v);
      
      if (!YWaitSend(TRUE)) break;
      if (!VRoadCalc (&ra, surf, &p1, &p2, &sway/* , FALSE */))  {
	YWarning ("YMAKE - VRoadCalc");
	break;
      }

      test  = SwayOnSphere (r_sphere, &p1, &p2);
      d_otn = 100 * (sway - test) / sway;

      if (YABS(d_otn) > max_err) {
	sprintf  (Y_STR, "  err = %f point = (%f %f %f) \n", d_otn, p2.x, p2.y, p2.z);
	YPrintDo (Y_STR);
	if (to_screen) {
	  memcpy (vis_cur, &p2, sizeof (VT_P3D));
	  vis_cur++; num++;
	}
      } else {
	if (to_screen) {
	  memcpy (vis_cur1, &p2, sizeof (VT_P3D));
	  vis_cur1++; num1++;
	}
      }

      d_max = YMAX (d_max, YABS (d_otn));
      d_sum += d_otn;
    }

    if (to_screen) {
      V3ObjInit (&obj_err, "MARKERS", "", vis, num, YCUBE, LP(msize_min), YColor("red"));
      YAlgOut (YSEND2FACE, MM_OBJ3D_ADD,  0, 0, 0, LP(obj_err));
      V3ObjInit (&obj_tru, "MARKERS", "", vis1, num1, YCUBE, LP(msize_min), YColor("green"));
      YAlgOut (YSEND2FACE, MM_OBJ3D_ADD,  0, 0, 0, LP(obj_tru));
    }
    
    YWaitEnd ();
    d_mid = d_sum / (ii * jj * kk);
    return (TRUE);
  case YGETSIZE:
    MYSIZE_IS (W_MOD, H_MOD);
    break;
  case YOPEN:
  case YDRAW:
    YDrawRectF (0, 0, WND->w, WND->h, WIN->color);

    YBeginGroup ("Points", 5,10, 165,120, YColor(""));
    YWnd (&P1_x, FLOATS,  "S= ", 25,10, 45,20, LP(p1.x),YSPACE,0,0, CLR_DEF);
    YWnd (&P1_y, FLOATS,  "",    70,10, 45,20, LP(p1.y),YSPACE,0,0, CLR_DEF);
    YWnd (&P1_z, FLOATS,  "",   115,10, 45,20, LP(p1.z),YSPACE,0,0, CLR_DEF);

    YWnd (&P2_x, FLOATS,  "T= ", 25,40, 45,20, LP(p2.x),YSPACE,0,0, CLR_DEF);
    YWnd (&P2_y, FLOATS,  "",    70,40, 45,20, LP(p2.y),YSPACE,0,0, CLR_DEF);
    YWnd (&P2_z, FLOATS,  "",   115,40, 45,20, LP(p2.z),YSPACE,0,0, CLR_DEF);
    YWnd (Ph(),  CHECK,   "",    10,65, 20,20, 0,LP(multi_s),0,0, CLR_DEF);
    YWnd (Ph(),  DECIMAL, "",    45,65, 35,20, 0,num_min,num_max,LP(ii), CLR_DEF);
    YWnd (Ph(),  DECIMAL, "",    80,65, 35,20, 0,num_min,num_max,LP(jj), CLR_DEF);
    YWnd (Ph(),  DECIMAL, "",   120,65, 35,20, 0,num_min,num_max,LP(kk), CLR_DEF);

    YWnd (&hR_max, FLOATS, "rmax|rmin ", 70,90, 45,20, LP(rmax),YSPACE,0,0, CLR_DEF);
    YWnd (&hR_min, FLOATS, "",          115,90, 45,20, LP(rmin),YSPACE,0,0, CLR_DEF);
    YEndGroup ();

    YBeginGroup ("Algoriphm", 5,170, 165,65, YColor(""));
    YWnd (Ph(), CHECK, "geodez",  10,10, 20,20, 0,LP(ra.geodez), 0,0, CLR_DEF);
    YWnd (Ph(), CHECK, "horizo",  10,35, 20,20, 0,LP(ra.horizon),0,0, CLR_DEF);
    YWnd (Ph(), CHECK, "kleying", 85,10, 20,20, 0,LP(ra.kleying),0,0, CLR_DEF);
    YWnd (Ph(), CHECK, "cutvis",  85,35, 20,20, 0,LP(ra.cutvis), 0,0, CLR_DEF);
    YEndGroup ();


    YBeginGroup ("Surface", 175,10, 140,65, YColor(""));
    YWnd (Ph(), DECIMAL,   "",   5,10, 35,20, 0,num_min,num_max,LP(num_u), CLR_DEF);
    YWnd (Ph(), DECIMAL,   "",  40,10, 35,20, 0,num_min,num_max,LP(num_v), CLR_DEF);
    YWnd (&hR_sph, FLOATS, "",  80,10, 40,20, LP(r_sphere),YSPACE,0,0, CLR_DEF);
    YWnd (Ph(), CHECK, "polu-sprere", 20,35, 20,20, 0,LP(polu), 0,0, CLR_DEF);
    YEndGroup ();

    YBeginGroup ("Results", 175,85, 140,160, YColor(""));
    YWnd (&hTest, FLOATS, "ô/÷= ",      40,10, 45,20, LP(test), YSPACE,0,0, CLR_DEF);
    YWnd (&hSway, FLOATS, "",           90,10, 45,20, LP(sway), YSPACE,0,0, CLR_DEF);
    YWnd (&hDmid, FLOATS, "D_mid.(%) ", 70,35, 45,20, LP(d_mid),YSPACE,0,0, CLR_DEF);
    YWnd (&hDmax, FLOATS, "D_max.(%) ", 70,60, 45,20, LP(d_max),YSPACE,0,0, CLR_DEF);
    YWnd (&hErr,  FLOATS, "max_err = ", 70,85, 45,20, LP(max_err),YSPACE,0,0, CLR_DEF);

    YWnd (Ph(), CHECK, "to_screen",  3,105,  18,18, 0,  LP(to_screen), 0, 0, CLR_DEF);
    YWnd (Ph(), CHECK, "",  3,130,  18,18, 0,  LP(to_file), 0, 0, CLR_DEF);
    YWnd (Ph(), FILES, "", 25,130, 110,20, (long)fname, 75, 0, 0, CLR_DEF); 
    YEndGroup ();
    break;
  case YSCANF:
/*     if (YGet("wmode")) { */
    if (Y_WMODE) {
      YGetData (P1_x);
      YGetData (P1_y);
      YGetData (P1_z);
      YGetData (P2_x);
      YGetData (P2_y);
      YGetData (P2_z);
      YGetData (hR_sph);
      YGetData (hR_max);
      YGetData (hR_min);
      YGetData (hErr);
    }else{
    }
    break;
  case YPRINT:
    sprintf (Y_STR," Prec/Calc = %.2f %.2f \n", test, sway); YPrintDo (Y_STR);
    sprintf (Y_STR," D_mid.(%) = %.2f \n", d_mid);           YPrintDo (Y_STR);
    sprintf (Y_STR," D_max.(%) = %.2f \n", d_max);           YPrintDo (Y_STR);
/*     if (YGet("wmode")) { */
    if (Y_WMODE) {
      YWndUpdate (hTest);
      YWndUpdate (hSway);
      YWndUpdate (hDmid);
      YWndUpdate (hDmax);
    }
    break;
  case YCLOSE:
    YWndClean (id);
    break;
/*   default: ;;; */
  default:
    if (MM_FORWARD)  YAlgOut (YSEND2FACE, message,  mes1, mes2, mes3, mes4);
  }

  RETURN_TRUE;
}
/*-----------------------------VSurfMakeGraf-------------------------------*/
VT_GRAF *
VSurfMakeGraf (VT_SURF *surf)
{
  static VT_GRAF *graf;
  VT_GI i;
  VT_POL  pol;

  graf = VGrafCreate (surf->num_uzel);

  for (i = 0; i < surf->num_poli; i++) {
    VSurfGetPol (i, surf, &pol);
    GRAF_EDGE (graf, pol.u1, pol.u2) = (VT_GV) VLenOtrezok (pol.p1, pol.p2);
    GRAF_EDGE (graf, pol.u2, pol.u3) = (VT_GV) VLenOtrezok (pol.p2, pol.p3);

    if (pol.tria) {
      GRAF_EDGE (graf, pol.u3, pol.u1) = (VT_GV) VLenOtrezok (pol.p3, pol.p1);
    } else {
      GRAF_EDGE (graf, pol.u3, pol.u4) = (VT_GV) VLenOtrezok (pol.p3, pol.p4);
      GRAF_EDGE (graf, pol.u4, pol.u1) = (VT_GV) VLenOtrezok (pol.p4, pol.p1);
    }
  }

  /* surf->graf = graf; */
  return (graf);
}
/*-------------------------------VRoadCalc---------------------------------*/
YT_BOOL
VRoadCalc (VT_ROAD *ra, VT_SURF *surf, VT_P3D *p1, VT_P3D *p2, YT_SPACE *ret)
{
  /* static  */VT_GRAF *new_graf/* , *n_graf */;
  VT_GI s, t;
  YT_BOOL flag;
  VT_GI nn;
  static VT_GV smin;
  VT_RAYS *rays2, *pk1, *pk2, *pk;
  int     num2, i, j;

  static VT_GRAF *graf;
  static VT_RAYS *rays1;
  static int num1;
  static VT_GV *full;


  if (!p1 && !p2) { /* ---------  end work  -------- */
    OUTS ("p1 == NULL");
    VGrafDestroy (graf);
    free (full);

    return (TRUE);
  }

  if (p1 && !p2) {  /* --------- begin work -------- */
    graf = VSurfMakeGraf (surf);
    /* n_graf   = VGrafCreate (graf->nn + 2); */

    /* IsvisPoints (&obj, &s, NULL); */

    if (!(num1 = VRoadFindRays (ra, p1, surf, &rays1)))  {YWarning("num1="); return (FALSE);}
    full = VRoadFullGraf (graf, rays1, num1);  

    return (TRUE);
  }


  /* --------- main work ---------- */

/*   if (VSurfIsvisPoint (surf, p1, p2, -1)) { */
/*     smin = VLenOtrezok (p1, p2); */
  if (VSurfIsvisPoint (surf, p2, p1, -1)) {
    smin = VLenOtrezok (p2, p1);
    *ret = smin;
    return (TRUE);
  }

  if (!(num2 = VRoadFindRays (ra, p2, surf, &rays2)))  {YWarning("num2="); return (FALSE);}
  nn  = num1 + num2 + 2;
  new_graf = VGrafCreate (nn);

  flag = YWaitBegin (WAIT, num1 * num2, "VRoadCalc"); 
  for (i = 0; i < num1; i++) 
  for (j = 0; j < num2; j++) {
    pk1 = &rays1[i];
    pk2 = &rays2[j];
    
    smin = (VT_GV)full[BB (graf->nn,graf->nn, pk1->uzel, pk2->uzel)]; 
    /* VGrafSmin (graf, pk1->uzel, pk2->uzel, &smin); */

    GRAF_EDGE (new_graf, i, num1 + j) = (VT_GV)smin;
    /* GRAF_EDGE (n_graf, pk1->uzel, pk2->uzel) = (VT_GV)smin; */

    if (!YWaitSend (flag)) {YWaitEnd(); return (FALSE);}
  }
  YWaitEnd ();

  s = num1 + num2;
  t = num1 + num2 + 1;

  for (i = 0; i < num1; i++) {
    pk = &rays1[i];
    GRAF_EDGE (new_graf, s, i) = (VT_GV)(pk->l);
    /* GRAF_EDGE (n_graf, graf->nn, pk->uzel) = (VT_GV)(pk->l); */
  }

  for (j = 0; j < num2; j++) {
    pk = &rays2[j];
    GRAF_EDGE (new_graf, t, num1 + j) = (VT_GV)(pk->l);
    /* GRAF_EDGE (n_graf, graf->nn+1, pk->uzel)   = (VT_GV)(pk->l); */
  }

  VGrafSmin (new_graf, s, t, &smin);
  /* VGrafSmin (n_graf,   graf->nn, graf->nn+1, &smin); */

  VGrafDestroy (new_graf);
  free (rays2);

  *ret = smin;
  return (TRUE);
}
/*----------------------------VRoadFullGraf---------------------------------*/
VT_GV *
VRoadFullGraf (VT_GRAF *graf, VT_RAYS *rays, int num)
{
  static VT_GV *full, *all;
  VT_GI nn = graf->nn, i, j;
  VT_RAYS *pk;

  YMALLOC (full, VT_GV, nn*nn);
  YMALLOC (all,  VT_GV, nn);

  YWaitBegin (WAIT, num, "VRoadFullGraf");

  for (i = 0; i < num; i++) {
    YWaitSend (TRUE);
    pk = &rays[i];

    VGrafAllSmin (graf, pk->uzel, all);
    for (j = 0; j < nn; j++)  
      full[BB (nn,nn, pk->uzel, j)] = all[j];
  }

  YWaitEnd ();

  free (all);

  return (full);
}
/*----------------------------VRoadFindRays--------------------------------*/
int
VRoadFindRays (VT_ROAD *ra, VT_P3D *s, VT_SURF *surf, VT_RAYS **ptr_rays)
{
  VT_RAYS *rays;
  int     i, uz;
  YT_BOOL *horizon, *visible, *uzelrays;
  VT_P3D *t;

  visible = VIlistCreate (surf->num_uzel, TRUE);

  VSurfCheckVisible (s, surf, visible);

  if (ra->horizon) {
    horizon = VSurfVisibleHorizon (surf, visible);
    uzelrays = horizon;
    free (visible);
  } else
    uzelrays = visible;

  YMALLOC (rays, VT_RAYS, surf->num_uzel);

  for (i = 0, uz = 0; uz < surf->num_uzel; uz++) {
    if (!uzelrays[uz])  continue;
    rays[i].uzel = uz;
    t = VSurfUzel (surf, uz);
    rays[i].l = VLenOtrezok (s, t);
    rays[i].t = t;
    i++;
  }
  
  free (uzelrays);

  *ptr_rays = rays;
  return (i);
}
/*-------------------------------VRoadCalcOldest---------------------------------*/
YT_BOOL
VRoadCalcOldest (VT_ROAD *ra, VT_SURF *surf, VT_P3D *p1, VT_P3D *p2, YT_SPACE *ret, 
           YT_BOOL local)
{
  static VT_GV smin;
  VT_GRAF *new_graf;
  VT_RAYS *rays2, *pk1, *pk2, *pk;
  int     num2, i, j;
  VT_GI s, t;
  /* VT_RSURF *rsurf; */
  YT_BOOL flag;

  static VT_GRAF *graf;
  static VT_RAYS *rays1;
  static int num1;
  static VT_GV *full;

  if (p2 != NULL)
    if (VSurfIsvisPoint (surf, p1, p2, -1)) {
      smin = VLenOtrezok (p1, p2);
      *ret = smin;
      return (TRUE);
    }

  if      (ra->geodez)   /* rsurf = RsurfCreateTest () */;
  else    graf = VSurfMakeGraf (surf);

  if (!(num1 = VRoadFindRays (ra, p1, surf, &rays1)))  {YWarning("num1="); return (FALSE);}
  if (!local && p2 == NULL) {
    full = VRoadFullGraf (graf, rays1, num1);
    return (TRUE);
  }

  if (!(num2 = VRoadFindRays (ra, p2, surf, &rays2)))  {YWarning("num1="); return (FALSE);}
  new_graf = VGrafCreate (num1 + num2 + 2);

  flag = YWaitBegin (WAIT, num1 * num2, "VRoadCalc"); 
  for (i = 0; i < num1; i++) 
  for (j = 0; j < num2; j++) {
    pk1 = &rays1[i];
    pk2 = &rays2[j];
    
    if (!local)         smin = full[BB (graf->nn,graf->nn, pk1->uzel,pk2->uzel)];
    else {
      if (!ra->geodez)  VGrafSmin (graf, pk1->uzel, pk2->uzel, &smin);
      else              smin=DugaOnSphere(1, pk1->t,pk2->t); 
    }
    
    GRAF_EDGE (new_graf, i, num1 + j) = (VT_GV)smin;
    if (!YWaitSend (flag)) {YWaitEnd(); return (FALSE);}
  }
  YWaitEnd ();

  s = num1 + num2;
  t = num1 + num2 + 1;

  for (i = 0; i < num1; i++) {
    pk = &rays1[i];
    GRAF_EDGE (new_graf, s, i) = (VT_GV)(pk->l);
  }

  for (j = 0; j < num2; j++) {
    pk = &rays2[j];
    GRAF_EDGE (new_graf, t, num1 + j) = (VT_GV)(pk->l);
  }

  VGrafSmin (new_graf, s, t, &smin);

  *ret = smin;
  return (TRUE);
}
/*----------------------------------mix3_info_proc----------------------------------*/
long            
mix3_info_proc (PFUNC_VAR)
{
  typedef struct {
    int  hImax, hJmax, hKmax;
    char Imax[5], Jmax[5], Kmax[5];
    char *fname;
  } YT_USR;

  static int  *p_ii, *p_jj, *p_kk;

  switch (message) {
  case YOPEN:
    U_MALLOC;
    U->fname = (char*) YGet("wlong1");
    p_ii = (int*) YGet("wlong2");
    p_jj = (int*) YGet("wlong3");
    p_kk = (int*) YGet("wlong4");
    /* strcpy (U->Imax, ""); */
    /* strcpy (U->Jmax, ""); */
    /* strcpy (U->Kmax, ""); */
  case YDRAW:
    sprintf (U->Imax, "%d", *p_ii);  
    sprintf (U->Jmax, "%d", *p_jj); 
    sprintf (U->Kmax, "%d", *p_kk);  
    YDrawRectFB (0, 0, WND->w, WND->h, YColor("white"), YColor("black"));

    YBeginGroup ("", 10, 10, 100, 120, YColor(""));
    YWnd (Ph(), PUSH, "Info", 20,10, 55,20,  0,0,0,0, CLR_DEF);
    YWnd (&U->hImax, YTEXT, "II= ", 40,40, 40,20, (long)U->Imax,0,0,0, CLR_DEF);
    YWnd (&U->hJmax, YTEXT, "JJ= ", 40,65, 40,20, (long)U->Jmax,0,0,0, CLR_DEF);
    YWnd (&U->hKmax, YTEXT, "KK= ", 40,90, 40,20, (long)U->Kmax,0,0,0, CLR_DEF);
    YEndGroup ();

    break;
  case YPUSH:
    Mix3TestBinoff (U->fname);

    Mix3PreloadFile (U->fname, p_ii, p_jj, p_kk);
    sprintf (U->Imax, "%d", *p_ii);  
    sprintf (U->Jmax, "%d", *p_jj); 
    sprintf (U->Kmax, "%d", *p_kk);  

    YWndUpdate (U->hImax);
    YWndUpdate (U->hJmax);
    YWndUpdate (U->hKmax);
    break;
  case YCLOSE:
    YWndClean (id);
    break;
  default: ;;;;
  }

  RETURN_TRUE;
}
/*----------------------------------mix3_want_proc----------------------------------*/
long            
mix3_want_proc (PFUNC_VAR)
{

  static YT_MIX3_WANT *w;
  int i;

  switch (message) {
  case YOPEN:
    w = (YT_MIX3_WANT*) YGet("wlong1");
  case YDRAW:
    YDrawRectFB (0, 0, WND->w, WND->h, YColor("white"), YColor("black"));

    YBeginGroup ("What you want?", 20,15, 190,140, YColor(""));
    i = 0;
    YWnd (Ph(), CHECK, "Ro",   15, 10+25*i++, 20, 20, 0, LP(w->ro), 0,0, CLR_DEF);
    YWnd (Ph(), CHECK, "E",    15, 10+25*i++, 20, 20, 0, LP(w->e),  0,0, CLR_DEF);
    YWnd (Ph(), CHECK, "P",    15, 10+25*i++, 20, 20, 0, LP(w->p),  0,0, CLR_DEF);
    YWnd (Ph(), CHECK, "V_x",  15, 10+25*i++, 20, 20, 0, LP(w->vx), 0,0, CLR_DEF);
    i = 0;
    YWnd (Ph(), CHECK, "V_y", 110, 10+25*i++, 20, 20, 0, LP(w->vy), 0,0, CLR_DEF);
    YWnd (Ph(), CHECK, "V_z", 110, 10+25*i++, 20, 20, 0, LP(w->vz), 0,0, CLR_DEF);
    YWnd (Ph(), CHECK, "|V|", 110, 10+25*i++, 20, 20, 0, LP(w->v),  0,0, CLR_DEF);
    YWnd (Ph(), CHECK, "nFl", 110, 10+25*i++, 20, 20, 0, LP(w->nn), 0,0, CLR_DEF);
    YWnd (Ph(), CHECK, "dot", 110, 10+25*i++, 20, 20, 0, LP(w->dot),0,0, CLR_DEF);
    YEndGroup ();

    break;
  case YCLOSE:
    YWndClean (id);
    break;
  default: ;;;;
  }

  RETURN_TRUE;
}
/*----------------------------------Mix3CreateLat-------------------------------------*/
YT_BOOL            
Mix3CreateLat (void **p_lat, YT_MIX3_WANT *w, int ii, int jj, int kk)
{
  
  int  d, dd;
  static char *data_names[10];

  d = 0;
  if (w->ro)   data_names[d++] = "Ro";
  if (w->e)    data_names[d++] = "E";
  if (w->p)    data_names[d++] = "P";
  if (w->vx)   data_names[d++] = "V_x";
  if (w->vy)   data_names[d++] = "V_y";
  if (w->vz)   data_names[d++] = "V_z";
  if (w->v)    data_names[d++] = "|V|";
  if (w->nn)   data_names[d++] = "nFl";
  if (w->dot)  data_names[d++] = "dot";
  data_names[d] = NULL;

  dd = d;

  if (!(VLAT (p_lat, 3, YCONSTR0, ii, jj, kk, dd))) {
    YMessageBox ("Don't CreateLAT !", "OK");
    return (FALSE);
  }
  VLAT (*p_lat, 0, YNAMES, 0, 0, 0, (long)data_names);

  return (TRUE);
}
/*----------------------------------Mix3ReadPoints-----------------------------------*/
YT_BOOL            
Mix3ReadPoints (FILE *fp, VT_MIX3 *m, void *lat, YT_MIX3_WANT *w)
{
  
  YT_SPACE val;
  M3_POINT m3_point, *point;
  int i, j, k, d;

  int ii = ((VT_LAT*)lat)->ii;
  int jj = ((VT_LAT*)lat)->jj;
  int kk = ((VT_LAT*)lat)->kk;

  if (fp) point = &m3_point;

  YWaitBegin (WAIT, ii * jj * kk, "Reading points");

  for (k = 1; k <= kk; k++)
  for (j = 1; j <= jj; j++)
  for (i = 1; i <= ii; i++) {
    YWaitSend (TRUE/* , "Reading points" */); 
	
    if (fp) { 
      if (fread (point, sizeof(M3_POINT), 1, fp) != 1) YError ("m3_points");
    } else {
/*       point = &(m->m3_points[BBB_old (ii,jj,kk, i-1,j-1,k-1)]); */
      point = &(m->m3_points[BBB(kk,jj,ii, k-1,j-1,i-1)]);
    }
    
    VLAT (lat, LP(point->r.x), YPUTDATA, i, j, k, 1);
    VLAT (lat, LP(point->r.y), YPUTDATA, i, j, k, 2);
    VLAT (lat, LP(point->r.z), YPUTDATA, i, j, k, 3);
    d = 4;
    if (w->ro)  VLAT_put (lat, i,j,k, d++, LP(point->ro));
    if (w->e)   VLAT_put (lat, i,j,k, d++, LP(point->e));
    if (w->p)   VLAT_put (lat, i,j,k, d++, LP(point->p));  
    if (w->vx)  VLAT (lat, LP(point->u.x), YPUTDATA, i, j, k, d++);
    if (w->vy)  VLAT (lat, LP(point->u.y), YPUTDATA, i, j, k, d++);
    if (w->vz)  VLAT (lat, LP(point->u.z), YPUTDATA, i, j, k, d++);
    if (w->v) {
      val = sqrt (point->u.x * point->u.x +
		  point->u.y * point->u.y +
		  point->u.z * point->u.z);
      VLAT (lat, LP(val), YPUTDATA, i, j, k, d++);
    }
    if (w->nn) {
      VLAT_put (lat, i,j,k, d++, LP(val));
    }
  }
  YWaitEnd ();               


  return (TRUE);
}
/*----------------------------------Mix3ReadTins-----------------------------------*/
YT_BOOL            
Mix3ReadTins (FILE *fp, VT_MIX3 *m, void *lat)
{
  
  int i, j, k;
  double  vals, *p_vals;

  int ii = ((VT_LAT*)lat)->ii;
  int jj = ((VT_LAT*)lat)->jj;
  int kk = ((VT_LAT*)lat)->kk;
  int dd = ((VT_LAT*)lat)->dd;

  if (fp) p_vals = &vals;

  for (k = 1; k <= kk; k++) {
  for (j = 1; j <= jj; j++) {
  for (i = 1; i <= ii; i++) {
    if (i==1 || j==1 || k==1)  continue; 

    if (fp) {
      if (fread(p_vals, sizeof(double), 1, fp) != 1) YError("array_vals");
    } else {
/*       p_vals = &(m->vals[BBB_old (ii-1,jj-1,kk-1, i-1,j-1,k-1)]); */
      p_vals = &(m->vals[BBB(kk-1,jj-1,ii-1, k-1,j-1,i-1)]);
    }

    VLAT_put (lat, i,j,k, dd+3, (long)p_vals);
  }}}
	
  return (TRUE);
}
/*---------------------------------------mRmix3-------------------------------------*/
long            
mRmix3 (PFUNC_VAR)
{

  static REGION_T  def_region;

  typedef struct {
    ABCD;
  } YT_USR;
  enum words {
    MAHMAKELAT = YKEY_LOCALS + 1, MAHPRELOADFILE
  };

  static int hFile;
  static void *lat;
  static int i, j/* , k */; 
  char   *text[] =
  {
    "This module read file ********.mix",
    "and make latice data..............",
    NULL
  };

  static int  ii_1, jj_1, kk_1, ii, jj, kk;
  static long  NUM;
  static short type;

  static FILE  *fp;

/*   static YT_SPACE val; */
/*   static M3_POINT m3_point; */

  static VT_PARS pars[] = {
    {"bool",   "vx",    "TRUE"}, 
    {"bool",   "vy",    "TRUE"}, 
    {"bool",   "vz",    "TRUE"}, 
    {"bool",   "ro",    "TRUE"}, 
    {"bool",   "e",     "TRUE"}, 
    {"bool",   "p",     "TRUE"}, 
    {"bool",   "v",     "TRUE"}, 
    {"bool",   "nn",    "TRUE"}, 
    {"bool",   "dot",   "TRUE"}, 
    {"string", "fname", "00003000.mix"}, 
    {NULL}};
  static char Fname[80];

  static YT_MIX3_WANT want, *w;
  static int hInfo;

  switch (message) {
  case YCREATE:
    U_MALLOC;
    WND->name = "Rmix3";
    lat = NULL;

    w = &want;

    PAR_INIT ("fname", Fname); 
    PAR_INIT ("ro",  &w->ro); 
    PAR_INIT ("e",   &w->e); 
    PAR_INIT ("p",   &w->p);  
    PAR_INIT ("vx",  &w->vx);
    PAR_INIT ("vy",  &w->vy); 
    PAR_INIT ("vz",  &w->vz);  
    PAR_INIT ("v",   &w->v); 
    PAR_INIT ("nn",  &w->nn);  
    PAR_INIT ("dot", &w->dot);

    /* IntrSetDatas(); */
    break;
  case MM_APPLY:
    if (!YGoto (MAHMAKELAT, 0, 0, 0, 0))   break;;
    YWndUpdate (hInfo);
    YAlgOut (YSEND2FACE, MM_LAT3,  0, 0, 0, (long)(lat));
    break;

  case MAHMAKELAT:
    {
     /*  int     d, dd; */
     /*  static char *data_names[10]; */

      CELL    cells;
     /*  double  vals; */
      if ((fp = fopen (Fname, "rb")) == NULL) {
	YMessageBox ("Cannot open input file", "OK");
	return (FALSE);
      }

      if (fread (&def_region,  sizeof (REGION_T),  1, fp) != 1) YError ("DOMAIN");

      NUM    = def_region.NUM;
      type   = def_region.type;

      ii_1 = def_region.III;
      jj_1 = def_region.JJJ;
      kk_1 = def_region.KKK;
      ii = ii_1 + 1;
      jj = jj_1 + 1;
      kk = kk_1 + 1;


      Mix3CreateLat (&lat, w, ii, jj, kk);

      Mix3ReadPoints (fp, NULL, lat, w);

      if (w->dot && type == 2  ) {
	for(i = 0; i < NUM; i++){
	  if(fread(&cells, sizeof(CELL), 1, fp)	!= 1) YError("CELLstep");
	}

	Mix3ReadTins (fp, NULL, lat);
      }

      fclose (fp);
      return (TRUE);
    }

  case YGETSIZE:
    MYSIZE_IS (W_MOD, H_MOD);
    break;
  case YOPEN:
  case YDRAW:
    YDrawRectF (0, 0, WND->w, WND->h, WIN->color);
    YDrawStrings (text, 20, 20);

    YWnd (&hFile, FILES, "Name : ", 80, 60, 150, 20, (long)Fname,75,0,0, CLR_DEF); 
    YWnd (&hInfo, mix3_info_proc, "", 210,95, 100,120, (long)Fname, 
	  LP(ii_1),LP(jj_1),LP(kk_1), CLR_DEF); 
    YWnd (Ph(), mix3_want_proc, "", 10, 95, 190,135, (long)w, 0, 0, 0, CLR_DEF); 

    break;
  case YCLOSE:
    YWndClean (id);
    break;
  default:
    MM_ONLY;
    YAlgOut (YSEND2FACE, message,  mes1, mes2, mes3, mes4);
  }

  RETURN_TRUE;
}
/*---------------------------------------mToLat-------------------------------------*/
long            
mToLat (PFUNC_VAR)
{

  typedef struct {
    ABCD;
  } YT_USR;

  static int  ii, jj, kk;
  static short type;
 /*  static int i, j, k;  */

  char   *text[] =
  {
    "..........................",
    "..........................",
    NULL
  };

  static VT_PARS pars[] = {
    {"bool",   "vx",    "TRUE"}, 
    {"bool",   "vy",    "TRUE"}, 
    {"bool",   "vz",    "TRUE"}, 
    {"bool",   "ro",    "TRUE"}, 
    {"bool",   "e",     "TRUE"}, 
    {"bool",   "p",     "TRUE"}, 
    {"bool",   "v",     "TRUE"}, 
    {"bool",   "nn",    "TRUE"}, 
    {"bool",   "dot",   "TRUE"}, 
    {"string", "fname", "00003000.mix"}, 
    {NULL}};

  static YT_MIX3_WANT want, *w;
  static VT_MIX3 *mix3 = NULL;
  static void    *lat  = NULL;

  switch (message) {
  case YCREATE:
    U_MALLOC;
    WND->name = "ToLat";
    lat = NULL;

    w = &want;

    PAR_INIT ("ro",  &w->ro); 
    PAR_INIT ("e",   &w->e); 
    PAR_INIT ("p",   &w->p);  
    PAR_INIT ("vx",  &w->vx);
    PAR_INIT ("vy",  &w->vy); 
    PAR_INIT ("vz",  &w->vz);  
    PAR_INIT ("v",   &w->v); 
    PAR_INIT ("nn",  &w->nn);  
    PAR_INIT ("dot", &w->dot);

    break;
  case MM_DATA:
    mix3 = (VT_MIX3*) PDATA;
  case MM_APPLY:
    YGoto (YMAKE, 0, 0, 0, 0);
    YAlgOut (YSEND2FACE, MM_LAT3,  0, 0, 0, (long)(lat));
    break;
  case YMAKE:
    if (!mix3) break;

    type   = (mix3->def_region).type;
    ii = (mix3->def_region).III + 1;
    jj = (mix3->def_region).JJJ + 1;
    kk = (mix3->def_region).KKK + 1;

    Mix3CreateLat (&lat, w, ii, jj, kk);

    Mix3ReadPoints (NULL, mix3, lat, w);

    if (w->dot && type == 2  )
      Mix3ReadTins (NULL, mix3, lat);
     
    return (TRUE);
  case YGETSIZE:
    MYSIZE_IS (W_MOD, H_MOD);
    break;
  case YOPEN:
  case YDRAW:
    YDrawRectF (0, 0, WND->w, WND->h, WIN->color);
    YDrawStrings (text, 20, 20);

    YWnd (Ph(), mix3_want_proc, "", 10, 95, 190,135, (long)w, 0, 0, 0, CLR_DEF); 

    break;
  case YCLOSE:
    YWndClean (id);
    break;
  default:
    MM_ONLY;
    YAlgOut (YSEND2FACE, message,  mes1, mes2, mes3, mes4);
  }

  RETURN_TRUE;
}
/*--------------------------------mRW_max--------------------------------------*/
long            
mRW_max (PFUNC_VAR)
{

  char   s_act[80];
  static int  ii, jj, kk; 
  static int  hInfo;

  typedef struct {
    VT_MIX3 *m;
    char     Fname[80];
    int      act, mode;

    int      hFile;
    YT_BOOL  is_read, is_write, is_bin, is_txt;
  } YT_USR;

  static VT_PARS pars[] = {
    {"string",  "fname",  "00000001.mix"}, 
    {"string",  "s_act",  "YREAD"}, 
    {NULL}};

  switch (message) {
  case YCREATE:
    U_MALLOC;
    WND->name = "RW_max";
    U->is_read  = U->is_write = U->is_bin = U->is_txt = FALSE;

    PAR_INIT ("fname", U->Fname); 
    PAR_INIT ("s_act", s_act); 

    if      (YStrCmp(s_act,"YREAD"))  {U->act = YREAD;  U->is_read  = TRUE;}
    else if (YStrCmp(s_act,"YWRITE")) {U->act = YWRITE; U->is_write = TRUE;}

    U->is_bin = TRUE;
    YGoto (YCHECK, 0,0,0, 0);

    U->m = NULL;
    YGoto (YTEST, 0, 0, 0, 0);

    ii = jj = kk = 0;
   /*  YBinoffTest (); */
    break;
  case YCHECK:
    if      ( U->is_bin && !U->is_txt) U->mode = YBIN;
    else if (!U->is_bin &&  U->is_txt) U->mode = YTXT;
    else    YBeep();
    break;
  case YTEST:
    IntrDoTypes (mix3_types);
    break;
  case MM_APPLY:
    if (!YGoto (YMAKE, 0, 0, 0, 0)) break;
    YAlgOut (YSEND2FACE, MM_DATA,  0, 0, 0, (long)U->m);
    break;
  case MM_DATA:
    U->m = (VT_MIX3*) PDATA;
    U->act = YWRITE;  U->is_write = TRUE;  U->is_read = FALSE;
    YGoto (YMAKE, 0, 0, 0, 0);
    break;  
  case YMAKE:
    /* YBinoffSet (4); */
/*     IntrDoTypes (mix3_types); */ /*error*/

    Mix3RW (U->Fname, &(U->m), U->act, U->mode);
    YWndUpdate (hInfo);
    break;  
  case YGETSIZE:
    MYSIZE_IS (W_MOD, H_MOD);
    break;  
  case YOPEN:
  case YDRAW:
    YDrawRectF (0, 0, WND->w, WND->h, WIN->color);

    YWnd (&U->hFile, FILES, "Name : ", 80,30, 150,20,  (long)U->Fname,75,0,0, CLR_DEF);

    YBeginGroup ("Act",  20,70, 120,70, YColor(""));
    YWndGroupBegin ();
    YWnd (Ph(), CHECK, "read",  15,10, 20,20, 0,LP(U->is_read),0,0,  CLR_DEF);
    YWnd (Ph(), CHECK, "write", 15,35, 20,20, 0,LP(U->is_write),0,0, CLR_DEF);
    YWndGroupEnd ();
    YEndGroup ();

    YBeginGroup ("Mode", 20,150, 120,70, YColor(""));
    YWndGroupBegin ();
    YWnd (Ph(), CHECK, "binary", 15,10, 20,20, 0,LP(U->is_bin),0,0, CLR_DEF);
    YWnd (Ph(), CHECK, "ascii",  15,35, 20,20, 0,LP(U->is_txt),0,0, CLR_DEF);
    YWndGroupEnd ();
    YEndGroup ();

    YWnd (&hInfo, mix3_info_proc, "", 200,80, 100,120, (long)U->Fname, 
	  LP(ii),LP(jj),LP(kk), CLR_DEF); 

    break;
  case YCLOSE:
    YWndClean (id);
    break;
  default:
    if (MM_FORWARD)  YAlgOut (YSEND2FACE, message,  mes1, mes2, mes3, mes4);
  }

  RETURN_TRUE;
}
/*--------------------------------mConver--------------------------------------*/
long            
mConver (PFUNC_VAR)
{

  static int  hInfo, hFile_R, hFile_W;
  static char fname_r[80], fname_w[80];
  static int  ii, jj, kk;
  static YT_BOOL  work_1, work_2, work_3;
  static VT_MIX3 *mix3;
  

  switch (message) {
  case YCREATE:
    WND->name = "Conver";

    mix3 = NULL;
    IntrDoTypes (mix3_types);

   /*  YBinoffTest (); */
    ii = jj = kk = 0;
    work_1  = TRUE;
    work_2  = FALSE;
    work_3  = FALSE;
    break;
  case MM_APPLY:
  case YMAKE:
    if (work_1) {
      Mix3RW (fname_r, &mix3, YREAD,  YBIN);
      Mix3RW (fname_w, &mix3, YWRITE, YTXT);
    } 
    else if (work_2) {
      Mix3RW (fname_r, &mix3, YREAD,  YTXT);
      Mix3RW (fname_w, &mix3, YWRITE, YBIN);
    }

    YWndUpdate (hInfo);
    break;  
  case YGETSIZE:
    MYSIZE_IS (W_MOD, H_MOD);
    break;  
  case YOPEN:
  case YDRAW:
    YDrawRectF (0, 0, WND->w, WND->h, WIN->color);

    YWnd (&hFile_R, FILES, "Read  : ", 100,30, 150,20,  (long)fname_r, 75, 0, 0, CLR_DEF);
    YWnd (&hFile_W, FILES, "Write : ", 100,60, 150,20,  (long)fname_w, 75, 0, 0, CLR_DEF);

    YBeginGroup ("TODO",  30,100, 120,100, YColor(""));
    YWndGroupBegin ();
    YWnd (Ph(), CHECK, "bin->ascii",  15,10, 20,20, 0,LP(work_1),0,0,  CLR_DEF);
    YWnd (Ph(), CHECK, "ascii->bin",  15,40, 20,20, 0,LP(work_2),0,0,  CLR_DEF);
    YWnd (Ph(), CHECK, "bin->bin",    15,70, 20,20, 0,LP(work_3),0,0,  CLR_DEF);
    YWndGroupEnd ();
    YEndGroup ();

    YWnd (&hInfo, mix3_info_proc, "", 190,100, 100,120, (long)fname_r, 
	  LP(ii),LP(jj),LP(kk), CLR_DEF); 

    break;
  case YCLOSE:
    YWndClean (id);
    break;
  default: ;;;
  }

  RETURN_TRUE;
}
/*----------------------------VLat3CellCenter-----------------------------*/
void
VLat3CellCenter (VT_LAT *lat3, int i, int j, int k, VT_P3D *pc)
{

  int     l, m, n;
  VT_P3D  p1, p2, p3, p4, p5, p6, p7, p8;


  l = i; m = j; n = k;
  VLAT (lat3, LP(p1.x), YGETDATA, l, m, n, 1);
  VLAT (lat3, LP(p1.y), YGETDATA, l, m, n, 2);
  VLAT (lat3, LP(p1.z), YGETDATA, l, m, n, 3);
  
  l = i-1; m = j; n = k;
  VLAT (lat3, LP(p2.x), YGETDATA, l, m, n, 1);
  VLAT (lat3, LP(p2.y), YGETDATA, l, m, n, 2);
  VLAT (lat3, LP(p2.z), YGETDATA, l, m, n, 3);
  
  l = i; m = j-1; n = k;
  VLAT (lat3, LP(p3.x), YGETDATA, l, m, n, 1);
  VLAT (lat3, LP(p3.y), YGETDATA, l, m, n, 2);
  VLAT (lat3, LP(p3.z), YGETDATA, l, m, n, 3);
  
  l = i; m = j; n = k-1;
  VLAT (lat3, LP(p4.x), YGETDATA, l, m, n, 1);
  VLAT (lat3, LP(p4.y), YGETDATA, l, m, n, 2);
  VLAT (lat3, LP(p4.z), YGETDATA, l, m, n, 3);
  
  l = i-1; m = j-1; n = k;
  VLAT (lat3, LP(p5.x), YGETDATA, l, m, n, 1);
  VLAT (lat3, LP(p5.y), YGETDATA, l, m, n, 2);
  VLAT (lat3, LP(p5.z), YGETDATA, l, m, n, 3);
  
  l = i-1; m = j; n = k-1;
  VLAT (lat3, LP(p6.x), YGETDATA, l, m, n, 1);
  VLAT (lat3, LP(p6.y), YGETDATA, l, m, n, 2);
  VLAT (lat3, LP(p6.z), YGETDATA, l, m, n, 3);
  
  l = i; m = j-1; n = k-1;
  VLAT (lat3, LP(p7.x), YGETDATA, l, m, n, 1);
  VLAT (lat3, LP(p7.y), YGETDATA, l, m, n, 2);
  VLAT (lat3, LP(p7.z), YGETDATA, l, m, n, 3);
  
  l = i-1; m = j-1; n = k-1;
  VLAT (lat3, LP(p8.x), YGETDATA, l, m, n, 1);
  VLAT (lat3, LP(p8.y), YGETDATA, l, m, n, 2);
  VLAT (lat3, LP(p8.z), YGETDATA, l, m, n, 3);
  
  pc->x = (p1.x + p2.x + p3.x + p4.x + p5.x + p6.x + p7.x + p8.x) / 8 ;
  pc->y = (p1.y + p2.y + p3.y + p4.y + p5.y + p6.y + p7.y + p8.y) / 8 ;
  pc->z = (p1.z + p2.z + p3.z + p4.z + p5.z + p6.z + p7.z + p8.z) / 8 ;
  

  return;
}
/*-------------------------------VRoadCalc_old---------------------------------*/
YT_BOOL
VRoadCalc_old (VT_ROAD *ra, VT_SURF *surf, VT_P3D *p1, VT_P3D *p2, YT_SPACE *ret, 
           YT_BOOL local)
{
  static VT_GV smin;
  VT_GRAF *new_graf;
  VT_RAYS *rays2, *pk1, *pk2, *pk;
  int     num2, i, j;
  VT_GI s, t;
  YT_BOOL flag;

  static VT_GRAF *graf;
  static VT_RAYS *rays1;
  static int num1;
  static VT_GV *full;

  if (p2 != NULL)
    if (VSurfIsvisPoint (surf, p1, p2, -1)) {
      smin = VLenOtrezok (p1, p2);
      *ret = smin;
      return (TRUE);
    }

  graf = VSurfMakeGraf (surf);

  if (!(num1 = VRoadFindRays (ra, p1, surf, &rays1)))  {YWarning("num1="); return (FALSE);}

  if (p2 == NULL) {
    full = VRoadFullGraf (graf, rays1, num1); 
    return (TRUE);
  }
  if (!(num2 = VRoadFindRays (ra, p2, surf, &rays2)))  {YWarning("num2="); return (FALSE);}

  new_graf = VGrafCreate (num1 + num2 + 2);

  flag = YWaitBegin (WAIT, num1 * num2, "VRoadCalc_old"); 
  for (i = 0; i < num1; i++) 
  for (j = 0; j < num2; j++) {
    pk1 = &rays1[i];
    pk2 = &rays2[j];
    
    smin = full[BB (graf->nn,graf->nn, pk1->uzel,pk2->uzel)];
    GRAF_EDGE (new_graf, i, num1 + j) = smin;

    if (!YWaitSend (flag)) {YWaitEnd(); return (FALSE);}
  }
  YWaitEnd ();

  s = num1 + num2;
  t = num1 + num2 + 1;

  for (i = 0; i < num1; i++) {
    pk = &rays1[i];
    GRAF_EDGE (new_graf, s, i) = pk->l;
  }

  for (j = 0; j < num2; j++) {
    pk = &rays2[j];
    GRAF_EDGE (new_graf, t, num1 + j) = pk->l;
  }

  VGrafSmin (new_graf, s, t, &smin);

  VGrafDestroy (graf);

  *ret = smin;
  return (TRUE);
}
/*------------------------------mDcalc------------------------------------*/
long
mDcalc (PFUNC_VAR)
{
  typedef struct {
    ABCD;
  } YT_USR;

  char   *text[] = {
    "Calculate MinWays between points",
    "with  round  of a given surface.",
    NULL
  };

  int i,j,k/* , l,m,n */;
  static int ii,jj,kk;
  static VT_LAT *lat3;
  static YT_SPACE sway, /* test, */ r;

  VT_SETKA setka={NULL};
  static VT_SURF *surf;
  static VT_ROAD ra;

  static int hs_x,hs_y,hs_z ;
  static YT_BOOL do_sphere=TRUE; 

  static VT_P3D  p0,  pc/* , p1,p2,p3,p4,p5,p6,p7,p8 */;
  static VT_PARS pars[] = {
    {"space", "p0_x",  "-12"}, 
    {"space", "p0_y",    "0"}, 
    {"space", "p0_z",    "0"}, 
    {NULL}};

  switch (message) {
  case YCREATE:
    U_MALLOC;
    WND->name = "Dcalc";

    PAR_INIT ("p0_x", &(p0.x));
    PAR_INIT ("p0_y", &(p0.y));
    PAR_INIT ("p0_z", &(p0.z));
    /* VSetPoint3D (&p0, -12, 0, 0); */

    ra.geodez = FALSE;
    ra.horizon = TRUE;
    ra.cutvis = FALSE;
    ra.kleying = TRUE;
    r=9.0;
    break;
  case MM_LAT3:
    lat3 = (VT_LAT *) PDATA;
    ii = lat3->ii;
    jj = lat3->jj;
    kk = lat3->kk;
    YGoto (YWORK, 0, 0, 0, 0);
    break;
  case MM_APPLY:
    YGoto (YSCANF, 0,0,0, 0);
    YGoto (YWORK, 0, 0, 0, 0);
    break;
  case YWORK:
    if (!YGoto (YMAKE, 0, 0, 0, 0)) {YMessageBox ("Don't calculate", "OK");break;}
    YAlgOut (YSEND2FACE, MM_LAT3,  0, 0, 0, (long)lat3);
    break;
  case YMAKE:           
    if (do_sphere) {
      VLAT (lat3, LP(r), YGETDATA, ii, 1, 1,  1);
      OUTF(r);
      VLAT (lat3, LP(r), YGETDATA,  1, 1, 1,  1);
      OUTF(r);
    }else{
      VSetkaFromLat3 (&setka,lat3);
      VSetkaSetSizes (&setka,12,12);
      surf = VSurfFromSetka (&setka, ra.kleying, -1);
      VRoadCalc_old (&ra, surf, &p0, NULL, &sway, FALSE);
    }

    YWaitBegin (WAIT, ii * jj * kk, "Dcalc - ii*jj*kk");
    for (i = 1; i <= ii; i++)
    for (j = 1; j <= jj; j++)
    for (k = 1; k <= kk; k++) {
      if (i==1 || j==1 || k==1)  continue;  
      YWaitSend (TRUE/* , "Dcalc - ii*jj*kk" */);

      VLat3CellCenter (lat3, i, j, k, &pc);

      if (do_sphere) 
	sway = SwayOnSphere (r, &p0, &pc);
      else
	if (!VRoadCalc_old (&ra, surf, &p0, &pc, &sway, FALSE))  return (FALSE);

      /* if (i==1) sway = -1; */
      VLAT_put (lat3, i, j, k, 4, LP(sway));

    }
    YWaitEnd ();

    lat3->data_names[0] = "MinSway";
    return (TRUE);
  case YSCANF:
    if (Y_WMODE) {
      YGetData (hs_x);
      YGetData (hs_y);
      YGetData (hs_z);
    }else{
    }
    break;
  case YGETSIZE:
    MYSIZE_IS (W_MOD, H_MOD);
    break;
  case YOPEN:
  case YDRAW:
    YDrawRectF (0, 0, WND->w, WND->h, WIN->color);
    YDrawStrings (text, 25, 20);

    YBeginGroup ("Point", 5,65, 165,40, YColor(""));
    YWnd (&hs_x, FLOATS, "S= ", 25,10, 45,20, LP(p0.x),YSPACE,0,0, CLR_DEF);
    YWnd (&hs_y, FLOATS, "",    70,10, 45,20, LP(p0.y),YSPACE,0,0, CLR_DEF);
    YWnd (&hs_z, FLOATS, "",   115,10, 45,20, LP(p0.z),YSPACE,0,0, CLR_DEF);
    YEndGroup ();

    YBeginGroup ("SPHERE-calc", 5,145, 140,50, YColor(""));
    YWnd (Ph(), CHECK, "Do it?", 15,20, 20,20, 0,LP(do_sphere),0,0, CLR_DEF);
    YEndGroup ();

    YLoadMyFont ();
    YDrawMyString ("TEST", 115, 120, YColor("black"));
    break;
  case YCLOSE:
    YWndClean (id);
    break;
  default:
    MM_ONLY;
    YAlgOut (YSEND2FACE, message,  mes1, mes2, mes3, mes4);
  }

  RETURN_TRUE;
}
/*-----------------------------Mix3SeekToTins--------------------------------*/
YT_BOOL            
Mix3SeekToTins (FILE *fp, VT_LAT *lat3) 
{
  static REGION_T  def_region;

  static int i, j, k; 
  
  static int  ii, jj, kk;
  static long  NUM;
  ;
  static M3_POINT m3_point;
  CELL    cells;

  if (fread (&def_region,  sizeof (REGION_T), 1, fp) != 1) YError ("DOMAIN");
  ii = def_region.III;
  jj = def_region.JJJ;
  kk = def_region.KKK;
  ii++;  jj++;  kk++;
  
  if ((lat3->ii != ii) || (lat3->jj != jj) || (lat3->kk != kk)) {
    fclose (fp); YWarning ("ii_jj_kk");
    return (FALSE);
  }
  
  NUM    = def_region.NUM;
  
  for (k = 1; k <= kk; k++)
  for (j = 1; j <= jj; j++)
  for (i = 1; i <= ii; i++) {
    if (fread (&m3_point, sizeof(M3_POINT), 1, fp) != 1) YError ("m3_points");
  }
  
  for(i = 0; i < NUM; i++){
    if(fread(&cells, sizeof(CELL), 1, fp)	!= 1) YError("CELLstep");
  }
  

  return (TRUE);
}
/*-------------------------------mWmix3--------------------------------------*/
long            
mWmix3 (PFUNC_VAR)
{

  static REGION_T  def_region;

  typedef struct {
    ABCD;
  } YT_USR;
  enum words {
    MAHMAKELAT = YKEY_LOCALS + 1, MAHPRELOADFILE
  };

  /* static void *lat; */
  static int i, j, k; 
  char   *text[] =
  {
    "This module read file ********.mix",
    "and make latice data..............",
    NULL
  };

  static int  ii, jj, kk;
  static long  NUM;

  static char Fname[80];
  static FILE  *fp;

  /* static YT_SPACE val; */
  static M3_POINT m3_point;
  static VT_LAT *lat3 = NULL;

  static int hv;
  static YT_SPACE v;
  static VT_PARS pars[] = {
    {"string", "fname", "0000000.mix"}, 
    {"space",  "v",     "1.0"        }, 
    {NULL}};

  switch (message) {
  case YCREATE:
    U_MALLOC;
    WND->name = "Wmix3";
    PAR_INIT ("fname", Fname);
    PAR_INIT ("v", &v);
    break;
  case MM_LAT3:
    lat3 = (VT_LAT *) PDATA;
    YGoto (YWORK, 0, 0, 0, 0);
    break;
  case MM_APPLY:
    YGetData (hv);
    YGoto (YWORK, 0, 0, 0, 0);
    break;
  case YWORK:
    {
      CELL    cells;
      static double  vals;

      if (lat3 ==NULL) break;

      if ((fp = fopen (Fname, "r+")) == NULL) {
	YMessageBox ("Cannot open output file", "OK");
	return (FALSE);
      }

      if (fread (&def_region,  sizeof (REGION_T), 1, fp) != 1) YError ("DOMAIN");
      ii = def_region.III;
      jj = def_region.JJJ;
      kk = def_region.KKK;
      ii++;  jj++;  kk++;

      if ((lat3->ii != ii) || (lat3->jj != jj) || (lat3->kk != kk)) {
	fclose (fp); YWarning ("ii_jj_kk");
	return (FALSE);
      }

      NUM    = def_region.NUM;

      for (k = 1; k <= kk; k++)
      for (j = 1; j <= jj; j++)
      for (i = 1; i <= ii; i++) {
	if (fread (&m3_point, sizeof(M3_POINT), 1, fp) != 1) YError ("m3_points");
      }

      for(i = 0; i < NUM; i++){
	if(fread(&cells, sizeof(CELL), 1, fp)	!= 1) YError("CELLstep");
      }

      fseek(fp,0,1);
      for (k = 1; k <= kk; k++) 
      for (j = 1; j <= jj; j++) 
      for (i = 1; i <= ii; i++) {
	if (i==1 || j==1 || k==1)  continue; 
	/* vals=2.0;  */
	VLAT (lat3, LP(vals), YGETDATA, i, j, k,    4); 
	vals=vals / v;
	if (fwrite(&vals, sizeof(double), 1, fp) != 1) YError("array_vals");
      }
      
      fclose (fp);
      return (TRUE);
    }

  case YGETSIZE:
    MYSIZE_IS (W_MOD, H_MOD);
    break;
  case YOPEN:
  case YDRAW:
    YDrawRectF (0, 0, WND->w, WND->h, WIN->color);
    YDrawStrings (text, 20, 20);

    YWnd (Ph(), FILES, "Name : ", 80,60, 150,20,  (long)Fname,75,0,0, CLR_DEF); 

    YBeginGroup ("Velocity", 15,100, 160,50, YColor(""));
    YWnd (&hv,   FLOATS, "V = ", 40,15, 50,20, LP(v),YSPACE,0,0, CLR_DEF);
    YEndGroup ();
    break;
  case YCLOSE:
    YWndClean (id);
    break;
  default: ;;;
  }

  RETURN_TRUE;
}
/*******************************************************************************/

#endif
/****************************************************************************/
