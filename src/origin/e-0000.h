// -*-  mode: c    ; coding: koi8   -*- ----------------------------------------


/*-----------------------------------------------------------------------------*/
/*                                                                             */
/*                             C O M M O N . H                                 */
/*                                                                             */
/*-----------------------------------------------------------------------------*/ 

enum keywords {
	YCONST, YRAND, 
	YDONE
};

#define OUTD(val)  (fprintf(stderr,"out_%d \n",(val)))
#define OUTF(val)  (fprintf(stderr,"out_%f \n",(val)))
#define OUTS(val)  (fprintf(stderr,"out_%s \n",(val)))

#define YMAX(a,b)  (((a) > (b)) ? (a) : (b))
#define YMIN(a,b)  (((a) < (b)) ? (a) : (b))
#define YABS(x)    (((x) < (0)) ? (-x) : (x))

#define YRAND_S  srand((unsigned)time(NULL))
#define YRAND(imin,imax) (imin+rand()%(imax-imin+1))

//#define YRAND(imin,imax) (imin+random()%(imax-imin+1)) 

#define YOVERFLOW(i) ( ((double)(i)) != (i) )
#define CALLOC(p,conv,size) {if (YOVERFLOW(size)) p=NULL; else p=(conv)calloc(1,size);}
#define MALLOC(p,conv,size) {if (YOVERFLOW(size)) p=NULL; else p=(conv)malloc(size);}
#define REALLOC(p_new,p_old,conv,size) \
               {if (YOVERFLOW(size)) p_new=NULL; else p_new=(conv)realloc(p_old,size);}
#define YMALLOC(pp,type,num) {MALLOC((pp),type*,(num)*sizeof(type)); \
               if (!(pp)) Error ("YMALLOC");}
#define YREALLOC(pp_new,pp_old,type,num) {REALLOC((pp_new),(pp_old),type*,(num)*sizeof(type)); \
               if (!(pp_new)) Error ("YREALLOC");}

typedef int BOOL;

#define YERROR(str)  {printf("ERR: %s \n",(str)); getchar(); exit(0);}
#define TRUE  1
#define FALSE 0

#define YPI (3.141592653589)
#define RAD(grad) ((double)(grad)*2.0*(YPI)/360.0)
#define GRAD(rad) ((double)(rad)*360.0/(2.0*YPI) )

#define FOR(i,ii) for ((i)=0; (i) < (ii); (i)++)

#define YPI (3.141592653589)
#define RAD(grad) ((double)(grad)*2.0*(YPI)/360.0)
#define GRAD(rad) ((double)(rad)*360.0/(2.0*YPI) )

#define CHAR int

#define  EPS  0.000001

int    Rand123 (double p1, double p2, double p3);
BOOL   RandYes (double procent);
BOOL   FRavno (double d1, double d2, double eps);
int    YInt (double f);
void   Error (const char *string);
double YRandF (double fmin, double fmax);
BOOL   str_cmp (const char *str1, const char *str2);

//-----------------------------------------------------
// ANSI  color-change escape sequences.
#define ED  printf("\x1b[2J") // стереть экран
#define EL  printf("\x1b[K")  // стереть строку
#define CUP(row,col) printf("\x1b[%d;%dH", row,col) // переместить курсор
#define CUU printf("\x1b[A")  // на одну строку вверх
#define CUD printf("\x1b[B")  // на одну строку вниз
#define CUF printf("\x1b[C")  // на одну строку вправо
#define CUB printf("\x1b[D")  // на одну строку влево
#define SCP printf("\x1b[s")  // считать текущую позицию курсора
#define RCP printf("\x1b[u")  // восстановит позицию курсора

//#define YMAXDOUBLE MAXDOUBLE  //DBL_MAX=1.7976931348623157e+308  values.h->float.h
//#define YMINDOUBLE MINDOUBLE  //DBL_MIN=2.2250738585072014e-308
#define YMAXDOUBLE 1.00e+100
#define YMINDOUBLE 1.00e-100

#define MAXVAL  10000.0
#define MINVAL -10000.0

#define YMAXSPACE 1.00E+30
#define YMINSPACE 1.00E-30

/*-----------------------------------------------------------------------------*/
/*                                                                             */
/*                             P L O T E R . H                                 */
/*                                                                             */
/*-----------------------------------------------------------------------------*/ 
#define MAX_OUT 50
#define MAX_TITLE 1000

typedef struct {
	int      fnum;
	int      xnum, tnum, tnul;
	double   xmin[MAX_OUT], ymin[MAX_OUT], xmax[MAX_OUT], ymax[MAX_OUT];

	double  *x;
	double  *f[MAX_OUT][MAX_OUT];

	char    *title[MAX_TITLE];
	char    *l_name[MAX_OUT][MAX_OUT];
} YT_PLOT;

YT_PLOT* plot_create (int fnum, int xnum, int tnum);
void     plot_print (YT_PLOT *plot, BOOL is_win, BOOL is_gnu);
void     win_sgr (int par);
  
typedef struct {
	int     numw;
	char    *legend; //const char *legend;
	BOOL    val;
	double  *f;
} ZT_OUT;

ZT_OUT *Out (ZT_OUT *p_out, const char *legend);

YT_PLOT*
  make_plot_test (int n, double fi_min, double fi_max);

void
  Do_Open_Close (ZT_OUT *p_out, int mod, int xnum,
                 BOOL is_win, BOOL is_gnu);

/*****************************************************************************/
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

YT_PLOT  *GrafCalcOut (int, GRAF *, ZT_OUT *p_out, int xnum, 
                       BOOL is_win, BOOL is_gnu);
void     GrafCheck (GRAF *graf);

BOOL     GrafSmin (GRAF *, int, int, double *);
BOOL     GrafAllSmin (GRAF *, int, double *);
WORKS   *GrafWorkCreate (GRAF *);
void     GrafWorkPrint (WORKS *);
void     GrafWorkDelete (WORKS *);

void     GrafEdgesFill (GRAF *graf, int u, double edge);
void     GrafMetrica (GRAF *pg, double *rr, double *dd, int *num_rr, int *num_dd);

/*-----------------------------------------------------------------------------*/ 

int dao_loop0 (int is_win, int is_gnu);
int dao_loop1 (int is_win, int is_gnu);

typedef int (*DAO_LOOP) (int, int);

void  test_01 (void);
void  test_11 (void);
void  test_00 (int);

/*-----------------------------------------------------------------------------*/ 
