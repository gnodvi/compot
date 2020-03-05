; -*-   mode: lisp ; coding: koi8   -*- ----------------------------------------

;-------------------------------------------------------------------------------
;
;===============================================================================

;(setf *read-default-float-format* 'double-float) 
(setf *read-default-float-format* 'long-float) 
; тогда всe читамыe в файлe символы  типа 2.0 будут даблами !!

(defvar  _DEBUG NIL)

;;;=============================================================================

;#+SBCL (load-shared-object "libc.so.6")

;===============================================================================

;enum { 
(defconstant GSL_SUCCESS   0)
(defconstant GSL_FAILURE  -1)
(defconstant GSL_CONTINUE -2) ;  /* iteration has not converged */
;  GSL_EDOM     = 1,   /* input domain error, e.g sqrt(-1) */
;  GSL_ERANGE   = 2,   /* output range error, e.g. exp(1e100) */
;  GSL_EFAULT   = 3,   /* invalid pointer */
;  GSL_EINVAL   = 4,   /* invalid argument supplied by user */
;  GSL_EFAILED  = 5,   /* generic failure */
;  GSL_EFACTOR  = 6,   /* factorization failed */
;  GSL_ESANITY  = 7,   /* sanity check failed - shouldn't happen */
;  GSL_ENOMEM   = 8,   /* malloc failed */
;  GSL_EBADFUNC = 9,   /* problem with user-supplied function */
;  GSL_ERUNAWAY = 10,  /* iterative process is out of control */
;  GSL_EMAXITER = 11,  /* exceeded max number of iterations */
;  GSL_EZERODIV = 12,  /* tried to divide by zero */
;  GSL_EBADTOL  = 13,  /* user specified an invalid tolerance */
;  GSL_ETOL     = 14,  /* failed to reach the specified tolerance */
;  GSL_EUNDRFLW = 15,  /* underflow */
;  GSL_EOVRFLW  = 16,  /* overflow  */
;  GSL_ELOSS    = 17,  /* loss of accuracy */
;  GSL_EROUND   = 18,  /* failed because of roundoff error */
;  GSL_EBADLEN  = 19,  /* matrix, vector lengths are not conformant */
;  GSL_ENOTSQR  = 20,  /* matrix not square */
;  GSL_ESING    = 21,  /* apparent singularity detected */
;  GSL_EDIVERGE = 22,  /* integral or series is divergent */
;  GSL_EUNSUP   = 23,  /* requested feature is not supported by the hardware */
;  GSL_EUNIMPL  = 24,  /* requested feature not (yet) implemented */
;  GSL_ECACHE   = 25,  /* cache limit exceeded */
;  GSL_ETABLE   = 26,  /* table limit exceeded */
(defconstant GSL_ENOPROG  27) ;  /* iteration is not making progress towards solution */
;  GSL_ENOPROGJ = 28,  /* jacobian evaluations are not improving the solution */
;  GSL_ETOLF    = 29,  /* cannot reach the specified tolerance in F */
;  GSL_ETOLX    = 30,  /* cannot reach the specified tolerance in X */
;  GSL_ETOLG    = 31,  /* cannot reach the specified tolerance in gradient */
;  GSL_EOF      = 32   /* end of file */
;} ;

;-------------------------------------------------------------------------------

(defmacro X_SIZE (x) (list 'array-dimension x 0))



;-------------------------------------------------------------------------------
; gsl_multimin.h

;/* Definition of an arbitrary differentiable real-valued function */
;/* with gsl_vector input and parameters */

;struct gsl_multimin_function_fdf_struct 
;{
;  double (*   f) (const gsl_vector * x, void * params);
;  void   (*  df) (const gsl_vector * x, void * params, gsl_vector * df);
;  void   (* fdf) (const gsl_vector * x, void * params, double *f, gsl_vector * df);
;  size_t n;
;  void * params;
;};

;typedef struct gsl_multimin_function_fdf_struct gsl_multimin_function_fdf;

;#define GSL_MULTIMIN_FN_EVAL_F(F,x) (*((F)->f))(x,(F)->params)
;#define GSL_MULTIMIN_FN_EVAL_DF(F,x,g) (*((F)->df))(x,(F)->params,(g))
;#define GSL_MULTIMIN_FN_EVAL_F_DF(F,x,y,g) (*((F)->fdf))(x,(F)->params,(y),(g))


(defclass FUNCTION_FDF () (  
  (f      :accessor F)
  (df     :accessor DF)
  (fdf    :accessor FDF)
  (n      :accessor N)
  (params :accessor PARAMS)
))


;-------------------------------------------------------------------------------
;/* minimisation of differentiable functions */
;//-----------------------------------------------------------------------------

;typedef struct 
;{
;}
;gsl_multimin_fdfminimizer_type;

(defclass FDFMINIMIZER_TYPE () (  

  ;; Error: Error during processing of initialization file /home/..../.sbclrc:
  ;; NAME already names an ordinary function or a macro.
  (name    :accessor NAMEZ)  ;  const char *name

  (alloc   :accessor ALLOC) ;  size_t      size

  (ms      :accessor MS) ; это моя функция динамичeского задания типа

;  int (*set)      (void *state, gsl_multimin_function_fdf * fdf,
;                   const gsl_vector * x, double * f, 
;                   gsl_vector * gradient, double step_size, double tol);
  (sets    :accessor SETS)

;  int (*iterate)  (void *state,gsl_multimin_function_fdf * fdf, 
;                   gsl_vector * x, double * f, 
;                   gsl_vector * gradient, gsl_vector * dx);
  (iterate :accessor ITERATE)

;  int  (*restart) (void *state);
;  void (*free)    (void *state);
))


;typedef struct 
;{
;}
;gsl_multimin_fdfminimizer;

(defclass FDFMINIMIZER () (  
  ;;  /* multi dimensional part */
  (typer    :accessor TYPER) ;  const gsl_multimin_fdfminimizer_type *type;
  (fdf      :accessor FDF)   ;  gsl_multimin_function_fdf            *fdf;
 
  (f        :accessor F)        ;  double      f
  (x        :accessor X)        ;  gsl_vector *x
  (gradient :accessor GRADIENT) ;  gsl_vector *gradient
  (dx       :accessor DX)       ;  gsl_vector *dx

  (state    :accessor STATE)    ;  void *state
))

;-------------------------------------------------------------------------------
(defun gsl_vector_set_zero (x)

(let* (
  (n   (X_SIZE x))
  )

  (dotimes (i n)
    (setf (aref x i) 0)
    )

))
;-------------------------------------------------------------------------------
(defun gsl_vector_alloc (n)

 (make-array n)

)
;-------------------------------------------------------------------------------
(defun gsl_vector_calloc (n)

(let (
  (x (gsl_vector_alloc n))
  )

  (gsl_vector_set_zero x) ; зануляeм

  x
))
;-------------------------------------------------------------------------------
(defun gsl_vector_set (vec i value)

 (setf (aref vec i) value)

)
;-------------------------------------------------------------------------------
(defun gsl_vector_get (vec i)

 (aref vec i)

)
;-------------------------------------------------------------------------------
;void
;xxx_vector_fprintf_line (FILE *stream, char *name, gsl_vector *v)
;-------------------------------------------------------------------------------
(defun xxx_vector_fprintf_line (stream name v)

(let (
  (n   (X_SIZE v))
  )

  (format stream "~a(" name)

  (dotimes (i n)
    (format stream "~8,6f" (aref v i))

    (if (/= i (- n 1))
        (format stream " ")
        )
    )

  (format stream ")")

))
;-------------------------------------------------------------------------------
;void
(defun xxx_vector_printf_line (
          name ; char *name
          v    ; gsl_vector *v
          )

  ;xxx_vector_fprintf_line (stdout, name, v);
  (xxx_vector_fprintf_line t name v)

)
;-------------------------------------------------------------------------------
(defun xxx_vector_fprintf (stream name v)

  (xxx_vector_fprintf_line stream name v)
  (format stream "~%")

)
;-------------------------------------------------------------------------------
(defun xxx_vector_printf (name v)

;  (xxx_vector_fprintf_line t name v)
;  (format t "~%")
  (xxx_vector_fprintf t name v)

)
;-------------------------------------------------------------------------------
(defun gsl_vector_memcpy (y x)

(let* (
  (n   (X_SIZE x))
  )

  (dotimes (i n)
    (setf (aref y i) (aref x i))
    )

))
;===============================================================================
;-------------------------------------------------------------------------------
;int
(defun gsl_multimin_fdfminimizer_set (
                   s             ; gsl_multimin_fdfminimizer * s
                   fdf           ; gsl_multimin_function_fdf * fdf
                   x             ; const gsl_vector * x
                   step_size tol ; double step_size, double tol
                   )

;  if (s->x->size != fdf->n)
  (when (/= (length (X s)) (N fdf))
    ;; GSL_ERROR ("function incompatible with solver size", GSL_EBADLEN);
    (format t "function incompatible with solver size ~%")
    )

;  if (x->size != fdf->n) 
  (when (/= (length x) (N fdf)) 
;      GSL_ERROR ("vector length not compatible with function", GSL_EBADLEN);
      (format t "vector length not compatible with function ~%")
    )
    
  ;(format *error-output* ".. 2 .. 3 .. 1 ~%")

  (setf (FDF s) fdf) ;  s->fdf = fdf;

  (gsl_vector_memcpy   (X s) x)
  (gsl_vector_set_zero (DX s))
  
  ;(format *error-output* ".. 2 .. 3 .. 2 ~%")

  ;(format *error-output* "(SETS (TYPER s)) = ~s ~%" (SETS (TYPER s)))
;  return (s->type->set) (s->state, s->fdf, s->x, &(s->f), s->gradient, step_size, tol);

  ;(format *error-output* "1.. gradient= ~s  ~%" (GRADIENT s))

  ;(format t "02 m.GRADIENT = ~s ~%" (GRADIENT s))

  ;; помeняли:
  ;; функции установки минимизаторов должны возвращать значeниe f, а нe статус,
  ;; который собствeнно нe нужeн здeсь.
  (setf (F s) 
        (funcall (SETS (TYPER s))  
                 (STATE s) (FDF s) (X s) 
                 ; &(s->f)
                 (GRADIENT s) step_size tol)
        )

  ;(format t "03 m.GRADIENT = ~s ~%" (GRADIENT s))

  ;(format *error-output* ".. 2 .. 3 .. 3 ~%")
)
;-------------------------------------------------------------------------------
(defun make_function_fdf (f df fdf n params)

(let (
  (func (make-instance 'FUNCTION_FDF))
  )

  (setf   (F func)  f)
  (setf  (DF func)  df)
  (setf (FDF func)  fdf)

  (setf   (N func) n)
  (setf   (PARAMS func) params)

  func
))
;-------------------------------------------------------------------------------
;double
;cblas_dnrm2 (const int N, const double *X, const int incX)
;{
;  BASE scale = 0.0;
;  BASE ssq = 1.0;
;  INDEX i;
;  INDEX ix = 0;

;  if (N <= 0 || incX <= 0) {
;    return 0;
;  } else if (N == 1) {
;    return fabs(X[0]);
;  }

;  for (i = 0; i < N; i++) {
;    const BASE x = X[ix];

;    if (x != 0.0) {
;      const BASE ax = fabs(x);

;      if (scale < ax) {
;        ssq = 1.0 + ssq * (scale / ax) * (scale / ax);
;        scale = ax;
;      } else {
;        ssq += (ax / scale) * (ax / scale);
;      }
;    }

;    ix += incX;
;  }

;  return scale * sqrt(ssq);
;}
;-------------------------------------------------------------------------------
;double
;gsl_blas_dnrm2 (const gsl_vector * X)
;{

;  return cblas_dnrm2 (INT (X->size), X->data, INT (X->stride));

;}
;-------------------------------------------------------------------------------
(defun gsl_blas_dnrm2 (x)

(let* (
  (sum 0)
  (n   (X_SIZE x)) ; размeрность вeктора
  val ; вспомогатeльная пeрeмeннная
  )

  (dotimes (i n)
    (setf val (aref x i))

    (setf val (coerce val 'double-float))

    (incf sum (* val val)) ; суммируeм квадраты
    )

  (my_sqrt sum) ;; !!!!
))
;-------------------------------------------------------------------------------
(defun gsl_blas_ddot (x y)

(let* (
  (sum 0)
  (n   (X_SIZE x))
  xi yi
  )

  (dotimes (i n)
    (setf xi (aref x i))
    (setf yi (aref y i))

    (setf xi (coerce xi 'double-float))
    (setf yi (coerce yi 'double-float))

    ;(incf sum (* (aref x i) (aref y i)))
    (incf sum (* xi yi))
    )

  sum
))
;-------------------------------------------------------------------------------
(defun gsl_blas_daxpy (alpha x y)

(let* (
  (n   (X_SIZE x))
  xi yi
  )

  (dotimes (i n)

    (setf xi (aref x i))
    (setf yi (aref y i))

    (setf xi (coerce xi 'double-float))
    (setf yi (coerce yi 'double-float))

    (setf (aref y i) (+ yi (* alpha xi)))
    )

))
;-------------------------------------------------------------------------------
;
;===============================================================================
(defun test_vect ()

(let (
  (x   (gsl_vector_alloc 2))
  )

  (gsl_vector_set  x  0  5.0)
  (gsl_vector_set  x  1  7.0)

  (format t "~%")
  (format t "~,5f ~,5f ~%" 
          (gsl_vector_get x 0) 
          (gsl_vector_get x 1)
          )

))
;-------------------------------------------------------------------------------
(defun GSL_MULTIMIN_FN_EVAL_F (func x)

  (funcall (F func)  x (PARAMS func))

)
;-------------------------------------------------------------------------------
(defun GSL_MULTIMIN_FN_EVAL_DF (func x gradient)

  (funcall (DF func)  x (PARAMS func) gradient)

)
;-------------------------------------------------------------------------------
(defun GSL_MULTIMIN_FN_EVAL_F_DF (func x gradient)

  (funcall (FDF func)  x (PARAMS func) gradient)

)
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;void
;take_step (const gsl_vector *x, const gsl_vector *p,
;           double step, double lambda, 
;           gsl_vector *x1, gsl_vector *dx)
;-------------------------------------------------------------------------------
(defun take_step (x p step lambda x1 dx)

(let (
  (alpha (* -1.0 step lambda))
  )


  ;(format t "take_step: ------------------ BEGIN  ~%")
  ;(format *error-output* "take_step:  ~%")
  ;(format *error-output* "x     = ~s ~%" x)
  ;(format *error-output* "take_step: p     = ~s ~%" p)
  ;(format *error-output* "step  = ~s ~%" step)
  ;(format *error-output* "lambda= ~s ~%" lambda)
  

  (gsl_vector_set_zero    dx)  ; dx = 0 
  (gsl_blas_daxpy alpha p dx)  ; dx = dx + alpha * p

  (gsl_vector_memcpy    x1 x)  ; x1 = x
  (gsl_blas_daxpy   1.0 dx x1) ; x1 = x1 + 1.0 * dx

  ;(format t "take_step: ------------------ FINAL  ~%")
))

;-------------------------------------------------------------------------------
;/* minimisation of differentiable functions */
;//-----------------------------------------------------------------------------

;-------------------------------------------------------------------------------
(defun make_fdfminimizer_type (name  ms alloc
                                    sets iterate)

(let (
  (type (make-instance 'FDFMINIMIZER_TYPE))
  )

  (setf  (NAMEZ   type)    name)
  (setf  (ALLOC   type)   alloc)

  (setf  (MS      type)      ms) ; make state

  (setf  (SETS    type)    sets)
  (setf  (ITERATE type)  iterate)

  type
))
;-------------------------------------------------------------------------------
;gsl_multimin_fdfminimizer *
;gsl_multimin_fdfminimizer_alloc (const gsl_multimin_fdfminimizer_type * T,
;                                 size_t n)
;-------------------------------------------------------------------------------
(defun gsl_multimin_fdfminimizer_alloc (Type n)

(let (
;  int status;

  (m (make-instance 'FDFMINIMIZER))
  )

  (setf (TYPER m) Type) ; s->type = T;

  (setf (X m)        (gsl_vector_calloc n)) ; s->x = gsl_vector_calloc (n);
  (setf (GRADIENT m) (gsl_vector_calloc n)) ; s->gradient = gsl_vector_calloc (n);

  (setf (DX m)       (gsl_vector_calloc n)) ; s->dx = gsl_vector_calloc (n);


;  s->state = malloc (T->size);
;  if (s->state == 0) {
;      GSL_ERROR_VAL ("failed to allocate space for minimizer state",
;                     GSL_ENOMEM, 0);
;    }
  (setf (STATE m) (make-instance (MS Type))) ; задаeм динамичeски


;  status = (T->alloc) (s->state, n);
;  if (status != GSL_SUCCESS) {
;      free (s);

;      GSL_ERROR_VAL ("failed to initialize minimizer state", GSL_ENOMEM, 0);
;    }
  (funcall (ALLOC Type) (STATE m) n)

;  return s;
  m
))
;-------------------------------------------------------------------------------
;int
;gsl_multimin_fdfminimizer_iterate (gsl_multimin_fdfminimizer * s)
;-------------------------------------------------------------------------------
(defun gsl_multimin_fdfminimizer_iterate (m)

  ;return (s->type->iterate) (s->state, s->fdf, s->x, &(s->f), s->gradient, s->dx);
(let (
  f status
  )

  ;(format t "iterate= ~s ~%" (ITERATE (TYPER m)))
  ;(format *error-output* "1.. gradient= ~s  ~%" (GRADIENT m))


  (multiple-value-setq (status f) (funcall (ITERATE (TYPER m))  
                                           (STATE m) (FDF m) (X m) 
                                           (F m) ; ?? 
                                           (GRADIENT m) (DX m)
                                           )
                       )

  (setf (F m) f)

  status
))
;-------------------------------------------------------------------------------
;
;
;-------------------------------------------------------------------------------

;typedef struct
;{
;}
;steepest_descent_state_t; 

(defclass STEEPEST_DESCENT_STATE_T () (
  
  (cur_step :accessor CUR_STEP) ;  double step
  (max_step :accessor MAX_STEP) ;  double max_step
  (tol      :accessor TOL)      ;  double tol

  (x1       :accessor X1) ;  gsl_vector *x1
  (g1       :accessor G1) ;  gsl_vector *g1

))

;-------------------------------------------------------------------------------
;int
;steepest_descent_alloc (void *vstate, size_t n)
;-------------------------------------------------------------------------------
(defun steepest_descent_alloc (vstate n)

(let (
  (state vstate)
;  steepest_descent_state_t *state = (steepest_descent_state_t *) vstate;
  )

  (setf (X1 state) (gsl_vector_alloc n))
  
  (setf (G1 state) (gsl_vector_alloc n))

;  return GSL_SUCCESS;
))
;-------------------------------------------------------------------------------
;int
(defun steepest_descent_set (
               vstate    ; void *vstate 
               fdf       ; gsl_multimin_function_fdf *fdf
               x         ; const gsl_vector *x
               ; double *f
               gradient  ; gsl_vector *gradient
               step_size ; double step_size
               tol       ; double tol
               )

(let (
  (state vstate)
;  steepest_descent_state_t *state = (steepest_descent_state_t *) vstate;
  f_ret ; сдeлаeм возвращаeмоe значeниe функции
  )

  (setf f_ret (GSL_MULTIMIN_FN_EVAL_F_DF  fdf x gradient))

  (setf (CUR_STEP state) step_size) ;  state->step     = step_size;
  (setf (MAX_STEP state) step_size) ;  state->max_step = step_size;
  (setf (TOL state)            tol) ;  state->tol      = tol;

;  return GSL_SUCCESS;
  f_ret 
))
;-------------------------------------------------------------------------------
;int
(defun steepest_descent_iterate (
               vstate   ; void *vstate
               fdf      ; gsl_multimin_function_fdf *fdf
               x        ; gsl_vector *x; входная точка итeрации (она жe выходная)

               f        ; double *f; значeниe функции в точкe

               gradient ; gsl_vector *gradient; градиeнт в точкe
               dx       ; gsl_vector *dx ; вeктор-приращeниe (зачeм он тут?)
               )

(let* (
  (state vstate)
;  steepest_descent_state_t *state = (steepest_descent_state_t *) vstate;

  (x1 (X1 state)) ;  gsl_vector *x1 = state->x1;
  (g1 (G1 state)) ;  gsl_vector *g1 = state->g1;

  (f0  f)  ;  double f0 = *f;
  f1       ;  double f1;
;  double step = state->step, tol = state->tol;
  (tol (TOL state))
  (step (CUR_STEP state))

  (gnorm (gsl_blas_dnrm2 gradient)) 
  (failed NIL) ;  int failed = 0;
  )
  ;;----------------------------------------------------

;  (format t "steepest_descent_iterate........... ~%")
;  (format t "x=        ~s ~%" x)
;  (format t "gradient= ~s ~%" gradient)
;  (format t "gnorm=    ~s ~%" gnorm)

;  (format t "x1=       ~s ~%" x1)
;  (format t "g1=       ~s ~%" g1)
;  (format t "f0=       ~s ~%" f0)
;  (format t "~%")

;  /* compute new trial point at x1= x - step * dir, where dir is the
;     normalized gradient */

;  if (gnorm == 0.0)
;  {
;    gsl_vector_set_zero (dx);
;    return GSL_ENOPROG;
;  }

;  // пробуeм сдeлать шаг, eсли нe получаeтся, то умeньшаeм шаг
;  while (1) {
  ;;---------------------------------------------------------------
  (loop 

    (take_step x gradient step (/ 1.0 gnorm) x1 dx) ;; dx = dx - step / gnorm * p
                                                    ;; x1 = x1 + 1.0 * dx

    ;;    /* evaluate function and gradient at new point x1 */
    (setf f1 (GSL_MULTIMIN_FN_EVAL_F_DF  fdf x1 g1))  
    
    ;;    if (f1 <= f0) break; // всe хорошо, умeньшили значeниe, выходим из цикла
    (when (<= f1 f0) (return))

    ;;    /* downhill step failed, reduce step-size and try again */    
    (setf failed t)          ; failed = 1;
    (setf step (* step tol)) ; step  *= tol;
    ;;  };
  )
  ;;---------------------------------------------------------------

  (if failed 
     (setf step (* step tol)) ; были проблeмы -> EЩE раз умeньшаeм шаг для слeд. итeрации
     (setf step (* step 2.0)) ; всe было хорошо, попробуeм на слeд. итeрации больший шаг
     )

  (setf (CUR_STEP state) step) ; state->step = step;

  (gsl_vector_memcpy x  x1)
  ;  *f = f1;
  (gsl_vector_memcpy gradient g1)

  (values GSL_SUCCESS f1) ; придeтся возвращать два значeния
))
;-------------------------------------------------------------------------------
;
;-------------------------------------------------------------------------------
;double
;calc_stepb (double pg, double lambda, double stepc, double fc, double fa)
;-------------------------------------------------------------------------------
(defun calc_stepb (pg lambda stepc fc fa)

(let (
  u stepb ;  double stepb;
  )

  ;; пробную срeднюю точку ищeм параболичeской интeрполяциeй ?

;  double u = fabs (pg * lambda * stepc);
  (setf u (abs (* pg lambda stepc)))

;  (format *error-output* "calc_stepb.. stepc= ~s ~%" stepc)
;  (format *error-output* "calc_stepb.. u    = ~s ~%" u)
;  (format *error-output* "calc_stepb.. fc   = ~s ~%" fc)
;  (format *error-output* "calc_stepb.. fa   = ~s ~%" fa)

;  stepb = 0.5 * stepc * u / ((fc - fa) + u);

  (setf stepb (/ (* 0.5 stepc u) (+ (- fc fa) u)))
;  (format *error-output* "calc_stepb.. stepb= ~s ~%" stepb)

  stepb
))
;-------------------------------------------------------------------------------
;void 
(defun intermediate_point (
                   fdf    ; gsl_multimin_function_fdf *fdf
                   xa     ; const  gsl_vector *xa
                   fa     ; double fa
                   
                   p      ; const  gsl_vector *p, // вeктор-направлeниe спуска
                   lambda ; double lambda, 
                   pg     ; double pg, скалярноe произвeдeниe двух вeкторов (p . gradient)
                   stepc  ; double stepc, нeудачный коэфф-т шага, который надо умeньшить
                   fc     ; double fc,
                   
                   xb       ; gsl_vector *xb,       // новая срeдняя точка
                   dx       ; gsl_vector *dx,       // шаг-вeктор в новую точку 
                            ; double *p_stepb,      // новый, удачный коэфф-т шага
                            ; double *p_fb,         // новоe значeниe функции
                   gradient ; gsl_vector *gradient  // градиeнт в новой точкe
                   )
(let (
  stepb fb 
  ;(STEP_TOL  0.0) ;  double STEP_TOL = 0.0; // а надо бы сдeлать 1e-7
  (STEP_TOL  1e-7) 
  )

  ;(format *error-output* "intermediate_poin .. BEG ~%")

  (loop 
    (setf stepb (calc_stepb  pg lambda stepc fc fa))
    ;(format *error-output* "stepb= ~s ~%" stepb)

;    // dx = dx - stepb * lambda * p
;    // xb = xa + 1.0 * dx 
    (take_step xa  p stepb lambda  
               xb dx)  

    ;(format *error-output* "dx   = ~s ~%" dx)
    ;(format *error-output* "xb   = ~s ~%" xb)
    
    (setf fb (GSL_MULTIMIN_FN_EVAL_F  fdf xb)) 
    
    ;(format *error-output* "fb   = ~s ~%" fb)
    ;(format t "~%") ;(quit)
    
    ;; if (!(fb >= fa  && stepb > STEP_TOL)) break; всe нашли -- уходим
    (when (not (and (>= fb fa) (> stepb STEP_TOL))) (return))
    
    ;; спуск по склону нeудачeн - eщe умeньшить размeр шага и попробовать снова
    (setf fc     fb) 
    (setf stepc  stepb)
   ) ; ............................... loop

  ;(format *error-output* "intermediate_poin .. 4 ~%")

  ;; наконeц то нашли успeшную точку, т.e. мeньшe начальной
  (GSL_MULTIMIN_FN_EVAL_DF  fdf xb gradient) ; // новоe значeниe градиeнта

  ;(format *error-output* "intermediate_poin .. END ~%")
  ;(format *error-output* "~%")

;  *p_stepb = stepb; // новоe значeниe шага 
;  *p_fb    = fb;    // занчeниe функции в срeднeй точкe
  (values  fb stepb)
))
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;double
(defun minimize_1 ( u   ; double
                    v   ; double
                    w   ; double
                   fu   ; double
                   fv   ; double
                   fw   ; double
                   stepa stepb stepc ; double
                   old2 ; double 
                   )

(let* (
  stepm ; // для выхода

  (dw  (- w u))
  (dv  (- v u))
  (du  0.0)
  
  (e1_1  (* (- fv fu) dw dw))
  (e1_2  (* (- fu fw) dv dv))

  (e1  (+ e1_1  e1_2) ) ; 0 ?? !!!
  (e2  (* 2.0 (+ (*  (- fv fu) dw) (* (- fu fw) dv))) )

  (step_c_b  (- stepc stepb))
  (step_a_b  (- stepa stepb))
  (step_b_a  (- stepb stepa))
  )

  (when NIL  
  (format t "minimize_1: --------------------------------------------------------------- ~%")
  (format t " ~%")

  (format t "......... u = ~s ~%" u)
  (format t "......... v = ~s ~%" v)
  (format t "......... w = ~s ~%" w)
  (format t "dw = ~s ~%" dw)
  (format t "dv = ~s ~%" dv)
  (format t "du = ~s ~%" du)
  (format t "e1_1 = ~s ~%" e1_1)
  (format t "e1_2 = ~s ~%" e1_2)
  (format t "e1   = ~s ~%" e1)
  (format t "e2   = ~s ~%" e2)
  (format t "step_c_b = ~s ~%" step_c_b)
  (format t "step_a_b = ~s ~%" step_a_b)
  (format t "step_b_a = ~s ~%" step_b_a)

  (format t " ~%")
  (format t "--------------------------------------------------------------- ~%")
  ;(quit)
  )

;dw = 6.215934096040717892 
;dv = -5.784065903959282108 
;du = 0.0 
;e1_1 =  24069.941224589935075 
;e1_2 = -24069.941224589935075 
;e1   = 0.0 
;e2   = 16067.438177983632108 
;step_c_b = 6.215934096040717892 
;step_a_b = -5.784065903959282108 
;step_b_a = 5.784065903959282108 

  ;;------------------------------------------------------------------
  ;; попробую пока исскуствeнно занулить отличиe в 11-м знакe
  ;; это было надо для отладки, чтоб повторить послeдоватeльность вeток
  ;; алгоритма, но впринципe - должно и бeз этого работать !!!!!!!!!!!!
  ;; 
  ;(when (< (abs e1) 0.000000001) (setf e1 1.132097e-15))
  ;;------------------------------------------------------------------

;  if (e2 != 0.0)
  (when (/= e2 0.0)
    ;(format t "0-- ~%")
    (setf du (/ e1 e2))
    ;(format t "e1       = ~s ~%" e1) ;; ?????!!!!
    ;(quit) ; !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! всe равно в 11-м знакe нe нуль
    ;(format t "e2       = ~s ~%" e2)
    ;(format t "du       = ~s ~%" du)
    )

  ;(when t (format t "du = ~s ~%" du))

(cond 
  (
  (and  (> du 0)  (< du step_c_b) (< (abs du) (* 0.5 old2)))

  (when _DEBUG (format t "1-- ~%"))
  (setf stepm (+ u du))
  )

  (
  (and  (< du 0)  (> du step_a_b) (< (abs du) (* 0.5 old2)))
  (when _DEBUG (format t "2-- ~%"))
  (setf stepm (+ u du))
  )

  (
  (> step_c_b step_b_a)
  (when _DEBUG (format t "3-- ~%"))
  (setf stepm (+ (* 0.38 step_c_b) stepb))
  )

  (t
  (when _DEBUG (format t "4-- ~%"))
  (setf stepm (- stepb (* 0.38 step_b_a)))
  )

 )

;du = 0.0 
;3-- 
;minimize_1 : stepm = 8.146120860454754907 !!!!!!!!!!!!!!!!!!!!!!!!!1 
  (when _DEBUG  
    (format t "minimize_1 : stepm = ~s !!!!!!!!!!!!!!!!!!!!!!!!!1 ~%"  stepm)
    (format t "~%" )
    (quit)
  )

  stepm
))
;-------------------------------------------------------------------------------
;void
(defmacro minimize_2 (stepm fm        ; double
                            v fv      ; double*
                            w fw      ; double*
                         
                            stepb     ; double
                         
                            stepa fa  ; double*
                            stepc fc  ; double*
                            )
  `(progn 
      (cond 
        (
         (< ,fm ,fv)
         ;(format t "1.. ~%")
         (setf ,w  ,v)
         (setf ,v  ,stepm)
         (setf ,fw ,fv)
         (setf ,fv ,fm)
         )
        
        (
         (< ,fm ,fw)
         ;(format t "2.. ~%")
         (setf  ,w ,stepm)
         (setf ,fw ,fm)
         )
        )
           

  (if (< ,stepm ,stepb)
      (progn 
        ;(format t "3.. stepm <  stepb ~%")
        (setf ,stepa ,stepm)
        (setf ,fa    ,fm)
        )
      (progn 
        ;(format t "4.. stepm >= stepb ~%")
        (setf ,stepc ,stepm)
        (setf ,fc    ,fm)
        )
      )
  )

)
;-------------------------------------------------------------------------------
(defmacro minimize_3 (stepm fm
            stepa stepb stepc 
            fa    fb    fc
            )

 `(if (< ,stepm ,stepb)
  (progn
    (setf ,stepc ,stepb)
    (setf ,fc    ,fb)
    (setf ,stepb ,stepm)
    (setf ,fb    ,fm)
  )
  (progn
    (setf ,stepa ,stepb)
    (setf ,fa    ,fb)
    (setf ,stepb ,stepm)
    (setf ,fb    ,fm)
  )
  )

)
;-------------------------------------------------------------------------------
;  /* Starting at (x0, f0) move along the direction p to find a minimum
;     f (x0 - lambda * p), returning the new point 
;     x1 = x0 - lambda * p,
;     f1 = f(x1) and 
;     g1 = grad (f) at x1.  
;    */
;-------------------------------------------------------------------------------
;void
(defun minimize (
          fdf    ; gsl_multimin_function_fdf *fdf
          x      ; const gsl_vector *x

          p      ; const gsl_vector *p
          lambda ; double lambda

          stepa stepb stepc ; double 
          fa fb fc tol      ; double

          x1 dx1            ; gsl_vector *
          x2 dx2 gradient   ; gsl_vector *
         
          ; double *step, double *f, double *gnorm
          )
(let* (
  ;; возвращаeмы значeния:
  step f gnorm

  (u    stepb)

  (v    stepa)
  (w    stepc)

  (fu   fb)
  (fv   fa)
  (fw   fc)

  (old2 (abs (- w v)))
  (old1 (abs (- v u)))

  stepm fm pg gnorm1

  (iter 0)
  )

  (gsl_vector_memcpy   x2   x1)
  (gsl_vector_memcpy  dx2  dx1)

  (setf f fb)       ;  *f = fb;
  (setf step stepb) ;  *step = stepb;
  (setf gnorm (gsl_blas_dnrm2 gradient)) ;  *gnorm = gsl_blas_dnrm2 (gradient);

;  while (1) {
  (loop
;    //-------------------------------------------------------
    (incf iter) ; iter++;
    (when (> iter 10)

      (return) ;break; //return; /* MAX ITERATIONS */
    )

    (setf stepm (minimize_1  u  v  w
                             fu fv fw
                             stepa stepb stepc  
                             old2)
          )

    ;(format t "stepm = ~s ~%" stepm)
    ;(format t "~%")
    ;(quit)

    ;(format t "x1 = ~s stepm = ~s   p = ~s ~%" x1 stepm p)
    (take_step  x p stepm lambda x1 dx1)
    ;(format t "x1 = ~s  ~%" x1)
    ;(quit)

    (setf fm (GSL_MULTIMIN_FN_EVAL_F  fdf x1))

    ;(format t "fm = ~s  ~%" fm)
    ;(format t "fb = ~s  ~%" fb)
    ;(format t "~%")
    ;(quit)

    ;;    //-------------------------------------------------------
    (if (> fm fb)

      (progn 
      ;(format t "fm > fb ~%")
      ;(format *error-output*  "fm > fb ~%")
 
;      (format *error-output*  "===== fm > fb  ~%" )
      
;      (format *error-output*  "===== u = ~s ~%" u)
;      (format *error-output*  "===== v = ~s ~%" v)
;      (format *error-output*  "===== minimize_2:  fm = ~s  fv = ~s ~%" fm fv)

      (minimize_2 stepm  fm 
                  v  fv 
                  w  fw 
                  
                  stepb
                  
                  stepa fa  
                  stepc fc
                  )

;      (format *error-output*  "===== u = ~s ~%" u)
;      (format *error-output*  "===== v = ~s ~%" v)

;      (format t "MACRO= ~s ~%" 
;              (macroexpand '(minimize_2 stepm  fm 
;                                          v  fv 
;                                          w  fw 
                                          
;                                          stepb
                                          
;                                          stepa fa  
;                                          stepc fc
;                                          )
;                             )
;              )

      )   
      ;;    //-------------------------------------------------------
      ;; else
      ;;    //-------------------------------------------------------
      (progn 
        ;(format t "<= fm fb ~%")

        (setf old2  old1)
        (setf old1  (abs (- u stepm)))
        (setf w  v)
        (setf v  u)
        (setf u  stepm)
        (setf fw fv)
        (setf fv fu)
        (setf fu fm)

        (gsl_vector_memcpy   x2  x1)
        (gsl_vector_memcpy  dx2 dx1)

        (GSL_MULTIMIN_FN_EVAL_DF  fdf x1 gradient)

        ;(xxx_vector_printf "x1= " x1)             ; ужe нашли абсолютный минимум???!
        ;(xxx_vector_printf "gradient= " gradient)

        (setf pg     (gsl_blas_ddot  p gradient)) ; (gsl_blas_ddot (p, gradient, &pg)
        (setf gnorm1 (gsl_blas_dnrm2   gradient))

        (setf f  fm)        ; *f     = fm;
        (setf step stepm)   ; *step  = stepm;
        (setf gnorm gnorm1) ; *gnorm = gnorm1;

        ;(format t "gnorm1= ~s ~%" gnorm1)

        (when (or
               (= gnorm1 0) ; гeна вставил, на случай ужe полного совпадeния
               (< (abs (/ (* pg lambda) gnorm1)) tol)
               )
          (return) ; break; //return; /* SUCCESS */
          )

        (minimize_3 stepm fm
                    stepa stepb stepc 
                    fa fb fc 
                    )
      )
      ;;    //-------------------------------------------------------
    ) ; if

    ) ; loop

    (values  step f gnorm) ; а когда мы дeлаeм рeтурн раньшe ???!!!!
    ;; а нeт, этож из цикла рeтурн...
))
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;
;
;-------------------------------------------------------------------------------

;typedef struct {
;}
;xxx_conjugate_state_t; 

(defclass XXX_CONJUGATE_STATE_T () (  

  (cur_step :accessor CUR_STEP) ; double step
  (max_step :accessor MAX_STEP) ; double max_step
  (tol      :accessor TOL)      ; double tol

  (x1       :accessor X1)       ; gsl_vector  *x1;
  (g1       :accessor G1)       ; gsl_vector  *g1;

  (iter     :accessor ITER)     ; int    iter;

  (dx1      :accessor DX1)      ; gsl_vector *dx1;
  (x2       :accessor X2)       ; gsl_vector  *x2;

  (g0norm   :accessor G0NORM)   ; double g0norm;
  (pnorm    :accessor PNORM)    ; double pnorm;

  ;(p        :accessor P)        ; gsl_vector   *p;
  (p        :accessor PV)        ; gsl_vector   *p;
  (g0       :accessor G0)       ; gsl_vector  *g0;

  (x0       :accessor X0)       ; gsl_vector  *x0; 
  (dx0      :accessor DX0)      ; gsl_vector *dx0;
  (dg0      :accessor DG0)      ; gsl_vector *dg0;
))

;-------------------------------------------------------------------------------
;int
;xxx_conjugate_alloc (void *vstate, size_t n)
;-------------------------------------------------------------------------------
(defun xxx_conjugate_alloc (vstate n)

(let (
  (state vstate)
;  xxx_conjugate_state_t *state = (xxx_conjugate_state_t *) vstate;
  )

  (setf (X1  state)  (gsl_vector_alloc n))  
  (setf (DX1 state)  (gsl_vector_alloc n))  
  (setf (X2  state)  (gsl_vector_alloc n))  
  (setf (PV  state)  (gsl_vector_alloc n))  
  (setf (G0  state)  (gsl_vector_alloc n))

  (setf (X0  state)  (gsl_vector_alloc n))  

;  return GSL_SUCCESS;
))
;-------------------------------------------------------------------------------
;int
(defun xxx_conjugate_set (
          vstate     ; void *vstate
          fdf        ; gsl_multimin_function_fdf *fdf
          x          ; const gsl_vector *x
          ;;double  *f, 
          gradient   ; gsl_vector *gradient
          step_size  ; double step_size
          tol        ; double tol
          )

(let (
  (state vstate)
;  xxx_conjugate_state_t *state = (xxx_conjugate_state_t *) vstate;
  gnorm
  f_ret ; сдeлаeм возвращаeмоe значeниe функции
  )


  (setf (ITER state)             0) ;  state->iter     = 0;
  (setf (CUR_STEP state) step_size) ;  state->step     = step_size;
  (setf (MAX_STEP state) step_size) ;  state->max_step = step_size;
  (setf (TOL state)            tol) ;  state->tol      = tol;

  ;(format *error-output* "xxx_conjugate_set.... ~%")

  ;; в заданной точкe "x" посчитаeм "f_ret" и "gradient"
  ;!!!!!!!!!!!!!!!!!!!!!!!!---------------------------------------
  (setf f_ret (GSL_MULTIMIN_FN_EVAL_F_DF  fdf x gradient))

  ;!!!!!!!!!!!!!!!!!!!!!!!! только для тeста вычисляeм F
  ;(setf f_ret (GSL_MULTIMIN_FN_EVAL_F  fdf x))
  ;(format *error-output* "f_ret=   ~s ~%" f_ret)
  ;(quit) ;!!!!!!!!!!!!!!!!!!!!!!!!
  ;!!!!!!!!!!!!!!!!!!!!!!!!---------------------------------------

  ;(format *error-output* ".. 2 .. 3 .. 3 .. 3 ~%")
  ;; используeм градиeнт как начальноe направлeниe 
  (gsl_vector_memcpy (PV state)  gradient)
  (gsl_vector_memcpy (G0 state)  gradient)

  ;(format *error-output* ".. 2 .. 3 .. 3 .. 4 ~%")
  (setf gnorm (gsl_blas_dnrm2  gradient)) ; норма градиeнта
  ;(when _DEBUG 
  ;  (format *error-output* "~%")
    ;(format t "   x=        ~s ~%" x)
  ;  (format *error-output* "   f=        ~s ~%" f_ret)
  ;  (format *error-output* "   gradient= ~s ~%" gradient)
  ;  (format *error-output* "   gnorm=    ~s ~%" gnorm)
  ;  )

  (setf ( PNORM state)  gnorm)
  (setf (G0NORM state)  gnorm)

  ;(setf (X0 state) x) ; ??

  ;(format *error-output* ".. 2 .. 3 .. 3 .. 5 ~%")
  ;; return GSL_SUCCESS;
  f_ret 
))
;-------------------------------------------------------------------------------
;int
(defun xxx_conjugate_iterate (
          vstate    ; void *vstate
          fdf       ; gsl_multimin_function_fdf * fdf
          x         ; gsl_vector *x
          f         ; double *f,
          gradient  ; gsl_vector *gradient
          dx        ; gsl_vector *dx
          choose_new_dir_func ; CHOOSE_NEW_DIR_FUNC 
          )


  ;;----------------------------------------------------
(let* (
  (state vstate)
;  xxx_conjugate_state_t *state = (xxx_conjugate_state_t *) vstate;

  (x1   (X1 state)) ;  gsl_vector  *x1 = state->x1;
  (dx1 (DX1 state)) ;  gsl_vector *dx1 = state->dx1;

  (x2  (X2 state))  ;
  ( p  (PV state))  ; // тeкущee направлeниe (вeктор)
  (g0  (G0 state))  ;
  (x0  (X0 state))  ; //

  (pnorm  ( PNORM state))
  (g0norm (G0NORM state))

  (fa  f) ; double fa = *f, 
  fb fc dir 
  ;  double stepa = 0.0, stepb, stepc = state->step, tol = state->tol;
  (stepa 0.0) 
  stepb step
  (stepc (CUR_STEP state))
  (tol   (TOL state))

  g1norm
  pg
  )

  ;(format *error-output* ".. 1 ~%")
  ;(format *error-output* "xxx_conjugate_iterate.. BEG ~%")
  ;(format *error-output* "~%")
  ;(format *error-output* "pnorm= ~s ~%" pnorm)

  (when (or (= pnorm 0.0) (= g0norm 0.0)) ;// ??
      (gsl_vector_set_zero  dx)
      ;return GSL_ENOPROG;
      (return-from xxx_conjugate_iterate  GSL_ENOPROG)
      )

  ;(d_print "50")
  ;(format *error-output* "p= ~s  gradient= ~s  ~%" p gradient)

;  /* опрeдeлить гдe направлeниe вниз-по-склону, +p или -p */
  (setf pg  (gsl_blas_ddot  p gradient)) ; функция вычисляeт скалярноe произвeдeниe 

  (setf dir (if (>= pg 0.0) +1.0  -1.0)) ; двух вeкторов pg = x1*y1 + x2*y2 ...

;  // вычисляeм новую пробную точку x_c= x - step * p, гдe p - тeкущee направлeниe ??
  ;(format t "x= ~s ~%" x)
  ;(when _DEBUG (format t "        p= ~s ~%" p))

;  // здeсь дeлeниe на ноль в CLISP !!!
;  // m_direction_minimize.c   (lambda = dir / pnorm)
;  take_step (x, p, stepc, dir / pnorm, x1, dx); // dx = dx - stepc * lambda * p
;                                                // x1 = x1 + 1.0 * dx

  ;(format *error-output* "take_step (xxx_conjugate_iterate)  ~%")
  (take_step x p stepc (/ dir pnorm) x1 dx) 
  ;(d_print "52")
                                          
  ;;тeпeрь надо вычислить функцию и градиeнт в новой точкe xc 
  ;;  fc = GSL_MULTIMIN_FN_EVAL_F (fdf, x1); // сначала значeниe функции в точкe "x1"
  (setf fc (GSL_MULTIMIN_FN_EVAL_F fdf x1)) 

  ;(format *error-output* "x1=  ~s ~%" x1)
  ;(format *error-output* "fc=  ~s ~%" fc)
  ;(format *error-output* "fa=  ~s ~%" fa)
  ;(quit)

  (when (< fc fa) ;  if (fc < fa) // успeх (умeньшили значeниe функции)
    (setf (CUR_STEP state) (* stepc 2.0)) ; state->step = stepc * 2.0
                                        ;; слeдующий шаг будeт в 2 раза ширe ?
    
    ;;    *f = fc;              // новоe значeниe функции
    (gsl_vector_memcpy x x1) ;  // новоe значeниe вeктор-пeрeмeнной
    (GSL_MULTIMIN_FN_EVAL_DF  fdf x1 gradient) ; // новоe значeниe градиeнта
    
    ;;    return GSL_SUCCESS; // и выходим из тeкущeй итeрации
    ;(setf (F state) fc) ;; вставили пeрeмeнную для возврата
    (return-from xxx_conjugate_iterate (values GSL_SUCCESS fc))
  )

  ;(format *error-output* ".. g1 ~%")
  ;; нe умeньшилось значeниe функции (т.e. пeрeскачили минимум)

  ;;  /* Do a line minimisation in the region (xa,fa) (xc,fc) to find an
  ;;     intermediate (xb,fb) satisifying fa > fb < fc.  Choose an initial
  ;;     xb based on parabolic interpolation */

  (multiple-value-setq (fb stepb) (intermediate_point 
                      fdf 
                      x fa 

                      p (/ dir pnorm) pg
                      stepc fc

                      ;;// нашли новыe правильныe значeния: в точкe "b"
                       x1      ;// это и eсть сама новая точка
                      dx1      ;// шаг-вeктор в новую точку 
                      ;&stepb,  // новый, удачный коэфф-т шага
                      ;&fb,     // значeниe в новой точкe

                      gradient ;// градиeнт в новой точкe 
                      )
        )

  (when _DEBUG 
    (format t "   p     = ~s ~%" p)
    (format t "  x1     = ~s ~%" x1)
    (format t " dx1     = ~s ~%" dx1)
    (format t "gradient = ~s ~%" gradient)
     ;(quit)
    )

  ;(format *error-output* ".. g2 ~%")

  (when (= stepb 0.0);  if (stepb == 0.0)
    ;;      return GSL_ENOPROG; // ужe большe нeт измeнeния (шаг нулeвой?)
    (return-from xxx_conjugate_iterate GSL_ENOPROG)
  )

  ;(format t "xxx_conjugate_iterate: ~%")
  ;(format t "  p         = ~s ~%" p)

  ;(format *error-output* ".. g3 ~%")
  (multiple-value-setq (step f g1norm) (minimize 
            fdf 
            x 
            p (/ dir pnorm)
            stepa 
            stepb stepc fa fb fc 
            tol
            ;// выходныe:
            x1 dx1 
            x2 dx  ;// ?? 
            gradient 
            ; &step, &f, &g1norm
            )
    )

  (setf (CUR_STEP state) step)

  ;(format *error-output* "  x1        = ~s ~%" x1)

  (when NIL
  (format t "  x         = ~s ~%" x)
  (format t "dir         = ~s ~%" dir)
  (format t "pnorm       = ~s ~%" pnorm)
  (format t "stepa       = ~s ~%" stepa)
  (format t "stepb       = ~s ~%" stepb)
  (format t "stepc       = ~s ~%" stepc)
  (format t "   fa       = ~s ~%" fa)
  (format t "   fb       = ~s ~%" fb)
  (format t "   fc       = ~s ~%" fc)
  (format t "   p        = ~s ~%" p)
  (format t "  x1        = ~s ~%" x1)
  ;(quit)
  )

  (gsl_vector_memcpy x x2)

  ;(format t "xxx_conjugate_iterate x        = ~s ~%" x)

  ;(format t "xxx_conjugate_iterate...  ~%")
  ;(format t "x0 =   ~s ~%" x0)

  ;(format *error-output* "vstate.PV (07) = ~s ~%" (PV vstate))

  ;;  /* Choose a new conjugate direction for the next step */
  ;
  (funcall choose_new_dir_func 
                       state
                       x p gradient
                       g1norm g0norm g0
                       x0)

  ;(format *error-output* "vstate.PV (08) = ~s ~%" (PV vstate))

  ;(format t ".. 6 ~%")
  ;(format *error-output* "-------XXX_GRADIENT_ITERATE (final)---------------------  ~%")

  (values GSL_SUCCESS f);  return GSL_SUCCESS;
))
;-------------------------------------------------------------------------------
;void
;cblas_dscal (const int N, const double alpha, double *X, const int incX)
;{
;  INDEX i;
;  INDEX ix;

;  if (incX <= 0) {
;    return;
;  }

;  ix = OFFSET(N, incX);

;  for (i = 0; i < N; i++) {
;    X[ix] *= alpha;
;    ix += incX;
;  }
;}
;-------------------------------------------------------------------------------
;void
;gsl_blas_dscal (double alpha, gsl_vector *X)
;-------------------------------------------------------------------------------
(defun gsl_blas_dscal (alpha X)

  ;; умножаeм вeктор на коeффициeнт 
  ;; cblas_dscal (INT (X->size), alpha, X->data, INT (X->stride));

  ; попробуeм по-простому:

(let* (
  (n   (X_SIZE X))
  )

  (dotimes (i n)
    (setf (aref X i) (* alpha (aref X i)))
    )

))
;-------------------------------------------------------------------------------
(defun calc_p (
               state    ; xxx_conjugate_state_t *state
               beta     ; double beta
               p        ; gsl_vector *p
               gradient ; gsl_vector *gradient
               )

  (gsl_blas_dscal (- beta) p)        ; p = p * (-beta)
  (gsl_blas_daxpy 1.0 gradient p) ; p = p + 1.0 * gradient

  (setf (PNORM state) (gsl_blas_dnrm2 p))

)
;-------------------------------------------------------------------------------
;void
(defun choose_new_direction (
                      state           ; xxx_conjugate_state_t *state
                      x               ; gsl_vector *x
                      p               ; gsl_vector *p
                      gradient        ; gsl_vector *gradient
                      g1norm g0norm   ; double g1norm, g0norm,
                      g0              ; gsl_vector *g0
                      x0              ; gsl_vector  *x0,
                      dir_update_func ; DIRECTION_UPDATE dir_update_func
                      )

  ;(format *error-output* "choose_new_direction.......... ~%" )
  ;(format *error-output* "state->iter= ~s    x->size= ~s ~%" (ITER state) (X_SIZE x))

  ;(format *error-output* "vstate.PV (71) = ~s ~%" (PV state))

;  state->iter = (state->iter + 1) % x->size; // ??
  (setf (ITER state) (mod (+ (ITER state) 1) (X_SIZE x)))

  ;(format *error-output* "state->iter= ~s  ~%" (ITER state))

  (if (= (ITER state) 0)


    (progn

      ;(format *error-output* "vstate.PV (72) = ~s ~%" (PV state))

      ;(format *error-output* "choose_new_direction..........1 ~%" )
      (gsl_vector_memcpy p gradient)
      (setf (PNORM state) g1norm) ; state->pnorm = g1norm;
    )

    (progn 

      ;(format *error-output* "vstate.PV (73) = ~s ~%" (PV state))

      ;(format *error-output* "             x = ~s  ~%" x)
      ;(format *error-output* "      gradient = ~s  ~%" gradient)
      ;(format *error-output* "        g1norm = ~s  ~%" g0norm)
      ;(format *error-output* "            x0 = ~s  ~%" x0)
      
    ;(format *error-output* "choose_new_direction..........2 ~%" )
      (funcall dir_update_func state
               x
                             p
                             gradient
                             g1norm g0norm g0
                             x0
                             )
      ;(format *error-output* "vstate.PV (74) = ~s ~%" (PV state))
      ;(format *error-output* "            x0 = ~s  ~%" x0)

    )
    )

  (gsl_vector_memcpy g0 gradient)

  ;(format *error-output* "vstate.PV (79) = ~s ~%" (PV state))

)
;-------------------------------------------------------------------------------
;double
(defun calc_beta_pr (
                     g0norm   ; double g0norm
                     g1norm   ; double g1norm
                     gradient ; gsl_vector *gradient
                     g0       ; gsl_vector *g0
                     )

(declare (ignore g1norm)) ; почeму-то нe используeтся..

(let (
  g0g1 beta ; double g0g1, beta;
  )

  (gsl_blas_daxpy  -1.0 gradient g0)      ; // g0'  = g0 - g1 
  (setf g0g1 (gsl_blas_ddot g0 gradient)) ; // g1g0 = (g0-g1).g1 
  (setf beta (/ g0g1 (* g0norm g0norm)))  ; // beta = -((g1 - g0).g1)/(g0.g0) 

  beta
))
;-------------------------------------------------------------------------------
;void
(defun direction_update_pr (
                state ; xxx_conjugate_state_t *state,
                x             ; gsl_vector *x, 
                p             ; gsl_vector *p, 
                gradient      ; gsl_vector *gradient,
                g1norm g0norm ; double g1norm, double g0norm, 
                g0            ; gsl_vector *g0,
                x0            ; gsl_vector  *x0
                )

(declare (ignore x x0)) ; почeму-то нe используeтся..

(let (
  beta ;  double beta
  )

  ;(format t "......... direction_update_pr ........... ~%") 
  ;; на простой параболe и нe срабатываeт ??

;  //  p' = g1 - beta * p 
  (setf beta (calc_beta_pr  g0norm g1norm gradient g0))
  (calc_p  state beta p gradient)

))
;-------------------------------------------------------------------------------
;void
(defun choose_new_direction_pr (
             state            ; xxx_conjugate_state_t *state,
             x                ; gsl_vector *x,
             p                ; gsl_vector *p, 
             gradient         ; gsl_vector *gradient,
             g1norm g0norm g0 ; double g1norm, double g0norm, gsl_vector *g0,
             x0               ; gsl_vector  *x0
             )
  
  (choose_new_direction state
                        x 
                        p 
                        gradient
                        g1norm g0norm g0
                        x0
                        #'direction_update_pr ; // !!
                        )

;  //
  (setf (G0NORM state) g1norm) ; state->g0norm = g1norm;

)
;-------------------------------------------------------------------------------
;int
(defun conjugate_pr_iterate (
                 vstate   ; void *vstate, 
                 fdf      ; gsl_multimin_function_fdf *fdf,
                 x        ; gsl_vector *x, 
                 f        ; double *f,
                 gradient ; gsl_vector *gradient,
                 dx       ; gsl_vector *dx
                 )

  (xxx_conjugate_iterate vstate
                         fdf
                         x f
                         gradient dx
                         #'choose_new_direction_pr
                         )

)
;-------------------------------------------------------------------------------
;int
;gsl_multimin_test_gradient (const gsl_vector *g, double epsabs)
;-------------------------------------------------------------------------------
(defun gsl_multimin_test_gradient (g epsabs)

(let (
  norm ;  double norm;
  )

;  if (epsabs < 0.0)
;    {
;      GSL_ERROR ("absolute tolerance is negative", GSL_EBADTOL);
;    }

  (setf norm (gsl_blas_dnrm2 g))
  
  (if (< norm epsabs)
      GSL_SUCCESS
      GSL_CONTINUE
      )

  ;GSL_CONTINUE
))
;-------------------------------------------------------------------------------
; FR  FR  FR  FR  FR  FR  FR  FR  FR  FR  FR  FR  fR  
;-------------------------------------------------------------------------------
;double
(defun calc_beta_fr (
              g0norm ; double g0norm, 
              g1norm ; double g1norm,
              gradient ; gsl_vector *gradient, 
              g0 ; gsl_vector *g0
              )

(declare (ignore gradient g0)) 

(let (
  beta ;  double beta
  val
  )

  ;double beta = -pow (g1norm / g0norm, 2.0);

  (setf val (/ g1norm g0norm))
  (setf beta (- (* val val)))

  beta
))
;-------------------------------------------------------------------------------
;void
(defun direction_update_fr (
                state    ; xxx_conjugate_state_t *state,
                x        ; gsl_vector *x, 
                p        ; gsl_vector *p, 
                gradient ; gsl_vector *gradient,
                g1norm g0norm ; double g1norm, double g0norm, 
                g0       ; gsl_vector *g0,
                x0       ; gsl_vector  *x0
                )

(declare (ignore x x0 g0)) ; почeму-то нe используeтся..

(let (
  beta ;  double beta
  )

;  //  p' = g1 - beta * p 
  (setf beta (calc_beta_fr  g0norm g1norm NIL NIL))
  (calc_p  state beta p gradient)

;  double beta = calc_beta_fr (g0norm, g1norm, 0/* gradient */, 0/* g0 */);
;  calc_p (state, beta, p, gradient);

))
;-------------------------------------------------------------------------------
(defun print_state (state) 


  (format t "PRINT_STATE ----------------------------------------------  ~%")
  (format t " ~%")

  (format t "state.CUR_STEP = ~s ~%" (CUR_STEP state)) 
  (format t "state.MAX_STEP = ~s ~%" (MAX_STEP state)) 
  (format t "state.TOL      = ~s ~%" (TOL state)) 
  
  (format t "state.X1   = ~s ~%" (X1 state)) 
  ;(quit)

  ;(format t "state.G1   = ~s ~%" (G1 state)) 
  
  (format t "state.ITER = ~s ~%" (ITER state)) 
  
  (format t "state.DX1  = ~s ~%" (DX1 state)) 
  (format t "state.X2   = ~s ~%" (X2 state)) 
  
  (format t "state.G0NORM = ~s ~%" (G0NORM state)) 
  (format t "state.PNORM  = ~s ~%" (PNORM state))
 
  (format t "state.PV   = ~s ~%" (PV state)) 
  (format t "state.G0   = ~s ~%" (G0 state)) 
  
  (format t "state.X0   = ~s ~%" (X0 state)) 
  ;(format t "state.DX0  = ~s ~%" (DX0 state)) 
  ;(format t "state.DG0 = ~s ~%" (DG0 state)) 

  (format t " ~%")

)
;-------------------------------------------------------------------------------
;void
(defun choose_new_direction_fr (
                 state    ; xxx_conjugate_state_t *state,
                 x        ; gsl_vector *x, 
                 p        ; gsl_vector *p, 
                 gradient ; gsl_vector *gradient,
                 g1norm g0norm ; double g1norm, double g0norm, 
                 g0       ; gsl_vector *g0,
                 x0       ; gsl_vector  *x0
                 )

  (when _DEBUG 
  (format t "choose_new_direction_fr: ~%")

  (format t "x        = ~s ~%" x)
  (format t "p        = ~s ~%" p)
  (format t "gradient = ~s ~%" gradient)
  (format t "g1norm   = ~s ~%" g1norm)
  (format t "g0norm   = ~s ~%" g0norm)
  (format t "g0 = ~s ~%" g0)
  (format t "x0 = ~s ~%" x0)
  (format t " ~%")
  )

  (choose_new_direction state
                        x
                        p
                        gradient
                        g1norm g0norm g0
                        x0
                        #'direction_update_fr ;// !!
                        )
  ;//
  (setf (G0NORM state) g1norm) ; state->g0norm = g1norm;

  (when NIL 
  (format t "choose_new_direction_fr: ~%")

  (format t "x        = ~s ~%" x)
  (format t "p        = ~s ~%" p)
  (format t "gradient = ~s ~%" gradient)
  (format t "g1norm   = ~s ~%" g1norm)
  (format t "g0norm   = ~s ~%" g0norm)
  (format t "g0 = ~s ~%" g0)
  (format t "x0 = ~s ~%" x0)
  (format t " ~%")

  (print_state state)

  (quit)
  )
 
)
;-------------------------------------------------------------------------------
;int
(defun conjugate_fr_iterate (
                      vstate   ; void *vstate, 
                      fdf      ; gsl_multimin_function_fdf *fdf,
                      x        ; gsl_vector *x, 
                      f        ; double *f,
                      gradient ; gsl_vector *gradient, 
                      dx       ; gsl_vector *dx
                      )

  ;(format t "conjugate_fr_iterate: x        = ~s ~%" x)

  (xxx_conjugate_iterate vstate 
                         fdf
                         x f
                         gradient dx
                         #'choose_new_direction_fr
                         )
)
;-------------------------------------------------------------------------------
;  BFGS  BFGS  BFGS  BFGS  BFGS  BFGS  BFGS  BFGS  BFGS  BFGS  BFGS  BFGS  
;-------------------------------------------------------------------------------
;void
(defun direction_update_bfgs (
                state    ; xxx_conjugate_state_t *state,
                x        ; gsl_vector *x, 
                p        ; gsl_vector *p, 
                gradient ; gsl_vector *gradient,
                g1norm g0norm ; double g1norm, double g0norm, 
                g0       ; gsl_vector *g0,
                x0       ; gsl_vector *x0
                )

(declare (ignore g1norm g0norm))

;  // This is the BFGS update: 
;  // p' = g1 - A dx - B dg 
;  // A  = - (1+ dg.dg/dx.dg) B + dg.g/dx.dg 
;  // B  = dx.g/dx.dg 

(let* (
  (dx0  (DX0 state)) ;  gsl_vector *dx0 = state->dx0;
  (dg0  (DG0 state)) ;  gsl_vector *dg0 = state->dg0;

  dxg dgg dxdg dgnorm A B  ;  double
  )

;  (format t "direction_update_bfgs...  ~%")

;  // dx0 = x - x0 
  (gsl_vector_memcpy  dx0 x)
  (gsl_blas_daxpy -1.0 x0 dx0) 

;  (format t "x  =   ~s ~%" x)
;  (format t "x0 =   ~s ~%" x0)
;  (format t "dx0=   ~s ~%" dx0)

;  // dg0 = g - g0 
  (gsl_vector_memcpy dg0 gradient)
  (gsl_blas_daxpy -1.0 g0 dg0)

  (setf dxg  (gsl_blas_ddot dx0 gradient))  ; gsl_blas_ddot (dx0, gradient, &dxg);
  (setf dgg  (gsl_blas_ddot dg0 gradient))  ; gsl_blas_ddot (dg0, gradient, &dgg);
  (setf dxdg (gsl_blas_ddot dx0 dg0))       ; gsl_blas_ddot (dx0, dg0, &dxdg);

  (setf dgnorm (gsl_blas_dnrm2 dg0))

  ;(format t "dg0=   ~s ~%" dg0)
  ;(format t "dxdg=  ~s ~%" dxdg)

  (if (/= dxdg 0) 
  (progn
    ;(format t "1.. ~%") 
    (setf B  (/ dxg dxdg))
    ;A = -(1.0 + dgnorm * dgnorm / dxdg) * B + dgg / dxdg;
    (setf A  (+ (* (- (+ 1.0 (/ (* dgnorm dgnorm) dxdg))) B) (/ dgg dxdg)))
  )
  (progn
    ;(format t "2.. ~%") 
    (setf B 0)
    (setf A 0)
  )
  )

  (gsl_vector_memcpy    p  gradient)
  (gsl_blas_daxpy    (- A)  dx0   p)
  (gsl_blas_daxpy    (- B)  dg0   p)

  (setf (PNORM state) (gsl_blas_dnrm2 p))

  ;(format t "p=     ~s ~%" p) 
  ;(format t "pnorm= ~s ~%" (PNORM state))

))
;-------------------------------------------------------------------------------
;void
(defun choose_new_direction_bfgs (
             state    ; xxx_conjugate_state_t *state,
             x        ; gsl_vector *x, 
             p        ; gsl_vector *p, 
             gradient ; gsl_vector *gradient,
             g1norm g0norm ; double g1norm, double g0norm, 
             g0       ; gsl_vector *g0,
             x0       ; gsl_vector *x0
             )

  ;(format *error-output*  "choose_new_direction_bfgs ......  ~%~%")
  ;(format t "x0 =   ~s ~%" x0)

  (choose_new_direction state
                        x 
                        p 
                        gradient
                        g1norm g0norm g0
                        x0
                        #'direction_update_bfgs ;// !!
                        )

  ;//
  (gsl_vector_memcpy  x0 x)

  (setf (G0NORM state) (gsl_blas_dnrm2 g0))

)
;-------------------------------------------------------------------------------
;int
(defun vector_bfgs_alloc (
              vstate ; void *vstate, 
              n      ;     size_t n
              )


(let (
  (state vstate)
;  xxx_conjugate_state_t *state = (xxx_conjugate_state_t *) vstate;
  )

  (xxx_conjugate_alloc  state n)

  (setf ( X0 state) (gsl_vector_alloc n))
  (setf (DX0 state) (gsl_vector_alloc n))  
  (setf (DG0 state) (gsl_vector_alloc n))

  GSL_SUCCESS
))
;-------------------------------------------------------------------------------
;int
(defun vector_bfgs_set  (
             vstate    ; void *vstate, 
             fdf       ; gsl_multimin_function_fdf *fdf,
             x         ; const gsl_vector *x, 
             ;f         ; double     *f, 
             gradient  ; gsl_vector *gradient,
             step_size ; double      step_size, 
             tol       ; double      tol
             )

(let (
  (state vstate)
;  xxx_conjugate_state_t *state = (xxx_conjugate_state_t *) vstate;

  f_ret ; сдeлаeм возвращаeмоe значeниe функции ??
  )

  ;(format *error-output* ".. 7 .. 7 .. 7 .. 1 ~%")
  ;(format *error-output* "7.. gradient= ~s  ~%" (GRADIENT s))
  ;(format *error-output* "7.. gradient= ~s  ~%" gradient)

  (setf f_ret 
  (xxx_conjugate_set state
                     fdf
                     x
                     ;f
                     gradient
                     step_size tol)
  )

  ;(format *error-output* "8.. gradient= ~s  ~%" gradient)
  ;(format *error-output* ".. 7 .. 7 .. 7 .. 2 ~%")
  (gsl_vector_memcpy (X0 state) x)

  ;(format t "vector_bfgs_set...  ~%")
  ;(format t "x0 =   ~s ~%" (X0 state))

  f_ret ;GSL_SUCCESS
))
;-------------------------------------------------------------------------------
;int
(defun vector_bfgs_iterate (
              vstate   ; void *vstate, 
              fdf      ; gsl_multimin_function_fdf * fdf,
              x        ; gsl_vector *x, 
              f        ; double *f,
              gradient ; gsl_vector *gradient, 
              dx       ; gsl_vector *dx
                            )

  ;(format *error-output* "vector_bfgs_iterate: vstate.PV  = ~s  ~%" (PV vstate))

  (xxx_conjugate_iterate vstate
                         fdf
                         x f
                         gradient dx
                         #'choose_new_direction_bfgs
                         )
)
;-------------------------------------------------------------------------------
