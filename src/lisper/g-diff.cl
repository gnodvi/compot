; -*-   mode: lisp ; coding: koi8   -*- ----------------------------------------

;-------------------------------------------------------------------------------
;#   ga_de.c

;#   ga_de - Differential Evolution.

;#   Synopsis:     Differential Evolution.

;# 		The DE algorithm was originally conceived by Rainer
;# 		Storn and Ken Price.  The GAUL implementation is
;# 		based in part on their "de36.c" reference source code.
;# 		See http://www.icsi.berkeley.edu/~storn/code.html

;# 		You may notice that this code includes equivalents of
;# 		all of the original DE strategies along with a
;# 		selection of additional strateties.


;#-------------------------------------------------------------------------------
;# 
;# Differential evolution parameter structure.
;# 

;record define GA_DE_T {
(defclass  GA_DE_T () (

  (de_strategy         :accessor DE_STRATEGY)         ;#-# Selection strategy;                
  (de_crossover_method :accessor DE_CROSSOVER_METHOD) ;#-# Crossover strategy;                
  (de_num_perturbed    :accessor DE_NUM_PERTURBED)     ;#-# Number to perturb;                 
  (de_crossover_factor :accessor DE_CROSSOVER_FACTOR) ;#-# Crossover ratio;                   
  (de_weighting_min    :accessor DE_WEIGHT_MIN)       ;#-# Minimum crossover weighting factor;
  (de_weighting_max    :accessor DE_WEIGHT_MAX)       ;#-# Maximum crossover weighting factor;

;}
))

;#  **********************************************************************/

;#   synopsis:     Sets the differential evolution parameters for a
;# 		population.
;#   parameters:	population *pop		Population to set parameters of.
;# 		const GAcompare		Callback to compare two entities.
;#   return:	none
;#  **********************************************************************/
;# void 
;# ga_population_set_differentialevolution_parameters (population *pop,
;#                                                     const ga_de_strategy_type strategy,
;#                                                     const ga_de_crossover_type crossover,
;#                                                     const int num_perturbed,
;#                                                     const double weighting_min,
;#                                                     const double weighting_max,
;#                                                     const double crossover_factor)

;# ------------------------------------------------------------------------------
(defun ga_population_set_differentialevolution_parameters (pop          
                                                           strategy           
                                                           crossover          
                                                           num_perturbed      
                                                           weighting_min      
                                                           weighting_max      
                                                           crossover_factor)

  ;;#   if ( !pop ) die("Null pointer to population structure passed.");
  
  ;;#   plog( LOG_VERBOSE, "Population's differential evolution parameters set" );
  
  ;;#   if (pop->de_params == NULL)
  ;;#   {
  ;;#     if ( !(pop->de_params = s_malloc(sizeof(ga_de_t))) )
  ;;#       die("Unable to allocate memory");
  ;;#   }
  
(let (  
  ;;  set DE [GA_DE_T \#auto]
  (DE (make-instance 'GA_DE_T))
  ) 

  ;;  $pop.de_params = $DE
  (setf (POP_DE_PARAMS pop) DE)
  

  (setf (DE_STRATEGY         DE) strategy)
  
  (setf (DE_CROSSOVER_METHOD DE) crossover)
  
  (setf (DE_NUM_PERTURBED    DE) num_perturbed)
  
  (setf (DE_WEIGHT_MIN       DE) weighting_min)
  
  (setf (DE_WEIGHT_MAX       DE) weighting_max)
  
  (setf (DE_CROSSOVER_FACTOR DE) crossover_factor)
  
  ;;  return

))
;# ------------------------------------------------------------------------------


;# ------------------------------------------------------------------------------
;#  * Pick an number of random entities by moving their index to the
;#  * beginning of the permutation array.
;#  * This method is a lot more efficient than the original algorithm's
;#  * approach - especially for small population sizes.
;#
;# void 
;# _gaul_pick_random_entities (int *permutation, int num, int size, int avoid)
;# ------------------------------------------------------------------------------
;proc _gaul_pick_random_entities {&permutation num size avoid} {

;# ------------------------------------------------------------------------------
(defun _gaul_pick_random_entities (r_permutation num size avoid)

;  USE_REFS 

(let (
  ;(is_p  0)
  (is_p   false)
  ;(is_p   true)

  (permutation  (symbol-value r_permutation))
  
  pos val tmp 
  )

  (when is_p
    (format t "~%")
    (format t "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ~%")
    (format t "_gaul_pick_random_entities :  num= ~s  size= ~s  avoid= ~s ~%" num size avoid)
    (format t "~%")
    (format t "permutation = ~s ~%" permutation) ;
    (format t "~%")
  )


  ;;#   int		j;		/* Loop variable over picked numbers. */
  ;;#   int		pos, tmp;	/* Current indices. */

  ;;  for {set j 0} {$j < $num} {incr j} {
  (loop for j from 0 to (1- num) do

    ;;#     do
    ;;#     {
    ;;#       pos = j+random_int(size-j);
    ;;#     } while (permutation[pos] == avoid);
    

    ;;    while 1 {
    (loop while true do

      ;;      set pos [expr {$j + [random_int [expr {$size - $j}]]}]
      (setf pos (+  j (random_int (- size j))))

      ;;      set val [lindex $permutation $pos]
      ;(setf val (nth pos permutation))
      (setf val (elt permutation pos))
      
      ;;      #puts "j= $j  pos= $pos  val= $val  avoid= $avoid"
      ;(format t "j= ~s  pos= ~s  val= ~s  avoid= ~s  ~%" j pos val avoid)

      ;;      if {$val != $avoid} break ;# нашли не "avoid"
      ;;(when (\= val avoid) (return))  
      (unless (= val avoid) (return))  
    )
    

    ;;    # swap j <-> pos
    ;;    # 
    ;;    set tmp [lindex $permutation $j]
    ;(setf tmp (nth j permutation))
    (setf tmp (elt permutation j))
    
    ;;    lset permutation $j [lindex $permutation $pos]
    ;(setf (nth j permutation) (nth pos permutation))
    (setf (elt permutation j) (elt permutation pos))
    
    ;;    if {$is_p} {
    ;;      puts ""
    ;;      puts "pos = $pos" 
    ;;      puts "tmp = $tmp" 
    ;;    }
    
    ;;    lset permutation $pos $tmp;
    ;(setf (nth pos permutation) tmp)
    (setf (elt permutation pos) tmp)
  )

  (when is_p
    (format t "~%")
    (format t "permutation = ~s ~%" permutation);
    (format t "~%")
    (format t "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ ~%")
    (format t "~%")
  )

;  return
))
;# //------------------------------------------------------------------------------
;#
;# //------------------------------------------------------------------------------
;# void calc_tmpentity_11 (population *pop, entity *tmpentity, int n, int i0, 
;#                         int *perm, double weighting_factor) 
;# //------------------------------------------------------------------------------
(defun calc_tmpentity_11 (pop tmpentity n  i0 perm  weighting_factor)
  
;  (when __is_print
;    ;(pop_print_  pop)
;    (format t "  calc_tmpentity_11:  n= ~s  perm= ~s" n perm)
;  )
  
(let* (  
  
;  (p1  (nth 0 perm))  ; [lindex $perm 0]
;  (p2  (nth 1 perm))  ; [lindex $perm 1]
  
  (p1  (elt perm 0))  ; [lindex $perm 0]
  (p2  (elt perm 1))  ; [lindex $perm 1]
  

  (e0  (pop_get_entity_  pop  i0))  
  (e1  (pop_get_entity_  pop  p1))
  (e2  (pop_get_entity_  pop  p2))  

  (g0  (ent_get_chromo_gen_   e0  n))
  (g1  (ent_get_chromo_gen_   e1  n))
  (g2  (ent_get_chromo_gen_   e2  n))
  
  

  ;;  #   double diff = ((double *) pop->entity_iarray[perm[0]]->CH)[n]
  ;;  #               - ((double *) pop->entity_iarray[perm[1]]->CH)[n];
  
  (diff  (- g1 g2))
  
  ;;  #   ((double *)tmpentity->CH)[n] =
  ;;  #     ((double *)pop->entity_iarray[i0]->CH)[n] + weighting_factor * diff;

  (gen  (+ g0 (* weighting_factor diff)))
  )  


;  (when __is_print
;    ;;    $e1 print_ch "  e1= "
;    ;;    puts -nonewline [format "  g1= %f "  $g1]

;    (format t " p1= ~s g1= ~s   p2= ~s g2= ~s  g0= ~s  ~%" p1 g1  p2 g2 g0)
;    )
  
  ;;  #$tmpentity set_chromo_gen  $n $gen

  (ent_set_chromo_gen_  tmpentity  n gen)
  
  ;;   return
))
;# //------------------------------------------------------------------------------
;# void calc_tmpentity2 (population  *pop, int n, int best, 
;#                     entity	*tmpentity, int	*permutation, double weighting_factor) 
;# //------------------------------------------------------------------------------
(defun calc_tmpentity2 (pop n best tmpentity  permutation  weighting_factor)
  
  ;;#   calc_tmpentity_11 (pop, tmpentity, n, 
  ;;#                              best, &permutation[0], weighting_factor);

  (calc_tmpentity_11  pop tmpentity n  best permutation   weighting_factor)

  ;;   return
)
;# //------------------------------------------------------------------------------
(defun calc_tmpentity3  (pop n best tmpentity  permutation  weighting_factor)
 
(declare (ignore  best))
 
  ;;#   calc_tmpentity_11 (pop, tmpentity, n, 
  ;;#                              permutation[0], &permutation[1], weighting_factor);

(let (
  (permutation_0   (elt    permutation 0)) ; [lindex $permutation 0]
  (permutation_1   (subseq permutation 1)) ; [lrange $permutation 1 end]
  )

  (calc_tmpentity_11   pop  tmpentity  n  permutation_0  permutation_1  weighting_factor)

  ;; return
))
;# //------------------------------------------------------------------------------
;# void calc_tmpentity_22 (population *pop, entity *tmpentity, int n, int i0, 
;#                         int *perm, double weighting_factor) 

;# //------------------------------------------------------------------------------
;proc calc_tmpentity_22 {pop tmpentity n i0 perm weighting_factor} {
  
;#   double diff = (((double *) pop->entity_iarray[perm[0]]->CH)[n]
;#                + ((double *) pop->entity_iarray[perm[1]]->CH)[n]
;#                - ((double *) pop->entity_iarray[perm[2]]->CH)[n]
;#                - ((double *) pop->entity_iarray[perm[3]]->CH)[n]);

;#   set e1 [$pop get_entity [lindex $perm 0]]
;#   set e2 [$pop get_entity [lindex $perm 1]]
;#   set e3 [$pop get_entity [lindex $perm 2]]
;#   set e4 [$pop get_entity [lindex $perm 3]]

;  set e1 [pop_get_entity_ $pop [lindex $perm 0]]
;  set e2 [pop_get_entity_ $pop [lindex $perm 1]]
;  set e3 [pop_get_entity_ $pop [lindex $perm 2]]
;  set e4 [pop_get_entity_ $pop [lindex $perm 3]]

;  set g1 [ent_get_chromo_gen_ $e1 $n]
;  set g2 [ent_get_chromo_gen_ $e2 $n]
;  set g3 [ent_get_chromo_gen_ $e3 $n]
;  set g4 [ent_get_chromo_gen_ $e4 $n]

;  set diff [expr {$g1 + $g2 - $g3 - $g4}]

;#   ((double *)tmpentity->CH)[n] =
;#     ((double *)pop->entity_iarray[i0]->CH)[n] + weighting_factor * diff;

;  #set i0_entity   [$pop get_entity $i0]
;  set i0_entity   [pop_get_entity_ $pop  $i0]

;  set i0_entity_n_gen [ent_get_chromo_gen_ $i0_entity $n]

;  #$tmpentity set_chromo_gen $n [expr {$i0_entity_n_gen + $weighting_factor * $diff}]
;  ent_set_chromo_gen_ $tmpentity $n [expr {$i0_entity_n_gen + $weighting_factor * $diff}]

;  return
;}
;# //------------------------------------------------------------------------------
;#  calc_tmpentity4 (population  *pop, int n, int best, 
;#                     entity	*tmpentity, int	*permutation, double weighting_factor) 
;# //------------------------------------------------------------------------------
;proc  calc_tmpentity4 {pop n best tmpentity permutation weighting_factor} {

;#   calc_tmpentity_22 (pop, tmpentity, n, 
;#                              best, &permutation[0], weighting_factor);

;  calc_tmpentity_22  $pop $tmpentity $n \
;                              $best $permutation $weighting_factor

;  return
;}
;# //------------------------------------------------------------------------------
;proc calc_tmpentity5 {pop n best tmpentity permutation weighting_factor} {

;  set permutation_0 [lindex $permutation 0]
;  set permutation_1 [lrange $permutation 1 end]

;#   calc_tmpentity_22 (pop, tmpentity, n, 
;#                              permutation[0], &permutation[1], weighting_factor);

;  calc_tmpentity_22  $pop $tmpentity $n $permutation_0 $permutation_1 $weighting_factor

;  return;
;}
;# //------------------------------------------------------------------------------
;proc calc_tmpentity_33 {pop tmpentity n i0 perm weighting_factor} {
  
;#   set e1 [$pop get_entity [lindex $perm 0]]
;#   set e2 [$pop get_entity [lindex $perm 1]]
;#   set e3 [$pop get_entity [lindex $perm 2]]
;#   set e4 [$pop get_entity [lindex $perm 3]]
;#   set e5 [$pop get_entity [lindex $perm 4]]
;#   set e6 [$pop get_entity [lindex $perm 5]]

;  set e1 [pop_get_entity_ $pop [lindex $perm 0]]
;  set e2 [pop_get_entity_ $pop [lindex $perm 1]]
;  set e3 [pop_get_entity_ $pop [lindex $perm 2]]
;  set e4 [pop_get_entity_ $pop [lindex $perm 3]]
;  set e5 [pop_get_entity_ $pop [lindex $perm 4]]
;  set e6 [pop_get_entity_ $pop [lindex $perm 5]]

;  set g1 [ent_get_chromo_gen_ $e1 $n]
;  set g2 [ent_get_chromo_gen_ $e2 $n]
;  set g3 [ent_get_chromo_gen_ $e3 $n]
;  set g4 [ent_get_chromo_gen_ $e4 $n]
;  set g5 [ent_get_chromo_gen_ $e5 $n]
;  set g6 [ent_get_chromo_gen_ $e6 $n]

;#   double diff = (((double *) pop->entity_iarray [perm[0]]->CH)[n]
;#                + ((double *) pop->entity_iarray [perm[1]]->CH)[n]
;#                + ((double *) pop->entity_iarray [perm[2]]->CH)[n]
;#                - ((double *) pop->entity_iarray [perm[3]]->CH)[n]
;#                - ((double *) pop->entity_iarray [perm[4]]->CH)[n]
;#                - ((double *) pop->entity_iarray [perm[5]]->CH)[n]);

;  set diff [expr {$g1 + $g2 + $g3  - $g4 - $g5 - $g6}]

;#   ((double *)tmpentity->CH)[n] = 
;#     ((double *) pop->entity_iarray[i0]->CH)[n] + weighting_factor * diff;

;  #set i0_entity   [$pop get_entity $i0]
;  set i0_entity   [pop_get_entity_ $pop  $i0]

;  set i0_entity_n_gen [ent_get_chromo_gen_ $i0_entity $n]

;  #$tmpentity set_chromo_gen $n [expr {$i0_entity_n_gen + $weighting_factor * $diff}]
;  ent_set_chromo_gen_ $tmpentity $n [expr {$i0_entity_n_gen + $weighting_factor * $diff}]

;  return
;}
;# //------------------------------------------------------------------------------
;proc calc_tmpentity6 {pop n best tmpentity permutation weighting_factor} {
  
;#   calc_tmpentity_33 (pop, tmpentity, n, 
;#                              best, &permutation[0], weighting_factor);

;  calc_tmpentity_33  $pop $tmpentity $n \
;                              $best $permutation $weighting_factor
;  return
;}
;# //------------------------------------------------------------------------------
;proc calc_tmpentity7 {pop n best tmpentity permutation weighting_factor} {

;#   calc_tmpentity_33 (pop, tmpentity, n, 
;#                              permutation[0], &permutation[1], weighting_factor);

;  set permutation_0 [lindex $permutation 0]
;  set permutation_1 [lrange $permutation 1 end]

;  calc_tmpentity_33  $pop $tmpentity $n $permutation_0 $permutation_1 $weighting_factor


;  return
;}
;# //------------------------------------------------------------------------------
;# void calc_tmpentity_1bin (population  *pop, int n, int best, 
;#                       entity *tmpentity, int *permutation, double weighting_factor) 
;# //------------------------------------------------------------------------------
(defun  calc_tmpentity_1bin (pop n best tmpentity permutation weighting_factor)


  ;;#   double diff = (((double *)pop->entity_iarray[best]->CH)[n]
  ;;#                - ((double *)tmpentity->CH)[n]
  ;;#                + ((double *)pop->entity_iarray[permutation[0]]->CH)[n]
  ;;#                - ((double *)pop->entity_iarray[permutation[1]]->CH)[n]);
  
  ;;#   ((double *) tmpentity->CH)[n] += weighting_factor * diff;
 
(let* (
  ;;  #set e1 [$pop get_entity $best]
  (e1  (pop_get_entity_  pop  best))

  (e2  tmpentity)
       ;;  #set e3 [$pop get_entity [lindex $permutation 0]]
       ;;  #set e4 [$pop get_entity [lindex $permutation 1]]
  (e3  (pop_get_entity_  pop (elt  permutation 0)))
  (e4  (pop_get_entity_  pop (elt  permutation 1)))

  (g1  (ent_get_chromo_gen_  e1  n))
  (g2  (ent_get_chromo_gen_  e2  n))
  (g3  (ent_get_chromo_gen_  e3  n))
  (g4  (ent_get_chromo_gen_  e4  n))

  (diff (+ (- g1 g2) (- g3  g4)))  ; [expr {$g1 - $g2 + $g3  - $g4}]
  )

  ;;  #$tmpentity set_chromo_gen $n  [expr {$g2 + $weighting_factor * $diff}]
  (ent_set_chromo_gen_  tmpentity  n  (+ g2 (* weighting_factor diff)))

  ;;  return
))
;# //------------------------------------------------------------------------------
;# void calc_tmpentity_2bin (population  *pop, int n, int best, 
;#                       entity *tmpentity, int *permutation, double weighting_factor) 
;# //------------------------------------------------------------------------------
;proc  calc_tmpentity_2bin {pop n best tmpentity permutation weighting_factor} {

;#   double diff = (((double *)pop->entity_iarray[best]->CH)[n]
;#                - ((double *)tmpentity->CH)[n]
;#                + ((double *)pop->entity_iarray[permutation[0]]->CH)[n]
;#                + ((double *)pop->entity_iarray[permutation[1]]->CH)[n]
;#                - ((double *)pop->entity_iarray[permutation[2]]->CH)[n]
;#                - ((double *)pop->entity_iarray[permutation[3]]->CH)[n]);

;#   ((double *)tmpentity->CH)[n] += weighting_factor * diff;

;  #set e1 [$pop get_entity $best]
;  set e1 [pop_get_entity_ $pop  $best]

;  set e2 $tmpentity
;#   set e3 [$pop get_entity [lindex $permutation 0]]
;#   set e4 [$pop get_entity [lindex $permutation 1]]
;#   set e5 [$pop get_entity [lindex $permutation 2]]
;#   set e6 [$pop get_entity [lindex $permutation 3]]

;  set e3 [pop_get_entity_ $pop [lindex $permutation 0]]
;  set e4 [pop_get_entity_ $pop [lindex $permutation 1]]
;  set e5 [pop_get_entity_ $pop [lindex $permutation 2]]
;  set e6 [pop_get_entity_ $pop [lindex $permutation 3]]

;  set g1 [ent_get_chromo_gen_ $e1 $n]
;  set g2 [ent_get_chromo_gen_ $e2 $n]
;  set g3 [ent_get_chromo_gen_ $e3 $n]
;  set g4 [ent_get_chromo_gen_ $e4 $n]
;  set g5 [ent_get_chromo_gen_ $e5 $n]
;  set g6 [ent_get_chromo_gen_ $e6 $n]

;  set diff [expr {$g1 - $g2 + $g3 + $g4 - $g5 - $g6}]


;  #$tmpentity set_chromo_gen $n  [expr {$g2 + $weighting_factor * $diff}]
;  ent_set_chromo_gen_ $tmpentity $n  [expr {$g2 + $weighting_factor * $diff}]

;  return
;}
;# //------------------------------------------------------------------------------
;proc DE_best_1_exp {pop i n best tmpentity &name_permutation weighting_factor} {

;  USE_REFS

;  set N 2
;  set calc_proc "calc_tmpentity$N"

;  DE_best_exp  $pop $i $n $best $tmpentity name_permutation $weighting_factor \
;               $N $calc_proc

;  return
;}
;# //------------------------------------------------------------------------------
;proc DE_best_2_exp {pop i n best tmpentity &name_permutation weighting_factor} {

;  USE_REFS

;  set N 4
;  set calc_proc "calc_tmpentity$N"

;  DE_best_exp  $pop $i $n $best $tmpentity name_permutation $weighting_factor \
;               $N $calc_proc

;  return
;}
;# //------------------------------------------------------------------------------
;proc DE_best_3_exp {pop i n best tmpentity &name_permutation weighting_factor} {

;  USE_REFS

;  set N 6
;  set calc_proc "calc_tmpentity$N"

;  DE_best_exp  $pop $i $n $best $tmpentity name_permutation $weighting_factor \
;               $N $calc_proc

;  return
;}
;# //------------------------------------------------------------------------------
;proc DE_rand_1_exp {pop i n best tmpentity &name_permutation weighting_factor} {

;  USE_REFS

;  set N 3
;  set calc_proc "calc_tmpentity$N"

;  DE_best_exp  $pop $i $n $best $tmpentity name_permutation $weighting_factor \
;               $N $calc_proc

;  return
;}
;# //------------------------------------------------------------------------------
;proc DE_rand_2_exp {pop i n best tmpentity &name_permutation weighting_factor} {

;  USE_REFS

;  set N 5
;  set calc_proc "calc_tmpentity$N"

;  DE_best_exp  $pop $i $n $best $tmpentity name_permutation $weighting_factor \
;               $N $calc_proc

;  return
;}
;# //------------------------------------------------------------------------------
;proc DE_rand_3_exp {pop i n best tmpentity &name_permutation weighting_factor} {

;  USE_REFS

;  set N 7
;  set calc_proc "calc_tmpentity$N"

;  DE_best_exp  $pop $i $n $best $tmpentity name_permutation $weighting_factor \
;               $N $calc_proc

;  return
;}
;# //------------------------------------------------------------------------------
;proc DE_best_exp {pop i n best tmpentity &name_permutation weighting_factor  \
;                 N  calc_proc } {

;  USE_REFS

;  set len_chromosomes [$pop cget -len_chromosomes]

;  _gaul_pick_random_entities   name_permutation $N [$pop cget -orig_size] $i
;  set L   0


;  while (1) {
    
;    $calc_proc  $pop $n $best $tmpentity $name_permutation $weighting_factor 
       
;    set n [expr {($n + 1) % $len_chromosomes}]
;    incr L

;    #set factor [$pop cget -de_crossover_factor]
;    set factor [[$pop.de_params].de_crossover_factor]

;    set flag [random_boolean_prob $factor]
 
;    if {! $flag} { break; } ;# вообще заканчиваем цикл ! и выходим
    
;    if {! [expr {$L < $len_chromosomes}]}   { break; }
;  }
  

;  return
;}
;# //------------------------------------------------------------------------------
;proc DE_randtobest_1_exp {pop i n best tmpentity &name_permutation weighting_factor} {

;  USE_REFS

;  set N 2
;  set calc_proc "calc_tmpentity_1bin"

;  DE_best_exp  $pop $i $n $best $tmpentity name_permutation $weighting_factor \
;               $N $calc_proc

;  return
;}
;# //------------------------------------------------------------------------------
;proc DE_randtobest_2_exp {pop i n best tmpentity &name_permutation weighting_factor} {

;  USE_REFS

;  set N 4
;  set calc_proc "calc_tmpentity_2bin"

;  DE_best_exp  $pop $i $n $best $tmpentity name_permutation $weighting_factor \
;               $N $calc_proc

;  return
;}
;# //------------------------------------------------------------------------------
;# //------------------------------------------------------------------------------
;proc DE_best_1_bin {pop i n best tmpentity &name_permutation weighting_factor} {

;# //------------------------------------------------------------------------------
(defun DE_best_1_bin (pop i n best tmpentity  r_name_permutation weighting_factor)


  ;;  USE_REFS
(let (
  (name_permutation (symbol-value r_name_permutation))
  len_chromosomes  L flag
  )

  (_gaul_pick_random_entities  r_name_permutation 2 (POP_ORIG_SIZE pop) i) 
                                               ;; [$pop cget -orig_size] $i
      

  (calc_tmpentity2   pop n best tmpentity name_permutation  weighting_factor) 

  (setf len_chromosomes (POP_LEN_CHROMOSOMES pop)) ; [$pop cget -len_chromosomes]
  (setf L   1)


  ;;  while (1) {
  (loop while true do

    ;;    if {! [expr {$L < $len_chromosomes}]} { break; }
    (when (not (< L len_chromosomes)) (return))

    (setf flag (random_boolean))

    (when flag
      (calc_tmpentity2  pop n best tmpentity name_permutation weighting_factor)
      )

    ;;    # // а здесь не заканчиваем, но продолжаем!
    
    (setf n   (mod (+ n 1) len_chromosomes))
    ;;
    ;;set n [expr {($n + 1) % $len_chromosomes}]

    (incf L)
    )
 
  ;;  (set r_ind_index                    ind_index) !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

;  return
))
;# //------------------------------------------------------------------------------
;#
;# не пошло! хотя вроде один в один
;#
;# //------------------------------------------------------------------------------
;proc DE_best_1_bin_new {pop i n best tmpentity  &name_permutation weighting_factor} {
  
;  USE_REFS

;  set N 2
;  set calc_proc "calc_tmpentity2"


;  DE_best_bin  $pop $i $n $best $tmpentity  name_permutation $weighting_factor \
;                 $N $calc_proc

;  return
;}
;# //------------------------------------------------------------------------------
;proc DE_best_bin {pop i n best tmpentity  &name_permutation weighting_factor \
;                 N calc_proc} {
  
;# //------------------------------------------------------------------------------
(defun DE_best_bin (pop i n best tmpentity  r_name_permutation weighting_factor 
                        N_ calc_proc)
  
;  USE_REFS

(let (
  (name_permutation (symbol-value r_name_permutation))
  len_chromosomes  flag
  )

  ;(format t "DE_best_bin  .. 01 ~%")

  (_gaul_pick_random_entities   r_name_permutation  N_ (POP_ORIG_SIZE pop) i)
  
  (funcall calc_proc   pop  n  best  tmpentity  name_permutation  weighting_factor)

  (setf len_chromosomes (POP_LEN_CHROMOSOMES pop)) ;[$pop cget -len_chromosomes]

  ;(format t "DE_best_bin  .. 02 ~%")


  ;;  for {set L 1} {$L < $len_chromosomes} {incr L} {
  (loop for L from 1 to (1- len_chromosomes) do

    ;(format t "DE_best_bin  .. 03 ~%")

    (setf flag (random_boolean))
 
    ;(format t "DE_best_bin  .. L= ~s flag= ~s ~%" L flag)

    (when flag
      (funcall calc_proc   pop  n  best  tmpentity  name_permutation  weighting_factor) 
      )

    ;;    set n [expr {($n + 1) % $len_chromosomes}]
    (setf n   (mod (+ n 1) len_chromosomes))
    )
 
  ;(format t "DE_best_bin  .. 04 ~%")

                                ;;  return
))
;# //------------------------------------------------------------------------------
;proc DE_best_2_bin {pop i n best tmpentity  &name_permutation weighting_factor} {
  
;  USE_REFS

;  set N 4
;  set calc_proc "calc_tmpentity4"


;  DE_best_bin  $pop $i $n $best $tmpentity  name_permutation $weighting_factor \
;                 $N $calc_proc

;  return
;}
;# //------------------------------------------------------------------------------
;proc DE_best_3_bin {pop i n best tmpentity  &name_permutation weighting_factor} {
  
;  USE_REFS

;  set N 6
;  set calc_proc "calc_tmpentity6"


;  DE_best_bin  $pop $i $n $best $tmpentity  name_permutation $weighting_factor \
;                 $N $calc_proc

;  return
;}
;# //------------------------------------------------------------------------------
;proc DE_rand_1_bin {pop i n best tmpentity  &name_permutation weighting_factor} {
  
;# //------------------------------------------------------------------------------
(defun DE_rand_1_bin (pop i n best tmpentity  r_name_permutation weighting_factor)
  
  ;;  USE_REFS

(let (
  (N_  3)
  (calc_proc 'calc_tmpentity3)
  )


  (DE_best_bin   pop  i  n  best  tmpentity  r_name_permutation  weighting_factor
                 N_ calc_proc)

  ;;  return
))
;# //------------------------------------------------------------------------------
;proc DE_rand_2_bin {pop i n best tmpentity  &name_permutation weighting_factor} {
  
;  USE_REFS

;  set N 5
;  set calc_proc "calc_tmpentity5"


;  DE_best_bin  $pop $i $n $best $tmpentity  name_permutation $weighting_factor \
;                 $N $calc_proc

;  return
;}
;# //------------------------------------------------------------------------------
;# void DE_rand_3_bin (population  *pop, int i, int n, int best, 
;#                     entity	*tmpentity, int	*permutation, double weighting_factor)
;# {
  
;#   int L;  /* Allele indice */
  
;#   _gaul_pick_random_entities(permutation, 7, pop->orig_size, i);
  
;#   calc_tmpentity7 (pop, n, best, tmpentity, permutation, weighting_factor); 
  
;#   for (L=1; L<pop->len_chromosomes; L++)
;#   {
;#     if (random_boolean ()) {
;#       calc_tmpentity7 (pop, n, best, tmpentity, permutation, weighting_factor); 
;#     }

;#     n = (n+1) % pop->len_chromosomes;
;#   }
  

;# }
;# //------------------------------------------------------------------------------
;proc DE_rand_3_bin {pop i n best tmpentity  &name_permutation weighting_factor} {
  
;  USE_REFS

;  set N 7
;  set calc_proc "calc_tmpentity7"


;  DE_best_bin  $pop $i $n $best $tmpentity  name_permutation $weighting_factor \
;                 $N $calc_proc

;  return
;}
;# //------------------------------------------------------------------------------
(defun  DE_randtobest_1_bin (pop i n best tmpentity  r_name_permutation weighting_factor)
  
  ;;  USE_REFS
  
  ;;  set N 2
  ;;  set calc_proc "calc_tmpentity_1bin"

(let (
  (N_  2)
  (calc_proc 'calc_tmpentity_1bin)
  )


  (DE_best_bin   pop  i  n  best  tmpentity  r_name_permutation  weighting_factor 
                 N_ calc_proc)

  ;;  return
))
;# //------------------------------------------------------------------------------
;# void DE_randtobest_2_bin (population  *pop, int i, int n, int best, 
;#                     entity	*tmpentity, int	*permutation, double weighting_factor)
;# {
  
;#   int L;  /* Allele indice */
  
;#   _gaul_pick_random_entities(permutation, 4, pop->orig_size, i);
  
;#   calc_tmpentity_2bin (pop, n, best, 
;#                        tmpentity, permutation, weighting_factor);

  
;#   for (L=1; L < pop->len_chromosomes; L++)
;#   {
;#     if ( random_boolean() )
;#       calc_tmpentity_2bin (pop, n, best, 
;#                            tmpentity, permutation, weighting_factor);

;#     n = (n+1)%pop->len_chromosomes;
;#   }

;# }
;# //------------------------------------------------------------------------------
;proc DE_randtobest_2_bin {pop i n best tmpentity  &name_permutation weighting_factor} {
  
;  USE_REFS

;  set N 4
;  set calc_proc "calc_tmpentity_2bin"


;  DE_best_bin  $pop $i $n $best $tmpentity  name_permutation $weighting_factor \
;                 $N $calc_proc

;  return
;}
;# //------------------------------------------------------------------------------
(defun die (message)


  (format t "~%")
  (format t "~a ~%" message)
  (format t "~%")

  (exit)

)
;# //------------------------------------------------------------------------------
;# void ga_de_crossover_binomial (population  *pop, int i, int n, int best, 
;#                                entity	*tmpentity, int	*permutation, double weighting_factor)
;# //------------------------------------------------------------------------------
;proc ga_de_crossover_binomial {pop i n best tmpentity &name_permutation weighting_factor} {

;# //------------------------------------------------------------------------------
(defun ga_de_crossover (suf pop i n best tmpentity  r_permutation weighting_factor)


(let* ( 
  ;(suf  "_bin")

  (de_params (POP_DE_PARAMS pop))

  (strategy       (DE_STRATEGY      de_params))  
  (num_perturbed  (DE_NUM_PERTURBED de_params)) 

  (DE_best_1       (read-from-string (concatenate 'string   "DE_best_1" suf)))
  (DE_best_2       (read-from-string (concatenate 'string   "DE_best_2" suf)))
  (DE_best_3       (read-from-string (concatenate 'string   "DE_best_3" suf)))

  (DE_rand_1       (read-from-string (concatenate 'string   "DE_rand_1" suf)))
  (DE_rand_2       (read-from-string (concatenate 'string   "DE_rand_2" suf)))
  (DE_rand_3       (read-from-string (concatenate 'string   "DE_rand_3" suf)))

  (DE_randtobest_1 (read-from-string (concatenate 'string   "DE_randtobest_1" suf)))
  (DE_randtobest_2 (read-from-string (concatenate 'string   "DE_randtobest_2" suf)))
  )


  ;(format t "STRATEGY =  ~s ~%" strategy)

  ;;  (when __is_print
  ;;    (format t "ga_de_crossover_binomial: strategy = ~s  num_perturbed = ~s ~%"
  ;;           strategy  num_perturbed)
  ;;  )

  (cond 

   ;-----------------------------------------
   ((equal strategy "GA_DE_STRATEGY_BEST")    
    (cond 

     ((= num_perturbed 1)      
      (funcall DE_best_1   pop  i  n  best  tmpentity r_permutation  weighting_factor))    
      
     ((= num_perturbed 2)      
      (funcall DE_best_2   pop  i  n  best  tmpentity r_permutation  weighting_factor))   
      
     ((= num_perturbed 3)      
      (funcall DE_best_3   pop  i  n  best  tmpentity r_permutation  weighting_factor))
      
     (t
      (die "Invalid differential evolution selection number."))
     ))
   ;-----------------------------------------

   ;-----------------------------------------
   ((equal  strategy "GA_DE_STRATEGY_RAND")
    (cond 

     ((= num_perturbed 1)
      (funcall DE_rand_1   pop  i  n  best  tmpentity r_permutation  weighting_factor))     

     ((= num_perturbed 2) 
      (funcall DE_rand_2   pop  i  n  best  tmpentity r_permutation  weighting_factor))    

     ((= num_perturbed 3)
      (funcall DE_rand_3   pop  i  n  best  tmpentity r_permutation  weighting_factor))   

     (t
      (die "Invalid differential evolution selection number."))
     ))
   ;-----------------------------------------


   ;-----------------------------------------
   ((equal  strategy "GA_DE_STRATEGY_RANDTOBEST")
    (cond 

     ((= num_perturbed 1) 
      (funcall DE_randtobest_1   pop  i  n best  tmpentity r_permutation  weighting_factor))

     ((= num_perturbed 2) 
      (funcall DE_randtobest_2   pop  i  n best  tmpentity r_permutation  weighting_factor))

     (t
      (die "Invalid differential evolution selection number."))
     ))
   ;-----------------------------------------


   (t (progn  
        (format t "strategy =  ~s ~%" strategy)
        (die "Unknown differential evolution strategy")
        ))
   )
      
))
;# //------------------------------------------------------------------------------
;# void ga_de_crossover_exponential (population  *pop, int i, int n, int best, 
;#                                   entity      *tmpentity, int *permutation, double weighting_factor)

;# //------------------------------------------------------------------------------
;(defun ga_de_crossover_exponential (pop i n best tmpentity &name_permutation weighting_factor)


;  set strategy         [[$pop.de_params].de_strategy]

;  set num_perturbed    [[$pop.de_params].de_num_perturbed]
  

;  if {$strategy == "GA_DE_STRATEGY_BEST"} {    
;    if       {$num_perturbed == 1} {       
;      DE_best_1_exp  $pop $i $n $best $tmpentity name_permutation $weighting_factor  
    
;    } elseif {$num_perturbed == 2} {       
;      DE_best_2_exp  $pop $i $n $best $tmpentity name_permutation $weighting_factor
      
;    } elseif {$num_perturbed == 3} { 
;      DE_best_3_exp  $pop $i $n $best $tmpentity name_permutation $weighting_factor 
   
;    } else {
;      die "Invalid differential evolution selection number."
;    }   
 
;  } elseif {$strategy == "GA_DE_STRATEGY_RAND"} {
;    if       {$num_perturbed == 1} {       
;     DE_rand_1_exp  $pop $i $n $best $tmpentity name_permutation $weighting_factor        

;    } elseif {$num_perturbed == 2} { 
;     DE_rand_2_exp  $pop $i $n $best $tmpentity name_permutation $weighting_factor           

;    } elseif {$num_perturbed == 3} {       
;     DE_rand_3_exp  $pop $i $n $best $tmpentity name_permutation $weighting_factor
                
;    } else {
;      die "Invalid differential evolution selection number."
;    }

;  } elseif {$strategy == "GA_DE_STRATEGY_RANDTOBEST"} {
;    if      {$num_perturbed == 1} {       
;     DE_randtobest_1_exp  $pop $i $n $best $tmpentity name_permutation $weighting_factor        

;    } elseif {$num_perturbed == 2} {       
;     DE_randtobest_2_exp  $pop $i $n $best $tmpentity name_permutation $weighting_factor           

;    } else {
;      die "Invalid differential evolution selection number."
;    }

;  } else {

;    #  die ("Unknown differential evolution strategy.");
;    puts "Unknown differential evolution strategy."
;  }

  
;)
;#-------------------------------------------------------------------------------
(defun find_best_solution (pop rank_proc)

(let (
  (best 0)
  
  ;  # а почему с 1-го а не с 0-го ищем?
  ;  # 
  (i0   0) ;# // 1 -было ?!
  )

  (if (equal rank_proc "ga_rank_fitness")
    
    ;    for {set i $i0} {$i < [$pop cget -size]} {incr i} {
    (loop for i from i0 to (1- (POP_SIZE pop)) do
      
      ;;      # if (pop->entity_iarray[i]->fitness > pop->entity_iarray[best]->fitness)
      ;;      #    best = i;
      
      ;;      #if {[$pop get_entity_fitness $i] > [$pop get_entity_fitness $best]} {}

      (when (> (pop_get_entity_fitness_  pop i) (pop_get_entity_fitness_  pop  best))
            (setf best  i)
            )     
      )   
  )

  ;  } else {
    
  ;    #       for (i=1; i<pop->size; i++)
  ;    #       {
  ;    #         if ( pop->rank(pop, pop->entity_iarray[i],
  ;    #                        pop, pop->entity_iarray[best]) > 0 )
  ;    #           best = i;
  ;    #       }
  ;  }

  ;  $pop configure -best $best ;# и занесем сразу номер лучшего элемента
  (setf (POP_BEST pop) best)

  ;  return $best
  best
))
;# ------------------------------------------------------------------------------
;# //  synopsis:	Performs differential evolution. 

;# GAULFUNC int ga_differentialevolution (population  *pop,
;#                                        const int  max_generations)
;# {
;#   int		generation = 0;		/* Current generation number. */
;# //------------------------------------------------------------------------------
(defun prepare_permutation (size)


  (when __is_print
    (format t "Prepare arrays to store permutations ... ~%")
  )

  ;  # 
  ;  # if ( !(permutation = s_malloc(sizeof(int)*pop->size)) )
  ;  #   die("Unable to allocate memory");

(let (
  
  ;(permutation "")
  ;(permutation  NIL)

  ;(permutation  (make-list size))
  (permutation  (make-array size))

  ;(permutation  (list 0))
  )

  ;  for {set i 0} {$i < $size} {incr i} {
  (loop for i from 0 to (1- size) do

    ;;    #permutation [i] = i;
    ;;    lappend permutation $i

    ;(setf permutation (append permutation i)) ????? как вообще добавлять то ??

    ;(setf (nth i permutation) i)
    (setf (elt permutation i) i)

    ;(format t "prepare_permutation: i= ~s  permutation= ~s  ~%" i permutation)
  )

  ;  return $permutation
  permutation

))
;#-------------------------------------------------------------------------------
(defun pop_eliminate (pop)

  ;;  #//
  ;;  #// Eliminate the original population members.
  ;;  #//
  
  ;;  #while (pop->orig_size > 0)
  ;;  #{
  ;;  #  pop->orig_size--;
  ;;  #  ga_entity_dereference_by_rank (pop, pop->orig_size);
  ;;  #}
  
  ;;  # у нас есть возможность сделать все проще! н
  ;;  # задача: удалить старую популяцию. т.е. первые orig_size элементов:
  
  ;;  #$pop eliminate

  (pop_eliminate_  pop)

  ;;  return
)
;#-------------------------------------------------------------------------------
(defun ga_differentialevolution	(pop max_generations)

(let (
  (DE   (POP_DE_PARAMS  pop))
  
  (generation  0) ;# #   int generation = 0; /* Current generation number. */
  
  ;;  #   int	i;			/* Loop variable over entities. */
  ;;  #   int	best;			/* Index of best entity. */
  ;;  #   int	*permutation;		/* Permutation array for random selections. */
  ;;  #   entity	*tmpentity;		/* New entity. */
  ;;  #   int	n;			/* Allele indices. */
  ;;  #   double	weighting_factor;	/* Weighting multiplier. */
  
  ;;  #   /* Checks. */
  
  ;;  #   if (!pop)
  ;;  #     die ("NULL pointer to population structure passed.");
  ;;  #   if (!pop->de_params)
  ;;  #     die ("ga_population_set_differentialevolution_params(), or similar, must 
  ;;  #   be used prior to ga_differentialevolution().");
  
  ;;  #   if (!pop->evaluate)       die ("Population's evaluation callback is undefined.");
  ;;  #   if (!pop->rank)           die ("Population's ranking callback is undefined.");
  ;;  #   if (pop->stable_size < 6) die ("Population's stable size is too small.  (Must be at least 6)");
  ;;  #   if ( pop->de_params->crossover_factor < 0.0 ||
  ;;  #       pop->de_params->crossover_factor > 1.0 )
  ;;  #     die ("Invalid crossover_factor.");
  
  ;;  #   plog (LOG_VERBOSE, "The differential evolution has begun!");
  
  ;;  #   pop->generation = 0;

  (size        (POP_SIZE        pop)) ;  [$pop cget -size]
  ;(stable_size (POP_STABLE_SIZE pop)) ;  [$pop cget -stable_size]

  entity fit
  (eval_proc   (POP_EVALUATE    pop))

  permutation weighting_min weighting_max weighting_factor rank_proc best
  oldentity tmpentity n 
  crossover_method strategy num_perturbed
  is_edone old_fit new_fit is_worse

  len
  )

;    (setf crossover_method (DE_CROSSOVER_METHOD DE)) ; [$DE.de_crossover_method]
;    (setf strategy         (DE_STRATEGY         DE)) ; [$DE.de_strategy]    
;    (setf num_perturbed    (DE_NUM_PERTURBED    DE)) ; [$DE.de_num_perturbed]
  ;; -------------------------------------------------------------------

   (declare (special permutation))

 
  ;;  $pop configure -generation 0
  (setf (POP_GENERATION pop) 0)
  
  ;;  # 
  ;;  # Score the initial population members.
  ;;  #  
  

;  (format t "ga_differentialevolution ....... 01 ~%")

;  (format t "size        = ~s ~%"        size  )
;  (format t "stable_size = ~s ~%" stable_size  )
  
  ;;  # вот это что тут за фигня? если популяция не полна, то дополнить новыми членами?
  ;;  # 
  ;;  #   if (pop->size < pop->stable_size) {
  ;;  #     gaul_population_fill (pop, pop->stable_size - pop->size);
  ;;  #   }
  
  
  ;;  # зачем здесь отдельно для нулевого?
  ;;  # 
  ;;  #   if (pop->entity_iarray[0]->fitness == GA_MIN_FITNESS) {
  ;;  #     pop->evaluate(pop, pop->entity_iarray[0]);
  ;;  #   }
  
  ;;  #   /* #pragma omp parallel for \ */
  ;;  #   /*    shared(pop) private(i) \ */
  ;;  #   /*    schedule(static) */
  
  
  ;-------------------------------------------------------------------
  (when __is_print 
    (format t "~%")
    )

  ;;  for {set i 0} {$i < $size} {incr i} {
  (loop 
    for i from 0 to (- size 1)  do
    ;for i  from 0
    ;unless (< i size)
    ;do
  
    ;;    #  if (pop->entity_iarray[i]->fitness == GA_MIN_FITNESS)
    ;;    #      pop->evaluate(pop, pop->entity_iarray[i]);
    
    ;;    #set entity [$pop get_entity $i]
    ;;    set entity [pop_get_entity_ $pop  $i]
    (setf entity (pop_get_entity_  pop  i))
    
    ;(format t "i= ~s   entity= ~s ~%" i entity)
    
    (setf fit (ENT_FITNESS entity))

    ;(format t "ga_differentialevolution .. i= ~s  fit= ~s ~%" i fit)

    (when (eql fit __GA_MIN_FITNESS)
    ;(when (= fit __GA_MIN_FITNESS)
      ;(format t "i = ~s ~%" i)
      (funcall eval_proc pop entity)
      ;;      [$pop cget -evaluate] $pop $entity
      )


    (when __is_print 
      (setf fit (ENT_FITNESS entity))

      (format t "ga_diff: evaluate .. i= ~2s  fit= ~,6F ~%" i fit)
      )

   )

  (when __is_print 
    (format t "~%")
    )
  ;-------------------------------------------------------------------
  
  
  (setf permutation (prepare_permutation  (POP_SIZE pop))) ; [$pop cget -size]]
  
  ;;  #
  ;;  # Determine weighting factor. (в ходе генерации не меняется, я предположил..)
  ;;  #   
  (setf weighting_min (DE_WEIGHT_MIN  DE)) ; [$DE.de_weighting_min]
  
  (setf weighting_max (DE_WEIGHT_MAX  DE)) ; [$DE.de_weighting_max]
  
  ;;  # gaul.h.tl:
  ;;  #
  ;;  # int ga_rank_fitness (population *alphapop, entity *alpha, population *betapop, entity *beta);
  
  (setf rank_proc (POP_RANK pop)) ; [$pop cget -rank]
  
  ;;  # ~~~~~~~~~~~~~~~~~~~~~~~ GENERATION LOOP BEGIN ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  ;;  # 
  ;;  # Stop when (a) max_generations reached, or
  ;;  #           (b) "pop->generation_hook" returns FALSE.
  
  ;;  #   while ( 
  ;;  #          (pop->generation_hook?pop->generation_hook(generation, pop):TRUE) &&
  ;;  #          generation < max_generations 
  ;;  #          )
  
  ;;  #while {$generation < $max_generations} {}
  ;;  while {1} {
  (loop while true do
  
  (if __is_print (progn
        (format t "~%")
        (format t "GENERATION LOOP ......... generation = ~s ~%" generation)
        (format t "~%")

        )
        ;;    } else {
        
        ;;      #pop->generation_hook (generation, pop); // печать через 10
        ;;      [$pop cget -generation_hook]  $generation $pop ; #// печать через 10
        (funcall (POP_GENERATION_HOOK pop) generation pop)
        )
  
  ;;    if {$generation >= $max_generations} {break}
  (when (>= generation max_generations) (return))
  
  ;;    # хитроумный трюк здесь и в конце
  ;;    $pop configure -orig_size  [$pop cget -size] 
  (setf (POP_ORIG_SIZE pop) (POP_SIZE pop))
  
  ;;    # Determine weighting factor. (на каждой генерации меняем весовой фактор ?)
  
  (if (= weighting_min weighting_max)
    (setf weighting_factor  weighting_min)
    (setf weighting_factor (random_double_range  weighting_min weighting_max))
  )
  
  
  ;;    # 
  ;;    # Find best solution.
  ;;    # 
  (setf best (find_best_solution  pop rank_proc))
  
  (incf generation) ;#     generation++;

  ;;    $pop configure -generation $generation
  (setf (POP_GENERATION pop) generation)
  
  
  ;;    # ~~~~~~~~~~~~~~~~~ I LOOP BEGIN ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  ;;    # 
  ;;    # цикл по каждому элементу I, для его корректировки
  
  ;;    for {set i 0} {$i < [$pop cget -orig_size]} {incr i} {
  (loop for i from 0 to (1- (POP_ORIG_SIZE pop)) do
  
    (finish-output)

    (when __is_print
      (format t "~%")
      (format t "i= ~2s  .................................... ~%"  i)

      (format t "~%")
      (pop_print  pop)
      (format t "~%")
      )
  
  
    ;;      #set oldentity [$pop get_entity $i]
    (setf oldentity (pop_get_entity_  pop  i))
    
    (when  __is_print
      (print_entit   oldentity "OLDENTITY =")
      (finish-output)
      (pop_print  pop)
      )
    
    ;;      # tmpentity = ga_entity_clone (pop, pop->entity_iarray[i]);
    ;;      #
    ;;      # в оригинале здесь было клонирование с добавлением в массив, но мы хотим
    ;;      # сделать без добавления:
    ;;      # 
    (setf tmpentity (ga_entity_clone_without_add  pop oldentity))
    
    ;(format t "... 001 ~%")
      
    (setf len (POP_LEN_CHROMOSOMES pop))

    (setf n (random_int  len)) ; $pop cget -len_chromosomes]] ;# случайный номер гена
       

    ;(format *error-output* " ~%")
    ;(format *error-output* "len = ~s  n = ~s !!!!!!!!!!!!!!!!!!!!!!!!!  ~%" len n)
    ;(format *error-output* " ~%")


    ;(format t "... 002 ~%")

    ;;      #
    ;;      # Note that the following code may appear bloated due to excessive
    ;;      # extraction of branches from loops.
    ;;      # However, this yields much more efficient code (particularly for larger
    ;;      # chromosomes) on less-than-cutting-edge compilers.
    ;;      # 
    
    ;(setf de_params (POP_DE_PARAMS pop)); [$pop.de_params] ;# целиком структура
    
    ; почему не вынести в самое начало???
    ; 
    (setf crossover_method (DE_CROSSOVER_METHOD DE)) ; [$DE.de_crossover_method]
    (setf strategy         (DE_STRATEGY         DE)) ; [$DE.de_strategy]
    
    ;(format t "... 003 ~%")

    (setf num_perturbed    (DE_NUM_PERTURBED    DE)) ; [$DE.de_num_perturbed]

    ;(format t "... 004 ~%")
    
    (when __is_print
      (print_entit   tmpentity "TMPENTITY =")
      ;(format t "permutation = ~a ~%" permutation)
      (pop_print  pop)
      ;(pop_print_  pop) (finish-output)
      )
    
    ;;      # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    (if (equal crossover_method "GA_DE_CROSSOVER_BINOMIAL")
        ;;# GA_DE_CROSSOVER_BINOMIAL
        (ga_de_crossover "_bin"  pop i n best tmpentity 'permutation
                                      weighting_factor)       
        ;;      } else { 
        ;;# GA_DE_CROSSOVER_EXPONENTIAL       
        (ga_de_crossover "_exp"  pop i n best tmpentity 'permutation 
                                      weighting_factor)
        )
   
    ;;      # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    
    (when __is_print
      (print_entit   tmpentity "TMPENTITY =")
      (pop_print  pop) (finish-output)
      )
    
    ;;      # посчитаем фитнес для нового элемента and restore the former chromosome 
    ;;      # values if this new solution is not an improvement
    ;;      # 
    ;;      set is_edone [[$pop cget -evaluate] $pop $tmpentity] 
    (setf is_edone (funcall (POP_EVALUATE pop) pop tmpentity))
    
    (when (not is_edone)
      (print "")
      (print "ERROR : not is_edone !!!")
      (print "")
      (exit)
      )
    
    (setf old_fit  (ENT_FITNESS oldentity )) ; [$oldentity cget -fitness]
    (setf new_fit  (ENT_FITNESS tmpentity )) ; [$tmpentity cget -fitness]
    
    ;(setf eps 0.00001)
    (setf eps 0.00000001)

    (if (equal rank_proc "ga_rank_fitness")

      (setf is_worse (> (- old_fit new_fit) eps )) 
      ;(setf is_worse (> old_fit new_fit)) ;; !!!! точность !!!!!

      ;;      } else {
      (setf is_worse (<  (funcall rank_proc   pop tmpentity pop oldentity) 0))
      ;;        # is_worse = (pop->rank (pop, tmpentity, pop, pop->entity_iarray[i]) < 0 );
      )
    
    
    (when __is_print
      ;;        puts -nonewline [format "  n= %d  old = %f .. new = %f "  \
      ;;                           $n $old_fit $new_fit]

      (format t "  n= ~s  old= ~,6F .. new= ~,6F "   
              n old_fit new_fit)
    )
    


    (if is_worse 
      (progn
        ;;        # все только ухудшилось
    
        (ga_entity_blank  pop tmpentity)            ;# обнулить фитнес ?     
        (ga_entity_copy   pop tmpentity  oldentity) ;# $tmpentity <- $oldentity
        ;;        #
        ;;        # так оно ж (копирование) не работало ?? !!
        
        (when __is_print (format t "~%"))
        
        (pop_add_entity_  pop  oldentity) ;# "перезапишем" на старое
        
        )
      ;;      } else {
      (progn 

        ;;        # ура, улучшилось !!
        ;;        #
        ;;        if {$::is_print} { puts [format " .... OK !!"] }
        (when __is_print (format t " .... OK !!~%"))
        
        ;;        #$pop set_entity $i $tmpentity ;# перезапишем на новое
        ;;        #
        ;;        # но по си-шному алгоритму этот элемент добавлен уже в конец массива при
        ;;        # вызове функций ga_entity_clone -> ga_get_free_entity, но мы поменяли на:
        ;;        #                
        ;;        #
        ;;        # здесь попробуем это симитировать, добавив его сейчас в конец:
        ;;        #

;        (when __is_print
;          (format t "==============pop_add_entity===================== ~%")
;          (pop_print  pop)  (finish-output)
;          )

        (pop_add_entity_  pop  tmpentity)

;        (when __is_print
;          (pop_print  pop) (finish-output)   
;          (format t "======================================================= ~%")
;          )
        )
      )
    
    )
  
  ;;    # // 
  ;;    # // ~~~~~~~~~~~~~~~~~ I LOOP FINAL ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  
  (when __is_print
    (format t  "~%")
    (format t "I LOOP FINAL ......................................... ~%")
    (format t  "~%")
    
    (format t  "~%")
    ;;      puts ""
    ;;      $pop print
    ;;      puts ""
    (pop_print      pop)
    ;(finish-output)
    
    (format t  "~%")
    (format t  "Eliminate the original population members ..... ~%")
    (format t  "~%")

    ;(finish-output)
    )
  
  (pop_eliminate  pop)
  

  (when __is_print
    ;;      puts ""
    ;;      $pop print
    (format t  "~%")
    (pop_print      pop)
    (format t  "~%")
    ;;      puts ""
  )
  
  ;;    # End of generation.
  ;;    # 
  
  ;;    # Предпологается, что элементы уже отсортированы? Когда успели?
  ;;    #
  ;;    #     plog (LOG_VERBOSE,
  ;;    #          "After generation %d, population has fitness scores between %f and %f",
  ;;    #          generation,
  ;;    #          pop->entity_iarray[0]->fitness,
  ;;    #          pop->entity_iarray[pop->size-1]->fitness );
  
    )
  ;;  } ;#	/* Generation loop. */
  ;;  #   //
  ;;  #   //~~~~~~~~~~~~~~~~ GENERATION LOOP FINAL ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  
  
  ;;  #   /*
  ;;  #     * Ensure final ordering of population is correct.
  ;;  #     */
  (sort_population  pop)
  
  ;;  if {$::is_print} {
  ;;    puts ""
  ;;    $pop print
  ;;    puts ""
  ;;  }
  
  ;;  #   /*
  ;;  #     * Clean-up.
  ;;  #     */
  ;;  #   s_free (permutation);
  
  ;;   return $generation
  generation
  
))
;# //******************************************************************************
;# //****************************************************************************


