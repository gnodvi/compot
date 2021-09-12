; -*-   mode: lisp ; coding: koi8   -*- ----------------------------------------

;-------------------------------------------------------------------------------
;#   ga_crossover.c

;#   ga_crossover - Genetic algorithm crossover operators.
;#   Copyright б╘2000-2006, Stewart Adcock <stewart@linux-domain.com>
;#   All rights reserved.

;#   Synopsis:     Routines for performing GA crossover operations.

;# 		These functions should duplicate user data where
;# 		appropriate.

;#   To do:	Merge static crossover functions by passing datatype size.

;#  **********************************************************************/


;# //------------------------------------------------------------------------------
;# // `Mates' two chromosomes by single-point crossover.
;# //------------------------------------------------------------------------------
;# void 
;# ga_singlepoint_crossover_integer_chromosome (population *pop,
;#                                              int *father, int *mother,
;#                                              int *son, int *daughter )

;# //------------------------------------------------------------------------------
;proc ga_singlepoint_crossover_integer_chromosome {pop  father_CH  mother_CH \
;                                                        &son_CH    &dau_CH} {

;  USE_REFS

;  #   int  location; // Point of crossover  
;  #   if (!father || !mother || !son || !daughter)
;  #     die ("Null pointer to integer-array chromosome structure passed.");
  
;  set len_chromo [$pop cget -len_chromosomes]

;  # Choose crossover point and perform operation 
;  #
;  set location [random_int  $len_chromo]
  
;  set son_chromo [make_list $len_chromo 0]
;  set dau_chromo [make_list $len_chromo 0]

;  #   memcpy (     son, mother, location*sizeof(int));
;  #   memcpy (daughter, father, location*sizeof(int));
  
;  #   memcpy (&(     son[location]), &(father[location]), (pop->len_chromosomes-location)*sizeof(int));
;  #   memcpy (&(daughter[location]), &(mother[location]), (pop->len_chromosomes-location)*sizeof(int));
  
;  memcpy  son_chromo 0  $mother_CH 0  $location
;  memcpy  dau_chromo 0  $father_CH 0  $location
  
;  memcpy  son_chromo $location  $father_CH $location  [expr {$len_chromo - $location}]
;  memcpy  dau_chromo $location  $mother_CH $location  [expr {$len_chromo - $location}]

;  # и запишем по адресу:
;  #
;  set son_CH $son_chromo
;  set dau_CH $dau_chromo
  
;  return
;}
;# //------------------------------------------------------------------------------
;# //  `Mates' two chromosomes by double-point crossover.
;# //------------------------------------------------------------------------------
;# void 
;# ga_doublepoint_crossover_integer_chromosome (population *pop,
;#                                              int *father, int *mother,
;#                                              int *son, int *daughter)

;# //------------------------------------------------------------------------------
;#
;# !!!! это один в один с ga_doublepoint_crossover_double...., но еам нужна другая!
;#
;# //------------------------------------------------------------------------------
;proc ga_doublepoint_crossover_integer_chromosome {pop  father_CH  mother_CH \
;                                                        &son_CH    &dau_CH} {

;  USE_REFS

;  #   int	location1, location2;	/* Points of crossover. */
;  #   int	tmp;			/* For swapping crossover loci. */
  
;  #   if (!father || !mother || !son || !daughter)
;  #     die ("Null pointer to integer-array chromosome structure passed.");
  
;  set len_chromo [$pop cget -len_chromosomes]

;  #   /* Choose crossover point and perform operation */

;  set location1 [random_int  $len_chromo]

;  #   do
;  #   {
;  #     location2 = random_int (pop->len_chromosomes);
;  #   } while (location2 == location1);
  
;  while {1} {
;    set  location2 [random_int  $len_chromo]
;    if {$location2 != $location1} {break}
;  }

;  #// получили две несовпадающие точки (целочисленные)

;  if {$location1 > $location2} {

;    set tmp $location1
;    set location1 $location2
;    set location2 $tmp
;  }
  
;  #// теперь они в нужном порядке (по возрастающей)

;  set son_chromo [make_list $len_chromo 0]
;  set dau_chromo [make_list $len_chromo 0]

;  #   memcpy (     son, father, location1*sizeof(int));
;  #   memcpy (daughter, mother, location1*sizeof(int));
  
;  #   memcpy (&(     son[location1]), &(mother[location1]), (location2-location1)*sizeof(int));
;  #   memcpy (&(daughter[location1]), &(father[location1]), (location2-location1)*sizeof(int));
  
;  #   memcpy (&(     son[location2]), &(father[location2]), (pop->len_chromosomes-location2)*sizeof(int));
;  #   memcpy (&(daughter[location2]), &(mother[location2]), (pop->len_chromosomes-location2)*sizeof(int));
  
;  memcpy  son_chromo 0  $father_CH 0  $location1
;  memcpy  dau_chromo 0  $mother_CH 0  $location1
  
;  memcpy  son_chromo $location1  $mother_CH $location1  [expr {$location2 - $location1}]
;  memcpy  dau_chromo $location1  $father_CH $location1  [expr {$location2 - $location1}]
  
;  memcpy  son_chromo $location2  $father_CH $location2  [expr {$len_chromo - $location2}]
;  memcpy  dau_chromo $location2  $mother_CH $location2  [expr {$len_chromo - $location2}]

;  # и запишем по адресу:
;  #
;  set son_CH $son_chromo
;  set dau_CH $dau_chromo
  
;  return
;}
;# //------------------------------------------------------------------------------
;# //  `Mates' two genotypes by single-point crossover of
;# //   each chromosome.
;# //------------------------------------------------------------------------------
;# void 
;# ga_crossover_integer_singlepoints (CROSSOVER_VALS)

;# //------------------------------------------------------------------------------
(defun ga_crossover_integer_singlepoints (pop father mother son daughter)


  ;;  #   ga_singlepoint_crossover_integer_chromosome (pop,
  ;;  #                                                (int *)  father->CH,
  ;;  #                                                (int *)  mother->CH,
  ;;  #                                                (int *)     son->CH,
  ;;  #                                                (int *)daughter->CH);
  
  ;;  ga_singlepoint_crossover_integer_chromosome  $pop [ent_CH_ $father ] [ent_CH_ $mother] \
  ;;                                                   son_CH  daughter_CH

  (declare (special son_CH  daughter_CH))

  (ga_singlepoint_crossover_integer_chromosome  pop  
                                                (ent_CH_ father) 
                                                (ent_CH_ mother)
                                                'son_CH  'daughter_CH)


  (ent_set_chromosome_  son       son_CH)
  (ent_set_chromosome_  daughter  daughter_CH)

  ;;  return
)
;# //------------------------------------------------------------------------------
;# //  `Mates' two genotypes by randomizing the parents
;# //   alleles.
;# //   Keeps no chromosomes intact, and therefore will
;# //   need to recreate all structural data.
;# //------------------------------------------------------------------------------
;# void 
;# ga_crossover_char_allele_mixing (CROSSOVER_VALS)
;# //------------------------------------------------------------------------------
;proc ga_crossover_char_allele_mixing {pop father mother son daughter} \
;{

;  # USE_REFS не надо ???????
;  # а нет, здесь же entity !

;  #   int	j;    /* Loop over all chromosomes, alleles. */
  
;  #   if (!father || !mother || !son || !daughter)
;  #     die ("Null pointer to entity structure passed.");
  
;  for {set j 0} {$j < [$pop cget -len_chromosomes]} {incr j} \
;  {
;    if {[random_boolean]} \
;    {
;      #  ((char *)     son->CH)[j] = ((char *)father->CH)[j];
;      #  ((char *)daughter->CH)[j] = ((char *)mother->CH)[j];

;      ent_set_chromo_gen_ $son      $j  [ent_get_chromo_gen_ $father $j]
;      ent_set_chromo_gen_ $daughter $j  [ent_get_chromo_gen_ $mother $j]

;    } else {
;      #  ((char *)daughter->CH)[j] = ((char *)father->CH)[j];
;      #  ((char *)     son->CH)[j] = ((char *)mother->CH)[j];

;      ent_set_chromo_gen_ $daughter $j  [ent_get_chromo_gen_ $father $j]
;      ent_set_chromo_gen_ $son      $j  [ent_get_chromo_gen_ $mother $j]
;    }
; }

;  return
;}
;# //------------------------------------------------------------------------------
;# //  `Mates' two genotypes by single-point crossover of
;# //   each chromosome.
;# //------------------------------------------------------------------------------
;# void 
;# ga_crossover_char_singlepoints (CROSSOVER_VALS)
;# //------------------------------------------------------------------------------
;proc ga_crossover_char_singlepoints {pop father mother son daughter} \
;{

;  # наверное имеет смысл просто так
;  # 
;  ga_crossover_integer_singlepoints  $pop $father $mother $son $daughter


;  return
;}
;# //------------------------------------------------------------------------------
;# //  `Mates' two genotypes by double-point crossover of
;# //   each chromosome.
;# //------------------------------------------------------------------------------
;# void 
;# ga_crossover_char_doublepoints (CROSSOVER_VALS)
;# //------------------------------------------------------------------------------
;proc ga_crossover_char_doublepoints {pop father mother son daughter} \
;{

  
;  set len_chromo [$pop cget -len_chromosomes]

;  #     /* Choose crossover point and perform operation */
;  #     location1 = random_int (pop->len_chromosomes);

;  set location1 [random_int  $len_chromo]

;  #     do
;  #     {
;  #       location2 = random_int (pop->len_chromosomes);
;  #     } while (location2==location1);

;  while {1} {
;    set  location2 [random_int  $len_chromo]
;    if {$location2 != $location1} {break}
;  }
  
;  #     if (location1 > location2)
;  #     {
;  #       tmp = location1;
;  #       location1 = location2;
;  #       location2 = tmp;
;  #     }
  
;  if {$location1 > $location2} {

;    set tmp $location1
;    set location1 $location2
;    set location2 $tmp
;  }

;  #// теперь они в нужном порядке (по возрастающей)


;  set son_chromo [make_list $len_chromo 0]
;  set dau_chromo [make_list $len_chromo 0]

;  # (можно использовать другую функцию ?)
;  # 

;  set father_CH  [ent_CH_ $father]
;  set mother_CH  [ent_CH_ $mother]

;  memcpy  son_chromo 0  $father_CH 0  $location1
;  memcpy  dau_chromo 0  $mother_CH 0  $location1
  
;  memcpy  son_chromo $location1  $mother_CH $location1  [expr {$location2 - $location1}]
;  memcpy  dau_chromo $location1  $father_CH $location1  [expr {$location2 - $location1}]
  
;  memcpy  son_chromo $location2  $father_CH $location2  [expr {$len_chromo - $location2}]
;  memcpy  dau_chromo $location2  $mother_CH $location2  [expr {$len_chromo - $location2}]


;  # и запишем по адресу:
;  #
;  ent_set_chromosome_ $son      $son_chromo
;  ent_set_chromosome_ $daughter $dau_chromo

;  return
;}
;# //------------------------------------------------------------------------------


;# ------------------------------------------------------------------------------
;proc memcpy {&new n   old o  size} {

;# ------------------------------------------------------------------------------
;(defun memcpy (r_new n   old o  size)

;# ------------------------------------------------------------------------------
(defun memcpy (new n   old o  size) ; ????? new or r_new ?????

  ;;  USE_REFS

  ;;  for {set i 0} {$i < $size} {incr i} {
  (loop for i from 0 to (1- size) do

    ;;    lset new   [expr {$n + $i}]   [lindex $old [expr {$o + $i}]]

    (setf (elt new (+ n i)) (elt old (+ o i)))
  )

  ;;  return
)
;# //------------------------------------------------------------------------------
;# //  `Mates' two chromosomes by double-point crossover.

;# void 
;# ga_doublepoint_crossover_double_chromosome (population *pop,
;#                                             double *father, double *mother,
;#                                             double    *son, double *daughter)

;# //------------------------------------------------------------------------------
(defun ga_doublepoint_crossover_double_chromosome (pop  father_CH  mother_CH 
                                                         r_son_CH   r_dau_CH)

(let* (
  ;;  USE_REFS

  ;;  #   int	location1, location2;	/* Points of crossover. */
  ;;  #   int	tmp;			/* For swapping crossover loci. */
  
  ;;  #   if (!father || !mother || !son || !daughter)
  ;;  #     die ("Null pointer to chromosome structure passed.");
  
  (len_chromo (POP_LEN_CHROMOSOMES pop)) ; [$pop cget -len_chromosomes]

   ;;  # Choose crossover point and perform operation 

  (location1  (random_int  len_chromo))

  son_chromo dau_chromo location2 tmp
  )

  ;;  #   do
  ;;  #   {
  ;;  #     location2 = random_int(pop->len_chromosomes);
  ;;  #   } while (location2==location1);
  
  (loop while true do
    (setf  location2  (random_int  len_chromo))
    (when (/= location2 location1)    (return))
    )

  ;;  #// получили две несовпадающие точки (целочисленные)

  (when (> location1 location2)
    
    (setf tmp        location1)
    (setf location1  location2)
    (setf location2  tmp)
    )
  
  ;;  #puts stderr "location1 = $location1"
  ;;  #puts stderr "location2 = $location2"


  ;;  #// теперь они в нужном порядке (по возрастающей)

  ;;  if {0} {
  
  ;;    # пока для теста сделаем очень просто: 
  ;;    #
  ;;    set son_chromo $mother_CH
  ;;    set dau_chromo $father_CH
  
  ;;  } else {
  
  ;;    # получилось неправильно !
  ;;    #     lappend son_chromo [lrange $father_CH 0 $location1]
  ;;    #     lappend dau_chromo [lrange $mother_CH 0 $location1]
  
  ;;    #     lappend son_chromo [lrange $mother_CH $location1 $location2]
  ;;    #     lappend dau_chromo [lrange $father_CH $location1 $location2]
  
  ;;    #     lappend son_chromo [lrange $father_CH $location2 end]
  ;;    #     lappend dau_chromo [lrange $mother_CH $location2 end]
  

  (setf son_chromo (make-array  len_chromo :initial-element 0)) ;(make_list  len_chromo 0))
  (setf dau_chromo (make-array  len_chromo :initial-element 0)) ;(make_list  len_chromo 0))
    
  ;;    #puts "son_chromo = $son_chromo"
  ;;    #puts "dau_chromo = $dau_chromo"
  ;;    #puts ""
  ;;    #exit
  
  ;(memcpy  'son_chromo 0  father_CH 0  location1)
  ;
  ; правильно ли здесь передавать массив так, чтоб его изменять??
  ;??????????????????????????????

  (memcpy  son_chromo 0  father_CH 0  location1)
  (memcpy  son_chromo 0  father_CH 0  location1)
  (memcpy  dau_chromo 0  mother_CH 0  location1)

  (memcpy  son_chromo location1   mother_CH location1  (- location2 location1))
  (memcpy  dau_chromo location1   father_CH location1  (- location2 location1))

  (memcpy  son_chromo location2   father_CH location2  (- len_chromo location2))
  (memcpy  dau_chromo location2   mother_CH location2  (- len_chromo location2))

  ;;  }

  ;;  #if {$::is_print} {
  ;;  #  puts stderr ""
  ;;  #  puts stderr "son_chromo = $son_chromo"
  ;;  #  puts stderr "dau_chromo = $dau_chromo"
  ;;  #  puts stderr ""
  ;;  #}
  
  ;;  # и запишем по адресу:
  ;;  #

  (set r_son_CH  son_chromo)
  (set r_dau_CH  dau_chromo)
  
  ;;  return
))
;# //------------------------------------------------------------------------------
;# //  `Mates' two genotypes by double-point crossover of
;# //   each chromosome.

;# void 
;# ga_crossover_double_doublepoints (CROSSOVER_VALS)

;# #define CROSSOVER_VALS population *pop, entity *father, entity *mother, entity *son, entity *daughter 

;# //------------------------------------------------------------------------------
(defun ga_crossover_double_doublepoints (pop father mother son daughter)


  ;;#   if (!father || !mother || !son || !daughter)
  ;;#     die ("Null pointer to entity structure passed");
  
  ;;#   ga_doublepoint_crossover_double_chromosome (pop,
  ;;#                                               (double *) father->CH,
  ;;#                                               (double *) mother->CH,
  ;;#                                               (double *) son->CH,
  ;;#                                               (double *) daughter->CH);

  (declare (special son_CH  daughter_CH))


  (ga_doublepoint_crossover_double_chromosome  pop  
                                               (ent_CH_ father) (ent_CH_ mother)
                                               'son_CH  'daughter_CH)

  (ent_set_chromosome_  son       son_CH)
  (ent_set_chromosome_  daughter  daughter_CH)

  ;;  return
)
;# //------------------------------------------------------------------------------

;# //******************************************************************************
;# //------------------------------------------------------------------------------









;#------------------------------------------------------------------------------
;#   synopsis:	Seed genetic data for a single entity with an integer
;# 		chromosome by randomly setting each allele.
;#   parameters:	population *pop
;# 		entity *adam
;#   return:	success
;#------------------------------------------------------------------------------
;# boolean 
;# ga_seed_integer_random (population *pop, entity *adam)
;#------------------------------------------------------------------------------
;proc ga_seed_integer_random {pop adam}  {

;  #   //int		chromo;		/* Index of chromosome to seed */
;  #   int		point;		/* Index of allele to seed */
  
;  #   /* Checks. */
;  #   if (!pop) die("Null pointer to population structure passed.");
;  #   if (!adam) die("Null pointer to entity structure passed.");
  
;  #   /* Seeding. */
;  #   //chromo=0;
;  #   //for (chromo=0; chromo<pop->num_chromosomes; chromo++)
;  #   //{

;  set amin [$pop cget -allele_min_integer]
;  set amax [$pop cget -allele_max_integer]

;  #set amin $::allele_min_integer
;  #set amax $::allele_min_integer

;  for {set point 0} {$point < [$pop cget -len_chromosomes]} {incr point} \
;  {
;    # ((int *)adam->CH/* chromosome[chromo] */)[point] =
;    #   random_int_range(pop->allele_min_integer,pop->allele_max_integer);

;    set r [random_int_range  $amin $amax]

;    #$adam set_chromo_gen $point $r 
;    ent_set_chromo_gen_ $adam $point $r 
;  }

;  #   //}

;  return true
;}
;#-------------------------------------------------------------------------------
;#   synopsis:	Sets the minimum value for an integer allele for a
;# 		population.
;#-------------------------------------------------------------------------------
;# void 
;# ga_population_set_allele_min_integer (population *pop,
;# 				      int	  value)
;#-------------------------------------------------------------------------------
;proc ga_population_set_allele_min_integer {pop value}  {


;  $pop configure -allele_min_integer $value
;  #set ::allele_min_integer $value 

;  return
;}
;#-------------------------------------------------------------------------------
;#   synopsis:	Sets the maximum value for an integer allele for a
;# 		population.
;#-------------------------------------------------------------------------------
;proc ga_population_set_allele_max_integer {pop value}  {


;  $pop configure -allele_max_integer $value
;  #set ::allele_max_integer $value 

;  return
;}
;# /**********************************************************************
;#   ga_mutate.c

;#   ga_mutate - Genetic algorithm mutation operators.
;#   Copyright б╘2000-2006, Stewart Adcock <stewart@linux-domain.com>
;#   All rights reserved.

;#   Synopsis:     Routines for performing GA mutation operations.

;# 		These functions should duplicate user data where
;# 		appropriate.

;#-------------------------------------------------------------------------------
;#   synopsis:	Cause a single mutation event in which a single
;# 		allele is cycled.
;#-------------------------------------------------------------------------------
;proc ga_mutate_integer_singlepoint_drift {pop father son} {

;  if {$::is_print} {
;    puts "  ga_mutate_integer_singlepoint_drift : "
;    #puts ""
;  }

;  #   //int		i;		/* Loop variable over all chromosomes */
;  #   int		chromo;		/* Index of chromosome to mutate */
;  #   int		point;		/* Index of allele to mutate */
;  #   int		dir=random_boolean()?-1:1;	/* The direction of drift. */
  
;  if {[random_boolean]} {
;    set dir -1
;  } else {
;    set dir  1
;  }

;  #   /* Checks */
;  #   if (!father || !son) die("Null pointer to entity structure passed");
  
;  #   /* Select mutation locus. */
;  #   random_int (1/* pop->num_chromosomes */);
;  random_int 1

;  set len_chromo [$pop cget -len_chromosomes]

;  #   chromo =  0; 
;  set chromo    0
;  #   point  = (int) random_int (pop->len_chromosomes);
;  set point [random_int  $len_chromo]
  
;  #   /*
;  #     * Copy unchanged data.
;  #     */
;  #   //i = 0;
;  #   //for (i=0; i<pop->num_chromosomes; i++)
;  #   //{

;  #   memcpy (son->CH/* chromosome[i] */, father->CH/* chromosome[i] */, pop->len_chromosomes*sizeof(int));
;  #$son set_chromosome [$father get_chromosome]
;  #set_chromosome_ $son [$father get_chromosome]
;  ent_set_chromosome_ $son [ent_get_chromosome_ $father]

;  # /*   if (i!=chromo) */
;  # /*   { */
;  # /*     ga_copy_data(pop, son, father, i); */
;  # /*   } */
;  # /*   else */
;  # /*   { */
;  #   ga_copy_data (pop, son, NULL, 0/* i */); - надо ли это ???????????
;  # /*   } */
;  #   //}
  
;  set allele_max_integer [$pop cget -allele_max_integer]
;  set allele_min_integer [$pop cget -allele_min_integer]

;  #   /*
;  #     * Mutate by tweaking a single allele.
;  #     */
;  #   ((int *)son->chromosome[chromo])[point] += dir;
;  #
;  set point_gen [ent_get_chromo_gen_ $son  $point] ;# старое значение
;  set point_gen [expr {$point_gen + $dir}]  ;# новое  значение

;  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;  #   if (((int *)son->chromosome[chromo])[point] > pop->allele_max_integer)
;  #     ((int *)son->chromosome[chromo])[point] = pop->allele_min_integer;
  
;  if {$point_gen > $allele_max_integer} {
;    if {$::is_print} {
;      puts "  > allele_max_integer"
;    }
;    set point_gen $allele_min_intege ;# скорректировали
;  }

;  #   if (((int *)son->chromosome[chromo])[point] < pop->allele_min_integer)
;  #     ((int *)son->chromosome[chromo])[point] = pop->allele_max_integer;
  
;  if {$point_gen < $allele_min_integer} {
;    if {$::is_print} {
;      puts "  < allele_min_integer"
;    }
;    set point_gen  $allele_max_intege ;# скорректировали
;  }
;  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

;  #$son set_chromo_gen  $point $point_gen ;# записали новое значение
;  ent_set_chromo_gen_ $son  $point $point_gen ;# записали новое значение

;  return
;}
;#-------------------------------------------------------------------------------
;#-------------------------------------------------------------------------------
;#   synopsis:	Cause a single mutation event in which a single
;# 		allele is cycled.
;#-------------------------------------------------------------------------------
;# void 
;# ga_mutate_printable_singlepoint_drift (population *pop,
;#                                        entity *father, entity *son)
;#-------------------------------------------------------------------------------
;proc ga_mutate_printable_singlepoint_drift {pop father son}  {

;  #if {$::is_print} {
;  #  puts "  ga_mutate_printable_singlepoint_drift : "
;  #}

;  #   //int		i;		/* Loop variable over all chromosomes */
;  #   int		chromo;		/* Index of chromosome to mutate */
;  #   int		point;		/* Index of allele to mutate */

;  #   int		dir=random_boolean()?-1:1;	/* The direction of drift. */
  
;  if {[random_boolean]} {
;    set dir -1
;  } else {
;    set dir  1
;  }

;  #   /* Checks */
;  #   if (!father || !son) die ("Null pointer to entity structure passed");
  
;  #   /* Select mutation locus. */
;  #   /* chromo =  (int) */ random_int (1/* pop->num_chromosomes */);
;  random_int 1

;  set len_chromo [$pop cget -len_chromosomes]

;  #   chromo = 0; // (int) random_int (1/* pop->num_chromosomes */);
;  set chromo    0
;  #   point  = (int) random_int (pop->len_chromosomes);
;  set point [random_int  $len_chromo]
  
;  #   /*
;  #     * Copy unchanged data.
;  #     */
;  #   //i = 0;
;  #   //for (i=0; i<pop->num_chromosomes; i++)
;  #   //{

;  #   memcpy(son->CH, father->CH, pop->len_chromosomes*sizeof(char));

;  ent_set_chromosome_ $son [ent_get_chromosome_ $father]

;  # /*   if (i!=chromo) */
;  # /*   { */
;  # /*     ga_copy_data(pop, son, father, i); */
;  # /*   } */
;  # /*   else */
;  # /*   { */
;  #   ga_copy_data(pop, son, NULL, /* i */0);
;  # /*   } */
;  #   //}
  
;  #   /*
;  #     * Mutate by tweaking a single allele.
;  #     */

;  #   ((char *)son->chromosome[chromo])[point] += (char)dir;
;  set point_gen [ent_get_chromo_gen_ $son  $point] ;# старое значение
;  set point_gen [expr {$point_gen + $dir}]  ;# новое  значение


;  set char_min_num [scan " " "%c"]
;  set char_max_num [scan "~" "%c"] 
    
;  #   if (((char *)son->chromosome[chromo])[point] > '~')
;  #     ((char *)son->chromosome[chromo])[point] = ' ';

;  if {$point_gen > $char_max_num} {
;    set point_gen $char_min_num ;# скорректировали
;  }

;  #   if (((char *)son->chromosome[chromo])[point] < ' ')
;  #     ((char *)son->chromosome[chromo])[point] = '~';
  
;  if {$point_gen < $char_min_num} {
;    set point_gen $char_max_num ;# скорректировали
;  }


;  #$son set_chromo_gen  $point $point_gen ;# записали новое значение
;  ent_set_chromo_gen_ $son  $point $point_gen ;# записали новое значение

;  return
;}
;#-------------------------------------------------------------------------------
;#-------------------------------------------------------------------------------
;#   synopsis:	Cause a single mutation event in which a single
;# 		allele is adjusted.  (Unit Gaussian distribution.)

;# void 
;# ga_mutate_double_singlepoint_drift (population *pop,
;#                                     entity *father, entity *son)

;#-------------------------------------------------------------------------------
;proc ga_mutate_double_singlepoint_drift {pop father son}  {

;#-------------------------------------------------------------------------------
(defun ga_mutate_double_singlepoint_drift (pop father son)

  (when __is_print
    (pop_print  pop)
    (format t "  ga_mutate_double_singlepoint_drift : ~%")
    ;;    #puts ""
    )
  
  ;;  #   //int		i;		/* Loop variable over all chromosomes */
  ;;  #   //int		chromo;		/* Index of chromosome to mutate */
  ;;  #   int		point;		/* Index of allele to mutate */
  ;;  #   double	amount=random_unit_gaussian();	/* The amount of drift. (FIXME: variance should be user-definable) */

(let* (
  (amount  (random_unit_gaussian))
  
  ;;  #   /* Checks */
  ;;  #   if (!father || !son) die("Null pointer to entity structure passed");
  
  (len_chromo (POP_LEN_CHROMOSOMES pop))  ; [$pop cget -len_chromosomes]

  point allele_max_double allele_min_double point_gen allele_correct
  )
  ;; ---------------------------------------------------------------

  ;;  #   /* Select mutation locus. */
  ;;  #   /* chromo =  (int) */ random_int(1/* pop->num_chromosomes */);

  (random_int 1)

  ;;  #   //chromo = 0; // (int) random_int(1/* pop->num_chromosomes */);
  ;;  #   point  = (int) random_int(pop->len_chromosomes);

  (setf point (random_int   len_chromo))

  ;;  #   /*
  ;;  #     * Copy unchanged data.
  ;;  #     */
  ;;  #   //i=0;
  ;;  #   //for (i=0; i<pop->num_chromosomes; i++)
  ;;  #   //{
  
  ;;  #   memcpy(son->CH, father->CH, pop->len_chromosomes*sizeof(double));
  ;;  #$son set_chromosome [$father get_chromosome]
  ;;  #ent_set_chromosome_ $son [$father get_chromosome]

  ;(ent_set_chromosome_  son (ent_get_chromosome_ father))
  (ent_set_chromosome_  son (copy-seq (ent_get_chromosome_ father)))
 

  ;;  # /*   if (i!=chromo) */
  ;;  # /*   { */
  ;;  # /*     ga_copy_data(pop, son, father, i); */
  ;;  # /*   } */
  ;;  # /*   else */
  ;;  # /*   { */

  ;;  #   ga_copy_data(pop, son, NULL, /* i */0); - надо ли это ???????????

  ;;  # /*   } */
  ;;  #   //}
  
  (setf allele_max_double (POP_ALLELE_MAX_DOUBLE pop)) ; [$pop cget -allele_max_double]
  (setf allele_min_double (POP_ALLELE_MIN_DOUBLE pop)) ; [$pop cget -allele_min_double]

  ;;  #   /*
  ;;  #     * Mutate by tweaking a single allele.
  ;;  #     */
  ;;  #   ((double *)son->CH/* chromosome[chromo] */)[point] += amount;
  ;;  #

  (setf point_gen  (ent_get_chromo_gen_  son point)) ;# старое значение
  (setf point_gen  (+ point_gen amount))              ;# новое  значение

  
  ;;  # вообще не понятно это зачем, но надо сделать, чтобы совпадать с си-шным
  ;;  # вариантом;
  ;;  #
  ;;  # кстати, после кооректировки срабатывает та самая дурацкая процедура
  ;;  # ga_genocide_by_fitness  !!!!!!!!!!!!!
  ;;  #
  ;;  # ну и здесь лучше разобраться окончательно со значением, а уж потом
  ;;  # записывать;

  (setf allele_correct (- allele_max_double allele_min_double))


  ;;  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  ;;  #if (((double *)son->CH)[point] > allele_max_double)
  ;;  #  ((double *)son->CH)[point] -= (allele_max_double - allele_min_double);

  (when (> point_gen allele_max_double)

    (when __is_print
      (format t  "  > allele_max_double")
      )
    (setf point_gen (- point_gen allele_correct)) ;# скорректировали
    )

  ;;  #if (((double *)son->CH)[point] < allele_min_double)
  ;;  #  ((double *)son->CH)[point] += (allele_max_double - allele_min_double);
  
  (when (< point_gen allele_min_double)

    (when __is_print
      (format t "  < allele_min_double ~%")
      )
    (setf point_gen (+ point_gen allele_correct)) ;# скорректировали
    )

  ;;  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  
  (when __is_print
    ;(pop_print  pop)
    (format t "  ent_set_chromo_gen_: point= ~s  point_gen= ~s ~%"
            point point_gen)
    )

  (ent_set_chromo_gen_  son point point_gen) ;# записали новое значение

  (when __is_print
    (pop_print  pop)
    )

  ;;  return
))
;#-------------------------------------------------------------------------------

;# //******************************************************************************








;# ------------------------------------------------------------------------------
;#   ga_optim.c

;#   ga_optim - Optimisation and evolution routines.

;#   Synopsis:     Routines for optimisation and evolution.
;# 
;#                 Note that the temperatures in the simulated annealling
;#                 and MC functions do not exactly run from the initial
;#                 temperature to the final temperature.  They are offset
;#                 slightly so that sequential calls to these functions
;#                 will have a linear temperature change.  The SA and MC
;# 		code in this file is deprecated anyway - these routines
;# 		have been replaced with much more flexible alternatives
;# 		and will be removed in the near future.
;# 
;#   To do:	Finish rewriting parallel versions, ga_evolution_mp() in particular.
;# 		Write ga_evolution_pvm().
;# 		Remove much duplicated code.
;# 		OpenMOSIX fix.  See below.
;# 		gaul_adapt_and_evaluate_forked() and gaul_adapt_and_evaluate_threaded() 
;#                 are only parallelized for the case that no adaptation occurs.

;# //------------------------------------------------------------------------------
;# //  synopsis:	Swap the ranks of a pair of entities.
;# //  parameters: population *pop
;# //		const int rank1
;# //		const int rank2
;# //  return:	none
;# //------------------------------------------------------------------------------
;proc gaul_entity_swap_rank {pop rank1 rank2} \
;{
;  #   entity	*tmp;		/* Swapped entity. */
  
;  #   tmp = pop->entity_iarray[rank1];
;  #set tmp [$pop get_entity $rank1]
;  set tmp [pop_get_entity_ $pop  $rank1]

;  #   pop->entity_iarray[rank1] = pop->entity_iarray[rank2];
;  #$pop set_entity $rank1 [$pop get_entity $rank2]
;  pop_set_entity_ $pop  $rank1 [pop_get_entity_ $pop  $rank2]

;  #   pop->entity_iarray[rank2] = tmp;
;  pop_set_entity_ $pop  $rank2 $tmp
  
;  return
;}
;# //------------------------------------------------------------------------------
;# //  synopsis:	Migration cycle.
;# //  parameters:	population *pop
;# //  return:	none
;# //------------------------------------------------------------------------------
;# void 
;# gaul_migration (const int num_pops, population **pops)
;# //------------------------------------------------------------------------------
;proc gaul_migration {num_pops pops} \
;{

;  #   int  pop0_osize;	    /* Required for correct migration.  */
;  #   int  current_island;  /* Current current_island number.   */
;  #   int  i;		    /* Loop over members of population. */
  
;  #   plog (LOG_VERBOSE, "*** Migration Cycle ***");
  
;  if {$::is_print} {
;    puts "gaul_migration : "
;    puts ""
;  }

;  #   pop0_osize = pops[0]->size;
;  set pop0 [lindex $pops 0]
;  set pop0_osize [$pop0 cget -size]
  
;  for {set current_island 1} {$current_island < $num_pops} {incr current_island} {
  
;    set popcur   [lindex $pops $current_island]
;    set popcur_1 [lindex $pops [expr {$current_island - 1}]]

;    for {set i 0} {$i < [$popcur cget -size]} {incr i} {
    
;      if {[random_boolean_prob [$popcur cget -migration_ratio]]} {
        
;        #ga_entity_clone $popcur_1 [$popcur get_entity $i];
;        ga_entity_clone $popcur_1 [pop_get_entity_ $popcur  $i];
        
;        # /* printf ("%d, %d: Cloned %d %f\n", mpi_get_rank(), current_island, i, 
;        #   pops[current_island]->entity_iarray[i]->fitness);*/
;      }
;    }
;  }
  
;  set popbeg  [lindex $pops 0]
;  set popend  [lindex $pops [expr {$num_pops - 1}]]

;  for {set i 0} {$i < $pop0_osize} {incr i} {
  
;    if {[random_boolean_prob  [$popbeg cget -migration_ratio]]} {
;      #ga_entity_clone $popend [popbeg get_entity $i]
;      #ga_entity_clone $popend [$popbeg get_entity $i] ;# !!! одинаково
;      ga_entity_clone $popend [pop_get_entity_ $popbeg  $i]
;    }
    
;    #     /*  printf("%d, 0: Cloned %d %f\n", mpi_get_rank(), i, 
;    #       pops[current_island]->entity_iarray[i]->fitness);*/
;  }
  
;  #   /*
;  #     * Sort the individuals in each population.
;  #     * Need this to ensure that new immigrants are ranked correctly.
;  #     * FIXME: It would be more efficient to insert the immigrants correctly.
;  #     */
  
;  for {set current_island 0} {$current_island < $num_pops} {incr current_island} \
;  {
;    sort_population [lindex $pops $current_island];
;  }

;  return
;}
;# //------------------------------------------------------------------------------
;# //  synopsis:	Mating cycle. (i.e. Sexual reproduction).
;# //  parameters:	population *pop
;# //  return:	none
;# //------------------------------------------------------------------------------
(defun gaul_crossover (pop)

  ;;  #   entity	*mother, *father;  /* Parent entities. */
  ;;  #   entity	*son, *dau;        /* Child entities.  */
  
  ;;  #   plog (LOG_VERBOSE, "*** Mating cycle ***");

(let* (
  (select_two_proc (POP_SELECT_TWO pop)) ; cget -select_two]
  son dau 
  mother father ; NIL ??
  )

(declare (special mother father))


  (when __is_print
    (format t "gaul_crossover : (select_two_proc = ~s) ~%" select_two_proc)
    ;#puts "gaul_crossover : "
    (format t "~%")
    )
  
  (when (<= (POP_CROSSOVER_RATIO pop) 0.0) 
    (format t "!!!!!!!!!!!!!!!!!!!! ~%")
    (return-from gaul_crossover) 
    )
  
  ;;  # здесь обнуляем, т.е. начинаем процедуру выбора (селекции) сначала
  ;;  # 
  (setf (POP_SELECT_STATE pop) 0) ;  $pop configure -select_state 0
  
  ;;  #   /* Select pairs of entities to mate via crossover. */
  ;;  #   /* #pragma intel omp parallel taskq */
  
  ;;  while {! [$select_two_proc $pop  mother father]} {
  (loop while (not (funcall select_two_proc pop  'mother 'father)) :do
  
    ;;    #if {$mother == "NULL"} {

    ;;    #       plog (LOG_VERBOSE, 
    ;;    #             "Crossover between %d (rank %d fitness %f) and %d (rank %d fitness %f)",
    ;;    #             ga_get_entity_id(pop, mother),
    ;;    #             ga_get_entity_rank(pop, mother), mother->fitness,
    ;;    #             ga_get_entity_id(pop, father),
    ;;    #             ga_get_entity_rank(pop, father), father->fitness);
    
    (setf son (ga_get_free_entity  pop))
    (setf dau (ga_get_free_entity  pop))

    (when __is_print
      (print_entit  dau    "dau =")
      (print_entit  son    "son =")      
      (pop_print pop)

     )

    ;;    # pop->crossover (pop, mother, father, dau, son); ??? почему перепутано ??
    ;;    [$pop cget -crossover] $pop  $mother $father $dau $son
    (funcall (POP_CROSSOVER pop) pop   mother father  dau son)
    
    ;;    # перепутанный порядок даже с сишным вариантом!
    ;;    # однако

    (when __is_print
      (print_entit  mother "mom =")
      (print_entit  father "dad =")
      (print_entit  dau    "dau =")
      (print_entit  son    "son =")      

      
;      (format t "~%")
;      (pop_print pop)
      )

    ;;    #} else {
    ;;    #  plog LOG_VERBOSE "Crossover not performed."
    ;;    #}

    (when __is_print
      (format t "~%")
      )

    ); while loop
  
  ;;  return
))
;# //------------------------------------------------------------------------------
;# //  synopsis:	Mutation cycle.  (i.e. Asexual reproduction)
;# //  parameters:	population *pop
;# //  return:	none
;# //------------------------------------------------------------------------------
(defun gaul_mutation (pop)

(let (
  ;;  #   entity    *mother;	    /* Parent entities. */
  ;;  #   entity    *daughter;	    /* Child entities.  */

  dau mother
  )
  (declare (special mother))
  
  ;;  #   plog (LOG_VERBOSE, "*** Mutation cycle ***");
  
  (when __is_print
    (format t "gaul_mutation : ~%")
    (format t "~%")
    )
  
  ;;  #   if (pop->mutation_ratio <= 0.0) return;

  (when (<= (POP_MUTATION_RATIO pop) 0.0)  (return-from  gaul_mutation))
  
  ;;  #   pop->select_state = 0;
  (setf (POP_SELECT_STATE pop) 0) ;  $pop configure -select_state 0
  
  ;;  #   /*
  ;;  #     * Select entities to undergo asexual reproduction, in each case the child will
  ;;  #     * have a genetic mutation of some type.
  ;;  #     */
  
  ;;  #   while ( !(pop->select_one(pop, &mother)) )

  ;;  while { ! [[$pop cget -select_one] $pop mother] } {
  (loop while (not (funcall (POP_SELECT_ONE pop)  pop 'mother)) do


    ;;    # в Си-шном варианте тут есть проблема, когда mother == NULL !!!!!
    ;;    # а здесь нет такого ??
    ;;    # 
    ;;    #if {$::is_print} {
    ;;    #  print_entit  $mother "mam ="
    ;;    #}
    
    ;;    #     if (mother)
    ;;    #     {
    ;;    #       //{
    ;;    #         plog(LOG_VERBOSE, "Mutation of %d (rank %d fitness %f)",
    ;;    #              ga_get_entity_id(pop, mother),
    ;;    #              ga_get_entity_rank(pop, mother), mother->fitness );
    
    ;;    #         daughter = ga_get_free_entity(pop);

    (setf dau  (ga_get_free_entity  pop))

    ;;    #         pop->mutate(pop, mother, daughter);

    ;;    [$pop cget -mutate] $pop  $mother $dau
    (funcall (POP_MUTATE pop)  pop  mother dau)
    
    ;;    #         if (is_print) print_entit (daughter, "dau =", pop->len_chromosomes);

    (when __is_print
      (print_entit   dau "dau =")
      (format t "~%")
      )

    ;;    #       //}
    ;;    #     } else {
    
    ;;    #       plog( LOG_VERBOSE, "Mutation not performed." );
    ;;    #     }
    )
  
  ;;  return
))
;# //------------------------------------------------------------------------------
;# //  synopsis:	Fitness evaluations.
;# //		Evaluate all previously unevaluated entities.
;# //		No adaptation.
;# //  parameters:	population *pop
;# //  return:	none
;# //------------------------------------------------------------------------------
(defun gaul_ensure_evaluations (pop)

(let (
  ;;  #   int  i;	/* Loop variable over entity ranks. */
  ret entity
  )  


  ;;  for {set i 0} {$i < [$pop cget -size]} {incr i} {
  (loop for i from 0 to (1- (POP_SIZE pop)) do

    ;;    #     if (pop->entity_iarray[i]->fitness == GA_MIN_FITNESS)
    ;;    #     {
    ;;    #       if ( pop->evaluate(pop, pop->entity_iarray[i]) == FALSE )
    ;;    #         pop->entity_iarray[i]->fitness = GA_MIN_FITNESS;
    ;;    #     }
    
    ;;    #set entity [$pop get_entity $i]  
    (setf entity (pop_get_entity_  pop i))

    (when (= (ENT_FITNESS entity) __GA_MIN_FITNESS)

        (setf ret (funcall (POP_EVALUATE pop)  pop entity))
        (when (equal ret false)

          ;;        #  pop->entity_iarray[i]->fitness = GA_MIN_FITNESS;
          (format t "ERROR ............. !!!!!!!!!!!!!!!!!!!!!! ~%")
          (exit) ;# пока сделаем просто ошибку..
          )
      )

    ) ; loop for i 

  ;;  return
))
;# //------------------------------------------------------------------------------
(defun score_and_sort_initial_pop (pop)

(let (
  (size          (POP_SIZE        pop)) ; [$pop cget -size]
  (stable_size   (POP_STABLE_SIZE pop)) ; [$pop cget -stable_size]
  )

  (when  (< size stable_size)
    ;#gaul_population_fill (pop, pop->stable_size - pop->size);
    (gaul_population_fill  pop (- stable_size size))
    )
  
  (gaul_ensure_evaluations  pop)
  (sort_population          pop)
  
  (ga_genocide_by_fitness   pop __GA_MIN_FITNESS)

  ;;  return
))
;# //------------------------------------------------------------------------------
;# 
;# лонгическая схема сделана так будто в перечисляемом типе "scheme" хранится
;# несколько одновременно флажков, но нигде не нашел где это формируется, т.е.
;# где эти битовые маски складываются ! наверное это лишнее !?
;# 
;# //------------------------------------------------------------------------------
;# int 
;# is_in_scheme (ga_scheme_type scheme, ga_scheme_type name)
;# //------------------------------------------------------------------------------
(defun is_in_scheme (scheme name)

  ;;  #puts "is_in_scheme : scheme = $scheme"
  ;;  #puts ""
  
  ;;  #   //int ret = ((scheme & GA_SCHEME_BALDWIN_PARENTS) != 0);
  ;;  #   int ret = ((scheme & name) != 0);
  
  ;;  # пока предпологаем, что там не список:
  ;;  # 

(let (
  (ret (equal scheme name))
  )
       
  ret
))
;# //------------------------------------------------------------------------------
;# int 
;# is_in_scheme_only (ga_scheme_type scheme, ga_scheme_type name)
;# //------------------------------------------------------------------------------
(defun is_in_scheme_only (scheme name)


  ;;  #puts "is_in_scheme_only : scheme = $scheme"
  ;;  #puts ""
  
  ;;  # // (scheme == GA_SCHEME_DARWIN)
  ;;  # int ret = (scheme == name);
  
  ;;  # пока предпологаем, что там не список:
  ;;  # 

(let (
  (ret (equal scheme name))
  )
       
  ret
))
;# //------------------------------------------------------------------------------
;# void adapt_1 (population *pop, int ibeg, int iend)
;# //------------------------------------------------------------------------------
;proc adapt_1 {pop ibeg iend} \
;{

;  if {$::is_print} {
;    puts "adapt_1 ... BEGIN : "
;    puts ""
;    #$pop print
;    #puts ""
;  }

;  #   int	    i;			/* Loop variable over entity ranks. */
;  #   entity    *adult = NULL;	/* Adapted entity.                  */
  
;  # адаптируем новые элементы
;  # 

;  for {set i $ibeg} {$i < $iend} {incr i} \
;  {
;    #     adult = pop->adapt (pop, pop->entity_iarray[i]);
;    #set adult [[$pop cget -adapt] $pop [$pop get_entity $i]]
;    set adult [[$pop cget -adapt] $pop [pop_get_entity_ $pop  $i]]

;    # выполнили адаптацию, т.е. "взрастили" особь (?)
;    # и теперь ее фитнесс запишем младенцу (?)

;    #     pop->entity_iarray[i]->fitness = adult->fitness;
;    set fi [$adult cget -fitness]

;    if {$::is_print} {
;      puts [format "i = %2d  fi = $fi" $i]
;    }

;    #pop->entity_iarray[i]->fitness = fi;
;    #$pop set_entity_fitness  $i $fi ;# не оказывает эффекта ??? просто ошибка
;    pop_set_entity_fitness_ $pop   $i $fi ;# не оказывает эффекта ??? просто ошибка

;    ga_entity_dereference  $pop $adult
;  }

;  if {$::is_print} {
;    #puts ""
;    #$pop print
;    puts ""
;    puts "adapt_1 ... FINAL ."
;  }

;  return
;}
;# //------------------------------------------------------------------------------
;proc adapt_2 {pop ibeg iend} \
;{

;  #   int	    i;			/* Loop variable over entity ranks. */
;  #   entity    *adult = NULL;	/* Adapted entity.                  */
;  #   int	    adultrank;		/* Rank of adapted entity.          */
  
;  for {set i $ibeg} {$i < $iend} {incr i} \
;  {
;    # adult     = pop->adapt (pop, pop->entity_iarray[i]);
;    # set adult [[$pop cget -adapt] $pop [$pop get_entity $i]]
;    set adult [[$pop cget -adapt] $pop [pop_get_entity_ $pop  $i]]
    
;    set adultrank [ga_get_entity_rank  $pop $adult]
    
;    gaul_entity_swap_rank  $pop $i $adultrank
    
;    ga_entity_dereference_by_rank  $pop $adultrank
;  }

;  return
;}
;# //------------------------------------------------------------------------------
;# //  synopsis:	Fitness evaluations.
;# //		Evaluate the new entities produced in the current
;# //		generation, whilst performing any necessary adaptation.
;# //		Simple sequential version.
;# //  parameters:	population *pop
;# //  return:	none
;# //------------------------------------------------------------------------------
(defun gaul_adapt_and_evaluate (pop)

  ;;  #   int  i;  /* Loop variable over entity ranks. */
  
  ;;  #   /* typedef enum ga_scheme_type_t     */
  ;;  #   /*   { */
  ;;  #   /*   GA_SCHEME_DARWIN           = 0, */
  ;;  #   /*   GA_SCHEME_LAMARCK_PARENTS  = 1, */
  ;;  #   /*   GA_SCHEME_LAMARCK_CHILDREN = 2, */
  ;;  #   /*   GA_SCHEME_LAMARCK_ALL      = 3, */
  ;;  #   /*   GA_SCHEME_BALDWIN_PARENTS  = 4, */
  ;;  #   /*   GA_SCHEME_BALDWIN_CHILDREN = 8, */
  ;;  #   /*   GA_SCHEME_BALDWIN_ALL      = 12 */
  ;;  #   /*   } ga_scheme_type; */
  
  ;;  #   ga_scheme_type scheme = pop->scheme;	/* Evolutionary scheme.    */

(let (

  (scheme  (POP_SCHEME pop)) ; [$pop cget -scheme]
  entity ret
  )
  
  (if (is_in_scheme_only  scheme "GA_SCHEME_DARWIN")
  (progn  

    ;;    #  // This is pure Darwinian evolution. Simply assess fitness of all children.
    
    ;;    #  plog (LOG_VERBOSE, "*** Fitness Evaluations ***");
    
    ;;    #  for (i = pop->orig_size; i < pop->size; i++)
    ;;    #  {
    ;;    #    if ( pop->evaluate (pop, pop->entity_iarray[i]) == FALSE )
    ;;    #      pop->entity_iarray[i]->fitness = GA_MIN_FITNESS;
    ;;    #  }
    
    ;;    for {set i [$pop cget -orig_size]} {$i < [$pop cget -size]} {incr i} \
    (loop for i :from (POP_ORIG_SIZE pop) :below (POP_SIZE pop) :do

      ;;      #set entity [$pop get_entity $i]
      (setf entity (pop_get_entity_ pop  i))

      (setf ret (funcall (POP_EVALUATE pop) pop entity))  ; [[$pop cget -evaluate] $pop $entity]

      (when (eql ret false)
        ;;        #pop->entity_iarray[i]->fitness = GA_MIN_FITNESS;

        (format t "ERROR ............. !!!!!!!!!!!!!!!!!!!!!!")
        (exit)  ;# пока сделаем просто ошибку..
        )
      )

  )
  ;;  } else {
  (progn 
  
    ;;    #  // Some kind of adaptation is required.  First reevaluate parents, as needed, 
    ;;    #  // then children. 
    
    ;;    #  plog (LOG_VERBOSE, "*** Adaptation and Fitness Evaluations ***");
    
    (cond 
     ((is_in_scheme  scheme "GA_SCHEME_BALDWIN_PARENTS")
    
      (adapt_1  pop 0 (POP_ORIG_SIZE pop))
      )
    
     ((is_in_scheme  scheme "GA_SCHEME_LAMARCK_PARENTS")
 
      (adapt_2   pop 0 (POP_ORIG_SIZE pop))
      )
     )
    
    
    (cond 
     ((is_in_scheme  scheme "GA_SCHEME_BALDWIN_CHILDREN")
    
      (adapt_1  pop (POP_ORIG_SIZE pop) (POP_SIZE pop))
      )
    
     ((is_in_scheme  scheme "GA_SCHEME_LAMARCK_CHILDREN")
 
      (adapt_2   pop (POP_ORIG_SIZE pop) (POP_SIZE pop))
      )
     )
    
    
;    if        {[is_in_scheme $scheme "GA_SCHEME_BALDWIN_CHILDREN"]} {
   
;      adapt_1  $pop [$pop cget -orig_size] [$pop cget -size]
    
;    } elseif {[is_in_scheme $scheme "GA_SCHEME_LAMARCK_CHILDREN"]} {
    
;      adapt_2  $pop [$pop cget -orig_size] [$pop cget -size]
;    }

  ))
  
  ;;  return
))
;# //------------------------------------------------------------------------------
;# //------------------------------------------------------------------------------
(defun sort_and_genocide_by_fitness (pop)

  ;;  #   // Sort all population members by fitness.
  ;;  #   //

  (sort_population  pop)
  
  ;;  #   // Ensure that any very bad solutions are not retained.
  ;;  #   //

  (ga_genocide_by_fitness  pop __GA_MIN_FITNESS) ;# - это имеет ли смысл?

  ;;  return
)
;# //------------------------------------------------------------------------------
(defun sort_and_genocide (pop)

  (sort_and_genocide_by_fitness   pop)


  ;;  #   // Least fit population members die to restore the
  ;;  #   // population size to its stable size.
  ;;  #   //

  (ga_genocide  pop  (POP_STABLE_SIZE pop)) ; ;[$pop cget -stable_size]

  ;;  return
)
;# //------------------------------------------------------------------------------
;# void ga_elitism_parents_die_exept (population *pop, int num_parents_survives)
;# //------------------------------------------------------------------------------
;proc ga_elitism_parents_die_exept {pop num_parents_survives} \
;{

;  #   //int num_parents_survives = 1 (elitism == GA_ELITISM_ONE_PARENT_SURVIVES);
;  #   //
;  #   // эта хитрая конструкция означает сколько родителей оставить : 0 или 1
  
;  while {[$pop cget -orig_size] > $num_parents_survives} \
;  {
;    #     pop->orig_size--;
;    $pop configure -orig_size  [expr {[$pop cget -orig_size] - 1}]

;    #ga_entity_dereference_by_rank (pop, pop->orig_size);
;    ga_entity_dereference_by_rank $pop [$pop cget -orig_size]
;  }
  
;  sort_and_genocide $pop

;  return
;}
;# //------------------------------------------------------------------------------
;# //  synopsis:	Survival of the fittest.
;# //		Enforce elitism, reduce
;# //		population back to its stable size and rerank entities,
;# //		as required.
;# //  parameters:	population *pop
;# //  return:	none
;# //------------------------------------------------------------------------------
(defun gaul_survival (pop)

  ;;  #   plog (LOG_VERBOSE, "*** Survival of the fittest ***");
  
  ;;  #   /* typedef enum ga_elitism_type_t */
  ;;  #   /*   { */
  ;;  #   /*   GA_ELITISM_UNKNOWN             = 0, */
  ;;  #   /*   GA_ELITISM_NULL                = 0, */
  ;;  #   /*   GA_ELITISM_PARENTS_SURVIVE     = 1, */
  ;;  #   /*   GA_ELITISM_ONE_PARENT_SURVIVES = 2, */
  ;;  #   /*   GA_ELITISM_PARENTS_DIE         = 3, */
  ;;  #   /*   GA_ELITISM_RESCORE_PARENTS     = 4, */
  ;;  #   /*   GA_ELITISM_BEST_SET_SURVIVE    = 5, */
  ;;  #   /*   GA_ELITISM_PARETO_SET_SURVIVE  = 6 */
  ;;  #   /*   } ga_elitism_type; */
  
  ;;  #   ga_elitism_type  elitism = pop->elitism;   /* Elitism mode. */

(let (
  (elitism (POP_ELITISM pop)) ; [$pop cget -elitism]
  )

  (when  __is_print
    (format t "~%")
    (format t "gaul_survival: elitism = ~s ~%" elitism)
    (format t "~%")
    )
  
  (cond 

   ((equal elitism "GA_ELITISM_PARENTS_SURVIVE")     (sort_and_genocide              pop))
  
   ((equal elitism "GA_ELITISM_PARENTS_DIE")         (ga_elitism_parents_die_exept   pop 0))
    
   ((equal elitism "GA_ELITISM_ONE_PARENT_SURVIVES") (ga_elitism_parents_die_exept   pop 1))
    
   ((equal elitism "GA_ELITISM_RESCORE_PARENTS")     (ga_elitism_rescore_parents     pop))
    
   ((equal elitism "GA_ELITISM_BEST_SET_SURVIVE")    (ga_elitism_best_set_survive    pop))
    
   ((equal elitism "GA_ELITISM_PARETO_SET_SURVIVE")  (ga_elitism_pareto_set_survive  pop))

   (T (ERROR "gaul_survival"))
    
   )  

))
;# //------------------------------------------------------------------------------
(defun crossover_mutation_adapt_survival (pop)

  (when __is_print
    (pop_print pop)
  )
  
  ;;  #     // Crossover step.
  ;;  #     //
  (gaul_crossover pop)
  
  (when __is_print
    (pop_print pop)
  )
  
  ;;  #     // Mutation step.
  ;;  #     //
  (gaul_mutation  pop)
  
  ;;  #if {$::is_print} {
  ;;  #  puts ""
  ;;  #  pop_print $pop
  ;;  #}
  
  ;;  #     // Apply environmental adaptations, score entities, sort entities, etc.
  ;;  #     //
  (gaul_adapt_and_evaluate  pop)
  
  ;;  #     // Survival of the fittest.
  ;;  #     //
  (gaul_survival  pop)
    
  ;;  return
)
;# //------------------------------------------------------------------------------
;# //  synopsis:	Main genetic algorithm routine.  Performs GA-based
;# //		optimisation on the given population.
;# //		This is a generation-based GA.
;# //		ga_genesis(), or equivalent, must be called prior to
;# //		this function.
;# //  parameters:
;# //  return:
;# //------------------------------------------------------------------------------
(defun ga_evolution (pop max_generations)

(let (
  ;;  #   int  generation = 0;  /* Current generation number. */
  (generation 0)
  g_hook
  )

  ;;  #   /* Checks. */
  
  ;;  #   if (!pop)             die ("NULL pointer to population structure passed.");
  ;;  #   if (!pop->evaluate)   die ("Population's evaluation callback is undefined.");
  ;;  #   if (!pop->select_one) die ("Population's asexual selection callback is undefined.");
  ;;  #   if (!pop->select_two) die ("Population's sexual selection callback is undefined.");
  ;;  #   if (!pop->mutate)     die ("Population's mutation callback is undefined.");
  ;;  #   if (!pop->crossover)  die ("Population's crossover callback is undefined.");
  ;;  #   if (!pop->rank)       die ("Population's ranking callback is undefined.");
  
  ;;  #   if (pop->scheme != GA_SCHEME_DARWIN && !pop->adapt) 
  ;;  #     die ("Population's adaption callback is undefined.");
  
  ;;  #   plog (LOG_VERBOSE, "The evolution has begun!");
  
  ;;  #   pop->generation = 0;
  
  ;(format t "05 ...................................... ~%")

  (setf (POP_GENERATION pop) 0) ; $pop configure -generation 0
  
  ;;  #   //
  ;;  #   // Score and sort the initial population members.
  ;;  #   //

  (score_and_sort_initial_pop  pop)
  
  ;(format t "06 ...................................... ~%")

  ;;  #   plog (LOG_VERBOSE,
  ;;  #         "Prior to the first generation, population has fitness scores between %f and %f",
  ;;  #         pop->entity_iarray[0]->fitness,
  ;;  #         pop->entity_iarray[pop->size-1]->fitness);
  
  ;;  #   printf ("\n");  
  
  ;;  #   // Do all the generations:
  ;;  #   //
  ;;  #   // Stop when (a) max_generations reached, or
  ;;  #   //           (b) "pop->generation_hook" returns FALSE.
  
  ;;  #   // while ( (pop->generation_hook?pop->generation_hook(generation, pop):TRUE) && 
  ;;  #   //          generation < max_generations ) 
  
  ;;  #puts "ga_evolution : max_generations = $max_generations"
  ;;  #exit

  ;;  while {1} {
  (loop while true do
  
    (if __is_print 
      (progn
        (format t "~%")
        (format t "GENERATION LOOP ......... generation = ~s ~%" generation)
        (format t "~%")       
        )
      ;;    } else {
      (progn

        ;;      set  g_hook [$pop cget -generation_hook]
        ;;      if {$g_hook != "NULL"} {
        ;;        [$pop cget -generation_hook]  $generation $pop ; #// печать через 10
        
        (setf g_hook (POP_GENERATION_HOOK pop))
        
        (when g_hook
          ;;(funcall (POP_GENERATION_HOOK pop) generation pop)
          (funcall g_hook generation pop)
          )
      ))
  
  ;(format t "07 ...................................... ~%")

    (when (>= generation max_generations) (return))
    ;;    if {$generation >= $max_generations} {break}
  

    ;;    #     // сделали простой while .................    
    ;;    #     generation++;
    ;;    #     pop->generation = generation;

    (incf generation)
    ;(setf (POP_GENERATION pop) 0) ; $pop configure -generation $generation
    (setf (POP_GENERATION pop) generation) ; $pop configure -generation $generation
    
    ;;    #     pop->orig_size = pop->size;
    ;;    $pop configure -orig_size  [$pop cget -size] 
    (setf (POP_ORIG_SIZE pop) (POP_SIZE pop))
    
    ;;    #     plog (LOG_DEBUG,
    ;;    #               "Population size is %d at start of generation %d",
    ;;    #               pop->orig_size, generation );
    
    (crossover_mutation_adapt_survival  pop)
        
    ;;    #     // End of generation.
    ;;    #     //
    ;;    #     plog (LOG_VERBOSE,
    ;;    #           "After generation %d, population has fitness scores between %f and %f",
    ;;    #           generation,
    ;;    #           pop->entity_iarray[0]->fitness,
    ;;    #           pop->entity_iarray[pop->size-1]->fitness);
    
    ) ;# /* Generation loop. */
  
  
   (when __is_print
      (format t "~%")
      (format t "FINAL RESULT: ~%")
      (format t "~%")
      ;;    #$pop print
      (pop_print_  pop)
      (format t "~%")
      )
  
  ;;  #exit
  ;;  return $generation

  generation

))
;# //------------------------------------------------------------------------------
;# //  synopsis:	Main genetic algorithm routine.  Performs GA-based
;# //		optimisation on the given populations using a simple
;# //		island model.  Migration occurs around a cyclic
;# //		topology only.  Migration causes a duplication of the
;# //		respective entities.  This is a generation-based GA.
;# //		ga_genesis(), or equivalent, must be called prior to
;# //		this function.
;# //  parameters:	const int	num_pops
;# //		population	**pops
;# //		const int	max_generations
;# //
;# //  return:	number of generation performed
;# //------------------------------------------------------------------------------
;proc generation_hook_check {pop generation} \
;{

;  #  if (pop->generation_hook?pop->generation_hook (generation, pop):TRUE)

;  set  g_hook [$pop cget -generation_hook]

;  if {$g_hook == "NULL"} {return true}

;  #puts "9999999999999999.................."

;  set ret [$g_hook  $generation $pop] 

;  return $ret
;}
;# //------------------------------------------------------------------------------
;# int 
;# ga_evolution_archipelago (int  num_pops, population **pops,
;#                           int  max_generations)
;# //------------------------------------------------------------------------------
;proc ga_evolution_archipelago {num_pops pops max_generations} \
;{

;  #   int		generation = 0;   /* Current generation number.       */
;  set generation 0

;  #   int		current_island;	  /* Current current_island number.   */
;  #   population	*pop = NULL;	  /* Current population.              */

;  #   boolean	complete = FALSE;	  /* Whether evolution is terminated. */
;  set complete FALSE
  
;  #   /* Checks. */
  
;  #   if (! pops)
;  #     die ("NULL pointer to array of population structures passed.");
;  #   if (num_pops < 2)
;  #     die ("Need at least two populations for the island model.");
  
;  for {set current_island 0} {$current_island < $num_pops} {incr current_island} \
;  {
;    #     pop = pops[current_island];
;    set pop [lindex $pops $current_island]
    
;    #     if (!pop->evaluate)   die ("Population's evaluation callback is undefined.");
;    #     if (!pop->select_one) die ("Population's asexual selection callback is undefined.");
;    #     if (!pop->select_two) die ("Population's sexual selection callback is undefined.");
;    #     if (!pop->mutate)     die ("Population's mutation callback is undefined.");
;    #     if (!pop->crossover)  die ("Population's crossover callback is undefined.");
;    #     if (!pop->rank)       die ("Population's ranking callback is undefined.");
    
;    #     if (pop->scheme != GA_SCHEME_DARWIN && !pop->adapt) {
;    #       die ("Population's adaption callback is undefined.");
;    #     }
    
;    #     /* Set current_island property. */
;    #     pop->island = current_island;
;    $pop configure -island $current_island
;  }
  
;  #   plog (LOG_VERBOSE, "The evolution has begun on %d islands!", num_pops);
  
;  #// ?? к какой именно популяции ??
;  #   pop->generation = 0;
  
;  for {set current_island 0} {$current_island < $num_pops} {incr current_island} \
;  {
;    #     pop = pops[current_island];
;    set pop [lindex $pops $current_island]
    
;    #     //
;    #     // Score and sort the initial population members.
;    #     //
;    score_and_sort_initial_pop $pop
    
;    #     plog (LOG_VERBOSE, "Prior to the first generation, population on \
;    #                        current_island %d has fitness scores between %f and %f",
;    #           current_island,
;    #           pop->entity_iarray[0]->fitness,
;    #           pop->entity_iarray[pop->size-1]->fitness );
;  }
  
;  #   /* Do all the generations: ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */
  
;  while {1} {

;    if {$generation >= $max_generations} {break}
;    if {$complete   != FALSE}            {break}

;    incr generation

;    if {$::is_print} {
;      puts ""
;      puts "GENERATION LOOP ......... generation = $generation"
;      puts ""
;    } 

;    #  pop->generation = generation;   $pop configure -generation $generation
    
;    # // Migration step.
;    # //
;    gaul_migration  $num_pops $pops
    
    
;    for {set current_island 0} {$current_island < $num_pops} {incr current_island} \
;    {
;      if {$::is_print} {
;        puts ""
;        puts "CURRENT ISLAND = $current_island"
;        puts ""
;      } 

;      #   pop = pops[current_island];
;      set pop [lindex $pops $current_island]
      
;      #  plog (LOG_VERBOSE, "*** Evolution on current_island %d ***", current_island);
      
;      if {[generation_hook_check $pop $generation]} {
      
;        $pop configure -orig_size [$pop cget -size]
        
;        #         plog (LOG_DEBUG,
;        #               "Population %d size is %d at start of generation %d",
;        #               current_island, pop->orig_size, generation );
        
;        # //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
;        crossover_mutation_adapt_survival  $pop
        
;        # //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
        
;      } else {
        
;        set complete TRUE
;      }
;    }
    
;    #     plog (LOG_VERBOSE,
;    #           "After generation %d, population %d has fitness scores between %f and %f",
;    #           generation,
;    #           current_island,
;    #           pop->entity_iarray[0]->fitness,
;    #           pop->entity_iarray[pop->size-1]->fitness );
  
;  } 
  
;  return $generation
;}
;# //******************************************************************************
;# //------------------------------------------------------------------------------








