; -*-   mode: lisp ; coding: koi8   -*- ----------------------------------------

;===============================================================================
;===============================================================================

(defvar CUR_DIR  "b")


;----------------------------------------

(require 'asdf)

(format t "~% ")
;(push "EXT/LSP/src/"  asdf:*central-registry*)
(push "./"  asdf:*central-registry*)


(asdf:load-system :pkgcocom) 

;----------------------------------------

;(load "CLI/src/c-comm.cl")
;
;*** - READ from #<INPUT BUFFERED FILE-STREAM CHARACTER #P"COM/src/a-comm.tl" @2>: bad
;      syntax for pathname: #PACKAGE

;(load "CLI/src/c-comp.cl")
;(load "CLI/src/c-plot.cl")

;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
(defun GRAF (argus)

  (load "b-graf.cl")

  (run_cdr_argus (first argus) argus "GRAF ..")
)
;-------------------------------------------------------------------------------
(defun NETS (argus)

  ;(load "CLI/src/c-comp.cl")

;*** - LOAD: A file with name Others/g-graf.cl does not exist
; l - указывает на эту папку
  
;  (my_load "b-graf.cl" CUR_DIR)
;  (my_load "b-nets.cl" CUR_DIR)

  (load "b-graf.cl")
  (load "b-nets.cl")

  (run_cdr_argus (first argus) argus "NETS ..")
)
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------

(READ_AND_CALL_ARGUS  CUR_DIR)

;-------------------------------------------------------------------------------

; cl g~.cl GRAF test_00 
; cl g~.cl GRAF test_01 
; cl g~.cl,GRAF,test_05
; sl g~.cl GRAF test_11 
; sl g~.cl GRAF test_99 

; cl g~.cl NETS amat_03 

;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
