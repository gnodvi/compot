/*******************************************************************************
 *                                                                             *
 *  Имя этого файла: c_memory_chunks.h                                         *
 *                                                                             *
  ******************************************************************************
 */  
                                                                            
#ifndef MEMORY_CHUNKS_H_INCLUDED
#define MEMORY_CHUNKS_H_INCLUDED

#include "c_all_util.h"

#include <stdlib.h>
#include <string.h>

#include "c_memory_util.h"

#ifndef MEMORY_ALIGN_SIZE
#define MEMORY_ALIGN_SIZE       MAX(sizeof(void *), sizeof(long))
#endif

/*----------------------------------------------------------------------------*/
/*
 * Data types.
 */

typedef struct MemChunk_t MemChunk;

/*----------------------------------------------------------------------------*/
/*
 * Prototypes.
 */

GAULFUNC void		mem_chunk_init_openmp(void);

GAULFUNC MemChunk      *mem_chunk_new_real (size_t atom_size, unsigned int num_atoms);
GAULFUNC MemChunk      *mem_chunk_new_unfreeable_real (size_t atom_size, unsigned int num_atoms);
GAULFUNC boolean	mem_chunk_has_freeable_atoms_real (MemChunk *mem_chunk);
GAULFUNC boolean	mem_chunk_isempty_real (MemChunk *mem_chunk);
GAULFUNC void		mem_chunk_destroy_real (MemChunk *mem_chunk);
GAULFUNC void	       *mem_chunk_alloc_real (MemChunk *mem_chunk);
GAULFUNC void		mem_chunk_free_real (MemChunk *mem_chunk, void *mem);
GAULFUNC void		mem_chunk_clean_real (MemChunk *mem_chunk);
GAULFUNC void		mem_chunk_reset_real (MemChunk *mem_chunk);
GAULFUNC boolean	mem_chunk_test_real (void);
GAULFUNC boolean	mem_chunk_check_all_bounds_real (MemChunk *mem_chunk);
GAULFUNC boolean	mem_chunk_check_bounds_real (MemChunk *mem_chunk, void *mem);
GAULFUNC void		mem_chunk_diagnostics_real (void);

GAULFUNC MemChunk      *mem_chunk_new_mimic (size_t atom_size, unsigned int num_atoms);
GAULFUNC MemChunk      *mem_chunk_new_unfreeable_mimic (size_t atom_size, unsigned int num_atoms);
GAULFUNC boolean	mem_chunk_has_freeable_atoms_mimic (MemChunk *mem_chunk);
GAULFUNC boolean	mem_chunk_isempty_mimic (MemChunk *mem_chunk);
GAULFUNC void		mem_chunk_destroy_mimic (MemChunk *mem_chunk);
GAULFUNC void	       *mem_chunk_alloc_mimic (MemChunk *mem_chunk);
GAULFUNC void		mem_chunk_free_mimic (MemChunk *mem_chunk, void *mem);
GAULFUNC void		mem_chunk_clean_mimic (MemChunk *mem_chunk);
GAULFUNC void		mem_chunk_reset_mimic (MemChunk *mem_chunk);
GAULFUNC boolean	mem_chunk_test_mimic (void);
GAULFUNC boolean	mem_chunk_check_all_bounds_mimic (MemChunk *mem_chunk);
GAULFUNC boolean	mem_chunk_check_bounds_mimic (MemChunk *mem_chunk, void *mem);
GAULFUNC void		mem_chunk_diagnostics_mimic (void);

/*----------------------------------------------------------------------------*/
/*
 * Exposed API.
 */

#ifndef MEMORY_CHUNKS_MIMIC

#define mem_chunk_new(Y,Z)		mem_chunk_new_real((Y), (Z))
#define mem_chunk_new_unfreeable(Y,Z)	mem_chunk_new_unfreeable_real((Y), (Z))
#define mem_chunk_has_freeable_atoms(Z)	mem_chunk_has_freeable_atoms_real((Z))
#define mem_chunk_isempty(Z)		mem_chunk_isempty_real((Z))
#define mem_chunk_destroy(Z)		mem_chunk_destroy_real((Z))
#define mem_chunk_alloc(Z)		mem_chunk_alloc_real((Z))
#define mem_chunk_free(Y,Z)		mem_chunk_free_real((Y), (Z))
#define mem_chunk_clean(Z)		mem_chunk_clean_real((Z))
#define mem_chunk_reset(Z)		mem_chunk_reset_real((Z))
#define mem_chunk_test			mem_chunk_test_real()
#define mem_chunk_check_all_bounds(Z)	mem_chunk_check_all_bounds_real(Z)
#define mem_chunk_check_bounds(Y,Z)	mem_chunk_check_bounds_real((Y), (Z))
#define mem_chunk_diagnostics		mem_chunk_diagnostics_real()

#else

#define mem_chunk_new(Y,Z)		mem_chunk_new_mimic((Y), (Z))
#define mem_chunk_new_unfreeable(Y,Z)	mem_chunk_new_unfreeable_mimic((Y), (Z))
#define mem_chunk_has_freeable_atoms(Z)	mem_chunk_has_freeable_atoms_mimic((Z))
#define mem_chunk_isempty(Z)		mem_chunk_isempty_mimic((Z))
#define mem_chunk_destroy(Z)		mem_chunk_destroy_mimic((Z))
#define mem_chunk_alloc(Z)		mem_chunk_alloc_mimic((Z))
#define mem_chunk_free(Y,Z)		mem_chunk_free_mimic((Y), (Z))
#define mem_chunk_clean(Z)		mem_chunk_clean_mimic((Z))
#define mem_chunk_reset(Z)		mem_chunk_reset_mimic((Z))
#define mem_chunk_test			mem_chunk_test_mimic()
#define mem_chunk_check_all_bounds(Z)	mem_chunk_check_all_bounds_mimic(Z)
#define mem_chunk_check_bounds(Y,Z)	mem_chunk_check_bounds_mimic((Y), (Z))
#define mem_chunk_diagnostics		mem_chunk_diagnostics_mimic()

#endif

/*----------------------------------------------------------------------------*/
#endif /* MEMORY_CHUNKS_H_INCLUDED */
/*----------------------------------------------------------------------------*/

