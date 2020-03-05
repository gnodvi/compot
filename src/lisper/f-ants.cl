; -*-   mode: lisp ; coding: koi8   -*- ----------------------------------------

;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------

(defclass POLE (GAME) (   

  (array_make :accessor POLE-array_make)

  (i    :accessor POLE-i)
  (j    :accessor POLE-j)

  (dir  :accessor POLE-dir)
  (arr  :accessor POLE-arr)
  (num  :accessor POLE-num)
))

(defmacro make-POLE () `(make-instance 'POLE))

;-------------------------------------------------------------------------------

;(defvar ant_angeline  '(IF-FOOD-AHEAD 
;                        (MOVE)   
;                        (PROGN (RIGHT)    ; --> 2
;                               (IF-FOOD-AHEAD ; 2
;                                (MOVE)   
;                                (PROGN (RIGHT)    ; --> 3
;                                       (IF-FOOD-AHEAD ; 3
;                                        (MOVE)
;                                        (PROGN (RIGHT)    ; --> 4 
;                                               (IF-FOOD-AHEAD ; 4 
;                                                (MOVE)
;                                                (PROGN (RIGHT)    ; --> 5
;                                                       (IF-FOOD-AHEAD ; 5
;                                                        (MOVE)
;                                                        (MOVE) 
;                                                        )
;                                                       )
;                                                )
;                                               )
;                                        ) 
;                                       )
;                                )
;                               )
;                        )
;  )

;-------------------------------------------------------------------------------


(defun tsarev_1 ()
  (eval '(IF-FOOD-AHEAD 
   (PROGN (MOVE)  (tsarev_1)) 
   (PROGN (MOVE)) 
   ))
)

(defun tsarev_2 ()
  (eval '(IF-FOOD-AHEAD 
   (PROGN (MOVE)) 
   (PROGN (LEFT) (tsarev_4)) 
   ))
)

(defun tsarev_3 ()
  (eval '(IF-FOOD-AHEAD 
   (PROGN (MOVE)  (tsarev_2)) 
   (PROGN (LEFT)  (tsarev_2)) 
   ))
)

(defun tsarev_4 ()
  (eval '(IF-FOOD-AHEAD 
   (PROGN (MOVE)  (tsarev_1)) 
   (PROGN (RIGHT) (tsarev_1)) 
   ))
)

(defvar ant_tsarev_83g '(IF-FOOD-AHEAD 
                         (MOVE)   
                         (PROGN (RIGHT) (tsarev_3))
                         )
  )

;;;-----------------------------------------------------------------------------

(defun tsar_1 ()
  (eval '(IF-FOOD-AHEAD 
   (PROGN (MOVE)   (tsar_5)) 
   (PROGN (RIGHT)  (tsar_2)) 
   ))
)

(defun tsar_2 ()
  (eval '(IF-FOOD-AHEAD 
   (MOVE)
   (PROGN (RIGHT)  (tsar_4)) 
   ))
)

(defun tsar_3 ()
  (eval '(IF-FOOD-AHEAD 
   (PROGN (MOVE)   (tsar_3)) 
   (PROGN (RIGHT)  (tsar_1)) 
   ))
)

(defun tsar_4 ()
  (eval '(IF-FOOD-AHEAD 
   (PROGN (MOVE)  (tsar_5)) 
   (RIGHT)  
   ))
)

(defun tsar_5 ()
  (eval '(IF-FOOD-AHEAD 
   (PROGN (MOVE)  (tsar_2)) 
   (MOVE) 
   ))
)


(defvar ant_tsarev_85g '(IF-FOOD-AHEAD 
                         (PROGN (MOVE) (tsar_3))
                         (PROGN (MOVE) (tsar_3))
                         )
  )

;-------------------------------------------------------------------------------

; На рис. 3 изображeн граф пeрeходов построeнного разработанным алгоритмом 
; автомата с сeмью состояниями, котрый позволяeт муравью съeсть всю eду 
; за 190 ходов.

;;;------------------------
(defun shalito_2 ()

  (if *debug_print* (format t "shalito_2 ~%"))

  (eval '(IF-FOOD-AHEAD 
   (PROGN  (MOVE) (shalito_4)) 
   (MOVE) 
   ))
)
;;;------------------------
(defun shalito_3 ()

  (if *debug_print* (format t "shalito_3 ~%"))

  (eval '(IF-FOOD-AHEAD 
   (PROGN   (MOVE) (shalito_7)) 
   (PROGN  (RIGHT) (shalito_5)) 
   ))
)
;;;------------------------
(defun shalito_4 ()

  (if *debug_print* (format t "shalito_4 ~%"))

  (eval '(IF-FOOD-AHEAD 
   (PROGN  (MOVE) (shalito_5)) 
   (PROGN  (MOVE) (shalito_2)) 
   ))
)
;;;------------------------
(defun shalito_5 ()

  (if *debug_print* (format t "shalito_5 ~%"))

  (eval '(IF-FOOD-AHEAD 
   (PROGN   (MOVE) (shalito_2)) 
   (PROGN  (RIGHT) (shalito_6)) 
   ))
)
;;;------------------------
(defun shalito_6 ()

  (if *debug_print* (format t "shalito_6 ~%"))

  (eval '(IF-FOOD-AHEAD 
   (PROGN   (MOVE) (shalito_7)) 
   (PROGN   (LEFT) (shalito_2)) 
   ))
)
;;;------------------------
(defun shalito_7 ()

  (if *debug_print* (format t "shalito_7 ~%"))

  (eval '(IF-FOOD-AHEAD 
   ;(PROGN   (MOVE) (shalito_4))  !!!! была ошибка !!!
   ;(PROGN   (MOVE) (shalito_2)) 

   (PROGN   (MOVE) (shalito_2)) 
   (PROGN   (MOVE) (shalito_4)) 
   ))
)
;;;------------------------

(defvar ant_shalito  '(IF-FOOD-AHEAD 
                  (PROGN  (MOVE) (shalito_5))
                  (PROGN (RIGHT) (shalito_3))
                  )
  )

;-------------------------------------------------------------------------------
;; подобно как в 
;; Santa Fe trail (i.e., trails with single gaps, double
;; gaps, single gaps at corners, double gaps at corners, and triple gaps at 
;; corners appearing in any order).
  
;;;-----------------------------------------------------------------------------
(defun arr_make_2 ()

(let (arr)

  (setf arr (make-array '(32 32) :initial-contents '(
             (* x x x x x x x x x x * * * * * * * * * * * * * * * * * * * * *) 
             (* * * * * * * * * * x * * * * * * * * * * * * * * * * * * * * *) 
             (* * * * * * * * * * x * * * * * * * * * * * * * * * * * * * * *) 
             (* * * * * * * * * * x * * * * * * * * * * * * * * * * * * * * *) 
             (* * * * * * * * * * x * * * o x * * * * * * * * * * * * * * * *) 
             (x x x x * * * * * * x * * * o * * * * * * * * * o x x x x x x x) 
             (* * * x * * * * * * x * * * o * * * * * * * * * x * * * * * * *) 
             (* * * x * * * * * * x * * * x * * * * * * * * * x * * * * * * *) 
             (* * * x * * * * * * x o x o o * * * * * * * * * x * * * * * * *) 
             (* * * x * * * * * * x o * * * * * * * * * * * * x * * * * * * *) 
             (* * * x x x x x x x x o * * * * * * * * * * * * x * * * * * * *) 
             (* * * * * * * * * * * x * * * * * * o x x x x x o * * * * * * *) 
             (* * * * * * * * * * * o o o x o * * x * * * * * * * * * * * * *) 
             (* * * * * * * * * * * * * * * o * * x * * * * * * * * * * * * *) 
             (* * * * * * * * * * * * * * * x * * x * * * * * * * * * * * * *) 
             (* * * * * * * * * * * o x o o o * * x * * * * * * * * * * * * *) 
             (* * * * * * * * * * * o * * * * * * x * * * * * * * * * * * * *) 
             (* * * * * * * * * * * x * * * * * * x * * * * * * * * * * * * *) 
             (* * * * * * * o x o o o * * * * * * o * * * * * * * * * * * * *) 
             (* * * * * * * o * * * * * * * * * * o * * * * * * * * * * * * *) 
             (* * * * * * * o * * * * * * * * * * x * * * * * * * * * * * * *) 
             (* * * * * * * x * * * * * * * * * * x * * * * * * * * * * * * *) 
             (* * * * o x o o * * * * * * * * * * x * * * * * * * * * * * * *) 
             (* * * * o * * * * * * * * * * * * * x * * * * * * * * * * * * *) 
             (* * * * x * * * * * * * * * * * * * x * * * * * * * * * * * * *) 
             (* * * * x * * * * * * * * * * * * * x * * * * * * * * * * * * *) 
             (* * * * x * * * * * * * * * * * * * o * * * * * * * * * * * * *) 
             (* * * * x o o x x x x o x x x x x x o * * * * * * * * * * * * *) 
             (* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *) 
             (* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *) 
             (* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *) 
             (* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *) 
             ))
        )

  arr
))
;===============================================================================
;-------------------------------------------------------------------------------
(defun arr_set_random_val (arr val r_val)

(let (
  r
  )

  (dotimes (i (array-dimension arr 0)) 
  (dotimes (j (array-dimension arr 1)) 

    (setf r (YRandF 0 1))
    (when (<= r r_val)
      (setf (aref arr i j) val)
      )
  ))

))
;-------------------------------------------------------------------------------
(defun arr_make_random ()

(let (
  (mn  0.2)
  (arr (make-array '(32 32)))
  )

  (Y-srand48 2011)

  (arr_set_random_val  arr '*  1.0)
  (arr_set_random_val  arr 'x   mn)

  arr
))
;;;-----------------------------------------------------------------------------
(defun arr_print (arr i0 j0 dir)

  (dotimes (i (array-dimension arr 0)) 
  (dotimes (j (array-dimension arr 1)) 

    (if (and (= i i0) (= j j0))        
      ;(format t "@ ")
      (format t "~A " dir)
      (format t "~A " (aref arr i j))
        )
  )
  (format t "~%")
  )

  (format t "~%")
)
;;;-----------------------------------------------------------------------------
(defun eat_init_calc (arr)

(let (
 (eat_init 0)
 )

  (dotimes (i (array-dimension arr 0)) 
  (dotimes (j (array-dimension arr 1)) 

    (when (eq (aref arr i j) 'x)
      (incf eat_init)
      )
  ))

  eat_init
))
;;;-----------------------------------------------------------------------------
(defun pole_create_ (array_make)

(let (
  (pol (make-POLE))  ;; создадим новую пструктуру
  )

  (setf (POLE-array_make pol)  array_make)
  (setf (GAME-print      pol)  'pole_print)

  (setf *gameptr*        pol)  ; установим еще и глобально

  pol
))
;;;-----------------------------------------------------------------------------
(defun pole_init (pol)

  (setf (POLE-arr pol) (funcall (POLE-array_make pol)))

  ; управляющие параметры 
  (setf (POLE-i   pol)  0)
  (setf (POLE-j   pol)  0)
  (setf (POLE-dir pol)  '>)

  (setf (GAME-fit pol)  0)  
  (setf (POLE-num pol)  0)  

  ;; посчитаем начальные параметры еды
  (setf (GAME-fitfull pol) (eat_init_calc (POLE-arr pol)))  

  pol
)
;;;-----------------------------------------------------------------------------
(defun pole_arr_print (pole)

  (format *error-output* "================================================ ~%")  

  (arr_print (POLE-arr pole) (POLE-i pole) (POLE-j pole) (POLE-dir pole))

  (format t "EAT = ~A / ~A ~%" (GAME-fit pole) (GAME-fitfull pole))  
  (format t "NUM = ~A ~%"      (POLE-num pole))  

  (format *error-output* "================================================ ~%")  
  (format t "~%")  
)
;;;-----------------------------------------------------------------------------
(defun pole_print (pol)

  (pole_arr_print  pol)

)
;-------------------------------------------------------------------------------
(defun ant_t2 (argus) (declare (ignore argus))

(let* (
  (pol  (pole_create_ 'arr_make_random))
  )

  (pole_init pol)
  (game_print)

))
;-------------------------------------------------------------------------------
; cl y~.cl ANTS ant_t2  - можно уже тестировать !!
;;;-----------------------------------------------------------------------------
(defun ij_after_move_old (dir i j)

  (if (eq dir '>) (incf j))
  (if (eq dir '<) (decf j))

  (if (eq dir '^) (decf i))
  (if (eq dir 'V) (incf i))

  (list i j)
)
;;;-----------------------------------------------------------------------------
(defun set_ij_after_move (dir r_i r_j)
(let* (
  (i  (symbol-value r_i))
  (j  (symbol-value r_j))

  (arr (POLE-arr *gameptr*))
  (i_dim (array-dimension arr 0))
  (j_dim (array-dimension arr 1))
  )

  (if (eq dir '>) (incf j))
  (if (eq dir '<) (decf j))
  (if (eq dir '^) (decf i))
  (if (eq dir 'V) (incf i))

  (if (= i i_dim) (setf i 0))
  (if (= j j_dim) (setf j 0))
  (if (= i -1) (setf i (decf i_dim)))
  (if (= j -1) (setf j (decf j_dim)))

  (set r_i  i)
  (set r_j  j)
))
;;;-----------------------------------------------------------------------------
(defun pole_move (pole)

(let (
 (dir (POLE-dir pole))
 (i   (POLE-i pole))
 (j   (POLE-j pole))
 )
  (declare (special i j)) ; чтобы менять эту переменную динамически

  (setf (aref (POLE-arr pole) i j) '-)

  (set_ij_after_move dir 'i 'j)

  (setf (POLE-i pole) i)
  (setf (POLE-j pole) j)

  (when (eq (aref (POLE-arr pole) i j) 'X) ;; на этом полe была eда
      (incf (GAME-fit pole)) ;; 
      ;(setf *last_eat_num* (POLE-num pole))
    )

))
;;;-----------------------------------------------------------------------------
(defun pole_right (pole)

(let (
 (dir (POLE-dir pole))
 )

  (case dir
    (^ (setf dir '>))
    (> (setf dir 'V))
    (V (setf dir '<))
    (< (setf dir '^))
    )

  (setf (POLE-dir pole) dir)
))
;;;-----------------------------------------------------------------------------
(defun pole_left (pole)

(let (
 (dir (POLE-dir pole))
 )

  (case dir
    (^ (setf dir '<))
    (< (setf dir 'V))
    (V (setf dir '>))
    (> (setf dir '^))
    )

  (setf (POLE-dir pole) dir)
))
;;;-----------------------------------------------------------------------------
(defun pole_is_dir_food (pole)

(let (
 (dir (POLE-dir pole))
 (i   (POLE-i pole))
 (j   (POLE-j pole))
 )

  (declare (special i j)) ; чтобы менять эту переменную динамически
  (set_ij_after_move dir 'i 'j)

  (if (eq (aref (POLE-arr pole) i j) 'X)
      T
    nil
    )

))
;;;-----------------------------------------------------------------------------
;;;-----------------------------------------------------------------------------
(defun MOVE ()

  (pole_move *gameptr*)
  (incf (POLE-num *gameptr*)) 

  (if *debug_print* (format t "MOVE ~%"))
)
;;;-----------------------------------------------------------------------------
(defun LEFT ()

  (pole_left *gameptr*)
  (incf (POLE-num *gameptr*)) 

  (if *debug_print* (format t "LEFT: num= ~s  ~%" (POLE-num *gameptr*)))
)
;;;-----------------------------------------------------------------------------
(defun RIGHT ()

  (pole_right *gameptr*)
  (incf (POLE-num *gameptr*)) 

  (if *debug_print* (format t "RIGHT ~%"))
)
;;;-----------------------------------------------------------------------------
(defun NO ()

  (incf (POLE-num *gameptr*)) 

  (if *debug_print* (format t "NO ~%"))
)
;;;-----------------------------------------------------------------------------
;-------------------------------------------------------------------------------
(defmacro IF-FOOD-AHEAD (then-argument else-argument)

  `(if (pole_is_dir_food *gameptr*)
      (eval ',then-argument)
      (eval ',else-argument)
      )
)
;-------------------------------------------------------------------------------
; работаем мураша заданного непосредственно макросами лиспа
; т.е. "деревом решений", а не автоматом-графом в любом виде
;-------------------------------------------------------------------------------
(defun game_loop_all_num (lisp_form n)


  ;(format t "game_loop_all_num:  lisp_form= ~s   n= ~s  ~%" lisp_form n)
  ;(quit)

  (loop 
    while (< (POLE-num *gameptr*) n) do
    (eval lisp_form)
    )

)
;-------------------------------------------------------------------------------
(defun game_loop_eval_any_key (lisp_form)

  (loop
    (format t "Press Any Key: ~%")
    (read-char)
    (eval lisp_form)
    (game_print)
    )

)
;-------------------------------------------------------------------------------
(defun game_do_eval_steps (lisp_form steps)

(let* (
  (pol  (pole_create_ 'arr_make_2))
  )

  (format t "~%")
  (format t "PROG= ~s ~%" lisp_form)
  (format t "~%")

  (pole_init pol)

  (if (= steps 0)
    (progn
      (setf *debug_print* t)
      (game_loop_any_key lisp_form)
      )
    (progn
      (game_loop_all_num lisp_form steps)
      (game_print)
      )
    )

))
;-------------------------------------------------------------------------------
(defun ant_test_shalito (argus) (declare (ignore argus))

  (game_do_eval_steps  ant_shalito 200)

)
;-------------------------------------------------------------------------------

