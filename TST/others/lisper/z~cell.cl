; -*-   mode: lisp ; coding: koi8   -*- ----------------------------------------

;-------------------------------------------------------------------------------
;===============================================================================


(format t "~% ")

(require 'asdf)

;(defpackage #:cell-asd
;  (:use :cl :asdf)
;  )
;(in-package :cell-asd)


;(defsystem :gol
;           :default-component-class cl-source-file.cl ; ����� ���� � *.cl
;           :defsystem-depends-on    (:asdf-encodings) ; 

;           :description "..............."
;           :components 
;           ((:file "n-cell"))
;           )

;-------------------------------------------------------------------------------

;(push "EXT/LSP/src/"  asdf:*central-registry*)
(push "./"  asdf:*central-registry*)

(asdf:load-system :pkgcocom) 

;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
(defun MAIN ()

  ;;  (load "I/a-comp.cl")
  ;;  (load "I/b-plot.cl") 

  (load "a-comp.cl")
  (load "a-plot.cl") 

  (load "z-cell.cl")
  (load "z-cell.li")

  (ca_main NIL)

  (format t "~% ")
)
;-------------------------------------------------------------------------------


(MAIN)

;===============================================================================
; 
;===============================================================================