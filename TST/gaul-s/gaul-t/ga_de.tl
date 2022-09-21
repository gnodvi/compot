# /**********************************************************************
#   ga_de.c
#  **********************************************************************

#   ga_de - Differential Evolution.
#   Copyright б╘2005, Stewart Adcock <stewart@linux-domain.com>
#   All rights reserved.

#   Synopsis:     Differential Evolution.

# 		The DE algorithm was originally conceived by Rainer
# 		Storn and Ken Price.  The GAUL implementation is
# 		based in part on their "de36.c" reference source code.
# 		See http://www.icsi.berkeley.edu/~storn/code.html

# 		You may notice that this code includes equivalents of
# 		all of the original DE strategies along with a
# 		selection of additional strateties.

#  **********************************************************************/

# //#include "gцушa_de.h"
# #include "gaul.h"


# /**********************************************************************
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
proc ga_population_set_differentialevolution_parameters {pop            \
                                                    strategy            \
                                                    crossover           \
                                                    num_perturbed       \
                                                    weighting_min       \
                                                    weighting_max       \
                                                    crossover_factor} {

#   if ( !pop ) die("Null pointer to population structure passed.");

#   plog( LOG_VERBOSE, "Population's differential evolution parameters set" );

#   if (pop->de_params == NULL)
#   {
#     if ( !(pop->de_params = s_malloc(sizeof(ga_de_t))) )
#       die("Unable to allocate memory");
#   }

#   pop->de_params->strategy = strategy;
#   pop->de_params->crossover_method = crossover;
#   pop->de_params->num_perturbed = num_perturbed;
#   pop->de_params->weighting_min = weighting_min;
#   pop->de_params->weighting_max = weighting_max;
#   pop->de_params->crossover_factor = crossover_factor;

  $pop configure -de_strategy         $strategy
  $pop configure -de_crossover_method $crossover
  $pop configure -de_num_perturbed    $num_perturbed
  $pop configure -de_weighting_min    $weighting_min
  $pop configure -de_weighting_max    $weighting_max
  $pop configure -de_crossover_factor $crossover_factor

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
      set pos [expr $j + [random_int [expr $size - $j]]]
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
  
  if {$::is_print} {
    puts -nonewline "  calc_tmpentity_11 .. n= $n "
  }


  set p0 [lindex $perm 0]
  set p1 [lindex $perm 1]

  #set e1 [$pop get_entity $p0]
  #set e2 [$pop get_entity $p1]

  set e1 [pop_get_entity_ $pop  $p0]
  set e2 [pop_get_entity_ $pop  $p1]

  set g1 [ent_get_chromo_gen_ $e1  $n]
  set g2 [ent_get_chromo_gen_ $e2  $n]

  #   double diff = ((double *) pop->entity_iarray[perm[0]]->CH)[n]
  #               - ((double *) pop->entity_iarray[perm[1]]->CH)[n];

  set diff [expr $g1 - $g2]

  #   ((double *)tmpentity->CH)[n] =
  #     ((double *)pop->entity_iarray[i0]->CH)[n] + weighting_factor * diff;

  #set e0    [$pop get_entity $i0]
  set e0    [pop_get_entity_ $pop  $i0]

  set n_gen [ent_get_chromo_gen_ $e0  $n]

  set   gen [expr $n_gen + $weighting_factor * $diff]

  if {$::is_print} {
    $e1 print_ch "  e1= "
    puts -nonewline [format "  g1= %f "  $g1]
    puts ""
  }

  #$tmpentity set_chromo_gen  $n $gen
  ent_set_chromo_gen_ $tmpentity  $n $gen

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

  set g1 [ent_get_chromo_gen_ $e1 $n]
  set g2 [ent_get_chromo_gen_ $e2 $n]
  set g3 [ent_get_chromo_gen_ $e3 $n]
  set g4 [ent_get_chromo_gen_ $e4 $n]

  set diff [expr $g1 + $g2 - $g3 - $g4]

#   ((double *)tmpentity->CH)[n] =
#     ((double *)pop->entity_iarray[i0]->CH)[n] + weighting_factor * diff;

  #set i0_entity   [$pop get_entity $i0]
  set i0_entity   [pop_get_entity_ $pop  $i0]

  set i0_entity_n_gen [ent_get_chromo_gen_ $i0_entity $n]

  #$tmpentity set_chromo_gen $n [expr {$i0_entity_n_gen + $weighting_factor * $diff}]
  ent_set_chromo_gen_ $tmpentity $n [expr {$i0_entity_n_gen + $weighting_factor * $diff}]

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

  set g1 [ent_get_chromo_gen_ $e1 $n]
  set g2 [ent_get_chromo_gen_ $e2 $n]
  set g3 [ent_get_chromo_gen_ $e3 $n]
  set g4 [ent_get_chromo_gen_ $e4 $n]
  set g5 [ent_get_chromo_gen_ $e5 $n]
  set g6 [ent_get_chromo_gen_ $e6 $n]

#   double diff = (((double *) pop->entity_iarray [perm[0]]->CH)[n]
#                + ((double *) pop->entity_iarray [perm[1]]->CH)[n]
#                + ((double *) pop->entity_iarray [perm[2]]->CH)[n]
#                - ((double *) pop->entity_iarray [perm[3]]->CH)[n]
#                - ((double *) pop->entity_iarray [perm[4]]->CH)[n]
#                - ((double *) pop->entity_iarray [perm[5]]->CH)[n]);

  set diff [expr $g1 + $g2 + $g3  - $g4 - $g5 - $g6]

#   ((double *)tmpentity->CH)[n] = 
#     ((double *) pop->entity_iarray[i0]->CH)[n] + weighting_factor * diff;

  #set i0_entity   [$pop get_entity $i0]
  set i0_entity   [pop_get_entity_ $pop  $i0]

  set i0_entity_n_gen [ent_get_chromo_gen_ $i0_entity $n]

  #$tmpentity set_chromo_gen $n [expr {$i0_entity_n_gen + $weighting_factor * $diff}]
  ent_set_chromo_gen_ $tmpentity $n [expr {$i0_entity_n_gen + $weighting_factor * $diff}]

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

  set g1 [ent_get_chromo_gen_ $e1 $n]
  set g2 [ent_get_chromo_gen_ $e2 $n]
  set g3 [ent_get_chromo_gen_ $e3 $n]
  set g4 [ent_get_chromo_gen_ $e4 $n]

  set diff [expr $g1 - $g2 + $g3  - $g4]


  #$tmpentity set_chromo_gen $n  [expr {$g2 + $weighting_factor * $diff}]
  ent_set_chromo_gen_ $tmpentity $n  [expr {$g2 + $weighting_factor * $diff}]

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

  set g1 [ent_get_chromo_gen_ $e1 $n]
  set g2 [ent_get_chromo_gen_ $e2 $n]
  set g3 [ent_get_chromo_gen_ $e3 $n]
  set g4 [ent_get_chromo_gen_ $e4 $n]
  set g5 [ent_get_chromo_gen_ $e5 $n]
  set g6 [ent_get_chromo_gen_ $e6 $n]

  set diff [expr $g1 - $g2 + $g3 + $g4 - $g5 - $g6]


  #$tmpentity set_chromo_gen $n  [expr {$g2 + $weighting_factor * $diff}]
  ent_set_chromo_gen_ $tmpentity $n  [expr {$g2 + $weighting_factor * $diff}]

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
proc DE_best_exp {pop i n best tmpentity &name_permutation weighting_factor  \
                 N  calc_proc } {

  USE_REFS

  set len_chromosomes [$pop cget -len_chromosomes]

  _gaul_pick_random_entities   name_permutation $N [$pop cget -orig_size] $i
  set L   0


  while (1) {
    
    $calc_proc  $pop $n $best $tmpentity $name_permutation $weighting_factor 
       
    set n [expr ($n + 1) % $len_chromosomes]
    incr L

    set flag [random_boolean_prob [$pop cget -de_crossover_factor]]  
    if {! $flag} { break; } ;# вообще заканчиваем цикл ! и выходим
    
    if {! [expr $L < $len_chromosomes]} { break; }
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

  _gaul_pick_random_entities   name_permutation 2 [$pop cget -orig_size] $i
      

  calc_tmpentity2  $pop $n $best $tmpentity $name_permutation $weighting_factor 

  set len_chromosomes [$pop cget -len_chromosomes]
  set L   1


  while (1) {

    if {! [expr $L < $len_chromosomes]} { break; }

    set flag [random_boolean]

    if {$flag} {
      calc_tmpentity2  $pop $n $best $tmpentity $name_permutation $weighting_factor 
    }
    # // а здесь не заканчиваем, но продолжаем!
    
    set n [expr ($n + 1) % $len_chromosomes]
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
proc DE_best_bin {pop i n best tmpentity  &name_permutation weighting_factor \
                 N calc_proc} {
  
  USE_REFS

  _gaul_pick_random_entities   name_permutation $N [$pop cget -orig_size] $i
  
  $calc_proc  $pop $n $best $tmpentity $name_permutation $weighting_factor 

  set len_chromosomes [$pop cget -len_chromosomes]


  for {set L 1} {$L < $len_chromosomes} {incr L} {

    set flag [random_boolean]
   if {$flag} {
     $calc_proc  $pop $n $best $tmpentity $name_permutation $weighting_factor 
    }

    set n [expr ($n + 1) % $len_chromosomes]
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
  
#   for (L=1; L<pop->len_chromosomes; L++)
#   {
#     if (random_boolean ()) {
#       calc_tmpentity7 (pop, n, best, tmpentity, permutation, weighting_factor); 
#     }

#     n = (n+1) % pop->len_chromosomes;
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

  
#   for (L=1; L < pop->len_chromosomes; L++)
#   {
#     if ( random_boolean() )
#       calc_tmpentity_2bin (pop, n, best, 
#                            tmpentity, permutation, weighting_factor);

#     n = (n+1)%pop->len_chromosomes;
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
  
  set strategy         [$pop cget -de_strategy]
  set num_perturbed    [$pop cget -de_num_perturbed]
  
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

  set strategy         [$pop cget -de_strategy]
  set num_perturbed    [$pop cget -de_num_perturbed]
  

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
    
    for {set i $i0} {$i < [$pop cget -size]} {incr i} {
      
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

  $pop configure -best $best ;# и занесем сразу номер лучшего элемента

  return $best
}
# ------------------------------------------------------------------------------
# //  synopsis:	Performs differential evolution. 

# GAULFUNC int ga_differentialevolution (population  *pop,
#                                        const int  max_generations)
# {
#   int		generation = 0;		/* Current generation number. */
# //------------------------------------------------------------------------------
proc prepare_permutation {size} {


  if {$::is_print} {
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
proc pop_eliminate {pop} {

  #//
  #// Eliminate the original population members.
  #//

  #while (pop->orig_size > 0)
  #{
  #  pop->orig_size--;
  #  ga_entity_dereference_by_rank (pop, pop->orig_size);
  #}

  # у нас есть возможность сделать все проще! н
  # задача: удалить старую популяцию. т.е. первые orig_size элементов:

  #$pop eliminate
  pop_eliminate_ $pop

  return
}
#-------------------------------------------------------------------------------
proc ga_differentialevolution	{pop max_generations} {

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
  #   if (pop->stable_size < 6) die ("Population's stable size is too small.  (Must be at least 6)");
  #   if ( pop->de_params->crossover_factor < 0.0 ||
  #       pop->de_params->crossover_factor > 1.0 )
  #     die ("Invalid crossover_factor.");
  
  #   plog (LOG_VERBOSE, "The differential evolution has begun!");
  
  #   pop->generation = 0;
  $pop configure -generation 0
 
  # 
  # Score the initial population members.
  #  

  set size        [$pop cget -size]
  set stable_size [$pop cget -stable_size]

  #puts "size        = $size"
  #puts "stable_size = $stable_size"

  # вот это что тут за фигня? если популяция не полна, то дополнить новыми членами?
  # 
  #   if (pop->size < pop->stable_size) {
  #     gaul_population_fill (pop, pop->stable_size - pop->size);
  #   }
  

  # зачем здесь отдельно для нулевого?
  # 
  #   if (pop->entity_iarray[0]->fitness == GA_MIN_FITNESS) {
  #     pop->evaluate(pop, pop->entity_iarray[0]);
  #   }
  
  #   /* #pragma omp parallel for \ */
  #   /*    shared(pop) private(i) \ */
  #   /*    schedule(static) */
  

  for {set i 0} {$i < $size} {incr i} {

    #  if (pop->entity_iarray[i]->fitness == GA_MIN_FITNESS)
    #      pop->evaluate(pop, pop->entity_iarray[i]);

    #set entity [$pop get_entity $i]
    set entity [pop_get_entity_ $pop  $i]

    #puts "i = $i   entity = $entity"
 
    if {[$entity cget -fitness] == $::GA_MIN_FITNESS} {
      #puts "i = $i"
      [$pop cget -evaluate] $pop $entity
    }
  }
  

  set permutation [prepare_permutation  [$pop cget -size]]
  
  #
  # Determine weighting factor. (в ходе генерации не меняется, я предположил..)
  #   
  set weighting_min [$pop cget -de_weighting_min]
  set weighting_max [$pop cget -de_weighting_max]
  
  # gaul.h.tl:
  #
  # int ga_rank_fitness (population *alphapop, entity *alpha, population *betapop, entity *beta);
  
  set rank_proc [$pop cget -rank]

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

    if {$::is_print} {
      puts ""
      puts "GENERATION LOOP ......... generation = $generation"
      puts ""
    } else {

      #pop->generation_hook (generation, pop); // печать через 10
      [$pop cget -generation_hook]  $generation $pop ; #// печать через 10
    }

    if {$generation >= $max_generations} {break}

    # хитроумный трюк здесь и в конце
    $pop configure -orig_size  [$pop cget -size] 

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
    $pop configure -generation $generation


    # ~~~~~~~~~~~~~~~~~ I LOOP BEGIN ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    # 
    # цикл по каждому элементу I, для его корректировки
    
    for {set i 0} {$i < [$pop cget -orig_size]} {incr i} {

      if {$::is_print} {
        puts ""
        puts [format "i= %2d ...................................." $i]
        puts ""
        
        $pop print_lite
        puts ""
      }

      #set oldentity [$pop get_entity $i]
      set oldentity [pop_get_entity_ $pop  $i]

      if {$::is_print} {
        print_entit  $oldentity "OLDENTITY ="
      }

      # tmpentity = ga_entity_clone (pop, pop->entity_iarray[i]);
      #
      # в оригинале здесь было клонирование с добавлением в массив, но мы хотим
      # сделать без добавления:
      # 
      set tmpentity [ga_entity_clone_without_add $pop $oldentity]

      set n [random_int [$pop cget -len_chromosomes]] ;# случайный номер гена

      #
      # Note that the following code may appear bloated due to excessive
      # extraction of branches from loops.
      # However, this yields much more efficient code (particularly for larger
      # chromosomes) on less-than-cutting-edge compilers.
      # 

      set crossover_method [$pop cget -de_crossover_method]
      set strategy         [$pop cget -de_strategy]
      set num_perturbed    [$pop cget -de_num_perturbed]

      if {$::is_print} {
        print_entit  $tmpentity "TMPENTITY ="
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

      if {$::is_print} {
        print_entit  $tmpentity "TMPENTITY ="
      }

      # посчитаем фитнес для нового элемента and restore the former chromosome 
      # values if this new solution is not an improvement
      # 
      set is_edone [[$pop cget -evaluate] $pop $tmpentity] 
 
      if { ! $is_edone}  {
        puts ""
        puts "ERROR : not is_edone !!!"
        puts ""
        exit
      }

      set old_fit  [$oldentity cget -fitness]
      set new_fit  [$tmpentity cget -fitness]

      if {$rank_proc == "ga_rank_fitness"} {
        set is_worse [expr  $old_fit > $new_fit] 
      } else {
        set is_worse [expr [rank_proc  $pop $tmpentity $pop $oldentity] < 0 ]
        # is_worse = (pop->rank (pop, tmpentity, pop, pop->entity_iarray[i]) < 0 );
      }
      
      
      if {$::is_print} {
        puts -nonewline [format "  n= %d  old = %f .. new = %f "  \
                           $n $old_fit $new_fit]
      }

      if {$is_worse}  {
        # все только ухудшилось
      
        ga_entity_blank  $pop $tmpentity            ;# обнулить фитнес ?     
        ga_entity_copy   $pop $tmpentity $oldentity ;# $tmpentity <- $oldentity
        #
        # так оно ж (копирование) не работало ?? !!

        if {$::is_print} { puts "" }

        #$pop add_entity $oldentity ;# "перезапишем" на старое
        pop_add_entity_ $pop  $oldentity ;# "перезапишем" на старое

      } else {
        # ура, улучшилось !!
        #
        if {$::is_print} { puts [format " .... OK !!"] }

        #$pop set_entity $i $tmpentity ;# перезапишем на новое
        #
        # но по си-шному алгоритму этот элемент добавлен уже в конец массива при
        # вызове функций ga_entity_clone -> ga_get_free_entity, но мы поменяли на:
        #                
        #
        # здесь попробуем это симитировать, добавив его сейчас в конец:
        #
        #$pop add_entity $tmpentity
        pop_add_entity_ $pop  $tmpentity
      }
      
    } ;

    # // 
    # // ~~~~~~~~~~~~~~~~~ I LOOP FINAL ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    if {$::is_print} {
      puts ""
      puts "I LOOP FINAL ........................................."
      puts ""
      
      puts ""
      $pop print
      puts ""
      
      puts  "Eliminate the original population members ..... "
    }
    
    pop_eliminate $pop
    
    if {$::is_print} {
      puts ""
      $pop print
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
  sort_population $pop
  
  if {$::is_print} {
    puts ""
    $pop print
    puts ""
  }
  
  #   /*
  #     * Clean-up.
  #     */
  #   s_free (permutation);
  
   return $generation
}
# //******************************************************************************
# //------------------------------------------------------------------------------

# //****************************************************************************


