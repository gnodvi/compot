# -*-   mode: tcl  ; coding: koi8   -*- ----------------------------------------

#===============================================================================

# (defpackage "A-CTAB" (:use "CL" "CL-USER" )
#                      (:export :Y_BEG :YTODO :SORT_MIN_MAX :SORT_3 :bottop_create :bot_make
#                               :bottop_add_player :bottop_init :Bdata 
#                               :DAT :SUM :INT1 :INT2 :INT3
#                               :bottop_prog_data 
#                               :YPROG :LONG1 :LONG2 :LONG3
#                               :bottop_print_sort_results
#                               :NUM_PLAYERS :TT :BOT  :PLAYER_NAME :SORT_MAX_MIN :SORT_0
#                               :bottop_sort_results_old :bottop_print_results
#                               ) 
#                      (:import-from :cl-user :FALSE :TRUE :NUL :srandom_set)
#                      )
# ;#+SBCL
# ;(defun srandom_set (seed)

# (in-package :a-ctab)

#/******************************************************************************/

# ;enum keywords_1 {
# ;  YINIT, YFREE, YCALC, YTRUE,  

# ;  YGINT, YRINT, YQINT, 

# ;  Y_BEG, YTODO, 
# ;  Y_PEREBOR, YGSLSPUSK, 
# ;  Y_GENALGO, 
# ;};

# (defconstant Y_BEG 7)
# (defconstant YTODO 8)

# ;/******************************************************************************/
# ;//
# ;//   Простые  БОТЫ     БОТЫ     БОТЫ     БОТЫ     БОТЫ     БОТЫ     
# ;//            БОТЫ     БОТЫ     БОТЫ     БОТЫ     БОТЫ     БОТЫ     
# ;//
# ;/******************************************************************************/

# ;typedef struct {

# (defclass YT_BOT () (
# ;  //Bprog  parent;
# ;  //----------------------------------

# ;  YT_PROG prog;               // основная счетная прога (бот)
# ;  long    long1, long2, long3 /* , long4 */;
# ;  double  d1;

#   (yprog :accessor YPROG)
#   (long1 :accessor LONG1)
#   (long2 :accessor LONG2)
#   (long3 :accessor LONG3)
#   (d1    :accessor D1)

# ))

record define YT_BOT {

  YPROG
  LONG1
  LONG2
  LONG3
  D1

}


# ;YT_BOOL BOTPRINT = FALSE;


# ;/*----------------------------------------------------------------------------*/
# ;YT_BOT *
# ;bot_create () 
# ;{
# ;  YT_BOT *bot;
# ;  bot = (YT_BOT*) malloc (sizeof (YT_BOT));

# ;  return (bot);
# ;}
# ;/*----------------------------------------------------------------------------*/
# ;void 
# ;bot_init (YT_BOT *bot, /* char *name, */ YT_PROG prog, 
# ;          long long1, long long2, long long3, /* long long4, */ double d1)
# ;/*----------------------------------------------------------------------------*/
proc bot_init {bot yprog long1 long2 long3 d1} {

  # ;  //Bprog *bp = (Bprog*)bot;
  # ;  //b_prog_init (bp, name);
  # ;  //---------------------------------
  
  #   (setf (YPROG bot) yprog) ;  bot->prog  = prog; // основная программа-бот
  #   (setf (LONG1 bot) long1) ;  bot->long1 = long1;
  #   (setf (LONG2 bot) long2) ;  bot->long2 = long2;
  #   (setf (LONG3 bot) long3) ;  bot->long3 = long3;

  $bot.YPROG = $yprog
  $bot.LONG1 = $long1
  $bot.LONG2 = $long2
  $bot.LONG3 = $long3
  
  # ;  //bot->long4 = long4;
  
  #   (setf (D1 bot) d1) ;  bot->d1 = d1;
  $bot.D1 = $d1

}
# ;/*----------------------------------------------------------------------------*/
# ;YT_BOT *
# ;bot_make (YT_PROG prog,  long long1, long long2, long long3, 
# ;          /* long long4, */ double d1) 
# ;/*----------------------------------------------------------------------------*/
proc bot_make {yprog  long1 long2 long3 d1} {

  # (let (
  # ;  YT_BOT *bot = bot_create ();
  #   (bot (make-instance 'YT_BOT))
  set bot [YT_BOT #auto]
  #   )
  
  bot_init  $bot $yprog $long1 $long2 $long3 $d1

  return $bot
}
# ;===============================================================================



# ;===============================================================================
# ; *                                                                            *
# ; *  Имя этого файла: e_tabs.c                                                 *
# ; *                                                                            *
# ;===============================================================================
                                                                             
# ;#include "a_comm.h"
# ;#include "e_tabs.h"
 
# ;===============================================================================

# (defclass Bdata () (
# ;  char   name[NAMELENG+1];   // описательное (наглядное) имя 
#   (name :accessor BDATA_NAME)  

# ;  //void  (*data_begin)  (void *m, long, long);
# ;  //void  (*print_name)  (void *m); 
# ;  //void  (*check_print) (void *m); 
# ))

# (defconstant NAMELENG  18)

# ;  //typedef struct {
# ;  //char   name[NAMELENG+1];   // описательное (наглядное) имя 

# ;  //void  (*prog_begin) (void *p, void *d);
# ;  //void  (*print_name) (void *p); 
# ;  //void  (*prog_todo)  (void *p, void *d);
# ;  //} Bprog;

# ;// -------------------------------------------------------------------------
# ;// это некий стандартный бот, используется в  MIPROG и BOTTUR 
# ;// однако !! не совсем стандартный, а уже потомок Bprog !!


#-------------------------------------------------------------------------------
record define YT_PLAYER {

  # ;  //char *name;
  # ;  char   name[NAMELENG+1];   // описательное (наглядное) имя 
  # ;  void *bot; 
  
  #   (name :accessor PLAYER_NAME)
  #   (bot  :accessor BOT)

  PLAYER_NAME ;# public variable PLAYER_NAME
  BOT         ;# public variable BOT

  # ;  // это относится к результатам (а точнее к краткому резюме в контексте соревнования)
  # ;  int    status;
  # ;  double sum; 
  # ;  int    int1, int2, int3;
  
  #   (status :accessor STATUS)
  #   (sum    :accessor SUM)
  #   (int1   :accessor INT1)
  #   (int2   :accessor INT2)
  #   (int3   :accessor INT3)
  
  STATUS ;# public variable STATUS
  SUM    ;# public variable SUM
  INT1   ;# public variable INT1
  INT2   ;# public variable INT2
  INT3   ;# public variable INT3

}
#-------------------------------------------------------------------------------


# ;/*---------------------------*/

set ::SORT_0  0
set ::SORT_1  1
set ::SORT_2  2
set ::SORT_3  3

set ::SORT_MIN_MAX  10
set ::SORT_MAX_MIN  11

# ;typedef struct {
# ;  char   name[NAMELENG+1];   // описательное (наглядное) имя 

# ;  //void  (*prog_begin) (void *p, void *d);
# ;  //void  (*print_name) (void *p); 
# ;  //void  (*prog_todo)  (void *p, void *d);
# ;} Btop;


#-------------------------------------------------------------------------------
# (defclass Y_BOTTOP () (

#class Y_BOTTOP {}
record define Y_BOTTOP {
    
  #eval makegetset {TT 0}

  #eval makegetset BOTTOP_NAME TT SS MAX_PLAYERS NUM_PLAYERS SET_RESULT CALC_DATA
  #eval makegetset PRINT_SORT_RESULTS PROG_PRINT_NAME DATA_BEGIN PROG_BEGIN
  #eval makegetset DATA_PRINT_NAME DATA_CHECK_PRINT PROG_TODO M MAX_DATAS NUM_DATAS DAT

  # ;  Btop  parent;
  #   (name :accessor BOTTOP_NAME)
  # ;  //----------------------------------
  
  # ;  YT_PLAYER   *t;     // описание игроков c табличками результатов
  #   (tt :accessor TT)
  
  TT ;# public variable TT  
  #   method setTTind {ind val} {
  #     lset TT $ind  $val  ;# это же список
  #   }
  
  # ;  YT_PLAYER   *s;     // таблица для сортированных результатов
  #   (ss :accessor SS)
  
  SS ;# public variable SS  
  #   method setSSind {ind val} {
  #     lset SS $ind  $val 
  #   }
  
  
  # ;  int       max_players, num_players;
  #   (max_players :accessor MAX_PLAYERS)
  #   (num_players :accessor NUM_PLAYERS)
  
  MAX_PLAYERS ;# public variable MAX_PLAYERS
  NUM_PLAYERS ;# public variable NUM_PLAYERS
  
  # ;  YT_SET_RESULT         set_result;
  # ;  void  (*calc_data) (void *bottop, void *prog); 
  #   (set_result  :accessor SET_RESULT)
  #   (calc_data   :accessor CALC_DATA)
  
  # ;  YT_PRINT_SORT_RESULTS print_sort_results;
  # ;  void  (*prog_print_name) (void *p);
  #   (print_sort_results :accessor PRINT_SORT_RESULTS)
  #   (prog_print_name    :accessor PROG_PRINT_NAME)
  
  # ;  //----------------------------------
  
  # ;  void  (*data_begin)  (void *m, long, long);
  # ;  void  (*prog_begin) (void *p, void *d);
  #   (data_begin :accessor DATA_BEGIN)
  #   (prog_begin :accessor PROG_BEGIN)
  
  # ;  void  (*data_print_name)  (void *m); 
  # ;  void  (*data_check_print) (void *m); 
  #   (data_print_name  :accessor DATA_PRINT_NAME)
  #   (data_check_print :accessor DATA_CHECK_PRINT)
  
  # ;  void  (*prog_todo) (void *p, void *d);
  #   (prog_todo :accessor PROG_TODO)
  
  # ;  void   **m;   // данные пока обобщенные (потом надо выводить в потомках)
  # ;  int    max_datas, num_datas;
  #   (m         :accessor M)
  #   (max_datas :accessor MAX_DATAS)
  #   (num_datas :accessor NUM_DATAS)
  
  M ;# public variable M
  MAX_DATAS ;# public variable MAX_DATAS
  NUM_DATAS ;# public variable NUM_DATAS
  
  # ;  //-------------------------------------------
  
  # ;  void      *dat;
  #   (dat :accessor DAT)
  # ))
  
}

#-------------------------------------------------------------------------------
proc bottop_print {top} {


  set num_players  [$top cget -NUM_PLAYERS]
  
  set TT [$top cget -TT] 
  set SS [$top cget -SS] 

  puts "BOTTOP.NUM_PLAYERS = $num_players"
  puts ""
  puts "BOTTOP.TT = $TT"
  puts ""
  puts ""
  puts "BOTTOP.SS = $SS"

  puts ""

  return
}
#-------------------------------------------------------------------------------
proc setTTind {btop ind val} {

  lset [$btop vget -TT] $ind  $val  ;# это же список

}
#-------------------------------------------------------------------------------
proc addTT {btop val} {

  lappend [$btop vget -TT] $val 

}
#-------------------------------------------------------------------------------
# proc setSSind {btop ind val} {

#   lset [$btop vget -SS] $ind  $val 

# }
#-------------------------------------------------------------------------------


# ;#define IGROK(n) (&((top->t)[n]))

# ;-------------------------------------------------------------------------------
# (defun IGROK_func (n top)

#   (nth n (TT top))
# )
# ;-------------------------------------------------------------------------------
# (defmacro IGROK (n) (list 'nth n (list 'TT 'top)))

#-------------------------------------------------------------------------------
proc IGROK {top n} {

  #puts "IGROK: TT = [$top cget -TT]"

  set p [lindex [$top cget -TT] $n]

  #puts "IGROK: n = $n  p  = $p \n"

  return $p
}
# ;===============================================================================
# ;
# ;===============================================================================

# ;-------------------------------------------------------------------------------
# ;void 
# ;b_data_init (Bdata *self, char *name/* , */ 
# ;             //void  (*data_begin)  (void *, long, long),
# ;             //void  (*print_name)  (void *),
# ;             //void  (*check_print) (void *)
# ;             ) 
# ;{

# ;  b_data_set_name (self, name);

# ;  //self->data_begin  = data_begin;
# ;  //self->print_name  = print_name;
# ;  //self->check_print = check_print;

# ;  return;
# ;}
# ;-------------------------------------------------------------------------------
# ;void
# ;b_data_set_name (Bdata *self, char *name)
# ;{

# ;  strcpy (self->name, name);

# ;  return;
# ;}
# ;===============================================================================


# ;-------------------------------------------------------------------------------
# ;/* void  */
# ;/* b_prog_init (Bprog *self, char *name) */
# ;/* { */

# ;/*   return; */
# ;/* } */
# ;-------------------------------------------------------------------------------
# ;/* void */
# ;/* b_prog_set_name (Bprog *self, char *name) */
# ;/* { */


# ;/*   return; */
# ;/* } */
# ;-------------------------------------------------------------------------------
# ;/* char* */
# ;/* b_prog_get_name (Bprog *self) */
# ;/* { */

# ;/*   return ("NONE"); */
# ;/* } */
# ;===============================================================================

# ;===============================================================================

#-------------------------------------------------------------------------------
proc player_create {} {

  set ply [YT_PLAYER #auto]

  $ply configure -SUM 0

  $ply configure -INT1 0
  $ply configure -INT2 0
  $ply configure -INT3 0

  return $ply
}
#-------------------------------------------------------------------------------
proc bottop_players_create {top max_players} {

  #$top configure -TT [make-list $max_players]
  $top configure -TT {}
  
  puts ""
  
#   for {set i 0} {$i < $max_players} {incr i} {   
#     set ply [player_create]          
#     #setTTind $top $i $ply ;
#     addTTind $top $ply ;
#   }
   
 
  $top configure -SS {}

  #$top configure -SS [make-list $max_players] ;# ??? зачем ???

  #for {set i 0} {$i < $max_players} {incr i} {
  #    set ply [player_create]
  #    setSSind $top $i $ply
  #}
      
  $top configure -MAX_PLAYERS $max_players
  $top configure -NUM_PLAYERS 0

  return
}
#-------------------------------------------------------------------------------
# ;void
# ;bottop_datas_create (Y_BOTTOP *top, int max_datas)
#-------------------------------------------------------------------------------
proc bottop_datas_create {top max_datas} {

# ;  top->m = (void**) malloc (max_datas * sizeof (void*));
# ;  //top->d = (YT_BOT**) malloc (max_datas * sizeof (YT_BOT*));

#   (setf (M top) (make-list max_datas))
  $top configure -M [list_make $max_datas]

# ;  top->max_datas = max_datas;
# ;  top->num_datas = 0;
#   (setf (MAX_DATAS top) (make-list max_datas))
#   (setf (NUM_DATAS top) (make-list 0))
  $top configure -MAX_DATAS [list_make $max_datas]
  $top configure -NUM_DATAS [list_make 0]

# ;  //-----------------
# ;  //top->d = g_array_new (FALSE/*zero_terminated*/, FALSE/*clear_*/, sizeof (void*));

}
#-------------------------------------------------------------------------------
# ;Y_BOTTOP* 
# ;bottop_create (int max_players)
#-------------------------------------------------------------------------------
proc bottop_create {max_players} {

# (let (
# ;  Y_BOTTOP *top = (Y_BOTTOP*) malloc (sizeof (Y_BOTTOP));
#   (top (make-instance 'Y_BOTTOP))
#   )
  
  #Y_BOTTOP top
  set top [Y_BOTTOP #auto]

  bottop_players_create $top $max_players

# ;  bottop_datas_create (top, /* max_datas */10);
#   (bottop_datas_create top 10)
  bottop_datas_create $top 10

  return $top
}
#-------------------------------------------------------------------------------
# ;void 
# ;bottop_players_init (Y_BOTTOP *top)


#-------------------------------------------------------------------------------
proc bottop_players_init {top} {

  # вся таблица уже созданных игроков обнуляется ...

  # int i
  # p ;  YT_PLAYER *p

  # ;  for (i= 0; i <= top->num_players; i++) {}
  # ;  (dotimes (i (NUM_PLAYERS top))
  #   (loop for i from 0 to (NUM_PLAYERS top) do
 
  #-------------------------------------------------- 

  set num [$top cget -NUM_PLAYERS]

  #puts "num = $num"

  for {set i 0} {$i < $num} {incr i} {

    #     (setf p (IGROK i))
    #set p [lindex [$top cget -TT] $i]
    set p [IGROK $top $i]

    #puts "player init i = $i"
    
    #     (setf (STATUS p)  0)
    #     (setf (INT1 p)    0)
    #     (setf (INT2 p)    0)
    #     (setf (INT3 p)    0)

    $p configure -STATUS  0
    $p configure -INT1  0
    $p configure -INT2  0
    $p configure -INT3  0
  }

}
#-------------------------------------------------------------------------------
# ;void 
# ;bottop_init (Y_BOTTOP *top, int seed,
# ;             YT_SET_RESULT set_result,
# ;             YT_PRINT_SORT_RESULTS print_sort_results,

# ;             void  (*data_begin)  (void *m, long, long),
# ;             void  (*data_print_name)  (void *m), 
# ;             void  (*data_check_print) (void *m),

# ;             void  (*prog_begin) (void *p, void *d),
# ;             void  (*prog_print_name) (void *p),
# ;             void  (*prog_todo) (void *p, void *d),

# ;             void  (*calc_data) (void *t, void *p)
# ;             )
#-------------------------------------------------------------------------------
proc bottop_init {top  seed          \
                  set_result         \
                  print_sort_results \
                                     \
                  data_begin         \
                  data_print_name    \
                  data_check_print   \
                                     \
                  prog_begin         \
                  prog_print_name    \
                  prog_todo          \
                                     \
                  calc_data          \
                  } {

  bottop_players_init  $top
  #   (srandom_set  seed)  
  comm_random_seed $seed 
  
  #   (setf (SET_RESULT top) set_result)
  #   (setf (PRINT_SORT_RESULTS top) print_sort_results)
  
  $top.SET_RESULT         = $set_result
  $top.PRINT_SORT_RESULTS = $print_sort_results


  #   (setf (DATA_BEGIN top)         data_begin)
  #   (setf (DATA_PRINT_NAME top)    data_print_name)
  #   (setf (DATA_CHECK_PRINT top)   data_check_print)
  
  #   (setf (PROG_BEGIN top)         prog_begin)
  #   (setf (PROG_PRINT_NAME top)    prog_print_name)
  #   (setf (PROG_TODO top)          prog_todo)
  
  #   (setf (CALC_DATA top)          calc_data)
  $top.CALC_DATA = $calc_data

}
#-------------------------------------------------------------------------------
# ;void 
# ;bottop_add_player (Y_BOTTOP *top, char *name, void *bot)
#-------------------------------------------------------------------------------
proc bottop_add_player {top name bot} {

  #   player
  # ;  int i = top->num_players + 1; // т.е. первый будет 1-м ?!?????????????????
  #   (i  (+ (NUM_PLAYERS top) 1))
  set i [expr {[$top cget -NUM_PLAYERS] + 1}]
  
  #   (when (> i (MAX_PLAYERS top))
  # ;    fprintf (stderr, "ERROR: i > max_players = %d \n", top->max_players);
  #     (format t "ERROR: i > max_players = %s ~%" (MAX_PLAYERS top))
  #     (exit 0)
  #     )
  if {$i > [$top cget -MAX_PLAYERS]} {
    puts [format "ERROR: $i > max_players = %d \n" [$top cget -MAX_PLAYERS]]
    exit
  }
  
  $top configure -NUM_PLAYERS $i
  
  # ;  YT_PLAYER *player = &((top->t)[i]);
  #   (setf player (nth i (TT top)))
  
  # взяли копию из списка?
  #set player [lindex [$top cget -TT] $i]

  set player [player_create]
  
  $player configure -BOT $bot
  
  # ;  // все же лучше имя основное хранить тут
  # ;  // а если потребуется, то дополнять из бота
  # ;  //player->name = name; 
  
  # ;  strcpy (player->name, name); 
  #   (setf (PLAYER_NAME player) name)
  $player configure -PLAYER_NAME $name
  
  # здесь наверное копию надо положить обратно в массив в объекте
  # 
  #setTTind $top $i $player
  addTT $top $player
  
}
# ;-------------------------------------------------------------------------------
# ;void 
# ;bottop_add_data (Y_BOTTOP *top, /* YT_BOT *bot, */ void *data)
# ;{
# ;  int i = top->num_datas + 1;

# ;  if (i > top->max_datas) {
# ;    fprintf (stderr, "ERROR: i > max_datas = %d \n", top->max_datas);
# ;    exit (0);
# ;  }

# ;  ((top->m)[i]) = data;
# ;  top->num_datas = i;

# ;  //--------------------------------
# ;  //g_array_append_val (top->d, data);


# ;  return;
# ;}
# ;-------------------------------------------------------------------------------
# ;void 
# ;bottop_copy_table (Y_BOTTOP *top, YT_PLAYER to[], YT_PLAYER from[]) 
# ;-------------------------------------------------------------------------------
proc bottop_copy_table {top &to from} { 

  USE_REFS

  set players [$top cget -NUM_PLAYERS]
  
  # сначала копируем результаты в новую табличку

  for {set i 0} {$i <= $players} {incr i} {

    # ;    // ...
    # ;    // а тогда проще вообще все сразу скопировать:
    # ;    memcpy (&(to[i]), &(from[i]), sizeof (YT_PLAYER));
    
    lset to $i [lindex $from $i]
  }

}
# ;-------------------------------------------------------------------------------
# ;void 
# ;bottop_players_swap_new (YT_PLAYER *sorted, int i, int max)
# ;-------------------------------------------------------------------------------
proc bottop_players_swap_new {&sorted i max} {

  USE_REFS

  # (let (
  # ;  swap_bot ;  YT_PLAYER swap;
  # ;  int size = sizeof (YT_PLAYER);
  
  # ;  /* void */ YT_PLAYER  *p_swap = (void*)(&swap);
  # ;  /* void */ YT_PLAYER  *p_i    = (void*)(&(sorted[i]));
  # ;  /* void */ YT_PLAYER  *p_max  = (void*)(&(sorted[max]));
  
  #set p_i   [lindex  $sorted $i]
  #set p_max [lindex  $sorted $max]
  #   )
  
  # ;  memcpy (p_swap, p_i, size);
  # ;  //memcpy (p_swap->bot, p_i->bot, sizeof (YT_BOT));
  # ;  p_swap->bot = p_i->bot;
  #   ;(setf swap_bot (BOT p_i)) ;???? !!!
  
  # ;  memcpy (p_i, p_max, size);
  # ;  //memcpy (p_i->bot, p_max->bot, sizeof (YT_BOT));
  # ;  p_i->bot = p_max->bot;
  #   ;(setf (BOT p_i) (BOT p_max))
  
  # ;  memcpy (p_max, p_swap, size);
  # ;  //memcpy (p_max->bot, p_swap->bot, sizeof (YT_BOT));
  # ;  p_max->bot = p_swap->bot;
  #   ;(setf (BOT p_max) swap_bot)
  
  #lset $sorted $i   $p_max
  #lset $sorted $max $p_i 
  
}
# ;-------------------------------------------------------------------------------
# ;double 
# ;player_get_sorting_val (YT_PLAYER *players, int n, int s_area)
# ;-------------------------------------------------------------------------------
proc player_get_sorting_val {players n s_area} {

  # ;  double ret;
  set player [lindex $players $n]

  #puts "player_get_sorting_val: players= $players  n= $n  player = $player s_area= $s_area"
  
  #if {$s_area == 0} {set ret [$player.SUM] }
  #if {$s_area == 3} {set ret [$player.INT3]}
  
  #   if {$s_area == "SORT_0"} {set ret [$player.SUM] }
  #   if {$s_area == "SORT_3"} {set ret [$player.INT3]}
  
  switch -glob $s_area {

  "SORT_0" {set ret [$player.SUM] }
  "SORT_3" {set ret [$player.INT3]}
  default { 
    ERROR "!!!!!!!!!!!!!!!!!!!!!!"
  }

  } 

  return $ret
}
# ;-------------------------------------------------------------------------------
# ;void 
# ;bottop_sort_results_old (Y_BOTTOP *top, int s_direct, int s_area)
# ;-------------------------------------------------------------------------------
# (defun bottop_sort_results_old (
#        top       ; Y_BOTTOP *top
#        s_direct  ; int s_direct
#        s_area    ; int s_area
#        )
# ;-------------------------------------------------------------------------------
proc bottop_sort_results_old {top s_direct s_area } {

  if   {$s_direct == $::SORT_MIN_MAX} {set is_max FALSE} \
  else                                {set is_max  TRUE}
  
  set crosed [$top cget -TT] 
  #set sorted [$top cget -SS] 
  
  #  сначала копируем результаты в новую табличку
  #bottop_copy_table  $top  sorted $crosed
  set sorted $crosed 
  
  #   ;; простая (последовательная) процедура сортировки ----------------
  #for {set i 1} {$i <= [$top cget -NUM_PLAYERS]} {incr i} {}
  for {set i 0} {$i < [$top cget -NUM_PLAYERS]} {incr i} {
  
    set  best $i
    set sum_best [player_get_sorting_val  $sorted $best $s_area]

    #     ;(format t "i=best=~d sum_best=~d ~%" i sum_best)
    
    #for {set j $i} {$j <= [$top cget -NUM_PLAYERS]} {incr j} {}
    for {set j $i} {$j < [$top cget -NUM_PLAYERS]} {incr j} {
   
      set sum_j  [player_get_sorting_val  $sorted $j $s_area]
      
      # ;      // НАДО ЗАДАВАТЬ ПОЛЕ (функцию) СОРТИРОВКИ !!!
      # ;      if ( ( is_max & (sum_j > sum_best)) || 
      # ;           (!is_max & (sum_j < sum_best))  ) 
      #       ;(format t "j=~d sum_j=~d ~%" j sum_j)
      
      #       (when (  or 
      #              (and      is_max  (> sum_j sum_best)) 
      #              (and (not is_max) (< sum_j sum_best))  
      #              ) 
      #         ;(format t "... ~%")
      #         (setf best j) 
      #         (setf sum_best (player_get_sorting_val  sorted best s_area))
      #         )
      
      if { [expr {\
              ($is_max  &&  ($sum_j > $sum_best)) \
              || \
                    ((! $is_max) && ($sum_j < $sum_best)) }] } { \
        set best $j 
        set sum_best [player_get_sorting_val  $sorted $best $s_area]
      }
      
    }
    # ;    // best -  это игрок с наилучшим результатом в списке за i-м игроком
    # ;    // меняем местами в таблице игроков :  i <-> max
    
    #bottop_players_swap_new  $sorted $i $best

    set i_val    [lindex  $sorted $i]
    set best_val [lindex  $sorted $best]
    #puts "i_val = $i_val   best_val = $best_val"

    lset sorted $i    $best_val
    lset sorted $best $i_val
  }
  #   ;;------------------------------------------------------------------
  
  $top configure -SS $sorted

}
# ;-------------------------------------------------------------------------------
# ;void 
# ;bottop_print_sort_results (Y_BOTTOP *top, int s_direct, int s_area,
# ;                           YT_DRAW_LINE draw_line)
# ;-------------------------------------------------------------------------------
proc bottop_print_sort_results {top s_direct s_area draw_line} {

  # ;  bottop_sort_results_old (top, s_direct, /* SORT_0 */ s_area);

  #   (bottop_sort_results_old  top s_direct s_area)
  #   (bottop_print_results top draw_line) ; а теперь напечатаем отсортированные результаты..

  bottop_sort_results_old  $top $s_direct $s_area
  bottop_print_results     $top $draw_line ;# а теперь напечатаем отсортированные результаты..

}
# ;===============================================================================
# ;-------------------------------------------------------------------------------
# ;void 
# ;bottop_players_swap (void *p_i, void *p_j,  int size, void *p_tmp)
# ;{

# ;  memcpy (p_tmp, p_i,   size);
# ;  memcpy (  p_i, p_j,   size);
# ;  memcpy (  p_j, p_tmp, size);

# ;  return;
# ;}
# ;-------------------------------------------------------------------------------
# ;int 
# ;sortbot_max_func (const void *a, const void *b) 
# ;{ 
# ;  YT_PLAYER *pa = (YT_PLAYER *) a;
# ;  YT_PLAYER *pb = (YT_PLAYER *) b;

# ;  double dif = pb->sum - pa->sum;
# ;  int    ret = dif * 1000000;

# ;  //printf ("dif = %f  ret = %d \n", dif, ret);
# ;  return (ret); 
# ;} 
# ;-------------------------------------------------------------------------------
# ;void 
# ;my_sort (void *sorted, // массив объектов размером `size`
# ;         int num,
# ;         int size,
# ;         int (*compare) (const void *, const void *)
# ;         )
# ;{
# ;  void *p_tmp = (void*) malloc (size);
# ;  int   i, j;
# ;  void *pi, *pj, *pb;

# ;  // простая (последовательная) процедура сортировки
# ;  for (i = 1; i <= num; i++) {
# ;    pi = (void*)(sorted) + size*(i-1);
# ;    //pi = &(sorted[i]);
# ;    pb = pi;    

# ;    for (j = i; j <= num; j++) {
# ;      pj = (void*)(sorted) + size*(j/* -1 */); //??
# ;      //pj = &(sorted[j]);

# ;      if (compare (pj, pb) > 0)
# ;      {
# ;        pb = pj;
# ;      }
     
# ;    }

# ;    // best - это игрок с наилучшим результатом в списке за i-м игроком
# ;    // меняем местами в таблице игроков :  i <-> best
# ;    bottop_players_swap (pi, pb, size, p_tmp);
# ;  }

# ;  free (p_tmp);
# ;  return;
# ;}
# ;-------------------------------------------------------------------------------
# ;void 
# ;bottop_sort_results (Y_BOTTOP *top, int (*compare) (const void *, const void *),
# ;                     int s_direct, int s_area)
# ;{

# ;  YT_PLAYER *sorted = top->s;
# ;  YT_PLAYER *crosed = top->t;

# ;  // сначала копируем результаты в новую табличку
# ;  bottop_copy_table (top, sorted, crosed);

# ;  my_sort ((void*) sorted, top->num_players, sizeof (YT_PLAYER), sortbot_max_func);

# ;  // работает с массивом указателей ?!
# ;  //qsort (sorted, top->num_players, sizeof (YT_PLAYER), sortbot_max_func);

# ;  return;
# ;}
# ;-------------------------------------------------------------------------------
# ;-------------------------------------------------------------------------------
# ;void 
# ;bottop_draw_line (YT_PLAYER *table, int i)
# ;-------------------------------------------------------------------------------
# (defun bottop_draw_line (table i)

# (declare (ignore table i))

# ;  if (i == 0) {
# ;    printf ("    Time    ");
# ;    printf ("\n");
# ;  }

# ;  else {
# ;    printf (" %f ", table[i].sum);
# ;    printf ("\n");
# ;  }

# )
# ;-------------------------------------------------------------------------------
proc PRINT_LONGLINE {} {

  puts "------------------------------------------------------------------- "

}
#-------------------------------------------------------------------------------
proc bottop_print_results {top draw_line} {


  set num_players  [$top cget -NUM_PLAYERS]
  
  set players [$top cget -SS] 


  puts "FINAL SORTETED RESULTS:  "

  puts ""
  PRINT_LONGLINE

  puts -nonewline "      "
  puts -nonewline "Player Name      "
  
  #   (if (not (eq draw_line NUL)) (funcall draw_line  players 0)
  #                                ( bottop_draw_line  players 0)
  #                                )

  $draw_line  NUL 0 ;# заголовочная строка !!!!
  puts ""
  

  #for {set i 1} {$i <= $num_players} {incr i} {}
  for {set i 0} {$i < $num_players} {incr i} {
  
    #set player [lindex [$top cget -TT] $i]  
    set player [lindex $players $i]  
    #player_print $player

    set bot_name [$player cget -PLAYER_NAME]
    #puts "bot_name = $bot_name"
    
    puts -nonewline [format " %2d)  " [expr {$i + 1}]]
    puts -nonewline [format "%-18s" $bot_name] 
    
    #   (if (not (eq draw_line NUL)) (funcall draw_line  players i)
    #                                (bottop_draw_line   players i)
    #                                )
    #$draw_line  $player $i   
    #$draw_line  $player 9999 ;# номер не нужен!  ???????????????????
    $draw_line  $player  $i ;# номер не нужен!  ???????????????????
  }
  
  #(format t "~%")
  #(PRINT_LONGLINE)
  puts ""
  PRINT_LONGLINE

  return
}
# ;===============================================================================

# ;===============================================================================
# ;#if 0
# ;-------------------------------------------------------------------------------
# ;void 
# ;bottop_data_prog (Y_BOTTOP *top)
# ;{

# ;  int    i, d;
# ;  double time_beg, time_end, t; 
# ;  YT_PLAYER *player;    
# ;  void      *prog;

# ;  // идем по списку данных
# ;  for (d= 1; d <= top->num_datas; d++) {
# ;    void *data = ((top->m)[d]);

# ;    // инициируем данные
# ;    top->data_begin (data, 0, 0);

# ;    top->data_print_name (data); // печатаем имя данных
# ;    printf ("\n"); // завершаем строку с именем
# ;    printf ("\n"); // и еще одну пустую вставляем

# ;    //-----------------------------------------------------------
# ;    // идем по списку всех игроков
# ;    for (i= 1; i <= top->num_players; i++) {
# ;      player = IGROK(i);
# ;      prog = player->bot;

# ;      printf ("  "); // печатаем небольшой отступ
# ;      top->prog_print_name (prog); // печатаем имя бота

# ;      time_beg = TimeSec ();
 
# ;      top->prog_begin (prog, data); // инициируем бота 
# ;      top->prog_todo  (prog, data); // напускаем бота на данные

# ;      time_end = TimeSec (); 
# ;      t = time_end - time_beg;
# ;      top->set_result (player, t); // каждому игроку добавить время

# ;      top->data_check_print (data);
# ;    }
# ;    //-----------------------------------------------------------

# ;    printf ("\n"); 
# ;  }

# ;  top->print_sort_results (top);

# ;  return;
# ;}
# ;===============================================================================
# ;#endif
# ;===============================================================================
# ;-------------------------------------------------------------------------------
# ;void 
# ;bottop_prog_data (Y_BOTTOP *top)
# ;-------------------------------------------------------------------------------
proc bottop_prog_data {top} {

  # (let (
  # ;  double  time_beg, time_end, t;
  #   player ;  YT_PLAYER *player;    
  #   yprog  ;  void      *prog;
  #   )
  
  #   (loop for i from 1 to (NUM_PLAYERS top) do
  for {set i 0} {$i < [$top.NUM_PLAYERS]} {incr i} {
  
    #     (setf player (IGROK i))  
    set player [IGROK $top $i]
 
    #     (setf yprog  (BOT player))
    set yprog [$player.BOT]
    
    # ;    //top->prog_print_name (prog); // печатаем имя бота
    #     (format t "~s " (PLAYER_NAME player)) ; // печатаем имя бота
    puts [$player.PLAYER_NAME]
    
    #     (format t "~%") ; // завершаем строку с именем
    #     (format t "~%") ; // и еще одну пустую вставляем
    puts ""
    
    # ;    time_beg = TimeSec (); 
    
    #     (funcall (CALC_DATA top) top yprog) ;
    [$top.CALC_DATA] $top $yprog
    
    # ;    time_end = TimeSec (); 
    # ;    t = time_end - time_beg;
    
    # ;    top->set_result (player, t);
    #     (funcall (SET_RESULT top) player 77)
    [$top.SET_RESULT] $player 77
    #     (format t "~%")
    puts ""
    
    #     )
  }

  # ;  top->print_sort_results (top);
  #   (funcall (PRINT_SORT_RESULTS top) top)
  [$top.PRINT_SORT_RESULTS] $top

}
#===============================================================================
#===============================================================================
#===============================================================================

# это тестовый пример использования 
# соревнование сортировок


# ;=============================================================================
# f_sort.tl 
# ;=============================================================================

# ;void sort_main_44 ();
# ;void sort_main_55 ();
# ;void sort_main_03 (int argc, char** argv, int j);

# ;=============================================================================

# (defclass T_SORTING (Bdata) (

# ;  Bdata  parent;

# ;  int  Num;
# ;  int *Array, *Sorts, *Orign;

#   (Num   :accessor NUM)
#   (Arrey :accessor ARREY)
#   (Sorts :accessor SORTS)
#   (Orign :accessor ORIGN)

# ;  int num_randoms, sorted, reversed;

#   (num_randoms :accessor NUM_RANDOMS)
#   (sorted      :accessor SORTED)
#   (reversed    :accessor REVERSED)

# ))

record define T_SORTING {

  NUM
  ARREY
  SORTS
  ORIGN  
  
  NUM_RANDOMS
  SORTED
  REVERSED  
}

# ;=============================================================================

# ;-----------------------------------------------------------------------------
# ;/* void */
# ;/* sorting_begin (void *s, long long1, long long2)  */
# ;/* { */
# ;/*   T_SORTING *sorting = (T_SORTING *) s; */

# ;/*   ai_initialize (sorting->Sorts, sorting->Num); */

# ;/*   return; */
# ;/* } */
# ;-------------------------------------------------------------------------------
# ;void 
# ;sort_check (int *Orign, int *Array, int *Sorts, int Num, 
# ;            char *message)
# ;-------------------------------------------------------------------------------
proc sort_check {Orign Arrey Sorts Num message} {

  #ai_print $Orign    
  #ai_print $Arrey     
  #ai_print $Sorts     

  # (let (
  # ;  // если хотя бы одни элемент массива не совпал, то G_FAILURE=-1
  set status  [ai_check_compare  $Arrey $Sorts $Num]
  #   )
  
  # ;  if (status == G_SUCCESS)  printf ("PASS: ");
  # ;  else                      printf ("FAIL: "); 
   
  if {$status == true}  {puts -nonewline  "PASS: "} \
  else                  {puts -nonewline  "FAIL: "}
  
  # ;  //printf ("%-*s  \n", NAMELENG, p_i->name);
  #   (format t "~s  ~%" message)
  #puts [format "%s  \n" $message]
  puts "$message"
  
  if {$status == false} {
    ai_print $Orign    
    ai_print $Arrey     
    ai_print $Sorts     
  }
  
}
# ;-------------------------------------------------------------------------------
# ;void 
# ;sorting_check_print (void *s, char *message)
# ;-------------------------------------------------------------------------------
proc sorting_check_print {s message} {

  # (let* (
  # ;  T_SORTING *sorting = (T_SORTING *) s; // делаем реальный указатель
  
  # ;  int    Num = sorting->Num;
  
  # ;  int *Array = sorting->Array; 
  # ;  int *Sorts = sorting->Sorts; 
  # ;  int *Orign = sorting->Orign; 
  #   )
  
  # ;  sort_check (Orign, Array, Sorts, Num, message);

  sort_check  [$s.ORIGN] [$s.ARREY] [$s.SORTS] [$s.NUM] $message
  
}
# ;-------------------------------------------------------------------------------
# ;void 
# ;sorting_init (T_SORTING *sorting, char *name, int Num,
# ;              int num_randoms, int sorted, int reversed)
# ;-------------------------------------------------------------------------------
proc sorting_init {sorting name Num num_randoms sorted reversed} {


  # (declare (ignore name))
  # ;  //Bdata *bd = (Bdata*)sorting;
  
  # ;  //b_data_init (bd, name, midata_begin, midata_print_name, midata_check_print);
  # ;  //---------------------------------
  
  # ;  sorting->Num = Num;
  $sorting.NUM = $Num
  
  # ;  sorting->Array = (int *) malloc (Num * sizeof (int));
  # ;  sorting->Sorts = (int *) malloc (Num * sizeof (int));
  # ;  sorting->Orign = (int *) malloc (Num * sizeof (int));
  
  $sorting.ARREY = {} ;# (make-list Num))
  $sorting.SORTS = {} ;# (make-list Num))
  $sorting.ORIGN = {} ;# (make-list Num))
  
  # ;  sorting->num_randoms = num_randoms;
  # ;  sorting->sorted      = sorted;
  # ;  sorting->reversed    = reversed;
  
  $sorting.NUM_RANDOMS = $num_randoms
  $sorting.SORTED      = $sorted
  $sorting.REVERSED    = $reversed
  
}
# ;-------------------------------------------------------------------------------
# ;void *
# ;sorting_create (char *name, int Num,
# ;                int num_randoms, int sorted, int reversed) 
# ;-------------------------------------------------------------------------------
proc sorting_create {name Num num_randoms sorted reversed} {

  set s [T_SORTING #auto]
  
  sorting_init  $s $name $Num  $num_randoms $sorted $reversed
  
  # ;  return ((void*) s);
  return $s
}
# ;-------------------------------------------------------------------------------
# ;void
# ;sorting_end (/* T_SORTING *sorting */void *s) 
# ;{
# ;  T_SORTING *sorting = (T_SORTING *) s; // делаем реальный указатель

# ;  free (sorting->Sorts);
# ;  free (sorting->Orign);
# ;  free (sorting->Array);

# ;  return;
# ;}
# ;-------------------------------------------------------------------------------


# ;#define BOT_VAR   int message, void *m, long long1, long long2, long long3, double d1
# ;#define BOT_RETURN return (1)

# ;-------------------------------------------------------------------------------
# ;///////////////////////////////////////////////////////////////////////////////
# ;-------------------------------------------------------------------------------
# ;T_BOT_RETURN
# ;sortbot_common (/* int message, void *m, long long1, long long2 */BOT_VAR)
# ;-------------------------------------------------------------------------------
proc sortbot_common {message m long1 long2 long3 d1} {

  #puts "message = $message"
  #set ret {}

  # (declare (ignore long2 long3 d1))
  
  # (let (
  # ;  T_SORTPROG sortprog = (T_SORTPROG) m;
  
  # ;  int  *Array = (int*) long1;
  # ;  int   Num = long2;
  #   )
  
  # ;  switch (message) {
  # ;  case Y_BEG:
  # ;    break;
  # ;  case YTODO:
  # ;  sortprog (Array, Num); 
  
  #   (unless (= message Y_BEG)
  #     (funcall m long1) ;  
  #     )

  if {$message != "Y_BEG"} {
    set ret [$m $long1]
    #puts "sortbot_common: m = $m  logn1 = $long1  ret = $ret"
    return $ret
  }

  # ; *** - APPLY: too many arguments given to #<COMPILED-FUNCTION QSORT_AF>

  # ;    break;
  # ;  default:
  # ;    ;;;
  # ;  }
  
}
# ;-------------------------------------------------------------------------------
# ;void 
# ;sort_by_one_bot (YT_BOT *bot, T_SORTING *s, char *message)
# ;-------------------------------------------------------------------------------
proc sort_by_one_bot {bot s message} {
  
  #puts "sort_by_one_bot ..."

  # ;  ai_copy (s->Array, s->Orign, s->Num);     
  #   (ai_copy (ARREY s) (ORIGN s) (NUM s))
  $s.ARREY = [$s.ORIGN]
  
  # ;  YT_PROG lbot = (YT_PROG) bot->long3;
  
  # ;  bot->prog (YTODO, lbot, (long)(s->Array), s->Num, 0,0);

  #   (funcall (YPROG bot) YTODO (LONG3 bot) (ARREY s) (NUM s) 0 0)
  
  set ret [[$bot.YPROG] YTODO [$bot.LONG3] [$s.ARREY] [$s.NUM] 0 0]
  
  $s.ARREY = $ret

  sorting_check_print $s $message
  
}
# ;-------------------------------------------------------------------------------
# ;void
# ;sorting_set_result (YT_PLAYER *player, double t) 
# ;-------------------------------------------------------------------------------
proc sorting_set_result {player tval} { 

  #   ;(format t "1--- ~%")
  #   (setf (SUM player) tval) ;  player->sum  = tval; 

  $player.SUM = $tval
  
  #   (setf (INT1 player) (TO_COUNT))
  #   (setf (INT2 player) (LG_COUNT))
  #   (setf (INT3 player) (+ (TO_COUNT) (LG_COUNT)))
  
  $player.INT1 = [TO_COUNT]
  $player.INT2 = [LG_COUNT]
  $player.INT3 = [expr {[TO_COUNT] + [LG_COUNT]}]
  
  #   ;(format t "2--- ~%")
}
# ;-------------------------------------------------------------------------------
# ;void 
# ;sorting_draw_line (YT_PLAYER *table, int i)
# ;-------------------------------------------------------------------------------
proc sorting_draw_line {players i} {

  # (let (
  #   tabl
  #   )
  
  #puts "sorting_draw_line: players = $players"

  #if {$i == 0} {}
  if {$players == "NUL"} {
    puts -nonewline " "
    puts -nonewline "   TO+LG   "
    puts -nonewline "    Time  "
    puts -nonewline "      TO  "
    puts -nonewline "      LG  "
    puts ""

  } else {

    # ;    printf (" %8d  " , table[i].int3); // TO+LG
    # ;    printf (" {%8.6f} ", table[i].sum);
    # ;    printf (" %8d "  , table[i].int1); // TO
    # ;    printf (" %8d "  , table[i].int2); // LG

    set pl [lindex $players $i]
    #puts "i= $i tabl= $tabl"
    
    #     (format t " ~7d  "    (INT3 tabl)) ; // TO+LG
    #     (format t " {~7,5f} " (SUM  tabl))
    #     (format t " ~7d "     (INT1 tabl)); // TO
    #     (format t " ~7d "     (INT2 tabl)); // LG

    puts -nonewline [format " %7d  "    [$pl.INT3]]  ;# // TO+LG
    puts -nonewline [format " {%7.5f} " [$pl.SUM]]
    puts -nonewline [format " %7d "     [$pl.INT1]]  ;# // TO
    puts -nonewline [format " %7d "     [$pl.INT2]]  ;# // LG

    puts ""
  }
  
}
# ;-------------------------------------------------------------------------------
# ;void 
# ;sorting_print_sort_results (Y_BOTTOP *top)
# ;-------------------------------------------------------------------------------
proc sorting_print_sort_results {top} {

  # ;  bottop_print_sort_results (top, SORT_MIN_MAX, /* SORT_0 */ SORT_3, sorting_draw_line);
  #   (bottop_print_sort_results  top  SORT_MIN_MAX  SORT_3  'sorting_draw_line)

  bottop_print_sort_results  $top  SORT_MIN_MAX  SORT_3  "sorting_draw_line"

}
# ;-------------------------------------------------------------------------------
# ;void
# ;sorting_calc_data (void *t, /* YT_BOT* bot */void *p) 
# ;-------------------------------------------------------------------------------
# ;(defun sorting_calc_data (tval  p) 
proc sorting_calc_data {top  bot} { 

  # (let* (
  #   ;(top tval) ;  Y_BOTTOP *top = (Y_BOTTOP *) t;
  #   ;(bot p)    ;  YT_BOT* bot = (YT_BOT *) p;
  
  # ;  T_SORTING *sorting = (T_SORTING *) top->dat; // делаем реальный указатель
  #   (sorting (DAT top))
  set sorting [$top.DAT]
  
  #   Num Sorts Orign num_randoms sorted reversed 
  #   )
  
  #   ;(format t "..... ~s ~%" (YPROG bot))
  # ;  bot->prog (Y_BEG, sorting, bot->long1, bot->long2, 0,0);
  #   (funcall (YPROG bot) Y_BEG sorting (LONG1 bot) (LONG2 bot) 0 0) 

  [$bot.YPROG] Y_BEG $sorting [$bot.LONG1] [$bot.LONG2] 0 0
  
  # ;  //sorting_begin (sorting, 0,0);
  #ai_initialize [$sorting.SORTS] [$sorting.NUM]

  set Num [$sorting.NUM]
  $sorting.SORTS = [ai_initialize_new $Num]
  
  #puts "sorting.SORTS = [$sorting.SORTS]"
  #exit
  # ;  //------------------------------ 
  
  #   (setf Num (Num sorting))
  # ;  //int *Array = sorting->Array; 

  #   (setf Sorts (SORTS sorting)) 
  #   (setf Orign (ORIGN sorting)) 
  
  #set Sorts [$sorting.SORTS]
  #set Orign [$sorting.ORIGN]

  # ;  //int num_randoms = data_bot->long2;

  set num_randoms [$sorting.NUM_RANDOMS]
  set sorted      [$sorting.SORTED]
  set reversed    [$sorting.REVERSED]
  
  #puts "num_randoms = $num_randoms"
  #puts "sorted      = $sorted"
  #puts "reversed    = $reversed"

  TO_RESET
  LG_RESET
  
  # ;  // будем сортировать случайные наборы
  #   (when  (> num_randoms 0) 
  
  #dotimes {$n $num_randoms} {}
  for {set n 0} {$n < $num_randoms} {incr n} {
    puts "n = $n"
    #       (ai_copy Orign Sorts Num)
    #set Orign $Sorts
    #       (ai_randomize Orign Num)   ;    /* Perform some shuffling */  
    #       (sort_by_one_bot bot sorting "....")
    #       )
  }
  
  # ;  // будем сортировать уже отсортированные
  #   (when (> sorted 0) 
  #     (ai_copy  Orign Sorts Num)       
  #     (sort_by_one_bot  bot sorting "--->")
  #     )
  
  # ;  // теперь попробуем уже отсортированные в обратном порядке
  if  {$reversed >  0} {
    #     (ai_copy  Orign Sorts Num)       
    #set Orign $Sorts
    #     (ai_reverse Orign Num)  
    #set Orign [ai_reverse_new $Orign]
    #set Orign [lreverse $Orign]

    $sorting.ORIGN = [lreverse [$sorting.SORTS]]

    #ai_print $Orign     
    #ai_print $Sorts  
   
    sort_by_one_bot  $bot $sorting "<---"
  }
  
  # ;  //----------------------------
  # ;  //sorting_end (s); 
  
}
# ;-------------------------------------------------------------------------------
# ;/* void  */
# ;/* sortbot_print_name (void *s) */
# ;/* { */
# ;/*   YT_BOT *bot = (YT_BOT *) s; */

# ;/*   printf ("%s ", b_prog_get_name ((Bprog *) bot));  */

# ;/*   return; */
# ;/* } */
# ;-------------------------------------------------------------------------------
# ;/* Y_BOTTOP * */
# ;/* sort_bottop_create_old ()  */
# ;/* { */

# ;/*   Y_BOTTOP *top = bottop_create (20); */

# ;/*   YT_PROG sbot = sortbot_common; */

# ;/*   bottop_add_bot (top, "bubblesort"       , sbot, 0,0,  (long) bubblesort,       0); */
# ;/*   bottop_add_bot (top, "shakersort"       , sbot, 0,0,  (long) shakersort,       0); */
# ;/*   bottop_add_bot (top, "s_insertion_swap" , sbot, 0,0,  (long) s_insertion_swap, 0); */
# ;/*   bottop_add_bot (top, "s_insertion_take" , sbot, 0,0,  (long) s_insertion_take, 0); */
# ;/*   bottop_add_bot (top, "s_selection"      , sbot, 0,0,  (long) s_selection,      0); */
# ;/*   bottop_add_bot (top, "shellsort_AF"     , sbot, 0,0,  (long) shellsort_AF,     0); */
# ;/*   bottop_add_bot (top, "qsort_AF"         , sbot, 0,0,  (long) qsort_AF,         0); */
  

# ;/*   return (top); */
# ;/* } */
# ;-------------------------------------------------------------------------------
# ;Y_BOTTOP *
# ;sort_bottop_create () 
# ;-------------------------------------------------------------------------------
proc sort_bottop_create {} { 

  # (let (
  # ;  Y_BOTTOP *top = bottop_create (20);
  set top [bottop_create 20]
  
  # ;  YT_PROG sbot = sortbot_common;
  set sbot "sortbot_common"
  #   )
  
  
  # ;  bottop_add_player (top, "bubblesort", bot_make (sbot, 0,0, (long) bubblesort,  0));
  # ;  bottop_add_player (top, "shakersort", bot_make (sbot, 0,0, (long) shakersort,  0));
  
  # ;  bottop_add_player (top, "s_insertion_swap" ,
  # ;                     bot_make (sbot, 0,0,  (long) s_insertion_swap, 0));
  # ;  bottop_add_player (top, "s_insertion_take" ,
  # ;                  bot_make (sbot, 0,0,  (long) s_insertion_take, 0));
  # ;  bottop_add_player (top, "s_selection"      ,
  # ;                  bot_make (sbot, 0,0,  (long) s_selection,      0));
  # ;  bottop_add_player (top, "shellsort_AF"     ,
  # ;                  bot_make (sbot, 0,0,  (long) shellsort_AF,     0));
  
  # ;  bottop_add_player (top, "qsort_AF"         ,
  # ;                  bot_make (sbot, 0,0,  (long) qsort_AF,         0));
  
  bottop_add_player  $top "qsort_AF" [bot_make $sbot 0 0 "qsort_AF" 0]
  
  # ;  //bottop_add_bot (top, "heapsort_gsl", heapsort_gsl);
  # ;  //bottop_add_bot (top, "qsort_unix" , qsort_unix);
  
  return $top
}
# ;-------------------------------------------------------------------------------
# (defun sort_main_44 (argus)  (declare (ignore argus))

# (let* (
# ;  Y_BOTTOP *top = sort_bottop_create (); 
#   (top (sort_bottop_create))

#   (Orign '(44 55 12 42 94 18  6 67))
#   (Sorts '( 6 12 18 42 44 55 67 94))

# ;  int Num = sizeof (Orign)/sizeof (Orign[0]);
#   (Num (list-length Orign))
# ;  int  i;

# ;  T_SORTING *s = sorting_create ("", Num, 0,0,0);
#   (s  (sorting_create "" Num 0 0 0))
#   )

#   (setf (ORIGN s) Orign) ;  s->Orign = Orign;
#   (setf (SORTS s) Sorts) ;  s->Sorts = Sorts;
#   (setf (DAT top) s) ;  top->dat = s;

# ;  for (i = 1; i <= top->num_players; i++) {
#   (loop for i from 1 to (NUM_PLAYERS top) do
# ;    sort_by_one_bot (IGROK(i)->bot, s, "");
#     (sort_by_one_bot (BOT (IGROK i)) s "")
#     )

#   (format t "~%")

# ))
# ;===============================================================================
# ;-------------------------------------------------------------------------------
proc sort_bottop_init_03 {top} {

  # ;e~test sort 100 - 2 1 1
  
  # (let* (
  #   sorting
  # ;  int  Num, num_randoms, sorted, reversed;
  
  set Num  10 ;#  Num  = atoi (argv[j++]); // 100
  #   ;(flag '-)  ;  char *flag = argv[j++];  // - 
  
  # ;  if (!strcmp (flag, "+")) BOTPRINT = TRUE;
  # ;  else                     BOTPRINT = FALSE;
  
  set num_randoms 0 ;#  num_randoms = atoi (argv[j++]); // 2
  set sorted      0 ;#  sorted      = atoi (argv[j++]); // 1
  set reversed    1 ;#  reversed    = atoi (argv[j++]); // 1
  #   )
  
  #   (bottop_init  top 0 ;/* SRAND_TIME */
  #                'sorting_set_result 'sorting_print_sort_results

  #                NUL NUL NUL 
  #                NUL NUL NUL
  
  #                'sorting_calc_data 
  #                )
  
  bottop_init  $top 0 \
                  "sorting_set_result" "sorting_print_sort_results" \
                  \
                  NUL NUL NUL \
                  NUL NUL NUL \
                  \
                  "sorting_calc_data" 
                  
  
  # ;  T_SORTING *sorting = sorting_create ("MIXEDSORT", Num, 
  # ;                                       num_randoms,sorted,reversed);
  # ;  top->dat = sorting;
  
  set sorting [sorting_create "MIXEDSORT" $Num \
                 $num_randoms $sorted $reversed]

  #   (setf (DAT top) sorting)
  $top.DAT = $sorting
  
}
# ;-------------------------------------------------------------------------------
# ;void
# ;sort_main_03 (int argc, char** argv, int j)
# ;-------------------------------------------------------------------------------
proc sort_tabs {} {

  # (let (
  # ;  Y_BOTTOP *top = sort_bottop_create (); 
  #   (top  (sort_bottop_create))
  #   )
  
  set top [sort_bottop_create] 

  sort_bottop_init_03  $top
  
  bottop_prog_data  $top
  
}
#===============================================================================
#===============================================================================
#===============================================================================
#===============================================================================
