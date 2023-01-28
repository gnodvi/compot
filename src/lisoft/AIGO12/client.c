// -*-  mode: c    ; coding: koi8   -*- ----------------------------------------

/*******************************************************************************
 *                                                                             *
 *  Имя этого файла: client.c                                                  *
 *                                                                             *
  ******************************************************************************
 */  

/*----------------------------------------------------------------------------*/
 
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <time.h>

#ifdef _UNIX 
#include <unistd.h>
#else

#include <windows.h>
#include <io.h>
#include <fcntl.h>
#include <process.h>

#include <process.h>
#include <memory.h>
#include <string.h>
#include <stdio.h>
#include <fcntl.h>
#include <io.h>
#endif     

#include <assert.h>

#include "common.h"
#include "aboard.h"
#include "gowork.h"

#include "minmax.h" 

#include "client.h"
#include "evalut.h"

/******************************************************************************/

/*----------------------------------------------------------------------------*/
GO_GAME*
game_begin (int ii, int jj)
{
  GO_GAME *g;
 
  g = (GO_GAME*) malloc (sizeof(GO_GAME));
  g->isize = ii;
  g->jsize = jj;

  g->gamer_num = 0;

  g->aboard = aboard_begin (ii, jj);
  g->mywork = work_begin (ii, jj, g->aboard);

  if (!g) MyError ("game_begin");

  return (g);
}
/******************************************************************************/
int get_name_num (char *string, char *name)
{
  int num;
  int offset = strlen (name);

  if (strlen(string) == offset)
    return (0);

  num = atoi (string+offset);

  return (num);
}
/*----------------------------------------------------------------------------*/
void
game_showboard (GO_GAME *g) 
{

  aboard_show ((g->mywork)->aboard);

}
/*----------------------------------------------------------------------------*/
void
game_finish (GO_GAME *g)
{


  return;
}
/*----------------------------------------------------------------------------*/
void
game_set_stone (GO_GAME *g, int i_move, int j_move, GO_STONE stone)
{

  GBOARD (i_move, j_move) = stone;

  return;
}
/*----------------------------------------------------------------------------*/
int
game_set_move (GO_GAME *g, int i_move, int j_move, GO_STONE stone)
{

  // дополнительная проверка гл. судьи (а надо ли?!)
  if (!aboard_is_move_legal (g->aboard, i_move, j_move))
    return (FALSE); 

  // сделать ход на доске
  aboard_set_stone (g->aboard, stone, i_move, j_move);

  // запомнить последний ход  
  work_set_move (g->mywork, stone, i_move, j_move);

  return (TRUE);
}
/*----------------------------------------------------------------------------*/
void
game_set_board (GO_GAME *g, int *d_board)
{
  int  i, j, stone;

  for (i = 0; i < g->isize; i++) 
  for (j = 0; j < g->jsize; j++) {

    stone = BOARD_PS (d_board, g->isize, g->jsize, i, j);

    game_set_stone (g, i, j, stone);
  }

  return;
}
/*----------------------------------------------------------------------------*/
void
game_get_board (GO_GAME *g, int *d_board)
{
  int i, j, stone;

  for (i = 0; i < g->isize; i++) {
  for (j = 0; j < g->jsize; j++) {
    stone = GBOARD (i,j);
    d_board[i*(g->jsize)+j] = stone;
  }
  }

  return;
}
/*----------------------------------------------------------------------------*/



/******************************************************************************/
//                                                                            //
/******************************************************************************/

/*----------------------------------------------------------------------------*/
void   
stone_print (GO_WORK *w, int i, int j) 
{ 
  int  stone = WBOARD(i, j);
  char *name = "Error stone: ";

  if      (stone == STONE_WHITE) name = "White stone: ";
  else if (stone == STONE_BLACK) name = "Black stone: ";
  else if (stone == STONE_CONTACT_DAME) name = "CONTACT_DAME! :";
  else if (stone == STONE_NONE)         name = "STONE_NONE: ";
  else if (stone == STONE_WHITE_DEAD)   name = "WHITE_DEAD: ";
  else if (stone == STONE_BLACK_DEAD)   name = "BLACK_DEAD: ";
  else if (stone == STONE_WHITE_FALSE)  name = "WHITE_FALSE: ";
  else if (stone == STONE_BLACK_FALSE)  name = "BLACK_FALSE: ";
  else 
    OUTD (stone);

  fprintf (stderr, "%s (%d %d) \n", name, j, i);

  return;
}
/*----------------------------------------------------------------------------*/
int   
game_random_handicap (GO_GAME *g, int handicap, int *i_move, int *j_move) 
{ 
  YT_BOOL ret = FALSE;
  GO_BOARD *b = (g->mywork)->aboard;
  
  //if (handicap <= 2) 
  //  ret = board_random_rect_stone (b, 1, 1, b->isize-2, b->isize-2, i_move, j_move);
  //else
    ret = board_random_stone (b, i_move, j_move);

  return (ret);
}
/*----------------------------------------------------------------------------*/
int   
game_random_stone_new (GO_GAME *g, int *i_move, int *j_move) 
{ 

  return (board_random_stone ((g->mywork)->aboard, i_move, j_move));

}
/******************************************************************************/
//                                                                            //
/******************************************************************************/

/*----------------------------------------------------------------------------*/
int 
game_atarigo_who_win (GO_GAME *g/* , GO_STONE last_stone */) 
{
  int   who_win;
  int   b_cap, w_cap;

  work_get_captures (g->mywork , TRUE, &b_cap, &w_cap/* , last_stone */);

  if      (b_cap > 0)  who_win = STONE_BLACK;
  else if (w_cap > 0)  who_win = STONE_WHITE;
  else         
    who_win = 0;

  return (who_win);
}
//------------------------------------------------------------------------------
void
gamer_get_move (GO_GAMER *gamer, int *p_i, int *p_j)
{
  GO_MOVE *bestmove;
  long    bmove;

  GO_POSI  posi = {/* NULL, */ gamer->board, gamer->color};
  GO_POSI *pos  = &posi; // каждый раз берет текущую позицию с главной доски!!

  mm_minimax (gamer->mm, (long)pos , gamer->maxply, &bmove, (long)gamer);
  if (bmove) {
    bestmove = (GO_MOVE *) bmove;
    *p_i = bestmove->i;
    *p_j = bestmove->j;
  } else {
  }

  return;
}
/*----------------------------------------------------------------------------*/
YT_BOOL
game_make_move (GO_GAME *g, int n_gamer, GO_STONE stone)
{
  int     i_move, j_move;
  YT_BOOL ret = TRUE;

  // игрок подумал

  gamer_get_move (&(GAMER), &i_move, &j_move);
  //ret = goga_get_move (g, g->mywork, &i_move, &j_move, stone);

  // и сделал (зафиксировал) этот ход
  game_set_move (g, i_move, j_move, stone);

  return (ret);
}
/*----------------------------------------------------------------------------*/
int
game_autoplay (GO_GAME *g, char *prog1, char *prog2, int is_print, int param)
{
  int   who_win;

  int   gamer1     = game_create_gamer (g, prog1, param, STONE_WHITE);
  int   gamer2     = game_create_gamer (g, prog2, param, STONE_BLACK);

  int   stone = STONE_BLACK;   // первый ход у черных
  int   gamer = gamer2;        // т.е. у второго  игрока !!

  while (1) { //-------------------------
    game_make_move (g, gamer, stone);
    who_win = game_atarigo_who_win (g/* , stone */);

    if (is_print) game_showboard (g);  
    if (who_win) break; 
    
    stone = STONE_NEXT (stone);
    gamer = GAMER_NEXT (gamer);
  } //-----------------------------------

  if (is_print) printf ("--------------> %s win! \n", STONE_NAME(who_win));

  gamer1++;       // оказался не нужен !
  return (who_win);
}

/******************************************************************************/


/*----------------------------------------------------------------------------*/

/*----------------------------------------------------------------------------*/
GO_POSI *
xo_make_move (GO_POSI *old, GO_MOVE *move)
{
  GO_BOARD *a;
  GO_POSI   *new;
  int  i, j, me;
	
  assert (old != NULL);
  a = old->a;

  i  = move->i;
  j  = move->j;
  me = old->stone;

  /* square must not already be occupied */
  if (i < 0 || i > a->isize || j < 0 || j > a->jsize   || BOARD (a, i, j) != 0)
    return NULL;

  new = xo_pos_copy (NULL, old);

  BOARD (new->a, i, j) = me;
  new->stone  = STONE_NEXT (me);  /* make ready for next player */

  return (new);
}
/*----------------------------------------------------------------------------*/
long  
go_make_move (long pstr, long old_posi, long move)
{ 


  return ((long)xo_make_move ((GO_POSI *)old_posi, (GO_MOVE *)move));

}
/*----------------------------------------------------------------------------*/
char* 
go_name_posi (long pstr, long posi)
{ 

  GO_POSI *pos = (GO_POSI*) posi;

  xo_show_board (pos); 
    
  return (NULL);
}
/*----------------------------------------------------------------------------*/


/*----------------------------------------------------------------------------*/
//
/*----------------------------------------------------------------------------*/
char* 
go_name_move (long move, long pstr_new)
{ 
  static char buf[80];
  char       *name;

  if (!move) return ("");
  GO_MOVE     *mov = (GO_MOVE *) move;

  GO_BOARD *board = ((GO_GAMER*) pstr_new)->board; 
  if (!board) MyError ("board");

  name = board_name_from_index (board, mov->i, mov->j);
  sprintf (buf, "%s", name);

  return (buf);
}
/*----------------------------------------------------------------------------*/
int 
game_create_gamer (GO_GAME *g, char *prog_name, int param, GO_STONE color)
{
  int n_gamer = g->gamer_num;

  GAMER.color = color;
  if (prog_name) strcpy (GAMER.name, prog_name);

  //--------------------------------------------

  int maxply   = get_name_num (GAMER.name, "aigo");
  if (maxply == 0) maxply = g->isize * g->jsize;

  GAMER.maxply = maxply;
  GAMER.mm = mm_create (NULL, aigo_findmoves, 
                      aigo_evaluate, go_make_move, NULL,
                      go_name_move, go_name_posi, (int) color);

  GAMER.board = g->aboard;
  GAMER.work   = work_begin (g->isize, g->jsize, g->aboard);
  //--------------------------------------------


  g->gamer_num++;
  return (n_gamer);
}
/******************************************************************************/
//                                                                            //
/******************************************************************************/
