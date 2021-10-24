// -*-  mode: c    ; coding: koi8   -*- ----------------------------------------

/*******************************************************************************/
/*-----------------------------------------------------------------------------*/
/*                                                                             */
/*                             G R A F E R . H                                 */
/*                                                                             */
/*-----------------------------------------------------------------------------*/ 

typedef struct {
  BOOL    fix;
  double  l;
  int     prev;
} METKA;

typedef struct {
  int     s, t;
  METKA  *met;
  int    *puti;
  double  smin;
} WORKS;

typedef struct {
  int     nn;
  double *nodes;
  double *edges;

  WORKS  *wk;
} GRAF;

void     GrafInit (GRAF *, int, double,  double, int, double,  double);
GRAF    *GrafCreate (int);
void     GrafDestroy (GRAF *graf);
void     GrafReMax (GRAF *old);

double  *GrafEdge (GRAF *, int, int);
#define  EDGE(graf, u, v)  (*( (double*)GrafEdge((graf), (u), (v)) ))
#define  NODE(graf, u)  (*(graf->nodes+u))
#define  YES (-1001.0)
#define  NOT (-1000.0)

void     GrafPrint (GRAF *);
BOOL     GrafGetSosed (GRAF *, int, int *);
double   GrafGetSum (GRAF *graf, int u);
BOOL     GrafGetEdges (GRAF *graf, double *edge, int *, int *);
BOOL     GrafNewNode (GRAF *graf, int *pu);
BOOL     GrafDelNode (GRAF *graf, int u);
void     GrafCopy (GRAF *graf, GRAF *graf_new);
int      GrafGetNum (GRAF *graf, double);
int      GrafGetNumNodes (GRAF *graf);
void     GrafAddNode (GRAF *graf, int *pu, double node);
void     GetNumEdges (GRAF *graf, int *one_edges, int *two_edges, int *all_edges);
YT_PLOT  *GrafCalcOut (int, GRAF *, ZT_OUT *p_out, int xnum);
void     GrafCheck (GRAF *graf);

BOOL     GrafSmin (GRAF *, int, int, double *);
BOOL     GrafAllSmin (GRAF *, int, double *);
WORKS   *GrafWorkCreate (GRAF *);
void     GrafWorkPrint (WORKS *);
void     GrafWorkDelete (WORKS *);

void     GrafEdgesFill (GRAF *graf, int u, double edge);
void     GrafMetrica (GRAF *pg, double *rr, double *dd, int *num_rr, int *num_dd);

/*-----------------------------------------------------------------------------*/ 
