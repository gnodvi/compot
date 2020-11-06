# -*-   mode: tcl  ; coding: koi8   -*- ----------------------------------------

#!/bin/sh
# \
exec tclsh "$0" ${1+"$@"}


#-------------------------------------------------------------------------------
# Josef Knecht @ Copyright 
#-------------------------------------------------------------------------------


set COMPOT "./COMPOT" 

set auto_path [linsert $auto_path 0 $COMPOT]

set auto_path [linsert $auto_path 0 $COMPOT/src/common] ;# for JIM

#lappend auto_path \
  [file join [file dirname [info script]] "."] ;# "COM" "../common"


#-------------------------------------------------------------------------------

package require compot::common 

if {$::__JIM__} {

} else {

  #package require tcltest
  package require TclOO

}

#------------------------------------------

source "g-corA.tl"
source "g-corB.tl" 

source "g-cros.tl"
source "g-croz.tl"

source "g-diff.tl"
source "g-detw.tl"

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------


set ::gp_list "1 2 3 4 5 6 7 8 9"

random_seed 0


# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
proc maintest_seed_proc {pop adam} {

  set len [GET $pop len_chromosomes]


  for {set point 0} {$point < $len} {incr point} {
    
    set char_sym [randinstr_NEXT  $::gp_list]
    

    set ch [scan $char_sym "%c"]  ;# десятичные коды символьных цифр
    #
    # а зачем в цифру переводить? нам нужны здесь симыолы, а точнее - строки !!!


    ent_set_chromo_gen_ $adam $point $ch 
    #
    # записывем ген в хромосому в виде эдемента списка
  }

  return $::true
}
# ------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
# //------------------------------------------------------------------------------

# /*   ! " # $ % & ' ( ) * + , - . / 0 1 2 3 4 5 6 7 8 9 : ; < = > ? @ A B C D E F G H I J K L M N O P Q R S T U V W X Y Z [ \ ] ^ _ ` a b c d e f g h i j k l m n o p q r s t u v w x y z { | } ~  */

# /* i=  32  ch=    */
# /* i=  33  ch= !  */
# /* i=  34  ch= "  */
# /* i=  35  ch= #  */
# /* i=  36  ch= $  */
# /* i=  37  ch= %  */
# /* i=  38  ch= &  */
# /* i=  39  ch= '  */
# /* i=  40  ch= (  */
# /* i=  41  ch= )  */
# /* i=  42  ch= *  */
# /* i=  43  ch= +  */
# /* i=  44  ch= ,  */
# /* i=  45  ch= -  */
# /* i=  46  ch= .  */
# /* i=  47  ch= /  */
# /* i=  48  ch= 0  */
# /* i=  49  ch= 1  */
# /* i=  50  ch= 2  */
# /* i=  51  ch= 3  */
# /* i=  52  ch= 4  */
# /* i=  53  ch= 5  */
# /* i=  54  ch= 6  */
# /* i=  55  ch= 7  */
# /* i=  56  ch= 8  */
# /* i=  57  ch= 9  */
# /* i=  58  ch= :  */
# /* i=  59  ch= ;  */
# /* i=  60  ch= <  */
# /* i=  61  ch= =  */
# /* i=  62  ch= >  */
# /* i=  63  ch= ?  */
# /* i=  64  ch= @  */
# /* i=  65  ch= A  */
# /* i=  66  ch= B  */
# /* i=  67  ch= C  */
# /* i=  68  ch= D  */
# /* i=  69  ch= E  */
# /* i=  70  ch= F  */
# /* i=  71  ch= G  */
# /* i=  72  ch= H  */
# /* i=  73  ch= I  */
# /* i=  74  ch= J  */
# /* i=  75  ch= K  */
# /* i=  76  ch= L  */
# /* i=  77  ch= M  */
# /* i=  78  ch= N  */
# /* i=  79  ch= O  */
# /* i=  80  ch= P  */
# /* i=  81  ch= Q  */
# /* i=  82  ch= R  */
# /* i=  83  ch= S  */
# /* i=  84  ch= T  */
# /* i=  85  ch= U  */
# /* i=  86  ch= V  */
# /* i=  87  ch= W  */
# /* i=  88  ch= X  */
# /* i=  89  ch= Y  */
# /* i=  90  ch= Z  */
# /* i=  91  ch= [  */
# /* i=  92  ch= \  */
# /* i=  93  ch= ]  */
# /* i=  94  ch= ^  */
# /* i=  95  ch= _  */
# /* i=  96  ch= `  */
# /* i=  97  ch= a  */
# /* i=  98  ch= b  */
# /* i=  99  ch= c  */
# /* i= 100  ch= d  */
# /* i= 101  ch= e  */
# /* i= 102  ch= f  */
# /* i= 103  ch= g  */
# /* i= 104  ch= h  */
# /* i= 105  ch= i  */
# /* i= 106  ch= j  */
# /* i= 107  ch= k  */
# /* i= 108  ch= l  */
# /* i= 109  ch= m  */
# /* i= 110  ch= n  */
# /* i= 111  ch= o  */
# /* i= 112  ch= p  */
# /* i= 113  ch= q  */
# /* i= 114  ch= r  */
# /* i= 115  ch= s  */
# /* i= 116  ch= t  */
# /* i= 117  ch= u  */
# /* i= 118  ch= v  */
# /* i= 119  ch= w  */
# /* i= 120  ch= x  */
# /* i= 121  ch= y  */
# /* i= 122  ch= z  */
# /* i= 123  ch= {  */
# /* i= 124  ch= |  */
# /* i= 125  ch= }  */
# /* i= 126  ch= ~  */


set ::allele_min_integer  32 ;# (' ') 
set ::allele_max_integer 126 ;# ('~') 

# //------------------------------------------------------------------------------
#   struggle_ALL.c

#   Synopsis:	Test/example program.

# This program aims to generate the final sentence from
# Chapter 3 of Darwin's "The Origin of Species",
# entitled "Struggle for Existence".

# /*
#  * The solution string.
#  */

# set ::target_text_full  "When we reflect on this struggle, we may console ourselves with the full belief, that the war of nature is not incessant, that no fear is felt, that death is generally prompt, and that the vigorous, the healthy, and the happy survive and multiply."

#set ::target_text  "When we reflect on this struggle"

set ::target_text  "1 2 2 3 3 3 4 4 4 4 5 5 5 5 5"


#set ::NEWTEXT 0

#set ::NEWMODE 0

# ------------------------------------------------------------------------------
proc LTARGET {} {

  set len [llength $::target_text]

  return $len
}
#------------------------------------------------------------------------------
# TODO: упростить
#------------------------------------------------------------------------------
proc FS_fitness_one_calc_add {fit  char_calc_decm char_true_decm} {

  set abs [expr {abs ($char_calc_decm - $char_true_decm)}]

  ##if {$char_calc_decm == $char_true_decm} {}
  if {$abs == 0} {

    set fit [expr {$fit + 1.0}]
    # если   совпадают, просто увеличиваем на 1

    #puts "FS_fitness_one_calc_add: abs == 0"
    #exit
  }
  
  set char_min $::allele_min_integer 
  set char_max $::allele_max_integer 

  set size_all   [- $char_max $char_min] 
  set size_all_half [/ $size_all 2.0] 


  set fit_add [expr {1.0 * ($char_max - $abs) / $size_all_half}]

  set fit [+ $fit $fit_add] 


  # подсчет идет в пространстве кодовых значений символов
  # 
  # добавляем признак, что уже ближе? холодно-теплее-горячо ?
  
  return $fit
}
#------------------------------------------------------------------------------if

proc FS_fitness {text_calc task} {

  set fit 0.0
  
  set len [ent_get_chromo_len_ $text_calc] 

  set text_true $::target_text


  # Loop over alleles in chromosome.
  
  for {set k 0} {$k < $len} {incr k} {
  
    set char_true  [lindex  $text_true  $k]

    set char_true_decm  [scan   $char_true "%c"] ;# по символу берем его номер

    if {0} {
      puts "char_true      = $char_true"
      puts "char_true_decm = $char_true_decm"
      puts "char_true_decm2= [scan $char_true "%Ld"]"

      exit
    }

    set char_calc_decm  [ent_get_chromo_gen_ $text_calc  $k]

    set fit [FS_fitness_one_calc_add  $fit  $char_calc_decm $char_true_decm]
  }

  # #   if {$::ISNEW} {
  # #     #puts stderr ".................................. 001"
  # #     #set fi [expr {abs (53.1 - $fi)}]
  
  # #     #set fi [expr {$fi - 39}]  ;# это еще нормально для ga_select_two_sus
  # #     #set fi [expr {$fi - 40}]   ;# а это уже с ошибкой
  # #     #set fi [expr {$fi - 53.1}]   
  # #   }  

  return $fit
}
# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
proc do_print_best {pop name} \
{

  set best_entity [ga_get_entity_from_rank $pop 0]
  set best_fitnes [item_get_fitn           $best_entity] 

  #puts [format "The final solution with %s evolution with score %f was:" $name $best_fitnes]
  puts -nonewline [format "Best solution %s, score = %5.2f : " $name $best_fitnes]

  #   beststring = ga_chromosome_char_to_string (pop, ga_get_entity_from_rank (pop, 0), 
  #                                              beststring, &beststrlen);
  #   printf ("%s\n", beststring);
  #   printf ("\n");

  ent_print_ch_ $best_entity ""

  puts ""
  puts ""

}
# ------------------------------------------------------------------------------

#  struggle.c
# 
#  This program is fairly lean, showing how little
#  application code is needed.
#  This example is explained in docs/html/tutorial/simple.html
# 
# ------------------------------------------------------------------------------
# proc  strlen {str} {

#   return [string length $str]
# }
# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
proc pop1_create {args} {

  set len_chromosomes [dict_parse $args "-lgen"] 
  set population_size [dict_parse $args "-lpop"] 


  set pop [GAUL new  \
                -lpop $population_size -lgen $len_chromosomes]

  
  SET $pop  generation_hook NULL ;# $generation_hook
  
  SET $pop  adapt       NULL ;# $adapt
  
  SET $pop  mutate      ga_mutate_printable_singlepoint_drift

  SET $pop  crossover   ga_crossover_char_allele_mixing
  SET $pop  replace     NULL ;# $replace   ;#
  
  SET $pop  ch_form "%c" 
  
  SET $pop  scheme           GA_SCHEME_DARWIN
  SET $pop  elitism          GA_ELITISM_PARENTS_DIE

  SET $pop  crossover_ratio  0.9
  SET $pop  mutation_ratio   0.2
  SET $pop  migration_ratio  0.0
  
  SET $pop  seed   "maintest_seed_proc"   ;#   $seed_proc 
  
  return $pop
}
# ------------------------------------------------------------------------------

dict_class_create BOT01 {BOT} {

  ;# _это_перечисление_переменных
  
} {
  # а это конструктор класса 

  set pop [pop1_create  {*}$args]
  
  SET $pop  select_one   "ga_select_one_sus"
  SET $pop  select_two   "ga_select_two_sus"

  SET $obj pop $pop

}
# ------------------------------------------------------------------------------
proc _01_test {} {

  set len_chromo [LTARGET] 

  global argc argv

  if {$argc != 3} {

    puts "!!!!!!!!! g_stru.tl GA 20 20 !!!!!!!!!!!!"
    exit

  } else {
    
    set population_size  [lindex $argv 1] ;# 20  ;# колич-во ботов  
    set max_generations  [lindex $argv 2] ;# 20  ;# шагов эволюции 
  }

  puts ""
  puts "bnums  = $population_size"  ;# колич-во ботов
  puts "bsize  = $len_chromo" 
  puts "maxgs  = $max_generations"  ;# шагов эволюции  
  puts ""

  set ::is_print 1 ;# TODO: здесь уж слишком много печати, надо гибче?

  set seed_proc     "maintest_seed_proc"

  set fitness_func  "FS_fitness"

  test_random_seed 0 ;#$i
  
  if {$max_generations == -1} {
    set task [task_create $fitness_func -fit_target $::fit_target -fit_error 0.01 ]  
  } else {
    set task [task_create $fitness_func]  
  }
  
  set obj \
    [BOT01 new  -lpop $population_size -lgen $len_chromo -task $task] 

  set pop [GET $obj pop]
  
 
  SET $pop  seed $seed_proc   
  
  ga_evolution  $task $pop $max_generations   
  
  do_print_best $pop ""
  
  return
}
# ------------------------------------------------------------------------------
proc _01_test_new {} {


  set ::NEWMODE 1

  _01_test 

}
# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------

dict_class_create  BOT02 {BOT} {

  ;# _это_перечисление_переменных
  
} {
  # а это конструктор класса 

  set pop1 [pop1_create  {*}$args]
  
  SET $pop1  elitism  GA_ELITISM_PARENTS_SURVIVE ;# всех оставдяем !
  SET $pop1  select_one  "ga_select_one_bestof2"
  SET $pop1  select_two  "ga_select_two_bestof2"  
  
  SET $obj "pop" $pop1
}

# //------------------------------------------------------------------------------
# //  struggle_generation_hook()
# //  synopsis:	This function is called by the main GA routine at the
# //		beginning of every generation.

  set ::sum_best_fitnesses 0.0  


# //------------------------------------------------------------------------------
proc _3_struggle_generation_hook {generation pop} \
{

  set fi [pop_get_entity_fitness_ $pop  0]

  set ::sum_best_fitnesses [expr {$::sum_best_fitnesses + $fi}]
  
  # Display statistics every 20th generation.
  # 
  
  if {[expr {$generation % 20}] == 0} {

    #puts [format "Generation = %d " $generation]
    #puts [format "Number of evaluations = %ld" $::eval_count]
    #puts [format "Best fitness = %f" $fi]

    set average ""
    set stddev  ""

    ga_fitness_mean_stddev  $pop  average stddev
    
    #puts [format "Mean fitness = %f, with standard deviation = %f" $average $stddev]

    #if {$generation > 0} {
    #  puts [format "Average best fitness for entire run = %f" \
    \#          [expr {$::sum_best_fitnesses / $generation}]]
    #}

    #puts ""
  }
  
  return $::true ;#  /* TRUE indicates that evolution should continue. */
}
# //------------------------------------------------------------------------------
# //  struggle3.c
# //
# //		This program demonstrates the use of custom GA
# //		termination criteria.  It also provides an example of
# //		how to collate some simple statistics.
# //
#-------------------------------------------------------------------------------
proc parse_opts_2 {&par1    &par2 
                def_par1 def_par2 } {

  USE_REFS

  global argc argv argv0

  set ::is_print 0

  if  {$argc == 1} { 
    # вызов без параметров, только с одним mode
    
    set par1  $def_par1
    set par2  $def_par2
 
  } else {

    set par1 [lindex $argv 1]
    set par2 [lindex $argv 2]

    if  {$argc == 4}    {
      set ::is_print 1
    }
  }

  return
}
# ------------------------------------------------------------------------------
proc allele_incr {adult allele incr_val}  \
{

  set oldval [ent_get_chromo_gen_ $adult  $allele]

  ent_set_chromo_gen_ $adult $allele [expr {$oldval + $incr_val}]

}
# ------------------------------------------------------------------------------
proc _3_struggle_adaptation {task pop child} \
{
  
  set eval_proc [GET $task "fitness_proc"]

  # We must generate a new solution by copying the original solution.
  # This function copys all genomic, and if appropriate, phenomic data.
  # It is never safe to adapt the solution in place.
  #

  set adult [ga_entity_clone $pop $child] ;# for Adapted solution
  
  set len [LTARGET]

  set allele [random_int $len] ;# Randomly selected allele

  # ----------------------------------------------------
  #
  # Make point mutation.
  
  allele_incr $adult $allele +1
 
  pop_eval_item  $pop $adult $eval_proc $task
    
  if {[item_get_fitn $adult] > [item_get_fitn $child]} {
    return $adult
  }
  
  # ----------------------------------------------------
  # 
  #  Searching in that previous direction didn't help. 

  allele_incr $adult $allele -2
  
  pop_eval_item  $pop $adult $eval_proc $task
    
  if {[item_get_fitn $adult] > [item_get_fitn $child]} {
    return $adult
  }
  
  # ----------------------------------------------------

  #  We must already be at a maxima. 
  
  allele_incr $adult $allele +1

  #ent_set_fitness $adult [item_get_fitn $child]
  ga_entity_set_fitness  $adult [item_get_fitn $child]

  return $adult
}
# ------------------------------------------------------------------------------

dict_class_create  BOT03 {BOT} {

  ;# _это_перечисление_переменных
  
} {
  # а это конструктор класса 

  set len_chromo      [dict_parse $args "-lgen" ] 
  set population_size [dict_parse $args "-lpop" ] 
  set task            [dict_parse $args "-task" ] 
    
  set seed_proc  "maintest_seed_proc"
  
  set mutate [mutate_create -mutate_proc ga_mutate_printable_singlepoint_drift]

  set pop  [ga_genesis_main                          \
	      $task \
              $population_size			     \
              1			                     \
              $len_chromo                            \
              _3_struggle_generation_hook	     \
              NULL			             \
              NULL			             \
              NULL                                   \
              $seed_proc                             \
              _3_struggle_adaptation	             \
              ga_select_one_sus	                     \
              ga_select_two_sus	                     \
              $mutate  \
              ga_crossover_char_allele_mixing        \
              NULL			             \
              NULL			             \
             ]

    SET $pop ch_form "%c" ;# 
    
    ga_population_set_parameters \
      $pop	                 \
      GA_SCHEME_LAMARCK_CHILDREN \
      GA_ELITISM_PARENTS_DIE     \
      0.8			 \
      0.05		         \
      0.0      	          

    SET $obj "pop"  $pop

}
#-------------------------------------------------------------------
proc calc_BOT03 {obj args} {

  set task            [dict_parse $args "-task" [GET $obj task]] 
  set max_generations [dict_parse $args "-steps"] 
  
  set  pop [GET $obj pop]
  
  set ret [ga_evolution  $task $pop $max_generations]  
  
  return $ret  
}
# //------------------------------------------------------------------------------
proc _03_test {} \
{
  
  test_random_seed 23091975
  
  set population_size 120
  set max_generations 1000

  parse_opts_2  population_size max_generations \
                120 1000
  
  #----------------------------------------------------------------------

  set len_chromo [LTARGET] 
  
  set task [task_create "FS_fitness"]

  #----------------------------------------------------------------------

  set obj \
    [BOT03 new  -lpop $population_size -lgen $len_chromo -task $task] 


  set pop [GET $obj pop]

  set ret [ga_evolution  $task $pop $max_generations]  


  if {$ret < $max_generations} {

    puts "The evolution was stopped because the termination criteria were met. "
  } else {
    puts "The evolution was stopped because the maximum number of generations were performed."
  }

  puts ""
  
  do_print_best $pop ""

  puts [format "Total number of fitness evaluations: %ld" $::eval_count]
  

  return 1
}
# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
# proc _4_struggle_seed {pop adam} \
# {

#   ga_seed_printable_random $pop $adam


#   return $::true
# }
# ------------------------------------------------------------------------------
proc _4_struggle_mutate {pop father son} \
{
 
  # похоже это тоже самое !?
  # 
  ga_mutate_printable_singlepoint_drift  $pop $father $son


  return
}
# ------------------------------------------------------------------------------
# synopsis:	A pair of crossover operators which will be called
# 		alternately through the use of cross definitions.
#
# т.е. вызываются попеременно
# //------------------------------------------------------------------------------
proc _4_the_other_struggle_crossover {pop father mother son daughter} \
{

  ga_crossover_char_singlepoints  $pop $father $mother $son $daughter

  SET $pop crossover _4_struggle_crossover

  return
}
# //------------------------------------------------------------------------------
proc _4_struggle_crossover {pop father mother son daughter} \
{
  ga_crossover_char_doublepoints $pop $father $mother $son $daughter

  SET $pop crossover _4_the_other_struggle_crossover

  return
}
# //------------------------------------------------------------------------------
# ------------------------------------------------------------------------------

dict_class_create  BOT04 {BOT} {

  ;# _это_перечисление_переменных

} {

  # если нет в args, то берем значение здесь
  # 
  set len_chromo      [dict_parse $args "-lgen" ] 
  set population_size [dict_parse $args "-lpop" ] 
  
  set pop [GAUL new  \
             -lpop $population_size -lgen $len_chromo]
  
  SET $pop ch_form "%c" ;# 
    
  #   /*
  #     * Define chromosome handling functions.
  #     * Normally these functions would only be set manually when
  #     * creating a custom chromosome type.
  #     */
  
  #   pop->chromosome_constructor = ga_chromosome_char_allocate;
  #   pop->chromosome_destructor  = ga_chromosome_char_deallocate;
  #   pop->chromosome_replicate   = ga_chromosome_char_replicate;
  #   pop->chromosome_to_bytes    = ga_chromosome_char_to_bytes;
  #   pop->chromosome_from_bytes  = ga_chromosome_char_from_bytes;
  #   pop->chromosome_to_string   = ga_chromosome_char_to_string;
  
  #   /* Define all the needed callback functions. */
  SET $pop generation_hook NULL
  #$pop configure -iteration_hook  NULL
  #   pop->data_destructor = NULL;
  #   pop->data_ref_incrementor = NULL;
  
  
  set seed_proc  "maintest_seed_proc"
  
  
  SET $pop seed       $seed_proc      ;# /* Individual initialisation    */
  
  SET $pop adapt      _3_struggle_adaptation ;# /* Environmental adaptation operator */
  SET $pop select_one  ga_select_one_sus     ;# /* Mutation selection operator  */
  SET $pop select_two  ga_select_two_sus     ;# /* Crossover selection operator */
  SET $pop mutate     _4_struggle_mutate     ;# /* Mutation operator            */
  SET $pop crossover  _4_struggle_crossover  ;# /* Crossover operator           */
  
  #   /* Replacement operator. (Only used in steady-state evolution) */
  SET $pop replace NULL
  
  #   /*
  #     * Seed the initial population. (Could do this manually - it
  #     * just calls pop->seed() 100 times in this case.)
  #     */
  ga_population_seed $pop
  
  #   /*
  #     * Set the GA parameters.
  #     * Lamarkian evolution.
  #     * Parents may survive into next generation.
  #     * Crossover ratio = 0.9.
  #     * Mutation ratio = 0.1.
  #     * Migration ration = 0.0.
  #     *
  #     * Note that custom operator functions may choose to ignore these values.
  #     *
  #     * There are functions for setting these individually too.
  #     */
  #   ga_population_set_parameters (pop, GA_SCHEME_LAMARCK_CHILDREN, GA_ELITISM_PARENTS_DIE, 0.9, 0.1, 0.0);
    
  ga_population_set_parameters \
    $pop	               \
    GA_SCHEME_LAMARCK_CHILDREN \
    GA_ELITISM_PARENTS_DIE     \
    0.9			       \
    0.1		               \
    0.0      	          
  
  
  SET $obj "pop"  $pop
  
}

#---------------------------------------------------------
proc  calc_BOT04  {obj args} {
  
  
  set task            [dict_parse $args "-task" [GET $obj task]] 
  set max_generations [dict_parse $args "-steps"] 
  
  set  pop [GET $obj pop]
  
  set ret [ga_evolution  $task $pop $max_generations]  
  
  return $ret
}
#---------------------------------------------------------

# //------------------------------------------------------------------------------
# //
# //  struggle4.c
# //
# //	This program demonstrates the use of custom GA
# //	operator functions.  The long-hand method is used
# //	to set up the population's genomic form, rather than
# //	and of the high-level utility functions.
# //
# //	This example is explained in docs/html/tutorial4.html
# //
# //------------------------------------------------------------------------------
proc _04_test {} \
{
  
  test_random_seed 23091975
  

  set population_size ""
  set max_generations ""

  parse_opts_2  population_size max_generations \
                100 500
  
  set len_chromo [LTARGET] 

  #-----------------------------------------------------------------

  set task [task_create "FS_fitness"]
  
  set obj \
    [BOT04 new  -lpop $population_size -lgen $len_chromo -task $task] 

  set pop [GET $obj pop]

  RUN1 "calc_" $obj -steps $max_generations -task $task 


  #-----------------------------------------------------------------

  do_print_best $pop ""

  return 1
}
# ------------------------------------------------------------------------------

dict_class_create  BOT05 {BOT} {

  ;# _это_перечисление_переменных

  pops ""

} {
  #---------------------------------------------------------

  #set obj [SELF]

  # если нет в args, то берем значение здесь
  # 
  set task  [GET $obj task]

  set len_chromo      [dict_parse $args "-lgen" ] 
  set population_size [dict_parse $args "-lpop" ] 
  set num_pops        [dict_parse $args "-num_pops" 1]
  
  
  set seed_proc  "maintest_seed_proc"
  
  set mutate [mutate_create -mutate_proc ga_mutate_printable_singlepoint_drift]

  # все попы одинаковы?
  set pops ""
  
  for {set i 0} {$i < $num_pops} {incr i} {
    
    set pop  [ga_genesis_main                         \
                $task \
                $population_size	              \
                1			              \
                $len_chromo                           \
                NULL	                              \
                NULL			              \
                NULL			              \
                NULL                                  \
                $seed_proc                            \
                NULL	                              \
                ga_select_one_sus	              \
                ga_select_two_sus	              \
                $mutate \
                ga_crossover_char_allele_mixing       \
                NULL			              \
                NULL			              \
               ]
    
    SET $pop ch_form "%c" ;# 
    
    ga_population_set_parameters \
      $pop	                 \
      GA_SCHEME_DARWIN           \
      GA_ELITISM_PARENTS_DIE     \
      0.75			 \
      0.25		         \
      0.0001        
    
    lappend pops $pop
  }
  
  
  SET $obj "pops"  $pops
  
}

#---------------------------------------------------------
proc  calc_BOT05 {obj args} {

  
  set task            [dict_parse $args "-task" [GET $obj task]] 
  set max_generations [dict_parse $args "-steps"] 
  
  set pops [GET $obj pops]
  
  set num_pops [llength $pops]
  
  set ret [ga_evolution_archipelago  $num_pops $pops  $max_generations $task]
  
  return $ret
}
#---------------------------------------------------------
proc  final_BOT05 {obj args} {


  set pops [GET $obj pops]    
  set pop0 [lindex $pops 0]
  
  set num_generations [GET $pop0 "generation"] ;# сколько было генераций
  set ch_form         [GET $pop0 "ch_form"]
  
  set num_pops [llength $pops]
  
  for {set i 0} {$i < $num_pops} {incr i} {
    
    set pop [lindex $pops $i] 
    set best_entity     [ga_get_entity_from_rank $pop 0]
  }
  
  return [list $num_generations $best_entity $ch_form]


}
#---------------------------------------------------------

# //------------------------------------------------------------------------------
# //
# //  struggle4.c
# //
# //	This program demonstrates the use of custom GA
# //	operator functions.  The long-hand method is used
# //	to set up the population's genomic form, rather than
# //	and of the high-level utility functions.
# //
# //	This example is explained in docs/html/tutorial4.html
# //
# ------------------------------------------------------------------------------
# struggle5.c
# 
# This example shows the use of multiple populations
# (so called "archipelago" scheme).  This is
# the basic island model of evolution.
# 
# This example is explained in
# http://gaul.sourceforge.net/tutorial/island.html
# and
# http://gaul.sourceforge.net/tutorial/multiprocessor.html
# 

# Specify the number of populations (islands) to use.

set ::GA_STRUGGLE_NUM_POPS	5

# //------------------------------------------------------------------------------
proc _05_test {} \
{

  set num_pops        ""
  set population_size "" 
  set max_generations ""

  parse_opts_3   num_pops population_size max_generations  5 80 250

  test_random_seed 42
  

  #----------------------------------------------------------------------

  set len_chromo [LTARGET] 
  
  set task [task_create "FS_fitness"]
  
  #----------------------------------------------------------------------

  set obj \
    [BOT05 new  -lpop $population_size -lgen $len_chromo -task $task -num_pops $num_pops ] 

  set pops [GET $obj pops]

  RUN1 "calc_" $obj -steps $max_generations -task $task

  #----------------------------------------------------------------------

  for {set i 0} {$i < $num_pops} {incr i} {
  
    set pop [lindex $pops $i] 

    do_print_best $pop [format " on island %d " $i]
  }
  
  return 1
}
# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------

dict_class_create  BOT06 {BOT} {

  ;# _это_перечисление_переменных

} {
  #---------------------------------------------------------

  #set obj [SELF]

  # если нет в args, то берем значение здесь
  # 
  set task   [GET $obj task]
  
  set len_chromo      [dict_parse $args "-lgen" ] 
  set population_size [dict_parse $args "-lpop" ] 
  

  set seed_proc  "maintest_seed_proc"
        
  set mutate [mutate_create -mutate_proc ga_mutate_printable_singlepoint_drift]

  set pop  [ga_genesis_main                         \
              $task                                 \
              $population_size	                    \
              1			                    \
              $len_chromo                           \
              NULL	                            \
              NULL			            \
              NULL			            \
              NULL                                  \
              $seed_proc                            \
              NULL	                            \
              ga_select_one_sus	                    \
              ga_select_two_sus	                    \
              $mutate \
              ga_crossover_char_allele_mixing       \
              NULL			            \
              NULL			            \
             ]
  
  
  SET $pop ch_form "%c" ;# 
  
  ga_population_set_parameters \
    $pop	               \
    GA_SCHEME_DARWIN           \
    GA_ELITISM_PARENTS_DIE     \
    0.9			       \
    0.2		               \
    0.0      
  
  ga_population_set_deterministiccrowding_parameters  \
    $pop \
    "ga_compare_char_hamming"
  

  SET $obj "pop"  $pop
}

#---------------------------------------------------------
proc calc_BOT06 {obj args} {

  
  set task            [dict_parse $args "-task" [GET $obj task]] 
  set max_generations [dict_parse $args "-steps"] 
  
  set pop  [GET $obj pop]
  
  ga_deterministiccrowding  $task $pop $max_generations
}
#---------------------------------------------------------


# //------------------------------------------------------------------------------
# //------------------------------------------------------------------------------
# //  struggle_dc.c
# //
# //	This program is almost identical to struggle, except it
# //	applies deterministic crowding instead of a genetic
# //	algorithm.
# //
# //	This example is explained in docs/html/tutorial/simple.html
# //
# //------------------------------------------------------------------------------
proc _dc_test {} \
{

  set        num_runs ""
  set population_size ""
  set max_generations ""

  parse_opts_3   num_runs population_size max_generations  3 120 500

  #----------------------------------------------------------------------
  #
  for {set i 0} {$i < $num_runs} {incr i} {
  
    test_random_seed  $i
    
    set len_chromo [LTARGET] 
  
    set task [task_create "FS_fitness"]

 
    #----------------------------------------------------------

    set obj \
      [BOT06 new  -lpop $population_size -lgen $len_chromo -task $task] 

    set pop [GET $obj pop]

    RUN1 "calc_" $obj -steps $max_generations -task $task

    #----------------------------------------------------------

    set best_entity [ga_get_entity_from_rank $pop 0]

    set best_fitnes [item_get_fitn $best_entity] 

    puts "The final solution with seed = $i was:"
    ent_print_ch_ $best_entity ""

    puts ""

    puts ""
    puts [format "With score = %f " $best_fitnes]
    #puts ""
    
  }  
  #
  #----------------------------------------------------------------------

  return 1
}
# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
proc make_pop_DARWIN {task population_size len_chromo} {


  set len_chromo [LTARGET] 
  
  test_random_seed 23091975

  set seed_proc  "maintest_seed_proc"


  set mutate [mutate_create -mutate_proc ga_mutate_printable_singlepoint_drift]

  set popd [ga_genesis_main                          \
	      $task \
              $population_size			     \
              1			                     \
              $len_chromo                            \
              NULL		  	             \
              NULL			             \
              NULL			             \
              NULL                                   \
              $seed_proc                             \
              _3_struggle_adaptation	             \
              ga_select_one_sus	                     \
              ga_select_two_sus	                     \
              $mutate  \
              ga_crossover_char_allele_mixing        \
              NULL			             \
              NULL			             \
             ]

  SET $popd ch_form "%c" ;# 

  #   ga_population_set_parameters (
  #      popd,			/* population   *pop */
  #      GA_SCHEME_DARWIN,		/* const ga_scheme_type scheme */
  #      GA_ELITISM_PARENTS_DIE,	/* const ga_elitism_type   elitism */
  #      0.9,			/* const double       crossover */
  #      0.1,			/* const double       mutation */
  #      0.0			/* const double       migration */
  #      );
  
  ga_population_set_parameters \
    $popd	               \
    "GA_SCHEME_DARWIN"	       \
    GA_ELITISM_PARENTS_DIE     \
    0.9			       \
    0.1			       \
    0.0      	          


  return $popd
}
# ------------------------------------------------------------------------------

set ::_NEW_ 1
set ::_OLD_ [expr (! $::_NEW_)]

# ------------------------------------------------------------------------------

dict_class_create  BOT79 {BOT} {

  ;# _это_перечисление_переменных

} {
  #---------------------------------------------------------

  set len_chromo      [dict_parse $args "-lgen"] 
  set population_size [dict_parse $args "-lpop"] 
  set task            [dict_parse $args "-task"] 
  
  set pop [make_pop_DARWIN  $task $population_size $len_chromo] 
  
  SET $obj "pop"   $pop

}
# ------------------------------------------------------------------------------
proc do_evolution_and_print_best {task pop max_generations name}  \
{

  ga_evolution  $task $pop $max_generations   

  do_print_best $pop $name

}
#---------------------------------------------------------
proc calc_BOT79 {obj args} {
  
  
  set task             [dict_parse $args "-task" [GET $obj task]] 
  set max_generations1 [dict_parse $args "-steps"] 
  
  set popd [GET $obj pop]
  set name [GET $obj name]
  
  do_evolution_and_print_best $task $popd $max_generations1 $name
}
# ------------------------------------------------------------------------------
proc BOT07_new {args} {


  set obj  [BOT79 new  {*}$args] 

  return $obj
}
# ------------------------------------------------------------------------------
proc BOT08_new {args} {


  set obj  [BOT79 new  {*}$args] 

  set pop [GET $obj pop]

  ga_population_set_scheme  $pop "GA_SCHEME_BALDWIN_CHILDREN"    

  return $obj
}
# ------------------------------------------------------------------------------
proc BOT09_new {args} {


  set obj  [BOT79 new  {*}$args] 

  set pop [GET $obj pop]

  ga_population_set_scheme  $pop "GA_SCHEME_LAMARCK_CHILDREN"

  return $obj
}
#-------------------------------------------------------------------------------
proc parse_opts_4 {&par1    &par2    &par3    &par4 
                def_par1 def_par2 def_par3 def_par4} {

  USE_REFS

  global argc argv argv0

  set ::is_print 0

  if  {$argc == 1} { 
    # вызов без параметров, только с одним mode
    
    set par1  $def_par1
    set par2  $def_par2
    set par3  $def_par3
    set par4  $def_par4
 
  } else {

    set par1 [lindex $argv 1]
    set par2 [lindex $argv 2]
    set par3 [lindex $argv 3]
    set par4 [lindex $argv 4]

    if  {$argc == 6}    {
      set ::is_print 1
    }
  }

  return
}
# ------------------------------------------------------------------------------
proc eschemes {} \
{

  set population_size  ""
  set max_generations1 ""
  set max_generations2 ""
  set max_generations3 ""

  parse_opts_4  population_size max_generations1 max_generations2 max_generations3    \
                150 600 300 300
  

  set task [task_create "FS_fitness"]

  set len_chromo [LTARGET] 
  
  #----------------------------------------------------------------------

  set obj7 \
    [BOT07_new  -lpop $population_size -lgen $len_chromo -task $task -name Darwinian ] 
 
  set obj8  \
    [BOT08_new  -lpop $population_size -lgen $len_chromo -task $task -name Baldwinian] 

  set obj9 \
    [BOT09_new  -lpop $population_size -lgen $len_chromo -task $task -name Lamarckian] 

  #----------------------------------------------------------

  if {! $::is_print} {
    RUN1 "calc_" $obj7 -task $task -steps $max_generations1
  }
  
    RUN1 "calc_" $obj8 -task $task -steps $max_generations2
  
  if {! $::is_print} {
    RUN1 "calc_" $obj9 -task $task -steps $max_generations3
  }
  
  
  return 1
}
# ------------------------------------------------------------------------------
  # TODO : 
  #   YRAND -> YRAND_new

# ------------------------------------------------------------------------------
proc make_random_list_member {source_list} {

  set nums [llength $source_list]
  
  set j [YRAND_new 0 [- $nums 1]]
  set l [lindex $source_list $j]

  return $l
}
# ------------------------------------------------------------------------------
proc make_random_target_text {source_list  size pmin pmax} {

  set ret {}

  for {set i 0} {$i < $size} {} {

    set l [make_random_list_member  $source_list] ;# или с коэффициентом порядка 

    set povtor [YRAND_new  $pmin $pmax]

    dotimes p $povtor {

      lappend ret $l

      incr i
      if {$i == $size} {break} ;# вышли из цикла dotimes
    }
  }

  return $ret
}
# ------------------------------------------------------------------------------
proc sort_proc {aa bb} {

  set a [lindex $aa 1]
  set b [lindex $bb 1]

  # возвращаемое значение определяет "желаемый" знак разности левого и правого 
  # 

  if {$a <  $b}  {return -1} ;# т.е МЕНЬШИЕ будут слева в списке 
  if {$a == $b}  {return  0} 
  if {$a >  $b}  {return  1} 

}
#-------------------------------------------------------------------------------
proc print_result_maintest {botobjs sum_name} {

  upvar $sum_name sum

  set resultlist {}

  dict for {botname obj} [set $botobjs] {

    lappend  resultlist [list $botname $sum($botname)]
    #puts "SUM  $botname =  $sum($botname)   eval_counts"
  }

  #puts "resultlist = $resultlist"

  set sortresult [lsort -command "sort_proc" $resultlist] 

  #puts "sortresult = $sortresult"
  puts "------------------------------------------------"
  puts ""

  set n 1

  foreach s $sortresult {

    set a [lindex $s 0]
    set b [lindex $s 1]

    puts [format "%d mesto : %8s, %6d eval"  $n $a $b]
    incr n
  }

  #set mid [expr {1.0 * $sum_generations / ($num_runs * $num_text)}]
  #
  #puts "mid_generations = $mid  \[$min ... $max\]"
  #puts ""

  return
}
#-------------------------------------------------------------------------------
proc ent_as_string_list {e ch_form} {


  if {$ch_form == ""} {
    set ch_form [GET $e ch_form] ;# локальная переменная
  }

  set ch  [ent_get_chromosome_ $e]
  
  #puts -nonewline $out $name
  
  set buf {}

  foreach c $ch {

    #append buf [format $ch_form $c]
    lappend buf [format $ch_form $c]

  } 
  
  return $buf
}
# ------------------------------------------------------------------------------
proc maintest_run {botobjs task 
                     max_generations 
                   num_text num_runs pmin pmax len_chromosomes 
                 } {


  set ::gp_list "1 2 3 4 5 6 7 8 9"

  #set sum_generations 0
  set min +99999
  set max -99999

  #--------------------------------

  dict for {botname obj} [set $botobjs] {

    set sum($botname) 0
  }

  # -----------------------------------------------------------------
  for {set t 0} {$t < $num_text} {incr t} {

    set ::target_text  [make_random_target_text   $::gp_list \
                          $len_chromosomes  $pmin $pmax]
    
    puts "target_text = $::target_text \n"
    
    # ----------------------------------------------------------------- 
    for {set r 0} {$r < $num_runs} {incr r} {
      
      #puts -nonewline [format "r= $r   "]
      puts "r= $r   "
       
      # или здесь создавать какждый цикл новые боты-объекты?? 
      # 

      # ------------------------------------------------------------
      #       
      dict for {botname obj} [set $botobjs] {
        
        set ::eval_count 0 ;# Number of fitness evaluations performed
        
        test_random_seed $r      
        
        # или здесь обнновдять (инициировать) уже готовые объекты
        # 
        # $obj null or init ????? !!!!! TODO !!!

        #--------------------------------

        RUN1 "calc_" $obj -steps $max_generations -task $task -is_print 0
        
        # забираем результаты
        # 
        foreach {num_generations  best_entity  ch_form} \
          [RUN1 "final_" $obj] \
          break
        
        #--------------------------------

        set best_fitnes    [item_get_fitn $best_entity] 

        set best_as_string [ent_as_string_list  $best_entity $ch_form]

        if {0} {
          puts ""
          puts "---------------------------------"
          puts "num_generations = $num_generations"
          puts "best_entity     = [set $best_entity]"
          puts "ch_form         = $ch_form"
          puts "---------------------------------"
          puts "" 
        }

        #--------------------------------       
        # теперь напечатаем результаты по этому испытанию       

        puts ""
        
        puts -nonewline [format "$botname :  "]
        puts -nonewline [format "%02d gens,  " $num_generations]
        puts -nonewline [format "%04d eval,  " $::eval_count]
        puts -nonewline [format "str = %s,  " $best_as_string]
        puts -nonewline [format "fit = %5.2f " $best_fitnes]
        
        flush stdout  ;# все данные должны быть выведены
        #--------------------------------       

        # и еще нам нужна общая сумма по всем испытаниям (?)
        # 
        incr sum($botname) $::eval_count
      }
      # 
      # ------------------------------------------------------------  
      
      puts ""
      
    } ;# num_runs
    # -----------------------------------------------------------------  
    
    puts ""
    
  } ;# num_text 
  
  # ----------------------------------------------------------------- 
  
  #if {$max_generations == -1} {
    
    print_result_maintest  $botobjs sum
  #}
  
  return
}
# ------------------------------------------------------------------------------
proc make_bots_standart {bots lpop lgen task} {


  dict_set $bots "bot01" [BOT01 new  -lpop $lpop -lgen $lgen -task $task]
  dict_set $bots "bot02" [BOT02 new  -lpop $lpop -lgen $lgen -task $task]
  dict_set $bots "bot03" [BOT03 new  -lpop $lpop -lgen $lgen -task $task]
  dict_set $bots "bot04" [BOT04 new  -lpop $lpop -lgen $lgen -task $task]

}
# ------------------------------------------------------------------------------
proc maintest_531 {} {

  global argc argv

  puts "argc = $argc   argv = $argv"

  set mode [lindex $argv 1]

  puts "mode = $mode"
  puts ""
  

  set ::is_print 0 ;# TODO: здесь уж слишком много печати, надо гибче?

  set pmin 1  ;# выбираем длину блоков повторов из этого интервала: от
  set pmax 4  ;# и до

  set task [task_create  "FS_fitness" -fit_target $::fit_target]

  set lgen 15 ;# [strlen $::target_text] ;# длина хромосом (строк)

  set num_text 1 ;# 1 ;# 2
  set num_runs 1 ;# 2 ;# 5 ;# количество экспериментов. для повторов

  set max_generations -1 ;# 30 ;# 15 - останов по достижению нужной точности
  set lpop 30 ;# 140
    
  
  #-------------------------------------------------------------

  set bots [dict_create] 
  
  #-------------------------------------------------------------

  if {$mode == "@"} {

    # фиксированный тест
    srandom_set 2019 ;# постоянный выбор текстовой строки

    #set lgen 15 ;# [strlen $::target_text] ;# длина хромосом (строк)

    make_bots_standart  $bots $lpop $lgen $task

  #-------------------------------------------------------------
  } \
  elseif {$mode == "S"} {
  #-------------------------------------------------------------

    # фиксированный тест
    srandom_set 2019 ;# постоянный выбор текстовой строки

    #set lgen 9  ;# длина хромосом (строк)
    #set pmin 2  ;# выбираем длину блоков повторов из этого интервала: от
    #set pmax 3  ;# и до
    #
    # хочу сделать задачу поменьше (быстрее), а ее переклинивает!?
    # 
    # просто увеличив ошибку?

    set task [task_create  "FS_fitness" -fit_target $::fit_target -fit_error 8.0 ]

    #task_print $task

    make_bots_standart  $bots $lpop $lgen $task

  #-------------------------------------------------------------
  } \
  elseif {$mode == "A"} {
  #-------------------------------------------------------------

    set num_text 2 ;# 1 ;# 2
    set num_runs 2 ;# 2 ;# 5 ;# количество экспериментов. для повторов

    make_bots_standart  $bots $lpop $lgen $task

  #-------------------------------------------------------------
  } \
  elseif {$mode == "T"} {
  #-------------------------------------------------------------

    set task [task_create  "FS_fitness" -fit_target $::fit_target -fit_error 0.1 ]

    dict_set $bots "bot02" [BOT02 new  -lpop $lpop -lgen $lgen -task $task]

  #-------------------------------------------------------------
  } \
  elseif {$mode == "Z"} {
  #-------------------------------------------------------------

  #set ::target_text "122333444455555" она дальше все равно случайно выбирается

  set task [task_create "FS_fitness_list"]

  set sort_driver  "GT_lsort" 
  set randpop_proc "make_rand_prgpop" ;# "make_rand_prgpop_unikum"

  set lpop 10
  set lgen 15 ;# длина хромосом (строк)
  set max_generations -1 ;# 100 - останов по достижению нужной точности

  set obj \
    [bot33_create  -lpop $lpop -lgen $lgen \
       -sort_driver $sort_driver  -task $task -is_print 0]

  dict_set $bots "bot33" $obj 

  #-------------------------------------------------------------
  } else {

    puts "maintest_531: NOT mode"
  }
  #-------------------------------------------------------------



  maintest_run  $bots $task \
    $max_generations \
    $num_text $num_runs $pmin $pmax \
    $lgen 


return
}
#-------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
proc main {} {

  global argc argv argv0

  puts ""
  
  set taskname [lindex $argv 0] ;# имя выч. задачи
  
  $taskname ;# прсто выполним

  puts ""
  
  return
}
#-------------------------------------------------------------------------------

main

#-------------------------------------------------------------------------------
# 
# TODO:
# 
# +) Cделать ботов по всем тестам и добавить в соревнование maintest_531:

#    + переименовывать по номерам общих тестов, например bot01 для _01_test
#    + для bot02 общего теста нет, сразу в соревнование.
#    + bot03, bot04, bot05
#
#    + _dc_test    : bot06
#    + тест (eschemes, struggle2.c) разбить на bot07, bot08, bot09 

# 2) общая схемы "seed_proc" и "fitness_proc" (несколько вариантов)

# 3) Тест из файла g-croz.tl bot03  -> bot033, подогнать под общую схему
# 
# 4) Провести соревнования.
# 5) Найти аналогичные сравнительные тесты, пеерписать на них и сравниться.
# 6) Начать реализацию супербота (bot044) с выделением библиотечных подстрок, 
#    сравнить на соревнованиях, доказать, что такая идея дает большой профит!!
# 

# ------------------------------------------------------------------------------

#  g_stru.tl maintest_531 -1  (set num_runs 20)

# 1 mesto :     bot01,  23217 eval
# 2 mesto :     bot05,  26628 eval

# 3 mesto :     bot02,  29040 eval
# 4 mesto :     bot03,  32821 eval
# 5 mesto :     bot04,  45543 eval

# ------------------------------------------------------------------------------

# g_stru.tl _01_test 10 10           ................ PASSED
# g_stru.tl _03_test  3 8 2          ................ PASSED
# g_stru.tl _04_test  10 2 @         ................ PASSED
# g_stru.tl _05_test  2 10 1         ................ PASSED
# g_stru.tl _dc_test  1 5 2  @       ................ PASSED
# g_stru.tl _gp_test 2013 10 6 10    ................ PASSED
# g_stru.tl eschemes  5  1 1 1       ................ PASSED
# g_stru.tl maintest_531 @           ................ PASSED

#-------------------------------------------------------------------------------
#                       bnums, bsize, steps

# g_stru.tl _01_test        30      25           

# ******************************************************************************
