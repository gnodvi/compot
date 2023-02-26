// -*-  mode: c    ; coding: koi8   -*- -----------------------------------------

// ******************************************************************************                    
#ifdef __cplusplus                                                               
extern "C" {                                                                     
#endif                                                                                       
//-------------------------------------------------------------------------------


extern FILE *LOG;
extern FILE *input;


/*================================== Z-LIBRARY ===============================*/

enum keys_Z {
  ZCONST, ZRAND 
};

typedef  int  ZT_BOOL;                                                          

#define  FALSE  0                                                              
#define  TRUE   1  
                                                           
#define  ZRAND_S    srand((unsigned)time(NULL))
#define  ZRAND(imin,imax) (imin+rand()%(imax-imin+1))

#define  ZMAX(a,b)  (((a) > (b)) ? (a) : (b))
#define  ZMIN(a,b)  (((a) < (b)) ? (a) : (b))
#define  ZABS(x)    (((x) < (0)) ? (-x) : (x))

#define  AA(ii,i,j) (((j)-1)*(ii) + ((i)-1))
#define  AAA(ii,jj,i,j,k) ((ii)*(jj)*((k)-1) + (ii)*((j)-1) + ((i)-1))
#define  AAAA(ii,jj,kk,i,j,k,l) ((ii)*(jj)*(kk)*((l)-1)+(ii)*(jj)*((k)-1)+(ii)*((j)-1)+((i)-1))
#define  BB(ii,jj,i,j)       ((jj)*(i) + (j)) 
#define  BBB(ii,jj,kk,i,j,k) ((jj)*(kk)*(i) + (kk)*(j) + (k))
#define  BBBB(ii,jj,kk,ll,i,j,k,l) ((jj)*(kk)*(ll)*(i)+(kk)*(ll)*(j)+(ll)*(k)+(l))
#define  PARR2(p,ii,jj,i,j)  (p+BB(ii,jj,i,j))
#define  ARR2(p,ii,jj,i,j)   (*(PARR2(p,ii,jj,i,j)))

void     ZError (char *);
void     ZWarning (char *);

#define  OUTD(val)  (printf("out_%d \n",(val)))                       
#define  OUTF(val)  (printf("out_%f \n",(val)))                       
#define  OUTS(val)  (printf("out_%s \n",(val))) 

/* #define LOG (stderr)  */


#define MAX_OUT 10
typedef struct {
	int      numw;
	char    *legend;
	char    *fname;
	ZT_BOOL /* *ptr,  */val;
	FILE    *fout;

} ZT_OUT;

//------------------------------------------------------------------------------

int     ZRand123 (float p1, float p2, float p3);
ZT_BOOL ZRandYes (float procent);
int     ZRand123 (float p1, float p2, float p3);
void    ZValueRead (FILE *input, void *pdata,  char *type, char *name/* , char *value_def */);

/*******************************************************************************/   
#ifdef __cplusplus                                                               
}                                                                                
#endif                                                                           
// ******************************************************************************  
