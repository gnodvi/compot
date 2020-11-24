# -*-   mode: tcl  ; coding: koi8   -*- ----------------------------------------

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------

#namespace import ::struct::*

#set ::NEWEST 1 ;# !!!!!!!!!!!!!!!!!!! OK !!!!

set ::NEWPOP 0

#-------------------------------------------------------------------------------


set ::GA_BOLTZMANN_FACTOR	1.38066e-23


#set ::sort_driver "MAX_to_LEFT" ;# функция признак-сортировки

set ::ISPRINT 0


# #define GA_TINY_DOUBLE		(1.0e-9)

#-------------------------------------------------------------------------------

# item - это prog через указатель !!

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
proc item_create {len_chromosome} {
    
  set item [dict_create]
  
  # зачем здесь задавать жесткую длину ??
  # 
  set tmp  [make_list $len_chromosome "@"]

  item_set_chromosome $item $tmp
          
  SET $item ch_form    "%s " ;#  " %02d" "% 6.3f " 
 
  return $item
}
#-------------------------------------------------------------------------------
proc item_set_chromosome {item ch} {


  SET $item "main" "src" $ch

}
#-------------------------------------------------------------------------------
proc item_get_chromosome {item} {


  return [GET $item "main" "src"]

}
#-------------------------------------------------------------------------------
proc item_CH {item} {


  return [item_get_chromosome $item]

}
#-------------------------------------------------------------------------------
proc item_set_chromo_gen {item i val} {
  
  set  tmp [item_get_chromosome $item]

  lset tmp $i $val

  item_set_chromosome  $item $tmp

  return
}
#-------------------------------------------------------------------------------
proc item_get_chromo_gen {item i} {

  set  tmp [item_get_chromosome $item]
  
  return [lindex $tmp $i]
}
#-------------------------------------------------------------------------------
proc item_get_chromo_len {item} {

  set  tmp [item_get_chromosome $item]
  
  return [llength $tmp]
}
#-------------------------------------------------------------------------------
proc item_as_string {item ch_form} {

  if {$ch_form == ""} {
    set ch_form [GET $e ch_form] ;# локальная переменная
  }

  set ch  [item_get_chromosome $item]
  
  set buf {}

  foreach c $ch {

    append buf [format $ch_form $c]
  } 
  
  return $buf
}
#-------------------------------------------------------------------------------
proc item_print_ch {item {name "ch=   "} {out "stdout"} {ch_form "%s "}} {


  puts -nonewline $out $name
  
  set buf [item_as_string  $item $ch_form]
  
  puts -nonewline $out $buf

  flush $out  ;# все данные должны быть выведены
}
#-------------------------------------------------------------------------------
proc item_print_oneline {item {out "stdout"} {ch_form "%s "}} {


  set fi [item_get_fitn $item]
  
  if {[string equal $fi $::GA_MIN_FITNESS]} {

    puts -nonewline $out "fitness= NOT_FITNESS"
  } else {
    puts -nonewline $out "fitness= [format "%9.3f"  $fi]"
  }
  
  item_print_ch $item "   ch=  " $out $ch_form
  
  puts $out ""
}
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

  #puts "item_get_fitn: iten = $item"

  return  [dict_get  $item "fitn"]

}
#-------------------------------------------------------------------------------
proc item_get_prog {item} {

  # item - это prog через указатель !!

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
    
    puts -nonewline [format "  step %3d  ...  f0 = $fitn0  " $index]
    item_print_ch     $item0 "i0 =  "
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

  # а может уже посчитано?
  # 
  set fitn  [item_get_fitn  $item_ptr] 

#   if {$fitn != $::GA_MIN_FITNESS} {
#     return
#   }

  set prog [item_get_prog    $item_ptr]
  set src  [prog_get_prg_src $prog "main"] 

  #-------------------------------------
  #puts ""
  #puts "prog = $prog"
  #puts " src =  $src"
  #puts ""
  #-------------------------------------

  #set fitn  [$fitnessfunc  $src $prog] ;# запускаем тест 
  #set fitn  [$fitnessfunc  $src]  
  set fitn  [$fitnessfunc  $src $task]  

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

dict_class_create POP {} {

  ;# _это_перечисление_переменных
  
  stable_size      ""  ;# _требуемый_размер_популяции
  len_chromosomes  ""  ;# _int_:_Maximum_length_of_each_chromosome
  
  ch_form          "%s "  ;# _"%02d"     
  generation_hook  ""  ;# _GAgeneration_hook_generation_hook 

  #sort_driver "" 

  itemslist        ""  ;# _ 
  generation       ""  ;# _ 

  best       "" ;# _для_хранения_лучшего_номера

} {
  # а это конструктор класса 

  #-----------------------------------------------

  SET $obj "stable_size"     [dict_parse $args "-lpop"] 
  SET $obj "len_chromosomes" [dict_parse $args "-lgen"] 
  
  SET $obj "ch_form"         "% 6.3f " ;#  " %02d"   
  SET $obj "generation_hook" NULL
  
  SET $obj generation      {}  
  SET $obj best            {}     
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


dict_class_create GAUL {POP} {

  # это перечисление переменных
  
  max_size  ""  ;# _текущий_максимальный_размер
  size      ""  ;# _актуальный_размер

  #generation "" ;# _номер_текущей_генерации
  #best       "" ;# _для_хранения_лучшего_номера

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

  SET $obj  iteration_hook  NULL
  SET $obj  adapt           NULL
    
  #$newpop.selectdata = [selectdata_create]
  # 
  SET $obj  "selectdata" [selectdata_create]
  
  #[$newpop.selectdata].offset1 = 555
  #puts "offset1 = [[$newpop.selectdata].offset1]"
  
  #   newpop->data = NULL;
  #   newpop->free_index = newpop->max_size-1;
  
  #   newpop->fitness_dimensions = 0;
  #SET $newpop "fitness_dimensions" 0
  
  #   newpop->crossover_ratio = GA_DEFAULT_CROSSOVER_RATIO;
  #   newpop->mutation_ratio = GA_DEFAULT_MUTATION_RATIO;
  #   newpop->migration_ratio = GA_DEFAULT_MIGRATION_RATIO;
  SET $obj  "scheme" GA_SCHEME_DARWIN;
  
  #   newpop->elitism = GA_ELITISM_PARENTS_SURVIVE;  
  #   newpop->allele_mutation_prob = GA_DEFAULT_ALLELE_MUTATION_PROB;
  
  #   newpop->allele_max_integer = RAND_MAX-1;
  SET $obj  "allele_min_integer" 0
  
  SET $obj  "allele_max_integer" [expr {$::RANDOM_RAND_MAX - 1}] ;# попробуем так
  
  SET $obj  "allele_min_double" $::DBL_MIN
  SET $obj  "allele_max_double" $::DBL_MAX
  
  SET $obj  "rank" "ga_rank_fitness"
  
  #---------------------------------------
  
  SET $obj  "island"     -1
  SET $obj  "generation"  0    
  SET $obj  "best"       -1 ;# для хранения лучшего номера (пока нет)  
}

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
  
  set ch_form [GET $p "ch_form"]

  #puts "pop_print_lite_: ch_form = $ch_form"

  foreach e $tmp {
    
    puts -nonewline $out [format "   i = %3d   " $i]
    
    item_print_oneline $e $out $ch_form

    incr i
  }

  return
}
#-------------------------------------------------------------------------------
proc pop_print_ {p {out "stdout"}} {


  puts $out "---------------------- POPULATION PRINT -------------------------------"
  puts $out ""
  puts $out "Generation = [GET $p generation]"
  puts $out ""
  
  pop_print_lite_ $p $out
  
  set best  [GET $p best]
  
  puts $out ""
  puts $out "STABLE_SIZE = [GET $p stable_size] "
  #puts $out "SIZE        = [GET $p size] "
  puts $out "SIZE        = [get_pop_size $p] "
  puts $out "BEST        = $best "
  puts $out ""
  
  if {$best != -1 && $best != ""} {

    set best_fit [pop_get_entity_fitness_ $p  $best]
    
    puts $out [format "BEST = $best  (fitness = %f) " $best_fit]
  }
  
  puts $out " "
  puts $out "-----------------------------------------------------------------------"

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

  item_print_ch $entity $name

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
      item_print_ch     $adam "ch=   "
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
        puts "ERROR ............. !!!!!!!!!!!!!!!!!!!! 111"
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

  pop_sorting  $pop [make_sortdriver_fromtask $task]
  
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

  item_set_fitn $item $ret

  #!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  # а если 0 - это наша цель ??

  #if {$ret == 0} {
  #  puts "ERROR ............. !!!!!!!!!!!!!!!!!!!! 22"
  #  exit ;# пока сделаем просто ошибку..
  #}

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

  pop_sorting  $pop [make_sortdriver_fromtask $task]
  
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


  set joe [item_create [GET $pop len_chromosomes]]


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
  item_set_chromosome $dest [item_get_chromosome $src]  

  item_set_fitn $dest [item_get_fitn $src]

  return $::true;
}
#-------------------------------------------------------------------------------
proc ga_entity_clone_ {dolly parent} {

  item_set_chromosome $dolly [item_get_chromosome $parent]

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
# proc ga_entity_set_fitness {e fitness} {


#   item_set_fitn $e $fitness

#   return $::true;
# }
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

  #   double        sum=0.0, sumsq=0.0;     /* Sum and sum squared. */
  #   double	deviation;		/* Distance to mean. */
  
  set sum   0.0
  set sumsq 0.0

  set size [get_pop_size $pop]

  for {set i 0} {$i < $size} {incr i} \
  {
    set fi  [pop_get_entity_fitness_ $pop  $i]
    set sum [expr {$sum + $fi}]
  }
  
  set mean [expr {$sum / $size}]
  
  for {set i 0} {$i < $size} {incr i} \
  {
    
    set fi  [pop_get_entity_fitness_ $pop  $i]
    set deviation  [expr {$fi - $mean}]

    set sumsq [expr {$sumsq + ($deviation * $deviation)}]
  }
  
  #   *stddev = sqrt (sumsq/pop->size); ???? return ??

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
# ------------------------------------------------------------------------------
# proc get_random_wordchar {char_min char_max} {

  
#   set randmax [expr {$char_max - $char_min}]

#   set char_num [expr {[random_int $randmax] + $char_min}]
  
#   # может лучше число просто возвращать? и формировать не строку, а список целых?
#   return $char_num
# }
# ------------------------------------------------------------------------------
# proc ga_seed_printable_random {pop adam} {


#   SET $pop  allele_min [scan " " "%c"] 
#   SET $pop  allele_max [scan "~" "%c"]

#   set char_min [GET $pop allele_min]
#   set char_max [GET $pop allele_max]


#   for {set point 0} {$point < [GET $pop len_chromosomes]} {incr point}  \
#   {
#     set ch [get_random_wordchar $char_min $char_max]

#     item_set_chromo_gen $adam $point $ch
#   }


#   return $::true
# }
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

  set a [item_get_chromosome $alpha]
  set b [item_get_chromosome $beta]
  
  for {set j 0} {$j < [GET $pop len_chromosomes]} {incr j} \
  {
    set aj [lindex $a $j]
    set bj [lindex $b $j]
    
    set dist [expr {$dist + abs ($aj - $bj)}]
  }

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

  set fath_fitness  [item_get_fitn $father]
  

  set chal_i [random_int $orig_size]
  set challenger   [pop_get_entity_ $pop  $chal_i];

  set chal_fitness [item_get_fitn $challenger]
 
  #puts "  moth_i= $moth_i  fath_i= $fath_i  chth_i= $chal_i  chal_fitness= $chal_fitness  fath_fitness= $fath_fitness"

  if {$chal_i != $moth_i  &&  $chal_fitness > $fath_fitness} {
    #puts "  ....."
    set father $challenger
    set fath_i $chal_i ;# // сделаем это по факту !?
  }
  
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  if {$::is_print > 2} {
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
  
  if {$::is_print > 2} {
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

  if {$::ISPRINT} {puts stderr ".................................. 005_1_1"}

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

  if {$::ISPRINT} {puts stderr ".................................. 005_1_2"}

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  if {$select_state == 0} {
 
    if {$::ISPRINT} {puts stderr ".................................. 005_1_3"}

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
  
  if {$::ISPRINT} {puts stderr ".................................. 005_1_5"}

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
 
  if {$::ISPRINT} {puts stderr ".................................. 005_1_6"}
  

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  while {1} \
  {

    set off2 [GET $sd "offset2"]
    set cur2 [GET $sd "current2"]
    set perm [GET $sd "permutation"]

    set fit2 [pop_get_entity_fitness_ $pop  [lindex $perm $cur2]]

    #if {$::ISPRINT} {puts stderr "....... off2 = $off2   fit2 = $fit2"}

    if {$off2 <= $fit2} {break}

    #puts "off2 > fit2"
    #exit

    SET $sd "offset2" [expr {$off2 - $fit2}]

    incr cur2

    if {$cur2 >= $orig_size} {
      set cur2 [expr {$cur2 - $orig_size}]
    }    

    if {$::ISPRINT} {puts stderr "....... off2 = $off2  fit2 = $fit2  cur2 = $cur2"}

    SET $sd "current2" $cur2

  }
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  
  if {$::ISPRINT} {puts stderr ".................................. 005_1_7"}

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
proc item_qsort_MAX_to_LEFT {a b} {


  set a_fit [item_get_fitn $a]
  set b_fit [item_get_fitn $b]

  # налево, т.е. в лучшие отправим с БОЛЬШИМ фитенсом 
  #                     (это должно быть по умолчанию)

  #return [GT $a_fit $b_fit]
  return [qsort_MAX_to_LEFT $a_fit $b_fit]
}
#-------------------------------------------------------------------------------
proc item_qsort_MIN_to_LEFT {a b} {


  set a_fit [item_get_fitn $a]
  set b_fit [item_get_fitn $b]

  # налево, т.е. в лучшие отправим с МЕНЬШИМ фитенсом 
  #                      (вариант для особых случаев)

  #
  # т.е. здесь уже просто фитнесы

  #return [LT $a_fit $b_fit]
  return [qsort_MIN_to_LEFT $a_fit $b_fit]
}
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
proc pop_sorting {pop sort_driver} {

#   if {$sort_driver == ""} {
#     set sort_driver $::sort_driver
#     #set sort_driver [GET $pop sort_driver]
#   }


  if {[get_pop_size $pop] == 0} {
    return ;# если в популяции ничего еще нет !!
  }
  
  # в случае, если специально определена функция сравнения (а не просто по фитнесу)
  # т.е. if (pop->rank != ga_rank_fitness) то надл использовать эту функцию!
  #                ??? нафига, если все можно в вфитнес вынести ???
  #set rank_proc [$self cget -rank]
  #if {$rank_proc != "ga_rank_fitness"} {
  #  die "NOT ..... ga_rank_fitness"
  #}
  
  set itemslist [GET $pop itemslist]

  # если ы списке реальные итемы (словари), то делаем типа
  # item_MIN_to_LEFT или item_MAX_to_LEFT

  set sortcmd "item_qsort_${sort_driver}"

  SET $pop itemslist  [qsort_AF $itemslist $sortcmd]

  SET $pop best 0 ;# после сортировки это должно быть так

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
proc dict_parse_all {d args} {

  dict for {key value} $args {

    set key [string trimleft $key "-"]

    SET $d  $key $value
  }

}
#-------------------------------------------------------------------------------
proc task_create {fitness_proc  args} {

  set t [dict_create]

  SET $t "fitness_proc" $fitness_proc

  SET $t "fit_tobest" "MIN" ;# т.е. чем меьше, тем лучше 
  SET $t "fit_target" 0
  SET $t "fit_error"  0.01

  #SET $t "fit_target"   [dict_parse $args "-fit_target"] 
  #SET $t "fit_error"    [dict_parse $args "-fit_error" ] 

  dict_parse_all $t {*}$args

  return $t
}
#-------------------------------------------------------------------------------
proc task_print {t} {

  puts "-------------------------- task --------------"
  puts "fitness_proc = [GET $t fitness_proc]"
  puts "fit_target   = [GET $t fit_target]" 
  puts "fit_error    = [GET $t fit_error]" 
  puts "-------------------------- task --------------"
  puts ""

  return $t
}
#-------------------------------------------------------------------------------
set ::NEWMUTATE 0
#-------------------------------------------------------------------------------
proc mutate_create {args} {

  #set mutate_proc "ga_mutate_double_singlepoint_drift"

  set mutate_proc [dict_parse $args "-mutate_proc" ga_mutate_double_singlepoint_drift]

  #dict_parse_all $t {*}$args


  if {$::NEWMUTATE} {

    set m [dict_create]

    SET $m "mutate_proc" $mutate_proc
  } else {
    
    set m $mutate_proc
  }

  return $m
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
                -lpop $population_size -lgen $len_chromo]

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

  SET $pop  mutate  [mutate_create -mutate_proc $mutate]

  SET $pop  crossover $crossover ;#
  SET $pop  replace   $replace   ;#
  
  return $pop
}
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------









#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
# g-corB.tl
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------

package require tcltest

namespace import tcltest::*

#-----------------------------------------------------------------------------
# 
#   СТРОКИ + БЛОКИ = ПРОГРАММЫ
# 
#
# TODO: ключевая точка роста, надо понять:
#
# - куда записывать fitness (main должна быть такой же функцией как все!)

# - в чем разница "prog" и "libra"
# - нужно ли делать через глобальные указатели ? тогда изменения будут видны сразу
#   для всех организмов
# - но можно сделать и локально, просто скопировав!

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
proc make_itemslist_from_prgpop {prgpop} {


  set itemslist {}
  
  # идем списком по "сырым заготовкам" - только программы
  # 

  foreach prg $prgpop {

    set item  [item_make $prg] ;# здесь указатели !!

    # пока фитнеса нет, только программы

    lappend itemslist  $item ;# добавляем организма (указатели)
  }

  return $itemslist
}
#-------------------------------------------------------------------------------
# создаем начальную популяцию программ с заданным числом особей
# и с размерами в заданном интервале (UNICUM) 
#
# n - требуемое кол-во особей в популяции
#
#-------------------------------------------------------------------------------
proc make_rand_prgpop_unikum {n 
                               minlen maxlen 
                               gp_list randinstr quotes_proc} {

  set prgpop {}

  set attempts      0
  set max_attempts  [expr {$n / 3}] 
  
  for {set i 0} {$i < $n} {} {
    
    set p [get_randprog_unikum  $prgpop $minlen $maxlen \
                                $attempts $max_attempts \
                                $gp_list  $randinstr $quotes_proc]
    
    if {$p == {}} { 

      # неудачная по пытка создания уникума
      #puts "NOT find PRG !! attempts = $attempts"

      incr  attempts ;# сколько неудачных попыток уже было
      continue 

      # но тогда популяция станет маленькой, надо пробовать другие..
    } else {
      set attempts 0
    }
    
    lappend prgpop $p ;# добаляем программу в популяцию !! списком !!

    incr i ;# счетчик полученных особей (надо  именно здесь)
  }
  
  return $prgpop
}
#-------------------------------------------------------------------------------
# создать начальную популяцию программ с заданным числом особей и
# длинами (этих программ) из заданного диапазона

#-------------------------------------------------------------------------------
proc make_rand_prgpop {bnums minlen maxlen  gp_list randinstr quotes_proc} {

  set prgpop {}

  while {[incr bnums -1] >= 0} {

    set n [myrand_new $minlen $maxlen]

    lappend prgpop [make_randprog $n  $gp_list $randinstr $quotes_proc]
  }

  return $prgpop
}
#-------------------------------------------------------------------------------
proc pop_print_B {pop} {


  set i 1
  
  foreach item $pop {

    puts -nonewline [format "  %2d)  " $i]

    #item_print  $item
    puts "$item"

    incr i
  }

  puts ""
  
}
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------

set ::len_is_constant 0

#-------------------------------------------------------------------------------
proc make_prgpop {randpop_proc 
                  population_size len 
                  is_print 
                } {


  # создаем стартовую популяцию (здесь пока только сами программы, не агенты!!!)
  # т.е. сырые заготовки в формате JOY
  #

  #----------------------------------------
  if {$::len_is_constant} {
    set minlen $len
  } else {
    set minlen 1
  }

  set maxlen $len
  #----------------------------------------

  set prgpop [$randpop_proc  $population_size  $minlen $maxlen \
                             $::gp_list   $::randinstr $::quotes_proc]
  
  if {$is_print} {
    puts ""
    puts "make_prgpop: INIT POPULATION = \n"
    puts "$prgpop \n"
    puts ""
    pop_print_B  $prgpop 
    puts ""
  }

  return $prgpop
}
#-------------------------------------------------------------------------------
proc make_itemslist {randpop_proc 
                     population_size len 
                     is_print 
                   } {

  
  set prgpop [make_prgpop  $randpop_proc \
                            $population_size $len \
                             $is_print]

  if {$is_print} {
    puts ""
    puts stderr "randpop_proc = $randpop_proc"
    puts stderr "prgpop       = $prgpop"
    puts ""
  }

  # TODO:
  # 
  # а вот здесь уже можно сделать реальные программы с "main" и т.д.
  #

  set itemslist [make_itemslist_from_prgpop  $prgpop]


  return $itemslist
}
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#-----------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#-----------------------------------------------------------------------------

set ::IN  {}  ;# стек интервалов зарисовки 

set ::RN 100  ;# процент случайного возврата 1

set ::proc_index 1

#-------------------------------------------------------------------------------
proc is_equal {item1 item2} {

  set len [llength $item1]

  if {$len == 1} {return $::false}

  for {set i 0} {$i < $len} {incr i} {


    if {[lindex $item1 $i] != [lindex $item2 $i]} {return $::false}
  }

  return $::true
}
#-------------------------------------------------------------------------------
proc add_num_to_item {i item w} {

  set subs [lindex $item 0]
  set nums [lindex $item 1]

  set ret [list  $subs [lappend nums $i]  $w]

  #puts "item = $item  i = $i  ret = $ret"

  return $ret
}
#-------------------------------------------------------------------------------
proc add_sub_to_list {prg  i w  &L} {

  USE_REFS


  set i_beg  $i
  set i_end  [expr $i + $w -1]   
  set sub    [lrange $prg  $i_beg $i_end]
  
  #dputs "add_sub_to_lis:   w = $w  i = $i  sub = $sub"
  

  set len [llength $L] ;# текущая длина словаря

  # смотрим в словаре, если уже есть совпадение, добавляем ссылку, если нет, то
  # добавляем запись:

  for {set d 0} {$d < $len} {incr d} {

    set item [lindex $L $d 0]

    if {[is_equal  $item $sub]} {

      # найдено совпадение, добавить номер (i, смещение) подсписка SUB 
      # в уже существующую запись словаря
      # 

      lset L $d   [add_num_to_item  $i [lindex $L $d] $w]

      return
    } 
  }

  # не найдено совпадений, добавим подсписок SUB в словарь
  # 

  lappend L  [list $sub [list $i]]

  return
}
#-------------------------------------------------------------------------------
proc substrings_to_dict_find {prg len w  &L} {

  USE_REFS

  # скользим окошком ширины "w":
  # 

  for {set i 0} {$i < [expr $len - $w +1]} {incr i} {
    
    add_sub_to_list $prg $i $w  L 
  }
  
}
#-------------------------------------------------------------------------------
proc substrings_find_by_w_expand {prg w_prev &L_prev} {

  USE_REFS

  set w [expr $w_prev + 1]

  set L_ret {}

  foreach item $L_prev {

    set subs [lindex $item 0]
    set nums [lindex $item 1]

    if {[llength $nums] == 1} {continue}

    #puts "item   = $item"

    foreach i $nums {

      add_sub_to_list  $prg $i $w L_ret 
    }

  }

  return $L_ret
}
#-------------------------------------------------------------------------------
proc clean_compressed {L} {

  set L_ret {}

  foreach item $L {

    set nums [lindex $item 1]
    
    if {[llength $nums] == 1} {continue}

    lappend L_ret $item
  }

  return $L_ret
}
#-------------------------------------------------------------------------------
proc substrings_find_all {prg start_w} {

  #set start_w 2

  set len   [llength  $prg]
  set max_w [expr $len / 2] ;# 

 
 if {0} {

   puts "substrings_find_all: ~~~~~~~~~"
   puts ""
   puts "prg   = $prg"
   puts "len   = $len"
   puts "max_w = $max_w"
   puts ""

   exit
  }


  for {set w $start_w} {$w <= $max_w} {incr w} {

    set L($w) "" ;# здесь будем складывать результаты сканирования

    #puts ""
    #puts "w = $w ........................... "
    #puts ""

    if {$w == $start_w} {

      substrings_to_dict_find  $prg $len $w  L($w) 
    } else {
      
      set w_prev [expr $w - 1]
      set L($w) [substrings_find_by_w_expand  $prg $w_prev L($w_prev) ]
    }

    
    set  L($w) [clean_compressed [set L($w)]] ;# очистим от одиночных

  }


  set ret      [dict create]
  #puts "ret = |$ret| ................  "
  set ret_list {} ;# сделаем по-новому - "новичок"

  set names [array names L]

  set sortnames [lsort -decreasing $names]

  foreach w $sortnames {

    set L_w [set L($w)] ;# items

    if {$L_w == {}} {continue} ;# оставляем только те, где есть повторения

    #puts "substrings_find_all: w = $w  L_w = $L_w" 
    # TODO: надо дописать туда w в каждый item !!!!

    #dict set ret      $w $L_w ;# для JIM получается не тот порядок
    lappend  ret_list $w $L_w
  }

  if {0} {

    puts ""
    puts "substrings_find_all: names = $names, sortnames = $sortnames"
    #puts "substrings_find_all: ret      = $ret"
    puts "substrings_find_all: ret_list = $ret_list"
    puts ""
    puts "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
    puts ""

    exit
  }

  #return [list $ret] ;# уже по убыванию!
  return [list $ret_list] 
}
#-------------------------------------------------------------------------------
proc interval_set_null {} {
  
  set ::IN {}

}
#-----------------------------------------------------------------------------
proc interval_push args {
  
  # последовательно все аргументы помещаем в стек:
  # 
  # а если аргументы сами представляют списки?
  # если это список, то он добавится как список tcl, а нужно поэелментно! 
  
  foreach a $args {lappend ::IN  $a}
  
  return
}
#-----------------------------------------------------------------------------
proc interval_pop {} {
  
  # хитрый приемчик, чтобы быстро "вытащить" последний (верхний) элемент
  # стека:
  # возьмем элемент из списка, а сам список "укоротим"
  
  set element [ K [lindex $::IN end] [set ::IN [lrange $::IN 0 end-1]] ]
  
  return $element
}
#-------------------------------------------------------------------------------
proc random_set {procent} {

  set ::RN $procent

  return
}
#-------------------------------------------------------------------------------
proc random_0_or_1 {} {

  if {$::RN == 100}  {return 1}

  return [RandYes $::RN]

  #return 1 ;# пока никаких случайностей
}
#-------------------------------------------------------------------------------
proc interval_draw_check_new {i1 i2} {


  foreach i $::IN {

    set i_beg [lindex $i 0]
    set i_end [lindex $i 1]

    set is_1 [expr {$i2 < $i_beg}] ;# целиком слева  от проверяемого
    set is_2 [expr {$i1 > $i_end}] ;# целиком справа от проверяемого

    if {[expr ! ($is_1 || $is_2)]} {return $::false} ;# пересекаются?
  }

  # вроде бы место свободно, все хорошо. но !
  # можно в этом месте ввести элемент случайности

  if {[random_0_or_1] == 0} {

    return $::false ;# колесо фортуны
  }

  return $::true
}
#-------------------------------------------------------------------------------
proc interval_draw {fl_ptr  i1 i2} {

  # это более совершенный вариант, кладем в стек интервал (границы отрезка)
  # 


  if {! [interval_draw_check_new  $i1 $i2]} {return $::false}

  interval_push  [list $i1 $i2] 

  return $::true
}
#-------------------------------------------------------------------------------
proc interval_init {} {


  interval_set_null

}
#-------------------------------------------------------------------------------
# proc is_this_main {key} {

#   if {$key == "main"} {return true}

#   return false
# }
#-------------------------------------------------------------------------------
proc proc_name_index_init {{index_start 1}} {

  set ::proc_index $index_start

}
#-------------------------------------------------------------------------------
proc get_new_proc_name {} {

  set proc_name "proc$::proc_index"

  incr ::proc_index ;# увеличили индекс наименования

  return $proc_name
}
#-------------------------------------------------------------------------------
proc set_clean_items_proc {clean_items  &prog} {

  USE_REFS

  set clean_items_with_proc {}

  foreach item $clean_items {

    set proc_name [get_new_proc_name]

    set subs [lindex $item 0]
    set nums [lindex $item 1]
    set w    [lindex $item 2]

    # тут надо бы сразу добавлять в библиотеку !!
    #
    prog_set_prg_src  prog $proc_name $subs

    # на место строки записываем уже готовое имя процедуры
    # 
    lappend clean_items_with_proc [list $proc_name $nums $w]
  }

  return $clean_items_with_proc
}
#-------------------------------------------------------------------------------
proc find_equal_index {nums i} {

  foreach n $nums {

    if {$n == $i} {return $::true}
  }

  return $::false
}
#-------------------------------------------------------------------------------
proc find_proc_index_w {clean_items_with_proc i} {


  set p {} ;# возвращаемое значение 

  foreach item $clean_items_with_proc {

    #dputs "item = $item"

    set name [lindex $item 0]
    set nums [lindex $item 1]
    set w    [lindex $item 2]

    set is_ok [find_equal_index $nums $i]

    if {$is_ok} {
      set p $name
      break
    }
  }



  return [list $p $w]
}
#-------------------------------------------------------------------------------
proc prog_add_NEW {clean_items_with_proc  prg} {

  #set prog_ret $prog ;# просто делаем копию,  и будем заполнять

  set prg_new {}

  set i 0
  set i_max [expr [llength $prg] -1]

  #dputs ""
  #dputs "clean_items_with_proc = $clean_items_with_proc"
  #dputs "prg  = $prg"
  #dputs ""

  # поэлементо и последовательно будем преобразовывать
  # 

  while {1} {

    if {$i > $i_max} {break}

    # здесь надо искать для этого индекса, есть ли интеравл, брать его и 
    # сдвигаться, а если нет, то просто копировать итем. !!!!!!!!!

    foreach {p w} [find_proc_index_w  $clean_items_with_proc $i] {break}

    #dputs "i = $i"
    #dputs "p = $p"
    #dputs "w = $w"
    #dputs ""

    if {$p == {}} {
      lappend prg_new [lindex $prg $i]

    } else {
      lappend prg_new $p
      incr i $w
      continue
    }

    incr i
  }

  # а надо ли уж тут это заносить?
  #
  #dict set prog_ret {} $prg_new
  
  #return [list $prog_ret $prg_new]

  return $prg_new

}
#-------------------------------------------------------------------------------
proc recurse_find  {fl n0 nums w  &nums_new } {

  USE_REFS

  set len [llength $nums]


  dputs "recurse_find:  n0   = $n0"
  dputs "recurse_find:  nums = $nums"
  dputs ""
   

  # взяли первое значение и рисуем для него интервал
  # 
  
  set is_ok [interval_draw  $fl $n0 [expr $n0 + $w -1]]
  
  if {$is_ok} {
    lappend nums_new  $n0
  }
  
  

  for {set i $n0} {$i < $len} {incr i} {
    
    set ni [lindex $nums $i]
    
    recurse_find  $fl $ni [lrange $nums [expr $i +1] end] $w  nums_new      
  }

  return
}
#-------------------------------------------------------------------------------
proc clean_on_border_one_item_NEW {item fl  &ret} {

  USE_REFS

  dputs "clean_on_border_one_item_NEW:  item = $item"
  dputs ""

  # главное. чтобы хоть два отрезко не пересеклись, т.е. правильно - это их
  # все сочетания перебрать и выбрать максимальное!   будем их подсчитывать

  set subs  [lindex $item 0]
  set nums  [lindex $item 1]
  set w     [lindex $item 2]

  set len [llength $nums]

  set nums_new  "" ;# здесь и посчитаем, должно быть >= 2

   
  for {set i 0} {$i < $len} {incr i} {
    
    set ni [lindex $nums $i]
    
    recurse_find  $fl $ni [lrange $nums [expr $i +1] end] $w  nums_new      
  }

  # посмотрим. сколько вообще сформировалось "правильных" интервалов
  # 
   
  set len_new [llength $nums_new]
   
  # можно тут подумать как задавать "коэффициент рефакторинга", и потом
  # добиваться его выполнения, удаляя лишние принятые интервалы, но, наверное,
  # лучше использовать "вероятностность" ? да, но одиночная проц не проходит?

  if {[expr $len_new >= 2]} {
    
    # сформируем новый итем, c правильно уложенными интервалами
    # 
    
    lappend ret [list  $subs $nums_new $w]

    return $::true;
  }

  if {$len_new == 1} {

    # одни нас не устроит, это не "рефакторинг", надо отыграть назад
    # 

    interval_pop
  }

  return $::false; ;# не найдено пары интервалов, так и ничего не запишем.
}
#-------------------------------------------------------------------------------
proc witems_to_prog_main_NEW {prg witems} {


  set prog [list "main" {}] ;# чтобы по порядку сдеовало в начеле словаря!?

  set fl [interval_init] ;# список зарисовки интервалов

  set all_items   {} ;# избавимся от группировки по W
  set clean_items {} ;# сначала ничего нет


  dict for {w items}  $witems {

    lappend all_items {*}$items
  }

  dputs "witems_to_prog_main_NEW:  all_items   = $all_items"
  dputs ""
  dputs "-----------------------------------------"
  dputs ""

  # теперь идем по всем возможным вариантам интервалов и формируем подходящий
  # вариант распределения подстрок (подпрограмм)

  foreach item $all_items {

    #dputs ""
    #dputs "---------------------"
    #dputs ""

    clean_on_border_one_item_NEW  $item $fl  clean_items

    dputs ""
    dputs "::IN  = $::IN"
    dputs "clean_items = $clean_items"
    dputs ""
    dputs "---------------------"
    dputs ""
  }


  dputs "-----------------------------------------"
  dputs ""

  if {$clean_items == {}} {

    return [list $prog $prg] 
  }


  # и окончательно пишем библиотеку 
  # 
  dputs "clean_items           = $clean_items"
  dputs "prog                  = $prog"

  set clean_items_with_proc [set_clean_items_proc  $clean_items  prog]

  dputs "clean_items_with_proc = $clean_items_with_proc"
  dputs ""

  # меняем программу заменяя библ. процами
  # 
  set prg_new [prog_add_NEW  $clean_items_with_proc $prg]

  dputs "prg                   = $prg"
  dputs "prg_new               = $prg_new"
  dputs ""
  dputs "-----------------------------------------"
  dputs ""


  return [list $prog $prg_new] 
}
#-------------------------------------------------------------------------------
proc commit_to_from {prog_new  prog_old} {


  # а если в библиотеках совпадают имена ?? надо переименовать !!
  # 

  set prg_new [prog_get_prg_src $prog_new "main"]

  set prog_ret $prog_new

  # от "prog_old" берем только библиотеки
  #

  dict for {key value} $prog_old {

    #puts "key= $key value= $value"

    if {$key == "main"} {continue}

    # здесь надо проверять, есть ли такая проца (key/value) уже в prg_new 
    # (и по имени и по содержанию) !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    # 

    #dict set prog_ret $key $value 
    lappend prog_ret $key $value 
  }

  prog_set_prg_src  prog_ret "main" $prg_new ;# !!!

  return $prog_ret
}
#-------------------------------------------------------------------------------
proc set_max_starter {prog} {


  set max_numer 0 ;# будем искать максимум

  dict for {key value} $prog {

    if {$key == "main"} {continue}

    #set numer [lrange $key 0 end] ;# это же для списка !!
    set numer [string range $key 4 end]

    if {$numer > $max_numer} {set max_numer $numer}

    #puts "set_max_starter: key= $key numer= $numer max_numer= $max_numer "
  }

  proc_name_index_init [expr $max_numer + 1]

}
#-------------------------------------------------------------------------------
proc libra_refactoring {prog {start_w 2}} {

  set prog_old $prog
  set  prg_old [prog_get_prg_src  $prog_old "main"]

  dputs ""

  # можно согласовывать все имена на этом этапе рефакторинга
  # 
  # TODO: нельзя сделать рефакторинг отдельно тела MAIN программs без
  # учета продпроцедур в библиотеке !!!

  # получаем словарь для всех ширин W (исключая пустые) по убыванию
  # 
  foreach {all_witems} [substrings_find_all  $prg_old $start_w] {break}

  #puts "libra_refactoring: all_witems = $all_witems"

  # TODO: здесь надо посмотреть все имена в библиотеке
  # и установить стартер (начальный номер?)
  #
  set_max_starter  $prog_old ;#??

  # возвращает отдельно библиотеку, отдельно программу
  # 
  foreach {prog prg_new} [witems_to_prog_main_NEW  $prg_old $all_witems] {break}


  # занесем главную программу
  # 
  prog_set_prg_src  prog "main" $prg_new

  dputs "prog_old = $prog_old"
  dputs "prog     = $prog"
  dputs ""

  set    prog_new [commit_to_from  $prog $prog_old] 

  return $prog_new
}
#-------------------------------------------------------------------------------
proc proc_find  {prog p} {

  if {[dict exist $prog $p]} {

    #set f [dict get $prog $p]
    set f [prog_get_prg_src $prog $p]

  } else {

    set f {}
  }

  return $f
}
#-------------------------------------------------------------------------------
proc make_unfactoring_prog {prog_old} {

  set prog_new {}
  set  prg_new {}

  set prg_old [prog_get_prg_src $prog_old "main"]

  foreach p $prg_old {

    puts "p = $p"

    set f [proc_find $prog_old $p]
    
    if {$f == {}} {

      lappend prg_new $p ;# нет такого имени в библиотеке, просто копируем
    } else {
      lappend prg_new {*}$f
    }


  }

  #dict set prog_new "main" $prg_new
  prog_set_prg_src  prog_new "main" $prg_new

  return $prog_new
}
#-------------------------------------------------------------------------------

# http://www.wellho.net/mouth/3638_Sorting-dicts-and-arrays-in-Tcl.html

# Once version 8.6 ofTcl gets to a production release (and you have it on all 
# your systems), you'll be able to use the -stride and index options on lsort, 
# which will directly return you a sorted dict if you pass in a parameter 2 to 
# the stride. Thus:

#  lsort -stride 2 {grapefruit 10 banana 110 cherry 25}
# will return
#  banana 110 cherry 25 grapefruit 10

# and
#  lsort -stride 2 -index 1 -integer {grapefruit 10 banana 110 cherry 25}
# wlll return
#  grapefruit 10 cherry 25 banana 110

#-------------------------------------------------------------------------------
proc dict_sort {d} {

  if {$::__TCL__} {

    return [lsort -stride 2 $d]
  } else {

    # в JIM такого ключа нет, но тут, похоже и не нужна сортировка?
    # 
    return $d
  }

}
#-------------------------------------------------------------------------------
proc canonical_form {prog} {

  set prog_ret {}

  dict for {key value} $prog {

    #puts "canonical_form: key= $key value= $value"

    set prg_src [dict get $value "src"]    
    #dict set prog_ret $key $prg_src
    lappend prog_ret $key $prg_src

  }

  # но словарь может быть в произвольном порядке 
  # поэтому надо бы отсортировать по алфавиту

  set prog_ret [dict_sort $prog_ret] 

  return $prog_ret
}
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------


set ::randinstr   "randinstr_SIMP"
set ::quotes_proc "quotes_proc_NULL"

#-------------------------------------------------------------------------------
################################################################################
# 
#  T R A N S F O R M    T R A N S F O R M    T R A N S F O R M    
# 
################################################################################


#set ::item_OLD 0

#set ::OLD 0

#-------------------------------------------------------------------------------
proc string_replace_first {prg_old str1 str2  &ind_start} {

  USE_REFS

  set str1_len [string length  $str1]
  set str2_len [string length  $str2]

  set  i1 [string first $str1 $prg_old $ind_start]

  if {$i1 == -1} {
    # return 0  ;# можно наверное придумать признак какой-нибудь..
    set ind_start -1
    return $prg_old
  }

  set i2 [expr $i1 + $str1_len - 1] 
  set prg_new [string replace  $prg_old $i1 $i2  $str2]

  set ind_start [expr $i1 + $str2_len]

  return $prg_new
}
#-------------------------------------------------------------------------------
proc get_transform {prg_old  trans_rule} {

  set str1 [lindex $trans_rule 0] ;# будем менять эту подстроку
  set str2 [lindex $trans_rule 1] ;# на эту

  set prg_new $prg_old

  set ind_start 0
  #puts "prg = $prg_new ind_start = $ind_start"

  # выполняем все подобные трансформации в строке, но
  # в целях экономии каждый раз с более дальнего места
  # и заканчиваем по достижении конца (-1)
  
  while {$ind_start >= 0} {
    set prg_new [string_replace_first  $prg_new $str1 $str2   ind_start]
    #puts "prg = $prg_new ind_start = $ind_start"
  }

  puts ""

  return $prg_new
}
#-------------------------------------------------------------------------------
proc get_transform_s {prg_old  trans_rule_s} {

  set prg_new $prg_old

  # можно вообще-то и в обратноу сторону заменять, но тогда
  # отмечать, наверное, уже отработанную схему ..

  # а смысл заменять в обратную? тут наверное нужен точечный подход:
  # где надо, там и менять в какую надо сторону..

  foreach r $trans_rule_s {
    
    # выплним трансформацию для каждого правила
    set prg_new [get_transform $prg_new $r]
  }

  return $prg_new
}
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
proc get_arglist {instr} {

  #set

  #set arglist [info args $instr]

  #return $arglist
}
#-------------------------------------------------------------------------------
# получить случайную инструкцию
# вариант с анализом аргументов
#-------------------------------------------------------------------------------
proc randinstr_ARGS {gp_list} {

  #set instr [lrand $gp_list]
  set instr [lrand_new $gp_list]
  
  set arglist [info args $instr]
  
  if {[llength $arglist] == 0} { #if {$arglist eq {}}  - для Tcl-8.4 
    #puts "111111111111"
    return $instr
    
  } else {
    
    #puts "222222222222"
    info default $instr [lindex $arglist 0] l

    foreach {min max} $l break
    return [list $instr [rand $min $max]]
  }

}
#-------------------------------------------------------------------------------
# возвращаем случайную инструкцию
# пока упрощенный вариант -  не получается анализ аргументов
#-------------------------------------------------------------------------------
proc randinstr_SIMP {gp_list} {

  #puts ""
  #puts "RANDINSTR ... !!"

  #set  instr   [lrand $gp_list]
  set  instr   [lrand_new $gp_list]

  #------------------------------------------------------------
  #set  procname ::joy::builtin::${instr} ;# делаем имя более уникальным!
  #puts "instr= $instr  procname= $procname"

  # проверяем наличие переменной массива (туда записывали инфу)
  #if {[info exists ::joy::builtin($instr)]} {
  #  # если есть уже во встроенных функциях, то 
  #  puts "222"
  #} else {
  #  puts "333"
  #}

  #puts ""
  #set arglist [info args $instr]  ;# список параметров процедуры

  #set arglist [info args $procname]  ;# список параметров процедуры
  #"::joy::builtin::-" isn't a procedure
  #while executing "info args $procname"

  # тут проблема в "Math related functions":
  # все они регистрируются через одну функцию "+",
  # "::joy::builtin::+" что не очень правильно !!
  # !!! TODO: сделать раздельную регистрацию этих функций !!!

  #puts "arglist= $arglist"
  #puts ""
  #------------------------------------------------------------
  
  # если простые процедуры без аргументов:
  return $instr
  


  #------------------------------------------------------------
  #puts "instr= $instr   arglist= $arglist"
  
  #if {[llength $arglist] == 0} {} #if {$arglist eq {}}  - для Tcl-8.4 
  if {$arglist eq {}} {

    return $instr
    
  } else {
    # здесь есть примитивное предположение о конкретной ф-ции
    # с двумя параметрами - выбор константы из интервала, но
    # а что делать в общем случае??
    #
    # так может пока обойтись без таких особенностей?
    
    puts "??"
    
    info default $instr [lindex $arglist 0] l ;# возвращает TRUE
    # если для заданного параметра есть значение по умолчанию
    # (оно и записывается в переменную в конце (l)
    
    foreach {min max} $l break ;# ??? интервал для константы?

    # команда foreach используется "не по назначению", т.е. не для
    # организации цикла, а лишь для присвоения элементов списка
    # сразу нескольким переменным..
    # команда break нужна чтобы случайно не захватить больше
    
    return [list $instr [rand $min $max]]
  }
  #------------------------------------------------------------
  
} 
#-------------------------------------------------------------------------------
proc quotes_proc_NULL {oldprg} {

  set newprg $oldprg

  return $newprg
}
#-------------------------------------------------------------------------------
# создать случайную программу (список?) длиной не больше 'n' или равно ??
# 
#-------------------------------------------------------------------------------
proc make_randprog {n gp_list {randinstr "randinstr_SIMP"} {quotes_proc "quotes_proc_NULL"}} {

  while {[incr n -1] >= 0} {

    set instr [$randinstr $gp_list]

    lappend prg $instr
  }
  
  # а здесь надо бы вставить скобочки, т.е. заквотить часть инструкций
  # но что тогда с длиной?

  #if {![info exist ::quotes_proc]} {
  #  set ::quotes_proc quotes_proc_NULL
  #}

  set prg [$quotes_proc $prg]


  return $prg
}
#-------------------------------------------------------------------------------
proc get_randprog_unikum {result minlen maxlen attempts max_attempts 
                          gp_list randinstr quotes_proc} {

 #puts "... 1"

 set prg [make_randprog [myrand_new  $minlen $maxlen] \
            $gp_list $randinstr \
            $quotes_proc]

 #puts "prg = $prg "
 #puts "result = $result"
 #puts "... 2"

 # 
 # здесь надо бы сравнить на уникальность?
 #
 set ix [lsearch -exact $result $prg]

 if {$ix >= 0} { 
   #puts "ALREADYyyy: result= $result  prg= $prg "
   #continue ;# не возьмем уже такую же особь в популяцию
   # но тогда популяция станет маленькой, надо пробовать другие..
   #puts "attempts = $attempts"
   
   if {$attempts < $max_attempts} {
     set prg {} ;# если попыток подряд мало, 
     #puts "attempts < 2 "
     # то вернем пустой список, как сигнал, что не найдено

   }  else {

     # а иначе пусть останется дубляж ..
     #puts "NOT FIND:  $prg  attempts=$attempts max_attempts=$max_attempts"
     puts "NOT FIND:  $prg"
   }
 }
 
 return $prg 
}
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#-----------------------------------------------------------------------------
#-------------------------------------------------------------------------------

#namespace import tcltest::*

#-------------------------------------------------------------------------------
proc set_argc_argv_null {} {

  global argc argv

  set argc 0
  set argv "" ;# где-то эти параметры используются внутри тестов !!

}
#-------------------------------------------------------------------------------
proc make_simple_main_prog {src} {


  return [list "main" [list "src" $src]]
}
#-------------------------------------------------------------------------------
proc ALL_TESTS {} {


  set_argc_argv_null 

  #-----------------------------------------------

  #tcltest::test intro-111 {
  #  "EXAMPLE"
  #
  #} -body {
  #  expr 3 * 5
  #} -result 15

  #-----------------------------------------------

  test simple_01 {} {
    
     proc_name_index_init

     set src {p0 p0  p1 p1 p1  p2 p2  p2 p2  p1 p1 p1  p3 p3}

     set prog [make_simple_main_prog $src]

     set prog [libra_refactoring $prog] 

     return [canonical_form $prog]

   } {main {p0 p0 proc1 proc2 proc2 proc1 p3 p3} proc1 {p1 p1 p1} proc2 {p2 p2}}

  #-----------------------------------------------

  test simple_01_a {} {
    
    proc_name_index_init

    set src {p0 p0  p1 p1 p1  p2 p2  p2 p2  p1 p1 p1  p0 p0}

    set prog [make_simple_main_prog $src]
    set prog [libra_refactoring $prog] 

    return [canonical_form $prog]

   } {main {proc2 proc1 proc3 proc3 proc1 proc2} proc1 {p1 p1 p1} proc2 {p0 p0} proc3 {p2 p2}}

  #-----------------------------------------------

  test simple_02 {} {
    
    proc_name_index_init

    set src {p1 p1 p1    p1 p1 p1}

    set prog [make_simple_main_prog $src]
    set prog [libra_refactoring $prog] 

    return [canonical_form $prog]

  } {main {proc1 proc1} proc1 {p1 p1 p1}}

  #-----------------------------------------------

  test simple_03 {} {
    
    proc_name_index_init

    set src {p1 p1 p1}

    set prog [make_simple_main_prog $src]
    set prog [libra_refactoring $prog] 

    return [canonical_form $prog]

  } {main {p1 p1 p1}}

  #-----------------------------------------------

  test simple_04 {} {
    
    proc_name_index_init

    set src {p1 p1 p1 p1 p1}

    set prog [make_simple_main_prog $src]
    set prog [libra_refactoring $prog] 

    return [canonical_form $prog]

  } {main {proc1 p1 proc1} proc1 {p1 p1}}

  #-----------------------------------------------

  test simple_05 {} {
    
    proc_name_index_init

    set src {p1 p1 p1   p2 p2  p2 p2   p1 p1 p1}

    set prog [make_simple_main_prog $src]
    set prog [libra_refactoring $prog] 

    return [canonical_form $prog]

  } {main {proc1 proc2 proc2 proc1} proc1 {p1 p1 p1} proc2 {p2 p2}}

  #-----------------------------------------------

  test simple_06 {} {
    
    proc_name_index_init

    set src {p1 p1 p1  p2  p1 p1 p1  p3  p1 p1 p1}

    set prog [make_simple_main_prog $src]
    set prog [libra_refactoring $prog] 

    return [canonical_form $prog]

  } {main {proc1 p2 proc1 p3 proc1} proc1 {p1 p1 p1}}

  #-----------------------------------------------

  test simple_07 {} {
    
    set prog_old [list \
                    "main"  {"src" {proc1 p2 p2 proc1 p2 p2 proc1}}  \
                    "proc1" {"src" {p1 p1 p1}}]

    proc_name_index_init ;# 2 ;# !! новые имена генерим с этой цифры (заплатка)

    set prog_new [libra_refactoring  $prog_old 2]

    return [canonical_form $prog_new]

  } {main {proc2 proc2 proc1} proc1 {p1 p1 p1} proc2 {proc1 p2 p2}}
  # {} {main {proc2 proc2 proc1} proc2 {proc1 p2 p2} proc1 {p1 p1 p1}}

  #-----------------------------------------------

}
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
proc ITEM_test {} {

  puts ""
  puts "----------------------------------------------------"
  puts ""

  ALL_TESTS

  puts "----------------------------------------------------"
  puts ""

  # TODO:
  #
  # нужно научиться выделять схожие последовательности и складывать в 
  # библиотеку!
  #
  # алгоритм lz77 делает похожее, но он последовательный, т.е. надо дополнительно
  # его рихтовать и кроме того, он - на строках из символов и надо переделывать
  # в списки токенов!
  #
  # поэтому пока сделаю тут вручную простейший, а потмо, если совсем медлено
  # будет. вернусь к lz77!


  #set prg { p1 p1 p1} 
  #set prg { p1 p1 p1 p1 p1 } 

  #set prg {p0 p0  p1 p1 p1   p2 p2  p2 p2  p1 p1 p1   p0 p0}
  #set prg { p1 p1 p1  p1 p1 p1} 

  set src {p1 p1 p1  p2  p1 p1 p1  p3  p1 p1 p1} 

  #set src  {p1 p1 p1   p2 p2  p2 p2  p1 p1 p1} 


  #set prog_origin  [make_simple_main_prog $src]
  #puts "prog_origin = $prog_origin"

  set item_prog    [item_make $src]  

  puts " src = $src"
  puts "item = [set $item_prog]"

  #puts ""
  #puts "----------------------------------------------------"
  #puts ""

  #set ::NEW 1

  #set item_prog    [item_make $src]  

  #puts " src = $src"
  #puts "item = [set $item_prog]"

  #puts ""
  
  return

  #d+

  set start_w 2   ;# минимальное окно сканирования

  #random_set  70 ;# вероятносность


  proc_name_index_init

  set prog2 [libra_refactoring   $prog_origin $start_w] 

  puts "----------------------------------------------------"
  puts ""
  puts "prg_origin = $prg"
  puts ""

  #puts "prog1 = $prog1"  
  puts "prog2 = $prog2"  
  puts ""

   
  puts "RandYes 100 = [RandYes 100]"
  puts "RandYes  90 = [RandYes  90]"
  puts "RandYes  50 = [RandYes  50]"
  puts "RandYes  10 = [RandYes  10]"
  puts ""

  set prog3 [make_unfactoring_prog  $prog2]

  puts ""
  puts "prog3 = $prog3"  
  puts ""
  puts "----------------------------------------------------"
  puts ""


  set prog4_old  [list \
                    "main"  {src {proc1 p2 p2 proc1 p2 p2 proc1}}  \
                    "proc1" {src {p1 p1 p1}}] 

  puts "prog4_old = $prog4_old"  
  puts ""

  #------------------------------------------------------------

  #set prog_new = main {src {proc1 proc1 proc1}} proc1 {src {proc1 p2 p2}}

  #set prog_new  [list \
                    "main"  {src {proc1 proc1 proc1}}  \
                    "proc1" {src {proc1 p2 p2}}] 

  #set      prog_new [commit_to_from  $prog_new $prog_old] 

  #return

  #------------------------------------------------------------


  proc_name_index_init  ; #2 ;# !!;# новые имена генерятся с 1 и забивают старые! 
  # 
  # в любом случае, если будем где-то хранить уже готовые процы, то
  # надо вопрос совместимости имен решать !!

  #d+

  set prog4_new [libra_refactoring  $prog4_old 2] 

  puts "prog4_new = $prog4_new"  
  puts ""


  return
}
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------


#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#
# g-cros.tl  g-cros.tl  g-cros.tl  g-cros.tl  g-cros.tl  g-cros.tl 
#

#   ga_crossover.c

#   ga_crossover - Genetic algorithm crossover operators.
#   Copyright б╘2000-2006, Stewart Adcock <stewart@linux-domain.com>
#   All rights reserved.

#   Synopsis:     Routines for performing GA crossover operations.

# 		These functions should duplicate user data where
# 		appropriate.

#   To do:	Merge static crossover functions by passing datatype size.


# //------------------------------------------------------------------------------
# // `Mates' two chromosomes by single-point crossover.
# //------------------------------------------------------------------------------
proc ga_singlepoint_crossover_integer_chromosome {pop  father_CH  mother_CH 
                                                         &son_CH    &dau_CH} {

  USE_REFS

  set len_chromo [GET $pop len_chromosomes]

  # Choose crossover point and perform operation 
  #
  set location [random_int  $len_chromo]
  
  set son_chromo [make_list $len_chromo 0]
  set dau_chromo [make_list $len_chromo 0]


  memcpy  son_chromo 0  $mother_CH 0  $location
  memcpy  dau_chromo 0  $father_CH 0  $location
  
  memcpy  son_chromo $location  $father_CH $location  [expr {$len_chromo - $location}]
  memcpy  dau_chromo $location  $mother_CH $location  [expr {$len_chromo - $location}]

  # и запишем по адресу:
  #
  set son_CH $son_chromo
  set dau_CH $dau_chromo
  
  return
}
# //------------------------------------------------------------------------------
# //  `Mates' two chromosomes by double-point crossover.
# //------------------------------------------------------------------------------
#
# !!!! это один в один с ga_doublepoint_crossover_double...., но еам нужна другая!
#
# //------------------------------------------------------------------------------
proc ga_doublepoint_crossover_integer_chromosome {pop  father_CH  mother_CH 
                                                        &son_CH    &dau_CH} {

  USE_REFS

  set len_chromo [GET $pop len_chromosomes]

  #   /* Choose crossover point and perform operation */

  set location1 [random_int  $len_chromo]

  #   do
  #   {
  #     location2 = random_int (pop->len_chromosomes);
  #   } while (location2 == location1);
  
  while {1} {
    set  location2 [random_int  $len_chromo]
    if {$location2 != $location1} {break}
  }

  #// получили две несовпадающие точки (целочисленные)

  if {$location1 > $location2} {

    set tmp $location1
    set location1 $location2
    set location2 $tmp
  }
  
  #// теперь они в нужном порядке (по возрастающей)

  set son_chromo [make_list $len_chromo 0]
  set dau_chromo [make_list $len_chromo 0]


  memcpy  son_chromo 0  $father_CH 0  $location1
  memcpy  dau_chromo 0  $mother_CH 0  $location1
  
  memcpy  son_chromo $location1  $mother_CH $location1  [expr {$location2 - $location1}]
  memcpy  dau_chromo $location1  $father_CH $location1  [expr {$location2 - $location1}]
  
  memcpy  son_chromo $location2  $father_CH $location2  [expr {$len_chromo - $location2}]
  memcpy  dau_chromo $location2  $mother_CH $location2  [expr {$len_chromo - $location2}]

  # и запишем по адресу:
  #
  set son_CH $son_chromo
  set dau_CH $dau_chromo
  
  return
}
# //------------------------------------------------------------------------------
# //  `Mates' two genotypes by single-point crossover of
# //   each chromosome.
# //------------------------------------------------------------------------------
proc ga_crossover_integer_singlepoints {pop father mother son daughter} {

  set son_CH      "" ;# <---
  set daughter_CH "" ;# <---

  ga_singlepoint_crossover_integer_chromosome  $pop \
    [item_CH $father ] [item_CH $mother]    son_CH  daughter_CH

  item_set_chromosome $son      $son_CH
  item_set_chromosome $daughter $daughter_CH

  return
}
# //------------------------------------------------------------------------------
# //  `Mates' two genotypes by randomizing the parents
# //   alleles.
# //   Keeps no chromosomes intact, and therefore will
# //   need to recreate all structural data.
# //------------------------------------------------------------------------------
proc ga_crossover_char_allele_mixing {pop father mother son daughter} \
{

  for {set j 0} {$j < [GET $pop len_chromosomes]} {incr j} \
  {
    if {[random_boolean]} \
    {

      item_set_chromo_gen $son      $j  [item_get_chromo_gen $father $j]
      item_set_chromo_gen $daughter $j  [item_get_chromo_gen $mother $j]

    } else {

      item_set_chromo_gen $daughter $j  [item_get_chromo_gen $father $j]
      item_set_chromo_gen $son      $j  [item_get_chromo_gen $mother $j]
    }
 }

  return
}
# //------------------------------------------------------------------------------
# //  `Mates' two genotypes by single-point crossover of
# //   each chromosome.
# //------------------------------------------------------------------------------
proc ga_crossover_char_singlepoints {pop father mother son daughter} \
{

  # наверное имеет смысл просто так
  # 
  ga_crossover_integer_singlepoints  $pop $father $mother $son $daughter


  return
}
# //------------------------------------------------------------------------------
# //  `Mates' two genotypes by double-point crossover of
# //   each chromosome.
# //------------------------------------------------------------------------------
# void 
# ga_crossover_char_doublepoints (CROSSOVER_VALS)
# //------------------------------------------------------------------------------
proc ga_crossover_char_doublepoints {pop father mother son daughter} \
{

  
  set len_chromo [GET $pop len_chromosomes]

  #     /* Choose crossover point and perform operation */
  #     location1 = random_int (pop->len_chromosomes);

  set location1 [random_int  $len_chromo]

  #     do
  #     {
  #       location2 = random_int (pop->len_chromosomes);
  #     } while (location2==location1);

  while {1} {
    set  location2 [random_int  $len_chromo]
    if {$location2 != $location1} {break}
  }
  
  #     if (location1 > location2)
  #     {
  #       tmp = location1;
  #       location1 = location2;
  #       location2 = tmp;
  #     }
  
  if {$location1 > $location2} {

    set tmp $location1
    set location1 $location2
    set location2 $tmp
  }

  #// теперь они в нужном порядке (по возрастающей)


  set son_chromo [make_list $len_chromo 0]
  set dau_chromo [make_list $len_chromo 0]

  # (можно использовать другую функцию ?)
  # 

  set father_CH  [item_CH $father]
  set mother_CH  [item_CH $mother]

  memcpy  son_chromo 0  $father_CH 0  $location1
  memcpy  dau_chromo 0  $mother_CH 0  $location1
  
  memcpy  son_chromo $location1  $mother_CH $location1  [expr {$location2 - $location1}]
  memcpy  dau_chromo $location1  $father_CH $location1  [expr {$location2 - $location1}]
  
  memcpy  son_chromo $location2  $father_CH $location2  [expr {$len_chromo - $location2}]
  memcpy  dau_chromo $location2  $mother_CH $location2  [expr {$len_chromo - $location2}]


  # и запишем по адресу:
  #
  item_set_chromosome $son      $son_chromo
  item_set_chromosome $daughter $dau_chromo

  return
}
# //------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
proc memcpy {&new n  old o  size} {

  USE_REFS

  for {set i 0} {$i < $size} {incr i} {

    lset new [expr {$n + $i}] [lindex $old [expr {$o + $i}]]
  }

  return
}
# //------------------------------------------------------------------------------
# //  `Mates' two chromosomes by double-point crossover.

# void 
# ga_doublepoint_crossover_double_chromosome (population *pop,
#                                             double *father, double *mother,
#                                             double    *son, double *daughter)

# //------------------------------------------------------------------------------
proc ga_doublepoint_crossover_double_chromosome {pop  father_CH  mother_CH 
                                                        &son_CH    &dau_CH} {

  USE_REFS

  #   int	location1, location2;	/* Points of crossover. */
  #   int	tmp;			/* For swapping crossover loci. */
  
  #   if (!father || !mother || !son || !daughter)
  #     die ("Null pointer to chromosome structure passed.");
  
  set len_chromo [GET $pop len_chromosomes]

  # Choose crossover point and perform operation 

  set location1 [random_int  $len_chromo]

  #   do
  #   {
  #     location2 = random_int(pop->len_chromosomes);
  #   } while (location2==location1);
  
  while {1} {
    set  location2 [random_int  $len_chromo]
    if {$location2 != $location1} {break}
  }

  #// получили две несовпадающие точки (целочисленные)

  if {$location1 > $location2} {

    set tmp $location1
    set location1 $location2
    set location2 $tmp
  }
  
  #puts stderr "location1 = $location1"
  #puts stderr "location2 = $location2"


  #// теперь они в нужном порядке (по возрастающей)

  if {0} {

    # пока для теста сделаем очень просто: 
    #
    set son_chromo $mother_CH
    set dau_chromo $father_CH
    
  } else {
    
    # получилось неправильно !
    #     lappend son_chromo [lrange $father_CH 0 $location1]
    #     lappend dau_chromo [lrange $mother_CH 0 $location1]
    
    #     lappend son_chromo [lrange $mother_CH $location1 $location2]
    #     lappend dau_chromo [lrange $father_CH $location1 $location2]
    
    #     lappend son_chromo [lrange $father_CH $location2 end]
    #     lappend dau_chromo [lrange $mother_CH $location2 end]


    set son_chromo [make_list $len_chromo 0]
    set dau_chromo [make_list $len_chromo 0]
    
    #puts "son_chromo = $son_chromo"
    #puts "dau_chromo = $dau_chromo"
    #puts ""
    #exit

    memcpy  son_chromo 0  $father_CH 0  $location1
    memcpy  dau_chromo 0  $mother_CH 0  $location1

    memcpy  son_chromo $location1  $mother_CH $location1  [expr {$location2 - $location1}]
    memcpy  dau_chromo $location1  $father_CH $location1  [expr {$location2 - $location1}]

    memcpy  son_chromo $location2  $father_CH $location2  [expr {$len_chromo - $location2}]
    memcpy  dau_chromo $location2  $mother_CH $location2  [expr {$len_chromo - $location2}]

  }

  #if {$::is_print} {
  #  puts stderr ""
  #  puts stderr "son_chromo = $son_chromo"
  #  puts stderr "dau_chromo = $dau_chromo"
  #  puts stderr ""
  #}

  # и запишем по адресу:
  #
  set son_CH $son_chromo
  set dau_CH $dau_chromo
  
  return
}
# //------------------------------------------------------------------------------
# //  `Mates' two genotypes by double-point crossover of
# //   each chromosome.

# void 
# ga_crossover_double_doublepoints (CROSSOVER_VALS)

# #define CROSSOVER_VALS population *pop, entity *father, entity *mother, entity *son, entity *daughter 

# //------------------------------------------------------------------------------
proc ga_crossover_double_doublepoints {pop father mother son daughter} {


  #   if (!father || !mother || !son || !daughter)
  #     die ("Null pointer to entity structure passed");
  
  #   ga_doublepoint_crossover_double_chromosome (pop,
  #                                               (double *) father->CH,
  #                                               (double *) mother->CH,
  #                                               (double *) son->CH,
  #                                               (double *) daughter->CH);

  set son_CH      ""  
  set daughter_CH ""

  ga_doublepoint_crossover_double_chromosome  $pop [item_CH $father] [item_CH $mother ] \
                                                   son_CH  daughter_CH

  item_set_chromosome $son      $son_CH
  item_set_chromosome $daughter $daughter_CH

  return
}
# //------------------------------------------------------------------------------

# //******************************************************************************
# //------------------------------------------------------------------------------









#------------------------------------------------------------------------------
#   synopsis:	Seed genetic data for a single entity with an integer
# 		chromosome by randomly setting each allele.
#   parameters:	population *pop
# 		entity *adam
#   return:	success
#------------------------------------------------------------------------------
# boolean 
# ga_seed_integer_random (population *pop, entity *adam)
#------------------------------------------------------------------------------
proc ga_seed_integer_random {pop adam}  {

  #   //int		chromo;		/* Index of chromosome to seed */
  #   int		point;		/* Index of allele to seed */
  
  #   /* Checks. */
  #   if (!pop) die("Null pointer to population structure passed.");
  #   if (!adam) die("Null pointer to entity structure passed.");
  
  #   /* Seeding. */
  #   //chromo=0;
  #   //for (chromo=0; chromo<pop->num_chromosomes; chromo++)
  #   //{

  set amin [GET $pop allele_min_integer]
  set amax [GET $pop allele_max_integer]


  for {set point 0} {$point < [GET $pop len_chromosomes]} {incr point} \
  {
    # ((int *)adam->CH/* chromosome[chromo] */)[point] =
    #   random_int_range(pop->allele_min_integer,pop->allele_max_integer);

    set r [random_int_range  $amin $amax]

    #$adam set_chromo_gen $point $r 
    item_set_chromo_gen $adam $point $r 
  }

  #   //}

  return 1 ;#true
}
#-------------------------------------------------------------------------------
#   synopsis:	Sets the minimum value for an integer allele for a
# 		population.
#-------------------------------------------------------------------------------
# void 
# ga_population_set_allele_min_integer (population *pop,
# 				      int	  value)
#-------------------------------------------------------------------------------
# proc ga_population_set_allele_min_integer__ {pop value}  {


#   SET $pop  allele_min_integer $value

#   return
# }
#-------------------------------------------------------------------------------
#   synopsis:	Sets the maximum value for an integer allele for a
# 		population.
#-------------------------------------------------------------------------------
# proc ga_population_set_allele_max_integer {pop value}  {


#   SET $pop  allele_max_integer $value

#   return
# }
# /**********************************************************************
#   ga_mutate.c

#   ga_mutate - Genetic algorithm mutation operators.
#   Copyright б╘2000-2006, Stewart Adcock <stewart@linux-domain.com>
#   All rights reserved.

#   Synopsis:     Routines for performing GA mutation operations.

# 		These functions should duplicate user data where
# 		appropriate.

#-------------------------------------------------------------------------------
#   synopsis:	Cause a single mutation event in which a single
# 		allele is cycled.
#-------------------------------------------------------------------------------
proc ga_mutate_integer_singlepoint_drift {pop father son} {

  if {$::is_print} {
    puts "  ga_mutate_integer_singlepoint_drift : "
    #puts ""
  }

  set chromosome [item_get_chromosome $father]

  item_set_chromosome $son $chromosome

  #set len_chromo [GET $pop len_chromosomes]

  set len_chromo [llength chromosome]

  set point [random_int  $len_chromo] ;# Index of allele to mutate 
  
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # 
  # Mutate by tweaking a single allele.
  #    
  # ((int *)son->chromosome[chromo])[point] += dir;
  #

  if {[random_boolean]} {
    set dir -1  ;# The direction of drift.
  } else {
    set dir  1
  }

  set point_gen [item_get_chromo_gen $son  $point] ;# старое значение
  set point_gen [expr        {$point_gen + $dir}]  ;# новое  значение

  set allele_max_integer [GET $pop allele_max_integer]
  set allele_min_integer [GET $pop allele_min_integer]

  ##_
  #puts "allele_max_integer = $allele_max_integer"
  #puts "allele_min_integer = $allele_min_integer"
    
  if {$point_gen > $allele_max_integer} {
    if {$::is_print} {
      puts "  > allele_max_integer"
    }
    set point_gen $allele_min_intege ;# скорректировали
  }

  
  if {$point_gen < $allele_min_integer} {
    if {$::is_print} {
      puts "  < allele_min_integer"
    }
    set point_gen  $allele_max_intege ;# скорректировали
  }

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  item_set_chromo_gen $son  $point $point_gen ;# записали новое значение

  return
}
#-------------------------------------------------------------------------------
#   synopsis:	Cause a single mutation event in which a single
# 		allele is cycled.
# void 
# ga_mutate_printable_singlepoint_drift (population *pop,
#                                        entity *father, entity *son)
#-------------------------------------------------------------------------------
proc ga_mutate_printable_singlepoint_drift {pop father son}  {


  set chromosome [item_get_chromosome $father]

  item_set_chromosome $son $chromosome ;# ????


  #set len_chromo [GET $pop len_chromosomes]

  set len_chromo [llength $chromosome]

  # случайно выбираем точку в хромосоме? тогда ее длину и надо же брать?
  # 
  set point [random_int  $len_chromo]
  
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #   /*
  #     * Mutate by tweaking a single allele.
  #     */

  # The direction of drift. 
  
  if {[random_boolean]} {
    set dir -1
  } else {
    set dir  1
  }

  set point_gen [item_get_chromo_gen $son  $point] ;# старое значение
  set point_gen [expr {$point_gen + $dir}]  ;# новое  значение


  #   set char_min_num $::allele_min_integer
  #   set char_max_num $::allele_max_integer
  
  #   if {$point_gen > $char_max_num} {
  #     puts "mutate 1..............."
  #     set point_gen $char_min_num ;# скорректировали
  #   }
  
  #   if {$point_gen < $char_min_num} {
  #     puts "mutate 2..............."
  #     set point_gen $char_max_num ;# скорректировали
  #   }
  
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  item_set_chromo_gen $son  $point $point_gen ;# записали новое значение

  return
}
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#   synopsis:	Cause a single mutation event in which a single
# 		allele is adjusted.  (Unit Gaussian distribution.)

# void 
# ga_mutate_double_singlepoint_drift (population *pop,
#                                     entity *father, entity *son)

#-------------------------------------------------------------------------------
proc ga_mutate_double_singlepoint_drift {pop father son}  {

  if {$::is_print} {
    pop_print $pop
    puts "  ga_mutate_double_singlepoint_drift : "
    #puts ""
  }

  #   //int		i;		/* Loop variable over all chromosomes */
  #   //int		chromo;		/* Index of chromosome to mutate */
  #   int		point;		/* Index of allele to mutate */
  #   double	amount=random_unit_gaussian();	/* The amount of drift. (FIXME: variance should be user-definable) */
  set amount [random_unit_gaussian]
  
  #   /* Checks */
  #   if (!father || !son) die("Null pointer to entity structure passed");
  
  set len_chromo [GET $pop len_chromosomes]

  #   /* Select mutation locus. */
  #   /* chromo =  (int) */ random_int(1/* pop->num_chromosomes */);
  random_int 1

  #   //chromo = 0; // (int) random_int(1/* pop->num_chromosomes */);
  #   point  = (int) random_int(pop->len_chromosomes);
  set point [random_int  $len_chromo]

  #   /*
  #     * Copy unchanged data.
  #     */
  #   //i=0;
  #   //for (i=0; i<pop->num_chromosomes; i++)
  #   //{

  #   memcpy(son->CH, father->CH, pop->len_chromosomes*sizeof(double));
  #$son set_chromosome [$father get_chromosome]
  #item_set_chromosome $son [$father get_chromosome]
  item_set_chromosome $son [item_get_chromosome $father]

  # /*   if (i!=chromo) */
  # /*   { */
  # /*     ga_copy_data(pop, son, father, i); */
  # /*   } */
  # /*   else */
  # /*   { */

  #   ga_copy_data(pop, son, NULL, /* i */0); - надо ли это ???????????

  # /*   } */
  #   //}
  
  set allele_max_double [GET $pop allele_max_double]
  set allele_min_double [GET $pop allele_min_double]

  #   /*
  #     * Mutate by tweaking a single allele.
  #     */
  #   ((double *)son->CH/* chromosome[chromo] */)[point] += amount;
  #
  set point_gen [item_get_chromo_gen $son  $point] ;# старое значение
  set point_gen [expr {$point_gen + $amount}]  ;# новое  значение

  
  # вообще не понятно это зачем, но надо сделать, чтобы совпадать с си-шным
  # вариантом;
  #
  # кстати, после кооректировки срабатывает та самая дурацкая процедура
  # ga_genocide_by_fitness  !!!!!!!!!!!!!
  #
  # ну и здесь лучше разобраться окончательно со значением, а уж потом
  # записывать;

  set allele_correct [expr {$allele_max_double - $allele_min_double}]


#   if {$::is_print} {
#     pop_print $pop
#     puts "  item_set_chromo_gen:  point_gen= $point_gen  amount= $amount  allele_min_double= $allele_min_double"
#   }

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#   if {$point_gen > $allele_max_double} {
#     #if {$::is_print} {
#       puts "  > allele_max_double .............. "
#     #}
#     set point_gen [expr {$point_gen - $allele_correct}] ;# скорректировали
#   }

  
#   if {$point_gen < $allele_min_double} {
#     #if {$::is_print} {
#       puts "  < allele_min_double .............. "
#     #}
#     set point_gen [expr {$point_gen + $allele_correct}] ;# скорректировали
#   }
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  
  if {$::is_print} {
    #pop_print $pop
    puts "  item_set_chromo_gen: point= $point point_gen= $point_gen"
  }

  #$son set_chromo_gen  $point $point_gen ;# записали новое значение
  item_set_chromo_gen $son  $point $point_gen ;# записали новое значение

  if {$::is_print} {
    pop_print $pop
  }

  return
}
#-------------------------------------------------------------------------------

# //******************************************************************************








# ------------------------------------------------------------------------------
#   ga_optim.c

#   ga_optim - Optimisation and evolution routines.

#   Synopsis:     Routines for optimisation and evolution.
# 
#                 Note that the temperatures in the simulated annealling
#                 and MC functions do not exactly run from the initial
#                 temperature to the final temperature.  They are offset
#                 slightly so that sequential calls to these functions
#                 will have a linear temperature change.  The SA and MC
# 		code in this file is deprecated anyway - these routines
# 		have been replaced with much more flexible alternatives
# 		and will be removed in the near future.
# 
#   To do:	Finish rewriting parallel versions, ga_evolution_mp() in particular.
# 		Write ga_evolution_pvm().
# 		Remove much duplicated code.
# 		OpenMOSIX fix.  See below.
# 		gaul_adapt_and_evaluate_forked() and gaul_adapt_and_evaluate_threaded() 
#                 are only parallelized for the case that no adaptation occurs.

# //------------------------------------------------------------------------------
# //  synopsis:	Swap the ranks of a pair of entities.
# //  parameters: population *pop
# //		const int rank1
# //		const int rank2
# //  return:	none
# //------------------------------------------------------------------------------
proc pop_entities_swap {pop  id1 id2} \
{

  set ent1 [pop_get_entity_ $pop  $id1]
  set ent2 [pop_get_entity_ $pop  $id2]

  pop_set_entity_ $pop  $id1 $ent2
  pop_set_entity_ $pop  $id2 $ent1
  
  return
}
# ------------------------------------------------------------------------------
# //------------------------------------------------------------------------------
# //  synopsis:	Mating cycle. (i.e. Sexual reproduction).
# //  parameters:	population *pop
# //  return:	none
# //------------------------------------------------------------------------------
proc gaul_crossover {pop task} {
  

  set select_two_proc [GET $pop select_two]

  if {$::is_print > 2} {
    puts "gaul_crossover : (select_two_proc = $select_two_proc)"
    puts ""
  }
  
  if {[GET $pop crossover_ratio] <= 0.0}  { 
    puts "!!!!!!!!!!!!!!!!!!!!"
    return 
  }
  
  # здесь обнуляем, т.е. начинаем процедуру выбора (селекции) сначала
  # 
  SET $pop  select_state 0
  
  #set crossover_proc [GET $pop crossover] ;# TODO: странно, но что-то меняется!
  #                                       для g_stru.tl _4  10 2 @

  #set eval_proc [GET $pop "evaluate"]
  set eval_proc [GET $task "fitness_proc"]

  # For JIM
  set mother "" ;# ссылка
  set father "" ;# ссылка

  #  Select pairs of entities to mate via crossover.
  #
  while {! [$select_two_proc $pop  mother father]} {

    set crossover_proc [GET $pop crossover] ;# почему здесь ??
  
    set son [ga_get_free_entity  $pop] ;# создали новых !!!
    set dau [ga_get_free_entity  $pop] ;# 

    $crossover_proc $pop  $mother $father  $dau $son
    
    # здесь бы сразу деток посчитать?
    # 
    pop_eval_item  $pop $dau $eval_proc $task
    pop_eval_item  $pop $son $eval_proc $task 

    # перепутанный порядок даже с сишным вариантом!
    # однако

    if {$::is_print >= 3} {

      print_entit  $mother "mom ="
      print_entit  $father "dad ="

      print_entit  $dau    "dau ="
      print_entit  $son    "son ="       
    }

    if {$::is_print >= 3} {
      puts ""
    }
  }
  
  return
}
# ------------------------------------------------------------------------------
# synopsis:	Mutation cycle.  (i.e. Asexual reproduction)
# parameters:	population *pop
# return:	none

# ------------------------------------------------------------------------------
proc gaul_mutation {pop task} {


  if {$::is_print > 2} {
    puts "gaul_mutation  : (select_one_proc = [GET $pop select_one])"
    puts ""
  }
  
  set select_one_proc [GET $pop select_one]
 
  set mutate_proc     [GET $pop mutate]

  
  if {[GET $pop mutation_ratio] <= 0.0}  { return }  
  
  SET $pop select_state 0
  
  # Select entities to undergo asexual reproduction, in each case the child will
  # have a genetic mutation of some type.
 
  #set eval_proc [GET $pop "evaluate"]
  set eval_proc [GET $task "fitness_proc"]

  set mother "" ;# <-------- &
  # 
  while { ! [$select_one_proc  $pop mother] } {

    set dau [ga_get_free_entity $pop]  ;# создали нового !!!

    $mutate_proc $pop  $mother $dau
    
    # здесь бы сразу мутантку посчитать?
    # 
    pop_eval_item  $pop $dau $eval_proc  $task

    if {$::is_print >= 3} {
      print_entit  $dau "dau ="
      puts ""
    }

  }
  
  return
}
# //------------------------------------------------------------------------------
# 
# лонгическая схема сделана так будто в перечисляемом типе "scheme" хранится
# несколько одновременно флажков, но нигде не нашел где это формируется, т.е.
# где эти битовые маски складываются ! наверное это лишнее !?
# 
# //------------------------------------------------------------------------------
# int 
# is_in_scheme (ga_scheme_type scheme, ga_scheme_type name)
# //------------------------------------------------------------------------------
proc is_in_scheme {scheme name} \
{

  #puts "is_in_scheme : scheme = $scheme"
  #puts ""

  #   //int ret = ((scheme & GA_SCHEME_BALDWIN_PARENTS) != 0);
  #   int ret = ((scheme & name) != 0);

  # пока предпологаем, что там не список:
  # 
  set ret [expr {$scheme == $name}]

  return $ret
}
#//------------------------------------------------------------------------------
proc adapt_1 {task pop ibeg iend} \
{

  set adapt_proc [GET $pop adapt]

#   puts stderr ""
#   puts stderr "adapt_1:  adapt_proc = $adapt_proc"
#   puts stderr ""


  for {set i $ibeg} {$i < $iend} {incr i} \
  {

    set child     [pop_get_entity_ $pop  $i]
    set child_fit [item_get_fitn $child]

    # выполнили адаптацию, т.е. "взрастили" особь (?)

    set adult     [$adapt_proc  $task $pop $child] ;# новая структура
    set adult_fit [item_get_fitn $adult]

    # и теперь ее фитнесс запишем младенцу (?)

    pop_set_entity_fitness_ $pop  $i $adult_fit

    pop_del_entity  $pop $adult ;# и удалим адаптированную особь ??!!
  }

  return
}
# //------------------------------------------------------------------------------
proc adapt_2 {task pop ibeg iend} \
{

  set adapt_proc [GET $pop adapt]
#   puts stderr ""
#   puts stderr "adapt_2:  adapt_proc = $adapt_proc"
#   puts stderr ""


  for {set i $ibeg} {$i < $iend} {incr i} \
  {

    set child    [pop_get_entity_ $pop  $i]

    set adult    [$adapt_proc  $task $pop $child]    
    set adult_id [pop_get_entity_id  $pop $adult]
    
    pop_entities_swap  $pop $i $adult_id
    
    pop_del_entity_by_id   $pop $adult_id
  }

  return
}
# ------------------------------------------------------------------------------
# synopsis:	Fitness evaluations.
# 		Evaluate the new entities produced in the current
# 		generation, whilst performing any necessary adaptation.
# 		Simple sequential version.
# parameters:	population *pop
# return:	none
#
# ------------------------------------------------------------------------------
proc gaul_adapt_and_evaluate {pop task} \
{

  #   /* typedef enum ga_scheme_type_t     */
  #   /*   { */
  #   /*   GA_SCHEME_DARWIN           = 0, */
  #   /*   GA_SCHEME_LAMARCK_PARENTS  = 1, */
  #   /*   GA_SCHEME_LAMARCK_CHILDREN = 2, */
  #   /*   GA_SCHEME_LAMARCK_ALL      = 3, */
  #   /*   GA_SCHEME_BALDWIN_PARENTS  = 4, */
  #   /*   GA_SCHEME_BALDWIN_CHILDREN = 8, */
  #   /*   GA_SCHEME_BALDWIN_ALL      = 12 */
  #   /*   } ga_scheme_type; */
  
  set scheme [GET $pop scheme]  ;# Evolutionary scheme
  
  if {$::is_print > 2} {
    puts "gaul_adapt_and_evaluate : (scheme = [GET $pop scheme])"
    puts ""
  }

  set o [GET $pop stable_size]
  set s [get_pop_size $pop]
    
  #set eval_proc [GET $pop "evaluate"]

  # < Total number of fitness evaluations: 150
  # ---
  # > Total number of fitness evaluations: 214 если сразу все посчитать
  
  if {$scheme == "GA_SCHEME_DARWIN"} {
  
    # This is pure Darwinian evolution. Simply assess fitness of all children.    
 
  } else {
  
    #  Some kind of adaptation is required.  First reevaluate parents, as needed, 
    #  then children. 

    switch -- $scheme {

      "GA_SCHEME_BALDWIN_PARENTS"  {
        adapt_1       $task $pop  0 $o
      }
    
      "GA_SCHEME_LAMARCK_PARENTS"  {
        adapt_2       $task $pop  0 $o
      }
    
      "GA_SCHEME_BALDWIN_CHILDREN" {
        adapt_1       $task $pop $o $s
      }
    
      "GA_SCHEME_LAMARCK_CHILDREN" {
        adapt_2       $task $pop $o $s
      }

      default {
        puts ""
        puts "gaul_adapt_and_evaluate: scheme = $scheme    !!! ERROR"
        puts ""
        exit 
      }
    }

  }
  
  return
}
# //------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
proc pop_del_entities {p imin imax} {


  set tmp [GET $p itemslist] 

  set new_iarray [lreplace $tmp $imin $imax] ;# удалили часть списка  

  SET $p itemslist $new_iarray
  
  return
}
# ------------------------------------------------------------------------------
proc ga_elitism_parents_die_exept {pop num_parents_survives} \
{

  set  imin  $num_parents_survives  ;# сколько родителей оставить
  set  imax  [GET $pop stable_size]
  incr imax  -1

  # удаляем группу [num_parents_survives , stable_size - 1]

  pop_del_entities $pop $imin $imax


  if {$::is_print > 2} {
    puts "after  delete_parents_exept_some !"
    puts ""
    pop_print $pop "stderr"
    puts ""
  }


  return
}
# ------------------------------------------------------------------------------
#   synopsis:	Survival of the fittest (выживание сильнейшего).
# 		Enforce elitism (навязывем элитаность), reduce
# 		population back to its stable size and rerank entities,
# 		as required.

#   parameters:	population *pop
#   return:	none

# ------------------------------------------------------------------------------
proc gaul_survival {pop} \
{

  # survival - выживание

  set elitism [GET $pop elitism]

  if {$::is_print > 2} {
    puts "gaul_survival : (elitism = $elitism)"
    puts ""
  }

  switch -- $elitism {

    "GA_ELITISM_PARENTS_SURVIVE"     {}
    
    "GA_ELITISM_PARENTS_DIE"         {ga_elitism_parents_die_exept  $pop 0}    
    "GA_ELITISM_ONE_PARENT_SURVIVES" {ga_elitism_parents_die_exept  $pop 1}
    
    "GA_ELITISM_RESCORE_PARENTS"     {ga_elitism_rescore_parents    $pop}    
    "GA_ELITISM_BEST_SET_SURVIVE"    {ga_elitism_best_set_survive   $pop}
    "GA_ELITISM_PARETO_SET_SURVIVE"  {ga_elitism_pareto_set_survive $pop}    
  }


  return
}
# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
proc crossover_mutation_adapt_survival {pop task} {

  if {$::is_print > 2} {

    puts stderr "crossover_mutation_adapt_survival ... "
    puts ""
    pop_print $pop "stderr" ; puts ""
  }

  #-----------------------------------------------------------------
  #  Crossover step 
  #  
  gaul_crossover $pop $task ;# выбираются мама и папа и затем скрещиваются 
                       # в новых (созданных) членов общества !!
  
  if {$::is_print > 2} {pop_print $pop "stderr" ; puts ""}

  #-----------------------------------------------------------------
  # Mutation step
  #  

  gaul_mutation $pop $task ;# муитруем в новых членов общества !!
  
  if {$::is_print > 2} {pop_print $pop "stderr" ; puts ""}

  #-----------------------------------------------------------------
  # Apply environmental adaptations, score entities, sort entities, etc.
  #  
 
  gaul_adapt_and_evaluate $pop $task ;# а где же сортировка?
  
  if {$::is_print > 2} {pop_print $pop "stderr" ; puts ""}

  #-----------------------------------------------------------------
  # Survival of the fittest (выживание наиболее приспособленных)
  # 
  # GA_ELITISM_PARENTS_DIE     (FS)
  # GA_ELITISM_PARENTS_SURVIVE (_2_main_ 
  # 

  gaul_survival $pop ;# что-то делаем с получившемся набором старых и новых 
    

  if {$::is_print > 2} {pop_print $pop "stderr" ; puts ""}

  #-----------------------------------------------------------------
  # сортируем всех челнов популяции по фитнесу
  # 
 
  pop_sorting $pop [make_sortdriver_fromtask $task]

  #-----------------------------------------------------------------
  # Убиваем наименее приспособленных членов популяции, чтобы восстановить 
  # численность до ее стабильного первоначального размера.
  #

  ga_genocide  $pop [GET $pop stable_size]


  return
}
# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
proc migration_right_to_left {pop0 pop1} {


  set migration_ratio [GET $pop1 "migration_ratio"] ;# может отличаться?

  #set size1 [GET $pop1 size]

  set size1 [get_pop_size $pop1]

  for {set i 0} {$i < $size1} {incr i} {
    
    if {[random_boolean_prob $migration_ratio]} {        
      ga_entity_clone  $pop0 [pop_get_entity_ $pop1  $i];
    }
  }

  return
}
# ------------------------------------------------------------------------------
proc gaul_migration_by_pairs {num_pops pops} {

  # идем циклом по популяциям, сдвигая пару соседних и них делаем тупую миграцию ?? 

  for {set i 1} {$i < $num_pops} {incr i} {
  
    set pop1 [lindex $pops $i]
    set pop0 [lindex $pops [expr {$i - 1}]]

    # pop1 --> pop0 частично, т.е. некоторые итемы, в соответсвии с "migration_ratio"
    #
    migration_right_to_left  $pop0 $pop1
  }
  
  # и теперь тоже самое надо сделать для последней спец. пары
  #

  set popbeg  [lindex $pops 0]
  set popend  [lindex $pops [expr {$num_pops - 1}]]

  migration_right_to_left  $popend $popbeg

}
# ------------------------------------------------------------------------------
#   synopsis:	Migration cycle.
#   parameters:	population *pop
#   return:	none
# ------------------------------------------------------------------------------
proc gaul_migration {task num_pops pops} {

  set sort_driver [make_sortdriver_fromtask $task]

  if {$::is_print} {
    puts "gaul_migration : "
    puts ""
  }

  gaul_migration_by_pairs  $num_pops $pops


  # сортируем членов каждой популяции, чтобы новые иммигранты ранжировались
  # корректно.
  # FIXME: возможно было бы более эффективно вставлять иммигрантов сразу корректно
  # 
  
  for {set i 0} {$i < $num_pops} {incr i} \
  {
    pop_sorting [lindex $pops $i] $sort_driver
  }

  return
}
# //----------------------------------------------------------------------------
proc ga_evolution_step {task pop max_generations  fit_target fit_error} {


  set generation [GET $pop "generation"]
  
  if [is_check_generation_break  $pop $generation $max_generations \
        $fit_target $fit_error \
        $::is_print] {

    return 0 ;# false
  }
  
  # основная часть !!!! делаем новое поколение!
  #
  crossover_mutation_adapt_survival $pop $task
  
  incr generation
  SET $pop generation $generation
  

  return 1 ;# true
}
# //----------------------------------------------------------------------------
# //  synopsis:	Main genetic algorithm routine.  Performs GA-based
# //		optimisation on the given population.
# //		This is a generation-based GA.
# //		ga_genesis(), or equivalent, must be called prior to
# //		this function.
# //  parameters:
# //  return:
# //----------------------------------------------------------------------------
proc ga_evolution_main {task pop max_generations} {


  set fit_target [GET $task "fit_target"]
  set fit_error  [GET $task "fit_error"]


  # Do all the generations:
  # 
  # Stop when (a) max_generations reached, or
  #           (b) "pop->generation_hook" returns FALSE.  

  SET $pop "generation" 0


  #--------------------------------------------------------------------
  while {1} {

    if {! [ga_evolution_step  $task $pop $max_generations $fit_target $fit_error]} {
      break;
    }

  } ;# /* Generation loop. */
  #--------------------------------------------------------------------
  
  puts ""

  if {$::is_print > 1} {

    puts ""
    puts "FINAL RESULT: "
    puts ""
    pop_print_ $pop
    puts ""
  }

  #exit
  #return $generation
  return [GET $pop "generation"]
}
# //------------------------------------------------------------------------------
proc ga_evolution {task pop  max_generations} {


  # Score and sort the initial population members.
  #  
  pop_initial_score_and_sort  $pop $task
 
  set generation [ga_evolution_main  $task $pop $max_generations]

  return $generation

}
# //------------------------------------------------------------------------------
# //  synopsis:	Main genetic algorithm routine.  Performs GA-based
# //		optimisation on the given populations using a simple
# //		island model.  Migration occurs around a cyclic
# //		topology only.  Migration causes a duplication of the
# //		respective entities.  This is a generation-based GA.
# //		ga_genesis(), or equivalent, must be called prior to
# //		this function.
# //  parameters:	const int	num_pops
# //		population	**pops
# //		const int	max_generations
# //
# //  return:	number of generation performed
# ------------------------------------------------------------------------------
proc ga_evolution_archipelago {num_pops pops  max_generations task} {

  
  for {set i 0} {$i < $num_pops} {incr i} \
  {
    set pop [lindex $pops $i] ;# Current population  
 
    # Score and sort the initial population members.
    #  
    pop_initial_score_and_sort $pop $task  
  }
  

  #  Do all the generations: ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 
  #
  set generation 0

  set complete ::false ;# Whether evolution is terminated
  
  set fit_target [GET $task "fit_target"]
  set fit_error  [GET $task "fit_error"]


  while {1} {

    #     if {$generation >= $max_generations} {break}
    if {$complete != $::false}            {break}

    # // Migration step.
    # //
    gaul_migration $task  $num_pops $pops
    
    
    for {set i 0} {$i < $num_pops} {incr i} {

      if {$::is_print} {
        puts ""
        puts "CURRENT ISLAND = $i"
        puts ""
      } 

      set pop [lindex $pops $i]

      if {! [ga_evolution_step  $task $pop $max_generations $fit_target $fit_error]} {
        set complete TRUE
        break;
      }
        
      #--------------------------------------------------------------------

    }
    
  } 
  
  return $generation
}
# //******************************************************************************
# //------------------------------------------------------------------------------
# //------------------------------------------------------------------------------
# //------------------------------------------------------------------------------
# //------------------------------------------------------------------------------
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
proc lsort_pop_command {sort_driver a b} {

  #puts "lsort_pop_command: sort_driver= $sort_driver"

  set a_fit [item_get_fitn  $a]
  set b_fit [item_get_fitn  $b]

  # аоскольку используем функцияю lsort, присоединяем к ней типв "MIN_to_LEFT"
  # 
  set sort_driver lsort_$sort_driver

  #set sort_driver lsort_$::sort_driver
  # как отказаться от глобальной переменной? а вот так !! передали доп. параметр!!

  return [$sort_driver $a_fit $b_fit] ; # т.е МЕНЬШИЕ будут слева в списке 
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
                        } {

  set steps $max_generations

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

    # сортируем особей по фитнесу - лучший  фитнес идет куда ранее задано 
    #                               в ::sort_driver ?
    # как отказаться от этой глобальной переменной ?

    set sort_driver [make_sortdriver_fromtask $task]
    #set sort_driver $::sort_driver

    set sortcmd [list lsort_pop_command $sort_driver]

    set itemslist_sorted [lsort -command $sortcmd $itemslist]
    
    set best_item [lindex $itemslist_sorted 0]
    
    SET $pop "itemslist" $itemslist_sorted

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
  
  name  "BotName"
  task  ""
  pop   ""

} {
  # а это конструктор класса 

  #   set task [dict_parse $args "-task" \
     #               [task_create  "FS_fitness" -fit_target $::fit_target]] 
  
  #   SET $obj "task" $task
  
  #   SET $obj "name" [dict_parse  $args  "-name" ]
  #   SET $obj "pop"  [dict_parse  $args  "-pop"  ] 
  
  dict_parse_all $obj {*}$args 
}

#---------------------------------------------------------
proc calc_BOT {obj args} {
    
  set task            [dict_parse $args "-task"  [GET $obj "task"]] 
  set max_generations [dict_parse $args "-nums"] 
  
  set  pop [GET $obj "pop"]
  
  pop_initial_score_and_sort  $pop $task ;# инициация итемов функцией [GET $pop seed]  
  
  ga_evolution_main           $task $pop $max_generations ;# 0.01
  
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

  set task [task_create "FS_fitness_list" -fit_tobest "MAX" ]

  #set randpop_proc "make_rand_prgpop" ;# "make_rand_prgpop_unikum"

  #-------------------------
  
  SET $obj "task" $task  

  set pop [POP new  {*}$args]

  #set sort_driver [dict_parse $args "-sort_driver"] 

  #set      ::sort_driver $sort_driver
  #SET $pop "sort_driver" $sort_driver
  
  #SET $pop  ch_form "%s" 

  SET $obj "pop"  $pop
}

#-----------------------------------------------------------
proc calc_BOT33  {obj args} {
  
  #puts stderr "calc_BOT33: args = $args"
  
  set task [dict_parse $args "-task" [GET $obj "task"]] 
  
  if {! [info exists max_generations]} {
    set max_generations [dict_parse $args "-nums" ] 
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

  set obj [BOT33 new {*}$args]

  return $obj
}
#-------------------------------------------------------------------------------
proc make_sortdriver_fromtask {task} {

  set tobest [GET $task "fit_tobest"]

  set sort_driver "${tobest}_to_LEFT" ;# лучшие в популяции жмем влево

  return $sort_driver
}
#-------------------------------------------------------------------------------
proc run_gp_evolution {seed randpop_proc 
                       population_size  len_chromosomes 
                       fitnessfunc  fit_tobest 
                       mutprob 
                       max_generations   is_print 
                       {game_print_proc 0} 
                     } {


  #-------------------------------------
  if {$seed == "@"} {

    set seed [clock seconds]
    #exit
  }
  #-------------------------------------

  random_seed $seed ;# 

  set task [task_create $fitnessfunc -fit_tobest $fit_tobest]

  #set sort_driver [make_sortdriver_fromtask $task]

  #set ::sort_driver $sort_driver    

  #-------------------------------------

  set obj \
    [BOT33 new  -lpop $population_size -lgen $len_chromosomes \
       -task $task]

    
  # создаем начальную популяцию итемов-программ (формат 11 или 22 ??)
  # и  выпоняем эволюционный поиск 

  RUN1 "calc_" $obj \
    -nums           $max_generations \
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
    set list_calc  [item_get_chromosome $list_calc]
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

  # т.е. чем больше - тем хуже!  
  # но если возвращать отрицательное значение
  
  set fit [expr - $fit]
  
  # и тогда, чем меньше - тем хуже, т.е. чем больше, тем лучше:

  # fit_tobest = MAX 
  # fit_target = 0

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

  #set  sort_driver  "MAX_to_LEFT" ;## большие влево?
  #set ::sort_driver "MAX_to_LEFT"    

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

  run_gp_evolution  0 $randpop_proc \
                    $bnums $bsize \
    $fitnessfunc "MAX" \
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
# //------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
