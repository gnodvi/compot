# -*-   mode: tcl  ; coding: koi8   -*- ------------------------------------------

#===============================================================================
# *                                                                            *
# *  Имя этого файла: s_func.c                                                 *
# *                                                                            *
# ==============================================================================

# ;#include "a_comm.h"
# ;#include "a_plot.h"

# ;#include "b_plox.h"
# ;#include "gaul.h"

# ;#include "m_corp.h"  
# ;#include "m_fgsl.h" 

# ;#include "gaul.h" 
# ;#include "m_gaul.h" 

# ;#include "s_func.h"

# ;===============================================================================


set ::FALSE 0
set ::TRUE  1

# ;typedef double (*YT_FUNC) (int message, long long1, long long2, long long3, long long4);
# ;#define CI_MAX 10 

# ;typedef double (*YT_CALC_REZI) (void *mf, double *xyz);

# ;//-----------------------------------------

# (defclass MT_STEP () (
# ;  double    rezi; // невязка (текущая и конечная)
#   (rezi :accessor P_REZI)

# ;/*   double   *fval[CI_MAX][FI_MAX];  */

# ;  double   *fval[FI_MAX]; 
#   (fval :accessor P_FVAL)
# ))


record define MT_STEP {
  P_REZI
  
  P_FVAL
}


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# (defclass MT_FUNC () (
# ;  char      name[80]; // 
#   (name :accessor P_NAME)

# ;  double    fmin;  // ожидаемые границы решения
# ;  double    fmax;  // ожидаемые границы решения
# ;  double    ferr;  // допускаемая погрешность решения (на каждую функцию???)
#   (fmin :accessor P_FMIN)
#   (fmax :accessor P_FMAX)
#   (ferr :accessor P_FERR)

# ;  int      *mval;  // признак неизменяемости значений !!! mval[CI]
#   (mval :accessor P_MVAL)
# ))
  


record define  MT_FUNC { 

  P_NAME
  
  P_FMIN
  P_FMAX
  P_FERR
  
  P_MVAL
}
  

# ;===============================================================================

# (defclass YT_MINFUNC () (
# ;  char     name[80];  // имя функции-проекта 
#   (name :accessor P_NAME)

# ;  // параметры по x-оси
# ;  int      mdim;
# ;  double   xmin, xmax,  ymin, ymax;
#   (mdim :accessor P_MDIM)
#   (xmin :accessor P_XMIN)
#   (xmax :accessor P_XMAX)
#   (ymin :accessor P_YMIN)
#   (ymax :accessor P_YMAX)

# ;  int      cnum; // количесво приближенных калькуляций (1 - обычный расчет)
# ;  int      ccur; // текущая калькуляция

# ;  //---------------------------------------------
# ;  // каждая калькуляция - просто отдельная задача !!
# ;  // сделать отдельной структурой
# ;  int      xnum /* [CI_MAX] */, ynum; 
# ;  double   xstep/* [CI_MAX] */, ystep;
#   (xnum  :accessor P_XNUM)
#   (ynum  :accessor P_YNUM)
#   (xstep :accessor P_XSTEP)
#   (ystep :accessor P_YSTEP)

# ;  // параметры по t-оси
# ;  int      tnum, told; 
# ;  double   tstep;
#   (tnum  :accessor P_TNUM)
#   (told  :accessor P_TOLD)
#   (tstep :accessor P_TSTEP)

# ;  MT_STEP  steps[TI_MAX]; // основные массивы расчетов !!
#   (steps  :accessor P_STEPS)

# ;  int      fnum;     // количество неизвестных функций системы
#   (fnum  :accessor P_FNUM)

# ;  MT_FUNC  funcs[FI_MAX]; // описания функций (в т.ч. фиксация)
#   (funcs  :accessor P_FUNCS)

# ;  //int      *mval[FI_MAX];  // признак неизменяемости значений !!! mval[CI]
# ;  //---------------------------------------------

# ;  void    (*calc_rezi_beg) (void *mf);
# ;  void    (*calc_rezi_end) (void *mf);
# ;  YT_CALC_REZI calc_rezi;
# ;  void     *param;
#   (calc_rezi_beg :accessor CALC_REZI_BEG)
#   (calc_rezi_end :accessor CALC_REZI_END)
#   (calc_rezi     :accessor CALC_REZI)
#   (param         :accessor PARAM)

# ;  YT_TIMER *solv_timer;
# ))



record define YT_MINFUNC {

  P_NAME
  
  P_MDIM
  P_XMIN
  P_XMAX
  P_YMIN
  P_YMAX
  
  P_XNUM
  P_YNUM
  P_XSTEP
  P_YSTEP
  
  P_TNUM
  P_TOLD
  P_TSTEP
  
  P_STEPS
  
  P_FNUM
  
  P_FUNCS
  
  CALC_REZI_BEG
  CALC_REZI_END
  CALC_REZI
  PARAM
 
}




# ;//-----------------------------------------
# ;typedef double (*FUN_REZI) (void *mf, double *xyz);

# ;===============================================================================

# (defmacro mDIM () `(P_MDIM minfunc))

proc MDIM_ {} {upvar minfunc m; return [$m vget P_MDIM]}
proc MDIM_get {}    {upvar minfunc minfunc; return [set [MDIM_]]}
proc MDIM_set {val} {upvar minfunc minfunc;         set [MDIM_] $val}

# ;//---------------------------------
# ;/* #define XNUM  (minfunc->xnum [CI]) */
# ;/* #define XSTEP (minfunc->xstep[CI]) */

# (defmacro XMIN () `(P_XMIN minfunc))
proc XMIN_ {} {upvar minfunc m; return [$m vget P_XMIN]}
proc XMIN_get {}    {upvar minfunc minfunc; return [set [XMIN_]]}
proc XMIN_set {val} {upvar minfunc minfunc;         set [XMIN_] $val}

# (defmacro XMAX () `(P_XMAX minfunc))
proc XMAX_ {} {upvar minfunc m; return [$m vget P_XMAX]}
proc XMAX_get {}    {upvar minfunc minfunc; return [set [XMAX_]]}
proc XMAX_set {val} {upvar minfunc minfunc;         set [XMAX_] $val}

# (defmacro XNUM () `(P_XNUM minfunc))
proc XNUM_ {} {upvar minfunc m; return [$m vget P_XNUM]}
proc XNUM_get {}    {upvar minfunc minfunc; return [set [XNUM_]]}
proc XNUM_set {val} {upvar minfunc minfunc;         set [XNUM_] $val}


# (defmacro XSTEP () `(P_XSTEP minfunc))
proc XSTEP_ {} {upvar minfunc m; return [$m vget P_XSTEP]}
proc XSTEP_get {}    {upvar minfunc minfunc; return [set [XSTEP_]]}
proc XSTEP_set {val} {upvar minfunc minfunc;         set [XSTEP_] $val}

# (defmacro XVAL (xi) `(+ (XMIN) (* (XSTEP) ,xi)))
proc XVAL_get {xi} {upvar minfunc minfunc; return [expr {[XMIN_get] + ([XSTEP_get] * $xi) }]}

# ;//---------------------------------
# ; // уже заняты: YMIN, Y_MIN ..

# ;#define Y_BEG 0
# ;#define Y_END yNUM-1

# (defmacro YMIN () `(P_YMIN minfunc))
proc YMIN_ {} {upvar minfunc m; return [$m vget P_YMIN]}
proc YMIN_get {}    {upvar minfunc minfunc; return [set [YMIN_]]}
proc YMIN_set {val} {upvar minfunc minfunc;         set [YMIN_] $val}

# (defmacro YMAX () `(P_YMAX minfunc))
proc YMAX_ {} {upvar minfunc m; return [$m vget P_YMAX]}
proc YMAX_get {}    {upvar minfunc minfunc; return [set [YMAX_]]}
proc YMAX_set {val} {upvar minfunc minfunc;         set [YMAX_] $val}

# (defmacro YNUM () `(P_YNUM minfunc))
proc YNUM_ {} {upvar minfunc m; return [$m vget P_YNUM]}
proc YNUM_get {}    {upvar minfunc minfunc; return [set [YNUM_]]}
proc YNUM_set {val} {upvar minfunc minfunc;         set [YNUM_] $val}


# ;#define yVAL(yi) (minfunc->ymin + ySTEP * (yi))

# (defmacro YSTEP () `(P_YSTEP minfunc))
proc YSTEP_ {} {upvar minfunc m; return [$m vget P_YSTEP]}
proc YSTEP_get {}    {upvar minfunc minfunc; return [set [YSTEP_]]}
proc YSTEP_set {val} {upvar minfunc minfunc;         set [YSTEP_] $val}

# ;//---------------------------------

# (defvar   X_BEG 0)
proc X_BEG {} {return 0}
# (defmacro X_END () `(- (XNUM) 1))
proc X_END {} {upvar minfunc minfunc; return [expr {[XNUM_get] - 1}]}


# ;//---------------------------------
# ;// степень дискретизации (0-самый грубый, ....) 
# ;/* #define CI 0  */
# ;// вариант решения
# ;// #define DI 0 
# ;#define NUMER(xi,yi) ((yi)*(XNUM)+(xi))

# ;//-----------------------------------------------

# (defmacro FVAL_ARR (ti fi)    `(nth ,fi (P_FVAL (nth ,ti (P_STEPS minfunc)))))
# (defmacro FVAL     (ti fi xi) `(aref (FVAl_ARR ,ti ,fi) ,xi))

proc  FVAL_ARR_set {ti fi val} {
  upvar minfunc m; 
  set step [lindex [$m.P_STEPS] $ti] ;# взяли структуру из списка
 
  lset [$step vget P_FVAL] $fi $val  ;# 
}

proc  FVAL_ARR_get {ti fi} {
  upvar minfunc m; 
  set step [lindex [$m.P_STEPS] $ti] ;# взяли структуру из списка

  set fval_list [$step.P_FVAL]
  return [lindex $fval_list $fi]
}

proc  FVAL_set {ti fi xi  val} {
  upvar minfunc minfunc; 
  set  l [FVAL_ARR_get $ti $fi]

  lset l $xi $val 
  FVAL_ARR_set  $ti $fi  $l
}

proc  FVAL_get {ti fi xi} {
  upvar minfunc minfunc; 

  set  l [FVAL_ARR_get $ti $fi]
  return [lindex $l $xi] 
}

# ;//-----------------------------------------------

# (defmacro FVAL_2D (ti fi xi yi) (list 'aref (list 'FVAl_ARR ti fi) xi yi))

# (defmacro Fn   (fi)    `(FVAL  ti ,fi xi))
proc Fn {fi}  {upvar minfunc minfunc; upvar ti ti; upvar xi xi; return [FVAL_get  $ti $fi $xi]}

# (defmacro Fun_ (xi ti) `(FVAL ,ti  0 ,xi))
proc Fun_ {xi ti} {
  upvar minfunc minfunc; 
  return [FVAL_get  $ti 0 $xi]
}

# ;#define Fun_2D(xi,yi,ti) (FVAL_2D((ti),0,(xi),(yi)))

# ;//---------------------------------

# (defmacro TVAL (ti) `(* (P_TSTEP minfunc) ,ti)) ; (minfunc->tstep * (ti))
proc TVAL_get {ti} {upvar minfunc m; return [expr {[$m.P_TSTEP] * $ti}]}

# (defmacro FNUM () `(P_FNUM minfunc))
proc FNUM_    {}    {upvar minfunc m;  return [$m vget P_FNUM]}
proc FNUM_get {}    {upvar minfunc minfunc; return [set [FNUM_]]}
proc FNUM_set {val} {upvar minfunc minfunc;         set [FNUM_] $val}

proc FUNCS_     {}    {upvar minfunc m; return [$m vget  P_FUNCS]}
# proc FUNCS_get {}    {upvar minfunc minfunc; return [set [FUNCS]]}
# proc FUNCS_set {val} {upvar minfunc minfunc;         set [FUNCS] $val}

# (defmacro FMIN (fi) `(P_FMIN (nth ,fi (P_FUNCS minfunc))))
proc  FMIN_ {fi} {upvar minfunc m; return [[lindex [$m.P_FUNCS] $fi] vget P_FMIN]}
proc  FMIN_get {fi}     {upvar minfunc minfunc; return [set [FMIN_ $fi]]}
proc  FMIN_set {fi val} {upvar minfunc minfunc;         set [FMIN_ $fi] $val}

# (defmacro FMAX (fi) `(P_FMAX (nth ,fi (P_FUNCS minfunc))))
proc  FMAX_ {fi} {upvar minfunc m; return [[lindex [$m.P_FUNCS] $fi] vget P_FMAX]}
proc  FMAX_get {fi}     {upvar minfunc minfunc; return [set [FMAX_ $fi]]}
proc  FMAX_set {fi val} {upvar minfunc minfunc;         set [FMAX_ $fi] $val}

# (defmacro FERR (fi) `(P_FERR (nth ,fi (P_FUNCS minfunc))))
proc  FERR_ {fi} {upvar minfunc m; return [[lindex [$m.P_FUNCS] $fi] vget P_FERR]}
proc  FERR_get {fi}     {upvar minfunc minfunc; return [set [FERR_ $fi]]}
proc  FERR_set {fi val} {upvar minfunc minfunc;         set [FERR_ $fi] $val}

# (defmacro FIMQ (fi) `(P_NAME (nth ,fi (P_FUNCS minfunc))))
proc  FIMQ {fi} {upvar minfunc m; return [[lindex [$m.P_FUNCS] $fi] vget P_NAME]}
proc  FIMQ_get {fi}     {upvar minfunc minfunc; return [set [FIMQ $fi]]}
proc  FIMQ_set {fi val} {upvar minfunc minfunc;         set [FIMQ $fi] $val}

# ;//-----------------------------------------------

# (defmacro FMOD_ARR (fi)       `(P_MVAL (nth ,fi (P_FUNCS minfunc))))
# (defmacro FMOD     (fi xi)    `(aref (FMOD_ARR ,fi) ,xi))


proc  FMOD_ARR_set {fi val} {
  upvar minfunc m; 

  set func [lindex [$m.P_FUNCS] $fi] ;# взяли структуру из списка 
  $func.P_MVAL = $val                ;# поменяли в ней поле

  lset [$m vget P_FUNCS] $fi $func   ;# записали обратно с список
}

proc  FMOD_ARR_get {fi} {
  upvar minfunc m; 

  set func [lindex [$m.P_FUNCS] $fi]
  return [$func.P_MVAL]
}

proc  FMOD_set {fi xi  val} {
  upvar minfunc minfunc; 

  set  l [FMOD_ARR_get $fi]
  lset l $xi $val 

  FMOD_ARR_set  $fi  $l
}

proc  FMOD_get {fi xi} {
  upvar minfunc minfunc; 

  set  l [FMOD_ARR_get $fi]
  return [lindex $l $xi] 
}

# ;//-----------------------------------------------

# (defmacro FMOD_2D  (fi xi yi) `(aref (FMOD_ARR ,fi) ,xi ,yi))

# (defmacro REZI     (ti) `(P_REZI (nth ,ti (P_STEPS minfunc))))

proc  REZI_get {ti} {
  upvar minfunc minfunc; 

  set step [lindex [$minfunc.P_STEPS] $ti]
  return [$step.P_REZI]
}

proc  REZI_set {ti val} {
  upvar minfunc minfunc; 

  set step [lindex [$minfunc.P_STEPS] $ti]
  $step.P_REZI = $val
}

# ;//---------------------------------

# (defmacro TNUM  () `(P_TNUM minfunc)) ;/* зарезервированно слоев для оасчета  */

# (defmacro TOLD  () `(P_TOLD minfunc)) ;/* последний значимый (известный) слой */
proc TOLD_ {} {upvar minfunc m; return [$m vget P_TOLD]}
proc TOLD_get {}    {upvar minfunc minfunc; return [set [TOLD_]]}
proc TOLD_set {val} {upvar minfunc minfunc;         set [TOLD_] $val}

# (defmacro TI    () `(+ (TOLD) 1))
proc TI_get {} {upvar minfunc minfunc; return [expr {[TOLD_get] + 1}]}

# (defmacro TSTEP () `(P_TSTEP minfunc))

proc TNUM_ {} {upvar minfunc m; return [$m vget P_TNUM]}
proc TNUM_get {}    {upvar minfunc minfunc; return [set [TNUM_]]}
proc TNUM_set {val} {upvar minfunc minfunc;         set [TNUM_] $val}

proc TSTEP_ {} {upvar minfunc m; return [$m vget P_TSTEP]}
proc TSTEP_get {}    {upvar minfunc minfunc; return [set [TSTEP_]]}
proc TSTEP_set {val} {upvar minfunc minfunc;         set [TSTEP_] $val}

# (defmacro XX () `(XVAL xi)) 
proc XX {} {upvar minfunc minfunc;  upvar xi xi;  return [XVAL_get $xi]}

# ;#define X (XVAL (xi))
# ;#define T (TVAL (ti))

# (defmacro FF () `(Fn 0)) ;#define F (Fn(0))
proc FF {} {upvar minfunc minfunc; upvar ti ti; upvar xi xi; return [Fn 0]}

# ;#define G (Fn(1))

# ;===============================================================================
# ;/******************************************************************************/

# ;#define FUN(x, p_status) (function_get (minfunc, 0/*fi*/, ti, (x), p_status))

# ;//void  make_diff_xx (YT_MINFUNC *minfunc, /* static  */double *y, /* static  */double *u, 
# ;//                    double *y_xx);

# ;typedef void (*YT_SXEM_SOLVER) (YT_MINFUNC *minfunc, int ti, int sxem);

# ;//--------------------------------------------

# ;typedef struct {
# (defclass YT_ONEFUN () (
#   (on_name   :accessor ON_NAME)   ;  char     *name;

#   (task_init :accessor TASK_INIT) ;  YT_MINFUNC* (*task_init) (void *o);
#   (solv_init :accessor SOLV_INIT) ;  YT_MINBOT * (*solv_init) (void *o);

#   (param :accessor PARAM) ;  int      param;
#   (tt    :accessor TT)    ;  int      tt;
#   (dt    :accessor DT)    ;  double   dt;
# ))
# ;} YT_ONEFUN;


record define YT_ONEFUN {
  
  ON_NAME

  TASK_INIT
  SOLV_INIT

  PARAM
  TT
  DT
}

# ;===============================================================================

# ;//- для расчета градиента использовать (также) gsl_diff_central
# ;//- масштабные коеффициенты для разных уравнений
# ;//- свести к решению нелинейного уравнения (multidimensional Root-Finding) ??

# ;//- максимально точное интегрирование (numerical integration)
# ;//- разные режимы перебора контуров
# ;//- оптимизировать само суммирование по контурам

# ;//- грубый расчет начального приближения (измельчение сетки)
# ;//- упрощенный расчет невязки (другая метрика?)

# ;//- исключить или оптимизировать minfunc<->minproc
# ;//- OpenMP
# ;//- тесты и преимущесво интегр-го подхода
# ;//- добавить генетические алгоритмы
# ;//- поиск минимума с отжигом (simulated annealing)
 
# ;-------------------------------------------------------------------------------
# (defun fval_set_2d (minfunc fi 
#                             xi yi 
#                             ti  val)

#   (setf (FVAL_2D ti fi xi yi) val)

# )
# ;-------------------------------------------------------------------------------
proc fval_set {minfunc fi xi ti  val} {

  #   (setf (FVAL ti fi xi) val)
  FVAL_set   $ti $fi $xi  $val

}
# -------------------------------------------------------------------------------
# proc minfunc_print_prepare {minfunc xmin xmax} {

#   set tnum  [expr {1 + [TOLD_get]}] ;#/* последний значимый слой */ + 1
  
#   set fnum [FNUM_get]
#   set xnum [XNUM_get]

#   set plot  [plot_create  $fnum $xnum $tnum]
  
  
#   $plot.XMIN_SET = $xmin ;# // навязанные границы графиков
#   $plot.XMAX_SET = $xmax 
  
#   # установим значeния иксов

#   #dotimes  xi [$plot.L_XNUM] {}
#   dotimes  xi $xnum {

#     lset [$plot vget X] $xi [XVAL_get $xi]
#   }
  
#   # имeна всeх функций

#   #dotimes  fi [$plot.L_FNUM] {}
#   dotimes  fi $fnum {

#     PP_NAME_set $plot $fi   [FIMQ_get $fi]
#   }
  
#   # цикл по врeмeнным шагам

#   dotimes  ti [$plot.L_TNUM] {

#     PP_STEP_NAME_set $plot $ti \
#       [format "MINFUNC_PRINT:  %s (t = %d/%d  rezi = %.8f)"  \
#          [$minfunc.P_NAME] $ti [TOLD_get] [REZI_get $ti]]

#     #dotimes  fi [$plot.L_FNUM] {}
#     dotimes  fi $fnum {

#       set ylist [FVAL_ARR_get $ti $fi]

#       lset [PP_STEP_F $plot $ti]  $fi $ylist  
#     }
#   }
  
#   return $plot
# }
# -------------------------------------------------------------------------------
proc minfunc_print_prepare_NEW {minfunc xmin xmax} {

  set tnum  [expr {1 + [TOLD_get]}] ;# последний значимый слой  + 1
  
  set fnum [FNUM_get]
  set xnum [XNUM_get]

  set plot  [plot_create_NEW  $fnum $xnum $tnum]
  
  
  dict_set $plot XMIN_SET  $xmin ;# навязанные границы графиков
  dict_set $plot XMAX_SET  $xmax 
  
  # установим значeния иксов

  #dotimes  xi $xnum {

  #  lset [$plot vget X] $xi [XVAL_get $xi]
  #}
  
  # имeна всeх функций

  dotimes  fi $fnum {

    PP_NAME_set_NEW $plot $fi   [FIMQ_get $fi]
  }
  
  # цикл по врeмeнным шагам
  #
  set tnum [dict_get $plot "L_TNUM"]

  dotimes  ti $tnum {

    PP_STEP_NAME_set_NEW $plot $ti \
      [format "MINFUNC_PRINT:  %s (t = %d/%d  rezi = %.8f)"  \
         [$minfunc.P_NAME] $ti [TOLD_get] [REZI_get $ti]]

    dotimes  fi $fnum {

      #set ylist [FVAL_ARR_get $ti $fi]
      #lset [PP_STEP_F $plot $ti]  $fi $ylist 
 
      dotimes  xi $xnum {

        set xval [XVAL_get $xi]
        set yval [FVAL_get $ti $fi $xi]

        dict_set $plot "T_$ti" "F_$fi" $xval $yval 
      }

    }
  }
  
  return $plot
}
# -------------------------------------------------------------------------------
proc minfunc_print_oneti_1d {minfunc ti} {

  # s~.tl SOLV gazdin_main

#   if {0} {

#     set plot [minfunc_print_prepare  $minfunc +0 -0]
  
#     # после подготовительного этапа непосредственно печатаем график
#     # 
#     plot_print_one  $plot $ti

#   } else {

    puts ""
    minfunc_print_info $minfunc
    #puts ""

    #exit

    set plot [minfunc_print_prepare_NEW  $minfunc +0 -0]
    
    # после подготовительного этапа непосредственно печатаем график
    # 
    plot_print_one_NEW  $plot $ti
    puts ""
    puts ""
    
    #puts ""
    #puts "................ NEW !!!"
    #puts ""
    
#   }
 
  return
}
# ;-------------------------------------------------------------------------------
# ;void
# ;minfunc_print_oneti_2d (YT_MINFUNC *minfunc, int ti)
# ;{

# ;  int  xi, yi, fi=0;
# ;  double f;

# ;  for (yi=yNUM-1 ; yi>=0;   yi--) {
# ;  for (xi=0      ; xi<XNUM; xi++) {

# ;    f = FVAL_2D (ti,fi,xi,yi);
# ;    printf ("%3.1f ", f);
# ;  }
# ;  printf ("\n");
# ;  }
	
# ;  return;
# ;}
# ;-------------------------------------------------------------------------------
proc minfunc_print_one {minfunc ti} {

  if {$ti < 0} {

    set ti [TOLD_get]  ;# последний из расчитанных слоев
  } 
  
  if {[MDIM_get] == 1} {

    minfunc_print_oneti_1d $minfunc $ti
  }

  # ;  else
  # ;  if (mDIM == 2) minfunc_print_oneti_2d (minfunc, ti);
  
}
# ;-------------------------------------------------------------------------------
# (defun minfunc_print_all (minfunc)

# (let (
#   (plot (minfunc_print_prepare minfunc +0 -0))
#   )

#   (plot_print plot)

# ))
# ;-------------------------------------------------------------------------------
# (defun minfunc_print_gui (minfunc)

# (let (
#   (plot (minfunc_print_prepare minfunc +0 -0))
#   )

#   ;(plot_print plot)
#   (plot_print_gui plot)

# ))
# -------------------------------------------------------------------------------
# proc minfunc_print_tt_prepare {minfunc} {

#   set xi  0 ;#  int  ti, fi, xi=0;
  
#   set xnum  [expr {[TOLD_get] + 1}] ;# интересуют тольок посчитанные точки

#   set fnum [FNUM_get]

#   set plot  [plot_create $fnum $xnum 1]
  
#   PP_STEP_NAME_set $plot 0  "MINFUNC_PRINT_tt:"
 
 
#   #dotimes fi [$plot.L_FNUM] {}
#   dotimes fi $fnum {

#     PP_NAME_set $plot $fi   [FIMQ_get $fi]
    
#     set f_line [list_make $xnum]  ;# YMALLOC (f_line, double, xnum);    
    
#     dotimes  ti $xnum {
    
#       lset [$plot vget X] $ti [TVAL_get $ti]
      
#       lset f_line         $ti [FVAL_get $ti $fi $xi]
#     }
         
#     # попробуeм тут приклeить сформированную линию значeний
#     #     
#     lset [PP_STEP_F $plot 0]  $fi  $f_line
#   }
  
#   return $plot
# }
# -------------------------------------------------------------------------------
proc minfunc_print_tt_prepare_NEW {minfunc} {

  set xi  0 ;#  int  ti, fi, xi=0;
  
  set xnum [expr {[TOLD_get] + 1}] ;# интересуют тольок посчитанные точки
  set fnum [FNUM_get]

  set plot  [plot_create_NEW $fnum $xnum 1]
  
  PP_STEP_NAME_set_NEW $plot 0  "MINFUNC_PRINT_tt:"
 
 
  dotimes fi $fnum {

    PP_NAME_set_NEW $plot $fi   [FIMQ_get $fi]
    
    dotimes  ti $xnum {
    
      set xval [TVAL_get $ti]
      set yval [FVAL_get $ti $fi $xi]

      #puts "ti = $ti  xval = $xval  yval = $yval"

      #dict_set $plot "T_$ti" "F_$fi" $xval $yval 
      dict_set $plot "T_0" "F_$fi" $xval $yval   ;# теперь время сало иксами !
    }
         
    # попробуeм тут приклeить сформированную линию значeний
    #     
    #lset [PP_STEP_F $plot 0]  $fi  $f_line
  }
  
  #puts ""
  #puts "plot = [set $plot]"
  #puts ""

  return $plot
}
# ;-------------------------------------------------------------------------------
proc minfunc_print_one_tt {minfunc} {

  # s~.tl FUNO u0_dynamic_main 2

  #   if {0} {
  
  #     set plot [minfunc_print_tt_prepare  $minfunc]
  
  #     plot_print_one  $plot 0
  #     puts ""
  #     puts ""
  
  #   } else {

    set plot [minfunc_print_tt_prepare_NEW  $minfunc]
  
    plot_print_one_NEW  $plot 0
    puts ""
    puts ""

    #puts ""
    #puts "................ NEW !!!"
    #puts ""

#   }
  
}
# ;-------------------------------------------------------------------------------
# ;void
# ;minfunc_print_tt (YT_MINFUNC *minfunc)
# ;{

# ;  YT_PLOT *plot = minfunc_print_tt_prepare (minfunc);

# ;  // здесь надо загнать все графики в один фрейм..
# ;  plot_frames_init0 (plot);
# ;  plot_frames_init9 (plot);

# ;  plotbig_print (plot, 0,0,0,0);

# ;  return;
# ;}
# ;-------------------------------------------------------------------------------
proc minfunc_named {fi minfunc name} {

  # ;  strncpy (FIMQ(fi), name, 80);
  
  FIMQ_set $fi $name
}
# ;-------------------------------------------------------------------------------
# ;void
proc minfunc_make_malloc {minfunc fnum xnum ynum} {

  FNUM_set $fnum
  XNUM_set $xnum
  YNUM_set $ynum
  
  # (let (
  set xint [expr {[XNUM_get] - 1}] ;# // количество интервалов
  set yint [expr {[YNUM_get] - 1}] ;# // количество интервалов
  #   )
  
  if {$xint == 0}  {XSTEP_set 0} \
  else             {XSTEP_set [expr {([XMAX_get] - [XMIN_get]) / $xint}]}
  
  if {$yint == 0}  {YSTEP_set 0} \
  else             {YSTEP_set [expr {([YMAX_get] - [YMIN_get]) / $yint}]}
  
  dotimes  fi [FNUM_get] {

    #set [FMOD_ARR $fi] [make-array $xnum] ;#!!! пока сдeлаeм одномeрныe !!
    FMOD_ARR_set $fi  [list_make $xnum] ;#!!! пока сдeлаeм одномeрныe !!
    
    #     ;;  for (ti=0; ti <= TOLD; ti++) // выделяем массивы по временным слоям

    dotimes  ti [expr {1 + [TOLD_get]}] {

      FVAL_ARR_set $ti $fi  [list_make $xnum] ;#!!! пока сдeлаeм одномeрныe !!
    }
  }
  
}
# ;-------------------------------------------------------------------------------
proc create_step {} {

  # (let (
  set step [make-instance "MT_STEP"]
  #   )
  
  # ;  double   *fval[FI_MAX]; 
  #$step.P_FVAl =  [list_make $::FI_MAX]
  $step.P_FVAL =  [list_make $::FI_MAX]
  

  return $step
}
# ;-------------------------------------------------------------------------------
# (defun minfunc_create_2d (fnum name  
#                                xmin xmax xnum
#                                ymin ymax ynum)

# (let (
# ;  //int  cnum = 1; // количесво приближенных калькуляций (1 - обычный расчет)
#   fi_name

#   (minfunc (make-instance 'YT_MINFUNC))
#   )

#   ;; --------------------------------------------------------
#   ;;  MT_STEP  steps[TI_MAX]; // основные массивы расчетов !!
#   (setf (P_STEPS minfunc) (make-list TI_MAX))
#   (dotimes (i TI_MAX)
#     ;(setf (nth i (P_STEPS minfunc)) (make-instance 'MT_STEP)) ; надо явно их создать!
#     (setf (nth i (P_STEPS minfunc)) (create_step)) ; надо явно их создать!
#     )

#   ;;  MT_FUNC  funcs[FI_MAX]; // описания функций (в т.ч. фиксация)
#   (setf (P_FUNCS minfunc) (make-list FI_MAX))
#   (dotimes (i FI_MAX)
#     (setf (nth i (P_FUNCS minfunc)) (make-instance 'MT_FUNC)) 
#     )
#   ;; --------------------------------------------------------

#   (setf (MDIM) 2)

#   (setf (P_NAME minfunc) name)

#   (setf (XMIN) xmin) ; ?????
#   (setf (XMAX) xmax)
#   (setf (YMIN) ymin)
#   (setf (YMAX) ymax)

#   (setf (TOLD)  0) ; пока выделяем один счетный временной слой
#   (setf (TNUM)  1)
#   (setf (TSTEP) 0)

#   ;;  //CI = 0;
#   (minfunc_make_malloc  minfunc fnum xnum ynum)

#   (dotimes (fi (FNUM))
#     (minfunc_fmin_fmax_ferr  fi minfunc -5.0 5.0 0.1) ; ?????

#     (setf fi_name (format nil "~D" fi))
#     (minfunc_named fi minfunc fi_name)
   
#     ;; занулим маcсивы (на всякий случай) 
#     (dotimes (yi (YNUM))
#     (dotimes (xi (XNUM))
#       (minfunc_put_2d  fi minfunc xi yi 0  0.0)
#       ))
#     )


#   (setf (REZI 0) 0.0)

#   minfunc
# ))
# ;-------------------------------------------------------------------------------
# ;
# ; здeсь нeльзя использовать си-шный трюк с массивами, поэтому будeм 
# ; использовать чeстно 1-мeрный (пока).
# ;
# ;-------------------------------------------------------------------------------
proc  minfunc_create_1d {fnum name  
                         xmin xmax xnum
                         ymin ymax ynum} {

  # (let (
  # ;  //int  cnum = 1; // количесво приближенных калькуляций (1 - обычный расчет)
  
  # ;  YT_MINFUNC *minfunc;
  # ;  int  xi, yi, fi;
  # ;  char fi_name[80];
  #   fi_name
  
  set minfunc [make-instance "YT_MINFUNC"]
  #   )
  
  #   ;; --------------------------------------------------------
  # ;  MT_STEP  steps[TI_MAX]; // основные массивы расчетов !!

  $minfunc.P_STEPS = [list_make $::TI_MAX]

  dotimes  i $::TI_MAX {
    #puts "i = $i"
    lset [$minfunc vget P_STEPS] $i  [create_step] ;# надо явно их создать!
  }
  
  # ;  MT_FUNC  funcs[FI_MAX]; // описания функций (в т.ч. фиксация)

  #$minfunc.P_FUNCS =  [make-list $::FI_MAX]
  #FUNCS_set  [make-list $::FI_MAX]
  set [FUNCS_]  [list_make $::FI_MAX]

  dotimes i $::FI_MAX {
    #     (setf (nth i (P_FUNCS minfunc)) (make-instance 'MT_FUNC))
    lset [FUNCS_] $i  [make-instance "MT_FUNC"]
  }

  #   ;; --------------------------------------------------------
  
  MDIM_set 2
  
  $minfunc.P_NAME = $name
  
  XMIN_set $xmin
  XMAX_set $xmax
  YMIN_set $ymin
  YMAX_set $ymax
  
  TOLD_set  0 ;# пока выделяем один счетный временной слой
  TNUM_set  1
  TSTEP_set 0
  
  # ;  //CI = 0;
  minfunc_make_malloc  $minfunc $fnum $xnum $ynum
  
  dotimes fi [FNUM_get] {

    minfunc_fmin_fmax_ferr  $fi $minfunc -5.0 5.0 0.1
    set fi_name [format "%d" $fi]
    minfunc_named $fi $minfunc $fi_name
    
    #     ;; // занулим маcсивы (на всякий случай) 
    
    dotimes  xi [XNUM_get] {
      minfunc_put  $fi $minfunc $xi 0  0.0
    }    
  }
  
  
  #   (setf (REZI 0) 0.0)
  #set [REZI 0]  0.0
  REZI_set 0    0.0
  
  return $minfunc
}
# ;-------------------------------------------------------------------------------
# ;YT_MINFUNC*
# ;minfunc_create (int fnum, const char *name,  double xmin, double xmax, int xnum)
# ;-------------------------------------------------------------------------------
proc minfunc_create {fnum name xmin xmax xnum} {

  # (let (
  # ;  (minfunc (minfunc_create_2d  fnum name  
  # ;                               xmin xmax xnum
  # ;                               0 0 1))

  set minfunc [minfunc_create_1d  $fnum $name  \
                 $xmin $xmax $xnum  \
                 0 0 1]
  
  # ;  mDIM = 1;
  MDIM_set 1
  
  return $minfunc
}
# ;-------------------------------------------------------------------------------
# ;void
# ;minfunc_add_params (YT_MINFUNC *minfunc, 
# ;                    void   (*calc_rezi_beg) (void *mf),
# ;                    void   (*calc_rezi_end) (void *mf),
# ;                    //double (*calc_rezi)     (void *mf, double *xyz),  
# ;                    FUN_REZI calc_rezi,                
# ;                    void *param)
# ;-------------------------------------------------------------------------------
proc minfunc_add_params {minfunc  \
                           calc_rezi_beg \
                           calc_rezi_end \
                           calc_rezi     \
                           param} {

  $minfunc.CALC_REZI_BEG  = $calc_rezi_beg
  $minfunc.CALC_REZI_END  = $calc_rezi_end
  $minfunc.CALC_REZI      = $calc_rezi
  
  $minfunc.PARAM          = $param
}
# ;-------------------------------------------------------------------------------
# ; размножим заданные нач. условия на все временные слои
# ; однако можно потом переписать (если они меняются)
# ;-------------------------------------------------------------------------------
proc minfunc_add_fix_points {minfunc fi} {

  # (let (
  #   val mod 
  #   )
  
  #puts "minfunc_add_fix_points:  tnum= [expr [TNUM_get] - 1]  xnum= [XNUM_get]"
  
  # ;  for (ti=1; ti < TNUM; ti++) 
  # ;  for (xi=0; xi < XNUM; xi++) {}
  
  #   (loop for ti from 1 to (- (TNUM) 1) do
  for {set ti 1} {$ti <= [expr {[TNUM_get] - 1}]} {incr ti} {

  dotimes  xi [XNUM_get] {

    set mod [FMOD_get $fi $xi]  ;# ?????
    
    #puts "minfunc_add_fix_points:  ti= $ti  xi= $xi  mod= $mod "
    
    # ;    if (mod == FALSE) continue;
    # ;    val = FVAL (/* ti */0, fi, xi);
    
    if {$mod == $::FALSE} {continue}    
    set val [FVAL_get 0 $fi $xi]

    fval_set  $minfunc $fi $xi $ti  $val
    #  ;(format t "fval_set: ~s ~s mod=~s ~s ~s ~%" ti xi mod fi  val)
    
    #   setf (FMOD fi xi)   mod)
    FMOD_set      $fi $xi  $mod ;# ?????
    
  }}
  
}
# ;-------------------------------------------------------------------------------
proc minfunc_add_fix_points_all {minfunc} {

  dotimes  fi [FNUM_get] {

    minfunc_add_fix_points  $minfunc $fi ;# или здeсь 
  }

}
# ;-------------------------------------------------------------------------------
# ;void
proc minfunc_add_tt {minfunc tt tstep} {


  if {$tt >= $::TI_MAX}  {error "tt >= TI_MAX"}
  
  TSTEP_set $tstep
  TNUM_set  [expr {1 + $tt}] ;# // добавим временных слоев
  
  dotimes  fi [FNUM_get] {

    #     (loop for ti from 1 to (- (TNUM) 1) do
    for {set ti 1} {$ti <= [expr {[TNUM_get] - 1}]} {incr ti} {

      #set [REZI $ti] 0 ;#;; ?? чтоб было
      REZI_set $ti  0 ;#;; ?? чтоб было
      
      #       ;; выделяем массивы по временным слоям
      #       ;; YMALLOC (FVAL_ARR(ti, fi), double, XNUM);
      #       ;(setf (FVAL_ARR ti fi) (make-array (list (XNUM)))) 
      
      #       (setf (FVAL_ARR ti fi) (make-array (list (XNUM)) :initial-element 0)
      #             ) ; надо бы и обнулить их?
           
      FVAL_ARR_set $ti $fi  [list_make [XNUM_get] 0]
      #             ) ; надо бы и обнулить их?
      
      
      #       ;; размножим заданные нач. условия на все временные слои
      #       ;; однако можно потом переписать (если они меняются)
      #       ;(minfunc_add_fix_points  minfunc fi) ; только зачeм это дeлать в циклe?????
      #       ;; да eщe до инициализации нач. данных ??? !!!
    }
    
    #     ;(minfunc_add_fix_points  minfunc fi) ; уж хотя бы здeсь 
  }
  

  # ;  (dotimes (fi (FNUM))
  # ;    (minfunc_add_fix_points  minfunc fi) ; или здeсь 
  # ;    )
  # ;  (minfunc_add_fix_points_all minfunc)
  
}
# ;-------------------------------------------------------------------------------

# (defvar *minfunc_read_save* :unbound) ; эмуляция "minfunc_read_save"

# ;-------------------------------------------------------------------------------
# ;YT_MINFUNC *
# ;minfunc_read_save (char *fname, int act, YT_MINFUNC *minfunc_old)
# ;-------------------------------------------------------------------------------
proc minfunc_read_save {fname act minfunc_old} {

  # (declare (ignore fname))
  
  # (let (
  # ;  FILE *fp;
  # ;  int  fi, ti, xi;
  # ;  int    i;
  # ;  double f;
  #   minfunc
  #   )
  
  # ;  char *open_type;
  # ;  if      (act == YREAD)   open_type = "r";
  # ;  else if (act == YWRITE)  open_type = "w";
  # ;  else Error("act");

  
  if       {$act == "YREAD"}   {
    set minfunc $::minfunc_read_save
  } elseif {$act ==  "YWRITE"} {
    set ::minfunc_read_save $minfunc_old
  }
  
  # ;  if ((fp = fopen (fname, open_type)) == NULL) {
  # ;    fprintf (STD_ERR, "Cannot open file:  %s \n", fname);
  # ;    return (NULL);
  # ;  }
  # ;  //------------------------------
  # ;  minfunc = minfunc_old;
  
  # ;  if (act == YREAD) { 
  # ;    YMALLOC (minfunc, YT_MINFUNC, 1);
  # ;  }
  
  # ;  YDataRW (1, act, minfunc->name, 80, fp);
  # ;  YDataRW (11, act, &mDIM,  sizeof(int), fp);
  
  # ;  YDataRW (2, act, &XNUM,  sizeof(int), fp);
  # ;  YDataRW (3, act, &XMIN,  sizeof(double), fp);
  # ;  YDataRW (4, act, &XMAX,  sizeof(double), fp);
  # ;  YDataRW (5, act, &XSTEP, sizeof(double), fp);
  
  # ;  YDataRW (22, act, &yNUM,  sizeof(int), fp);
  # ;  YDataRW (23, act, &yMIN,  sizeof(double), fp);
  # ;  YDataRW (24, act, &yMAX,  sizeof(double), fp);
  # ;  YDataRW (25, act, &ySTEP, sizeof(double), fp);
  
  # ;  YDataRW (6, act, &TOLD,  sizeof(int), fp);
  # ;  YDataRW (9, act, &TSTEP, sizeof(double), fp);
  
  # ;  YDataRW (10, act, &FNUM, sizeof(int), fp);
  # ;  //-------------------------------------------------------
  
  # ;  //int tt = TOLD+1; // записываемых слоев (включая нулевой)
  
  # ;  //-------------------------------------------------------
  # ;  for (ti=0; ti <= TOLD; ti++) 
  # ;    YDataRW (13, act, &(REZI(ti)), sizeof(double), fp);
  
  # ;  // записать/прочитать fmin_fmax_ferr
  # ;  for (fi=0; fi < FNUM; fi++) {
  # ;    YDataRW (12, act, &(FMIN(fi)), sizeof(double), fp);
  # ;    YDataRW (12, act, &(FMAX(fi)), sizeof(double), fp);
  # ;    YDataRW (12, act, &(FERR(fi)), sizeof(double), fp);
  # ;  }
  # ;  //-------------------------------------------------------
  
  # ;  // записать/прочитать основные данные: значения и статусы 
  # ;  //-------------------------------------------------------
  # ;  if (act == YREAD) {
  # ;    minfunc_make_malloc (minfunc, FNUM, XNUM, yNUM);
  # ;  }
  
  # ;  for (fi=0; fi < FNUM; fi++) {
  # ;    YDataRW (12, act, FIMQ(fi), 80, fp);
  
  # ;    for (ti=0; ti <=TOLD; ti++) 
  # ;    for (xi=0; xi < XNUM; xi++) {
  # ;      if (act == YWRITE) f = FVAL (ti, fi, xi);  
  # ;      YDataRW (11, act, &f, sizeof(double), fp);
  
  # ;      if (act == YREAD)  fval_set (minfunc, fi, xi, ti,  f);
  # ;    }
  
  # ;    for (xi=0; xi < XNUM; xi++) {
  # ;      if (act == YWRITE) i = FMOD (fi, xi);  
  # ;      YDataRW (11, act, &i, sizeof(int), fp);
  
  # ;      if (act == YREAD)  FMOD (fi, xi) = i;
  # ;    }
  # ;  }
  # ;  //-------------------------------------------------------
  
  # ;  fclose (fp);
  
  #  minfunc  
}
# ;-------------------------------------------------------------------------------
# (defun minfunc_put_old_2d (fi minfunc xi yi 
#                               ti 
#                               val mod)

#   (fval_set_2d  minfunc fi xi yi ti  val)
#   (setf (FMOD_2D  fi xi yi) mod) ; // только на нижней границе

# )
# ;-------------------------------------------------------------------------------
# ;void
# ;minfunc_put_old (int fi, YT_MINFUNC *minfunc, int xi, int ti, 
# ;                 double val, int mod)
# ;-------------------------------------------------------------------------------
# (defun minfunc_put_old (fi minfunc xi ti val mod)

# ;  minfunc_put_old_2d (fi, minfunc, xi, /* yi */0, 
# ;                      ti, 
# ;                      val, mod);

#   (minfunc_put_old_2d  fi minfunc xi 0 
#                        ti 
#                        val mod)

# )
# ;-------------------------------------------------------------------------------
# ;void
# ;minfunc_put_fix (int fi, YT_MINFUNC *minfunc, int xi, int ti, double val)
# ;-------------------------------------------------------------------------------
# (defun minfunc_put_fix (fi minfunc xi ti val)

# ; minfunc_put_old (fi, minfunc, xi, ti, val, /* mod */TRUE);

# ;-------------------------
# ; сдeлаeм чeстно 1-мeрныe массивы

#   (setf (FVAL ti fi xi) val)
#   (setf (FMOD    fi xi) TRUE)

# )
# ;-------------------------------------------------------------------------------
# (defun minfunc_put_2d (fi minfunc xi yi 
#                           ti val)

# ;  minfunc_put_old_2d (fi, minfunc, xi, yi, ti, val, /* mod */FALSE);
#   (minfunc_put_old_2d  fi minfunc xi yi ti val FALSE)

# )
# ;-------------------------------------------------------------------------------
proc minfunc_put {fi minfunc xi ti val} {

  # ;-------------------------
  # ;  minfunc_put_2d (fi, minfunc, xi, /* yi */0, ti, val);
  # ;-------------------------
  # ; сдeлаeм чeстно 1-мeрныe массивы
  
  #   ;(setf (FVAL_2D ti fi xi yi) val)
  #   ;(setf (FMOD_2D    fi xi yi) FALSE) ; // только на нижней границе
  
  #   (setf (FVAL ti fi xi) val)
  #   (setf (FMOD    fi xi) FALSE) ; // только на нижней границе
  
  FVAL_set $ti $fi $xi   $val
  FMOD_set     $fi $xi   0 ;# FALSE // только на нижней границе
  
}
# ;-------------------------------------------------------------------------------
proc minfunc_t0_fix {fi minfunc xi val} {

  #   ;minfunc_put_old (fi, minfunc, xi, /* ti */0, val, /* mod */TRUE);
  #   ;(minfunc_put_old  fi minfunc xi 0 val t)
  
  #   ;; сдeлаeм чeстно 1-мeрныe массивы
  
  #set [FVAL 0  $fi $xi) val)
  FVAL_set 0 $fi $xi   $val

  #   (setf (FMOD    fi xi) t)
  FMOD_set   $fi $xi   1 ;# "t"
  
}
# ;-------------------------------------------------------------------------------
# ;void
# ;minfunc_t0_put_int (int fi, YT_MINFUNC *minfunc, double val, 
# ;                           int xi_beg, int xi_end)
# ;-------------------------------------------------------------------------------
proc minfunc_t0_put_int {fi minfunc val xi_beg xi_end} {

  # ;  // установить начальные условия (t=0)
  # ;  int xi;
  
  #puts "minfunc_t0_put_int: fi= $fi  xi_beg= $xi_beg  xi_end= $xi_end "
  
  for {set xi $xi_beg} {$xi <= $xi_end} {incr xi} {
  #   (loop for xi from xi_beg to xi_end do

    minfunc_put  $fi $minfunc $xi 0 $val
  }
  
}
# ;-------------------------------------------------------------------------------
# ;void
# ;minfunc_t0_put_all (int fi, YT_MINFUNC *minfunc, double val)
# ;-------------------------------------------------------------------------------
proc minfunc_t0_put_all {fi minfunc val} {

  # ;  установить начальные условия (t=0)
  
  minfunc_t0_put_int  $fi $minfunc $val [X_BEG] [X_END]

}
# ;-------------------------------------------------------------------------------
proc minfunc_fmin_fmax_ferr {n minfunc fmin fmax ferr} {

  FMIN_set $n $fmin
  FMAX_set $n $fmax
  FERR_set $n $ferr

}
# ;-------------------------------------------------------------------------------
proc minfunc_to_minproc {minfunc minproc} {

  set ti  [expr {[TOLD_get] + 1}]

  # ;  // сформировать основные константы
  set ind 0 
  
  #   ;(format t "minfunc_to_minproc .. ~%")
  
  
  dotimes  fi [FNUM_get] {
  for {set xi [X_BEG]} {$xi <= [X_END]} {incr xi} {

    if {[FMOD_get $fi $xi] == 1} {continue} ;# // значение постоянно

    #     (setf (nth ind (XYZ_MIN)) (FMIN fi))

    # ;    XYZ_MAX[ind] = FMAX(fi);
    # ;    XYZ_ERR[ind] = FERR(fi);

    #     (setf (nth ind (XYZ_MAX)) (FMAX fi))
    #     (setf (nth ind (XYZ_ERR)) (FERR fi))
    
    lset [XYZ_MAX] $ind [FMAX_get $fi]
    lset [XYZ_ERR] $ind [FERR_get $fi]

    incf ind
  }}
  
  
  # ;  DIM  = size = ind; // свободных точек функции 
  set size  $ind
  set [DIM] $ind
  

  if {[set [DIM]] == 0} {error "!DIM"}

  
  # ;  // представить неизвестную функцию в виде пространства для минимизации
  set ind 0
  
  dotimes  fi [FNUM_get] {
  for {set xi [X_BEG]} {$xi <= [X_END]} {incr xi} {

    if {[FMOD_get $fi $xi] == 1} {continue}

    # ;    // задать одно начальное приближение ???
    # ;    XYZ_BEG[0][ind++] = FVAL (ti, fi, xi);

    set v [FVAL_get $ti $fi $xi]
    #     ;(format t "v= ~s ~%" v)
    
    #     (setf (aref (XYZ_BEG) 0 ind) v)
    arr2d_set [XYZ_BEG] 0 $ind  $v  

    incf ind   
  }}
  
  set [NUM_BEG] 1
  
}
# ;-------------------------------------------------------------------------------
proc minproc_read_xyzend_n {minproc n} {

  # (let (
  set xyz [list_make [set [DIM]]]
  #   v
  #   )
  
  #   ;(format t "minproc_read_xyzend_n: ~%")
  
  dotimes  i [set [DIM]] {

    #     (setf v (aref (XYZ_END) n i))
    #     (setf (nth i xyz) v)    

    #     (setf v (aref (XYZ_END) n i))
    set v [arr2d_get [XYZ_END] $n $i]
    lset  xyz $i  $v    
  }
  
  return $xyz
}
# ;-------------------------------------------------------------------------------
# ;void
proc minproc_to_minfunc {minproc minfunc  xyz_cur} {


  set ti  [TI_get]
  
  #   ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  #puts ""
  #puts "minproc_to_minfunc: ti= $ti xyz_cur= $xyz_cur "
  #puts "PROVERKA : "
  #puts ""
  #minfunc_print_lines_ti  $minfunc 1 ;# eщe нормально !

  #   ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  
  #   ;; if (!xyz_cur) {} // окончательное (а не текущее) решение
  #
  if {$xyz_cur == "NUL"} { ;# NIL ???
    #     ;(format t "(eq xyz_cur NIL)~%")
    
    if {[set [NUM_END]] != 1} {
      puts [format t"NUM_END != 1  Don't solver!!!"]
    }
    
    #     ;; xyz_cur = XYZ_END[0]; 
    set xyz_cur [minproc_read_xyzend_n  $minproc 0] ;# ??? здeсь ОШИБКА ???

    #     ;; это мы бeрeм из  minproc  тeкущую точку (а туда она когда попала)  
    #     ;; REZI(ti) = FUN_END[0]-0.0; // в пошаговой схеме: T_CALC_BEG==T_CALC_END

    set rezi [expr {[lindex [set [FUN_END]] 0] - 0.0}]

    #puts [format t "REZI(%d) = %s " $ti $rezi]
    REZI_set $ti  $rezi
  }
  
  
  set ind 0

  #   ;(minfunc_print_lines_ti  minfunc 1) ; !!!!!!!!!!!!!!!!!!!!!
   
  dotimes fi [FNUM_get] {
  for {set xi [X_BEG]} {$xi <= [X_END]} {incr xi} {

    if {[FMOD_get $fi $xi] == 1} {continue} ;# // значение постоянно

    #     ;(setf val = xyz_cur[ind++])
    set val [lindex $xyz_cur $ind]
    
    #     ;(format t "xi=~2s ti=~2s val=~s ~%" xi ti val )
    
    fval_set  $minfunc $fi $xi $ti  $val

    incf ind   
  }}
  
  

  #   ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  #   ;(format t "~%")
  #   ;(format t "PROVERKA : ~%")
  #   ;(minfunc_print_lines_ti  minfunc 1) ; подбортился ужe гдeто!!
  #   ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  #   ;(format *error-output* "~%")  (quit)
  
}
# ;-------------------------------------------------------------------------------
# ;void
# ;minfunc_pik_tstart (int fi, YT_MINFUNC *minfunc, double w, double fc)
# ;{
# ;  int hand = w / 2 * XNUM; 
# ;  int xi;
# ;  double /* ret, */ a, b, xc, x1, /* x2, */ f;
# ;  int xi_c, xi_1, /* xi_2, */ i;

# ;  xi_c = XNUM / 2; 
# ;  xi_1 = xi_c - hand + 1;
# ;  xc = XVAL (xi_c);
# ;  x1 = XVAL (xi_1);
# ;  a  = fc / (xc - x1); b = - x1 / (xc - x1) * fc;
	
# ;  minfunc_t0_put_all (fi, minfunc, 0);

# ;  minfunc_put (fi, minfunc, xi_c, 0, fc);
# ;  for (i=1; i<hand; i++) {
# ;    xi = xi_c-i;
# ;    f  = a*X+b;
# ;    minfunc_put (fi, minfunc, xi,     0, f);
# ;    minfunc_put (fi, minfunc, xi_c+i, 0, f);
# ;  }
	
# ;  return;
# ;}
# ;-------------------------------------------------------------------------------
# ;void
# ;minfunc_cos_tstart (int fi, YT_MINFUNC *minfunc, double v_null, double v_pike)
# ;-------------------------------------------------------------------------------
proc minfunc_cos_tstart {fi minfunc v_null v_pike} {

  # (let* (
  # ;  //double v_null = 0.0;
  set v_diff  [expr {$v_pike - $v_null}]
  
  set w  0.5 
  # ;  int hand = w / 2 * XNUM; 
  set hand [floor_int [expr {($w / 2) * [XNUM_get] }]]
  
  #   xc x2 f dhand
  #   xi_c xi_2 xi ; int
  #   )
  
  minfunc_t0_put_all  $fi $minfunc $v_null
  # ;  //--------------------------------------
  
  set xi_c [floor_int [expr {[XNUM_get] / 2}]]
  set xi_2 [expr {$xi_c + $hand - 1}]
  #   ;xi_2 = xi_c + hand - 1;
  
  set xc  [XVAL_get $xi_c]
  set x2  [XVAL_get $xi_2]
  set dhand [expr {$x2 - $xc}]
  
  # ;  // задать центральную точку
  # ;  minfunc_put (fi, minfunc, xi_c, 0, v_pike/* , TRUE */);
  minfunc_put  $fi $minfunc $xi_c 0 $v_pike
  
  # ;  (format t "minfunc_cos_tstart: ~%")
  # ;  (format t "v_null = ~s ~%" v_null)
  # ;  (format t "v_diff = ~s ~%" v_diff)
  # ;  (format t "dhand  = ~s ~%" dhand)
  # ;  (format t " hand  = ~s ~%" hand)
  # ;  (format t "  xi_c = ~s ~%" xi_c)
  # ;  (format t "  xi_2 = ~s ~%" xi_2)
  
  # ;  // задать саму "горку"
  for {set i 1} {$i < $hand} {incr i} {
  #   (loop for i from 1 to (- hand 1) do
  
    # ;    xi = xi_c+i;
    # ;    f  = v_null + 0.5*v_diff * (cos (X*G_PI/dhand)+1);
    # ;    //f  = v_null + 0.5*v_diff * (cos (X*YPI/dhand));
    
    set xi [expr {$xi_c + $i}]
    #     (setf f  (+ v_null (* 0.5 v_diff (+ (cos (/ (* (XX) G_PI) dhand)) 1))))
    set f  [expr {$v_null + (0.5 * $v_diff * ((cos (([XX] * $::G_PI) / $dhand)) + 1)) }]
    
    #puts "minfunc_cos_tstart ........................."
    #puts [format  "i=%s  xi=%s  x=%s  f=%s \n" $i $xi [XX] $f]
    
    minfunc_put $fi $minfunc       $xi         0 $f
    minfunc_put $fi $minfunc [expr {$xi_c - $i}] 0 $f
  }
  
}
# ;-------------------------------------------------------------------------------
# ;void
# ;minfunc_t0_cos_i (int fi, YT_MINFUNC *minfunc, double v0, double v1,
# ;                        int xi_beg, int xi_end)
# ;-------------------------------------------------------------------------------
# (defun minfunc_t0_cos_i (fi minfunc v0 v1 xi_beg xi_end)

# (let* (
#   (xbeg  (+ (XMIN) (* xi_beg (XSTEP))))     ; double
#   (xend  (+ (XMIN) (* xi_end (XSTEP))))

#   (h    (- v1 v0))       ; // высота пупыря
#   (w    (- xend xbeg)) ; // ширина пупыря
#   (hand (/ w 2))         ; // полуширина
#   (xc   (+ xbeg hand))  ; // центр          ; double - всe пeрeмeнныe были такиe

#   ;----------------------------------
#   (ti  0) ;  int   xi, ti = 0;
#   f       ;  double f;
#   )
	
#   ;(format t "fi=~s  xi_beg=~s  xi_end=~s ~%" fi xi_beg xi_end)
#   ;(format t "5) xi_beg=~s  xi_end=~s ~%" X_BEG (X_END))
	
#   (minfunc_t0_put_all  fi minfunc v0)

# ;  for (xi=xi_beg; xi <= xi_end; xi++) {
# ;    f = v0 + h * 0.5 * (1 + cos ((X-xc)*G_PI / hand));
# ;    minfunc_put (fi, minfunc, xi, ti, f);
# ;  }
	
#   ;(format t "2 ... ~%")
#   ;; надо проэммулировать нeявноe привидeниe к типу int в циклe Си: ??
#   (setf xi_beg (floor xi_beg))
#   (setf xi_end (floor xi_end))

#   (loop for xi from xi_beg to xi_end do
#     (setf f  (+ v0 (* h 0.5 (1+ (cos (/ (* (- (XX) xc) G_PI) hand))))))
#     (minfunc_put  fi minfunc xi ti f)
#   )
	
# ))
# ;-------------------------------------------------------------------------------
# ;void
# ;minfunc_t0_cos (int fi, YT_MINFUNC *minfunc, double v0, double v1,
# ;                double x_beg, double x_end)
# ;-------------------------------------------------------------------------------
# ;
# ; помeнял x_beg -> xbeg, x_end -> xend , а иначe похожe тихо конфликтуeт 
# ; с глоб. пeрeмeнной X_BEG !!
# ;
# (defun minfunc_t0_cos (fi minfunc v0 v1 xbeg xend)

# (let (
#   (xi_beg  (YInt (/ (- xbeg (XMIN)) (XSTEP)))) ; она нe приводит к типу Int ??
#   (xi_end  (YInt (/ (- xend (XMIN)) (XSTEP)))) ; да нeт, у мeня ужe приводит (a_plot.cl)
#   )

#   (minfunc_t0_cos_i  fi minfunc v0 v1 xi_beg xi_end)

# ))
# ;-------------------------------------------------------------------------------
# ;void
# ;minfunc_t0_gap_i (int fi, YT_MINFUNC *minfunc, double v0, double v1,
# ;                        int xi_beg, int xi_end)
# ;{
# ;  //double x_beg = XMIN + xi_beg * XSTEP;
# ;  //double x_end = XMIN + xi_end * XSTEP;

# ;  //double h = v1 - v0;         // высота пупыря
# ;  //double w = x_end - x_beg;   // ширина пупыря
# ;  //double hand = w / 2;        // полуширина
# ;  //double xc   = x_beg + hand; // центр
	
# ;  minfunc_t0_put_all (fi, minfunc, v0);

# ;  int   xi, ti = 0;
# ;  double f;
# ;  for (xi=xi_beg; xi <= xi_end; xi++) {
# ;    f = v1;
# ;    minfunc_put (fi, minfunc, xi, ti, f);
# ;  }
	
# ;  return;
# ;}
# ;-------------------------------------------------------------------------------
# ;void
# ;minfunc_t0_gap (int fi, YT_MINFUNC *minfunc, double v0, double v1,
# ;                double x_beg, double x_end)
# ;{
# ;  int xi_beg = YInt ((x_beg - XMIN) / XSTEP);
# ;  int xi_end = YInt ((x_end - XMIN) / XSTEP);
	
# ;  minfunc_t0_gap_i (fi, minfunc, v0, v1, xi_beg, xi_end);

# ;  return;
# ;}
# ;-------------------------------------------------------------------------------
# ;void
# ;minfunc_lef_tstart (int fi, YT_MINFUNC *minfunc, double w, double fc)
# ;{
# ;  // сделать ступеньку                                                         
# ;  int i, i_right;

# ;  i_right = XNUM / w; 

# ;  for (i=0; i<i_right; i++)
# ;    minfunc_put (0, minfunc, i, 0, fc);

# ;  for (i=i_right; i<XNUM; i++)
# ;    minfunc_put (0, minfunc, i, 0, 0.0);
	
# ;  return;
# ;}
# ;-------------------------------------------------------------------------------
proc minfunc_info {minfunc} {

  # ;  fprintf (STD_ERR, "xx= %3d  dx= %g  \n", XNUM-1, XSTEP);
  # ;  fprintf (STD_ERR, "t0= %3d  dt= %g  \n", TOLD, TSTEP);
  
  #   (format t "xx= ~3d  dx= ~,6f  ~%"  (- (XNUM) 1) (XSTEP))
  #   (format t "t0= ~3d  dt= ~,6f  ~%"        (TOLD) (TSTEP))
  
  puts [format "xx= %3d  dx= %.6f  "  [expr {[XNUM_get] - 1}] [XSTEP_get] ]
  puts [format "t0= %3d  dt= %.6f  "  [TOLD_get]  [TSTEP_get] ]
  
}
# ;-------------------------------------------------------------------------------
proc minfunc_print_info {minfunc} {

  puts "----------- MINFUNC_PRINT_INFO ---------------------------  "
  puts ""

  minfunc_info  $minfunc

  set tnum  [expr {1 + [TOLD_get]}] ;#/* последний значимый слой */ + 1  
  set fnum  [FNUM_get]

  puts "tnum = $tnum"
  puts "fnum = $fnum"

  dotimes  ti $tnum {
  dotimes  fi $fnum {
    puts stderr "ti= $ti  fi= $fi  FVAL= [FVAL_ARR_get  $ti $fi]"
  }}

  puts ""
  puts "----------------------------------------------------------  "
  puts ""

}
# ;-------------------------------------------------------------------------------
# ;char*
# ;get_argcargv (int argc, char *argv[], int i0)
# ;{
# ;  int i;
# ;  static char buffer[180];

# ;  strcpy (buffer, "");

# ;  for (i=i0; i<argc; i++) {
# ;    strcat (buffer, argv[i]);
# ;    strcat (buffer, " ");
# ;  }

# ;  return (buffer);
# ;}
# ;-------------------------------------------------------------------------------
# ;void
# ;dinamic_t_solver_beg (char *buff, YT_MINFUNC *minfunc)
# ;-------------------------------------------------------------------------------
proc dinamic_t_solver_beg {buff minfunc} {

  # ;  time_t t;
  
  # ;  fprintf (STD_ERR, "---------------------------------------------- \n");
  puts "---------------------------------------------- "
  # ;  t = time (NULL);
  
  # ;  fprintf (STD_ERR, "> <ProgName> ");
  #   (format (STD_ERR) "> <ProgName> ")
  puts -nonewline "> <ProgName> "
  
  # ;  //for (i=0; i<argc; i++) // нафига печатать непостоянное имя проги
  # ;  // 
  # ;  // надо будет сдвинуть строку параметров, начиная ее с предметных параметров!
  
  # ;  fprintf (STD_ERR, "%s", buff);
  # ;  fprintf (STD_ERR, "\n");
  # ;  fprintf (STD_ERR, "\n");
  #   (format (STD_ERR) "~S ~%~%" buff)
  puts "$buff ??"
  
  minfunc_info $minfunc
  # ;  fprintf (STD_ERR, "\n");
  puts stderr ""
  
  # ;  minfunc->solv_timer = timer_beg ();
  
}
# ;-------------------------------------------------------------------------------
proc dinamic_t_solver_end {minfunc} {

  #   (declare (ignore minfunc))
  
  # ;  char solv_hms_time[80], *p_time;
  
  
  puts $::STD_ERR "" ;# #   (format (STD_ERR) "~%")
  
  # ;  timer_end (minfunc->solv_timer, solv_hms_time);
  
  # ;  //if (IS_TEST) p_time = "#######";
  # ;  /* else */     p_time = solv_hms_time;
  
  # ;  fprintf (STD_ERR, "Solv-Elapsed Time = %s \n", p_time);
  
  # ;  //kill_pid_free ();
  puts  $::STD_ERR "---------------------------------------------- "
  
}
# ;-------------------------------------------------------------------------------
# ;T_PROC_RETURN
# ;minfun_proc (PROC_VAR)
# ;{
# ;  static YT_MINPROC *minproc;
# ;  static YT_MINFUNC *minfunc;

# ;  double rezi;

# ;  switch (message) {
# ;  case YINIT:
# ;    // пока это расчет одного шага по времени ?
# ;    minproc = (YT_MINPROC*) ptr;
# ;    minfunc = (YT_MINFUNC*) long1;

# ;    if (minfunc->calc_rezi_beg)
# ;    minfunc->calc_rezi_beg (minfunc);
# ;    break;
# ;  case YFREE:
# ;    if (minfunc->calc_rezi_end)
# ;    minfunc->calc_rezi_end (minfunc);
# ;    break;
# ;  case YCALC:
# ;    minproc_to_minfunc (minproc, minfunc, xyz);
# ;    rezi = minfunc->calc_rezi (minfunc, xyz);

# ;    if (ret) *ret = rezi;
# ;    return (0);
# ;  }

# ;  RETURN;
# ;}
# ;-------------------------------------------------------------------------------
# ;T_PROC_RETURN
# ;minfun_proc (PROC_VAR)

# ;  static YT_MINPROC *minproc;
# ;  static YT_MINFUNC *minfunc;
# ;-------------------------------------------------------------------------------

# (defvar *minproc* :unbound)
# (defvar *minfunc* :unbound)

# ;-------------------------------------------------------------------------------
proc minfun_proc_calc {xi} {

  # (let (
  set xyz $xi
  #   )
  
  minproc_to_minfunc $::minproc $::minfunc $xyz ;#; !!!! здeсь портит !!!
  
  #   (funcall (CALC_REZI *minfunc*) *minfunc* xyz)  ; напримeр 'berger_calc_rezi
  
  [$::minfunc.CALC_REZI] $::minfunc $xyz

}
# ;-------------------------------------------------------------------------------
proc minfun_proc {message xyz fun long1 long2 ptr ret} {

  # (declare (ignore fun long2 ret))
  
  
  switch -glob $message  {
      
  "YINIT" {  
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  # ;    // пока это расчет одного шага по времени ?
  # ;    minproc = (YT_MINPROC*) ptr;
  # ;    minfunc = (YT_MINFUNC*) long1;

  set ::minproc $ptr
  set ::minfunc $long1
  
  #   ;(minfunc_print_lines_ti *minfunc* 1)
  
  # ;    if (minfunc->calc_rezi_beg)
  # ;    minfunc->calc_rezi_beg (minfunc);

  if {[$::minfunc.CALC_REZI_BEG]  != "NIL"} { 
    #       (funcall (CALC_REZI_BEG *minfunc*) *minfunc*)
    [$::minfunc.CALC_REZI_BEG]  $::minfunc
  }
  
    set ::calc_xi "minfun_proc_calc" ;#; !!!!!!!!!!
  
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  }    
  "YFREE" {    
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  # ;    if (minfunc->calc_rezi_end)
  # ;    minfunc->calc_rezi_end (minfunc);

  #   (unless (eq (CALC_REZI_END *minfunc*) NIL) 
  #     (funcall (CALC_REZI_END *minfunc*) *minfunc*))
  
  if {[$::minfunc.CALC_REZI_END]  != "NIL"} { 
    [$::minfunc.CALC_REZI_END]  $::minfunc
  }

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  }    
  "YCALC" {    
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  #   ;;????? сюда попадаeм, напримeр, при пeрeборe
  #   ;(format *error-output* "YCALC.. xyz= ~s ~%" xyz) 
  
  # ;;    double rezi;
  # ;;    minproc_to_minfunc (minproc, minfunc, xyz);
  # ;;    rezi = minfunc->calc_rezi (minfunc, xyz);
  # ;;    if (ret) *ret = rezi;
  
  #   ;(format t "YCALC:   xyz= ~s ~%" xyz)
  #   ;(quit) ; !!!!!!!!!!!!1
  
  #   (funcall *calc_xi* (coerce xyz 'list))
  
    return [$::calc_xi $xyz]

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  }
  }
  

  # ;  RETURN;
}
# ;-------------------------------------------------------------------------------
proc minfunc_solver {minfunc mbot} {

  # (let (
  set minproc [minproc_create "minfun_proc"]
  #   )
  
  minproc_begin  $minproc $minfunc 0 
  
  minfunc_to_minproc  $minfunc $minproc
  
  #   ;;------------------------------------------------
  #   ;(d_print 331)
  #   (funcall (BOT_DATA mbot) mbot minproc) ; прицeпляeм к боту данныe
  [$mbot.BOT_DATA]  $mbot $minproc

  #   ;(d_print 332)
  #   ;; вот и надо провeрить..
  
  #   ;(minfunc_print_lines_ti minfunc 1)
 
  # ;  //------------------------------------------------
  if {$::BOT_DEBUG} {

    #puts "bot = [$mbot.BOT_TODO]"
    #bot = botgslspusk_4_todo

    #minbot_print $mbot

    #exit 
  }
  # ;  //------------------------------------------------

  #   (funcall (BOT_TODO mbot) mbot) ; напускаем бота на данные
  [$mbot.BOT_TODO]  $mbot ;# !!!!!!  напускаем бота на данные

  #   ;(d_print 333)
  # ;  //------------------------------------------------
  
  minproc_to_minfunc  $minproc $minfunc "NUL"	

  #exit 
  #   ;(d_print 333)
  # ;  minproc_free (minproc);
  
}
# ;-------------------------------------------------------------------------------
# ;void
# ;minfunc_print_lines_ti (YT_MINFUNC *minfunc, int ti)
# ;{

# ;  //  (dotimes (fi (FNUM))
# ;  //    (format t "~A= ~S ~%" (FIMQ fi) (coerce (FVAL_ARR ti fi) 'list))
# ;  //    )
# ;  int fi, xi;

# ;  for (fi=0; fi < FNUM; fi++) {
# ;    fprintf (STD_ERR, "\n");
# ;    fprintf (STD_ERR, "%s=  \n", FIMQ(fi));

# ;    for (xi=X_BEG; xi <= X_END; xi++) 
# ;      fprintf (STD_ERR, "%g ", FVAL (ti, fi, xi));

# ;    fprintf (STD_ERR, "\n");
# ;  }

# ;}
# ;-------------------------------------------------------------------------------

#set ::STD_ERR stderr
set ::STD_ERR stdout ;# пока так для отладки

# ;-------------------------------------------------------------------------------
# ;void
proc dinamic_t_solver {minfunc mbot} {

  # (let (
  set is_2_slice  0 ;# FALSE)
  #   ft_1 ft_2 ft_d
  
  # ;  YT_TIMER *step_timer;
  # ;  //char  fname[80];
  # ;  char  step_hms_time[80], *p_time;
  #   p_time val
  #   )
  
  puts $::STD_ERR [format "  true ti=%3d  r= %s  " [TOLD_get] [REZI_get [TOLD_get]] ]
  #exit

  #   ;;  динамический счет по шагам времени
  #   ;;  ------------------------------------------------------
  #   (loop for ti from (+ (TOLD) 1) to (- (TNUM) 1) do

  for {set ti [expr {[TOLD_get] + 1}] }   {$ti <= [expr {[TNUM_get] - 1}]} {incr ti} {
  
    #puts stderr "dinamic_t_solve: ti= $ti !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"

    # ;    //TI = /* ti */ (TOLD+1); // новый (текущий) слой, требующий расчета
    # ;    //TOLD++;  // предыдущий (последний из расчитанных) слой
    # ;    step_timer = timer_beg ();
    
    #     ;; -----------------------------
    #     ;; начальное приближение с предыдущего слоя
    #     ;; ("хитрый" предиктор по двум слоям)
    
    set ft_d 0
    
    dotimes fi [FNUM_get] {
    #     (loop for xi from X_BEG to (X_END) do
    for {set xi [X_BEG]} {$xi <= [X_END]} {incr xi} {
        
      #       ;; нельзя забивать константные значения!!
      #       (unless (eq (FMOD fi xi) t)
      if {[FMOD_get $fi $xi] != 1} {
        
        #         ;; значeния ближнeго прeдыдущeго слоя
        set ft_1 [FVAL_get [expr {$ti - 1}] $fi $xi]
        
        #         ;; эта часть вообщe-то нe работаeт:
        
        if  {$is_2_slice && ($ti != 1)} { ;# не первый счетный слой

          #ERROR "dinamic_t_solver : !!!!!??????????!"
          #exit
          set ft_2 [FVAL_get [expr {$ti - 2}] $fi $xi] ;# с дальнeго (второго) слоя
          set ft_d [expr {$ft_1 - $ft_2}]
        }
        
        if {$is_2_slice && ($ti != 1)} { ;# не первый счетный слой
          
          set ft_2 [FVAL_get [expr {$ti - 2}] $fi $xi] ;# с дальнeго (второго) слоя
          set ft_d [expr {$ft_1 - $ft_2}]
        }
        
        #puts ""
        #puts "ft_1 = $ft_1"
        #puts ""
        
        set val [expr {$ft_1 + $ft_d}] ;# пока просто ft_1
        
        #         ;(format t "ti=~s xi=~s val=~s ~%" ti xi val)
        fval_set  $minfunc $fi $xi $ti  $val      
      }   
    }}
    

    #exit

    # ;; -----------------------------
    # ;(format t "~% ~%")
    # ;(minfunc_print_lines_ti minfunc 0)
    # ;(format t "~% ~%")
    # ;(minfunc_print_lines_ti minfunc 1)
    # ;(exit)
    
    puts -nonewline $::STD_ERR [format "  calc "]
    #exit
    
    minfunc_solver $minfunc $mbot
    
    #     ;;  timer_end (step_timer, step_hms_time);
    #     ;;  p_time = step_hms_time;
    set p_time "12345"
    
    puts -nonewline $::STD_ERR [format "ti=%3d  r= %.8f  t= %s  " $ti [REZI_get $ti] $p_time]
    puts $::STD_ERR [format ""]
    #     ;; -----------------------------
    
    # ;    (minfunc_print_one minfunc 0)
    # ;    (format (STD_ERR) "FVAL_ARR(0 0)= ~S ~%" (coerce (FVAL_ARR 0 0) 'list))
    
    incf [TOLD_] ;# предыдущий (последний из расчитанных) слой
    
    # ;    (minfunc_print_one minfunc 0) ; чe за брeд почeму тут мeняeтся ??
    # ;    (format (STD_ERR) "FVAL_ARR(0 0)= ~S ~%" (coerce (FVAL_ARR 0 0) 'list))
    # ;    (format (STD_ERR) "~% ~% ~% ~% ~% ~% ")
    
    #     ;; всегда записывать основной файл
    minfunc_read_save  "LAST_SOL" YWRITE $minfunc
    
    
  } ;# по шагам времени
  #  ------------------------------------------------------
  
}
# ;-------------------------------------------------------------------------------
# ;void
proc dinamic_t_solver_main {cmd_1 minfunc mbot} {

  # ;  //char *cmd_1 = get_argcargv (argc, argv, 1);
  # ;

  dinamic_t_solver_beg  $cmd_1 $minfunc
  dinamic_t_solver      $minfunc  $mbot
  dinamic_t_solver_end  $minfunc
  
}
# ;-------------------------------------------------------------------------------
# ;double
# ;minfunc_integral (YT_MINFUNC *minfunc, int xi_min, int xi_max, YT_SUBFUNC func, double x_param)
# ;{
# ;  int    xi;
# ;  double sum, val, k;
# ;  int mode = 2;
# ;  //XSTEP???

# ;  sum = 0;

# ;  switch (mode) {
# ;  case 1: // прямоугольники
# ;    for (xi=xi_min; xi <= xi_max; xi++) {
# ;      val = func (minfunc, xi, (long)(&x_param), 0,0);
# ;      sum += val;
# ;    }
# ;    sum = sum * XSTEP;
# ;    break;

# ;  case 2: // тпапеции
# ;    for (xi=xi_min; xi <= xi_max; xi++) {
# ;      val = func (minfunc, xi, (long)(&x_param), 0,0);
# ;      if (xi==xi_min && xi==xi_max) k = 1;
# ;      else                          k = 2;
# ;      sum += (k*val);
# ;    }
# ;    sum = sum * XSTEP/2;
# ;    break;

# ;  default: ;;;;;
# ;  }

# ;  return (sum);
# ;}
# ;===============================================================================
# ;-------------------------------------------------------------------------------
# ;void
# ;minfunc_file_info (char *fname)
# ;{
# ;  YT_MINFUNC *minfunc = minfunc_read_save (fname, YREAD, NULL);

# ;  minfunc_info (minfunc);

# ;  fprintf (STD_ERR, "\n");
# ;  return;
# ;}
# ;-------------------------------------------------------------------------------
# ;void
# ;minfunc_file_print (char *fname, int argc, char *argv[])
# ;{
# ;  double  xmin, xmax;

# ;  YT_MINFUNC *minfunc = minfunc_read_save (fname, YREAD, NULL);

# ;  xmin = +0;
# ;  xmax = -0;

# ;  if (argc == 4) {
# ;    xmin = atof (argv[2]);
# ;    xmax = atof (argv[3]);
# ;  }
# ;  minfunc_print (1/*win*/, 1/*gnu*/, minfunc,  xmin, xmax);

# ;  return;
# ;}
# ;-------------------------------------------------------------------------------
# ;void
# ;minfunc_file_print_tt (char *fname)
# ;{

# ;  YT_MINFUNC *minfunc = minfunc_read_save (fname, YREAD, NULL);
# ;  minfunc_print_tt (minfunc);

# ;  return;
# ;}
# ;-------------------------------------------------------------------------------
# ;void
# ;minfunc_file_print_one (char *fname)
# ;{

# ;  YT_MINFUNC *minfunc = minfunc_read_save (fname, YREAD, NULL);
# ;  minfunc_print_one (minfunc, -1000/*последний шаг*/);

# ;  return;
# ;}
# ;-------------------------------------------------------------------------------

# ;/* #define argv_1(str) (YStrCmp (argv[1], str)) */
# ;/* #define argv_new_1(str) (YStrCmp (argv_new[1], str)) */
# ;//#define argv_0(str) (YStrCmp (argv_new[0], str))
# ;#define argv_0(str) (YStrCmp (argv[0], str))

# ;-------------------------------------------------------------------------------
# ;YT_BOOL
# ;minfunc_info_print_ (int argc, char *argv[])
# ;{
# ;  char  *fname;

# ;  if (argc == 1)  fname = LAST_SOL;
# ;  else            fname = argv[1];

# ;/*   printf ("argc= %d  ", argc); */
# ;/*   int i; */
# ;/*   for (i=0; i<argc; i++) { */
# ;/*     printf ("%s ", argv[i]); */
# ;/*   } */
# ;/*   printf ("\n"); */

# ;  if (argv_0 ("-i")) {
# ;    minfunc_file_info (fname);
# ;    return (TRUE);
# ;  }

# ;  if (argv_0 ("-p")) {
# ;    minfunc_file_print (fname, argc, argv);
# ;    return (TRUE);
# ;  }

# ;  if (argv_0 ("-t")) {
# ;    minfunc_file_print_tt (fname);
# ;    return (TRUE);
# ;  }

# ;  if (argv_0 ("-w")) {
# ;    minfunc_file_print_one (fname);
# ;    return (TRUE);
# ;  }

# ;  return (FALSE);
# ;}
# ;-------------------------------------------------------------------------------
# ;double
# ;function_get (YT_MINFUNC *minfunc, int fi, int ti, double x_value, int *status_ok)
# ;{
# ;-------------------------------------------------------------------------------
proc function_get {minfunc fi ti x_value} {

  # (declare (ignore fi))
  
  # (let* (
  # ;  double f;
  # ;  int    xi;
  # ;  f = (x_value - minfunc->xmin) / XSTEP;
  # ; xi = YInt (f);
  
  set xreal  [expr {($x_value - [XMIN_get]) / [XSTEP_get] }]
  set xi     [YInt  $xreal]
  #   )
  
  # ;  if ((xi < 0) || (xi > XNUM-1)) {
  # ;    *status_ok = FALSE;
  # ;    return (0);
  # ;  }
  # ;  *status_ok = TRUE;
  # ;  return (F);
  
  if {($xi < 0) || ($xi > ([XNUM_get] - 1))}  {return [list  0  $::FALSE]} \
  else                                        {return [list [FF] $::TRUE]}
  
}
# ;-------------------------------------------------------------------------------
# ;void
# ;make_diff_c (YT_MINFUNC *minfunc, double *y, double *y_x/* , int x_beg, int x_end */)
# ;{
# ;  double  f1, /* f2, */ f3;
# ;  int     xi;

# ;  for (xi=X_BEG+1; xi <= X_END-1; xi++) {    
# ;    f1 = y[xi-1];
# ;    //f2 = y[xi];
# ;    f3 = y[xi+1];

# ;    y_x[xi] = (f3 - f1) / (2 *XSTEP); // центральная разность
# ;  }
# ;  y_x[X_BEG] = (y[X_BEG+1] - y[X_BEG])   / XSTEP;
# ;  y_x[X_END] = (y[X_END]   - y[X_END-1]) / XSTEP;

# ;  return;
# ;}
# ;-------------------------------------------------------------------------------
# ;void
proc make_diff_r {minfunc  y  &y_x} {

  #USE_REFS
  upvar ${&y_x} y_x

  # (let (
  #   f1 f2 ;  double  f1, f2;
  # ;  int     xi;
  #   )
  
  for {set xi [X_BEG]}  {$xi <= [expr {[X_END] - 1}]} {incr  xi} { 
  
    set f1 [lindex  $y  $xi]           ;#    f1 = y[xi];
    set f2 [lindex  $y [expr {1 + $xi}]] ;#    f2 = y[xi+1];
    
    # y_x[xi] = (f2 - f1) / XSTEP ; // правая производная 
    lset  y_x  $xi  [expr {($f2 - $f1) / [XSTEP_get]}] 
  }
  
  # ;  // на правом конце делаем левую производную
  # ;  y_x[X_END] = (y[X_END] - y[X_END-1]) / XSTEP; 
  
  #   (setf (nth (X_END) y_x) (/ (- (nth (X_END) y) (nth (- (X_END) 1) y)) (XSTEP))) 
  #
  set x_end_1  [expr {[X_END] - 1}]

  lset  y_x [X_END]  [expr {([lindex $y [X_END]] - [lindex $y $x_end_1]) /  [XSTEP_get]}] 
  
}
# ;-------------------------------------------------------------------------------
# ;void
# (defun make_diff_l (
#        minfunc ; YT_MINFUNC *minfunc, 
#        y   ; double *y, 
#        y_x ; double *y_x /* , int x_beg, int x_end */
#        )

# (let (
#   f1 f2 ;  double  f1, f2;
# ;  int     xi;
#   )

# ;  for (xi = X_BEG+1; xi <= X_END; xi++) {    
#   (loop for xi from (1+ X_BEG) to (X_END) do
#     (setf f1 (nth (- xi 1)  y)) ;    f1 = y[xi-1];
#     (setf f2 (nth    xi     y)) ;    f2 = y[xi];

#     (setf (nth xi y_x) (/ (- f2 f1) (XSTEP))) ; y_x[xi] = (f2 - f1) / XSTEP; // правая производная 
#     )

# ;  // на левом конце делаем правую производную
# ;  y_x[X_BEG] = (y[X_BEG+1] - y[X_BEG]) / XSTEP; 
#   (setf (nth X_BEG y_x) (/ (- (nth (1+ X_BEG) y) (nth X_BEG y)) 
#                              (XSTEP))) 

# ))
# ;-------------------------------------------------------------------------------
# ;void
proc make_func {minfunc &y  ti} {

  #USE_REFS
  upvar ${&y} y

  # ;  int     xi/* , ti = TI */;
  
  # ;  for (xi=X_BEG; xi <= X_END; xi++) {    
  # ;    y[xi] = Fun(xi, ti);
  # ;  }
  
  #puts "\n"
  #puts "make_func: ti= $ti X_BEG= [X_BEG]  X_END= [X_END]"
  #puts "\n"
  #minfunc_print_info $minfunc
  #puts stderr "ti= 1  fi= 0  FVAL= [FVAL_ARR_get  1 0]"

  for {set xi [X_BEG]} {$xi <= [X_END]} {incr xi} {

    set f [Fun_ $xi $ti]

    #puts "ti= $ti  xi= $xi  f= $f"

    lset y $xi  $f
  }
  
  #puts ""
  #exit

}
# ;-------------------------------------------------------------------------------
# ;void
# (defun sxem_solver (
#             minfunc          ; YT_MINFUNC *minfunc, 
#             sxem_solver_calc ; YT_SXEM_SOLVER sxem_solver_calc, 
#             sxem ; int sxem
#             )

# ;  int      ti;
# ;  YT_TIMER *step_timer;
# ;  char  step_hms_time[80], *p_time;

# ;  fprintf (STD_ERR, "  true ti=%3d  \n", TOLD/* , REZI (TOLD) */);

# ;  for (ti=TOLD+1; ti <= TNUM-1; ti++) {
#   (loop for ti from (+ (TOLD) 1) to (- (TNUM) 1) do

# ;    step_timer = timer_beg ();

# ;    sxem_solver_calc (minfunc, ti, sxem);
#     (funcall  sxem_solver_calc minfunc ti sxem)

# ;    fprintf (STD_ERR, "  calc ");
#     (format (STD_ERR) "  calc ")

# ;    //OUTD (111);
# ;    //*** glibc detected *** free(): invalid next size (fast): 0x00000000005e96c0 ***
# ;    timer_end (step_timer, step_hms_time);
# ;    //OUTD (222);
# ;    p_time = step_hms_time;

# ;    fprintf (STD_ERR, "ti=%3d  t= %s  ", ti, /* REZI(ti), */ p_time);
#     (format (STD_ERR) "ti=~3d  " ti)
#     (format (STD_ERR) "~%")

#     (incf (TOLD)) ;    TOLD++;  // предыдущий (последний из расчитанных) слой

# ;    // всегда записывать основной файл
#     (minfunc_read_save  "LAST_SOL" YWRITE minfunc)
#     )
# ;  }

# )
# ;-------------------------------------------------------------------------------
# ;void
proc  botgslspusk_4_data {bot mp} {

  # (let (
  #   ;  YT_MINBOT *bot = (YT_MINBOT *) self;

  set stop_func [$bot.D1] ;#  double     stop_func =  bot->d1; //!!
  
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
  

  #   (setf (V_PARAM bot) (gslspusk_create))  ;  bot->v_param = gslspusk_create ();
  
  $bot.V_PARAM = [gslspusk_create]   ;#  bot->v_param = gslspusk_create ();

  #   (gslspusk_set 
  #                 (V_PARAM bot) ;  bot->v_param, 
  #                 ; TRUE, //FALSE
  #                 0.00000001 ; 0.00000001, // 0.000001,
  
  #                 conjugate_bfgs_type  ; gsl_multimin_fdfminimizer_vector_bfgs,
  #                 0.01d0 ; /* размер первого пробного шага  */ 0.01, 
  #                 0.01d0 ; /* точность линейной минимизации */ 0.01, 
  
  #                 ; //        критерии останова :::::::
  #                 0.001       ; /* по норме градиента     */ /* 0.01 */ 0.001, 
  #                 100000      ; /* по количеству итераций */ /* 5000 */ 100000 ,
  
  #                 stop_func t ; /* по значению функции    */ stop_func, TRUE //???!!!
  #                 )
  
  gslspusk_set  \
                    [$bot.V_PARAM]  \
                    0.00000001      \
                    \
                    "conjugate_bfgs_type" \
                    \
                    0.01     \
                    0.01     \
                    \
                    0.001    \
                    100000   \
                    \
                    $stop_func \
                    1   
 

  # ;  //---------------------------------

  $bot.MINPROC = $mp ;#  bot->minproc = (YT_MINPROC *) mp;
  
}
# ;-------------------------------------------------------------------------------
# ;void
proc botgslspusk_4_todo {bot} {

  # (let (
  # ;  YT_MINBOT *bot = (YT_MINBOT *) self;

  set gslspusk [$bot.V_PARAM] ;#  YT_GSLSPUSK *gslspusk = (YT_GSLSPUSK *) (bot->v_param);
  #   )
  
  minbot_gslspusk_s  $bot
  
  # ;  fprintf (STD_ERR, "%s  niters=%4d  ",
  # ;           gslspusk->end_status, gslspusk->end_niters);
  
  puts -nonewline [format "%s  niters=%4d  " [$gslspusk.END_STATUS] [$gslspusk.END_NITERS]]
  
}
# ;-------------------------------------------------------------------------------
# ;YT_MINFUNC *
proc onefun_minfunc {xnum xmin xmax} {

  # (let (
  #   ;  YT_MINFUNC *minfunc;
  set minfunc  [minfunc_create 1 "OneFunTest" $xmin $xmax $xnum]
  #   )
  
  minfunc_named 0 $minfunc "U"
  
  #   ;; чeго-то мало тут, гдe инициация TT ?  в ode_sets eсть eщe:
  #   ;; (setf (TT of) tt);;  (setf (TT of) tt) ;  of->tt = tt;
  #   ;;  (setf (DT of) dt) ;  of->dt = dt;
  #   ;;  (minfun_add_rezi  minfunc calc_rezi of)   
  
  #minfunc_print $minfunc

  return  $minfunc
}
# ;-------------------------------------------------------------------------------
# ;void
proc minfun_add_rezi {minfunc fun_rezi  o} {


  minfunc_add_params  $minfunc NIL NIL $fun_rezi $o

}
# ;-------------------------------------------------------------------------------
proc onefun_make {p} {

  # (let (
  set of [make-instance "YT_ONEFUN"]
  #   )
  
  $of.ON_NAME   = [lindex $p 0]
  $of.TASK_INIT = [lindex $p 1]
  $of.SOLV_INIT = [lindex $p 2]
  
  return $of 
}
# ;-------------------------------------------------------------------------------
# ;YT_ONEFUN *
# (defun get_of_name (
#           ; int argc, 
#           ; char *argv[],
#           argus
#           ofs ; YT_ONEFUN *ofs
#           )
# ;-------------------------------------------------------------------------------
proc dolist {ind list progbody} { 

  upvar ind i

  foreach i $list [uplevel eval $progbody] ;# на коментах ошибка?

}
# ;-------------------------------------------------------------------------------
# ;YT_ONEFUN *
proc get_of_name {ofs} {

  global argc argv
  set ind 2
  #set n   [lindex $argv $ind] ; incr ind

  set argus $argv

  # (let (
  set name  "0"   ;#  char *name = "0"; по умолчанию бeрeм этот пeрвый вариант ??
  set of    "NIL" ;#  YT_ONEFUN *of = NULL;
  #   )
  
  # ;  //if (argc == 3) name = argv[2];
  # ;  if (argc >= 3) name = argv[2];

  puts ""
  puts "argus = $argus"
  puts ""

  #if {[llength $argus] > 0} {}
  if {[llength $argus] > $ind} {
    #set name [first argus]
    set name [lindex $argus $ind]
  }
  
  puts "name = $name"
  puts ""
  #exit

  #dolist  p $ofs {}
  foreach  p $ofs {

    #     ;(format t "p= ~s  f1= ~s  f2= ~s ~%" p (first p) (first argus))    
    #     ;(when (string= (first p) (first argus))

    set f [first $p]
    puts "f = $f"

    if {[string equal $f $name]} {

      set of [onefun_make $p] ;# сдeлаeм класс из списка-заготовки
      break ;#       (return)
    }
  }
  
  #   ;(when (eq (ON_NAME of) Nil) (error "of->name")) ; структура жe нe создана!

  if {$of == "NIL"} {error "GET_OF_NAME: of->name"} ;# структура жe нe создана!
  
  # ;  if (argc == 4) { // любой символ, например ... @ 
  # ;    of->solv_init = gaul_mbot; 
  # ;  }
  
  return $of ;#  return (of);
}
# ;-------------------------------------------------------------------------------
proc  onefun_main_calc {ofs} {

  set of  [get_of_name $ofs] ;# пока возьмeм пeрвоe заданиe из списка
   
  
  $of.TT = 0 ;# здeсь что-ли установить заглушки-нули?
  $of.DT = 0 ;# 
  
  # создаем задачу по функции-условию
  # 
  set minfunc [[$of.TASK_INIT] $of] 
  

  if {[$of.SOLV_INIT] != "NIL"} { 

    set mbot [[$of.SOLV_INIT] $of] ;# инициация бота
   
  } else {
 
    # если бот конкретно не задан - берем обобщенный бот

    if {$::BOT_DEBUG} {
      set stopfun $::BOT_DEBUG
    } else {
      set stopfun 0.0001
    }

    set mbot [minbot_make "" \
              "NIL"  \
              "botgslspusk_4_data"  \
              "botgslspusk_4_todo"  \
                0 0 0   \
                $stopfun] ;# stopfun = 0.0001

  }
  
  # ------------------------------------------
  
  set tt [$of.TT] ;#  int    tt = of->tt;
  set dt [$of.DT] ;#  double dt = of->dt;
  
  # если уравнения стационарны, то шаг по времени - не важен!

  if {$tt == 0} {set tt 1  } 
  if {$dt == 0} {set dt 1.0}
  
  minfunc_read_save  "LAST_SOL" YWRITE $minfunc
  
  minfunc_add_tt              $minfunc  $tt $dt 
  minfunc_add_fix_points_all  $minfunc
  
  # ------------------------------------------

  dinamic_t_solver_main "argus"  $minfunc $mbot ;# ?? argus == cmd_1 &&
  

  puts ""
  
  if {$tt == 1} { ;# // чисто статическая 1-мерная задача

    minfunc_print_one     $::minfunc_read_save -1000 ;# послeднюю запись    
  } else {
    
    minfunc_print_one_tt  $::minfunc_read_save
  }

  return
}
# ;===============================================================================
# ;//
# ;===============================================================================
