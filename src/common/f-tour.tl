# -*-   mode: tcl  ; coding: koi8   -*- ----------------------------------------

#===============================================================================
# *                                                                            *
# *  Имя этого файла: e_tour.c                                                 *
# *                                                                            *
#===============================================================================
                                                                            
# ;#include "a_comm.h"

# ;#include "e_tabs.h"
# ;#include "e_tour.h"

# ;===============================================================================

# package require TclOO;  #if loading for the first time

# oo::class create summation {
#     constructor {} {
#         variable v 0
#     }
#     method add x {
#         variable v
#         incr v $x
#     }
#     method value {} {
#         variable v
#         return $v
#     }
#     destructor {
#         variable v
#         puts "Ended with value $v"
#     }
# }

# set sum [summation new]

# puts "Start with [$sum value]"

# for {set i 1} {$i <= 10} {incr i} {
#     puts "Add $i to get [$sum add $i]"
# }

#-------------------------------------------------------------------------------
#   ITCL   ITCL   ITCL   ITCL   ITCL   ITCL   ITCL
#-------------------------------------------------------------------------------

# package require Itcl
# namespace import itcl::*

#-------------------------------------------------------------------------------
# proc class_example1 {} {

#   class helloworld {
#     public variable owner "No-one"
    
#     eval makegetset  foo zoo
#     #eval makegetset {foo 9}
#     #eval makegetset {ownerr 11}

#     method greet {} { puts "Hello World from $owner" }
#   }

#   helloworld  h1
#   helloworld  h2

#   h1 greet
#   h1 configure -owner Me
#   h2 configure -owner You
#   h1 greet
#   h2 greet

#   #puts "owner = $owner" ;# can't read "owner": no such variable
#   #puts "owner = $owner" 

#   puts "foo = [h1 getfoo]" 
#   h1 setfoo  100
#   puts "foo = [h1 getfoo]" 
#   #puts "zoo = [h1 getzoo]" 
#   h1 setfoo  200
#   puts "foo = [h1 getfoo]" 

#   #unset helloworld - как бы убрать класс?
# }

# puts ""
# class_example1 

# ;===============================================================================

# (defconstant  fw 4) ;#define fw         4       /* field width for printed numbers */

# ;typedef int (*YT_GAME_FUNC) (/* YT_PROG prog1, YT_PROG prog2, */ void *bot1, void *bot2);

#---------------------------------------

# (defclass YT_TURNIR () (
# ;  Y_BOTTOP   *bottop;
#   (bottop :accessor BOTTOP)

# ;  YT_GAME_FUNC play_game;
# ;  YT_BOOL is_double_play;
#   (play_game      :accessor PLAY_GAME)
#   (is_double_play :accessor IS_DOUBLE_PLAY)

# ))

#---------------------------------------
#class YT_TURNIR {}
record define YT_TURNIR {
   
  # да не, не будем так подка делать, воспользуемся стандартными средствами
  # cget/configure
  # 
  #eval makegetset  BOTTOP PLAY_GAME IS_DOUBLE_PLAY

  BOTTOP    ;# public variable BOTTOP  
  PLAY_GAME ;# public variable PLAY_GAME 
  IS_DOUBLE_PLAY ;# public variable IS_DOUBLE_PLAY 

}
#---------------------------------------

#---------------------------------------
#package require TclOO

# oo::class create YT_TURNIR {
#     constructor {} {
#         variable BOTTOP          0     
#         variable PLAY_GAME       0   
#         variable IS_DOUBLE_PLAY  0    
#     }

#     method getbottop {} {
#         variable BOTTOP
#         return $BOTTOP
#     }

# }
#---------------------------------------


# (defconstant GAME_WIN  102)
# (defconstant GAME_DRA  101)
# (defconstant GAME_LOS  100)

# ;// -----------------------------------

# ;typedef struct {
# ;  char *name;
# ;  int   place;
# ;  int   d[10];
# ;} YT_RESULTS;

# ;===============================================================================

#-------------------------------------------------------------------------------
# ;YT_TURNIR* 
# ;turnir_create (int max_players, YT_GAME_FUNC play_game, YT_BOOL is_double_play)
#-------------------------------------------------------------------------------
proc turnir_create {max_players play_game is_double_play} {

# ;  YT_TURNIR *tur = (YT_TURNIR*) malloc (sizeof (YT_TURNIR));
#   (tur (make-instance 'YT_TURNIR))

  #set tur [YT_TURNIR new]
  #YT_TURNIR tur
  set tur [YT_TURNIR #auto]

#   puts "foo = [tur getfoo]" 
#   tur setfoo  100
#   puts "foo = [tur getfoo]" 
  
# ;  tur->bottop = bottop_create (max_players);
#   (setf (BOTTOP tur)  (bottop_create max_players))
  $tur configure -BOTTOP [bottop_create $max_players]


# ;  tur->play_game = play_game;
# ;  tur->is_double_play = is_double_play;
#   (setf (PLAY_GAME tur)      play_game)
#   (setf (IS_DOUBLE_PLAY tur) is_double_play)
  $tur configure -PLAY_GAME       $play_game
  $tur configure -IS_DOUBLE_PLAY  $is_double_play

  return $tur
}
#-------------------------------------------------------------------------------
# ;void 
# ;turnir_add_player (YT_TURNIR *tur, char *name, void *bot)
#-------------------------------------------------------------------------------
proc turnir_add_player {tur name bot} {

  bottop_add_player [$tur cget -BOTTOP] $name $bot

}
#-------------------------------------------------------------------------------
proc turnir_print {tur} {

  puts "TURNIR PRINT ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
  puts ""
 
  set bottop [$tur cget -BOTTOP]

  puts "BOTTOP    = $bottop"
  puts "PLAY_GAME = [$tur cget -PLAY_GAME]"
  puts "IS_DOUBLE_PLAY = [$tur cget -IS_DOUBLE_PLAY]"

  puts ""
  bottop_print $bottop
  puts ""

  puts "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
  puts ""

  return
}
# ;-------------------------------------------------------------------------------
# ;void 
# ;turnir_init (YT_TURNIR *tur, int seed)
# ;-------------------------------------------------------------------------------
proc turnir_init {tur seed} {


  bottop_init [$tur cget -BOTTOP] $seed  NUL NUL NUL NUL NUL  NUL NUL NUL  NUL

}
#-------------------------------------------------------------------------------
proc player_print {pl} {


  puts "PLAYER PRINT ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
 
  puts " SUM = [$pl cget -SUM]"
  puts "INT1 = [$pl cget -INT1]"
  puts "INT2 = [$pl cget -INT2]"
  puts "INT3 = [$pl cget -INT3]"

  return
}
#-------------------------------------------------------------------------------
proc turnir_draw_line {pl i} {


  #if {$i == 0} { }
  if {$pl == "NUL"} { 
    puts "   total    +   =   - "
    return
  } 
    
  puts -nonewline [format "%6d" [$pl cget -SUM]]

  puts -nonewline [format "   %3d %3d %3d " \
                     [$pl cget -INT1] [$pl cget -INT2] [$pl cget -INT3]]
  
  puts ""
  
}
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
proc turnir_play {tur is_double_play} {

  set top     [$tur cget -BOTTOP]
  set players [$top cget -NUM_PLAYERS]
  #   signum         ;  char signum;
  
  #   j0 result      ;  int  i, j, j0, result;
  #   p_i  p_j       ;  YT_PLAYER  *pi, *pj;
  #   bi  bj         ;  YT_BOT     *bi,  *bj; //!!!! новое 
  
  # надо прeдваритeльно занулить суммы

  #for {set i 1} {$i <= $players} {incr i} {}
  for {set i 0} {$i < $players} {incr i} {

    set p_i [lindex [$top cget -TT] $i] 
    $p_i configure -SUM 0               
    #setTTind $top $i $p_i 
  }
    
  # а тeпeрь ужe рeальный пeрeбор .........

  #for {set i 1} {$i <= $players} {incr i} {}
  for {set i 0} {$i < $players} {incr i} {
    
    set p_i [lindex [$top cget -TT] $i]
    set b_i  [$p_i cget -BOT] 
    
    if {$is_double_play} {
      #set j0 1
      set j0 0
    } else {
      set j0 [expr {$i + 1}]
    }

    puts -nonewline  [format " %2d %-18s " $i [$p_i cget -PLAYER_NAME]]

    #  ------------------------------
    #for {set j $j0} {$j <= $players} {incr j} {}
    for {set j $j0} {$j < $players} {incr j} {

      set p_j [lindex [$top cget -TT] $j]
      set b_j  [$p_j cget -BOT] 

      # вызываем на матч две программы, по их процедурным именам
      # а надо бы всего бота вызывать ?? !!

      set result [[$tur cget -PLAY_GAME] $b_i $b_j]
      
      # 2 очка за победу, 1 за ничью (как раньше в футболе)
      
      if {$result == "GAME_WIN"} {
        incr [$p_i vget -INT1]  ;  incr [$p_i vget -SUM] 2
        incr [$p_j vget -INT3]  ;  incr [$p_j vget -SUM] 0 ;# для проигравшего
        set signum "+"
      }
      
      if {$result == "GAME_DRA"} {
        incr [$p_i vget -INT2]  ;  incr [$p_i vget -SUM] 1
        incr [$p_j vget -INT2]  ;  incr [$p_j vget -SUM] 1 ;# для проигравшего
        set signum "="
      }
      
      if {$result == "GAME_LOS"} {
        set signum "-"
        incr [$p_i vget -INT3]  ;  incr [$p_i vget -SUM] 0
        incr [$p_j vget -INT1]  ;  incr [$p_j vget -SUM] 2 ;# для проигравшего
      }
      
      puts -nonewline "$signum"
    }

    puts ""

  }

}
# ;===============================================================================
# ;int d_min = -7, d_max = 7;

# (defconstant d_min -7)
# (defconstant d_max +7)
set ::d_min -7
set ::d_max +7

# ;-------------------------------------------------------------------------------
# ;//T_BOT_RETURN
# ;int
# ;bot1 (/* BOT_VAR */)
# ;-------------------------------------------------------------------------------
proc bot1 {} {

  #global d_min d_max

# (let (
#   (d  (YRAND d_min d_max))
  set d [myrand $::d_min $::d_max]
#   )

#   (+ 10 d)
  return [expr {10 + $d}]
}
#-------------------------------------------------------------------------------
proc bot2 {} {

  set d [myrand $::d_min $::d_max]

  return [expr {20 + $d}]
}
#-------------------------------------------------------------------------------
proc bot3 {} {

  set d [myrand $::d_min $::d_max]

  return [expr {30 + $d}]
}
#-------------------------------------------------------------------------------
proc bot4 {} {

  set d [myrand $::d_min $::d_max]

  return [expr {40 + $d}]
}
#-------------------------------------------------------------------------------
proc bot5 {} {

  set d [myrand $::d_min $::d_max]

  return [expr {50 + $d}]
}
#-------------------------------------------------------------------------------
# Играем матч между двумя ТЕСТОВЫМИ игроками 
#-------------------------------------------------------------------------------
proc test_turnir_play {b1 b2} {


  set p1 [$b1]
  set p2 [$b2]

  #   (cond 
  #    ((>  p1 p2 ) (setf result GAME_WIN))      
  #    ((<  p1 p2 ) (setf result GAME_LOS))       
  #    (t           (setf result GAME_DRA))
  #    ) 
  # здесь бы надо реализовать функцию (макрос?) cond ??
  #

  if       {$p1 > $p2} {set result GAME_WIN
  } elseif {$p1 < $p2} {set result GAME_LOS
  } else               {set result GAME_DRA}
  
  #   ;(format t "~% p1= ~2s  p2= ~2s  result= ~s ~%" p1 p2 result) 
  
  return $result
}
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
proc turnir_calc {tur tur_nums seed} {

  turnir_init  $tur $seed

  for {set n 0} {$n < $tur_nums} {incr n} {

    turnir_play  $tur [$tur cget -IS_DOUBLE_PLAY]
  }

  puts ""
  puts ""

  #turnir_print $tur

  #bottop_sort_results_old [$tur cget -BOTTOP]  $::SORT_MAX_MIN $::SORT_0
  bottop_sort_results_old [$tur cget -BOTTOP]  $::SORT_MAX_MIN "SORT_0"

  #turnir_print $tur

  bottop_print_results    [$tur cget -BOTTOP] turnir_draw_line

}
# ;-------------------------------------------------------------------------------
# ;void 
# ;test_turnir (int tur_nums, int seed)
# ;-------------------------------------------------------------------------------
proc test_turnir {tur_nums seed} {

  set tur [turnir_create  50 "test_turnir_play" t] 

  turnir_add_player  $tur "bot1" bot1
  turnir_add_player  $tur "bot2" bot2
  turnir_add_player  $tur "bot3" bot3
  turnir_add_player  $tur "bot4" bot4
  turnir_add_player  $tur "bot5" bot5

  turnir_calc  $tur $tur_nums $seed

}
# ;-------------------------------------------------------------------------------
# ;-------------------------------------------------------------------------------
# ;void
# ;turnir_parse_cmdline (int argc, char** argv, int j, 
# ;                      int *p_seed, int *p_nums)
# ;{
# ;  if (argc == j) {
# ;    printf ("Need argument(s): \n");
# ;    printf ("<seed> <tur_nums> \n");
# ;    return;
# ;  }

# ;  *p_seed = atoi (argv[j]); 
# ;  j++;
# ;  *p_nums = atoi (argv[j]); 

# ;  return;
# ;}
#-------------------------------------------------------------------------------
# ;void
# ;tour_main (int argc, char** argv, int j)
#-------------------------------------------------------------------------------
# (defun tour_main (argus)  (declare (ignore argus))
proc tour_main {} {

# ;  int seed;
# ;  int tur_nums; 

# ;  turnir_parse_cmdline (argc, argv, j, &seed, &tur_nums);
# ;  test_turnir (tur_nums, seed);

  test_turnir 1 2010
}
# ;===============================================================================


