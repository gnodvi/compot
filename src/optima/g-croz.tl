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
proc gp_crossover {a b} {

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

  #puts stderr "gp_crossover:  $a  +  $b  = $x0  +  $x1"

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
    #set r [random_rand] - неверно, не в [0,1] !
    set r [random_double 1.0]
    #puts "............. gp_joy_mutate: r = $r,  prob = $prob"

    # заменяем итем-строку
    # 
    if {$r <= $prob} {
      set item [randinstr_NEXT $gp_list]
      #puts "................................ lset   item = $item"
      lset program $i $item ; # для Tcl-8.4            
    }

    #set r [expr {rand()}]
    #set r [random_rand]
    set r [random_double 1.0]
    #puts "............. gp_joy_mutate: r = $r,  prob = $prob"

    # добавляем итем-стрку
    # 
    if {$r <= $prob} {
      set item [randinstr_NEXT $gp_list]
      #puts "................................ linsert item = $item"
      set program [linsert $program $i $item]
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
      [gp_crossover $parent0_prg $parent1_prg] break
    

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
proc itemslist_sorted_evolution_3parts {sorted_items mutprob} {


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
  
  #puts stderr "itemslist_sorted_evolution_3parts: offsprings_prg = $offsprings_prg"

  set offsprings_items [make_itemslist_from_prgpop     $offsprings_prg]


  #---------------------------------------
  # 3)
  # генерируем последнюю 1/3 популяции мутируя лидеров
  
  
  set m [expr {$len - ($l + $o)}]  ;# сделаем сколько-то мутантов

  set mutated_items  [make_mutated_from_leaders  $sorted_items $m  $mutprob]

  #dict_print_real_all_in_list  "itemslist_sorted_evolution_3parts"  $mutated_items

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
proc print_best {i task  best_item is_print game_print_proc} {

  set fitnessfunc [GET $task "fitness_proc"]  


  # печатаем лучшую особь итерации ():

  set prg [item_get_main_src  $best_item]
  set ftn [item_get_fitn      $best_item]

  if {$is_print > 1} {  

    puts ""
    puts "================================================"
    puts ""
  }

  if {$is_print} {  

    puts [format "% 3d) BEST: '$prg' with fitness $ftn" $i]

    #puts stderr "game_print_proc = $game_print_proc"
    #puts ""

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
proc item_print_fitness {item i} {


  puts -nonewline [format "  %2d)" $i]
  
  #set src   [item_get_main_src   $item] 
  #set fitn  [item_get_fitn       $item] 

  # а если фитнес уже есть, зачем его вычилять ????????
  # 
  
  if {$::is_fitn_first} {

    set src   [item_get_main_src   $item] 
    set fitn  [item_get_fitn       $item] 
    
    puts [format "  fitn = % 3s :   %s" $fitn $src]
    
  } else {
    
    set src   [item_get_main_src   $item] 
    set fitn  [item_get_fitn       $item] 
    
    puts -nonewline [format "  %s     " $src]
    flush stdout               ;# все данные должны быть выведены
    
    puts [format "fitn = %s" $fitn]
  }
  #
  # item_print  $item
  
  return
}
#-------------------------------------------------------------------------------
proc gp_pop_calc_fitness_all {pop task} {

  set fitnessfunc [GET $task "fitness_proc"]  
  set itemlist    [GET $pop  "itemslist"] 
  
  foreach item $itemlist {

    item_calc_fitness  $item $fitnessfunc  $task
  }

  return
}
#-------------------------------------------------------------------------------
proc gp_pop_all_print {pop} {


  set itemspop   [GET $pop  "itemslist"] 

  set i 1
  
  foreach item $itemspop {

    item_print_fitness  $item $i ;###$fitnessfunc
    
    incr i
  }

  puts ""

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

  #set fitnessfunc [GET $task "fitness_proc"]  
  #set itemslist   [GET $pop  "itemslist"] 


  set steps $max_generations
  #puts stderr ""
  #puts stderr "steps = $steps"
  #puts stderr ""

  SET $pop "generation" 0
  set i 0

  set fit_target [GET $task "fit_target"]
  set fit_error  [GET $task "fit_error"]

  # ---------------------------------------------------------------------
  # 
  while {1} {

    set i         [GET $pop "generation"]
    set itemslist [GET $pop  "itemslist"] 
    

    # запускаем каждую программу, и формируем список из нее и ее фитнеса
    #  
    gp_pop_calc_fitness_all $pop $task ;#  $itemslist ;###$fitnessfunc

    #gp_pop_all_print        $pop ;# $itemslist 

    set itemslist   [GET $pop  "itemslist"] 
    #----------------------------------------------

    # сортируем особей по фитнесу (низкий фитнес идет влево == лучше)
    #  

    if {1} {
      set itemslist_sorted [lsort -command "popu_sort_command" $itemslist]
    
      set best_item [lindex $itemslist_sorted 0]
    
      SET $pop "itemslist" $itemslist_sorted

    } else {
      
      pop_sorting $pop "popu_sort_command"
      set best_item [GET $pop best]

    }

    if {$is_print > 1} {
      gp_pop_all_print     $pop ;# $itemslist 
    }
    #exit

    print_best $i  $task $best_item  $is_print $game_print_proc ;# $fitnessfunc 

    #----------------------------------------------

    if [is_check_generation_break  $pop $i $max_generations \
          $fit_target $fit_error \
          0] \
      {     
        return false
      }      
    #----------------------------------------------


    # а это основная эволюция:
    # 
    set itemslist [itemslist_sorted_evolution_3parts  $itemslist_sorted  $mutprob]
    #
    # после нее итемы не сортированы
    #

    #----------------------------------------------

    SET $pop "itemslist" $itemslist


    if {$is_print > 1} {
      puts ""
    }

    incr i
    SET $pop "generation" $i ;# $generation
  }
  

  return
}
#-------------------------------------------------------------------------------

#set ::NEWFITN 0

#set ::fit_target 53.1
set ::fit_target 55.213

# ------------------------------------------------------------------------------

dict_class_create BOT {} {

  ;# _это_перечисление_переменных
  
  name  ""
  task  ""
  pop   ""

} {
  # а это конструктор класса 

  if {0} {

    puts "dict_class_create BOT: args = $args"
    puts ""
    exit
  }

  set task [dict_parse $args "-task" \
              [task_create  "FS_fitness" -fit_target $::fit_target]] 
  
  #set obj [SELF]
  
  SET $obj "task" $task
  SET $obj "name" [dict_parse  $args  "-name" "BotName"]
  SET $obj "pop"  [dict_parse  $args  "-pop"  ""] 
  
}

#---------------------------------------------------------
proc calc_BOT {obj args} {
  
  
  #variable task
  set task            [dict_parse $args "-task"  [GET $obj "task"]] 
  set max_generations [dict_parse $args "-steps"] 
  
  #variable pop
  set  pop [GET $obj "pop"]
  
  pop_initial_score_and_sort  $pop $task ;# инициация итемов функцией [GET $pop seed]  
  #$obj init
  
  ga_evolution_main           $task $pop $max_generations ;# 0.01
  
  #set ret [ga_evolution  $task $pop $max_generations]  
}
#---------------------------------------------------------
proc final_BOT {obj args} {
  

  set pop [GET $obj "pop"]
  
  #puts ""
  #puts "BOT final: pop = [pop_print $pop]"

  set num_generations [GET $pop "generation"] ;# сколько было генераций
  set best_entity     [ga_get_entity_from_rank $pop 0]
  set ch_form         [GET $pop "ch_form"]
  
  return [list  $num_generations $best_entity $ch_form]
}
# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------

dict_class_create BOT33 {BOT} {

  # это перечисление переменных
  
} {
  # а это конструктор класса 

  #set obj [SELF]

  if {0} {
    puts stderr "class_create BOT33: args = |$args|"
    puts stderr ""
    #exit
  }

  # если нет в args, то берем значение здесь
  # 
  set task [dict_parse $args "-task" \
              [task_create  "FS_fitness_list"]] 
  
  SET $obj "task" $task
  
  set pop [POP new  {*}$args]

  set sort_driver [dict_parse $args "-sort_driver" "LT_lsort"] 
  # 
  # "LT_lsort" ;# с меньшим фитнесом - влево. т.е. в лучшие!
  #
  set      ::sort_driver $sort_driver
  SET $pop "sort_driver" $sort_driver
  
  SET $pop  ch_form "%s" 

  SET $obj "pop"  $pop
}

#-----------------------------------------------------------
proc calc_BOT33  {obj args} {
  
  #puts stderr "calc_BOT33: args = $args"
  
  set task [dict_parse $args "-task" [GET $obj "task"]] 
  
  if {! [info exists max_generations]} {
    set max_generations [dict_parse $args "-steps" ] 
  }
  
  set  pop [GET $obj "pop"]
  
  set is_print         [dict_parse $args "-is_print"        1]
  #puts "is_print = $is_print"
  #exit
  set game_print_proc  [dict_parse $args "-game_print_proc" 0]
  set mutprob          [dict_parse $args "-mutprob"         0.1]
   
  # создаем начальную популяцию итемов-программ (формат 11 или 22 ??)
  #  
  set randpop_proc     [dict_parse $args "-randpop_proc"  "make_rand_prgpop"]

  set population_size [GET $pop "stable_size"]
  set len_chromosomes [GET $pop "len_chromosomes"]
  
  if {0} {
  puts stderr ""
  puts stderr "calc_BOT33: randpop_proc    = $randpop_proc"
  puts stderr "calc_BOT33: population_size = $population_size"
  puts stderr "calc_BOT33: len_chromosomes = $len_chromosomes"
  puts stderr "calc_BOT33:             pop = $pop"
  dict_print $pop
  exit
  }

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
#---------------------------------------------------------
proc final_BOT33 {obj args} {
  

  set  pop [GET $obj "pop"]
  
  #puts "BOT33 final: pop = [pop_print $pop]"


  set num_generations [GET $pop "generation"] ;# сколько было генераций   

  set best_entity     [ga_get_entity_from_rank $pop 0] ;# ??? не сортирована !?

  set ch_form         [GET $pop "ch_form"]
  
  return [list $num_generations $best_entity $ch_form]

}
#-----------------------------------------------------------
# ------------------------------------------------------------------------------
proc bot33_create {args} {

  #puts stderr "bot33_create: args = $args"

  set obj [BOT33 new {*}$args]

  return $obj
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

  RUN1 "calc_" $obj \
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
set ::ITEMS_LIST 0

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#proc FS_fitness_list {list_calc {prog @}} {}
proc FS_fitness_list {list_calc task} {


  if {$::ITEMS_LIST} {
    set list_calc  [ent_get_chromosome_ $list_calc]
  }

  #set list_true [split $::target_text ""]
  set list_true $::target_text  ;# это список

  set len_true [llength $list_true]
  set len_calc [llength $list_calc]

  #puts stderr "FS_fitness_list: true = $list_true, calc = $list_calc"

  set fit 0 ;# начальное значение фитнес 

  # идем циклом по целевому списку? но ведь он может быть как больше так и меньше?
  # а надо бы идти по максимальному?
  # 

  if {$len_true > $len_calc} {
    set len_max $len_true
  } else {
    set len_max $len_calc
  }


  for {set i 0} {$i < $len_max} {incr i} {
    
    set char_true [lindex $list_true $i]
    set char_calc [lindex $list_calc $i]
    
    # -----------------------------------------------------------
    if {$char_true != $char_calc} {
      
      set is_true_integer [string is integer -strict  $char_true]
      set is_calc_integer [string is integer -strict  $char_calc]
      
      # если для конкретных типов отдельных генов возможна более 
      # точная метрика, то :
      
      if {$is_true_integer && $is_calc_integer} {
        incr fit [expr {abs ($char_calc - $char_true)}]
        
      } else {
        incr fit ;# а иначе просто увеличиваем на 1
      }
      
    }
    # -----------------------------------------------------------
  }
  
  # и еще добавляем разницу в длинах
  # 
  incr fit [expr {abs ($len_calc - $len_true)}] 
  
  # но попробуем возвращать отрицательное значение, чтоб удовлетворять
  # стандарту : лучшие слева, с  большим фитнесом (пусть и отрицательым )
  
  set fit [expr - $fit]
  

  return $fit
}
#-------------------------------------------------------------------------------

# g_stru.jm _gp_test 2013  20 5 -1
# 
#  561) BEST: '1 2 2 3 3 1 4 4 4 4 5 5 5 5 5' with fitness -1
#  562) BEST: '1 2 2 3 3 1 4 4 4 4 5 5 5 5 5' with fitness -1
#  563) BEST: '1 2 2 3 3 3 4 4 4 4 5 5 5 5 5' with fitness 0

#-------------------------------------------------------------------------------
# proc FS_fitness_list_NEW {list_calc} {

#   set ::NEWFITN 1

#   #return [FS_fitness_list  $list_calc $prog]
#   return [FS_fitness_list  $list_calc]

# }
#-------------------------------------------------------------------------------
# ищем пока простто структуру
#-------------------------------------------------------------------------------
# g_stru.tl _gp_test 2013 10 6 10
#-------------------------------------------------------------------------------
proc gp_fitness_test {item} {

  set task NULL

  puts "item = $item,  ret = [FS_fitness_list  $item $task] "

}
#-------------------------------------------------------------------------------
proc _gp_test {} {

  # FINS STRUCT - ищем пока простто структуру

  #set ::target_text "122333444455555"

  set ::target_text "1 2 2 3 3 3 4 4 4 4 5 5 5 5 5"

  global argc

  #set ::NEWFITN 1 ;# даже немного замедляет ?! 

  #----------------------------------------------------------------
  if {$argc == 1} {

    #set ::NEWFITN 1

    gp_fitness_test  "1 2 2 3 3 3 4 4 4 4 5 5 5 5 5"
    gp_fitness_test  "1 2 2 3 3 3 4 4 4 4 5 5 5 5 4"
    gp_fitness_test  "1 2 2 3 3 3 4 4 4 4 5 5 5 4 4"
    gp_fitness_test  "1 2 2 3 3 3 4 4 4 4 5 5 5 0 0"
    gp_fitness_test  "0 0 0 0 0 0 0 0 0 0 0 0 0 0 0"
    gp_fitness_test  "0 0 "
    gp_fitness_test  "0 "
    gp_fitness_test  "0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0"

    puts ""

    exit

#     set bnums 10 ;# population_size
#     set bsize 15
#     set steps  1 ;# 1 ;# max_generations 
    
#     set ::len_is_constant 1 ;# g-corB.tl -> make_prgpop : постоянной длины
#     set ::is_fitn_first   1 ;# 0 ;# g-corA.tl -> item_print_fitness
    
  #----------------------------------------------------------------
  } else {
  #----------------------------------------------------------------

    # берем данные из командной строки: k~.tl TEST FS  @  20 15 100
    #                                   cd ../others ; h_stru.tl FS
    incr ::ind0

    set bnums ""
    set bsize ""
    set steps ""

    parse_opt_seed_3_new  bnums bsize steps 

    # if ! @ -> mysrand var 
  }
  #----------------------------------------------------------------

  set randpop_proc "make_rand_prgpop" ;# "make_rand_prgpop_unikum"    

  #set ::randinstr  "randinstr_NEXT"
  #set ::len_is_constant 1 ;# g-corB.tl -> make_prgpop : постоянной длины


  set  fitnessfunc  "FS_fitness_list"
  #set  fitnessfunc  "FS_fitness_list_NEW"

  set  sort_driver  "GT_lsort" ;## большие влево?

  # ------------------------------------------------

  #random_seed 0 ;# ?? mysrand 2013

  #puts ""
  #puts "GP_find ..."
  puts ""
  puts "bnums  = $bnums"  ;# колич-во ботов
  puts "bsize  = $bsize"  ;# макс. длина ботов (при начальном старте?)
  puts "steps  = $steps"  ;# шагов эволюции  
  puts ""



  set is_print 1
  set ::gp_list   "1 2 3 4 5 6 7 8 9" ;#   

  run_gp_evolution  $randpop_proc \
                    $bnums $bsize \
    $fitnessfunc $sort_driver \
    0.1  $steps  $is_print 0 ;# not game print

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
