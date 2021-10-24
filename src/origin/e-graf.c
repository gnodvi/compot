// -*-  mode: c    ; coding: koi8   -*- ----------------------------------------

/*-----------------------------------------------------------------------------*/
/*                                                                             */
/*                            T E S T E R . C                                  */
/*                                                                             */
/*-----------------------------------------------------------------------------*/ 


#include <stdio.h>
#include <stdlib.h> 
#include <string.h>
#include <math.h>
#include <time.h>
#include <unistd.h>
#include <sys/time.h>
#include <sys/param.h>
#include <sys/timeb.h>

#include <semaphore.h>
#include <errno.h>
#include <unistd.h>
#include <limits.h>
#include <libgen.h>
#include <sys/types.h>
#include <stdint.h>


//------------------------------------------------------------------------------

#include "p_gnup.h"

#include "e-comm.h"

#include "e-graf.h"


/*-----------------------------------------------------------------------------*/
/*                                                                             */
/*                              G R A F E R . C                                */
/*                                                                             */
/*-----------------------------------------------------------------------------*/ 


/*------------------------------GrafInit---------------------------------------*/
/*                                                                             */
/*-----------------------------------------------------------------------------*/ 
void
GrafInit (GRAF *graf, int type_nodes, double nod1, double nod2,
                      int type_edges, double edg1, double edg2)
{
  int v, u;

  YRAND_S;

  for (u = 0; u < graf->nn; u++) {
    NODE (graf, u) = YRandF (nod1, nod2);

    //for (v = u; v < graf->nn; v++) {
    for (v = 0; v < graf->nn; v++) {
      EDGE (graf, u, v) = YRandF (edg1, edg2);
    }
  }

  return;
}
/*---------------------------------GrafInit1-----------------------------------*/
/*                                                                             */
/*-----------------------------------------------------------------------------*/ 
void
GrafInit1 (GRAF *graf, double r_edge_all, double r_edge_two)
{
  int v, u;

  YRAND_S;
  
  for (u = 0; u < graf->nn; u++) {
    NODE (graf, u)   = YES;
    EDGE (graf, u, u) = YES;
  }
  
  for (u = 0; u < graf->nn; u++)
  for (v=u+1; v < graf->nn; v++) {
    
    if ((NODE (graf, u)==NOT) || (NODE (graf, u)==NOT))
      continue;
    if (!(RandYes (r_edge_all))) {
      EDGE (graf, u, v) = EDGE (graf, v, u) = NOT;
      continue;
    }
    
    if (RandYes (r_edge_two))  // ребро будет двухнаправленным
      EDGE (graf, u, v) = EDGE (graf, v, u) = YES;
    else {
      if (RandYes(50.0)) {       // ребро будет в одну сторону
        EDGE (graf, u, v) = NOT;
        EDGE (graf, v, u) = YES;
      } else {                   // ребро будет в другую сторону
        EDGE (graf, u, v) = YES;
        EDGE (graf, v, u) = NOT;
      }
    }
  }
  
  return;
}
/*-------------------------------GrafCreate------------------------------------*/
/*                                                                             */
/*-----------------------------------------------------------------------------*/ 
GRAF *
GrafCreate (int nn)
{
  GRAF *graf;
  int v, u;

  graf = (GRAF*) malloc (sizeof(GRAF));
  graf->nn = nn;

  graf->edges = (double*) malloc (sizeof(double) * nn*nn);
  graf->nodes = (double*) malloc (sizeof(double) * nn   );

  graf->wk = GrafWorkCreate (graf);

  for (u = 0; u < graf->nn; u++)
    NODE (graf, u) = NOT;

  for (u = 0; u < graf->nn; u++)
  for (v = 0; v < graf->nn; v++)
    EDGE (graf, u, v) = NOT;

  return (graf);
}
/*-------------------------------GrafDestroy-----------------------------------*/
/*                                                                             */
/*-----------------------------------------------------------------------------*/ 
void
GrafDestroy (GRAF *graf)
{

  GrafWorkDelete (graf->wk);

  free (graf->nodes);
  free (graf->edges);

  free (graf);

  return;
}
/*-----------------------------GrafEdge----------------------------------------*/
/*                                                                             */
/*-----------------------------------------------------------------------------*/ 
double *
GrafEdge (GRAF *graf, int u, int v)
{
  /* int rab; */

  if ((u<0) || (u>= graf->nn)) YERROR ("GrafEdge");
  if ((v<0) || (v>= graf->nn)) YERROR ("GrafEdge");

  // оптимизация для только ненаправленных графов
  /*   if (u > v) {  */
  /*     rab = v; */
  /*     v = u; */
  /*     u = rab; */
  /*   } */
  
  return ((graf->edges) + u*(graf->nn) + v);
}
/*--------------------------------GrafPrint------------------------------------*/
/*                                                                             */
/*-----------------------------------------------------------------------------*/ 
void
GrafPrint (GRAF *pg)
{
  int    v, u;
  double val;
  
  //  set nn [$gr.NN] 
  int nn = pg->nn;
  
  printf ("------------------------------- \n");

  printf ("NN    = %d \n", nn);
  //  puts "NODES = [$gr.NODES]"
  //  puts "EDGES = [arr2d_print [$gr.EDGES]]"
  
  //  puts -nonewline [format "   | "]
  
  //  dotimes u $nn { 
  //    puts -nonewline [format "  %2d " $u]
  //  }
  
  printf ("\n");
  printf ("------------------------------- \n");
  
  for (u = 0; u < pg->nn; u++) {
  //    puts -nonewline [format "%2d | " $u]
  for (v = 0; v < pg->nn; v++) {

    val = EDGE (pg, u, v);
    //      set val [EDGE_get $gr $u $v]
    
    if      (val == NOT) printf ("  o  ");
    else if (val == YES) printf ("  *  ");
    else
      printf ("% #5.1f ", val);
    
    //      if     {$val == "NOS"}         {puts -nonewline [format "  o  "]} \
    //      elseif {$val == "YES"}         {puts -nonewline [format "  *  "]} \
    //      elseif {[llength $val] > 1}    {puts -nonewline [format "  .  "]} \
    //      else                           {puts -nonewline [format " %3.1f " $val]}
    
  }
  
  printf ("\n");
  //    puts -nonewline [format "\n"]
  }
  
  printf ("\n");
  
  //  puts -nonewline [format "------------------------------- \n"]
  
  return;
}
/*----------------------------GrafGetSosed-------------------------------------*/
/*                                                                             */
/*-----------------------------------------------------------------------------*/ 
BOOL
GrafGetSosed (GRAF *graf, int uzel, int *sosed)
{
  static GRAF *g;
  static int uz;
  static int i;

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
    if (EDGE (g, uz, i) == NOT)
      continue;
    *sosed = i;
    return (TRUE);
  }

}
/*-----------------------------GrafGetSum--------------------------------------*/
/*                                                                             */
/*-----------------------------------------------------------------------------*/ 
double
GrafGetSum (GRAF *pg, int u)
{
  double  sum;
  int     sosed, num_sosed;

  sum = num_sosed = 0;

  GrafGetSosed (pg, u, &sosed);

  while (GrafGetSosed (NULL, 0, &sosed)) {
    sum += (EDGE(pg, u, sosed) * NODE(pg, sosed));
    num_sosed++;
  }
  sum = sum/num_sosed;

  return (sum);
}
/*-----------------------------GrafWorkCreate----------------------------------*/
/*                                                                             */
/*-----------------------------------------------------------------------------*/ 
WORKS *
GrafWorkCreate (GRAF *pg)
{
  WORKS *wk;
  int nn = pg->nn;

  if (!(wk = (WORKS *) malloc (sizeof (WORKS))))      YERROR ("GrafWork");

  wk->puti = (int *) malloc (sizeof(int) * nn * nn);
  wk->met  = (METKA *) malloc (sizeof(METKA) * nn);

  return (wk);
}
/*-----------------------------GrafWorkDelete----------------------------------*/
/*                                                                             */
/*-----------------------------------------------------------------------------*/ 
void
GrafWorkDelete (WORKS *wk)
{

  if (wk == NULL)  return;

  free (wk->met);
  free (wk->puti);
  free (wk);

  return;
}
/*------------------------------GrafSmin---------------------------------------*/
/*                                                                             */
/*-----------------------------------------------------------------------------*/ 
BOOL
GrafSmin (GRAF *graf, int s, int t, double *smin)
{

  int j, v, v_min, p;
  static WORKS *wk = NULL;
  static GRAF *pg = NULL;
  METKA *met;
  double sum, l_min;

  /*   if (pg != graf) { */
  /*     pg = graf; */
  /*     GrafWorkDelete (wk); */
  /*     wk = GrafWorkCreate (pg); */
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
      if (EDGE (pg, p, v) == NOT)
				continue;
      if (met[v].fix)
				continue;

      sum = met[p].l + EDGE (pg, p, v);
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

  if (smin == NULL)  GrafWorkPrint (wk);
  else               *smin = wk->smin;

  return (TRUE);
}
/*----------------------------GrafAllSmin--------------------------------------*/
/*                                                                             */
/*-----------------------------------------------------------------------------*/ 
BOOL
GrafAllSmin (GRAF *graf, int s, double *all)
{

  BOOL *list;
  int num, u, v, nn = graf->nn;
  double mini, val_uv;

  num = nn;
  /* YMALLOC (list, BOOL, nn); */
  if (!(list = (BOOL*)malloc (sizeof(BOOL) * nn))) YERROR ("GrafAllSmin");
  for (v = 0; v < nn; v++)  list[v] = TRUE;

  for (v = 0; v < nn; v++) {
    all[v] = EDGE (graf, s, v);
    if (all[v] == NOT)  all[v] = MAXVAL;
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
      val_uv = EDGE (graf, u, v);
      if (val_uv == NOT)  val_uv = MAXVAL;
      all[v] = YMIN (all[v], all[u] + val_uv);
    }
  }

  free (list);
  return (TRUE);
}
/*-----------------------------GrafNewNode-------------------------------------*/
/*                                                                             */
/*-----------------------------------------------------------------------------*/ 
BOOL
GrafNewNode (GRAF *graf, int *pu)
{
  int u;

  for (u = 0; u < graf->nn; u++) {
    if (NODE (graf, u) == NOT) break;
  }
  if (u == graf->nn) {
    return (FALSE);
  }

  if (pu) *pu = u;

  return (TRUE);
}
/*-----------------------------GrafWorkPrint-----------------------------------*/
/*                                                                             */
/*-----------------------------------------------------------------------------*/ 
void
GrafWorkPrint (WORKS *wk)
{
  int v, num;

  fprintf (stderr, "--------------------------\n");
  fprintf (stderr, "S = %d \n", wk->s);
  fprintf (stderr, "T = %d \n", wk->t);
  fprintf (stderr, "L_min = %f \n", wk->smin);

  for (v = 0; wk->puti[v] != -1; v++) ;;;
  num = v;

  for (v=num-1; v >= 0; v--) {
    fprintf (stderr, "%d", wk->puti[v]);
    if (v != 0)
      fprintf (stderr, "_");
  }

  fprintf (stderr, "\n------------------------\n");

}
/*-----------------------------GrafReMax---------------------------------------*/
/*                                                                             */
/*-----------------------------------------------------------------------------*/ 
void
GrafReMax (GRAF *old)
{
  int u, v, new_nn;
  GRAF *new_graf;
  
  new_nn = (int) (old->nn * 1.25);
  new_graf = GrafCreate (new_nn);
  //printf ("GrafReMax: new_nn=%d \n", new_nn);
  
  for (u = 0; u < old->nn; u++)
    NODE (new_graf, u) = NODE (old, u);
  
  for (u = 0; u < old->nn; u++)
  for (v = 0; v < old->nn; v++)
    EDGE (new_graf, u, v) = EDGE (old, u, v);
  
  free (old->nodes);
  free (old->edges);
  
  old->nodes = new_graf->nodes;
  old->edges = new_graf->edges;
  old->nn    = new_graf->nn;
  
  free (new_graf);
  
  return;
}
/*-----------------------------GrafDelNode-------------------------------------
*/
/*                                                                             */
/*-----------------------------------------------------------------------------*/ 
BOOL
GrafDelNode (GRAF *graf, int u)
{
  int v;

  if (u < 0 || u >= graf->nn)  return (FALSE);
  if (NODE (graf, u) == NOT)   return (FALSE);

  NODE (graf, u) = NOT;
  for (v = 0; v < graf->nn; v++)
    EDGE (graf, u, v) = NOT;

  return (TRUE);
}
/*-----------------------------GrafSubNode-------------------------------------*/
/*                                                                             */
/*-----------------------------------------------------------------------------*/ 
void
GrafSubNode (GRAF *graf, int u)
{
  int v1, v2;

  for (v1 = 0; v1 < graf->nn; v1++) {
    if (u == v1) continue;
    if (EDGE (graf, v1, u) == NOT) continue;
    // найден вход
    for (v2 = 0; v2 < graf->nn; v2++) {
      if (u == v2) continue;
      if (EDGE (graf, u, v2) == NOT) continue;
      // найден выход
      EDGE (graf, v1, v2) = YES;
    }
  }
  
  return;
}
/*-------------------------------GrafEdgesCopy---------------------------------*/
/*                                                                             */
/*-----------------------------------------------------------------------------*/ 
void
GrafEdgesCopy (GRAF *graf_from, int u_from, GRAF *graf_to, int u_to)
{
  int v;
  double edge;
  
  //for (v=0; v < graf_from->nn; v++) { // только односторонние?
  //  EDGE (graf_to, u_to, v) = EDGE (graf_from, u_from, v);
  //}
  
  for (v=0; v < graf_from->nn; v++) { 
    if (u_from == v) continue;
    
    if (EDGE(graf_from,u_from,v)==YES) EDGE(graf_to,u_to,v) = EDGE(graf_from,u_from,v);
    if (EDGE(graf_from,v,u_from)==YES) EDGE(graf_to,v,u_to) = EDGE(graf_from,v,u_from);
  }
  
  return;
}
/*-----------------------------GrafAllToNode-----------------------------------*/
/*                                                                             */
/*-----------------------------------------------------------------------------*/ 
void
GrafAllToNode (GRAF *graf, int node)
{
  int new_node, u;

  // 
  GrafAddNode (graf, &new_node, YES);

  for (u=0; u < graf->nn; u++) {
    if (node == u) continue;
    if ((EDGE(graf, node,u)==NOT) && (EDGE(graf, u,node)==NOT)) continue;
    // нашли непустой узел - соседа "u"
		
    GrafEdgesCopy (graf, u, graf, new_node); // скопировать-добавить
    GrafDelNode (graf, u); // удалили за ненадобностью
  }

  GrafDelNode (graf, node); // теперь удалили и сам исходный узел

  return;
}
/*-------------------------------GrafCopy--------------------------------------*/
/*                                                                             */
/*-----------------------------------------------------------------------------*/ 
void
GrafCopy (GRAF *graf, GRAF *graf_new)
{
  int u, v;

  for (u = 0; u < graf->nn; u++) {
    NODE (graf_new, u) = NODE (graf, u);

    for (v = 0; v < graf->nn; v++)
      EDGE (graf_new, u, v) = EDGE (graf, u, v);
  }

  return;
}
/*-----------------------------GrafGetNum--------------------------------------*/
/*                                                                             */
/*-----------------------------------------------------------------------------*/ 
int
GrafGetNum (GRAF *graf, double node)
{
  int num_nodes, u;

  num_nodes=0;

  for (u = 0; u < graf->nn; u++) {
    if (NODE (graf, u) == /* YES */node)
      num_nodes++;
  }

  return (num_nodes);
}
/*-----------------------------GrafGetNumNodes---------------------------------*/
/*                                                                             */
/*-----------------------------------------------------------------------------*/ 
int
GrafGetNumNodes (GRAF *graf)
{
  int num_nodes, u;

  num_nodes=0;

  for (u = 0; u < graf->nn; u++) {
    if (NODE (graf, u) == NOT) continue;
      num_nodes++;
  }

  return (num_nodes);
}
/*-----------------------------GrafEdgesFill-----------------------------------*/
/*                                                                             */
/*-----------------------------------------------------------------------------*/ 
void
GrafEdgesFill (GRAF *graf, int u, double edge)
{
  int v;

  for (v = 0; v < graf->nn; v++)
    EDGE (graf, u, v) = edge;

  return;
}
/*-----------------------------GrafAddNode-------------------------------------*/
/*                                                                             */
/*-----------------------------------------------------------------------------*/ 
void
GrafAddNode (GRAF *graf, int *pu, double node)
{
  int u;

  if (!GrafNewNode (graf, &u)) {
    u = graf->nn;
    GrafReMax (graf);
  }

  NODE (graf, u) = node;

  if (pu) *pu = u;

  return /* (TRUE) */;
}
/*----------------------------GrafGetEdges-------------------------------------*/
/*                                                                             */
/*-----------------------------------------------------------------------------*/ 
BOOL
GrafGetEdges (GRAF *pgraf, double *pedge, int *pu, int *pv)
{
  static int    u, v, nn;
  static GRAF   *pg;
  static double *pedge_mem;
  static int    *pu_mem, *pv_mem;

  double edge;

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
	//-----------------

  while (TRUE) {
    if (v >= nn) {
      u++;
      v = u + 1;
    }
    if (u >= nn - 1)
      return (FALSE);

    edge = EDGE (pg, u, v);
    v++;
    if (edge != NOT)
      break;
  }

	//printf ("edge = %f \n", edge);

  if (pedge == NULL)  pedge = pedge_mem;
  if (pu == NULL)     pu = pu_mem;
  if (pv == NULL)     pv = pv_mem;

  if (pedge != NULL)  *pedge = edge;
  if (pu != NULL)     *pu = u;
  if (pv != NULL)     *pv = v - 1;

  return (TRUE);
}
/*-------------------------------GetNumEdges-----------------------------------*/
/*                                                                             */
/*-----------------------------------------------------------------------------*/ 
void
GetNumEdges (GRAF *graf, int *one_edges, int *two_edges, int *all_edges)
{

  int num_one_edges, num_two_edges, num_all_edges;
  int u, v;
  
  num_one_edges=0;
  num_two_edges=0;
  
  for (u = 0; u < graf->nn; u++)
  for (v=u+1; v < graf->nn; v++) {
    
    if ((EDGE(graf, u, v)==NOT) && (EDGE(graf, v, u)==NOT))
      continue;
    
    if ((EDGE(graf, u, v)!=NOT) && (EDGE(graf, v, u)!=NOT))
      num_two_edges++;
    else
      num_one_edges++;
  }
  
  num_all_edges = num_one_edges + num_two_edges;
  
  if (one_edges) *one_edges = num_one_edges;
  if (two_edges) *two_edges = num_two_edges;
  if (all_edges) *all_edges = num_all_edges;
  
  return;
}
/*--------------------------------GrafMetrica----------------------------------*/
/*                                                                             */
/*-----------------------------------------------------------------------------*/ 
void
GrafMetrica (GRAF *pg, double *rr, double *dd, int *num_rr, int *num_dd)
{

  int      i, j;
  double   all[10000];
  double   r, d, e;
  int      num_r, num_d;
  
  //YMALLOC (all, double, pg->nn);
  
  r = MAXVAL; // радиус
  d = MINVAL; // окраина
  num_r = 0;  // количество узлов в центре
  num_d = 0;  // количество узлов на окраине
  
  for (i=0; i < pg->nn; i++) {
    GrafAllSmin (pg, i, all); // кратчайшие расстояния от этой вершины до остальных
    
    // ищем эксцентриситет этой вершины
    e = MINVAL;
    for (j=0; j < pg->nn; j++) {
      if (i == j) continue;
      if (all[j] == MAXVAL) continue;
      e = YMAX (e, all[j]);
    }
    //printf ("%d  %f \n", i, e);
    
    if      (e <  r) {r = e; num_r = 1;} // ищем радиус 
    else if (e == r) num_r++; // и считаем кол-во таких центральных точек 
    
    if      (e >  d) {d = e; num_d = 1;} // ищем диаметр 
    else if (e == d) num_d++; // и считаем кол-во таких окраиных точек 
  }
  
  
  *rr = r;  *num_rr = num_r;
  *dd = d;  *num_dd = num_d;
  
  //free (all);
  
  return;
}
/*-------------------------------GrafCalcOut-----------------------------------*/
/*                                                                             */
/* расчет и вывод на каждом шаге различных характеристик графа */
/*-----------------------------------------------------------------------------*/ 
YT_PLOT*
GrafCalcOut (int mod, GRAF *graf, ZT_OUT *p_out, int xnum)
{

  BOOL   to_term = 1;
  static int step;
  int    u, v;
  int    num_nodes, num_one_edges, num_two_edges, num_all_edges;
  
  ZT_OUT *out1, *out2, *out3, *pout;
  ZT_OUT *out_rmin, *out_rmax, *out_nminus, *out_nplus, *out_nnull, *out_sum, *out_metr,
    *out_r, *out_d, *out_numr, *out_numd;
  
#define OUTPLOT(p,val,step) ((p)->f)[(step)]=(val);

#define OUTINT(p,val,step) {OUTPLOT(p,val,step); if (to_term) printf ("%3d  ", (val));}
#define OUTDBL(p,val,step) {OUTPLOT(p,val,step); if (to_term) printf ("%.2f  ", (val));}
#define OUT(v) ((v) && (v)->val)

  double  rmin, rmax, sum;
  int     metr, nnull, nplus, nminus;
  double  value;

  int     i, j, k;
  double  i_j, j_k, k_i;

  double  r, d;
  int     num_r, num_d;
  
  /* --------------- подготовка к выводу */
  if (mod == 1) {
    step = 0;
    Do_Open_Close (p_out, mod, xnum);
    
    return;
  }
  /* --------------- завершение вывода --*/
  if (mod == 3) {
    Do_Open_Close (p_out, mod, xnum);
    //DemOut (p_out);
    return;
  }
  //======================================
  
  
  if (to_term) printf ("%3d  ", step);
  //step++;
  Do_Open_Close (p_out, mod, xnum);
  
  /*------- количесиво узлов в графе ----*/
  pout = Out (p_out, "Nodes");
  if (pout && pout->val) {
    num_nodes = GrafGetNumNodes (graf);
    
    OUTINT (pout, num_nodes, step);
  }
  
  /*------ количесиво ребер в графе -----*/
  out1 = Out (p_out, "One_Edges");
  out2 = Out (p_out, "Two_Edges");
  out3 = Out (p_out, "All_Edges");

  if ((out1 && out1->val) || (out2 && out2->val) || (out3 && out3->val)) {
    
    GetNumEdges (graf, &num_one_edges, &num_two_edges, &num_all_edges);
    
    if (out1 && out1->val)  OUTINT (out1, num_one_edges, step);
    if (out2 && out2->val)  OUTINT (out2, num_two_edges, step);
    if (out3 && out3->val)  OUTINT (out3, num_all_edges, step);
  }
  
  /*------------------------------------*/

  out_rmin   = Out (p_out, "Rmin");
  out_rmax   = Out (p_out, "Rmax");
  out_nminus = Out (p_out, "Nminus");
  out_nplus  = Out (p_out, "Nplus");
  out_nnull  = Out (p_out, "Nnull");
  out_sum    = Out (p_out, "Sum");
  out_metr   = Out (p_out, "Metr");
  
  out_r      = Out (p_out, "R");
  out_d      = Out (p_out, "D");
  out_numr   = Out (p_out, "NumR");
  out_numd   = Out (p_out, "NumD");
  
  nminus = 0;
  nplus  = 0;
  nnull  = 0;
  rmin   =  1000000;
  rmax   = -1000000;
  sum    = 0;


  /*   GrafGetEdges (graf, &value, NULL, NULL); */
  /*   while (GrafGetEdges (NULL, NULL, NULL, NULL)) { */

  for (u = 0; u < graf->nn; u++)
  for (v = 0; v < graf->nn; v++) {
    //if (u == v) continue;
    if (EDGE(graf, u, v)==NOT) continue;
    value = EDGE (graf, u, v);

    rmin = YMIN (rmin, value);
    rmax = YMAX (rmax, value);
    if (value < 0 )  nminus++;
    if (value > 0 )  nplus++;
    if (value == 0)  nnull++;
		sum += value;
  }

  // Ошибка при маленьких размерностях ???
  GrafMetrica (graf, &r, &d, &num_r, &num_d);

  if (OUT(out_metr)) {
    metr = 0;
    for (i=0;   i <= graf->nn-3; i++)	/*??? */
    for (j=i+1; j <= graf->nn-2; j++)
    for (k=j+1; k <= graf->nn-1; k++) {
      i_j = EDGE (graf, i, j);
      j_k = EDGE (graf, j, k);
      k_i = EDGE (graf, k, i);
      if ((i_j <= k_i + j_k) && (j_k <= i_j + k_i) && (k_i <= j_k + i_j))
				metr++;
    }
  }


  if (OUT(out_rmin))   OUTDBL (out_rmin, rmin,step);
  if (OUT(out_rmax))   OUTDBL (out_rmax, rmax,step);
  if (OUT(out_nminus)) OUTINT (out_nminus, nminus, step);
  if (OUT(out_nplus))  OUTINT (out_nplus,  nplus, step);
  if (OUT(out_nnull))  OUTINT (out_nnull,  nnull, step);
  if (OUT(out_sum))    OUTDBL (out_sum, sum,step);
  
  if (OUT(out_metr))   OUTINT (out_metr, metr, step);
  
  if (OUT(out_r))      OUTDBL (out_r, r,step);
  if (OUT(out_d))      OUTDBL (out_d, d,step);
  if (OUT(out_numr))   OUTINT (out_numr, num_r, step);
  if (OUT(out_numd))   OUTINT (out_numd, num_d, step);
  /*--------------------------------------*/
  
  
  if (to_term) printf ("\n");
  
  step++;

  return;
}
/*-------------------------------GrafCheck-------------------------------------*/
/*                                                                             */
/*-----------------------------------------------------------------------------*/ 
void
GrafCheck (GRAF *graf)
{

  int  /* edge, */ u, v;
	double node_u, node_v;
  BOOL exist_edges;

  for (u = 0; u < graf->nn; u++)
  for (v = 0; v < graf->nn; v++) {

    if (EDGE (graf, u, v) == NOT)
      continue;
    
    node_u = NODE (graf, u);
    node_v = NODE (graf, v);

    if ((node_u == NOT) || (node_v == NOT))
      // нет концов у существующего ребра, значит "удалить" ребро:
      EDGE (graf, u, v) = NOT;
  }
  

  for (u=0; u < graf->nn; u++) {
    if (NODE (graf, u) == NOT) continue;

    exist_edges = FALSE;
    for (v = 0; v < graf->nn; v++)
      //if (EDGE (graf, u, v) == YES)
      if (EDGE (graf, u, v) != NOT)
				exist_edges = TRUE;

		// для существующего узла нет ни одного ребра, значит "удалить" узел:
    if (!exist_edges) NODE (graf, u) = NOT;
  }

  return;
}
/*******************************************************************************/
/*-----------------------------------------------------------------------------*/
/*                                                                             */
/*                                 M A I N . C                                 */
/*                                                                             */
/*-----------------------------------------------------------------------------*/ 







/*-------------------------------make_plot_test--------------------------------*/
/*                                                                             */
/*-----------------------------------------------------------------------------*/
YT_PLOT*
make_plot_test (int n, double fi_min, double fi_max)
{

  YT_PLOT *plot;
  int    i;
  double fi_step;
  double *f_sin, *f_cos;

  plot = plot_create (2, n,1);
  f_sin = (double*) malloc (n * sizeof(double));
  f_cos = (double*) malloc (n * sizeof(double));

  fi_step = (fi_max - fi_min) / (n - 1);

  for (i=0 ; i<n ; i++) {
    plot->x[i] = fi_min + fi_step * i;
    f_sin[i] = sin (plot->x[i]);
    f_cos[i] = cos (plot->x[i]);
  }

  plot->f[0][0] = f_sin;
  plot->f[0][1] = f_cos;

  plot->f[1][0] = f_sin;
  plot->f[1][1] = NULL;

  strcpy (plot->title[0], "Test for Plot");
  plot->l_name[0][0] = "Sinus";
  plot->l_name[0][1] = "Cosin";
  plot->l_name[1][0] = "Sinus";

  return (plot);
}
/*--------------------------------find_new_node--------------------------------*/
/*                                                                             */
/*-----------------------------------------------------------------------------*/ 
int
find_new_node (GRAF *graf, int cur_node)
{
  int u;

  for (u = 0; u < graf->nn; u++) {
    if (EDGE (graf, cur_node, u) == NOT) continue;
    if (RandYes(80.0)) continue;

    //new_node = u;
    break;
  }
  //new_node = YRAND (0, graf->nn-1);

  return (u);
}
//------------------------------------------------------------------------------
void
get_options_print_help () 
{

  printf ("\n");
  printf ("USE: \n");
  printf ("./s_dial -t* -p* -o* \n");
  printf ("\n");      
  
}
//------------------------------------------------------------------------------
void
options_warning_NULL (char c) {

  fprintf (stderr, "\n");
  fprintf (stderr, "WARNING OPTIONS: pointer to -%c == NUL !! \n", c);
  //fprintf (stderr, "\n");

  return;
}
//------------------------------------------------------------------------------
void
get_options (int argc, char **argv, 
             char     *p_ip_buf, 
             uint16_t *port, 
             double   *interval_ms,
             int *count_max, 
             int *count_out, int *is_verbose, int *test_num,
             int *user_flag)
{
  char c;

  // optarg - указатель на текущий аргумент, если таковой имеется
  // optind - индекс на след. указатель argv (будет обработан при след. вызове)

  optind = 1; // чтобы бы повторном (вложенном вызове) начать с начала 

  //fprintf (stderr, "\n");
  //fprintf (stderr, "get_options: BEGIN  optind = %d   \n", optind);

  //if (argc == 1) {
  //  get_options_print_help ();
  //  return;
  //}
    

  // перебираем все параметры:
  // (в QNX эти параметры должны идти первыми)

  while ((c = getopt (argc, argv, "uha:p:i:n:o:vt:")) != -1) { 

    //fprintf (stderr, "get_options: optind = %d   c = %c \n", optind, c);

    switch (c) {

    case 'a': // IP-адрес
      if (p_ip_buf) strcpy (p_ip_buf, optarg); 
      else              options_warning_NULL (c);
      break;

    case 'p': 
      if (port) *port = atoi (optarg); 
      else              options_warning_NULL (c);
      break;

    case 'i': 
      if (interval_ms) *interval_ms = atoi (optarg); 
      else              options_warning_NULL (c);
      break;

    case 'n': 
      if (count_max) *count_max = atoi (optarg); 
      else            options_warning_NULL (c);
      break;

    case 'o': 
      if (count_out) *count_out = atoi (optarg); 
      else            options_warning_NULL (c);
      break;

    case 'v':     // verbose - многословный
      if (is_verbose) *is_verbose  = 1; // подробная печать 
      else             options_warning_NULL (c);
      break;

    case 't': 
      if (test_num) *test_num = atoi (optarg); 
       else          options_warning_NULL (c);
     break;

    case 'u':    
      if (user_flag) *user_flag  = 1;
      else           options_warning_NULL (c);
      break;

    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    case 'h': 
      get_options_print_help (); 
      break;


    default:      
      exit( EXIT_FAILURE ); // сюда невозможно попасть!
    }
  }

  //fprintf (stderr, "get_options: END \n");

  return;
}
/*------------------------------------main-------------------------------------*/
/*                                                                             */
/*--------------------------------more_graf_test-------------------------------*/
/*                                                                             */
/*-----------------------------------------------------------------------------*/ 
void
test_00 (int nn)
{
  GRAF *graf;
  int u;

  graf = GrafCreate (nn);

  GrafInit1 (graf, 50.0, 50.0);
  GrafPrint (graf);

  GrafCheck (graf);
  GrafPrint (graf);

  GrafAddNode (graf, &u, YES);
  GrafEdgesFill (graf, u, YES);
  GrafPrint (graf);

  GrafCheck (graf);
  GrafPrint (graf);

  GrafDelNode (graf, u);
  GrafPrint (graf);

  return;
}
/*-----------------------------main_graf_test----------------------------------*/
/*                                                                             */
//# ;-------------------------------------------------------------------------------
//proc test_01 {} { 

  
//  YRAND_C
  
//  set gr [graf_create 4]

//  EDGE_set $gr 0 1  1
//  EDGE_set $gr 1 2  1
//  EDGE_set $gr 2 3  1
//  EDGE_set $gr 0 3  3.1 ;#3.1 2.9
  
//  NODE_set $gr 0   2.2
  
//  set s   0
//  set tar 3

//  puts -nonewline [format "\n"]
//  graf_print $gr

//  graf_smin  $gr $s $tar $::NIL
  
//}
/*-----------------------------------------------------------------------------*/ 
void
test_01 ()
{

  GRAF *pg;
  int   s, t, nn;
  double  r, d;
  int     num_r, num_d;


  pg = GrafCreate (4);
  
  //GrafInit (pg, YCONST, 0.0, 0.0, YCONST, NOT, 0.0);
  GrafInit (pg, YRAND, 0.0, 0.0, YRAND, NOT, NOT);
  
  EDGE (pg, 0, 1) = 1;
  EDGE (pg, 1, 2) = 1;
  EDGE (pg, 2, 3) = 1;
  EDGE (pg, 0, 3) = 3.1 /* 2.9 */;
  
  s = 0;
  t = 3;
  
  printf ("\n");
  GrafPrint (pg);

  GrafSmin (pg, s, t, NULL);
  printf ("\n");

  GrafMetrica (pg, &r, &d, &num_r, &num_d);

  printf ("r = %.1f  num_r = %d \n", r, num_r);
  printf ("d = %.1f  num_d = %d \n", d, num_d);

  return;
}
/*-----------------------------------------------------------------------------*/ 
void
test_11 ()
{

  GRAF *pg;
  int   s, t, nn;
  double  r, d;
  int     num_r, num_d;


  nn = 6;
  pg = GrafCreate (nn);
  //GrafInit (pg, YCONST, 0.0, 0.0, YCONST, 5.0, 0.0);
  GrafInit (pg, YRAND, 0.0,5.0, YRAND, 0.0,5.0);
  
  YRAND_S;
  
  //s = YRAND (0, nn - 1);
  //t = YRAND (0, nn - 1);
  

  printf ("\n");
  GrafPrint (pg);

  //GrafSmin (pg, s, t, NULL);
  //printf ("\n");

  GrafMetrica (pg, &r, &d, &num_r, &num_d);

  printf ("r = %.1f  num_r = %d \n", r, num_r);
  printf ("d = %.1f  num_d = %d \n", d, num_d);

  return;
}
/*-----------------------------------------------------------------------------*/ 
//------------------------------------------------------------------------------
// 
//------------------------------------------------------------------------------
