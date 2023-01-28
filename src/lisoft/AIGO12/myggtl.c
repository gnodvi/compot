// -*-  mode: c    ; coding: koi8   -*- ----------------------------------------

/*******************************************************************************
 *                                                                             *
 *  Имя этого файла: myggtl.c                                                  *
 *                                                                             *
  ******************************************************************************
 */    
  
#define  DINAM_BOARD 

/*******************************************************************************
 * Example implementation of game to show the capabilites of GGTL
 *
 * GGTL provides generic game-tree search for many strategic games. This
 * is a trivial implementation of Tic-Tac-Toe that uses it.
 *
 * Copyright (C) 2004 Stig Brautaset
 * Copyright (C) 2003 Stig Brautaset, Dimitris Parapadakis and
 * the University of Westminster, London, UK.
 *
 */

#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include <string.h>

#include <math.h>
#include <time.h>

#include "common.h"
#include "ggtl.h"


int MY_DEBUG = FALSE;
//#define ATARIGO_GAME

struct ggtl *ago_new_game (int ii, int jj);

//---------------------------------------------------

/* struct aigo_ggtl_pos { */
/*   struct go_ggtl_pos *next; */
/*   int  isize, jsize; */
/*   int *board; */
/*   int  player; */
/* }; */

//---------------------------------------------------

#define TSIZE 3

int   score_max;
int   score_win; 

int (*score_fun) (struct ggtl_pos *state, int x);


struct ggtl_pos {
  struct ggtl_pos *next;
  //#ifdef DINAM_BOARD
  int   *p_doska;
  //#else
  //int    doska[ISIZE][JSIZE];
  //#endif
  int    player;
};

struct ggtl_move {
  struct ggtl_move *next;
  //int  x;
  //int  y; // чтобы не было путаницы надо заменить
  int    i;
  int    j;
};
/*----------------------------------------------------------------------------*/
typedef int (*YT_PFUNC) (struct ggtl_pos *);
//typedef  long (*YT_PFUNC) (PFUNC_PAR);                             

  int (*p_evaluate)   (struct ggtl_pos *);
  int (*p_end_of_game)(struct ggtl_pos *);


//#ifdef DINAM_BOARD
#define DOSKA(pos, i, j) ((pos->p_doska)[(i)*jsize+(j)])
//#else
//#define DOSKA(pos, i, j) ((pos->doska)[i][j])
//#endif


/*----------------------------------------------------------------------------*/
int isize/*  = ISIZE */;
int jsize /* = JSIZE */;

int *my_board;

#define BOARD_P(p, i, j) (p[(i)*jsize+(j)])
#define BOARD(i, j) (BOARD_P(my_board,i,j))


//#define STONE_NONE   -2
#define STONE_NONE  0
#define STONE_CONTACT_DAME 99

/*----------------------------------------------------------------------------
 * Show the board and the fitness for each player.
 *
 * param: board the game position to display
 *----------------------------------------------------------------------------*/
void show_board (struct ggtl_pos *board)
{
  int i, j, c;

  if (board != NULL) {
    puts ("");

    for (i = 0; i < isize; i++) {
    for (j = 0; j < jsize; j++) {
      c = DOSKA (board, i, j);

      if      (c == 1)  printf("x ");
      else if (c == 2)  printf("o ");
      else              printf(". ");
      
    }
    putchar('\n');
    }
    puts("\n");
  }
}
//----------------------------------------------------------------------------
//
//                             ATARIGO
//
//----------------------------------------------------------------------------
int IS_EF = FALSE;
int MAX_SCORE = 10000;
int MAX_DAME  = 1000;



#define BSIZE  7
#define BSIZE2 49

typedef struct {
  int stone;
  int ij_num, xy_num; // количество камней и дамэ у группы
  int i[BSIZE2], j[BSIZE2];   // координаты камней этой группы
  int x[BSIZE2], y[BSIZE2];   // координаты дамэ этой группы
} GT_GROUP;

typedef struct {
  int       stone, dame;
  GT_GROUP *group;
} GT_POINT;

typedef struct {
  int       groups_num;
  GT_GROUP  groups[BSIZE2];
  GT_POINT  goban[BSIZE][BSIZE];
} YT_WORK;

YT_WORK  *ptr_work;

/*----------------------------------------------------------------------------*/
void   
add_dame_to_group (GT_GROUP *g, int i, int j) 
{ 
  int d;

  for (d=0; d < g->xy_num; d++) {
    if ((g->x[d]==i) && (g->y[d]==j)) 
      return; // уже есть такое дамэ в группе
  }

  g->x[g->xy_num] = i;
  g->y[g->xy_num] = j;
  g->xy_num++;

  return;
}
/*----------------------------------------------------------------------------*/
void   
this_is_dame (GT_GROUP *g, int i, int j) 
{ 
#define DAME (ptr_work->goban[i][j].dame)

  // добавим это дамэ к группе
  add_dame_to_group (g, i, j); 

  //if (DAME==STONE_WHITE))

  if (DAME==g->stone) return; // уже посчитали это даме за свое (НО ЭТОЙ ЛИ ГРУППЫ????!)
  if (DAME==STONE_CONTACT_DAME) return; // а это за общее  (НО ЭТОЙ ЛИ ГРУППЫ????!)

  if (DAME==STONE_NONE) DAME = g->stone;
  else                  DAME = STONE_CONTACT_DAME;

  return;
}
/*----------------------------------------------------------------------------*/
void   
check_iteration (GT_GROUP *g, int i, int j) 
{ 
  // проверка на выход за границу
  if (i<0 || j<0 || i>isize-1 || j>jsize-1)
    return;

  if (BOARD(i,j) == STONE_NONE) {
    // разберемся с этим дамэ

    this_is_dame (g, i, j); 
    return;
  } 

  if (BOARD(i,j) != g->stone) 
    // это - камень противника, здесь делать нечего
    return;

  //----------------------------------------------
  //----------------------------------------------
  // а это значит камень нашего цвета

  if (ptr_work->goban[i][j].stone != STONE_NONE)
  return; // здесь мы уже были

  // отметим камень на схеме
  ptr_work->goban[i][j].stone = g->stone;
  ptr_work->goban[i][j].group = g;
  // добавим камень в группу
  g->i[g->ij_num] = i;
  g->j[g->ij_num] = j;
  g->ij_num++;
  
  check_iteration (g, i,  j-1);
  check_iteration (g, i,  j+1);
  check_iteration (g, i+1,  j);
  check_iteration (g, i-1,  j);

  return;
}
/*----------------------------------------------------------------------------*/
void   
game_get_group (int i, int j) 
{ 
  // описать группу для этого пункта-камня
  GT_GROUP *g = &(ptr_work->groups[ptr_work->groups_num]);

  g->stone = BOARD(i,j);
  g->ij_num = 0;
  g->xy_num = 0;

  check_iteration (g, i, j);

  return;
}
/*----------------------------------------------------------------------------*/
void   
game_get_groups (YT_WORK *ptr_work) 
{ 
  int i, j;

  for (i=0; i < isize; i++) 
  for (j=0; j < jsize; j++) {
    ptr_work->goban[i][j].dame  = STONE_NONE;
    ptr_work->goban[i][j].stone = STONE_NONE;
    ptr_work->goban[i][j].group = NULL;
  }

  ptr_work->groups_num = 0;

  for (i=0; i < isize; i++) 
  for (j=0; j < jsize; j++) {
    if (BOARD(i,j) == STONE_NONE) 
    continue;
    if (ptr_work->goban[i][j].stone != STONE_NONE) 
    continue;// здесь мы уже были

    game_get_group (i, j);
    ptr_work->groups_num++; 
  }

  return;
}
/*----------------------------------------------------------------------------*/
YT_WORK *
game_work_begin (/* int boardsize */)
{
  YT_WORK *ptr;
  ptr = (YT_WORK*) malloc (sizeof (YT_WORK));

  YRAND_S;  
  return (ptr);
}
/*----------------------------------------------------------------------------*/
int   
calc_min_dames (int stone) 
{ 
  int n, min_dames;
  GT_GROUP *g;

  min_dames = MAX_DAME;

  for (n=0; n < ptr_work->groups_num; n++) {
    g = &(ptr_work->groups[n]);

    if (g->stone != stone) continue;
 
    min_dames = YMIN (min_dames, g->xy_num);
  }

  return (min_dames);
}
/*----------------------------------------------------------------------------*/
int score_dame (int min_dames)
{
  int score=0;

  //score = min_dames;

  if      (min_dames == 0) score = -10;
  else if (min_dames == 1) score = 0;
  else if (min_dames == 2) score = 10;
  else if (min_dames >= 3) score = 20+min_dames;

  return (score);
}
/*----------------------------------------------------------------------------*/
int ago_myscore (struct ggtl_pos *state, int me)
{
  int score=0;
  int he_dames, me_dames, he/* , x_mindame, o_mindame */;
  int last_player = 3 - state->player;

  // расчитываем инфу о группах
  my_board = state->p_doska;
  game_get_groups (ptr_work);

  he = 3 - me;

  me_dames = calc_min_dames (me); 
  he_dames = calc_min_dames (he); 

  if      (last_player==he && me_dames==0) score = -MAX_SCORE; // атака удалась, он меня убил
  else if (last_player==me && he_dames==0) score =  MAX_SCORE; // атака удалась, он меня убил
  else if (last_player==me && me_dames==0) score = -MAX_SCORE; // я сам себя убил
  else if (last_player==he && he_dames==0) score =  MAX_SCORE; // он сам себя убил
  else {
    if (IS_EF) {
      //score = score_dame (me_dames);
      score = me_dames;
    } else {
      score =  0; // не определено еще
    }
  }

  //if (MY_DEBUG) {
  //  if (me==1) {x_mindame=me_dames; o_mindame=he_dames;}
  //  else       {x_mindame=he_dames; o_mindame=me_dames;}
  //  printf ("score=%d   x_mindame=%d  o_mindame=%d  \n", score, x_mindame, o_mindame);
  //}
  return (score);
}
//#ifdef ATARIGO_GAME
//#else
//----------------------------------------------------------------------------
//
//                         Tic-Tac-Toe GAME
//
//----------------------------------------------------------------------------
int ttt_add_score (int score, int xcount, int ocount)
{
  int add;

/*  if      (!ocount && xcount == 3) score += 1000; */
/*  else if (!ocount && xcount == 2) score += 10;   */
/*  else if (!ocount && xcount == 1) score++;       */

  if  (ocount) return (score);

  if (xcount == TSIZE)  add = score_max;
  else                  add = pow (10, (xcount-1));

  score += add;
  return (score);
}
//----------------------------------------------------------------------------
int calc_to_dir (int x, int o, struct ggtl_pos *state, int score, 
                 int i0,int iadd,  int j0, int jadd,  int num)
{
  int i, j, n;
  int xcount, ocount;
  int stone;

  xcount = ocount = 0;

  j = j0;
  i = i0;

  for (n = 0; n < num; n++) {
    stone = DOSKA (state, i, j);
    if      (x == stone) xcount++;
    else if (o == stone) ocount++;
    i += iadd;
    j += jadd;
  }

  score = ttt_add_score (score, xcount, ocount);

  return (score);
}
/*----------------------------------------------------------------------------
 * Calculate score for player @p x at position @p b.
 *
 * state - position to calculate score for
 * x     - player to calculate score for (это не обязательно крестик!!)
 *
 * return: The score for position @p b
 *----------------------------------------------------------------------------*/
int ttt_myscore (struct ggtl_pos *state, int x)
{
  int i, j, o;
  int score = 0;

  if (x == 1) o = 2;
  else        o = 1;

  /* horisontal */
  for (i = 0; i < TSIZE; i++) 
  score = calc_to_dir (x, o, state, score,  i,+0,  0,+1,  TSIZE);
  
  /* vertical */
  for (j = 0; j < TSIZE; j++) 
  score = calc_to_dir (x, o, state, score,  0,+1,  j,+0,  TSIZE);

  /* diagonal */
  score = calc_to_dir (x, o, state, score,  0,+1,  0,+1,  TSIZE);

  /* diagonal */
  score = calc_to_dir (x, o, state, score,  0,+1,  2,-1,  TSIZE);


  return (score);
}
//----------------------------------------------------------------------------
//#endif
//----------------------------------------------------------------------------
//
//                            MyGGTL Library
//
//----------------------------------------------------------------------------
int not_avail_move (struct ggtl_pos *state)
{
  int i, j, avail;

  // проверим количество пустых полей
  avail = 0;
  for (i = 0; i < isize; i++)
  for (j = 0; j < jsize; j++)
    
    if (DOSKA (state, i, j) == 0)
      avail++;

  if (avail == 0) // некуда вообще ходить
    return TRUE; 

  return FALSE;
}
/*----------------------------------------------------------------------------*/
// Evaluate position.
//
// state  - position to evaluate
// return - The value of the position.
/*---------------------------------------------------------------------------- 
 * Indicate if the game has ended. This can be either because someone
 * has won, or because there is no moves left to perform.
 *
 * state  - position to check for end on
 *
 * Return - 1 if the game is finished, or 0 if it is still going. 
 *----------------------------------------------------------------------------*/


/*----------------------------------------------------------------------------*/
//#ifdef ATARIGO_GAME
/*----------------------------------------------------------------------------*/
int ago_evaluate (struct ggtl_pos *state)
{
  int me_score, he_score, score, me;
  assert (state != NULL);

  me = state->player;

  me_score = ago_myscore (state, me);      // -1, 0, 1
  he_score = ago_myscore (state, 3 - me);  // -1, 0, 1

  score = me_score - he_score;


  if (MY_DEBUG) {
    printf ("----------------- \n");
    show_board (state);
    printf ("--------- score=%d \n", me_score);
  }

  return (me_score);
}
/*----------------------------------------------------------------------------*/
int ago_end_of_game (struct ggtl_pos *state)
{

  int me_score, me;
  assert (state != NULL);

  me = state->player;

  me_score = ago_myscore (state, me);

  if (me_score>=MAX_SCORE || me_score<=-MAX_SCORE) 
    return 1; 

  return (not_avail_move (state));
}
/*----------------------------------------------------------------------------*/
//#else // TIC-TAC-TOE
/*----------------------------------------------------------------------------*/
int ttt_evaluate (struct ggtl_pos *state)
{
  int me_score, he_score, me;
  assert (state != NULL);

  me = state->player;

  me_score = score_fun (state, me);
  he_score = score_fun (state, 3 - me);

  if (me_score > score_win) return  score_max;
  if (he_score > score_win) return -score_max;

  return (me_score - he_score);
}
/*----------------------------------------------------------------------------*/
int ttt_end_of_game (struct ggtl_pos *state)
{
  int me;
  assert (state != NULL);

  me = state->player;

  if (score_fun (state, 3 - me) > score_win) // противник победил
    return 1; 

  return (not_avail_move (state));
}
/*----------------------------------------------------------------------------*/
//#endif
//=============================================================================	

/*----------------------------------------------------------------------------*/
struct ggtl_pos *
my_create_state (int player)
{
  struct ggtl_pos *state; 

  state = calloc (1, sizeof (*state));
  if (!state)
      exit (EXIT_FAILURE);

  state->player = player;
  state->next   = NULL; 

  //#ifdef DINAM_BOARD
  // память для доски нужно также выделять динамически
  state->p_doska = calloc (isize*jsize, sizeof (int));
  //#else
  //state->p_doska = &(state->doska[0][0]);
  //#endif

  return (state);
}
/*-----------------------------------------------------------------------------
 * Copy a position. Use cached position if provided, else allocate the
 * necessary memory. Exit if the necessary memory cannot be allocated.
 *
 * dst - where to copy the position (if non-NULL)
 * src - the position to copy
 *
 * return: A pointer to the copy of the position is returned.
 *----------------------------------------------------------------------------*/
struct ggtl_pos *copy_pos (struct ggtl_pos *dst, struct ggtl_pos *src)
{
  int *save_p_doska;

  if (!dst) 
    dst = my_create_state (0); // здесь не важен игрок, все равно закопируется

  save_p_doska = dst->p_doska;
  memcpy (dst, src, sizeof (*src));

  //#ifdef DINAM_BOARD
  dst->p_doska = save_p_doska;
  memcpy (dst->p_doska, src->p_doska, isize*jsize*sizeof (int));
  //#else
  // при статическом задании доски нужно и указатель пересчитать ??
  // т.к. он забьется неверным из источника !!
  //dst->p_doska = &(dst->doska[0][0]);
  //#endif

  return (dst);
}
/*----------------------------------------------------------------------------
 * Perform a move.
 *
 * g      - struct with game information
 * board  - pointer to position to perform move on
 * move   - pointer to the move to perform
 *
 * return - Return 1 on success, or 0 if the move could not be performed.
 *----------------------------------------------------------------------------*/
struct ggtl_pos *make_move (struct ggtl *g, struct ggtl_pos *old, struct ggtl_move *move)
{
  struct ggtl_pos *new;
  int i;
  int j;
  int me;
	
  assert (old != NULL);

  i  = move->i;
  j  = move->j;
  me = old->player;

  /* square must not already be occupied */
  if (i < 0 || i > isize || j < 0 || j > jsize   || DOSKA (old, i, j) != 0)
    return NULL;

  new = ggtl_pop_pos (g);
  new = copy_pos (new, old);

  DOSKA (new, i, j) = me;
  new->player  = 3 - me;	/* make ready for next player */

  return (new);
}
/*----------------------------------------------------------------------------*/
// Find moves at position "st".
// 
// game  - ggtl state information
// state - game position
/*----------------------------------------------------------------------------*/
struct ggtl_move *
find_moves_1 (struct ggtl *game, int i, int j)
{
  struct ggtl_move *mv;

  mv = ggtl_pop_move (game); // берет позицию из кэша (зачем???)

  if (!mv) {
    mv = malloc (sizeof (*mv));

    if (!mv)
      exit(EXIT_FAILURE);
    mv->next = NULL;
  }

  mv->i = i;
  mv->j = j;

  return (mv);
}
/*----------------------------------------------------------------------------*/
void find_moves (struct ggtl *game, struct ggtl_pos *state)
{
  struct ggtl_move *mv;
  int i, j;

  assert (game != NULL); // аборт и сообщение об ошибке
  assert (state!= NULL);

  for (i = 0; i < isize; i++) 
  for (j = 0; j < jsize; j++) {
    if (DOSKA (state, i, j) != 0) continue;

    mv = find_moves_1 (game, i, j);
    //mv->x = i;
    //mv->y = j;

    ggtl_add_move (game, mv);
  }

  return;
}
/*----------------------------------------------------------------------------*/
int
show_end_game (struct ggtl *game, struct ggtl_pos *state, int is_print)
{
  int fitness, winer=0;

  if (is_print) {
    show_board (ggtl_peek_pos(game));
    puts ("\n");
  }

  fitness = p_evaluate (state);
  //fitness = game->evaluate(state);

  if  (fitness == 0) { 
    if (is_print) printf ("[ :: draw :: ]"); 
  } else  {              
    if (fitness > 0) winer = state->player;
    else             winer = 3 - state->player;

    if (is_print) printf ("[ :: player '%s' win :: ]", winer==1 ? "x" : "o");
  }

  if (is_print) puts ("\n");
  //printf ("[ Fitness value was %d  ] \n\n", fitness);

  ggtl_free (game);

  return (winer);
}
//-----------------------------------------------------------------------------
struct ggtl_move *
my_last_move (struct ggtl *g)
{
  struct ggtl_move *mv=NULL;

  //mv = ggtl__undo (g);
  //mv = sl_pop (&g->move_hist);

  if (!mv) return NULL;

  return (mv);
}
//-----------------------------------------------------------------------------
struct ggtl_pos *
my_get_move_old (struct ggtl *g, int maxply, int *p_i, int *p_j)
{
  struct ggtl_pos *board;
  struct ggtl_move *mv;

#if cfg__ttt_iterative
  board = ggtl_alphabeta_iterative (g, maxply);
#else
  board = ggtl_alphabeta (g, maxply);
#endif

  if (!board) return NULL;

  mv = my_last_move (g);
  if (!mv) return NULL;

  //ago_myscore (board, board->player);
  fprintf (stderr, "my_get_move: %d %d \n", mv->i, mv->j);

  *p_i = mv->i;
  *p_j = mv->j;
  return (board);
}
//-----------------------------------------------------------------------------
void my_set_move (struct ggtl *game, int i, int j)
{
  struct ggtl_pos *board;
  struct ggtl_move *mv;

  mv = find_moves_1 (game, i, j);
			
  board = ggtl_move (game, mv);
  if (!board) { 
    ggtl_push_move (game, mv);
    fprintf (stderr, "Error move: %d %d \n", mv->i, mv->j);
  }

  //fprintf (stderr, "my_set_move: %d %d \n", mv->i, mv->j);
  return;
}
//-----------------------------------------------------------------------------
struct ggtl_pos *
my_get_move (struct ggtl *g, int maxply, int *p_i, int *p_j)
{
  struct ggtl_pos *board;
  //struct ggtl_move *mv;

#if cfg__ttt_iterative
  board = ggtl_alphabeta_iterative (g, maxply);
#else
  board = ggtl_alphabeta (g, maxply);
#endif

  if (!board) return NULL;

  //mv = my_bestmove (g);
  //mv = my_last_move (g);
  //if (!mv) return NULL;

  //ago_myscore (board, board->player);
  //fprintf (stderr, "my_get_move: %d %d \n", my_bestmove->i, my_bestmove->j);
  //if (is_print) fprintf (stderr, "MAKE MOVE: %d %d \n", my_bestmove->i, my_bestmove->j);

  *p_i = my_bestmove->i;
  *p_j = my_bestmove->j;
  return (board);
}
/*----------------------------------------------------------------------------*/
// Main loop of simple Tic-Tac-Toe.
//
// game   - ggtl state information
// maxply - maximum ply to search to
/*----------------------------------------------------------------------------*/
void mainloop (struct ggtl *game, int maxply)
{
  char   move[100] = {0};
  struct ggtl_pos *board = ggtl_peek_pos (game);
  int    i, j;


  for (;;) { //-------------------------------
    //show_board (board);
    board = ggtl_peek_pos (game);
    show_board (board);

    fputs ("Chose action (??|undo|rate): ", stderr); 
    fflush (stdout);
    fgets (move, sizeof move, stdin); 


    if (!strncmp (move, "undo", 4)) {
      board = ggtl_undo (game);
      if (!board) {
        puts("Error: no move to undo\n");
      }
    }
    else if (!strncmp (move, "rate", 4)) {
      printf ("MiniMax value: %d\n\n", p_evaluate (board));
      board = NULL;
    }
    else if (move[0]=='\n') { // нажали ENTER - пусть ходит комп!

/* #if cfg__ttt_iterative */
/*       board = ggtl_alphabeta_iterative (game, maxply); */
/* #else */
/*       board = ggtl_alphabeta (game, maxply); */
/* #endif */

      board = my_get_move (game, maxply, &i, &j);
    }
    else { //---------------------------------------------------
      //x = 4 -(move[1]-'0')-1;
      //i = isize - (move[1]-'0')-1;
      //j =         (move[0]-'0')-1;

      i = (move[0]-'0');
      j = (move[1]-'0');

      //i =             (move[0]-'0')-1;
      //j = (isize-1) - (move[1]-'0')-1;
      //fprintf (stderr, "m0=%c m1=%c isize=%d  x=%d  y=%d  \n", move[0], move[1], isize, x, y);

      my_set_move (game, i, j);
    } //--------------------------------------------------------


    if (board && (p_end_of_game(board)))
      break;
  } 


  show_end_game (game, board, TRUE);
  return;
}
/*----------------------------------------------------------------------------*/
int 
mainloop_all (struct ggtl *game, int maxply, int is_print)
{
  int winer, i, j;
  struct ggtl_pos *state = ggtl_peek_pos (game);

  for (;;) {
    if (is_print) show_board (state);

    //board = ggtl_alphabeta (game, maxply);
    state = my_get_move (game, maxply, &i, &j);

    //if (board)
    //if (is_print) fprintf (stderr, "MAKE MOVE: %d %d \n", my_bestmove->i, my_bestmove->j);

    if (state && (p_end_of_game (state)))
      break;
  } 

  winer = show_end_game (game, state, is_print);

  return (winer);
}
/*----------------------------------------------------------------------------*/
struct ggtl *
my_create_game (int ii, int jj, YT_PFUNC eva, YT_PFUNC end)
{
  struct ggtl     *game;
  struct ggtl_pos *state; 

  isize = ii;
  jsize = jj;

  p_evaluate    = eva;
  p_end_of_game = end;

  game = ggtl_new (make_move, p_end_of_game, find_moves, p_evaluate);
  if (!game) 
    YERROR ("Sorry; NO GAME FOR YOU!");

  state = my_create_state (1);

  if (!ggtl_init (game, state)) {
    ggtl_free (game);
    YERROR ("Sorry; NO GAME FOR YOU!");
  }

  return (game);
}
/*----------------------------------------------------------------------------*/
void make_one_test (int ii, int jj, int w_true)
{
  int    t, w_calc;
  struct ggtl  *game;

  //isize = ii;
  //jsize = jj;

  for (t=0; t<10; t++) { 
    game = ago_new_game (ii, jj);
    //ptr_work = game_work_begin ();  
    //game  = my_create_game (ii, jj, ago_evaluate, ago_end_of_game);

    w_calc = mainloop_all (game, 100, FALSE);
    if (w_calc != w_true) break;
    //free (game);
  }

  if (w_calc == w_true) fprintf (stderr, "Test - TRUE \n");
  else                  fprintf (stderr, "Test - FALSE \n");

  return;
}
/*----------------------------------------------------------------------------*/
void make_all_test ()
{

  puts ("\n");
  make_one_test (1,2,  2);
  make_one_test (1,3,  1);
  make_one_test (1,4,  1);
  make_one_test (1,5,  1);

  make_one_test (2,2,  2);
  make_one_test (2,3,  2);
  puts ("\n");

}
/*----------------------------------------------------------------------------*/
struct ggtl *ago_new_game (int ii, int jj)
{
  struct ggtl  *game;

  IS_EF = TRUE;

  ptr_work = game_work_begin ();  
  game  = my_create_game (ii,jj, ago_evaluate, ago_end_of_game);

  return (game);
}
/*----------------------------------------------------------------------------*/
struct ggtl *ttt_new_game ()
{
  struct ggtl  *game;

  score_max = pow (10, TSIZE);
  score_win = 0.5* score_max; 
  score_fun = ttt_myscore;

  game  = my_create_game (3,3, ttt_evaluate, ttt_end_of_game);

  return (game);
}
/*----------------------------------------------------------------------------*/
void main_ttt ()
{
  struct ggtl     *game;

  game = ttt_new_game ();

  mainloop_all (game, 1, TRUE);

  return;
}
/*----------------------------------------------------------------------------*/
int main_ago ()
{
  struct ggtl  *game;

  make_all_test ();
  return 0;

  //--------------------------------------
  game = ago_new_game (3, 3);

  //MY_DEBUG = TRUE;
  //ggtl_set (game, GGTL_DEBUG, TRUE);

  mainloop_all (game, 4, TRUE);
  //mainloop (game, /* 100 */4);

  return 0;
}
/*----------------------------------------------------------------------------*/
//
//
/*----------------------------------------------------------------------------*/
