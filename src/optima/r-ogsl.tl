# -*-   mode: tcl  ; coding: koi8   -*- ----------------------------------------

#===============================================================================
# *                                                                            *
# *  Имя этого файла: m_fgsl.c                                                 *
# *                                                                            *
# ==============================================================================
# ;
# ; построeниe ботов на основe связки библиотeк GSL / MY-GSL
# ;                                                                          
                                                                          
# ;#include "a_comm.h"

# ;#include "m_corp.h"
# ;#include "m_fgsl.h"

# ;===============================================================================

# ;  //#include <gsl/gsl_test.h>
# ;  //#include <gsl/gsl_rng.h>
# ;  //#include <gsl/gsl_siman.h>
# ;  //#include <gsl/gsl_ieee_utils.h>
# ;#include <gsl/gsl_multimin.h>
# ;#include <gsl/gsl_blas.h>  // обязательно, а то идут "nun"                               
# ;#include <gsl/gsl_vector.h>

# ;-------------------------------------------------------------------------------

# (defclass YT_GSLSPUSK () (

# ;  BOOL   diff2;
#   (diff_h    :accessor DIFF_H)    ;  double diff_h;

#   (min_type  :accessor MIN_TYPE)  ; const gsl_multimin_fdfminimizer_type *min_type;
#   (step_size :accessor STEP_SIZE) ;  double step_size; 
#   (tol       :accessor TOL)       ;  double tol;
 
# ;  // критерии останова
#   (stop_grad    :accessor STOP_GRAD) ;  double stop_grad;
#   (stop_iter    :accessor STOP_ITER) ;  int    stop_iter;
#   (stop_func    :accessor STOP_FUNC) ;  double stop_func;
#   (is_stop_func :accessor IS_STOP_FUNC) ; BOOL is_stop_func;

#   (end_status :accessor END_STATUS) ;  char  *end_status;
#   (end_niters :accessor END_NITERS) ;  int    end_niters;

# ))


record define YT_GSLSPUSK {

  DIFF_H
  
  MIN_TYPE
  STEP_SIZE
  TOL
  
  STOP_GRAD
  STOP_ITER
  STOP_FUNC
  IS_STOP_FUNC
  
  END_STATUS
  END_NITERS
  
}


# ;===============================================================================
# ;// 
# ;-------------------------------------------------------------------------------
# ;YT_GSLSPUSK *
# ;gslspusk_create ()
# ;-------------------------------------------------------------------------------
proc gslspusk_create {} {

  # (let (
  # ;  YT_GSLSPUSK *gslspusk;
  # ;  gslspusk = (YT_GSLSPUSK*) malloc (sizeof(YT_GSLSPUSK));
  
  set gslspusk [make-instance "YT_GSLSPUSK"]
  #   )
  
  # ;  return (gslspusk);
  
  #   gslspusk
}
# ;-------------------------------------------------------------------------------
# ;void
# ;gslspusk_set (YT_GSLSPUSK *gslspusk,

# ;              BOOL diff2, double diff_h,

# ;              const gsl_multimin_fdfminimizer_type *min_type,
# ;              double step_size, double tol, 
# ;              double stop_grad,
# ;              int    stop_iter,
# ;              double stop_func, BOOL is_stop_func)
# ;-------------------------------------------------------------------------------
# ;void
proc gslspusk_set { \
                     gslspusk      \
                     \
                     diff_h        \
                     min_type      \
                     step_size tol \
                     stop_grad     \
                     stop_iter     \
                     stop_func     \
                     is_stop_func  \
                   } { 

  # ;  gslspusk->diff2  = diff2;
  $gslspusk.DIFF_H =  $diff_h
  
  # ;  gslspusk->min_type = min_type;
  $gslspusk.MIN_TYPE = $min_type
  
  # ;  // gsl_multimin_fdfminimizer_conjugate_fr;     // Fletcher-Reeves
  # ;  // gsl_multimin_fdfminimizer_conjugate_pr;     // Polak-Ribiere
  # ;  // gsl_multimin_fdfminimizer_steepest_descent; // 
  
  # ;  // gsl_multimin_fdfminimizer_vector_bfgs;      // Broyden-Fletcher-Goldfarb-Shanno
  # ;  // очень хороший веторный квази-ньютоновский алгоритм (комбинация производных)
  
  # ;  gslspusk->step_size = step_size; // размер первого пробного шага
  # ;  gslspusk->tol	      = tol;       // точность линейной минимизации
  
  $gslspusk.STEP_SIZE = $step_size
  $gslspusk.TOL       = $tol
  
  #   ;; критерий останова
  
  $gslspusk.STOP_GRAD = $stop_grad ;# // норма градиента
  $gslspusk.STOP_ITER = $stop_iter
  $gslspusk.STOP_FUNC = $stop_func ;#  gslspusk->stop_func = stop_func;

  $gslspusk.IS_STOP_FUNC = $is_stop_func

}
# ;===============================================================================
# ;
# ;-------------------------------------------------------------------------------
# ;double
# (defun my_f (
#          v      ; const gsl_vector *v, 
#          params ; void *params
#          )
# ;-------------------------------------------------------------------------------
# ;double
proc my_f {  \
          v  \
          params \
          } {

  #   ;(format *error-output* "my_f...... ~%")
  
  # (let* (

  set bot  $params     ;# YT_MINBOT   *bot = (YT_MINBOT *) params;
  set minproc [$bot.MINPROC]  ;# YT_MINPROC  *minproc = bot->minproc; 
  
  #   ;(xyz_cur (make-array MAX_DIM)) ; double xyz_cur[MAX_DIM];

  set xyz_cur [list_make [set [DIM]]] ;# и сразу ошибка исправилась, и массив малeнький !!
  #   )
  
  # ;  for (i=0; i < DIM; i++) 
  # ;    xyz_cur[i] = gsl_vector_get (v, i);
  #   ;(format *error-output* "~%")
  #   ;(format *error-output* "my_f...... ~%")
  #   ;(format t "v= ~s ~%" v)
  
  dotimes  i [set [DIM]] {
    lset xyz_cur $i  [gsl_vector_get  $v $i]
  }
  
  #   ;(xxx_vector_fprintf  *error-output* "xyz_cur= " xyz_cur) 
  #   ;; в SBCL массив xyz_cur инициируeтся нулями ?
  #   ;; а в CLISP - NIL ?!
  #   ;(format t "xyz_cur= ~s ~%" xyz_cur)
  #   ;(quit) ; !!!!!!!!!!!!1
  
  return [minproc_calc_proc  $minproc $xyz_cur]
}
# ;-------------------------------------------------------------------------------
# ;double
# (defun my_diff_central (
#          v_null ; const gsl_vector *v_null, 
#          i      ; int i, 
#          params ; void *params
#          )
# ;-------------------------------------------------------------------------------
# ;double
proc my_diff_central { \
         v_null        \
         i             \
         params        \
       } {

  #   ;(format *error-output* ".. 2 .. 3 .. 3 .. 2 .. 1 .. 2 .. A ~%")
  
  # (let* (

  set bot   $params         ;#  YT_MINBOT *bot = (YT_MINBOT *) params;
  set minproc  [$bot.MINPROC]  ;#  YT_MINPROC   *minproc = bot->minproc; 
  set gslspusk [$bot.V_PARAM]  ;#  YT_GSLSPUSK *gslspusk = bot->v_param;
  
  #   df_dxyz f_plus f_mins ;  double

  set v_plus [gsl_vector_alloc [set [DIM]]] ;#  gsl_vector *v_plus = gsl_vector_alloc (DIM);
  set v_mins [gsl_vector_alloc [set [DIM]]] ;#  gsl_vector *v_mins = gsl_vector_alloc (DIM);
  set diff_h [$gslspusk.DIFF_H] ;#  double diff_h = gslspusk->diff_h;
  #   )
  
  #   ;(format *error-output* "v_null= ~s ~%" v_null)
  
  #   ;;  // точка v_plus
  gsl_vector_memcpy  v_plus $v_null
  
  #   ;(format *error-output* "v_plus= ~s ~%" v_plus)
  #   ;(format *error-output* "diff_h= ~s ~%" diff_h)
  
  gsl_vector_set  v_plus $i  [expr {[gsl_vector_get $v_plus $i] + $diff_h}]  ;# !!!!ERRR
  
  #   ;(format *error-output* "v_plus= ~s ~%" v_plus)
  #   ;(quit)
  
  set f_plus [my_f  $v_plus $params]
  
  #   ;(format *error-output* ".. 2 .. 3 .. 3 .. 2 .. 1 .. 2 .. E ~%")
  
  # ;  // точка v_mins

  gsl_vector_memcpy  v_mins $v_null
  gsl_vector_set     v_mins $i  [expr {[gsl_vector_get $v_mins $i] - $diff_h}]
  set f_mins [my_f  $v_mins $params]
  
  set df_dxyz  [expr {($f_plus - $f_mins) / (2 * $diff_h)}]
	
  return $df_dxyz
}
# ;-------------------------------------------------------------------------------
# ;/*  Вычисление градиента:  df = (df/dx, df/dy)                               */
# ;-------------------------------------------------------------------------------
# ;void 
# (defun my_df (
#               v_null ; const gsl_vector *v_null, 
#               params ; void *params, 
#               df ; gsl_vector *df
#               )
# ;-------------------------------------------------------------------------------
# ;void 
proc my_df {v_null params &df} {

  #USE_REFS
  upvar ${&df} df

  set bot  $params         ;#  YT_MINBOT *bot = (YT_MINBOT *) params;
  set minproc [$bot.MINPROC]  ;#  YT_MINPROC   *minproc = bot->minproc; 
  
  #   ;(format *error-output* "my_df..... ~%")
  
  # ;  // формировать градиент, т.е. вектор производных
  # ;  for (i=0; i<DIM; i++) {} // по каждой координате

  dotimes  i [set [DIM]] {
  
    set df_dxyz  [my_diff_central  $v_null $i $params]
    gsl_vector_set  df $i $df_dxyz
  }

  return
}
# ;-------------------------------------------------------------------------------
# ;/*  Compute both f and df together                                           */
# ;-------------------------------------------------------------------------------
# ;void 
# ;my_fdf (const gsl_vector *x, void *params, double *f, gsl_vector *df) 
# ;-------------------------------------------------------------------------------
proc my_fdf {x params &df} { 

  #USE_REFS
  upvar ${&df} df
  
  # ;  *f = my_f (x, params); 
  # ;  my_df (x, params, df);
  
  #   ;(format *error-output* "my_fdf.... ~%")
  #   ;(format *error-output* ".......... ~%")
  #   ;(format t "x1= ~s ~%" x)
  
  my_df  $x $params  df ;# посчитаeм и запишeм градиeнт ; my_df (x, params, df)
  
  #   ;(format *error-output* ".......... ~%")

  return [my_f  $x $params] ;# возвращаeм значeниe F        ; *f = my_f (x, params); 
}
# ;-------------------------------------------------------------------------------
# ;(defun parabol_fdf (x params df) 

# ;)
# ;-------------------------------------------------------------------------------
# ;void
# ;multimin_print (int iter, gsl_multimin_fdfminimizer *s)
# ;{

# ;  fprintf (stderr, "i=%03d  ", iter);
# ;  fprintf (stderr, "f= % 8.7f  |g|= % 8.4f  |dx|= %f ", 
# ;           s->f, 
# ;           gsl_blas_dnrm2 (s->gradient), 
# ;           gsl_blas_dnrm2 (s->dx)
# ;           );

# ;  // печатаем (обобщенную) точку
# ;  // похоже печатает в конце "\n", а нам бы это не надо..
# ;  //gsl_vector_fprintf (stderr, s->x, "x= [%g]");

# ;  fprintf (stderr, "\n");

# ;  return;
# ;}
# ;-------------------------------------------------------------------------------
# ;/*  Градиентный спуск по программе GSL                                       */
# ;-------------------------------------------------------------------------------
# ;double
proc minbot_gslspusk_one {bot xyz_beg  &xyz_end } {

  #USE_REFS
  upvar ${&xyz_end} xyz_end

  # (let (
  set minproc  [$bot.MINPROC]  ;#  YT_MINPROC   *minproc = bot->minproc;
  set gslspusk [$bot.V_PARAM]  ;#  YT_GSLSPUSK *gslspusk = bot->v_param;
  
  #   end_status  ;  char *end_status;
  #   iter status ;  int 
  #   s ;  gsl_multimin_fdfminimizer *s;
  #   x ;  gsl_vector                *x;
  #   my_func ;  gsl_multimin_function_fdf  my_func;
  # ;  //double minimum, g_norma=0, x_elem;
  
  #   step_size tol
  #   )
  
  # ;  // задание самой минимизируемой функции
  # ;  my_func.f   = &my_f;
  # ;  my_func.df  = &my_df;
  # ;  my_func.fdf = &my_fdf;
  # ;  my_func.n   = DIM;
  # ;  my_func.params = bot;          // !!!!!!!!

  set my_func [make_function_fdf  "my_f" "my_df" "my_fdf"  [set [DIM]] $bot]
  
  #   ;(format *error-output* ".. 2 .. 1 ~%")
  #   ;(d_print "41-1")
  
  # ;  // начальное приближения: точка инициализации спуска
  set x [gsl_vector_alloc [set [DIM]]]   

  # ;  for (i=0; i<DIM; i++) 
  # ;    gsl_vector_set (x, i, xyz_beg[i]);

  dotimes  i [set [DIM]] {
    gsl_vector_set  x  $i [lindex $xyz_beg $i] ;# coerce -> 'double-float
  }
  
  #   ;(format *error-output* ".. 2 .. 2 ~%")
  #   ;(d_print "41-2")
  
  #   ;; создание и инициализация алгоритма
  set s  [gsl_multimin_fdfminimizer_alloc [$gslspusk.MIN_TYPE] [set [DIM]]]
  
  #   ;(format *error-output* ".. 2 .. 3 ~%")
  #   ;(d_print "41-3")
  
  set step_size [$gslspusk.STEP_SIZE]
  set tol       [$gslspusk.TOL]
  
  # ;  (format *error-output* "my_func  = ~s ~%" my_func)
  # ;  (format *error-output* "x        = ~s ~%" x)
  # ;  (format *error-output* "step_size= ~s ~%" step_size)
  # ;  (format *error-output* "tol      = ~s ~%" tol)
  
  #   ;; gsl_multimin_fdfminimizer_set (s, &my_func, x, step_size, tol);	
  gsl_multimin_fdfminimizer_set  $s  $my_func $x  $step_size $tol
	
  #   ;(format *error-output* "2.. gradient= ~s  ~%" (GRADIENT s))
  
  #   ;(format *error-output* "minbot_gslspusk_one.. ~%")
  #   ;(xxx_vector_fprintf *error-output*  "x= " x)
  


  set iter 0 ;# // начинаем итерационный спуск -------------------------
  while {1} {
  
    # ;    if (ERR_PRINT) { // тестовая печать текущего состояния
    # ;      multimin_print (iter, s);
    # ;    }
    
    # ;    // проверяем условие на количество итераций
    incr iter
    
    # ;    if (iter++ >= gslspusk->stop_iter) {
    # ;      end_status = "gsl_maxiter";
    # ;      break;
    # ;    }
    
    if  {$iter >=  [$gslspusk.STOP_ITER]} {
      set end_status "gsl_maxiter"
      break
    }
    
    #     ;(format *error-output* ".. 2 .. 6 ~%")
    #     ;(d_print "41-5")
    #     ;(format *error-output* "2.. gradient= ~s  ~%" (GRADIENT s))
    
    # ;    // выполнить одну итерацию
    set status [gsl_multimin_fdfminimizer_iterate  $s]
    
    #     ;(format *error-output* "status = ~s ~%" status)
    #     ;(d_print "41-6")
    
    # ;// gsl_vector* gsl_multimin_fdsolver_x (s) - best estimate of the location of the minimum,
    # ;// double      gsl_multimin_fdsolver_minimum (s)  - value of the function at that point,
    # ;// gsl_vector* gsl_multimin_fdsolver_gradient (s) - and its gradient;
    
    # ; // неожиданные проблемы - так и не понятно что это !!!!!
    # ; // и как с этим бороться (просто уменьшать шаг?)
    #
    if  {$status > 0} {
    
      # ;      // gsl-1.8/multimin/vector_bfgs.c:
      # ;      // -------------------------------------?????
      # ;      //  if (pnorm == 0.0 || g0norm == 0.0)
      # ;      //    {
      # ;      //      gsl_vector_set_zero (dx);
      # ;      //      return GSL_ENOPROG;
      # ;      //    }
      # ;      // ........
      # ;      // ........
      # ;      //  if (stepb == 0.0)
      # ;      //    {
      # ;      //      return GSL_ENOPROG;
      # ;      //    }
      # ;      // -------------------------------------?????
      #       ;(format *error-output* ".. 2 .. 6__ ~%")
      
      if {$status == $::GSL_ENOPROG} { 
        set end_status "gsl_enoprog" 
      } else {
        set end_status "gsl_problem"
      }

      break
    }
    
    
    #     ;(format *error-output* ".. 2 .. 7 ~%")
    #     ;(d_print "41-7")
    
    #     ;; прверяем условие на норму градиента |g| < stop_grad 
    #     ;; т.е. близость к локальному минимуму 
    #     ;; status = gsl_multimin_test_gradient (s->gradient, gslspusk->stop_grad /*epsabs*/);
    
    set status [gsl_multimin_test_gradient [$s.GRADIENT] [$gslspusk.STOP_GRAD]]
    
    #     ;(format *error-output* "status = ~s ~%" s)
    
    if {$status == $::GSL_SUCCESS} { 

      set end_status "gsl_mingrad"
      
      #       ;; все таки проверим достижение искомого значения (если задано):
      
      if {[$gslspusk.IS_STOP_FUNC] && ([$s.F] > [$gslspusk.STOP_FUNC])} {

        set end_status "gsl_MINGRAD"
      }
      
      break
    }
    
    #     ;(format *error-output* ".. 2 .. 8 ~%")
    #     ;(d_print "41-8")
    
    # ;    // A suitable choice of 'epsab' can be made from the desired accuracy in the function
    # ;    // for small variations in x. The relationship between these quantities is given by 
    # ;    // df = g * dx
    
    # ;    // Gsl-Ref (p.348) : 
    # ;    // A minimum has been found to within the user-specified precision.
    # ;    // 
    # ;    // ЭТО МОЖЕТ СОВСЕМ УБРАТЬ ??????????????????
    # ;    // заданное значение мы достигли, но оно нам зачем, если это не МИНИМУМ?
    # ;    // 
    
    #puts stderr "minbot_gslspusk_one: iter= $iter  F= [$s.F]"
    
    if {[$gslspusk.IS_STOP_FUNC]} { 
    
      #     ;(format *error-output* ".. 2 .. 8 ~%")
      #     ;(format *error-output* "f= ~s   stop_func= ~s  ~%" (F s) (STOP_FUNC gslspusk))
      
      if {[$s.F] < [$gslspusk.STOP_FUNC]} {
 
        set end_status "gsl_stopfun"

        if {0} { ;# отладка для минфун

          puts ""
          puts "set end_status gsl_stopfun : F= [$s.F] STOP_FUNC= [$gslspusk.STOP_FUNC]"
          puts ""

          exit

        }
        break
      }
    }
    #     ;; //-----------------------------------------
    
  }
  

  #   ;(d_print "41-8-")
  
  # ;  // ---------------------------------------------------------------
  # ;  // 
  # ;  //if (ERR_PRINT) { // тестовая печать конечного состояния
  # ;  //  multimin_print (iter, s);
  # ;  //  fprintf (stderr, "--------- \n");
  # ;  //  fprintf (stderr, "%s \n", end_status);
  # ;  //  fprintf (stderr, "--------- \n");
  # ;  //}
  
  # ;  // записываем и возвращаем результаты

  $gslspusk.END_STATUS = $end_status
  $gslspusk.END_NITERS = $iter
  
  # ;  for (i=0; i < DIM; i++)
  # ;    xyz_end[i] = gsl_vector_get (s->x, i);

  dotimes  i [set [DIM]] {
    lset xyz_end $i  [gsl_vector_get  [$s.X] $i]
  }
  
  #   ;(format t "minbot_gslspusk_one.. 9 ~%")
  #   ;(d_print "41-9")
  
  return [$s.F] ;#  return (s->f);
  
}
# ;===============================================================================
# ;
# ;-------------------------------------------------------------------------------
# ;void
proc minbot_gslspusk_s {bot} {

  # (let (
  #   ;;  YT_MINBOT *bot = (YT_MINBOT *) b;

  set minproc [$bot.MINPROC] ;#  YT_MINPROC   *minproc = bot->minproc;
  
  #   g ;  double g, xyz_cur[MAX_DIM];
  set xyz_cur [list_make $::MAX_DIM]

  # ;  int    n=0;
  set first 1 ;# t);  BOOL   first; ;  first = TRUE;

  # ;  //NUM_END = 0; //!!!!!!!!!!
  
  #   xyz_beg
  #   )
  
  #   ;(d_print "41")
  dotimes  n [set [NUM_BEG]] {  ;# // проводим спуск для каждой начальной точки
  
    #puts "n= $n "
    #     ;(format *error-output* ".. 1 ~%")
    
    set xyz_beg [make_xyz_from_fpoints [set [DIM]] [$minproc.S_INIT] $n]

    #     ;(d_print "41-1")
    
    #     ;; g = minbot_gslspusk_one (bot, XYZ_BEG[n], xyz_cur);    
    #     ;; (setf g (minbot_gslspusk_one  bot (aref xyz_beg n) xyz_cur)) 

    set g [minbot_gslspusk_one  $bot $xyz_beg  xyz_cur] 
    
    #     ;(d_print "41-2")
    
    if {$first} { 
      lset [FUN_END] 0   $g ;# FUN_END[0] = g;
      set first 0 ;# NIL           ;= FALSE;
    }
  }
  

  #     ;(d_print "41-3")

  minproc_check_new_solution  $minproc $xyz_cur $g ;# // прверяем возможное решение
  #     )

  #   ;(d_print "42")
  
}
# ;-------------------------------------------------------------------------------
# ;-------------------------------------------------------------------------------
# ;void
# (defun minproc_rand_init_one (
#        minproc ;YT_MINPROC *minproc
#        )

# (let (
# ;  int  /* n, */ i;
#   v ;  double  v;
# ;  //n = 0;
#   )

#   ;(format *error-output* "minproc_rand_init_one.. ~%" )

# ;  if (debug) fprintf (stderr, "XYZ_BEG= ");
#   ;(format *error-output* "XYZ_BEG= ")
    
# ;  for (i=0; i < DIM; i++) {
#   (dotimes (i (DIM))
# ;    v = YRandF (XYZ_MIN[i], XYZ_MAX[i]);
#     (setf v (YRandF (nth i (XYZ_MIN)) (nth i (XYZ_MAX)) ))

# ;    XYZ_BEG[0/*n*/][i] = v;
#     (setf (aref (XYZ_BEG) 0 i) v) ; зачeм тут двумeрный массив ?

# ;    if (debug) fprintf (stderr, "% 4.2f ", v);
#     ;(format *error-output* "~s " v )
#   )

# ;  //FUN_BEG[n] = minproc_calc_proc (minproc, XYZ_BEG[n]);
# ;  if (debug) fprintf (stderr, "\n");
#   ;(format *error-output* "~%")

#   (setf (NUM_BEG) 1) ;  NUM_BEG = 1;

# ))
# ;-------------------------------------------------------------------------------
# ;void
proc WriteXyz0 {minproc xyz} {

  # ;/*   int  i; */
  
  # ;/*   for (i=0; i<DIM; i++) { */
  # ;/*     XYZ_END[0][i] = xyz[i]; */
  # ;/*   } */
  
  # ;  minproc_write_xyzend_n (minproc, xyz, /* NUM_END */0);

  minproc_write_xyzend_n  $minproc $xyz 0
  
  set [NUM_END] 1  ;#  NUM_END = 1;

}
# ;-------------------------------------------------------------------------------
# ;void
# (defun minproc_check_new_solution_ (
#        minproc ; YT_MINPROC *minproc, 
#        xyz     ; double *xyz, 
#        g       ; double g,
#        eps     ; double eps
#        )
# ;-------------------------------------------------------------------------------
# ;void
proc minproc_check_new_solution_ {minproc xyz g eps} {

  # (let (
  #   find ;  BOOL    find;
  #   )
  
  set old [lindex [set [FUN_END]] 0]

  # ;  // три варианта для нового проверяемого значения :
  
  # ;  if      (g > FUN_END[0] + eps)  return; // большее значение

  if  {$g > [expr {$old + $eps}]} { 
 
    #     (return-from minproc_check_new_solution_)
    return
  }
  


  # // новый минимальный уровень

  if       {$g < [expr {$old - $eps}]} {

    #         (setf (nth 0 (FUN_END)) g) ;    FUN_END[0] = g;
    #         (WriteXyz0 minproc xyz)

  } else { ; #// найдено еще одно значение этого уровня

    # ;    // проверить есть ли уже такой корень !!!!
    # ;    find = fpoints_find_xyz (DIM, MM->s_calc, xyz, eps);
    set find [fpoints_find_xyz  [set [DIM]] [$minproc.S_CALC] $xyz $eps]
    
    if {! $find} { ;# // записать новое значение минимального уровня

      WriteXyz0  $minproc $xyz
    }
  }
  
}
# ;-------------------------------------------------------------------------------
# ;BOOL
# ;is_stop_func (char *status)
# ;-------------------------------------------------------------------------------
proc is_stop_func_fromstatus {status} {


  set flag [expr {[string equal $status "gsl_mingrad"] || \
                    [string equal $status "gsl_stopfun"] }]

  return $flag
}
# ;-------------------------------------------------------------------------------
# ;void
# ;botspusk_fun_data (void *self, void *mp)
# ;-------------------------------------------------------------------------------
proc botspusk_fun_data {bot minproc} {

  # ;  YT_MINBOT *bot = (YT_MINBOT *) self;
  # ;  bot->minproc = (YT_MINPROC *) mp;
  
  $bot.MINPROC = $minproc

}
# ;-------------------------------------------------------------------------------
# ;char *
proc  botspusk_for_xyzbeg {bot xyzbeg} {

  # ;(format t "botspusk_for_xyzbeg.. 1 ~%")
  
  # (let* (
  set minproc [$bot.MINPROC] ;#  YT_MINPROC  *minproc = bot->minproc;
  #   status ;  char *status;
  
  set xyz [list_make $::MAX_DIM]  ;# double xyz[MAX_DIM]; 
  
  #   ;;  g = minbot_gslspusk_one (bot,  xyzbeg, xyz);
  #   ;(g (minbot_gslspusk_one  bot xyzbeg xyz)) ;  double g
  #   g ;  double g
  
  # ;  // нужно соотнести с точностью поискового алгоритма  !!!
  # ;  // для этого нужно знать масштабы ШКАЛЫ ЗНАЧЕНИЙ ФУНКЦИИ
  # ;  //double  eps = /* EPS  */0.0001;

  set eps  0.01 ;#  double  eps = 0.01;
  #   gslspusk
  #   )
  
  # ; (format *error-output* "botspusk_for_xyzbeg.. 1 ~%")
  # ; (format *error-output* "xyzbeg= ~s ~%" xyzbeg)
  # ; ;(format t "xyz   = ~s ~%" xyz)

  set g [minbot_gslspusk_one  $bot $xyzbeg xyz]

  # ; (format *error-output* "botspusk_for_xyzbeg.. 2 ~%")
  
  lset [FUN_END] 0  $g ;#  FUN_END[0] = g;
  
  minproc_check_new_solution_ $minproc $xyz $g $eps ;# // прверяем возможное решение
  
  # ;  YT_GSLSPUSK *gslspusk = (YT_GSLSPUSK *) (bot->v_param);
  set gslspusk [$bot.V_PARAM]
  
  set status [$gslspusk.END_STATUS] ;# ;  status = gslspusk->end_status;
  
  # ;  //if (debug) {
  # ;  //fprintf (STD_ERR, "%s  niters=%4d  ", status, bot->gslspusk->end_niters);
  # ;  //printf ("\n\n");
  # ;  //}
  
  # ; (format *error-output* "botspusk_for_xyzbeg.. 3 ~%")
  
  return $status
}
# ;-------------------------------------------------------------------------------
# ;void
# (defun minproc_rand_init_one_XYZ_BEG (
#        minproc ; YT_MINPROC *minproc, 
#        xyzbeg  ; double *xyzbeg, 
#        d       ; double d
#        )

# (let (
#   delta  ; double  delta;
#   ;  int     i;
#   xyzint xyzmin xyzmax v ; double  v, xyzmin, xyzmax, xyzint;
#   )

# ;  if (debug) fprintf (stderr, "XYZ_BEG= ");
    
# ;  for (i=0; i < DIM; i++) {
#   (dotimes (i (DIM))

# ;    xyzint = (XYZ_MAX[i] - XYZ_MIN[i]);
#     (setf xyzint (- (nth i (XYZ_MAX)) (nth i (XYZ_MIN))))
#     (setf delta  (* xyzint d))

#     (setf xyzmin (- (aref xyzbeg i) delta)) ; xyzmin = xyzbeg[i] - delta;
#     (setf xyzmax (+ (aref xyzbeg i) delta)) ; xyzmax = xyzbeg[i] + delta;
#     (setf xyzmin (max (nth i (XYZ_MIN)) xyzmin))   ; xyzmin = YMAX (XYZ_MIN[i], xyzmin);
#     (setf xyzmax (min (nth i (XYZ_MAX)) xyzmax))   ; xyzmax = YMIN (XYZ_MAX[i], xyzmax);

#     (setf v (YRandF  xyzmin xyzmax))

#     (setf (aref (XYZ_BEG) 0 i) v)  ;  XYZ_BEG[0][i] = v;
# ;    if (debug) fprintf (stderr, "% 4.2f ", v);
#     )

# ;  if (debug) fprintf (stderr, "\n");

#   (setf (NUM_BEG) 1) ;  NUM_BEG = 1;
# ))
# ;-------------------------------------------------------------------------------
# ;YT_BOOL
# (defun one_XYZ_BEG (
#        bot  ;YT_MINBOT *bot, 
#        ii  ;int ii, 
#        d  ;double d
#        )

# (let* (
#   (minproc (MINPROC bot)) ;  YT_MINPROC  *minproc = bot->minproc;
# ;  int i;
# ;  int n;
#   status ;  char *status;
#   xyz_beg
#   )

# ;  for (n= 0; n< NUM_BEG; n++)  
# ;  for (i=0; i< ii; i++) {  // 
#   (dotimes (n (NUM_BEG))
#   (dotimes (i ii)

#     (setf xyz_beg (make_xyz_from_fpoints  (DIM) (S_INIT minproc) n)) 
#     ;; такой хитрый приeм

# ;    minproc_rand_init_one_XYZ_BEG (minproc, XYZ_BEG[n], d); 
#     (minproc_rand_init_one_XYZ_BEG  minproc xyz_beg d) 

# ;    status = botspusk_for_xyzbeg (bot, XYZ_BEG[0]);
# ;    if (is_stop_func (status))
# ;      return (TRUE); 

#     (setf status (botspusk_for_xyzbeg bot xyz_beg))
#     (when (is_stop_func_fromstatus status)
#       (return-from one_XYZ_BEG) 
#       )
#   ))

#  FALSE
# ))
# ;-------------------------------------------------------------------------------
# ;void
proc botspusk_fun_todo {bot} {

  # (let* (
  #   ;  YT_MINBOT *bot = (YT_MINBOT *) self;
  set minproc [$bot.MINPROC] ;#  YT_MINPROC  *minproc = bot->minproc;
  
  #   ;  //int num = bot->s_power;
  set num [$bot.LONG1] ;#  int num = bot->long1;
  #   ;  int i, n
  #   status ;  char *status;
  #   xyz_beg
  #   )
  
  YRAND_F ;#  YRAND_F;
  
  #puts stderr ""
  #puts stderr "SPUSK FOR NUM_BEG "
  #puts stderr "S_INIT  = [$minproc.S_INIT]"
  #puts stderr "NUM_BEG = [set [NUM_BEG]]"
  #puts stderr ""
  
  # ;  //--------------------------------------------
  # // проводим спуск для каждой начальной точки

  dotimes  n [set [NUM_BEG]] {
  
    set xyz_beg [make_xyz_from_fpoints [set [DIM]] [$minproc.S_INIT] $n] 
    #     ;; такой хитрый приeм
    #     ;(format *error-output* "xyz_beg= ~s ~%" xyz_beg)
    
    # ;    status = botspusk_for_xyzbeg (bot, /* n */ XYZ_BEG[n]);
    set status [botspusk_for_xyzbeg  $bot $xyz_beg]

    #puts stderr "n= $n status= $status"
    
    if {[is_stop_func_fromstatus $status]} {

      return ;# // сразу нашли нужный минимум по начальному значению
    }
  }
  


  #   ;; !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  #   ;(quit) ;
  #   ;; !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
  
  # ;  if (debug) fprintf (stderr, "SPUSK FOR NUM_BEG's VICINITY's \n");

  #puts stderr "SPUSK FOR NUM_BEG's VICINITY's "
  #puts ""
  #exit
  
  # ;  // лучше бы не просто случайные точки из всей области определения,
  # ;  // а случайные из близкой окрестности начальных точек
  # ;  //--------------------------------------------
  # ;  if (one_XYZ_BEG (bot, 10, 0.1)) return; 
  # ;  if (one_XYZ_BEG (bot, 10, 0.2)) return; 
  # ;  if (one_XYZ_BEG (bot, 10, 0.3)) return; 
  

  #   (when (one_XYZ_BEG  bot 10 0.1) (return-from botspusk_fun_todo)) 
  #   (when (one_XYZ_BEG  bot 10 0.2) (return-from botspusk_fun_todo)) 
  #   (when (one_XYZ_BEG  bot 10 0.3) (return-from botspusk_fun_todo)) 
  
  # ;  if (debug) fprintf (stderr, "SPUSK FOR RANDOM POINTS \n");
  #   (format *error-output* "SPUSK FOR RANDOM POINTS ~%")
  
  # ;  //--------------------------------------------
  # // попробуем случайные нач. точки

  dotimes  i $num {

    #     ;(format t "i= ~s ~%" i)
    #     (minproc_rand_init_one  minproc)
    
    #     ;(format t "..........222 ~%")
    
    # ;    status = botspusk_for_xyzbeg (bot, /* 0, */ XYZ_BEG[0]);
    #     (setf xyz_beg (make_xyz_from_fpoints  (DIM) (S_INIT minproc) 0)) 
    #     ;(format t "xyz_beg= ~s ~%" xyz_beg)
    #     (setf status (botspusk_for_xyzbeg  bot xyz_beg))
    
    #     ;(format t "..........333 ~%")
    # ;    if (is_stop_func_fromstatus  (status))
    # ;      return;
    
    #     (when (is_stop_func_fromstatus status)
    #       (return-from botspusk_fun_todo) 
    #     )
  }
  


  # ;  // ничего не нашли - это нас не устраивает совсем..

  #   (format t "~%")
  #   (format t "ERROR: Don't find STOPFUN minimum (~s iterations) ~%" num)
  #   (format t "~%");

  # ;  exit(0);
  
}
# ;-------------------------------------------------------------------------------
# ;void 
proc botspusk_fun_init {bot  long1 long2 long3   d1} {

  # (let* (
  # ;  YT_MINBOT *bot = (YT_MINBOT *) b;
  
  #   (conjugate_bfgs_type  (make_fdfminimizer_type 
  #                        "conjugate_bfgs"                        
  #                        'XXX_CONJUGATE_STATE_T ; sizeof (xxx_conjugate_state_t),
  #                        #'vector_bfgs_alloc
  #                        #'vector_bfgs_set 
  #                        #'vector_bfgs_iterate
  #                        ;;  &xxx_conjugate_restart,
  #                        ;;  &vector_bfgs_free
  #                        ))
  #   )
  

  set ::conjugate_bfgs_type  [make_fdfminimizer_type \
                                "conjugate_bfgs"          \
                                XXX_CONJUGATE_STATE_T     \
                                "vector_bfgs_alloc"   \
                                "vector_bfgs_set"     \
                                "vector_bfgs_iterate"]
 

  #   (setf (LONG1 bot) long1) ;  bot->long1 = long1;
  #   (setf (LONG2 bot) long2) ;  bot->long2 = long2;
  #   (setf (LONG3 bot) long3) ;  bot->long3 = long3;
  #   (setf (D1    bot) d1) ;  bot->d1 = d1;

  $bot.LONG1 = $long1
  $bot.LONG2 = $long2
  $bot.LONG3 = $long3
  $bot.D1    = $d1
  
  $bot.V_PARAM = [gslspusk_create]   ;#  bot->v_param = gslspusk_create ();
  

  #   (gslspusk_set 
  #                  (V_PARAM bot) ; bot->v_param, 
  # ;                FALSE /* TRUE */, // diff2
  #                  0.00001       ;   // diff_h
  
  #                  conjugate_bfgs_type ; gsl_multimin_fdfminimizer_vector_bfgs,
  
  #                  0.01D0   ;// размер первого пробного шага
  #                  0.01D0   ;// точность линейной минимизации
  
  # ;                // критерии останова :
  #                 0.001     ;// по норме градиента     (stop_grad )
  #                 100       ;// по количеству итераций (stop_iter )
  
  #                 d1 ;/* stop_func    */ d1, 
  #                 t ;/* is_stop_func */ TRUE             
  #                 )
 


  gslspusk_set  \
                    [$bot.V_PARAM]  \
                    0.00001         \
                    \
                    "conjugate_bfgs_type" \
                    \
                    0.01     \
                    0.01     \
                    \
                    0.001    \
                    100      \
                    \
                    $d1 \
                    1   
 
 
}
# ;===============================================================================
# ;-------------------------------------------------------------------------------
# ;void 
proc botgslspusk_1_init {  \
                  bot      \
                  long1 long2 long3 \
                  d1   \
                } {


  # (let* (
  # ;  YT_MINBOT *bot = (YT_MINBOT *) b;
  #   stop_func ;  double stop_func;
  
  set num_multy     $long1 ;#  int  num_multy    = long1;
  set is_stop_func  $long2 ;#  BOOL is_stop_func = long2;
  
  #   (conjugate_fr_type  (make_fdfminimizer_type 
  #                        "conjugate_fr"                        
  #                        'XXX_CONJUGATE_STATE_T ; sizeof (xxx_conjugate_state_t),
  #                        #'xxx_conjugate_alloc  
  #                        #'xxx_conjugate_set 
  #                        #'conjugate_fr_iterate
  #                        ;;  &xxx_conjugate_restart,
  #                        ;;  &xxx_conjugate_free
  #                        ))
  #   )
  
  set ::conjugate_fr_type  [make_fdfminimizer_type   \
                            "conjugate_fr"         \
                            XXX_CONJUGATE_STATE_T  \
                            "xxx_conjugate_alloc"  \
                            "xxx_conjugate_set"    \
                            "conjugate_fr_iterate"]
  
  if {$is_stop_func} {
    set stop_func $d1 ;# если мы точно знаем чего хотим
  } else {
    set stop_func "NIL"
  }
  
  $bot.S_POWER =  $num_multy          ;# bot->s_power  = num_multy;
  $bot.V_PARAM =  [gslspusk_create]   ;# bot->v_param = gslspusk_create ();
  
  #   (gslspusk_set 
  #                  (V_PARAM bot) ;bot->v_param,
  # ;                FALSE /* TRUE */, // diff2
  #                 0.000001         ; // diff_h
  
  #                 conjugate_fr_type ;"gsl_multimin_fdfminimizer_conjugate_fr"
  # ;                //gsl_multimin_fdfminimizer_vector_bfgs,
  
  #                 0.01D0 ; 0.01   ;// размер первого пробного шага
  #                 0.01D0   ;// точность линейной минимизации
  
  # ;                // критерии останова :
  #                 0.001    ; // stop_grad : норма градиента
  #                 100      ; // stop_iter : максимум итераций
  
  #                 stop_func
  #                 is_stop_func              
  #                 )

  
  gslspusk_set  \
                   [$bot.V_PARAM]    \
                   0.000001          \
                   \
                   "conjugate_fr_type" \
                   \
                   0.01 \
                   0.01 \
                   \
                   0.001 \
                   100   \
                   \
                   $stop_func    \
                   $is_stop_func 

  
}
# ;-------------------------------------------------------------------------------
# ;void
proc botgslspusk_1_todo {bot} {

  # ;  YT_MINBOT *bot = (YT_MINBOT *) self;
  
  # ;  // задаем случайные начальные точки:
  # ;  // (эта часть внутри алгоритма расчета или вне его должна быть ???)
  
  #   ;(format t "botgslspusk_1_todo ......... 1 ~%")
  
  minproc_rand_init [$bot.MINPROC] [$bot.S_POWER]  
  
  #   ;(format t "botgslspusk_1_todo ......... 2 ~%")
  
  # ;  //---------------------------
  minbot_gslspusk_s  $bot
  # ;  //---------------------------
  
  #   ;(format t "botgslspusk_1_todo ......... 3 ~%")
  
  # ;  if (debug) {
  # ;    YT_GSLSPUSK *gslspusk = (YT_GSLSPUSK *) (bot->v_param);
  
  # ;    fprintf (STD_ERR, "%s  niters=%4d  ",
  # ;             gslspusk->end_status, gslspusk->end_niters);
  # ;    printf ("\n\n");
  # ;  }
  
}
# ;===============================================================================
# ;
# ;===============================================================================
