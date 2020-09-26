# -*-   mode: tcl  ; coding: koi8   -*- ----------------------------------------

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------

#namespace import ::struct::*

#set ::NEWEST 1 ;# !!!!!!!!!!!!!!!!!!! OK !!!!

set ::NEWPOP 0

#-------------------------------------------------------------------------------


set ::GA_BOLTZMANN_FACTOR	1.38066e-23


set ::sort_driver "MAX_to_LEFT" ;# функция признак-сортировки
set ::ISREVERSE 0


# #define GA_TINY_DOUBLE		(1.0e-9)

#-------------------------------------------------------------------------------

# item - это prog через указатель !!

#-------------------------------------------------------------------------------
# proc l_set_option_ {e optname i val} {

#   #set optname chrom_some
#   #
#   # но также используется и для популяции !

#   set  tmp [GET $e $optname] ;# это список

#   #if {$::is_print} {
#   #  puts "i = $i  val = $val llength = [llength $tmp]"
#   #  puts "tmp = $tmp " ;# списка нет?
#   #}
  

#   if {[llength $tmp] == 0} {
#     lset tmp $val
#   } else {
#     lset tmp $i $val
#     #lset options(-chromosome) $i $val ;#list index out of range ?? 
#   }

#   SET $e $optname $tmp

# }
#-------------------------------------------------------------------------------
# proc l_set_option_pop {e optname i val} {

#   #set optname chrom_some
#   #
#   # но также используется и для популяции !

#   #if {$::NEW} {    
#   #  set  tmp [GET $e $optname] ;# это список
#   #} else {
#     set  tmp [GET $e $optname] ;# это список
#   #}

#   #if {$::is_print} {
#   #  puts "i = $i  val = $val llength = [llength $tmp]"
#   #  puts "tmp = $tmp " ;# списка нет?
#   #}
  

#   #if {[llength $tmp] == 0} {
#   #  lset tmp $val
#   #} else {
#     lset tmp $i $val
#     #lset options(-chromosome) $i $val ;#list index out of range ?? 
#   #}

#   #if {$::NEW} {    
#   #  SET $e $optname $tmp
#   #} else {
#     SET $e $optname $tmp
#   #}
  
# }
#-------------------------------------------------------------------------------
#  ENTITY_T    ENTITY_T   ENTITY_T   ENTITY_T   ENTITY_T   ENTITY_T   ENTITY_T
#-------------------------------------------------------------------------------

# (defstruct ORGANISM  
#   genotype  ; project program 

#   (standardized-fitness 0)
#   (adjusted-fitness     0)
#   (normalized-fitness   0)
#   (hits                 0)
# )

# record define ENTITY_T {

#   chrom_some ;# vpointer* : The chromosomes (the genotype)
#   ch_form    ;# "% 6.3f" ;#  " %02d"

#   fitness    ;# double    : Fitness score
#   # vpointer  data; // User data containing physical properties. (the phenotype)
# }

#-------------------------------------------------------------------------------
proc make_list {num val} {

  set ret ""

  for {set i 0} {$i < $num} {incr i} {

    lappend ret $val
  }

  return $ret
}
#-------------------------------------------------------------------------------
#
#-------------------------------------------------------------------------------
proc ent_create_ {len_chromosome} {

    
  set e [dict_create]
  
  # зачем здесь задавать жесткую длину ??
  # 
  set tmp  [make_list $len_chromosome "@"]

  ent_set_chromosome_ $e $tmp
          

  SET $e ch_form    "% 6.3f " ;#  " %02d" 
 
  return $e
}
#-------------------------------------------------------------------------------
proc ent_set_chromosome_ {e ch} {


  SET $e "main" "src" $ch

}
#-------------------------------------------------------------------------------
proc ent_get_chromosome_ {e} {


  return [GET $e "main" "src"]

}
#-------------------------------------------------------------------------------
proc ent_CH_ {e} {


  return [ent_get_chromosome_ $e]

}
#-------------------------------------------------------------------------------
proc ent_set_chromo_gen_ {e i val} {
  
  set  tmp [ent_get_chromosome_ $e]

  lset tmp $i $val

  ent_set_chromosome_  $e $tmp

  return
}
#-------------------------------------------------------------------------------
proc ent_get_chromo_gen_ {e i} {

  set  tmp [ent_get_chromosome_ $e]
  
  return [lindex $tmp $i]
}
#-------------------------------------------------------------------------------
proc ent_get_chromo_len_ {e} {

  set  tmp [ent_get_chromosome_ $e]
  
  return [llength $tmp]
}
#-------------------------------------------------------------------------------
proc ent_print_ch_ {e {name "ch=   "} {out "stdout"} {ch_form ""}} {

  #set ch_form ""

  if {$ch_form == ""} {
    set ch_form [GET $e ch_form] ;# локальная переменная
  }

  set ch      [ent_get_chromosome_ $e]
  
  puts -nonewline $out $name
  
  foreach c $ch {

    if {[catch {puts -nonewline $out [format $ch_form $c]} err]} {

      puts -nonewline $out "$c "
      #puts -nonewline $out "$c ;"
    }
  } 
  
  flush $out  ;# все данные должны быть выведены
}
#-------------------------------------------------------------------------------
proc ent_print_oneline_ {e {out "stdout"}} {


  ent_print_ch_ $e "ch=   " $out
  
  
  set fi [item_get_fitn $e]
  
  if {[string equal $fi $::GA_MIN_FITNESS]} {

    puts -nonewline $out "   fitness= GA_NOT_FITNESS"
  } else {
    puts -nonewline $out "   fitness= [format "%f"  $fi]"
  }
  
  puts $out ""
}
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#
#-------------------------------------------------------------------------------
proc item_make {{src @}} {

  set item [dict_create]
  
  dict_set $item  "main" [list "src" $src]

  item_set_fitn   $item "@"  ;# $fitness

  return $item ;# указатель на словарь
}
#-------------------------------------------------------------------------------
proc item_set_fitn {item fitness} {


  dict_set  $item "fitn" $fitness

}
#-------------------------------------------------------------------------------
proc item_get_fitn {item} {

  # dict get работает не с именем, а непосредственно со словаоем, и получить его 
  # можно используя $name, либо надежнее, если имя уже по ссылке, то [set $name]

  return  [dict_get  $item "fitn"]

}
#-------------------------------------------------------------------------------
proc item_get_prog {item} {


  return [set $item]

}
#-------------------------------------------------------------------------------
proc prog_set_prg_src {&prog prg_name prg_src} {

  # TODO: наверное главная проблема - нужно сделать через ссылки на словари!!
  # 

  USE_REFS

  dict set prog $prg_name "src" $prg_src  ;# занесем процедуру в библиотеку

}
#-------------------------------------------------------------------------------
proc prog_get_prg_src {prog prg_name} {

  
  return [dict get $prog  $prg_name "src"] 
}
#-------------------------------------------------------------------------------
proc item_get_main_src {item} {

  set prog [item_get_prog $item]

  return [prog_get_prg_src $prog "main"]

}
# ------------------------------------------------------------------------------
proc generation_hook_check {pop generation} \
{

  set  g_hook [GET $pop generation_hook]

  if {$g_hook == "NULL"} {return 1} ;# true

  set ret [$g_hook  $generation $pop] 

  return $ret
}
# //----------------------------------------------------------------------------
proc is_check_generation_break {pop generation max_generations 
                                  fit_target fit_error is_print} {


  set item0  [pop_get_entity_ $pop  0] ;# лучший итем?

  set fitn0  [item_get_fitn   $item0]
  set fitn0  [format "%7.3f"  $fitn0]
  
  set index  [format "% 3d"   $generation]
  
  if {$is_print >= 1} {
    
    if {$is_print >= 2} {puts ""}
    
    puts -nonewline "GA EVOLUTION $index  ...  f0 = $fitn0  "
    ent_print_ch_     $item0 "i0 =  "
    puts ""
    
    if {$is_print >= 2} {puts ""}
    
  } else {
    
    set ret [generation_hook_check $pop $generation]
  }
  
  
  if {$max_generations == -1} { 
    #
    # нщем целевое значение фитнеса fit_target
    
    set delta [expr {abs ($fitn0 - $fit_target)}]
    if {$delta <= $fit_error} {
      #break
      return 1 ;# true
    } 
    
  } else {
    if {$generation >= $max_generations} {
     # break
      return 1 ;# true
    } 
  }
  
  return 0 ;# false
}
#-------------------------------------------------------------------------------
proc item_calc_fitness {item_ptr fitnessfunc task} {

  #pop_eval_item $pop $e $eval_proc $task


  set prog [item_get_prog    $item_ptr]
  set src  [prog_get_prg_src $prog "main"] 

  #-------------------------------------
  #puts ""
  #puts "prog = $prog"
  #puts " src =  $src"
  #puts ""
  #-------------------------------------

  #set fitn  [$fitnessfunc  $src $prog] ;# запускаем тест 
  set fitn  [$fitnessfunc  $src]  

  incr ::eval_count

  #-------------------------------------

  #set fitn  [$fitnessfunc  $src "@"]
  #set fitn  [$fitnessfunc  "@" $prog]

  #-------------------------------------
  #
  # на переходный еприод можно и так и так запускать, т.е. если указана prog,то
  # выполняется полная версия, иначе выполняется src - т.е. без библиотеки

  # if {[string equal $prog "@"]} {
  #   run_v1_src   $src_11 
  # } else {
  #   run_v1_prog  $prog
  # }
  #-------------------------------------

  item_set_fitn  $item_ptr  $fitn
  
}
#-------------------------------------------------------------------------------

set ::is_fitn_first 1

#-------------------------------------------------------------------------------
proc item_print_fitness_calc {task item i} {


  set fitnessfunc [GET $task "fitness_proc"]  


  puts -nonewline [format "  %2d)" $i]
  
  #-----------------------------------------------
  #set src   [item_get_main_src   $item] 
  #set fitn  [item_get_fitn       $item] 
  
  if {$::is_fitn_first} {

    item_calc_fitness  $item $fitnessfunc  $task
    
    set src   [item_get_main_src   $item] 
    set fitn  [item_get_fitn       $item] 
    
    puts [format "  fitn = % 3s :   %s" $fitn $src]
    
  } else {
    
    set src   [item_get_main_src   $item] 
    set fitn  [item_get_fitn       $item] 
    
    #puts [format "  %s     fitn = %s" $src $fitn]
    puts -nonewline [format "  %s     " $src]
    flush stdout               ;# все данные должны быть выведены
    
    item_calc_fitness  $item $fitnessfunc   $task 
    
    puts [format "fitn = %s" $fitn]
  }
  #-----------------------------------------------
  #
  # item_print  $item
  
  return
}
#-------------------------------------------------------------------------------
proc item_print {item} {

  set src   [item_get_main_src   $item] 
  set fitn  [item_get_fitn       $item] 

  if {$::is_fitn_first} {
    puts [format "  fitn = %s :   %s" $fitn $src]
  } else {
    puts [format "  %s     fitn = %s" $src $fitn]
  }

  return 
}
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#
#-------------------------------------------------------------------------------
# proc sort_command {a b} {

#   set a_fit [ent_get_fitness $a]
#   set b_fit [ent_get_fitness $b]

#   if {$a_fit >  $b_fit}  {return -1} ;# т.е бОльшие будут слева в списке (вверху)
#   if {$a_fit == $b_fit}  {return  0} 
#   if {$a_fit <  $b_fit}  {return  1} 

#   return 1
# }
#-------------------------------------------------------------------------------
#  POPULATION_T    POPULATION_T    POPULATION_T    POPULATION_T    POPULATION_T   

#-------------------------------------------------------------------------------

# (defvar *check_already_created* t)

# (defvar *program* :unbound)

# ;(defvar *get_starter*    #'(lambda (program) program))
# (defvar *genotype_print* #'(lambda (genotype) (format t "~S ~%" genotype)))

# (defvar *size-of-population* :unbound)
# (defvar *best-of-population* :unbound) 

# ;; метод селекции особей в популяции; это
# ;; или :fitness-proportionate, :tournament
# ;; или :fitness-proportionate-with-over-selection
# (defvar *method-of-selection*                         :unbound)

# (defvar *tournament-size* :unbound
#   "The group size to use when doing tournament selection.")

# ;; хэш-таблица..
# ;; используется, чтобы гарантировать, что все особи 0-го поколения - уникальны.
# ;;
# (defvar *generation-0-uniquifier-table* (make-hash-table :test #'equal))

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------

class_create 0 POP {} {

  ;# _это_перечисление_переменных
  
  stable_size      ""  ;# _требуемый_размер_популяции
  len_chromosomes  ""  ;# _int_:_Maximum_length_of_each_chromosome
  
  ch_form          ""  ;# _"%02d"     
  generation_hook  ""  ;# _GAgeneration_hook_generation_hook 

  sort_driver      ""  ;# _
  itemslist        ""  ;# _ 
  generation       ""  ;# _ 

} {
  # а это конструктор класса 

  #-----------------------------------------------
  # 
  
  if {$::__JIM__ && $::NEWPOP}  {
    set args [lindex $args 0] 
  }
 
  # 
  #-----------------------------------------------

  set  stable_size    [dict_parse $args "-lpop"] 
  set len_chromosomes [dict_parse $args "-lgen"] 
  
  set  "ch_form"  "% 6.3f " ;#  " %02d"   
  set generation_hook NULL
  
}

#-------------------------------------------------------------------------------
#   Population handling functions.

#   synopsis:	Allocates and initialises a new population structure,
# 		and assigns a new population id to it.

#   parameters:	const int stable_size    кол-во переданных в след. поколение.
# 		const int num_chromosome	Num. of chromosomes.
# 		const int len_chromosome	Size of chromosomes (may be ignored).

#   return:	population *	new population structure.
#-------------------------------------------------------------------------------


#--------------------------------
if {1} {
#--------------------------------

class_create 0 GAUL {POP} {

  # это перечисление переменных
  
  max_size  ""  ;# _текущий_максимальный_размер
  size      ""  ;# _актуальный_размер

  generation "" ;# _номер_текущей_генерации
  best       "" ;# _для_хранения_лучшего_номера

  ;# _здесь_основной_массив_хранения
  ;# _
  itemslist  "" 


  ;# _/*
  ;# __*_The_scoring_function_and_the_other_callbacks_are_defined_here.
  ;# __*/
  iteration_hook ""
  
  seed           "" 
  
  select_state "" ;# _Available_to_selection_algorithms.
  selectdata   "" ;# _State_values_for_built-in_selection_operators.
  
  select_one   "" 
  select_two   "" 

  mutate       "" 
  crossover    "" 
  adapt        "" 


  allele_min_integer "" 
  allele_max_integer ""

  allele_min_double  ""
  allele_max_double  ""
  
  ;# _/*
  ;#  _*_Special_parameters_for_particular_built-in_GA_operators.
  ;#  _*_FIXME:_I_don't_like_how_this_is_currently_implemented;_need_a_more
  ;#  _*_elegant_approach.
  ;#  _*/

  ;# _/*
  ;# __*_Evolutionary_parameters.
  ;# __*/
  crossover_ratio "" ;# _double___/*_Chance_for_crossover._*/
  mutation_ratio  "" ;# _double___/*_Chance_for_mutation.__*/
  migration_ratio "" ;# _double___/*_Chance_for_migration._*/

  scheme          "" ;# _ga_scheme_type__/*_Evolutionary_scheme.__*/
  elitism         "" ;# _ga_elitism_type_/*_Elitism_mode._________*/
  

  algo_params     "" ;# _сюда_будут_по_дключаться_все_структуры_разных_"классов"_алгоритмов

  ;# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  replace         "" ;# _GAreplace_replace;
  rank            "" ;# _GArank_rank;

  ;# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  island          ""
  step            ""

  ;# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  de_params         ""
  sa_params         ""
  dc_params_compare ""
  gr_params         ""



} {
  # а это конструктор класса 

  set args [lindex $args 0] ;# передаем аргументы целым списком, как в JIM
  
  # --> POP
  # 
  #SUPER constructor $args

  SUPER constructor {*}$args
  
  #-------------------------------------------------

    set  max_size       {}
    set  size           {}

    set iteration_hook  NULL
    
    set seed            {}
    set select_state    {}
    set selectdata      {}
    
    set select_one      {}
    set select_two      {}
    
    set mutate          {}
    set crossover       {}
    set adapt           NULL
    
    set allele_min_integer {}
    set allele_max_integer {}
    set allele_min_double  {}
    set allele_max_double  {}
    
    set crossover_ratio    {}
    set mutation_ratio     {}
    set migration_ratio    {}
    
    set scheme             {}
    set elitism            {}
    set algo_params {}
    
    set replace     {}
    set rank        {}
    
    set island      {}
    set step        {}
    
    set de_params   {}
    set sa_params   {}
    set dc_params_compare {}
    set gr_params         {}

    #---------------------------------------

    #set ::sort_driver "MAX_to_LEFT" ;# функция признак-сортировки
    
    #---------------------------------------
    
    #$newpop.selectdata = [selectdata_create]
    # 
    set  "selectdata" [selectdata_create]
    
    #[$newpop.selectdata].offset1 = 555
    #puts "offset1 = [[$newpop.selectdata].offset1]"
    
    #   newpop->data = NULL;
    #   newpop->free_index = newpop->max_size-1;
    
    #   newpop->fitness_dimensions = 0;
    #SET $newpop "fitness_dimensions" 0

    #   newpop->crossover_ratio = GA_DEFAULT_CROSSOVER_RATIO;
    #   newpop->mutation_ratio = GA_DEFAULT_MUTATION_RATIO;
    #   newpop->migration_ratio = GA_DEFAULT_MIGRATION_RATIO;
    set "scheme" GA_SCHEME_DARWIN;
    
    #   newpop->elitism = GA_ELITISM_PARENTS_SURVIVE;  
    #   newpop->allele_mutation_prob = GA_DEFAULT_ALLELE_MUTATION_PROB;
    
    #   newpop->allele_max_integer = RAND_MAX-1;
    set "allele_min_integer" 0

    set "allele_max_integer" [expr {$::RANDOM_RAND_MAX - 1}] ;# попробуем так
    
    set "allele_min_double" $::DBL_MIN
    set "allele_max_double" $::DBL_MAX
    
    set "rank" "ga_rank_fitness"

    #---------------------------------------

    set generation      {}  
    set best            {}     
    set itemslist       {}
    
    set  "island"    -1
    set "generation"  0    
    set "best"       -1 ;# для хранения лучшего номера (пока нет)
    
}

#--------------------------------
} else {
#--------------------------------

#--------------------------------
}
#--------------------------------



#-------------------------------------------------------------------------------
proc pop_set_entity_fitness_ {p i fi} {
    
  set ent  [pop_get_entity_ $p  $i]

  #ent_set_fitness $ent $fi

  item_set_fitn $ent $fi

}
#-------------------------------------------------------------------------------
proc pop_get_entity_fitness_ {p i} {
    
  set ent  [pop_get_entity_ $p  $i]
  
  if {0} {
    puts ""
    puts "pop_get_entity_fitness_: i = $i  ent = $ent"
    puts ""
    #exit
  }

  #return [ent_get_fitness $ent]

  return [item_get_fitn $ent]

}
#-------------------------------------------------------------------------------

#   set  ip [dict_get $::ctx_NEW "ip"]
#   incr ip
#   dict_set $::ctx_NEW "ip" $ip

#-------------------------------------------------------------------------------
proc get_pop_size {pop} {

  set list [GET $pop "itemslist"]

  set size [llength $list]

  return $size
}
#-------------------------------------------------------------------------------
# proc set_pop_size {p val} {

#   SET $p size  $val
  
# }
#-------------------------------------------------------------------------------
# proc pop_incr_size_ {p val} {

#   set  old_size [GET $p size]
#   #set  old_size [get_pop_size $p]

#   incr old_size $val

#   #SET $p size  $old_size
#   #set_pop_size  $p $old_size
  
# }
#-------------------------------------------------------------------------------
proc pop_add_entity_ {p entity} {

  
  set tmp [GET $p itemslist]

  #puts "pop_add_entity_: tmp = $tmp, entity = [set $entity]"

  lappend tmp $entity

  SET $p  itemslist $tmp ;# ERROR on JIM !!???

  #pop_incr_size_ $p  1
  
  return 
}
#-------------------------------------------------------------------------------
proc pop_set_entity_ {p i entity} {

  #l_set_option_pop $p "itemslist" $i $entity

  set optname "itemslist"

  set  tmp [GET $p $optname] ;# это список

  lset tmp $i $entity

  SET $p $optname $tmp

}
#-------------------------------------------------------------------------------
proc pop_get_entity_ {p i} {

  set tmp [GET $p itemslist]
  
  set r [lindex $tmp $i]
  
  return $r
}
#-------------------------------------------------------------------------------
proc pop_print_lite_ {p {out "stdout"}} {


  set i 0  
  set tmp [GET $p itemslist]
  

  foreach e $tmp {
    
    puts -nonewline $out [format "   i = %3d   " $i]
    
    ent_print_oneline_ $e $out

    incr i
  }

  return
}
#-------------------------------------------------------------------------------
proc pop_print_ {p {out "stdout"}} {

  #puts "options = [array get options]"
  
  #set out "stdout"

  puts $out "---------------------- POPULATION PRINT -------------------------------"
  puts $out ""
  puts $out "Generation = [GET $p generation]"
  puts $out ""
  
  pop_print_lite_ $p $out
  
  set best     [GET $p best]
  
  puts $out ""
  puts $out "STABLE_SIZE = [GET $p stable_size] "
  #puts $out "SIZE        = [GET $p size] "
  puts $out "SIZE        = [get_pop_size $p] "
  puts $out "BEST        = $best "
  puts $out ""
  
  if {$best != -1} {
    #set best_fit [$p get_entity_fitness $best]
    set best_fit [pop_get_entity_fitness_ $p  $best]
    
    puts $out [format "BEST = $best  (fitness = %f) " $best_fit]
  }
  
  puts $out " "
  puts $out "-----------------------------------------------------------------------"

}
#-------------------------------------------------------------------------------
proc MAX_to_LEFT {a b} {

  #set a_fit [ent_get_fitness $a]
  #set b_fit [ent_get_fitness $b]

  set a_fit [item_get_fitn $a]
  set b_fit [item_get_fitn $b]

  # налево, т.е. в лучшие отправим с БОЛЬШИМ фитенсом 
  #                     (это должно быть по умолчанию)

  return [GT $a_fit $b_fit]
}
#-------------------------------------------------------------------------------
proc MIN_to_LEFT {a b} {

  #set a_fit [ent_get_fitness $a]
  #set b_fit [ent_get_fitness $b]

  set a_fit [item_get_fitn $a]
  set b_fit [item_get_fitn $b]

  # налево, т.е. в лучшие отправим с МЕНЬШИМ фитенсом 
  #                      (вариант для особых случаев)

  return [LT $a_fit $b_fit]
}
#-------------------------------------------------------------------------------
proc pop_sort_ {p} {

  if {[get_pop_size $p] == 0} {
    return ;# если в популяции ничего еще нет !!
  }
  
  # в случае, если специально определена функция сравнения (а не просто по фитнесу)
  # т.е. if (pop->rank != ga_rank_fitness) то надл использовать эту функцию!
  #
  #set rank_proc [$self cget -rank]
  #if {$rank_proc != "ga_rank_fitness"} {
  #  die "NOT ..... ga_rank_fitness"
  #}
  
  #set ::sort_driver "MAX_to_LEFT" ;# функция признак-сортировки
  # будем определять при создании популяции

  SET $p itemslist  [qsort_AF [GET $p  itemslist] $::sort_driver]


  SET $p best 0 ;# после сортировки это должно быть так

}
#-------------------------------------------------------------------------------
proc pop_print {pop {out "stdout"}} {


  pop_print_ $pop $out

}
#-------------------------------------------------------------------------------

# /*
#  * Constant definitions.
#  */

# // к сожалению DBL_MAX и DBL_MIN используется в алгоритмах мутации, случ. чисел
# // и т.д. поэтому просто так поменять не получистя !
# // 

# /* Define lower bound on fitness. */
# #define GA_MIN_FITNESS			-DBL_MAX

# DBL_MAX is defined in <float.h>. Its availability in <limits.h> on unix 
# DBL_MAX = 1.79769e+308
#

set ::DBL_MAX  999999999999999999
set ::DBL_MIN -999999999999999999


# set ::DBL_MIN 0.000000 
# set ::DBL_MAX 179769313486231570814527423731704356798070567525844996598917476803157260780028538760589558632766878171540458953514382464234321326889464182768467546703537516986049910576551282076245490090389328944075868508455133942304583236903222948165808559332123348274797826204144723168738177180919299881250404026184124858368.000000 

#set ::GA_MIN_FITNESS 999999999999999999
#set ::GA_MIN_FITNESS [expr {- $::DBL_MAX}]

#set ::GA_MIN_FITNESS  $::DBL_MIN
#set ::GA_MIN_FITNESS  $::DBL_MAX

#set ::GA_MIN_FITNESS  -9999 
set ::GA_MIN_FITNESS   "NOT-FIT"
;#  - почему-то ошибка на  g_ping.tl _sa  1 1 1
#                                неверная инициация?  @@@@@@@
#set ::GA_MIN_FITNESS  ABCD 

# /*
#  * Define some default values.
#  */
# #define GA_DEFAULT_CROSSOVER_RATIO	0.9
# #define GA_DEFAULT_MUTATION_RATIO	0.1
# #define GA_DEFAULT_MIGRATION_RATIO	0.1

# /*
#  * Define chance of any given allele being mutated in one mutation
#  * operation (only for certain mutation functions).
#  */
# #define GA_DEFAULT_ALLELE_MUTATION_PROB	0.02

# /*
#  * A private prototype.
#  */
# boolean gaul_population_fill (population *pop, int num);

# /**********************************************************************
#   ga_similarity.h
#  **********************************************************************/

# /**********************************************************************
#   ga_core.c


#   Synopsis:     Routines for handling populations and performing GA
# 		operations.
  
# 		Also contains a number of helper functions providing
# 		alternative optimisation schemes for comparison and
# 		analysis purposes.

# 		BEWARE: MANY FUNCTIONS ARE NOT THREAD-SAFE!

# 		Internally, and in the public C interface, pointers
# 		are used to identify the population and entity
# 		structures.  However, in the scripting interface these
# 		pointers are unusable, so identifing integers are
# 		used instead.

#   Vague usage details:	Set-up with ga_genesis_XXX(), where XXX is a built-in chromosome type().
# 			Perform calculations with ga_evolution().
# 			Grab data for post-analysis with ga_transcend().
# 			Evolution will continue if ga_evolution() is
# 			called again without calling ga_genesis_XXX() again.

#   To do:	Replace the send_mask int array with a bit vector.
# 		All functions here should be based on entity/population _pointers_ while 
#                 the functions in ga_intrinsics should be based on _handles_.
# 		More "if ( !pop ) die("Null pointer to population structure passed.");" 
#                 checks are needed.
# 		Population/entity iterator functions.
# 		ga_get_struct_whatever() should be renamed to ga_struct_get_whatever().

#  **********************************************************************/


set ::is_print   0

set ::__is_print 0 ;# false


# //------------------------------------------------------------------------------
proc print_entit  {entity name} {

  puts -nonewline "  "

  ent_print_ch_ $entity $name

  puts ""

}
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#   synopsis:	Fills a population structure with genes.  Defined in
# 		a user-specified function.
#   parameters:	population *	The entity's population.
# 		entity *	The entity.
#   return:	boolean success.
#-------------------------------------------------------------------------------
proc ga_entity_seed {pop adam} \
{

  return [[GET $pop seed]  $pop $adam]
}
#-------------------------------------------------------------------------------
#   synopsis:	Fills all entities in a population structure with
# 		genes from a user-specified function.
#   parameters:	population *pop
# 		int num			Number of entities to seed.
#   return:	boolean success.
#
# boolean 
# gaul_population_fill (population *pop, int num)
#-------------------------------------------------------------------------------
proc  gaul_population_fill {pop num} {

  # ------------------------
  #
  #if {$::__JIM__} {
  #set ::is_print 3
  #}
  #
  # ------------------------

  set proc_seed [GET $pop seed]

  if {$::is_print >= 3} {
    puts ""
    puts "   gaul_population_fill ........... num = $num pop = $pop proc_seed = $proc_seed"
    puts ""
  }

  #----------------------------------------------------------

  for {set i 0} {$i < $num} {incr i} {

    set adam [ga_entity_setup $pop] ;# 

    # заполняем структуру элемента
    #  
    $proc_seed  $pop $adam

    if {$::is_print >= 3} {

      # проконтролируем печатью
      # 
      puts -nonewline [format "   i = %3d   " $i]
      ent_print_ch_     $adam "ch=   "
      puts ""
    }
    
    # -------------------------------------------
    # вообще-то теперь надо добавить в популяцию: 
    # 

    #puts stderr "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~  1111 "
    pop_add_entity_ $pop  $adam
    #puts stderr "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~  2222 "
    
  }
  #----------------------------------------------------------

  if {$::is_print >= 2} {
    #puts "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
    puts ""
  }

  return 1 ;# true
}
# //------------------------------------------------------------------------------
# //  synopsis:	Fitness evaluations.
# //		Evaluate all previously unevaluated entities.
# //		No adaptation.
# //  parameters:	population *pop
# //  return:	none
# //------------------------------------------------------------------------------
proc pop_check_all_eval {pop task} \
{

  set eval_proc [GET $task "fitness_proc"]

  
  for {set i 0} {$i < [get_pop_size $pop]} {incr i} {

    set entity [pop_get_entity_ $pop  $i]


    if {[string equal [item_get_fitn  $entity]  $::GA_MIN_FITNESS]} {

      set ret [pop_eval_item  $pop $entity $eval_proc $task] 

      if {$ret == 0} {
        puts "ERROR ............. !!!!!!!!!!!!!!!!!!!!!!"
        exit ;# пока сделаем просто ошибку..
      }
    }
  }

  return
}
# //------------------------------------------------------------------------------
proc pop_initial_score_and_sort {pop task} {


  set size        [get_pop_size $pop]
  set stable_size [GET $pop stable_size]

  # если реальный размер популяции меньше заявленного, т.е. еще не все (или вообще
  # никто) агенты инициированны

  if {$size < $stable_size} {
    
    gaul_population_fill $pop [expr {$stable_size - $size}]
  }
  
  pop_check_all_eval  $pop $task;# если какие-то недосчитаны, то посчитать фитнес

  sort_population     $pop
  
  return
}
#-------------------------------------------------------------------------------
#   synopsis:	Fills all entities in a population structure with
# 		genes from a user-specified function.
#   parameters:	population
#   return:	boolean success.
#
# т.е. делает фил для всего размера популяции

# boolean 
# ga_population_seed (population *pop)
#-------------------------------------------------------------------------------
proc ga_population_seed {pop} {

  
  if {$::is_print} {
    puts "ga_population_seed  ......... \n"
  }

  # plog(LOG_DEBUG, "Population seeding by user-defined genesis.");

  return [gaul_population_fill  $pop [GET $pop stable_size]]
}
# //----------------------------------------------------------------------------

set ::eval_count 0 ;# Number of fitness evaluations performed

# ------------------------------------------------------------------------------
proc pop_eval_item {pop item eval_proc  task} \
{

  #!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

  set ret  [$eval_proc  $item $task]

  ga_entity_set_fitness $item $ret

  #!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
 
 
  if {$ret == 0} {
    puts "ERROR ............. !!!!!!!!!!!!!!!!!!!!!!"
    exit ;# пока сделаем просто ошибку..
  }

  incr ::eval_count

  return $ret
}
#-------------------------------------------------------------------------------
#   synopsis:	Score and sort entire population.  This is probably
# 		a good idea after changing the fitness function!
# 		Note: remember to define the callback functions first.
#-------------------------------------------------------------------------------
proc ga_population_score_and_sort {pop task} \
{

  set eval_proc [GET $task "fitness_proc"]

  
  set size [get_pop_size $pop]

  for {set i 0} {$i < $size} {incr i} \
  {
    set e [pop_get_entity_ $pop  $i]

    pop_eval_item $pop $e $eval_proc $task
  }
  
  # а теперь сортируем !!! !!! !!! !!!
  # 

  sort_population  $pop
  
  return $::true
}
#-------------------------------------------------------------------------------
proc pop_get_entity_id {pop e} \
{

  set id 0 

  while {$id < [get_pop_size $pop]} \
  {
    set e_tmp [pop_get_entity_ $pop $id]

    if {$e_tmp == $e} {return $id} 

    incr id
  }

  return -1
}
#-------------------------------------------------------------------------------
proc ga_get_entity_from_rank {pop rank} {

  return [pop_get_entity_ $pop  $rank]
}
#-------------------------------------------------------------------------------
proc pop_del_entity {pop dying} \
{

  set id [pop_get_entity_id  $pop $dying]

  return [pop_del_entity_by_id   $pop $id]

}
#-------------------------------------------------------------------------------
proc ga_entity_blank {p this_entity} {


  item_set_fitn  $this_entity "$::GA_MIN_FITNESS"

  return
}
#-------------------------------------------------------------------------------
#   synopsis:	Prepares a pre-allocated entity structure for use.
# 		Chromosomes are allocated, but will contain garbage.
#
# static boolean 
# ga_entity_setup (population *pop, entity *joe)
#
#-------------------------------------------------------------------------------
proc ga_entity_setup {pop} {


  set joe [ent_create_ [GET $pop len_chromosomes]]


  SET $joe ch_form [GET $pop ch_form]

  item_set_fitn $joe $::GA_MIN_FITNESS

  return $joe

}
#-------------------------------------------------------------------------------
proc ga_get_free_entity {pop} {

  # здесь надо бы наоборот, сначала создать структуру, а потом записать в массив:
  # 
  set fresh [ga_entity_setup $pop]

  pop_add_entity_ $pop $fresh


  return $fresh
}
#-------------------------------------------------------------------------------
proc pop_del_entity_by_id {p id} {


  set tmp [GET $p itemslist] 

  set new_iarray [lreplace $tmp $id $id] ;# удалили элемент списка  

  SET $p itemslist $new_iarray
  
  return
}
# ------------------------------------------------------------------------------
proc get_free_and_init {pop task} {

  set adam [ga_get_free_entity  $pop] 

  ga_entity_seed    $pop $adam


#   set evalproc [GET $pop evaluate]
#   $evalproc  $pop $adam 

  set eval_proc [GET $task "fitness_proc"]

  pop_eval_item $pop $adam $eval_proc $task

  return $adam
}
#-------------------------------------------------------------------------------
proc ga_entity_copy {pop dest src} {

  # у нас тут все просто:
  # 
  ent_set_chromosome_ $dest [ent_get_chromosome_ $src]  

  item_set_fitn $dest [item_get_fitn $src]

  return $::true;
}
#-------------------------------------------------------------------------------
proc ga_entity_clone_ {dolly parent} {

  ent_set_chromosome_ $dolly [ent_get_chromosome_ $parent]

  item_set_fitn $dolly [item_get_fitn $parent]

  return $dolly
}
#-------------------------------------------------------------------------------
proc ga_entity_clone {pop parent} {


  set dolly [ga_get_free_entity $pop]

  set dolly [ga_entity_clone_ $dolly $parent]

  return $dolly
}
#-------------------------------------------------------------------------------
proc ga_entity_clone_without_add {pop parent} {


  set dolly [ga_entity_setup $pop] ;# сразу эту вызовем 

  set dolly [ga_entity_clone_ $dolly $parent]

  return $dolly
}
#-------------------------------------------------------------------------------
#   GA functions.
#
#   synopsis:	Sets the GA parameters for a population.

#-------------------------------------------------------------------------------
proc ga_population_set_parameters { pop  scheme elitism 
                                    crossover 
                                    mutation  
                                    migration} {  
  if {$::is_print} {
    puts "ga_population_set_parameters ... "
    puts ""
  }
  
  SET $pop  scheme           $scheme
  SET $pop  elitism          $elitism

  SET $pop  crossover_ratio  $crossover
  SET $pop  mutation_ratio   $mutation
  SET $pop  migration_ratio  $migration

  return
}
#-------------------------------------------------------------------------------
#   synopsis:	Sets the evolutionary class for a population.
#-------------------------------------------------------------------------------
proc ga_population_set_scheme {pop scheme} \
{

  SET $pop scheme $scheme

  return
}
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
proc pop_to_size {p size} {


  set tmp [GET $p "itemslist"]

  set aleft   [lrange $tmp 0 [expr {$size-1}]]

  SET $p "itemslist" $aleft ;# взяли первые $orig_size
  
  return
}
#-------------------------------------------------------------------------------
#   synopsis:	Kill entities to reduce population size down to
# 		specified value.
#-------------------------------------------------------------------------------
proc ga_genocide {pop target_size} \
{

  pop_to_size  $pop $target_size

  return $::true
}
#-------------------------------------------------------------------------------

#   synopsis:	Kill entities with fitness equal to or worse than
# 		specified value.

#-------------------------------------------------------------------------------
# boolean 
# ga_genocide_by_fitness (population *pop, double target_fitness)

#-------------------------------------------------------------------------------
proc ga_genocide_by_fitness {pop target_fitness}  {


  #while {[expr $flag1 && $flag2]} {}
  
  while {1} {
  
    set size [get_pop_size $pop]

    if {0} {
      puts ""
      puts "ga_genocide_by_fitness: size = $size"
      puts ""
      exit
    }


    set size_1 [expr {$size - 1}]

    set fitn_1 [pop_get_entity_fitness_ $pop  $size_1]
    
    set flag1 [expr {$size   > 0}]
    set flag2 [expr {$fitn_1 < $target_fitness}] 

    if {! [expr {$flag1 && $flag2}]} {break}

    puts ""
    puts "ga_genocide_by_fitness: !!!!!!"
    puts ""

    set size [get_pop_size $pop]

    set id [expr {$size - 1}]

    pop_del_entity_by_id   $pop $id
     
  }
  
  return $::true
}
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
#   synopsis:	Gets an entity's fitness.
#
# boolean 
# ga_entity_set_fitness (entity *e, double fitness)
# ------------------------------------------------------------------------------
proc ga_entity_set_fitness {e fitness} {

  #   if ( !e ) return FALSE;

  #   e->fitness=fitness;

  #ent_set_fitness $e $fitness

  item_set_fitn $e $fitness

  return $::true;
}
# ------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#   synopsis:	Compares two entities and returns their relative
# 		ranking.
#   parameters:	population *alphapop	Population A
# 		entity *alpha		Test entity A.
# 		population *betapop 	Population B
# 		entity *beta		Test entity B.
#   return:	Relative rank.
#-------------------------------------------------------------------------------
# int 
# ga_rank_fitness (population *alphapop, entity *alpha,
#                  population *betapop, entity *beta)
#-------------------------------------------------------------------------------
proc check_fitness {message fit} {

  if {[string equal $fit "$::GA_MIN_FITNESS"]} {
    puts ""
    puts "check_fitness ERROR: $message = $fit"
    puts ""

    exit 
  }

}
#-------------------------------------------------------------------------------
proc ga_rank_fitness {alphapop alpha  betapop beta} {

  #   /* Checks */
  #   if (!alphapop || !betapop) die("Null pointer to population structure passed");
  #   if (!alpha || !beta) die("Null pointer to entity structure passed");
  
  #set afit [ent_get_fitness $alpha]
  #set bfit [ent_get_fitness $beta]

  set afit [item_get_fitn $alpha]
  set bfit [item_get_fitn $beta]

  check_fitness  "ga_rank_fitness, afit" $afit
  check_fitness  "ga_rank_fitness, bfit" $bfit

  return [expr {($afit - $bfit) > 0.0}]
}
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#   synopsis:     Determine mean and standard deviation of the fitness
#                 scores.
#   parameters:	population *pop		The population to evaluate.
#   		double *mean		Returns the mean fitness.
# 		double *stddev		Returns the standard deviation of the fitnesses.
#   return:	TRUE on success.
#-------------------------------------------------------------------------------
# boolean 
# ga_fitness_mean_stddev (population *pop,
#                         double *mean, double *stddev)
#-------------------------------------------------------------------------------
proc ga_fitness_mean_stddev {pop &p_mean &p_stddev} \
{

  USE_REFS

  #   int           i;                      /* Loop over all entities. */
  #   double        sum=0.0, sumsq=0.0;     /* Sum and sum squared. */
  #   double	deviation;		/* Distance to mean. */
  
  set sum   0.0
  set sumsq 0.0

  #   if (!pop) die("Null pointer to population structure passed.");
  #   if (pop->size < 1) die("Pointer to empty population structure passed.");
  #   if (!stddev || !mean) die("Null pointer to double passed.");
  
  set size [get_pop_size $pop]

  for {set i 0} {$i < $size} {incr i} \
  {
    #sum += pop->entity_iarray[i]->fitness;

    #set fi  [$pop get_entity_fitness $i]
    set fi  [pop_get_entity_fitness_ $pop  $i]
    set sum [expr {$sum + $fi}]
  }
  
  #   *mean = sum / pop->size;
  set mean [expr {$sum / $size}]
  
  for {set i 0} {$i < $size} {incr i} \
  {
    #     deviation = pop->entity_iarray[i]->fitness - *mean;
    #     sumsq += deviation * deviation;
    
    #set fi  [$pop get_entity_fitness $i]
    set fi  [pop_get_entity_fitness_ $pop  $i]
    set deviation  [expr {$fi - $mean}]

    set sumsq [expr {$sumsq + ($deviation * $deviation)}]
  }
  
  #   *stddev = sqrt (sumsq/pop->size);

  set p_mean   $mean
  set p_stddev [expr {sqrt ($sumsq / $size)}]

  return $::true
}
#-------------------------------------------------------------------------------
# //******************************************************************************







# /*******************************************************************************
#   synopsis:	Allocate the chromosomes for an entity.  Initial
# 		contents are garbage (there is no need to zero them).
#-------------------------------------------------------------------------------
# FUNC boolean ga_chromosome_double_allocate(population *pop, entity *embryo)
#-------------------------------------------------------------------------------
proc ga_chromosome_double_allocate {pop embryo} {

  #     //int		i;		/* Loop variable over all chromosomes */
  
  #   if (!pop) die("Null pointer to population structure passed.");
  #   if (!embryo) die("Null pointer to entity structure passed.");

  #   if (embryo->chromosome!=NULL)
  #     die("This entity already contains chromosomes.");
  
  #   if ( !(embryo->chromosome = s_malloc (/* pop->num_chromosomes* */sizeof(double *))) )
  #     die("Unable to allocate memory");
  
  #   if ( !(embryo->CH = s_malloc(/* pop->num_chromosomes* */pop->len_chromosomes*sizeof(double))) )
  #     die("Unable to allocate memory");
  
  puts "len_chromosomes = [GET $pop len_chromosomes]"


  # /*   for (i=1; i<pop->num_chromosomes; i++) */
  # /*     { */
  # /*     embryo->chromosome[i] = &(((double *)embryo->chromosome[i-1])[pop->len_chromosomes]); */
  # /*     } */

  return $::true;
}
# //******************************************************************************








# /**********************************************************************
#   ga_seed.c

#   Synopsis:     Routines for performing GA seeding operations.

# 		Seeding operations generate genetic data by some
# 		non-evolutionary means.  Typically, this is often
# 		just random generation.

#------------------------------------------------------------------------------
# //------------------------------------------------------------------------------
# char
# get_random_wordchar ()

# ------------------------------------------------------------------------------
proc get_random_wordchar {} {

  #   char ch;  
  #   int randmax = '~' - ' ';
  
  set char_min [scan " " "%c"]
  set char_max [scan "~" "%c"] 
  
  set randmax [expr {$char_max - $char_min}]

  #   char_num = random_int (randmax) + ' ';
  set char_num [expr {[random_int $randmax] + $char_min}]
  
  #   ch = (char) char_num;
  #return (ch);

  # может лучше число просто возвращать? и формировать не строку, а список целых?
  return $char_num
}
# ------------------------------------------------------------------------------
# boolean 
# ga_seed_printable_random (population *pop, entity *adam)

# ------------------------------------------------------------------------------
proc ga_seed_printable_random {pop adam}  {

  #   //int		chromo;		/* Index of chromosome to seed */
  #   int		point;		/* Index of allele to seed */
  
  #   char ch;
  
  #   /* Checks. */
  #   if (!pop)  die ("Null pointer to population structure passed.");
  #   if (!adam) die ("Null pointer to entity structure passed.");
  
  #   /* Seeding. */
  #   //chromo=0;
  #   //for (chromo=0; chromo<pop->num_chromosomes; chromo++)
  #   //{


  #puts "ga_seed_printable_random : "
  #puts ""
  #$adam print
  #puts ""

  for {set point 0} {$point < [GET $pop len_chromosomes]} {incr point}  \
  {
    # ch = get_random_wordchar (); 
    set ch [get_random_wordchar]

    # ((char *)adam->CH)[point] = ch ;

    #$adam set_chromo_gen $point $ch
    ent_set_chromo_gen_ $adam $point $ch
  }

  #   //}

  return $::true
}
# //------------------------------------------------------------------------------
# //******************************************************************************








# //------------------------------------------------------------------------------

#   ga_compare.c

#   Synopsis:     Routines for comparing entities.

# 		These routines return a distance between two entities.

# //------------------------------------------------------------------------------
# /**********************************************************************
#   synopsis:	Compares two char-array genomes and returns their
# 		hamming distance.
#   parameters:	population *pop	Population of entities (you may use
# 			differing populations if they are "compatible")
# 		entity *alpha	Test entity.
# 		entity *beta	Test entity.
#   return:	Returns Hamming distance between two entities' genomes.
#  **********************************************************************/
# //------------------------------------------------------------------------------
# double 
# ga_compare_char_hamming (population *pop, entity *alpha, entity *beta)
# //------------------------------------------------------------------------------
proc ga_compare_char_hamming {pop alpha beta} \
{

  #   int	 /* i, */j;	/* Loop variable over all chromosomes, alleles. */
  #   char	 *a, *b;	/* Pointers to chromosomes. */  
  #   int	 dist = 0;	/* Genomic distance.        */
  set  dist 0

  #   int    aj, bj;
  
  #   /* Checks */
  #   if (!alpha || !beta) die ("Null pointer to entity structure passed");
  
  #   //i = 0;
  #   //for (i=0; i<pop->num_chromosomes; i++)
  #   //{
  
  #   a = (char *) (alpha->CH);
  #   b = (char *) ( beta->CH);
  set a [ent_get_chromosome_ $alpha]
  set b [ent_get_chromosome_ $beta]
  
  for {set j 0} {$j < [GET $pop len_chromosomes]} {incr j} \
  {
    #     aj = (int) a[j];
    #     bj = (int) b[j];
    set aj [lindex $a $j]
    set bj [lindex $b $j]
    
    #     //dist += abs ((int) a[j] - b[j]);
    #     dist += abs (aj - bj);

    set dist [expr {$dist + abs ($aj - $bj)}]
  }

  #   //}

  return $dist
}
# //------------------------------------------------------------------------------
# //******************************************************************************
# //------------------------------------------------------------------------------








# /**********************************************************************
#   ga_select.c

#   Synopsis:     Routines for performing GA selection operations.

# 		This selection routines return TRUE if the selection
# 		procedure has run to completion, otherwise they return
# 		FALSE.  They may potentially return NULL for the
# 		selected entities.  This is valid behaviour and doesn't
# 		necessarily indicate that the selection producedure is
# 		complete.

# 		On the first call to these routines in a given
# 		generation, pop->select_state is guaranteed to be set
# 		to zero.  These routines are then free to modify this
# 		value, for example, to store the number of selections
# 		performed in this generation.

# 		The ga_select_one_xxx() functions are intended for
# 		asexual selections.
# 		The ga_select_two_xxx() functions are intended for
# 		sexual selections.  Checking whether the mother and
# 		father are different entities is optional.

# 		The calling code is welcome to not use any of these
# 		functions.

# 		These functions return a pointer to the entity instead
# 		of an id because, potentially, the entities may come
# 		from a different population.

# 		It may be important to use the value held in the
# 		pop->orig_size field instead of the pop->size field
# 		because the population size is liable to increase
# 		between calls to these functions!  (Although, of course,
# 		you are free to use whichever value you like in
# 		user-defined functions.)

#  **********************************************************************/

#-------------------------------------------------------------------------------
#   synopsis:	Determine sum of entity fitnesses.
#   parameters:	population *pop
#   return:	double sum
#-------------------------------------------------------------------------------
# double 
# gaul_select_sum_fitness (population *pop)
#-------------------------------------------------------------------------------
proc gaul_select_sum_fitness {pop}  {

  #   int           i;		/* Loop over all entities. */
  #   double        sum=0.0;	/* Sum and sum squared. */
  
  set sum 0

  #for {set i 0} {$i < [GET $pop orig_size]} {incr i} 

  for {set i 0} {$i < [GET $pop stable_size]} {incr i} \
  {
    # sum += pop->entity_iarray[i]->fitness;
    #set f [$pop get_entity_fitness $i]
    set f [pop_get_entity_fitness_ $pop  $i]

    set sum [expr {$sum + $f}]
  }

  return $sum
}
#-------------------------------------------------------------------------------
#   synopsis:	Select a single entity by my rank-based method.
#
#-------------------------------------------------------------------------------
proc ga_select_one_randomrank {pop &mother} {

  USE_REFS

  #   if (!pop) die("Null pointer to population structure passed.");
  
  #   pop->select_state++;
  SET $pop select_state [expr {[GET $pop select_state] + 1}]
  
  #   *mother = NULL;
  
  #set orig_size    [GET $pop orig_size]
  set orig_size    [GET $pop stable_size]
  set select_state [GET $pop select_state]

  if {$orig_size < $select_state} \
  {
    return $::true
  }
  
  if {[random_boolean_prob [GET $pop mutation_ratio]]} \
  {
     # *mother = pop->entity_iarray[random_int(pop->select_state)];
    #set mother [$pop get_entity [random_int $select_state]]
    set mother [pop_get_entity_ $pop [random_int $select_state]]

    return 0 ;# false
  } else {
    return 1 ;# true
  }
  
  #return false
}
#-------------------------------------------------------------------------------
#   synopsis:	Select a pair of entities by my rank-based method.
# 		Basically, I loop through all entities, and each is
# 		paired with a random, fitter, partner.

# boolean 
# ga_select_two_randomrank (population *pop, entity **mother, entity **father)

#-------------------------------------------------------------------------------
proc ga_select_two_randomrank {pop &mother &father} {

  USE_REFS

  #   if (!pop) die("Null pointer to population structure passed.");
  
  #   pop->select_state++;
  SET $pop select_state [expr {[GET $pop select_state] + 1}]
  
  #set mother "NULL"
  #set father "NULL"
  
  #set orig_size    [GET $pop orig_size]
  set orig_size    [GET $pop stable_size]
  set select_state [GET $pop select_state]

  if {$::is_print} {
    puts "ga_select_two_randomrank: "
    puts "orig_size = $orig_size   select_state = $select_state"
  }

  if {$orig_size < $select_state} \
  {
    #puts "!!!!!!!!!!!!!????????????"
    return $::true
  }

  #   if ( random_boolean_prob (pop->crossover_ratio) )
  #   {
  #     *mother = pop->entity_iarray[random_int(pop->select_state)];
  #     *father = pop->entity_iarray[pop->select_state];
  #   }
  
  if {[random_boolean_prob [GET $pop crossover_ratio]]} \
  {
    #set mother [$pop get_entity [random_int $select_state]]
    #set father [$pop get_entity             $select_state]

    set mother [pop_get_entity_ $pop  [random_int $select_state]]
    set father [pop_get_entity_ $pop              $select_state]

    return 0 ;# false
  } else {
    return 1 ;# true
  }
  
  #return false
}
#-------------------------------------------------------------------------------
#   synopsis:	Kind of tournament selection.  Choose two random
# 		entities, return the best as the selection.  Selection
# 		stops when
# 		(population size)*(mutation ratio)=(number selected)

# boolean 
# ga_select_one_bestof2 (population *pop, entity **mother)

#-------------------------------------------------------------------------------
proc ga_select_one_bestof2 {pop &mother} {

  USE_REFS
  #   entity	*mother2;	/* Random competitor. */
  
  #   if (!pop) die ("Null pointer to population structure passed.");
  
  #   if (pop->orig_size < 1)
  #   {
  #     *mother = NULL;
  #     return TRUE;
  #   }
  
  #set orig_size [GET $pop orig_size]
  set orig_size [GET $pop stable_size]

  #   *mother = pop->entity_iarray[random_int(pop->orig_size)];
  #   mother2 = pop->entity_iarray[random_int(pop->orig_size)];

  #set mother1 [$pop get_entity [random_int $orig_size]]
  #set mother2 [$pop get_entity [random_int $orig_size]]
  
  set mother1 [pop_get_entity_ $pop  [random_int $orig_size]]
  set mother2 [pop_get_entity_ $pop  [random_int $orig_size]]
  
  #   if (mother2->fitness > (*mother)->fitness)
  #     *mother = mother2;
  
  #set fit1 [ent_get_fitness $mother1]
  #set fit2 [ent_get_fitness $mother2]

  set fit1 [item_get_fitn $mother1]
  set fit2 [item_get_fitn $mother2]

  if {$fit1 > $fit2} {

    set mother $mother1
  } else {
    set mother $mother2
  }

  #   pop->select_state++;
  SET $pop select_state [expr {[GET $pop select_state] + 1}]

  set ret [expr {[GET $pop select_state] > ($orig_size * [GET $pop mutation_ratio])} ]

  #   return pop->select_state>(pop->orig_size*pop->mutation_ratio);
  return $ret
}
#-------------------------------------------------------------------------------
#   synopsis:	Kind of tournament selection.  For each parent, choose
# 		two random entities, return the best as the selection.
# 		The two parents will be different.  Selection
# 		stops when
# 		(population size)*(crossover ratio)=(number selected)

# boolean 
# ga_select_two_bestof2 (population *pop, entity **mother, entity **father)

#-------------------------------------------------------------------------------
proc ga_select_two_bestof2 {pop &mother &father} {

  USE_REFS

  #   entity	*challenger;	/* Random competitor. */
  
  #   if (!pop) die("Null pointer to population structure passed.");
  
  #   if (pop->orig_size < 2)
  #   {
  #     *mother = NULL;
  #     *father = NULL;
  #     return TRUE;
  #   }
  
  #set orig_size [GET $pop orig_size]
  set orig_size [GET $pop stable_size]
  set c_ratio   [GET $pop crossover_ratio] 

  set moth_i [random_int $orig_size]
  #set mother [$pop get_entity $moth_i]
  set mother [pop_get_entity_ $pop  $moth_i]

  #set moth_fitness [ent_get_fitness $mother]
  set moth_fitness [item_get_fitn $mother]

  set chal_i [random_int $orig_size]
  #set challenger [$pop get_entity $chal_i]
  set challenger [pop_get_entity_ $pop  $chal_i]

  #set chal_fitness [ent_get_fitness $challenger]
  set chal_fitness [item_get_fitn $challenger]
  

  if {$chal_fitness > $moth_fitness} {
    #puts "  chal_fitness > moth_fitness"
    set mother $challenger
    set moth_i $chal_i ;# // сделаем это по факту !?
  }

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  while {1} {
    set fath_i [random_int $orig_size]
    if {$moth_i != $fath_i}  {break}
  }

  #set father  [$pop get_entity $fath_i]
  set father  [pop_get_entity_ $pop  $fath_i]

  #set fath_fitness  [ent_get_fitness $father]
  set fath_fitness  [item_get_fitn $father]
  

  set chal_i [random_int $orig_size]
  #set challenger   [$pop get_entity $chal_i];
  set challenger   [pop_get_entity_ $pop  $chal_i];

  #set chal_fitness [ent_get_fitness $challenger]
  set chal_fitness [item_get_fitn $challenger]
 
  #puts "  moth_i= $moth_i  fath_i= $fath_i  chth_i= $chal_i  chal_fitness= $chal_fitness  fath_fitness= $fath_fitness"

  if {$chal_i != $moth_i  &&  $chal_fitness > $fath_fitness} {
    #puts "  ....."
    set father $challenger
    set fath_i $chal_i ;# // сделаем это по факту !?
  }
  
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  if {$::is_print > 2.2} {
  #if {$::is_print} {}
    puts "  ga_select_two_bestof2 :"
    print_entit  $mother "mother = ($moth_i) ="
    print_entit  $father "father = ($fath_i) ="
  }
  

  #   pop->select_state++;
  #
  set  s_state [GET $pop select_state]
  incr s_state
  SET $pop select_state $s_state

  # истина, если закончился перебор (селекция пар) ?
  # 
  set ret [expr {$s_state > 1.0 * $orig_size * $c_ratio} ]
  
  if {$::is_print > 2.2} {
  #if {$::is_print} {}
    puts "  s_state= $s_state  orig_size= $orig_size  c_ratio= $c_ratio   ret = $ret" 
    puts ""
  }

  #   return pop->select_state>(pop->orig_size*pop->crossover_ratio);
  return $ret
}
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
# 
# Systematic search parameter structure.
# 

# typedef struct
# {
#   GAscan_chromosome	scan_chromosome;	/* Allele searching function. */
#   int			chromosome_state;	/* Permutation counter. */
#   int			allele_state;		/* Permutation counter. */
# } ga_search_t;

#-------------------------------------------------------------------------------
# 
# Probabilistic sampling parameter structure.
# 

# typedef struct
# {
#   int			**num_states;		/* Number of states for each allele. */
# } ga_sampling_t;

#-------------------------------------------------------------------------------
# 
# Internal state values for built-in selection operators.
# Currently used for roulette wheel and SUS selection routines.
# 
  # А зачем вообще здесь, если они все локально используются? ААА, там
  # цикл и выделяется первый вызов для инициации


# record define GA_SELECTDATA_T {

#   # double	mean, stddev, sum;  /* double : Fitness statistics.            */
#   # double	current_expval;	    /* double : Total of expectancy values.    */
#   # double	minval;		    /* double : Worst fitness value.           */

#   step          ;#-#  /* double : Distance between each pointer. */
#   offset1       ;#-#  /* double : Current pointer offsets.       */
#   offset2       ;#-#
#   #   int	marker;	/* int  : The roulette wheel marker.       */
#   num_to_select ;#-#  /* int  : Number of individuals to select. */
#   current1      ;#-#  /* int  : Currently selected individuals.  */
#   current2 
#   permutation   ;#-#  /* int* : Randomly ordered indices.        */

# } ;# ga_selectdata_t;

#-----------------------
# h_all5.tl _1  11 10 10

#-------------------------------------------------------------------------------
proc dict_generate_setget_one {sd l} {

  SET $sd $l "" ;# по умолчанию создадим все переменные ??

}
#-------------------------------------------------------------------------------
proc dict_generate_setget_all {sd list} {

  foreach l $list {

    #puts stderr "dict_generate_setget_all: l = $l"
    dict_generate_setget_one  $sd $l
  }

  return
}
#-------------------------------------------------------------------------------
proc selectdata_create {} {


  set sd [dict_create]  
  
  dict_generate_setget_all $sd {
    
    step       
    offset1       
    offset2       
    num_to_select 
    current1     
    current2 
    permutation 
  }
  
  return $sd
}
#-------------------------------------------------------------------------------
#   synopsis:	Stochastic Universal Sampling selection.
#   		pop->mutation_ratio multiplied by pop->orig_size gives
# 		the number of selections which will be performed.
# 		This version is for fitness values where 0.0 is bad and
# 		large positive values are good.  Negative values will
# 		severely mess-up the algorithm.

# boolean 
# ga_select_one_sus (population *pop, entity **mother)

#-------------------------------------------------------------------------------
proc ga_select_one_sus {pop &mother}  {

  USE_REFS

  #   double	sum;			/* Fitness total. */
  
  #set orig_size       [GET $pop orig_size]
  set orig_size       [GET $pop stable_size]
  set select_state    [GET $pop select_state]
  set mutation_ratio  [GET $pop mutation_ratio]

  if {$orig_size < 1} \
  {
      return $::true
  }
  
  set sd [GET $pop selectdata]


  if {$select_state == 0} \
  { 
    # First call of this generation.

    #set f  [expr {max (1, int (floor ($orig_size * $mutation_ratio)))}]
    # 
    set f_tmp [* $orig_size $mutation_ratio]
    set f_tmp [expr {int (floor ($f_tmp))}]
    set f [max  1 $f_tmp]


    #set sd [$pop.selectdata]

    SET $sd "num_to_select" $f

    set sum [gaul_select_sum_fitness $pop]

    set selectdata_step [expr {$sum / ($orig_size * $mutation_ratio)}]

    #$pop.step = $selectdata_step
    #
    SET $pop step  $selectdata_step

    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


    SET $sd "offset1" [random_double $selectdata_step]

    SET $sd "current1" 0

  } else {

    set num_to_select  [GET $sd "num_to_select"]

    if {$select_state > $num_to_select} {
      return $::true ;# признак окончания
    }

    set step [GET $pop step]

    SET $sd "offset1" [expr {[GET $sd "offset1"] + $step}]

  }
  

  while {1} \
  {

    set off1 [GET $sd "offset1"]
    set cur1 [GET $sd "current1"]

    set fit1 [pop_get_entity_fitness_ $pop  $cur1]

    if {$off1 <= $fit1} {break}

    SET $sd "offset1"  [expr {$off1 - $fit1}]

    incr cur1

    if {$cur1 >= $orig_size} {
      set cur1 [expr {$cur1 - $orig_size}]
    }   
 

    SET $sd "current1"  $cur1
  }
  

  set cur1 [GET $sd "current1"]

  set mother [pop_get_entity_ $pop  $cur1]

  
  #   pop->select_state++;
  SET $pop select_state [expr {[GET $pop select_state] + 1}]
  
  return 0 ;# false
}
#-------------------------------------------------------------------------------
# /**********************************************************************
#   synopsis:	Stochastic Universal Sampling selection.
#
#   		pop->mutation_ratio multiplied by pop->orig_size gives
# 		the number of selections which will be performed.
#
# 		This version is for fitness values where 0.0 is bad and
# 		large positive values are good.  Negative values will
# 		severely mess-up the algorithm.
#  **********************************************************************/
# boolean 
# ga_select_two_sus (population *pop, entity **mother, entity **father)
#-------------------------------------------------------------------------------
#
#Reference Argument - The caller is expected to pass the name of an existing 
# variable. An implicit 
# upvar 1 origname name 
# is done to make the variable available in the proc scope. 
# 
#-------------------------------------------------------------------------------
# 
proc ga_select_two_sus {pop &mother &father}  {

  if {$::ISREVERSE} {puts stderr ".................................. 005_1_1"}

  USE_REFS

  #   double	sum;			/* Fitness total. */
  #   int	*ordered;		/* Ordered indices. */
  #   int	i;			/* Loop variable over indices. */
  
  set ordered "" ;# &
  set oarray  "" ;# &

  #   if (!pop) die("Null pointer to population structure passed.");  
  #   *mother = NULL;
  
  #set orig_size      [GET $pop orig_size]
  set orig_size       [GET $pop stable_size]
  set select_state    [GET $pop select_state]
  set crossover_ratio [GET $pop crossover_ratio]

  set sd [GET $pop selectdata]

  set num_to_select [GET $sd "num_to_select"]
  
  #puts "select_state  = $select_state"
  #puts "num_to_select = $num_to_select"
  #puts ""

  if {$orig_size < 1} \
  {
      return $::true
  }
  
  if {$::is_print > 1} {
    puts stderr "ga_select_two_sus ........ "
  }

  if {$::ISREVERSE} {puts stderr ".................................. 005_1_2"}

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  if {$select_state == 0} {
 
    if {$::ISREVERSE} {puts stderr ".................................. 005_1_3"}

    if {$::is_print > 1} {puts stderr "1 ... "}

    # First call of this generation

    set f_tmp [* $orig_size $crossover_ratio]
    set f_tmp [expr {int (floor ($f_tmp))}]

    #set f [expr {max (1, int (floor ($orig_size * $crossover_ratio)))}]
    #set f [expr {max (1, int (floor ($f_tmp)))}]
    #set f [expr {max (1, $f_tmp)}]
    set f [max  1 $f_tmp]


    SET $sd "num_to_select"  $f      

    set sum [gaul_select_sum_fitness  $pop]

    set f [expr {$sum / [GET $sd "num_to_select"]} ]

    set selectdata_step $f


    #$pop configure -selectdata_step $selectdata_step
    SET $pop step  $selectdata_step
 
    #puts stderr "selectdata_step = $selectdata_step"
    #exit

    SET $sd "offset1" [random_double  $selectdata_step]
    SET $sd "offset2" [GET $sd "offset1"]

    #puts  stderr [format "sum = %f  step = %f  off1 = %f " $sum $selectdata_step [$pop cget -selectdata_offset1]]

    SET $sd "current1" 0
    SET $sd "current2" 0
    SET $sd "permutation" "" ;# NULL

    for {set i 0} {$i < $orig_size} {incr i} {
      lappend  ordered $i
    }
    #  int    *iarray, // Source array.
    #  int    *oarray  // Destination array.

    #puts stderr "ordered = $ordered"

    #random_int_permutation  $orig_size $ordered oarray ;# перемешали числа
    #
    # вообще-то в оригинале массив "ordered" тоже портится, но здесь незаметно
    # поскольку вызывается один раз
    #

    random_int_permutation  $orig_size  ordered oarray ;# перемешали числа

    
    SET $sd "permutation" $oarray     ;# записаил перемешку


  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  } else {
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    set num_to_select [GET $sd "num_to_select"]


    if {$select_state > $num_to_select} {
      
      if {$::is_print > 1} {puts stderr "2 ... "}
      
      # эта ветка для окончания пеербора (селекции) пар ?
      #     s_free (pop->selectdata.permutation);
      #     pop->selectdata.permutation = NULL;
      

      SET $sd "permutation" ""

      return $::true ;# признак окончания
    }


    if {$::is_print > 1} {puts stderr "3 ... "}

    #set step [$pop cget -selectdata_step]
    set step [GET $pop step]

    SET $sd "offset1" [expr {[GET $sd "offset1"] + $step}]
    SET $sd "offset2" [expr {[GET $sd "offset2"] + $step}]
    
  }
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  
  if {$::ISREVERSE} {puts stderr ".................................. 005_1_5"}

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  while {1} \
  {

    set off1 [GET $sd "offset1"]
    set cur1 [GET $sd "current1"]

    set fit1 [pop_get_entity_fitness_ $pop  $cur1 ]

    if {$off1 <= $fit1} {break}

    #puts "off1 > fit1"
    #exit


    SET $sd "offset1" [expr {$off1 - $fit1}]

    incr cur1

    if {$cur1 >= $orig_size} {
      set cur1 [expr {$cur1 - $orig_size}]
    }
    

    SET $sd "current1" $cur1

  }
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 
  if {$::ISREVERSE} {puts stderr ".................................. 005_1_6"}
  

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  while {1} \
  {

    set off2 [GET $sd "offset2"]
    set cur2 [GET $sd "current2"]
    set perm [GET $sd "permutation"]

    set fit2 [pop_get_entity_fitness_ $pop  [lindex $perm $cur2]]

    #if {$::ISREVERSE} {puts stderr "....... off2 = $off2   fit2 = $fit2"}

    if {$off2 <= $fit2} {break}

    #puts "off2 > fit2"
    #exit

    SET $sd "offset2" [expr {$off2 - $fit2}]

    incr cur2

    if {$cur2 >= $orig_size} {
      set cur2 [expr {$cur2 - $orig_size}]
    }    

    if {$::ISREVERSE} {puts stderr "....... off2 = $off2  fit2 = $fit2  cur2 = $cur2"}

    SET $sd "current2" $cur2

  }
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  
  if {$::ISREVERSE} {puts stderr ".................................. 005_1_7"}

  set cur1 [GET $sd "current1"]
  set cur2 [GET $sd "current2"]
  set perm [GET $sd "permutation"]

  if {$::is_print > 1} {
    puts stderr "cur1 = $cur1"
    puts stderr "cur2 = $cur2"
    puts stderr "perm = $perm"
  }


  set mother [pop_get_entity_ $pop  $cur1]

  set father [pop_get_entity_ $pop  [lindex $perm $cur2]]
  
  SET $pop select_state [expr {$select_state + 1}]

  return 0 ;# false
}
#-------------------------------------------------------------------------------
# //******************************************************************************






#-------------------------------------------------------------------------------
#   ga_qsort.c

#   ga_qsort - GA population sorting routines.

#   Synopsis:	Sort the population by fitness.

# 		These functions aren't intended for public use.

# 		Two versions exist.  (1) The older version uses the
# 		quicksort algorithm, but since it is inefficient for
# 		small arrays we use a shuffle sort to sort blocks of
# 		less than 8 elements.  Unfortunately, platform
# 		precision seems to be critical to the final ordering
# 		with degenerate fitness scores - resulting in different
# 		evolution results on different types of computer, which
# 		is unacceptable.  (2) The newer, low-tech, shuffle
# 		sort which sucks from a 'fanciness' perspective... but
# 		it works.

#-------------------------------------------------------------------------------
proc sort_population {pop} {

  #$pop sort 
  pop_sort_ $pop

}
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#   ga_utility.c

#   ga_utility - High-level genetic algorithm routines.

#   Synopsis:     High-level GA functions and convenience functions.

#   To do:	Population/entity iterator functions.
# 		On-line and off-line performance summaries.

#   synopsis:	High-level function to create a new population and
# 		perform the basic setup (i.e. initial seeding) required
# 		for further optimisation and manipulation.
# 		Assumes the use of integer chromosomes is desired.
# 		Integer-valued chromsomes.
#-------------------------------------------------------------------------------
# population *
# ga_genesis_integer (const int		population_size,
#                       const int		num_chromo,
#                       const int		len_chromo,
#                       GAgeneration_hook	generation_hook,
#                       GAiteration_hook	iteration_hook,
#                       GAdata_destructor	data_destructor,
#                       GAdata_ref_incrementor	data_ref_incrementor,
#                       GAevaluate		evaluate,
#                       GAseed			seed,
#                       GAadapt			adapt,
#                       GAselect_one		select_one,
#                       GAselect_two		select_two,
#                       GAmutate		mutate,
#                       GAcrossover		crossover,
#                       GAreplace		replace,
#                       vpointer		userdata )

#-------------------------------------------------------------------------------
proc task_create {fitness_proc  args} {

  set t [dict_create]

  SET $t "fitness_proc" $fitness_proc

  SET $t "fit_target"   [dict_parse $args "-fit_target" 0] 
  SET $t "fit_error"    [dict_parse $args "-fit_error"  0.01] 

  return $t
}
#-------------------------------------------------------------------------------
proc ga_genesis_main {
			task 
			population_size      
			num_chromo           
			len_chromo           
			generation_hook      
			iteration_hook       
			data_destructor      
			data_ref_incrementor 
			seed                 
			adapt                
			select_one           
			select_two           
			mutate               
			crossover            
			replace              
			userdata             
                      } {

  set pop [GAUL new  \
                "-lpop $population_size -lgen $len_chromo"]

  # /*
  #  * Assign population's user data.
  #  */
  #   pop->data = userdata;
  
  # /*
  #  * Define some callback functions.
  #  */
  SET $pop  generation_hook $generation_hook

  #   pop->iteration_hook = iteration_hook;
  
  #   pop->data_destructor = data_destructor;
  #   pop->data_ref_incrementor = data_ref_incrementor;
  
  #   pop->chromosome_constructor = ga_chromosome_integer_allocate;
  #$pop configure -chromosome_constructor "ga_chromosome_integer_allocate"

  #   pop->chromosome_destructor = ga_chromosome_integer_deallocate;
  #   pop->chromosome_replicate = ga_chromosome_integer_replicate;
  #   pop->chromosome_to_bytes = ga_chromosome_integer_to_bytes;
  #   pop->chromosome_from_bytes = ga_chromosome_integer_from_bytes;
  #   pop->chromosome_to_string = ga_chromosome_integer_to_string;
  
  #-------------------------------------------
  #SET $pop  evaluate $evaluate ;# убрать !!!!!

  #-------------------------------------------
  
  SET $pop  seed     $seed    
  SET $pop  adapt    $adapt

  SET $pop  select_one  $select_one 
  SET $pop  select_two  $select_two 

  SET $pop  mutate    $mutate    ;#
  SET $pop  crossover $crossover ;#
  SET $pop  replace   $replace   ;#
  
  return $pop
}
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------









