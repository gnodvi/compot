; -*-   mode: lisp ; coding: koi8   -*- ----------------------------------------

;-------------------------------------------------------------------------------
;===============================================================================
;

(require 'asdf) 

(require 'uiop)

;===============================================================================

(defvar CUR_DIR "a")


(load "./a-comm.cl")

;-------------------------------------------------------------------------------

(load   "a-rand.cl")

;# подключаем тесты только если  файлы есть;
;# другой способ - заключить их в отдельные процедуры 0-го уровня

;my_source "a-comp.tl"
;my_source "a-menu.tl"

;-------------------------------------------------------------------------------



;# //******************************************************************************
;# //  Synopsis:	Test GAUL pseudo-random number generator.
;# //------------------------------------------------------------------------------
;# void 
;# test_prng (int argc, char **argv)
;# //------------------------------------------------------------------------------
;#proc test_prng {} {
(defun prng (argus)

  (declare (ignore argus))

  ;;  #   boolean  success;
  
  ;;  #   /* Usual initializations */
  (random_init) 
  
  ;;  #   /* Run randomness test function */
  ;;  #   success = random_test ();

  (random_test) 
  
  ;;  #   if (success == FALSE)
  ;;  #     printf ("*** Routines DO NOT produce sufficiently random numbers.\n");
  ;;  #   else
  ;;  #     printf ("Routines produce sufficiently random numbers.\n");
  
  (format t  "~%")
  
  ;;  return
)
;#-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
(defun COMM (argus)

  (run_cdr_argus (first argus) argus "COMM ..")
)
;-------------------------------------------------------------------------------
(defun COMP (argus)

  (my_load "a-comp.cl" CUR_DIR)
  (run_cdr_argus (first argus) argus "COMP ..")

  ;; cl a~.cl COMP win_test_old
)
;-------------------------------------------------------------------------------
;(defun CPOP (argus)

;  (my_load "a-pops.cl" CUR_DIR) ;

;  (run_cdr_argus (first argus) argus "CPOP ..") 
;)
;-------------------------------------------------------------------------------
(defun PLUT (argus)

  (my_load "a-comp.cl" CUR_DIR)

  ;(my_load "d-plot.cl" CUR_DIR)
  (load "a-plot.cl")

  (run_cdr_argus (first argus) argus "PLUT ..")

  ;; cl d~.cl PLUT plot_test1
  ;; cl d~.cl PLUT plot_test3_save

  ;; cl d~.cl PLUT plot_test3
)
;-------------------------------------------------------------------------------

(READ_AND_CALL_ARGUS  CUR_DIR)

(format t "~%")

;-------------------------------------------------------------------------------

; cl a~.cl COMM rand_1
; cl a~.cl COMM rand_4
; cl a~.cl COMM rand_2

;===============================================================================
