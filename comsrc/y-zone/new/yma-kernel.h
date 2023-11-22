// -*-  mode: c    ; coding: koi8   -*- ----------------------------------------

/****************************************************************************    
 *                                                                          *    
 *  y_zone.h  -- declarations for "Library Yzone";                          *    
 *                                                                          *    
 *  Copyright (c) 2000, Life Software.                                      *    
 *                                                                          *    
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
    //
    YNONE, 
    //
    YOPEN, YDRAW, YCLOSE, YREDRAW, 
    YLMOUSEDOWN, YLMOUSEUP, YLMOUSEDRAG, YLMOUSEDOUBLE, 
    YRMOUSEDOWN, YRMOUSEUP, YRMOUSEDRAG,
    YM_NULL, 
    YWIN, YPIX, YDRAWITEM,
    YKEYWORD1,
    YLEFT, YUP, YRIGHT, YDOWN, YTIMER, YDATAMADE, YDECIMAL, 
    YPUSH, YRPUSH, YPUSHDOWN, YRPUSHDOWN,
    YCHECK, 
    YGETDATA, YGOTOFROM, YADDITEM, YDELITEM, 
    YKEY_LOCALS,
    //
    //ybo-kernel.h
    // 
    YDESTROY, YM_PAINT, /* YLMOUSEDOWN, YRMOUSEDOWN,  */ 
    /* YLMOUSEUP, YRMOUSEUP, */ /* YM_NULL, */ YM_CREATE/* , */ /* YNONE, */ 
    /* YWIN, YPIX, */ /* YPUSH, YDRAWITEM, */
    /* YKEY_LOCALS, */
  }; 
 
typedef int YT_BOOL; 
typedef unsigned long YT_COLOR;  
/* typedef int Int;  */
typedef int Int; 
typedef long Mes; 
 
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
extern Int w_glob, h_glob; 

extern Int    wdisplay_pix, hdisplay_pix;  
extern double xpix_per_mm, ypix_per_mm;
extern int id_last; 

#define  ID_NULL  20000  
#define  ID_ROOT  20001  
#define  ID_LAST  (id_last) 
#define  LP(val) (long)&(val)  
#define  SC_DEF   20002
typedef int SC; 

#define  XMM(mm) ((Int)((double)(mm)*xpix_per_mm)) 
#define  YMM(mm) ((Int)((double)(mm)*ypix_per_mm)) 
#define  XSCR(p) ((Int)((p)*wdisplay_pix)) 
#define  YSCR(p) ((Int)((p)*hdisplay_pix)) 
 
#define  PFUNC_PAR   int, int, int, Mes, Mes, long, long 
#define  PFUNC_VAR   int id, int from, int message, Mes mes1, Mes mes2, long mes3, long mes4  
#define  PFUNC_VAL   id, from, message, mes1, mes2, mes3, mes4  
typedef  long (*YT_PFUNC) (PFUNC_PAR);                              
 
#define  RETURN_TRUE { from++; mes1++; mes2++; mes3++; mes4++; return(TRUE); } 
#define  CALL(proc, id,from,message,mes1,mes2,mes3,mes4) ((*(proc))(id,from,message,mes1,mes2,mes3,mes4)) 
 
#define  YRETURN {return (quit_ret);}
#define  YQUIT (yquit_flag) 
 
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

int     MAIN (int argc, char *argv[]) ;  

void    YInit (void); 
void    YQuit (void);  
long    YSend (int id, int message, Mes mes1, Mes mes2, long mes3, long mes4) ; 
long    YGoto (int message, Mes mes1, Mes mes2, long mes3, long mes4); 
 
YT_BOOL YBig_yma/* new */ (int *, YT_PFUNC, char *wname, Int, Int, Int, Int, long, long, long, long, YT_COLOR);   
YT_BOOL YWnd (int *, YT_PFUNC, char *wname, Int, Int, Int, Int, long, long, long, long, YT_COLOR);
  
void    YWndDestroy (int id);   
void    YDelWindow (int id);

void    YWinBegPaint (int);  
void    YWinEndPaint (int);  

typedef struct {
	long     hwnd;
  YT_PFUNC proc; 
	char    *name;
	YT_COLOR color;
	int      parent;
	Int      x, y;
  void     *usr;  
  long     reg;
  int      id_goto;
} YT_BIGWND; 

extern YT_BIGWND *bigwnds[];  
#define BIGI(i) (bigwnds[(i)])

Int      YWinW (int); 
Int      YWinH (int);  
int      YWinP (int);  
YT_COLOR YWinC (int);  
char    *YWinN (int);  
#define WND_goto  (BIGI(id)->id_goto) 
#define WND_x  (BIGI(id)->x) 
#define WND_y  (BIGI(id)->y) 
#define WND_w  (YWinW(id)) 
#define WND_h  (YWinH(id)) 
#define WND_parent (YWinP(id)) 
#define WND_color  (YWinC(id)) 
#define WND_name   (YWinN(id)) 
 
#define  U   ((YT_USR*)(BIGI(id)->usr))
#define  U_MALLOC   {if (!(BIGI(id)->usr = malloc(sizeof(YT_USR)))) YError("usr");}

long  YWinMapGet (int); 
void  YWinMapPut (int id, long map); 
void  YWinMapSet (long map); 
 
long  YImageGet (Int x, Int y, Int w, Int h);   
void  YImagePut (Int x, Int y, long pImage);   
void  YImageSet (long img);  
int   YHwndToId (long hwnd); 
 
 
void  YDrawRectF (Int x, Int y, Int w, Int h, YT_COLOR color);  
void  YDrawTriF  (Int x1, Int y1, Int x2, Int y2, Int x3, Int y3, YT_COLOR fcolor);      
void  YDrawTriB  (Int x1, Int y1, Int x2, Int y2, Int x3, Int y3, YT_COLOR color); 
void  YDrawTriFB (Int x1, Int y1, Int x2, Int y2, Int x3, Int y3, YT_COLOR fcolor, YT_COLOR bcolor);                                                     
void  YFillPolygon (YPoint *pts, YT_COLOR color); 
void  YFlush (void); 
void  YDrawLine  (Int x1, Int y1, Int x2, Int y2, YT_COLOR color);  
void  YDrawCircB (Int cx, Int cy, Int r, YT_COLOR bcolor);  
void  YDrawCircFB(Int cx, Int cy, Int r, YT_COLOR fcolor, YT_COLOR bcolor);  
 
long  YCreatePixmap (int); 
void  YSetWindowPixmap (int, long pix); 
void  YPixToWin(long, int); 
void  YBeginPaint (long, int);  
void  YEndPaint (long, int);  
 
YT_COLOR YColorRGB (int red, int green, int blue);  
void     YCopyPixmaps (long from, long to, Int, Int);  
 
void     YCheckSystem (void); 
void     YCheckEvents (void); 
void     YCheckProcess (void); 

YT_BOOL  YPauseSoft (int); 
void     YPauseHard (int); 
void     YDrawRectB (Int x, Int y, Int w, Int h, YT_COLOR color);  
void     YDrawRectFB (Int x, Int y, Int width, Int height, YT_COLOR fcolor, YT_COLOR lcolor) ; 
void     YDrawPolyF (YPoint *pts, int numpoints, YT_COLOR fcolor);  
void     YDrawString (char *text, Int x, Int y, YT_COLOR color);  
void     YDrawStringImp (char *text, Int x0, Int y0, YT_COLOR color, int horz, int vert);  
void     YError (char *string);  
void     YWarning (char *string);  
int      YStringW (char *string);   
int      YStringH (char *string);   
void     YSetColler (void); 

#define  CALCXY(x,y)      {x=x+(orig_x0);  y=y+(orig_y0);}
#define  ANTICALCXY(x,y)  {x=x-(orig_x0);  y=y-(orig_y0); }
  

/****************************************************************************/  
 
#define  SIZE_COLER  18 /*  16 */
#define  COLER(n)   (globcoller[n]) 

#define  CLR_MAX   256
#define  CLR_DEF   CLR_MAX+1
#define  CLR_NULL  CLR_MAX+2	/*not real color! */
#define  CLR_XOR   CLR_MAX+3

#define YPost YSend 

YT_COLOR YColor (char *name); 
double   YRandF (double fmin, double fmax); 
long     PUSH (PFUNC_VAR);
long     CHECK (PFUNC_VAR);
long     DECIMAL (PFUNC_VAR);
void     YSetProcess (int, int);
void     YKillProcess (void);   
int      YSetTimer (int, long);
void     YKillTimer (int);
long     YTimeGet (void); 
void     YSetFont (char *name); 
void     YWndGroupBegin (void);
void     YWndGroupEnd (void);
int      YIdGoto (void); 

#define  OUTD(val)  (printf ("out_%d \n",(val)))
#define  OUTF(val)  (printf ("out_%f \n",(val)))
#define  OUTS(val)  (printf ("out_%s \n",(val)))


/*-----------------------------svisor1-------------------------------------*/

#define  Y_SWIT  (yswitch)  
#define  Y_CASE  (in_case)  
#define  YSTRCMP(s)  (YStrCmp((s), Y_SWIT))
#define  YSWITCH(sw)  (Y_SWIT=(sw)); if (FALSE) 
#define  YCASE(s)           } else if (YSTRCMP(s)) { 
#define  YCASE2(s1,s2)      } else if (YSTRCMP(s1) || YSTRCMP(s2)) { 
#define  YCASE3(s1,s2,s3)   } else if (YSTRCMP(s1) || YSTRCMP(s2) || YSTRCMP(s3)) { 
#define  YBREAK             ;;
#define  YDEFAULT           } else {    

typedef  double  YT_SPACE;
#define  YMAXSPACE 1.00E+30
#define  YMINSPACE 1.00E-30 

typedef struct {
  YT_BOOL exist;
  char   *legend;
  YT_SPACE *xlist, *ylist;
  int     ii;
  YT_COLOR color;
} VT_PLOT;

VT_PLOT *V1PlotCreate (void);
void     V1PlotInit (VT_PLOT *, char *, int);
void     V1PlotPut (VT_PLOT *, int, YT_SPACE, YT_SPACE);

#define COL_SIZE_DARKS  9
typedef struct {
  char     title[50], axeX[50], axeY[50];
  int      scrx, scry, scrw, scrh;
  YT_SPACE x_min, x_max, y_min, y_max;
  YT_BOOL  is_title, is_axeX, is_axeY;
  int      legends_style;
  YT_COLOR backgr, foregr;
  YT_COLOR darks[COL_SIZE_DARKS];
} VT_CAM1D;
VT_CAM1D *V1CamCreate (void);

#define MAX_PLOTS 20
typedef struct {
  VT_CAM1D *cam1d;
  VT_PLOT plot[MAX_PLOTS];
  YT_SPACE xmin, xmax, ymin, ymax;
} VT_W1D;
VT_W1D  *V1Create (void);
void     V1Init (VT_W1D *, char *, char *, char *);

#define  YOVERFLOW(i) ( ((double)i) != (i) )
#define  YMEMLOC(p,conv,size) {if (YOVERFLOW(size)) p=NULL; else p=(conv)calloc(1,size);}
#define  YMALLOC(p,type,num) {YMEMLOC(p,type*,(num)*sizeof(type)); /* if (p==NULL) YError("YMALLOC"); */}

YT_BOOL  V1PlotAdd (VT_W1D *, VT_PLOT *);
void     V1DrawMain (VT_W1D *);
void     V1CalcMinMax (VT_W1D *);
void     V1DrawFrame (VT_W1D *, int, int, int, int, int, int);
void     V1DrawAll (VT_W1D *, int, int, int, int);
void     V1DrawOne (VT_W1D *, VT_PLOT *, int, int, int, int);
void     V1DrawLegends (VT_W1D *, int, int);
void     V1DrawAxeX (int, int, int, YT_COLOR, YT_SPACE, YT_SPACE, int);
void     V1DrawAxeY (int, int, int, YT_COLOR, YT_SPACE, YT_SPACE, int);

//-------------------------------------------------------------------
  
void  YBeginGroup (char *name, Int x, Int y, Int w, Int h, YT_COLOR color);
void  YEndGroup ();
void  YModeType (YT_BOOL flag, int type);

void    YModePaint (YT_BOOL flag); 
YT_BOOL YWin (int *pid, YT_PFUNC proc, char *wname, int x, int y, int w, int h);   

YT_BOOL YBig (int *pid, YT_PFUNC proc, char *wname, SC x, SC y, SC w, SC h);   

/****************************************************************************/   

                                                                                
#ifdef __cplusplus                                                               
}                                                                                
#endif                                                                           
#endif /* _Y_ZONE_H */                                                           
                                                                                 
/****************************************************************************/   
 
