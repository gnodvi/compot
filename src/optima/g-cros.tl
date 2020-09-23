# -*-   mode: tcl  ; coding: koi8   -*- ----------------------------------------


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
    [ent_CH_ $father ] [ent_CH_ $mother]    son_CH  daughter_CH

  ent_set_chromosome_ $son      $son_CH
  ent_set_chromosome_ $daughter $daughter_CH

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

      ent_set_chromo_gen_ $son      $j  [ent_get_chromo_gen_ $father $j]
      ent_set_chromo_gen_ $daughter $j  [ent_get_chromo_gen_ $mother $j]

    } else {

      ent_set_chromo_gen_ $daughter $j  [ent_get_chromo_gen_ $father $j]
      ent_set_chromo_gen_ $son      $j  [ent_get_chromo_gen_ $mother $j]
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

  set father_CH  [ent_CH_ $father]
  set mother_CH  [ent_CH_ $mother]

  memcpy  son_chromo 0  $father_CH 0  $location1
  memcpy  dau_chromo 0  $mother_CH 0  $location1
  
  memcpy  son_chromo $location1  $mother_CH $location1  [expr {$location2 - $location1}]
  memcpy  dau_chromo $location1  $father_CH $location1  [expr {$location2 - $location1}]
  
  memcpy  son_chromo $location2  $father_CH $location2  [expr {$len_chromo - $location2}]
  memcpy  dau_chromo $location2  $mother_CH $location2  [expr {$len_chromo - $location2}]


  # и запишем по адресу:
  #
  ent_set_chromosome_ $son      $son_chromo
  ent_set_chromosome_ $daughter $dau_chromo

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

  ga_doublepoint_crossover_double_chromosome  $pop [ent_CH_ $father] [ent_CH_ $mother ] \
                                                   son_CH  daughter_CH

  ent_set_chromosome_ $son      $son_CH
  ent_set_chromosome_ $daughter $daughter_CH

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

  #set amin $::allele_min_integer
  #set amax $::allele_min_integer

  for {set point 0} {$point < [GET $pop len_chromosomes]} {incr point} \
  {
    # ((int *)adam->CH/* chromosome[chromo] */)[point] =
    #   random_int_range(pop->allele_min_integer,pop->allele_max_integer);

    set r [random_int_range  $amin $amax]

    #$adam set_chromo_gen $point $r 
    ent_set_chromo_gen_ $adam $point $r 
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
proc ga_population_set_allele_min_integer {pop value}  {


  SET $pop  allele_min_integer $value
  #set ::allele_min_integer $value 

  return
}
#-------------------------------------------------------------------------------
#   synopsis:	Sets the maximum value for an integer allele for a
# 		population.
#-------------------------------------------------------------------------------
proc ga_population_set_allele_max_integer {pop value}  {


  SET $pop  allele_max_integer $value
  #set ::allele_max_integer $value 

  return
}
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

  #   //int		i;		/* Loop variable over all chromosomes */
  #   int		chromo;		/* Index of chromosome to mutate */
  #   int		point;		/* Index of allele to mutate */
  #   int		dir=random_boolean()?-1:1;	/* The direction of drift. */
  
  if {[random_boolean]} {
    set dir -1
  } else {
    set dir  1
  }

  #   /* Checks */
  #   if (!father || !son) die("Null pointer to entity structure passed");
  
  #   /* Select mutation locus. */
  #   random_int (1/* pop->num_chromosomes */);
  random_int 1

  set len_chromo [GET $pop len_chromosomes]

  #   chromo =  0; 
  set chromo    0
  #   point  = (int) random_int (pop->len_chromosomes);
  set point [random_int  $len_chromo]
  
  #   /*
  #     * Copy unchanged data.
  #     */
  #   //i = 0;
  #   //for (i=0; i<pop->num_chromosomes; i++)
  #   //{

  #   memcpy (son->CH/* chromosome[i] */, father->CH/* chromosome[i] */, pop->len_chromosomes*sizeof(int));
  #$son set_chromosome [$father get_chromosome]
  #set_chromosome_ $son [$father get_chromosome]
  ent_set_chromosome_ $son [ent_get_chromosome_ $father]

  # /*   if (i!=chromo) */
  # /*   { */
  # /*     ga_copy_data(pop, son, father, i); */
  # /*   } */
  # /*   else */
  # /*   { */
  #   ga_copy_data (pop, son, NULL, 0/* i */); - надо ли это ???????????
  # /*   } */
  #   //}
  
  set allele_max_integer [GET $pop allele_max_integer]
  set allele_min_integer [GET $pop allele_min_integer]

  #   /*
  #     * Mutate by tweaking a single allele.
  #     */
  #   ((int *)son->chromosome[chromo])[point] += dir;
  #
  set point_gen [ent_get_chromo_gen_ $son  $point] ;# старое значение
  set point_gen [expr {$point_gen + $dir}]  ;# новое  значение

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #   if (((int *)son->chromosome[chromo])[point] > pop->allele_max_integer)
  #     ((int *)son->chromosome[chromo])[point] = pop->allele_min_integer;
  
  if {$point_gen > $allele_max_integer} {
    if {$::is_print} {
      puts "  > allele_max_integer"
    }
    set point_gen $allele_min_intege ;# скорректировали
  }

  #   if (((int *)son->chromosome[chromo])[point] < pop->allele_min_integer)
  #     ((int *)son->chromosome[chromo])[point] = pop->allele_max_integer;
  
  if {$point_gen < $allele_min_integer} {
    if {$::is_print} {
      puts "  < allele_min_integer"
    }
    set point_gen  $allele_max_intege ;# скорректировали
  }
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  #$son set_chromo_gen  $point $point_gen ;# записали новое значение
  ent_set_chromo_gen_ $son  $point $point_gen ;# записали новое значение

  return
}
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#   synopsis:	Cause a single mutation event in which a single
# 		allele is cycled.
#-------------------------------------------------------------------------------
# void 
# ga_mutate_printable_singlepoint_drift (population *pop,
#                                        entity *father, entity *son)
#-------------------------------------------------------------------------------
proc ga_mutate_printable_singlepoint_drift {pop father son}  {


  # The direction of drift. 
  
  if {[random_boolean]} {
    set dir -1
  } else {
    set dir  1
  }

  #   /* Select mutation locus. */
  #   /* chromo =  (int) */ random_int (1/* pop->num_chromosomes */);

  random_int 1
  set len_chromo [GET $pop len_chromosomes]

  set chromo    0
  set point [random_int  $len_chromo]
  

  ent_set_chromosome_ $son [ent_get_chromosome_ $father] ;# ????

  #   /*
  #     * Mutate by tweaking a single allele.
  #     */

  set point_gen [ent_get_chromo_gen_ $son  $point] ;# старое значение
  set point_gen [expr {$point_gen + $dir}]  ;# новое  значение


  set char_min_num [scan " " "%c"]
  set char_max_num [scan "~" "%c"] 
    
  if {$point_gen > $char_max_num} {
    set point_gen $char_min_num ;# скорректировали
  }

  if {$point_gen < $char_min_num} {
    set point_gen $char_max_num ;# скорректировали
  }


  ent_set_chromo_gen_ $son  $point $point_gen ;# записали новое значение

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
  #ent_set_chromosome_ $son [$father get_chromosome]
  ent_set_chromosome_ $son [ent_get_chromosome_ $father]

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
  set point_gen [ent_get_chromo_gen_ $son  $point] ;# старое значение
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
#     puts "  ent_set_chromo_gen_:  point_gen= $point_gen  amount= $amount  allele_min_double= $allele_min_double"
#   }

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #if (((double *)son->CH)[point] > allele_max_double)
  #  ((double *)son->CH)[point] -= (allele_max_double - allele_min_double);

  if {$point_gen > $allele_max_double} {
    if {$::is_print} {
      puts "  > allele_max_double"
    }
    set point_gen [expr {$point_gen - $allele_correct}] ;# скорректировали
  }

  #if (((double *)son->CH)[point] < allele_min_double)
  #  ((double *)son->CH)[point] += (allele_max_double - allele_min_double);
  
  if {$point_gen < $allele_min_double} {
    if {$::is_print} {
      puts "  < allele_min_double"
    }
    set point_gen [expr {$point_gen + $allele_correct}] ;# скорректировали
  }
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  
  if {$::is_print} {
    #pop_print $pop
    puts "  ent_set_chromo_gen_: point= $point point_gen= $point_gen"
  }

  #$son set_chromo_gen  $point $point_gen ;# записали новое значение
  ent_set_chromo_gen_ $son  $point $point_gen ;# записали новое значение

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
  

  if {$::is_print == 2.2} {
    puts "gaul_crossover : (select_two_proc = [GET $pop select_two])"
    puts ""
  }
  
  set select_two_proc [GET $pop select_two]

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


  if {$::is_print == 2.2} {
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
  
  if {$::is_print == 2.2} {
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
# //------------------------------------------------------------------------------
# proc sort_and_genocide {pop} \
# {

#   # сортируем всех челнов популяции по фитнесу
#   #  
#   sort_population $pop

#   # Убиваем наименее приспособленных членов популяции, чтобы восстановить 
#   # численность до ее стабильного первоначального размера.
#   #

#   ga_genocide  $pop [GET $pop stable_size]

#   return
# }
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


  if {$::is_print == 2.2} {
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

  if {$::is_print == 2.2} {
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

  if {$::is_print == 2.2} {

    puts stderr "crossover_mutation_adapt_survival ... "
    puts ""
    pop_print $pop "stderr" ; puts ""
  }

  #-----------------------------------------------------------------
  #  Crossover step 
  #  
  gaul_crossover $pop $task ;# выбираются мама и папа и затем скрещиваются 
                       # в новых (созданных) членов общества !!
  
  if {$::is_print == 2.2} {pop_print $pop "stderr" ; puts ""}

  #-----------------------------------------------------------------
  # Mutation step
  #  

  gaul_mutation $pop $task ;# муитруем в новых членов общества !!
  
  if {$::is_print == 2.2} {pop_print $pop "stderr" ; puts ""}

  #-----------------------------------------------------------------
  # Apply environmental adaptations, score entities, sort entities, etc.
  #  
 
  gaul_adapt_and_evaluate $pop $task ;# а где же сортировка?
  
  if {$::is_print == 2.2} {pop_print $pop "stderr" ; puts ""}

  #-----------------------------------------------------------------
  # Survival of the fittest (выживание наиболее приспособленных)
  # 
  # GA_ELITISM_PARENTS_DIE     (FS)
  # GA_ELITISM_PARENTS_SURVIVE (_2_main_ 
  # 

  gaul_survival $pop ;# что-то делаем с получившемся набором старых и новых 
    

  if {$::is_print == 2.2} {pop_print $pop "stderr" ; puts ""}

  #-----------------------------------------------------------------
  # сортируем всех челнов популяции по фитнесу
  # 
 
  sort_population $pop

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
proc gaul_migration {num_pops pops} {

  
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
    sort_population [lindex $pops $i];
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
  
  
  if ($::is_print) {

    puts ""
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
    gaul_migration  $num_pops $pops
    
    
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








