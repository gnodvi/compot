// -*-  mode: c    ; coding: koi8   -*- ----------------------------------------

/**************************************************************************** 
 *                                                                          * 
 *  kernel.c  --  "Library Yzone" (main file);                              * 
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
                                                                              
 
 
/***********************************************************************/  
#include  <stdio.h> 
#include  <stdlib.h>   
#include  <string.h> 
#include  <math.h> 
#include  <time.h>   
#include  <ctype.h>
 
#include "ybo-kernel.h" 
 
 
/***********************************************************************/ 
#ifdef Y_UNIX 
 
#include  <X11/Xlib.h>  
#include  <X11/X.h>  
#include  <X11/Xatom.h>  
#include  <X11/Xutil.h>  
#include  <X11/keysym.h>  
#include  <X11/keysymdef.h>  
#include  <X11/cursorfont.h>  
#include  <dirent.h>  
#include  <sys/time.h>
#include  <string.h>  
#include  <unistd.h>  
 
 
Drawable  drawable;  
Display  *dpy;   
int       scr;  
Colormap  cmap;  
GC        gc;  
Window    root;  
Visual   *vis;  
unsigned int depth; 

/* Window    win;   */
/* Region    reg;   */
 
#else /****************************************/ 
#define API_W 1 
 
#define STRICT 
#include <windows.h> 
 
HINSTANCE glob_hInstance;  
HINSTANCE glob_hPrevInstance;  
LPSTR     glob_lpszCmdLine;  
int       glob_nCmdShow;  
 
/* HWND  main_hwnd;  */
HDC   glob_hdc; // индекс контекста устройства   
HDC   glob_hdcMemory;  
 
HDC   drawable;   
HDC   hdc_pix; // for pixmap  
 
// Прототипы функций 
BOOL InitApp(HINSTANCE); 
LRESULT CALLBACK WndProc(HWND, UINT, WPARAM, LPARAM); 
 
char const szClassName[]   = "WindowAppClass"; 
//char const szWindowTitle[] = "Window Application"; 
extern int main(int, char *[]); 
extern int  __argc; 
extern char **__argv; 
 
 
#endif   
/***********************************************************************/  
 
YT_BOOL yquit_flag;  
int quit_ret; 
YT_BOOL bigwindow; 
 
int    blk,wht; 
int    wdisplay_pix, hdisplay_pix;  
float  wdisplay_mm, hdisplay_mm;  
double xpix_per_mm, ypix_per_mm;
int    x_pix_in_inch, y_pix_in_inch;
int    id_last; 
int    mode_type;

typedef struct {
	long     hwnd;
  YT_PFUNC proc; 
	int      parent;
  long     reg;
} YT_BIGWND; 

#define BIGWND_NUM 20 
#define BIGI(i) (bigwnds[(i)])
YT_BIGWND *bigwnds[BIGWND_NUM];  
 
/*------------------------------YPaintPixel----------------------------------*/  
void  
YPaintPixel (int x, int y, YT_COLOR color)  
{  
#ifdef Y_UNIX  
  XSetForeground (dpy, gc, color);  
  XDrawPoint (dpy, drawable, gc, x, y);  
#else   
  SetPixel (drawable, x, y, color);  
#endif  
  
}  
/*-----------------------------YDrawLine------------------------------------*/   
void   
YDrawLine (int x1, int y1, int x2, int y2, YT_COLOR color)   
{   
#ifdef Y_UNIX  
   
  if (mode_type != YM_PAINT) return; 
  
  XSetForeground (dpy, gc, color);   
  XDrawLine (dpy, drawable, gc, x1, y1, x2, y2);   
   
#else /*-------------------------*/   
  int   x0 = 0, y0 = 0;  
  HPEN  hpen, hpenOld;   
   
  if (mode_type != YM_PAINT) return; 
  
  if (!(hpen = CreatePen (PS_SOLID, 1, color)))    YERROR ("YPaintLine-1");   
  if (!(hpenOld = SelectObject (drawable, hpen)))  YERROR ("YPaintLine-2");   
 
  MoveToEx (drawable, x1, y1, NULL);    
  LineTo (drawable, x2, y2);  
  YPaintPixel (x2-x0, y2-y0 , color);        
 
  if (!(SelectObject (drawable, hpenOld)))  YERROR ("YPaintLine-3");   
  if (!DeleteObject (hpen))                 YERROR ("YPaintLine-4");   
  
  return;                                                                         
#endif  
}   
/*-----------------------------YDrawRectF--------------------------------*/   
void   
YDrawRectF (int x, int y, int w, int h, YT_COLOR color)   
{   
#ifdef Y_UNIX  
   
  if (mode_type != YM_PAINT) return; 
  
  XSetForeground (dpy, gc, color);   
  XFillRectangle (dpy, drawable, gc, x, y, w, h);   
  
#else /*-------------------------*/   
  HBRUSH    hbr, hbrOld;   
  RECT      rect;   
  
  if (mode_type != YM_PAINT) return; 
   
  rect.left   = x;   
  rect.top    = y;   
  rect.right  = x+w + 1;   
  rect.bottom = y+h + 1;   
   
  if (!(hbr = CreateSolidBrush (color)))   YERROR ("YPaintRectF-1");   
  if (!(hbrOld = SelectObject (drawable, hbr)))  YERROR ("SelectObject-1");  
 
  FillRect (drawable, &rect, hbr);   
 
  if (!(SelectObject (drawable, hbrOld)))  YERROR ("SelectObject-2");  
  if (!DeleteObject (hbr))   YERROR ("YPaintRectF-2");   
  
#endif  
}   
/*------------------------------YDrawRectB----------------------------------*/  
void  
YDrawRectB (int x, int y, int w, int h, YT_COLOR color)  
{  
  //w--;  
  //h--;  
  YDrawLine (x,   y,   x+w, y,   color);  
  YDrawLine (x,   y+h, x+w, y+h, color);  
  YDrawLine (x,   y+h, x,   y,   color);  
  YDrawLine (x+w, y,   x+w, y+h, color);  
}  
/*------------------------------YDrawRectFB---------------------------------*/  
void  
YDrawRectFB (int x, int y, int width, int height, YT_COLOR fcolor, YT_COLOR lcolor)  
{  
  YDrawRectF (x, y, width, height, fcolor);  
  YDrawRectB (x, y, width, height, lcolor);  
  return;  
}  
/*------------------------------YDrawCircF----------------------------------*/ 
void 
YDrawCircF (int cx, int cy, int r, YT_COLOR f_color) 
{ 
  return; 
} 
/*------------------------------YDrawCircB---------------------------------*/  
void  
YDrawCircB (int cx, int cy, int r, YT_COLOR bcolor)  
{  
 
#ifdef Y_UNIX   
  int x, y, w, h, ang_begin, ang_delta;
      
  if (mode_type != YM_PAINT) return; 
 
  x = cx - r;
  y = cy - r;
  w = 2*r;
  h = 2*r;
  ang_begin = 0;
  ang_delta = 360*64;

  XSetForeground (dpy, gc, bcolor); 
  XDrawArc (dpy, drawable, gc, x, y, w, h, ang_begin, ang_delta); 

#else 
  HPEN  hpen, hpenOld;    
  HBRUSH    hbr, hbrOld;    
   
  if (mode_type != YM_PAINT) return; 
   
  if (!(hpen = CreatePen (PS_SOLID, 1, bcolor)))    YERROR ("YPaintLine-1");    
  if (!(hpenOld = SelectObject (drawable, hpen)))  YERROR ("YPaintLine-2");    
 
  if (!(hbr = CreateSolidBrush (bcolor)))   YERROR ("YPaintRectF-1");    
  if (!(hbrOld = SelectObject (drawable, hbr)))  YERROR ("SelectObject-1");   
  
  Arc( 
      drawable,         // handle to device context 
      cx-r/2,   // x-coord of rectangle's upper-left corner 
      cy-r/2,    // y-coord of rectangle's upper-left corner 
      cx+r/2,  // x-coord of rectangle's lower-right corner 
      cy+r/2, // y-coord of rectangle's lower-right corner 
      cx+r/2,  // x-coord of first radial ending point 
      0,  // y-coord of first radial ending point 
      cx+r/2,    // x-coord of second radial ending point 
      0     // y-coord of second radial ending point 
       ); 
 
  if (!(SelectObject (drawable, hbrOld)))  YERROR ("SelectObject-2");   
  if (!DeleteObject (hbr))   YERROR ("YPaintRectF-2");    
 
  if (!(SelectObject (drawable, hpenOld)))  YERROR ("YPaintLine-3");    
  if (!DeleteObject (hpen))                 YERROR ("YPaintLine-4");    
   
#endif 
  
}  
/*------------------------------YDrawCircFB---------------------------------*/  
void  
YDrawCircFB (int cx, int cy, int r, YT_COLOR fcolor, YT_COLOR bcolor)  
{  
 
#ifdef Y_UNIX   
  int x, y, w, h, ang_begin, ang_delta;
   
  if (mode_type != YM_PAINT) return; 
   
  x = cx - r;
  y = cy - r;
  w = 2*r;
  h = 2*r;
  ang_begin = 0;
  ang_delta = 360*64;
   
  XSetForeground (dpy, gc, fcolor); 
  XFillArc (dpy, drawable, gc, x, y, w, h, ang_begin, ang_delta); 
 
#else 
  HBRUSH    hbr, hbrOld;    
  HPEN  hpen, hpenOld;    
   
  if (mode_type != YM_PAINT) return; 
   
  if (!(hpen = CreatePen (PS_SOLID, 1, bcolor)))    YERROR ("YPaintLine-1");    
  if (!(hpenOld = SelectObject (drawable, hpen)))  YERROR ("YPaintLine-2");    
  
  if (!(hbr = CreateSolidBrush (fcolor)))   YERROR ("YPaintRectF-1");    
  if (!(hbrOld = SelectObject (drawable, hbr)))  YERROR ("SelectObject-1");   
  
  Ellipse (drawable, cx-r/2, cy-r/2, cx+r/2, cy+r/2); 
  
  if (!(SelectObject (drawable, hbrOld)))  YERROR ("SelectObject-2");   
  if (!DeleteObject (hbr))   YERROR ("YPaintRectF-2");    
 
  if (!(SelectObject (drawable, hpenOld)))  YERROR ("YPaintLine-3");    
  if (!DeleteObject (hpen))                 YERROR ("YPaintLine-4");    
   
#endif 
  
}  
/*-----------------------------YDrawPolyF-----------------------------------*/  
void  
YDrawPolyF (YPoint *pts, int numpoints, YT_COLOR fcolor)  
{  
  
#ifdef Y_UNIX  
   
  if (mode_type != YM_PAINT) return; 
  
  XSetForeground(dpy, gc, fcolor);  
  XFillPolygon(dpy, drawable, gc, (XPoint*)pts, numpoints, Nonconvex, CoordModeOrigin);  
   
#else /*---------------------*/   
#define MAX_PNTS 8  
  int     i;  
  POINT   pnts[MAX_PNTS];  
  HPEN    hpen, hpenOld;   
  HBRUSH  hbr, hbrOld;   
   
  if (mode_type != YM_PAINT) return; 
  
  if (numpoints > MAX_PNTS)  YERROR ("YDrawFLines");  
 
  for (i = 0; i < numpoints; i++) {  
    pnts[i].x = pts[i].x;  
    pnts[i].y = pts[i].y;  
  }  
  pnts[i].x = pts[0].x;  
  pnts[i].y = pts[0].y;  
 
  if (!(hpen = CreatePen (PS_SOLID, 1, fcolor)))    YERROR ("YPaintLine-1");   
  if (!(hpenOld = SelectObject (drawable, hpen)))  YERROR ("YPaintLine-2");   
  //SetPolyFillMode (drawable, WINDING /*ALTERNATE*/); 
  if (!(hbr = CreateSolidBrush (fcolor))) YERROR ("YPaintPolyF-1");  
  if (!(hbrOld = SelectObject (drawable, hbr)))  YERROR ("SelectObject-1");  
  
  Polygon (drawable, pnts, numpoints+1);  
 
  if (!(SelectObject (drawable, hbrOld)))  YERROR ("SelectObject-2");  
  //Polyline (drawable, pnts, numpoints+1);  
  if (!DeleteObject (hbr))                YERROR ("YPaintPolyF-4");  
  if (!(SelectObject (drawable, hpenOld)))  YERROR ("YPaintLine-3");   
  if (!DeleteObject (hpen))                 YERROR ("YPaintLine-4");   
  
#endif  
}  
/*-----------------------------YDrawPolyB-----------------------------------*/  
void  
YDrawPolyB (YPoint *pts, int numpoints, YT_COLOR fcolor)  
{  
  
#ifdef Y_UNIX  
   
  if (mode_type != YM_PAINT) return; 
 
   
#else /*---------------------*/   
#define MAX_PNTS 8  
  int     i;  
  POINT   pnts[MAX_PNTS];  
  HPEN    hpen, hpenOld;   
   
  if (mode_type != YM_PAINT) return; 
  
  if (numpoints > MAX_PNTS)  YERROR ("YDrawFLines");  
 
  for (i = 0; i < numpoints; i++) {  
    pnts[i].x = pts[i].x;  
    pnts[i].y = pts[i].y;  
  }  
  pnts[i].x = pts[0].x;  
  pnts[i].y = pts[0].y;  
 
  if (!(hpen = CreatePen (PS_SOLID, 1, fcolor)))    YERROR ("YPaintLine-1");   
  if (!(hpenOld = SelectObject (drawable, hpen)))  YERROR ("YPaintLine-2");   
  
  Polyline (drawable, pnts, numpoints+1);  
 
  if (!(SelectObject (drawable, hpenOld)))  YERROR ("YPaintLine-3");   
  if (!DeleteObject (hpen))                 YERROR ("YPaintLine-4");   
  
#endif  
}  
/*-------------------------------YStringW-----------------------------------*/  
int  
YStringW (char *string)  
{  
 
#ifdef Y_UNIX  
  //return (XTextWidth (KERN_S->font_struct, string, strlen (string))); 
  return (8);
#else  
  SIZE  siz;  
  GetTextExtentPoint32 (drawable, string, lstrlen (string), &siz);  
  return (siz.cx);  
#endif  
}  
/*------------------------------YStringH------------------------------------*/  
int  
YStringH (char *string)  
{  
 
#ifdef Y_UNIX  
  string++;  
  /* return (FONTH);   */
  return (16);
#else   
  SIZE    siz;  
  GetTextExtentPoint32 (drawable, string, lstrlen (string), &siz);  
  return (siz.cy);  
#endif  
}  
/*-----------------------------YDrawString---------------------------------*/  
void  
YDrawString (char *text, int x, int y, YT_COLOR color)  
{  
  
#ifdef Y_UNIX  
   
  if (mode_type != YM_PAINT) return; 
 
  y += 4; /*??!!!*/ 
  XSetForeground (dpy, gc, color);  
  XDrawString (dpy, drawable, gc, x, y, text, strlen (text));  
#else  
  int fonth = YStringH (text); 
   
  if (mode_type != YM_PAINT) return; 
 
  SetTextColor (drawable, color);  
  TextOut (drawable, x, y-fonth/2, text, strlen (text));  
#endif  
}  
/*-------------------------------YDrawGroup---------------------------------*/ 
void 
YDrawGroup (char *sText, int x, int y, int w, int h, YT_COLOR color) 
{ 
  int  w_char = YStringW ("W"); 
  int  left = 10, dx = 5, dy = 4, xmax, ymax, xl, xr; 
  int  wtext; 
  YT_COLOR clr_white = YColorRGB(WHITE); 
  YT_COLOR clr_black = YColorRGB(BLACK); 
 
  xmax = x+w-1; 
  ymax = y+h-1; 
 
  /*   if (color != CLR_NULL) {  */
  /*     YDrawRectF (x+2, y+2+dy, w-4, h-4-dy, color);   */
  /*     YDrawRectF (x+2, y+2, left-2, dy, color);   */
  /*   }  */
 
  xl = x+left; 
  YDrawLine (x,   y,   xl, y,   clr_black); 
  YDrawLine (x+1, y+1, xl, y+1, clr_white); 
 
  /*   YDrawString (sText, xl+dx, y, clr_black);  */
  wtext = YStringW (sText); 

  xr = xl+dx+wtext+dx; 
  /*   if (color != CLR_NULL)   */
  /*     YDrawRectF (xr, y+2, xmax-2-xr+1, dy, color);   */
 
  YDrawLine (xr, y,   xmax,   y,   clr_black); 
  YDrawLine (xr, y+1, xmax-1, y+1, clr_white); 
 
  YDrawLine (x+1,    y+1,    x+1,    ymax,   clr_white); 
  YDrawLine (x,      ymax,   xmax,   ymax,   clr_white); 
  YDrawLine (xmax,   y,      xmax,   ymax,   clr_white); 
 
  YDrawLine (x,      y,      x,      ymax-1, clr_black); 
  YDrawLine (x,      ymax-1, xmax-1, ymax-1, clr_black); 
  YDrawLine (xmax-1, y,      xmax-1, ymax-1, clr_black); 
 
  return; 
} 
/*-----------------------------YGroup----------------------------------*/ 
void 
YGroup (int numer, char *name, int x, int y, int w, int h, YT_COLOR color) 
{ 
  static int x0group[100], y0group[100];
  static int cur=0;
       
  if (numer == 1) {
    if (name != NULL)  
      YDrawGroup (name, x, y, w, h, color); 
     
    /*     YGetOrigin (&(x0group[cur]), &(y0group[cur]));  */
    /*     YSetOrigin (x0group[cur] + x, y0group[cur] + y); */
    cur++;
    
  } else {
    cur--;
    /*     YSetOrigin (x0group[cur], y0group[cur]);  */
  }

  return;
} 
/*-----------------------------YBeginGroup----------------------------------*/ 
void 
YBeginGroup (char *name, int x, int y, int w, int h, YT_COLOR color) 
{ 
       
  YGroup (1, name, x, y, w, h, color); 
  
} 
/*-------------------------------YEndGroup----------------------------------*/ 
void 
YEndGroup () 
{ 
 
  YGroup (2, NULL, 0, 0, 0, 0, 0); 
 
} 
/*-------------------------------YDrawTriF--------------------------*/    
void                                                                              
YDrawTriF (int x1, int y1, int x2, int y2, int x3, int y3, YT_COLOR fcolor)       
{                                                                                 
  
  YPoint  pnts[3];                                                                
                                                                                  
  pnts[0].x = x1;    pnts[0].y = y1;                                   
  pnts[1].x = x2;    pnts[1].y = y2;                                   
  pnts[2].x = x3;    pnts[2].y = y3;                                   
                                                                                  
  YDrawPolyF (pnts, 3, fcolor);  
   
  return;                                                                         
}                                                                                 
/*------------------------------YDrawTriB---------------------------*/  
void  
YDrawTriB (int x1, int y1, int x2, int y2, int x3, int y3, YT_COLOR color)  
{  
 
  YDrawLine (x1, y1, x2, y2, color);   
  YDrawLine (x2, y2, x3, y3, color);   
  YDrawLine (x3, y3, x1, y1, color);   
  
  return;                                                                         
}  
/*--------------------------------YDrawTriFB--------------------------------*/    
void                                                                              
YDrawTriFB (int x1, int y1, int x2, int y2, int x3, int y3, YT_COLOR fcolor,      
            YT_COLOR bcolor)                                                      
{                                                                                 
  
  YDrawTriF (x1, y1, x2, y2, x3, y3, fcolor);                                     
  YDrawTriB (x1, y1, x2, y2, x3, y3, bcolor);                                     
  
}  
/*-----------------------------YColorRGB---------------------------------*/  
YT_COLOR  
YColorRGB (int red, int green, int blue)  
{
  
#ifdef Y_UNIX 
  XColor  cell;  
  
  cell.red = red << 8;  
  cell.green = green << 8;  
  cell.blue = blue << 8;  
 
  if (!(XAllocColor (dpy, cmap, &cell)))  
    printf ("Error : KisaSetColor \n");  
  
  return (cell.pixel);  
#else /*-------------------------*/  
 
  //  return (PALETTERGB (red, green, blue));  
  return (RGB(red,green,blue));  
 
#endif 
}  
/*---------------------------YFlush--------------------------------*/ 
void 
YFlush () 
{ 
#ifdef Y_UNIX 
	 
  XClearWindow (dpy, drawable); 
  XFlush (dpy); 
	  
#else /*-------------------------*/  
 
#endif 
} 
/*-----------------------------YImageFree-----------------------------------*/  
void  
YImageFree (long pImage)  
{  
 
#ifdef Y_UNIX  
  XDestroyImage ((XImage *) pImage);  
  XFlush (dpy);  
#else   
  if (!DeleteObject ((HBITMAP) pImage))  
    YERROR ("YImageFree-DeleteObject");  
#endif  
}  
/*------------------------------YImageGet-----------------------------------*/  
long  
YImageGet (int x, int y, int w, int h)  
{  
 
#ifdef Y_UNIX  
  XImage *xim;  
  //  CALCXY (x, y);  
  //  CALCWH (w, h);  
   
  //if (mode_type != YM_PAINT) return; 
 
  xim = XGetImage (dpy, /* win */drawable, x, y, w+1, h+1, AllPlanes, ZPixmap);  
  XFlush (dpy); 
  
  return ((long)xim);  
#else   
  HBITMAP hbmp; 
   
  //if (mode_type != YM_PAINT) return; 
   
  if (!(hbmp = CreateCompatibleBitmap (drawable, w+1, h+1))) YERROR ("YImageGet-1");  
  if (!(hdc_pix = CreateCompatibleDC (drawable)))  YERROR ("CreateCompDC");  
  //  if (!SelectObject (glob_hdcMemory, hbmp))                  YERROR ("YImageGet-2");  
  if (!SelectObject (hdc_pix, hbmp))                  YERROR ("YImageGet-2");  
 
  if (!BitBlt (hdc_pix, 0, 0, w+1, h+1, drawable,  x, y, SRCCOPY))   
    YERROR ("YImageGet-3");  
  return ((LONG) hbmp);  
#endif  
}  
/*-------------------------------YImagePut----------------------------------*/  
void  
YImagePut (int x, int y, long pImage)  
{  
 
#ifdef Y_UNIX  
  XImage *xim;  
  //  CALCXY (x, y);  
   
  if (mode_type != YM_PAINT) return; 
 
  xim = (XImage *) pImage;  
  XPutImage (dpy, /* win */drawable, gc, xim, 0, 0, x, y, xim->width, xim->height);  
  XFlush (dpy);  
 
#else   
  HBITMAP hbmp;  
  BITMAP  bmp;  
   
  if (mode_type != YM_PAINT) return; 
 
  hbmp = (HBITMAP) pImage;  
  if (!GetObject (hbmp, sizeof (BITMAP), &bmp))    YERROR ("YImagePut-1");  
  if (!BitBlt (drawable, x, y, bmp.bmWidth, bmp.bmHeight, hdc_pix, 0, 0, SRCCOPY))  
    YERROR ("YImagePut-2");  
#endif  
}  
/*----------------------------YMakeImage----------------------------------*/  
/* long   */
/* YMakeImage (int wreal, int hreal)   */
/* {   */
/* #ifdef Y_UNIX   */
/*   return ((long)XGetImage (dpy, win, 10, 10, wreal, hreal, AllPlanes, ZPixmap));   */
/* #else    */
/*   return (0);  */
/* #endif   */
/* }    */
/*---------------------------YWinW---------------------------------*/ 
int 
YWinW (int id) 
{ 
#ifdef Y_UNIX  
  XWindowAttributes w_a; 

  XGetWindowAttributes (dpy, /* win */BIGI(id)->hwnd, &w_a); 
  return (w_a.width); 
 
#else /*-------------------------*/   
  RECT rect; 
 
  GetClientRect((HWND)(BIGI(id)->hwnd), (LPRECT)&rect); 
  return (rect.right); 
 
#endif 
} 
/*---------------------------YWinH---------------------------------*/  
int  
YWinH (int id)  
{  
#ifdef Y_UNIX   
  XWindowAttributes w_a;  
 
  XGetWindowAttributes (dpy, /* win */BIGI(id)->hwnd, &w_a);  
  return (w_a.height);  
  
#else /*-------------------------*/    
  RECT rect;  
  
  GetClientRect((HWND)(BIGI(id)->hwnd), (LPRECT)&rect);  
  return (rect.bottom);  
  
#endif  
}  
/*---------------------------YWinR---------------------------------*/  
int  
YWinR (int id)  
{  
#ifdef Y_UNIX   
  XWindowAttributes w_a;  
  Window parent; 
 
  XGetWindowAttributes (dpy, BIGI(id)->hwnd, &w_a);  
 
  parent = w_a.root;  
  return (YHwndToId((long)parent));  
  
#else /*-------------------------*/    
  HWND parent; 
 
  parent = GetParent ((HWND)(BIGI(id)->hwnd)); 
 
  return (YHwndToId((long)parent));  
  
#endif  
}  
/*---------------------------YWinP---------------------------------*/  
int  
YWinP (int id)  
{  

  return (BIGI(id)->parent);  

}  
/*------------------------YCreatePixmap----------------------------*/ 
long  
YCreatePixmap (int id) 
{ 
#ifdef Y_UNIX 
  Pixmap pix; 
  long window = BIGI(id)->hwnd;
 
  SC w = YWinW (id); 
  SC h = YWinH (id); 
 
  /* 	pix = XCreatePixmap(dpy, window, w_glob, h_glob, depth);  */
  pix = XCreatePixmap(dpy, window, w, h, depth); 
 
  return ((long)pix); 
 
#else /*-------------------------*/  
  static HBITMAP hbmp;  
  SC  x, y, w, h; 
  HDC hdc; 
  long window = BIGI(id)->hwnd;
 
  x = 0; y = 0; 
  /*   w = w_glob;  */
  /*   h = h_glob;  */
  w = YWinW (id); 
  h = YWinH (id); 
 
  hdc = GetDC ((HWND)window); 
  //SetBkMode (hdc, TRANSPARENT);  
  if (!(hdc_pix = CreateCompatibleDC (hdc)))  YERROR ("CreateCompDC");  
  
 
  if (!(hbmp = CreateCompatibleBitmap (hdc_pix, w+1, h+1))) YERROR ("YImageGet-1");  
  if (!SelectObject (hdc_pix, hbmp))    YERROR ("YImageGet-2");  
 
  ReleaseDC ((HWND)window, hdc);  
  return ((LONG) hbmp);  
#endif 
} 
/*---------------------------------YCopyPixmaps----------------------------*/  
void   
YCopyPixmaps (long from, long to, SC w, SC h)  
{  
#ifdef Y_UNIX  
  
  /* 	XCopyArea(dpy, from, to, gc, 0, 0, w_glob, h_glob, 0, 0);   */
  XCopyArea(dpy, from, to, gc, 0, 0, w, h, 0, 0);  
  
#else /*-------------------------*/    
#endif  
}  
/*---------------------------------YPixToWin----------------------------*/  
void   
YPixToWin (long pix, int id)  
{  
#ifdef Y_UNIX  
  long win = BIGI(id)->hwnd;
  
  /* 	XCopyArea(dpy, pix, win, gc, 0, 0, w_glob, h_glob, 0, 0);   */
  XCopyArea(dpy, pix, win, gc, 0, 0, YWinW(id), YWinH(id), 0, 0);  
  
#else /*-------------------------*/    
  HBITMAP hbmp = (HBITMAP) pix;  
  BITMAP  bmp;  
  int x= 0, y= 0, w, h; 
  HDC hdc_win;  
  long win = BIGI(id)->hwnd;
 
  GetObject (hbmp, sizeof (BITMAP), &bmp);  
  w = bmp.bmWidth; 
  h = bmp.bmHeight; 
 
  hdc_win = GetDC ((HWND)win);  
  //hdc_win = drawable;  
  BitBlt (hdc_win, x,y,w,h, hdc_pix, 0,0, SRCCOPY);  
  ReleaseDC ((HWND)win, hdc_win); 
#endif  
}  
/*------------------------------YSetWindowPixmap-----------------------------*/ 
void  
YSetWindowPixmap (int id, long pix) 
{ 
#ifdef Y_UNIX 
  long window = BIGI(id)->hwnd;
 
  XSetWindowBackgroundPixmap (dpy, window, pix); 
 
#else /*-------------------------*/  
 
#endif 
} 
/*------------------------------YBeginPaint-----------------------------*/   
void    
YBeginPaint (long d, int type)   
{   
#ifdef Y_UNIX   
   
  drawable = (Drawable) d;   
   
#else /*-------------------------*/    
  
  if (type == YWIN)  
    drawable = GetDC ((HWND)d);    
  
  if (type == YPIX)   
    drawable = hdc_pix;    
  
#endif   
}   
/*------------------------------YEndPaint-----------------------------*/  
void   
YEndPaint (long d, int type)  
{  
#ifdef Y_UNIX  
  
#else /*-------------------------*/    
  
  if (type == YWIN)  
    ReleaseDC ((HWND)d, drawable); 
  
#endif  
}  
/*--------------------------------YModePaint--------------------------------*/ 
void 
YModePaint (YT_BOOL flag) 
{ 
  static int mode_old[200]; 
  static int cur = 0; 
 
  if (flag) { 
    mode_old[cur++] = mode_type; 
    mode_type = YM_PAINT; 
  } else { 
    mode_type = mode_old[--cur]; 
  } 
 
  return; 
} 
/*------------------------------YWinBegPaint-----------------------------*/   
void    
YWinBegPaint (int id)   
{   
#ifdef Y_UNIX   
  drawable = (Drawable)(BIGI(id)->hwnd);   
  YModePaint (TRUE);
#else /*-------------------------*/    
  drawable = GetDC ((HWND)(BIGI(id)->hwnd));  
  YModePaint (TRUE);
#endif   
}   
/*------------------------------YWinEndPaint-----------------------------*/  
void   
YWinEndPaint (int id)  
{  
#ifdef Y_UNIX  
  YModePaint (FALSE); 
#else /*-------------------------*/    
  YModePaint (FALSE); 
  ReleaseDC (((HWND)(BIGI(id)->hwnd)), drawable); 
#endif  
}  
/*----------------------------------YQuit-----------------------------------*/ 
void 
YQuit () 
{ 
	 
  yquit_flag = TRUE;  

#ifdef Y_UNIX  
#else  
  PostQuitMessage(0);  
#endif 
 
}  
/*-----------------------------YImageSet---------------------------------*/ 
void 
YImageSet (long img) 
{ 

#ifdef Y_UNIX  
  static Drawable old_drawable;  

  if (img) { 
    old_drawable = drawable; 
    drawable = img; 
  } else { 
    drawable = old_drawable;   
  } 
#else  
  static HDC old_drawable; 
 
  if (img) { 
    old_drawable = drawable; 
    drawable = hdc_pix; 
  } else { 
    drawable = old_drawable;   
  } 
#endif 
 
}
/*--------------------------------YWinMapGet--------------------------------*/
long
YWinMapGet (int id)
{

#ifdef Y_UNIX  
  /*   long win = BIGI(id)->hwnd; */
  /* 	return (YCreatePixmap (win)); */
  return (YCreatePixmap (id));
#else  
  /* 	return (YImageGet (0, 0, w_glob-1, h_glob-1)); */
  return (YImageGet (0, 0, YWinW(id)-1, YWinH(id)-1));
#endif 

}
/*--------------------------------YWinMapPut--------------------------------*/
void
YWinMapPut (int id, long map)
{

#ifdef Y_UNIX  
  /* 	YPixToWin (map, win);  */
  YPixToWin (map, id); 
#else  
  YImagePut (0, 0, map);
#endif 

}
/*--------------------------------YWinMapSet--------------------------------*/
void
YWinMapSet (long map)
{

#ifdef Y_UNIX  
  YImageSet (map);
#else  
  YImageSet (map);
#endif 

}
/*----------------------------------YPauseSoft-------------------------------*/ 
YT_BOOL 
YPauseSoft (int num) 
{ 
  static int i, j; 
  static int numer; 
 
  if (num) { 
    numer = num; 
    i = 0; 
    j = 0; 
    //printf ("%d %d %d \n", i, j, numer); 
    return FALSE; 
  } 
 
  j++; 
  if (j == numer) { 
    j = 0; 
    i++; 
    if (i == numer) 
      return FALSE; 
  } 
 
  //printf ("%d %d \n", i, j); 
 
  return TRUE; 
} 
/*----------------------------------YPauseHard-------------------------------*/ 
void 
YPauseHard (int num) 
{ 
  int i, j; 
 
  for (i=0; i<num; i++)  
    for (j=0; j<num; j++) {  
      ;;; 
    } 
 
  return; 
} 
/*-----------------------------------YGoto-----------------------------------*/ 
long 
YGoto (int message, int mes1, int mes2, long mes3, long mes4) 
{ 
  YT_PFUNC proc; 
  int  id   = ID_LAST; 
  int  from = ID_NULL; 
 
  proc = BIGI(id)->proc; 
 
  return (CALL (proc, id, from, message, mes1, mes2, mes3, mes4)); 
} 
/*-------------------------------YSendFrom----------------------------------*/ 
long 
YSendFrom (int id, int from, int message, int mes1, int mes2, long mes3, long mes4) 
{ 
  long    ret; 
  int     old_id_last; 
  YT_PFUNC proc; 
 
  proc = BIGI(id)->proc;   
 
  old_id_last = ID_LAST; 
  ID_LAST = id; 
  ret = CALL (proc, id, from, message, mes1, mes2, mes3, mes4); 
  ID_LAST = old_id_last; 
  
  return (ret); 
} 
/*----------------------------------YSend----------------------------------*/ 
long  
YSend (int id, int message, int mes1, int mes2, long mes3, long mes4) 
{ 
  int from = ID_LAST; 
 
  return (YSendFrom (id, from, message, mes1, mes2, mes3, mes4)); 
 
 
} 
/*-------------------------------YAddWindow------------------------*/
int
YAddWindow (long hwnd, YT_PFUNC proc)
{
  int i;

  for (i = 0; i < BIGWND_NUM; i++) 
    if (bigwnds[i] == NULL) 
      break; 
  if (i == BIGWND_NUM)  YERROR ("YAddNewWindow"); 
 
  bigwnds[i] = (YT_BIGWND *) malloc (sizeof (YT_BIGWND));
  BIGI(i)->hwnd = hwnd; 
  BIGI(i)->proc = proc; 

  return (i);
}
/*-------------------------------YHwndToId------------------------*/
int
YHwndToId (long hwnd)
{
  int i;

  for (i = 0; i < BIGWND_NUM; i++) {
    if (bigwnds[i] == NULL) continue;
    if (hwnd == BIGI(i)->hwnd)
      return (i);
  }
  if (i == BIGWND_NUM)  YERROR ("YFindProc"); 
 
  return (ID_NULL); 
} 
/*--------------------------------------------------------------------------*/
#ifdef Y_UNIX 
#else 
// ========================================================================== 
LRESULT CALLBACK  
WndProc(HWND hwnd, UINT msg, WPARAM wParam, LPARAM lParam) 
{ 
  // Выполняем обработку сообщений. Идентификатор 
  // сообщения передается через параметр msg  
  PAINTSTRUCT ps;      // структура для рисования 
  int id=0, from=0;  
  //int mode_type_old;

  //id   = YHwndToId ((long)hwnd);
  from = ID_NULL;
   
  //is_mymessage = TRUE;
  
  switch (msg) { 
  case WM_LBUTTONDOWN:  
    //CALL (DITTO, id,from, YLMOUSEDOWN, 0,0,0,0);  
    id = YHwndToId ((long)hwnd); 
    YSendFrom (id,from, YLMOUSEDOWN, 0,0,0,0);  
    return 0;  
  case WM_RBUTTONDOWN:  
    id = YHwndToId ((long)hwnd); 
    YSendFrom (id,from, YRMOUSEDOWN, 0,0,0,0); 
    return 0;  
  case WM_LBUTTONUP:  
    id = YHwndToId ((long)hwnd); 
    YSendFrom (id,from, YLMOUSEUP, 0,0,0,0); 
    return 0;  
  case WM_RBUTTONUP:  
    id = YHwndToId ((long)hwnd); 
    YSendFrom (id,from, YRMOUSEUP, 0,0,0,0); 
    return 0;  
  case WM_PAINT: 
    id = YHwndToId ((long)hwnd); 
    // Получаем индекс контекста устройства 
    glob_hdc = BeginPaint(hwnd, &ps);  
    drawable = glob_hdc; 
    //mode_type_old = mode_type; 
    //mode_type = YM_PAINT;
    YModePaint (TRUE); 
    YSendFrom (id,from, YM_PAINT, 0,0,0,0); 
    YModePaint (FALSE); 
    //mode_type = mode_type_old;
    // Отдаем индекс контекста устройства 
    EndPaint(hwnd, &ps);  
    return 0; 
    //case WM_CREATE:  
    //	id = YHwndToId ((long)hwnd);  
    //  YSendFrom (id,from, YM_CREATE, 0,0,0,0);  
    //  return 0;  
  case WM_DESTROY:  
    id = YHwndToId ((long)hwnd);  
    YSendFrom (id,from, YDESTROY, 0,0,0,0);  
    return 0;  
  }  

  // Все сообщения, которые не обрабатываются нашей 
  // функцией окна, ДОЛЖНЫ передаваться функции 
  // DefWindowProc 
  return DefWindowProc(hwnd, msg, wParam, lParam); 
} 
#endif 
/*----------------------------YSkipExpose-------------------------------*/ 
void 
YSkipExpose () 
{ 
#ifdef Y_UNIX 
  XEvent  event;  
  XRectangle rect;  
 
  while (1) { 
    if (!XCheckMaskEvent (dpy,  
			  ExposureMask | KeyPressMask | ButtonPressMask |  
			  ButtonReleaseMask | ButtonMotionMask,  
			  &event))  
      continue;  

    if ((event.type==Expose) && (event.xexpose.count == 0))  
      break;  

    /*     rect.x      = (short) event.xexpose.x;   */
    /*     rect.y      = (short) event.xexpose.y;   */
    /*     rect.width  = (unsigned short) event.xexpose.width;   */
    /*     rect.height = (unsigned short) event.xexpose.height;  		  */
    /*   	XUnionRectWithRegion (&rect, reg, reg);   */
  } 
 
  return; 
#else /*-------------------------*/  
 
#endif 
} 
/*----------------------------YCheckEvents-----------------------------*/  
void  
YCheckEvents ()  
{  
#ifdef Y_UNIX 
  XEvent  event;  
  char *name_mes;  
  XRectangle rect;  
  int id=0, from=0;
  long window;
  Region reg;
 
  if (!XCheckMaskEvent (dpy,  
			ExposureMask | KeyPressMask | ButtonPressMask |  
			ButtonReleaseMask | ButtonMotionMask,  
			&event))  
    return;  
  
  window = (long)event.xany.window;
  id   = YHwndToId (window);
  from = ID_NULL;

  switch (event.type) {  
  case ButtonPress:  
    if (event.xbutton.button == Button1)  {YSendFrom (id,from, YLMOUSEDOWN, 0,0,0,0); }  
    else                                  {YSendFrom (id,from, YRMOUSEDOWN, 0,0,0,0); }  
    break;  
  case ButtonRelease:  
    if (event.xbutton.button == Button1)  {YSendFrom (id,from, YLMOUSEUP, 0,0,0,0); }  
    else                                  {YSendFrom (id,from, YRMOUSEUP, 0,0,0,0); }  
    break;  
  case Expose:  
    /* YSkipExpose ();  */

    rect.x      = (short) event.xexpose.x;  
    rect.y      = (short) event.xexpose.y;  
    rect.width  = (unsigned short) event.xexpose.width;  
    rect.height = (unsigned short) event.xexpose.height;  
    reg = (Region)(BIGI(id)->reg);
    /* XUnionRectWithRegion (&rect, reg, reg);  */ 
		 
    if (event.xexpose.count == 0) {  
      /* 			XSetRegion (dpy, gc, reg);   */

      drawable = window; 
      YModePaint (TRUE); 
      YSendFrom (id,from, YM_PAINT, 0,0,0,0); 
      YModePaint (FALSE); 
    }  
    break; 
  default: ;; 
  } 
	  
  return; 
#else /*-------------------------*/  
  MSG  msg;   
   
  if (PeekMessage (&msg, NULL, 0, 0, PM_REMOVE)) {  
    TranslateMessage (&msg);  
    DispatchMessage (&msg);  
  }  
  return;  
   
#endif 
}  
/*--------------------------------YBig------------------------*/   
YT_BOOL   
YBig (int *pid, YT_PFUNC proc, char *wname, SC x, SC y, SC w, SC h)   
{  
  YT_BOOL ret; 
  
  /* printf ("YBig: mode_type=%d \n", mode_type); */ 
 
  bigwindow = TRUE;   
  ret = YWin (pid, proc, wname, x, y, w, h);   
  //bigwindow = FALSE;   
 
  return (ret); 
} 
/*----------------------------------YWin-----------------------------*/   
YT_BOOL   
YWin (int *pid, YT_PFUNC proc, char *wname,
      int x, int y, int w, int h)   
{
  
#ifdef Y_UNIX 
  XSetWindowAttributes attributes;  
  int id, parent;
  Window  win, rootwin;  
 
  if (mode_type == YM_PAINT) return FALSE;  
  /* 	if (*pid != ID_NULL) return FALSE; */

  attributes.backing_store = Always;   
  parent = ID_LAST;

  if (bigwindow || (parent == ID_ROOT)) { 
    rootwin = RootWindow (dpy, scr); 
    bigwindow = FALSE;   
  } else {
    /* if (parent == ID_ROOT) YERROR ("YWin"); */
    rootwin = (Window)(BIGI(parent)->hwnd); 
  }
 
  if (x == SC_DEF) x = 0; 
  if (y == SC_DEF) y = 0; 
  if (w == SC_DEF) w = 0; 
  if (h == SC_DEF) h = 0; 
  
  win = XCreateWindow (dpy, rootwin,  
		       x, y, w, h,  
		       1, CopyFromParent, InputOutput, CopyFromParent,  
		       CWBackingStore, &attributes);

  id = YAddWindow ((long)win, proc);
  BIGI(id)->parent = parent;
  YSendFrom (id,ID_NULL, YM_CREATE, 0,0,0,0);  
    
  XStoreName (dpy, win, wname);  
  XMapWindow (dpy, win);  
  
  XSelectInput (dpy, win, ExposureMask | KeyPressMask |  
		ButtonPressMask | ButtonReleaseMask | ButtonMotionMask  
		| PointerMotionHintMask);  
  
  /* reg = XCreateRegion ();  */
 
  /* YSkipExpose ();   */

  drawable = win;  
  YModePaint (TRUE); 
  YSendFrom (YHwndToId((long)win),ID_NULL, YM_PAINT, 0,0,0,0);  
  YModePaint (FALSE); 
 
  *pid = id; 
  return (TRUE);  
 
#else /*-------------------------*/ 
  HWND hwnd;  // идентификатор главного окна приложения  
  int id, parent;
  DWORD dwStyle; 
  HWND hWndParent; 
  //SC  x, y;  
  //int mode_type_old;

 
  if (mode_type == YM_PAINT) return FALSE;  
  /* 	if (*pid != ID_NULL) return FALSE; */ 
 
  parent = ID_LAST;

  if (parent == ID_ROOT)  hWndParent = 0; 
  else                    hWndParent = (HWND)(BIGI(parent)->hwnd); 
 
  if (bigwindow) { 
    dwStyle = WS_OVERLAPPEDWINDOW; 
    bigwindow = FALSE;   
  } else  
    dwStyle = WS_CHILDWINDOW | WS_VISIBLE; 
 
  if (x == SC_DEF) x = CW_USEDEFAULT; 
  if (y == SC_DEF) y = CW_USEDEFAULT; 
  if (w == SC_DEF) w = CW_USEDEFAULT; 
  if (h == SC_DEF) h = CW_USEDEFAULT; 
  
  hwnd = CreateWindow( 
		      szClassName, // имя класса окна 
		      wname,       // заголовок окна 
		      dwStyle,     // стиль окна 
		      x,        
		      y,       
		      w, 
		      h, 
		      hWndParent,          // идентификатор родительского окна 
		      0,                   // идентификатор меню 
		      glob_hInstance,      // идентификатор приложения 
		      NULL);               // указатель на дополнительные 
  // параметры 
  // Если создать окно не удалось, завершаем приложение 
  if(!hwnd) 
    return (0); 
 
  id = YAddWindow ((long)hwnd, proc);
  BIGI(id)->parent = parent;

  //  mode_type_old = mode_type;  
  //  mode_type = YM_CREATE;  
  YSendFrom (id,ID_NULL, YM_CREATE, 0,0,0,0);  
  //  mode_type = mode_type_old;  
 
  if (!(glob_hdc = GetDC (hwnd)))  YERROR ("GetDC");   
  if (!(glob_hdcMemory = GetDC (hwnd)))  YERROR ("GetDC-Memory");   
 
  // Рисуем окно. Для этого после функции ShowWindow, 
  // рисующей  окно, вызываем функцию UpdateWindows, 
  // посылающую сообщение WM_PAINT в функцию окна 
  ShowWindow(hwnd, glob_nCmdShow); 
  UpdateWindow(hwnd);  
 
  *pid = id;
  return (TRUE);  
#endif 
}   
// ======================================================================== 
#ifdef Y_UNIX 
#else 
BOOL 
InitApp(HINSTANCE hInstance) 
{ 
  ATOM aWndClass; // атом для кода возврата 
  WNDCLASS wc;    // структура для регистрации 
                  // класса окна 
  memset(&wc, 0, sizeof(wc)); 
  // Стиль окна 
  wc.style = 0; 
  // Указатель на функцию окна, обрабатывающую 
  // сообщения, предназначенные для всех окон, 
  // созданных на основе данного класса 
  wc.lpfnWndProc = (WNDPROC) WndProc; 
  // Размер дополнительной области данных, 
  // зарезервированной в описании класса окна 
  wc.cbClsExtra = 0; 
  // Размер дополнительной области данных, 
  // зарезервированной для каждого окна, 
  // созданного на основе данного класса 
  wc.cbWndExtra = 0; 
  // Идентификатор приложения, которое 
  // создало данный класс 
  wc.hInstance = hInstance; 
  // Идентификатор пиктограммы, используемой 
  // для окна данного класса 
  wc.hIcon = LoadIcon(NULL, IDI_APPLICATION); 
  // Идентификатор курсора, используемого 
  // для окна данного класса 
  wc.hCursor = LoadCursor(NULL, IDC_ARROW); 
  // Цвет фона окна 
  wc.hbrBackground = (HBRUSH)(COLOR_WINDOW + 1); 
  // Идентификатор меню 
  wc.lpszMenuName = (LPSTR)NULL; 
  // Имя, которое присваивается создаваемому 
  // классу и используется при создании 
  // окон данного класса 
  wc.lpszClassName = (LPSTR)szClassName; 
 
 
  // Регистрация класса 
  aWndClass = RegisterClass(&wc); 
  // Возвращаем результат регистрации класса 
  return (aWndClass != 0); 
} 
#endif 
//*-----------------------------YInitDisplay------------------------------*/  
YT_BOOL  
YInitDisplay ()  
{  
#ifdef Y_UNIX 
  XGCValues gcvals; 
  
  dpy   = XOpenDisplay (NULL);  
  scr   = DefaultScreen (dpy);  
  root  = DefaultRootWindow(dpy); 
  depth = DefaultDepth(dpy,scr); 
  vis   = DefaultVisual(dpy,scr); 
  blk   = BlackPixel(dpy,scr); 
  wht   = WhitePixel(dpy,scr); 
  cmap  = DefaultColormap (dpy, scr);  
  gc    = XCreateGC (dpy,root,(unsigned long)0,&gcvals); 
 
  wdisplay_pix = DisplayWidth (dpy, scr);  
  hdisplay_pix = DisplayHeight (dpy, scr);  
  wdisplay_mm = DisplayWidthMM (dpy, scr); 
  hdisplay_mm = DisplayHeightMM (dpy, scr); 
  /* printf ("%f %f \n" , wdisplay_mm, hdisplay_mm); */
  xpix_per_mm = wdisplay_pix / wdisplay_mm;
  ypix_per_mm = wdisplay_pix / wdisplay_mm;
  
  return TRUE;  
#else /*-------------------------*/ 
  //  static WNDCLASS wc;   
  //  wc.style = 0;  
  //  wc.lpfnWndProc = MainWndProc;  
  //  wc.cbClsExtra = 0;  
  //  wc.cbWndExtra = 0;  
  //  wc.hInstance = hInstance;  
  //  if (!(wc.hIcon = LoadIcon (NULL, IDI_APPLICATION)))      YERROR ("LoadIcon");  
  //  if (!(wc.hCursor = LoadCursor (NULL, IDC_ARROW)))        YERROR ("LoadCursor");  
  //  if (!(wc.hbrBackground = GetStockObject (WHITE_BRUSH)))  YERROR ("Background");  
  //  wc.lpszMenuName = NULL;  
  //  wc.lpszClassName = (LPSTR)szClassName;  
  //  if (!hPrevInstance)  
  //    if (!RegisterClass (&wc))  
  //      YERROR ("RegisterClass");  
  HDC root_hdc ;
  //int w_pi, h_pi, w_mm, h_mm; 
  //float mm_in_inch = 25.4; 

  // Проверяем, не запускалось ли это приложение ранее  
  if(glob_hPrevInstance) 
    { 
      MessageBox(NULL, 
		 "Можно запускать только одну копию приложения", 
		 "Ошибка", MB_OK | MB_ICONSTOP); 
      return FALSE; 
    } 
  else 
    { 
      // Если не запускалось, вызываем функцию InitApp 
      // для инициализации приложения. 
      // Если инициализацию выполнить не удалось, 
      // завершаем приложение 
      if(!InitApp(glob_hInstance)) 
	return FALSE; 
    }  
 
  wdisplay_pix = GetSystemMetrics(SM_CXSCREEN);  
  hdisplay_pix = GetSystemMetrics(SM_CYSCREEN);  
  
  root_hdc = GetDC (0); 
  /*   printf ("HORZRES=%d  VERTRES=%d \n",   */
  /*     GetDeviceCaps(root_hdc, HORZRES), GetDeviceCaps(root_hdc, VERTRES));  */
  /*   printf ("HORZSIZE=%d  VERTSIZE=%d \n",   */
  /*     GetDeviceCaps(root_hdc, HORZSIZE), GetDeviceCaps(root_hdc, VERTSIZE));  */
  x_pix_in_inch = GetDeviceCaps(root_hdc, LOGPIXELSX); 
  y_pix_in_inch = GetDeviceCaps(root_hdc, LOGPIXELSY); 
  /* printf ("LOGPIXELSX=%d  LOGPIXELSY=%d \n", x_pix_in_inch, y_pix_in_inch);  */ 
  xpix_per_mm = (double) x_pix_in_inch / 25.4; 
  ypix_per_mm = (double) y_pix_in_inch / 25.4;  
  ReleaseDC (0, root_hdc); 
 
  //SystemParametersInfo(SPI_GETWORKAREA );  
 
  //BOOL SystemParametersInfo( 
  //  UINT uiAction,  // system parameter to retrieve or set 
  //  UINT uiParam,   // depends on action to be taken 
  //  PVOID pvParam,  // depends on action to be taken 
  //  UINT fWinIni    // user profile update option 
  //); 

  return TRUE; 
#endif 
}  
/*---------------------------------YInit---------------------------------*/
void
YInit ()
{  
  int i; 

  YInitDisplay (); 
  
  yquit_flag = FALSE;  
 
  for (i = 0; i < BIGWND_NUM; i++)  
    bigwnds[i] = NULL;  
 
  ID_LAST = ID_ROOT; 
  bigwindow = FALSE; 
  mode_type = YNONE;

  /*   printf ("wdisplay_pix=%d \n", wdisplay_pix);  */
  /*   printf ("hdisplay_pix=%d \n", hdisplay_pix);  */

  return;
}  
/*************************************************************************/  
#ifdef Y_UNIX  
/*************************************************************************/  
int  
main (int argc, char *argv[])  
{   
 
  return (MAIN(argc, argv)); 
 
}  
#else 
// ======================================================================= 
// Функция WinMain 
// Получает управление при запуске 
// приложения 
// ======================================================================= 
//#pragma argsused 
int PASCAL 
WinMain(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpszCmdLine,   
	int nCmdShow)                                     
{ 
  int     argc, i;   
  static char *argv[10] = {"svisor"};  
  static char cmdline[250];  
  
  glob_hInstance = hInstance;  
  glob_hPrevInstance = hPrevInstance;  
  glob_lpszCmdLine = lpszCmdLine;  
  glob_nCmdShow = nCmdShow;  
 
#ifndef Y_NODEBUG 
#define Y_DEBUG 
#endif 
#ifdef Y_DEBUG 
  /* 
   * If we are using compiling in debug mode, open a console window so 
   * we can see any printf's, etc... 
   */ 
  
  AllocConsole(); 
  freopen("conin$", "r", stdin); 
  freopen("conout$", "w", stdout); 
  freopen("conout$", "w", stderr); 
 
#endif /* Y_DEBUG */ 
 
  strcpy (cmdline, lpszCmdLine);  
  argv[1] = strtok (cmdline, " ");  
  for (i = 2; i < 10; i++)  
    if (!(argv[i] = strtok (NULL, " ")))  
      break;  
  argc = i;  
  
  return (MAIN(argc, argv)); 
 
} 
/*************************************************************************/ 
#endif 
//------------------------------------------------------------------------- 
