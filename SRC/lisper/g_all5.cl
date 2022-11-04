; -*-   mode: lisp ; coding: koi8   -*- ----------------------------------------

;-------------------------------------------------------------------------------
;# Josef Knecht @ Copyright 

;#-------------------------------------------------------------------------------

;lappend auto_path \
;  [file join [file dirname [info script]] "I"] ;# "../common"

;#source "../common/a-comm.tl"
;package require common 1.0

;#-------------------------------------------

;source "I/a-rand.tl"
;#source "../common/a-rand.tl"

;#source "./f-comm.tl"

;source "f-sort.tl"

;source "h-core.tl"
;source "h-cros.tl"

;#source "ga_de.tl"

;#-------------------------------------------

;(load  "EXT/LSP/src/a-comm.cl")
;(load  "EXT/LSP/src/a-rand.cl")

(load  "a-comm.cl")
(load  "a-rand.cl")

;#-------------------------------------------
;#-------------------------------------------

(load  "f-sort.cl")

(load  "l-core.cl")
(load  "l-cros.cl")

;(load  "h-diff.cl")

;#-------------------------------------------------------------------------------
;# //  Score solution (Normalised RMSD deviation from values
;# //  of '5' for all parameters).
;# //------------------------------------------------------------------------------
;# static boolean 
;# all5s_score (population *pop, entity *entity)
;# //------------------------------------------------------------------------------
(defun all5s_score (pop entity) 

(let (

  ;;  #   int		allele;
  ;;  #   int		k;
      
  ;;  #   entity->fitness = 0.0;
  ;;  #set fitness 0.0

  (fitness 0)
  (len     (POP_LEN_CHROMOSOMES pop))
  allele
  )

  ;;  #   // Loop over alleles in chromosome
  ;;  #   // 
  
  ;;  for {set k 0} {$k < [$pop cget -len_chromosomes]} {incr k} \
  (loop for k  from 0 to (1- len) do


    ;;    # allele = ((int *) entity->CH)[k];
    ;;    # entity->fitness += ((5-allele) * (5-allele));

    (setf   allele (ent_get_chromo_gen_  entity  k))

    ;;    incr fitness [expr {(5 - $allele) * (5 - $allele)}]
    )
  

  ;;  #   entity->fitness = sqrt (entity->fitness);
  (setf fitness  (sqrt fitness)) ; [expr {sqrt ($fitness)}]
  
  ;;  #   // Normalize fitness so larger positive values are better
  ;;  #   //
  ;;  #   entity->fitness = 1.0 / (1.0 + entity->fitness);

  (setf fitness  (/ 1.0 (+ 1.0 fitness))) ; [expr  {1.0 / (1.0 + $fitness)}]
  ;;  #puts "all5s_score : fitness = $fitness"

  (ga_entity_set_fitness  entity fitness) 


  true ;;  return true

))
;# //------------------------------------------------------------------------------
;# // Entity initialisation.

;# static boolean 
;# all5s_seed (population *pop, entity *entity)

;# //------------------------------------------------------------------------------
(defun all5s_seed (pop entity)

  ;;  # int  point; /* Index of allele to seed */
  
(let (

  (len  (POP_LEN_CHROMOSOMES pop))
  )

  ;;  for {set point 0} {$point < [$pop cget -len_chromosomes]} {incr point} \
  ;;  {
  (loop for point  from 0 to (1- len) do

    ;;    #$entity set_chromo_gen  $point [random_int 11]
    ;;    ent_set_chromo_gen_ $entity  $point [random_int 11]
    (ent_set_chromo_gen_  entity point  (random_int 11))

    ;;    #$entity configure -ch_form " %02d"
    ;;    # БУДЕМ ЗАДАВАТЬ ЭТОТ параметр при создании, т.е. ga_entity_setup
  )
  

  ;;  return true
  true
))
;# //------------------------------------------------------------------------------
;# // Mutation of a single parameter with wrapping 0<->10.
;# //------------------------------------------------------------------------------
;# static void 
;# all5s_mutate (population *pop, entity *father, entity *son)

;# //------------------------------------------------------------------------------
;proc all5s_mutate {pop father son}  {

;  #   int   i;                             /* Loop variable over all chromosomes */
;  #   int   point;                         /* Index of allele to mutate          */
;  #   int   dir = random_boolean()?-1:1;   /* The direction of drift.            */
  
;  if {[random_boolean]} {
;    set dir -1
;  } else {
;    set dir  1
;  }

;  #puts -nonewline stderr "  all5s_mutate : dir = $dir"

;  #   // Sanity check
;  #   // 
;  #   if (!father || !son)
;  #     die ("Null pointer to entity structure passed");
  
;  set len_chromosomes [$pop cget -len_chromosomes]

;  #   // Select mutation locus
;  #   // 
;  set point [random_int $len_chromosomes]
  
;  #   // Copy genome from father
;  #   // 
;  #   for (i=0; i<pop->len_chromosomes; i++)
;  #     ((int *)son->CH)[i] = ((int *)father->CH)[i];
  
;  #set son_CH [$father get_chromosome]
;  set son_CH [ent_get_chromosome_ $father]

;  #   //
;  #   // Mutate by tweaking a single allele.
;  #   //
;  #   ((int *)son->CH)[point] += dir;

;  set  gen [lindex $son_CH $point]
;  incr gen $dir
  
;  #puts stderr "  point = $point  gen = $gen"

;  #   if      (((int *) son->CH)[point] > 10)
;  #     ((int *) son->CH)[point] = 0;
;  #
;  #   else if (((int *) son->CH)[point] < 0)
;  #     ((int *) son->CH)[point] = 10;

;  if       {$gen > 10} {
;    set gen 0
;  } elseif {$gen <  0} {
;    set gen 10
;  }

;  lset son_CH $point $gen ;# смутировали хромосому-список

;  ent_set_chromosome_ $son $son_CH ;# и записали ее в сына

;  return
;}
;# //------------------------------------------------------------------------------
;#-------------------------------------------------------------------------------
;# похожий есть в l_strugle.tl
;#-------------------------------------------------------------------------------
;proc parse_opts_3 {&par1    &par2    &par3  \
;                     def_par1 def_par2 def_par3 {ind 1}} {

;  #set ind 1 ;# с какого параметра начинаем обработку (чтение)

;  USE_REFS

;  global argc argv argv0

;  set ::is_print 0

;  if  {$argc == $ind} { 
;    # вызов без параметров, только с одним mode
    
;    set par1  $def_par1
;    set par2  $def_par2
;    set par3  $def_par3
 
;  } else {

;    set par1 [lindex $argv $ind]  ; incr ind 
;    set par2 [lindex $argv $ind]  ; incr ind 
;    set par3 [lindex $argv $ind]  ; incr ind 

;    if  {$argc == [expr {$ind + 1}]}    {
;      set ::is_print 1
;      #set ::target_text $::target_text_simp
;    }
;  }

;  return
;}
;#-------------------------------------------------------------------------------
(defun parse_opts_3 (  r_par1   r_par2   r_par3 
                     def_par1 def_par2 def_par3 
                     &optional (ind 1))

(let* (
  (argus  (get_argus))
  (argc   (list-length argus))
  )

  ;(format t "argc = ~s ~%" argc)
  (setf __is_print false)
  
  (if  (= argc ind) 

      (progn
        ;;    # вызов без параметров, только с одним mode 
        (set r_par1  def_par1) ; пишем в "символ"
        (set r_par2  def_par2)
        (set r_par3  def_par3)
        )
      (progn
        (set r_par1 (parse-integer (nth ind argus))) (incf ind) 
        (set r_par2 (parse-integer (nth ind argus))) (incf ind) 
        (set r_par3 (parse-integer (nth ind argus))) (incf ind) 

        (when (= argc (+ ind 1))
          (setf __is_print true)
          )
        )
  )
  
))
;# //------------------------------------------------------------------------------
;# //  all5s.c

;# //		This searches for a set of values all equalling '5', 
;# //		with allowed bounds of 0 to 10 inclusive as imposed
;# //		by custom chromosomes.

;# //		It is an example to demonstrate how to impose bounds
;# //		on the chromosome values by using custom seed and
;# //		mutation operator functions.  Compare this to the
;# //		accompanying all5s_allele_ranges.c

;# //------------------------------------------------------------------------------
(defun  _1_main () 

  ;;  #   population  *pop = NULL;	      /* Population of solutions.               */
  ;;  #   char        *beststring = NULL; /* Human readable form of best solution.  */
  ;;  #   size_t       beststrlen = 0;    /* Length of beststring.                  */
  
  
  ;;  #   int len_chromo, population_size, max_generations;
  
  ;;  #   parse_opts_len (argc, argv, &len_chromo, &population_size, &max_generations,  
  ;;  #                   100, 200, 250);
  
  ;;  #parse_opts_len  len_chromo population_size max_generations 100 200 250


(let* (
  ;(population_size  200) 
  ;(max_generations  500)

  pop best beststring best_entity
  )


  (declare (special 
                len_chromo population_size  max_generations
                ))

  (parse_opts_3  'len_chromo 'population_size 'max_generations 
                 100 200 250)
  

  (random_seed 20092004) ;  random_seed  20092004
  
;  #   pop = ga_genesis_integer (
;  #      population_size,	/* const int              population_size      */
;  #      1,		        /* const int              num_chromo           */
;  #      len_chromo,		/* const int              len_chromo           */
;  #      NULL,			/* GAgeneration_hook      generation_hook      */
;  #      NULL,			/* GAiteration_hook       iteration_hook       */
;  #      NULL,			/* GAdata_destructor      data_destructor      */
;  #      NULL,			/* GAdata_ref_incrementor data_ref_incrementor */
;  #      all5s_score,		/* GAevaluate             evaluate             */
;  #      all5s_seed,		/* GAseed                 seed                 */
;  #      NULL,			/* GAadapt                adapt                */
;  #      ga_select_one_sus,	/* GAselect_one           select_one           */
;  #      ga_select_two_sus,	/* GAselect_two           select_two           */
;  #      all5s_mutate,		/* GAmutate               mutate               */
;  #      ga_crossover_integer_singlepoints, /* GAcrossover    crossover        */
;  #      NULL,			/* GAreplace	  	  replace              */
;  #      NULL			/* vpointer		  User data            */
;  #      );
  
  (setf pop (ga_genesis_integer                  
             population_size		      
             1			              
             len_chromo			              
             NUL          
             NUL			              
             NUL			              
             NUL			              
             'all5s_score		              
             'all5s_seed		              
             NUL		              
             'ga_select_one_sus	      
             'ga_select_two_sus	      
             'all5s_mutate 
             'ga_crossover_integer_singlepoints  
             NUL	              
             NUL		              
             ))


  (setf (POP_CH_FORM  pop)  " %02d")   

  ;(format t "01 ...................................... ~%")

  (ga_population_set_parameters                           
                               pop	                  
                               "GA_SCHEME_DARWIN"	          
                               "GA_ELITISM_PARENTS_SURVIVE" 
                               0.8			  
                               0.05			  
                               0.0)      	          
                               
  ;(format t "02 ...................................... ~%")

  (when __is_print 

  ;(format t "03 ...................................... ~%")

    ;;    # пока здесь остановимся, осмотримся и распечатаемся:
    ;;    # (похоже инициация-seed еще не выполнялась ?) давай пока тут выполним:
    ;;    #
    ;;    ga_population_seed $pop
    (ga_population_seed  pop)
    
    ;;    #
    ;;    $pop print
    (pop_print pop)
    ;;    #exit
    )


  ;(format t "04 ...................................... ~%")

  ;;  #   ga_evolution(
  ;;  #      pop,			/* population                 *pop */
  ;;  #      max_generations	/* const int       max_generations */
  ;;  #      );
  
  (ga_evolution   pop max_generations)   

  ;;  #$pop print
  
  ;;  #   // Display final solution
  ;;  #   // 

  (format t "The final solution was: ~%")

  ;;  #   beststring = ga_chromosome_integer_to_string (pop, ga_get_entity_from_rank(pop,0), 
  ;;  #                                                 beststring, &beststrlen);

  ;;  set best_entity [ga_get_entity_from_rank $pop 0]
  (setf best  (pop_get_entity_  pop  0))

  ;;  #set beststring [$best_entity get_chromosome]

;  set beststring  [ent_get_chromosome_ $best_entity]
  (setf beststring (ent_get_chromosome_  best_entity))

  ;;  #   printf ("%s\n", beststring);
;  puts $beststring
  (format t "~s ~%" beststring)

;  puts [format "With score = %f" [$best_entity cget -fitness]]  
  (format t "With score = ~f ~%" (ENT_FITNESS best_entity))

  ;;  #   // Free memory
  ;;  #   //
  ;;  #   ga_extinction (pop);
  ;;  #   s_free (beststring);
  
  ;;  return 1
))
;# //------------------------------------------------------------------------------
;# // 
;# //  all5s_allele_ranges.c
;# //
;# //		This searches for a set of values all equalling '5', 
;# //		with allowed bounds of 0 to 10 inclusive, using
;# //		built-in features only.
;# //
;# //		This example demonstrates the
;# //		ga_population_set_allele_min_integer() and
;# //		ga_population_set_allele_max_integer() functions.
;# // 
;#-------------------------------------------------------------------------------
;# //------------------------------------------------------------------------------
;proc _2_main {} \
;{

;  #   population  *pop = NULL;	   /* Population of solutions.                 */
;  #   char	      *beststring = NULL;  /* Human readable form of best solution.    */
;  #   size_t       beststrlen = 0;	   /* Length of beststring.                    */
  
;  #   int len_chromo, population_size, max_generations;
  
;  #   parse_opts_len (argc, argv, &len_chromo, &population_size, &max_generations,  
;  #                   100, 200, 250);
  
;  parse_opts_3  len_chromo population_size max_generations 100 200 250

;  random_seed  20092004

;  #   pop = ga_genesis_integer (
;  #      population_size,		/* const int              population_size      */
;  #      1,				/* const int              num_chromo           */
;  #      len_chromo,		/* const int              len_chromo           */
;  #      NULL,			/* GAgeneration_hook      generation_hook      */
;  #      NULL,			/* GAiteration_hook       iteration_hook       */
;  #      NULL,			/* GAdata_destructor      data_destructor      */
;  #      NULL,			/* GAdata_ref_incrementor data_ref_incrementor */
;  #      all5s_score,		/* GAevaluate             evaluate             */
;  #      ga_seed_integer_random,	/* GAseed                 seed                 */
;  #      NULL,			/* GAadapt                adapt                */
;  #      ga_select_one_sus,		/* GAselect_one           select_one           */
;  #      ga_select_two_sus,		/* GAselect_two           select_two           */
;  #      ga_mutate_integer_singlepoint_drift,  /* GAmutate               mutate    */
;  #      ga_crossover_integer_singlepoints,    /* GAcrossover            crossover */
;  #      NULL,			/* GAreplace		replace                */
;  #      NULL			/* vpointer		User data              */
;  #      );

;  set pop [ga_genesis_integer   \
;             $population_size   \
;             1		        \
;             $len_chromo	\
;             NULL               \
;             NULL               \
;             NULL               \
;             NULL               \
;             all5s_score        \
;             ga_seed_integer_random \
;             NULL               \
;             ga_select_one_sus	\
;             ga_select_two_sus	\
;             ga_mutate_integer_singlepoint_drift \
;             ga_crossover_integer_singlepoints   \
;             NULL               \
;             NULL               \
;          ]

;  $pop configure -ch_form " %02d" ;# 

;  ga_population_set_allele_min_integer  $pop  0
;  ga_population_set_allele_max_integer  $pop 10

;  #   ga_population_set_parameters (
;  #      pop,			/* population                 *pop */
;  #      GA_SCHEME_DARWIN,		/* const ga_scheme_type     scheme */
;  #      GA_ELITISM_PARENTS_SURVIVE,/* const ga_elitism_type   elitism */
;  #      0.8,			/* double		 crossover */
;  #      0.05,			/* double		  mutation */
;  #      0.0              		/* double		 migration */
;  #      );

;  ga_population_set_parameters                            \
;                               $pop	                  \
;                               GA_SCHEME_DARWIN	          \
;                               GA_ELITISM_PARENTS_SURVIVE \
;                               0.8			  \
;                               0.05			  \
;                               0.0      	          
  
;  #   ga_evolution(
;  #      pop,			/* population                 *pop */
;  #      max_generations	        /* const int       max_generations */
;  #      );
  
;  ga_evolution  $pop $max_generations   

;  #$pop print

;  #   // Display final solution
;  #   // 
;  puts "The final solution was:"

;  #   beststring = ga_chromosome_integer_to_string (pop, ga_get_entity_from_rank(pop,0), 
;  #                                                 beststring, &beststrlen);

;  set best_entity [ga_get_entity_from_rank $pop 0]
;  #set beststring [$best_entity get_chromosome]
;  set beststring [ent_get_chromosome_ $best_entity]

;  #   printf ("%s\n", beststring);
;  puts $beststring

;  #   printf ("With score = %f\n", ga_get_entity_from_rank(pop,0)->fitness);
;  puts [format "With score = %f" [$best_entity cget -fitness]]
    
;  #   // Free memory
;  #   // 
;  #   ga_extinction (pop);
;  #   s_free (beststring);

;  return 1
;}
;# //******************************************************************************
;# //------------------------------------------------------------------------------
(defun  main ()

  ;;  global argc argv argv0

(let* (
  (argus  (get_argus))
  ;(argc   (list-length argus))
  mode
  )
  
  (format t "~%")
  
  ;;  #   if (argc < 2 ) 
  ;;  #     exit (EXIT_SUCCESS);
  
  (setf mode (nth 0 argus)); [lindex $argv 0] ;# имя выч. задачи
  

  (cond
   ((equal mode  "_1")      (_1_main))
   ((equal mode  "_2")      (_2_main))

   (t (progn
    (format t "~%")
    (format t "ERROR mode = ~s  ~%" mode)
    (format t "~%")
    ))
   )

    (format t "~%")
  
))
;# //-----------------------------------------------------------------------------


(main)


;# //-----------------------------------------------------------------------------

; TODO:

; cl h_all5.cl _1  11 10 10 
; cl h_all5.cl _1  11 10 10  1

; ga_select_two_sus

;# //------------------------------------------------------------------------------
;# //******************************************************************************


