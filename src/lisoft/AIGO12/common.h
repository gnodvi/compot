// -*-  mode: c    ; coding: koi8   -*- ----------------------------------------

/****************************************************************************/                    
#ifdef __cplusplus                                                                
extern "C" {                                                                     
#endif                                                                                       
/****************************************************************************/   
#define  YERROR(str)  {fprintf (stderr, "ERROR: %s \n", (str)); exit(0);}

#define TRUE  1
#define FALSE 0

typedef short YT_BOOL;                                                          
#define CHAR int

#define OUTD(val)  (fprintf (stderr, "out_%d \n",(val)))                       
#define OUTF(val)  (fprintf (stderr, "out_%f \n",(val)))                       
#define OUTS(val)  (fprintf (stderr, "out_%s \n",(val))) 

#define is_pri TRUE
#define STDERR stderr 

#define YMAX(a,b)  (((a) > (b)) ? (a) : (b)) 
#define YMIN(a,b)  (((a) < (b)) ? (a) : (b))   

int     YInt (float f); 
void    Error (const char *msg);      
void    MyError (const char *msg);      

char  **YDirRead (void); 

/****************************************************************************/   

#define YRAND_S  srand((unsigned)time(NULL)) 
#define YRAND(imin,imax) (imin+rand()%(imax-imin+1)) 

  //extern  YT_BOOL  debuging;
  //#define DEBUGING debuging

void    dbg_proc_beg (char *str, int exp);
#define DBG_PROC_BEG(str, exp) dbg_proc_beg (str, exp)

void    DBG_PRINT (char *fmt, ...);

void    dbg_proc_end ();
#define DBG_PROC_END(str) dbg_proc_end (str)

void    dbg_set_maxlevel (int mlevel);

/*******************************************************************************/

#define LEFT left_buf                                                           
#define LEFT_BEG {LEFT[left_num]=' '; left_num+=2; LEFT[left_num]='\0';}        
#define LEFT_END {LEFT[left_num]=' '; left_num-=2; LEFT[left_num]='\0';}        
                                                                                
//-----------------------------------------------------
#define ED  printf("\x1b[2J") // стереть экран
#define EL  printf("\x1b[K")  // стереть строку
#define CUP(row,col) printf("\x1b[%d;%dH", row,col) // переместить курсор

#define CUU printf("\x1b[A")  // на одну строку вверх
#define CUD printf("\x1b[B")  // на одну строку вниз
#define CUF printf("\x1b[C")  // на одну строку вправо
#define CUB printf("\x1b[D")  // на одну строку влево

#define SCP printf("\x1b[s")  // считать текущую позицию курсора
#define RCP printf("\x1b[u")  // восстановит позицию курсора

/*******************************************************************************/

// ANSI  color-change escape sequences.                                         
// Xterm Control Sequences (this is the file ctlseqs.ms)                        
// man console_codes                                                            
                                                                                
#define SGR_DEFAULT  0                                                          
#define SGR_BOLD     1                                                          
#define SGR_BLACK   30    //set black foreground                                
#define SGR_RED     31    //set red foreground                                  
#define SGR_GREEN   32    //set green foreground                                
#define SGR_BROWN   33    //set brown foreground                                
#define SGR_BLUE    34    //set blue foreground                                 
#define SGR_MAGENTA 35    //set magenta foreground                              
#define SGR_CYAN    36    //set cyan foreground                                 
#define SGR_WHITE   37    //set white foreground                                

  //void    win_sgr (int par);

/*******************************************************************************/

typedef struct {
	int  w, h;
	char p[100][100];
} YT_WIN;

typedef long  YT_SPACE_NULL;

/* typedef struct { */
/*   int     i, x, y, delta_x, delta_y, exchange, err, incx, incy; */
/*   int     x_old, y_old, x_left, x_right; */
/*   BOOL    begin, end; */
/*   int     align; */
/* } VT_HANDLINE; */

YT_WIN* win_create (int w, int h);
void    win_char (YT_WIN *win, CHAR ch, int x, int y);
void    win_sgr (int par);
void    win_rect (YT_WIN *win, CHAR ch_horz, CHAR  ch_vert, int x, int y, int w, int h);
void    win_draw (YT_WIN *win, int x, int y);
void    win_delete (YT_WIN *win);

#define SKIP while(getchar()!='\n')
  
#define SKIP_LINE  fprintf(stderr, "\n")
  
/****************************************************************************/   
#ifdef __cplusplus                                                               
}                                                                                
#endif                                                                           
/****************************************************************************/   
