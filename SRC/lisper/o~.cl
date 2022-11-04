; -*-   mode: lisp ; coding: koi8   -*- ----------------------------------------

;-------------------------------------------------------------------------------
;===============================================================================

(defvar CUR_DIR "o")

;(load "../a-comm.cl")
;(load "EXT/LSP/src/a-comm.cl")
(load "a-comm.cl")
;(load "a-comm.cl")

;-------------------------------------------------------------------------------
(defun A000 (argus)

  ;(my_load "p-0000.cl" CUR_DIR)
  (load "f-0000.cl")

  (my_load "o-am00.cl" CUR_DIR)

  (run_cdr_argus (first argus) argus "A000 ..")
)
;-------------------------------------------------------------------------------
;1: cl z~.cl A000 amat_04
;1: cl z~.cl A000 anet_01
;-------------------------------------------------------------------------------
(defun ANTS (argus)

  ;(my_load "a-pops.cl" CUR_DIR)
  ;(load "../common/a-pops.cl")
  (load "f-pops.cl")

  ;(my_load "l-gena.cl" CUR_DIR)

  ;(my_load "n-mgen.cl" CUR_DIR)
  (load "h-mgen.cl")


  ;(my_load "p-0000.cl" CUR_DIR)
  (load "f-0000.cl")

  (load "o-am00.cl")

  (load "o-am00.cl")

  (load "o-am01.cl")


  ;(my_load "p_ants.cl" CUR_DIR)
  (load "f-ants.cl")

  (load "o_ants.li")

  (run_cdr_argus (first argus) argus "ANTS ..")
)
;-------------------------------------------------------------------------------
;1: cl z~.cl ANTS ant_test_new
;1: cl z~.cl ANTS ant_t1
;1: cl z~.cl ANTS ant_t2
;1: cl z~.cl ANTS ant_test_old 2
;1: cl z~.cl ANTS ant_perebor arr_make_2 1
;1: cl z~.cl ANTS ant_test_ga 7 @ 11 2
;
;-------------------------------------------------------------------------------
(defun FLIB (argus)

  (my_load "f-pops.cl" CUR_DIR)
  ;(my_load "l-gena.cl" CUR_DIR)
  (my_load "h-mgen.cl" CUR_DIR)

  (my_load "f-0000.cl" CUR_DIR)
  (my_load "o-am00.cl" CUR_DIR)
  (my_load "o-am01.cl" CUR_DIR)

  (my_load "o_flib.li" CUR_DIR)

  (run_cdr_argus (first argus) argus "FLIB ..")
)
;-------------------------------------------------------------------------------

;1: cl z~.cl FLIB test_perebor
;1: cl z~.cl FLIB test_ga 1 @ 10 2
;1: cl z~.cl FLIB test_1

;-------------------------------------------------------------------------------

(READ_AND_CALL_ARGUS CUR_DIR)

;===============================================================================

