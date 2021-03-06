# -*-   mode: tcl  ; coding: koi8   -*- ----------------------------------------

#!/bin/sh
# the next line restarts using tclsh \
exec tclsh "$0" "$@"

#-------------------------------------------------------------------------------

source "./a-comm.tl"
#package require common 1.0

#-------------------------------------------

source "g_0000.tl"

# загружаем библиотеку и вызываем инициализирующую процедуру
# 
load T/tclgaul.so gaul

#-------------------------------------------------------------------------------
# общая процедура генерации случайного списка
#-------------------------------------------------------------------------------
proc genrand {max num} {

  set result [list]
  
  for {set i 0} {$i < $num} {incr i} {
    lappend result [expr { int($max * rand()) }]
  }

  return $result
}
#-------------------------------------------------------------------------------

variable goal 

#-------------------------------------------------------------------------------

snit::type TASK_LIST {


  #-----------------------------------------------------------------------------
  method goal_init {} {
    
    global goal 
    
    set goal [genrand 100 10]
    
    return $goal
  }
  #-----------------------------------------------------------------------------
  method _evaluate {entity} {
    
    global goal
    
    set result [expr 100 * 10]
    
    for {set i 0} {$i < 10} {incr i} {
      
      set n_goal [lindex $goal    $i]
      set n_real [lindex  $entity $i]
      
      incr result [expr {-1 * abs($n_goal - $n_real)}]
    }

    #puts "Evaluate: $result"
    
    return $result
  }
  #-----------------------------------------------------------------------------

}

#-------------------------------------------------------------------------------

snit::type SOLV_LIST {

#option -taskobj ""
variable taskobj "RRR"

#variable goal ;# в случаем с namespace - переменная станет обязательно ее частью, 
# а не глобальной области вдруг случайно


#-------------------------------------------------------------------------------
proc generation {name gen} {

  puts "Generation: $gen"
  
  # XXX puts [pop list]
}
#-------------------------------------------------------------------------------
proc _evaluate {entity} {

  global goal
  
  set result [expr 100 * 10]
  
  for {set i 0} {$i < 10} {incr i} {

    set n_goal [lindex $goal    $i]
    set n_real [lindex  $entity $i]

    incr result [expr {-1 * abs($n_goal - $n_real)}]
  }

  #puts "Evaluate: $result"

  return $result
}
#-------------------------------------------------------------------------------
# A Snit proc is really just a Tcl proc defined within the type's namespace. 
# You can use procs for private code that isn't related to any particular instance. 
#-------------------------------------------------------------------------------
method evaluate {name entity} {
  #proc evaluate {name entity} {}

  puts stderr "proc evaluate ................. 1"

  #set result [_evaluate $entity]

  #set t $options(-taskobj)
  
  variable taskobj ;# если явно указать, то вообще ни одна ветка не выполняется !
  #
  #???????????????????????
  #global taskobj 

  # HOW DO I MAKE AN INSTANCE VARIABLE PUBLIC?
  # Practically speaking, you don't. Instead, you'll implement public variables 
  # as OPTIONS. Alternatively, you can write INSTANCE METHODS to set and get 
  # the variable's value. 

  # почему-то не печатает, наверное перехватывает 
  #                                   ошибку прерывания
  puts stderr "proc evaluate ................. 2"

  if {[catch {puts stderr "taskobj = $taskobj"} message]} {
    puts stderr "MESSAGE = $message"
  } else {
    puts stderr "OK....."
  }
  #
  #puts stderr "taskobj = "
  #   exit

  puts stderr "proc evaluate ................. 3"
  puts stderr ""

  set result [$taskobj _evaluate $entity]

  #set result [_evaluate $entity]

  return $result
}
#-------------------------------------------------------------------------------
proc seed {name entity} {

  set seed [genrand 100 10]

  #puts "Seed: $seed"

  return $seed
}
#-------------------------------------------------------------------------------
proc adapt {name entity} { ;# XXX

  #puts "Adapt"

  return $entity
}
#-------------------------------------------------------------------------------
proc mutate {name entity} {

  #puts "Mutate: original: $entity"
  lset entity [genrand 10 1] [genrand 100 1]
  #puts "Mutate: mutated:  $entity"

  return $entity
}
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
# method goal_init {} {

#   global goal 

#   set goal [genrand 100 10]
  
# }
#-------------------------------------------------------------------------------
constructor {args} {

#   $self configurelist $args

#   puts stderr ""
#   puts stderr "OPTIONS = [array get options]"
#   puts stderr ""

}
#-------------------------------------------------------------------------------
method find_solution {t} {

  #goal_init

  #puts [exec ps -C tclsh -orss,size] ;# XXX
  
  set taskobj $t

  puts stderr ""
  puts stderr "TASKOBJ = $taskobj"

  # -evaluate        [mymethod evaluate]  

  # The mymethod command returns code that will call the desired method safely; 
  # the caller of the callback can add additional arguments to the end of the 
  # command as usual. 

  puts stderr ""
  puts stderr "mymethod evaluate = [mymethod evaluate] "
  puts stderr "mymproc  evaluate = [myproc   evaluate] "
  puts stderr ""

  # mymethod evaluate = ::snit::RT.CallInstance ::SOLV_LIST::Snit_inst2 evaluate 
  # mymproc  evaluate = ::SOLV_LIST::evaluate 
  #
  # т.е. mymproc просто так вызвать можно, а вот mymethod видимо нет, оно пойдет
  # как параметры к команде-вызова-объекта!
  
  #[myproc   evaluate] NAME [genrand 100 10]

  #$self [mymethod   evaluate] NAME [genrand 100 10]
  puts "RES = [$self evaluate NAME [genrand 100 10]]"

  #exit
  
  gaul create pop 100 \
    -generation_hook generation \
    -evaluate        [myproc   evaluate]   \
    -seed            seed       \
    -adapt           adapt      \
    -mutate          mutate     \
    -crossover       crossover  \
    -select_one      SUS \
    -select_two      SUS
  
  # как здесь описывать callback-процедуры? как proc или как method?
  # proc  :    вызывается (но не видит встроенную переменную?)
  # method: не вызывается

  # Once you've defined an instance variable in the type definition, it can be 
  # used in any instance code (instance methods, the constructor, and the 
  # destructor) without declaration. 

  #puts [exec ps -C tclsh -orss,size] ;# XXX
  
  #pop params {*}[pop params] - это и не надо тогда!
  #
  # или уж сделать как в g_list
  pop params -scheme lamarck_all -elitism parents_die \
             -crossover 0.900000 \
             -mutation  0.100000 \
             -migration 0.100000
  
  pop seed

  puts ""
  pop evolve 50
  
  set solution [pop solution]

  pop destroy
  
  return $solution
}
#-------------------------------------------------------------------------------
} ;# snit SOLV_LIST
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
#proc TEST_memt {} {}
 
set srand_init [seedrand_from_argv 1]   
# 
gaulgena  -seedrand $srand_init ;# переустановим random_seed
  

set t [TASK_LIST create %AUTO%]

$t goal_init


set f [SOLV_LIST create %AUTO% ]

#$f goal_init

#set solution [$f find_solution $goal]
set solution [$f find_solution $t]

  puts ""
  puts "---------------------------------------------"
  puts ""
  puts "GAUL Library: [gaul version]\n"
  puts ""
  
  puts "Goal:     $goal"
  puts "Solution: $solution"
  # stats
  # list
  # rank
  puts ""
  puts "---------------------------------------------"
  puts ""
  
  #puts "---------------------------------------------"
  
#{}
#-------------------------------------------------------------------------------
#
# TODO: 
#
# 1) global goal -> variable goal
# 2) 

#-------------------------------------------------------------------------------

#TEST_memt 

#-------------------------------------------------------------------------------

# g_memt.tl 2013


# Generation: 46
# Generation: 47
# Generation: 48
# Generation: 49
# Generation: 50

# ---------------------------------------------

# GAUL Library: major 0 minor 1850 patch 0


# Goal:     78 3 26 46 76 70 55 42 53 98
# Solution: 78 3 25 46 76 69 55 43 53 98

#-------------------------------------------------------------------------------

