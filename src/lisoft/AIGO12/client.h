// -*-  mode: c    ; coding: koi8   -*- ----------------------------------------

/*******************************************************************************
 *                                                                             *
 *  Имя этого файла: client.h                                                  *
 *                                                                             *
  ******************************************************************************
 */  


/******************************************************************************/                  
#ifdef __cplusplus                                                               
extern "C" {                                                                     
#endif                                                                                     
/******************************************************************************/   



/******************************************************************************/   
#define  GPROC_PAR   int, long, long, long, long, long 
#define  GPROC_VAR   int message, long mes1, long mes2, long mes3, long mes4, long mes5  
typedef  long (*YT_GPROC) (GPROC_PAR);                              
 
enum y_enum { 
   YM_CREATE, YM_SETSTONE, YM_SETMOVE, YM_GETMOVE 
}; 

/******************************************************************************/   
typedef struct {
  GO_STONE  color;
  char      name[150];
  long      param;
  int       maxply;
  MM_MAIN  *mm;
  GO_BOARD *board; // указатель на главную доску
  GO_WORK  *work; 
} GO_GAMER;

typedef struct {
  int        isize, jsize;
  GO_BOARD  *aboard; // доска должна быть здесь!!!
  GO_WORK   *mywork;
  int        gamer_num;
  GO_GAMER   gamer[20];  // надо уточнить, т.е. оставить только двух игроков !?
} GO_GAME;

#define GAMER (g->gamer[n_gamer])
#define GAMER_NEXT(gamer)  (gamer==0 ? 1 : 0) 
#define GBOARD(i, j) ((((g->mywork)->aboard)->board)[(i)*(g->jsize)+(j)])

/******************************************************************************/   

GO_GAME *game_begin (int ii, int jj);
int      game_create_gamer (GO_GAME *, char *name, int param, GO_STONE color);

YT_BOOL  game_make_move (GO_GAME *, int n_gamer, GO_STONE stone);

int      game_set_move (GO_GAME *, int i_move, int j_move, GO_STONE stone);
void     game_showboard (GO_GAME *); 
void     game_set_board (GO_GAME *, int *d_board);
void     game_set_stone (GO_GAME *, int i_move, int j_move, GO_STONE stone);
void     game_get_board (GO_GAME *, int *d_board);

int      game_random_stone_new (GO_GAME *, int *i_move, int *j_move); 
int      game_random_handicap (GO_GAME *g, int, int *i_move, int *j_move); 

  //void     game_set_position (GO_GAME *g, YT_POSITION *pp) ;
void     game_finish (GO_GAME *);

char*    game_get_prog (char *gamer_name);
int      game_autoplay (GO_GAME *g, char *prog1, char *prog2, int is_print, int param);


/******************************************************************************/   

/******************************************************************************/   
#ifdef __cplusplus                                                               
}                                                                                
#endif                                                                           
/******************************************************************************/   
