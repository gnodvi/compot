; -*-   mode: lisp ; coding: koi8   -*- ----------------------------------------

;-------------------------------------------------------------------------------
;===============================================================================

(require 'asdf) 

(require 'uiop)

;-------------------------------------------------------------------------------

;(defpackage #:O
;  (:use     :cl :asdf))
;;;  (:use     :cl :asdf :gm-com))

;(in-package :O)

;===============================================================================

(defvar CUR_DIR "r")


;(push "../gm-com/sys/"  asdf:*central-registry*)
;(asdf:load-system :gm-com) 

;(load "EXT/LSP/src/a-comm.cl")
(load "a-comm.cl")


(load "f-func.cl")

;===============================================================================


;(defpackage #:O
;  (:use     :cl :asdf))
;;;  (:use     :cl :asdf :gm-com))

;(in-package :O)

;(use-package :asdf)

;(defsystem MINF-asd
;  :default-component-class cl-source-file.cl 
;  :defsystem-depends-on    (:asdf-encodings)

;  :components (

;;               (:static-file "o-mbee.cl")              
;;               (:static-file "o-obot.cl")  
;;               (:static-file "m-gslm.cl")
;;               (:static-file "o-ogsl.cl")                
;;               (:static-file "o_test.li")


;               (:file "o-mbee")              
;               (:file "o-obot")  
;               (:file "m-gslm")
;               (:file "o-ogsl")                
;               (:static-file "o_test.li")

;               )
;)

;-------------------------------------------------------------------------------
(defun MINF (argus)

;  (my_load "a-func.cl" CUR_DIR)
;  (my_load "n-mbee.cl" CUR_DIR)

;  (my_load "n-obot.cl" CUR_DIR)  
;  (my_load "m-gslm.cl" CUR_DIR)
;  (my_load "n-ogsl.cl" CUR_DIR) 

  ;(load "./a-func.cl")


;  (asdf:load-system :MINF-asd) ; не загружается ???
;
;*** - FUNCALL: undefined function MORE_TEST


  (load "h-mbee.cl")

  (load "r-obot.cl")  
  (load "h-gslm.cl")
  (load "r-ogsl.cl") 

  (load "r_otst.li")


  (run_cdr_argus (first argus) argus "MINF ..")

)
;-------------------------------------------------------------------------------
(defun GENA (argus)

  ;(my_load "a-func.cl" CUR_DIR)
  (load "f-pops.cl")

  ;(my_load "l-gena.cl" CUR_DIR)
  (load "h-mgen.cl") 
 
  (run_cdr_argus (first argus) argus " ..")
)
;-------------------------------------------------------------------------------
(defun VALS (argus)
  
  ;(my_load "a-func.cl" CUR_DIR)

  (my_load "f-pops.cl" CUR_DIR)
  ;(my_load "l-gena.cl" CUR_DIR)
  ;(my_load "g-mgen.cl" CUR_DIR)  
  (load "h-mgen.cl")  
  ;(my_load "h-mbee.cl" CUR_DIR) 
  (load "h-mbee.cl") 
 
  ;(my_load "n_vals.li" CUR_DIR)
  (load "i_vals.li")

  (run_cdr_argus (first argus) argus "VALS ..")
)
;-------------------------------------------------------------------------------
;===============================================================================

(READ_AND_CALL_ARGUS  CUR_DIR)

; ==============================================================================

; TODO: 

; - описаниe счeтных функций (в видe объeктов);
; - выдeлить объeктно-сорeвноватeльную систeму из m-obot.cl;
; - 
; - нeсколько хромосом (и вообщe додeлать GA);
; - провeрить на тeстах как в Матлабe;
; - поиск с ограничeниями;
; - соeдинить с пчeлиным поиском;

;===============================================================================

; cl n~.cl VALS vals_find t5 0.1 1 5 @ GA 40 8 0.7 0.2
; ????

;===============================================================================
