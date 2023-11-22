# -*-   mode: tcl  ; coding: koi8   -*- ----------------------------------------

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
proc calc_FITPROC_01 {task joy_prg} {

  set fitness 0

  set result [getresult_prg  $joy_prg]

  set delta [expr {abs($::sum_target-$result)}]  ;# ??
  
  incr fitness $delta


  #return [expr {$fitness + [llength $joy_prg]}]
  #
  # давай пока длину не учитывать ?!
  # 

  return $fitness
}
#-------------------------------------------------------------------------------
proc FITPROC_01 {p task args} {


  set joy_prg  [item_get_mainsrc $p]

  return [calc_FITPROC_01 $task $joy_prg]
}
#-------------------------------------------------------------------------------
proc _test_seed {pop task adam} {

  set len_chromo [GET $task "len_chromo"]  

  for {set i 0} {$i < $len_chromo} {incr i} {

    item_set_chromo_gen $adam $i  [random_double 1.0]
  }

  return true;
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
# вероятностное программирование (в программе каждый итем задан словарем 
# с вероятностью)
# 
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

    set fitness [calc_FITPROC_01 $task $program]

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
#-------------------------------------------------------------------------------
proc test_pGP {args} {

  puts ""
  puts "args = $args"
  puts ""

  #global argc argv argv0
  #set argo [lrange $argv 2 end]

  #global argv 
  #set argv [lrange $argv 2 end]

  set argv $args
  
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

  #set pb [mp_create]
  v1_init_all  ;# !!!!!!!!!!! ???

  #mp_init $pb 

  #exit
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  set task_rev [task_create  \
		  -fit_func "_test_score" -fit_tobest "MAX" -isreverse 1 -fit_error 0.001 ]
    
  #global argv
  #set argv [lrange $argv 1 end]

  set len_chromo  9 ;# [dict_parse $argv  "-size" 4]

  SET $task_rev "len_chromo" $len_chromo

  set seed_proc "_test_seed"
  set step_proc "_test_step"

  #set pop [super_de $task_rev $seed_proc $step_proc  {*}$argv -size 9] ;# !!!!!

  set pop [super_ga $task_rev $seed_proc $step_proc   {*}$argv -lsrc 9] ;# !!!!!


  puts ""
  #exit
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  #pop_print $pop

  set best [pop_get_entity_ $pop  0]
  
  set best_chromo [item_get_mainsrc $best]
  set best_fit    [item_get_fitn    $best]

  #set best 0
  
  #set best_entity [pop_get_entity_         $pop  $best]
  #set best_fit    [pop_get_entity_fitness_ $pop  $best]
  
  #set best_chromo [item_get_mainsrc $best_entity]
  
  print_one_line  "Final"  $best_fit $best_chromo
  
  
  return
}
################################################################################
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
  }

  # выполняем программку (TODO - надо вылавливать ошибки!)
  # j-prog:  test_joy_savestack
  # 
  # -1 - ошибки нет, 0, 1, .. - индекс ошибочного оператора

  set err_index [run_v1_prog $prog] ;# по любому надо выполнить

  #if {$::rr_is_reterror == 1} {
  #  set err_index__ $::rr_index
  #} else {
  #  set err_index__ -1
  #}
  
  #puts "err_index = $err_index, err_index__ = $err_index__"
  #set err_index $err_index__ ;# забрали индекс ршибочного оператора здесь

  set err_index [get_rr_is_reterror]

  # забираем одно значение из стека
  # 
  set result [pop]

  # можно бы попробовать гибкую реакци. на "неверные" операторы программы, т.е.
  # не вываливаться сразу в ошибку, а продолжать выпонять остальные операторы !
  #
 
  return [list $result $err_index]
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

  #puts stderr "args = $args, is_print = $is_print, ::is_print = $::is_print"

  set x_list [get_x_list  0 2  10]

  #set func [GET $task "func"]
  set joyf [GET $task "joyf"] ;# наверное удобне в консоли задавать строку на JOY

  # начинаем в цикле подсчет фитнеса --------------------------

  set fitness   0
  set delta_sum 0 ;# будем суммировать отклонения в точках или их квадраты


  foreach x $x_list {

    #----------------------------------------------------------

    set real [v1_get_result_from_one_arg  $joyf $x] ;# посчитаем истинное значение по функции 

    #set calc [getresult_prog_val          $prog $x] ;# по найденному варианту
    #
    foreach {calc err} [getresult_prog_val $prog $x] break


    set len [llength $::joy_ST] ;# сколько еще осталось в стеке значений ??

    if {$::is_print >= 3} {
      #set src [prog_get_prg_src $prog "main"]
      set src [v1_get_main_src $prog]

      #set src "sfsffdfddfdfdf" 

      puts -nonewline stderr [format "[procname]: %20s : err= %2d,  x= %5.2f,  calc= | %s |"  \
                                $src $err $x $calc]
      if {$err != -1} {
        puts -nonewline stderr " .....  ERROR operator N $err"
      }
      puts stderr ""
    }

    #-----------------------------------------------------------

    #if {$calc eq {}}  {}
    if {$err != -1}  {

      #if {$::is_print >= 3} {
      #  puts stderr "[procname]:  ERROR operator??"
      #}

      # ошибка программы (на первом ошибочном операторе) !!
      # но пока просто даим не слишком большой штраф, в пределах дельта-ошибок
      
      #incr fitness 25 ;# 10 50 150
      incr fitness 900 ;# 10 50 150

      incr fitness -$err ;# немного скорректируем, т.е. чем дальше о начала проги ошилка
      # тем лучше фитнес (меньше)

      break ;# сразу выходить из цикла по точкам

    } elseif {![string is integer $calc] && ![string is double $calc]} {

      # здесь может быть просто списко или символ-строка, а не число!
      # но пока кроме числе и {ошибки} в стеке ничего не предвидится
      #
      puts "[procname]: NOT DIGITAL ???? !!!"
      exit

    } else {

      set delta [expr {( $real - $calc ) ** 2 } ] ;# !! может корень из суммы квадратов?

      set delta_sum [+ $delta_sum $delta]

      if {$is_print} {
        puts stderr "[procname]:  x = $x, real = $real, calc = $calc, delta = $delta, delat_sum = $delta_sum"
      }

      #set fitness [+ $fitness $delta]
    }

    #------------------------------------------------------------

  } ;# конец цикла по тестовым кейсм !!!


    
  set fitness [expr {$fitness + sqrt ($delta_sum)}]


  # 1) TODO
  # длину учитывать ? но тогда генетич. разнообразие ухудшается?
  #
  #set len [calc_len_prog $prog]

  #set fitness [+ $fitness [* 0.01 $len]]


  # 2) TODO
  # нам не нужны лишние результаты в стеке ? тоже ухудшает? лучше потом преобразовать?
  #
  #incr fitness $len

  #puts stderr "FITPROC_xx, prg = $src, fitness = $fitness"

  # 3) нужно вернуть признак, что была ошибка и где (для возможной корректировки)
  #

  if {$::is_print >= 3} {
    puts stderr ""
  }

  return $fitness
}
#-------------------------------------------------------------------------------
# proc fitness_test {task item} {

#   #set task NULL

#   puts "item = $item,  ret = [FITPROC_xx  $item $task -is_print 1] "

# }
#-------------------------------------------------------------------------------
# proc func_prepare_from_input {inp} {

#   set lis [split $inp]

#   set out {}

#   foreach l $lis {

#     if        {$l == "x"} {
#       append out {$x}
#     } elseif  {$l ==  "plus"} {
#       append out +
#     } elseif  {$l == "minus"} {
#       append out -
#     } elseif  {$l ==  "mult"} {
#       append out *
#     } elseif  {$l ==   "pow"} {
#       append out **
#     } else {
#       append out $l
#     }
#   } 

#   return $out
# }
#-------------------------------------------------------------------------------
proc TEST_xx {args} {

  set argv $args

  puts ""
  puts "TEST_xx $args"
  puts ""

  set vers        [dict_parse $argv "-vers"  "gp"] ;# по умолчанию 
  set ::is_print  [dict_parse $argv "-print"    1]  ;# $print

  set fit_func    [dict_parse $argv "-fit_func"    "FITPROC_xx"] 
  set fit_tobest  [dict_parse $argv "-fit_tobest"  "MIN"] 

  #------------------------------------------------------

  set ::INIT  [dict_parse $argv "-init"   0] 
  #
  # 0 - не делаем специально начальеую инициацию
  # 1 - кладем сразу начальное значение x в стек несколько раз с запасом dup dup dup
  # 
  if {$::INIT} {
    set gp_list     [dict_parse $argv "-list"   "* nop +"]
  } else {
    set gp_list     [dict_parse $argv "-list"   "dup * +"]
  }

  #------------------------------------------------------
  # либо в таком виде
  #
  #set func        [dict_parse $argv "-func"   {x pow 2 plus x}]
  #set func [func_prepare_from_input $func] 

  set joyf        [dict_parse $argv "-joyf"   {dup dup * +}]

  # флажки для новейших алгоритмов
  # 
  dict_parse_GLOBAL "::gp_NEWS" $argv
  dict_parse_GLOBAL "::gp_AUTO" $argv
  dict_parse_GLOBAL "::gp_DEEP" $argv
  
  #------------------------------------------------------

  ios_init_TEST_xx 

  v1_init_all  ;# !!!!! ???

  set task [task_create  \
	      -ios_begin 1 -ios_final 1 \
              -fit_func $fit_func  -fit_tobest $fit_tobest \
              \
              -joyf  $joyf -gp_list $gp_list \
             ] 
  #------------------------------------------------------
  
  set seed        [dict_parse $argv "-seed"   @]   ;# каждый вызов случаен
  set lpop        [dict_parse $argv "-lpop"  10]   ;# колич-во ботов 
  set lsrc        [dict_parse $argv "-lsrc"   6]   ;# макс. длина ботов (при начальном старте?)
  set nums        [dict_parse $argv "-nums"  10]   ;# шагов эволюции 

  # распечатаем начальные значения

  #puts "func = $func"
  puts "joyf = $joyf"
  puts "init = $::INIT"
  puts "list = $gp_list"

  #------------------------------------------------------
  #
  # задаем начальную "случайность"
  
  if {$seed == "@"} {
    
    set seed [clock seconds]
  }
  
  comm_random_seed $seed 

  #------------------------------------------------------


  if {$vers == "fs"} {
  #------------------------------------------------------
  # r~.tl TEST TEST_xx  -seed 2013 -lpop 30 -nums -1 -vers fs

    #
    # ga_evolution, ищем как обычную строку 

    #set gp_list   "dup * nop +"  ;# "1 2 3 4 5 6 7 8 9"
    set gp_list   "1 2 3 4 5 6 7 8 9" ;#   


    #set ::target_text  "nop dup dup nop nop nop nop * nop + nop nop"
    set ::target_text "1 2 3 4"
    #set lsrc 12
    set lsrc 4


    set fitness_func   "FITPROC_list_FS"
    set fit_target     0    
    # т.е. тоже больше фитнес - лучше, но мы приближаемся сдева к точносу 0 !!
  
    set task_fs [task_create  -fit_func $fitness_func -fit_tobest "MAX" \
                   -fit_target $fit_target \
                   -fit_error  0.01        \
                   -gp_list    $gp_list]  


    set pop [pop1_create  -lpop $lpop -lsrc $lsrc -task $task_fs] ;#   -vers $vers 

    SET $pop  select_one   "ga_select_one_bestof2"
    SET $pop  select_two   "ga_select_two_bestof2"

    set m [dict merge   {-print  1} $argv]
    puts "m = $m"
      
    #set args {*}$m
    set args $m
    
    set task   $task_fs ;# [dict_parse $args "-task"  [GET $obj "task"]] 

    SET $pop  seedproc "maintest_seed_proc" ;# ??
    #set max_generations [dict_parse $args "-nums"  10] 
    
    puts stderr ""
    
    SET $pop "generation" 0
    SET $pop "itemlist"   {}
    
    set ret [ga_evolution  $task $pop  $nums  {*}$args]
    
    
  #------------------------------------------------------
  }
  if {$vers == "gp"} {
    #
    # запускаем эволюцию GP напрямую, через функцию
    
    puts "seed = $seed"
    
    run_gp_evolution_for_task   $task \
      -lpop $lpop  -lsrc $lsrc -nums $nums {*}$args
    
    
    puts ""
    puts "=============================================="
    
  } 
  #------------------------------------------------------
  if {$vers == "ga"} {

    set pop [pop1_create  -lpop $lpop -lsrc $lsrc -task $task] ;#  -vers $vers 
    
    SET $pop  select_one   "ga_select_one_bestof2"
    SET $pop  select_two   "ga_select_two_bestof2"    
         
    #set args [list  -nums $nums  -print 1]
    
    SET $pop  seedproc "maintest_seed_proc" ;# ?? 
    #set max_generations [dict_parse $args "-nums"  10] 
    #set max_generations $nums
    
    puts stderr ""
    
    SET $pop "generation" 0
    SET $pop "itemlist"   {}
    
    #puts stderr "args = $args"; exit

    #set ret [ga_evolution  $task $pop  $nums -nums $nums  -print 1 {*}$args]
    set ret [ga_evolution  $task $pop  $nums   {*}$args]
     
    #------------------------------------------------------
  } 
  
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

# Test1:  x ** 4 + x ** 3 + x ** 2 + x       =  dup dup dup dup dup  * + * + * +

#         sin ( x ** 2 + x      )            =  * + sin      
#         sin ( x ** 2 + x ** 2 )            =  + * sin      
#         sin ( x ** 2 + x ** 3 )            =  * + * sin      
# Test2:  sin ( x ** 2 + x ** 4 )            =  * * + * sin

# Test3:  sin (exp(sin(exp(sin(x)))))        =  
# Test4:  sin (x ** 3) + exp (x)             =  
# Test5:  sin (2 * x) + 1/(x ** 2) - x ** 3  =  
# Test6:  (x + 2) / exp (a * x - 5)          =  

#-------------------------------------------------------------------------------

# можно упростить (сразу занося в стек X несколько раз (dup dup dup dup dup dup)
# ???

# l~.tl TEST TEST_xx  -seed @ -lpop 20 -size 20 -nums -1 -news 1 -list "* +" -print 2 -func 'x ** 3 + x ** 2 + x' 

#-------------------------------------------------------------------------------

# r~.tl TEST TEST_xx  -seed 2013 -lpop 10 -lsrc 6 -nums 10 -vers ga
# r~.tl TEST TEST_xx  -seed 1    -lpop 20 -size 6 -nums -1 -vers ga  
  
#-------------------------------------------------------------------------------

# r~.tl TEST TEST_xx -nums -1 -news 1 -func 'x pow 3 plus x' -print 1
# r~.tl TEST TEST_xx -nums  5 -news 1 -func 'x pow 3 plus x' -print 1 -seed 13 -auto 1

# r~.tl TEST TEST_xx     -seed 1 -lpop 20 -size 6 -nums -1 -vers gp    
  
# OUT:
# r~.tl TEST TEST_xx  -seed    0 -lpop  5 -size 6 -nums -1 -vers gp -print 2 
# r~.tl TEST TEST_xx  -seed 2013 -lpop 10 -size 6 -nums 10 -vers gp

################################################################################
#-------------------------------------------------------------------------------
proc NEXT_01 {args} {

  set argo $args
  
  argo_print $argo 

  set ::is_print  [dict_parse $argo "-print" 1] 
  set gp_list     [dict_parse $argo "-list" "p1"] ;#  "p1 nop"  "p1 p3" 

  set tclinit     [dict_parse $argo "-tcl"  ""]
  eval $tclinit

  puts "tclinit = $tclinit"
  #puts "nums = $nums"
  puts ""
  #exit
    
  # флажки для новейших алгоритмов
  # 
  # 
  dict_parse_GLOBAL "::gp_NEWS" $argo
  dict_parse_GLOBAL "::gp_AUTO" $argo

  # TODO 
  # - автоматическое добавление этих параметров и их динамическая корректировка
  # - более гибкое задание вариантов алгоритмов и их параметров? -algo ??

  ios_add_new  p1  {} {}
  ios_add_new  p3  {} {}
  ios_add_new  p5  {} {}
  ios_add_new  m1  {} {}

  #------------------------------------------------------

  set ::sum_target [dict_parse $argo "-target" 20]

  puts "::sum_target = $::sum_target" ;# к чему стремимся, что надо получить 
  puts ""

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  set is_print 1
  #DebugOn

  set task [task_create  \
              -fit_func  FITPROC_01_NEW  -fit_tobest  "MIN" -fit_target  0  \
              -gp_list     $gp_list]


  v1_init_all  ;# !!!!!!!!!!! ???

  set seed        [dict_parse $argo "-seed"  @]

  puts "gp_list      = $gp_list"     ;#   

  run_gp_evolution_for_task    \
      $task                    \
      {*}$argo  


  return
}

################################################################################

# r~.tl ANTS ANTS_gp 2012  10 15 2

# r~.tl TEST TEST_xx  -seed 1 -lpop  5 -size 6 -nums 0 -print 2

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# TODO: на простейшей "программы" отладить все механмзмы
#       SP - статистического программирования

# r~.tl TEST NEXT_01 -seed @ -lpop 5 -size 2 -nums 3 -list "p1 p3 p5" -print 2 -auto 0


# r~.tl TEST NEXT_01 -nums -1 -target 10 -list "p1 p3" -size 10 -print 2
# r~.tl TEST NEXT_01 -nums -1 -target 10 -list "p1 p3" -size  2 -print 1 -news 1

# r~.tl TEST NEXT_01 -seed 2016 -lpop 10 -size 10 -nums  4
# r~.tl TEST NEXT_01 -seed    @ -lpop 10 -size  1 -nums -1
# r~.tl TEST NEXT_01 -seed 2020 -lpop 10 -size  1 -nums  5 

# r~.tl TEST NEXT_01 -seed @ -lpop 10 -size 1 -nums -1 -list "p1 p3 p5" -auto 1

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# r~.tl TEST TEST_xx  -joyf 'dup dup dup * * +' -lpop 20 -size 6 -nums -1 -vers gp -list '* + dup' -offprob 0.1 -print 3 

# r~.tl TEST TEST_xx  -joyf 'dup dup dup * * +' -lpop 20 -size 6 -nums -1 -vers ga -print 2
# 
#
# mutation_ratio crossover_ratio
# mutprob 
# r~.tl TEST TEST_xx  -joyf 'dup dup dup * * +' -lpop 10 -size 6 -nums -1 -vers ga -print 2 -mutratio 0.6
#
###########################################################################################
