# -*-   mode: tcl  ; coding: koi8   -*- ----------------------------------------

#-------------------------------------------------------------------------------
# FOR JOY
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
proc v1_get_result_from_one_arg {prg_11 val {prog_11 @}} {


  push $val 

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #d+

  #puts "prg    = $prg"
  #puts "prg_11 = $prg_11"

  #if {$prog == @} {puts "v1_get_result_from_one_arg:  prog == @ !!"}

  #if {[string equal $prog "@"]} {

  #  puts "v1_get_result_from_one_arg: prog= |$prog|"
  #} 


  run_v1_src_or_prog $prg_11 $prog_11

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  #run_v2_src_old $prg 

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  set result [pop]

  return $result
}
#-------------------------------------------------------------------------------
proc getresult_prg_val_11 {prg_11 val {prog_11 @}} {


  #convert_22_to_11  $prg_22 prg_11
  #set prg_11 $prg_22 ;# ??

  v0_set_stack_null ;# и не более того !!!!


  if {[catch {set result [v1_get_result_from_one_arg  $prg_11 $val $prog_11]} err ]} {

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

    if {[myrand 0 3] == 0} {

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
    set  instr   [lrand $::gp_list]
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

  #set ind 1 ;# один параметр у нас уже есть - имя "TEST_randprog"
  set ind $::ind0 

  #
  # лучше бы как-то неявно выражать, через кол-во параметров!
  #global argc
  #puts "argc = $argc"
  ##
  #set ind $argc
  #
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
  # 
  # v1_init_all  
  #DebugOn

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
#-------------------------------------------------------------------------------
# 
# 
#-------------------------------------------------------------------------------
#
# Типичный пример. Выявлем (раскручиваем) программу, вычисляющую квадрат числа.
# Лучшая програма :  "DUP *"
# Лучший фитнес == 2 (нет ошибок для любых входов, длина проги == 2).
#
#-------------------------------------------------------------------------------
proc squareFitness {prg_11 {prog_11 @}} {

  set fitness 0

  foreach i {1 2 3 4 5} o {1 4 9 16 25} {

    set result [getresult_prg_val_11  $prg_11 $i $prog_11]


    if {$result eq {}}  {

      # здесь может быть просто списко или символ-строка, а не число!
      # 
      #puts "NOT run? NOT result !!"
      #exit
      incr fitness 50 ;# при каждой ошибке добавляем дельту

    } elseif {![string is integer $result]} {

      incr fitness 50 ;# при каждой ошибке добавляем дельту

    } else {

      set delta [expr {abs($o-$result)}] ;# !!!!!!!!! o {1 4 9 16 25}

      if {$delta > 1000} {
        # anti overflow ???
        set delta 1000
      }
      incr fitness $delta
    }
  }
    
  #return [expr {$fitness + [llength $prg_11]}]
  #
  # давай пока длину не учитывать ?!
  # 
  return $fitness
}
#-------------------------------------------------------------------------------
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
proc fitness_00 {joy_prg} {

  set fitness 0

  #set result [getresult_prg_val_11  $joy_prg $i]
  
  #set result [getresult_prg  $joy_prg]
  
  #puts "joy_prg = $joy_prg  resul = $result"

#   if {$result eq {}}  {
    
#     # здесь может быть просто списко или символ-строка, а не число!
#     # 
#     #puts "NOT run? NOT result !!"
#     #exit

#     incr fitness 50 ;# при каждой ошибке добавляем дельту
    
#   } elseif {![string is integer $result]} {

#     incr fitness 50 ;# при каждой ошибке добавляем дельту
    
#   } else {
    
#     set delta [expr {abs($::sum_target-$result)}]  ;# ??
    
#     if {$delta > 1000} {
#       # 
#       set delta 1000 ;# anti overflow ???????????
#     }

#     incr fitness $delta
#   }

  
  #return [expr {$fitness + [llength $joy_prg]}]
  #
  # давай пока длину не учитывать ?!
  # 

  return $fitness

}
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
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
proc fitness_01 {joy_prg {prog @}} {

  set fitness 0

  #set result [getresult_prg_val_11  $joy_prg $i]
  
  #set result [getresult_prg  $joy_prg]
  
  #if {$::OLD} {
  #  set result [getresult_prg  $joy_prg]
    
  #} else {
    #puts "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
    #puts "joy_prg= $joy_prg  prog= $prog"
    #puts "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"

  set result [getresult_prg  $joy_prg $prog]
  #}
  

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


  #DebugOn
  run_gp_evolution  $rand_prgpop_proc \
                       $individuals $len \
                       fitness_01 "LT_lsort" 0.1  $nums $is_print 0 ;# not game print
  
  return
}
#-------------------------------------------------------------------------------
proc TEST_NEW {} {


  # ищем функцию возведения в квадрат 
  # 

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  incr ::ind0

  # берем данные из командной строки 
  # 
  set individuals 10 ;# колич-во ботов
  set len          6 ;# макс. длина ботов (при начальном старте?)
  set nums        10 ;# шагов эволюции  

  #parse_opt_seed_3_new  individuals len nums

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


  set is_print 1
  
  # из чего и как делаем проги (надо бы сделать отдельным "классом" в JOY)
  # 

  #set ::gp_list     "+ - * / dup"  
  set ::gp_list     "+ - * dup i nop" 

  #set randpop_proc "make_rand_prgpop_unikum"
  set randpop_proc "make_rand_prgpop"
  
  #------------------------------------------
  #set ::randinstr   randinstr_SIMP 

  #set ::quotes_proc "make_quotes_BE"
  #set ::quotes_proc "make_quotes_TCL"
  #set ::quotes_proc  "quotes_proc_NULL" 
  #------------------------------------------


  set pb [mp_create]

  mp_init $pb \
    randinstr    "randinstr_SIMP" \
    quotes_proc  "make_quotes_TCL"


  set itemspop_NEW [make_itemspop  $randpop_proc \
                      $individuals $len \
                      $is_print]

  puts ""
  itemspop_print $itemspop_NEW
  puts ""

  return
}
#-------------------------------------------------------------------------------
proc TEST_xx {} {


  # ищем функцию возведения в квадрат 
  # 

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  incr ::ind0

  # берем данные из командной строки 
  # 
  #set individuals ;# колич-во ботов
  #set len         ;# макс. длина ботов (при начальном старте?)
  #set nums        ;# шагов эволюции  

  parse_opt_seed_3_new  individuals len nums

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


  set is_print 1
  
  # из чего и как делаем проги (надо бы сделать отдельным "классом" в JOY)
  # 

  #set ::gp_list     "+ - * / dup"  
  set ::gp_list     "+ - * dup i nop" 

  #------------------------------------------
  #set ::randinstr   randinstr_SIMP 

  #set ::quotes_proc "make_quotes_TCL"
  #------------------------------------------

  #set randpop_proc "make_rand_prgpop_unikum"
  set rand_prgpop_proc "make_rand_prgpop"
  

  set pb [mp_create]

  mp_init $pb \
    randinstr    "randinstr_SIMP" \
    quotes_proc  "make_quotes_TCL"



  run_gp_evolution  $rand_prgpop_proc \
                       $individuals $len \
                       squareFitness "LT_lsort" 0.1  $nums $is_print
  
  return
}
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------

# k~.tl TEST TEST_xx  2013  10 3 6

# k~.tl TEST TEST_xx  @     10 6 10
# k~.tl TEST TEST_xx  2013  10 6 10


# k~.tl ANTS ANTS_gp  2012  10 15 2


# k~.tl TEST ALL_TESTS

#   +) обратный анфакторинг (распаковка процедур) : make_unfactoring_prog
#   +) слияние нескольких программ с локальными библиотеками : commit
#   -) слияние и рtфакторинг с использованием общей библиотеки.


# k~.tl TEST NEXT_01 @  10 5 2

#   -) перевод всех алгоритмов : prg --> prog ;
#   -) запуск joy_run с использованием сторонних библиотек;
#   -) поиск лучшего решения путем рефакторинга;

#-------------------------------------------------------------------------------

# k~.tl TEST TEST_pp 2014

# k~.tl TEST TEST_makeparas
# k~.tl TEST TEST_randprog @
# k~.tl TEST TEST_randprog 2014

# k~.tl TEST TEST_xx  @ 10 6 10

# - почему уменьшается кол-во ботов в популяции?
# - куда то из популяции пропадают правильные решения
# - ошибочные операнды надо просто удалять (так подбирать прогу)

# Основные идеи:

# -) поиск и выделение частей-функций в программах, занесение их в библиотеку,
#   и рефакторинг шаблонов, как основной путь эволюции;

# -) шаблоны вырезаются и записываются в библиотеку вместе c некоторой инфой об 
#   их окружении; эта инфа используется как "описание типов" для адекватной
#   подстройки программ в эволюции;

#-------------------------------------------------------------------------------
################################################################################
