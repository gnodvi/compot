; -*-   mode: lisp ; coding: koi8   -*- ----------------------------------------

;-------------------------------------------------------------------------------
;;;=============================================================================

(defvar *num_calc* 0)

(defvar  *xyz_min_list* :unbound)
(defvar  *xyz_max_list* :unbound)
(defvar  *len* :unbound)

;-------------------------------------------------------------------------------
; ��������e ����e��e �� ���e����� [-max-value, max-value] ??
;-------------------------------------------------------------------------------
(defun random-value (max-value)

(let (
  r ;(r (YRAND 0 max-value))
  ret
  )

  (if *simp_random*
    (setf r (YRandF 0 max-value))
    (setf r (YRAND  0 max-value))    
    )

  ; (- max-value (* 2 (random max-value)))
  ; (- max-value (* 2 (YRAND 0 max-value)))

  (setf ret (- max-value (* 2 r)))

  ;(- max-value (* 2 r))

;  (when *debug_print*
;    (format t "  random-value: max_value= ~s  r= ~s  ret= ~s ~%" 
;            max-value r ret)
;  )
  
  ret
  ;(coerce ret 'double-float)
))
;-------------------------------------------------------------------------------
(defun make_i_check (point i r)

(let (
  xyz_min xyz_max
  (r (coerce r 'double-float))
  )

  (setf xyz_min (nth i *xyz_min_list*))
  (setf xyz_max (nth i *xyz_max_list*))
  
  (when (< r xyz_min)  (setf r xyz_min))
  (when (> r xyz_max)  (setf r xyz_max))

  (setf (nth i point) r)

))
;-------------------------------------------------------------------------------
; �����e� ��������� ����� � ���e�������
;-------------------------------------------------------------------------------
(defun make_rand_obee_near_point (point_null interval)

(let* (
  (len    (list-length point_null))
  (point  (make-list len))
  c d 
  )

  (dotimes (i len)

    (setf c (nth i point_null))
    (setf d (random-value interval))

    (when *debug_print*
      (format t
              "make_rand_near_point: c= ~s d= ~s ~%" c d)
      )
    
    (make_i_check  point i (+ d c))
    )

  (when *debug_print*
    (format t
            "make_rand_near_point: point= ~s [~s] ~%" point interval)
    (format t "~%")
    ;(quit)
    )
  
  point
))
;-------------------------------------------------------------------------------
; ����e��e� �����. ��������e� "quantity" ��e� � ���e������� "interval"
; ����� "point" (� �����������e ����e������� "dim" ?)
; 
; ������e���, ���� ������ �����e� ������ ��������� ��e� � ���e�������!
;-------------------------------------------------------------------------------
(defun make_rand_bees_near_point (point interval quantity)

(let (
  (bees (make-list quantity))
  )

  (dotimes (i quantity)

    (setf (nth i bees) (make_rand_obee_near_point point interval))
    )

  

  bees
))
;-------------------------------------------------------------------------------
(defun random_in_interval (fmin fmax)

(let (
;  (coerce (- (random-floating-point-number (- fmax fmin)) (- 0.0 fmin))
;          'single-float)
  r
)

  (setf r (YRandF fmin fmax))

;  (when *debug_print*
;    (format t "random_in_interval: r = ~s ~%" r)
;    ;(quit)
;    )

  r
))
;-------------------------------------------------------------------------------
(defun make_in_interval ()

(let* (
  ;(len (list-length *xyz_min_list*))
  (len *len*)

  (point (make-list len))
  r xyz_min xyz_max
  )

  (dotimes (i len)

    (setf xyz_min (nth i *xyz_min_list*))
    (setf xyz_max (nth i *xyz_max_list*))

    (setf r (random_in_interval xyz_min xyz_max))

    (setf (nth i point) r)
    )

  point
))
;-------------------------------------------------------------------------------
(defun explore_interval (quantity)

(let (
  (bees (make-list quantity))
  )

  (when *debug_print*
    (format t "QUANTITY= ~s ~%" quantity)
    )
  
  (dotimes (i quantity)
    (setf (nth i bees) (make_in_interval))
    )

  (when *debug_print*
    (format t "explore_interval: bees = ~s ~% ~%"  bees)
    ;(quit)
    )

  bees
))
;-------------------------------------------------------------------------------
; ��������e� ��e�-����e������ � �����e���e "number-of-scouts"
; � ���e������� [*xyz_min_list* *xyz_max_list*]
;-------------------------------------------------------------------------------
(defun random-search (number-of-scouts)

  (explore_interval number-of-scouts)

)
;-------------------------------------------------------------------------------
; 
;-------------------------------------------------------------------------------
(defun calc-and-sort-list (func list)

(let* (
  (res-list (mapcar func list)) ; ����e��� ������� ��� ��e� ���e� ������
  (res-list-sorted (stable-sort (copy-list res-list) #'>))

  pos_list rev_list ret_list
  )

  (setf *num_calc* (+ *num_calc* (list-length list)))

  ; �� ��������� ������ �e�e� � ������ ����e�����e������� ��e�e���
  ;

  (setf pos_list (mapcar #'(lambda (val) (position val res-list))
                           res-list-sorted
                           ))

  (setf rev_list (reverse pos_list))

  (setf ret_list (mapcar #'(lambda (val) (nth val list))  rev_list))


;  (mapcar #'(lambda (val) (nth val list))           

;          (reverse ; �e��e� �� �������� (� ����� �e���� ����??)
;           ;; ������ ������� ��e�e���� �� ����������� ����e��� ������� ?
;           (mapcar #'(lambda (val) (position val res-list))
;                           res-list-sorted
;                           )
;                   ))
  
  (when *debug_print*
    (format t " ~%")
    (format t "calc-and-sort-list: ------------------------------------------- ~%")
    (format t " ~%")
    (format t "list= ~s ~%" list)
    (format t " ~%")
    (format t "res_list= ~s ~%" res-list)
    (format t " ~%")
    (format t "res_list_sorted= ~s ~%" res-list-sorted)
    (format t " ~%")
    (format t "pos_list= ~s ~%" pos_list)
    (format t " ~%")
    (format t "rev_list= ~s ~%" rev_list)
    (format t " ~%")
    (format t "ret_list= ~s ~%" ret_list)
    (format t " ~%")
    (format t "--------------------------------------------------------------- ~%")
    (format t " ~%")
    )
  
  ret_list
))
;-------------------------------------------------------------------------------
(defun get-best-elems (func list max-number)

(let (
  (l (list-length list))
  ret
  )
  ;(format t "max-number= ~S ~%" max-number)
  ;(format t "list_l    = ~S ~%" (list-length list))


  (when (> max-number l)
    (setf max-number l)
    )

  (setf ret (subseq (calc-and-sort-list func list) 0 max-number))

  (when *debug_print*
     ;    (format t " ~%")
     ;    (format t " FUNC = ~s ~%" func)
     ;    (format t " LIST = ~s ~%" list)

    (format t " ~%")
    (format t "get-best-elems: max_number = ~s   ret = ~s  ~%" max-number ret)
    (format t " ~%")
    )

  ret
))
;-------------------------------------------------------------------------------
; ��e�e�� ������ � ����e����� ����e��e� �e�e��� �������
;-------------------------------------------------------------------------------
(defun min-elem (func list)

  ; �� �e�� ��e ����� �e�� ������ ����� �������e��� ������� ?! 

  (when *debug_print*
    (format t "MIN-ELEM .........  !!! ~% ~%")
  )

  (first (get-best-elems func list 1))

)
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
(defun make_rand_bees (i points 
                       number-of-bees 
                       interval 
                       decrease)

(let (
  (num_points (length points))
  (point (nth i points)) ; (elt points i) 

  loc_interval dec loc_quantity
  )

  (setf loc_interval (if (= i 0) (* interval decrease) 
                       interval))

  (setf dec (/ (- num_points (* (+ i 1) 0.5)) 
               num_points))

  (setf loc_quantity  (if (or (= i 0) (= i 1))
                          (* number-of-bees 2)
                        (floor (* number-of-bees dec))
                        ))

  ;(format *error-output*  "make_rand_bees: ~%" )
  ;(format *error-output*  "point= ~s ~%" point)
  ;(format *error-output*  "loc_interva = ~s ~%" loc_interval)
  ;(format *error-output*  "loc_quantity= ~s ~%" loc_quantity)
  ;(format *error-output*  "~%" )
  ;(quit)

  ;; ���e� ��e ��� ���� �e ������� !
  
  ;; �������e� ������� ��������� � ���e������� ��e�
  (make_rand_bees_near_point  point 
                              loc_interval loc_quantity
                              )

))
;-------------------------------------------------------------------------------
;(defun make_circ_bees (i points 
;                       number-of-bees 
;                       interval 
;                       decrease)

;(declare (ignore number-of-bees decrease))

;(let (
;  (point (nth i points))
;  )
  
;  ;(make_circ_bees_near_point  point interval)
 
;))
;-------------------------------------------------------------------------------
; �������e���-��������� �����, ����e��e� ���e������� ������ �� ���e� "points"
;-------------------------------------------------------------------------------
(defun informed-search (func search_proc
                        points 
                        number-of-bees 
                        interval 
                        decrease)

(let (
  (num_points (length points))

  (res nil) ; ��� ������ ��e� �����e���� �����
  rand_bees ; ��� ������ ��e� ����e ������ ��������� �����

  informed-res 
  informed-res_bests
  )

  (when *debug_print*
    (format t "INFORMED-SEARCH:................................  ~%" )
    (format t "~%" )
    )

  ;; ��������� ��������� ����� ???? (���e���e ����� ������ �� �e���� ���e?)
  (push (list (first points)) res)

  (when *debug_print*
    (format t "res= ~s ~%" res)
    )

  (dotimes (i num_points)

    ;; �������e� ������ (������) ��������� � ���e������� ��e�
    (setf rand_bees (funcall search_proc  ; 'make_rand_bees
                             i points 
                             number-of-bees 
                             interval 
                             decrease))

;    (when *debug_print*
;      (format *error-output* "RAND_BEES= ~s  ~%" rand_bees)
;      (quit)
;      )


    ;; ��������� ������ � ������ ������ "res"
    ;
    ;
    ;
    (push rand_bees res)

    (when *debug_print*
      (format t "rand_bees (~s) = ~s ~%" i rand_bees)
      )

  )

  ;(format *error-output* "informed-search: ~%")

  ;(format *error-output* "  points = ~s  num_points = ~s ~%" points num_points)

  (when *debug_print*
    (format t "~%" )
    (format t "res= ~s ~%" res)
    (format t "~%" )
    )

  ;; �e�e�e����� ������ �����, ����� 1-� ���e���� � ����� 1-�.. ���e�?
  (setf informed-res (reverse res))

  (when *debug_print*
    (format t "informed-res= ~s ~%" informed-res)
    (format t "~%" )
    )

  ;;---------------------------------------------------
  ;; ��e�� ���������� ��e �e���e ������e���
  ;; ������ ������ �� ������ ������

  (setf informed-res_bests (mapcar #'(lambda (l) (min-elem func l))  
                                   informed-res))


  ;(when *debug_print*
  ;  (format *error-output* "INFORMED_RES_BESTS= ~s ~%" informed-res_bests)
  ;  (format t "~%")
  ;  (quit)
  ;  )

  informed-res_bests
))
;-------------------------------------------------------------------------------
; ������e���� ���� ������
;-------------------------------------------------------------------------------
(defun bee-stage (func random-point-number 
                       points 
                       interval number-of-bees
                       
                       chosen-number decrease)
  
(let* (
  random-res  a  ret
  informed-res_bests
  )

  ;; ���� �� ������� �������e���� ����� !!!
  ;; ������ ����� �� ������ ������ ��������-�������e���� ��e� 
  (setf informed-res_bests (informed-search func 'make_rand_bees
                                      points 
                                      number-of-bees
                                      interval decrease))


  ;; ������� ������ ���������-��������� ��e�-����e������
  (setf random-res   (random-search random-point-number))
  ;(format t "random-point-number= ~S ~%" random-point-number)
  ;(format t "random-res= ~S ~%" random-res)

  (setf a (append random-res informed-res_bests)) 
  

;  (when *debug_print*
;    (format t "~%" )
;    (format t "................................... ~%" )
;    (format t "chosen_number = ~s ~%" chosen-number)
;    (format t "................................... ~%" )
;    )

  (when *debug_print*
    (format t "BEE-STAGE .........  !!! ~% ~%")
    (format t "a = ~s ~%" a)
    (format t "~%" )
  )

  ;; �������e���� ������e� "chosen-number" ����� ������ �� ���e���e��� 
  ;; ���������� � �������e����� ������
  (setf ret (get-best-elems func a chosen-number))


  ret
))
;-------------------------------------------------------------------------------
(defun make_null_point (dim xyz_min_list xyz_max_list)

(let* (
  (xyz_min (nth 0 xyz_min_list))
  (xyz_max (nth 0 xyz_max_list))
  (random-search-interval (/ (- xyz_max xyz_min) 2))

  null-point
  )

  ;(format *error-output*  "dim = ~s ~%" dim)
  
  (setf null-point 
        (make-list dim :initial-element (+ xyz_min random-search-interval)))

  null-point
))
;-------------------------------------------------------------------------------
; ��� ���� ���������� �� ������� �������.
;-------------------------------------------------------------------------------
(defun bee-cycle (func  dim 
                        minvalue
                        num_steps                   ; �����e���� ������ ������                        

                        xyz_min_list xyz_max_list
                        random-point-number    ; �����e���� ����e������

                        null-point 
                        interval               ; ������� ������ ����� �����
                        number-of-bees 
                        
                        chosen-number          ; ������� ������ ��e� ������e� �� ���������
                        decrease 
                        )

;(declare (ignore minvalue))

(let (
  ;(eps  1.e-7) ; ����e��� ��������

  points 
  (cur-val 0) 
  ;(min-val 0) 
  (min-val 999999) 
  (tmp-decr decrease)

  dec p_number
  (find_minvalue NIL)
  )
  
  (setf *num_calc* 0) ; ����e� �����e� 
  (setf *len* dim)

  ;; ���������� ���e����, ������������ � �����e��e�
  (setf *xyz_min_list* xyz_min_list)
  (setf *xyz_max_list* xyz_max_list)

  (when (eq null-point NIL)
    ;; ��������� ����� �����e� � �e�e���e ���e����� (�� �e���� ����e������)
    (setf null-point (make_null_point  dim xyz_min_list xyz_max_list))
    )
  (setf points (list null-point)) ; ����e� � �ee ��������� �����

  ;; ------------------------------------------------------------------
  (dotimes (i num_steps)

    (when *debug_print*
      (format *error-output* "i = ~s ~%" i)
      )

    (setf dec (/ (- num_steps (+ i 1)) num_steps)) ;;??
    

    (setf p_number (floor (* random-point-number (/ (+ 1 dec) 2))) )

     (when *debug_print*
       (format t "------------------------------------ ~%")
       (format t "p_number      = ~s ~%" p_number)
       (format t "points        = ~s ~%" points)
       (format t "interval      = ~s ~%" interval)
       (format t "number-of-bees= ~s ~%" number-of-bees)
       (format t "chosen-number = ~s ~%" chosen-number)
       (format t "decrease      = ~s ~%" decrease)
       (format t "------------------------------------ ~%")
       )
  
    ;; �e�e�e��e� ������ ������ "chosen-number" ���e� (������������� �� ����e��)
    (setf points  
          (bee-stage func 
                     ;; �� ������ ���e ��e����e� �����e���� ��������� ��e�
                     p_number

                     points      ; ����� ��� �������e����� ������ (���� ��e�� ����)
                     interval    ; ��������� ���e���� 
                     number-of-bees

                     chosen-number decrease)
          )

    ;; ��� �����e��� �e���e�� � ����e�� �e�������� e�e ��� ��������
    ;; ����e��e � ����e� ����e
    (setf cur-val (funcall func (first points)))
    (if (< cur-val min-val) (setf min-val cur-val)) ;; ???

    (unless (eq NIL minvalue)
    (when (< min-val minvalue) 
      (setf find_minvalue t)
      (return)
      )
    )

;    (if (> (abs (- cur-val min-val)) eps)
;        (setf min-val cur-val)
;        (return) ; �����e��e ��e��������� � ��e�e��� ����e������
;        )
    (setf decrease (* decrease tmp-decr))

    
    (when *debug_print*
      (format *error-output* "~%")
    )
    ;(quit)
  )
  ;; ------------------------------------------------------------------

  (unless (eq NIL minvalue)
  (when (eq find_minvalue NIL) 
    (format t "~%")
    (format t "WARNING in beecycle: ~%")
    (format t "minvalue= ~S ~%" minvalue)
    (format t "min-val = ~S ~%" min-val)
    (format t "~%")
    ;(exit)
    )
  )

  (values (first points) min-val )
))
;-------------------------------------------------------------------------------
(defun bees_test_one_interval (num_steps random-point-number ffunc dim 
                                         xyz_min_list xyz_max_list
                                         )



  (multiple-value-bind (min_point min_val)

    (bee-cycle  ffunc dim 
                NIL ;0.001 ;minvalue  
                num_steps ; �����e���� ������ ������
                
                xyz_min_list xyz_max_list
                random-point-number ;    ; �����e���� ����e������
       
                NIL ;null-point       
                0.1   ; ������� ����. ������ ����� ���e�
                5 
                
                5     ; ������� ������ ��e� ������e� �� ���������
                0.95  ; ���e�e��e� �����e��� ������       
                )


    (format t "~%")
    (format t "min-val=  ~A ~%" min_val)
    (format t "point=    ~A ~%" min_point)
    (format t "num_calc= ~A ~%" *num_calc*)
    (format t "~%")
    )
)
;-------------------------------------------------------------------------------
(defun bees_test (argus)

;(declare (ignore argus))
(let (
  (flag  (nth 0 argus))
  (num_steps 100)
  (random-point-number 50)
  )

  (unless (eq flag NIL) 
    ;(format *error-output* "flag = ~s ~%" flag)
    ;(setf *debug_print* t)
    (setf *simp_random* t)

    (setf num_steps     3)
    (setf random-point-number   10)
  )

  ;;(bees_test  #'bees_peaks    2)
  (YRAND_C)
  

  (bees_test_one_interval num_steps random-point-number 
                          #'proc_martin    2  '(0.0 0.0)  '(+10.0 +10.0))

  (when *debug_print*
    (quit)
    )

  (bees_test_one_interval num_steps random-point-number 
                          #'proc_rosenbrok 2  '(-1.2 -1.2)  '(+1.2 +1.2))
  (bees_test_one_interval num_steps random-point-number 
                          #'proc_sinusoida 1 '(-10.0) '(+10.0))


  ;;(bees_test_one  #'proc_hsphere    6)
  ;;(bees_test_one  #'proc_griewangk 10)

))
;-------------------------------------------------------------------------------
(defun random_test (argus)

  (declare (ignore argus))

  (setf *debug_print* t)
  (setf *simp_random* t)

  (YRAND_C)

;  (format t "r= ~s ~%"  (YRAND 0 0.095))
;  (format t "r= ~s ~%"  (YRAND 0 0.095))
;  (format t "r= ~s ~%"  (YRAND 0 0.095))
;  (format t "r= ~s ~%"  (YRAND 0 0.095))

  (YRAND 0 0.095)
  (YRAND 0 0.095)

  ;(format t "Y-random = ~s ~%" (Y-random))
  ;(format t "Y-random = ~s ~%" (Y-random))

  (format t "~%")
)
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
(defun random_test_new  (argus)

  (declare (ignore argus))

  (setf *debug_print* t)
  (setf *simp_random* t)

  ;(format t "~s ~%"  (_RandomInit 5049))


  (format t "~s ~%"  (_Random))
  (format t "~s ~%"  (_Random))

  (format t "~s ~%"  (_RandomRange 100))

  (format t "~%")

  (format t "[YRandF 10 20] = ~s ~%"  (YRandF 10 20))
  (format t "[YRandF 10 20] = ~s ~%"  (YRandF 10 20))

  (format t "~%")

  (format t "[YRandF 80 90] = ~s ~%"  (YRandF 80 90))
  (format t "[YRandF 80 90] = ~s ~%"  (YRandF 80 90))

  (format t "~%")


  (format t "[random-value 0.095] = ~s ~%"  (random-value 0.095))

;  (format t "[YRAND 0 0.095] = ~s ~%"  (YRAND 0 0.095))
;  (format t "[YRAND 0 0.095] = ~s ~%"  (YRAND 0 0.095))

;  (format t "[YRAND 10 20] = ~s ~%"  (YRAND 10 20))
;  (format t "[YRAND 10 20] = ~s ~%"  (YRAND 10 20))

  (format t "~%")


)
;===============================================================================
;
; n   : ��e�-����e������
; m   : ������� ������e��� �� (n) ���e�e���� ��e����
; e   : ������ ������� ������e��� �� (m) ��������� �������
; nep : ��e� �e�������e��� ��� ������ (e) ������� 
; nsp : ��e� �e�������e��� ��� ������ (m-e) ��������� �������
; ngh : ��������� ����e� �������� (������� � ee ���e�������)
;
;-------------------------------------------------------------------------------
;
; 1) ������������ ��������� (n) ���������� �e�e�����
; 2) �������� ����e� ���������

; 3) e��� �e ������e� ����e��� �������� - ����������� ����� ���������
; 4) ������� ������� ��� ���e������ ������
; 5) �e����������� ��e� ��� ��������� ������� (�����e ��e� ��� ������ 
;    "e" �������) � ��������� ����e�� � ���� ��������
; 6) ������� ������ ��e�� � ������� �������
; 7) �������� ���������� ��e��� ��������� ����� � ������� �� ����e��
;
; 8) �e�e��� � 3)
;
;===============================================================================
