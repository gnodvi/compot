
# /**********************************************************************
#   ga_core.c
#  **********************************************************************

#   ga_core - Genetic algorithm routines.
#   Copyright б╘2000-2006, Stewart Adcock <stewart@linux-domain.com>
#   All rights reserved.

#   Synopsis:     Routines for handling populations and performing GA
# 		operations.
  
# 		Also contains a number of helper functions providing
# 		alternative optimisation schemes for comparison and
# 		analysis purposes.

# 		BEWARE: MANY FUNCTIONS ARE NOT THREAD-SAFE!

# 		Internally, and in the public C interface, pointers
# 		are used to identify the population and entity
# 		structures.  However, in the scripting interface these
# 		pointers are unusable, so identifing integers are
# 		used instead.

#   Vague usage details:	Set-up with ga_genesis_XXX(), where XXX is a built-in chromosome type().
# 			Perform calculations with ga_evolution().
# 			Grab data for post-analysis with ga_transcend().
# 			Evolution will continue if ga_evolution() is
# 			called again without calling ga_genesis_XXX() again.

#   To do:	Replace the send_mask int array with a bit vector.
# 		All functions here should be based on entity/population _pointers_ while 
#                 the functions in ga_intrinsics should be based on _handles_.
# 		More "if ( !pop ) die("Null pointer to population structure passed.");" 
#                 checks are needed.
# 		Population/entity iterator functions.
# 		ga_get_struct_whatever() should be renamed to ga_struct_get_whatever().

#  **********************************************************************/

# //#include "ga_core.h"
# #include "gaul.h"
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------


set ::is_print 0


# //------------------------------------------------------------------------------
proc print_entit  {entity name} {

  puts -nonewline "  "

  #$entity  print_ch $name
  ent_print_ch_ $entity $name

  puts ""

}
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------

# /*
#  * Global variables.
#  */
# static TableStruct	*pop_table=NULL;	/* The population table. */

# THREAD_LOCK_DEFINE_STATIC(pop_table_lock);
# /* #ifdef USE_OPENMP */
# /* static boolean gaul_openmp_initialised = FALSE; */
# /* #endif */

# /*
#  * Lookup table for functions.
#  *
#  * This is required for saving defined code hooks in files and for
#  * some script interfaces.
#  */
# struct func_lookup {char *funcname; void *func_ptr;};

# static struct func_lookup lookup[]={
# 	{ NULL, NULL },
# 	{ "ga_select_one_random",                      (void *) ga_select_one_random },
# 	{ "ga_select_two_random",                      (void *) ga_select_two_random },
# 	{ "ga_select_one_every",                       (void *) ga_select_one_every },
# 	{ "ga_select_two_every",                       (void *) ga_select_two_every },
# 	{ "ga_select_one_randomrank",                  (void *) ga_select_one_randomrank },
# 	{ "ga_select_two_randomrank",                  (void *) ga_select_two_randomrank },
# 	{ "ga_select_one_bestof2",                     (void *) ga_select_one_bestof2 },
# 	{ "ga_select_two_bestof2",                     (void *) ga_select_two_bestof2 },
# 	{ "ga_select_one_bestof3",                     (void *) ga_select_one_bestof3 },
# 	{ "ga_select_two_bestof3",                     (void *) ga_select_two_bestof3 },
# 	{ "ga_select_one_roulette",                    (void *) ga_select_one_roulette },
# 	{ "ga_select_two_roulette",                    (void *) ga_select_two_roulette },
# 	{ "ga_select_one_roulette_rebased",            (void *) ga_select_one_roulette_rebased },
# 	{ "ga_select_two_roulette_rebased",            (void *) ga_select_two_roulette_rebased },
# 	{ "ga_select_one_sus",                         (void *) ga_select_one_sus },
# 	{ "ga_select_two_sus",                         (void *) ga_select_two_sus },
# 	{ "ga_select_one_sussq",                       (void *) ga_select_one_sussq },
# 	{ "ga_select_two_sussq",                       (void *) ga_select_two_sussq },
# 	{ "ga_select_one_best",                        (void *) ga_select_one_best },
# 	{ "ga_select_two_best",                        (void *) ga_select_two_best },
# 	{ "ga_select_one_aggressive",                  (void *) ga_select_one_aggressive },
# 	{ "ga_select_two_aggressive",                  (void *) ga_select_two_aggressive },
# 	{ "ga_select_one_linearrank",                  (void *) ga_select_one_linearrank },
# 	{ "ga_select_two_linearrank",                  (void *) ga_select_two_linearrank },
# 	{ "ga_select_one_roundrobin",                  (void *) ga_select_one_roundrobin },
# 	{ "ga_crossover_integer_singlepoints",         (void *) ga_crossover_integer_singlepoints },
# 	{ "ga_crossover_integer_doublepoints",         (void *) ga_crossover_integer_doublepoints },
# 	{ "ga_crossover_integer_mean",                 (void *) ga_crossover_integer_mean },
# 	{ "ga_crossover_integer_mixing",               (void *) ga_crossover_integer_mixing },
# 	{ "ga_crossover_integer_allele_mixing",        (void *) ga_crossover_integer_allele_mixing },
# 	{ "ga_crossover_boolean_singlepoints",         (void *) ga_crossover_boolean_singlepoints },
# 	{ "ga_crossover_boolean_doublepoints",         (void *) ga_crossover_boolean_doublepoints },
# 	{ "ga_crossover_boolean_mixing",               (void *) ga_crossover_boolean_mixing },
# 	{ "ga_crossover_boolean_allele_mixing",        (void *) ga_crossover_boolean_allele_mixing },
# 	{ "ga_crossover_char_singlepoints",            (void *) ga_crossover_char_singlepoints },
# 	{ "ga_crossover_char_doublepoints",            (void *) ga_crossover_char_doublepoints },
# 	{ "ga_crossover_char_mixing",                  (void *) ga_crossover_char_mixing },
# 	{ "ga_crossover_char_allele_mixing",           (void *) ga_crossover_char_allele_mixing },
# 	{ "ga_crossover_double_mean",                  (void *) ga_crossover_double_mean },
# 	{ "ga_crossover_double_mixing",                (void *) ga_crossover_double_mixing },
# 	{ "ga_crossover_double_allele_mixing",         (void *) ga_crossover_double_allele_mixing },
# 	{ "ga_crossover_double_singlepoints",          (void *) ga_crossover_double_singlepoints },
# 	{ "ga_crossover_double_doublepoints",          (void *) ga_crossover_double_doublepoints },
# 	{ "ga_crossover_bitstring_singlepoints",       (void *) ga_crossover_bitstring_singlepoints },
# 	{ "ga_crossover_bitstring_doublepoints",       (void *) ga_crossover_bitstring_doublepoints },
# 	{ "ga_crossover_bitstring_mixing",             (void *) ga_crossover_bitstring_mixing },
# 	{ "ga_crossover_bitstring_allele_mixing",      (void *) ga_crossover_bitstring_allele_mixing },
# 	{ "ga_mutate_integer_singlepoint_drift",       (void *) ga_mutate_integer_singlepoint_drift },
# 	{ "ga_mutate_integer_singlepoint_randomize",   (void *) ga_mutate_integer_singlepoint_randomize },
# 	{ "ga_mutate_integer_multipoint",              (void *) ga_mutate_integer_multipoint },
# 	{ "ga_mutate_integer_allpoint",                (void *) ga_mutate_integer_allpoint },
# 	{ "ga_mutate_boolean_singlepoint",             (void *) ga_mutate_boolean_singlepoint },
# 	{ "ga_mutate_boolean_multipoint",              (void *) ga_mutate_boolean_multipoint },
# 	{ "ga_mutate_char_singlepoint_drift",          (void *) ga_mutate_char_singlepoint_drift },
# 	{ "ga_mutate_char_singlepoint_randomize",      (void *) ga_mutate_char_singlepoint_randomize },
# 	{ "ga_mutate_char_allpoint",                   (void *) ga_mutate_char_allpoint },
# 	{ "ga_mutate_char_multipoint",                 (void *) ga_mutate_char_multipoint },
# 	{ "ga_mutate_printable_singlepoint_drift",     (void *) ga_mutate_printable_singlepoint_drift },
# 	{ "ga_mutate_printable_singlepoint_randomize", (void *) ga_mutate_printable_singlepoint_randomize },
# 	{ "ga_mutate_printable_multipoint",            (void *) ga_mutate_printable_multipoint },
# 	{ "ga_mutate_printable_allpoint",              (void *) ga_mutate_printable_allpoint },
# 	{ "ga_mutate_bitstring_singlepoint",           (void *) ga_mutate_bitstring_singlepoint },
# 	{ "ga_mutate_bitstring_multipoint",            (void *) ga_mutate_bitstring_multipoint },
# 	{ "ga_mutate_double_singlepoint_randomize",    (void *) ga_mutate_double_singlepoint_randomize },
# 	{ "ga_mutate_double_singlepoint_drift",        (void *) ga_mutate_double_singlepoint_drift },
# 	{ "ga_mutate_double_allpoint",                 (void *) ga_mutate_double_allpoint },
# 	{ "ga_mutate_double_multipoint",               (void *) ga_mutate_double_multipoint },
# 	{ "ga_seed_boolean_random",                    (void *) ga_seed_boolean_random },
# 	{ "ga_seed_boolean_zero",                      (void *) ga_seed_boolean_zero },
# 	{ "ga_seed_integer_random",                    (void *) ga_seed_integer_random },
# 	{ "ga_seed_integer_zero",                      (void *) ga_seed_integer_zero },
# 	{ "ga_seed_double_random",                     (void *) ga_seed_double_random },
# 	{ "ga_seed_double_zero",                       (void *) ga_seed_double_zero },
# 	{ "ga_seed_double_random_unit_gaussian",       (void *) ga_seed_double_random_unit_gaussian },
# 	{ "ga_seed_char_random",                       (void *) ga_seed_char_random },
# 	{ "ga_seed_printable_random",                  (void *) ga_seed_printable_random },
# 	{ "ga_seed_bitstring_random",                  (void *) ga_seed_bitstring_random },
# 	{ "ga_seed_bitstring_zero",                    (void *) ga_seed_bitstring_zero },
# 	{ "ga_replace_by_fitness",                     (void *) ga_replace_by_fitness },
# 	{ "ga_rank_fitness",                           (void *) ga_rank_fitness },
# 	{ "ga_chromosome_integer_allocate",            (void *) ga_chromosome_integer_allocate },
# 	{ "ga_chromosome_integer_deallocate",          (void *) ga_chromosome_integer_deallocate },
# 	{ "ga_chromosome_integer_replicate",           (void *) ga_chromosome_integer_replicate },
# 	{ "ga_chromosome_integer_to_bytes",            (void *) ga_chromosome_integer_to_bytes },
# 	{ "ga_chromosome_integer_from_bytes",          (void *) ga_chromosome_integer_from_bytes },
# 	{ "ga_chromosome_integer_to_string",           (void *) ga_chromosome_integer_to_string },
# 	{ "ga_chromosome_boolean_allocate",            (void *) ga_chromosome_boolean_allocate },
# 	{ "ga_chromosome_boolean_deallocate",          (void *) ga_chromosome_boolean_deallocate },
# 	{ "ga_chromosome_boolean_replicate",           (void *) ga_chromosome_boolean_replicate },
# 	{ "ga_chromosome_boolean_to_bytes",            (void *) ga_chromosome_boolean_to_bytes },
# 	{ "ga_chromosome_boolean_from_bytes",          (void *) ga_chromosome_boolean_from_bytes },
# 	{ "ga_chromosome_boolean_to_string",           (void *) ga_chromosome_boolean_to_string },
# 	{ "ga_chromosome_double_allocate",             (void *) ga_chromosome_double_allocate },
# 	{ "ga_chromosome_double_deallocate",           (void *) ga_chromosome_double_deallocate },
# 	{ "ga_chromosome_double_replicate",            (void *) ga_chromosome_double_replicate },
# 	{ "ga_chromosome_double_to_bytes",             (void *) ga_chromosome_double_to_bytes },
# 	{ "ga_chromosome_double_from_bytes",           (void *) ga_chromosome_double_from_bytes },
# 	{ "ga_chromosome_double_to_string",            (void *) ga_chromosome_double_to_string },
# 	{ "ga_chromosome_char_allocate",               (void *) ga_chromosome_char_allocate },
# 	{ "ga_chromosome_char_deallocate",             (void *) ga_chromosome_char_deallocate },
# 	{ "ga_chromosome_char_replicate",              (void *) ga_chromosome_char_replicate },
# 	{ "ga_chromosome_char_to_bytes",               (void *) ga_chromosome_char_to_bytes },
# 	{ "ga_chromosome_char_from_bytes",             (void *) ga_chromosome_char_from_bytes },
# 	{ "ga_chromosome_char_to_string",              (void *) ga_chromosome_char_to_string },
# 	{ "ga_chromosome_bitstring_allocate",          (void *) ga_chromosome_bitstring_allocate },
# 	{ "ga_chromosome_bitstring_deallocate",        (void *) ga_chromosome_bitstring_deallocate },
# 	{ "ga_chromosome_bitstring_replicate",         (void *) ga_chromosome_bitstring_replicate },
# 	{ "ga_chromosome_bitstring_to_bytes",          (void *) ga_chromosome_bitstring_to_bytes },
# 	{ "ga_chromosome_bitstring_from_bytes",        (void *) ga_chromosome_bitstring_from_bytes },
# 	{ "ga_chromosome_bitstring_to_string",         (void *) ga_chromosome_bitstring_to_string },
# 	{ "ga_chromosome_list_allocate",               (void *) ga_chromosome_list_allocate },
# 	{ "ga_chromosome_list_deallocate",             (void *) ga_chromosome_list_deallocate },
# 	{ "ga_chromosome_list_replicate",              (void *) ga_chromosome_list_replicate },
# 	{ "ga_chromosome_list_to_bytes",               (void *) ga_chromosome_list_to_bytes },
# 	{ "ga_chromosome_list_from_bytes",             (void *) ga_chromosome_list_from_bytes },
# 	{ "ga_chromosome_list_to_string",              (void *) ga_chromosome_list_to_string },
# 	{ NULL, NULL } };


# /**********************************************************************
#   Private utility functions.
#  **********************************************************************/

# /**********************************************************************
#   synopsis:	Destroys an userdata list and it's contents.  For
# 		many applications, the destructor callback will just
# 		be free() or similar.  This callback may safely be
# 		NULL.
#   parameters:	population *pop	 Population.
# 		SLList     *list Phenomic data.
#  **********************************************************************/
# void 
# destruct_list (population *pop, SLList *list)
# {
#   SLList        *present;	/* Current list element */
#  int		num_destroyed;	/* Count number of things destroyed. */
#   vpointer	data;		/* Data in item. */

#   /* A bit of validation. */
#   if ( !pop ) die("Null pointer to population structure passed.");
#   if ( !list ) die("Null pointer to list passed.");

#   /*
#   * Deallocate data stored in the list, if required.
#   */
#   if ( pop->data_destructor )
#   {
#   num_destroyed = 0;
#   present=list;

#   while(present!=NULL)
#   {
#   if ((data = slink_data(present)))
#   {
#   pop->data_destructor(data);
#   num_destroyed++;
#   }
#   present=slink_next(present);
#   }

# #if GA_DEBUG>2
#   /*
#   * Not typically needed now, because num_destrtoyed may
#   * (correctly) differ from the actual number of chromosomes.
#   */
#   if (num_destroyed != 1/* pop->num_chromosomes */)
#   printf ("Uh oh! Dodgy user data here? %d %d\n",
#           num_destroyed, 1/* pop->num_chromosomes */);
# #endif

#   }

#   /* Deallocate the list sructure. */
#   slink_free_all(list);

#   return;
# }
#-------------------------------------------------------------------------------
#   Population handling functions.
#-------------------------------------------------------------------------------
#   synopsis:	Allocates and initialises a new population structure,
# 		and assigns a new population id to it.
#   parameters:	const int stable_size		Num. individuals carried into next generation.
# 		const int num_chromosome	Num. of chromosomes.
# 		const int len_chromosome	Size of chromosomes (may be ignored).
#   return:	population *	new population structure.

# population *
# ga_population_new (const int stable_size, /* const int num_chromosome, */
#                    const int len_chromosome)
#-------------------------------------------------------------------------------
proc ga_population_new {stable_size len_chromosome} {

  #   puts ""
  #   puts "ga_population_new ..."
  #   puts ""
  
  #   population	*newpop=NULL;	/* New population structure. */
  set newpop ""
  
  #   unsigned int	pop_id;		/* Handle for new population structure. */
  #   int		i;		/* Loop over (unassigned) entities. */
  
  #   if ( !(newpop = s_malloc(sizeof(population))) )
  #     die("Unable to allocate memory");
  
  #set newpop [POPULATION_T %AUTO%]
  set newpop [pop_create_]
  
  $newpop configure -ch_form  "% 6.3f" ;#  " %02d"

  # newpop->size = 0;
  $newpop configure -size 0 
  
  # newpop->stable_size = stable_size;
  $newpop configure -stable_size $stable_size
  
  #   newpop->max_size = (1+stable_size)*4;  /* +1 prevents problems if stable_size is 0. */
  
  #   newpop->orig_size = 0;
  $newpop configure -orig_size 0
  
  #   //newpop->num_chromosomes = /* num_chromosome */ 1;
  $newpop configure -len_chromosomes  $len_chromosome
  
  #  $newpop print
  
  #   newpop->data = NULL;
  #   newpop->free_index = newpop->max_size-1;
  $newpop configure -island  -1
  #   newpop->generation = 0;
  $newpop configure -generation 0
  
  #   newpop->fitness_dimensions = 0;
  $newpop configure -fitness_dimensions 0

  $newpop configure -best  -1 ;# для хранения лучшего номера (пока нет)

  #   newpop->crossover_ratio = GA_DEFAULT_CROSSOVER_RATIO;
  #   newpop->mutation_ratio = GA_DEFAULT_MUTATION_RATIO;
  #   newpop->migration_ratio = GA_DEFAULT_MIGRATION_RATIO;
  #   newpop->scheme = GA_SCHEME_DARWIN;
  $newpop configure -scheme GA_SCHEME_DARWIN;

  #   newpop->elitism = GA_ELITISM_PARENTS_SURVIVE;
  
  #   newpop->allele_mutation_prob = GA_DEFAULT_ALLELE_MUTATION_PROB;

  #   newpop->allele_min_integer = 0;
  #   newpop->allele_max_integer = RAND_MAX-1;
  $newpop configure -allele_min_integer 0
  #$newpop configure -allele_max_integer [expr $RAND_MAX - 1]
  $newpop configure -allele_max_integer [expr $::RANDOM_RAND_MAX - 1] ;# попробуем так

  # 
  #/* this may seem like an odd choice, but it is to maintain compatiability with older versions. */
  
  #   newpop->allele_min_double = DBL_MIN;
  #   newpop->allele_max_double = DBL_MAX;
  $newpop configure -allele_min_double $::DBL_MIN
  $newpop configure -allele_max_double $::DBL_MAX

  #   if ( !(newpop->entity_array = s_malloc(newpop->max_size*sizeof(entity*))) )
  #     die("Unable to allocate memory");
  #$newpop configure -entity_array "E1 E2 E3 E4" ;# ???? зачем это?
  
  #   if ( !(newpop->entity_iarray = s_malloc(newpop->max_size*sizeof(entity*))) )
  #     die("Unable to allocate memory");
  #$newpop configure -entity_iarray ""
  
  #   newpop->entity_chunk = mem_chunk_new(sizeof(entity), 512);

  #   /*
  #     * Wipe the entity arrays.
  #     */
  #   for (i=0; i<newpop->max_size; i++)
  #   {
  #     newpop->entity_array [i] = NULL;
  #     newpop->entity_iarray[i] = NULL;
  #   }
  
  #   /*
  #     * Wipe optional parameter data.
  #     */
  #   newpop->tabu_params = NULL;
  #   newpop->sa_params = NULL;
  #   newpop->climbing_params = NULL;
  #   newpop->simplex_params = NULL;
  #   newpop->dc_params = NULL;
  #   newpop->gradient_params = NULL;
  #   newpop->search_params = NULL;
  #   newpop->de_params = NULL;
  #   newpop->sampling_params = NULL;
  
  #   /*
  #     * Clean the callback functions.
  #     * Prevents erronerous callbacks - helpful when debugging!
  #     */
  #   newpop->generation_hook = NULL;
  #   newpop->iteration_hook = NULL;
  
  #   newpop->data_destructor = NULL;
  #   newpop->data_ref_incrementor = NULL;
  
  #   newpop->population_data_destructor = NULL;
  #   newpop->population_data_copy = NULL;
  
  #   newpop->chromosome_constructor = NULL;
  #   newpop->chromosome_destructor = NULL;
  #   newpop->chromosome_replicate = NULL;
  #   newpop->chromosome_to_bytes = NULL;
  #   newpop->chromosome_from_bytes = NULL;
  #   newpop->chromosome_to_string = NULL;
  
  #   newpop->evaluate = NULL;
  #   newpop->seed = NULL;
  #   newpop->adapt = NULL;
  #   newpop->select_one = NULL;
  #   newpop->select_two = NULL;
  #   newpop->mutate = NULL;
  #   newpop->crossover = NULL;
  #   newpop->replace = NULL;
  
  $newpop configure -rank "ga_rank_fitness"

  #   /*
  #     * Efficient memory chunks for chromosome handling.
  #     */
  # #ifdef USE_CHROMO_CHUNKS
  #   newpop->chromoarray_chunk = NULL;
  #   newpop->chromo_chunk = NULL;
  # #endif
  
  #   /*
  #     * Add this new population into the population table. ???
  #     */

  #   THREAD_LOCK(pop_table_lock);
  #   if ( !pop_table ) pop_table = table_new();
  
  #   pop_id = table_add (pop_table, (vpointer) newpop);
  #   THREAD_UNLOCK(pop_table_lock);
  
  #   plog( LOG_DEBUG, "New pop = %p id = %d", newpop, pop_id);
  
  return $newpop
}
#-------------------------------------------------------------------------------
#   synopsis:	Allocates and initialises a new population structure,
# 		and fills it with an exact copy of the data from an
# 		existing population, with the exception that entity
# 		data is not copied.  The population's user data
# 		field is referenced.
#   parameters:	population *	original population structure.
#   return:	population *	new population structure.
#-------------------------------------------------------------------------------
# population *
# ga_population_clone_empty (population *pop)
#-------------------------------------------------------------------------------
proc ga_population_clone_empty {pop} \
{

  #   int		i;		/* Loop variable. */
  #   population	*newpop=NULL;	/* New population structure. */
  #   unsigned int	pop_id;		/* Handle for new population structure. */
  
  #   /* Checks */
  #   if ( !pop ) die("Null pointer to population structure passed.");
  
  #   /*
  #     * Allocate new structure.
  #     */
  #   if ( !(newpop = s_malloc(sizeof(population))) )
  #     die("Unable to allocate memory");

  #set newpop [POPULATION_T %AUTO%]
  set newpop [pop_create_]
  
  #   /*
  #     * Clone parameters.
  #     */
  $newpop configure -size  0
  $newpop configure -stable_size [$pop cget -stable_size]
  $newpop configure -max_size    [$pop cget -max_size]
  $newpop configure -orig_size   0
  #   //newpop->num_chromosomes = 1/* pop->num_chromosomes */;
  $newpop configure -len_chromosomes [$pop cget -len_chromosomes]

  #//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~`
  $newpop configure -ch_form [$pop cget -ch_form]
  #//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~`

  #   newpop->free_index = pop->max_size - 1;
  $newpop configure -island    -1
  $newpop configure -generation 0
  
  $newpop configure -fitness_dimensions 0
  
  $newpop configure -crossover_ratio [$pop cget -crossover_ratio]
  $newpop configure -mutation_ratio  [$pop cget -mutation_ratio]
  $newpop configure -migration_ratio [$pop cget -migration_ratio]
  
  $newpop configure -scheme [$pop cget -scheme]
  
  $newpop configure -elitism [$pop cget -elitism]
  
  #   newpop->allele_mutation_prob = pop->allele_mutation_prob;

  #// ???? явная ошибка !    надо pop->
  # ?????????/ !!!!!!!!!!!!!!!!! ERROR !!!!!!!!!!!!!!!!!!!!!
  #
  #newpop->allele_min_integer   [newpop->allele_min_integer]
  #newpop->allele_max_integer   = newpop->allele_max_integer
  #newpop->allele_min_double    = newpop->allele_min_double;
  #newpop->allele_max_double    = newpop->allele_max_double;

  #   THREAD_LOCK_NEW(newpop->lock);
  # #ifdef USE_CHROMO_CHUNKS
  #   THREAD_LOCK_NEW(newpop->chromo_chunk_lock);
  # #endif
  
  #   /*
  #     * Clone the callback functions.
  #     */

  $newpop configure -generation_hook [$pop cget -generation_hook]
  #$newpop configure -iteration_hook  [$pop cget -iteration_hook ]
  
  #   newpop->data_destructor = pop->data_destructor;
  #   newpop->data_ref_incrementor = pop->data_ref_incrementor;
  
  #   newpop->population_data_destructor = pop->population_data_destructor;
  #   newpop->population_data_copy = pop->population_data_copy;
  
  #   newpop->chromosome_constructor = pop->chromosome_constructor;
  #   newpop->chromosome_destructor = pop->chromosome_destructor;
  #   newpop->chromosome_replicate = pop->chromosome_replicate;
  #   newpop->chromosome_to_bytes = pop->chromosome_to_bytes;
  #   newpop->chromosome_from_bytes = pop->chromosome_from_bytes;
  #   newpop->chromosome_to_string = pop->chromosome_to_string;

  $newpop configure -evaluate   [$pop cget -evaluate]
  $newpop configure -seed       [$pop cget -seed ]
  $newpop configure -adapt      [$pop cget -adapt]
  $newpop configure -select_one [$pop cget -select_one]
  $newpop configure -select_two [$pop cget -select_two]
  $newpop configure -mutate     [$pop cget -mutate    ]
  $newpop configure -crossover  [$pop cget -crossover ]
  $newpop configure -replace    [$pop cget -replace   ]
  $newpop configure -rank       [$pop cget -rank      ]
  
  #   /*
  #     * Copy optional parameter data.
  #     */
  #   if (pop->data == NULL)
  #   {
  #     newpop->data = NULL;
  #   }
  #   else if (pop->population_data_copy)
  #   {
  #     newpop->data = pop->population_data_copy(pop->data);
  #   }
  #   else
  #   {
  #     newpop->data = pop->data;
  #   }
  
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #   if (pop->tabu_params == NULL)
  #   {
  #     newpop->tabu_params = NULL;
  #   }
  #   else
  #   {
  #     if ( !(newpop->tabu_params = s_malloc(sizeof(ga_tabu_t))) )
  #       die("Unable to allocate memory");
  
  #     newpop->tabu_params->tabu_accept = pop->tabu_params->tabu_accept;
  #     newpop->tabu_params->list_length = pop->tabu_params->list_length;
  #     newpop->tabu_params->search_count = pop->tabu_params->search_count;
  #   }

  $newpop configure -tabu_params         [$pop cget -tabu_params]
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  

  #   if (pop->sa_params == NULL)
  #   {
  #     newpop->sa_params = NULL;
  #   }
  #   else
  #   {
  #     if ( !(newpop->sa_params = s_malloc(sizeof(ga_sa_t))) )
  #       die("Unable to allocate memory");
  
  #     newpop->sa_params->sa_accept = pop->sa_params->sa_accept;
  #     newpop->sa_params->initial_temp = pop->sa_params->initial_temp;
  #     newpop->sa_params->final_temp = pop->sa_params->final_temp;
  #     newpop->sa_params->temp_step = pop->sa_params->temp_step;
  #     newpop->sa_params->temp_freq = pop->sa_params->temp_freq;
  #     newpop->sa_params->temperature = pop->sa_params->temperature;
  #   }
  
  #   if (pop->climbing_params == NULL)
  #   {
  #     newpop->climbing_params = NULL;
  #   }
  #   else
  #   {
  #     if ( !(newpop->climbing_params = s_malloc(sizeof(ga_climbing_t))) )
  #       die("Unable to allocate memory");
  
  #     newpop->climbing_params->mutate_allele = pop->climbing_params->mutate_allele;
  #   }
  
  #   if (pop->simplex_params == NULL)
  #   {
  #     newpop->simplex_params = NULL;
  #   }
  #   else
  #   {
  #     if ( !(newpop->simplex_params = s_malloc(sizeof(ga_simplex_t))) )
  #       die("Unable to allocate memory");
  
  #     newpop->simplex_params->to_double = pop->simplex_params->to_double;
  #     newpop->simplex_params->from_double = pop->simplex_params->from_double;
  #     newpop->simplex_params->dimensions = pop->simplex_params->dimensions;
  #     newpop->simplex_params->step = pop->simplex_params->step;
  #     newpop->simplex_params->alpha = pop->simplex_params->alpha;
  #     newpop->simplex_params->beta = pop->simplex_params->beta;
  #     newpop->simplex_params->gamma = pop->simplex_params->gamma;
  #   }
  
  #   if (pop->dc_params == NULL)
  #   {
  #     newpop->dc_params = NULL;
  #   }
  #   else
  #   {
  #     if ( !(newpop->dc_params = s_malloc(sizeof(ga_dc_t))) )
  #       die("Unable to allocate memory");
  
  #     newpop->dc_params->compare = pop->dc_params->compare;
  #   }
  
  #   if (pop->gradient_params == NULL)
  #   {
  #     newpop->gradient_params = NULL;
  #   }
  #   else
  #   {
  #     if ( !(newpop->gradient_params = s_malloc(sizeof(ga_gradient_t))) )
  #       die("Unable to allocate memory");
  
  #     newpop->gradient_params->to_double = pop->gradient_params->to_double;
  #     newpop->gradient_params->from_double = pop->gradient_params->from_double;
  #     newpop->gradient_params->gradient = pop->gradient_params->gradient;
  #     newpop->gradient_params->step_size = pop->gradient_params->step_size;
  #     newpop->gradient_params->dimensions = pop->gradient_params->dimensions;
  #     newpop->gradient_params->alpha = pop->gradient_params->alpha;
  #   }
  
  #   if (pop->search_params == NULL)
  #   {
  #     newpop->search_params = NULL;
  #   }
  #   else
  #   {
  #     if ( !(newpop->search_params = s_malloc(sizeof(ga_search_t))) )
  #       die("Unable to allocate memory");
  
  #     newpop->search_params->scan_chromosome = pop->search_params->scan_chromosome;
  #     newpop->search_params->chromosome_state = 0;
  #     newpop->search_params->allele_state = 0;
  #   }
  
  #   if (pop->de_params == NULL)
  #   {
  #     newpop->de_params = NULL;
  #   }
  #   else
  #   {
  #     if ( !(newpop->de_params = s_malloc(sizeof(ga_de_t))) )
  #       die("Unable to allocate memory");
  
  $newpop configure -de_strategy         [$pop cget -de_strategy]
  $newpop configure -de_crossover_method [$pop cget -de_crossover_method]
  $newpop configure -de_num_perturbed    [$pop cget -de_num_perturbed   ]
  $newpop configure -de_crossover_factor [$pop cget -de_crossover_factor]
  $newpop configure -de_weighting_min    [$pop cget -de_weighting_min]
  $newpop configure -de_weighting_max    [$pop cget -de_weighting_max]
  #   }
  
  #   if (newpop->sampling_params == NULL)
  #   {
  #     newpop->sampling_params = NULL;
  #   }
  #   else
  #   {
  #     newpop->sampling_params = NULL;
  
  #     newpop->sampling_params->num_states = pop->sampling_params->num_states;
  #   }
  
  #   /*
  #     * Allocate arrays etc.
  #     */
  #   if ( !(newpop->entity_array = s_malloc(newpop->max_size*sizeof(entity*))) )
  #     die("Unable to allocate memory");
  #   if ( !(newpop->entity_iarray = s_malloc(newpop->max_size*sizeof(entity*))) )
  #     die("Unable to allocate memory");
  #   newpop->entity_chunk = mem_chunk_new(sizeof(entity), 512);
  
  #   /*
  #     * Wipe the the entity arrays.
  #     */
  #   for (i=0; i<newpop->max_size; i++)
  #   {
  #     newpop->entity_array[i] = NULL;
  #     newpop->entity_iarray[i] = NULL;
  #   }
  
  #   /*
  #     * Add this new population into the population table. ???
  #     */

  #   THREAD_LOCK(pop_table_lock);
  #   if ( !pop_table ) pop_table = table_new();
  
  #   pop_id = table_add (pop_table, (vpointer) newpop);
  #   THREAD_UNLOCK(pop_table_lock);
  
  #   plog( LOG_DEBUG, "New pop = %p id = %d (cloned from %p)",
  #        newpop, pop_id, pop );
  
  return $newpop
}
#-------------------------------------------------------------------------------
#   synopsis:	Allocates and initialises a new population structure,
# 		and fills it with an exact copy of the data from an
# 		existing population, including the individual
# 		entity data.  The population's user data
# 		field is referenced.
# 		Entity id's between the populations will _NOT_
# 		correspond.
#   parameters:	population *	original population structure.
#   return:	population *	new population structure.
#-------------------------------------------------------------------------------
# population *
# ga_population_clone (population *pop)
#-------------------------------------------------------------------------------
proc ga_population_clone {pop}  \
{

  #   int	  i;		/* Loop variable.             */
  #   population *newpop=NULL;	/* New population structure.  */
  #   entity	 *newentity;	/* Used for cloning entities. */
  
  #   /* Note that checks are performed in the ga_population_clone_empty() function. */
  
  #   /*
  #     * Clone the population data.
  #     */
  set newpop [ga_population_clone_empty $pop]
  
  #   /*
  #     * Clone each of the constituent entities.
  #     */

  #   /* #pragma omp parallel for \ */
  #   /*    shared(pop,newpop) private(i,newentity) \ */
  #   /*    schedule(static) */

  for {set i 0} {$i < [$pop cget -size]} {incr i} \
  {
    set newentity [ga_get_free_entity  $newpop]
    #ga_entity_copy (newpop, newentity, pop->entity_iarray[i]);

    #ga_entity_copy $newpop $newentity [$pop get_entity $i]
    ga_entity_copy $newpop $newentity [pop_get_entity_ $pop  $i]
  }

  return $newpop
}
#-------------------------------------------------------------------------------
# /**********************************************************************
#   synopsis:	Gets the number of populations.
#   parameters:	none
#   return:	int	number of populations, -1 for undefined table.
#  **********************************************************************/
# int 
# ga_get_num_populations (void)
# {
#   int	num=-1;

#   THREAD_LOCK(pop_table_lock);
#   if (pop_table)
#   {
#     num = table_count_items(pop_table);
#   }
#   THREAD_UNLOCK(pop_table_lock);

#   return num;
# }
# /**********************************************************************
#   synopsis:	Get population pointer from its internal id.
#   parameters:	unsigned int	id for population.
#   return:	int
#  **********************************************************************/
# population *
# ga_get_population_from_id (unsigned int id)
# {
#   population	*pop=NULL;	/* The population pointer to return. */

#   THREAD_LOCK(pop_table_lock);
#   if (pop_table)
#   {
#     pop = (population *) table_get_data(pop_table, id);
#   }
#   THREAD_UNLOCK(pop_table_lock);

#   return pop;
# }
# /**********************************************************************
#   synopsis:	Get population's internal id from its pointer.
#   parameters:	population	population pointer to lookup.
#   return:	unsigned int	internal id for population (or -1 for no match).
#  **********************************************************************/
# unsigned int 
# ga_get_population_id (population *pop)
# {
#   unsigned int	id=TABLE_ERROR_INDEX;	/* Internal population id. */

#   THREAD_LOCK(pop_table_lock);
#   if (pop_table && pop)
#   {
#     id = table_lookup_index(pop_table, (vpointer) pop);
#   }
#   THREAD_UNLOCK(pop_table_lock);

#   return id;
# }
# /**********************************************************************
#   synopsis:	Get array of internal ids for all currently
# 		allocated populations.  The returned array needs to
# 		be deallocated by the caller.
#   parameters:	none
#   return:	unsigned int*	array of population ids (or NULL)
#  **********************************************************************/
# unsigned int *
# ga_get_all_population_ids (void)
# {
#   unsigned int	*ids=NULL;	/* Array of ids. */

#   THREAD_LOCK(pop_table_lock);
#   if (pop_table)
#   {
#     ids = table_get_index_all(pop_table);
#   }
#   THREAD_UNLOCK(pop_table_lock);

#   return ids;
# }
# /**********************************************************************
#   synopsis:	Get array of all currently allocated populations.  The
# 		returned array needs to be deallocated by the caller.
#   parameters:	none
#   return:	population**	array of population pointers
#  **********************************************************************/
# population **
# ga_get_all_populations (void)
# {
#   population	**pops=NULL;	/* Array of all population pointers. */

#   THREAD_LOCK(pop_table_lock);
#   if (pop_table)
#   {
#     pops = (population **) table_get_data_all(pop_table);
#   }
#   THREAD_UNLOCK(pop_table_lock);

#   return pops;
# }
#-------------------------------------------------------------------------------
# /**********************************************************************
#   synopsis:	Fills a population structure with genes.  Defined in
# 		a user-specified function.
#   parameters:	population *	The entity's population.
# 		entity *	The entity.
#   return:	boolean success.
#  **********************************************************************/
#-------------------------------------------------------------------------------
# boolean 
# ga_entity_seed (population *pop, entity *adam)
#-------------------------------------------------------------------------------
proc ga_entity_seed {pop adam} \
{

  #   if ( !pop ) die("Null pointer to population structure passed.");
  #   if ( !pop->seed ) die("Population seeding function is not defined.");
  
  #   return pop->seed(pop, adam);

  return [[$pop cget -seed]  $pop $adam]
}
#-------------------------------------------------------------------------------
#   synopsis:	Fills all entities in a population structure with
# 		genes from a user-specified function.
#   parameters:	population *pop
# 		int num			Number of entities to seed.
#   return:	boolean success.
#
# boolean 
# gaul_population_fill (population *pop, int num)
#-------------------------------------------------------------------------------
proc  gaul_population_fill {pop num} {

  #   plog (LOG_DEBUG, "Population seeding by user-defined genesis.");

  #   if ( !pop )       die("Null pointer to population structure passed.");
  #   if ( !pop->seed ) die("Population seeding function is not defined.");

  #   /* NOTE: OpenMP adjusts order of seeding operations here, and therefore alters results. */
  #   /* #pragma omp parallel for \ */
  #   /*    if (GAUL_DETERMINISTIC_OPENMP==0) \ */
  #   /*    shared(pop, num) private(i,adam) \ */
  #   /*    schedule(static) */

  set proc_seed [$pop cget -seed]

  for {set i 0} {$i < $num} {incr i} {

    #     /*printf("DEBUG: ga_population_seed() parallel for %d on %d/%d.\n", i, 
    #     omp_get_thread_num(), omp_get_num_threads());*/

    # set adam [ga_get_free_entity $pop]  ;# New population member
    #
    # напрямую эту функцию вызовем (а добавим в массив чуть позже) 
    # а можно ли сделать все правильно, т.е. как было ?
    #
    set adam [ga_entity_setup $pop] ;# создает и chromosome_constructor?

    # заполняем структуру элемента
    #  
    $proc_seed  $pop $adam

    if {$::is_print} {
      # проконтролируем:
      # 
      puts -nonewline "   i = $i  "
      #$adam print_ch
      ent_print_ch_ $adam

      puts ""
    }
    
    # вообще-то теперь надо добавить в популяцию: 
    # 
    #$pop add_entity $adam
    pop_add_entity_ $pop  $adam
    
  }

  if {$::is_print} {
    puts ""
  }

  return true
}
#-------------------------------------------------------------------------------
#   synopsis:	Fills all entities in a population structure with
# 		genes from a user-specified function.
#   parameters:	population
#   return:	boolean success.
#
# т.е. делает фил для всего размера популяции

# boolean 
# ga_population_seed (population *pop)
#-------------------------------------------------------------------------------
proc ga_population_seed {pop} {

  
  if {$::is_print} {
    puts "ga_population_seed  ......... \n"
  }

  # plog(LOG_DEBUG, "Population seeding by user-defined genesis.");

  return [gaul_population_fill  $pop [$pop cget -stable_size]]
}
#-------------------------------------------------------------------------------
#   synopsis:     Assign a unique id to a callback function for
# 		population disk format from its pointer.
#-------------------------------------------------------------------------------
# int 
# ga_funclookup_ptr_to_id (void *func)
# {
#   int	id=1;	/* Index into lookup table. */

#   if ( !func ) return 0;

#   while (lookup[id].func_ptr != NULL &&
#          func != lookup[id].func_ptr)
#     id++;

# #if GA_DEBUG>2
#   printf("Function id is %d\n", id);
# #endif

#   return lookup[id].func_ptr!=NULL?id:-1;
# }
# /**********************************************************************
#   synopsis:     Assign a unique id to a callback function for
# 		population disk format from its label.
#  **********************************************************************/
# int 
# ga_funclookup_label_to_id (char *funcname)
# {
#   int	id=1;	/* Index into lookup table. */

#   if ( !funcname ) return 0;

#   while (lookup[id].funcname != NULL &&
#          strcmp(funcname, lookup[id].funcname) != 0)
#     id++;

# #if GA_DEBUG>2
#   printf("Function id is %d\n", id);
# #endif

#   return lookup[id].func_ptr!=NULL?id:-1;
# }
# /**********************************************************************
#   synopsis:     Return the pointer to a callback function
# 		from its label.
#  **********************************************************************/
# void *
# ga_funclookup_label_to_ptr (char *funcname)
# {
#   int	id=1;	/* Index into lookup table. */

#   if ( !funcname ) return 0;

#   while (lookup[id].funcname != NULL &&
#          strcmp(funcname, lookup[id].funcname) != 0)
#     id++;

# #if GA_DEBUG>2
#   printf("Function id is %d\n", id);
# #endif

#   return lookup[id].func_ptr;
# }
# /**********************************************************************
#   synopsis:     Returns the pointer to a function from its unique id.
#  **********************************************************************/
# void *
# ga_funclookup_id_to_ptr (int id)
# {

# #if GA_DEBUG>2
#   printf("Looking for function with id %d\n", id);
# #endif

#   return (id<0)?NULL:lookup[id].func_ptr;
# }
# /**********************************************************************
#   synopsis:     Returns the label for a function from its unique id.
#  **********************************************************************/
# char *
# ga_funclookup_id_to_label (int id)
# {

# #if GA_DEBUG>2
#   printf("Looking for function with id %d\n", id);
# #endif

#   return (id<0)?NULL:lookup[id].funcname;
# }
# /**********************************************************************
#   synopsis:	Score a single entity.
#  **********************************************************************/
# double 
# ga_entity_evaluate (population *pop, entity *this_entity)
# {

#   if ( !pop ) die("Null pointer to population structure passed.");
#   if ( !this_entity ) die("Null pointer to entity structure passed.");
#   if ( !pop->evaluate ) die("Evaluation callback not defined.");

#   if (pop->evaluate(pop, this_entity) == FALSE)
#     this_entity->fitness = GA_MIN_FITNESS;

#   return this_entity->fitness;
# }
#-------------------------------------------------------------------------------
# /**********************************************************************
#   synopsis:	Score and sort entire population.  This is probably
# 		a good idea after changing the fitness function!
# 		Note: remember to define the callback functions first.
#  **********************************************************************/
#-------------------------------------------------------------------------------
# boolean 
# ga_population_score_and_sort (population *pop)
#-------------------------------------------------------------------------------
proc ga_population_score_and_sort {pop} \
{

  #   int  i;	    /* Loop variable over all entities. */
  
  # #if GA_DEBUG>2
  #   double	origfitness;	/* Stored fitness value. */
  # #endif
  
  #   /* Checks. */
  #   if ( !pop ) die("Null pointer to population structure passed.");
  #   if ( !pop->evaluate ) die("Evaluation callback not defined.");
  
  #   /*
  #     * Score and sort all of the population members.
  #     *
  #     * Note that this will (potentially) use a huge amount of memory more
  #     * than the original population data if the userdata hasn't been maintained.
  #     * Each chromosome is decoded separately, whereas originally many
  #     * degenerate chromosomes would share their userdata elements.
  #     */
  #   /* #pragma omp parallel for \ */
  #   /*    shared(pop) private(i) \ */
  #   /*    schedule(static) */
  
  for {set i 0} {$i < [$pop cget -size]} {incr i} \
  {
    # #if GA_DEBUG>2
    #     origfitness = pop->entity_iarray[i]->fitness;
    # #endif


    set e [pop_get_entity_ $pop  $i]

    # ~~~~~~~~~~~~~~~~~~~~~~~~~~
    #if {$::is_print} {
    #  puts ""
    #  ent_print_ch_ $e 
    #  puts ""
    #  puts ""
    #}
    # ~~~~~~~~~~~~~~~~~~~~~~~~~~

    [$pop cget -evaluate]  $pop $e
    #  pop->evaluate (pop, pop->entity_iarray[i]);

    

    # #if GA_DEBUG>2
    #     if (origfitness != pop->entity_iarray[i]->fitness)
    #       plog(LOG_NORMAL,
    #            "Recalculated fitness %f doesn't match stored fitness %f for entity %d.",
    #            pop->entity_iarray[i]->fitness, origfitness, i);
    # #endif
  }
  

  # а теперь сортируем !!! !!! !!! !!!
  # 

  sort_population  $pop

  
  return true
}
#-------------------------------------------------------------------------------
# /**********************************************************************
#   synopsis:	Sort entire population (i.e. ensure that the entities
# 		are correctly ordered in ranking array -- currently
# 		rank is defined only by fitness).
# 		Note: remember to define the callback functions first.
#  **********************************************************************/
# boolean 
# ga_population_sort (population *pop)
# {

#   /* Checks. */
#   if ( !pop ) die("Null pointer to population structure passed.");

#   sort_population(pop);

#   return TRUE;
# }
# //******************************************************************************

# #if 0
# FIXME: The following 3 functions need to be fixed for the new absracted chromosome types.
# /**********************************************************************
#   synopsis:	Determine ratio of converged genotypes in population.
#  **********************************************************************/
# void 
# ga_population_convergence_genotypes (population *pop)
# {
#   int		i, j;		/* Loop over pairs of entities. */
#   int		count=0, converged=0;	/* Number of comparisons, matches. */

#   if ( !pop ) die("Null pointer to population structure passed.");
#   if (pop->size < 1) die("Pointer to empty population structure passed.");

#   for (i=1; i<pop->size; i++)
#   {
#     for (j=0; j<i; j++)
#     {
#       if (ga_compare_genome(pop, pop->entity_iarray[i], pop->entity_iarray[j]))
#         converged++;
#       count++;
#     }
#   }

#   return (double) converged/count;
# }
# /**********************************************************************
#   synopsis:	Determine ratio of converged chromosomes in population.
#  **********************************************************************/
# void 
# ga_population_convergence_chromosomes (population *pop)
# {
#   int		i, j;		/* Loop over pairs of entities. */
#   //int		k;		/* Loop over chromosomes. */
#   int		count=0, converged=0;	/* Number of comparisons, matches. */

#   if ( !pop ) die("Null pointer to population structure passed.");
#   if (pop->size < 1) die("Pointer to empty population structure passed.");

#   for (i=1; i<pop->size; i++)
#     //{
#   for (j=0; j<i; j++) {
#     //k=0;
#     //for (k=0; k<pop->num_chromosomes; k++)
#     //{
#     /* FIXME: Not counted efficiently: */
#     if (ga_count_match_alleles( pop->len_chromosomes,
#                                pop->entity_iarray[i]->CH/* chromosome[0] */,
#                                pop->entity_iarray[j]->CH/* chromosome[0] */) == pop->len_chromosomes)
#       converged++;
#     count++;
#     //}
#   }
#   //}

#   return (double) converged/count;
# }
# /**********************************************************************
#   synopsis:	Determine ratio of converged alleles in population.
#  **********************************************************************/
# void 
# ga_population_convergence_alleles (population *pop)
# {
#   int		i, j;		/* Loop over pairs of entities. */
#   //int		k;		/* Loop over chromosomes. */
#   int		count=0, converged=0;	/* Number of comparisons, matches. */

#   if ( !pop ) die("Null pointer to population structure passed.");
#   if (pop->size < 1) die("Pointer to empty population structure passed.");

#   for (i=1; i<pop->size; i++)
#   //{
#   for (j=0; j<i; j++) {
#     //k=0;
#     //for (k=0; k<pop->num_chromosomes; k++)
#     //{
#     converged+=ga_count_match_alleles( pop->len_chromosomes,
#                                       pop->entity_iarray[i]->CH/* chromosome[0] */,
#                                       pop->entity_iarray[j]->CH/* chromosome[0] */);
#     count+=pop->len_chromosomes;
#     //}
#   }
#   //}

#   return (double) converged/count;
# }
# #endif
#-------------------------------------------------------------------------------
#   synopsis:	Gets an entity's rank (subscript into entity_iarray of
# 		the population).  This is not necessarily the fitness
# 		rank unless the population has been sorted.
#-------------------------------------------------------------------------------
proc ga_get_entity_rank {pop e} \
{

  set rank 0  ;# /* The rank. */

  while {$rank < [$pop cget -size]} \
  {
    set e_tmp [pop_get_entity_ $pop $rank]

    if {$e_tmp == $e} {return $rank}

    incr rank
  }

  if {$::is_print} {
    puts stderr ""
    puts stderr "ga_get_entity_rank = -1,  e_tmp = |$e_tmp|   e = |$e|"
  }

  return -1
}
#-------------------------------------------------------------------------------
# /**********************************************************************
#   synopsis:	Gets an entity's rank (subscript into entity_iarray of
# 		the population).  This is not necessarily the fitness
# 		rank unless the population has been sorted.
#  **********************************************************************/
# int 
# ga_get_entity_rank_from_id (population *pop, int id)
# {
#   int	rank=0;		/* The rank. */

#   while (rank < pop->size)
#   {
#     if (pop->entity_iarray[rank] == pop->entity_array[id]) return rank;
#     rank++;
#   }

#   return -1;
# }
# /**********************************************************************
#   synopsis:	Gets an entity's id from its rank.
#  **********************************************************************/
# int 
# ga_get_entity_id_from_rank (population *pop, int rank)
# {
#   int	id=0;		/* The entity's index. */

#   while (id < pop->max_size)
#   {
#     if (pop->entity_array[id] == pop->entity_iarray[rank]) return id;
#     id++;
#   }

#   return -1;
# }
# /**********************************************************************
#   synopsis:	Gets an entity's internal index.
#  **********************************************************************/

# int 
# ga_get_entity_id (population *pop, entity *e)
# {
#   int	id=0;	/* The index. */

#   if ( !pop ) die("Null pointer to population structure passed.");
#   if ( !e ) die("Null pointer to entity structure passed.");

#   while (id < pop->max_size)
#   {
#     if (pop->entity_array[id] == e) return id;
#     id++;
#   }

#   return -1;
# }
# /**********************************************************************
#   synopsis:	Gets a pointer to an entity from it's internal index
# 		(subscript in the entity_array array).
#  **********************************************************************/
# entity *
# ga_get_entity_from_id (population *pop, const unsigned int id)
# {
#   if ( !pop ) die("Null pointer to population structure passed.");

#   if ( (int) id>pop->max_size ) return NULL;

#   return pop->entity_array[id];
# }
#-------------------------------------------------------------------------------
#   synopsis:	Gets a pointer to an entity from it's internal rank.
# 		(subscript into the entity_iarray buffer).
# 		Note that this only relates to fitness ranking if
# 		the population has been properly sorted.
#
# entity *
# ga_get_entity_from_rank (population *pop, const unsigned int rank)
#-------------------------------------------------------------------------------
proc ga_get_entity_from_rank {pop rank} {

  #   if ( !pop ) die ("Null pointer to population structure passed.");

  #   if ( rank > (unsigned) pop->size ) return NULL;
  #
  # если  rank=0 и  pop->size=0 , то чего возвращать?
  
  #   return pop->entity_iarray[rank];

  #return [$pop get_entity $rank]
  return [pop_get_entity_ $pop  $rank]
}
#-------------------------------------------------------------------------------
#   synopsis:	Prepares a pre-allocated entity structure for use.
# 		Chromosomes are allocated, but will contain garbage.
#
# static boolean 
# ga_entity_setup (population *pop, entity *joe)
#
#-------------------------------------------------------------------------------
proc ga_entity_setup {pop} {

  #   if (!joe)
  #     die("Null pointer to entity structure passed.");
  #   if (!pop->chromosome_constructor)
  #     die("Chromosome constructor not defined.");

  #puts "len_chromosomes = [$pop cget -len_chromosomes]"

  # здесь будем создавать сруктуру:
  # 

  set joe [ent_create_ [$pop cget -len_chromosomes]]

  $joe configure -ch_form [$pop cget -ch_form]

  #  // Allocate chromosome structures. 
  #  joe->chromosome = NULL;
  #  pop->chromosome_constructor(pop, joe);

  # вызываем "конструктор" для заполнения
  # 
  #set ch_constructor [$pop cget -chromosome_constructor]
  #$ch_constructor $pop $joe ;# -> ga_chromo.tl -> ga_chromosome_double_allocate
  #
  # ничего особо не делает?

  #  // Physical characteristics currently undefined. 
  #  joe->data=NULL;

  #  No fitness evaluated yet
  #
  $joe configure -fitness $::GA_MIN_FITNESS

  # остальное (мультихромосом) - не надо пока!
  #
  return $joe


  #   if {[$pop cget -fitness_dimensions] > 0} { 
  #     # This population is being used for multiobjective optimisation. */
  
  #     # Clear multiobjective fitness vector.
  
  #     for {set i 0} {$i < [$pop cget -fitness_dimensions} {incr i} {
  #       #joe->fitvector[i] = GA_MIN_FITNESS;
  #       puts stderr "I = $i"
  #     }
  
  #   } else {
  #     $joe configure -fitvector ""
  #   }
  
  
  #  return TRUE;
}
#-------------------------------------------------------------------------------

# /**********************************************************************
#   synopsis:	Marks an entity structure as unused.
# 		Deallocation is expensive.  It is better to re-use this
# 		memory.  So, that is what we do.
# 		Any contents of entities data field are freed.
# 		If rank is known, this is much quicker than the plain
# 		ga_entity_dereference() function.
# 		Note, no error checking in the interests of speed.
#  **********************************************************************/
# boolean 
# ga_entity_dereference_by_rank (population *pop, int rank)

#-------------------------------------------------------------------------------
proc ga_entity_dereference_by_rank {pop rank} {
 
  #   int		i;	/* Loop variable over the indexed array. */
  
  #   entity	*dying=pop->entity_iarray[rank];	/* Dead entity. */
  
  #   if (!dying) die("Invalid entity rank");
  
  #   /* Clear user data. */
  #   if (dying->data)
  #   {
  #     destruct_list(pop, dying->data);
  #     dying->data=NULL;
  #   }
  
  #   /* Free multiobjective fitness vector. */
  #   if ( dying->fitvector != NULL )
  #     s_free(dying->fitvector);
  
  #   THREAD_LOCK(pop->lock);
  
  #   /* Population size is one less now! */
  #   pop->size--;
  
  
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #
  # да нам надо просто ..
  
  #$pop del_entity  $rank
  pop_del_entity_ $pop $rank

  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  
  #   /* Deallocate chromosomes. */
  #   if (dying->chromosome) pop->chromosome_destructor(pop, dying);
  
  #   /* Update entity_iarray[], so there are no gaps! */
  #   for (i=rank; i<pop->size; i++)
  #     pop->entity_iarray[i] = pop->entity_iarray[i+1];
  
  #   pop->entity_iarray[pop->size] = NULL;
  
  #   /* Release index. */
  #   i = ga_get_entity_id (pop, dying);
  #   pop->entity_array[ga_get_entity_id(pop, dying)] = NULL;
  
  #   THREAD_UNLOCK(pop->lock);
  
  #   /* Release memory. */
  #   mem_chunk_free(pop->entity_chunk, dying);
  
  #   /*  printf("ENTITY %d DEREFERENCED. New pop size = %d\n", i, pop->size);*/
  
  return true
}
# /**********************************************************************
#   synopsis:	Marks an entity structure as unused.
# 		Deallocation is expensive.  It is better to re-use this
# 		memory.  So, that is what we do.
# 		Any contents of entities data field are freed.
# 		If rank is known, this is much quicker than the plain
# 		ga_entity_dereference() function, while this index
# 		based version is still almost as fast.
# 		Note, no error checking in the interests of speed.
#  **********************************************************************/
# boolean 
# ga_entity_dereference_by_id (population *pop, int id)
# {
#   int		i;	/* Loop variable over the indexed array. */
#   entity	*dying=pop->entity_array[id];	/* Dead entity. */

#   if (!dying) die("Invalid entity index");

#   /* Clear user data. */
#   if (dying->data)
#   {
#     destruct_list(pop, dying->data);
#     dying->data = NULL;
#   }

#   /* Free multiobjective fitness vector. */
#   if ( dying->fitvector != NULL )
#     s_free(dying->fitvector);

#   THREAD_LOCK(pop->lock);

#   /* Population size is one less now! */
#   pop->size--;

#   /* Update entity_iarray[], so there are no gaps! */
#   for (i=ga_get_entity_rank(pop, dying); i<pop->size; i++)
#     pop->entity_iarray[i] = pop->entity_iarray[i+1];

#   pop->entity_iarray[pop->size] = NULL;

#   /* Deallocate chromosomes. */
#   if (dying->chromosome) pop->chromosome_destructor(pop, dying);

#   THREAD_UNLOCK(pop->lock);

#   /* Release index. */
#   pop->entity_array[id] = NULL;

#   /* Release memory. */
#   mem_chunk_free(pop->entity_chunk, dying);

#   /*  printf("ENTITY %d DEREFERENCED. New pop size = %d\n", id, pop->size);*/

#   return TRUE;
# }
#-------------------------------------------------------------------------------
#   synopsis:	Marks an entity structure as unused.
# 		Deallocation is expensive.  It is better to re-use this
# 		memory.  So, that is what we do.
# 		Any contents of entities data field are freed.
# 		If rank is known, the above
# 		ga_entity_dereference_by_rank() or
# 		ga_entity_dereference_by_id() functions are much
# 		faster.
#-------------------------------------------------------------------------------
# boolean 
# ga_entity_dereference (population *pop, entity *dying)
#-------------------------------------------------------------------------------
proc ga_entity_dereference {pop dying} \
{

  set id [ga_get_entity_rank  $pop $dying]

  return [ga_entity_dereference_by_rank  $pop $id]

  #return ga_entity_dereference_by_rank (pop, ga_get_entity_rank (pop, dying));
}
#-------------------------------------------------------------------------------
# /**********************************************************************
#   synopsis:	Clears some of the entity's data.  Safe if data doesn't
# 		exist anyway.
#  **********************************************************************/
# void 
# ga_entity_clear_data (population *p, entity *this_entity, const int chromosome)
# {
#   SLList	*tmplist;
#   vpointer	data;		/* Data in item. */

#   if (this_entity->data)
#   {
#     tmplist = slink_nth(this_entity->data, chromosome);
#     if ( (data = slink_data(tmplist)) )
#     {
#       p->data_destructor(data);
#       tmplist->data=NULL;
#     }
#   }

#   return;
# }
#-------------------------------------------------------------------------------
#   synopsis:	Clears the entity's data.
# 		Equivalent to an optimised ga_entity_dereference()
# 		followed by ga_get_free_entity().  It is much more
# 		preferable to use this fuction!
# 		Chromosomes are gaurenteed to be intact, but may be
# 		overwritten by user.
#
# void 
# ga_entity_blank (population *p, entity *this_entity)

#-------------------------------------------------------------------------------
proc ga_entity_blank {p this_entity} {

  #   int	i;	/* Loop variable over the fitness vector. */
  
  #   if (this_entity->data)
  #   {
  #     destruct_list(p, this_entity->data);
  #     this_entity->data=NULL;
  #   }

  #   this_entity->fitness=GA_MIN_FITNESS;
  $this_entity  configure -fitness "GA_MIN_FITNESS"
  
  #   /* Clear multiobjective fitness vector. */
  #   for (i=0; i<p->fitness_dimensions; i++)
  #     this_entity->fitvector[i] = GA_MIN_FITNESS;
  
  #   /*  printf("ENTITY %d CLEARED.\n", ga_get_entity_id(p, this_entity));*/

  return
}
#-------------------------------------------------------------------------------
#   synopsis:	Returns pointer to an unused entity structure from the
# 		population's entity pool.  Increments population size
# 		too.
#-------------------------------------------------------------------------------
# entity *
# ga_get_free_entity (population *pop)
#-------------------------------------------------------------------------------
proc ga_get_free_entity {pop} {

#   int		new_max_size;	/* Increased maximum number of entities. */
#   int		i;
#   entity	*fresh;		/* Unused entity structure. */

#   /*
#     plog(LOG_DEBUG, "Locating free entity structure.");
#     */
#   THREAD_LOCK(pop->lock);

#   /*
#     * Do we have room for any new structures?
#     */

#   if (pop->max_size == (pop->size+1))
#   {	/* No, so allocate some more space. */
#     plog(LOG_VERBOSE, "No unused entities available -- allocating additional structures.");

#     new_max_size = (pop->max_size * 3)/2 + 1;

#     pop->entity_array  = s_realloc(pop->entity_array, new_max_size*sizeof(entity*));
#     pop->entity_iarray = s_realloc(pop->entity_iarray, new_max_size*sizeof(entity*));

#     for (i=pop->max_size; i<new_max_size; i++)
#     {
#       pop->entity_array [i] = NULL;
#       pop->entity_iarray[i] = NULL;
#     }

#     pop->max_size = new_max_size;
#     pop->free_index = new_max_size-1;
#   }

#   /* Find unused entity index. */
#   while (pop->entity_array[pop->free_index]!=NULL)
#   {
#     if (pop->free_index == 0) pop->free_index=pop->max_size;
#     pop->free_index--;
#   }

  #   /* Prepare it. */
  #   fresh = (entity *)mem_chunk_alloc(pop->entity_chunk);

  #   pop->entity_array[pop->free_index] = fresh;
  #   ga_entity_setup (pop, fresh);


  # здесь надо бы наоборот, сначала создать структуру, а потом записать в массив:
  # 
  set fresh [ga_entity_setup $pop]

  #$pop set_entity_array [$pop cget -free_index] $fresh
  # лучше добавить структуру попростому ? :
  #
  #$pop add_entity $fresh
  pop_add_entity_ $pop $fresh

  #set pop_size [$pop cget -size]

  #   /* Store in lowest free slot in entity_iarray */
  #$pop set_entity_iarray $pop_siz $fresh ;#   pop->entity_iarray[pop->size] = fresh;

  #   /* Population is bigger now! */
  # пусть  счетчик меняет функция добавления!
  # $pop configure -size [expr $pop_size + 1] ;#   pop->size++;


  #   THREAD_UNLOCK(pop->lock);
  #   /*  printf("ENTITY %d ALLOCATED.\n", pop->free_index);*/

  return $fresh
}
#-------------------------------------------------------------------------------
#   synopsis:	Copy one chromosome's portion of the data field of an
# 		entity structure to another entity structure.  (Copies
# 		the portion of the phenome relating to that chromosome)
# 		'Copies' NULL data safely.
# 		The destination chromosomes must be filled in order.
# 		If these entities are in differing populations, no
# 		problems will occur provided that the
# 		data_ref_incrementor callbacks are identical or at least
# 		compatible.
#-------------------------------------------------------------------------------
# boolean 
# ga_copy_data (population *pop, entity *dest, entity *src, const int chromosome)
# {
#   vpointer	tmpdata=NULL;	/* Temporary pointer. */

#   if ( !src || !(tmpdata = slink_nth_data(src->data, chromosome)) )
#   {
#     dest->data = slink_append (dest->data, NULL);
#   }
#   else
#   {
#     dest->data = slink_append (dest->data, tmpdata);
#     pop->data_ref_incrementor (tmpdata);
#   }

#   return TRUE;
# }
#-------------------------------------------------------------------------------
#   synopsis:	Copy one chromosome between entities.
# 		If these entities are in differing populations, no
# 		problems will occur provided that the chromosome
# 		datatypes match up.
#
# boolean 
# ga_copy_chromosome (population *pop, entity *dest, entity *src,
#                     const int chromosome)
#-------------------------------------------------------------------------------
proc ga_copy_chromosome {pop  dest src chromosome} {

  # вообще-то она NULL
  #
  #   pop->chromosome_replicate (pop, src,  dest, chromosome);
  

  return true
}
#-------------------------------------------------------------------------------
#   synopsis:	Copy genetic data between entity structures.
# 		If these entities are in differing populations, no
# 		problems will occur provided that the chromosome
# 		properties are identical.
#
# boolean 
# ga_entity_copy_all_chromosomes (population *pop, entity *dest, entity *src)
#-------------------------------------------------------------------------------
proc ga_entity_copy_all_chromosomes {pop dest src} {

  #   int  i;	/* Loop variable over all chromosomes. */

  #   /* Checks */
  #   if (!dest || !src) die("Null pointer to entity structure passed");
  
  #   /*
  #     * Ensure destination structure is not likely be already in use.
  #     */
  #   if (dest->data) die("Why does this entity already contain data?");
  
  #   /*
  #     * Copy genetic data.
  #     */

  set i 0

  #   //for (i=0; i<pop->num_chromosomes; i++)
  #   //{

  #   ga_copy_data(pop, dest, src, i);		/* Phenome. */

  ga_copy_chromosome $pop  $dest $src $i ;#	/* Genome. */

  #   //}
  
  return true
}
#-------------------------------------------------------------------------------
# /**********************************************************************
#   synopsis:	Copy chromosome and user data between entity
# 		structures.
#  **********************************************************************/
# boolean 
# ga_entity_copy_chromosome (population *pop, entity *dest, entity *src, int chromo)
# {

#   /* Checks. */
#   if (!dest || !src) die("Null pointer to entity structure passed");
#   if (chromo<0 || chromo>=1/* pop->num_chromosomes */) die("Invalid chromosome number.");

#   /*
#     * Ensure destination structure is not likely be already in use.
#     */
#   if (dest->data) die("Why does this entity already contain data?");

#   /*
#     * Copy genetic and associated structural data (phenomic data).
#     */
#   /*
#     memcpy(dest->chromosome[chromo], src->chromosome[chromo],
#     pop->len_chromosomes*sizeof(int));
#     */
#   ga_copy_data(pop, dest, src, chromo);
#   ga_copy_chromosome(pop, dest, src, chromo);

#   return TRUE;
# }
#-------------------------------------------------------------------------------
#   synopsis:	Copy entire entity structure.  This is safe
# 		for copying between populations... provided that they
# 		are compatible.
# 
# boolean 
# ga_entity_copy (population *pop, entity *dest, entity *src)
#-------------------------------------------------------------------------------
proc ga_entity_copy {pop dest src} {

  #puts "ga_entity_copy !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"

  #ga_entity_copy_all_chromosomes $pop $dest $src ;# не работало ?

  # у нас тут все просто:
  # 
  ent_set_chromosome_ $dest [ent_get_chromosome_ $src]  

  #   dest->fitness = src->fitness; # а тогда зачем, если раньше все скопировали?
  $dest configure -fitness [$src cget -fitness]

  return true;
}
#-------------------------------------------------------------------------------
proc ga_entity_clone_ {dolly parent} {

  # ga_entity_copy_all_chromosomes(pop, dolly, parent);

  # в нашем TCL можно все сделать проще (и хромосома у нас одна)
  # 
  ent_set_chromosome_ $dolly [ent_get_chromosome_ $parent]

  $dolly configure -fitness [$parent cget -fitness]

  return $dolly
}
#-------------------------------------------------------------------------------
#   synopsis:	Clone an entity structure.
# 		Safe for cloning into a different population, provided
# 		that the populations are compatible.
#   parameters:	population	*pop	Population.
# 		entity	*parent		The original entity.
#   return:	entity	*dolly		The new entity.

# entity *
# ga_entity_clone (population *pop, entity *parent)

#-------------------------------------------------------------------------------
proc ga_entity_clone {pop parent} {


  set dolly [ga_get_free_entity $pop]

  set dolly [ga_entity_clone_ $dolly $parent]

  return $dolly
}
#-------------------------------------------------------------------------------
proc ga_entity_clone_without_add {pop parent} {


  set dolly [ga_entity_setup $pop] ;# сразу эту вызовем 

  set dolly [ga_entity_clone_ $dolly $parent]

  return $dolly
}
#-------------------------------------------------------------------------------
#   Environmental operator function.

#   synopsis:	Optimise the entity's structure through local
# 		searching in the gene space.
# 		Should be default choice for "adaptation" function.
# 		The original entity will be left untouched.
#  **********************************************************************/
# entity *
# ga_optimise_entity (population *pop, entity *unopt)
# {
#   entity	*optimised;

#   /* Checks */
#   if ( !pop ) die("Null pointer to population structure passed.");
#   if ( !unopt ) die("Null pointer to entity structure passed.");

#   plog(LOG_FIXME,
#        "This function is deprecated and shoulf not be used.");

#   optimised = ga_entity_clone(pop, unopt);

#   /* FIXME: hard-coded value. */
#   ga_random_ascent_hillclimbing( pop, optimised, 25 );

#   plog(LOG_DEBUG,
#        "Entity optimised from %f to %f.",
#        unopt->fitness, optimised->fitness);

#   return optimised;
# }
# /**********************************************************************
#   GA functions.
#  **********************************************************************/

#-------------------------------------------------------------------------------
#   synopsis:	Sets the GA parameters for a population.

# void 
# ga_population_set_parameters (population	   *pop,
#                               const ga_scheme_type  scheme,
#                               const ga_elitism_type elitism,
#                               const double	    crossover,
#                               const double	    mutation,
#                               const double	    migration)

#-------------------------------------------------------------------------------
proc ga_population_set_parameters { pop  scheme elitism  \
                                    crossover \
                                    mutation  \
                                    migration} {
  
  if {$::is_print} {
    #puts ""
    puts "ga_population_set_parameters ... "
    puts ""
  }

  #   if ( !pop ) die("Null pointer to population structure passed.");
  
  #   plog( LOG_VERBOSE,
  #        "Population's parameters: scheme = %d elitism = %d crossover = %f mutation = %f migration = %f",
  #        (int) scheme, (int) elitism,
  #        crossover, mutation, migration );
  
  $pop  configure -scheme           $scheme
  $pop  configure -elitism          $elitism
  $pop  configure -crossover_ratio  $crossover
  $pop  configure -mutation_ratio   $mutation
  $pop  configure -migration_ratio  $migration

  return
}
#-------------------------------------------------------------------------------
#   synopsis:	Sets the evolutionary class for a population.
#-------------------------------------------------------------------------------
# void 
# ga_population_set_scheme (population		*pop,
#                           const ga_scheme_type	scheme)
#-------------------------------------------------------------------------------
proc ga_population_set_scheme {pop scheme} \
{

  #   if ( !pop ) die("Null pointer to population structure passed.");
  
  #   plog( LOG_VERBOSE, "Population's evolutionary class = %d", (int) scheme);
  
  $pop configure -scheme $scheme

  return
}
#-------------------------------------------------------------------------------
# /**********************************************************************
#   synopsis:	Sets the elitism mode for a population.
#  **********************************************************************/
# void 
# ga_population_set_elitism (population	    *pop,
#                            ga_elitism_type  elitism)
# {

#   if ( !pop ) die("Null pointer to population structure passed.");

#   plog( LOG_VERBOSE, "Population's elitism mode = %d", (int) elitism);

#   pop->elitism = elitism;

#   return;
# }
# /**********************************************************************
#   synopsis:	Sets the mutation rate for a population.
#  **********************************************************************/
# void 
# ga_population_set_mutation (population *pop,
# 			    double	mutation)
# {

#   if ( !pop ) die("Null pointer to population structure passed.");

#   plog( LOG_VERBOSE, "Population's mutation rate = %f", mutation);

#   pop->mutation_ratio = mutation;

#   return;
# }
# /**********************************************************************
#   synopsis:	Sets the migration rate for a population.
#  **********************************************************************/
# void 
# ga_population_set_migration (population	*pop,
# 			     double	 migration)
# {

#   if ( !pop ) die("Null pointer to population structure passed.");

#   plog( LOG_VERBOSE, "Population's migration rate = %f", migration);

#   pop->migration_ratio = migration;

#   return;
# }
# /**********************************************************************
#   synopsis:	Sets the crossover rate for a population.
#  **********************************************************************/
# void 
# ga_population_set_crossover (population	*pop,
# 			     double	 crossover)
# {

#   if ( !pop ) die("Null pointer to population structure passed.");

#   plog( LOG_VERBOSE, "Population's crossover rate = %f", crossover);

#   pop->crossover_ratio = crossover;

#   return;
# }
# /**********************************************************************
#   synopsis:	Sets the allele mutation rate (e.g. bitwise mutation
# 		probability) for a population.
#  **********************************************************************/
# void 
# ga_population_set_allele_mutation_prob (population *pop,
# 					double	    prob)
# {

#   if ( !pop ) die("Null pointer to population structure passed.");

#   plog( LOG_VERBOSE, "Population's allele mutation probability = %f", prob);

#   pop->allele_mutation_prob = prob;

#   return;
# }
#-------------------------------------------------------------------------------
#   synopsis:	Sets the minimum value for an integer allele for a
# 		population.
#-------------------------------------------------------------------------------
# void 
# ga_population_set_allele_min_integer (population *pop,
# 				      int	  value)
#-------------------------------------------------------------------------------
proc ga_population_set_allele_min_integer {pop value}  {

  #   if (! pop) die("Null pointer to population structure passed.");
  #   plog ( LOG_VERBOSE, "Population's minimum integer allele value = %d", value);
  
  #   pop->allele_min_integer = value;
  $pop configure -allele_min_integer $value

  return
}
#-------------------------------------------------------------------------------
#   synopsis:	Sets the maximum value for an integer allele for a
# 		population.
#-------------------------------------------------------------------------------
proc ga_population_set_allele_max_integer {pop value}  {

  #   if ( !pop ) die("Null pointer to population structure passed.");
  #   plog( LOG_VERBOSE, "Population's maximum integer allele value = %d", value);
  
  #   pop->allele_max_integer = value;
  $pop configure -allele_max_integer $value

  return
}
#-------------------------------------------------------------------------------
# /**********************************************************************
#   synopsis:	Sets the minimum value for a double-precision allele
# 		for a population.
#  **********************************************************************/
# void 
# ga_population_set_allele_min_double (population	*pop,
# 				     double	value)
# {

#   if ( !pop ) die("Null pointer to population structure passed.");

#   plog( LOG_VERBOSE, "Population's minimum double allele value = %f", value);

#   pop->allele_min_double = value;

#   return;
# }
# /**********************************************************************
#   synopsis:	Sets the maximum value for a doubleprecision allele
# 		for a population.
#  **********************************************************************/
# void 
# ga_population_set_allele_max_double (population	*pop,
# 				     double	 value)
# {

#   if ( !pop ) die("Null pointer to population structure passed.");

#   plog( LOG_VERBOSE, "Population's maximum double allele value = %f", value);

#   pop->allele_max_double = value;

#   return;
# }
# /**********************************************************************
#   synopsis:	Return a population structure to user for analysis or
# 		whatever.  But remove it from the population table.
# 		(Like ga_extinction, except doesn't purge memory.)
#   parameters:   unsigned int	population id
#   return:       population *	population pointer (or NULL)
#  **********************************************************************/
# population *
# ga_transcend (unsigned int id)
# {
#   population	*pop=NULL;	/* Transcending population. */

#   plog(LOG_VERBOSE, "This population has achieved transcendance!");

#   THREAD_LOCK (pop_table_lock);
#   if (pop_table)
#   {
#     pop = (population *) table_remove_index(pop_table, id);
#     if (table_count_items(pop_table) < 1)
#     {
#       table_destroy(pop_table);
#       pop_table=NULL;
#     }
#   }
#   THREAD_UNLOCK (pop_table_lock);

#   return pop;
# }
# /**********************************************************************
#   synopsis:	Restores a population structure into the population
# 		table from an external source.
#   parameters:	population *	population pointer
#   return:       unsigned int	population id (or -1)
#  **********************************************************************/
# unsigned int 
# ga_resurect (population *pop)
# {
#   unsigned int	id=TABLE_ERROR_INDEX;	/* Internal population id. */

#   if ( !pop ) die("Null pointer to population structure passed.");

#   plog(LOG_VERBOSE, "The population has been restored!");

#   THREAD_LOCK (pop_table_lock);
#   if (pop_table)
#   {
#     id = table_add(pop_table, pop);
#   }
#   THREAD_UNLOCK (pop_table_lock);

#   return id;
# }
#-------------------------------------------------------------------------------
#   synopsis:	Kill entities to reduce population size down to
# 		specified value.
#-------------------------------------------------------------------------------
# boolean 
# ga_genocide (population *pop, int target_size)
#-------------------------------------------------------------------------------
proc ga_genocide {pop target_size} \
{

  #   if ( !pop ) return FALSE;
  
  #   plog(LOG_VERBOSE,
  #        "The population is being culled from %d to %d individuals!",
  #        pop->size, target_size);
  
  #   /*
  #     * Dereference the structures relating to the least
  #     * fit population members until the desired population size in reached. 
  #     */

  while {[$pop cget -size] > $target_size} \
  {
    #puts stderr "ga_genocide .. target_size = $target_size"

  #     /*printf("Dereferencing entity with rank %d (fitness = %d)\n",
  #       pop->size-1, pop->entity_iarray[pop->size-1]->fitness);*/

    ga_entity_dereference_by_rank  $pop [expr [$pop cget -size] - 1];
  }


  # вообще-то есть такая процедура, надо ли ей воспользоваться?
  # изменение размера популяции до родительской (удалением последних элементов)
  # 
  #method eliminate {} {
  #  
  #  set entity_iarray [lrange $entity_iarray  $options(-orig_size) end]
  #
  #  $self configure -size  [expr $options(-size) - $options(-orig_size)]
  #  $self configure -orig_size 0
  #}

  return true
}
#-------------------------------------------------------------------------------

#   synopsis:	Kill entities with fitness equal to or worse than
# 		specified value.

#-------------------------------------------------------------------------------
# boolean 
# ga_genocide_by_fitness (population *pop, double target_fitness)

#-------------------------------------------------------------------------------
proc ga_genocide_by_fitness {pop target_fitness}  {

  #   if (! pop) return FALSE;
  
  #   plog (LOG_VERBOSE,
  #        "The population of size %d is being culled at fitness %f!",
  #        pop->size, target_fitness);
  
  #   /*
  #     * Dereference the structures relating to the least
  #     * fit population members until the desired population size in reached. 
  #     */

  #   while ( pop->size > 0 &&
  #          pop->entity_iarray[pop->size-1]->fitness < target_fitness )

  #while {[expr $flag1 && $flag2]} {}
  
  while {1} {
  
    set size   [$pop cget -size]
    set size_1 [expr $size - 1]
    #set fitn_1 [$pop get_entity_fitness $size_1]
    set fitn_1 [pop_get_entity_fitness_ $pop  $size_1]
    
    set flag1 [expr $size   > 0]
    set flag2 [expr $fitn_1 < $target_fitness] 

    if {! [expr $flag1 && $flag2]} {break}

    #     /*printf("Dereferencing entity with rank %d (fitness = %d)\n",
    #       pop->size-1, pop->entity_iarray[pop->size-1]->fitness);*/
  
    #     ga_entity_dereference_by_rank (pop, pop->size-1);
    ga_entity_dereference_by_rank  $pop [expr [$pop cget -size] - 1];
     
    #puts "ga_genocide_by_fitness : !!!!!!!!!!!!!!!!!!!!"
    ##exit
  }
  
  return true
}
#-------------------------------------------------------------------------------
# /**********************************************************************
#   synopsis:	Purge all memory used by a population, also remove
# 		it from the population table.
#  **********************************************************************/
#-------------------------------------------------------------------------------
# boolean 
# ga_extinction (population *extinct)
# {
#   unsigned int	id = TABLE_ERROR_INDEX;	/* Internal index for this extinct population. */

#   if ( !extinct ) die("Null pointer to population structure passed.");

#   plog(LOG_VERBOSE, "This population is becoming extinct!");

#   /*
#     * Remove this population from the population table.
#     */
#   THREAD_LOCK(pop_table_lock);
#   if (pop_table)
#   {
#     id = table_remove_data(pop_table, extinct);
#     if (table_count_items(pop_table) < 1)
#     {
#       table_destroy(pop_table);
#       pop_table=NULL;
#     }
#   }
#   THREAD_UNLOCK(pop_table_lock);

#   /*
#     * Error check.
#     */
#   if (id == TABLE_ERROR_INDEX)
#     die("Unable to find population structure in table.");

#   /*
#     * Dereference/free everyting.
#     */
#   if (!ga_genocide(extinct, 0))
#   {
#     plog(LOG_NORMAL, "This population is already extinct!");
#   }
#   else
#   {
#     s_free(extinct->entity_array);
#     s_free(extinct->entity_iarray);
#     mem_chunk_destroy(extinct->entity_chunk);

# #ifdef USE_CHROMO_CHUNKS
#     mem_chunk_destroy(extinct->chromo_chunk);
#     mem_chunk_destroy(extinct->chromoarray_chunk);
# #endif

#     if (extinct->tabu_params) s_free(extinct->tabu_params);
#     if (extinct->sa_params) s_free(extinct->sa_params);
#     if (extinct->dc_params) s_free(extinct->dc_params);
#     if (extinct->climbing_params) s_free(extinct->climbing_params);
#     if (extinct->simplex_params) s_free(extinct->simplex_params);
#     if (extinct->gradient_params) s_free(extinct->gradient_params);
#     if (extinct->search_params) s_free(extinct->search_params);
#     if (extinct->de_params) s_free(extinct->de_params);
#     if (extinct->sampling_params) s_free(extinct->sampling_params);

#     if (extinct->data)
#     {
#       if (extinct->population_data_destructor)
#       {
#         extinct->population_data_destructor(extinct->data);
#       }
#       else
#       {
#         plog(LOG_WARNING, "User data field is not empty. (Potential memory leak)");
#       }
#     }

#     THREAD_LOCK_FREE(extinct->lock);
# #ifdef USE_CHROMO_CHUNKS
#     THREAD_LOCK_FREE(extinct->chromo_chunk_lock);
# #endif

#     s_free(extinct);
#   }

#   return TRUE;
# }
#-------------------------------------------------------------------------------
# /**********************************************************************
#   synopsis:	Gets an entity's fitness.
#  **********************************************************************/
# double 
# ga_entity_get_fitness (entity *e)
# {

#   return e ? e->fitness : GA_MIN_FITNESS;
# }
# ------------------------------------------------------------------------------
#   synopsis:	Gets an entity's fitness.
#
# boolean 
# ga_entity_set_fitness (entity *e, double fitness)
# ------------------------------------------------------------------------------
proc ga_entity_set_fitness {e fitness} {

  #   if ( !e ) return FALSE;

  #   e->fitness=fitness;
  $e configure -fitness $fitness

  return true;
}
# ------------------------------------------------------------------------------
# /**********************************************************************
#   synopsis:	Gets a population's stable size.
#  **********************************************************************/
# int 
# ga_population_get_stablesize (population *pop)
# {

#   return pop?pop->stable_size:0;
# }
# /**********************************************************************
#   synopsis:	Gets a population's current size.
#  **********************************************************************/
# int 
# ga_population_get_size (population *pop)
# {

#   return pop?pop->size:0;
# }
# /**********************************************************************
#   synopsis:	Gets a population's maximum size. (I don't know why
# 		anyone would need this function, but it is here for
# 		completeness.)
#  **********************************************************************/
# int 
# ga_population_get_maxsize (population *pop)
# {

#   return pop?pop->max_size:0;
# }
# /**********************************************************************
#   synopsis:	Gets a population's stable size.
#  **********************************************************************/
# boolean 
# ga_population_set_stablesize (population *pop, int stable_size)
# {
#   if ( !pop ) return FALSE;

#   pop->stable_size = stable_size;

#   return TRUE;
# }
# /**********************************************************************
#   synopsis:	Sets the population's user data.
#  **********************************************************************/
# boolean 
# ga_population_set_data (population *pop, vpointer data)
# {
#   if ( !pop ) return FALSE;

#   pop->data = data;

#   return TRUE;
# }
# /**********************************************************************
#   synopsis:	Sets the population's user data, along with appropriate
# 		user-defined deallocation and copy callback functions.
#  **********************************************************************/
# boolean 
# ga_population_set_data_managed (population *pop,
#                                 vpointer data,
#                                 GAdata_destructor population_data_destructor,
#                                 GAdata_copy population_data_copy)
# {
#   if (!pop) return FALSE;

#   pop->data = data;
#   pop->population_data_destructor = population_data_destructor;
#   pop->population_data_copy = population_data_copy;

#   return TRUE;
# }
# /**********************************************************************
#   Gets the population's user data.
#  **********************************************************************/
# vpointer 
# ga_population_get_data (population *pop)
# {
#   if ( !pop ) return NULL;

#   return pop->data;
# }
# /**********************************************************************
#   Sets the entity's user data.
#  **********************************************************************/
# boolean 
# ga_entity_set_data (population *pop, entity *e, SLList *data)
# {
#   SLList	*present;		/* Current list element. */

#   if ( !pop ) return FALSE;
#   if ( !e ) return FALSE;

#   if (e->data)
#   {
#     if (pop->data_destructor)
#     {
#       present = data;
#       while (present!=NULL)
#       {
#         pop->data_destructor(slink_data(present));
#         present = slink_next(present);
#       }
#     }
#     slink_free_all(e->data);
#   }

#   e->data = data;

#   return TRUE;
# }
# /**********************************************************************
#   synopsis:	Gets the entity's user data.
#  **********************************************************************/
# SLList *
# ga_entity_get_data (population *pop, entity *e)
# {

#   if ( !pop ) return NULL;
#   if ( !e ) return NULL;

#   return e->data;
# }
# /**********************************************************************
#   synopsis:	Gets the current generation number.  Intended for use
# 		within fitness evaluation callbacks only.
#  **********************************************************************/
# int 
# ga_population_get_generation (population *pop)
# {

#   if ( !pop ) return 0;

#   return pop->generation;
# }
# /**********************************************************************
#   synopsis:	Gets the current island number.  Intended for use
# 		within fitness evaluation callbacks only.
#  **********************************************************************/
# int 
# ga_population_get_island (population *pop)
# {

#   if ( !pop ) return 0;

#   return pop->island;
# }
# /**********************************************************************
#   synopsis:	Get number of dimensions in fitness vector, for
# 		multiobjective optimisation.
#  **********************************************************************/
# int 
# ga_population_get_fitness_dimensions (population *pop)
# {

#   if ( !pop ) die("Null pointer to population structure passed.");

#   return pop->fitness_dimensions;
# }
# /**********************************************************************
#   synopsis:	Set number of dimensions in fitness vector, for
# 		multiobjective optimisation.
#  **********************************************************************/
# boolean 
# ga_population_set_fitness_dimensions (population *pop, int num)
# {
#   if ( !pop ) return FALSE;

#   pop->fitness_dimensions = num;

#   return TRUE;
# }
# /**********************************************************************
#   synopsis:	Gets the crossover rate of a population.
#  **********************************************************************/
# double 
# ga_population_get_crossover (population	*pop)
# {

#   if ( !pop ) die("Null pointer to population structure passed.");

#   return pop->crossover_ratio;
# }
# /**********************************************************************
#   synopsis:	Gets the allele mutation rate of a population.
#  **********************************************************************/
# double 
# ga_population_get_allele_mutation_prob (population *pop)
# {

#   if ( !pop ) die("Null pointer to population structure passed.");

#   return pop->allele_mutation_prob;
# }
# /**********************************************************************
#   synopsis:	Gets the minimum integer allele value for a population.
#  **********************************************************************/
# int 
# ga_population_get_allele_min_integer (population *pop)
# {

#   if ( !pop ) die("Null pointer to population structure passed.");

#   return pop->allele_min_integer;
# }
# /**********************************************************************
#   synopsis:	Gets the maximum integer allele value for a population.
#  **********************************************************************/
# int 
# ga_population_get_allele_max_integer (population *pop)
# {

#   if ( !pop ) die("Null pointer to population structure passed.");

#   return pop->allele_max_integer;
# }
# /**********************************************************************
#   synopsis:	Gets the minimum double-precision allele value for a
# 		population.
#  **********************************************************************/
# double 
# ga_population_get_allele_min_double (population	*pop)
# {

#   if ( !pop ) die("Null pointer to population structure passed.");

#   return pop->allele_min_double;
# }
# /**********************************************************************
#   synopsis:	Gets the maximum double-precision allele value for a
# 		population.
#  **********************************************************************/
# double 
# ga_population_get_allele_max_double (population	*pop)
# {

#   if ( !pop ) die("Null pointer to population structure passed.");

#   return pop->allele_max_double;
# }
# /**********************************************************************
#   synopsis:	Gets the mutation rate of a population.
#  **********************************************************************/
# double 
# ga_population_get_mutation (population *pop)
# {

#   if ( !pop ) die("Null pointer to population structure passed.");

#   return pop->mutation_ratio;
# }
# /**********************************************************************
#   synopsis:	Gets the migration rate of a population.
#  **********************************************************************/
# double 
# ga_population_get_migration (population	*pop)
# {

#   if ( !pop ) die("Null pointer to population structure passed.");

#   return pop->migration_ratio;
# }
# /**********************************************************************
#   synopsis:	Gets the evolutionary scheme of a population.
#  **********************************************************************/
# ga_scheme_type 
# ga_population_get_scheme (population *pop)
# {

#   if ( !pop ) die("Null pointer to population structure passed.");

#   return pop->scheme;
# }
# /**********************************************************************
#   synopsis:	Gets the elitism mode of a population.
#  **********************************************************************/
# ga_elitism_type 
# ga_population_get_elitism (population *pop)
# {

#   if ( !pop ) die("Null pointer to population structure passed.");

#   return pop->elitism;
# }
# /**********************************************************************
#   synopsis:	Initialises OpenMP code.
# 		This function must be called in OpenMP enabled code,
# 		but the ga_genesis_XXX() functions do this.
#  **********************************************************************/
# void 
# ga_init_openmp ( void )
# {

#   /* #ifdef USE_OPENMP */
#   /* #pragma omp single */
#   /*     { */
#   /*     if (gaul_openmp_initialised == FALSE) */
#   /*       { */
#   /*       avltree_init_openmp(); */
#   /*       linkedlist_init_openmp(); */
#   /*       memory_init_openmp(); */
#   /*       mem_chunk_init_openmp(); */
#   /*       random_seed(0); */

#   /*       omp_init_lock(&pop_table_lock); */
#   /*       gaul_openmp_initialised = TRUE; */
#   /*       } */
#   /*     } */
#   /* #endif */

#   return;
# }
# /**********************************************************************
#   ga_rank.c
#  **********************************************************************

#   ga_rank - Entity comparison routines.
#   Copyright б╘2005, Stewart Adcock <stewart@linux-domain.com>
#   All rights reserved.

#    Synopsis:     Routines for comparing entities.

# 		These routines return -1, 0, or 1 depending upon
# 		how the entities should ranked.
# 		(optionally) 0 if ranking is equal or indeterminant.
# 		1 if alpha entity ranks higher.
# 		-1 if beta entity ranks higher.

#  **********************************************************************/

# //#include "ga_core.h"
# //#include "gaul.h"

#-------------------------------------------------------------------------------
#   synopsis:	Compares two entities and returns their relative
# 		ranking.
#   parameters:	population *alphapop	Population A
# 		entity *alpha		Test entity A.
# 		population *betapop 	Population B
# 		entity *beta		Test entity B.
#   return:	Relative rank.
#-------------------------------------------------------------------------------
# int 
# ga_rank_fitness (population *alphapop, entity *alpha,
#                  population *betapop, entity *beta)
#-------------------------------------------------------------------------------
proc ga_rank_fitness {alphapop alpha betapop beta} {

  #   /* Checks */
  #   if (!alphapop || !betapop) die("Null pointer to population structure passed");
  #   if (!alpha || !beta) die("Null pointer to entity structure passed");
  
  #   return (alpha->fitness - beta->fitness) > 0.0;
  return [expr ([$alpha.fitness] - [$beta.fitness]) > 0.0]
}
#-------------------------------------------------------------------------------
# /**********************************************************************
#   ga_replace.c
#  **********************************************************************

#   ga_replace - Genetic algorithm replacement operators.
#   Copyright б╘2000-2006, Stewart Adcock <stewart@linux-domain.com>
#   All rights reserved.

#   Synopsis:     Routines for performing GA replacement operations.

# 		These functions should duplicate user data where
# 		appropriate.

#   To do:	Replace parents if less fit.
# 		Replace most similar entities.
# 		Replace 'oldest' entities.

#  **********************************************************************/

# //#include "ga_core.h"
# //#include "gaul.h"

# /**********************************************************************
#   synopsis:	Replace by fitness.  (i.e. New entity gets inserted
# 		into population, according to fitness, and least fit
# 		entity dies.)
#  **********************************************************************/
# void 
# ga_replace_by_fitness (population *pop, entity *child)
# {
#   int		i, j;		/* Loop over entities. */
#   entity	*tmp;		/* For swapping. */

#   /* Find child's current rank, which will be somewhere near the bottom. */
#   i=pop->size;
#   do
#   {
#     i--;
#   } while (i>=pop->orig_size && !(child == pop->entity_iarray[i]));

#   if (i<pop->orig_size) die("Dodgy replacement requested.");

#   if (child->fitness >= pop->entity_iarray[pop->orig_size-1]->fitness)
#   {
#     tmp = pop->entity_iarray[pop->orig_size-1];
#     pop->entity_iarray[pop->orig_size-1] = pop->entity_iarray[i];
#     pop->entity_iarray[i] = tmp;

#     /* Shuffle entity to rightful location. */
#     j = pop->orig_size-1;
#     while (j>0 && pop->entity_iarray[j]->fitness > pop->entity_iarray[j-1]->fitness)
#     {
#       tmp = pop->entity_iarray[j];
#       pop->entity_iarray[j] = pop->entity_iarray[j-1];
#       pop->entity_iarray[j-1] = tmp;
#       j--;
#     }

#     /* Rank of replaced entity. */
#     i = pop->orig_size-1;
#   }

#   /* Kill off child/replaced entity. */
#   ga_entity_dereference_by_rank(pop, i);

#   return;
# }
# //******************************************************************************
# /**********************************************************************
#   ga_stats.c
#  **********************************************************************

#   ga_stats - Statistics routines.
#   Copyright б╘2000-2006, Stewart Adcock <stewart@linux-domain.com>
#   All rights reserved.

#   Synopsis:     Convenience statistics functions.

#   To do:	On-line and off-line performance summaries.

#  **********************************************************************/

#   //#include "gaul.h"  // это я убрал, поскольку нe понял зачeм это..
# //#include "ga_core.h"		/* Private aspects of GAUL. */

# /**********************************************************************
#   synopsis:     Determine mean of the fitness scores.
#   parameters:	population *pop		The population to evaluate.
#   		double *mean		Returns the mean fitness.
#   return:	TRUE on success.
#  **********************************************************************/
# boolean 
# ga_fitness_mean (population *pop, double *mean)
# {
#   int           i;           /* Loop over all entities. */
#   double        sum=0.0;     /* Sum of fitnesses. */

#   if (!pop) die("Null pointer to population structure passed.");
#   if (pop->size < 1) die("Pointer to empty population structure passed.");
#   if (!mean) die("Null pointer to double passed.");

#   for (i=0; i<pop->size; i++)
#   {
#     sum += pop->entity_iarray[i]->fitness;
#   }

#   *mean = sum / pop->size;

#   return TRUE;
# }
#-------------------------------------------------------------------------------
#   synopsis:     Determine mean and standard deviation of the fitness
#                 scores.
#   parameters:	population *pop		The population to evaluate.
#   		double *mean		Returns the mean fitness.
# 		double *stddev		Returns the standard deviation of the fitnesses.
#   return:	TRUE on success.
#-------------------------------------------------------------------------------
# boolean 
# ga_fitness_mean_stddev (population *pop,
#                         double *mean, double *stddev)
#-------------------------------------------------------------------------------
proc ga_fitness_mean_stddev {pop &p_mean &p_stddev} \
{

  USE_REFS

  #   int           i;                      /* Loop over all entities. */
  #   double        sum=0.0, sumsq=0.0;     /* Sum and sum squared. */
  #   double	deviation;		/* Distance to mean. */
  
  set sum   0.0
  set sumsq 0.0

  #   if (!pop) die("Null pointer to population structure passed.");
  #   if (pop->size < 1) die("Pointer to empty population structure passed.");
  #   if (!stddev || !mean) die("Null pointer to double passed.");
  
  set size [$pop cget -size]

  for {set i 0} {$i < $size} {incr i} \
  {
    #sum += pop->entity_iarray[i]->fitness;

    #set fi  [$pop get_entity_fitness $i]
    set fi  [pop_get_entity_fitness_ $pop  $i]
    set sum [expr $sum + $fi]
  }
  
  #   *mean = sum / pop->size;
  set mean [expr $sum / $size]
  
  for {set i 0} {$i < $size} {incr i} \
  {
    #     deviation = pop->entity_iarray[i]->fitness - *mean;
    #     sumsq += deviation * deviation;
    
    #set fi  [$pop get_entity_fitness $i]
    set fi  [pop_get_entity_fitness_ $pop  $i]
    set deviation  [expr $fi - $mean]

    set sumsq [expr $sumsq + ($deviation * $deviation)]
  }
  
  #   *stddev = sqrt (sumsq/pop->size);

  set p_mean   $mean
  set p_stddev [expr sqrt ($sumsq / $size)]

  return true
}
#-------------------------------------------------------------------------------
# /**********************************************************************
#   synopsis:     Determine some stats about the fitness scores.
#   parameters:	population *pop		The population to evaluate.
#   		double *mean		Returns the average fitness.
#   		double *median		Returns the median fitness.
# 		double *variance	Returns the variance of the fitnesses.
# 		double *stddev		Returns the standard deviation of the fitnesses.
# 		double *kurtosis	Returns the kurtosis of the fitnesses.
# 		double *skew		Returns the skew of the fitnesses.
#   return:	TRUE on success.
#  **********************************************************************/
# boolean 
# ga_fitness_stats (population *pop,
#                   double *maximum, double *minimum,
#                   double *mean, double *median,
#                   double *variance, double *stddev,
#                   double *kurtosis, double *skew)
# {
#   int           i;                      /* Loop over all entities. */
#   double	sum2=0.0,sum3=0.0,sum4=0.0;	/* Distribution moments (x pop->size). */
#   double	tmp=0.0;		/* Used to save some lookups. */

#   if (!pop) die("Null pointer to population structure passed.");
#   if (pop->size < 1) die("Pointer to empty population structure passed.");
#   if (!maximum || !minimum || !mean || !variance || !stddev || !kurtosis || !skew)
#     die("Null pointer to double passed.");

#   *minimum = pop->entity_iarray[0]->fitness;
#   *maximum = pop->entity_iarray[pop->size-1]->fitness;
#   *median = *minimum + (*maximum - *minimum)/2;

#   for (i=0; i<pop->size; i++)
#   {
#     tmp += pop->entity_iarray[i]->fitness;
#   }

#   *mean = tmp / pop->size;

#   for (i=0; i<pop->size; i++)
#   {
#     tmp = pop->entity_iarray[i]->fitness - *mean;
#     sum2 += tmp*tmp;
#     sum3 += tmp*tmp*tmp;	/* I hope my compiler optimises this... */
#     sum4 += tmp*tmp*tmp*tmp;
#   }

#   *variance = sum2/pop->size;
#   *skew = (sum3/pop->size)/pow(*variance,3.0/2.0);
#   *kurtosis = (sum4/pop->size)/(*variance * *variance);
#   *stddev = sqrt(*variance);

#   return TRUE;
# }
# //******************************************************************************
# //******************************************************************************


