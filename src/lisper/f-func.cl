; -*-   mode: lisp ; coding: koi8   -*- ----------------------------------------

;-------------------------------------------------------------------------------
;;; e_func.cl
;;;=============================================================================

(defstruct TESTFUNC
    proc dim 
    xmin xmax
)

(defvar *tabl* '(
   (t4     . (make-TESTFUNC :proc 'proc_martin    :dim  2 :xmin  0.0  :xmax 10.0 )) 
   (t5     . (make-TESTFUNC :proc 'proc_rosenbrok :dim  2 :xmin -1.2  :xmax +1.2 )) 
   
   (t7_min . (make-TESTFUNC :proc 'proc_hsphere   :dim  5 :xmin -5.12 :xmax +5.12 ))
   (t7     . (make-TESTFUNC :proc 'proc_hsphere   :dim  6 :xmin -5.12 :xmax +5.12 ))
   
   (t8_min . (make-TESTFUNC :proc 'proc_griewangk :dim  5 :xmin -1.2  :xmax +1.2 ))
   (t8     . (make-TESTFUNC :proc 'proc_griewangk :dim 10 :xmin -512  :xmax +512 )) 
   ))

;-------------------------------------------------------------------------------
(defun get_testfunc (tabl name)  
(let (
 (fun (cdr (assoc name tabl))) 
 )

 (eval fun) 

))
;-------------------------------------------------------------------------------
;
;-------------------------------------------------------------------------------
(defun proc_martin (xi)
	                                     
(let (
  (x (nth 0 xi)) 
  (y (nth 1 xi)) 
  )

  (+ (expt (- x y) 2) (expt (/ (+ x y -10) 3) 2))

))
;-------------------------------------------------------------------------------
(defun proc_rosenbrok (xi)

(let (
  (x (nth 0 xi)) 
  (y (nth 1 xi)) 
  )

  (+ (* (expt (- (* x x) y) 2) 100) (expt (- 1 x) 2))

))
;-------------------------------------------------------------------------------
(defun proc_hsphere (xi)

(let (
  (dim (list-length xi))
  x 
  (f 0)
  )

  ;(setf dim (list-length xi))

  (dotimes (i dim)
    (setf x (nth i xi))
    (setf f (+ f (* x x)))
    )

  f
))
;-------------------------------------------------------------------------------
;/*  Сложная синусоида                                                         */
;-------------------------------------------------------------------------------
(defun proc_sinusoida (xi)

(let (
  ;(dim (list-length xi))
  x 
  (f 0)
  )

  (setf x (nth 0 xi))
  (setf f (* (sin x) x x))

  f
))
;-------------------------------------------------------------------------------
(defun proc_griewangk (xi)

(let (
  (dim (list-length xi))
  x f
  (sum 0)
  (mul 1)
  ;(F_max 0.0)
  )

  (dotimes (i dim)
    (setf x (nth i xi))
    (setf sum (+ sum (/ (* x x) 4000)))
    (setf mul (* mul (cos (/ x (sqrt (1+ i))))))
    )

  ;(setf f (+ 0.1 (- sum mul) 1))
  (setf f (+ 10 (- sum mul) 1))
  ;(setf f (+ F_max (- sum mul) 1))
  ;(- f)
))
;-------------------------------------------------------------------------------
(defun bees_peaks (xi)

(let (
  (x (nth 0 xi)) 
  (y (nth 1 xi)) 
  )

  (- (* 3
        (expt (- 1 x) 2)
        (exp (- (- (expt x 2))
                (expt (+ y 1) 2))))
     (* 10
        (- (/ x 5)
           (expt x 3)
           (expt y 5))
        (exp (- (- (expt x 2))
                (expt y 2))))
     (* (/ 1 3)
        (exp (- (- (expt (+ x 1) 2))
                (expt y 2)))))

))
;-------------------------------------------------------------------------------
; цeлeвая функция бeрeтся от одного аргумeнта - списка, это сильно упрощаeт
; рeализацию.
; рeзультат такой: peaks (0.22799665, -1.6253955) = -6.551133
;-------------------------------------------------------------------------------
;(defun peaks-1 (l)

;  (eval `(peaks ,@l)) ; список раскрываeтся и бeз скобок вставляeтся внутрь

;  ;; а нам бы надо бeз скобок, чтоб по индeксам можно было обращаться !
;)
;;;=============================================================================

;-------------------------------------------------------------------------------
;(defun optimum_print_x (genotype make_calc_xi data)

;(let ( 
;  (*print-pretty* t) ; здесь глобальная, меняется локально для этой функции

;  xi
;  )
 
;  (format t "PRINT_BEST_OPTIMUM: ~%")            
;  (format t "~%")

;  (setf xi (funcall  make_calc_xi genotype data))	                                     
;  (format t "X= ~A ~%" xi)
;  ;(format_bord75) ;===========================

;))
;===============================================================================


