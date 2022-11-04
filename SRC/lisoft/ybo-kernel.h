// -*-  mode: c    ; coding: koi8   -*- ----------------------------------------

/****************************************************************************    
 *                                                                          *    
 *  y_zone.h  -- declarations for "Library Yzone";                          *    
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
                                                                                 
#ifndef _Y_ZONE_H                                                                
#define _Y_ZONE_H                                                                
                                                                                 
#ifdef __cplusplus                                                               
extern "C" {                                                                     
#endif                                                                           
                                                                                 
/****************************************************************************/   
  enum y_enum { 
    YDESTROY, YM_PAINT, YLMOUSEDOWN, YRMOUSEDOWN,  
    YLMOUSEUP, YRMOUSEUP, YM_NULL, YM_CREATE, YNONE, 
    YWIN, YPIX, YPUSH, YDRAWITEM,
		YKEY_LOCALS
  }; 
 
typedef int YT_BOOL; 
typedef unsigned long YT_COLOR;  
typedef int SC; 
 
#define YERROR(str)  {printf("ERR: %s \n",(str)); getchar(); exit(0);}  
#define TRUE  1 
#define FALSE 0  

 
typedef struct { 
	short x, y; 
} YPoint; 
 
#define  YNULL  0 
 
extern int quit_ret; 
extern YT_BOOL yquit_flag; 
extern int blk, wht; 
extern int w_glob, h_glob; 

extern int    wdisplay_pix, hdisplay_pix;  
extern double xpix_per_mm, ypix_per_mm;
extern int id_last; 

#define  ID_NULL  20000  
#define  ID_ROOT  20001  
#define  ID_LAST  (id_last) 
#define  LP(val) (long)&(val)  
#define  SC_DEF   20002

#define XMM(mm) ((int)((double)(mm)*xpix_per_mm)) 
#define YMM(mm) ((int)((double)(mm)*ypix_per_mm)) 
#define XSCR(p) ((int)((p)*wdisplay_pix)) 
#define YSCR(p) ((int)((p)*hdisplay_pix)) 
 
#define  PFUNC_PAR   int, int, int, int, int, long, long 
#define  PFUNC_VAR   int id, int from, int message, int mes1, int mes2, long mes3, long mes4  
#define  PFUNC_VAL   id, from, message, mes1, mes2, mes3, mes4  
typedef  long (*YT_PFUNC) (PFUNC_PAR);                              
 
#define  RETURN_TRUE { from++; mes1++; mes2++; mes3++; mes4++; return(TRUE); } 
#define  CALL(proc, id,from,message,mes1,mes2,mes3,mes4) ((*(proc))(id,from,message,mes1,mes2,mes3,mes4)) 
 
#define YRETURN {return (quit_ret);}
#define YQUIT (yquit_flag) 
 
#define  YMAX(a,b)  (((a) > (b)) ? (a) : (b)) 
#define  YMIN(a,b)  (((a) < (b)) ? (a) : (b)) 
#define  YRAND_S  srand((unsigned)time(NULL)) 
#define  YRAND(imin,imax) (imin+rand()%(imax-imin+1))  

#define  BLACK    0,0,0  
#define  WHITE    255,255,255  
#define  GRAY     128,128,128  
#define  MAROON   128,0,0  
#define  RED      255,0,0  
#define  PURPLE   128,0,128  
#define  FUCHSIA  255,0,255  
#define  GREEN    0,128,0  
#define  LIME     0,255,0  
#define  OLIVE    128,128,0  
#define  YELLOW   255,255,0  
#define  NAVY     0,0,128  
#define  BLUE     0,0,255  
#define  TEAL     0,128,128  
#define  AQUA     0,255,255  

int   MAIN (int argc, char *argv[]) ;  

void  YInit (void); 
void  YQuit (void);  
long  YSend (int id, int message, int mes1, int mes2, long mes3, long mes4) ; 
long  YGoto (int message, int mes1, int mes2, long mes3, long mes4); 
 
YT_BOOL YBig (int *, YT_PFUNC, char *wname, SC, SC, SC, SC);   
YT_BOOL YWin (int *, YT_PFUNC, char *wname, SC, SC, SC, SC);   
void    YWinBegPaint (int);  
void    YWinEndPaint (int);  
SC      YWinW (int); 
SC      YWinH (int);  
int     YWinP (int);  
long    YWinMapGet (int); 
void    YWinMapPut (int id, long map); 
void    YWinMapSet (long map); 
 
long YImageGet (int x, int y, int w, int h);   
void YImagePut (int x, int y, long pImage);   
void YImageSet (long img);  
int 
YHwndToId (long hwnd); 
 
 
void  YDrawRectF (int x, int y, int w, int h, YT_COLOR color);  
void  YDrawTriF (int x1, int y1, int x2, int y2, int x3, int y3, YT_COLOR fcolor);      
void  YDrawTriB (int x1, int y1, int x2, int y2, int x3, int y3, YT_COLOR color); 
void  YDrawTriFB (int x1, int y1, int x2, int y2, int x3, int y3, YT_COLOR fcolor, YT_COLOR bcolor);                                                     
void  YFillPolygon (YPoint *pts, YT_COLOR color); 
void  YFlush (void); 
void  YDrawLine (int x1, int y1, int x2, int y2, YT_COLOR color);  
void  YDrawCircB (int cx, int cy, int r, YT_COLOR bcolor);  
void  YDrawCircFB (int cx, int cy, int r, YT_COLOR fcolor, YT_COLOR bcolor);  
 
long  YCreatePixmap (int); 
void  YSetWindowPixmap (int, long pix); 
void  YPixToWin(long, int); 
void  YBeginPaint (long, int);  
void  YEndPaint (long, int);  
 
YT_COLOR  YColorRGB (int red, int green, int blue);  
void  YCopyPixmaps (long from, long to, SC, SC);  
 
void  YCheckEvents (void); 
YT_BOOL YPauseSoft (int); 
void    YPauseHard (int); 
void  YDrawRectB (int x, int y, int w, int h, YT_COLOR color);  
void  YDrawRectFB (int x, int y, int width, int height, YT_COLOR fcolor, YT_COLOR lcolor) ; 
void  YDrawPolyF (YPoint *pts, int numpoints, YT_COLOR fcolor);  
 
#define WIN_W  (YWinW(id)) 
#define WIN_H  (YWinH(id)) 
 
/****************************************************************************/   
                                                                                
#ifdef __cplusplus                                                               
}                                                                                
#endif                                                                           
#endif /* _Y_ZONE_H */                                                           
                                                                                 
/****************************************************************************/   
 
