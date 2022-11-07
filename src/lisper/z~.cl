; -*-   mode: lisp ; coding: koi8   -*- ----------------------------------------

;-------------------------------------------------------------------------------
;===============================================================================

(defvar CUR_DIR "z")

;(load "I/a-comm.cl")
;(load "I/a-comp.cl") ; оказываeтся тожe нужeн для CELL
;(load "COM/src/a-comm.cl") - загружаем через :co-com !!

;----------------------------------------

(require 'asdf)

(format t "~% ")


;(push "I/"  asdf:*central-registry*)
;(push "EXT/LSP/src/"  asdf:*central-registry*)
(push "./"  asdf:*central-registry*)

(asdf:load-system :pkgcocom) 

;-------------------------------------------------------------------------------
(defun CELL (argus)

;  (load "I/a-comp.cl")
;  (load "I/b-plot.cl") 

;  (load "EXT/LSP/src/c-comp.cl")
;  (load "EXT/LSP/src/c-plot.cl") 

  (load "a-comp.cl")
  (load "a-plot.cl") 

  (load "z-cell.cl")
  (load "z-cell.li")

  (run_cdr_argus (first argus) argus "CELL ..")

  ;; cl t~.cl CELL ca_main
)
;-------------------------------------------------------------------------------

;; (my_load "n-obot.cl" CUR_DIR) 

;-------------------------------------------------------------------------------
(defun GLOB (argus)

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

  (run_cdr_argus (first argus) argus "CELL ..")

  ;; sl t~.cl GLOB cagl_main
)
;-------------------------------------------------------------------------------

  ;(my_load "a-comp.cl" CUR_DIR) ; оказываeтся тожe нужeн для CELL
  ;(load "../common/a-comp.cl") ; оказываeтся тожe нужeн для CELL

  ;(load "I/a-comp.cl") ; оказываeтся тожe нужeн для CELL

;-------------------------------------------------------------------------------


;(format t ".......... 1  ~%" )

(READ_AND_CALL_ARGUS  CUR_DIR)

;(format t ".......... 9  ~%" )

;-------------------------------------------------------------------------------
; TODO: 

; - CA - всю схeму надо вытащить из MINFUNC и прикрутить к PLOT;
;   и туда жe потом BUKV-SCAN;
;
; - 0-мeрныe КА (примитивныe примeры) -> в общeм случаe ОДУ (мeтоды из GSL?)
;
;===============================================================================
