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
; �� ���� ��� ���������, ���� ����� �� ����� �� ������ ��������, ����������:
; 
; asdf? cl-lunch, .. ?
; 
;-------------------------------------------------------------------------------
(defun my_load_new (fname      ; ��� ����� ��� �������� 
                ;bukva_from ; �� ������ ���e�� �������e� 
                )

(let* (
;  (bukva_to (get_bukva fname))  ; � ����� ���e�e ���� ��������;
;  (prefix   (prefix_find_global ; �e��e� �������e����� ���� � �����, 
;             GLOBAL_DIRS_TABL   ; ���������� ������� ���e���; 
;             bukva_from bukva_to))

;  (filename   (concatenate 'string prefix "/"   fname))  ; ������������ + ���

;  (fname_base (subseq fname 0 6))  ; ���� �� ���ee ����� 
;  (filename_T (concatenate 'string prefix "/T/" fname_base)) 

  (filename_T (concatenate 'string "./T/" fname)) 

  ; ������������ + ��� (�e� ������e���)

  ret 
  )

;  (load filename)
;  (return-from my_load) ; ���� ������ ���e� �� �������e.. ���������:
  ;; �e ����e����e��� ����������� ���e�e��� !!

  ;;-------------------------------------------------------------------
;  (format t "fname= ~s  ~%" fname )
;  (format t "fname_base= ~s  ~%" fname_base )
;  (format t "filename_T= ~s  ~%" filename_T )

  ; ��e�� ���� �� �������� ������� � ���e������ ./T �� ��e��e� ������� ���
  ; ����������������� ��e ��������

  (setf ret (load filename_T :if-does-not-exist nil))

  ;; �� � e��� ���e����� e���, � �������� �� ��� ��e ���e�e�?? !!

  (when (eq ret NIL) ; e��� �e� �����������������, ��

    ;(format t "filename_T = NIL ~%")   
    ; ���������� �������
    ;(compile-file filename :verbose NIL :output-file filename_T :print NIL) 

    ;(compile-file filename :output-file filename_T ) 

    (load filename_T) ; �������� ��e ����������������
    )

))
;===============================================================================


(load "t_meta.cl") ; ��� �� ���� ���� �������������?

;(my_load_new "u_meta.cl")

;===============================================================================
(defun MAIN ()

(let* (

  gr 

  (p_out (list 

    ;'(1 "Nodes"   TRUE  NIL) ; �������, ��� ������ ������� !? ���!

    '(1 "Rmax"    TRUE  NIL)
    '(1 "Rmin"    TRUE  NIL)

    ;; '(2  "D"      TRUE  NIL)
    ;; '(2  "R"      TRUE  NIL)

    ;'(3 "NumD"    TRUE  NIL)
    ;'(3 "NumR"    TRUE  NIL)

    ;'(4 "Nminus"  TRUE  NIL)
    ;'(4 "Nplus"   TRUE  NIL)
    ;'(4 "Nnull"   TRUE  NIL)

    ;;'(2 "Sum"    NIL  NIL) ; !!! �e ������e� ������ !! �� ���e� �� �����e ���e�..
    ;;'(2 "Sum"    FALSE  NIL) ; !!! �e ������e� ������ !!
    ;'(2 "Sum"    TRUE  NIL)

    ;'(2 "Metr"   TRUE  NIL)
    ))

  (nn    10)  ; ���������� ����� � �����
  (nums  10)  ; ���������� �����
  (test   1)  ; ������� ��������� (�����)

  (point  0)  ; ��������� ����� (����)
  )


  ;; -----------------------------------------------
  (format t "~%")

  (setf gr (Graf_Create nn))

  (format t "~%")

  (Graf_Print gr)

  (srandom_set -1) ; ����������������� �� �������

  (Graf_Init  gr GR_RAND 0.0 0.0  GR_RAND 0.0 0.0)

  (format t "~%")

  (Graf_Print gr)

  ;; -----------------------------------------------

  (tao_loop0_main  gr  nums  
                   test  point 
                   p_out   
                   0 ; is__gnu = 0, 1: �������� �� � Gnuplot
                   ) 

  (Graf_Print gr)

  (format t "~%")

))
;-------------------------------------------------------------------------------

(MAIN)

;-------------------------------------------------------------------------------


; tao_loop0 - ���� ����������, �� ��������; ������ ���� �� ������ � ��������
;             ��������� ����� � ������ ���������� �� ���� ������.
; 
; tao_loop1 - ������������� ��������� ��������� �� ����� �������� ��� �������
;             ����� �� ��� ���������.

;===============================================================================
