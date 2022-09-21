
# /*******************************************************************************
#   ga_chromo.c
#  *******************************************************************************

#   ga_chromo - Genetic algorithm chromosome handling routines.
#   Copyright ©2000-2006, Stewart Adcock <stewart@linux-domain.com>
#   All rights reserved.

#   ******************************************************************************

#   Synopsis:     Routines for handling GAUL's built-in chromosome types.

# 		The functions required for each chromsome type are:
# 		ga_chromosome_XXX_allocate() - assign memory.
# 		ga_chromosome_XXX_deallocate() - free memory.
# 		ga_chromosome_XXX_replicate() - copy genetic information.
# 		ga_chromosome_XXX_to_bytes() - for serialization.
# 		   (Leave max_bytes==0, if no need to free (i.e. static))
# 		ga_chromosome_XXX_from_bytes() - for deserialization.
# 		ga_chromosome_XXX_to_string() - Human readable NULL-
# 		   terminated string.

# 		The chromosome types are:
# 		integer - C int.
# 		boolean - boolean (generally, C _Bool by default).
# 		double - C double.
# 		char - C char.
# 		bitstring - bitstring.
# 		list - generic linked-list.

#   To do:	Will need chromosome comparison functions.

#   *****************************************************************************/

# //#include "ga_chromo.h"
# #include "gaul.h"

# /*******************************************************************************
#   synopsis:	Allocate the chromosomes for an entity.  Initial
# 		contents are garbage (there is no need to zero them).
#  *******************************************************************************/
# GAULFUNC boolean ga_chromosome_integer_allocate (population *pop,
#                                         entity *embryo )
# {
#   //int		i;		/* Loop variable over all chromosomes */

#   if (! pop)    die ("Null pointer to population structure passed.");
#   if (! embryo) die ("Null pointer to entity structure passed.");

#   if (embryo->chromosome!=NULL)
#     die("This entity already contains chromosomes.");

# /* #ifdef USE_CHROMO_CHUNKS */
# /*   THREAD_LOCK(pop->chromo_chunk_lock); */
# /*   if (!pop->chromo_chunk) */
# /*     { */
#   ///*     pop->chromoarray_chunk = mem_chunk_new(/* pop->num_chromosomes* */sizeof(int *), 1024); */
#   ///*     pop->chromo_chunk = mem_chunk_new(/* pop->num_chromosomes* */pop->len_chromosomes*sizeof(int), 2048);  */
# /*     } */

# /*   embryo->chromosome = mem_chunk_alloc(pop->chromoarray_chunk); */
# /*   embryo->CH = mem_chunk_alloc(pop->chromo_chunk); */
# /*   THREAD_UNLOCK(pop->chromo_chunk_lock); */
# /* #else */
#   if ( !(embryo->chromosome = s_malloc(/* pop->num_chromosomes* */sizeof(int *))) )
#     die("Unable to allocate memory");
#   if ( !(embryo->CH = s_malloc(/* pop->num_chromosomes* */pop->len_chromosomes*sizeof(int))) )
#     die("Unable to allocate memory");
# /* #endif */

# /*  for (i=1; i<pop->num_chromosomes; i++) */
# /*     { */
# /*     embryo->chromosome[i] = &(((int *)embryo->chromosome[i-1])[pop->len_chromosomes]); */
# /*     } */

#   return TRUE;
#   }
# /*******************************************************************************
#   synopsis:	Deallocate the chromosomes for an entity.
# *******************************************************************************/
# GAULFUNC void ga_chromosome_integer_deallocate( population *pop,
#                                        entity *corpse )
#   {

#   if (!pop) die("Null pointer to population structure passed.");
#   if (!corpse) die("Null pointer to entity structure passed.");

#   if (corpse->chromosome==NULL)
#     die("This entity already contains no chromosomes.");

# /* #ifdef USE_CHROMO_CHUNKS */
# /*   THREAD_LOCK(pop->chromo_chunk_lock); */
# /*   mem_chunk_free(pop->chromo_chunk, corpse->CH); */
# /*   mem_chunk_free(pop->chromoarray_chunk, corpse->chromosome); */
# /*   corpse->chromosome=NULL; */

# /*   if (mem_chunk_isempty(pop->chromo_chunk)) */
# /*     { */
# /*     mem_chunk_destroy(pop->chromo_chunk); */
# /*     mem_chunk_destroy(pop->chromoarray_chunk); */
# /*     pop->chromo_chunk = NULL; */
# /*     } */
# /*   THREAD_UNLOCK(pop->chromo_chunk_lock); */
# /* #else */
#   s_free(corpse->CH);
#   s_free(corpse->chromosome);
#   corpse->chromosome=NULL;
# /* #endif */

#   return;
#   }
# /*******************************************************************************
#   synopsis:	Duplicate a chromosome exactly.
# *******************************************************************************/
# GAULFUNC void ga_chromosome_integer_replicate( const population *pop,
#                                       entity *parent, entity *child,
#                                       const int chromosomeid )
#   {

#   if (!pop) die("Null pointer to population structure passed.");
#   if (!parent || !child) die("Null pointer to entity structure passed.");
#   if (!parent->chromosome || !child->chromosome) die("Entity has no chromsomes.");

#   memcpy( child->chromosome[chromosomeid],
#           parent->chromosome[chromosomeid],
#           pop->len_chromosomes * sizeof(int));

#   return;
#   }
# /*******************************************************************************
#   synopsis:	Convert to contiguous form.  In this case, a trivial
# 		process.
# *******************************************************************************/
# GAULFUNC unsigned int ga_chromosome_integer_to_bytes(const population *pop, entity *joe,
#                                      gaulbyte **bytes, unsigned int *max_bytes)
#   {
#   int		num_bytes;	/* Actual size of genes. */

#   if (!pop) die("Null pointer to population structure passed.");
#   if (!joe) die("Null pointer to entity structure passed.");

#   if (*max_bytes!=0) die("Internal error.");

#   if (!joe->chromosome)
#     {
#     *bytes = (gaulbyte *)"\0";
#     return 0;
#     }

#   num_bytes = pop->len_chromosomes * /* pop->num_chromosomes * */ sizeof(int);

#   *bytes = (gaulbyte *)joe->CH;

#   return num_bytes;
#   }
# /*******************************************************************************
#   synopsis:	Convert from contiguous form.  In this case, a trivial
# 		process.
# *******************************************************************************/
# GAULFUNC void ga_chromosome_integer_from_bytes(const population *pop, entity *joe, gaulbyte *bytes)
#   {

#   if (!pop) die("Null pointer to population structure passed.");
#   if (!joe) die("Null pointer to entity structure passed.");

#   if (!joe->chromosome) die("Entity has no chromsomes.");

#   memcpy(joe->CH, bytes,
#          pop->len_chromosomes * /* pop->num_chromosomes * */ sizeof(int));

#   return;
#   }
# /*******************************************************************************
#   synopsis:	Convert to human readable form.
#   parameters:	const population *pop	Population (compatible with entity)
#   		const entity *joe	Entity to encode as text.
# 		char *text		Malloc()'ed text buffer, or NULL.
# 		size_t *textlen		Current size of text buffer.
# *******************************************************************************/
# GAULFUNC char *ga_chromosome_integer_to_string (
#                               const population *pop, const entity *joe,
#                               char *text, size_t *textlen)
# {
#   int		/* i, */ j;		/* Loop over chromosome, alleles. */
#   int		k=0;		/* Pointer into 'text'. */
#   int		l;		/* Number of appended digits. */

#   //if (is_print) 
#   //  printf ("ga_chromosome_integer_to_strin ............... \n");

#   if (! pop) die ("Null pointer to population structure passed.");
#   if (! joe) die ("Null pointer to entity structure passed.");

#   // Ensure that a reasonable amount of memory is allocated.
#   // 
#   if (!text || (int) *textlen < 8 * pop->len_chromosomes /* * pop->num_chromosomes */)
#     {
#     *textlen = 8 * pop->len_chromosomes/*  * pop->num_chromosomes */;
#     text = s_realloc (text, sizeof(char) * *textlen);
#     }

#   // Handle empty chromosomes. 
#   // 
#   if (! joe->chromosome)
#     {
#     text[1] = '\0';
#     return text;
#     }

  

#   // i=0;
#   // for(i=0; i<pop->num_chromosomes; i++)
#   //  {
#   for (j = 0; j < pop->len_chromosomes; j++) {
#     if (*textlen-k < 8)
#     {
#       *textlen *= 2;   // Double allocation.
#       text = s_realloc (text, sizeof(char) * *textlen);
#     }

#     l = snprintf (&(text[k]), *textlen-k, "%d ",
#                  ((int *)joe->CH/* chromosome[0] */)[j]);

#     if (l == -1)
#     {	// Truncation occured.
#       *textlen *= 2;	// Double allocation. 
#       text = s_realloc (text, sizeof(char) * *textlen);
#       l = snprintf (&(text[k]), *textlen-k, "%d ",
#                    ((int *)joe->CH/* chromosome[0] */)[j]);

#       if (l == -1) die ("Internal error, string truncated again.");
#     }

#     k += l;
#   }
#   //  }

#   // Replace last space character with NULL character.
#   text[k-1] = '\0';

#   return text;
# }
# /*******************************************************************************
#   synopsis:	Allocate the chromosomes for an entity.  Initial
# 		contents are garbage (there is no need to zero them).
# *******************************************************************************/
# GAULFUNC boolean ga_chromosome_boolean_allocate(population *pop, entity *embryo)
#   {
#     //int		i;		/* Loop variable over all chromosomes */

#   if (!pop) die("Null pointer to population structure passed.");
#   if (!embryo) die("Null pointer to entity structure passed.");

#   if (embryo->chromosome!=NULL)
#     die("This entity already contains chromosomes.");

#   if ( !(embryo->chromosome = s_malloc(/* pop->num_chromosomes* */sizeof(boolean *))) )
#     die("Unable to allocate memory");
#   if ( !(embryo->CH = s_malloc(/* pop->num_chromosomes* */pop->len_chromosomes*sizeof(boolean))) )
#     die("Unable to allocate memory");

# /*   for (i=1; i<pop->num_chromosomes; i++) */
# /*     { */
# /*     embryo->chromosome[i] = &(((boolean *)embryo->chromosome[i-1])[pop->len_chromosomes]); */
# /*     } */

#   return TRUE;
#   }
# /*******************************************************************************
#   synopsis:	Deallocate the chromosomes for an entity.
# *******************************************************************************/
# GAULFUNC void ga_chromosome_boolean_deallocate(population *pop, entity *corpse)
#   {

#   if (!pop) die("Null pointer to population structure passed.");
#   if (!corpse) die("Null pointer to entity structure passed.");

#   if (corpse->chromosome==NULL)
#     die("This entity already contains no chromosomes.");

#   s_free(corpse->CH);
#   s_free(corpse->chromosome);
#   corpse->chromosome=NULL;

#   return;
#   }
# /*******************************************************************************
#   synopsis:	Duplicate a chromosome exactly.
# *******************************************************************************/
# GAULFUNC void ga_chromosome_boolean_replicate( const population *pop,
#                                       entity *parent, entity *child,
#                                       const int chromosomeid )
#   {

#   if (!pop) die("Null pointer to population structure passed.");
#   if (!parent || !child) die("Null pointer to entity structure passed.");
#   if (!parent->chromosome || !child->chromosome) die("Entity has no chromsomes.");

#   memcpy(child->chromosome[chromosomeid], parent->chromosome[chromosomeid],
#               pop->len_chromosomes * sizeof(boolean));

#   return;
#   }
# /*******************************************************************************
#   synopsis:	Convert to contiguous form.  In this case, a trivial
# 		process.  (Note that we could compress the data at this
# 		point but CPU time is currenty more important to me
# 		than memory or bandwidth)
# *******************************************************************************/
# GAULFUNC unsigned int ga_chromosome_boolean_to_bytes(const population *pop, entity *joe,
#                                     gaulbyte **bytes, unsigned int *max_bytes)
#   {
#   int		num_bytes;	/* Actual size of genes. */

#   if (!pop) die("Null pointer to population structure passed.");
#   if (!joe) die("Null pointer to entity structure passed.");

#   if (*max_bytes!=0) die("Internal error.");

#   if (!joe->chromosome)
#     {
#     *bytes = (gaulbyte *)"\0";
#     return 0;
#     }

#   num_bytes = pop->len_chromosomes * /* pop->num_chromosomes * */sizeof(boolean);

#   *bytes = (gaulbyte *)joe->CH;

#   return num_bytes;
#   }
# /*******************************************************************************
#   synopsis:	Convert from contiguous form.  In this case, a trivial
# 		process.
# *******************************************************************************/
# GAULFUNC void ga_chromosome_boolean_from_bytes(const population *pop, entity *joe, gaulbyte *bytes)
#   {

#   if (!pop) die("Null pointer to population structure passed.");
#   if (!joe) die("Null pointer to entity structure passed.");

#   if (!joe->chromosome) die("Entity has no chromsomes.");

#   memcpy(joe->CH, bytes,
#          pop->len_chromosomes */*  pop->num_chromosomes *  */sizeof(boolean));

#   return;
#   }
# /*******************************************************************************
#   synopsis:	Convert to human readable form.
# *******************************************************************************/
# GAULFUNC char *ga_chromosome_boolean_to_string(
#                               const population *pop, const entity *joe,
#                               char *text, size_t *textlen)
#   {
#   int		/* i, */ j;		/* Loop over chromosome, alleles. */
#   int		k=0;		/* Pointer into 'text'. */

#   if (!pop) die("Null pointer to population structure passed.");
#   if (!joe) die("Null pointer to entity structure passed.");

#   if (!text || (int) *textlen < pop->len_chromosomes /* * pop->num_chromosomes */ + 1)
#     {
#     *textlen = pop->len_chromosomes /* * pop->num_chromosomes */ + 1;
#     text = s_realloc(text, sizeof(char) * *textlen);
#     }

#   if (!joe->chromosome)
#     {
#     text[0] = '\0';
#     }
#   else
#     {
#       //i=0;
#       //for(i=0; i<pop->num_chromosomes; i++)
#       //{
#       for(j=0; j<pop->len_chromosomes; j++)
#       {
#         text[k++] = ((boolean *)joe->CH/* chromosome[i] */)[j]?'1':'0';
#       }
#       //}
#     text[k] = '\0';
#     }

#   return text;
#   }
# /*******************************************************************************
#   synopsis:	Allocate the chromosomes for an entity.  Initial
# 		contents are garbage (there is no need to zero them).
#-------------------------------------------------------------------------------
# GAULFUNC boolean ga_chromosome_double_allocate(population *pop, entity *embryo)
#-------------------------------------------------------------------------------
proc ga_chromosome_double_allocate {pop embryo} {

  #     //int		i;		/* Loop variable over all chromosomes */
  
  #   if (!pop) die("Null pointer to population structure passed.");
  #   if (!embryo) die("Null pointer to entity structure passed.");

  #   if (embryo->chromosome!=NULL)
  #     die("This entity already contains chromosomes.");
  
  #   if ( !(embryo->chromosome = s_malloc (/* pop->num_chromosomes* */sizeof(double *))) )
  #     die("Unable to allocate memory");
  
  #   if ( !(embryo->CH = s_malloc(/* pop->num_chromosomes* */pop->len_chromosomes*sizeof(double))) )
  #     die("Unable to allocate memory");
  
  puts "len_chromosomes = [$pop cget -len_chromosomes]"


  # /*   for (i=1; i<pop->num_chromosomes; i++) */
  # /*     { */
  # /*     embryo->chromosome[i] = &(((double *)embryo->chromosome[i-1])[pop->len_chromosomes]); */
  # /*     } */

  return true;
}
# /*******************************************************************************
#   synopsis:	Deallocate the chromosomes for an entity.
# *******************************************************************************/
# GAULFUNC void ga_chromosome_double_deallocate(population *pop, entity *corpse)
#   {

#   if (!pop) die("Null pointer to population structure passed.");
#   if (!corpse) die("Null pointer to entity structure passed.");

#   if (corpse->chromosome==NULL)
#     die("This entity already contains no chromosomes.");

#   s_free(corpse->CH);
#   s_free(corpse->chromosome);
#   corpse->chromosome=NULL;

#   return;
#   }
# /*******************************************************************************
#   synopsis:	Duplicate a chromosome exactly.
# *******************************************************************************/
# GAULFUNC void ga_chromosome_double_replicate( const population *pop,
#                                       entity *parent, entity *child,
#                                       const int chromosomeid )
#   {

#   if (!pop) die("Null pointer to population structure passed.");
#   if (!parent || !child) die("Null pointer to entity structure passed.");
#   if (!parent->chromosome || !child->chromosome) die("Entity has no chromsomes.");

#   memcpy(child->chromosome[chromosomeid], parent->chromosome[chromosomeid],
#               pop->len_chromosomes * sizeof(double));

#   return;
#   }
# /*******************************************************************************
#   synopsis:	Convert to contiguous form.  In this case, a trivial
# 		process.  (Note that we could compress the data at this
# 		point but CPU time is currenty more important to me
# 		than memory or bandwidth)
# *******************************************************************************/
# GAULFUNC unsigned int ga_chromosome_double_to_bytes (const population *pop, entity *joe,
#                                     gaulbyte **bytes, unsigned int *max_bytes)
#   {
#   int		num_bytes;	/* Actual size of genes. */

#   if (!pop) die("Null pointer to population structure passed.");
#   if (!joe) die("Null pointer to entity structure passed.");

#   if (*max_bytes!=0) die("Internal error.");

#   if (!joe->chromosome)
#     {
#     *bytes = (gaulbyte *)"\0";
#     return 0;
#     }

#   num_bytes = pop->len_chromosomes * /* pop->num_chromosomes * */ sizeof(double);

#   *bytes = (gaulbyte *)joe->CH;

#   return num_bytes;
#   }
# /*******************************************************************************
#   synopsis:	Convert from contiguous form.  In this case, a trivial
# 		process.
# *******************************************************************************/
# GAULFUNC void ga_chromosome_double_from_bytes(const population *pop, entity *joe, gaulbyte *bytes)
#   {

#   if (!pop) die("Null pointer to population structure passed.");
#   if (!joe) die("Null pointer to entity structure passed.");

#   if (!joe->chromosome) die("Entity has no chromsomes.");

#   memcpy(joe->CH, bytes,
#          pop->len_chromosomes */*  pop->num_chromosomes * */ sizeof(double));

#   return;
#   }
# /*******************************************************************************
#   synopsis:	Convert to human readable form.
# *******************************************************************************/
# GAULFUNC char *ga_chromosome_double_to_string(
#                               const population *pop, const entity *joe,
#                               char *text, size_t *textlen)
#   {
#   int		/* i, */ j;		/* Loop over chromosome, alleles. */
#   int		k=0;		/* Pointer into 'text'. */
#   int		l;		/* Number of 'snprintf'ed characters. */

#   if (!pop) die("Null pointer to population structure passed.");
#   if (!joe) die("Null pointer to entity structure passed.");

#   if (!text || (int) *textlen < 10 * pop->len_chromosomes /* * pop->num_chromosomes */)
#     {
#     *textlen = 10 * pop->len_chromosomes /* * pop->num_chromosomes */;
#     text = s_realloc(text, sizeof(char) * *textlen);
#     }

#   if (!joe->chromosome)
#     {
#     text[1] = '\0';
#     return text;
#     }

#   //i=0;
#   //for(i=0; i<pop->num_chromosomes; i++)
#   //{
#   for(j=0; j<pop->len_chromosomes; j++) {
#     if (*textlen-k<8) {
#       *textlen *= 2;	/* Double allocation. */
#       text = s_realloc(text, sizeof(char) * *textlen);
#     }

#     l = snprintf(&(text[k]), *textlen-k, "%f ",
#                  ((double *)joe->CH/* chromosome[i] */)[j]);

#     if (l == -1)
#     {	/* Truncation occured. */
#       *textlen *= 2;	/* Double allocation. */
#       text = s_realloc(text, sizeof(char) * *textlen);
#       l = snprintf(&(text[k]), *textlen-k, "%f ",
#                    ((double *)joe->CH/* chromosome[i] */)[j]);

#       if (l == -1) die("Internal error, string truncated again.");
#     }

#     k += l;
#   }
#   //}

#   text[k-1] = '\0';

#   return text;
#   }
# /*******************************************************************************
#   synopsis:	Allocate the chromosomes for an entity.  Initial
# 		contents are garbage (there is no need to zero them).
# *******************************************************************************/
# GAULFUNC boolean ga_chromosome_char_allocate(population *pop, entity *embryo)
#   {
#     //int		i;		/* Loop variable over all chromosomes */

#   if (!pop) die("Null pointer to population structure passed.");
#   if (!embryo) die("Null pointer to entity structure passed.");

#   if (embryo->chromosome!=NULL)
#     die("This entity already contains chromosomes.");

#   if ( !(embryo->chromosome = s_malloc(/* pop->num_chromosomes* */sizeof(char *))) )
#     die("Unable to allocate memory");
#   if ( !(embryo->CH = s_malloc(/* pop->num_chromosomes* */pop->len_chromosomes*sizeof(char))) )
#     die("Unable to allocate memory");

# /*   for (i=1; i<pop->num_chromosomes; i++) */
# /*     { */
# /*     embryo->chromosome[i] = &(((char *)embryo->chromosome[i-1])[pop->len_chromosomes]); */
# /*     } */

#   return TRUE;
#   }
# /*******************************************************************************
#   synopsis:	Deallocate the chromosomes for an entity.
# *******************************************************************************/
# GAULFUNC void ga_chromosome_char_deallocate(population *pop, entity *corpse)
#   {

#   if (!pop) die("Null pointer to population structure passed.");
#   if (!corpse) die("Null pointer to entity structure passed.");

#   if (corpse->chromosome==NULL)
#     die("This entity already contains no chromosomes.");

# /*  ga_entity_dump(pop, corpse);*/

#   s_free(corpse->CH);
#   s_free(corpse->chromosome);
#   corpse->chromosome=NULL;

#   return;
#   }
# /*******************************************************************************
#   synopsis:	Duplicate a chromosome exactly.
# *******************************************************************************/
# GAULFUNC void ga_chromosome_char_replicate( const population *pop,
#                                    entity *parent, entity *child,
#                                    const int chromosomeid )
#   {

#   if (!pop) die("Null pointer to population structure passed.");
#   if (!parent || !child) die("Null pointer to entity structure passed.");
#   if (!parent->chromosome || !child->chromosome) die("Entity has no chromsomes.");

#   memcpy(child->chromosome[chromosomeid], parent->chromosome[chromosomeid],
#               pop->len_chromosomes * sizeof(char));

#   return;
#   }
# /*******************************************************************************
#   synopsis:	Convert to contiguous form.  In this case, a highly
# 		trivial process.
# *******************************************************************************/
# GAULFUNC unsigned int ga_chromosome_char_to_bytes(const population *pop, entity *joe,
#                                     gaulbyte **bytes, unsigned int *max_bytes)
#   {
#   int		num_bytes;	/* Actual size of genes. */

#   if (!pop) die("Null pointer to population structure passed.");
#   if (!joe) die("Null pointer to entity structure passed.");

#   if (*max_bytes!=0) die("Internal error.");

#   if (!joe->chromosome)
#     {
#     *bytes = (gaulbyte *)"\0";
#     return 0;
#     }

#   num_bytes = pop->len_chromosomes * /* pop->num_chromosomes * */ sizeof(char);

#   *bytes = (gaulbyte *)joe->CH;

#   return num_bytes;
#   }
# /*******************************************************************************
#   synopsis:	Convert from contiguous form.  In this case, a trivial
# 		process.
# *******************************************************************************/
# GAULFUNC void ga_chromosome_char_from_bytes(const population *pop, entity *joe, gaulbyte *bytes)
#   {

#   if (!pop) die("Null pointer to population structure passed.");
#   if (!joe) die("Null pointer to entity structure passed.");

#   if (!joe->chromosome) die("Entity has no chromsomes.");

#   memcpy(joe->CH, bytes,
#          pop->len_chromosomes * /* pop->num_chromosomes *  */sizeof(char));

#   return;
#   }
# /*******************************************************************************
#   synopsis:	Convert genetic data into human readable form.
# *******************************************************************************/
# GAULFUNC char *ga_chromosome_char_to_string (
#                               const population *pop, const entity *joe,
#                               char *text, size_t *textlen)
#   {
#     //int		i;		/* Loop over chromosome, alleles. */
#   int		k=0;		/* Pointer into 'text'. */

#   if (!pop) die("Null pointer to population structure passed.");
#   if (!joe) die("Null pointer to entity structure passed.");

#   if ( (int) *textlen < pop->len_chromosomes /* * pop->num_chromosomes  */+ 1 )
#     {
#     *textlen = pop->len_chromosomes /* * pop->num_chromosomes */ + 1;
#     text = s_realloc(text, sizeof(char) * *textlen);
#     }

#   if (!joe->chromosome)
#     {
#     text[0] = '\0';
#     }
#   else
#     {
#       //i=0;
#       //for(i=0; i<pop->num_chromosomes; i++)
#       //{
#       memcpy(&(text[k]), joe->CH,
#              pop->len_chromosomes * sizeof(char));
#       k += pop->len_chromosomes;
#       //}
#     text[k] = '\0';
#     }

#   return text;
#   }
# /*******************************************************************************
#   synopsis:	Allocate the chromosomes for an entity.  Initial
# 		contents are garbage (there is no need to zero them).
# *******************************************************************************/
# GAULFUNC boolean ga_chromosome_bitstring_allocate(population *pop, entity *embryo)
#   {
#     //int		i;		/* Loop variable over all chromosomes */

#   if (!pop) die("Null pointer to population structure passed.");
#   if (!embryo) die("Null pointer to entity structure passed.");

#   if (embryo->chromosome!=NULL)
#     die("This entity already contains chromosomes.");

#   if ( !(embryo->chromosome = s_malloc(/* pop->num_chromosomes* */sizeof(gaulbyte *))) )
#     die("Unable to allocate memory");

#   //i=0;
#   //for (i=0; i<pop->num_chromosomes; i++)
#   embryo->CH/* chromosome[i] */ = ga_bit_new(pop->len_chromosomes);

#   return TRUE;
#   }
# /*******************************************************************************
#   synopsis:	Deallocate the chromosomes for an entity.
# *******************************************************************************/
# GAULFUNC void ga_chromosome_bitstring_deallocate(population *pop, entity *corpse)
#   {
#     //int		i;		/* Loop variable over all chromosomes */

#   if (!pop) die("Null pointer to population structure passed.");
#   if (!corpse) die("Null pointer to entity structure passed.");

#   if (corpse->chromosome==NULL)
#     die("This entity already contains no chromosomes.");

#   //i=0;
#   //for (i=0; i<pop->num_chromosomes; i++)
#   ga_bit_free(corpse->CH/* chromosome[i] */);

#   s_free(corpse->chromosome);
#   corpse->chromosome=NULL;

#   return;
#   }
# /*******************************************************************************
#   synopsis:	Duplicate a chromosome exactly.
# *******************************************************************************/
# GAULFUNC void ga_chromosome_bitstring_replicate( const population *pop,
#                                       entity *parent, entity *child,
#                                       const int chromosomeid )
#   {

#   if (!pop) die("Null pointer to population structure passed.");
#   if (!parent || !child) die("Null pointer to entity structure passed.");
#   if (!parent->chromosome || !child->chromosome) die("Entity has no chromsomes.");

#   ga_bit_clone( child->chromosome[chromosomeid],
#                 parent->chromosome[chromosomeid],
#                 pop->len_chromosomes );

#   return;
#   }
# /*******************************************************************************
#   synopsis:	Convert to contiguous form.
# *******************************************************************************/
# GAULFUNC unsigned int ga_chromosome_bitstring_to_bytes(const population *pop,
#                                     entity *joe,
#                                      gaulbyte **bytes, unsigned int *max_bytes)
#   {
#   int		num_bytes;	/* Actual size of genes. */
#   //int		i;		/* Loop variable over all chromosomes */

#   if (!pop) die("Null pointer to population structure passed.");
#   if (!joe) die("Null pointer to entity structure passed.");

#   num_bytes = (int) ga_bit_sizeof(pop->len_chromosomes) /* * pop->num_chromosomes */;

#   if (num_bytes>(int)*max_bytes)
#     {
#     *max_bytes = num_bytes;
#     *bytes = s_realloc(*bytes, *max_bytes*sizeof(gaulbyte));
#     /* sizeof(gaulbyte) should always be 1 */
#     }

#   if (!joe->chromosome)
#     {
#     *bytes = (gaulbyte *)0;
#     return 0;
#     }

#   //i=0;
#   //for(i=0; i<pop->num_chromosomes; i++)
#   //{
#   ga_bit_copy( *bytes, joe->CH/* chromosome[i] */,
#               /* i*pop->len_chromosomes */0, 0,
#               pop->len_chromosomes );
#   //}

#   return num_bytes;
#   }
# /*******************************************************************************
#   synopsis:	Convert from contiguous form.  In this case, a trivial
# 		process.
# *******************************************************************************/
# GAULFUNC void ga_chromosome_bitstring_from_bytes( const population *pop,
#                                          entity *joe,
#                                          gaulbyte *bytes )
#   {
#     //int		i;		/* Loop variable over all chromosomes */

#   if (!pop) die("Null pointer to population structure passed.");
#   if (!joe) die("Null pointer to entity structure passed.");

#   if (!joe->chromosome) die("Entity has no chromsomes.");

#   //i=0;
#   //for(i=0; i<pop->num_chromosomes; i++)
#   //{
#   ga_bit_copy( joe->CH/* chromosome[i] */, bytes,
#               0, /* i*pop->len_chromosomes */0,
#               pop->len_chromosomes );
#   //}

#   return;
#   }
# /*******************************************************************************
#   synopsis:	Convert to human readable form.
# *******************************************************************************/
# GAULFUNC char *ga_chromosome_bitstring_to_string(
#                               const population *pop, const entity *joe,
#                               char *text, size_t *textlen)
#   {
#   int		/* i, */ j;		/* Loop over chromosome, alleles. */
#   int		k=0;		/* Pointer into 'text'. */

#   if (!pop) die("Null pointer to population structure passed.");
#   if (!joe) die("Null pointer to entity structure passed.");

#   if (!text || (int) *textlen < pop->len_chromosomes /* * pop->num_chromosomes  */+ 1)
#     {
#     *textlen = pop->len_chromosomes /* * pop->num_chromosomes  */+ 1;
#     text = s_realloc(text, sizeof(char) * *textlen);
#     }

#   if (!joe->chromosome)
#     {
#     text[0] = '\0';
#     }
#   else
#     {
#       //i=0;
#       //for(i=0; i<pop->num_chromosomes; i++)
#       //{
#       for(j=0; j<pop->len_chromosomes; j++)
#       {
#         text[k++] = ga_bit_get (joe->CH/* chromosome[i] */,j)?'1':'0';
#       }
#       //}
#     text[k] = '\0';
#     }

#   return text;
#   }
# /*******************************************************************************
#   synopsis:	Allocate the chromosomes for an entity.  Initial
# 		contents are set to null.
# *******************************************************************************/
# GAULFUNC boolean ga_chromosome_list_allocate(population *pop, entity *embryo)
#   {
#     //int		i;		/* Loop variable over all chromosomes */

#   if (!pop) die("Null pointer to population structure passed.");
#   if (!embryo) die("Null pointer to entity structure passed.");

#   if (embryo->chromosome!=NULL)
#     die("This entity already contains chromosomes.");

#   if ( !(embryo->chromosome = s_malloc(/* pop->num_chromosomes* */sizeof(DLList *))) )
#     die("Unable to allocate memory");

#   //i=0;
#   //for (i=0; i<pop->num_chromosomes; i++)
#   embryo->CH/* chromosome[i] */ = NULL;

#   return TRUE;
#   }
# /*******************************************************************************
#   synopsis:	Deallocate the chromosomes for an entity.
# *******************************************************************************/
# GAULFUNC void ga_chromosome_list_deallocate(population *pop, entity *corpse)
#   {
#     //int		i;		/* Loop variable over all chromosomes */

#   if (!pop) die("Null pointer to population structure passed.");
#   if (!corpse) die("Null pointer to entity structure passed.");

#   if (corpse->chromosome==NULL)
#     die("This entity already contains no chromosomes.");

#   //i=0;
#   //for (i=0; i<pop->num_chromosomes; i++)
#   dlink_free_all (corpse->CH/* chromosome[i] */);

#   s_free(corpse->chromosome);
#   corpse->chromosome=NULL;

#   return;
#   }
# /*******************************************************************************
#   synopsis:	Duplicate a chromosome exactly.
# 		Currently unimplemented at present.
# *******************************************************************************/
# GAULFUNC void ga_chromosome_list_replicate( const population *pop,
#                                       entity *parent, entity *child,
#                                       const int chromosomeid )
#   {

#   if (!pop) die("Null pointer to population structure passed.");
#   if (!parent || !child) die("Null pointer to entity structure passed.");
#   if (!parent->chromosome || !child->chromosome) die("Entity has no chromsomes.");

#   child->chromosome[chromosomeid] = dlink_clone(
#                 parent->chromosome[chromosomeid] );

#   return;
#   }
# /*******************************************************************************
#   synopsis:	Convert to contiguous form.
# 		Currently unimplemented at present.
# 		FIXME: Need a user-defined callback to implement this
# 		according to contents of the list.
# *******************************************************************************/
# GAULFUNC unsigned int ga_chromosome_list_to_bytes(const population *pop,
#                                     entity *joe,
#                                      gaulbyte **bytes, unsigned int *max_bytes)
#   {
#   int		num_bytes=0;	/* Actual size of genes. */

#   if (!pop) die("Null pointer to population structure passed.");
#   if (!joe) die("Null pointer to entity structure passed.");

#   die("ga_chromosome_list_to_bytes() is not implemented.");

#   /* Avoid compiler warnings. */
#   **bytes = 0;
#   *max_bytes = 0;

#   return num_bytes;
#   }
# /*******************************************************************************
#   synopsis:	Convert from contiguous form.  In this case, a trivial
# 		process.
# 		Currently unimplemented at present.
# 		FIXME: Need a user-defined callback to implement this
# 		according to contents of the list.
# *******************************************************************************/
# GAULFUNC void ga_chromosome_list_from_bytes( const population *pop,
#                                          entity *joe,
#                                          gaulbyte *bytes )
#   {

#   if (!pop) die("Null pointer to population structure passed.");
#   if (!joe) die("Null pointer to entity structure passed.");

#   if (!joe->chromosome) die("Entity has no chromsomes.");

#   die("ga_chromosome_list_from_bytes() is not implemented.");

#   /* Avoid compiler warning. */
#   *bytes = 0;

#   return;
#   }
# /*******************************************************************************
#   synopsis:	Convert to human readable form.
# 		Currently unimplemented at present.
# 		FIXME: Need a user-defined callback to implement this
# 		according to contents of the list.
# *******************************************************************************/
# GAULFUNC char *ga_chromosome_list_to_string(
#                               const population *pop, const entity *joe,
#                               char *text, size_t *textlen)
#   {

#   if (!pop) die("Null pointer to population structure passed.");
#   if (!joe) die("Null pointer to entity structure passed.");

#   if (!text || *textlen < 14)
#     {
#     *textlen = 14;
#     text = s_realloc(text, sizeof(char) * *textlen);
#     }

#   strncpy(text, "<unavailable>", 14);

#   return text;
#   }
# //******************************************************************************



