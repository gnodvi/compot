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

  check_tranform_s  $trans_rule_s $prg1  calc_12345_results

  return
}
#-------------------------------------------------------------------------------
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

    if {[comm_random_int_minmax 0 3] == 0} {

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
proc getresult_prg {prg_22} {


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
#-------------------------------------------------------------------------------

#set ::FULLPROG 0

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

  
#   comm_random_seed [+ $t $r]      


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
#-------------------------------------------------------------------------------
proc argo_print {argo} {

  puts ""
  puts "argo = $argo"
  puts ""

  #dict_print_real $argo 
  #dict_print $argo  "ARGO" "true" 
  dict_print $argo  "" "true" 


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
###########################################################################################
###########################################################################################
