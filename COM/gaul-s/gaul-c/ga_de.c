//------------------------------------------------------------------------------
// 
//------------------------------------------------------------------------------

/**********************************************************************
  ga_de.c
 **********************************************************************

  ga_de - Differential Evolution.
  Copyright б╘2005, Stewart Adcock <stewart@linux-domain.com>
  All rights reserved.

  Synopsis:     Differential Evolution.

		The DE algorithm was originally conceived by Rainer
		Storn and Ken Price.  The GAUL implementation is
		based in part on their "de36.c" reference source code.
		See http://www.icsi.berkeley.edu/~storn/code.html

		You may notice that this code includes equivalents of
		all of the original DE strategies along with a
		selection of additional strateties.

 **********************************************************************/

//#include "ga_de.h"
#include "gaul.h"


/**********************************************************************
  synopsis:     Sets the differential evolution parameters for a
		population.
  parameters:	population *pop		Population to set parameters of.
		const GAcompare		Callback to compare two entities.
  return:	none
 **********************************************************************/
void 
ga_population_set_differentialevolution_parameters (population *pop,
                                                    const ga_de_strategy_type strategy,
                                                    const ga_de_crossover_type crossover,
                                                    const int num_perturbed,
                                                    const double weighting_min,
                                                    const double weighting_max,
                                                    const double crossover_factor)
{

  if ( !pop ) die("Null pointer to population structure passed.");

  plog( LOG_VERBOSE, "Population's differential evolution parameters set" );

  if (pop->de_params == NULL)
  {
    if ( !(pop->de_params = s_malloc(sizeof(ga_de_t))) )
      die("Unable to allocate memory");
  }

  pop->de_params->strategy         = strategy;
  pop->de_params->crossover_method = crossover;
  pop->de_params->num_perturbed    = num_perturbed;
  pop->de_params->weighting_min    = weighting_min;
  pop->de_params->weighting_max    = weighting_max;
  pop->de_params->crossover_factor = crossover_factor;

  return;
}
//------------------------------------------------------------------------------
/*  Pick an number of random entities by moving their index to the            */
/*  beginning of the permutation array.                                       */
/*  This method is a lot more efficient than the original algorithm's         */
/*  approach - especially for small population sizes.                         */
//------------------------------------------------------------------------------
void 
_gaul_pick_random_entities (int *permutation, int num, int size, int avoid)
{
  int		j;		/* Loop variable over picked numbers. */
  int		pos, tmp;	/* Current indices. */

  for (j = 0; j < num; j++)
  {

    do
    {
      pos = j + random_int (size - j);
    } while (permutation[pos] == avoid);

    tmp = permutation[j];
    permutation[j]   = permutation[pos];
    permutation[pos] = tmp;
  }

  return;
}
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
void calc_tmpentity_11 (population *pop, entity *tmpentity, int n, int i0, 
                        int *perm, double weighting_factor) 
{
  
  if (is_print) {
    printf ("  calc_tmpentity_11 .. n= %d ", n);
  }

  int p0 = perm[0];
  int p1 = perm[1];

  entity *e1 = pop->entity_iarray[p0];
  entity *e2 = pop->entity_iarray[p1];

  //double g1 = ((double *) pop->entity_iarray[p0]->CH)[n];
  //double g2 = ((double *) pop->entity_iarray[p1]->CH)[n];

  double g1 = ((double *) e1->CH)[n];
  double g2 = ((double *) e2->CH)[n];

  double diff = g1 - g2;

  
  double n_gen = ((double *)pop->entity_iarray[i0]->CH)[n];

  double   gen = n_gen + weighting_factor * diff;

  if (is_print) {
    print_ch (e1, "  e1= ", pop->len_chromosomes);
    printf ("  g1= %f ", g1);   
    printf ("\n");
  }

  ((double *)tmpentity->CH)[n] = gen;


  return;
}
//------------------------------------------------------------------------------
void calc_tmpentity2 (population  *pop, int n, int best, 
                    entity	*tmpentity, int	*permutation, double weighting_factor) 
{
  
  calc_tmpentity_11 (pop, tmpentity, n, 
                             best, &permutation[0], weighting_factor);

  return;
}
//------------------------------------------------------------------------------
void calc_tmpentity3 (population  *pop, int n, int best, 
                    entity	*tmpentity, int	*permutation, double weighting_factor) 
{
  
  calc_tmpentity_11 (pop, tmpentity, n, 
                             permutation[0], &permutation[1], weighting_factor);

  return;
}
//------------------------------------------------------------------------------
void calc_tmpentity_22 (population *pop, entity *tmpentity, int n, int i0, 
                        int *perm, double weighting_factor) 
{
  
  double diff = (((double *) pop->entity_iarray[perm[0]]->CH)[n]
               + ((double *) pop->entity_iarray[perm[1]]->CH)[n]
               - ((double *) pop->entity_iarray[perm[2]]->CH)[n]
               - ((double *) pop->entity_iarray[perm[3]]->CH)[n]);

  ((double *)tmpentity->CH)[n] =
    ((double *)pop->entity_iarray[i0]->CH)[n] + weighting_factor * diff;

  return;
}
//------------------------------------------------------------------------------
void calc_tmpentity4 (population  *pop, int n, int best, 
                    entity	*tmpentity, int	*permutation, double weighting_factor) 
{

  calc_tmpentity_22 (pop, tmpentity, n, 
                             best, &permutation[0], weighting_factor);

  return;
}
//------------------------------------------------------------------------------
void calc_tmpentity5 (population  *pop, int n, int best, 
                    entity	*tmpentity, int	*permutation, double weighting_factor) 
{

  calc_tmpentity_22 (pop, tmpentity, n, 
                             permutation[0], &permutation[1], weighting_factor);

  return;
}
//------------------------------------------------------------------------------
void calc_tmpentity_33 (population *pop, entity *tmpentity, int n, int i0, 
                        int *perm, double weighting_factor) 
{
  
  double diff = (((double *) pop->entity_iarray [perm[0]]->CH)[n]
               + ((double *) pop->entity_iarray [perm[1]]->CH)[n]
               + ((double *) pop->entity_iarray [perm[2]]->CH)[n]
               - ((double *) pop->entity_iarray [perm[3]]->CH)[n]
               - ((double *) pop->entity_iarray [perm[4]]->CH)[n]
               - ((double *) pop->entity_iarray [perm[5]]->CH)[n]);

  ((double *)tmpentity->CH)[n] = 
    ((double *) pop->entity_iarray[i0]->CH)[n] + weighting_factor * diff;

  return;
}
//------------------------------------------------------------------------------
void calc_tmpentity6 (population  *pop, int n, int best, 
                    entity	*tmpentity, int	*permutation, double weighting_factor) 
{
  
  calc_tmpentity_33 (pop, tmpentity, n, 
                             best, &permutation[0], weighting_factor);

  return;
}
//------------------------------------------------------------------------------
void calc_tmpentity7 (population  *pop, int n, int best, 
                    entity  *tmpentity, int *permutation, double weighting_factor) 
{

  calc_tmpentity_33 (pop, tmpentity, n, 
                             permutation[0], &permutation[1], weighting_factor);

  return;
}
//------------------------------------------------------------------------------
void calc_tmpentity_1bin (population  *pop, int n, int best, 
                      entity *tmpentity, int *permutation, double weighting_factor) 
{

  double diff = (((double *)pop->entity_iarray[best]->CH)[n]
               - ((double *)tmpentity->CH)[n]
               + ((double *)pop->entity_iarray[permutation[0]]->CH)[n]
               - ((double *)pop->entity_iarray[permutation[1]]->CH)[n]);

  ((double *) tmpentity->CH)[n] += weighting_factor * diff;
 
}
//------------------------------------------------------------------------------
void calc_tmpentity_2bin (population  *pop, int n, int best, 
                      entity *tmpentity, int *permutation, double weighting_factor) 
{

  double diff = (((double *)pop->entity_iarray[best]->CH)[n]
               - ((double *)tmpentity->CH)[n]
               + ((double *)pop->entity_iarray[permutation[0]]->CH)[n]
               + ((double *)pop->entity_iarray[permutation[1]]->CH)[n]
               - ((double *)pop->entity_iarray[permutation[2]]->CH)[n]
               - ((double *)pop->entity_iarray[permutation[3]]->CH)[n]);

  ((double *)tmpentity->CH)[n] += weighting_factor * diff;

}
//------------------------------------------------------------------------------
void intarray_print (char *name, int *arr, int n) {
  
  int i;

  fprintf (stderr, "%s ", name);

  for (i = 0; i < n; i++) {
    fprintf (stderr, "%d ", arr[i]);
  }

  fprintf (stderr, "\n");

}
//------------------------------------------------------------------------------
void DE_best_1_exp (population  *pop, int i, int n, int best, 
                    entity	*tmpentity, int	*permutation, double weighting_factor)
{

  int L/* , flag1, flag2 */, flag;  
  int  len_chromosomes = pop->len_chromosomes; /* Maximum length of each chromosome. */

  _gaul_pick_random_entities (permutation, 2, pop->orig_size, i);
      
  L = 0;

  while (1)
  {
    //if (! (L < len_chromosomes)) break;

    calc_tmpentity2 (pop, n, best, tmpentity, permutation, weighting_factor); 

    //flag = random_boolean_prob (pop->de_params->crossover_factor);
    //if (! flag) break; // вообще заканчиваем цикл ! и выходим

    n = (n+1) % len_chromosomes;
    L++;

    flag = random_boolean_prob (pop->de_params->crossover_factor);
    if (! flag) break; // вообще заканчиваем цикл ! и выходим

    if (! (L < len_chromosomes)) break;
  };

  return;
}
//------------------------------------------------------------------------------
void DE_best_2_exp (population  *pop, int i, int n, int best, 
                    entity *tmpentity, int *permutation, double weighting_factor)
{

  int L, flag;  
  int  len_chromosomes = pop->len_chromosomes; /* Maximum length of each chromosome. */

  _gaul_pick_random_entities (permutation, 4, pop->orig_size, i);
      
  L = 0;

  while (1)
  {
    calc_tmpentity4 (pop, n, best, tmpentity, permutation, weighting_factor); 

    n = (n+1) % len_chromosomes;
    L++;


    flag = random_boolean_prob (pop->de_params->crossover_factor);
    if (! flag) break; // вообще заканчиваем цикл ! и выходим

    if (! (L < len_chromosomes)) break;
  };
  

  return;
}
//------------------------------------------------------------------------------
void DE_best_3_exp (population  *pop, int i, int n, int best, 
                    entity *tmpentity, int *permutation, double weighting_factor)
{

  int L, flag;  
  int  len_chromosomes = pop->len_chromosomes; /* Maximum length of each chromosome. */

  _gaul_pick_random_entities (permutation, 6, pop->orig_size, i);
  
  L = 0;

  while (1)
  {
    calc_tmpentity6 (pop, n, best, tmpentity, permutation, weighting_factor); 

    n = (n+1) % len_chromosomes;
    L++;

    flag = random_boolean_prob (pop->de_params->crossover_factor);
    if (! flag) break; // вообще заканчиваем цикл ! и выходим

    if (! (L < len_chromosomes)) break;
  };
  
  
  return;
}
//------------------------------------------------------------------------------
void DE_rand_1_exp (population  *pop, int i, int n, int best, 
                    entity *tmpentity, int *permutation, double weighting_factor)
{

  int L, flag;  
  int  len_chromosomes = pop->len_chromosomes; /* Maximum length of each chromosome. */

  _gaul_pick_random_entities (permutation, 3, pop->orig_size, i);
  
  L = 0;

  while (1)
  {
    calc_tmpentity3 (pop, n, best, tmpentity, permutation, weighting_factor); 

    n = (n+1) % len_chromosomes;
    L++;

    flag = random_boolean_prob (pop->de_params->crossover_factor);
    if (! flag) break; // вообще заканчиваем цикл ! и выходим

    if (! (L < len_chromosomes)) break;
  };
  
  //} while (random_boolean_prob (pop->de_params->crossover_factor) && (L < pop->len_chromosomes));
  
  return;
}
//------------------------------------------------------------------------------
void DE_rand_2_exp (population  *pop, int i, int n, int best, 
                    entity *tmpentity, int *permutation, double weighting_factor)
{

  int L, flag;  
  int  len_chromosomes = pop->len_chromosomes; /* Maximum length of each chromosome. */
      
  _gaul_pick_random_entities(permutation, 5, pop->orig_size, i);
  
  L = 0;

  while (1) 
  {
    calc_tmpentity5 (pop, n, best, tmpentity, permutation, weighting_factor); 

    n = (n+1) % len_chromosomes;
    L++;

    flag = random_boolean_prob (pop->de_params->crossover_factor);
    if (! flag) break; // вообще заканчиваем цикл ! и выходим

    if (! (L < len_chromosomes)) break;
  } ;
  
  //} while (random_boolean_prob (pop->de_params->crossover_factor) && (L < pop->len_chromosomes));
  
  return;
}
//------------------------------------------------------------------------------
void DE_rand_3_exp (population  *pop, int i, int n, int best, 
                    entity *tmpentity, int *permutation, double weighting_factor)
{

  int  L, flag;  
  int  len_chromosomes = pop->len_chromosomes; /* Maximum length of each chromosome. */

     
  _gaul_pick_random_entities(permutation, 7, pop->orig_size, i);
      
  L = 0;
  
  while (1)
  {
    calc_tmpentity7 (pop, n, best, tmpentity, permutation, weighting_factor); 

    n = (n+1) % len_chromosomes;
    L++;

    flag = random_boolean_prob (pop->de_params->crossover_factor);
    if (! flag) break; // вообще заканчиваем цикл ! и выходим

    if (! (L < len_chromosomes)) break;
  } ;
  
  
  return;
}
//------------------------------------------------------------------------------
void DE_randtobest_1_exp (population  *pop, int i, int n, int best, 
                          entity  *tmpentity, int *permutation, double weighting_factor)
{
  
  int  L, flag;  /* Allele indice */
  int  len_chromosomes = pop->len_chromosomes; /* Maximum length of each chromosome. */

  
  _gaul_pick_random_entities(permutation, 2, pop->orig_size, i);
  
  L = 0;

  while (1)
  {    
    calc_tmpentity_1bin (pop, n, best, 
                         tmpentity, permutation, weighting_factor);

    n = (n+1) % len_chromosomes;
    L++;

    flag = random_boolean_prob (pop->de_params->crossover_factor);
    if (! flag) break; // вообще заканчиваем цикл ! и выходим

    if (! (L < len_chromosomes)) break;
  } ;
  
  
  return;
}
//------------------------------------------------------------------------------
void DE_randtobest_2_exp (population  *pop, int i, int n, int best, 
                          entity  *tmpentity, int *permutation, double weighting_factor)
{
  
  int  L, flag;  /* Allele indice */
  int  len_chromosomes = pop->len_chromosomes; /* Maximum length of each chromosome. */
  
  _gaul_pick_random_entities(permutation, 4, pop->orig_size, i);
      
  L = 0;

  while (1)
  {
    
    calc_tmpentity_2bin (pop, n, best, 
                         tmpentity, permutation, weighting_factor);

    n = (n+1) % pop->len_chromosomes;
    L++;

    flag = random_boolean_prob (pop->de_params->crossover_factor);
    if (! flag) break; // вообще заканчиваем цикл ! и выходим

    if (! (L < len_chromosomes)) break;
  } ;
  

  return;
}
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
void DE_best_1_bin (population  *pop, int i, int n, int best, 
                entity	*tmpentity, int	*permutation, double weighting_factor)
{

  int L, flag;  
  int  len_chromosomes = pop->len_chromosomes; /* Maximum length of each chromosome. */

  //intarray_print ("  permutation before =", permutation, 6);
  _gaul_pick_random_entities (permutation, 2, pop->orig_size, i);
  //intarray_print ("  permutation after  =", permutation, 6);
    
  
  calc_tmpentity2 (pop, n, best, tmpentity, permutation, weighting_factor); 

  //for (L=1; L<pop->len_chromosomes; L++)

  L = 1 ;

  while (1)
  {

    if (! (L < len_chromosomes)) break;

    flag = random_boolean ();
    if (flag) {
      calc_tmpentity2 (pop, n, best, tmpentity, permutation, weighting_factor); 
    }
    // а здесь не заканчиваем, но продолжаем!

    n = (n+1) % len_chromosomes;
    L++;
  }
 
  return;
}
//------------------------------------------------------------------------------
void DE_best_2_bin (population  *pop, int i, int n, int best, 
                    entity	*tmpentity, int	*permutation, double weighting_factor)
{
  
  int L; 
  
  _gaul_pick_random_entities (permutation, 4, pop->orig_size, i);
  
  calc_tmpentity4 (pop, n, best, tmpentity, permutation, weighting_factor); 

  for (L = 1; L < pop->len_chromosomes; L++)
  {
    if (random_boolean ()) {
      calc_tmpentity4 (pop, n, best, tmpentity, permutation, weighting_factor); 
    }

    n = (n+1) % pop->len_chromosomes;
  }
  
}
//------------------------------------------------------------------------------
void DE_best_3_bin (population  *pop, int i, int n, int best, 
                    entity	*tmpentity, int	*permutation, double weighting_factor)
{
  
  int L;  
  
  _gaul_pick_random_entities (permutation, 6, pop->orig_size, i);
  
  calc_tmpentity6 (pop, n, best, tmpentity, permutation, weighting_factor); 

  for (L=1; L<pop->len_chromosomes; L++)
  {
    if (random_boolean()) {
      calc_tmpentity6 (pop, n, best, tmpentity, permutation, weighting_factor); 
    }
    
    n = (n+1)%pop->len_chromosomes;
  }
  
}
//------------------------------------------------------------------------------
void DE_rand_1_bin (population  *pop, int i, int n, int best, 
                    entity	*tmpentity, int	*permutation, double weighting_factor)
{
  
  int L;  /* Allele indice */
  
  _gaul_pick_random_entities (permutation, 3, pop->orig_size, i);
  
  calc_tmpentity3 (pop, n, best, tmpentity, permutation, weighting_factor); 

  for (L=1; L<pop->len_chromosomes; L++)
  {
    if (random_boolean()) {
      calc_tmpentity3 (pop, n, best, tmpentity, permutation, weighting_factor); 
    }

    n = (n+1)%pop->len_chromosomes;
  }
  

  return;
}
//------------------------------------------------------------------------------
void DE_rand_2_bin (population  *pop, int i, int n, int best, 
                    entity	*tmpentity, int	*permutation, double weighting_factor)
{
  
  int L;  /* Allele indice */
  
  _gaul_pick_random_entities(permutation, 5, pop->orig_size, i);
      
  calc_tmpentity5 (pop, n, best, tmpentity, permutation, weighting_factor); 

  for (L=1; L<pop->len_chromosomes; L++)
  {
    if (random_boolean()) {
      calc_tmpentity5 (pop, n, best, tmpentity, permutation, weighting_factor); 
    }

    n = (n+1)%pop->len_chromosomes;
  }
  
}
//------------------------------------------------------------------------------
void DE_rand_3_bin (population  *pop, int i, int n, int best, 
                    entity	*tmpentity, int	*permutation, double weighting_factor)
{
  
  int L;  /* Allele indice */
  
  _gaul_pick_random_entities(permutation, 7, pop->orig_size, i);
  
  calc_tmpentity7 (pop, n, best, tmpentity, permutation, weighting_factor); 
  
  for (L=1; L<pop->len_chromosomes; L++)
  {
    if (random_boolean ()) {
      calc_tmpentity7 (pop, n, best, tmpentity, permutation, weighting_factor); 
    }

    n = (n+1) % pop->len_chromosomes;
  }
  

}
//------------------------------------------------------------------------------
void DE_randtobest_1_bin (population  *pop, int i, int n, int best, 
                    entity	*tmpentity, int	*permutation, double weighting_factor)
{
  
  int L;  /* Allele indice */
  
  _gaul_pick_random_entities(permutation, 2, pop->orig_size, i);
  
  calc_tmpentity_1bin (pop, n, best, 
                       tmpentity, permutation, weighting_factor);

  for (L=1; L<pop->len_chromosomes; L++)
  {
    if (random_boolean ())
      calc_tmpentity_1bin (pop, n, best, 
                           tmpentity, permutation, weighting_factor);

    n = (n+1) % pop->len_chromosomes;
  }
  

}
//------------------------------------------------------------------------------
void DE_randtobest_2_bin (population  *pop, int i, int n, int best, 
                    entity	*tmpentity, int	*permutation, double weighting_factor)
{
  
  int L;  /* Allele indice */
  
  _gaul_pick_random_entities(permutation, 4, pop->orig_size, i);
  
  calc_tmpentity_2bin (pop, n, best, 
                       tmpentity, permutation, weighting_factor);

  
  for (L=1; L < pop->len_chromosomes; L++)
  {
    if ( random_boolean() )
      calc_tmpentity_2bin (pop, n, best, 
                           tmpentity, permutation, weighting_factor);

    n = (n+1)%pop->len_chromosomes;
  }

}
//------------------------------------------------------------------------------
void ga_de_crossover_binomial (population  *pop, int i, int n, int best, 
                               entity	*tmpentity, int	*permutation, double weighting_factor)
{

  //int L;  /* Allele indice */

  if (pop->de_params->strategy == GA_DE_STRATEGY_BEST)
  {
    if      (pop->de_params->num_perturbed == 1)
    {       
      DE_best_1_bin (pop, i, n, best, tmpentity, permutation, weighting_factor);      
    }
    else if (pop->de_params->num_perturbed == 2)
    {       
      DE_best_2_bin (pop, i, n, best, tmpentity, permutation, weighting_factor);      
    }
    else if (pop->de_params->num_perturbed == 3)
    {      
      DE_best_3_bin (pop, i, n, best, tmpentity, permutation, weighting_factor);
          }
    else
    {
      die("Invalid differential evolution selection number.");
    }
  }
  else if (pop->de_params->strategy == GA_DE_STRATEGY_RAND)
  {
    if (pop->de_params->num_perturbed == 1)
    {
      DE_rand_1_bin (pop, i, n, best, tmpentity, permutation, weighting_factor);      
    }
    else if (pop->de_params->num_perturbed == 2)
    { 
      DE_rand_2_bin (pop, i, n, best, tmpentity, permutation, weighting_factor);      
    }
    else if (pop->de_params->num_perturbed == 3)
    { 
      DE_rand_3_bin (pop, i, n, best, tmpentity, permutation, weighting_factor);      
    }
    else
    {
      die("Invalid differential evolution selection number.");
    }
  }
  else if (pop->de_params->strategy == GA_DE_STRATEGY_RANDTOBEST)
  {
    if (pop->de_params->num_perturbed == 1)
    { 
      DE_randtobest_1_bin (pop, i, n, best, tmpentity, permutation, weighting_factor);      
    }
    else if (pop->de_params->num_perturbed == 2)
    { 
      DE_randtobest_2_bin (pop, i, n, best, tmpentity, permutation, weighting_factor);
    }

    else
    {
      die ("Invalid differential evolution selection number.");
    }
  }

  else
  {
    die ("Unknown differential evolution strategy.");
  }

}

//------------------------------------------------------------------------------
void ga_de_crossover_exponential (population  *pop, int i, int n, int best, 
                                  entity      *tmpentity, int *permutation, double weighting_factor)
{


  if (pop->de_params->strategy == GA_DE_STRATEGY_BEST)
  {
    if (pop->de_params->num_perturbed == 1)
    {       
      DE_best_1_exp (pop, i, n, best, tmpentity, permutation, weighting_factor);      
    }
    else if (pop->de_params->num_perturbed == 2)
    {       
      DE_best_2_exp (pop, i, n, best, tmpentity, permutation, weighting_factor);      
    }
    else if (pop->de_params->num_perturbed == 3)
    { 
      DE_best_3_exp (pop, i, n, best, tmpentity, permutation, weighting_factor);      
    }
    else
    {
      die("Invalid differential evolution selection number.");
    }
    
  }
  else if (pop->de_params->strategy == GA_DE_STRATEGY_RAND)
  {
    if (pop->de_params->num_perturbed == 1)
    {       
     DE_rand_1_exp (pop, i, n, best, tmpentity, permutation, weighting_factor);         
    }
    else if (pop->de_params->num_perturbed == 2)
    { 
     DE_rand_2_exp (pop, i, n, best, tmpentity, permutation, weighting_factor);           
    }
    else if (pop->de_params->num_perturbed == 3)
    {       
     DE_rand_3_exp (pop, i, n, best, tmpentity, permutation, weighting_factor);                 
    }
    else
    {
      die("Invalid differential evolution selection number.");
    }
    
  }
  else if (pop->de_params->strategy == GA_DE_STRATEGY_RANDTOBEST)
  {
    if (pop->de_params->num_perturbed == 1)
    {       
     DE_randtobest_1_exp (pop, i, n, best, tmpentity, permutation, weighting_factor);        
    }
    else if (pop->de_params->num_perturbed == 2)
    {       
     DE_randtobest_2_exp (pop, i, n, best, tmpentity, permutation, weighting_factor);            
    }
    else
    {
      die ("Invalid differential evolution selection number.");
    }
    
  }
  else
  {
    die ("Unknown differential evolution strategy.");
  }
  
  
}
//------------------------------------------------------------------------------
int find_best_solution (population  *pop) {

  int  	i;    	/* Loop variable over entities. */
  int  	best;  	/* Index of best entity. */

  best = 0;

  int i0 = 0; // 1 -было ?!
  // 
  // а почему с 1-го а не с 0-го ищем?
  // 

  if (pop->rank == ga_rank_fitness)
  {
    for (i = i0; i<pop->size; i++)
    {
      if (pop->entity_iarray[i]->fitness > pop->entity_iarray[best]->fitness)
        best = i;
    }

  } else {

    for (i = i0; i<pop->size; i++)
    {
      if ( pop->rank(pop, pop->entity_iarray[i],
                     pop, pop->entity_iarray[best]) > 0 )
        best = i;
    }
  }
  
  //$pop configure -best $best ;# и занесем сразу номер лучшего элемента
  pop->best = best;

  return (best);
}
//------------------------------------------------------------------------------
//  synopsis:	Performs differential evolution. 
//------------------------------------------------------------------------------
void print_entit (entity *entity, char *name, int len_chromo) {


  printf ("  ");
  print_ch (entity , name, len_chromo);
  printf ("\n");

}
//------------------------------------------------------------------------------
int * 
prepare_permutation (size) {

  int i;
  int *permutation;   /* Permutation array for random selections. */

  if (is_print) {
    printf ("Prepare arrays to store permutations ... \n");
  }
    
  if ( !(permutation = s_malloc(sizeof(int) * size)) )
    die("Unable to allocate memory");

  for (i = 0; i < size; i++) {
    permutation[i] = i;
  }

  return (permutation);
}
//------------------------------------------------------------------------------
void
pop_eliminate (population *pop) {

  //
  // Eliminate the original population members.
  //

  while (pop->orig_size > 0)
  {
    pop->orig_size--;
    ga_entity_dereference_by_rank (pop, pop->orig_size);
  }

  return;
}
//------------------------------------------------------------------------------
GAULFUNC int ga_differentialevolution (population  *pop,
                                       const int  max_generations)
{
  int		generation = 0;		/* Current generation number. */

  int		i;			/* Loop variable over entities. */
  int		best;			/* Index of best entity. */
  int		*permutation;		/* Permutation array for random selections. */

  entity	*oldentity;		/* Old entity. */
  entity	*tmpentity;		/* New entity. */

  int		n;			/* Allele indices. */
  double	weighting_factor;	/* Weighting multiplier. */

  /* Checks. */
  if (!pop) die ("NULL pointer to population structure passed.");
  if (!pop->de_params) die ("ga_population_set_differentialevolution_params(), or similar, must be used prior to ga_differentialevolution().");

  if (!pop->evaluate)       die ("Population's evaluation callback is undefined.");
  if (!pop->rank)           die ("Population's ranking callback is undefined.");
  if (pop->stable_size < 6) die ("Population's stable size is too small.  (Must be at least 6)");

  if ( pop->de_params->crossover_factor < 0.0 ||
      pop->de_params->crossover_factor > 1.0 )
    die ("Invalid crossover_factor.");
  
  plog (LOG_VERBOSE, "The differential evolution has begun!");

  pop->generation = 0;

  
  /*
    * Score the initial population members.
    */
  if (pop->size < pop->stable_size) {
    gaul_population_fill (pop, pop->stable_size - pop->size);
  }

  if (pop->entity_iarray[0]->fitness == GA_MIN_FITNESS) {
    pop->evaluate (pop, pop->entity_iarray[0]);
  }

  /* #pragma omp parallel for \ */
  /*    shared(pop) private(i) \ */
  /*    schedule(static) */

  for (i=0; i<pop->size; i++)
  {
    if (pop->entity_iarray[i]->fitness == GA_MIN_FITNESS)
      pop->evaluate (pop, pop->entity_iarray[i]);
  }

  
  permutation = prepare_permutation (pop->size);
  
  //set rank_proc [$pop cget -rank]

  const double weighting_min = pop->de_params->weighting_min;
  const double weighting_max = pop->de_params->weighting_max;

  // ~~~~~~~~~~~~~~~~~~~~~~~ GENERATION LOOP BEGIN ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  /*
    * Do all the generations:
    *
    * Stop when (a) max_generations reached, or
    *           (b) "pop->generation_hook" returns FALSE.
    */

  while (1)
  {

    //permutation = prepare_permutation (pop->size);
  
    if (is_print) {
      printf ("\n");
      printf ("GENERATION LOOP ......... generation = %d \n", generation);
      printf ("\n");
    } else {

      pop->generation_hook?pop->generation_hook(generation, pop):TRUE; // печать через 10
      //pop->generation_hook (generation, pop); // печать через 10
    }

    if (generation >= max_generations) break;

    //pop->generation = generation;
    pop->orig_size  = pop->size;

    //plog (LOG_VERBOSE,
    //      "Population size is %d at start of generation %d",
    //      pop->orig_size, generation );


    //#
    //# Determine weighting factor. (на каждой генерации меняем весовой фактор ?)
    //# 
    //
    if (weighting_min == weighting_max) {
      weighting_factor = weighting_min;
    } else {
      weighting_factor = random_double_range (weighting_min, weighting_max);
    }

    //
    // Find best solution.
    //
    best = find_best_solution (pop);

    // if (generation >= max_generations) break; - почему-то не пошол тест
    // l_polynomial de: (а точнее не совпало)
    //
    //Final: A = 0.750233 B = 0.947633 C = 0.282777 D = 0.766159 (fitness = -0.000395)

    generation++; // зачем здесь сразу увеличивать то?
    pop->generation = generation;

    //plog (LOG_VERBOSE,
    //     "Best fitness is %f at start of generation %d",
    //     pop->entity_iarray[best]->fitness, generation );

    /* #pragma omp parallel for \ */
    /*    if (GAUL_DETERMINISTIC_OPENMP==0) \ */
    /*    shared(pop) private(i) \ */
    /*    schedule(static) */

    // ~~~~~~~~~~~~~~~~~ I LOOP BEGIN ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    //
    // цикл по каждому элементу I, для его корректировки

    for (i=0; i<pop->orig_size; i++)
    {

      if (is_print) {
        printf ( "\n");
        printf ( "i= %2d .................................... \n", i);
        printf ("\n");

        pop_print_lite (pop);
        printf ("\n");

      }

      oldentity = pop->entity_iarray[i];

      if (is_print) {
        print_entit (oldentity, "OLDENTITY =", pop->len_chromosomes);
      }


      // здесь зачем-то добавляется этот копируемый элемент в конец списка
      // а зачем ?? хотя скорее всего это не влияет на исход, но надо проверить
      // 
      tmpentity = ga_entity_clone (pop, pop->entity_iarray[i]);

      n = random_int (pop->len_chromosomes); //  случайный номер гена

      /*
        * Note that the following code may appear bloated due to excessive
        * extraction of branches from loops.
        * However, this yields much more efficient code (particularly for larger
        * chromosomes) on less-than-cutting-edge compilers.
        */

      if (is_print) {
        print_entit (tmpentity, "TMPENTITY =", pop->len_chromosomes);
      }
        
      //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      if (pop->de_params->crossover_method == GA_DE_CROSSOVER_BINOMIAL)
      {
        // GA_DE_CROSSOVER_BINOMIAL
        ga_de_crossover_binomial (pop, i, n, best, tmpentity, permutation, 
                                  weighting_factor);
      } else { 
        // GA_DE_CROSSOVER_EXPONENTIAL 
        ga_de_crossover_exponential (pop, i, n, best, tmpentity, permutation, 
                                     weighting_factor);
      } 
      //~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

      if (is_print) {
        print_entit (tmpentity, "TMPENTITY =", pop->len_chromosomes);
      }

      //
      // Evaluate new solution and restore the former chromosome values
      // if this new solution is not an improvement.
      //

      int is_worse;
      int is_edone = pop->evaluate (pop, tmpentity);

      if (! is_edone)  {
        printf ("\n");
        printf ("ERROR : not is_edone !!! \n");
        printf ("\n");

        exit (0);
      }


      double old_fit = oldentity->fitness;
      double new_fit = tmpentity->fitness;

      if (pop->rank == ga_rank_fitness) {
        is_worse = (pop->entity_iarray[i]->fitness > tmpentity->fitness);
      } else {
        is_worse = (pop->rank (pop, tmpentity, pop, pop->entity_iarray[i]) < 0 );
      }


      if (is_print) {
        printf ( "  n= %2d  old = %f .. new = %f ", n, old_fit, new_fit);
      }

      if (is_worse)         
      {
        // все только ухудшилось
        
        ga_entity_blank (pop, tmpentity); // очистить элемент, "обнулив" фитнес ? 
        ga_entity_copy  (pop, tmpentity, pop->entity_iarray[i]); 
                                         //  $tmpentity <- $oldentity
        if (is_print) printf ( "\n");
      } else {
        //
        // ничего не делаем, поскольку новый элемент в конце списка по указателю 
        // уже перезаписан;
        // 
       if (is_print)  printf ( " .... OK !! \n");
      }

    }
    // 
    // ~~~~~~~~~~~~~~~~~ I LOOP FINAL ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    if (is_print) {
      printf ( "\n");
      printf ( "I LOOP FINAL .........................................\n");
      printf ( "\n");

      printf ( "\n");
      pop_print (pop);
      printf ( "\n");

      printf ( "Eliminate the original population members ..... \n");
      }

    pop_eliminate (pop);

    if (is_print) {
      printf ( "\n");
      pop_print (pop);
      printf ( "\n");
    }

    /*
      * End of generation.
      */

    plog (LOG_VERBOSE,
         "After generation %d, population has fitness scores between %f and %f",
         generation,
         pop->entity_iarray[0]->fitness,
         pop->entity_iarray[pop->size-1]->fitness );

  }	/* Generation loop. */
  //
  //~~~~~~~~~~~~~~~~ GENERATION LOOP FINAL ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  /*
    * Ensure final ordering of population is correct.
    */
  sort_population (pop);

  if (is_print) {
    printf ( "\n");
    pop_print (pop);
    printf ( "\n");
  }

  /*
    * Clean-up.
    */
  s_free (permutation);

  return generation;
}
//******************************************************************************
//------------------------------------------------------------------------------


