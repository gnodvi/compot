// -*-  mode: c    ; coding: koi8   -*- ----------------------------------------

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
#include <math.h> 
 
#include "yma-kernel.h" 
       
/*-----------------------------------------------------------------------*/ 
 
/* YT_COLOR new_darkgray;  */
/* YT_COLOR new_yellow;  */
/* YT_COLOR new_blue;  */
/* YT_COLOR new_outlines[32];  */
 
/*----------------------------vec.h--------------------------------------*/ 
 
typedef struct { 
   double x, y; 
} Vec, *pVec; 
 
Vec*   zero_vec (void); 
Vec*   new_vec (double x, double y); 
Vec*   vec_copy (Vec*); 
void   vec_clear (Vec*); 
void   vec_diff (Vec* vec1, Vec* vec2, Vec* vec3); 
void   vec_add (Vec* vec1, Vec* vec2); 
void   vec_smul (Vec* vec, double scalar); 
void   vec_sdiv (Vec* vec, double scalar); 
void   vec_limit (Vec* vec, double lim); 
void   vec_setmag (Vec* vec, double mag); 
double vec_rdist (Vec* vec1, Vec* vec2); 
  
/*------------------------------boid.h-------------------------------------*/ 
 
typedef struct { 
   Vec *pos, *vel; 
   Int X,Y; 
   int onscreen; /* boolean */ 
} _Boid, *Boid; 
 
Boid new_boid (Int W, Int H); 
void boid_perspective (Boid boid, Int W, Int H); 
int  boid_isonscreen (Boid boid, Int W, Int H); 
void boid_move1 (Boid boid, Boid allboids[], int numboids, 
	       Vec* real_center, Vec* real_avgvel, 
	       Int W, Int H); 
Vec* boid_av_vel (Boid boid, Vec* real_avgvel, int numboids); 
Vec* boid_chill_out (Boid boid, Boid boids[], int numboids, double); 
 
int    map; 
Boid  *boids; 
Vec   *center, *avg_velocity; 
int    numboids; 
Int    width, height; 
int    algorifm;
double mashtab;
int    is_boids, is_drops;
int    middle_h, top_h;
int    left_w, left_h;
    
/*======================================================================*/

/* int id; */
int h_main, h_left, h_right, h_top, h_middle;
Int ww;
double world_x, world_y, world_w, world_h; 

int  hWinlist;

/*----------------------------draw_boid-------------------------------*/ 
void  
draw_boid (Boid boid) 
{ 

  YDrawCircB (boid->X, boid->Y, 10, YColor("yellow"));
  return;

}    
/*----------------------------zero_vec--------------------------------*/ 
Vec* 
zero_vec (void) 
{ 
  Vec* vec; 
	 
  vec = new_vec (0, 0);

  return vec; 
} 
/*----------------------------new_vec--------------------------------*/ 
Vec* 
new_vec (double x, double y) 
{ 
  Vec* vec; 
	 
  vec = (Vec*) malloc (sizeof(Vec)); 
  vec->x = x; vec->y = y; 
  
  return vec; 
} 
/*----------------------------vec_copy-------------------------------*/ 
Vec* 
vec_copy (Vec* v1) 
{ 
  Vec* vec; 
	 
  vec = zero_vec(); 
  vec->x = v1->x; vec->y = v1->y; 
  return vec; 
} 
/*----------------------------vec_clear------------------------------*/ 
void 
vec_clear (Vec* vec) 
{ 
  vec->x = vec->y = 0; 
} 
/*---------------------------vec_diff--------------------------------*/ 
void 
vec_diff (Vec* vec1, Vec* vec2, Vec* vec3) 
{ 
  vec3->x = vec1->x - vec2->x; 
  vec3->y = vec1->y - vec2->y; 
} 
/*---------------------------vec_add---------------------------------*/ 
void 
vec_add (Vec* vec1, Vec* vec2) 
{ 
  vec1->x += vec2->x; 
  vec1->y += vec2->y; 
} 
/*--------------------------vec_smul--------------------------------*/ 
void 
vec_smul (Vec* vec, double scalar) 
{ 
  vec->x *= scalar; 
  vec->y *= scalar; 
} 
/*------------------------vec_sdiv----------------------------------*/ 
void 
vec_sdiv (Vec* vec, double scalar) 
{ 
  vec->x /= scalar; 
  vec->y /= scalar; 
} 
/*------------------------------------------------------------------
 *      Limit the length of the longest 
 *      component to lim, while keeping others 
 *      in proportion 
 *------------------------------------------------------------------*/ 
void 
vec_limit (Vec* vec, double lim) 
{ 
  double m, f; 
	 
  m = YMAX (fabs(vec->x), fabs(vec->y)); 
	 
  if (m <= lim) return; 
	 
  f = lim/m; 
  vec_smul (vec, f); 
} 
/*------------------------------------------------------------------*/ 
/* 
 * Set the magnitude of the vector to a 
 * particular value 
 */ 
void vec_setmag (Vec* vec, double mag) 
{ 
  double m,f; 
	 
  m = YMAX(fabs(vec->x), fabs(vec->y)); 
	 
  f = mag/m; 
  vec_smul(vec, f); 
} 
/*--------------------------------vec_rdist--------------------------- 
 * Rectangular (ie. min component) distance 
 * between this and vec2 
 *-------------------------------------------------------------------*/ 
double  
vec_rdist(Vec* vec1, Vec* vec2) 
{ 
  double dx,dy, dm; 
    
  dx = vec1->x - vec2->x; 
  dy = vec1->y - vec2->y; 
	 
  dm = YMAX(fabs(dx), fabs(dy)); 
	 
  return dm; 
} 
/*-----------------------------boid.c--------------------------------*/ 
 
#define rrand(a) (rand()%a) 
 
/*----------------------------new_boid-------------------------------*/ 
Boid  
new_boid (Int W, Int H) 
{ 
  Boid   boid; 
  double px,py; 
  double vx,vy; 
	 
  boid = (Boid)malloc(sizeof(_Boid)); 
	 
  /* 	px = (double)(rrand((W<<4)) - (W<<3));  */
  /* 	py = (double)(rrand((H<<4)) - (H<<3));  */
  px = (double)(YRandF(world_x,world_x+world_w)); 
  py = (double)(YRandF(world_y,world_x+world_h)); 
	 
  boid->pos = new_vec (px,py); 
	 
  /* 	vx = (double)(rrand(51) - 25);  */
  /* 	vy = (double)(rrand(51) - 25);  */
  /* 	vx = (double)(YRandF(-25,25));  */
  /* 	vy = (double)(YRandF(-25,25));  */
  vx = (double)(YRandF(-5,5)); 
  vy = (double)(YRandF(-5,5)); 
	 
  boid->vel = new_vec (vx,vy); 
	  
  return boid; 
} 
/*--------------------------boid_perspective-------------------------*/ 
void  
boid_perspective (Boid boid, Int W, Int H) 
{ 
  double zfactor; 
	 
  /* 	zfactor = 30.0;  */
  /* 	zfactor = 0.1 * mashtab;  */
  /* 	zfactor = 0.1 * W;  */
  zfactor = 0.0003 * mashtab * W; 
  /* 	zfactor = 45.0* mashtab / W;  */
  /* 	zfactor = 45.0*mashtab / W;  */
  /* 	zfactor = 4500.0 / W;  */
  /* 	zfactor = 1;  */
		 
  boid->X = W/2 + (int)(boid->pos->x/zfactor); 
  boid->Y = H/2 + (int)(boid->pos->y/zfactor); 
		 		 
  boid->onscreen = boid_isonscreen (boid, W,H); 
	 
} 
/*-----------------------------------------------------------------*/ 
int 
boid_isonscreen (Boid boid, int W, int H) 
{ 

  return (boid->X>=0 && boid->X<W && boid->Y>=0 && boid->Y<H); 

} 
/*-----------------------------------------------------------------*/ 
Vec* 
boid_chill_out (Boid boid, Boid boids[], int numboids, double radius) 
{ 
  Vec *chill, *bigchill; 
  int i; 
	 
  chill = zero_vec(); 
  bigchill = zero_vec(); 
	 
  for (i=0; i<numboids; i++) { 
    if (boids[i] == boid) continue; 
    if (vec_rdist(boid->pos, boids[i]->pos) > radius) continue; 
    // если точка в пределах окрестности-прямоугольника
    // bigchill = bigchill + (pos - boids[i]->pos);
    vec_diff (boid->pos, boids[i]->pos, chill); 
    vec_add (bigchill, chill); 
  } 
	 
  free(chill); 
	 
  return bigchill; 
} 
/*----------------------------------------------------------------------*/ 
void 
boid_move1 (Boid boid, Boid allboids[], int numboids, 
	    Vec* real_center, Vec* real_avgvel, Int W, Int H) 
{ 
  Vec  center_bias; 
  Vec  avgvel_bias; 
  Vec *chilling;

  YT_BOOL to_mid_pos = 0;
  YT_BOOL to_mid_vel = 0;
  YT_BOOL to_out_rad = 1;

  double dd = mashtab/10;
  double radius = mashtab;
  double limit = mashtab;
	 
  vec_clear (&center_bias); 
  vec_clear (&avgvel_bias); 

  // связность:   перемещение с средней позиции
  if (to_mid_pos) {
    vec_diff (real_center, boid->pos, &center_bias); 
    vec_sdiv (&center_bias, 1.28*mashtab); 
    vec_add (boid->vel, &center_bias);
  }
	
  // выравнивание: стремление к среднему направлению
  if (to_mid_vel) {
    vec_diff (real_avgvel, boid->vel, &avgvel_bias); 
    vec_sdiv (&avgvel_bias, 0.08*mashtab); 
    vec_add (boid->vel, &avgvel_bias); 
  }
	
  // разделение: стремление покинуть соседей по окрестности
  if (to_out_rad) {
    chilling = boid_chill_out(boid, allboids, numboids, radius); 
    vec_sdiv (chilling, mashtab/50); 
    vec_add (boid->vel, chilling); 
  }
	 
  //vec_add (boid->vel, &center_bias); 
  //vec_add (boid->vel, &avgvel_bias); 
  //vec_add (boid->vel, chilling); 

  vec_limit (boid->vel, limit); 
  vec_add (boid->pos, boid->vel); 
	 
  free(chilling); 
	     
  /*------- bound world -------*/
  if (boid->pos->x < world_x)          boid->vel->x += dd;  
  if (boid->pos->x > world_x+world_w)  boid->vel->x -= dd; 
  if (boid->pos->y < world_y)          boid->vel->y += dd; 
  if (boid->pos->y > world_y+world_h)  boid->vel->y -= dd; 

  boid_perspective (boid, W, H); 

} 
/*---------------------------boid_move2-----------------------------------*/ 
void 
boid_move2 (Boid boid, Boid allboids[], int numboids, Int W, Int H) 
{ 
  double world_x, world_y, world_w, world_h; 
  int j;
  double xi, yi, xj, yj;
	 
  world_x = -1500;
  world_y = -1200;
  world_w =  3000;
  world_h =  2000;

  for (j=0; j<numboids; j++) {
    xi = boid->pos->x; 
    yi = boid->pos->y; 
    xj = allboids[j]->pos->x; 
    yj = allboids[j]->pos->y;
    /* s = sqrt ((x); */
    if ((xi-xj)*(xi-xj) + (yi-yj)*(yi-yj) > 100) continue;
    /* 				 drops[i]->vx = drops[i]->vx + drops[j]->vx; */
    /* 				 drops[i]->vy = drops[i]->vy + drops[j]->vy; */
    xi = xi + allboids[j]->vel->x;
    yi = yi + allboids[j]->vel->y;
    if (xi < 0) xi = world_w;
    if (yi < 0) yi = world_h;
    if (xi > world_w)  xi = 0;
    if (yi > world_h)  yi = 0;
    YDrawCircB ((int)xi, (int)yi, 10, YColor("yellow"));
    boid->pos->x = xi;
    boid->pos->y = yi;
  }
	
  boid_perspective (boid, W, H); 
	
} 
/*-------------------------------calc_proc----------------------------*/  
long  
calc_proc (PFUNC_VAR)  
{
  
  static int hBoids, hDrops, hNum;
  static int n_min=1, n_max=100, n=30;
  
  switch (message) {  
  case YOPEN:  
    break; 
  case YDRAW: 
    YDrawRectF (0, 0, WND_w, WND_h, YColor("silver"));           
    YBeginGroup ("Algorifm", 20, 20, 140, 100, YColor("white")); 
    YWndGroupBegin (); 
    YWnd (&hBoids,   CHECK,  "Boids",  20,20, 25, 25, 0,LP(is_boids),0,0, YColor("lime"));
    YWnd (&hDrops,   CHECK,  "Drops",  20,50, 25, 25, 0,LP(is_drops),0,0, YColor("lime"));
    YWndGroupEnd (); 
    YEndGroup ();
    YBeginGroup ("Misc", 20, 130, 140, 100, YColor("white")); 
    /*     YWnd (&hNum, DECIMAL, "Num", 90,20, 40, 25, 0,n_min,n_max,LP(n), YColor("lime"));  */
    YEndGroup ();
    break; 
  case YCLOSE:
    YDelWindow (id);
    break; 
  default: ;;;;  
  }  
  
  RETURN_TRUE;  
}  
/*-------------------------------demo_proc----------------------------*/  
long  
demo_proc (PFUNC_VAR)  
{ 
  static int hCheck=ID_NULL;
  static int hDecimal=ID_NULL;
  static int xx_min=1, xx_max=100, xx;
  
  switch (message) {  
  case YOPEN:  
    break; 
  case YDRAW: 
    YDrawRectF (0, 0, WND_w, WND_h, YColor("aqua"));           
    YBeginGroup ("Demo", 20, 20, 150, 100, YColor("silver")); 
    YWnd (&hCheck,   CHECK,   "CHECK",   20,20, 25, 25, TRUE,0,0,0, YColor("fuchsia")); 
    YWnd (&hDecimal, DECIMAL, "DECIMAL", 90,55, 40, 25, 0,xx_min,xx_max,LP(xx), 
	  YColor("fuchsia")); 
    YEndGroup ();
    break; 
  case YLMOUSEDOWN:  
    printf ("YLMOUSEDOWN-new \n");  
    break;  
  case YRMOUSEDOWN:  
    printf ("YRMOUSEDOWN-new \n");  
    break;  
  case YLMOUSEUP:  
    printf ("YLMOUSEUP-new \n"); 
    YSend (WND_parent, YPUSH, 0,0,0,0); 
    break;  
  case YCLOSE:
    YDelWindow (id);
    break; 
  default: ;;;;  
  }  
  
  RETURN_TRUE;  
}  
/*-------------------------------win1_proc----------------------------*/  
long  
win1_proc (PFUNC_VAR)  
{ 
  static int h1, h2;
  
  switch (message) {  
  case YOPEN:  
    break; 
  case YDRAW: 
    YDrawRectF (0, 0, WND_w, WND_h, YColor("lime"));           
    YWnd (&h1,  PUSH,  "CALC",  50, 50, 100, 150, 0,0,0,0, YColor("white"));
    YWnd (&h2,  PUSH,  "DEMO", 160, 50, 100, 150, 0,0,0,0, YColor("white"));
    break; 
  case YPUSH: 
    if (mes1 == h1)
      YSend (hWinlist, YKEYWORD1, (long)calc_proc,0,0,0);
    if (mes1 == h2)
      YSend (hWinlist, YKEYWORD1, (long)demo_proc,0,0,0);
    break; 
  case YCLOSE: 
    YDelWindow (id);
    break; 
  default: ;;;;  
  }  
  
  RETURN_TRUE;  
}  
/*--------------------------------WINLIST-----------------------------*/  
long  
WINLIST (PFUNC_VAR)  
{  
#define NUM_ITEM 10 
  static YT_PFUNC Items[NUM_ITEM]; 
  static int  cur; 
  static int hUp=ID_NULL, hText=ID_NULL, hWin=ID_NULL;
  Int w_push=80, h_push=30;
  
  switch (message) {  
  case YOPEN:  
    cur = -1; 
    hWin = ID_NULL; 
    YGoto (YADDITEM, (long)win1_proc, 0, 0, 0); 
    break; 
  case YDRAW: 
    YWnd (&hUp,   PUSH,  "..", 0, 0, w_push, h_push, 0,0,0,0, YColor("green"));
    YDrawRectF (w_push, 0, WND_w-w_push, h_push, YColor("yellow"));           
  case YDRAWITEM: 
    /* 		if (cur != 0)  { */
    /* 			printf ("WndDestroy cur=%d \n", cur); */
    /* 			YWndDestroy (hWin); */
    /* 		} */
    YWinBegPaint (id);   
    YWnd (&hWin,  Items[cur],  "Cur-1", 0, h_push, WND_w, WND_h, 0,0,0,0, CLR_DEF);
    YWinEndPaint (id);   
    break; 
  case YKEYWORD1: 
    YGoto (YADDITEM, mes1, 0, 0, 0); 
    YModeType (TRUE, YOPEN); 
    YGoto (YDRAWITEM, 0, 0, 0, 0); 
    YModeType (FALSE, YOPEN); 
    break; 
  case YADDITEM: 
    printf ("YADDITEM \n");
    cur++;
    Items[cur] = (YT_PFUNC)mes1; 
    break; 
  case YDELITEM: 
  case YPUSH: 
    if (cur == 0) 
      break; 
    YWndDestroy (hWin);  
    YWnd (&hWin,  Items[cur],  "Cur-2", 0, h_push, WND_w, WND_h, 0,0,0,0, CLR_DEF);
    cur--;
  case YCLOSE: 
    break; 
  default: ;;;;  
  }  
  
  RETURN_TRUE;  
}  
/*--------------------------right_init-----------------------------*/
void
right_init (int numboids, Int width, Int height)
{
  int i; 

  YWinBegPaint (h_right);   
  map = YWinMapGet (h_right);   
  YWinMapSet (map); 
  YDrawRectF (0,0, width,height, blk);
  YWinMapSet (0); 
  YWinEndPaint (h_right); 

  /* freshmap   = YCreatePixmap(id);  */
 
  boids = (Boid *) calloc (numboids, sizeof(_Boid)); 
  for(i=0; i<numboids; i++) { 
    boids[i] = new_boid (width, height); 
  } 

  center = zero_vec(); 
  avg_velocity = zero_vec(); 
    
  /* YSetWindowPixmap (id, freshmap);  */

} 
/*--------------------------right_step-----------------------------*/
void
right_step (int algorifm, int numboids, Int width, Int height)
{
  int i;

  /* YCopyPixmaps (background, freshmap, width, height);  */
  YWinBegPaint (h_right);    
  YWinMapPut (h_right, map);   
	
  switch (algorifm) {
  case 1:
    vec_clear (center); 
    vec_clear (avg_velocity); 
    for(i=0; i<numboids; i++) { 
      vec_add (center, boids[i]->pos); 
      vec_add (avg_velocity, boids[i]->vel); 
    } 
    vec_sdiv (center, (double)(numboids-1));  
    vec_sdiv (avg_velocity, (double)(numboids-1)); 
    break;
  case 2:
    break;
  }
	

  for(i=0; i<numboids; i++) { 
    switch (algorifm) {
    case 1:
      boid_move1 (boids[i], boids, numboids, center, avg_velocity, width, height);
      break;
    case 2:
      boid_move2 (boids[i], boids, numboids, width, height); 
      break;
    }
		
    if(boids[i]->onscreen) { 
      /* YBeginPaint (freshmap, YPIX);   */
      /* draw_boid (boids[i], freshmap); */
			
      draw_boid (boids[i]); 
    } 
  } 
	
  YWinEndPaint (h_right);  
  YFlush (); 
	
  return;
}
/*-----------------------------middle_proc--------------------------*/  
long  
middle_proc (PFUNC_VAR)  
{ 
  static int hExit=ID_NULL, hStart=ID_NULL, hStop=ID_NULL, hStep=ID_NULL;
  static int hContinue=ID_NULL, tim=ID_NULL;
  static int is_flag;
  
  switch (message) {  
  case YOPEN:  
    break; 
  case YDRAW: 
    YDrawRectF (0, 0, WND_w, WND_h, YColor("blue"));           
    YWnd (&hExit,     PUSH, "Exit",   10, 20, 55, 30, 0,0,0,0, YColor("green"));
    YWnd (&hStart,    PUSH, "Start",  70, 20, 55, 30, 0,0,0,0, YColor("red"));
    YWnd (&hStop,     PUSH, "Stop",  130, 20, 55, 30, 0,0,0,0, YColor("red"));
    YWnd (&hStep,     PUSH, "Step",  190, 20, 55, 30, 0,0,0,0, YColor("red"));
    YWnd (&hContinue, PUSH, "Cont",  250, 20, 55, 30, 0,0,0,0, YColor("red"));
    break; 
  case YPUSH:
    if (mes1 == hExit) YQuit (); 
    if (mes1 == hStart) {
      YRAND_S;
      if (is_boids) algorifm = 1;
      else          algorifm = 2;
      YKillTimer (tim); 
      right_init (numboids, world_w, world_h);
      tim = YSetTimer (id, 10); 
    }
    if (mes1 == hStop)  
      YKillTimer (tim); 
    if (mes1 == hContinue)  
      tim = YSetTimer (id, 10); 
    if (mes1 == hStep)  
      right_step (algorifm, numboids, world_w, world_h);
    break; 
  case YTIMER: 
    right_step (algorifm, numboids, world_w, world_h);
    break; 
  case YCLOSE: 
    break; 
  default: ;;;;  
  }  
  
  RETURN_TRUE;  
}  
/*-------------------------------right_proc---------------------------*/  
long  
right_proc (PFUNC_VAR)  
{  
  
  switch (message) {  
  case YOPEN:  
    world_x = 0;
    world_y = 0;
    world_w = WND_w;
    world_h = WND_h;
    break; 
  case YDRAW: 
    YDrawRectF (0, 0, WND_w, WND_h, YColor("black"));           
    break; 
  case YCLOSE: 
    YQuit (); 
    break; 
  default: ;;;;  
  }  
  
  RETURN_TRUE;  
}  
/*-----------------------------VISOR1--------------------------*/  
long  
VISOR1 (PFUNC_VAR)  
{  
  static VT_W1D *w1d;
  static VT_CAM1D *cam1d;
  
  switch (message) {  
  case YOPEN:  
    w1d = (VT_W1D*) mes1;
    break; 
  case YDRAW: 
    YDrawRectF (0, 0, WND_w, WND_h, YColor("white"));           
    /* break;  */
  case YREDRAW: 
    cam1d = w1d->cam1d;
    cam1d->scrx = 0;
    cam1d->scry = 0;
    cam1d->scrw = WND_w;
    cam1d->scrh = WND_h;

    YWinBegPaint (id);    
    V1DrawMain (w1d);
    YWinEndPaint (id);    
    break; 
  case YCLOSE: 
    YQuit (); 
    break; 
  default: ;;;;  
  }  
  
  RETURN_TRUE;  
}  
/*--------------------------------main_proc--------------------------*/  
long  
main_proc (PFUNC_VAR)  
{  
  static int ii = 100;
  static VT_PLOT *plot1, *plot2;
  static VT_W1D *w1d;
  static YT_SPACE x, y;
  int i;
  static VT_CAM1D *cam1d;
  static int count = 1;
  
  switch (message) {  
  case YOPEN:  
    w1d = V1Create ();
    V1Init (w1d, NULL, NULL, NULL);
    plot1 = V1PlotCreate ();
    plot2 = V1PlotCreate ();

    V1PlotInit (plot1, "legend-sin", ii);
    /* V1PlotInit (plot2, "legend-cos", ii); */
    V1PlotAdd (w1d, plot1);
    /* V1PlotAdd (w1d, plot2); */

    break; 
  case YDRAW: 
    YDrawRectF (0, 0, WND_w, WND_h, WND_color);           
    YWnd (&h_top,     VISOR1,      "VISOR1",      5, 5, WND_w-10, top_h, (long)w1d,0,0,0, CLR_DEF);    
    YWnd (&h_middle,  middle_proc, "middle_proc", 5, top_h+10, ww, middle_h, 0,0,0,0, CLR_DEF);    
    YWnd (&hWinlist,  WINLIST,     "WINLIST",     5, top_h+middle_h+15, left_w, left_h, 0,0,0,0, CLR_DEF);    
    YWnd (&h_right,   right_proc,  "right_proc", 10+left_w, top_h+10, ww, WND_h-15-top_h, 0,0,0,0, CLR_DEF);    
    break; 
  case YLMOUSEDOWN:

    ii = 100;
    for (i = 0; i < ii; i++) {
      x = i * 0.1;
      V1PlotPut (plot1, i, x, sin(x)*cos(count*x));
      /* V1PlotPut (plot2, i, count-x, cos(x)); */
    }

    YSend (h_top, YREDRAW, 0,0,0,0);
    count++;
    break;
  case YCLOSE: 
    YQuit (); 
    break; 
  default: ;;;;  
  }  
  
  RETURN_TRUE;  
} 
/*-----------------------------------------------------------------------*/ 
int 
MAIN (int argc, char **argv) 
{   
  int i; 

  h_main = h_left = h_right = h_top = h_middle = ID_NULL;
  hWinlist = ID_NULL;

  ww = 320;
  left_w = ww;
  left_h = ww+20;
  middle_h = 70;
  top_h = 220; 
  width  = 2*ww + 15;  
  height = top_h+middle_h+left_h+20;

  numboids = 30; 
  is_boids = TRUE;
  is_drops = FALSE;
  /* 	 mashtab = 100; */
  mashtab = ww;
 
  YInit ();    
 
  YBig_new (&h_main, main_proc, "Laboratory of Elementary Magic Particles", 
	SC_DEF, SC_DEF, width, height, 0,0,0,0, YColor("aqua")); 
 
  for( ; ; ) { 
    if (YQUIT) break;

    YCheckEvents (); 
  } 
	  
  YRETURN;  
} 
/***************************************************************************/ 
