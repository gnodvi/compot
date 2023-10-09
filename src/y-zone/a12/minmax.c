// -*-  mode: c    ; coding: koi8   -*- ----------------------------------------

/*******************************************************************************
 *                                                                             *
 *  Имя этого файла: mmgame.c                                                  *
 *                                                                             *
  ******************************************************************************
 */    

#include <stdio.h>
#include <stdlib.h>
#include <assert.h>
#include <string.h>

#include <math.h>
#include <time.h>

#include "common.h"
//#include "sl.h"
#include "minmax.h" 


/*----------------------------------------------------------------------------*/
void 
tr_node_txt (TR_MAIN *tr, char *node_name, int nval, 
               char *next1_name, char *next2_name)
{
  int  i;
  TR_NODE *node = &(tr->nods[tr->nums]);

  //node_set (nnew, node_name, nval,  next1_name, next2_name,
  //          NULL, NULL, NULL);
  node->name  = node_name;
  node->nval  = nval;

  node->next1_name = next1_name;
  node->next2_name = next2_name;

  for (i=0; i < MM_NEXT_MAX; i++) {
    // this_is_DEBUG;
    // здесь надо записывать реальные имена узлов из входного массива!
    node->next_name[i] = NULL;
  
    node->next_pstr[i] = NULL;
  }
  // эти значения заполнятся потом, при повторном проходе
  node->prev  = NULL;
  node->next1 = NULL;
  node->next2 = NULL;


  tr->nums++;

  return;
}
/*----------------------------------------------------------------------------*/
TR_MAIN * 
tr_begin ()
{
  TR_MAIN *t = (TR_MAIN *) malloc (sizeof(TR_MAIN));

  t->nums = 0;
  t->name = "TREE";

  return (t);
}
/*----------------------------------------------------------------------------*/
void
tr_node_to_nodes (TR_MAIN *tr, TR_NODE *from_node)
{
  TR_NODE *to_node;
  int      i;

  for (i=0; i < tr->nums; i++) { // сканируем весь список узлов дерева
    to_node = &(tr->nods[i]);    // и ищем куда направлены ветки

    if (!strcmp (from_node->next1_name, to_node->name)) {
      from_node->next1 = to_node;
      to_node->prev    = from_node;
    }

    if (!strcmp (from_node->next2_name, to_node->name)) {
      from_node->next2 = to_node;
      to_node->prev    = from_node;
    }

  }

  //if  (i == t->nums) {
  //  fprintf (stderr, "%s -> %s %s \n", from_node->name, from_node->next1_name, from_node->next2_name) ;
  //  Error ("i == t->nums");
  //}

  return;
}
/*----------------------------------------------------------------------------*/
/* TR_NODE *  */void
tr_finish (TR_MAIN *tr)
{
  int      i;
  TR_NODE *n;

  for (i=0; i < tr->nums; i++) {
    n = &(tr->nods[i]);
    //fprintf (stderr, "name= %s \n", n->name);

    tr_node_to_nodes (tr, n);
  }

  tr->cur = &(tr->nods[0]);
  //cur    = &(t->nods[0]);

  return /* (&(t->nods[0])) */;
}
//
// негамакс - везде ищем максимум (MAX), но меняя знаки  ПОДНИМАЯСЬ НА УРОВЕНЬ..
// 
/*----------------------------------------------------------------------------*/
TR_MAIN *
tr_create (TR_NODE_TXT nodes[])
{
  TR_NODE_TXT *n;
  TR_MAIN *tr = tr_begin ();

  for (n=nodes; n->node_name; n++) {
    // записываем в каждый узел дерева текстовую болванку

    tr_node_txt (tr, n->node_name, n->nval, 
                   n->next1_name, n->next2_name);
  }

  // теперь от текстовой заготовки перейти к реальной стркутуре дерева (с указателями)
  tr_finish (tr);

  return (tr);
}
/*----------------------------------------------------------------------------*/
TR_MAIN *
tr_create_new (char *nodestring[])
{
  TR_MAIN *tr = tr_begin ();

  if (!nodestring) return (NULL);

 

  return (tr);
}
/******************************************************************************/
/******************************************************************************/



/******************************************************************************/
/*----------------------------------------------------------------------------*/
MM_MAIN *
mm_create (/* long pstr, */ MM_PROC_C copy_posi,
           MM_PROC_F find_moves, MM_PROC_E evaluate,
           MM_PROC_M make_move,  MM_PROC_U undo_move,
           //int	(*end_of_game)(AB_POS *), 
           // необязательная, для отладки ..
           MM_PROC_N name_move ,  MM_PROC_P name_posi, int gamer_color/* , int maxply */
)
{
  MM_MAIN *g;

  g = malloc (sizeof *g);
  if (!g) {
    return NULL;
  }

  //g->pstr = pstr;

  //ab->end_of_game	= end_of_game;
  g->copy_posi	= copy_posi;
  g->find_moves	= find_moves;
  g->evaluate	= evaluate;
  g->make_move	= make_move;
  g->undo_move	= undo_move;

  g->name_move	= name_move;
  g->name_posi	= name_posi;

  g->numlev    = -1;
  g->posis_num =  0;
  g->gamer_color = gamer_color;

  return (g);
}
/*----------------------------------------------------------------------------*/
void 
mm_push_posi (MM_MAIN *g, long p)
{ 

  g->posis[g->posis_num] = g->copy_posi (/* g->pstr, */ p);
  (g->posis_num)++;

}
/*----------------------------------------------------------------------------*/
//MM_POSI *
long
mm_pop_posi (MM_MAIN *g)
{ 

  //return (sl_pop (&g->pos_cache));
  (g->posis_num)--;
  return (g->posis[g->posis_num]);

}
/*----------------------------------------------------------------------------*/
/* MM_POSI * */
/* mm_user_posi (MM_MAIN *g, long user_posi) */
/* {  */


/*   return (sl_pop (&g->pos_cache)); */
/* } */
/*----------------------------------------------------------------------------*/
YT_BOOL
find_best_old (int bestmove, int numlev, int eval, int best)
{

  if (!(numlev%2)) { if ((eval>best) || ((eval==best) && (!bestmove) && (YRAND(0,100)<50))) 
    return (TRUE); } 
  else             { if ((eval<best) || ((eval==best) && (!bestmove) && (YRAND(0,100)<50))) 
    return (TRUE); }  

  return (FALSE);   
}

/*----------------------------------------------------------------------------*/
YT_BOOL
find_best (int bestmove, int numlev, int eval, int best)
{
  // немного сложновато записано, но суть проста:
  // если равенство в первый раз, т.е. взять этот ход (даже если он - отвратительный :-)

  if (!(numlev%2)) { if ((eval>best) || ((eval==best) && ((!bestmove) || (YRAND(0,100)<50)))) 
    return (TRUE); } 
  else             { if ((eval<best) || ((eval==best) && ((!bestmove) || (YRAND(0,100)<50)))) 
    return (TRUE); }  

  return (FALSE);   
}
/*----------------------------------------------------------------------------*/
int 
mm_minimax (MM_MAIN *g, long old_posi, int maxlev, long *p_bestmove, long pstr)
{ 
  //int   gamer_color = g->gamer_color;
  int   i;
  int   best, eval;
  long  bestmove = 0;

  long moves [MM_MOVES_MAX];   // массив (указателей) возможных ходов
  int  num_moves; 


  DBG_PROC_BEG ("mm_minimax", TRUE);
  g->numlev++;

  // юзер знает текущцю позицию в дереве !(?);  это плохо (надо делать стек)
  // но пока это нужно только для печати
  // а потом это будет нужно для повторного использования прохода по дереву
    
  num_moves = g->find_moves (/* g-> */pstr, old_posi, moves);  // юзер генерирует список ходов
  eval      = g->evaluate (pstr, old_posi/* , g->numlev, g->gamer_color */); // оценивает позицию

  DBG_PRINT ("numlev   = %d (%d) \n", g->numlev, maxlev);
  DBG_PRINT ("num_moves= %d \n", num_moves);
  //DBG_PRINT ("evaluate = %d \n", eval);

  if ( //-------- предварительная оценка: нужно ли идти дальше по дереву ? ------
     (g->numlev == maxlev) ||  // достигли максималного уровня
     (num_moves == 0)      ||  // больше нет ходов  
      //(abs(eval) >= MM_MAX_EVAL)  // это признак окончания игры         
     (eval >= MM_MAX_EVAL) ||        
     (eval <= MM_MIN_EVAL)        
     ) 
  {  
    best  = eval;
    //DBG_PRINT ("end of tree \n");
    goto end;           // возвращаем оценку
  } //----------------------------------------------------------------------

  if (!(g->numlev%2)) best =  MM_MIN_EVAL-1000; // на уровнях 0, 2, 4.. ищем максимум
  else                best =  MM_MAX_EVAL+1000; // а на четных (после ходов соперника) - минимум

  //mm_push_posi (g, posi); // запомнили текущую позицию (в стек)  перед тем как делать ходы

  for (i = 0; i < num_moves; i++) { //---------------------------------------
    // к сожалению, сначала вызывается функция...(лишняя работа в рабочем режиме)
    DBG_PRINT ("move: %s \n", g->name_move (/* g-> *//* pstr, */ moves[i], pstr)); 

    //long old_posi = g->make_move (g->pstr, moves[i]);  // вносит изменения в позицию;
    long new_posi = g->make_move (/* g-> */pstr, old_posi, moves[i]);  // вносит изменения в позицию;
    if (g->name_posi) g->name_posi (/* g-> */pstr, new_posi);

    //eval = mm_minimax (g, posi, maxlev, NULL);   // рекурсивно вызывает себя,    
    eval = mm_minimax (g, new_posi, maxlev, NULL, pstr);   // рекурсивно вызывает себя,    
    DBG_PRINT ("minimax= % d \n", eval); 

    // запоминает лучшую оценку
    //if (!(g->numlev%2)) { if (eval >= best) {best = eval; bestmove = moves[i];} } 
    //else                { if (eval <= best) {best = eval; bestmove = moves[i];} }  

    if (find_best (bestmove, g->numlev, eval, best)) {best = eval; bestmove = moves[i];}
    // но тогда можно остаться вообще без хода (даже плохонького)!!

    //g->undo_move (g->pstr, old_posi);         // восстанавливает исходную позицию
    // а нам зачем восстанавливать исходную? очистить использованную - можно..
  } //---------------------------------------------------------------------

  //posi = mm_pop_posi (g); // вспомнили (из стека) позицию до этого хода
  end: 

  if (!(g->numlev%2))  
    DBG_PRINT ("BestMax= % d  Move= %s \n", best, g->name_move (/* g-> *//* pstr, */ bestmove, pstr));
  else                 
    DBG_PRINT ("BestMin= % d  Move= %s \n", best, g->name_move (/* g-> *//* pstr, */ bestmove, pstr));     
                

  g->numlev--;
  DBG_PROC_END ();

  if (p_bestmove) *p_bestmove = bestmove;
  //else ??????????

  return (best);
}
/*----------------------------------------------------------------------------*/
