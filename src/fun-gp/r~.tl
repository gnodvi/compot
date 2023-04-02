# -*-   mode: tcl  ; coding: koi8   -*- ----------------------------------------

#!/bin/sh
# \
exec tclsh "$0" ${1+"$@"}
#
#-------------------------------------------------------------------------------


#set COMPOT "./COMPOT"
# set auto_path [linsert $auto_path 0 "COMMON"]

#lappend auto_path \
  [file join [file dirname [info script]] "."] ;# "COM" "../common"


set auto_path [linsert $auto_path 0 "COMMON"]
package require compot::common 

package require tcltest

# source "b-com0.tl"
# source "b-com1.tl"

#-------------------------------------------------------------------------------
#
#-------------------------------------------------------------------------------
proc NEXT_sorted {} {

  set res {{1 one} {3 three} {2 two}}

  # сортируем по 1-му элементу списков

  set sorted [lsort -integer -index 0 $res]

  puts ""
  puts "res origin = $res"
  puts "res sorted = $sorted"

}
#-------------------------------------------------------------------------------
#
#
# ~/.pilot/s/compot/genpro$ j~.tl JOY2 TEST_main b__01.joy 
#
# OPEN_FNAME not find file TEST_main in all PATHS !!
#
# ------------------------------------------------------------------------------
#
#-------------------------------------------------------------------------------
proc ALIB {} {

  source "r_ants.tl"

  global argc argv

  eval [lindex $argv 1] ;# вызываем вспомогательную секонд-функцию

}
#-------------------------------------------------------------------------------
proc ANTS {} {

  source "j-0000.tl"  ;# общие части
  source "j-1111.tl"  ;# надо будет подключить и ко всем примерам!!
  source "j-2222.tl"  ;
  source "j-3333.tl"  ; #  ????? dict_create

  source "j-prog.tl"
  source "p-corE.tl" 

  #source "t-proJ.tl"  ;# GP, и тесты на Tcl (типа Koza-Lisp)
  source "r_ants.tl"

  global argc argv

  eval [lindex $argv 1] ;# вызываем вспомогательную секонд-функцию

}
#-------------------------------------------------------------------------------
# proc COMM {} {

#  source "f-prog.tl"
#   source "g-corE.tl"
  
#   global argc argv

#   incr ::ind0

#   eval [lindex $argv 1] ;# вызываем вспомогательную секонд-функцию

# }
#-------------------------------------------------------------------------------
#
# Типичный пример. Выявлем (раскручиваем) программу, вычисляющую квадрат числа.
# Лучшая програма :  "DUP *"
# Лучший фитнес == 2 (нет ошибок для любых входов, длина проги == 2).
#
#-------------------------------------------------------------------------------
proc FITPROC_xx_NEW {prog task args} {

  set is_print [dict_parse $args "-is_print"   0]

  set x_list [get_x_list  0 2  10]

  #puts "x_list = $x_list"
  #exit

  # ???? 
  # 
  set func [GET $task "func"]
  #set joyf [GET $task "joyf"]

  # начинаем в цикле подсчет фитнеса --------------------------

  #set is_print 0

  if {$is_print} {
    puts stderr ""
    puts stderr "-------------------------------------------------------------------"
    puts stderr ""
    puts stderr "FITPROC_xx: x_list = $x_list"
    puts stderr "FITPROC_xx: func   = $func"
    #puts stderr "FITPROC_xx: joyf   = $joyf"
    puts stderr ""
  }

  set fitness 0

  set delta_sum 0 ;# будем суммировать отклонения в точках или их квадраты



  foreach x $x_list {

    #---------------------------------------------------------------

    set real [expr $func] ;# рельное значение для функции в этой точке

    ##run_v1_src $joyf     ;# выполнить исходник

    # обнудим стек, выполним программку и возьмем результат (верхний эдемент стека)
    # 
    set calc [getresult_prog_val  $prog $x] ;# посчитанное
 
    #---------------------------------------------------------------

    set len [llength $::joy_ST] ;# сколько еще осталось в стеке значений ??

    #puts stderr "::joy_ST = $::joy_ST,  len = $len"
    #puts "calc = $calc"

    #set delta_sum 0 ;# будем суммировать отклонения в точках или их квадраты

    if {$is_print} {
      puts stderr "x = $x, calc = |$calc|, ::joy_ST = |$::joy_ST|"
    }
    #---------------------------------------------------------------
    #

    if {$calc eq {}}  {

      if {$is_print} {
        puts stderr "FITPROC_xx: x = $x, calc eq {} , ERROR operator??"
      }
      # ошибка программы (на первом ошибочном операторе) !!
      # 
      # можно бы попробовать гибкую реакци. на "неверные" операторы программы, т.е.
      # не вываливаться сразу в ошибку, а продолжать выпонять остальные операторы !
      #
      # но пока просто даим не слишком большой штраф, в пределах дельта-ошибок
      
      incr fitness 25 ;# 10 50 150
      #
      # может сразу выходить из цикла по точкам, они же все такие будут?
      break

    } elseif {![string is integer $calc] && ![string is double $calc]} {

      # здесь может быть просто списко или символ-строка, а не число!
      # но пока кроме числе и {ошибки} в стеке ничего не предвидится
      #
      puts "FITPROC_xx: NOT DIGITAL ???? !!!"
      exit

      incr fitness 50 ;# при каждой ошибке добавляем дельту
      # 
      # может сразу выходить из цикла по точкам, они же все такие будут?
      break

    } else {

      #set delta [expr {abs($o-$calc)}] ;# 
      set delta [expr {( $real - $calc ) ** 2 } ] ;# !! может корень из суммы квадратов?

      #if {$delta > 1000} {
      #  # anti overflow ???
      #  set delta 1000
      #}

      set delta_sum [+ $delta_sum $delta]

      if {$is_print} {
        puts stderr "FITPROC_xx: x = $x, real = $real, calc = $calc, delta = $delta, delat_sum = $delta_sum"
      }

      #set fitness [+ $fitness $delta]
    }
    #---------------------------------------------------------------

  }
    
  #set fitness [+ $fitness $delta_sum]
  set fitness [expr {$fitness + sqrt ($delta_sum)}]

  # 1) TODO
  # длину учитывать ? но тогда генетич. разнообразие ухудшается?
  #
  set len [calc_len_prog $prog]

  #set fitness [+ $fitness [* 0.01 $len]]


  # 2) TODO
  # нам не нужны лишние результаты в стеке ? тоже ухудшает? лучше потом преобразовать?
  #
  #incr fitness $len


  #puts stderr "FITPROC_xx, prg = $src, fitness = $fitness"

  return $fitness
}
#-------------------------------------------------------------------------------
proc TEST_xx_SIMP {args} {

  set argv $args

  puts ""
  puts "TEST_xx $args"
  puts ""

  #------------------------------------------------------

  set seed       @   ;# каждый выхов случаен

  set lpop      10   ;# колич-во ботов 
  set size       6   ;# макс. длина ботов (при начальном старте?)
  set nums      10   ;# шагов эволюции 

  set print       [dict_parse $argv "-print"    1]
  set ::is_print  $print

  set fit_func     "FITPROC_xx_NEW" 
  set fit_tobest   "MIN"

  #------------------------------------------------------

  set ::INIT  [dict_parse $argv "-init"   0] 

  ;# 0 - не делаем специально начальеую инициацию
  ;# 1 - кладем сразу начальное значение x в стек несколько раз с запасом dup dup dup

  if {$::INIT} {
    set gp_list     [dict_parse $argv "-list"   "* nop +"]
  } else {
    set gp_list     [dict_parse $argv "-list"   "dup * +"]
  }

  #------------------------------------------------------

  set func   {$x ** 2 + $x}

  #set func        [dict_parse $argv "-func"   {x pow 2 plus x}]
  #set func [func_prepare_from_input $func] 

  set joyf        [dict_parse $argv "-joyf"   {dup dup * +}]
  #puts "joyf = $joyf"

  #------------------------------------------------------
  # флажки для новейших алгоритмов
  # 
  # 
  set ::NEWS      [dict_parse $argv "-news"  $::NEWS]
  set ::AUTO      [dict_parse $argv "-auto"  $::AUTO]
  set ::DEEP      [dict_parse $argv "-deep"  $::DEEP]
  
  ios_init_TEST_xx 

  v1_init_all  ;# !!!!!!!!!!! ???

  set task [task_create  \
	      -ios_begin 1 -ios_final 1 \
              -fit_func $fit_func  -fit_tobest $fit_tobest \
              -func       $func \
              -gp_list    $gp_list\
             ] 
  
  # задаем начальную "случайность"
  
  if {$seed == "@"} {set seed [clock seconds]}
  
  comm_random_seed $seed 

  #comm_random_seed [clock seconds]  


  # распечатаем начальные значения

  puts "func = $func"
  puts "seed = $seed"
  puts "init = $::INIT"
  puts "list = $gp_list"


  #------------------------------------------------------
  #
  # запускаем эволюцию GP напрямую, через функцию

  run_gp_evolution_for_task $task $seed \
    -lpop $lpop  -size $size -nums $nums  


  puts ""
  puts "===================================================================="

  
  return
}
#-------------------------------------------------------------------------------
proc TEST {} {

  source "p-corE.tl" 
  source "r_test.tl" 
  
  global argc argv

  incr ::ind0 ;# указатель следуюшему обработчику, откуда начинать парсить


  set next_prog [lrange $argv 1 end] 

  if {$next_prog != ""} {

    # вызываем вспомогательную секонд-функцию с параметрами
    #eval [lindex $argv 1] [lrange $argv 2 end] 

    eval $next_prog
    return;
  }

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  set fit_func     "FITPROC_xx_NEW"
  set fit_tobest   "MIN"

  #set target_funtion "x pow 3 plus x"
  set target_funtion "x pow 2 plus x"


  TEST_xx_SIMP    -nums -1 -news 1 -func $target_funtion -print 1 \
    -init 0 \
    -fit_func $fit_func  -fit_tobest $fit_tobest \
    -list "dup * +" 

  # NEXT_01 -seed @ -lpop 5 -size 2 -nums -1 -list "p1 p3 p5" 

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  return
}
#-------------------------------------------------------------------------------
#
#-------------------------------------------------------------------------------

set CUR_DIR "r"
  
READ_AND_CALL_ARGUS  $CUR_DIR

puts "" 

#-------------------------------------------------------------------------------

# r:r~.tl,TEST,TEST_xx,,-seed,0,-lpop,5,-size,6,-nums,-1,-print,2 ................ PASSED
# r:r~.tl,TEST,TEST_xx,,-seed,2013,,-lpop,10,-size,6,-nums,10 ................ PASSED


#-------------------------------------------------------------------------------

# r~.tl TEST TEST_nn  2013 9 6 1 @  ???????

# -) Усложнить задачи. (ANTS) задавая более сложные рисунки в т.ч. и динамически 
#    меняющиеся; а также  с постепенным усложнением; кроме того, сделать эвлюцию
#    "жизни мурашей" в реальном времени;

#-------------------------------------------------------------------------------
# 
# r~.tl ANTS ANTS_test_shalito_joy 50
# r~.tl ANTS ANTS_test_shalito_joy  0 - в интерактивном виде !!
# r~.tl ANTS ANTS_test_simple_joy

# r~.tl ANTS ANTS_gp @  10 15 2
# 
# r~.tl ANTS ANTS_t2

# r~.tl ANTS ANTS_test_shalito_old
# r~.tl ANTS ANTS_test_simple_old

#-------------------------------------------------------------------------------
#
#-------------------------------------------------------------------------------
