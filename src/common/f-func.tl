# -*-   mode: tcl  ; coding: koi8   -*- ----------------------------------------

# ;=============================================================================
# ; e_func.cl
# ;=============================================================================

# (defstruct TESTFUNC
#     proc dim 
#     xmin xmax
# )

# (defvar *tabl* '(
#    (t4     . (make-TESTFUNC :proc 'proc_martin    :dim  2 :xmin  0.0  :xmax 10.0 )) 
#    (t5     . (make-TESTFUNC :proc 'proc_rosenbrok :dim  2 :xmin -1.2  :xmax +1.2 )) 
   
#    (t7_min . (make-TESTFUNC :proc 'proc_hsphere   :dim  5 :xmin -5.12 :xmax +5.12 ))
#    (t7     . (make-TESTFUNC :proc 'proc_hsphere   :dim  6 :xmin -5.12 :xmax +5.12 ))
   
#    (t8_min . (make-TESTFUNC :proc 'proc_griewangk :dim  5 :xmin -1.2  :xmax +1.2 ))
#    (t8     . (make-TESTFUNC :proc 'proc_griewangk :dim 10 :xmin -512  :xmax +512 )) 
#    ))

#-------------------------------------------------------------------------------
# (defun get_testfunc (tabl name)  
# (let (
#  (fun (cdr (assoc name tabl))) 
#  )

#  (eval fun) 

# ))
#-------------------------------------------------------------------------------
#
#-------------------------------------------------------------------------------
proc proc_martin {xi} {
	                                     
  # (let (
  set x [lindex $xi 0] 
  set y [lindex $xi 1] 
  #   )
  
  #   (+ (expt (- x y) 2) (expt (/ (+ x y -10) 3) 2))
  
  #return [expr pow( $x - $y, 2) + pow((($x + $y + -10) / 3), 2) ]

  #puts "proc_martin: x= $x  y= $y"

  set p1 [expr {$x - $y}]
  set p2 [expr {($x + $y + -10) / 3}]

  return [expr {$p1*$p1 + $p2*$p2}]

}
# ;-------------------------------------------------------------------------------
proc proc_rosenbrok {xi} {

  # (let (
  set x [lindex $xi 0] 
  set y [lindex $xi 1] 
  #   )
  
  set p1 [expr {$x * $x - $y}]
  set p2 [expr { 1 - $x}]

  #   (+ (* (expt (- (* x x) y) 2) 100) (expt (- 1 x) 2))
  
  return [expr {$p1*$p1*100 + $p2*$p2}]
}
# ;-------------------------------------------------------------------------------
proc proc_hsphere {xi} {

  #puts ""
  #puts "proc_hsphere : xi = $xi"
  #puts ""

  # (let (
  set dim [llength $xi]
  #   x 
  set f 0
  #   )
  
  #   ;(setf dim (list-length xi))
  
  dotimes  i $dim {

    set x [lindex $xi $i]
    set f [expr {$f + ($x * $x)}]
  }
  
  return $f
}
# ;-------------------------------------------------------------------------------
# ;/*  Сложная синусоида                                                         */
# ;-------------------------------------------------------------------------------
proc proc_sinusoida {xi} {

  # (let (
  #   ;(dim (list-length xi))
  #   x 
  set f 0
  #   )
  
  set x [lindex $xi 0]
  #   (setf f (* (sin x) x x))

  set f [expr {sin($x) * $x * $x}]
  
  return $f
}
# ;-------------------------------------------------------------------------------
# (defun proc_griewangk (xi)

# (let (
#   (dim (list-length xi))
#   x f
#   (sum 0)
#   (mul 1)
#   ;(F_max 0.0)
#   )

#   (dotimes (i dim)
#     (setf x (nth i xi))
#     (setf sum (+ sum (/ (* x x) 4000)))
#     (setf mul (* mul (cos (/ x (sqrt (1+ i))))))
#     )

#   ;(setf f (+ 0.1 (- sum mul) 1))
#   (setf f (+ 10 (- sum mul) 1))
#   ;(setf f (+ F_max (- sum mul) 1))
#   ;(- f)
# ))
# ;-------------------------------------------------------------------------------
# (defun bees_peaks (xi)

# (let (
#   (x (nth 0 xi)) 
#   (y (nth 1 xi)) 
#   )

#   (- (* 3
#         (expt (- 1 x) 2)
#         (exp (- (- (expt x 2))
#                 (expt (+ y 1) 2))))
#      (* 10
#         (- (/ x 5)
#            (expt x 3)
#            (expt y 5))
#         (exp (- (- (expt x 2))
#                 (expt y 2))))
#      (* (/ 1 3)
#         (exp (- (- (expt (+ x 1) 2))
#                 (expt y 2)))))

# ))
# ;-------------------------------------------------------------------------------
# ; цeлeвая функция бeрeтся от одного аргумeнта - списка, это сильно упрощаeт
# ; рeализацию.
# ; рeзультат такой: peaks (0.22799665, -1.6253955) = -6.551133
# ;-------------------------------------------------------------------------------
# ;(defun peaks-1 (l)

# ;  (eval `(peaks ,@l)) ; список раскрываeтся и бeз скобок вставляeтся внутрь

# ;  ;; а нам бы надо бeз скобок, чтоб по индeксам можно было обращаться !
# ;)
# ;;;=============================================================================

# ;-------------------------------------------------------------------------------
# ;(defun optimum_print_x (genotype make_calc_xi data)

# ;(let ( 
# ;  (*print-pretty* t) ; здесь глобальная, меняется локально для этой функции

# ;  xi
# ;  )
 
# ;  (format t "PRINT_BEST_OPTIMUM: ~%")            
# ;  (format t "~%")

# ;  (setf xi (funcall  make_calc_xi genotype data))	                                     
# ;  (format t "X= ~A ~%" xi)
# ;  ;(format_bord75) ;===========================

# ;))
# ;===============================================================================


