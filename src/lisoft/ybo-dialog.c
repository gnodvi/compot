// -*-  mode: c    ; coding: koi8   -*- ----------------------------------------

#ifdef DIALOG

/****************************************************************************    
 *                                                                          *    
 *  dialog.c  --  demo examples for "Library Yzone";                        *    
 *                                                                          *    
 *  Copyright (c) 2000, Life Software.                                      *    
 *                                                                          *    
 *  This library is free software; you can redistribute it and/or           *    
 *  modify it under the terms of the GNU Library General Public             *    
 *  License as published by the Free Software Foundation; either            *    
 *  version 2 of the License, or (at your option) any later version.        *    
 *                                                                          *    
 *  This library is distributed in the hope that it will be useful,         *    
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of          *    
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU       *    
 *  Library General Public License for more details.                        *    
 *                                                                          *    
 *  You should have received a copy of the GNU Library General Public       *    
 *  License along with this library; if not, write to the Free              *    
 *  Software Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.      *    
 *                                                                          *    
 *                Life Software:                                            *    
 *                Web:     http://www.chat.ru/~lifesoft                     *    
 *                E-mail:  lifesoft@chat.ru                                 *    
 *                                                                          *    
 ****************************************************************************    
 */                                                                              
                                                                                 
                                                                                 
                                                                                 
/****************************************************888*********************/      
                                                                                 
#include  <stdio.h> 
#include  <stdlib.h>   
#include  <string.h> 
#include  <math.h> 
#include  <time.h>   
#include  <ctype.h>
   
//#include  "kernel.h"

#ifdef _NEW
#include  "yma-kernel.h"
#else
#include  "ybo-kernel.h"
#endif
 
/*===========================================================================*/
                                                                                 
void   
draw_background ();

enum local_keys {
  DRAW_MESS = YKEY_LOCALS,
  MYPUSH_UP 
};

static int n, o;
                                                                                 
/*----------------------------draw_background-------------------------------*/   
void   
draw_background (int id)   
{   
  SC w = YWinW (id);   
  SC h = YWinH (id);  
 
  YDrawRectF (0, 0, w, h, YColorRGB(LIME));         
  YDrawRectFB (10, 10, w-20, h-20, YColorRGB(RED), YColorRGB(BLACK));   
    
  /*   YDrawLine (10, 10, 100, 100, YColorRGB(BLUE));  */
  /*   YDrawTriB (20,20, 20,100, 150,20, YColorRGB (255,0,255));    */
  /*   YDrawTriF (110,10, 200,10, 110,100, YColorRGB (YELLOW));     */
 
  /*   YDrawCircB (50,50, 20, YColorRGB(BLACK));     */
  /*   YDrawCircFB (50,150, 20, YColorRGB(BLUE), YColorRGB(BLACK));     */
   
  /*   YDrawRectF (0, 0, 20, 20, YColorRGB(GREEN));   */
  return; 
}  
/*-----------------------------draw_foreground------------------------------*/ 
void 
draw_foreground (int id) 
{ 
  int i;  
  SC x, y, w=20, h=20, width, height;  
 
  width  = YWinW (id); 
  height = YWinH (id); 
   
  printf ("draw_foreground: width = %3d, height = %3d \n", width, height);

  for (i=0; i<8; i++) {
    
    x = YRAND (w, width-2*w); 
    y = YRAND (h, height-2*h);
    
    YDrawRectF (x, y, w, h, YColorRGB(YELLOW)); // это маленькие желтые квадратики
    //printf ("draw_foreground: xywh = %3d, %3d, %3d, %3d \n", x, y, w, h);
  }

  return;
}  
/*-----------------------------push1_proc--------------------------------------*/   
long   
push1_proc (PFUNC_VAR)   
{   
  switch (message) {
    
  case YM_CREATE: 
  case YM_PAINT:  
		YDrawRectF (0, 0, YWinW(id), YWinH(id), YColorRGB(GRAY));           
    break;  
  case YLMOUSEUP:  
    YSend (YWinP(id), YPUSH, 0,0,0,0); 
    break;  
  default: ;;;;   
  }   
   
  RETURN_TRUE;   
}  
/*-----------------------------new_proc--------------------------------------*/   
long   
new_proc (PFUNC_VAR)   
{   
  static int id_push=ID_NULL; 
 
  switch (message) {   
  case YM_CREATE:  
  case YM_PAINT:   
		YDrawRectF (0, 0, YWinW(id), YWinH(id), YColorRGB(YELLOW));            
		/* YWin (&id_push, push_proc, "Push", 30, 30, 70, 25); */     
    break;   
  case YLMOUSEDOWN:  
    printf ("YLMOUSEDOWN-new \n");  
    break;  
  case YRMOUSEDOWN:  
    printf ("YRMOUSEDOWN-new \n");  
    break;  
  case YLMOUSEUP:  
    printf ("YLMOUSEUP-new \n"); 
    YSend (YWinP(id), YPUSH, 0,0,0,0); 
    break;  
  case YPUSH: 
    printf ("PUSH-COMMAND \n"); 
    break; 
  case YRMOUSEUP:  
  case YDESTROY:  
    YQuit ();  
    break;  
  default: ;;;;   
  }   
   
  RETURN_TRUE;   
}  
/*-----------------------------newmain_proc--------------------------------------*/  
long  
newmain_proc (PFUNC_VAR)  
{  
#define WIN_W  (YWinW(id)) 
#define WIN_H  (YWinH(id)) 
	int id_new=ID_NULL;
  
  switch (message) {
    
  case YM_CREATE:  
    printf ("YM_CREATE \n");  
  case YM_PAINT:  
    /*     printf ("YM_PAINT \n");   */
    /*     YDrawRectF (0, 0, WIN_W, WIN_H, YColorRGB(LIME));            */
    //draw_background (id);   
    //YWin (&id_new, new_proc, "Hello, New Window!!", 100, 0, 150, 150);    
    break;  
  case YLMOUSEDOWN:  
    printf ("YLMOUSEDOWN \n");  
    break;  
  case YRMOUSEDOWN: 
    printf ("YRMOUSEDOWN \n"); 
    break; 
  case YLMOUSEUP: 
    printf ("YLMOUSEUP: \n");
    //YBig (&id_new, new_proc, "Hello, New Window!!", SC_DEF, SC_DEF, 150, 150);   
    break; 
  case YPUSH: 
    printf ("PUSH-MAIN-COMMAND \n"); 
    break; 
  case YRMOUSEUP: 
  case YDESTROY: 
    YQuit (); 
    break; 
  default: ;;;;  
  }  
  
  RETURN_TRUE;  
} 
/*------------------------------page3_proc------------------------------*/
long
page3_proc (PFUNC_VAR)       
{        
  static int hTest = ID_NULL;

  switch (message) {       
  case YM_CREATE: 
    /* hTest = *((int*)Y_WLONG1); */
  case YM_PAINT:       
    YDrawRectFB (0,0,WIN_W,WIN_H, YColorRGB(BLUE), YColorRGB(BLACK));        
    break;        
    /*   case YCLOSE:        */
    /*     YWndClean (id);         */
    /*     break;   */
  default:;;
    /* YSend (hTest, message, mes1,mes2,mes3,mes4); */
  }       
  
  RETURN_TRUE;
}
/*--------------------------------push_proc----------------------------------*/
long
push_proc (PFUNC_VAR)
{
	int color = YColorRGB (GRAY);

  switch (message) {
  case YM_CREATE:
  case YM_PAINT:
    YDrawRectFB (0, 0, WIN_W, WIN_H, color, YColorRGB(BLACK));
    /*     YDrawRectText (WND->name, 0, 0, WND->w, WND->h, YColor("black")); */
    break;
  case YLMOUSEUP:
    /*     YPost (WND->parent, MYPUSH_UP, id, 0, 0, 0); */
    YSend (YWinP(id), MYPUSH_UP, id, 0, 0, 0);
    break;
    /*   case YCLOSE: */
    /*     YWndClean (id); */
    /*     break; */
  default: ;;;;
  }

  RETURN_TRUE;
}
/*--------------------------------test_picture---------------------------*/
void
test_picture ()
{

/*   YDrawRectF (40,20,  80,90, YColor("white")); */
/*   YDrawRectFB(60,80,  80,90, YColor("aqua"), YColor("black")); */
/*   YDrawLine  (10,10, 110,110,YColor("black")); */
/*   YDrawLine  (5,100, 160,10, YColor("white")); */
/*   YDrawRectFB(60,70,  70,40, YColor("silver"), YColor("white")); */
/*   YDrawRectF (110,40, 60,80, YColor("red")); */
/*   YDrawRectF (10,100, 90,50, YColor("fuchsia")); */
/*   YDrawString("This is test", 20,60, YColor("black"));   */
/*   YDrawLine  (25,25, 160,150, YColor("blue")); */
/*   YDrawLine  (25,25, 160,152, YColor("blue")); */
/*   YDrawLine  (25,25, 160,154, YColor("blue")); */
/*   YDrawLine  (25,25, 160,156, YColor("blue")); */
/*   YDrawCircB (50, 50,  35, YColor("black")); */

  return;
}
/*-----------------------------dial_proc-------------------------------------*/
long
dial_proc (PFUNC_VAR)
{

/*   switch (message) { */
/*   case YOPEN: */
/*   case YDRAW: */
/*     YDrawRectFB (0, 0, WND->w, WND->h, YColor("lime"), YColor("black")); */
/*     test_picture (); */
 
/*     YWnd (Ph(), push_proc, "O'Key",  90, 160, 80,30, 0,0,0,0, YColor("yellow")); */
/*     break; */
/*   case MYPUSH_UP: */
/* 		YBigDelete ();  */
/*     break; */
/*   case YLMOUSEDOWN: */
/* 		printf ("dial_proc_YLMOUSEDOWN: %d %d \n", mes1, mes2); */
/*     break; */
/*   case YCLOSE: */
/*     YWndClean (id); */
/*     break; */
/*   default: ;;;; */
/*   } */

  RETURN_TRUE;
}
/*------------------------------testmsg_proc----------------------------------*/
long                                                                            
testmsg_proc (PFUNC_VAR)                                                        
{                                                                               
/*   static char str[100];                                                          */
                                                                                
/*   switch (message) {                                                             */
/*   case YOPEN:                                                                    */
/*   case YDRAW:                                                                    */
/*     YDrawRectFB (0,0, WND->w,WND->h, YColor("white"), YColor("black"));          */
/*     YDrawRectText (str, 0,0, WND->w,WND->h, YColor("black"));                    */
/*     break;                                                                       */
/*   case YCLOSE:                                                                   */
/*     YWndClean (id);                                                              */
/*     break;                                                                       */
/*   default:                                                                       */
/*     switch (message) {                                                           */
/*     case YLMOUSEDOWN:  sprintf (str, "LMOUSEDOWN:   %d  %d", mes1, mes2);  break; */
/*     case YLMOUSEUP:    sprintf (str, "YLMOUSEUP:    %d  %d", mes1, mes2);  break; */
/*     case YLMOUSEDRAG:  sprintf (str, "YLMOUSEDRAG:  %d  %d", mes1, mes2);  break; */
/*     case YRMOUSEDOWN:  sprintf (str, "YRMOUSEDOWN:  %d  %d", mes1, mes2);  break; */
/*     case YRMOUSEUP:    sprintf (str, "YRMOUSEUP:    %d  %d", mes1, mes2);  break; */
/*     case YRMOUSEDRAG:  sprintf (str, "YRMOUSEDRAG:  %d  %d", mes1, mes2);  break; */
/*     }                                                                            */
/*     YGoto (YDRAW, 0,0,0,0);                                                      */
/*     break;                                                                       */
/*   }                                                                              */
                                                                                
  RETURN_TRUE;                                                                  
}                                                                               
/*--------------------------------page1_proc------------------------------*/
long
page1_proc (PFUNC_VAR)       
{
  
  /*   YT_COLOR clr_text; */
  /*   static int hTest = ID_NULL; */
  /*   static int hNewWin, hDialog; */

  /*   switch (message) {        */
  /*   case YOPEN:  */
  /*     hTest = *((int*)Y_WLONG1); */
  /*   case YDRAW:        */
  /*     YDrawRectFB (0,0,WND->w,WND->h, WIN->color, YColor("black"));         */

  /*     YBeginGroup ("ABOUT", 20,30, 210,110, YColor("teal")); */
  /*       clr_text = YColor("white"); */
  /*       YDrawString ("   'Library Yzone'    ", 20,20, clr_text);   */
  /*       YDrawString ("     version 0.2      ", 20,35, clr_text);   */
  /*       YDrawString (" Copyright (c) 2000   ", 20,60, clr_text);   */
  /*       YDrawString ("    Life Software.    ", 20,75, clr_text);   */
  /*       YDrawString ("  Under GNU License.  ", 20,90, clr_text);   */
  /*     YEndGroup (); */

  /*     YBeginGroup("YDraw..", 240,30, 185,190, YColor("green"));  */
  /*     test_picture (); */
  /*     YEndGroup (); */

  /*     YWnd (&hNewWin, push_proc, "NewWin",  200,240, 70,50, 0,0,0,0, CLR_DEF); */
  /*     YWnd (&hDialog, push_proc, "Dialog",  290,240, 70,50, 0,0,0,0, CLR_DEF); */

  /*     break;         */
  /*   case MYPUSH_DOWN:   */
  /*     if (mes1 == hNewWin) { */
  /* 			YBigWindow (NULL, dial_proc, "Big Window", 0,0,240,220, 0,0,0,0, CLR_DEF); */
  /*     } else  */
  /*     if (mes1 == hDialog) { */
  /*       YDlg (dial_proc, "Dialog", 0,0,260,250, 0,0,0,0, CLR_DEF, TRUE);  */
  /*     } */
  /*     break;   */
  /*   case YRMOUSEUP: */
  /*     YBeep (); */
  /*     break; */
  /*   case YCLOSE:        */
  /*     YWndClean (id);         */
  /*     break;   */
  /*   default: */
  /*     YSend (hTest, message, mes1,mes2,mes3,mes4); */
  /*   }        */
  
  RETURN_TRUE;
}
/*------------------------------oldmain_proc--------------------------------*/
long
oldmain_proc (PFUNC_VAR)       
{        
  static int hExit, hCurPage=ID_NULL, hPage1, hPage2, hPage3, hPage4, hTest = ID_NULL;
  static YT_COLOR col1, col2, col3, col4;
	int w /*440*/ , w_push=55, h_mes = 45;


  switch (message) {       
  case YM_CREATE: 
    //YSetDialog (dialog_proc);
    col1 = YColorRGB (FUCHSIA);
    col2 = YColorRGB (WHITE);
    col3 = YColorRGB (BLUE);
    col4 = YColorRGB (RED);
  case YM_PAINT:       
    YDrawRectF (0,0, WIN_W,WIN_H, YColorRGB(YELLOW));        

    /*     YBeginGroup ("MESSAGES",    20,375, 440,55, YColor("")); */
    /*     YWnd (&hTest, testmsg_proc, "",  15,15, 385,30, 0,0,0,0, CLR_DEF); */
    /*     YEndGroup (); */

    YGoto (YDRAWITEM, 0,0,col1,(long)page3_proc);

    YWin (&hPage1, push_proc, "Page1", WIN_W-10-w_push, 20, w_push,40/* , 0,0,0,0, col1 */);
    YWin (&hPage2, push_proc, "Page2", WIN_W-10-w_push, 70, w_push,40/* , 0,0,0,0, col2 */);
    YWin (&hPage3, push_proc, "Page3", WIN_W-10-w_push,120, w_push,40/* , 0,0,0,0, col3 */);
    /*     YWnd (&hPage2, push_proc, "Page2", 465, 70, 65,40, 0,0,0,0, col2); */
    /*     YWnd (&hPage3, push_proc, "Page3", 465,120, 65,40, 0,0,0,0, col3); */
    /*     YWnd (&hPage4, push_proc, "Page4", 465,170, 65,40, 0,0,0,0, col4); */

    /*     YWnd (&hExit,  push_proc, "Exit",  465,380, 65,40, 0,0,0,0, YColor("lime")); */
    break;        
  case YDRAWITEM:       
    /*  YWndClose (hCurPage);  */
    /*  YUnWnd (hCurPage);  */   
    YWin (&hCurPage, (YT_PFUNC)mes4, "", 10,10, WIN_W-30-w_push,WIN_H-h_mes-30/*, LP(hTest),0,0,0, (YT_COLOR)mes3*/); 
    break; 
    /* 	case YCLOSE:        */
    /*     YWndClean (id);         */
    /*     break;  */
    /*   case MYPUSH_UP: */
    /*     if      (mes1 == hExit )  exit(0);  */
    /*     else if (mes1 == hPage1)  YGoto (YDRAWITEM, 0,0,col1,(long)page1_proc); */
    /*     else if (mes1 == hPage2)  YGoto (YDRAWITEM, 0,0,col2,(long)page2_proc); */
    /*     else if (mes1 == hPage3)  YGoto (YDRAWITEM, 0,0,col3,(long)page3_proc); */
    /*     else if (mes1 == hPage4)  YGoto (YDRAWITEM, 0,0,col4,(long)page4_proc); */
    /*     break;  */
  default:;;;
    /*     return (YSend (hTest, message, mes1,mes2,mes3,mes4));  */
  }       
  
  RETURN_TRUE; 
}
/*-----------------------------main_proc--------------------------------------*/  
long  
main_proc (PFUNC_VAR)  
{
  
  int w = 130;
  
  switch (message) {
    
  case YM_CREATE:  
  case YM_PAINT:  
    YDrawRectF (0, 0, WIN_W, WIN_H, YColorRGB (WHITE));
    
    YWin (&n, newmain_proc, "", 10,      10,   w,          WIN_H-20);    
    YWin (&o, oldmain_proc, "", 10+w+10, 10,   WIN_W-30-w, WIN_H-20);    
    break;  
  default: ;;;;  
  }  
  
  RETURN_TRUE;  
} 
/**********************************************************888***************/ 
int  
MAIN (int argc, char *argv[])  
{   
  int w, h;  
  static int id=ID_NULL;
  long map;
  
  YInit();  
  
  w = XSCR (0.4); 
  h = YSCR (0.4 ); 
  /* 	w = 550;  */
  /* 	h = 450;  */
  /* printf ("w=%d h=%d \n", w, h); */

#ifdef _NEW
  YBig_new (&id, main_proc, "Hello, Y_ZONE!!", SC_DEF, SC_DEF, w, h,  0,0,0,0,
	//YColorRGB (AQUA)
	YColor ("aqua")
	);
#else
  YBig     (&id, main_proc, "Hello, Y_ZONE!!", SC_DEF, SC_DEF, w, h);
#endif
    
  YRAND_S;

  YWinBegPaint (n);    
  map = YWinMapGet (n);  
  YWinMapSet (map);
  
  draw_background(n);
  
  YWinMapSet (0); 
  YWinMapPut (n, map);   
  YWinEndPaint (n);  
 
  YPauseSoft (500);
  
  while (!YQUIT) { \
    
    YCheckEvents(); 
    if (YPauseSoft(0)) continue;  
 
    YWinBegPaint (n);  
    YWinMapPut (n, map);
    
    draw_foreground (n);
    
    YWinEndPaint (n);  
  
    YFlush ();
    //YPauseHard (10000); 
    YPauseSoft (500);  
  } 
 
  YRETURN;  
}  
/***************************************************************************/

#endif 
#ifdef YBOIDS

/*-----------------------------------------------------------------------*/ 
/*                                                                       */ 
/*                                                                       */ 
/*                                                                       */ 
/*                                                                       */ 
/*                                                                       */ 
/*-----------------------------------------------------------------------*/ 
 
#include <stdio.h> 
#include <stdlib.h> 
#include <string.h> 
#include <time.h> 
//#include <values.h> 
#include <math.h> 
//#include <unistd.h>                                                             
 
//#include "ybo-kernel.h" 
       
#ifdef _NEW
#include  "yma-kernel.h"
#else
#include  "ybo-kernel.h"
#endif

/*-----------------------------------------------------------------------*/ 
 
YT_COLOR new_darkgray; 
YT_COLOR new_yellow; 
YT_COLOR new_blue; 
YT_COLOR new_outlines[32]; 
 
/*----------------------------vec.h--------------------------------------*/ 
 
typedef struct { 
   double x, y, z; 
} _Vec, *Vec; 
 
Vec  zero_vec (void); 
Vec  new_vec (double X, double Y, double Z); 
Vec  vec_copy (Vec v1); 
void vec_clear (Vec vec); 
void vec_diff (Vec vec1, Vec vec2, Vec vec3); 
void vec_add (Vec vec1, Vec vec2); 
void vec_smul (Vec vec, double scalar); 
void vec_sdiv (Vec vec, double scalar); 
void vec_rshift (Vec vec, int n); 
void vec_lshift (Vec vec, int n); 
 
/*---------------------------------------------- 
 * Limit the length of the longest 
 * component to lim, while keeping others 
 * in proportion 
 */ 
void vec_limit(Vec vec, double lim); 
 
/*---------------------------------------------- 
 * Set the magnitude of the vector to a 
 * particular value 
 */ 
void vec_setmag(Vec vec, double mag); 
 
/*---------------------------------------------- 
 * Rectangular (ie. min component) distance 
 * between this and vec2 
 */ 
double vec_rdist(Vec vec1, Vec vec2); 
 
 
/*----------------------------boid.h-------------------------------------*/ 
 
typedef struct { 
   Vec pos, vel; 
   int X,Y; 
   int tail_lX, tail_lY, tail_rX, tail_rY, tail_X, tail_Y; 
   /* XPoint shadow[4]; */ 
   YPoint shadow[4]; 
   int wing_level; 
   int onscreen; /* boolean */ 
   int upstroke; /* boolean */ 
   int perching; /* boolean */ 
   int perch_timer; 
} _Boid, *Boid; 
 
Boid new_boid (int W, int H); 
void boid_perspective (Boid boid, int W, int H); 
int  boid_isonscreen (Boid boid, int W, int H); 
void boid_move (Boid boid, Boid allboids[], int numboids, 
	       Vec real_center, Vec real_avgvel, 
	       int W, int H); 
Vec boid_perceive_center (Boid boid, Vec real_cent, int numboids); 
Vec boid_av_vel (Boid boid, Vec real_avgvel, int numboids); 
Vec boid_chill_out (Boid boid, Boid boids[], int numboids); 
 
/*-------------------------------------------------------------------*/ 
void  
setup_colormap (void) 
{    
  int i; 
  int r, g, b; 
    
  new_darkgray = YColorRGB (0x4000>>8, 0x4000>>8, 0x4000>>8);  
  new_yellow   = YColorRGB (0xf000>>8, 0xf000>>8, 0x0>>8);  
  new_blue     = YColorRGB (0x0>>8, 0x0>>8, 0xf000>>8);  
 
  for (i=0; i<32; i++) { 
    r = (0xfa00-(i<<10))>>8; 
    g = (0xa000-(i<<10))>>8; 
    b = (0x7f00-(i<<10))>>8; 
    new_outlines[i] = YColorRGB (r, g, b);  
  } 
 
} 
/*----------------------------draw_boid------------------------------*/ 
void  
draw_boid (Boid boid) 
{
  
  //int i; 
  YPoint lwing[3], rwing[3]; 
  int outline_index; 
 
  int lx1, lx2, lx3, ly1, ly2, ly3; 
  int rx1, rx2, rx3, ry1, ry2, ry3; 
  YT_COLOR fcolor; 
	 
  /* YDrawRectF (0,0, 300,300, blk);     */  
 
  //YFillPolygon (boid->shadow, new_darkgray);  
  YDrawPolyF (boid->shadow, 3, new_darkgray);  
	 
  lx1 = lwing[0].x = boid->X; 
  lx2 = lwing[1].x = boid->tail_lX; 
  lx3 = lwing[2].x = boid->tail_X; 
	 
  ly1 = lwing[0].y = boid->Y; 
  ly2 = lwing[1].y = boid->tail_lY; 
  ly3 = lwing[2].y = boid->tail_Y; 
	 
  rx1 = rwing[0].x = boid->X; 
  rx2 = rwing[1].x = boid->tail_rX; 
  rx3 = rwing[2].x = boid->tail_X; 
	 
  ry1 = rwing[0].y = boid->Y; 
  ry2 = rwing[1].y = boid->tail_rY; 
  ry3 = rwing[2].y = boid->tail_Y; 
 
  outline_index = ((int)boid->pos->z) >> 10; 
	 
  /* if moving right => lwing behind rwing */ 
  if(boid->vel->x > 0) { 
 
    if (boid->tail_lY < boid->Y)  fcolor = new_yellow; 
    else                          fcolor = new_blue; 
    YDrawTriFB (lx1, ly1, lx2, ly2, lx3, ly3, fcolor, new_outlines[outline_index]); 
 
    if (boid->tail_rY < boid->Y)  fcolor = new_blue; 
    else                          fcolor = new_yellow; 
    YDrawTriFB (rx1, ry1, rx2, ry2, rx3, ry3, fcolor, new_outlines[outline_index]); 
 
  } else { 
 
    if (boid->tail_rY < boid->Y) fcolor = new_yellow; 
    else                         fcolor = new_blue; 
    YDrawTriFB (rx1, ry1, rx2, ry2, rx3, ry3, fcolor, new_outlines[outline_index]); 
 
    if (boid->tail_lY < boid->Y) fcolor = new_blue; 
    else                         fcolor = new_yellow; 
    YDrawTriFB (lx1, ly1, lx2, ly2, lx3, ly3, fcolor, new_outlines[outline_index]); 
 
  } 
	 
}    
/*------------------------------------------------------------------*/ 
//#define max(a,b) ((a>b)?a:b) 
 
 
/*------------------------------------------------------------------*/ 
Vec zero_vec(void) 
{ 
  Vec vec; 
	 
  vec = (Vec)malloc(sizeof(_Vec)); 
  vec->x = vec->y = vec->z = 0; 
  return vec; 
} 
/*------------------------------------------------------------------*/ 
Vec new_vec(double X, double Y, double Z) 
{ 
  Vec vec; 
	 
  vec = zero_vec(); 
  vec->x = X; vec->y = Y; vec->z = Z;    
  return vec; 
} 
/*------------------------------------------------------------------*/ 
Vec vec_copy(Vec v1) 
{ 
  Vec vec; 
	 
  vec = zero_vec(); 
  vec->x = v1->x; vec->y = v1->y; vec->z = v1->z; 
  return vec; 
} 
/*------------------------------------------------------------------*/ 
void vec_clear(Vec vec) 
{ 
  vec->x = vec->y = vec->z = 0; 
} 
/*------------------------------------------------------------------*/ 
void vec_diff(Vec vec1, Vec vec2, Vec vec3) 
{ 
  vec3->x = vec1->x - vec2->x; 
  vec3->y = vec1->y - vec2->y; 
  vec3->z = vec1->z - vec2->z; 
} 
/*------------------------------------------------------------------*/ 
void vec_add(Vec vec1, Vec vec2) 
{ 
  vec1->x += vec2->x; 
  vec1->y += vec2->y; 
  vec1->z += vec2->z; 
} 
/*------------------------------------------------------------------*/ 
void vec_smul(Vec vec, double scalar) 
{ 
  vec->x *= scalar; 
  vec->y *= scalar; 
  vec->z *= scalar; 
} 
/*------------------------------------------------------------------*/ 
void vec_sdiv(Vec vec, double scalar) 
{ 
  vec->x /= scalar; 
  vec->y /= scalar; 
  vec->z /= scalar; 
} 
/*------------------------------------------------------------------*/ 
void vec_rshift(Vec vec, int n) 
{ 
  vec->x = (int)vec->x >>n; 
  vec->y = (int)vec->y >>n; 
  vec->z = (int)vec->z >>n; 
} 
/*------------------------------------------------------------------*/ 
void vec_lshift(Vec vec, int n) 
{ 
  vec->x = (int)vec->x <<n; 
  vec->y = (int)vec->y <<n; 
  vec->z = (int)vec->z <<n; 
} 
/*------------------------------------------------------------------*/ 
/* 
 * Limit the length of the longest 
 * component to lim, while keeping others 
 * in proportion 
 */ 
void vec_limit(Vec vec, double lim) 
{ 
  double m,f; 
	 
  m = YMAX(fabs(vec->x), fabs(vec->y)); 
  m = YMAX(m, fabs(vec->z)); 
	 
  if(m <= lim) return; 
	 
  f = lim/m; 
  vec_smul(vec, f); 
} 
/*------------------------------------------------------------------*/ 
/* 
 * Set the magnitude of the vector to a 
 * particular value 
 */ 
void vec_setmag(Vec vec, double mag) 
{ 
  double m,f; 
	 
  m = YMAX(fabs(vec->x), fabs(vec->y)); 
  m = YMAX(m, fabs(vec->z)); 
	 
  f = mag/m; 
  vec_smul(vec, f); 
} 
/*--------------------------------vec_rdist--------------------------- 
 * Rectangular (ie. min component) distance 
 * between this and vec2 
 *-------------------------------------------------------------------*/ 
double  
vec_rdist(Vec vec1, Vec vec2) 
{ 
  double dx,dy,dz, dm; 
    
  dx = vec1->x - vec2->x; 
  dy = vec1->y - vec2->y; 
  dz = vec1->z - vec2->z; 
	 
  dm = YMAX(fabs(dx), fabs(dy)); 
  dm = YMAX(dm, fabs(dz)); 
	 
  return dm; 
} 
/*-----------------------------boid.c--------------------------------*/ 
 
#define rrand(a) (rand()%a) 
 
#define DEFAULT_CENTER_BIAS 7 
#define DEFAULT_AVG_VEL     3 
#define DEFAULT_CHILLING    1 
 
/*-------------------------------------------------------------------*/ 
Boid  
new_boid(int W, int H) 
{ 
  Boid boid; 
  double px,py,pz; 
  double vx,vy,vz; 
	 
  boid=(Boid)malloc(sizeof(_Boid)); 
	 
  px=(double)(rrand((W<<4)) - (W<<3)); 
  py=(double)(rrand((H<<4)) - (H<<3)); 
  pz=(double)(rrand(2000) + 2000); 
	 
  boid->pos=new_vec(px,py,pz); 
	 
  vx=(double)(rrand(51) - 25); 
  vy=(double)(rrand(51) - 25); 
  vz=(double)(rrand(51) - 25); 
	 
  boid->vel=new_vec(vx,vy,vz); 
	 
  boid->wing_level=(int)(rrand(200)-100); 
	 
  boid_perspective(boid, W, H); 
	 
  return boid; 
} 
/*-----------------------------------------------------------------*/ 
void  
boid_perspective (Boid boid, int W, int H) 
{
  
  double zfactor, zf; 
  Vec tail, tail_end; 
  double tail_lx, tail_lz, tail_rx, tail_rz; 
  double tailx, tailz; 
	 
  tail=vec_copy(boid->vel); 
  tail_end=vec_copy(boid->vel); 
	 
  if(boid->pos->z <= 0) { 
    boid->onscreen = 0; 
  } else { 
    zf = W/(double)2.5; 
    zfactor=((double)boid->pos->z)/zf; 
		 
    boid->X = (W>>1) + (int)(boid->pos->x/zfactor); 
    boid->Y = (H>>1) + (int)(boid->pos->y/zfactor); 
		 
    boid->shadow[0].x = boid->X; 
    boid->shadow[0].y = (H>>1) + (int)(1000/zfactor); 
		 
    vec_setmag(tail_end, 40); 
    vec_diff(boid->pos, tail_end, tail_end); 
		 
    zfactor=((double)tail_end->z)/zf; 
    boid->tail_X = (W>>1) + (int)(tail_end->x/zfactor); 
    boid->tail_Y = (H>>1) + (int)(tail_end->y/zfactor); 
    boid->shadow[2].x = boid->tail_X; 
    boid->shadow[2].y = (H>>1) + (int)(1000/zfactor); 
		 
    vec_setmag(tail, 50); 
    vec_diff(boid->pos, tail, tail); 
		 
    tailx = -tail->z/60; 
    tailz = tail->x/60; 
		 
    tail_lx = tail->x - tailx; 
    tail_lz = tail->z - tailz; 
		 
    tail_rx = tail->x + tailx; 
    tail_rz = tail->z + tailz; 
		 
    tail->y -= boid->wing_level; 
		 
    zfactor = ((double)tail_lz)/zf; 
    boid->tail_lX = (W>>1) + (int)(tail_lx/zfactor); 
    boid->tail_lY = (H>>1) + (int)(tail->y/zfactor); 
    boid->shadow[1].x = boid->tail_lX; 
    boid->shadow[1].y = (H>>1) + (int)(1000/zfactor); 
		 
    zfactor = ((double)tail_rz)/zf; 
    boid->tail_rX = (W>>1) + (int)(tail_rx/zfactor); 
    boid->tail_rY = (H>>1) + (int)(tail->y/zfactor); 
    boid->shadow[3].x = boid->tail_rX; 
    boid->shadow[3].y = (H>>1) + (int)(1000/zfactor);  
		 
		 
    boid->onscreen = boid_isonscreen(boid,W,H); 
  } 
	 
  free(tail); 
  free(tail_end); 
} 
/*-----------------------------------------------------------------*/ 
int boid_isonscreen(Boid boid, int W, int H) 
{ 
  return (boid->X>=0 && boid->X<W && boid->Y>=0 && boid->Y<H); 
} 
/*-----------------------------------------------------------------*/ 
/* 
 * Move this boid, wrt allboids 
 */ 
void boid_move(Boid boid, Boid allboids[], int numboids, 
	       Vec real_center, Vec real_avgvel, 
	       int W, int H) 
{ 
  Vec center, center_bias; 
  Vec avgvelocity, avgvel_bias; 
  Vec chilling; 
	 
  if(boid->perching) { 
    if(boid->perch_timer > 0) { 
      boid->perch_timer--; 
      return; 
    } 
    else { 
      boid->perching = 0; 
    } 
  } 
	 
  center_bias = zero_vec(); 
  center = boid_perceive_center(boid, real_center, numboids); 
  vec_diff(center, boid->pos, center_bias); 
  vec_rshift(center_bias, DEFAULT_CENTER_BIAS); 
	 
  avgvel_bias = zero_vec(); 
  avgvelocity = boid_av_vel(boid, real_avgvel, numboids); 
  vec_diff(avgvelocity, boid->vel, avgvel_bias); 
  vec_rshift(avgvel_bias, DEFAULT_AVG_VEL); 
	 
  chilling = boid_chill_out(boid, allboids, numboids); 
  vec_rshift(chilling, DEFAULT_CHILLING); 
	 
  vec_add(boid->vel, center_bias); 
  vec_add(boid->vel, avgvel_bias); 
  vec_add(boid->vel, chilling); 
	 
  vec_limit(boid->vel, 100); 
	 
  vec_add(boid->pos, boid->vel); 
	 
  free(center); free(center_bias); 
  free(avgvelocity); free(avgvel_bias); 
  free(chilling); 
	 
  if(boid->upstroke) { 
    if(boid->wing_level >= 100) {	   
      boid->upstroke = 0; 
    } 
    else { 
      boid->wing_level += 40; 
    } 
  } 
  else { 
    if(boid->wing_level <= -100) { 
      boid->upstroke = 1; 
    } 
    else { 
      boid->wing_level -= 20; 
    } 
		 
  } 
	 
    
  /* bound world */ 
  if(boid->pos->x < -1500) { 
    boid->vel->x += 10; 
  } 
  if(boid->pos->x > 1500) { 
    boid->vel->x -= 10; 
  } 
  if(boid->pos->y < -1200) { 
    boid->vel->y += 10; 
  } 
  if(boid->pos->y > 800) { 
    boid->vel->y -= 10; 
  } 
  if(boid->pos->y > 1000) { 
    boid->pos->y = 1000; /* Hit ground!! */ 
    boid->perching = 1; 
    boid->perch_timer = (int)(rrand(20) + 30); 
    boid->wing_level = 60; 
    boid->vel->y = 0; 
  } 
  if(boid->pos->z < 1500) { 
    boid->vel->z += 10; 
  } 
  if(boid->pos->z > 3000) { 
    boid->vel->z -= 10; 
  } 
	 
  boid_perspective (boid, W, H);

  return;
} 
/*-----------------------------------------------------------------*/ 
Vec boid_perceive_center(Boid boid, Vec real_cent, int numboids) 
{ 
  Vec perc_cent; 
    
  perc_cent = zero_vec(); 
  vec_diff(real_cent, boid->pos, perc_cent); 
  vec_sdiv(perc_cent, (double)(numboids-1)); 
	 
  return perc_cent; 
} 
/*-----------------------------------------------------------------*/ 
Vec boid_av_vel(Boid boid, Vec real_avgvel, int numboids) 
{ 
  Vec perc_avgvel; 
	 
  perc_avgvel = zero_vec(); 
  vec_diff(real_avgvel, boid->vel, perc_avgvel); 
  vec_sdiv(perc_avgvel, (double)(numboids-1)); 
	 
  return perc_avgvel; 
} 
/*-----------------------------------------------------------------*/ 
Vec boid_chill_out(Boid boid, Boid boids[], int numboids) 
{
  
  Vec chill, bigchill; 
  int i; 
	 
  chill = zero_vec(); 
  bigchill = zero_vec(); 
	 
  for(i=0; i<numboids; i++) { 
    if(boids[i] != boid) { 
      if(vec_rdist(boid->pos, boids[i]->pos) <= 100) { 
	vec_diff(boid->pos, boids[i]->pos, chill); 
	vec_add(bigchill, chill); 
      } 
    } 
  } 
	 
  free(chill); 
	 
  return bigchill; 
} 
/*-----------------------------main_proc--------------------------*/  
long  
main_proc (PFUNC_VAR)  
{  
  
  switch (message) {  
  case YM_PAINT: 
    break; 
  case YRMOUSEUP: 
  case YDESTROY: 
    YQuit (); 
    break; 
  default: ;;;;  
  }  
  
  RETURN_TRUE;  
}  
/*-----------------------------------------------------------------*/ 
int 
MAIN (int argc, char **argv) 
{
  
  //long background, freshmap;  
  int  numboids; 
  Boid *boids; 
  int i; 
  Vec center, avg_velocity; 
  int  width, height; 
  //long bwin;
  int map; 
  int id;
    
  /*-------------------------------------------*/
  
  YRAND_S;
  numboids = 30; 
 
  YInit ();    
  setup_colormap (); 
 
  width  = XSCR(0.4);  
  height = YSCR(0.4);
  
#ifdef _NEW
  YBig_new (&id, main_proc, "Yboids", SC_DEF, SC_DEF, width, height, 0,0,0,0,
  	//YColorRGB (AQUA)
  	YColor ("aqua")
  	);
#else
  YBig (&id, main_proc, "Yboids", SC_DEF, SC_DEF, width, height);
#endif
 
  YWinBegPaint (id);   
  map = YWinMapGet (id);   
  YWinMapSet (map); 
  YDrawRectF (0,0, width,height, blk);
  YWinMapSet (0); 
  YWinEndPaint (id); 

  /* freshmap   = YCreatePixmap(id);  */
 
  boids = (Boid *) calloc (numboids, sizeof(_Boid)); 

  for (i = 0; i < numboids; i++) { 
    boids[i] = new_boid (width, height); 
  } 

  center = zero_vec(); 
  avg_velocity = zero_vec(); 
    
  /* YSetWindowPixmap (id, freshmap);  */
 
  for( ; ; ) {
    
    if (YQUIT) break;
 
    /* YCopyPixmaps (background, freshmap, width, height);  */
    YWinBegPaint (id);    
    YWinMapPut (id, map);   

    vec_clear(center); 
    vec_clear(avg_velocity); 
    for(i=0; i<numboids; i++) { 
      vec_add(center, boids[i]->pos); 
      vec_add(avg_velocity, boids[i]->vel); 
    } 
       
    for(i=0; i<numboids; i++) { 
      boid_move(boids[i], boids, numboids, center, avg_velocity, width, height); 
 
      if(boids[i]->onscreen) { 
	/* YBeginPaint (freshmap, YPIX);  */
	/* draw_boid (boids[i], freshmap);  */
	draw_boid(boids[i]); 
      } 
    } 
    YWinEndPaint (id);  
 
    YFlush (); 
    YCheckEvents (); 

    YPauseHard (3000); 
  } 
	  
  YRETURN;  
} 
/***************************************************************************/

#endif 
