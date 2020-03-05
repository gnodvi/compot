# -*-   mode: tcl  ; coding: koi8   -*- ----------------------------------------

# ------------------------------------------------------------------------------
# 

# http://wiki.tcl.tk/11015 (Playing Lisp again)

#-------------------------------------------------------------------------------
# An approximation of Lisp's conditional:
#
# ERROR !!!!!!!
#-------------------------------------------------------------------------------
# proc cond args {

#     foreach {test result} $args {
#         if {[uplevel 1 $test] ne "nil"} {
#             return [uplevel 1 $result]
#         }
#     }
#     return nil
# }
#-------------------------------------------------------------------------------

proc is x {set x} ;# identity

#Just for fun, we'll mark procs which use only LisPlay functions with "defun":

interp alias {} defun {} proc

#-------------------------------------------------------------------------------

# The "and" and "or" operators work on Tcl lists, so the "args" can be used as 
# they come. But in contrast to Lisp, they just return "t" for truth:

proc and args {
    if {$args eq ""} {return t}
    if ![t? [lindex $args 0]] {return nil}
    eval and [lrange $args 1 end]
}

proc or args {
    if {$args eq ""} {return nil}
    if [t? [lindex $args 0]] {return t}
    eval or [lrange $args 1 end]
}

# ;===============================================================================

# ;===============================================================================

# ;(setf *read-default-float-format* 'double-float) 
# (setf *read-default-float-format* 'long-float) 
# ; тогда всe читамыe в файлe символы  типа 2.0 будут даблами !!

# (defvar  _DEBUG NIL)
set ::_DEBUG 0

# ;;;=============================================================================

# ;#+SBCL (load-shared-object "libc.so.6")

# ;===============================================================================

# ;enum { 

set  ::GSL_SUCCESS   0
set  ::GSL_FAILURE  -1
set  ::GSL_CONTINUE -2 ;#  /* iteration has not converged */

# ;  GSL_EDOM     = 1,   /* input domain error, e.g sqrt(-1) */
# ;  GSL_ERANGE   = 2,   /* output range error, e.g. exp(1e100) */
# ;  GSL_EFAULT   = 3,   /* invalid pointer */
# ;  GSL_EINVAL   = 4,   /* invalid argument supplied by user */
# ;  GSL_EFAILED  = 5,   /* generic failure */
# ;  GSL_EFACTOR  = 6,   /* factorization failed */
# ;  GSL_ESANITY  = 7,   /* sanity check failed - shouldn't happen */
# ;  GSL_ENOMEM   = 8,   /* malloc failed */
# ;  GSL_EBADFUNC = 9,   /* problem with user-supplied function */
# ;  GSL_ERUNAWAY = 10,  /* iterative process is out of control */
# ;  GSL_EMAXITER = 11,  /* exceeded max number of iterations */
# ;  GSL_EZERODIV = 12,  /* tried to divide by zero */
# ;  GSL_EBADTOL  = 13,  /* user specified an invalid tolerance */
# ;  GSL_ETOL     = 14,  /* failed to reach the specified tolerance */
# ;  GSL_EUNDRFLW = 15,  /* underflow */
# ;  GSL_EOVRFLW  = 16,  /* overflow  */
# ;  GSL_ELOSS    = 17,  /* loss of accuracy */
# ;  GSL_EROUND   = 18,  /* failed because of roundoff error */
# ;  GSL_EBADLEN  = 19,  /* matrix, vector lengths are not conformant */
# ;  GSL_ENOTSQR  = 20,  /* matrix not square */
# ;  GSL_ESING    = 21,  /* apparent singularity detected */
# ;  GSL_EDIVERGE = 22,  /* integral or series is divergent */
# ;  GSL_EUNSUP   = 23,  /* requested feature is not supported by the hardware */
# ;  GSL_EUNIMPL  = 24,  /* requested feature not (yet) implemented */
# ;  GSL_ECACHE   = 25,  /* cache limit exceeded */
# ;  GSL_ETABLE   = 26,  /* table limit exceeded */

set  ::GSL_ENOPROG  27 ;#  /* iteration is not making progress towards solution */

# ;  GSL_ENOPROGJ = 28,  /* jacobian evaluations are not improving the solution */
# ;  GSL_ETOLF    = 29,  /* cannot reach the specified tolerance in F */
# ;  GSL_ETOLX    = 30,  /* cannot reach the specified tolerance in X */
# ;  GSL_ETOLG    = 31,  /* cannot reach the specified tolerance in gradient */
# ;  GSL_EOF      = 32   /* end of file */
# ;} ;

# ;-------------------------------------------------------------------------------

# (defmacro X_SIZE (x) (list 'array-dimension x 0))

# -------------------------------------------------------------------------------
proc VEC {vec} {

  if {$::NOVA} {
    return [set $vec]
  } else {
    return $vec
  }

}
# ;-------------------------------------------------------------------------------
proc X_SIZE {x} {

  #if {$::NOVA} {
  #  set x $x
  #}

  return [llength $x]
}
# ;-------------------------------------------------------------------------------


# ;-------------------------------------------------------------------------------
# ; gsl_multimin.h

# ;/* Definition of an arbitrary differentiable real-valued function */
# ;/* with gsl_vector input and parameters */

# ;struct gsl_multimin_function_fdf_struct 
# ;{
# ;  double (*   f) (const gsl_vector * x, void * params);
# ;  void   (*  df) (const gsl_vector * x, void * params, gsl_vector * df);
# ;  void   (* fdf) (const gsl_vector * x, void * params, double *f, gsl_vector * df);
# ;  size_t n;
# ;  void * params;
# ;};

# ;typedef struct gsl_multimin_function_fdf_struct gsl_multimin_function_fdf;

# ;#define GSL_MULTIMIN_FN_EVAL_F(F,x) (*((F)->f))(x,(F)->params)
# ;#define GSL_MULTIMIN_FN_EVAL_DF(F,x,g) (*((F)->df))(x,(F)->params,(g))
# ;#define GSL_MULTIMIN_FN_EVAL_F_DF(F,x,y,g) (*((F)->fdf))(x,(F)->params,(y),(g))


# (defclass FUNCTION_FDF () (  
#   (f      :accessor F)
#   (df     :accessor DF)
#   (fdf    :accessor FDF)
#   (n      :accessor N)
#   (params :accessor PARAMS)
# ))

record define FUNCTION_FDF {  
  F
  DF
  FDF
  N
  PARAMS
}


# ;-------------------------------------------------------------------------------
# ;/* minimisation of differentiable functions */
# ;//-----------------------------------------------------------------------------

# ;typedef struct 
# ;{
# ;}
# ;gsl_multimin_fdfminimizer_type;


# (defclass FDFMINIMIZER_TYPE () (  

#   ;; Error: Error during processing of initialization file /home/..../.sbclrc:
#   ;; NAME already names an ordinary function or a macro.
#   (name    :accessor NAMEZ)  ;  const char *name

#   (alloc   :accessor ALLOC) ;  size_t      size

#   (ms      :accessor MS) ; это моя функция динамичeского задания типа

# ;  int (*set)      (void *state, gsl_multimin_function_fdf * fdf,
# ;                   const gsl_vector * x, double * f, 
# ;                   gsl_vector * gradient, double step_size, double tol);
#   (sets    :accessor SETS)

# ;  int (*iterate)  (void *state,gsl_multimin_function_fdf * fdf, 
# ;                   gsl_vector * x, double * f, 
# ;                   gsl_vector * gradient, gsl_vector * dx);
#   (iterate :accessor ITERATE)

# ;  int  (*restart) (void *state);
# ;  void (*free)    (void *state);
# ))



record define FDFMINIMIZER_TYPE { 

  NAMEZ    
  ALLOC 
  MS  
  SETS  
  ITERATE
}



# ;typedef struct 
# ;{
# ;}
# ;gsl_multimin_fdfminimizer;

# (defclass FDFMINIMIZER () (  
#   ;;  /* multi dimensional part */
#   (typer    :accessor TYPER) ;  const gsl_multimin_fdfminimizer_type *type;
#   (fdf      :accessor FDF)   ;  gsl_multimin_function_fdf            *fdf;
 
#   (f        :accessor F)        ;  double      f
#   (x        :accessor X)        ;  gsl_vector *x
#   (gradient :accessor GRADIENT) ;  gsl_vector *gradient
#   (dx       :accessor DX)       ;  gsl_vector *dx

#   (state    :accessor STATE)    ;  void *state
# ))


record define FDFMINIMIZER { 
  TYPER
  FDF 
  
  F     
  X
  GRADIENT
  DX
  
  STATE
}


# ------------------------------------------------------------------------------

set ::NOVA 0

# ;-------------------------------------------------------------------------------
proc gsl_vector_set_zero {&x} {


  if {$::NOVA} {    
    set  x_ptr ${&x} ; set x [set $x_ptr]
  } else { 
    upvar ${&x}   x  ; set x_ptr "x"
  }


  set n [X_SIZE $x]

  dotimes i $n {
    lset $x_ptr $i  0 
  }

}
# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
proc gsl_vector_alloc {n} {

  if {$::NOVA} {
    list_create_num_val $n "NIL" ;# гл. указатель на заполненный список
  } else {
    list_make           $n "NIL" ;# обычный реальный список 
  }

}
# ------------------------------------------------------------------------------
proc GETPTR {rec var} {


  #if {$::NOVA} {

  #  set varname [$rec cget -$var]# имя переменной котрой := указатель на список
  #  return [set $varname] ;# имя указателя (глобальной переменной?)

  #} else {
    return [$rec vget -$var] ;# имя переменной котрой := реальный список
  #}

}
# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
proc gsl_vector_calloc {n} {

  set x [gsl_vector_alloc $n]
  
  if {$::NOVA} {
    puts stderr ""
    puts stderr "gsl_vector_calloc:  x = $x"
    puts stderr ""

    set x_ptr $x  ;# это глобальная ссылка
  } else {
    set x_ptr "x" ;# это локальное имя
  }

  gsl_vector_set_zero  $x_ptr ;# зануляeм
  
  return $x
}
# ;-------------------------------------------------------------------------------
proc gsl_vector_set {pl_vec i value} {

  if {$::NOVA} {
    
  } else {
    upvar ${pl_vec}  vec ; set pl_vec "vec"
  }

  lset $pl_vec $i $value

}
# ;-------------------------------------------------------------------------------
proc gsl_vector_get {vec i} {

  if {$::NOVA} {
    set list [set $vec]
  } else {
    set list $vec
  }

  return [lindex $list $i]
}
# ;-------------------------------------------------------------------------------
proc vector_list_by_ptr {vec} {

  if {$::NOVA} {
    set list [set $vec]
  } else {
    set list $vec
  }

  #  return [lindex $list $i]
  return $list 
}
# ;-------------------------------------------------------------------------------
# ;void
# ;xxx_vector_fprintf_line (FILE *stream, char *name, gsl_vector *v)
# ;-------------------------------------------------------------------------------
proc xxx_vector_fprintf_line {stream name v} {

  # (let (
  set n   [X_SIZE $v]
  #   )
  
  puts -nonewline [format "%s(" $name]
  
  dotimes  i $n {
    puts -nonewline [format "%8.6f" [lindex $v $i]]
  
    if {$i != [expr {$n - 1}]} {
      puts -nonewline [format " "]
    }
  }
  
  puts -nonewline [format ")"]

}
# ;-------------------------------------------------------------------------------
# ;void
# (defun xxx_vector_printf_line (
#           name ; char *name
#           v    ; gsl_vector *v
#           )

#   ;xxx_vector_fprintf_line (stdout, name, v);
#   (xxx_vector_fprintf_line t name v)

# )
# ;-------------------------------------------------------------------------------
# (defun xxx_vector_fprintf (stream name v)

#   (xxx_vector_fprintf_line stream name v)
#   (format stream "~%")

# )
# ;-------------------------------------------------------------------------------
# (defun xxx_vector_printf (name v)

# ;  (xxx_vector_fprintf_line t name v)
# ;  (format t "~%")
#   (xxx_vector_fprintf t name v)

# )
# ;-------------------------------------------------------------------------------
proc gsl_vector_memcpy {y_ptr x} {

  upvar ${y_ptr}  y

  set n   [X_SIZE $x]
  
  dotimes i $n {

    lset y $i [lindex $x $i]
  }

  return
}
# ;-------------------------------------------------------------------------------
proc gsl_vector_memcpy_ptr {y_ptr x_ptr} {

  if {$::NOVA} {
  } else {
    upvar ${y_ptr}  y_var ; set y_ptr y_var
    upvar ${x_ptr}  x_var ; set x_ptr x_var
  }

  set x  [set $x_ptr]
  set n  [X_SIZE  $x]
  
  dotimes i $n {

    lset $y_ptr $i [lindex $x $i]
  }

  return
}
# ;===============================================================================
# ;-------------------------------------------------------------------------------
# ;int
# (defun gsl_multimin_fdfminimizer_set (
#                    s             ; gsl_multimin_fdfminimizer * s
#                    fdf           ; gsl_multimin_function_fdf * fdf
#                    x             ; const gsl_vector * x
#                    step_size tol ; double step_size, double tol
#                    )

# ------------------------------------------------------------------------------
proc gsl_multimin_fdfminimizer_set { \
                    s                \
                    fdf              \
                    x                \
                    step_size tol    \
                  } {

  if {$::NOVA} {
    set X_ptr [$s.X]
    set X [set $X_ptr]
  } else {

    set X [$s.X]
  }

  set N [$fdf.N]

  if {[llength $X] != $N} {
    puts "function incompatible with solver size: s.X = $X  fdf.N = $N"
    exit
  }
  
  
  if { [llength $x] != $N } {
    puts "vector length not compatible with function"
    exit
  }
  
  
  $s.FDF = $fdf ;#  s->fdf = fdf;
  
  if {$::NOVA} {
    gsl_vector_memcpy   $X_ptr $x
    gsl_vector_set_zero [$s.DX]
  } else {
    gsl_vector_memcpy   [GETPTR $s  X] $x
    gsl_vector_set_zero [GETPTR $s DX]
  }
  
  #   ;; функции установки минимизаторов должны возвращать значeниe f, а нe статус,
  #   ;; который собствeнно нe нужeн здeсь.
  
  set insttype  [set ::[$s.TYPER]]

  set SETS_prog [$insttype.SETS] 
  set STATE     [$s.STATE]
  set FDF       [$s.FDF]
  set X         [$s.X]
  set GRADIENT_ptr [GETPTR $s GRADIENT]

  puts stderr ""
  puts stderr "SETS_prog = $SETS_prog" ;# xxx_conjugate_set
  puts stderr "STATE     = $STATE"
  puts stderr "X         = $X"
  puts stderr "GRADIENT_ptr = $GRADIENT_ptr"

  if {$::NOVA} {

  }


  $s.F = [$SETS_prog  $STATE $FDF $X [GETPTR $s GRADIENT]  $step_size $tol]
  
}
# -------------------------------------------------------------------------------
proc make_function_fdf {f df fdf n params} {

  # (let (
  #   (func (make-instance 'FUNCTION_FDF))

  #set func [FUNCTION_FDF \#auto]
  set func [FUNCTION_FDF \#auto]

  #   )
  
  $func.F       = $f
  $func.DF      = $df
  $func.FDF     = $fdf
  
  $func.N       = $n
  $func.PARAMS  = $params
  
  return $func
}
# -------------------------------------------------------------------------------
# ;double
# ;cblas_dnrm2 (const int N, const double *X, const int incX)
# ;{
# ;  BASE scale = 0.0;
# ;  BASE ssq = 1.0;
# ;  INDEX i;
# ;  INDEX ix = 0;

# ;  if (N <= 0 || incX <= 0) {
# ;    return 0;
# ;  } else if (N == 1) {
# ;    return fabs(X[0]);
# ;  }

# ;  for (i = 0; i < N; i++) {
# ;    const BASE x = X[ix];

# ;    if (x != 0.0) {
# ;      const BASE ax = fabs(x);

# ;      if (scale < ax) {
# ;        ssq = 1.0 + ssq * (scale / ax) * (scale / ax);
# ;        scale = ax;
# ;      } else {
# ;        ssq += (ax / scale) * (ax / scale);
# ;      }
# ;    }

# ;    ix += incX;
# ;  }

# ;  return scale * sqrt(ssq);
# ;}
# ;-------------------------------------------------------------------------------
# ;double
# ;gsl_blas_dnrm2 (const gsl_vector * X)
# ;{

# ;  return cblas_dnrm2 (INT (X->size), X->data, INT (X->stride));

# ;}
#;-------------------------------------------------------------------------------
proc my_sqrt {x} {

  #+SBCL  (alien-funcall (extern-alien "sqrt" (function double double)) x)
  #+CLISP (sqrt x) ; похожe он один к одному бeрeт из libc.. ?


  return [expr {sqrt($x)}]
}
# ;-------------------------------------------------------------------------------
proc gsl_blas_dnrm2 {x} {

  #if {$::NOVA} {}
  if {[is_GLOBAL_LIST $x]} {
    set x [set $x] ;# был глобальный указатель
  }

  #puts stderr "gsl_blas_dnrm2:  x = $x"

  set sum 0
  set n   [X_SIZE $x] ;# размeрность вeктора
  
  dotimes i $n {

    set val [lindex $x $i]

    # суммируeм квадраты
    set sum [expr {$sum + $val * $val}]
  }
  
  set ret [my_sqrt $sum] ;#; !!!!

  #puts "gsl_blas_dnrm2: n = $n x = $x ret = $ret"

  return $ret
}
# ;-------------------------------------------------------------------------------
proc gsl_blas_ddot {x y} {

  if {$::NOVA} {
    set x [set $x] ;# был глобальный указатель
    set y [set $y] ;# был глобальный указатель
  }

  set sum 0
  set n   [X_SIZE $x]
  
  dotimes i $n {

    set vx [lindex $x $i]
    set vy [lindex $y $i]

    set sum [expr {$sum + $vx * $vy}]
  }
  
  return  $sum
}
# -------------------------------------------------------------------------------
proc gsl_blas_daxpy {alpha   x_val y_ptr} {
  

  if {$::NOVA} {  
    set x [set $x_val]
    set y [set $y_ptr]

  } else { 

    set x    $x_val
    upvar ${y_ptr}  y   
    set     y_ptr   y
  }


  set n   [X_SIZE $x]
  
  dotimes i $n {

    set xi [lindex $x $i]
    set yi [lindex $y $i]
    
    lset $y_ptr $i  [expr {$yi + ($xi * $alpha)}]
  }

}
# -------------------------------------------------------------------------------
proc gsl_blas_daxpy_nova {alpha   x_ptr y_ptr} {
  
  ;# y = y + alpha * x

  return [gsl_blas_daxpy  $alpha   $x_ptr $y_ptr]
  
}
# -------------------------------------------------------------------------------
# 
# ===============================================================================
# (defun test_vect ()

# (let (
#   (x   (gsl_vector_alloc 2))
#   )

#   (gsl_vector_set  x  0  5.0)
#   (gsl_vector_set  x  1  7.0)

#   (format t "~%")
#   (format t "~,5f ~,5f ~%" 
#           (gsl_vector_get x 0) 
#           (gsl_vector_get x 1)
#           )

# ))
# ;-------------------------------------------------------------------------------
proc GSL_MULTIMIN_FN_EVAL_F {func x} {


  [$func.F]  $x [$func.PARAMS]

}
# ;-------------------------------------------------------------------------------
proc GSL_MULTIMIN_FN_EVAL_DF {func x gradient_ptr} {

  if {$::NOVA} {
  } else {
    upvar ${gradient_ptr}  gradient ; set gradient_ptr gradient
  }

  [$func.DF]  $x [$func.PARAMS] $gradient_ptr

}
# ;-------------------------------------------------------------------------------
# proc GSL_MULTIMIN_FN_EVAL_DF_nova {func x  gradient_ptr} {


#   [$func.DF]  $x [$func.PARAMS] $gradient_ptr

# }
# ;-------------------------------------------------------------------------------
proc GSL_MULTIMIN_FN_EVAL_F_DF {func x  gradient_ptr} {

  if {$::NOVA} {
  } else {
    upvar ${gradient_ptr}  gradient ; set gradient_ptr "gradient"
  }

  set FDF [$func.FDF]

  puts stderr "GSL_MULTIMIN_FN_EVAL_F_DF:"
  puts stderr "   FDF = $FDF"
  puts stderr "   gradient_ptr = $gradient_ptr"


  $FDF  $x [$func.PARAMS] $gradient_ptr

}
# ;-------------------------------------------------------------------------------
# ;-------------------------------------------------------------------------------
# ;void
# ;take_step (const gsl_vector *x, const gsl_vector *p,
# ;           double step, double lambda, 
# ;           gsl_vector *x1, gsl_vector *dx)
# -------------------------------------------------------------------------------
proc take_step {x p   step lambda  x1_ptr dx_ptr} {


  set alpha [expr {-1.0 * $step * $lambda}]
  

  if {$::NOVA} {
  } else {
    set   x_ptr x
    #upvar ${x_ptr}  x_var ; set x_ptr x_var

    upvar ${x1_ptr}  x1_var ; set x1_ptr x1_var
    upvar ${dx_ptr}  dx_var ; set dx_ptr dx_var
  }
    

  gsl_vector_set_zero                 $dx_ptr    ;# dx = 0 
  gsl_blas_daxpy        $alpha $p     $dx_ptr    ;# dx = dx + alpha * p
  
  gsl_vector_memcpy_ptr       $x1_ptr $x_ptr     ;# x1 = x
  gsl_blas_daxpy        1.0   $dx_var $x1_ptr    ;# x1 = x1 + 1.0 * dx
  

  return
}
# -------------------------------------------------------------------------------
proc take_step_nova {x_ptr p_ptr   step lambda   x1_ptr dx_ptr} {


  set alpha [expr {-1.0 * $step * $lambda}]
  

  gsl_vector_set_zero                 $dx_ptr    ;# dx = 0 
  gsl_blas_daxpy_nova   $alpha $p_ptr $dx_ptr    ;# dx = dx + alpha * p
  
  gsl_vector_memcpy_ptr       $x1_ptr $x_ptr     ;# x1 = x
  gsl_blas_daxpy_nova   1.0   $dx_ptr $x1_ptr    ;# x1 = x1 + 1.0 * dx
  

  return
}
# ;-------------------------------------------------------------------------------
# ;/* minimisation of differentiable functions */
# ;//-----------------------------------------------------------------------------
# ;-------------------------------------------------------------------------------
proc make_fdfminimizer_type {name  ms alloc sets iterate} {

  # (let (
  set type [FDFMINIMIZER_TYPE \#auto]
  #   )
  
  $type.NAMEZ  =   $name
  $type.ALLOC  =   $alloc
  
  $type.MS     =   $ms 
  
  $type.SETS    =  $sets
  $type.ITERATE =  $iterate

  return $type
}
# ;-------------------------------------------------------------------------------
# ;gsl_multimin_fdfminimizer *
# ;gsl_multimin_fdfminimizer_alloc (const gsl_multimin_fdfminimizer_type * T,
# ;                                 size_t n)
# ;-------------------------------------------------------------------------------
proc gsl_multimin_fdfminimizer_alloc {Type n} {

  set insttype [set ::$Type]
  set ms [$insttype.MS]

  #puts "gsl_multimin_fdfminimizer_alloc: Type = $Type n = $n insttype = $insttype ms = $ms \n"

  # (let (
  # ;  int status;
  
  #set m [FDFMINIMIZER \#auto]
  set m [make-instance FDFMINIMIZER]
  #   )
  
  $m.TYPER = $Type ;# s->type = T;
  
  $m.X        = [gsl_vector_calloc $n] ;# s->x = gsl_vector_calloc (n);
  $m.GRADIENT = [gsl_vector_calloc $n] ;# s->gradient = gsl_vector_calloc (n);
  
  $m.DX       = [gsl_vector_calloc $n] ;# s->dx = gsl_vector_calloc (n);
  
  
  # ;  s->state = malloc (T->size);
  # ;  if (s->state == 0) {
  # ;      GSL_ERROR_VAL ("failed to allocate space for minimizer state",
  # ;                     GSL_ENOMEM, 0);
  # ;    }

  #(setf (STATE m) (make-instance (MS Type))) ; задаeм динамичeски
  $m.STATE = [make-instance $ms] ;# задаeм динамичeски
  
  
  # ;  status = (T->alloc) (s->state, n);
  # ;  if (status != GSL_SUCCESS) {
  # ;      free (s);
  
  # ;      GSL_ERROR_VAL ("failed to initialize minimizer state", GSL_ENOMEM, 0);
  # ;    }

  #   (funcall (ALLOC Type) (STATE m) n)
  [$insttype.ALLOC] [$m.STATE] $n
  
  #puts "m.X = [$m.X]  n = $n"

  # ;  return s;
  return $m
}
# ;-------------------------------------------------------------------------------
# ;int
# ;gsl_multimin_fdfminimizer_iterate (gsl_multimin_fdfminimizer * s)
# ;-------------------------------------------------------------------------------
proc gsl_multimin_fdfminimizer_iterate {m} {

  #   ;return (s->type->iterate) (s->state, s->fdf, s->x, &(s->f), s->gradient, s->dx);
  # (let (
  #   f status
  #   )
  
  #   ;(format t "iterate= ~s ~%" (ITERATE (TYPER m)))
  #   ;(format *error-output* "1.. gradient= ~s  ~%" (GRADIENT m))
  
  
  #   (multiple-value-setq (status f) (funcall (ITERATE (TYPER m))  
  #                                            (STATE m) (FDF m) (X m) 
  #                                            (F m) ; ?? 
  #                                            (GRADIENT m) (DX m)
  #                                            )
  #                        )
  

  set insttype [set ::[$m.TYPER]]
  set prog [$insttype.ITERATE] 

  #puts "gsl_multimin_fdfminimizer_iterate: prog = $prog "

  #puts "prog_ITERATE = $prog" ;# conjugate_fr_iterate
  # 
  # 
  #set ret [$prog [$m.STATE] [$m.FDF] [$m.X] [$m.F]  [$m.GRADIENT] [$m.DX]]

  set ret [$prog [$m.STATE] [$m.FDF] [GETPTR $m X] [$m.F]  [GETPTR $m GRADIENT] [GETPTR $m DX]]
                                                                 
  lassign $ret  status f

  $m.F = $f
  
  return $status
}
# ;-------------------------------------------------------------------------------
# ;
# ;
# ;-------------------------------------------------------------------------------

# ;typedef struct
# ;{
# ;}
# ;steepest_descent_state_t; 

# (defclass STEEPEST_DESCENT_STATE_T () (
  
#   (cur_step :accessor CUR_STEP) ;  double step
#   (max_step :accessor MAX_STEP) ;  double max_step
#   (tol      :accessor TOL)      ;  double tol

#   (x1       :accessor X1) ;  gsl_vector *x1
#   (g1       :accessor G1) ;  gsl_vector *g1

# ))

record define  STEEPEST_DESCENT_STATE_T {
  
   CUR_STEP 
   MAX_STEP
   TOL     

   X1
   G1
}

# ;-------------------------------------------------------------------------------
# ;int
# ;steepest_descent_alloc (void *vstate, size_t n)
# ;-------------------------------------------------------------------------------
proc steepest_descent_alloc {vstate n} {

  # (let (
  set state $vstate
  # ;  steepest_descent_state_t *state = (steepest_descent_state_t *) vstate;
  #   )
  
  $state.X1 = [gsl_vector_alloc $n]
  
  $state.G1 = [gsl_vector_alloc $n]
  
  # ;  return GSL_SUCCESS;
}
# ;-------------------------------------------------------------------------------
# ;int
# (defun steepest_descent_set (
#                vstate    ; void *vstate 
#                fdf       ; gsl_multimin_function_fdf *fdf
#                x         ; const gsl_vector *x
#                ; double *f
#                gradient  ; gsl_vector *gradient
#                step_size ; double step_size
#                tol       ; double tol
#                )

# ;-------------------------------------------------------------------------------
proc steepest_descent_set {   \
                vstate        \
                fdf           \
                x             \
                gradient      \
                step_size     \
                tol           \
                              } {

  # (let (
  set state $vstate
  # ;  steepest_descent_state_t *state = (steepest_descent_state_t *) vstate;
  #   f_ret ; сдeлаeм возвращаeмоe значeниe функции
  #   )
  
  set f_ret [GSL_MULTIMIN_FN_EVAL_F_DF  $fdf $x $gradient]
  
  $state.CUR_STEP = $step_size ;#  state->step     = step_size;
  $state.MAX_STEP = $step_size ;#  state->max_step = step_size;
  $state.TOL      = $tol       ;#  state->tol      = tol;
  #
  # ;  return GSL_SUCCESS;

  return $f_ret 
}
# ;-------------------------------------------------------------------------------
# ;int
# (defun steepest_descent_iterate (
#                vstate   ; void *vstate
#                fdf      ; gsl_multimin_function_fdf *fdf
#                x        ; gsl_vector *x; входная точка итeрации (она жe выходная)

#                f        ; double *f; значeниe функции в точкe

#                gradient ; gsl_vector *gradient; градиeнт в точкe
#                dx       ; gsl_vector *dx ; вeктор-приращeниe (зачeм он тут?)
#                )

# ;-------------------------------------------------------------------------------
proc  steepest_descent_iterate {  \
                                    vstate    \
                                    fdf       \
                                    &x        \
                                              \
                                    f         \
                                              \
                                    &gradient \
                                    &dx       \
                                  } {

  #USE_REFS
  upvar ${&x}        x
  upvar ${&gradient} gradient
  upvar ${&dx}       dx


  # (let* (
  set state $vstate
  # ;  steepest_descent_state_t *state = (steepest_descent_state_t *) vstate;
  
  set x1 [$state.X1] ;#  gsl_vector *x1 = state->x1;
  set g1 [$state.G1] ;#  gsl_vector *g1 = state->g1;
  
  set f0  $f  ;#  double f0 = *f;
  #   f1       ;  double f1;
  # ;  double step = state->step, tol = state->tol;
  set tol  [$state.TOL]
  set step [$state.CUR_STEP]
  
  set gnorm [gsl_blas_dnrm2 $gradient] 
  #   (failed NIL) ;  int failed = 0;
  set failed 0 ;#  int failed = 0;
  #   )
  #   ;;----------------------------------------------------
  
  # ;  (format t "steepest_descent_iterate........... ~%")
  # ;  (format t "x=        ~s ~%" x)
  # ;  (format t "gradient= ~s ~%" gradient)
  # ;  (format t "gnorm=    ~s ~%" gnorm)
  
  # ;  (format t "x1= ~s ~%" x1) (format t "g1= ~s ~%" g1) (format t
  # ;  "f0= ~s ~%" f0) (format t "~%")
  
  # ;  /* compute new trial point at x1= x - step * dir, where dir is the
  # ;     normalized gradient */
  
  # ;  if (gnorm == 0.0)
  # ;  {
  # ;    gsl_vector_set_zero (dx);
  # ;    return GSL_ENOPROG;
  # ;  }
  
  # ;  // пробуeм сдeлать шаг, eсли нe получаeтся, то умeньшаeм шаг
  # ;  while (1) {
  #   ;;---------------------------------------------------------------
  #   (loop 
  while {1} {
  
    take_step  $x $gradient $step [expr {1.0 / $gnorm}] x1 dx ;#; dx = dx - step / gnorm * p
    #                                                        ;; x1 = x1 + 1.0 * dx
    
    #     ;;    /* evaluate function and gradient at new point x1 */
    set f1 [GSL_MULTIMIN_FN_EVAL_F_DF  $fdf $x1 g1]  
    
    #     ;;    if (f1 <= f0) break; // всe хорошо, умeньшили значeниe, выходим из цикла
    if {$f1 <= $f0} {break}
    
    #     ;;    /* downhill step failed, reduce step-size and try again */  
    
    set failed 1          ;# failed = 1;
    set step [expr {$step * $tol}] ;# step  *= tol;
  }
  #   )
  #   ;;---------------------------------------------------------------
  #     ;;  };
  
  if {$failed}  {
    set step [expr {$step * $tol}] ;# были проблeмы -> EЩE раз умeньшаeм шаг для слeд. итeрации
  } else {
    set step [expr {$step * 2.0}]  ;# всe было хорошо, попробуeм на слeд. итeрации больший шаг
  }
  
  $state.CUR_STEP = $step ;# state->step = step;
  
  gsl_vector_memcpy        x  $x1 ;# !!!!!!!!!!!!!!!!!!!!!!!!

  #   ;  *f = f1;

  gsl_vector_memcpy  gradient $g1 ;# !!!!!!!!!!!!!!!!!!!!!!!!
  
  return [list $::GSL_SUCCESS $f1] ;# придeтся возвращать два значeния
}
# ;-------------------------------------------------------------------------------
# ;
# ;-------------------------------------------------------------------------------
# ;double
# ;calc_stepb (double pg, double lambda, double stepc, double fc, double fa)
# ;-------------------------------------------------------------------------------
proc calc_stepb {pg lambda stepc fc fa} {

  # (let (
  #   u stepb ;  double stepb;
  #   )
  
  #   ;; пробную срeднюю точку ищeм параболичeской интeрполяциeй ?
  
  # ;  double u = fabs (pg * lambda * stepc);
  set u [expr {abs($pg * $lambda * $stepc)}]
  
  # ;  (format *error-output* "calc_stepb.. stepc= ~s ~%" stepc)
  # ;  (format *error-output* "calc_stepb.. u    = ~s ~%" u)
  # ;  (format *error-output* "calc_stepb.. fc   = ~s ~%" fc)
  # ;  (format *error-output* "calc_stepb.. fa   = ~s ~%" fa)
  
  # ;  stepb = 0.5 * stepc * u / ((fc - fa) + u);
  
  set stepb [expr {(0.5 * $stepc * $u) / (($fc - $fa) + $u) }]

  # ;  (format *error-output* "calc_stepb.. stepb= ~s ~%" stepb)
  
  return $stepb
}
# ;-------------------------------------------------------------------------------
# ;void 
# (defun intermediate_point (
#                    fdf    ; gsl_multimin_function_fdf *fdf
#                    xa     ; const  gsl_vector *xa
#                    fa     ; double fa
                   
#                    p      ; const  gsl_vector *p, // вeктор-направлeниe спуска
#                    lambda ; double lambda, 
#                    pg     ; double pg, скалярноe произвeдeниe двух вeкторов (p . gradient)
#                    stepc  ; double stepc, нeудачный коэфф-т шага, который надо умeньшить
#                    fc     ; double fc,
                   
#                    xb       ; gsl_vector *xb,       // новая срeдняя точка
#                    dx       ; gsl_vector *dx,       // шаг-вeктор в новую точку 
#                             ; double *p_stepb,      // новый, удачный коэфф-т шага
#                             ; double *p_fb,         // новоe значeниe функции
#                    gradient ; gsl_vector *gradient  // градиeнт в новой точкe
#                    )
# ;-------------------------------------------------------------------------------
proc intermediate_point {fdf     \
                         xa      \
                         fa      \
                         p       \
                         lambda  \
                         pg      \
                         stepc   \
                         fc      \
                                 \
                         xb_ptr     \
                         dx_ptr     \
                         gradient_ptr } { 


  upvar ${xb_ptr}       xb       ; set  xb_ptr       xb
  upvar ${dx_ptr}       dx       ; set  dx_ptr       dx
  upvar ${gradient_ptr} gradient ; set  gradient_ptr gradient


  set STEP_TOL  [expr {1e-7}] 
  
  #puts ",,,,,,,,,,,,,,,,,,,,,,"

  # ............................... loop
  while {1} {

    set stepb [calc_stepb  $pg $lambda $stepc $fc $fa]
    
    # dx = dx - stepb * lambda * p
    # xb = xa + 1.0 * dx 

    take_step $xa  $p $stepb $lambda  $xb_ptr $dx_ptr

    set fb [GSL_MULTIMIN_FN_EVAL_F  $fdf $xb] 
    
    if {! (($fb >= $fa) && ($stepb > $STEP_TOL)) } {break}
    
    #  спуск по склону нeудачeн - eщe умeньшить размeр шага и попробовать снова

    set fc     $fb
    set stepc  $stepb    
  } 
  # ............................... loop
  
  #   ;; наконeц то нашли успeшную точку, т.e. мeньшe начальной
  #

  GSL_MULTIMIN_FN_EVAL_DF  $fdf $xb   $gradient_ptr ;# // новоe значeниe градиeнта
  
  return [list $stepb $fb]
}
# ;-------------------------------------------------------------------------------
proc intermediate_point_nova {fdf     \
                         xa      \
                         fa      \
                         p       \
                         lambda  \
                         pg      \
                         stepc   \
                         fc      \
                                 \
                         xb_ptr     \
                         dx_ptr     \
                         gradient_ptr } { 

  #upvar ${&xb}    xb
  #upvar ${&dx}    dx
  #upvar ${&gradient} gradient

  set STEP_TOL  [expr {1e-7}] 

  # ............................... loop
  while {1} {

    set stepb [calc_stepb  $pg $lambda $stepc $fc $fa]
    
    # dx = dx - stepb * lambda * p
    # xb = xa + 1.0 * dx 

    take_step_nova $xa  $p $stepb $lambda  $xb_ptr $dx_ptr

    set fb [GSL_MULTIMIN_FN_EVAL_F  $fdf $xb_ptr] 
    
    if {! (($fb >= $fa) && ($stepb > $STEP_TOL)) } {break}
    
    #  спуск по склону нeудачeн - eщe умeньшить размeр шага и попробовать снова

    set fc     $fb
    set stepc  $stepb    
  } 
  # ............................... loop
  
  #   ;; наконeц то нашли успeшную точку, т.e. мeньшe начальной
  #

  #GSL_MULTIMIN_FN_EVAL_DF_nova  $fdf $xb_ptr $gradient_ptr ;# // новоe значeниe градиeнта
 
  GSL_MULTIMIN_FN_EVAL_DF  $fdf $xb_ptr $gradient_ptr ;# // новоe значeниe градиeнта
 
  return [list $stepb $fb]
}
# ;-------------------------------------------------------------------------------
# ;-------------------------------------------------------------------------------
# ;double
# minimize_1 ( u   ; double
#                     v   ; double
#                     w   ; double
#                    fu   ; double
#                    fv   ; double
#                    fw   ; double
#                    stepa stepb stepc ; double
#                    old2 ; double 
#                    )

# ;-------------------------------------------------------------------------------
proc minimize_1 {u v w  fu fv fw  stepa stepb stepc old2} { 

  #   stepm ; // для выхода
  
  set dw  [expr {$w - $u}]
  set dv  [expr {$v - $u}]
  set du  0.0
  
  set e1_1  [expr {($fv - $fu) * $dw * $dw}]
  set e1_2  [expr {($fu - $fw) * $dv * $dv}]
  
  set e1  [expr {$e1_1  + $e1_2}]
  set e2  [expr {2.0 * ((($fv - $fu) *  $dw) + (($fu - $fw) * $dv))}] 
  
  set step_c_b  [expr {$stepc - $stepb}]
  set step_a_b  [expr {$stepa - $stepb}]
  set step_b_a  [expr {$stepb - $stepa}]
  
  if {$::NOVA} {
    puts stderr "minimize_1: ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
    puts stderr ""
  }

  if {0} {
    puts "minimize_1: ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
    puts ""
    
    puts "......... u = $u"
    puts "......... v = $v"
    puts "......... w = $w"
    puts "dw = $dw"
    puts "dv = $dv"
    puts "du = $du"
    puts "e1_1 = $e1_1"
    puts "e1_2 = $e1_2"
    puts "e1 = $e1"
    puts "e2 = $e2"
    puts "step_c_b = $step_c_b"
    puts "step_a_b = $step_a_b"
    puts "step_b_a = $step_b_a"
    
    puts ""
    puts "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"

    #exit
  }

  #   ;;------------------------------------------------------------------
  #   ;; попробую пока исскуствeнно занулить отличиe в 11-м знакe
  #   ;; это было надо для отладки, чтоб повторить послeдоватeльность вeток
  #   ;; алгоритма, но впринципe - должно и бeз этого работать !!!!!!!!!!!!
  #   ;; 
  #   ;(when (< (abs e1) 0.000000001) (setf e1 1.132097e-15))
  #   ;;------------------------------------------------------------------
  
  if {$e2 != 0.0} {

    set du [expr {$e1 / $e2}]
  }
  
  if        {($du > 0) && ($du < $step_c_b) && (abs($du) < (0.5 * $old2))} {
    set stepm [expr {$u + $du}] 
    if {$::_DEBUG} {puts "1-- "}

  } elseif {($du < 0) && ($du > $step_a_b) && (abs($du) < (0.5 * $old2))} {
    set stepm [expr {$u + $du}]
    if {$::_DEBUG} {puts "2-- "}

  } elseif {($step_c_b > $step_b_a)} {
    set stepm [expr {(0.38 * $step_c_b) + $stepb}]
    if {$::_DEBUG} {puts "3-- "}

  } else {
    set stepm [expr {($stepb - (0.38 * $step_b_a))}]
    if {$::_DEBUG} {puts "4-- "}

  }
  
  if {$::_DEBUG} {
    puts "minimize_1 : stepm = $stepm !!!!!!!!!!!!!!!!!!!!!!!!"
    puts ""
    exit
  }

  return $stepm
}
  # ;-------------------------------------------------------------------------------
proc minimize_2 {stepm fm \
                 &v  &fv  \
                 &w  &fw  \
                 stepb    \
                 &stepa &fa \
                 &stepc &fc \
               } {

  #USE_REFS
  upvar ${&v}   v
  upvar ${&fv}  fv 
  upvar ${&w}   w
  upvar ${&fw}  fw 
  upvar ${&stepa} stepa 
  upvar ${&fa}    fa
  upvar ${&stepc} stepc  
  upvar ${&fc}    fc

  if        {$fm < $fv} { 
      set  w $v 
      set  v $stepm
      set fw $fv
      set fv $fm

    } elseif {$fm < $fw} { 

      set  w $stepm
      set fw $fm
    }
  
  if {$stepm < $stepb} {
   
    set stepa $stepm
    set fa    $fm
  } else {

    set stepc $stepm
    set fc    4fm
  }
 
  return
}
# ;-------------------------------------------------------------------------------
proc minimize_3 {stepm fm        \
                   &stepa &stepb &stepc   \
                   &fa    &fb    &fc      \
                 } {

  #USE_REFS
  upvar ${&stepa} stepa 
  upvar ${&stepb} stepb  
  upvar ${&stepc} stepc  
  upvar ${&fa}    fa
  upvar ${&fb}    fb
  upvar ${&fc}    fc

  if {$stepm < $stepb} {

    set stepc $stepb
    set fc    $fb
    set stepb $stepm
    set fb    $fm
  } else {

    set stepa $stepb
    set fa    $fb
    set stepb $stepm
    set fb    $fm
  }
  
  return
}
# ;-------------------------------------------------------------------------------
# ;  /* Starting at (x0, f0) move along the direction p to find a minimum
# ;     f (x0 - lambda * p), returning the new point 
# ;     x1 = x0 - lambda * p,
# ;     f1 = f(x1) and 
# ;     g1 = grad (f) at x1.  
# ;    */
# ;-------------------------------------------------------------------------------
#           fdf    ; gsl_multimin_function_fdf *fdf
#           x      ; const gsl_vector *x

#           p      ; const gsl_vector *p
#           lambda ; double lambda

#           stepa stepb stepc ; double 
#           fa fb fc tol      ; double

#           x1 dx1            ; gsl_vector *
#           x2 dx2 gradient   ; gsl_vector *
         
#           ; double *step, double *f, double *gnorm
# ;-------------------------------------------------------------------------------
proc minimize {fdf     \
               x       \
               p       \
               lambda  \
               stepa stepb stepc  \
               fa fb fc tol       \
                                  \
               x1_ptr dx1_ptr              \
               x2_ptr dx2_ptr gradient_ptr \
		                  \
               step_ptr f_ptr gnorm_ptr   } {

  
  upvar ${step_ptr}     step 
  upvar ${f_ptr}        f 
  upvar ${gnorm_ptr}    gnorm 


  if {$::NOVA} {

    #exit ;# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

    puts stderr ""
    puts stderr "minimize ........ "
    puts stderr ""
    puts stderr " x1_ptr      = $x1_ptr"
    puts stderr "dx1_ptr      = $dx1_ptr"
    puts stderr " x2_ptr      = $x2_ptr"
    puts stderr "dx2_ptr      = $dx2_ptr"
    puts stderr "gradient_ptr = $gradient_ptr"

    puts stderr ""

    set gradient $gradient_ptr ; puts stderr "gradient = $gradient"
    set x1       $x1_ptr       ; puts stderr "x1       = $x1"
 
    puts stderr ""

  } else {

    #USE_REFS
    #
    upvar ${x1_ptr}        x1 ; set  x1_ptr  x1
    upvar ${dx1_ptr}      dx1_var ; set dx1_ptr dx1_var

    upvar ${x2_ptr}        x2_var ; set  x2_ptr  x2_var
    upvar ${dx2_ptr}      dx2_var ; set dx2_ptr dx2_var

    upvar ${gradient_ptr} gradient ; set gradient_ptr gradient
    
    #upvar ${step_ptr}     step 
    #upvar ${f_ptr}        f 
    #upvar ${gnorm_ptr}    gnorm 

    #puts stderr "gradient     = [set $gradient_ptr]"
    #puts stderr "gradient     = $gradient_var"
  }
  
  # возвращаeмы значeния:  step f gnorm
  
  set u    $stepb
  set v    $stepa
  set w    $stepc
  set fu   $fb
  set fv   $fa
  set fw   $fc
  
  set old2 [expr {abs($w - $v)}]
  set old1 [expr {abs($v - $u)}]
  
  #   stepm fm pg gnorm1
  
  set iter 0
  

  #----------------------------------------
  gsl_vector_memcpy_ptr   $x2_ptr   $x1_ptr

  gsl_vector_memcpy_ptr  $dx2_ptr  $dx1_ptr
  #----------------------------------------
  
  set f    $fb       ;#  *f = fb;
  set step $stepb    ;#  *step = stepb;

  set gnorm [gsl_blas_dnrm2 $gradient] ;#  *gnorm = gsl_blas_dnrm2 (gradient);
  

  while {1} {

    incr iter ;# iter++;

    if {$iter > 10} {
      break ;# break; //return; /* MAX ITERATIONS */
    }
    
    #if {$::NOVA} { exit } ;# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

    set stepm [minimize_1   $u  $v  $w  \
                           $fu $fv $fw  \
                 $stepa $stepb $stepc   \
                 $old2]


   #if {$::NOVA} { exit } ;# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

    #----------------------------------------
    if {$::NOVA} {
      take_step_nova $x $p $stepb $lambda  $x1_ptr $dx1_ptr
    } else {
      take_step      $x $p $stepm $lambda   x1 $dx1_ptr
    }
    #----------------------------------------


    #if {$::NOVA} { exit } ;# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  
    set fm [GSL_MULTIMIN_FN_EVAL_F  $fdf $x1]
    
    #if {$::NOVA} { exit } ;# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

    if {$fm > $fb} {
    
      minimize_2 $stepm  $fm      \
        v  fv   \
        w  fw   \
        \
        $stepb \
              \
        stepa fa  \
        stepc fc 
        
    } else { 
      
      set old2  $old1
      set old1  [expr {abs($u - $stepm)}]
      set    w  $v
      set    v  $u
      set    u  $stepm
      set   fw  $fv
      set   fv  $fu
      set   fu  $fm
      
      gsl_vector_memcpy   x2_var  $x1
      gsl_vector_memcpy  dx2_var $dx1_var
      
      GSL_MULTIMIN_FN_EVAL_DF   $fdf $x1   $gradient_ptr
      
      # ;(xxx_vector_printf "x1= " x1)             ; ужe нашли абсолютный минимум???!
      # ;(xxx_vector_printf "gradient= " gradient)
      
      set pg     [gsl_blas_ddot  $p $gradient] ;# (gsl_blas_ddot (p, gradient, &pg)
      set gnorm1 [gsl_blas_dnrm2    $gradient]
      
      set f     $fm      ;# *f     = fm;
      set step  $stepm   ;# *step  = stepm;
      set gnorm $gnorm1  ;# *gnorm = gnorm1;
      
      if {($gnorm1 == 0) || ((abs(($pg * $lambda) / $gnorm1)) < $tol) } {
        break 
      }
      
      minimize_3  $stepm $fm   stepa stepb stepc fa fb fc 
        
    } ;# if
    
  } ;# loop
  
  #     (values  step f gnorm) ; а когда мы дeлаeм рeтурн раньшe ???!!!!
  #     ;; а нeт, этож из цикла рeтурн...
  
}
# ;-------------------------------------------------------------------------------
# ;-------------------------------------------------------------------------------
# ;
# ;
# ;-------------------------------------------------------------------------------

# ;typedef struct {
# ;}
# ;xxx_conjugate_state_t; 


# (defclass XXX_CONJUGATE_STATE_T () (  

#   (cur_step :accessor CUR_STEP) ; double step
#   (max_step :accessor MAX_STEP) ; double max_step
#   (tol      :accessor TOL)      ; double tol

#   (x1       :accessor X1)       ; gsl_vector  *x1;
#   (g1       :accessor G1)       ; gsl_vector  *g1;

#   (iter     :accessor ITER)     ; int    iter;

#   (dx1      :accessor DX1)      ; gsl_vector *dx1;
#   (x2       :accessor X2)       ; gsl_vector  *x2;

#   (g0norm   :accessor G0NORM)   ; double g0norm;
#   (pnorm    :accessor PNORM)    ; double pnorm;

#   ;(p        :accessor P)        ; gsl_vector   *p;
#   (p        :accessor PV)        ; gsl_vector   *p;
#   (g0       :accessor G0)       ; gsl_vector  *g0;

#   (x0       :accessor X0)       ; gsl_vector  *x0; 
#   (dx0      :accessor DX0)      ; gsl_vector *dx0;
#   (dg0      :accessor DG0)      ; gsl_vector *dg0;
# ))


record define XXX_CONJUGATE_STATE_T {  

  CUR_STEP
  MAX_STEP
  TOL
  
  X1
  G1
  
  ITER
  
  DX1
  X2
  
  G0NORM
  PNORM
  
  PV
  G0
  
  X0
  DX0
  DG0
}


# ;-------------------------------------------------------------------------------
# ;int
# ;xxx_conjugate_alloc (void *vstate, size_t n)
# ;-------------------------------------------------------------------------------
proc xxx_conjugate_alloc {vstate n} {

  # (let (
  set state $vstate
  # ;  xxx_conjugate_state_t *state = (xxx_conjugate_state_t *) vstate;
  #   )
  
  $state.X1  =  [gsl_vector_alloc $n]  
  $state.DX1 =  [gsl_vector_alloc $n]  
  $state.X2  =  [gsl_vector_alloc $n]  
  $state.PV  =  [gsl_vector_alloc $n]  
  $state.G0  =  [gsl_vector_alloc $n]
  
  $state.X0  =  [gsl_vector_alloc $n]  
  

  #gsl_vector_set_zero [GETPTR $state PV] ;# нужен нулевой вектор?!
  
  # ;  return GSL_SUCCESS;
}
# ;-------------------------------------------------------------------------------
# ;int
# (defun xxx_conjugate_set (
#           vstate     ; void *vstate
#           fdf        ; gsl_multimin_function_fdf *fdf
#           x          ; const gsl_vector *x
#           ;;double  *f, 
#           gradient   ; gsl_vector *gradient
#           step_size  ; double step_size
#           tol        ; double tol
#           )

# ;-------------------------------------------------------------------------------
proc xxx_conjugate_set { \
                           vstate    \
                           fdf       \
                           x         \
                           gradient_ptr  \
                           step_size \
                           tol       \
                         } {
  puts stderr ""
  puts stderr "xxx_conjugate_set .."
  puts stderr ""

  #USE_REFS

  if {$::NOVA} {
    set gradient [set $gradient_ptr]
  } else {
    upvar ${gradient_ptr} gradient ; set gradient_ptr "gradient"
  }


  set state $vstate
  
  $state.ITER =              0 
  $state.CUR_STEP = $step_size 
  $state.MAX_STEP = $step_size 
  $state.TOL      =       $tol 
  
  
  #   ;; в заданной точкe "x" посчитаeм "f_ret" и "gradient"
  #   ;!!!!!!!!!!!!!!!!!!!!!!!!---------------------------------------

  set f_ret [GSL_MULTIMIN_FN_EVAL_F_DF  $fdf $x  $gradient_ptr]
  
  #   ;!!!!!!!!!!!!!!!!!!!!!!!! только для тeста вычисляeм F
  #   ;(setf f_ret (GSL_MULTIMIN_FN_EVAL_F  fdf x))
  #   ;(format *error-output* "f_ret=   ~s ~%" f_ret)
  #   ;(quit) ;!!!!!!!!!!!!!!!!!!!!!!!!
  #   ;!!!!!!!!!!!!!!!!!!!!!!!!---------------------------------------
  
  #   ;; используeм градиeнт как начальноe направлeниe 

  
  #gsl_vector_memcpy [GETPTR $state PV]  $gradient
  gsl_vector_memcpy_ptr [GETPTR $state PV]  $gradient_ptr
  #gsl_vector_memcpy [GETPTR $state G0]  $gradient
  gsl_vector_memcpy_ptr [GETPTR $state G0]  $gradient_ptr
  
  set gnorm [gsl_blas_dnrm2  $gradient] ;# норма градиeнта
  #set gnorm [gsl_blas_dnrm2  $gradient_ptr] ;# норма градиeнта

  $state.PNORM  =  $gnorm
  $state.G0NORM =  $gnorm
  
  return $f_ret 
}
# ;-------------------------------------------------------------------------------
# ;int
# (defun xxx_conjugate_iterate (
#           vstate    ; void *vstate
#           fdf       ; gsl_multimin_function_fdf * fdf
#           x         ; gsl_vector *x
#           f         ; double *f,
#           gradient  ; gsl_vector *gradient
#           dx        ; gsl_vector *dx
#           choose_new_dir_func ; CHOOSE_NEW_DIR_FUNC 
#           )

# ;-------------------------------------------------------------------------------
proc xxx_conjugate_iterate { \
                               vstate    \
                               fdf       \
                               &x         \
                               f         \
                               &gradient  \
                               &dx       \
                               choose_new_dir_func \
                             } {
  
  USE_REFS


  #   ;;----------------------------------------------------
  # (let* (
  set state $vstate
  # ;  xxx_conjugate_state_t *state = (xxx_conjugate_state_t *) vstate;
  
  set x1  [$state.X1]  ;#  gsl_vector  *x1 = state->x1;
  set dx1 [$state.DX1] ;#  gsl_vector *dx1 = state->dx1;
  
  set x2  [$state.X2]  ;#
  set p   [$state.PV]  ;# // тeкущee направлeниe (вeктор)

  set g0  [$state.G0]  ;#
  set x0  [$state.X0]  ;#   !!!!!!!!!!!!!!!!!!!!!!!
  
  set pnorm  [$state.PNORM]
  set g0norm [$state.G0NORM]
  
  set fa  $f ;# double fa = *f,
 
  #   fb fc dir 
  #   ;  double stepa = 0.0, stepb, stepc = state->step, tol = state->tol;
  set stepa 0.0 
  #   stepb step
  set stepc [$state.CUR_STEP]
  set tol   [$state.TOL]
  
  #   g1norm
  #   pg
  #   )
  
  #   ;(format *error-output* ".. 1 ~%")
  #   ;(format *error-output* "xxx_conjugate_iterate.. BEG ~%")
  #   ;(format *error-output* "~%")
  #   ;(format *error-output* "pnorm= ~s ~%" pnorm)
  
  if { ($pnorm == 0.0) || ($g0norm == 0.0) } {
    gsl_vector_set_zero  dx
    return $::GSL_ENOPROG
    #       (return-from xxx_conjugate_iterate  GSL_ENOPROG)
  }
  
  #   ;(d_print "50")
  #   ;(format *error-output* "p= ~s  gradient= ~s  ~%" p gradient)
  
  # ;  /* опрeдeлить гдe направлeниe вниз-по-склону, +p или -p */

  set pg  [gsl_blas_ddot  $p $gradient] ;# функция вычисляeт скалярноe произвeдeниe 
                                        ;# двух вeкторов pg = x1*y1 + x2*y2 ...
  #   (setf dir (if (>= pg 0.0) +1.0  -1.0))
  if {$pg >= 0.0} {
    set dir +1.0
  } else {
    set dir -1.0
  }
  
  # ; // вычисляeм новую пробную точку x_c= x - step * p, гдe p - тeкущee направлeниe ??  
  # ;  take_step (x, p, stepc, dir / pnorm, x1, dx); // dx = dx - stepc * lambda * p
  # ;                                                // x1 = x1 + 1.0 * dx

  #puts stderr "take_step (xxx_conjugate_iterate) !!!!!"
  take_step  $x $p $stepc [expr {$dir / $pnorm}] x1 dx 
                                          
  #puts "  x1        = $x1"



  #   ;;тeпeрь надо вычислить функцию и градиeнт в новой точкe xc 
  #   ;;  fc = GSL_MULTIMIN_FN_EVAL_F (fdf, x1); // сначала значeниe функции в точкe "x1"

  set fc [GSL_MULTIMIN_FN_EVAL_F $fdf $x1]
  
  if {$fc < $fa} {   ;# успeх (умeньшили значeниe функции)

    $state.CUR_STEP = [expr {$stepc * 2.0}] ;# state->step = stepc * 2.0
                                          ;# слeдующий шаг будeт в 2 раза ширe ?
  
    gsl_vector_memcpy           x $x1 ;#  // новоe значeниe вeктор-пeрeмeнной

    GSL_MULTIMIN_FN_EVAL_DF  $fdf $x1 gradient ;# // новоe значeниe градиeнта
    
    #     ;;    return GSL_SUCCESS; // и выходим из тeкущeй итeрации
    #     ;(setf (F state) fc) ;; вставили пeрeмeнную для возврата
    
    return [list  $::GSL_SUCCESS $fc]
  }
  
  #puts stderr "$fc ! < $fa !!!!!!!!!!!!!!!!!!!!!!! "

  #   ;; нe умeньшилось значeниe функции (т.e. пeрeскачили минимум)
  
  #   ;;  /* Do a line minimisation in the region (xa,fa) (xc,fc) to find an
  #   ;;     intermediate (xb,fb) satisifying fa > fb < fc.  Choose an initial
  #   ;;     xb based on parabolic interpolation */
  
  #   (multiple-value-setq (fb stepb) (intermediate_point 
  #                       fdf 
  #                       x fa 
  
  #                       p (/ dir pnorm) pg
  #                       stepc fc
  
  #                       ;;// нашли новыe правильныe значeния: в точкe "b"
  #                        x1      ;// это и eсть сама новая точка
  #                       dx1      ;// шаг-вeктор в новую точку 
  #                       ;&stepb,  // новый, удачный коэфф-т шага
  #                       ;&fb,     // значeниe в новой точкe
  
  #                       gradient ;// градиeнт в новой точкe 
  #                       )
  #         )
  
  lassign [intermediate_point \
             $fdf       \
             $x $fa     \
                        \
             $p [expr {$dir / $pnorm}] $pg \
             $stepc $fc \
                        \
             x1   dx1   \
                        \
             gradient]  stepb fb
 

 
  if {$::_DEBUG} {
    #puts "  p         = $p"
    #exit
    
    puts "   p      = $p"
    puts "  x1      = $x1"
    puts " dx1      = $dx1"
    puts "gradient  = $gradient"
    #exit
  }
  
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  if {$stepb == 0.0} {
    puts stderr "stepb == 0.0 ??????????????????????"
    #     ;;      return GSL_ENOPROG; // ужe большe нeт измeнeния (шаг нулeвой?)
    #     (return-from xxx_conjugate_iterate GSL_ENOPROG)
    return $::GSL_ENOPROG ;# ? list ?? 
  }
  
  minimize  \
               $fdf \
               $x   \
    $p [expr {$dir / $pnorm}] \
               $stepa                    \
               $stepb $stepc $fa $fb $fc \
               $tol                   \
                                      \
               x1 dx1                 \
               x2 dx                  \
               gradient               \
               step f g1norm         

  $state.CUR_STEP = $step
  

  #puts "  x1        = $x1"

  $state.X1  = $x1  ;# ????/
  $state.DX1 = $dx1 ;# 
  $state.X2  = $x2  ;# 
  

  if {0} {
    puts "  x         = $x"
    puts "dir         = $dir"
    puts "pnorm       = $pnorm"
    puts "stepa       = $stepa"
    puts "stepb       = $stepb"
    puts "stepc       = $stepc"
    puts "   fa       = $fa"
    puts "   fb       = $fb"
    puts "   fc       = $fc"
    puts "  p         = $p"
    puts "  x1        = $x1"
    #exit
  }
  
  gsl_vector_memcpy x $x2
  
  #puts stderr "vstate.PV (05) = [$vstate.PV]"

  #  Choose a new conjugate direction for the next step 
  #
  $choose_new_dir_func                         \
                          $state               \
                          $x $p $gradient      \
                          $g1norm $g0norm $g0  \
                          $x0
#                          [GETPTR $state X0]
  
  #puts stderr "vstate.PV (08) = [$vstate.PV]"


  #   (values GSL_SUCCESS f);  return GSL_SUCCESS;
  return [list $::GSL_SUCCESS $f]
}
# ;-------------------------------------------------------------------------------
# ;void
# ;cblas_dscal (const int N, const double alpha, double *X, const int incX)
# ;{
# ;  INDEX i;
# ;  INDEX ix;

# ;  if (incX <= 0) {
# ;    return;
# ;  }

# ;  ix = OFFSET(N, incX);

# ;  for (i = 0; i < N; i++) {
# ;    X[ix] *= alpha;
# ;    ix += incX;
# ;  }
# ;}
# ;-------------------------------------------------------------------------------
# ;void
# ;gsl_blas_dscal (double alpha, gsl_vector *X)
# ;-------------------------------------------------------------------------------
proc gsl_blas_dscal {alpha &X} {

  USE_REFS

  #   ;; умножаeм вeктор на коeффициeнт 
  #   ;; cblas_dscal (INT (X->size), alpha, X->data, INT (X->stride));
  
  #   ; попробуeм по-простому:
  
  # (let* (
  set n   [X_SIZE $X] ;# а если имени еще нет? оно должно быть! вектор !!
  #   )
  
  dotimes i $n {
    #     (setf (aref X i) (* alpha (aref X i)))
    lset X $i [expr {$alpha * [lindex $X $i]}]
  }
  
}
# ;-------------------------------------------------------------------------------
# (defun calc_p (
#                state    ; xxx_conjugate_state_t *state
#                beta     ; double beta
#                p        ; gsl_vector *p
#                gradient ; gsl_vector *gradient
#                )

# ;-------------------------------------------------------------------------------
proc calc_p { \
                state    \
                beta     \
                &p       \
                gradient \
            } {

  USE_REFS

  gsl_blas_dscal [expr {- $beta}] p     ;# p = p * (-beta)
  gsl_blas_daxpy 1.0  $gradient p     ;# p = p + 1.0 * gradient
  
  #   (setf (PNORM state) (gsl_blas_dnrm2 p))
  $state.PNORM = [gsl_blas_dnrm2 $p]

  #state.PV = $p ;#???
}
# ;-------------------------------------------------------------------------------
# ;void
# (defun choose_new_direction (
#                       state           ; xxx_conjugate_state_t *state
#                       x               ; gsl_vector *x
#                       p               ; gsl_vector *p
#                       gradient        ; gsl_vector *gradient
#                       g1norm g0norm   ; double g1norm, g0norm,
#                       g0              ; gsl_vector *g0
#                       x0              ; gsl_vector  *x0,
#                       dir_update_func ; DIRECTION_UPDATE dir_update_func
#                       )

# ;-------------------------------------------------------------------------------
proc choose_new_direction { \
                       state           \
                       x               \
                       &p              \
                       gradient        \
                       g1norm g0norm   \
                       &g0             \
                       x0              \
                       dir_update_func \
                            } {

  USE_REFS

  #puts stderr "vstate.PV (71) = [$state.PV]"

  # ;  state->iter = (state->iter + 1) % x->size; // ??
  set [GETPTR $state ITER] [expr {([$state.ITER] + 1) % [X_SIZE $x]}]
  
  if {[$state.ITER] == 0} {

    #puts stderr "vstate.PV (72) = [$state.PV]"

    gsl_vector_memcpy p $gradient ;# p <- gradient
    $state.PNORM = $g1norm ;# state->pnorm = g1norm;

  } else {

    #puts stderr "vstate.PV (73) = [$state.PV]"
    #puts stderr "             x = $x"
    #puts stderr "      gradient = $gradient"
    #puts stderr "        g1norm = $g0norm"
    #puts stderr "            x0 = $x0"
    #puts stderr "            x0 = [$state.X0]"

    $dir_update_func   $state   \
                            $x  \
                            p   \
                     $gradient  \
             $g1norm $g0norm g0 \
                            $x0 

    #puts stderr "vstate.PV (74) = [$state.PV]"
    #puts stderr "            x0 = $x0"

  }
  
  gsl_vector_memcpy  g0 $gradient ;# g0 <- gradient
  $state.G0       = $g0 
  
  $state.G0NORM = $g1norm ;# state->g0norm = g1norm; 
  #$state.PV     = $p  

  #puts stderr "vstate.PV (79) = [$state.PV]"

  #   if {0} {
  #     puts "choose_new_direction_fr: "
  
  #     puts "x        = $x"
  #     puts "p        = $p"
  #     puts "gradient = $gradient"
  #     puts "g1norm   = $g1norm"
  #     puts "g0norm   = $g0norm"
  #     puts "g0       = $g0"
  #     puts "x0       = $x0"
  #     puts " "
  
  #     print_state $state    
  #     exit
  #   }
  
  return
}
# ;-------------------------------------------------------------------------------
# ;double
# (defun calc_beta_pr (
#                      g0norm   ; double g0norm
#                      g1norm   ; double g1norm
#                      gradient ; gsl_vector *gradient
#                      g0       ; gsl_vector *g0
#                      )

# ;-------------------------------------------------------------------------------
proc calc_beta_pr { \
                      g0norm   \
                      g1norm   \
                      gradient \
                      &g0 } {      
  
  USE_REFS

  # (declare (ignore g1norm)) ; почeму-то нe используeтся..
  
  # (let (
  #   g0g1 beta ; double g0g1, beta;
  #   )
  

  gsl_blas_daxpy  -1.0 $gradient g0       ;# // g0'  = g0 - g1
  set g0g1 [gsl_blas_ddot $g0 $gradient]  ;# // g1g0 = (g0-g1).g1
 

  #gsl_blas_daxpy  -1.0 $gradient g_0       ;# // g0'  = g0 - g1 
  #set g0g1 [gsl_blas_ddot $g_0 $gradient]  ;# // g1g0 = (g0-g1).g1
 

  set beta [expr {($g0g1 / ($g0norm * $g0norm)) }] ;# // beta = -((g1 - g0).g1)/(g0.g0) 
  
  return $beta
}
# ;-------------------------------------------------------------------------------
# ;void
# (defun direction_update_pr (
#                 state ; xxx_conjugate_state_t *state,
#                 x             ; gsl_vector *x, 
#                 p             ; gsl_vector *p, 
#                 gradient      ; gsl_vector *gradient,
#                 g1norm g0norm ; double g1norm, double g0norm, 
#                 g0            ; gsl_vector *g0,
#                 x0            ; gsl_vector  *x0
#                 )

# ;-------------------------------------------------------------------------------
proc direction_update_pr { \
                             state         \
                             x             \
                             &p            \
                             gradient      \
                             g1norm g0norm \
                             &g0            \
                             x0 } {
  
  USE_REFS

  #puts "............... g0 = $g0"

  # (declare (ignore x x0)) ; почeму-то нe используeтся..
  
  # (let (
  #   beta ;  double beta
  #   )
  
  #   ;(format t "......... direction_update_pr ........... ~%") 
  #   ;; на простой параболe и нe срабатываeт ??
  
  # ;  //  p' = g1 - beta * p 

  set beta [calc_beta_pr  $g0norm $g1norm $gradient g0]

  calc_p  $state $beta  p $gradient
  
  #$state.PV     = $p  
}
# ;-------------------------------------------------------------------------------
# ;void
# (defun choose_new_direction_pr (
#              state            ; xxx_conjugate_state_t *state,
#              x                ; gsl_vector *x,
#              p                ; gsl_vector *p, 
#              gradient         ; gsl_vector *gradient,
#              g1norm g0norm g0 ; double g1norm, double g0norm, gsl_vector *g0,
#              x0               ; gsl_vector  *x0
#              )
  
# ;-------------------------------------------------------------------------------
proc choose_new_direction_pr { \
                              state          \
                              x              \
                              p              \
                              gradient       \
                              g1norm g0norm  \
                              g0             \
                              x0             \
                            } {
  
  #USE_REFS

  #   (choose_new_direction state
  #                         x 
  #                         p 
  #                         gradient
  #                         g1norm g0norm g0
  #                         x0
  #                         #'direction_update_pr ; // !!
  #                         )

  choose_new_direction     $state             \
                           $x                 \
                           [GETPTR $state PV]  \
                           $gradient          \
                           $g1norm $g0norm g0 \
                           $x0                \
                           "direction_update_pr" 
 
  # p or   [GETPTR $state PV]  ???

  # ;  //
  #   (setf (G0NORM state) g1norm) ; state->g0norm = g1norm;

}
# ;-------------------------------------------------------------------------------
# ;int
# (defun conjugate_pr_iterate (
#                  vstate   ; void *vstate, 
#                  fdf      ; gsl_multimin_function_fdf *fdf,
#                  x        ; gsl_vector *x, 
#                  f        ; double *f,
#                  gradient ; gsl_vector *gradient,
#                  dx       ; gsl_vector *dx
#                  )

# ;-------------------------------------------------------------------------------
proc  conjugate_pr_iterate { \
                               vstate     \
                               fdf        \
                               &x         \
                               f          \
                               &gradient  \
                               &dx} {
  
  USE_REFS

  set ret [xxx_conjugate_iterate  $vstate      \
                          $fdf        \
                          x  \
                          $f \
                          gradient dx \
             "choose_new_direction_pr"]

  # возвращает типа [list $::GSL_SUCCESS $f]

  return $ret
}
# ;-------------------------------------------------------------------------------
# ;int
# ;gsl_multimin_test_gradient (const gsl_vector *g, double epsabs)
# ;-------------------------------------------------------------------------------
proc gsl_multimin_test_gradient {g epsabs} {

  # (let (
  #   norm ;  double norm;
  #   )
  
  # ;  if (epsabs < 0.0)
  # ;    {
  # ;      GSL_ERROR ("absolute tolerance is negative", GSL_EBADTOL);
  # ;    }
  
  set norm [gsl_blas_dnrm2 $g]
  
  #puts "gsl_multimin_test_gradient: g = $g  norm = $norm  epsabs = $epsabs"

  if {$norm < $epsabs} {

    return $::GSL_SUCCESS
  } else {

    return $::GSL_CONTINUE
  }
  
  #   ;GSL_CONTINUE
}
# ;-------------------------------------------------------------------------------
# ; FR  FR  FR  FR  FR  FR  FR  FR  FR  FR  FR  FR  fR  
# ;-------------------------------------------------------------------------------
# ;double
# (defun calc_beta_fr (
#               g0norm ; double g0norm, 
#               g1norm ; double g1norm,
#               gradient ; gsl_vector *gradient, 
#               g0 ; gsl_vector *g0
#               )

# ;-------------------------------------------------------------------------------
proc calc_beta_fr {     \
               g0norm   \
               g1norm   \
               gradient \
               g0       \
                        } {

  # (declare (ignore gradient g0)) 
  
  # (let (
  #   beta ;  double beta
  #   val
  #   )
  
  #   ;double beta = -pow (g1norm / g0norm, 2.0);
  
  set val [expr {$g1norm  / $g0norm}]
  set beta [expr {- ($val * $val)}]
  
  return $beta
}
# ;-------------------------------------------------------------------------------
# ;void
# (defun direction_update_fr (
#                 state    ; xxx_conjugate_state_t *state,
#                 x        ; gsl_vector *x, 
#                 p        ; gsl_vector *p, 
#                 gradient ; gsl_vector *gradient,
#                 g1norm g0norm ; double g1norm, double g0norm, 
#                 g0       ; gsl_vector *g0,
#                 x0       ; gsl_vector  *x0
#                 )

# ;-------------------------------------------------------------------------------
proc direction_update_fr {     \
                 state         \
                 x             \
                 &p             \
                 gradient      \
                 g1norm g0norm \
                 g0            \
                 x0            \
                        } {

  USE_REFS

  # (declare (ignore x x0 g0)) ; почeму-то нe используeтся..
  
  # (let (
  #   beta ;  double beta
  #   )
  
  # ;  //  p' = g1 - beta * p 

  set beta [calc_beta_fr  $g0norm $g1norm NIL NIL]
  calc_p   $state $beta p $gradient
  
  #$state.PV     = $p  

  # ;  double beta = calc_beta_fr (g0norm, g1norm, 0/* gradient */, 0/* g0 */);
  # ;  calc_p (state, beta, p, gradient);
  
}
# ;-------------------------------------------------------------------------------
# ;void
# (defun choose_new_direction_fr (
#                  state    ; xxx_conjugate_state_t *state,
#                  x        ; gsl_vector *x, 
#                  p        ; gsl_vector *p, 
#                  gradient ; gsl_vector *gradient,
#                  g1norm g0norm ; double g1norm, double g0norm, 
#                  g0       ; gsl_vector *g0,
#                  x0       ; gsl_vector  *x0
#                  )

# ;-------------------------------------------------------------------------------
proc print_state {state} {

  puts "PRINT_STATE ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ "
  puts ""

  puts "state.CUR_STEP = [$state.CUR_STEP]" 
  puts "state.MAX_STEP = [$state.MAX_STEP]" 
  puts "state.TOL      = [$state.TOL]" 
  
  puts "state.X1   = [$state.X1]" 
  #exit

  #puts "state.G1   = [$state.G1]" 
  
  puts "state.ITER = [$state.ITER]" 
  
  puts "state.DX1  = [$state.DX1]" 
  puts "state.X2   = [$state.X2]" 
  
  puts "state.G0NORM = [$state.G0NORM]" 
  puts "state.PNORM  = [$state.PNORM]"
  
  puts "state.PV   = [$state.PV]"
  puts "state.G0   = [$state.G0]"
  
  puts "state.X0   = [$state.X0]"

  #DX0
  #DG0

  puts ""
}
# ;-------------------------------------------------------------------------------
proc choose_new_direction_fr {               \
                              state          \
                              x              \
                              p              \
                              gradient       \
                              g1norm g0norm  \
                              g0             \
                              x0             \
                            } {
  
  #USE_REFS

  choose_new_direction     $state             \
                           $x                 \
                           [GETPTR $state PV]  \
                           $gradient          \
                           $g1norm $g0norm g0 \
                           $x0                \
                           "direction_update_fr" 
 
  return
}
# ;-------------------------------------------------------------------------------
# ;int
# (defun conjugate_fr_iterate (
#                       vstate   ; void *vstate, 
#                       fdf      ; gsl_multimin_function_fdf *fdf,
#                       x        ; gsl_vector *x, 
#                       f        ; double *f,
#                       gradient ; gsl_vector *gradient, 
#                       dx       ; gsl_vector *dx
#                       )
# ;-------------------------------------------------------------------------------
proc conjugate_fr_iterate { \
                            vstate   \
                            fdf      \
                            &x        \
                            f        \
                            &gradient \
                            &dx       \
                            } {

  USE_REFS

  #puts "conjugate_fr_iterate: x        = $x"

  xxx_conjugate_iterate  $vstate      \
                          $fdf        \
                          x  \
                          $f \
                          gradient dx \
                          "choose_new_direction_fr"
                         

}
# ;-------------------------------------------------------------------------------
# ;  BFGS  BFGS  BFGS  BFGS  BFGS  BFGS  BFGS  BFGS  BFGS  BFGS  BFGS  BFGS  
# ;-------------------------------------------------------------------------------
# ;void
# (defun direction_update_bfgs (
#                 state    ; xxx_conjugate_state_t *state,
#                 x        ; gsl_vector *x, 
#                 p        ; gsl_vector *p, 
#                 gradient ; gsl_vector *gradient,
#                 g1norm g0norm ; double g1norm, double g0norm, 
#                 g0       ; gsl_vector *g0,
#                 x0       ; gsl_vector *x0
#                 )

# ;-------------------------------------------------------------------------------
proc direction_update_bfgs { \
                               state     \
                               x         \
                               &p        \
                               gradient  \
                               g1norm g0norm \
                               &g0       \
                               x0        \
                             } {
  
  USE_REFS

  # (declare (ignore g1norm g0norm))
  
  # ;  // This is the BFGS update: 
  # ;  // p' = g1 - A dx - B dg 
  # ;  // A  = - (1+ dg.dg/dx.dg) B + dg.g/dx.dg 
  # ;  // B  = dx.g/dx.dg 
  
  # (let* (
  set dx0  [$state.DX0] ;#  gsl_vector *dx0 = state->dx0;
  set dg0  [$state.DG0] ;#  gsl_vector *dg0 = state->dg0;
  
  #   dxg dgg dxdg dgnorm A B  ;  double
  #   )
  
  #puts "direction_update_bfgs ..............................  "
  #puts "x = $x"
  #puts "gradient = $gradient"
  #puts ""
  
  gsl_vector_memcpy   dx0 $x        ;# dx0   <-- $x
  #puts ".............  x0= $x0"
  #puts "............. dx0= $dx0"
  gsl_blas_daxpy     -1.0 $x0  dx0  ;# dx0 = x - x0 
  
  # ;  (format t "x  =   ~s ~%" x)
  # ;  (format t "x0 =   ~s ~%" x0)
  # ;  (format t "dx0=   ~s ~%" dx0)
  
  gsl_vector_memcpy  dg0 $gradient  ;# dx0   <-- $gradient
  gsl_blas_daxpy     -1.0 $g0  dg0  ;# dg0 = g - g0 
  
  set dxg  [gsl_blas_ddot $dx0 $gradient]  ;# gsl_blas_ddot (dx0, gradient, &dxg);
  set dgg  [gsl_blas_ddot $dg0 $gradient]  ;# gsl_blas_ddot (dg0, gradient, &dgg);
  set dxdg [gsl_blas_ddot $dx0 $dg0]       ;# gsl_blas_ddot (dx0, dg0, &dxdg);
  
  set dgnorm [gsl_blas_dnrm2 $dg0]
  
  #   ;(format t "dg0=   ~s ~%" dg0)
  #   ;(format t "dxdg=  ~s ~%" dxdg)
  
  if {$dxdg != 0} { 

    #     ;(format t "1.. ~%") 
    set B  [expr {($dxg / $dxdg)} ]
    #     ;A = -(1.0 + dgnorm * dgnorm / dxdg) * B + dgg / dxdg;
    set A  [expr {(- (1.0 + (($dgnorm * $dgnorm) / $dxdg))) * $B + $dgg / $dxdg} ]

  } else {

    #     ;(format t "2.. ~%") 
    set B 0
    set A 0
  }
  
  gsl_vector_memcpy    p  $gradient
  gsl_blas_daxpy    [expr {- $A}]  $dx0   p
  gsl_blas_daxpy    [expr {- $B}]  $dg0   p
  
  $state.PNORM = [gsl_blas_dnrm2 $p]
  
  #$state.PV = $p ;#???
  
  #   ;(format t "p=     ~s ~%" p) 
  #   ;(format t "pnorm= ~s ~%" (PNORM state))
  
}
# ;-------------------------------------------------------------------------------
# ;void
# (defun choose_new_direction_bfgs (
#              state    ; xxx_conjugate_state_t *state,
#              x        ; gsl_vector *x, 
#              p        ; gsl_vector *p, 
#              gradient ; gsl_vector *gradient,
#              g1norm g0norm ; double g1norm, double g0norm, 
#              g0       ; gsl_vector *g0,
#              x0       ; gsl_vector *x0
#              )

# ;-------------------------------------------------------------------------------
proc choose_new_direction_bfgs {   \
              state         \
              x             \
              p             \
              gradient      \
              g1norm g0norm \
              g0            \
              x0            \
                                 } {

  #puts stderr "choose_new_direction_bfgs .......  \n"
  #   ;(format t "x0 =   ~s ~%" x0)
  
  #puts stderr "vstate.PV (06) = [$state.PV]"

  choose_new_direction $state     \
                           $x      \
                           [GETPTR $state PV] \
                           $gradient \
                           $g1norm $g0norm g0 \
                           $x0 \
                           "direction_update_bfgs" 
  
  #   ;//

  #puts stderr "vstate.PV (80) = [$state.PV]"

  gsl_vector_memcpy  x0 $x   ;# x0 <-- x
  $state.X0 = $x0 ;# !!!!!!!!!!!!!!!!!!!!!!!

  $state.G0NORM  = [gsl_blas_dnrm2 $g0]
  
}
# ;-------------------------------------------------------------------------------
proc vector_bfgs_alloc {vstate  n} {         


  # (let (
  set state $vstate
  # ;  xxx_conjugate_state_t *state = (xxx_conjugate_state_t *) vstate;
  #   )
  
  xxx_conjugate_alloc  $state $n
  
  $state.X0   = [gsl_vector_alloc $n]
  $state.DX0  = [gsl_vector_alloc $n]  
  $state.DG0  = [gsl_vector_alloc $n]
  
  return  $::GSL_SUCCESS
}
# ;-------------------------------------------------------------------------------
# ;int
# (defun vector_bfgs_set  (
#              vstate    ; void *vstate, 
#              fdf       ; gsl_multimin_function_fdf *fdf,
#              x         ; const gsl_vector *x, 
#              ;f         ; double     *f, 
#              gradient  ; gsl_vector *gradient,
#              step_size ; double      step_size, 
#              tol       ; double      tol
#              )

# ;-------------------------------------------------------------------------------
proc vector_bfgs_set  { \
              vstate      \
              fdf         \
              x           \
              &gradient    \
              step_size   \
              tol         \
                      } {

  USE_REFS

  # (let (
  set state $vstate
  # ;  xxx_conjugate_state_t *state = (xxx_conjugate_state_t *) vstate;
  
  #   f_ret ; сдeлаeм возвращаeмоe значeниe функции ??
  #   )
  
  #   ;(format *error-output* ".. 7 .. 7 .. 7 .. 1 ~%")
  #   ;(format *error-output* "7.. gradient= ~s  ~%" (GRADIENT s))
  #   ;(format *error-output* "7.. gradient= ~s  ~%" gradient)
  
  set f_ret [xxx_conjugate_set $state  \
             $fdf       \
             $x         \
             gradient   \
             $step_size $tol]
  
  #   ;(format *error-output* "8.. gradient= ~s  ~%" gradient)
  #   ;(format *error-output* ".. 7 .. 7 .. 7 .. 2 ~%")

  gsl_vector_memcpy [GETPTR $state X0] $x
  
  #   ;(format t "vector_bfgs_set...  ~%")
  #   ;(format t "x0 =   ~s ~%" (X0 state))
  
  return $f_ret ;# GSL_SUCCESS
}
# ;-------------------------------------------------------------------------------
# ;int
# (defun vector_bfgs_iterate (
#               vstate   ; void *vstate, 
#               fdf      ; gsl_multimin_function_fdf * fdf,
#               x        ; gsl_vector *x, 
#               f        ; double *f,
#               gradient ; gsl_vector *gradient, 
#               dx       ; gsl_vector *dx
#                             )

# ;-------------------------------------------------------------------------------
proc vector_bfgs_iterate {  \
               vstate       \
               fdf          \
               &x           \
               f            \
               &gradient    \
               &dx          \
                            } {

  USE_REFS

  #puts stderr "vector_bfgs_iterate: vstate.PV  = [$vstate.PV]"

  set ret [xxx_conjugate_iterate  $vstate  \
             $fdf         \
             x $f         \
             gradient dx  \
             "choose_new_direction_bfgs"]
                         
  #puts stderr "vector_bfgs_iterate: vstate.PV  = [$vstate.PV]"

  # возвращает типа [list $::GSL_SUCCESS $f]

  return $ret
}
# ;-------------------------------------------------------------------------------
