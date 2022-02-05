/*******************************************************************************
 *                                                                             *
 *  Имя этого файла: avltree.h                                                 *
 *                                                                             *
  ******************************************************************************
 */  
                                                                            
#ifndef AVLTREE_H_INCLUDED
#define AVLTREE_H_INCLUDED

//#include "gaul_util.h"

#include <stdio.h>
#include <stdlib.h>

#include "c_all_util.h"

//#include "c_compatibility.h"
#include "c_memory_util.h"

/*----------------------------------------------------------------------------*/
/*
 * Define datatype for AVL keys.
 */
#ifdef AVLTREE_KEY_TYPE
typedef AVLTREE_KEY_TYPE AVLKey;
#else
typedef unsigned long AVLKey;
#endif

typedef AVLKey	(*AVLKeyFunc)(constvpointer data);
typedef boolean	(*AVLTraverseFunc)(AVLKey key, vpointer data, vpointer userdata);
typedef boolean	(*AVLMatchFunc)(constvpointer data, vpointer userdata);
typedef int	(*AVLSearchFunc)(constvpointer data, vpointer userdata);
typedef void	(*AVLDestructorFunc)(vpointer data);

typedef struct AVLTree_t
  {
  struct AVLNode_t	*root;  /* opaque from hereonin. */
  AVLKeyFunc		key_generate_func;
  } AVLTree;

/*----------------------------------------------------------------------------*/
/*
 * Prototypes.
 */

GAULFUNC void		avltree_init_openmp (void);
GAULFUNC AVLTree       *avltree_new (AVLKeyFunc key_generate_func);
GAULFUNC void		avltree_delete (AVLTree *tree);
GAULFUNC void		avltree_destroy (AVLTree *tree, AVLDestructorFunc free_func);
GAULFUNC boolean	avltree_insert (AVLTree *tree, vpointer data);
GAULFUNC vpointer	avltree_remove (AVLTree *tree, vpointer data);
GAULFUNC vpointer	avltree_remove_key (AVLTree *tree, AVLKey key);
GAULFUNC vpointer	avltree_lookup (AVLTree *tree, vpointer data);
GAULFUNC vpointer	avltree_lookup_lowest (AVLTree *tree);
GAULFUNC vpointer	avltree_lookup_highest (AVLTree *tree);
GAULFUNC vpointer	avltree_lookup_key (AVLTree *tree, AVLKey key);
GAULFUNC vpointer	avltree_ordered_search (AVLTree *tree,
                                                AVLSearchFunc search_func, vpointer userdata);
GAULFUNC vpointer	avltree_search (AVLTree *tree,
                                        AVLMatchFunc search_func, vpointer userdata);
GAULFUNC void		avltree_traverse (AVLTree *tree,
                                          AVLTraverseFunc traverse_func, vpointer userdata);
GAULFUNC int		avltree_height (AVLTree *tree);
GAULFUNC int		avltree_num_nodes (AVLTree *tree);
GAULFUNC void		avltree_diagnostics (void);

//#ifndef AVLTREE_COMPILE_MAIN
GAULFUNC boolean	avltree_test (void);
//#endif

#endif /* AVLTREE_H_INCLUDED */
/*============================================================================*/
