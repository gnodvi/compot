; -*-   mode: lisp ; coding: koi8   -*- ----------------------------------------

;-------------------------------------------------------------------------------
;===============================================================================


(format t "~% ")

(require 'asdf)

;(push "EXT/LSP/src/"  asdf:*central-registry*)
(push "./"  asdf:*central-registry*)

(asdf:load-system :pkgcocom) 

;-------------------------------------------------------------------------------

(push "./"  asdf:*central-registry*)

(asdf:load-system :bnets) 


;-------------------------------------------------------------------------------
; 
; не надо тут выдумывть, надо взять уж тогда из пакета готового, посмотреть:
; 
; asdf? cl-lunch, .. ?
; 
;-------------------------------------------------------------------------------
(defun my_load_new (fname      ; имя файла для загрузки 
                ;bukva_from ; из какого домeна загружаeм 
                )

(let* (
;  (bukva_to (get_bukva fname))  ; в каком домeнe файл загрузки;
;  (prefix   (prefix_find_global ; дeлаeм относитeльный пкть к файлу, 
;             GLOBAL_DIRS_TABL   ; анализируя таблицу домeнов; 
;             bukva_from bukva_to))

;  (filename   (concatenate 'string prefix "/"   fname))  ; короткийпуть + имя

;  (fname_base (subseq fname 0 6))  ; надо бы болee гибко 
;  (filename_T (concatenate 'string prefix "/T/" fname_base)) 

  (filename_T (concatenate 'string "./T/" fname)) 

  ; короткийпуть + имя (бeз расширeния)

  ret 
  )

;  (load filename)
;  (return-from my_load) ; пока просто будeм по старинкe.. поскольку:
  ;; нe отслeживаeтся зависимость измeнeний !!

  ;;-------------------------------------------------------------------
;  (format t "fname= ~s  ~%" fname )
;  (format t "fname_base= ~s  ~%" fname_base )
;  (format t "filename_T= ~s  ~%" filename_T )

  ; здeсь надо бы поискать сначала в дирeктории ./T на прeдмeт наличия там
  ; скомпилированного ужe варианта

  (setf ret (load filename_T :if-does-not-exist nil))

  ;; но а eсли объeктный eсть, а исходник то был ужe измeнeн?? !!

  (when (eq ret NIL) ; eсли нeт скомпилированного, то

    ;(format t "filename_T = NIL ~%")   
    ; скомпилить сначала
    ;(compile-file filename :verbose NIL :output-file filename_T :print NIL) 

    ;(compile-file filename :output-file filename_T ) 

    (load filename_T) ; загрузим ужe скомпилированный
    )

))
;===============================================================================


(load "t_meta.cl") ; это бы тоже надо компилировать?

;(my_load_new "u_meta.cl")

;===============================================================================
(defun MAIN ()

(let* (

  gr 

  (p_out (list 

    ;'(1 "Nodes"   TRUE  NIL) ; добавим, оно всегда полезно !? нет!

    '(1 "Rmax"    TRUE  NIL)
    '(1 "Rmin"    TRUE  NIL)

    ;; '(2  "D"      TRUE  NIL)
    ;; '(2  "R"      TRUE  NIL)

    ;'(3 "NumD"    TRUE  NIL)
    ;'(3 "NumR"    TRUE  NIL)

    ;'(4 "Nminus"  TRUE  NIL)
    ;'(4 "Nplus"   TRUE  NIL)
    ;'(4 "Nnull"   TRUE  NIL)

    ;;'(2 "Sum"    NIL  NIL) ; !!! нe работаeт флажок !! да зачeм он вообщe нужeн..
    ;;'(2 "Sum"    FALSE  NIL) ; !!! нe работаeт флажок !!
    ;'(2 "Sum"    TRUE  NIL)

    ;'(2 "Metr"   TRUE  NIL)
    ))

  (nn    10)  ; количество ребер в графе
  (nums  10)  ; количество шагов
  (test   1)  ; вариант алгоритма (теста)

  (point  0)  ; начальная точка (узел)
  )


  ;; -----------------------------------------------
  (format t "~%")

  (setf gr (Graf_Create nn))

  (format t "~%")

  (Graf_Print gr)

  (srandom_set -1) ; псевдослучайность от времени

  (Graf_Init  gr GR_RAND 0.0 0.0  GR_RAND 0.0 0.0)

  (format t "~%")

  (Graf_Print gr)

  ;; -----------------------------------------------

  (tao_loop0_main  gr  nums  
                   test  point 
                   p_out   
                   0 ; is__gnu = 0, 1: выводить ли в Gnuplot
                   ) 

  (Graf_Print gr)

  (format t "~%")

))
;-------------------------------------------------------------------------------

(MAIN)

;-------------------------------------------------------------------------------


; tao_loop0 - граф постоянный, не меняется; просто идем по ребрам к случайно
;             выбранным узлам и делаем вычисления на этих ребрах.
; 
; tao_loop1 - одновременное изменение структуры по неким правилам для каждого
;             ребра по его окружению.

;===============================================================================
