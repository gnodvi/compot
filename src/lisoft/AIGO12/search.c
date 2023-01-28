// -*-  mode: c    ; coding: koi8   -*- ----------------------------------------

/*******************************************************************************
 *                                                                             *
 *  Имя этого файла: search.c                                                  *
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
#include  <assert.h>

#include  "common.h"
#include  "aboard.h"
#include  "gowork.h"

#include  "minmax.h" 

#include  "search.h"
//#include  "myeuler.h" 
//#include  "ggtl.h"

/******************************************************************************/


//typedef struct {
//  TR_NODE *node;
//} SE_POSI;


typedef struct {
  TR_MAIN *tree; // тестовое дерево
  TR_NODE *node; // текущая позиция
} SE_MAIN;



/*----------------------------------------------------------------------------*/
long  
se_copy_posi (/* long pstr, */ long posi)
{ 
  TR_NODE *old_posi = (TR_NODE *) posi;

  TR_NODE *new_posi = old_posi;
  // в нашем простом случае позиция описывается только указателем, т.е.
  // не надо создавать место в памяти и реально копировать структуру

  return ((long)new_posi); 
}
/*----------------------------------------------------------------------------*/
int 
se_evaluate (long user, long posi/* , int numlev, int gamer_color */)
{ 
  //TR_MAIN *t = (TR_MAIN*) user; // главная структура юзера
  TR_NODE *n = (TR_NODE *) posi;

  // нужно знать текущую позицию - это плохо!
  //int   eval = (t->cur)->nval;
  int   eval = n->nval;
 
  // если значения нет, то можно вернуть номер уровня
  //if (eval == NO) eval = numlev; 
  if (eval == NO) eval = 0; 

  return (eval);
}
/******************************************************************************/
/*----------------------------------------------------------------------------*/
int  
se_find_moves (long pstr, long posi, long *p_moves)
{ 
  //TR_MAIN *t = (TR_MAIN*) pstr;
  //TR_NODE *cur = t->cur;
  TR_NODE *cur = (TR_NODE *) posi;

  TR_MOVE *move /* = malloc (sizeof (TR_MOVE)) */;
  int num=0;  // не с нуля, а с некоторого уровня!!

  if (cur->next1) {
    move = malloc (sizeof (TR_MOVE)); 
    move->node=cur->next1;  
    (p_moves[num++]) = (long) move; 
  }
  //if ((t->cur)->next2) {
  if (cur->next2) {
    move = malloc (sizeof (TR_MOVE)); 
    move->node=cur->next2;  
    (p_moves[num++]) = (long) move; 
  }

  return (num);
}
/*----------------------------------------------------------------------------*/
long  
se_make_move (long pstr, long old_posi, long move)
{ 
  //TR_MAIN *t = (TR_MAIN*) pstr;
  TR_MOVE *m = (TR_MOVE*) move;

  //t->cur = m->node;  // сделали ход (в дереве) - это лишнее!
  // а старая позиция в данном случае и не нужна!

  return ((long)(/* t->cur */m->node));  // вернули указатель на новую позицию
}
/*----------------------------------------------------------------------------*/
void  
se_undo_move (long pstr, long old_posi)
{ 
  //TR_MAIN *t = (TR_MAIN*) pstr;

  //TR_NODE *old_cur = (TR_NODE *) old_posi;

  // вернулись к запомненной старой позиции
  // используется "программный стек вызова функций"
  //cur = old_cur;
  //t->cur = old_cur;

  return;
}
/*----------------------------------------------------------------------------*/
char* 
se_name_move (/* long pstr, */ long move, long pstr_new)
{ 
  TR_MAIN *tr = (TR_MAIN *) pstr_new; 
  
  static char buffer[20];
  TR_MOVE *m;

  if (!move) return ("");

  m = (TR_MOVE*) move;

  //sprintf (buffer, "to_%s", (m->node)->name);
  sprintf (buffer, "%s to_%s", tr->name, (m->node)->name);

  return (buffer);
}
/*----------------------------------------------------------------------------*/
char* 
se_name_posi (long pstr, long posi)
{ 
  static char buffer[20];
  TR_NODE *n;

  if (!posi) return ("");

  n = (TR_NODE*) posi;

  //sprintf (buffer, "posi: %s", n->name);
  DBG_PRINT ("posi: %s  \n", n->name);

  return (buffer);
}
/******************************************************************************/
/*----------------------------------------------------------------------------*/
void 
se_test_do (TR_NODE_TXT nodes[], int true_find, char *nodestring[]) 
{
  int   maxply = 10;
  int   calc_find;
  long  bestmove;

  TR_MAIN *tr = tr_create (nodes);
  //TR_MAIN *se_t = tr_create_new (nodestring);
  //SE_POSI posi0 = {tr->cur}; // будем искать лучший ход для начальной позиции
  TR_NODE *n0 = tr->cur; // будем искать лучший ход для начальной позиции

  MM_MAIN *mm = mm_create (NULL, se_find_moves, 
                           se_evaluate, se_make_move, NULL,
                           se_name_move, se_name_posi, 0);

  calc_find = mm_minimax (mm, (long)(n0), /* 10 */maxply, &bestmove, (long)(tr));

  if (calc_find==true_find) {
    printf (".......... OK \n");
  } else {
    printf ("ERROR: se_test_do: TRUE= %d  CALC= %d  BESTMOVE= %s \n", true_find, calc_find,
             se_name_move (/* (long)tr, */ bestmove, (long)tr));
  }

  return;
}
/*----------------------------------------------------------------------------*/
void 
se_search_tests () 
{

/******************************************************************************/
//                    _________A__________                 
//                    |                  |
//               _____B_____       ______C_____            
//               |         |       |          |
//              D=7       E=6     F=10        G=9          
//                                             ^
/******************************************************************************/
/******************************************************************************/
//     +  -            
/******************************************************************************/
  char *nodestring [] = {
    " A          ",              
    "   B        ",      
    "     D=7    ",   
    "     E=6    ",        
    "   C        ",     
    "     F=10   ",     
    "     G=9    ", 
    NULL
  };

  TR_NODE_TXT nodes_1[] = {
    {"A", NO,  "B", "C"}, 
    {"B", NO,  "D", "E"}, 
    {"D",  7,   "",  ""}, 
    {"E",  6,   "",  ""}, 
    {"C", NO,  "F", "G"}, 
    {"F",  10,   "", ""}, 
    {"G",  9,   "",  ""}, 
    {NULL, 0,NULL, NULL},
  };

/******************************************************************************/
//                    _________A__________                MAX  (numlev=0) 
//                    |                  |
//               _____B_____       ______C______          MIN  (numlev=1)        
//               |         |       |           | 
//              D=7       E=6     F=8     _____G_____     MAX  (numlev=2)   
//                                        |         |
//                                       I=12      J=9                    
//                         ^       ^
/******************************************************************************/
  TR_NODE_TXT nodes_2[] = {
    {"A", NO,  "B", "C"},
    {"B", NO,  "D", "E"},
    {"C", NO,  "F", "G"},
    
    {"D",  7,   "",  ""},
    {"E",  6,   "",  ""},
    {"F",  8,   "",  ""},
    
    //{"G", /* NO */ -MM_MAX_EVAL,  "I", "J"},
    {"G", MM_MIN_EVAL,  "I", "J"},
    {"I", 12,   "",  ""},
    {"J",  9,   "",  ""},
    {NULL, 0,NULL, NULL},
  };


  se_test_do (nodes_1, 9, nodestring); 
  se_test_do (nodes_2, /* 8 */6, NULL); 

  return;

}
////////////////////////////////////////////////////////////////////////////////
//
/*-------------------------------------main----------------------------------*/
int 
main (int argc, char **argv) 
{ 
  //dbg_set_maxlevel (1);
  
  SKIP_LINE;
  se_search_tests (); 
  SKIP_LINE;

  return (1);  
}
/******************************************************************************/
//                                                                             /
/******************************************************************************/

