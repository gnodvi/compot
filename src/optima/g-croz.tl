# -*-   mode: tcl  ; coding: koi8   -*- ----------------------------------------

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
# возвращаем случайный элемент из списка  (a_comm.tl)
#-------------------------------------------------------------------------------
# proc lrand {list} {
    
#   lindex $list [expr {int(rand()*[llength $list])}]
    
# }
#-------------------------------------------------------------------------------
proc randinstr_NEXT {gp_list} {

  #set  instr  [lrand $gp_list] ;# ???
  set  instr  [lrand_new $gp_list] ;# ???
    
  return $instr
}
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------

# Ядро движка GP.
# 
# Создается случайная популяция заданного размера и стартует эволюционный
# процесс, вчисляющий рейтинг каждой программы, используя заданную
# "функцию годности." 

# На каждой итерации 1/3 популяции с лучшей годностью
# используется для создания другой 1/3 популяции через своих потомков
# и еще 1/3 - методом простой мутации исходных программ.
# После чего процесс эволюции повторяется.
# 
# Функция годности должна возвращать целое число, представляющее
# количество вычислительной ошибки сделанное программой.

# Она (функция) получает в качестве входного парпметра - особь популяции.
# Обычно фитнес-функция  вызывает процедуру "run" для запуска скрипта
# с значимым входящим стеком и ранжирует программу в соответствии с 
# ее выходом (результатом).
#
# На каждой итерации особь с лучшей годностью выводится на экран.
#
# Описание параметров:
#
# population_size : количество особей во всей популяции;
#               это число приближенно кратно 3.
# len :         максимальная длина особей в начальной популяции.
# fitnessfunc : фитнесс-функция (имя Tcl-процедуры).
# mutprob :     вероятность мутации, используемая процедурой 'gp_joy_mutate'.
# 
#-------------------------------------------------------------------------------

# Двухточечный кроссовер. Используется для создания двух потомков
# от двух программ. Пример как это работает:
#
# Даны две программы: {A B C D E F} и {1 2 3 4 5 6 7 8 9}
# Определяем две случайные точки в обоих программах:
#
# {A B C D E F}
#    ^   ^
#
# {1 2 3 4 5 6 7 8 9}
#  ^         ^
#
# Два потомкка создаются используя внешнюю часть первой программы
# и внутреннюю часть второй и наоборот.
# Тогда первый потомок будет:
#
# {A 1 2 3 4 5 6 E F}
#
# и второй:
#
# {B C D 7 8 9}
#
# Входные программы -  'a' и 'b'; два скрещивания возвращаются как 
# двухэлементный список.

#-------------------------------------------------------------------------------
proc ga_crossover {a b} {

  # получить четыре точки скрещивания
  # поменять две точки если необходимо, чтобы a0>=a1 и b0>=b1

  set a0 [myrand_new 0 [expr {[llength $a]-1}]]
  set a1 [myrand_new 0 [expr {[llength $a]-1}]]

  if {$a0 > $a1} {set t $a0; set a0 $a1; set a1 $t}

  set b0 [myrand_new 0 [expr {[llength $b]-1}]]
  set b1 [myrand_new 0 [expr {[llength $b]-1}]]  

  if {$b0 > $b1} {set t $b0; set b0 $b1; set b1 $t}
  
  # получить левую/центральную/правую части каждой программы

  set aleft   [lrange $a 0 [expr {$a0-1}]]
  set acenter [lrange $a $a0 $a1]
  set aright  [lrange $a [expr {$a1+1}] end]
  
  set bleft   [lrange $b 0 [expr {$b0-1}]]
  set bcenter [lrange $b $b0 $b1]
  set bright  [lrange $b [expr {$b1+1}] end]
  
  # Теперь создаем кроссовер посредством соединения списков

  set x0 [concat $aleft $bcenter $aright]
  set x1 [concat $bleft $acenter $bright]
  
  # программы не символьные строки !! а списки !! , 
  # поэтому скрещиваются вполне корректно !!!!!!!
  # 
  # puts ""
  # puts "a      : $a"
  # puts "a0 = $a0  a1 = $a1"
  # puts "aleft  : $aleft"
  # puts "acenter: $acenter"
  # puts "aright : $aright"

  #puts stderr "ga_crossover:  $a  +  $b  = $x0  +  $x1"

  list $x0 $x1
}
#-------------------------------------------------------------------------------
# По заданной программе возвращается мутированная программа, в которой каждая 
# инструкция будет заменена (или новая вставлена сразу за ней) с заданной 
# вероятностью '$p'.
#-------------------------------------------------------------------------------
proc gp_joy_mutate {program prob} {

  set gp_list $::gp_list

  for {set i 0} {$i < [llength $program]} {incr i} {
    
    #set r [expr {rand()}]
    set r [random_rand]

    # заменяем итем-строку
    # 
    if {$r <= $prob} {            
      lset program $i [randinstr_NEXT $gp_list] ; # для Tcl-8.4            
    }

    #set r [expr {rand()}]
    set r [random_rand]

    # добавляем итем-стрку
    # 
    if {$r <= $prob} {
      set program [linsert $program $i [randinstr_NEXT $gp_list]]
    }
  }
  
  return $program
}
#-------------------------------------------------------------------------------
proc make_mutant {leader  mutprob} {


  set prg        [item_get_main_src $leader] ;# исходник на JOY в виде строки?
  
  set prg_mutant [gp_joy_mutate  $prg $mutprob]
  
  # делаем нового агента-мутанта
  
  set leader_mutant [item_make $prg_mutant]  
  
  # пока фитнеса нет, только программы

  return $leader_mutant
}
#-------------------------------------------------------------------------------
#  генерируем последнюю 1/3 популяции мутируя лидеров.
#-------------------------------------------------------------------------------
proc make_mutated_from_leaders {leaders l mutprob} {


  set mutated {} ;# сформируем список мутантов
  

  set l_leaders [lrange $leaders 0 [- $l 1]]

  foreach leader $l_leaders {

    set leader_mutant [make_mutant  $leader $mutprob]
    lappend mutated $leader_mutant
  }
  
  
  return $mutated
}
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
proc get_rand_offspring {leaders l} {


  #set x       [myrand 0 [expr {$l - 1}]]
  set x       [myrand_new 0 [expr {$l - 1}]]

  set item    [lindex $leaders $x]

  #set parent_prg [item_get_prog $item]

  #return $parent_prg
  return $item
}
#-------------------------------------------------------------------------------
proc add_offspring {&offsprings offspring l} {

  USE_REFS

  lappend offsprings $offspring         ;# добавили отпрыска

  if {[llength $offsprings] == $l} {return 0} ;# если привысили лимит - выходим

  return 1
}
#-------------------------------------------------------------------------------
proc make_offsprings_from_leaders {leaders l} {

  #set l [llength $leaders]

  # генерируем другую 1/3  популяции отпрысками от случайных лидеров.
  #
  set offsprings {}
  
  while 1 {
    
    set parent0  [get_rand_offspring  $leaders $l]
    set parent1  [get_rand_offspring  $leaders $l]

    set parent0_prg [item_get_main_src $parent0]
    set parent1_prg [item_get_main_src $parent1]

    # трюк получения двух значений от функции списком: (здесь чистые prg?)
    # 
    foreach {offspring0 offspring1} \
      [ga_crossover $parent0_prg $parent1_prg] break
    

    # добавляем отпрысков и смотрим превышение лимита:
    # 
    if {! [add_offspring  offsprings $offspring0 $l]} break
    if {! [add_offspring  offsprings $offspring1 $l]} break
  }
  

  #if {$is_print} {puts "OFFSPRINGS = $offsprings \n"}
   
  return $offsprings
}
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
# proc erase_fit_from_list {leaders} {

 
#   set leaders_prg {}
  
#   foreach leader $leaders {

#     set prg [item_get_main_src $leader]
#     lappend leaders_prg $prg ;# отделяем от старого фитнеса
#   }
  
#   return $leaders_prg
# }

#-------------------------------------------------------------------------------
proc dict_print_real_all_in_list {name list_pd} {

  puts stderr "$name : " 

  foreach item $list_pd {
    dict_print_real $item
  }

}
#-------------------------------------------------------------------------------
proc popu_sorted_evolve_13 {sorted_items mutprob} {


  # TODO: а зачем мне тут так хитро выедлять начальную треть группы?
  # потом от инх делаем остальные две трети, что не точно по целому значению.
  #
  # лучше просто задать нужные цифры, а список лидеров уже сортированный!

  # и вообще - это слишком простой вариант, нужно сначала добавлять, потом
  #            пересчитывать и потом уже убивать слабых

  set len [llength $sorted_items]

  #---------------------------------------
  # 1)
  # выделяем лидеров популяции  (1/3)

  
  set l [expr {$len/3}] ;# размер лидирующей группы
  
  set leaders_items [lrange $sorted_items 0 [expr {$l-1}]]
  
  #if {$is_print} {puts "LEADERS = $leaders \n"}
    

  #---------------------------------------
  # 2)
  # генерируем другую 1/3  популяции отпрысками от случайных лидеров
 
  
  set o $l ;# сгенерим столько же отпрысков от лидеров

  set offsprings_prg   [make_offsprings_from_leaders  $sorted_items $o]
  
  #puts stderr "popu_sorted_evolve_13: offsprings_prg = $offsprings_prg"

  set offsprings_items [make_itemslist_from_prgpop     $offsprings_prg]


  #---------------------------------------
  # 3)
  # генерируем последнюю 1/3 популяции мутируя лидеров
  
  
  set m [expr {$len - ($l + $o)}]  ;# сделаем сколько-то мутантов

  set mutated_items  [make_mutated_from_leaders  $sorted_items $m  $mutprob]

  #dict_print_real_all_in_list  "popu_sorted_evolve_13"  $mutated_items

  #---------------------------------------
  # отделяем "leaders" от фитнеса и делаем обычный спсок программ-исходников ??
  #
  #set leaders_prg [erase_fit_from_list $leaders_items]
 
  #---------------------------------------
  # склеиваем три популяции исходников (лидеров, отпрысков, мутантов)
  # создавая популяцию исходников для следующей итерации.
  #
  #set pop [concat $leaders_prg $offsprings_prg $mutated_prg] ;# новая популяция на месте
                                                      # старой ??
  # заного собираем из исходников итемы, т.е. агентов популяции
  # 
  #set offsprings_items [make_itemslist_from_prgpop  $offsprings_prg]
  #set mutated_items    [make_itemslist_from_prgpop  $mutated_prg] 
  #---------------------------------------


  set pop_items   [concat $leaders_items   $offsprings_items   $mutated_items] 
  
  return $pop_items
}
#-------------------------------------------------------------------------------
# proc pop_create_simp {} {
    

#   set p [dict_create]

#   return $p
# }
#-------------------------------------------------------------------------------
proc print_best {task  best_item is_print game_print_proc} {

  set fitnessfunc [GET $task "fitness_proc"]  


  # печатаем лучшую особь итерации ():

  set prg [item_get_main_src  $best_item]
  set ftn [item_get_fitn      $best_item]

  if {$is_print} {  

    #puts "  BEST: '$prg' with fitness $ftn"
    puts "================================================"
    puts ""
    puts "PRINT BEST: '$prg' with fitness $ftn"

    #puts stderr "game_print_proc = $game_print_proc"
    puts ""

    # здксь печатаем пользовательскую картинку, типа поля игрового
    # 

    if {$game_print_proc != 0}  {

      item_calc_fitness  $best_item $fitnessfunc   $task

      # далее не лучшее печатается, а последнее !!!
      #
      # 
      #t~.tl ANTS ANTS_gp_new  2002 15 15 2     
      #
      $game_print_proc;#     # -> game_print -> pole_print 
      #
      #
      # можно попробовать передавать параметром номер
    }
  }
  
  #return $best_item
}
#-------------------------------------------------------------------------------
proc popu_sort_command {a b} {

  set a_fit [item_get_fitn  $a]
  set b_fit [item_get_fitn  $b]

  #set ::sort_driver "LT_lsort"

  return [$::sort_driver $a_fit $b_fit] ; # т.е МЕНЬШИЕ будут слева в списке 
}
#-------------------------------------------------------------------------------
proc gp_pop_calc_fitness_all_and_print {task pop  itemspop fitnessfunc} {

  set fitnessfunc [GET $task "fitness_proc"]  
  set itemslist   [GET $pop  "itemslist"] 

  set i 1
  
  foreach item $itemspop {

    item_print_fitness_calc  $task $item $i ;#$fitnessfunc

    incr i
  }

  puts ""

  return
}
#-------------------------------------------------------------------------------
proc gp_pop_calc_fitness_all {task pop  itemspop fitnessfunc} {

  set fitnessfunc [GET $task "fitness_proc"]  
  set itemslist   [GET $pop  "itemslist"] 

  set i 1
  
  foreach item $itemspop {

    item_calc_fitness  $item $fitnessfunc    $task

    incr i
  }

  return
}
# ------------------------------------------------------------------------------
proc is_check_generation_break_gp {pop i max_generations 
                                   is_print} {

  set steps $max_generations

  if {$i >= $steps} {
    return $::true
  } 
  
  if {$is_print} {
    puts "EVOLVE ..................................... i = $i \n"    
  }

  return $::false
}
# ------------------------------------------------------------------------------
proc gp_evolution_main {task  pop max_generations 
                          {is_print        1}    
                          {game_print_proc 0}    
                          {mutprob         0.1}  
                          {fit_error       0.01} 
                        } {

  set fitnessfunc [GET $task "fitness_proc"]  
  set itemslist   [GET $pop  "itemslist"] 

  # запускаем каждую программу, и формируем список из нее и ее фитнеса
  #  
  gp_pop_calc_fitness_all  $task $pop  $itemslist $fitnessfunc


  set steps $max_generations
  puts stderr ""
  puts stderr "steps = $steps"
  puts stderr ""

  SET $pop "generation" 0
  set i 0

  set fit_target [GET $task "fit_target"]
  set fit_error  [GET $task "fit_error"]

  # ---------------------------------------------------------------------
  # 
  while {1} {

    set i [GET $pop "generation"]
    
    if [is_check_generation_break  $pop $i $max_generations \
          $fit_target $fit_error \
          $::is_print] {
      
      return false
    }
  
    #----------------------------------------------
    # запускаем каждую программу, и формируем список из нее и ее фитнеса
    #  
    gp_pop_calc_fitness_all_and_print  $task $pop  $itemslist $fitnessfunc
    
    
    # сортируем особей по фитнесу (низкий фитнес идет влево == лучше)
    #  
    set sorted_items [lsort -command "popu_sort_command" $itemslist]
    

    set best_item [lindex $sorted_items 0]
    #
    # а потому-что печать игры идет с этой последней
    #
    print_best  $task $best_item  $is_print $game_print_proc ;# $fitnessfunc 


    # а это основная эволюция:
    # 
    set itemslist [popu_sorted_evolve_13  $sorted_items  $mutprob]
    #
    #----------------------------------------------

    if {$is_print} {
      puts ""
    }

    incr i
    SET $pop "generation" $i ;# $generation
  }
  

  return
}
# ------------------------------------------------------------------------------

class_create 0 BOT {} {

  ;# _это_перечисление_переменных
  
  name  ""
  task  ""
  pop   ""

} {
  # а это конструктор класса 

  #     if {! [info exists task]} {
  #       set task [dict_parse $args "-task" ] 
  #     }
  
  set task [dict_parse $args "-task" \
              [task_create  "FS_fitness" -fit_target 53.1]] 
  
  set obj [SELF]
  
  $obj SET_task $task
  $obj SET_name [dict_parse  $args  "-name" "BotName"]
  $obj SET_pop  [dict_parse  $args  "-pop"  ""] 
  
}

#---------------------------------------------------------
#oo::define BOT  method init {args} {}
class_method  BOT  init {args} {
  
  pop_initial_score_and_sort  $pop $task ;# инициация итемов функцией [GET $pop seed]  

}
#---------------------------------------------------------
#oo::define BOT  method calc {args} }{
class_method BOT  calc {args} {
  
  set obj [self]
  
  variable task
  set task            [dict_parse $args "-task"  [$obj GET_task]] 
  set max_generations [dict_parse $args "-steps"] 
  
  variable pop
  #set  pop [$obj GET_pop]
  
  #pop_initial_score_and_sort  $pop $task ;# инициация итемов функцией [GET $pop seed]  
  my init
  
  ga_evolution_main           $task $pop $max_generations ;# 0.01
  
  #set ret [ga_evolution  $task $pop $max_generations]  
}
#---------------------------------------------------------
class_method BOT final {} {
    
  set obj [self]
  
  set pop [$obj GET_pop]
  
  set num_generations [GET $pop "generation"] ;# сколько было генераций
  set best_entity     [ga_get_entity_from_rank $pop 0]
  set ch_form         [GET $pop "ch_form"]
  
  return [list  $num_generations $best_entity $ch_form]
}
# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------

class_create 0 BOT33 {BOT} {

  # это перечисление переменных
  
} {
  # а это конструктор класса 

  puts stderr "BOT33: args = |$args|"
  puts stderr ""

  set args [lindex $args 0] ;# передаем аргументы целым списком, как в JIM

  puts stderr "BOT33: args = |$args|"
  puts stderr ""

  SUPER constructor {*}$args
  
  # если нет в args, то берем значение здесь
  # 
  set task [dict_parse $args "-task" \
              [task_create  "FS_fitness_list"]] 
  
  #set len_chromosomes [dict_parse $args "-lgen" ] 
  #set population_size [dict_parse $args "-lpop" ] 
  
  [SELF] SET_task $task
  
  #-----------------------------------------------
  # 
  if {$::__JIM__} {

    set ::NEWPOP 1
    set pop [POP new     $args]

  } else {
    set pop [POP new  {*}$args]
  }

  
  #-----------------------------------------------

  set sort_driver [dict_parse $args "-sort_driver" "LT_lsort"] 
  # 
  # "LT_lsort" ;# с меньшим фитнесом - влево. т.е. в лучшие!
  #
  set      ::sort_driver $sort_driver
  SET $pop "sort_driver" $sort_driver
  
  
  SET $pop  ch_form "%c" 
  SET $pop  "generation_hook" NULL ;# $generation_hook
  
  #-----------------------------------------------
  
  [SELF] SET_pop  $pop
  #my SET_pop  $pop
}

#-----------------------------------------------------------
class_method BOT33 calc {args} {
  
  set obj [SELF]
  
  set task [dict_parse $args "-task" [$obj GET_task]] 
  
  if {! [info exists max_generations]} {
    set max_generations [dict_parse $args "-steps" ] 
  }
  
  set  pop [$obj GET_pop]
  
  set is_print         [dict_parse $args "-is_print"        1]
  set game_print_proc  [dict_parse $args "-game_print_proc" 0]
  set mutprob          [dict_parse $args "-mutprob"         0.1]
  
  
  set randpop_proc [dict_parse $args "-randpop_proc"  "make_rand_prgpop"]
  
  # создаем начальную популяцию итемов-программ (формат 11 или 22 ??)
  #
  
  set population_size [GET $pop "stable_size"]
  set len_chromosomes [GET $pop "len_chromosomes"]
  
  set itemslist [make_itemslist  \
                   $randpop_proc \
                   $population_size $len_chromosomes   $is_print]
  
  SET $pop "itemslist" $itemslist
  
  gp_evolution_main  $task $pop  $max_generations \
    $is_print        \
    $game_print_proc \
    $mutprob  
  
  return
}
#-----------------------------------------------------------
class_method BOT33  final {} {
  
  set obj [SELF]
  
  set  pop [$obj GET_pop]
  
  set num_generations [GET $pop "generation"] ;# сколько было генераций   
  set best_entity     [ga_get_entity_from_rank $pop 0]
  set ch_form         [GET $pop "ch_form"]
  
  return [list $num_generations $best_entity $ch_form]
}
#-----------------------------------------------------------

# ------------------------------------------------------------------------------
proc bot33_create {args} {


  #set obj [BOT33 new {*}$args]

  puts stderr "bot33_create: args = |$args|"
  puts stderr ""

  set obj [BOT33 new $args]

  return $obj
}
# ------------------------------------------------------------------------------
proc bot33_calc {obj args} {


  return [$obj calc {*}$args]
}
# ------------------------------------------------------------------------------
proc bot33_final {obj} {


  return [$obj final {*}$args]
}
#-------------------------------------------------------------------------------
proc run_gp_evolution {randpop_proc 
                       population_size  len_chromosomes 
                       fitnessfunc  sort_driver
                       mutprob 
                       max_generations   is_print 
                       {game_print_proc 0} 
                     } {


  random_seed 0 ;# ?? mysrand 2013

  #-------------------------------------

  set task [task_create $fitnessfunc]

  #-------------------------------------

  set obj \
    [bot33_create  -lpop $population_size -lgen $len_chromosomes \
       -sort_driver $sort_driver  -task $task]

    
  # создаем начальную популяцию итемов-программ (формат 11 или 22 ??)
  # и  выпоняем эволюционный поиск 

  bot33_calc  $obj  \
    -steps           $max_generations \
    -task            $task \
    -is_print        $is_print        \
    -game_print_proc $game_print_proc \
    -mutprob         $mutprob \
    -randpop_proc    $randpop_proc


  return
}
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------

set ::NEW 0

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#proc FS_fitness_list {list_calc {prog @}} {}
proc FS_fitness_list {list_calc} {

  # list_calc - 
  # 

  set list_true [split $::target_text ""]

  set len_true [llength $list_true]
  set len_calc [llength $list_calc]


  set fit 0 ;# начальное значение фитнес 

  for {set i 0} {$i < $len_true} {incr i} {
    
    set char_true [lindex $list_true $i]
    set char_calc [lindex $list_calc $i]
    
    if {$::NEW} {
      set char_true_decm  [scan   $char_true "%c"] ;# по символу берем его номер
      set char_calc_decm  [scan   $char_calc "%c"] ;# по символу берем его номер
      
      #puts stderr "FS_fitness_list_NEW: char_true_decm = $char_true_decm  char_calc_decm = $char_calc_decm "
      
      set fit [FS_fitness_one_calc_add  $fit  $char_calc_decm $char_true_decm]
    } else {

      if {$char_true != $char_calc} {
        incr fit ;# если не совпадают, просто увеличиваем на 1
      }
    }

  }

  if {$::NEW} {
  } else {

    # и еще добавляем разницу в длинах
    # 
    incr fit [expr {abs ($len_calc - $len_true)}] 
    
    # но попробуем возвращать отрицательное значение, чтоб удовлетворять
    # стандарту : лучшие слева, с  большим фитнесом (пусть и отрицательым )
    
    set fit [expr - $fit]
    
    #puts "fit = $fit"   
    #  return [expr - $fit]
  }

  return $fit
}
#-------------------------------------------------------------------------------
proc FS_fitness_list_NEW {list_calc} {

  set ::NEW 1

  #return [FS_fitness_list  $list_calc $prog]
  return [FS_fitness_list  $list_calc]

}
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
# g_stru.tl _gp_test 2013 10 6 10
#-------------------------------------------------------------------------------
proc _gp_test {} {

  # FINS STRUCT - ищем пока простто структуру

  set ::target_text "122333444455555"

  global argc

  if {$argc == 1} {

    #puts "GP ... test !! \n"
    #exit

    set bnums 10 ;# population_size
    set bsize 15
    set steps  5 ;# 1 ;# max_generations 
    
    #mysrand 2013 ;# ???
     
    set ::len_is_constant 1 ;# g-corB.tl -> make_prgpop : постоянной длины
    set ::is_fitn_first   0 ;# g-corA.tl -> item_print_fitness_calc
    
  } else {

    # берем данные из командной строки: k~.tl TEST FS  @  20 15 100
    #                                   cd ../others ; h_stru.tl FS
    incr ::ind0

    set bnums ""
    set bsize ""
    set steps ""

    parse_opt_seed_3_new  bnums bsize steps 

    # if ! @ -> mysrand var 
  }

  # ------------------------------------------------

  set  fitnessfunc  "FS_fitness_list"
  #set  fitnessfunc  "FS_fitness_list_NEW"

  set  sort_driver  "GT_lsort" 

  # ------------------------------------------------

  # FINS STRUCT - ищем пока простто структуру

  #random_seed 0 ;# ?? mysrand 2013

  puts ""
  puts "GP_find ..."
  puts ""
  puts "bnums  = $bnums"  ;# колич-во ботов
  puts "bsize  = $bsize"  ;# макс. длина ботов (при начальном старте?)
  puts "steps  = $steps"  ;# шагов эволюции  
  puts ""


  set is_print 1
  #DebugOn

  set ::gp_list   "1 2 3 4 5 6 7 8 9" ;#   

  set randpop_proc "make_rand_prgpop" ;# "make_rand_prgpop_unikum"
    
  #set ::randinstr  "randinstr_NEXT"

  run_gp_evolution  $randpop_proc \
                    $bnums $bsize \
    $fitnessfunc $sort_driver \
    0.1  $steps $is_print 0 ;# not game print

  # ------------------------------------------------

  return
}
#-------------------------------------------------------------------------------
# g_stru.tl _gp_test 2013 10 6 10

# g_stru.tl _gp_test 2013   10  6    1  - очень быстрый для проверок
# g_stru.tl _gp_test 2013   30  6  250


# ------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
