// -*-  mode: c    ; coding: koi8   -*- ----------------------------------------

/*******************************************************************************
 *                                                                             *
 *  ��� ����� �����: goga.c                                                    *
 *                                                                             *
  ******************************************************************************
 */   

 
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


/*----------------------------------------------------------------------------*/
void   
work_get_contact_dames (GO_WORK *w, GO_MOVES *mvs) 
{ 
  int i, j, num=0;

  for (i = 0; i < w->isize; i++) 
  for (j = 0; j < w->jsize; j++) {
    if (w->goban[i][j].dame != STONE_CONTACT_DAME) 
      continue;

    (mvs->moves)[num].i = i;
    (mvs->moves)[num].j = j;

    num++;
  }

  mvs->moves_num = num;
  return;
}
/*----------------------------------------------------------------------------*/
int   
work_calc_mindames_diff (GO_WORK *w, GO_STONE stone) 
{ 
  int  my, he, diff;

  // ��������� ����� ������� � ����������
  my  = work_calc_mindames (w, stone);
  he  = work_calc_mindames (w, STONE_OTHER(stone));

  //if (my == 0 ) diff = VALUE_MIN; //???!
  //else          diff = my - he;

  diff = my - he;

  return (diff);
}
/*----------------------------------------------------------------------------*/
void   
weakes_calc (GO_WORK *w, GO_STONE stone, GO_MOVES *mvs) 
{ 
  int  i, j, n, mindames;

  for (n=0; n < mvs->moves_num; n++) {

    // � ���� �� ��� ��� ���?? (������ ����� ���������� ����� 'simple'!)
    i = (mvs->moves)[n].i;
    j = (mvs->moves)[n].j;

    // ������� ��� 
    WBOARD (i, j) = stone;
    work_get_groups (w, NULL);

    mindames = work_calc_mindames_diff (w, stone);

    (mvs->moves)[n].move_stone = mindames;

    // ���������� ��� �����
    WBOARD(i, j) = STONE_NONE;
    work_get_groups (w, NULL);
  }

  return;
}
/*----------------------------------------------------------------------------*/
int   
play_by_weakes_diff (GO_WORK *w, int *i_move, int *j_move, GO_STONE stone) 
{   
  GO_MOVES cdames;

  int n, n_best=-1;
  int diff, max_diff;

  // ������� ��� ���������� ����
  work_get_contact_dames (w, &cdames);

  // ������� ���� ���� � ��������� "������� �������" = my - he
  weakes_calc (w, stone, &cdames);

  // �������� ���, ��� � ���� ������ `������� �������
  // ------------------------------------------------
  max_diff = /* VALUE_MIN */-1000;

  for (n=0; n < cdames.moves_num; n++) {
    diff = (cdames.moves)[n].move_stone;

    if (diff > max_diff) { 
      max_diff = diff;
      n_best   = n;
    }
  }
  if (n_best == -1) // ������ �� ���� ���������� ����
    return (FALSE); 

  if (i_move) *i_move = (cdames.moves)[n_best].i;
  if (j_move) *j_move = (cdames.moves)[n_best].j;
  // ------------------------------------------------

  return (TRUE);
}
/*----------------------------------------------------------------------------*/
int   
find_try_captures (GO_WORK *w, GO_STONE stone, GO_MOVES *mvs) 
{ 
  // ��������� ��������� ������ ����� ������!
  int  n, num_find;
  GO_GROUP *g;

  num_find = 0;

  for (n=0; n < w->groups_num; n++) {
    g = &(w->groups[n]);
    if (stone==g->stone) continue; // ���� ������ ��� �� ����������

    if (g->xy_num==1) { // ����� ����� ������ � ����� ����
      moves_add (mvs, g->x[0], g->y[0], stone);
      num_find++;
    }
  }

  return (num_find);
}
/*----------------------------------------------------------------------------*/
int    
find_try_defends (GO_WORK *w, GO_STONE stone, GO_MOVES *mvs) 
{ 
  // ��������� �������� ���� ������ ������!
  int i=0, j=0, n, num_find;
  GO_GROUP *g;

  num_find = 0;

  for (n=0; n < w->groups_num; n++) {
    g = &(w->groups[n]);
    if (stone != g->stone) continue; // ����� �� �������� 

    if (g->xy_num==1) { // ����� ������ � ����� ����
      i = g->x[0];
      j = g->y[0];
      if (!work_is_move_suicide (w, stone, i, j)) {
        // � ��� ���� �� ����� ���������
        moves_add (mvs, i, j, stone);
        num_find++;
        break; // ���� ����������� ����� ��������� �����!
      }
    }

  }
  if (num_find==0)
    return (FALSE);

  // ��� ��� �������� ���� ������ �����, � ������ � ��������� �������� !
  // ���, ����������� ����� �������� �� ������, ����� ���������!
 
  if (!work_is_this_good (w, stone, i, j))
     return (FALSE);

  return (TRUE);
}
//*****************************************************************************/
/*----------------------------------------------------------------------------*/
int 
find_moves_caps (GO_WORK *w, GO_STONE stone,  GO_BOARD *t, long *p_moves, int num)
{ 

  GO_MOVES *mvs = moves_create ();
  moves_init (mvs);

  int  my_num = find_try_captures (w, stone, mvs); 
  int  n, i, j;

  for (n=0; n < my_num; n++) {
    i = ((mvs->moves)[n]).i;
    j = ((mvs->moves)[n]).j;

    BOARD (t, i, j) = STONE_BLACK;
    (p_moves[num++]) = (long) xo_malloc_move (i, j); 
  }

  return (num);
}
/*----------------------------------------------------------------------------*/
int 
find_moves_defs (GO_WORK *w, GO_STONE stone,  GO_BOARD *t, long *p_moves, int num)
{ 

  GO_MOVES *mvs = moves_create ();
  moves_init (mvs);

  int  my_num = find_try_defends (w, stone, mvs); 
  int  n, i, j;

  for (n=0; n < my_num; n++) {
    i = ((mvs->moves)[n]).i;
    j = ((mvs->moves)[n]).j;

    BOARD (t, i, j) = STONE_BLACK;
    (p_moves[num++]) = (long) xo_malloc_move (i, j); 
  }

  return (num);
}
/*----------------------------------------------------------------------------*/
int 
find_moves_random (GO_BOARD *t, int numfind, long *p_moves, int num)
{ 
  int  n, i, j;

  for (n=0; n < numfind; n++) {
    if (!board_random_stone (t, &i, &j) )
      break; // ��� ���� ���������, �.�. - �������!

    BOARD (t, i, j) = STONE_BLACK;
    (p_moves[num++]) = (long) xo_malloc_move (i, j); 
  }

  return (num);
} 
/*----------------------------------------------------------------------------*/
int   
find_moves_cont (GO_WORK *w,  GO_BOARD *t, long *p_moves, int num) 
{   
  GO_MOVES cdames;
  int  n, i, j;

  // ������� ��� ���������� ����
  work_get_contact_dames (w, &cdames);

  for (n=0; n < cdames.moves_num; n++) {
    i = (cdames.moves)[n].i;
    j = (cdames.moves)[n].j;

    BOARD (t, i, j) = STONE_BLACK;
    (p_moves[num++]) = (long) xo_malloc_move (i, j); 
  }

  return (num);
}
/*----------------------------------------------------------------------------*/
int 
find_moves_all (GO_BOARD *t, long *p_moves, int num)
{ 
  int  i, j;

  for (i=0; i < t->isize; i++) 
  for (j=0; j < t->jsize; j++) {
    if (BOARD (t, i, j) != STONE_NONE) continue;

    (p_moves[num++]) = (long) xo_malloc_move (i, j);  
    // ����� ���� ��� ��� ����������� !!!!!
    // �.�. �������� �������  "aigo_freemoves"
  }

  return (num);
} 
/*----------------------------------------------------------------------------*/
int  
aigo_findmoves (long pstr, long posi, long *p_moves)
{  
  GO_GAMER *gamer = (GO_GAMER*) pstr;
  GO_POSI    *pos = (GO_POSI *) posi;
  GO_BOARD     *a = pos->a;

  int num = 0; 

  if (0) { // ������� �� ����� ������������ :-( ����� ������ ������ ������
    GO_WORK  *aigo_work = gamer->work;
    work_get_groups (aigo_work, a);  

    int       num_add;
    GO_BOARD *tmp = board_copy (a);

    num = find_moves_defs (aigo_work, pos->stone, tmp, p_moves, num);
    num = find_moves_caps (aigo_work, pos->stone, tmp, p_moves, num);
    num = find_moves_cont (aigo_work,  tmp, p_moves, num);

    num_add = 15 - num;
    if (num_add < 0) num_add = 0;
    num = find_moves_random (tmp, num_add, p_moves, num);
    //num = find_moves_all (tmp, p_moves, num); // ������� ��������� ��������� ����

  } else { //--------------------------------

    num = find_moves_all (a, p_moves, num); 
  }

  return (num);
}
//*****************************************************************************/

/*----------------------------------------------------------------------------*/
int aigo_evaluate (long pstr, long posi)
{
  GO_GAMER *gamer = (GO_GAMER*) pstr;
  GO_WORK  *aigo_work = gamer->work;

  GO_POSI *pos = (GO_POSI *) posi;
  GO_STONE me   = gamer->color;
  GO_STONE he   = 3 - me;
  GO_STONE last = 3 - pos->stone;

  int MAX_SCORE = MM_MAX_EVAL;

  int min_score = -MAX_SCORE;
  int max_score =  MAX_SCORE;
  int s, he_dames, me_dames, he_capts=0, me_capts=0;

  work_get_groups (aigo_work, pos->a);  

  work_get_calcus (aigo_work, me, &me_dames, /* NULL */ &me_capts); 
  work_get_calcus (aigo_work, he, &he_dames, /* NULL */ &he_capts); 

  // ����� ��������� � �����������!
  // work_get_captures (aigo_work, TRUE, &b_cap, &w_cap);

  if      (last==me && he_dames==0) s = max_score;   // ����� �������,  �  ��� ����
  else if (last==me && me_dames==0) s = min_score-1; // � ��� ���� ���� (������-�����)

  else if (last==he && me_dames==0) s = min_score;   // ����� �������, �� ���� ����
  else if (last==he && he_dames==0) s = max_score+1; // �� ��� ���� ���� (������-�����)

  else {
    s = me_dames - he_dames;
  }

  return (s);
}
/******************************************************************************/

/******************************************************************************/
