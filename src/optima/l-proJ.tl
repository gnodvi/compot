# -*-   mode: tcl  ; coding: koi8   -*- ----------------------------------------

#-------------------------------------------------------------------------------
# FOR JOY
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
proc v1_get_result_from_one_arg {prg_11 val} {

  # кладем одно значение в стек
  # 
  push $val 

  # выполняем программку
  # 
  #run_v1_src_or_prog $prg_11 ;### $prog_11
  run_v1_src $prg_11

  # забираем одно значение из стека
  # 
  set result [pop]


  return $result
}
#-------------------------------------------------------------------------------
# кладем один аргумент в стек и выполняем joy-программу
#
# proga - обобщенное название программы, там могут быть разные варианты (типы) 
#
#-------------------------------------------------------------------------------
proc getresult_prg_val_11 {prg_11 val} {


  #convert_22_to_11  $prg_22 prg_11
  #set prg_11 $prg_22 ;# ??

  v0_set_stack_null ;# и не более того !!!!

  #-----------------------------------------------------------------
  if {0} {
  #-----------------------------------------------------------------

    # да вроде уже отлавливаем на уровне команд
    # 
    # отлпаливаем аварийное завершение целиком полность программы !?
    # 
    
    if {[catch {set result [v1_get_result_from_one_arg  $prg_11 $val]} err ]} {
      
      if {$::error_print1} {
        puts stderr "r_error_print1: getresult_prg_val_11: err = $err"
        puts stderr ""
      }
      
      return {}
    } else {
      return $result
    }

  #-----------------------------------------------------------------
  } else {
  #-----------------------------------------------------------------

    set result [v1_get_result_from_one_arg  $prg_11 $val]

    return $result

  #-----------------------------------------------------------------
  }
  #-----------------------------------------------------------------


}
#-------------------------------------------------------------------------------
proc getresult_prog_val {prog val} {


  v0_set_stack_null ;# и не более того !!!!
  
  # кладем одно значение в стек
  # 
  push $val 

  # выполняем программку
  # 
  run_v1_prog $prog

  # забираем одно значение из стека
  # 
  set result [pop]


  return $result
}
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
proc calc_12345_results {prg_11} {


  #convert_22_to_11  $prg_22 prg_11
  #set prg_11 $prg_22

  v0_set_stack_null ;# и не более того !!!!

  foreach i {1 2 3 4 5}  {

    set res [v1_get_result_from_one_arg  $prg_11 $i]

    lappend results $res
  }

  return $results
}
#-------------------------------------------------------------------------------
proc check_tranform_s {trans_rule_s  prg1  calc_proc} {

  # делаем новую трансформированную программу
  # 
  set prg2 [get_transform_s  $prg1 $trans_rule_s]
  

  set res1 [eval {$calc_proc $prg1}] ;# результаты по исходной проге
  set res2 [eval {$calc_proc $prg2}] ;# по трансормной

  # puts ""
  puts "prg1 = $prg1"
  puts "prg2 = $prg2"
  puts ""

  puts "res1 = $res1"
  puts "res2 = $res2"
  puts ""

  if {[string equal $res1 $res2]} {
    puts "OK .... !!!!"
  } else {
    puts "NO .... (((("
  }

}
#-------------------------------------------------------------------------------
# 
#-------------------------------------------------------------------------------
proc TEST_trans_01 {} {

  set  trans_rule_s {
    {"2 *"     "dup +"   }
    {"100 +"   "99 + 1 +"}
  }

  puts ""
  puts "trans_rule_s = $trans_rule_s"

  set prg1  "2 *  100 +  2 *  dup +"

  #DebugOn
  v1_init_all  

  check_tranform_s  $trans_rule_s  $prg1 calc_12345_results

  return
}
#-------------------------------------------------------------------------------
#
# надо добить этот тест, для запуска по 
# VER3 !!
#-------------------------------------------------------------------------------
# proc run_i_joyprg {prg valstack} {


#   set ctx [v3_init_context]

#   # положили начальное значение в стек, потом программу и выполнили ее
#   # 
#   joy-eval "$valstack $prg"

#   # взяли со стека предпологаемый результат
#   # 
#   set e   [pop ]

#   # преобразовали его из внутреннего в JOY-формат
#   # 
#   set ret [v3->joy $e]

#   return $ret
# }
#-------------------------------------------------------------------------------
# proc calc_list_results {prg} {

#   set ll {[1 2 3 4 5]}

#   catch {set res [eval {run_i_joyprg  $prg $ll}]} res

#   return $res
# }
#-------------------------------------------------------------------------------
# proc TEST_trans_02 {} {


#   set trans_rule_s {
#     {"reverse size"    "size"}
#   }

#   set prg1  "reverse size"

#   check_tranform_s  $trans_rule_s  $prg1 calc_list_results

# }
#-------------------------------------------------------------------------------
# 
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
################################################################################
#
# сначала научимся просто разбивать большой интервал на случайные подинтревалы
#
#-------------------------------------------------------------------------------
proc make_test_prg {n} {

  set prg {}
  set ind 0

  repeat $n {
    lappend prg $ind
    incr ind
  }

  return $prg
}
#-------------------------------------------------------------------------------
proc make_prelist {n} {

  set ret {}

  set ind 0

  repeat $n {

    if {[myrand_new 0 3] == 0} {

      lappend ret $ind 
    }

    incr ind
  }
 
  return $ret
}
#-------------------------------------------------------------------------------
proc make_paras_from_prelist {prelist} {

  set ret {}

  foreach {i1 i2} $prelist {
    
    if {$i2 == {} } {break} ;# не нашлось конца для пары

    set l [list $i1 $i2]
   
    #puts "($i1 $i2) [llength $l]"
    lappend ret $l    
  }

  return $ret
}
#-------------------------------------------------------------------------------
proc make_paras {n} {

  set preli  [make_prelist $n]  ;# случайное подмножество из  0 1 2 .. n

  #puts "preli = $preli"
  set paras  [make_paras_from_prelist $preli]

  return $paras
}
#-------------------------------------------------------------------------------
proc make_quotes_TCL {prg} {

  set n [llength $prg]

  set paras  [make_paras $n]

  set newprg [make_quotes_by_paras  $prg $paras $n  "lappend_TCL_list"]

  return $newprg
}
#-------------------------------------------------------------------------------
proc TEST_randprog {} {

  incr ::ind0

  #set ind 1 ;# один параметр у нас уже есть - имя "TEST_randprog"
  set ind $::ind0

  #global argc
  #set ind $argc
  #
  read_seedflag  ind 

  #   set minlen 1
  #   set maxlen 8
  #

  set n 10

  set gp_list     "+ - * dup i" 

  #------------------------------------------
  set ::randinstr randinstr_MAIN

  set ::quotes_proc "make_quotes_TCL"
  #set ::quotes_proc "quotes_proc_NULL"
  #------------------------------------------


  v1_init  ;# ERROR = can't use non-numeric string as operand of "*"
            # NOT result !!
  # stack= | 3 {i dup dup i i dup - +} {2op *} |  instr= tcl  
  # ERROR = can't use non-numeric string as operand of "*"

  set task [task_create  \
              -gp_list    $gp_list]
  

  set prg [make_randprog  $task $n $::randinstr $::quotes_proc]

  #set prg "dup *"

  set x 3 

  DebugOn
  d+
  set result [getresult_prg_val_11  $prg $x]
 	
  puts ""

  if {$result eq {}}  {
    puts "NOT result !!"
  } else {
    puts "x= $x  result= $result"
  }
  
}
#-------------------------------------------------------------------------------
#
#  k~.tl TEST TEST_randprog 2014
#
#-------------------------------------------------------------------------------
#
# PP (primitive programming is NOT genetic programming !
#
#
#-------------------------------------------------------------------------------
proc randinstr_or_LIST {gp_list} {

  # здесь уже можно подумать, а не сделать ли квотированный список
  #if {[myrand 0 3] == 0} {

  #  set size [myrand 2 4]

    #set  instr { nop nop} ;# очень простой список!

  #} else {
    set  instr   [lrand_new  $gp_list]
  #}

  return $instr
} 
#-------------------------------------------------------------------------------
# создать случайную тру-программу длиной не больше 'n'
#-------------------------------------------------------------------------------
proc make_randtrueprog {gp_list num_max ind_max fitnessfunc_check} {

  set ind 0 ;# это всего, чтобы не зациклиться
  set num 0 ;# а это макс длина программы? а зачем? пусть уж какая получится?
  set prg {}

  while {[incr ind] <= $ind_max} {

    #set instr [randinstr_SIMP]  - здесь можем получить и список инструкций 
    # 
    #set instr [randinstr_SIMP] 
    set instr [randinstr_or_LIST $gp_list] 

    set rab $prg       ;# делаем рабочую копию для теста

    lappend rab $instr ;# добавляем новую инструкцию
    # и проверяем опять полностью всю программу, а ведь это не рационально
    # мы же уже все посчитали, надо только досчитать !

    set is_true [$fitnessfunc_check  $rab] 

    #puts -nonewline [format "ind= %2d check= " $ind]

    if {! $is_true}  {
      #puts "NULL    rab= $rab"
      continue ;# попробуем другую инструкцию
    } else {
     # puts "TRUE !! rab= $rab"
            }


    # хорошая инструкция, добавим в программу:
    #
    lappend prg $instr
    if {[incr num] >= $num_max} {break}
  }
  
  return $prg
}
#-------------------------------------------------------------------------------
# 
# TODO: эту функцию надо будет интегрировать потом с основной (из j-core)
#
#-------------------------------------------------------------------------------
proc squareFitness_check_true {joy_prg } {

  set fitness 0

  foreach i {1 2 3 4 5} o {1 4 9 16 25} {

    set result [getresult_prg_val_11  $joy_prg $i]

    if {$result eq {}}  {
      return 0

    }
     
  }
    
  return 1
}
#-------------------------------------------------------------------------------
proc TEST_pp {} {

  incr ::ind0

  set ind $::ind0 

  read_seedflag  ind 


  set num_max  10
  set ind_max 100
  puts ""

  set gp_list     "dup i i" 

  v1_init_all  

  # делаем выполнимую программу
  # 
  set prg [make_randtrueprog  $gp_list $num_max $ind_max squareFitness_check_true]

  puts ""
  puts "RANDTRUEPROG = $prg"
  puts "SIZETRUEPROG = [llength $prg]"

  # а теперь проверяем, что именно она выполняет:

  set x 3 
  set result [getresult_prg_val_11  $prg $x]
 
  # печатаем резудьтат (того, что было в стеке)
  # 
  puts ""

  if {$result eq {}}  {
    puts "NOT result !!"

  } else {
    puts "x= $x  result= $result"
  }
  

}
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
# 
# 
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
proc v1_get_result_from_not_arg {prg_11 {prog @}} {


  v0_set_stack_null

  #push $val 
  set ::sum 0

  #run_v2_src_old $prg 

  run_v1_src $prg_11 

  #set result [pop]
  set result $::sum

  #puts stderr "result = $result"

  return $result
}
#-------------------------------------------------------------------------------
proc getresult_prg {prg_22 {prog @}} {


  #convert_22_to_11  $prg_22 prg_11
  set prg_11 $prg_22

  if {[catch {set result [v1_get_result_from_not_arg  $prg_11]} err ]} {

    if {[IsDebug]} {

      puts stderr "ERROR = $err"
    }
    return {}

  } else {

    return $result
  }

}
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
proc lappend_TCL_list {prg i1 i2 &ret} {

  USE_REFS

  # потом формируем саму пару:
  #
  set quoted_list {} ;# [lrange $prg $i1 $i2]
  

  for {set i $i1} {$i <= $i2} {incr i} {

    lappend quoted_list  [lindex $prg $i]
  }
  
  lappend ret $quoted_list

}
#-------------------------------------------------------------------------------
proc make_quotes_by_paras {prg paras n lappend_list_proc} {

  set ret {} ;# здесь будем формировать результат

  set i0 0


  foreach para $paras {

    set i1 [lindex $para 0]
    set i2 [lindex $para 1]

    # сначала "скопируем" одиночные элементы до начала пары
    #
    for {set i $i0} {$i < $i1} {incr i} {
      lappend ret [lindex $prg $i]
    }


    $lappend_list_proc  $prg $i1 $i2  ret 

    set i0 [expr $i2 + 1] ;# устанавливаем новое начало цикла
  }


  # и в после всех пар надо добавить одиночные в конце
  # 

  for {set i $i0} {$i < $n} {incr i} {
    lappend ret [lindex $prg $i]
  }

  return $ret
}
#-------------------------------------------------------------------------------
proc TEST_makeparas {} {

  set n 10

  puts ""


  set prg [make_test_prg $n]    ;# 0 1 2 .. n - самая простая программа из n оп.

  puts "oldprg = $prg"


  set paras [make_paras $n]

  puts "paras  = $paras"


  set lappend_list_proc "lappend_TCL_list"
  #
  #set lappend_list_proc "lappend_BE_list@

  set newprg [make_quotes_by_paras \
                $prg $paras $n  $lappend_list_proc]

  puts "newprg = $newprg"

}
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
proc itemspop_print {itemspop} {


  foreach item $itemspop {

    puts "item = [set $item]"

  }

  return
}
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
proc mp_create {} {


  v1_init_all  ;# !!!!!!!!!!! ???

}
#-------------------------------------------------------------------------------
proc mp_init {pb args} {


  dict with args {} ;# name value - присвоили переменным значения (локально?)

  #puts ""
  #puts "randinstr = $randinstr"
  # quotes_proc 

  set ::randinstr   "randinstr_MAIN"
  set ::quotes_proc "quotes_proc_NULL"

  # ?? проверяем существование локальных переменных ??
  #
  if [info exists "randinstr"]   {set ::randinstr   $randinstr}
  if [info exists "quotes_proc"] {set ::quotes_proc $quotes_proc}

}
proc get_x_list {xmin xmax nums} {

  set x_list {}

  lappend x_list $xmin ;# 1-я точка обязательна


  # делаем внутренни точки в таком количестве
  set in_nums [- $nums 2] 

  # с шагом
  set step [/ [* 1.0 [- $xmax $xmin]] [- $nums 1]]

  for {set i 1} {$i <= $in_nums} {incr i} {

    set x [+ $xmin [* $i $step]]
    lappend x_list $x
  }


  lappend x_list $xmax ;# последняяя точка обязательна

  return $x_list
}
#-------------------------------------------------------------------------------
proc x_subst {inp} {

  set lis [split $inp]

  set out {}

  foreach l $lis {

    if {$l == "x"} {
      append out {$x}
    } else {
      append out $l
    }
  }

  return $out
}
#-------------------------------------------------------------------------------

set ::FULLPROG 0

#-------------------------------------------------------------------------------
#
# Типичный пример. Выявлем (раскручиваем) программу, вычисляющую квадрат числа.
# Лучшая програма :  "DUP *"
# Лучший фитнес == 2 (нет ошибок для любых входов, длина проги == 2).
#
#-------------------------------------------------------------------------------
proc FITPROC_xx {prog task args} {

  set is_print [dict_parse $args "-is_print"   0]

  set x_list [get_x_list  0 2  10]

  #puts "x_list = $x_list"
  #exit

  # ???? 
  # 
  set func [GET $task "func"]

  # начинаем в цикле подсчет фитнеса --------------------------

  #set is_print 0

  if {$is_print} {
    #puts stderr ""
    #puts stderr "-------------------------------------------------------------------"
    #puts stderr ""
    #puts stderr "FITPROC_xx: prg    = $src"
    #puts stderr "FITPROC_xx: x_list = $x_list"
    #puts stderr "FITPROC_xx: func   = $func"
    #puts stderr ""
  }

  set fitness 0

  set delta_sum 0 ;# будем суммировать отклонения в точках или их квадраты



  foreach x $x_list {

    set o [expr $func]

    # обнудим стек, выполним программку и возьмем результат (верхний эдемент стека)
    # 
 
    set result [getresult_prog_val  $prog $x]
 
    #---------------------------------------------------------------

    set len [llength $::joy_ST] ;# сколько еще осталось в стеке значений ??

    #puts stderr "::joy_ST = $::joy_ST,  len = $len"
    #puts "result = $result"

    #set delta_sum 0 ;# будем суммировать отклонения в точках или их квадраты

    if {$is_print} {
      puts stderr "x = $x, result = |$result|, ::joy_ST = |$::joy_ST|"
    }
    #---------------------------------------------------------------
    #

    if {$result eq {}}  {

      if {$is_print} {
        puts stderr "FITPROC_xx: x = $x, result eq {} , ERROR operator??"
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

    } elseif {![string is integer $result] && ![string is double $result]} {

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

      #set delta [expr {abs($o-$result)}] ;# 
      set delta [expr {($o-$result) ** 2 } ] ;# !! может корень из суммы квадратов?

      #if {$delta > 1000} {
      #  # anti overflow ???
      #  set delta 1000
      #}

      set delta_sum [+ $delta_sum $delta]

      if {$is_print} {
        puts stderr "FITPROC_xx: x = $x, o = $o, result = $result, delta = $delta, delat_sum = $delta_sum"
      }

      #set fitness [+ $fitness $delta]
    }
    #---------------------------------------------------------------

  }
    
  #set fitness [+ $fitness $delta_sum]
  set fitness [expr {$fitness + sqrt ($delta_sum)}]

  # длину учитывать ? но тогда генетич. разнообразие ухудшается?
  #
  #incr fitness [llength $src] 

  # нам не нужны лишние результаты в стеке ? тоже ухудшает? лучше потом преобразовать?
  #
  #incr fitness $len

  #puts stderr "FITPROC_xx, prg = $src, fitness = $fitness"

  return $fitness
}
#-------------------------------------------------------------------------------
proc fitness_test {task item} {

  #set task NULL

  puts "item = $item,  ret = [FITPROC_xx  $item $task -is_print 1] "

}
#-------------------------------------------------------------------------------
proc test_joy_savestack {} {


  v1_init_all  ;# !!!!!!!!!!! ???

  #---------------------------------------------------

  set ::error_print1 1
  set ::error_print2 1
  set ::error_print3 1
  
  set ::error_saverestore 1
  
  #set proga "+ + + dup *"
  set proga "+ dup * + + "
  
  v0_set_stack_null 
  set result [v1_get_result_from_one_arg $proga  3]
  
  
  puts ""
  puts "result = $result"
  puts "joy_ST = $::joy_ST"
  puts ""
  
}
# ------------------------------------------------------------------------------
proc task_correct_gp {task t r} {


#   set size    [GET $task "size"] 
#   set pmin    [GET $task "pmin"] 
#   set pmax    [GET $task "pmax"] 

#   set gp_list      [GET $task "gp_list"] 
#   set target_text0 [GET $task "target_text"] 

  
#   test_random_seed [+ $t $r]      


#   if {$t == 0} { 
#     # берем задачу-строку  по умолчанию
#     set text  $target_text0
#   } else {
#     set text  [make_random_target_text   $gp_list $size  $pmin $pmax]
#   }


#   SET $task "target_text" $text

  return
}
#-------------------------------------------------------------------------------
proc TEST_xx {} {


  global argc argv argv0
  set argv [lrange $argv 2 end]

  puts ""
  #puts stderr "argv = $argv"
  #exit

  #------------------------------------------------------

  set args {-print  1}

  #------------------------------------------------------


  set seed        [dict_parse $argv "-seed"  2013]
  set lpop        [dict_parse $argv "-lpop"  10]  ;# колич-во ботов 
  set size        [dict_parse $argv "-size"   6]  ;# макс. длина ботов (при начальном старте?)
  set nums        [dict_parse $argv "-nums"  10]  ;# шагов эволюции 
  set vers        [dict_parse $argv "-vers"  "gp"]
  set print       [dict_parse $argv "-print"  1]

  set gp_list     [dict_parse $argv "-list"   "dup * nop +"]
  set func        [dict_parse $argv "-func"  {x ** 2 + x}]
  set auto        [dict_parse $argv "-auto"   0]

  set ::gp_dict_AUTO $auto

  #------------------------------------------------------
  #set ::randinstr   randinstr_MAIN 

  #set ::quotes_proc "make_quotes_BE"
  #set ::quotes_proc "make_quotes_TCL"
  #set ::quotes_proc  "quotes_proc_NULL" 

  #set randpop_proc "make_rand_prgpop_unikum"

  set rand_prgpop_proc "make_rand_prgpop"
  
  set pb [mp_create]

  if {0} {
    mp_init $pb \
      randinstr    "randinstr_MAIN" \
      quotes_proc  "make_quotes_TCL"
  } else {
    mp_init $pb \
      randinstr    "randinstr_MAIN" \
      quotes_proc  "quotes_proc_NULL"
  }

  set func [x_subst $func] 
 
  puts "func = $func"

  set task [task_create  \
              -fit_func "FITPROC_xx"  \
              -fit_tobest     "MIN" \
              -func           $func \
              -gp_list    $gp_list]
  

  #--------------------------------
  #
  # задаем начальную "случайность"
  
  if {$seed == "@"} {
    
    set seed [clock seconds]
  }
  
  #random_seed $seed 
  test_random_seed $seed 

  set obj_ga \
    [BOT01 new  -lpop $lpop -lsrc $size -task $task -vers $vers] 
    

  set obj_gp [BOT33 new   -lpop $lpop -lsrc $size \
                -task $task -print $print]

  #--------------------------------


  #------------------------------------------------------

  if {$vers == "fs"} {
  #------------------------------------------------------
    #
    # ga_evolution, ищем как обычную строку 

    set gp_list      "dup * nop +"  ;# "1 2 3 4 5 6 7 8 9"
    set ::target_text  "nop dup dup nop nop nop nop * nop + nop nop"
    set size 12

    set fitness_func   "FITPROC_list_FS"
    set fit_target     0    
    # т.е. тоже больше фитнес - лучше, но мы приближаемся сдева к точносу 0 !!
  
    set task_fs [task_create  -fit_func $fitness_func \
                   -fit_tobest       "MAX" \
                   -fit_target $fit_target \
                   -fit_error  0.01        \
                   -gp_list    $gp_list]  

    set ::is_print $print
  
    set obj \
      [BOT01 new  -lpop $lpop -lsrc $size -task $task_fs -vers $vers] 

    set pop [GET $obj "pop"]
    SET $pop  select_one   "ga_select_one_bestof2"
    SET $pop  select_two   "ga_select_two_bestof2"

    set m [dict merge $args $argv]
    puts "m = $m"

    #set ret [calc_BOT01 $obj {*}$argv  -print 1]
    set ret [calc_BOT01 $obj {*}$m]

  #------------------------------------------------------
  }
  if {$vers == "gp"} {

  #------------------------------------------------------
  #
  # запускаем эволюцию GP напрямую, через функцию

    run_gp_evolution_for_task $task $seed $rand_prgpop_proc \
                              $lpop $size        \
                              $nums $print       \
                              -game_print_proc 0 \
                              -mutprob         0.2

    puts ""
    puts "===================================================================="


    calc_BOT33  $obj_gp \
      -nums            $nums  \
      -task            $task             \
      -print           $print         \
      -randpop_proc    $rand_prgpop_proc 

    puts ""
    puts "===================================================================="

    
  #------------------------------------------------------
  } 
  if {$vers == "ga"} {
  #------------------------------------------------------
    
    set ::is_print $print
    
    set pop [GET $obj_ga "pop"]
    
    # только эти функции выбора работают для GP!
    # но вот в этом, наверное и есть ошибка, почему здесь получается хуже мутация
    # чем в BOT01 для поиска строк
    
    SET $pop  select_one   "ga_select_one_bestof2"
    SET $pop  select_two   "ga_select_two_bestof2"    
         

    calc_BOT01 $obj_ga  -nums $nums   -print 1

  #------------------------------------------------------
  } 
  if {$vers == "ga_gp"} {
  #------------------------------------------------------
    
    #
    # а теперь запустим "соревнование"
    
    
    set botobjs [dict_create] 
  
    dict_set $botobjs "BOT33" $obj_gp

    set num_text 1
    set num_runs [dict_parse $argv "-runs" 1]

    maintest_run  $botobjs  "task_correct_gp" $num_text $num_runs  $nums  
   

  #------------------------------------------------------
  } 
  #------------------------------------------------------
  
  
  return
}
#-------------------------------------------------------------------------------
#
# соревнование-тест (пока с одним участником)

# О.Г. Монахов, Э.А.Монахова, 2017
#
# Параллельный алгоритм 
# многовариантного эволюционного синтеза нелинейных моделей
#
#

# l~.tl TEST TEST_xx  -seed @ -lpop 200 -size 6 -nums 500 -vers ga_gp -runs 100 \
                      -func 'x ** 3 + x ** 2 + x'
#
# Вариант попроще:
# 
#l~.tl TEST TEST_xx  -seed @ -lpop 50 -size 10 -nums 100 -vers ga_gp -runs 10 \
                     -func 'x ** 3 + x ** 2 + x'
#
# TODO:
#   этот примитивный генетичекий алгоритм очень плохо сходится. нужно делать 
#   рефакторинг, 
#   выделение блоков и статистику по расположению этих блоков относительно друг 
#   друга 
#   (.е. это уже начальное понятие типа данных), а также об их эффективном 
#   вкладе в результат..
#  
#  

#-------------------------------------------------------------------------------

# l~.tl TEST TEST_xx  -seed 1 -lpop 20 -size 6 -nums -1 -vers ga    
# l~.tl TEST TEST_xx  -seed 1 -lpop 20 -size 6 -nums -1 -vers gp    
  
# OUT:
# l~.tl TEST TEST_xx  -seed    0 -lpop  5 -size 6 -nums -1 -vers gp -print 2 
# l~.tl TEST TEST_xx  -seed 2013 -lpop 10 -size 6 -nums 10 -vers gp

#-------------------------------------------------------------------------------

# ищем простую функцию x^2:
#
# l~.tl TEST TEST_xx  -seed @ -lpop 10 -size 6 -nums -1

# ищем простую функцию x^3 + x^2:      dup dup dup * + * 
#
# l~.tl TEST TEST_xx  -seed 0 -lpop 50 -size 6 -nums -1 -vers 1 -print 1

# ищем простую функцию x^3 + x^2 + x:  dup dup dup dup * nop + * + 
#
# l~.tl TEST TEST_xx  -seed @ -lpop 100 -size 6 -nums -1 -vers 1 -print 2

# какой-то странный все же алгоритм, долго не сходится
#
# l~.tl TEST TEST_xx  -seed @ -lpop 20 -size 6 -nums -1 -print 2 
#                                     -func 'x ** 3 + x ** 2 + x'

#-------------------------------------------------------------------------------

#007)     best =    0.000 :   dup dup dup + nop + dup + + 

#l~.tl TEST TEST_xx  -seed @ -lpop 200 -nums -1 -print 2 -vers 0 
#                    -func 'x ** 3 + x ** 2 + x'

#-------------------------------------------------------------------------------

# Вспомогательные тесты:

# l~.tl ANTS ANTS_gp 2012  10 15 2
# l~.tl TEST TEST_pp 2014

# l~.tl TEST TEST_makeparas
# l~.tl TEST TEST_randprog @
# l~.tl TEST TEST_randprog 2014

###########################################################################################

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------

# NEXT_01  - простейший тест из плюсов и минусов

set ::sum        0  ;# начальное значение сумматора 
set ::sum_target 0  ;# к чему стремимся, что надо получить 


# ------------------------------------------------------------------------------
# proc PLUS_1 {} {

#   incr ::sum +1

# }
# ------------------------------------------------------------------------------
# proc MINUS_1 {} {

#   incr ::sum -1

# }
#-------------------------------------------------------------------------------
v0_make_tclproc  null {} {

  set ::sum 0

}
#-------------------------------------------------------------------------------
v0_make_tclproc  p1 {} {

  #PLUS_1 ;# это уже вызываем TCL-функцию из прикладной библиотеки
  incr ::sum +1

}
#-------------------------------------------------------------------------------
v0_make_tclproc  m1 {} {

  #MINUS_1 ;# это уже вызываем TCL-функцию из прикладной библиотеки
  incr ::sum -1

}
#-------------------------------------------------------------------------------
v0_make_tclproc  p9 {} {

  incr ::sum +9

}
#-------------------------------------------------------------------------------
proc FITPROC_01 {p {prog @}} {

  set fitness 0

  #if {$::ITEMS_LIST} {
  set joy_prg  [item_get_mainsrc $p]
  #} else {
  #  set joy_prg $p
  #}


  set result [getresult_prg  $joy_prg $prog]


  #puts "joy_prg = $joy_prg  resul = $result"

  if {$result eq {}}  {
    
    # здесь может быть просто списко или символ-строка, а не число!
    # 
    #puts "NOT run? NOT result !!"
    #exit

    incr fitness 50 ;# при каждой ошибке добавляем дельту
    
  } elseif {![string is integer $result]} {

    incr fitness 50 ;# при каждой ошибке добавляем дельту
    
  } else {
    
    set delta [expr {abs($::sum_target-$result)}]  ;# ??
    
    if {$delta > 1000} {
      # 
      set delta 1000 ;# anti overflow ???
    }

    incr fitness $delta
  }

  
  #return [expr {$fitness + [llength $joy_prg]}]
  #
  # давай пока длину не учитывать ?!
  # 

  return $fitness
}
#-------------------------------------------------------------------------------
proc argo_print {argo} {

  puts ""
  puts "argo = $argo"
  puts ""

  dict_print $argo 

}
#-------------------------------------------------------------------------------
proc gp_list_to_librarys {gp_list} {

  # если src == {}, то это tcl-функция ?

  set bibl  [list "p3" {src {}}] 

  librarys_push $bibl ;# запихнуть в глобальную библиотеку 

}
#-------------------------------------------------------------------------------
proc gp_dict_print {} {


  set dict [set $::gp_dict]

  dict for {key val} $dict {

    set src [dict get  $val "src"]
    puts "$key : $src"
  }

}
#-------------------------------------------------------------------------------
proc NEXT_01 {} {

  global argc argv argv0
  set argo [lrange $argv 2 end]
  
  argo_print $argo 

  set seed        [dict_parse $argo "-seed" 2016]
  set individuals [dict_parse $argo "-lpop" 10]
  set len         [dict_parse $argo "-size" 10] 
  set nums        [dict_parse $argo "-nums"  4]
  set gp_list     [dict_parse $argo "-list" "p1"] ;#  "p1 nop"  "p1 p3" 
  set auto        [dict_parse $argo "-auto"  0]
  
  set ::sum_target 20


  puts "individuals  = $individuals" ;# колич-во ботов
  puts "len          = $len"         ;# макс. длина ботов (при начальном старте?)
  puts "nums         = $nums"        ;# шагов эволюции  
  puts "gp_list      = $gp_list"     ;#   

  puts "::sum_target = $::sum_target" ;# к чему стремимся, что надо получить 
  puts ""

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  set is_print 1
  #DebugOn

  set rand_prgpop_proc "make_rand_prgpop" ;# "make_rand_prgpop_unikum"
    
  set pb [mp_create]

  mp_init $pb 

  set task [task_create  -fit_func FITPROC_01  "-fit_tobest" "MIN" \
                         -gp_list  $gp_list]

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  #SET $::gp_dict "p222" {src { p1 p1 p1 }}
  #SET $::gp_dict "p5" {src { p3 p1 p1 }}
  #gp_dict_add_by_src { p1 p1 p1 }
  #gp_dict_add_by_src { p1 p1 p1 p1 p1 }
  #gp_dict_add_by_src { p000 p001 p1 p1 p1 }
  #SET $::gp_dict "p5" {src { p1 p1 p1 }}

  set ::gp_dict_AUTO $auto

  ## l~.tl TEST NEXT_01 -seed @ -lpop 10 -size 1 -nums -1 -list "p1 p3 p5"
  ## touch l:l~.tl,TEST,NEXT_01,-seed,123,-lpop,10,-size,1,-nums,-1,
  ##                                            -list,\{,p1,p3,p5,\}

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  run_gp_evolution_for_task    \
      $task                    \
      $seed $rand_prgpop_proc  \
      $individuals  $len $nums \
      $is_print                \
      -print        $is_print  \
      -mutprob          0.1    \
      -game_print_proc  0      \
    {*}$argo
  

  puts ""
  gp_dict_print 

  return
}
################################################################################

# Основные идеи:

# -) поиск и выделение частей-функций в программах, занесение их в библиотеку,
#   и рефакторинг шаблонов, как основной путь эволюции;

# -) шаблоны вырезаются и записываются в библиотеку вместе c некоторой инфой об 
#   их окружении; эта инфа используется как "описание типов" для адекватной
#   подстройки программ в эволюции;

# l~.tl TEST NEXT_01 -seed 2016 -lpop 10 -size 10 -nums  4
# l~.tl TEST NEXT_01 -seed    @ -lpop 10 -size  1 -nums -1
# l~.tl TEST NEXT_01 -seed 2020 -lpop 10 -size  1 -nums  5 

# -) универсальная передача параметров через args (dict_print);

# -) gp_list --> ::mainlib (с индексом пригодности и его привязкой к 
#                "окружению" потом)
# -) лучшие проги заносим в ::mainlib (аналог как у новосибирцев)
# -) 
# -) запуск joy_run ? с использованием сторонних библиотек (::mainlib);

# run_v1_src_or_prog ->  run_v1_src   $proga 
#                    ->  run_v1_prog  $prog  - будет через библиотеки !!


# +) обратный анфакторинг (распаковка процедур) : make_unfactoring_prog
# +) слияние нескольких программ с локальными библиотеками : commit
# -) слияние и рtфакторинг с использованием общей библиотеки.

# +) перевод всех алгоритмов : prg --> prog ;
# -) поиск лучшего решения путем рефакторинга;

################################################################################
