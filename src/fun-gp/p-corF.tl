# -*-   mode: tcl  ; coding: koi8   -*- ----------------------------------------

# //----------------------------------------------------------------------------

# //****************************************************************************

#source "p-detw.tl"

#ga_deterministiccrowding.c

# //****************************************************************************

#   ga_deterministiccrowding - Deterministic crowding.

#   synopsis:     Sets the deterministic crowding parameters for a
# 		population.
#   parameters:	population *pop		Population to set parameters of.
# 		const GAcompare		Callback to compare two entities.
#   return:	none
# //------------------------------------------------------------------------------
proc ga_population_set_deterministiccrowding_parameters {pop compare} \
{

  SET $pop dc_params_compare  $compare

  return
}
# //------------------------------------------------------------------------------

#   synopsis:	Performs optimisation of the given population by a
# 		method known as determinstic crowding.
# 		ga_genesis(), or equivalent, must be called prior to
# 		this function.
# 		This approach is useful when you desire a
# 		significant amount of diversity in the resulting
# 		population.
# 		This was designed as a niching algorithm rather than
# 		an optimisation algorithm.

# 		During a generation, children potentially replace
# 		their parents as soon as they are created, rather
# 		than replacing them at the end of the generation.
# 		This differs slightly from the canonical
# 		deterministic crowding algorithm.

# //------------------------------------------------------------------------------
proc swap_i_rank {pop i rank} \
{
  
  set this_entity [pop_get_entity_ $pop  $i]
  
  pop_set_entity_ $pop   $i [pop_get_entity_ $pop  $rank] 
  
  pop_set_entity_ $pop   $rank $this_entity

  return
}
# //------------------------------------------------------------------------------
proc swap_one_child {pop i parent child ind} \
{

  set rank [pop_get_entity_id  $pop $child]
  
  if {[item_get_fitn $child] < [item_get_fitn $parent]} \
  {
    swap_i_rank  $pop $ind $rank
  }
  
  pop_del_entity_by_id $pop $rank
  
  return
}
# //------------------------------------------------------------------------------
proc main_swap_childs {pop i father mother son daughter permutation} \
{

  swap_one_child  $pop $i $mother $daughter $i

  swap_one_child  $pop $i $father $son     [lindex $permutation $i]

  return
}
# //------------------------------------------------------------------------------
proc mutation_step {pop task child} \
{

  if {[comm_random_boolean_prob [GET $pop mutation_ratio]]} \
  {
    
    set this_entity [ga_get_free_entity $pop]
    [GET $pop mutate]  $pop $task  $child $this_entity
    
    pop_del_entity  $pop $child
    set child $this_entity
  }
  
  return $child
}
# //------------------------------------------------------------------------------
proc ga_deterministiccrowding {task pop max_generations} \
{

  set generation 0

  set eval_proc      [GET $task "fit_func"]
  set mutate_proc    [GET $pop  "mutate"]
  set crossover_proc [GET $pop  "crossover"]

  set compare_proc   [GET $pop  "dc_params_compare"]

  if {$eval_proc      == "NULL"}  {die "Population's evaluation callback is undefined."}
  if {$mutate_proc    == "NULL"}  {die "Population's mutation callback is undefined."}
  if {$crossover_proc == "NULL"}  {die "Population's crossover callback is undefined."}  
  if {$compare_proc   == "NULL"}  {die "Population's comparison callback is undefined."}
  

  SET $pop "generation" 0
  
  pop_initial_fill $pop $task
  
  set size [get_pop_size $pop]

  for {set i 0} {$i < $size} {incr i} {
    lappend  ordered $i
  }
  
  # ---------------------------------------------------------------------
  # 
  while {1} \
  {
  
    pop_calc_fitness_nov  $pop $task;# если какие-то недосчитаны, то посчитать фитнес
    pop_sorting  $pop $task
    
    # --------------------------------------------------

    if [is_check_generation_break  $pop $task \
          $max_generations ] {
      
      return false
    }
  
    # --------------------------------------------------

    
    if {$::is_print} {
      puts "ordered     = $ordered"
    }
    
    set permutation {}
    comm_random_int_permutation  $size  ordered  permutation 
    #
    # сделаем как в оригинале пока, т.е. с изменением исходного ordered, но
    # это довольно странно !
    
    if {$::is_print} {
      puts "permutation = $permutation"
    }

    for {set i 0} {$i < $size} {incr i} \
    {
      set perm_i [lindex $permutation $i]
      
      set mother   [pop_get_entity_    $pop       $i];
      set father   [pop_get_entity_    $pop  $perm_i];
    
      set son      [ga_get_free_entity $pop]
      set daughter [ga_get_free_entity $pop]

      $crossover_proc  $pop $task  $mother $father $daughter $son
      
      #  // Mutation step.
      #  //
      
      set daughter [mutation_step  $pop $task $daughter]
      set son      [mutation_step  $pop $task $son]
      
      #  // Apply environmental adaptations, score entities, sort entities, etc.
      #  // FIXME: Currently no adaptation.
      #  //
      pop_eval_item  $pop $daughter $eval_proc $task
      pop_eval_item  $pop $son      $eval_proc $task
      
      #  // Evaluate similarities.
      #  //
      set md [$compare_proc  $pop $mother $daughter]
      set fs [$compare_proc  $pop $father $son]

      set dist1 [expr {$md + $fs}]
      
      set ms [$compare_proc  $pop $mother $son]
      set fd [$compare_proc  $pop $father $daughter]

      set dist2 [expr {$ms + $fd}]
      

      if {$::is_print} {
        puts [format "i= $i  dist1= %7.2f  dist2= %7.2f" $dist1 $dist2]
      }

      #  //
      #  // Determine which entities will survive, and kill the others.
      #  //
      if {$dist1 < $dist2} \
      {
        main_swap_childs  $pop $i $father $mother $son $daughter $permutation
      } else {
        main_swap_childs  $pop $i $father $mother $daughter $son $permutation
      }
      
    } ;# for {set i 0} {$i < $size} {incr i}

    # --------------------------------------------------
    
    set generation [GET $pop "generation"]    
    incr generation
    SET $pop generation  $generation
    
  } ;# while
  # 
  # ---------------------------------------------------------------------
  
  #   // Ensure final ordering of population is correct.
  #   //
  pop_sorting  $pop $task
  
  
  return $generation
}


# //****************************************************************************
# //****************************************************************************
# //****************************************************************************

# source "p-diff.tl"

#-------------------------------------------------------------------------------
#
if [info exists ::G_DIFF_TL] {
  return
} else {
  set  ::G_DIFF_TL ""
}

#-------------------------------------------------------------------------------
# /**********************************************************************
#   ga_de.c

#   ga_de - Differential Evolution.

#   Synopsis:     Differential Evolution.

# 		The DE algorithm was originally conceived by Rainer
# 		Storn and Ken Price.  The GAUL implementation is
# 		based in part on their "de36.c" reference source code.
# 		See http://www.icsi.berkeley.edu/~storn/code.html

# 		You may notice that this code includes equivalents of
# 		all of the original DE strategies along with a
# 		selection of additional strateties.

  # /*
  #   pop->de_params->weighting_factor = random_double_range(-2.0, 2.0);
  # */
  # /*
  #  * This is a easy method for implementing randomly selected
  #  * scaling factor (F in original paper) for each generation, as
  #  * suggested in:
  #  *
  #  * Karaboga D., Okdem, S. "A simple and global optimization algorithm
  #  * for engineering problems: differential evolution algorithm",
  #  * Elec. Engin. 12:53-60 (2004).
  #  *
  #  * Uncomment, if desired.
  #  */


#-------------------------------------------------------------------------------
# 
# Differential evolution parameter structure.
# 

# dictrecord define GA_DE_T {

#   de_strategy         ;#-#	Selection strategy;                
#   de_crossover_method ;#-#	Crossover strategy;                
#   de_num_perturbed    ;#-#	Number to perturb;                 
#   de_crossover_factor ;#-#	Crossover ratio;                   
#   de_weighting_min    ;#-#	Minimum crossover weighting factor;
#   de_weighting_max    ;#-#	Maximum crossover weighting factor;

# }

#  **********************************************************************/

#   synopsis:     Sets the differential evolution parameters for a
# 		population.
#   parameters:	population *pop		Population to set parameters of.
# 		const GAcompare		Callback to compare two entities.
#   return:	none
#  **********************************************************************/
# void 
# ga_population_set_differentialevolution_parameters (population *pop,
#                                                     const ga_de_strategy_type strategy,
#                                                     const ga_de_crossover_type crossover,
#                                                     const int num_perturbed,
#                                                     const double weighting_min,
#                                                     const double weighting_max,
#                                                     const double crossover_factor)

# ------------------------------------------------------------------------------
proc ga_population_set_differentialevolution_parameters {pop            
                                                    strategy            
                                                    crossover           
                                                    num_perturbed       
                                                    weighting_min       
                                                    weighting_max       
                                                    crossover_factor} {

  set DE [dict_create]

  #--------------------------------------------------

  SET $DE de_strategy           $strategy
  SET $DE de_crossover_method   $crossover
  SET $DE de_num_perturbed      $num_perturbed
  SET $DE de_weighting_min      $weighting_min
  SET $DE de_weighting_max      $weighting_max
  SET $DE de_crossover_factor   $crossover_factor

  #--------------------------------------------------

  SET $pop de_params   $DE


  return
}
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
#  * Pick an number of random entities by moving their index to the
#  * beginning of the permutation array.
#  * This method is a lot more efficient than the original algorithm's
#  * approach - especially for small population sizes.
#
# void 
# _gaul_pick_random_entities (int *permutation, int num, int size, int avoid)
# ------------------------------------------------------------------------------
proc _gaul_pick_random_entities {&permutation num size avoid} {

  USE_REFS 

  set is_p 0

  if {$is_p} {
    puts ""
    puts "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
    puts "_gaul_pick_random_entities :  num= $num  size= $size  avoid= $avoid"
    puts ""
    puts "permutation = $permutation" ;
    puts ""
  }


#   int		j;		/* Loop variable over picked numbers. */
#   int		pos, tmp;	/* Current indices. */

  for {set j 0} {$j < $num} {incr j} {

#     do
#     {
#       pos = j+random_int(size-j);
#     } while (permutation[pos] == avoid);

    while 1 {
      set pos [expr {$j + [comm_random_int [expr {$size - $j}]]}]
      set val [lindex $permutation $pos]

      #puts "j= $j  pos= $pos  val= $val  avoid= $avoid"
      if {$val != $avoid} break ;# нашли не "avoid"
    }

    # swap j <-> pos
    # 
    set tmp [lindex $permutation $j]

    lset permutation $j [lindex $permutation $pos]

    if {$is_p} {
      puts ""
      puts "pos = $pos" 
      puts "tmp = $tmp" 
    }

    lset permutation $pos $tmp;
  }

  if {$is_p} {
    puts ""
    puts "permutation = $permutation" ;
    puts ""
    puts "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
    puts ""
  }

  return
}
# //------------------------------------------------------------------------------
#
# //------------------------------------------------------------------------------
# void calc_tmpentity_11 (population *pop, entity *tmpentity, int n, int i0, 
#                         int *perm, double weighting_factor) 
# //------------------------------------------------------------------------------
proc calc_tmpentity_11 {pop tmpentity n  i0 perm  weighting_factor} {
  
#   if {$::is_print} {
#     #pop_print $pop
#     puts -nonewline "  calc_tmpentity_11:  n= $n  perm= $perm"
#   }


  set p1 [lindex $perm 0]
  set p2 [lindex $perm 1]

  set e1 [pop_get_entity_     $pop  $p1]
  set g1 [item_get_chromo_gen $e1   $n]

  set e2 [pop_get_entity_     $pop  $p2]
  set g2 [item_get_chromo_gen $e2   $n]


  set e0    [pop_get_entity_  $pop  $i0]
  set g0 [item_get_chromo_gen $e0   $n]


  #   double diff = ((double *) pop->entity_iarray[perm[0]]->CH)[n]
  #               - ((double *) pop->entity_iarray[perm[1]]->CH)[n];

  set diff [expr {$g1 - $g2}]

  #   ((double *)tmpentity->CH)[n] =
  #     ((double *)pop->entity_iarray[i0]->CH)[n] + weighting_factor * diff;



  set   gen [expr {$g0 + $weighting_factor * $diff}]

#   if {$::is_print} {
#      #     $e1 print_ch "  e1= "   ;

#      #     puts -nonewline [format "  g1= %f "  $g1]
#      puts " p1= $p1 g1= $g1   p2= $p2 g2= $g2  g0= $g0"
#    }

  #$tmpentity set_chromo_gen  $n $gen
  item_set_chromo_gen $tmpentity  $n $gen

   return
}
# //------------------------------------------------------------------------------
# void calc_tmpentity2 (population  *pop, int n, int best, 
#                     entity	*tmpentity, int	*permutation, double weighting_factor) 
# //------------------------------------------------------------------------------
proc calc_tmpentity2 {pop n best tmpentity  permutation  weighting_factor} {
  
#   calc_tmpentity_11 (pop, tmpentity, n, 
#                              best, &permutation[0], weighting_factor);

   calc_tmpentity_11  $pop $tmpentity $n \
                              $best $permutation $weighting_factor

   return
}
# //------------------------------------------------------------------------------
proc calc_tmpentity3 {pop n best tmpentity  permutation  weighting_factor} {
  
#   calc_tmpentity_11 (pop, tmpentity, n, 
#                              permutation[0], &permutation[1], weighting_factor);

  set permutation_0 [lindex $permutation 0]
  set permutation_1 [lrange $permutation 1 end]

  calc_tmpentity_11  $pop $tmpentity $n $permutation_0 $permutation_1 $weighting_factor

  return
}
# //------------------------------------------------------------------------------
# void calc_tmpentity_22 (population *pop, entity *tmpentity, int n, int i0, 
#                         int *perm, double weighting_factor) 

# //------------------------------------------------------------------------------
proc calc_tmpentity_22 {pop tmpentity n i0 perm weighting_factor} {
  
#   double diff = (((double *) pop->entity_iarray[perm[0]]->CH)[n]
#                + ((double *) pop->entity_iarray[perm[1]]->CH)[n]
#                - ((double *) pop->entity_iarray[perm[2]]->CH)[n]
#                - ((double *) pop->entity_iarray[perm[3]]->CH)[n]);

#   set e1 [$pop get_entity [lindex $perm 0]]
#   set e2 [$pop get_entity [lindex $perm 1]]
#   set e3 [$pop get_entity [lindex $perm 2]]
#   set e4 [$pop get_entity [lindex $perm 3]]

  set e1 [pop_get_entity_ $pop [lindex $perm 0]]
  set e2 [pop_get_entity_ $pop [lindex $perm 1]]
  set e3 [pop_get_entity_ $pop [lindex $perm 2]]
  set e4 [pop_get_entity_ $pop [lindex $perm 3]]

  set g1 [item_get_chromo_gen $e1 $n]
  set g2 [item_get_chromo_gen $e2 $n]
  set g3 [item_get_chromo_gen $e3 $n]
  set g4 [item_get_chromo_gen $e4 $n]

  set diff [expr {$g1 + $g2 - $g3 - $g4}]

#   ((double *)tmpentity->CH)[n] =
#     ((double *)pop->entity_iarray[i0]->CH)[n] + weighting_factor * diff;

  #set i0_entity   [$pop get_entity $i0]
  set i0_entity   [pop_get_entity_ $pop  $i0]

  set i0_entity_n_gen [item_get_chromo_gen $i0_entity $n]

  #$tmpentity set_chromo_gen $n [expr {$i0_entity_n_gen + $weighting_factor * $diff}]
  item_set_chromo_gen $tmpentity $n [expr {$i0_entity_n_gen + $weighting_factor * $diff}]

  return
}
# //------------------------------------------------------------------------------
#  calc_tmpentity4 (population  *pop, int n, int best, 
#                     entity	*tmpentity, int	*permutation, double weighting_factor) 
# //------------------------------------------------------------------------------
proc  calc_tmpentity4 {pop n best tmpentity permutation weighting_factor} {

#   calc_tmpentity_22 (pop, tmpentity, n, 
#                              best, &permutation[0], weighting_factor);

  calc_tmpentity_22  $pop $tmpentity $n \
                              $best $permutation $weighting_factor

  return
}
# //------------------------------------------------------------------------------
proc calc_tmpentity5 {pop n best tmpentity permutation weighting_factor} {

  set permutation_0 [lindex $permutation 0]
  set permutation_1 [lrange $permutation 1 end]

#   calc_tmpentity_22 (pop, tmpentity, n, 
#                              permutation[0], &permutation[1], weighting_factor);

  calc_tmpentity_22  $pop $tmpentity $n $permutation_0 $permutation_1 $weighting_factor

  return;
}
# //------------------------------------------------------------------------------
proc calc_tmpentity_33 {pop tmpentity n i0 perm weighting_factor} {
  
#   set e1 [$pop get_entity [lindex $perm 0]]
#   set e2 [$pop get_entity [lindex $perm 1]]
#   set e3 [$pop get_entity [lindex $perm 2]]
#   set e4 [$pop get_entity [lindex $perm 3]]
#   set e5 [$pop get_entity [lindex $perm 4]]
#   set e6 [$pop get_entity [lindex $perm 5]]

  set e1 [pop_get_entity_ $pop [lindex $perm 0]]
  set e2 [pop_get_entity_ $pop [lindex $perm 1]]
  set e3 [pop_get_entity_ $pop [lindex $perm 2]]
  set e4 [pop_get_entity_ $pop [lindex $perm 3]]
  set e5 [pop_get_entity_ $pop [lindex $perm 4]]
  set e6 [pop_get_entity_ $pop [lindex $perm 5]]

  set g1 [item_get_chromo_gen $e1 $n]
  set g2 [item_get_chromo_gen $e2 $n]
  set g3 [item_get_chromo_gen $e3 $n]
  set g4 [item_get_chromo_gen $e4 $n]
  set g5 [item_get_chromo_gen $e5 $n]
  set g6 [item_get_chromo_gen $e6 $n]

#   double diff = (((double *) pop->entity_iarray [perm[0]]->CH)[n]
#                + ((double *) pop->entity_iarray [perm[1]]->CH)[n]
#                + ((double *) pop->entity_iarray [perm[2]]->CH)[n]
#                - ((double *) pop->entity_iarray [perm[3]]->CH)[n]
#                - ((double *) pop->entity_iarray [perm[4]]->CH)[n]
#                - ((double *) pop->entity_iarray [perm[5]]->CH)[n]);

  set diff [expr {$g1 + $g2 + $g3  - $g4 - $g5 - $g6}]

#   ((double *)tmpentity->CH)[n] = 
#     ((double *) pop->entity_iarray[i0]->CH)[n] + weighting_factor * diff;

  #set i0_entity   [$pop get_entity $i0]
  set i0_entity   [pop_get_entity_ $pop  $i0]

  set i0_entity_n_gen [item_get_chromo_gen $i0_entity $n]

  #$tmpentity set_chromo_gen $n [expr {$i0_entity_n_gen + $weighting_factor * $diff}]
  item_set_chromo_gen $tmpentity $n [expr {$i0_entity_n_gen + $weighting_factor * $diff}]

  return
}
# //------------------------------------------------------------------------------
proc calc_tmpentity6 {pop n best tmpentity permutation weighting_factor} {
  
#   calc_tmpentity_33 (pop, tmpentity, n, 
#                              best, &permutation[0], weighting_factor);

  calc_tmpentity_33  $pop $tmpentity $n \
                              $best $permutation $weighting_factor
  return
}
# //------------------------------------------------------------------------------
proc calc_tmpentity7 {pop n best tmpentity permutation weighting_factor} {

#   calc_tmpentity_33 (pop, tmpentity, n, 
#                              permutation[0], &permutation[1], weighting_factor);

  set permutation_0 [lindex $permutation 0]
  set permutation_1 [lrange $permutation 1 end]

  calc_tmpentity_33  $pop $tmpentity $n $permutation_0 $permutation_1 $weighting_factor


  return
}
# //------------------------------------------------------------------------------
# void calc_tmpentity_1bin (population  *pop, int n, int best, 
#                       entity *tmpentity, int *permutation, double weighting_factor) 
# //------------------------------------------------------------------------------
proc  calc_tmpentity_1bin {pop n best tmpentity permutation weighting_factor} {


#   double diff = (((double *)pop->entity_iarray[best]->CH)[n]
#                - ((double *)tmpentity->CH)[n]
#                + ((double *)pop->entity_iarray[permutation[0]]->CH)[n]
#                - ((double *)pop->entity_iarray[permutation[1]]->CH)[n]);

#   ((double *) tmpentity->CH)[n] += weighting_factor * diff;
 

  #set e1 [$pop get_entity $best]
  set e1 [pop_get_entity_ $pop $best]

  set e2 $tmpentity
  #set e3 [$pop get_entity [lindex $permutation 0]]
  #set e4 [$pop get_entity [lindex $permutation 1]]
  set e3 [pop_get_entity_ $pop [lindex $permutation 0]]
  set e4 [pop_get_entity_ $pop [lindex $permutation 1]]

  set g1 [item_get_chromo_gen $e1 $n]
  set g2 [item_get_chromo_gen $e2 $n]
  set g3 [item_get_chromo_gen $e3 $n]
  set g4 [item_get_chromo_gen $e4 $n]

  set diff [expr {$g1 - $g2 + $g3  - $g4}]


  #$tmpentity set_chromo_gen $n  [expr {$g2 + $weighting_factor * $diff}]
  item_set_chromo_gen $tmpentity $n  [expr {$g2 + $weighting_factor * $diff}]

  return
}
# //------------------------------------------------------------------------------
# void calc_tmpentity_2bin (population  *pop, int n, int best, 
#                       entity *tmpentity, int *permutation, double weighting_factor) 
# //------------------------------------------------------------------------------
proc  calc_tmpentity_2bin {pop n best tmpentity permutation weighting_factor} {

#   double diff = (((double *)pop->entity_iarray[best]->CH)[n]
#                - ((double *)tmpentity->CH)[n]
#                + ((double *)pop->entity_iarray[permutation[0]]->CH)[n]
#                + ((double *)pop->entity_iarray[permutation[1]]->CH)[n]
#                - ((double *)pop->entity_iarray[permutation[2]]->CH)[n]
#                - ((double *)pop->entity_iarray[permutation[3]]->CH)[n]);

#   ((double *)tmpentity->CH)[n] += weighting_factor * diff;

  #set e1 [$pop get_entity $best]
  set e1 [pop_get_entity_ $pop  $best]

  set e2 $tmpentity
#   set e3 [$pop get_entity [lindex $permutation 0]]
#   set e4 [$pop get_entity [lindex $permutation 1]]
#   set e5 [$pop get_entity [lindex $permutation 2]]
#   set e6 [$pop get_entity [lindex $permutation 3]]

  set e3 [pop_get_entity_ $pop [lindex $permutation 0]]
  set e4 [pop_get_entity_ $pop [lindex $permutation 1]]
  set e5 [pop_get_entity_ $pop [lindex $permutation 2]]
  set e6 [pop_get_entity_ $pop [lindex $permutation 3]]

  set g1 [item_get_chromo_gen $e1 $n]
  set g2 [item_get_chromo_gen $e2 $n]
  set g3 [item_get_chromo_gen $e3 $n]
  set g4 [item_get_chromo_gen $e4 $n]
  set g5 [item_get_chromo_gen $e5 $n]
  set g6 [item_get_chromo_gen $e6 $n]

  set diff [expr {$g1 - $g2 + $g3 + $g4 - $g5 - $g6}]


  #$tmpentity set_chromo_gen $n  [expr {$g2 + $weighting_factor * $diff}]
  item_set_chromo_gen $tmpentity $n  [expr {$g2 + $weighting_factor * $diff}]

  return
}
# //------------------------------------------------------------------------------
proc DE_best_1_exp {pop i n best tmpentity &name_permutation weighting_factor} {

  USE_REFS

  set N 2
  set calc_proc "calc_tmpentity$N"

  DE_best_exp  $pop $i $n $best $tmpentity name_permutation $weighting_factor \
               $N $calc_proc

  return
}
# //------------------------------------------------------------------------------
proc DE_best_2_exp {pop i n best tmpentity &name_permutation weighting_factor} {

  USE_REFS

  set N 4
  set calc_proc "calc_tmpentity$N"

  DE_best_exp  $pop $i $n $best $tmpentity name_permutation $weighting_factor \
               $N $calc_proc

  return
}
# //------------------------------------------------------------------------------
proc DE_best_3_exp {pop i n best tmpentity &name_permutation weighting_factor} {

  USE_REFS

  set N 6
  set calc_proc "calc_tmpentity$N"

  DE_best_exp  $pop $i $n $best $tmpentity name_permutation $weighting_factor \
               $N $calc_proc

  return
}
# //------------------------------------------------------------------------------
proc DE_rand_1_exp {pop i n best tmpentity &name_permutation weighting_factor} {

  USE_REFS

  set N 3
  set calc_proc "calc_tmpentity$N"

  DE_best_exp  $pop $i $n $best $tmpentity name_permutation $weighting_factor \
               $N $calc_proc

  return
}
# //------------------------------------------------------------------------------
proc DE_rand_2_exp {pop i n best tmpentity &name_permutation weighting_factor} {

  USE_REFS

  set N 5
  set calc_proc "calc_tmpentity$N"

  DE_best_exp  $pop $i $n $best $tmpentity name_permutation $weighting_factor \
               $N $calc_proc

  return
}
# //------------------------------------------------------------------------------
proc DE_rand_3_exp {pop i n best tmpentity &name_permutation weighting_factor} {

  USE_REFS

  set N 7
  set calc_proc "calc_tmpentity$N"

  DE_best_exp  $pop $i $n $best $tmpentity name_permutation $weighting_factor \
               $N $calc_proc

  return
}
# //------------------------------------------------------------------------------
proc DE_best_exp {pop i n best tmpentity &name_permutation weighting_factor 
                 N  calc_proc } {

  USE_REFS

  set lsrc [GET $pop lsrc]

  #_gaul_pick_random_entities   name_permutation $N [GET $pop orig_size] $i
  _gaul_pick_random_entities   name_permutation $N [GET $pop lpop] $i
  set L   0


  while (1) {
    
    $calc_proc  $pop $n $best $tmpentity $name_permutation $weighting_factor 
       
    set n [expr {($n + 1) % $lsrc}]
    incr L

    set factor [GET [GET $pop de_params] de_crossover_factor]

    set flag [comm_random_boolean_prob $factor]
 
    if {! $flag} { break; } ;# вообще заканчиваем цикл ! и выходим
    
    if {! [expr {$L < $lsrc}]}   { break; }
  }
  

  return
}
# //------------------------------------------------------------------------------
proc DE_randtobest_1_exp {pop i n best tmpentity &name_permutation weighting_factor} {

  USE_REFS

  set N 2
  set calc_proc "calc_tmpentity_1bin"

  DE_best_exp  $pop $i $n $best $tmpentity name_permutation $weighting_factor \
               $N $calc_proc

  return
}
# //------------------------------------------------------------------------------
proc DE_randtobest_2_exp {pop i n best tmpentity &name_permutation weighting_factor} {

  USE_REFS

  set N 4
  set calc_proc "calc_tmpentity_2bin"

  DE_best_exp  $pop $i $n $best $tmpentity name_permutation $weighting_factor \
               $N $calc_proc

  return
}
# //------------------------------------------------------------------------------
# //------------------------------------------------------------------------------
proc DE_best_1_bin {pop i n best tmpentity &name_permutation weighting_factor} {


  USE_REFS

#  _gaul_pick_random_entities   name_permutation 2 [GET $pop orig_size] $i
  _gaul_pick_random_entities   name_permutation 2 [GET $pop lpop] $i
      

  calc_tmpentity2  $pop $n $best $tmpentity $name_permutation $weighting_factor 

  set lsrc [GET $pop lsrc]
  set L   1


  while (1) {

    if {! [expr {$L < $lsrc}]} { break; }

    set flag [comm_random_boolean]

    if {$flag} {
      calc_tmpentity2  $pop $n $best $tmpentity $name_permutation $weighting_factor 
    }
    # // а здесь не заканчиваем, но продолжаем!
    
    set n [expr {($n + 1) % $lsrc}]
    incr L
   }
 
  return
}
# //------------------------------------------------------------------------------
#
# не пошло! хотя вроде один в один
#
# //------------------------------------------------------------------------------
proc DE_best_1_bin_new {pop i n best tmpentity  &name_permutation weighting_factor} {
  
  USE_REFS

  set N 2
  set calc_proc "calc_tmpentity2"


  DE_best_bin  $pop $i $n $best $tmpentity  name_permutation $weighting_factor \
                 $N $calc_proc

  return
}
# //------------------------------------------------------------------------------
proc DE_best_bin {pop i n best tmpentity  &name_permutation weighting_factor 
                 N calc_proc} {
  
  USE_REFS

#  _gaul_pick_random_entities   name_permutation $N [GET $pop orig_size] $i
  _gaul_pick_random_entities   name_permutation $N [GET $pop lpop] $i
  
  $calc_proc  $pop $n $best $tmpentity $name_permutation $weighting_factor 

  set lsrc [GET $pop lsrc]


  for {set L 1} {$L < $lsrc} {incr L} {

    set flag [comm_random_boolean]
   if {$flag} {
     $calc_proc  $pop $n $best $tmpentity $name_permutation $weighting_factor 
    }

    set n [expr {($n + 1) % $lsrc}]
  }
 
  return
}
# //------------------------------------------------------------------------------
proc DE_best_2_bin {pop i n best tmpentity  &name_permutation weighting_factor} {
  
  USE_REFS

  set N 4
  set calc_proc "calc_tmpentity4"


  DE_best_bin  $pop $i $n $best $tmpentity  name_permutation $weighting_factor \
                 $N $calc_proc

  return
}
# //------------------------------------------------------------------------------
proc DE_best_3_bin {pop i n best tmpentity  &name_permutation weighting_factor} {
  
  USE_REFS

  set N 6
  set calc_proc "calc_tmpentity6"


  DE_best_bin  $pop $i $n $best $tmpentity  name_permutation $weighting_factor \
                 $N $calc_proc

  return
}
# //------------------------------------------------------------------------------
proc DE_rand_1_bin {pop i n best tmpentity  &name_permutation weighting_factor} {
  
  USE_REFS

  set N 3
  set calc_proc "calc_tmpentity3"


  DE_best_bin  $pop $i $n $best $tmpentity  name_permutation $weighting_factor \
                 $N $calc_proc

  return
}
# //------------------------------------------------------------------------------
proc DE_rand_2_bin {pop i n best tmpentity  &name_permutation weighting_factor} {
  
  USE_REFS

  set N 5
  set calc_proc "calc_tmpentity5"


  DE_best_bin  $pop $i $n $best $tmpentity  name_permutation $weighting_factor \
                 $N $calc_proc

  return
}
# //------------------------------------------------------------------------------
# void DE_rand_3_bin (population  *pop, int i, int n, int best, 
#                     entity	*tmpentity, int	*permutation, double weighting_factor)
# {
  
#   int L;  /* Allele indice */
  
#   _gaul_pick_random_entities(permutation, 7, pop->orig_size, i);
  
#   calc_tmpentity7 (pop, n, best, tmpentity, permutation, weighting_factor); 
  
#   for (L=1; L<pop->lsrc; L++)
#   {
#     if (random_boolean ()) {
#       calc_tmpentity7 (pop, n, best, tmpentity, permutation, weighting_factor); 
#     }

#     n = (n+1) % pop->lsrc;
#   }
  

# }
# //------------------------------------------------------------------------------
proc DE_rand_3_bin {pop i n best tmpentity  &name_permutation weighting_factor} {
  
  USE_REFS

  set N 7
  set calc_proc "calc_tmpentity7"


  DE_best_bin  $pop $i $n $best $tmpentity  name_permutation $weighting_factor \
                 $N $calc_proc

  return
}
# //------------------------------------------------------------------------------
proc DE_randtobest_1_bin {pop i n best tmpentity  &name_permutation weighting_factor} {
  
  USE_REFS

  set N 2
  set calc_proc "calc_tmpentity_1bin"


  DE_best_bin  $pop $i $n $best $tmpentity  name_permutation $weighting_factor \
                 $N $calc_proc

  return
}
# //------------------------------------------------------------------------------
# void DE_randtobest_2_bin (population  *pop, int i, int n, int best, 
#                     entity	*tmpentity, int	*permutation, double weighting_factor)
# {
  
#   int L;  /* Allele indice */
  
#   _gaul_pick_random_entities(permutation, 4, pop->orig_size, i);
  
#   calc_tmpentity_2bin (pop, n, best, 
#                        tmpentity, permutation, weighting_factor);

  
#   for (L=1; L < pop->lsrc; L++)
#   {
#     if ( random_boolean() )
#       calc_tmpentity_2bin (pop, n, best, 
#                            tmpentity, permutation, weighting_factor);

#     n = (n+1)%pop->lsrc;
#   }

# }
# //------------------------------------------------------------------------------
proc DE_randtobest_2_bin {pop i n best tmpentity  &name_permutation weighting_factor} {
  
  USE_REFS

  set N 4
  set calc_proc "calc_tmpentity_2bin"


  DE_best_bin  $pop $i $n $best $tmpentity  name_permutation $weighting_factor \
                 $N $calc_proc

  return
}
# //------------------------------------------------------------------------------
# void ga_de_crossover_binomial (population  *pop, int i, int n, int best, 
#                                entity	*tmpentity, int	*permutation, double weighting_factor)
# //------------------------------------------------------------------------------
proc ga_de_crossover_binomial {pop i n best tmpentity &name_permutation weighting_factor} {

  USE_REFS

  #   //int L;  /* Allele indice */
  
  set strategy         [GET [GET $pop de_params] de_strategy]

  set num_perturbed    [GET [GET $pop de_params] de_num_perturbed]
  
#   if {$::is_print} {
#     puts "ga_de_crossover_binomial: strategy = $strategy  num_perturbed = $num_perturbed"
#     #puts "                        : tmpentity = $tmpentity"
#   }



  if {$strategy == "GA_DE_STRATEGY_BEST"} {
    
    if       {$num_perturbed == 1} {       
      DE_best_1_bin  $pop $i $n $best $tmpentity name_permutation $weighting_factor    

    } elseif {$num_perturbed == 2} {       
      DE_best_2_bin  $pop $i $n $best $tmpentity name_permutation $weighting_factor     

    } elseif {$num_perturbed == 3} {      
      DE_best_3_bin  $pop $i $n $best $tmpentity name_permutation $weighting_factor

    } else {
      die "Invalid differential evolution selection number."
    }


  } elseif {$strategy == "GA_DE_STRATEGY_RAND"} {

    if       {$num_perturbed == 1} {
      DE_rand_1_bin  $pop $i $n $best $tmpentity name_permutation $weighting_factor     

    } elseif {$num_perturbed == 2} { 
      DE_rand_2_bin  $pop $i $n $best $tmpentity name_permutation $weighting_factor    

    } elseif {$num_perturbed == 3} { 
      DE_rand_3_bin  $pop $i $n $best $tmpentity name_permutation $weighting_factor   

    } else {
      die "Invalid differential evolution selection number."
    }


  } elseif {$strategy == "GA_DE_STRATEGY_RANDTOBEST"} {

    if      {$num_perturbed == 1} { 
      DE_randtobest_1_bin  $pop $i $n $best $tmpentity name_permutation $weighting_factor     

    } elseif  {$num_perturbed == 2} { 
      DE_randtobest_2_bin  $pop $i $n $best $tmpentity name_permutation $weighting_factor

    } else {
      die "Invalid differential evolution selection number."
    }

  } else {

    puts "Unknown differential evolution strategy."
  }

}
# //------------------------------------------------------------------------------
# void ga_de_crossover_exponential (population  *pop, int i, int n, int best, 
#                                   entity      *tmpentity, int *permutation, double weighting_factor)

# //------------------------------------------------------------------------------
proc ga_de_crossover_exponential {pop i n best tmpentity &name_permutation weighting_factor} {

  USE_REFS

  set strategy         [GET [GET $pop de_params] de_strategy]

  set num_perturbed    [GET [GET $pop de_params] de_num_perturbed]
  

  if {$strategy == "GA_DE_STRATEGY_BEST"} {    
    if       {$num_perturbed == 1} {       
      DE_best_1_exp  $pop $i $n $best $tmpentity name_permutation $weighting_factor  
    
    } elseif {$num_perturbed == 2} {       
      DE_best_2_exp  $pop $i $n $best $tmpentity name_permutation $weighting_factor
      
    } elseif {$num_perturbed == 3} { 
      DE_best_3_exp  $pop $i $n $best $tmpentity name_permutation $weighting_factor 
   
    } else {
      die "Invalid differential evolution selection number."
    }   
 
  } elseif {$strategy == "GA_DE_STRATEGY_RAND"} {
    if       {$num_perturbed == 1} {       
     DE_rand_1_exp  $pop $i $n $best $tmpentity name_permutation $weighting_factor        

    } elseif {$num_perturbed == 2} { 
     DE_rand_2_exp  $pop $i $n $best $tmpentity name_permutation $weighting_factor           

    } elseif {$num_perturbed == 3} {       
     DE_rand_3_exp  $pop $i $n $best $tmpentity name_permutation $weighting_factor
                
    } else {
      die "Invalid differential evolution selection number."
    }

  } elseif {$strategy == "GA_DE_STRATEGY_RANDTOBEST"} {
    if      {$num_perturbed == 1} {       
     DE_randtobest_1_exp  $pop $i $n $best $tmpentity name_permutation $weighting_factor        

    } elseif {$num_perturbed == 2} {       
     DE_randtobest_2_exp  $pop $i $n $best $tmpentity name_permutation $weighting_factor           

    } else {
      die "Invalid differential evolution selection number."
    }

  } else {

    #  die ("Unknown differential evolution strategy.");
    puts "Unknown differential evolution strategy."
  }

  
}
#-------------------------------------------------------------------------------
proc find_best_solution {pop rank_proc} {

  set best 0
  
  # а почему с 1-го а не с 0-го ищем?
  # 
  set i0 0 ;# // 1 -было ?!

  if {$rank_proc == "ga_rank_fitness"} {
    
    for {set i $i0} {$i < [get_pop_size $pop]} {incr i} {
      
      # if (pop->entity_iarray[i]->fitness > pop->entity_iarray[best]->fitness)
      #    best = i;
      
      #if {[$pop get_entity_fitness $i] > [$pop get_entity_fitness $best]} {}
      if {[pop_get_entity_fitness_ $pop  $i] > [pop_get_entity_fitness_ $pop  $best]} {
        set best $i

      }
      
    }
    
  } else {
    
    #       for (i=1; i<pop->size; i++)
    #       {
    #         if ( pop->rank(pop, pop->entity_iarray[i],
    #                        pop, pop->entity_iarray[best]) > 0 )
    #           best = i;
    #       }
  }

  SET $pop best $best ;# и занесем сразу номер лучшего элемента

  return $best
}
# ------------------------------------------------------------------------------
# //  synopsis:	Performs differential evolution. 

# GAULFUNC int ga_differentialevolution (population  *pop,
#                                        const int  max_generations)
# {
#   int		generation = 0;		/* Current generation number. */
# //------------------------------------------------------------------------------
proc prepare_permutation {size args} {

  set print [dict_parse $args "-print"]

  if {$print} {
    puts "Prepare arrays to store permutations ..."
  }

  # 
  # if ( !(permutation = s_malloc(sizeof(int)*pop->size)) )
  #   die("Unable to allocate memory");
  
  set permutation ""

  for {set i 0} {$i < $size} {incr i} {

    #permutation [i] = i;
    lappend permutation $i
  }

  return $permutation
}
#-------------------------------------------------------------------------------
proc pop_eliminate {p} {


  set orig_size [GET $p "lpop"]
  
  set tmp [GET $p "itemlist"]

  SET $p "itemlist" [lrange $tmp $orig_size end] ;# взяли первые $orig_size

  return
}
#-------------------------------------------------------------------------------
proc ga_differentialevolution	{pop task max_generations args} {


  set print $::is_print

  set eval_proc [GET $task "fit_func"]


  set DE [GET $pop de_params]

  set generation 0 ;# #   int generation = 0; /* Current generation number. */

  #   int	i;			/* Loop variable over entities. */
  #   int	best;			/* Index of best entity. */
  #   int	*permutation;		/* Permutation array for random selections. */
  #   entity	*tmpentity;		/* New entity. */
  #   int	n;			/* Allele indices. */
  #   double	weighting_factor;	/* Weighting multiplier. */
  
  #   /* Checks. */

  #   if (!pop)
  #     die ("NULL pointer to population structure passed.");
  #   if (!pop->de_params)
  #     die ("ga_population_set_differentialevolution_params(), or similar, must 
  #   be used prior to ga_differentialevolution().");
  
  #   if (!pop->evaluate)       die ("Population's evaluation callback is undefined.");
  #   if (!pop->rank)           die ("Population's ranking callback is undefined.");
  #   if (pop->lpop < 6) die ("Population's stable size is too small.  (Must be at least 6)");
  #   if ( pop->de_params->crossover_factor < 0.0 ||
  #       pop->de_params->crossover_factor > 1.0 )
  #     die ("Invalid crossover_factor.");
  
  #   plog (LOG_VERBOSE, "The differential evolution has begun!");
  
  #   pop->generation = 0;
  SET $pop generation 0
 
  # 
  # Score the initial population members.
  #  

  set size        [get_pop_size $pop]
  set lpop [GET $pop lpop]

  #puts "size        = $size"
  #puts "lpop = $lpop"

  # вот это что тут за фигня? если популяция не полна, то дополнить новыми членами?
  # 
  #   if (pop->size < pop->lpop) {
  #     gaul_population_fill (pop, pop->lpop - pop->size);
  #   }
  

  # зачем здесь отдельно для нулевого?
  # 
  #   if (pop->entity_iarray[0]->fitness == GA_MIN_FITNESS) {
  #     pop->evaluate(pop, pop->entity_iarray[0]);
  #   }
  
  #   /* #pragma omp parallel for \ */
  #   /*    shared(pop) private(i) \ */
  #   /*    schedule(static) */
  
  # ;-------------------------------------------------------------------
  if {$print} {
    puts ""
  }

  for {set i 0} {$i < $size} {incr i} {

    #  if (pop->entity_iarray[i]->fitness == GA_MIN_FITNESS)
    #      pop->evaluate(pop, pop->entity_iarray[i]);

    #set entity [$pop get_entity $i]
    set entity [pop_get_entity_ $pop  $i]

    #puts "i = $i   entity = $entity"
 
    if {[item_get_fitn $entity] == $::GA_NOT_FIT} {
      #puts "i = $i"

      pop_eval_item  $pop $entity $eval_proc $task

    }

    if {$print} {

      set fit [item_get_fitn $entity]
      #puts "ga_diff: evaluate .. i= $i  fit= $fit%"
      puts [format "ga_diff: evaluate .. i= %2d  fit= %f "  $i $fit]
    }

  }

  if {$print} {
      puts ""
  }
  # ;-------------------------------------------------------------------
  

  set permutation [prepare_permutation  [get_pop_size $pop] -print $print]
  
  #
  # Determine weighting factor. (в ходе генерации не меняется, я предположил..)
  #   
  set weighting_min [GET $DE de_weighting_min]

  set weighting_max [GET $DE de_weighting_max]
  
  # gaul.h.tl:
  #
  # int ga_rank_fitness (population *alphapop, entity *alpha, population *betapop, entity *beta);
  
  set rank_proc [GET $pop rank]

  # ~~~~~~~~~~~~~~~~~~~~~~~ GENERATION LOOP BEGIN ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # 
  # Stop when (a) max_generations reached, or
  #           (b) "pop->generation_hook" returns FALSE.
  
  #   while ( 
  #          (pop->generation_hook?pop->generation_hook(generation, pop):TRUE) &&
  #          generation < max_generations 
  #          )

  #while {$generation < $max_generations} {}
  while {1} {

    if {$print} {
      puts ""
      puts "GENERATION LOOP ......... generation = $generation"
      puts ""
    } else {

      #pop->generation_hook (generation, pop); // печать через 10
      [GET $pop generation_hook]  $generation $pop ; #// печать через 10
    }

    if {$generation >= $max_generations} {break}

    # хитроумный трюк здесь и в конце
    #SET $pop orig_size  [GET $pop size] 

    # Determine weighting factor. (на каждой генерации меняем весовой фактор ?)

    if {$weighting_min == $weighting_max} {
      set weighting_factor $weighting_min
    } else {
      set weighting_factor [random_double_range  $weighting_min $weighting_max]
    }
  

    # 
    # Find best solution.
    # 
    set best [find_best_solution $pop $rank_proc]

    incr generation ;#     generation++;
    SET $pop generation $generation


    # ~~~~~~~~~~~~~~~~~ I LOOP BEGIN ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # 
    # цикл по каждому элементу I, для его корректировки
    
    #for {set i 0} {$i < [GET $pop orig_size]} {incr i} {}
    for {set i 0} {$i < [GET $pop lpop]} {incr i} {

      if {$print} {
        puts ""
        puts [format "i= %2d ...................................." $i]

        puts ""       
        #$pop print_lite
        pop_print $pop
        puts ""
      }

      #set oldentity [$pop get_entity $i]
      set oldentity [pop_get_entity_ $pop  $i]

      if {$print} {
        print_entit  $oldentity "OLDENTITY ="
        pop_print $pop
      }

      # tmpentity = ga_entity_clone (pop, pop->entity_iarray[i]);
      #
      # в оригинале здесь было клонирование с добавлением в массив, но мы хотим
      # сделать без добавления:
      # 
      set tmpentity [ga_entity_clone_without_add $pop $oldentity]


      set len [GET $pop lsrc]
      set n [comm_random_int $len] ;# случайный номер гена

      #puts ""
      #puts "len = $len  n = $n !!!!!!!!!!!!!!!!!!!!!!!!!"
      #puts ""

      #
      # Note that the following code may appear bloated due to excessive
      # extraction of branches from loops.
      # However, this yields much more efficient code (particularly for larger
      # chromosomes) on less-than-cutting-edge compilers.
      # 

      #set de_params [$pop.de_params] ;# целиком структура

      set crossover_method [GET $DE de_crossover_method]
      set strategy         [GET $DE de_strategy]

      set num_perturbed    [GET $DE de_num_perturbed]

      if {$print} {
        print_entit  $tmpentity "TMPENTITY ="
        #puts "permutation = $permutation"
        pop_print $pop
      }


      # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      if {$crossover_method == "GA_DE_CROSSOVER_BINOMIAL"} {
        # GA_DE_CROSSOVER_BINOMIAL
        ga_de_crossover_binomial  $pop $i $n $best $tmpentity permutation \
                                  $weighting_factor       
      } else { 
        # GA_DE_CROSSOVER_EXPONENTIAL       
        ga_de_crossover_exponential  $pop $i $n $best $tmpentity permutation \
                                     $weighting_factor       
      } 
      # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

      if {$print} {
        print_entit  $tmpentity "TMPENTITY ="
        pop_print $pop
      }

      # посчитаем фитнес для нового элемента and restore the former chromosome 
      # values if this new solution is not an improvement
      # 

#       set eval_proc [GET $pop evaluate]
      set is_edone [pop_eval_item   $pop $tmpentity $eval_proc $task]

      if { ! $is_edone}  {
        puts ""
        puts "ERROR : not is_edone !!!"
        puts ""
        exit
      }

      set old_fit  [item_get_fitn $oldentity]
      set new_fit  [item_get_fitn $tmpentity]

      #!!!!!!!!!!!!!!!!!!!!!!!!!!
      #set eps 0.00001
      set eps 0.00000001
      #!!!!!!!!!!!!!!!!!!!!!!!!!!

      if {$rank_proc == "ga_rank_fitness"} {

        set is_worse [expr  {($old_fit - $new_fit) > $eps}] 
        #set is_worse [expr  {$old_fit > $new_fit}] 

      } else {
        set is_worse [expr {[rank_proc  $pop $tmpentity $pop $oldentity] < 0} ]
        # is_worse = (pop->rank (pop, tmpentity, pop, pop->entity_iarray[i]) < 0 );
      }
      
      
      if {$print} {
        puts -nonewline [format "  n= %d  old = %f .. new = %f "  \
                           $n $old_fit $new_fit]
      }

      if {$is_worse}  {
        # все только ухудшилось
      
        ga_entity_blank  $pop $tmpentity            ;# обнулить фитнес ?     
        ga_entity_copy   $pop $tmpentity $oldentity ;# $tmpentity <- $oldentity
        #
        # так оно ж (копирование) не работало ?? !!

        if {$print} { puts "" }

        pop_add_entity_ $pop  $oldentity ;# "перезапишем" на старое

      } else {
        # ура, улучшилось !!
        #
        if {$print} { puts [format " .... OK !!"] }

        #$pop set_entity $i $tmpentity ;# перезапишем на новое
        #
        # но по си-шному алгоритму этот элемент добавлен уже в конец массива при
        # вызове функций ga_entity_clone -> ga_get_free_entity, но мы поменяли на:
        #                
        #
        # здесь попробуем это симитировать, добавив его сейчас в конец:
        #
        pop_add_entity_ $pop  $tmpentity
      }
      
    } ;

    # // 
    # // ~~~~~~~~~~~~~~~~~ I LOOP FINAL ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    if {$print} {
      puts ""
      puts "I LOOP FINAL ........................................."
      puts ""
      #flush stdout  ;# все данные должны быть выведены
      
      puts ""
      pop_print $pop

      puts ""
      #flush stdout  ;# все данные должны быть выведены      
      puts  "Eliminate the original population members ..... "
      puts ""
    }
    

    pop_eliminate $pop
    

    if {$print} {
      puts ""
#       $pop print
      pop_print $pop
      puts ""
    }

    # End of generation.
    # 

    # Предпологается, что элементы уже отсортированы? Когда успели?
    #
    #     plog (LOG_VERBOSE,
    #          "After generation %d, population has fitness scores between %f and %f",
    #          generation,
    #          pop->entity_iarray[0]->fitness,
    #          pop->entity_iarray[pop->size-1]->fitness );

  } ;#	/* Generation loop. */
  #   //
  #   //~~~~~~~~~~~~~~~~ GENERATION LOOP FINAL ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  
  
  #   /*
  #     * Ensure final ordering of population is correct.
  #     */
  pop_sorting  $pop $task
  
#   if {$::is_print} {
#     puts ""
#     $pop print
#     puts ""
#   }
  
  #   /*
  #     * Clean-up.
  #     */
  #   s_free (permutation);
  
   return $generation
}
# //******************************************************************************
#-------------------------------------------------------------------------------
proc strategy_parse_and_print {s 
                       &label &strategy &crossover &num_perturbed &crossover_factor
                       &weighting_factor &weighting_factor2} {


  USE_REFS

  set label             [lindex $s 0]
  set strategy          [lindex $s 1]
  set crossover         [lindex $s 2]
  set num_perturbed     [lindex $s 3]
  set crossover_factor  [lindex $s 4]
  set weighting_factor  [lindex $s 5]
  set weighting_factor2 [lindex $s 6]


  puts -nonewline [format "Strategy %s ; C = %f ; " $label $crossover_factor]


  if {$weighting_factor != $weighting_factor2} {
    puts [format "F = rand( %f, %f )" $weighting_factor $weighting_factor2]
  } else {        
    puts [format "F = %f"  $weighting_factor]
  }


  if {$::is_print} { 

    puts "strategy_parse_and_print ......... "
    puts ""
    
    puts "   label             =  $label            "   
    puts "   strategy          =  $strategy         "
    puts "   crossover         =  $crossover        "
    puts "   num_perturbed     =  $num_perturbed    "
    
    puts [format "   crossover_factor  =  %f" $crossover_factor]
    puts [format "   weighting_factor  =  %f" $weighting_factor]
    puts [format "   weighting_factor2 =  %f" $weighting_factor2]

  }

  puts ""

  return
}
#-------------------------------------------------------------------------------
proc de_run_one {task strategy_one label population_size max_generations len_chromo print
               seed_proc step_proc} {

  #set seed_proc "_test_seed"
  #set step_proc "test_generation_callback"


  set label             ""
  set strategy          "" 
  set crossover         "" 
  set num_perturbed     "" 
  set crossover_factor  ""
  set weighting_factor  "" 
  set weighting_factor2 ""
  
  strategy_parse_and_print $strategy_one \
    label strategy crossover num_perturbed crossover_factor \
    weighting_factor weighting_factor2
  
  
  
  #  pop = ga_genesis_double (
  #      40,			   /* const int              population_size      */
  #      1,			   /* const int              num_chromo           */
  #      4,			   /* const int              len_chromo           */
  #    test_generation_callback, /* GAgeneration_hook      generation_hook      */
  #     NULL,			   /* GAiteration_hook       iteration_hook       */
  #     NULL,			   /* GAdata_destructor      data_destructor      */
  #     NULL,			   /* GAdata_ref_incrementor data_ref_incrementor */
  #     _test_score,		   /* GAevaluate             evaluate             */
  #     _test_seed,		   /* GAseed                 seed                 */
  #     NULL,			   /* GAadapt                adapt                */
  #     NULL,			   /* GAselect_one           select_one           */
  #     NULL,			   /* GAselect_two           select_two           */
  #     NULL,			   /* GAmutate               mutate               */
  #     NULL,			   /* GAcrossover            crossover            */
  #     NULL,			   /* GAreplace              replace              */
  #     NULL			   /* vpointer               User data            */
  #     );
  
  set pop [ga_genesis_main         \
	     $task \
             $population_size          \
             1                         \
             $len_chromo               \
             $step_proc                \
             NULL                      \
             NULL                      \
             NULL                      \
             $seed_proc                \
             NULL                      \
             NULL                      \
             NULL                      \
             NULL                      \
             NULL                      \
             NULL                      \
             NULL                      \
            ]
  
  # (похоже инициация-seed еще не выполнялась ?) давай пока тут выполним:
  #
  ga_population_seed $pop $task
  
  # пока здесь остановимся, осмотримся и распечатаемся:
  #$pop print
  #exit
  
  #  ga_population_set_differentialevolution_parameters (
  #      pop, strategy[i].strategy, strategy[i].crossover,
  #      strategy[i].num_perturbed, strategy[i].weighting_factor, strategy[i].weighting_factor2,
  #      strategy[i].crossover_factor
  #      );
  
  ga_population_set_differentialevolution_parameters $pop \
    $strategy $crossover   \
    $num_perturbed $weighting_factor $weighting_factor2 \
    $crossover_factor
  
  
  # выполняем основной расчет (поиск минимума)
  #
  ga_differentialevolution  $pop $task $max_generations -print $print			
  
  return $pop
}

# //****************************************************************************
# //****************************************************************************
# //****************************************************************************
# //****************************************************************************

#source "p-grad.tl"

# //****************************************************************************

#
if [info exists ::G_GRAD_TL] {
  return
} else {
  set  ::G_GRAD_TL ""
}

# //------------------------------------------------------------------------------
#   ga_gradient.c

#   ga_gradient - Gradient methods for comparison and local search.

#   Synopsis:     Gradient methods for comparison and local search.

# 		Routines for local search and optimisation using
# 		non-evolutionary methods.  These methods are all
# 		first-order, that is, they require first derivatives.

# 		Note that, these algorithms require that chromosomes
# 		may be reversibly mapped to arrays of double-precision
# 		floating-point array chromsomes.  If this is not
# 		possible then, hmmm, tough luck.

# 		You might want to think carefully about your convergence
# 		criteria.

#   References:

#-------------------------------------------------------------------------------
#
# Gradient methods parameter structure.
# 

# dictrecord define GA_GR_T {

#   dimensions  ;#   int	        : Size of double array
#   step_size   ;#   double	: Step size, (or initial step size)
#   alpha       ;#   double	: Step size scale-down factor
#   beta        ;#   double	: Step size scale-up factor
#   to_double   ;#   GAto_double	: Convert chromosome to double array
#   from_double ;#   GAfrom_double: Convert chromosome from double array
#   gradient    ;#   GAgradient	: Return gradients array

# } 

# /**********************************************************************
#   synopsis:     Sets the gradient-search parameters for a population.
#   parameters:	population *pop		Population to set parameters of.
# 		const GAto_double	Map chromosomal data to array of doubles.
# 		const GAfrom_double	Map array of doubles to chromosomal data.
# 		const int		Number of dimensions for double array 
#                                         (Needn't match dimensions of chromosome.)
#   return:	none
#  **********************************************************************/
# //------------------------------------------------------------------------------
# void 
# ga_population_set_gradient_parameters (population		*pop,
#                                         const GAto_double	to_double,
#                                         const GAfrom_double	from_double,
#                                         const GAgradient	gradient,
# 					const int		dimensions,
# 					const double		step_size)
# //------------------------------------------------------------------------------
proc ga_population_set_gradient_parameters {pop          
                                            to_double    
                                            from_double  
                                            gradient     
                                            dimensions   
                                            step_size}   \
{

   set GR [dict_create]


   SET $GR to_double    $to_double   ;#   GAto_double    /* Convert chromosome to double array.
   SET $GR from_double  $from_double ;#   GAfrom_double  /* Convert chromosome from double array. 
   SET $GR gradient     $gradient    ;#   GAgradient     /* Return gradients array. 
   SET $GR step_size    $step_size   ;#   double  /* Step size, (or initial step size).
   SET $GR dimensions   $dimensions  ;#   int     /* Size of double array. 
   SET $GR alpha        0.5          ;# /* Step-size scale-down factor. */
   SET $GR beta         1.2          ;# /* Step-size scale-up factor.   */
   

   SET $pop "gr_params"  $GR


  return
}
# //------------------------------------------------------------------------------
#   synopsis:	Performs optimisation on the passed entity by using a
#   		steepest ascents method (i.e. steepest descent, except
# 		maximising the fitness function).
# 		The passed entity will have its data overwritten.  The
# 		remainder of the population will be let untouched.
# 		Note that it is safe to pass a NULL initial structure,
# 		in which case a random starting structure wil be
# 		generated, however the final solution will not be
# 		available to the caller in any obvious way.
# //------------------------------------------------------------------------------
# entity *
# check_starting_solution (population *pop, entity *current) 

# //------------------------------------------------------------------------------
proc check_starting_solution {pop task current} \
{

  if {$current == "NULL"} \
  {
    if {$::is_print} {
    puts "Will perform gradient search with RANDOM starting solution. \n"
    }
    
    set current [ga_get_free_entity  $pop]
    ga_entity_seed  $pop $task $current

  } else {   
    if {$::is_print} {
    puts "Will perform gradient search with SPECIFIED starting solution. \n"
    }
  }

  return $current
}
# //------------------------------------------------------------------------------
# int 
# check_gradient_loop (population *pop, boolean force_terminate, entity *current,
#                      int iteration, int max_iterations) 
# //------------------------------------------------------------------------------
proc check_gradient_loop {pop force_terminate current iteration max_iterations} \
{

  #   int ret =  (force_terminate == FALSE &&
  #               (pop->iteration_hook?pop->iteration_hook(iteration, current):TRUE) &&
  #               iteration < max_iterations );

  set r1 [expr {$force_terminate == false}]

  set hook_proc [GET $pop iteration_hook]

  if {$hook_proc == "NULL"} {
    set r2 true
  } else {
    set r2 [$hook_proc $iteration $current]
  }

  set r3 [expr {$iteration < $max_iterations}]

  if {$::is_print} {
    #puts "check_gradient_loop:  iteration= $iteration  max_iterations= $max_iterations"    
  }

  return [expr {$r1 && $r2 && $r3}]
}
# //------------------------------------------------------------------------------
# /**********************************************************************
#   synopsis:	Performs optimisation on the passed entity by using a
#   		steepest ascents method (i.e. steepest descent, except
# 		maximising the fitness function).
# 		The passed entity will have its data overwritten.  The
# 		remainder of the population will be let untouched.
# 		Note that it is safe to pass a NULL initial structure,
# 		in which case a random starting structure wil be
# 		generated, however the final solution will not be
# 		available to the caller in any obvious way.

# 		Only double chromosomes may be used in this optimised
# 		version of the algorithm.
#  **********************************************************************/
# //------------------------------------------------------------------------------
# void
# make_putative (population *pop, entity *current, double step_size, 
#                double	*current_g, entity *putative)
# //------------------------------------------------------------------------------
proc make_putative {pop current step_size current_g putative} \
{

  #   int i;
  
  for {set i 0} {$i < [GET $pop lsrc]} {incr i} \
  {
    #  ((double *) putative->CH)[i] = ((double *) current->CH)[i] + 
    #                                step_size * current_g[i];

    set ci [item_get_chromo_gen $current $i]
   
    #$putative set_chromo_gen $i [expr $ci + ($step_size * [lindex $current_g $i])]
    item_set_chromo_gen $putative $i [expr {$ci + ($step_size * [lindex $current_g $i])}]
  }
 
  return
}
# //------------------------------------------------------------------------------
# int ga_steepestascent_double (population *pop,
#                               entity     *current,
#                               int  	  max_iterations)
# //------------------------------------------------------------------------------
proc ga_steepestascent_double {task pop current max_iterations} \
{

  set eval_proc [GET $task "fit_func"]


  set GR [GET $pop gr_params]


  #   int	iteration=0;		/* Current iteration number. */
  set iteration 0

  #   //int	i;			/* Index into arrays. */
  #   double	*current_g;		/* Current iteration gradient array. */
  #   entity	*putative;		/* New solution. */
  #   entity	*tmpentity;		/* Used to swap working solutions. */
  #   double	step_size;		/* Current step size. */
  #   double	grms;			/* Current RMS gradient. */

  #   boolean	force_terminate=FALSE;	/* Force optimisation to terminate. */
  set force_terminate false
  
  #   //
  #   // Checks ............................
  #   // 
  # check_pop_gradient $pop
  
  #   //
  #   // Prepare working entity and gradient array.
  #   //
  #   if (! (current_g = s_malloc (sizeof(double) * pop->lsrc)))
  #     die ("Unable to allocate memory");
  
  set putative [ga_get_free_entity $pop]
  
  #   // Do we need to generate a random starting solution? 
  #   // 
  set current [check_starting_solution  $pop $task $current]
  
  #   GAgradient gradient_proc = pop->gradient_params->gradient; /* Return gradients array. */
  #   //
  set gradient_proc [GET $GR gradient]
  
  #   //
  #   // Get initial fitness and derivatives.
  #   //

  #set eval_proc [GET $pop evaluate]
  
  pop_eval_item $pop $current $eval_proc $task
 
  set current_CH [item_CH $current]

  set current_g ""

  set grms [$gradient_proc  $pop $current $current_CH current_g]
  
  
  #   plog (LOG_VERBOSE,
  #        "Prior to the first iteration, the current solution has fitness score of %f and a RMS gradient of %f",
  #        current->fitness, grms);
  
  #   // Adjust step size based on gradient.
  #   // This scales the step size according to the initial gradient so that the
  #   // calculation doesn't blow-up completely.
  #   //
  #   //  step_size = (pop->lsrc*pop->gradient_params->step_size) / grms;
  
  set step_size [GET $GR step_size]
  
  #   /*
  #     * Do all the iterations:
  #     *
  #     * Stop when (a) max_iterations reached, or
  #     *           (b) "pop->iteration_hook" returns FALSE.
  #     * The iteration hook could evaluate the RMS gradient, or the maximum component
  #     * of the gradient, or any other termination criteria that may be desirable.
  #     */
  
  #if {$::is_print} {
  #  $pop print
  #  puts ""
  #}

  while {[check_gradient_loop  $pop $force_terminate $current $iteration $max_iterations]} \
  {
    #  iteration++;
    incr iteration

    if {$::is_print} {
      #puts "iteration = $iteration"
    }
  
    make_putative  $pop $current $step_size $current_g $putative
    #$eval_proc  $pop $putative
    pop_eval_item  $pop $putative $eval_proc $task
    
    if {[item_get_fitn $current] > [item_get_fitn $putative]} \
    {	
      #       // New solution is worse.
      while {1} {

        #         step_size *= pop->gradient_params->alpha;
        set step_size [expr {$step_size * [GET $GR alpha]}]
        
        make_putative  $pop $current $step_size $current_g $putative
        #$eval_proc  $pop $putative
        pop_eval_item $pop $putative $eval_proc $task 
        
        if {[item_get_fitn $current] <= [item_get_fitn $putative]} {break} 
        ;# // улучшили фитнес
        if {$step_size  <= $::ApproxZero}  {break} ;# // 
        
      } 
    
      if { [expr  {$step_size <= $::ApproxZero && $grms <= $::ApproxZero}] } {
        set force_terminate true
      }
      
    } else {	
      #       // New solution is an improvement.
      #       // 
      #       step_size *= pop->gradient_params->beta;
      set step_size [expr {$step_size * [GET $GR beta]}]
   }
    
    #  Store improved solution. 
    # 
    set tmpentity   $current
    set current    $putative
    set putative  $tmpentity
    
    #     grms = gradient_proc (pop, current, (double *)current->CH, current_g);
    set grms [$gradient_proc  $pop $current [item_CH $current] current_g]
    
    #     //
    #     // Use the iteration callback.
    #     //
    #     plog (LOG_VERBOSE,
    #          "After iteration %d, the current solution has fitness score of %f and RMS gradient of %f (step_size = %f)",
    #          iteration, current->fitness, grms, step_size);
    
  }  ;# /* Iteration loop. */
  
  #   //
  #   // Cleanup.
  #   //
  pop_del_entity  $pop $putative
  
  return $iteration
}
# //****************************************************************************
# //****************************************************************************
# //****************************************************************************
# //****************************************************************************

#source "p-sima.tl"

# //****************************************************************************

# -*-   mode: tcl  ; coding: koi8   -*- ----------------------------------------

if [info exists ::G_SIMA_TL] {
  return
} else {
  set  ::G_SIMA_TL ""
}

# ------------------------------------------------------------------------------
# ga_sa.c

# ga_sa - A simulated annealling algorithm for comparison and search.

# Synopsis:     A simulated annealling algorithm for comparison and search.

#-------------------------------------------------------------------------------
# 
# Simulated Annealling search parameter structure.
#  

# dictrecord define GA_SA_T {

#   initial_temp ;#   double         : Initial temperature; 
#   final_temp   ;#   double         : Final temperature; 
#   temp_step    ;#   double         : Increment of temperature updates;
#   temp_freq    ;#   int	temp_freq  : Frequency for temperature updates;
#   #                                * (Or, -1 for smooth transition between Ti and Tf)
#   temperature  ;#   double	   : Current temperature;
#   sa_accept    ;#   GAsa_accept sa_accept : Acceptance criterion function;
# }

# //------------------------------------------------------------------------------
# //  synopsis:     Simulated annealling acceptance criterion.
# //------------------------------------------------------------------------------
# boolean 
# ga_sa_boltzmann_acceptance (population	*pop,
# 			    entity	*original,
# 			    entity	*putative)
# //------------------------------------------------------------------------------
proc ga_sa_boltzmann_acceptance {pop original putative} {

  set SA [GET $pop sa_params]


  set ofit [item_get_fitn $original]
  set pfit [item_get_fitn $putative]

  set d [expr {$::GA_BOLTZMANN_FACTOR * [GET $SA temperature]}]

  if {$ofit < $pfit} {return true}

  set rand_prob [comm_random_boolean_prob [expr {exp (($pfit - $ofit) / $d ) }]]

  return $rand_prob

  #   return ( original->fitness < putative->fitness ||
  #           random_boolean_prob (exp((putative->fitness - original->fitness)
  #                                   /(GA_BOLTZMANN_FACTOR*pop->sa_params->temperature))) );

}
# //------------------------------------------------------------------------------
# //  synopsis:     Sets the simulated annealling parameters for a
# //	    	  population.
# //------------------------------------------------------------------------------
# void 
# ga_population_set_sa_parameters (population             *pop,
#                                  GAsa_accept             sa_accept,
#                                  const double            initial_temp,
#                                  const double            final_temp,
#                                  const double            temp_step,
#                                  const int               temp_freq )
# //------------------------------------------------------------------------------
proc ga_population_set_sa_parameters { pop          
                                      sa_accept     
                                      initial_temp  
                                      final_temp    
                                      temp_step     
                                      temp_freq}    \
{

  set SA [dict_create]

  #----------------------------------------------

  SET $SA sa_accept     $sa_accept
  SET $SA initial_temp  $initial_temp
  SET $SA final_temp    $final_temp
  SET $SA temp_step     $temp_step
  SET $SA temp_freq     $temp_freq
  SET $SA temperature   0.0        ;#	/* Current temperature. */
  
  #----------------------------------------------

  SET $pop "sa_params"  $SA

}
# //------------------------------------------------------------------------------
# /**********************************************************************
#   synopsis:	Performs optimisation on the passed entity by using a
#   		simplistic simulated annealling protocol.  The local
# 		search and fitness evaluations are performed using the
# 		standard mutation and evaluation callback mechanisms,
# 		respectively.

# 		The passed entity will have its data overwritten.  The
# 		remainder of the population will be let untouched.  Note
# 		that it is safe to pass a NULL initial structure, in
# 		which case a random starting structure wil be generated,
# 		however the final solution will not be available to the
# 		caller in any obvious way.

# 		Custom cooling schemes may be introduced by using
# 		ga_population_set_sa_temperature() from within
# 		an iteration_hook callback.
#  **********************************************************************/

# ------------------------------------------------------------------------------
# int 
# ga_sa (population  *pop,
#        entity	   *initial,
#        const int    max_iterations)
# ------------------------------------------------------------------------------
proc  ga_sa {task pop 
             initial 
             max_iterations} {


  set SA [GET $pop sa_params]

  #   int	iteration = 0;		/* Current iteration number. */
  set iteration 0

  #   entity	*putative;		/* Current solution. */
  #   entity	*best;			/* Current solution. */
  #   entity	*tmp;			/* Used to swap working solutions. */
  
  if {$::is_print} {
    puts ""
    puts "ga_sa ............................................. "
    puts ""
  }
  
  #   // Checks. 
  #   if (! pop)            die ("NULL pointer to population structure passed.");
  #   if (! pop->evaluate)  die ("Population's evaluation callback is undefined.");
  #   if (! pop->mutate)    die ("Population's mutation callback is undefined.");
  #   if (! pop->sa_params) die ("ga_population_set_sa_params(), or similar, must be used prior to ga_sa().");
  
  # Prepare working entities ...

  set putative [get_free_and_init $pop $task]

  #set best     [ga_get_free_entity  $pop] ;#  2-й
  set best     [get_free_and_init  $pop $task] ;#  2-й
  #
  #   // Do we need to generate a random starting solution?
  #   if (! initial)

  if {$initial == "NULL"} \
  {
    if {$::is_print} {
      puts "Will perform simulated annealling with random starting solution. "
    }
    
    set initial [get_free_and_init $pop $task] ;#  3-й
    #set initial [ga_get_free_entity $pop] ;#  3-й
    #ga_entity_seed  $pop $initial

    #ga_entity_seed  $pop $best

  } else {   
    #     if (is_print)
    #       printf ("> Will perform simulated annealling with specified starting solution. \n");

    ga_entity_copy $pop  $best $initial ;# $best <-- $initial
  }
  
  #   //
  #   // Ensure that initial solution is scored.
  #   //
  #   if (best->fitness==GA_MIN_FITNESS) pop->evaluate(pop, best);
  #

  if {[string equal [item_get_fitn $best]  $::GA_NOT_FIT]} {item

    puts "...... GA_MIN_FITNESS ......................"

    set eval_proc [GET $task "fit_func"]
    #$eval_proc  $pop $best
    pop_eval_item $pop $best $eval_proc $task
    
  }
#   if {[ent_get_fitness $initial] == $::GA_NOT_FIT} {
#     [$pop.evaluate] $pop $initial
#   }
  
  #   if (is_print)
  #     printf ("> Prior to the first iteration, the current solution has fitness score of %f \n",
  #             best->fitness);
  
  if {$::is_print} { 
    puts ""
    puts [format \
            "Prior to the first iteration, the current solution has fitness score of %f " \
            [item_get_fitn $best]]
    puts ""

    pop_print $pop
  }

  #   //
  #   // Do all the iterations:
  #   // 
  #   // Stop when (a) max_iterations reached, or
  #   //           (b) "pop->iteration_hook" returns FALSE.
  #   //

  SET $SA temperature   [GET $SA initial_temp]
  
  #   while ( (pop->iteration_hook?pop->iteration_hook(iteration, best):TRUE) &&
  #          iteration<max_iterations )

  while {1} {

    if {$iteration >= $max_iterations} {break}
    
    incr iteration
    #     iteration++;
    
    if {[GET $SA temp_freq] == -1} \
    {
      #       pop->sa_params->temperature = pop->sa_params->initial_temp
      #         + ((double)iteration/max_iterations)
      #         * (pop->sa_params->final_temp - pop->sa_params->initial_temp);

      #puts stderr "55555555555555555555" ;# мы сюда не попадаем ????
    } else {

      #       if (    pop->sa_params->temperature > pop->sa_params->final_temp
      #           && iteration%pop->sa_params->temp_freq == 0 )
      #       {
      #         pop->sa_params->temperature -= pop->sa_params->temp_step;
      #       }

      set t [GET $SA temperature]
      set f [GET $SA final_temp]

      set q [expr {$iteration % [GET $SA temp_freq]}]

      if {$t > $f  && $q == 0} \
      {
        #[GET $SA temperature] = [expr {[GET $SA temperature] - $SA.temp_step}]
        [GET $SA temperature] = [expr {[GET $SA temperature] - [GET $SA temp_step]}]
      }

      #puts stderr "6666666666666666666"
    }
    
    #  
    # Generate and score a new solution.
    # 
    #[GET $pop mutate]   $pop $best $putative
    [GET $pop mutate]   $pop $task $best $putative
    
    #[GET $pop evaluate] $pop       $putative
    
    #set task      [GET $pop  "TASK"]
    set eval_proc [GET $task "fit_func"]
    #$eval_proc $pop       $putative
    pop_eval_item $pop $putative $eval_proc $task

    #
    # Use the acceptance criterion to decide whether this new solution should
    # be selected or discarded.
    # 
    if {[[GET $SA sa_accept] $pop  $best $putative]} \
    {
      set   tmp    $best
      set  best    $putative
      set putative $tmp
    }
    
    # 
    # Save the current best solution in the initial entity, if this
    # is now the best found so far.
    # 

    if {[item_get_fitn $initial] < [item_get_fitn $best]} \
    {
      ga_entity_blank $pop $initial
      ga_entity_copy  $pop $initial $best
    }
    
    #     //
    #     // Use the iteration callback.
    #     //
    #     if (is_print)
    #       printf ("> After iteration %d, the current solution has fitness score of %f \n",
    #               iteration,
    #               best->fitness);
    
    if {$::is_print} { 
      puts [format "After iteration %d, the current solution has fitness score of %f" \
              $iteration [item_get_fitn $best]]
    }

  }  ;# // Iteration loop.
  

  if {$::is_print} { 
    puts ""

    pop_print $pop
  }

  #   //
  #   // Cleanup.
  #   //
  pop_del_entity  $pop $best     ;#       //??
  pop_del_entity  $pop $putative ;#
  
  return $iteration
}
# //******************************************************************************
# // 
# //------------------------------------------------------------------------------



# //****************************************************************************
# //****************************************************************************
# //****************************************************************************

#source "p-tabu.tl"

# //****************************************************************************

# -*-   mode: tcl  ; coding: koi8   -*- ----------------------------------------

if [info exists ::G_TABU_TL] {
  return
} else {
  set  ::G_TABU_TL ""
}

# ------------------------------------------------------------------------------

#   ga_tabu.c
#   ga_tabu - A tabu-search algorithm for comparison and local search.

#   Synopsis:     A tabu-search algorithm for comparison and local search.

#   		A novel population-based tabu-search is also provided.
# 		(Or at least it will be!)


#-------------------------------------------------------------------------------
# 
# Tabu-search parameter structure.
# 

# dictrecord define GA_TABU_T \
# {
#   list_length  ;# int	 /* Length of the tabu-list. */
#   search_count ;# int	 /* Number of local searches initiated at each iteration. */
#   tabu_accept  ;# GAtabu_accept /* Acceptance function. */
# }

# //------------------------------------------------------------------------------
# //  synopsis:   Compares two solutions with integer chromosomes and
# //	   	returns TRUE if, and only if, they are exactly
# //		identical.
# //------------------------------------------------------------------------------
# boolean 
# ga_tabu_check_integer (population *pop,
#                        entity	  *putative,
#                        entity	  *tabu)
# //------------------------------------------------------------------------------
# proc ga_tabu_check_integer {pop putative tabu} {


#   set a [ent_get_chromosome_ $putative]
#   set b [ent_get_chromosome_ $tabu]

#   set len  [GET $pop lsrc]
  
#   for {set j 0} {$j < $len} {incr j} {

#     set a_gen [lindex $a $j]
#     set b_gen [lindex $b $j]

#     if {$a_gen != $b_gen}  {return "FALSE"}
#   }

#   return "TRUE"
# }
# //------------------------------------------------------------------------------
# //  synopsis:   Checks the tabu list verses the putative solutions and
# //		chooses an acceptable solution.  Returns -1 if all
# //		putative solutions are tabu.
# //------------------------------------------------------------------------------
# int 
# gaul_check_tabu_list (population  *pop,
#                       entity	  **putative,
#                       entity	  **tabu)
# //------------------------------------------------------------------------------
proc  gaul_check_tabu_list {pop &putative tabu} {

  #set tabu_params [$pop.tabu_params]
  set tabu_params [GET $pop algo_params]


  USE_REFS

  #   int	    i;		/* Loop variable over putative solutions. */
  #   int	    j;		/* Loop variable over tabu list.          */
  #   boolean   is_tabu;	/* Whether current solution is tabu.      */
  
  for {set i 0} {$i < [GET $tabu_params search_count]} {incr i} \
  {
    set is_tabu "FALSE"
    
    for {set j 0} {1} {incr j} \
    {
      set t [lindex $tabu $j]
      
      #puts "gaul_check_tabu_list: t = $t"
        
      if {$j >= [GET $tabu_params list_length]} {break}
      if {$t       ==  "NULL"} {break}
      if {$is_tabu != "FALSE"} {break}
      
      set is_tabu [[GET $tabu_params tabu_accept] $pop $putative($i) $t]
    }
    
    if {$is_tabu == "FALSE"} {
      #  /* This solution is not tabu. */
      return $i
    }
  }
  
  #   // All solutions are tabu.
  #   // 

  return -1  
}
# //------------------------------------------------------------------------------
# //  synopsis:     Sets the tabu-search parameters for a population.
# //------------------------------------------------------------------------------
# void 
# ga_population_set_tabu_parameters (population    *pop,
#                                    GAtabu_accept  tabu_accept,
#                                    const int      list_length,
#                                    const int      search_count)
# //------------------------------------------------------------------------------
proc ga_population_set_tabu_parameters {pop
                                        tabu_accept
                                        list_length
                                        search_count} \
{
  if {$::is_print} {
    puts "> "
    puts [format "> Population's tabu-search parameters: list_length = %d search_count = %d " \
            $list_length $search_count]
  }
  

  set tabu_params [dict_create]

  #set tabu_params [GA_TABU_T \#auto]

  #--------------------------------------------------

  SET $tabu_params tabu_accept   $tabu_accept
  SET $tabu_params list_length   $list_length
  SET $tabu_params search_count  $search_count

  #--------------------------------------------------

  SET $pop algo_params   $tabu_params

}
# //------------------------------------------------------------------------------
# void update_tabu_list (population *pop,
#                        entity	**tabu_list,    
#                        entity    *best, 
#                        int    *p_tabu_list_pos 
#                        )
# //------------------------------------------------------------------------------
proc update_tabu_list {pop  &tabu_list best &p_tabu_list_pos} {

  #set tabu_params [$pop.tabu_params]
  set tabu_params [GET $pop algo_params]

  USE_REFS

  set tabu_list_pos  $p_tabu_list_pos
  
  set t [lindex $tabu_list $tabu_list_pos] ;# это вообще-то "entity"

  #puts ""
  #puts "update_tabu_list:  tabu_list= $tabu_list"
  #puts "update_tabu_list:  tabu_list_pos= $tabu_list_pos t= $t"
  #puts ""

  if {$t == "NULL"} \
  {
    lset tabu_list $tabu_list_pos [ga_entity_clone  $pop $best]
  } else {
    ga_entity_blank  $pop $t

    ga_entity_copy   $pop  $t $best
  }

  incr tabu_list_pos
  
  if { $tabu_list_pos >= [GET $tabu_params list_length] } {
    set tabu_list_pos  0
  } 
  
  set p_tabu_list_pos $tabu_list_pos
  
  #   return;
}
# //------------------------------------------------------------------------------
# entity *
# swap_putative_to_index (entity   *best,
#                     entity  **putative, int index
# //------------------------------------------------------------------------------
proc swap_putative_to_index {best &putative index} {

  USE_REFS
  #   entity   *tmp; 
  
  set tmp $best

  #   best = putative[index];
  set best $putative($index)

  #   putative[index] = tmp;
  set putative($index) $tmp
  
  return $best
}
# //------------------------------------------------------------------------------
# //  synopsis:	Performs optimisation on the passed entity by using a
# //  		simplistic tabu-search.  The local search and fitness
# //	       	evaluations are performed using the standard mutation
# //	       	and evaluation callback mechanisms, respectively.
# //		The passed entity will have its data overwritten.  The
# //		remainder of the population will be let untouched.
# //		Note that it is safe to pass a NULL initial structure,
# //		in which case a random starting structure wil be
# //		generated, however the final solution will not be
# //		available to the caller in any obvious way.
# //------------------------------------------------------------------------------
# int 
# ga_tabu (population	*pop,
#          entity		*initial,
#          const int	 max_iterations )
## //------------------------------------------------------------------------------
proc ga_tabu {task pop initial max_iterations} {


  set tabu_params [GET $pop algo_params]

  set iteration 0 ;# 	/* Current iteration number. 

  #   int	i, j;			/* Index into putative solution array. */
  #   entity	*best;			/* Current best solution.              */
  #   entity	**putative;		/* Current working solutions.          */
  #   //entity	*tmp;			/* Used to swap working solutions.     */
  #   entity	**tabu_list;		/* Tabu list.                          */

  #   int	tabu_list_pos = 0;	/* Index into the tabu list.           */
  set tabu_list_pos 0
  
  if {$::is_print} {
      puts "> "
      puts "> ga_tabu ..................................................... "
      #puts "> max_iterations = $max_iterations"
      puts "> "
  }
  
  
  #   // Prepare working entities. 
  
  #set best [ga_get_free_entity $pop] ;#   // The best solution so far.
  set best [get_free_and_init $pop $task] ;#   // The best solution so far.
  
  set search_count [GET $tabu_params search_count]
  set list_length  [GET $tabu_params list_length]

  #   if (! (putative = s_malloc (sizeof(entity *) * pop->tabu_params->search_count)))
  #     die ("Unable to allocate memory");
  
  for {set i 0} {$i < $search_count} {incr i} \
  {
    #set putative($i) [ga_get_free_entity $pop] ;#    // The 'working' solutions.
    set putative($i) [get_free_and_init $pop $task] ;#    // The 'working' solutions.
  }
  
  #   // Allocate and clear an array for the tabu list.
  #   if (! (tabu_list = s_malloc (sizeof(vpointer) * pop->tabu_params->list_length)))
  #     die ("Unable to allocate memory");
  
  for {set i 0} {$i < $list_length} {incr i} \
  {
    # tabu_list[i] = NULL;
    #lappend  tabu_list  $i "NULL" ;# !!!????  tabu_list= 0 NULL 1 NULL 2 NULL 3 NULL
    lappend  tabu_list "NULL"
  }
  
  #   // Do we need to generate a random starting solution?
  #   if (! initial)
  if {$initial == "NULL"} \
  {
    if {$::is_print} {
      puts "> Will perform tabu-search with random starting solution."
    }
    
    #set initial [ga_get_free_entity $pop]
    set initial [get_free_and_init $pop $task]
    #ga_entity_seed  $pop $best

  } else {   
    if {$::s_print} { 
      puts "> Will perform tabu-search with specified starting solution."
    }
  
    ga_entity_copy $pop $best $initial
  }
  
  set eval_proc [GET $task "fit_func"]
  #-------------------------------------------------

  #   //
  #   // Ensure that initial solution is scored.
  #   //
  if {[string equal [item_get_fitn $best]  $::GA_NOT_FIT]} {
    #pop->evaluate (pop, best);
    #puts "!!!!!!!!!!!!!!!!!!!!!!!!"
    #$eval_proc $pop $best
    pop_eval_item $pop $best $eval_proc $task
  }
  
  if {$::is_print} { 
    puts "> "
    puts [format \
            "> Prior to the first iteration, the current solution has fitness score of %f " \
            [item_get_fitn $best]]

    pop_print $pop
  }
  
  #   //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #   //
  #   // Do all the iterations:
  #   //
  #   // Stop when (a) max_iterations reached, or
  #   //           (b) "pop->iteration_hook" returns FALSE.
  #   //
  #   //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  
  while (1) {
  
    if {$::is_print} {
      puts "> "
      puts [format "> ITERATION LOOP ......... iteration = %d (%d)" \
              $iteration $max_iterations]

    } else {
      
      # //  pop->generation_hook?pop->generation_hook(generation, pop):TRUE; // печать через 10
      # pop->iteration_hook?pop->iteration_hook (iteration, best):TRUE ;
    }
  
    if {$iteration >= $max_iterations} {break}
    
    # iteration++;
    incr iteration
    
    #     // 
    #     // Generate and score new solutions.
    #     //
    for {set i 0} {$i < $search_count} {incr i} {

      #[GET $pop mutate]   $pop $best $putative($i)
      [GET $pop mutate]   $pop $task $best $putative($i)

      #set eval_proc [GET $pop evaluate]
      #$eval_proc  $pop  $putative($i)
      pop_eval_item $pop  $putative($i) $eval_proc $task
    }
    
#     if {$::is_print} { 
#       puts ""
#       puts "After MUTATE and EVALUATE: "
#       puts ""
      
#       pop_print $pop
#     }
    
    #     //
    #     // Sort new solutions (putative[0] will have highest rank).
    #     // We assume that there are only a small(ish) number of
    #     // solutions and, therefore, a simple bubble sort is adequate.
    #     //

    set rank_proc [GET $pop rank]

    for {set i 1} {$i < $search_count} {incr i} \
    {
      for {set j [expr {$search_count - 1}]} {$j >= $i} {incr j -1} \
        {
          #puts "i = $i  j = $j"
          #         if (pop->rank (pop, putative[j], pop, putative[j-1]) > 0 )
          if {[$rank_proc  $pop $putative($j) $pop $putative([expr {$j - 1}])] > 0 } \
          {	
            #           // Perform a swap.
            #           putative[j] = swap_putative_to_index (putative[j], putative, j-1);
            set putative($j) [swap_putative_to_index  $putative($j) putative [expr {$j - 1}] ]
          }
        }
    }
    
#     if {$::is_print} { 
#       puts ""
#       puts "POP_PRINT 11111111111 : "
#       puts ""
      
#       pop_print $pop
#     }

    #     //
    #     // Save best solution if it is an improvement, otherwise
    #     // select the best non-tabu solution (if any).
    #     // If appropriate, update the tabu list.
    #     //

    #     if (pop->rank (pop, putative[0], pop, best) > 0 )
    if {[$rank_proc  $pop $putative(0) $pop $best] > 0 } \
    {
      # best = swap_putative_to_index (best, putative, 0);
      set best [swap_putative_to_index  $best putative 0]

      # update_tabu_list (pop, tabu_list, best, &tabu_list_pos);
      update_tabu_list  $pop tabu_list $best tabu_list_pos

    } else {

      #set ::is_print 1
      #       if (-1 < (j = gaul_check_tabu_list (pop, putative, tabu_list)))
      if {-1 < [set j [gaul_check_tabu_list  $pop putative $tabu_list]] } \
      {
        #  best = swap_putative_to_index (best, putative, j);
        set best [swap_putative_to_index  $best putative $j]

        #  update_tabu_list (pop, tabu_list, best, &tabu_list_pos);
        update_tabu_list  $pop tabu_list $best tabu_list_pos

        #puts "111111111111111111111111111111111111111 j = $j"
        #puts "best = $best"
        #puts "tabu_list = $tabu_list"
      }
    }
    
    if {$::is_print} { 
      puts ""
      puts "POP_PRINT 22222222222 : "
      puts ""
      
      pop_print $pop
    }

    #     // Save the current best solution in the initial entity, if this
    #     // is now the best found so far.
    #     //

    #     if (pop->rank (pop, best, pop, initial) > 0)
    if {[$rank_proc  $pop $best  $pop $initial] > 0 } \
    {
      ga_entity_blank  $pop $initial
      ga_entity_copy   $pop $initial $best
    }
    
    if {$::is_print} { 
      puts ""
      puts "POP_PRINT 3333333333 : "
      puts ""
      
      pop_print $pop
    }


    #     // Use the iteration callback.
    #     //
    if {$::is_print} { 
      puts [format "> After iteration %d, the current solution has fitness score of %f" \
              $iteration [item_get_fitn $best]]
    }
    
    
  } ;#  // Iteration loop. 
  #   //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  
  
  if {$::is_print} { 
    puts ""
    puts "BEFORE CLEANUP: "
    puts ""

    pop_print $pop
  }
  #   //
  #   // Cleanup.
  #   //
  
  pop_del_entity  $pop $best
  
  for {set i 0} {$i < $search_count} {incr i} \
  {
    pop_del_entity $pop $putative($i)
  }
  
  if {$::is_print} { 
    puts ""
    puts "AFTER  CLEANUP part1: "
    puts ""

    pop_print $pop
  }

  if {1} {
  for {set i 0} {$i < $list_length} {incr i} \
  {
    #puts -nonewline [format "tabu_list: i= %2d  " $i ]

    set t [lindex $tabu_list $i]

    if {$t != "NULL"} {

      #ent_print_ch_ $t 

      pop_del_entity $pop $t

  } else {
    #puts -nonewline "t= NULL "
  }
    #puts ""

  }
  }

  if {$::is_print} { 
    puts ""
    puts "AFTER  CLEANUP part2: "
    puts ""

    pop_print $pop
  }

  #   s_free (putative);
  #   s_free (tabu_list);
  
  #   return iteration;
}
# //******************************************************************************
# //
# //------------------------------------------------------------------------------
  
  


# //****************************************************************************
# //----------------------------------------------------------------------------


