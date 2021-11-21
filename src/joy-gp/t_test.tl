# -*-   mode: tcl  ; coding: koi8   -*- ----------------------------------------

#-------------------------------------------------------------------------------


#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------

# NEXT_01  - простейший тест из плюсов и минусов

set ::sum        0  ;# начальное значение сумматора 
set ::sum_target 0  ;# к чему стремимся, что надо получить 

# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
v0_make_tclproc  null {} {

  set ::sum 0

}
#-------------------------------------------------------------------------------
v0_make_tclproc  p1 {} {

  incr ::sum +1

}
#-------------------------------------------------------------------------------
v0_make_tclproc  m1 {} {

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
  set ::is_print  [dict_parse $argo "-print" 1] 

  # флажки для новейших алгоритмов
  # 
  # 
  set ::NEWS      [dict_parse $argo "-news"  $::NEWS]
  set ::AUTO      [dict_parse $argo "-auto"  $::AUTO]
  
  pi_add p1  {"inp" 0 "out" 0}
  pi_add p3  {"inp" 0 "out" 0}
  pi_add p5  {"inp" 0 "out" 0}

  set ::LIPS_begin 0
  set ::LIPS_final 0

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
  #set joyf [GET $task "joyf"]

  # начинаем в цикле подсчет фитнеса --------------------------

  #set is_print 0

  if {$is_print} {
    puts stderr ""
    puts stderr "-------------------------------------------------------------------"
    puts stderr ""
    #puts stderr "FITPROC_xx: prg    = $src"
    puts stderr "FITPROC_xx: x_list = $x_list"
    puts stderr "FITPROC_xx: func   = $func"
    puts stderr "FITPROC_xx: joyf   = $joyf"
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
# proc fitness_test {task item} {

#   #set task NULL

#   puts "item = $item,  ret = [FITPROC_xx  $item $task -is_print 1] "

# }
#-------------------------------------------------------------------------------
proc func_prepare_from_input {inp} {

  set lis [split $inp]

  set out {}

  foreach l $lis {

    if        {$l == "x"} {
      append out {$x}
    } elseif  {$l == "plus"} {
      append out +
    } elseif  {$l == "minus"} {
      append out -
    } elseif  {$l == "mult"} {
      append out *
    } elseif  {$l == "pow"} {
      append out **
    } else {
      append out $l
    }
  } 

  return $out
}
#-------------------------------------------------------------------------------
proc pi_init_TEST_xx {} {

  pi_add nop {"inp" 0 "out" 0}
  pi_add dup {"inp" 1 "out" 2}
  pi_add *   {"inp" 2 "out" 1}
  pi_add +   {"inp" 2 "out" 1}

  set ::LIPS_begin 1
  set ::LIPS_final 1

}
#-------------------------------------------------------------------------------
# 
# 
#-------------------------------------------------------------------------------
proc TEST_xx {args} {


  if {$args == ""} {
    global argc argv argv0
    set argv [lrange $argv 2 end]
  } else {
    set argv $args
  }
  
  puts ""

  #------------------------------------------------------

  ## set seed        [dict_parse $argv "-seed"  2013]
  set seed        [dict_parse $argv "-seed"  @] ;# каждый выхов случаен

  set lpop        [dict_parse $argv "-lpop"  10]   ;# колич-во ботов 
  set size        [dict_parse $argv "-size"   6]   ;# макс. длина ботов (при начальном старте?)
  set nums        [dict_parse $argv "-nums"  10]   ;# шагов эволюции 

  set vers        [dict_parse $argv "-vers"  "gp"] ;# по умолчанию 

  set print       [dict_parse $argv "-print"    1]
  set ::is_print  $print
  

  #------------------------------------------------------

  set ::INIT  [dict_parse $argv "-init"   0] 
  ;# 0 - не делаем специально начальеую инициацию
  ;# 1 - кладем сразу начальное значение x в стек несколько раз с запасом dup dup dup

  if {$::INIT} {
    set gp_list     [dict_parse $argv "-list"       "* nop +"]
  } else {
    set gp_list     [dict_parse $argv "-list"   "dup * +"]
  }

  #------------------------------------------------------

  #set func        [dict_parse $argv "-func"   {x ** 2 + x}]
  set func        [dict_parse $argv "-func"   {x pow 2 plus x}]

  set func [func_prepare_from_input $func] 

  set joyf        [dict_parse $argv "-joyf"   {dup dup * +}]
  #puts "joyf = $joyf"

  #------------------------------------------------------
  # флажки для новейших алгоритмов
  # 
  # 
  set ::NEWS      [dict_parse $argv "-news"  $::NEWS]
  set ::AUTO      [dict_parse $argv "-auto"  $::AUTO]
  set ::DEEP      [dict_parse $argv "-deep"  $::DEEP]
  
#   pi_add nop {"inp" 0 "out" 0}
#   pi_add dup {"inp" 1 "out" 2}
#   pi_add *   {"inp" 2 "out" 1}
#   pi_add +   {"inp" 2 "out" 1}

#   set ::LIPS_begin 1
#   set ::LIPS_final 1

  pi_init_TEST_xx 

  #------------------------------------------------------

  #set ::randinstr   randinstr_MAIN 
  #set ::quotes_proc "make_quotes_BE"
  #set ::quotes_proc "make_quotes_TCL"
  #set ::quotes_proc  "quotes_proc_NULL" 

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

  set task [task_create  \
              -fit_func "FITPROC_xx"  \
              -fit_tobest     "MIN" \
              -func           $func \
              -gp_list    $gp_list] 

##              -joyf           $joyf \
  #------------------------------------------------------
  #
  # задаем начальную "случайность"
  
  if {$seed == "@"} {
    
    set seed [clock seconds]
  }
  
  comm_random_seed $seed 


  #------------------------------------------------------
  # распечатаем начальные значения

  puts "func = $func"
  puts "seed = $seed"
  puts "init = $::INIT"
  puts "list = $gp_list"

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

    set obj \
      [BOT01 new  -lpop $lpop -lsrc $size -task $task_fs -vers $vers] 

    set pop [GET $obj "pop"]
    SET $pop  select_one   "ga_select_one_bestof2"
    SET $pop  select_two   "ga_select_two_bestof2"


    set m [dict merge   {-print  1} $argv]
    puts "m = $m"
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

    # -> calc_BOT33 -> gp_evolution_main ->

    puts ""
    puts "===================================================================="

  #------------------------------------------------------
  } 
  if {$vers == "ga"} {
  #------------------------------------------------------
    
    #set ::is_print $print
    
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
proc TEST_lips {args} {

  puts ""
  puts "TEST_lips"
  puts ""

  pi_init_TEST_xx 


  #puts "::LIPS = [set $::LIPS]"
  puts "::LIPS = $::LIPS"
  puts ""
  pi_print 
  puts ""

  #set b [pi_calc_balans_prg  "dup dup"]

  #set begin 1
  #set final 1
  #set prg   "dup dup * +"
  set prg   "* dup dup +"

  #set f [pi_calc_balans_full  $begin $prg $final]
  #set f [pi_calc_balans_full  $prg]

  #set l [pi_calc_balans_list $begin $prg $final]
  set lst [pi_calc_balans_list $prg]

  puts "full balans: $::LIPS_begin | $prg | $::LIPS_final,  lst = $lst   ???"


}
#-------------------------------------------------------------------------------
#
# t~.tl TEST TEST_xx -nums -1 -news 1 -func 'x pow 3 plus x' -news 1 -print 2
# t~.tl TEST TEST_xx -nums  5 -news 1 -func 'x pow 3 plus x' -news 1 -print 2 -seed 13 -auto 1
#
# TODO :

# +) печатать подробно все шаги 
# +) при клонировании рефакторить с выделением новых библю функций

# -) в библ. добавить крайние значения, т.е. контекст и + статистика использования
# -) мутировать не произвольно а в соотвт. с плюсовой статистикой 
# -) возможно запоминать хорошие "практики мутирования"
#

# В общем, надо отслеживать и использовать, следующие статистики :
#   - динамические шаблоны полезных мутаций
#   - статическое распределение шаблонов по популяции (библиотеки?)
#   - полезность отдельных операций в рантайме (и сразу реагировать на крах?)

#   - учитывать арность операций и текущий размер стека ?!!!! !!!!!!!!!!!!!

###########################################################################################
