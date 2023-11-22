# -*-   mode: tcl  ; coding: koi8   -*- ----------------------------------------

#-------------------------------------------------------------------------------


source "j-0000.tl"  ;# общие части
source "j-1111.tl"  ;# 
source "j-prog.tl"  ;# 

################################################################################
#-------------------------------------------------------------------------------
# POP  POP POP  POP  POP  POP  POP  POP  POP  POP  POP  POP  POP  POP   
#-------------------------------------------------------------------------------

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
  
  lpop      ""  ;# _требуемый_размер_популяции
  lsrc  ""  ;# _int_:_Maximum_length_of_each_chromosome
  
  ch_form          "%s "  ;# _"%02d"     
  generation_hook  ""  ;# _GAgeneration_hook_generation_hook 

  itemlist        ""  ;# _ 
  generation        0  ;# _ 

  best       "" ;# _для_хранения_лучшего_номера

} {
  # а это конструктор класса 

  #-----------------------------------------------

  SET $obj "lpop"     [dict_parse $args "-lpop"] 
  SET $obj "lsrc" [dict_parse $args "-lsrc"] 

  # TODO - надо вводить -printchform и по умолчанию % s
  # 
  # 
  #SET $obj "ch_form"         "% 6.3f " ;#  " %02d"   ????????????????????????/
  SET $obj "ch_form"   [dict_parse $args "-printchform"  "% 6.3f "] 

  #SET $obj "ch_form"  "% s "
  # g_orov.jm -test 1 -lpop 40 -nums 40
  
  SET $obj "generation_hook" NULL
  
  SET $obj best            {}     
}

#-------------------------------------------------------------------------------
#   Population handling functions.

#   synopsis:	Allocates and initialises a new population structure,
# 		and assigns a new population id to it.

#   parameters:	const int lpop    кол-во переданных в след. поколение.
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
  itemlist  "" 


  ;# _/*
  ;# __*_The_scoring_function_and_the_other_callbacks_are_defined_here.
  ;# __*/
  iteration_hook ""
  
  seedproc     "" 
  
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
  
  set ::RANDOM_RAND_MAX 4294967295  ;# g-gaul
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
    puts "[procname]: i = $i  ent = $ent"
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

  set list [GET $pop "itemlist"]

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

  
  set tmp [GET $p itemlist]

  #puts "pop_add_entity_: tmp = $tmp, entity = [set $entity]"

  lappend tmp $entity

  SET $p  itemlist $tmp ;# ERROR on JIM !!???

  #pop_incr_size_ $p  1
  
  return 
}
#-------------------------------------------------------------------------------
proc pop_set_entity_ {p i entity} {

  #l_set_option_pop $p "itemlist" $i $entity

  set optname "itemlist"

  set  tmp [GET $p $optname] ;# это список

  lset tmp $i $entity

  SET $p $optname $tmp

}
#-------------------------------------------------------------------------------
proc pop_get_entity_ {p i} {

  set tmp [GET $p itemlist]
  
  set r [lindex $tmp $i]
  
  return $r
}
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
proc pop_print_lite {p {out "stdout"}} {


  set itemlist [GET $p itemlist]
  set gen_form   [GET $p "ch_form"]
  set ind_form   " %4d)   "


  itemlist_print $itemlist $ind_form $gen_form $out

  return
}
#-------------------------------------------------------------------------------
proc pop_print {p {out "stdout"}} {


  puts $out "---------------------- POPULATION PRINT ---------------------------"
  puts $out ""
  puts $out "Generation = [GET $p generation]"
  puts $out ""
  

  pop_print_lite $p $out
  
  # дополнительная инфа ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  set best  [GET $p best]
  
  puts $out ""
  puts $out "STABLE_SIZE = [GET $p lpop] "
  #puts $out "SIZE        = [GET $p size] "
  puts $out "SIZE        = [get_pop_size $p] "
  puts $out "BEST        = $best "
  puts stderr "::gp_dict = [set $::gp_dict]"

  puts $out ""
  
  if {$best != -1 && $best != ""} {

    set best_fit [pop_get_entity_fitness_ $p  $best]
    
    puts $out [format "BEST = $best  (fitness = %f) " $best_fit]
  }
  
  puts $out " "
  puts $out "-------------------------------------------------------------------"

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


# //------------------------------------------------------------------------------
set ::is_print   0

#set ::__is_print 0 ;# false


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
proc ga_entity_seed {pop task adam} \
{

  return [[GET $pop seedproc]  $pop $task $adam]
}
#-------------------------------------------------------------------------------
#   synopsis:	Fills all entities in a population structure with
# 		genes from a user-specified function.
#   parameters:	population *pop
# 		int num			Number of entities to seed.
#   return:	boolean success.
#
#-------------------------------------------------------------------------------
proc  gaul_population_fill {pop task num args} {


  set proc_seed [GET $pop "seedproc"]

  if {$::is_print >= 3} {
    puts ""
    puts "    [procname] ........... num = $num pop = $pop proc_seed = $proc_seed"
    puts ""
  }

  #----------------------------------------------------------
  for {set i 0} {$i < $num} {incr i} {

    set adam [ga_entity_setup $pop] ;# 

    # заполняем структуру элемента
    #  
    $proc_seed  $pop $task $adam


    if {$::is_print >= 3} {

      # проконтролируем печатью
      # 
      puts -nonewline [format "   i = %3d   " $i]
      item_print_ch     $adam "ch=   "
      puts ""
    }
    
    # вообще-то теперь надо добавить в популяцию: 
    # 
    pop_add_entity_ $pop  $adam
    
  }
  #----------------------------------------------------------

  if {$::is_print >= 2} {
    puts ""
  }

  return 1 ;# true
}
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
proc pop_calc_fitness_nov {pop task} \
{

  set itemlist    [GET $pop  "itemlist"] 

  itemlist_calc_fitness_nov  $itemlist $task

  return

  # set fitnessfunc [GET $task "fit_func"]
  # foreach item $itemlist {
  #   item_calc_fitness_nov  $item $fitnessfunc  $task
  # }

  return
}
#-------------------------------------------------------------------------------
proc pop_calc_fitness_all {pop task} {

  set fitnessfunc [GET $task "fit_func"]  
  set itemlist    [GET $pop  "itemlist"] 
  
  foreach item $itemlist {

    item_calc_fitness  $item $fitnessfunc  $task
  }

  return
}
# //------------------------------------------------------------------------------
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

# ------------------------------------------------------------------------------
proc pop_sorting {pop task} {

  if {[get_pop_size $pop] == 0} {
    return ;# если в популяции ничего еще нет !!
  }
  
  set itemlist   [GET $pop  "itemlist"] 
  

  set sort_driver [make_sortdriver_fromtask $task]
  set sortcmd     [list lsort_pop_command $sort_driver]
  
  set itemlist_sorted [lsort -command $sortcmd $itemlist]

  # The implementation of the lsort command uses the merge-sort algorithm which 
  # is a stable sort that has O(n log n) performance characteristics. 

  #set sortcmd "item_qsort_${sort_driver}"
  #set itemlist_sorted [qsort_AF $itemlist $sortcmd] ?? отличия?
  

  SET $pop "itemlist" $itemlist_sorted
  
  SET $pop best 0 ;# после сортировки это должно быть так

  return $itemlist_sorted
}
#-------------------------------------------------------------------------------
# //------------------------------------------------------------------------------
proc pop_initial_fill {pop task  args} {


  set size        [get_pop_size $pop]
  set lpop [GET $pop lpop]

  # если реальный размер популяции меньше заявленного, т.е. еще не все (или вообще
  # никто) агенты инициированны

  if {$size < $lpop} {
    
    gaul_population_fill  $pop $task [expr {$lpop - $size}] 
  }
  
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # Хорошо бы это перенести в .._step
  # 
  #pop_calc_fitness_nov  $pop $task;# если какие-то недосчитаны, то посчитать фитнес
  # 
  # g_stru.jm _05_test  2 10 1
  # g_stru.jm _dc_test  1 5 2  @

  #pop_sorting  $pop $task  

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
proc ga_population_seed {pop task} {

  
  if {$::is_print} {
    puts "[procname]  ......... \n"
  }

  return [gaul_population_fill  $pop $task [GET $pop lpop] ]
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

  set eval_proc [GET $task "fit_func"]

  
  set size [get_pop_size $pop]

  for {set i 0} {$i < $size} {incr i} \
  {
    set e [pop_get_entity_ $pop  $i]

    pop_eval_item $pop $e $eval_proc $task
  }
  
  # а теперь сортируем !!! !!! !!! !!!
  # 

  pop_sorting  $pop $task
  
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


  item_set_fitn  $this_entity "$::GA_NOT_FIT"

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

  set lsrc  [GET $pop lsrc]
  set form  [GET $pop ch_form] 


  set joe [item_create $lsrc]

  SET $joe "ch_form" $form

  item_set_fitn $joe $::GA_NOT_FIT

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


  set tmp [GET $p itemlist] 

  set new_iarray [lreplace $tmp $id $id] ;# удалили элемент списка  

  SET $p itemlist $new_iarray
  
  return
}
# ------------------------------------------------------------------------------
proc get_free_and_init {pop task} {

  set adam [ga_get_free_entity  $pop] 

  ga_entity_seed    $pop $task $adam


#   set evalproc [GET $pop evaluate]
#   $evalproc  $pop $adam 

  set eval_proc [GET $task "fit_func"]

  pop_eval_item $pop $adam $eval_proc $task

  return $adam
}
#-------------------------------------------------------------------------------
proc ga_entity_copy {pop dest src} {

  # у нас тут все просто:
  # 
  item_set_mainsrc $dest [item_get_mainsrc $src]  

  item_set_fitn $dest [item_get_fitn $src]

  return $::true;
}
#-------------------------------------------------------------------------------
proc ga_entity_clone_ {dolly parent} {

  item_set_mainsrc $dolly [item_get_mainsrc $parent]

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
    puts "[procname] ... "
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


  set tmp [GET $p "itemlist"]

  set aleft   [lrange $tmp 0 [expr {$size-1}]]

  SET $p "itemlist" $aleft ;# взяли первые $orig_size
  
  return
}
#-------------------------------------------------------------------------------
#   synopsis:	Kill entities to reduce population size down to
# 		specified value.
#-------------------------------------------------------------------------------
# proc ga_genocide {pop target_size} \
# {

#   pop_to_size  $pop $target_size

#   return $::true
# }
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
      puts "[procname]: size = $size"
      puts ""
      exit
    }


    set size_1 [expr {$size - 1}]

    set fitn_1 [pop_get_entity_fitness_ $pop  $size_1]
    
    set flag1 [expr {$size   > 0}]
    set flag2 [expr {$fitn_1 < $target_fitness}] 

    if {! [expr {$flag1 && $flag2}]} {break}

    puts ""
    puts "[procname]: !!!!!!"
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

  if {[string equal $fit "$::GA_NOT_FIT"]} {
    puts ""
    puts "[procname] ERROR: $message = $fit"
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

  check_fitness  "[procname], afit" $afit
  check_fitness  "[procname], bfit" $bfit

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
  
  #   if ( !(embryo->CH = s_malloc(/* pop->num_chromosomes* */pop->lsrc*sizeof(double))) )
  #     die("Unable to allocate memory");
  
  puts "lsrc = [GET $pop lsrc]"


  # /*   for (i=1; i<pop->num_chromosomes; i++) */
  # /*     { */
  # /*     embryo->chromosome[i] = &(((double *)embryo->chromosome[i-1])[pop->lsrc]); */
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


#   for {set point 0} {$point < [GET $pop lsrc]} {incr point}  \
#   {
#     set ch [get_random_wordchar $char_min $char_max]

#     item_set_chromo_gen $adam $point $ch
#   }


#   return $::true
# }
# //------------------------------------------------------------------------------
# //------------------------------------------------------------------------------
#   ga_compare.c

#   Synopsis:     Routines for comparing entities.
# 		These routines return a distance between two entities.

# //------------------------------------------------------------------------------
#   synopsis:	Compares two char-array genomes and returns their
# 		hamming distance.
#   parameters:	population *pop	Population of entities (you may use
# 			differing populations if they are "compatible")
# 		entity *alpha	Test entity.
# 		entity *beta	Test entity.
#   return:	Returns Hamming distance between two entities' genomes.

# double 
# ga_compare_char_hamming (population *pop, entity *alpha, entity *beta)
# //------------------------------------------------------------------------------
proc ga_compare_char_hamming {pop alpha beta} \
{

  #   int	 /* i, */j;	/* Loop variable over all chromosomes, alleles. */
  #   char	 *a, *b;	/* Pointers to chromosomes. */  
  #   int	 dist = 0;	/* Genomic distance.        */
  set  dist 0

  set a [item_get_mainsrc $alpha]
  set b [item_get_mainsrc $beta]
  
  for {set j 0} {$j < [GET $pop lsrc]} {incr j} \
  {
    set aj [lindex $a $j]
    set bj [lindex $b $j]
    
    set dist [expr {$dist + abs ($aj - $bj)}]
  }

  return $dist
}
# //------------------------------------------------------------------------------
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

  for {set i 0} {$i < [GET $pop lpop]} {incr i} \
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

  #   pop->select_state++;
  SET $pop select_state [expr {[GET $pop select_state] + 1}]
  
  set orig_size    [GET $pop lpop]
  set select_state [GET $pop select_state]

  if {$orig_size < $select_state} \
  {
    return $::true
  }
  
  if {[comm_random_boolean_prob [GET $pop mutation_ratio]]} \
  {
    set mother [pop_get_entity_ $pop [comm_random_int $select_state]]

    return 0 ;# false
  } else {
    return 1 ;# true
  }
  
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

  #   pop->select_state++;
  SET $pop select_state [expr {[GET $pop select_state] + 1}]
  
  set orig_size    [GET $pop  lpop]
  set select_state [GET $pop select_state]

  if {$::is_print} {
    puts "[procname]: "
    puts "orig_size = $orig_size   select_state = $select_state"
  }

  if {$orig_size < $select_state} \
  {
    #puts "!!!!!!!!!!!!!????????????"
    return $::true
  }

  
  if {[comm_random_boolean_prob [GET $pop crossover_ratio]]} \
  {
    set mother [pop_get_entity_ $pop  [comm_random_int $select_state]]
    set father [pop_get_entity_ $pop                   $select_state]

    return 0 ;# false
  } else {
    return 1 ;# true
  }
  
}
#-------------------------------------------------------------------------------
#   synopsis:	Kind of tournament selection.  Choose two random
# 		entities, return the best as the selection.  Selection
# 		stops when
# 		(population size) * (mutation ratio) = (number selected)

# boolean 
# ga_select_one_bestof2 (population *pop, entity **mother)

#-------------------------------------------------------------------------------
# 
# GENETIC ALGORITHMS. COMPARISON OF METHODS FOR SELECTING
# PARENTS FOR CROSSING# 
# Markov Artem Dmitrievich, 2020, 
# 
# Tournament selection - the BEST !!!!!!!!!
# 
#-------------------------------------------------------------------------------
proc ga_select_one_bestof2 {pop &mother} {

  USE_REFS
  
  set orig_size [GET $pop lpop]

  # выбрали двух случайных особей
  # 
  set mother1 [pop_get_entity_ $pop  [comm_random_int $orig_size]]
  set mother2 [pop_get_entity_ $pop  [comm_random_int $orig_size]]
  
  set fit1 [item_get_fitn $mother1] 
  set fit2 [item_get_fitn $mother2]

  # сравним их фитнесы и выберем лучшую особь
  # 
  if {$fit1 > $fit2} {

    set mother $mother1
  } else {
    set mother $mother2
  }

  # увеличиваем этот странный счетчик выбора особи из популяции
  # 
  #set select_state [GET $pop select_state]
  #incr select_state
  #SET $pop select_state $select_state ;# записали обратно

  # кол-во особей будем выбирать в соответсвии с коэффициентом мутации
  # зачем так сложно-то ?
  #set ret [expr {$select_state > ($orig_size * [GET $pop mutation_ratio])} ]
  # может надо проще?
  # 

  #set num_mutate_items [expr {($orig_size * [GET $pop mutation_ratio])} ]
  #set ret [expr {$select_state > $num_mutate_items } ]
  #return $ret

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

  set orig_size [GET $pop lpop]

  set moth_i [comm_random_int $orig_size]
  set mother [pop_get_entity_ $pop  $moth_i]

  set moth_fitness [item_get_fitn $mother]

  set chal_i [comm_random_int $orig_size]
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
    set fath_i [comm_random_int $orig_size]
    if {$moth_i != $fath_i}  {break}
  }

  #set father  [$pop get_entity $fath_i]
  set father  [pop_get_entity_ $pop  $fath_i]

  set fath_fitness  [item_get_fitn $father]
  

  set chal_i [comm_random_int $orig_size]
  set challenger   [pop_get_entity_ $pop  $chal_i];

  set chal_fitness [item_get_fitn $challenger]
 
  #puts "  moth_i= $moth_i  fath_i= $fath_i  chth_i= $chal_i  chal_fitness= $chal_fitness  fath_fitness= $fath_fitness"

  if {$chal_i != $moth_i  &&  $chal_fitness > $fath_fitness} {
    #puts "  ....."
    set father $challenger
    set fath_i $chal_i ;# // сделаем это по факту !?
  }
  
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  if {$::is_print >= 4} {
    puts "  ga_select_two_bestof2 :"
    print_entit  $mother "mother = ($moth_i) ="
    print_entit  $father "father = ($fath_i) ="
  }
  

  #   pop->select_state++;
  #
  #set  s_state [GET $pop select_state]
  #incr s_state
  #SET $pop select_state $s_state

  # истина, если закончился перебор (селекция пар) ?
  # 

  #set c_ratio   [GET $pop crossover_ratio] 
  #set ret [expr {$s_state >   1.0 * $orig_size * $c_ratio} ]
  

  #set num_cross_pairs [expr {($orig_size * [GET $pop crossover_ratio])} ]
  #set ret [expr {$s_state > $num_cross_pairs } ]

  #if {$::is_print >= 4} {
  #  puts "  s_state= $s_state  orig_size= $orig_size  c_ratio= $c_ratio   ret = $ret" 
  #  puts ""
  #}

  #return $ret
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
  set orig_size       [GET $pop lpop]
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
#   synopsis:	Stochastic Universal Sampling selection.
#
#   		pop->mutation_ratio multiplied by pop->orig_size gives
# 		the number of selections which will be performed.
#
# 		This version is for fitness values where 0.0 is bad and
# 		large positive values are good.  Negative values will
# 		severely mess-up the algorithm.

# boolean 
# ga_select_two_sus (population *pop, entity **mother, entity **father)
#-------------------------------------------------------------------------------
# 
proc ga_select_two_sus {pop &mother &father}  {

  USE_REFS

  if {$::ISPRINT} {puts stderr ".................................. 005_1_1"}

  #   double	sum;			/* Fitness total. */
  #   int	*ordered;		/* Ordered indices. */
  #   int	i;			/* Loop variable over indices. */
  
  set ordered "" ;# &
  set oarray  "" ;# &

  #   if (!pop) die("Null pointer to population structure passed.");  
  #   *mother = NULL;
  
  #set orig_size      [GET $pop orig_size]
  set orig_size       [GET $pop lpop]
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
    puts stderr "[procname] ........ "
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

    comm_random_int_permutation  $orig_size  ordered oarray ;# перемешали числа

    
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
# ga_genesis_integer (const int		lpop,
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
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
set ::NEWMUTATE 0
#-------------------------------------------------------------------------------
proc mutate_create {args} {

  #set mutate_proc "ga_mutate_double_singlepoint_drift"

  set mutate_proc [dict_parse $args "-mutate_proc" ga_mutate_double_singlepoint_drift]


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
			lpop      
			num_chromo           
			len_chromo           
			generation_hook      
			iteration_hook       
			data_destructor      
			data_ref_incrementor 
			seedproc                 
			adapt                
			select_one           
			select_two           
			mutate               
			crossover            
			replace              
			userdata             
                      } {


  set pop [GAUL new  -lpop $lpop -lsrc $len_chromo]

  # /*
  #  * Assign population's user data.
  #  */
  #   pop->data = userdata;
  
  # /*
  #  * Define some callback functions.
  #  */
  SET $pop  generation_hook $generation_hook

  #   pop->iteration_hook = iteration_hook;
  SET $pop  iteration_hook $iteration_hook
  
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
  
  SET $pop  seedproc $seedproc    
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

  set len_chromo [GET $pop lsrc]

  # Choose crossover point and perform operation 
  #
  set location [comm_random_int  $len_chromo]
  
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

  set len_chromo [GET $pop lsrc]

  #   /* Choose crossover point and perform operation */

  set location1 [comm_random_int  $len_chromo]

  #   do
  #   {
  #     location2 = random_int (pop->lsrc);
  #   } while (location2 == location1);
  
  while {1} {
    set  location2 [comm_random_int  $len_chromo]
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
proc ga_crossover_integer_singlepoints {pop task  father mother son daughter} {

  set son_CH      "" ;# <---
  set daughter_CH "" ;# <---

  ga_singlepoint_crossover_integer_chromosome  $pop \
    [item_CH $father ] [item_CH $mother]    son_CH  daughter_CH

  item_set_mainsrc $son      $son_CH
  item_set_mainsrc $daughter $daughter_CH

  return
}
# //------------------------------------------------------------------------------
# //  `Mates' two genotypes by randomizing the parents
# //   alleles.
# //   Keeps no chromosomes intact, and therefore will
# //   need to recreate all structural data.
# //------------------------------------------------------------------------------
proc ga_crossover_char_allele_mixing {pop task  father mother son daughter} \
{

  for {set j 0} {$j < [GET $pop lsrc]} {incr j} \
  {
    if {[comm_random_boolean]} \
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
proc ga_crossover_char_singlepoints {pop task  father mother son daughter} \
{

  # наверное имеет смысл просто так
  # 
  ga_crossover_integer_singlepoints  $pop $task  $father $mother $son $daughter


  return
}
# //------------------------------------------------------------------------------
# //  `Mates' two genotypes by double-point crossover of
# //   each chromosome.
# //------------------------------------------------------------------------------
# void 
# ga_crossover_char_doublepoints (CROSSOVER_VALS)
# //------------------------------------------------------------------------------
proc ga_crossover_char_doublepoints {pop task  father mother son daughter} \
{

  
  set len_chromo [GET $pop lsrc]

  #     /* Choose crossover point and perform operation */
  #     location1 = random_int (pop->lsrc);

  set location1 [comm_random_int  $len_chromo]

  #     do
  #     {
  #       location2 = random_int (pop->lsrc);
  #     } while (location2==location1);

  while {1} {
    set  location2 [comm_random_int  $len_chromo]
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
  item_set_mainsrc $son      $son_chromo
  item_set_mainsrc $daughter $dau_chromo

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
  
  set len_chromo [GET $pop lsrc]

  # Choose crossover point and perform operation 

  set location1 [comm_random_int  $len_chromo]

  #   do
  #   {
  #     location2 = random_int(pop->lsrc);
  #   } while (location2==location1);
  
  while {1} {
    set  location2 [comm_random_int  $len_chromo]
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
proc ga_crossover_double_doublepoints {pop task  father mother son daughter} {


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

  item_set_mainsrc $son      $son_CH
  item_set_mainsrc $daughter $daughter_CH

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
proc ga_seed_integer_random {pop task adam}  {

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


  for {set point 0} {$point < [GET $pop lsrc]} {incr point} \
  {
    # ((int *)adam->CH/* chromosome[chromo] */)[point] =
    #   random_int_range(pop->allele_min_integer,pop->allele_max_integer);

    set r [comm_random_int_minmax_1  $amin $amax]

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
proc ga_mutate_integer_singlepoint_drift {pop task  father son} {

  if {$::is_print} {
    puts "  [procname]: "
    #puts ""
  }

  set chromosome [item_get_mainsrc $father]

  item_set_mainsrc $son $chromosome

  #set len_chromo [GET $pop lsrc]

  set len_chromo [llength chromosome]

  set point [comm_random_int  $len_chromo] ;# Index of allele to mutate 
  
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # 
  # Mutate by tweaking a single allele.
  #    
  # ((int *)son->chromosome[chromo])[point] += dir;
  #

  if {[comm_random_boolean]} {
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
#-------------------------------------------------------------------------------
#   synopsis:	Cause a single mutation event in which a single
# 		allele is adjusted.  (Unit Gaussian distribution.)

# void 
# ga_mutate_double_singlepoint_drift (population *pop,
#                                     entity *father, entity *son)

#-------------------------------------------------------------------------------
proc ga_mutate_double_singlepoint_drift {pop task  father son}  {

  if {$::is_print} {
    pop_print $pop
    puts "  [procname] : "
    #puts ""
  }

  #   //int		i;		/* Loop variable over all chromosomes */
  #   //int		chromo;		/* Index of chromosome to mutate */
  #   int		point;		/* Index of allele to mutate */
  #   double	amount=random_unit_gaussian();	/* The amount of drift. (FIXME: variance should be user-definable) */
  set amount [random_unit_gaussian]
  
  #   /* Checks */
  #   if (!father || !son) die("Null pointer to entity structure passed");
  
  set len_chromo [GET $pop lsrc]

  #   /* Select mutation locus. */
  #   /* chromo =  (int) */ random_int(1/* pop->num_chromosomes */);
  comm_random_int 1

  #   //chromo = 0; // (int) random_int(1/* pop->num_chromosomes */);
  #   point  = (int) random_int(pop->lsrc);
  set point [comm_random_int  $len_chromo]

  #   /*
  #     * Copy unchanged data.
  #     */
  #   //i=0;
  #   //for (i=0; i<pop->num_chromosomes; i++)
  #   //{

  #   memcpy(son->CH, father->CH, pop->lsrc*sizeof(double));
  #$son set_chromosome [$father get_chromosome]
  #item_set_mainsrc $son [$father get_chromosome]
  item_set_mainsrc $son [item_get_mainsrc $father]

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
# //****************************************************************************



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
proc cross_to_dau_and_son {pop task  mother father} \
{

  set crossover_proc [GET $pop crossover] ;# !!


  set son [ga_get_free_entity  $pop] ;# создали новых !!!
  set dau [ga_get_free_entity  $pop] ;# 
  
  $crossover_proc $pop $task  $mother $father  $dau $son
  

  if {$::is_print >= 4} {
    
    puts stderr "[procname] .. crossover_proc= $crossover_proc \n"

    print_entit  $mother "mother = "
    print_entit  $father "father = "
    
    print_entit  $dau    "   dau = "
    print_entit  $son    "   son = "       
    
    puts ""
  }
  
  # здесь бы сразу деток посчитать?
  # 
  set eval_proc      [GET $task "fit_func"]

  pop_eval_item  NULL $dau $eval_proc $task
  pop_eval_item  NULL $son $eval_proc $task 
  
  return
}
# //------------------------------------------------------------------------------
# //  synopsis:	Mating cycle. (i.e. Sexual reproduction).
# //  parameters:	population *pop
# //  return:	none
# //------------------------------------------------------------------------------
proc gaul_crossover {pop task args} {
  

  set crossover_ratio [GET $pop crossover_ratio]
  set select_two_proc [GET $pop select_two]
  set eval_proc       [GET $task "fit_func"]
  set crossover_proc  [GET $pop crossover] ;# !!
  
  # здесь обнуляем, т.е. начинаем процедуру выбора (селекции) сначала
  # 
  SET $pop  select_state 0
  
  #set crossover_proc [GET $pop crossover] ;# 
  #
  # TODO: странно, но что-то меняется!
  #        для g_stru.tl _4  10 2 @
  # а дело в том, что crossover_proc - попеременно меняется на каждом шаге!
  # такая вот особенность.
  #   crossover_proc = _4_struggle_crossover
  #   crossover_proc = _4_the_other_struggle_crossover

  # For JIM

  set mother "" ;# ссылка
  set father "" ;# ссылка

  set mother_list {}
  set father_list {}
  #set preparelist 1

  set orig_size [GET $pop lpop]
  set num 0
  set num_cross_pairs [expr {int ($orig_size * $crossover_ratio)} ]
  

 if {$::is_print >= 3} {

   puts "[procname]  : "
   puts ""
   puts "  select_two_proc = $select_two_proc"
   puts "  crossover_proc  = $crossover_proc"  
   puts "  eval_proc       = $eval_proc"
   puts "  crossover_ratio = $crossover_ratio"
   puts "  num_cross_pairs = $num_cross_pairs"
   puts ""
 }  
  if {$crossover_ratio <= 0.0}  { 
    puts "crossover_ratio <= 0.0  !! !return  !!!"
    return 
  }
  

  # готовим пары для скрещивания
  #
  while {1} {

    #set ret [$select_two_proc $pop  mother father] ;# ga_select_two_bestof2
    $select_two_proc  $pop  mother father

    incr num ;# увеличили счетчик
    set ret [expr {$num > $num_cross_pairs } ]

    if {$ret} {break}

    lappend mother_list  $mother
    lappend father_list  $father
  }
  
  # и затем 
  # 
  set l [llength $mother_list]
  
  for {set i 0} {$i < $l} {incr i} {
    
    set mother [lindex $mother_list $i]
    set father [lindex $father_list $i]
    
    cross_to_dau_and_son  $pop $task $mother $father 
  }

  return
}
#-------------------------------------------------------------------------------
#   synopsis:	Cause a single mutation event in which a single
# 		allele is cycled.
#-------------------------------------------------------------------------------
proc ga_mutate_printable_singlepoint_drift {pop task father son}  {


  # son - отпрыск, туда будем формировать мутанта

  # TODO: привести к общему виду с 
  # proc gp_joyprg_mutate {task prg mutprob} {}

  set prg [item_get_mainsrc $father]

  set prg [ga_joyprg_mutate $task $prg] ;# смутировали


  #if {$::is_print >= 4} { 
  #  puts -nonewline stderr "[procname] : "
  #  item_print_ch   $father "father ="
  #  puts            stderr ", point = $point, old = $point_gen_old, new = $point_gen_new \n"
  #}
  
  # print_entit  $mother "mom ="

  ##lset prg  $point $point_gen_new

  item_set_mainsrc    $son  $prg           ;# старая хромосома
  #item_set_chromo_gen $son  $point $point_gen_new ;# записали новое значение гена

  return
}
# ------------------------------------------------------------------------------
# synopsis:	Mutation cycle.  (i.e. Asexual reproduction)
# parameters:	population *pop
# return:	none

# ------------------------------------------------------------------------------
proc mutate_mother_to_dau {pop task mother mutate_proc eval_proc task} {


  set dau [ga_get_free_entity $pop]  ;# создали нового !!!
  
  $mutate_proc $pop $task  $mother $dau
  #
  # например   ga_mutate_printable_singlepoint_drift
  

  # здесь бы сразу мутантку посчитать?
  # 
  pop_eval_item  $pop $dau $eval_proc  $task
  
  if {$::is_print >= 4} {

    print_entit  $mother "mom = "
    print_entit  $dau    "dau = "
    puts ""
  }
  
}
# ------------------------------------------------------------------------------
proc gaul_mutation {pop task args} {


  set mutation_ratio  [GET $pop "mutation_ratio"]
  set select_one_proc [GET $pop select_one] 

  set mutate_proc     [GET $pop mutate]
  set eval_proc       [GET $task "fit_func"]
  
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #
  # попробуем корректировку 

  #puts stderr ""
  #puts stderr "args = $args"
  set mutation_ratio [dict_parse $args "-mutratio" $mutation_ratio]
  ## mutprob
  #set mutprob [dict_parse  $args "-mutprob" 0.5]
  #set mutprob [dict_parse  $args "-nums" 0.5]  ;# -> dict exist !!??? jimtcl ????
  #/home/pilot/MGENA/github/compot/src/common/a-dict.tl:2098: Error: missing value to go with key

  #puts "mutation_ratio = $mutation_ratio"
  #puts ""   SOLBER:   $args -> {*}$args

  #exit
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  if {$mutation_ratio <= 0.0}  { return }  ;# не нужна мутация
  
  # здесь обнуляем, т.е. начинаем процедуру выбора (селекции) сначала
  # 
  SET $pop select_state 0
  

  # Select entities to undergo asexual reproduction, in each case the child will
  # have a genetic mutation of some type.
 
  set mother_list {}
  #set preparelist 1

  # ~~~~~ создаем список подлежащих мутации ~~~~~~~~~~~~~~~~~~~~~
  # 

  set orig_size [GET $pop lpop]
  set num_mutate_items [expr {int ($orig_size * $mutation_ratio)} ]
  set num 0 ;# счетчик для кол-ва мутантов

  set mother "" ;# <-------- & для Jim?
  
  if {$::is_print >= 3} {
    puts "[procname]  : "
    puts ""
    puts "  select_one_proc = $select_one_proc"
    puts "  mutate_proc     = $mutate_proc"  
    puts "  eval_proc       = $eval_proc"
    puts "  mutation_ratio  = $mutation_ratio"
    puts "  num_mutate_items= $num_mutate_items"
    puts ""
  }
  

  while {1} {

    ##set ret [$select_one_proc  $pop mother]  ;# ga_select_one_bestof2
    $select_one_proc  $pop mother

    incr num ;# увеличили счетчик
    set ret [expr {$num > $num_mutate_items } ]

    if {$ret} {break}


    #if {$preparelist} {
    lappend mother_list $mother
    #} else {

    #  mutate_mother_to_dau  $pop $task  $mother $mutate_proc $eval_proc $task  
    #  #
    #  # если сразу мутируем и добавляем в популяцию, то его же в этом цикле
    #  # можем выбрать ? это вроде не очень?
    #}
  }
  

  # ~~~~~ идем по списку и каждого мутируем  ~~~~~~~~~~~~~~~~~~~~~
  # 
  #if {$preparelist} {

  foreach mother $mother_list {

    # основня процедура мутации -  ga_mutate_printable_singlepoint_drift
    #
    # TODO: надо добавить туда сначала 0) 1) а потом и улучшенный 2)  
    # 
    # 0) make_mutant_from_item  $parent $mutprob $task

    # 1) сделаем уникального мутанта (c 10-ти поыток) для этого списка
    # set mutant [make_mutant_unikum  $task $parent $mutprob $sorted_items 10]
    #
    # 2) set item_new [try_mutate_to_best  $deep_mutate $task $item_old $fitn_old]

    #
    mutate_mother_to_dau  $pop $task  $mother $mutate_proc $eval_proc $task   
  }
  #}

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
    puts "[procname] : (scheme = [GET $pop scheme])"
    puts ""
  }

  set o [GET $pop lpop]
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
        adapt_1       $task $pop  $o $s
      }
    
      "GA_SCHEME_LAMARCK_CHILDREN" {
        adapt_2       $task $pop  $o $s
      }

      default {
        puts ""
        puts "[procname]: scheme = $scheme    !!! ERROR"
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

  if {$::is_print > 2} { 
    puts -nonewline stderr "[procname] : "
    puts            stderr "imin = $imin, imax = $imax \n"
  }

  set tmp [GET $p itemlist] 

  set new_iarray [lreplace $tmp $imin $imax] ;# удалили часть списка  

  SET $p itemlist $new_iarray
  
  return
}
# ------------------------------------------------------------------------------
proc ga_elitism_parents_die_exept {pop  num_parents_saves} \
{

  set  imin  $num_parents_saves  ;# сколько родителей оставить
  #
  # а зачем вообще родителей не глядя убивать, может они с хорошим фитнесом ?!

  set  imax  [GET $pop lpop]
  incr imax  -1


  if {$::is_print > 2} { 
    puts -nonewline stderr "[procname] : "
    puts            stderr "num_parents_saves = $num_parents_saves \n"
  }

  # удаляем группу [num_parents_saves, lpop - 1]

  pop_del_entities $pop  $imin $imax 


  if {$::is_print > 2} {
    puts "after  delete_parents_exept_some !"
    puts ""
    pop_print $pop "stderr"
    puts ""
  }


  return
}
# ------------------------------------------------------------------------------
proc GA_ELITISM_PARENTS_SURVIVE {pop} {


}
# ------------------------------------------------------------------------------
proc GA_ELITISM_PARENTS_DIE {pop} {

  ga_elitism_parents_die_exept  $pop 0

}
# ------------------------------------------------------------------------------
proc GA_ELITISM_ONE_PARENT_SURVIVES {pop} {

  ga_elitism_parents_die_exept  $pop 1

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
    puts stderr "[procname] : (elitism = $elitism)"
    puts stderr ""
  }

  switch -- $elitism {

    "GA_ELITISM_PARENTS_SURVIVE"     {GA_ELITISM_PARENTS_SURVIVE     $pop}
    
    "GA_ELITISM_PARENTS_DIE"         {GA_ELITISM_PARENTS_DIE         $pop}    
    "GA_ELITISM_ONE_PARENT_SURVIVES" {GA_ELITISM_ONE_PARENT_SURVIVES $pop}
    
  }

  #     "GA_ELITISM_RESCORE_PARENTS"     {ga_elitism_rescore_parents    $pop}    
  #     "GA_ELITISM_BEST_SET_SURVIVE"    {ga_elitism_best_set_survive   $pop}
  #     "GA_ELITISM_PARETO_SET_SURVIVE"  {ga_elitism_pareto_set_survive $pop}    

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
    
    if {[comm_random_boolean_prob   $migration_ratio]} { 
       
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

  if {$::is_print} {
    puts "[procname] : "
    puts ""
  }


  #   for {set i 0} {$i < $num_pops} {incr i} \
    #   {
  #     set pop [lindex $pops $i]
  #     pop_sorting  $pop $task
  #   }

  gaul_migration_by_pairs  $num_pops $pops


  # сортируем членов каждой популяции, чтобы новые иммигранты ранжировались
  # корректно.
  # FIXME: возможно было бы более эффективно вставлять иммигрантов сразу корректно
  # 
  
  #set sort_driver [make_sortdriver_fromtask $task]


  #   for {set i 0} {$i < $num_pops} {incr i} \
    #   {
  #     set pop [lindex $pops $i]
  #     pop_sorting  $pop $task
  #   }
  
  return
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
# 
# g_stru.jm _05_test  2 10 1
# 
# ------------------------------------------------------------------------------
proc ga_evolution_archipelago {task  num_pops pops nums} {

  set print $::is_print


  for {set i 0} {$i < $num_pops} {incr i} \
  {
    set pop [lindex $pops $i] ;# Current population  
 
    # Score and sort the initial population members.
    #  
    pop_initial_fill $pop $task  

    pop_calc_fitness_nov  $pop $task;# если какие-то недосчитаны, то посчитать фитнес

    #pop_sorting  $pop $task
  }
  

  #  Do all the generations: ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ 
  #
  set generation 0

  set complete ::false ;# Whether evolution is terminated
  

  while {1} {

    #     if {$generation >= $max_generations} {break}
    if {$complete != $::false}   {break}

    # // Migration step.
    # //
    gaul_migration $task  $num_pops $pops
    
    
    #--------------------------------------------------------------------
    for {set i 0} {$i < $num_pops} {incr i} {

      if {$print} {
        puts ""
        puts "CURRENT ISLAND = $i"
        puts ""
      } 

      set pop [lindex $pops $i]

      if {! [pop_evolution  $pop $task -evol "ga_evol"  -nums $nums]} {
	
        set complete TRUE
        break;
      }        

    }
    #--------------------------------------------------------------------
    
    #gaul_migration $task  $num_pops $pops
  } 
  
  return $generation
}
#-------------------------------------------------------------------------------
# g-diff.tl
#-------------------------------------------------------------------------------

#source "p-diff.tl"

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
# lpop : количество особей во всей популяции;
#               это число приближенно кратно 3.
# len :         максимальная длина особей в начальной популяции.
# fitnessfunc : фитнесс-функция (имя Tcl-процедуры).
# mutprob :     вероятность мутации, используемая процедурой 'gp_joyprg_mutate'.
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

  set a0 [comm_random_int_minmax 0 [expr {[llength $a]-1}]]
  set a1 [comm_random_int_minmax 0 [expr {[llength $a]-1}]]

  if {$a0 > $a1} {set t $a0; set a0 $a1; set a1 $t}

  set b0 [comm_random_int_minmax 0 [expr {[llength $b]-1}]]
  set b1 [comm_random_int_minmax 0 [expr {[llength $b]-1}]]  

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
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
proc get_rand_offspring {leaders l} {


  #set x       [myrand 0 [expr {$l - 1}]]
  set x       [comm_random_int_minmax 0 [expr {$l - 1}]]

  set item    [lindex $leaders $x]

  #set parent_prg [item_get_prog $item]
  #return $parent_prg

  #puts "get_rand_offspring: item = $item, prog = [set $item]"
  #exit

  return $item
}
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
proc lsort_pop_command {sort_driver a b} {

  #puts "lsort_pop_command: sort_driver= $sort_driver"

  set a_fit [item_get_fitn  $a]
  set b_fit [item_get_fitn  $b]

  # аоскольку используем функцияю lsort, присоединяем к ней типв "MIN_to_LEFT"
  # 
  set sort_driver lsort_$sort_driver

  return [$sort_driver $a_fit $b_fit] ; # т.е МЕНЬШИЕ будут слева в списке 
}
#-------------------------------------------------------------------------------
# ------------------------------------------------------------------------------

dict_class_create BOT {} {

  ;# _это_перечисление_переменных
  
  name  "BotName"
  task  {}
  pop   ""

} {
  # а это конструктор класса 

  dict_parse_all_minus  $obj {*}$args 
}

#---------------------------------------------------------
proc calc_BOT {obj args} {
    
  set task [dict_parse $args "-task"  [GET $obj "task"]] 
  set nums [dict_parse $args "-nums"] 
  
  set  pop [GET $obj "pop"]
  
  SET $pop "generation" 0
  SET $pop "itemlist"   {}

  #puts "args = $args"

  ga_evolution  $task $pop  $nums -nums $nums {*}$args

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

  set task    [dict_parse $args "-task" ] 
  
  SET $obj "task" $task  

  set pop [POP new  {*}$args]

  SET $obj "pop"  $pop
}

#-------------------------------------------------------------------------------
proc add_offspring {&offsprings offspring l} {

  USE_REFS

  ##lappend offsprings $offspring ;# добавили отпрыска

  if {[llength $offsprings] == $l} {

    return 0 ;# если привысили лимит - выходим ? может перед проверять?
  } 

  lappend offsprings $offspring ;# добавили отпрыска

  return 1
}
#-------------------------------------------------------------------------------
proc make_offsprings_from_items {sorted_items l} \
{

  # генерируем l-штук детей от случайных родителей (всего списка).
  #
  set offsprings {}
  
  while 1 {
    
    if {[llength $offsprings] == $l} break

    set parent0  [get_rand_offspring  $sorted_items $l]
    set parent1  [get_rand_offspring  $sorted_items $l]

    set parent0_src [item_get_main_src $parent0]
    set parent1_src [item_get_main_src $parent1]

    # трюк получения двух значений от функции списком: (здесь чистые prg?)
    # 
    foreach {offspring0_src offspring1_src} \
      \
      [gp_crossover  $parent0_src $parent1_src] break
    
      set s0  [item_make $offspring0_src] 
      set s1  [item_make $offspring1_src] 

    # добавляем отпрысков и смотрим превышение лимита = l:
    # TODO: не добавлять, если уже такоей есть 

    ##puts stderr "parent0_src = $parent0_src, parent1_src = $parent1_src, l = $l"

    if {! [add_offspring  offsprings $s0  $l]} break
    if {! [add_offspring  offsprings $s1  $l]} break
  }
  

  #if {$is_print} {puts "OFFSPRINGS = $offsprings \n"}
   
  return $offsprings
}
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
proc is_this_src_exist {src_new} {

  # проверяем тольков ::gp_dict, поскольку в gp_list "элементраные" !?

  dict for {name namedict} [set $::gp_dict] {

    set src_old [dict get $namedict "src"]
    #puts "is_this_src_exist: name = $name, namedict = $namedict, src = $src"

    if {$src_new == $src_old} {
      return 1;
    }
  }

  return 0;
}
#-------------------------------------------------------------------------------
proc gp_dict_add_by_src {src} {


  #puts "gp_dict_add_item: src = $src"

  #------------------------------------------------
  # проверяем, есть ли уже програ с таким текстом
  # 
  set is_exist [is_this_src_exist $src]
  
  if {$is_exist} {
    # continue
    #  return
    #puts "gp_dict_add_by_src: src exist !!!!!!!! "
    return 0
  }
  
  #------------------------------------------------
  # нет смысла брать исходник в одну функцию!

  if {[llength $src] == 1} {

    return 0
  }

  #------------------------------------------------
  #return

  set name [format "p%03d" $::gp_dict_NUMER]
  
  SET $::gp_dict $name [list src $src]

  if {$::is_print} {
    puts stderr "gp_dict_add_bu_src: src = $src, name = $name, ::gp_dict = [set $::gp_dict]"
  }

  incr ::gp_dict_NUMER

  return 1
}
#-------------------------------------------------------------------------------
proc gp_dict_add_item {item} {


  set src [item_get_main_src $item]
  
  return [gp_dict_add_by_src $src]

}
#-----------------------------------------------------------
proc calc_BOT33  {obj args} {
  
  set task_local [GET $obj "task"]
  set task [dict_parse $args "-task" $task_local] 
  
  set nums [dict_parse $args "-nums" ] 
  

  # создаем начальную популяцию итемов-программ (формат 11 или 22 ??)
  #  

  set  pop [GET $obj "pop"]

  set lpop [GET $pop "lpop"]
  set lsrc [GET $pop "lsrc"]
  

  SET $pop "itemlist" [make_itemlist  $task {*}$args]
  
  pop_evolution_main  $task $pop  {*}$args -evol "gp_evol"  
  
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

  # "MIN" ;# т.е. чем меьше, тем лучше
  # "MAX" 
  # 
  set tobest [GET $task "fit_tobest"]

  set sort_driver "${tobest}_to_LEFT" ;# лучшие в популяции жмем влево

  return $sort_driver
}
#-------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
proc maintest_seed_proc {pop task adam} {

  set gp_list [GET $task "gp_list"]

  set len     [GET $pop lsrc]


  for {set point 0} {$point < $len} {incr point} {
    
    set char_sym [randinstr_MAIN  $gp_list]
    
    #if {$::CHROMOLIST} {

    # а зачем в цифру переводить? нам нужны здесь симыолы, а точнее - строки !!!
    #
    set ch $char_sym 

    #} else {
    #  set ch [scan $char_sym "%c"]  ;# десятичные коды символьных цифр
    #}


    item_set_chromo_gen $adam $point $ch 
    #
    # записывем ген в хромосому в виде эдемента списка
  }

  return $::true
}
# ------------------------------------------------------------------------------
proc pop1_create {args} {


  set lsrc [dict_parse $args "-lsrc"] 
  set lpop [dict_parse $args "-lpop"] 

  set pop [GAUL new  -lpop $lpop -lsrc $lsrc]

  
  SET $pop  generation_hook NULL ;# $generation_hook 
  SET $pop  adapt       NULL ;# $adapt
  SET $pop  mutate      ga_mutate_printable_singlepoint_drift
  SET $pop  crossover   ga_crossover_char_allele_mixing
  SET $pop  replace     NULL ;# $replace   ;#
  
  SET $pop  ch_form "%s " 
  
  SET $pop  scheme           GA_SCHEME_DARWIN
  SET $pop  elitism          GA_ELITISM_PARENTS_DIE

  SET $pop  crossover_ratio  0.9
  SET $pop  mutation_ratio   0.2
  SET $pop  migration_ratio  0.0
  
  SET $pop  seedproc  "maintest_seed_proc"   ;#   $seed_proc 
  
  return $pop
}
# ------------------------------------------------------------------------------

dict_class_create BOT01 {BOT} {

  ;# _это_перечисление_переменных
  
} {
  # а это конструктор класса 

  set pop [pop1_create  {*}$args]
  
  SET $pop  select_one   "ga_select_one_bestof2" ;# "ga_select_one_sus"
  SET $pop  select_two   "ga_select_two_bestof2" ;# "ga_select_two_sus"

  SET $obj pop $pop

  SET $obj "vers" [dict_parse $args "-vers" 0]
}
#---------------------------------------------------------
proc calc_BOT01 {obj args} {
    
  set pop [GET $obj pop]
   
  SET $pop  seedproc "maintest_seed_proc" ;# ??
  
  #------------------

  set task   [dict_parse $args "-task"  [GET $obj "task"]] 
  set nums   [dict_parse $args "-nums"  10] 
  set vers   [dict_parse $args "-vers"  [GET $obj "vers"]]

  puts stderr ""
  
  set  pop [GET $obj "pop"]
  #
  SET $pop "generation" 0
  SET $pop "itemlist"   {}
  
  set ret [ga_evolution  $task $pop  $nums  -nums $nums {*}$args]

  return $ret
}
#-------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
proc dict_incr {obj var incr_val} {


  set val [GET $obj $var]

  set val [+ $val $incr_val]

  SET $obj $var $val

}
# ------------------------------------------------------------------------------
proc result_sort_proc_sum {aa bb} {

  set a_sum [lindex $aa 1]
  set b_sum [lindex $bb 1]

  # возвращаемое значение определяет "желаемый" знак разности левого и правого 
  # 

  if {$a_sum <  $b_sum}  {return -1} ;# т.е МЕНЬШИЕ будут слева в списке 
  if {$a_sum == $b_sum}  {return  0} 
  if {$a_sum >  $b_sum}  {return  1} 

}
# ------------------------------------------------------------------------------
proc result_sort_proc_res {aa bb} {

  set a_sum [lindex $aa 1]
  set b_sum [lindex $bb 1]

  set a_res [lindex $aa 2]
  set b_res [lindex $bb 2]

  # возвращаемое значение определяет "желаемый" знак разности левого и правого 
  # 

  if {$a_res >  $b_res}  {return -1}   ;# т.е БОЛЬШИЕ будут слева в списке 

  if {$a_res == $b_res}  {
    #return  0
    if {$a_sum <  $b_sum}  {return -1} ;# т.е МЕНЬШИЕ будут слева в списке 
    if {$a_sum == $b_sum}  {return  0} 
    if {$a_sum >  $b_sum}  {return  1} 
  } 

  if {$a_res <  $b_res}  {return  1} 

}
#-------------------------------------------------------------------------------
proc maintest_run_print_result {max_generations botobjs result_upvar} {

  upvar $result_upvar result


  set resultlist {}

  dict for {botname obj} [set $botobjs] {

    set sum $result("sum",$botname)
    set ret $result("ret",$botname)

    # сформируем строку списка для дальнейшей сортировки
    # 

    lappend  resultlist [list $botname  $sum $ret]
  }

  # сформировали список имя-сумма
  # и теперь отсортируем его

  if {$max_generations < 0} {
    set sortresult [lsort -command "result_sort_proc_sum" $resultlist] 
  } else {
    set sortresult [lsort -command "result_sort_proc_res" $resultlist] 
  }

  # теперь строки списка уже по ранжиру
  # можемпросто их распечатать

  set n 1

  foreach s $sortresult {

    set botname [lindex $s 0]

    set sum $result("sum",$botname)
    set ret $result("ret",$botname)

    puts [format "%d mesto : %8s, %6d eval, %6d rets"  $n  $botname $sum $ret]
    incr n
  }

  puts ""
  puts "------------------------------------------------"

  return
}
# ------------------------------------------------------------------------------
# 
proc is_this_target {item task} {

  set fit  [item_get_fitn  $item] 

  set fit_target [GET $task "fit_target"]
  set fit_error  [GET $task "fit_error"]

  set delta [expr {abs ($fit - $fit_target)}]

  if {0} {
  puts [format \
          "[procname] : fit_error= $fit_error, fit_target= $fit_target, fit= %5.3f, delta= %5.3f" $fit $delta]
  }

  if {$delta <= $fit_error} {
    return 1 ;#true
  } 

  return 0 ;# false
}
# ------------------------------------------------------------------------------
proc dict_clone {obj} {

  set  obj_new [dict_create]

  set $obj_new [set $obj]

  return $obj_new
}
# ------------------------------------------------------------------------------
# 
proc maintest_run {botobjs  task_correct
                   num_text num_runs max_generations  args} {


  #set num_text [llength $targets]

  # -----------------------------------------------------------------

  for {set t 0} {$t < $num_text} {incr t} {

    #set target_text [lindex $targets $t]

    #puts stderr "t=$t, target_text =  $target_text"

    # ----------------------------------------------------------------- 
    for {set r 0} {$r < $num_runs} {incr r} {
      
      puts ""
      
      # должен уже быть готов список ботов
      # и к каждому боту свое описание задачи 

      # ------------------------------------------------------------
      #       
      dict for {botname obj} [set $botobjs] {
        
        set obj [dict_clone $obj] 

        # клон то получается уже "грязный" ! надо либо здесь чистить
        # 
        #SET $obj pop itemlist {}
        # 
        #set pop [GET $obj "pop"]
        #SET $pop "itemlist" {}
        #SET $obj      "pop" $pop

        #dict_print_real $obj ;# полностью распечатаем
        
        
        #---------------------------------------
        # надо для самого первого прохода, инициировать накоптельную сумму
        #

        if {$t == 0 && $r == 0} {

          set result("sum",$botname) 0
          set result("ret",$botname) 0
        }

        set ::eval_count 0 ;# Number of fitness evaluations performed
        
        #---------------------------------------
        # task уже должен быть задан для этого конкретного бота
        # но нужно поткорректировать вариант
        # 

        set  task [GET $obj task]
        #SET $task "target_text" $target_text

        $task_correct $task $t $r ;# лучше бы так, в общем виде

        #puts "[procname] : size = [GET $task size]"

        #---------------------------------------
        # основной расчет
        #

        #dict_print_real $task
        #exit

        #RUN1 "calc_" $obj -nums $max_generations -is_print 0 -task $task
        RUN1 "calc_" $obj -nums $max_generations -print 1 -task $task
        #RUN1 "calc_" $obj -nums $max_generations -task $task {*}$args
        
        # забираем результаты
        # 
        foreach {num_generations  best_entity  ch_form} \
          [RUN1 "final_" $obj] \
          break
        
        set ret [is_this_target  $best_entity [GET $obj "task"]]

        # теперь напечатаем результаты по этому испытанию       
       
        #set best_fitnes    [item_get_fitn $best_entity] 
        #set best_as_string [item_as_string  $best_entity $ch_form]

        puts ""
        puts -nonewline [format "t=$t, r=$r, "]
        puts -nonewline [format "$botname :  "]
        #puts -nonewline [format "%02d gens,  " $num_generations]
        puts -nonewline [format "%04d eval,  " $::eval_count]
        #puts -nonewline [format "str = %s,  " $best_as_string]
        #puts -nonewline [format "fit = %5.2f " $best_fitnes]        
        puts -nonewline [format "sucsess = %d " $ret]        
        puts ""
        puts "-------------------------------------------------------------------------"
        puts ""
        flush stdout  ;# все данные должны быть выведены

        # и еще нам нужна общая сумма по всем испытаниям (?)
        # 
        incr result("sum",$botname) $::eval_count
        incr result("ret",$botname) $ret

      }
      # закончили цикл по всем ботам
      # ------------------------------------------------------------  
      
      puts ""
      
    } 
    # num_runs (закончили цикл по всем повторам выполнения)
    # -----------------------------------------------------------------  
    
    puts ""
    
  } 
  # num_text (закончили цикл по всем задачам) 
  # ----------------------------------------------------------------- 
  
  maintest_run_print_result  $max_generations $botobjs result
  
  return
}
# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
proc parse_opts_NEW {argv 
                     &lpop &nums &lsrc  
                     def_lpop def_nums def_lsrc} {

  USE_REFS

  #global argv
  #set argv [lrange $argv 1 end]

  set lpop  [dict_parse $argv  "-lpop"   $def_lpop]
  set nums  [dict_parse $argv  "-nums"   $def_nums]
  #set lsrc  [dict_parse $argv  "-size"   $def_lsrc]
  set lsrc  [dict_parse $argv  "-lsrc"   $def_lsrc]

  set print  [dict_parse $argv  "-verb"   0]

  set ::is_print $print

  #------------------------------
  set seed            [dict_parse $argv  "-seed"   23091975]

  if {$seed == "@"} {
    set seed [clock seconds]
  }

  comm_random_seed $seed
  #------------------------------

  return $print
}
#-------------------------------------------------------------------------------
#
# SuperCalc !!!!!!!!!!!!!!!!!!!!!!!!
#
#-------------------------------------------------------------------------------
proc print_one_line {name best_fit {listvalues {}}} {

  #puts [format "%6s :   A = %f  B = %f  C = %f  D = %f   : fitness = %f "  $name \

  puts -nonewline [format "%6s :"  $name]

  foreach v $listvalues {

    puts -nonewline [format "  % 5.3f"  $v]
  }
  puts -nonewline [format "  "]

  puts -nonewline [format ": fit = % 14.12f "  $best_fit]

  puts ""

}
#-------------------------------------------------------------------------------
proc super_de {task seed_proc step_proc args} {

  #set seed_proc "_test_seed"
  #set step_proc "test_generation_callback"


  set s { "DE/best/1/bin" GA_DE_STRATEGY_BEST GA_DE_CROSSOVER_BINOMIAL 1  0.8  0.5  0.5 }

  set lpop  "" 
  set nums  ""
  set lsrc  ""
  set print [parse_opts_NEW  $args   lpop nums lsrc  40 50 4]

  puts ""
  puts "lpop = $lpop"
  puts "nums = $nums"
  puts "lsrc = $lsrc"
  puts ""

  SET $task "len_chromo" $lsrc

  
  set pop [de_run_one  $task $s "" $lpop $nums $lsrc $print \
          $seed_proc $step_proc]
  

  return $pop
}
#-------------------------------------------------------------------------------
proc super_ga {task seed_proc step_proc   args} {

  # здесь уже нормальные словарные параметы вводим ()
  # 
  #   -lpop    -> lpop
  #   -nums    -> nums
  #   -size    -> lsrc
  #   -verb    -> print
  #   -seed    -> seed
  

  set lpop ""
  set nums ""
  set lsrc      ""
  set print [parse_opts_NEW  $args lpop nums lsrc  200 500 4]

  #-------------------------------------------

  SET $task "len_chromo" $lsrc

  set pop [ga_genesis_main  \
             $task                              {*}[NB                 ] \
             $lpop		                {*}[NB                 ] \
             1			                {*}[NB  num_chromo     ] \
             $lsrc     			        {*}[NB  len_chromo     ] \
             $step_proc                         {*}[NB  generation_hook] \
             NULL			        {*}[NB  iteration_hook ] \
             NULL			        {*}[NB  data_destructor] \
             NULL			        {*}[NB  data_ref_incrementor] \
             $seed_proc		                {*}[NB  seed           ] \
             NULL			        {*}[NB  adapt          ] \
             ga_select_one_bestof2	        {*}[NB  select_one     ] \
             ga_select_two_bestof2	        {*}[NB  select_two     ] \
             ga_mutate_double_singlepoint_drift {*}[NB  mutate         ] \
             ga_crossover_double_doublepoints   {*}[NB  crossover      ] \
             NULL			        {*}[NB  replace        ] \
             NULL			        {*}[NB  User data      ] \
            ]

  ga_population_set_parameters \
    $pop	               {*}[NB population      ] \
    GA_SCHEME_DARWIN	       {*}[NB ga_scheme_type  ] \
    GA_ELITISM_PARENTS_SURVIVE {*}[NB ga_elitism_type ] \
    0.8			       {*}[NB crossover       ] \
    0.2			       {*}[NB mutation        ] \
    0.0      	               {*}[NB migration       ] 
                               

  ga_population_seed $pop $task
  
  ga_evolution  $task $pop $nums   -nums $nums -print $print {*}$args	 
  
  #puts ""
  return $pop

}
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
# обрабатываем популяцию, выделяя паттерны в библиотеки.
# 
# 
#-------------------------------------------------------------------------------
proc works_on_gp_dict {sorted_items} {

  # но пока самы простейший случай - берем самого успешного итема и делаем
  # его исходник частью библиотеки/
  # не сильно улучшает, если искать среди всего списка?

  # TODO:
  # 
  # - по всему списку успешных программ выбирать максимально совпадающие шаблоны
  # - обновлять статистический рейтин?
  # - обновлять статистику контекста?
  # - удалять уже не актуальные?
  

  if {1} {

    set item [lindex $sorted_items 0] ;# будем пока брать лучшиего
    set src [item_get_main_src $item]
      
    set add_ok [gp_dict_add_by_src $src] ;# 0 - такой src уже есть, 1 - норм

  } else {

    foreach item $sorted_items { 
      #set item [lindex $sorted_items 0] ;# будем пока брать лучшиего    
      #set src [item_get_main_src $item]
      #set add_ok [gp_dict_add_by_src $src] ;# 0 - такой src уже есть, 1 - норм
      
      #if {$add_ok} {
      #break
      #}
    }
  }
  
  return
}
#-------------------------------------------------------------------------------
# создание новой популяции на основе списка лидеров (меньшего размера)
# циклическим клонированием
# 
#-------------------------------------------------------------------------------
proc cyclic_clone_from_leaders {leaders_items new_len} {

  set new_items {} ;# будем формировать новую популяцию длиной 'new_len'

  set old_len [llength $leaders_items]

  if {$::is_print >= 2} {
    puts -nonewline stderr "cyclic_clone_from_leaders: old_len= $old_len, new_len= $new_len:  "
  }

  set       j 0 ;# индекс по списку лидеров

  while {1} {

    if {[llength $new_items] ==  $new_len} {break} ;# достигли резудьтата, заканчиваем

    if {$j == $old_len} { ;#          завершился список лидеров     
      set j 0 ;# продолжим клонирование с начала списка лидеров
      
      if {$::is_print >= 2} {puts -nonewline stderr "_ "}
    }

    lappend new_items [lindex $leaders_items $j]

    incr j
    
    if {$::is_print >= 2} {puts -nonewline stderr "$j "}
  }

  if {$::is_print >= 2} {puts stderr ""}

  #exit ;# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! for DEBUG

  return $new_items
}
# ------------------------------------------------------------------------------
# основная эволюционная программа (для GA)
#
# r~.tl TEST TEST_xx -seed 2013 -lpop 10 -size 6 -nums 10 -vers ga
# 
#-------------------------------------------------------------------------------
proc ga_evol {pop task args} {

  
  #puts stderr "args = $args"; exit

  # 1) Crossover step 
  #  
  gaul_crossover $pop $task {*}$args


  # выбираются мама и папа и затем скрещиваются 
  # в новых (созданных) членов общества !!
  
  #if {$::is_print > 2} {pop_print $pop "stderr" ; puts ""}

  #-----------------------------------------------------------------
  # 2) Mutation step
  #  

  gaul_mutation $pop $task {*}$args  ;# муитруем в новых членов общества !!
  
  #if {$::is_print > 2} {pop_print $pop "stderr" ; puts ""}

  #-----------------------------------------------------------------
  # 3) Apply environmental adaptations, score entities, sort entities, etc.
  #  
 
  ##  gaul_adapt_and_evaluate $pop $task 
  
  #if {$::is_print > 2} {pop_print $pop "stderr" ; puts ""}

  #-----------------------------------------------------------------
  # 4) Survival of the fittest (выживание наиболее приспособленных)
  # 
  # GA_ELITISM_PARENTS_DIE     (FS)
  # GA_ELITISM_PARENTS_SURVIVE (_2_main_ 

  # удаляем лузеров ? ничего подобного! просто удаляем почти всех родителей! зачем?
  #
  #gaul_survival $pop 
   
 
  #if {$::is_print > 2} {pop_print $pop "stderr" ; puts ""}

  return
}
#-------------------------------------------------------------------------------
# основная эволюционная программа (для GP)
#
# r~.tl TEST TEST_xx -seed 2013 -lpop 10 -size 6 -nums 10 -vers gp
# 
# r~.tl ANTS ANTS_gp_new -lpop 10 -lsrc 5 -nums 10 -print 3 -pole pole_20a5 
# 
#-------------------------------------------------------------------------------
proc gp_evol {pop task args} {

  #puts stderr ""
  #puts stderr "args = $args"
  #puts stderr ""

  # предполагается что итемы тут уже отсортированы !!
  # 
  set sorted_items [GET $pop "itemlist"]

  # это слишком простой вариант, нужно сначала добавлять, потом
  #            пересчитывать и потом уже убивать слабых ?

  set len       [llength $sorted_items]
  set orig_size [GET $pop lpop]


  set lidprob [dict_parse  $args "-lidprob" 0.5]
  set mutprob [dict_parse  $args "-mutprob" 0.5]
  set offprob [dict_parse  $args "-offprob" 0.0]

  set l [expr {int ($len * $lidprob) }] ;#  размер лидирующей группы 
  set o [expr {int ($len * $offprob) }] ;;# сгенерим столько же отпрысков от лидеров
  #set m [expr {$len - $l}]  ;# сделаем сколько-то мутантов ??
  #set m [expr {$len * $mutprob}] ;# num_ 
  set m [expr {int ($orig_size * $mutprob) }] ;# num_  

  #---------------------------------------
  # 1)
  # выделяем лидеров популяции  (1/3)

  set leaders_items [lrange $sorted_items   0 [expr { $l - 0 }]]
  
  #---------------------------------------

  if {$::is_print >= 2} {
    puts stderr ""
    puts stderr "[procname]: len = $len, l = $l --------------------- BEGIN ------"
    puts stderr ""
    puts stderr "lidprob = $lidprob, l = $l"
    puts stderr "mutprob = $mutprob, m = $m"
    puts stderr "offprob = $offprob, o = $o"
    puts stderr ""
  }
   
  #---------------------------------------
  # 2) выделяем библиотечные шаблоны

  if {$::gp_AUTO} {

    works_on_gp_dict  $leaders_items
  }

  #---------------------------------------
  # 2) CROSSOVER
  # генерируем другую 1/3  популяции отпрысками от случайных лидеров
 
  set offsprings_items {}
  

  if {$::gp_NEWS} {

    set o 0 ;# не будем кроссовить !!
    set offsprings_items {}

  } else {

    #set o 0 ;### $l ;# сгенерим столько же отпрысков от лидеров
    set offsprings_items  [make_offsprings_from_items  $sorted_items $o]
    #set offsprings_items {}
  }
 
  #---------------------------------------
  # 3) MUTATION
   
  if {$::gp_NEWS} {

    # совсем новый механизм: (форк от лучших и затем мутация)

    # TODO: клонировать с рефакторингом (::gp_AUTO)
    # 
    set pop_items [cyclic_clone_from_leaders  $leaders_items $len]

    set pop_items [try_mutate_for_all_items   $pop_items $task $::gp_DEEP]

  } else {
    
    #puts stderr "[procname] : m = $m"
    #set num_mutate_items [expr {($orig_size * [GET $pop mutation_ratio])} ]

    set mutated_items  [make_mutated_from_items  $task $sorted_items $m]
    
    #dict_print_real_all_in_list  "[procname]"  $mutated_items
      
    #---------------------------------------
    # 4) 
    # склеиваем три популяции итемов (лидеров, отпрысков, мутантов)
    # создавая популяцию исходников для следующей итерации.
    #
    
    set pop_items   [concat $leaders_items   $offsprings_items   $mutated_items]  
 
    #set pop_items   [concat  $leaders_items  $mutated_items]   
    #set pop_items   [concat  $sorted_items  $mutated_items]   
  }

    
  #---------------------------------------
  # записываем их в популяцию

  SET $pop "itemlist" $pop_items


  #if {$::gp_AUTO} {
  #if {$::is_print >= 2} {
  #  #puts ""
  #  #puts stderr "  ::gp_dict = [set $::gp_dict]"
  #}
  #}
  if {$::is_print >= 2} {
    #puts stderr ""
    puts stderr "[procname]: ------------------------------------ FINAL ------"
    puts stderr ""
  }
   
  return $pop_items
}
# ------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
proc gp_pop_all_print {pop} {

  set itemspop   [GET $pop  "itemlist"] 
  set ind 1
  
  puts ""
  foreach item $itemspop {

    item_print_fitness  $item $ind ;###$fitnessfunc 
    incr ind
  }
  puts ""

  return
}
#-------------------------------------------------------------------------------
proc print_item_for_step {item i task  game_print_proc} {

  set fitnessfunc [GET $task "fit_func"]  

  set prg [item_get_main_src  $item]
  set ftn [item_get_fitn      $item]


  puts [format "step %03d)  best= % 7.3f :   $prg " $i $ftn ]
  
  # здксь печатаем пользовательскую картинку, типа поля игрового
  # 
  
  if {$game_print_proc != 0}  {
    
    item_calc_fitness  $item $fitnessfunc  $task
    
    $game_print_proc  
  }
 
  return
}
# ------------------------------------------------------------------------------
proc pop_print_step_info {pop task args} {

  
  set printproc [dict_parse $args "-printproc" 0]
  
  set i         [GET $pop  generation]
  set itemlist  [GET $pop  "itemlist"] 
  set best_item [lindex $itemlist 0]
  
  print_item_for_step  $best_item $i  $task $printproc
  
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
proc is_check_generation_break {pop task max_generations} {

  set generation [GET $pop  "generation"]
  set fit_target [GET $task "fit_target"]
  set fit_error  [GET $task "fit_error"]

  set item0  [pop_get_entity_ $pop  0] ;# лучший итем?

  set fitn0  [item_get_fitn   $item0]
  set fitn0  [format "%7.3f"  $fitn0]  

  set index  [format "% 3d"   $generation]
  
  if {$::is_print >= 1} {
    
    #     if {$is_print >= 2} {puts ""}
    #     puts -nonewline [format "  step %3d  ...  f0 = $fitn0  " $index]
    #     item_print_ch     $item0 "i0 =  "
    #     puts ""
    #     if {$is_print >= 2} {puts ""}
    
  } else {
    
    set ret [generation_hook_check $pop $generation]
  }
  
  
  if {$max_generations == -1} { 
    #
    # нщем целевое значение фитнеса fit_target
    
    set delta [expr {abs ($fitn0 - $fit_target)}]
    if {$delta <= $fit_error} {
      return 1 ;#true
    } 
    
  } else {
    if {$generation >= $max_generations} {
      return 1 ;# true
    } 
  }
  
  return 0 ;# false
}
# ------------------------------------------------------------------------------
# основная программа вызова "эволюционной" функции
# ------------------------------------------------------------------------------
proc pop_evolution {pop task  args} {


  set nums   [dict_parse $args "-nums"] 

  if {$::is_print >= 2} {gp_pop_all_print $pop}

  #-----------------------------------------------------------------

  # если какие-то недосчитаны, то посчитать фитнес
  # 
  if {$::is_print >= 2} {
    puts stderr "\n   pop_calc_fitness_nov ............. \n"
  }

  pop_calc_fitness_nov  $pop $task

  if {$::is_print >= 2} {
    gp_pop_all_print $pop
  }
  #-----------------------------------------------------------------

  # сортируем всех челнов популяции по фитнесу
  #  
  if {$::is_print >= 2} {
    puts stderr "\n   pop_sorting ...................... \n"
  }

  pop_sorting  $pop $task

  if {$::is_print >= 2} {
    gp_pop_all_print $pop
  }
  #----------------------------------------------

  # кое-что напечатаем
  #
  if {$::is_print >= 1} {
    pop_print_step_info  $pop $task {*}$args
  }
  
  # проверяем не пора ли закончить цикл (с учетом номера, -1, и фитнеса)
  #   
  if [is_check_generation_break  $pop $task $nums] \
    { 
      return false
    }
  
  #----------------------------------------------
  # EVOLUTION !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

  if {$::is_print >= 2} {
    puts stderr "\n   pop_evolution  ...................... \n"
  }

  set evolfunc  [dict_parse $args "-evol"  "NOTEVOLFUNC"]

  #puts stderr "args = $args"; exit

  $evolfunc $pop $task {*}$args
 
  if {$::is_print >= 2} {
    gp_pop_all_print $pop
  }

  # ga_evol 
  #   if        {$evolfunc == "ga_evolution_func"} {
  
  #     ga_evolution_func  $pop $task {*}$args 
  #     #gp_evolution_func  $pop $task {*}$args  -mutprob 0.0
  
  #   } elseif  {$evolfunc == "gp_evolution_func"} {
  
  #     if {0} {
  #       # TODO 
  #       #ga_evolution_func  $pop $task {*}$args 
  
  #       SET $pop  select_one   "ga_select_one_bestof2"
  #       SET $pop  select_two   "ga_select_two_bestof2"
  #       SET $pop  seedproc     "maintest_seed_proc"
  #       SET $pop  crossover    "ga_crossover_char_allele_mixing"
  
  #       SET $pop  crossover_ratio 0.5
  
  #       # Score and sort the initial population members.
  #       # инициация итемов функцией [GET $pop seedproc] 
  #       #  
  #       #pop_initial_fill  $pop $task 
  
  #       gaul_crossover $pop $task 
  #       gaul_mutation  $pop $task 
  #     }
  
  
  #     gp_evolution_func  $pop $task {*}$args 
  
  #   } else {
  #     puts "ERROR !!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
  #   }
  #----------------------------------------------

  ###  !! pop_calc_fitness_nov  $pop $task;# если какие-то недосчитаны, то посчитать фитнес

  # 5) сортируем всех челнов популяции по фитнесу
  #  
  pop_sorting  $pop $task

  # 6) Убиваем наименее приспособленных членов популяции, чтобы восстановить 
  # численность до ее стабильного первоначального размера.
  # 
  pop_to_size  $pop [GET $pop lpop] ;# удаляем лузеров ?

  #----------------------------------------------
  
  set generation [GET $pop "generation"]  
  incr generation
  SET $pop generation $generation ;# увеличили счетчик поколений
  
  
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
proc pop_evolution_main {task pop args} {

  # Do all the generations:
  # 
  # Stop when (a) max_generations reached, or
  #           (b) "pop->generation_hook" returns FALSE.  
 
  SET $pop "generation" 0


  #------------------------------------------------
  while {1} {

    if {$::is_print > 2} {
      puts "\n\n"
      puts stderr "[procname] : ~~~~ BEGIN ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ !!!!!!!!!! \n"
    }
    
    set ret [pop_evolution  $pop $task  {*}$args]
    
    if {$::is_print > 2} {
      puts ""
      pop_print $pop "stderr" ; 
      puts ""
      puts stderr "[procname] : ~~~~ FINAL ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ !!!!!!!!!! \n"
      puts ""
    }
    
    if {! $ret} {break;}
    
    ##if {$::is_print >= 2} {pop_print $pop "stderr"}
    
  } 
  # /* Generation loop. */
  #------------------------------------------------
  
  if {$::is_print > 2} {

    puts ""
    puts ""
    puts ""
    puts "FINAL RESULT: "
    puts ""
    pop_print $pop
    puts ""
  }

  return [GET $pop "generation"]
}
# //------------------------------------------------------------------------------
proc ga_evolution {task pop nums args} {


  # Score and sort the initial population members.
  # инициация итемов функцией [GET $pop seedproc] 
  #  
  pop_initial_fill  $pop $task 
 
  if {$::is_print > 2} {
    pop_print $pop
    #puts ""
  }

  ##set nums [dict_parse $args "-nums" 10]

  set generation [pop_evolution_main  $task $pop  -nums $nums {*}$args \
		    -print $::is_print -evol "ga_evol"]

  return $generation
}
# //------------------------------------------------------------------------------
###########################################################################################
#-------------------------------------------------------------------------------
proc run_gp_evolution_for_task {
                       task     
                       args
                     } {

  #set seed   [dict_parse $args "-seed" 2013]
  set seed   [dict_parse $args "-seed" @]

  set lpop   [dict_parse $args "-lpop" 10]
  set lsrc   [dict_parse $args "-lsrc"  6] 
  set nums   [dict_parse $args "-nums" 10]
  puts ""
  puts "nums  = $lpop"  ;# колич-во ботов
  puts "lsrc  = $lsrc"  ;# макс. длина ботов (при начальном старте?)
  puts "nums  = $nums"  ;# шагов эволюции  
  puts ""

  #-------------------------------------


  puts stderr "args = $args"

  #set seed  [dict_parse $args "-seed" 2013]
  #set lpop  [dict_parse $args "-lpop"   10]
  #set lsrc  [dict_parse $args "-lsrc"    6]
  ###set nums  [dict_parse $args "-nums"  2]  

  #-------------------------------------
  if {$seed == "@"} {

    set seed [clock seconds]
  }
  #puts "[procname] : seed = $seed !!!!!!!!!!!"

  comm_random_seed $seed 

  #-------------------------------------

  set pop [POP new  {*}$args  -printchform  "% s " ]


  # создаем начальную популяцию итемов-программ (формат 11 или 22 ??)
  #  
  SET $pop "itemlist" [make_itemlist  $task {*}$args]
  
  pop_evolution_main  $task $pop  {*}$args -evol "gp_evol"  
  

  return
}
#-------------------------------------------------------------------------------
#set ::ITEMS_LIST 1
#-------------------------------------------------------------------------------
proc FITPROC_list_FS {list_calc task} {


  #if {$::ITEMS_LIST} {
  set list_calc  [item_get_mainsrc $list_calc]
  #}

  set list_true $::target_text  ;# это список

  set len_true [llength $list_true]
  set len_calc [llength $list_calc]

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
#-------------------------------------------------------------------------------
proc gp_fitness_test {item} {

  set task NULL

  set item [item_make $item]

  puts "item = [item_get_mainsrc $item],  ret = [FITPROC_list_FS  $item $task] "

}
#-------------------------------------------------------------------------------
proc _gp_test {} {

  # FINS STRUCT - ищем пока простто структуру
  #set ::target_text "122333444455555"

  #set ::target_text "1 2 2 3 3 3 4 4 4 4 5 5 5 5 5"
  set ::target_text "1 2 3 4"

  global argc

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  if {$argc == 1} {


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

  } else {
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    global argc argv argv0
    set argv [lrange $argv 1 end]

  }
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  #set randpop_proc "make_rand_prgpop" ;# "make_rand_prgpop_unikum"    
  #set ::randinstr  "randinstr_MAIN"
  #set ::len_is_constant 1 ;# g-corB.tl -> make_prgpop : постоянной длины

  set  fitnessfunc  "FITPROC_list_FS"

  set ::is_print 1
  set gp_list   "1 2 3 4 5 6 7 8 9" ;#   

    
  set task [task_create "-fit_func" $fitnessfunc "-fit_tobest" MAX -gp_list $gp_list]
  
  set seed   [dict_parse $argv "-seed" 2013]
  dict_parse_GLOBAL "::is_print" $argv


  run_gp_evolution_for_task \
    $task \
    {*}$argv
   

  return
}
#-------------------------------------------------------------------------------

# p_stru.tl _gp_test  -seed 2013 -lpop 10 -size 6 -nums -1

# r~.tl TEST TEST_xx  -seed 2013 -lpop 10 -size 6 -nums -1 -vers ga
# r~.tl TEST TEST_xx  -seed 2013 -lpop 10 -size 6 -nums -1 -vers gp

#-------------------------------------------------------------------------------
#
# TODO
# 
# - объединить функции в одну, добавив управление через общие вызовы и параметры
#   (цель - боле универсальный поиск алгоритмов, испольщующий как стандартные
#   адгоритмы GA + GP, так  новые стековые с перестановками.
# 
###########################################################################################
