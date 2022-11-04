// -*-  mode: c    ; coding: koi8   -*- ----------------------------------------

//==============================================================================

#define TNUM_MAX 1000
#define FNUM_MAX 10

typedef struct {

  int  xnum; //   
  int  tnum; // размeрность по врeмeни
  int  fnum; // количeство функций

  char    *names[FNUM_MAX];
  double  *t;
  double  *u[FNUM_MAX][TNUM_MAX];

} TADMOR;

void  reader_test (char *main_dir);
void  tadmor_get_arrays (TADMOR *tad, char *main_dir);

YT_PLOT *
  tadmor_make_plot (TADMOR *tad);

//==============================================================================

void *gnu_bigplot_init (void *plot);
void  gnu_bigplot_draw (void *p, void *plot, char *title, int ti);
void  gnu_bigplot_close (void *p);

void
plotbig_print_gtk (YT_PLOT *plot, int X, int Y, int W, int H);


void  plotbig_step_do (T_PLOTSTEP *ps, int ti);
void  plotbig_step_end (T_PLOTSTEP *ps);

T_PLOTSTEP *plotbig_step_beg (YT_PLOT *plot, int X, int Y, int W, int H);

//==============================================================================
