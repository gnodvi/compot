# -*-   mode: tcl  ; coding: koi8   -*- ----------------------------------------

#!/bin/sh
# \
exec tclsh "$0" ${1+"$@"}

#-------------------------------------------------------------------------------
# Josef Knecht @ Copyright 
#-------------------------------------------------------------------------------

#source "../gaul-l/a-comm.tl"

#source "../common/a-comm.tl"
#package require common 1.0

#-------------------------------------------

set COMPOT "./COMPOT"

set auto_path [linsert $auto_path 0 $COMPOT]

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

source "ga_de.tl"
source "ga_optim.tl"
source "ga_utility.tl"
source "ga_chromo.tl"
source "ga_qsort.tl"

source "ga_gradient.tl"


# /*******************************************************************************
#-------------------------------------------------------------------------------
proc parse_opts {&population_size &max_generations  \
                def_population_size def_max_generations} {

  USE_REFS

  global argc argv argv0

  set ::is_print 0

  #puts "argc = $argc"
  #exit

  if  {$argc == 1} { 
    # вызов без параметров, только с одним mode
    
    set population_size  $def_population_size
    set max_generations  $def_max_generations
 
  } else {

    set population_size [lindex $argv 1]
    set max_generations [lindex $argv 2]
    if  {$argc == 4}    {set ::is_print 1}
  }

  return
}
# /*******************************************************************************
#   ga_x_tester.c

# *******************************************************************************/

# //#include "c_all_util.h"
# #include "gaul.h"

# //#include "l_test_LIB.h"
# //------------------------------------------------------------------------------

# boolean _test_score (population *pop, entity *this_entity);
# boolean _test_seed (population *pop, entity *adam);
# boolean _test_generation_callback (int generation, population *pop);

# boolean _test_to_double (population *pop, entity *this_entity, double *array);
# boolean _test_from_double (population *pop, entity *this_entity, double *array);
# boolean _test_iteration_callback (int iteration, entity *solution);

# double 
# _test_analytical_gradient (population *pop, entity *this_entity, double *params, double *grad);

# /*******************************************************************************

# *******************************************************************************/

# //#include "gaul.h"
# //#include "l_test_LIB.h"

#-------------------------------------------------------------------------------

# #define SQU(x)          ((x)*(x))		/* Square */
# #define CUBE(x)         ((x)*(x)*(x))		/* Cube */
# #define FOURTH_POW(x)	((x)*(x)*(x)*(x))	/* Guess ;) */
# #define FIFTH_POW(x)	((x)*(x)*(x)*(x)*(x))	/*  - " - */

#-------------------------------------------------------------------------------
proc SQU {x} {

  return [expr $x * $x]
}
#-------------------------------------------------------------------------------
proc CUBE {x} {

  return [expr $x * $x * $x]
}
#-------------------------------------------------------------------------------
proc FOURTH_POW {x} {

  return [expr $x * $x * $x * $x]
}
#-------------------------------------------------------------------------------
# http://equi4.com/papers/ctpaper3_1.html

# package require critcl

# critcl::cproc noop {} void {}

# critcl::cproc add {int x int y} int {
#   return x + y;
# }

# critcl::cproc cube {int x} int {
#   return x * x * x;
# }
#-------------------------------------------------------------------------------
# //  synopsis:	Fitness function.

# /* static */ boolean 
# _test_score (population *pop, entity *this_entity)
#-------------------------------------------------------------------------------
proc _test_score {pop this_entity} {

  #   double    A, B, C, D;	/* Parameters. */
  
  #   A = ((double *) this_entity->chromosome[0]) [0];
  #   B = ((double *) this_entity->chromosome[0]) [1];
  #   C = ((double *) this_entity->chromosome[0]) [2];
  #   D = ((double *) this_entity->chromosome[0]) [3];
  
  set A [ent_get_chromo_gen_ $this_entity  0] 
  set B [ent_get_chromo_gen_ $this_entity  1] 
  set C [ent_get_chromo_gen_ $this_entity  2] 
  set D [ent_get_chromo_gen_ $this_entity  3] 

  #   ga_entity_set_fitness (this_entity, 
  #      - (fabs(0.75-A) + SQU(0.95-B) + fabs(CUBE(0.23-C)) + FOURTH_POW(0.71-D))
  #      );
  #
  # почему пользователь то записывает ответ (fitness) в системную область ?,
  
  set f1             [expr      0.75 - $A]
  set f2 [SQU        [expr      0.95 - $B]]
  set f3 [CUBE       [expr      0.23 - $C]]
  set f4 [FOURTH_POW [expr      0.71 - $D]]

  set fitness [expr - (abs ($f1) + $f2 + abs ($f3) + $f4 )]
 
  ga_entity_set_fitness $this_entity $fitness 

  return true
}
#-------------------------------------------------------------------------------
# proc  my_random_double {max} {

#   if {$::is_my_random} {
#     # это пока простая замена
#     #
#     set rd [expr {rand() * $max}]

#   } else {

#     # а надо бы вызывать правильную функцию
#     #
#     set rd [random_double $max]
#   }

#   # а надо ли здесь форматировать?
#   # 
#   #return [format "%.2f" $rd]
#   return $rd
# }
#-------------------------------------------------------------------------------
# Seed genetic data.

# /* static */ boolean 
# _test_seed (population *pop, entity *adam)
#-------------------------------------------------------------------------------
proc _test_seed {pop adam} {

  # /* Checks. */
  #   if (!pop)  die ("Null pointer to population structure passed.");
  #   if (!adam) die ("Null pointer to entity structure passed.");
  
  # /* Seeding. */
  
  #   ((double *) adam->chromosome[0]) [0] = random_double (2.0);
  #   ((double *) adam->chromosome[0]) [1] = random_double (2.0);
  #   ((double *) adam->chromosome[0]) [2] = random_double (2.0);
  #   ((double *) adam->chromosome[0]) [3] = random_double (2.0);

  # пока (а может и всегда!) будем делать с ОДНОЙ хромосомой 
  #

  #$adam set_chromo_gen 0  [random_double 2.0]
  #$adam set_chromo_gen 1  [random_double 2.0]
  #$adam set_chromo_gen 2  [random_double 2.0]
  #$adam set_chromo_gen 3  [random_double 2.0]

  ent_set_chromo_gen_ $adam 0  [random_double 2.0]
  ent_set_chromo_gen_ $adam 1  [random_double 2.0]
  ent_set_chromo_gen_ $adam 2  [random_double 2.0]
  ent_set_chromo_gen_ $adam 3  [random_double 2.0]

  return true;
}
#-------------------------------------------------------------------------------
# synopsis:	Generation callback
# /* static */ boolean 
# _test_generation_callback (int generation, population *pop)

# //------------------------------------------------------------------------------
proc _test_generation_callback {generation pop} {

  #   entity  *best;   /* Fittest entity. */
  #   best = ga_get_entity_from_rank (pop, 0);
  # 
  #set best [$pop get_entity 0]
  set best [pop_get_entity_ $pop  0]
  
  #   printf ("%d: A = %f B = %f C = %f D = %f (fitness = %f)\n",
  #             generation,
  #             ((double *) best->chromosome[0]) [0],
  #             ((double *) best->chromosome[0]) [1],
  #             ((double *) best->chromosome[0]) [2],
  #             ((double *) best->chromosome[0]) [3],
  #             ga_entity_get_fitness (best)
  #           );


  #set best_fit    [$pop  get_entity_fitness $best]
  #set best_chromo [$best get_chromosome]
  set best_chromo [ent_get_chromosome_ $best]
  set best_fit    [$best cget -fitness]
  
  set A [lindex $best_chromo 0]
  set B [lindex $best_chromo 1]
  set C [lindex $best_chromo 2]
  set D [lindex $best_chromo 3]
  
  puts [format "%3d  : A = %f B = %f C = %f D = %f (fitness = %f) "  $generation \
          $A $B $C $D $best_fit]
  
  
  return true;
}
# //------------------------------------------------------------------------------
# //  synopsis:     Convert to double array.
# //------------------------------------------------------------------------------
# boolean 
# _test_to_double (population *pop, entity *this_entity, double *array)
# {

#   if (!pop)         die ("Null pointer to population structure passed.");
#   if (!this_entity) die ("Null pointer to entity structure passed.");

#   array[0] = ((double *)this_entity->chromosome[0]) [0];
#   array[1] = ((double *)this_entity->chromosome[0]) [1];
#   array[2] = ((double *)this_entity->chromosome[0]) [2];
#   array[3] = ((double *)this_entity->chromosome[0]) [3];

#   return TRUE;
# }
# //------------------------------------------------------------------------------
# //  synopsis:     Convert from double array.
# //------------------------------------------------------------------------------
# boolean 
# _test_from_double (population *pop, entity *this_entity, double *array)
# {

#   if (!pop) die ("Null pointer to population structure passed.");
#   if (!this_entity) die ("Null pointer to entity structure passed.");

#   if (!this_entity->chromosome) die ("Entity has no chromsomes.");

#   ((double *) this_entity->chromosome[0]) [0] = array[0];
#   ((double *) this_entity->chromosome[0]) [1] = array[1];
#   ((double *) this_entity->chromosome[0]) [2] = array[2];
#   ((double *) this_entity->chromosome[0]) [3] = array[3];

#   return TRUE;
# }
# //------------------------------------------------------------------------------
# //  synopsis:	Generation callback
# //------------------------------------------------------------------------------
# boolean 
# _test_iteration_callback (int iteration, entity *solution)
# //------------------------------------------------------------------------------
proc _test_iteration_callback {iteration solution} \
{

  #set ch [$solution get_chromosome]
  set ch [ent_get_chromosome_ $solution]
  set fi [$solution cget -fitness]

  #   printf ( "%d: A = %f B = %f C = %f D = %f (fitness = %f)\n",
  #           iteration,
  #           ((double *) solution->chromosome[0]) [0],
  #           ((double *) solution->chromosome[0]) [1],
  #           ((double *) solution->chromosome[0]) [2],
  #           ((double *) solution->chromosome[0]) [3],
  #           solution->fitness );
  
  set A [lindex $ch 0]
  set B [lindex $ch 1]
  set C [lindex $ch 2]
  set D [lindex $ch 3]
  
  puts [format "%3d  : A = %f B = %f C = %f D = %f (fitness = %f) "  $iteration \
          $A $B $C $D $fi]

  return true
}
# //------------------------------------------------------------------------------
# //  synopsis:     Calculate gradients analytically.
# //------------------------------------------------------------------------------
# double 
# _test_analytical_gradient (population *pop, entity *this_entity, double *params, double *grad)
# //------------------------------------------------------------------------------
proc _test_analytical_gradient {pop this_entity params &grad} \
{

  USE_REFS

  #   double    grms = 0.0;	 /* RMS gradient. */
  set grms  0.0

  #   double    A, B, C, D;	 /* The parameters. */
  #   double    g0, g1, g2, g3;
  
  #   if (! pop)         die ("Null pointer to population structure passed.");
  #   if (! this_entity) die ("Null pointer to entity structure passed.");
  
  set A [lindex $params 0]
  set B [lindex $params 1]
  set C [lindex $params 2]
  set D [lindex $params 3]
  
  #   g0 = A > 0.75+TINY ? -1.0 : ( A < 0.75-TINY ? 1.0 : 0.0 );

  if {$A > [expr 0.75 + $::TINY]} {
    set g0  -1.0 

  } else {

    if {$A < [expr 0.75 - $::TINY]} {
      set tmp 1.0
    } else {
      set tmp 0.0
    }
    set g0 $tmp  
  }

  set g1 [expr 0.95 - $B]

  #   g2 = C > 0.23 ? -SQU(0.23 - C) : SQU(0.23 - C);

  if {$C > 0.23} {
    set g2 -[SQU [expr 0.23 - $C]]
  } else {
    set g2  [SQU [expr 0.23 - $C]]
  }

  set g3 [CUBE [expr 0.71 - $D]] ;# тут бы макросами может сделать?
  

  #   grad[0] = g0 ;
  #   grad[1] = g1 ;
  #   grad[2] = g2 ;
  #   grad[3] = g3 ;

  set grad {}

  lappend grad $g0
  lappend grad $g1
  lappend grad $g2
  lappend grad $g3
  
  set grms [expr sqrt ($g0 * $g0 + $g1 * $g1 + $g2 * $g2 + $g3 * $g3)]

  return $grms
}
# //------------------------------------------------------------------------------
# //------------------------------------------------------------------------------


# //******************************************************************************



# //******************************************************************************
# /* To test+time these functions, compile with something like:
#    gcc ga_qsort.c -DGA_QSORT_TIME -DGA_QSORT_COMPILE_MAIN ga_core.o \
#      -o qsort `gtk-config --cflags` \
#      -DNO_TRACE -DMEMORY_ALLOC_DEBUG \
#      -DQSORT_DEBUG=3
#  */
# //******************************************************************************
# /* #ifdef GA_QSORT_COMPILE_MAIN */
# /* int main(int argc, char **argv) */
# /* #else */
# //------------------------------------------------------------------------------
# boolean ga_qsort_test (void)
#   /* #endif */
# {
#   int		i;		/* Loop variable */
#   population	*pop=NULL;	/* Test population */
  
#   //plog(LOG_NORMAL, "GENNA");
  
#   printf ("1... \n");
#   pop = ga_population_new (50000, /* 4, !!!??? */ 32);
  
#   printf ("2... \n");
#   /* Randomly assigned fitnesses */
#   for (i=0; i<50000; i++)
#   {
#     pop->entity_array[i]->fitness = (double) rand()/RAND_MAX;
#     pop->entity_iarray[i] = pop->entity_array[i];
#   }
#   pop->size=50000;
  
#   printf ("3... \n");
#   plog(LOG_NORMAL, "Sorting random list.");
#   sort_population (pop);
  
#   plog(LOG_NORMAL, "Sorting ordered list.");
#   sort_population(pop);
  
#   /* Reverse population */
#   for (i=0; i<50000/2; i++)
#     swap_e(pop->entity_iarray[i],pop->entity_iarray[24999-i]);
  
#   plog(LOG_NORMAL, "Sorting reverse-ordered list.");
#   sort_population(pop);
  
#   /* Write list */
#   /*
#     for (i=0; i<50000; i++)
#     printf("%6d: %f\n", i, pop->entity_iarray[i]->fitness);
#     */
  
#   /* #ifdef GA_QSORT_COMPILE_MAIN */
#   /*   exit(EXIT_SUCCESS); */
#   /* #else */
#   return TRUE;
#   /* #endif */
# }
# //------------------------------------------------------------------------------
# //  Synopsis:	Test program for GAUL's basic genetic algorithm.
# //
# //		This program aims to solve a function of the form
# //		(0.75-A) + (0.95-B)^2 + (0.23-C)^3 + (0.71-D)^4 = 0
# //------------------------------------------------------------------------------
# void 
proc test_ga {} {

  #   population		*pop;	  /* Population of solutions. */
  # 
  parse_opts  population_size max_generations  200 500

  puts ""

  random_seed 23091975

  #   pop = ga_genesis_double (
  #        200,			      /* const int              population_size      */
  #        1,			      /* const int              num_chromo           */
  #        4,			      /* const int              len_chromo           */
  #        _test_generation_callback, /* GAgeneration_hook      generation_hook      */
  #        NULL,                      /* GAiteration_hook       iteration_hook       */
  #        NULL,                      /* GAdata_destructor      data_destructor      */
  #        NULL,                      /* GAdata_ref_incrementor data_ref_incrementor */
  #        _test_score,	                       /* GAevaluate             evaluate    */
  #        _test_seed,                         /* GAseed                 seed        */
  #        NULL,                               /* GAadapt                adapt       */
  #        ga_select_one_bestof2,              /* GAselect_one           select_one  */
  #        ga_select_two_bestof2,              /* GAselect_two           select_two  */
  #        ga_mutate_double_singlepoint_drift, /* GAmutate               mutate      */
  #        ga_crossover_double_doublepoints,   /* GAcrossover            crossover   */
  #        NULL,			       /* GAreplace              replace     */
  #        NULL			               /* vpointer               User data   */
  #        );

  set pop [ga_genesis_double                  \
           $population_size		      \
           1			              \
           4			              \
           _test_generation_callback          \
           NULL			              \
           NULL			              \
           NULL			              \
           _test_score		              \
           _test_seed		              \
           NULL			              \
           ga_select_one_bestof2	      \
           ga_select_two_bestof2	      \
           ga_mutate_double_singlepoint_drift \
           ga_crossover_double_doublepoints   \
           NULL			              \
           NULL			              \
          ]

  #   ga_population_set_parameters(
  #        pop,				/* population      *pop            */
  #        GA_SCHEME_DARWIN,		/* const ga_scheme_type     scheme */
  #        GA_ELITISM_PARENTS_SURVIVE,	/* const ga_elitism_type   elitism */
  #        0.8,				/* double  crossover               */
  #        0.2,				/* double  mutation                */
  #        0.0      		        /* double  migration               */
  #        );

  ga_population_set_parameters                            \
                               $pop	                  \
                               GA_SCHEME_DARWIN	          \
                               GA_ELITISM_PARENTS_SURVIVE \
                               0.8			  \
                               0.2			  \
                               0.0      	          
                               

  # пока здесь остановимся, осмотримся и распечатаемся:
  # (похоже инициация-seed еще не выполнялась ?) давай пока тут выполним:
  #
  ga_population_seed $pop
  #
  #$pop print
  #exit


  #   ga_evolution (
  #        pop,				/* population	*pop            */
  #        500				/* const int	max_generations */
  #        );
  
  ga_evolution  $pop $max_generations   
  
  #   ga_extinction (pop);
  
  puts ""

  return
}
# //------------------------------------------------------------------------------
# //******************************************************************************
# /*
#  * The solution string.
#  */
# static char *target_text="When we reflect on this struggle, we may console ourselves with the full belief, that the war of nature is not incessant, that no fear is felt, that death is generally prompt, and that the vigorous, the healthy, and the happy survive and multiply.";


# //------------------------------------------------------------------------------
# //  Score solution.
# //------------------------------------------------------------------------------
# boolean 
# struggle_score (population *pop, entity *entity)
# {
#   int		k;		/* Loop variable over all alleles. */

#   entity->fitness = 0.0;

#   /* Loop over alleles in chromosome. */
#   for (k = 0; k < pop->len_chromosomes; k++)
#   {
#     if ( ((char *)entity->chromosome[0])[k] == target_text[k])
#       entity->fitness+=1.0;
#     /*
#       * Component to smooth function, which helps a lot in this case:
#       * Comment it out if you like.
#       */
#     entity->fitness += (127.0-abs((int)((char *)entity->chromosome[0])[k]-target_text[k]))/50.0;
#   }

#   return TRUE;
# }
# //------------------------------------------------------------------------------
# //  Write usage details.
# //------------------------------------------------------------------------------
# void 
# write_usage (void)
# {
  
#   printf ("\n"
#          "saveload ╘2002-2004, \"Stewart Adcock\" <stewart@linux-domain.com>\n"
#          "\n");

#   printf ("Usage: saveload [-n INTEGER] [-i FILENAME] -o FILENAME\n"
#          "-o FILENAME   Write a population file to FILENAME.\n"
#          "-i FILENAME   Read population from FILENAME, otherwise create a new population.\n"
#          "-n INTEGER    Number of generations to perform.  [default=10]\n"
#          "\n");

#   return;
# }
# //------------------------------------------------------------------------------
# void 
# test_saveload (int argc, char **argv)
#   {
#   population	*pop=NULL;		/* Population of solutions. */
#   char		*filename_in=NULL;	/* Input filename. */
#   char		*filename_out=NULL;	/* Output filename. */
#   int		i;			/* Loop variable over command-line arguments. */
#   int		generations=10;		/* Number of generations to perform. */
#   char		*beststring=NULL;	/* Human readable form of best solution. */
#   size_t	beststrlen=0;		/* Length of beststring. */

#   random_seed (42);

#   /*
#     * Parse command-line.  Expect '-i FILENAME' for a population to read,
#     * otherwise a new population will be created.
#     * '-o FILENAME' is absolutely required to specify a file to write to.
#     * If we don't get these, then we will write the options.
#     */
#   if (argc < 2) {
#     write_usage ();
#     exit (0);
#     }

#   //printf ("1... \n");

#   for (i=1; i<argc; i++) {

#     //printf ("2... \n");

#     if (strcmp(argv[i], "-i") == 0) { /* Read pop. */
#       i++;
#       if (i==argc) 
#         {
#         printf("Input filename not specified.\n");
#         write_usage();
#         exit(0);
#         }
#       filename_in = argv[i];
#       printf ("Input filename set to \"%s\"\n", filename_in);
#       }

#     else if (strcmp(argv[i], "-o")==0)
#       {	/* Out pop. */
#       i++;
#       if (i==argc) {
#         printf ("Output filename not specified.\n");
#         write_usage ();
#         exit (0);
#       }
#       filename_out = argv[i];
#       printf ("Output filename set to \"%s\"\n", filename_out);
#       }

#     else if (strcmp(argv[i], "-n")==0)
#       { /* Number of generations requested. */
#       i++;
#       if (i==argc)
#         {
#         printf("Number of generations not specified.\n");
#         write_usage();
#         exit(0);
#         }
#       generations = atoi(argv[i]);
#       printf("Number of generations set to %d.\n", generations);
#       }

#     else
#       {	/* Error parsing args. */
#       printf ("Unable to parse command-line argument \"%s\"\n", argv[i]);
#       write_usage ();
#       exit (0);
#       }
#     }

# /*
#  * Check that we had the required inputs.
#  */
#   if (filename_out == NULL)
#     {
#     printf("No output filename was specified.\n");
#     write_usage();
#     exit(0);
#     }

# /*
#  * Read or create population.
#  */
#   if (filename_in == NULL)
#     {
#     pop = ga_genesis_char(
#        100,			/* const int              population_size */
#        1,			/* const int              num_chromo */
#        strlen(target_text),	/* const int              len_chromo */
#        NULL,		 	/* GAgeneration_hook      generation_hook */
#        NULL,			/* GAiteration_hook       iteration_hook */
#        NULL,			/* GAdata_destructor      data_destructor */
#        NULL,			/* GAdata_ref_incrementor data_ref_incrementor */
#        struggle_score,			/* GAevaluate             evaluate */
#        ga_seed_printable_random,	/* GAseed                 seed */
#        NULL,				/* GAadapt                adapt */
#        ga_select_one_roulette,		/* GAselect_one           select_one */
#        ga_select_two_roulette,		/* GAselect_two           select_two */
#        ga_mutate_printable_singlepoint_drift,	/* GAmutate               mutate */
#        ga_crossover_char_allele_mixing,	/* GAcrossover            crossover */
#        NULL,			/* GAreplace replace */
#        NULL			/* vpointer	User data */
#             );

#     ga_population_set_parameters(
#        pop,				/* population      *pop */
#        GA_SCHEME_DARWIN,		/* const ga_scheme_type    scheme */
#        GA_ELITISM_PARENTS_SURVIVE,	/* const ga_elitism_type   elitism */
#        1.0,				/* double  crossover */
#        0.1,				/* double  mutation */
#        0.0				/* double  migration */
#                               );
#     }
#   else
#     {
#     pop = ga_population_read(filename_in);
#     pop->evaluate = struggle_score;	/* Custom functions can't be saved and
#                                          * therefore "pop->evaluate" must be
# 					 * defined manually.  Likewise, if a
# 					 * custom crossover routine was used, for
# 					 * example, then that would also need
# 					 * to be manually defined here.
# 					 */
#     }

#   ga_evolution(
#        pop,				/* population              *pop */
#        generations			/* const int               max_generations */
#               );

#   printf("The final solution with seed = %d was:\n", i);
#   beststring = ga_chromosome_char_to_string (pop, ga_get_entity_from_rank(pop,0), 
#                                              beststring, &beststrlen);
#   printf("%s\n", beststring);
#   printf("With score = %f\n", ga_entity_get_fitness(ga_get_entity_from_rank(pop,0)) );

#   ga_population_write(pop, filename_out);

#   printf("Population has been saved as \"%s\"\n", filename_out);

#   ga_extinction(pop);

#   s_free(beststring);

#   return;
#   //exit(EXIT_SUCCESS);
#   }
# //******************************************************************************
# //******************************************************************************
# //  Synopsis:	Test program for GAUL's simplex algorithm.
# //
# //		This program aims to solve a function of the form
# //		(0.75-A) + (0.95-B)^2 + (0.23-C)^3 + (0.71-D)^4 = 0
# //------------------------------------------------------------------------------
# void 
# test_simplex_1 ()
# {
#   population  *pop;			/* Population of solutions. */
#   entity      *solution;		/* Optimised solution.      */

#   random_seed (23091975);

#   pop = ga_genesis_double (
#        50,			 /* const int              population_size         */
#        1,			 /* const int              num_chromo              */
#        4,			 /* const int              len_chromo              */
#        NULL,			 /* GAgeneration_hook      generation_hook         */
#        _test_iteration_callback, /* GAiteration_hook       iteration_hook          */
#        NULL,			 /* GAdata_destructor      data_destructor         */
#        NULL,			 /* GAdata_ref_incrementor data_ref_incrementor    */
#        _test_score,		 /* GAevaluate             evaluate                */
#        _test_seed,		 /* GAseed                 seed                    */
#        NULL,			 /* GAadapt                adapt                   */
#        NULL,			 /* GAselect_one           select_one              */
#        NULL,			 /* GAselect_two           select_two              */
#        ga_mutate_double_singlepoint_drift, /* GAmutate	   mutate                  */
#        NULL,			 /* GAcrossover            crossover               */
#        NULL,			 /* GAreplace              replace                 */
#        NULL			 /* vpointer	           User data               */
#        );

#   ga_population_set_simplex_parameters (
#        pop,				/* population		*pop               */
#        4,				/* const int		num_dimensions     */
#        0.5,				/* const double         Initial step size. */
#        _test_to_double,			/* const GAto_double	to_double          */
#        _test_from_double		/* const GAfrom_double	from_double        */
#        );

#   /* Evaluate and sort the initial population members (i.e. select best of 50 random solutions. */
#   ga_population_score_and_sort (pop);

#   /* Use the best population member. */
#   solution = ga_get_entity_from_rank (pop, 0);

#   ga_simplex (
#        pop,				/* population		*pop           */
#        solution,			/* entity		*solution      */
#        10000				/* const int		max_iterations */
#        );

#   ga_extinction (pop);

#   return;
#   //exit (EXIT_SUCCESS);
# }
# //------------------------------------------------------------------------------
# void 
# test_simplex_2 ()
# {
#   population		*pop;			/* Population of solutions.     */
#   entity		*solution;		/* Optimised solution.          */

#   random_seed (23091975);

#   pop = ga_genesis_double (
#        50,			 /* const int              population_size      */
#        1,			 /* const int              num_chromo           */
#        4,			 /* const int              len_chromo           */
#        NULL,			 /* GAgeneration_hook      generation_hook      */
#        _test_iteration_callback, /* GAiteration_hook       iteration_hook       */
#        NULL,			 /* GAdata_destructor      data_destructor      */
#        NULL,			 /* GAdata_ref_incrementor data_ref_incrementor */
#        _test_score,		 /* GAevaluate             evaluate             */
#        _test_seed,		 /* GAseed                 seed                 */
#        NULL,			 /* GAadapt                adapt                */
#        NULL,			 /* GAselect_one           select_one           */
#        NULL,			 /* GAselect_two           select_two           */
#        ga_mutate_double_singlepoint_drift,  /* GAmutate	mutate                  */
#        NULL,			 /* GAcrossover            crossover            */
#        NULL,			 /* GAreplace              replace              */
#        NULL			 /* vpointer	           User data            */
#        );

#   ga_population_set_simplex_parameters (
#        pop,			 /* population		   *pop                 */
#        4,			 /* const int		   num_dimensions       */
#        0.5,			 /* const double           Initial step size.   */
#        _test_to_double,		 /* const GAto_double	   to_double            */
#        _test_from_double	 /* const GAfrom_double	   from_double          */
#        );

#   /* Evaluate and sort the initial population members (i.e. select best of 50 random solutions. */
#   ga_population_score_and_sort (pop);

#   /* Use the best population member. */
#   solution = ga_get_entity_from_rank (pop, 0);

#   ga_simplex (
#        pop,				/* population		*pop           */
#        solution,			/* entity		*solution      */
#        10000				/* const int		max_iterations */
#        );

#   ga_extinction (pop);

#   return;
#   //exit (EXIT_SUCCESS);
# }
# //******************************************************************************
# //------------------------------------------------------------------------------
# //  Synopsis:	Test program for GAUL's steepest ascent algorithm.
# //
# //		This program aims to solve a function of the form
# //		(0.75-A) + (0.95-B)^2 + (0.23-C)^3 + (0.71-D)^4 = 0
# //------------------------------------------------------------------------------
# //
# // в чем тут фишка конвертации from и to DOUBLE - не понял!
# // 
# //------------------------------------------------------------------------------
# void 
# main_sd1 (/* int argc, char **argv */)
# {
#   population		*pop;			/* Population of solutions. */
#   entity		*solution;		/* Optimised solution.      */

#   random_seed (23091975);

#   pop = ga_genesis_double (
#        50,			 /* const int              population_size      */
#        1,			 /* const int              num_chromo           */
#        4,			 /* const int              len_chromo           */
#        NULL,			 /* GAgeneration_hook      generation_hook      */
#        _test_iteration_callback, /* GAiteration_hook       iteration_hook       */
#        NULL,			 /* GAdata_destructor      data_destructor      */
#        NULL,			 /* GAdata_ref_incrementor data_ref_incrementor */
#        _test_score,		 /* GAevaluate             evaluate             */
#        _test_seed,		 /* GAseed                 seed                 */
#        NULL,			 /* GAadapt                adapt                */
#        NULL,			 /* GAselect_one           select_one           */
#        NULL,			 /* GAselect_two           select_two           */
#        NULL,			 /* GAmutate               mutate               */
#        NULL,			 /* GAcrossover            crossover            */
#        NULL,			 /* GAreplace              replace              */
#        NULL			 /* vpointer               User data            */
#        );

#   ga_population_set_gradient_parameters (
#        pop,				/* population		*pop           */
#        _test_to_double,		        /* const GAto_double	to_double      */
#        _test_from_double,		/* const GAfrom_double	from_double    */
#        _test_analytical_gradient,	/* const GAgradient	gradient       */
#        4,				/* const int		num_dimensions */
#        0.1				/* const double		step_size      */
#        );

#   /* Evaluate and sort the initial population members (i.e. select best of 50 random solutions. */
#   ga_population_score_and_sort (pop);

#   /* Use the best population member. */
#   solution = ga_get_entity_from_rank (pop, 0);

#   ga_steepestascent (
#        pop,				/* population		*pop           */
#        solution,			/* entity		*solution      */
#        1000				/* const int		max_iterations */
#        );

#   ga_extinction (pop);

#   exit (EXIT_SUCCESS);
# }
# //------------------------------------------------------------------------------
proc main_sd2 {} \
{

  #   population	*pop;			/* Population of solutions. */
  #   entity		*solution;		/* Optimised solution.      */
  
  random_seed  23091975
  
  #set population_size   50
  #set max_iterations  1000

  parse_opts  population_size max_iterations  50 1000

  if {$::is_print} {
    puts ""
  }

  #   pop = ga_genesis_double (
  #        50,			     /* const int              population_size      */
  #        1,			     /* const int              num_chromo           */
  #        4,			     /* const int              len_chromo           */
  #        NULL,		     /* GAgeneration_hook      generation_hook      */
  #        _test_iteration_callback, /* GAiteration_hook       iteration_hook       */
  #        NULL,	             /* GAdata_destructor      data_destructor      */
  #        NULL,	             /* GAdata_ref_incrementor data_ref_incrementor */
  #        _test_score,		     /* GAevaluate             evaluate             */
  #        _test_seed,		     /* GAseed                 seed                 */
  #        NULL,		     /* GAadapt                adapt                */
  #        NULL,		     /* GAselect_one           select_one           */
  #        NULL,		     /* GAselect_two           select_two           */
  #        NULL,		     /* GAmutate               mutate               */
  #        NULL,		     /* GAcrossover            crossover            */
  #        NULL,	             /* GAreplace              replace              */
  #        NULL		             /* vpointer	       User data            */
  #        );
  
  set pop [ga_genesis_double                  \
           $population_size		      \
           1			              \
           4			              \
           NULL			              \
           _test_iteration_callback           \
           NULL			              \
           NULL			              \
           _test_score		              \
           _test_seed		              \
           NULL			              \
           NULL	                              \
           NULL	                              \
           NULL                               \
           NULL                               \
           NULL			              \
           NULL			              \
          ]

  #   ga_population_set_gradient_parameters (
  #        pop,				/* population		*pop           */
  #        NULL,			/* const GAto_double	to_double      */
  #        NULL,			/* const GAfrom_double	from_double    */
  #        _test_analytical_gradient,	/* const GAgradient	gradient       */
  #        0,				/* const int		num_dimensions */
  #        0.1				/* const double		step_size      */
  #        );
  
  ga_population_set_gradient_parameters  \
          $pop		                 \
          NULL			         \
          NULL			         \
          _test_analytical_gradient      \
          0			         \
          0.1				
          
  # почему тут надо так искуссствено?
  # 
  #ga_population_seed $pop


  # Evaluate and sort the initial population members (i.e. select best of 
  # 50 random solutions.
  #
  ga_population_score_and_sort  $pop
  
  if {$::is_print} {
    $pop print
    puts ""
  }

  # Use the best population member.
  # 
  #set solution [ga_get_entity_from_rank  $pop 0]
  #
  # сделаем пока так, а то не понятно, как там возвращается и зачем
  # 
  set solution NULL
  
  #   ga_steepestascent_double (
  #        pop,				/* population		*pop           */
  #        solution,			/* entity		*solution      */
  #        1000				/* const int		max_iterations */
  #        );
  
     ga_steepestascent_double   \
          $pop		        \
          $solution             \
          $max_iterations       \
         
  
  #   ga_extinction (pop);  
  #  exit (EXIT_SUCCESS);

  if {$::is_print} {
    puts ""
  }

  return
}
# /*******************************************************************************
#   test_de.c

#   Synopsis:	Test program for GAUL's differential evolution algorithm.

# 		This program aims to solve a function of the form
# 		(0.75-A) + (0.95-B)^2 + (0.23-C)^3 + (0.71-D)^4 = 0

# *******************************************************************************/

# //#include "gaul.h"
# //#include "l_test_LIB.h"

# //------------------------------------------------------------------------------
# struct strategies_t
# {
#   char			*label; 
#   ga_de_strategy_type	strategy;
#   ga_de_crossover_type	crossover;
#   int			num_perturbed;
#   double		crossover_factor;
#   double		weighting_factor;
#   double		weighting_factor2;
# };

# //------------------------------------------------------------------------------

# static struct strategies_t strategy[]={
# ....
# { NULL, 0, 0, 0, 0.0, 0.0 } };


# это едиинчный тест для отладки
# 
set strategy_test {
  { "DE/best/1/bin"            GA_DE_STRATEGY_BEST        GA_DE_CROSSOVER_BINOMIAL     1  0.8  0.5  0.5 }
  { "DE/rand-to-best/1/bin"    GA_DE_STRATEGY_RANDTOBEST  GA_DE_CROSSOVER_BINOMIAL     1  0.8  0.5  0.5 }
}

# это полный список тестов (оригинальный)
# 
set strategy_full_origin {

  { "DE/best/1/exp (DE0)"      GA_DE_STRATEGY_BEST        GA_DE_CROSSOVER_EXPONENTIAL  1  0.8  0.5  0.5 }
  { "DE/best/1/exp (DE0)"      GA_DE_STRATEGY_BEST        GA_DE_CROSSOVER_EXPONENTIAL  1  0.8  2.0  0.0 }
  { "DE/best/2/exp"            GA_DE_STRATEGY_BEST        GA_DE_CROSSOVER_EXPONENTIAL  2  0.8  0.5  0.5 }
  { "DE/best/2/exp"            GA_DE_STRATEGY_BEST        GA_DE_CROSSOVER_EXPONENTIAL  2  0.8  2.0  0.0 }
  { "'DE/best/3/exp'"          GA_DE_STRATEGY_BEST        GA_DE_CROSSOVER_EXPONENTIAL  3  0.8  0.5  0.5 }
  { "'DE/best/3/exp'"          GA_DE_STRATEGY_BEST        GA_DE_CROSSOVER_EXPONENTIAL  3  0.8  2.0  0.0 }
  { "DE/rand/1/exp (DE1)"      GA_DE_STRATEGY_RAND        GA_DE_CROSSOVER_EXPONENTIAL  1  0.8  0.5  0.5 }
  { "DE/rand/1/exp (DE1)"      GA_DE_STRATEGY_RAND        GA_DE_CROSSOVER_EXPONENTIAL  1  0.8  2.0  0.0 }
  { "DE/rand/2/exp"            GA_DE_STRATEGY_RAND        GA_DE_CROSSOVER_EXPONENTIAL  2  0.8  0.5  0.5 }
  { "DE/rand/2/exp"            GA_DE_STRATEGY_RAND        GA_DE_CROSSOVER_EXPONENTIAL  2  0.8  2.0  0.0 }
  { "'DE/rand/3/exp'"          GA_DE_STRATEGY_RAND        GA_DE_CROSSOVER_EXPONENTIAL  3  0.8  0.5  0.5 }
  { "'DE/rand/3/exp'"          GA_DE_STRATEGY_RAND        GA_DE_CROSSOVER_EXPONENTIAL  3  0.8  2.0  0.0 }
  { "DE/rand-to-best/1/exp"    GA_DE_STRATEGY_RANDTOBEST  GA_DE_CROSSOVER_EXPONENTIAL  1  0.8  0.5  0.5 }
  { "DE/rand-to-best/1/exp"    GA_DE_STRATEGY_RANDTOBEST  GA_DE_CROSSOVER_EXPONENTIAL  1  0.8  2.0  0.0 }
  { "'DE/rand-to-best/2/exp'"  GA_DE_STRATEGY_RANDTOBEST  GA_DE_CROSSOVER_EXPONENTIAL  2  0.8  0.5  0.5 }
  { "'DE/rand-to-best/2/exp'"  GA_DE_STRATEGY_RANDTOBEST  GA_DE_CROSSOVER_EXPONENTIAL  2  0.8  2.0  0.0 }

  { "DE/best/1/bin"            GA_DE_STRATEGY_BEST        GA_DE_CROSSOVER_BINOMIAL     1  0.8  0.5  0.5 }
  { "DE/best/1/bin"            GA_DE_STRATEGY_BEST        GA_DE_CROSSOVER_BINOMIAL     1  0.8  2.0  0.0 }
  { "DE/best/2/bin"            GA_DE_STRATEGY_BEST        GA_DE_CROSSOVER_BINOMIAL     2  0.8  0.5  0.5 }
  { "DE/best/2/bin"            GA_DE_STRATEGY_BEST        GA_DE_CROSSOVER_BINOMIAL     2  0.8  2.0  0.0 }
  { "'DE/best/3/bin'"          GA_DE_STRATEGY_BEST        GA_DE_CROSSOVER_BINOMIAL     3  0.8  0.5  0.5 }
  { "'DE/best/3/bin'"          GA_DE_STRATEGY_BEST        GA_DE_CROSSOVER_BINOMIAL     3  0.8  2.0  0.0 }
  { "DE/rand/1/bin"            GA_DE_STRATEGY_RAND        GA_DE_CROSSOVER_BINOMIAL     1  0.8  0.5  0.5 }
  { "DE/rand/1/bin"            GA_DE_STRATEGY_RAND        GA_DE_CROSSOVER_BINOMIAL     1  0.8  2.0  0.0 }
  { "DE/rand/2/bin"            GA_DE_STRATEGY_RAND        GA_DE_CROSSOVER_BINOMIAL     2  0.8  0.5  0.5 }
  { "DE/rand/2/bin"            GA_DE_STRATEGY_RAND        GA_DE_CROSSOVER_BINOMIAL     2  0.8  2.0  0.0 }
  { "'DE/rand/3/bin'"          GA_DE_STRATEGY_RAND        GA_DE_CROSSOVER_BINOMIAL     3  0.8  0.5  0.5 }
  { "'DE/rand/3/bin'"          GA_DE_STRATEGY_RAND        GA_DE_CROSSOVER_BINOMIAL     3  0.8  2.0  0.0 }
  { "DE/rand-to-best/1/bin"    GA_DE_STRATEGY_RANDTOBEST  GA_DE_CROSSOVER_BINOMIAL     1  0.8  0.5  0.5 }
  { "DE/rand-to-best/1/bin"    GA_DE_STRATEGY_RANDTOBEST  GA_DE_CROSSOVER_BINOMIAL     1  0.8  2.0  0.0 }
  { "'DE/rand-to-best/2/bin'"  GA_DE_STRATEGY_RANDTOBEST  GA_DE_CROSSOVER_BINOMIAL     2  0.8  0.5  0.5 }
  { "'DE/rand-to-best/2/bin'"  GA_DE_STRATEGY_RANDTOBEST  GA_DE_CROSSOVER_BINOMIAL     2  0.8  2.0  0.0 }
}



# //------------------------------------------------------------------------------
# //  synopsis:	Generation callback
# //------------------------------------------------------------------------------
# static boolean 
# test_generation_callback (int generation, population *pop)
# //------------------------------------------------------------------------------
proc test_generation_callback {generation pop} {

  #     //entity	*this_entity;	/* Top ranked entity. */
  
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
  # /*
  #   pop->de_params->weighting_factor = random_double_range(-2.0, 2.0);
  # */
  
  # /*
  #  * Write top ranked solution every tenth generation.  Note, that this
  #  * is not neccesarily the best solution because DE doesn't require
  #  * the population to be sorted, as genetic algorithms usually do.
  #  */
  
  if {[expr $generation % 10] == 0} {

    _test_generation_callback $generation $pop
  }
  
  return true
}
# //------------------------------------------------------------------------------
# void 
# test_de (/* int argc, char **argv */)

#-------------------------------------------------------------------------------
proc strategy_parse_and_print {s \
                       &label &strategy &crossover &num_perturbed &crossover_factor \
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

    puts ""
  }

  return
}
#-------------------------------------------------------------------------------
#proc test_de {population_size max_generations} {}
#-------------------------------------------------------------------------------
proc test_de {strategy} {

  #   population	*pop;	/* Population of solutions.       */
  #   entity		*best;	/* Fittest entity.                */
  #   int		i=0;	/* Loop variable over strategies. */
  
  parse_opts  population_size max_generations  40 50

  random_seed 23091975

  #   log_init (LOG_NORMAL, NULL, NULL, FALSE);
  puts ""

  #  while (strategy[i].label != NULL)
  foreach s $strategy {

    strategy_parse_and_print $s \
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

    set pop [ga_genesis_double         \
             $population_size          \
             1                         \
             4                         \
             test_generation_callback  \
             NULL                      \
             NULL                      \
             NULL                      \
             _test_score               \
             _test_seed                \
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
    ga_population_seed $pop
    
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
    ga_differentialevolution  $pop $max_generations			


    if {1} {
      #  //# предполагаем, что уже отсортирована популяция ??
      #  // 
      set best 0

    } else {

      # ну, а если не отсортирована, воспользуемся полученным расчетом по фитнесу:
      # 
      #set best [$pop cget -best] ;# вычисляется после "break"

      # пока придется так по-топорному (т.е. снова здесь повторить поиск лучшего):
      # 
      set rank_proc [$pop cget -rank]
      set best [find_best_solution $pop $rank_proc]
    }

    #set best_entity [$pop get_entity $best]
    set best_entity [pop_get_entity_ $pop  $best]

    #set best_fit    [$pop get_entity_fitness $best]
    set best_fit    [pop_get_entity_fitness_ $pop  $best]

    #set best_chromo [$best_entity get_chromosome]
    set best_chromo [ent_get_chromosome_ $best_entity]

    set A [lindex $best_chromo 0]
    set B [lindex $best_chromo 1]
    set C [lindex $best_chromo 2]
    set D [lindex $best_chromo 3]

    if {$::is_print} { 

      puts [format "FINAL BEST : numer = $best  fitness = %f" $best_fit]
      puts ""
      
      puts [format "   A = %f  ( 0.75 )" $A]
      puts [format "   B = %f  ( 0.95 )" $B]
      puts [format "   C = %f  ( 0.23 )" $C]
      puts [format "   D = %f  ( 0.71 )" $D]

    } else {
      puts [format "Final: A = %f B = %f C = %f D = %f (fitness = %f) "  $A $B $C $D $best_fit]
      puts ""
    }

    #     ga_extinction (pop);
    
  }

  #   exit (EXIT_SUCCESS);

  puts ""

  return
}
# //------------------------------------------------------------------------------
# /*******************************************************************************
#   test_moga.c

#   Synopsis:   Test program for GAUL's multiobjective genetic
# 	      algorithm.

# 	      This program aims to solve a function of the form
# 	      (0.75-A) + (0.95-B)^2 + (0.23-C)^3 + (0.71-D)^4 = 0

# 	      The values of the individual terms, A, B, C and D, are
# 	      the multiobjective terms.

# *******************************************************************************/

# //#include "gaul.h"
# //#include "l_test_LIB.h"

# //------------------------------------------------------------------------------
# //  synopsis:	Fitness function.
# //------------------------------------------------------------------------------
# static boolean 
# test_score (population *pop, entity *this_entity)
# {
#   double		A, B, C, D;	/* Parameters. */

#   A = ((double *) this_entity->chromosome[0]) [0];
#   B = ((double *) this_entity->chromosome[0]) [1];
#   C = ((double *) this_entity->chromosome[0]) [2];
#   D = ((double *) this_entity->chromosome[0]) [3];

#   this_entity->fitvector[0] = fabs (0.75-A);
#   this_entity->fitvector[1] = fabs (0.95-B);
#   this_entity->fitvector[2] = fabs (0.23-C);
#   this_entity->fitvector[3] = fabs (0.71-D);

#   this_entity->fitness = 
#     - (fabs(0.75-A) + SQU(0.95-B) + fabs(CUBE(0.23-C)) + FOURTH_POW(0.71-D));

#   return TRUE;
# }
# //------------------------------------------------------------------------------
# //  synopsis:	Generation callback
# //------------------------------------------------------------------------------
# static boolean 
# moga_test_generation_callback (int generation, population *pop)
# {
#   entity   *this_entity = ga_get_entity_from_rank (pop, 0);	/* The best entity. */

#   printf ("%d: A = %f B = %f C = %f D = %f (fitness = %f) pop_size %d\n",
#             generation,
#             ((double *)this_entity->chromosome[0]) [0],
#             ((double *)this_entity->chromosome[0]) [1],
#             ((double *)this_entity->chromosome[0]) [2],
#             ((double *)this_entity->chromosome[0]) [3],
#             ga_entity_get_fitness (this_entity),
#             pop->size );

#   return TRUE;
# }
# //------------------------------------------------------------------------------
# void 
# main_common (population *pop, ga_elitism_type elitism)
# {

#   pop = ga_genesis_double(
#        100,			/* const int              population_size      */
#        1,			/* const int              num_chromo           */
#        4,			/* const int              len_chromo           */
#        moga_test_generation_callback,/* GAgeneration_hook      generation_hook      */
#        //mgena       _test_generation_callback,/* GAgeneration_hook      generation_hook */
#        NULL,			/* GAiteration_hook       iteration_hook       */
#        NULL,			/* GAdata_destructor      data_destructor      */
#        NULL,			/* GAdata_ref_incrementor data_ref_incrementor */
#        test_score,		/* GAevaluate             evaluate             */
#        _test_seed,		/* GAseed                 seed                 */
#        NULL,			/* GAadapt                adapt                */
#        ga_select_one_bestof2,	/* GAselect_one           select_one           */
#        ga_select_two_bestof2,	/* GAselect_two           select_two           */
#        ga_mutate_double_singlepoint_drift,	/* GAmutate         mutate     */
#        ga_crossover_double_doublepoints,	/* GAcrossover      crossover  */
#        NULL,			/* GAreplace              replace              */
#        NULL			/* vpointer	          User data            */
#        );

#   ga_population_set_parameters(
#        pop,				/* population      *pop            */
#        GA_SCHEME_DARWIN,		/* const ga_scheme_type     scheme */
#        //GA_ELITISM_BEST_SET_SURVIVE,	/* const ga_elitism_type   elitism */
#        elitism,	
#        0.8,				/* double  crossover  */
#        0.2,				/* double  mutation   */
#        0.0      		        /* double  migration  */
#        );

#   ga_population_set_fitness_dimensions (pop, 4);

#   ga_evolution(
#        pop,				/* population	*pop            */
#        200				/* const int	max_generations */
#        );

#   ga_extinction (pop);

# }
# //------------------------------------------------------------------------------
# void 
# test_moga (/* int argc, char **argv */)
# {
#   population   *pop;		/* Population of solutions. */

#   random_seed (23091975);

#   printf ("Using the Best Set Multiobjective GA varient.\n");
#   main_common (pop, GA_ELITISM_BEST_SET_SURVIVE);

#   printf ("Using the Pareto Set Multiobjective GA varient.\n");
#   main_common (pop, GA_ELITISM_PARETO_SET_SURVIVE);

#   return;
#   //exit (EXIT_SUCCESS);
# }
# //------------------------------------------------------------------------------
proc main {} {

  global argc argv argv0
  global strategy_full_origin strategy_simp strategy_test

  if  {$argc == 0} { 
    puts "argc == 0"
    exit
  }
  #
  set mode [lindex $argv 0] ;# имя выч. задачи

  #set ::is_my_random 0  ;# 1 - это было мое ..

  if     {$mode == "ga"}       { test_ga } \
  elseif {$mode == "de"}       { test_de  $strategy_full_origin } \
  elseif {$mode == "de_test"}  { test_de  $strategy_test } \
  elseif {$mode == "sd2"}      { main_sd2 } \
  else {
    puts ""
    puts "ERROR mode = $mode"
    puts ""
  }

  #   if (!strcmp(argv[1], "qsort"))  ga_qsort_test ();
  #   if (!strcmp(argv[1], "io"))     test_saveload (argc-1, argv+1);

  #   if (!strcmp(argv[1], "simplex1"))  test_simplex_1 ();
  #   if (!strcmp(argv[1], "simplex2"))  test_simplex_2 ();
  
  #   if (!strcmp(argv[1], "sd1")) main_sd1 ();
  #   if (!strcmp(argv[1], "sd2")) main_sd2 ();
  
  #if {$mode == "de"}   {test_de $population_size $max_generations}
  #   if (!strcmp(argv[1], "moga")) test_moga ();
  
  #   exit (EXIT_SUCCESS);
}
# //------------------------------------------------------------------------------

main

# //------------------------------------------------------------------------------

# // ga_x_tester.tl  de 

# // ga_x_tester  ga 
# // ga_x_tester  moga 
# // ga_x_tester  sd1 
# // ga_x_tester  sd2
# // ga_x_tester  simplex1
# // ga_x_tester  simplex2 

# //******************************************************************************



