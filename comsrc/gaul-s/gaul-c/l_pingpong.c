/*******************************************************************************
  pingpong_ALL.c

		This program aims to solve a problem proposed in:
		Dennis E. Shasha, "Dr Ecco's Omniheurist Corner: Foxy",
		Dr Dobb's Journal, 323:148-149 (2001).

*******************************************************************************/
//------------------------------------------------------------------------------
/*

Каждая команда состоит из 25 игроков, но для мини-соревнования, только 9 лучших
игроков будет заявлено.
Команда А - лучшая команда (в среднем), но команда В также имеет несколько 
замечательных игроков.

Предположим, мы пронумеруем в каждой команде игроков от 0 (лучший) до 24 (слабейший)
так что: A[0] - лучший игрок в команде A, B[0] - лучший игрок в команде B. 
Далее предположим, что игрок A[i] побеждает игрока B[i] на 2 очка для каждого i
от 0 до 24 включительно.
Однако, B[i] может побить A[i+1] (для каждого i от 0 до 23) на 2 очка.
И далее, согласно транзитивности, получаем диаграмму силы (через 2 очка) :

A[0] -> B[0] -> A[1] -> B[1] -> A[2] -> B[2] -> A[3] 

Тренер команды B (которая в среднем слабее) - знает всю эту схему. 
Тренер команды A - не в курсе!
Тренер B понимает, что его команда будет терять по 2 очка на каждой "правильной"
паре, т.е. B[0] -- A[0], B[1] -- A[1] и т. д. 
Соответственно, он хочет  организовать схему соревнования таким образом, чтобы 
выиграть больше игр, чем команда A, и при этом не разбудить подозрения у 
тренера A.
Тренер  A может стать подозрительным. если "average point spread" в играх, где 
игроки команды A выиграют - слишком велика или если "maximum point spread" в таких
играх  is too high.

Таким образом, ТренерB поставил перед собой задачу -  составить пары из своих игроков 
противигроков  команды A таким образом, чтобы игроки команды B не проигрывали больше 
10 очков и чтобы "average point spread" для игр где A побеждали - был не больше 7. 

Here is an example to show you how this would go: If there were just five 
players on each side, then ТренерB might pair up

Ateam		Bteam
0		4
1		0
2		1
3		2
4 	        3

which would enable B players to win by 2 points in every game except against 
A[0]. However, B[4] would then lose by 18 points. Foxy wouldn't choose this 
strategy because he would arouse the suspicions of ТренерА. Besides, 
he needs only a majority of games, not 4 out of 5."


Reader: First try to figure out a winning strategy for тренера B in the case of 
the mini-competition (nine players on each team) and then for the case of 
the maxi-competition (25 players on each team). 

1) In neither case should a B player lose by more than 10 points and 
2) the average B loss should be as near to 6 points as possible. 

One last wrinkle not mentioned by the champions: 
In the case of 25 players, at least five of the B wins should be by 2 points.

*/

//------------------------------------------------------------------------------

//#include "l_pingpong.h"

//------------------------------------------------------------------------------
/*
 * Includes
 */
#include "gaul.h"

/*
 * Prototypes.
 */
boolean pingpong_score (population *pop, entity *entity);
boolean pingpong_seed (population *pop, entity *adam);
void    pingpong_crossover (population *pop, entity *mother, entity *father, entity *daughter, 
                            entity *son);
//------------------------------------------------------------------------------


//------------------------------------------------------------------------------
// Score solution.

// чем больше фитнес, тем лучше ??
// 
//------------------------------------------------------------------------------
boolean 
pingpong_score (population *pop, entity *entity)
{
  int	    i;	// Команда А (сильнейшая)       
  int	    j;	// Команда В (хитрая)
  int     score = 0, badscore = 0;
  double    lossscore = 0.0;

  int  badloss = 0;
  int 	  loss = 0;

  // mgena
  // 
  int  len_chromo = pop->len_chromosomes; /* 25 */ /* 9 */

  //int  is_score_print = is_print;
  int  is_score_print = 0;

  // делаем предварительные подсчеты по играм турнира
  // 
  
  for (i = 0; i < len_chromo; i++) {

    j = ((int *) entity->CH)[i]; // соперник для игрока i

    score = (j - i) * 4 + 2;     // результат игры в этой паре (в очках)

    //printf ("... score = %f \n", score);
    if (is_score_print) {
    printf ("::: i = %d   j = %d   score = %d \n", i, j, score);
    }

    if (score > 0) {
      loss++;              // число проигрышей 
      lossscore += score;  // очков проиграно

      if (score > 10) { 
        badloss++;
        badscore += score;
      }
    }
  }

  lossscore /= loss; //  средний проигрыш

  if (is_score_print) {
  printf ("::: score     = %d \n", score);
  printf ("::: loss      = %d \n", loss);
  printf ("::: lossscore = %f \n", lossscore);
  printf ("::: badscore  = %d \n", badscore);
  }

  // теперь начинаем считать фитнес (от нуля и ухудшая в сторону уменьшения)
  // 
  entity->fitness = 0;


  // Ни в каком случае игрок не должен проиграть больше 10 очков.
  //  
  entity->fitness -= badscore * 2.0;

  // Средний проигрыш должен быть по возможности не больше 6. 
  // 
  entity->fitness -= SQU (6 - lossscore) * 3.0;

  // Команда должна выиграть большинство игр.
  // 
  if (loss > 12) entity->fitness -= loss;
  
  if (is_score_print)
    printf ("...entity->fitness = %f \n", entity->fitness);

  return TRUE;
}
//------------------------------------------------------------------------------
// Seed initial solutions.
//------------------------------------------------------------------------------
boolean 
pingpong_seed (population *pop, entity *adam)
{
  int	  i, j;   // Team members 
  int	 *data;   // Chromosome  

  data = (int *)adam->CH;  // это указатель на хромосому, которую будем делать

  //mgena
  int  len_chromo = pop->len_chromosomes; /* 25 */ /* 9 */

  for (i = 0; i < len_chromo; i++) {
    data[i] = -1;
  }

  for (i = 0; i < len_chromo; i++)
  {
    j = random_int (len_chromo); // выбрали второй случайный индекс

    while (data[j] > -1)
    {
      if (j == len_chromo-1)
        j = 0;
      else
        j++; // двигаемся вправо по кругу, пока не найдем первый свободный
    }

    data[j] = i; // в него и запишем индекс i (номер соперника из другой команды)
  }

  return TRUE;
}
//------------------------------------------------------------------------------
// Mutation by swapping two team members.
//------------------------------------------------------------------------------
void 
pingpong_mutate_swap (population *pop, entity *mother, entity *son)
{
  int	   i, j;  /* Team members.         */
  int	   tmp;	  /* For swapping i and j. */

  //mgena
  int  len_chromo = pop->len_chromosomes; /* 25 */ /* 9 */

  // Copy chromosomes of parent to offspring. 
  // 
  memcpy (son->CH,
          mother->CH,
          pop->len_chromosomes * sizeof(int));

  i = random_int (len_chromo);
  j = random_int (len_chromo);

  if (i == j)
  {
    if (j == len_chromo-1)
      j = 0;
    else
      j++;
  }

  tmp = ((int *)son->CH)[i];

  ((int *)son->CH)[i] = ((int *)son->chromosome[0])[j];
  ((int *)son->CH)[j] = tmp;

  return;
}
//------------------------------------------------------------------------------
// Crossover.
//------------------------------------------------------------------------------
void 
pingpong_crossover (population *pop, entity *mother,   entity *father, 
                                     entity *daughter, entity *son)
{
  int	  i, j;	/* Team members. */

  //mgena
  int  len_chromo = pop->len_chromosomes; /* 25 */ /* 9 */

  for (i = 0; i < len_chromo; i++)
  {
    if (random_boolean ())
    {
      ((int *)     son->CH)[i] = ((int *)father->CH)[i];
      ((int *)daughter->CH)[i] = ((int *)mother->CH)[i]; // ????
    }
    else
    {
      ((int *)     son->CH)[i] = ((int *)father->CH)[i]; // ???? один в один !!
      ((int *)daughter->CH)[i] = ((int *)mother->CH)[i];
    }
  }

  for (i = 1; i< len_chromo; i++)
  {
    for (j = 0; j < i; j++)
    {
      if (((int *)son->CH)[j] == ((int *)son->CH)[i])
      {
        if (((int *)son->CH)[i] == len_chromo-1)
          ((int *)son->CH)[i] = 0;
        else
          ((int *)son->CH)[i]++;
        j = 0;
      }
    }

    for (j = 0; j < i; j++)
    {
      if (((int *)daughter->CH)[j] == ((int *)daughter->CH)[i])
      {
        if (((int *)daughter->CH)[i] == len_chromo-1)
          ((int *)daughter->CH)[i] = 0;
        else
          ((int *)daughter->CH)[i]++;
        j = 0;
      }
    }
  }
  
  return;
}
//------------------------------------------------------------------------------
// Mutation by shifting a team member.
//------------------------------------------------------------------------------
void 
pingpong_mutate_shift (population *pop, entity *mother, entity *son)
{
  int	   i, j, k;	/* Team members.         */
  int	   tmp;		/* For swapping i and j. */

  //mgena
  int  len_chromo = pop->len_chromosomes; /* 25 */ /* 9 */

  /* Copy chromosomes of parent to offspring. */
  memcpy (son->CH,
          mother->CH,
          pop->len_chromosomes * sizeof (int));

  i = random_int (len_chromo);

  do {
    j = random_int (len_chromo);

  } while (i == j);

  if (i > j)
  {
    tmp = ((int *)son->CH)[j];
    
    for (k = j; k < i; k++)
    {
      ((int *)son->CH)[k] = ((int *)son->CH)[k+1];
    }
    ((int *)son->CH)[i] = tmp;
  }
  else
  {
    tmp = ((int *)son->CH)[j];

    for (k = j; k > i; k--)
    {
      ((int *)son->CH)[k] = ((int *)son->CH)[k-1];
    }
    ((int *)son->CH)[i] = tmp;
  }
  
  return;
}
//------------------------------------------------------------------------------
// Mutation.
//------------------------------------------------------------------------------
void 
pingpong_mutate (population *pop, entity *mother, entity *son, 
                 double r_prob)
{

  if (random_boolean_prob (r_prob))
    pingpong_mutate_swap  (pop, mother, son);
  else
    pingpong_mutate_shift (pop, mother, son);

  return;
}
//------------------------------------------------------------------------------
// Analysis callback.
//------------------------------------------------------------------------------
boolean 
pingpong_callback_ (int iteration, entity *this, int  len_chromo)
{
  int	    i;		    /* Team member.                   */
  int	    score[25];	    /* Scores.                        */
  int	    loss      = 0;  /* Number of matches lost.        */
  double    lossscore = 0;  /* Average score in lost matches. */

  //int  len_chromo = /* pop->len_chromosomes */25; /* 25 */ /* 9 */
  //assert (len_chromo <= 25);

  for (i = 0; i < len_chromo; i++)
  {
    score[i] = (((int *)this->CH)[i] - i) * 4 + 2;

    if (score[i] > 0)
    {
      loss++;
      lossscore += score[i];
    }
  }
  lossscore /= loss;

  printf ( "%2d:  %d %d %d %d %d %d %d %d %d  fitness= %f  wins = %d  Ave.loss= %f  ",
          iteration,
          ((int *)this->CH)[0],
          ((int *)this->CH)[1],
          ((int *)this->CH)[2],
          ((int *)this->CH)[3],
          ((int *)this->CH)[4],
          ((int *)this->CH)[5],
          ((int *)this->CH)[6],
          ((int *)this->CH)[7],
          ((int *)this->CH)[8],
          
          this->fitness, // а почему тут нули ??
          /* 25 */len_chromo - loss ,
          lossscore
           );

  //printf ("\n");
  //printf ("                            ");
  printf ("%d %d %d %d %d %d %d %d %d  \n",
         score[0], score[1], score[2],
         score[3], score[4], score[5],
          score[6], score[7], score[8]
           );

  // If this was to return FALSE, then the search would terminate. 
  // ??
  return TRUE;	
}
//------------------------------------------------------------------------------
boolean 
pingpong_iteration_callback (int iteration, entity *this)
{

  return (pingpong_callback_ (iteration, this, 25));
}
//------------------------------------------------------------------------------
// Analysis callback.
//------------------------------------------------------------------------------
boolean 
pingpong_ga_callback (int generation, population *pop)
{
  // Top ranked solution.
  // 
  entity  *solution = ga_get_entity_from_rank (pop, 0);

  //entity  *best = ga_get_entity_from_rank (pop, 0); //mgena
  //  а оно точно лучшее ?? уже отсортировано ??

  return (pingpong_callback_ (generation, solution, pop->len_chromosomes));
}
//------------------------------------------------------------------------------


/*******************************************************************************

  pingpong1.c

  Обратите внимание, что это, вероятно, не является методом выбора
  для решения данной проблемы - а используется только в качестве иллюстрации.

  В этом примере используются кастомные операторы кроссовера и мутации, поскольку
  

  This example uses custom crossover and mutation
  operators since a given team member is unable to
  play twice.

*******************************************************************************/


//------------------------------------------------------------------------------
void 
pingpong_mutate_0_2 (population *pop, entity *mother, entity *son)
{

  // Checks.
  // 
  if (!mother || !son) die ("Null pointer to entity structure passed");

  pingpong_mutate (pop, mother, son, 0.2);

  return;
}
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
population*
pingpong_genesis (int population_size, int len_chromo, 
                  GAmutate mutate,
                  GAselect_one  select_one,
                  GAselect_two  select_two,
                  GAcrossover   crossover)
{

  //int population_size = 50;

  population *pop = NULL;   /* Population of solutions. */

  pop = ga_genesis_integer (
       population_size,		/* const int              population_size */
        1,			/* const int              num_chromo      */
       /* 25 */len_chromo,	/* const int              len_chromo      */

       NULL, /*pingpong_ga_callback,*/	/* GAgeneration_hook  generation_hook  */

       NULL,			/* GAiteration_hook       iteration_hook       */
       NULL,			/* GAdata_destructor      data_destructor      */
       NULL,			/* GAdata_ref_incrementor data_ref_incrementor */
       pingpong_score,		/* GAevaluate             evaluate             */
       pingpong_seed,		/* GAseed                 seed                 */
       NULL,			/* GAadapt                adapt                */
       /* ga_ */select_one/* _randomrank */,  /* GAselect_one       select_one */
       /* ga_ */select_two/* _randomrank */,  /* GAselect_two       select_two */
       /* pingpong_ */mutate/* _0_2 */,	      /* GAmutate               mutate */
       /* pingpong_ */crossover,	      /* GAcrossover         crossover */
       NULL,			/* GAreplace              replace              */
       NULL			/* vpointer		  User data            */
       );

  return (pop);
}
//------------------------------------------------------------------------------
void 
parse_opts_3 (int argc, char **argv, 
                int  *p_par1,  int  *p_par2,  int  *p_par3,
                int def_par1,  int def_par2,  int def_par3
                )
{

  is_print = 0;

  if (argc == 2) { // вызов без параметров, только с одним MODE
    
    *p_par1 = def_par1;
    *p_par2 = def_par2;
    *p_par3 = def_par3;
    
  } else {
    
    *p_par1 = atoi (argv[2]);
    *p_par2 = atoi (argv[3]);
    *p_par3 = atoi (argv[4]);
    
    if (argc == 6) {
      is_print = 1; 
      //target_text = TEXT_SIMP;
    }
  }
  
  return;
}
//------------------------------------------------------------------------------
//------------------------------------------------------------------------------
int 
main_ga (int len_chromo,  int argc, char **argv)
{

  int num_runs        ;
  int population_size ;
  int max_generations ;

  parse_opts_3 (argc, argv,  &num_runs, &population_size, &max_generations,  
                              50, 50, 200);


  int	      i;		     /* Runs.                                 */
  population  *pop        = NULL;    /* Population of solutions.              */

  for (i = 0; i < num_runs; i++)
  {
    if (pop) ga_extinction (pop);

    unsigned int seed = 424242 * i;
    random_seed (seed);

    pop = pingpong_genesis (population_size, len_chromo, pingpong_mutate_0_2,
                            ga_select_one_randomrank,
                            ga_select_two_randomrank,
                            pingpong_crossover);

    ga_population_set_parameters (
       pop,			   /* population                *pop */
       GA_SCHEME_DARWIN,	   /* const ga_scheme_type    scheme */
       GA_ELITISM_PARENTS_SURVIVE, /* const ga_elitism_type  elitism */
       0.5,			   /* double  crossover              */
       0.5,			   /* double  mutation               */
       0.0              	   /* double  migration              */
       );


    ga_evolution (
       pop,			   /* population                *pop */
       max_generations		   /* const int      max_generations */
       );

    //if (is_print) {
    //// осмотримся и распечатаемся:
    //ga_population_seed (pop); // вообще-то здесь это происходило дальше!
    //pop_print (pop);
    //exit (0); // пока здесь остановимся !
    //}

    //printf ("\n");
    //pop_print (pop);
    //printf ("\n");

    // вообще, почему оно здесь то вызывается, а не стандартным способом?
    // i - должна быть итерацией, а не номером теста
    // 
    //pingpong_ga_callback (i, pop);
    //}


  printf ("\n");
  printf ( "The final solution with found was: (seed = %d) \n", seed);

  char	      *beststring = NULL;    /* Human readable form of best solution. */
  size_t       beststrlen  = 0;      /* Length of beststring.                 */

  entity *bestentity = ga_get_entity_from_rank (pop, 0);

  beststring = ga_chromosome_integer_to_string (pop, bestentity, beststring, &beststrlen);

  printf ("%s\n", beststring);
  printf ("With score = %f\n", ga_entity_get_fitness (bestentity));
  printf ("\n");

  //  }

  //ga_extinction (pop);

  //s_free (beststring);
  //*** glibc detected *** l_pingpong: double free or corruption (out): 0x09981968 ***
  }


  exit (EXIT_SUCCESS);
}
/*******************************************************************************
  pingpong9.c

		Note that this probably isn't the method of choice
		for solving this problem - it is just used as an
		illustration.

		This example uses custom crossover and mutation
		operators since a given team member is unable to
		play twice.

*******************************************************************************/

/*******************************************************************************
  pingpong_tabu.c

		This example uses the tabu-search algorithm instead of
		a GA.
  
*******************************************************************************/

//------------------------------------------------------------------------------
void 
pingpong_mutate_0_5 (population *pop, entity *mother, entity *son)
{

  /* Checks. */
  if (!mother || !son) die ("Null pointer to entity structure passed");

  pingpong_mutate (pop, mother, son, 0.5);

  return;
}
//------------------------------------------------------------------------------
//
//------------------------------------------------------------------------------
int 
main_t1 (int len_chromo,  int argc, char **argv)
{
  //int len_chromo      =  25; // т.е. правила .. можно ли изменять ??

  int num_runs        ;
  int population_size ;
  int max_iterations  ;  // generations ??

  parse_opts_3 (argc, argv,  &num_runs, &population_size, &max_iterations,  
                              50, 50, 100);


  int	      i;		   /* Runs.                                 */
  population  *pop = NULL;	   /* Population of solutions.              */
  char	      *beststring = NULL;  /* Human readable form of best solution. */
  size_t      beststrlen  = 0;	   /* Length of beststring.                 */

  for (i = 0; i < num_runs; i++)
  {

    unsigned int seed = 230975 * i;
    random_seed (seed);

    // Note that most of the population data is not required for a tabu-search. 
    // 
    pop = pingpong_genesis (population_size, len_chromo, pingpong_mutate_0_5, 
                            NULL, NULL, NULL);

    /* ga_population_set_tabu_parameters() is required instead of
     * the usual ga_population_set_parameters().
     */
    ga_population_set_tabu_parameters (
       pop,			/* population	   *pop                            */
       ga_tabu_check_integer,	/* GAtabu_accept   tabu acceptance criterion       */
       50,			/* const int	   tabu list length                */
       20			/* const int	   tabu neighbourhood search count */
       );

    /* ga_tabu() is called instead of ga_evolution().  The NULL parameter indicates
     * that a random (as generated by the GAseed callback) should be used.
     * Alternatively, a specific starting solution may be passed.
     */

    ga_tabu (
       pop,			/* population		*pop           */
       NULL,			/* entity		*initial       */
       max_iterations		/* const int		max_iterations */
       );

    /* ga_tabu() doesn't sort the population.  Using ga_population_score_and_sort() is
     * therefore required so that we know which entity was optimised, but this process
     * is fairly inefficient.  This is not needed if a specific entity is passed to
     * ga_tabu() for optimisation.
     */

    //if (is_print) {
    //  pop_print (pop);
    //}

    ga_population_score_and_sort (pop);

    entity *bestentity = ga_get_entity_from_rank (pop, 0);

    printf ("\n");
    printf ("The best solution found on attempt %d with fitness %f was:\n", i, 
            bestentity->fitness);

    beststring = ga_chromosome_integer_to_string (pop, bestentity, 
                                                  beststring, &beststrlen);
    printf ("%s\n", beststring);
    printf ("\n");

    // вообще, почему оно здесь то вызывается, а не стандартным способом?
    // i - должна быть итерацией, а не номером теста
    // 
    //pingpong_ga_callback (i, pop);

    ga_extinction (pop);
  }

  //if (is_print) {
  //  printf ("PPPPPPPPPPPPPPP \n");
  //}

  s_free (beststring);

  exit (EXIT_SUCCESS);
}
/*******************************************************************************
  pingpong_tabu2.c

		This example uses the tabu-search algorithm instead of
		a GA.

*******************************************************************************/

//------------------------------------------------------------------------------
// 
// отличается от первого варианта тем. что есть начальная инициализация
// 
//------------------------------------------------------------------------------
int 
main_t2 (int len_chromo,  int argc, char **argv)
{
  //int len_chromo      =  25;

  int num_runs        =  50;
  int population_size =  50;
  int max_iterations  =  60;


  int		i;		     /* Runs.                                 */
  population	*pop = NULL;	     /* Population of solutions.              */
  char		*beststring = NULL;  /* Human readable form of best solution. */
  entity	*solution;	     /* Fittest entity in population.         */

  size_t	beststrlen  = 0;     /* Length of beststring.                 */

  for (i = 0; i < num_runs; i++)
  {

    random_seed (230975 * i);

    // Note that most of the population data is not required for a tabu-search. 
    //
    pop = pingpong_genesis (population_size, len_chromo, pingpong_mutate_0_5, 
                            NULL, NULL, NULL);


    // Evaluate the initial 50 population members. 
    // 
    ga_population_seed (pop);
    ga_population_score_and_sort(pop);

    /* ga_population_set_tabu_parameters() is required instead of
     * the usual ga_population_set_parameters().
     */
    ga_population_set_tabu_parameters(
       pop,			/* population	    *pop                            */
       ga_tabu_check_integer,	/* GAtabu_accept    tabu acceptance criterion       */
       50,			/* const int	    tabu list length                */
       20			/* const int	    tabu neighbourhood search count */
                              );

    /* ga_tabu() is called instead of ga_evolution().  We use the best of the
     * initial 50 population members.  This entity is overwritten with an
     * improved version.
     */
    solution = ga_get_entity_from_rank (pop, 0);

    ga_tabu (
       pop,			/* population		*pop           */
       solution,		/* entity		*initial       */
       max_iterations		/* const int		max_iterations */
           );
    
    printf ("The best solution found on attempt %d with fitness %f was:\n", 
            i, solution->fitness); // solution ??

    beststring = ga_chromosome_integer_to_string (pop, solution, beststring, &beststrlen);
    printf ("%s\n", beststring);

    // Just used here to write the resulting solution. 
    // 
    pingpong_iteration_callback (i, solution); 
    //pingpong_ga_callback (i, pop); 

    ga_extinction (pop);
  }

  s_free (beststring);

  exit (EXIT_SUCCESS);
}
//******************************************************************************
//------------------------------------------------------------------------------
int 
main_sa (int argc, char **argv)
{

  int len_chromo      =  25;

  int	      i;		    /* Runs.                                 */
  population  *pop = NULL;	    /* Population of solutions.              */
  char	      *beststring = NULL;   /* Human readable form of best solution. */
  size_t      beststrlen = 0;	    /* Length of beststring.                 */
  entity      *solution;	    /* Fittest entity in population.         */

  int num_runs        =    50;
  int population_size =    50;
  int max_iterations  =  1000;

  parse_opts_3 (argc, argv,  &num_runs, &population_size, &max_iterations,  
                              50, 50, 1000);


  //exit(EXIT_SUCCESS);

  for (i = 0; i < /*50*/num_runs; i++)
  {

    //printf ("i = %d ... \n", i);

    unsigned int seed = 230975 * i;
    random_seed (seed);

    /* Note that most of the population data is not required for
      * simulated annealling.
      */

    pop = ga_genesis_integer (
       population_size,		/* const int              population_size      */
        1,			/* const int              num_chromo           */
       len_chromo,		/* const int              len_chromo           */
       NULL,			/* GAgeneration_hook      generation_hook      */
       NULL,			/* GAiteration_hook       iteration_hook       */
       NULL,			/* GAdata_destructor      data_destructor      */
       NULL,			/* GAdata_ref_incrementor data_ref_incrementor */
       pingpong_score,		/* GAevaluate             evaluate             */
       pingpong_seed,		/* GAseed                 seed                 */
       NULL,			/* GAadapt                adapt                */
       NULL,			/* GAselect_one           select_one           */
       NULL,			/* GAselect_two           select_two           */
       pingpong_mutate_0_5,	/* GAmutate               mutate               */
       NULL,			/* GAcrossover            crossover            */
       NULL,			/* GAreplace              replace              */
       NULL			/* vpointer		  User data            */
       );

    //printf ("BESt = %d \n", pop->best);

    // Evaluate the initial 50 population members. 
    //
    ga_population_score_and_sort (pop);

    //printf ("BESt = %d \n", pop->best);

    /* ga_population_set_sa_parameters() is required instead of
     * the usual ga_population_set_parameters().
     */
    ga_population_set_sa_parameters (
       pop,			     /* population	   *pop                         */
       ga_sa_boltzmann_acceptance,   /* GAsa_accept	   SA acceptance criterion      */
       100.0,			     /* const double	   Initial temperature          */
       0.0,			     /* const double	   Final temperature            */
       10.0,			     /* const double	   Temperature step size        */
       50			     /* const int	   Temperature update frequency */
       );


    if (is_print) {
      printf ("\n");
      printf ("POP_PRINT  11111111111111111 : \n");
      printf ("\n");

      pop_print (pop);
    }

    /* ga_sa() is called instead of ga_evolution().  We use the best of the
     * initial 50 population members.  This entity is overwritten with an
     * improved version.
     */
    solution = ga_get_entity_from_rank (pop, 0);

    //mgena
    //assert (solution != NULL);
    //mgena

    if (is_print) { 

      printf ("\n");
      printf ("solution = \n"); // = NUL !!!!!
      printf ("\n");

      //print_ch (solution, " solution =", len_chromo);
      //print_entit (solution, " solution =", len_chromo);
    }

    ga_sa (
       pop,		 /* population	    *pop           */
       solution,	 /* entity	    *initial       */
       max_iterations	 /* const int	    max_iterations */
       );


    // попробуем вот так:
    // 
    ga_population_score_and_sort (pop);
    entity *bestentity = ga_get_entity_from_rank (pop, 0);

    printf ("\n");
    printf ("Final best: i = %d, seed = %d  fitness %f, beststring = \n", i, seed,
            bestentity->fitness);

    //printf ("The best solution found on attempt %d with fitness %f was:\n", 
    //        i, solution->fitness);

    beststring = ga_chromosome_integer_to_string (pop, /*solution*/ bestentity, 
                                                  beststring, &beststrlen);

    printf ("%s\n", beststring);
    printf ("\n");

    // Just used here to write the resulting solution.
    //
    //pingpong_iteration_callback (i, solution);	
    //pingpong_iteration_callback (i, bestentity);	

    ga_extinction (pop);
  }

  s_free (beststring);

  //return;
  exit(EXIT_SUCCESS);
} 
//------------------------------------------------------------------------------
// 
// l_pingpong _09
// 
// - вводить все параметры через командную строку;
// - выделить общие процедуры по максимуму; 
// 
//------------------------------------------------------------------------------
int 
main (int argc, char **argv)
{

  if (argc < 2) 
    exit (EXIT_SUCCESS);


  //if (!strcmp(argv[1], "_sa"))    main_sa (argc, argv);

  if (!strcmp(argv[1], "_09"))    main_ga ( 9, argc, argv); // малое соревнование
  if (!strcmp(argv[1], "_25"))    main_ga (25, argc, argv);

  if (!strcmp(argv[1], "_t1_09")) main_t1 ( 9, argc, argv);
  if (!strcmp(argv[1], "_t1_25")) main_t1 (25, argc, argv);

  if (!strcmp(argv[1], "_t2_09")) main_t2 ( 9, argc, argv);
  if (!strcmp(argv[1], "_t2_25")) main_t2 (25, argc, argv);

  if (!strcmp(argv[1], "_sa"))    main_sa (argc, argv);

  exit (EXIT_SUCCESS);
}
//------------------------------------------------------------------------------

/* X1:l_pingpong,_09 ... PASSED */
/* X1:l_pingpong,_25 ... PASSED */
/* X1:l_pingpong,_t1 ... PASSED */
/* X1:l_pingpong,_t2 ... PASSED */

//******************************************************************************


