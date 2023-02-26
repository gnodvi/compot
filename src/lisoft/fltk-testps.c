// -*-  mode: c    ; coding: koi8   -*- ----------------------------------------

/****************************************************************************
 *                                                                          *
 *  Имя этого файла: svisor.c                                               *
 *                                                                          *
 ****************************************************************************
 */  
    
                                                                        
#include  <stdio.h>
#include  <stdlib.h>  
#include  <string.h>
#include  <math.h>
#include  <time.h>  
#include  <unistd.h> 
#include  <ctype.h>  
//#include  <dirent.h> 
#include  <sys/time.h> 
#include  <sys/param.h>
                                                                               

/****************************************************************************/

#include "fltk-common.h"
//#include "client.h"


/****************************************************************************/
//#include "myfltk.h"  

#define YT_COLOR Fl_Color
#define FALSE 0
#define TRUE  1

#define  CALCXY(x,y)      { x=x+X0_DRAW;  y=y+Y0_DRAW; }
#define  ANTICALCXY(x,y)  { x=x-X0_DRAW;  y=y-Y0_DRAW; }

#define FL_HELVETICA_KOI8      FL_FREE_FONT
#define FL_HELVETICA_BOLD_KOI8 (FL_FREE_FONT+1)

enum keyss { 
  YLEVEL0_BEGIN = 0, 

  LEFTDOWN, LEFTUP, RIGHTDOWN, RIGHTUP,
  YMETA,  YREAL, YPOST, YNEW,  

  YLEVEL0_END 
};

/****************************************************************************/

#include <FL/Fl.H>
#include <FL/Fl_Double_Window.H>
#include <FL/Fl_Bitmap.H>
#include <FL/fl_draw.H>
#include <FL/Fl_Menu_Item.H>
#include <FL/fl_ask.H>


/****************************************************************************/
  int WW ;
  int HH;
  Fl_Window *main_window;

/****************************************************************************/
/****************************************************************************/
#define YT_BOOL int

typedef struct { 
  int     type; 
  void   *ptr; 
  int     i1, i2, i3, i4; 
  YT_COLOR color; 
  int     i5, i6; 
  char   *text; 
  char   *oname; 
  int     status; 
  YT_BOOL xorr; 
} YT_SCROBJ; 
 
typedef struct { 
  YT_SCROBJ **ptr; 
  int     size; 
  int     x, y, w, h; 
  char   *save_fname; 
  int     save_xx, save_yy; 
  int     xold, yold, wold, hold; 
  int     old_x0, old_y0; 
  float   old_x_mult, old_y_mult; 
} YT_META;  
 
#define  PNAMES_MAX   100 
#define  NUM_VNAMES   100  
typedef struct { 
  //YT_NEXTPROC  nproces[NEXTPROC_NUM]; 
  //YT_SETI   *seti; 
  int        x0group, y0group; 
  int        draw_mode; 
  //YT_VNAME  *vnames[NUM_VNAMES]; 
  //AT_PNAME2  pnames[PNAMES_MAX]; 
  FILE      *post_file; 
  char       draw_oname[30]; 
  int        transf_ymin, transf_ymax; 
  int        hand_savemode; 
  //YT_CMAP   *hand_cmap; 
  YT_META   *meta; 
  int        meta_savemode; 
  YT_BOOL    meta_xor; 
  //int        WAIT_done, WAIT_doneold; 
  //int        WAIT_id; 
  //int        WAIT_i; 
  //int        WAIT_imax; 
  //YT_CONTEXT WAIT_save; 
} YT_MORE_S; 
 
YT_MORE_S impr_s; 
#define  IS (&impr_s)   
 
//YT_MORE *impr; 
 
#define DRAW_MODE (IS->draw_mode) 
#define POST_FILE (IS->post_file) 
 


/****************************************************************************/
/****************************************************************************/

int X0_DRAW;
int Y0_DRAW;
int DRAWING;

/*-----------------------------YDrawLine-----------------------------------*/    
void    
YDrawLine (int x1, int y1, int x2, int y2, Fl_Color color)    
{ 
  if (!DRAWING) return;
  //printf ("YDrawLine %d \n", color);

  fl_color (color);
  fl_line (x1, y1, x2, y2);
}   
/*-------------------------------YDrawRectF--------------------------------*/    
void    
YDrawRectF (int x, int y, int w, int h, Fl_Color color)    
{    
  if (!DRAWING) return;
  CALCXY (x, y); 

  fl_color (color);
  fl_rectf (x, y, w, h);
}    
/*-----------------------------YDrawString--------------------------------*/ 
void 
YDrawString (char *string, int x, int y, Fl_Color color) 
{ 
  if (!DRAWING) return;
  CALCXY (x, y); 
  //YSetFont(Y_FONT);
  y += (fl_height()/2 - fl_descent()) ; 

  fl_color (color); 
  fl_draw (string, x, y); /*??*/

  return;
} 
/*----------------------------------------------------------------------------*/
void
YStart ()
{

  Fl::set_font (FL_HELVETICA_KOI8,      "-*-helvetica-medium-r-*-*-*-*-*-*-*-*-koi8-*");
  Fl::set_font ((Fl_Font)(FL_HELVETICA_BOLD_KOI8), "Courier New:Bold:9::Cyrillic"); // ?????

  fl_font (FL_HELVETICA_KOI8, 10);

  DRAWING = FALSE;
}
/****************************************************************************/
/*----------------------------------------------------------------------------*/
void
YError (const char *msg)      
{

  fprintf (stderr, "Error: %s\n", msg);

  exit (0);
}
/*-------------------------------YStrCmp------------------------------------*/ 
YT_BOOL 
YStrCmp (char *str1, char *str2) 
{ 
  if (!str1 || !str2) return (FALSE);   
   
  return (!(strcmp(str1, str2))); 
/*   if (strcmp (str1, str2) == 0) */ 
/*     return (TRUE); */ 
/*   else */ 
/*     return (FALSE); */ 
} 
/*-------------------------------YMetaAdd-----------------------------------*/ 
void 
YMetaAdd (int type, void *ptr, int i1, int i2, int i3, int i4, 
	  YT_COLOR color, int i5, int i6, char *text) 
{ 
  YT_SCROBJ *o; 
  YT_META *meta = IS->meta; 
  int     i; 
  char   *name = IS->draw_oname; 
 
  for (i = 0; i < meta->size; i++) 
    if (((meta->ptr)[i]) == NULL) 
      break; 
  if (i == meta->size)  YError ("META_SIZE"); 
 
  o = (YT_SCROBJ *) malloc (sizeof (YT_SCROBJ)); 
 
  if (!o) 
    YError ("malloc YT_SCROBJ"); 
  o->type = type; 
  o->ptr = ptr; 
  o->i1 = i1; 
  o->i2 = i2; 
  o->i3 = i3; 
  o->i4 = i4; 
  o->color = color; 
  o->i5 = i5; 
  o->i6 = i6; 
  o->status = YNEW; 
  o->xorr = IS->meta_xor; 
 
  if (text != NULL) { 
    o->text = (char *) malloc (strlen (text) + 1); 
    strcpy (o->text, text); 
  } else 
    o->text = NULL; 
 
  if (!YStrCmp (name, "")) { 
    o->oname = (char *) malloc (strlen (name) + 1); 
    strcpy (o->oname, name); 
  } else 
    o->oname = NULL; 
 
  IS->meta->ptr[i] = o; 
 
  return; 
} 
/*----------------------------YColorToRGB-----------------------------------*/ 
void 
YColorToRGB (YT_COLOR color, int *red, int *green, int *blue) 
{ 
  int r=0, g=0, b=0;

  switch (color) {
  case FL_RED: 
    r=255; g=0;   b=0;
    break;
  case FL_GREEN: 
    r=0;   g=255; b=0;
    break;
  case FL_BLUE: 
    r=0;
    g=0;
    b=255;
    break;
  case FL_WHITE: 
    r=255;
    g=255;
    b=255;
    break;
  case FL_BLACK: 
    r=0;
    g=0;
    b=0;
    break;
  default: YERROR ("YColorToRGB");
  };

  *red   = r;
  *green = g;
  *blue =  b;
 
} 
/*----------------------------PS_Setcolor-----------------------------------*/ 
void 
PS_Setcolor (YT_COLOR color) 
{ 
  int     r, g, b; 
  float   red, green, blue; 
 
  YColorToRGB (color, &r, &g, &b);
 
  red = (float) r / 255; 
  green = (float) g / 255; 
  blue = (float) b / 255; 
  fprintf (POST_FILE, "%f %f %f setcolor \n", red, green, blue); 
 
} 
/*-----------------------------PS_Stroke------------------------------------*/ 
void 
PS_Stroke () 
{ 
 
  fprintf (POST_FILE, "%s \n", "stroke"); 
 
} 
/*------------------------------YTransf-------------------------------------*/ 
void 
YTransf (int *px, int *py) 
{ 
  int  x = *px; 
  int  y = *py; 
 
  *px = x; 
  y = IS->transf_ymax - (y - IS->transf_ymin); 
  *py = y; 
 
} 
/*-----------------------------PS_Begin-------------------------------------*/ 
void 
PS_Begin (char *fname, char *fontname) 
{ 
  int llx=0, lly=0, urx=200, ury=200;

  /* char *fontname="Times-Italic"; */ 
  if ((POST_FILE = fopen (fname, "wb")) == NULL) 
    YError ("fopen--SVISOR.PS"); 
 
  fprintf (POST_FILE, "%%!PS-Adobe-2.0 EPSF-2.0\n"); 
  // %%BoundingBox: 0 0 230 300
  fprintf (POST_FILE, "%%%%BoundingBox: %d %d %d %d\n", llx, lly, urx, ury); 

  fprintf (POST_FILE, "%%%%Title: %s\n", "pstest.ps"); 
  fprintf (POST_FILE, "%%%%Creator: \n"); 
  fprintf (POST_FILE, "%%%%Pages: 1\n"); 
  fprintf (POST_FILE, "%%%%DocumentFonts:\n"); 
  fprintf (POST_FILE, "%%%%EndComments\n"); 
  fprintf (POST_FILE, "%%%%EndProlog\n\n"); 
  fprintf (POST_FILE, "%%%%Page: 1 1\n\n"); 
 
  fprintf (POST_FILE, "%% remember original state\n"); 
  fprintf (POST_FILE, "/origstate save def\n\n"); 
  fprintf (POST_FILE, "%% build a temporary dictionary\n"); 
  fprintf (POST_FILE, "20 dict begin\n\n"); 
 
  fprintf (POST_FILE, "/%s findfont \n", fontname); 
  fprintf (POST_FILE, "15 scalefont \n"); 
  fprintf (POST_FILE, "setfont \n"); 
 
  fprintf (POST_FILE, "/DeviceRGB \n"); 
  fprintf (POST_FILE, "setcolorspace \n"); 
 
} 
/*-----------------------------PS_Showpage----------------------------------*/ 
void 
PS_Showpage () 
{ 
 
  fprintf (POST_FILE, "%s \n", "showpage"); 
 
} 
/*------------------------------PS_End--------------------------------------*/ 
void 
PS_End () 
{ 
 
  fprintf (POST_FILE, "\n"); 
  PS_Stroke (); 
 
  PS_Showpage (); 
  fprintf (POST_FILE, "end\n"); 
  fprintf (POST_FILE, "origstate restore\n"); 
 
} 
/*-----------------------------ZDrawLine------------------------------------*/ 
void 
ZDrawLine (int x1, int y1, int x2, int y2, YT_COLOR color) 
{ 
  switch (DRAW_MODE) { 
  case YMETA: 
    //YMetaAdd (YLINE, NULL, x1, y1, x2, y2, color, 0, 0, NULL); 
    break; 
  case YREAL:  
    YDrawLine (x1, y1, x2, y2, color); 
    break; 
  case YPOST: 
    YTransf (&x1, &y1); 
    YTransf (&x2, &y2); 
    PS_Setcolor (color); 
    fprintf (POST_FILE, "%d %d %s \n", x1, y1, "moveto"); 
    fprintf (POST_FILE, "%d %d %s \n", x2, y2, "lineto"); 
    PS_Stroke (); 
    break; 
  } 
 
  return; 
} 
/*------------------------------ZDrawString--------------------------------*/ 
void 
ZDrawString (char *text, int x, int y, YT_COLOR color) 
{ 
  switch (DRAW_MODE) { 
  case YMETA: 
    //YMetaAdd (YSTRING, NULL, x, y, 0, 0, color, 0, 0, text); 
    break; 
  case YREAL: 
    YDrawString (text, x, y, color); 
    break; 
  case YPOST: 
    y += 4; 
    YTransf (&x, &y); 
    PS_Setcolor (color); 
    fprintf (POST_FILE, "%d %d %s \n", x, y, "moveto"); 
    fprintf (POST_FILE, "( %s ) show \n", text); 
    PS_Stroke (); 
    break; 
  default: ;; 
  } 
 
} 
/*------------------------------ZDrawRectF----------------------------------*/ 
void 
ZDrawRectF (int x, int y, int w, int h, YT_COLOR f_color) 
{ 
  switch (DRAW_MODE) { 
  case YMETA: 
    //YMetaAdd (YRECTF, NULL, x, y, w, h, f_color, 0, 0, NULL); 
    break; 
  case YREAL: 
    YDrawRectF (x, y, w, h, f_color); 
    break; 
  case YPOST: 
    { 
      int     x1 = x, y1 = y; 
      int     x2 = x + w, y2 = y; 
      int     x3 = x + w, y3 = y + h; 
      int     x4 = x, y4 = y + h; 
      YTransf (&x1, &y1); 
      YTransf (&x2, &y2); 
      YTransf (&x3, &y3); 
      YTransf (&x4, &y4); 
      fprintf (POST_FILE, "newpath \n"); 
      PS_Setcolor (f_color); 
      fprintf (POST_FILE, "%d %d %s \n", x1, y1, "moveto"); 
      fprintf (POST_FILE, "%d %d %s \n", x2, y2, "lineto"); 
      fprintf (POST_FILE, "%d %d %s \n", x3, y3, "lineto"); 
      fprintf (POST_FILE, "%d %d %s \n", x4, y4, "lineto"); 
      fprintf (POST_FILE, "%d %d %s \n", x1, y1, "lineto"); 
      fprintf (POST_FILE, "closepath fill \n"); 
      PS_Stroke (); 
    } 
    break; 
  } 
 
  return; 
} 
/*------------------------------ZDrawRectB----------------------------------*/ 
void 
ZDrawRectB (int x, int y, int w, int h, YT_COLOR color) 
{ 
  w--; 
  h--; 
  ZDrawLine (x, y, x + w, y, color); 
  ZDrawLine (x, y + h, x + w, y + h, color); 
  ZDrawLine (x, y + h, x, y, color); 
  ZDrawLine (x + w, y, x + w, y + h, color); 
} 
/*------------------------------ZDrawRectFB---------------------------------*/ 
void 
ZDrawRectFB (int x, int y, int width, int height, YT_COLOR fcolor, YT_COLOR lcolor) 
{ 
  ZDrawRectF (x, y, width, height, fcolor); 
  ZDrawRectB (x, y, width, height, lcolor); 
  return; 
} 
/*******************************************************************************/
/*******************************************************************************/



/*******************************************************************************/
//class My_Window : public Fl_Double_Window {
//class My_Window : public Fl_Overlay_Window {
class My_Window : public Fl_Window {

public:
  My_Window (int x,int y,int w,int h) : Fl_Window (x,y,w,h) {;;}
  My_Window (int w,int h,char*title) : Fl_Window (w,h,title) {;;}
  My_Window (int x,int y,int w,int h,char*title) : Fl_Window (x,y,w,h,title) {;;}

  //My_Window (int x,int y,int w,int h) : Fl_Double_Window (x,y,w,h) {;;}

/*----------------------------------------------------------------------------*/
virtual void 
OPEN_DRAW () {


}
/*----------------------------------------------------------------------------*/
void 
draw () 
{
  DRAWING = TRUE;
  OPEN_DRAW ();

  Fl_Widget *const*a = array();

  if (damage() == FL_DAMAGE_CHILD) { // only redraw some children
    for (int i = children(); i --; a ++) update_child(**a);
  } else 

  { // total redraw
    /* ... draw background graphics ... */
    //YRedrawAll();

    // now draw all the children atop the background:
    for (int i = children(); i --; a ++) {
      draw_child(**a);
      draw_outside_label(**a); // you may not want to do this
    }
  }

  return;
}
/*----------------------------------------------------------------------------*/
int 
YMOUSE (int message, int x, int y) {

  switch (message) {
  case LEFTDOWN:
    printf ("LEFTDOWN \n");
    break;
  case RIGHTDOWN:
    printf ("RIGHTDOWN \n");
    break;
  case LEFTUP:
    printf ("LEFTUP \n");
    break;
  case RIGHTUP:
    printf ("RIGHTUP \n");
   break;
  default: 
    return (0);
  }

  return (0);
}
};
/*******************************************************************************/

/******************************************************************************/
class MAIN_TESTPS : public My_Window { 

public:

/*----------------------------------------------------------------------------*/
MAIN_TESTPS (int X, int Y, int W, int H) : My_Window (X, Y, W, H) 
{ 

  //------------------------
  DRAW_MODE = YREAL; 

  DRAWING = FALSE;
  OPEN_DRAW ();
}
/*----------------------------------------------------------------------------*/
void  
OPEN_DRAW () {


  for (int i=0; i<2; i++) {
    if (i==0) DRAW_MODE = YREAL; 
    else      DRAW_MODE = YPOST; 

    PS_Begin ("boxdlg.eps", "Times-Roman"); 
    IS->transf_ymin = 0; 
    IS->transf_ymax = h(); 

    ZDrawRectFB (0,0, w(),h(), FL_GREEN, FL_BLACK); 

    ZDrawLine (50,50, 150, 150, FL_RED); 
    ZDrawString ("Test BLOKNOT", 50, 150, FL_BLUE); 
   
    PS_End (); 
  }

  return;
}  
/*******************************************************************************/
};//                                                                           // 
/*******************************************************************************/




/*******************************************************************************/
//
/*******************************************************************************/
int 
main (int argc, char **argv) 
{  
  char *caption;

  YStart ();
  WW = 230;  
  HH = 300;

  caption = "  NOTEBOX";

  Fl::visual(FL_DOUBLE|FL_INDEX);
  main_window = new  Fl_Window (WW, HH, caption);

  Fl_Window *win = new MAIN_TESTPS (0,0, WW,HH);

  main_window->add (win);  
                                                             
  main_window->end ();                                                               
  main_window->show (argc, argv);                                                        

  return Fl::run();                                                             

} 
/*******************************************************************************/
//
/*******************************************************************************/


