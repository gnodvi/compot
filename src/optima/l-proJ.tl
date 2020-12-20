# -*-   mode: tcl  ; coding: koi8   -*- ----------------------------------------

#-------------------------------------------------------------------------------
# FOR JOY
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
#proc v1_get_result_from_one_arg {prg_11 val {prog_11 @}} {}
proc v1_get_result_from_one_arg {prg_11 val} {


  # кладем одно значение в стек
  # 
  push $val 


  # выполняем программку
  # 
  run_v1_src_or_prog $prg_11 ;### $prog_11


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
#proc getresult_prg_val_11 {prg_11 val {prog_11 @}} {}
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
  #   set ::randinstr randinstr_SIMP
  #   set ::gp_list     "+ - * / dup" ;# работает !!
  #   set prg [make_randprog [rand $minlen $maxlen]]

  set n 10

  set ::gp_list     "+ - * dup i" 

  #------------------------------------------
  set ::randinstr randinstr_SIMP

  set ::quotes_proc "make_quotes_TCL"
  #set ::quotes_proc "quotes_proc_NULL"
  #------------------------------------------


  v1_init  ;# ERROR = can't use non-numeric string as operand of "*"
            # NOT result !!
  # stack= | 3 {i dup dup i i dup - +} {2op *} |  instr= tcl  
  # ERROR = can't use non-numeric string as operand of "*"


  set prg [make_randprog $n $::gp_list $::randinstr $::quotes_proc]

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
proc randinstr_or_LIST {} {

  # здесь уже можно подумать, а не сделать ли квотированный список
  #if {[myrand 0 3] == 0} {

  #  set size [myrand 2 4]

    #set  instr { nop nop} ;# очень простой список!

  #} else {
    set  instr   [lrand_new  $::gp_list]
  #}

  return $instr
} 
#-------------------------------------------------------------------------------
# создать случайную тру-программу длиной не больше 'n'
#-------------------------------------------------------------------------------
proc make_randtrueprog {num_max ind_max fitnessfunc_check} {

  set ind 0 ;# это всего, чтобы не зациклиться
  set num 0 ;# а это макс длина программы? а зачем? пусть уж какая получится?
  set prg {}

  while {[incr ind] <= $ind_max} {

    #set instr [randinstr_SIMP]  - здесь можем получить и список инструкций 
    # 
    #set instr [randinstr_SIMP] 
    set instr [randinstr_or_LIST] 

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

  set ::gp_list     "dup i i" 

  v1_init_all  

  # делаем выполнимую программу
  # 
  set prg [make_randtrueprog   $num_max $ind_max squareFitness_check_true]

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
#-------------------------------------------------------------------------------

# NEXT_01  - простейший тест из плюсов и минусов

set ::sum        0  ;# начальное значение сумматора 
set ::sum_target 0  ;# к чему стремимся, что надо получить 


# ------------------------------------------------------------------------------
proc PLUS_1 {} {

  incr ::sum +1

}
# ------------------------------------------------------------------------------
proc MINUS_1 {} {

  incr ::sum -1

}
#-------------------------------------------------------------------------------
v0_make_tclproc  p1 {} {

  PLUS_1 ;# это уже вызываем TCL-функцию из прикладной библиотеки

}
#-------------------------------------------------------------------------------
v0_make_tclproc  m1 {} {

  MINUS_1 ;# это уже вызываем TCL-функцию из прикладной библиотеки

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
proc itemspop_print {itemspop} {


  foreach item $itemspop {

    puts "item = [set $item]"

  }

  return
}
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
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

  set ::randinstr   "randinstr_SIMP"
  set ::quotes_proc "quotes_proc_NULL"

  # ?? проверяем существование локальных переменных ??
  #
  if [info exists "randinstr"]   {set ::randinstr   $randinstr}
  if [info exists "quotes_proc"] {set ::quotes_proc $quotes_proc}

}
#-------------------------------------------------------------------------------
proc NEXT_01 {} {


  # берем данные из командной строки (n~.tl NEXT_01  2013  10 6 10)
  # 
  incr ::ind0

  parse_opt_seed_3_new  individuals len nums

  puts "individuals  = $individuals" ;# колич-во ботов
  puts "len          = $len"         ;# макс. длина ботов (при начальном старте?)
  puts "nums         = $nums"        ;# шагов эволюции  
  puts ""

  set ::sum_target 20

  puts "::sum_target = $::sum_target" ;# к чему стремимся, что надо получить 
  puts ""

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  set is_print 1
  #DebugOn

  set ::gp_list   "p1" ;#  "p1 nop"  "p1 m1" 

  set rand_prgpop_proc "make_rand_prgpop" ;# "make_rand_prgpop_unikum"
    

  set pb [mp_create]

  mp_init $pb 

  run_gp_evolution  0 $rand_prgpop_proc \
    $individuals $len \
    FITPROC_01 "MIN"  0.1  $nums $is_print 0 ;# not game print
  
  return
}
#-------------------------------------------------------------------------------
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
#
# Типичный пример. Выявлем (раскручиваем) программу, вычисляющую квадрат числа.
# Лучшая програма :  "DUP *"
# Лучший фитнес == 2 (нет ошибок для любых входов, длина проги == 2).
#
#-------------------------------------------------------------------------------
proc FITPROC_xx {prg_11 task args} {

  set is_print [dict_parse $args "-is_print"   0]

  #if {$::ITEMS_LIST} {
  set prg_11  [item_get_mainsrc $prg_11]
  #}

  set prog_11 @ ;# это заглушка на будущее ?

  #set vers [GET $task "vers"]

  #set x_list [get_x_list  1 5  5]
  set x_list [get_x_list  0 2  10]

  #puts "x_list = $x_list"
  #exit

  set func [GET $task "func"]

  # начинаем в цикле подсчет фитнеса --------------------------

  #set is_print 0

  if {$is_print} {
    #puts stderr ""
    #puts stderr "-------------------------------------------------------------------"
    #puts stderr ""
    #puts stderr "FITPROC_xx: prg    = $prg_11"
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
    #set result [getresult_prg_val_11  $prg_11 $x $prog_11]
    set result [getresult_prg_val_11  $prg_11 $x]
 
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
  #incr fitness [llength $prg_11] 


  # нам не нужны лишние результаты в стеке ? тоже ухудшает? лучше потом преобразовать?
  #
  #incr fitness $len

  #puts stderr "FITPROC_xx, prg = $prg_11, fitness = $fitness"

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
#-------------------------------------------------------------------------------
proc TEST_xx {} {


  global argc argv argv0
  set argv [lrange $argv 2 end]

  puts ""
  #puts stderr "argv = $argv"
  #exit

  set seed        [dict_parse $argv "-seed"  2013]
  set lpop        [dict_parse $argv "-lpop"  10]  ;# колич-во ботов 
  set size        [dict_parse $argv "-size"   6]  ;# макс. длина ботов (при начальном старте?)
  set nums        [dict_parse $argv "-nums"  10]  ;# шагов эволюции 
  set vers        [dict_parse $argv "-vers"  "gp"]
  set is_print    [dict_parse $argv "-print"  1]

  set ::gp_list   [dict_parse $argv "-list"   "dup * nop +"]
  set func        [dict_parse $argv "-func"  {x ** 2 + x}]

  #------------------------------------------------------
  #set ::randinstr   randinstr_SIMP 

  #set ::quotes_proc "make_quotes_BE"
  #set ::quotes_proc "make_quotes_TCL"
  #set ::quotes_proc  "quotes_proc_NULL" 

  #set randpop_proc "make_rand_prgpop_unikum"

  set rand_prgpop_proc "make_rand_prgpop"
  
  set pb [mp_create]

  if {0} {
    mp_init $pb \
      randinstr    "randinstr_SIMP" \
      quotes_proc  "make_quotes_TCL"
  } else {
    mp_init $pb \
      randinstr    "randinstr_SIMP" \
      quotes_proc  "quotes_proc_NULL"
  }

  set func [x_subst $func] 
 
  puts "func = $func"

  #------------------------------------------------------

  if {$vers == "test"} {
  #------------------------------------------------------
    #
    # ga_evolution, ищем как обычную строку (но для FS_fitness_list)

    set ::gp_list      "dup * nop +"  ;# "1 2 3 4 5 6 7 8 9"
    set ::target_text  "nop dup dup nop nop nop nop * nop + nop nop"
    set size 12

    set fitness_func   "FS_fitness_list"
    # т.е. тоже больше фитнес - лучше, но мы приближаемся сдева к точносу 0 !!
    set fit_target     0    
  
    set task [task_create $fitness_func -fit_tobest "MAX" -fit_target $fit_target \
              -fit_error 0.01 ]  

    set ::is_print $is_print
    #test_random_seed 0 ;#$i
  
    set obj \
      [BOT01 new  -lpop $lpop -lsrc $size -task $task -vers $vers] 

    set pop [GET $obj "pop"]
    SET $pop  select_one   "ga_select_one_bestof2"
    SET $pop  select_two   "ga_select_two_bestof2"

    set ret [calc_BOT01 $obj {*}$argv]

  #------------------------------------------------------
  }
  if {$vers == "gp"} {
  #------------------------------------------------------

    set task [task_create "FITPROC_xx"  -fit_tobest "MIN" -func $func]

    run_gp_evolution_for_task $task $seed $rand_prgpop_proc \
                              $lpop $size  \
                              0.2                \
                              $nums  $is_print \
                              -game_print_proc 0 

    # l~.tl TEST TEST_xx  -seed 1 -lpop 20 -size 6 -nums -1 -vers gp    

  #------------------------------------------------------
  } 
  if {$vers == "ga"} {
  #------------------------------------------------------
    
    set task [task_create "FITPROC_xx"  -fit_tobest "MIN" -func $func]

    #set ::error_saverestore 1
    
    set ::is_print $is_print
    
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    if {$seed == "@"} {      
      set seed [clock seconds]
    }
    
    random_seed $seed 
    #srandom_set 20 ;#???
    #test_random_seed $seed ;# 1
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    
    
    set obj \
      [BOT01 new  -lpop $lpop -lsrc $size -task $task -vers $vers] 
    
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    
    set pop [GET $obj "pop"]
    
    # только эти функции выбора работают для GP!
    # но вот в этом, наверное и есть ошибка, почему здесь получается хуже мутация
    # чем в BOT01 для поиска строк
    
    SET $pop  select_one   "ga_select_one_bestof2"
    SET $pop  select_two   "ga_select_two_bestof2"    
         
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    calc_BOT01 $obj  -nums $nums
         
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    # l~.tl TEST TEST_xx  -seed 1 -lpop 20 -size 6 -nums -1 -vers ga    
  } 
  
  
  return
}
#-------------------------------------------------------------------------------

# ищем строку 1 2 2 3 3 3 4 4 4 4 5 5 5 5 5

# g_stru.jm _01_test -lpop 10 -nums -1 -test 0  ;# ga_evolution FS_fitness
# g_stru.jm _01_test -lpop 10 -nums -1 -test 1  ;# ga_evolution FS_fitness_list

# g_stru.jm _gp_test 2013 10 6 -1     ;# gp_evolution FS_fitness_list

#-------------------------------------------------------------------------------

# ищем простую функцию x^2:
#
# l~.tl TEST TEST_xx  -seed @ -lpop 10 -size 6 -nums -1

#--------------------------------
# ищем простую функцию x^3 + x^2:      dup dup dup * + * 
#
# l~.tl TEST TEST_xx  -seed 0 -lpop 50 -size 6 -nums -1 -vers 1 -print 1

#--------------------------------
# ищем простую функцию x^3 + x^2 + x:  dup dup dup dup * nop + * + 
#
# l~.tl TEST TEST_xx  -seed @ -lpop 100 -size 6 -nums -1 -vers 1 -print 2

#--------------------------------
# какой-то странный все же алгоритм, долго не сходится
#
# l~.tl TEST TEST_xx  -seed @ -lpop 20 -size 6 -nums -1 -print 2 -func 'x ** 3 + x ** 2 + x'

#-------------------------------------------------------------------------------

#007)     best =    0.000 :   dup dup dup + nop + dup + + 

#l~.tl TEST TEST_xx  -seed @ -lpop 200 -nums -1 -print 2 -vers 0 -func 'x ** 3 + x ** 2 + x'

#-------------------------------------------------------------------------------

# Основные идеи:

# -) поиск и выделение частей-функций в программах, занесение их в библиотеку,
#   и рефакторинг шаблонов, как основной путь эволюции;

# -) шаблоны вырезаются и записываются в библиотеку вместе c некоторой инфой об 
#   их окружении; эта инфа используется как "описание типов" для адекватной
#   подстройки программ в эволюции;


# l~.tl TEST NEXT_01 @  10 5 2

#   +) обратный анфакторинг (распаковка процедур) : make_unfactoring_prog
#   +) слияние нескольких программ с локальными библиотеками : commit
#   -) слияние и рtфакторинг с использованием общей библиотеки.

#   -) перевод всех алгоритмов : prg --> prog ;
#   -) запуск joy_run с использованием сторонних библиотек;
#   -) поиск лучшего решения путем рефакторинга;

#-------------------------------------------------------------------------------

# Вспомогательные тесты:

# l~.tl ANTS ANTS_gp 2012  10 15 2
# l~.tl TEST TEST_pp 2014

# l~.tl TEST TEST_makeparas
# l~.tl TEST TEST_randprog @
# l~.tl TEST TEST_randprog 2014

################################################################################
