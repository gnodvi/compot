; -*-   mode: lisp ; coding: koi8   -*- ----------------------------------------

;-------------------------------------------------------------------------------

;#namespace import ::struct::*

;#-------------------------------------------------------------------------------

;# /*
;#  * Constant definitions.
;#  */

;# // к сожалению DBL_MAX и DBL_MIN используется в алгоритмах мутации, случ. чисел
;# // и т.д. поэтому просто так поменять не получистя !
;# // 

;# /* Define lower bound on fitness. */
;# #define GA_MIN_FITNESS			-DBL_MAX

;# DBL_MAX is defined in <float.h>. Its availability in <limits.h> on unix 
;# DBL_MAX = 1.79769e+308
;#

(defvar __DBL_MAX  999999999999999999)
(defvar __DBL_MIN -999999999999999999)


;(defvar __DBL_MIN 0.000000) 
;(defvar __DBL_MAX 179769313486231570814527423731704356798070567525844996598917476803157260780028538760589558632766878171540458953514382464234321326889464182768467546703537516986049910576551282076245490090389328944075868508455133942304583236903222948165808559332123348274797826204144723168738177180919299881250404026184124858368.000000) 

;#set ::GA_MIN_FITNESS 999999999999999999
;set ::GA_MIN_FITNESS [expr {- $::DBL_MAX}]
(defvar __GA_MIN_FITNESS (- __DBL_MAX))

;# /*
;#  * Define some default values.
;#  */
;# #define GA_DEFAULT_CROSSOVER_RATIO	0.9
;# #define GA_DEFAULT_MUTATION_RATIO	0.1
;# #define GA_DEFAULT_MIGRATION_RATIO	0.1

;# /*
;#  * Define chance of any given allele being mutated in one mutation
;#  * operation (only for certain mutation functions).
;#  */
;# #define GA_DEFAULT_ALLELE_MUTATION_PROB	0.02


(defvar __is_print false) 


;#-------------------------------------------------------------------------------
;(defun make_list (num val) 

;(let (
;  ;(ret "")
;  ;(ret NIL)
;  (ret (make-list num))
;  )

;  ;;  for {set i 0} {$i < $num} {incr i} {
;  (loop for i from 0 to (- num 1) do

;    ;;    lappend ret $val
;    ;; (append  ret val)
;    (setf (nth i ret) val)
;  )

;  ;;  return $ret
;  ret

;))
;#-------------------------------------------------------------------------------


;set ::GA_BOLTZMANN_FACTOR	1.38066e-23

;# #define GA_TINY_DOUBLE		(1.0e-9)

;#-------------------------------------------------------------------------------
;#  ENTITY_T    ENTITY_T   ENTITY_T   ENTITY_T   ENTITY_T   ENTITY_T   ENTITY_T
;#-------------------------------------------------------------------------------

;# (defstruct ORGANISM  
;#   genotype  ; project program 

;#   (standardized-fitness 0)
;#   (adjusted-fitness     0)
;#   (normalized-fitness   0)
;#   (hits                 0)
;# )

;record define ENTITY_T {
(defclass  ENTITY_T () (

  (chrom_some :accessor ENT_CHROM_SOME) ;# vpointer* : The chromosomes (the genotype)
  (ch_form    :accessor ENT_CH_FORM)    ;# "% 6.3f" ;#  " %02d"

  (fitness    :accessor ENT_FITNESS)    ;# double    : Fitness score

  ;;  # vpointer  data; // User data containing physical properties. (the phenotype)
))

;#-------------------------------------------------------------------------------
;#
;#-------------------------------------------------------------------------------
(defun ent_create_ (len_chromosome)

(let (
  ;;  set e [ENTITY_T  #auto]
  (e  (make-instance 'ENTITY_T))
  )
  
  ;(format t "ent_create_ : len_chromosome= ~s ~%" len_chromosome)

  ;;  # зачем здесь задавать жесткую длину ??
  ;;  # 
  ;;  $e configure -chrom_some [make_list $len_chromosome "@"]





  ;(setf (ENT_CHROM_SOME e) (make_list  len_chromosome "@"))
  
  (setf (ENT_CHROM_SOME e) (make-array  len_chromosome :initial-element '@))
  




  ;(format t "ent_create_   .............. ~s ~%" (ENT_CHROM_SOME e))

  ;;  $e configure -ch_form  "% 6.3f" ;#  " %02d"

  ;;(setf (ENT_CH_FORM    e)   "% 6.3f")
  (setf (ENT_CH_FORM    e)   "~ s")   ; ???
  
  ;;  return $e
  e

))
;#-------------------------------------------------------------------------------
(defun ent_get_chromo_gen_ (e i)

  ;;  # set e $self ;# !!!!!!!!!!!
  
(let (
  (tmp  (ENT_CHROM_SOME e))  ; [$e cget -chrom_some] ;# это список
  )
  
  ;;  return [lindex $tmp $i]

  ;(nth i tmp)
  (elt tmp i)

))
;#-------------------------------------------------------------------------------
(defun ent_CH_ (e)

  ;;  #set e $self ;# !!!!!!!!!!!
  
  ;;  return [$e cget -chrom_some]

  (ENT_CHROM_SOME e)
)
;#-------------------------------------------------------------------------------
(defun ent_get_chromosome_ (e)


;  return [$e cget -chrom_some]
  (ENT_CHROM_SOME e)

)
;#-------------------------------------------------------------------------------
;proc ent_print_ch_ {e {name "ch= "}} {
(defun ent_print_ch_ (e &optional (name "ch= "))

;(declare (ignore name))

(let* (
  ;(ch_form (ENT_CH_FORM e)) ; [$e cget -ch_form] ;# локальная переменная
  (ch      (ent_get_chromosome_  e))
  (len     (length ch))
  c
  )
  
  ;;  puts -nonewline $name
  (format t "~A  " name)
  
  ;(format t " ~S ~%" ch)

  ;(loop for c in ch do
  (loop for i from 0 to (1- len) do

    (setf c (elt ch i))

    ;;    if {[catch {puts -nonewline [format $ch_form $c]} err]} {
    ;;      puts -nonewline "$c! "
    ;;    }

    ;;(format t ch_form ch)
    ;(format t "~8,6F " c)  ; "% 6.3f" 
    (format t "~6,3F " c)  ; "% 6.3f" 
  )
  
  ;(format t "~%")
  (finish-output)

  ;;  flush stdout  ;# все данные должны быть выведены

))
;#-------------------------------------------------------------------------------
(defun fitnes_print (fit)


  (if (eql fit __GA_MIN_FITNESS)

    "GA_MIN_FITNESS"
    (format nil "~,6F" fit)
    )

)
;#-------------------------------------------------------------------------------
(defun ent_print_oneline_ (e)

(let ( 
  (fi (ENT_FITNESS e))    ; [$e cget -fitness]
  )
  
  ;;  #set e $self ;# !!!!!!!!!!!
  
  ;;  puts -nonewline "  "
  ;;  ent_print_ch_ $e
  
  ;(format t "  ")

  (ent_print_ch_  e)
 
;  (if (eql fi __GA_MIN_FITNESS)
;      ;;    puts -nonewline "   fitness= GA_MIN_FITNESS"
;      (format t "   fitness= GA_MIN_FITNESS" )
;      ;;  } else {
;      ;;    puts -nonewline "   fitness= [format "%f"  $fi]"
;      (format t "   fitness= ~s " fi)
;      )


  (format t "   fitness= ~A" (fitnes_print fi))

 
  (format t "~%")

))
;#-------------------------------------------------------------------------------
(defun  ent_set_chromosome_ (e ch)

  ;;  #set e $self ;# !!!!!!!!!!!
  
  ;;  $e configure -chrom_some $ch

  (setf (ENT_CHROM_SOME e) ch)

)
;#-------------------------------------------------------------------------------
(defun l_set_option_ (e optname i val)

  ;;  #set optname chrom_some
(let* (  
  ;;  set  tmp [$e cget -$optname] ;# это список
  (tmp  (slot-value e optname))
  ;(len  (length tmp))
  )
  

  ;;   if {$::is_print} {
  ;;  #  puts "i = $i  val = $val llength = [llength $tmp]"
  ;;  #  puts "tmp = $tmp " ;# списка нет?
  ;;  #}
  
;  (when __is_print
;    (format t "l_set_option_: optname= ~s  len= ~s  i= ~s  val= ~s  tmp= ~s  ~%" optname  len i val tmp)
;    )

  
  ;;  if {[llength $tmp] == 0} {
  ;;    lset tmp $val
  ;;  } else {
  ;;    lset tmp $i $val
  ;;    #lset options(-chromosome) $i $val ;#list index out of range ?? 
  ;;  }


;  (if (= (length tmp) 0) 
;    (setf        tmp  (list val))   ; (setf        tmp  val)
;    (setf (nth i tmp) val)
;  )

;  (if (= len 0) 
;    (setf        tmp  (list val))   
;    (if (= i len) 
;      (progn 
;        (format t "!!!!!!!!!!!  = i len ~%")
;        (format t "!!!!!!!!!!! tmp= ~s val= ~s ~%" tmp val)
;        (append  tmp val)
;        ;(append  tmp (list val))
;        (format t "!!!!!!!!!!! tmp= ~s ~%" tmp)
;        )
;      (setf (nth i tmp) val)
;      )
;    )


  ;(setf (nth i tmp) val)

  (setf (elt tmp i) val)

  ;(format t "!!!!!!!!!!! tmp= ~s i= ~s ~%" tmp i)

  ;;  $e configure -$optname $tmp
  (setf (slot-value e optname) tmp)
  
))
;#-------------------------------------------------------------------------------
(defun ent_set_chromo_gen_ (e i val) 

  
  ;(l_set_option_  e "chrom_some"  i val) ; has no slot named "chrom_some"
  ;(l_set_option_  e  'chrom_some  i val)

  (setf (elt (ENT_CHROM_SOME e) i) val)

  ;;  return
)
;#-------------------------------------------------------------------------------
;#-------------------------------------------------------------------------------
;# 
;# Systematic search parameter structure.
;# 

;# typedef struct
;# {
;#   GAscan_chromosome	scan_chromosome;	/* Allele searching function. */
;#   int			chromosome_state;	/* Permutation counter. */
;#   int			allele_state;		/* Permutation counter. */
;# } ga_search_t;

;#-------------------------------------------------------------------------------
;# 
;# Probabilistic sampling parameter structure.
;# 

;# typedef struct
;# {
;#   int			**num_states;		/* Number of states for each allele. */
;# } ga_sampling_t;

;#-------------------------------------------------------------------------------
;# 
;# Internal state values for built-in selection operators.
;# Currently used for roulette wheel and SUS selection routines.
;# 
;  # А зачем вообще здесь, если они все локально используются? ААА, там
;  # цикл и выделяется первый вызов для инициации

;record define GA_SELECTDATA_T {
(defclass  GA_SELECTDATA_T () (

  ;;  # double	mean, stddev, sum;  /* double : Fitness statistics.            */
  ;;  # double	current_expval;	    /* double : Total of expectancy values.    */
  ;;  # double	minval;		    /* double : Worst fitness value.           */

  (step    :accessor SD_STEP)    ;  /* double : Distance between each pointer. */
  (offset1 :accessor SD_OFFSET1) ;  /* double : Current pointer offsets.       */
  (offset2 :accessor SD_OFFSET2) ;

  ;;  #   int	marker;	/* int  : The roulette wheel marker.       */

  (num_to_select :accessor SD_NUM_TO_SELECT) ; int  : Number of individuals to select. */
  (current1      :accessor SD_CURRENT1)      ; int  : Currently selected individuals.  */
  (current2      :accessor SD_CURRENT2)
  (permutation   :accessor SD_PERMUTATION)   ; int* : Randomly ordered indices.        */

)) ;# ga_selectdata_t;


;set ::is_GA_SELECTDATA_T 1 ;# пока старый вариант

;#-------------------------------------------------------------------------------
(defun selectdata_create ()


(let (
  ;;  set sd [GA_SELECTDATA_T \#auto]
  (sd  (make-instance 'GA_SELECTDATA_T))
  )

  ;;  return $sd
  sd
))
;#-------------------------------------------------------------------------------
;#
;#
;#-------------------------------------------------------------------------------
(defun sort_command (a b)

(let (
  (a_fit  (ENT_FITNESS a)) ; [$a cget -fitness]
  (b_fit  (ENT_FITNESS b)) ; [$b cget -fitness]
  )

  ;(format t "sort_command:  a_fit= ~s  b_fit= ~s  ~%"  a_fit b_fit)

  ;;  if {$a_fit >  $b_fit}  {return -1} ;# т.е бОльшие будут слева в списке (вверху)
  ;;  if {$a_fit == $b_fit}  {return  0} 
  ;;  if {$a_fit <  $b_fit}  {return  1} 


  ;; Predicate should return true if and only if the first argument is strictly 
  ;; less than the second (in some appropriate sense). If the first argument is 
  ;; greater than or equal to the second (in the appropriate sense), then the 
  ;; predicate should return false. 
  
  (cond
   ((<  a_fit  b_fit)   false) ; {return  1} 
   (t                   true)

;   ((<  a_fit  b_fit)   true) ; {return  1} 
;   (t                   false)

;   ((>  a_fit  b_fit)   false ) ; {return -1}   ;# т.е бОльшие будут слева в списке (вверху)
;   ((=  a_fit  b_fit)   0) ; {return  0} 
  )

  ;1
  ;;  return 1
))
;#-------------------------------------------------------------------------------
;#  POPULATION_T    POPULATION_T    POPULATION_T    POPULATION_T    POPULATION_T   

;#-------------------------------------------------------------------------------

;# (defvar *check_already_created* t)

;# (defvar *program* :unbound)

;# ;(defvar *get_starter*    #'(lambda (program) program))
;# (defvar *genotype_print* #'(lambda (genotype) (format t "~S ~%" genotype)))

;# (defvar *size-of-population* :unbound)
;# (defvar *best-of-population* :unbound) 

;# ;; метод селекции особей в популяции; это
;# ;; или :fitness-proportionate, :tournament
;# ;; или :fitness-proportionate-with-over-selection
;# (defvar *method-of-selection*                         :unbound)

;# (defvar *tournament-size* :unbound
;#   "The group size to use when doing tournament selection.")

;# ;; хэш-таблица..
;# ;; используется, чтобы гарантировать, что все особи 0-го поколения - уникальны.
;# ;;
;# (defvar *generation-0-uniquifier-table* (make-hash-table :test #'equal))

;#-------------------------------------------------------------------------------


;record define POPULATION_T {
(defclass  POPULATION_T () (

  (ch_form :accessor POP_CH_FORM) ;#-#  " %02d"
  
  ;;  max_size	 ;#-# int   : Current maximum population size
  (stable_size	:accessor POP_STABLE_SIZE)  ;#-# int   : Requested population size
  (size         :accessor POP_SIZE)         ;#-# int   : Actual population size

  (orig_size	:accessor POP_ORIG_SIZE)    ;#-# int   : Number of parents (entities at end of previous generation)
  
  ;;  island         ;#-# int	island;	/* Population's island. */
  
  ;;  free_index     ;#-# int   : Next potentially free entity index. 
  (generation  :accessor POP_GENERATION) ;#-# int   : For ga_population_get_generation()

  ;;  fitness_dimensions ;# int : Size of fitness vector (for multiobjective optimisation
  (best        :accessor POP_BEST)         ;#-# для хранения лучшего номера

  ;;  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  ;;  # здесь основной массив хранения
  ;;  # 
  (entitysiarray   :accessor POP_ENTITYSIARRAY) ;#-# "" 

  ;;  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  (len_chromosomes :accessor POP_LEN_CHROMOSOMES) ;#-#   int : Maximum length of each chromosome. 
  
  ;;  #   vpointer	data;			/* User data. */
  
  (select_state :accessor POP_SELECT_STATE)  
  ;; ;#-#   int select_state;	/* Available to selection algorithms. */

  (selectdata :accessor POP_SELECTDATA) 
  ;;  selectdata  #   ga_selectdata_t	/* State values for built-in selection operators. */
  
  ;;  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  
  ;;  # /*
  ;;  #  * Special parameters for particular built-in GA operators.
  ;;  #  * FIXME: I don't like how this is currently implemented; need a more
  ;;  #  * elegant approach.
  ;;  #  */
  ;;  #   int	allele_min_integer, allele_max_integer;	/* Range for "integer" alleles. */
  ;;  allele_min_integer ;#-#
  ;;  allele_max_integer ;#-#

  ;;  #   double	allele_min_double, allele_max_double;	/* Range for "double" alleles. */
  (allele_min_double  :accessor POP_ALLELE_MIN_DOUBLE) ;#-#
  (allele_max_double  :accessor POP_ALLELE_MAX_DOUBLE) ;#-#
  
  ;;  # /*
  ;;  #  * Evolutionary parameters.
  ;;  #  */
  (crossover_ratio  :accessor POP_CROSSOVER_RATIO)  ;#-# double /* Chance for crossover. */
  (mutation_ratio   :accessor POP_MUTATION_RATIO)   ;#-# double /* Chance for mutation.  */
  (migration_ratio  :accessor POP_MIGRATION_RATIO)  ;#-# double /* Chance for migration. */

  (scheme  :accessor POP_SCHEME)   ;#-# ga_scheme_type scheme;    /* Evolutionary scheme.  */
  (elitism :accessor POP_ELITISM)  ;#-# ga_elitism_type  elitism; /* Elitism mode.         */
  
  ;;  # /*
  ;;  #  * Special (aka miscellaneous) parameters.
  ;;  #  */
  ;;  #   double		allele_mutation_prob;	/* Chance for individual alleles to mutate in certain mutation operators. */
  
  ;;  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  ;;  algo_params ;# сюда будут подключаться все структуры разных "классов" алгоритмов

  ;;  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  ;;  # /*
  ;;  #  * Non-evolutionary parameters.
  ;;  #  */
  ;;  #tabu_params  ;#-#   ga_tabu_t *tabu_params;	/* Parameters for tabu-search. */
  (sa_params :accessor POP_SA_PARAMS)    ;#-#   ga_sa_t	* /* Parameters for simulated annealling. */
  ;;  #   ga_climbing_t		*climbing_params;	/* Parameters for hill climbing. */
  ;;  #   ga_simplex_t		*simplex_params;	/* Parameters for simplex search. */

  ;;  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  ;;  #   ga_dc_t		*dc_params;	/* Parameters for deterministic crowding. */
  ;;  {dc_params_compare NULL} ;#-#	/* Compare two entities (either genomic or phenomic space). */
  
  ;;  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  ;;  #
  (de_params :accessor POP_DE_PARAMS)  ;# Parameters for differential evolution.
  ;;  #

  ;;  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  (gr_params :accessor POP_GR_PARAMS)   ;#-# Parameters for gradient methods;

  ;;#   gr_dimensions       ;#-#   int            /* Size of double array.                 */
  ;;#   gr_step_size        ;#-#   double         /* Step size, (or initial step size).    */
  ;;#   gr_alpha            ;#-#   double         /* Step size scale-down factor.          */
  ;;#   gr_beta             ;#-#   double         /* Step size scale-up factor.            */
  ;;#   gr_to_double        ;#-#   GAto_double    /* Convert chromosome to double array.   */
  ;;#   gr_from_double      ;#-#   GAfrom_double  /* Convert chromosome from double array. */
  ;;#   gr_gradient         ;#-#   GAgradient	    /* Return gradients array.               */

  ;;  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  ;;  #   ga_search_t	*search_params;		/* Parameters for systematic search. */
  ;;  #   ga_sampling_t	*sampling_params;	/* Parameters for probabilistic sampling. */
  
  ;;  # /*
  ;;  #  * The scoring function and the other callbacks are defined here.
  ;;  #  */

  ;;  {generation_hook NULL} ;#-#   GAgeneration_hook generation_hook;
  ;;  {iteration_hook  NULL} ;#-#   GAiteration_hook	iteration_hook;
  
  (generation_hook :accessor POP_GENERATION_HOOK :initarg NUL) 
  (iteration_hook  :accessor  POP_ITERATION_HOOK :initarg NUL) 
  
  ;;  #   GAdata_destructor		data_destructor;        /* entity.data destructor */
  ;;  #   GAdata_ref_incrementor	data_ref_incrementor;   /* entity.data reference counter incrementor */
  
  ;;  #   GAdata_destructor		population_data_destructor;
  ;;  #   GAdata_copy			population_data_copy;
  (chromosome_constructor :accessor POP_CHROMOSOME_CONSTRUCTOR) ;#-# GAchromosome_constructor :
  
  ;;  #   GAchromosome_destructor	chromosome_destructor;
  ;;  #   GAchromosome_replicate	chromosome_replicate;
  ;;  #   GAchromosome_to_bytes		chromosome_to_bytes;
  ;;  #   GAchromosome_from_bytes	chromosome_from_bytes;
  ;;  #   GAchromosome_to_string	chromosome_to_string;

  (evaluate :accessor POP_EVALUATE) ;#-# GAevaluate	
  (seed     :accessor POP_SEED) ;;  seed       ;#-# GAseed

  ;;  {adapt      NULL} ;# GAadapt		adapt;
  (adapt  :accessor  POP_ADAPT :initarg NUL) 

  (select_one :accessor POP_SELECT_ONE) ;#-# GAselect_one	select_one;
  (select_two :accessor POP_SELECT_TWO) ;#-# GAselect_two	select_two;

  (mutate     :accessor POP_MUTATE)     ;#-# GAmutate	mutate;
  (crossover  :accessor POP_CROSSOVER)  ;#-# GAcrossover crossover;
  (replace    :accessor POP_REPLACE)    ;#-# GAreplace			replace;
  (rank   :accessor POP_RANK)  ;#-# GArank	rank;

  ;;  # /*
  ;;  #  * Memory handling.
  ;;  #  */
  ;;  # #ifdef USE_CHROMO_CHUNKS
  ;;  #   MemChunk			*chromoarray_chunk;
  ;;  #   MemChunk			*chromo_chunk;
  ;;  # #endif
  
  ;;  # /*
  ;;  #  * Execution locks.
  ;;  #  */  

))
;#-------------------------------------------------------------------------------

;#-------------------------------------------------------------------------------
(defun pop_create_ (stable_size)
    
  ;;  set p [POPULATION_T #auto]

(let (
  (p (make-instance 'POPULATION_T)) ; почему ен срабатывает :initarg
  )
 

  ;(format t "~%")
  ;(format t "pop_create_: .... 01 ~%")

  ;(setf (POP_ENTITYSIARRAY p) NIL) 
  ;; (setf (POP_ENTITYSIARRAY p) (list NIL)) 
  ;(setf (POP_ENTITYSIARRAY p) (make-list 40)) 


  ;------------------------------------------------------
  ;(setf (POP_ENTITYSIARRAY p) (make-list stable_size)) 

  (setf (POP_ENTITYSIARRAY p) (make-array stable_size 
                                          :fill-pointer 0 :adjustable t)) 

  ;(format t "fill-pointer01=  ~s ~%" (fill-pointer (POP_ENTITYSIARRAY p)))

  ;------------------------------------------------------

  (setf (POP_STABLE_SIZE   p)            stable_size)

  ;(format t "pop_create_: .... 01 ~%")
  ;(format t "pop_create: entitysiarray = ~s ~%" (POP_ENTITYSIARRAY p))  
  ;(format t "pop_create: .... 03 ~%")
  ;(format t "~%")

  (setf (POP_GENERATION p) 0)

  ;;  return $p
  p
))
;#-------------------------------------------------------------------------------
(defun pop_get_size (p)

  (POP_SIZE        p)

  ;(length (POP_ENTITYSIARRAY p))

)
;#-------------------------------------------------------------------------------
;proc pop_set_entity_fitness_ {p i fi} {
    
;  set ent  [pop_get_entity_ $p  $i]

;  $ent configure -fitness $fi
;}
;#-------------------------------------------------------------------------------
(defun pop_get_entity_fitness_ (p i)
   
(let ( 
  (ent  (pop_get_entity_  p  i))
  )
  
  ;;  return [$ent cget -fitness]
  (ENT_FITNESS ent)

))
;#-------------------------------------------------------------------------------
;proc pop_add_entity_ {p entity} {

;  #set tmp [$p cget -entitysiarray]
;  #lappend tmp $entity
;  #$p configure -entitysiarray $tmp
  
;  lappend [VGET $p entitysiarray] $entity
  
;  #pop_incr_size_ $p  1
;  incr [VGET $p size] 1
  
;  return 
;}
;#-------------------------------------------------------------------------------
;(defun pop_add_entity_OLD (p entity)

;(let* ( 
;  (tmp  (POP_ENTITYSIARRAY p))
;  (i    (length tmp)) 
;  )  

;  (format t "pop_add_entity_: i = ~s ~%" i)

;  ;(format t "POP_ENTITYSIARRAY .. = ~s ~%" (POP_ENTITYSIARRAY p))
;  ;;(format t "POP_ENTITYSIARRAY .. = ~s ~%" (POP_ENTITYSIARRAY p))
;  ;; *** - There are no sequences of type ENTITY_T

;  ;;  lappend [VGET $p entitysiarray] $entity
;  ;(format t "tmp = ~s ~%" tmp)

;  ;(append (POP_ENTITYSIARRAY p) entity)
;  ;(append tmp entity)
;  ;(append tmp '(d e))
;  ;(setf (POP_ENTITYSIARRAY p) entity)

;  (format t "tmp = ~s ~%" tmp)

;  (setf tmp (append tmp NIL)) ; сначала добавим пустой список ?????

;  (format t "tmp = ~s ~%" tmp)

;  ;(setf (POP_ENTITYSIARRAY p) tmp)
;  ;(setf (POP_ENTITYSIARRAY p) (append tmp entity))
;  ;(setf (POP_ENTITYSIARRAY p) (concatenate 'ENTITY_T tmp entity))

;  ;(setf i (1- (POP_SIZE p)))
;  ;(setf i  (POP_SIZE p))

;  ;(setf (nth i (POP_ENTITYSIARRAY p)) entity) ; а теперь запишем конкретное значение

;  (setf (nth (1- i) tmp) entity) ; а теперь запишем конкретное значение

;  ;-------------------------------------------------
;  ;(format t "~%")
;  ;(format t "pop_add_entity_: .... 01 ~%")
 
;  ;(setf (POP_ENTITYSIARRAY p) NIL) 

;  ;(format t "pop_add_entity_: .... 02 ~%")

;  ;(format t "pop_add_entity_: entitysiarray = ~s ~%" (POP_ENTITYSIARRAY p))
  
;  ;(format t "pop_add_entity_: .... 03 ~%")
;  ;-------------------------------------------------

;  ;;  #pop_incr_size_ $p  1
;  ;;  incr [VGET $p size] 1

;  (setf (POP_ENTITYSIARRAY p) tmp) 

;  (incf (POP_SIZE p))
  
;  ;(format t "POP_ENTITYSIARRAY .. = ~s ~%" (POP_ENTITYSIARRAY p))

;  ;(format t "fill-pointer02=  ~s ~%" (fill-pointer (POP_ENTITYSIARRAY p)))

;  tmp ; ??
;))
;#-------------------------------------------------------------------------------
(defun pop_add_entity_ (p entity)

(let ( 
  new-index
  )  

  (incf (POP_SIZE p))
  
  (setf new-index (vector-push-extend   entity (POP_ENTITYSIARRAY p)))

  ;(format t "fill-pointer02=  ~s ~%" (fill-pointer (POP_ENTITYSIARRAY p)))

  ;(incf (POP_SIZE p))
 
  new-index
))
;#-------------------------------------------------------------------------------
;(defun pop_add_entity_i (p entity i)

;(let ( 
;  )  

;  (setf (nth i (POP_ENTITYSIARRAY p)) entity)

;  (incf (POP_SIZE p))
  
;))
;#-------------------------------------------------------------------------------
;(defun pop_set_entity_ (p i entity)

  
;  ;;  l_set_option_ $p "entitysiarray" $i $entity

;  ; попробуем попроще:
;  ;
;  (setf (nth i (POP_ENTITYSIARRAY  p))  entity)

;)
;#-------------------------------------------------------------------------------
(defun pop_get_entity_ (p i)

(let* (
  (tmp  (POP_ENTITYSIARRAY  p))
  
  ;(r    (nth i tmp))  ; [lindex $tmp $i]
  (r    (elt tmp i)) 
  )
  
  ;(format t "pop_get_entity_: r = ~s   ~%" r)

  ;;  return $r
  r
))
;#-------------------------------------------------------------------------------
(defun pop_get_entity_clone (p i)


  ;;*** - COPY-SEQ: #<ENTITY_T #x208C3526> is not a SEQUENCE
  ;;  (copy-seq (pop_get_entity_  p i))  
  ;(pop_get_entity_  p i)

 
(let* (
  (tmp  (copy-seq (POP_ENTITYSIARRAY  p))) ;; ????? а надо?
  
  (r    (elt tmp i)) 
  )
  
  r
))
;#-------------------------------------------------------------------------------
(defun pop_incr_size_  (p val)

  ;;  #set  old_size [$p.size]
  ;;  #incr old_size $val
  ;;  #$p.size = $old_size
  
  ;;  incr [VGET $p size] $val
  (incf (POP_SIZE p) val)

)
;#-------------------------------------------------------------------------------
(defun delete_at (seq i)

  ;; ?????????

  (replace  seq seq :start1 i :start2 (1+ i))

)
;#-------------------------------------------------------------------------------
(defun  pop_del_entity_  (p i)

(let* (
  (tmp   (POP_ENTITYSIARRAY p))     ; [$p cget -entitysiarray]) 
  (new_iarray    (delete_at tmp i)) ; [lreplace $tmp $i $i] ;# удалили элемент списка  
  )

  ; надо бы уменьшить fill-pointer ?????
  ; 
  ;(setf (fill-pointer new-array) i0)
  (incf (fill-pointer new_iarray) -1) ;; !!!!!!!!!!!!!!!!!!!1 


  ;;  $p configure -entitysiarray $new_iarray
  (setf (POP_ENTITYSIARRAY p) new_iarray)
  
  ;;  # нет
  ;;  #$p configure -entitysiarray  [lreplace [VGET $p entitysiarray] $i $i]

  (pop_incr_size_  p -1)
  
  ;;  return
))
;#-------------------------------------------------------------------------------
(defun pop_print_lite_ (p)

(let* (
  ;(i   0)
  
  (arr (POP_ENTITYSIARRAY p))   ; [$p cget -entitysiarray]

  ;(len  (length tmp)) ; нет, надо брать размер явно азданный в POP !! пока 
  (len  (pop_get_size p)) 
  e
  )
  
  ;(format t "pop_print_lite_: p = ~s ~%" p)
  ;(format t "pop_print_lite_: tmp = ~s ~%" tmp)

  ;;  foreach e $tmp {
  ;;(loop for e in tmp do - но у нас теперь не список !!!!!
    
  (loop for i from 0 to (1- len) do 
    
    ;;    puts -nonewline "   i= [format "%2s" $i]"
    ;(format t "   i = ~3s   " i)
    (format t "   i = ~3D   " i)
    
    ;;    #puts -nonewline "   e= |$e|"
    (setf e (elt arr i))

    (ent_print_oneline_  e)

;    (ent_print_ch_  adam)
;    (format t "~%")

    ;(incf i)
    )

))
;#-------------------------------------------------------------------------------
(defun pop_print_ (p)

  ;;  #puts "options = [array get options]"
  
  ;(format t "pop_print: p = ~s ~%" p)

  (format t "---------------------- POPULATION PRINT -------------------------------~%")
  (format t "~%")
  (format t "Generation = ~s~%" (POP_GENERATION p)) ; [$p cget -generation]
  (format t "~%")
  
  (pop_print_lite_  p) 
 
  (let ( 
    (best  (POP_BEST p))   ; [$p cget -best]
    best_fit
    )

    (format t "~%")
    (format t "STABLE_SIZE = ~s ~%"  (POP_STABLE_SIZE p))
    (format t "ORIG_SIZE   = ~s ~%"  (POP_ORIG_SIZE   p))

    (format t "SIZE        = ~s "  (pop_get_size    p))
    (format t "    (length = ~s)"  (length (POP_ENTITYSIARRAY p)))
    (format t "~%")

    
    (format t "BEST        = ~s ~%"  best)
;    (format t "LENGTH      = ~s ~%" (length (POP_ENTITYSIARRAY p)))
;    (format t "FPOINT      = ~s ~%" (fill-pointer (POP_ENTITYSIARRAY p)))

    (format t "~%")
    
    (when (/= best -1)
      ;;    #set best_fit [$p get_entity_fitness $best]
      (setf best_fit (pop_get_entity_fitness_  p  best))
      
      (format t "BEST = ~s  (fitness = ~,6F) ~%"  best best_fit)
      )
  )

  (format t " ~%")
  (format t "----------------------------------------------------------------------- ~%")

  (finish-output)
)
;#-------------------------------------------------------------------------------
;(in-package :alexandria)
;#-------------------------------------------------------------------------------

(defun copy-array_from (array i0
                        &key 
                        (element-type (array-element-type array))
                        (fill-pointer (and (array-has-fill-pointer-p array)
                                           (fill-pointer array)))
                        (adjustable (adjustable-array-p array)))

  "Returns an undisplaced copy of ARRAY, with same fill-pointer and
adjustability (if any) as the original, unless overridden by the keyword
arguments."

(let* (
       (dimensions (array-dimensions array))
       (new-array  (make-array dimensions
                               :element-type element-type
                               :adjustable   adjustable
                               :fill-pointer fill-pointer))

       (total_size  (array-total-size array))
       (j  0)
       )

  ;(dotimes (i total_size)
  (loop for i from i0 to (1- total_size) do ; ()

    ;(setf (row-major-aref new-array i) (row-major-aref array i))
    (setf (row-major-aref new-array j) (row-major-aref array i))
    (incf j)
    )
  
  ;(setf (fill-pointer new-array) 4)

  (setf (fill-pointer new-array) i0)

  new-array

))
;#-------------------------------------------------------------------------------
; удалить старую популяцию. т.е. первые orig_size элементов ???
;#-------------------------------------------------------------------------------
(defun pop_eliminate_ (p)
    
  ;;  # DE
  
(let (
  (osize (POP_ORIG_SIZE     p)) ; [$p cget -orig_size]  
  (old   (POP_ENTITYSIARRAY p)) ; [$p cget -entitysiarray]
  )

  ;;  $p configure -entitysiarray [lrange $tmp $osize end] ; но это же наоборот, 
                                                 ; последние ? ну да, их и берем

  ;(setf (POP_ENTITYSIARRAY p) (lrange tmp osize 'end))
  ;(setf (POP_ENTITYSIARRAY p) (last tmp osize))

  ;(format t "fill-pointer03=  ~s ~%" (fill-pointer (POP_ENTITYSIARRAY p)))

;  (format t "================================================================= ~%")
;  (format t "pop_eliminate_: array-dimensions = ~s   pop_get_size =  ~s ~%" 
;          (array-dimensions (POP_ENTITYSIARRAY p)) ; 20  ?
;          (pop_get_size     p))

;  (pop_print p)
  


  ;(setf (POP_ENTITYSIARRAY p) (subseq old osize)) 

  (setf (POP_ENTITYSIARRAY p) (copy-array_from old osize)) 

  ;(setf (POP_ENTITYSIARRAY p) (copy-array_from old 0)) 


  ;;  $p configure -size  [expr {[$p cget -size] - $osize}]
  ;;  $p configure -orig_size 0

  ;(setf (POP_SIZE p)      (- (POP_SIZE p) osize)) ;??
  (setf (POP_SIZE p)      (- (pop_get_size p) osize)) ;??

  (setf (POP_ORIG_SIZE p) 0)                      ;??

 ; (format t "pop_eliminate_: array-dimensions = ~s   pop_get_size =  ~s ~%" 
;          (array-dimensions (POP_ENTITYSIARRAY p)) ; 20  ?
;          (pop_get_size     p))

  ;(format t "fill-pointer04=  ~s ~%" (fill-pointer (POP_ENTITYSIARRAY p)))


;  (pop_print p)
  
;  (format t "================================================================= ~%")

))
;#-------------------------------------------------------------------------------
(defun pop_sort_ (p)

  (when (= 0 (POP_SIZE p)) ; {[$p cget -size] == 0} {
      (return-from  pop_sort_) ;# если в популяции ничего еще нет !!
  )
  
  (let (
  ;(tmp (copy-tree (POP_ENTITYSIARRAY p)))
  ;(tmp (copy-seq (POP_ENTITYSIARRAY p)))
  )

  ;;  # в случае, если специально определена функция сравнения (а не просто по фитнесу)
  ;;  # т.е. if (pop->rank != ga_rank_fitness) то надл использовать эту функцию!
  ;;  #
  ;;  #set rank_proc [$self cget -rank]
  ;;  #if {$rank_proc != "ga_rank_fitness"} {
  ;;  #  die "NOT ..... ga_rank_fitness"
  ;;  #}
  

  ;;  $p configure -entitysiarray [lsort -command "sort_command" [$p cget -entitysiarray]]
  ;(setf (POP_ENTITYSIARRAY p) (stable-sort  tmp 'sort_command))  
  ;(format t "pop_sort_:  fill-pointer1= " (fill-pointer (POP_ENTITYSIARRAY p)))



  ;(stable-sort (POP_ENTITYSIARRAY p)  'sort_command) 
  ;(sort (POP_ENTITYSIARRAY p)  'sort_command)
  (A_SORT:qsort_AF  (POP_ENTITYSIARRAY p)  :sort_proc 'sort_command) 
 


  ;(format t "pop_sort_:  fill-pointer2= " (fill-pointer (POP_ENTITYSIARRAY p)))
  ;(format t 
  ;;  $p configure -best 0 ;# после сортировки это должно быть так
  
  (setf (POP_BEST p) 0)

))
;#-------------------------------------------------------------------------------
(defun pop_print (pop)


  (pop_print_  pop) 

)
;#-------------------------------------------------------------------------------



;# /*
;#  * A private prototype.
;#  */
;# boolean gaul_population_fill (population *pop, int num);

;# /**********************************************************************
;#   ga_similarity.h
;#  **********************************************************************/

;# //******************************************************************************




;# /**********************************************************************
;#   ga_core.c


;#   Synopsis:     Routines for handling populations and performing GA
;# 		operations.
  
;# 		Also contains a number of helper functions providing
;# 		alternative optimisation schemes for comparison and
;# 		analysis purposes.

;# 		BEWARE: MANY FUNCTIONS ARE NOT THREAD-SAFE!

;# 		Internally, and in the public C interface, pointers
;# 		are used to identify the population and entity
;# 		structures.  However, in the scripting interface these
;# 		pointers are unusable, so identifing integers are
;# 		used instead.

;#   Vague usage details:	Set-up with ga_genesis_XXX(), where XXX is a built-in chromosome type().
;# 			Perform calculations with ga_evolution().
;# 			Grab data for post-analysis with ga_transcend().
;# 			Evolution will continue if ga_evolution() is
;# 			called again without calling ga_genesis_XXX() again.

;#   To do:	Replace the send_mask int array with a bit vector.
;# 		All functions here should be based on entity/population _pointers_ while 
;#                 the functions in ga_intrinsics should be based on _handles_.
;# 		More "if ( !pop ) die("Null pointer to population structure passed.");" 
;#                 checks are needed.
;# 		Population/entity iterator functions.
;# 		ga_get_struct_whatever() should be renamed to ga_struct_get_whatever().

;#  **********************************************************************/



;# //------------------------------------------------------------------------------
(defun  print_entit  (entity name)

  ;;  puts -nonewline "  "
  (format t "  ")
  
  ;;  #$entity  print_ch $name
  (ent_print_ch_  entity name)
  
  ;;  puts ""
  (format t "~%")

  (finish-output)
)
;#-------------------------------------------------------------------------------

;(defclass POPULATION_T  () (
(defclass person  () (

  (size         :accessor person-size)       
  ;(age  :accessor person-age)       

))
;#


;#-------------------------------------------------------------------------------
;#   Population handling functions.
;#-------------------------------------------------------------------------------
;#   synopsis:	Allocates and initialises a new population structure,
;# 		and assigns a new population id to it.
;#   parameters:	const int stable_size		Num. individuals carried into next generation.
;# 		const int num_chromosome	Num. of chromosomes.
;# 		const int len_chromosome	Size of chromosomes (may be ignored).
;#   return:	population *	new population structure.

;# population *
;# ga_population_new (const int stable_size, /* const int num_chromosome, */
;#                    const int len_chromosome)
;#-------------------------------------------------------------------------------
(defun ga_population_new (stable_size len_chromosome)

  ;;  #   puts ""
  ;;  #   puts "ga_population_new ..."
  ;;  #   puts ""
  
  ;;  #   population	*newpop=NULL;	/* New population structure. */

(let (

  (newpop "")
  ;(newpop  (make-instance 'person))
  )
  
  ;;  #   unsigned int	pop_id;		/* Handle for new population structure. */
  ;;  #   int		i;		/* Loop over (unassigned) entities. */
  
  ;;  #   if ( !(newpop = s_malloc(sizeof(population))) )
  ;;  #     die("Unable to allocate memory");
  
  ;;  #set newpop [POPULATION_T %AUTO%]
  (setf newpop (pop_create_ stable_size))

  ;(setf newpop (make-instance 'person))

  ;(setq nepop (make-instance 'person :size 100))
  ;; Illegal keyword/value pair :SIZE, 100 in argument list
  ;; The allowed keywords are NIL
  ;(setq nepop (make-instance 'person :age 100))
  ;(setq nepop (make-instance 'person :age 100))



  ;;  $newpop configure -ch_form  "% 6.3f" ;#  " %02d"
  (setf (POP_CH_FORM     newpop)  "% 6.3f") 
  
  (setf (POP_SIZE        newpop)  0) 

  ;(setf (slot-value newpop 'size) 0)
  ;(setf (slot-value newpop 'size) 10)
  ;(format t "age    = ~s ~% .. 1 ~%"   (slot-value newpop 'size))
  ;(setf (person-size newpop) 100)
  ;(format t "age    = ~s ~% .. 1 ~%"   (slot-value newpop 'size))
  ;(format t ".. 2 ~%")

  ;(setf (POP_STABLE_SIZE newpop)  stable_size)
  
  ;;  #   newpop->max_size = (1+stable_size)*4;  /* +1 prevents problems if stable_size is 0. */
  
  ;;  $newpop configure -orig_size 0
  (setf (POP_ORIG_SIZE newpop) 0)
  
  ;;  #   //newpop->num_chromosomes = /* num_chromosome */ 1;
  ;;  $newpop configure -len_chromosomes  $len_chromosome
  (setf (POP_LEN_CHROMOSOMES newpop) len_chromosome)
  
  ;;  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~`
  ;;  $newpop.selectdata = [selectdata_create]
  (setf (POP_SELECTDATA newpop) (selectdata_create))
  
  ;;  #[$newpop.selectdata].offset1 = 555
  ;;  #puts "offset1 = [[$newpop.selectdata].offset1]"
  
  
  ;;  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~`
  
  ;;  #   newpop->data = NULL;
  ;;  #   newpop->free_index = newpop->max_size-1;
  ;;  $newpop configure -island  -1
  ;;  #   newpop->generation = 0;
  ;;  $newpop configure -generation 0
  
  ;;  #   newpop->fitness_dimensions = 0;
  ;;  $newpop configure -fitness_dimensions 0
  
  ;;  $newpop configure -best  -1 ;# для хранения лучшего номера (пока нет)
  (setf (POP_BEST newpop) -1)
  
  ;;  #   newpop->crossover_ratio = GA_DEFAULT_CROSSOVER_RATIO;
  ;;  #   newpop->mutation_ratio = GA_DEFAULT_MUTATION_RATIO;
  ;;  #   newpop->migration_ratio = GA_DEFAULT_MIGRATION_RATIO;
  ;;  #   newpop->scheme = GA_SCHEME_DARWIN;
  ;;  $newpop configure -scheme GA_SCHEME_DARWIN;
  
  ;;  #   newpop->elitism = GA_ELITISM_PARENTS_SURVIVE;
  
  ;;  #   newpop->allele_mutation_prob = GA_DEFAULT_ALLELE_MUTATION_PROB;
  
  ;;  #   newpop->allele_min_integer = 0;
  ;;  #   newpop->allele_max_integer = RAND_MAX-1;
  ;;  $newpop configure -allele_min_integer 0
  ;;  #$newpop configure -allele_max_integer [expr $RAND_MAX - 1]
  ;;  $newpop configure -allele_max_integer [expr {$::RANDOM_RAND_MAX - 1}] ;# попробуем так
  
  ;;  # 
  ;;  #/* this may seem like an odd choice, but it is to maintain compatiability with older versions. */
  
  ;;  $newpop configure -allele_min_double $::DBL_MIN
  ;;  $newpop configure -allele_max_double $::DBL_MAX
  
  (setf (POP_ALLELE_MIN_DOUBLE newpop) __DBL_MIN)
  (setf (POP_ALLELE_MAX_DOUBLE newpop) __DBL_MAX)
  
  
  ;;  $newpop configure -rank "ga_rank_fitness"
  (setf (POP_RANK newpop) "ga_rank_fitness")
  
  
;  (format t "ga_population_new: array-dimensions = ~s  array-dimension = ~s    pop_get_size =  ~s ~%" 
;          (array-dimensions (POP_ENTITYSIARRAY newpop)) ; 20  ?
;          (array-dimension  (POP_ENTITYSIARRAY newpop) 0) 
;          (pop_get_size     newpop))


  ;;  return $newpop
  newpop
  
))
;#-------------------------------------------------------------------------------
;#   synopsis:	Allocates and initialises a new population structure,
;# 		and fills it with an exact copy of the data from an
;# 		existing population, with the exception that entity
;# 		data is not copied.  The population's user data
;# 		field is referenced.
;#   parameters:	population *	original population structure.
;#   return:	population *	new population structure.
;#-------------------------------------------------------------------------------
;# population *
;# ga_population_clone_empty (population *pop)
;#-------------------------------------------------------------------------------
;proc ga_population_clone_empty {pop} \
;{

;  set newpop [pop_create_]
  
;  #   /*
;  #     * Clone parameters.
;  #     */
;  $newpop configure -size  0
;  $newpop configure -stable_size [$pop cget -stable_size]
;  $newpop configure -max_size    [$pop cget -max_size]
;  $newpop configure -orig_size   0
;  #   //newpop->num_chromosomes = 1/* pop->num_chromosomes */;
;  $newpop configure -len_chromosomes [$pop cget -len_chromosomes]

;  #//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~`
;  $newpop configure -ch_form [$pop cget -ch_form]
;  #//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~`

;  #   newpop->free_index = pop->max_size - 1;
;  $newpop configure -island    -1
;  $newpop configure -generation 0
  
;  $newpop configure -fitness_dimensions 0
  
;  $newpop configure -crossover_ratio [$pop cget -crossover_ratio]
;  $newpop configure -mutation_ratio  [$pop cget -mutation_ratio]
;  $newpop configure -migration_ratio [$pop cget -migration_ratio]
  
;  $newpop configure -scheme [$pop cget -scheme]
  
;  $newpop configure -elitism [$pop cget -elitism]
  
;  #   /*
;  #     * Clone the callback functions.
;  #     */

;  $newpop configure -generation_hook [$pop cget -generation_hook]
;  #$newpop configure -iteration_hook  [$pop cget -iteration_hook ]
  
;  $newpop configure -evaluate   [$pop cget -evaluate]
;  $newpop configure -seed       [$pop cget -seed ]
;  $newpop configure -adapt      [$pop cget -adapt]
;  $newpop configure -select_one [$pop cget -select_one]
;  $newpop configure -select_two [$pop cget -select_two]

;  $newpop configure -mutate     [$pop cget -mutate    ]
;  $newpop configure -crossover  [$pop cget -crossover ]
;  $newpop configure -replace    [$pop cget -replace   ]
;  $newpop configure -rank       [$pop cget -rank      ]
  
;  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~  
;  $newpop.selectdata = [$pop.selectdata]

;  #$newpop configure -tabu_params  [$pop cget -tabu_params]
;  $newpop configure -algo_params  [$pop cget -algo_params]

;  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~  

;  $newpop configure -de_params  [$pop cget -de_params]
  
;  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~  

;  $newpop configure -gr_params  [$pop cget -gr_params]
  
;  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~  

;  return $newpop
;}
;#-------------------------------------------------------------------------------
;#   synopsis:	Allocates and initialises a new population structure,
;# 		and fills it with an exact copy of the data from an
;# 		existing population, including the individual
;# 		entity data.  The population's user data
;# 		field is referenced.
;# 		Entity id's between the populations will _NOT_
;# 		correspond.
;#   parameters:	population *	original population structure.
;#   return:	population *	new population structure.
;#-------------------------------------------------------------------------------
;# population *
;# ga_population_clone (population *pop)
;#-------------------------------------------------------------------------------
;proc ga_population_clone {pop}  \
;{

;  #   int	  i;		/* Loop variable.             */
;  #   population *newpop=NULL;	/* New population structure.  */
;  #   entity	 *newentity;	/* Used for cloning entities. */
  
;  #   /* Note that checks are performed in the ga_population_clone_empty() function. */
  
;  #   /*
;  #     * Clone the population data.
;  #     */
;  set newpop [ga_population_clone_empty $pop]
  
;  #   /*
;  #     * Clone each of the constituent entities.
;  #     */

;  #   /* #pragma omp parallel for \ */
;  #   /*    shared(pop,newpop) private(i,newentity) \ */
;  #   /*    schedule(static) */

;  for {set i 0} {$i < [$pop cget -size]} {incr i} \
;  {
;    set newentity [ga_get_free_entity  $newpop]
;    #ga_entity_copy (newpop, newentity, pop->entity_iarray[i]);

;    #ga_entity_copy $newpop $newentity [$pop get_entity $i]
;    ga_entity_copy $newpop $newentity [pop_get_entity_ $pop  $i]
;  }

;  return $newpop
;}
;#-------------------------------------------------------------------------------
;#-------------------------------------------------------------------------------
;# /**********************************************************************
;#   synopsis:	Fills a population structure with genes.  Defined in
;# 		a user-specified function.
;#   parameters:	population *	The entity's population.
;# 		entity *	The entity.
;#   return:	boolean success.
;#  **********************************************************************/
;#-------------------------------------------------------------------------------
;# boolean 
;# ga_entity_seed (population *pop, entity *adam)
;#-------------------------------------------------------------------------------
;proc ga_entity_seed {pop adam} \
;{

;  #   if ( !pop ) die("Null pointer to population structure passed.");
;  #   if ( !pop->seed ) die("Population seeding function is not defined.");
  
;  #   return pop->seed(pop, adam);

;  return [[$pop cget -seed]  $pop $adam]
;}
;#-------------------------------------------------------------------------------
;#   synopsis:	Fills all entities in a population structure with
;# 		genes from a user-specified function.
;#   parameters:	population *pop
;# 		int num			Number of entities to seed.
;#   return:	boolean success.
;#
;# boolean 
;# gaul_population_fill (population *pop, int num)
;#-------------------------------------------------------------------------------
(defun gaul_population_fill (pop num)

(let (
  (proc_seed (POP_SEED pop))  ; [$pop cget -seed]
   adam
  )

  (loop 
    for i from 0 to (- num 1) do

    ;;    #     /*printf("DEBUG: ga_population_seed() parallel for %d on %d/%d.\n", i, 
    ;;    #     omp_get_thread_num(), omp_get_num_threads());*/
    
    ;;    # set adam [ga_get_free_entity $pop]  ;# New population member
    ;;    #
    ;;    # напрямую эту функцию вызовем (а добавим в массив чуть позже) 
    ;;    # а можно ли сделать все правильно, т.е. как было ?
    ;;    #
    
    (setf adam (ga_entity_setup  pop)) ;# создает и chromosome_constructor?
    
    ;;    # заполняем структуру одного элемента-организма
    ;;    #  
    (funcall proc_seed  pop adam)
    
    (when __is_print 

      (format t "   i = ~3D   " i)
      ;(format t "fit = ~A" (fitnes_print   (ENT_FITNESS adam)))

      (ent_print_ch_  adam)

      (format t "~%")
      )
    
    ;-----------------------------------------
    ;;    # вообще-то теперь надо добавить в популяцию: 
    ;;    # 

    (pop_add_entity_  pop  adam)

    ;----------------------------------------- 
    )
  
  ;(format t "POP_ENTITYSIARRAY = ~s ~%" (POP_ENTITYSIARRAY pop))

  (when __is_print
    (format t "~%")
  )
  
  true ; return

))
;#-------------------------------------------------------------------------------
;#   synopsis:	Fills all entities in a population structure with
;# 		genes from a user-specified function.
;#   parameters:	population
;#   return:	boolean success.
;#
;# т.е. делает фил для всего размера популяции

;# boolean 
;# ga_population_seed (population *pop)
;#-------------------------------------------------------------------------------
(defun ga_population_seed (pop)

  
  (when __is_print
    (format t "ga_population_seed  .........  ~%~%")
  )
  
  ;;  # plog(LOG_DEBUG, "Population seeding by user-defined genesis.");  
  ;;  return [gaul_population_fill  $pop [$pop cget -stable_size]]

  (gaul_population_fill  pop (POP_STABLE_SIZE pop) )

)
;#-------------------------------------------------------------------------------
;# /**********************************************************************
;#   synopsis:	Score and sort entire population.  This is probably
;# 		a good idea after changing the fitness function!
;# 		Note: remember to define the callback functions first.
;#  **********************************************************************/
;#-------------------------------------------------------------------------------
;# boolean 
;# ga_population_score_and_sort (population *pop)
;#-------------------------------------------------------------------------------
;proc ga_population_score_and_sort {pop} \
;{

;  #   int  i;	    /* Loop variable over all entities. */
  
;  #   /*
;  #     * Score and sort all of the population members.
;  #     *
;  #     * Note that this will (potentially) use a huge amount of memory more
;  #     * than the original population data if the userdata hasn't been maintained.
;  #     * Each chromosome is decoded separately, whereas originally many
;  #     * degenerate chromosomes would share their userdata elements.
;  #     */
;  #   /* #pragma omp parallel for \ */
;  #   /*    shared(pop) private(i) \ */
;  #   /*    schedule(static) */
  
;  for {set i 0} {$i < [$pop cget -size]} {incr i} \
;  {
;    # #if GA_DEBUG>2
;    #     origfitness = pop->entity_iarray[i]->fitness;
;    # #endif


;    set e [pop_get_entity_ $pop  $i]

;    # ~~~~~~~~~~~~~~~~~~~~~~~~~~
;    #if {$::is_print} {
;    #  puts ""
;    #  ent_print_ch_ $e 
;    #  puts ""
;    #  puts ""
;    #}
;    # ~~~~~~~~~~~~~~~~~~~~~~~~~~

;    [$pop cget -evaluate]  $pop $e
;    #  pop->evaluate (pop, pop->entity_iarray[i]);

    
;  }
  

;  # а теперь сортируем !!! !!! !!! !!!
;  # 

;  sort_population  $pop

  
;  return true
;}
;#-------------------------------------------------------------------------------
;#-------------------------------------------------------------------------------
;#   synopsis:	Gets an entity's rank (subscript into entity_iarray of
;# 		the population).  This is not necessarily the fitness
;# 		rank unless the population has been sorted.
;#-------------------------------------------------------------------------------
;proc ga_get_entity_rank {pop e} \
;{

;  set rank 0  ;# /* The rank. */

;  while {$rank < [$pop cget -size]} \
;  {
;    set e_tmp [pop_get_entity_ $pop $rank]

;    if {$e_tmp == $e} {return $rank}

;    incr rank
;  }

;  if {$::is_print} {
;    puts stderr ""
;    puts stderr "ga_get_entity_rank = -1,  e_tmp = |$e_tmp|   e = |$e|"
;  }

;  return -1
;}
;#-------------------------------------------------------------------------------
;#-------------------------------------------------------------------------------
;#   synopsis:	Gets a pointer to an entity from it's internal rank.
;# 		(subscript into the entity_iarray buffer).
;# 		Note that this only relates to fitness ranking if
;# 		the population has been properly sorted.
;#
;# entity *
;# ga_get_entity_from_rank (population *pop, const unsigned int rank)
;#-------------------------------------------------------------------------------
;proc ga_get_entity_from_rank {pop rank} {

;  #   if ( !pop ) die ("Null pointer to population structure passed.");

;  #   if ( rank > (unsigned) pop->size ) return NULL;
;  #
;  # если  rank=0 и  pop->size=0 , то чего возвращать?
  
;  #   return pop->entity_iarray[rank];

;  #return [$pop get_entity $rank]
;  return [pop_get_entity_ $pop  $rank]
;}
;#-------------------------------------------------------------------------------
;#   synopsis:	Prepares a pre-allocated entity structure for use.
;# 		Chromosomes are allocated, but will contain garbage.
;#
;# static boolean 
;# ga_entity_setup (population *pop, entity *joe)
;#
;#-------------------------------------------------------------------------------
(defun  ga_entity_setup (pop)

(let (

  ;;  #   if (!joe)
  ;;  #     die("Null pointer to entity structure passed.");
  ;;  #   if (!pop->chromosome_constructor)
  ;;  #     die("Chromosome constructor not defined.");

  ;;  #puts "len_chromosomes = [$pop cget -len_chromosomes]"

  ;;  # здесь будем создавать сруктуру:
  ;;  # 

  (joe (ent_create_ (POP_LEN_CHROMOSOMES pop) )) ; [$pop cget -len_chromosomes]]

  )

  ;(format t "ga_entity_setup .............. ~s ~%" (ENT_CHROM_SOME joe))

  ;;  $joe configure -ch_form [$pop cget -ch_form]
  (setf (ENT_CH_FORM joe) (POP_CH_FORM pop))

  ;;  #  // Allocate chromosome structures. 
  ;;  #  joe->chromosome = NULL;
  ;;  #  pop->chromosome_constructor(pop, joe);

  ;;  # вызываем "конструктор" для заполнения
  ;;  # 
  ;;  #set ch_constructor [$pop cget -chromosome_constructor]
  ;;  #$ch_constructor $pop $joe ;# -> ga_chromo.tl -> ga_chromosome_double_allocate
  ;;  #
  ;;  # ничего особо не делает?

  ;;  #  // Physical characteristics currently undefined. 
  ;;  #  joe->data=NULL;

  ;;  #  No fitness evaluated yet
  ;;  #

  ;;  $joe configure -fitness $::GA_MIN_FITNESS
  (setf (ENT_FITNESS joe) __GA_MIN_FITNESS)

  ;;  # остальное (мультихромосом) - не надо пока!
  ;;  #
  
  ;;  return $joe
  joe

))
;#-------------------------------------------------------------------------------
;# /**********************************************************************
;#   synopsis:	Marks an entity structure as unused.
;# 		Deallocation is expensive.  It is better to re-use this
;# 		memory.  So, that is what we do.
;# 		Any contents of entities data field are freed.
;# 		If rank is known, this is much quicker than the plain
;# 		ga_entity_dereference() function.
;# 		Note, no error checking in the interests of speed.
;#  **********************************************************************/
;# boolean 
;# ga_entity_dereference_by_rank (population *pop, int rank)

;#-------------------------------------------------------------------------------
(defun ga_entity_dereference_by_rank (pop rank)
 
  
  ;;  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  ;;  #
  ;;  # да нам надо просто ..
  
  ;;  #$pop del_entity  $rank

  (pop_del_entity_  pop rank)

  
  true
)
;#-------------------------------------------------------------------------------
;#   synopsis:	Marks an entity structure as unused.
;# 		Deallocation is expensive.  It is better to re-use this
;# 		memory.  So, that is what we do.
;# 		Any contents of entities data field are freed.
;# 		If rank is known, the above
;# 		ga_entity_dereference_by_rank() or
;# 		ga_entity_dereference_by_id() functions are much
;# 		faster.
;#-------------------------------------------------------------------------------
;# boolean 
;# ga_entity_dereference (population *pop, entity *dying)
;#-------------------------------------------------------------------------------
;proc ga_entity_dereference {pop dying} \
;{

;  set id [ga_get_entity_rank  $pop $dying]

;  return [ga_entity_dereference_by_rank  $pop $id]

;  #return ga_entity_dereference_by_rank (pop, ga_get_entity_rank (pop, dying));
;}
;#-------------------------------------------------------------------------------
;#-------------------------------------------------------------------------------
;#   synopsis:	Clears the entity's data.
;# 		Equivalent to an optimised ga_entity_dereference()
;# 		followed by ga_get_free_entity().  It is much more
;# 		preferable to use this fuction!
;# 		Chromosomes are gaurenteed to be intact, but may be
;# 		overwritten by user.
;#
;# void 
;# ga_entity_blank (population *p, entity *this_entity)

;#-------------------------------------------------------------------------------
(defun ga_entity_blank (p this_entity)

(declare (ignore p))

  ;;  #   int	i;	/* Loop variable over the fitness vector. */
  
  ;;  #   if (this_entity->data)
  ;;  #   {
  ;;  #     destruct_list(p, this_entity->data);
  ;;  #     this_entity->data=NULL;
  ;;  #   }
  
  ;;  #   this_entity->fitness=GA_MIN_FITNESS;

  ;;  $this_entity  configure -fitness "GA_MIN_FITNESS"
  (setf (ENT_FITNESS this_entity)  __GA_MIN_FITNESS)     ; ??????
  
  ;;  #   /* Clear multiobjective fitness vector. */
  ;;  #   for (i=0; i<p->fitness_dimensions; i++)
  ;;  #     this_entity->fitvector[i] = GA_MIN_FITNESS;
  
  ;;  #   /*  printf("ENTITY %d CLEARED.\n", ga_get_entity_id(p, this_entity));*/
  
  ;;  return
)
;#-------------------------------------------------------------------------------
;#   synopsis:	Returns pointer to an unused entity structure from the
;# 		population's entity pool.  Increments population size
;# 		too.
;#-------------------------------------------------------------------------------
;# entity *
;# ga_get_free_entity (population *pop)
;#-------------------------------------------------------------------------------
(defun ga_get_free_entity (pop)

(let* (
  ;;  # здесь надо бы наоборот, сначала создать структуру, а потом записать в массив:
  ;;  # 
  (fresh     (ga_entity_setup  pop))
  (new-index (pop_add_entity_  pop fresh))
  )

  ;;  #$pop set_entity_array [$pop cget -free_index] $fresh
  ;;  # лучше добавить структуру попростому ? :
  ;;  #
  ;;  #$pop add_entity $fresh

  ;(pop_add_entity_  pop fresh)

  (when __is_print
    (finish-output)
    (format t  "ga_get_free_entity: new-index= ~d  fresh= ~s ~%" 
            new-index fresh) 
    ;(format t  "~%") 
    (finish-output)
    )

  fresh ;;  return $fresh  ???
))
;#-------------------------------------------------------------------------------
;#   synopsis:	Copy one chromosome between entities.
;# 		If these entities are in differing populations, no
;# 		problems will occur provided that the chromosome
;# 		datatypes match up.
;#
;# boolean 
;# ga_copy_chromosome (population *pop, entity *dest, entity *src,
;#                     const int chromosome)
;#-------------------------------------------------------------------------------
;proc ga_copy_chromosome {pop  dest src chromosome} {

;  # вообще-то она NULL
;  #
;  #   pop->chromosome_replicate (pop, src,  dest, chromosome);
  

;  return true
;}
;#-------------------------------------------------------------------------------
;#   synopsis:	Copy genetic data between entity structures.
;# 		If these entities are in differing populations, no
;# 		problems will occur provided that the chromosome
;# 		properties are identical.
;#
;# boolean 
;# ga_entity_copy_all_chromosomes (population *pop, entity *dest, entity *src)
;#-------------------------------------------------------------------------------
;proc ga_entity_copy_all_chromosomes {pop dest src} {


;  set i 0

;  #   //for (i=0; i<pop->num_chromosomes; i++)
;  #   //{

;  #   ga_copy_data(pop, dest, src, i);		/* Phenome. */

;  ga_copy_chromosome $pop  $dest $src $i ;#	/* Genome. */

;  #   //}
  
;  return true
;}
;#-------------------------------------------------------------------------------
;#-------------------------------------------------------------------------------
;#   synopsis:	Copy entire entity structure.  This is safe
;# 		for copying between populations... provided that they
;# 		are compatible.
;# 
;# boolean 
;# ga_entity_copy (population *pop, entity *dest, entity *src)
;#-------------------------------------------------------------------------------
(defun ga_entity_copy (pop dest src)

  (declare (ignore pop))


  ;;  #puts "ga_entity_copy !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
  
  ;;  #ga_entity_copy_all_chromosomes $pop $dest $src ;# не работало ?
  
  ;;  # у нас тут все просто:
  ;;  # 
  ;(ent_set_chromosome_  dest (ent_get_chromosome_ src))  ;; ??????? TODO не клонируем??
  ;
  (ent_set_chromosome_  dest (copy-seq (ent_get_chromosome_ src))) 
  
  ;;  #   dest->fitness = src->fitness; # а тогда зачем, если раньше все скопировали?
  ;;  $dest configure -fitness [$src cget -fitness]

  (setf (ENT_FITNESS dest) (ENT_FITNESS src))
  
  ;;  return true;
  true
)
;#-------------------------------------------------------------------------------
(defun ga_entity_clone_ (dolly parent)

  ;;  # ga_entity_copy_all_chromosomes(pop, dolly, parent);
  
  ;;  # в нашем TCL можно все сделать проще (и хромосома у нас одна)
  ;;  # 

  ;; здесь, наверное, идет ен копированеи списка, а "ссылка" !!!!
  ;;
  ;; 

  ;(ent_set_chromosome_  dolly  (ent_get_chromosome_ parent)) 
  ;(ent_set_chromosome_  dolly  (copy-tree (ent_get_chromosome_ parent)))
  (ent_set_chromosome_  dolly  (copy-seq (ent_get_chromosome_ parent)))
  


  ;;  $dolly configure -fitness [$parent cget -fitness]
  (setf (ENT_FITNESS dolly) (ENT_FITNESS parent))

  ;;  return $dolly
  dolly
)
;#-------------------------------------------------------------------------------
;#   synopsis:	Clone an entity structure.
;# 		Safe for cloning into a different population, provided
;# 		that the populations are compatible.
;#   parameters:	population	*pop	Population.
;# 		entity	*parent		The original entity.
;#   return:	entity	*dolly		The new entity.

;# entity *
;# ga_entity_clone (population *pop, entity *parent)

;#-------------------------------------------------------------------------------
;proc ga_entity_clone {pop parent} {


;  set dolly [ga_get_free_entity $pop]

;  set dolly [ga_entity_clone_ $dolly $parent]

;  return $dolly
;}
;#-------------------------------------------------------------------------------
(defun ga_entity_clone_without_add (pop parent)

(let (
  (dolly  (ga_entity_setup  pop)) ;# сразу эту вызовем 
  )

  (setf dolly (ga_entity_clone_  dolly parent))

  ;;  return $dolly

  dolly
))
;# /**********************************************************************
;#   GA functions.
;#  **********************************************************************/

;#-------------------------------------------------------------------------------
;#   synopsis:	Sets the GA parameters for a population.

;# void 
;# ga_population_set_parameters (population	   *pop,
;#                               const ga_scheme_type  scheme,
;#                               const ga_elitism_type elitism,
;#                               const double	    crossover,
;#                               const double	    mutation,
;#                               const double	    migration)

;#-------------------------------------------------------------------------------
(defun ga_population_set_parameters (pop  scheme elitism 
                                          crossover 
                                          mutation  
                                          migration)
  
  (when __is_print
    ;;    #puts ""
    (format t "ga_population_set_parameters ... ~%")
    (format t "~%")
    )
  
  ;;  #   if ( !pop ) die("Null pointer to population structure passed.");
  
  ;;  #   plog( LOG_VERBOSE,
  ;;  #        "Population's parameters: scheme = %d elitism = %d crossover = %f mutation = %f migration = %f",
  ;;  #        (int) scheme, (int) elitism,
  ;;  #        crossover, mutation, migration );
  

  (setf (POP_SCHEME  pop) scheme   ) ;  $pop  configure -scheme           $scheme
  (setf (POP_ELITISM pop) elitism  ) ;  $pop  configure -elitism          $elitism

  (setf (POP_CROSSOVER_RATIO pop) crossover) ;  $pop  configure -crossover_ratio  $crossover
  (setf (POP_MUTATION_RATIO  pop) mutation ) ;  $pop  configure -mutation_ratio   $mutation
  (setf (POP_MIGRATION_RATIO pop) migration) ;  $pop  configure -migration_ratio  $migration

  ;;  return
)
;#-------------------------------------------------------------------------------
;#   synopsis:	Sets the evolutionary class for a population.
;#-------------------------------------------------------------------------------
;# void 
;# ga_population_set_scheme (population		*pop,
;#                           const ga_scheme_type	scheme)
;#-------------------------------------------------------------------------------
;proc ga_population_set_scheme {pop scheme} \
;{

;  #   if ( !pop ) die("Null pointer to population structure passed.");
  
;  #   plog( LOG_VERBOSE, "Population's evolutionary class = %d", (int) scheme);
  
;  $pop configure -scheme $scheme

;  return
;}
;#-------------------------------------------------------------------------------
;#-------------------------------------------------------------------------------
;#   synopsis:	Kill entities to reduce population size down to
;# 		specified value.
;#-------------------------------------------------------------------------------
;# boolean 
;# ga_genocide (population *pop, int target_size)
;#-------------------------------------------------------------------------------
(defun ga_genocide  (pop target_size)


  (loop while  (> (POP_SIZE pop) target_size) :do

    ;;    #puts stderr "ga_genocide .. target_size = $target_size"

    ;;  #     /*printf("Dereferencing entity with rank %d (fitness = %d)\n",
    ;;  #       pop->size-1, pop->entity_iarray[pop->size-1]->fitness);*/

    (ga_entity_dereference_by_rank   pop (- (POP_SIZE pop) 1))
    )


  ;;  # вообще-то есть такая процедура, надо ли ей воспользоваться?
  ;;  # изменение размера популяции до родительской (удалением последних элементов)
  ;;  # 
  ;;  #method eliminate {} {
  ;;  #  
  ;;  #  set entity_iarray [lrange $entity_iarray  $options(-orig_size) end]
  ;;  #
  ;;  #  $self configure -size  [expr $options(-size) - $options(-orig_size)]
  ;;  #  $self configure -orig_size 0
  ;;  #}

  ;;  return true
  true
)
;#-------------------------------------------------------------------------------

;#   synopsis:	Kill entities with fitness equal to or worse than
;# 		specified value.

;#-------------------------------------------------------------------------------
;# boolean 
;# ga_genocide_by_fitness (population *pop, double target_fitness)

;#-------------------------------------------------------------------------------
(defun ga_genocide_by_fitness (pop target_fitness)

(let (
  size size_1 fitn_1 flag1 flag2
  ) 
  ;;  #while {[expr $flag1 && $flag2]} {}
  
  ;;  while {1} {
  (loop while true do
  
    (setf size   (POP_SIZE pop)) ; [$pop cget -size]
    (setf size_1      (1- size)) ; [expr {$size - 1}]

          ;;    #set fitn_1 [$pop get_entity_fitness $size_1]
    (setf fitn_1 (pop_get_entity_fitness_  pop  size_1))
    
    (setf flag1 (> size   0))
    (setf flag2 (< fitn_1 target_fitness)) 

    (when (not (and flag1 flag2)) (return))

    ;;    #     /*printf("Dereferencing entity with rank %d (fitness = %d)\n",
    ;;    #       pop->size-1, pop->entity_iarray[pop->size-1]->fitness);*/
    
    ;;    #     ga_entity_dereference_by_rank (pop, pop->size-1);

    (ga_entity_dereference_by_rank   pop (1- (POP_SIZE pop)))
     
    ;;    #puts "ga_genocide_by_fitness : !!!!!!!!!!!!!!!!!!!!"
    ;;    ##exit
    )
  
  true
))
;#-------------------------------------------------------------------------------
;#-------------------------------------------------------------------------------
;# ------------------------------------------------------------------------------
;#   synopsis:	Gets an entity's fitness.
;#
;# boolean 
;# ga_entity_set_fitness (entity *e, double fitness)
;# ------------------------------------------------------------------------------
(defun ga_entity_set_fitness (e fitness)

  ;;  #   if ( !e ) return FALSE;
  
  ;;  #   e->fitness=fitness;
  ;;  $e configure -fitness $fitness
  (setf (ENT_FITNESS e) fitness)
  
  ;;  return true;
  true
)
;# ------------------------------------------------------------------------------
;#-------------------------------------------------------------------------------
;#   synopsis:	Compares two entities and returns their relative
;# 		ranking.
;#   parameters:	population *alphapop	Population A
;# 		entity *alpha		Test entity A.
;# 		population *betapop 	Population B
;# 		entity *beta		Test entity B.
;#   return:	Relative rank.
;#-------------------------------------------------------------------------------
;# int 
;# ga_rank_fitness (population *alphapop, entity *alpha,
;#                  population *betapop, entity *beta)
;#-------------------------------------------------------------------------------
;proc ga_rank_fitness {alphapop alpha betapop beta} {

;  #   /* Checks */
;  #   if (!alphapop || !betapop) die("Null pointer to population structure passed");
;  #   if (!alpha || !beta) die("Null pointer to entity structure passed");
  
;  #   return (alpha->fitness - beta->fitness) > 0.0;
;  return [expr {([$alpha.fitness] - [$beta.fitness]) > 0.0}]
;}
;#-------------------------------------------------------------------------------
;#-------------------------------------------------------------------------------
;#   synopsis:     Determine mean and standard deviation of the fitness
;#                 scores.
;#   parameters:	population *pop		The population to evaluate.
;#   		double *mean		Returns the mean fitness.
;# 		double *stddev		Returns the standard deviation of the fitnesses.
;#   return:	TRUE on success.
;#-------------------------------------------------------------------------------
;# boolean 
;# ga_fitness_mean_stddev (population *pop,
;#                         double *mean, double *stddev)
;#-------------------------------------------------------------------------------
;proc ga_fitness_mean_stddev {pop &p_mean &p_stddev} \
;{

;  USE_REFS

;  #   int           i;                      /* Loop over all entities. */
;  #   double        sum=0.0, sumsq=0.0;     /* Sum and sum squared. */
;  #   double	deviation;		/* Distance to mean. */
  
;  set sum   0.0
;  set sumsq 0.0

;  #   if (!pop) die("Null pointer to population structure passed.");
;  #   if (pop->size < 1) die("Pointer to empty population structure passed.");
;  #   if (!stddev || !mean) die("Null pointer to double passed.");
  
;  set size [$pop cget -size]

;  for {set i 0} {$i < $size} {incr i} \
;  {
;    #sum += pop->entity_iarray[i]->fitness;

;    #set fi  [$pop get_entity_fitness $i]
;    set fi  [pop_get_entity_fitness_ $pop  $i]
;    set sum [expr {$sum + $fi}]
;  }
  
;  #   *mean = sum / pop->size;
;  set mean [expr {$sum / $size}]
  
;  for {set i 0} {$i < $size} {incr i} \
;  {
;    #     deviation = pop->entity_iarray[i]->fitness - *mean;
;    #     sumsq += deviation * deviation;
    
;    #set fi  [$pop get_entity_fitness $i]
;    set fi  [pop_get_entity_fitness_ $pop  $i]
;    set deviation  [expr {$fi - $mean}]

;    set sumsq [expr {$sumsq + ($deviation * $deviation)}]
;  }
  
;  #   *stddev = sqrt (sumsq/pop->size);

;  set p_mean   $mean
;  set p_stddev [expr {sqrt ($sumsq / $size)}]

;  return true
;}
;#-------------------------------------------------------------------------------
;# //******************************************************************************







;# /*******************************************************************************
;#   synopsis:	Allocate the chromosomes for an entity.  Initial
;# 		contents are garbage (there is no need to zero them).
;#-------------------------------------------------------------------------------
;# GAULFUNC boolean ga_chromosome_double_allocate(population *pop, entity *embryo)
;#-------------------------------------------------------------------------------
;proc ga_chromosome_double_allocate {pop embryo} {

;  #     //int		i;		/* Loop variable over all chromosomes */
  
;  #   if (!pop) die("Null pointer to population structure passed.");
;  #   if (!embryo) die("Null pointer to entity structure passed.");

;  #   if (embryo->chromosome!=NULL)
;  #     die("This entity already contains chromosomes.");
  
;  #   if ( !(embryo->chromosome = s_malloc (/* pop->num_chromosomes* */sizeof(double *))) )
;  #     die("Unable to allocate memory");
  
;  #   if ( !(embryo->CH = s_malloc(/* pop->num_chromosomes* */pop->len_chromosomes*sizeof(double))) )
;  #     die("Unable to allocate memory");
  
;  puts "len_chromosomes = [$pop cget -len_chromosomes]"


;  # /*   for (i=1; i<pop->num_chromosomes; i++) */
;  # /*     { */
;  # /*     embryo->chromosome[i] = &(((double *)embryo->chromosome[i-1])[pop->len_chromosomes]); */
;  # /*     } */

;  return true;
;}
;# //******************************************************************************








;# /**********************************************************************
;#   ga_seed.c

;#   Synopsis:     Routines for performing GA seeding operations.

;# 		Seeding operations generate genetic data by some
;# 		non-evolutionary means.  Typically, this is often
;# 		just random generation.

;#------------------------------------------------------------------------------
;# //------------------------------------------------------------------------------
;# char
;# get_random_wordchar ()

;# //------------------------------------------------------------------------------
;proc get_random_wordchar {} {

;  #   GAULFUNC unsigned int char_num;
;  #   char ch;  
;  #   int randmax = '~' - ' ';
  
;  set char_min [scan " " "%c"]
;  set char_max [scan "~" "%c"] 
  
;  set randmax [expr {$char_max - $char_min}]

;  #   char_num = random_int (randmax) + ' ';
;  set char_num [expr {[random_int $randmax] + $char_min}]
  
;  #   ch = (char) char_num;
;  #return (ch);

;  # может лучше число просто возвращать? и формировать не строку, а список целых?
;  return $char_num
;}
;# //------------------------------------------------------------------------------
;# boolean 
;# ga_seed_printable_random (population *pop, entity *adam)

;# //------------------------------------------------------------------------------
;proc ga_seed_printable_random {pop adam}  {

;  #   //int		chromo;		/* Index of chromosome to seed */
;  #   int		point;		/* Index of allele to seed */
  
;  #   char ch;
  
;  #   /* Checks. */
;  #   if (!pop)  die ("Null pointer to population structure passed.");
;  #   if (!adam) die ("Null pointer to entity structure passed.");
  
;  #   /* Seeding. */
;  #   //chromo=0;
;  #   //for (chromo=0; chromo<pop->num_chromosomes; chromo++)
;  #   //{


;  #puts "ga_seed_printable_random : "
;  #puts ""
;  #$adam print
;  #puts ""

;  for {set point 0} {$point < [$pop cget -len_chromosomes]} {incr point}  \
;  {
;    # ch = get_random_wordchar (); 
;    set ch [get_random_wordchar]

;    # ((char *)adam->CH)[point] = ch ;

;    #$adam set_chromo_gen $point $ch
;    ent_set_chromo_gen_ $adam $point $ch
;  }

;  #   //}

;  return true
;}
;# //------------------------------------------------------------------------------
;# //******************************************************************************








;# //------------------------------------------------------------------------------

;#   ga_compare.c

;#   Synopsis:     Routines for comparing entities.

;# 		These routines return a distance between two entities.

;# //------------------------------------------------------------------------------
;# /**********************************************************************
;#   synopsis:	Compares two char-array genomes and returns their
;# 		hamming distance.
;#   parameters:	population *pop	Population of entities (you may use
;# 			differing populations if they are "compatible")
;# 		entity *alpha	Test entity.
;# 		entity *beta	Test entity.
;#   return:	Returns Hamming distance between two entities' genomes.
;#  **********************************************************************/
;# //------------------------------------------------------------------------------
;# double 
;# ga_compare_char_hamming (population *pop, entity *alpha, entity *beta)
;# //------------------------------------------------------------------------------
;proc ga_compare_char_hamming {pop alpha beta} \
;{

;  #   int	 /* i, */j;	/* Loop variable over all chromosomes, alleles. */
;  #   char	 *a, *b;	/* Pointers to chromosomes. */  
;  #   int	 dist = 0;	/* Genomic distance.        */
;  set  dist 0

;  #   int    aj, bj;
  
;  #   /* Checks */
;  #   if (!alpha || !beta) die ("Null pointer to entity structure passed");
  
;  #   //i = 0;
;  #   //for (i=0; i<pop->num_chromosomes; i++)
;  #   //{
  
;  #   a = (char *) (alpha->CH);
;  #   b = (char *) ( beta->CH);
;  set a [ent_CH_ $alpha]
;  set b [ent_CH_ $beta]
  
;  for {set j 0} {$j < [$pop cget -len_chromosomes]} {incr j} \
;  {
;    #     aj = (int) a[j];
;    #     bj = (int) b[j];
;    set aj [lindex $a $j]
;    set bj [lindex $b $j]
    
;    #     //dist += abs ((int) a[j] - b[j]);
;    #     dist += abs (aj - bj);

;    set dist [expr {$dist + abs ($aj - $bj)}]
;  }

;  #   //}

;  return $dist
;}
;# //------------------------------------------------------------------------------
;# //******************************************************************************
;# //------------------------------------------------------------------------------








;# /**********************************************************************
;#   ga_select.c

;#   Synopsis:     Routines for performing GA selection operations.

;# 		This selection routines return TRUE if the selection
;# 		procedure has run to completion, otherwise they return
;# 		FALSE.  They may potentially return NULL for the
;# 		selected entities.  This is valid behaviour and doesn't
;# 		necessarily indicate that the selection producedure is
;# 		complete.

;# 		On the first call to these routines in a given
;# 		generation, pop->select_state is guaranteed to be set
;# 		to zero.  These routines are then free to modify this
;# 		value, for example, to store the number of selections
;# 		performed in this generation.

;# 		The ga_select_one_xxx() functions are intended for
;# 		asexual selections.
;# 		The ga_select_two_xxx() functions are intended for
;# 		sexual selections.  Checking whether the mother and
;# 		father are different entities is optional.

;# 		The calling code is welcome to not use any of these
;# 		functions.

;# 		These functions return a pointer to the entity instead
;# 		of an id because, potentially, the entities may come
;# 		from a different population.

;# 		It may be important to use the value held in the
;# 		pop->orig_size field instead of the pop->size field
;# 		because the population size is liable to increase
;# 		between calls to these functions!  (Although, of course,
;# 		you are free to use whichever value you like in
;# 		user-defined functions.)

;#  **********************************************************************/

;#-------------------------------------------------------------------------------
;#   synopsis:	Determine sum of entity fitnesses.
;#   parameters:	population *pop
;#   return:	double sum
;#-------------------------------------------------------------------------------
;# double 
;# gaul_select_sum_fitness (population *pop)
;#-------------------------------------------------------------------------------
(defun gaul_select_sum_fitness (pop)

  ;;  #   int           i;		/* Loop over all entities. */
  ;;  #   double        sum=0.0;	/* Sum and sum squared. */
  
(let (
  (sum 0)
  f
  )

  ;;  for {set i 0} {$i < [$pop cget -orig_size]} {incr i} \

  (loop for i from 0 to (1- (POP_ORIG_SIZE pop)) do

    ;;    # sum += pop->entity_iarray[i]->fitness;
    ;;    #set f [$pop get_entity_fitness $i]

    (setf f (pop_get_entity_fitness_  pop  i))

    (setf sum (+ sum f)) ; [expr {$sum + $f}]
    )

  sum ;  return $sum
))
;#-------------------------------------------------------------------------------
;#-------------------------------------------------------------------------------
;# /**********************************************************************
;#   synopsis:	Select a single entity by my rank-based method.
;#  **********************************************************************/
;# boolean 
;# ga_select_one_randomrank (population *pop, entity **mother)

;#-------------------------------------------------------------------------------
;proc ga_select_one_randomrank {pop &mother} {

;  USE_REFS

;  #   if (!pop) die("Null pointer to population structure passed.");
  
;  #   pop->select_state++;
;  $pop configure -select_state [expr {[$pop cget -select_state] + 1}]
  
;  #   *mother = NULL;
  
;  set orig_size    [$pop cget -orig_size]
;  set select_state [$pop cget -select_state]

;  if {$orig_size < $select_state} \
;  {
;    return true
;  }
  
;  if {[random_boolean_prob [$pop cget -mutation_ratio]]} \
;  {
;     # *mother = pop->entity_iarray[random_int(pop->select_state)];
;    #set mother [$pop get_entity [random_int $select_state]]
;    set mother [pop_get_entity_ $pop [random_int $select_state]]

;    return false
;  } else {
;    return true
;  }
  
;  #return false
;}
;#-------------------------------------------------------------------------------
;# /**********************************************************************
;#   synopsis:	Select a pair of entities by my rank-based method.
;# 		Basically, I loop through all entities, and each is
;# 		paired with a random, fitter, partner.
;#  **********************************************************************/
;# boolean 
;# ga_select_two_randomrank (population *pop, entity **mother, entity **father)

;#-------------------------------------------------------------------------------
;proc ga_select_two_randomrank {pop &mother &father} {

;  USE_REFS

;  #   if (!pop) die("Null pointer to population structure passed.");
  
;  #   pop->select_state++;
;  $pop configure -select_state [expr {[$pop cget -select_state] + 1}]
  
;  #set mother "NULL"
;  #set father "NULL"
  
;  set orig_size    [$pop cget -orig_size]
;  set select_state [$pop cget -select_state]

;  if {$::is_print} {
;    puts "ga_select_two_randomrank: "
;    puts "orig_size = $orig_size   select_state = $select_state"
;  }

;  if {$orig_size < $select_state} \
;  {
;    #puts "!!!!!!!!!!!!!????????????"
;    return true
;  }

;  #   if ( random_boolean_prob (pop->crossover_ratio) )
;  #   {
;  #     *mother = pop->entity_iarray[random_int(pop->select_state)];
;  #     *father = pop->entity_iarray[pop->select_state];
;  #   }
  
;  if {[random_boolean_prob [$pop cget -crossover_ratio]]} \
;  {
;    #set mother [$pop get_entity [random_int $select_state]]
;    #set father [$pop get_entity             $select_state]

;    set mother [pop_get_entity_ $pop  [random_int $select_state]]
;    set father [pop_get_entity_ $pop              $select_state]

;    return false
;  } else {
;    return true
;  }
  
;  #return false
;}
;#-------------------------------------------------------------------------------
;#-------------------------------------------------------------------------------
;#   synopsis:	Kind of tournament selection.  Choose two random
;# 		entities, return the best as the selection.  Selection
;# 		stops when
;# 		(population size)*(mutation ratio)=(number selected)

;# boolean 
;# ga_select_one_bestof2 (population *pop, entity **mother)

;#-------------------------------------------------------------------------------
;proc ga_select_one_bestof2 {pop &mother} {

;#-------------------------------------------------------------------------------
(defun ga_select_one_bestof2 (pop r_mother)

  ;;  USE_REFS
  ;;  #   entity	*mother2;	/* Random competitor. */
  
  ;;  #   if (!pop) die ("Null pointer to population structure passed.");
  
  ;;  #   if (pop->orig_size < 1)
  ;;  #   {
  ;;  #     *mother = NULL;
  ;;  #     return TRUE;
  ;;  #   }
 
(let* ( 
  (orig_size (POP_ORIG_SIZE pop)) ; [$pop cget -orig_size]

  ;;  #   *mother = pop->entity_iarray[random_int(pop->orig_size)];
  ;;  #   mother2 = pop->entity_iarray[random_int(pop->orig_size)];
  
  ;;  #set mother1 [$pop get_entity [random_int $orig_size]]
  ;;  #set mother2 [$pop get_entity [random_int $orig_size]]
  
;  (mother1 (pop_get_entity_  pop  (random_int  orig_size)))
;  (mother2 (pop_get_entity_  pop  (random_int  orig_size)))

  (mother1 (pop_get_entity_clone  pop  (random_int  orig_size)))
  (mother2 (pop_get_entity_clone  pop  (random_int  orig_size)))

  ret s_state
  (m_ratio   (POP_MUTATION_RATIO pop))  ; [$pop cget -mutation_ratio]
  )
  
  ;;  #   if (mother2->fitness > (*mother)->fitness)
  ;;  #     *mother = mother2;
  
  ;;  if {[$mother1 cget -fitness] > [$mother2 cget -fitness]} {
  ;;    set mother $mother1
  ;;  } else {
  ;;    set mother $mother2
  ;;  }

  (if (> (ENT_FITNESS mother1) (ENT_FITNESS mother2))
      (set r_mother mother1) 
      (set r_mother mother2) 
      )

  ;;  #   pop->select_state++;
  ;;  $pop configure -select_state [expr {[$pop cget -select_state] + 1}]

  (setf  s_state (POP_SELECT_STATE pop)) ; [$pop cget -select_state]
  (incf  s_state)
  (setf (POP_SELECT_STATE pop) s_state)

  ;;  set ret [expr {[$pop cget -select_state] > ($orig_size * [$pop cget -mutation_ratio])} ]

  (setf ret (> s_state (* 1.0 orig_size m_ratio)))
  
  ;;  #   return pop->select_state>(pop->orig_size*pop->mutation_ratio);
  ;;  return $ret

  ret

))
;#-------------------------------------------------------------------------------
;#   synopsis:	Kind of tournament selection.  For each parent, choose
;# 		two random entities, return the best as the selection.
;# 		The two parents will be different.  Selection
;# 		stops when
;# 		(population size)*(crossover ratio)=(number selected)

;# boolean 
;# ga_select_two_bestof2 (population *pop, entity **mother, entity **father)

;#-------------------------------------------------------------------------------
(defun ga_select_two_bestof2 (pop  r_mother r_father)

  ;;  USE_REFS
  
  ;;  #   entity	*challenger;	/* Random competitor. */
  
  ;;  #   if (!pop) die("Null pointer to population structure passed.");
  
  ;;  #   if (pop->orig_size < 2)
  ;;  #   {
  ;;  #     *mother = NULL;
  ;;  #     *father = NULL;
  ;;  #     return TRUE;
  ;;  #   }
  
(let* (
  (orig_size (POP_ORIG_SIZE       pop))  ; [$pop cget -orig_size]
  (c_ratio   (POP_CROSSOVER_RATIO pop))  ; [$pop cget -crossover_ratio] 

  (moth_i       (random_int  orig_size))
  ;(mother       (pop_get_entity_  pop  moth_i))
  (mother       (pop_get_entity_clone  pop  moth_i))

  (moth_fitness (ENT_FITNESS mother)) 

  (chal_i     (random_int  orig_size))
  ;(challenger (pop_get_entity_  pop  chal_i))
  (challenger (pop_get_entity_clone  pop  chal_i))

  (chal_fitness (ENT_FITNESS challenger)) 

  ret s_state fath_i fath_fitness

  father
  ;(father (symbol-value r_father))
  ;(mother (symbol-value r_mother))
  )  
  ;(declare (special


  (when (> chal_fitness moth_fitness)
    ; #puts "  chal_fitness > moth_fitness"

    (setf mother  challenger)
    (setf moth_i  chal_i) ;# // сделаем это по факту !?
  )

  ; #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  ;;  while {1} {
  (loop while true do

    (setf fath_i  (random_int  orig_size))
    (when (/= moth_i fath_i)  (return)) ;  нашли для папы индекс, отилчный от мамы
    )

  ;(setf father  (pop_get_entity_  pop  fath_i))
  (setf father  (pop_get_entity_clone  pop  fath_i))
  (setf fath_fitness  (ENT_FITNESS father))
  

  (setf chal_i (random_int  orig_size))
  ;(setf challenger   (pop_get_entity_  pop  chal_i))
  (setf challenger   (pop_get_entity_clone  pop  chal_i))
  (setf chal_fitness (ENT_FITNESS challenger)) 
 
  ;;  #puts "  moth_i= $moth_i  fath_i= $fath_i  chth_i= $chal_i  chal_fitness= $chal_fitness  fath_fitness= $fath_fitness"

  (when (and  (/= chal_i moth_i) (> chal_fitness fath_fitness))
    ; #puts "  ....."
    (setf father challenger)
    (setf fath_i  chal_i)  ;# // сделаем это по факту !?
    )
  
  ; #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  (set r_mother mother)
  (set r_father father)

  ; #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  (when __is_print
    (format t "  ga_select_two_bestof2 : ~%")

    (print_entit  mother (format nil "mother = (~d) =" moth_i))
    (print_entit  father (format nil "father = (~d) =" fath_i))
    )
  

  ;;  #   pop->select_state++;
  ;;  #

  (setf  s_state (POP_SELECT_STATE pop)) ; [$pop cget -select_state]
  (incf  s_state)
  (setf (POP_SELECT_STATE pop) s_state)

  ;;  # истина, если закончился перебор (селекция пар) ?
  ;;  # 
  (setf ret (> s_state (* 1.0 orig_size c_ratio)))
  
  (when __is_print
    (format t "  s_state= ~s  orig_size= ~s  c_ratio= ~s  ret = ~s ~%"
            s_state orig_size c_ratio ret) 
    (format t "~%")
    )

  ;;  #   return pop->select_state>(pop->orig_size*pop->crossover_ratio);
  ;;  return $ret
  ret
))
;#-------------------------------------------------------------------------------
;#-------------------------------------------------------------------------------
;#   synopsis:	Stochastic Universal Sampling selection.
;#   		pop->mutation_ratio multiplied by pop->orig_size gives
;# 		the number of selections which will be performed.
;# 		This version is for fitness values where 0.0 is bad and
;# 		large positive values are good.  Negative values will
;# 		severely mess-up the algorithm.
;#-------------------------------------------------------------------------------
;# boolean 
;# ga_select_one_sus (population *pop, entity **mother)

;#-------------------------------------------------------------------------------
;proc ga_select_one_sus {pop &mother}  {

;  USE_REFS

;  #   double	sum;			/* Fitness total. */
  
;  set orig_size       [$pop cget -orig_size]
;  set select_state    [$pop cget -select_state]
;  set mutation_ratio  [$pop cget -mutation_ratio]

;  if {$orig_size < 1} \
;  {
;      return true
;  }
  
;  if {$select_state == 0} \
;  { 
;    # First call of this generation.

;    [$pop.selectdata].num_to_select = [expr {max (1, int (floor ($orig_size * $mutation_ratio)))}]

;#     if {$::is_GA_SELECTDATA_T} {
;#     } else {
;#     }

;    set sum [gaul_select_sum_fitness $pop]

;    set selectdata_step [expr {$sum / ($orig_size * $mutation_ratio)}]

;    $pop.step = $selectdata_step

;    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

;     [$pop.selectdata].offset1 = [random_double $selectdata_step]

;#     if {$::is_GA_SELECTDATA_T} {
;#      } else {
;#     }
;    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


;    [$pop.selectdata].current1 = 0

;#     if {$::is_GA_SELECTDATA_T} {
;#     } else {
;#     }

;  } else {

;    set num_to_select  [[$pop.selectdata].num_to_select]

;#     if {$::is_GA_SELECTDATA_T} {
;#     } else {
;#     }

;    if {$select_state > $num_to_select} {
;      return true ;# признак окончания
;    }

;    set step [$pop.step]

;    [$pop.selectdata].offset1 = [expr {[[$pop.selectdata].offset1] + $step}]

;  }
  

;  while {1} \
;  {

;    set off1 [[$pop.selectdata].offset1]

;#     if {$::is_GA_SELECTDATA_T} {
;#     } else {
;#     }

;    set cur1 [[$pop.selectdata].current1]

;#     if {$::is_GA_SELECTDATA_T} {
;#     } else {
;#     }


;    set fit1 [pop_get_entity_fitness_ $pop  $cur1]

;    if {$off1 <= $fit1} {break}


;    [$pop.selectdata].offset1 =   [expr {$off1 - $fit1}]

;#     if {$::is_GA_SELECTDATA_T} {
;#     } else {
;#     }

;    incr cur1

;    if {$cur1 >= $orig_size} {
;      set cur1 [expr {$cur1 - $orig_size}]
;    }   
 
;    [$pop.selectdata].current1 = $cur1

;#      if {$::is_GA_SELECTDATA_T} {
;#     } else {
;#     }

;  }
  
;  set cur1 [[$pop.selectdata].current1]

;#   if {$::is_GA_SELECTDATA_T} {
;#   } else {
;#   }

;  set mother [pop_get_entity_ $pop  $cur1]

  
;  #   pop->select_state++;
;  $pop configure -select_state [expr {[$pop cget -select_state] + 1}]
  
;  return false
;}
;#-------------------------------------------------------------------------------
;# /**********************************************************************
;#   synopsis:	Stochastic Universal Sampling selection.
;#
;#   		pop->mutation_ratio multiplied by pop->orig_size gives
;# 		the number of selections which will be performed.
;#
;# 		This version is for fitness values where 0.0 is bad and
;# 		large positive values are good.  Negative values will
;# 		severely mess-up the algorithm.
;#  **********************************************************************/
;# boolean 
;# ga_select_two_sus (population *pop, entity **mother, entity **father)
;#-------------------------------------------------------------------------------
;proc ga_select_two_sus {pop &mother &father}  {
(defun ga_select_two_sus  (pop r_mother r_father)

;  USE_REFS

;  #   double	sum;			/* Fitness total. */
;  #   int	*ordered;		/* Ordered indices. */
;  #   int	i;			/* Loop variable over indices. */
  
;  #   if (!pop) die("Null pointer to population structure passed.");  
;  #   *mother = NULL;
  

(let* (

  (orig_size        (POP_ORIG_SIZE        pop))  ; [$pop cget -orig_size]
  (select_state     (POP_SELECT_STATE     pop))  ; [$pop cget -select_state]
  (crossover_ratio  (POP_CROSSOVER_RATIO  pop))  ; [$pop cget -crossover_ratio] 
       
  (selectdata       (POP_SELECTDATA       pop))
  num_to_select ; ; [[$pop.selectdata].num_to_select]

  (ordered (make-array orig_size))

  sum selectdata_step step off1 cur1 off2 cur2 fit1 fit2 perm 
  )  


  ;;#     if {$::is_GA_SELECTDATA_T} {
  ;;#     } else {
  ;;#     }

  (format t "~%")
  (format t "ga_select_two_sus: select_state  = ~s ~%" select_state)
  (format t "ga_select_two_sus: orig_size     = ~s ~%" orig_size)
  (format t "ga_select_two_sus: num_to_select = ~s ~%" num_to_select)
  (format t "~%")
  ;(exit)

  ;;  if {$orig_size < 1} \
  ;;  {
  ;;      return true
  ;;  }
  
  ;;  if {$::is_print} {
  ;;    puts stderr "ga_select_two_sus ........ "
  ;;  }

;  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  (if (= select_state 0)
  (progn 
 
    ;;    if {$::is_print} {puts stderr "1 ... "}

    ;;    # First call of this generation

    ;;    [$pop.selectdata].num_to_select = \
    ;;      [expr {max (1, int (floor ($orig_size * $crossover_ratio)))}]

    (setf (SD_NUM_TO_SELECT selectdata) (max 1 (floor (* orig_size crossover_ratio))))

    ;;#     if {$::is_GA_SELECTDATA_T} {
    ;;#     } else {
    ;;#     }


    (setf sum (gaul_select_sum_fitness   pop))

    ;;    set selectdata_step [expr {$sum / [[$pop.selectdata].num_to_select]} ]
    (setf selectdata_step (/ sum (SD_NUM_TO_SELECT selectdata)))

    ;;#     if {$::is_GA_SELECTDATA_T} {
    ;;#     } else {
    ;;#     }

    ;;    #$pop configure -selectdata_step $selectdata_step
    ;;    $pop.step = $selectdata_step ?????????????????????????? нет такой

    (setf (SD_STEP selectdata) selectdata_step)

    ;;    [$pop.selectdata].offset1 = [random_double $selectdata_step]
    (setf (SD_OFFSET1 selectdata)  (random_double  selectdata_step))

    ;;    [$pop.selectdata].offset2 = [[$pop.selectdata].offset1]
    (setf (SD_OFFSET2 selectdata)  (SD_OFFSET1 selectdata))

    ;;#     if {$::is_GA_SELECTDATA_T} {
    ;;#     } else {
    ;;#     }

    ;;    #puts  stderr [format "sum = %f  step = %f  off1 = %f " $sum $selectdata_step [$pop cget -selectdata_offset1]]

    (setf (SD_CURRENT1    selectdata) 0) ;    [$pop.selectdata].current1 = 0
    (setf (SD_CURRENT2    selectdata) 0) ;    [$pop.selectdata].current2 = 0

    (setf (SD_PERMUTATION selectdata) 0) ;    [$pop.selectdata].permutation = "" ;# NULL

    ;;    if {$::is_GA_SELECTDATA_T} {
    ;;    } else {
    ;;      #$pop configure -selectdata_permutation "" ;# NULL
    ;;    }

    
    ;;    for {set i 0} {$i < $orig_size} {incr i} {
    ;;      lappend  ordered $i
    ;;    }
    (loop for i from 0 to (1- orig_size) do
      ;(append  ordered i) ; ????
      (setf (elt ordered i)  i)
      )

    ;;    #  int    *iarray, // Source array.
    ;;    #  int    *oarray  // Destination array.
    
    ;;    #puts stderr "ordered = $ordered"
    
    ;;    #random_int_permutation  $orig_size $ordered oarray ;# перемешали числа
    ;;    #
    ;;    # вообще-то в оригинале массив "ordered" тоже портится, но здесь незаметно
    ;;    # поскольку вызывается один раз
    ;;    #

    ;;    random_int_permutation  $orig_size  ordered oarray ;# перемешали числа
    ;;    [$pop.selectdata].permutation = $oarray     ;# записаил перемешку
    
    (setf (SD_PERMUTATION selectdata) (random_int_permutation orig_size ordered))

    ;;#     if {$::is_GA_SELECTDATA_T} {
    ;;#     } else {
    ;;#       #$pop configure -selectdata_permutation $oarray     ;# записаил перемешку
    ;;#     }

    ;;  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  ) ; progn
  ;;  } else {
  (progn

    ;;  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    ;;    set num_to_select [[$pop.selectdata].num_to_select]
    (setf num_to_select (SD_NUM_TO_SELECT selectdata)) 

    (when (> select_state num_to_select)
      
      ;;      if {$::is_print} {puts stderr "2 ... "}
      
      ;;      # эта ветка для окончания пеербора (селекции) пар ?
      ;;      #     s_free (pop->selectdata.permutation);
      ;;      #     pop->selectdata.permutation = NULL;
      
      ;;      [$pop.selectdata].permutation = ""
      (setf (SD_PERMUTATION selectdata) #())

      ;;#       if {$::is_GA_SELECTDATA_T} {
      ;;#       } else {
      ;;#         #$pop configure -selectdata_permutation ""
      ;;#       }


      (return-from ga_select_two_sus true) ; return true ;# признак окончания
      )


    ;;    if {$::is_print} {puts stderr "3 ... "}

    ;;    #set step [$pop cget -selectdata_step]

    ;;    set step [$pop.step]
    (setf step (SD_STEP selectdata))

    ;;    [$pop.selectdata].offset1 = [expr {[[$pop.selectdata].offset1] + $step}]
    (setf (SD_OFFSET1 selectdata) (+ (SD_OFFSET1 selectdata) step))

    ;;    [$pop.selectdata].offset2 = [expr {[[$pop.selectdata].offset2] + $step}]
    (setf (SD_OFFSET2 selectdata) (+ (SD_OFFSET2 selectdata) step))

    ;;#     if {$::is_GA_SELECTDATA_T} {
    ;;#     } else {
    ;;#     }

  )) ; progn if
  



  ;;  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  ;;  while {1} \
  (loop while true do


    (setf off1 (SD_OFFSET1   selectdata)) ; [[$pop.selectdata].offset1]
    (setf cur1 (SD_CURRENT1  selectdata)) ; [[$pop.selectdata].current1]

    ;;#     if {$::is_GA_SELECTDATA_T} {
    ;;#     } else {
    ;;#     }

    (setf fit1 (pop_get_entity_fitness_  pop cur1))

    (when (<= off1 fit1) (return))

    ;;    #puts "off1 > fit1"
    ;;    #exit

    ;;    [$pop.selectdata].offset1 =  [expr {$off1 - $fit1}]
    (setf (SD_OFFSET1 selectdata) (- off1 fit1))

    (incf cur1) ;    incr cur1

    (when (>= cur1 orig_size)
      (setf cur1 (- cur1 orig_size))
      )
    
    ;;    [$pop.selectdata].current1 = $cur1
    (setf (SD_CURRENT1 selectdata) cur1)

    ;;    if {$::is_GA_SELECTDATA_T} {
    ;;    } else {
    ;;    }

  )
  ;; #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  

  ;; #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  (loop while true do

    (setf off2 (SD_OFFSET2     selectdata)) ; [[$pop.selectdata].offset2]
    (setf cur2 (SD_CURRENT2    selectdata)) ; [[$pop.selectdata].current2]

    (setf perm (SD_PERMUTATION selectdata)) ; [[$pop.selectdata].permutation]

    ;;    if {$::is_GA_SELECTDATA_T} {      
    ;;    } else {
    ;;      #set perm [$pop cget -selectdata_permutation]
    ;;    }


    ;;    #set fit2 [$pop get_entity_fitness [lindex $perm $cur2]]
    ;;    set fit2 [pop_get_entity_fitness_ $pop  [lindex $perm $cur2]]
    (setf fit2 (pop_get_entity_fitness_  pop cur2))

    ;;    if {$off2 <= $fit2} {break}
    (when (<= off2 fit2) (return))

    ;;    #puts "off2 > fit2"
    ;;    #exit

    ;;    [$pop.selectdata].offset2 = [expr {$off2 - $fit2}]
    (setf (SD_OFFSET2 selectdata) (- off2 fit2))


    (incf cur2) ;    incr cur2
    

    ;;    if {$cur2 >= $orig_size} {
    ;;      set cur2 [expr {$cur2 - $orig_size}]
    ;;    }    
    (when (>= cur2 orig_size)
      (setf cur2 (- cur2 orig_size))
      )

    ;;    [$pop.selectdata].current2 = $cur2
    (setf (SD_CURRENT2 selectdata) cur2)

    ;;#     if {$::is_GA_SELECTDATA_T} {
    ;;#     } else {
    ;;#     }

)
;  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  
  (setf cur1 (SD_CURRENT1 selectdata)) ; [[$pop.selectdata].current1]
  (setf cur2 (SD_CURRENT2 selectdata)) ; [[$pop.selectdata].current2]

  (setf perm (SD_PERMUTATION selectdata)) ; [[$pop.selectdata].permutation]

  ;;#   if {$::is_GA_SELECTDATA_T} {
  ;;#   } else {
  ;;#     set perm [$pop cget -selectdata_permutation]
  ;;#   }


  ;;  if {$::is_print} {
  ;;    puts stderr "cur1 = $cur1"
  ;;    puts stderr "cur2 = $cur2"
  ;;    puts stderr "perm = $perm"
  ;;  }


  (set r_mother (pop_get_entity_  pop cur1))

  (set r_father (pop_get_entity_  pop (elt perm cur2))) ; [lindex $perm $cur2]]
  
  ;;  $pop configure -select_state [expr {$select_state + 1}]
  (setf (POP_SELECT_STATE pop) (+ select_state 1))

  false ;;  return false
))
;#-------------------------------------------------------------------------------
;# //******************************************************************************






;#-------------------------------------------------------------------------------
;#   ga_qsort.c

;#   ga_qsort - GA population sorting routines.

;#   Synopsis:	Sort the population by fitness.

;# 		These functions aren't intended for public use.

;# 		Two versions exist.  (1) The older version uses the
;# 		quicksort algorithm, but since it is inefficient for
;# 		small arrays we use a shuffle sort to sort blocks of
;# 		less than 8 elements.  Unfortunately, platform
;# 		precision seems to be critical to the final ordering
;# 		with degenerate fitness scores - resulting in different
;# 		evolution results on different types of computer, which
;# 		is unacceptable.  (2) The newer, low-tech, shuffle
;# 		sort which sucks from a 'fanciness' perspective... but
;# 		it works.

;#-------------------------------------------------------------------------------
(defun sort_population (pop)

  ;;  #$pop sort 

  (pop_sort_  pop)

)
;#-------------------------------------------------------------------------------
;#-------------------------------------------------------------------------------









;# /**********************************************************************
;#   ga_utility.c

;#   ga_utility - High-level genetic algorithm routines.

;#   Synopsis:     High-level GA functions and convenience functions.

;#   To do:	Population/entity iterator functions.
;# 		On-line and off-line performance summaries.

;#-------------------------------------------------------------------------------
;# /**********************************************************************
;#   synopsis:	High-level function to create a new population and
;# 		perform the basic setup (i.e. initial seeding) required
;# 		for further optimisation and manipulation.
;# 		Assumes the use of integer chromosomes is desired.
;# 		Integer-valued chromsomes.
;#  **********************************************************************/
;#-------------------------------------------------------------------------------
;# population *
;# ga_genesis_integer (const int		population_size,
;#                       const int		num_chromo,
;#                       const int		len_chromo,
;#                       GAgeneration_hook	generation_hook,
;#                       GAiteration_hook	iteration_hook,
;#                       GAdata_destructor	data_destructor,
;#                       GAdata_ref_incrementor	data_ref_incrementor,
;#                       GAevaluate		evaluate,
;#                       GAseed			seed,
;#                       GAadapt			adapt,
;#                       GAselect_one		select_one,
;#                       GAselect_two		select_two,
;#                       GAmutate		mutate,
;#                       GAcrossover		crossover,
;#                       GAreplace		replace,
;#                       vpointer		userdata )

;#-------------------------------------------------------------------------------
;proc ga_genesis_integer {population_size      \
;                         num_chromo           \
;                         len_chromo           \
;                         generation_hook      \
;                         iteration_hook       \
;                         data_destructor      \
;                         data_ref_incrementor \
;                         evaluate             \
;                         seed                 \
;                         adapt                \
;                         select_one           \
;                         select_two           \
;                         mutate               \
;                         crossover            \
;                         replace              \
;                         userdata} {

;  #   population	*pop;	/* The new population structure. */
  
;  #   plog(LOG_VERBOSE, "Genesis is beginning!");
  

(defun ga_genesis_integer (population_size   
                          num_chromo          
                          len_chromo           
                          generation_hook      
                          iteration_hook       
                          data_destructor      
                          data_ref_incrementor 
                          evaluate             
                          seed                 
                          adapt                
                          select_one           
                          select_two           
                          mutate               
                          crossover            
                          replace              
                          userdata)
  

(declare (ignore  num_chromo data_destructor data_ref_incrementor iteration_hook
                  userdata))

(let (

  (pop  "")  ;#  population * : The new population structure
  )
  

  ;;  # /*
  ;;  #  * Initialise OpenMP code.
  ;;  #  */
  ;;  #   //ga_init_openmp();
  
  ;;  # /*
  ;;  #  * Allocate and initialise a new population.
  ;;  #  * This call also sets this as the active population.
  ;;  #  */
  ;;  #   if ( !(pop = ga_population_new( population_size, /* num_chromo, */ len_chromo )) )
  ;;  #     return NULL;
  
  ;;  set pop [ga_population_new  $population_size $len_chromo]
  (setf pop (ga_population_new   population_size  len_chromo))

  ;;  # /*
  ;;  #  * Assign population's user data.
  ;;  #  */
  ;;  #   pop->data = userdata;
  
  ;;  # /*
  ;;  #  * Define some callback functions.
  ;;  #  */
  ;;  #   pop->generation_hook = generation_hook;

  ;;  $pop configure -generation_hook $generation_hook
  (setf (POP_GENERATION_HOOK pop) generation_hook)

  ;;  #   pop->iteration_hook = iteration_hook;
  
  ;;  #   pop->data_destructor = data_destructor;
  ;;  #   pop->data_ref_incrementor = data_ref_incrementor;
  
  ;;  #   pop->chromosome_constructor = ga_chromosome_integer_allocate;

  ;;  $pop configure -chromosome_constructor "ga_chromosome_integer_allocate"
  (setf (POP_CHROMOSOME_CONSTRUCTOR pop) "ga_chromosome_integer_allocate")

  ;;  #   pop->chromosome_destructor = ga_chromosome_integer_deallocate;
  ;;  #   pop->chromosome_replicate = ga_chromosome_integer_replicate;
  ;;  #   pop->chromosome_to_bytes = ga_chromosome_integer_to_bytes;
  ;;  #   pop->chromosome_from_bytes = ga_chromosome_integer_from_bytes;
  ;;  #   pop->chromosome_to_string = ga_chromosome_integer_to_string;
  
  ;;  #   pop->evaluate = evaluate;
  ;;  #   pop->seed = seed;
  

  ;;  $pop configure -evaluate $evaluate;
  ;;  $pop configure -seed     $seed       ;# pop->seed = seed;

  (setf (POP_EVALUATE pop) evaluate) 
  (setf (POP_SEED     pop) seed) 

  ;;  $pop configure -adapt    $adapt
  (setf (POP_ADAPT pop) adapt)

;  $pop configure -select_one  $select_one ;#   pop->select_one = select_one;
;  $pop configure -select_two  $select_two ;#   pop->select_two = select_two;
;  $pop configure -mutate    $mutate    ;#
;  $pop configure -crossover $crossover ;#
;  $pop configure -replace   $replace   ;#
  
  (setf (POP_SELECT_ONE pop) select_one)
  (setf (POP_SELECT_TWO pop) select_two)
  
  (setf (POP_MUTATE    pop)    mutate)
  (setf (POP_CROSSOVER pop) crossover)
  (setf (POP_REPLACE   pop)   replace)

  ;;  # /*
  ;;  #  * Seed the population.
  ;;  #  */
  ;;  # #if 0
  ;;  #   if (seed==NULL)
  ;;  #     {
  ;;  #     plog(LOG_VERBOSE, "Entity seed function not defined.  Genesis can not occur.  Continuing anyway.");
  ;;  #     }
  ;;  #   else
  ;;  #     {
  ;;  #     ga_population_seed(pop);
  ;;  #     plog(LOG_VERBOSE, "Genesis has occured!");
  ;;  #     }
  ;;  # #endif

  ;;  return $pop
  pop
))
;#-------------------------------------------------------------------------------

;# /**********************************************************************
;#   *** DEPRECATED FUNCTIONS! ***
;#   synopsis:	High-level function to create a new population and
;# 		perform the basic setup (i.e. initial seeding) required
;# 		for further optimisation and manipulation.
;# 		Assumes the use of integer chromosomes is desired.
;# 		This currently only exists for compatibility with
;# 		older versions of GAUL.
;# 		Integer-valued chromsomes.
;#  **********************************************************************/

;#-------------------------------------------------------------------------------
;#   synopsis:	High-level function to create a new population and
;# 		perform the basic setup (i.e. initial seeding) required
;# 		for further optimisation and manipulation.
;# 		Character-valued chromosomes.

;#-------------------------------------------------------------------------------
;# population *
;# ga_genesis_char (const int		population_size,
;#                  const int		num_chromo,
;#                  const int		len_chromo,
;#                  GAgeneration_hook	generation_hook,
;#                  GAiteration_hook	iteration_hook,
;#                  GAdata_destructor	data_destructor,
;#                  GAdata_ref_incrementor	data_ref_incrementor,
;#                  GAevaluate		evaluate,
;#                  GAseed			seed,
;#                  GAadapt			adapt,
;#                  GAselect_one		select_one,
;#                  GAselect_two		select_two,
;#                  GAmutate		mutate,
;#                  GAcrossover		crossover,
;#                  GAreplace		replace,
;#                  vpointer		userdata )
;#-------------------------------------------------------------------------------
;proc ga_genesis_char {population_size        \
;                      num_chromo             \
;                      len_chromo             \
;                      generation_hook        \
;                      iteration_hook         \
;                      data_destructor        \
;                      data_ref_incrementor   \
;                      evaluate               \
;                      seed                   \
;                      adapt                  \
;                      select_one             \
;                      select_two             \
;                      mutate                 \
;                      crossover              \
;                      replace                \
;                      userdata } {

;  #   population	*pop;	/* The new population structure. */
;  #   plog (LOG_VERBOSE, "Genesis is beginning!");
  
;  # /*
;  #  * Initialise OpenMP code.
;  #  */
;  #   //ga_init_openmp();
  
;  # /*
;  #  * Allocate and initialise a new population.
;  #  * This call also sets this as the active population.
;  #  */
;  #   if ( !(pop = ga_population_new (population_size, /* num_chromo, */ len_chromo)) )
;  #     return NULL;

;  set pop [ga_population_new  $population_size $len_chromo]
 
  
;  # /*
;  #  * Assign population's user data.
;  #  */
;  #   pop->data = userdata;
  
;  # /*
;  #  * Define some callback functions.
;  #  */
;  #   pop->generation_hook = generation_hook;
;  $pop configure -generation_hook $generation_hook

;  #   pop->iteration_hook = iteration_hook;
  
;  #   pop->data_destructor = data_destructor;
;  #   pop->data_ref_incrementor = data_ref_incrementor;
  
;  #   pop->chromosome_constructor = ga_chromosome_char_allocate;
;  $pop configure -chromosome_constructor "ga_chromosome_char_allocate"

;  #   pop->chromosome_destructor = ga_chromosome_char_deallocate;
;  #   pop->chromosome_replicate = ga_chromosome_char_replicate;
;  #   pop->chromosome_to_bytes = ga_chromosome_char_to_bytes;
;  #   pop->chromosome_from_bytes = ga_chromosome_char_from_bytes;
;  #   pop->chromosome_to_string = ga_chromosome_char_to_string;
  
;  #   pop->evaluate = evaluate;
;  #   pop->seed = seed;
;  $pop configure -evaluate $evaluate;
;  $pop configure -seed     $seed    

;  $pop configure -adapt    $adapt

;  $pop configure -select_one  $select_one ;#   pop->select_one = select_one;
;  $pop configure -select_two  $select_two ;#   pop->select_two = select_two;

;  $pop configure -mutate    $mutate    ;#
;  $pop configure -crossover $crossover ;#
;  $pop configure -replace   $replace   ;#
  
;  # /*
;  #  * Seed the population.
;  #  */
;  # #if 0
;  #   if (seed==NULL)
;  #     {
;  #     plog(LOG_VERBOSE, "Entity seed function not defined.  Genesis can not occur.  Continuing anyway.");
;  #     }
;  #   else
;  #     {
;  #     ga_population_seed(pop);
;  #     plog(LOG_VERBOSE, "Genesis has occured!");
;  #     }
;  # #endif
  
;  return $pop
;}
;#-------------------------------------------------------------------------------
;#-------------------------------------------------------------------------------
;#   synopsis:	High-level function to create a new population and
;# 		perform the basic setup (i.e. initial seeding) required
;# 		for further optimisation and manipulation.
;# 		Double precision real-valued chromosomes.
;#   return:	population, or NULL on failure.
;#-------------------------------------------------------------------------------
;# population *
;# ga_genesis_double (const int		population_size,
;#                      const int		num_chromo,
;#                      const int		len_chromo,
;#                      GAgeneration_hook	generation_hook,
;#                      GAiteration_hook	iteration_hook,
;#                      GAdata_destructor	data_destructor,
;#                      GAdata_ref_incrementor	data_ref_incrementor,
;#                      GAevaluate		evaluate,
;#                      GAseed			seed,
;#                      GAadapt			adapt,
;#                      GAselect_one		select_one,
;#                      GAselect_two		select_two,
;#                      GAmutate		mutate,
;#                      GAcrossover		crossover,
;#                      GAreplace		replace,
;#                      vpointer		userdata )

;#-------------------------------------------------------------------------------
(defun ga_genesis_double (population_size   
                          num_chromo          
                          len_chromo           
                          generation_hook      
                          iteration_hook       
                          data_destructor      
                          data_ref_incrementor 
                          evaluate             
                          seed                 
                          adapt                
                          select_one           
                          select_two           
                          mutate               
                          crossover            
                          replace              
                          userdata)
  

(declare (ignore  num_chromo data_destructor data_ref_incrementor adapt 
                  userdata))

(let (

  (pop  "")  ;#  population * : The new population structure
  )
  
  ;;  # plog (LOG_VERBOSE, "Genesis is beginning!");
  
  ;;  # 
  ;;  # Initialise OpenMP code.
  ;;  # 
  ;;  # //ga_init_openmp();
  
  ;;  #
  ;;  # Allocate and initialise a new population.
  ;;  # This call also sets this as the active population.
  ;;  # 
  ;;  # if ( !(pop = ga_population_new( population_size, /* num_chromo, */ len_chromo )) )
  ;;  #     return NULL;
  ;;  #

  (setf pop (ga_population_new   population_size  len_chromo))
  
  
  ;;  #   Assign population's user data.
  ;;  # 
  ;;  #   pop->data = userdata;
  
  ;;  #   Define some callback functions.
  ;;  # 
  ;;  #   pop->generation_hook = generation_hook;

  (setf (POP_GENERATION_HOOK pop) generation_hook)
  
  (setf (POP_ITERATION_HOOK  pop) iteration_hook)
  
  ;;  #   pop->data_destructor = data_destructor;
  ;;  #   pop->data_ref_incrementor = data_ref_incrementor;
  
  ;;  # pop->chromosome_constructor = ga_chromosome_double_allocate;

  (setf (POP_CHROMOSOME_CONSTRUCTOR pop) "ga_chromosome_double_allocate")
  
  ;;  #   pop->chromosome_destructor = ga_chromosome_double_deallocate;
  ;;  #   pop->chromosome_replicate  = ga_chromosome_double_replicate;
  ;;  #   pop->chromosome_to_bytes   = ga_chromosome_double_to_bytes;
  ;;  #   pop->chromosome_from_bytes = ga_chromosome_double_from_bytes;
  ;;  #   pop->chromosome_to_string  = ga_chromosome_double_to_string;
  
  (setf (POP_EVALUATE pop) evaluate) ;;  $pop configure -evaluate $evaluate;
  (setf (POP_SEED     pop) seed) ;;  $pop configure -seed     $seed       ;# pop->seed = seed;
  
  ;;  $pop configure -adapt       $adapt
  (setf (POP_SELECT_ONE pop) select_one);;  $pop configure -select_one  $select_one
  (setf (POP_SELECT_TWO pop) select_two);;  $pop configure -select_two  $select_two 
  
  (setf (POP_MUTATE    pop)    mutate)
  (setf (POP_CROSSOVER pop) crossover)
  (setf (POP_REPLACE   pop)   replace)
  
  ;;  # 
  ;;  #   Seed the population.
  ;;  #  
  
  ;;  # здесь начальная популяция не создается реально ?!
  ;;  # видимо дальше, при итерациях?
  
  ;;  # #if 0
  ;;  #   if (seed==NULL)
  ;;  #     {
  ;;  #     plog(LOG_VERBOSE, "Entity seed function not defined.  Genesis can not occur.  Continuing anyway.");
  ;;  #     }
  ;;  #   else
  ;;  #     {
  ;;  #     ga_population_seed (pop);
  ;;  #     plog(LOG_VERBOSE, "Genesis has occured!");
  ;;  #     }
  ;;  # #endif
  
  
  ;;  return $pop
  pop

))
;#-------------------------------------------------------------------------------
;# //******************************************************************************









