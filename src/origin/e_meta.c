// -*-  mode: c    ; coding: koi8   -*- ----------------------------------------

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

/*-----------------------------------------------------------------------------*/ 


#include "e-comm.h"

#include "e-graf.h"


/*-----------------------------------------------------------------------------*/
/*                                                                             */
/*                                Model "000"                                  */
/*                                                                             */
/*-----------------------------------------------------------------------------*/ 

/*---------------------------------dao_loop0--------------------------------*/
/*                                                                             */
/*-----------------------------------------------------------------------------*/ 
int
dao_loop0 (int argc, char *argv[])
{
  static int point;
  double  sum;
  int     new_point, rab_point;
  static double edge;
  static BOOL isplus = FALSE;
  static int  /* n, */ imin=-100, imax=100/* , point, model */;
  //static long nedges;

  GRAF *graf;
  int   i;
  //int model =   4;   // Значение на проходном ребре стремится к среднему 
  // по всем ребрам из текущей точки
  int   model =   1;   
  int   n     =  100;

  //int   steps =  10000;
  int   steps =  100;

  int   steps_out = 1;

  //typedef struct {
  //	int     numw;
  //	char    *legend; //const char *legend;
  //	BOOL    val;
  //	double  *f;
  //} ZT_OUT;

  static ZT_OUT out[MAX_OUT] = {

    {1, "Nodes"    ,  TRUE,  NULL},

    {2, "Rmax",   1,  NULL},
    {2, "Rmin",   1,  NULL},

    /*     {3, "Nminus", 1,  NULL}, */
    /*     {3, "Nplus",  1,  NULL}, */
    /*     {3, "Nnull",  1,  NULL}, */

    /*     {2, "D",      1,  NULL}, */
    /*     {2, "R",      1,  NULL}, */
    /*     {3, "NumD",   1,  NULL}, */
    /*     {3, "NumR",   1,  NULL}, */

    /*     {4, "Nminus", 1,  NULL}, */
    /*     {4, "Nplus",  1,  NULL}, */
    /*     {4, "Nnull",  1,  NULL}, */

    /*     {2, "Sum",    0,  NULL}, */
    /*     {1, "Metr",   0,  NULL}, */

    {0,  NULL, 0, NULL}
  };

  ZT_OUT *p_out = &out[0];


  //------------------------
  graf = GrafCreate (n);
  //GrafInit (graf, YCONST,0.0,0.0, YCONST,0.0,0.0);
  GrafInit (graf, YRAND, 0.0,0.0, YRAND, 0.0,0.0);

  point  =    0;
  //n      = pg->nn;
  //nedges = (n * n - n) / 2;
  YRAND_S;
  //------------------------


  GrafCalcOut (1, NULL, p_out, steps);

  for (i=0; i < steps; i++) {

    if (!(i%steps_out)) GrafCalcOut (2, graf, p_out, steps);

    new_point = YRAND (0, graf->nn-1);
    /* 	if (new_point == point)  */
    /* 		return; */
		
    switch (model) {
    case 1:			/*Simple */
      if (isplus) (EDGE (graf, point, new_point))++;
      else        (EDGE (graf, point, new_point))--;
      isplus = !isplus;
      break;
    case 2:			/*Triang */
      rab_point = YRAND (0, graf->nn-1);
      if (rab_point == point || rab_point == new_point)
        break;
      if (EDGE (graf, point, new_point) >=
          EDGE (graf, point, rab_point) +
          EDGE (graf, rab_point, new_point)) {
        (EDGE (graf, point, new_point))--;
        (EDGE (graf, point, rab_point))++;
      }
      break;
    case 3:			/*All-Plus */
      (EDGE (graf, point, new_point))++;
			
      break;
    case 4:			/*Median */
      sum = 0;
      GrafGetEdges (graf, &edge, NULL, NULL);
      while (GrafGetEdges (NULL, &edge, NULL, NULL))
        sum += edge;
      sum = sum / /* nedges */(graf->nn*graf->nn-graf->nn) / 2;
      if (EDGE (graf, point, new_point) > sum)
        (EDGE (graf, point, new_point))--;
      else
        (EDGE (graf, point, new_point))++;
      break;
    default:
      Error ("Calc_model not found !");
      break;
    }
		
    //if (EDGE (pg, point, new_point) > imax)
    //	EDGE (pg, point, new_point) = imin;
    point = new_point;
  }

  GrafCalcOut (3, NULL, p_out, steps);
	
  argc++; argv++;

  return 1;
}
/*******************************************************************************/
/*-----------------------------------------------------------------------------*/
/*                                                                             */
/*                                  DAO-INFO                                   */
/*                                                                             */
/*-----------------------------------------------------------------------------*/ 

/*------------------------------dao_edges_mutaciq------------------------------*/
/*                                                                             */
/*-----------------------------------------------------------------------------*/ 
void
dao_edges_mutaciq (GRAF *graf, int u, double mutaciq)
{
  int v;
  double edge;

  for (v=0; v < graf->nn; v++) {
    edge = EDGE (graf, u, v);

    if (RandYes(mutaciq) && edge==YES)
      edge = NOT;

    EDGE (graf, u, v) = edge;
  }

  return;
}
/*------------------------------dao_addnode_copys------------------------------*/
/*                                                                             */
/*-----------------------------------------------------------------------------*/ 
void
dao_addnode_copys (GRAF *graf, GRAF *graf_new, int cur_node)
{
  int  new_node;

  GrafAddNode (graf_new, &new_node, YES);

  GrafEdgesCopy (graf, cur_node, graf_new, new_node);

  dao_edges_mutaciq (graf_new, new_node, 10.0);
				
  if (RandYes(30))  EDGE (graf_new, cur_node, new_node) = YES;
  if (RandYes(30))  EDGE (graf_new, new_node, cur_node) = YES;

  return;
}
/*------------------------------dao_addnode_clone------------------------------*/
/*                                                                             */
/*-----------------------------------------------------------------------------*/ 
void
dao_addnode_clone (GRAF *graf, int node)
{
  int u, v,  i, j, index;
  int new_node;
  int s[1000];

  // инициализация списка
  index = 0;

  // клонируем входы-выходы и составляем их список
  for (u=0; u < graf->nn; u++) {
    //if (u == node) continue;
    if (EDGE (graf, u, node) == NOT) continue;
    if (EDGE (graf, node, u) == NOT) continue;

    GrafAddNode (graf, &new_node, YES); // клонирование и копирование
    EDGE (graf, new_node, u) = EDGE (graf, node, u);
    EDGE (graf, u, new_node) = EDGE (graf, u, node);

    s[index++] = new_node; // заносим в список номер нового узла
  }
  s[index] = -1; // завершить список

  //  соединить каждую точку с каждой (простейший вариант)
  for (i=0; s[i] != -1; i++) 
    for (j=0; s[j] != -1; j++) {
      EDGE (graf, s[i], s[j]) = EDGE (graf, s[j], s[i]) = YES;
    }

  // удаляем начальную точку
  GrafDelNode (graf, node);

  return;
}
/*--------------------------------dao_addnode----------------------------------*/
/*                                                                             */
/*-----------------------------------------------------------------------------*/ 
void
dao_addnode (GRAF *graf, GRAF *graf_new, int node)
{

  switch (2) {
  case 1: // простое копирование с мутацией
    dao_addnode_copys (graf, graf_new, node);
    break;
  case 2: // раздувание-клонирование
    dao_addnode_clone (graf_new, node);
    break;
  default: ;;
  }

  return;
}
/*--------------------------------dao_delnode----------------------------------*/
/*                                                                             */
/*-----------------------------------------------------------------------------*/ 
void
dao_delnode (GRAF *graf, int node)
{

  switch (3) {

  case 1: // простое удаление (вместе со связями)
    GrafDelNode (graf, node);
    break;

  case 2: // перевод стрелочек и простое удаление 
    GrafSubNode (graf, node);
    GrafDelNode (graf, node);
    break;

  case 3: // удаление со стягиванием в этот узел (не много ли удаляется?)
    GrafAllToNode (graf, node);
    break;
  default: ;;
  }

  return;
}
/*--------------------------------dao_what_do----------------------------------*/
/*                                                                             */
/*-----------------------------------------------------------------------------*/ 
int
dao_what_do (GRAF *graf_new, int cur_node)
{

  double do_add, do_not, do_del;
  
  do_add = 50;
  do_del = 40;
  do_not = 100 - (do_add + do_del);
  
  return (Rand123 (do_add, do_not, do_del));

}
/*--------------------------------dao_bestday----------------------------------*/
/*                                                                             */
/*-----------------------------------------------------------------------------*/ 
void
dao_bestday (GRAF *graf)
{
  int node;

  GrafAddNode (graf, &node, YES);
  EDGE (graf, node, node) = YES; //!!!!!!!!!!!!

  return;
}
/*-------------------------------dao_loop1---------------------------------*/
/*                                                                             */
/*-----------------------------------------------------------------------------*/ 
int
dao_loop1 (int argc, char *argv[])
{
  int    cur_node, new_node, u;
  BOOL   ret;
  static GRAF *graf_new=NULL;
  int    what_do;
  int    nn, i, num_doing;
  GRAF  *graf;
  double mutaciq;
  YT_PLOT *plot;

  static ZT_OUT out[MAX_OUT] = {
    {1, "Nodes"    ,  TRUE,  NULL},
    //{2, "All_Edges",  TRUE,  NULL},
    {2, "One_Edges",  TRUE,  NULL},
    {2, "Two_Edges",  TRUE,  NULL},

    //{2, "Sum",    1,  NULL},
    //{1, "Metr",   1,  NULL},

    {0, NULL,0,NULL}
  };
  ZT_OUT *p_out = &out[0];

  //-------------------------
  nn        =10;
  num_doing =200;

  graf = GrafCreate (nn);
  //GrafInit1 (graf, 50/*edge_all*/, 80/*edge_two*/);
  //GrafCheck (graf);
  YRAND_S;

  graf_new = GrafCreate (graf->nn);
  //-------------------------
	
  // пошаговые итерации
  plot = GrafCalcOut (1, NULL, p_out, num_doing);

  for (i=0; i < num_doing; i++) {

    GrafCalcOut (2, graf, p_out, num_doing);		
    /* подготовить новый граф из текущего */
    GrafCopy (graf, graf_new);
		
    // если ничего нет, то нужно зародить
    if (GrafGetNumNodes (graf) == 0) dao_bestday (graf_new);

    /* главный цикл по всем узлам графа */
    for (u = 0; u < graf->nn; u++) {
      if (NODE (graf, u) == NOT) continue;
			
      cur_node = u;
      what_do = dao_what_do (graf_new, cur_node);
			
      if      (what_do == 1) dao_addnode (graf, graf_new, cur_node); 
      else if (what_do == 3) dao_delnode (graf_new, cur_node); 
    }
		
    /* проверка корректности узлов и связей */
    GrafCheck (graf_new);

    /* сделать новый граф текущим */
    graf = graf_new;		
  }
  GrafCalcOut (3, NULL, p_out, num_doing);
	
	
  argc++; argv++;
  return 1;
}
//******************************************************************************
/*-----------------------------------------------------------------------------*/ 
int
main (int argc, char *argv[])
{

  int test_num   = 0;

  get_options (argc, argv, 
             NULL, NULL, 
             /* &interval_ms */ NULL, /* &count_max */ NULL, 

             NULL, NULL, &test_num, NULL);


  YT_PLOT *plot;
  
  switch (test_num) {
    
  case 0:
    dao_loop1 (argc, argv);
    break;


  case 1:
    test_01 ();
    break;

  case 11:
    test_11 ();
    break;

  case 2:
    test_00 (4);
    break;


  case 3:
    dao_loop0 (argc, argv);
    break;

  case 4:
    plot = make_plot_test (100, 0, 2*YPI);
    plot_print (plot, FALSE, TRUE);
    break;

  default:
    break;

  }

  printf ("\n");

  //return 1;
  return (0); // Tcl's exec treats any non-zero exit status as an exceptional 
  // situation. 
}
//------------------------------------------------------------------------------

// cl g~.cl GRAF test_01      
// c_graf -t1

// sl g~.cl GRAF test_11 

// cl g~.cl NETS amat_03 
// sl g~.cl META tao_loop0 500 1  1706 0 
// sl g~.cl META tao_loop1 200 2 3  1706 0


// g~.tl GRAF test_01 
// g~.tl GRAF test_11 
// g~.tl GRAF test_99 
// g~.tl META tao_loop0 5 1    1706 0 
// g~.tl META tao_loop1 3  2 3  1706 0 
// g~.tl META test_00 
// g~.tl META test_05 
// g~.tl NETS amat_03 

//------------------------------------------------------------------------------
