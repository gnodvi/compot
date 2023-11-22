// -*-  mode: c    ; coding: koi8   -*- ----------------------------------------

/**************************************************************************** 
 *                                                                          * 
 *  kernel.c  --  "Library Yzone" (main file);                              * 
 *                                                                          * 
 *  Copyright (c) 2000, Life Software.                                      * 
 *                                                                          * 
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
 
#include "yma-kernel.h" 
 
 
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

XFontStruct *font_struct; 
Font         font; 
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
Int    wdisplay_pix, hdisplay_pix;  
float  wdisplay_mm, hdisplay_mm;  
double xpix_per_mm, ypix_per_mm;
Int    x_pix_in_inch, y_pix_in_inch;
int    id_last; 
int    mode_type;
int    orig_x0, orig_y0;
YT_BOOL   wndgroup_flag; 
int       wndgroup_first; 
int       wndgroup_last; 
char    *yswitch;
YT_BOOL  in_case;

#define BIGWND_NUM 20 
YT_BIGWND *bigwnds[BIGWND_NUM];  
 
typedef struct { 
  char   *name; 
  int     r, g, b; 
} YT_DEFCOLOR; 
void     YDefColors (YT_DEFCOLOR*); 
 
typedef struct { 
  YT_BOOL exist; 
  char    name[30];  
  int     r, g, b; 
  YT_COLOR color; 
} YT_COLER; 
YT_COLER   globcoller[SIZE_COLER]; 

typedef struct { 
  int     id; 
  int     message; 
} YT_PROCESS; 
YT_PROCESS   process; 

typedef struct { 
  int     id; 
  long    start; 
  long    delta; 
} YT_TIMER; 
#define YTIMER_MAX 20
YT_TIMER   timer[YTIMER_MAX]; 

/*----------------------------------YBeep----------------------------------*/ 
void 
YBeep () 
{ 
  fprintf (stderr, "\a"); 
} 
/*---------------------------------YWarning--------------------------------*/ 
void 
YWarning (char *string) 
{ 
 
  printf  ("%s : %s \n", "YWarning: ", string);  
 
} 
/*---------------------------------YError----------------------------------*/ 
void 
YError (char *string) 
{ 
 
  YBeep (); 
  printf  ("%s : %s \n", "YError: ", string);  
  exit (EXIT_FAILURE); 

} 
/*------------------------------YPaintPixel--------------------------------*/  
void  
YPaintPixel (Int x, Int y, YT_COLOR color)  
{  
#ifdef Y_UNIX  
  XSetForeground (dpy, gc, color);  
  XDrawPoint (dpy, drawable, gc, x, y);  
#else   
  SetPixel (drawable, x, y, color);  
#endif  
  
}  
/*-----------------------------YDrawLine-----------------------------------*/   
void   
YDrawLine (Int x1, Int y1, Int x2, Int y2, YT_COLOR color)   
{   
#ifdef Y_UNIX  
   
/* 	if (mode_type != YDRAW) return;  */
  
  XSetForeground (dpy, gc, color);   
  XDrawLine (dpy, drawable, gc, x1, y1, x2, y2);   
   
#else /*-------------------------*/   
  Int   x0 = 0, y0 = 0;  
  HPEN  hpen, hpenOld;   
   
/*   if (mode_type != YDRAW) return;  */
  
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
/*-------------------------------YDrawRectF--------------------------------*/   
void   
YDrawRectF (Int x, Int y, Int w, Int h, YT_COLOR color)   
{   
#ifdef Y_UNIX  
   
/*   if (mode_type != YDRAW) return;  */
  
  XSetForeground (dpy, gc, color);   
  XFillRectangle (dpy, drawable, gc, x, y, w, h);   
  
#else /*-------------------------*/   
  HBRUSH    hbr, hbrOld;   
  RECT      rect;   
  
/*   if (mode_type != YDRAW) return;  */
   
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
YDrawRectB (Int x, Int y, Int w, Int h, YT_COLOR color)  
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
YDrawRectFB (Int x, Int y, Int width, Int height, YT_COLOR fcolor, YT_COLOR lcolor)  
{  
  YDrawRectF (x, y, width, height, fcolor);  
  YDrawRectB (x, y, width, height, lcolor);  
  return;  
}  
/*------------------------------YDrawCircF----------------------------------*/ 
void 
YDrawCircF (Int cx, Int cy, Int r, YT_COLOR f_color) 
{ 
  return; 
} 
/*------------------------------YDrawCircB---------------------------------*/  
void  
YDrawCircB (Int cx, Int cy, Int r, YT_COLOR bcolor)  
{  
 
#ifdef Y_UNIX   
  Int x, y, w, h; 
  int ang_begin, ang_delta;
      
  /*   if (mode_type != YDRAW) return;  */
 
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
   
  /*   if (mode_type != YDRAW) return;  */
   
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
YDrawCircFB (Int cx, Int cy, Int r, YT_COLOR fcolor, YT_COLOR bcolor)  
{  
 
#ifdef Y_UNIX   
  int x, y, w, h, ang_begin, ang_delta;
   
  /*   if (mode_type != YDRAW) return;  */
   
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
   
  /*   if (mode_type != YDRAW) return;  */
   
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
   
  /*   if (mode_type != YDRAW) return;  */
  
  XSetForeground(dpy, gc, fcolor);  
  XFillPolygon(dpy, drawable, gc, (XPoint*)pts, numpoints, Nonconvex, CoordModeOrigin);  
   
#else /*---------------------*/   
#define MAX_PNTS 8  
  int     i;  
  POINT   pnts[MAX_PNTS];  
  HPEN    hpen, hpenOld;   
  HBRUSH  hbr, hbrOld;   
   
  /*   if (mode_type != YDRAW) return;  */
  
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
   
/*   if (mode_type != YDRAW) return;  */
 
   
#else /*---------------------*/   
#define MAX_PNTS 8  
  int     i;  
  POINT   pnts[MAX_PNTS];  
  HPEN    hpen, hpenOld;   
   
/*   if (mode_type != YDRAW) return;  */
  
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
  return (XTextWidth (font_struct, string, strlen (string))); 
	/* return (8); */
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
  return ((font_struct)->ascent + (font_struct)->descent);  
	/* return (16); */
#else   
  SIZE    siz;  
  GetTextExtentPoint32 (drawable, string, lstrlen (string), &siz);  
  return (siz.cy);  
#endif  
}  
/*------------------------------YSetFont-----------------------------------*/ 
void 
YSetFont (char *name) 
{ 
#if defined(Y_UNIX) 
  if ((font_struct = XLoadQueryFont (dpy, name)) == NULL) 
    YError ("YSetFont"); 
 
  XSetFont (dpy, gc, (font_struct)->fid); 

#else  

#endif 
} 
/*-----------------------------YDrawStringImp------------------------------*/ 
void 
YDrawStringImp (char *text, Int x0, Int y0, YT_COLOR color, int horz, int vert) 
{ 
  Int     x, y, w, h; 
 
  w = YStringW (text); 
  h = YStringH (text); 
  /* ANTICALCWH (w, h); */ 
 
  if      (horz == YLEFT)  x = x0 - w; 
  else if (horz == YNONE)  x = x0 - w / 2; 
  else if (horz == YRIGHT) x = x0; 
  else 
    YError ("YDrawStringImp-1"); 
 
  if      (vert == YUP)    y = y0 - h / 2; 
  else if (vert == YNONE)  y = y0; 
  else if (vert == YDOWN)  y = y0 + h / 2; 
  else 
    YError ("YDrawStringImp-2"); 
 
  YDrawString (text, x, y, color); 
} 
/*-----------------------------YDrawRectText--------------------------------*/ 
void 
YDrawRectText (char *text, Int x, Int y, Int w, Int h, YT_COLOR color) 
{ 
 
  YDrawStringImp (text, x + w / 2, y + h / 2, color, YNONE, YNONE); 
  return; 
 
} 
/*-----------------------------YDrawString---------------------------------*/  
void  
YDrawString (char *text, Int x, Int y, YT_COLOR color)  
{  
  
#ifdef Y_UNIX  
   
/*   if (mode_type != YDRAW) return;  */
 
  y += 4; /*??!!!*/ 
  XSetForeground (dpy, gc, color);  
  XDrawString (dpy, drawable, gc, x, y, text, strlen (text));  
#else  
  int fonth = YStringH (text); 
   
/*   if (mode_type != YDRAW) return;  */
 
  SetTextColor (drawable, color);  
  TextOut (drawable, x, y-fonth/2, text, strlen (text));  
#endif  
}  
/*-------------------------------YDrawGroup---------------------------------*/ 
void 
YDrawGroup (char *sText, Int x, Int y, Int w, Int h, YT_COLOR color) 
{ 
  Int  w_char = YStringW ("W"); 
  Int  left = 10, dx = 5, dy = 4, xmax, ymax, xl, xr; 
  Int  wtext; 
  YT_COLOR clr_white = YColorRGB(WHITE); 
  YT_COLOR clr_black = YColorRGB(BLACK); 
 
  xmax = x+w-1; 
  ymax = y+h-1; 
 
  if (color != CLR_NULL) { 
    YDrawRectF (x+2, y+2+dy, w-4, h-4-dy, color);  
    YDrawRectF (x+2, y+2, left-2, dy, color);  
  } 
 
  xl = x+left; 
  YDrawLine (x,   y,   xl, y,   clr_black); 
  YDrawLine (x+1, y+1, xl, y+1, clr_white); 
 
  YDrawString (sText, xl+dx, y, clr_black); 
  wtext = YStringW (sText); 

  xr = xl+dx+wtext+dx; 
  if (color != CLR_NULL)  
    YDrawRectF (xr, y+2, xmax-2-xr+1, dy, color);  
 
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
/*------------------------------YSetOrigin--------------------------------*/ 
void 
YSetOrigin (int x0, int y0) 
{ 
  orig_x0 = x0; 
  orig_y0 = y0; 
  return; 
} 
/*------------------------------YGetOrigin--------------------------------*/ 
void 
YGetOrigin (int *x0, int *y0) 
{ 
  *x0 = orig_x0; 
  *y0 = orig_y0; 
  return; 
} 
/*-----------------------------YGroup----------------------------------*/ 
void 
YGroup (int numer, char *name, Int x, Int y, Int w, Int h, YT_COLOR color) 
{ 
  static int x0group[100], y0group[100];
  static int cur=0;
       
  if (numer == 1) {
    if (name != NULL)  
      YDrawGroup (name, x, y, w, h, color); 
     
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
YBeginGroup (char *name, Int x, Int y, Int w, Int h, YT_COLOR color) 
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
YDrawTriF (Int x1, Int y1, Int x2, Int y2, Int x3, Int y3, YT_COLOR fcolor)       
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
YDrawTriB (Int x1, Int y1, Int x2, Int y2, Int x3, Int y3, YT_COLOR color)  
{  
 
  YDrawLine (x1, y1, x2, y2, color);   
  YDrawLine (x2, y2, x3, y3, color);   
  YDrawLine (x3, y3, x1, y1, color);   
  
  return;                                                                         
}  
/*--------------------------------YDrawTriFB--------------------------------*/    
void                                                                              
YDrawTriFB (Int x1, Int y1, Int x2, Int y2, Int x3, Int y3, YT_COLOR fcolor,      
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
YImageGet (Int x, Int y, Int w, Int h)  
{  
 
#ifdef Y_UNIX  
  XImage *xim;  
//  CALCXY (x, y);  
//  CALCWH (w, h);  
   
  //if (mode_type != YDRAW) return; 
 
  xim = XGetImage (dpy, /* win */drawable, x, y, w+1, h+1, AllPlanes, ZPixmap);  
  XFlush (dpy); 
  
  return ((long)xim);  
#else   
  HBITMAP hbmp; 
   
  //if (mode_type != YDRAW) return; 
   
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
YImagePut (Int x, Int y, long pImage)  
{  
 
#ifdef Y_UNIX  
  XImage *xim;  
  //  CALCXY (x, y);  
   
  /*   if (mode_type != YDRAW) return;  */
 
  xim = (XImage *) pImage;  
  XPutImage (dpy, /* win */drawable, gc, xim, 0, 0, x, y, xim->width, xim->height);  
  XFlush (dpy);  
 
#else   
  HBITMAP hbmp;  
  BITMAP  bmp;  
   
/*   if (mode_type != YDRAW) return;  */
 
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
/*---------------------------YWinN---------------------------------*/  
char*  
YWinN (int id)  
{  
  return (BIGI(id)->name);  
}  
/*---------------------------YWinC---------------------------------*/  
YT_COLOR  
YWinC (int id)  
{  
  return (BIGI(id)->color);  
}  
/*------------------------YCreatePixmap----------------------------*/ 
long  
YCreatePixmap (int id) 
{ 
#ifdef Y_UNIX 
	Pixmap pix; 
	long window = BIGI(id)->hwnd;
 
  Int w = YWinW (id); 
  Int h = YWinH (id); 
 
/* 	pix = XCreatePixmap(dpy, window, w_glob, h_glob, depth);  */
	pix = XCreatePixmap(dpy, window, w, h, depth); 
 
	return ((long)pix); 
 
#else /*-------------------------*/  
  static HBITMAP hbmp;  
  Int  x, y, w, h; 
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
YCopyPixmaps (long from, long to, Int w, Int h)  
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
  Int x= 0, y= 0, w, h; 
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

  // XFlush
  
#else /*-------------------------*/    
  
  if (type == YWIN)  
  ReleaseDC ((HWND)d, drawable); 
  
#endif  
}  
/*--------------------------------YModeType--------------------------------*/ 
void 
YModeType (YT_BOOL flag, int type) 
{ 
  static int mode_old[200]; 
  static int cur = 0; 
 
  if (flag) { 
    mode_old[cur++] = mode_type; 
    /* mode_type = YDRAW; */ 
    mode_type = type; 
  } else { 
    mode_type = mode_old[--cur]; 
  } 
 
  return; 
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
    return FALSE; 
  } 
 
  j++; 
  if (j == numer) { 
    j = 0; 
    i++; 
    if (i == numer) 
      return FALSE; 
  } 
 
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
YGoto (int message, Mes mes1, Mes mes2, long mes3, long mes4) 
{ 
  YT_PFUNC proc; 
  int  id   = ID_LAST; 
  int  from = ID_NULL; 
 
  proc = BIGI(id)->proc; 
 
  return (CALL (proc, id, from, message, mes1, mes2, mes3, mes4)); 
} 
/*-------------------------------YSendFrom----------------------------------*/ 
long 
YSendFrom (int id, int from, int message, Mes mes1, Mes mes2, long mes3, long mes4) 
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
YSend (int id, int message, Mes mes1, Mes mes2, long mes3, long mes4) 
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
/*-------------------------------YDelWindow------------------------*/
void
YDelWindow (int id)
{

  if (id == ID_NULL) return; 
  if (!(bigwnds[id]))  return; 
 
	free (bigwnds[id]);
	bigwnds[id] = NULL;
	printf ("YDelWindow \n");

	return;
}
/*--------------------------------YWndDestroy-----------------------------*/   
void   
YWndDestroy (int id)   
{  

#ifdef Y_UNIX 
  XDestroyWindow (dpy, (Window)(BIGI(id)->hwnd));
	/* YDelWindow (id); */
#else
  DestroyWindow ((HWND)(BIGI(id)->hwnd));
  /* YDelWindow (id); */
#endif

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
/*------------------------------YWinBegPaint-----------------------------*/   
void    
YWinBegPaint (int id)   
{   
#ifdef Y_UNIX   
  drawable = (Drawable)(BIGI(id)->hwnd);   
  /* YModeType (TRUE, YDRAW); */
#else /*-------------------------*/    
  drawable = GetDC ((HWND)(BIGI(id)->hwnd));  
  /* YModeType (TRUE, YDRAW); */
#endif   
}   
/*------------------------------YWinEndPaint-----------------------------*/  
void   
YWinEndPaint (int id)  
{
  
#ifdef Y_UNIX  
  /* YModeType (FALSE, YDRAW);  */
#else /*-------------------------*/    
  /* YModeType (FALSE, YDRAW); */ 
  ReleaseDC (((HWND)(BIGI(id)->hwnd)), drawable); 
#endif
  
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
    /* YModeType (TRUE, YDRAW); */ 
    YSendFrom (id,from, YDRAW, 0,0,0,0); 
    /* YModeType (FALSE, YDRAW);  */
    // Отдаем индекс контекста устройства 
    EndPaint(hwnd, &ps);  
    return 0; 
  //case WM_CREATE:  
  //	id = YHwndToId ((long)hwnd);  
  //  YSendFrom (id,from, YOPEN, 0,0,0,0);  
  //  return 0;  
  case WM_DESTROY:  
  	id = YHwndToId ((long)hwnd);  
    YSendFrom (id,from, YCLOSE, 0,0,0,0);  
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
/*----------------------------YCheckSystem-----------------------------*/  
void  
YCheckSystem ()  
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
			ButtonReleaseMask | ButtonMotionMask| StructureNotifyMask

			/* KeyPressMask| KeyReleaseMask| ButtonPressMask| ButtonReleaseMask|  */
			/* EnterWindowMask| LeaveWindowMask| PointerMotionMask| PointerMotionHintMask| */
			/* Button1MotionMask| Button2MotionMask| Button3MotionMask| Button4MotionMask| Button5MotionMask|  */
			/* ButtonMotionMask| KeymapStateMask| ExposureMask| VisibilityChangeMask|  */
			/* StructureNotifyMask| ResizeRedirectMask| SubstructureNotifyMask| SubstructureRedirectMask| */
			/* FocusChangeMask| PropertyChangeMask| ColormapChangeMask| OwnerGrabButtonMask */
			, &event))  
    return;  
  
  window = (long)event.xany.window;
  id   = YHwndToId (window);
  from = ID_NULL;

  switch (event.type) { 
  case DestroyNotify:  
    /* printf ("DestroyNotify \n"); */
    YSendFrom (id,from, YCLOSE, 0,0,0,0);  
    break;  
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

      YWinBegPaint (id);   
      YSendFrom (id,from, YDRAW, 0,0,0,0); 
      YWinEndPaint (id);   
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
  
  printf ("YMA: YBig:     mode_type=%d \n", mode_type); 
 
  bigwindow = TRUE;   

  ret = YWin (pid, proc, wname, x, y, w, h); 
  
  //bigwindow = FALSE;   
 
  return (ret); 
} 
/*--------------------------------YBig_new------------------------*/   
YT_BOOL   
YBig_yma/* new */ (int *pid, YT_PFUNC proc, char *wname, Int x, Int y, Int w, Int h, 
          long w_long1, long w_long2, long w_long3, long w_long4, 
          YT_COLOR color)   
{  
  YT_BOOL ret; 
  
  printf ("YMA: YBig_new: mode_type=%d \n", mode_type); 
 
  bigwindow = TRUE;
  
  YModeType (TRUE, YOPEN); 

  ret = YWnd (pid, proc, wname, x, y, w, h, w_long1, w_long2, w_long3, w_long4, color);   

  YModeType (FALSE, YOPEN); 

  //bigwindow = FALSE;   
 
  return (ret); 
} 
/*----------------------------------YWnd-----------------------------*/   
YT_BOOL   
YWnd (int *pid, YT_PFUNC proc, char *wname, Int x, Int y, Int w, Int h, 
      long w_long1, long w_long2, long w_long3, long w_long4, YT_COLOR color)   
{
  

#ifdef Y_UNIX 

  XSetWindowAttributes attributes;  
  int id, parent;
  Window  win, rootwin;  
  Drawable  drawable_old;  
 
  if (mode_type != YOPEN) return FALSE;  
  /*   if (mode_type == YDRAW) return FALSE;   */
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
  
  CALCXY(x,y);

  win = XCreateWindow (dpy, rootwin,  
		       x, y, w, h,  
		       1, CopyFromParent, InputOutput, CopyFromParent,  
		       CWBackingStore, &attributes);

  id = YAddWindow ((long)win, proc);
  printf ("YWnd: YAddWindow: %s \n", wname);

  *pid = id; 
  BIGI(id)->parent = parent;
  BIGI(id)->name   = wname;
  BIGI(id)->color  = color;
  BIGI(id)->x  = x;
  BIGI(id)->y  = y;

  //------------------------------
  if (wndgroup_flag) { 
    if (wndgroup_last == ID_NULL)  wndgroup_first = id; 
    else                           BIGI(id)->id_goto = wndgroup_last; 
    wndgroup_last = id; 
  } else 
    BIGI(id)->id_goto = ID_NULL; 
  //------------------------------

  YSendFrom (id,ID_NULL, YOPEN, w_long1,w_long2,w_long3,w_long4);  
    
  XStoreName (dpy, win, wname);  
  XMapWindow (dpy, win);  
  
  XSelectInput (dpy, win, ExposureMask | KeyPressMask |  
		ButtonPressMask | ButtonReleaseMask | ButtonMotionMask  
		| PointerMotionHintMask | StructureNotifyMask);  
  
  /* XSelectInput (dpy, win, */
  /* KeyPressMask| KeyReleaseMask| ButtonPressMask| ButtonReleaseMask|  */
  /* EnterWindowMask| LeaveWindowMask| PointerMotionMask| PointerMotionHintMask| */
  /* Button1MotionMask| Button2MotionMask| Button3MotionMask| Button4MotionMask| Button5MotionMask|  */
  /* ButtonMotionMask| KeymapStateMask| ExposureMask| VisibilityChangeMask|  */
  /* StructureNotifyMask| ResizeRedirectMask| SubstructureNotifyMask| SubstructureRedirectMask| */
  /* FocusChangeMask| PropertyChangeMask| ColormapChangeMask| OwnerGrabButtonMask */
  /* 	   );   */
  
  /* reg = XCreateRegion ();  */
  /* 	YSkipExpose ();  */ 

  drawable_old = drawable;
  drawable = win;
  
  YModeType (TRUE, YOPEN); 
  YSendFrom (YHwndToId((long)win),ID_NULL, YDRAW, 0,0,0,0);  
  YModeType (FALSE, YOPEN);
  
  drawable = drawable_old;  
 
  return (TRUE);  
 
#else /*-------------------------*/
  
  HWND hwnd;  // идентификатор главного окна приложения  
  int id, parent;
  DWORD dwStyle; 
  HWND hWndParent; 
  //SC  x, y;  
  //int mode_type_old;

 
  if (mode_type != YOPEN) return FALSE;  
  /*   if (mode_type == YDRAW) return FALSE;   */
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
  *pid = id;
  BIGI(id)->parent = parent;

  //  mode_type_old = mode_type;  
  //  mode_type = YOPEN;  
  /*   YSendFrom (id,ID_NULL, YOPEN, 0,0,0,0);   */
  YSendFrom (id,ID_NULL, YOPEN, w_long1,w_long2,w_long3,w_long4);  
  //  mode_type = mode_type_old;  
 
  if (!(glob_hdc = GetDC (hwnd)))        YERROR ("GetDC");   
  if (!(glob_hdcMemory = GetDC (hwnd)))  YERROR ("GetDC-Memory");   
 
  // Рисуем окно. Для этого после функции ShowWindow, 
  // рисующей  окно, вызываем функцию UpdateWindows, 
  // посылающую сообщение WM_PAINT в функцию окна
  
  ShowWindow(hwnd, glob_nCmdShow); 
  YModeType (TRUE, YOPEN); 
  UpdateWindow(hwnd);  
  YModeType (FALSE, YOPEN); 
 
  return (TRUE);  
#endif 
}
//--------------------------------------------------------------------
// из ybo-kernel.c
//
// 
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
/*----------------------------------YWin-----------------------------*/   
YT_BOOL   
YWin (int *pid, YT_PFUNC proc, char *wname,
      int x, int y, int w, int h)   
{
  
  //printf ("YMA: YWin:  wname = %s \n", wname); 
 
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

  printf ("YMA: YWin:  win = %d, id = %d ... YSendFrom \n", win, id); 
 
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
  ATOM aWndClass; // atom dlq koda vozvrata 
  WNDCLASS wc;    // struktura dlq registracii
                  // klassa okna 
  memset(&wc, 0, sizeof(wc)); 
  // Stil' okna 
  wc.style = 0; 
  // Ukazatel' na funkciy okna, obrabat=vay]uy
  // soob]eniq, prednaznahenn=e dlq vsex okon
  // sozdann=x na osnove dannogo klassa
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

  YT_DEFCOLOR defcolors[] = { 
    { "black",       0,   0,   0},     { "green",     0, 128,   0}, 
		{ "silver",    192, 192, 192},     { "lime",      0, 255,   0}, 
    { "gray",      128, 128, 128},     { "olive",   128, 128,   0}, 
    { "white",     255, 255, 255},     { "yellow",  255, 255,   0}, 
    { "maroon",    128,   0,   0},     { "navy",      0,   0, 128}, 
    { "red",       255,   0,   0},     { "blue",      0,   0, 255}, 
    { "purple",    128,   0, 128},     { "teal",      0 ,128, 128}, 
    { "fuchsia",   255,   0, 255},     { "aqua",      0, 255, 255}, 
    {NULL} 
  }; 
 
  YInitDisplay (); 
  
  yquit_flag = FALSE;  
 
  for (i = 0; i < BIGWND_NUM; i++)  
    bigwnds[i] = NULL;  
 
  ID_LAST = ID_ROOT; 
  bigwindow = FALSE; 
  mode_type = YNONE;

/*   printf ("wdisplay_pix=%d \n", wdisplay_pix);  */
/*   printf ("hdisplay_pix=%d \n", hdisplay_pix);  */

  for (i = 0; i<SIZE_COLER; i++) { 
    COLER(i).exist = FALSE; 
    strcpy(COLER(i).name, ""); 
  } 
  YDefColors (defcolors); 
	YSetColler (); 

  process.id = ID_NULL;

	for (i=0; i<YTIMER_MAX; i++)
		timer[i].id = ID_NULL; 

	YSetFont ("9x15"); 

  wndgroup_flag = FALSE; 
  wndgroup_last = ID_NULL; 

 return;
}  
/*************************************************************************/  
#ifdef Y_UNIX  
/*************************************************************************/  
/*-------------------------------main--------------------------------------*/ 
int  
main (int argc, char *argv[])  
{   
 
  return (MAIN (argc, argv)); 
 
}  
#else 
// ======================================================================= 
// Функция WinMain 
// Получает управление при запуске 
// приложения 
// ======================================================================= 
//#pragma argsused 
int PASCAL 
WinMain (HINSTANCE hInstance, HINSTANCE hPrevInstance, LPSTR lpszCmdLine,   
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



/*------------------------------YDefColor---------------------------------*/ 
void 
YDefColor (YT_BOOL flag_add, int r, int g, int b, char *name) 
{ 
  YT_BOOL find = FALSE; 
  int i; 
 
  for (i=0; i<SIZE_COLER; i++) { 
    if (COLER(i).exist == FALSE) continue; 
    if (!strcmp(name, COLER(i).name)) {find=TRUE; break;} 
  } 
 
  if (!find) { 
    for (i=0; i<SIZE_COLER; i++) { 
      if (COLER(i).exist == FALSE) {find=TRUE; break;} 
    } 
  } 
  if (!find) return; 
 
  COLER(i).exist = TRUE; 
  strcpy (COLER(i).name, name); 
  COLER(i).r = r; 
  COLER(i).g = g; 
  COLER(i).b = b; 
 
  flag_add++; 
  return; 
} 
/*------------------------------YDefColors---------------------------------*/ 
void 
YDefColors (YT_DEFCOLOR *df) 
{ 
 
  for ( ; df->name != NULL; df++)  
    YDefColor (TRUE, df->r, df->g, df->b, df->name); 
   
  return; 
} 
/*------------------------------YSetColler---------------------------------*/ 
void 
YSetColler () 
{ 
  int i; 
 
  for (i=0; i<SIZE_COLER; i++) { 
    if (COLER(i).exist == FALSE) continue; 
    COLER (i).color = YColorRGB (COLER (i).r, COLER (i).g, COLER (i).b); 
  } 
 
} 
/*--------------------------------YColor----------------------------------------*/ 
YT_COLOR 
YColor(char *name) 
{ 
  int i; 
 
  if ((name==NULL) || !strcmp(name,""))  
    return (CLR_NULL); 
 
  for (i = 0; i<SIZE_COLER; i++) { 
    if (COLER(i).exist == FALSE) continue; 
    if (!strcmp(name, COLER(i).name)) 
			return (COLER(i).color); 
			/* return (YColorRGB (COLER (i).r, COLER (i).g, COLER (i).b));  */
  } 
 
  fprintf (stderr, "Dont' find color = %s", name); 
  return (CLR_NULL); 
} 
/*---------------------------------YRandF--------------------------------------*/ 
double 
YRandF (double fmin, double fmax) 
{ 
#ifdef Y_UNIX  
  double   choise; 
  choise = drand48 (); 
  return (fmin + choise * (fmax - fmin)); 
#else  
  int     irand, imax = 10000; 
  irand = YRAND (0, imax); 
  return (fmin + irand * ((fmax - fmin) / imax)); 
#endif 
} 
/*------------------------------YDrawDownBar--------------------------------*/ 
void 
YDrawDownBar (Int x, Int y, Int w, Int h, YT_COLOR color) 
{ 
  YDrawRectF (x, y, w, h, color); 
  YDrawLine (x, y, x + w - 1, y, YColor("black")); 
  YDrawLine (x, y, x, y + h - 1, YColor("black")); 
  YDrawLine (x + w, y, x + w, y + h, YColor("white")); 
  YDrawLine (x, y + h, x + w, y + h, YColor("white")); 
} 
/*-------------------------------YDrawUpBar---------------------------------*/ 
void 
YDrawUpBar (Int x, Int y, Int w, Int h, YT_COLOR color) 
{ 
  YDrawRectF (x, y, w, h, color); 
  YDrawLine (x, y, x + w - 1, y, YColor("white")); 
  YDrawLine (x, y, x, y + h - 1, YColor("white")); 
  YDrawLine (x + w, y, x + w, y + h, YColor("black")); 
  YDrawLine (x, y + h, x + w, y + h, YColor("black")); 
} 
/*--------------------------------PUSH--------------------------------------*/ 
long 
PUSH (PFUNC_VAR) 
{ 
  static int flag;     

  switch (message) { 
  case YOPEN: 
    break; 
  case YDRAW: 
    YGoto (YREDRAW, TRUE, 0, 0, 0); 
    break; 
  case YREDRAW: 
		YWinBegPaint (id); // ??? for Windows  
    if (mes1 == TRUE) { 
      YDrawUpBar (0, 0, WND_w, WND_h, WND_color); 
      YDrawRectText (WND_name, 0, 0, WND_w, WND_h, YColor("black")); 
    } else { 
      YDrawDownBar (0, 0, WND_w, WND_h, WND_color); 
      YDrawRectText (WND_name, 1, 1, WND_w, WND_h, YColor("black")); 
    } 
		YWinEndPaint (id);   
    break; 
  case YGETDATA: 
    return ((long) WND_name); 
  case YLMOUSEDOWN: 
    flag = 1; 
    YGoto (YREDRAW, FALSE, 0, 0, 0); 
    YPost (WND_parent, YPUSHDOWN, id, 0, 0, 0); 
    break; 
  case YRMOUSEDOWN: 
    flag = 1; 
    YGoto (YREDRAW, FALSE, 0, 0, 0); 
    YPost (WND_parent, YRPUSHDOWN, id, 0, 0, 0); 
    break; 
  case YLMOUSEDRAG: 
    if (flag) { 
      if (mes1<0 || mes1>WND_w || mes2>WND_h || mes2<0) { 
				flag = 0; 
				YGoto (YREDRAW, TRUE, 0, 0, 0); 
      } 
    }else 
      if (mes1>0 && mes1<WND_w && mes2<WND_h && mes2>0) 
				YGoto (YLMOUSEDOWN, 0, 0, 0, 0); 
    break;         
  case YRMOUSEDRAG: 
    if(flag){ 
      if(mes1<0 || mes1>WND_w || mes2>WND_h || mes2<0){ 
				flag = 0; 
				YGoto (YREDRAW, TRUE, 0, 0, 0); 
      } 
    }else 
      if(mes1>0 && mes1<WND_w && mes2<WND_h && mes2>0) 
				YGoto (YRMOUSEDOWN, 0, 0, 0, 0); 
    break;         
  case YLMOUSEUP: 
    YGoto (YREDRAW, TRUE, 0, 0, 0); 
    if (flag) 
      YPost (WND_parent, YPUSH, id, 0, 0l, 0); 
    break; 
  case YRMOUSEUP: 
    YGoto (YREDRAW, TRUE, 0, 0, 0); 
    if (flag) 
      YPost (WND_parent, YRPUSH, id, 0, 0l, 0); 
    break; 
  case YCLOSE:
		YDelWindow (id);
    break; 
  default: ;;;; 
  } 
 
  RETURN_TRUE; 
} 
/*--------------------------------CHECK-------------------------------------*/ 
long 
CHECK (PFUNC_VAR) 
{ 
#define FLAG (*(U->pflag)) 
 
  typedef struct { 
    YT_BOOL  flag; 
    YT_BOOL *pflag; 
  } YT_USR; 
 
  YT_COLOR c_line; 
 
  switch (message) { 
  case YOPEN: 
    U_MALLOC; 
    U->pflag = (YT_BOOL*)mes2; 
    if (U->pflag == NULL) { 
      U->flag  = (YT_BOOL)mes1; 
      U->pflag = &(U->flag); 
    } 
    break; 
  case YDRAW: 
    YDrawDownBar (0, 0, WND_w, WND_h, WND_color); 
  case YREDRAW: 
    if (FLAG == FALSE)   c_line = WND_color; 
    else                 c_line = YColor("black"); 
    YDrawLine (1, 1, WND_w-1, WND_h-1, c_line); 
    YDrawLine (1, WND_h-1, WND_w-1, 1, c_line); 

		YWinBegPaint (WND_parent);   
    YDrawString (WND_name, WND_x+WND_w+10, WND_y+WND_h/2, YColor("black")); 
		YWinEndPaint (WND_parent);    
    break; 
  case YLMOUSEDOWN: 
    FLAG = !(FLAG); 
    YPost (WND_parent, YCHECK, id, FLAG, 0, 0); 
		YWinBegPaint (id); // ???   
    YGoto (YREDRAW, 0, 0, 0, 0); 
		YWinEndPaint (id); // ???   
    if (!FLAG)   
      break; 
    if (WND_goto != ID_NULL)  
      YSend (WND_goto, YGOTOFROM, id, 0, 0, 0); 
    break; 
  case YGOTOFROM: 
    if (mes1 == id) 
      break; 
    FLAG = FALSE; 
		YWinBegPaint (id); // ???   
    YGoto (YREDRAW, 0, 0, 0, 0); 
		YWinEndPaint (id); // ???   
    YSend (WND_goto, YGOTOFROM, mes1, 0, 0, 0); 
    break; 
  case YCLOSE: 
		YDelWindow (id);
    break; 
  case YGETDATA: 
    return ((long)FLAG); 
  default: 
    break; 
  } 
 
  RETURN_TRUE; 
#undef FLAG 
} 
/*---------------------------------YSetProcess-------------------------------*/ 
void 
YSetProcess (int id, int message) 
{ 
  if (process.id != ID_NULL) 
    YError ("YSetProcess"); 
 
  process.id = id; 
  process.message = message; 
} 
/*------------------------------YKillProcess---------------------------------*/ 
void 
YKillProcess () 
{ 
 
  process.id = ID_NULL; 
 
} 
/*--------------------------------YCheckProcess------------------------------*/ 
void 
YCheckProcess () 
{ 
  if (process.id == ID_NULL) 
    return; 
  YSend (process.id, process.message, 0, 0, 0, 0); 
} 
/*------------------------------YSetTimer--------------------------------*/ 
int 
YSetTimer (int id, long delta) 
{ 
	int i;

	for (i=0; i<YTIMER_MAX; i++)
		if (timer[i].id == ID_NULL)
			break;

  if (i == YTIMER_MAX) 
    YError ("YSetTimer"); 
 
  timer[i].id = id; 
  timer[i].delta = delta; 
  timer[i].start = YTimeGet (); 

	return (i);
} 
/*------------------------------YKillTimer-------------------------------*/ 
void 
YKillTimer (int i) 
{ 
 
	if (i == ID_NULL) return;
  timer[i].id = ID_NULL; 
 
} 
/*----------------------------------YTimeGet--------------------------------*/ 
long 
YTimeGet () 
{			 
#if defined(Y_UNIX) || defined(CYGWIN)           
  struct timeval tp; 
  struct timezone tz; 
  gettimeofday (&tp, &tz); 
  return (tp.tv_sec * 100 + tp.tv_usec / 10000); 
#else /*-------------------*/ 
  struct _timeb tb; 
  _ftime (&tb); 
  return (tb.time * 100 + tb.millitm / 10); 
#endif 
} 
/*-------------------------------YCheckTimer-----------------------------*/ 
void 
YCheckTimer () 
{ 
  long  cur_time, d_time;
  int   i;

  for (i=0; i<YTIMER_MAX; i++) {
    if (timer[i].id == ID_NULL) continue; 
 
    cur_time = YTimeGet (); 
    d_time = cur_time - timer[i].start; 
    if (d_time < timer[i].delta) continue; 
 
    timer[i].start = cur_time; 

    YSend (timer[i].id, YTIMER, 0, 0, 0, 0); 
  }
 
  return; 
} 
/*-------------------------------YCheckEvents--------------------------------*/ 
void 
YCheckEvents () 
{ 
  static int num = 1; 
   
  switch ((num++)%3) { 
  case 0: 
		YCheckSystem (); 
    break; 
  case 1: 
    YCheckProcess (); 
    break; 
  case 2: 
    YCheckTimer (); 
    break; 
  } 
  
  return; 
} 
/*--------------------------------DECIMAL-----------------------------------*/ 
long 
DECIMAL (PFUNC_VAR) 
{ 
#define DVAL (*(U->pdval)) 
#define DMIN (U->dmin) 
#define DMAX (U->dmax) 
  char    string[20]; 
  static YT_BOOL minus; 
  static int delay, x0, y0, delta, tim; 
 
  typedef struct { 
    int  *pdval, dval, dmin, dmax; 
  } YT_USR; 
 
  switch (message) { 
  case YOPEN: 
    U_MALLOC; 
    if (mes4 == 0) { 
      U->dval  = mes1; 
      U->pdval = &(U->dval); 
    } 
    else 
      U->pdval = (int*) mes4; 
    DMIN = mes2; 
    DMAX = mes3; 
    break; 
  case YDRAW: 
    YDrawRectB (0, 0, WND_w, WND_h, YColor("black")); 
		YWinBegPaint (WND_parent);   
    YDrawString (WND_name, WND_x-YStringW(WND_name)-10, WND_y+WND_h/2, YColor("black")); 
		YWinEndPaint (WND_parent);   
    YGoto (YREDRAW, 0, 0, 0, 0); 
    break; 
  case YREDRAW: 
		YWinBegPaint (id);   
    YDrawRectF (1, 1, WND_w-2, WND_h-2, WND_color); 
    sprintf (string, "%d", DVAL); 
    YDrawRectText (string, 1, 2, WND_w-2, WND_h-1, YColor("black")); 
		YWinEndPaint (id);   
    break; 
  case YLMOUSEDOUBLE: 
  case YLMOUSEDOWN: 
    DVAL--; 
    if (DVAL < DMIN) { 
      DVAL = DMIN; 
      break; 
    } 
    YGoto (YREDRAW, 0, 0, 0, 0); 
    tim = YSetTimer (id, 10); 
    minus = TRUE; 
    delay = 0; 
    x0 = mes1; 
    y0 = mes2; 
    delta = 1; 
    break; 
  case YRMOUSEDOWN: 
    DVAL++; 
    if (DVAL > DMAX) { 
      DVAL = DMAX; 
      break; 
    } 
    YGoto (YREDRAW, 0, 0, 0, 0); 
    tim = YSetTimer (id, 10); 
    minus = FALSE; 
    delay = 0; 
    x0 = mes1; 
    y0 = mes2; 
    delta = 1; 
    break; 
  case YLMOUSEDRAG: 
  case YRMOUSEDRAG: 
    delta = 1 + (abs (mes1 - x0) + abs (mes2 - y0)) / 5; 
    break; 
  case YTIMER: 
    if (delay++ < 3) 
      break; 
    if (minus) { 
      DVAL -= delta; 
      if (DVAL < DMIN)  DVAL = DMIN; 
    } else { 
      DVAL += delta; 
      if (DVAL > DMAX)  DVAL = DMAX; 
    } 
    YGoto (YREDRAW, 0, 0, 0, 0); 
    break; 
  case YLMOUSEUP: 
  case YRMOUSEUP: 
    YKillTimer (tim); 
    YGoto (YDATAMADE, 0,0,0,0); 
    break; 
  case YDATAMADE: 
    YSend (WND_parent, YDECIMAL, id, 0, DVAL, 0); 
    break;  
  case YGETDATA: 
    return(DVAL);  
  case YCLOSE: 
		YDelWindow (id);
    break; 
  } 
 
  RETURN_TRUE; 
} 
/*----------------------------YWndGroupBegin--------------------------------*/ 
void 
YWndGroupBegin () 
{ 
  /* if (SECOND_DRAW) return;   */             /*!!!!!!*/ 
  wndgroup_flag = TRUE; 
 
} 
/*-----------------------------YWndGroupEnd---------------------------------*/ 
void 
YWndGroupEnd () 
{ 
  /* if (SECOND_DRAW) return;   */             /*!!!!!!*/ 
 
  BIGI(wndgroup_first)->id_goto = wndgroup_last; 
  wndgroup_flag = FALSE; 
  wndgroup_last = ID_NULL;  
 
} 
/*===========================================================================*/
//                SVISOR1  SVISOR1  SVISOR1  SVISOR1  SVISOR1  
//                SVISOR1  SVISOR1  SVISOR1  SVISOR1  SVISOR1  
/*===========================================================================*/

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
/*-----------------------------YDrawSymbol----------------------------------*/ 
void 
YDrawSymbol (char *name, int x, int y, int w, int h, YT_COLOR color) 
{ 
  int  x1, y1, x2, y2, x3, y3; 
 
  YSWITCH (name) { 
  YCASE ("up>") 
    x1 = x; 
    x2 = x + w; 
    x3 = x + w / 2; 
    y1 = y + h; 
    y2 = y1; 
    y3 = y; 
    YDrawTriF (x1, y1, x2, y2, x3, y3, color); 
  YCASE ("down>") 
    x1 = x; 
    x2 = x + w; 
    x3 = x + w / 2; 
    y1 = y; 
    y2 = y1; 
    y3 = y + h; 
    YDrawTriF (x1, y1, x2, y2, x3, y3, color); 
  YCASE ("left>") 
    x1 = x + w; 
    x2 = x1; 
    x3 = x; 
    y1 = y; 
    y2 = y + h; 
    y3 = y + h / 2; 
    YDrawTriF (x1, y1, x2, y2, x3, y3, color); 
  YCASE ("right>") 
    x1 = x; 
    x2 = x1; 
    x3 = x + w; 
    y1 = y; 
    y2 = y + h; 
    y3 = y + h / 2; 
    YDrawTriF (x1, y1, x2, y2, x3, y3, color); 
  YDEFAULT 
  }  
 
  return; 
} 
/*---------------------------V1DrawMain-------------------------------------*/
void
V1DrawMain (VT_W1D *w1d)
{
  VT_CAM1D *cam1d = w1d->cam1d;
  int     xscr = cam1d->scrx, yscr = cam1d->scry, wscr = cam1d->scrw, hscr = cam1d->scrh;
  int     title_h = 20, y_line;
  YT_COLOR color = cam1d->foregr;

  YDrawRectF (xscr, yscr, wscr, hscr, cam1d->backgr);
  YDrawRectB (xscr, yscr, wscr, hscr, color);

  if (cam1d->is_title) {
    y_line = yscr + title_h;
    YDrawLine (xscr, y_line, xscr + wscr, y_line, color);
    YDrawStringImp (cam1d->title, xscr + wscr / 2, yscr + title_h / 2, color, YNONE, YNONE);
    yscr += title_h;
    hscr -= title_h;
  }
  V1CalcMinMax (w1d);
  V1DrawAll (w1d, xscr + 10, yscr + 10, wscr - 20, hscr - 20);

  wscr++;
  hscr++;
}
/*-----------------------------V1Init---------------------------------------*/
void
V1Init (VT_W1D *w1d, char *title, char *axeX, char *axeY)
{
  VT_PLOT *plot;
  int     i;
/* VT_CAM1D *cam1d=w1d->cam1d; */

  for (i = 0; i < MAX_PLOTS; i++) {
    plot = &(w1d->plot[i]);
    plot->exist = FALSE;
    plot->legend = "";
    plot->xlist = NULL;
    plot->ylist = NULL;
  }

  title++;
  axeX++;
  axeY++;
}
/*----------------------------V1CamCreate-----------------------------------*/
VT_CAM1D *
V1CamCreate ()
{
  VT_CAM1D *cam1d;

  if (!(cam1d = (VT_CAM1D *) malloc (sizeof (VT_CAM1D))))
            YError ("V1CamCreate");

  cam1d->scrx = 0;
  cam1d->scry = 0;
  cam1d->scrw = 10;
  cam1d->scrh = 10;
  cam1d->is_title = FALSE;
  cam1d->is_axeX = FALSE;
  cam1d->is_axeY = FALSE;
  strcpy (cam1d->title, "Demo example");
  strcpy (cam1d->axeX, "Horizontal");
  strcpy (cam1d->axeY, "Vertical");
  cam1d->legends_style = YUP;

  cam1d->backgr = YColor("white");
  cam1d->foregr = YColor("black");

  cam1d->darks[0] = YColor("black");
  cam1d->darks[1] = YColor("red");
  cam1d->darks[2] = YColor("green");
  cam1d->darks[3] = YColor("blue");
  cam1d->darks[4] = YColor("yellow");
  cam1d->darks[5] = YColor("green");
  cam1d->darks[6] = YColor("fuchsia");
  cam1d->darks[7] = YColor("olive");
  cam1d->darks[8] = YColor("purple");

  return (cam1d);
}
/*----------------------------V1PlotCreate----------------------------------*/
VT_PLOT *
V1PlotCreate ()
{
  VT_PLOT *plot;

  if (!(plot = (VT_PLOT *) malloc (sizeof (VT_PLOT))))
            YError ("V1PlotCreate");
  return (plot);
}
/*-----------------------------VListCreate----------------------------------*/
YT_SPACE *
VListCreate (int ii)
{
  YT_SPACE *list;

  YMEMLOC (list, YT_SPACE *, ii * sizeof (YT_SPACE));
  if (!list)
    YError ("VListCreate");

  return (list);
}
/*-----------------------------VListPut-------------------------------------*/
void
VListPut (YT_SPACE *list, int i, YT_SPACE value)
{

  list[i] = value;

}
/*----------------------------V1PlotInit------------------------------------*/
void
V1PlotInit (VT_PLOT *plot, char *legend, int ii)
{

  plot->exist = TRUE;
  plot->legend = legend;
  plot->xlist = VListCreate (ii);
  plot->ylist = VListCreate (ii);
  plot->ii = ii;

}
/*-----------------------------V1PlotPut------------------------------------*/
void
V1PlotPut (VT_PLOT *plot, int i, YT_SPACE x, YT_SPACE y)
{
  VListPut (plot->xlist, i, x);
  VListPut (plot->ylist, i, y);
  return;
}
/*-------------------------------V1Create-----------------------------------*/
VT_W1D *
V1Create ()
{
  VT_W1D *w1d;

  if (!(w1d = (VT_W1D *) malloc (sizeof (VT_W1D))))
            YError ("V1Create");
  w1d->cam1d = V1CamCreate ();

  return (w1d);
}
/*-----------------------------V1PlotAdd------------------------------------*/
YT_BOOL
V1PlotAdd (VT_W1D *w1d, VT_PLOT *pplot)
{
  VT_PLOT *plot;
  int     i;

  for (i = 0; i < MAX_PLOTS; i++) {
    plot = &(w1d->plot[i]);
    if (plot->exist) 
      continue;

    *plot = *pplot;
    return (TRUE);
  }

/*   YMessageBox ("Too many PLOT!", "OK"); */
  YWarning ("Too many PLOT!");
  return (FALSE);
}
/*-----------------------------V1CalcMinMax---------------------------------*/
void
V1CalcMinMax (VT_W1D *w1d)
{
  VT_CAM1D *cam1d = w1d->cam1d;
  VT_PLOT *plot;
  YT_SPACE xmin, xmax, x, ymin, ymax, y;
  int     i, k;

  xmin = YMAXSPACE;
  xmax = YMINSPACE;
  ymin = YMAXSPACE;
  ymax = YMINSPACE;
  for (k = 0; k < MAX_PLOTS; k++) {
    plot = &(w1d->plot[k]);
    if (!(plot->exist))  
      continue;

    for (i = 0; i < plot->ii; i++) {
      x = plot->xlist[i];
      y = plot->ylist[i];
      xmin = YMIN (x, xmin);
      xmax = YMAX (x, xmax);
      ymin = YMIN (y, ymin);
      ymax = YMAX (y, ymax);
    }
  }

  cam1d->x_min = w1d->xmin = xmin;
  cam1d->x_max = w1d->xmax = xmax;

  cam1d->y_min = w1d->ymin = ymin;
  cam1d->y_max = w1d->ymax = ymax;

  return;
}
/*------------------------------YVertString---------------------------------*/ 
int 
YVertString (int x0, int y0, char *string, YT_COLOR color, YT_BOOL drawing) 
{ 
  int   i = 0, x, y; 
  char  bukva[2] = {'\0', '\0'}; 
 
  x = x0 - YStringW ("W") / 2; 
  y = y0 + YStringH ("H"); 
 
  for (i = 0; i < strlen (string); i++) { 
    *&(bukva[0]) = *&(string[i]); 
    if (drawing) 
      YDrawString (bukva, x, y, color); 
    y += YStringH (bukva); 
  } 
 
  return (y - y0); 
} 
/*-----------------------------YDrawVString---------------------------------*/ 
void 
YDrawVString (char *string, int x0, int y0, YT_COLOR color) 
{ 
 
  YVertString (x0, y0, string, color, TRUE); 
 
} 
/*-----------------------------YVertStringH---------------------------------*/ 
int 
YVertStringH (char *string) 
{ 
 
  return (YVertString (0, 0, string, YColor("black"), FALSE)); 
} 
/*-----------------------------V1DrawAll------------------------------------*/
void
V1DrawAll (VT_W1D *w1d, int xscr, int yscr, int wscr, int hscr)
{
  VT_CAM1D *cam1d = w1d->cam1d;
  VT_PLOT *plot;
  int     i, i_plot, x, y, w, h;
  int     arrowX = 20, arrowY = 20;
  int     left, right, top, bottom;
  char   *axeX = cam1d->axeX;
  char   *axeY = cam1d->axeY;
  YT_BOOL is_axeX = cam1d->is_axeX, is_axeY = cam1d->is_axeY;
  YT_COLOR color = cam1d->foregr;
	char Y_STR[256];

  sprintf (Y_STR, "%.1f", w1d->ymin);
  left = YStringW (Y_STR);
  sprintf (Y_STR, "%.1f", w1d->ymax);
  left = YMAX (left, YStringW (Y_STR));
  left += 5;			/* for negative values ?! */
  if (is_axeY)
    left = left + YStringW ("W") + 5;

  top = arrowY;
  right = arrowX;

  bottom = 5 + YStringH ("H");
  if (is_axeX)
    bottom = bottom + YStringH (axeX) + 5;

  x = xscr + left;
  w = wscr - left - right;
  y = yscr + top;
  h = hscr - top - bottom;

  if (is_axeY) 
		YDrawVString (axeY, xscr + YStringH ("H") / 2, y + h / 2 - YVertStringH (axeY) / 2, color);
  if (is_axeX) 
    YDrawStringImp (axeX, x + w / 2, yscr + hscr, color, YNONE, YUP);

  V1DrawFrame (w1d, x, y, w, h, right, top);

  for (i_plot = 0, i = 0; i < MAX_PLOTS; i++) {
    plot = &(w1d->plot[i]);
    if (!(plot->exist))  
      continue;
    plot->color = cam1d->darks[i_plot++];
    V1DrawOne (w1d, plot, x, y, w, h);
  };

  if (cam1d->legends_style == YUP)
    V1DrawLegends (w1d, x + 30, y);

  return;
}
/*------------------------------V1DrawFrame---------------------------------*/
void
V1DrawFrame (VT_W1D *w1d, int xscr, int yscr, int wscr, int hscr,
	     int arrowX, int arrowY)
{
  VT_CAM1D *cam1d = w1d->cam1d;
  YT_COLOR color = cam1d->foregr;

  YDrawRectB (xscr, yscr, wscr, hscr, color);

  V1DrawAxeX (xscr, yscr + hscr - 1, wscr, color, w1d->xmin, w1d->xmax, arrowX);
  V1DrawAxeY (xscr, yscr + hscr - 1, hscr, color, w1d->ymin, w1d->ymax, arrowY);

}
/*----------------------------V1DrawAxeX------------------------------------*/
void
V1DrawAxeX (int x0, int y0, int w, YT_COLOR color,
	    YT_SPACE xmin, YT_SPACE xmax, int pointer)
{
  int     l = 5, x, d = 10;
	char Y_STR[256];

  if (pointer) {
    YDrawLine (x0 + w, y0, x0 + w + pointer, y0, color);
    YDrawSymbol ("right>", x0 + w + pointer - 10, y0 - 5, 10, 10, color);
  }
  x = x0;
  sprintf (Y_STR, "%.1f", xmin);
  YDrawLine (x, y0, x, y0 + l, color);
  YDrawStringImp (Y_STR, x, y0 + d, color, YRIGHT, YDOWN);

  x = x0 + w / 2;
  sprintf (Y_STR, "%.1f", xmin + (xmax - xmin) / 2);
  YDrawLine (x, y0, x, y0 + l, color);
  YDrawStringImp (Y_STR, x, y0 + d, color, YNONE, YDOWN);

  x = x0 + w - 1;
  sprintf (Y_STR, "%.1f", xmax);
  YDrawLine (x, y0, x, y0 + l, color);
  YDrawStringImp (Y_STR, x, y0 + d, color, YLEFT, YDOWN);

}
/*-----------------------------V1DrawAxeY-----------------------------------*/
void
V1DrawAxeY (int x0, int y0, int h, YT_COLOR color,
	    YT_SPACE ymin, YT_SPACE ymax, int pointer)
{
  int     l = 5, y;
	char Y_STR[256];

  if (pointer) {
    YDrawLine (x0, y0 - h, x0, y0 - h - pointer, color);
    YDrawSymbol ("up>", x0 - 5, y0 - h - pointer, 10, 10, color);
  }
  y = y0;
  sprintf (Y_STR, "%.1f", ymin);
  YDrawLine (x0, y, x0 - l, y, color);
  YDrawStringImp (Y_STR, x0 - l, y, color, YLEFT, YUP);

  y = y0 - h / 2;
  sprintf (Y_STR, "%.1f", ymin + (ymax - ymin) / 2);
  YDrawLine (x0, y, x0 - l, y, color);
  YDrawStringImp (Y_STR, x0 - l, y, color, YLEFT, YNONE);

  y = y0 - h + 1;
  sprintf (Y_STR, "%.1f", ymax);
  YDrawLine (x0, y, x0 - l, y, color);
  YDrawStringImp (Y_STR, x0 - l, y, color, YLEFT, YDOWN);

}
/*---------------------------V1DrawLegends----------------------------------*/
void
V1DrawLegends (VT_W1D *w1d, int x0, int y0)
{
  VT_CAM1D *cam1d = w1d->cam1d;
  VT_PLOT *plot;
  int     i, x;
  char   *title = "Legends: ";

  x = x0;
  YDrawStringImp (title, x, y0, cam1d->foregr, YRIGHT, YUP);
  x = x + YStringW (title);
  for (i = 0; i < MAX_PLOTS; i++) {
    plot = &(w1d->plot[i]);
    if (!(plot->exist))  
      continue;

    YDrawStringImp (plot->legend, x, y0, plot->color, YRIGHT, YUP);
    x = x + YStringW (plot->legend) + 10;
  };

}
/*---------------------------V1DrawOne--------------------------------------*/
void
V1DrawOne (VT_W1D *w1d, VT_PLOT *plot, int xscr, int yscr, int wscr, int hscr)
{
  static int x1, y1, x2, y2;
  YT_SPACE yymin, yymax, yystep, yy;
  YT_SPACE xxmin, xxmax, xxstep, xx;
  int     d, x, y;

  xxmin = w1d->xmin;
  xxmax = w1d->xmax;
  xxstep = (xxmax - xxmin) / wscr;

  yymin = w1d->ymin;
  yymax = w1d->ymax;
  yystep = (yymax - yymin) / hscr;

  for (d = 0; d < plot->ii; d++) {
    xx = (plot->xlist)[d];
    yy = (plot->ylist)[d];
    x = xscr + (int) ((xx - xxmin) / xxstep);
    y = yscr + (int) ((yy - yymin) / yystep);
    if (d == 0) {
      x1 = x;  y1 = y;
      continue;
    }
    x2 = x;
    y2 = y;
    YDrawLine (x1, y1, x2, y2, plot->color);
    x1 = x2;
    y1 = y2;
  }

  return;
}
/*===========================================================================*/
/*---------------------------------------------------------------------------*/ 
