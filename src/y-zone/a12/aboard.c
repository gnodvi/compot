// -*-  mode: c    ; coding: koi8   -*- ----------------------------------------

/*******************************************************************************
 *                                                                             *
 *  Имя этого файла: aboard.c                                                  *
 *                                                                             *
  ******************************************************************************
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

#include  <stdarg.h>
/*----------------------------------------------------------------------------*/

#include "common.h"
#include "aboard.h"


char horz_arr[19] = 
{'A','B','C','D','E','F','G','H','J','K','L','M','N','O','P','Q','R','S','T'};

/*----------------------------------------------------------------------------*/
GO_MOVES*
moves_create ()
{
  GO_MOVES *mvs = malloc (sizeof (GO_MOVES));

  mvs->moves_num = 0;
  return (mvs);
}
/*----------------------------------------------------------------------------*/
void
moves_init (GO_MOVES *mvs)
{

  mvs->moves_num = 0;

  return;
}
/*----------------------------------------------------------------------------*/
void
moves_add (GO_MOVES *mvs, int i, int j, int stone)
{
  int num = mvs->moves_num;

  if (num == 100) YERROR ("moves_add");

  ((mvs->moves)[num]).i = i;
  ((mvs->moves)[num]).j = j;

  mvs->moves_num++;
  return;
}
/*----------------------------------------------------------------------------*/
GO_MOVE*
moves_get (GO_MOVES *mvs, int n)
{
  GO_MOVE *mv = &((mvs->moves)[n]);

  return (mv);
}
/*----------------------------------------------------------------------------*/
void
moves_del (GO_MOVES *mvs, int n_del)
{
  int n;

  if (n_del >= mvs->moves_num)
    YERROR ("n_del >= mvs->moves_num");

  for (n=n_del; n<mvs->moves_num; n++) {
    ((mvs->moves)[n]).i = ((mvs->moves)[n+1]).i;
    ((mvs->moves)[n]).j = ((mvs->moves)[n+1]).j;
    ((mvs->moves)[n]).move_stone = ((mvs->moves)[n+1]).move_stone;
  }

  mvs->moves_num--;
  return;
}
/*----------------------------------------------------------------------------*/
int 
moves_num (GO_MOVES *mvs)
{

  return (mvs->moves_num);

}
/*----------------------------------------------------------------------------*/

/*----------------------------------------------------------------------------*/
GO_BOARD *
aboard_begin (int ii, int jj)
{
  GO_BOARD *a = malloc (sizeof (GO_BOARD));

  a->board = calloc (ii*jj, sizeof (int));

  a->isize = ii;
  a->jsize = jj;

  return (a);
}
/*----------------------------------------------------------------------------*/
GO_BOARD *
board_copy (GO_BOARD *from)
{

  GO_BOARD *to = aboard_begin (from->isize, from->jsize);
  memcpy (to->board, from->board, from->isize*from->jsize*sizeof(int));

  return (to);
}
/*----------------------------------------------------------------------------*/
void
aboard_del_stone (GO_BOARD *a, int i, int j)
{

  BOARD (a, i, j) = STONE_NONE;

}
/*----------------------------------------------------------------------------*/
void
aboard_set_stone (GO_BOARD *a, int stone, int i_move, int j_move)
{

  if (BOARD(a, i_move, j_move) != STONE_NONE)
    fprintf (stderr, "board_set_move: %d %d stone_old=%d \n", 
             i_move, j_move, BOARD(a, i_move, j_move));

  BOARD (a, i_move, j_move) = stone;

}
/*----------------------------------------------------------------------------*/
int
aboard_is_move_legal (GO_BOARD *a, int i, int j)
{

  if (i<0 || j<0 || i>a->isize-1 || j>a->jsize-1) 
    return (FALSE);

  if (BOARD(a,i,j) == STONE_NONE)  return (TRUE);
  else                             return (FALSE);

}
/*----------------------------------------------------------------------------*/
void 
board_name_to_index (GO_BOARD *a, char *name, int *i_ptr, int *j_ptr) 
{
  int isize = a->isize;
  int jsize = a->jsize;
  char horz, vert[10];
  int  i, j;

  horz = name[0];
  strcpy (vert, name+1);

  for (j=0; j<jsize; j++)
    if (toupper(horz) == horz_arr[j]) break;
      
  i = isize - atoi (vert); 

  *i_ptr = i;
  *j_ptr = j;

  return;
}
/*----------------------------------------------------------------------------*/
char* 
board_name_from_index (GO_BOARD *a, /* int nn, */ int i, int j) 
{
  //int isize = a->isize;
  //int jsize = a->jsize;
  int nn = a->isize;

  static char name[10];
  char *name1=NULL;

  strcpy (name, "");

  if (j ==  0) name1 = "a";
  if (j ==  1) name1 = "b";
  if (j ==  2) name1 = "c";
  if (j ==  3) name1 = "d";
  if (j ==  4) name1 = "e";
  if (j ==  5) name1 = "f";
  if (j ==  6) name1 = "g";
  if (j ==  7) name1 = "h";
  if (j ==  8) name1 = "j";

  if (j ==  9) name1 = "k";
  if (j == 10) name1 = "l";
  if (j == 11) name1 = "m";
  if (j == 12) name1 = "n";
  if (j == 13) name1 = "o";
  if (j == 14) name1 = "p";
  if (j == 15) name1 = "q";
  if (j == 16) name1 = "r";
  if (j == 17) name1 = "s";
  if (j == 18) name1 = "t";

  sprintf (name, "%s%d", name1, nn-i);
  //sprintf (name, "%s%d\n", name1, nn-i);
  //fprintf (stderr, "%s", name);

  return (name);
}
/*----------------------------------------------------------------------------*/
int  
int_from_char (char c) 
{
  char str[2];

  str[0] = c;
  str[1] = '\0';
  
  return (atoi(str));
}
/*----------------------------------------------------------------------------*/
void
board_borders (YT_WIN  *win, int x0, int  y0, int ww, int hh, YT_BOOL is_plus) 
{
  int  x, y, j, n;

  // горизонтальные бортики
  for (j=x0+2, n=0; j < ww-2; j++, n++) {
    if (!is_plus && n%2) continue;
    x = j;
    win_char (win, '-', x, 0);
    win_char (win, '-', x, hh-1);
  }

  // вертикальные бортики
  for (y = y0+1; y < hh-1; y++) {
    win_char (win, '|', 0,    y);
    win_char (win, '|', ww-1, y);
  }

  if (is_plus) {
    // уголки
    win_char (win, '+', 0, 0);
    win_char (win, '+', 0, hh-1);
    win_char (win, '+', ww-1, 0);
    win_char (win, '+', ww-1, hh-1);
  }

  return;
}
/*----------------------------------------------------------------------------*/
void
board_mainreg (YT_WIN  *win, GO_BOARD *a, int x0, int  y0) 
{
  int  i, j;
  CHAR ch;
  int  isize = a->isize;
  int  jsize = a->jsize;

  // основная область доски с камнями
  for (i=0; i < isize; i++) 
  for (j=0; j < jsize; j++) {
    if      (BOARD (a,i,j) == STONE_WHITE)       ch = 'O';
    else if (BOARD (a,i,j) == STONE_BLACK)       ch = 'X';      
    else if (BOARD (a,i,j) == STONE_WHITE_FALSE) ch = 'o';
    else if (BOARD (a,i,j) == STONE_BLACK_FALSE) ch = 'x';      
    else if (BOARD (a,i,j) == STONE_WHITE_DEAD)  ch = '@';
    else if (BOARD (a,i,j) == STONE_BLACK_DEAD)  ch = '#';      
    else ch = '.';
  
    win_char (win, ch, x0 + 2*j, y0 + i);
  }

  return;
}
/*----------------------------------------------------------------------------*/
void
board_abcd (YT_WIN  *win, GO_BOARD *a) 
{
  int  x0 = 2;
  int  y0 = win->h-1;
  int  j;
  int  jsize = a->jsize;
  CHAR ch;

  for (j=0; j < jsize; j++) {
    ch = tolower (horz_arr[j]);
    win_char (win, ch, x0 + 2*j, y0);
  }

  return;
}
/*----------------------------------------------------------------------------*/
void
board_1234 (YT_WIN  *win, GO_BOARD *a) 
{
  int  x0 = win->w-1;
  int  y0 = 1;
  int  i;
  int  isize = a->isize;
  CHAR ch;

  for (i=0; i < isize; i++) {
    ch = toascii (48+ isize-i);
    win_char (win, ch, x0, y0+i);
  }

  return;
}
/*----------------------------------------------------------------------------*/
void
aboard_show (GO_BOARD *a) 
{
  YT_BOOL is_plus = 0;

  int  i;
  int  hh =   a->isize + 2;
  int  ww = 2*a->jsize - 1 + 4;
  int  hb = hh;  // высота рамки бортика 
  int  wb = ww;  // ширина рамки бортика 

  // для больших досок принудительно установить показ координат
  if (a->isize>=5 && a->jsize>=5) is_plus = 1;

  if (is_plus) {
    hh++; 
    ww+=2;
  }

  YT_WIN  *win = win_create (ww, hh);

  board_borders (win, 0, 0, wb, hb, is_plus); 
  board_mainreg (win, a, 2, 1); 
  if (is_plus) {
    board_abcd (win, a); 
    board_1234 (win, a); 
  }

  // -------------- win_draw (win, 0, 0);
  for (i=0; i < win->h; i++) 
    DBG_PRINT ("%s \n", (char*)(&(win->p[i][0])));

  if (is_plus) {
    DBG_PRINT ("\n");
  }
  // -----------------------------------

  win_delete (win);

  return;
}
/*----------------------------------------------------------------------------*/
int   
board_random_rect_stone (GO_BOARD *b, int  imin, int  jmin, int  imax, int  jmax, 
                         int *i_move, int *j_move) 
{ 
  int  i, j, n0, n;

  n = 0;
  for (i=imin; i <= imax; i++) 
  for (j=jmin; j <= jmax; j++) {
    if (BOARD(b,i,j) == STONE_NONE) 
      n++;
  }

  // посчитали количество пустых полей
  if (n==0) return (FALSE);

  n0 = YRAND (1, n); // выбрали случайное

  n = 0;
/*   for (i=0; i < b->isize; i++)  */
/*   for (j=0; j < b->jsize; j++) { */
  for (i=imin; i <= imax; i++) 
  for (j=jmin; j <= jmax; j++) {
    if (BOARD(b,i,j) == STONE_NONE) 
      n++;
    if (n0 == n) { // нашли это случайное      
      *i_move = i;
      *j_move = j;
      return (TRUE);
    }
  }

  return (FALSE);
}
/*----------------------------------------------------------------------------*/
int   
board_random_stone (GO_BOARD *b, int *i_move, int *j_move) 
{ 

  int  imin = 0;
  int  jmin = 0;
  int  imax = b->isize-1;
  int  jmax = b->isize-1;

  return (board_random_rect_stone (b, imin, jmin, imax, jmax, 
                                   i_move, j_move)); 

}
/*----------------------------------------------------------------------------*/
/* int    */
/* board_get_random_moves (GO_BOARD *b, int *i_move, int *j_move)  */
/* {  */
/*   int num; */



/*   return (num); */
/* } */
/*----------------------------------------------------------------------------*/
GO_MOVE *
xo_malloc_move (int i, int j)
{
  GO_MOVE *mv/* =NULL */;

  //if (!mv) {
  mv = malloc (sizeof (*mv));
  if (!mv) exit(EXIT_FAILURE);

  //mv->next = NULL;
    //}
  mv->i = i;
  mv->j = j;

  return (mv);
}
//------------------------------------------------------------------------------
void 
xo_show_board (GO_POSI *pos)
{

  if (pos == NULL) 
    Error ("board == NULL");

  aboard_show (pos->a);

  return;
}
/*----------------------------------------------------------------------------*/
GO_POSI *
xo_pos_create (int stone, int ii, int jj)
{
  GO_POSI *pos; 

  pos = calloc (1, sizeof (*pos));
  if (!pos)
      exit (EXIT_FAILURE);

  //pos->next   = NULL; 
  pos->a = aboard_begin (ii, jj);
  pos->stone = stone;

  return (pos);
}
/*----------------------------------------------------------------------------*/
GO_POSI *
xo_pos_copy (GO_POSI *dst, GO_POSI *src)
{
  GO_BOARD *sa = src->a;

  if (!dst) 
    dst = xo_pos_create (0, sa->isize, sa->jsize); // здесь не важен игрок, все равно закопируется

  // а если уже создано, то надо честно копировать все поля!!!
  // и аккуратно сложную вложенную структуру GO_BOARD

  //dst->next   = src->next;

  memcpy ((dst->a)->board, (src->a)->board, (sa->isize)*(sa->jsize)*sizeof (int));
  (dst->a)->isize = sa->isize;
  (dst->a)->jsize = sa->jsize;

  dst->stone = src->stone;

  return (dst);
}
/*----------------------------------------------------------------------------*/
int
stone_from_char (char ch)
{
  int stone= STONE_NONE;

  switch (ch) {
  case 'X':
    stone = STONE_BLACK;
    break;
  case 'O':
    stone = STONE_WHITE;
    break;
  case '@':
    stone = STONE_WHITE_DEAD;
    break;
  case '#':
    stone = STONE_BLACK_DEAD;
    break;
  case '.':
    stone = STONE_NONE;
    break;
/*   default: MyError ("stone"); */
/*     break; */
  }

  return (stone);
}
/******************************************************************************/
//                                                                             /
/******************************************************************************/
