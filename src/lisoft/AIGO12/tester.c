// -*-  mode: c    ; coding: koi8   -*- ----------------------------------------

/*******************************************************************************
 *                                                                             *
 *  Имя этого файла: tester.c                                                  *
 *                                                                             *
  ******************************************************************************
 */  

#include  <stdio.h>
#include  <stdlib.h>   
#include  <string.h>
#include  <math.h>
#include  <time.h>  
#include  <unistd.h> 
#include  <ctype.h>  
#include  <dirent.h> 
#include  <sys/time.h> 
#include  <sys/param.h>
                                                                             
#include "common.h"
#include "aboard.h"
#include "gowork.h"

#include "minmax.h" 
#include "client.h"

#include "search.h"
#include "evalut.h"

/******************************************************************************/

typedef struct {
  char *pos_old_new[10];
} YT_PROB_2x5x5;

typedef struct {
   int    ii, jj;
   char  *pos[5];

  GO_STONE stone;
} YT_POSITION;
  

/*----------------------------------------------------------------------------*/
void
test_play_one (int wins_true, char *prog1, char *prog2, int ii, int jj)
{

  GO_GAME *g = game_begin (ii, jj);

  int wins_calc = game_autoplay (g, prog1, prog2, /* is_print */FALSE, /*param*/0);

  if (wins_calc == wins_true)  fprintf (stderr, ".......... OK \n");
  else {
    fprintf (stderr, "\n.......... ERROR \n");
    game_showboard (g);
  }

  game_finish (g);

  return;
}
/*----------------------------------------------------------------------------*/
void
test_play_all (char *prog1, char *prog2)
{
  int BlackWin = STONE_BLACK;
  int WhiteWin = STONE_WHITE;

  fprintf (stderr, "\n");

  //test_play_one (WhiteWin, prog1, prog2, 0, 0);
  // желательно этот крайний случай тоже рассмотреть потом!!!!!

  test_play_one (WhiteWin, prog1, prog2, 1, 1);
  test_play_one (WhiteWin, prog1, prog2, 1, 2);
  test_play_one (BlackWin, prog1, prog2, 1, 3);
  test_play_one (BlackWin, prog1, prog2, 1, 4);
  test_play_one (BlackWin, prog1, prog2, 1, 5);
  test_play_one (BlackWin, prog1, prog2, 1, 6); 
  test_play_one (BlackWin, prog1, prog2, 1, 7);
  //test_play_one (BlackWin, prog1, prog2, 1, 8);
  //test_play_one (BlackWin, prog1, prog2, 1, 9);

  test_play_one (WhiteWin, prog1, prog2, 2, 2);
  test_play_one (WhiteWin, prog1, prog2, 2, 3);
  //test_play_one (WhiteWin, prog1, prog2, 2, 4);
  //ame_test_one (BlackWin, prog1, prog2, 2, 5);

  return;
}
/*----------------------------------------------------------------------------*/
void
test_prob_lines_to_ints (GO_WORK *w, char *pos_lines[], int *pos_old, int *pos_new)
{
  int   i, j;
  char *line_old, *line_new;

  for (i=0; i < w->isize; i++) {
    line_old = pos_lines[2*i];
    line_new = pos_lines[2*i+1];

    for (j=0; j<w->jsize; j++) {
      BOARD_PS (pos_old, w->isize, w->jsize, i, j) =  stone_from_char (line_old[j]);
      BOARD_PS (pos_new, w->isize, w->jsize, i, j) =  stone_from_char (line_new[j]);
   }
  }

  return;
}
/*----------------------------------------------------------------------------*/
int
test_prob_compare (GO_WORK *w, int *poscalc, int *postrue)
{
  int   i, j;

  for (i=0; i<w->isize; i++) 
  for (j=0; j<w->jsize; j++) {
    if (BOARD_PS (poscalc, w->isize, w->jsize, i,j) != BOARD_PS (postrue, w->isize, w->jsize, i,j))
      return (FALSE);
  }
  
  return (TRUE);
}
/*----------------------------------------------------------------------------*/
void
test_prob_one (char *prog_string, YT_PROB_2x5x5 *prob)
{
  GO_STONE stone = STONE_BLACK;
 
  GO_GAME *g = game_begin (5, 5);
  int gamer  = game_create_gamer (g, prog_string, 0, stone);

  int  b_cap, w_cap;
  int  pos_old[25], pos_new_true[25], pos_new_calc[25];

  test_prob_lines_to_ints (g->mywork, prob->pos_old_new, pos_old, pos_new_true);
  game_set_board (g, pos_old);

  game_make_move (g, gamer, stone);

  work_get_captures (g->mywork, TRUE, &b_cap, &w_cap/* , stone */);
  game_get_board (g, pos_new_calc);

  if (test_prob_compare (g->mywork, pos_new_calc, pos_new_true))
    fprintf (stderr, ".......... OK \n");
  else {
    fprintf (stderr, "\n");
    fprintf (stderr, ".......... ERROR \n");
    game_showboard (g);

  }

  game_finish (g);
  return;
}
/*----------------------------------------------------------------------------*/
void
test_prob_all (char *prog_string)
{
  YT_PROB_2x5x5 prob1 = {{
    ".....",   ".....",
    ".....",   ".....",
    ".....",   ".....",
    "X....",   "X....",
    "O....",   "@X...", 
  }}; 
  YT_PROB_2x5x5 prob3 = {{
    ".....",   ".....",   
    ".....",   ".....",   
    "OOOOO",   "OOOOO",   
    "XXXX.",   "XXXXX",   
    "XXXOO",   "XXX@@",   
  }};
  YT_PROB_2x5x5 prob4 = {{
    ".....",   ".....",   
    ".....",   ".....",   
    "XXXXX",   "XXXXX",   
    "OOOO.",   "@@@@X",   
    "OOOXX",   "@@@XX",   
  }};
  YT_PROB_2x5x5 prob5 = {{
    ".....",   ".....",
    ".....",   ".....",
    ".....",   ".....",
    "XXXXX",   "XXXXX",
    "OO.OO",   "@@X@@", 
  }};  
  YT_PROB_2x5x5 prob7 = {{
    "XXXXX",   "XXXXX",  
    "XOOOO",   "X@@@@", 
    "XXXXO",   "XXXX@", 
    ".XOOO",   ".X@@@", 
    ".XO.O",   ".X@X@", 
  }};  
  YT_PROB_2x5x5 prob8 = {{
    "XO.O.",   "XO.O.",  
    "XOOOX",   "XOOOX",  
    "XXXOX",   "XXXOX",  
    "XOOXX",   "X@@XX",  
    "X.OXX",   "XX@XX",  
  }};   
  YT_PROB_2x5x5 prob9 = {{
    ".XOOO",   ".X@@@",  
    "..XOO",   "..X@@",  
    "..XOO",   "..X@@",  
    "...XO",   "...X@",  
    "...O.",   "...OX",  
  }};  
 

  fprintf (stderr, "\n");
  
  test_prob_one (prog_string, &prob1);
  test_prob_one (prog_string, &prob3);
  test_prob_one (prog_string, &prob4);
  test_prob_one (prog_string, &prob5);
  test_prob_one (prog_string, &prob7);    
  test_prob_one (prog_string, &prob8);
  test_prob_one (prog_string, &prob9);

  return;
}
/*----------------------------------------------------------------------------*/
void 
game_set_position (GO_GAME *g, YT_POSITION *pp) 
{
  int   i, j;
  char *line;

  for (i=0; i < pp->ii; i++) {
    line = pp->pos[i];

    for (j=0; j < pp->jj; j++) {
      if      (line[j]=='O')  game_set_stone (g, i, j, STONE_WHITE); 
      else if (line[j]=='X')  game_set_stone (g, i, j, STONE_BLACK);
      else                    game_set_stone (g, i, j, STONE_NONE); 
   }
  }

  return;
}
/*----------------------------------------------------------------------------*/
int
test_eval_one (YT_POSITION *p)
{
  int e = 0;
  GO_GAME *g;
  int      n_gamer;
  //GO_STONE stone = p->stone/*  = STONE_BLACK */;
  GO_POSI  posi;

  g      = game_begin (p->ii, p->jj);
  n_gamer  = game_create_gamer (g, "aigo2", 0, /* stone */STONE_BLACK);
  game_set_position (g, p); 
  
  posi.a = g->aboard;
  posi.stone = /* stone */p->stone;

  game_showboard (g);

  //OUTD (00);
  e = aigo_evaluate ((long)&(GAMER), (long)(&posi)/* , 0, STONE_BLACK */);
  fprintf (stderr, "e = %d \n", e);

  //game_finish (g);
  return (e);
}
/*----------------------------------------------------------------------------*/
void
test_eval_all ()
{

  YT_POSITION pos1x3[] = {
    { 1,2 , { ".." }, STONE_BLACK},   

    { 1,2 , { "X." }, STONE_WHITE},   
    { 1,2 , { "XO" }, STONE_BLACK}, 

    { 1,2 , { ".X" }, STONE_WHITE},   
    { 1,2 , { "OX" }, STONE_BLACK}, 
    { 0,0 , { NULL }}
  };  

  int e, p;
 
  for (p = 0; (pos1x3[p].ii) != 0; p++) {
    e = test_eval_one (&(pos1x3[p]));
  } 

  return;
}
/*----------------------------------------------------------------------------*/
int 
main_switch_test (int num_var, char **ptr_var) 
{
  int mode;

  if (num_var == 0) mode = 20; // без параметров, печатаю хелп..
  else              mode = atoi (ptr_var[0]);

  switch (mode) {
  case 20:
  case 0: //--------------------------------------------------------
    if (mode==20)  fprintf (stderr, "0 - ALL TESTS [@ == debug] \n\n");
    else {
      test_prob_all ("aigo1"); 
      test_play_all ("aigo", "aigo"); 
      break;
    }

  case 1: //--------------------------------------------------------
    if (mode==20)  fprintf (stderr, "1 - test_eval_all \n");
    else {

      test_eval_all (); 
      break;
    }

  case 2: //--------------------------------------------------------
    if (mode==20)  fprintf (stderr, "2 - test_prob_all [prog] \n");
    else {
      char *prog = ptr_var[1];

      test_prob_all (prog); 
      break;
    }

  case 3: //--------------------------------------------------------
    if (mode==20)  {
      fprintf (stderr, "3 - auto_play [prog1 prog2  ii jj] \n");
    } else {
      char *prog1 = ptr_var[1];
      char *prog2 = ptr_var[2];
      int   ii    = atoi (ptr_var[3]);
      int   jj    = atoi (ptr_var[4]);

      GO_GAME *g  = game_begin (ii, jj);
      game_autoplay (g, prog1, prog2, /* is_print */TRUE, 0);
      game_finish (g);
      break;
    }

  default: //--------------------------------------------------------
    if (mode!=20) 
    fprintf (stderr, "Sorry, what you want ??\n");
  }

  fprintf (stderr, "\n");
  return 1;
} 
/*----------------------------------win_test----------------------------------*/
void
win_test ()
{ 

  printf ("\n");
  win_sgr (SGR_BOLD);
  win_sgr (SGR_RED);
  fprintf (stderr, "SGR_BOLD - SGR_RED \n");
  win_sgr (SGR_DEFAULT);
  printf ("\n");

  //-------------------------------
  YT_WIN  *win;

  // создаем экранную форму и рисуем главную рамочку
  win = win_create (5, 3);
  win_rect (win, '=', '|', 0, 0, 5, 3);
  win_draw (win, 0, 0);

  //-------------------------------
  return;
}
/*----------------------------------board_test--------------------------------*/
void
board_test ()
{ 

  int board[9] = {0,0,0, 0,1,2, 0,0,0};
  GO_BOARD a = { 3, 3, &board[0]};

  printf ("\n");
  aboard_show (&a); 
  printf ("\n");

  return;
}
/*--------------------------------------main----------------------------------*/
/*                                                                            */
/*----------------------------------------------------------------------------*/
int
main (int argc, char **argv) 
{
  int    num_var = argc-1;
  char **ptr_var = argv+1;

  //myeuler_test ();

  //win_test ();
  //board_test ();
  //return 1;

  if ((num_var > 1) && (ptr_var[0][0] == '@')) { // ввести "звездочку" не получается!

    dbg_set_maxlevel (10);
    // надо сделать более гибким управление такой отладкой, т.е.
    // указывать интервалы уровней и/или их имена...

    num_var--;
    ptr_var++;
  } 
  
  fprintf (stderr, "\n");
  main_switch_test (num_var, ptr_var); 

  return 1;
} 
//-------------------------------------------------------------------------------
