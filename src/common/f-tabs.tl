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
  mysrand $seed 
  
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
# ;===============================================================================
