// -*-  mode: c    ; coding: koi8   -*- ----------------------------------------

/*******************************************************************************
 *                                                                             *
 *  Имя этого файла: gowork.h                                                  *
 *                                                                             *
  ******************************************************************************
 */  

#ifdef __cplusplus                                                               
extern "C" {                                                                     
#endif                                                                          
/******************************************************************************/   


#define BSIZE  7
#define BSIZE2 49

typedef struct {
  int stone;
  int ij_num, xy_num;        // количество камней и дамэ у группы
  int i[BSIZE2], j[BSIZE2];  // координаты камней этой группы
  int x[BSIZE2], y[BSIZE2];  // координаты дамэ этой группы
} GO_GROUP;

typedef struct {
  int       stone, dame;
  GO_GROUP *group;
} GO_POINT;

typedef struct {
  GO_BOARD  *aboard;
  int        isize, jsize;

  // надо сделать отдельным сервисом.....
  GO_MOVE    moves[100]; // история ходов
  int        moves_num;

  int        groups_num;
  GO_GROUP   groups[BSIZE2];
  GO_POINT   goban[BSIZE][BSIZE];
} GO_WORK;

#define BOARD_PS(p, ii, jj, i, j) (p[(i)*(jj)+(j)])

#define WBOARD(i, j) (((w->aboard)->board)[(i)*((w->aboard)->jsize)+(j)])

/****************************************************************************/   

GO_WORK  *work_begin (int, int, GO_BOARD *a);
void      work_get_groups (GO_WORK *, GO_BOARD *a);
GO_GROUP* work_find_captured_group (GO_WORK *w, int stone);
int       work_is_this_good (GO_WORK *, int my_stone, int i, int j); 
void      work_get_captures (GO_WORK *, int is_set, int *p_ib_cap, int *p_iw_cap
                             /* , GO_STONE last_stone */);
int       work_is_move_suicide (GO_WORK *, int stone, int i, int j); 

int       work_random_move (GO_WORK *, int stone, int *i_move, int *j_move); 

GO_GROUP* work_find_captured_group (GO_WORK *w, int stone);
int       work_calc_mindames (GO_WORK *w, GO_STONE stone); 
void      work_get_calcus (GO_WORK *w, GO_STONE stone, int *p_min_dames, int *p_num_capts) ;

int       work_set_move (GO_WORK *w, int stone, int i_move, int j_move);
int       work_del_move (GO_WORK *w);

extern int  debug;

/****************************************************************************/   
#ifdef __cplusplus                                                               
}                                                                                
#endif                                                                           
/****************************************************************************/   

