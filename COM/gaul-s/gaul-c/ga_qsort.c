/**********************************************************************
  ga_qsort.c
 **********************************************************************

  ga_qsort - GA population sorting routines.
  Copyright б╘2000-2006, Stewart Adcock <stewart@linux-domain.com>
  All rights reserved.

  Synopsis:	Sort the population by fitness.

		These functions aren't intended for public use.

		Two versions exist.  (1) The older version uses the
		quicksort algorithm, but since it is inefficient for
		small arrays we use a shuffle sort to sort blocks of
		less than 8 elements.  Unfortunately, platform
		precision seems to be critical to the final ordering
		with degenerate fitness scores - resulting in different
		evolution results on different types of computer, which
		is unacceptable.  (2) The newer, low-tech, shuffle
		sort which sucks from a 'fanciness' perspective... but
		it works.

 **********************************************************************/

//#include "ga_qsort.h"
#include "gaul.h"

/*
 * Nice and useful macro for swapping pointers to entities.
 */
/* #define swap_e(x, y)	{entity *t; t = x; x = y; y = t; } */

//-----------------------------------------------------------------------------
/*
 * New, shuffle sort function.
 * Fairly efficient when much of the population is already in order.
 */
//-----------------------------------------------------------------------------
void sort_population (population *pop)
  {
  int	k;  /* Loop variable. */

  int	first = 0, last = pop->size-1;	/* Indices into population. */

  entity      **array_of_ptrs = pop->entity_iarray;
  boolean     done = TRUE;	/* Whether shuffle sort is complete. */


  if (pop->size == 0) { // надо бы вставить ??!!
    return ;
  }

  plog (LOG_VERBOSE, "Sorting population with %d members.", pop->size);

#ifdef GA_QSORT_TIME
  timer_start();
#endif

  if (pop->rank == ga_rank_fitness)
    {
/*
 * This optimised code for the typical fitness ranking method.
 * It avoids a function call per comparision that is required in the
 * general case.
 */

/*
 * A bi-directional bubble sort (actually called shuffle sort, apparently)
 * algorithm.  We stop when the first pop->stable_size entities are
 * definitely sorted.
 * There's an extra bubble-up at the start.
 */
/*
    for (k = 0 ; k < pop->size ; k++)
      printf("-- rank %d id %d fitness %f.\n", k, ga_get_entity_id_from_rank(pop, k), array_of_ptrs[k]->fitness);
*/

    for (k = last ; k > first ; k--)
      {
      if ( array_of_ptrs[k]->fitness > array_of_ptrs[k-1]->fitness )
        {
        swap_e(array_of_ptrs[k], array_of_ptrs[k-1]);
        done = FALSE;
        }
      }
    first++;	/* The first one *MUST* be correct now. */

    while (done == FALSE && first <= pop->stable_size && first < last)
      {
      for (k = last ; k > first ; k--)
        {
        if ( array_of_ptrs[k]->fitness > array_of_ptrs[k-1]->fitness )
          {
          swap_e(array_of_ptrs[k], array_of_ptrs[k-1]);
          }
        }
      first++;	/* The first one *MUST* be correct now. */

      done = TRUE;

      for (k = first ; k < last ; k++)
        {
        if ( array_of_ptrs[k]->fitness < array_of_ptrs[k+1]->fitness )
          {
          swap_e(array_of_ptrs[k], array_of_ptrs[k+1]);
          done = FALSE;
          }
        }
      last--;	/* The last one *MUST* be correct now. */
      }
    }
  else
    {
/*
 * A bi-directional bubble sort (actually called shuffle sort, apparently)
 * algorithm.  We stop when the first pop->stable_size entities are
 * definitely sorted.
 * There's an extra bubble-up at the start.
 */
/*
    for (k = 0 ; k < pop->size ; k++)
      printf("-- rank %d id %d fitness %f.\n", k, ga_get_entity_id_from_rank(pop, k), array_of_ptrs[k]->fitness);
*/

    for (k = last ; k > first ; k--)
      {
      if ( pop->rank(pop, array_of_ptrs[k], pop, array_of_ptrs[k-1]) > 0 )
        {
        swap_e(array_of_ptrs[k], array_of_ptrs[k-1]);
        done = FALSE;
        }
      }
    first++;	/* The first one *MUST* be correct now. */

    while (done == FALSE && first <= pop->stable_size && first < last)
      {
      for (k = last ; k > first ; k--)
        {
        if ( pop->rank(pop, array_of_ptrs[k], pop, array_of_ptrs[k-1]) > 0 )
          {
          swap_e(array_of_ptrs[k], array_of_ptrs[k-1]);
          }
        }
      first++;	/* The first one *MUST* be correct now. */

      done = TRUE;

      for (k = first ; k < last ; k++)
        {
        if ( pop->rank(pop, array_of_ptrs[k], pop, array_of_ptrs[k+1]) < 0 )
          {
          swap_e(array_of_ptrs[k], array_of_ptrs[k+1]);
          done = FALSE;
          }
        }
      last--;	/* The last one *MUST* be correct now. */
      }
    }

#if GA_QSORT_DEBUG>1
/* Check that the population is correctly sorted. */
  printf ("rank 0 id %d fitness %f.\n", ga_get_entity_id_from_rank(pop, 0), 
          array_of_ptrs[0]->fitness);
  for (k = 1 ; k < pop->stable_size ; k++)
    {
    printf("rank %d id %d fitness %f.\n", k, ga_get_entity_id_from_rank(pop, k), array_of_ptrs[k]->fitness);
    if ( pop->rank(pop, array_of_ptrs[k-1]->fitness, pop, array_of_ptrs[k]->fitness) < 0 )
      {
      plog(LOG_WARNING, "Population is incorrectly ordered.");
      }
    }
#endif

#ifdef GA_QSORT_TIME
  timer_check ();
#endif


  // мы же уже поменяли, так что надо установить!
  // 
  pop->best = 0; // !!?? а если не было ни одного элемента! 
  // тогда неоправдано -1 поменяется на 0 !!

  return;
  }
//-----------------------------------------------------------------------------
// 
//*****************************************************************************
//-----------------------------------------------------------------------------


