/****************************************************************************
 *                                                                          *
 *  egraph.c  --  "Program EvoGraph"                                        *
 *                                                                          *
 *  Copyright (c) 2001,  Gennady M.                                         *
 *                                                                          *
 ****************************************************************************
 */                                                                          
/*----------------------------------------------------------------------------*/
                                                                             
 
#include  <stdio.h>
#include  <stdlib.h>  
#include  <string.h>
#include  <math.h>
#include  <time.h>  
#include  <unistd.h> 
#include  <ctype.h>  
#include  <dirent.h> 
#include  <sys/time.h> 
  
           
#include  "kernel.h" 

int     ZRand123 (float p1, float p2, float p3);
ZT_BOOL ZRandYes (float procent);
int     ZRand123 (float p1, float p2, float p3);
void    ZValueRead (FILE *input, void *pdata,  char *type, char *name/* , char *value_def */);

/*============================= Graf-LIBRARY ============================*/

typedef struct {
  int  nn;
  int *nodes;
  int *edges;
} VT_GRAF; 

int     *GrafEdge (VT_GRAF *, int, int);
#define  EDGE(graf, u, v)  (*( (int*)GrafEdge((graf), (u), (v)) ))
#define  NODE(graf, u)  (*(graf->nodes+u))

VT_GRAF *GrafCreate (int);
void     GrafDestroy (VT_GRAF *graf);
void     GrafPrint (VT_GRAF *);
void     GrafCalcOut (int, VT_GRAF *);

#define V_0   0
#define V_1   1
#define V_NOT V_0

void     GrafCheck (VT_GRAF *graf);
int      GrafGetNum (VT_GRAF *graf);
ZT_BOOL  GrafGetSosed (VT_GRAF *graf, int uzel, int *sosed);
void     GrafCopy (VT_GRAF *graf, VT_GRAF *graf_new);
ZT_BOOL  GrafAddNode (VT_GRAF *graf, int *pu);
ZT_BOOL  GrafDelNode (VT_GRAF *graf, int u);
void     GrafInit (VT_GRAF *graf, float r_edge_all, float r_edge_two);
void     GrafEdgesFill (VT_GRAF *graf, int u);

/*=============================== Agl-LIBRARY ============================*/

extern FILE *LOG;
extern FILE *input;



#ifdef  D_SVISOR  

FILE *LOG;
FILE *input;


/*=============================== Z-LIBRARY ==============================*/
/*                                                                        */
/*                                                                        */
/*                                                                        */
/*-------------------------------ZRand123---------------------------------*/
int
ZRand123 (float p1, float p2, float p3)
{
	int ret, yrand;

	yrand = ZRAND (1,100);

  if      (yrand < p1) return (1);
	else if (yrand > p3) return (3);
	else                 return (2);

}
/*--------------------------------ZRandYes--------------------------------*/
ZT_BOOL
ZRandYes (float procent)
{

	if (ZRand123(procent, 0, 100-procent)==1) 
		return (TRUE);
	else             
		return (FALSE);

}
/*----------------------------------ZWarning------------------------------*/
void
ZWarning (char *string)
{

  fprintf (LOG, "ZWarning: %s \n", string);

}
/*----------------------------------ZError--------------------------------*/
void
ZError (char *string)
{

  fprintf (LOG, "ZError: %s \n", string);
  exit (EXIT_FAILURE);

}
/*-------------------------------ZStrCmp----------------------------------*/ 
ZT_BOOL 
ZStrCmp (char *str1, char *str2) 
{ 
  if (!str1 || !str2) return (FALSE);   

   
  return (!(strcmp(str1, str2))); 
} 
/*-------------------------------ZValueSet--------------------------------*/ 
ZT_BOOL 
ZValueSet (char *type, char *value, void *pdata) 
{ 
 int     decimal; 
 
 if      (ZStrCmp (type,"int"))      *((int*)pdata)      = atoi (value); 
 else if (ZStrCmp (type,"float"))    *((float*)pdata)    = atof (value); 
 else if (ZStrCmp (type,"double"))   *((double*)pdata)   = atof (value); 
 else if (ZStrCmp (type,"bool")) { 
   if      (ZStrCmp (value, "true"))   decimal = 1; 
   else if (ZStrCmp (value, "false"))  decimal = 0; 
   else    { 
     ZWarning ("bool"); 
     return (FALSE); 
   } 
   *((int *) pdata) = decimal; 
 } 
 else if (ZStrCmp(type,"string"))   strcpy ((char*)pdata,value); 
  
 return (TRUE); 
} 
/*-----------------------------ZValueRead---------------------------------*/
void
ZValueRead (FILE *input, void *pdata,  char *type, char *name/* , char *value_def */)
{
/* 	char *value; */
#define SIZE_STR 100 
  char  str_rab[SIZE_STR], *str; 
	char stype[80], sname[80], svalue[80];
	ZT_BOOL is_find_value;

  fseek (input, 0, SEEK_SET);
	/* value = value_def; */
	is_find_value = FALSE;

  while (1) { 
    if (!fgets (str_rab, SIZE_STR-1, input))  
      break; 
    if (str_rab[0] == '#') continue; 
		if (str_rab[0] == ';') {
			str = strchr(str_rab+1,';')+1;
		} else {
			str = str_rab;
		}

		/* printf ("str = %s \n", str); */
    sscanf (str, "%s %s %s", stype, sname, svalue); 
    sscanf (str, "%s %s", sname, svalue); 
		if (ZStrCmp(sname, name)) {
			/* value = svalue; */
			is_find_value = TRUE;
			break;
		}
  } 

	if (!is_find_value) {
		fprintf (LOG, "Don't find value: %s \n\n", name);
		exit (1);
	}

	ZValueSet (type, svalue, pdata); 

	return;
}
/*-------------------------------ZPause------------------------------------*/
void
ZPause (char *message)
{

	printf ("%s \n", message);
	getchar ();

	return;
}
/*************************************************************************/
/*============================= Graf-LIBRARY ============================*/
/*                                                                       */
/*                                                                       */
/*                                                                       */
/*--------------------------------GrafCreate-----------------------------*/
VT_GRAF *
GrafCreate (int nn)
{
  VT_GRAF *graf;
  int v, u;

  graf = (VT_GRAF*) malloc (sizeof(VT_GRAF));
  graf->nn = nn;

  graf->edges = (int*) malloc (sizeof(int) * nn*nn); 
  graf->nodes = (int*) malloc (sizeof(int) * nn   ); 

  for (u = 0; u < graf->nn; u++) 
    NODE (graf, u) = V_NOT; 

  for (u = 0; u < graf->nn; u++) 
	for (v = 0; v < graf->nn; v++) 
		EDGE (graf, u, v) = V_NOT; 

  return (graf);
}
/*-------------------------------GrafDestroy-----------------------------*/
void
GrafDestroy (VT_GRAF *graf)
{

  free (graf->nodes);
  free (graf->edges);

  free (graf);

  return;
}
/*------------------------------GrafInit---------------------------------*/
void
  GrafInit (VT_GRAF *graf, float r_edge_all, float r_edge_two)
{
  int v, u, val;

  ZRAND_S;

  for (u = 0; u < graf->nn; u++) {
    NODE (graf, u) = V_1;
    EDGE (graf, u, u) = V_1; 
  }

  for (u = 0; u < graf->nn; u++) 
    for (v=u+1; v < graf->nn; v++) {

      if ((NODE(graf, u)==V_NOT) || (NODE(graf, u)==V_NOT)) 
        continue;
      if (!(ZRandYes(r_edge_all))) {
        EDGE (graf, u, v) = EDGE (graf, v, u) = V_0; 
        continue;
      }

      if (ZRandYes(r_edge_two)) 
        EDGE (graf, u, v) = EDGE (graf, v, u) = V_1;
      else {
        if (ZRandYes(50)) {
          EDGE (graf, u, v) = V_0;
          EDGE (graf, v, u) = V_1;
        } else {
          EDGE (graf, u, v) = V_1;
          EDGE (graf, v, u) = V_0;
        }
      }
    }

  return;
}
/*----------------------------GrafGetSosed-------------------------------*/
ZT_BOOL
GrafGetSosed (VT_GRAF *graf, int uzel, int *sosed)
{
  static VT_GRAF *g;
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
    if (EDGE (g, uz, i) == (int)V_NOT)
      continue;
    *sosed = i;
    return (TRUE);
  }

}
/*-----------------------------GrafEdge----------------------------------*/
int *
GrafEdge (VT_GRAF *graf, int u, int v)
{
  int rab;

  if ((u<0) || (u>= graf->nn)) ZError ("GrafEdge");
  if ((v<0) || (v>= graf->nn)) ZError ("GrafEdge");

/*   if (u > v) { */
/*     rab = v; */
/*     v = u; */
/*     u = rab; */
/*   } */
  return ((graf->edges) + u*(graf->nn) + v);
}
/*--------------------------------GrafPrint------------------------------*/
void
  GrafPrint (VT_GRAF *graf)
{
  int v, u, val;

  printf ("\n");

  for (u = 0; u < graf->nn; u++) {
    for (v = 0; v < graf->nn; v++) {
      if  (u != v) printf ("%d ",  EDGE (graf, u, v));
      else {
        val = NODE (graf, u);
        if (val == V_0) printf ("0 ");
        else            printf ("1 ");
      }
    }
    printf ("\n");
  }
  
  printf ("\n");

  return;
}
/*-----------------------------GrafGetNum--------------------------------*/
int
GrafGetNum (VT_GRAF *graf)
{
  int num_nodes, u;

  num_nodes=0;
  for (u = 0; u < graf->nn; u++) {
    if (NODE (graf, u) == V_1)
      num_nodes++;
  }

  return (num_nodes);
}
/*-------------------------------GrafCheck-------------------------------*/
void
GrafCheck (VT_GRAF *graf)
{
  int  sum;
  int  edge, u, v, node_u, node_v;
  ZT_BOOL exist_edges;

  for (u = 0; u < graf->nn; u++) 
	for (v = 0; v < graf->nn; v++) {
		if (EDGE (graf, u, v) == V_0)
			continue;
    node_u = NODE (graf, u);
    node_v = NODE (graf, v);
    if ((node_u == V_NOT) || (node_v == V_NOT))
      EDGE (graf, u, v) = V_NOT;
	}


  for (u = 0; u < graf->nn; u++) {
    if (NODE (graf, u) == V_NOT) continue; 
    exist_edges = FALSE;
    for (v = 0; v < graf->nn; v++) 
      if (EDGE (graf, u, v) == V_1) exist_edges = TRUE; 
    if (!exist_edges) NODE (graf, u) = V_NOT;
  }

  return;
}
/*-----------------------------GrafEdgesFill----------------------------*/
void
GrafEdgesFill (VT_GRAF *graf, int u)
{
  int v;

  for (v = 0; v < graf->nn; v++) 
    EDGE (graf, u, v) = V_1; 

  return;
}
/*-----------------------------GrafNewNode------------------------------*/
ZT_BOOL
GrafNewNode (VT_GRAF *graf, int *pu)
{
  int u;

  for (u = 0; u < graf->nn; u++) {
    if (NODE (graf, u) == V_NOT) break; 
  }
  if (u == graf->nn) {
    return (FALSE);
  }

  /* NODE (graf, u) = V_1; */
  if (pu) *pu = u;

  return (TRUE);
} 
/*-----------------------------GrafReMax---------------------------------*/
void 
GrafReMax (VT_GRAF *old)
{
  int u, v, new_nn;
	VT_GRAF *new_graf;

	new_nn = old->nn * 1.25;
	new_graf = GrafCreate (new_nn);
	fprintf (LOG, "GrafReMax: new_nn=%d \n", new_nn);

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
/*-----------------------------GrafAddNode--------------------------------*/
ZT_BOOL
GrafAddNode (VT_GRAF *graf, int *pu)
{
  int u, v;

  if (!GrafNewNode (graf, &u)) {
		u = graf->nn;
		GrafReMax (graf);
	}
 
  NODE (graf, u) = V_1;

  if (pu) *pu = u;

  return (TRUE);
}
/*-----------------------------GrafDelNode--------------------------------*/
ZT_BOOL
GrafDelNode (VT_GRAF *graf, int u)
{
  int v;

  if (u < 0 || u >= graf->nn)  return (FALSE);
  if (NODE (graf, u) == V_NOT) return (FALSE); 

  NODE (graf, u) = V_0;
  for (v = 0; v < graf->nn; v++) 
    EDGE (graf, u, v) = V_0; 

  return (TRUE);
}
/*-------------------------------GrafCopy---------------------------------*/
void
GrafCopy (VT_GRAF *graf, VT_GRAF *graf_new)
{
  int u, v;

  for (u = 0; u < graf->nn; u++) {
    NODE (graf_new, u) = NODE (graf, u);
   
    for (v = 0; v < graf->nn; v++) 
      EDGE (graf, u, v) = EDGE (graf, u, v);
  }

  return;
}
/*-------------------------------One_Plot---------------------------------*/
void
One_Plot (FILE *fdem, ZT_OUT *p_out, int num_plot)
{
  int count;

  fprintf (fdem, "plot ");

  for (count=0; p_out->numw!=0; p_out++) {
    /* *(p_out->ptr) = p_out->val; */
    if (!(p_out->val)) continue;
    if (p_out->numw != num_plot) continue;

    if (count != 0)  fprintf (fdem, ", ");                                           
    fprintf (fdem, "'%s' title '%s' with lines", p_out->fname, 
             p_out->legend);
    count++;
  }
                                                                           
  fprintf (fdem, "\n"); 
  return;
}
/*---------------------------------Out------------------------------------*/
ZT_OUT *
Out (ZT_OUT *p_out, char *legend)
{
  ZT_OUT *p;

  for (p=p_out; p->numw!=0; p++) {

    if (strcmp(legend, p->legend)==0) {
      return (p);
    }
  }

  ZError ("Out");
  return (NULL);
}
/*--------------------------------Do_Out----------------------------------*/
void
Do_Out (ZT_OUT *p_out, int mod)
{
  char bufname[200];


  for ( ; p_out->numw != 0; p_out++) {
    if (!(p_out->val)) continue;

    if (mod == 1) {
      strcpy (bufname, "etc/");
      /* p_out->fout = fopen (p_out->fname, "w"); */
      p_out->fout = fopen (strcat(bufname,p_out->fname), "w");
      if (p_out->fout == NULL) ZError ("Do_Out");
    } else {
      if (fclose (p_out->fout) != 0)
        ZError ("fclose");
    }

  }

  return;
}
/*-------------------------------Get_N_Plot-------------------------------*/
int
Get_N_Plot (ZT_OUT *p_out)
{
  int n_plot;

  n_plot = 0;

  for ( ; p_out->numw != 0; p_out++) {
    if (!(p_out->val)) continue;

    if (p_out->numw > n_plot)
      n_plot = p_out->numw;	
  }

  return (n_plot);
}
/*--------------------------------DemOut----------------------------------*/
void
DemOut (ZT_OUT *p_out)
{
  int    i, n_plot;
  float  h_plot;
  FILE  *fdem;
  int pause = 600; /* pause secunds */

  n_plot = Get_N_Plot (p_out);
  h_plot = 1.0 / n_plot;

  fdem  = fopen ("etc/plot.dem", "w");

  fprintf (fdem, "set multiplot \n");                          
  for (i = 1; i <= n_plot; i++) {
    fprintf (fdem, "\n"); 
    fprintf (fdem, "set size 1.0,%.2f \n", h_plot);                       
    fprintf (fdem, "set origin 0.0,%.2f \n", (n_plot-i)*h_plot);                 
    One_Plot (fdem, p_out, i);
  }
  fprintf (fdem, "\n"); 
  fprintf (fdem, "set nomultiplot \n\n");                                            
  /* fprintf (fdem, "pause -1 'Hit return to continue' \n"); */                         
  /* fprintf (fdem, "pause %d \n", pause);   */                       
  fclose  (fdem);

  return;
}
/*------------------------------GrafCalcOut-------------------------------*/
void
GrafCalcOut (int mod, VT_GRAF *graf)
/* расчет и вывод на каждом шаге различных характеристик графа */
{
  int edge, u, v, i, n_plot;
	float h_plot;
  static int step;
  static FILE *fdem, *fout1, *fout2, *fout3;

  int num_nodes, num_one_edges, num_two_edges, num_sum_edges;
  int num_plot, count;

  static ZT_OUT out[MAX_OUT] = {
    {1, "Nodes",     "out1.txt",  TRUE}, 
    {2, "One_Edges", "out2.txt",  TRUE}, 
    {2, "Two_Edges", "out3.txt",  FALSE}, 
    {2, "Edges",     "out4.txt",  TRUE}, 
    {0, NULL, NULL} 
  };

  ZT_OUT *p_out = &out[0];

  ZT_OUT *out1, *out2, *out3, *out4, *pout;
	
  if (mod == 1) {
    /* подготовка к выводу */
    /* fprintf (LOG, "\n -------------------------- \n");   */
    step = 0;
    Do_Out (p_out, mod);
    return;
  }

  if (mod == 3) {
    /* завершение вывода */
    Do_Out (p_out, mod);
    DemOut (p_out);
    return;
  }

  fprintf (LOG, "%d  ", step);  
  step++;

  /*----------- количесиво узлов в графе -----------*/
  pout = Out(p_out, "Nodes");
  if (pout->val) {
    num_nodes = GrafGetNum (graf);

    fprintf (pout->fout, "%d  \n", num_nodes);    
    fprintf (LOG, "%d  ", num_nodes); 
  }


  /*----------- количесиво ребер в графе -----------*/
  out1 = Out(p_out, "One_Edges");
  out2 = Out(p_out, "Two_Edges");
  out3 = Out(p_out, "Edges");
  if (out1->val || out2->val || out3->val) {

    num_one_edges=0;
    num_two_edges=0;
    for (u = 0; u < graf->nn; u++) 
      for (v=u+1; v < graf->nn; v++) {
        if ((EDGE(graf, u, v)==V_0) && (EDGE(graf, v, u)==V_0))
          continue;
        if ((EDGE(graf, u, v)==V_1) && (EDGE(graf, v, u)==V_1))
          num_two_edges++;
        else 
          num_one_edges++;
      }
    num_sum_edges = num_one_edges + num_two_edges;

    if (out1->val) {
      fprintf (out1->fout, "%d  \n", num_one_edges); 
      fprintf (LOG, "%d  ", num_one_edges);
    }
    if (out2->val) {
      fprintf (out2->fout, "%d  \n", num_two_edges); 
      fprintf (LOG, "%d  ", num_two_edges);
    }
    if (out3->val) {
      fprintf (out3->fout, "%d  \n", num_sum_edges); 
      fprintf (LOG, "%d  ", num_sum_edges);
    }
  }


  fprintf (LOG, "\n");  

  return;
}
//*************************************************************************

#endif
#ifdef  D_NEW  

/*************************************************************************
 *                                                                       *
 *                                                                       *
 *************************************************************************
 */ 
 
Fl_Window *window;
/* int is_Plot = 0; */
char dir_root[100];

Fl_Gnuplot *gp;
Fl_Box *box_gnu;  

/*================================Agl-LIBRARY=============================*/
/*                                                                        */
/*                                                                        */
/*--------------------------------AglRandV--------------------------------*/
int
AglRandV (float procent)
{
  int ret; 

  if (ZRandYes(procent)) ret = V_1;
  else                 ret = V_0;

  return (ret);
}
/*------------------------------AglRandNode-------------------------------*/
ZT_BOOL
AglRandNode (VT_GRAF *graf, int *pu)
{
  int u, num;

  num = GrafGetNum (graf);
  if (num == 0) return (FALSE);

  while (1) {
    u = ZRAND (0, graf->nn-1);
    if (NODE (graf, u) != V_NOT) break; 
  }

  *pu = u;
  return (TRUE);
}
/*-----------------------------AglReverse---------------------------------*/
int
AglReverse (int edge)
{

  if (edge == V_0) return (V_1);
  else             return (V_0);

}
/*----------------------------AglGetSum----------------------------------*/
int
AglGetSum (VT_GRAF *graf, int u)
{
  int  sum;
  int  sosed, num_sosed;

  sum = num_sosed = 0;
  GrafGetSosed (graf, u, &sosed);
  while (GrafGetSosed (NULL, 0, &sosed)) {
    sum += (EDGE(graf, u, sosed) * NODE(graf, sosed));
    num_sosed++;
  }
  sum = sum/num_sosed;

  return (sum);
}
/*---------------------------AglEdgesCopy--------------------------------*/
void
AglEdgesCopy (VT_GRAF *graf_from, int u_from, VT_GRAF *graf_to, int u_to, float mutaciq)
{
  int v, edge;

  for (v = 0; v < graf_from->nn; v++) {
    edge = EDGE (graf_from, u_from, v); 
    if (ZRandYes(mutaciq) && edge==V_1)
      edge = V_0;
    EDGE (graf_to, u_to, v) = edge; 
  }

  return;
}
/*------------------------------AglDoMagic-------------------------------*/
VT_GRAF *
AglDoMagic (VT_GRAF *graf, ZT_BOOL flag_parall, float do_add, float do_del, 
				 float old_to_new, float new_to_old,
				 float mutaciq)
{
  int cur_node, new_node, u;
  ZT_BOOL ret;
  static VT_GRAF *graf_new=NULL;
  float do_not;
  int   what_do;

  ret = FALSE;

  if (flag_parall) {
    /* только для первого параллельного шага*/
    if (graf_new == NULL) 
      graf_new = GrafCreate (graf->nn);

    /* подготовить новый граф из текущего */
    GrafCopy (graf, graf_new);

  } else {
    /* последовательные действия на одном графе */
    graf_new = graf;
  }

  /* некоторые предварительные действия */
  do_not = 100 - (do_add + do_del);
  if (do_not < 0) ZError ("do_not < 0");


  /* главный цикл по узлам графа */
  for (u = 0; u < graf->nn; u++) {
    if (NODE (graf, u) == V_NOT) continue; 

    cur_node = u;
    what_do = ZRand123 (do_add, do_not, do_del);

    if (what_do == 1) {
      ret = GrafAddNode (graf_new, &new_node);
      AglEdgesCopy (graf, cur_node,  graf_new, new_node, mutaciq);
      if (old_to_new)  EDGE (graf_new, cur_node, new_node) = V_1; 
      if (new_to_old)  EDGE (graf_new, new_node, cur_node) = V_1; 
    } else 
      if (what_do == 3) {
        ret = GrafDelNode (graf_new, cur_node);
      }
  }

  /* проверка корректности узлов и связей */
  GrafCheck (graf_new);

  /* сделать новый граф текущим */
  graf = graf_new;

  if (!ret) return (NULL);
  else      return (graf_new);
}
/****************************************************************************/
/****************************************************************************/
/*                                                                          */
/*------------------------------graf_test-----------------------------------*/
void
graf_test (int nn)
{
  VT_GRAF *graf;
  int u;
  
  graf = GrafCreate (nn);
  GrafInit (graf, 50, 50);
  
  GrafCheck (graf);
  GrafPrint (graf);

  GrafAddNode (graf, &u);
  GrafEdgesFill (graf, u);
  GrafPrint (graf);

  GrafCheck (graf);
  GrafPrint (graf);

  GrafDelNode (graf, u);
  GrafPrint (graf);

  return;
}
/* #endif */
/* #ifdef  D_LIBRARY   */
/*--------------------------doPuts---------------------------------------*/
void doPuts ()
{
  FILE *out;

  char *flag_parall = "true";
  int nn = 101;          
  int num_doing = 251;   
  int edge_all = 50;    
  int edge_two = 80;    
  int do_add = 50;      
  int do_del = 40;      
  int old_to_new = 30; 
  int new_to_old = 30;  
  int mutaciq = 10;     

  out = fopen ("calc.def", "w");

  fprintf (out, "#-------------------------------------------------\n");
  fprintf (out, "#                                                 \n");
  fprintf (out, "#        Defined params for AGL                   \n");
  fprintf (out, "#                                                 \n");
  fprintf (out, "#-------------------------------------------------\n");
  fprintf (out, ";                         ; FLAG_PARALL %s \n", flag_parall);
  fprintf (out, ";                         ; \n");
  fprintf (out, "; number of nodes         ; NN          %d \n", nn);
  fprintf (out, "; number of steps         ; NUM_DOING   %d \n", num_doing);
  fprintf (out, ";                         ; \n");
  fprintf (out, ";                         ; EDGE_ALL    %d \n", edge_all);
  fprintf (out, ";                         ; EDGE_TWO    %d \n", edge_two);
  fprintf (out, ";                         ; \n");
  fprintf (out, ";                         ; DO_ADD      %d \n", do_add);
  fprintf (out, ";                         ; DO_DEL      %d \n", do_del);
  fprintf (out, ";                         ; \n");
  fprintf (out, ";                         ; OLD_TO_NEW  %d \n", old_to_new);
  fprintf (out, ";                         ; NEW_TO_OLD  %d \n", new_to_old);
  fprintf (out, ";                         ; \n");
  fprintf (out, ";                         ; MUTACIQ     %d \n", mutaciq);
  fprintf (out, "#-------------------------------------------------");

  fclose (out);

  return;
}
/*--------------------------doCalc---------------------------------------*/
void doCalc ()
{

  chdir (dir_root);
  /* system ("egraph calc.def"); */
  system ("d_new -calc");

  return;
}
/*--------------------------doPlot_old---------------------------------------*/
void doPlot_old ()
{

  /* chdir (strcat(dir_root,"/etc")); */
  /* system ("plot gnu . &"); */
  /* system ("s_plot &"); */
  /* chdir (dir_root); */
  /* is_Plot = 1; */

  return;
}
/*--------------------------doPlot---------------------------------------*/
void doPlot ()
{
  static char dir_plot[100];

  /* 	dir_root = getcwd (dir_root, NULL); */
  getcwd (dir_plot, 100);
  /* strcat(dir_plot,"/etc"); */

  /* 	strcpy (dir_plot, ""); */
  /* 	strcpy (dir_plot, dir_root); */
  /* 	strcat(dir_plot,"/etc"); */

  /* 	printf("%s \n", dir_plot); */

  /* 	chdir (dir_plot); */

  /* 	printf("%s \n", dir_root); */
  /* 	printf("%s \n", dir_plot); */
  /* 	if (strcmp(dir_root, dir_plot) != 0) */
  /* 		printf("ERROR!! \n"); */

  /* chdir (strcat(dir_root,"/etc")); */
  chdir (strcat(dir_plot,"/etc"));

  /* 	printf("%s \n", dir_root); */
  /* 	printf("%s \n", dir_plot); */
  /* chdir (dir_plot); */
  /* chdir ("./etc"); */

  gp->set_filename("plot.dem");
  /* gp->set_filename("test.gp"); */

  box_gnu->redraw();
  gp->redraw();

  /* chdir (dir_root); */

  return;
}
/*--------------------------doKill---------------------------------------*/
void doKill ()
{

  box_gnu->redraw();

  /* 	if (is_Plot) { */
  /*     system ("killall -9 gnuplot_x11 gnuplot s_plot"); */
  /*   } */
  /*   is_Plot = 0; */

  return;
}
/*--------------------------exit_proc------------------------------------*/
void 
exit_proc (Fl_Widget *wid, void *ptr) 
{  

  doKill (); 
  exit (1);

}  
/*--------------------------plot_proc------------------------------------*/
void 
plot_proc (Fl_Widget *wid, void *ptr) 
{  

  doPlot ();
	
}  
/*--------------------------kill_proc------------------------------------*/
void 
kill_proc (Fl_Widget *wid, void *ptr) 
{  

  doKill ();
 
}  
/*--------------------------doTest------------------------------------*/
void 
doTest () 
{  
  int i;
  double x[256], y[256];
  static int numer = 1;

  switch (numer) {
  case 1:
    for(i=0; i<256 ; i++) {
      x[i] = i/256.0;
      y[i] = x[i]*x[i] - x[i] + 0.5;
    }
    gp->set_2d_data(x, y, 256, "A nice curve");
    numer = 2;
    break;
  case 2:
    for(i=0; i<256 ; i++) {
      x[i] = i/16.0;
      y[i] = x[i]*sin(x[i]);
    }
    gp->set_2d_polar_data(x, y, 256, "A nicer curve");
    numer = 3;
    break;
  case 3:
    gp->set_filename("etc/test.gp");
    numer = 1;
    break;
  default: ;;
  }

  /* gp->draw(); */
  box_gnu->redraw();
  gp->redraw();

  // OUTD(11);
  return;
}  
/*--------------------------opts_proc------------------------------------*/
void 
opts_proc (Fl_Widget *wid, void *ptr) 
{  

  doTest ();
  return;
}  
/*--------------------------help_proc------------------------------------*/
void 
help_proc (Fl_Widget *wid, void *ptr) 
{  

  YMessageBox ("Sorry, it's under construction!!");
 
  return;
}  
/*--------------------------calc_proc------------------------------------*/
void 
calc_proc (Fl_Widget *wid, void *ptr) 
{  
  doPuts (); 
  doKill ();
  doCalc ();  
  doPlot ();
 
  return;
}  
/*--------------------------save_proc------------------------------------*/
void 
save_proc (Fl_Widget *wid, void *ptr) 
{  

  YMessageBox ("Sorry, it's under construction!!");
 
  return;
}  
/*--------------------------open_proc------------------------------------*/
void 
open_proc (Fl_Widget *wid, void *ptr) 
{  

  YMessageBox ("Sorry, it's under construction!!");
 
  return;
}  
/*---------------------------------mInit------------------------------------*/
VT_GRAF * 
mInit (int mode)
{
  static int  nn;
  static float edge_all, edge_two;

  switch (mode) {
  case YINIT:
    ZValueRead (input, &nn,         "int",   "NN"/* ,         "100" */);
    ZValueRead (input, &edge_all,   "float", "EDGE_ALL"/* ,   "50" */);
    ZValueRead (input, &edge_two,   "float", "EDGE_TWO"/* ,   "80" */);
    return (NULL);
  case YCALC:
    VT_GRAF *graf = GrafCreate (nn);
    GrafInit (graf, edge_all, edge_two);
    GrafCheck (graf);
    return (graf);
  }

}
/*---------------------------------mWork------------------------------------*/
void 
mWork (int mode, VT_GRAF *graf)
{
  static int   num_doing;
  static float do_add, do_del, old_to_new, new_to_old;
  static float mutaciq;
  static ZT_BOOL flag_parall;

  switch (mode) {
  case YINIT:
    ZValueRead (input, &flag_parall,"bool", "FLAG_PARALL"/* , "true" */);
    ZValueRead (input, &num_doing,  "int",   "NUM_DOING"/* ,  "250" */);
    ZValueRead (input, &do_add,     "float", "DO_ADD"/* ,     "40" */);
    ZValueRead (input, &do_del,     "float", "DO_DEL"/* ,     "40" */);
    ZValueRead (input, &old_to_new, "float", "OLD_TO_NEW"/* , "90" */);
    ZValueRead (input, &new_to_old, "float", "NEW_TO_OLD"/* , "90" */);
    ZValueRead (input, &mutaciq,    "float", "MUTACIQ"/* ,    "10" */);
    break;
  case YCALC:
    GrafCalcOut (1, NULL);
    ZRAND_S;

    for (int i=0; i<num_doing; i++) {
      Fl::check();
      GrafCalcOut (2, graf);
      graf = AglDoMagic (graf, flag_parall, do_add, do_del, new_to_old, old_to_new, mutaciq);
      if (!graf) {
        GrafCalcOut (3, NULL);
        break;
      }
      /* GrafPrint (graf); */
      /* ZPause ("Hit return to continue"); */
    }
    break;
  }

  return;
}
/*---------------------------------mAlgorifm------------------------------------*/
int 
mAlgorifm (int mode)
{
  /*   int  nn, i, num_doing; */
  static VT_GRAF *graf;
  /* 	float edge_all, edge_two, do_add, do_del, old_to_new, new_to_old; */
  /*   float mutaciq; */
  /* 	ZT_BOOL flag_parall; */

  /* 	char *dname_i = "./"; */
  char *fname_i = "./calc.def";
  /* 	char *dname_o = "etc/"; */
  char *fname_o = "etc/calc.log";

  /* LOG = stderr; */
  LOG = fopen (fname_o, "w");
  /* input = fopen (strcat(dname_i,fname_i), "r"); */
  input = fopen (fname_i, "r");

  switch (mode) {
  case YINIT:
  case YCALC:
    graf = mInit (mode);
    mWork (mode, graf);
    break;
  case YOPEN:
    break;
  }

  fclose (input);
  fclose (LOG);
  return(0);
}
/****************************************************************************/
/*-------------------------------------main------------------------------*/
int 
main (int argc, char **argv) 
{


  int h_menu;
  int x, y, w, h;
  int width  = 530;
  int height = 500;
  int x_push, y_push, w_push, h_push;


  for (int i=1; i< argc; i++) {
    if (strcmp(argv[i],"-calc")==0) {
      mAlgorifm (YINIT);
      mAlgorifm (YCALC);
      return (1);
    }
  }
  
  getcwd (dir_root, 100);

  Fl_Window *win;                                                               
  {                                                                             
    window = new Fl_Window (width, height);
    win = window;                                                                 
    window->color(FL_GREEN);

    box_gnu = new Fl_Box (FL_BORDER_BOX, 10, 10, width-20, 230, "");  
    box_gnu->color(FL_WHITE);
    gp = new Fl_Gnuplot(10, 10, width-20, 230);
    gp->color(FL_RED);


    YBeginGroup ("Group", 10,250, 150,240, FL_BLUE); 
    x_push = 10;
    y_push = 10;
    w_push = 55;
    h_push = 25;
    YPush ("Plot",  x_push,            y_push, w_push, h_push, plot_proc);
    YPush ("Kill",  x_push+=w_push+10, y_push, w_push, h_push, kill_proc);
    x_push = 10;
    y_push+= h_push+20;
    YPush ("About", x_push,            y_push, w_push, h_push, about_proc);
    YPush ("Test",  x_push+=w_push+10, y_push, w_push, h_push, opts_proc);
    x_push = 10;
    y_push+= h_push+20;
    YPush ("Help",  x_push           , y_push, w_push, h_push, help_proc);
    YPush ("Calc",  x_push+=w_push+10, y_push, w_push, h_push, calc_proc);
    x_push = 10;
    y_push+= h_push+20;
    YPush ("Save",  x_push,            y_push, w_push, h_push, save_proc);
    YPush ("Open",  x_push+=w_push+10, y_push, w_push, h_push, open_proc);
    x_push = 10;
    y_push+= h_push+20;
    YPush ("Exit",  x_push,            y_push, w_push, h_push, exit_proc);
    YEndGroup ();
 

    Fl_Box *box = new Fl_Box (FL_BORDER_BOX, 170,250, 350,240, "");  
    box->color(FL_YELLOW);


    window->end();                                                               
  }                                                                       
                                                                                
  win->show(argc, argv);                                                        
  return Fl::run();                                                             

  /*   window->end(); */
  /*   window->show(argc, argv); */
  /*   window->make_current(); */

  /*   return Fl::run(); */
}
/*******************************************************************************/

#endif
/*******************************************************************************/
