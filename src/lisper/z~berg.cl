; -*-   mode: lisp ; coding: koi8   -*- ----------------------------------------

;-------------------------------------------------------------------------------
;===============================================================================


(format t "~% ")

(require 'asdf)

;(push "EXT/LSP/src/"  asdf:*central-registry*)
(push "./"  asdf:*central-registry*)

(asdf:load-system :pkgcocom) 

;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
(defun MAIN ()

  (load "a-plot.cl") 
  (load "f-func.cl")

  (load "h-mbee.cl")    
  (load "r-obot.cl")  
  (load "h-gslm.cl")
  (load "r-ogsl.cl") 
 
  (load "s_funo.cl") 
  (load "solver.cl") 


  (load "z-cell.cl")
  (load "z-main.cl")

  (cagl_main NIL)

  (format t "~% ")

)
;-------------------------------------------------------------------------------


(MAIN)

;===============================================================================
; 
;===============================================================================
