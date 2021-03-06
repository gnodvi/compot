# -*-   mode: tcl  ; coding: koi8   -*- ----------------------------------------

#-------------------------------------------------------------------------------

# #!/bin/sh
# # the next line restarts using tclsh \
# exec tclsh "$0" "$@"

#-------------------------------------------------------------------------------

source "g_0000.tl"

load T/tclgaul.so gaul

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------

snit::type TASK {
  #
  #option -goal ""
  variable goal ""
  variable name "GENA"

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  method _goalset {} {
        
    set goal [genrand 100 10] ;# генерируем 10 целевых чисел (их ищем)

  }
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  method _goalget {} {
        
    return $goal
  }
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  method _goalgetname {} {
        
    return $name
  }
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  method _evaluate {entity} {
    
    global goal ;# 10 чисел до 100
    # их и будем просто искать 
    
    #puts "EVALUATE: name= $name  entity= $entity"
    #EVALUATE: name= pop  entity= 78 2 29 46 76 70 55 41 18 95
    
    # это видимо максимально возможное суммарное отклонение, он же наилучший (здесь)
    # фитнес ..?
    # 
    set result [expr {100 * 10}]
    
    for {set i 0} {$i < 10} {incr i} {
      
      set n_goal [lindex $goal    $i]
      set n_real [lindex  $entity $i]
      
      incr result [expr {-1 * abs ($n_goal - $n_real)}]
      #
      # уменьшаем (ухудшаем) фитнес на величину локального отклонения
    }
    
    #puts "Evaluate: $result"
    
    return $result
  }
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  
}

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------

namespace eval TESTLIST {

   namespace export test_list_memt

#-------------------------------------------------------------------------------

#source "../common/a-comm.tl"

#-------------------------------------------------------------------------------
proc genrand {max num} {

  set result [list]
  
  for {set i 0} {$i < $num} {incr i} {
    lappend result [expr {int($max * rand())}]
  }
  
  return $result
}
#-------------------------------------------------------------------------------
# This procedure is executed at the end of each generation, starting from 0. If 
# it generates a Tcl error, the evolution process terminates prematurely; thus, 
# it can be used to introduce custom termination criteria.
#-------------------------------------------------------------------------------
proc generation {name gen} {

  puts "Generation $gen: "
  #puts "\nGeneration $gen: [pop stats]\n"
  
  #foreach member [pop list] {
  #    puts "\t$member"
  #}
}
#-------------------------------------------------------------------------------
# фитнес-функция для задачи поиска идентичного списка
#
# т.е. при полном совпадении получим максимально возможное значение?
# fitness - приспособленность или плохость? здесь получается 1-е.
# 
# Фитнес-функция - это целевая функция, т.е. мера точности решения или мера
# удовлетворения решению задачи. Увеличением значения фитнес-функции и занимается
# генетический алгоритм. <-  http://www.gamedev.ru/code/terms/Genetic_Algorithm

# Но.. чем меньше число, тем ближе результат к желаемому значению.
# <- http://habrahabr.ru/post/128704/

# fit     - соответсвующий, подходящий, приспособленный
# fitness - фитнес, пригодность, приспособленность, соответствие
#
# ness - мыс, нос
# less - суффикс: без, не сущиствительное: меньший
# 
#-------------------------------------------------------------------------------
#
# This procedure determines the fitness of each member of the population. It must 
# return a floating-point number that indicates the fitness of the member. 
# The higher this number, the greater the fitness.
# Arguments:
# name : The name given to the population in the gaul create command.
# member : The member to be evaluated.
#
#-------------------------------------------------------------------------------
proc evaluate {name entity} {
  
  global goal ;# 10 чисел до 100
               # их и будем просто искать 
  
  #puts "EVALUATE: name= $name  entity= $entity"
  #EVALUATE: name= pop  entity= 78 2 29 46 76 70 55 41 18 95

  # это видимо максимально возможное суммарное отклонение, он же наилучший (здесь)
  # фитнес ..?
  # 
  set result [expr {100 * 10}]
  
  for {set i 0} {$i < 10} {incr i} {

    set n_goal [lindex $goal    $i]
    set n_real [lindex  $entity $i]

    incr result [expr {-1 * abs ($n_goal - $n_real)}]
    #
    # уменьшаем (ухудшаем) фитнес на величину локального отклонения
  }


  #puts "Evaluate: $result"

  return $result
}
#-------------------------------------------------------------------------------
# This procedure is called before the evolution starts in order to initialize all 
# the members of the population. It must return the newly initialized member.
#-------------------------------------------------------------------------------
proc seed {name entity} {

  set seed [genrand 100 10] ;# список из 10-ти случайных до 100
  
  puts stderr "Seed: $seed"

  return $seed
}
#-------------------------------------------------------------------------------
# This functionality is only available on Lamarckian and Baldwinian evolutionary 
# schemes. The specified procedure is called for every member of the population 
# in order to "adapt" it before it is evaluated at the end of the generation.
#-------------------------------------------------------------------------------
proc adapt {name entity} {

  #puts "Adapt"
  return $entity
}
#-------------------------------------------------------------------------------
# This procedure is executed to mutate a single member. The mutated member is
# expected to be returned.
#-------------------------------------------------------------------------------
proc mutate {name entity} {
  
  #puts "Mutate: original: $entity"
  lset entity [genrand 10 1] [genrand 100 1]
  #puts "Mutate: mutated:  $entity"
  
  return $entity
}
#-------------------------------------------------------------------------------
# This procedure is invoked to mate/breed two members. A list of two offsprings 
# are expected to be returned by the procedure.
#-------------------------------------------------------------------------------
proc crossover {name entity1 entity2} {

  #puts "Crossover: Father: $entity1"
  #puts "Crossover: Mother: $entity2"
  set cross [genrand 10 1]
  #puts "Crossover: cross: $cross"

  set child1 [concat [lrange $entity1 0 $cross-1] [lrange $entity2 $cross end]]
  set child2 [concat [lrange $entity2 0 $cross-1] [lrange $entity1 $cross end]]

  #puts "Crossover: Child1: $child1"
  #puts "Crossover: Child2: $child2"
  
  return [list $child1 $child2]
}
#-------------------------------------------------------------------------------
# 
#-------------------------------------------------------------------------------

# name params ..  Set population parameters.

# The -scheme switch sets the evolutionary scheme. The Darwinian scheme 
# corresponds to the standard genetic algorithm, which only considers natural 
# selection. On the other hand, the Baldwinian/Lamarckian schemes also consider 
# the ability of each member to adapt (or improve on its own) giving higher 
# survival chance to those members that can better adapt.

# In the Baldwinian scheme the members are adapted and their new form is 
# re-evaluated. The greater the fitness of the adapted form, the higher the 
# chances for its genes to appear in the next generation. However, the GA 
# operators are performed on the previous/original form of the member (before 
# the adaption). The Lamarckian scheme is like the Baldwinian, but the members 
# retain the adapted form and the GA operators are perfomed on the adapted form.

# In particular, the acceptable values for this switch are:

# dawrin  This corresponds to the standard GA. No adaption is performed/considered 
#         in this case.
# lamarck_parents
#         Lamarckian evolution for parents only performed immediately after "birth".
# lamarck_children
# 	Lamarckian evolution for children only performed immediately after "birth".
# lamarck_all
#         Lamarckian evolution for the entire population at every generation, not 
#         just the parents or children at the moment of "birth". This allow ongoing 
#         adaptation or learning, rather than just a single chance immediately after 
#         "birth".
# baldwin_parents
#         Baldwinian evolution for parents only performed immediately after "birth".
# baldwin_children
#         Baldwinian evolution for children only performed immediately after "birth".
# baldwin_all
#         Baldwinian evolution for entire population.
# lamarck_parents_baldwin_children
#         Lamarckian evolution for the parents and baldwinian for the children.
# lamarck_children_baldwin_parents
#         Baldwinian evolution for the parents and lamarckian for the children.
	

# The -elitism switch sets the rules for the passage of parent individuals into 
# subsequent generations. The meaning of the possible values is:
	
# parents
#         All parents that rank sufficiently highly will pass to the next generation.
# one_parent
#         The single fittest parent will pass to the next generation if it ranks 
#         sufficiently well.
# parents_die
#         No parents pass to next generation, regardless of their fitness.
# rescore_parents
	
# All parents are re-evalutated, and those that subsequently rank sufficiently 
# highly will pass to the next generation.
	

# The -mutation and -crossover switches set the propability that a 
# mutation/crossover will occur on a member of the population on every 
# generation. It must be a flowating point number from 0 to 1. The default is 
# 0.1 for mutation and 0.9 for crossover.

#-------------------------------------------------------------------------------

# The -select_one type is used when selecting members for mutation, whereas 
# the -select_two type is used in the crossover operator. Both switches accept 
# one of a fixed number of selection operators:
	

# RANDOM   Random selection of entities, irrespective of their fitnesses/ranks.
# EVERY    Every entity (or combination of entities) will be systematically selected. 
#          The mutation and crossover ratios are ignored by these selection functions.	
# RANDOMRANK
#          Systematically select each entity in turn along with a random, more fit, 
#          entity. The select_one function doesn`t return the systematically 
#          selected entity.
# BESTOF2  Simple pairwise tournament selection.
# BESTOF3  Simple three-way tournament selection.
# ROULETTE Standard roulette wheel selection.
# ROULETTE_REBASED
#          Standard roulette wheel selection.
# SUS      Universal stochastic sampling.
# SUSSQ    Universal stochastic sampling.
# AGGRESSIVE
#          Random selection, but heavily biased toward fit entities.
# BEST     Select the single best entity only. The select_two function also selects 
#          a random entity.
# LINEARRANK
#          Select an entity based on linear probability distribution with respect 
#          to rank.
# ROUNDROBIN
# 	 elect entities using a round-robin algorithm. Each entity is selected 
#          in turn, returning to the first once the last entity has been 
#          selected. This option is not available to -select_two switch.
	
# The default value for both selection switches is SUS.

#-------------------------------------------------------------------------------
proc make_TASK {} {
  

  set t [TASK create %AUTO%]

  #$t _goalset ; можно пока не делать, чтобы не сбивать случайный ряд!

  return $t
}
#-------------------------------------------------------------------------------
proc test_list_memt {selone seltwo} {
  
  global goal 

  #set srand_init [seedrand_from_argv] ;# парсинг ком.строки и локальная установка 
  
  set srand_init [get_srand_from_argv 2]
  #set srand_init 2013
  
  #puts "srand_init = $srand_init"
  #exit
  
  #set_srand_local_and_gaul $srand_init
  #
  expr {srand ($srand_init)} 
  #load T/tclgaul_gena.so Gaulgena
  
  set goal [genrand 100 10] ;# генерируем 10 целевых чисел (их ищем)
  puts stderr "GOAL = $goal"
  
  #set t [make_TASK] 
  #puts "GOALNAME = [$t _goalgetname]"

  gaul create  pop 100 \
           -generation_hook generation \
           -evaluate        evaluate   \
           -seed            seed       \
           -adapt           adapt      \
           -mutate          mutate     \
           -crossover       crossover  \
           -select_one      $selone    \
           -select_two      $seltwo     

#     -select_one SUS \
#     -select_two SUS

  #puts "P = $p" ;# т.е. нефига не возвращает объект !?
  #exit

  # 
  load T/tclgaul_gena.so Gaulgena
  gaulgena  -seedrand $srand_init ;# переустановим random_seed
  
 	

  # Set population parameters.
  # 
  pop params -scheme lamarck_all -elitism parents_die \
             -crossover 0.900000 \
             -mutation  0.100000 \
             -migration 0.100000
  
  # так седлано в g_memt:
  # 
  #pop params {*}[pop params] - это и не надо тогда!

  puts ""
  puts "Params: [pop params]"
  puts ""
  
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # 
  pop seed
  pop evolve 50 ;# regular
  # 
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  
  #pop evolve 50 -forked
  #pop evolve 50 -mpi ;# XXX Not tested.
  #pop evolve 50 -threaded ;# XXX Segmentation fault
  #pop evolve 50 -steady_state ;# FATAL ERROR: Dodgy replacement requested.
  
  puts ""
  puts "=========================================================="
  puts ""
  
  puts "Goal    : $goal"
  puts "Solution: [pop solution]"
  puts "Stats   : [pop stats]"
  puts ""
  
  # распечатаем максимальных членов популяции (?)
  # 
  #foreach {member rank} [pop rank] {
  #    puts "\t$rank\t$member"
  #}
  
  pop destroy
  
}
#-------------------------------------------------------------------------------
 
} ;# namespace TESTLIST

#-------------------------------------------------------------------------------
proc TEST_list {} {
 
  set selone "RANDOM"
  set seltwo "RANDOM"

#   set selone "SUS" ;# как в g_memt.tl 
#   set seltwo "SUS"

  #test_list_memt  $selone $seltwo

  TESTLIST::test_list_memt  $selone $seltwo

  #
  # gaul-t/g_prox.cc/Proxy_seed/TclEvalObj: TCL_EVAL_GLOBAL -> NULL 
  #  //
  #  // сработало, но почему-то результат не очень ! 
  # да просто надо было везде поменять , во всех функциях !

  return
}
#-------------------------------------------------------------------------------

#TEST_list

#-------------------------------------------------------------------------------

# g~.tl TEST_list 2013

# Generation 48: 
# Generation 49: 
# Generation 50: 

# ==========================================================

# Goal    : 78 3 26 46 76 70 55 42 53 98
# Solution: 78 2 29 46 76 70 55 41 53 95
# Stats   : max 992.0 min 991.0 mean 991.61 median 991.5 variance 0.2379000000000003 stddev 0.48774993593028826 kurtosis 1.2034468263976945 skew -0.451050802457685

#-------------------------------------------------------------------------------
