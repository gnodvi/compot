; -*-   mode: lisp ; coding: koi8   -*- ----------------------------------------

;-------------------------------------------------------------------------------
;;;=============================================================================


;;#+CLISP  (load "asdf/asdf.fas")

(require 'asdf) ; почему ен грузит автоматом ??

;-------------------------------------------------------------------------------


(format t "~% ")

;-------------------------------------------------------------------------------
;(load "./a-comm.cl")


(push "./"  asdf:*central-registry*)

;;#+SBCL  (require :sb-posix) ; странно, почему надо именно здесь?

;(asdf:load-system :co-com) 

(asdf:load-system :pkgcocom) 

;==============================================================================

;;#+SBCL  (require :sb-posix)
;;#+SBCL (sb-ext:enable-debugger)  ; наоборот, запустит дебагер !

(require 'uiop)

(uiop:run-program "ls -all" :output "T/a_test.ls" :if-output-exists :supersede)

(format t "~s " (uiop:directory-files "." "c*"))

(format t "~%")
(format t "~%")

;(quit)

;==============================================================================


;(let* (
;  (cmd       "cl a~.cl COMM rand_1 2> /dev/null")
;  (CALC_FILE  "CALC_FILE")
;  )

;  (format t "~% ")
  
;  ;;(defparameter com )
  
;  #+:CLISP 
;  ;;(EXT:run-shell-command cmd     :output CALC_FILE) 
;  (EXT:run-shell-command cmd     :output CALC_FILE) 
  
;  #+SBCL 
;  ;;(sb-ext:run-program    cmd nil :output CALC_FILE :if-output-exists :supersede  :search t) 
;  (uiop:run-program    cmd  :output CALC_FILE :if-output-exists :supersede) 
  
;  (format t "~% ")
  
;  (quit)
  
;)

;==============================================================================


;(asdf:load-system :gm-com) 
;cl a~.cl COMM rand_1


;(rand_1 NIL)


;(format t "~% ")
;(format t "----------------------------------------------------- ~% ")
;(format t "~% ")

;(rand_4 NIL)

;(format t "~% ")
;(format t "----------------------------------------------------- ~% ")
;(format t "~% ")

;(test5 NIL)

;(format t "~% ")
;(format t "----------------------------------------------------- ~% ")
;(format t "~% ")


;(win_test_old NIL)

;===============================================================================
; 

;#+CLISP
;(format t "LOAD-PATH = ~s ~%" CUSTOM:*LOAD-PATHS* )

;(format t "~% ")
 
; 
;===============================================================================
