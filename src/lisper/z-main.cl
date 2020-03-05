; -*-   mode: lisp ; coding: koi8   -*- ----------------------------------------

;-------------------------------------------------------------------------------
;===============================================================================
;                                                                              *
;  ��� ����� �����: s_cell.cl                                                  *
;                                                                              *
;-------------------------------------------------------------------------------


;(load "n-cell.cl")

;-------------------------------------------------------------------------------
;(defun ca_calc_sum_interval (index minfunc ti_old xi)
(defun cm_calc_sum_interval (num minfunc ti_old xi)

(let* (
  ;(num  (num_from_sumind index))
  ;(num  (num_from_sumind (second *sxema_sum*)))

  (sum  (Fun_ xi ti_old))
  l  r
  )

  (loop for i from 1 to num do
    (setf l   (Fun_ (- xi i) ti_old))
    (setf r   (Fun_ (+ xi i) ti_old))

    (incf sum (+ l r))
    )

  sum 
))
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
(defun cm_calc_n (minfunc ti_old xi)

(let (
  sum n    

  (sxm (first  *sxema_sum*))
  ;(ind (second *sxema_sum*))
  (num  (num_from_sumind (second *sxema_sum*)))
  )

  ;(setf *sxema* (first  *sxema_sum*))
  ;(setf *ind*   (second *sxema_sum*))

  ;(setf sum (ca_calc_sum_interval *ind* minfunc ti_old xi))
  ;(setf sum (ca_calc_sum_interval ind minfunc ti_old xi))
  (setf sum (cm_calc_sum_interval num minfunc ti_old xi))

  ;; ���� �� ����e���� � �����e���� ����e���� ?

  ;(setf n  (get_n_from_sxema sum *sxema*))
  (setf n  (get_n_from_sxema sum sxm))

  ;(format t " n=~s  ... ~%" n)
  
  n
))
;-------------------------------------------------------------------------------
(defun cm_print_one (minfunc ti)

(let (
  (arr (FVAL_ARR ti 0))
  value chara
  )

  (format t "ARR =  ")  

  (dotimes (xi (XNUM))
    (setf value (aref arr xi)) ; �e�����e ����e��e � ��e��e
    (setf chara                ; �e�e�e�e� � �e������ ������
          (ca_get_chara value)
          )

    (cond
     ((eq chara '1) (win_sgr SGR_RED)  )
     ((eq chara '2) (win_sgr SGR_GREEN))
     ((eq chara '3) (win_sgr SGR_CYAN) )
     ((eq chara '4) (win_sgr SGR_BROWN))
     )
    
    (format t "~s " chara) ; e��� �����, �� ����e �� ���e������ �������

    (win_sgr SGR_DEFAULT)
    )

  (format t "~%")  

))
;-------------------------------------------------------------------------------
(defun cm_print_all (minfunc)

(let* (
  (tnum  (1+ (TOLD))) ;/* ��������� �������� ���� */ + 1

  ;(plot  (plot_create (FNUM) (XNUM) tnum))
  )

  (dotimes (ti tnum)
    ;; 
    ;(format t "ARR= ~s ~%" (FVAL_ARR ti 0))  
    (cm_print_one  minfunc ti)
    )

))
;-------------------------------------------------------------------------------
;
; ��� ��e�� CM (�.e. CA �e�e� MINFUNC) ���� �������� �� MINFUNC � ���������� � PLOT
;
;===============================================================================
;
;
; ��e�� �������e��� ����� ������ �e��e���
;
;
;===============================================================================
;double
(defun cagl_calc_rezi (
             minfunc  ; void *mf 
             xyz      ; double *xyz
             )

(declare (ignore xyz))

(let* (
  (ti   (TI))
  (ti_old  (- ti 1))
  n r rezi f 

  (num  (num_from_sumind (second *sxema_sum*)))
  )

  ;;  ���������� �������, �.�. ���������� �� ������� �������
  (setf rezi  0.0)

  ;; ��� ��� ��e���� � ������� ��e�e
  ;(loop for xi from (+ X_BEG 1) to (- (X_END) 1) do
  (loop for xi from (+ X_BEG num) to (- (X_END) num) do

    (setf n (cm_calc_n  minfunc ti_old xi)) ; ��������e ����e ����e��e
    (setf f (Fun_ xi ti))
    ;(format t "~4,2f " f)

    (setf r (- f n))
    (incf rezi (* r r))
    )

  (setf rezi (sqrt rezi))
  ;(format t "rezi=~4,2f ~%" rezi)

  rezi
))
;-------------------------------------------------------------------------------
(defun cagl_sets (mode)

  (declare (ignore mode))

  (values  'berger_null 'berger_calc_rezi) ; ������ ������� ������� �� �e��e���
  ;(values  'ca_init_minfunc 'cagl_calc_rezi) ; ����� �������

  ; ����: ���e���� �����e��� ������, ��� �e �������� ��e������ e������ ��e���!!
)
;-------------------------------------------------------------------------------
(defun cagl_argv (argus) 

(declare (ignore argus))

(let (
  (mode  "")

  ;(xx    10) ; ��e�� �����e �e� ����������.. ��� �e��e��� !
  (xx    20) 
  (tt    2)  ;; 50 ����
  (tstep 0.005) ;; ����� �������� ?

  (xmin  0.0)
  (xmax  (* 2 G_PI))

  ;(argc (list-length argus))
  )

  (values mode xx xmin xmax tt tstep)
))
;-------------------------------------------------------------------------------
(defun cagl_main (argus) 

(let (
  mbot ; YT_MINBOT *mbot

  (num       100) ;  int     num = 100;
  (stop_func 0.1) ; double  stop_func = 0.1 /* 0.08 */; 
  minfunc
  )

  (YRAND_C)

  (setf mbot (minbot_make "" 
                          'botspusk_fun_init
                          'botspusk_fun_data 
                          'botspusk_fun_todo
                          num 0 0 stop_func))

;  (format t "1 ..... ~%")
  (setf minfunc (temp_main  argus "BergerTest" "U" 'cagl_argv 'cagl_sets
                            mbot))

;  (format t "2 ..... ~%")
;  (format t "~%") 
;  (minfunc_print_one *minfunc_read_save* -1000) ; ����e���� ������

  (format t "~%") 
  (format t "~%") 
  (cm_print_all minfunc)
  (format t "~%") 

))
;===============================================================================
