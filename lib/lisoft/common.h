// -*-  mode: c    ; coding: koi8   -*- ----------------------------------------

/****************************************************************************/                    
#ifdef __cplusplus                                                               
extern "C" {                                                                     
#endif                                                                                       
/****************************************************************************/   
#define  YERROR(str)  {fprintf (stderr, "ERROR: %s \n", (str)); exit(0);}

#define  TRUE  1
#define  FALSE 0

typedef  int  ZT_BOOL;                                                          

#define  OUTD(val)  (fprintf (stderr, "out_%d \n",(val)))                       
#define  OUTF(val)  (fprintf (stderr, "out_%f \n",(val)))                       
#define  OUTS(val)  (fprintf (stderr, "out_%s \n",(val))) 

#define is_pri TRUE
#define STDERR stderr

#define  YMAX(a,b)  (((a) > (b)) ? (a) : (b)) 
#define  YMIN(a,b)  (((a) < (b)) ? (a) : (b))   
#define  YRAND_S  srand((unsigned)time(NULL)) 
#define  YRAND(imin,imax) (imin+rand()%(imax-imin+1)) 

int   YInt (float f); 
void  Error (const char *msg);      
void  MyError (const char *msg);      

/****************************************************************************/   
#ifdef __cplusplus                                                               
}                                                                                
#endif                                                                           
/****************************************************************************/   
