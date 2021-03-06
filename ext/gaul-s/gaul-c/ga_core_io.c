/**********************************************************************
  ga_io.c
 **********************************************************************

  ga_io - Disk I/O routines.
  Copyright ©2003-2006, Stewart Adcock <stewart@linux-domain.com>
  All rights reserved.

  Synopsis:     Routines for reading/writing GA data from/onto disk.

  To do:	Fix the really inefficient entity format (i.e. remove len).
		Remove excessive use of malloc()/free() in posix versions.
		Support for longer chromosomes in win32 versions.
		It is fair to say that the file formats are embarrasingly poor.
		Alternative optimisation function parameters not saved.

 **********************************************************************/

//#include "ga_core.h"
#include "gaul.h"

#define BUFFER_SIZE	1024

/**********************************************************************
  synopsis:	Writes an entity to a filepointer using a binary format.
		Note: Currently does not (and probably can not) store
		any of the userdata.
 **********************************************************************/
void 
gaul_write_entity_posix (FILE *fp, population *pop, entity *this_entity)
{
  gaulbyte		*buffer=NULL;		/* Buffer for genetic data. */
  unsigned int	len, max_len=0;		/* Length of buffer. */

  fwrite(&(this_entity->fitness), sizeof(double), 1, fp);
  len = (int) pop->chromosome_to_bytes(pop, this_entity, &buffer, &max_len);
  fwrite(&len, sizeof(unsigned int), 1, fp);
  fwrite(buffer, sizeof(gaulbyte), len, fp);

  if (max_len!=0)
    s_free(buffer);

  return;
}
/**********************************************************************
  synopsis:	Reads an entity from a filepointer using a binary
		format.
  parameters:	FILE *fp	File handle from which to read entity.
		population *pop	Population to add new entity to.
  return:	entity*	An entity as read from disk.
 **********************************************************************/
entity *
gaul_read_entity_posix (FILE *fp, population *pop)
{
  gaulbyte		*buffer=NULL;	/* Buffer for genetic data. */
  unsigned int	len;		/* Length of buffer. */
  entity	*this_entity;	/* New entity read from disk. */

  this_entity = ga_get_free_entity(pop);

  fread(&(this_entity->fitness), sizeof(double), 1, fp);
  fread(&len, sizeof(unsigned int), 1, fp);

  if ( !(buffer = s_malloc(sizeof(gaulbyte)*len)) )
    die("Unable to allocate memory");

  fread(buffer, sizeof(gaulbyte), len, fp);
  pop->chromosome_from_bytes(pop, this_entity, buffer);

  s_free(buffer);

  return this_entity;
}
/**********************************************************************
  synopsis:	Reads an entity from a filepointer using a binary
		format.
  parameters:	FILE *fp	File handle from which to read entity.
		population *pop	Population to add new entity to.
  return:	entity*	An entity as read from disk.
 **********************************************************************/

enum GA_POPULATION_HOOK_OFFSET
  {
    GA_POPULATION_HOOK_OFFSET_GENERATION_HOOK,
    GA_POPULATION_HOOK_OFFSET_ITERATION_HOOK,
    GA_POPULATION_HOOK_OFFSET_DATA_DESTRUCTOR,
    GA_POPULATION_HOOK_OFFSET_DATA_REF_INCREMENTOR,
    GA_POPULATION_HOOK_OFFSET_POPULATION_DATA_DESTRUCTOR,
    GA_POPULATION_HOOK_OFFSET_POPULATION_DATA_COPY,
    GA_POPULATION_HOOK_OFFSET_CHROMOSOME_CONSTRUCTOR,
    GA_POPULATION_HOOK_OFFSET_CHROMOSOME_DESTRUCTOR,
    GA_POPULATION_HOOK_OFFSET_CHROMOSOME_REPLICATE,
    GA_POPULATION_HOOK_OFFSET_CHROMOSOME_TO_BYTES,
    GA_POPULATION_HOOK_OFFSET_CHROMOSOME_FROM_BYTES,
    GA_POPULATION_HOOK_OFFSET_CHROMOSOME_TO_STRING,
    GA_POPULATION_HOOK_OFFSET_EVALUATE,
    GA_POPULATION_HOOK_OFFSET_SEED,
    GA_POPULATION_HOOK_OFFSET_ADAPT,
    GA_POPULATION_HOOK_OFFSET_SELECT_ONE,
    GA_POPULATION_HOOK_OFFSET_SELECT_TWO,
    GA_POPULATION_HOOK_OFFSET_MUTATE,
    GA_POPULATION_HOOK_OFFSET_CROSSOVER,
    GA_POPULATION_HOOK_OFFSET_REPLACE,
    GA_POPULATION_HOOK_OFFSET_RANK,

    GA_POPULATION_HOOK_COUNT
  };

/**********************************************************************
  synopsis:	Writes entire population and it's genetic data to disk,
		using a binary format.
		Note: Currently does not (and probably can not) store
		any of the userdata.
 **********************************************************************/
boolean 
ga_population_write (population *pop, char *fname)
  {
  FILE          *fp;				/* File handle. */
  int		i;				/* Loop variables. */
  char		buffer[BUFFER_SIZE];		/* String buffer. */
  int		id[GA_POPULATION_HOOK_COUNT];	/* Array of hook indices. */
  int		count=0;			/* Number of unrecognised hook functions. */
  char		*format_str="FORMAT: GAUL POPULATION 004";	/* Format tag. */

/* Checks. */
  if ( !pop ) die("Null pointer to population structure passed.");
  if ( !fname ) die("Null pointer to filename passed.");

/*
 * Open output file.
 */
  if( !(fp=fopen(fname,"w")) )
    dief("Unable to open population file \"%s\" for output.", fname);

/*
 * Program info.
 */
  fwrite(format_str, sizeof(char), strlen(format_str), fp);
  for (i=0; i<64; i++) buffer[i]='\0';
  snprintf(buffer, 64, "%s %s", GA_VERSION_STRING, GA_BUILD_DATE_STRING);
  fwrite(buffer, sizeof(char), 64, fp);

/*
 * Population info.
 */
  fwrite(&(pop->size), sizeof(int), 1, fp);
  fwrite(&(pop->stable_size), sizeof(int), 1, fp);
  //fwrite(&(pop->num_chromosomes), sizeof(int), 1, fp);
  fwrite(&(pop->len_chromosomes), sizeof(int), 1, fp);

/*
 * GA parameters.
 */
  fwrite(&(pop->crossover_ratio), sizeof(double), 1, fp);
  fwrite(&(pop->mutation_ratio), sizeof(double), 1, fp);
  fwrite(&(pop->migration_ratio), sizeof(double), 1, fp);
  fwrite(&(pop->allele_mutation_prob), sizeof(double), 1, fp);
  fwrite(&(pop->allele_min_integer), sizeof(int), 1, fp);
  fwrite(&(pop->allele_max_integer), sizeof(int), 1, fp);
  fwrite(&(pop->allele_min_double), sizeof(double), 1, fp);
  fwrite(&(pop->allele_max_double), sizeof(double), 1, fp);
  fwrite(&(pop->scheme), sizeof(int), 1, fp);
  fwrite(&(pop->elitism), sizeof(int), 1, fp);

  fwrite(&(pop->island), sizeof(int), 1, fp);

/*
 * Callback handling.  Note that user-implemented functions currently
 * can't be handled in these files.
 * id = -1 - Unknown, external function.
 * id = 0  - NULL function.
 * id > 0  - GAUL defined function.
 */
  id[GA_POPULATION_HOOK_OFFSET_GENERATION_HOOK] = ga_funclookup_ptr_to_id((void *)pop->generation_hook);
  id[GA_POPULATION_HOOK_OFFSET_ITERATION_HOOK]  = ga_funclookup_ptr_to_id((void *)pop->iteration_hook);

  /* GAUL doesn't define any functions for any of these four callbacks: */
  id[GA_POPULATION_HOOK_OFFSET_DATA_DESTRUCTOR]             = pop->data_destructor ? -1 : 0;
  id[GA_POPULATION_HOOK_OFFSET_DATA_REF_INCREMENTOR]        = pop->data_ref_incrementor ? -1 : 0;
  id[GA_POPULATION_HOOK_OFFSET_POPULATION_DATA_DESTRUCTOR]  = pop->population_data_destructor ? -1 : 0;
  id[GA_POPULATION_HOOK_OFFSET_POPULATION_DATA_COPY]        = pop->population_data_copy ? -1 : 0;

  id[GA_POPULATION_HOOK_OFFSET_CHROMOSOME_CONSTRUCTOR]  = 
    ga_funclookup_ptr_to_id ((void *)pop->chromosome_constructor);

  id[GA_POPULATION_HOOK_OFFSET_CHROMOSOME_DESTRUCTOR]   = 
    ga_funclookup_ptr_to_id ((void *)pop->chromosome_destructor);

  id[GA_POPULATION_HOOK_OFFSET_CHROMOSOME_REPLICATE]    = 
    ga_funclookup_ptr_to_id ((void *)pop->chromosome_replicate);

  id[GA_POPULATION_HOOK_OFFSET_CHROMOSOME_TO_BYTES]     = 
    ga_funclookup_ptr_to_id ((void *)pop->chromosome_to_bytes);

  id[GA_POPULATION_HOOK_OFFSET_CHROMOSOME_FROM_BYTES]   = 
    ga_funclookup_ptr_to_id ((void *)pop->chromosome_from_bytes);

  id[GA_POPULATION_HOOK_OFFSET_CHROMOSOME_TO_STRING]    = 
    ga_funclookup_ptr_to_id ((void *)pop->chromosome_to_string);

  id[GA_POPULATION_HOOK_OFFSET_EVALUATE]    = ga_funclookup_ptr_to_id((void *)pop->evaluate);
  id[GA_POPULATION_HOOK_OFFSET_SEED]        = ga_funclookup_ptr_to_id((void *)pop->seed);
  id[GA_POPULATION_HOOK_OFFSET_ADAPT]       = ga_funclookup_ptr_to_id((void *)pop->adapt);
  id[GA_POPULATION_HOOK_OFFSET_SELECT_ONE]  = ga_funclookup_ptr_to_id((void *)pop->select_one);
  id[GA_POPULATION_HOOK_OFFSET_SELECT_TWO]  = ga_funclookup_ptr_to_id((void *)pop->select_two);
  id[GA_POPULATION_HOOK_OFFSET_MUTATE]      = ga_funclookup_ptr_to_id((void *)pop->mutate);
  id[GA_POPULATION_HOOK_OFFSET_CROSSOVER]   = ga_funclookup_ptr_to_id((void *)pop->crossover);
  id[GA_POPULATION_HOOK_OFFSET_REPLACE]     = ga_funclookup_ptr_to_id((void *)pop->replace);
  id[GA_POPULATION_HOOK_OFFSET_RANK]        = ga_funclookup_ptr_to_id((void *)pop->rank);

  fwrite(id, sizeof(int), GA_POPULATION_HOOK_COUNT, fp);

/*
 * Warn user of any unhandled data.
 */
  for (i=0; i < GA_POPULATION_HOOK_COUNT; i++)
    if (id[i] == -1) count++;

  if (count>0)
    plog(LOG_NORMAL, "Unable to handle %d hook function%sspecified in population structure.", 
         count, count==1?" ":"s ");

/*
 * Entity info.
 */
  for (i=0; i<pop->size; i++)
    {
    gaul_write_entity_posix(fp, pop, pop->entity_iarray[i]);
    }

/*
 * Footer info.
 */
  fwrite("END", sizeof(char), 4, fp); 

/*
 * Close file.
 */
  fclose(fp);

  return TRUE;
}
/**********************************************************************
  synopsis:	Reads entire population and it's genetic data back
		from disk.   Some things can't be restored.  See
		ga_population_write() for details.
  parameters:	char *fname		Filename to read from.
  return:	population *pop		New population structure.
 **********************************************************************/
population *
ga_population_read (char *fname)
{
  population	*pop=NULL;			/* New population structure. */
  FILE          *fp;				/* File handle. */
  int		i;				/* Loop variables. */
  char		buffer[BUFFER_SIZE];		/* String buffer. */
  int		id[GA_POPULATION_HOOK_COUNT];			/* Array of hook indices. */
  int		count=0;			/* Number of unrecognised hook functions. */
  char		*format_str="FORMAT: GAUL POPULATION 004";	/* Format tag. */
  char		format_str_in[32]="";           // Input format tag. (Empty initialiser 
                                                // to avoid valgrind warning...) 
  int		size, stable_size, /* num_chromosomes, */ len_chromosomes;	/* Input data. */

  /* Checks. */
  if ( !fname ) die("Null pointer to filename passed.");

  /*
    * Open output file.
    */
  if( !(fp=fopen(fname,"r")) )
    dief("Unable to open population file \"%s\" for input.", fname);

  /*
    * Program info.
    */
  fread(format_str_in, sizeof(char), strlen(format_str), fp);
  if (strcmp(format_str, format_str_in)!=0)
  {
    fclose(fp);
    die("Invalid file format");
  }

  fread(buffer, sizeof(char), 64, fp);	/* Presently ignored. */

  /*
    * Population info.
    */
  fread(&size, sizeof(int), 1, fp);
  fread(&stable_size, sizeof(int), 1, fp);
  //fread(&num_chromosomes, sizeof(int), 1, fp);
  fread(&len_chromosomes, sizeof(int), 1, fp);

  /*
    * Allocate a new population structure.
    */
  pop = ga_population_new (stable_size/* , 1 *//* num_chromosomes */, len_chromosomes);

  /*
    * Got a population structure?
    */
  if ( !pop ) die("Unable to allocate population structure.");

  /*
    * GA parameters.
    */
  fread(&(pop->crossover_ratio), sizeof(double), 1, fp);
  fread(&(pop->mutation_ratio), sizeof(double), 1, fp);
  fread(&(pop->migration_ratio), sizeof(double), 1, fp);
  fread(&(pop->allele_mutation_prob), sizeof(double), 1, fp);
  fread(&(pop->allele_min_integer), sizeof(int), 1, fp);
  fread(&(pop->allele_max_integer), sizeof(int), 1, fp);
  fread(&(pop->allele_min_double), sizeof(double), 1, fp);
  fread(&(pop->allele_max_double), sizeof(double), 1, fp);
  fread(&(pop->scheme), sizeof(int), 1, fp);
  fread(&(pop->elitism), sizeof(int), 1, fp);
  fread(&(pop->island), sizeof(int), 1, fp);

  /*
    * Callback handling.  Note that user-implemented functions currently
    * can't be handled in these files.
    * id = -1 - Unknown, external function.
    * id = 0  - NULL function.
    * id > 0  - GAUL defined function.
    */
  fread(id, sizeof(int), GA_POPULATION_HOOK_COUNT, fp);

  pop->generation_hook        = (GAgeneration_hook)  
    ga_funclookup_id_to_ptr(id[GA_POPULATION_HOOK_OFFSET_GENERATION_HOOK]);
  pop->iteration_hook         = (GAiteration_hook)   
    ga_funclookup_id_to_ptr(id[GA_POPULATION_HOOK_OFFSET_ITERATION_HOOK]);

  pop->data_destructor        = (GAdata_destructor)      
    ga_funclookup_id_to_ptr(id[GA_POPULATION_HOOK_OFFSET_DATA_DESTRUCTOR]);
  pop->data_ref_incrementor   = (GAdata_ref_incrementor) 
    ga_funclookup_id_to_ptr(id[GA_POPULATION_HOOK_OFFSET_DATA_REF_INCREMENTOR]);

  pop->population_data_destructor = (GAdata_destructor) 
    ga_funclookup_id_to_ptr(id[GA_POPULATION_HOOK_OFFSET_POPULATION_DATA_DESTRUCTOR]);
  pop->population_data_copy   = (GAdata_copy)           
    ga_funclookup_id_to_ptr(id[GA_POPULATION_HOOK_OFFSET_POPULATION_DATA_COPY]);

  pop->chromosome_constructor = (GAchromosome_constructor) 
    ga_funclookup_id_to_ptr(id[GA_POPULATION_HOOK_OFFSET_CHROMOSOME_CONSTRUCTOR]);
  pop->chromosome_destructor  = (GAchromosome_destructor)  
    ga_funclookup_id_to_ptr(id[GA_POPULATION_HOOK_OFFSET_CHROMOSOME_DESTRUCTOR]);
  pop->chromosome_replicate   = (GAchromosome_replicate)   
    ga_funclookup_id_to_ptr(id[GA_POPULATION_HOOK_OFFSET_CHROMOSOME_REPLICATE]);
  pop->chromosome_to_bytes    = (GAchromosome_to_bytes)    
    ga_funclookup_id_to_ptr(id[GA_POPULATION_HOOK_OFFSET_CHROMOSOME_TO_BYTES]);
  pop->chromosome_from_bytes  = (GAchromosome_from_bytes)  
    ga_funclookup_id_to_ptr(id[GA_POPULATION_HOOK_OFFSET_CHROMOSOME_FROM_BYTES]);
  pop->chromosome_to_string   = (GAchromosome_to_string)   
    ga_funclookup_id_to_ptr(id[GA_POPULATION_HOOK_OFFSET_CHROMOSOME_TO_STRING]);

  pop->evaluate   = (GAevaluate)       ga_funclookup_id_to_ptr(id[GA_POPULATION_HOOK_OFFSET_EVALUATE]);
  pop->seed       = (GAseed)           ga_funclookup_id_to_ptr(id[GA_POPULATION_HOOK_OFFSET_SEED]);
  pop->adapt      = (GAadapt)          ga_funclookup_id_to_ptr(id[GA_POPULATION_HOOK_OFFSET_ADAPT]);
  pop->select_one = (GAselect_one)     ga_funclookup_id_to_ptr(id[GA_POPULATION_HOOK_OFFSET_SELECT_ONE]);
  pop->select_two = (GAselect_two)     ga_funclookup_id_to_ptr(id[GA_POPULATION_HOOK_OFFSET_SELECT_TWO]);
  pop->mutate     = (GAmutate)         ga_funclookup_id_to_ptr(id[GA_POPULATION_HOOK_OFFSET_MUTATE]);
  pop->crossover  = (GAcrossover)      ga_funclookup_id_to_ptr(id[GA_POPULATION_HOOK_OFFSET_CROSSOVER]);
  pop->replace    = (GAreplace)        ga_funclookup_id_to_ptr(id[GA_POPULATION_HOOK_OFFSET_REPLACE]);
  pop->rank       = (GArank)           ga_funclookup_id_to_ptr(id[GA_POPULATION_HOOK_OFFSET_RANK]);

  /*
    * Warn user of any unhandled data.
    */
  for (i=0; i < GA_POPULATION_HOOK_COUNT; i++)
    if (id[i] == -1) count++;

  if (count>0)
    plog(LOG_NORMAL, "Unable to handle %d hook function%sspecified in population structure.", 
         count, count==1?" ":"s ");

  /*
    * Entity info.
    */
  for (i=0; i<size; i++)
  {
    gaul_read_entity_posix(fp, pop);
  }

  /*
    * Footer info.
    */
  fread(buffer, sizeof(char), 4, fp); 
  if (strcmp("END", buffer)!=0)
    die("Corrupt population file?");

  /*
    * Close file.
    */
  fclose(fp);

  plog(LOG_DEBUG, "Have read %d entities into population.", pop->size);

  return pop;
}
/**********************************************************************
  synopsis:	Write an entity to disk.
		Note: Currently does not (and probably can not) store
		any of the userdata.
  parameters:	population *pop
		entity *this_entity
		char *fname
  return:	TRUE
 **********************************************************************/
boolean 
ga_entity_write (population *pop, entity *this_entity, char *fname)
{
  int		i;			/* Loop variable. */
  char		buffer[BUFFER_SIZE];	/* String buffer. */
  char		*format_str="FORMAT: GAUL ENTITY 001";	/* Format tag. */
  FILE		*fp;			/* Filehandle. */

  /* Checks. */
  if ( !pop ) die("Null pointer to population structure passed.");
  if ( !this_entity ) die("Null pointer to entity structure passed.");
  if ( !fname ) die("Null pointer to filename passed.");

  /*
    * Open output file.
    */
  if( !(fp=fopen(fname,"w")) )
    dief("Unable to open entity file \"%s\" for output.", fname);

  /*
    * Write stuff.
    */
  fwrite(format_str, sizeof(char), strlen(format_str), fp);
  for (i=0; i<64; i++) buffer[i]='\0';
  snprintf(buffer, 64, "%s %s", GA_VERSION_STRING, GA_BUILD_DATE_STRING);
  fwrite(buffer, sizeof(char), 64, fp);

  gaul_write_entity_posix(fp, pop, this_entity);

  fwrite("END", sizeof(char), 4, fp); 

  fclose(fp);

  return TRUE;
}
/**********************************************************************
  synopsis:	Read an entity from disk.
		Note: Currently does not (and probably can not) store
		any of the userdata.
  parameters:	population *pop
		entity *this_entity
		char *fname
  return:	TRUE
 **********************************************************************/
entity *
ga_entity_read (population *pop, char *fname)
{
  char		buffer[BUFFER_SIZE];	/* String buffer. */
  char		*format_str="FORMAT: GAUL ENTITY 001";	/* Format tag. */
  char		format_str_in[32];	/* Input format tag. */
  FILE		*fp;			/* Filehandle. */
  entity	*this_entity;		/* Input entity. */

  /* Checks. */
  if ( !pop ) die("Null pointer to population structure passed.");
  if ( !fname ) die("Null pointer to filename passed.");

  /*
    * Open input file.
    */
  if( !(fp=fopen(fname,"r")) )
    dief("Unable to open entity file \"%s\" for input.", fname);

  /*
    * Read stuff.
    */
  fread(format_str_in, sizeof(char), strlen(format_str), fp);
  if (strcmp(format_str, format_str_in)!=0) die("Incorrect format for entity file.");
  fread(buffer, sizeof(char), 64, fp);	/* Ignored. */

  this_entity = gaul_read_entity_posix(fp, pop);

  fread(buffer, sizeof(char), 4, fp); 
  if (strcmp("END", buffer)!=0) die("Corrupt population file?");

  fclose(fp);

  return this_entity;
}
//******************************************************************************

