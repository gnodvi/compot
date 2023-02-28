// -*-  mode: c    ; coding: koi8   -*- ----------------------------------------

/*=================================== svmix3.h ===============================*/


typedef struct {
  double  x;
  double  y;
  double  z;
} vector;

typedef struct {
  short   type;
  int     III, JJJ, KKK;  
  long    NUM;
} REGION_T;

typedef struct {

  vector  r;
  vector  u;
  double  ro;
  double  e;
  double  p;

} M3_POINT;

typedef struct {
  short    i ;    
  short    j ;    
  short    k ;     
  long     params; 
} CELL;

typedef struct {

  REGION_T     def_region;   
  M3_POINT     *m3_points;
  CELL         *cells;
  double       *vals;

} VT_MIX3;

/*========================================================================*/
