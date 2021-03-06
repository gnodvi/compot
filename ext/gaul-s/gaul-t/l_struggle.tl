#!/bin/sh
# \
exec tclsh "$0" ${1+"$@"}

#-------------------------------------------------------------------------------
# Josef Knecht @ Copyright 
#-------------------------------------------------------------------------------

#source "../gaul-l/a-comm.tl"
#source "../common/a-comm.tl"

#-------------------------------------------

set COMPOT "./COMPOT"

set auto_path [linsert $auto_path 0 $COMPOT]

#package require common 1.0

package require compot::common 1.0

#-------------------------------------------

source "c_random_util.c.tl"
source "c_random_util.h.tl"
source "gaul.h.tl"

source "c_all_util.h.tl"
source "c_all_util.c.tl"

source "ga_core.tl"
source "ga_core-select.tl"
source "ga_core_crosser.tl"
source "ga_core_mutate.tl"
source "ga_core_seed.tl"

source "ga_de.tl"
source "ga_optim.tl"
source "ga_utility.tl"
source "ga_chromo.tl"
source "ga_qsort.tl"

source "ga_deterministiccrowding.tl"
source "ga_core_compare.tl"

#-------------------------------------------------------------------------------
# //------------------------------------------------------------------------------
#   struggle_ALL.c

#   Synopsis:	Test/example program for GAUL.


# 		This program aims to generate the final sentence from
# 		Chapter 3 of Darwin's "The Origin of Species",
# 		entitled "Struggle for Existence".

# //------------------------------------------------------------------------------

# /*
#  * Includes
#  */
# #include "gaul.h"

# //------------------------------------------------------------------------------

# /*
#  * The solution string.
#  */

# static char *target_text = 

set ::target_text_full  "When we reflect on this struggle, we may console ourselves with the full belief, that the war of nature is not incessant, that no fear is felt, that death is generally prompt, and that the vigorous, the healthy, and the happy survive and multiply."

set ::target_text_simp  "When we reflect on this struggle"


#set ::target_text  $::target_text_simp
set ::target_text  $::target_text_full

#-------------------------------------------------------------------------------
proc parse_opts_3 {&par1    &par2    &par3  \
                def_par1 def_par2 def_par3} {

  USE_REFS

  global argc argv argv0

  set ::is_print 0

  if  {$argc == 1} { 
    # вызов без параметров, только с одним mode
    
    set par1  $def_par1
    set par2  $def_par2
    set par3  $def_par3
 
  } else {

    set par1 [lindex $argv 1]
    set par2 [lindex $argv 2]
    set par3 [lindex $argv 3]

    if  {$argc == 5}    {
      set ::is_print 1
      set ::target_text $::target_text_simp
    }
  }

  return
}
# //------------------------------------------------------------------------------


# long _3_evaluation_count = 0;	/* Number of fitness evaluations performed. */
set ::_3_evaluation_count 0

# //------------------------------------------------------------------------------
# static boolean 
# struggle_score (population *pop, entity *entity)
# //------------------------------------------------------------------------------
proc struggle_score {pop entity}  {

  #   int		k;		/* Loop variable over all alleles. */
  
  #   entity->fitness = 0.0;
  set fi 0.0
  
  #   /* Loop over alleles in chromosome. */

  for {set k 0} {$k < [$pop cget -len_chromosomes]} {incr k} \
  {
  
    set source_char_num  [ent_get_chromo_gen_ $entity  $k]

    set target_char      [string index $::target_text  $k]
    set target_char_num  [scan   $target_char "%c"]

    #     if ( ((char *)entity->CH)[k] == target_text[k])
    #       entity->fitness += 1.0;

    if {0} {
    puts "source_char_num = $source_char_num"
    puts "target_char     = $target_char"
    puts "target_char_num = $target_char_num"
    puts ""
    }
    
    if {$source_char_num == $target_char_num} {
      set fi [expr $fi + 1.0]
    }

    #     /*
    #       * Component to smooth function, which helps a lot in this case:
    #       * Comment it out if you like.
    #       */
    #     entity->fitness += (127.0 - abs ((int)(((char *)entity->CH)[k] - target_text[k]))) / 50.0;

    set ab [expr abs ($source_char_num - $target_char_num)]
    set fi [expr $fi + (127.0 - $ab) / 50.0]
  }

  ga_entity_set_fitness $entity $fi

  return true
}
# //------------------------------------------------------------------------------
# static boolean 
# //------------------------------------------------------------------------------
proc _3_struggle_score {pop entity} \
{

  struggle_score  $pop $entity

  incr ::_3_evaluation_count

  return true
}
# //------------------------------------------------------------------------------


# //------------------------------------------------------------------------------
# //  struggle_adaptation()
# //  synopsis:	Adapt solution by making a single hill-climbing step
# //		for a randomly selected allele.
# //------------------------------------------------------------------------------
# static entity *
# struggle_adaptation (population *pop, entity *child)
# //------------------------------------------------------------------------------
proc allele_incr {adult allele incr_val}  \
{

  set oldval [ent_get_chromo_gen_ $adult  $allele]

  #$adult set_chromo_gen $allele [expr $oldval + $incr_val]
  ent_set_chromo_gen_ $adult $allele [expr $oldval + $incr_val]

}
# //------------------------------------------------------------------------------
proc struggle_adaptation {pop child}  \
{
  #   entity	*adult;		/* Adapted solution.         */
  #   int	allele;		/* Randomly selected allele. */
  
  # /*
  #  * We must generate a new solution by copying the original solution.
  #  * This function copys all genomic, and if appropriate, phenomic data.
  #  * It is never safe to adapt the solution in place.
  #  */

  set adult [ga_entity_clone $pop $child]
  
  # /* Make point mutation. */
  set allele [random_int [strlen $::target_text]]

  #   ((char *)adult->CH)[allele]++;
  allele_incr $adult $allele +1

  struggle_score $pop $adult
  
  if {[$adult cget -fitness] > [$child cget -fitness]} {
    return $adult
  }
  
  # /* Searching in that previous direction didn't help. */

  #   ((char *)adult->CH)[allele] -= 2;
  allele_incr $adult $allele -2

  struggle_score $pop $adult
  
  if {[$adult cget -fitness] > [$child cget -fitness]} {
    return $adult
  }
  
  # /* We must already be at a maxima. */

  #   ((char *)adult->CH)[allele]++;
  allele_incr $adult $allele +1

  #   adult->fitness = child->fitness;
  $adult configure -fitness [$child cget -fitness]
  
  return $adult
}
# //------------------------------------------------------------------------------
# static entity *
# _3_struggle_adaptation (population *pop, entity *child)
# //------------------------------------------------------------------------------
proc _3_struggle_adaptation {pop child} \
{
  #   entity	*adult;		/* Adapted solution. */
  #   int	allele;		/* Randomly selected allele. */
  
  #   /*
  #     * We must generate a new solution by copying the original solution.
  #     * This function copys all genomic, and if appropriate, phenomic data.
  #     * It is never safe to adapt the solution in place.
  #     */
  set adult [ga_entity_clone $pop $child]
  
  #   /* Make point mutation. */
  set allele [random_int [strlen $::target_text]]

  
  #   ((char *)adult->CH)[allele]++;
   allele_incr $adult $allele +1
 
  #   //mgena !!!!!!!!!!!1
  #   //_3_struggle_score (pop, adult);
  
  struggle_score $pop $adult
  incr ::_3_evaluation_count
  
  if {[$adult cget -fitness] > [$child cget -fitness]} {
    return $adult
  }
  
  #   /* Searching in that previous direction didn't help. */
  #   ((char *)adult->CH)[allele] -= 2;
   allele_incr $adult $allele -2
  
  #   //mgena !!!!!!!!!!!1
  #   //_3_struggle_score (pop, adult);
  
  struggle_score $pop $adult
  incr ::_3_evaluation_count
  
  if {[$adult cget -fitness] > [$child cget -fitness]} {
    return $adult
  }
  
  #   /* We must already be at a maxima. */
  
  #   ((char *)adult->CH)[allele]++;
  allele_incr $adult $allele +1

  #   adult->fitness = child->fitness;
  $adult configure -fitness [$child cget -fitness]

  return $adult
}
# //------------------------------------------------------------------------------
# //  struggle.c
# //
# //		This program is fairly lean, showing how little
# //		application code is needed when using GAUL.
# //		This example is explained in docs/html/tutorial/simple.html
# //
# //		This example is explained in docs/html/tutorial/simple.html
# //
# //------------------------------------------------------------------------------
proc  strlen {str} {


  #return [llength $str]
  return [string length $str]
}
# //------------------------------------------------------------------------------
proc  _1_main {} {


  # TODO :
  #
  # - l_struggle.tl 1  5 1
  #
  # - наверное более правильно вместо чисто строк использовать в обшем виде списки
  #   в т.ч. списки из целых, поэтому сначала найти похожий тест (для целых)


  #set  num_runs        3
  #set population_size 120  
  #set max_generations 500

  parse_opts_3   num_runs population_size max_generations  3 120 500


  #   int		i;			/* Loop over runs.                       */
  #   population	*pop=NULL;		/* Population of solutions.              */
  #   char		*beststring=NULL;	/* Human readable form of best solution. */
  #   size_t	beststrlen=0;		        /* Length of beststring.                 */
  set beststrlen 0

  #   //mgena  for (i=0; i<50; i++)
  #
  for {set i 0} {$i < $num_runs} {incr i} {

    random_seed $i
  
  #     pop = ga_genesis_char (
  #        120,			          /* const int              population_size      */
  #        1,			          /* const int              num_chromo           */
  #        (int) strlen(target_text),     /* const int              len_chromo           */
  #        NULL,		  	  /* GAgeneration_hook      generation_hook      */
  #        NULL,			  /* GAiteration_hook       iteration_hook       */
  #        NULL,			  /* GAdata_destructor      data_destructor      */
  #        NULL,			  /* GAdata_ref_incrementor data_ref_incrementor */
  #        struggle_score,	 	  /* GAevaluate             evaluate             */
  #        ga_seed_printable_random,      /* GAseed                 seed                 */
  #        NULL,			  /* GAadapt                adapt                */
  #        ga_select_one_sus,	          /* GAselect_one           select_one           */
  #        ga_select_two_sus,	          /* GAselect_two           select_two           */
  #        ga_mutate_printable_singlepoint_drift,	/* GAmutate               mutate */
  #        ga_crossover_char_allele_mixing,	/* GAcrossover      crossover            */
  #        NULL,			  /* GAreplace		    replace              */
  #        NULL			          /* vpointer		    User data            */
  #        );
  
    set len_chromo [strlen $::target_text] 
    #        puts ""
    #        puts "len_chromo = $len_chromo"
    #        puts ""
    
    set  pop [ga_genesis_char                            \
                $population_size			 \
                1			                 \
                [strlen $::target_text]                  \
                NULL		  	                 \
                NULL			                 \
                NULL			                 \
                NULL                                     \
                struggle_score	 	                 \
                ga_seed_printable_random                 \
                NULL			                 \
                ga_select_one_sus	                 \
                ga_select_two_sus	                 \
                ga_mutate_printable_singlepoint_drift    \
                ga_crossover_char_allele_mixing          \
                NULL			                 \
                NULL			                 \
               ]
  
    #$pop configure -ch_form " %03d" ;# 
    $pop configure -ch_form "%c" ;# 
    
    #     ga_population_set_parameters (
    #        pop,			   /* population                 *pop */
    #        GA_SCHEME_DARWIN,       /* const ga_scheme_type     scheme */
    #        GA_ELITISM_PARENTS_DIE, /* const ga_elitism_type   elitism */
    #        0.9,			   /* double  crossover               */
    #        0.2,			   /* double  mutation                */
    #        0.0              	   /* double  migration               */
    #        );
    
    ga_population_set_parameters  \
      $pop	                  \
      GA_SCHEME_DARWIN	          \
      GA_ELITISM_PARENTS_DIE      \
      0.9			  \
      0.2			  \
      0.0      	          

    # пока здесь остановимся, осмотримся и распечатаемся:
    # (похоже инициация-seed еще не выполнялась ?) давай пока тут выполним:
    #
    #ga_population_seed $pop
    #
    #$pop print
    #exit
    
    
    #     ga_evolution (
    #        pop,			   /* population      *pop            */
    #        500			   /* const int       max_generations */
    #        );
    
    ga_evolution  $pop $max_generations   
    
    puts [format "The solution with seed = %d was:" $i ]
    #     beststring = ga_chromosome_char_to_string (pop, ga_get_entity_from_rank (pop, 0), 
    #                                                beststring, &beststrlen);
    
    set best_entity [ga_get_entity_from_rank $pop 0]

    #set beststring  [$best_entity get_chromosome]    
    #   printf ("%s\n", beststring);
    #puts $beststring

    #$best_entity  print_ch ""
    ent_print_ch_ $best_entity ""

    puts ""
    
    #     printf ("With score = %f\n", ga_entity_get_fitness (ga_get_entity_from_rank (pop, 0)));
    #     printf ("\n");
    puts [format "With score = %f" [$best_entity cget -fitness]]
    puts ""
    
    #     ga_extinction (pop);
  }
  
  #   s_free (beststring);
  
  #   //exit (EXIT_SUCCESS);
  return (1);
}
# //------------------------------------------------------------------------------
# //  struggle2.c
# //
# //  This program demonstrates the alternative evolutionary
# //  schemes available within GAUL:
# //  o Darwinian Evolution.
# //  o Baldwinian Evolution.
# //  o Lamarckian Evolution.
# //
# //  This example is explained in docs/html/tutorial2.html
# //
#-------------------------------------------------------------------------------
proc parse_opts_4 {&par1    &par2    &par3    &par4  \
                def_par1 def_par2 def_par3 def_par4} {

  USE_REFS

  global argc argv argv0

  set ::is_print 0

  if  {$argc == 1} { 
    # вызов без параметров, только с одним mode
    
    set par1  $def_par1
    set par2  $def_par2
    set par3  $def_par3
    set par4  $def_par4
 
  } else {

    set par1 [lindex $argv 1]
    set par2 [lindex $argv 2]
    set par3 [lindex $argv 3]
    set par4 [lindex $argv 4]

    if  {$argc == 6}    {
      set ::is_print 1
      set ::target_text $::target_text_simp
    }
  }

  return
}
# //------------------------------------------------------------------------------
# void evolution_print_best (population  *pop, int max_generations, char *name)
# //------------------------------------------------------------------------------
proc evolution_print_best {pop max_generations name}  \
{

  #   char   *beststring = NULL;  /* Human readable form of best solution. */
  #   size_t  beststrlen = 0;     /* Length of beststring.                 */

  set beststrlen 0
  
  #   ga_evolution (
  #     pop,			  /* population          *pop              */
  #     max_generations		  /* const int           max_generations   */
  #     );
  
  ga_evolution  $pop $max_generations   

  set best_entity [ga_get_entity_from_rank $pop 0]
  set best_fitnes [$best_entity cget -fitness] 

  #   printf ("The final solution with %s evolution with score %f was: \n",  name,
  #           ga_get_entity_from_rank (pop, 0)->fitness);
  
  puts [format "The final solution with %s evolution with score %f was:" $name $best_fitnes]

  #   beststring = ga_chromosome_char_to_string (pop, ga_get_entity_from_rank (pop, 0), 
  #                                              beststring, &beststrlen);
  #   printf ("%s\n", beststring);
  #   printf ("\n");

  #$best_entity  print_ch ""
  ent_print_ch_ $best_entity ""

  puts ""
  puts ""

  #exit
}
# //------------------------------------------------------------------------------
proc _2_main {} \
{
  #   population	*popd = NULL;		/* Population for Darwinian evolution.   */
  #   population	*popb = NULL;		/* Population for Baldwinian evolution.  */
  #   population	*popl = NULL;		/* Population for Lamarckian evolution.  */
  #   //char		*beststring = NULL;	/* Human readable form of best solution. */
  
  #   //size_t	 beststrlen = 0;	/* Length of beststring.                 */
  
  #   int population_size  = 150;
  #   int max_generations1 = 600;
  #   int max_generations2 = 300;
  #   int max_generations3 = 300;
  
  #   parse_opts_4 (argc, argv,  &population_size, 
  #                 &max_generations1,  &max_generations2,  &max_generations3, 
  #                 150, 600, 300, 300);
  
  parse_opts_4  population_size max_generations1 max_generations2 max_generations3 \
                150 600 300 300
  
  random_seed 23091975
  
  #   popd = ga_genesis_char (
  #      population_size,		/* const int              population_size */
  #      1,				/* const int              num_chromo      */
  #      (int) strlen(target_text),	/* const int              len_chromo      */
  #      NULL,		 	/* GAgeneration_hook      generation_hook      */
  #      NULL,			/* GAiteration_hook       iteration_hook       */
  #      NULL,			/* GAdata_destructor      data_destructor      */
  #      NULL,			/* GAdata_ref_incrementor data_ref_incrementor */
  #      struggle_score,		/* GAevaluate             evaluate        */
  #      ga_seed_printable_random,	/* GAseed                 seed            */
  #      struggle_adaptation,	        /* GAadapt                adapt           */
  #      ga_select_one_sus,		/* GAselect_one           select_one      */
  #      ga_select_two_sus,		/* GAselect_two           select_two      */
  #      ga_mutate_printable_singlepoint_drift,	/* GAmutate     mutate    */
  #      ga_crossover_char_allele_mixing,    	/* GAcrossover  crossover */
  #      NULL,			/* GAreplace		          replace */
  #      NULL			/* vpointer		        User data */
  #      );
  
  set len_chromo [strlen $::target_text] 
  #        puts ""
  #        puts "len_chromo = $len_chromo"
  #        puts ""
  
  set popd [ga_genesis_char                          \
              $population_size			     \
              1			                     \
              [strlen $::target_text]                \
              NULL		  	             \
              NULL			             \
              NULL			             \
              NULL                                   \
              struggle_score	 	             \
              ga_seed_printable_random               \
              struggle_adaptation	             \
              ga_select_one_sus	                     \
              ga_select_two_sus	                     \
              ga_mutate_printable_singlepoint_drift  \
              ga_crossover_char_allele_mixing        \
              NULL			             \
              NULL			             \
             ]

  $popd configure -ch_form "%c" ;# 

  #   ga_population_set_parameters (
  #      popd,			/* population   *pop */
  #      GA_SCHEME_DARWIN,		/* const ga_scheme_type scheme */
  #      GA_ELITISM_PARENTS_DIE,	/* const ga_elitism_type   elitism */
  #      0.9,			/* const double       crossover */
  #      0.1,			/* const double       mutation */
  #      0.0			/* const double       migration */
  #      );
  
  ga_population_set_parameters \
    $popd	               \
    GA_SCHEME_DARWIN	       \
    GA_ELITISM_PARENTS_DIE     \
    0.9			       \
    0.1			       \
    0.0      	          


  #   /*
  #     * Make exact copies of the populations, except modify
  #     * their evolutionary schemes.
  #     */

  set popb [ga_population_clone $popd]
  ga_population_set_scheme  $popb "GA_SCHEME_BALDWIN_CHILDREN"
  
  set popl [ga_population_clone $popd]
  ga_population_set_scheme  $popl "GA_SCHEME_LAMARCK_CHILDREN"
  
  #   /*
  #     * Evolve each population in turn.
  #     */
  
  #   //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  
  #puts "max_generations1 = $max_generations1"
  #puts "max_generations2 = $max_generations2"
  #puts "max_generations3 = $max_generations3"

  if {! $::is_print} {
    evolution_print_best $popd $max_generations1 "Darwinian"
  }
  
  evolution_print_best $popb $max_generations2 "Baldwinian"
  
  if {! $::is_print} {
    evolution_print_best $popl $max_generations3 "Lamarckian"
  }
  
  #   //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  
  #   /* Deallocate population structures. */
  #   ga_extinction (popd);
  #   ga_extinction (popb);
  #   ga_extinction (popl);
  
  #   /* Deallocate string buffer. */
  #   //s_free (beststring);
  
  #//exit (EXIT_SUCCESS);
  
  return 1
}
# //------------------------------------------------------------------------------

# //------------------------------------------------------------------------------
# //  struggle_generation_hook()
# //  synopsis:	This function is called by the main GA routine at the
# //		beginning of every generation.

  set ::sum_best_fitnesses 0.0  


# //------------------------------------------------------------------------------
# static boolean 
# _3_struggle_generation_hook (int generation, population *pop)
# //------------------------------------------------------------------------------
proc _3_struggle_generation_hook {generation pop} \
{

  #   /* Sum of best fitness score at each generation. */
  #static double	sum_best_fitnesses = 0.0;  

  #   double	average, stddev;     /* Simple stats. */
  
  #   sum_best_fitnesses += ga_get_entity_from_rank (pop,0)->fitness;
  #set fi [$pop  get_entity_fitness 0]
  set fi [pop_get_entity_fitness_ $pop  0]

  set ::sum_best_fitnesses [expr $::sum_best_fitnesses + $fi]
  
  #   // Display statistics every 20th generation.
  #   //
  
  if {[expr $generation % 20] == 0} {

    puts [format "Generation = %d " $generation]
    puts [format "Number of evaluations = %ld" $::_3_evaluation_count]
    puts [format "Best fitness = %f" $fi]

    # ga_fitness_mean_stddev (pop, &average, &stddev);
    ga_fitness_mean_stddev  $pop  average stddev
    
    puts [format "Mean fitness = %f, with standard deviation = %f" $average $stddev]

    if {$generation > 0} {
      puts [format "Average best fitness for entire run = %f" \
              [expr $::sum_best_fitnesses / $generation]]
    }

    puts ""
  }
  
  #   // Stop if we have the exact solution.
  #   //
  #   if (!strncmp (target_text,
  #                (char *) ga_get_entity_from_rank (pop, 0)->CH,
  #                strlen (target_text)))
  #   {
  #     printf ("Exact solution has been found! \n");
  #     return FALSE;
  #   }
  
  #   // Stop if the population has converged.
  #   //
  #   if (!strncmp ((char *) ga_get_entity_from_rank (pop,0)->CH,
  #                 (char *) ga_get_entity_from_rank (pop,pop->size-1)->CH,
  #                strlen (target_text)))
  #   {
  #     printf ("Solutions have converged!\n");
  #     return FALSE;
  #   }

  return true ;#  /* TRUE indicates that evolution should continue. */
}
# //------------------------------------------------------------------------------
# //  struggle3.c
# //
# //		This program demonstrates the use of custom GA
# //		termination criteria.  It also provides an example of
# //		how to collate some simple statistics.
# //
#-------------------------------------------------------------------------------
proc parse_opts_2 {&par1    &par2 \
                def_par1 def_par2 } {

  USE_REFS

  global argc argv argv0

  set ::is_print 0

  if  {$argc == 1} { 
    # вызов без параметров, только с одним mode
    
    set par1  $def_par1
    set par2  $def_par2
 
  } else {

    set par1 [lindex $argv 1]
    set par2 [lindex $argv 2]

    if  {$argc == 4}    {
      set ::is_print 1
      set ::target_text $::target_text_simp
    }
  }

  return
}
# //------------------------------------------------------------------------------
proc _3_main {} \
{
  #   population	*pop = NULL;		/* Population structure. */
  #   char		*beststring = NULL;	/* Human readable form of best solution. */
  #   size_t	beststrlen = 0;		/* Length of beststring. */
  
  random_seed 23091975
  
  set population_size 120
  set max_generations 1000

  parse_opts_2  population_size max_generations \
                120 1000
  
  #   pop = ga_genesis_char (
  #      120,				/* const int              population_size */
  #      1,					/* const int              num_chromo */
  #      (int) strlen(target_text),		/* const int              len_chromo */
  #      _3_struggle_generation_hook, 	/* GAgeneration_hook      generation_hook */
  #      NULL,				/* GAiteration_hook       iteration_hook */
  #      NULL,				/* GAdata_destructor      data_destructor */
  #      NULL,				/* GAdata_ref_incrementor data_ref_incrementor */
  #      _3_struggle_score,			/* GAevaluate             evaluate */
  #      ga_seed_printable_random,		/* GAseed                 seed */
  #      _3_struggle_adaptation,		/* GAadapt                adapt */
  #      ga_select_one_sus,			/* GAselect_one		select_one */
  #      ga_select_two_sus,			/* GAselect_two		select_two */
  #      ga_mutate_printable_singlepoint_drift,	/* GAmutate	mutate */
  #      ga_crossover_char_allele_mixing,	/* GAcrossover		crossover */
  #      NULL,				/* GAreplace		replace */
  #      NULL				/* vpointer		User data */
  #      );
  
  set len_chromo [strlen $::target_text] 
  #        puts ""
  #        puts "len_chromo = $len_chromo"
  #        puts ""
  
  set pop  [ga_genesis_char                          \
              $population_size			     \
              1			                     \
              $len_chromo                            \
              _3_struggle_generation_hook	     \
              NULL			             \
              NULL			             \
              NULL                                   \
              _3_struggle_score	 	             \
              ga_seed_printable_random               \
              _3_struggle_adaptation	             \
              ga_select_one_sus	                     \
              ga_select_two_sus	                     \
              ga_mutate_printable_singlepoint_drift  \
              ga_crossover_char_allele_mixing        \
              NULL			             \
              NULL			             \
             ]

  $pop configure -ch_form "%c" ;# 

  #   ga_population_set_parameters (
  #      pop,				/* population		*pop */
  #      GA_SCHEME_LAMARCK_CHILDREN,	/* const ga_scheme_type	scheme */
  #      GA_ELITISM_PARENTS_DIE,		/* const ga_elitism_type	elitism */
  #      0.8,				/* const double		crossover */
  #      0.05,				/* const double		mutation */
  #      0.0				/* const double		migration */
  #      );
  
  ga_population_set_parameters \
    $pop	               \
    GA_SCHEME_LAMARCK_CHILDREN \
    GA_ELITISM_PARENTS_DIE     \
    0.8			       \
    0.05		       \
    0.0      	          


  set ret [ga_evolution  $pop $max_generations]  


  if {$ret < $max_generations} {
    puts "The evolution was stopped because the termination criteria were met. "
  } else {
    puts "The evolution was stopped because the maximum number of generations were performed."
  }
  puts ""
  
  set best_entity [ga_get_entity_from_rank $pop 0]
  set best_fitnes [$best_entity cget -fitness] 

  #   printf ("The final solution with score %f was: \n",
  #           ga_get_entity_from_rank (pop, 0)->fitness);

  puts [format "The final solution with score %f was:" $best_fitnes]
  
  #   beststring = ga_chromosome_char_to_string (pop, ga_get_entity_from_rank (pop, 0), 
  #                                              beststring, &beststrlen);
  #   printf ("%s \n", beststring);

  #$best_entity  print_ch ""
  ent_print_ch_ $best_entity ""

  puts ""

  puts ""
  puts [format "Total number of fitness evaluations: %ld" $::_3_evaluation_count]
  
  #   ga_extinction (pop);  
  #   s_free (beststring);  
  #   //exit (EXIT_SUCCESS);

  return 1
}
# //------------------------------------------------------------------------------
# static boolean 
# _4_struggle_seed (population *pop, entity *adam) 
# //------------------------------------------------------------------------------
proc _4_struggle_seed {pop adam} \
{

  #   int   chromo;   /* Index of chromosome to seed */
  #   int   point;    /* Index of allele to seed     */
  
  #   /* Checks (Not really necessary here). */
  #   if (!pop)  die ("Null pointer to population structure passed.");
  #   if (!adam) die ("Null pointer to entity structure passed.");
  
  #   /* Seeding. */
  #   for (chromo = 0; chromo < 1/* pop->num_chromosomes */; chromo++)
  #   {
  #     for (point = 0; point < pop->len_chromosomes; point++)
  #     {
  #       ((char *)adam->chromosome[chromo])[point]
  #         = random_int ('~'-' ')+' ';
  #     }
  #   }
  
  # это похоже тоже самое
  #
  ga_seed_printable_random $pop $adam


  return true
}
# //------------------------------------------------------------------------------
# static void 
# _4_struggle_mutate (population *pop, entity *father, entity *son)
# //------------------------------------------------------------------------------
proc _4_struggle_mutate {pop father son} \
{

  
  # похоже это тоже самое !?
  # 
  ga_mutate_printable_singlepoint_drift  $pop $father $son


  #   int  i;              /* Loop variable over all chromosomes */
  #   int  chromo;         /* Index of chromosome to mutate      */
  #   int  point;          /* Index of allele to mutate          */

  #   int  dir = random_boolean()?-1:1;    /* The direction of drift. */
  
  #   /* Checks */
  #   if (!father || !son) die("Null pointer to entity structure passed");
  
  #   /* Select mutation locus. */

  #   chromo = random_int (1/* pop->num_chromosomes */);
  #   point  = random_int (pop->len_chromosomes);
  
  #   // Copy unchanged data.
  #   //
  #   for (i = 0; i<1/* pop->num_chromosomes */; i++)
  #     {
  #     memcpy (son->chromosome[i], father->chromosome[i], pop->len_chromosomes * sizeof(char));
  
  #     if (i!=chromo) {
  #       ga_copy_data (pop, son, father, i);
  #     } else {
  #       ga_copy_data (pop, son, NULL, i);
  #     }
  #     }
  
  #   // Mutate by tweaking a single allele.
  #   //
  #   ((char *)son->chromosome[chromo])[point] += dir;
  
  #   if (((char *)son->chromosome[chromo])[point] > '~')
  #     ((char *)son->chromosome[chromo])[point] = ' ';
  
  #   if (((char *)son->chromosome[chromo])[point] < ' ')
  #     ((char *)son->chromosome[chromo])[point] = '~';

  return
}
# //------------------------------------------------------------------------------
# //  synopsis:	A pair of crossover operators which will be called
# //		alternately through the use of cross definitions.
# //------------------------------------------------------------------------------
# //------------------------------------------------------------------------------
# static void 
# _4_the_other_struggle_crossover (population *pop,
#                               entity *father, entity *mother,
#                               entity    *son, entity *daughter )
# //------------------------------------------------------------------------------
proc _4_the_other_struggle_crossover {pop father mother son daughter} \
{

  ga_crossover_char_singlepoints  $pop $father $mother $son $daughter
  $pop configure -crossover _4_struggle_crossover

  return
}
# //------------------------------------------------------------------------------
# static void 
# _4_struggle_crossover (population *pop,
#                         entity *father, entity *mother,
#                     entity *son, entity *daughter )
# //------------------------------------------------------------------------------
proc _4_struggle_crossover {pop father mother son daughter} \
{
  ga_crossover_char_doublepoints $pop $father $mother $son $daughter

  $pop configure -crossover _4_the_other_struggle_crossover

  return
}
# //------------------------------------------------------------------------------
# //------------------------------------------------------------------------------
# //
# //  struggle4.c
# //
# //	This program demonstrates the use of custom GA
# //	operator functions.  The long-hand method is used
# //	to set up the population's genomic form, rather than
# //	and of the high-level utility functions.
# //
# //	This example is explained in docs/html/tutorial4.html
# //
# //------------------------------------------------------------------------------
proc _4_main {} \
{
  #   population  *pop        = NULL;	/* Population structure. */
  #   char	  *beststring = NULL;	/* Human readable form of best solution. */
  #   size_t      beststrlen  = 0;      /* Length of beststring. */
  
  random_seed 23091975
  
  #   /*
  #     * Allocate a new popuation structure.
  #     * stable num. individuals = 100.
  #     * num. chromosomes = 1.
  #     * length of chromosomes = strlen(target_text);
  #     */

  # set population_size ;# 100
  # set max_generations ;# 500

  parse_opts_2  population_size max_generations \
                100 500
  

  set len_chromo [strlen $::target_text] 

  #   pop = ga_population_new (100,/*  1, */ (int) strlen (target_text));
  set pop [ga_population_new $population_size $len_chromo]
  
  $pop configure -ch_form "%c" ;# 

  #   if (! pop) die ("Unable to allocate population.");
  
  #   /*
  #     * Define chromosome handling functions.
  #     * Normally these functions would only be set manually when
  #     * creating a custom chromosome type.
  #     */

  #   pop->chromosome_constructor = ga_chromosome_char_allocate;
  #   pop->chromosome_destructor  = ga_chromosome_char_deallocate;
  #   pop->chromosome_replicate   = ga_chromosome_char_replicate;
  #   pop->chromosome_to_bytes    = ga_chromosome_char_to_bytes;
  #   pop->chromosome_from_bytes  = ga_chromosome_char_from_bytes;
  #   pop->chromosome_to_string   = ga_chromosome_char_to_string;
  
  #   /* Define all the needed callback functions. */
  $pop configure -generation_hook NULL
  #$pop configure -iteration_hook  NULL
  #   pop->data_destructor = NULL;
  #   pop->data_ref_incrementor = NULL;
  
  
  $pop configure -evaluate   struggle_score        ;# /* Fitness evaluation           */
  $pop configure -seed       _4_struggle_seed      ;# /* Individual initialisation    */
  $pop configure -adapt      struggle_adaptation   ;# /* Environmental adaptation operator */
  $pop configure -select_one ga_select_one_sus     ;# /* Mutation selection operator  */
  $pop configure -select_two ga_select_two_sus     ;# /* Crossover selection operator */
  $pop configure -mutate     _4_struggle_mutate    ;# /* Mutation operator            */
  $pop configure -crossover  _4_struggle_crossover ;# /* Crossover operator           */
  
  #   /* Replacement operator. (Only used in steady-state evolution) */
  $pop configure -replace NULL
  
  #   /*
  #     * Seed the initial population. (Could do this manually - it
  #     * just calls pop->seed() 100 times in this case.)
  #     */
  ga_population_seed $pop
  
  #   /*
  #     * Set the GA parameters.
  #     * Lamarkian evolution.
  #     * Parents may survive into next generation.
  #     * Crossover ratio = 0.9.
  #     * Mutation ratio = 0.1.
  #     * Migration ration = 0.0.
  #     *
  #     * Note that custom operator functions may choose to ignore these values.
  #     *
  #     * There are functions for setting these individually too.
  #     */
  #   ga_population_set_parameters (pop, GA_SCHEME_LAMARCK_CHILDREN, GA_ELITISM_PARENTS_DIE, 0.9, 0.1, 0.0);
  
  ga_population_set_parameters \
    $pop	               \
    GA_SCHEME_LAMARCK_CHILDREN \
    GA_ELITISM_PARENTS_DIE     \
    0.9			       \
    0.1		               \
    0.0      	          

  ga_evolution  $pop $max_generations
  
  set best_entity [ga_get_entity_from_rank $pop 0]
  set best_fitnes [$best_entity cget -fitness] 

  #   printf ("The final solution with score %f was:\n",
  #           ga_get_entity_from_rank (pop,0)->fitness);

  puts [format "The final solution with score %f was:" $best_fitnes]
  
  #   beststring = ga_chromosome_char_to_string (pop, ga_get_entity_from_rank(pop,0), 
  #                                              beststring, &beststrlen);
  #   printf ("%s\n", beststring);

  #$best_entity  print_ch ""
  ent_print_ch_ $best_entity ""

  puts ""
  
  #   /*
  #     * This deallocates the population, all individuals, and
  #     * any genomic and phenomic data that may be associated.
  #     * (Not quite true - it actually dereferences any phenomic
  #     * data, which will then be deallocated if appropriate.)
  #     */
  #   ga_extinction (pop);
  
  #   s_free (beststring);
  
  #   // exit (EXIT_SUCCESS);
  return 1
}
# //------------------------------------------------------------------------------
# //  struggle5.c
# //
# //    This example shows the use of multiple populations
# //	with GAUL's so called "archipelago" scheme.  This is
# //	the basic island model of evolution.
# //
# //	This example is explained in
# //	http://gaul.sourceforge.net/tutorial/island.html
# //	and
# //	http://gaul.sourceforge.net/tutorial/multiprocessor.html
# //
# //------------------------------------------------------------------------------

# /* Specify the number of populations (islands) to use. */
# #define GA_STRUGGLE_NUM_POPS	5

set ::GA_STRUGGLE_NUM_POPS	5

# //******************************************************************************
# //------------------------------------------------------------------------------
proc _5_main {} \
{

  #   int		i;				/* Loop over populations. */
  #   population	*pops[GA_STRUGGLE_NUM_POPS];	/* Array of populations.  */
  #   char		*beststring = NULL;		/* Human readable form of best solution. */
  #   size_t	beststrlen  = 0;		/* Length of beststring. */
  
  #set num_pops 5
  #set population_size  80
  #set max_generations 250

  parse_opts_3   num_pops population_size max_generations  5 80 250

  random_seed 42
  #random_seed 23091975
  
  for {set i 0} {$i < $num_pops} {incr i} {
  
    #     pops[i] = ga_genesis_char (
    #        80,			  /* const int              population_size      */
    #        1,			          /* const int              num_chromo           */
    #        (int) strlen(target_text),   /* const int              len_chromo           */
    #        NULL,		   	  /* GAgeneration_hook      generation_hook      */
    #        NULL,			  /* GAiteration_hook       iteration_hook       */
    #        NULL,			  /* GAdata_destructor      data_destructor      */
    #        NULL,			  /* GAdata_ref_incrementor data_ref_incrementor */
    #        struggle_score,		  /* GAevaluate             evaluate             */
    #        ga_seed_printable_random,    /* GAseed                 seed                 */
    #        NULL,			  /* GAadapt                adapt                */
    #        ga_select_one_sus,	          /* GAselect_one           select_one           */
    #        ga_select_two_sus,	          /* GAselect_two           select_two           */
    #        ga_mutate_printable_singlepoint_drift, /* GAmutate       mutate             */
    #        ga_crossover_char_allele_mixing,	    /* GAcrossover    crossover          */
    #        NULL,			            /* GAreplace      replace            */
    #        NULL			            /* vpointer       User data          */
    #        );
    
    set len_chromo [strlen $::target_text] 
  
    set pop  [ga_genesis_char                         \
                $population_size	              \
                1			              \
                $len_chromo                           \
                NULL	                              \
                NULL			              \
                NULL			              \
                NULL                                  \
                struggle_score	 	              \
                ga_seed_printable_random              \
                NULL	                              \
                ga_select_one_sus	              \
                ga_select_two_sus	              \
                ga_mutate_printable_singlepoint_drift \
                ga_crossover_char_allele_mixing       \
                NULL			              \
                NULL			              \
               ]

    $pop configure -ch_form "%c" ;# 

    #     ga_population_set_parameters (pops[i], GA_SCHEME_DARWIN, GA_ELITISM_PARENTS_DIE, 
    #                                   0.75, 0.25, 0.001);

    ga_population_set_parameters \
      $pop	                 \
      GA_SCHEME_DARWIN           \
      GA_ELITISM_PARENTS_DIE     \
      0.75			 \
      0.25		         \
      0.0001      

    lappend pops $pop
  }
  
  ga_evolution_archipelago  $num_pops $pops $max_generations
  
  for {set i 0} {$i < $num_pops} {incr i} {
  
    set pop [lindex $pops $i] 

    set best_entity [ga_get_entity_from_rank $pop 0]
    set best_fitnes [$best_entity cget -fitness] 

    # printf ("The best solution on island %d with score %f was:\n",
    #         i, ga_get_entity_from_rank (pops[i], 0)->fitness);
    
    puts [format "The best solution on island %d with score %f was:" $i $best_fitnes]
    
    # beststring = ga_chromosome_char_to_string (pops[i], ga_get_entity_from_rank (pops[i], 0), 
    #                               beststring, &beststrlen);
    #  printf ("\n");
    #  printf ("%s \n", beststring);
    #  printf ("\n");
    
    puts ""
    #$best_entity  print_ch ""
    ent_print_ch_ $best_entity ""

    puts ""
    puts ""

    #  ga_extinction (pops[i]);
  }
  
  #   s_free (beststring);
  
  #   //exit (EXIT_SUCCESS);
  
  return 1
}
# //------------------------------------------------------------------------------
# //  struggle_dc.c
# //
# //	This program is almost identical to struggle, except it
# //	applies deterministic crowding instead of a genetic
# //	algorithm.
# //
# //	This example is explained in docs/html/tutorial/simple.html
# //
# //------------------------------------------------------------------------------
proc _dc_main {} \
{

  #   int  i;     /* Runs. */
  #   population  *pop        = NULL;    /* Population of solutions.              */
  #   char	  *beststring = NULL;    /* Human readable form of best solution. */
  #   size_t       beststrlen = 0;	 /* Length of beststring.                 */
  

  #set num_runs         ; # mgena i<50
  #set population_size  
  #set max_generations  

  parse_opts_3   num_runs population_size max_generations  3 120 500


  for {set i 0} {$i < $num_runs} {incr i} {
  
    random_seed  $i
    
    #     pop = ga_genesis_char (
    #        population_size,	         /* const int              population_size      */
    #        1,			         /* const int              num_chromo           */
    #        (int) strlen(target_text),  /* const int              len_chromo           */
    #        NULL,		   	 /* GAgeneration_hook      generation_hook      */
    #        NULL,			 /* GAiteration_hook       iteration_hook       */
    #        NULL,			 /* GAdata_destructor      data_destructor      */
    #        NULL,			 /* GAdata_ref_incrementor data_ref_incrementor */
    #        struggle_score,		 /* GAevaluate             evaluate             */
    #        ga_seed_printable_random,   /* GAseed                 seed                 */
    #        NULL,			 /* GAadapt                adapt                */
    #        ga_select_one_sus,	         /* GAselect_one           select_one           */
    #        ga_select_two_sus,	         /* GAselect_two           select_two           */
    #        ga_mutate_printable_singlepoint_drift, /* GAmutate    mutate               */
    #        ga_crossover_char_allele_mixing,	    /* GAcrossover crossover            */
    #        NULL,		  	            /* GAreplace   replace              */
    #        NULL			            /* vpointer	   User data            */
    #        );
    
    set len_chromo [strlen $::target_text] 
  
    set pop  [ga_genesis_char                         \
                $population_size	              \
                1			              \
                $len_chromo                           \
                NULL	                              \
                NULL			              \
                NULL			              \
                NULL                                  \
                struggle_score	 	              \
                ga_seed_printable_random              \
                NULL	                              \
                ga_select_one_sus	              \
                ga_select_two_sus	              \
                ga_mutate_printable_singlepoint_drift \
                ga_crossover_char_allele_mixing       \
                NULL			              \
                NULL			              \
               ]



    $pop configure -ch_form "%c" ;# 

    #     ga_population_set_parameters (
    #        pop,                       /* population                *pop */
    #        GA_SCHEME_DARWIN,          /* const ga_scheme_type    scheme */
    #        GA_ELITISM_PARENTS_DIE,    /* const ga_elitism_type  elitism */
    #        0.9,                       /* double  crossover              */
    #        0.2,                       /* double  mutation               */
    #        0.0                        /* double  migration              */
    #        );
    
    ga_population_set_parameters \
      $pop	                 \
      GA_SCHEME_DARWIN           \
      GA_ELITISM_PARENTS_DIE     \
      0.9			 \
      0.2		         \
      0.0      

    #     ga_population_set_deterministiccrowding_parameters (
    #        pop,			  /* population	               *pop */
    #        ga_compare_char_hamming	  /* GAcompare 	Comparison function */
    #        );
    
    ga_population_set_deterministiccrowding_parameters  $pop "ga_compare_char_hamming"

    #     ga_deterministiccrowding (
    #        pop,			  /* population  *pop               */
    #        max_generations	  /* const int    max_generations   */
    #        );
    
    ga_deterministiccrowding  $pop $max_generations

    set best_entity [ga_get_entity_from_rank $pop 0]
    set best_fitnes [$best_entity cget -fitness] 


    puts "The final solution with seed = $i was:"
    #     beststring = ga_chromosome_char_to_string (pop, ga_get_entity_from_rank (pop, 0), 
    #                                                beststring, &beststrlen);
    #     printf ("%s\n", beststring);
    #$best_entity  print_ch ""
    ent_print_ch_ $best_entity ""

    puts ""

    #     printf ( "With score = %f\n", ga_entity_get_fitness (ga_get_entity_from_rank (pop, 0)) );
    puts "With score = $best_fitnes "
    puts ""
    
    #     ga_extinction (pop);
  }    

  #   s_free (beststring);    
  #   //exit (EXIT_SUCCESS);
  
  return 1
}
# //------------------------------------------------------------------------------
# /**********************************************************************
#   struggle_randomsearch.c

# 	This program uses the monkeys on typewriters approach
# 	to solving the problem tackled by all of the struggle*
# 	examples.

# 	This example is explained in docs/html/tutorial/simple.html

#  **********************************************************************/
# //------------------------------------------------------------------------------
# int 
# _rs_main(int argc, char **argv)
# {
#   population	*pop        = NULL;   	/* Population of solutions. */
#   char		*beststring = NULL;	/* Human readable form of best solution. */
#   size_t	beststrlen  = 0;	/* Length of beststring.    */
#   entity	*solution;		/* Solution to problem.     */

#   random_seed (23091975);

#   pop = ga_genesis_char (
#        100,			/* const int              population_size */
#        1,			/* const int              num_chromo      */
#        strlen(target_text),	/* const int              len_chromo      */
#        NULL,		 	/* GAgeneration_hook      generation_hook      */
#        NULL,			/* GAiteration_hook       iteration_hook       */
#        NULL,			/* GAdata_destructor      data_destructor      */
#        NULL,			/* GAdata_ref_incrementor data_ref_incrementor */
#        struggle_score,		/* GAevaluate             evaluate        */
#        ga_seed_printable_random,	/* GAseed         seed            */
#        NULL,			/* GAadapt                adapt           */
#        NULL,			/* GAselect_one           select_one      */
#        NULL,			/* GAselect_two           select_two      */
#        NULL,			/* GAmutate               mutate          */
#        NULL,			/* GAcrossover            crossover       */
#        NULL,			/* GAreplace		  replace         */
#        NULL			/* vpointer		  User data       */
#        );

#   solution = ga_get_free_entity (pop);

#   ga_random_search (
#        pop,			/* population      *pop           */
#        solution,		/* entity          *entity        */
#        //mgena       1000000	/* const int       max_iterations */
#        10000			/* const int       max_iterations */
#        );

#   printf ("The final solution was: \n");
#   beststring = ga_chromosome_char_to_string (pop, solution, beststring, &beststrlen);
#   printf ("%s\n", beststring);
#   printf ("With score = %f\n", ga_entity_get_fitness (solution) );

#   ga_extinction (pop);
#   s_free (beststring);

#   //exit (EXIT_SUCCESS);
#   return (1);
# }
# //------------------------------------------------------------------------------
# //  struggle_ss.c
# //
# //	This program is fairly lean, showing how little
# //	application code is needed when using GAUL.
# //
# //------------------------------------------------------------------------------
# int 
# _ss_main (int argc, char **argv)
# {
#   population   *pop        = NULL;	/* Population of solutions. */
#   char	       *beststring = NULL;	/* Human readable form of best solution. */
#   size_t       beststrlen = 0;		/* Length of beststring.    */

#   random_init ();

#   random_seed (12345678);

#   pop = ga_genesis_char (
#        60,				/* const int              population_size */
#        1,				/* const int              num_chromo      */
#        (int) strlen(target_text),	/* const int              len_chromo      */
#        NULL,			 	/* GAgeneration_hook      generation_hook */
#        NULL,				/* GAiteration_hook       iteration_hook  */
#        NULL,				/* GAdata_destructor      data_destructor */
#        NULL,				/* GAdata_ref_incrementor data_ref_incrementor */
#        struggle_score,			/* GAevaluate             evaluate   */
#        ga_seed_printable_random,	/* GAseed                 seed       */
#        NULL,				/* GAadapt                adapt      */
#        ga_select_one_roulette,		/* GAselect_one           select_one */
#        ga_select_two_roulette,		/* GAselect_two           select_two */
#        ga_mutate_printable_singlepoint_drift,	/* GAmutate       mutate     */
#        ga_crossover_char_allele_mixing,	/* GAcrossover            crossover  */
#        ga_replace_by_fitness,		/* GAreplace	          replace    */
#        NULL				/* vpointer		  User data  */
#        );

#   ga_population_set_parameters (
#        pop,			/* population	             *pop */
#        GA_SCHEME_DARWIN,	/* const ga_scheme_type	   scheme */
#        GA_ELITISM_NULL,		/* const ga_elitism_type  elitism */
#        1.0,			/* double		crossover */
#        0.1,			/* double		 mutation */
#        0.0              	/* double		migration */
#        );

#   ga_evolution_steady_state (
#        pop,			/* population		*pop */
#        50000			/* const int		max_generations */
#        );

#   printf ("\n");
#   printf ( "The final solution was: \n");
#   printf ("\n");

#   beststring = ga_chromosome_char_to_string (pop, ga_get_entity_from_rank(pop,0), 
#                                              beststring, &beststrlen);
#   printf ("%s \n", beststring);

#   printf ("\n");
#   printf ("With score = %f\n", ga_entity_get_fitness (ga_get_entity_from_rank (pop, 0)));
#   printf ("\n");

#   ga_extinction (pop);

#   s_free (beststring);

#   //exit (EXIT_SUCCESS);
#   return (1);
# }
# //------------------------------------------------------------------------------
# //  struggle_systematicsearch.c
# //
# //		This program uses a systematic searching approach
# //		to solving the problem tackled by all of the struggle*
# //		examples.
# //
# //		This example is explained in docs/html/tutorial/simple.html
# //
# //------------------------------------------------------------------------------
# //  synopsis:	Allele combination enumeration function.

# //------------------------------------------------------------------------------
# boolean 
# _zs_struggle_scan_chromosome (population *pop, entity *entity, int enumeration)
# {
#   int  i = 0, j = 0;   /* Loop variables over all chromosomes, alleles. */

#   (((char *)entity->CH)[0])++;
  
#   while (((char *)entity->chromosome[i])[j]>'~') {

#     ((char *)entity->chromosome[i])[j] = ' ';
#     j++;

#     if (j == pop->len_chromosomes) {
#       j = 0;
#       i++;

#       if (i == 1/* pop->num_chromosomes */) {
#         return TRUE;	/* Enumeration is now complete! */
#       }
#     }

#     (((char *)entity->chromosome[i])[j])++;
#   }

#   /* Enumeration is not complete. */
#   return FALSE;
# }
# //------------------------------------------------------------------------------
# //  synopsis:	Need to seed with first allele permutation.

# //------------------------------------------------------------------------------
# boolean 
# _zs_struggle_seed (population *pop, entity *entity)
# {
#   int  i = 0, j = 0;    /* Loop variables over all chromosomes, alleles. */

#   /* Checks. */
#   if (! pop)    die ("Null pointer to population structure passed.");
#   if (! entity) die ("Null pointer to entity structure passed.");

#   while (i < 1/* pop->num_chromosomes */)
#   {
#     while (j < pop->len_chromosomes) {

#       ((char *)entity->chromosome[i])[j] = ' ';
#       j++;
#     }
#     i++;
#   }

#   return TRUE;
# }
# //*****************************************************************************
# //------------------------------------------------------------------------------
# int 
# _zs_main (int argc, char **argv)
# {
#   population	*pop        = NULL;	/* Population of solutions.       */
#   char		*beststring = NULL;	/* Human readable form of best solution. */
#   size_t	beststrlen  = 0;	/* Length of beststring.          */
#   entity	*solution;		/* Solution to problem.           */
#   int		num_iterations;		/* Number of iterations required. */

#   random_seed (23091975);

#   pop = ga_genesis_char (
#        100,	                /* const int              population_size */
#        //mgena 4,		/* const int              population_size */

#        1,			/* const int              num_chromo      */
#        strlen(target_text),	/* const int              len_chromo      */
#        NULL,		 	/* GAgeneration_hook      generation_hook */
#        NULL,			/* GAiteration_hook       iteration_hook  */
#        NULL,			/* GAdata_destructor      data_destructor */
#        NULL,			/* GAdata_ref_incrementor data_ref_incrementor */
#        struggle_score,		/* GAevaluate             evaluate        */
#        _zs_struggle_seed,	/* GAseed                 seed            */
#        NULL,			/* GAadapt                adapt           */
#        NULL,			/* GAselect_one           select_one      */
#        NULL,			/* GAselect_two           select_two      */
#        NULL,			/* GAmutate               mutate          */
#        NULL,			/* GAcrossover            crossover       */
#        NULL,			/* GAreplace	    	  replace         */
#        NULL			/* vpointer		  User data       */
#        );

#   ga_population_set_search_parameters (pop, _zs_struggle_scan_chromosome);

#   solution = ga_get_free_entity (pop);

#   num_iterations = ga_search(
#        pop,		/* population      *pop    */
#        solution		/* entity          *entity */
#        );

#   printf ("The final solution was: \n");

#   beststring = ga_chromosome_char_to_string (pop, solution, beststring, &beststrlen);

#   printf ("%s\n", beststring);
#   printf ("With score = %f\n", ga_entity_get_fitness(solution));
#   printf ("This required %d iterations\n", num_iterations);

#   ga_extinction (pop);
#   s_free (beststring);

#   //exit (EXIT_SUCCESS);
#   return (1);
# }
# //*****************************************************************************
# //-----------------------------------------------------------------------------
# //------------------------------------------------------------------------------
proc print_wordchar_s {}  {

  set char_min [scan " " "%c"]
  set char_max [scan "~" "%c"] 
  
  #   int randmax = '~' - ' ';
  #   int i;
  set randmax [expr $char_max - $char_min]

  puts ""
  
  puts "get_random_wordchar : ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ "
  puts ""

  puts [format "char_min = %d"  $char_min] 
  puts [format "char_max = %d"  $char_max] 

  puts "size_all = $randmax"   ; #// randmax = 94 
  puts ""
  
 
  for {set i $char_min} {$i <= $char_max} {incr i} {
    puts [format "i= %3d  ch= %c " $i $i]
  }
  
  puts ""
  
  for {set i $char_min} {$i <= $char_max} {incr i} {
    puts -nonewline [format "%c " $i]
  }

  puts ""
  puts ""
  
  return
}
# //------------------------------------------------------------------------------

# /* char_min = 32 (' ')  */
# /* char_max = 126 ('~')  */
# /* size_all = 94  */

# /*   ! " # $ % & ' ( ) * + , - . / 0 1 2 3 4 5 6 7 8 9 : ; < = > ? @ A B C D E F G H I J K L M N O P Q R S T U V W X Y Z [ \ ] ^ _ ` a b c d e f g h i j k l m n o p q r s t u v w x y z { | } ~  */

# /* i=  32  ch=    */
# /* i=  33  ch= !  */
# /* i=  34  ch= "  */
# /* i=  35  ch= #  */
# /* i=  36  ch= $  */
# /* i=  37  ch= %  */
# /* i=  38  ch= &  */
# /* i=  39  ch= '  */
# /* i=  40  ch= (  */
# /* i=  41  ch= )  */
# /* i=  42  ch= *  */
# /* i=  43  ch= +  */
# /* i=  44  ch= ,  */
# /* i=  45  ch= -  */
# /* i=  46  ch= .  */
# /* i=  47  ch= /  */
# /* i=  48  ch= 0  */
# /* i=  49  ch= 1  */
# /* i=  50  ch= 2  */
# /* i=  51  ch= 3  */
# /* i=  52  ch= 4  */
# /* i=  53  ch= 5  */
# /* i=  54  ch= 6  */
# /* i=  55  ch= 7  */
# /* i=  56  ch= 8  */
# /* i=  57  ch= 9  */
# /* i=  58  ch= :  */
# /* i=  59  ch= ;  */
# /* i=  60  ch= <  */
# /* i=  61  ch= =  */
# /* i=  62  ch= >  */
# /* i=  63  ch= ?  */
# /* i=  64  ch= @  */
# /* i=  65  ch= A  */
# /* i=  66  ch= B  */
# /* i=  67  ch= C  */
# /* i=  68  ch= D  */
# /* i=  69  ch= E  */
# /* i=  70  ch= F  */
# /* i=  71  ch= G  */
# /* i=  72  ch= H  */
# /* i=  73  ch= I  */
# /* i=  74  ch= J  */
# /* i=  75  ch= K  */
# /* i=  76  ch= L  */
# /* i=  77  ch= M  */
# /* i=  78  ch= N  */
# /* i=  79  ch= O  */
# /* i=  80  ch= P  */
# /* i=  81  ch= Q  */
# /* i=  82  ch= R  */
# /* i=  83  ch= S  */
# /* i=  84  ch= T  */
# /* i=  85  ch= U  */
# /* i=  86  ch= V  */
# /* i=  87  ch= W  */
# /* i=  88  ch= X  */
# /* i=  89  ch= Y  */
# /* i=  90  ch= Z  */
# /* i=  91  ch= [  */
# /* i=  92  ch= \  */
# /* i=  93  ch= ]  */
# /* i=  94  ch= ^  */
# /* i=  95  ch= _  */
# /* i=  96  ch= `  */
# /* i=  97  ch= a  */
# /* i=  98  ch= b  */
# /* i=  99  ch= c  */
# /* i= 100  ch= d  */
# /* i= 101  ch= e  */
# /* i= 102  ch= f  */
# /* i= 103  ch= g  */
# /* i= 104  ch= h  */
# /* i= 105  ch= i  */
# /* i= 106  ch= j  */
# /* i= 107  ch= k  */
# /* i= 108  ch= l  */
# /* i= 109  ch= m  */
# /* i= 110  ch= n  */
# /* i= 111  ch= o  */
# /* i= 112  ch= p  */
# /* i= 113  ch= q  */
# /* i= 114  ch= r  */
# /* i= 115  ch= s  */
# /* i= 116  ch= t  */
# /* i= 117  ch= u  */
# /* i= 118  ch= v  */
# /* i= 119  ch= w  */
# /* i= 120  ch= x  */
# /* i= 121  ch= y  */
# /* i= 122  ch= z  */
# /* i= 123  ch= {  */
# /* i= 124  ch= |  */
# /* i= 125  ch= }  */
# /* i= 126  ch= ~  */

# //-----------------------------------------------------------------------------
proc main {} {

  global argc argv argv0

  #//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #print_wordchar_s 
  #exit
  #//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  #   if (argc !=2 ) 
  #     exit (EXIT_SUCCESS);
  
  #   printf ("\n");
  puts ""
  
  #   char *mode = argv[1];
  set mode [lindex $argv 0] ;# имя выч. задачи
  
  
  #   if      (! strcmp (mode, "1"))   _1_main  (argc, argv);
  #   else if (! strcmp (mode, "2"))   _2_main  (argc, argv); 
  #   else if (! strcmp (mode, "3"))   _3_main  (argc, argv); 
  #   else if (! strcmp (mode, "4"))   _4_main  (argc, argv); 
  #   else if (! strcmp (mode, "5"))   _5_main  (argc, argv); 
  
  #   else if (! strcmp (mode, "dc"))  _dc_main (argc, argv);
  #   else if (! strcmp (mode, "rs"))  _rs_main (argc, argv);
  #   else if (! strcmp (mode, "ss"))  _ss_main (argc, argv);
  
  #   // не заканчивается !!
  #   else if (! strcmp(mode, "zs"))  _zs_main (argc, argv);
  

  if     {$mode == "_1"}    { _1_main } \
  elseif {$mode == "_2"}    { _2_main } \
  elseif {$mode == "_3"}    { _3_main } \
  elseif {$mode == "_4"}    { _4_main } \
  elseif {$mode == "_5"}    { _5_main } \
  elseif {$mode == "dc"}    { _dc_main } \
  \
  else {
    puts ""
    puts "ERROR mode = $mode"
    puts ""
  }
  
  
  #   printf ("\n");
  puts ""
  
  #   exit (EXIT_SUCCESS);
}
# //-----------------------------------------------------------------------------

main

# //-----------------------------------------------------------------------------

# l_struggle.tl _1  1  5 1

# //-----------------------------------------------------------------------------
# //*****************************************************************************


