; -*-   mode: lisp ; coding: koi8   -*- ----------------------------------------

;-------------------------------------------------------------------------------
;(load "l-gena.cl")


(defvar  *lis_n*      :unbound)
(defvar  *lis_tset*  '(:floating-point-random-constant))


;===============================================================================
;
(defvar *fmin_old* -5.0)
(defvar *fmax_old* +5.0)

;-------------------------------------------------------------------------------
; случайный выбор терминала из терминального набора;
; если выбранный терминал - особое эфимерное значение, то для них соответственно:
;
; если :Floating-Point-Random-Constant то
;   создается вещественная единичной точности случайная константа [-5.0 , 5.0]
;
; если :Integer-Random-Constant то
;   создается целая случайная константа в диапазоне [-10 , +10]
;-------------------------------------------------------------------------------
(defun choose-from-terminal-set_old (terminal-set)

(let* ( ; локальные переменные
  (choice_int (random-integer (length terminal-set)))
  (choice     (nth choice_int terminal-set))

  ;(choice (nth (random-integer (length terminal-set)) terminal-set))
  )

  (case choice

    (:floating-point-random-constant
     ;; двойная точность более "дорогая", но если она действительно нужна
     ;; достаточно просто упростить клозу, убрав "coerce";
     ;; также здесь можно изменить диапазон, если нужен не [-5.0 , +5.0]
     ;(coerce (- (random-floating-point-number 10.0) 5.0)
     (coerce (- (random-floating-point-number (- *fmax_old* *fmin_old*)) 
                (- 0.0 *fmin_old*))
             'single-float))

    (:integer-random-constant 
     (- (random-integer 21) 10)) ; получаем диапазон [-10 , +10]

    (otherwise choice)) ; обычно просто возвращаем выбранный терминал
  
))
;===============================================================================
;
;-------------------------------------------------------------------------------
(defun lis_evaluate_fitness_SUM	(genotype data) 
(declare (ignore data))             

(let (
  (hits 0)
  ) 
  
  (dotimes (i *lis_n*)
    (setf hits (+ hits (nth i genotype)))
  )

  (values (* hits 1.0) hits )
))	                                                             
;-------------------------------------------------------------------------------
(defun lis_evaluate_fitness_EQL	(genotype data)	                                     

(let (
  (hits 0)
  ) 
  
  (dotimes (i *lis_n*)
    (if (= (nth i data) (nth i genotype))
        (incf hits)
    )
  )

  (values (* hits 1.0) hits )
))	                                                             
;-------------------------------------------------------------------------------
(defun lis_evaluate_fitness_BIN	(genotype data)	                                     
(declare (ignore data))	                     

(let (
  (value (int_from_bin genotype *lis_n*))
  ) 
  
  (values (* value 1.0) value )
))	                                                             
;-------------------------------------------------------------------------------
(defun lis_create_id_attempts (r_attempts-at-this-individual)

(let (
  (attempts-at-this-individual  (symbol-value r_attempts-at-this-individual))
  )

  (format t "> attempts-at-this-individual 20")

  (set r_attempts-at-this-individual  attempts-at-this-individual)
))
;-------------------------------------------------------------------------------
(defun lis_create_id (&optional index)

(declare (ignore index))

(let* (
   (new-vals (make-list *lis_n*))
  )

  (dotimes (i *lis_n*)
    (setf (nth i new-vals) (choose-from-terminal-set_old *lis_tset*))
  )

  new-vals
))
;-------------------------------------------------------------------------------
(defun lis_create_population ( n tset
                                 size-of-population
                                 seeded-genotypes ;seed
                                 )

  (setf *lis_tset*  tset)
  (setf *lis_n*     n)

  ;(seed_set seed)

  (population_create size-of-population
                      seeded-genotypes
                      
                      'lis_create_id
                      'lis_create_id_attempts
                      )
)
;-------------------------------------------------------------------------------
(defun lis_crossover_1 (mal fem &optional opt)
(declare (ignore opt))

(let* (
  (len (length mal))
  ;(p (random-integer len)) ; mutation-point
  p ;(p 3)
  (mal_new (copy-list mal))
  (fem_new (copy-list fem))
  )

  (setf p (random-integer len))

  ;(format t "--------------- ~%")
  ;(format t "p= ~A ~%" p)

  (do ((i p (incf i))) ((= i len)) 
    
    (setf (nth i mal_new) (nth i fem)) 
    (setf (nth i fem_new) (nth i mal)) 
  )
 
  ;(format t "--------------- ~%" p)
  ;(values mal fem)
  (values mal_new fem_new)
))
;-------------------------------------------------------------------------------
(defun lis_mutate (lis)

(let* (
  (len (length lis))
  ;(m (random-integer len)) ;; ???!!! m=9 всeгда!
  m
  (new (choose-from-terminal-set_old *lis_tset*))
  (lis_new (copy-list lis))
  )

  (setf m (random-integer len))

  ;(format t "--------------- ~%")
  ;(format t "m  = ~A ~%" m)
  ;(format t "--------------- ~%")

  (setf (nth m lis_new) new)
  lis_new 
))
;-------------------------------------------------------------------------------
;
;-------------------------------------------------------------------------------
(defun lis_test_0 (argus)  (declare (ignore argus))

(let (
   ;(t1  '(:floating-point-random-constant))
   (*lis_tset* '(:integer-random-constant))
 
   (l1  '(0 1 2 3 4 5 6 7 8 9))
   (l2  '(a b c d e f g h i j))
   )

  (format t "~%")
  ;(seed_set 0.6)
  (seed_set_random)

  (format t "l1= ~A ~%" l1)
  (format t "l2= ~A ~%" l2)
  (format t "~%")

  (setf l1 (lis_mutate l1))

  (format t "l1= ~A ~%" l1)
  (format t "l2= ~A ~%" l2)
  (format t "~%")

  (multiple-value-bind  (new_l1 new_l2)
      (lis_crossover_1 l1 l2)
    (setf l1 new_l1)
    (setf l2 new_l2)
    )

  (format t "l1= ~A ~%" l1)
  (format t "l2= ~A ~%" l2)
  (format t "~%")

  ;;------------------------
  (dotimes (i 20)
    (format t "random-integer= ~A ~%" (random-integer 10)) 
  )

  (format t "~%")
))
;-------------------------------------------------------------------------------
;
;-------------------------------------------------------------------------------
(defun optimum_print_x_old (genotype make_calc_xi data)

(let ( 
  (*print-pretty* t) ; здесь глобальная, меняется локально для этой функции

  xi
  )
 
  (format t "PRINT_BEST_OPTIMUM: ~%")            
  (format t "~%")

  (setf xi (funcall  make_calc_xi genotype data))	                                     
  (format t "X= ~A ~%" xi)
  ;(format_bord75) ;===========================

))
;-------------------------------------------------------------------------------
(defun lis_test_1 (argus)  (declare (ignore argus))
(let (
   (vals  '(3.2584867 -3.2887073  3.7805939 4.809394  2.6604538))
   )

  (optimum_print_x_old vals
                   (function (lambda (genotype data) (declare (ignore data)) genotype))
                   ;(function (lambda (genotype) genotype))
                   NIL
                   )

  (multiple-value-bind (fits hits)
      (optimum_eval_xx vals)

    (format t "fits=~S  hits=~S ~%" fits hits)	                                     
    )

  (format t "~%")
))
;-------------------------------------------------------------------------------
(defun lis_test_2 (argus)  

(declare (ignore argus))

(let (
   pop 
  )

  (seed_set 1.0)

  (setf pop (lis_create_population 8 '(0 1)
                                   10 ;150   ; size-of-population
                                   (list 
                                    '(0 0 0 0 0 0 0 0) 
                                    '(1 1 1 1 1 1 1 1)
                                    )
                                   ;1.0 ; seed
                                   ))

  (population_utils pop 
                    ;'lis_evaluate_fitness_SUM NIL 
                    ;'lis_evaluate_fitness_EQL '(0 0 1 1 1 1 0 0) 
                    'lis_evaluate_fitness_BIN NIL 
                    'sort-population-by-fitness_0 
                    )

  (population_print pop
                    (lambda () (format t "~%"))
                    )

  (format t "~%")
))
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
(defun lis_run_test (n tset 
                size-of-population  maximum-generation
                calc-sfitness-proc data
                termination  
                crossover_fraction reproduction_fraction
                )  
(let (
  (population (lis_create_population  n 
                                      tset
                                      size-of-population
                                      NIL ; seeded-genotypes
                                      ))
  )

  (population_print population)
  
  (execute_generations_  population  maximum-generation
                         'sort-population-by-fitness_0
                         
                         :fitness-proportionate
                         calc-sfitness-proc  data
                         termination 
                         
                         crossover_fraction    ;0.4
                         reproduction_fraction ;0.1
                         'lis_crossover_1 
                         'lis_mutate 
                         'ga_print_parameters  
                         t ; *is_print*
                         )
  ;ret
))
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------