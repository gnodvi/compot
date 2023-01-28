// -*-  mode: c    ; coding: koi8   -*- ----------------------------------------

/****************************************************************************
 *                                                                          *
 *  Имя этого файла: myfltk.c                                               *
 *                                                                          *
 ****************************************************************************
 */  
    
#include  <stdio.h>
#include  <stdlib.h>  
#include  <string.h>
#include  <math.h>
//#include  <time.h>  
#include  <unistd.h> 
#include  <ctype.h>  
//#include  <dirent.h> 
//#include  <sys/time.h> 
//#include  <sys/param.h>
                                                                             
/*--------------------------------------------------------------------*/

#include "common.h"
#include "myfltk.h"
//#include "myhelp.h"

int X0_DRAW;
int Y0_DRAW;
int DRAWING;

Fl_Color background2 = FL_BACKGROUND2_COLOR; /* FL_WHITE */
Fl_Color background  = FL_BACKGROUND_COLOR;  /* FL_GRAY  */
Fl_Color foreground  = FL_FOREGROUND_COLOR;  /* FL_BLACK */


/*--------------------------------------------------------------------*/
int  
YMessageBox (char* message, char *mess_ok, char *mess_title) 
{  
  int w=230, h=150;
  int w_push = 80;
                                             
  if (!mess_ok)    mess_ok    = "Ok";
  if (!mess_title) mess_title = "Message";

  Fl_Window window (w,h);                                                   

  Fl_Box box (FL_BORDER_BOX, 30,20, w-60, h-10-60, message);  
  box.color(background2);

  Fl_Button ok (w/2-w_push/2, h-40, w_push, 25, mess_ok);                                 
  ok.color (background);

  window.color (background);
  window.label (mess_title);                                                              

  window.hotspot(&ok); // you must position modal windows                 
  window.end();                                                               
  window.set_modal();                                                         
  window.show();                                                              

  for (;;) {                                                                  
    Fl::wait();                                                               
    Fl_Widget *o;                                                             
    while ((o = Fl::readqueue())) {                                           
      if (o == &ok)                                                          
        return 1;                                                             
    }                                                                         
  }                                                                           
}                                                                             
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
/*------------------------------YDrawRectB----------------------------------*/   
void   
YDrawRectB (int x, int y, int w, int h, Fl_Color color)   
{ 
  if (!DRAWING) return;
  CALCXY (x, y); 

  fl_color (color);
  fl_rect (x, y, w, h);
  return;
}   
/*------------------------------YDrawRectFB---------------------------------*/   
void   
YDrawRectFB (int x, int y, int width, int height, Fl_Color fcolor, Fl_Color lcolor)   
{   
  YDrawRectF (x, y, width, height, fcolor);   
  YDrawRectB (x, y, width, height, lcolor);   
  return;   
}   
/*-----------------------------YDrawStrings--------------------------------*/ 
void 
YDrawStrings (char **text, int x, int *py, int dy, Fl_Color color) 
{ 
  if (!DRAWING) return;
  int y = *py;
  CALCXY (x, y); 

  fl_color (color); 

  for (int i=0; text[i]!=NULL; i++) {
    if (strlen (text[i]) == 0) y += 10;
    else                       y += dy;
    fl_draw (text[i], x, y);
  }

  *py = y;
  return;
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
/*-----------------------------YDrawText--------------------------------*/ 
void 
YDrawText (char *string, int x, int y, int w, int h, Fl_Color color) 
{ 
  if (!DRAWING) return;
  CALCXY (x, y); 
  //YSetFont(Y_FONT); /*??*/ 

  fl_color (color); 
  fl_draw (string, x, y, w, h, FL_ALIGN_CENTER, NULL, 0);

  return;
} 
/*-----------------------------YDrawStringImp------------------------------*/ 
void 
YDrawStringImp (char *text, int x0, int y0, YT_COLOR color, int horz, int vert) 
{ 
  int     x=0, y=0, w, h; 
 
  w = /* YStringW (text) */(int) fl_width (text); 
  h = /* YStringH (text) */(int) fl_height (); 
  //ANTICALCWH (w, h); 
 
  if      (horz == YLEFT)  x = x0 - w; 
  else if (horz == YNONE)  x = x0 - w / 2; 
  else if (horz == YRIGHT) x = x0; 
  else 
    printf ("YDrawStringImp-1"); 
 
  if      (vert == YUP)    y = y0 - h / 2; 
  else if (vert == YNONE)  y = y0; 
  else if (vert == YDOWN)  y = y0 + h / 2; 
  else 
    printf  ("YDrawStringImp-2"); 
 
  YDrawString (text, x, y, color); 
} 
/*-----------------------------YDrawRectText--------------------------------*/ 
void 
YDrawRectText (char *text, int x, int y, int w, int h,  
               int horz, int vert, YT_COLOR color) 
{ 
 
  //YDrawRectB (x, y, w, h, FL_BLACK); 

  switch (horz) {
  case YLEFT:
    x = x; horz = YRIGHT;
    break;
  case YRIGHT:
    break;
  case YNONE:
    x = x + w/2; 
    break;
  default: ;;
  }

  switch (vert) {
  case YLEFT:
    break;
  case YRIGHT:
    break;
  case YNONE:
    y = y + h/2; 
    break;
  default: ;;
  }

  YDrawStringImp (text, x, y, color, horz, vert); 
  return; 
 
} 
/*----------------------------------------------------------------------------*/
void
YHelp (char *help_index)
{
//#define HELP_FLTK

#ifdef _UNIX
  Fl_Help_Dialog  *help; 
  //Fl_Help_View    *view;
  help = new Fl_Help_Dialog;

  //view = help->view_;
  help->load(help_index);
  //view->textfont (FL_HELVETICA_BOLD_KOI8);
  help->show();

  Fl::run();
  delete help;
#else

  //system ("notepad RULES.txt");
#endif

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
/*----------------------------------YTopmenu------------------------------*/ 
Fl_Widget *
YTopmenu (int x, int y, int w, int h, Fl_Menu_Item *items, Fl_Callback cb)
{
  CALCXY(x,y);

  static Fl_Menu_Bar *OB;
  
  OB = new Fl_Menu_Bar (x, y, w, h);                       
  OB->callback(cb, NULL);

  OB->selection_color(FL_WHITE);
#ifdef _UNIX
  OB->textfont(FL_HELVETICA_KOI8);
  OB->labelsize(14); 
#endif
  
  OB->menu (items);  

  OB->redraw();
  return (OB);
}
/*-------------------------------YDrawGroup---------------------------------*/ 
void 
YDrawGroup (char *sText, int x, int y, int w, int h, YT_COLOR fcolor, YT_COLOR lcolor/* , int drawing  */) 
{ 
  //static Fl_Box *box;
 
  /* if (drawing) */ YDrawRectFB (x, y, w, h, fcolor, lcolor); //!!!!!!!

  //box = new Fl_Box (FL_FLAT_BOX, x, y, w, h, "");  
  //box->color (fcolor);
  //box->selection_color (FL_WHITE);
  //box->labelcolor (/* lcolor */FL_WHITE);

  return; 
} 
/*------------------------------YSetOrigin----------------------------------*/ 
void 
YSetOrigin (int x0, int y0) 
{ 
  X0_DRAW = x0; 
  Y0_DRAW = y0; 
  return; 
}  
/*------------------------------YGetOrigin----------------------------------*/ 
void 
YGetOrigin (int *x0, int *y0) 
{ 
  *x0 = X0_DRAW; 
  *y0 = Y0_DRAW; 
  return; 
} 
/*-----------------------------YGroup----------------------------------*/ 
void 
YGroup (int numer, char *name, int x, int y, int w, int h, YT_COLOR fcolor, YT_COLOR lcolor/* ,int drawing */) 
{ 
  static int x0group[100], y0group[100];
  static int cur=0;
       
  if (numer == 1) {
    if (name != NULL)  
      YDrawGroup (name, x, y, w, h, fcolor, lcolor/* , drawing */); 
     
    YGetOrigin (&(x0group[cur]), &(y0group[cur])); 
    YSetOrigin (x0group[cur] + x, y0group[cur] + y);
    cur++;
    
  } else {
    cur--;
    YSetOrigin (x0group[cur], y0group[cur]); 
  }

  return;
} 
/*-----------------------------YBeginGroup----------------------------------*/ 
void 
YBeginGroup (char *name, int x, int y, int w, int h, YT_COLOR fcolor, YT_COLOR lcolor/* , int drawing */) 
{ 
       
  YGroup (1, name, x, y, w, h, fcolor, lcolor/* , drawing */); 
  
} 
/*-------------------------------YEndGroup----------------------------------*/ 
void 
YEndGroup () 
{ 
 
  YGroup (2, NULL, 0, 0, 0, 0, FL_RED, FL_RED/* , FALSE */); 
 
} 
/*-------------------------------PROC_NULL------------------------------------*/
void 
PROC_NULL (Fl_Widget *wid, void *ptr) 
{  

  return;
}  
/*----------------------------------YPush------------------------------*/ 
void
YPush (Fl_Button **wpush, char *name, char *ttip, int x, int y, int w, int h, Fl_Callback proc,  
       Fl_Color color)
{
  if (DRAWING) return;
  //printf ("y (push1) = %d \n", y);
  CALCXY (x,y);
  //printf ("y (push2) = %d \n", y);
  
  Fl_Button *OB;
  
  OB = new Fl_Button (x, y, w, h, name);                       
  OB->callback (proc, NULL);
  OB->labelcolor (FL_FOREGROUND_COLOR);
  //OB->color (color);
  //OB->down_color (FL_WHITE);
  OB->tooltip (ttip);
  OB->clear_visible_focus();

  *wpush = OB;
  return;
}
/*----------------------------------YReturnPush------------------------------*/ 
void
YReturnPush (Fl_Return_Button **wpush, char *name, int x, int y, int w, int h)
{
  if (DRAWING) return;
  CALCXY(x,y);
  
  Fl_Return_Button *OB;
  
  OB = new Fl_Return_Button (x, y, w, h, name);                       
  //OB->callback (proc, NULL);
  //OB->labelcolor (FL_FOREGROUND_COLOR);
  //OB->tooltip (ttip);
  //OB->clear_visible_focus();

  *wpush = OB;
  return;
}
/*----------------------------------YText------------------------------*/ 
void
YText (Fl_Box **wbox, char *name, int x, int y, int w, int h, Fl_Color color, 
       int face, int size)
{
  if (DRAWING) return;
  CALCXY(x,y);

  Fl_Box *OB; 
  OB = new Fl_Box (/* FL_BORDER_BOX, */ x, y, w, h, name);                       
   
  OB->color (color); 
  OB->labelcolor (FL_FOREGROUND_COLOR);

  //#ifdef _UNIX
  //OB->labelfont (FL_HELVETICA_KOI8);
  OB->labelfont (/* FL_BOLD */face);
  //OB->labelsize(14); 
  OB->labelsize (size); 
  //#endif
  OB->align(FL_ALIGN_INSIDE | FL_ALIGN_LEFT); 
  //OB->align(FL_ALIGN_INSIDE | FL_ALIGN_CENTER); 
  
  *wbox = OB;
  return ;
}
/*--------------------------------------------------------------------*/
