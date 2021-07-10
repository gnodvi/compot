# -*-   mode: tcl  ; coding: koi8   -*- ----------------------------------------

#-------------------------------------------------------------------------------


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
v0_make_tclproc  p3 {} {

  incr ::sum +3

}
#-------------------------------------------------------------------------------
v0_make_tclproc  p5 {} {

  incr ::sum +5

}
#-------------------------------------------------------------------------------
v0_make_tclproc  p9 {} {

  incr ::sum +9

}
#-------------------------------------------------------------------------------
proc calc_FITPROC_01 {joy_prg} {

  set fitness 0

  set result [getresult_prg  $joy_prg]

  #puts stderr "joy_prg = $joy_prg  resul = $result"


  #   if {$result eq {}}  {
  
  #     # здесь может быть просто списко или символ-строка, а не число!
  #     # 
  #     #puts "NOT run? NOT result !!"
  #     #exit
  
  #     incr fitness 50 ;# при каждой ошибке добавляем дельту
  
  #   } else
  
  if {! [string is integer $result]} {

    # здесь может быть просто списко или символ-строка, а не число!
    # 
    #puts "NOT run? NOT result !!"
    #exit

    incr fitness 50 ;# при каждой ошибке добавляем дельту
    
  } else {
    
    set delta [expr {abs($::sum_target-$result)}]  ;# ??
    
    #     if {$delta > 1000} {
    #       # 
    #       set delta 1000 ;# anti overflow ???
    #     }

    incr fitness $delta
  }

  
  #return [expr {$fitness + [llength $joy_prg]}]
  #
  # давай пока длину не учитывать ?!
  # 

  return $fitness
}
#-------------------------------------------------------------------------------
proc FITPROC_01 {p task args} {


  set joy_prg  [item_get_mainsrc $p]

  return [calc_FITPROC_01 $joy_prg]
}
#-------------------------------------------------------------------------------
################################################################################
################################################################################
#
# Новый метод (pGP - probabalistic):
# 
# 1) фиксируем "программу" максимального размера с избыточным кол-ом операторов
# 2) каждый оператор идет с вероятность его выполения
# 3) фитнес-значене = сумме попыток выполнения вероятностной программы
# 4) ищем решение в виде вщественной хромомомы (а может и округляя вероятности)
# 
#-------------------------------------------------------------------------------
proc _test_seed {pop task adam} {

  set len_chromo [GET $task "len_chromo"]  

  for {set i 0} {$i < $len_chromo} {incr i} {

    item_set_chromo_gen $adam $i  [random_double 1.0]
  }

  return true;
}
#-------------------------------------------------------------------------------
proc _test_score {this_entity  task} {


  set len_chromo [GET $task "len_chromo"]  

  set program {}

  for {set i 0} {$i < $len_chromo} {incr i} {

    set X [item_get_chromo_gen $this_entity  $i] 
    
    #puts -nonewline [format "  % 5.3f"  $X]

    set cmd [dict_create  "cmd" p1 "ver" $X]
    lappend program $cmd
  }


  set num_runs    7
  set fitness_sum 0

  for {set i 0} {$i < $num_runs} {incr i} {

    set fitness [calc_FITPROC_01 $program]
    #puts "fitness = $fitness"
    incr fitness_sum $fitness
  }

  set fitness [expr {1.0 * $fitness_sum} / $num_runs]

  set fitness [expr {-  $fitness}] 
  #
  # а теперь наоборот должно быть 
  # fit_tobest = MAX, движемся к нулю сдева  : --> 0 
  
  #print_one_line  "--"  $fitness $this_entity

  #puts -nonewline [format "  "]
  #puts -nonewline [format ": fit = % f "  $fitness]
  #puts ""

  #set fitness 0.9
  #puts "_test_score: program = $program, fitness = $fitness"

  return $fitness
}
# //------------------------------------------------------------------------------
proc _test_step {generation pop} {

  set best [pop_get_entity_ $pop  0]
  
  set best_chromo [item_get_mainsrc $best]
  set best_fit    [item_get_fitn    $best]
  
  #print_one_line  [format "%3d" $generation]  $best_fit $best_chromo

  #puts [format "generation = %3d: best_fit = $best_fit" $generation] 

  #puts ""
  print_one_line  [format "%3d" $generation]  $best_fit $best_chromo
  #puts ""

  
  return true;
}
#-------------------------------------------------------------------------------
#
# t~.tl TEST test_pGP -nums 2 -lpop 10 -seed @
# 
#-------------------------------------------------------------------------------
proc test_pGP {} {


  #global argc argv argv0
  #set argo [lrange $argv 2 end]

  global argv 
  set argv [lrange $argv 2 end]
  
  puts ""
  #argo_print $argo 

  set seed        [dict_parse $argv "-seed" 2016]
  set individuals [dict_parse $argv "-lpop" 10]
  #set len         [dict_parse $argo "-size" 10] 
  set nums        [dict_parse $argv "-nums"  4]
  #set gp_list     [dict_parse $argo "-list" "p1"] ;#  "p1 nop"  "p1 p3" 
  #set auto        [dict_parse $argo "-auto"  0]
  
  set ::sum_target 5 ;# 20


  puts "individuals  = $individuals" ;# колич-во ботов
  #puts "len          = $len"         ;# макс. длина ботов (при начальном старте?)
  puts "nums         = $nums"        ;# шагов эволюции  
  #puts "gp_list      = $gp_list"     ;#   

  puts "::sum_target = $::sum_target" ;# к чему стремимся, что надо получить 
  puts ""

  #exit
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  #set is_print 1
  #DebugOn

  #set rand_prgpop_proc "make_rand_prgpop" ;# "make_rand_prgpop_unikum"
    
  set pb [mp_create]

  mp_init $pb 

  #exit
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


  set task_rev [task_create  -fit_func "_test_score" -fit_tobest "MAX" -isreverse 1 -fit_error 0.001 ]
    
  #global argv
  #set argv [lrange $argv 1 end]

  set len_chromo  9 ;# [dict_parse $argv  "-size" 4]

  SET $task_rev "len_chromo" $len_chromo

  set seed_proc "_test_seed"
  set step_proc "_test_step"

  #set pop [super_de $task_rev $seed_proc $step_proc  {*}$argv -size 9] ;# !!!!!

  set pop [super_ga $task_rev $seed_proc $step_proc   {*}$argv -size 9] ;# !!!!!


  puts ""
  exit
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  set best 0
  
  set best_entity [pop_get_entity_         $pop  $best]
  set best_fit    [pop_get_entity_fitness_ $pop  $best]
  
  set best_chromo [item_get_mainsrc $best_entity]
  
  print_one_line  "Final"  $best_fit $best_chromo
  
  
  return
}
################################################################################
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

# l~.tl TEST NEXT_01 -seed @ -lpop 10 -size 1 -nums -1 -list "p1 p3 p5" -auto 1



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

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#
# соревнование-тест (пока с одним участником)

# О.Г. Монахов, Э.А.Монахова, 2017
#
# Параллельный алгоритм 
# многовариантного эволюционного синтеза нелинейных моделей
#
#

# x^3 + x^2      :  dup dup dup * + * 
# x^3 + x^2 + x  :  dup dup dup dup * nop + * + 

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

# упростил пока (сразу заношу в стек X несколько раз (dup dup dup dup dup dup)

# l~.tl TEST TEST_xx  -seed @ -lpop 20 -size 20 -nums -1 -news 1 -list "* +" -print 2 -func 'x ** 3 + x ** 2 + x' 

# Test1:  x ** 4 + x ** 3 + x ** 2 + x       =  * + * + * +

#         sin ( x ** 2 + x      )            =  * + sin      
#         sin ( x ** 2 + x ** 2 )            =  + * sin      
#         sin ( x ** 2 + x ** 3 )            =  * + * sin      
# Test2:  sin ( x ** 2 + x ** 4 )            =  * * + * sin

# Test3:  sin (exp(sin(exp(sin(x)))))        =  
# Test4:  sin (x ** 3) + exp (x)             =  
# Test5:  sin (2 * x) + 1/(x ** 2) - x ** 3  =  
# Test6:  (x + 2) / exp (a * x - 5)          =  

#-------------------------------------------------------------------------------

# l~.tl TEST TEST_xx  -seed 1 -lpop 20 -size 6 -nums -1 -vers ga    
# l~.tl TEST TEST_xx  -seed 1 -lpop 20 -size 6 -nums -1 -vers gp    
  
# OUT:
# l~.tl TEST TEST_xx  -seed    0 -lpop  5 -size 6 -nums -1 -vers gp -print 2 
# l~.tl TEST TEST_xx  -seed 2013 -lpop 10 -size 6 -nums 10 -vers gp

#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------

# Вспомогательные тесты:

# l~.tl ANTS ANTS_gp 2012  10 15 2
# l~.tl TEST TEST_pp 2014

# l~.tl TEST TEST_makeparas
# l~.tl TEST TEST_randprog @
# l~.tl TEST TEST_randprog 2014

################################################################################

# TODO: на простейшей "программы" отладить все механмзмы
#       SP - статистического программирования

#t~.tl TEST NEXT_01 -seed @ -lpop 5 -size 2 -nums 3 -list "p1 p3 p5" -print 2 -auto 0

#-------------------------------------------------------------------------------
proc NEXT_01 {args} {

  if {$args == ""} {
    global argc argv argv0
    set argo [lrange $argv 2 end]
  } else {
    set argo $args
  }
  
  argo_print $argo 

  set seed        [dict_parse $argo "-seed" 2016]
  set individuals [dict_parse $argo "-lpop" 10]
  set len         [dict_parse $argo "-size" 10] 
  set nums        [dict_parse $argo "-nums"  4]
  set gp_list     [dict_parse $argo "-list" "p1"] ;#  "p1 nop"  "p1 p3" 

  # флажки для новейших алгоритмов
  # 
  # 
  set auto        [dict_parse $argo "-auto"  0]
  set ::NEWS      [dict_parse $argo "-news"  $::NEWS]
  
  #set auto        [dict_parse $argv "-auto"   0]

  set ::gp_dict_AUTO $auto

  #------------------------------------------------------

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

  #set ::gp_dict_AUTO $auto

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
#-------------------------------------------------------------------------------
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
proc x_add_dollar {inp} {

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

# 0 - не делаем специально начальеую инициацию для задачи _XX (поиска формулы)
# 1 - кладем сразу начальное значение x в стек несколько раз с запасом
# 
set ::INIT 0  


#-------------------------------------------------------------------------------
proc getresult_prog_val {prog val} {


  v0_set_stack_null ;# и не более того !!!!
  
  # кладем одно значение в стек
  # 
  push $val 

  if {$::INIT} {
    push $val 
    push $val 
    push $val 
    push $val 
    push $val 
    push $val 
    push $val 
    push $val 
  }

  # выполняем программку
  # 
  run_v1_prog $prog

  # забираем одно значение из стека
  # 
  set result [pop]


  return $result
}
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
# proc fitness_test {task item} {

#   #set task NULL

#   puts "item = $item,  ret = [FITPROC_xx  $item $task -is_print 1] "

# }
#-------------------------------------------------------------------------------
proc TEST_xx {args} {


#   global argc argv argv0
#   set argv [lrange $argv 2 end]


  if {$args == ""} {
    global argc argv argv0
    set argv [lrange $argv 2 end]
  } else {
    set argv $args
  }
  

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

  #------------------------------------------------------

  set ::INIT  [dict_parse $argv "-init"   0] 
  ;# 0 - не делаем специально начальеую инициацию
  ;# 1 - кладем сразу начальное значение x в стек несколько раз с запасом

  if {$::INIT} {
    set gp_list     [dict_parse $argv "-list"       "* nop +"]
  } else {
    set gp_list     [dict_parse $argv "-list"   "dup * nop +"]
  }

  #------------------------------------------------------

  set func        [dict_parse $argv "-func"   {x ** 2 + x}]

  set func [x_add_dollar $func] 
 
  puts "func = $func"

  #------------------------------------------------------

  #set ::randinstr   randinstr_MAIN 
  #set ::quotes_proc "make_quotes_BE"
  #set ::quotes_proc "make_quotes_TCL"
  #set ::quotes_proc  "quotes_proc_NULL" 

  #if {$::NEWS} {

  #  set rand_prgpop_proc "make_rand_prgpop_unikum"
  #} else {

  set rand_prgpop_proc "make_rand_prgpop"
  #}
  
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

  set task [task_create  \
              -fit_func "FITPROC_xx"  \
              -fit_tobest     "MIN" \
              -func           $func \
              -gp_list    $gp_list]
  

  #------------------------------------------------------
  #
  # задаем начальную "случайность"
  
  if {$seed == "@"} {
    
    set seed [clock seconds]
  }
  
  #random_seed $seed 
  comm_random_seed $seed 

  #------------------------------------------------------


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


  #------------------------------------------------------
  } 
  if {$vers == "ga"} {
  #------------------------------------------------------
    
    set ::is_print $print
    
    set obj_ga \
      [BOT01 new  -lpop $lpop -lsrc $size -task $task -vers $vers] 
    

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
    
   set obj_gp [BOT33 new   -lpop $lpop -lsrc $size \
                -task $task -print $print]

   
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
###########################################################################################
#-------------------------------------------------------------------------------
