; -*-   mode: lisp ; coding: koi8   -*- ----------------------------------------

;-------------------------------------------------------------------------------
;===============================================================================

(defpackage "A-CTAB" (:use "CL" "CL-USER" )
                     (:export :Y_BEG :YTODO :SORT_MIN_MAX :SORT_3 :bottop_create :bot_make
                              :bottop_add_player :bottop_init :Bdata 
                              :DAT :SUM :INT1 :INT2 :INT3
                              :bottop_prog_data 
                              :YPROG :LONG1 :LONG2 :LONG3
                              :bottop_print_sort_results
                              :NUM_PLAYERS :TT :BOT  :PLAYER_NAME :SORT_MAX_MIN :SORT_0
                              :bottop_sort_results_old :bottop_print_results
                              ) 
                     (:import-from :cl-user :FALSE :TRUE :NUL :srandom_set)
                     )
;#+SBCL
;(defun srandom_set (seed)

(in-package :a-ctab)

;/******************************************************************************/

;enum keywords_1 {
;  YINIT, YFREE, YCALC, YTRUE,  

;  YGINT, YRINT, YQINT, 

;  Y_BEG, YTODO, 
;  Y_PEREBOR, YGSLSPUSK, 
;  Y_GENALGO, 
;};

(defconstant Y_BEG 7)
(defconstant YTODO 8)

;/******************************************************************************/
;//
;//   Простые  БОТЫ     БОТЫ     БОТЫ     БОТЫ     БОТЫ     БОТЫ     
;//            БОТЫ     БОТЫ     БОТЫ     БОТЫ     БОТЫ     БОТЫ     
;//
;/******************************************************************************/

;typedef struct {
(defclass YT_BOT () (
;  //Bprog  parent;
;  //----------------------------------

;  YT_PROG prog;               // основная счетная прога (бот)
;  long    long1, long2, long3 /* , long4 */;
;  double  d1;

  (yprog :accessor YPROG)
  (long1 :accessor LONG1)
  (long2 :accessor LONG2)
  (long3 :accessor LONG3)
  (d1    :accessor D1)

))

;YT_BOOL BOTPRINT = FALSE;


;/*----------------------------------------------------------------------------*/
;YT_BOT *
;bot_create () 
;{
;  YT_BOT *bot;
;  bot = (YT_BOT*) malloc (sizeof (YT_BOT));

;  return (bot);
;}
;/*----------------------------------------------------------------------------*/
;void 
;bot_init (YT_BOT *bot, /* char *name, */ YT_PROG prog, 
;          long long1, long long2, long long3, /* long long4, */ double d1)
;/*----------------------------------------------------------------------------*/
(defun bot_init (bot yprog long1 long2 long3 d1)

;  //Bprog *bp = (Bprog*)bot;
;  //b_prog_init (bp, name);
;  //---------------------------------

  (setf (YPROG bot) yprog) ;  bot->prog  = prog; // основная программа-бот
  (setf (LONG1 bot) long1) ;  bot->long1 = long1;
  (setf (LONG2 bot) long2) ;  bot->long2 = long2;
  (setf (LONG3 bot) long3) ;  bot->long3 = long3;

;  //bot->long4 = long4;

  (setf (D1 bot) d1) ;  bot->d1 = d1;

)
;/*----------------------------------------------------------------------------*/
;YT_BOT *
;bot_make (YT_PROG prog,  long long1, long long2, long long3, 
;          /* long long4, */ double d1) 
;/*----------------------------------------------------------------------------*/
(defun bot_make (yprog  long1 long2 long3 d1) 

(let (
;  YT_BOT *bot = bot_create ();
  (bot (make-instance 'YT_BOT))
  )

  (bot_init bot yprog long1 long2 long3 d1)

  bot
))
;===============================================================================



;===============================================================================
; *                                                                            *
; *  Имя этого файла: e_tabs.c                                                 *
; *                                                                            *
;===============================================================================
                                                                             
;#include "a_comm.h"
;#include "e_tabs.h"
 
;===============================================================================

(defclass Bdata () (
;  char   name[NAMELENG+1];   // описательное (наглядное) имя 
  (name :accessor BDATA_NAME)  

;  //void  (*data_begin)  (void *m, long, long);
;  //void  (*print_name)  (void *m); 
;  //void  (*check_print) (void *m); 
))

(defconstant NAMELENG  18)

;  //typedef struct {
;  //char   name[NAMELENG+1];   // описательное (наглядное) имя 

;  //void  (*prog_begin) (void *p, void *d);
;  //void  (*print_name) (void *p); 
;  //void  (*prog_todo)  (void *p, void *d);
;  //} Bprog;

;// -------------------------------------------------------------------------
;// это некий стандартный бот, используется в  MIPROG и BOTTUR 
;// однако !! не совсем стандартный, а уже потомок Bprog !!


(defclass YT_PLAYER () (
;  //char *name;
;  char   name[NAMELENG+1];   // описательное (наглядное) имя 
;  void *bot; 

  (name :accessor PLAYER_NAME)
  (bot  :accessor BOT)

;  // это относится к результатам (а точнее к краткому резюме в контексте соревнования)
;  int    status;
;  double sum; 
;  int    int1, int2, int3;

  (status :accessor STATUS)
  (sum    :accessor SUM)
  (int1   :accessor INT1)
  (int2   :accessor INT2)
  (int3   :accessor INT3)

))


;/*---------------------------*/
(defconstant SORT_0  0)
(defconstant SORT_1  1)
(defconstant SORT_2  2)
(defconstant SORT_3  3)

(defconstant SORT_MIN_MAX  10)
(defconstant SORT_MAX_MIN  11)

;typedef struct {
;  char   name[NAMELENG+1];   // описательное (наглядное) имя 

;  //void  (*prog_begin) (void *p, void *d);
;  //void  (*print_name) (void *p); 
;  //void  (*prog_todo)  (void *p, void *d);
;} Btop;

(defclass Y_BOTTOP () (
;  Btop  parent;
  (name :accessor BOTTOP_NAME)
;  //----------------------------------

;  YT_PLAYER   *t;     // описание игроков c табличками результатов
  (tt :accessor TT)

;  YT_PLAYER   *s;     // таблица для сортированных результатов
  (ss :accessor SS)

;  int       max_players, num_players;
  (max_players :accessor MAX_PLAYERS)
  (num_players :accessor NUM_PLAYERS)

;  YT_SET_RESULT         set_result;
;  void  (*calc_data) (void *bottop, void *prog); 
  (set_result  :accessor SET_RESULT)
  (calc_data   :accessor CALC_DATA)

;  YT_PRINT_SORT_RESULTS print_sort_results;
;  void  (*prog_print_name) (void *p);
  (print_sort_results :accessor PRINT_SORT_RESULTS)
  (prog_print_name    :accessor PROG_PRINT_NAME)

;  //----------------------------------

;  void  (*data_begin)  (void *m, long, long);
;  void  (*prog_begin) (void *p, void *d);
  (data_begin :accessor DATA_BEGIN)
  (prog_begin :accessor PROG_BEGIN)

;  void  (*data_print_name)  (void *m); 
;  void  (*data_check_print) (void *m); 
  (data_print_name  :accessor DATA_PRINT_NAME)
  (data_check_print :accessor DATA_CHECK_PRINT)
  
;  void  (*prog_todo) (void *p, void *d);
  (prog_todo :accessor PROG_TODO)

;  void   **m;   // данные пока обобщенные (потом надо выводить в потомках)
;  int    max_datas, num_datas;
  (m         :accessor M)
  (max_datas :accessor MAX_DATAS)
  (num_datas :accessor NUM_DATAS)

;  //-------------------------------------------

;  void      *dat;
  (dat :accessor DAT)
))

;#define IGROK(n) (&((top->t)[n]))
;-------------------------------------------------------------------------------
(defun IGROK_func (n top)

  (nth n (TT top))
)
;-------------------------------------------------------------------------------

(defmacro IGROK (n) (list 'nth n (list 'TT 'top)))

;===============================================================================
;
;===============================================================================

;-------------------------------------------------------------------------------
;void 
;b_data_init (Bdata *self, char *name/* , */ 
;             //void  (*data_begin)  (void *, long, long),
;             //void  (*print_name)  (void *),
;             //void  (*check_print) (void *)
;             ) 
;{

;  b_data_set_name (self, name);

;  //self->data_begin  = data_begin;
;  //self->print_name  = print_name;
;  //self->check_print = check_print;

;  return;
;}
;-------------------------------------------------------------------------------
;void
;b_data_set_name (Bdata *self, char *name)
;{

;  strcpy (self->name, name);

;  return;
;}
;===============================================================================


;-------------------------------------------------------------------------------
;/* void  */
;/* b_prog_init (Bprog *self, char *name) */
;/* { */

;/*   return; */
;/* } */
;-------------------------------------------------------------------------------
;/* void */
;/* b_prog_set_name (Bprog *self, char *name) */
;/* { */


;/*   return; */
;/* } */
;-------------------------------------------------------------------------------
;/* char* */
;/* b_prog_get_name (Bprog *self) */
;/* { */

;/*   return ("NONE"); */
;/* } */
;===============================================================================

;===============================================================================

;-------------------------------------------------------------------------------
;void
;bottop_players_create (Y_BOTTOP *top, int max_players)
;-------------------------------------------------------------------------------
(defun bottop_players_create (top max_players)

;  int size = max_players * sizeof (YT_PLAYER);

;  top->t = (YT_PLAYER*) malloc (size);
  (setf (TT top) (make-list max_players))
  (dotimes (i max_players)
    (setf (nth i (TT top)) (make-instance 'YT_PLAYER))
    )

  (setf (SS top) (make-list max_players))
  (dotimes (i max_players)
    (setf (nth i (SS top)) (make-instance 'YT_PLAYER))
    )

;  top->max_players = max_players;
  (setf (MAX_PLAYERS top) max_players)

;  top->num_players = 0;  
  (setf (NUM_PLAYERS top) 0)

)
;-------------------------------------------------------------------------------
;void
;bottop_datas_create (Y_BOTTOP *top, int max_datas)
;-------------------------------------------------------------------------------
(defun bottop_datas_create (top max_datas)

;  top->m = (void**) malloc (max_datas * sizeof (void*));
;  //top->d = (YT_BOT**) malloc (max_datas * sizeof (YT_BOT*));

  (setf (M top) (make-list max_datas))

;  top->max_datas = max_datas;
;  top->num_datas = 0;
  (setf (MAX_DATAS top) (make-list max_datas))
  (setf (NUM_DATAS top) (make-list 0))

;  //-----------------
;  //top->d = g_array_new (FALSE/*zero_terminated*/, FALSE/*clear_*/, sizeof (void*));

)
;-------------------------------------------------------------------------------
;Y_BOTTOP* 
;bottop_create (int max_players)
;-------------------------------------------------------------------------------
(defun bottop_create (max_players)

(let (
;  Y_BOTTOP *top = (Y_BOTTOP*) malloc (sizeof (Y_BOTTOP));
  (top (make-instance 'Y_BOTTOP))
  )
  
  (bottop_players_create top max_players)
;  bottop_datas_create (top, /* max_datas */10);
  (bottop_datas_create top 10)

  top
))
;-------------------------------------------------------------------------------
;void 
;bottop_players_init (Y_BOTTOP *top)
;-------------------------------------------------------------------------------
(defun bottop_players_init (top)

;  // вся таблица уже созданных игроков обнуляется ......

(let (
;  int i;
  p ;  YT_PLAYER *p;
  )

;  for (i= 0; i <= top->num_players; i++) {
;  (dotimes (i (NUM_PLAYERS top))
  (loop for i from 0 to (NUM_PLAYERS top) do
    (setf p (IGROK i))

    (setf (STATUS p)  0)
    (setf (INT1 p)    0)
    (setf (INT2 p)    0)
    (setf (INT3 p)    0)
    )

))
;-------------------------------------------------------------------------------
;void 
;bottop_init (Y_BOTTOP *top, int seed,
;             YT_SET_RESULT set_result,
;             YT_PRINT_SORT_RESULTS print_sort_results,

;             void  (*data_begin)  (void *m, long, long),
;             void  (*data_print_name)  (void *m), 
;             void  (*data_check_print) (void *m),

;             void  (*prog_begin) (void *p, void *d),
;             void  (*prog_print_name) (void *p),
;             void  (*prog_todo) (void *p, void *d),

;             void  (*calc_data) (void *t, void *p)
;             )
;-------------------------------------------------------------------------------
(defun 
bottop_init (top  seed
             set_result
             print_sort_results

             data_begin
             data_print_name
             data_check_print

             prog_begin
             prog_print_name
             prog_todo

             calc_data
             )

  (bottop_players_init  top)
  (srandom_set  seed)  

  (setf (SET_RESULT top) set_result)
  (setf (PRINT_SORT_RESULTS top) print_sort_results)

  (setf (DATA_BEGIN top)         data_begin)
  (setf (DATA_PRINT_NAME top)    data_print_name)
  (setf (DATA_CHECK_PRINT top)   data_check_print)

  (setf (PROG_BEGIN top)         prog_begin)
  (setf (PROG_PRINT_NAME top)    prog_print_name)
  (setf (PROG_TODO top)          prog_todo)

  (setf (CALC_DATA top)          calc_data)

)
;-------------------------------------------------------------------------------
;void 
;bottop_add_player (Y_BOTTOP *top, char *name, void *bot)
;-------------------------------------------------------------------------------
(defun bottop_add_player (top name bot)

(let (
  player
;  int i = top->num_players + 1; // т.е. первый будет 1-м ?!?????????????????
  (i  (+ (NUM_PLAYERS top) 1))
  )

  (when (> i (MAX_PLAYERS top))
;    fprintf (stderr, "ERROR: i > max_players = %d \n", top->max_players);
    (format t "ERROR: i > max_players = %s ~%" (MAX_PLAYERS top))
    (exit 0)
    )

;  YT_PLAYER *player = &((top->t)[i]);
  (setf player (nth i (TT top)))

;  top->num_players = i;
  (setf (NUM_PLAYERS top) i)

;  player->bot  = bot;
  (setf (BOT player) bot)

;  // все же лучше имя основное хранить тут
;  // а если потребуется, то дополнять из бота
;  //player->name = name; 

;  strcpy (player->name, name); 
  (setf (PLAYER_NAME player) name)
                       
))
;-------------------------------------------------------------------------------
;void 
;bottop_add_data (Y_BOTTOP *top, /* YT_BOT *bot, */ void *data)
;{
;  int i = top->num_datas + 1;

;  if (i > top->max_datas) {
;    fprintf (stderr, "ERROR: i > max_datas = %d \n", top->max_datas);
;    exit (0);
;  }

;  ((top->m)[i]) = data;
;  top->num_datas = i;

;  //--------------------------------
;  //g_array_append_val (top->d, data);


;  return;
;}
;-------------------------------------------------------------------------------
;void 
;bottop_copy_table (Y_BOTTOP *top, YT_PLAYER to[], YT_PLAYER from[]) 
;-------------------------------------------------------------------------------
(defun bottop_copy_table (top to from) 

(let (
  (players  (NUM_PLAYERS top))
;  int i;
  )

;  // сначала копируем результаты в новую табличку
;  for (i = 0; i <= players; i++) {
  (loop for i from 0 to players do
;    // ...
;    // а тогда проще вообще все сразу скопировать:
;    memcpy (&(to[i]), &(from[i]), sizeof (YT_PLAYER));
    
    (setf (nth i to) (nth i from)) 
    )

))
;-------------------------------------------------------------------------------
;void 
;bottop_players_swap_new (YT_PLAYER *sorted, int i, int max)
;-------------------------------------------------------------------------------
(defun bottop_players_swap_new (sorted i max)

(let (
;  swap_bot ;  YT_PLAYER swap;
;  int size = sizeof (YT_PLAYER);

;  /* void */ YT_PLAYER  *p_swap = (void*)(&swap);
;  /* void */ YT_PLAYER  *p_i    = (void*)(&(sorted[i]));
;  /* void */ YT_PLAYER  *p_max  = (void*)(&(sorted[max]));

  (p_i   (nth i   sorted))
  (p_max (nth max sorted))
  )

;  memcpy (p_swap, p_i, size);
;  //memcpy (p_swap->bot, p_i->bot, sizeof (YT_BOT));
;  p_swap->bot = p_i->bot;
  ;(setf swap_bot (BOT p_i)) ;???? !!!

;  memcpy (p_i, p_max, size);
;  //memcpy (p_i->bot, p_max->bot, sizeof (YT_BOT));
;  p_i->bot = p_max->bot;
  ;(setf (BOT p_i) (BOT p_max))

;  memcpy (p_max, p_swap, size);
;  //memcpy (p_max->bot, p_swap->bot, sizeof (YT_BOT));
;  p_max->bot = p_swap->bot;
  ;(setf (BOT p_max) swap_bot)

  (setf (nth i sorted)   p_max) 
  (setf (nth max sorted) p_i) 

))
;-------------------------------------------------------------------------------
;double 
;player_get_sorting_val (YT_PLAYER *players, int n, int s_area)
;-------------------------------------------------------------------------------
(defun player_get_sorting_val (players n s_area)

(let (
;  double ret;
  ret
  (player (nth n players))
  )

  (when (= s_area 0) (setf ret (SUM  player)))
  (when (= s_area 3) (setf ret (INT3 player)))

  ret
))
;-------------------------------------------------------------------------------
;void 
;bottop_sort_results_old (Y_BOTTOP *top, int s_direct, int s_area)
;-------------------------------------------------------------------------------
(defun bottop_sort_results_old (
       top       ; Y_BOTTOP *top
       s_direct  ; int s_direct
       s_area    ; int s_area
       )

(let (
  best           ;  int i, j, best;
  sum_best sum_j ;  double sum_best, sum_j;

;  YT_BOOL is_max;
;  if (s_direct == SORT_MIN_MAX) is_max = FALSE;
;  else                          is_max = TRUE;

;  (is_max (if (= s_direct SORT_MIN_MAX) CL-USER::FALSE CL-USER::TRUE))
  (is_max (if (= s_direct SORT_MIN_MAX) FALSE TRUE))

  (sorted (SS top)) ;  YT_PLAYER *sorted = top->s;
  (crosed (TT top)) ;  YT_PLAYER *crosed = top->t;
  )

  ;;  // сначала копируем результаты в новую табличку
  (bottop_copy_table  top sorted crosed)

  ;; простая (последовательная) процедура сортировки ----------------
  (loop for i from 1 to (NUM_PLAYERS top) do

    (setf best i)
    (setf sum_best (player_get_sorting_val  sorted best s_area))
    ;(format t "i=best=~d sum_best=~d ~%" i sum_best)

    (loop for j from i to (NUM_PLAYERS top) do

      (setf sum_j  (player_get_sorting_val  sorted j s_area))

;      // НАДО ЗАДАВАТЬ ПОЛЕ (функцию) СОРТИРОВКИ !!!
;      if ( ( is_max & (sum_j > sum_best)) || 
;           (!is_max & (sum_j < sum_best))  ) 
      ;(format t "j=~d sum_j=~d ~%" j sum_j)

      (when (  or 
             (and      is_max  (> sum_j sum_best)) 
             (and (not is_max) (< sum_j sum_best))  
             ) 
        ;(format t "... ~%")
        (setf best j) 
        (setf sum_best (player_get_sorting_val  sorted best s_area))
        )
     
    )
;    // best -  это игрок с наилучшим результатом в списке за i-м игроком
;    // меняем местами в таблице игроков :  i <-> max

    (bottop_players_swap_new  sorted i best)
  )
  ;;------------------------------------------------------------------

))
;-------------------------------------------------------------------------------
;void 
;bottop_print_sort_results (Y_BOTTOP *top, int s_direct, int s_area,
;                           YT_DRAW_LINE draw_line)
;-------------------------------------------------------------------------------
(defun bottop_print_sort_results (top s_direct s_area draw_line)

;  bottop_sort_results_old (top, s_direct, /* SORT_0 */ s_area);
  (bottop_sort_results_old  top s_direct s_area)
  (bottop_print_results top draw_line) ; а теперь напечатаем отсортированные результаты..

)
;===============================================================================
;-------------------------------------------------------------------------------
;void 
;bottop_players_swap (void *p_i, void *p_j,  int size, void *p_tmp)
;{

;  memcpy (p_tmp, p_i,   size);
;  memcpy (  p_i, p_j,   size);
;  memcpy (  p_j, p_tmp, size);

;  return;
;}
;-------------------------------------------------------------------------------
;int 
;sortbot_max_func (const void *a, const void *b) 
;{ 
;  YT_PLAYER *pa = (YT_PLAYER *) a;
;  YT_PLAYER *pb = (YT_PLAYER *) b;

;  double dif = pb->sum - pa->sum;
;  int    ret = dif * 1000000;

;  //printf ("dif = %f  ret = %d \n", dif, ret);
;  return (ret); 
;} 
;-------------------------------------------------------------------------------
;void 
;my_sort (void *sorted, // массив объектов размером `size`
;         int num,
;         int size,
;         int (*compare) (const void *, const void *)
;         )
;{
;  void *p_tmp = (void*) malloc (size);
;  int   i, j;
;  void *pi, *pj, *pb;

;  // простая (последовательная) процедура сортировки
;  for (i = 1; i <= num; i++) {
;    pi = (void*)(sorted) + size*(i-1);
;    //pi = &(sorted[i]);
;    pb = pi;    

;    for (j = i; j <= num; j++) {
;      pj = (void*)(sorted) + size*(j/* -1 */); //??
;      //pj = &(sorted[j]);

;      if (compare (pj, pb) > 0)
;      {
;        pb = pj;
;      }
     
;    }

;    // best - это игрок с наилучшим результатом в списке за i-м игроком
;    // меняем местами в таблице игроков :  i <-> best
;    bottop_players_swap (pi, pb, size, p_tmp);
;  }

;  free (p_tmp);
;  return;
;}
;-------------------------------------------------------------------------------
;void 
;bottop_sort_results (Y_BOTTOP *top, int (*compare) (const void *, const void *),
;                     int s_direct, int s_area)
;{

;  YT_PLAYER *sorted = top->s;
;  YT_PLAYER *crosed = top->t;

;  // сначала копируем результаты в новую табличку
;  bottop_copy_table (top, sorted, crosed);

;  my_sort ((void*) sorted, top->num_players, sizeof (YT_PLAYER), sortbot_max_func);

;  // работает с массивом указателей ?!
;  //qsort (sorted, top->num_players, sizeof (YT_PLAYER), sortbot_max_func);

;  return;
;}
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;void 
;bottop_draw_line (YT_PLAYER *table, int i)
;-------------------------------------------------------------------------------
(defun bottop_draw_line (table i)

(declare (ignore table i))

;  if (i == 0) {
;    printf ("    Time    ");
;    printf ("\n");
;  }

;  else {
;    printf (" %f ", table[i].sum);
;    printf ("\n");
;  }

)
;-------------------------------------------------------------------------------
(defun PRINT_LONGLINE ()

  (format t "------------------------------------------------------------------- ~%")

)
;-------------------------------------------------------------------------------
;void 
;bottop_print_results (Y_BOTTOP *top, YT_DRAW_LINE draw_line)
;-------------------------------------------------------------------------------
(defun bottop_print_results (top draw_line)

(let (
;  int  i;
;  YT_BOOL my_bot;
  (num_players  (NUM_PLAYERS top))

  (players (SS top)) ;  YT_PLAYER *players = top->s;
  bot      ;  void  *bot;
  bot_name ;  char  *bot_name;
  )

  (format t "FINAL SORTETED RESULTS:  ~%")
  (format t "~%")
  (PRINT_LONGLINE)
  (format t "      ")
;  printf ("%-*s ", NAMELENG, "Player Name");
  (format t "~18a" "Player Name")

  (if (not (eq draw_line NUL)) (funcall draw_line  players 0)
                               ( bottop_draw_line  players 0)
                               )
  (format t "~%")

  ;;(format t " ~s ~%" draw_line)
  ;; цикл по всeм игрокам с пeчатью строк рeзультатов
  (loop for i from 1 to num_players do  ;----------------------------------

    (setf bot (BOT (nth i players))) 
    (setf bot_name (PLAYER_NAME (nth i players))) 

;    if (!strncmp (bot_name, "MY_", 3))   my_bot = TRUE;
;    else                                 my_bot = FALSE;    
;    if (my_bot) printf (" -------------------------------------------- \n");

    (format t " ~2d)  " i)
;    printf ("%-*s ", NAMELENG, /* players[i]. */bot_name);
    (format t "~18a " bot_name)
    ;(format t "~18a |" bot_name)

  (if (not (eq draw_line NUL)) (funcall draw_line  players i)
                               (bottop_draw_line   players i)
                               )

;    if (my_bot) printf (" -------------------------------------------- \n");
    ) ;-------------------------------------------------------------------

  (format t "~%")
  (PRINT_LONGLINE)

))
;===============================================================================

;===============================================================================
;#if 0
;-------------------------------------------------------------------------------
;void 
;bottop_data_prog (Y_BOTTOP *top)
;{

;  int    i, d;
;  double time_beg, time_end, t; 
;  YT_PLAYER *player;    
;  void      *prog;

;  // идем по списку данных
;  for (d= 1; d <= top->num_datas; d++) {
;    void *data = ((top->m)[d]);

;    // инициируем данные
;    top->data_begin (data, 0, 0);

;    top->data_print_name (data); // печатаем имя данных
;    printf ("\n"); // завершаем строку с именем
;    printf ("\n"); // и еще одну пустую вставляем

;    //-----------------------------------------------------------
;    // идем по списку всех игроков
;    for (i= 1; i <= top->num_players; i++) {
;      player = IGROK(i);
;      prog = player->bot;

;      printf ("  "); // печатаем небольшой отступ
;      top->prog_print_name (prog); // печатаем имя бота

;      time_beg = TimeSec ();
 
;      top->prog_begin (prog, data); // инициируем бота 
;      top->prog_todo  (prog, data); // напускаем бота на данные

;      time_end = TimeSec (); 
;      t = time_end - time_beg;
;      top->set_result (player, t); // каждому игроку добавить время

;      top->data_check_print (data);
;    }
;    //-----------------------------------------------------------

;    printf ("\n"); 
;  }

;  top->print_sort_results (top);

;  return;
;}
;===============================================================================
;#endif
;===============================================================================
;-------------------------------------------------------------------------------
;void 
;bottop_prog_data (Y_BOTTOP *top)
;-------------------------------------------------------------------------------
(defun bottop_prog_data (top)

(let (
;  double  time_beg, time_end, t;
  player ;  YT_PLAYER *player;    
  yprog  ;  void      *prog;
  )

  (loop for i from 1 to (NUM_PLAYERS top) do

    (setf player (IGROK i))  
    (setf yprog  (BOT player))
 
;    //top->prog_print_name (prog); // печатаем имя бота
    (format t "~s " (PLAYER_NAME player)) ; // печатаем имя бота

    (format t "~%") ; // завершаем строку с именем
    (format t "~%") ; // и еще одну пустую вставляем

;    time_beg = TimeSec (); 

    (funcall (CALC_DATA top) top yprog) ;

;    time_end = TimeSec (); 
;    t = time_end - time_beg;

;    top->set_result (player, t);
    (funcall (SET_RESULT top) player 77)
    (format t "~%")
    )

;  top->print_sort_results (top);
  (funcall (PRINT_SORT_RESULTS top) top)

))
;===============================================================================
