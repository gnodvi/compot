; -*-   mode: lisp ; coding: koi8   -*- ----------------------------------------

;-------------------------------------------------------------------------------
;===============================================================================

(defvar CUR_DIR  "p")

;(load "EXT/LSP/src/a-comm.cl")
(load "a-comm.cl")

;---------------------------- hfjgh-------------hfjgh-
;(load "../../a-comm.cl")
;
; TODO: �� ����� "�������" ��� ����� ��������� ������� my_load - ����
;       ��� ��������� ��� ������ �� �� TCL ����������
;  ghgjghjg ghgjghjg ghgjghjg hfjgh ;ljklj
;  ������ ���� !!!!! ��� �� Xming !!!! jhjhjh ��������� ���� !!!
;-----------------------------------------



;-------------------------------------------------------------------------------
(defun TEST (argus)

  ;(my_load "f-tabs.cl" CUR_DIR) (use-package :a-ctab)
  ;(my_load "f-tour.cl" CUR_DIR)

  (load "f-tabs.cl") (use-package :a-ctab)
  (load "f-tour.cl")

  (my_load "p_test.cl" CUR_DIR)
  (my_load "p-rsb-.cl" CUR_DIR)
  (my_load "p_rsb1.cl" CUR_DIR)

  ;(load "v_test.cl")
  ;(load "v-rsb-.cl")
  ;

  (run_cdr_argus (first argus) argus "TEST ..")

)
;===============================================================================

(READ_AND_CALL_ARGUS  CUR_DIR)

(format t "~%") ; ��������� main �e ��e��� ...

;===============================================================================

