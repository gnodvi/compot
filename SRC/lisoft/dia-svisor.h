// -*-  mode: c    ; coding: koi8   -*- ----------------------------------------

/****************************************************************************
 *                                                                          *
 *  svisor.h  -- declarations for "Library Svisor";                         *  
 *                                                                          *
 *  Copyright (c) 2000, Life Software.                                      *
 *                                                                          *
 ****************************************************************************
 */                                                                          

#ifndef _SVISOR_H
#define _SVISOR_H

#ifdef __cplusplus
extern "C" {
#endif

/*----------------------------------*/

#include  <stdio.h>
#include  <stdlib.h>  
#include  <string.h>

#include  <math.h>
#include  <time.h>  
#include  <ctype.h>  
  
/****************************************************************************
 *                                                                          *
 *               Declarations for section [MISC]                            *  
 *                                                                          *
 ****************************************************************************
 */                                                                          

void     YInitMISC (void);

typedef struct {
  float    t[300][15][10]; 
  YT_BOOL  t_exist;
} YT_MISC;

extern  YT_MISC *misc;
#define  MISC (misc)  


void     YLoadMyFont (void);
void     YDrawMyString (char *s, int x0, int y0, YT_COLOR color);

#define  FO (MISC->t)
#define  FO_EXIST (MISC->t_exist)

#define  ATR_BUKVA   '@' 
#define  ATR_POINT   '*' 
#define  ATR_DUGA    ')' 
#define  ATR_FLAG    '+' 
#define  ATR_VERT    '|' 
#define  ATR_CIRC    '$' 
#define  ATR_OTREZ   '/' 
#define  ATR_END     '-' 
#define  ATR_COMMENT '!' 
 
#define  F_BUKVA  0
#define  F_POINT  1 
#define  F_CIRC   2
#define  F_OTREZ  3
#define  F_DUGA   4 
#define  F_END    9 


/****************************************************************************
 *                                                                          *
 *               Declarations for section [MATFUN]                          *
 *                                                                          *
 ****************************************************************************
 */                                                                          
           
                                                                               
enum keys {
  YDECART, YPOLAR, YCONST, YRAND 
};

/* typedef struct { */
/*   int  ii, jj; */
/*   int  *cells; */
/* } VT_CELLS; */

void     SLoadMatlib (void);
long     graf_test (PFUNC_PAR);


typedef YT_SPACE VT_GV;
typedef long     VT_GI;

typedef struct {
  YT_BOOL fix;
  VT_GV   l;
  VT_GI   prev;
} VT_GM;

typedef struct {
  VT_GI   s, t;
  VT_GM  *met;
  VT_GI  *puti;
  VT_GV   smin;
} VT_GW;

typedef struct {
  VT_GI  nn;
  VT_GV *nodes;
  VT_GV *edges;
  VT_GW *wk;
} VT_GRAF; 

VT_GV   *VGrafEdge (VT_GRAF *, VT_GI, VT_GI);
#define  GRAF_EDGE(pg, u, v)  (*( (VT_GV*)VGrafEdge((pg), (u), (v)) ))
#define  GRAF_NODE(pg, u)  (*(pg->nodes+u))
#define  GRAF_NOT_EDGE -1000

VT_GRAF *VGrafCreate (VT_GI);
YT_BOOL  VGrafCreateNew (VT_GRAF **ppg, VT_GI nn);
void     VGrafDestroy (VT_GRAF *pg);
void     VGrafInit (VT_GRAF *, int, VT_GV,  VT_GV, int, VT_GV,  VT_GV);
YT_BOOL  VGrafGetEdges (VT_GRAF *pg, VT_GV *edge, VT_GI *, VT_GI *);
YT_BOOL  VGrafGetSosed (VT_GRAF *, VT_GI, VT_GI *);
VT_GV    VGrafGetSum (VT_GRAF *pg, VT_GI u);

YT_BOOL  VGrafSmin (VT_GRAF *, VT_GI, VT_GI, VT_GV *);
void     VGrafPrint (VT_GRAF *);
YT_BOOL  VGrafAllSmin (VT_GRAF *, VT_GI, VT_GV *);

VT_GW   *VGrafWorkCreate (VT_GRAF *);
void     VGrafWorkPrint (VT_GW *);
void     VGrafWorkDelete (VT_GW *);

void     MGrafTest (void);
/*----------------------------------*/


/****************************************************************************
 *                                                                          *
 *               Declarations for section [SVISOR]                            *
 *                                                                          *
 ****************************************************************************
 */                                                                          

/*---------------------------------------------*/

/* long     SVISOR (PFUNC_VAR); */
void     SLoadSvisor (void);
void     SLoadLatice (void);
long     SVISOR (PFUNC_VAR);

  enum ykeys_global {
    YCONSTR0 = YKEY_LEVEL4, YCONSTR1, YCONSTR2, YCONSTR3, YCONSTR4,
    YDESTRU0, YDESTRU1, YDESTRU2, YDESTRU3, YDESTRU4,
    
    MM_LEGEND, MM_SETKA, 
    MM_LAT1, MM_LAT2, MM_LAT3, MM_W1D, MM_CMAP_DRAW, 
    MM_CLEAR_ALL, MM_OBJ3D_ADD, MM_OBJ3D_XOR,  
    MM_VOL3D_CHANGE1, MM_VOL3D_CHANGE2,                                             
                
    VPLINES3D, VPTRIS3D, VSURF, VSETKA3D, VTELO3D, VFLINES3D, VPOINTS, VTRIS3D   
                                                                                
  };                                                                              
                                                                                
/*---------------------------------------------*/

long     mR_LAT   (PFUNC_PAR);
long     mR_CMAP  (PFUNC_PAR);
long     mR_OBJ3D (PFUNC_PAR);
long     mR_PLOT  (PFUNC_PAR);

long     mW_LAT (PFUNC_PAR); 
long     mRotL  (PFUNC_PAR); 

long     mData  (PFUNC_PAR);
long     mColor (PFUNC_PAR);
long     mScale (PFUNC_PAR);
long     mCut   (PFUNC_PAR);
long     mBody  (PFUNC_PAR);
long     mSlice (PFUNC_PAR);
long     mPress (PFUNC_PAR);
long     mL_C   (PFUNC_PAR);
long     mSlines (PFUNC_PAR);

long     mPLOT   (PFUNC_PAR);
long     mLat3d  (PFUNC_PAR);
long     mPerson (PFUNC_PAR);
long     mMLAT   (PFUNC_PAR);

long     mOBJ3D  (PFUNC_PAR);
long     mIsVis  (PFUNC_PAR);
long     mSetka  (PFUNC_PAR);

long     mREND1 (PFUNC_PAR);
long     mREND2 (PFUNC_PAR);

long     mREND3 (PFUNC_PAR);
long     V3cube_proc (PFUNC_PAR);

/*--------------------------------------------*/

int      SvisRend (int num);

#define  Y_NONENAMES   (SVIS->none_names) 
#define RAD(grad) ((float)(grad) * 2 * (YPI) / 360)
#define GRAD(rad) ((float)(rad) * 360 / (2*YPI) )

/*=====================data, methods, functions==========================*/

typedef struct {
  YT_SPACE x;
  YT_SPACE y;
} VT_P2D;

typedef struct {
  YT_SPACE x;
  YT_SPACE y;
  YT_SPACE z;
} VT_P3D;
void     VSetPoint3D (VT_P3D *, YT_SPACE, YT_SPACE, YT_SPACE);

typedef struct {
  VT_P3D *pts;
  int     uu, vv;
  VT_P3D  center;
} VT_SETKA;
void     VSetkaInit (VT_SETKA *, int, int);
VT_P3D  *VSetkaPts (VT_SETKA *, int, int);


typedef struct {
  YT_SPACE a, b, c, d;
} VT_PLANE;

typedef struct {
  YT_BOOL tria;
  int     u1, u2, u3, u4;
} VT_POLI;

typedef VT_P3D VT_VECTOR;
typedef struct {
  YT_BOOL tria;
  VT_P3D *p1, *p2, *p3, *p4;
  int     u1, u2, u3, u4;
} VT_POL;

typedef struct {
  int      num_uzel, num_poli;
  VT_P3D  *uzel;
  VT_POLI *poli;
  VT_P3D   center;
 /*  VT_GRAF *graf; */
} VT_SURF;

VT_SURF *VSurfCreate (int, int);
void     VSurfCalcCenter (VT_SURF *);
void     VSurfGetPol (int, VT_SURF *, VT_POL *);
void     VSurfPutPol (int, VT_SURF *, int, int, int, int);
void     VSurfRenameUzel (VT_SURF *, int, int);
YT_BOOL  VSurfCheckUzel (VT_SURF *, int);
VT_P3D  *VSurfUzel (VT_SURF *, int);
VT_SURF *VSurfDeleteUzels (VT_SURF *, YT_BOOL *);
YT_SPACE VSurfMinSize (VT_SURF *);

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

typedef struct {
  YT_SPACE x;
  YT_SPACE y;
  YT_SPACE z;
  YT_COLOR color;
} VT_CPOINT;

typedef struct {
  VT_CPOINT *p1;
  VT_CPOINT *p2;
  YT_COLOR *c;
} VT_PLINE3D;

typedef struct {
  VT_CPOINT *p1;
  VT_CPOINT *p2;
  VT_CPOINT *p3;
  YT_COLOR *f_color;
  YT_COLOR *l_color;
} VT_PTRI3D;

typedef struct {
  YT_BOOL existed;
  YT_BOOL visible;
  char   *tname;
  /* int     type; */
  char   *name;
  void   *p;
  long    long1;
  long    long2;
  long    long3;
  long    long4;
} VT_OBJ3D;
void  V3ObjInit (VT_OBJ3D *, char *tname, char *, void *, long, long, long, long);

typedef struct {
  YT_SPACE *x;
  YT_SPACE *y;
  YT_SPACE *z;
  YT_COLOR *color;
} VT_CPOINTP;

typedef struct {
  VT_CPOINT p1;
  VT_CPOINT p2;
  VT_CPOINT p3;
  YT_COLOR f_color;
  YT_COLOR l_color;
} VT_TRI3D;

typedef struct {
  VT_CPOINT p1, p2, p3, p4;
  YT_COLOR color;
} VT_FOUR;

typedef struct {
  VT_P3D  p1, p2, p3, p4, p5, p6, p7, p8;
} VT_BOX;

typedef struct {
  VT_P3D  v0, v1, v2, v3;
} VT_SLICEXOR;

#define A_VOL3D(vol3d,i,l)     (*(vol3d->p+ BB(0,vol3d->ii, i,l) )) /*??*/
typedef struct {
  YT_SPACE z0, zW, h0, hW;
  int     cellsize;
  YT_BOOL check;
} VT_PROBE3D;

#define DD_MAX  20
typedef struct {
  int     izm;
  YT_SPACE *pcoor;
  YT_SPACE *pdata;
  YT_COLOR *pcats;
  int     ii, jj, kk;
  int     dd, dsel;
  VT_BOX  box;
  char   *data_names[DD_MAX + 1];
  YT_SPACE hmin[DD_MAX];
  YT_SPACE hmax[DD_MAX];
  YT_BOOL srez;
  int     islice, jslice, kslice;
} VT_LAT;
long    VLAT (void *, long, int, long, long, long, long);
void    VLAT_put (void *lat, int i, int j, int k, int d, long pdata);

typedef struct {
  VT_LAT *lat;
  int     i1, i2, j1, j2, k1, k2;
  YT_BOOL i1_lines, i2_lines, j1_lines, j2_lines, k1_lines, k2_lines;
  YT_BOOL i1_polys, i2_polys, j1_polys, j2_polys, k1_polys, k2_polys;
  YT_BOOL full_points, points_min, points_max;
  YT_BOOL full_lines, full_colored;
  YT_BOOL full_isosurf;
  int     full_isurf;
  YT_BOOL ijk_box;
  VT_BOX  box;
} VT_TELO;
VT_TELO *V3TeloCreate (void);
void     V3TeloInit (VT_TELO *, VT_LAT *);

typedef YT_BOOL (*VT_FLINES3D) (int, YT_SPACE *, YT_SPACE *, YT_SPACE *, 
                YT_SPACE *, YT_SPACE *, YT_SPACE *,long);

typedef struct {
  YT_SIZET ii;
  YT_SIZET dd;
  YT_SPACE *p;
  YT_BOOL scale_isit;
  YT_SPACE scale_x, scale_y, scale_z;
  VT_PROBE3D probe3d;
} VT_VOL3D;
YT_BOOL   VLatCreateVOL (VT_VOL3D *, int, int);

int      *VIlistCreate (int, int);
YT_SPACE *VListCreate (int);
void      VListPut (YT_SPACE *, int, YT_SPACE);
 
YT_SPACE VLenOtrezok (VT_P3D *, VT_P3D *);
YT_SPACE VVecLenght (VT_VECTOR *);
void     VVecMultVec (VT_VECTOR *, VT_VECTOR *, VT_VECTOR *);
YT_SPACE VVecMult (VT_VECTOR *, VT_VECTOR *);

YT_BOOL  VPlaneFromTri (VT_P3D *, VT_P3D *, VT_P3D *, VT_PLANE *);
YT_BOOL  VVisibleFromTri (VT_P3D *, VT_P3D *, VT_P3D *, VT_P3D *, VT_P3D *);
YT_BOOL  VPlaneIsOneside (VT_P3D *, VT_P3D *, VT_P3D *, VT_P3D *, VT_P3D *);
YT_SPACE VPlanePointHislo (VT_PLANE *, VT_P3D *);
YT_SPACE VPlaneToPoint (VT_PLANE *, VT_P3D *);

YT_BOOL  IsvisPoints (VT_OBJ3D *pobj, VT_P3D *s, VT_P3D *t);

YT_BOOL  V1PlotAdd (VT_W1D *, VT_PLOT *);

/*==============================modules=====================================*/

void     V1DrawMain (VT_W1D *);
void     V1CalcMinMax (VT_W1D *);
void     V1DrawFrame (VT_W1D *, int, int, int, int, int, int);
void     V1DrawAll (VT_W1D *, int, int, int, int);
void     V1DrawOne (VT_W1D *, VT_PLOT *, int, int, int, int);
void     V1DrawLegends (VT_W1D *, int, int);
void     V1DrawAxeX (int, int, int, YT_COLOR, YT_SPACE, YT_SPACE, int);
void     V1DrawAxeY (int, int, int, YT_COLOR, YT_SPACE, YT_SPACE, int);

/*-----------------------------------*/
/*--------------D3 Library-----------*/
/*-----------------------------------*/

void  D3_Start (void);

typedef YT_SPACE VT_ZBUFVAL;
typedef struct {
  YT_SPACE    xmin3d, ymin3d, zmin3d, xmax3d, ymax3d, zmax3d;
  YT_BOOL     prints, calcus;
  VT_ZBUFVAL *zbuf_ptr;
  int         zbuf_w, zbuf_h;
  YT_BOOL     zbuf_flag;
  VT_ZBUFVAL  zbuf_eps_line, zbuf_eps_reps, zbuf_eps_text;
  YT_SPACE    zbuf_zplane;
  YT_BOOL     v3_light, v_guro;
  char       *ptr_fonts;
  YT_BOOL     is_colbuf;
  long        pm;
  void       *buffer;
} VT_REND3;

extern VT_REND3 sss;
#define SSS sss

#define  PRINTS		 SSS.prints
#define  CALCUS	         SSS.calcus
#define  ZBUFF_val(x,y)  SSS.zbuf_ptr[(x-1)*ZBUFF_h+y-1]
#define  ZBUFF_flag     (SSS.zbuf_flag)
#define  ZBUFF_ptr      (SSS.zbuf_ptr)
#define  ZBUFF_w        (SSS.zbuf_w)
#define  ZBUFF_h        (SSS.zbuf_h)
#define  ZBUFF_zditto	-12345.6789
#define  ZBUFF_eps_line (SSS.zbuf_eps_line)
#define  ZBUFF_eps_reps (SSS.zbuf_eps_reps)
#define  ZBUFF_eps_text (SSS.zbuf_eps_text)
#define  V3_LIGHT        SSS.v3_light
#define  V_GURO          SSS.v_guro

#define  ZBUFF_zplane   (SSS.zbuf_zplane)

#define  MAXZBUFVAL      YMAXSPACE

typedef struct {
  YT_SPACE cx, cy, w, h;
  YT_SPACE cube_x0, cube_y0, cube_z0, cube_size;
  int      alfa, beta;
  int      scrx, scry, scrw, scrh;
  YT_COLOR background;
  YT_SPACE zplane, zview;
  YT_BOOL  zview_flag;
  YT_BOOL  xzy_box, boxing;
  int      repers;
  YT_COLOR repers_color;
  YT_BOOL  guro, light;
  void    *cmap;
} VT_CAM3D;

#define MAX_OBJ3D 10
typedef struct {
  VT_CAM3D *cam3d;
  VT_BOX    xzy_box;
  VT_OBJ3D *o3d[MAX_OBJ3D];
  VT_OBJ3D *xorr;
} VT_W3D;

long     W3D (void *, long, int, long, long, long, long);
/* VT_W3D  *D3_WorldCreate(void); */
void     D3_WorldDelete(VT_W3D *w3d);
void     D3_CamDelete (VT_CAM3D *cam3d);

void     D3_WorldClear(VT_W3D *w3d);
YT_BOOL  D3_WorldAddTo (VT_W3D *, VT_OBJ3D *);

void     D3_DrawWorld (VT_W3D *, int, int, int);
void     D3_DrawAll (VT_W3D *);
void     D3_DrawCube (VT_CAM3D *, YT_SPACE, YT_SPACE, YT_SPACE, YT_SPACE, YT_COLOR color);
void     D3_DrawPlines (VT_CAM3D *, VT_OBJ3D *);
void     D3_DrawFlines (VT_CAM3D *, VT_OBJ3D *);
void     D3_DrawSetka (VT_CAM3D *, VT_OBJ3D *);
void     D3_DrawMarkerS (VT_CAM3D *cam3d, VT_OBJ3D *obj3d);
void     D3_DrawPoints (VT_CAM3D *, VT_OBJ3D *);
void     D3_DrawTri (VT_CAM3D *, VT_PTRI3D *);
void     D3_DrawTriang (VT_CAM3D *, VT_TRI3D *);
YT_BOOL  D3_DrawPoint (VT_CAM3D *, YT_SPACE, YT_SPACE, YT_SPACE, YT_COLOR);
void     D3_DrawLine (VT_CAM3D *, YT_SPACE, YT_SPACE, YT_SPACE, YT_SPACE, YT_SPACE, YT_SPACE, YT_COLOR);
void     D3_DrawXor (VT_W3D *);
void     D3_DrawBox (VT_CAM3D *, VT_BOX *, YT_COLOR);
void     D3_DrawRepers (VT_CAM3D *);
void     D3_DrawFour (VT_CAM3D *, VT_FOUR *);
void     D3_DrawSlice (VT_VOL3D *, VT_CAM3D *); /*??*/
void     D3_DrawSurf (VT_CAM3D *, VT_OBJ3D *);
void     D3_DrawTeloMain (VT_CAM3D *, VT_OBJ3D *);
void     D3_DrawTeloIJKBox (VT_CAM3D *, VT_TELO *);
void     D3_DrawTeloEdge (VT_CAM3D *, VT_TELO *, int, int, int);
void     D3_DrawTeloPlaneIJK (int, VT_CAM3D *, VT_TELO *, int, int, int, YT_BOOL);
void     D3_DrawTeloFullBody (int, VT_CAM3D *, VT_TELO *, YT_BOOL);

void     D3_SetRotate(VT_CAM3D *cam3d, int  alfa, int  beta);
void     D3_GetRotate(VT_CAM3D *cam3d, int *alfa, int *beta);
void     D3_RotateOX (YT_SPACE rad_alfa, YT_SPACE *px, YT_SPACE *py, YT_SPACE *pz);
void     D3_RotateOY (YT_SPACE rad_alfa, YT_SPACE *px, YT_SPACE *py, YT_SPACE *pz);
void     D3_Viewport (VT_CAM3D *cam3d, int x, int y, int w, int h);

void     D3_LightShow (void);
void     D3_LightHide (void);
YT_COLOR D3_LightDo (YT_COLOR, float);
void     D3_GuroYes (void);
void     D3_GuroNot (void);
YT_BOOL  D3_ZbufBegin (int, int);
void     D3_ZbufEnd (void);
YT_BOOL  D3_ZbufPut (int, int, YT_SPACE);
void     D3_SetMinmax (VT_W3D *);
void     D3_PointToScreen (VT_CAM3D *, YT_SPACE, YT_SPACE, YT_SPACE, int *, int *, YT_SPACE *);
void     D3_TransAndRot (VT_CAM3D *, YT_SPACE *, YT_SPACE *, YT_SPACE *);
void     D3_PlaneToScreen (VT_CAM3D *, YT_SPACE, YT_SPACE, int *, int *);
/* void     D3_Proection (VT_P3D *, YT_SPACE *, YT_SPACE *, VT_P3D *, VT_P3D *, VT_P3D *); */
void     D3_SetCube (VT_CAM3D *);

typedef struct {
  int     i, x, y, delta_x, delta_y, exchange, err, incx, incy;
  int     x_old, y_old, x_left, x_right;
  YT_BOOL begin, end;
  int     align;
} VT_HANDLINE;

int      VHandLineGetX (VT_HANDLINE *line);
YT_BOOL  VHandPLineFuncOld (VT_HANDLINE *, YT_BOOL, int *, int *, int *, int *, int);
YT_BOOL  VHandPLineFunc (VT_HANDLINE *, YT_BOOL, int *, int *, int *, int *, int);
YT_BOOL  VHandLineFunc (VT_HANDLINE *, YT_BOOL, int *, int *, int *, int *);

void     VHandLoadFont (void);
void     VHandText (int x0, int y0, char *text, YT_COLOR color, YT_SPACE);
void     VHandPLine (int, int, int, int, YT_COLOR);
void     VHandLine (int, int, int, int, YT_COLOR, YT_SPACE, YT_SPACE);
void     VHandHorzTriF (int, int, int, int, int, YT_COLOR, YT_SPACE, YT_SPACE, YT_SPACE, int, int, int);
void     VHandTriF (int, int, int, int, int, int, YT_COLOR, YT_SPACE, YT_SPACE, YT_SPACE,YT_COLOR, YT_COLOR, YT_COLOR);
YT_BOOL  VHandPixel (int, int, YT_COLOR, YT_SPACE);
void     VHandRectF (int, int, int, int, YT_COLOR);
void     VHandRectB (int, int, int, int, YT_COLOR);

/*-----------------------------------*/
/*-----------------------------------*/

/*================== functions -> modules ========================*/

void      VLatToSlice3 (VT_LAT *, void *);
VT_LAT   *VLat2From3 (VT_LAT *);
VT_LAT   *VLat1From2 (VT_LAT *);
void     *VLatCmapFrom2 (VT_LAT *);
YT_BOOL   VLatMakeCats (VT_LAT *);
VT_W1D   *VLatToW1D (VT_LAT *);
/* void      VSetkaFromLat2 (VT_SETKA *, VT_LAT *lat); */
void      VSetkaFromLat3 (VT_SETKA *setka, VT_LAT *lat3);
YT_SPACE  VFuncXYZ (int, YT_SPACE, YT_SPACE, YT_SPACE);
void      V3TeloMakeIsosurf (VT_TELO *, VT_OBJ3D *);
void      VSetkaSetSizes (VT_SETKA *setka_old, int uu_new, int vv_new);
void      VSetkaMakeTest (VT_SETKA *, int, int, int, YT_SPACE);
void      VSurfKleying (VT_SURF **, YT_SPACE);
/* VT_GRAF  *VSurfMakeGraf (VT_SURF *); */
VT_SURF  *VSurfFromSetka (VT_SETKA *, YT_BOOL, YT_SPACE);
VT_SURF  *VSurfSlice (VT_SURF *, VT_PLANE *, YT_SPACE);

YT_BOOL   VSurfIsvisPoint (VT_SURF *, VT_P3D *, VT_P3D *, int);
void      VSurfCheckVisible (VT_P3D *, VT_SURF *, YT_BOOL *);
YT_BOOL  *VSurfVisibleHorizon (VT_SURF *, YT_BOOL *);
void      VSurfCheckBadFour (VT_SURF *);
void      VSurfChangeCheck (VT_SURF *, YT_BOOL *, YT_BOOL *);
VT_SURF  *VSurfChangeMake (VT_SURF *, YT_BOOL *, YT_BOOL *);

/*---------------------------------------------------------------*/

typedef struct {
  YT_SPACE hmin, hmax;
  int      xrel, yrel;
} VT_CDAT;
extern VT_CDAT cdat_glob;

void   VMaping (VT_CDAT *, YT_SPACE *, int *, YT_BOOL);
void   VDrawLegend (int, int, int, int);

/*=============================================*/

typedef struct {
  char   **none_names;
  int    hRamka1, hRamka2, hRamka3, 
         hConsole; 
} VT_SVISOR;
#define  SVIS ((VT_SVISOR*)YGet("psvis"))

/*--------------------------------------------*/

#ifdef __cplusplus
}
#endif
#endif  /* _SVISOR_H */

/******************************************************************************/
