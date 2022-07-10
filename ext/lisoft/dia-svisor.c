// -*-  mode: c    ; coding: koi8   -*- ----------------------------------------

/****************************************************************************
 *                                                                          *
 *  svisorl.c  --  "Library Svisor" (main file);                             *
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
 ****************************************************************************
 */                                                                          
                                                                             

#if defined(D_SVISOR) 
/*************************************************************************/


#include "dia-y_zone.h" 
#include "dia-algols.h" 
#include "dia-svisor.h" 

/*==========================================================================*/
/*                                                                          */
/*-------------------------------MAIN---------------------------------------*/
long
MAIN (PFUNC_VAR)
{
  int    argc/* , index */; 
  char **argv;
  

  char *main_map[] = {
    "@MAP  Main",
    "40 25 | ...............................",
    "40 40 | ...............................", 
    "@MAP_plan   ",
    " 1 YMAP MIX3      NULL 110 130 80 120  NULL |  |  ",

    " 2 YMAP D_kernel  NULL 210  70 65 25  NULL |  |  ",
    " 3 YMAP D_svisor  NULL 210 110 65 25  NULL |  |  ",
    " 4 YMAP D_matlib  NULL 210 150 65 25  NULL |  |  ",
    " 4 YMAP D_latice  NULL 210 190 65 25  NULL |  |  ",

    "@OPEN  Main",
    NULL};

 
  char *pars_test[] = {
    "@PARS pars_test",
    "string  name  inMAIN:", 
    NULL};

  switch (message) {
  case YCREATE: 
    YInitWIND ();    
    YInitALGO (); 

    argc = mes2;
    argv = (char**) mes3;
    YMainParse (argc, argv);

    SLoadMatlib ();
#ifdef D_USERPKG 
    YAlgLoadUser ();
#endif

    YAlgLoadTest ();
    YAlgReadAll (pars_test);

    SLoadSvisor ();
    SLoadLatice ();

    YAlgReadAll (main_map);

    YAlgParse (argc, argv); 
    YAlgResolve ();

    if (START_ACT == YCALC) {
      YAlgCalc (START_NAME);
      YExit (0);
    } else {
      YBigWindow (NULL, SVISOR, "SuperVisor (Demo for Svisor)", 0,0, 0,0, 
		  (long)START_NAME, 0, 0, 0, CLR_DEF); 
    }
    break;  
  case YFINAL:
    YFinalYlib ();
    break; 
  default:  ;;
  }

  id++;
  RETURN_TRUE;
}
/*---------------------------------SVISOR--------------------------------------*/
long
SVISOR (PFUNC_VAR)
{
  int     W, H;
  float   koef = 1.0 /* 0.85 */; 

  static long  start_name;
  static int hLay;
  static char *coms_3[] = {
    "Redraw", "/+", "/-", "/>", "Find", NULL
  };

  switch (message) {
  case YCREATE:
    break;
  case YGET:
    W = YLINER (YGet("wdisplay"), 640, 640, 1280, 800);
    H = YLINER (YGet("hdisplay"), 480, 480, 1024, 650);
    if (id == 1) return (W*koef);
    if (id == 2) return (H*koef);
  case YOPEN:
    start_name  = YGet("wlong1");
  case YDRAW:

    YWnd (&hLay, LAYOUT,  "",  0,0, WND->w,WND->h, 0,0,0,0, CLR_DEF);
    YLayPut (hLay, 4, MODLIST, "",  start_name, 0, 0,0, CLR_DEF);
    SVIS->hRamka1 = YLayPut(hLay, 1, RAMKA, "SCREEN1", 0, FALSE, (long)SCREEN, 0, CLR_DEF);
    SVIS->hRamka2 = YLayPut(hLay, 2, RAMKA, "SCREEN2", 0, FALSE, (long)SCREEN, 0, CLR_DEF);
    SVIS->hRamka3 = YLayPut(hLay, 3, RAMKA, "SCREEN3", (long)coms_3, FALSE, (long)SCREEN, 0, CLR_DEF);

    break;
  case YCLOSE:
    YWndClean (id);
    break;
  default: ;;;;
  }

  RETURN_TRUE;
}
/*************************************************************************/


#endif 
#if defined(D_MISC)
/****************************************************************************
 *                                                                          *
 *                          MISC MISC MISC MISC MISC                        *
 *                                                                          *
 ****************************************************************************
 */ 

/* #include "y_open.h"  */
/* #include "y_more.h"  */
#include "dia-y_zone.h" 
#include "dia-svisor.h" 

YT_MISC *misc;


/****************************************************************************/

/*-------------------------------YInitMISC------------------------------*/
void  
YInitMISC ()
{

  YMALLOC (MISC, YT_MISC, 1); 

  FO_EXIST = FALSE;

  return;
}
/*----------------------------------------------------------------------*/

/****************************
------------------------------------------------ 
@ ^' 16 
/ 4.4 10.2 4.4 23.7 
/ 2 23.7 4.4 23.7 
) 3.5 10.5 13.7 * 10.5 17.2 * 10.5 10.2 
/ 4.4 10.2 10.5 10.2 
/ 4.4 17.2 10.5 17.2 
------------------------------------------  
@ ^1 5.6 
/ 2.8 10 2.8 23.9 
------------------------------------- 
@ ^2 10.4 
/ 2.7 10 2.7 23.9 
/ 7.7 10 7.7 23.9 
--------------------------------------- 
@ ^3 15.2 
/ 2.6 10 2.6 23.9 
/ 7.6 10 7.6 23.9 
/ 12.6 10 12.6 23.9 
------------------------------------------ 
@ ^4 17.6 
/ 2.75 10 2.75 23.9 
/ 7.55 23.9 11.1 10 
/ 11.1 10 11.6 10 
/ 11.6 10 15.15 23.9 
----------------------------------------- 
@ ^5 12 
/ 2.2 23.9 5.75 10 
/ 5.75 10 6.25 10 
/ 6.25 10 10.05 23.9 
-------------------------------------- 
@ ^6 17.6 
/ 2.45 23.9 6.0 10 
/ 6 10 6.5 10 
/ 6.5 10 10.05 23.9 
/ 14.85 10 14.85 23.9 
--------------------------------------- 
@ ^7 22.4 
/ 2.25 23.9 5.8 10 
/ 5.8 10 6.3 10 
/ 6.3 10 9.85 23.9 
/ 14.65 10 14.65 23.9 
/ 19.65 10 19.65 23.9 
------------------------------------------ 
@ ^8 27.2 
/ 2.05 23.9 5.6 10 
/ 5.6 10 6.1 10 
/ 6.1 10 9.65 23.9 
/ 14.45 10 14.45 23.9 
/ 19.45 10 19.45 23.9 
/ 24.45 10 24.45 23.9 
------------------------------------------ 
@ ^9 18.4 
/ 2.75 10 2.75 23.9 
/ 7.75 10 15.95 23.9 
/ 7.95 23.9 16.15 10 
------------------------------------------ 
@ ^10 12.8 
/ 2.2 10 10.4 23.9 
/ 2.4 23.9 10.6 10 
***********************************/


/*--------------------------duga_duga-------------------------------------*/ 
void 
duga_duga (float ra, float xa, float ya, float rb, float xb, float yb, 
	   char flag, float *x, float *y) 
{ 
float m, n, a, b, c, xp1, yp1, xp2, yp2, xp, yp, fi; 
float fi_delta = YPI/360; 
 
m = -(yb-ya)/(xb-xa); 
n = (yb*yb - ya*ya + xb*xb - xa*xa + ra*ra - rb*rb)/(xb-xa)/2; 
a = m*m + 1; 
b = (m*n - m*xb - yb)*2; 
c = xb*xb - 2*xb*n + n*n + yb*yb - rb; 

yp1 = (-b - sqrt(b*b-4*a*c))/2/a; 
xp1 = m*yp1 + n; 
yp2 = (-b + sqrt(b*b-4*a*c))/2/a; 
xp2 = m*yp2 + n; 
xp  = xp1; 
yp  = yp1; 

if (yp == ya)   
   if (xp > xa)  fi = YPI/2.0; 
   else          fi = 3*YPI/2.0; 
else if (yp < ya)   fi = YPI + atan((xp-xa)/(yp-ya)); 
else if (xp <= xa)  fi = 2*YPI + atan((xp-xa)/(yp-ya)); 
else                fi = atan((xp-xa)/(yp-ya)); 

fi = fi + fi_delta; 
if (fi > 2*YPI)  fi=fi-2*YPI; 

xp = xa + ra*sin(fi); 
yp = ya + ra*cos(fi); 
if ((sqrt((xp-xb)*(xp-xb) + (yp-yb)*(yp-yb)) < rb) && (flag == ATR_FLAG)) 
  { 
   *x = xp1; 
   *y = yp1; 
  } 
else 
  { 
   *x = xp2; 
   *y = yp2; 
  } 
return; 
} 
/*-----------------------------duga_otrez----------------------------------*/ 
void
duga_otrez (float ra, float xa, float ya, float xvert, char flag, float *x, float *y) 
{ 
if (flag == ATR_FLAG) 
   *y = ya + sqrt (ra*ra-(xvert-xa)*(xvert-xa)); 
else 
   *y = ya - sqrt (ra*ra-(xvert-xa)*(xvert-xa)); 
   *x = xvert; 
return; 
} 
/*------------------------------ReadDuga-----------------------------------*/
char* 
ReadDuga (float r, float x, float y, char *left,
	  float *point1, float *point2)
{
  char *next, next_str[5];
  char  ch, flag;
  float xvert, rb, xb, yb;

  ch   = *left;
  flag = *(left+1);

  if      (ch == ATR_POINT) 
    { 
      sscanf (left+2, "%f %f %s", point1, point2, next_str); 
    } 
  else if (ch == ATR_VERT) 
    { 
      sscanf (left+2, "%f %s", &xvert, next_str); 
      duga_otrez (r, x, y, xvert, flag, point1, point2); 
    } 
  else if (ch == ATR_DUGA) 
    { 
      sscanf (left+2, "%f %f %f %s", &rb, &xb, &yb, next_str); 
      duga_duga (r, x, y, rb, xb, yb, flag, point1, point2); 
    } 

  next = strchr (left+2, next_str[0]);
  return (next);
}
/*-----------------------------YLoadMyFont---------------------------------*/
void
YLoadMyFont ()
{

  unsigned char ch = 0; 
  int bukva, k;

  FILE  *in;
  static char buf[100];
  char   str[3];
  char  *left;
  float  r, x, y;

  if ((in = fopen ("myfont.dat", "r")) == NULL) {
    /* YWarning ("YLoadMyFont"); */
    return;
  }

  while (fgets (buf, 80, in)) {

    ch = buf[0];
    k++;

    if (ch == ATR_BUKVA) { 
      sscanf (buf+1, " %c", &ch);    /*  !!! " %c" */
      bukva = ch;
      k = 0;

      FO[bukva][k][0] = F_BUKVA; 
      sscanf (buf+1, " %c %f", &FO[bukva][k][1], &FO[bukva][k][2]); 
      FO[bukva][k][3] = 32.5; 
    } 
    else if (ch == ATR_END) { 
      FO[bukva][k][0] = F_END; 
    } 
    else if (ch == ATR_POINT) { 
      FO[bukva][k][0] = F_POINT; 
      sscanf (buf+1, "%f %f", &FO[bukva][k][1], &FO[bukva][k][2]); 
    } 
    else if (ch == ATR_CIRC)  { 
      FO[bukva][k][0] = F_CIRC; 
      sscanf (buf+1, "%f %f %f", &FO[bukva][k][1], &FO[bukva][k][2], &FO[bukva][k][3]); 
    } 
    else if (ch == ATR_OTREZ) { 
      FO[bukva][k][0] = F_OTREZ; 
      sscanf (buf+1, "%f %f %f %f", &FO[bukva][k][1], &FO[bukva][k][2], 
	      &FO[bukva][k][3], &FO[bukva][k][4]); 
    } 
    else if (ch == ATR_DUGA) {
      FO[bukva][k][0] = F_DUGA; 
      sscanf (buf+1, "%f %f %f %s", &r, &x, &y, str);
      FO[bukva][k][1] = r;
      FO[bukva][k][2] = x;
      FO[bukva][k][3] = y;
      left = strchr (buf+1, str[0]);
      left = ReadDuga (r, x, y, left, &FO[bukva][k][4], &FO[bukva][k][5]);
      ReadDuga (r, x, y, left, &FO[bukva][k][6], &FO[bukva][k][7]);
    }
    else if (ch == ATR_COMMENT) continue;

  };


  fclose (in);
  FO_EXIST = TRUE;

  return;
}
/*--------------------------------YDrawMyChar-----------------------------*/
void YDrawMyChar (unsigned char ch, int x, int y, YT_COLOR color)
{
  int k;
  float width, height, cx, cy, x1, y1, x2, y2, r;

  if (!FO_EXIST) return;

  for (k=0; ; k++) {
    if      (FO[ch][k][0] == F_BUKVA) {
      width  = FO[ch][k][2];
      height = FO[ch][k][3];
      YDrawRectB (x, y, width, height, color);
    }
    else if (FO[ch][k][0] == F_OTREZ) {
      x1 = x + FO[ch][k][1];
      y1 = y + height - FO[ch][k][2];
      x2 = x + FO[ch][k][3];
      y2 = y + height - FO[ch][k][4];
      YDrawLine (x1, y1, x2, y2, color);
    }
    else if (FO[ch][k][0] == F_POINT) {
      x1 = x + FO[ch][k][1];
      y1 = y + height - FO[ch][k][2];
      YDrawPixel (x1, y1, color);
    }
    else if (FO[ch][k][0] == F_CIRC) {
      r  = FO[ch][k][1];
      x1 = FO[ch][k][2];
      y1 = FO[ch][k][3];
      YDrawCircB (x+x1, y+height-y1, r, color);
    }
    else if (FO[ch][k][0] == F_DUGA) {
      r  = FO[ch][k][1];
      cx = FO[ch][k][2];
      cy = FO[ch][k][3];
      YDrawCircB (x+cx, y+height-cy, r, color);

      YDrawCircF (x+FO[ch][k][4], y+height-FO[ch][k][5], 2, YColor ("red"));
      YDrawCircF (x+FO[ch][k][6], y+height-FO[ch][k][7], 2, YColor ("green"));
    }
    else if (FO[ch][k][0] == F_END)   break;
    else 
      YWarning ("YDrawMyChar");

  }

  return;
}
/*------------------------------YMyCharW----------------------------------*/
int YMyCharW (unsigned char ch)
{

  return (FO[ch][0][2]);

}
/*------------------------------YDrawMyString-----------------------------*/
void 
YDrawMyString (char *s, int x0, int y0, YT_COLOR color)
{
  int   x, i, delta, w;
  char ch;

  x = x0;
  delta = 5;

  for (i=0; ;i++) {
    ch = s[i];
    if (ch == '\0') break;
    if (ch == ' ') {x += 20; continue;}

    YDrawMyChar (ch, x, y0, color);
    w = YMyCharW (ch);
    x = x + w + delta;
  }

  return;
}
/*----------------------------------------------------------------------*/
/****************************************************************************/


#endif
#if defined(D_MATFUN)
/****************************************************************************
 *                                                                          *
 *  matfun.c  --  "Library Matfun" (main file);                             *
 *                                                                          *
 *  Copyright (c) 2000, Life Software.                                      *
 *                                                                          *
 ****************************************************************************
 */                                                                          

/* #include "y_open.h"  */
#include "dia-y_zone.h" 
/* #include "matfun.h"  */
#include "dia-svisor.h" 



/*------------------------------VSetPoint3D---------------------------------*/
void
VSetPoint3D (VT_P3D *p, YT_SPACE x, YT_SPACE y, YT_SPACE z)
{
  p->x = x;
  p->y = y;
  p->z = z;

  return;
}
/*-----------------------------VLenOtrezok----------------------------------*/
YT_SPACE
VLenOtrezok (VT_P3D *p1, VT_P3D *p2)
{

  return (sqrt ((p1->x - p2->x) * (p1->x - p2->x) + (p1->y - p2->y) * (p1->y - p2->y) + 
		(p1->z - p2->z) * (p1->z - p2->z)));

}
/*------------------------------VVecMult------------------------------------*/
YT_SPACE
VVecMult (VT_VECTOR * v1, VT_VECTOR * v2)
{

  return ((v1->x) * (v2->x) + (v1->y) * (v2->y) + (v1->z) * (v2->z));

}
/*----------------------------VVecMultVec-----------------------------------*/
void
VVecMultVec (VT_VECTOR * v, VT_VECTOR * v1, VT_VECTOR * v2)
{
  v->x = (v1->y) * (v2->z) - (v2->y) * (v1->z);
  v->y = (v1->z) * (v2->x) - (v2->z) * (v1->x);
  v->z = (v1->x) * (v2->y) - (v2->x) * (v1->y);
  return;
}
/*----------------------------VVecLenght------------------------------------*/
YT_SPACE
VVecLenght (VT_VECTOR * v)
{

  return (sqrt ((v->x) * (v->x) + (v->y) * (v->y) + (v->z) * (v->z)));

}
/*-------------------------------VGrafCreate--------------------------------*/
VT_GRAF *
VGrafCreate (VT_GI nn)
{
  static VT_GRAF *new_graf;

  new_graf = (VT_GRAF*) malloc (sizeof(VT_GRAF));
  new_graf->nn = nn;

  new_graf->edges = (VT_GV*) malloc (sizeof(VT_GV) * nn*nn); 
  new_graf->nodes = (VT_GV*) malloc (sizeof(VT_GV) * nn   ); 

  new_graf->wk = VGrafWorkCreate (new_graf);

  VGrafInit (new_graf, YCONST, 0, 0, YCONST, GRAF_NOT_EDGE, 0);

  return (new_graf);
}
/*-------------------------------VGrafCreateOld--------------------------------*/
/* VT_GRAF * */
/* VGrafCreateOld (VT_GI nn) */
/* { */
/*   VT_GRAF *pg; */

/*   if (!(pg = malloc (sizeof(VT_GRAF))) YERROR ("VT_GRAF"); */
/*   pg->nn = nn; */

/*   YMALLOC (pg->edges, VT_GV, nn*nn );  */
/*   YMALLOC (pg->nodes, VT_GV, nn    ); */

/*   VGrafInit (pg, YCONST, 0, 0, YCONST, GRAF_NOT_EDGE, 0); */

/*   return (pg); */
/* } */
/*-------------------------------VGrafCreateNew1--------------------------------*/
/* YT_BOOL */
/* VGrafCreateNew1 (VT_GRAF **ppg, VT_GI nn) */
/* { */

/*   YMALLOC ((*ppg), VT_GRAF, 1); */
/*   (*ppg)->nn = nn; */

/*   YMALLOC ((*ppg)->edges, VT_GV, nn*nn); */
/*   YMALLOC ((*ppg)->nodes, VT_GV, nn); */

/*   VGrafInit ((*ppg), YCONST, 0, 0, YCONST, GRAF_NOT_EDGE, 0); */

/*   return (TRUE); */
/* } */
/*-------------------------------VGrafDestroy--------------------------------*/
void
VGrafDestroy (VT_GRAF *pg)
{

  VGrafWorkDelete (pg->wk);

  free (pg->nodes);
  free (pg->edges);

  free (pg);

  return;
}
/*------------------------------VGrafInit-----------------------------------*/
void
VGrafInit (VT_GRAF *pg, int type_nodes, VT_GV nod1, VT_GV nod2, 
                        int type_edges, VT_GV edg1, VT_GV edg2)
{
  VT_GI v, u;

  for (u = 0; u < pg->nn; u++) {
    if      (type_nodes == YRAND)  GRAF_NODE (pg, u) = /* YRandF */YRAND((int)nod1, (int)nod2); 
    else if (type_nodes == YCONST) GRAF_NODE (pg, u) = nod1;
    for (v = u; v < pg->nn; v++) {
      if      (type_edges == YRAND)  GRAF_EDGE (pg, u, v) = (VT_GV)/* YRandF */
				       YRAND ((int)edg1, (int)edg2); 
      else if (type_edges == YCONST) GRAF_EDGE (pg, u, v) = (VT_GV)edg1;
    }
  }

  return;
}
/*----------------------------VGrafGetSosed----------------------------------*/
YT_BOOL
VGrafGetSosed (VT_GRAF *graf, VT_GI uzel, VT_GI *sosed)
{
  static VT_GRAF *g;
  static VT_GI uz;
  static VT_GI i;

  if (graf != NULL) {
    g = graf;
    uz = uzel;
    i = -1;
    return (TRUE);
  }
  while (TRUE) {
    i++;
    if (i == g->nn)
      return (FALSE);
    if (GRAF_EDGE (g, uz, i) == (VT_GV)GRAF_NOT_EDGE)
      continue;
    *sosed = i;
    return (TRUE);
  }

}
/*-----------------------------VGrafEdge--------------------------------------*/
VT_GV *
VGrafEdge (VT_GRAF *pg, VT_GI u, VT_GI v)
{
  VT_GI rab;

  if ((u<0) || (u>= pg->nn)) YERROR ("VGrafEdge");
  if ((v<0) || (v>= pg->nn)) YERROR ("VGrafEdge");

  if (u > v) {
    rab = v;
    v = u;
    u = rab;
  }
  return ((pg->edges) + u*(pg->nn) + v);
}
/*----------------------------VGrafGetSum----------------------------------*/
VT_GV
VGrafGetSum (VT_GRAF *pg, VT_GI u)
{
  VT_GV  sum;
  VT_GI  sosed, num_sosed;

  sum = num_sosed = 0;
  VGrafGetSosed (pg, u, &sosed);
  while (VGrafGetSosed (NULL, 0, &sosed)) {
    sum += (GRAF_EDGE(pg, u, sosed) * GRAF_NODE(pg, sosed));
    num_sosed++;
  }
  sum = sum/num_sosed;

  return (sum);
}
/*--------------------------VGrafGetEdges-----------------------------------*/
YT_BOOL
VGrafGetEdges (VT_GRAF *pgraf, VT_GV *pedge, VT_GI *pu, VT_GI *pv)
{
  static VT_GI u, v, nn;
  static VT_GRAF *pg;
  static VT_GV *pedge_mem;
  VT_GV edge;
  VT_GI *pu_mem, *pv_mem;

  if (pgraf != NULL) {
    pg = pgraf;
    pedge_mem = pedge;
    pu_mem = pu;
    pv_mem = pv;

    u = 0;
    v = 1;
    nn = pg->nn;
    return (TRUE);
  }
  while (TRUE) {
    if (v >= nn) {
      u++;
      v = u + 1;
    }
    if (u >= nn - 1)
      return (FALSE);

    edge = GRAF_EDGE (pg, u, v);
    v++;
    if (edge != GRAF_NOT_EDGE)
      break;
  }

  if (pedge == NULL)  pedge = pedge_mem;
  if (pu == NULL)     pu = pu_mem;
  if (pv == NULL)     pv = pv_mem;

  if (pedge != NULL)  *pedge = edge;
  if (pu != NULL)     *pu = u;
  if (pv != NULL)     *pv = v - 1;

  return (TRUE);
}
/*--------------------------------VGrafPrint--------------------------------*/
void
VGrafPrint (VT_GRAF *pg)
{
  VT_GI v, u;
  VT_GV s;

  for (u = 0; u < pg->nn; u++) {
    for (v = 0; v < pg->nn; v++) {
      s = GRAF_EDGE (pg, u, v);
      fprintf (stderr, "% #9.2f ", s);
    }
    fprintf (stderr, "\n");
  }
  
  return;
}
/*-----------------------------VGrafWorkCreate------------------------------*/
VT_GW *
VGrafWorkCreate (VT_GRAF *pg)
{
  VT_GW *wk;
  VT_GI nn = pg->nn;

  if (!(wk = (VT_GW *) malloc (sizeof (VT_GW))))      YERROR ("VGrafWork");

  wk->puti = (VT_GI *) malloc (sizeof(VT_GI) * nn * nn);
  wk->met  = (VT_GM *) malloc (sizeof(VT_GM) * nn);

  return (wk);
}
/*-----------------------------VGrafWorkDelete------------------------------*/
void
VGrafWorkDelete (VT_GW *wk)
{

  if (wk == NULL)  return;

  free (wk->met);
  free (wk->puti);   
  free (wk);

  return;
}
/*------------------------------VGrafSmin-----------------------------------*/
YT_BOOL
VGrafSmin (VT_GRAF *graf, VT_GI s, VT_GI t, VT_GV *smin)
{
  VT_GI j, v, v_min, p;
  static VT_GW *wk = NULL;
  static VT_GRAF *pg = NULL;
  VT_GM *met;
  VT_GV sum, l_min;

/*   if (pg != graf) { */
/*     pg = graf; */
/*     VGrafWorkDelete (wk); */
/*     wk = VGrafWorkCreate (pg); */
/*   } */
  pg = graf;
  wk = pg->wk;

  met = wk->met;

  wk->s = s;
  wk->t = t;
  if (s == t) {
    wk->smin = 0;
    wk->puti[0] = -1;
    return (FALSE);
  }
  for (v = 0; v < pg->nn; v++) {
    met[v].fix = FALSE;
    met[v].l = /* MAXFLOAT; */ YMAXSPACE;
    met[v].prev = -1;
  }
  met[s].fix = TRUE;
  met[s].l = 0;

  p = s;
  while (TRUE) {
    for (v = 0; v < pg->nn; v++) {
      if (GRAF_EDGE (pg, p, v) == GRAF_NOT_EDGE)  
	continue;
      if (met[v].fix)  
	continue;

      sum = met[p].l + GRAF_EDGE (pg, p, v);
      if (met[v].l > sum) {
	met[v].l = sum;
	met[v].prev = p;
      }
    }

    l_min = /* MAXFLOAT */ YMAXSPACE;
    for (v = 0; v < pg->nn; v++) {
      if (met[v].fix)  
	continue;

      if (met[v].l < l_min) {
	l_min = met[v].l;
	v_min = v;
      }
    }
    met[v_min].fix = TRUE;

    p = v_min;
    if (p == t)  
      break;
  }

  p = t;
  j = 0;
  while (TRUE) {
    wk->puti[j++] = p;
    if (p == s)  break;
    p = met[p].prev;
  }
  wk->puti[j] = -1;

  wk->smin = met[t].l;

  if (smin == NULL)  VGrafWorkPrint (wk);
  else               *smin = wk->smin;

  return (TRUE);
}
/*----------------------------VGrafAllSmin----------------------------------*/
YT_BOOL
VGrafAllSmin (VT_GRAF *graf, VT_GI s, VT_GV *all)
{
#define MAXVAL 10000.0
  YT_BOOL *list;
  VT_GI num, u, v, nn = graf->nn;
  VT_GV mini, val_uv;

  num = nn;
  /* YMALLOC (list, YT_BOOL, nn); */
  if (!(list = (YT_BOOL*)malloc (sizeof(YT_BOOL) * nn))) YERROR ("VGrafAllSmin");
  for (v = 0; v < nn; v++)  list[v] = TRUE;

  for (v = 0; v < nn; v++) {
    all[v] = GRAF_EDGE (graf, s, v);
    if (all[v] == GRAF_NOT_EDGE)  all[v] = MAXVAL;
  }

  all[s] = 0;
  list[s] = FALSE;
  num--;

  while (num != 0) {
    mini = MAXVAL;
    for (v = 0; v < nn; v++) {
      if (list[v] == FALSE)  
	continue;
      if (all[v] < mini) {
	mini = all[v];
	u = v;
      }
    }
    list[u] = FALSE;
    num--;
    for (v = 0; v < nn; v++) {
      if (list[v] == FALSE)  
	continue;
      val_uv = GRAF_EDGE (graf, u, v);
      if (val_uv == GRAF_NOT_EDGE)  val_uv = MAXVAL;
      all[v] = YMIN (all[v], all[u] + val_uv);
    }
  }

  free (list);
  return (TRUE);
}
/*-----------------------------VGrafWorkPrint-------------------------------*/
void
VGrafWorkPrint (VT_GW *wk)
{
  VT_GI v, num;

  fprintf (stderr, "--------------------------\n");
  fprintf (stderr, "S = %d \n", wk->s);
  fprintf (stderr, "T = %d \n", wk->t);
  fprintf (stderr, "L_min = %f \n", wk->smin);
  for (v = 0; wk->puti[v] != -1; v++) ;;;
  num = v;
  for (v = num - 1; v >= 0; v--) {
    fprintf (stderr, "%d", wk->puti[v]);
    if (v != 0)
      fprintf (stderr, "_");
  }
  fprintf (stderr, "\n------------------------\n");

}
/*-----------------------------MGrafTest-----------------------------------*/
void
MGrafTest ()
{

      VT_GRAF *pg;
      VT_GI s, t, nn;
      
      nn = 4; 
      /* nn = 6; */
      pg = VGrafCreate (nn);
      
      fprintf (stderr, "init_begin \n");
      if (pg->nn == 4) {
	GRAF_EDGE (pg, 0, 1) = 1;
	GRAF_EDGE (pg, 1, 2) = 1;
	GRAF_EDGE (pg, 2, 3) = 1;
	GRAF_EDGE (pg, 0, 3) = 3.1;
	s = 0;
	t = 3;
      } else {
	VGrafInit (pg, YCONST, 0, 0, YRAND, 2, 5 /* 1, 3 */);
	YRAND_S;
	s = YRAND (0, nn - 1);
	t = YRAND (0, nn - 1);
      }
      fprintf (stderr, "init_end \n");
      
      VGrafPrint (pg);
      VGrafSmin (pg, s, t, NULL);


}
/****************************************************************************/



/* #endif */
/* #if  defined(D_COMP) */
/****************************************************************************/

/* #include "y_open.h"  */
/* #include "svisor.h"  */

/****************************************************************************/


#endif
#if defined(D_ALL)
/****************************************************************************/
/*                                                                          */
/****************************************************************************/

#if defined(D_MESA)
#define D_OPENGL
#endif

#include "dia-y_zone.h" 
#include "dia-algols.h" 
#include "dia-svisor.h" 

#if defined(D_OPENGL)
#include <X11/Xlib.h>
#include <X11/Xutil.h>
#include "GL/xmesa.h"
#include <GL/glx.h>
#include "GL/gl.h"
#endif
#if defined(D_MESA)
#include "GL/xmesa.h"
#include "GL/osmesa.h"
#endif


VT_REND3 sss;
VT_CDAT cdat_glob = {0, 0, 50, 50};


/*-----------------------------SLoadSvisor-------------------------------*/
void 
SLoadSvisor ()
{

  VT_SVISOR   *psvis;

  AT_PNAME1 pnames[] = {
    { "mREND3",   mREND3   }, 
    { "mREND2",   mREND2   },   
    { "mREND1",   mREND1   },   
    { "mPLOT",    mPLOT    },   
    { "mR_PLOT",  mR_PLOT  },  

    { "mR_OBJ3D", mR_OBJ3D }, 
    { "mR_CMAP",  mR_CMAP  },  
    { "mOBJ3D",   mOBJ3D   }, 
    { "mIsVis",   mIsVis   }, 
    { NULL }
  }; 

  static char *def_map1[] = {


   "@MAP  D_svisor",
    "40 25 | ...............................",
    "40 40 | ...............................", 
    "@MAP_plan   ",
    " 8 YMOD mPLOT   NULL 100 190 WFU HFU  NULL | 21 |  ",
    " 4 YMOD mOBJ3D  NULL 100  90 WFU HFU  NULL | 23 |  MM_APPLY",
    " 5 YMOD mIsVis  NULL 100 130 WFU HFU  NULL | 23 |  ",

    "21 YMOD mREND1  NULL 200 190 WFU HFU  NULL |   | ",
    "22 YMOD mREND2  NULL 200 140 WFU HFU  NULL |   | ",
    "23 YMOD mREND3  NULL 200  90 WFU HFU  NULL |   | ",

    "  6 YMOD mR_PLOT  NULL 270 190 WFU HFU  NULL | 21 | ",
    " 15 YMOD mR_CMAP  NULL 270 140 WFU HFU  NULL | 22 | ",
    " 14 YMOD mR_OBJ3D NULL 270  90 WFU HFU  NULL | 23 | ",

    NULL};


  /* D3_Start (); */

  YMEMLOC (psvis, VT_SVISOR*, sizeof(VT_SVISOR));
  YSet ("psvis", (long)psvis);

  YSetPnames (pnames);
  YSet ("MM_OBJ3D_ADD", MM_OBJ3D_ADD);
  YSet ("MM_CMAP_DRAW", MM_CMAP_DRAW);
  YSet ("MM_W1D", MM_W1D);

  YAlgReadAll (def_map1);

  return;
}
/*-----------------------------SLoadLatice-------------------------------*/
void 
SLoadLatice ()
{

  static char *n_names[] = {
    "Not data", "Not data", "Not data", "Not data", NULL
  };

  AT_PNAME1 pnames[] = {
    { "mScale",   mScale   }, 
    { "mData",    mData    },   
    { "mColor",   mColor   },  
    { "mBody",    mBody    },   
    { "mSlice",   mSlice   },   
    { "mL_C",     mL_C     },     
    { "mSlines",  mSlines  },  
    { "mR_LAT",   mR_LAT   },  
    { "mLat3d",   mLat3d   }, 
    { "mW_LAT",   mW_LAT   }, 
    { "mMLAT",    mMLAT    },    
    { "mRotL",    mRotL    },   
    { NULL }
  }; 

  static char *def_map1[] = {
    "@PARS pars_color ",
    "int  xrel    70  ",
    "int  yrel    70  ", 
    "bool blegend TRUE", 
    "@MAP  Chanal3",
    "30 30 | ------------------------",
    "30 45 | ------------------------",
    "30 60 | ------------------------",
    "@MAP_plan   ",
    " 1 YMOD mScale NULL         80 120  60 40  NULL | 2   | MM_LAT3 MM_LAT2",
    " 2 YMOD mData  NULL        150 120  60 40  NULL | 3   |            ",
    " 3 YMOD mColor pars_color  220 120  60 40  NULL | 999 |            ",


    "@MAP  Chanal2",
    "30 30 | ------------------------",
    "30 45 | ------------------------",
    "30 60 | ------------------------",
    "@MAP_plan   ",
    " 1 YMOD mScale NULL   80 120  60 40  NULL | 2   | MM_LAT3 MM_LAT2",
    " 2 YMOD mData  NULL  150 120  60 40  NULL | 3   |            ",
    " 3 YMOD mColor NULL  220 120  60 40  NULL | 999 |            ",


    "@MAP  Vizor",
    "@MAP_plan   ",
    "  2 YMAP Chanal3 NULL  32  40 WFU HFU  Chanal3 | 3     | MM_LAT3      ",
    "  3 YMOD mKran   NULL  95  40 WMI HMI  NULL    | 7 37  |              ",
    " 37 YMOD mBody   NULL 165  40 WFU HFU  NULL    | 30    |              ",
    " 30 YMOD mKran   NULL 225  40 WMI HMI  NULL    | 20    |              ",
    " 20 YMOD mREND3  NULL 285  40 WFU HFU  NULL    |       | MM_OBJ3D_ADD ",
    "  7 YMOD mSlice  NULL  95  75 WFU HFU  NULL    | 9 16  |              ",
    " 16 YMOD mKran   NULL 225  75 WMI HMI  NULL    | 30    |              ",
    "  1 YMAP Chanal2 NULL  32 125 WFU HFU  Chanal2 | 9     | MM_LAT2      ", 
    /* "  1 YMAP Chanal3 NULL  32 125 WFU HFU  Chanal2 | 9     | MM_LAT2      ",  */
    "  9 YMOD mKran   NULL  95 125 WMI HMI  NULL    | 18 13 |              ",
    " 18 YMOD mL_C    NULL 165 125 WFU HFU  NULL    | 21    | MM_CMAP_DRAW ",
    " 21 YMOD mREND2  NULL 285 125 WFU HFU  NULL    |       |              ",
    " 13 YMOD mSlines NULL  95 160 WFU HFU  NULL    | 14    |              ",
    " 14 YMOD mKran   NULL  95 210 WMI HMI  NULL    | 23    | MM_LAT1 MM_W1D",
    " 23 YMOD mREND1  NULL 285 210 WFU HFU  NULL    |       |              ",


    "@MAP  Lat321",
    "@MAP_plan   ",
    "  2 YMAP Chanal3 NULL  32  40 WFU HFU  Chanal3 | 3     | MM_LAT3   ",
    "  3 YMOD mKran   NULL  95  40 WMI HMI  NULL    | 7 37  |           ",
    " 37 YMOD mBody   NULL 165  40 WFU HFU  NULL    | 30    |           ",
    " 30 YMOD mKran   NULL 225  40 WMI HMI  NULL    | 999   |           ",
    "  7 YMOD mSlice  NULL  95  75 WFU HFU  NULL    | 9 16  |           ",
    " 16 YMOD mKran   NULL 225  75 WMI HMI  NULL    | 30    |           ",
    "  1 YMAP Chanal2 NULL  32 125 WFU HFU  Chanal2 | 9     | MM_LAT2   ", 
    "  9 YMOD mKran   NULL  95 125 WMI HMI  NULL    | 18 13 |           ",
    " 18 YMOD mL_C    NULL 165 125 WFU HFU  NULL    | 999   |           ",
    " 13 YMOD mSlines NULL  95 160 WFU HFU  NULL    | 14    |           ",
    " 14 YMOD mKran   NULL  95 210 WMI HMI  NULL    | 999   | MM_LAT1 MM_W1D",


    "@MAP  Viz_new",
    "@MAP_plan   ",
    "  1 YMAP Lat321  NULL 100 125 80 120  NULL |10 20 30 | MM_LAT3 MM_LAT2 MM_LAT1 MM_W1D ",

    " 10 YMOD mREND3  NULL 250  50 WFU HFU  NULL    |       | MM_OBJ3D_ADD  ",
    " 20 YMOD mREND2  NULL 250 125 WFU HFU  NULL    |       |  ",
    " 30 YMOD mREND1  NULL 250 200 WFU HFU  NULL    |       | MM_W1D  ",


    "@MAP  T_W_R",
    "30 30 | ..................................",
    "30 45 | ..................................", 
    "@MAP_plan   ",
    " 3 YMOD mLat3d NULL  50  90 WFU HFU  NULL | 4 | ",
    " 4 YMOD mW_LAT NULL 120  90 WFU HFU  NULL |   | ",
    " 2 YMOD mR_LAT NULL 190  90 WFU HFU  NULL | 9 | ",
    " 9 YMAP Vizor  NULL 260 140 WFU HFU  NULL |   | ",


   "@MAP  D_latice",
    "40 25 | ...............................",
    "40 40 | ...............................", 
    "@MAP_plan   ",
    " 22 YMOD mMLAT   NULL  80  90 WFU HFU  NULL  | 1 | MM_APPLY ", 
    " 25 YMOD mRotL   NULL  80 130 WFU HFU  NULL  | 1 |          ",
    "  6 YMOD mR_LAT  NULL  80 170 WFU HFU  NULL  | 1 |          ", 

    " 5 YMAP T_W_R   NULL 160 200  65  25  NULL |   |   ",
 
    " 1 YMAP Viz_new NULL 240  90 WFU HFU  NULL |   |   ",
    " 7 YMAP Vizor   NULL 240 170 WFU HFU  NULL |   |   ",

    NULL};


  SVIS->none_names = n_names;

  YSetPnames (pnames);
  YSet ("MM_LAT3", MM_LAT3);
  YSet ("MM_LAT2", MM_LAT2);
  YSet ("MM_LAT1", MM_LAT1);

  YAlgReadAll (def_map1);

  return;
}
/*---------------------------------SvisRend----------------------------------*/
int SvisRend (int num)
{

  if (num == 1)  return (SVIS->hRamka1);
  if (num == 2)  return (SVIS->hRamka2);
  if (num == 3)  return (SVIS->hRamka3);

  return (ID_NULL);
}
/*-----------------------------mR_PLOT---------------------------------------*/
long
mR_PLOT (PFUNC_VAR)
{
  typedef struct {
    ABCD;
  } YT_USR;
  char   *text[] =
  {
    "                                ",
    "  Read 1D-PLOT data from file   ",
    "                                ",
    "     SORRY! THIS MODULE IS      ",
    "     UNDER CONSTRUCTION !!      ",
    "                                ",
    NULL
  };

  switch (message) {
  case YCREATE:
    U_MALLOC;
    WND->name = "R_PLOT";
    break;
/*   case MM_FORWARD: */
/*     break; */
  case MM_APPLY:
    break;
  case YGETSIZE:
    MYSIZE_IS (W_MOD, H_MOD);
    break;
  case YOPEN:
  case YDRAW:
    YDrawRectF (0, 0, WND->w, WND->h, WIN->color);
    YDrawStrings (text, 30, 80);
    /*
    YDrawStringImp("SORRY! THIS MODULE IS", WND->w/2,WND->h/2-15, YColor("red"), YNONE,YNONE);
    YDrawStringImp("UNDER CONSTRUCTION !!", WND->w/2,WND->h/2+15, YColor("red"), YNONE,YNONE);
    */
    break;
  case YCLOSE:
    YWndClean (id);
    break;
  default: ;;;
  }

  RETURN_TRUE;
}
/*--------------------------------mPLOT-------------------------------------*/
long
mPLOT (PFUNC_VAR)
{

  typedef struct {
    ABCD;
  } YT_USR;

  typedef struct {
    char   *name;
    char   *legend;
    YT_BOOL flag;
  } TT_PLOTINFO;

#define NUM_PRIMS 7
  static TT_PLOTINFO prim[NUM_PRIMS] =
  {
    {"sin(x)",          "f1", TRUE},
    {"cos(x)",          "f2", FALSE},
    {"sin(2x)*cos(x)",  "f3", FALSE},
    {"sin(2x)+cos(x)",  "f4", TRUE},
    {"sin(3x)+cos(x)",  "f5", TRUE},
    {"sin(x)^2+cos(x)", "f6", FALSE},
    {"sin(x)^3",        "f7", TRUE}
  };
  static YT_SPACE x, y;
  static int ii = 100;
  static VT_PLOT *plot;
  static VT_W1D *w1d;

  int     i, k, x0, m;
  char   *text[] =
  {
    "Creation test 1D-latice data as PLOT.",
    "Set a few data functions :",
    NULL
  };

  switch (message) {
  case YCREATE:
    U_MALLOC;
    WND->name = "PLOT";
    w1d = V1Create ();
    plot = V1PlotCreate ();
    break;
/*   case MM_FORWARD: */
/*     break; */
  case MM_APPLY:
    YGoto (YAPPLY, 0, 0, 0, 0);
    break;
  case YAPPLY:
    V1Init (w1d, NULL, NULL, NULL);

    for (k = 0; k < NUM_PRIMS; k++) {
      if (!prim[k].flag) 
	continue;
      
      V1PlotInit (plot, prim[k].legend, ii);
      for (i = 0; i < ii; i++) {
	x = i * 0.1;
	if      (k == 0) y = sin (x);
	else if (k == 1) y = cos (x);
	else if (k == 2) y = sin (2 * x) * cos (x);
	else if (k == 3) y = sin (2 * x) + cos (x);
	else if (k == 4) y = sin (3 * x) + cos (x);
	else if (k == 5) y = sin (x) * sin (x) + cos (x);
	else if (k == 6) y = sin (x) * sin (x) * sin (x);
	V1PlotPut (plot, i, x, y);
      }

      V1PlotAdd (w1d, plot);
      YAlgOut (YSEND2FACE, MM_W1D,  0, 0, 0, (long)w1d);
    }
    break;

  case YGETSIZE:
    MYSIZE_IS (W_MOD, H_MOD);
    break;
  case YOPEN:
  case YDRAW:
    YDrawRectF (0, 0, WND->w, WND->h, WIN->color);
    YDrawStrings (text, 20, 20);

    YBeginGroup ("Funcs", 10,100, 300,10+4*25, YColor(""));
    x0 = 10;
    m = 0;
    for (k = 0; k < 7; k++) {
      if (k == 4) {x0 = 155; m = 0;}
      YWnd (Ph(), CHECK, prim[k].name, x0,10+(m++)*25, 20,20, 0,LP(prim[k].flag),0,0, CLR_DEF);
    }
    YEndGroup ();
    break;
  case YCLOSE:
    YWndClean (id);
    break;
  default: ;;;
  }

  RETURN_TRUE;
}
/*===============================render1======================================*/
/*                                                                            */
/*--------------------------------mREND1--------------------------------------*/
long
mREND1 (PFUNC_VAR)
{
  typedef struct {
    ABCD;
  } YT_USR;

  static VT_W1D *w1d = NULL;
  static int hTitle, hAxeX, hAxeY;
  static void *meta = NULL;

  VT_CAM1D *cam1d;
/*   static char *commands[] = */
/*   { "XX","YY", NULL}; */
  YT_RECT rect;
  char   *text[] =
  {
    "Accepts data PLOT (simply diagram)",
    "makes their rendering and result ",
    "places on the screen:", 
    NULL
  };

  switch (message) {
  case YCREATE:
    U_MALLOC;
    WND->name = "Render1";
    meta = YMetaCreate (1000);
    break;
/*   case MM_FORWARD: */
/*     break; */
  case MM_LAT1:
    w1d = VLatToW1D ((VT_LAT *) PDATA);
    YGoto (YDRAWITEM, 0, 0, 0, 0);
    break;
  case MM_W1D:
    w1d = (VT_W1D *) PDATA;
    YGoto (YDRAWITEM, 0, 0, 0, 0);
    break;
  case MM_APPLY:
    YGoto (YWND2MOD, 0, 0, 0, 0);
    YGoto (YDRAWITEM, 0, 0, 0, 0);
    break;
  case YDRAWITEM:
    rect.x = 5;
    rect.y = 5;
    rect.w = 300;
    rect.h = 200;
    cam1d = w1d->cam1d;
    cam1d->scrx = rect.x;
    cam1d->scry = rect.y;
    cam1d->scrw = rect.w;
    cam1d->scrh = rect.h;
    /* meta = YMetaCreate (1000); */	/*?! */
    YMetaInit (meta, 0, 0, 310, 210);

    YMetaBegin (meta, "");
    V1DrawMain (w1d);
    YMetaEnd ();

    /* YMetaDrawTo (meta, mScreen_id, TRUE, id); */
    YMetaDrawTo (meta, SvisRend(1), TRUE, id);
    break;
  case YGETSIZE:
    MYSIZE_IS (W_MOD, H_MOD);
    break;
  case YOPEN:
  case YDRAW:
    YDrawRectF (0, 0, WND->w, WND->h, WIN->color);
    YDrawStrings (text, 20, 30);
    if (!w1d)
      break;
    cam1d = (w1d)->cam1d;
    YBeginGroup ("Color", 10,120, 100,60, YColor(""));
    YWnd (Ph(), COLORS, "Back-nd", 10,10, 20,20, LP(cam1d->backgr),0,0,0, CLR_DEF);
    YWnd (Ph(), COLORS, "Fore-nd", 10,35, 20,20, LP(cam1d->foregr),0,0,0, CLR_DEF);
    YEndGroup ();
    YBeginGroup ("Inscript", 120,120, 190,100, YColor(""));
    YWnd (&hTitle, EDIT, "Title: ", 60,10, 95,20, (long)(cam1d->title),0,0,0, CLR_DEF);
    YWnd (&hAxeX,  EDIT, "Axe è: ", 60,35, 95,20, (long)(cam1d->axeX), 0,0,0, CLR_DEF);
    YWnd (&hAxeY,  EDIT, "Axe Y: ", 60,60, 95,20, (long)(cam1d->axeY), 0,0,0, CLR_DEF);
    YWnd (Ph(), CHECK, "", 160,10, 20,20, 0,LP(cam1d->is_title),0,0, CLR_DEF);
    YWnd (Ph(), CHECK, "", 160,35, 20,20, 0,LP(cam1d->is_axeX), 0,0, CLR_DEF);
    YWnd (Ph(), CHECK, "", 160,60, 20,20, 0,LP(cam1d->is_axeY), 0,0, CLR_DEF);
    YEndGroup ();
    break;
  case YWND2MOD:
    cam1d = (w1d)->cam1d;
    strcpy (cam1d->title, (char *) YGetData (hTitle));
    strcpy (cam1d->axeX,  (char *) YGetData (hAxeX));
    strcpy (cam1d->axeY,  (char *) YGetData (hAxeY));
    break;
  case YLBUTT:
  case YRBUTT:
    break;
  case YCLOSE:
    YWndClean (id);
    break;
  default: ;;;
  }

  RETURN_TRUE;
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
  cam1d->is_title = TRUE;
  cam1d->is_axeX = TRUE;
  cam1d->is_axeY = TRUE;
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

  YMessageBox ("Too many PLOT!", "OK");
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
/*------------------------------VLatToW1D-----------------------------------*/
VT_W1D *
VLatToW1D (VT_LAT *lat)
{
  VT_PLOT *plot;
  VT_W1D *w1d;
  int     i, ii = lat->ii;
  int     d, dd = lat->dd;
  YT_SPACE x, data;

  w1d = V1Create ();
  V1Init (w1d, NULL, NULL, NULL);

  for (d = 1; d <= dd; d++) {
    plot = V1PlotCreate ();
    V1PlotInit (plot, lat->data_names[d - 1], ii);

    for (i = 1; i <= ii; i++) {
      VLAT (lat, LP(x), YGETDATA, i, 1, 1, 1);
      VLAT (lat, LP(data), YGETDATA, i, 1, 1, lat->izm + d);
      V1PlotPut (plot, i - 1, x, data);
    }

    V1PlotAdd (w1d, plot);
  }

  return (w1d);
}
/*---------------------------------VLAT-------------------------------------*/
long
VLAT (void *ptr, long long0, int signal, long long1, long long2, long long3, long long4)
{
  VT_LAT *lat = (VT_LAT *) ptr;
  enum y_keys {
    GETPTR = YKEY_LOCALS + 1, SREZBEGIN, SREZEND, SREZSIZES
  };

  int     izm, i, j, k, l, d, ii, jj, kk, dd;
  long    ijk, num;
  void   *p;
  YT_SPACE hmin = YMAXSPACE, hmax = YMINSPACE;
  YT_SPACE h;
  long    lret;
  int    *pii, *pjj;
  int     inew, jnew, knew;

  switch (signal) {
  case YCONSTR0:
    {
      VT_LAT *lat;

      if (!VLAT (&lat, long0, YCONSTR1, 0, 0, 0, 0))             return (FALSE);
      if (!VLAT (lat, 0, YCONSTR2, long1, long2, long3, long4))  return (FALSE);
      if (!VLAT (lat, 0, YCONSTR3, long1, long2, long3, long4))  return (FALSE);

      *((VT_LAT **) ptr) = lat;
      return (TRUE);
    }
  case YCONSTR1:
    {
      VT_LAT *lat;

      if (!(lat = (VT_LAT *) malloc (sizeof (VT_LAT))))
	        return (FALSE);

      lat->izm = long0;
      lat->ii = lat->jj = lat->kk = 999;
      lat->pcoor = NULL;
      lat->pdata = NULL;
      lat->pcats = NULL;

      lat->dd = 0;
      lat->dsel = 1;
      YStrCopy (lat->data_names, Y_NONENAMES, DD_MAX + 1);
      for (i = 0; i < DD_MAX; i++) {
	lat->hmin[i] = 0;
	lat->hmax[i] = 0;
      }
      VLAT (lat, 0, YEND, 0, 0, 0, 0);

      *((VT_LAT **) ptr) = lat;
      return (TRUE);
    }
  case YCONSTR2:
    izm = lat->izm;
    ijk = VLAT (lat, 0, YKEYWORD1, long1, long2, long3, long4);

    YMEMLOC (lat->pcoor, YT_SPACE *, ijk * izm * sizeof (YT_SPACE));
    if (lat->pcoor == NULL)  return (FALSE);

    return (TRUE);
  case YCONSTR3:
    izm = lat->izm;
    dd = lat->dd = (int) long4;
    if (dd > DD_MAX)  YError ("DD_MAX");
    if (dd == 0) return (TRUE);

    ijk = VLAT (lat, 0, YKEYWORD1, long1, long2, long3, long4);

    YMEMLOC (lat->pdata, YT_SPACE *, ijk * dd * sizeof (YT_SPACE));
    if (lat->pdata == NULL)  return (FALSE);

    return (TRUE);
  case YCONSTR4:
    izm = lat->izm;
    ijk = VLAT (lat, 0, YKEYWORD1, lat->ii, lat->jj, lat->kk, 0);

    YMEMLOC (lat->pcats, YT_COLOR *, ijk * sizeof (YT_COLOR));
    if (lat->pcats == NULL)  return (FALSE);

    return (TRUE);
  case YKEYWORD1:
    ii = lat->ii = (int) long1;
    jj = lat->jj = (int) long2;
    kk = lat->kk = (int) long3;
    izm = lat->izm;

    if      (izm == 1)  ijk = ii;
    else if (izm == 2)  ijk = ii * jj;
    else if (izm == 3)  ijk = ii * jj * kk;
    return (ijk);
  case YDESTRU0:
    if (!lat)
      break;
    VLAT (lat, 0, YDESTRU3, 0, 0, 0, 0);
    VLAT (lat, 0, YDESTRU2, 0, 0, 0, 0);
    VLAT (lat, 0, YDESTRU1, 0, 0, 0, 0);
    break;
  case YDESTRU3:
    if (lat->pdata) {
      free (lat->pdata);
      lat->pdata = NULL;
    }
    break;
  case YDESTRU2:
    if (lat->pcoor) {
      free (lat->pcoor);
      lat->pcoor = NULL;
    }
    break;
  case YDESTRU1:
    free (lat);
    break;
  case YPUTDATA:
    lret = VLAT (lat, 0, GETPTR, long1, long2, long3, long4);
    if (!lret)  return (FALSE);
    if (long4 == -1)  *((YT_COLOR *) lret) = *((YT_COLOR *) long0);
    else              *((YT_SPACE *) lret) = *((YT_SPACE *) long0);
    return (TRUE);
  case YGETDATA:
    lret = VLAT (lat, 0, GETPTR, long1, long2, long3, long4);
    if (!lret)  return (FALSE);
    if (long4 == -1)  *((YT_COLOR *) long0) = *((YT_COLOR *) lret);
    else              *((YT_SPACE *) long0) = *((YT_SPACE *) lret);
    return (TRUE);
  case GETPTR:
    i = (int) long1;  ii = lat->ii;
    j = (int) long2;  jj = lat->jj;
    k = (int) long3;  kk = lat->kk;
    d = (int) long4;
    izm = lat->izm;

    if (lat->srez) {
      if (izm == 2)  j = 1;
      if      (lat->islice)  {inew = lat->islice; jnew = i;           knew = j;} 
      else if (lat->jslice)  {inew = i;           jnew = lat->jslice; knew = j;} 
      else if (lat->kslice)  {inew = i;           jnew = j;           knew = lat->kslice;}
      else  YError ("ijk_slice");
      i = inew;
      j = jnew;
      k = knew;
    }
    if (izm == 2 && k != 1)              return (YNULL);
    if (izm == 1 && (j != 1 || k != 1))  return (YNULL);

    if      (d == 0)  d = izm + lat->dsel;
    else if (d < -1)  YError ("d<-1");

    if      (d == -1)  {p = lat->pcats; l = 1;} 
    else if (d <= izm) {p = lat->pcoor; l = d;} 
    else               {p = lat->pdata; l = d - izm;}

    if      (izm == 3)  num = AAAA (ii,jj,kk, i, j, k, l);
    else if (izm == 2)  num = AAA (ii, jj, i, j, l);
    else if (izm == 1)  num = AA (ii, i, l);

    if (d == -1)  return ((long)((YT_COLOR *) p + num));
    else          return ((long)((YT_SPACE *) p + num));
  case YMAKE:
    ii = lat->ii;
    jj = lat->jj;
    kk = lat->kk;

    if (lat->hmin[lat->dsel] != 0 || lat->hmax[lat->dsel] != 0)
      break;

    for (i = 1; i <= ii; i++) 
    for (j = 1; j <= jj; j++) 
    for (k = 1; k <= kk; k++) {
      if (!VLAT (lat, LP(h), YGETDATA, i, j, k, 0))  continue;
      /* if (lat->dsel == 3 ) OUTF(h);  */
      if      (h < hmin)  hmin = h;
      else if (h > hmax)  hmax = h;
    }
    lat->hmin[lat->dsel] = hmin;
    lat->hmax[lat->dsel] = hmax;
    /* fprintf(Y_STDERR, "%f %f \n",hmin,hmax); */

    break;
  case YNAMES:
    YStrCopy (lat->data_names, (char **) long4, DD_MAX + 1);
    break;
  case YBEGIN:
    lat->srez = TRUE;
    lat->islice = long1;
    lat->jslice = long2;
    lat->kslice = long3;
    break;
  case YEND:
    lat->srez = FALSE;
    lat->islice = lat->jslice = lat->kslice = 0;
    break;
  case YSIZE:
    if (!lat->srez)  YError ("SREZSIZES");
    pii = (int *) long1;
    pjj = (int *) long2;

    if (lat->izm == 2 && pjj != NULL)  YError ("SREZSIZES");
    if      (lat->islice)  {ii = lat->jj; jj = lat->kk;} 
    else if (lat->jslice)  {ii = lat->ii; jj = lat->kk;} 
    else if (lat->kslice)  {ii = lat->ii; jj = lat->jj;}
    *pii = ii;
    if (pjj != NULL)  *pjj = jj;
    return (TRUE);
  case YGETPOINT:
    {
      VT_CPOINT *point = (VT_CPOINT *) long0;
      VLAT (lat, LP(point->x), YGETDATA, long1, long2, long3, 1);
      VLAT (lat, LP(point->y), YGETDATA, long1, long2, long3, 2);
      VLAT (lat, LP(point->z), YGETDATA, long1, long2, long3, 3);
      VLAT (lat, LP(point->color), YGETDATA, long1, long2, long3, -1);
    }
    break;
  default:;;;
  }

  return (YNULL);
}
/*-----------------------------mR_OBJ3D---------------------------------------*/
long
mR_OBJ3D (PFUNC_VAR)
{
  typedef struct {
    ABCD;
  } YT_USR;
  char   *text[] =
  {
    "Read OBJ3D data from file : ",
    "................................",
   NULL
  };

  switch (message) {
  case YCREATE:
    U_MALLOC;
    WND->name = "R_OBJ3D";
    break;
/*   case MM_FORWARD: */
/*     break; */
  case MM_APPLY:
    break;
  case YGETSIZE:
    MYSIZE_IS (W_MOD, H_MOD);
    break;
  case YOPEN:
  case YDRAW:
    YDrawRectF (0, 0, WND->w, WND->h, WIN->color);
    YDrawStrings (text, 30, 30);
    YDrawStringImp("SORRY! THIS MODULE IS", WND->w/2,WND->h/2-15, YColor("red"), YNONE,YNONE);
    YDrawStringImp("UNDER CONSTRUCTION !!", WND->w/2,WND->h/2+15, YColor("red"), YNONE,YNONE);
    break;
  case YCLOSE:
    YWndClean (id);
    break;
  default: ;;;
  }

  RETURN_TRUE;
}
/*-----------------------------mR_CMAP---------------------------------------*/
long
mR_CMAP (PFUNC_VAR)
{
  typedef struct {
    ABCD;
  } YT_USR;
  char   *text[] =
  {
    "Read CMAP data from file : ",
    "................................",
    NULL
  };

  switch (message) {
  case YCREATE:
    U_MALLOC;
    WND->name = "R_CMAP";
    break;
/*   case MM_FORWARD: */
/*     break; */
  case MM_APPLY:
    break;
  case YGETSIZE:
    MYSIZE_IS (W_MOD, H_MOD);
    break;
  case YOPEN:
  case YDRAW:
    YDrawRectF (0, 0, WND->w, WND->h, WIN->color);
    YDrawStrings (text, 30, 30);
    YDrawStringImp("SORRY! THIS MODULE IS", WND->w/2,WND->h/2-15, YColor("red"), YNONE,YNONE);
    YDrawStringImp("UNDER CONSTRUCTION !!", WND->w/2,WND->h/2+15, YColor("red"), YNONE,YNONE);
    break;
  case YCLOSE:
    YWndClean (id);
    break;
  default: ;;;
  }

  RETURN_TRUE;
}
/*==========================render3==================================*/
/*                                                                   */
/*===================================================================*/

/* ------------------------D3_CreateContext--------------------------*/
void 
D3_CreateContext (int width, int height) 
{

#if defined(D_MESA)

   OSMesaContext ctx;

   /* Create an RGBA-mode context */
   ctx = OSMesaCreateContext( GL_RGBA, NULL );

   /* Allocate the image buffer */
   SSS.buffer = malloc(width * height * 4 );

   /* Bind the buffer to the context and make it current */
   OSMesaMakeCurrent( ctx, SSS.buffer, GL_UNSIGNED_BYTE, width, height);

#elif defined(D_OPENGL)

  Display *dpy = (Display*) YGet_DPY();
  int      scr = (int)      YGet_SCR();
  Window   win = (Window)   YGet_WIN();

   int attrib[] = { GLX_RGBA,
		    GLX_RED_SIZE, 1,
		    GLX_GREEN_SIZE, 1,
		    GLX_BLUE_SIZE, 1,
		    GLX_DOUBLEBUFFER,
		    None };

   XVisualInfo *visinfo;
   GLXContext ctx;

   Pixmap pm;
   GLXPixmap glxpm;
   XWindowAttributes attr;


   visinfo = glXChooseVisual( dpy, scr, attrib );
   if (!visinfo) {
      printf("Error: couldn't get an RGB, Double-buffered visual\n");
      exit(1);
   }

   ctx = glXCreateContext( dpy, visinfo, NULL, True );

   /*----------------------------------------------*/
   pm = XCreatePixmap( dpy, win, width, height, visinfo->depth );
   SSS.pm = (long)pm;
   XGetWindowAttributes( dpy, win, &attr );

   /*
    * IMPORTANT:
    *   Use the glXCreateGLXPixmapMESA funtion when using Mesa because
    *   Mesa needs to know the colormap associated with a pixmap in order
    *   to render correctly.  This is because Mesa allows RGB rendering
    *   into any kind of visual, not just TrueColor or DirectColor.
    */
#ifdef GLX_MESA_pixmap_colormap
   glxpm = glXCreateGLXPixmapMESA( dpy, visinfo, pm, attr.colormap );
#else
   /* This will work with Mesa too if the visual is TrueColor or DirectColor */
   glxpm = glXCreateGLXPixmap( dpy, visinfo, pm );
#endif
   /*----------------------------------------------*/

/* #define JUNK */
#ifdef JUNK
   glXMakeCurrent( dpy, win, ctx ); /*to make sure ctx is properly initialized*/
#endif
   glXMakeCurrent( dpy, pm, ctx );


   /* Ready to render! */
#endif

}
/*--------------------------------D3_Start------------------------------------*/
void
D3_Start ()
{

  VHandLoadFont ();
  ZBUFF_ptr  = NULL;
  ZBUFF_flag = FALSE;
  PRINTS = TRUE;

  CALCUS = FALSE;

#if defined(D_OPENGL)

  D3_CreateContext (200, 200);
  glViewport (0, 0, 200, 200); /*!!!*/


  glClearColor (1.0, 1.0, 0.0, 0.0);  /*backgraund*/
  /* glClearIndex (YColor("blue")); */

  glMatrixMode (GL_PROJECTION);
  glLoadIdentity ();

  glDepthFunc (GL_LESS);
  glEnable( GL_DEPTH_TEST );
  glClear( GL_COLOR_BUFFER_BIT  |  GL_DEPTH_BUFFER_BIT );

  glPointSize (1);
  glLineWidth (1);

#else
#endif

  return;
}
/*----------------------------D3_DrawPoint-----------------------------------*/
YT_BOOL
D3_DrawPoint (VT_CAM3D *cam3d, YT_SPACE x, YT_SPACE y, YT_SPACE z, YT_COLOR color)
{
  int     n, m;
  YT_SPACE zz;

  D3_PointToScreen (cam3d, x, y, z, &n, &m, &zz);

  if (PRINTS)
    return (VHandPixel (n, m, color, zz));

  return (FALSE);
}
/*------------------------D3_Rotate-------------------------------*/
void
D3_Rotate (VT_CAM3D *cam3d, int alfa, int beta)
{

  cam3d->alfa += alfa;
  cam3d->beta += beta;

#if defined(D_OPENGL)
  glRotatef (alfa, 1, 0, 0);
  glRotatef (beta, 0, 1, 0);
#else
#endif

}
/*-----------------------------D3_SetRotate---------------------------------*/
void
D3_SetRotate(VT_CAM3D *cam3d, int alfa, int beta)
{

  cam3d->alfa = alfa;
  cam3d->beta = beta;

#ifdef D_OPENGL
  glMatrixMode (GL_MODELVIEW);	
  glLoadIdentity ();
  /*   set init ???!!!   */
  glRotatef( alfa, 1, 0, 0 );
  glRotatef( beta, 0, 1, 0 );
#else
#endif

}
/*-----------------------------D3_GetRotate---------------------------------*/
void
D3_GetRotate(VT_CAM3D *cam3d, int *alfa, int *beta)
{

#ifdef D_OPENGL
#else
   *alfa = cam3d->alfa;
   *beta = cam3d->beta;
#endif

}
/*------------------------D3_Perspective----------------------------*/
void
D3_Perspective (VT_CAM3D *cam3d, float eyez, float x0, float y0, float w, float h,
                float z_near, float z_far)
{
  
#if defined(D_OPENGL)
  float left, top, right, bottom, near, far;

  glMatrixMode (GL_MODELVIEW);	
  glLoadIdentity ();
  glTranslatef (0, 0, eyez);

  left   = x0 - w/2;
  top    = y0 + h/2;
  right  = x0 + w/2;
  bottom = y0 - h/2; 
  near = abs (eyez - z_near);
  far  = abs (eyez - z_far);

  glMatrixMode (GL_PROJECTION);	
  glLoadIdentity ();
  glFrustum (left, right, bottom, top, near, far);
#else
#endif


}
/*------------------------D3_Orthographic-------------------------*/
void
D3_Orthographic (VT_CAM3D *cam3d, float eyez, float x0, float y0, float w, float h, float z_near, float z_far)
{

#if defined(D_OPENGL)
  float  left, top, right, bottom, near, far;
#endif

  cam3d->cx = x0;
  cam3d->cy = y0;
  cam3d->w  = w;
/*   cam3d->h  = h; */
  cam3d->zplane = z_near;
/*   cam3d->zview  = eyez; */
  cam3d->zview_flag = FALSE; 

#if defined(D_OPENGL)

  /*glMatrixMode (GL_MODELVIEW);	
  glLoadIdentity ();
  glTranslatef (0, 0, eyez);*/

  left   = x0 - w/2;
  top    = y0 + h/2;
  right  = x0 + w/2;
  bottom = y0 - h/2; 

  glMatrixMode (GL_PROJECTION);	
  glLoadIdentity ();
  glOrtho (left, right, bottom, top, z_near, z_far);
    
  glDepthRange (z_near, z_far);
#else
#endif

}  
/*------------------------D3_Viewport------------------------------*/
void
D3_Viewport (VT_CAM3D *cam3d, int x, int y, int w, int h)
{

  cam3d->scrx = x;
  cam3d->scry = y;
  cam3d->scrw = w;
  cam3d->scrh = h;

#if defined(D_OPENGL)
  y = Y_HDISPLAY - y - h;
  glViewport (x, y, w, h);
#else
#endif

}
/*---------------------------D3_DrawLine-------------------------------------*/
void
D3_DrawLine (VT_CAM3D *cam3d, YT_SPACE x1, YT_SPACE y1, YT_SPACE z1,
	    YT_SPACE x2, YT_SPACE y2, YT_SPACE z2,
	    YT_COLOR color)
{

  int     n1, m1, n2, m2;
  YT_SPACE zz1, zz2;

  D3_PointToScreen (cam3d, x1, y1, z1, &n1, &m1, &zz1);
  D3_PointToScreen (cam3d, x2, y2, z2, &n2, &m2, &zz2);

  if (!PRINTS)
    return;

#if defined(D_OPENGL)

  /* OUTS ("GL_LINES"); */
  fprintf (stderr, "p1 = %f %f %f \n", x1, y1, z1); 
  fprintf (stderr, "p2 = %f %f %f \n", x2, y2, z2); 
  /* glIndexi( color ); */   glColor3f(1.0, 0.0, 0.0);
  glBegin(GL_LINES);
	 glVertex3f(x1, y1, z1);
	 glVertex3f(x2, y2, z2);
  glEnd();
  glFlush();

#else

  if (color == CLR_XOR)
    YDrawLine (n1, m1, n2, m2, YColor("white"));
  else 
    VHandLine (n1, m1, n2, m2, color, zz1 - ZBUFF_eps_line,
	       zz2 - ZBUFF_eps_line);
#endif

}
/*-------------------------D3_DrawTriang-------------------------------------*/
void
D3_DrawTriang (VT_CAM3D *cam3d, VT_TRI3D *t)
{

/* #if defined(D_OPENGL) */

/*   glIndexi( t->f_color );  */
/*   glBegin(GL_POLYGON); */
/* 	 glVertex3f((t->p1).x, (t->p1).y, (t->p1).z); */
/* 	 glVertex3f((t->p2).x, (t->p2).y, (t->p2).z); */
/* 	 glVertex3f((t->p3).x, (t->p3).y, (t->p3).z); */
/*   glEnd(); */
/*   glFlush(); */

/* #else */

  VT_PTRI3D ptri;
  static YT_COLOR black;

  black = YColor("black");
  ptri.p1 = &(t->p1);
  ptri.p2 = &(t->p2);
  ptri.p3 = &(t->p3);
  ptri.f_color = &(t->f_color);
  ptri.l_color = &black;

  D3_DrawTri (cam3d, &ptri);

/* #endif */

}
/*---------------------------D3_DrawTri--------------------------------------*/
void
D3_DrawTri (VT_CAM3D *cam3d, VT_PTRI3D *p)
{

  YT_SPACE x1 = (p->p1)->x, y1 = (p->p1)->y, z1 = (p->p1)->z;
  YT_COLOR c1 = (p->p1)->color;
  YT_SPACE x2 = (p->p2)->x, y2 = (p->p2)->y, z2 = (p->p2)->z;
  YT_COLOR c2 = (p->p2)->color;
  YT_SPACE x3 = (p->p3)->x, y3 = (p->p3)->y, z3 = (p->p3)->z;
  YT_COLOR c3 = (p->p3)->color;

  YT_COLOR f_color = *(p->f_color), l_color = *(p->l_color);
  float   angl = 0.0;
  VT_VECTOR N, a, b;

  int     n1, m1, n2, m2, n3, m3;
  YT_SPACE zz1, zz2, zz3;

  D3_PointToScreen (cam3d, x1, y1, z1, &n1, &m1, &zz1);
  D3_PointToScreen (cam3d, x2, y2, z2, &n2, &m2, &zz2);
  D3_PointToScreen (cam3d, x3, y3, z3, &n3, &m3, &zz3);

  if (!PRINTS)  return;

#if defined(D_OPENGL)

  /* OUTS ("GL_POLYGON"); */
  /* glIndexi( f_color ); */  glColor3f(1.0, 0.0, 0.0);
  glBegin(GL_POLYGON);
	 glVertex3f(x1, y1, z1);
	 glVertex3f(x2, y2, z2);
	 glVertex3f(x3, y3, z3);
  glEnd();
  glFlush();

#else

  if (V3_LIGHT) {
    a.x = x2 - x1;
    a.y = y2 - y1;
    a.z = z2 - z1;
    b.x = x3 - x1;
    b.y = y3 - y1;
    b.z = z3 - z1;
    VVecMultVec (&N, &a, &b);
    angl = (N.x) / (VVecLenght (&N));
    f_color = D3_LightDo (f_color, angl);
  }
  VHandTriF (n1, m1, n2, m2, n3, m3, f_color, zz1, zz2, zz3, c1, c2, c3);

  l_color++;

#endif

}
/*----------------------------D3_ViewportMove--------------------------------*/
void
D3_ViewportMove (VT_CAM3D *cam3d, int dx, int dy, int dw, int dh)
{

  D3_Viewport (cam3d, cam3d->scrx + dx, cam3d->scry + dy, 
	              cam3d->scrw + dw, cam3d->scrh + dh);

  return;
}
/*-----------------------------D3_ColbufBegin--------------------------------*/
void
D3_ColbufBegin (VT_CAM3D *cam3d)
{

#if defined(D_OPENGL)
  glClear( GL_COLOR_BUFFER_BIT  |  GL_DEPTH_BUFFER_BIT );
#else
  cam3d->cmap = YColmapCreate ();
  YColmapInit (cam3d->cmap, cam3d->scrw, cam3d->scrh);
  YColmapBeginDraw (cam3d->cmap, 0, 0, cam3d->background);
#endif

}
/*-----------------------------D3_ColbufEnd----------------------------------*/
void
D3_ColbufEnd ()
{

#if defined(D_OPENGL)
#else
  YColmapEndDraw ();
#endif

}
/*-----------------------------D3_ColbufSwap----------------------------------*/
void
D3_ColbufSwap (VT_CAM3D *cam3d, int x, int y)
{

#if defined(D_OPENGL)
  static GC gc;
  Display *dpy = (Display*) YGet_DPY();
  Window   win = (Window)   YGet_WIN();

  void *cmap;
  int  i, j, w, h;
  long *ptr;
  YT_COLOR color;

  glFlush();

  /* glXSwapBuffers((Display*)YGet_DPY(), (Window)YGet_WIN());  */


   /* make an X GC so we can do XCopyArea later */
   /* gc = XCreateGC( dpy, win, 0, NULL ); */
   /* OUTD(111); */
   /* copy the image from GLXPixmap to window */
   /* src pos, size,  dest pos */
/*     XCopyArea( dpy, (Pixmap)(SSS.pm), win, gc,  */
/* 	       0, 0, 50, 50,                */
/* 	       x+100, y+100 );                           */


  w = cam3d->scrw;
  h = cam3d->scrh;

/*   ptr = malloc (w*h*sizeof (long)); */
/*   glReadPixels (0, 0, w, h, GL_COLOR_INDEX, GL_UNSIGNED_INT, ptr);   */

  cmap = YColmapCreate ();
  YColmapInit (cmap, w, h);
  YColmapBeginDraw (cmap, 0, 0, YColor("lime"));
  for (i = 0; i < w; i++)
  for (j = 0; j < h; j++) {
/*     color = (YT_COLOR)(ARR2(ptr,w,h,i,j)); */
    /* color = (YT_COLOR)(ARR2((char*)(SSS.buffer),w,h,i,j)); */
    color = (YT_COLOR)(ptr[(j*w+i)*4]);
    /* color = YColor("yellow"); */
    /* OUTD(color); */
    YColmapDrawPixel (i, j, color);
  }
  YColmapEndDraw ();
  YDrawColmapB (cmap, x, y, 0, 0, YColor("black"));

#else
  YDrawColmapB (cam3d->cmap, x, y, 0, 0, YColor("black"));
#endif

}
/*-----------------------------------------------------------*/
void my_draw ()
{


#if defined(D_OPENGL)
  /* glIndexi( Red ); */   glColor3f(1.0, 0.0, 0.0);
  glBegin(GL_LINES);
	 glVertex3f(0.0, 0.0, 0.0);
	 glVertex3f(1.0, 0.0, 0.0);
  glEnd();

  /* glIndexi( Green );  */  glColor3f(0.0, 1.0, 0.0);
  glBegin(GL_LINES);
	 glVertex3f(0.0, 0.0, 0.0);
	 glVertex3f(0.0, 1.0, 0.0);
  glEnd();

  /* glIndexi( Blue );  */  glColor3f(0.0, 0.0, 1.0);
  glBegin(GL_LINES);
	 glVertex3f(0.0, 0.0, 0.0);
	 glVertex3f(0.0, 0.0, 1.0);
  glEnd();

  glIndexi( YColor("white") ); /* glColor3f(1.0, 1.0, 1.0); */
  glBegin(GL_POLYGON);
	 glVertex3f(1.0, 0.0, 0.0);
	 glVertex3f(0.0, 1.0, 0.0);
	 glVertex3f(0.0, 0.0, 1.0);
  glEnd();
#endif

}
/*-----------------------------D3_DrawWorld----------------------------------*/
void
D3_DrawWorld (VT_W3D *w3d, int x, int y, int whatdraw)
{
  /* void   *cmap; */
  VT_CAM3D *cam3d = w3d->cam3d;

  switch (whatdraw) {
  case YMAIN:
    D3_ColbufBegin (cam3d);
    D3_DrawAll (w3d);
    D3_ColbufEnd ();

    D3_ColbufSwap (cam3d, x, y);
    break;
  case YXOR:
    D3_ViewportMove (cam3d, x, y, 0, 0);
    D3_DrawXor (w3d);
    D3_ViewportMove (cam3d, -x, -y, 0, 0);
    break;
  case YCUBE:
    D3_ViewportMove (cam3d, x, y, 0, 0);
    D3_DrawCube (w3d->cam3d, cam3d->cube_x0, cam3d->cube_y0, cam3d->cube_z0, 
		cam3d->cube_size, CLR_XOR);
    D3_ViewportMove (cam3d, -x, -y, 0, 0);
    break;
  default:
    YError ("whatdraw");
  }

  return;
}
/*----------------------------D3_ZbufBegin-----------------------------------*/
YT_BOOL
D3_ZbufBegin (int w, int h)
{
  int     i, j;
/*   size_t  size_bufval = sizeof (VT_ZBUFVAL); */

  /*   if (PRINTS)  */
  /*     return (FALSE); */ /*????*/

  YMALLOC (ZBUFF_ptr, VT_ZBUFVAL, (w * h))

  ZBUFF_w = w;
  ZBUFF_h = h;
  for (i = 1; i <= w; i++)
  for (j = 1; j <= h; j++)
      ZBUFF_val (i, j) = MAXZBUFVAL;

  ZBUFF_flag = TRUE;

  return (TRUE);
}
/*----------------------------D3_ZbufEnd-------------------------------------*/
void
D3_ZbufEnd ()
{

  /* if (PRINTS)       return; */
  if (!ZBUFF_flag)  return;

  free (ZBUFF_ptr);
  ZBUFF_flag = FALSE;

}
/*------------------------------D3_DrawAll-----------------------------------*/
void
D3_DrawAll (VT_W3D *w3d)
{
  VT_OBJ3D **obj3d = w3d->o3d;
  VT_CAM3D *cam3d = w3d->cam3d;
  int     i, ii;
  long    long1, long2;

  /* D3_ZbufBegin (cam3d->scrw, cam3d->scrh); */

  if (PRINTS) {
    /* if (!D3_ZbufBegin (cam3d->scrw, cam3d->scrh))  YError ("Not Z-buffer"); */
    if (cam3d->guro)   D3_GuroYes ();
    if (cam3d->light)  D3_LightShow ();
  }

  ZBUFF_eps_line = 0.01 * cam3d->w;
  ZBUFF_eps_reps = 2 * ZBUFF_eps_line;
  ZBUFF_eps_text = 3 * ZBUFF_eps_line;

  ZBUFF_zplane = cam3d->zplane;

  for (i = 0; i < MAX_OBJ3D; i++) {
    if (!obj3d[i] || !obj3d[i]->existed || !obj3d[i]->visible)
      continue;
    long1 = obj3d[i]->long1;
    long2 = obj3d[i]->long2;

    YSWITCH (obj3d[i]->tname) {
    YCASE ("VPLINES3D")
      D3_DrawPlines (w3d->cam3d, obj3d[i]);
    YCASE ("VFLINES3D")
      D3_DrawFlines (w3d->cam3d, obj3d[i]);
    YCASE ("VSETKA3D")
      D3_DrawSetka (w3d->cam3d, obj3d[i]);
    YCASE ("MARKERS")
      D3_DrawMarkerS (w3d->cam3d, obj3d[i]);
    YCASE ("VSURF")
      D3_DrawSurf (w3d->cam3d, obj3d[i]);
    YCASE ("VPOINTS")
      D3_DrawPoints (w3d->cam3d, obj3d[i]);
    YCASE ("VTELO3D")
      D3_LightHide ();
      D3_DrawTeloMain (w3d->cam3d, obj3d[i]);
      if (cam3d->light)  D3_LightShow ();
    YCASE ("VPTRIS3D")
      {
	VT_PTRI3D *p = (VT_PTRI3D *) long1;
	ii = (int) long2;
	for (i = 0; i < ii; i++)
	  D3_DrawTri (cam3d, p++);
      }
    YCASE ("VTRIS3D")
      {
	VT_TRI3D *p = (VT_TRI3D *) long1;
	ii = (int) long2;
	for (i = 0; i < ii; i++)
	  D3_DrawTriang (cam3d, p++);
      }
    YDEFAULT
    }

/*     switch (obj3d[i]->type) { */
/*     case VPLINES3D: */
/*       D3_DrawPlines (w3d->cam3d, obj3d[i]); */
/*       break; */
/*     case VFLINES3D: */
/*       D3_DrawFlines (w3d->cam3d, obj3d[i]); */
/*       break; */
/*     case VSETKA3D: */
/*       D3_DrawSetka (w3d->cam3d, obj3d[i]); */
/*       break; */
/*     case VSURF: */
/*       D3_DrawSurf (w3d->cam3d, obj3d[i]); */
/*       break; */
/*     case VPOINTS: */
/*       D3_DrawPoints (w3d->cam3d, obj3d[i]); */
/*       break; */
/*     case VTELO3D: */
/*       D3_LightHide (); */
/*       D3_DrawTeloMain (w3d->cam3d, obj3d[i]); */
/*       if (cam3d->light)  D3_LightShow (); */
/*       break; */
/*     case VPTRIS3D: */
/*       { */
/* 	VT_PTRI3D *p = (VT_PTRI3D *) long1; */
/* 	ii = (int) long2; */
/* 	for (i = 0; i < ii; i++) */
/* 	  D3_DrawTri (cam3d, p++); */
/*       } */
/*       break; */
/*     case VTRIS3D: */
/*       { */
/* 	VT_TRI3D *p = (VT_TRI3D *) long1; */
/* 	ii = (int) long2; */
/* 	for (i = 0; i < ii; i++) */
/* 	  D3_DrawTriang (cam3d, p++); */
/*       } */
/*       break; */
/*     default:;;; */
/*     } */

  }
  if (cam3d->repers)   D3_DrawRepers (cam3d);
  if (cam3d->xzy_box)  D3_DrawBox (cam3d, &(w3d->xzy_box), YColor("black"));

  if (PRINTS) {
    D3_GuroNot ();
    D3_LightHide ();
    /* D3_ZbufEnd (); */
  }

  /* D3_ZbufEnd (); */
  return;
}
/*----------------------------D3_DrawBox-------------------------------------*/
void
D3_DrawBox (VT_CAM3D *cam3d, VT_BOX *b, YT_COLOR color)
{
  VT_P3D *p1, *p2;

  p1 = &b->p1; 
  p2 = &b->p2;
  D3_DrawLine (cam3d, p1->x, p1->y, p1->z, p2->x, p2->y, p2->z, color);
  p1 = &b->p2; 
  p2 = &b->p6;
  D3_DrawLine (cam3d, p1->x, p1->y, p1->z, p2->x, p2->y, p2->z, color);
  p1 = &b->p6;
  p2 = &b->p5;
  D3_DrawLine (cam3d, p1->x, p1->y, p1->z, p2->x, p2->y, p2->z, color);
  p1 = &b->p5;
  p2 = &b->p1;
  D3_DrawLine (cam3d, p1->x, p1->y, p1->z, p2->x, p2->y, p2->z, color);
  p1 = &b->p3;
  p2 = &b->p4;
  D3_DrawLine (cam3d, p1->x, p1->y, p1->z, p2->x, p2->y, p2->z, color);
  p1 = &b->p4;
  p2 = &b->p8;
  D3_DrawLine (cam3d, p1->x, p1->y, p1->z, p2->x, p2->y, p2->z, color);
  p1 = &b->p8;
  p2 = &b->p7;
  D3_DrawLine (cam3d, p1->x, p1->y, p1->z, p2->x, p2->y, p2->z, color);
  p1 = &b->p7;
  p2 = &b->p3;
  D3_DrawLine (cam3d, p1->x, p1->y, p1->z, p2->x, p2->y, p2->z, color);
  p1 = &b->p1;
  p2 = &b->p3;
  D3_DrawLine (cam3d, p1->x, p1->y, p1->z, p2->x, p2->y, p2->z, color);
  p1 = &b->p2;
  p2 = &b->p4;
  D3_DrawLine (cam3d, p1->x, p1->y, p1->z, p2->x, p2->y, p2->z, color);
  p1 = &b->p6;
  p2 = &b->p8;
  D3_DrawLine (cam3d, p1->x, p1->y, p1->z, p2->x, p2->y, p2->z, color);
  p1 = &b->p5;
  p2 = &b->p7;
  D3_DrawLine (cam3d, p1->x, p1->y, p1->z, p2->x, p2->y, p2->z, color);

}
/*-----------------------------D3_DrawSlice----------------------------------*/
void
D3_DrawSlice (VT_VOL3D *vol3d, VT_CAM3D *cam3d)
{
  YT_SPACE *p = vol3d->p;
  int     npoints = vol3d->ii;
  int     size = (vol3d->probe3d).cellsize;
  VT_PROBE3D *prob3d = &(vol3d->probe3d);

  int     i, j;
  YT_SPACE *ptrf;
  int    *ptri;
  int     cellx, celly, cellh;
  YT_SIZET numer;
  YT_SPACE x, y, z, h;
  YT_SPACE xmin, ymin, zmin, hmin, xmax, ymax, zmax, hmax;
  int     num_cellx = cam3d->scrw / size, num_celly = cam3d->scrh / size;
  YT_SPACE xstep, hstep;

  if (!p)  return;

  if (YOVERFLOW (num_cellx * num_celly * sizeof (int))) {
    YSetCliping (FALSE, 0, 0, 0, 0);
    YMessageBox ("Too large screen!", "OK");
    YSetCliping (TRUE, cam3d->scrx, cam3d->scry,cam3d->scrw, cam3d->scrh);
    return;
  }
  if (!(ptrf = (YT_SPACE *) malloc (num_cellx * num_celly * sizeof (YT_SPACE)))) {
    YMessageBox ("Not memory1!", "OK");
    return;
  }
  if (!(ptri = (int *) malloc (num_cellx * num_celly * sizeof (int)))) {
    free (ptrf);
    YMessageBox ("Not memory2!", "OK");
    return;
  }
  for (numer = 0; numer < num_cellx * num_celly; numer++) {
    *(ptrf + numer) = 0;
    *(ptri + numer) = 0;
  }
  if ((vol3d->probe3d).check) {
    xmin = cam3d->cx - cam3d->w / 2;
    xmax = cam3d->cx + cam3d->w / 2;
    zmin = prob3d->z0 - prob3d->zW / 2;
    zmax = prob3d->z0 + prob3d->zW / 2;
    hmin = prob3d->h0 - prob3d->hW / 2;
    hmax = prob3d->h0 + prob3d->hW / 2;
  } else {
    xmin = YMAXSPACE;  xmax = YMINSPACE;
    ymin = YMAXSPACE;  ymax = YMINSPACE;
    zmin = YMAXSPACE;  zmax = YMINSPACE;
    hmin = YMAXSPACE;  hmax = YMINSPACE;
    for (i = 0; i < npoints; i++) {
      x = A_VOL3D (vol3d, i, 1);
      y = A_VOL3D (vol3d, i, 2);
      z = A_VOL3D (vol3d, i, 3);
      h = A_VOL3D (vol3d, i, 4);
      D3_TransAndRot (cam3d, &x, &y, &z);
      xmin = YMIN (x, xmin);  xmax = YMAX (x, xmax);
      ymin = YMIN (y, ymin);  ymax = YMAX (y, ymax);
      zmin = YMIN (z, zmin);  zmax = YMAX (z, zmax);
      hmin = YMIN (h, hmin);  hmax = YMAX (h, hmax);
    }
    cam3d->w = xmax - xmin;
    cam3d->cx = xmin + (xmax - xmin);
    cam3d->cy = ymin + (ymax - ymin);
    prob3d->zW = zmax - zmin;
    prob3d->z0 = zmin + (zmax - zmin) / 2;
    prob3d->hW = hmax - hmin;
    prob3d->h0 = hmin + (hmax - hmin) / 2;
    cam3d->cube_x0 = cam3d->cx;
    cam3d->cube_y0 = cam3d->cy;
    cam3d->cube_z0 = prob3d->z0;
  }

  xstep = cam3d->w / num_cellx;
  hstep = (hmax - hmin) / YGet("size_scale");

  for (i = 0; i < npoints; i++) {
    x = A_VOL3D (vol3d, i, 1);
    y = A_VOL3D (vol3d, i, 2);
    z = A_VOL3D (vol3d, i, 3);
    h = A_VOL3D (vol3d, i, 4);
    D3_TransAndRot (cam3d, &x, &y, &z);
    if (x < xmin || x > xmax)  continue;
    if (y < ymin || y > ymax)  continue;
    if (z < zmin || z > zmax)  continue;
    if (h < hmin || h > hmax)  continue;
    cellx = (int) ((x - xmin) / xstep + 1);
    celly = cellx;
    numer = (celly - 1) * num_cellx + cellx - 1;
    (*(ptrf + numer)) += h;
    (*(ptri + numer))++;
  }

  for (numer = 0; numer < num_cellx * num_celly; numer++) {
    if ((*(ptri + numer)) != 0)  h = (*(ptrf + numer)) / (*(ptri + numer));
    else                         h = 0;
    *(ptri + numer) = (int) ((h - hmin) / hstep) + 1;
  }

  for (cellx = 0; cellx < num_cellx; cellx++)
  for (celly = 0; celly < num_celly; celly++) {
    numer = celly * num_cellx + cellx;
    cellh = *(ptri + numer);
    for (j = 0; j < size; j++)
    for (i = 0; i < size; i++)
      YDrawPixel (cam3d->scrx + cellx * size + j, cam3d->scry + celly * size + i,
		  YScale (cellh));
  }
  
  free ((void *) ptri);
  free ((void *) ptrf);

  return;
}
/*-----------------------------D3_DrawCube-----------------------------------*/
void
D3_DrawCube (VT_CAM3D *cam3d, YT_SPACE cube_x0, YT_SPACE cube_y0, YT_SPACE cube_z0,
	    YT_SPACE cube_size, YT_COLOR color)
{
  float   cub_standart[12][2][3] =
  {
    {{-0.5, -0.5,  0.5},  { 0.5, -0.5,  0.5}},
    {{ 0.5, -0.5,  0.5},  { 0.5,  0.5,  0.5}},
    {{ 0.5,  0.5,  0.5},  {-0.5,  0.5,  0.5}},
    {{-0.5,  0.5,  0.5},  {-0.5, -0.5,  0.5}},
    {{-0.5, -0.5, -0.5},  { 0.5, -0.5, -0.5}},
    {{ 0.5, -0.5, -0.5},  { 0.5,  0.5, -0.5}},
    {{ 0.5,  0.5, -0.5},  {-0.5,  0.5, -0.5}},
    {{-0.5,  0.5, -0.5},  {-0.5, -0.5, -0.5}},
    {{-0.5, -0.5,  0.5},  {-0.5, -0.5, -0.5}},
    {{ 0.5, -0.5,  0.5},  { 0.5, -0.5, -0.5}},
    {{ 0.5,  0.5,  0.5},  { 0.5,  0.5, -0.5}},
    {{-0.5,  0.5,  0.5},  {-0.5,  0.5, -0.5}},
  };
  float   cub[12][2][3];
  int     i, j;
  YT_SPACE x1, y1, z1, x2, y2, z2;
  /* YT_SPACE cube_x0, cube_y0, cube_z0; */


  for (i = 0; i < 12; i++)
  for (j = 0; j < 2; j++) {
    cub[i][j][0] = /* cam3d-> */cube_x0 + (cub_standart[i][j][0]) * (cube_size);
    cub[i][j][1] = /* cam3d-> */cube_y0 + (cub_standart[i][j][1]) * (cube_size);
    cub[i][j][2] = /* cam3d-> */cube_z0 + (cub_standart[i][j][2]) * (cube_size);
  }

  if (color == CLR_XOR) YSetXorDraw (TRUE);

  for (i = 0; i < 12; i++) {
    x1 = cub[i][0][0];
    y1 = cub[i][0][1];
    z1 = cub[i][0][2];
    x2 = cub[i][1][0];
    y2 = cub[i][1][1];
    z2 = cub[i][1][2];
    D3_DrawLine (cam3d, x1, y1, z1, x2, y2, z2, color);
  }

  if (color == CLR_XOR) YSetXorDraw (FALSE);

  return;
}
/*----------------------------V3cube_proc-----------------------------------*/
long
V3cube_proc (PFUNC_VAR)
{
#define cam3d ((VT_CAM3D*)mes3)
#define boxing (!(cam3d->boxing))

  enum y_keys {
    MY_DLGBUTTS = YKEY_LOCALS + 1,
    MY_ROTATEBEGIN, MY_ROTATESTEP, MY_ROTATEEND,
    MY_MOVEBEGIN, MY_MOVESTEP, MY_MOVEEND,
    MY_ZOOMBEGIN, MY_ZOOMSTEP, MY_ZOOMEND,
    MY_ENDRMZ
  };
  static int hor_old, hor_delta, ver_old, ver_delta, alfa_old, beta_old;
  static YT_SPACE hor_fdelta, ver_fdelta;
  static YT_SPACE camera_cx_old, camera_cy_old, camera_w_old;
  static YT_SPACE mashtab, fscale;
  static YT_BOOL rot = FALSE, mov = FALSE, zom = FALSE;
  static YT_BOOL rmz = FALSE;

  switch (message) {
  case MY_ROTATEBEGIN:
    hor_old = mes1;
    ver_old = mes2;
/*     alfa_old = cam3d->alfa; */
/*     beta_old = cam3d->beta; */
    D3_GetRotate (cam3d, &alfa_old, &beta_old);
    break;
  case MY_MOVEBEGIN:
    hor_old = mes1;
    ver_old = mes2;
    mashtab = cam3d->w / cam3d->scrw;
    camera_cx_old = cam3d->cx;
    camera_cy_old = cam3d->cy;
    break;
  case MY_ZOOMBEGIN:
    ver_old = mes2;
    mashtab = cam3d->w / cam3d->scrw;
    camera_w_old = cam3d->w;
    break;
  case MY_ROTATESTEP:
    hor_delta = (mes1 - hor_old);
    ver_delta = (mes2 - ver_old);
    if (boxing) ;
/*     cam3d->alfa = alfa_old + ver_delta; */
/*     cam3d->beta = beta_old + hor_delta; */
    D3_SetRotate (cam3d, alfa_old + ver_delta, beta_old + hor_delta);

    if (boxing)  YGoto (YDRAWITEM, 0, 0, 0, 0);
    else         YGoto (YDRAWALL,  0, 0, 0, 0);
    break;
  case MY_MOVESTEP:
    hor_fdelta = (mes1 - hor_old) * mashtab;
    ver_fdelta = (mes2 - ver_old) * mashtab;
    if (boxing) ;
    cam3d->cx = camera_cx_old - hor_fdelta;
    cam3d->cy = camera_cy_old + ver_fdelta;
    if (boxing)  YGoto (YDRAWITEM, 0, 0, 0, 0);
    else         YGoto (YDRAWALL, 0, 0, 0, 0);
    break;
  case MY_ZOOMSTEP:
    ver_fdelta = (mes2 - ver_old) * mashtab;
    fscale = camera_w_old / (camera_w_old + ver_fdelta);
    if (boxing) {/***/ ;}
    cam3d->w = camera_w_old * fscale;
    if (boxing)  YGoto (YDRAWITEM, 0, 0, 0, 0);
    else         YGoto (YDRAWALL, 0, 0, 0, 0);
    break;
  case YEND:
  case MY_ENDRMZ:
    if (!rmz)
      break;
    rmz = FALSE;
    YGoto (YDRAWITEM, 0, 0, 0, 0);
    break;
  case YLMOUSEDOUBLE:
    YGoto (MY_ENDRMZ, 0, 0, 0, 0);
    YGoto (YREDRAW, 0, 0, 0, 0);
    break;
  case YLMOUSEDOWN:
    if (!rmz && boxing) {
      rmz = TRUE;
      D3_SetCube (cam3d);
      YGoto (YDRAWITEM, 0, 0, 0, 0);
    }
    if (zom) {
      zom = FALSE;
      mov = TRUE;
      YGoto (MY_MOVEBEGIN, mes1, mes2, mes3, mes4);
    } else {
      YGoto (MY_ROTATEBEGIN, mes1, mes2, mes3, mes4);
      rot = TRUE;
    }
    break;
  case YRMOUSEDOWN:
    if (!rmz && boxing) {
      rmz = TRUE;
      D3_SetCube (cam3d);
      YGoto (YDRAWITEM, 0, 0, 0, 0);
    }
    if (rot) {
      rot = FALSE;
      mov = TRUE;
      YGoto (MY_MOVEBEGIN, mes1, mes2, mes3, mes4);
    } else {
      YGoto (MY_ZOOMBEGIN, mes1, mes2, mes3, mes4);
      zom = TRUE;
    }
    break;
  case YLMOUSEDRAG:
    if (rot)  YGoto (MY_ROTATESTEP, mes1, mes2, mes3, mes4);
    break;
  case YLRMOUSEDRAG:
    YGoto (MY_MOVESTEP, mes1, mes2, mes3, mes4);
    break;
  case YRMOUSEDRAG:
    if (zom)  YGoto (MY_ZOOMSTEP, mes1, mes2, mes3, mes4);
    break;
  case YLMOUSEUP:
    if (rot)  rot = FALSE;
    if (mov) {
      mov = FALSE;
      YGoto (YRMOUSEDOWN, mes1, mes2, mes3, mes4);
    }
    break;
  case YRMOUSEUP:
    if (zom)  zom = FALSE;
    if (mov) {
      mov = FALSE;
      YGoto (YLMOUSEDOWN, mes1, mes2, mes3, mes4);
    }
    break;
  default:;;;
  }

#undef cam3d
#undef boxing
  id++;
  /* return (TRUE); */
  RETURN_TRUE;
}
/*--------------------------D3_PointToPlane-------------------------------------*/
void
D3_PointToPlane (VT_CAM3D *cam3d, YT_SPACE *px, YT_SPACE *py, YT_SPACE *pz)
{
  YT_SPACE x, y, z, zrab/* , len */;

  if (!cam3d->zview_flag) return;
  x = *px;  
  y = *py;  
  z = *pz;

  zrab = (cam3d->zplane - cam3d->zview)/(z - cam3d->zview);
  x = x * zrab; 
  y = y * zrab; 
/*   len = sqrt (pow(0-x,2) + pow(0-y,2) + pow(cam3d->zview-cam3d->zplane,2)); */
/*   z = len; */

  *px = x;  
  *py = y;  
  *pz = z;
  return;
}
/*--------------------------D3_PointToScreen---------------------------------*/
void
D3_PointToScreen (VT_CAM3D *cam3d, YT_SPACE x, YT_SPACE y, YT_SPACE z,
		 int *pn, int *pm, YT_SPACE *zz)
{

  D3_TransAndRot (cam3d, &x, &y, &z);
  D3_PointToPlane (cam3d, &x, &y, &z);
  D3_PlaneToScreen (cam3d, x, y, pn, pm);

  *zz = z;

  return;
}
/*--------------------------D3_RotateOX-----------------------------------*/
void
D3_RotateOX (YT_SPACE rad_alfa, YT_SPACE *px, YT_SPACE *py, YT_SPACE *pz)
{
  YT_SPACE  x, y, z;

  x = *px;
  y = *py;
  z = *pz;

  /* counterclockwise rotate about OX */

  *px =  x;
  *py =  y * cos (rad_alfa) + z * sin (rad_alfa);
  *pz = -y * sin (rad_alfa) + z * cos (rad_alfa);

  return;
}
/*--------------------------D3_RotateOY-----------------------------------*/
void
D3_RotateOY (YT_SPACE rad_beta, YT_SPACE *px, YT_SPACE *py, YT_SPACE *pz)
{
  YT_SPACE  x, y, z;

  x = *px;
  y = *py;
  z = *pz;

  /* counterclockwise rotate about OY */

  *px =  x * cos (rad_beta) - z * sin (rad_beta);
  *py =  y;
  *pz =  x * sin (rad_beta) + z * cos (rad_beta);

  return;
}
/*--------------------------D3_TransAndRot-----------------------------------*/
void
D3_TransAndRot (VT_CAM3D *cam3d, YT_SPACE *px, YT_SPACE *py, YT_SPACE *pz)
{
  YT_SPACE  X, Y, Z;

  X = *px - cam3d->cube_x0;
  Y = *py - cam3d->cube_y0;
  Z = *pz - cam3d->cube_z0;

  D3_RotateOX (RAD(cam3d->alfa), &X, &Y, &Z);
  D3_RotateOY (RAD(cam3d->beta), &X, &Y, &Z);

  X = X + cam3d->cube_x0;
  Y = Y + cam3d->cube_y0;
  Z = Z + cam3d->cube_z0;

  if (CALCUS) {
    if      (X < SSS.xmin3d)  SSS.xmin3d = X;
    else if (X > SSS.xmax3d)  SSS.xmax3d = X;

    if      (Y < SSS.ymin3d)  SSS.ymin3d = Y;
    else if (Y > SSS.ymax3d)  SSS.ymax3d = Y;

    if      (Z < SSS.zmin3d)  SSS.zmin3d = Z;
    else if (Z > SSS.zmax3d)  SSS.zmax3d = Z;
  }

  *px = X;
  *py = Y;
  *pz = Z;
  return;
}
/*-------------------------D3_PlaneToScreen----------------------------------*/
void
D3_PlaneToScreen (VT_CAM3D *cam3d, YT_SPACE x_plane, YT_SPACE y_plane,
		 int *n, int *m)
{
  YT_SPACE step;
  int     scr_cx = cam3d->scrx + cam3d->scrw / 2;
  int     scr_cy = cam3d->scry + cam3d->scrh / 2;

  step = cam3d->w / (cam3d->scrw);

  *n = (int) (scr_cx + (x_plane - cam3d->cx) / step);
  *m = (int) (scr_cy - (y_plane - cam3d->cy) / step);

}
/*---------------------------D3_DrawRepers-----------------------------------*/
void
D3_DrawRepers (VT_CAM3D *cam3d)
{
  YT_SPACE l = cam3d->repers;
  YT_COLOR color = cam3d->repers_color;
  int     n0, m0, n1, m1, n2, m2, n3, m3;
  YT_SPACE zz0, zz1, zz2, zz3;

  YT_SPACE x0 = 0, y0 = 0, z0 = 0, x1 = l, y1 = 0, z1 = 0, x2 = 0, y2 = l,
          z2 = 0, x3 = 0, y3 = 0, z3 = l;

  D3_PointToScreen (cam3d, x0, y0, z0, &n0, &m0, &zz0);
  D3_PointToScreen (cam3d, x1, y1, z1, &n1, &m1, &zz1);
  D3_PointToScreen (cam3d, x2, y2, z2, &n2, &m2, &zz2);
  D3_PointToScreen (cam3d, x3, y3, z3, &n3, &m3, &zz3);
  if (!PRINTS)
    return;

  VHandLine (n0, m0, n1, m1, color, zz0 - ZBUFF_eps_reps, zz1 - ZBUFF_eps_reps);
  VHandLine (n0, m0, n2, m2, color, zz0 - ZBUFF_eps_reps, zz2 - ZBUFF_eps_reps);
  VHandLine (n0, m0, n3, m3, color, zz0 - ZBUFF_eps_reps, zz3 - ZBUFF_eps_reps);

  VHandText (n0, m0, "O", color, zz0 - ZBUFF_eps_text);
  VHandText (n1, m1, "X", color, zz1 - ZBUFF_eps_text);
  VHandText (n2, m2, "Y", color, zz2 - ZBUFF_eps_text);
  VHandText (n3, m3, "Z", color, zz3 - ZBUFF_eps_text);

}
/*---------------------------D3_DrawPlines-----------------------------------*/
void
D3_DrawPlines (VT_CAM3D *cam3d, VT_OBJ3D *obj3d)
{
  VT_PLINE3D *p = (VT_PLINE3D *) (obj3d->long1);
  YT_SPACE x1, y1, z1, x2, y2, z2;
  int     i, ii;

  ii = (int) (obj3d->long2);
  for (i = 0; i < ii; i++, p++) {
    x1 = (p->p1)->x;
    y1 = (p->p1)->y;
    z1 = (p->p1)->z;
    x2 = (p->p2)->x;
    y2 = (p->p2)->y;
    z2 = (p->p2)->z;
    D3_DrawLine (cam3d, x1, y1, z1, x2, y2, z2, *(p->c));
  }

  return;
}
/*---------------------------D3_DrawXor--------------------------------------*/
void
D3_DrawXor (VT_W3D *w3d)
{
  VT_SLICEXOR *sx = (VT_SLICEXOR *) ((w3d->xorr)->long1);
  VT_P3D *p0, *p1, *p2, *p3;
  int     n0, m0, n1, m1, n2, m2, n3, m3;
  YT_SPACE zz0, zz1, zz2, zz3;

  p0 = &(sx->v0);
  p1 = &(sx->v1);
  p2 = &(sx->v2);
  p3 = &(sx->v3);

  D3_PointToScreen (w3d->cam3d, p0->x, p0->y, p0->z, &n0, &m0, &zz0);
  D3_PointToScreen (w3d->cam3d, p1->x, p1->y, p1->z, &n1, &m1, &zz1);
  D3_PointToScreen (w3d->cam3d, p2->x, p2->y, p2->z, &n2, &m2, &zz2);
  D3_PointToScreen (w3d->cam3d, p3->x, p3->y, p3->z, &n3, &m3, &zz3);

  YSetXorDraw (TRUE);
  D3_DrawLine (w3d->cam3d, p0->x, p0->y, p0->z, p1->x, p1->y, p1->z, CLR_XOR);
  D3_DrawLine (w3d->cam3d, p0->x, p0->y, p0->z, p2->x, p2->y, p2->z, CLR_XOR);
  D3_DrawLine (w3d->cam3d, p1->x, p1->y, p1->z, p3->x, p3->y, p3->z, CLR_XOR);
  D3_DrawLine (w3d->cam3d, p2->x, p2->y, p2->z, p3->x, p3->y, p3->z, CLR_XOR);

  YDrawString ("O'", n0, m0, YColor("white"));
  YDrawString ("X'", n1, m1, YColor("white"));
  YDrawString ("Y'", n2, m2, YColor("white"));

  YSetXorDraw (FALSE);
  return;
}
/*---------------------------D3_DrawFour-------------------------------------*/
void
D3_DrawFour (VT_CAM3D *cam3d, VT_FOUR *four)
{
  static VT_CPOINT v1, v2, v3, v4;
  static YT_COLOR black;
  static YT_COLOR color;
  VT_PTRI3D t1 = {&v1, &v2, &v3, &color, &black};
  VT_PTRI3D t2 = {&v1, &v3, &v4, &color, &black};

  black = YColor("black");
  v1.x = four->p1.x;
  v1.y = four->p1.y;
  v1.z = four->p1.z;
  v1.color = four->p1.color;

  v2.x = four->p2.x;
  v2.y = four->p2.y;
  v2.z = four->p2.z;
  v2.color = four->p2.color;

  v3.x = four->p3.x;
  v3.y = four->p3.y;
  v3.z = four->p3.z;
  v3.color = four->p3.color;

  v4.x = four->p4.x;
  v4.y = four->p4.y;
  v4.z = four->p4.z;
  v4.color = four->p4.color;
  color = four->color;

  D3_DrawTri (cam3d, &t1);
  D3_DrawTri (cam3d, &t2);

}
/*-------------------------VHandPLineFuncOld--------------------------------*/
YT_BOOL
VHandPLineFuncOld (VT_HANDLINE *line, YT_BOOL flag, int *px1, int *py1,
		   int *px2, int *py2, int align)
{
  int  x, y;

  if (flag == FALSE) {
    VHandLineFunc (line, FALSE, px1, py1, px2, py2);
    line->y_old = -1001;
    return (TRUE);
  }
  while (VHandLineFunc (line, TRUE, &x, &y, NULL, NULL)) {
    if (y != line->y_old) {
      *px1 = x;
      *py1 = y;
      line->y_old = y;
      return (TRUE);
    }
  }

  align++;
  return (FALSE);
}
/*-------------------------VHandPLineFunc-----------------------------------*/
YT_BOOL
VHandPLineFunc (VT_HANDLINE *line, YT_BOOL flag, int *px1, int *py1,
		int *px2, int *py2, int align)
{
  int  x, y;

  if (flag == FALSE) {
    VHandLineFunc (line, FALSE, px1, py1, px2, py2);
    line->begin = TRUE;
    line->end = FALSE;
    line->align = align;
    return (TRUE);
  }
  if (line->end)  return (FALSE);

  while (VHandLineFunc (line, TRUE, &x, &y, NULL, NULL)) {
    if (line->begin) {
      line->x_left = x;
      line->y_old = y;
      line->begin = FALSE;
    }
    if (y != line->y_old) {
      line->x_right = line->x_old;

      *px1 = VHandLineGetX (line);
      *py1 = line->y_old;

      line->y_old = y;
      line->x_old = x;
      line->x_left = x;
      return (TRUE);
    } else
      line->x_old = x;
  }

  line->x_right = line->x_old;
  *px1 = VHandLineGetX (line);
  *py1 = line->y_old;

  line->end = TRUE;
  return (TRUE);
}
/*-------------------------VHandLineGetX------------------------------------*/
int
VHandLineGetX (VT_HANDLINE *line)
{
  int     rab, x;

  if (line->x_left > line->x_right) {
    rab = line->x_left;
    line->x_left = line->x_right;
    line->x_right = rab;
  }
  if      (line->align == YLEFT)   x = line->x_left;
  else if (line->align == YRIGHT)  x = line->x_right;
  else if (line->align == YCENTER) x = (int) ((line->x_left + line->x_right) / 2.0);
  else
    YError ("line->align");

  return (x);
}
/*-----------------------------VHandTriF------------------------------------*/
void
VHandTriF (int x1, int y1, int x2, int y2, int x3, int y3, YT_COLOR fcolor,
	   YT_SPACE z1, YT_SPACE z2, YT_SPACE z3,
	   YT_COLOR c1, YT_COLOR c2, YT_COLOR c3)
{
  typedef struct {
    int     x;
    int     y;
    YT_SPACE z;
    int     s;
  } YT_TYPE;

  YT_TYPE p[4];
  int     xm, ym, sm;
  int     s1, s2, s3;
  YT_SPACE zm, koef;

  s1 = YColorToScale (c1);
  s2 = YColorToScale (c2);
  s3 = YColorToScale (c3);
  if (y1 == y2) {
    VHandHorzTriF (x3, y3, y1, x1, x2, fcolor, z3, z1, z2, s3, s1, s2);
    return;
  }
  if (y1 == y3) {
    VHandHorzTriF (x2, y2, y1, x1, x3, fcolor, z2, z1, z3, s2, s1, s3);
    return;
  }
  if (y2 == y3) {
    VHandHorzTriF (x1, y1, y2, x2, x3, fcolor, z1, z2, z3, s1, s2, s3);
    return;
  }
  p[0].x = p[0].y = 0;
  p[0].z = 0;

  p[1].x = x1;  p[1].y = y1;  p[1].z = z1;  p[1].s = s1;
  p[2].x = x2;  p[2].y = y2;  p[2].z = z2;  p[2].s = s2;
  p[3].x = x3;  p[3].y = y3;  p[3].z = z3;  p[3].s = s3;

  if (p[2].y > p[3].y) {
    p[0].x = p[2].x;  p[0].y = p[2].y;  p[0].z = p[2].z;  p[0].s = p[2].s;
    p[2].x = p[3].x;  p[2].y = p[3].y;  p[2].z = p[3].z;  p[2].s = p[3].s;
    p[3].x = p[0].x;  p[3].y = p[0].y;  p[3].z = p[0].z;  p[3].s = p[0].s;
  }
  if (p[1].y > p[2].y) {
    p[0].x = p[1].x;  p[0].y = p[1].y;  p[0].z = p[1].z;  p[0].s = p[1].s;
    p[1].x = p[2].x;  p[1].y = p[2].y;  p[1].z = p[2].z;  p[1].s = p[2].s;
    p[2].x = p[0].x;  p[2].y = p[0].y;  p[2].z = p[0].z;  p[2].s = p[0].s;
  }
  if (p[2].y > p[3].y) {
    p[0].x = p[2].x;  p[0].y = p[2].y;  p[0].z = p[2].z;  p[0].s = p[2].s;
    p[2].x = p[3].x;  p[2].y = p[3].y;  p[2].z = p[3].z;  p[2].s = p[3].s;
    p[3].x = p[0].x;  p[3].y = p[0].y;  p[3].z = p[0].z;  p[3].s = p[0].s;
  }
  ym = p[2].y;
  koef = YABS ((float) (ym - p[1].y) / (p[3].y - p[1].y));

  xm = (int) (p[1].x + (p[3].x - p[1].x) * koef);
  sm = (int) (p[1].s + (p[3].s - p[1].s) * koef);
  zm = p[1].z + (p[3].z - p[1].z) * koef;

  VHandHorzTriF (p[1].x, p[1].y, ym, p[2].x, xm, fcolor, p[1].z, p[2].z, zm,
		 p[1].s, p[2].s, sm);
  VHandHorzTriF (p[3].x, p[3].y, ym, p[2].x, xm, fcolor, p[3].z, p[2].z, zm,
		 p[3].s, p[2].s, sm);

}
/*-----------------------------VHandHorzTriF--------------------------------*/
void
VHandHorzTriF (int x0, int y0, int y_horz, int x1, int x2, YT_COLOR fcolor,
	       YT_SPACE z0, YT_SPACE z1, YT_SPACE z2,
	       int s0, int s1, int s2)
{
  int     x, y, y1, y2, xleft, xright, dx, dy;
  YT_SPACE zleft, zright, z, dz_left, dz_right, dz_horz, koef;
  VT_HANDLINE line1, line2;
  int     s, ds_left, ds_right;
  float   sleft, sright, ds_horz;
  int     blend = 1;		/*!! */

/* make 1-left, 2-right */
  if (x1 > x2) {
    x  = x2;   z = z2;   s = s2;
    x2 = x1;  z2 = z1;  s2 = s1;
    x1 = x;   z1 = z;   s1 = s;
  }

  dy = y0 - y_horz;
  dz_left  = z0 - z1;
  dz_right = z0 - z2;

  ds_left  = s0 - s1;
  ds_right = s0 - s2;

  VHandPLineFuncOld (&line1, FALSE, &x1, &y_horz, &x0, &y0, YCENTER);
  VHandPLineFuncOld (&line2, FALSE, &x2, &y_horz, &x0, &y0, YCENTER);
  while (VHandPLineFuncOld (&line1, TRUE, &xleft, &y1, NULL, NULL, 0) &&
	 VHandPLineFuncOld (&line2, TRUE, &xright, &y2, NULL, NULL, 0)) {

    if (y1 != y2)  YError ("VHandHorzTriF-y");

    y = y1;
    if (xleft > xright) ; /*!! */ ;
    xleft -= blend;
    xright += blend;

    dx = xright - xleft;
    koef = (float) ((float) y - y_horz) / dy;

    zleft  = z1 + dz_left * koef;
    zright = z2 + dz_right * koef;
    dz_horz = zright - zleft;
    if (V_GURO) {
      sleft  = s1 + ds_left * koef;
      sright = s2 + ds_right * koef;
      ds_horz = sright - sleft;
    }
    for (x = xleft; x <= xright; x++) {
      koef = YABS ((float) (x - xleft) / dx);
      z = zleft + dz_horz * koef;
      if (V_GURO) {
	s = YInt (sleft + ds_horz * koef);
	fcolor = YScale (s);
      }
      VHandPixel (x, y, fcolor, z);
    }

  }

}
/*===============================render2======================================*/
/*                                                                            */
/*-------------------------------mREND2---------------------------------------*/
long
mREND2 (PFUNC_VAR)
{
  typedef struct {
    ABCD;
    void  *cmap;
    void  *meta;
  } YT_USR;

  char   *text[] =
  {
    "Rendering 2D-data as 'CMAP' (colour  ",
    "map) and formation graphic primitives",
    "for a drawing on the screen.",
    NULL
  };
  static int hlegend = 40;

  static YT_BOOL is_1 = FALSE, is_2 = TRUE, is_3 = FALSE;

  static YT_BOOL blegend = FALSE;
  static YT_RECT rect;
  static int y;
  int     okno_w, okno_h, cmap_y, cmap_w, cmap_h;

  switch (message) {
  case YCREATE:
    U_MALLOC;
    WND->name = "Render2";
    /* U->mScreen_id = VMakeScreen (id, 2, 0); */
    U->cmap = NULL;
    U->meta = YMetaCreate (20);
    break;
/*   case MM_FORWARD: */
/*     break; */
  case MM_CMAP_DRAW:
    U->cmap = (void *) PDATA;
    YGoto (YAPPLY, 0, 0, 0, 0);
    break;
  case MM_LEGEND:
    blegend = PDATA;
    break;
  case MM_APPLY:
    YGoto (YAPPLY, 0,0,0, 0);
    break;
  case YAPPLY:
    YGoto (YDRAWITEM, 0, 0, 0, 0);
    break;
  case YDRAWITEM:
    /* YSend (U->mScreen_id, YGETRECT,"", 0, 0, LP(rect)); */
    YSend (SvisRend(2), YGETRECT, 0, 0, LP(rect), 0);
    okno_w = rect.w;
    okno_h = rect.h;
    cmap_y = 0;
    YMetaInit (U->meta, 0, 0, okno_w, okno_h);
    YMetaBegin (U->meta, "");
    if (is_3 || is_2 && blegend) {
      VDrawLegend (0, 0, YMetaW (U->meta), hlegend);
      cmap_y = hlegend - 1;
      okno_h -= hlegend;
    }
    cmap_w = okno_w;
    cmap_h = okno_h;
    YDrawColmapB (U->cmap, 0, cmap_y, cmap_w, cmap_h, YColor ("black"));
    YMetaEnd ();
    /* YMetaDrawTo (U->meta, U->mScreen_id, TRUE, id); */
    YMetaDrawTo (U->meta, SvisRend(2), TRUE, id);
    break;
  case YLMOUSEDOWN:
  case YLMOUSEDRAG:
    y = mes2;
    YGoto (YKEYWORD1, 0, 0, 0, 0);
    break;
  case YLMOUSEUP:
    YGoto (YKEYWORD1, 0, 0, 0, 0);	/*??? */
    break;
  case YKEYWORD1:
    YMetaBegin (U->meta, "XorLine");
    YDrawXorLine (0, y, YMetaW (U->meta), y, YColor("white"));
    YMetaEnd ();
    /* YMetaDrawTo (U->meta, U->mScreen_id, FALSE, id); */
    YMetaDrawTo (U->meta, SvisRend(2), FALSE, id);
    break;
  case YGETSIZE:
    MYSIZE_IS (W_MOD, H_MOD);
    break;
  case YOPEN:
  case YDRAW:
    YDrawRectF (0, 0, WND->w, WND->h, WIN->color);
    YDrawStrings (text, 25, 30);
    YBeginGroup ("Draw palette?", 40,100, 150,100, YColor(""));
    YWndGroupBegin ();
    YWnd (Ph(), CHECK, "Never",    15,15, 20,20, 0,LP(is_1),0,0, CLR_DEF);
    YWnd (Ph(), CHECK, "When need",15,40, 20,20, 0,LP(is_2),0,0, CLR_DEF);
    YWnd (Ph(), CHECK, "Always",   15,65, 20,20, 0,LP(is_3),0,0, CLR_DEF);
    YWndGroupEnd ();
    YEndGroup ();
    break;
  case YCLOSE:
    YWndClean (id);
    break;
  default: ;;;
  }

  RETURN_TRUE;
}
/*=============================latvis=========================================*/
/*                                                                            */
/*------------------------------mColor----------------------------------------*/
long
mColor (PFUNC_VAR)
{
  typedef struct {
    VT_LAT *lat;
    int     hX, hY;
    int     xrel_w, yrel_w, null, sto;
    int     xrel, yrel;
    YT_BOOL blegend;
    int        mdata_save;
  } YT_USR;

  static int x, y, w, h;

  VT_LAT *lat;
  int     x0, y0;
  YT_COLOR color;
  VT_CDAT *cdat = &cdat_glob;

  char   *text[] =
  {
    "Colour maping of data according to", 
    "piece-linear function. Its parameters", 
    "conveniently to change by the left",
    "key of mouse in a field of the diagram.", 
    NULL
  };

  static VT_PARS pars[] = {
    {"int",  "xrel",   "50"},
    {"int",  "yrel",   "50"}, 
    {"bool", "blegend", "TRUE"}, 
    {NULL}};

  switch (message) {
  case YCREATE:
    U_MALLOC;
    WND->name = "Color";
    PAR_INIT ("xrel",    &U->xrel);
    PAR_INIT ("yrel",    &U->yrel);
    PAR_INIT ("blegend", &U->blegend);
    U->lat = NULL;
    U->xrel_w = U->xrel;
    U->yrel_w = U->yrel;
    U->null = 1;
    U->sto  = 99;
    break;
  case MM_LAT3:
  case MM_LAT2:
    U->mdata_save = MDATA;
    U->lat = (VT_LAT *) PDATA;
    YGoto (YMAKE, 0, 0, 0, 0);
    break;
  case MM_APPLY:
    YGoto (YAPPLY, 0,0,0, 0);
    break;

  case YAPPLY:
    if (U->lat == NULL)  
      break;
    if (U->lat->pdata == NULL)  
      break;
    YGoto (YWND2MOD, 0, 0, 0, 0);
    YGoto (YMAKE, 0, 0, 0, 0);
    break;
  case YWND2MOD:
    break;
  case YMAKE:
    lat = U->lat;
    cdat->xrel = U->xrel;
    cdat->yrel = U->yrel;
    cdat_glob.hmin = lat->hmin[lat->dsel];
    cdat_glob.hmax = lat->hmax[lat->dsel];
    YAlgOut (YSEND2FACE, MM_LEGEND,  0, 0, 0, U->blegend);
    YAlgOut (YSEND2FACE, U->mdata_save,  0, 0, 0, (long)lat);
    break;

  case YGETSIZE:
    MYSIZE_IS (W_MOD, H_MOD);
    break;
  case YOPEN:
  case YDRAW:
    x = 25;
    y = 110;
    w = 150;
    h = 100;

    YDrawRectF (0, 0, WND->w, WND->h, WIN->color);
    YDrawStrings (text, 20, 20);

    YBeginGroup ("", 190,110, 120,100, YColor(""));
    YWnd (&(U->hX), DECIMAL, "Xo(%)= ", 60,10, 50,20, 0,U->null,U->sto,LP(U->xrel_w), CLR_DEF);
    YWnd (&(U->hY), DECIMAL, "Yo(%)= ", 60,35, 50,20, 0,U->null,U->sto,LP(U->yrel_w), CLR_DEF);
    YWnd (Ph(), CHECK, "Legend", 20,60, 20,20, 0,LP(U->blegend),0,0, CLR_DEF);
    YEndGroup ();

    YDrawScale (x - 11, y, 10, h, YVERT);
    YDrawString ("Min", x, y + h + 10, YColor("black"));
    YDrawString ("Max", x + w - 30, y + h + 10, YColor("black"));
    YGoto (YDRAWITEM, TRUE, 0, 0, 0);
    break;
  case YDRAWITEM:
    if (mes1)  color = YColor("black");
    else       color = WIN->color;

    x0 = x + U->xrel * w / 100.0;
    y0 = y + h - U->yrel * h / 100.0;
    YDrawLine (x, y + h, x0, y0, color);
    YDrawLine (x0, y0, x + w, y, color);
    YDrawRectF (x0 - 2, y0 - 2, 4, 4, color);
    YDrawRectF (x - 2, y + h - 2, 4, 4, color);
    YDrawRectF (x + w - 2, y - 2, 4, 4, color);
    YDrawRectB (x, y, w, h, YColor("black"));
    break;
/*   case YLMOUSEDOWN: */
/*     OUTS("YLMOUSEDOWN-mColor"); */
/*     break; */
  case YLMOUSEDRAG:
    U->xrel_w = 100.0 * (mes1 - x) / w;
    U->yrel_w = 100.0 * (h - (mes2 - y)) / h;
    if (U->xrel_w < U->null)  U->xrel_w = U->null;
    if (U->yrel_w < U->null)  U->yrel_w = U->null;
    if (U->xrel_w > U->sto)   U->xrel_w = U->sto;
    if (U->yrel_w > U->sto)   U->yrel_w = U->sto;
    YWndUpdate (U->hX);
    YWndUpdate (U->hY);
  /* case YDATAMADE: */
  case YDECIMAL:
    YGoto (YDRAWITEM, FALSE, 0, 0, 0);
    U->xrel = U->xrel_w;
    U->yrel = U->yrel_w;
    YGoto (YDRAWITEM, TRUE, 0, 0, 0);
    break;
  case YCLOSE:
    YWndClean (id);
    break;
  default:
   if (MM_FORWARD)  YAlgOut (YSEND2FACE, message, mes1, mes2, mes3, mes4);
  }

  color++;
  RETURN_TRUE;
}
/*-----------------------------mScale---------------------------------------*/
long
mScale (PFUNC_VAR)
{
  typedef struct {
    VT_LAT *lat_old, *lat;
    YT_BOOL scale_isit;
    float   scale_x, scale_y, scale_z;
    int     hScaleX, hScaleY, hScaleZ;
    int       mdata_save;
    /* AT_TDATA  tdata_save; */
  } YT_USR;

  int     i, j, k;
  YT_SPACE x, y, z;
  char   *text[] = {
    "This module is busy in scaling on axes",
    "X, Y, Z, i.e. multiplication of  ",
    "coordinates to appropriate factor.", 
    NULL};

  static VT_PARS pars[] = {
    {"bool",  "scale_isit", "FALSE"}, 
    {"float", "scale_x",    "1.0  "}, 
    {"float", "scale_y",    "1.0  "},   
    {"float", "scale_z",    "1.0  "},  
    {NULL}
  };

  switch (message) {
  case YCREATE:
    U_MALLOC;
    WND->name = "Scale";
    if (!(VLAT (&(U->lat), 0, YCONSTR1, 0, 0, 0, 0)))
      YError ("...");
/*     YAlgParam (&pars[0], "scale_isit", &U->scale_isit, NULL); */
/*     YAlgParam (&pars[0], "scale_x",    &U->scale_x, NULL); */
/*     YAlgParam (&pars[0], "scale_y",    &U->scale_y, NULL); */
/*     YAlgParam (&pars[0], "scale_z",    &U->scale_z, NULL); */
    PAR_INIT ("scale_isit", &U->scale_isit);
    PAR_INIT ("scale_x",    &U->scale_x);
    PAR_INIT ("scale_y",    &U->scale_y);
    PAR_INIT ("scale_z",    &U->scale_z);
    break;
  case MM_LAT3:
  case MM_LAT2:
    U->mdata_save = MDATA;
    U->lat_old = (VT_LAT *) PDATA;
    YGoto (YMAKE, 0, 0, 0, 0);
    YAlgOut (YSEND2FACE, U->mdata_save,  0, 0, 0, (long)(U->lat));
    break;

  case MM_APPLY:
    YGoto (YAPPLY, 0,0,0, 0);
    break;
  case YAPPLY:
    if ((U->lat)->pdata == NULL)  
      break;
    YGoto (YWND2MOD, 0, 0, 0, 0);
    YMouseForm ("wait");
    YGoto (YMAKE, 0, 0, 0, 0);
    YMouseForm ("arrow");
    YAlgOut (YSEND2FACE, U->mdata_save,  0, 0, 0, (long)(U->lat));
    break;
  case YWND2MOD:
    YGetData (U->hScaleX);
    YGetData (U->hScaleY);
    YGetData (U->hScaleZ);
    break;
  case YMAKE:
    *(U->lat) = *(U->lat_old);
    if (!U->scale_isit)  
      break;

    if (!(VLAT (U->lat, 0, YCONSTR2, (U->lat)->ii, (U->lat)->jj, (U->lat)->kk, 0)))
      YError ("...");
    for (i = 1; i <= (U->lat)->ii; i++) 
    for (j = 1; j <= (U->lat)->jj; j++) 
    for (k = 1; k <= (U->lat)->kk; k++) {
      VLAT (U->lat_old, LP(x), YGETDATA, i, j, k, 1);
      VLAT (U->lat_old, LP(y), YGETDATA, i, j, k, 2);
      VLAT (U->lat_old, LP(z), YGETDATA, i, j, k, 3);
      x = x * U->scale_x;
      y = y * U->scale_y;
      z = z * U->scale_z;
      VLAT (U->lat, LP(x), YPUTDATA, i, j, k, 1);
      VLAT (U->lat, LP(y), YPUTDATA, i, j, k, 2);
      VLAT (U->lat, LP(z), YPUTDATA, i, j, k, 3);
    }
    break;
/*   default:;;; */
/*   } */

/*   switch (message) { */
  case YGETSIZE:
    MYSIZE_IS (W_MOD, H_MOD);
    break;
  case YOPEN:
  case YDRAW:
    YDrawRectF (0, 0, WND->w, WND->h, WIN->color);
    YDrawStrings (text, 20, 20);
    YBeginGroup ("", 40,90, 210,130, YColor(""));
    YWnd (Ph(), CHECK, "Do this?", 20,10, 20,20, 0,LP(U->scale_isit),0,0, CLR_DEF);
    YWnd (&U->hScaleX, FLOATS, "For axe X: ", 100,35, 50,20, LP(U->scale_x),YFLOAT,0,0, CLR_DEF);
    YWnd (&U->hScaleY, FLOATS, "For axe Y: ", 100,60, 50,20, LP(U->scale_y),YFLOAT,0,0, CLR_DEF);
    YWnd (&U->hScaleZ, FLOATS, "For axe Z: ", 100,85, 50,20, LP(U->scale_z),YFLOAT,0,0, CLR_DEF);
    YEndGroup ();
    break;
  case YCLOSE:
    YWndClean (id);
    break;
  default:
    if (MM_FORWARD)  YAlgOut (YSEND2FACE, message,  mes1, mes2, mes3, mes4);
  }

  RETURN_TRUE;
}
/*------------------------------mData---------------------------------------*/
long
mData (PFUNC_VAR)
{
  typedef struct {
    VT_LAT *lat;
    /* int     forw_mes; */
    /* char     *forw_mes_phrase; */
   /*  AT_TDATA  tdata_save; */
    int       mdata_save;
    int     dsel, hList;
    char  **lst;
  } YT_USR;

  char   *text[] =
  {
    "The module allows to fix the channel",
    "data  i.e. to choose just those data",
    "with which then any actions will be",  
    "made.   Choose the necessary name",
    "from the list:", 
    NULL
  };

  switch (message) {
  case YCREATE:
    U_MALLOC;
    WND->name = "Data";
    U->dsel = 1;
    U->lst = Y_NONENAMES;
    break;
/*   case MM_FORWARD: */
/*     break; */
  case MM_LAT3:
  case MM_LAT2:
    U->mdata_save = MDATA;
    U->lat = (VT_LAT *) PDATA;
    YGoto (YMAKE, 0, 0, 0, 0);
    YAlgOut (YSEND2FACE, U->mdata_save,  0, 0, 0, (long)(U->lat));
    break;
  case MM_APPLY:
    YGoto (YAPPLY, 0, 0, 0, 0);
    break;
  case YAPPLY:
    if ((U->lat)->pdata == NULL)  
      break;
    YGoto (YWND2MOD, 0, 0, 0, 0);
    YGoto (YMAKE, 0, 0, 0, 0);
    YAlgOut (YSEND2FACE, U->mdata_save,  0, 0, 0, (long)(U->lat));
    break;
  case YWND2MOD:
    U->dsel = (int) YGetData (U->hList);
    break;
  case YMAKE:
    U->lst = (U->lat)->data_names;
/* OUTD(U->dsel); */
    U->dsel = YMIN (U->dsel, (U->lat)->dd);
/* OUTD(U->dsel); */
    (U->lat)->dsel = U->dsel;
    YMouseForm ("wait");
    VLAT (U->lat, 0, YMAKE, 0, 0, 0, 0);
    YMouseForm ("arrow");
    break;
/*   default:;;; */
/*   } */

/*   switch (message) { */
  case YGETSIZE:
    MYSIZE_IS (W_MOD, H_MOD);
    break;
  case YOPEN:
  case YDRAW:
    YDrawRectF (0, 0, WND->w, WND->h, WIN->color);
    YDrawStrings (text, 20, 20);
    YWnd (&(U->hList), LIST, "", 80,120, 150,100, (long)(U->lst),0,LP(U->dsel),0, CLR_DEF);
    break;
  case YCLOSE:
    YGoto (YWND2MOD, 0, 0, 0, 0);
    YWndClean (id);
    break;
  default:
    if (MM_FORWARD)  YAlgOut (YSEND2FACE, message,  mes1, mes2, mes3, mes4);
  }

  RETURN_TRUE;
}
/*-----------------------------mSlice---------------------------------------*/
long
mSlice (PFUNC_VAR)
{
  typedef struct {
    ABCD;
  } YT_USR;

  static YT_BOOL islice, jslice, kslice;
  static int i, j, k, ii, jj, kk;
  static VT_LAT *lat3, *lat2;
  static int one = 1;
  static char ii_str[30], jj_str[30], kk_str[30];
  static int h_i, h_j, h_k, h_islice, h_jslice, h_kslice;
  static int d, *pd, dmax, dinc;
  static VT_OBJ3D obj;
  int     y1 = 10, y2 = 35, y3 = 60;
  char   *text[] = {
    "This module lowers (3-> 2) dimensions",
    "in space of parameters latice data, ",
    "i.e. makes slice:", 
    NULL};

  static VT_PARS pars[] = {
    {"bool", "islice", "TRUE"}, 
    {"bool", "jslice", "FALSE"},
    {"bool", "kslice", "FALSE"}, 
    {NULL}
  };

  switch (message) {
  case YCREATE:
    U_MALLOC;
    WND->name = "Slice32";
    i = 1;  ii = 999;
    j = 1;  jj = 999;
    k = 1;  kk = 999;
    /* YAlgParam (&pars[0], "islice", &islice, NULL); */
    /* YAlgParam (&pars[0], "jslice", &jslice, NULL); */
    /* YAlgParam (&pars[0], "kslice", &kslice, NULL); */
    PAR_INIT ("islice", &islice);
    PAR_INIT ("jslice", &jslice);
    PAR_INIT ("kslice", &kslice);
    h_i = h_j = h_k = h_islice = h_jslice = h_kslice = ID_NULL;
    break;
  case YAPPLY:
    VLAT (lat3, 0, YBEGIN, islice ? i : 0, jslice ? j : 0, kslice ? k : 0, 0);
    lat2 = VLat2From3 (lat3);
    VLatToSlice3 (lat3, &obj);
    VLAT (lat3, 0, YEND, 0, 0, 0, 0);

    YAlgOut (YPOST2FACE, MM_LAT2,       0, 0, 0, (long)lat2);
    YAlgOut (YSEND2FACE, MM_OBJ3D_XOR,  0, 0, 0, LP(obj));
    break;
    /*   case MM_FORWARD: */
    /*     break; */
  case MM_LAT3:
    lat3 = (VT_LAT *) PDATA;
    ii = lat3->ii;
    jj = lat3->jj;
    kk = lat3->kk;
    YGoto (YAPPLY, 0, 0, 0, 0);
    break;
  case MM_APPLY:
    YGoto (YAPPLY, 0,0,0, 0);
    break;
  case MM_STRING:
    {
      char   *s = (char *) PDATA;
      if (strcmp (s, "/+") == 0 || strcmp (s, "/-") == 0) {
	if      (islice)  {pd = &(i); dmax = ii;} 
	else if (jslice)  {pd = &(j); dmax = jj;} 
	else if (kslice)  {pd = &(k); dmax = kk;}

	if (strcmp (s, "/+") == 0)  dinc = +1;
	else                        dinc = -1;
	d = *pd;
	d += dinc;
	if (d > dmax)  d = 1;
	if (d < 1)     d = dmax;
	*pd = d;
      } else if (strcmp (s, "/>") == 0) {
	if      (islice)  {islice = FALSE; jslice = TRUE;} 
	else if (jslice)  {jslice = FALSE; kslice = TRUE;} 
	else if (kslice)  {kslice = FALSE; islice = TRUE;}
      }

      YGoto (YMOD2WND, 0, 0, 0, 0);
      YAlgGo (id);
    }
    break;

  case YMOD2WND:
    YWndUpdate (h_i);
    YWndUpdate (h_islice);
    YWndUpdate (h_j);
    YWndUpdate (h_jslice);
    YWndUpdate (h_k);
    YWndUpdate (h_kslice);
    break;

  case YGETSIZE:   /*!!!!!!!!!!!!!!!!!*/
    MYSIZE_IS (W_MOD, H_MOD);
    break;
  case YOPEN:
    sprintf (ii_str, "Index I: (1..%d) ", ii);
    sprintf (jj_str, "Index J: (1..%d) ", jj);
    sprintf (kk_str, "Index K: (1..%d) ", kk);
  case YDRAW:
    YDrawRectF (0, 0, WND->w, WND->h, WIN->color);
    YDrawStrings (text, 20, 30);

    YBeginGroup ("Fix it:", 30,100, 245,90, YColor(""));
    YWnd (&h_i, DECIMAL, ii_str, 150,y1, 50,20, 0,one,ii,LP(i), CLR_DEF);
    YWnd (&h_j, DECIMAL, jj_str, 150,y2, 50,20, 0,one,jj,LP(j), CLR_DEF);
    YWnd (&h_k, DECIMAL, kk_str, 150,y3, 50,20, 0,one,kk,LP(k), CLR_DEF);
    YWndGroupBegin ();
      YWnd (&h_islice, CHECK, "", 210,y1, 20,20, 0,LP(islice),0,0, CLR_DEF);
      YWnd (&h_jslice, CHECK, "", 210,y2, 20,20, 0,LP(jslice),0,0, CLR_DEF);
      YWnd (&h_kslice, CHECK, "", 210,y3, 20,20, 0,LP(kslice),0,0, CLR_DEF);
    YWndGroupEnd ();
    YEndGroup ();
    break;
  case YCLOSE:
    YWndClean (id);
    break;
  default:
    if  (MM_FORWARD)  YAlgOut (YSEND2FACE, message,  mes1, mes2, mes3, mes4);
  }

  RETURN_TRUE;
}
/*------------------------------VLat2From3----------------------------------*/
VT_LAT *
VLat2From3 (VT_LAT *lat3)
{

  static VT_LAT *lat = NULL;
  int     i, j, ii, jj;
  YT_SPACE x, y, z, d, l;
  static YT_SPACE x_left, y_left, z_left, x_old, y_old, z_old, xi, yi = 0;

  if (!lat3->srez)  YError ("VLat2From3");

  VLAT (lat3, 0, YSIZE, LP(ii), LP(jj), 0, 0);
  VLAT (&lat, 2, YCONSTR0, ii, jj, 0, 1);

  for (i = 1; i <= ii; i++) 
  for (j = 1; j <= jj; j++) {
    VLAT (lat3, LP(d), YGETDATA, i, j, 0, 0);
    VLAT (lat3, LP(x), YGETDATA, i, j, 0, 1);
    VLAT (lat3, LP(y), YGETDATA, i, j, 0, 2);
    VLAT (lat3, LP(z), YGETDATA, i, j, 0, 3);
    /* fprintf(Y_STDERR,"%f %f %f \n",x,y,z);    */
    
    if (i == 1 && j == 1) {
      x_left = x_old = x;
      y_left = y_old = y;
      z_left = z_old = z;
    }
    if (j == 1) {
      xi = 0;
      l = sqrt ((x - x_left) * (x - x_left) + (y - y_left) * (y - y_left) + 
		(z - z_left) * (z - z_left));
      yi = yi + l;
      x_left = x;
      y_left = y;
      z_left = z;
    } else {
      l = sqrt ((x - x_old) * (x - x_old) + (y - y_old) * (y - y_old) + 
		(z - z_old) * (z - z_old));
      xi = xi + l;
    }
    
    VLAT (lat, LP(xi), YPUTDATA, i, j, 1, 1);
    VLAT (lat, LP(yi), YPUTDATA, i, j, 1, 2);
    VLAT (lat, LP(d),  YPUTDATA, i, j, 1, 0);
    
    x_old = x;
    y_old = y;
    z_old = z;
  }

  return (lat);
}
/*------------------------------VLat1From2----------------------------------*/
VT_LAT *
VLat1From2 (VT_LAT *lat2)
{
  VT_LAT *lat1 = NULL;
  int     i, ii;
  YT_SPACE x, y, d, l;
  YT_SPACE x_old, y_old, xi;

  if (!lat2->srez)  YError ("");

  VLAT (lat2, 0, YSIZE, LP(ii), YNULL, 0, 0);

  VLAT (&lat1, 1, YCONSTR0, ii, 0, 0, 1);
  VLAT (lat1, 0, YNAMES, 0, 0, 0, (long)lat2->data_names);

  xi = 0;
  for (i = 1; i <= ii; i++) {
    VLAT (lat2, LP(d), YGETDATA, i, 0, 0, 0);
    VLAT (lat2, LP(x), YGETDATA, i, 0, 0, 1);
    VLAT (lat2, LP(y), YGETDATA, i, 0, 0, 2);

    if (i == 1) {
      x_old = x;
      y_old = y;
    }
    l = sqrt ((x - x_old) * (x - x_old) + (y - y_old) * (y - y_old));
    xi = xi + l;

    VLAT (lat1, LP(xi), YPUTDATA, i, 1, 1, 1);
    VLAT (lat1, LP(d), YPUTDATA, i, 1, 1, 0);

    x_old = x;
    y_old = y;
  }

  return (lat1);
}
/*----------------------------VLatToSlice3----------------------------------*/
void
VLatToSlice3 (VT_LAT *lat3, void *xor_obj)
{
  static VT_SLICEXOR sxor;
  int     ii, jj;

  if (!lat3->srez)  YError ("VLatToSlice3");

  if (!lat3->islice && !lat3->jslice && !lat3->kslice)
    return;

  VLAT (lat3, 0, YSIZE, LP(ii), LP(jj), 0, 0);

  VLAT (lat3, LP(sxor.v0.x), YGETDATA, 1, 1, 0, 1);
  VLAT (lat3, LP(sxor.v0.y), YGETDATA, 1, 1, 0, 2);
  VLAT (lat3, LP(sxor.v0.z), YGETDATA, 1, 1, 0, 3);

  VLAT (lat3, LP(sxor.v1.x), YGETDATA, ii, 1, 0, 1);
  VLAT (lat3, LP(sxor.v1.y), YGETDATA, ii, 1, 0, 2);
  VLAT (lat3, LP(sxor.v1.z), YGETDATA, ii, 1, 0, 3);

  VLAT (lat3, LP(sxor.v2.x), YGETDATA, 1, jj, 0, 1);
  VLAT (lat3, LP(sxor.v2.y), YGETDATA, 1, jj, 0, 2);
  VLAT (lat3, LP(sxor.v2.z), YGETDATA, 1, jj, 0, 3);

  VLAT (lat3, LP(sxor.v3.x), YGETDATA, ii, jj, 0, 1);
  VLAT (lat3, LP(sxor.v3.y), YGETDATA, ii, jj, 0, 2);
  VLAT (lat3, LP(sxor.v3.z), YGETDATA, ii, jj, 0, 3);

  V3ObjInit ((VT_OBJ3D *) xor_obj, "YXOR", /* YXOR,  */"", NULL, LP(sxor), 0, 0, 0);

  return;
}
/*-----------------------------mSlines--------------------------------------*/
long
mSlines (PFUNC_VAR)
{
  typedef struct {
    ABCD;
  } YT_USR;

  static YT_BOOL islice, jslice;
  static int i, j, ii, jj;
  static VT_LAT *lat1, *lat2;
  static int one = 1;
  static char ii_str[30], jj_str[30];
  static int h_i, h_j, h_islice, h_jslice;
  int     y1 = 10, y2 = 35;

  char   *text[] = {
    "This module lowers (2->1) dimensions",
    "in space of parameters latice data,",
    "i.e. makes slice:", 
    NULL};
  static VT_PARS pars[] = {
    {"bool", "islice", "TRUE"},  
    {"bool", "jslice", "FALSE"}, 
    {NULL}
  };

  switch (message) {
  case YCREATE:
    U_MALLOC;
    WND->name = "Slice21";
    i = 1; ii = 999;
    j = 1; jj = 999;
/*     YAlgParam (&pars[0], "islice", &islice, NULL); */
/*     YAlgParam (&pars[0], "jslice", &jslice, NULL); */
    PAR_INIT ("islice", &islice);
    PAR_INIT ("jslice", &jslice);
    h_i = h_j = h_islice = h_jslice == ID_NULL;
    break;
/*   case MM_FORWARD: */
/*     break; */
  case MM_LAT2:
    lat2 = (VT_LAT *) PDATA;
    ii = lat2->ii;
    jj = lat2->jj;
    YGoto (YAPPLY, 0, 0, 0, 0);
    break;
  case MM_APPLY:
    YGoto (YAPPLY, 0, 0, 0, 0);
    break;
  case YAPPLY:
    VLAT (lat2, 0, YBEGIN, islice ? i : 0, jslice ? j : 0, 0, 0);
    lat1 = VLat1From2 (lat2);
    VLAT (lat2, 0, YEND, 0, 0, 0, 0);

    YAlgOut (YPOST2FACE, MM_LAT1,  0, 0, 0, (long)lat1);
    break;

  case YGETSIZE:
    MYSIZE_IS (W_MOD, H_MOD);
    break;
  case YOPEN:
    sprintf (ii_str, "Index I: (1..%d) ", ii);
    sprintf (jj_str, "Index J: (1..%d) ", jj);
  case YDRAW:
    YDrawRectF (0, 0, WND->w, WND->h, WIN->color);
    YDrawStrings (text, 20, 30);

    YBeginGroup ("Fix it:", 30,100, 245,80, YColor(""));
    YWnd (&h_i, DECIMAL, ii_str, 150,y1, 50,20, 0,one,ii,LP(i), CLR_DEF);
    YWnd (&h_j, DECIMAL, jj_str, 150,y2, 50,20, 0,one,jj,LP(j), CLR_DEF);
    YWndGroupBegin ();
      YWnd (&h_islice, CHECK, "", 210,y1, 20,20, 0,LP(islice),0,0, CLR_DEF);
      YWnd (&h_jslice, CHECK, "", 210,y2, 20,20, 0,LP(jslice),0,0, CLR_DEF);
    YWndGroupEnd ();
    YEndGroup ();
    break;
  case YCLOSE:
    YWndClean (id);
    break;
  default:
    if (MM_FORWARD)  YAlgOut (YSEND2FACE, message,  mes1, mes2, mes3, mes4);
  }

  RETURN_TRUE;
}
/*-----------------------------mBody----------------------------------------*/
long
mBody (PFUNC_VAR)
{
  typedef struct {
    ABCD;
  } YT_USR;

  static VT_TELO *telo = NULL;
  static VT_LAT *lat = NULL;
  static VT_OBJ3D obj, sur;
  /* static int null = 1; */
  static int hSurf;
  static YT_SPACE surf;
  int     y1, y2, y3;
  static int  ii, jj, kk;
  char   *text[] =
  {
    "Specify which you want to see 3D-latice:", 
    "It's possible to look two slices in each",
    "direction, and also all points (lines):",  
    NULL
  };

  switch (message) {
  case YCREATE:
    U_MALLOC;
    WND->name = "Body";
    telo = V3TeloCreate ();
    V3TeloInit (telo, lat);
    ii = jj = kk = 999;
    break;
/*   case MM_FORWARD: */
/*     break; */
  case MM_LAT3:
    lat = (VT_LAT *) PDATA;
    YMouseForm ("wait");
    VLatMakeCats (lat);
    V3TeloInit (telo, lat);
    
    telo->i1 = telo->j1 = telo->k1 = 1; 
    telo->i2 = ii = lat->ii;
    telo->j2 = jj = lat->jj;
    telo->k2 = kk = lat->kk;
    
    YGoto (YKEYWORD1, 0, 0, 0, 0);
    YMouseForm ("arrow");
    break;
  case MM_NONE:
    obj.existed = FALSE;
    sur.existed = FALSE;
    break;
  case MM_APPLY:
    YGoto (YAPPLY, 0, 0, 0, 0);
    break;
  case YAPPLY:
    YSend (hSurf, YGETDATA, 0, 0, 0, 0);
  case YKEYWORD1:
    V3ObjInit (&(obj), "VTELO3D", /* VTELO3D,  */"", NULL, 0, (long)telo, 0, 0);
    YAlgOut (YSEND2FACE, MM_OBJ3D_ADD,  0, 0, 0, LP(obj));

    if (telo->full_isosurf) {
      VMaping (&cdat_glob, &surf, &telo->full_isurf, TRUE);
      V3TeloMakeIsosurf (telo, &sur);
      YAlgOut (YSEND2FACE, MM_OBJ3D_ADD,  0, 0, 0, LP(sur));
    } else
      sur.existed = FALSE;
    break;
/*   default:;;; */
/*   } */

/*   switch (message) { */
  case YGETSIZE:
    MYSIZE_IS (W_MOD, H_MOD);
    break;
  case YOPEN:
  case YDRAW:
    YDrawRectF (0, 0, WND->w, WND->h, WIN->color);
    YDrawStrings (text, 10, 20);

    YBeginGroup ("Full body", 5,90, 110,135, YColor(""));
    YWnd (Ph(), CHECK, "IJK-box", 10,10, 20,20, 0,LP(telo->ijk_box),0,0, CLR_DEF);
    YWndGroupBegin ();
      YWnd (Ph(), CHECK, "Points", 10,35, 20,20, 0,LP(telo->full_points),0,0, CLR_DEF);
      YWnd (Ph(), CHECK, "Lines",  10,60, 20,20, 0,LP(telo->full_lines),0,0, CLR_DEF);
    YWndGroupEnd ();
    YWnd (Ph(), CHECK, "Isosurf", 10,85, 20,20, 0,LP(telo->full_isosurf),0,0, CLR_DEF);
    YWnd (&hSurf, FLOATS, "", 10,110, 70,20, LP(surf),YSPACE,0,0, CLR_DEF);
    YEndGroup ();

    YBeginGroup ("Slices IJK", 120,90, 195,110, YColor(""));
    y1 = 32;
    y2 = y1 + 25;
    y3 = y2 + 25;
    YDrawString ("First:", 30, y1 - 12, YColor("black"));
    YDrawString ("Second:", 115, y1 - 12, YColor("black"));

    YWnd (Ph(), DECIMAL, "I: ", 30,y1, 35,20, 0,1,/* lat->ii */ii,LP(telo->i1), CLR_DEF);
    YWnd (Ph(), DECIMAL, "J: ", 30,y2, 35,20, 0,1,/* lat->jj */jj,LP(telo->j1), CLR_DEF);
    YWnd (Ph(), DECIMAL, "K: ", 30,y3, 35,20, 0,1,/* lat->kk */kk,LP(telo->k1), CLR_DEF);

    YWnd (Ph(), CHECK, "", 65,y1, 20,20, 0,LP(telo->i1_polys),0,0, CLR_DEF);
    YWnd (Ph(), CHECK, "", 65,y2, 20,20, 0,LP(telo->j1_polys),0,0, CLR_DEF);
    YWnd (Ph(), CHECK, "", 65,y3, 20,20, 0,LP(telo->k1_polys),0,0, CLR_DEF);
    YWnd (Ph(), CHECK, "", 85,y1, 20,20, 0,LP(telo->i1_lines),0,0, CLR_DEF);
    YWnd (Ph(), CHECK, "", 85,y2, 20,20, 0,LP(telo->j1_lines),0,0, CLR_DEF);
    YWnd (Ph(), CHECK, "", 85,y3, 20,20, 0,LP(telo->k1_lines),0,0, CLR_DEF);

    YWnd (Ph(), DECIMAL, "", 115,y1, 35,20, 0,1,/* lat->ii */ii,LP(telo->i2), CLR_DEF);
    YWnd (Ph(), DECIMAL, "", 115,y2, 35,20, 0,1,/* lat->jj */jj,LP(telo->j2), CLR_DEF);
    YWnd (Ph(), DECIMAL, "", 115,y3, 35,20, 0,1,/* lat->kk */kk,LP(telo->k2), CLR_DEF);

    YWnd (Ph(), CHECK, "", 150,y1, 20,20, 0,LP(telo->i2_polys),0,0, CLR_DEF);
    YWnd (Ph(), CHECK, "", 150,y2, 20,20, 0,LP(telo->j2_polys),0,0, CLR_DEF);
    YWnd (Ph(), CHECK, "", 150,y3, 20,20, 0,LP(telo->k2_polys),0,0, CLR_DEF);
    YWnd (Ph(), CHECK, "", 170,y1, 20,20, 0,LP(telo->i2_lines),0,0, CLR_DEF);
    YWnd (Ph(), CHECK, "", 170,y2, 20,20, 0,LP(telo->j2_lines),0,0, CLR_DEF);
    YWnd (Ph(), CHECK, "", 170,y3, 20,20, 0,LP(telo->k2_lines),0,0, CLR_DEF);
    YEndGroup ();
    break;
  case YCLOSE:
    YWndClean (id);
    break;
  default:
    if (MM_FORWARD)  YAlgOut (YSEND2FACE, message,  mes1, mes2, mes3, mes4);
  }

  RETURN_TRUE;
#undef cat
}
/*-------------------------------VMaping------------------------------------*/
void
VMaping (VT_CDAT *c, YT_SPACE *px, int *py, YT_BOOL direct)
{
  YT_SPACE x0, x;
  int     y0, y;
  YT_SPACE hmin = c->hmin, hmax = c->hmax;

  /* if (hmax == hmin)  return;  */

  x0 = hmin + (hmax - hmin) * c->xrel / 100.0;
  y0 = 1 + (YGet("size_scale") - 1) * c->yrel / 100.0;

  if (direct) {         
    x = *px;
    if (x < x0)  y = YInt (YLINER (x, hmin, 1, x0, y0));
    else         y = YInt (YLINER (x, x0, y0, hmax, YGet("size_scale")));
    *py = y;
  } else {
    y = *py;
    if (y < y0)  x = YLINER (y, 1, hmin, y0, x0);
    else         x = YLINER (y, y0, x0, YGet("size_scale"), hmax); /* if (hmax == hmin) ???*/
    *px = x;
  }

  return;
}
/*-----------------------------VLatMakeCats---------------------------------*/
YT_BOOL
VLatMakeCats (VT_LAT *lat)
{
  YT_SPACE h;
  YT_COLOR color;
  int     cellh;
  int     i, j, k;
  int     ii = lat->ii, jj = lat->jj, kk = lat->kk;

  if (!(VLAT (lat, 0, YCONSTR4, 0, 0, 0, 0))) {
    YMessageBox ("Not memory for Cats!", "OK");
    return (FALSE);
  }

  for (i = 1; i <= ii; i++) 
  for (j = 1; j <= jj; j++) 
  for (k = 1; k <= kk; k++) {
    VLAT (lat, LP(h), YGETDATA, i, j, k, 0);
    VMaping (&cdat_glob, &h, &cellh, TRUE);
    
    color = YScale (cellh - 1);
    VLAT (lat, LP(color), YPUTDATA, i, j, k, -1);
  }

  return (TRUE);
}
/*-----------------------------mL_C-----------------------------------------*/
long
mL_C (PFUNC_VAR)
{
  typedef struct {
    ABCD;
  } YT_USR;

  static VT_LAT *lat2;
  static void *cmap;
  char   *text[] =
  {
    "The module makes translation of data of",
    "one type to other ('LAT2'->'CMAP').", 
    "The parameters while are not present.", 
    NULL
  };

  switch (message) {
  case YCREATE:
    U_MALLOC;
    WND->name = "L_C";
    break;
/*   case MM_FORWARD: */
/*     break; */
  case MM_LAT2:
    lat2 = (VT_LAT *) PDATA;
    cmap = VLatCmapFrom2 (lat2);
    YAlgOut (YSEND2FACE, MM_CMAP_DRAW,  0, 0, 0, (long)(cmap));
    break;
  case YGETSIZE:
    MYSIZE_IS (W_MOD, H_MOD);
    break;
  case YOPEN:
  case YDRAW:
    YDrawRectF (0, 0, WND->w, WND->h, WIN->color);
    YDrawStrings (text, 10, 40);
    YDrawLogo ("Ylib_sv",70, 100, 140, 100);
    break;
  case YCLOSE:
    YWndClean (id);
    break;
  default:
    if (MM_FORWARD)  YAlgOut (YSEND2FACE, message,  mes1, mes2, mes3, mes4);
  }

  RETURN_TRUE;
}
/*-----------------------------VLatCmapFrom2--------------------------------*/
void   *
VLatCmapFrom2 (VT_LAT *lat2)
{
  YT_SPACE h;
  int     cellh, i, j, ii, jj;
  VT_CDAT *cdat = &cdat_glob;
  static void *cmap;

  ii = lat2->ii;
  jj = lat2->jj;

  cmap = YColmapCreate ();
  YColmapInit (cmap, ii, jj);

  for (i = 0; i < ii; i++)
  for (j = 0; j < jj; j++) {
    VLAT (lat2, LP(h), YGETDATA, i + 1, j + 1, 1, 0);
    VMaping (cdat, &h, &cellh, TRUE);
    YColmapPut (cmap, i, j, YScale (cellh - 1));
  }

  return (cmap);
}
/*--------------------------VLatCreateVOL-----------------------------------*/
YT_BOOL
VLatCreateVOL (VT_VOL3D *vol3d, int ii, int dd)
{
  static YT_SPACE *p;

  if (YOVERFLOW (ii * (3 + dd) * sizeof (YT_SPACE))) {
    YMessageBox ("Overflow: npoints", "OK");
    return (FALSE);
  }
  if (p) {
    free ((void *) p);
    p = NULL;
  }
  if (!(p = (YT_SPACE *) malloc (ii * (3 + dd) * sizeof (YT_SPACE)))) {
    YMessageBox ("Not memory for vol3d!", "OK");
    return (FALSE);
  }
  vol3d->p = p;
  vol3d->ii = ii;
  vol3d->dd = dd;

  return (TRUE);
}
/*----------------------------D3_DrawTeloIJKBox------------------------------*/
void
D3_DrawTeloIJKBox (VT_CAM3D *cam3d, VT_TELO *telo)
{
  int     ii, jj, kk;
  VT_LAT *lat = telo->lat;

  ii = lat->ii;
  jj = lat->jj;
  kk = lat->kk;

  D3_DrawTeloEdge (cam3d, telo, 0, 1, 1);
  D3_DrawTeloEdge (cam3d, telo, 0, jj, 1);
  D3_DrawTeloEdge (cam3d, telo, 0, 1, kk);
  D3_DrawTeloEdge (cam3d, telo, 0, jj, kk);

  D3_DrawTeloEdge (cam3d, telo, 1, 0, 1);
  D3_DrawTeloEdge (cam3d, telo, ii, 0, 1);
  D3_DrawTeloEdge (cam3d, telo, 1, 0, kk);
  D3_DrawTeloEdge (cam3d, telo, ii, 0, kk);

  D3_DrawTeloEdge (cam3d, telo, 1, 1, 0);
  D3_DrawTeloEdge (cam3d, telo, ii, 1, 0);
  D3_DrawTeloEdge (cam3d, telo, 1, jj, 0);
  D3_DrawTeloEdge (cam3d, telo, ii, jj, 0);

}
/*----------------------------D3_DrawTeloEdge--------------------------------*/
void
D3_DrawTeloEdge (VT_CAM3D *cam3d, VT_TELO *telo, int ifix, int jfix, int kfix)
{
  int     l, ll;
  VT_CPOINT p1, p2;
  YT_COLOR color = YColor("black");
  VT_LAT *lat = telo->lat;

  if (ifix == 0) {
    ll = lat->ii;
    for (l = 1; l < ll; l++) {
      VLAT (lat, LP(p1), YGETPOINT, l, jfix, kfix, 0);
      VLAT (lat, LP(p2), YGETPOINT, l + 1, jfix, kfix, 0);
      D3_DrawLine (cam3d, p1.x, p1.y, p1.z, p2.x, p2.y, p2.z, color);
    }
  } else if (jfix == 0) {
    ll = lat->jj;
    for (l = 1; l < ll; l++) {
      VLAT (lat, LP(p1), YGETPOINT, ifix, l, kfix, 0);
      VLAT (lat, LP(p2), YGETPOINT, ifix, l + 1, kfix, 0);
      D3_DrawLine (cam3d, p1.x, p1.y, p1.z, p2.x, p2.y, p2.z, color);
    }
  } else if (kfix == 0) {
    ll = lat->kk;
    for (l = 1; l < ll; l++) {
      VLAT (lat, LP(p1), YGETPOINT, ifix, jfix, l, 0);
      VLAT (lat, LP(p2), YGETPOINT, ifix, jfix, l + 1, 0);
      D3_DrawLine (cam3d, p1.x, p1.y, p1.z, p2.x, p2.y, p2.z, color);
    }
  }
}
/*--------------------------D3_DrawTeloFullBody------------------------------*/
void
D3_DrawTeloFullBody (int dim, VT_CAM3D *cam3d, VT_TELO *telo, YT_BOOL colored)
{
  int     i, j, k, ii, jj, kk;
  VT_CPOINT point;
  VT_CPOINT p0, p1, p2, p3;
  YT_COLOR color = YColor("black");
  int     i_scale;
  VT_LAT *lat = telo->lat;

  if (dim == 0 || dim == 3)
    return;

  ii = lat->ii;
  jj = lat->jj;
  kk = lat->kk;
  if (dim == 1) {
    for (i = 1; i <= ii; i++)
    for (j = 1; j <= jj; j++)
    for (k = 1; k <= kk; k++) {
      VLAT (lat, LP(point), YGETPOINT, i, j, k, 0);
      for (i_scale = 0; i_scale < YGet("size_scale"); i_scale++)
	if (point.color == YScale (i_scale))  
	  break;
      if (telo->points_min - 1 <= i_scale && i_scale <= telo->points_max - 1)
	D3_DrawPoint (cam3d, point.x, point.y, point.z, point.color);
    }
  } else if (dim == 2) {
    for (i = 1; i < ii; i++)
    for (j = 1; j < jj; j++)
    for (k = 1; k < kk; k++) {
      VLAT (lat, LP(p0), YGETPOINT, i, j, k, 0);
      VLAT (lat, LP(p1), YGETPOINT, i + 1, j, k, 0);
      VLAT (lat, LP(p2), YGETPOINT, i, j + 1, k, 0);
      VLAT (lat, LP(p3), YGETPOINT, i, j, k + 1, 0);
      if (colored) color = p0.color;
      D3_DrawLine (cam3d, p0.x, p0.y, p0.z, p1.x, p1.y, p1.z, color);
      D3_DrawLine (cam3d, p0.x, p0.y, p0.z, p2.x, p2.y, p2.z, color);
      D3_DrawLine (cam3d, p0.x, p0.y, p0.z, p3.x, p3.y, p3.z, color);
    }
    D3_DrawTeloPlaneIJK (2, cam3d, telo, ii, 0, 0, TRUE);
    D3_DrawTeloPlaneIJK (2, cam3d, telo, 0, jj, 0, TRUE);
    D3_DrawTeloPlaneIJK (2, cam3d, telo, 0, 0, kk, TRUE);
  }
}
/*------------------------D3_DrawTeloPlaneIJK--------------------------------*/
void
D3_DrawTeloPlaneIJK (int dim, VT_CAM3D *cam3d, VT_TELO *telo,
		    int islice, int jslice, int kslice, YT_BOOL colored)
{
  int     l, m, ll, mm;
  VT_CPOINT point, point1, point2, point3, point4;
  VT_FOUR four;
  YT_COLOR color = YColor("black");
  VT_LAT *lat = telo->lat;

  if (dim == 0)
    return;

  VLAT (lat, 0, YBEGIN, islice, jslice, kslice, 0);
  VLAT (lat, 0, YSIZE, LP(ll), LP(mm), 0, 0);

  if (dim == 1) {
    for (l = 1; l <= ll; l++)
    for (m = 1; m <= mm; m++) {
      VLAT (lat, LP(point), YGETPOINT, l, m, 0, 0);
      if (colored)  color = point.color;
      D3_DrawPoint (cam3d, point.x, point.y, point.z, color);
    }
  } else if (dim == 2) {
    for (l = 1; l < ll; l++)
    for (m = 1; m < mm; m++) {
      VLAT (lat, LP(point1), YGETPOINT, l, m, 0, 0);
      VLAT (lat, LP(point2), YGETPOINT, l + 1, m, 0, 0);
      VLAT (lat, LP(point4), YGETPOINT, l, m + 1, 0, 0);
      if (colored)  color = point1.color;
      D3_DrawLine (cam3d, point1.x, point1.y, point1.z, 
		  point2.x, point2.y, point2.z, color);
      D3_DrawLine (cam3d, point1.x, point1.y, point1.z,
		  point4.x, point4.y, point4.z, color);
    }
    for (l = 1; l < ll; l++) {
      VLAT (lat, LP(point1), YGETPOINT, l, mm, 0, 0);
      VLAT (lat, LP(point2), YGETPOINT, l + 1, m, 0, 0);
      if (colored)  color = point1.color;
      D3_DrawLine (cam3d, point1.x, point1.y, point1.z,
		  point2.x, point2.y, point2.z, color);
    }
    for (m = 1; m < mm; m++) {
      VLAT (lat, LP(point1), YGETPOINT, ll, m, 0, 0);
      VLAT (lat, LP(point2), YGETPOINT, ll, m + 1, 0, 0);
      if (colored)  color = point1.color;
      D3_DrawLine (cam3d, point1.x, point1.y, point1.z,
		  point2.x, point2.y, point2.z, color);
    }

  } else if (dim == 3) {
    for (l = 1; l < ll; l++)
    for (m = 1; m < mm; m++) {
      VLAT (lat, LP(point1), YGETPOINT, l, m, 0, 0);
      VLAT (lat, LP(point2), YGETPOINT, l + 1, m, 0, 0);
      VLAT (lat, LP(point3), YGETPOINT, l + 1, m + 1, 0, 0);
      VLAT (lat, LP(point4), YGETPOINT, l, m + 1, 0, 0);
      four.p1.x = point1.x;
      four.p2.x = point2.x;
      four.p3.x = point3.x;
      four.p4.x = point4.x;

      four.p1.y = point1.y;
      four.p2.y = point2.y;
      four.p3.y = point3.y;
      four.p4.y = point4.y;

      four.p1.z = point1.z;
      four.p2.z = point2.z;
      four.p3.z = point3.z;
      four.p4.z = point4.z;

      four.p1.color = point1.color;
      four.p2.color = point2.color;
      four.p3.color = point3.color;
      four.p4.color = point4.color;

      four.color = point3.color;
      D3_DrawFour (cam3d, &four);
    }

  }
  VLAT (lat, 0, YEND, 0, 0, 0, 0);
}
/*-----------------------------D3_SetCube------------------------------------*/
void
D3_SetCube (VT_CAM3D *cam3d)
{

  cam3d->cube_x0 = cam3d->cx;
  cam3d->cube_y0 = cam3d->cy;
  cam3d->cube_z0 = 0;
  cam3d->cube_size = cam3d->w / 3;

}
/*---------------------------------VSetBox----------------------------------*/
void
VSetBox (VT_W3D *w3d, VT_CAM3D *cam3d)
{
  VT_BOX *b = &(w3d->xzy_box);

  SSS.xmax3d = SSS.ymax3d = SSS.zmax3d = YMINSPACE;
  SSS.xmin3d = SSS.ymin3d = SSS.zmin3d = YMAXSPACE;

 /*  cam3d->alfa = cam3d->beta = 0; */
  D3_SetRotate (cam3d, 0, 0);

  CALCUS = TRUE;
  PRINTS = FALSE;
  D3_DrawAll (w3d);
  CALCUS = FALSE;
  PRINTS = TRUE;

  b->p1.x = SSS.xmin3d;  b->p1.y = SSS.ymin3d;  b->p1.z = SSS.zmin3d;
  b->p2.x = SSS.xmax3d;  b->p2.y = SSS.ymin3d;  b->p2.z = SSS.zmin3d;
  b->p3.x = SSS.xmin3d;  b->p3.y = SSS.ymax3d;  b->p3.z = SSS.zmin3d;
  b->p4.x = SSS.xmax3d;  b->p4.y = SSS.ymax3d;  b->p4.z = SSS.zmin3d;
  b->p5.x = SSS.xmin3d;  b->p5.y = SSS.ymin3d;  b->p5.z = SSS.zmax3d;
  b->p6.x = SSS.xmax3d;  b->p6.y = SSS.ymin3d;  b->p6.z = SSS.zmax3d;
  b->p7.x = SSS.xmin3d;  b->p7.y = SSS.ymax3d;  b->p7.z = SSS.zmax3d;
  b->p8.x = SSS.xmax3d;  b->p8.y = SSS.ymax3d;  b->p8.z = SSS.zmax3d;

}
/*-------------------------------D3_SetMinmax--------------------------------*/
void
D3_SetMinmax (VT_W3D *w3d)
{
  YT_SPACE  koef = 1.14;

  SSS.xmax3d = SSS.ymax3d = YMINSPACE;
  SSS.xmin3d = SSS.ymin3d = YMAXSPACE;

  CALCUS = TRUE;
  PRINTS = FALSE;
  D3_DrawAll (w3d);
  CALCUS = FALSE;
  PRINTS = TRUE;

  (w3d->cam3d)->cx = (SSS.xmax3d + SSS.xmin3d) / 2;
  (w3d->cam3d)->cy = (SSS.ymax3d + SSS.ymin3d) / 2;

  (w3d->cam3d)->w = koef * (SSS.xmax3d - SSS.xmin3d);
  (w3d->cam3d)->h = koef * (SSS.ymax3d - SSS.ymin3d);

}
/*-----------------------------V3TeloMakeIsosurf----------------------------*/
void
V3TeloMakeIsosurf (VT_TELO *telo, VT_OBJ3D *obj3d)
{
  int     i, j, k, ii, jj, kk, di, dj, dk, i_rab, j_rab, k_rab;
  static YT_COLOR color;
  VT_CPOINT point;
  static VT_CPOINT v0, v1, v2;
  YT_BOOL first;
  VT_TRI3D *p_tris, tri;
  int     num = 0, num_tris;
  VT_LAT *lat = telo->lat;

  color = YScale (telo->full_isurf - 1);
  ii = lat->ii;
  jj = lat->jj;
  kk = lat->kk;

  num_tris = 1000;
  p_tris = (VT_TRI3D *) malloc (num_tris * sizeof (VT_TRI3D));

  for (i = 1; i <= ii; i++)
  for (j = 1; j <= jj; j++)
  for (k = 1; k <= kk; k++) {
    VLAT (lat, LP(v0), YGETPOINT, i, j, k, 0);
    if (v0.color != color)  
      continue;
    
    first = TRUE;
    for (di = -1; di <= 3; di++)
    for (dj = -1; dj <= 3; dj++)
    for (dk = -1; dk <= 3; dk++) {
      i_rab = i + di;
      j_rab = j + dj;
      k_rab = k + dk;
      if (i_rab < 1 || i_rab > ii)  continue;
      if (j_rab < 1 || j_rab > jj)  continue;
      if (k_rab < 1 || k_rab > kk)  continue;
      
      VLAT (lat, LP(point), YGETPOINT, i_rab, j_rab, k_rab, 0);
      if (point.color != color)  
	continue;
      
      if (first) {
	*&v1 = *&point;
	first = FALSE;
	continue;
      }
      *&v2 = *&point;
      
      *&tri.p1 = *&v0;
      *&tri.p2 = *&v1;
      *&tri.p3 = *&v2;
      tri.f_color = color;
      
      *(p_tris + num++) = *&tri;
      
      *&v1 = *&v2;
    }
  }

  num_tris = num - 1;
  V3ObjInit (obj3d, "VTRIS3D", /* VTRIS3D,  */"", NULL, (long)p_tris, num_tris, 0, 0);

  return;
}
/*--------------------------------D3_CamCreate------------------------------*/
VT_CAM3D *
D3_CamCreate ()
{
  VT_CAM3D *cam3d;

  if (!(cam3d = (VT_CAM3D *) malloc (sizeof (VT_CAM3D))))  
    return (NULL);

/*   cam3d->cx = 0; */
/*   cam3d->cy = 0; */
/*   cam3d->w = 2; */
/*   cam3d->zplane = -10.0; */
/*   cam3d->zview  = -20.0; */
/*   cam3d->zview_flag = FALSE;  */
  D3_Orthographic (cam3d, -20.0, 0, 0, 2, 2, -10, 10);
  
/*   cam3d->scrx = 0; */
/*   cam3d->scry = 0; */
/*   cam3d->scrw = 10; */
/*   cam3d->scrh = 10; */
  D3_Viewport (cam3d, 0, 0, 10, 10);
  cam3d->cube_x0 = 0;
  cam3d->cube_y0 = 0;
  cam3d->cube_z0 = 0;
  cam3d->cube_size = 1;
  cam3d->background = YColor("white");
/*   cam3d->alfa = 15; */
/*   cam3d->beta = 15; */
  D3_SetRotate (cam3d, 15, 15);

  cam3d->xzy_box = FALSE;
  cam3d->repers = 1;
  cam3d->repers_color = YColor("black");
  cam3d->boxing = FALSE;
  
  cam3d->guro = FALSE;
  cam3d->light = FALSE;
  
  return (cam3d); 
}
/*--------------------------------D3_CamDelete------------------------------*/
void
D3_CamDelete (VT_CAM3D *cam3d)
{

  if (!cam3d)  return;

  free (cam3d);
 
  return; 
}
/*--------------------------------D3_WorldDelete------------------------------*/
void
D3_WorldDelete (VT_W3D *w3d)
{

  if (!w3d)  return;
  
  D3_WorldClear(w3d);
  D3_CamDelete (w3d->cam3d);
  /* free (w3d); */ /* ??!! */
 
  return; 
}
/*--------------------------------W3D---------------------------------------*/
long
W3D (void *ptr, long long0, int signal, long long1, long long2, long long3, long long4)
{
  enum y_keys {
    GETPTR = YKEY_LOCALS + 1
  };

  VT_W3D *w3d = (VT_W3D *) ptr;

  switch (signal) {
  case YCONSTR0:
    {
      VT_W3D *w3d;

      if (!W3D (&w3d, 0, YCONSTR1, long1, long2, long3, long4))  return (FALSE);
      if (!W3D (w3d, 0, YCONSTR2, 0, 0, 0, 0))                   return (FALSE);
      if (!W3D (w3d, 0, YCONSTR3, 0, 0, 0, 0))                   return (FALSE);

      *((VT_W3D **) ptr) = w3d;
      return (TRUE);
    }
  case YCONSTR1:
    {
      VT_W3D *w3d;

      if (!(w3d = (VT_W3D *) malloc (sizeof (VT_W3D))))  return (FALSE);

      w3d->cam3d = NULL;
      w3d->xorr = NULL;

      *((VT_W3D **) ptr) = w3d;
      return (TRUE);
    }
  case YCONSTR2:
    {
      /* VT_CAM3D *cam3d; */
     
      if (!(w3d->cam3d = D3_CamCreate ()))  return (FALSE);
      return (TRUE);

    }
  case YCONSTR3:
    {
/*       VT_OBJ3D **obj3d = w3d->o3d; */
/*       int     i; */

      D3_WorldClear(w3d);
 /*      for (i = 0; i < MAX_OBJ3D; i++) */
/* 	obj3d[i] = NULL; */

      return (TRUE);
    }
  case YDESTRU0:
    if (!w3d)  
      break;
    W3D (w3d, 0, YDESTRU3, 0, 0, 0, 0);
    W3D (w3d, 0, YDESTRU2, 0, 0, 0, 0);
    W3D (w3d, 0, YDESTRU1, 0, 0, 0, 0);
    break;
  case YDESTRU3:
    D3_WorldClear(w3d);
    break;
  case YDESTRU2:
    if (w3d->cam3d) {
      free (w3d->cam3d);
      w3d->cam3d = NULL;
    }
    break;
  case YDESTRU1:
    /* free (w3d); */ /* ??!! */
    break;
  default:;;;;;
  }

  long0++;
  return (YNULL);
}
/*------------------------------D3_DrawFlines--------------------------------*/
void
D3_DrawFlines (VT_CAM3D *cam3d, VT_OBJ3D *obj3d)
{
  VT_FLINES3D func = (VT_FLINES3D) obj3d->long1;
  long    lparam = obj3d->long2;
  YT_COLOR color = (YT_COLOR) obj3d->long3;

  YT_SPACE x1, y1, z1, x2, y2, z2;
  if (!func)
    YError ("Flines");

  ((*(func)) (FALSE, &x1, &y1, &z1, &x2, &y2, &z2, lparam));
  do {
    D3_DrawLine (cam3d, x1, y1, z1, x2, y2, z2, color);
  } while (((*(func)) (TRUE, &x1, &y1, &z1, &x2, &y2, &z2, lparam)));

  return;
}
/*-----------------------------D3_DrawMarker----------------------------------*/
void
D3_DrawMarker (VT_CAM3D *cam3d, VT_P3D *p, int type, YT_SPACE size, YT_COLOR color)
{
  YT_SPACE pol = size/2, x, y, z;

  x = p->x;
  y = p->y;
  z = p->z;

  switch (type) {
  case YLINE:
    D3_DrawLine (cam3d, x-pol, y-pol, z-pol,  x+pol, y+pol, z+pol, color);
    break;
  case YCUBE:
    D3_DrawCube (cam3d, x, y, z, size, color);
    break;
  default: ;;;
  }

  return;
}
/*-----------------------------D3_DrawMarkerS----------------------------------*/
void
D3_DrawMarkerS (VT_CAM3D *cam3d, VT_OBJ3D *obj3d)
{
  VT_P3D  *p     = (VT_P3D*) obj3d->p;
  int      num   = (int) obj3d->long1;
  int      type  = (int) obj3d->long2; 
  YT_SPACE size, *p_size  = (YT_SPACE*)obj3d->long3; 
  YT_COLOR color = (int) obj3d->long4;

  int i;

  if (p_size == NULL) size = 0.1;
  else                size = *p_size;

  for (i = 0; i < num; i++, p++) {
    D3_DrawMarker (cam3d, p, type, size, color);
  }

  return;
}
/*-----------------------------D3_DrawSetka----------------------------------*/
void
D3_DrawSetka (VT_CAM3D *cam3d, VT_OBJ3D *obj3d)
{
  VT_P3D  *pts = (VT_P3D *) obj3d->p;
  int     inum = (int) obj3d->long1;
  int     jnum = (int) obj3d->long2;
  YT_COLOR   color = (YT_COLOR) obj3d->long3;
  YT_BOOL is_frame = (YT_BOOL) obj3d->long4;

  int     i, j, l, m;
  VT_P3D *p;
  VT_P3D *p1, *p2, *p3, *p4;
  YT_COLOR l_color = YColor("black");
  VT_FOUR four;

  OUTD(444);
  if (!pts)  return;

  if (is_frame) {
    for (i = 0; i < inum; i++)
    for (j = 0; j < jnum - 1; j++) {
      p = &pts[i * jnum + j];
      D3_DrawLine (cam3d, p->x, p->y, p->z, (p + 1)->x, (p + 1)->y, (p + 1)->z, l_color);
    }
    for (j = 0; j < jnum; j++)
    for (i = 0; i < inum - 1; i++) {
      p = &pts[i * jnum + j];
      p1 = &pts[(i + 1) * jnum + j];
      D3_DrawLine (cam3d, p->x, p->y, p->z, p1->x, p1->y, p1->z, l_color);
    }
  }

  if (color != CLR_NULL) {
    for (i = 0; i < inum - 1; i++)
    for (j = 0; j < jnum - 1; j++) {
      l = i;  
      m = j;
      p1 = &pts[l * jnum + m];
      l = i + 1;  
      m = j;
      p2 = &pts[l * jnum + m];
      l = i + 1;
      m = j + 1;
      p3 = &pts[l * jnum + m];
      l = i;
      m = j + 1;
      p4 = &pts[l * jnum + m];
      
      four.p1.x = p1->x;
      four.p2.x = p2->x;
      four.p3.x = p3->x;
      four.p4.x = p4->x;

      four.p1.y = p1->y;
      four.p2.y = p2->y;
      four.p3.y = p3->y;
      four.p4.y = p4->y;

      four.p1.z = p1->z;
      four.p2.z = p2->z;
      four.p3.z = p3->z;
      four.p4.z = p4->z;

      four.color = color;
      
      D3_DrawFour (cam3d, &four);
    }
  }


  return;
}
/*----------------------------D3_DrawPoints----------------------------------*/
void
D3_DrawPoints (VT_CAM3D *cam3d, VT_OBJ3D *obj3d)
{
  VT_CPOINT *p = (VT_CPOINT *) obj3d->long1;
  int     ii = (int) obj3d->long2;
  int     jj = (int) obj3d->long3;
  int     kk = (int) obj3d->long4;
  int     i, j, k;
  VT_CPOINT *point;

  for (i = 1; i <= ii; i++) {
  for (j = 1; j <= jj; j++) {
  for (k = 1; k <= kk; k++) {
    /* point = p + AAA (ii, jj, i, j, k); */
    point = p + BBB (ii,jj,kk, i,j,k);
    D3_DrawPoint (cam3d, point->x, point->y, point->z, point->color);
  }}}

}
/*-----------------------------D3_LightShow----------------------------------*/
void
D3_LightShow ()
{

  V3_LIGHT = TRUE;

}
/*-----------------------------D3_LightDo------------------------------------*/
YT_COLOR
D3_LightDo (YT_COLOR old_color, float sina)
{
  YT_COLOR new_color;
  int     old_index, new_index, delta = 10;

  old_index = YColorToScale (old_color);
  new_index = old_index + sina * delta;
  new_color = YScale (new_index);

  return (new_color);
}
/*-------------------------------D3_LightHide--------------------------------*/
void
D3_LightHide ()
{

  V3_LIGHT = FALSE;

}
/*-------------------------------D3_GuroYes----------------------------------*/
void
D3_GuroYes ()
{

  V_GURO = TRUE;

}
/*-------------------------------D3_GuroNot----------------------------------*/
void
D3_GuroNot ()
{

  V_GURO = FALSE;

}
/*-------------------------------D3_WorldClear---------------------------------*/
void
D3_WorldClear(VT_W3D *w3d)
{
  VT_OBJ3D **obj3d = w3d->o3d;
  int     i;

  for (i = 0; i < MAX_OBJ3D; i++) {
   /*  obj3d[i]->existed = FALSE; */
    obj3d[i] = NULL;
  };

  return;
}
/*---------------------------------D3_WorldAddTo---------------------------------*/
YT_BOOL
D3_WorldAddTo (VT_W3D *w3d, VT_OBJ3D *obj)
{
  VT_OBJ3D **obj3d = w3d->o3d;
  int     i;

  for (i = 0; i < MAX_OBJ3D; i++) {
    if (obj3d[i] == obj)  return (TRUE);
    if (obj3d[i] != NULL && obj3d[i]->existed)  
      continue;

    obj3d[i] = obj;
    return (TRUE);
  };

  YMessageBox ("Too many OBJ3D!", "OK");
  return (FALSE);
}
/*------------------------------V3ObjInit-----------------------------------*/
void
V3ObjInit (VT_OBJ3D *obj3d, char *tname, /* int type,  */char *name, void *p,
	   long long1, long long2, long long3, long long4)
{

  obj3d->existed = TRUE;
  obj3d->visible = TRUE;
  obj3d->tname = tname;
  /* obj3d->type = type; */
  obj3d->name = name;
  obj3d->p = p;
  obj3d->long1 = long1;
  obj3d->long2 = long2;
  obj3d->long3 = long3;
  obj3d->long4 = long4;

}
/*-----------------------------D3_ZbufPut------------------------------------*/
YT_BOOL
D3_ZbufPut (int x, int y, YT_SPACE z)
{
  if (!ZBUFF_flag)  YError ("D3_ZbufPut");
  if (z == ZBUFF_zditto)  return (TRUE);

  if (z < ZBUFF_zplane)  return (FALSE);

  if (!(x >= 1 && y >= 1 && x <= ZBUFF_w && y <= ZBUFF_h))  
    return (FALSE);

  if (z > ZBUFF_val (x, y))  
    return (FALSE);

  ZBUFF_val (x, y) = z;

  return (TRUE);
}
/*------------------------------VDrawLegend---------------------------------*/
void
VDrawLegend (int xscr, int yscr, int w, int twice_h)
{
  int     x = 0, y = 0, h = twice_h / 2;
  static void *cmap = NULL;

  int     i, x_, y_;
  YT_SPACE h00, h14, h12, h34, h11, hhh, hcur;
  char    s00[10], s14[10], s12[10], s34[10], s11[10];
  int     rect_left, rect_right, rect_w;
  VT_CDAT *cdat = &cdat_glob;

  cmap = YColmapCreate ();
  YColmapInit (cmap, w, twice_h);
  YColmapBeginDraw (cmap, 0, 0, YColor("white"));

  h00 = cdat->hmin;
  h11 = cdat->hmax;

  hhh = h11 - h00;
  h14 = h00 + hhh / 4;
  h12 = h00 + hhh / 2;
  h34 = h12 + hhh / 4;

  sprintf (s00, "%.1f", h00);
  sprintf (s14, "%.1f", h14);
  sprintf (s12, "%.1f", h12);
  sprintf (s34, "%.1f", h34);
  sprintf (s11, "%.1f", h11);

  VHandRectF (x, y, w, 2 * h, YColor("white"));
  VHandRectB (x, y, w, 2 * h, YColor("black"));

  rect_left = x + 1;
  for (i = 1; i <= YGet("size_scale"); i++) {
    VMaping (&cdat_glob, &hcur, &i, FALSE);  /*??????*/
    x_ = YInt (w * (hcur - h00) / hhh);
    rect_right = x + 1 + x_;
    rect_w = rect_right - rect_left + 1;
    VHandRectF (rect_left, y + 1, rect_w, h - 2, YScale (i - 1));
    rect_left = rect_right + 1;
  }

  y_ = y + h + h / 2;
  VHandText (x + 5, y_, s00, YColor("black"), ZBUFF_zditto);
  VHandText (x + w - 5 - strlen (s11) * 8, y_, s11, YColor("black"), ZBUFF_zditto);

  x_ = x + w / 4;
  VHandText (x_ - strlen (s14) * 4, y_, s14, YColor("black"), ZBUFF_zditto);
  VHandLine (x_, y + h / 2, x_, y + h, YColor("black"), 0, 0);
  x_ = x + w / 2;
  VHandText (x_ - strlen (s12) * 4, y_, s12, YColor("black"), ZBUFF_zditto);
  VHandLine (x_, y + h / 2, x_, y + h, YColor("black"), 0, 0);
  x_ = x + 3 * w / 4;
  VHandText (x_ - strlen (s34) * 4, y_, s34, YColor("black"), ZBUFF_zditto);
  VHandLine (x_, y + h / 2, x_, y + h, YColor("black"), 0, 0);

  YColmapEndDraw ();
  YDrawColmapB (cmap, xscr, yscr, 0, 0, YColor("black"));

  return;
}
/*-----------------------------D3_DrawTeloMain-------------------------------*/
void
D3_DrawTeloMain (VT_CAM3D *cam3d, VT_OBJ3D *obj3d)
{
  VT_TELO *telo = (VT_TELO *) obj3d->long2;

  if (!PRINTS) {
    D3_DrawTeloIJKBox (cam3d, telo);
    return;
  }

  if (telo->full_points)  D3_DrawTeloFullBody (1, cam3d, telo, TRUE);
  if (telo->full_lines)   D3_DrawTeloFullBody (2, cam3d, telo, telo->full_colored);
  if (telo->ijk_box)      D3_DrawTeloIJKBox (cam3d, telo);

  if (telo->i1_polys)  D3_DrawTeloPlaneIJK (3, cam3d, telo, telo->i1, 0, 0, TRUE);
  if (telo->i1_lines)  D3_DrawTeloPlaneIJK (2, cam3d, telo, telo->i1, 0, 0, FALSE);

  if (telo->i2_polys)  D3_DrawTeloPlaneIJK (3, cam3d, telo, telo->i2, 0, 0, TRUE);
  if (telo->i2_lines)  D3_DrawTeloPlaneIJK (2, cam3d, telo, telo->i2, 0, 0, FALSE);

  if (telo->j1_polys)  D3_DrawTeloPlaneIJK (3, cam3d, telo, 0, telo->j1, 0, TRUE);
  if (telo->j1_lines)  D3_DrawTeloPlaneIJK (2, cam3d, telo, 0, telo->j1, 0, FALSE);

  if (telo->j2_polys)  D3_DrawTeloPlaneIJK (3, cam3d, telo, 0, telo->j2, 0, TRUE);
  if (telo->j2_lines)  D3_DrawTeloPlaneIJK (2, cam3d, telo, 0, telo->j2, 0, FALSE);

  if (telo->k1_polys)  D3_DrawTeloPlaneIJK (3, cam3d, telo, 0, 0, telo->k1, TRUE);
  if (telo->k1_lines)  D3_DrawTeloPlaneIJK (2, cam3d, telo, 0, 0, telo->k1, FALSE);

  if (telo->k2_polys)  D3_DrawTeloPlaneIJK (3, cam3d, telo, 0, 0, telo->k2, TRUE);
  if (telo->k2_lines)  D3_DrawTeloPlaneIJK (2, cam3d, telo, 0, 0, telo->k2, FALSE);

}
/*----------------------------V3TeloCreate----------------------------------*/
VT_TELO *
V3TeloCreate ()
{
  VT_TELO *telo;

  if (!(telo = (VT_TELO *) malloc (sizeof (VT_TELO))))
            YError ("");

  return (telo);
}
/*-----------------------------V3TeloInit----------------------------------*/
void
V3TeloInit (VT_TELO *telo, VT_LAT *lat)
{

  telo->lat = lat;

  telo->ijk_box = TRUE;
  telo->full_points = FALSE;
  telo->points_min = 1;
  telo->points_max = YGet("size_scale");
  telo->full_lines = FALSE;
  telo->full_colored = TRUE;
  telo->full_isosurf = FALSE;
  telo->full_isurf = 1;

  telo->i1_lines = telo->j1_lines = telo->k1_lines = FALSE;
  telo->i2_lines = telo->j2_lines = telo->k2_lines = FALSE;

  telo->i1_polys = TRUE;
  telo->i2_polys = FALSE;
  telo->j1_polys = FALSE;
  telo->j2_polys = FALSE;
  telo->k1_polys = FALSE;
  telo->k2_polys = FALSE;

  telo->i1 = telo->j1 = telo->k1 = 1;
  telo->i2 = telo->j2 = telo->k2 = 999;

  return;
}
/*--------------------------------VFuncXYZ----------------------------------*/
YT_SPACE
VFuncXYZ (int func, YT_SPACE x, YT_SPACE y, YT_SPACE z)
{
  switch (func) {
  case 1: return (x);
  case 2: return (x * x + y * y + z * z);
  case 3: return (x * ((YT_SPACE) exp ((double) (-(x * x) - (y * y) - (z * z)))));
  case 4: return (x * x - y * y);
  case 5: return (x + y);
  case 6: return (1 / (x + y));
  case 7: return ((x - 5) * (x - 5) + (y - 5) * (y - 5) + YRandF (0, x + y + 5));
  case 8: return (sin (x));
  case 9: return (sin (2 * x) * cos (x));

  }
  return (0);
}
/*------------------------------VHandRectF----------------------------------*/
void
VHandRectF (int x, int y, int w, int h, YT_COLOR f_color)
{
  int     i, j;

  for (j = y; j < y + h; j++)
  for (i = x; i < x + w; i++) {
    VHandPixel (i, j, f_color, ZBUFF_zditto);
  }

}
/*------------------------------VHandRectB----------------------------------*/
void
VHandRectB (int x, int y, int w, int h, YT_COLOR color)
{

  w--;
  h--;
  VHandLine (x, y, x + w, y, color, ZBUFF_zditto, ZBUFF_zditto);
  VHandLine (x + w, y, x + w, y + h, color, ZBUFF_zditto, ZBUFF_zditto);
  VHandLine (x + w, y + h, x, y + h, color, ZBUFF_zditto, ZBUFF_zditto);
  VHandLine (x, y + h, x, y, color, ZBUFF_zditto, ZBUFF_zditto);

}
/*-------------------------------VHandPixel---------------------------------*/
YT_BOOL
VHandPixel (int x, int y, YT_COLOR color, YT_SPACE z)
{

/* OUTD(1); */
  if (ZBUFF_flag && !D3_ZbufPut (x, y, z))
    return (FALSE);

/* OUTD(2); */
    YColmapDrawPixel (x, y, color);

  return (TRUE);
}
/*----------------------------VHandLoadFont---------------------------------*/
void
VHandLoadFont ()
{
  FILE   *in;
  char   *p;
  int     i;
  char    name[200] = "";
  char   *pch;

  if ((in = fopen ("ega.cpi", "rb")) != NULL)
    goto metka;

  if (!(pch = getenv ("SVISOR_HOME")))
    if (!(pch = getenv ("HOME")))
      return;

  strncpy (name, pch, 180);
  strcat (name, "/");
  strcat (name, "ega.cpi");
  if ((in = fopen (name, "rb")) == NULL) {
    SSS.ptr_fonts = NULL;
    return;
  }

metka:;;
  if (!(SSS.ptr_fonts = (char *) malloc (16 * 256)))
    YError ("VHandText-malloc");
  p = SSS.ptr_fonts;
  fseek (in, 65, SEEK_SET);

  for (i = 0; i < 256 * 16; i++) {
    *p = fgetc (in);
    p++;
  }

  fclose (in);
  return;
}
/*-----------------------------VHandText------------------------------------*/
void
VHandText (int x0, int y0, char *text, YT_COLOR color, YT_SPACE z0)
{
  int     i, l_text;
  char    ch;
  int     x, y, cart, j;

  if (SSS.ptr_fonts == NULL)
    return;

  y0 -= 7;
  l_text = strlen (text);
  for (i = 0; i < l_text; i++) {
    ch = text[i];
    for (j = 0; j < 16; j++) {
      x = x0;
      y = y0 + j;
      cart = *(SSS.ptr_fonts + ch * 16 + j);

      if (cart & 128) VHandPixel (x, y, color, z0);
      x++;
      if (cart & 64)  VHandPixel (x, y, color, z0);
      x++;
      if (cart & 32)  VHandPixel (x, y, color, z0);
      x++;
      if (cart & 16)  VHandPixel (x, y, color, z0);
      x++;
      if (cart & 8)   VHandPixel (x, y, color, z0);
      x++;
      if (cart & 4)   VHandPixel (x, y, color, z0);
      x++;
      if (cart & 2)   VHandPixel (x, y, color, z0);
      x++;
      if (cart & 1)   VHandPixel (x, y, color, z0);
    }
    x0 = x + 1;
  }

  return;
}
/*-----------------------------VHandLine------------------------------------*/
void
VHandLine (int x1, int y1, int x2, int y2, YT_COLOR color,
	   YT_SPACE z1, YT_SPACE z2)
{
  VT_HANDLINE line;
  int     x, y, dx, dy;
  YT_SPACE dz, z, koef;
  YT_BOOL by_y;

  dx = x2 - x1;
  dy = y2 - y1;
  dz = z2 - z1;
  if (!dx && !dy)
    return;

  if (abs (dy) > abs (dx))  by_y = TRUE;
  else                      by_y = FALSE;

  VHandLineFunc (&line, FALSE, &x1, &y1, &x2, &y2);

  while (VHandLineFunc (&line, TRUE, &x, &y, NULL, NULL)) {
    if (by_y)  koef = YABS ((float) (y - y1) / dy);
    else       koef = YABS ((float) (x - x1) / dx);
    z = z1 + dz * koef;
    VHandPixel (x, y, color, z);
  }

}
/*--------------------------VHandLineFunc-----------------------------------*/
YT_BOOL
VHandLineFunc (VT_HANDLINE *p, YT_BOOL flag, int *px1, int *py1,
	       int *px2, int *py2)
{
  int     x1, y1, x2, y2, delta;

  if (flag == FALSE) {
    x1 = *px1;
    y1 = *py1;
    x2 = *px2;
    y2 = *py2;

    p->delta_x = x2 - x1;
    p->delta_y = y2 - y1;
    p->x = x1;
    p->y = y1;

    if      (p->delta_x > 0)  p->incx = 1;
    else if (p->delta_x == 0) p->incx = 0;
    else                      p->incx = -1;

    if      (p->delta_y > 0)  p->incy = 1;
    else if (p->delta_y == 0) p->incy = 0;
    else                      p->incy = -1;

    p->delta_x = abs (p->delta_x);
    p->delta_y = abs (p->delta_y);
    if (p->delta_y > p->delta_x) {
      delta = p->delta_x;
      p->delta_x = p->delta_y;
      p->delta_y = delta;
      p->exchange = TRUE;
    } else
      p->exchange = FALSE;

    p->err = 2 * p->delta_y - p->delta_x;
    p->i = 1;
    return (TRUE);
  }

  if (p->i > p->delta_x)
    return (FALSE);
  *px1 = p->x;
  *py1 = p->y;
  while (p->err >= 0) {
    if (p->exchange)  p->x += p->incx;
    else              p->y += p->incy;
    p->err = p->err - 2 * p->delta_x;
  }
  if (p->exchange)  p->y += p->incy;
  else              p->x += p->incx;
  p->err += 2 * p->delta_y;
  p->i++;

  return (TRUE);
}
/*-------------------------------mCut---------------------------------------*/
long
mCut (PFUNC_VAR)
{
  typedef struct {
    ABCD;
  } YT_USR;

  enum keys {
    MAKE_LAT_1 = YKEY_LOCALS + 1
  };

  static YT_BOOL cut_isit;
  static int imin, imax, jmin, jmax, kmin, kmax;
  static int ii, jj, kk;
  static VT_LAT *lat_old;
  static VT_LAT *lat;
  static int one = 1;
  static char ii_str[5], jj_str[5], kk_str[5];

  YT_SPACE space;
  int     i, j, k, d, dd, i_old, j_old, k_old;
  int     y1, y2, y3;

  switch (message) {
  case YCREATE:
    U_MALLOC;
    if (!(VLAT (&(lat), 0, YCONSTR1, 0, 0, 0, 0)))
      YError ("...");
    lat = lat;
    cut_isit = FALSE;
    imin = jmin = kmin = 1;
    imax = jmax = kmax = 999;
    ii = jj = kk = 999;
    break;
/*   case MM_FORWARD: */
/*     break; */
  case MM_DITTO:
    lat_old = (VT_LAT *) PDATA;
    YGoto (YKEYWORD1, 0, 0, 0, 0);
    YGoto (MAKE_LAT_1, 0, 0, 0, 0);
    YAlgOut (YSEND2FACE, MDATA,  0, 0, 0, (long)(lat));
    break;
  case MM_APPLY:
    YGoto (YAPPLY, 0, 0, 0, 0);
    break;

  case YAPPLY:
    if ((lat)->pdata == NULL)
      break;
    YMouseForm ("wait");
    YGoto (MAKE_LAT_1, 0, 0, 0, 0);
    YMouseForm ("arrow");
    YAlgOut (YSEND2FACE, MM_DITTO,  0, 0, 0, (long)(lat));
    break;
  case YKEYWORD1:
    ii = lat_old->ii;
    jj = lat_old->jj;
    kk = lat_old->kk;

    imax = YMIN (imax, 2 * ii / 3);
    jmax = YMIN (jmax, 2 * jj / 3);
    kmax = YMIN (kmax, 2 * kk / 3);

    imin = YMIN (ii / 3, imax);
    jmin = YMIN (jj / 3, jmax);
    kmin = YMIN (kk / 3, kmax);
    break;
  case MAKE_LAT_1:
    *(lat) = *(lat_old);

    if (cut_isit) {
      ii = imax - imin + 1;
      jj = jmax - jmin + 1;
      kk = kmax - kmin + 1;
      dd = 3 + lat->dd;
      if (!(VLAT (lat, 0, YCONSTR2, ii, jj, kk, lat->dd)))  YError ("...");
      if (!(VLAT (lat, 0, YCONSTR3, ii, jj, kk, lat->dd)))  YError ("...");

      for (i = 1; i <= ii; i++) 
      for (j = 1; j <= jj; j++) 
      for (k = 1; k <= kk; k++) 
      for (d = 1; d <= dd; d++) {
	i_old = i + imin - 1;
	j_old = j + jmin - 1;
	k_old = k + kmin - 1;
	VLAT (lat_old, LP(space), YGETDATA, i_old, j_old, k_old, d);
	VLAT (lat, LP(space), YPUTDATA, i, j, k, d);
      }
      lat->ii = ii;
      lat->jj = jj;
      lat->kk = kk;
    }
    break;
  case YGETSIZE:
    MYSIZE_IS (W_MOD, H_MOD);
    break;
  case YOPEN:
    sprintf (ii_str, "..%d", ii);
    sprintf (jj_str, "..%d", jj);
    sprintf (kk_str, "..%d", kk);
  case YDRAW:
    YDrawRectF (0, 0, WND->w, WND->h, WIN->color);
    YBeginGroup ("", 30,20, 270,140, YColor(""));
    YWnd (Ph(), CHECK, "Do this cut?", 35,10, 20,20, 0,LP(cut_isit),0,0, CLR_DEF);
    y1 = 45;
    y2 = y1 + 25;
    y3 = y2 + 25;
    YWnd (Ph(), YTEXT, "I: ", 35,y1, 50,20, (long)"1..",0,0,0, CLR_DEF);
    YWnd (Ph(), YTEXT, "J: ", 35,y2, 50,20, (long)"1..",0,0,0, CLR_DEF);
    YWnd (Ph(), YTEXT, "K: ", 35,y3, 50,20, (long)"1..",0,0,0, CLR_DEF);
    /* !!!!! */
/*     YWnd (Ph(), 0,"DECIMAL", "", 90,y1, 50,20, LP(imin),LP(one),LP(imax),0, CLR_DEF); */
/*     YWnd (Ph(), 0,"DECIMAL", "", 90,y2, 50,20, LP(jmin),LP(one),LP(jmax),0, CLR_DEF); */
/*     YWnd (Ph(), 0,"DECIMAL", "", 90,y3, 50,20, LP(kmin),LP(one),LP(kmax),0, CLR_DEF); */
    YWnd (Ph(), DECIMAL, "", 90,y1, 50,20, 0,one,ii,LP(imin), CLR_DEF);
    YWnd (Ph(), DECIMAL, "", 90,y2, 50,20, 0,one,jj,LP(jmin), CLR_DEF);
    YWnd (Ph(), DECIMAL, "", 90,y3, 50,20, 0,one,kk,LP(kmin), CLR_DEF);

    YWnd (Ph(), DECIMAL, "", 145,y1, 50,20, 0,imin,ii,LP(imax), CLR_DEF);
    YWnd (Ph(), DECIMAL, "", 145,y2, 50,20, 0,jmin,jj,LP(jmax), CLR_DEF);
    YWnd (Ph(), DECIMAL, "", 145,y3, 50,20, 0,kmin,kk,LP(kmax), CLR_DEF);

    YWnd (Ph(), YTEXT, "", 200,y1, 50,20, (long)ii_str,0,0,0, CLR_DEF);
    YWnd (Ph(), YTEXT, "", 200,y2, 50,20, (long)jj_str,0,0,0, CLR_DEF);
    YWnd (Ph(), YTEXT, "", 200,y3, 50,20, (long)kk_str,0,0,0, CLR_DEF);

    YEndGroup ();
    break;
  case YCLOSE:
    YWndClean (id);
    break;
  default:
    if (MM_FORWARD)  YAlgOut (YSEND2FACE, message,  mes1, mes2, mes3, mes4);
  }

  RETURN_TRUE;
}
/*----------------------------VIlistCreate----------------------------------*/
int *
VIlistCreate (int num, int fill)
{
  int    *ilist;
  int     i;

  YMALLOC (ilist, int, num);
  for (i = 0; i < num; i++)
    ilist[i] = fill;

  return (ilist);
}
/****************************************************************************/
/*                          Y - M O D U L E S                               */ 
/****************************************************************************/

/*------------------------------VLAT_put------------------------------------*/
void  VLAT_put (void *lat, int i, int j, int k, int d, long pdata)
{

  if (i == 1 || j == 1 || k == 1)  
    return;

  VLAT (lat, pdata, YPUTDATA, i, j, k, d);

  if (i != 2 && j != 2 && k != 2)  
    return;

  if (i == 2 && j == 2 && k == 2)  VLAT (lat, pdata, YPUTDATA, 1, 1, 1, d);
  if (i == 2 && j == 2)            VLAT (lat, pdata, YPUTDATA, 1, 1, k, d);
  if (j == 2 && k == 2)            VLAT (lat, pdata, YPUTDATA, i, 1, 1, d);
  if (k == 2 && i == 2)            VLAT (lat, pdata, YPUTDATA, 1, j, 1, d);
  if (i == 2)                      VLAT (lat, pdata, YPUTDATA, 1, j, k, d);
  if (j == 2)                      VLAT (lat, pdata, YPUTDATA, i, 1, k, d);
  if (k == 2)                      VLAT (lat, pdata, YPUTDATA, i, j, 1, d);

  return;
}
/*------------------------------mRotL--------------------------------------*/
long
mRotL (PFUNC_VAR)
{
  static YT_BOOL func0 = TRUE, func1 = TRUE;
  static char *names[2] = {
    "x^2+y^2+z^2",
    "x*exp(x^2-...)",
  };
  typedef struct {
    ABCD;
  } YT_USR;
  static int ii, jj, kk, dd, ii_man, jj_man, kk_man;
  static char *data_names[10];
  static int one = 1, sto = 100;
  char   *text[] =
  {
    "Creation test 3D-latice data (rotate).",
    "......................................",
    NULL
  };
  static YT_SPACE x, y, z, data;
  int     i, j, k, d;
  static void *lat;
  YT_SPACE u, v, r, ustep, vstep, rstep, uv;
  static YT_SPACE rmin, rmax;
  static int hRmin, hRmax;
  static YT_BOOL polusphere;

  switch (message) {
  case YCREATE:
    U_MALLOC;
    WND->name = "RotL";
    ii_man = 5;
    jj_man = 10;
    kk_man = 10;
    rmin = 9;  rmax = 12; 
    polusphere=TRUE;
    break;
/*   case MM_FORWARD: */
/*     break; */
  case MM_APPLY:
    YGoto (YAPPLY, 0, 0, 0, 0);
    break;
  case YAPPLY:
    lat = NULL;
    ii = ii_man;
    jj = jj_man;
    kk = kk_man;

    dd = 0;
    if (func0) data_names[dd++] = names[0];
    if (func1) data_names[dd++] = names[1];
    data_names[dd] = NULL;
    if (dd == 0) {
      YMessageBox ("Where are data ?", "OK");
      return (FALSE);
    }
    VLAT (lat, 0, YDESTRU0, 0, 0, 0, 0);
    VLAT (&lat, 3, YCONSTR0, ii, jj, kk, dd);
    VLAT (lat, 0, YNAMES, 0, 0, 0, (long)data_names);

    YGoto (YMAKE, 0, 0, 0, 0);

    YAlgOut (YSEND2FACE, MM_LAT3,  0, 0, 0, (long)lat);
    break;
  case YMAKE:
    if (polusphere) uv=YPI;
    else            uv=2*YPI;
    ustep = (uv) / (jj - 1);
    vstep = (uv) / (kk - 1);
    rstep = (rmax - rmin) / (ii - 1);
    YMouseForm ("wait");
    for (i = 1; i <= ii; i++) 
    for (j = 1; j <= jj; j++) 
    for (k = 1; k <= kk; k++) {
      r = rmin + rstep * (i-1);
      u = ustep * (j-1);
      v = vstep * (k-1);
      /*
      if (!(i == 1 || i == ii)) r = YRandF (r - rstep / 2, r + rstep / 2);
      if (!(j == 1 || j == jj)) u = YRandF (u - ustep / 2, u + ustep / 2);
      if (!(k == 1 || k == kk)) v = YRandF (v - vstep / 2, v + vstep / 2); 
      */
      x = r * cos (u);
      y = r * sin (u) * sin (v);
      z = r * sin (u) * cos (v);

      VLAT (lat, LP(x), YPUTDATA, i, j, k, 1);
      VLAT (lat, LP(y), YPUTDATA, i, j, k, 2);
      VLAT (lat, LP(z), YPUTDATA, i, j, k, 3);
      
      d = 4;
      if (func0) {
	data = x * x + y * y + z * z;
	VLAT (lat, LP(data), YPUTDATA, i, j, k, d++);
      }
      if (func1) {
	data = x * ((YT_SPACE) exp ((double) (-(x * x) - (y * y) - (z * z))));
	VLAT (lat, LP(data), YPUTDATA, i, j, k, d++);
      }
    }
    YMouseForm ("arrow");
    return (TRUE);
  case YGETSIZE:
    MYSIZE_IS (W_MOD, H_MOD);
    break;
  case YOPEN:
  case YDRAW:
    YDrawRectF (0, 0, WND->w, WND->h, WIN->color);
    YDrawStrings (text, 10, 20);

    YBeginGroup ("Functions", 10,65, 160,65, YColor(""));
    YWnd (Ph(), CHECK, names[0], 10,10, 20,20, 0,LP(func0),0,0, CLR_DEF);
    YWnd (Ph(), CHECK, names[1], 10,35, 20,20, 0,LP(func1),0,0, CLR_DEF);
    YEndGroup ();

    YBeginGroup ("Sizes", 180,65, 125,140, YColor(""));
    YWnd (Ph(), DECIMAL, "",  5,20, 35,20, 0,one,sto,LP(ii_man), CLR_DEF);
    YWnd (Ph(), DECIMAL, "", 45,20, 35,20, 0,one,sto,LP(jj_man), CLR_DEF);
    YWnd (Ph(), DECIMAL, "", 85,20, 35,20, 0,one,sto,LP(kk_man), CLR_DEF);

    YWnd (&hRmin, FLOATS, "rmin= ", 45,50, 45,20, LP(rmin),YSPACE,0,0, CLR_DEF);
    YWnd (&hRmax, FLOATS, "rmax= ", 45,75, 45,20, LP(rmax),YSPACE,0,0, CLR_DEF);

    YWnd (Ph(), CHECK, "1/2 sphere", 10,110, 20,20, 0,LP(polusphere),0,0, CLR_DEF);
    YEndGroup ();

    break;
  case YCLOSE:
    YWndClean (id);
    break;
  default:
    if (MM_FORWARD)  YAlgOut (YSEND2FACE, message,  mes1, mes2, mes3, mes4);
  }

  RETURN_TRUE;
}
/*-----------------------------mW_LAT---------------------------------------*/
long
mW_LAT (PFUNC_VAR)
{
  typedef struct {
    ABCD;
  } YT_USR;
  char   *text[] = {
    "Write latice data to file :",
    NULL
  };
  static VT_LAT *lat3;
  int   i,j,k,d, ii,jj,kk,dd, xzy;
  FILE *out;
  static int hFname;
  static char fname[80];

  YT_SPACE x,y,z,data;
  static YT_BOOL do_xzy=TRUE,  do_data=TRUE;
  static YT_BOOL do_bin=FALSE, do_asc=TRUE;

  switch (message) {
  case YCREATE:
    U_MALLOC;
    WND->name = "W_LAT";
    strcpy (fname, "latice.dat"); 
    break;
/*   case MM_FORWARD: */
/*     break; */
  case MM_LAT3:
    lat3 = (VT_LAT *) PDATA;
    YGoto (YMAKE, 0, 0, 0, 0);
    break;
  case MM_APPLY:
    YGetData (hFname);
    YGoto (YMAKE, 0, 0, 0, 0);
    break;
  case YMAKE:
    if      (do_asc)  YGoto (YASCII, 0,0,0, 0);
    else if (do_bin)  YGoto (YBINARY, 0,0,0, 0);
    break;
  case YASCII:
    ii = lat3->ii;
    jj = lat3->jj;
    kk = lat3->kk;
    dd = lat3->dd;

    if ((out=fopen(fname,"w")) == NULL) break;

    fprintf(out,"%d  %d  %d    ", ii, jj, kk);
    if (do_xzy)  xzy = 3;
    else         xzy = 0;
    fprintf(out,"%d  ", xzy);
    if (!do_data) dd = 0;
    fprintf(out,"%d ", dd);
    fprintf(out,"\n");

    if (do_xzy) fprintf(out,"X   Y   Z   ");
    for (d = 1; d <= dd; d++) 
      fprintf(out,"%s   ", lat3->data_names[d-1] );
    fprintf(out,"\n");

    for (i = 1; i <= ii; i++)
    for (j = 1; j <= jj; j++)
    for (k = 1; k <= kk; k++) {
      if (do_xzy) {
	VLAT (lat3, LP(x), YGETDATA, i, j, k, 1);
	VLAT (lat3, LP(y), YGETDATA, i, j, k, 2);
	VLAT (lat3, LP(z), YGETDATA, i, j, k, 3);
	fprintf(out,"%f %f %f    ", x, y, z);
      }
      for (d = 1; d <= dd; d++) {
	VLAT (lat3, LP(data), YGETDATA, i,j,k, 3+d);
	fprintf(out,"%f ", data);
      }
      fprintf(out," \n");
    }

    fclose(out);
    break;
  case YBINARY:
    break;
  case YGETSIZE:
    MYSIZE_IS (W_MOD, H_MOD);
    break;
  case YOPEN:
    YDrawRectF (0, 0, WND->w, WND->h, WIN->color);
    YDrawStrings (text, 25, 20);

    YWnd (&hFname, EDIT, "Fname = ", 100,50, 100,20, (long)fname,75,0,0, CLR_DEF);

    YBeginGroup ("type", 20,100, 120,65, YColor(""));
    YWnd (Ph(), CHECK, "ascii ", 15,10, 20,20, 0,LP(do_asc),0,0, CLR_DEF);
    YWnd (Ph(), CHECK, "binary", 15,40, 20,20, 0,LP(do_bin),0,0, CLR_DEF);
    YEndGroup ();

    YBeginGroup ("format", 160,100, 120,65, YColor(""));
    YWnd (Ph(), CHECK, "xzy-coord", 15,10, 20,20, 0,LP(do_xzy), 0,0, CLR_DEF);
    YWnd (Ph(), CHECK, "data",      15,40, 20,20, 0,LP(do_data),0,0, CLR_DEF);
    YEndGroup ();

    break;
  case YCLOSE:
    YWndClean (id);
    break;
  default: ;;;
  }

  RETURN_TRUE;
}

/*---------------------------VSetkaSetSizes---------------------------------*/
void
VSetkaSetSizes (VT_SETKA *setka_old, int uu_new, int vv_new)
{
  int   i,j, iold,jold;
  YT_SPACE u_step, v_step;
  VT_SETKA setka_new = {NULL};
  int uu_old = setka_old->uu;
  int vv_old = setka_old->vv;
  VT_P3D *p_old, *p_new;

  if (uu_new >= uu_old || vv_new >= vv_old) return;
  u_step = (uu_old-1)/(uu_new-1);
  v_step = (vv_old-1)/(vv_new-1);

  VSetkaInit(&setka_new, uu_new, vv_new);  

  for (i = 0; i < uu_new; i++) 
  for (j = 0; j < vv_new; j++) {
    iold = YInt(i*u_step);
    jold = YInt(j*v_step);

    p_old = VSetkaPts(setka_old, iold, jold);
    p_new = VSetkaPts(&setka_new, i, j);
    memcpy(p_new, p_old, sizeof(VT_P3D));
  }

  setka_old->uu  = uu_new;
  setka_old->vv  = vv_new;
  free(setka_old->pts);
  setka_old->pts = setka_new.pts;

  return;
}
/*---------------------------VSetkaFromLat3---------------------------------*/
void
VSetkaFromLat3 (VT_SETKA *setka, VT_LAT *lat3)
{
  int   i,j, ii,jj;
  YT_SPACE x, y, z;

  VLAT (lat3, 0, YBEGIN, 1,0,0, 0);

  VLAT (lat3, 0, YSIZE, LP(ii), LP(jj), 0, 0);
  VSetkaInit(setka, ii,jj);  

  for (i = 1; i <= ii; i++) 
  for (j = 1; j <= jj; j++) {
    VLAT (lat3, LP(x), YGETDATA, i, j, 0, 1);
    VLAT (lat3, LP(y), YGETDATA, i, j, 0, 2);
    VLAT (lat3, LP(z), YGETDATA, i, j, 0, 3);
    /* fprintf(Y_STDERR,"%f %f %f \n",x,y,z);  */   
    (VSetkaPts(setka, i-1, j-1))->x = x;
    (VSetkaPts(setka, i-1, j-1))->y = y;
    (VSetkaPts(setka, i-1, j-1))->z = z;
  }

  VLAT (lat3, 0, YEND, 0,0,0, 0);

}
/*------------------------------mOBJ3D--------------------------------------*/
long
mOBJ3D (PFUNC_VAR)
{
  typedef struct {
    ABCD;
  } YT_USR;
  enum keys {
    MAKE_MISC1 = YKEY_LOCALS, MAKE_MISC2, MAKE_MISC3, MAKE_MISC4
  };

  static VT_OBJ3D obj;
  static YT_BOOL is_color_setka, is_black_setka, misc1, misc2, misc3, misc4,
          isSURF, isKLEY, do_slice;
  static YT_SPACE delta_slice;
  static YT_COLOR color_setka;
  static YT_COLOR color1, color2, color3, color4;
  static VT_CPOINT v1 =
  {0, 0, 0}, v2 =
  {0, 1, 0}, v3 =
  {1, 0, 0,}, v4 =
  {0, 0, 1};
  static YT_COLOR white, black;
  static VT_PLINE3D rebra[6] =
  {
    {&v1, &v2, &black},
    {&v1, &v3, &black},
    {&v1, &v4, &black},
    {&v2, &v3, &white},
    {&v3, &v4, &white},
    {&v4, &v2, &white},
  };
  static VT_PLINE3D lines[2] =
  {
    {&v1, &v2, &black},
    {&v1, &v3, &white},
  };
  static VT_PTRI3D grani[4] =
  {
    {&v1, &v2, &v3, &color1, &black},
    {&v1, &v3, &v4, &color2, &black},
    {&v1, &v4, &v2, &color3, &black},
    {&v2, &v3, &v4, &color4, &black},
  };

  char   *text[] =
  {
    "This module prepares test data ",
    "(objects 3D-stage) for their subsequent",
    "rendering.",
    NULL
  };
  static int mod_setka, hSlice;
  static  VT_SETKA  setka;
  static  VT_P3D *pts;
  static  int     uu, vv;

  YT_COLOR color;
  VT_SURF *surf;
  VT_PLANE plane;
  VT_P3D  p1, p2, p3;
/*   YT_BOOL *visible; */
/*   VT_SURF *nsurf; */

  switch (message) {
  case YCREATE:
    U_MALLOC;
    WND->name = "OBJ3D";
    is_color_setka = TRUE;
    is_black_setka = TRUE;
    color_setka    = YColor("yellow");
    white    = YColor("white");
    black    = YColor("black");
    misc1    = FALSE;
    misc2    = FALSE;
    misc3    = FALSE;
    misc4    = TRUE;
    isSURF   = TRUE;
    isKLEY   = FALSE;
    do_slice = FALSE;
    delta_slice = 0.5;

    YWndCreate (&mod_setka, mSetka, NULL, 0, 0, 0, 0);
    break;
  case MM_APPLY:
  case YAPPLY:
    if      (misc1) YGoto (MAKE_MISC1, 0, 0, 0, 0);
    else if (misc2) YGoto (MAKE_MISC2, 0, 0, 0, 0);
    else if (misc3) YGoto (MAKE_MISC3, 0, 0, 0, 0);
    else if (misc4) {
      setka.pts = NULL;
      YGoto (MAKE_MISC4, 0, 0, 0, 0);
      YAlgCall (mod_setka, YSEND2FACE,  MM_SETKA, 0, 0, 0, LP(setka)); 
    }
    YAlgOut (YSEND2FACE, MM_OBJ3D_ADD,  0, 0, 0, LP(obj));
    break;
  case MAKE_MISC1:
    V3ObjInit (&obj, "VPLINES3D", "", NULL, (long)rebra, 6, 0, 0);
    break;
  case MAKE_MISC2:
    color1 = YScale (2);
    color2 = YScale (YGet("size_scale") / 3);
    color3 = YScale (YGet("size_scale") / 2);
    color4 = YScale (YGet("size_scale") - 2);
    V3ObjInit (&obj, "VPTRIS3D", "", NULL, (long)grani, 4, 0, 0);
    break;
  case MAKE_MISC3:
    V3ObjInit (&obj, "VPLINES3D", "", NULL, (long)lines, 2, 0, 0);
    break;
  case YOUTPUT:
  case MAKE_MISC4:
    pts = setka.pts;
    uu  = setka.uu;
    vv  = setka.vv;

    if (is_color_setka) color = color_setka;
    else                color = CLR_NULL;

    if (isSURF) {
      surf = VSurfFromSetka (&setka, isKLEY, -1);


      if (do_slice) {
	VSetPoint3D (&p1, 0, 0, 0);
	VSetPoint3D (&p2, 1, 0, 0);
	VSetPoint3D (&p3, 0, 1, 0);
	VPlaneFromTri (&p1, &p2, &p3, &plane);
	YGetData (hSlice);
	surf = VSurfSlice (surf, &plane, delta_slice);
      }

      V3ObjInit (&obj, "VSURF", "",  surf, 0, 0, color, is_black_setka);
      
    } else {
      V3ObjInit (&obj, "VSETKA3D", "", pts, uu, vv, color, is_black_setka);
    }

    break;
  case YGETSIZE:
    MYSIZE_IS (W_MOD, H_MOD);
    break;
  case YOPEN:
  case YDRAW:
    YDrawRectF (0, 0, WND->w, WND->h, WIN->color);
    YDrawStrings (text, 20, 20);

    YBeginGroup ("Objects", 10,90, 120,130, YColor(""));
    YWndGroupBegin ();
    YWnd (Ph(), CHECK, "Prism-1",  10,15, 20,20, 0,LP(misc1),0,0, CLR_DEF);
    YWnd (Ph(), CHECK, "Prism-2",  10,40, 20,20, 0,LP(misc2),0,0, CLR_DEF);
    YWnd (Ph(), CHECK, "Two lines",10,65, 20,20, 0,LP(misc3),0,0, CLR_DEF);
    YWnd (Ph(), CHECK, "Surface",  10,90, 20,20, 0,LP(misc4),0,0, CLR_DEF);
    YWndGroupEnd ();
    YEndGroup ();

    YBeginGroup ("Surface", 140,90, 150,140, YColor(""));
    YWnd (Ph(), COLORS, "Color",  15, 15, 35,20, LP(color_setka), 0, 0, 0,      CLR_DEF);
    YWnd (Ph(), MODPUSH, "",      15, 40, 70,20, mod_setka, 0, 0, 0,            CLR_DEF);
    YWnd (Ph(), CHECK, "to SURF", 15, 65, 20,20, 0, LP(isSURF), 0, 0,           CLR_DEF);
    YWnd (Ph(), CHECK, "kleying", 15, 85, 20,20, 0, LP(isKLEY), 0, 0,           CLR_DEF);
    YWnd (Ph(), CHECK, "",        15,110, 20,20, 0, LP(do_slice), 0, 0,         CLR_DEF);
    YWnd (&hSlice, FLOATS, "",    45,110, 45,20, LP(delta_slice), YSPACE, 0, 0, CLR_DEF);

    YEndGroup ();
    break;
  case YCLOSE:
    YWndClean (id);
    break;
  default:
    if (MM_FORWARD)  YAlgOut (YSEND2FACE, message,  mes1, mes2, mes3, mes4);
  }

  RETURN_TRUE;
}
/*------------------------------D3_PointToAxeZ------------------------------*/
void 
D3_PointToAxeZ (YT_SPACE x, YT_SPACE y, YT_SPACE z, 
		YT_SPACE *palfa, YT_SPACE *pbeta, YT_SPACE *pz)
{
  YT_SPACE alfa=0, beta=0;

  /* fprintf (stderr, "%f %f %f \n", alfa, beta, z); */

  if (z == 0)  alfa = YPI/2;
  else         alfa = atan (-y/z);
  D3_RotateOX (alfa, &x, &y, &z);
  y = 0;

  /* fprintf (stderr, "%f %f %f \n", alfa, beta, z); */


  if (z == 0)  beta = YPI/2;
  else         beta = atan (x/z);
  D3_RotateOY (beta, &x, &y, &z);

  *palfa = alfa;
  *pbeta = beta;
  *pz = z;

  /* fprintf (stderr, "%f %f %f \n", alfa, beta, z); */
  return;
}
/*----------------------------D3_IsPointVis-----------------------------------*/
YT_BOOL
D3_IsPointVis (VT_CAM3D *cam3d, YT_SPACE x, YT_SPACE y, YT_SPACE z, YT_COLOR color)
{
  int     n, m;
  YT_SPACE zz;

  if (!ZBUFF_flag) YError ("IsPointVis");

/*   if (zz < ZBUFF_zplane)   */
  if (z < ZBUFF_zplane)  
    return (TRUE);

  D3_PointToScreen (cam3d, x, y, z, &n, &m, &zz);

  if (!(n >= 1 && m >= 1 && n <= ZBUFF_w && m <= ZBUFF_h))  
    return (TRUE);

  if (zz > ZBUFF_val (n, m))  
    return (FALSE);

  return (TRUE);
}
/*-----------------------------IsvisPoints----------------------------------*/
YT_BOOL
IsvisPoints (VT_OBJ3D *pobj, VT_P3D *s, VT_P3D *t)
{

  static VT_W3D *w3d;
  static VT_CAM3D *cam3d;
  YT_SPACE  alfa, beta, zview;
  int  scrw, scrh;

  if (s && !t) { /* ------ begin work ------ */
    if (!(W3D (&(w3d), 0, YCONSTR0, 0, 0, 0, 0)))  YError ("W3D-CONSTR");
    cam3d = w3d->cam3d;

    D3_PointToAxeZ (s->x, s->y, s->z, &alfa, &beta, &zview);
    D3_SetRotate (cam3d, GRAD(alfa), GRAD(beta));

    cam3d->repers = 0;

    D3_WorldAddTo (w3d, pobj); 

    cam3d->zview = zview;
    cam3d->zview_flag = TRUE;
    D3_SetMinmax (w3d);
    /* cam3d->zplane = zview + 0.5; */
    cam3d->zplane = (zview + SSS.zmin3d)/2;
    
    scrw = 100;
    scrh = (cam3d->h * scrw) / cam3d->w; 
    D3_Viewport (cam3d, 0, 0, scrw, scrh);

    D3_ZbufBegin (cam3d->scrw, cam3d->scrh);
    D3_DrawAll (w3d);
  }


  if (s && t)   { /* ------ main work ------ */
    return (D3_IsPointVis (cam3d, t->x, t->y, t->z, YColor("black")));
  }

  if (!s && !t) { /* ------ end work  ------ */

    /*     D3_ZbufEnd (); */
    /*     W3D (&(w3d), 0, YDESTRU0, 0, 0, 0, 0); */  /* !! to separate parameters */

  }


  return (TRUE);
}
/*------------------------------mIsVis--------------------------------------*/
long
mIsVis (PFUNC_VAR)
{
  typedef struct {
    ABCD;
  } YT_USR;
  enum keys {
    MAKE_MISC1 = YKEY_LOCALS, MAKE_MISC2, MAKE_MISC3, MAKE_MISC4
  };

  static VT_OBJ3D obj, obj_mark, obj_s, obj_t, obj_tar;
  static YT_BOOL  is_color_setka, is_black_setka, isKLEY;
  static YT_COLOR color_setka;
  static VT_SETKA setka, setka_tar;

  YT_COLOR color;
  VT_SURF *surf;
  static int uu_tar, vv_tar, num_min = 3, num_max = 200;
  static YT_BOOL multi_t, my_method;

  static  VT_P3D *vis, *vis_cur;
  int u, v, num;
  static  VT_P3D s, *t, tar;
  static YT_SPACE s_x, s_y, s_z,  t_x, t_y, t_z, r_tar, r_sph, size_mark;
  static int  h_s_x, h_s_y, h_s_z,  h_t_x, h_t_y, h_t_z, h_r_tar, h_r_sph;
  static int  uu_sph, vv_sph;

/*   static VT_W3D *w3d; */
/*   VT_CAM3D *cam3d; */
/*   YT_SPACE  alfa, beta, zview; */

  switch (message) {
  case YCREATE:
    U_MALLOC;
    WND->name = "IsVis";

    is_color_setka = TRUE;
    is_black_setka = FALSE;
    color_setka    = YColor("yellow");
    isKLEY   = FALSE;
    s_x = 2.0;
    s_y = 0.5;
    s_z = 0.0;
    t_x = -1.0;
    t_y =  1.0;
    t_z =  0.0;
    multi_t = TRUE;
    r_tar = 0.8;
    r_sph = 0.7;

    uu_tar = 11;
    vv_tar = 11;
    uu_sph = 11;
    vv_sph = 11;

    my_method = TRUE;
    break;
  case MM_APPLY:
  case YAPPLY:
    YAlgOut (YSEND2FACE, MM_CLEAR_ALL,  0, 0, 0, 0);

    YGetData (h_s_x);
    YGetData (h_s_y);
    YGetData (h_s_z);
    YGetData (h_r_tar);
    YGetData (h_t_x);
    YGetData (h_t_y);
    YGetData (h_t_z);
    YGetData (h_r_sph);
    size_mark = r_tar / (uu_tar+vv_tar);

    VSetPoint3D (&s, s_x, s_y, s_z);
    V3ObjInit (&obj_s, "MARKERS", "", &s, 1, YCUBE, LP(size_mark), YColor("blue"));
    YAlgOut (YSEND2FACE, MM_OBJ3D_ADD,  0, 0, 0, LP(obj_s));
    
    if (multi_t) {
      setka_tar.pts = NULL;
      VSetkaMakeTest (&setka_tar, 0, uu_tar, vv_tar, r_tar);
      V3ObjInit (&obj_tar, "VSETKA3D", "", setka_tar.pts, uu_tar, vv_tar, CLR_NULL, TRUE);
      YAlgOut (YSEND2FACE, MM_OBJ3D_ADD,  0, 0, 0, LP(obj_tar));
    } else {
      VSetPoint3D (&tar, t_x, t_y, t_z);
      color = YColor("red");
      V3ObjInit (&obj_t, "MARKERS", "", &tar, 1, YCUBE, LP(size_mark), color);
      YAlgOut (YSEND2FACE, MM_OBJ3D_ADD,  0, 0, 0, LP(obj_t));
    }

    setka.pts = NULL;
    VSetkaMakeTest (&setka, 0, uu_sph, vv_sph, r_sph);
    surf = VSurfFromSetka (&setka, isKLEY, -1);
    if (is_color_setka) color = color_setka;
    else                color = CLR_NULL;
    V3ObjInit (&obj, "VSURF", "",  surf, 0, 0, color, is_black_setka);
    YAlgOut (YSEND2FACE, MM_OBJ3D_ADD,  0, 0, 0, LP(obj));
      
    if (multi_t) {
      if (!(vis = (VT_P3D *) malloc (uu_tar*vv_tar*sizeof(VT_P3D)))) YError ("009");
      vis_cur = vis;
      num     = 0;

      if (!my_method) {
	IsvisPoints (&obj, &s, NULL);
      }

      for (u = 0; u < uu_tar; u++) 
      for (v = 0; v < vv_tar; v++) {
	t = VSetkaPts (&setka_tar, u, v);

	if (my_method) {
	  if (!VSurfIsvisPoint (surf, &s, t, -1))  continue;
	} else {
	  if (!IsvisPoints (NULL, &s, t))  continue;
	}

	memcpy (vis_cur, t, sizeof (VT_P3D));
	vis_cur++; num++;
      }
      V3ObjInit (&obj_mark, "MARKERS", "", vis, num, YCUBE, LP(size_mark), YColor("red"));
      YAlgOut (YSEND2FACE, MM_OBJ3D_ADD,  0, 0, 0, LP(obj_mark));

      if (!my_method) {
	IsvisPoints (NULL, NULL, NULL);
      }
   }

    break;
  case YGETSIZE:
    MYSIZE_IS (W_MOD, H_MOD);
    break;
  case YOPEN:
  case YDRAW:
    YDrawRectF (0, 0, WND->w, WND->h, WIN->color);

    YBeginGroup ("Source", 10,10, 140,40, YColor(""));
    YWnd (&h_s_x, FLOATS, "",     10,10, 40,20, LP(s_x), YSPACE, 0, 0,   CLR_DEF);
    YWnd (&h_s_y, FLOATS, "",     50,10, 40,20, LP(s_y), YSPACE, 0, 0,   CLR_DEF);
    YWnd (&h_s_z, FLOATS, "",     90,10, 40,20, LP(s_z), YSPACE, 0, 0,   CLR_DEF);
    YEndGroup ();

    YBeginGroup ("Target", 10,60, 140,100, YColor(""));
    YWnd (&h_t_x, FLOATS,  "",    10,10, 40,20, LP(t_x),YSPACE,0,0, CLR_DEF);
    YWnd (&h_t_y, FLOATS,  "",    50,10, 40,20, LP(t_y),YSPACE,0,0, CLR_DEF);
    YWnd (&h_t_z, FLOATS,  "",    90,10, 40,20, LP(t_z),YSPACE,0,0, CLR_DEF);

    YWnd (Ph(),   CHECK,   "",    20,45, 20,20, 0,LP(multi_t),0,0, CLR_DEF);
    YWnd (Ph(),   DECIMAL, "",    55,45, 35,20, 0,num_min,num_max,LP(uu_tar), CLR_DEF);
    YWnd (Ph(),   DECIMAL, "",    90,45, 35,20, 0,num_min,num_max,LP(vv_tar), CLR_DEF);

    YWnd (&h_r_tar, FLOATS, "r_tar = ", 70,70, 45,20, LP(r_tar),YSPACE,0,0, CLR_DEF);
    YEndGroup ();

    YBeginGroup ("Algo", 10,170, 140,60, YColor(""));
    YWnd (Ph(), CHECK, "my_method", 10,10, 20,20, 0,LP(my_method),0,0, CLR_DEF);
    YEndGroup ();

    YBeginGroup ("Polu-Sphere", 160,20, 145,120, YColor(""));
    YWnd (Ph(),     DECIMAL, "", 10,10, 35,20, 0,num_min,num_max,LP(uu_sph), CLR_DEF);
    YWnd (Ph(),     DECIMAL, "", 45,10, 35,20, 0,num_min,num_max,LP(vv_sph), CLR_DEF);
    YWnd (&h_r_sph, FLOATS, "",  85,10, 45,20, LP(r_sph),YSPACE,0,0, CLR_DEF);

    YWnd (Ph(), COLORS, "Color",  15, 60, 35,20, LP(color_setka), 0, 0, 0, CLR_DEF);
    YWnd (Ph(), CHECK, "kleying", 15, 85, 20,20, 0, LP(isKLEY), 0, 0,      CLR_DEF);
    YEndGroup ();

    break;
  case YCLOSE:
    YWndClean (id);
    break;
  default:
    if (MM_FORWARD)  YAlgOut (YSEND2FACE, message,  mes1, mes2, mes3, mes4);
  }

  RETURN_TRUE;
}
/*-----------------------------------mSetka----------------------------------*/
long
mSetka (PFUNC_VAR)
{
  typedef struct {
    ABCD;
  } YT_USR;

  static int num_u = 11, num_v = 11, num_min = 5, num_max = 100;
  static int hSetka;
  static int sel = 1;
  static char *setka_names[] =
  {" Polu-Sphere", " Simple sphere", " Exponenta", " Sinusoida",
   " Moebius band",  
   " Kuen's Surface", " Pinched Torus",  
   NULL};

  char   *text[] =
  {
    "The module prepares test regular ",
    "grid surfaces, set in a parametrical",
    "kind.", 
    NULL
  };
  static VT_SETKA *setka;

  switch (message) {
  case YCREATE:
    U_MALLOC;
    WND->name = "Setka";
    setka = NULL;
    break;
/*   case MM_FORWARD: */
/*     break; */
  case MM_APPLY:
    YGoto (YMAKE, 0, 0, 0, 0);
    break;
  case MM_SETKA:
    setka = (VT_SETKA *)PDATA;
    YGoto (YMAKE, 0, 0, 0, 0);
    break;
  case YMAKE:
    if (!setka) break;
    VSetkaMakeTest (setka, sel-1, num_u,num_v, 0);
    YAlgOut (YSEND2FACE, MM_SETKA,  0, 0, 0, (long)setka); 
    break;
  case YGETSIZE:
    MYSIZE_IS (W_MOD, H_MOD);
    break;
  case YOPEN:
  case YDRAW:
    YDrawRectF (0, 0, WND->w, WND->h, WIN->color);
    YDrawStrings (text, 20, 20);

    YBeginGroup ("", 20,70, 170,150, YColor(""));
    YWnd (&hSetka, LIST, "", 10,10, 150,80, (long)setka_names,0,LP(sel),0, CLR_DEF);
    YWnd (Ph(), DECIMAL, "Num_U: ", 70,95, 40,20, 0,num_min,num_max,LP(num_u), CLR_DEF);
    YWnd (Ph(), DECIMAL, "Num_V: ",70,120, 40,20, 0,num_min,num_max,LP(num_v), CLR_DEF);
    YEndGroup ();
    break;
  case YCLOSE:
    YWndClean (id);
    break;
  default: ;;;
  }

  RETURN_TRUE;
}

/*------------------------------mLat3d--------------------------------------*/
long
mLat3d (PFUNC_VAR)
{
  typedef struct {
    ABCD;
  } YT_USR;
  static YT_BOOL func0 = TRUE, func1 = TRUE;
  static char *names[2] = {
    "x^2+y^2+z^2",
    "x*exp(x^2-...)",
  };
  static int ii, jj, kk, dd, ii_man, jj_man, kk_man;
  static char *data_names[10];
  static int one = 1, sto = 100;
  char   *text[] =
  {
    "Creation test 3D-latice data. And also",
    "demonstration some control elements:",
    NULL
  };
  static YT_SPACE xmin, ymin, zmin;
  static YT_SPACE xstep, ystep, zstep;
  static YT_SPACE x, y, z, data;
  int     i, j, k, d;
  static void *lat;

  static long fname = 0;
  static int hFname;
  static char Fname[20];

  static int sel = 1, hList;
  static char *list_names[] =
  {" string_01", " string_02", " string_03", " string_04",
   " string_05", " string_06", " string_07", " string_08",
   " string_09", " string_10", " string_11", " string_12",
   NULL};

  switch (message) {
  case YCREATE:
    U_MALLOC;
    WND->name = "Lat3d";
    ii_man = 30;
    jj_man = 20;
    kk_man = 10;
    strcpy (Fname, "testname");
    break;
/*   case MM_FORWARD: */
/*     break; */
  case MM_APPLY:
    YGoto (YAPPLY, 0, 0, 0, 0);
    break;
  case YAPPLY:
    lat = NULL;
    xmin = ymin = zmin = 0;
    xstep = ystep = zstep = 0.1;
    ii = ii_man;
    jj = jj_man;
    kk = kk_man;

    dd = 0;
    if (func0) data_names[dd++] = names[0];
    if (func1) data_names[dd++] = names[1];
    data_names[dd] = NULL;
    if (dd == 0) {
      YMessageBox ("Where are data ?", "OK");
      return (FALSE);
    }
    VLAT (lat, 0, YDESTRU0, 0, 0, 0, 0);
    VLAT (&lat, 3, YCONSTR0, ii, jj, kk, dd);
    VLAT (lat, 0, YNAMES, 0, 0, 0, (long)data_names);

    YGoto (YMAKE, 0, 0, 0, 0);

    YAlgOut (YSEND2FACE, MM_LAT3,  0, 0, 0, (long)lat);
    break;
  case YMAKE:
    YMouseForm ("wait");
    for (i = 1; i <= ii; i++) 
    for (j = 1; j <= jj; j++) 
    for (k = 1; k <= kk; k++) {
      x = xmin + xstep * (i - 1);
      y = ymin + ystep * (j - 1);
      z = zmin + zstep * (k - 1);
      if (!(i == 1 || i == ii)) x = YRandF (x - xstep / 2, x + xstep / 2);
      if (!(j == 1 || j == jj)) y = YRandF (y - ystep / 2, y + ystep / 2);
      if (!(k == 1 || k == kk)) z = YRandF (z - zstep / 2, z + zstep / 2);
      
      VLAT (lat, LP(x), YPUTDATA, i, j, k, 1);
      VLAT (lat, LP(y), YPUTDATA, i, j, k, 2);
      VLAT (lat, LP(z), YPUTDATA, i, j, k, 3);
      
      d = 4;
      if (func0) {
	data = x * x + y * y + z * z;
	VLAT (lat, LP(data), YPUTDATA, i, j, k, d++);
      }
      if (func1) {
	data = x * ((YT_SPACE) exp ((double) (-(x * x) - (y * y) - (z * z))));
	VLAT (lat, LP(data), YPUTDATA, i, j, k, d++);
      }
    }
    YMouseForm ("arrow");
    return (TRUE);
  case YGETSIZE:
    MYSIZE_IS (W_MOD, H_MOD);
    break;
  case YOPEN:
  case YDRAW:
    YDrawRectF (0, 0, WND->w, WND->h, WIN->color);
    YDrawStrings (text, 10, 20);

    YBeginGroup ("Functions", 10,55, 160,65, YColor(""));
    YWnd (Ph(), CHECK, names[0], 10,10, 20,20, 0,LP(func0),0,0, CLR_DEF);
    YWnd (Ph(), CHECK, names[1], 10,35, 20,20, 0,LP(func1),0,0, CLR_DEF);
    YEndGroup ();

    YBeginGroup ("II_JJ_KK", 180,55, 125,65, YColor(""));
    YWnd (Ph(), DECIMAL, "",  5,20, 35,20, 0,one,sto,LP(ii_man), CLR_DEF);
    YWnd (Ph(), DECIMAL, "", 45,20, 35,20, 0,one,sto,LP(jj_man), CLR_DEF);
    YWnd (Ph(), DECIMAL, "", 85,20, 35,20, 0,one,sto,LP(kk_man), CLR_DEF);
    YEndGroup ();

    YBeginGroup ("Demo", 10,130, 290,100, YColor(""));
    YWnd (Ph(),    PUSH, "Fail", 10,65, 55,20, 0,0,0,0, CLR_DEF);
    YWnd (&hFname, EDIT,  "",   70,65, 90,20, (long)Fname,0,0,0, CLR_DEF);
    YWnd (&hList,  LIST,  "",  170,10, 110,80, (long)list_names,0,LP(sel),0, CLR_DEF);
    YEndGroup ();
    break;
  case YPUSH:
    if (!(fname = YFindFile ()))
      break;
    strcpy (Fname, (char *) fname);
    YWndUpdate (hFname);
    break;
  case YRPUSH:
    YMessageBox ((char *) YGetData (hFname), "OK");
    break;
  /* case YDATAMADE: */
  case YLIST:
    /* if (mes1 != hList) */
/*       break; */
    YMessageBox (list_names[YGetData(hList)-1], "OK");
    break;
  case YCLOSE:
    YWndClean (id);
    break;
  default: ;;;
  }

  RETURN_TRUE;
}
/*-----------------------------mR_LAT---------------------------------------*/
long
mR_LAT (PFUNC_VAR)
{
  typedef struct {
    ABCD;
  } YT_USR;
  char   *text[] = {
    "Read 3D-latice data from file : ",
    "................................",
    NULL
  };
  static VT_LAT *lat3;
  int   i,j,k,d, ii,jj,kk,dd, xzy,l;
  FILE *in;
  /* static long ret; */
  static int hFname;
  static char fname[80];
  static YT_BOOL w_open=FALSE;

  YT_SPACE x,y,z,data;
  float   f[10];
  char    sh[10][40];
  static YT_BOOL do_bin=FALSE, do_asc=TRUE;

#define S_LEN 80
  char s[S_LEN];

  switch (message) {
  case YCREATE:
    U_MALLOC;
    WND->name = "R_LAT";
    strcpy (fname, "latice.dat"); 
    break;
  case MM_APPLY:
    if (w_open) YGetData(hFname);
    YGoto (YMAKE, 0, 0, 0, 0);
    break;
  case YMAKE:
    if      (do_asc)  YGoto (YASCII, 0,0,0, 0);
    else if (do_bin)  YGoto (YBINARY, 0,0,0, 0);
    YAlgOut (YSEND2FACE, MM_LAT3,  0, 0, 0, (long)lat3);
    break;
  case YASCII:
    if ((in=fopen(fname,"r")) == NULL) break;

    fgets(s, S_LEN, in);
    sscanf(s, "%d %d %d %d %d ", &ii, &jj, &kk, &xzy, &dd);
    VLAT (&lat3, 3, YCONSTR0, ii, jj, kk, dd);  /* ?? */

    fgets(s, S_LEN, in);
    sscanf(s, "%s %s %s %s %s %s %s %s %s %s ", 
	   &sh[0][0],&sh[1][0],&sh[2][0],&sh[3][0],&sh[4][0],
	   &sh[5][0],&sh[6][0],&sh[7][0],&sh[8][0],&sh[9][0] ); 
    if (xzy) l = 3;
    else     l = 0;
    for (d = 1; d <= dd; d++) 
      strcpy (lat3->data_names[d-1] , &sh[l++][0]); 
    lat3->data_names[d-1] = NULL;

    for (i = 1; i <= ii; i++)
    for (j = 1; j <= jj; j++)
    for (k = 1; k <= kk; k++) {
      fgets(s, S_LEN, in);
      sscanf(s, "%f %f %f %f %f %f %f %f %f %f ", 
	     &f[0], &f[1], &f[2], &f[3], &f[4], &f[5], &f[6], &f[7], &f[8], &f[9] ); 
      l = 0;
      if (xzy) {
	x = f[l++];
	y = f[l++];
	z = f[l++];
	VLAT (lat3, LP(x), YPUTDATA, i, j, k, 1);
	VLAT (lat3, LP(y), YPUTDATA, i, j, k, 2);
	VLAT (lat3, LP(z), YPUTDATA, i, j, k, 3);
      }
      for (d = 0; d < dd; d++) {
	data = f[l+d];
	VLAT (lat3, LP(data), YPUTDATA, i,j,k, 4+d);
      }
    }

    fclose(in);
    break;
  case YBINARY:
    break;
  case YGETSIZE:
    MYSIZE_IS (W_MOD, H_MOD);
    break;
  case YOPEN:
    w_open=TRUE;
  case YDRAW:
    YDrawRectF (0, 0, WND->w, WND->h, WIN->color);
    YDrawStrings (text, 30, 30);

    YWnd (&hFname, EDIT, "Fname = ", 100,80, 100,20, (long)fname,75,0,0, CLR_DEF);
    break;
  case YCLOSE:
    w_open=FALSE;
    YWndClean (id);
    break;
/*   default: ;;; */
  default:
    if (MM_FORWARD)  YAlgOut (YSEND2FACE, message,  mes1, mes2, mes3, mes4);
  }

  RETURN_TRUE;
}
/*------------------------------mMLAT---------------------------------------*/
long
mMLAT (PFUNC_VAR)
{
  typedef struct {
    ABCD;
  } YT_USR;

#define FUNC_NUM 9
  static YT_BOOL func[FUNC_NUM] = 
  {
    FALSE, TRUE, FALSE, FALSE, TRUE, FALSE
  };
  static char *allnames[FUNC_NUM] = {
    "x",
    "x^2+y^2+",
    "exp(...",
    "x^2-y^2",
    "x+y",
    "1/(x+y)",
    "..+RAND",
    "sin(x)",
    "sin*cos"
  };
  static YT_BOOL size1, size3, size5;
  static int ii, jj, kk, ii_man, jj_man, kk_man;
  static char *data_names[10];
  static int one = 1, sto = 100;
  char   *text[] =
  {
   "Creation test latice data:",
    NULL
  };
  int     xi, yi;
  static int izm = 3, izm_min = 1, izm_max = 3;
  static YT_SPACE xmin, ymin, zmin;
  static YT_SPACE xstep, ystep, zstep;
  int     i, j, k, d, fi;
  static YT_SPACE x, y, z, data;
  static void *lat;
  static VT_PARS pars[] = {
    {"bool", "size1",  "FALSE"},
    {"bool", "size3",  "TRUE"},  
    {"bool", "size5",  "FALSE"}, 
    {"int",  "ii_man", "10   "}, 
    {"int",  "jj_man", "10   "}, 
    {"int",  "kk_man", "10   "}, 
    {NULL}
  };

  switch (message) {
  case YCREATE:
    U_MALLOC;
    WND->name = "MLAT";
/*     YAlgParam (&pars[0], "size1",  &size1, NULL); */
/*     YAlgParam (&pars[0], "size3",  &size3, NULL); */
/*     YAlgParam (&pars[0], "size5",  &size5, NULL); */
/*     YAlgParam (&pars[0], "ii_man", &ii_man, NULL); */
/*     YAlgParam (&pars[0], "jj_man", &jj_man, NULL); */
/*     YAlgParam (&pars[0], "kk_man", &kk_man, NULL); */

    PAR_INIT ("size1",  &size1);
    PAR_INIT ("size3",  &size3);
    PAR_INIT ("size5",  &size5);
    PAR_INIT ("ii_man", &ii_man);
    PAR_INIT ("jj_man", &jj_man);
    PAR_INIT ("kk_man", &kk_man);

    break;
/*   case MM_FORWARD: */
/*     break; */
  case MM_APPLY:
    YGoto (YAPPLY, 0, 0, 0, 0);
    break;
  case YAPPLY:
    lat = NULL;
    xmin = ymin = zmin = 0;
    xstep = ystep = zstep = 0.1;

    if (size1) {
      ii = 100;
      jj = 90;
      kk = 80;
    } else if (size3) {
      ii = 30;
      jj = 20;
      kk = 10;
    } else if (size5) {
      ii = ii_man;
      jj = jj_man;
      kk = kk_man;
    }

    for (d = 0, fi = 0; fi < FUNC_NUM; fi++)
      if (func[fi]) 
	data_names[d++] = allnames[fi];

    data_names[d] = NULL;
    if (d == 0) {
      YMessageBox ("Don't DATA !", "OK");
      return (FALSE);
    }

    VLAT (lat, 0, YDESTRU0, 0, 0, 0, 0);
    VLAT (&lat, izm, YCONSTR0, ii, jj, kk, d);
    VLAT (lat, 0, YNAMES, 0, 0, 0, (long)data_names);

    YGoto (YMAKE, 0, 0, 0, 0);

    if      (izm == 3) YAlgOut (YSEND2FACE, MM_LAT3,  0, 0, 0, (long)lat);
    else if (izm == 2) YAlgOut (YSEND2FACE, MM_LAT2,  0, 0, 0, (long)lat);
    else if (izm == 1) YAlgOut (YSEND2FACE, MM_LAT1,  0, 0, 0, (long)lat);
    break;
  case YMAKE:
    YMouseForm ("wait");
    for (i = 1; i <= ii; i++) 
    for (j = 1; j <= jj; j++) 
    for (k = 1; k <= kk; k++) {
      if (izm == 2 && k != 1)             continue;
      if (izm == 1 && (k != 1 || j != 1)) continue;
      
      x = xmin + xstep * (i - 1);
      y = ymin + ystep * (j - 1);
      z = zmin + zstep * (k - 1);
      if (!(i == 1 || i == ii)) x = YRandF (x - xstep / 2, x + xstep / 2);
      if (!(j == 1 || j == jj)) y = YRandF (y - ystep / 2, y + ystep / 2);
      if (!(k == 1 || k == kk)) z = YRandF (z - zstep / 2, z + zstep / 2);
      
      VLAT (lat, LP(x), YPUTDATA, i, j, k, 1);
      if (izm >= 2) VLAT (lat, LP(y), YPUTDATA, i, j, k, 2);
      if (izm == 3) VLAT (lat, LP(z), YPUTDATA, i, j, k, 3);
      
      for (d = izm + 1, fi = 0; fi < FUNC_NUM; fi++)
	if (func[fi]) {
	  data = VFuncXYZ (fi + 1, x, y, z);
	  VLAT (lat, LP(data), YPUTDATA, i, j, k, d++);
	}
    }
    YMouseForm ("arrow");
    return (TRUE);
  case YGETSIZE:
    MYSIZE_IS (W_MOD, H_MOD);
    break;
  case YOPEN:
  case YDRAW:
    YDrawRectF (0, 0, WND->w, WND->h, WIN->color);
    YDrawStrings (text, 20, 20);
    YWnd (Ph(), DECIMAL, "N-dimenshions : ", 140,40, 50,30, 0,izm_min,izm_max,LP(izm), CLR_DEF);

    YBeginGroup ("Functions", 5,90, 185,140, YColor(""));
    xi = 5;
    yi = 10;
    for (fi = 0; fi < FUNC_NUM; fi++) {
      if (fi == 5) {
	xi = 100;
	yi = 10;
      }
      YWnd (Ph(), CHECK, allnames[fi], xi,yi, 20,20, 0,LP(func[fi]),0,0, CLR_DEF);
      yi += 25;
    }
    YEndGroup ();

    YBeginGroup ("Size", 195,90, 120,100, YColor(""));
    YWndGroupBegin ();
      YWnd (Ph(), CHECK, "100x90x80", 5,10, 20,20, 0,LP(size1),0,0, CLR_DEF);
      YWnd (Ph(), CHECK, "30x20x10",  5,35, 20,20, 0,LP(size3),0,0, CLR_DEF);
      YWnd (Ph(), CHECK, "", 5,60, 20,20, 0,LP(size5),0,0, CLR_DEF);
    YWndGroupEnd ();
    YWnd (Ph(), DECIMAL, "", 35,60, 25,20, 0,one,sto,LP(ii_man), CLR_DEF);
    YWnd (Ph(), DECIMAL, "", 60,60, 25,20, 0,one,sto,LP(jj_man), CLR_DEF);
    YWnd (Ph(), DECIMAL, "", 85,60, 25,20, 0,one,sto,LP(kk_man), CLR_DEF);
    YEndGroup ();
    break;
  case YCLOSE:
    YWndClean (id);
    break;
  default:
    if (MM_FORWARD)  YAlgOut (YSEND2FACE, message,  mes1, mes2, mes3, mes4);
  }

  RETURN_TRUE;
}
/*=============================surfer=========================================*/
/*                                                                            */
/*---------------------------VSurfDeleteUzels---------------------------------*/
VT_SURF *
VSurfDeleteUzels (VT_SURF *surf, YT_BOOL *uzel_for_delete)
{
  int     i;
  VT_SURF *nsurf;
  YT_BOOL *uzel_flags, *poli_flags;

  for (i = 0; i < surf->num_uzel; i++)
    uzel_for_delete[i] = !uzel_for_delete[i];

  uzel_flags = uzel_for_delete;
  poli_flags = VIlistCreate (surf->num_poli, TRUE);

  VSurfChangeCheck (surf, uzel_flags, poli_flags);
  nsurf = VSurfChangeMake (surf, uzel_flags, poli_flags);

  return (nsurf);
}
/*-----------------------------VSurfSlice-----------------------------------*/
VT_SURF *
VSurfSlice (VT_SURF *surf, VT_PLANE *plane, YT_SPACE delta)
{
  int     i;
  VT_P3D *p;
  VT_SURF *slice;
  YT_BOOL *uzel_flags, *poli_flags;

  uzel_flags = VIlistCreate (surf->num_uzel, TRUE);
  poli_flags = VIlistCreate (surf->num_poli, TRUE);

  for (i = 0; i < surf->num_uzel; i++) {
    if (!uzel_flags[i])  
      continue;
    p = VSurfUzel (surf, i);
    if (VPlaneToPoint (plane, p) > delta)
      uzel_flags[i] = FALSE;
  }

  VSurfChangeCheck (surf, uzel_flags, poli_flags);
  slice = VSurfChangeMake (surf, uzel_flags, poli_flags);

  return (slice);
}
/*------------------------VSurfGetSosedes_old-------------------------------*/
YT_BOOL *
VSurfGetSosedes_old (VT_SURF *surf, int i)
{
  YT_BOOL *sosedes;
 /*  VT_GI sos; */
  int j;
  YT_BOOL flag;
  VT_POL  pol;

  sosedes = VIlistCreate (surf->num_uzel, FALSE);

/*   VGrafGetSosed (surf->graf, i, &sos); */
/*   while (VGrafGetSosed (NULL, 0, &sos)) */
/*     sosedes[sos] = TRUE; */

  for (j = 0; j < surf->num_poli; j++) {
    VSurfGetPol (i, surf, &pol);
    flag = FALSE;

    if ((pol.u1 == j) || (pol.u2 == j) || (pol.u3 == j)) {
      flag = TRUE;
      fprintf (stderr, "+++ %d %d %d %d %d \n", i, j, pol.u1, pol.u2, pol.u3);
    }
    if (!pol.tria && (pol.u4 == j)) 
      flag = TRUE;
    
    if (flag) {
      fprintf (stderr, "--- %d %d %d %d %d \n", i, j, pol.u1, pol.u2, pol.u3);
      sosedes[pol.u1] = TRUE;
      sosedes[pol.u2] = TRUE;
      sosedes[pol.u3] = TRUE;
      if (!pol.tria) sosedes[pol.u4] = TRUE; 
    }
  }
  sosedes[i] = FALSE;

  return (sosedes);
}
/*------------------------VSurfGetSosedes-------------------------------*/
YT_BOOL *
VSurfGetSosedes (VT_SURF *surf, int i)
{
  YT_BOOL *sosedes;
  int j;
  YT_BOOL flag;
  VT_POL  pol;

  sosedes = VIlistCreate (surf->num_uzel, FALSE);

  for (j = 0; j < surf->num_poli; j++) {
    VSurfGetPol (j, surf, &pol);
    flag = FALSE;

    if ((pol.u1 == i) || (pol.u2 == i) || (pol.u3 == i)) {
      flag = TRUE;
      /* fprintf (stderr, "+++ %d %d %d %d %d \n", i, j, pol.u1, pol.u2, pol.u3); */
    }
    if (!pol.tria && (pol.u4 == i)) 
      flag = TRUE;
    
    if (flag) {
      /* fprintf (stderr, "--- %d %d %d %d %d \n", i, j, pol.u1, pol.u2, pol.u3); */
      sosedes[pol.u1] = TRUE;
      sosedes[pol.u2] = TRUE;
      sosedes[pol.u3] = TRUE;
      if (!pol.tria) sosedes[pol.u4] = TRUE; 
    }
  }
  sosedes[i] = FALSE;

  return (sosedes);
}
/*------------------------VSurfVisibleHorizon---------------------------*/
YT_BOOL *
VSurfVisibleHorizon (VT_SURF *surf, YT_BOOL *visible)
{
  int     i, j;
  YT_BOOL bool_hor;
  long sos;
  YT_BOOL *horizon, *sosedes;

  horizon = VIlistCreate (surf->num_uzel, FALSE);

  for (i = 0; i < surf->num_uzel; i++) {

    if (!visible[i])  
      continue;
    bool_hor = FALSE;

    sosedes = VSurfGetSosedes (surf, i);

    for (j = 0; j < surf->num_uzel; j++) {
      if (!sosedes[j]) continue;
      sos = j;
      if (!visible[sos]) {
	bool_hor = TRUE;
	break;
      }
    }

    free (sosedes);

    if (bool_hor) {
      visible[i] = FALSE;
      horizon[i] = TRUE;
    }
  }

  return (horizon);
}
/*---------------------------VSurfUzel--------------------------------------*/
VT_P3D *
VSurfUzel (VT_SURF *surf, int uz)
{

  return (surf->uzel + uz);

}
/*--------------------------VSurfCheckVisible-------------------------------*/
void
VSurfCheckVisible (VT_P3D *s, VT_SURF *surf, YT_BOOL *uzel_flags)
{
  int     i;
  VT_P3D *t;
  VT_OBJ3D obj;


  V3ObjInit (&obj, "VSURF", "",  surf, 0, 0, YColor("blue"), FALSE);
  IsvisPoints (&obj, s, NULL);

  for (i = 0; i < surf->num_uzel; i++) {
    if (!uzel_flags[i])  continue;

    t = VSurfUzel (surf, i);
    if (!IsvisPoints (NULL, s, t))  uzel_flags[i] = FALSE;
  }

  IsvisPoints (NULL, NULL, NULL);
  return;
}
/*--------------------------VSurfCheckVisible_old-------------------------------*/
void
VSurfCheckVisible_old (VT_P3D *s, VT_SURF *surf, YT_BOOL *uzel_flags)
{
  int     i;
  VT_P3D *t;

  for (i = 0; i < surf->num_uzel; i++) {
    if (!uzel_flags[i])  continue;

    t = VSurfUzel (surf, i);
    if (!VSurfIsvisPoint (surf, s, t, i))  uzel_flags[i] = FALSE;
  }

  return;
}
/*-------------------------VSurfIsvisPoint----------------------------------*/
YT_BOOL
VSurfIsvisPoint (VT_SURF *surf, VT_P3D *s, VT_P3D *t, int uz)
{
  int     i;
  VT_POL  pol;
  YT_BOOL do_uz = TRUE;

  for (i = 0; i < surf->num_poli; i++) {
    VSurfGetPol (i, surf, &pol);

    if (!do_uz && (uz == pol.u1 || uz == pol.u2 || uz == pol.u3 || uz == pol.u4))
      continue;

    if (pol.tria) {
      if (!VVisibleFromTri (s, pol.p1, pol.p2, pol.p3, t))  break;
    } else {
      if (!VVisibleFromTri (s, pol.p1, pol.p2, pol.p4, t))  break;
      if (!VVisibleFromTri (s, pol.p2, pol.p3, pol.p4, t))  break;
    }
  }

  if (i == surf->num_poli)  return (TRUE);
  else                      return (FALSE);
}
/*---------------------------VPointsEqual----------------------------------*/
YT_BOOL
VPointsEqual (VT_P3D *p1, VT_P3D *p2)
{

  return ((p1->x == p2->x) && (p1->y == p2->y) && (p1->z == p2->z));

}
/*-----------------------------VTriIsTrue----------------------------------*/
YT_BOOL
VTriIsTrue (VT_P3D *p1, VT_P3D *p2, VT_P3D *p3)
{

  if (VPointsEqual(p1, p2)) return (FALSE);
  if (VPointsEqual(p2, p3)) return (FALSE);
  if (VPointsEqual(p1, p3)) return (FALSE);

  return (TRUE);
}
/*------------------------------VVisibleFromTri-----------------------------*/
YT_BOOL
VVisibleFromTri (VT_P3D *s, VT_P3D *p1, VT_P3D *p2, VT_P3D *p3, VT_P3D *t)
{

  if (!VTriIsTrue(p1, p2, p3)) return (TRUE);

  if (!VPlaneIsOneside (p3, s, p1, p2, t))  return (TRUE);
  if (!VPlaneIsOneside (p2, s, p1, p3, t))  return (TRUE);
  if (!VPlaneIsOneside (p1, s, p2, p3, t))  return (TRUE);

  if (VPlaneIsOneside (s, p1, p2, p3, t))   return (TRUE);

  return (FALSE);
}
/*---------------------------VPlaneIsOneside--------------------------------*/
YT_BOOL
VPlaneIsOneside (VT_P3D *s, VT_P3D *p1, VT_P3D *p2, VT_P3D *p3, VT_P3D *t)
{
  YT_SPACE hislo_s, hislo_t;
  VT_PLANE pl;

  VPlaneFromTri (p1, p2, p3, &pl);

  hislo_s = VPlanePointHislo (&pl, s);
  hislo_t = VPlanePointHislo (&pl, t);

  if ((hislo_s < 0 && hislo_t < 0) || (hislo_s > 0 && hislo_t > 0))
    return (TRUE);

  return (FALSE);
}
/*--------------------------VPlanePointHislo--------------------------------*/
YT_SPACE
VPlanePointHislo (VT_PLANE *pl, VT_P3D *s)
{

  return (pl->a * s->x + pl->b * s->y + pl->c * s->z + pl->d);

}
/*---------------------------VPlaneFromTri----------------------------------*/
YT_BOOL
VPlaneFromTri (VT_P3D *p1, VT_P3D *p2, VT_P3D *p3, VT_PLANE *pl)
{
  YT_SPACE m1, m2, m3;

/*   if (VPointsEqual(p1, p2)) return (FALSE); */
/*   if (VPointsEqual(p2, p3)) return (FALSE); */
/*   if (VPointsEqual(p1, p3)) return (FALSE); */

  m1 = (p2->y - p1->y) * (p3->z - p1->z) - (p3->y - p1->y) * (p2->z - p1->z);
  m2 = (p2->x - p1->x) * (p3->z - p1->z) - (p3->x - p1->x) * (p2->z - p1->z);
  m3 = (p2->x - p1->x) * (p3->y - p1->y) - (p3->x - p1->x) * (p2->y - p1->y);

  pl->a = m1;
  pl->b = -m2;
  pl->c = m3;
  pl->d = p1->y * m2 - p1->x * m1 - p1->z * m3;

  return (TRUE);
}
/*-----------------------------VSurfChangeCheck-----------------------------*/
void
VSurfChangeCheck (VT_SURF *surf, YT_BOOL *uzel_flags, YT_BOOL *poli_flags)
{
  int     i, j;
  VT_POL  pol;

  for (i = 0; i < surf->num_uzel; i++) {
    if (uzel_flags[i])  
      continue;
    for (j = 0; j < surf->num_poli; j++) {
      if (!poli_flags[j])  
	continue;
      VSurfGetPol (j, surf, &pol);
      if (pol.u1 == i || pol.u2 == i || pol.u3 == i || pol.u4 == i) 
	poli_flags[j] = FALSE;
    }
  }

  for (i = 0; i < surf->num_uzel; i++) {
    if (!uzel_flags[i])  
      continue;
    uzel_flags[i] = VSurfCheckUzel (surf, i);
  }

  return;
}
/*----------------------------VSurfChangeMake-------------------------------*/
VT_SURF *
VSurfChangeMake (VT_SURF *surfold, YT_BOOL *uzel_flags, YT_BOOL *poli_flags)
{
  VT_SURF *surfnew;
  int     i, j, num_uzel_new, num_poli_new;
  VT_POL  pol;
  YT_BOOL realnew = TRUE;

  for (i = 0, num_uzel_new = 0; i < surfold->num_uzel; i++)
    if (uzel_flags[i])
      num_uzel_new++;

  for (j = 0, num_poli_new = 0; j < surfold->num_poli; j++)
    if (poli_flags[j])
      num_poli_new++;

  if (realnew) {
    surfnew = VSurfCreate (num_uzel_new, num_poli_new);
    memcpy (&(surfnew->center), &(surfold->center), sizeof (VT_P3D));
  }

  for (i = 0, j = 0; i < surfold->num_poli; i++) {
    if (!poli_flags[i])  
      continue;
    VSurfGetPol (i, surfold, &pol);
    VSurfPutPol (j, surfnew, pol.u1, pol.u2, pol.u3, pol.u4);
    j++;
  }

  for (i = 0, j = 0; i < surfold->num_uzel; i++) {
    if (!uzel_flags[i])  
      continue;
    memcpy (surfnew->uzel + j, surfold->uzel + i, sizeof (VT_P3D));
    VSurfRenameUzel (surfnew, i, j);
    j++;
  }

  return (surfnew);
}
/*-----------------------------VSurfCreate----------------------------------*/
VT_SURF *
VSurfCreate (int num_uzel, int num_poli)
{
  VT_SURF *surf;

  YMALLOC (surf, VT_SURF, 1);
  surf->poli = NULL;

  surf->num_uzel = num_uzel;
  surf->num_poli = num_poli;

  YMALLOC (surf->uzel, VT_P3D, surf->num_uzel);
  YMALLOC (surf->poli, VT_POLI, surf->num_poli);

 /*  surf->graf = NULL; */

  return (surf);
}
/*-----------------------------VSurfGetPol----------------------------------*/
void
VSurfGetPol (int i, VT_SURF *surf, VT_POL *pol)
{
  VT_POLI *poligon;

  if (i >= surf->num_poli) {
    sprintf (Y_STR, "VSurfGetPol: i = %d  ; num_poli = %d", i , surf->num_poli);
    YError  (Y_STR);
  }
  poligon = surf->poli + i;

  pol->tria = poligon->tria;

  pol->u1 = poligon->u1;
  pol->u2 = poligon->u2;
  pol->u3 = poligon->u3;
  pol->u4 = poligon->u4;

  pol->p1 = VSurfUzel (surf, pol->u1);
  pol->p2 = VSurfUzel (surf, pol->u2);
  pol->p3 = VSurfUzel (surf, pol->u3);
  pol->p4 = VSurfUzel (surf, pol->u4);

}
/*------------------------------VSurfPutPol---------------------------------*/
void
VSurfPutPol (int i, VT_SURF *surf, int u1, int u2, int u3, int u4)
{
  VT_POLI *poligon;

  poligon = surf->poli + i;

  poligon->u1 = u1;
  poligon->u2 = u2;
  poligon->u3 = u3;
  poligon->u4 = u4;
  if (u4 < 0)  poligon->tria = TRUE;
  else         poligon->tria = FALSE;

}
/*-----------------------------VSurfMinSize---------------------------------*/
YT_SPACE
VSurfMinSize (VT_SURF *surf)
{
  YT_SPACE minsize, xsize, ysize, zsize, xmin, ymin, zmin, xmax, ymax,
          zmax;
  VT_P3D *p;
  int     i;

  xmax = ymax = zmax = YMINSPACE;
  xmin = ymin = zmin = YMAXSPACE;

  for (i = 0; i < surf->num_uzel; i++) {
    p = VSurfUzel (surf, i);
    if      (p->x < xmin)  xmin = p->x;
    else if (p->x > xmax)  xmax = p->x;

    if      (p->y < ymin)  ymin = p->y;
    else if (p->y > ymax)  ymax = p->y;

    if      (p->z < zmin)  zmin = p->z;
    else if (p->z > zmax)  zmax = p->z;
  }

  xsize = xmax - xmin;
  ysize = ymax - ymin;
  zsize = zmax - zmin;
  minsize = YMIN (xsize, ysize);
  minsize = YMIN (minsize, zsize);

  return (minsize);
}
/*-----------------------------VSurfRenameUzel------------------------------*/
void
VSurfRenameUzel (VT_SURF *surf, int uzel_old, int uzel_new)
{
  int     i;
  VT_POL  pol;

  if (uzel_old == uzel_new)  return;

  for (i = 0; i < surf->num_poli; i++) {
    VSurfGetPol (i, surf, &pol);
    if (pol.u1 == uzel_old)  pol.u1 = uzel_new;
    if (pol.u2 == uzel_old)  pol.u2 = uzel_new;
    if (pol.u3 == uzel_old)  pol.u3 = uzel_new;
    if (pol.u4 == uzel_old)  pol.u4 = uzel_new;
    VSurfPutPol (i, surf, pol.u1, pol.u2, pol.u3, pol.u4);
  }

  return;
}
/*-----------------------------VSurfCalcCenter------------------------------*/
void
VSurfCalcCenter (VT_SURF *surf)
{
  int     i;
  YT_SPACE xsum = 0, ysum = 0, zsum = 0;
  long    num = surf->num_poli;
  VT_POL  pol;

  for (i = 0; i < num; i++) {
    VSurfGetPol (i, surf, &pol);
    if (pol.tria) {
      xsum = xsum + (pol.p1->x + pol.p2->x + pol.p3->x) / 3;
      ysum = ysum + (pol.p1->y + pol.p2->y + pol.p3->y) / 3;
      zsum = zsum + (pol.p1->z + pol.p2->z + pol.p3->z) / 3;
    } else {
      xsum = xsum + (pol.p1->x + pol.p2->x + pol.p3->x + pol.p4->x) / 4;
      ysum = ysum + (pol.p1->y + pol.p2->y + pol.p3->y + pol.p4->y) / 4;
      zsum = zsum + (pol.p1->z + pol.p2->z + pol.p3->z + pol.p4->z) / 4;
    }
  }

  (surf->center).x = xsum / num;
  (surf->center).y = ysum / num;
  (surf->center).z = zsum / num;

  return;
}
/*-----------------------------VSurfKleying---------------------------------*/
void
VSurfKleying (VT_SURF **psurf, YT_SPACE delta)
{
  VT_SURF *newsurf, *surf = *psurf;
  int     u, v, i, j;
  VT_P3D *p1, *p2;
  int    *list, num = surf->num_uzel;
  int     new_group = 1, first;
  YT_BOOL *uzel_flags, *poli_flags;
  int sum = 0;

  if (delta < 0)  delta = 0.01 * VSurfMinSize (surf);

  uzel_flags = VIlistCreate (surf->num_uzel, TRUE);
  poli_flags = VIlistCreate (surf->num_poli, TRUE);

  YMALLOC (list, int, num);
  for (i = 0; i < num; i++)  
    list[i] = 0;

  for (u = 0; u < surf->num_uzel - 1; u++)
  for (v = u + 1; v < surf->num_uzel; v++) {
    p1 = VSurfUzel (surf, u);
    p2 = VSurfUzel (surf, v);
    if (VLenOtrezok (p1, p2) > delta)  
      continue;
    if      (list[u] && !list[v])  list[v] = list[u];
    else if (list[v] && !list[u])  list[u] = list[v];
    else if (!list[u] && !list[v]) list[u] = list[v] = new_group++;
    else {
      if (list[u] == list[v])  
	continue;
      YWarning ("VSurfKleying");
    }
  }
  
  for (j = 1; j < new_group; j++) {
    first = -1;
    for (i = 0; i < num; i++) {
      if (list[i] != j)  
	continue;
      if (first < 0) {
	first = i;
	continue;
      }
      VSurfRenameUzel (surf, i, first);
      uzel_flags[i] = FALSE;   sum++;
    }
  }

  fprintf (Y_STDERR, "sum_uzel_FALSE = %d \n", sum);

  VSurfCheckBadFour (surf);
  newsurf = VSurfChangeMake (surf, uzel_flags, poli_flags);

  *psurf = newsurf;
  return;
}
/*-----------------------------VSurfCheckBadFour----------------------------*/
void
VSurfCheckBadFour (VT_SURF *surf)
{
  int     i;
  VT_POL  pol;
  int     u1, u2, u3;

  for (i = 0; i < surf->num_poli; i++) {
    VSurfGetPol (i, surf, &pol);
    if (pol.tria)  
      continue;
    if (pol.u1 == pol.u2) {
      u1 = pol.u1;
      u2 = pol.u3;
      u3 = pol.u4;
    } else if (pol.u2 == pol.u3) {
      u1 = pol.u2;
      u2 = pol.u4;
      u3 = pol.u1;
    } else if (pol.u3 == pol.u4) {
      u1 = pol.u3;
      u2 = pol.u1;
      u3 = pol.u2;
    } else if (pol.u4 == pol.u1) {
      u1 = pol.u4;
      u2 = pol.u2;
      u3 = pol.u3;
    } else
      continue;
    pol.tria = TRUE;
    VSurfPutPol (i, surf, u1, u2, u3, -1);
  }

}
/*-----------------------------VSurfCheckUzel-------------------------------*/
YT_BOOL
VSurfCheckUzel (VT_SURF *surf, int i)
{
  int     j;
  VT_POL  pol;

  for (j = 0; j < surf->num_poli; j++) {
    VSurfGetPol (j, surf, &pol);
    if (pol.u1 == i || pol.u2 == i || pol.u3 == i || pol.u4 == i)
      return (TRUE);
  }

  return (FALSE);
}

/*------------------------------D3_DrawSurf-----------------------------------*/
void
D3_DrawSurf (VT_CAM3D *cam3d, VT_OBJ3D *obj3d)
{
  VT_SURF *surf = (VT_SURF *) obj3d->p;
  static YT_COLOR color;
  YT_BOOL is_frame = (YT_BOOL) obj3d->long4;
  static YT_COLOR black;
  int     i;
  VT_POL  pol;
  YT_COLOR l_color = YColor("black");
  VT_FOUR four;
  static VT_CPOINT v1, v2, v3;
  VT_PTRI3D t1 =
  {&v1, &v2, &v3, &color, &black};

  black = YColor("black");
  color = (YT_COLOR) obj3d->long3;

  if (is_frame) {

    for (i = 0; i < surf->num_poli; i++) {
      VSurfGetPol (i, surf, &pol);
      D3_DrawLine (cam3d, pol.p1->x, pol.p1->y, pol.p1->z, pol.p2->x, pol.p2->y, pol.p2->z, l_color);
      D3_DrawLine (cam3d, pol.p2->x, pol.p2->y, pol.p2->z, pol.p3->x, pol.p3->y, pol.p3->z, l_color);
      
      if (pol.tria) {
	D3_DrawLine (cam3d, pol.p3->x, pol.p3->y, pol.p3->z, pol.p1->x, pol.p1->y, pol.p1->z, l_color);
      } else {
	D3_DrawLine (cam3d, pol.p3->x, pol.p3->y, pol.p3->z, pol.p4->x, pol.p4->y, pol.p4->z, l_color);
	D3_DrawLine (cam3d, pol.p4->x, pol.p4->y, pol.p4->z, pol.p1->x, pol.p1->y, pol.p1->z, l_color);
      }
    }


  }
  if (color != CLR_NULL) {
    for (i = 0; i < surf->num_poli; i++) {
      VSurfGetPol (i, surf, &pol);

      if (pol.tria) {
	v1.x = pol.p1->x;
	v1.y = pol.p1->y;
	v1.z = pol.p1->z;
	v1.color = YColor ("black");
	v2.x = pol.p2->x;
	v2.y = pol.p2->y;
	v2.z = pol.p2->z;
	v2.color = YColor("black");
	v3.x = pol.p3->x;
	v3.y = pol.p3->y;
	v3.z = pol.p3->z;
	v3.color = YColor("black");
	D3_DrawTri (cam3d, &t1);

      } else {
	four.p1.x = pol.p1->x;
	four.p2.x = pol.p2->x;
	four.p3.x = pol.p3->x;
	four.p4.x = pol.p4->x;

	four.p1.y = pol.p1->y;
	four.p2.y = pol.p2->y;
	four.p3.y = pol.p3->y;
	four.p4.y = pol.p4->y;

	four.p1.z = pol.p1->z;
	four.p2.z = pol.p2->z;
	four.p3.z = pol.p3->z;
	four.p4.z = pol.p4->z;
	four.color = color;

	D3_DrawFour (cam3d, &four);
      }
    }
  }
  return;
}
/*---------------------------VSetkaMakeTest---------------------------------*/
void
VSetkaMakeTest (VT_SETKA *psetka, int func, int num_u,int num_v, YT_SPACE par)
{
  YT_SPACE umin, umax, vmin, vmax;
  int     i, j;
  YT_SPACE ustep, vstep, u, v, x, y, z, t;

  switch (func) {
  case 0:			/* Polu-Sphere */
    umin = 0.0;  umax = YPI;
    vmin = 0.0;  vmax = YPI;
    if (par==0) par=1.0;
    break;
  case 1:			/* Sphere */
    umin = 0.0;  umax = 2 * YPI;
    vmin = 0.0;  vmax = 2 * YPI;
    if (par==0) par=1.0;
    break;
  case 2:			/* Exponenta */
    umin = -2.0;  umax = 2.0;
    vmin = -2.0;  vmax = 2.0;
    break;
  case 3:			/* Sinusoida */
    umin = -3.0;  umax = 3.0;
    vmin = -3.0;  vmax = 3.0;
    break;
  case 4:			/* Moebius band */
    num_u =  50;  num_v = 7;
    umin  =  0;   umax  = 2 * YPI;
    vmin  = -1;   vmax  = 1;
    break;
  case 5:			/* Kuen's Surface */
    num_u = 15;   num_v = 15;
    umin  = -4;   umax  = 4;
    vmin  = 0.01; vmax  = YPI - 0.01;
    break;
  case 6:			/* Pinched Torus */
    num_u = 20;   num_v = 10;
    umin  = 0;    umax  = 2 * YPI;
    vmin  = -YPI; vmax  = YPI;
    break;
  }

  VSetkaInit (psetka, num_u, num_v);  

  ustep = (umax - umin) / (num_u - 1);
  vstep = (vmax - vmin) / (num_v - 1);
  for (i = 0; i < num_u; i++)
  for (j = 0; j < num_v; j++) {
    u = umin + ustep * i;
    v = vmin + vstep * j;
    switch (func) {
    case 0:			/* Polu-Sphere */
    case 1:			/* Sphere */
      x = par * cos (u);
      y = par * sin (u) * sin (v);
      z = par * sin (u) * cos (v);
      break;
    case 2:			/* Exponenta */
      x = u;
      y = v;
      z = 2 * x * exp (-x * x - y * y);
      break;
    case 3:			/* Sinusoida */
      x = u;
      y = v;
      z = 2 * sin (x * x + y * y) / (x * x + y * y + 5);
      break;
    case 4:			/* Moebius band */
      x = (5 + cos (0.5 * u) * v) * cos (u);
      y = (5 + cos (0.5 * u) * v) * sin (u);
      z = sin (0.5 * u) * v;
      break;
    case 5:			/* Kuen's Surface */
      t = 1 + u * u * sin (v) * sin (v);
      x = 2 * (cos (u) + u * sin (u)) * sin (v) / t;
      y = 2 * (sin (u) - u * cos (u)) * sin (v) / t;
      z = log (tan (v / 2)) + 2 * cos (v) / t;
      break;
    case 6:			/* Pinched Torus */
      x = cos (u) * (1 + 0.2 * sin (v));
      y = sin (u) * (1 + 0.2 * sin (v));
      z = 0.2 * sin (u) * cos (v);
      break;
    }
    
    (VSetkaPts (psetka, i, j))->x = x;
    (VSetkaPts (psetka, i, j))->y = y;
    (VSetkaPts (psetka, i, j))->z = z;
  }
  
  return;
}
/*-----------------------------VSurfFromSetka-------------------------------*/
VT_SURF *
VSurfFromSetka (VT_SETKA *setka, YT_BOOL kleying, YT_SPACE delta)
{
  VT_SURF *surf;
  int     i, u, v, uu = setka->uu, vv = setka->vv;
  VT_P3D *s;

  surf = VSurfCreate (uu * vv, (uu - 1) * (vv - 1));

  i = 0;
  for (u = 0; u < uu; u++)
  for (v = 0; v < vv; v++) {
    s = VSetkaPts (setka, u, v);
/* fprintf(Y_STDERR, "%f %f %f \n", s->x,s->y,s->z); */
    memcpy (VSurfUzel (surf, i), s, sizeof (VT_P3D));
    i++;
  }
/* fprintf(Y_STDERR,"VSurfFromSetka = %d %d \n",uu,vv); */

  i = 0;
  for (u = 0; u < uu - 1; u++)
  for (v = 0; v < vv - 1; v++) {
    VSurfPutPol (i++, surf, u * vv + v, (u + 1) * vv + v, (u + 1) * vv + v + 1, 
		 u * vv + v + 1);
  }
  
  if (kleying) { 
    OUTS ("kleying");
    VSurfKleying (&surf, delta);
  }

  return (surf);
}
/*-----------------------VPoluSurfMakeTest----------------------------------*/
VT_SURF *
VPoluSurfMakeTest (int num_u, int num_v, YT_SPACE r)
{
  VT_SURF *surf = NULL;
  YT_SPACE umin, umax, vmin, vmax;
  int     i, j;
  YT_SPACE ustep, vstep, u, v, x, y, z/* , t */;

  umin = 0.0;  umax = YPI;
  vmin = 0.0;  vmax = YPI;

  ustep = (umax - umin) / (num_u - 1);
  vstep = (vmax - vmin) / (num_v - 1);

  for (i = 0; i < num_u; i++)
  for (j = 0; j < num_v; j++) {
    u = umin + ustep * i;
    v = vmin + vstep * j;

    x = r * cos (u);
    y = r * sin (u) * sin (v);
    z = r * sin (u) * cos (v);
  }


  x++; y++; z++; return (surf);
}
/*-----------------------------mTest5---------------------------------------*/
long
mTest5 (PFUNC_VAR)
{
  typedef struct {
    ABCD;
  } YT_USR;

  enum words {
    MAKETESTVOL3D = YKEY_LOCALS
  };

  static VT_VOL3D *vol3d;
  static YT_BOOL large;
  static YT_SIZET npoints;
  static int func;
  static int ii, jj, kk;
  static char *func_names[] =
  {
    "x",
    "x^2+y^2+z^2",
    "exp(-x^2-...)",
    NULL};
  static int hFuncs, hLarge;

  switch (message) {
  case YCREATE:
    U_MALLOC;
    WND->name = "Test5";
    large = FALSE;
    break;
/*   case MM_FORWARD: */
/*     break; */
  case MM_APPLY:
    YGoto (YAPPLY, 0, 0, 0, 0);
    break;
  case YAPPLY:
    YGoto (YCOMBO, hFuncs, 0, 0, 0);
    YAlgOut (YSEND2FACE, MM_VOL3D_CHANGE1,  0, 0, 0, 0);
    YGoto (MAKETESTVOL3D, 0, 0, 0, 0);
    YAlgOut (YSEND2FACE, MM_VOL3D_CHANGE2,  0, 0, 0, 0);
    break;
  case MAKETESTVOL3D:
    {
      YT_SIZET ii = vol3d->ii;
      YT_SIZET dd = vol3d->dd;
      static YT_SPACE xmin, xmax, ymin, ymax, zmin, zmax;
      static int i;
      static YT_SPACE x, y, z, h;

      xmin = -2;
      xmax = 2;
      ymin = -2;
      ymax = 2;
      zmin = -2;
      zmax = 2;

      if (!VLatCreateVOL (vol3d, ii, dd)) {
	YMessageBox ("Don't CreateLAT !", "OK");
	return (FALSE);
      }
      for (i = 1; i <= ii; i++) {
	x = YRandF (xmin, xmax);
	y = YRandF (ymin, ymax);
	z = YRandF (zmin, zmax);
	h = VFuncXYZ (func, x, y, z);
	A_VOL3D (vol3d, i, 1) = x;
	A_VOL3D (vol3d, i, 2) = y;
	A_VOL3D (vol3d, i, 3) = z;
	A_VOL3D (vol3d, i, 4) = h;
      }
      return (TRUE);
    }
  case YOPEN:
    YDrawRectF (0, 0, WND->w, WND->h, WIN->color);
    YBeginGroup ("", 10,10, 180,100, YColor(""));
    YWnd (&hFuncs, COMBO, "", 5,10, 140,20, (long)func_names,3,LP(func),0, CLR_DEF);
    YWnd (&hLarge, CHECK, "large", 5,35, 20,20, 0,LP(large),0,0, CLR_DEF);
    YEndGroup ();
    break;
  case YCOMBO:
    /* if (mes1 != hFuncs) */
/*       break; */
    func = (int) YGetData (hFuncs);
    if (large) {
      npoints = (YT_SIZET) 60000l;
      ii = 10;
      jj = 20;
      kk = 30;
    } else {
      npoints = 1000;
      ii = 4;
      jj = 5;
      kk = 6;
    }
    npoints++;
    ii++;  jj++;  kk++;
    break;
  case YCLOSE:
    YWndClean (id);
    break;
  default: ;;;
  }

  RETURN_TRUE;
  }
/*---------------------------VPlaneToPoint----------------------------------*/
YT_SPACE
VPlaneToPoint (VT_PLANE *pl, VT_P3D *p)
{

  return (YABS (VPlanePointHislo (pl, p)) / sqrt (pl->a * pl->a + pl->b * pl->b + 
						  pl->c * pl->c));

}
/*---------------------------VSetkaPts--------------------------------------*/
VT_P3D *
VSetkaPts (VT_SETKA *setka, int i, int j)
{
  int     num = setka->vv * i + j;

  return (&(setka->pts[num]));
}
/*---------------------------VSetkaInit-------------------------------------*/
void
VSetkaInit (VT_SETKA *setka, int num_u, int num_v)
{

  if (setka->pts != NULL) 
     free ((void *) setka->pts); 

  if (!(setka->pts = (VT_P3D *) malloc (num_u*num_v*sizeof(VT_P3D)))) {
            YError ("VSetkaInit");
  }
  setka->uu = num_u;
  setka->vv = num_v;

}
/*--------------------------------mREND3--------------------------------------*/
long
mREND3 (PFUNC_VAR)
{
  typedef struct {
    ABCD;
  } YT_USR;

  static VT_W3D *w3d;
  static int beg = 0;
  static VT_CAM3D *cam3d;
  /* static YT_SPACE zplane=9.9; */
  static YT_BOOL is_add = FALSE;

  static void *meta = NULL;
  static int hlegend = 40;
  static YT_BOOL blegend = FALSE;
  static YT_RECT rect;

  static int y_line = 0;
  static int v0 = 0, v360 = 360;
  static int null = 0, sto = 100;

  static int h_zplane, h_zview;

  char   *text[] =
  {
    "The module makes rendering of objects",
    "3D-stage, and directs the received",
    "image on the screen:",  
    NULL
  };

  begin_end ((int*)&MDATA, &beg);


  switch (message) {
  case YGETSIZE:
    MYSIZE_IS (W_MOD, H_MOD);
    break;
  case YCREATE:   
    U_MALLOC;
    WND->name = "Render3";

    D3_Start ();
    if (!(W3D (&(w3d), 0, YCONSTR0, 0, 0, 0, 0)))  YError ("W3D-CONSTR");

    meta = YMetaCreate (60);
    break;  
  case MM_END:
    if (!is_add)  
      break;
    D3_SetMinmax (w3d);
    YGoto (YREDRAW, 0, 0, 0, 0);
    is_add = FALSE;
    break;
  case MM_LEGEND:
    blegend = PDATA;
    break;
  case MM_CLEAR_ALL:
    D3_WorldClear (w3d);
    break;
  case MM_OBJ3D_ADD:
    D3_WorldAddTo (w3d, (VT_OBJ3D *) PDATA);
    is_add = TRUE;
    break;
  case MM_OBJ3D_XOR:
    w3d->xorr = (VT_OBJ3D *) PDATA;
    YGoto (YKEYWORD1, 0, 0, 0, 0);
    break;
  case MM_APPLY:
    YGoto (YPUT, 0, 0, 0, 0);
    YGoto (YREDRAW, 0, 0, 0, 0);
    break;
  case YREDRAW:
    if (!w3d)
      break;
    YGoto (YEND, 0, 0, 0, 0); /*??*/
    YSend (SvisRend(3), YGETRECT, 0, 0, LP(rect), 0);
/*     cam3d->scrx = rect.x; */
/*     cam3d->scry = rect.y; */
/*     cam3d->scrw = rect.w; */
/*     cam3d->scrh = rect.h; */
    D3_Viewport (cam3d, rect.x, rect.y, rect.w, rect.h);
    y_line = 0;
    if (blegend) {
      cam3d->scrh -= hlegend;
      y_line += hlegend - 1;
    }
    YMouseForm ("wait");
    YGoto (YDRAWALL, 0, 0, 0, 0);
    YMouseForm ("arrow");
    break;
  case YDRAWALL:
    if (!w3d)
      break;
    cam3d = w3d->cam3d;

    YMetaInit (meta, rect.x, rect.y, rect.w, rect.h);
    YMetaBegin (meta, "");
    if (blegend)
      VDrawLegend (0, 0, YMetaW (meta), hlegend);

    /* YDrawContext (TRUE, SvisRend(3)); */
    D3_ZbufBegin ((w3d->cam3d)->scrw, (w3d->cam3d)->scrh);
    D3_DrawWorld (w3d, 0, y_line, YMAIN);
    D3_ZbufEnd ();
    /* YDrawContext (FALSE, ID_NULL); */

    YMetaEnd ();
    YMetaDrawTo (meta, SvisRend(3), TRUE, id);
    if (w3d->xorr)
      YGoto (YKEYWORD1, 0, 0, 0, 0);
    break;
  case YKEYWORD1:
    if (!meta)  
      break;
    if (YMetaW (meta) == 0) 
      break;
    YMetaBegin (meta, "Xor3d");
    D3_DrawWorld (w3d, 0, y_line, YXOR);
    YMetaEnd ();
    YMetaDrawTo (meta, SvisRend(3), FALSE, id);
    break;
  case YDRAWITEM:
    YMetaBegin (meta, "XorCube");
    D3_DrawWorld (w3d, 0, y_line, YCUBE);
    YMetaEnd ();
    YMetaDrawTo (meta, SvisRend(3),  FALSE, id);
    break;
  case YLBUTT:
    YSWITCH ((char*)mes3) {
    YCASE ("Redraw")		      
      YGoto (YREDRAW, 0, 0, 0, 0);
      break;
    YCASE3 ("/+", "/-", "/>")		    
      YAlgOut (YSEND2BACK, MM_STRING,  0, 0, 0, mes3);
    YCASE ("Find")		    
      D3_SetMinmax (w3d);
      YGoto (YDRAWALL, 0, 0, 0, 0);
    YDEFAULT
      OUTS((char*)mes3); YBeep ();
    }
    break;
  case YOPEN:
    cam3d = (w3d)->cam3d;
  case YDRAW:
    YDrawRectF (0, 0, WND->w, WND->h, WIN->color);
    YDrawStrings (text, 20, 20);

    YBeginGroup ("Misc", 10,70, 150,160, YColor(""));
    YWnd (Ph(), COLORS, "Background",  10,10, 20,20, LP(cam3d->background),0,0,0, CLR_DEF);
    YWnd (Ph(), CHECK,  "Interpolate", 10,35, 20,20, 0,LP(cam3d->guro),0,0, CLR_DEF);
    YWnd (Ph(), CHECK,  "One Light",   10,60, 20,20, 0,LP(cam3d->light),0,0, CLR_DEF);
    YWnd (Ph(), CHECK,  "Hand Drag",   10,85, 20,20, 0,LP(cam3d->boxing),0,0, CLR_DEF);
    YWnd (&h_zplane, FLOATS, "zplane = ", 65,110, 50,20, LP(cam3d->zplane),YSPACE,0,0, CLR_DEF);
    YWnd (&h_zview,  FLOATS, "zview  = ", 65,135, 50,20, LP(cam3d->zview),YSPACE,0,0, CLR_DEF);
    YWnd (Ph(), CHECK,  "",              120,135, 20,20, 0,LP(cam3d->zview_flag),0,0, CLR_DEF);
    YEndGroup ();

    YBeginGroup ("Axes", 165,80, 140,70, YColor(""));
    YWnd (Ph(), DECIMAL, "", 15,15, 40,20, 0,null,sto,LP(cam3d->repers), CLR_DEF);
    YDrawString ("Lenght", 60, 25, YColor("black"));
    YWnd (Ph(), COLORS, "Color", 15,40, 20,20, LP(cam3d->repers_color),0,0,0, CLR_DEF);
    YEndGroup ();

    YBeginGroup ("Rotate", 165,160, 140,70, YColor(""));
    YWnd (Ph(), DECIMAL, "round OX ", 80,15, 40,20, 0,v0,v360,LP(cam3d->alfa), CLR_DEF);
    YWnd (Ph(), DECIMAL, "round OY ", 80,40, 40,20, 0,v0,v360,LP(cam3d->beta), CLR_DEF);
    YEndGroup ();
    break;
  case YPUT:
    YGetData (h_zplane);
    YGetData (h_zview);
    break;
  case YCLOSE:
    YWndClean (id);
    break;
  default:
    if (!MM_FORWARD) {
      if (!w3d)
	break;
      cam3d = (w3d)->cam3d;
      mes3 = (long)cam3d;
      CALL (V3cube_proc, id, from, message, mes1, mes2, mes3, mes4);
    }
  }

  RETURN_TRUE;
}
/******************************************************************************/



#endif
#if  defined(D_MAT)
/******************************************************************************/

#include "dia-y_zone.h" 
#include "dia-algols.h" 
#include "dia-svisor.h" 

long     mGrGener (PFUNC_PAR); 
long     mGrDoing (PFUNC_PAR); 
long     mGrCalcs (PFUNC_PAR);
void     VGrafCalcOutdata (VT_GRAF *, int hConsole, int, int, int, int, int, int, int);

/*--------------------------------SLoadMatlib----------------------------------*/
void 
SLoadMatlib ()
{

  AT_PNAME1 pnames[] = {
    { "graf_test",graf_test},
    { "mGrGener",  mGrGener },  
    { "mGrDoing",  mGrDoing },  
    { "mGrCalcs",  mGrCalcs }, 
    { NULL }
  }; 

  static AT_PAR pars_calcs = {
    "pars_calcs",
    {
    {"bool",  "out_rmin",   "TRUE"}, 
    {"bool",  "out_rmax",   "TRUE"}, 
    {"bool",  "out_metr",   "FALSE"}, 
    {"bool",  "out_nnull",  "FALSE"}, 
    {"bool",  "out_nplus",  "FALSE"}, 
    {"bool",  "out_nminus", "FALSE"}, 
    {"bool",  "out_sum",    "FALSE"}, 
    {NULL}
  }};


  static AT_TEXT txt_evograf[] = {
   {"..................................", 35,25},
   {"..................................", 35,40}, 
   {NULL}};
  static AT_PLANER pln_evograf[] = {
    { 1, YMOD, "mGrGener",   NULL,          50, 80, WFU,HFU, NULL, {2},   {"MM_APPLY"}},
    { 2, YMOD, "mControl",   NULL,         120, 80, WFU,HFU, NULL, {3}               },
    { 3, YMOD, "mGrDoing",   NULL,         190, 80, WFU,HFU, NULL, {4, 5}            },
    { 4, YMOD, "mKran",      NULL,         155,135, WMI,HMI, NULL, {2}               },
    { 5, YMOD, "mGrCalcs",  "pars_calcs",  260, 80, WFU,HFU, NULL, {0},   {"MM_HCONSOLE"}},
    {mid_END}};
  static AT_MAP evograf = {"Egraf", &pln_evograf[0], &txt_evograf[0]};


  static char *def_map[] = {
    "@MAP  D_matlib",
    "30 30 | ..................................",
    "30 45 | ..................................", 
    "@MAP_plan   ",
    " 1 YMAP Egraf     NULL  80 100 60 25  NULL    |   |   ",
    " 2 YMOD graf_test NULL 180 100 60 25  GR_test |   |   MM_APPLY", 

    NULL};

/* 	SLoadOptomo (); */


  YSetPnames (pnames);

  YAlgSetNewPars (&pars_calcs);
  YAlgSetNewMap  (&evograf);

  YAlgReadAll (def_map);

  return;
}
/*-----------------------------mGrGener---------------------------------------*/
long
mGrGener (PFUNC_VAR)
{
  typedef struct {
    ABCD;
  } YT_USR;
  char   *text[] =
  {
    ".......................................",
    ".......................................",
    NULL
  };
  static int  n_min = 3, n_max = 10000;
  static int  n;
  static VT_GRAF *pg;

  switch (message) {
  case YCREATE:
    U_MALLOC;
    WND->name = "GrGener";
    n = 100;
    break;
/*   case MM_FORWARD: */
/*     break; */
  case MM_APPLY:
    YGoto (YMAKE, 0, 0, 0, 0);
    YAlgOut (YSEND2FACE, MM_DATA,  0, 0, 0, (long)pg);
    break;

  case YMAKE:
    pg = VGrafCreate (n);
    VGrafInit (pg, YRAND, 0, 100, YRAND, 0, 100);
    /* VGrafPrint(pg); */
    break;
  case YGETSIZE:
    MYSIZE_IS (W_MOD, H_MOD);
    break;
  case YOPEN:
  case YDRAW:
    YDrawRectF (0, 0, WND->w, WND->h, WIN->color);
    YDrawStrings (text, 30, 30);

    YWnd (Ph(), DECIMAL, "N nodes : ", 120,80, 50,20, 0,n_min,n_max,LP(n), CLR_DEF);
    break;
  case YCLOSE:
    YWndClean (id);
    break;
  default: ;;;
  }

  RETURN_TRUE;
}
/*-----------------------------mGrDoing_old---------------------------------------*/
long
mGrDoing_old (PFUNC_VAR)
{
  typedef struct {
    ABCD;
  } YT_USR;
  char   *text[] =
  {
    ".......................................",
    ".......................................",
    NULL
  };
  static char *model_names[] =
  {
    "'Simple' alg.", "'Triangles'",
    "'All in plus'", "'Medians'",
    NULL
  };

  time_t  t;
  long    sum;
  int     new_point, rab_point;

  static VT_GRAF *pg;
  static VT_GV edge;
  static YT_BOOL isplus;
  static int n, imin, imax, model, point;
  static long nedges;

  switch (message) {
  case YCREATE:
    U_MALLOC;
    WND->name = "GrDoing";
    imin = -100;
    imax =  100;
    model = 1;
    point = 0;
    break;
/*   case MM_FORWARD: */
/*     break; */
  case MM_APPLY:
  case MM_DATA:
    pg = (VT_GRAF*) PDATA;
    n = pg->nn;
    nedges = (n * n - n) / 2;
    YGoto (YMAKE, 0, 0, PDATA/*?*/, 0); 
    YAlgOut (YPOST2FACE, MM_DATA,  0, 0, 0, PDATA);
    break;

  case YMAKE:
      new_point = YRAND (0, n - 1);

      if (new_point == point) 
	break;

      isplus = FALSE;
      srand ((unsigned) time (&t));

      switch (model) {
      case 1:			/*Simple */
	if (isplus) (GRAF_EDGE (pg, point, new_point))++;
	else        (GRAF_EDGE (pg, point, new_point))--;
	isplus = !isplus;
	break;
      case 2:			/*Triang */
	rab_point = YRAND (0, n - 1);
	if (rab_point == point || rab_point == new_point)
	  break;
	if (GRAF_EDGE (pg, point, new_point) >=
	    GRAF_EDGE (pg, point, rab_point) +
	    GRAF_EDGE (pg, rab_point, new_point)) {
	  (GRAF_EDGE (pg, point, new_point))--;
	  (GRAF_EDGE (pg, point, rab_point))++;
	}
	break;
      case 3:			/*All-Plus */
	(GRAF_EDGE (pg, point, new_point))++;
	if (GRAF_EDGE (pg, point, new_point) > imax)
	  GRAF_EDGE (pg, point, new_point) = imin;
	break;
      case 4:			/*Median */
	sum = 0;
	VGrafGetEdges (pg, &edge, NULL, NULL);
	while (VGrafGetEdges (NULL, &edge, NULL, NULL))
	  sum += edge;
	sum = sum / nedges;
	if (GRAF_EDGE (pg, point, new_point) > sum)
	  (GRAF_EDGE (pg, point, new_point))--;
	else
	  (GRAF_EDGE (pg, point, new_point))++;
	break;
      default:
	YError ("Calc_model not found !");
	break;
      }

      point = new_point;

    break;
  case YGETSIZE:
    MYSIZE_IS (W_MOD, H_MOD);
    break;
  case YOPEN:
  case YDRAW:
    YDrawRectF (0, 0, WND->w, WND->h, WIN->color);
    YDrawStrings (text, 30, 30);
    YWnd (Ph(), LIST, "", 60,100, 120,60, (long)model_names,0,LP(model),0, CLR_DEF);
    break;
  case YCLOSE:
    YWndClean (id);
    break;
  default: ;;;
  }

  RETURN_TRUE;
}

/*-----------------------------mGrDoing---------------------------------------*/
long
mGrDoing (PFUNC_VAR)
{
  typedef struct {
    ABCD;
  } YT_USR;
  char   *text[] =
  {
    ".......................................",
    ".......................................",
    NULL
  };

  static VT_GRAF *pg=NULL, *pg_new=NULL;
  static VT_GV   *calc1, *calc2/* , *tmp */;
  static VT_GI    nn;
  VT_GV  /* sum,  */err_mid, err_kfn;
  VT_GI  u, sosed/* , num_sosed */;

  switch (message) {
  case YCREATE:
    U_MALLOC;
    WND->name = "GrDoing";
    break;
/*   case MM_FORWARD: */
/*     break; */
  case MM_DATA:
    pg = (VT_GRAF*) PDATA;
    nn = pg->nn;
    if (!pg_new || pg_new->nn != nn) {
      pg_new = VGrafCreate (nn);
      YMALLOC(calc1, VT_GV, nn);
      YMALLOC(calc2, VT_GV, nn);
    }
  case MM_APPLY:
    if (!pg) break;
    YGoto (YMAKE, 0, 0, 0, 0);
    YAlgOut (YPOST2FACE, MM_DATA,  0, 0, 0, (long)pg_new);
    break;

  case YMAKE:
    if (!pg) break;
    for (u = 0; u < nn; u++) 
      calc1[u] = VGrafGetSum (pg, u);

    pg->nodes = calc1;
    for (u = 0; u < nn; u++) 
      calc2[u] = VGrafGetSum (pg, u);

    for (u = 0; u < nn; u++) 
      calc2[u] = YABS(calc2[u] - calc1[u]);

    VGrafInit (pg_new, YCONST, 0, 0, YCONST, GRAF_NOT_EDGE, 0);
    pg_new->nodes = calc1;

    pg->nodes = calc2;  /* calc_errors */
    for (u = 0; u < nn; u++) {
      err_mid = VGrafGetSum (pg, u);
      VGrafGetSosed (pg, u, &sosed);
      while (VGrafGetSosed (NULL, 0, &sosed)) {  /* !!! */
	if (err_mid == 0) err_kfn = 1;
	else              err_kfn = YABS(GRAF_NODE(pg, sosed) / err_mid);
	GRAF_EDGE(pg_new, u, sosed) = err_kfn * GRAF_EDGE(pg, u, sosed); 
/* 	fprintf (Y_STDERR, "%f ", (float)GRAF_EDGE(pg_new, u, sosed));  */     
      }
    }
    
    break;
  case YGETSIZE:
    MYSIZE_IS (W_MOD, H_MOD);
    break;
  case YOPEN:
  case YDRAW:
    YDrawRectF (0, 0, WND->w, WND->h, WIN->color);
    YDrawStrings (text, 30, 30);
    break;
  case YCLOSE:
    YWndClean (id);
    break;
  default: ;;;
  }

  RETURN_TRUE;
}
/*---------------------------VGrafCalcOutdata-------------------------------*/
void
VGrafCalcOutdata (VT_GRAF *pg, int hConsole, 
		  YT_BOOL out_rmin,  
		  YT_BOOL out_rmax,  
		  YT_BOOL out_metr, 
		  YT_BOOL out_nnull, 
		  YT_BOOL out_nplus, 
		  YT_BOOL out_nminus, 
		  YT_BOOL out_sum)
{
/*   typedef struct {      */
/*     YT_BOOL out_rmin;   */
/*     YT_BOOL out_rmax;   */
/*     YT_BOOL out_metr;   */
/*     YT_BOOL out_nnull;  */
/*     YT_BOOL out_nplus;  */
/*     YT_BOOL out_nminus; */
/*     YT_BOOL out_sum;    */
/*   } VT_GRCALC;          */

/* #define DRAW_STRING {YDrawString (Y_STR, x0, y0+step*i++, color);} */
#define DRAW_STRING printf("%s \n", Y_STR);

  VT_GV  rmin, rmax;
  VT_GI  metr, nnull, nplus, nminus;
  VT_GV  sum;

  int     i, j, k, i_j, j_k, k_i;
  VT_GV value;

  YT_COLOR color;
  int  x0, y0, step;

  nminus = 0;
  nplus  = 0;
  nnull  = 0;

  rmin =  1000000;
  rmax = -1000000;
  sum = 0;

  VGrafGetEdges (pg, &value, NULL, NULL);
  while (VGrafGetEdges (NULL, NULL, NULL, NULL)) {
    /* fprintf (Y_STDERR, "%f ", (float)value);  */
    /* OUTD(333); */
    if (out_rmin)  rmin = YMIN (rmin, value);
    if (out_rmax)  rmax = YMAX (rmax, value);

    if (out_nminus && value < 0)  nminus++;
    if (out_nplus  && value > 0)  nplus++;
    if (out_nnull  && value == 0) nnull++;

    if (out_sum)  sum += value;
  }

  if (out_metr) {
    metr = 0;
    for (i = 1; i <= pg->nn - 2; i++)	/*??? */
    for (j = i + 1; j <= pg->nn - 1; j++)
    for (k = j + 1; k <= pg->nn; k++) {
      i_j = GRAF_EDGE (pg, i, j);
      j_k = GRAF_EDGE (pg, j, k);
      k_i = GRAF_EDGE (pg, k, i);
      if ((i_j <= k_i + j_k) && (j_k <= i_j + k_i) && (k_i <= j_k + i_j))
	metr++;
    }
  }

  color = YColor("black");
  i = 0;
  x0   = 50;
  y0   = 100;
  step = 20;
  /* YDrawContext (TRUE, hConsole); */


  if (out_nminus) { sprintf (Y_STR, "nminus = %d ", nminus); DRAW_STRING; }
  if (out_nplus)  { sprintf (Y_STR, "nplus  = %d ", nplus);  DRAW_STRING; }
  if (out_nnull)  { sprintf (Y_STR, "nnull  = %d ", nnull);  DRAW_STRING; }
  if (out_metr)   { sprintf (Y_STR, "metr   = %d ", metr);   DRAW_STRING; }

  if (out_rmin)   { sprintf (Y_STR, "rmin   = %f ", (float)rmin);  DRAW_STRING; }
  if (out_rmax)   { sprintf (Y_STR, "rmax   = %f ", (float)rmax);  DRAW_STRING; }
  if (out_sum)    { sprintf (Y_STR, "sum    = %f ", (float)sum);   DRAW_STRING; }

	printf("===========================================\n");
  /* YDrawContext (FALSE, ID_NULL); */

  return;
#undef DRAW_STRING
}
/*-----------------------------mGrCalcs---------------------------------------*/
long
mGrCalcs (PFUNC_VAR)
{
  char   *text[] =
  {
    ".......................................",
    ".......................................",
    NULL
  };
  int i;
  static VT_GRAF *pg = NULL;
  static VT_PARS pars[] = {
    {"bool",  "out_rmin",   "TRUE" }, 
    {"bool",  "out_rmax",   "TRUE" }, 
    {"bool",  "out_metr",   "FALSE"}, 
    {"bool",  "out_nnull",  "TRUE" }, 
    {"bool",  "out_nplus",  "TRUE" }, 
    {"bool",  "out_nminus", "TRUE" }, 
    {"bool"  ,"out_sum",    "TRUE" }, 
    {NULL}};

  typedef struct {
    YT_BOOL out_rmin,  out_rmax,   out_metr,  out_nnull,
            out_nplus, out_nminus, out_sum;
  } YT_USR;

  /* static int hConsole; */

  switch (message) {
  case YCREATE:
    U_MALLOC;
    WND->name = "GrCalcs";

    PAR_INIT ("out_rmin",   &U->out_rmin);
    PAR_INIT ("out_rmax",   &U->out_rmax);
    PAR_INIT ("out_metr",   &U->out_metr);
    PAR_INIT ("out_nnull",  &U->out_nnull);
    PAR_INIT ("out_nplus",  &U->out_nplus);
    PAR_INIT ("out_nminus", &U->out_nminus);
    PAR_INIT ("out_sum",    &U->out_sum);

    break;
  case MM_DATA:
   /*  OUTD (101); */
    pg = (VT_GRAF*) PDATA;
/*     YAlgOut (YSEND2FACE, MM_HCONSOLE,  0, 0, 0, 0); */
/*     break; */
/*   case MM_HCONSOLE: */
/*     hConsole = mes1; */
/*     OUTD (hConsole); */
  case MM_APPLY:
    if (!pg) break;
    YGoto (YMAKE, 0,0,0, 0);
    break;
  case YMAKE:
    if (!pg) break;
    VGrafCalcOutdata (pg, ID_NULL,
		      U->out_rmin, 
		      U->out_rmax, 
		      U->out_metr, 
		      U->out_nnull,
		      U->out_nplus, 
		      U->out_nminus, 
		      U->out_sum);
    break;
  case YGETSIZE:
    MYSIZE_IS (W_MOD, H_MOD);
    break;
  case YOPEN:
  case YDRAW:
    YDrawRectF (0, 0, WND->w, WND->h, WIN->color);
    YDrawStrings (text, 30, 30);

    YBeginGroup ("To out", 70,90, 160,105, YColor(""));
    YWnd (Ph(), CHECK, "rmin",  10,i=10,  20,20, 0,LP(U->out_rmin),  0,0, CLR_DEF);
    YWnd (Ph(), CHECK, "rmax",  10,i+=23, 20,20, 0,LP(U->out_rmax),  0,0, CLR_DEF);
    YWnd (Ph(), CHECK, "metr",  10,i+=23, 20,20, 0,LP(U->out_metr),  0,0, CLR_DEF);
    YWnd (Ph(), CHECK, "nnull", 10,i+=23, 20,20, 0,LP(U->out_nnull), 0,0, CLR_DEF);
    YWnd (Ph(), CHECK, "nplus", 85,i=10,  20,20, 0,LP(U->out_nplus), 0,0, CLR_DEF);
    YWnd (Ph(), CHECK, "nminus",85,i+=23, 20,20, 0,LP(U->out_nminus),0,0, CLR_DEF);
    YWnd (Ph(), CHECK, "sum",   85,i+=23, 20,20, 0,LP(U->out_sum),   0,0, CLR_DEF);
    YEndGroup ();
    break;
  case YCLOSE:
    YWndClean (id);
    break;
  default: ;;;
  }

  RETURN_TRUE;
}
/*----------------------------VGrafSetkaUzel------------------------------
VT_GI
VGrafSetkaUzel (VT_SETKA *setka, int u, int v)
{

  return (setka->vv * u + v);

  }*/
/*-----------------------------graf_test-----------------------------------*/
long
graf_test (PFUNC_VAR)
{
  typedef struct {
    ABCD;
  } YT_USR;

  switch (message) {
  case YCREATE:
    U_MALLOC;
    WND->name = "graf_test";
    break;
  case MM_APPLY:
  case MM_DATA:
    YGoto (YMAKE, 0, 0, 0, 0);
    break;
  case YMAKE:
    MGrafTest ();
    break;
  case YGETSIZE:
    MYSIZE_IS (W_MOD, H_MOD);
    break;
  case YOPEN:
  case YDRAW:
    YDrawRectF (0, 0, WND->w, WND->h, WIN->color);
    YDrawString ("...graf_test...", 80, 80, YColor("black"));
    break;
  case YCLOSE:
    YWndClean (id);
    break;
  default: ;;;
  }

  RETURN_TRUE;
}
/*******************************************************************************/


#endif 

/******************************************************************************/
