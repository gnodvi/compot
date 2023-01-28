// -*-  mode: c    ; coding: koi8   -*- ----------------------------------------

/*******************************************************************************
 *                                                                             *
 *  Имя этого файла: aboard.h                                                  *
 *                                                                             *
  ******************************************************************************
 */  


/****************************************************************************/   

typedef  short  GO_STONE;                                                          


#define STONE_NONE   0
#define STONE_WHITE  1
#define STONE_BLACK  2

#define STONE_CONTACT_DAME 99

#define STONE_WHITE_FALSE 11
#define STONE_BLACK_FALSE 22

#define STONE_WHITE_DEAD  111
#define STONE_BLACK_DEAD  221

#define STONE_OTHER(stone) (stone==STONE_WHITE ? STONE_BLACK : STONE_WHITE)
#define STONE_NEXT(stone)  (stone==STONE_WHITE ? STONE_BLACK : STONE_WHITE)

#define STONE_CHAR(stone)  (stone==STONE_WHITE ? '0' : 'X')
#define STONE_NAME(stone)  (stone==STONE_WHITE ? "WHITE" : "BLACK")

/******************************************************************************/

typedef struct {
  int  i, j;
  int  move_stone;
} GO_MOVE;

GO_MOVE *xo_malloc_move (int i, int j);

/******************************************************************************/

typedef struct {
  GO_MOVE    moves[100]; // история ходов
  int        moves_num;
} GO_MOVES;

GO_MOVES *moves_create ();
void      moves_add (GO_MOVES *mvs, int i, int j, int stone);
GO_MOVE*  moves_get (GO_MOVES *mvs, int n);
void      moves_init (GO_MOVES *mvs);
int       moves_num (GO_MOVES *mvs);
void      moves_del (GO_MOVES *mvs, int n);

/******************************************************************************/

typedef struct {
  int   isize, jsize;  
  int  *board;
} GO_BOARD;

#define BOARD(b, i, j) (((b)->board)[(i)*((b)->jsize)+(j)])

typedef  struct  {
  GO_BOARD *a;
  int       stone; 
} GO_POSI;

void     xo_show_board     (GO_POSI *pos);
GO_POSI *xo_pos_copy (GO_POSI *dst, GO_POSI *src);
GO_POSI *xo_pos_create (int stone, int ii, int jj);

/******************************************************************************/

/******************************************************************************/

GO_BOARD *aboard_begin (int isize, int jsize);
void      aboard_set_stone (GO_BOARD *a, int stone, int i_move, int j_move);
void      aboard_del_stone (GO_BOARD *a, int i, int j);

int       aboard_is_move_legal (GO_BOARD*, int i, int j);
void      aboard_show (GO_BOARD*); 
void      aboard_show_old (GO_BOARD *a); 

char*     board_name_from_index (GO_BOARD *a, int i, int j); 
void      board_name_to_index (GO_BOARD *a, char *name, int *i_ptr, int *j_ptr); 

int       board_random_stone (GO_BOARD *b, int *i_move, int *j_move); 
int       board_random_rect_stone (GO_BOARD *b, int, int, int, int, int *i_move, int *j_move); 
GO_BOARD *board_copy (GO_BOARD *from);

/******************************************************************************/

int       stone_from_char (char ch);

/******************************************************************************/
//                                                                             /
/******************************************************************************/
