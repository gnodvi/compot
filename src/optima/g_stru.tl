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

source "g-corE.tl"

source "g-diff.tl"
source "g-detw.tl"

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------

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
# //------------------------------------------------------------------------------

#if {$::NEWTEST} {
#set ::allele_min_integer  48 ;# ('1') 
#set ::allele_max_integer 126 ;# ('~') 
#} else {
#set ::allele_min_integer__  32 ;# (' ') 
#set ::allele_max_integer__ 126 ;# ('~') 

#}

set ::target_text  "1 2 2 3 3 3 4 4 4 4 5 5 5 5 5"

set ::gp_list      "1 2 3 4 5 6 7 8 9"

gaul_random_seed 0


# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
proc LTARGET {} {

  set len [llength $::target_text]

  return $len
}
#------------------------------------------------------------------------------
# TODO: упростить

set ::FS_fitness_min_integer  32 ;# (' ') 
set ::FS_fitness_max_integer 126 ;# ('~') 

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
  
  set char_min $::FS_fitness_min_integer
  set char_max $::FS_fitness_max_integer

  set size_all   [- $char_max $char_min] 
  set size_all_half [/ $size_all 2.0] 


  set fit_add [expr {1.0 * ($char_max - $abs) / $size_all_half}]

  set fit [+ $fit $fit_add] 


  # подсчет идет в пространстве кодовых значений символов
  # 
  # добавляем признак, что уже ближе? холодно-теплее-горячо ?

  # чем больше, тем лучше (приближаясь к некому значению)
  # fit_tobest = MAX ?
  
  return $fit
}
# ------------------------------------------------------------------------------

#set ::fit_target 53.1
set ::fit_target 55.213

#------------------------------------------------------------------------------if
# 
proc FS_fitness {item_text_calc task} {

  set fit 0.0
  
  set len [item_get_chromo_len  $item_text_calc] 

  set text_true [GET $task "target_text"]


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

    set char_calc_decm  [item_get_chromo_gen  $item_text_calc  $k]

    #if {$::CHROMOLIST} { 
    set char_calc_decm [scan $char_calc_decm "%c"]  ;# десятичные коды символьных цифр
    #}


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
proc make_task_for_STRU {args} {

  set vers [dict_parse $args "-vers" 0]

  if {$vers == 0} {
    
    set fitness_func  "FS_fitness"
    set fit_target    $::fit_target
  }

  if {$vers == 1} {
    
    set fitness_func   "FITPROC_list_FS"

    # т.е. тоже больше фитнес - лучше, но мы приближаемся сдева к точносу 0 !!
    set fit_target     0    
  } 


  # а теперь
  #
  
  set size    [dict_parse $args "-size"  [LTARGET]] 
  set pmin 1  ;# 2 выбираем длину блоков повторов из этого интервала: от
  set pmax 4  ;# 3 и до 

  set task_local [task_create  -fit_func $fitness_func \
              -fit_tobest "MAX"       \
              -fit_target $fit_target \
              -fit_error 0.01         \
              -gp_list $::gp_list -target_text $::target_text \
              -size $size -pmin $pmin -pmax $pmax \
              ]  


  #set task [dict_parse $args "-task" $task_local]
  set task $task_local

  SET $task "fitness_func" $fitness_func
  SET $task "fit_target"   $fit_target
  
  return $task
}
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

  item_print_ch $best_entity ""
  puts ""

  set generation [GET $pop "generation"] ;# сколько было генераций
  puts "generation = $generation"

  puts [format "Total number of fitness evaluations: %ld" $::eval_count]

  puts ""

}
# ------------------------------------------------------------------------------
proc _01_test {} {

  global argc argv argv0
  set argv [lrange $argv 1 end]

  puts stderr "argv = $argv"

  set population_size [dict_parse $argv "-lpop" 10]
  set max_generations [dict_parse $argv "-nums" 10]

  set vers            [dict_parse $argv "-vers"  0]

  set target_text     [dict_parse $argv "-list"  $::target_text]
  set len_chromo      [dict_parse $argv "-size"  [LTARGET]] 
 
  puts ""
  puts "lpop  = $population_size"  ;# колич-во ботов
  puts "size  = $len_chromo" 
  puts "nums  = $max_generations"  ;# шагов эволюции  
  puts ""

  set ::is_print 1 ;# TODO: здесь уж слишком много печати, надо гибче?
  set print $::is_print

  test_random_seed 0 ;#$i
  
  #---------------------------------------------------------------------

  set task  [make_task_for_STRU -vers $vers]

  SET $task target_text $target_text 
  
  set obj \
    [BOT01 new  -lpop $population_size -lsrc $len_chromo -task $task -vers $vers] 

  if {$vers == 1} {
    set pop [GET $obj "pop"]
    SET $pop  select_one   "ga_select_one_bestof2"
    SET $pop  select_two   "ga_select_two_bestof2"
  }

  set ret [calc_BOT01 $obj {*}$argv -print $print]

  #---------------------------------------------------------------------
  
  do_print_stop_criteria  $ret $max_generations

  puts ""
  
  set pop [GET $obj pop]
   
  do_print_best $pop ""
  

  return
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

# ------------------------------------------------------------------------------
# //  struggle_generation_hook()
# //  synopsis:	This function is called by the main GA routine at the
# //		beginning of every generation.

  set ::sum_best_fitnesses 0.0  


# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
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

  set print 0

  if  {$argc == 1} { 
    # вызов без параметров, только с одним mode
    
    set par1  $def_par1
    set par2  $def_par2
 
  } else {

    set par1 [lindex $argv 1]
    set par2 [lindex $argv 2]

    if  {$argc == 4}    {
      set print 1
    }
  }

  set ::is_print $print

  return $print
}
# ------------------------------------------------------------------------------
proc allele_incr {adult allele incr_val}  \
{

  set oldval [item_get_chromo_gen $adult  $allele]

  item_set_chromo_gen $adult $allele [expr {$oldval + $incr_val}]

}
# ------------------------------------------------------------------------------
proc _3_struggle_adaptation {task pop child} \
{
  
  set eval_proc [GET $task "fit_func"]

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
  item_set_fitn  $adult [item_get_fitn $child]

  return $adult
}
# ------------------------------------------------------------------------------

dict_class_create  BOT03 {BOT} {

  ;# _это_перечисление_переменных
  
} {
  # а это конструктор класса 

  set len_chromo      [dict_parse $args "-lsrc" ] 
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

    #SET $pop ch_form "%c" ;# 
    SET $pop ch_form "%s " 
    
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
  set max_generations [dict_parse $args "-nums"] 
  
  set  pop [GET $obj pop]
  # 
  SET $pop "generation" 0
  SET $pop "itemlist"   {}
  
  set ret [ga_evolution  $task $pop $max_generations  {*}$args]  
  
  return $ret  
}
# //------------------------------------------------------------------------------
proc do_print_stop_criteria {ret max_generations} {


  puts "do_print_stop_criteria: ret = $ret, max_generations = $max_generations"
 
  if {$max_generations == -1 || $ret < $max_generations} {
    
    puts "The evolution was stopped: termination criteria "
  } else {
    puts "The evolution was stopped: maximum number of generations"
  }

}
# //------------------------------------------------------------------------------
proc _03_test {} \
{
  
  test_random_seed 0 ;# 23091975
  
  set population_size 120
  set max_generations 1000

  set print [parse_opts_2  population_size max_generations \
               120 1000]
  
  #----------------------------------------------------------------------

  set len_chromo [LTARGET] 
  
  set task [make_task_for_STRU]

  puts ""
  puts "bnums  = $population_size"  ;# колич-во ботов
  puts "bsize  = $len_chromo" 
  puts "maxgs  = $max_generations"  ;# шагов эволюции  
  puts ""

  #set ::is_print 1 ;# TODO: здесь уж слишком много печати, надо гибче?
  #set print $::is_print

  #----------------------------------------------------------------------

  set obj \
    [BOT03 new  -lpop $population_size -lsrc $len_chromo -task $task] 


  set pop [GET $obj pop]

  set ret [ga_evolution  $task $pop $max_generations -print $print]  


  do_print_stop_criteria  $ret $max_generations

  puts ""
  
  do_print_best $pop ""


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
proc _4_struggle_mutate {pop task father son} \
{
 
  # похоже это тоже самое !?
  # 
  ga_mutate_printable_singlepoint_drift  $pop $task $father $son


  return
}
# ------------------------------------------------------------------------------
# synopsis:	A pair of crossover operators which will be called
# 		alternately through the use of cross definitions.
#
# т.е. вызываются попеременно
# //------------------------------------------------------------------------------
proc _4_the_other_struggle_crossover {pop task  father mother son daughter} \
{

  ga_crossover_char_singlepoints  $pop $task  $father $mother $son $daughter

  SET $pop crossover _4_struggle_crossover

  return
}
# //------------------------------------------------------------------------------
proc _4_struggle_crossover {pop task  father mother son daughter} \
{
  ga_crossover_char_doublepoints $pop $task  $father $mother $son $daughter

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
  set len_chromo      [dict_parse $args "-lsrc" ] 
  set population_size [dict_parse $args "-lpop" ] 
  set task            [dict_parse $args "-task" ] 
  
  set pop [GAUL new  \
             -lpop $population_size -lsrc $len_chromo]
  
  #SET $pop ch_form "%c" ;# 
  SET $pop ch_form "%s " ;# 
    
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
  
  
  SET $pop seedproc    $seed_proc      ;# /* Individual initialisation    */
  
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
  ga_population_seed $pop $task
  
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
  set max_generations [dict_parse $args "-nums"] 
  
  set  pop [GET $obj pop]
  # 
  SET $pop "generation" 0
  SET $pop "itemlist"  {}
  
  set ret [ga_evolution  $task $pop $max_generations  {*}$args]  
  
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
  
  test_random_seed 0 ;# 23091975
  

  set population_size ""
  set max_generations ""

  set print [parse_opts_2  population_size max_generations \
               100 500]
  
  set len_chromo [LTARGET] 

  #-----------------------------------------------------------------

  set task [make_task_for_STRU]

  puts ""
  puts "bnums  = $population_size"  ;# колич-во ботов
  puts "bsize  = $len_chromo" 
  puts "maxgs  = $max_generations"  ;# шагов эволюции  
  puts ""

  #set ::is_print 1 ;# TODO: здесь уж слишком много печати, надо гибче?
  #set print $::is_print

  #----------------------------------------------------------------------

  set obj \
    [BOT04 new  -lpop $population_size -lsrc $len_chromo -task $task] 

  set pop [GET $obj pop]

  RUN1 "calc_" $obj -nums $max_generations -task $task -print $print

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

  set len_chromo      [dict_parse $args "-lsrc" ] 
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
  set max_generations [dict_parse $args "-nums"] 
  
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

  test_random_seed 0 ;# 42
  

  #----------------------------------------------------------------------

  set len_chromo [LTARGET] 
  
  set task [make_task_for_STRU]

  #----------------------------------------------------------------------

  set obj \
    [BOT05 new  -lpop $population_size -lsrc $len_chromo -task $task -num_pops $num_pops ] 

  set pops [GET $obj pops]

  RUN1 "calc_" $obj -nums $max_generations -task $task

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
  
  set len_chromo      [dict_parse $args "-lsrc" ] 
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
  set max_generations [dict_parse $args "-nums"] 
  
  set pop  [GET $obj pop]
  # 
  SET $pop "generation" 0
  SET $pop "itemlist"   {}
  
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
  
    set task [make_task_for_STRU]

    #----------------------------------------------------------

    set obj \
      [BOT06 new  -lpop $population_size -lsrc $len_chromo -task $task] 

    set pop [GET $obj pop]

    RUN1 "calc_" $obj -nums $max_generations -task $task

    #----------------------------------------------------------

    set best_entity [ga_get_entity_from_rank $pop 0]

    set best_fitnes [item_get_fitn $best_entity] 

    puts "The final solution with seed = $i was:"
    item_print_ch $best_entity ""

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
  
  test_random_seed 0 ;# 23091975

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

  set len_chromo      [dict_parse $args "-lsrc"] 
  set population_size [dict_parse $args "-lpop"] 
  set task            [dict_parse $args "-task"] 
  
  set pop [make_pop_DARWIN  $task $population_size $len_chromo] 
  
  SET $obj "pop"   $pop

}
# ------------------------------------------------------------------------------
# proc do_evolution_and_print_best {task pop max_generations name} \
# {

#   ga_evolution  $task $pop $max_generations   

#   do_print_best $pop $name

# }
#---------------------------------------------------------
proc calc_BOT79 {obj args} {
  
  
  set task             [dict_parse $args "-task" [GET $obj task]] 
  set max_generations  [dict_parse $args "-nums"] 
  
  set pop  [GET $obj pop]
  # 
  SET $pop "generation" 0
  SET $pop "itemlist"   {}

  set name [GET $obj name]
  
  #do_evolution_and_print_best $task $pop $max_generations1 $name

  ga_evolution  $task $pop $max_generations {*}$args   

  do_print_best $pop $name

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
# ------------------------------------------------------------------------------
proc eschemes {} \
{


  global argc argv argv0
  
  set ::is_print 0
  set print $::is_print
  
  set population_size  150
  set max_generations1 600
  set max_generations2 300
  set max_generations3 300
  
  if  {$argc > 1} { 
    
    set population_size  [lindex $argv 1]
    set max_generations1 [lindex $argv 2]
    set max_generations2 [lindex $argv 3]
    set max_generations3 [lindex $argv 4]
    
  }
    
  #----------------------------------------------------------------------

  set task [make_task_for_STRU]

  set len_chromo [LTARGET] 
  
  #----------------------------------------------------------------------

  set obj7 \
    [BOT07_new  -lpop $population_size -lsrc $len_chromo -task $task -name Darwinian ] 
 
  set obj8  \
    [BOT08_new  -lpop $population_size -lsrc $len_chromo -task $task -name Baldwinian] 

  set obj9 \
    [BOT09_new  -lpop $population_size -lsrc $len_chromo -task $task -name Lamarckian] 

  #----------------------------------------------------------

  if {! $print} {
    RUN1 "calc_" $obj7 -task $task -nums $max_generations1 -print $print
  }
  
    RUN1 "calc_" $obj8 -task $task -nums $max_generations2 -print $print
  
  if {! $print} {
    RUN1 "calc_" $obj9 -task $task -nums $max_generations3 -print $print
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
#-------------------------------------------------------------------------------
proc ent_as_string_list {e ch_form} {


  if {$ch_form == ""} {
    set ch_form [GET $e ch_form] ;# локальная переменная
  }

  set ch  [item_get_mainsrc $e]
  
  #puts -nonewline $out $name
  
  set buf {}

  foreach c $ch {

    #append buf [format $ch_form $c]
    lappend buf [format $ch_form $c]

  } 
  
  return $buf
}
# ------------------------------------------------------------------------------
# proc make_text_variant {task  t} {


#   set size    [GET $task "size"] 
#   set pmin    [GET $task "pmin"] 
#   set pmax    [GET $task "pmax"] 

#   set gp_list      [GET $task "gp_list"] 
#   set target_text0 [GET $task "target_text"] 

  
#   test_random_seed $t      


#   if {$t == 0} { 
#     # берем задачу-строку  по умолчанию
#     set text  $target_text0
#   } else {
#     set text  [make_random_target_text   $gp_list $size  $pmin $pmax]
#   }
  
#   return $text
# }
# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
proc make_bots_standart {bots lpop size task} {


  dict_set $bots "bot01" [BOT01 new  -lpop $lpop -lsrc $size -task $task]
  dict_set $bots "bot02" [BOT02 new  -lpop $lpop -lsrc $size -task $task]
  dict_set $bots "bot03" [BOT03 new  -lpop $lpop -lsrc $size -task $task]
  dict_set $bots "bot04" [BOT04 new  -lpop $lpop -lsrc $size -task $task]

}
# ------------------------------------------------------------------------------
proc make_bots_list {task gp_list target_text0 args} {


  # -----------------------------------------------------------------

  set mode       [dict_parse  $args "-mode"     S] 

  puts "[procname], mode = $mode ............."
  puts ""

  set lpop       [dict_parse  $args "-lpop"     30]    
  set ::is_print [dict_parse  $args "-print"     1]

  set size       [dict_parse  $args "-size"     [LTARGET]] 
  set pmin       [dict_parse  $args "-pmin"] 
  set pmax       [dict_parse  $args "-pmax"] 

  # -----------------------------------------------------------------


  set bots [dict_create] 
  
  #-------------------------------------------------------------

  if {$mode == "@"} {
  #-------------------------------------------------------------

    math_random_seed_null 2019 ;# постоянный выбор текстовой строки

    #set lpop 30 ;# 30 ;# 30 ;# 140
    #set ::is_print 1

    make_bots_standart  $bots $lpop $size $task

  #-------------------------------------------------------------
  } \
  elseif {$mode == "T"} {
  #-------------------------------------------------------------

    #set args_add "-size $size "

    #--------------------------------------------

    math_random_seed_null 2019 ;# постоянный выбор текстовой строки
    
    set vers 0
    set task [make_task_for_STRU -vers $vers]

    ####################
    #dict_print_real $task
    ####################

    set obj [BOT01 new  -lpop $lpop -lsrc $size -task $task -vers $vers]

    dict_set $bots "bot01_vers0" $obj

    ####################
    #dict_print_real $obj
    ####################

    #--------------------------------------------

    set vers 1
    set task [make_task_for_STRU -vers $vers]

    set obj [BOT01 new  -lpop $lpop -lsrc $size -task $task -vers $vers]

    set pop [GET $obj "pop"]
    SET $pop  select_one   "ga_select_one_bestof2"
    SET $pop  select_two   "ga_select_two_bestof2"

    dict_set $bots "bot01_vers1" $obj

  #-------------------------------------------------------------
  } \
  elseif {$mode == "S"} {
  #-------------------------------------------------------------

    # хочу сделать задачу поменьше (быстрее),
    # просто увеличив ошибку?

    SET $task "fit_error" 8.0
    #SET $task "fit_error" 1.0

    make_bots_standart $bots  $lpop $size $task

    # а ведь можно просто фиксировать маленькое кол-во шагов
    # и считать 1) сколько раз достигнем цели или
    #           2) как близко подойдет к ней.
 
  #-------------------------------------------------------------
  } \
  elseif {$mode == "Z"} {
  #-------------------------------------------------------------

    set task [make_task_for_STRU -vers 1]

    #dict_print_real $task
    #exit
    SET $task "fit_error" 8.0

    set sort_driver  "MAX_to_LEFT" 
    set randpop_proc "make_rand_prgpop" ;# "make_rand_prgpop_unikum"
    
    set obj \
      [BOT33 new   -lpop $lpop -lsrc $size \
         -sort_driver $sort_driver  -task $task -is_print 1]
    
    
    dict_set $bots "bot33" $obj 
    
  #-------------------------------------------------------------

  } else {
  #-------------------------------------------------------------

    set task [make_task_for_STRU]

    dict_set $bots "bot$mode" [BOT$mode new  -lpop $lpop -lsrc $size -task $task]

  }
  #-------------------------------------------------------------


  #puts "lpop = $lpop"
  #puts "size = $size"
  #puts ""

return $bots
}
# ------------------------------------------------------------------------------
proc task_correct_target_text {task t r} {

  #set target_text [make_text_variant  $task $t]

  set size    [GET $task "size"] 
  set pmin    [GET $task "pmin"] 
  set pmax    [GET $task "pmax"] 

  set gp_list      [GET $task "gp_list"] 
  set target_text0 [GET $task "target_text"] 

  
  test_random_seed [+ $t $r]      


  if {$t == 0} { 
    # берем задачу-строку  по умолчанию
    set text  $target_text0
  } else {
    set text  [make_random_target_text   $gp_list $size  $pmin $pmax]
  }


  #SET $task "target_text" $target_text
  SET $task "target_text" $text

  return
}
# ------------------------------------------------------------------------------
proc maintest_531 {} {

  global argc argv

  #puts "argc = $argc   argv = $argv"
 
  # надо оставить только словарные параметры
  # 
  set argv [lrange $argv 1 end]

  # -----------------------------------------------------------------

  set num_text  [dict_parse $argv "-text"  1] ;# 1 ;# 2  
  set size      [dict_parse $argv "-size"  [LTARGET]] 
  #set print     [dict_parse $argv "-print" 0] 

  set pmin 1  ;# 2 выбираем длину блоков повторов из этого интервала: от
  set pmax 4  ;# 3 и до 
  
  # -----------------------------------------------------------------

  set num_text        [dict_parse $argv "-text"  1] ;# 1 ;# 2
  set num_runs        [dict_parse $argv "-runs"  1] ;# 2 ;# 5 ;# количество экспериментов
  set max_generations [dict_parse $argv "-nums" -1] ;# 30 ;# 15 - останов 


  set task  [make_task_for_STRU {*}$argv]

  set botobjs [make_bots_list  $task $::gp_list $::target_text  {*}$argv]


  #---------------------------------------------------------
#   set targets {}

#   for {set t 0} {$t < $num_text} {incr t} {

#     #test_random_seed $t      
#     set target_text [make_text_variant  $task  $t]
    
#     lappend targets $target_text
#   }
  #---------------------------------------------------------

  #set num_text [llength $targets]

  maintest_run  $botobjs  "task_correct_target_text"  \
                $num_text $num_runs $max_generations  {*}$argv


  # g_stru.tl maintest_531 -mode @ -text 3 -runs 3
  # 
  # 1 mesto :    bot01,   8838 eval
  # 2 mesto :    bot02,  13830 eval
  # 3 mesto :    bot03,  15453 eval
  # 4 mesto :    bot04,  17274 eval

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

# 2) общая схемы "seed_proc" и "fit_func" (несколько вариантов)

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
