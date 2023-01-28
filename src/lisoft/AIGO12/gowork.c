// -*-  mode: c    ; coding: koi8   -*- ----------------------------------------

/****************************************************************************
 *                                                                          *
 *  Имя этого файла: gowork.c                                               *
 *                                                                          *
 ****************************************************************************
 */  

/*----------------------------------------------------------------------------*/
 
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
//#include <conio.h>
#include <ctype.h>
#include <time.h>

#ifdef _UNIX 
#include <unistd.h>
//#include <time.h>
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


#include "common.h"
#include "aboard.h"
#include "gowork.h"

int  debug = FALSE;

/*----------------------------------------------------------------------------*/

/*----------------------------------------------------------------------------*/
GO_WORK *
work_begin (int isize, int jsize, GO_BOARD *a)
{
  GO_WORK *w = (GO_WORK*) malloc (sizeof (GO_WORK));

  w->aboard = a;

  w->isize  = isize;
  w->jsize  = jsize;

  w->moves_num = 0;

  YRAND_S;  

  return (w);
}
/*----------------------------------------------------------------------------*/
void   
work_groups_print (GO_WORK *w) 
{ 
  //GO_WORK *w = ptr_work;
  int n;
  GO_GROUP *g;
  char *stone;

  printf ("groups_num = %d \n", w->groups_num);

  for (n=0; n < w->groups_num; n++) {
    g = &(w->groups[n]);
    stone = (g->stone==STONE_WHITE) ? "White" : "Black";
    printf ("%s group: stones=%d dame=%d \n", stone, g->ij_num, g->xy_num); 
  }

  return;
}
/*----------------------------------------------------------------------------*/

/******************************************************************************/
//                                                                             /
/******************************************************************************/


/*----------------------------------------------------------------------------*/
/* YT_MYBOARD* */
/* myboard_create (int isize, int jsize) */
/* { */
/*   int i, j; */
/*   YT_MYBOARD *myboard; */

/*   myboard = (YT_MYBOARD*) malloc (sizeof(YT_MYBOARD)); */

/*   myboard->board = (int*)malloc (isize*jsize*sizeof(int)); */

/*   for (i = 0; i < isize; i++)  */
/*   for (j = 0; j < jsize; j++)  */
/*     BOARD_PS ((myboard->board), isize, jsize, i,j) = STONE_NONE; */

/*   return (myboard); */
/* } */
/*----------------------------------------------------------------------------*/
GO_GROUP*
work_find_captured_group (GO_WORK *w, int stone)
{
  GO_GROUP *gr=NULL;
  int n;

  for (n=0; n < w->groups_num; n++) {
    gr = &(w->groups[n]);
    if (gr->xy_num==0) { // группа с нулевым дамэ
      //printf ("captured group: %d   move_stone: %d \n", g->stone, move_stone); //?????
      if (gr->stone==stone)  
      break; // нашли захваченную группу данного цвета
    }
  }

  if (n == w->groups_num) 
    return (NULL); // нет ни одной захваченной группы
  else 
    return (gr);
}
/*----------------------------------------------------------------------------*/
void   
work_add_dame_to_group (GO_WORK *w, GO_GROUP *gr, int i, int j) 
{ 
  int d;

  for (d=0; d < gr->xy_num; d++) {
    if ((gr->x[d]==i) && (gr->y[d]==j)) 
      return; // уже есть такое дамэ в группе
  }

  gr->x[gr->xy_num] = i;
  gr->y[gr->xy_num] = j;
  gr->xy_num++;

  return;
}
/*----------------------------------------------------------------------------*/
void   
work_this_is_dame (GO_WORK *w, GO_GROUP *gr, int i, int j) 
{ 
  //  #define DAME (ptr_work->goban[i][j].dame)
  int DAME = w->goban[i][j].dame;

  // добавим это дамэ к группе
  work_add_dame_to_group (w, gr, i, j); 

  //if (DAME==STONE_WHITE))

  if (DAME==gr->stone) return; // уже посчитали это даме за свое (НО ЭТОЙ ЛИ ГРУППЫ????!)
  if (DAME==STONE_CONTACT_DAME) return; // а это за общее  (НО ЭТОЙ ЛИ ГРУППЫ????!)

  if (DAME==STONE_NONE) DAME = gr->stone;
  else                  DAME = STONE_CONTACT_DAME;

  return;
}
/*----------------------------------------------------------------------------*/
void   
work_check_iteration (GO_WORK *w, GO_GROUP *gr, int i, int j) 
{ 
  // проверка на выход за границу
  if (i<0 || j<0 || i>w->isize-1 || j>w->jsize-1)
    return;

  if (WBOARD(i,j) == STONE_NONE) {
    work_this_is_dame (w, gr, i, j); 
    return;
  } 

  if (WBOARD(i,j) != gr->stone) 
    // это - камень противника, здесь делать нечего
    return;

  //----------------------------------------------
  //----------------------------------------------
  // а это значит камень нашего цвета

  if (/* ptr_work */w->goban[i][j].stone != STONE_NONE)
  return; // здесь мы уже были

  // отметим камень на схеме
  /* ptr_work */w->goban[i][j].stone = gr->stone;
  /* ptr_work */w->goban[i][j].group = gr;
  // добавим камень в группу
  gr->i[gr->ij_num] = i;
  gr->j[gr->ij_num] = j;
  gr->ij_num++;
  
  work_check_iteration (w, gr, i,  j-1);
  work_check_iteration (w, gr, i,  j+1);
  work_check_iteration (w, gr, i+1,  j);
  work_check_iteration (w, gr, i-1,  j);

  return;
}
/*----------------------------------------------------------------------------*/
void   
work_get_group (GO_WORK *w, int i, int j) 
{ 
  // описать группу для этого пункта-камня
  //GO_GROUP *gr = &(ptr_work->groups[ptr_work->groups_num]);
  GO_GROUP *gr = &(w->groups[w->groups_num]);

  gr->stone = WBOARD(i,j);
  gr->ij_num = 0;
  gr->xy_num = 0;

  work_check_iteration (w, gr, i, j);

  return;
}
/*----------------------------------------------------------------------------*/
void   
work_get_groups (GO_WORK *w, GO_BOARD *a) 
{ 
  int i, j;

  if (a)  w->aboard = a;

  for (i=0; i < w->isize; i++) 
  for (j=0; j < w->jsize; j++) {
    w->goban[i][j].dame  = STONE_NONE;
    w->goban[i][j].stone = STONE_NONE;
    w->goban[i][j].group = NULL;
  }

  w->groups_num = 0;

  for (i=0; i < w->isize; i++) 
  for (j=0; j < w->jsize; j++) {
    if (WBOARD(i,j) == STONE_NONE) 
    continue;
    if (w->goban[i][j].stone != STONE_NONE) 
    continue;// здесь мы уже были

    work_get_group (w, i, j);
    w->groups_num++; 
  }

  return;
}
/*----------------------------------------------------------------------------*/
void  
work_get_calcus (GO_WORK *w, GO_STONE stone, int *p_min_dames, int *p_num_capts) 
{ 
  GO_GROUP *gr;
  int n;

  int dames, min_dames = 1000; 
  int num_capts = 0;
  
  for (n=0; n < w->groups_num; n++) {
    gr = &(w->groups[n]);
    if (gr->stone != stone) continue;
 
    dames = gr->xy_num;
    if (dames == 0) num_capts++;

    min_dames = YMIN (min_dames, dames);
  }

  if (min_dames==1000) { // а если нет еще групп (т.е. вообще камней??!!)
    min_dames = -1;
  }

  if (p_min_dames) *p_min_dames = min_dames;
  if (p_num_capts) *p_num_capts = num_capts;

  return;
}
/*----------------------------------------------------------------------------*/
int   
work_calc_mindames (GO_WORK *w, GO_STONE stone) 
{ 
  GO_GROUP *gr;
  int n;

  int dames, min_dames = 1000; 
  
  for (n=0; n < w->groups_num; n++) {
    gr = &(w->groups[n]);
    if (gr->stone != stone) continue;
 
    dames = gr->xy_num;

    min_dames = YMIN (min_dames, dames);
  }

  if (min_dames==1000) { // а если нет еще групп (т.е. вообще камней??!!)
    min_dames=-1;
  }

  return (min_dames);
}
/*----------------------------------------------------------------------------*/
int   
work_move_mindames (GO_WORK *w, int stone, int i, int j) 
{ 
  int min_dames;
  GO_BOARD *a = w->aboard;

  // ставим камень на доску и расчитываем инфу о группах
  aboard_set_stone (w->aboard, stone, i, j);
  work_get_groups (w, NULL);

  min_dames = work_calc_mindames (w, stone);

  // убираем камень с доски и пересчитываем инфу
  aboard_del_stone (a, i, j);
  work_get_groups (w, NULL);

  return (min_dames);
}
/*----------------------------------------------------------------------------*/
int   
work_is_move_suicide (GO_WORK *w, int stone, int i, int j) 
{ 
  int min_dames;

  min_dames = work_move_mindames (w, stone, i, j); 

  if (min_dames==0) return (TRUE);
  else              return (FALSE);
}
/*----------------------------------------------------------------------------*/
int   
work_is_this_good (GO_WORK *w, int my_stone, int i, int j) 
{ 
  int min_dames;

  min_dames = work_move_mindames (w, my_stone, i, j); 

  if (min_dames<=1) return (FALSE);
  else              return (TRUE);
}
/*----------------------------------------------------------------------------*/
int   
work_random_stone (GO_WORK *w, int stone, int *i_move, int *j_move) 
{ 
  int i, j, n, nmax=30;
  int num=0;

  for (n=0; n<nmax; n++) {
    i = YRAND (0, w->isize-1);
    j = YRAND (0, w->jsize-1);
    
    if (aboard_is_move_legal(w->aboard, i, j) && !work_is_move_suicide (w, stone, i, j) ) {
      *i_move = i;
      *j_move = j;
      num++;
      break;
    }
  }

  return (num);
}
/*----------------------------------------------------------------------------*/
int
work_del_move (GO_WORK *w)
{
  GO_BOARD *a = w->aboard;
  int i, j;

  // удалить последний ход  
  if (w->moves_num==0) YERROR ("board_del_move");

  i =  (w->moves)[w->moves_num-1].i;
  j =  (w->moves)[w->moves_num-1].j;

  aboard_del_stone (a, i, j);

  w->moves_num--;  
  return (TRUE);
}
/*----------------------------------------------------------------------------*/
int
work_set_move (GO_WORK *w, int stone, int i_move, int j_move)
{
  //GO_BOARD *a = w->aboard;

  //aboard_set_stone (a, stone, i_move, j_move);

  // запомнить последний ход  
  (w->moves)[w->moves_num].i = i_move;
  (w->moves)[w->moves_num].j = j_move;
  (w->moves)[w->moves_num].move_stone = stone;

  w->moves_num++;
  
  return (TRUE);
}
/*----------------------------------------------------------------------------*/
int   
work_random_move_dame (GO_WORK *w, int stone, int *i_move, int *j_move, int dame) 
{ 
  int i, j, n, nmax=30;
  int min_dames;

  for (n=0; n<nmax; n++) {

    if (!board_random_stone (w->aboard, &i, &j))
      break;

    min_dames = work_move_mindames (w, stone, i, j);
 
    if (min_dames >= dame) {
      *i_move = i;
      *j_move = j;
      return (TRUE);
    }    
  }

  return (FALSE);
}
/*----------------------------------------------------------------------------*/
int   
work_random_move (GO_WORK *w, int stone, int *i_move, int *j_move) 
{ 

  if (work_random_move_dame (w, stone, i_move, j_move, 2))
    return (TRUE);

  if (work_random_move_dame (w, stone, i_move, j_move, 1))
    return (TRUE);

  if (work_random_move_dame (w, stone, i_move, j_move, 0)) // если нет ходов, то делать суицид !!
    return (TRUE);

  return (FALSE);
}
/*----------------------------------------------------------------------------*/
void
work_get_captures (GO_WORK *w, int is_set_captures, int *p_bcap, int *p_wcap/* , GO_STONE last_stone */)
{
  GO_STONE last_stone;

  int bcap=0, wcap=0;
  int n, dead_stone, enemy_stone, k, stone_cap/* , stone */;

  GO_GROUP *gr;
  //GO_BOARD *a = w->aboard;

  work_get_groups (w, NULL);

  // необходимо знать цвет последнего хода !!!!!! ??????
  last_stone = (w->moves)[w->moves_num-1].move_stone;

  enemy_stone = STONE_OTHER (last_stone);

  if (!(gr = work_find_captured_group (w, enemy_stone)))
    if (!(gr = work_find_captured_group (w, last_stone))) {
    *p_bcap = 0;
    *p_wcap = 0;
    return; // нет ни одной захваченной группы
  }
 
  stone_cap = gr->stone;
  // Группа этого камня - захвачена!!
 
  if (stone_cap==STONE_WHITE) {
    bcap = TRUE;
    dead_stone = STONE_WHITE_DEAD;
  } else {
    wcap = TRUE;
    dead_stone = STONE_BLACK_DEAD;
  }

  if (is_set_captures) {
    for (n=0; n < w->groups_num; n++) {
      gr = &(w->groups[n]);
      if (gr->xy_num!=0) continue;
      if (gr->stone!=stone_cap) continue;

      for (k = 0; k < gr->ij_num; k++) {
        WBOARD (gr->i[k], gr->j[k]) = dead_stone;
      }
    }
  }

  *p_bcap = bcap;
  *p_wcap = wcap;
  return;
}
/******************************************************************************/
//                                                                             /
/******************************************************************************/
