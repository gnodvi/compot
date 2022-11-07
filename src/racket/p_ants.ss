;;; -*- Mode:LISP; Base:10; Syntax:Common-Lisp; -*-

;;;=============================================================================

;;  GENP    GENP    GENP    GENP    GENP    GENP    GENP    GENP    GENP    

;;;=============================================================================
; 7.2 Artificial Ant

; As a second illustration of genetic programming, consider the task of 
; navigating an artificial ant attempting to find all the food lying along an
; irregular trail as described in subsection 3.3.2 (Jefferson et al. 1991; 
; Collins and Jefferson 1991a, 1991b). The problem involves primitive
; operations enabling the ant to move forward, turn right, turn left, and sense 
; food along the irregular Santa Fe trail (figure 3.6).

; When Jefferson, Collins, et al. used the conventional genetic algorithm 
; operating on strings to find the finite-state automaton to solve this
; problem, it was first necessary to develop a representation scheme that 
; converted the potential automaton into binary strings of length 453. In
; genetic programming, the problem can be approached and solved in a far more 
; direct way using 
; the natural terminology of the problem.

;;-------------------------------------------------------------------------------
;;-------------------------------------------------------------------------------

(define  number_of_foods     'unbound-01)
(define  max_steps           'unbound-02)
(define  array_make_func     'unbound-03)

;-------------------------------------------------------------------------------
(define (define_fitness_cases_NIL)

  (values NIL)
)
;-------------------------------------------------------------------------------
(define (evaluate_standardized_fitness_ANTS  program fitness-cases)                     

;(declare (ignore fitness-cases))

(let (
  (raw-fitness 'undef)
  (hits        'undef) 
  (standardized-fitness 'undef)
  (pol  (pole_create_  array_make_func))	     
  ) 

  (setf raw-fitness 0.0)	                                     
  (setf hits 0)	                                             

  ;(pole_create_init 'arr_make_0)
  ;(pole_create_init array_make_func)
  (pole_init  pol)

  ;; Each move operation and each turn operation takes one step. In our version 
  ;; of this problem, we limited the ant to 400 time steps

  ;; Time was computed here in the same way as in the work of Jefferson, Collins, 
  ;; et al. That is, the three primitive functions RIGHT, LEFT,
  ;; and MOVE each take one time step to execute, whereas the IF-FOOD-AHEAD 
  ;; conditional branching operator and the unconditional
  ;; connectives PROGN2 and PROGN3 each take no time steps to execute.


  ;(printf "evaluate_standardized_fitness_ANT .. 1 ~n")

  (game_loop_all_num program max_steps)

  ;(printf "evaluate_standardized_fitness_ANT .. 2 ~n")

  (setf raw-fitness (GAME-fit *gameptr*))
  (setf hits raw-fitness)

  (setf standardized-fitness (- number_of_foods raw-fitness))
	                     
  (values standardized-fitness hits)	                            
))	                                                             
;;-------------------------------------------------------------------------------
(define (define_parameters_ANTS)

  ;(setf *number-of-fitness-cases*                 89) ;; ЧТОБЫ БЫЛ КРИТEРИЙ ОСТАНОВА

  (set! *max-depth-for-new-individuals*                 6)
  (set! *max-depth-for-individuals-after-crossover*    17)

  (set! *reproduction-fraction*                       0.1)
  (set! *crossover-at-any-point-fraction*             0.2)
  (set! *crossover-at-function-point-fraction*        0.2)

  (set! *max-depth-for-new-subtrees-in-mutants*         4)

;  (set! *method-of-selection*      :fitness-proportionate)
;  (set! *method-of-generation*     :ramped-half-and-half)
;  (set! *method-of-selection*      'fitness-proportionate)
  (set! *method-of-selection*      'mos_fitness-proportionate)

  (set! *method-of-generation*     'ramped-half-and-half)
;  (set! *method-of-generation*     "ramped-half-and-half")

  (set! *is_ADF_as_OLD* #t) ;; надо было для совместимости результатов

  (values)
)
;;-------------------------------------------------------------------------------
(define (define_termination_criterion_ANTS 
        current-generation                                 
        maximum-generations	                                     
        best-standardized-fitness	                             
        best-hits)
	                                             
  ;(declare (ignore best-standardized-fitness))	                     

  (values	                                                     
    (or (>= current-generation  maximum-generations)	             
        (>= best-hits           number_of_foods) ;!!!!
    ))	                                                             
)	                                                             
;;-------------------------------------------------------------------------------
(define (ANTS_)


  ; тут все-таки список или вектор нужен ???!!!

  (set_sms_list (list (list  

       '(IF-FOOD-AHEAD  PROGN  PROGN)  
       '(2              2      3)  

       '((LEFT) (RIGHT) (MOVE))
       ))
  )

  ;(setf array_make_func 'arr_make_0)
  (set! number_of_foods  89)
  ;(setf max_steps 400)

  (values 
          'define_fitness_cases_NIL
          'evaluate_standardized_fitness_ANTS

          'define_parameters_ANTS
          'define_termination_criterion_ANTS
  )
)
;;===============================================================================
;;
;;-------------------------------------------------------------------------------
(define (ANT_2)

  (set! array_make_func 'arr_make_2)
  (set! max_steps 200)

  (ANTS_)
)
;;-------------------------------------------------------------------------------
(define (ant_test_gp_new  argus)

;(printf "argus= ~s ~n" argus)
;(printf "1 arg= ~s ~n" (nth 0 argus))
;(printf "2 arg= ~s ~n" (nth 1 argus))
;(printf "2 arg= ~s ~n" (read_string (nth 1 argus)))

(let (
;  (random_flag  (read-from-string (nth 0 argus)))
;  (size         (parse-integer    (nth 1 argus))) ; размер популяции
;  (maxi         (parse-integer    (nth 2 argus))) ; сколько поколений считать

  (random_flag  (read_string  (nth 0 argus)))
  (size         (read_string  (nth 1 argus))) ; размер популяции
  (maxi         (read_string  (nth 2 argus))) ; сколько поколений считать

  )

  ;(printf "0.... ~n")

  (if (eq random_flag '!) ; флаг для полностью случайного запуска
    (seed_set_random)
    ;(seed_set 1.0) -  с этим не получилсоь !!
    (seed_set  1)
    )

  ;(printf "1.... ~n")

  (run-g-p-system 'ANT_2  ; problem-function
                    maxi  ; minimum-generation
                    size  ; size-of-population
                    null  ;NIL ; seeded-programs
                     )

  ;(printf "9.... ~n")

  (evaluate_standardized_fitness_ANTS
   (funcall *get_starter* (ORGANISM-genotype *best-of-run*))
   NIL)

  (game_print)

)
)
;;-------------------------------------------------------------------------------
;; cl r~.cl GENP ant_test_gp_new ! 40 10
;;-------------------------------------------------------------------------------
;(defun check_best_ant (argus) (declare (ignore argus))

;(let* (
;  (steps  200)
;;;  NUM = 200
;;--------------------------------------
;;EAT 58 / 89
;;(ant '(PROGN (MOVE)
;;             (PROGN (LEFT)
;;                    (IF-FOOD-AHEAD (LEFT) (RIGHT))
;;                    (IF-FOOD-AHEAD (MOVE) (RIGHT))))
;;     )
;;--------------------------------------

;;--------------------------------------
;;EAT = 42 / 89
;;(ant = '(IF-FOOD-AHEAD (IF-FOOD-AHEAD (MOVE)
;;                                      (RIGHT))
;;                       (IF-FOOD-AHEAD  (IF-FOOD-AHEAD (RIGHT) (RIGHT))
;;                                       (LEFT)))
;;     )
;; понятно, что такая конструкция эквивалентна этой:
;;(ant '(IF-FOOD-AHEAD (MOVE) (LEFT)) )
;;--------------------------------------
                 
;;--------------------------------------
;;EAT = 57 / 89
;(ant '(IF-FOOD-AHEAD (PROGN (MOVE) (MOVE) (MOVE))
;                     (PROGN (LEFT) (MOVE) (RIGHT)) )
;     )
;;--------------------------------------
                    
;  )

;  (game_do_eval_steps  ant steps)

;))
;;-------------------------------------------------------------------------------

;;-------------------------------------------------------------------------------
