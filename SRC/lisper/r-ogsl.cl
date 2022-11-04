; -*-   mode: lisp ; coding: koi8   -*- ----------------------------------------

;-------------------------------------------------------------------------------
;===============================================================================
; *                                                                            *
; *  Имя этого файла: m_fgsl.c                                                 *
; *                                                                            *
;===============================================================================
;
; построeниe ботов на основe связки библиотeк GSL / MY-GSL
;                                                                          
                                                                          
;#include "a_comm.h"

;#include "m_corp.h"
;#include "m_fgsl.h"

;===============================================================================

;  //#include <gsl/gsl_test.h>
;  //#include <gsl/gsl_rng.h>
;  //#include <gsl/gsl_siman.h>
;  //#include <gsl/gsl_ieee_utils.h>
;#include <gsl/gsl_multimin.h>
;#include <gsl/gsl_blas.h>  // обязательно, а то идут "nun"                               
;#include <gsl/gsl_vector.h>

;-------------------------------------------------------------------------------

;typedef struct {
(defclass YT_GSLSPUSK () (

;  BOOL   diff2;
  (diff_h    :accessor DIFF_H)    ;  double diff_h;

  (min_type  :accessor MIN_TYPE)  ; const gsl_multimin_fdfminimizer_type *min_type;
  (step_size :accessor STEP_SIZE) ;  double step_size; 
  (tol       :accessor TOL)       ;  double tol;
 
;  // критерии останова
  (stop_grad    :accessor STOP_GRAD) ;  double stop_grad;
  (stop_iter    :accessor STOP_ITER) ;  int    stop_iter;
  (stop_func    :accessor STOP_FUNC) ;  double stop_func;
  (is_stop_func :accessor IS_STOP_FUNC) ; BOOL is_stop_func;

  (end_status :accessor END_STATUS) ;  char  *end_status;
  (end_niters :accessor END_NITERS) ;  int    end_niters;

))
;} YT_GSLSPUSK;


;===============================================================================
;// 
;-------------------------------------------------------------------------------
;YT_GSLSPUSK *
;gslspusk_create ()
;-------------------------------------------------------------------------------
(defun gslspusk_create ()

(let (
;  YT_GSLSPUSK *gslspusk;
;  gslspusk = (YT_GSLSPUSK*) malloc (sizeof(YT_GSLSPUSK));
  (gslspusk (make-instance 'YT_GSLSPUSK))
  )

;  return (gslspusk);
  gslspusk
))
;-------------------------------------------------------------------------------
;void
;gslspusk_set (YT_GSLSPUSK *gslspusk,

;              BOOL diff2, double diff_h,

;              const gsl_multimin_fdfminimizer_type *min_type,
;              double step_size, double tol, 
;              double stop_grad,
;              int    stop_iter,
;              double stop_func, BOOL is_stop_func)
;-------------------------------------------------------------------------------
;void
(defun gslspusk_set (
                     gslspusk      ; YT_GSLSPUSK *gslspusk
                     ; BOOL diff2, 
                     diff_h        ; double diff_h,                     
                     min_type      ; const gsl_multimin_fdfminimizer_type *min_type
                     step_size tol ; double step_size, double tol, 
                     stop_grad     ; double stop_grad,
                     stop_iter     ; int    stop_iter,
                     stop_func     ; double stop_func, 
                     is_stop_func  ; BOOL is_stop_func
                     )

;  gslspusk->diff2  = diff2;
  (setf (DIFF_H gslspusk) diff_h)

;  gslspusk->min_type = min_type;
  (setf (MIN_TYPE gslspusk) min_type)

;  // gsl_multimin_fdfminimizer_conjugate_fr;     // Fletcher-Reeves
;  // gsl_multimin_fdfminimizer_conjugate_pr;     // Polak-Ribiere
;  // gsl_multimin_fdfminimizer_steepest_descent; // 

;  // gsl_multimin_fdfminimizer_vector_bfgs;      // Broyden-Fletcher-Goldfarb-Shanno
;  // очень хороший веторный квази-ньютоновский алгоритм (комбинация производных)

;  gslspusk->step_size = step_size; // размер первого пробного шага
;  gslspusk->tol	      = tol;       // точность линейной минимизации
  (setf (STEP_SIZE gslspusk) step_size)
  (setf (TOL       gslspusk) tol)

  ;; критерий останова
  (setf (STOP_GRAD gslspusk) stop_grad) ; // норма градиента
  (setf (STOP_ITER gslspusk) stop_iter)
  (setf (STOP_FUNC gslspusk) stop_func) ;  gslspusk->stop_func = stop_func;
  (setf (IS_STOP_FUNC gslspusk) is_stop_func)

)
;===============================================================================
;
;-------------------------------------------------------------------------------
;double
(defun my_f (
         v      ; const gsl_vector *v, 
         params ; void *params
         )

  ;(format *error-output* "my_f...... ~%")

(let* (
  (bot     params)         ; YT_MINBOT   *bot = (YT_MINBOT *) params;
  (minproc (MINPROC bot))  ; YT_MINPROC  *minproc = bot->minproc; 

  ;(xyz_cur (make-array MAX_DIM)) ; double xyz_cur[MAX_DIM];
  (xyz_cur (make-array (DIM))) ; и сразу ошибка исправилась, и массив малeнький !!
  )
 
;  for (i=0; i < DIM; i++) 
;    xyz_cur[i] = gsl_vector_get (v, i);
  ;(format *error-output* "~%")
  ;(format *error-output* "my_f...... ~%")
  ;(format t "v= ~s ~%" v)

  (dotimes (i (DIM))
    (setf  (aref xyz_cur i) (gsl_vector_get  v i))
    )

  ;(xxx_vector_fprintf  *error-output* "xyz_cur= " xyz_cur) 
  ;; в SBCL массив xyz_cur инициируeтся нулями ?
  ;; а в CLISP - NIL ?!
  ;(format t "xyz_cur= ~s ~%" xyz_cur)
  ;(quit) ; !!!!!!!!!!!!1

  (minproc_calc_proc  minproc xyz_cur)
))
;-------------------------------------------------------------------------------
;double
(defun my_diff_central (
         v_null ; const gsl_vector *v_null, 
         i      ; int i, 
         params ; void *params
         )

  ;(format *error-output* ".. 2 .. 3 .. 3 .. 2 .. 1 .. 2 .. A ~%")

(let* (
  (bot      params)         ;  YT_MINBOT *bot = (YT_MINBOT *) params;
  (minproc  (MINPROC bot))  ;  YT_MINPROC   *minproc = bot->minproc; 
  (gslspusk (V_PARAM bot))  ;  YT_GSLSPUSK *gslspusk = bot->v_param;

  df_dxyz f_plus f_mins ;  double
  (v_plus (gsl_vector_alloc (DIM))) ;  gsl_vector *v_plus = gsl_vector_alloc (DIM);
  (v_mins (gsl_vector_alloc (DIM))) ;  gsl_vector *v_mins = gsl_vector_alloc (DIM);
  (diff_h (DIFF_H gslspusk)) ;  double diff_h = gslspusk->diff_h;
  )

  ;(format *error-output* "v_null= ~s ~%" v_null)

  ;;  // точка v_plus
  (gsl_vector_memcpy  v_plus v_null)

  ;(format *error-output* "v_plus= ~s ~%" v_plus)
  ;(format *error-output* "diff_h= ~s ~%" diff_h)

  (gsl_vector_set     v_plus i  (+ (gsl_vector_get v_plus i) diff_h)) ; !!!!ERRR

  ;(format *error-output* "v_plus= ~s ~%" v_plus)
  ;(quit)

  (setf f_plus (my_f  v_plus params))
	
  ;(format *error-output* ".. 2 .. 3 .. 3 .. 2 .. 1 .. 2 .. E ~%")

;  // точка v_mins
  (gsl_vector_memcpy  v_mins v_null)
  (gsl_vector_set     v_mins i  (- (gsl_vector_get v_mins i) diff_h))
  (setf f_mins (my_f  v_mins params))
	
  (setf df_dxyz  (/ (- f_plus f_mins) (* 2 diff_h)))
	
  df_dxyz
))
;-------------------------------------------------------------------------------
;/*  Вычисление градиента:  df = (df/dx, df/dy)                               */
;-------------------------------------------------------------------------------
;void 
(defun my_df (
              v_null ; const gsl_vector *v_null, 
              params ; void *params, 
              df ; gsl_vector *df
              )

(let* (
  (bot     params)         ;  YT_MINBOT *bot = (YT_MINBOT *) params;
  (minproc (MINPROC bot))  ;  YT_MINPROC   *minproc = bot->minproc; 

  df_dxyz;  double df_dxyz;
;  int    i;
  )
 
  ;(format *error-output* "my_df..... ~%")

;  // формировать градиент, т.е. вектор производных
;  for (i=0; i<DIM; i++) { // по каждой координате
  (dotimes (i (DIM))

    (setf df_dxyz  (my_diff_central v_null i params))
    (gsl_vector_set  df i df_dxyz)
    )

))
;-------------------------------------------------------------------------------
;/*  Compute both f and df together                                           */
;-------------------------------------------------------------------------------
;void 
;my_fdf (const gsl_vector *x, void *params, double *f, gsl_vector *df) 
;-------------------------------------------------------------------------------
(defun my_fdf (x params df) 

;  *f = my_f (x, params); 
;  my_df (x, params, df);

  ;(format *error-output* "my_fdf.... ~%")
  ;(format *error-output* ".......... ~%")
  ;(format t "x1= ~s ~%" x)

  (my_df  x params  df) ; посчитаeм и запишeм градиeнт ; my_df (x, params, df)

  ;(format *error-output* ".......... ~%")
  ( my_f  x params)     ; возвращаeм значeниe F        ; *f = my_f (x, params); 
)
;-------------------------------------------------------------------------------
;(defun parabol_fdf (x params df) 

;)
;-------------------------------------------------------------------------------
;void
;multimin_print (int iter, gsl_multimin_fdfminimizer *s)
;{

;  fprintf (stderr, "i=%03d  ", iter);
;  fprintf (stderr, "f= % 8.7f  |g|= % 8.4f  |dx|= %f ", 
;           s->f, 
;           gsl_blas_dnrm2 (s->gradient), 
;           gsl_blas_dnrm2 (s->dx)
;           );

;  // печатаем (обобщенную) точку
;  // похоже печатает в конце "\n", а нам бы это не надо..
;  //gsl_vector_fprintf (stderr, s->x, "x= [%g]");

;  fprintf (stderr, "\n");

;  return;
;}
;-------------------------------------------------------------------------------
;/*  Градиентный спуск по программе GSL                                       */
;-------------------------------------------------------------------------------
;double
(defun minbot_gslspusk_one (
            bot     ; YT_MINBOT *bot,
            xyz_beg ; double *xyz_beg, 
            xyz_end ; double *xyz_end
            )

(let (
  (minproc  (MINPROC bot))  ;  YT_MINPROC   *minproc = bot->minproc;
  (gslspusk (V_PARAM bot))  ;  YT_GSLSPUSK *gslspusk = bot->v_param;

  end_status  ;  char *end_status;
  iter status ;  int 
  s ;  gsl_multimin_fdfminimizer *s;
  x ;  gsl_vector                *x;
  my_func ;  gsl_multimin_function_fdf  my_func;
;  //double minimum, g_norma=0, x_elem;
  
  step_size tol
  )

;  // задание самой минимизируемой функции
;  my_func.f   = &my_f;
;  my_func.df  = &my_df;
;  my_func.fdf = &my_fdf;
;  my_func.n   = DIM;
;  my_func.params = bot;          // !!!!!!!!
  (setf my_func (make_function_fdf  #'my_f #'my_df #'my_fdf  (DIM) bot))

  ;(format *error-output* ".. 2 .. 1 ~%")
  ;(d_print "41-1")

;  // начальное приближения: точка инициализации спуска
  (setf x (gsl_vector_alloc (DIM)))   
;  for (i=0; i<DIM; i++) 
;    gsl_vector_set (x, i, xyz_beg[i]);
  (dotimes (i (DIM))
    (gsl_vector_set  x  i (coerce (aref xyz_beg i) 'double-float) )
    )

  ;(format *error-output* ".. 2 .. 2 ~%")
  ;(d_print "41-2")

  ;; создание и инициализация алгоритма
  (setf s  (gsl_multimin_fdfminimizer_alloc (MIN_TYPE gslspusk) (DIM)))

  ;(format *error-output* ".. 2 .. 3 ~%")
  ;(d_print "41-3")

  (setf step_size (STEP_SIZE gslspusk))
  (setf tol       (TOL       gslspusk))

;  (format *error-output* "my_func  = ~s ~%" my_func)
;  (format *error-output* "x        = ~s ~%" x)
;  (format *error-output* "step_size= ~s ~%" step_size)
;  (format *error-output* "tol      = ~s ~%" tol)

  ;; gsl_multimin_fdfminimizer_set (s, &my_func, x, step_size, tol);	
  (gsl_multimin_fdfminimizer_set  s  my_func x step_size tol)	
  ;(format *error-output* "2.. gradient= ~s  ~%" (GRADIENT s))

  ;(format *error-output* "minbot_gslspusk_one.. ~%")
  ;(xxx_vector_fprintf *error-output*  "x= " x)

  (setf iter 0) ; // начинаем итерационный спуск -------------------------
;  while (1) {
  (loop 

;    if (ERR_PRINT) { // тестовая печать текущего состояния
;      multimin_print (iter, s);
;    }

;    // проверяем условие на количество итераций
    (incf iter)
;    if (iter++ >= gslspusk->stop_iter) {
;      end_status = "gsl_maxiter";
;      break;
;    }
  ;(d_print "41-4")

    (when (>= iter (STOP_ITER gslspusk))
      (setf end_status "gsl_maxiter")
      (return)
      )

    ;(format *error-output* ".. 2 .. 6 ~%")
    ;(d_print "41-5")
    ;(format *error-output* "2.. gradient= ~s  ~%" (GRADIENT s))

;    // выполнить одну итерацию
    (setf status (gsl_multimin_fdfminimizer_iterate  s))

    ;(format *error-output* "status = ~s ~%" status)
    ;(d_print "41-6")

;    // gsl_vector* gsl_multimin_fdsolver_x (s) - best estimate of the location of the minimum,
;    // double      gsl_multimin_fdsolver_minimum (s)  - value of the function at that point,
;    // gsl_vector* gsl_multimin_fdsolver_gradient (s) - and its gradient;

;    if (status) { // неожиданные проблемы - так и не понятно что это !!!!!
;                  // и как с этим бороться (просто уменьшать шаг?)
    (when (> status 0)

;      // gsl-1.8/multimin/vector_bfgs.c:
;      // -------------------------------------?????
;      //  if (pnorm == 0.0 || g0norm == 0.0)
;      //    {
;      //      gsl_vector_set_zero (dx);
;      //      return GSL_ENOPROG;
;      //    }
;      // ........
;      // ........
;      //  if (stepb == 0.0)
;      //    {
;      //      return GSL_ENOPROG;
;      //    }
;      // -------------------------------------?????
      ;(format *error-output* ".. 2 .. 6__ ~%")

      (if (= status GSL_ENOPROG) (setf end_status "gsl_enoprog") 
                                 (setf end_status "gsl_problem")
                                 )
      (return) ; break;
     )
		
    ;(format *error-output* ".. 2 .. 7 ~%")
    ;(d_print "41-7")

    ;; прверяем условие на норму градиента |g| < stop_grad 
    ;; т.е. близость к локальному минимуму 
    ;; status = gsl_multimin_test_gradient (s->gradient, gslspusk->stop_grad /*epsabs*/);
    (setf status (gsl_multimin_test_gradient (GRADIENT s) (STOP_GRAD gslspusk)))
    ;(format *error-output* "status = ~s ~%" s)

    (when (= status GSL_SUCCESS) 
      (setf end_status "gsl_mingrad")

      ;; все таки проверим достижение искомого значения (если задано):
      (when (and (IS_STOP_FUNC gslspusk) (> (F s) (STOP_FUNC gslspusk)))
        (setf end_status "gsl_MINGRAD")
        )
        
      (return) ; break
    )

    ;(format *error-output* ".. 2 .. 8 ~%")
    ;(d_print "41-8")

;    // A suitable choice of 'epsab' can be made from the desired accuracy in the function
;    // for small variations in x. The relationship between these quantities is given by 
;    // df = g * dx
   
;    // Gsl-Ref (p.348) : 
;    // A minimum has been found to within the user-specified precision.
;    // 
;    // ЭТО МОЖЕТ СОВСЕМ УБРАТЬ ??????????????????
;    // заданное значение мы достигли, но оно нам зачем, если это не МИНИМУМ?
;    // 

    ; все совпадает с TCL
    ;
    ;(format *error-output* "minbot_gslspusk_one: iter= ~s  F= ~s ~%" iter (F s))

    (when (IS_STOP_FUNC gslspusk) 

    ;(format *error-output* ".. 2 .. 8 ~%")
    ;(format *error-output* "f= ~s   stop_func= ~s  ~%" (F s) (STOP_FUNC gslspusk))

    (when (< (F s) (STOP_FUNC gslspusk)) 
       (setf end_status "gsl_stopfun")
       (return) ; break;
    )
    )
    ;; //-----------------------------------------

   )

  ;(d_print "41-8-")

;  // ---------------------------------------------------------------
;  // 
;  //if (ERR_PRINT) { // тестовая печать конечного состояния
;  //  multimin_print (iter, s);
;  //  fprintf (stderr, "--------- \n");
;  //  fprintf (stderr, "%s \n", end_status);
;  //  fprintf (stderr, "--------- \n");
;  //}
	
;  // записываем и возвращаем результаты
  (setf (END_STATUS gslspusk) end_status)
  (setf (END_NITERS gslspusk) iter)

;  for (i=0; i < DIM; i++)
;    xyz_end[i] = gsl_vector_get (s->x, i);
  (dotimes (i (DIM))
    (setf (aref xyz_end i) (gsl_vector_get (X s) i))
    )

  ;(format t "minbot_gslspusk_one.. 9 ~%")
  ;(d_print "41-9")

  (F s) ;  return (s->f);
))
;===============================================================================
;
;-------------------------------------------------------------------------------
;void
(defun minbot_gslspusk_s (
             bot ; void *b
             )

(let (
  ;;  YT_MINBOT *bot = (YT_MINBOT *) b;
  (minproc (MINPROC bot)) ;  YT_MINPROC   *minproc = bot->minproc;

  g ;  double g, xyz_cur[MAX_DIM];
  (xyz_cur (make-array MAX_DIM))
;  int    n=0;
  (first t);  BOOL   first; ;  first = TRUE;
;  //NUM_END = 0; //!!!!!!!!!!
  
  xyz_beg
  )

  ;(d_print "41")
  (dotimes (n (NUM_BEG)) ; // проводим спуск для каждой начальной точки

    ;(format *error-output* "n= ~s ~%" n)
    ;(format *error-output* ".. 1 ~%")

    (setf xyz_beg (make_xyz_from_fpoints  (DIM) (S_INIT minproc) n))
    ;(d_print "41-1")

    ;; g = minbot_gslspusk_one (bot, XYZ_BEG[n], xyz_cur);    
    ;; (setf g (minbot_gslspusk_one  bot (aref xyz_beg n) xyz_cur)) 
    (setf g (minbot_gslspusk_one  bot xyz_beg xyz_cur)) 

    ;(d_print "41-2")
  
    (when first 
      (setf (nth 0 (FUN_END)) g) ; FUN_END[0] = g;
      (setf first NIL)           ;= FALSE;
    )

    ;(d_print "41-3")
    (minproc_check_new_solution  minproc xyz_cur g) ; // прверяем возможное решение
    )
  ;(d_print "42")

))
;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;void
(defun minproc_rand_init_one (
       minproc ;YT_MINPROC *minproc
       )

(let (
;  int  /* n, */ i;
  v ;  double  v;
;  //n = 0;
  )

  ;(format *error-output* "minproc_rand_init_one.. ~%" )

;  if (debug) fprintf (stderr, "XYZ_BEG= ");
  ;(format *error-output* "XYZ_BEG= ")
    
;  for (i=0; i < DIM; i++) {
  (dotimes (i (DIM))
;    v = YRandF (XYZ_MIN[i], XYZ_MAX[i]);
    (setf v (YRandF (nth i (XYZ_MIN)) (nth i (XYZ_MAX)) ))

;    XYZ_BEG[0/*n*/][i] = v;
    (setf (aref (XYZ_BEG) 0 i) v) ; зачeм тут двумeрный массив ?

;    if (debug) fprintf (stderr, "% 4.2f ", v);
    ;(format *error-output* "~s " v )
  )

;  //FUN_BEG[n] = minproc_calc_proc (minproc, XYZ_BEG[n]);
;  if (debug) fprintf (stderr, "\n");
  ;(format *error-output* "~%")

  (setf (NUM_BEG) 1) ;  NUM_BEG = 1;

))
;-------------------------------------------------------------------------------
;void
(defun WriteXyz0 (
       minproc ; YT_MINPROC *minproc, 
       xyz     ; double *xyz
       )

;/*   int  i; */

;/*   for (i=0; i<DIM; i++) { */
;/*     XYZ_END[0][i] = xyz[i]; */
;/*   } */

;  minproc_write_xyzend_n (minproc, xyz, /* NUM_END */0);
  (minproc_write_xyzend_n  minproc xyz 0)

 (setf (NUM_END) 1)  ;  NUM_END = 1;
)
;-------------------------------------------------------------------------------
;void
(defun minproc_check_new_solution_ (
       minproc ; YT_MINPROC *minproc, 
       xyz     ; double *xyz, 
       g       ; double g,
       eps     ; double eps
       )

(let (
  find ;  BOOL    find;
  )

;  // три варианта для нового проверяемого значения :

;  if      (g > FUN_END[0] + eps)  return; // большее значение
  (when (> g (+ (nth 0 (FUN_END)) eps))  
    (return-from minproc_check_new_solution_)
    )

;  else if (g < FUN_END[0] - eps) { // новый минимальный уровень
  (if (< g (- (nth 0 (FUN_END)) eps))
      (progn 
        (setf (nth 0 (FUN_END)) g) ;    FUN_END[0] = g;
        (WriteXyz0 minproc xyz)
      )
;  } else { // найдено еще одно значение этого уровня
      (progn 
;    // проверить есть ли уже такой корень !!!!
;    find = fpoints_find_xyz (DIM, MM->s_calc, xyz, eps);
    (setf find (fpoints_find_xyz  (DIM) (S_CALC minproc) xyz eps))

    (when (not find) ;{ // записать новое значение минимального уровня
      (WriteXyz0 minproc xyz)
      )
      )
    )

))
;-------------------------------------------------------------------------------
;BOOL
;is_stop_func (char *status)
;-------------------------------------------------------------------------------
(defun is_stop_func_fromstatus (status)

(let (
  flag
;  BOOL flag = (!strcmp(status, "gsl_mingrad") || !strcmp(status, "gsl_stopfun"));
  )

  (setf flag (or (string= status "gsl_mingrad") (string= status "gsl_stopfun")))

  flag
))
;-------------------------------------------------------------------------------
;void
;botspusk_fun_data (void *self, void *mp)
;-------------------------------------------------------------------------------
(defun botspusk_fun_data (bot minproc)

;  YT_MINBOT *bot = (YT_MINBOT *) self;
;  bot->minproc = (YT_MINPROC *) mp;

  (setf (MINPROC bot) minproc)
)
;-------------------------------------------------------------------------------
;char *
(defun botspusk_for_xyzbeg (
       bot    ; YT_MINBOT *bot, 
       xyzbeg ; double  *xyzbeg
       )

;(format t "botspusk_for_xyzbeg.. 1 ~%")

(let* (
  (minproc (MINPROC bot)) ;  YT_MINPROC  *minproc = bot->minproc;
  status ;  char *status;
 
  (xyz (make-array MAX_DIM))  ; double xyz[MAX_DIM]; 

  ;;  g = minbot_gslspusk_one (bot,  xyzbeg, xyz);
  ;(g (minbot_gslspusk_one  bot xyzbeg xyz)) ;  double g
  g ;  double g

;  // нужно соотнести с точностью поискового алгоритма  !!!
;  // для этого нужно знать масштабы ШКАЛЫ ЗНАЧЕНИЙ ФУНКЦИИ
;  //double  eps = /* EPS  */0.0001;
  (eps  0.01) ;  double  eps = 0.01;
  gslspusk
  )

; (format *error-output* "botspusk_for_xyzbeg.. 1 ~%")
; (format *error-output* "xyzbeg= ~s ~%" xyzbeg)
; ;(format t "xyz   = ~s ~%" xyz)
 (setf g (minbot_gslspusk_one  bot xyzbeg xyz))
; (format *error-output* "botspusk_for_xyzbeg.. 2 ~%")

 (setf (nth 0 (FUN_END)) g) ;  FUN_END[0] = g;

  (minproc_check_new_solution_ minproc xyz g eps) ; // прверяем возможное решение

;  YT_GSLSPUSK *gslspusk = (YT_GSLSPUSK *) (bot->v_param);
  (setf gslspusk (V_PARAM bot))

  (setf status (END_STATUS gslspusk)) ; ;  status = gslspusk->end_status;

;  //if (debug) {
;  //fprintf (STD_ERR, "%s  niters=%4d  ", status, bot->gslspusk->end_niters);
;  //printf ("\n\n");
;  //}

; (format *error-output* "botspusk_for_xyzbeg.. 3 ~%")

  status
))
;-------------------------------------------------------------------------------
;void
(defun minproc_rand_init_one_XYZ_BEG (
       minproc ; YT_MINPROC *minproc, 
       xyzbeg  ; double *xyzbeg, 
       d       ; double d
       )

(let (
  delta  ; double  delta;
  ;  int     i;
  xyzint xyzmin xyzmax v ; double  v, xyzmin, xyzmax, xyzint;
  )

;  if (debug) fprintf (stderr, "XYZ_BEG= ");
    
;  for (i=0; i < DIM; i++) {
  (dotimes (i (DIM))

;    xyzint = (XYZ_MAX[i] - XYZ_MIN[i]);
    (setf xyzint (- (nth i (XYZ_MAX)) (nth i (XYZ_MIN))))
    (setf delta  (* xyzint d))

    (setf xyzmin (- (aref xyzbeg i) delta)) ; xyzmin = xyzbeg[i] - delta;
    (setf xyzmax (+ (aref xyzbeg i) delta)) ; xyzmax = xyzbeg[i] + delta;
    (setf xyzmin (max (nth i (XYZ_MIN)) xyzmin))   ; xyzmin = YMAX (XYZ_MIN[i], xyzmin);
    (setf xyzmax (min (nth i (XYZ_MAX)) xyzmax))   ; xyzmax = YMIN (XYZ_MAX[i], xyzmax);

    (setf v (YRandF  xyzmin xyzmax))

    (setf (aref (XYZ_BEG) 0 i) v)  ;  XYZ_BEG[0][i] = v;
;    if (debug) fprintf (stderr, "% 4.2f ", v);
    )

;  if (debug) fprintf (stderr, "\n");

  (setf (NUM_BEG) 1) ;  NUM_BEG = 1;
))
;-------------------------------------------------------------------------------
;YT_BOOL
(defun one_XYZ_BEG (
       bot  ;YT_MINBOT *bot, 
       ii  ;int ii, 
       d  ;double d
       )

(let* (
  (minproc (MINPROC bot)) ;  YT_MINPROC  *minproc = bot->minproc;
;  int i;
;  int n;
  status ;  char *status;
  xyz_beg
  )

;  for (n= 0; n< NUM_BEG; n++)  
;  for (i=0; i< ii; i++) {  // 
  (dotimes (n (NUM_BEG))
  (dotimes (i ii)

    (setf xyz_beg (make_xyz_from_fpoints  (DIM) (S_INIT minproc) n)) 
    ;; такой хитрый приeм

;    minproc_rand_init_one_XYZ_BEG (minproc, XYZ_BEG[n], d); 
    (minproc_rand_init_one_XYZ_BEG  minproc xyz_beg d) 

;    status = botspusk_for_xyzbeg (bot, XYZ_BEG[0]);
;    if (is_stop_func (status))
;      return (TRUE); 

    (setf status (botspusk_for_xyzbeg bot xyz_beg))
    (when (is_stop_func_fromstatus status)
      (return-from one_XYZ_BEG) 
      )
  ))

 FALSE
))
;-------------------------------------------------------------------------------
;void
(defun botspusk_fun_todo (
            bot  ;void *self
            )

;  (format t "botspusk_fun_todo ... 1 ~%")

(let* (
  ;  YT_MINBOT *bot = (YT_MINBOT *) self;
  (minproc (MINPROC bot)) ;  YT_MINPROC  *minproc = bot->minproc;

  ;  //int num = bot->s_power;
  (num (LONG1 bot)) ;  int num = bot->long1;
  ;  int i, n
  status ;  char *status;
  xyz_beg
  )

  (YRAND_F) ;  YRAND_F;

;  (format t "botspusk_fun_todo ... 2 ~%")

  (when *simp_random* 
    (format t "SPUSK FOR NUM_BEG ~%")
    (format t "S_INIT  = ~s ~%" (S_INIT minproc))
    (format t "NUM_BEG = ~s ~%" (NUM_BEG))
    )

;  //--------------------------------------------
;  for (n= 0; n< NUM_BEG; n++) { // проводим спуск для каждой начальной точки
  (dotimes (n (NUM_BEG))

    (setf xyz_beg (make_xyz_from_fpoints  (DIM) (S_INIT minproc) n)) 
    ;; такой хитрый приeм
    ;(format *error-output* "xyz_beg= ~s ~%" xyz_beg)

;    status = botspusk_for_xyzbeg (bot, /* n */ XYZ_BEG[n]);
    (setf status (botspusk_for_xyzbeg bot xyz_beg))
    ;(format *error-output* "n= ~s status= ~s ~%" n status)

    (when (is_stop_func_fromstatus status)
      (return-from botspusk_fun_todo) ; // сразу нашли нужный минимум по начальному значению
      )
    )

  ;; !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  (format t "botspusk_fun_todo ... 3 ~%")

  (quit) ; ?? не попадаем сюда ??
  ;; !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

;  if (debug) fprintf (stderr, "SPUSK FOR NUM_BEG's VICINITY's \n");
  (format *error-output* "SPUSK FOR NUM_BEG's VICINITY's ~%")

;  // лучше бы не просто случайные точки из всей области определения,
;  // а случайные из близкой окрестности начальных точек
;  //--------------------------------------------
;  if (one_XYZ_BEG (bot, 10, 0.1)) return; 
;  if (one_XYZ_BEG (bot, 10, 0.2)) return; 
;  if (one_XYZ_BEG (bot, 10, 0.3)) return; 

  (when (one_XYZ_BEG  bot 10 0.1) (return-from botspusk_fun_todo)) 
  (when (one_XYZ_BEG  bot 10 0.2) (return-from botspusk_fun_todo)) 
  (when (one_XYZ_BEG  bot 10 0.3) (return-from botspusk_fun_todo)) 

;  if (debug) fprintf (stderr, "SPUSK FOR RANDOM POINTS \n");
  (format *error-output* "SPUSK FOR RANDOM POINTS ~%")

;  //--------------------------------------------
;  for (i=0; i< num; i++) { // попробуем случайные нач. точки
  (dotimes (i num)
    ;(format t "i= ~s ~%" i)
    (minproc_rand_init_one  minproc)

    ;(format t "..........222 ~%")

;    status = botspusk_for_xyzbeg (bot, /* 0, */ XYZ_BEG[0]);
    (setf xyz_beg (make_xyz_from_fpoints  (DIM) (S_INIT minproc) 0)) 
    ;(format t "xyz_beg= ~s ~%" xyz_beg)
    (setf status (botspusk_for_xyzbeg  bot xyz_beg))

    ;(format t "..........333 ~%")
;    if (is_stop_func_fromstatus  (status))
;      return;
    (when (is_stop_func_fromstatus status)
      (return-from botspusk_fun_todo) 
    )
  )

;  // ничего не нашли - это нас не устраивает совсем..
  (format t "~%")
  (format t "ERROR: Don't find STOPFUN minimum (~s iterations) ~%" num)
  (format t "~%");
;  exit(0);

))
;-------------------------------------------------------------------------------
;void 
(defun botspusk_fun_init (
             bot   ;void *b, 
             long1 long2 long3 
             d1 ; double d1
             )

(let* (
;  YT_MINBOT *bot = (YT_MINBOT *) b;

  (conjugate_bfgs_type  (make_fdfminimizer_type 
                       "conjugate_bfgs"                        
                       'XXX_CONJUGATE_STATE_T ; sizeof (xxx_conjugate_state_t),
                       #'vector_bfgs_alloc
                       #'vector_bfgs_set 
                       #'vector_bfgs_iterate
                       ;;  &xxx_conjugate_restart,
                       ;;  &vector_bfgs_free
                       ))
  )

  (setf (LONG1 bot) long1) ;  bot->long1 = long1;
  (setf (LONG2 bot) long2) ;  bot->long2 = long2;
  (setf (LONG3 bot) long3) ;  bot->long3 = long3;
  (setf (D1    bot) d1) ;  bot->d1 = d1;

  (setf (V_PARAM bot) (gslspusk_create))   ;  bot->v_param = gslspusk_create ();

  (gslspusk_set 
                 (V_PARAM bot) ; bot->v_param, 
;                FALSE /* TRUE */, // diff2
                 0.00001       ;   // diff_h

                 conjugate_bfgs_type ; gsl_multimin_fdfminimizer_vector_bfgs,

                 0.01D0   ;// размер первого пробного шага
                 0.01D0   ;// точность линейной минимизации

;                // критерии останова :
                0.001     ;// по норме градиента     (stop_grad )
                100       ;// по количеству итераций (stop_iter )

                d1 ;/* stop_func    */ d1, 
                t ;/* is_stop_func */ TRUE             
                )

))
;===============================================================================
;-------------------------------------------------------------------------------
;void 
(defun botgslspusk_1_init (
                  bot   ; void *b
                  long1 long2 long3 
                  d1    ; double d1
                  )
(declare (ignore long3))

(let* (
;  YT_MINBOT *bot = (YT_MINBOT *) b;
  stop_func ;  double stop_func;

  (num_multy     long1) ;  int  num_multy    = long1;
  (is_stop_func  long2) ;  BOOL is_stop_func = long2;

  (conjugate_fr_type  (make_fdfminimizer_type 
                       "conjugate_fr"                        
                       'XXX_CONJUGATE_STATE_T ; sizeof (xxx_conjugate_state_t),
                       #'xxx_conjugate_alloc  
                       #'xxx_conjugate_set 
                       #'conjugate_fr_iterate
                       ;;  &xxx_conjugate_restart,
                       ;;  &xxx_conjugate_free
                       ))
  )

  (when  is_stop_func (setf stop_func d1)) ; если мы точно знаем чего хотим
        
  (setf (S_POWER bot)  num_multy)          ; bot->s_power  = num_multy;
  (setf (V_PARAM bot) (gslspusk_create))   ; bot->v_param = gslspusk_create ();

  (gslspusk_set 
                 (V_PARAM bot) ;bot->v_param,
;                FALSE /* TRUE */, // diff2
                0.000001         ; // diff_h

                conjugate_fr_type ;"gsl_multimin_fdfminimizer_conjugate_fr"
;                //gsl_multimin_fdfminimizer_vector_bfgs,

                0.01D0 ; 0.01   ;// размер первого пробного шага
                0.01D0   ;// точность линейной минимизации

;                // критерии останова :
                0.001    ; // stop_grad : норма градиента
                100      ; // stop_iter : максимум итераций

                stop_func
                is_stop_func              
                )

))
;-------------------------------------------------------------------------------
;void
(defun botgslspusk_1_todo (
       bot  ; void *self
       )

;  YT_MINBOT *bot = (YT_MINBOT *) self;

;  // задаем случайные начальные точки:
;  // (эта часть внутри алгоритма расчета или вне его должна быть ???)

  ;(format t "botgslspusk_1_todo ......... 1 ~%")

  (minproc_rand_init (MINPROC bot) (S_POWER bot)) 

  ;(format t "botgslspusk_1_todo ......... 2 ~%")

;  //---------------------------
  (minbot_gslspusk_s bot)
;  //---------------------------

  ;(format t "botgslspusk_1_todo ......... 3 ~%")

;  if (debug) {
;    YT_GSLSPUSK *gslspusk = (YT_GSLSPUSK *) (bot->v_param);

;    fprintf (STD_ERR, "%s  niters=%4d  ",
;             gslspusk->end_status, gslspusk->end_niters);
;    printf ("\n\n");
;  }

)
;===============================================================================
;
;===============================================================================
