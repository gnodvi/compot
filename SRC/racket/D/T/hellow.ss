;;#! /usr/bin/env racket

;;#lang racket/load

;-------------------------------------------------------------------------------

; PS/Tk Example Program "Hello World"
; Copyright (C) 2006 Nils M Holm
; See the PS/Tk license for conditions of use.
;-------------------------------------------------------------------------------

;(printf "............... 1 \n")
;(flush-output)
;(exit)

;(load "pstk.scm")
(load "pstk.scm")

;-------------------------------------------------------------------------------

(define *wish-debug-input*  #t)
(define *wish-debug-output* #t)


;(display "............... 2")
;(report-error
; "You need to choose a version of RUN-PROGRAM first !!!!!!!!!!!!!!!1")
;report-error: undefined;
; cannot reference undefined identifier


(tk-start)

; (start) 
; start: undefined; - хотя этоа функция определена в letrec !!??

;-------------------------------------------------------------------------------

(let* (
  (label   (tk 'create-widget 'label
               'width: 20
               'height: 5
               'text: "Hello, World!"
               'font: "Helvetica 20"
               'fg: "#ff0000"))

  (bt-quit (tk 'create-widget 'button
               'text:    "Goodbye"
               'command: (lambda () (tk-end)))))
  
  (tk/pack label bt-quit)
  
  (tk-event-loop)
)

;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
