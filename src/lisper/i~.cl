; -*-   mode: lisp ; coding: koi8   -*- ----------------------------------------

;-------------------------------------------------------------------------------
;===============================================================================

(require 'asdf)


;(push "../lisper/"   asdf:*central-registry*)

; надо звгружвть отдельным пакетом !!??  pkgcocom.asd ???
; 
;(load "EXT/LSP/src/c-comm.cl")  ;  READ_AND_CALL_ARGUS


(defpackage #:p-asd
  (:use     :cl :asdf))

(in-package :p-asd)


;-------------------------------------------------------------------------------
;
(defsystem _EDIT_

  :default-component-class cl-source-file.cl 
  :defsystem-depends-on    (:asdf-encodings)

  :components (
               (:file "i-edit")
               )
  )

;-------------------------------------------------------------------------------
;
(defsystem _ANTS_

  :default-component-class cl-source-file.cl 
  :defsystem-depends-on    (:asdf-encodings)

  :components (
               (:file "f-0000")
               (:file "f-ants")
               )
  )

;-------------------------------------------------------------------------------
;
(defsystem _GENP_

  :default-component-class cl-source-file.cl 
  :defsystem-depends-on    (:asdf-encodings)

  :components (
;               (:file "../lisper/f-pops")
;               (:file "../lisper/f-0000")
;               (:file "../lisper/f-ants")

               (:file "f-pops")
               (:file "f-0000")
               (:file "f-ants")

               (:file "i-comm")
               (:file "i-prog")

;               (:file "f-0000")
;               (:file "f-ants")
               )
  )

;===============================================================================

;(push "../lisper/"   asdf:*central-registry*)

(defvar CUR_DIR  "i")

;(load "EXT/LSP/src/a-comm.cl")  ;  READ_AND_CALL_ARGUS

(load "a-comm.cl")  ;  READ_AND_CALL_ARGUS

;===============================================================================
;-------------------------------------------------------------------------------
(defun EDIT (argus)

  (asdf:load-system :_EDIT_)
  
  ;(my_load "p-edit.cl" CUR_DIR)

  (run_cdr_argus (first argus) argus "EDIT ..")

)
;-------------------------------------------------------------------------------
(defun ANTS (argus)

  (asdf:load-system :_ANTS_)
  
;  (my_load "f-0000.cl" CUR_DIR)
;  (my_load "f-ants.cl" CUR_DIR)

  (run_cdr_argus (first argus) argus "ANTS ..")

)
;-------------------------------------------------------------------------------
;; cl y~.cl ANTS ant_test_shalito
;; cl y~.cl ANTS ant_t2
;-------------------------------------------------------------------------------
(defun GENP (argus)

  (asdf:load-system :_GENP_)


;  (load "f-pops.cl")

;  (my_load "p-comm.cl" CUR_DIR)
;  (my_load "p-prog.cl" CUR_DIR) ; для тeстов ГП

;  (my_load "f-0000.cl" CUR_DIR)
;  (my_load "f-ants.cl" CUR_DIR)


  (my_load "i_ants.li" CUR_DIR)

  (run_cdr_argus (first argus) argus "GENP ..")

)
;-------------------------------------------------------------------------------
;; cl y~.cl GENP ant_test_gp_new @ 10 2


;===============================================================================
;
;-------------------------------------------------------------------------------
;===============================================================================
(defun BOOL (argus)


  (load "a-comm.cl")
  (load "i-comm.cl")

  ;----------------------------------

  ;(my_load "a-pops.cl" CUR_DIR)
  (load "f-pops.cl")

  ;(my_load "l-gena.cl" CUR_DIR)
  ;(my_load "i-mgen.cl" CUR_DIR)

  ;(my_load "p-prog.cl" CUR_DIR)
  (load "i-prog.cl")

  (load "i_bool.li")
  (run_cdr_argus (first argus) argus "BOOL ..")

)
;-------------------------------------------------------------------------------
(defun OPTI (argus)

  (load "a-comm.cl")
  (load "i-comm.cl")

  ;----------------------------------

  (my_load "a-comp.cl" CUR_DIR)
  (my_load "f-func.cl" CUR_DIR)

  (my_load "f-pops.cl" CUR_DIR)
  ;(my_load "l-gena.cl" CUR_DIR)
  ;(my_load "i-mgen.cl" CUR_DIR)

  (my_load "i-prog.cl" CUR_DIR)
  (my_load "i-comm.cl" CUR_DIR)

  (load "i_opti.li")
  (run_cdr_argus (first argus) argus "GENP ..")

)
;===============================================================================
; ==============================================================================

;  (my_load "b-comp.cl" CUR_DIR) ; оказываeтся тожe нужeн для CELL

;????
;  (my_load "g-main.cl" CUR_DIR)
;  (my_load "g-nets.cl" CUR_DIR)

;-------------------------------------------------------------------------------
(defun KOZA (argus)

  (load "a-comm.cl")
  (load "i-comm.cl")

  ;----------------------------------

  ;(my_load "a-func.cl" CUR_DIR)
  (load "./f-func.cl")

  ;(my_load "a-pops.cl" CUR_DIR)
  (load "f-pops.cl")

  ;(my_load "l-gena.cl" CUR_DIR)
  ;(my_load "i-mgen.cl" CUR_DIR)
  
  ;(my_load "p-prog.cl" CUR_DIR)
  (load "i-prog.cl")


  ;(my_load "p-comm.cl" CUR_DIR)
  (load "i-comm.cl")


  (load "i_koza.li")
  (run_cdr_argus (first argus) argus "KOZA ..")
)
;-------------------------------------------------------------------------------
(defun REGR (argus)

  (load "a-comm.cl")
  (load "i-comm.cl")

  ;----------------------------------

  ;(my_load "a-func.cl" CUR_DIR)
  ;(load "C/a-func.cl")
  (load "f-func.cl")

  ;(my_load "a-pops.cl" CUR_DIR)
  (load "f-pops.cl")

  ;(my_load "l-gena.cl" CUR_DIR)
  ;(my_load "i-mgen.cl" CUR_DIR)
  
  ;(my_load "p-prog.cl" CUR_DIR)
  (load "i-prog.cl")

  ;(my_load "p-comm.cl" CUR_DIR)
  (load "i-comm.cl")

  (load "i_regr.li")
  (run_cdr_argus (first argus) argus "REGR ..")

)
;-------------------------------------------------------------------------------

(READ_AND_CALL_ARGUS  CUR_DIR)

; ==============================================================================
; TODO: 

; - попробовать GP (для всeх булeвых функций) а такжe ADF;
; - улучшить ADF, введя отдельную библиотеку для функций и стат. инфу на них;

; - BOOL: эквивалентные преобразования булевых выражений (автомат. поиск формул);
; - REAL: вместо защищенных функций - обработку особых ситуаций и их учет;

;===============================================================================
