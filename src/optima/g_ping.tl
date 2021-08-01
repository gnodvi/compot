# -*-   mode: tcl  ; coding: koi8   -*- ----------------------------------------

#!/bin/sh
# \
exec tclsh "$0" ${1+"$@"}

#-------------------------------------------------------------------------------
# Josef Knecht @ Copyright 
#-------------------------------------------------------------------------------

set COMPOT "./COMPOT"

set auto_path [linsert $auto_path 0 $COMPOT]

set auto_path [linsert $auto_path 0 $COMPOT/src/common] ;# for JIM

#------------------------------------------

package require compot::common 

#------------------------------------------

# source "b-com0.tl"
# source "b-com1.tl"

#source "f-rand.tl"

source "g-corE.tl"

source "g-diff.tl"
source "g-detw.tl"
source "g-tabu.tl"
source "g-sima.tl"

#-------------------------------------------------------------------------------
#   pingpong_ALL.c

# 		This program aims to solve a problem proposed in:
# 		Dennis E. Shasha, "Dr Ecco's Omniheurist Corner: Foxy",
# 		Dr Dobb's Journal, 323:148-149 (2001).

# //------------------------------------------------------------------------------
# /*

# Каждая команда состоит из 25 игроков, но для мини-соревнования, только 9 лучших
# игроков будет заявлено.
# Команда А - лучшая команда (в среднем), но команда В также имеет несколько 
# замечательных игроков.

# Предположим, мы пронумеруем в каждой команде игроков от 0 (лучший) до 24 (слабейший)
# так что: A[0] - лучший игрок в команде A, B[0] - лучший игрок в команде B. 
# Далее предположим, что игрок A[i] побеждает игрока B[i] на 2 очка для каждого i
# от 0 до 24 включительно.
# Однако, B[i] может побить A[i+1] (для каждого i от 0 до 23) на 2 очка.
# И далее, согласно транзитивности, получаем диаграмму силы (через 2 очка) :

# A[0] -> B[0] -> A[1] -> B[1] -> A[2] -> B[2] -> A[3] 

# Тренер команды B (которая в среднем слабее) - знает всю эту схему. 
# Тренер команды A - не в курсе!
# Тренер B понимает, что его команда будет терять по 2 очка на каждой "правильной"
# паре, т.е. B[0] -- A[0], B[1] -- A[1] и т. д. 
# Соответственно, он хочет  организовать схему соревнования таким образом, чтобы 
# выиграть больше игр, чем команда A, и при этом не разбудить подозрения у 
# тренера A.
# Тренер  A может стать подозрительным. если "average point spread" в играх, где 
# игроки команды A выиграют - слишком велика или если "maximum point spread" в таких
# играх  is too high.

# Таким образом, ТренерB поставил перед собой задачу -  составить пары из своих игроков 
# противигроков  команды A таким образом, чтобы игроки команды B не проигрывали больше 
# 10 очков и чтобы "average point spread" для игр где A побеждали - был не больше 7. 

#---------------------------------------------------------

# Here is an example to show you how this would go: If there were just five 
# players on each side, then ТренерB might pair up

# Ateam		Bteam
# 0		4
# 1		0
# 2		1
# 3		2
# 4 	        3

# which would enable B players to win by 2 points in every game except against 
# A[0]. However, B[4] would then lose by 18 points. Foxy wouldn't choose this 
# strategy because he would arouse the suspicions of ТренерА. Besides, 
# he needs only a majority of games, not 4 out of 5."


# Reader: First try to figure out a winning strategy for тренера B in the case of 
# the mini-competition (nine players on each team) and then for the case of 
# the maxi-competition (25 players on each team). 

# 1) In neither case should a B player lose by more than 10 points and 
# 2) the average B loss should be as near to 6 points as possible. 

# One last wrinkle not mentioned by the champions: 
# In the case of 25 players, at least five of the B wins should be by 2 points.


# ------------------------------------------------------------------------------
# Score solution.

# чем больше фитнес, тем лучше ??
#  
#-------------------------------------------------------------------------------
proc SQU {x} {

  return [expr {$x * $x}]
}
# ------------------------------------------------------------------------------
proc pingpong_score {entity task} {

  #   int i;  // Команда А (сильнейшая)       
  #   int j;  // Команда В (хитрая)

  set     score  0 ;# 0.0
  set lossscore  0 ;# 0.0
  set  badscore  0 ;# 0.0
  
  set  badloss 0
  set  loss    0
  
  # pilot
  #  
  #set len_chromo [GET $pop len_chromosomes] ;# /* 25 */ /* 9 */ 

  #puts ""
  #puts "entity = [set $entity]"
  #puts ""
  set len_chromo [item_get_chromo_len $entity] 
 
  set is_score_print 0 ;# 0
 
  # делаем предварительные подсчеты по играм турнира
  #  
  if {$is_score_print} {
    puts ""
    puts "::: ~~~~~ pingpong_score BEGIN ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
    puts ""
  }
  
  for {set i 0} {$i < $len_chromo} {incr i} {

    set j [item_get_chromo_gen $entity  $i] ;# соперник для игрока i ????
    
    
    if {$is_score_print} {
      #puts ""
      puts "::: i = $i   j = $j "
      puts ""
    }

    set score [expr {($j - $i) * 4 + 2}] ;# результат игры в этой паре (в очках)
    
    if {$is_score_print} {
    puts "::: i = $i   j = $j  score = $score"
    }

    if {$score > 0} {
      incr loss             ;# число проигрышей 
      incr lossscore $score ;# очков проиграно
      
      if {$score > 10} { 
        incr badloss
        incr badscore $score
      }
    }    
  }
  
  set lossscore [expr {1.0 * $lossscore / $loss}] ;# средний проигрыш
  
  
  if {$is_score_print} {
  puts "::: score     = $score"
  puts "::: loss      = $loss "
  puts "::: lossscore = $lossscore"
  puts "::: badscore  = $badscore "
  }

  # теперь начинаем считать фитнес (от нуля и ухудшая в сторону уменьшения)
  #  
  set fitness  0 ;# пока в локальной переменной, а потом запишем!
  
  # Ни в каком случае игрок не должен проиграть больше 10 очков.
  #   
  set fitness [expr {$fitness - ($badscore * 2.0)}]
  
  # Средний проигрыш должен быть по возможности не больше 6. 
  # 
  set fitness [expr {$fitness - ([SQU [expr 6 - $lossscore]] * 3.0)}] ;# ??
  
  # Команда должна выиграть большинство игр.
  #  
  if {$loss > 12} {
    set fitness [expr {$fitness - $loss}]
  }
  

  if {$is_score_print} {
    puts "::: entity->fitness = $fitness"
    puts "::: ~~~~~ pingpong_score FINAL ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
  }

   return $fitness 
}
# //------------------------------------------------------------------------------
# // Seed initial solutions.
# //------------------------------------------------------------------------------
proc pingpong_seed {pop task adam} {

  # int	  i, j;   // Team members 
  
  set len_chromo [GET $pop len_chromosomes] ;# /* 25 */ /* 9 */
  
 
  for {set i 0} {$i < $len_chromo} {incr i} \
  {
    item_set_chromo_gen $adam  $i -1 ;# забили пустышками
  }


  for {set i 0} {$i < $len_chromo} {incr i} \
  {
    set j [comm_random_int $len_chromo] ;# выбрали второй случайный индекс
    
    while {[item_get_chromo_gen $adam  $j] > -1}  {

      if {$j == [expr {$len_chromo - 1}]} {
        set j 0
      } else {
        incr j ; # двигаемся вправо по кругу, пока не найдем первый свободный
      }
    }
    
    item_set_chromo_gen $adam  $j  $i
  }
  
  return true
}
# //------------------------------------------------------------------------------
# // Mutation by swapping two team members.
# //------------------------------------------------------------------------------
# void 
# pingpong_mutate_swap (population *pop, entity *mother, entity *son)
# //------------------------------------------------------------------------------
proc pingpong_mutate_swap {pop mother son} {

  #puts "pingpong_mutate_swap: ................ "

  #   int	   i, j;  /* Team members.         */
  #   int	   tmp;	  /* For swapping i and j. */
  
  #   //pilot
  #   int  len_chromo = pop->len_chromosomes; /* 25 */ /* 9 */
  set len_chromo [GET $pop len_chromosomes]
  
  #   // Copy chromosomes of parent to offspring. 
  #   // 
  #   memcpy (son->CH,
  #           mother->CH,
  #           pop->len_chromosomes * sizeof(int));

  item_set_mainsrc $son [item_get_mainsrc $mother]

  #   i = random_int (len_chromo);
  #   j = random_int (len_chromo);

  set i [comm_random_int $len_chromo]
  set j [comm_random_int $len_chromo]
    
  if {$i == $j} \
  {
    if {$j == [expr {$len_chromo - 1}]} {
      set j  0
    } else {
      incr j
    }
  }
  
  #puts "pingpong_mutate_swap: i = $i  j = $j"

  #   tmp = ((int *)son->CH)[i];
  set tmp [item_get_chromo_gen $son  $i]
  
  #   ((int *)son->CH)[i] = ((int *)son->chromosome[0])[j];
  item_set_chromo_gen $son $i [item_get_chromo_gen $son $j]

  #   ((int *)son->CH)[j] = tmp;
  item_set_chromo_gen $son $j $tmp
  
  #   return;
}
# //------------------------------------------------------------------------------
# // Crossover.
# //------------------------------------------------------------------------------
# void 
# pingpong_crossover (population *pop, entity *mother,   entity *father, 
#                                      entity *daughter, entity *son)
# {
# //------------------------------------------------------------------------------
proc pingpong_crossover {pop task  mother father dau son} {

#   int	  i, j;	/* Team members. */

#   //pilot
#   int  len_chromo = pop->len_chromosomes; /* 25 */ /* 9 */
  set len_chromo [GET $pop len_chromosomes]
  

  for {set i 0} {$i < $len_chromo} {incr i} \
    {
      if {[comm_random_boolean]} \
        {
          #       ((int *)     son->CH)[i] = ((int *)father->CH)[i];
          #       ((int *)daughter->CH)[i] = ((int *)mother->CH)[i];
          item_set_chromo_gen $son $i [item_get_chromo_gen $father $i]
          item_set_chromo_gen $dau $i [item_get_chromo_gen $mother $i]

        } else {
          # !!!!!!!!! то же самое ??
          #
          #       ((int *)     son->CH)[i] = ((int *)father->CH)[i];
          #       ((int *)daughter->CH)[i] = ((int *)mother->CH)[i];
          item_set_chromo_gen $son $i [item_get_chromo_gen $father  $i] 
          item_set_chromo_gen $dau $i [item_get_chromo_gen $mother  $i]
      }
    }
  
  for {set i 1} {$i < $len_chromo} {incr i} \
    {
      for {set j 0} {$j < $i} {incr j} \
        {

          set son_i [item_get_chromo_gen $son  $i]
          set son_j [item_get_chromo_gen $son  $j]

          #       if (((int *)son->CH)[j] == ((int *)son->CH)[i])
          if {$son_j == $son_i} \
          {
            #  if (((int *)son->CH)[i] == len_chromo-1)
            if {$son_i == [expr  {$len_chromo - 1}]} {
              # ((int *)son->CH)[i] = 0;
               item_set_chromo_gen $son $i 0 
            } else {
              # ((int *)son->CH)[i]++;
              item_set_chromo_gen $son $i [expr {$son_i + 1}] 
            }

            set j 0
          }
        }
      
      # тоже самое для дочери !!!
      # 
      for {set j 0} {$j < $i} {incr j} \
        {
          set dau_i [item_get_chromo_gen $dau  $i]
          set dau_j [item_get_chromo_gen $dau  $j]

          #  if (((int *)daughter->CH)[j] == ((int *)daughter->CH)[i])
          if {$dau_j == $dau_i} \
          {
          # if (((int *)daughter->CH)[i] == len_chromo-1)
            if {$dau_i == [expr  {$len_chromo - 1}]} {
             #   ((int *)daughter->CH)[i] = 0;
             item_set_chromo_gen $dau $i 0 
           } else {
             #   ((int *)daughter->CH)[i]++;
             item_set_chromo_gen $dau $i [expr {$dau_i + 1}] 
           }

           set j 0
          }
        }
  }
  
  return
}
# //------------------------------------------------------------------------------
# // Mutation by shifting a team member.
# //------------------------------------------------------------------------------
# void 
# pingpong_mutate_shift (population *pop, entity *mother, entity *son)

# //------------------------------------------------------------------------------
proc pingpong_mutate_shift {pop mother son}  {

  #puts "pingpong_mutate_shift .......... "

  #   int	   i, j, k;	/* Team members.         */
  #   int	   tmp;		/* For swapping i and j. */
  
  #   //pilot
  #   int  len_chromo = pop->len_chromosomes; /* 25 */ /* 9 */
  set len_chromo [GET $pop len_chromosomes]
  
  #   /* Copy chromosomes of parent to offspring. */
  #   memcpy (son->CH,
  #           mother->CH,
  #           pop->len_chromosomes * sizeof (int));

  item_set_mainsrc $son [item_get_mainsrc $mother]
  
  #   i = random_int (len_chromo);
  set i [comm_random_int $len_chromo]
  
  #   do {
  #     j = random_int (len_chromo);
  
  #   } while (i == j);

  while {1} {
    set j [comm_random_int $len_chromo]
    if {$i != $j} {break}
  }
  
  
  if {$i > $j} \
  {
    #     tmp = ((int *)son->CH)[j];
    set tmp [item_get_chromo_gen $son  $j] 
   
    for {set k $j} {$k < $i} {incr k} \
    {
      #       ((int *)son->CH)[k] = ((int *)son->CH)[k+1];
      item_set_chromo_gen $son $k [item_get_chromo_gen $son [expr {$k + 1}]] 
    }
    #     ((int *)son->CH)[i] = tmp;  #       не надо ???????!!!!!
    item_set_chromo_gen $son $i $tmp
    
  } else {
    
    #     tmp = ((int *)son->CH)[j];
    set tmp [item_get_chromo_gen $son  $j] ;# ??? одно и тоже ??
    
    for {set k $j} {$k > $i} {incr k -1} \
    {
      #       ((int *)son->CH)[k] = ((int *)son->CH)[k-1];
      item_set_chromo_gen $son $k [item_get_chromo_gen $son [expr {$k - 1}]] 
    }
    #     ((int *)son->CH)[i] = tmp; #       не надо ???????!!!!!
    item_set_chromo_gen $son $i $tmp
  }
  
  #   return;
}
# //------------------------------------------------------------------------------
# // Mutation.
# //------------------------------------------------------------------------------
# void 
# pingpong_mutate (population *pop, entity *mother, entity *son, 
#                  double r_prob)
# //------------------------------------------------------------------------------
proc  pingpong_mutate {pop mother son r_prob} {

  if {[comm_random_boolean_prob  $r_prob]} {
    pingpong_mutate_swap  $pop $mother $son

  } else {
    pingpong_mutate_shift $pop $mother $son
  }
  
  #   return;
}
# /*******************************************************************************

#   pingpong1.c

#   Обратите внимание, что это, вероятно, не является методом выбора
#   для решения данной проблемы - а используется только в качестве иллюстрации.

#   В этом примере используются кастомные операторы кроссовера и мутации, поскольку
  

#   This example uses custom crossover and mutation
#   operators since a given team member is unable to
#   play twice.

# //------------------------------------------------------------------------------
proc pingpong_genesis {population_size len_chromo         
                       mutate                             
                       select_one select_two crossover} { \


  #   //int population_size = 50;  
  #   population *pop = NULL;   /* Population of solutions. */
  
  set task [task_create  -fit_func "pingpong_score" -fit_tobest "MAX"]

  set pop [ga_genesis_main      \
	     $task \
	   $population_size  \
	     1                 \
              $len_chromo       \
              NULL              \
              NULL              \
              NULL              \
              NULL              \
              pingpong_seed     \
              NULL              \
              $select_one       \
              $select_two       \
              $mutate           \
              $crossover        \
              NULL              \
              NULL	        \
          ]
  

  return [list $task $pop]
}
# //------------------------------------------------------------------------------
proc main_ga {len_chromo} {

  set num_runs        "" ;
  set population_size "" ;
  set max_generations "" ;
  
  set print [parse_opts_3   num_runs population_size max_generations  50 50 200]
  

  for {set i 0} {$i < $num_runs} {incr i} {
 
    set seed [expr {424242 * $i + 10}]
    
    comm_random_seed $seed
  
    # set pop [pingpong_genesis  $population_size $len_chromo pingpong_mutate_0_2 \
    #          ga_select_one_randomrank \
    #          ga_select_two_randomrank \
    #          pingpong_crossover]
  
    foreach {task pop}  [pingpong_genesis  $population_size $len_chromo pingpong_mutate_0_5 \
			   ga_select_one_randomrank \
			   ga_select_two_randomrank \
			   pingpong_crossover] {}
  
    #     ga_population_set_parameters (
    #        pop,			   /* population                *pop */
    #        GA_SCHEME_DARWIN,	   /* const ga_scheme_type    scheme */
    #        GA_ELITISM_PARENTS_SURVIVE, /* const ga_elitism_type  elitism */
    #        0.5,			   /* double  crossover              */
    #        0.5,			   /* double  mutation               */
    #        0.0              	   /* double  migration              */
    #        );
    
    ga_population_set_parameters                            \
                               $pop	                  \
                               GA_SCHEME_DARWIN	          \
                               GA_ELITISM_PARENTS_SURVIVE \
                               0.5			  \
                               0.5			  \
                               0.0      	          

    SET $pop ch_form "%02d " ;# 

    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    #
    ga_evolution  $task $pop $max_generations  -print $print  
    #
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
    
    puts ""
    puts "The final solution with found was: (seed = $seed):"
    
    set bestentity [ga_get_entity_from_rank $pop 0]
    
    set beststring [item_get_mainsrc $bestentity]
    

    puts $beststring
    puts [format "With score = %f" [item_get_fitn $bestentity]]
    puts ""
    
  }
  
  
}
# /*******************************************************************************
#   pingpong9.c

# 		Note that this probably isn't the method of choice
# 		for solving this problem - it is just used as an
# 		illustration.

# 		This example uses custom crossover and mutation
# 		operators since a given team member is unable to
# 		play twice.

#   pingpong_tabu.c

# 		This example uses the tabu-search algorithm instead of
# 		a GA.
  
# //------------------------------------------------------------------------------
# void 
# pingpong_mutate_0_5 (population *pop, entity *mother, entity *son)
# //------------------------------------------------------------------------------
#proc pingpong_mutate_0_5 {pop mother son} {}
proc pingpong_mutate_0_5 {pop task mother son} {

  #   /* Checks. */
  #   if (!mother || !son) die ("Null pointer to entity structure passed");
  
  pingpong_mutate  $pop $mother $son 0.5
  
  #   return;
}
# //------------------------------------------------------------------------------
# //
# //------------------------------------------------------------------------------
proc main_t1 {len_chromo} {

  #   //int len_chromo      =  25; // т.е. правила .. можно ли изменять ??
  
  set num_runs        ""
  set population_size ""
  set max_iterations  ""
  
  parse_opts_3   num_runs population_size max_iterations  50 50 100
  
  
  for {set i 0} {$i < $num_runs} {incr i} {
 
    #     // Note that most of the population data is not required for a tabu-search. 
    #     // 
    
    set seed [expr {230975 * $i + 10}]
    comm_random_seed $seed
  
    foreach {task pop}   [pingpong_genesis  $population_size $len_chromo pingpong_mutate_0_5 \
			    NULL NULL NULL] {}
    
    #     /* ga_population_set_tabu_parameters() is required instead of
    #      * the usual ga_population_set_parameters().
    #      */
    #     ga_population_set_tabu_parameters (
    #        pop,			/* population	   *pop                            */
    #        ga_tabu_check_integer,	/* GAtabu_accept   tabu acceptance criterion       */
    #        50,			/* const int	   tabu list length                */
    #        20			        /* const int	   tabu neighbourhood search count */
    #        );
    
    ga_population_set_tabu_parameters                     \
                               $pop	                  \
                               ga_tabu_check_integer	  \
                               50			  \
                               20      	          

    SET $pop ch_form "%02d " ;# 

    #     /* ga_tabu() is called instead of ga_evolution().  The NULL parameter indicates
    #      * that a random (as generated by the GAseed callback) should be used.
    #      * Alternatively, a specific starting solution may be passed.
    #      */
    
    #     ga_tabu (
    #        pop,			/* population		*pop           */
    #        NULL,			/* entity		*initial       */
    #        max_iterations		/* const int		max_iterations */
    #        );
    
    ga_tabu $task     \
            $pop \
            NULL \
            $max_iterations 
    

    #     /* ga_tabu() doesn't sort the population.  Using ga_population_score_and_sort() is
    #      * therefore required so that we know which entity was optimised, but this process
    #      * is fairly inefficient.  This is not needed if a specific entity is passed to
    #      * ga_tabu() for optimisation.
    #      */
    
    #if {$::is_print} {
    #  pop_print $pop
    #}

    ga_population_score_and_sort $pop $task
    

    set bestentity [ga_get_entity_from_rank $pop 0]
    
    puts ""
    puts [format "The best solution found on attempt %d with fitness %f was:" $i \
            [item_get_fitn $bestentity]]
#            [ent_get_fitness $bestentity]]
    

    item_print_ch $bestentity ""
    puts ""
    puts ""
    
  }
  
}
# //------------------------------------------------------------------------------
proc main_sa {} {

  
  set num_runs        ""
  set population_size ""
  set max_iterations  ""
  
  parse_opts_3   num_runs population_size max_iterations  50 50 1000
  
  for {set i 0} {$i < $num_runs} {incr i} {
   
    set seed [expr {230 * $i + 10}] ;# !!! получается иногда ноль !!!

    #puts "main_sa: seed = $seed"
    #set seed 2021
    
    comm_random_seed $seed
  
    #     /* Note that most of the population data is not required for
    #       * simulated annealling.
    #       */
    
    #     pop = ga_genesis_integer (
    #        population_size,		/* const int              population_size      */
    #         1,			/* const int              num_chromo           */
    #        25,			/* const int              len_chromo           */
    #        NULL,			/* GAgeneration_hook      generation_hook      */
    #        NULL,			/* GAiteration_hook       iteration_hook       */
    #        NULL,			/* GAdata_destructor      data_destructor      */
    #        NULL,			/* GAdata_ref_incrementor data_ref_incrementor */
    #        pingpong_score,		/* GAevaluate             evaluate             */
    #        pingpong_seed,		/* GAseed                 seed                 */
    #        NULL,			/* GAadapt                adapt                */
    #        NULL,			/* GAselect_one           select_one           */
    #        NULL,			/* GAselect_two           select_two           */
    #        pingpong_mutate_0_5,	/* GAmutate               mutate               */
    #        NULL,			/* GAcrossover            crossover            */
    #        NULL,			/* GAreplace              replace              */
    #        NULL			/* vpointer		  User data            */
    #        );
    
    set len_chromo 25
   
    set task [task_create  -fit_func "pingpong_score" -fit_tobest "MAX"]

    set pop [ga_genesis_main   \
	       $task \
               $population_size  \
               1                 \
               $len_chromo       \
               NULL              \
               NULL              \
               NULL              \
               NULL              \
               pingpong_seed     \
               NULL              \
               NULL              \
               NULL              \
               pingpong_mutate_0_5 \
               NULL              \
               NULL              \
               NULL	         \
              ]

    #     // Evaluate the initial 50 population members. 
    #     //
    ga_population_score_and_sort $pop $task
    
    #     /* ga_population_set_sa_parameters() is required instead of
    #      * the usual ga_population_set_parameters().
    #      */

    #     ga_population_set_sa_parameters (
    #        pop,			/* population	   *pop                         */
    #        ga_sa_boltzmann_acceptance,/* GAsa_accept	   SA acceptance criterion      */
    #        100.0,		        /* const double	   Initial temperature          */
    #        0.0,		        /* const double	   Final temperature            */
    #        10.0,		        /* const double	   Temperature step size        */
    #        50			        /* const int	   Temperature update frequency */
    #        );
    
    ga_population_set_sa_parameters    \
            $pop                       \
            ga_sa_boltzmann_acceptance \
            100.0                      \
              0.0                      \
             10.0                      \
             50 	       
    
    
    #------------------------------------------------------------
    if {0} {

      set ch_form {%s }
      #set ch_form {123 4}
      
      puts "ch_form = |$ch_form|"
      
      SET $pop  ch_form $ch_form  
      
      set ch_form [GET $pop "ch_form"]
      
      puts "ch_form = |$ch_form|"
      
      exit

    } else {

      SET $pop  ch_form "%s " 
    }
    #------------------------------------------------------------
    
    if {$::is_print} { 
      puts ""
      puts "POP_PRINT  11111111111111111 : "
      puts ""
      
      pop_print $pop
    }

    #     /* ga_sa() is called instead of ga_evolution().  We use the best of the
    #      * initial 50 population members.  This entity is overwritten with an
    #      * improved version.
    #      */

    #set solution [ga_get_entity_from_rank  $pop 0]
    set solution "NULL"

    if {$::is_print} { 
      puts ""
      puts "solution = $solution"
      puts ""

      #item_print_ch  $solution
    }
    
    ga_sa  $task $pop      \
           $solution \
           $max_iterations 
    
    #pop_print $pop
    #exit
    
    # // попробуем вот так:
    # // 
    ga_population_score_and_sort  $pop $task

    set bestentity [ga_get_entity_from_rank $pop 0]
    
    puts ""
    puts [format "Final best: i = %d, seed = %d  fitness %f, beststring = " $i $seed \
            [item_get_fitn $bestentity]]

    item_print_ch $bestentity ""
    puts ""

    # ошибка в ch_form: надо {%s }, а у нас в JIM почему-то просто %s
    # это было в a-comm.tl : proc SET - скобочки {} надо для всех значений !!??
    #
    #puts stderr "bestentity = [set $bestentity]"

    puts ""
    
    #     // Just used here to write the resulting solution.
    #     //
    #     //pingpong_iteration_callback (i, solution);	
    #     //pingpong_iteration_callback (i, bestentity);	
    
    #     ga_extinction (pop);
  }
  
} 
# //------------------------------------------------------------------------------
# // 
# // l_pingpong _09
# // 
# // - вводить все параметры через командную строку;
# // - выделить общие процедуры по максимуму; 
# // 
# //------------------------------------------------------------------------------
proc main {} {

  #set ::NEWEST 1 ;# !!!!!!!!!!!!!!!!!!! OK !!!!

  global argc argv argv0

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #lset_test 

  #exit
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#   if (argc < 2) 
#     exit (EXIT_SUCCESS);

  set mode [lindex $argv 0] ;# имя выч. задачи

  set ::is_print 2 

  if     {$mode ==    "_09"}    { main_ga  9 } \
  elseif {$mode ==    "_25"}    { main_ga 25 } \
  elseif {$mode == "_t1_09"}    { main_t1  9 } \
  elseif {$mode == "_t1_25"}    { main_t1 25 } \
  elseif {$mode == "_t2_09"}    { main_t2  9 } \
  elseif {$mode == "_t2_25"}    { main_t2 25 } \
  elseif {$mode == "_sa"}       { main_sa    } \
  \
  else {
    puts ""
    puts "ERROR mode = $mode"
    puts ""
  }

#   if (!strcmp(argv[1], "_09"))    main_ga ( 9, argc, argv); // малое соревнование
#   if (!strcmp(argv[1], "_25"))    main_ga (25, argc, argv);

#   if (!strcmp(argv[1], "_t1_09")) main_t1 ( 9, argc, argv);
#   if (!strcmp(argv[1], "_t1_25")) main_t1 (25, argc, argv);

#   if (!strcmp(argv[1], "_t2_09")) main_t2 ( 9, argc, argv);
#   if (!strcmp(argv[1], "_t2_25")) main_t2 (25, argc, argv);

#   if (!strcmp(argv[1], "_sa"))    main_sa (argc, argv);

#   exit (EXIT_SUCCESS);
}
# //-----------------------------------------------------------------------------

main

# //-----------------------------------------------------------------------------
# //------------------------------------------------------------------------------

# /* X1:l_pingpong,_09 ... PASSED */
# /* X1:l_pingpong,_25 ... PASSED */
# /* X1:l_pingpong,_t1 ... PASSED */
# /* X1:l_pingpong,_t2 ... PASSED */

# //******************************************************************************


