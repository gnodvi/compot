# /**********************************************************************
#   gaul.h
#  **********************************************************************

#source "../../compot/src/comlib/s-recd.tl"

namespace import ::struct::*


#   gaul - Genetic Algorithm Utility Library.
#   Copyright б╘2000-2006, Stewart Adcock <stewart@linux-domain.com>
#   All rights reserved.

#   Synopsis:	Public header file for GAUL.

# 		This file should be included by any code that will
# 		be linking to libgaul.

#  **********************************************************************/

# #ifndef GAUL_H_INCLUDED
# #define GAUL_H_INCLUDED

# /**********************************************************************
#  * Include requisite headers.
#  **********************************************************************/

# #include "c_all_util.h"	/* General header containing commonly
# 				   used convenience definitions.
# 				   This also includes a platform-
# 				   specific configuration file. */

# /**********************************************************************
#  * Forward declarations.
#  * (These datatypes are actually declared in src/gaul/ga_core.h)
#  **********************************************************************/

# /* The entity datatype stores single individuals. */
# typedef struct entity_t entity;

# /* The population datatype stores single populations. */
# typedef struct population_t population;

# /**********************************************************************
#  * Enumerated types, used to define varients of the GA algorithms.
#  **********************************************************************/

# /*
#  * Evolutionary mode.
#  */
# typedef enum ga_scheme_type_t
#   {
#   GA_SCHEME_DARWIN           = 0,
#   GA_SCHEME_LAMARCK_PARENTS  = 1,
#   GA_SCHEME_LAMARCK_CHILDREN = 2,
#   GA_SCHEME_LAMARCK_ALL      = 3,
#   GA_SCHEME_BALDWIN_PARENTS  = 4,
#   GA_SCHEME_BALDWIN_CHILDREN = 8,
#   GA_SCHEME_BALDWIN_ALL      = 12
#   } ga_scheme_type;

# /*
#  * Elitism mode.
#  */
# typedef enum ga_elitism_type_t
#   {
#   GA_ELITISM_UNKNOWN             = 0,
#   GA_ELITISM_NULL                = 0,
#   GA_ELITISM_PARENTS_SURVIVE     = 1,
#   GA_ELITISM_ONE_PARENT_SURVIVES = 2,
#   GA_ELITISM_PARENTS_DIE         = 3,
#   GA_ELITISM_RESCORE_PARENTS     = 4,
#   GA_ELITISM_BEST_SET_SURVIVE    = 5,
#   GA_ELITISM_PARETO_SET_SURVIVE  = 6
#   } ga_elitism_type;

# /*
#  * Stategies available with Differential Evolution implementation.
#  */
# typedef enum de_strategy_t
#   {
#   GA_DE_STRATEGY_UNKNOWN    = 0,
#   GA_DE_STRATEGY_BEST       = 1,
#   GA_DE_STRATEGY_RAND       = 2,
#   GA_DE_STRATEGY_RANDTOBEST = 3
#   } ga_de_strategy_type;

# typedef enum de_crossover_t
#   {
#   GA_DE_CROSSOVER_UNKNOWN     = 0,
#   GA_DE_CROSSOVER_BINOMIAL    = 1,
#   GA_DE_CROSSOVER_EXPONENTIAL = 2
#   } ga_de_crossover_type;

# /**********************************************************************
#  * Callback function typedefs.
#  **********************************************************************/
# /*
#  * Analysis and termination.
#  */
# // GAgeneration_hook is called at the beginning of each generation by
# // all evolutionary functions. 
# typedef boolean (*GAgeneration_hook) (const int generation, population *pop);
# // GAiteration_hook is called at the beginning of each iteration by
# // all non-evolutionary functions.
# typedef boolean (*GAiteration_hook) (const int iteration, entity *entity);

# /*
#  * Phenome (A general purpose per-entity and per-population data cache) handling.
#  */
# // GAdata_destructor is used to deallocate phenomic data.
# // GAdata_destructor is also used to deallocate population-wide data.
# typedef void  (*GAdata_destructor) (vpointer data);
# /* GAdata_ref_incrementor is used for reference counting of phenomic data. */
# typedef void    (*GAdata_ref_incrementor)(vpointer data);
# /* GAdata_copy is used for copying of population-wide data. */
# typedef vpointer (*GAdata_copy)(vpointer data);

# /*
#  * Genome handling.
#  */
# /* GAchromosome_constructor is used to allocate single chromosomes. */
# typedef boolean (*GAchromosome_constructor)(population *pop, entity *entity);
# /* GAchromosome_destructor is used to deallocate single chromosomes. */
# typedef void    (*GAchromosome_destructor)(population *pop, entity *entity);
# /* GAchromosome_replicate is used to clone single chromosomes. */
# typedef void    (*GAchromosome_replicate)(const population *pop, entity *parent, entity *child, const int chromosomeid);
# /* GAchromosome_to_bytes is used to pack genomic data into a
#  * contiguous block of memory. */
# typedef unsigned int    (*GAchromosome_to_bytes)(const population *pop, entity *joe, gaulbyte **bytes, unsigned int *max_bytes);
# /* GAchromosome_from_bytes is used to unpack genomic data from a
#  * contiguous block of memory. */
# typedef void    (*GAchromosome_from_bytes)(const population *pop, entity *joe, gaulbyte *bytes);
# /* GAchromosome_to_string is used to generate a human readable
#  * representation of genomic data. */
# typedef char    *(*GAchromosome_to_string)(const population *pop, const entity *joe, char *text, size_t *textlen);

# /*
#  * GA operations.
#  *
#  * FIXME: Adaptation prototype should match the mutation prototype so that
#  * the adaptation local optimisation algorithms may be used as mutation
#  * operators.
#  */
# /* GAevaluate determines the fitness of an entity. */
# typedef boolean (*GAevaluate)(population *pop, entity *entity);
# /* GAseed initialises the genomic contents of an entity. */
# typedef boolean	(*GAseed)(population *pop, entity *adam);
# /* GAadapt optimises/performs learning for an entity. */
# typedef entity *(*GAadapt)(population *pop, entity *child);
# /* GAselect_one selects a single entity from the population. */
# typedef boolean (*GAselect_one)(population *pop, entity **mother);
# /* GAselect_two selects a pair of entities from the population. */
# typedef boolean (*GAselect_two)(population *pop, entity **mother, entity **father);
# /* GAmutate introduces a mutation into an entity. */
# typedef void    (*GAmutate)(population *pop, entity *mother, entity *daughter);
# /* GAcrossover produces two new sets of chromosomes from two parent sets. */
# typedef void    (*GAcrossover)(population *pop, entity *mother, entity *father, entity *daughter, entity *son);
# /* GAreplace inserts a new entity into the population. */
# typedef void    (*GAreplace)(population *pop, entity *child);
# /* GArank Compare two entities and return 1, 0, or -1, if alpha should rank higher,
#  * they should have equal rank, or beta should rank higher. */
# typedef int	(*GArank)(population *alphapop, entity *alpha, population *betapop, entity *beta);

# /*
#  * Alternative heuristic search function operations.
#  * 
#  * GAtabu_accept     - Tabu-search tabu+aspiration criteria.
#  * GAsa_accept       - Simulated Annealing acceptance criteria.
#  * GAmutate_allele   - Mutate a single, specified, allele.
#  * GAto_double       - Map chromosomal data to double-precision float array.
#  * GAfrom_double     - Map chromosomal data from double-precision float array.
#  * GAgradient        - Return array of gradients.
#  * GAscan_chromosome - Produce next permutation of genome.
#  * GAcompare         - Compare two entities and return distance.
#  */
# typedef boolean	(*GAtabu_accept)(population *pop, entity *putative, entity *tabu);

# typedef boolean	(*GAsa_accept)(population *pop, entity *current, entity *trial);
# typedef boolean	(*GAmutate_allele)(population *pop, entity *parent, entity *child, const int chromosomeid, const int alleleid);
# typedef boolean	(*GAto_double)(population *pop, entity *entity, double *darray);
# typedef boolean	(*GAfrom_double)(population *pop, entity *entity, double *darray);
# typedef double	(*GAgradient)(population *pop, entity *entity, double *darray, double *varray);
# typedef boolean	(*GAscan_chromosome)(population *pop, entity *entity, int enumeration_num);
# typedef double	(*GAcompare)(population *pop, entity *alpha, entity *beta);

# /**********************************************************************
#  * Public prototypes.
#  **********************************************************************/

# /*
#  * Functions located in ga_core.c:
#  * (Basic entity and population handling)
#  */
# population  *ga_population_new (const int stable_size,
# 				/* const int num_chromosome, */
# 				const int len_chromosome);

# population   *ga_population_clone_empty (population *pop);
# population   *ga_population_clone (population *pop);
# int	      ga_get_num_populations (void);
# population   *ga_get_population_from_id (unsigned int id);
# unsigned int  ga_get_population_id (population *pop);
# unsigned int *ga_get_all_population_ids (void);
# population  **ga_get_all_populations (void);
# boolean	ga_entity_seed (population *pop, entity *e);
# boolean ga_population_seed (population *pop);
# double	ga_entity_evaluate (population *pop, entity *entity);
# boolean	ga_population_score_and_sort (population *pop);
# boolean	ga_population_sort (population *pop);
# int     ga_get_entity_rank (population *pop, entity *e);
# int     ga_get_entity_id (population *pop, entity *e);
# entity *ga_get_entity_from_id (population *pop, const unsigned int id);
# entity *ga_get_entity_from_rank (population *pop, const unsigned int rank);
# int	ga_get_entity_rank_from_id (population *pop, int id);
# int	ga_get_entity_id_from_rank (population *pop, int rank);
# boolean	ga_entity_dereference_by_rank (population *pop, int rank);
# boolean ga_entity_dereference (population *p, entity *dying);
# boolean ga_entity_dereference_by_id (population *pop, int id);
# void    ga_entity_clear_data (population *p, entity *entity, const int chromosome);
# void    ga_entity_blank (population *p, entity *entity);
# entity *ga_get_free_entity (population *pop);
# boolean ga_copy_data (population *pop, entity *dest, entity *src, const int chromosome);
# boolean ga_entity_copy_all_chromosomes (population *pop, entity *dest, entity *src);
# boolean ga_entity_copy_chromosome (population *pop, entity *dest, entity *src, int chromo);
# boolean ga_entity_copy (population *pop, entity *dest, entity *src);
# entity *ga_entity_clone (population *pop, entity *parent);

# void ga_population_send_by_mask (population *pop, int dest_node, int num_to_send, boolean *send_mask);
# void ga_population_send_every (population *pop, int dest_node);
# void ga_population_append_receive (population *pop, int src_node);
# population *ga_population_new_receive (int src_node);
# population *ga_population_receive (int src_node);
# void ga_population_send (population *pop, int dest_node);
# void ga_population_send_all (population *pop, int dest_node);

# entity	*ga_optimise_entity (population *pop, entity *unopt);
# void	ga_population_set_parameters (population            *pop,
#                                       const ga_scheme_type  scheme,
#                                       const ga_elitism_type elitism,
#                                       const double          crossover,
#                                       const double          mutation,
#                                       const double          migration);
# void	ga_population_set_scheme (population *pop, const ga_scheme_type  scheme);
# void	ga_population_set_elitism (population *pop, const ga_elitism_type elitism);
# void	ga_population_set_crossover (population *pop, const double crossover);
# void	ga_population_set_mutation (population *pop, const double mutation);
# void	ga_population_set_migration (population *pop, const double migration);
# void	ga_population_set_allele_mutation_prob (population *pop, const double prob);
# void	ga_population_set_allele_min_integer (population *pop, const int value);
# void	ga_population_set_allele_max_integer (population *pop, const int value);
# void	ga_population_set_allele_min_double (population *pop, const double value);
# void	ga_population_set_allele_max_double (population *pop, const double value);
# double  ga_population_get_crossover (population       *pop);
# double  ga_population_get_mutation (population       *pop);
# double  ga_population_get_migration (population       *pop);
# double  ga_population_get_allele_mutation_prob (population *pop);
# int     ga_population_get_allele_min_integer   (population *pop);
# int     ga_population_get_allele_max_integer   (population *pop);
# double  ga_population_get_allele_min_double    (population *pop);
# double  ga_population_get_allele_max_double    (population *pop);
# ga_scheme_type  ga_population_get_scheme  (population  *pop);
# ga_elitism_type ga_population_get_elitism (population  *pop);
# population  *ga_transcend (unsigned int id);
# unsigned int ga_resurect (population *pop);
# boolean ga_extinction (population *extinct);
# boolean ga_genocide (population *pop, int target_size);
# boolean ga_genocide_by_fitness (population *pop, double target_fitness);
# boolean ga_population_set_data (population *pop, vpointer data);
# boolean ga_population_set_data_managed (population *pop,
#                                         vpointer data,
#                                         GAdata_destructor population_data_destructor,
#                                         GAdata_copy population_data_copy);
# vpointer ga_population_get_data (population *pop);
# boolean  ga_entity_set_data  (population *pop, entity *e, SLList *data);
# SLList	*ga_entity_get_data (population *pop, entity *e);
# int	 ga_population_get_generation (population *pop);
# int	 ga_population_get_island (population *pop);

# double	 ga_entity_get_fitness (entity *e);
# boolean	 ga_entity_set_fitness (entity *e, double fitness);
# int      ga_population_get_fitness_dimensions (population *pop);
# boolean  ga_population_set_fitness_dimensions (population *pop, int num);
# int	 ga_population_get_stablesize (population *pop);
# int	 ga_population_get_size (population *pop);
# int	 ga_population_get_maxsize (population *pop);
# boolean	 ga_population_set_stablesize (population *pop, int stable_size);

# int	 ga_funclookup_ptr_to_id (void *func);
# int	 ga_funclookup_label_to_id (char *funcname);
# void	*ga_funclookup_label_to_ptr (char *funcname);
# void	*ga_funclookup_id_to_ptr (int id);
# char	*ga_funclookup_id_to_label (int id);
# void	 ga_init_openmp (void);

# /*
#  * Functions located in ga_io.c:
#  * (Disk I/O)
#  */
# boolean     ga_population_write (population *pop, char *fname);
# population *ga_population_read (char *fname);
# boolean     ga_entity_write (population *pop, entity *entity, char *fname);
# entity     *ga_entity_read (population *pop, char *fname);

# /*
#  * Functions located in ga_select.c:
#  * (Selection operators)
#  */
# boolean ga_select_one_random (population *pop, entity **mother);
# boolean ga_select_two_random (population *pop, entity **mother, entity **father);
# boolean ga_select_one_every  (population *pop, entity **mother);
# boolean ga_select_two_every  (population *pop, entity **mother, entity **father);
# boolean	ga_select_one_randomrank (population *pop, entity **mother);
# boolean ga_select_two_randomrank (population *pop, entity **mother, entity **father);
# boolean ga_select_one_bestof2  (population *pop, entity **mother);
# boolean ga_select_two_bestof2  (population *pop, entity **mother, entity **father);
# boolean ga_select_one_bestof3  (population *pop, entity **mother);
# boolean ga_select_two_bestof3  (population *pop, entity **mother, entity **father);
# boolean	ga_select_one_roulette (population *pop, entity **mother);
# boolean	ga_select_two_roulette (population *pop, entity **mother, entity **father);
# boolean	ga_select_one_roulette_rebased (population *pop, entity **mother);
# boolean	ga_select_two_roulette_rebased (population *pop, entity **mother, entity **father);
# boolean	ga_select_one_sus (population *pop, entity **mother);
# boolean	ga_select_two_sus (population *pop, entity **mother, entity **father);
# boolean	ga_select_one_sussq (population *pop, entity **mother);
# boolean	ga_select_two_sussq (population *pop, entity **mother, entity **father);
# boolean	ga_select_one_aggressive (population *pop, entity **mother);
# boolean	ga_select_two_aggressive (population *pop, entity **mother, entity **father);
# boolean	ga_select_one_best (population *pop, entity **mother);
# boolean	ga_select_two_best (population *pop, entity **mother, entity **father);
# boolean ga_select_one_linearrank (population *pop, entity **mother);
# boolean ga_select_two_linearrank (population *pop, entity **mother, entity **father);
# boolean ga_select_one_roundrobin (population *pop, entity **mother);

# //------------------------------------------------------------------------------
# /*
#  * Functions located in ga_crossover.c:
#  * (Crossover operators)
#  */

# #define CROSSOVER_VALS population *pop, entity *father, entity *mother, entity *son, entity *daughter 

# void  ga_crossover_integer_singlepoints    (CROSSOVER_VALS);
# void  ga_crossover_integer_doublepoints    (CROSSOVER_VALS);
# void  ga_crossover_integer_mean            (CROSSOVER_VALS);
# void  ga_crossover_integer_mixing          (CROSSOVER_VALS);
# void  ga_crossover_integer_allele_mixing   (CROSSOVER_VALS);

# void  ga_crossover_boolean_singlepoints    (CROSSOVER_VALS);
# void  ga_crossover_boolean_doublepoints    (CROSSOVER_VALS);
# void  ga_crossover_boolean_mixing          (CROSSOVER_VALS);
# void  ga_crossover_boolean_allele_mixing   (CROSSOVER_VALS);

# void  ga_crossover_char_singlepoints       (CROSSOVER_VALS);
# void  ga_crossover_char_doublepoints       (CROSSOVER_VALS);
# void  ga_crossover_char_mixing             (CROSSOVER_VALS);
# void  ga_crossover_char_allele_mixing      (CROSSOVER_VALS);

# void  ga_crossover_double_singlepoints     (CROSSOVER_VALS);
# void  ga_crossover_double_doublepoints     (CROSSOVER_VALS);
# void  ga_crossover_double_mixing           (CROSSOVER_VALS);
# void  ga_crossover_double_mean             (CROSSOVER_VALS);
# void  ga_crossover_double_allele_mixing    (CROSSOVER_VALS);

# void  ga_crossover_bitstring_singlepoints  (CROSSOVER_VALS);
# void  ga_crossover_bitstring_doublepoints  (CROSSOVER_VALS);
# void  ga_crossover_bitstring_mixing        (CROSSOVER_VALS);
# void  ga_crossover_bitstring_allele_mixing (CROSSOVER_VALS);

# /*
#  * Functions located in ga_mutate.c:
#  * (Mutation operators)
#  */
# void	ga_mutate_integer_singlepoint_drift     (population *pop, entity *father, entity *son);
# void	ga_mutate_integer_singlepoint_randomize (population *pop, entity *father, entity *son);
# void	ga_mutate_integer_multipoint            (population *pop, entity *father, entity *son);
# void	ga_mutate_integer_allpoint              (population *pop, entity *father, entity *son);

# void	ga_mutate_boolean_singlepoint           (population *pop, entity *father, entity *son);
# void	ga_mutate_boolean_multipoint            (population *pop, entity *father, entity *son);

# void	ga_mutate_char_singlepoint_drift        (population *pop, entity *father, entity *son);
# void	ga_mutate_char_singlepoint_randomize    (population *pop, entity *father, entity *son);
# void	ga_mutate_char_allpoint                 (population *pop, entity *father, entity *son);
# void	ga_mutate_char_multipoint               (population *pop, entity *father, entity *son);

# void	ga_mutate_printable_singlepoint_drift     (population *pop, entity *father, entity *son);
# void	ga_mutate_printable_singlepoint_randomize (population *pop, entity *father, entity *son);
# void	ga_mutate_printable_allpoint              (population *pop, entity *father, entity *son);
# void	ga_mutate_printable_multipoint            (population *pop, entity *father, entity *son);

# void	ga_mutate_bitstring_singlepoint (population *pop, entity *father, entity *son);
# void	ga_mutate_bitstring_multipoint  (population *pop, entity *father, entity *son);

# void	ga_mutate_double_singlepoint_drift     (population *pop, entity *father, entity *son);
# void	ga_mutate_double_singlepoint_randomize (population *pop, entity *father, entity *son);
# void	ga_mutate_double_multipoint            (population *pop, entity *father, entity *son);
# void	ga_mutate_double_allpoint              (population *pop, entity *father, entity *son);

# /*
#  * Functions located in ga_seed.c:
#  * (Genesis operators)
#  */
# boolean	ga_seed_boolean_random (population *pop, entity *adam);
# boolean ga_seed_boolean_zero   (population *pop, entity *adam);

# boolean	ga_seed_integer_random (population *pop, entity *adam);
# boolean	ga_seed_integer_zero   (population *pop, entity *adam);

# boolean	ga_seed_double_random (population *pop, entity *adam);
# boolean	ga_seed_double_zero   (population *pop, entity *adam);
# boolean	ga_seed_double_random_unit_gaussian (population *pop, entity *adam);

# boolean	ga_seed_char_random      (population *pop, entity *adam);
# boolean	ga_seed_printable_random (population *pop, entity *adam);

# boolean	ga_seed_bitstring_random (population *pop, entity *adam);
# boolean	ga_seed_bitstring_zero   (population *pop, entity *adam);

# /*
#  * Functions located in ga_replace.c:
#  * (Replacement operators)
#  */
# void	ga_replace_by_fitness (population *pop, entity *child);

# /*
#  * Functions located in ga_utility.c:
#  * (Miscellaneous support functions)
#  */
# void    ga_diagnostics (void); 
# int	ga_get_major_version (void);
# int	ga_get_minor_version (void);
# int	ga_get_patch_version (void);
# /* ga_genesis() is deprecated! Use ga_genesis_integer() instead. */

# //---------------------------------------------------------------------
# #define GENESIS_VAR     const int               population_size,\
#                         const int               num_chromo,\
#                         const int               len_chromo,\
#                         GAgeneration_hook       generation_hook,\
#                         GAiteration_hook        iteration_hook,\
#                         GAdata_destructor       data_destructor,\
#                         GAdata_ref_incrementor  data_ref_incrementor,\
#                         GAevaluate              evaluate,\
#                         GAseed                  seed,\
#                         GAadapt                 adapt,\
#                         GAselect_one            select_one,\
#                         GAselect_two            select_two,\
#                         GAmutate                mutate,\
#                         GAcrossover             crossover,\
#                         GAreplace               replace,\
# 			vpointer		userdata 

# typedef population* (*GENESIS_PROC) (GENESIS_VAR);

# //#define CH  chromosome[0]
# //---------------------------------------------------------------------

# population *ga_genesis (GENESIS_VAR);

# /* ga_genesis_int() is deprecated! Use ga_genesis_integer() instead. */

# population *ga_genesis_integer (GENESIS_VAR);
# population *ga_genesis_boolean (GENESIS_VAR);
# population *ga_genesis_char (GENESIS_VAR);
# population *ga_genesis_double (GENESIS_VAR);
# population *ga_genesis_bitstring (GENESIS_VAR);

# entity  *ga_allele_search (population *pop,
#                                 const int       chromosomeid,
#                                 const int       point,
#                                 const int       min_val, 
#                                 const int       max_val, 
#                                 entity          *initial);
# void ga_population_dump (population *pop);
# void ga_entity_dump (population *pop, entity *john);

# /*
#  * Functions located in ga_stats.c:
#  * (Statistics functions)
#  */
# boolean ga_fitness_mean (population *pop, double *average );
# boolean ga_fitness_mean_stddev (population *pop,
#                              double *average, double *stddev);
# boolean ga_fitness_stats (population *pop,
#                           double *maximum, double *minimum,
#                           double *mean, double *median,
#                           double *variance, double *stddev,
#                           double *kurtosis, double *skew);

# /*
#  * Functions located in ga_compare.c:
#  * (Entity comparison functions)
#  */
# double ga_compare_char_hamming        (population *pop, entity *alpha, entity *beta);
# double ga_compare_char_euclidean      (population *pop, entity *alpha, entity *beta);

# double ga_compare_integer_hamming     (population *pop, entity *alpha, entity *beta);
# double ga_compare_integer_euclidean   (population *pop, entity *alpha, entity *beta);

# double ga_compare_double_hamming      (population *pop, entity *alpha, entity *beta);
# double ga_compare_double_euclidean    (population *pop, entity *alpha, entity *beta);

# double ga_compare_boolean_hamming     (population *pop, entity *alpha, entity *beta);
# double ga_compare_boolean_euclidean   (population *pop, entity *alpha, entity *beta);

# double ga_compare_bitstring_hamming   (population *pop, entity *alpha, entity *beta);
# double ga_compare_bitstring_euclidean (population *pop, entity *alpha, entity *beta);

# /*
#  * Functions located in ga_rank.c:
#  * (Entity comparison functions)
#  */
# int ga_rank_fitness (population *alphapop, entity *alpha, population *betapop, entity *beta);

# /**********************************************************************
#  * Include remainder of this library's headers.
#  * These should, mostly, contain private definitions etc.
#  * But they currently contain almost everything.
#  **********************************************************************/

# //#include "ga_core.h"		/* Private aspects of GAUL. */
# //#include "gaul_core.h"	/* Private aspects of GAUL. */

# /**********************************************************************
#   ga_core.h
#  **********************************************************************

#   ga_core - Genetic algorithm routines.
#   Synopsis:     Routines for handling populations and performing GA
# 		operations.

#  **********************************************************************/

# //#ifndef GA_CORE_H_INCLUDED
# //#define GA_CORE_H_INCLUDED

# /*
#  * Includes.
#  */
# //#include "gaul.h"

# /*
#  * Debugging
#  */
# #ifndef GA_DEBUG
# # ifdef DEBUG
# #  define GA_DEBUG	DEBUG
# # else
# #  define GA_DEBUG	0
# # endif
# #endif

# /*
#  * Specification of number of processes used in
#  * multiprocess functions.
#  */
# #ifndef GA_NUM_PROCESSES_ENVVAR_STRING
# #define GA_NUM_PROCESSES_ENVVAR_STRING  "GAUL_NUM_PROCESSES"
# #endif
  
# #ifndef GA_DEFAULT_NUM_PROCESSES
# #define GA_DEFAULT_NUM_PROCESSES  8
# #endif

# /*
#  * Specification of number of threads used in
#  * multithreaded functions.
#  */
# #ifndef GA_NUM_THREADS_ENVVAR_STRING
# #define GA_NUM_THREADS_ENVVAR_STRING	"GAUL_NUM_THREADS"
# #endif
  
# #ifndef GA_DEFAULT_NUM_THREADS
# #define GA_DEFAULT_NUM_THREADS	 4
# #endif

# /*
#  * Whether simple statistics should be dumped to disk.
#  */
# #ifndef GA_WRITE_STATS
# # if GA_DEBUG > 1
# #  define GA_WRITE_STATS	TRUE
# # else
# #  define GA_WRITE_STATS	FALSE
# # endif
# #endif

# //******************************************************************************

# /*
#  * Compilation constants.
#  */

# #define GA_BOLTZMANN_FACTOR	(1.38066e-23)
set ::GA_BOLTZMANN_FACTOR	1.38066e-23
#set ::GA_BOLTZMANN_FACTOR	1.38066


# #define GA_TINY_DOUBLE		(1.0e-9)


#-------------------------------------------------------------------------------
# /*
#  * Entity Structure.
#  *
#  * FIXME: Make opaque i.e. move definition into ga_core.c
#  * Should encourage the use of accessor functions rather than directly tweaking
#  * the values in this structure manually.
#  */

# struct entity_t {}

#-------------------------------------------------------------------------------
proc make_list {num val} {

  set ret ""

  for {set i 0} {$i < $num} {incr i} {

    lappend ret $val
  }

  return $ret
}
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
#  ENTITY_T    ENTITY_T   ENTITY_T   ENTITY_T   ENTITY_T   ENTITY_T   ENTITY_T
#-------------------------------------------------------------------------------

record define ENTITY_T {

  fitness    ;# double    : Fitness score
  ch_form    ;# "% 6.3f" ;#  " %02d"

  chrom_some ;# vpointer* : The chromosomes (the genotype)

  # vpointer  data;  /* User data containing physical properties. (the phenotype) */
  # Additional stuff for multiobjective optimisation: 
  # option  -fitvector ;# double*   :  Fitness vector
}

#-------------------------------------------------------------------------------
#
#-------------------------------------------------------------------------------
proc ent_create_ {len_chromosome} {

  set e [ENTITY_T  #auto]

  $e configure -chrom_some [make_list $len_chromosome "@"]
    
  $e configure -ch_form  "% 6.3f" ;#  " %02d"
  
  return $e
}
#-------------------------------------------------------------------------------
proc ent_get_chromo_gen_ {e i} {

  # set e $self ;# !!!!!!!!!!!
  
  set  tmp [$e cget -chrom_some] ;# это список
  
  return [lindex $tmp $i]
}
#-------------------------------------------------------------------------------
proc ent_CH_ {e} {

  #set e $self ;# !!!!!!!!!!!
  
  return [$e cget -chrom_some]
}
#-------------------------------------------------------------------------------
proc ent_get_chromosome_ {e} {


  return [$e cget -chrom_some]
}
#-------------------------------------------------------------------------------
proc ent_print_ch_ {e {name "ch= "}} {

  
  set ch_form [$e cget -ch_form] ;# локальная переменная
  set ch      [ent_get_chromosome_ $e]
  
  puts -nonewline $name
  
  foreach c $ch {
    if {[catch {puts -nonewline [format $ch_form $c]} err]} {
      puts -nonewline "$c! "
    }
  } 
  
  flush stdout  ;# все данные должны быть выведены
}
#-------------------------------------------------------------------------------
proc ent_print_oneline_ {e} {

  #set e $self ;# !!!!!!!!!!!
  
  puts -nonewline "  "
  ent_print_ch_ $e
  
  set fi [$e cget -fitness]
  
  if {$fi == $::GA_MIN_FITNESS} {
    puts -nonewline "   fitness= GA_MIN_FITNESS"
  } else {
    puts -nonewline "   fitness= [format "%f"  $fi]"
  }
  
  puts ""
}
#-------------------------------------------------------------------------------
proc ent_set_chromosome_ {e ch} {

  #set e $self ;# !!!!!!!!!!!
  
  $e configure -chrom_some $ch
}
#-------------------------------------------------------------------------------
proc l_set_option_ {e optname i val} {

  #set optname chrom_some

  set  tmp [$e cget -$optname] ;# это список

  #if {$::is_print} {
  #  puts "i = $i  val = $val llength = [llength $tmp]"
  #  puts "tmp = $tmp " ;# списка нет?
  #}
  

  if {[llength $tmp] == 0} {
    lset tmp $val
  } else {
    lset tmp $i $val
    #lset options(-chromosome) $i $val ;#list index out of range ?? 
  }
  $e configure -$optname $tmp
  
}
#-------------------------------------------------------------------------------
proc ent_set_chromo_gen_ {e i val} {

  
  l_set_option_ $e "chrom_some" $i $val

  return
}
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------


# //-------------------------------------------------------
# #define CH  chromosome[0]
# //-------------------------------------------------------

# /*
#  * Tabu-search parameter structure.
#  */
# typedef struct
#   {
#   int		   list_length;	  /* Length of the tabu-list. */
#   int	 	   search_count;  /* Number of local searches initiated at each iteration. */
#   GAtabu_accept  tabu_accept;	  /* Acceptance function. */
#   } ga_tabu_t;

record define GA_TABU_T {

  list_length  ;# int	 /* Length of the tabu-list. */
  search_count ;# int	 /* Number of local searches initiated at each iteration. */
  tabu_accept  ;# GAtabu_accept /* Acceptance function. */
}

# /*
#  * Simulated Annealling search parameter structure.
#  */
# typedef struct {
#   double	initial_temp;	/* Initial temperature. */
#   double	final_temp;	/* Final temperature. */
#   double	temp_step;	/* Increment of temperature updates. */
#   int		temp_freq;	/* Frequency for temperature updates.
#                                   * (Or, -1 for smooth transition between Ti and Tf) */
#   double	temperature;	/* Current temperature. */
#   GAsa_accept	sa_accept;	/* Acceptance criterion function. */
# } ga_sa_t;

record define GA_SA_T {

  initial_temp ;#   double	initial_temp;	/* Initial temperature. */
  final_temp   ;#   double	final_temp;	/* Final temperature. */
  temp_step    ;#   double	temp_step;	/* Increment of temperature updates. */
  temp_freq    ;#   int	temp_freq;	/* Frequency for temperature updates.
  #                                   * (Or, -1 for smooth transition between Ti and Tf) */
  temperature  ;#   double	 temperature;	/* Current temperature. */
  sa_accept    ;#   GAsa_accept sa_accept;	/* Acceptance criterion function. */
}

# /*
#  * Hill climbing parameter structure.
#  */
# typedef struct
#   {
#     GAmutate_allele	mutate_allele;	/* Allele mutation function. */
#   } ga_climbing_t;

# /*
#  * Simplex parameter structure.
#  */
# typedef struct
#   {
#   int		dimensions;	/* Size of double array. */
#   double	alpha;		/*  (range: 0=no extrap, 1=unit step extrap, higher OK.) */
#   double	beta;		/*  (range: 0=no contraction, 1=full contraction.) */
#   double	gamma;		/*  (range: 0=no contraction, 1=full contraction.) */
#   double	step;		/* Initial randomisation step (range: >0, 1=unit step randomisation, higher OK.) */
#   GAto_double	to_double;	/* Convert chromosome to double array. */
#   GAfrom_double	from_double;	/* Convert chromosome from double array. */
#   } ga_simplex_t;

# /*
#  * Deterministic crowding parameter structure.
#  */
# typedef struct
#   {
#     GAcompare	compare;	/* Compare two entities (either genomic or phenomic space). */
#   } ga_dc_t;

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# /*
#  * Differential evolution parameter structure.
#  */

# typedef struct
# {
#   ga_de_strategy_type	strategy;		/* Selection strategy. */
#   ga_de_crossover_type	crossover_method;	/* Crossover strategy. */
#   int			num_perturbed;		/* Number to perturb. */
#   double		crossover_factor;	/* Crossover ratio. */
#   double		weighting_min;		/* Minimum crossover weighting factor. */
#   double		weighting_max;		/* Maximum crossover weighting factor. */

# } ga_de_t;

# не буду делать структуру отдельно - перенесу переменные внутрь pop
# 
# 
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# /*
#  * Gradient methods parameter structure.
#  */
# typedef struct
# {
#   int		dimensions;	/* Size of double array. */
#   double	step_size;	/* Step size, (or initial step size). */
#   double	alpha;		/* Step size scale-down factor. */
#   double	beta;		/* Step size scale-up factor. */
#   GAto_double	to_double;	/* Convert chromosome to double array. */
#   GAfrom_double	from_double;	/* Convert chromosome from double array. */
#   GAgradient	gradient;	/* Return gradients array. */
# } ga_gradient_t;

# /*
#  * Systematic search parameter structure.
#  */
# typedef struct
# {
#   GAscan_chromosome	scan_chromosome;	/* Allele searching function. */
#   int			chromosome_state;	/* Permutation counter. */
#   int			allele_state;		/* Permutation counter. */
# } ga_search_t;

# /*
#  * Probabilistic sampling parameter structure.
#  */
# typedef struct
# {
#   int			**num_states;		/* Number of states for each allele. */
# } ga_sampling_t;

# /* 
#  * Internal state values for built-in selection operators.
#  * Currently used for roulette wheel and SUS selection routines.
#  */
# typedef struct
# {
#   double	mean, stddev, sum;	/* Fitness statistics. */
#   double	current_expval;		/* Total of expectancy values. */
#   double	minval;			/* Worst fitness value. */
#   double	step;			/* Distance between each pointer. */
#   double	offset1, offset2;	/* Current pointer offsets. */
#   int		marker;			/* The roulette wheel marker. */
#   int		num_to_select;		/* Number of individuals to select. */
#   int		current1, current2;	/* Currently selected individuals. */
#   int		*permutation;		/* Randomly ordered indices. */
# } ga_selectdata_t;


# /*
#  * Population Structure.
#  *
#  * FIXME: Make opaque. (I have already written the accessor functions.)
#  * IMPORTANT NOTE: If you really must iterate over all entities in
#  * a population in external code, loop over entity_iarray... NOT entity_array.
#  */


#-------------------------------------------------------------------------------
proc sort_command {a b} {

  set a_fit [$a cget -fitness]
  set b_fit [$b cget -fitness]

  if {$a_fit >  $b_fit}  {return -1} ;# т.е бОльшие будут слева в списке (вверху)
  if {$a_fit == $b_fit}  {return  0} 
  if {$a_fit <  $b_fit}  {return  1} 

  return 1
}
#-------------------------------------------------------------------------------
#  POPULATION_T    POPULATION_T    POPULATION_T    POPULATION_T    POPULATION_T   

#-------------------------------------------------------------------------------
record define POPULATION_T {

  ch_form        ;#-#  " %02d"

  max_size	 ;#-# int   : Current maximum population size
  stable_size	 ;#-# int   : Requested population size
  size         	 ;#-# int   : Actual population size
  orig_size	 ;#-# int   : Number of parents (entities at end of previous generation)

  island         ;#-# int	island;	/* Population's island. */

  free_index     ;#-# int   : Next potentially free entity index. 
  generation     ;#-# int   : For ga_population_get_generation()

  fitness_dimensions ;# int : Size of fitness vector (for multiobjective optimisation
  best           ;#-# для хранения лучшего номера

  # MemChunk	*entity_chunk;		/* Buffer for entity structures. */
  #
  # здесь основной массив хранения?
  # 
  #option  -entity_array  ""       ;# entity	** : The population in id order
  #option  -entity_iarray "" ;# entity	** : The population sorted by fitness

  #variable  entity_iarray ""
  entitysiarray  ;#-# "" 

  # //int		num_chromosomes;	/* Number of chromosomes in genotype.  
  #                                          FIXME: should be an array of lengths. */
  
  len_chromosomes ;#-#   int : Maximum length of each chromosome. 
  
  #   vpointer	data;			/* User data. */
  
  select_state   ;#-#   int select_state;	/* Available to selection algorithms. */

  #   ga_selectdata_t	selectdata;	/* State values for built-in selection operators. */
  #
  # typedef struct
  # {} ;#!!!!!!!!!!!!!!!!!!!!!!!!!!!

  #   double	mean, stddev, sum;	/* double : Fitness statistics.            */
  #   double	current_expval;		/* double : Total of expectancy values.    */
  #   double	minval;			/* double : Worst fitness value.           */

  #selectdata_num_to_select
  selectdata_step      ;#-#	/* double : Distance between each pointer. */

  selectdata_offset1   ;#-#  /* double : Current pointer offsets.       */
  selectdata_offset2   ;#-#

  #   int		marker;		/* int  : The roulette wheel marker.       */
  selectdata_num_to_select ;#-#	/* int  : Number of individuals to select. */
  selectdata_current1 ;#-#  /* int  : Currently selected individuals.  */
  selectdata_current2 
  selectdata_permutation   ;#-#	/* int* : Randomly ordered indices.        */
  # {} ga_selectdata_t; ;#!!!!!!!!!!!!!!!!!!!!!!!!!!!
  
  # /*
  #  * Special parameters for particular built-in GA operators.
  #  * FIXME: I don't like how this is currently implemented; need a more
  #  * elegant approach.
  #  */
  #   int	allele_min_integer, allele_max_integer;	/* Range for "integer" alleles. */
  allele_min_integer ;#-#
  allele_max_integer ;#-#

  #   double	allele_min_double, allele_max_double;	/* Range for "double" alleles. */
  allele_min_double  ;#-#
  allele_max_double  ;#-#
  
  # /*
  #  * Evolutionary parameters.
  #  */
  crossover_ratio    ;#-# double	       crossover_ratio;	/* Chance for crossover. */
  mutation_ratio     ;#-# double	       mutation_ratio;	/* Chance for mutation.  */
  migration_ratio    ;#-# double	       migration_ratio;	/* Chance for migration. */
  scheme             ;#-# ga_scheme_type   scheme;		/* Evolutionary scheme.  */
  elitism            ;#-# ga_elitism_type  elitism;		/* Elitism mode.         */
  
  # /*
  #  * Special (aka miscellaneous) parameters.
  #  */
  #   double		allele_mutation_prob;	/* Chance for individual alleles to mutate in certain mutation operators. */
  
  # /*
  #  * Non-evolutionary parameters.
  #  */
  tabu_params  ;#-#   ga_tabu_t *tabu_params;	/* Parameters for tabu-search. */
  sa_params    ;#-#   ga_sa_t	*sa_params;	/* Parameters for simulated annealling. */

  #   ga_climbing_t		*climbing_params;	/* Parameters for hill climbing. */
  #   ga_simplex_t		*simplex_params;	/* Parameters for simplex search. */

  #   ga_dc_t		*dc_params;	/* Parameters for deterministic crowding. */
  {dc_params_compare NULL} ;#-#	/* Compare two entities (either genomic or phenomic space). */
  
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #
  #   ga_de_t		*de_params;		/* Parameters for differential evolution. */
  #
  de_strategy         ;#-#	/* Selection strategy.                 */
  de_crossover_method ;#-#	/* Crossover strategy.                 */
  de_num_perturbed    ;#-#	/* Number to perturb.                  */
  de_crossover_factor ;#-#	/* Crossover ratio.                    */
  de_weighting_min    ;#-#	/* Minimum crossover weighting factor. */
  de_weighting_max    ;#-#	/* Maximum crossover weighting factor. */

  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  #   ga_gradient_t	*gradient_params;	/* Parameters for gradient methods.  */

  gr_dimensions       ;#-#   int            /* Size of double array.                 */
  gr_step_size        ;#-#   double         /* Step size, (or initial step size).    */
  gr_alpha            ;#-#   double         /* Step size scale-down factor.          */
  gr_beta             ;#-#   double         /* Step size scale-up factor.            */
  gr_to_double        ;#-#   GAto_double    /* Convert chromosome to double array.   */
  gr_from_double      ;#-#   GAfrom_double  /* Convert chromosome from double array. */
  gr_gradient         ;#-#   GAgradient	    /* Return gradients array.               */

  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  #   ga_search_t		*search_params;		/* Parameters for systematic search. */
  #   ga_sampling_t	*sampling_params;	/* Parameters for probabilistic sampling. */
  
  # /*
  #  * The scoring function and the other callbacks are defined here.
  #  */
  {generation_hook NULL} ;#-#  GAgeneration_hook generation_hook;
  {iteration_hook  NULL} ;#-#   GAiteration_hook	iteration_hook;
  
  #   GAdata_destructor		data_destructor;        /* entity.data destructor */
  #   GAdata_ref_incrementor	data_ref_incrementor;   /* entity.data reference counter incrementor */
  
  #   GAdata_destructor		population_data_destructor;
  #   GAdata_copy			population_data_copy;
  chromosome_constructor ;#-# GAchromosome_constructor :
  
  #   GAchromosome_destructor	chromosome_destructor;
  #   GAchromosome_replicate	chromosome_replicate;
  #   GAchromosome_to_bytes		chromosome_to_bytes;
  #   GAchromosome_from_bytes	chromosome_from_bytes;
  #   GAchromosome_to_string	chromosome_to_string;

  evaluate   ;#-# GAevaluate	
  seed       ;#-# GAseed

  {adapt      NULL} ;# GAadapt		adapt;
  select_one ;#-# GAselect_one	select_one;
  select_two ;#-# GAselect_two	select_two;

  mutate     ;#-# GAmutate			mutate;
  crossover  ;#-# GAcrossover crossover;
  replace    ;#-# GAreplace			replace;
  rank       ;#-# GArank	rank;

  # /*
  #  * Memory handling.
  #  */
  # #ifdef USE_CHROMO_CHUNKS
  #   MemChunk			*chromoarray_chunk;
  #   MemChunk			*chromo_chunk;
  # #endif
  
  # /*
  #  * Execution locks.
  #  */  
}
#-------------------------------------------------------------------------------

#
#-------------------------------------------------------------------------------
proc pop_create_ {} {
    
  set p [POPULATION_T #auto]

  return $p
}
#-------------------------------------------------------------------------------
proc pop_set_entity_fitness_ {p i fi} {
    
  set ent  [pop_get_entity_ $p  $i]

  $ent configure -fitness $fi
}
#-------------------------------------------------------------------------------
proc pop_get_entity_fitness_ {p i} {
    
  #set p $self ;# !!!!!!!!!!!
  
  #set ent  [$p get_entity $i]
  set ent  [pop_get_entity_ $p  $i]
  
  return [$ent cget -fitness]
}
#-------------------------------------------------------------------------------
proc pop_add_entity_ {p entity} {

  set tmp [$p cget -entitysiarray]

  lappend tmp $entity

  $p configure -entitysiarray $tmp
  
  #incr    options(-size)
  pop_incr_size_ $p  1
  
  return 
}
#-------------------------------------------------------------------------------
proc pop_set_entity_ {p i entity} {

  #lset $options(-entity_iarray) $i $entity
  #can't read "::ENTITY_T1 ::ENTITY_T3 ::ENTITY_T5 ::ENTITY_T7 ::ENTITY_T9 ::ENTITY_T11": 
  #no such variable
  # .. опять какая-то фигня, не получается обратиться к опции как к имени списка
  
  l_set_option_ $p "entitysiarray" $i $entity

}
#-------------------------------------------------------------------------------
proc pop_get_entity_ {p i} {

  set tmp [$p.entitysiarray]
  
  set r [lindex $tmp $i]
  
  return $r
}
#-------------------------------------------------------------------------------
proc pop_incr_size_ {p val} {

  #set  old_size [$p cget -size]
  set  old_size [$p.size]

  incr old_size $val

  #$p configure -size $old_size
  $p.size = $old_size
  
}
#-------------------------------------------------------------------------------
proc pop_del_entity_ {p i} {


  set tmp [$p cget -entitysiarray]
  
  set new_iarray [lreplace $tmp $i $i] ;# удалили элемент списка
  
  $p configure -entitysiarray $new_iarray
  
  #   pop->size--;

  pop_incr_size_ $p -1
  #incr  options(-size) -1
  
  return
}
#-------------------------------------------------------------------------------
proc pop_print_lite_ {p} {

  set i 0
  
  set tmp [$p cget -entitysiarray]
  
  foreach e $tmp {
    
    puts -nonewline "   i= [format "%2s" $i]"
    
    #puts -nonewline "   e= |$e|"
    
    ent_print_oneline_ $e
    incr i
  }

}
#-------------------------------------------------------------------------------
proc pop_print_ {p} {

  #puts "options = [array get options]"
  
  puts "~~~~~~~~~~~~~~~~~~~~~~ POPULATION PRINT ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
  puts ""
  puts "Generation = [$p cget -generation]"
  puts ""
  
  pop_print_lite_ $p 
  
  set best     [$p cget -best]
  
  puts ""
  puts "STABLE_SIZE = [$p cget -stable_size]"
  puts "ORIG_SIZE   = [$p cget -orig_size]"
  puts "SIZE        = [$p cget -size]"
  puts "BEST        = $best"
  puts ""
  
  if {$best != -1} {
    #set best_fit [$p get_entity_fitness $best]
    set best_fit [pop_get_entity_fitness_ $p  $best]
    
    puts [format "BEST = $best  (fitness = %f)" $best_fit]
  }
  
  puts ""
  puts "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"

}
#-------------------------------------------------------------------------------
proc pop_eliminate_ {p} {
    
  # DE
  
  set osize [$p cget -orig_size]
  
  set tmp [$p cget -entitysiarray]
  $p configure -entitysiarray [lrange $tmp $osize end]
  
  $p configure -size  [expr [$p cget -size] - $osize]
  $p configure -orig_size 0

}
#-------------------------------------------------------------------------------
proc pop_sort_ {p} {

  if {[$p cget -size] == 0} {
    return ;# если в популяции ничего еще нет !!
  }
  
  # в случае, если специально определена функция сравнения (а не просто по фитнесу)
  # т.е. if (pop->rank != ga_rank_fitness) то надл использовать эту функцию!
  #
  #set rank_proc [$self cget -rank]
  #if {$rank_proc != "ga_rank_fitness"} {
  #  die "NOT ..... ga_rank_fitness"
  #}
  
  $p configure -entitysiarray [lsort -command "sort_command" [$p cget -entitysiarray]]

  $p configure -best 0 ;# после сортировки это должно быть так
  }
#-------------------------------------------------------------------------------
proc pop_print {pop} {


  pop_print_ $pop 

}
#-------------------------------------------------------------------------------

# /*
#  * Constant definitions.
#  */

# // к сожалению DBL_MAX и DBL_MIN используется в алгоритмах мутации, случ. чисел
# // и т.д. поэтому просто так поменять не получистя !
# // 

# /* Define lower bound on fitness. */
# #define GA_MIN_FITNESS			-DBL_MAX

# DBL_MAX is defined in <float.h>. Its availability in <limits.h> on unix 
# DBL_MAX = 1.79769e+308
#

# set ::DBL_MAX  999999999999999999
# set ::DBL_MIN -999999999999999999


set ::DBL_MIN 0.000000 
set ::DBL_MAX 179769313486231570814527423731704356798070567525844996598917476803157260780028538760589558632766878171540458953514382464234321326889464182768467546703537516986049910576551282076245490090389328944075868508455133942304583236903222948165808559332123348274797826204144723168738177180919299881250404026184124858368.000000 

#set ::GA_MIN_FITNESS 999999999999999999
set ::GA_MIN_FITNESS [expr - $::DBL_MAX]

# /*
#  * Define some default values.
#  */
# #define GA_DEFAULT_CROSSOVER_RATIO	0.9
# #define GA_DEFAULT_MUTATION_RATIO	0.1
# #define GA_DEFAULT_MIGRATION_RATIO	0.1

# /*
#  * Define chance of any given allele being mutated in one mutation
#  * operation (only for certain mutation functions).
#  */
# #define GA_DEFAULT_ALLELE_MUTATION_PROB	0.02

# /*
#  * A private prototype.
#  */
# boolean gaul_population_fill (population *pop, int num);

# /**********************************************************************
#   ga_similarity.h
#  **********************************************************************/

# /*
#  * Deprecated Prototypes
#  */
# boolean	ga_compare_genome (population *pop, entity *alpha, entity *beta);
# double	ga_genome_euclidean_similarity (population *pop, entity *alpha, entity *beta);
# int	ga_count_match_alleles (const int length, const int *alpha, const int *beta);
# double	ga_genome_hamming_similarity (population *pop, entity *alpha, entity *beta);

# /*
#  * Prototypes.
#  */
# double	ga_similarity_bitstring_tanimoto (const population *pop,
#                                   const entity *alpha, const entity *beta);
# double	ga_similarity_bitstring_dice (const population *pop,
#                                   const entity *alpha, const entity *beta);
# double	ga_similarity_bitstring_hamming (const population *pop,
#                                   const entity *alpha, const entity *beta);
# double	ga_similarity_bitstring_euclidean (const population *pop,
#                                   const entity *alpha, const entity *beta);
# double	ga_similarity_bitstring_cosine (const population *pop,
#                                   const entity *alpha, const entity *beta);

# int ga_similarity_bitstring_count_1_alleles ( const population *pop,
#                                       const entity *alpha, const int chromosomeid );
# int ga_similarity_bitstring_count_match_alleles ( const population *pop,
#                                       const entity *alpha, const entity *beta,
#                                       const int chromosomeid );
# int ga_similarity_bitstring_count_and_alleles ( const population *pop,
#                                       const entity *alpha, const entity *beta,
#                                       const int chromosomeid );
# int ga_similarity_integer_count_match_alleles ( const population *pop,
#                                       const entity *alpha, const entity *beta,
#                                       const int chromosomeid );

# double	ga_similarity_double_tanimoto (const population *pop,
#                                   const entity *alpha, const entity *beta);
# double	ga_similarity_double_dice (const population *pop,
#                                       const entity *alpha, const entity *beta);
# double	ga_similarity_double_cosine (const population *pop,
#                                       const entity *alpha, const entity *beta);
# int ga_similarity_double_count_match_alleles ( const population *pop,
#                                       const entity *alpha, const entity *beta,
#                                       const int chromosomeid );

# //******************************************************************************
#   //#endif	/* GA_CORE_H_INCLUDED */
# //******************************************************************************



# /**********************************************************************
#   ga_climbing.h
#  **********************************************************************/

# void ga_population_set_hillclimbing_parameters (population *pop, GAmutate_allele mutate_allele);
# int  ga_next_ascent_hillclimbing (population *pop, entity *initial, const int max_iterations);
# int  ga_random_ascent_hillclimbing (population *pop, entity *initial, const int max_iterations);

# /**********************************************************************
#   ga_de.h
#  **********************************************************************/

# void ga_population_set_differentialevolution_parameters (population *pop,
#                                                          const ga_de_strategy_type strategy,
#                                                          const ga_de_crossover_type crossover,
#                                                          const int num_perturbed,
#                                                          const double weighting_min,
#                                                          const double weighting_max,
#                                                          const double crossover_factor);
# int ga_differentialevolution (population  *pop,
#                               const int max_generations);

# /**********************************************************************
#   ga_deterministiccrowding.h
#  **********************************************************************/

# void ga_population_set_deterministiccrowding_parameters (population *pop,
#                                                          GAcompare compare);
# int ga_deterministiccrowding (population *pop, int max_generations );


# /**********************************************************************
#   ga_gradient.h
#  **********************************************************************/

# void ga_population_set_gradient_parameters (population		*pop,
#                                         const GAto_double	to_double,
#                                         const GAfrom_double	from_double,
#                                         const GAgradient	gradient,
# 					const int		dimensions,
# 					const double		step_size);

# int ga_steepestascent (population *pop, entity *initial, int max_iterations);
# int ga_steepestascent_double (population *pop, entity *initial, int max_iterations);

# /**********************************************************************
#   ga_optim.h
#  **********************************************************************/

# /*
#  * Callback function prototype.
#  */
# typedef void  (*GAspecificmutate) (int chromo, int point, int *data);

# /*
#  * Prototypes
#  */
# void   ga_attach_mpi_slave ( population *pop );
# void   ga_detach_mpi_slaves (void);

# int    ga_evolution (population	 *pop, int max_generations);
# /* int    ga_evolution_mp (population *pop, int max_generations); */
# /* int    ga_evolution_mpi (population *pop, int max_generations); */

# /* int    ga_evolution_forked (population *pop, int max_generations); */
# int 
# ga_evolution_forked (population	 *pop,
# 		     int	  max_generations);


# /* int    ga_evolution_threaded (population *pop, int max_generations); */
# int    ga_evolution_steady_state (population *pop, int max_iterations);
# int    ga_evolution_archipelago (int num_pops, population **pops, int max_generations);
# /* int    ga_evolution_archipelago_forked (int num_pops, population **pops, int max_generations); */
# /* int    ga_evolution_archipelago_threaded (int num_pops, */
# /*                                           population **pops, int max_generations); */
# /* int    ga_evolution_archipelago_mp (int num_pops, */
# /*                                     population **pops, int max_generations); */
# /* int    ga_evolution_archipelago_mpi (int num_pops, */
# /*                                      population **pops, int  max_generations); */

# /**********************************************************************
#   ga_qsort.h
#  **********************************************************************/

# #include <math.h>
# #include <stdio.h>
# #include <string.h>
# #include <stdlib.h>

# /* Activate the timing code with this constant */
# /*#define GA_QSORT_TIME*/

# #ifndef GA_QSORT_DEBUG
# #define GA_QSORT_DEBUG	1
# #endif

# /*
#  * Nice and useful macro for swapping pointers to entities.
#  */
# #define swap_e(x, y)	{entity *t; t = x; x = y; y = t; }

# /*
#  * Private prototypes.
#  */
# void	sort_population (population *pop);
# boolean	ga_qsort_test (void);

# /**********************************************************************
#   ga_randomsearch.h
#  **********************************************************************/

# /* #ifndef GA_RANDOMSEARCH_H_INCLUDED */
# /* #define GA_RANDOMSEARCH_H_INCLUDED */

# int ga_random_search (population *pop, entity *initial, const int max_iterations);

# /**********************************************************************
#   ga_sa.h
#  **********************************************************************/

# boolean ga_sa_boltzmann_acceptance (population *pop, entity *original, entity *putative);
# boolean ga_sa_linear_acceptance (population *pop, entity *original, entity *putative);
# void    ga_population_set_sa_temperature (population *pop, const double temp);
# double  ga_population_get_sa_temperature (population *pop);
# void    ga_population_set_sa_parameters (population *pop, GAsa_accept sa_accept, 
#                                          const double initial_temp, const double final_temp, 
#                                          const double temp_step, const int temp_freq);
# int ga_sa (population *pop, entity *initial, const int max_iterations);

# /**********************************************************************
#   ga_systematicsearch.h
#  **********************************************************************/

# void ga_population_set_search_parameters (population  *pop,
#                                         GAscan_chromosome scan_chromosome);
# int ga_search (population *pop, entity *initial);

# /**********************************************************************
#   ga_simplex.h
#  **********************************************************************/

# void ga_population_set_simplex_parameters (population		*pop,
# 					const int		dimensions,
# 					const double		step,
#                                         const GAto_double	to_double,
#                                         const GAfrom_double	from_double);
# int ga_simplex (population *pop,
# 		entity     *initial,
# 	        const int   max_iterations);
# int ga_simplex_double (population  *pop,
# 		entity             *initial,
# 	        const int          max_iterations);

# /**********************************************************************
#   ga_tabu.h
#  **********************************************************************/

# boolean ga_tabu_check_integer   (population *pop, entity *putative, entity *tabu);
# boolean ga_tabu_check_boolean   (population *pop, entity *putative, entity *tabu);
# boolean ga_tabu_check_char      (population *pop, entity *putative, entity *tabu);
# boolean ga_tabu_check_double    (population *pop, entity *putative, entity *tabu);
# boolean ga_tabu_check_bitstring (population *pop, entity *putative, entity *tabu);
# void ga_population_set_tabu_parameters (population    *pop,
#                                         GAtabu_accept  tabu_accept,
#                                         const int      list_length,
#                                         const int      search_count);
# int ga_tabu (population *pop,
#              entity     *initial,
#              const int  max_iterations );

# /**********************************************************************
#   ga_chromo.h
#  **********************************************************************/

# boolean ga_chromosome_integer_allocate (population *pop, entity *embryo);
# void    ga_chromosome_integer_deallocate (population *pop, entity *corpse);
# void    ga_chromosome_integer_replicate ( const population *pop,
#                                          entity *parent, entity *child,
#                                          const int chromosomeid);
# unsigned int ga_chromosome_integer_to_bytes (const population *pop, entity *joe,
#                                              gaulbyte **bytes, unsigned int *max_bytes);
# void    ga_chromosome_integer_from_bytes (const population *pop, entity *joe, gaulbyte *bytes);
# char   *ga_chromosome_integer_to_string (const population *pop, const entity *joe, 
#                                          char *text, size_t *textlen);

# //-------------------------------------------------------

# boolean ga_chromosome_boolean_allocate (population *pop, entity *embryo);
# void    ga_chromosome_boolean_deallocate (population *pop, entity *corpse);
# void    ga_chromosome_boolean_replicate ( const population *pop,
#                                       entity *parent, entity *child,
#                                       const int chromosomeid );
# unsigned int ga_chromosome_boolean_to_bytes (const population *pop, entity *joe,
#                                     gaulbyte **bytes, unsigned int *max_bytes);
# void    ga_chromosome_boolean_from_bytes (const population *pop, entity *joe, gaulbyte *bytes);
# char   *ga_chromosome_boolean_to_string  (const population *pop, const entity *joe, 
#                                          char *text, size_t *textlen);
# //-------------------------------------------------------

# boolean ga_chromosome_double_allocate   (population *pop, entity *embryo);
# void    ga_chromosome_double_deallocate (population *pop, entity *corpse);
# void    ga_chromosome_double_replicate  (const population *pop,
#                                       entity *parent, entity *child,
#                                       const int chromosomeid );
# unsigned int ga_chromosome_double_to_bytes (const population *pop, entity *joe,
#                                             gaulbyte **bytes, unsigned int *max_bytes);
# void    ga_chromosome_double_from_bytes (const population *pop, entity *joe, gaulbyte *bytes);
# char   *ga_chromosome_double_to_string  (const population *pop, const entity *joe, char *text, 
#                                          size_t *textlen);
# //-------------------------------------------------------

# boolean ga_chromosome_char_allocate  (population *pop, entity *embryo);
# void    ga_chromosome_char_deallocate (population *pop, entity *corpse);
# void    ga_chromosome_char_replicate  (const population *pop,
#                                       entity *parent, entity *child,
#                                       const int chromosomeid );
# unsigned int ga_chromosome_char_to_bytes (const population *pop, entity *joe,
#                                     gaulbyte **bytes, unsigned int *max_bytes);
# void    ga_chromosome_char_from_bytes (const population *pop, entity *joe, gaulbyte *bytes);
# char   *ga_chromosome_char_to_string  (const population *pop, const entity *joe, char *text, size_t *textlen);

# //-------------------------------------------------------

# boolean ga_chromosome_bitstring_allocate   (population *pop, entity *embryo);
# void    ga_chromosome_bitstring_deallocate (population *pop, entity *corpse);
# void    ga_chromosome_bitstring_replicate  (const population *pop, entity *parent, entity *child, 
#                                             const int chromosomeid );
# unsigned int ga_chromosome_bitstring_to_bytes(const population *pop, entity *joe, gaulbyte **bytes, 
#                                               unsigned int *max_bytes);
# void    ga_chromosome_bitstring_from_bytes (const population *pop, entity *joe, gaulbyte *bytes);
# char   *ga_chromosome_bitstring_to_string  (const population *pop, const entity *joe, char *text, 
#                                             size_t *textlen);
# //-------------------------------------------------------

# boolean ga_chromosome_list_allocate   (population *pop, entity *embryo);
# void    ga_chromosome_list_deallocate (population *pop, entity *corpse);
# void    ga_chromosome_list_replicate  (const population *pop, entity *parent, entity *child, 
#                                        const int chromosomeid );
# unsigned int ga_chromosome_list_to_bytes (const population *pop, entity *joe, gaulbyte **bytes,
#                                           unsigned int *max_bytes);
# void    ga_chromosome_list_from_bytes (const population *pop, entity *joe, gaulbyte *bytes );
# char   *ga_chromosome_list_to_string  (const population *pop, const entity *joe, char *text, size_t *textlen);

# //******************************************************************************


# typedef int (*BIT_PROC) (entity *entity, int i); 


# //******************************************************************************
# #endif	/* GAUL_H_INCLUDED */
# //******************************************************************************

