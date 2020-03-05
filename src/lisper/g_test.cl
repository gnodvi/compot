; -*-   mode: lisp ; coding: koi8   -*- ----------------------------------------

;-------------------------------------------------------------------------------
;# Josef Knecht @ Copyright 
;#-------------------------------------------------------------------------------

;lappend auto_path \
;  [file join [file dirname [info script]] "I"] ;# "../common"

;package require common 1.0

;source "I/a-rand.tl"

;#-------------------------------------------

;(load  "EXT/LSP/src/a-comm.cl")
;(load  "EXT/LSP/src/a-rand.cl")

(load  "a-comm.cl")
(load  "a-rand.cl")

;#-------------------------------------------
;#-------------------------------------------

(load  "f-sort.cl")

(load  "g-core.cl")

(load  "g-cros.cl")

(load  "g-diff.cl")

;source "h-grad.tl"


;# /*******************************************************************************
;#-------------------------------------------------------------------------------
;proc parse_opts {&population_size &max_generations  \
;                def_population_size def_max_generations} {

;  USE_REFS

;  global argc argv argv0

;  set ::is_print 0

;  #puts "argc = $argc"
;  #exit

;  if  {$argc == 1} { 
;    # вызов без параметров, только с одним mode
    
;    set population_size  $def_population_size
;    set max_generations  $def_max_generations
 
;  } else {

;    set population_size [lindex $argv 1]
;    set max_generations [lindex $argv 2]
;    if  {$argc == 4}    {set ::is_print 1}
;  }

;  return
;}
;#-------------------------------------------------------------------------------
(defun parse_opts (r_population_size   r_max_generations)

(let* (
  (argus  (get_argus))
  (argc   (list-length argus))
  )

  ;(format t "argc = ~s ~%" argc)
  (setf __is_print false)
  
  (unless  (= argc 0) 
      (set r_population_size (parse-integer (nth 1 argus))) ; пишем в "символ"
      (set r_max_generations (parse-integer (nth 2 argus)))
  )
  
  (when (= argc 4)
    (setf __is_print true)
    )

))
;# /*******************************************************************************
;#   ga_x_tester.c

;# *******************************************************************************/

;#-------------------------------------------------------------------------------

;# #define SQU(x)          ((x)*(x))		/* Square */
;# #define CUBE(x)         ((x)*(x)*(x))		/* Cube */
;# #define FOURTH_POW(x)	((x)*(x)*(x)*(x))	/* Guess ;) */
;# #define FIFTH_POW(x)	((x)*(x)*(x)*(x)*(x))	/*  - " - */

;#-------------------------------------------------------------------------------
(defun SQU (x)

 (* x x)

)
;#-------------------------------------------------------------------------------
(defun CUBE (x)

 (*  x x x)

)
;#-------------------------------------------------------------------------------
(defun FOURTH_POW (x)

  (*  x x x x)

)
;#-------------------------------------------------------------------------------
;# //  synopsis:	Fitness function.

;# /* static */ boolean 
;# _test_score (population *pop, entity *this_entity)
;#-------------------------------------------------------------------------------
(defun _test_score  (pop this_entity)

(declare (ignore pop))

  ;;  #   double    A, B, C, D;	/* Parameters. */
  
  ;;  #   A = ((double *) this_entity->chromosome[0]) [0];
  ;;  #   B = ((double *) this_entity->chromosome[0]) [1];
  ;;  #   C = ((double *) this_entity->chromosome[0]) [2];
  ;;  #   D = ((double *) this_entity->chromosome[0]) [3];
  
(let* (

  (A  (ent_get_chromo_gen_  this_entity  0)) 
  (B  (ent_get_chromo_gen_  this_entity  1)) 
  (C  (ent_get_chromo_gen_  this_entity  2)) 
  (D  (ent_get_chromo_gen_  this_entity  3)) 

  ;;  #   ga_entity_set_fitness (this_entity, 
  ;;  #      - (fabs(0.75-A) + SQU(0.95-B) + fabs(CUBE(0.23-C)) + FOURTH_POW(0.71-D))
  ;;  #      );
  ;;  #
  ;;  # почему пользователь то записывает ответ (fitness) в системную область ?,
  
  (f1             (- 0.75 A))
  (f2 (SQU        (- 0.95 B)))
  (f3 (CUBE       (- 0.23 C)))
  (f4 (FOURTH_POW (- 0.71 D)))

  (fitness (- (+ (abs f1)  f2 (abs f3) f4 )))
  )
 
  (ga_entity_set_fitness  this_entity fitness) 

  ;;  return true
  true
))
;#-------------------------------------------------------------------------------
;# Seed genetic data.

;# /* static */ boolean 
;# _test_seed (population *pop, entity *adam)
;#-------------------------------------------------------------------------------
(defun _test_seed (pop adam)

(declare (ignore pop))

  ;;  # /* Checks. */
  ;;  #   if (!pop)  die ("Null pointer to population structure passed.");
  ;;  #   if (!adam) die ("Null pointer to entity structure passed.");
  
  ;;  # /* Seeding. */
  
  ;;  #   ((double *) adam->chromosome[0]) [0] = random_double (2.0);
  ;;  #   ((double *) adam->chromosome[0]) [1] = random_double (2.0);
  ;;  #   ((double *) adam->chromosome[0]) [2] = random_double (2.0);
  ;;  #   ((double *) adam->chromosome[0]) [3] = random_double (2.0);
  
  ;;  # пока (а может и всегда!) будем делать с ОДНОЙ хромосомой 
  ;;  #
  
  ;;  #$adam set_chromo_gen 0  [random_double 2.0]
  ;;  #$adam set_chromo_gen 1  [random_double 2.0]
  ;;  #$adam set_chromo_gen 2  [random_double 2.0]
  ;;  #$adam set_chromo_gen 3  [random_double 2.0]
  
  (ent_set_chromo_gen_  adam 0  (random_double 2.0))
  (ent_set_chromo_gen_  adam 1  (random_double 2.0))
  (ent_set_chromo_gen_  adam 2  (random_double 2.0))
  (ent_set_chromo_gen_  adam 3  (random_double 2.0))

  ;;  return true;
  true
)
;#-------------------------------------------------------------------------------
;# synopsis:	Generation callback
;# /* static */ boolean 
;# _test_generation_callback (int generation, population *pop)

;# //------------------------------------------------------------------------------
(defun _test_generation_callback (generation pop)

  ;;  #   entity  *best;   /* Fittest entity. */
  ;;  #   best = ga_get_entity_from_rank (pop, 0);
  ;;  # 
  ;;  #set best [$pop get_entity 0]

(let* (

  (best  (pop_get_entity_  pop  0))
  
  ;;  #   printf ("%d: A = %f B = %f C = %f D = %f (fitness = %f)\n",
  ;;  #             generation,
  ;;  #             ((double *) best->chromosome[0]) [0],
  ;;  #             ((double *) best->chromosome[0]) [1],
  ;;  #             ((double *) best->chromosome[0]) [2],
  ;;  #             ((double *) best->chromosome[0]) [3],
  ;;  #             ga_entity_get_fitness (best)
  ;;  #           );
  

  ;;  #set best_fit    [$pop  get_entity_fitness $best]
  ;;  #set best_chromo [$best get_chromosome]

    (best_chromo    (ent_get_chromosome_  best))
    (best_fit       (ENT_FITNESS          best)) ;; [$best cget -fitness]
  
    (A  (elt best_chromo 0 ))  ; [lindex $best_chromo 0]
    (B  (elt best_chromo 1 ))  ; [lindex $best_chromo 1]
    (C  (elt best_chromo 2 ))  ; [lindex $best_chromo 2]
    (D  (elt best_chromo 3 ))  ; [lindex $best_chromo 3]  
  
  )

    (format t "~3S  : A = ~,6F B = ~,6F C = ~,6F D = ~,6F (fitness = ~,6F) ~%"  
            generation 
            A B C D  best_fit)
  
  
  true
))
;# //------------------------------------------------------------------------------
;# //  synopsis:	Generation callback
;# //------------------------------------------------------------------------------
;# boolean 
;# _test_iteration_callback (int iteration, entity *solution)
;# //------------------------------------------------------------------------------
;proc _test_iteration_callback {iteration solution} \
;{

;  #set ch [$solution get_chromosome]
;  set ch [ent_get_chromosome_ $solution]
;  set fi [$solution cget -fitness]

;  #   printf ( "%d: A = %f B = %f C = %f D = %f (fitness = %f)\n",
;  #           iteration,
;  #           ((double *) solution->chromosome[0]) [0],
;  #           ((double *) solution->chromosome[0]) [1],
;  #           ((double *) solution->chromosome[0]) [2],
;  #           ((double *) solution->chromosome[0]) [3],
;  #           solution->fitness );
  
;  set A [lindex $ch 0]
;  set B [lindex $ch 1]
;  set C [lindex $ch 2]
;  set D [lindex $ch 3]
  
;  puts [format "%3d  : A = %f B = %f C = %f D = %f (fitness = %f) "  $iteration \
;          $A $B $C $D $fi]

;  return true
;}
;# //------------------------------------------------------------------------------
;# //  synopsis:     Calculate gradients analytically.
;# //------------------------------------------------------------------------------
;# double 
;# _test_analytical_gradient (population *pop, entity *this_entity, double *params, double *grad)
;# //------------------------------------------------------------------------------
;proc _test_analytical_gradient {pop this_entity params &grad} \
;{

;  USE_REFS

;  #   double    grms = 0.0;	 /* RMS gradient. */
;  set grms  0.0

;  #   double    A, B, C, D;	 /* The parameters. */
;  #   double    g0, g1, g2, g3;
  
;  #   if (! pop)         die ("Null pointer to population structure passed.");
;  #   if (! this_entity) die ("Null pointer to entity structure passed.");
  
;  set A [lindex $params 0]
;  set B [lindex $params 1]
;  set C [lindex $params 2]
;  set D [lindex $params 3]
  
;  #   g0 = A > 0.75+TINY ? -1.0 : ( A < 0.75-TINY ? 1.0 : 0.0 );

;  if {$A > [expr {0.75 + $::TINY}]} {
;    set g0  -1.0 

;  } else {

;    if {$A < [expr {0.75 - $::TINY}]} {
;      set tmp 1.0
;    } else {
;      set tmp 0.0
;    }
;    set g0 $tmp  
;  }

;  set g1 [expr {0.95 - $B}]

;  #   g2 = C > 0.23 ? -SQU(0.23 - C) : SQU(0.23 - C);

;  if {$C > 0.23} {
;    set g2 -[SQU [expr {0.23 - $C}]]
;  } else {
;    set g2  [SQU [expr {0.23 - $C}]]
;  }

;  set g3 [CUBE [expr {0.71 - $D}]] ;# тут бы макросами может сделать?
  

;  #   grad[0] = g0 ;
;  #   grad[1] = g1 ;
;  #   grad[2] = g2 ;
;  #   grad[3] = g3 ;

;  set grad {}

;  lappend grad $g0
;  lappend grad $g1
;  lappend grad $g2
;  lappend grad $g3
  
;  set grms [expr {sqrt ($g0 * $g0 + $g1 * $g1 + $g2 * $g2 + $g3 * $g3)}]

;  return $grms
;}
;# //------------------------------------------------------------------------------
;# //------------------------------------------------------------------------------
;# //  Synopsis:	Test program for GAUL's basic genetic algorithm.
;# //
;# //		This program aims to solve a function of the form
;# //		(0.75-A) + (0.95-B)^2 + (0.23-C)^3 + (0.71-D)^4 = 0
;# //------------------------------------------------------------------------------
;# void 
(defun test_ga ()

;  #   population		*pop;	  /* Population of solutions. */
;  # 
;  parse_opts  population_size max_generations  200 500




(let* (
  (population_size  200) 
  (max_generations  500)

  pop
  )


  (declare (special 
                population_size  max_generations
                ))
  (parse_opts  'population_size 'max_generations)


  (format t "~%")

  (random_seed 23091975)

  ;;  #   pop = ga_genesis_double (
  ;;  #        200,			      /* const int              population_size      */
  ;;  #        1,			      /* const int              num_chromo           */
  ;;  #        4,			      /* const int              len_chromo           */
  ;;  #        _test_generation_callback, /* GAgeneration_hook      generation_hook      */
  ;;  #        NULL,                      /* GAiteration_hook       iteration_hook       */
  ;;  #        NULL,                      /* GAdata_destructor      data_destructor      */
  ;;  #        NULL,                      /* GAdata_ref_incrementor data_ref_incrementor */
  ;;  #        _test_score,	                       /* GAevaluate             evaluate    */
  ;;  #        _test_seed,                         /* GAseed                 seed        */
  ;;  #        NULL,                               /* GAadapt                adapt       */
  ;;  #        ga_select_one_bestof2,              /* GAselect_one           select_one  */
  ;;  #        ga_select_two_bestof2,              /* GAselect_two           select_two  */
  ;;  #        ga_mutate_double_singlepoint_drift, /* GAmutate               mutate      */
  ;;  #        ga_crossover_double_doublepoints,   /* GAcrossover            crossover   */
  ;;  #        NULL,			       /* GAreplace              replace     */
  ;;  #        NULL			               /* vpointer               User data   */
  ;;  #        );
  
  (setf pop (ga_genesis_double                  
             population_size		      
             1			              
             4			              
             '_test_generation_callback          
             NUL			              
             NUL			              
             NUL			              
             '_test_score		              
             '_test_seed		              
             NUL		              
             'ga_select_one_bestof2	      
             'ga_select_two_bestof2	      
             'ga_mutate_double_singlepoint_drift 
             'ga_crossover_double_doublepoints   
             NUL	              
             NUL		              
             ))

  ;;  #   ga_population_set_parameters(
  ;;  #        pop,				/* population      *pop            */
  ;;  #        GA_SCHEME_DARWIN,		/* const ga_scheme_type     scheme */
  ;;  #        GA_ELITISM_PARENTS_SURVIVE,	/* const ga_elitism_type   elitism */
  ;;  #        0.8,				/* double  crossover               */
  ;;  #        0.2,				/* double  mutation                */
  ;;  #        0.0      		        /* double  migration               */
  ;;  #        );

  (ga_population_set_parameters                           
                               pop	                  
                               "GA_SCHEME_DARWIN"	          
                               "GA_ELITISM_PARENTS_SURVIVE" 
                               0.8			  
                               0.2			  
                               0.0)      	          
                               

  ;;  # пока здесь остановимся, осмотримся и распечатаемся:
  ;;  # (похоже инициация-seed еще не выполнялась ?) давай пока тут выполним:
  ;;  #

  (ga_population_seed  pop)

  ;;  #
  ;;  #$pop print
  ;;  #exit
  

  ;;  #   ga_evolution (
  ;;  #        pop,				/* population	*pop            */
  ;;  #        500				/* const int	max_generations */
  ;;  #        );
  
  (ga_evolution   pop max_generations)   
  
  ;;  #   ga_extinction (pop);
  
  (format t "~%")

  ;;  return
))
;# //------------------------------------------------------------------------------
;# //------------------------------------------------------------------------------
;proc main_sd2 {} \
;{

;  #   population	*pop;			/* Population of solutions. */
;  #   entity		*solution;		/* Optimised solution.      */
  
;  random_seed  23091975
  
;  #set population_size   50
;  #set max_iterations  1000

;  parse_opts  population_size max_iterations  50 1000

;  if {$::is_print} {
;    puts ""
;  }

;  #   pop = ga_genesis_double (
;  #        50,			     /* const int              population_size      */
;  #        1,			     /* const int              num_chromo           */
;  #        4,			     /* const int              len_chromo           */
;  #        NULL,		     /* GAgeneration_hook      generation_hook      */
;  #        _test_iteration_callback, /* GAiteration_hook       iteration_hook       */
;  #        NULL,	             /* GAdata_destructor      data_destructor      */
;  #        NULL,	             /* GAdata_ref_incrementor data_ref_incrementor */
;  #        _test_score,		     /* GAevaluate             evaluate             */
;  #        _test_seed,		     /* GAseed                 seed                 */
;  #        NULL,		     /* GAadapt                adapt                */
;  #        NULL,		     /* GAselect_one           select_one           */
;  #        NULL,		     /* GAselect_two           select_two           */
;  #        NULL,		     /* GAmutate               mutate               */
;  #        NULL,		     /* GAcrossover            crossover            */
;  #        NULL,	             /* GAreplace              replace              */
;  #        NULL		             /* vpointer	       User data            */
;  #        );
  
;  set pop [ga_genesis_double                  \
;           $population_size		      \
;           1			              \
;           4			              \
;           NULL			              \
;           _test_iteration_callback           \
;           NULL			              \
;           NULL			              \
;           _test_score		              \
;           _test_seed		              \
;           NULL			              \
;           NULL	                              \
;           NULL	                              \
;           NULL                               \
;           NULL                               \
;           NULL			              \
;           NULL			              \
;          ]

;  #   ga_population_set_gradient_parameters (
;  #        pop,				/* population		*pop           */
;  #        NULL,			/* const GAto_double	to_double      */
;  #        NULL,			/* const GAfrom_double	from_double    */
;  #        _test_analytical_gradient,	/* const GAgradient	gradient       */
;  #        0,				/* const int		num_dimensions */
;  #        0.1				/* const double		step_size      */
;  #        );
  
;  ga_population_set_gradient_parameters  \
;          $pop		                 \
;          NULL			         \
;          NULL			         \
;          _test_analytical_gradient      \
;          0			         \
;          0.1				
          
;  # почему тут надо так искуссствено?
;  # 
;  #ga_population_seed $pop


;  # Evaluate and sort the initial population members (i.e. select best of 
;  # 50 random solutions.
;  #
;  ga_population_score_and_sort  $pop
  
;  if {$::is_print} {
;    $pop print
;    puts ""
;  }

;  # Use the best population member.
;  # 
;  #set solution [ga_get_entity_from_rank  $pop 0]
;  #
;  # сделаем пока так, а то не понятно, как там возвращается и зачем
;  # 
;  set solution NULL
  
;  #   ga_steepestascent_double (
;  #        pop,				/* population		*pop           */
;  #        solution,			/* entity		*solution      */
;  #        1000				/* const int		max_iterations */
;  #        );
  
;     ga_steepestascent_double   \
;          $pop		        \
;          $solution             \
;          $max_iterations       \
         
  
;  #   ga_extinction (pop);  
;  #  exit (EXIT_SUCCESS);

;  if {$::is_print} {
;    puts ""
;  }

;  return
;}
;# /*******************************************************************************
;#   test_de.c

;#   Synopsis:	Test program for GAUL's differential evolution algorithm.

;# 		This program aims to solve a function of the form
;# 		(0.75-A) + (0.95-B)^2 + (0.23-C)^3 + (0.71-D)^4 = 0

;# *******************************************************************************/

;# struct strategies_t
;# {
;#   char			*label; 
;#   ga_de_strategy_type	strategy;
;#   ga_de_crossover_type	crossover;
;#   int			num_perturbed;
;#   double		crossover_factor;
;#   double		weighting_factor;
;#   double		weighting_factor2;
;# };


;# static struct strategies_t strategy[]={
;# ....
;# { NULL, 0, 0, 0, 0.0, 0.0 } };


;# это едиинчный тест для отладки
;# 
(defvar  strategy_test '(
  ( "DE/best/1/bin"            "GA_DE_STRATEGY_BEST"        "GA_DE_CROSSOVER_BINOMIAL"     1  0.8  0.5  0.5 )
  ( "DE/rand-to-best/1/bin"    "GA_DE_STRATEGY_RANDTOBEST"  "GA_DE_CROSSOVER_BINOMIAL"     1  0.8  0.5  0.5 )
  ))

;# это полный список тестов (оригинальный)
;# 
;set strategy_full_origin {

;  { "DE/best/1/exp (DE0)"      GA_DE_STRATEGY_BEST        GA_DE_CROSSOVER_EXPONENTIAL  1  0.8  0.5  0.5 }
;  { "DE/best/1/exp (DE0)"      GA_DE_STRATEGY_BEST        GA_DE_CROSSOVER_EXPONENTIAL  1  0.8  2.0  0.0 }
;  { "DE/best/2/exp"            GA_DE_STRATEGY_BEST        GA_DE_CROSSOVER_EXPONENTIAL  2  0.8  0.5  0.5 }
;  { "DE/best/2/exp"            GA_DE_STRATEGY_BEST        GA_DE_CROSSOVER_EXPONENTIAL  2  0.8  2.0  0.0 }
;  { "'DE/best/3/exp'"          GA_DE_STRATEGY_BEST        GA_DE_CROSSOVER_EXPONENTIAL  3  0.8  0.5  0.5 }
;  { "'DE/best/3/exp'"          GA_DE_STRATEGY_BEST        GA_DE_CROSSOVER_EXPONENTIAL  3  0.8  2.0  0.0 }
;  { "DE/rand/1/exp (DE1)"      GA_DE_STRATEGY_RAND        GA_DE_CROSSOVER_EXPONENTIAL  1  0.8  0.5  0.5 }
;  { "DE/rand/1/exp (DE1)"      GA_DE_STRATEGY_RAND        GA_DE_CROSSOVER_EXPONENTIAL  1  0.8  2.0  0.0 }
;  { "DE/rand/2/exp"            GA_DE_STRATEGY_RAND        GA_DE_CROSSOVER_EXPONENTIAL  2  0.8  0.5  0.5 }
;  { "DE/rand/2/exp"            GA_DE_STRATEGY_RAND        GA_DE_CROSSOVER_EXPONENTIAL  2  0.8  2.0  0.0 }
;  { "'DE/rand/3/exp'"          GA_DE_STRATEGY_RAND        GA_DE_CROSSOVER_EXPONENTIAL  3  0.8  0.5  0.5 }
;  { "'DE/rand/3/exp'"          GA_DE_STRATEGY_RAND        GA_DE_CROSSOVER_EXPONENTIAL  3  0.8  2.0  0.0 }
;  { "DE/rand-to-best/1/exp"    GA_DE_STRATEGY_RANDTOBEST  GA_DE_CROSSOVER_EXPONENTIAL  1  0.8  0.5  0.5 }
;  { "DE/rand-to-best/1/exp"    GA_DE_STRATEGY_RANDTOBEST  GA_DE_CROSSOVER_EXPONENTIAL  1  0.8  2.0  0.0 }
;  { "'DE/rand-to-best/2/exp'"  GA_DE_STRATEGY_RANDTOBEST  GA_DE_CROSSOVER_EXPONENTIAL  2  0.8  0.5  0.5 }
;  { "'DE/rand-to-best/2/exp'"  GA_DE_STRATEGY_RANDTOBEST  GA_DE_CROSSOVER_EXPONENTIAL  2  0.8  2.0  0.0 }

;  { "DE/best/1/bin"            GA_DE_STRATEGY_BEST        GA_DE_CROSSOVER_BINOMIAL     1  0.8  0.5  0.5 }
;  { "DE/best/1/bin"            GA_DE_STRATEGY_BEST        GA_DE_CROSSOVER_BINOMIAL     1  0.8  2.0  0.0 }
;  { "DE/best/2/bin"            GA_DE_STRATEGY_BEST        GA_DE_CROSSOVER_BINOMIAL     2  0.8  0.5  0.5 }
;  { "DE/best/2/bin"            GA_DE_STRATEGY_BEST        GA_DE_CROSSOVER_BINOMIAL     2  0.8  2.0  0.0 }
;  { "'DE/best/3/bin'"          GA_DE_STRATEGY_BEST        GA_DE_CROSSOVER_BINOMIAL     3  0.8  0.5  0.5 }
;  { "'DE/best/3/bin'"          GA_DE_STRATEGY_BEST        GA_DE_CROSSOVER_BINOMIAL     3  0.8  2.0  0.0 }
;  { "DE/rand/1/bin"            GA_DE_STRATEGY_RAND        GA_DE_CROSSOVER_BINOMIAL     1  0.8  0.5  0.5 }
;  { "DE/rand/1/bin"            GA_DE_STRATEGY_RAND        GA_DE_CROSSOVER_BINOMIAL     1  0.8  2.0  0.0 }
;  { "DE/rand/2/bin"            GA_DE_STRATEGY_RAND        GA_DE_CROSSOVER_BINOMIAL     2  0.8  0.5  0.5 }
;  { "DE/rand/2/bin"            GA_DE_STRATEGY_RAND        GA_DE_CROSSOVER_BINOMIAL     2  0.8  2.0  0.0 }
;  { "'DE/rand/3/bin'"          GA_DE_STRATEGY_RAND        GA_DE_CROSSOVER_BINOMIAL     3  0.8  0.5  0.5 }
;  { "'DE/rand/3/bin'"          GA_DE_STRATEGY_RAND        GA_DE_CROSSOVER_BINOMIAL     3  0.8  2.0  0.0 }
;  { "DE/rand-to-best/1/bin"    GA_DE_STRATEGY_RANDTOBEST  GA_DE_CROSSOVER_BINOMIAL     1  0.8  0.5  0.5 }
;  { "DE/rand-to-best/1/bin"    GA_DE_STRATEGY_RANDTOBEST  GA_DE_CROSSOVER_BINOMIAL     1  0.8  2.0  0.0 }
;  { "'DE/rand-to-best/2/bin'"  GA_DE_STRATEGY_RANDTOBEST  GA_DE_CROSSOVER_BINOMIAL     2  0.8  0.5  0.5 }
;  { "'DE/rand-to-best/2/bin'"  GA_DE_STRATEGY_RANDTOBEST  GA_DE_CROSSOVER_BINOMIAL     2  0.8  2.0  0.0 }
;}



;# //------------------------------------------------------------------------------
;# //  synopsis:	Generation callback
;# //------------------------------------------------------------------------------
;# static boolean 
;# test_generation_callback (int generation, population *pop)
;# //------------------------------------------------------------------------------
(defun test_generation_callback (generation pop)

  ;;  #     //entity	*this_entity;	/* Top ranked entity. */
  
  ;;  # /*
  ;;  #  * This is a easy method for implementing randomly selected
  ;;  #  * scaling factor (F in original paper) for each generation, as
  ;;  #  * suggested in:
  ;;  #  *
  ;;  #  * Karaboga D., Okdem, S. "A simple and global optimization algorithm
  ;;  #  * for engineering problems: differential evolution algorithm",
  ;;  #  * Elec. Engin. 12:53-60 (2004).
  ;;  #  *
  ;;  #  * Uncomment, if desired.
  ;;  #  */
  ;;  # /*
  ;;  #   pop->de_params->weighting_factor = random_double_range(-2.0, 2.0);
  ;;  # */
  
  ;;  # /*
  ;;  #  * Write top ranked solution every tenth generation.  Note, that this
  ;;  #  * is not neccesarily the best solution because DE doesn't require
  ;;  #  * the population to be sorted, as genetic algorithms usually do.
  ;;  #  */
  
  (when (= (mod  generation 10) 0)

    (_test_generation_callback  generation pop)
    )
  
  ;;  return true
)
;# //------------------------------------------------------------------------------
;# void 
;# test_de (/* int argc, char **argv */)

;#-------------------------------------------------------------------------------
(defun  strategy_parse_and_print (s 
                       r_label r_strategy r_crossover r_num_perturbed r_crossover_factor 
                       r_weighting_factor r_weighting_factor2)


;  USE_REFS

(let (

  (label             (nth 0 s))
  (strategy          (nth 1 s))
  (crossover         (nth 2 s))
  (num_perturbed     (nth 3 s))
  (crossover_factor  (nth 4 s))
  (weighting_factor  (nth 5 s))
  (weighting_factor2 (nth 6 s))
  )

  (format t "Strategy ~a ; C = ~,6F ; "  label crossover_factor)


(if (/=  weighting_factor weighting_factor2)
    (format t "F = rand( ~f, ~f ) ~%"  weighting_factor weighting_factor2)
    ;;  } else {        
    (format t "F = ~,6F ~%"              weighting_factor)
    )


  ;;  if {$::is_print} { 
  
  ;;    puts "strategy_parse_and_print ......... "
  ;;    puts ""
  
  ;;    puts "   label             =  $label            "   
  ;;    puts "   strategy          =  $strategy         "
  ;;    puts "   crossover         =  $crossover        "
  ;;    puts "   num_perturbed     =  $num_perturbed    "
  
  ;;    puts [format "   crossover_factor  =  %f" $crossover_factor]
  ;;    puts [format "   weighting_factor  =  %f" $weighting_factor]
  ;;    puts [format "   weighting_factor2 =  %f" $weighting_factor2]
  
  ;;    puts ""
  ;;  }
  

  (set r_label             label    )
  (set r_strategy          strategy )
  (set r_crossover         crossover)
  (set r_num_perturbed     num_perturbed    )
  (set r_crossover_factor  crossover_factor )
  (set r_weighting_factor  weighting_factor )
  (set r_weighting_factor2 weighting_factor2)

  ;;`  return
))
;#-------------------------------------------------------------------------------
;#proc test_de {population_size max_generations} {}
;#-------------------------------------------------------------------------------
(defun  test_de (strategy_list)

  ;;  #   population	*pop;	/* Population of solutions.       */
  ;;  #   entity		*best;	/* Fittest entity.                */
  ;;  #   int		i=0;	/* Loop variable over strategies. */
  
(let* (

  (population_size  40) 
  (max_generations  50)

  label crossover num_perturbed crossover_factor 
  weighting_factor weighting_factor2

  pop best_entity best_fit  best_chromo A B C D best
  )


  (declare (special 
            label crossover num_perturbed crossover_factor strategy 
            weighting_factor weighting_factor2
            ))
 
  (declare (special 
                population_size  max_generations
                ))
 
  (parse_opts  'population_size 'max_generations)

  ;;  parse_opts  population_size max_generations  40 50

  
  (random_seed 23091975)
  
  ;;  #   log_init (LOG_NORMAL, NULL, NULL, FALSE);
  (format t "~%")
  
  ;;  foreach s $strategy {
  (loop for s in  strategy_list  do
  
  ;;    strategy_parse_and_print $s \
  ;;                       label strategy crossover num_perturbed crossover_factor \
  ;;                       weighting_factor weighting_factor2
  
    (strategy_parse_and_print  s 
                         'label 'strategy 'crossover 'num_perturbed 'crossover_factor 
                         'weighting_factor 'weighting_factor2)
  
    (setf pop (ga_genesis_double         
             population_size              ; const int              population_size     
             1                            ; const int              num_chromo         
             4                            ; const int              len_chromo        
             'test_generation_callback    ; GAgeneration_hook      generation_hook    
             NUL                          ; GAiteration_hook       iteration_hook 
             NUL                          ; GAdata_destructor      data_destructor 
             NUL                          ; GAdata_ref_incrementor data_ref_incrementor
             '_test_score                 ; GAevaluate             evaluate  
             '_test_seed                  ; GAseed                 seed 
             NUL                          ; GAadapt                adapt 
             NUL                          ; GAselect_one           select_one 
             NUL                          ; GAselect_two           select_two 
             NUL                          ; GAmutate               mutate           
             NUL                          ; GAcrossover            crossover 
             NUL                          ; GAreplace              replace 
             NUL                          ; vpointer               User data
             ))
  

  ;;    # (похоже инициация-seed еще не выполнялась ?) давай пока тут выполним:
  ;;    #
  (ga_population_seed  pop)
  
  ;;    # пока здесь остановимся, осмотримся и распечатаемся:
  ;(pop_print pop)
  ;;    #$pop print
  ;;    #exit
  
  ;;    #  ga_population_set_differentialevolution_parameters (
  ;;    #      pop, strategy[i].strategy, strategy[i].crossover,
  ;;    #      strategy[i].num_perturbed, strategy[i].weighting_factor, strategy[i].weighting_factor2,
  ;;    #      strategy[i].crossover_factor
  ;;    #      );
  
  ;;    ga_population_set_differentialevolution_parameters $pop \
  ;;                                     $strategy $crossover   \
  ;;                                     $num_perturbed $weighting_factor $weighting_factor2 \
  ;;                                     $crossover_factor
  
  
  (ga_population_set_differentialevolution_parameters    
      pop 
      strategy crossover 
      num_perturbed weighting_factor weighting_factor2 
      crossover_factor)

  ;;    # выполняем основной расчет (поиск минимума)
  ;;    #
  (ga_differentialevolution  pop max_generations)			
  
  
  ;;    if {1} {
  ;;      #  //# предполагаем, что уже отсортирована популяция ??
  ;;      #  // 
  (setf best 0)
  
  ;;    } else {
  
  ;;      # ну, а если не отсортирована, воспользуемся полученным расчетом по фитнесу:
  ;;      # 
  ;;      #set best [$pop cget -best] ;# вычисляется после "break"
  
  ;;      # пока придется так по-топорному (т.е. снова здесь повторить поиск лучшего):
  ;;      # 
  ;;      set rank_proc [$pop cget -rank]
  ;;      set best [find_best_solution $pop $rank_proc]
  ;;    }
  

  ;;    #set best_entity [$pop get_entity $best]
  (setf best_entity (pop_get_entity_          pop  best))

  ;;    #set best_fit    [$pop get_entity_fitness $best]
  (setf best_fit    (pop_get_entity_fitness_  pop  best))
  
  ;;    #set best_chromo [$best_entity get_chromosome]
  (setf best_chromo (ent_get_chromosome_  best_entity))
  
  (setf A  (elt best_chromo 0)) ; [lindex $best_chromo 0]
  (setf B  (elt best_chromo 1)) ; [lindex $best_chromo 1]
  (setf C  (elt best_chromo 2)) ; [lindex $best_chromo 2]
  (setf D  (elt best_chromo 3)) ; [lindex $best_chromo 3]
  
  ;;    if {$::is_print} { 
  
  ;;      puts [format "FINAL BEST : numer = $best  fitness = %f" $best_fit]
  ;;      puts ""
  
  ;;      puts [format "   A = %f  ( 0.75 )" $A]
  ;;      puts [format "   B = %f  ( 0.95 )" $B]
  ;;      puts [format "   C = %f  ( 0.23 )" $C]
  ;;      puts [format "   D = %f  ( 0.71 )" $D]
  
  ;;    } else {
  (format t "Final: A = ~,6F B = ~,6F C = ~,6F D = ~,6F (fitness = ~,6F) ~%"   A B C D best_fit)
  (format t "~%")
  ;;    }
  
  ;;    #     ga_extinction (pop);
  
  ) ; loop ??
  
  ;;  #   exit (EXIT_SUCCESS);
  
  (format t "~%")
  
  ;;  return
))
;# //------------------------------------------------------------------------------
;# //------------------------------------------------------------------------------
(defun  main ()

;  global argc argv argv0
;  global strategy_full_origin strategy_simp strategy_test


(let* (
  (argus  (get_argus))
  (argc   (list-length argus))
  mode
  )
  
  
  (when (= argc 0)
    (format t "~%")
    (format t "argc == 0 ~%")
    (format t "~%")
    (exit)
    )


  (setf mode (nth 0 argus)); [lindex $argv 0] ;# имя выч. задачи

  ;;  #set ::is_my_random 0  ;# 1 - это было мое ..

  (cond
   ((equal mode "ga")      (test_ga))
   ;;  elseif {$mode == "de"}       { test_de  $strategy_full_origin } \
   ((equal mode "de_test") (test_de   strategy_test))
   ;;  elseif {$mode == "sd2"}      { main_sd2 } \

   (t (progn
    (format t "~%")
    (format t "ERROR mode = ~s  ~%" mode)
    (format t "~%")
    ))
   )


  ;;  #   if (!strcmp(argv[1], "qsort"))  ga_qsort_test ();
  ;;  #   if (!strcmp(argv[1], "io"))     test_saveload (argc-1, argv+1);
  
  ;;  #   if (!strcmp(argv[1], "simplex1"))  test_simplex_1 ();
  ;;  #   if (!strcmp(argv[1], "simplex2"))  test_simplex_2 ();
  
  ;;  #   if (!strcmp(argv[1], "sd1")) main_sd1 ();
  ;;  #   if (!strcmp(argv[1], "sd2")) main_sd2 ();
  
  ;;  #if {$mode == "de"}   {test_de $population_size $max_generations}
  ;;  #   if (!strcmp(argv[1], "moga")) test_moga ();
  
  ;;  #   exit (EXIT_SUCCESS);
))
;# //------------------------------------------------------------------------------

(main)

;#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!1
;# 
;# 0.75  0.95  0.23  0.71 
;# 
;#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!1



;# //------------------------------------------------------------------------------
;# kjkljlkjkljkljkljlklk;lk lk;lk;lkkljkkljkljklj
;# //------------------------------------------------------------------------------

;# // ga_x_tester.tl  de 

;# // ga_x_tester  ga 
;# // ga_x_tester  moga 
;# // ga_x_tester  sd1 
;# // ga_x_tester  sd2
;# // ga_x_tester  simplex1
;# // ga_x_tester  simplex2 

;# //------------------------------------------------------------------------------
