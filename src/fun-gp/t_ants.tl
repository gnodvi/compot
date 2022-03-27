# -*-   mode: tcl  ; coding: koi8   -*- ----------------------------------------

#-------------------------------------------------------------------------------
#
#-------------------------------------------------------------------------------
#
# t-alib.tl  t-alib.tl  t-alib.tl  t-alib.tl  t-alib.tl  t-alib.tl  t-alib.tl  
#
#-------------------------------------------------------------------------------

#set ::version "11"

# ;-------------------------------------------------------------------------------

# (define *gameptr* 'unbound)
# сейчас: ::gameptr

  #set pol $::gameptr ;# вот так сработало.. а можно ли обойтись?
  # наверное нет, ведь "по ссылке" мы передаем не просто имя-ссылку, а 
  # некое соглашение о том на каком уровне вложенности лежит переменная;
  # можно бы передавать пару? но тогда это будет не переносимо!
  #
  # ну может тогда вообще не париться пока и сделать все глобально? раз уж так..
  # ха! ну так надо сделать некую симуляцию выделения памяти в куче Си:
  # там общий массив, а возвращает не ссылку , а идентификатор, номер в массиве!
  #
  # можно пока сделать глобально, если понадобиться - сделать массив глоб-инд.
  #


# ;(defclass GAME () (
# ;   (param1 :accessor GAME-param1)
# ;   (param2 :accessor GAME-param2)

# ;   (game_print :accessor GAME-print) ; процедура печати 
# ;   (fitfull    :accessor GAME-fitfull)    ; максимальное FIT
# ;   (fit        :accessor GAME-fit)        ; профит
# ;   (fitness    :accessor GAME-fitness)    ; недосдача (дополнение профита до FIT)
# ;))


# (define-struct GAME ( 

#    [param1     #:auto]
#    [param2     #:auto]

#    [print      #:auto]
# ;   [game_print #:auto]
#    [fitfull    #:auto]
#    [fit        #:auto]
#    [fitness    #:auto]
#   )

#   #:mutable 
#   #:auto-value 0
# )

# ;-------------------------------------------------------------------------------
# (defun game_print ()

#   (funcall (GAME-print *gameptr*) *gameptr*)

# )
# ;-------------------------------------------------------------------------------
#proc  game_print {{ptr "::gameptr"}} {}
proc  game_print {} {

  set ptr ::gameptr

  #
  #
  #item_calc_fitness  $best_item $fitnessfunc 


  set gamedict [set $ptr]

  set game_print_proc [dict get $gamedict "game_print"] ;# pole_print


  eval $game_print_proc $ptr

}
# ;-------------------------------------------------------------------------------
# ;;-------------------------------------------------------------------------------


# (define-struct (POLE GAME) (  ; вообщето мы должны наследовать от GAME??

#   [array_make  #:auto]
#   [i     #:auto]
#   [j     #:auto]

#   [dir   #:auto]
#   [arr   #:auto]
#   [num   #:auto]

#   )

#   #:mutable 
#   #:auto-value 0
# )
# ;;-------------------------------------------------------------------------------




# ;-------------------------------------------------------------------------------

# (defclass POLE (GAME) (   

#   (array_make :accessor POLE-array_make)

#   (i    :accessor POLE-i)
#   (j    :accessor POLE-j)

#   (dir  :accessor POLE-dir)
#   (arr  :accessor POLE-arr)
#   (num  :accessor POLE-num)
# ))

# (defmacro make-POLE () `(make-instance 'POLE))

# ;-------------------------------------------------------------------------------

# ;(defvar ant_angeline  '(IF-FOOD-AHEAD 
# ;                        (MOVE)   
# ;                        (PROGN (RIGHT)    ; --> 2
# ;                               (IF-FOOD-AHEAD ; 2
# ;                                (MOVE)   
# ;                                (PROGN (RIGHT)    ; --> 3
# ;                                       (IF-FOOD-AHEAD ; 3
# ;                                        (MOVE)
# ;                                        (PROGN (RIGHT)    ; --> 4 
# ;                                               (IF-FOOD-AHEAD ; 4 
# ;                                                (MOVE)
# ;                                                (PROGN (RIGHT)    ; --> 5
# ;                                                       (IF-FOOD-AHEAD ; 5
# ;                                                        (MOVE)
# ;                                                        (MOVE) 
# ;                                                        )
# ;                                                       )
# ;                                                )
# ;                                               )
# ;                                        ) 
# ;                                       )
# ;                                )
# ;                               )
# ;                        )
# ;  )

# ;-------------------------------------------------------------------------------


# (defun tsarev_1 ()
#   (eval '(IF-FOOD-AHEAD 
#    (PROGN (MOVE)  (tsarev_1)) 
#    (PROGN (MOVE)) 
#    ))
# )

# (defun tsarev_2 ()
#   (eval '(IF-FOOD-AHEAD 
#    (PROGN (MOVE)) 
#    (PROGN (LEFT) (tsarev_4)) 
#    ))
# )

# (defun tsarev_3 ()
#   (eval '(IF-FOOD-AHEAD 
#    (PROGN (MOVE)  (tsarev_2)) 
#    (PROGN (LEFT)  (tsarev_2)) 
#    ))
# )

# (defun tsarev_4 ()
#   (eval '(IF-FOOD-AHEAD 
#    (PROGN (MOVE)  (tsarev_1)) 
#    (PROGN (RIGHT) (tsarev_1)) 
#    ))
# )

# (defvar ant_tsarev_83g '(IF-FOOD-AHEAD 
#                          (MOVE)   
#                          (PROGN (RIGHT) (tsarev_3))
#                          )
#   )

# ;;;-----------------------------------------------------------------------------

# (defun tsar_1 ()
#   (eval '(IF-FOOD-AHEAD 
#    (PROGN (MOVE)   (tsar_5)) 
#    (PROGN (RIGHT)  (tsar_2)) 
#    ))
# )

# (defun tsar_2 ()
#   (eval '(IF-FOOD-AHEAD 
#    (MOVE)
#    (PROGN (RIGHT)  (tsar_4)) 
#    ))
# )

# (defun tsar_3 ()
#   (eval '(IF-FOOD-AHEAD 
#    (PROGN (MOVE)   (tsar_3)) 
#    (PROGN (RIGHT)  (tsar_1)) 
#    ))
# )

# (defun tsar_4 ()
#   (eval '(IF-FOOD-AHEAD 
#    (PROGN (MOVE)  (tsar_5)) 
#    (RIGHT)  
#    ))
# )

# (defun tsar_5 ()
#   (eval '(IF-FOOD-AHEAD 
#    (PROGN (MOVE)  (tsar_2)) 
#    (MOVE) 
#    ))
# )


# (defvar ant_tsarev_85g '(IF-FOOD-AHEAD 
#                          (PROGN (MOVE) (tsar_3))
#                          (PROGN (MOVE) (tsar_3))
#                          )
#   )

# ;-------------------------------------------------------------------------------

# ; На рис. 3 изображeн граф пeрeходов построeнного разработанным алгоритмом 
# ; автомата с сeмью состояниями, котрый позволяeт муравью съeсть всю eду 
# ; за 190 ходов.

# ;;;------------------------
# (defun shalito_2 ()

#   (if *debug_print* (format t "shalito_2 ~%"))

#   (eval '(IF-FOOD-AHEAD 
#    (PROGN  (MOVE) (shalito_4)) 
#    (MOVE) 
#    ))
# )
# ;;;------------------------
# (defun shalito_3 ()

#   (if *debug_print* (format t "shalito_3 ~%"))

#   (eval '(IF-FOOD-AHEAD 
#    (PROGN   (MOVE) (shalito_7)) 
#    (PROGN  (RIGHT) (shalito_5)) 
#    ))
# )
# ;;;------------------------
# (defun shalito_4 ()

#   (if *debug_print* (format t "shalito_4 ~%"))

#   (eval '(IF-FOOD-AHEAD 
#    (PROGN  (MOVE) (shalito_5)) 
#    (PROGN  (MOVE) (shalito_2)) 
#    ))
# )
# ;;;------------------------
# (defun shalito_5 ()

#   (if *debug_print* (format t "shalito_5 ~%"))

#   (eval '(IF-FOOD-AHEAD 
#    (PROGN   (MOVE) (shalito_2)) 
#    (PROGN  (RIGHT) (shalito_6)) 
#    ))
# )
# ;;;------------------------
# (defun shalito_6 ()

#   (if *debug_print* (format t "shalito_6 ~%"))

#   (eval '(IF-FOOD-AHEAD 
#    (PROGN   (MOVE) (shalito_7)) 
#    (PROGN   (LEFT) (shalito_2)) 
#    ))
# )
# ;;;------------------------
# (defun shalito_7 ()

#   (if *debug_print* (format t "shalito_7 ~%"))

#   (eval '(IF-FOOD-AHEAD 
#    ;(PROGN   (MOVE) (shalito_4))  !!!! была ошибка !!!
#    ;(PROGN   (MOVE) (shalito_2)) 

#    (PROGN   (MOVE) (shalito_2)) 
#    (PROGN   (MOVE) (shalito_4)) 
#    ))
# )
# ;;;------------------------

# (defvar ant_shalito  '(IF-FOOD-AHEAD 
#                   (PROGN  (MOVE) (shalito_5))
#                   (PROGN (RIGHT) (shalito_3))
#                   )
#   )

# ;-------------------------------------------------------------------------------
# ;; подобно как в 
# ;; Santa Fe trail (i.e., trails with single gaps, double
# ;; gaps, single gaps at corners, double gaps at corners, and triple gaps at 
# ;; corners appearing in any order).
  
# ;;;-----------------------------------------------------------------------------
# (defun arr_make_2 ()

# (let (arr)

#   (setf arr (make-array '(32 32) :initial-contents '(
#              (* x x x x x x x x x x * * * * * * * * * * * * * * * * * * * * *) 
#              (* * * * * * * * * * x * * * * * * * * * * * * * * * * * * * * *) 
#              (* * * * * * * * * * x * * * * * * * * * * * * * * * * * * * * *) 
#              (* * * * * * * * * * x * * * * * * * * * * * * * * * * * * * * *) 
#              (* * * * * * * * * * x * * * o x * * * * * * * * * * * * * * * *) 
#              (x x x x * * * * * * x * * * o * * * * * * * * * o x x x x x x x) 
#              (* * * x * * * * * * x * * * o * * * * * * * * * x * * * * * * *) 
#              (* * * x * * * * * * x * * * x * * * * * * * * * x * * * * * * *) 
#              (* * * x * * * * * * x o x o o * * * * * * * * * x * * * * * * *) 
#              (* * * x * * * * * * x o * * * * * * * * * * * * x * * * * * * *) 
#              (* * * x x x x x x x x o * * * * * * * * * * * * x * * * * * * *) 
#              (* * * * * * * * * * * x * * * * * * o x x x x x o * * * * * * *) 
#              (* * * * * * * * * * * o o o x o * * x * * * * * * * * * * * * *) 
#              (* * * * * * * * * * * * * * * o * * x * * * * * * * * * * * * *) 
#              (* * * * * * * * * * * * * * * x * * x * * * * * * * * * * * * *) 
#              (* * * * * * * * * * * o x o o o * * x * * * * * * * * * * * * *) 
#              (* * * * * * * * * * * o * * * * * * x * * * * * * * * * * * * *) 
#              (* * * * * * * * * * * x * * * * * * x * * * * * * * * * * * * *) 
#              (* * * * * * * o x o o o * * * * * * o * * * * * * * * * * * * *) 
#              (* * * * * * * o * * * * * * * * * * o * * * * * * * * * * * * *) 
#              (* * * * * * * o * * * * * * * * * * x * * * * * * * * * * * * *) 
#              (* * * * * * * x * * * * * * * * * * x * * * * * * * * * * * * *) 
#              (* * * * o x o o * * * * * * * * * * x * * * * * * * * * * * * *) 
#              (* * * * o * * * * * * * * * * * * * x * * * * * * * * * * * * *) 
#              (* * * * x * * * * * * * * * * * * * x * * * * * * * * * * * * *) 
#              (* * * * x * * * * * * * * * * * * * x * * * * * * * * * * * * *) 
#              (* * * * x * * * * * * * * * * * * * o * * * * * * * * * * * * *) 
#              (* * * * x o o x x x x o x x x x x x o * * * * * * * * * * * * *) 
#              (* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *) 
#              (* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *) 
#              (* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *) 
#              (* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *) 
#              ))
#         )

#   arr
# ))
# ;===============================================================================
# ;-------------------------------------------------------------------------------
# (defun arr_set_random_val (arr val r_val)

# (let (
#   r
#   )

#   (dotimes (i (array-dimension arr 0)) 
#   (dotimes (j (array-dimension arr 1)) 

#     (setf r (YRandF 0 1))
#     (when (<= r r_val)
#       (setf (aref arr i j) val)
#       )
#   ))

# ))
# ;-------------------------------------------------------------------------------
# (defun arr_make_random ()

# (let (
#   (mn  0.2)
#   (arr (make-array '(32 32)))
#   )

#   (Y-srand48 2011)

#   (arr_set_random_val  arr '*  1.0)
#   (arr_set_random_val  arr 'x   mn)

#   arr
# ))
# ;;;-----------------------------------------------------------------------------
# (defun arr_print (arr i0 j0 dir)

#   (dotimes (i (array-dimension arr 0)) 
#   (dotimes (j (array-dimension arr 1)) 

#     (if (and (= i i0) (= j j0))        
#       ;(format t "@ ")
#       (format t "~A " dir)
#       (format t "~A " (aref arr i j))
#         )
#   )
#   (format t "~%")
#   )

#   (format t "~%")
# )
# ;;;-----------------------------------------------------------------------------
# (defun eat_init_calc (arr)

# (let (
#  (eat_init 0)
#  )

#   (dotimes (i (array-dimension arr 0)) 
#   (dotimes (j (array-dimension arr 1)) 

#     (when (eq (aref arr i j) 'x)
#       (incf eat_init)
#       )
#   ))

#   eat_init
# ))
# ;;;-----------------------------------------------------------------------------
# (defun pole_create_ (array_make)

# (let (
#   (pol (make-POLE))  ;; создадим новую пструктуру
#   )

#   (setf (POLE-array_make pol)  array_make)
#   (setf (GAME-print      pol)  'pole_print)

#   (setf *gameptr*        pol)  ; установим еще и глобально

#   pol
# ))
# ;;;-----------------------------------------------------------------------------
# (defun pole_init (pol)

#   (setf (POLE-arr pol) (funcall (POLE-array_make pol)))

#   ; управляющие параметры 
#   (setf (POLE-i   pol)  0)
#   (setf (POLE-j   pol)  0)
#   (setf (POLE-dir pol)  '>)

#   (setf (GAME-fit pol)  0)  
#   (setf (POLE-num pol)  0)  

#   ;; посчитаем начальные параметры еды
#   (setf (GAME-fitfull pol) (eat_init_calc (POLE-arr pol)))  

#   pol
# )
# ;;;-----------------------------------------------------------------------------
# (defun pole_arr_print (pole)

#   (format *error-output* "================================================ ~%")  

#   (arr_print (POLE-arr pole) (POLE-i pole) (POLE-j pole) (POLE-dir pole))

#   (format t "EAT = ~A / ~A ~%" (GAME-fit pole) (GAME-fitfull pole))  
#   (format t "NUM = ~A ~%"      (POLE-num pole))  

#   (format *error-output* "================================================ ~%")  
#   (format t "~%")  
# )
# ;;;-----------------------------------------------------------------------------
# (defun pole_print (pol)

#   (pole_arr_print  pol)

# )
# ;-------------------------------------------------------------------------------
# (defun ant_t2 (argus) (declare (ignore argus))

# (let* (
#   (pol  (pole_create_ 'arr_make_random))
#   )

#   (pole_init pol)
#   (game_print)

# ))
# ;-------------------------------------------------------------------------------
# ; cl y~.cl ANTS ant_t2  - можно уже тестировать !!
# ;;;-----------------------------------------------------------------------------
# (defun ij_after_move_old (dir i j)

#   (if (eq dir '>) (incf j))
#   (if (eq dir '<) (decf j))

#   (if (eq dir '^) (decf i))
#   (if (eq dir 'V) (incf i))

#   (list i j)
# )
# ;;;-----------------------------------------------------------------------------
# (defun set_ij_after_move (dir r_i r_j)
# (let* (
#   (i  (symbol-value r_i))
#   (j  (symbol-value r_j))

#   (arr (POLE-arr *gameptr*))
#   (i_dim (array-dimension arr 0))
#   (j_dim (array-dimension arr 1))
#   )

#   (if (eq dir '>) (incf j))
#   (if (eq dir '<) (decf j))
#   (if (eq dir '^) (decf i))
#   (if (eq dir 'V) (incf i))

#   (if (= i i_dim) (setf i 0))
#   (if (= j j_dim) (setf j 0))
#   (if (= i -1) (setf i (decf i_dim)))
#   (if (= j -1) (setf j (decf j_dim)))

#   (set r_i  i)
#   (set r_j  j)
# ))
# ;;;-----------------------------------------------------------------------------
# (defun pole_move (pole)

# (let (
#  (dir (POLE-dir pole))
#  (i   (POLE-i pole))
#  (j   (POLE-j pole))
#  )
#   (declare (special i j)) ; чтобы менять эту переменную динамически

#   (setf (aref (POLE-arr pole) i j) '-)

#   (set_ij_after_move dir 'i 'j)

#   (setf (POLE-i pole) i)
#   (setf (POLE-j pole) j)

#   (when (eq (aref (POLE-arr pole) i j) 'X) ;; на этом полe была eда
#       (incf (GAME-fit pole)) ;; 
#       ;(setf *last_eat_num* (POLE-num pole))
#     )

# ))
# ;;;-----------------------------------------------------------------------------
# (defun pole_right (pole)

# (let (
#  (dir (POLE-dir pole))
#  )

#   (case dir
#     (^ (setf dir '>))
#     (> (setf dir 'V))
#     (V (setf dir '<))
#     (< (setf dir '^))
#     )

#   (setf (POLE-dir pole) dir)
# ))
# ;;;-----------------------------------------------------------------------------
# (defun pole_left (pole)

# (let (
#  (dir (POLE-dir pole))
#  )

#   (case dir
#     (^ (setf dir '<))
#     (< (setf dir 'V))
#     (V (setf dir '>))
#     (> (setf dir '^))
#     )

#   (setf (POLE-dir pole) dir)
# ))
# ;;;-----------------------------------------------------------------------------
# (defun pole_is_dir_food (pole)

# (let (
#  (dir (POLE-dir pole))
#  (i   (POLE-i pole))
#  (j   (POLE-j pole))
#  )

#   (declare (special i j)) ; чтобы менять эту переменную динамически
#   (set_ij_after_move dir 'i 'j)

#   (if (eq (aref (POLE-arr pole) i j) 'X)
#       T
#     nil
#     )

# ))
# ;;;-----------------------------------------------------------------------------
# ;;;-----------------------------------------------------------------------------
# (defun MOVE ()

#   (pole_move *gameptr*)
#   (incf (POLE-num *gameptr*)) 

#   (if *debug_print* (format t "MOVE ~%"))
# )
# ;;;-----------------------------------------------------------------------------
# (defun LEFT ()

#   (pole_left *gameptr*)
#   (incf (POLE-num *gameptr*)) 

#   (if *debug_print* (format t "LEFT: num= ~s  ~%" (POLE-num *gameptr*)))
# )
# ;;;-----------------------------------------------------------------------------
# (defun RIGHT ()

#   (pole_right *gameptr*)
#   (incf (POLE-num *gameptr*)) 

#   (if *debug_print* (format t "RIGHT ~%"))
# )
# ;;;-----------------------------------------------------------------------------
# (defun NO ()

#   (incf (POLE-num *gameptr*)) 

#   (if *debug_print* (format t "NO ~%"))
# )
# ;;;-----------------------------------------------------------------------------
# ;-------------------------------------------------------------------------------
# (defmacro IF-FOOD-AHEAD (then-argument else-argument)

#   `(if (pole_is_dir_food *gameptr*)
#       (eval ',then-argument)
#       (eval ',else-argument)
#       )
# )
# ;-------------------------------------------------------------------------------
# ; работаем мураша заданного непосредственно макросами лиспа
# ; т.е. "деревом решений", а не автоматом-графом в любом виде
# ;-------------------------------------------------------------------------------
# (defun game_loop_all_num (lisp_form n)


#   ;(format t "game_loop_all_num:  lisp_form= ~s   n= ~s  ~%" lisp_form n)
#   ;(quit)

#   (loop 
#     while (< (POLE-num *gameptr*) n) do
#     (eval lisp_form)
#     )

# )
# ;-------------------------------------------------------------------------------
# (defun game_loop_eval_any_key (lisp_form)

#   (loop
#     (format t "Press Any Key: ~%")
#     (read-char)
#     (eval lisp_form)
#     (game_print)
#     )

# )
# ;-------------------------------------------------------------------------------
# (defun game_do_eval_steps (lisp_form steps)

# (let* (
#   (pol  (pole_create_ 'arr_make_2))
#   )

#   (format t "~%")
#   (format t "PROG= ~s ~%" lisp_form)
#   (format t "~%")

#   (pole_init pol)

#   (if (= steps 0)
#     (progn
#       (setf *debug_print* t)
#       (game_loop_any_key lisp_form)
#       )
#     (progn
#       (game_loop_all_num lisp_form steps)
#       (game_print)
#       )
#     )

# ))
# ;-------------------------------------------------------------------------------
# (defun ant_test_shalito (argus) (declare (ignore argus))

#   (game_do_eval_steps  ant_shalito 200)

# )

# ;;-------------------------------------------------------------------------------

# ;; На рис. 3 изображeн граф пeрeходов построeнного разработанным алгоритмом 
# ;; автомата с сeмью состояниями, котрый позволяeт муравью съeсть всю eду 
# ;; за 190 ходов.

# ;;;------------------------
proc shalito_2_old {} {

  IF-FOOD-AHEAD_old \
    {PROGN  MOVEPROC  shalito_4_old} \
    {MOVEPROC} 

}
# ;;;------------------------
proc shalito_3_old {} {

  IF-FOOD-AHEAD_old \
    {PROGN    MOVEPROC  shalito_7_old} \
    {PROGN   RIGHTPROC  shalito_5_old}

}
# ;;;------------------------
proc shalito_4_old {} {

  IF-FOOD-AHEAD_old \
    {PROGN   MOVEPROC  shalito_5_old} \
    {PROGN   MOVEPROC  shalito_2_old} 
  
}
# ;;;------------------------
proc shalito_5_old {} {
  
  IF-FOOD-AHEAD_old \
    {PROGN   MOVEPROC   shalito_2_old} \
    {PROGN   RIGHTPROC  shalito_6} 
  
}
# ;;------------------------
proc shalito_6 {} {
  
  IF-FOOD-AHEAD_old \
    {PROGN   MOVEPROC shalito_7_old} \
    {PROGN   LEFTPROC shalito_2_old}
  
}
# ;;;------------------------
proc shalito_7_old {} {

  IF-FOOD-AHEAD_old \
    {PROGN   MOVEPROC shalito_2_old} \
    {PROGN   MOVEPROC shalito_4_old}

}
# ;;----------------------------------------------------------------------------
#
# ;;----------------------------------------------------------------------------
proc ant_shalito_progn_old {} {
  
  IF-FOOD-AHEAD_old \
    {PROGN  MOVEPROC   shalito_5_old} \
    {PROGN  RIGHTPROC  shalito_3_old}

}
# ;;----------------------------------------------------------------------------
# ;;; подобно как в 
# ;;; Santa Fe trail (i.e., trails with single gaps, double
# ;;; gaps, single gaps at corners, double gaps at corners, and triple gaps at 
# ;;; corners appearing in any order).
  
# ;;;---------------------------------------------------------------------------
proc arr_make_2 {} {

  set arr_init_lists "
             * x x x x x x x x x x * * * * * * * * * * * * * * * * * * * * * 
             * * * * * * * * * * x * * * * * * * * * * * * * * * * * * * * *
             * * * * * * * * * * x * * * * * * * * * * * * * * * * * * * * * 
             * * * * * * * * * * x * * * * * * * * * * * * * * * * * * * * *
             * * * * * * * * * * x * * * o x * * * * * * * * * * * * * * * * 
             x x x x * * * * * * x * * * o * * * * * * * * * o x x x x x x x 
             * * * x * * * * * * x * * * o * * * * * * * * * x * * * * * * * 
             * * * x * * * * * * x * * * x * * * * * * * * * x * * * * * * * 
             * * * x * * * * * * x o x o o * * * * * * * * * x * * * * * * * 
             * * * x * * * * * * x o * * * * * * * * * * * * x * * * * * * * 
             * * * x x x x x x x x o * * * * * * * * * * * * x * * * * * * * 
             * * * * * * * * * * * x * * * * * * o x x x x x o * * * * * * * 
             * * * * * * * * * * * o o o x o * * x * * * * * * * * * * * * * 
             * * * * * * * * * * * * * * * o * * x * * * * * * * * * * * * * 
             * * * * * * * * * * * * * * * x * * x * * * * * * * * * * * * * 
             * * * * * * * * * * * o x o o o * * x * * * * * * * * * * * * * 
             * * * * * * * * * * * o * * * * * * x * * * * * * * * * * * * * 
             * * * * * * * * * * * x * * * * * * x * * * * * * * * * * * * * 
             * * * * * * * o x o o o * * * * * * o * * * * * * * * * * * * * 
             * * * * * * * o * * * * * * * * * * o * * * * * * * * * * * * * 
             * * * * * * * o * * * * * * * * * * x * * * * * * * * * * * * * 
             * * * * * * * x * * * * * * * * * * x * * * * * * * * * * * * * 
             * * * * o x o o * * * * * * * * * * x * * * * * * * * * * * * * 
             * * * * o * * * * * * * * * * * * * x * * * * * * * * * * * * * 
             * * * * x * * * * * * * * * * * * * x * * * * * * * * * * * * * 
             * * * * x * * * * * * * * * * * * * x * * * * * * * * * * * * * 
             * * * * x * * * * * * * * * * * * * o * * * * * * * * * * * * * 
             * * * * x o o x x x x o x x x x x x o * * * * * * * * * * * * * 
             * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
             * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
             * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
             * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * 
            "


  #puts "arr_init_lists = $arr_init_lists"

  lappend arr 32
  lappend arr 32 

  foreach l $arr_init_lists {
    lappend arr $l 
  }

  return $arr
}
# ;===============================================================================
# ------------------------------------------------------------------------------
proc arr_index {i j  {w 32}} {
 
  #set w 32

  return [expr ($i * $w) + $j + 2]

}
# ------------------------------------------------------------------------------
proc arr_create {w h} {
  
  lappend arr $w 
  lappend arr $h 
  
  for {set i 0} {$i < $h} {incr i} {
  for {set j 0} {$j < $w} {incr j} {

    set index [arr_index $i $j  $w]
    lappend arr "@"  
  }}

  return $arr
}
# ------------------------------------------------------------------------------
proc  arr_make_random {} {

  comm_random_seed 2011
  set r_val 0.2

  set w 32
  set h 32
  
  lappend arr $w
  lappend arr $h 

  for {set i 0} {$i < $w} {incr i} {
  for {set j 0} {$j < $h} {incr j} {

    #set r [expr rand()] ;#(YRandF 0 1) -  здесь как раз подошла стандартная функция
    set r [YRandF 0 1] 

    if {$r <= $r_val} {
      lappend arr "x"
    } else {
      lappend arr "*"
    }

  }}

  return $arr
}
# ------------------------------------------------------------------------------
proc arr_get {arr i j} {

  set w [lindex $arr 0]
  set h [lindex $arr 1]

  set index [arr_index $i $j  $w]

  set val [lindex $arr $index] 

  return $val
}
# ------------------------------------------------------------------------------
proc arr_set {&arr i j val} {

  USE_REFS

  set w [lindex $arr 0]
  set h [lindex $arr 1]

  set index [arr_index $i $j  $w]

  lset arr $index $val 

  #return $val
}
# ;;;-----------------------------------------------------------------------------
proc eat_init_calc {a} {

  set eat_init 0

  set w [lindex $a 0]
  set h [lindex $a 1]

  for {set i 0} {$i < $w} {incr i} {
  for {set j 0} {$j < $h} {incr j} {

    set val [arr_get $a $i $j]

    if {$val == "x"} {
      incr eat_init
    }

  }}

  return $eat_init
}
# ------------------------------------------------------------------------------
# a_make - процедура воссоздания поля
# ------------------------------------------------------------------------------
proc  pole_create {a_make} {

  set ::gameptr [dict create] ;# устанавливаем в глобальную переменную

  #set pol ::gameptr ;# а работать будем с именем этой глобальной переменной!

  #dict set $pol  array_make  $a_make
  #dict set $pol  game_print  pole_print

  #return $pol

  dict set ::gameptr  array_make  $a_make
  dict set ::gameptr  game_print  pole_print

  return ::gameptr
}
# ------------------------------------------------------------------------------
proc  pole_init {p_pol} {
  
  set pol [set $p_pol]

  set array_make [dict get $pol array_make]
  #set array_make [dict get $p_pol array_make]
  #exit

  set arr [eval $array_make]
  #dict set pol   arr $arr
  dict set $p_pol   arr $arr
  #
  # может лучше сделать макрос: dict_set pol(arr) ??

  #puts "pole_init_ARR = [dict get $::gameptr arr]"
  #exit


#   #  управляющие параметры 
  dict set  $p_pol  i  0
  dict set  $p_pol  j  0
  dict set  $p_pol  dir  >

  dict set  $p_pol  fit  0
  dict set  $p_pol  num  0

#   #  посчитаем начальные параметры еды
  dict set  $p_pol  fitfull  [eat_init_calc $arr]

  #pol
}
# ------------------------------------------------------------------------------
proc arr_print__ {a  i0 j0 dir} {

  set w [lindex $a 0]
  set h [lindex $a 1]
  #puts "w= $w  h= $h"

  set probel " "
  #set probel "" ;# более компактная печать, не понятно как лучше..

  for {set i 0} {$i < $w} {incr i} {
  for {set j 0} {$j < $h} {incr j} {
  
    if {$i == $i0 && $j == $j0} {       
      puts -nonewline "$dir"
    } else {
      set val [arr_get $a $i $j]
      puts -nonewline $val
    }
    puts -nonewline $probel
  }
    puts ""
  }

  puts ""
}
# ------------------------------------------------------------------------------
proc pole_arr_print {p_pol} {

  set pol [set $p_pol] ;# это по сути копия, но нас не должно волновать!
  # мы из нее будем только брать..

  #puts "pole_arr_print: pol = $pol"
  #exit

  puts ""
  puts "================================================ "  
  puts stderr ""

  set i   [dict get $pol i]
  set j   [dict get $pol j]

  set dir [dict get $pol dir]
  set arr [dict get $pol arr]

  arr_print__  $arr $i $j $dir

  puts "EAT = [dict get $pol  fit] / [dict get $pol fitfull]"  
  puts "NUM = [dict get $pol  num]"  

  puts stderr ""
  puts "================================================ " 
}
# ------------------------------------------------------------------------------
proc pole_print  {pol} {

  pole_arr_print  $pol

}
# ;;----------------------------------------------------------------------------
# ;
# ; эммулируем передачу по ссылке для изменения значений посредством макроса
# ;
# ;;----------------------------------------------------------------------------
proc set_ij_after_move  {dir  &i &j} {

  USE_REFS

  set arr [dict get $::gameptr arr] ;# (POLE-arr *gameptr*))

  set i_dim [lindex $arr 0]         ;# (array-end arr 0))
  set j_dim [lindex $arr 1]         ;# (array-end arr 1))


  if {$dir == ">"} {incr j}
  if {$dir == "<"} {incr j -1}
  if {$dir == "^"} {incr i -1}
  if {$dir == "V"} {incr i}

  if {$i == $i_dim} {set i 0}
  if {$j == $j_dim} {set j 0}
  if {$i == -1}     {set i [incr i_dim -1]}
  if {$j == -1}     {set j [incr j_dim -1]}

}
# ;;;---------------------------------------------------------------------------
proc pole_move  {&pole} {

  USE_REFS

  # очень прикольно печатается тип-словарь
  #puts ""
  #puts "pole = $pole"
  #puts ""

  set  dir [dict get $pole  dir]
  set  i   [dict get $pole  i]  
  set  j   [dict get $pole  j] 

  #puts "dir = $dir"
  #puts "i   = $i"
  #puts "j   = $j"

  #--------------------------------------
  #попробуем для теста тут изменить значение

  #dict set pole  i 100
  #puts "i   = [dict get $pole  i]"

  #dict set pole  arr 555
  #dict set pole  arr 1  555 ;# он список понимет как словарь!
  #--------------------------------------

  set arr [dict get $pole  arr]  ;# взяли "копию массива" 
  arr_set arr $i $j "-"          ;# поменяли в нем значение
  dict set  pole arr $arr        ;# и "перезаписали" в словарь обратно

  set_ij_after_move  $dir i j    ;# сделаем это макросом !!?

  dict set pole  i $i
  dict set pole  j $j

  set  i  [dict get $pole  i]  
  set  j  [dict get $pole  j] 
  #puts "i   = $i"
  #puts "j   = $j"

  set val [arr_get $arr $i $j]
  set fit [dict get $pole fit]

  # здесь была еда ...

  if {$val  == "x"} {
    dict set pole  fit [expr $fit + 1]
  }

}
# ;;;-----------------------------------------------------------------------------
proc pole_right {&pole} {

  USE_REFS

  #  (dir (POLE-dir pole))
  set  dir [dict get $pole  dir]

  switch $dir {
    "^"   {set dir ">"}
    ">"   {set dir "V"}
    "V"   {set dir "<"}
    "<"   {set dir "^"}
  }

#   (set-POLE-dir! pole dir)
  dict set pole  dir $dir

}
# ;;;-----------------------------------------------------------------------------
proc pole_left {&pole} {

  USE_REFS

#  (dir (POLE-dir pole))
  set  dir [dict get $pole  dir]

#   (case dir
#     [(^)  (set! dir '<)]
#     [(<)  (set! dir 'V)]
#     [(V)  (set! dir '>)]
#     [(>)  (set! dir '^)]
#     )

  switch $dir {
    "^"   {set dir "<"}
    "<"   {set dir "V"}
    "V"   {set dir ">"}
    ">"   {set dir "^"}
  }

#   (set-POLE-dir! pole dir)
  dict set pole  dir $dir

}
# ;;;-----------------------------------------------------------------------------
proc pole_is_dir_food {pole} {

  set  dir [dict get $pole  dir]
  set  i   [dict get $pole  i]  
  set  j   [dict get $pole  j] 


  set_ij_after_move  $dir  i j ;# прикиним, куда попадем после хода

  set arr [dict get $pole  arr]  ;# взяли "копию массива" 
  set val [arr_get $arr $i $j]

  if {$val == "x"} {
    return 1 ;#t
  } else {
    return 0 ;#f
  }

}
#-------------------------------------------------------------------------------
# 
#-------------------------------------------------------------------------------
proc game_loop_eval_any_key_old {lisp_form} {

  while {1} {
    puts "Press Any Key: "
    flush stdout               ;# все данные должны быть выведены

    set answer [gets stdin]
    
    eval $lisp_form
    game_print
  }

}
#-------------------------------------------------------------------------------
# работаем мураша заданного непосредственно макросами лиспа
# т.е. "деревом решений", а не автоматом-графом в любом виде
#-------------------------------------------------------------------------------
proc game_loop_all_num_old {lisp_form n} {

#   (if (vector? lisp_form)
#       (begin
#       (set! lisp_form (car (vector->list lisp_form))) ; почему-то здесь надо так,
#       ;; т.е. получилось лишняя пара скобок для списка.. (хотя в лиспе было все нормально)
#       )
#       (void)
#       )

#   (do () ((>= (POLE-num *gameptr*) n) 'ret)
#     (eval lisp_form)
#     )

  #set num [dict get $::gameptr num]
  #puts "game_loop_all_num_old: "

  #while {[dict get $::gameptr num] < $n} {
  #  #puts "num = $num"
  #  eval $lisp_form
  #}

  while {1} {
    set num [dict get $::gameptr num]
    #puts "num = $num  n = $n"

    if  {$num >= $n} break
    eval $lisp_form
  }

}
#-------------------------------------------------------------------------------
proc game_do_eval_steps_old  {lisp_form steps} {

  set pol  [pole_create  "arr_make_2"]

  #puts ""
  #puts "PROG= $lisp_form "
  #puts ""
  #
  # поскольку задавались отдельные части как функции, я тут не вижу
  # развернутую форму (полную), а хотелось бы ... 

  pole_init $pol

  if {$steps == 0} {
      #(set *debug_print* #t)
      game_loop_eval_any_key_old  $lisp_form
   } else {
      game_loop_all_num_old  $lisp_form $steps
      game_print
   }

} 
# ;;-----------------------------------------------------------------------------
#
# ;;-----------------------------------------------------------------------------

proc ANT_init_MLRI {} {
#


# ;;;-----------------------------------------------------------------------------
proc MOVEPROC {} {

  pole_move  ::gameptr

  dict set ::gameptr num [expr 1 + [dict get $::gameptr num]]

}
# ;;;-----------------------------------------------------------------------------
proc LEFTPROC {} {

  pole_left  ::gameptr

  dict set ::gameptr num [expr 1 + [dict get $::gameptr num]]

}
# ;;;-----------------------------------------------------------------------------
proc RIGHTPROC {} {

  pole_right ::gameptr

  dict set ::gameptr num [expr 1 + [dict get $::gameptr num]]

}
# ;;;-----------------------------------------------------------------------------
# ;(defun NO ()

# ;  (incf (POLE-num *gameptr*)) 

# ;  (if *debug_print* (format t "NO ~%"))
# ;)
# ;;;-----------------------------------------------------------------------------
# ;;-------------------------------------------------------------------------------
# (defmacro IF-FOOD-AHEAD_old (then-argument else-argument)

#   `(if (pole_is_dir_food *gameptr*)
#       (eval ',then-argument)
#       (eval ',else-argument)
#       )
# )
#-------------------------------------------------------------------------------
proc IF-FOOD-AHEAD_old {then_argument else_argument} {

  if {[pole_is_dir_food $::gameptr]} {

    eval  $then_argument
  } else {
    eval  $else_argument
  }

}
#-------------------------------------------------------------------------------
#  PROGN  PROGN  PROGN  PROGN  PROGN  PROGN  PROGN  PROGN  
#-------------------------------------------------------------------------------
proc PROGN {args} {

  # эмулируем запуск последовательно команд

  foreach a $args {
    eval $a
  }

}
#-------------------------------------------------------------------------------

} ;# ANT_init_MLRI

ANT_init_MLRI




# ------------------------------------------------------------------------------

# НАДО бы сделать без PROGN
# 
# ------------------------------------------------------------------------------
proc shalito_01_old {} {
  
  MOVEPROC ; shalito_5_old

}
# ------------------------------------------------------------------------------
proc ant_shalito_old {} {
  
  IF-FOOD-AHEAD_old  shalito_01_old  {RIGHTPROC ; shalito_3_old}

}
# ------------------------------------------------------------------------------
proc ANTS_test_02 {} {

  #set prg {IF-FOOD-AHEAD_old  {PROGN MOVE MOVE}  RIGHT}
  #set prg {IF-FOOD-AHEAD_old  {MOVE ; MOVE}  RIGHT}
  #set prg {IF-FOOD-AHEAD_old  {MOVE}  RIGHT}

  set prg ant_shalito_old

  game_do_eval_steps_old  $prg 60

}
# ------------------------------------------------------------------------------
proc ANTS_test_003 {} {

  # TODO:
  # 
  # делать случайные списки-программы ..
  # причем делать надо прям непосредственно на "тестовом поле"
  # 

}
# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
# Работающие тесты:
#
# tt~.tl ANTS_t2
# tt~.tl ANTS_test_simple_old 
# tt~.tl ANTS_test_shalito_old

#-------------------------------------------------------------------------------
proc  ANTS_t2 {} {

  # создали - пока только виртуально 
  #
  set p [pole_create  "arr_make_random"]

  # инициировали само поле, а также некоторые вспомогательные переменные
  # 
  pole_init $p

  # напчеталаи поле
  # 
  pole_arr_print  $p ;# а здесь не надо менять, а только получать

}
# ------------------------------------------------------------------------------
# выполняем программы заданные обычным способо (TCL)
# ------------------------------------------------------------------------------
proc ANTS_test_shalito_old {} {

  #ANT_init_MLRI

  #game_do_eval_steps_old   ant_shalito_progn_old 200
  game_do_eval_steps_old   ant_shalito_old 200

}
# ------------------------------------------------------------------------------
# тоже самое, только с другой функцией
# ------------------------------------------------------------------------------
proc ANTS_test_simple_old {} {

  set prg {IF-FOOD-AHEAD_old  MOVEPROC RIGHTPROC}

  #ANT_init_MLRI

  #set steps 0 
  set steps 50 

  game_do_eval_steps_old  $prg  $steps

}
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#
# ANTS   ANTS   ANTS   ANTS   ANTS   ANTS   ANTS   ANTS   ANTS   ANTS  
#
#-------------------------------------------------------------------------------
#
# t_ants.tl  t_ants.tl  t_ants.tl  t_ants.tl  t_ants.tl  t_ants.tl  t_ants.tl  
#
#-------------------------------------------------------------------------------
proc ANTS_init_progs {} {


  #-----------------------------------------------------------------------------
  v0_make_tclproc  MOVE {} {
    
    #puts stderr "MOVE ...."
    MOVEPROC ;# это уже вызываем TCL-функцию из прикладной библиотеки
    
  }
  #-----------------------------------------------------------------------------
  v0_make_tclproc  RIGHT {} {
    
    #puts stderr "RIGHT ...."
    RIGHTPROC
    
  }
  #-----------------------------------------------------------------------------
  v0_make_tclproc  LEFT {} {
    
    #puts stderr "LEFT ...."
    LEFTPROC
    
  }
  #-----------------------------------------------------------------------------
  # 
  #  ну а если там в аргументах имя подпрограммы? зачем проверять на список то?
  #  
  #  а затем, что не список он не квотированный, т.е. влюбом случае сначала
  #  выполниться, а нам не это надо!
  #  просто надо к скобкам [] относится не как к списку, а как к квотированию, 
  # т.е отмена выполнения
  #
  #-----------------------------------------------------------------------------

  v0_make_tclproc  IF_FOOD_AHEAD_22 {} {
    
    set else_argument_pop [pop] ;# вытащили значение из стека
    set then_argument_pop [pop] ;# вытащили значение из стека
    
    set else_argument [erase_LIST $else_argument_pop]
    set then_argument [erase_LIST $then_argument_pop]
    
    if {0} {
      puts stderr "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
      puts stderr "then_argument_pop = $then_argument_pop"
      puts stderr "else_argument_pop = $else_argument_pop"
      puts stderr "then_argument = $then_argument"
      puts stderr "else_argument = $else_argument"
      puts stderr ""
      puts stderr "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
    }
    
    set is_food [pole_is_dir_food $::gameptr]
    
    #   # распаковываем список и выполняем
    
    if {$is_food} {
      run_v2_src $then_argument
    } else {
      run_v2_src $else_argument
    }
    
  } 


  v0_make_tclproc  IF_FOOD_AHEAD_11 {} {
    
    set else_argument [pop] ;# вытащили значение из стека
    set then_argument [pop] ;# вытащили значение из стека
    
    #set else_argument [erase_LIST $else_argument_pop]
    #set then_argument [erase_LIST $then_argument_pop]

    #11_erase else_argument
    #11_erase then_argument
    
    set is_food [pole_is_dir_food $::gameptr]
    
    # распаковываем список и выполняем

    if {$is_food} {
      run_v1_src  $then_argument
    } else {
      run_v1_src  $else_argument
    }
    
  } 

  #-----------------------------------------------------------------------------

  # это хитрый вариант для байткомпилированных версий команд.  Зачем нам?
  # выдает ошибку при уже существующем алиасе !!
  # 
  #v0_make_tclproc_alias   L  LEFT

  v0_make_tclproc_alias_NEW   L  LEFT
  v0_make_tclproc_alias_NEW   M  MOVE
  v0_make_tclproc_alias_NEW   R  RIGHT

  #-----------------------------------------------------------------------------
} ;# FINAL .. ANTS_init_builtins
#-------------------------------------------------------------------------------

#ANTS_init ;# начальная инициализация всей системы

#-------------------------------------------------------------------------------
proc ANTS_init {{version 11}} {

  puts stderr ""
  puts stderr "ANTS_init ..... $version"

  ANTS_init_progs ;# выполним построение встроенных функций

  set ::version $version ;# сделаем флажок !!!!!


  v0_make_tclproc_alias_NEW   IF_FOOD_AHEAD  IF_FOOD_AHEAD_11

  switch -- $version {

    "11" {
      
      #v0_make_tclproc_alias_NEW   IF_FOOD_AHEAD  IF_FOOD_AHEAD_11
      v1_init_all 
    }

    "22" {
      
      #v0_make_tclproc_alias_NEW   IF_FOOD_AHEAD  IF_FOOD_AHEAD_22
      v2_init 
    } 
    
    "33" {

      v3_redefine_NEW 

      V3_INIT_01
    }

    default {}
  }
      
  return
}
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
proc convert_prog_22_to_11 {prog_22} {


  puts "convert_prog_22_to_11 ....... prog_22 = $prog_22"

  if {[string equal $prog_22 "@"]} {return "@"}

  
  dict for {key value} $prog_22 {

    puts "convert_prog_22_to_11:  key= $key value= $value"

    #if {$key == "main"} {continue}
  }


}
#-------------------------------------------------------------------------------
proc convert_22_to_11_ALL {prg_22 } {

  # 22 = BEG + END

  #if {[string equal $prog_22 "@"]} { # простой вариант с prg

  convert_22_to_11  $prg_22 prg_11 
  
  #puts stderr "22_to_11:   prg_22  = $prg_22"
  #puts stderr "22_to_11:   prg_11  = $prg_11"
  
  #} else {
  #}
  
  #set prog_11 [convert_prog_22_to_11  $prog_22]


  return [list $prg_11 "@"]
}
#-------------------------------------------------------------------------------
# запуск игры ANTS
# работаем мураша заданного непосредственно 
#-------------------------------------------------------------------------------
proc game_loop_any_key_joy {prg_22} {



  foreach {prg_11 prog_11} [convert_22_to_11_ALL "$prg_22"] {}

  #---------------------------------------------------------


  game_print

  while {1} {

    puts "Press Any Key: "
    flush stdout               ;# все данные должны быть выведены
    set answer [gets stdin]
    

    # надо бы перехватывать полностью аварию
    #     
    if {[catch {run_v1_src  "$prg_11"} err]} {

      return $err
    }

    game_print
  }

  return ""
}
#-------------------------------------------------------------------------------
proc game_loop_all_num_joy {src n} {


  # и кстати, вынос сюда сильно ускоряет цикл !!


  set ind 0

  while {1} {

    set num [dict get $::gameptr num]
    #puts "num= $num ................"
    # если никуда не движемся, счетчик и не увеличивается..

    if  {$num >=  $n} break
    if  {$ind >= 200} break ;# нужен дополнительный ограничтель

    # надо бы перехватывать полностью аварию
    #     

    if {$::version == "22"} {

      if {[catch {run_v2_src "$src"} err]} {
        return $err
      }
    } else {

      if {[catch {run_v1_src "$src"} err]} {
        return $err
      }
    }

    incr ind
  }

  return ""
}
#-------------------------------------------------------------------------------
proc game_do_eval_steps_joy  {src  steps} {


  set pol  [pole_create  "arr_make_2"]
  pole_init  $pol

  puts ""
  
  if {$steps == 0} {
    game_loop_any_key_joy  $src

  } else {
    
    game_loop_all_num_joy  $src $steps ;# "@"

    game_print
  }

} 
#-------------------------------------------------------------------------------

# DEFINE prog1 ==
#        [1000 >]  [2 /]  [3 *]  ifte.
#  1500  prog1 putn

#-------------------------------------------------------------------------------
#
# x~.tl ANTS_test_simple_joy 

#-------------------------------------------------------------------------------
proc ANTS_test_simple_joy {} {


  #v1_init_all  ;# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!


  # это для 2-й версии
  # 
  #set src {[MOVE_] [RIGHT_] IF_FOOD_AHEAD_}

  #   а для 1-й версии:
  # 
  #set src {_MOVE _RIGHT IF_FOOD_AHEAD}


  #set src {{nop MOVE} {nop RIGHT} IF_FOOD_AHEAD}
  #
  #set src { BEG nop MOVE END  BEG nop RIGHT END  IF_FOOD_AHEAD }
  #

  #set src { MOVE RIGHT  IF_FOOD_AHEAD } ;# хотелось, чтобы и так работало !!


  set src { BEG MOVE END  BEG RIGHT END  IF_FOOD_AHEAD }

  ANTS_init "22" 



  global argc ;# ищем флажок

  if {$argc > 2} {
    set steps 0 ;# усли хоть какой-то флажок, то идем пошагово
    #DebugOn
  } else {
    set steps 15 
    #set steps 50 
  }

  # пока еще упростим: -------------------------------------------

  #   set ctx [JOY_create_context]

  #   set pol  [pole_create  "arr_make_2"]
  #   pole_init  $pol
  #   puts ""

  #   run_v2_src_old   $src
  #   run_v2_src_old   $src
  #   run_v2_src_old   $src

  #   game_print
  
  #---------------------------------------------------------------
  v0_set_stack_null 

  game_do_eval_steps_joy  $src $steps


}
# ------------------------------------------------------------------------------
# k~.tl ANTS ANTS_test_shalito_joy 50
# 

#set ::is_v1 1

# ------------------------------------------------------------------------------
proc ANTS_test_shalito_joy {} {


  ANTS_init ;# начальная инициализация системы функций

  global argv0 argc argv

  # здесь надо бы в общем виде

  if {$argc != 3} {
    puts ""
    puts "USE: [lindex $argv 0] <steps>"
    puts ""
    exit
  }

  set steps [lindex $argv 2] ;# сколько сделать шагов (маленьких шажков)

  set pol  [pole_create  "arr_make_2"]
  pole_init  $pol
  puts ""


  # 1-я версия 
  #------------------------------------------------------------

  v0_:_prg shalito_07 {{MOVE shalito_02} {MOVE  shalito_04} IF_FOOD_AHEAD}
  v0_:_prg shalito_06 {{MOVE shalito_07} {LEFT  shalito_02} IF_FOOD_AHEAD}
  v0_:_prg shalito_05 {{MOVE shalito_02} {RIGHT shalito_06} IF_FOOD_AHEAD}
  v0_:_prg shalito_04 {{MOVE shalito_05} {MOVE  shalito_02} IF_FOOD_AHEAD}
  v0_:_prg shalito_03 {{MOVE shalito_07} {RIGHT shalito_05} IF_FOOD_AHEAD}
  v0_:_prg shalito_02 {{MOVE shalito_04} {nop   MOVE}       IF_FOOD_AHEAD}
  v0_:_prg shalito_01 {{MOVE shalito_05} {RIGHT shalito_03} IF_FOOD_AHEAD}

  set src_22 {\
      BEG  MOVE  BEG MOVE shalito_02 END BEG RIGHT shalito_06 END IF_FOOD_AHEAD END \
      \
      BEG  RIGHT BEG MOVE shalito_07 END BEG RIGHT shalito_05 END IF_FOOD_AHEAD END \
      \
      IF_FOOD_AHEAD \
      }

  convert_22_to_11   $src_22 src_11 ;# заранее перекодируем !!
  
  v0_:_prg   shalito_00 $src_11

  #------------------------------------------------------------

  #set prg {shalito_00} ;# начальную то функцию мы сконвертируем при старте, а вот
                        # остальные ??

  set prg shalito_00

  #game_do_eval_steps_joy  $ctx $prg 1000
  #game_do_eval_steps_joy  $ctx $prg 0

  #DebugOn


  # вообще-то здесь снова создается .. pol 
  # 
  game_do_eval_steps_joy  $prg $steps

}
#-------------------------------------------------------------------------------
# k~.tl ANTS ANTS_test_shalito_joy 50
#-------------------------------------------------------------------------------
#
# что делать, если в программе окажется непарная скобка?
# как они вводятся то?
#
# TODO:
# 
# может не делать скобочки, а сразу перейти к образованию функций ?!
# но все равно нужны списки, если только научить прогу IF_FOOD_AHEAD_
# понимать и единичные команды (что вобщем-то логично)
# 
# 
#-------------------------------------------------------------------------------
proc ANTS_test_06 {} {

  #set ::joy::debug 1
  set ctx [joy-create-context]

  puts ""
  puts "----------------------"
  set ::tdebug 1


  joy-eval    $ctx {[2 3  [4 5] concat ^}

  puts ""
  joy-rel-showstack $ctx

  # странно, что нигде не ругнулось, и не выполнилось, как буд-то целиком 
  # запихнулось в стек. нужны сообщения от "pop-list-token"
  #
  # [2 3 [4 5] concat ^]

}
#-------------------------------------------------------------------------------
# 
#-------------------------------------------------------------------------------
proc pole_calc_fitness {pol} {

  
  set p [set $pol] ;# это по сути копия, но нас не должно волновать!
  
  set fit [dict get $p fit]       ;# всего съедено
  set all [dict get $p fitfull]   ;# всего было

  set res [expr $all - $fit]      ;# сколько осталось (чем меньше - тем лучше)
  
  #set len [llength $prg]      ;# длина программы   
  #set fitness [expr $all + $len / 100] ;# ????

  set fitness $res

  return $fitness
}
#-------------------------------------------------------------------------------
#
# ------------------------------------------------------------------------------
proc  polearr_make_full {w h val} {


  #set  arr {} ;# создали локальную переменную
  #set parr [getglobalname] ;# создали уникальную глобальную переменную
  set parr [MAKE_GLOBAL_NAME]


  #lappend arr $w ;# начинаем в нее записывать данные (плоским массивом)
  #lappend arr $h 

  lappend $parr $w ;# начинаем в нее записывать данные (плоским массивом)
  lappend $parr $h 

  for {set i 0} {$i < $w} {incr i} {
  for {set j 0} {$j < $h} {incr j} {

    #lappend arr $val
    lappend $parr $val
  }}

  #return $arr ;# вернули непосредственно массив (забыли про локальную пер-ную)
  return $parr ;# вернули глоб. переменную!

}
# ;;;---------------------------------------------------------------------------
proc pole_20e5 {} {


  # другой вариант: в лок.перем. записали имя глоб.переменной (в которой массив)
  #
  set parr [polearr_make_full  20 20 "."] 


  # чтобы поменять соедржимое массива, сделаем:
  #   
  arr_set  $parr  0 5 "x"   ;# передадим имя глоб.переменной
  arr_set  $parr  0 6 "x"   ;# передадим имя глоб.переменной
  arr_set  $parr  0 7 "x"   
  arr_set  $parr  0 8 "x"   
  arr_set  $parr  0 9 "x"   


  return [set $parr] ;# а здесь уже возвращаем сам массив (из глоб.переменной)

}
# ;;;---------------------------------------------------------------------------
proc pole_20a5 {} {


  # другой вариант: в лок.перем. записали имя глоб.переменной (в которой массив)
  #
  set parr [polearr_make_full  20 20 "."] 


  # чтобы поменять соедржимое массива, сделаем:
  #   
  arr_set  $parr  0 1 "x"   ;# передадим имя глоб.переменной
  arr_set  $parr  0 2 "x"   ;# передадим имя глоб.переменной
  arr_set  $parr  0 3 "x"   
  arr_set  $parr  0 4 "x"   
  arr_set  $parr  0 5 "x"   


  return [set $parr] ;# а здесь уже возвращаем сам массив (из глоб.переменной)

}
# ;;;---------------------------------------------------------------------------
proc pole_20a6 {} {

  # другой вариант: в лок.перем. записали имя глоб.переменной (в которой массив)
  #
  set parr [polearr_make_full  20 20 "."] 

  # чтобы поменять соедржимое массива, сделаем:
  #   
  arr_set  $parr  0 1 "x"   ;# передадим имя глоб.переменной
  arr_set  $parr  0 2 "x"   ;# передадим имя глоб.переменной
  arr_set  $parr  0 3 "x"   
  arr_set  $parr  1 3 "x"   
  arr_set  $parr  2 3 "x"   
  arr_set  $parr  3 3 "x"   

  return [set $parr] ;# а здесь уже возвращаем сам массив (из глоб.переменной)
}
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
proc run_ants_game {src  arr_make_proc {n 50}} {

  
  set pol   [pole_create  $arr_make_proc]

  pole_init  $pol 

  #set ctx [prepare_pole_ctx]
  #set steps 50
  # 
  # это в общем виде повторы в стиле конечного автомата! 
  # реальный конечный автомат должен состоять только из вложенных IF THEN ELSE    

  #-----------------------------------------------

  game_loop_all_num_joy   $src  $n ;# "@" ;# 50


  # ну и наконец, посчитаем фитнес

  set fitness [pole_calc_fitness  $pol]

  #-----------------------------------------------

  return $fitness
}
#-------------------------------------------------------------------------------
proc FITPROC_ants {p task} {

  #v1_init_all ;# ???????????????????? 

  # не понятно, как, но это влияет на (возможно портиться системн. библиотека?)
  # 
  #k~.tl ANTS ANTS_gp 2012  10 15 2


  v0_set_stack_null  ;# #set ::joy_ST {}  ;# зануляем стек !! достаточно?


  #if {$::ITEMS_LIST} {
  set src  [item_get_mainsrc $p]
  #} else {
  #  set src $p
  #}


  # TODO: вызывать также и prog !!!
  # 
  # это можно, вот только как всю прогу пееркодировать из 22 в 11 ?
  # 
 
  set fitness [run_ants_game  $src  "arr_make_2" ] 

  # fit_tobest = MIN 
  # fit_target = 0

  return $fitness
}
#---------------------------------------------------------------------------
# 
#---------------------------------------------------------------------------
proc test_fitness_ants {} {


  ANTS_init "22"


  #set prg {{nop MOVE} {nop RIGHT nop} IF_FOOD_AHEAD}
  #
  set prg { BEG nop MOVE END   BEG nop RIGHT nop END  IF_FOOD_AHEAD}
  #set prg {MOVE}

  # DebugOn
  
  set fit [FITPROC_ants [item_make $prg] NULL]

  game_print

  puts ""
  puts "ants_fit = $fit"
  puts ""

}
#-------------------------------------------------------------------------------
proc read_params {&individuals &len &nums} {


  USE_REFS

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  incr ::ind0
  incr ::ind0

  # берем данные из командной строки 
  # 
  #set individuals ;# колич-во ботов
  #set len         ;# макс. длина ботов (при начальном старте?)
  #set nums        ;# шагов эволюции  

  parse_opt_seed_3_new  individuals len nums
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 
  return
}
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
proc lappend_BE_list {prg i1 i2 &ret} {

  USE_REFS

  set B "BEG"
  set E "END"

  #set B  "{"
  #set E  "}"

  # потом формируем саму пару:
  #

  lappend ret $B
  
  for {set i $i1} {$i <= $i2} {incr i} {
    lappend ret [lindex $prg $i]
  }
  
  lappend ret $E
  
  return
}
#-------------------------------------------------------------------------------
proc make_quotes_BE {prg} {

  set n [llength $prg]

  set paras  [make_paras $n]

  set newprg [make_quotes_by_paras  $prg $paras $n  "lappend_BE_list"]

  return $newprg
}
#-------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
# k~.tl ANTS ANTS_gp_new  2002 15 15 2

# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
proc check_prg_version {prg} {

  # опреедлим формат исходного текста и запишем в нужную ячейку словаря

  set BEG_index [lsearch $prg "BEG"]


  if {$BEG_index == -1} {  ;# не найдено 
    return "11"
  } else {
    return "22"
  }

}
#---------------------------------------------------------------------------
# ------------------------------------------------------------------------------
#
#k~.tl ANTS ANTS_newtest

# ------------------------------------------------------------------------------
proc item_print__ {pa} {

  puts ""
  puts "item_print__ ______________________________________| "
  puts ""

  puts "src = [item_get_main_src $pa]" 
  puts ""
  puts "___________________________________________________| "
  puts ""

}
# ------------------------------------------------------------------------------
proc item_run {item version} {


  set src [item_get_main_src $item] 

  puts "RUN $version ...... !! src = $src"


  switch -- $version {

    "11" { run_v1_src  $src }

    "22" { run_v2_src  $src } 

    "33" { run_v3_src  $src } 

    default {}
  }


  return
}
#-------------------------------------------------------------------------------
proc ANTS_newtest_version {src version} {


  v0_set_stack_null  

  set pol    [pole_create  "pole_20e5"]
  pole_init  $pol
  
  puts ""

  set pa [item_make $src]

  item_print__ $pa

  item_run   $pa $version
 
 
  pole_print  $pol
  
  set fit [pole_calc_fitness $pol]

  puts ""
  puts "ants_fitness = $fit"
  puts ""

}
#-------------------------------------------------------------------------------
proc ANTS_newtest {} {


  #set  src11 {M M M M  L R  M M M M M  L R  M M   {   R M M M M M   }  i }

  set  src22   { M M M M   R  M M  L  M M   BEG R M M M M M END  i}


  #--------------------------------------------------

  #convert_11_to_22 $src11  src22

  ANTS_init "22" ;# начальная инициализация системы функций

  ANTS_newtest_version $src22 "22"

  #--------------------------------------------------

  convert_22_to_11 $src22  src11

  ANTS_init "11"

  ANTS_newtest_version $src11 "11" 

  #--------------------------------------------------


  return
}
#-------------------------------------------------------------------------------
proc TEST_33 {} {


  set  src_JY  { M M M M   R  M M  L  M M  [ R M M M M M ]  i}

  ANTS_init "33"

  set src_33 [compile_joy_to_33  $src_JY]

  ANTS_newtest_version $src_33 "33" 


}
#---------------------------------------------------------------------------
proc TEST_simple {} {

  # простой алгоритм : есть жрачка - идем вперед, нет - крутимся вправо
  # 

  #--------------------------------------------------------- 

  set src11 {{~ MOVE} {~ RIGHT} IF_FOOD_AHEAD}

  ANTS_init "11" 

  game_do_eval_steps_joy  $src11 50

  #---------------------------------------------------------

  convert_11_to_22 $src11  src22

  ANTS_init "22" 

  game_do_eval_steps_joy  $src22 50

  #---------------------------------------------------------

  #ANTS_init "33" 

  #game_do_eval_steps_joy  $src33 50

  #--------------------------------------------------------- 

}
#-------------------------------------------------------------------------------
proc ANTS_gp {} {


  read_params  individuals len nums

  set gp_list       "MOVE RIGHT IF_FOOD_AHEAD nop i" 

  #---------------------------------------------

  #ANTS_init "22"    ;# какой-то другой результат !!
  #set quotes_proc "make_quotes_BE"
  
  ANTS_init "11" 
  set quotes_proc "make_quotes_TCL"
  

  #---------------------------------------------

  set mp [mp_create]

  mp_init $mp \
    randinstr    "randinstr_MAIN" \
    quotes_proc  $quotes_proc

  set task [task_create  -fit_func FITPROC_ants  "-fit_tobest" "MIN" -gp_list $gp_list]
    
  set ::is_print 1

  run_gp_evolution_for_task        \
      $task                        \
      0 "make_rand_prgpop_unikum"  \
      $individuals  $len $nums     \
      $::is_print                  \
      -mutprob          0.1        \
      -game_print_proc  0 


  return
}
#-------------------------------------------------------------------------------
proc FITPROC_ants20 {p task} {

  #v1_init_all ;# ???

  set src  [item_get_mainsrc $p]


  set n 1 ;# будем делать один повтор (т.е. никакой не конечный автомат)

  set fitness [run_ants_game  $src $::pole  $n]
 
  return $fitness
}
#-------------------------------------------------------------------------------
proc ANTS_gp_new {} {

  # простой лиенйный тест (без условий)
  # 

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  global argv
  set argo [lrange $argv 2 end]
  argo_print $argo 

  #read_params  individuals len nums

  set seed        [dict_parse $argo "-seed"  @]
  set individuals [dict_parse $argo "-lpop" 10]
  set len         [dict_parse $argo "-size" 10] 
  set nums        [dict_parse $argo "-nums"  4]
  set gp_list     [dict_parse $argo "-list" "M R L"] 
  #set gp_list     [dict_parse $argo "-list" "MOVE RIGHT LEFT"] 
  set ::is_print  [dict_parse $argo "-print" 1] 


  set ::pole  [dict_parse $argo "-pole" "pole_20e5"] 

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  # флажки для новейших алгоритмов
  # 
  # 
  set ::NEWS      [dict_parse $argo "-news"  $::NEWS]
  set ::AUTO      [dict_parse $argo "-auto"  $::AUTO]


  pi_add  M  {"inp" 0 "out" 0}
  pi_add  R  {"inp" 0 "out" 0}
  pi_add  L  {"inp" 0 "out" 0}

  set ::LIPS_begin 0
  set ::LIPS_final 0

  # t~.tl ANTS ANTS_gp_new  -lpop 10 -size 15 -nums -1 -print 1 -pole pole_20a5 -seed 2022 -news 1

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  #set gp_list  "M R L"
  
  ANTS_init "11" ;# начальная инициализация системы функций
  

  set mp [mp_create]

  mp_init $mp \
    randinstr    "randinstr_MAIN" \
    quotes_proc  "quotes_proc_NULL"

  #set ::is_print 1

  set task [task_create  -fit_func FITPROC_ants20  "-fit_tobest" "MIN" -gp_list $gp_list]
    
  run_gp_evolution_for_task \
      $task                        \
      $seed "make_rand_prgpop_unikum"  \
      $individuals  $len $nums     \
      $::is_print                  \
      -mutprob          0.1        \
      -game_print_proc  game_print 
  
}
#-------------------------------------------------------------------------------

# t~.tl ANTS ANTS_gp_new  -seed 2002  -lpop 10 -size 15 -nums -1 -print 2 -pole 'pole_20e7'

#-------------------------------------------------------------------------------
# 
# TODO:

# t~.tl ANTS TEST33 - системная библиотека не интегрирована ?

# t~.tl ANTS ANTS_newtest
# t~.tl ANTS TEST_simple


# 1) все тесты должны быить двойными - т.е. отдельно выполняться (и совпадать) с
#    версиями 11 и 22
# 
# 2) идею об одноверменном хранении двух версий исходников - пока забыть;
#    один код - одна версия, о ней - флажочек.
#  

# t~.tl ANTS ANTS_gp      2012  10 15 2
# t~.tl ANTS ANTS_gp_new  2002  15 15 2

# -----------------------------------------------

#    POPU_ITEM_T -> agent_create (только фитнес добавить)
#    попробовать добавление BEG и END не попарно (), а как обычные инструкции?
#
#    может быть фитнес должен быть не только у программы, но и у кусков?
#    тогда куски ничем не отличаются от программ ??

# t~.tl ANTS test_fitness_ants
# t~.tl ANTS ANTS_gp    @ 15 15 5


# t~.tl ALIB ANTS_t2 
# t~.tl ALIB ANTS_test_shalito_old 
# t~.tl ALIB ANTS_test_simple_old 
# t~.tl ANTS ANTS_gp 2012  10 15 2 
# t~.tl ANTS ANTS_gp_new  2002 15 15 2 
# t~.tl ANTS ANTS_test_shalito_joy 50 
# t~.tl ANTS  ANTS_test_simple_joy 

#-------------------------------------------------------------------------------
