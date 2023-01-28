// -*-  mode: c    ; coding: koi8   -*- ----------------------------------------

/****************************************************************************
 *                                                                          *
 *   MYFLTK.HH                                                              *
 *                                                                          *
 ****************************************************************************
 */   
                                                                            
#include <FL/Fl.H>
#include <FL/Fl_Window.H>
#include <FL/Fl_Menu_Bar.H>
#include <FL/fl_draw.H>
#include <FL/Fl_Box.H>                                                        
#include <FL/Fl_Input.H>                                                      
#include <FL/Fl_Menu_Button.H>
#include <FL/Fl_Button.H>                                                     
#include <FL/Fl_Toggle_Button.H>
#include <FL/Fl_Return_Button.H>                                              
#include <FL/Fl_Slider.H>
#include <FL/Fl_Value_Slider.H>                                                       
#include <FL/Fl_Scrollbar.H>                                                    
#include <FL/Fl_Clock.H>                                                        
#include <FL/Fl_File_Chooser.H>                                                 
#include <FL/Fl_Hold_Browser.H>
#include <FL/Fl_Tabs.H>
#include <FL/fl_message.H> 
                                                             
#include <FL/Fl_Overlay_Window.H>
#include <FL/Fl_Help_Dialog.H>
#include <FL/Fl_Text_Display.H>


/*--------------------------------------------------------------------*/

#define YT_COLOR Fl_Color
#define FALSE 0
#define TRUE  1

#define  CALCXY(x,y)      { x=x+X0_DRAW;  y=y+Y0_DRAW; }
#define  ANTICALCXY(x,y)  { x=x-X0_DRAW;  y=y-Y0_DRAW; }

/*--------------------------------------------------------------------*/
void  PROC_NULL (Fl_Widget *, void *); 

int   YMessageBox (char* message, char*, char*); 
void  YDrawLine (int x1, int y1, int x2, int y2, Fl_Color color);    
void  YDrawRectF (int x, int y, int w, int h, Fl_Color color);    
void  YDrawRectB (int x, int y, int w, int h, Fl_Color color);   
void  YDrawRectFB (int x, int y, int width, int height, Fl_Color fcolor, Fl_Color lcolor);   
void  YHelp (char* help_index);
Fl_Widget *YTopmenu (int x, int y, int w, int h, Fl_Menu_Item *items, Fl_Callback cb);

void  YBeginGroup (char *name, int x, int y, int w, int h, YT_COLOR fcolor, YT_COLOR lcolor/* , int drawing */); 
void  YEndGroup (); 

void  YPush (Fl_Button **, char *name, char *ttip, int x, int y, int w, int h, Fl_Callback proc, 
                  Fl_Color color);
void  YReturnPush (Fl_Return_Button **wpush, char *name, int x, int y, int w, int h);
Fl_Widget *YCheck (char *name, int x, int y, int w, int h);

typedef  void (*YT_PFUNC) (void);                             

typedef struct {
  char     *text;
  YT_PFUNC  proc;
  Fl_Color color; 
  /* Fl_Callback proc; */
} YT_BOOK; 

Fl_Widget *YBook (int x, int y, int w, int h, YT_BOOK *pages);
Fl_Widget *YEdit (char *name, int x, int y, int w, int h, char *text);

#define FL_HELVETICA_KOI8      FL_FREE_FONT
#define FL_HELVETICA_BOLD_KOI8 (FL_FREE_FONT+1)
//enum int {FL_HELVETICA_KOI8 = FL_FREE_FONT};
//#define FL_HELVETICA_BOLD_KOI8 (FL_FREE_FONT+1)

void  YStart ();
void YText (Fl_Box **, char *name, int x, int y, int w, int h, Fl_Color color, int face, int size);

extern int DRAWING;

extern Fl_Color background2;
extern Fl_Color background;
extern Fl_Color foreground; 

void YDrawString (char *string, int x, int y, Fl_Color color); 
void YDrawText (char *string, int x, int y, int w, int h, Fl_Color color); 

#define YLEFT  1
#define YNONE  2
#define YRIGHT 3
#define YUP    4
#define YDOWN  5

void YDrawStringImp (char *text, int x0, int y0, YT_COLOR color, int horz, int vert); 
void YDrawRectText (char *text, int x, int y, int w, int h, int horz, int vert, YT_COLOR color); 
void YDrawStrings (char **text, int x, int *y, int dy, Fl_Color color); 

enum keys { 
//enum int { 
  YLEVEL0_BEGIN = 0, 


  LEFTDOWN, LEFTUP, RIGHTDOWN, RIGHTUP,
  YMETA,  YREAL, YPOST, YNEW,  

/*   YLEVEL0_BEGIN = YKEY_LEVEL0,  */
/*   YCREATE, YOPEN, YCLOSE, YDESTROY, YFINAL,  */
/*   YCOLORED, YGRAYED, YINVERSE,  */
/*   YGETDATA, YSETFOCUS, YKILLFOCUS,  */
/*   YDRAW,  YDRAWITEM, YREDRAW, YGETSIZE, YUPDATE,                    */
/*   YGET, YGETITEM, YMREGIONOUT, YZOOMME,  */
/*   YKEYWORD0, YKEYWORD1, YKEYWORD2, YKEYWORD3, YKEYWORD4,  */
/*   YTIMER, PROCESS_BEGIN, PROCESS_STEP, PROCESS_END, */
/*   YLMOUSEDOWN, YLMOUSEUP, YLMOUSEDRAG,  */
/*   YRMOUSEDOWN, YRMOUSEUP, YRMOUSEDRAG,  */
/*   YLMOUSEDOUBLE, YLRMOUSEDRAG, */
/*   YKEYBOARD,   */
  YLEVEL0_END 
};

/*--------------------------------------------------------------------*/
