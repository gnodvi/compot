//------------------------------------------------------------------------------

/**********************************************************************
  ga_tabu.c
 **********************************************************************

  ga_tabu - A tabu-search algorithm for comparison and local search.
  Copyright б╘2002-2006, Stewart Adcock <stewart@linux-domain.com>
  All rights reserved.

  Synopsis:     A tabu-search algorithm for comparison and local search.

  		A novel population-based tabu-search is also provided.
		(Or at least it will be!)

 **********************************************************************/

//#include "ga_tabu.h"
#include "gaul.h"

//------------------------------------------------------------------------------
//  synopsis:   Compares two solutions with integer chromosomes and
//	   	returns TRUE if, and only if, they are exactly
//		identical.
//------------------------------------------------------------------------------
boolean 
ga_tabu_check_integer (population *pop,
                       entity	  *putative,
                       entity	  *tabu)
{
  //int		i;		/* Loop variable over chromosomes. */
  int		j;		/* Loop variable over alleles. */
  int           *a, *b;         /* Comparison integer arrays. */

  /* Checks. */
  //if ( !pop ) die("Null pointer to population structure passed.");
  //if ( !putative || !tabu ) die("Null pointer to entity structure passed.");

  //for (i=0; i< 1/* pop->num_chromosomes */; i++)
  //{
  a = (int*) (putative->CH);
  b = (int*) (    tabu->CH);

  for (j = 0; j < pop->len_chromosomes; j++)
    if (a[j] != b[j]) return FALSE;
  //}

  return TRUE;
}
//------------------------------------------------------------------------------
//  synopsis:   Compares two solutions with character chromosomes and
//		returns TRUE if, and only if, they are exactly
//		identical.
//------------------------------------------------------------------------------
boolean 
ga_tabu_check_char (population	*pop,
                    entity	*putative,
                    entity      *tabu)
{
  //int		i;		/* Loop variable over chromosomes. */
  int		j;		/* Loop variable over alleles.     */
  char		*a, *b;		/* Comparison char arrays.         */

  /* Checks. */
  //if ( !pop ) die("Null pointer to population structure passed.");
  //if ( !putative || !tabu ) die("Null pointer to entity structure passed.");

  //for (i=0; i< 1/* pop->num_chromosomes */; i++)
  //{
  a = (char*) (putative->CH);
  b = (char*) (    tabu->CH);

  for (j = 0; j < pop->len_chromosomes; j++)
    if (a[j] != b[j]) return FALSE;
  //}

  return TRUE;
}
//------------------------------------------------------------------------------
//  synopsis:   Compares two solutions with boolean chromosomes and
//		returns TRUE if, and only if, they are exactly
//		identical.
//------------------------------------------------------------------------------
boolean 
ga_tabu_check_boolean (population  *pop,
                       entity	   *putative,
                       entity	   *tabu)
{
  //int		i;		/* Loop variable over chromosomes. */
  int		j;		/* Loop variable over alleles.     */
  boolean	*a, *b;		/* Comparison boolean arrays.      */

  /* Checks. */
  //if ( !pop ) die("Null pointer to population structure passed.");
  //if ( !putative || !tabu ) die("Null pointer to entity structure passed.");

  //for (i=0; i< 1/* pop->num_chromosomes */; i++)
  //{
  a = (boolean*)(putative->CH);
  b = (boolean*)(    tabu->CH);

  for (j = 0; j < pop->len_chromosomes; j++)
    if (a[j] != b[j]) return FALSE;
  //}

  return TRUE;
}
//------------------------------------------------------------------------------
//  synopsis:   Compares two solutions with double chromosomes and
//		returns TRUE if, and only if, allele pair difference
//		is less than TINY.
//------------------------------------------------------------------------------
boolean 
ga_tabu_check_double (population  *pop,
                      entity	  *putative,
                      entity	  *tabu)
{
  //int		i;		/* Loop variable over chromosomes. */
  int		j;		/* Loop variable over alleles.     */
  double	*a, *b;         /* Comparison double arrays.       */

  /* Checks. */
  //if ( !pop ) die("Null pointer to population structure passed.");
  //if ( !putative || !tabu ) die("Null pointer to entity structure passed.");

  //for (i=0; i< 1/* pop->num_chromosomes */; i++)
  //{
  a = (double*) (putative->CH);
  b = (double*) (    tabu->CH);

  for (j = 0; j < pop->len_chromosomes; j++)
    if (a[j] < b[j]-TINY || a[j] > b[j]+TINY) return FALSE;
  //}

  return TRUE;
}
//------------------------------------------------------------------------------
//  synopsis:   Compares two solutions with bitstring chromosomes and
//		returns TRUE if, and only if, all alleles are exactly
//		the same.
//------------------------------------------------------------------------------
boolean 
ga_tabu_check_bitstring (population  *pop,
                         entity	     *putative,
                         entity	     *tabu)
{
  //int		i;		/* Loop variable over chromosomes. */
  int		j;		/* Loop variable over alleles.     */
  gaulbyte	*a, *b;         /* Comparison bitstrings.          */

  /* Checks. */
  //if ( !pop ) die("Null pointer to population structure passed.");
  //if ( !putative || !tabu ) die("Null pointer to entity structure passed.");

  //for (i=0; i< 1/* pop->num_chromosomes */; i++)
  //{
  a = (gaulbyte*) (putative->CH);
  b = (gaulbyte*) (    tabu->CH);

  for (j = 0; j < pop->len_chromosomes; j++) {
    if (ga_bit_get (a, 0/* i */ ) != ga_bit_get (b, 0/* i */)) 
      return FALSE; // i или j ??? 
  }
  //}

  return TRUE;
}
//------------------------------------------------------------------------------
//  synopsis:   Checks the tabu list verses the putative solutions and
//		chooses an acceptable solution.  Returns -1 if all
//		putative solutions are tabu.
//------------------------------------------------------------------------------
int 
gaul_check_tabu_list (population  *pop,
                      entity	  **putative,
                      entity	  **tabu)
{
  int	    i;		/* Loop variable over putative solutions. */
  int	    j;		/* Loop variable over tabu list.          */
  boolean   is_tabu;	/* Whether current solution is tabu.      */

  entity    *t;

  for (i = 0; i < pop->tabu_params->search_count; i++)
  {
    is_tabu = FALSE;

    //for (j = 0; j < pop->tabu_params->list_length && tabu[j] != NULL && is_tabu == FALSE; j++)
    for (j = 0; ; j++)
    {
      t = tabu[j];

      //printf ("gaul_check_tabu_list: t = \n");

      if (j >= pop->tabu_params->list_length) break;
      if (t ==  NULL) break;
      if (is_tabu != FALSE) break;

      is_tabu = pop->tabu_params->tabu_accept (pop, putative[i], t);
    }



    if (is_tabu == FALSE)
    {	/* This solution is not tabu. */
      return i;
    }
  }

  // All solutions are tabu.
  // 
  return -1;
}
//------------------------------------------------------------------------------
//  synopsis:     Sets the tabu-search parameters for a population.
//------------------------------------------------------------------------------
void 
ga_population_set_tabu_parameters (population    *pop,
                                   GAtabu_accept  tabu_accept,
                                   const int      list_length,
                                   const int      search_count)
{

  if (! pop )         die ("Null pointer to population structure passed.");
  if (! tabu_accept)  die ("Null pointer to GAtabu_accept callback passed.");

  if (is_print) {
    printf ("> \n");
    printf ("> Population's tabu-search parameters: list_length = %d search_count = %d \n",
            list_length, search_count );
  }

  if (pop->tabu_params == NULL)
  {
    if (! (pop->tabu_params = s_malloc(sizeof(ga_tabu_t))) )
      die ("Unable to allocate memory");
  }

  pop->tabu_params->tabu_accept  = tabu_accept;
  pop->tabu_params->list_length  = list_length;
  pop->tabu_params->search_count = search_count;

  return;
}
//------------------------------------------------------------------------------
void update_tabu_list (population *pop,
                       entity	**tabu_list,    
                       entity    *best, 
                       int    *p_tabu_list_pos 
                       )
{

  int  tabu_list_pos =  *p_tabu_list_pos;

  if (tabu_list[tabu_list_pos] == NULL)
  {
    tabu_list[tabu_list_pos] = ga_entity_clone (pop, best);
  }
  else
  {
    ga_entity_blank (pop, tabu_list[tabu_list_pos]);
    ga_entity_copy  (pop, tabu_list[tabu_list_pos], best);
  }
  tabu_list_pos++;
  
  if (tabu_list_pos >= pop->tabu_params->list_length)
    tabu_list_pos = 0;
  
  *p_tabu_list_pos = tabu_list_pos;
  
  return;
}
//------------------------------------------------------------------------------
entity *
swap_putative_to_index (entity   *best,
                    entity  **putative, int index
                    )
{

  entity   *tmp; 

  tmp = best;
  best = putative[index];
  putative[index] = tmp;

  return (best);
}
//------------------------------------------------------------------------------
//  synopsis:	Performs optimisation on the passed entity by using a
//  		simplistic tabu-search.  The local search and fitness
//	       	evaluations are performed using the standard mutation
//	       	and evaluation callback mechanisms, respectively.
//		The passed entity will have its data overwritten.  The
//		remainder of the population will be let untouched.
//		Note that it is safe to pass a NULL initial structure,
//		in which case a random starting structure wil be
//		generated, however the final solution will not be
//		available to the caller in any obvious way.
//------------------------------------------------------------------------------
int 
ga_tabu (population	*pop,
         entity		*initial,
         const int	 max_iterations )
{
  int		iteration = 0;		/* Current iteration number.           */
  int		i, j;			/* Index into putative solution array. */
  entity	*best;			/* Current best solution.              */
  entity	**putative;		/* Current working solutions.          */
  //entity	*tmp;			/* Used to swap working solutions.     */
  entity	**tabu_list;		/* Tabu list.                          */
  int		tabu_list_pos = 0;	/* Index into the tabu list.           */

  if (is_print) {
    printf ("> \n");
    printf ("> ga_tabu ..................................................... \n");
    printf ("> \n");
  }

  // Checks.
  if (!pop)              die ("NULL pointer to population structure passed.");
  if (!pop->evaluate)    die ("Population's evaluation callback is undefined.");
  if (!pop->mutate)      die ("Population's mutation callback is undefined.");
  if (!pop->rank)        die ("Population's ranking callback is undefined.");
  if (!pop->tabu_params) die ("ga_population_set_tabu_params(), or similar, must be used prior to ga_tabu().");
  if (!pop->tabu_params->tabu_accept) die ("Population's tabu acceptance callback is undefined.");
  

  // Prepare working entities. 

  best = ga_get_free_entity (pop);   // The best solution so far.

  if (! (putative = s_malloc (sizeof(entity *) * pop->tabu_params->search_count)))
    die ("Unable to allocate memory");

  for (i = 0; i < pop->tabu_params->search_count; i++)
  {
    putative[i] = ga_get_free_entity (pop);    // The 'working' solutions.
  }
  
  // Allocate and clear an array for the tabu list.
  if (! (tabu_list = s_malloc (sizeof(vpointer) * pop->tabu_params->list_length)))
    die ("Unable to allocate memory");
  
  for (i = 0; i < pop->tabu_params->list_length; i++)
  {
    tabu_list[i] = NULL;
  }
  
  // Do we need to generate a random starting solution?
  if (! initial)
  {
    if (is_print)
      printf ("> Will perform tabu-search with random starting solution. \n");
    
    initial = ga_get_free_entity (pop);
    ga_entity_seed (pop, best);
  }
  else
  {   
    if (is_print) 
       printf ("> Will perform tabu-search with specified starting solution. \n");

    ga_entity_copy (pop, best, initial);
  }
  
  //
  // Ensure that initial solution is scored.
  //
  if (best->fitness == GA_MIN_FITNESS) pop->evaluate (pop, best);

  if (is_print) {
    printf ("> \n");
    printf ("> Prior to the first iteration, the current solution has fitness score of %f \n",
            best->fitness );

    pop_print (pop);
  }
  
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  //
  // Do all the iterations:
  //
  // Stop when (a) max_iterations reached, or
  //           (b) "pop->iteration_hook" returns FALSE.
  //
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  while (1)
  {

    if (is_print) {
      printf ("> \n");
      printf ("> ITERATION LOOP ......... iteration = %d (%d) \n", 
              iteration, max_iterations);
    } else {

      //  pop->generation_hook?pop->generation_hook(generation, pop):TRUE; // печать через 10
      pop->iteration_hook?pop->iteration_hook (iteration, best):TRUE ;
    }

    if (iteration >= max_iterations) break;

    iteration++;
    
    // 
    // Generate and score new solutions.
    //
    for (i = 0; i < pop->tabu_params->search_count; i++)
    {
      pop->mutate  (pop, best, putative[i]);
      pop->evaluate(pop, putative[i]);
    }
    
/*     if (is_print) { */
/*       printf ("\n"); */
/*       printf ("After MUTATE and EVALUATE:  \n"); */
/*       printf ("\n"); */
/*       pop_print (pop); */
/*     } */

    //
    // Sort new solutions (putative[0] will have highest rank).
    // We assume that there are only a small(ish) number of
    // solutions and, therefore, a simple bubble sort is adequate.
    //
    for (i = 1; i < pop->tabu_params->search_count; i++)
    {
      for (j = pop->tabu_params->search_count-1; j >= i; j--)
      {
        
        //printf ("i = %d  j = %d \n", i, j);
        
        if (pop->rank (pop, putative[j], pop, putative[j-1]) > 0 )
        {	
          // Perform a swap.
          putative[j] = swap_putative_to_index (putative[j], putative, j-1);
        }
      }
    }
    
/*     if (is_print) { */
/*       printf ("\n"); */
/*       printf ("POP_PRINT 11111111111 :  \n"); */
/*       printf ("\n"); */
/*       pop_print (pop); */
/*     } */
    //
    // Save best solution if it is an improvement, otherwise
    // select the best non-tabu solution (if any).
    // If appropriate, update the tabu list.
    //
    if (pop->rank (pop, putative[0], pop, best) > 0 )
    {
      best = swap_putative_to_index (best, putative, 0);
      update_tabu_list (pop, tabu_list, best, &tabu_list_pos);
    }
    else
    {
      if (-1 < (j = gaul_check_tabu_list (pop, putative, tabu_list)))
      {
        best = swap_putative_to_index (best, putative, j);
        update_tabu_list (pop, tabu_list, best, &tabu_list_pos);

        //printf ("111111111111111111111111111111111111111 j = %d \n", j);
        //list_print ("best = %d \n", j);
      }
    }
    
    if (is_print) {
      printf ("\n");
      printf ("POP_PRINT 222222222 :  \n");
      printf ("\n");
      pop_print (pop);
    }

    // Save the current best solution in the initial entity, if this
    // is now the best found so far.
    //
    if (pop->rank (pop, best, pop, initial) > 0)
    {
      ga_entity_blank (pop, initial);
      ga_entity_copy  (pop, initial, best);
    }
    
    if (is_print) {
      printf ("\n");
      printf ("POP_PRINT 333333333 :  \n");
      printf ("\n");
      pop_print (pop);
    }

    // Use the iteration callback.
    //
    if (is_print) 
      printf ("> After iteration %d, the current solution has fitness score of %f \n",
              iteration,
              best->fitness);

    
  }   // Iteration loop. 
  //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 

    if (is_print) {
      printf ("\n");
      printf ("BEFORE CLEANUP: \n");
      printf ("\n");

        pop_print (pop);
    }

  //
  // Cleanup.
  //
 
  ga_entity_dereference (pop, best);
  
  for (i = 0; i < pop->tabu_params->search_count; i++)
  {
    ga_entity_dereference (pop, putative[i]);
  }
  
  entity *t;

  if (1) {
  for (i = 0; i < pop->tabu_params->list_length; i++)
  {
    //fprintf (stderr, "tabu_list: i= %2d  ", i);

    t = tabu_list[i];
    //ent_print

    if (t != NULL) {
      ga_entity_dereference (pop, t);
    } else {
      //fprintf (stderr, "t= NULL ");
    }

    //fprintf (stderr, "\n");
  }
  }
  
    if (is_print) {
      printf ("\n");
      printf ("AFTER  CLEANUP: \n");
      printf ("\n");

        pop_print (pop);
    }

  s_free (putative);
  s_free (tabu_list);
  
  return iteration;
}
//******************************************************************************
  //
//------------------------------------------------------------------------------
  
  
