; -*-   mode: lisp ; coding: koi8   -*- ----------------------------------------

;-------------------------------------------------------------------------------
;/*******************************************************************************
; *                                                                             *
; *  Имя этого файла: k~test.c                                                  *
; *                                                                             *
;  ******************************************************************************
; */ 
                                                                             

;#include "a_comm.h"

;#include "e_tabs.h"
;#include "e_tour.h"

;#include "y_rsb_.h"

;/******************************************************************************/

;/*----------------------------------------------------------------------------*/
;/* void */
;/* turnir_parse_cmdline (int argc, char** argv, int j,  */
;/*                       int *p_seed, int *p_nums) */
;/* { */
;/*   if (argc == j) { */
;/*     printf ("Need argument(s): \n"); */
;/*     printf ("<seed> <tur_nums> \n"); */
;/*     return; */
;/*   } */

;/*   *p_seed = atoi (argv[j]);  */
;/*   j++; */
;/*   *p_nums = atoi (argv[j]);  */

;/*   return; */
;/* } */
;/*----------------------------------------------------------------------------*/
;void
;rsb_big_main (int argc, char** argv, int j)
;/*----------------------------------------------------------------------------*/
(defun rsb_big_main (argus) (declare (ignore argus))

;  int seed;
;  int tur_nums; // кол-во круговых турниров (круговиков) [1, 4, 50]

;  turnir_parse_cmdline (argc, argv, j, &seed, &tur_nums);
;  rsb_bigtest (tur_nums, seed); 

  (rsb_bigtest 1 2010) ; пока так, явно задавая

;  return;
)
;/*----------------------------------------------------------------------------*/
;void
;rsb_min_main (int argc, char** argv, int j)
;/*----------------------------------------------------------------------------*/
(defun rsb_min_main (argus) (declare (ignore argus))

;  int seed;
;  int tur_nums; // кол-во круговых турниров (круговиков) [1, 4, 50]

;  turnir_parse_cmdline (argc, argv, j, &seed, &tur_nums);
;  rsb_mintest (tur_nums, seed); 
  ;(format t "1 ... ~%")

  (rsb_mintest 1 2010) ; пока так, явно задавая
  ;(format t "2 ... ~%")

;  return;
)
;-------------------------------------------------------------------------------
;void
;rsb_new_main (int argc, char** argv, int j)
;-------------------------------------------------------------------------------
(defun rsb_new_main (argus)  (declare (ignore argus))

;  int seed;
;  int tur_nums; // кол-во круговых турниров (круговиков) [1, 4, 50]

;  turnir_parse_cmdline (argc, argv, j, &seed, &tur_nums);
;  rsb_newtest (tur_nums, seed); 
;(format t "TEST3 ~%")

  (rsb_newtest 1 2010) ; пока так, явно задавая

;  return;
)
;/*----------------------------------------------------------------------------*/
;/* void */
;/* tour_main (int argc, char** argv, int j) */
;/* { */
;/*   int seed; */
;/*   int tur_nums; // кол-во круговых турниров (круговиков) [1, 4, 50] */

;/*   turnir_parse_cmdline (argc, argv, j, &seed, &tur_nums); */
;/*   test_turnir (tur_nums, seed); */

;/*   return; */
;/* } */
;/*-----------------------------------------------------------------------------*/



;/*============================================================================*/
;int 
;main (int argc, char** argv) 
;{
;  char *name;
;  int   j;

;  printf ("\n");

;  //if (argc == 1) {
;    //printf ("  tour <seed> <nums> \n");
;  //   printf ("  rsb_big <seed> <nums> \n");
;  //   printf ("  rsb_min <seed> <nums> \n");
;  //goto END;
;  //}

;  //-------------------------
;  j = 1;
;  name = argv[j++];
;  //-------------------------

;  //if (!strcmp (name, "tour"))     tour_main (argc, argv, j);
;  if (!strcmp (name, "rsb_big"))  rsb_big_main (argc, argv, j);
;  if (!strcmp (name, "rsb_min"))  rsb_min_main (argc, argv, j);

;  if (!strcmp (name, "rsb_new"))  rsb_new_main (argc, argv, j);

;  //END:
;  printf ("\n");
;  return (0);
;}
;/*============================================================================*/
;-------------------------------------------------------------------------------
(defun l_test (argus)  (declare (ignore argus))

(let (
  (list_bots (list 
;             '("Random (Optimal)"    randbot)
;             '("Good Ole Rock"       rockbot)
;             '("R-P-S 20-20-60"      r226bot)

             '("Rotate R-P-S"        rotatebot)
;             '("Beat The Last Move"  copybot)
             '("Always Switchin'"    switchbot)

;             '("f_russrocker4" foreign_russrocker4)
             ))
  )

  ;(setf TRIALS 10) ;# для отладки
  (setf TRIALS   10)
  (setf *simp_random* t)

  (rsb_run_turnir 1 2010 list_bots)

))
;-------------------------------------------------------------------------------
(defun f_test (argus)  (declare (ignore argus))

(let (
  (list_bots (list 
;             '("Random (Optimal)"    randbot)
;             '("Good Ole Rock"       rockbot)
;             '("R-P-S 20-20-60"      r226bot)

             '("_Rotate R-P-S"        foreign_rotatebot)
;             '("Beat The Last Move"  copybot)
             '("_Always Switchin'"    foreign_switchbot)

;             '("F- RussRocker4" foreign_russrocker4)
             ))
  )

  (rsb_run_turnir 1 2010 list_bots)
))
;===============================================================================
