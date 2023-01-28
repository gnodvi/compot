// -*-  mode: c    ; coding: koi8   -*- ----------------------------------------

/*******************************************************************************
 *                                                                             *
 *  Имя этого файла: mmgame.h                                                  *
 *                                                                             *
  ******************************************************************************
 */   

#ifndef MMGAME_H
#define MMGAME_H 

#include <limits.h>	/* for INT_MAX */

//******************************************************************************

#ifdef __cplusplus	/* let C++ coders use this library */
extern "C" {
#endif
//******************************************************************************

#define MM_MAX_EVAL   100
#define MM_MIN_EVAL  -100

#define NO            101
#define MM_MOVES_MAX  25

//******************************************************************************

typedef unsigned long MM_VPTR;

typedef struct {
  void  *next;
  void  *data;
} MM_MOVE;

typedef struct {
  void  *next;
  void  *data;
} MM_POSI;


/*----------------------------------------------------------------------------*/
typedef  long  (* MM_PROC_C) (/* long pstr, */ long posi);
typedef  int   (* MM_PROC_F) (long pstr, long posi, long *p);  // Find moves                            
typedef  int   (* MM_PROC_E) (long user, long posi/* , int numlev, int gamer_color */); // Evaluate position
typedef  long  (* MM_PROC_M) (long pstr, long posi, long move);
typedef  void  (* MM_PROC_U) (long pstr, long old_posi);

typedef  char* (* MM_PROC_N) (/* long pstr, */ long p_move, long pstr_new);
typedef  char* (* MM_PROC_P) (long pstr, long posi);

/*----------------------------------------------------------------------------*/
typedef struct {
  //long        pstr; 
  int         gamer_color;

  MM_PROC_C   copy_posi;
  MM_PROC_F   find_moves;
  MM_PROC_E   evaluate;
  MM_PROC_M   make_move;
  MM_PROC_U   undo_move;

  MM_PROC_N   name_move;
  MM_PROC_P   name_posi;

  int  numlev;
  long posis[100];
  int  posis_num;

} MM_MAIN;
/*----------------------------------------------------------------------------*/



MM_MAIN* mm_create (/* long pstr,  */
                    MM_PROC_C copy_posi, 
                    MM_PROC_F find_moves, MM_PROC_E evaluate,
                    MM_PROC_M make_move,  MM_PROC_U undo_move,
                    MM_PROC_N name_move,  MM_PROC_P name_posi, int gamer_color/* , int maxply */);

int      mm_minimax (MM_MAIN *g, long posi, int maxlev, long *p_bestmove, long param);



/******************************************************************************/
#define MM_NEXT_MAX 50

typedef struct {
  char  *node_name; 
  int    nval; 
  char  *next1_name; 
  char  *next2_name;
} TR_NODE_TXT;

typedef struct {
  char  *name;
  int    nval;
  char  *next1_name, *next2_name;
  void  *next1,      *next2;

  char  *next_name[MM_NEXT_MAX];
  void  *next_pstr[MM_NEXT_MAX];
  void  *prev;
} TR_NODE;

typedef struct {
  TR_NODE *node;
} TR_MOVE;

typedef struct {
  char    *name;
  TR_NODE  nods[30];
  int      nums;
  TR_NODE  *cur;
} TR_MAIN;

/*----------------------------------------------------------------------------*/

TR_MAIN  *tr_create (TR_NODE_TXT nodes[]);
TR_MAIN  *tr_create_new (char *nodestring[]);


//******************************************************************************
#ifdef __cplusplus
}
#endif
//******************************************************************************

#endif /* MMGAME_H */
/*----------------------------------------------------------------------------*/
