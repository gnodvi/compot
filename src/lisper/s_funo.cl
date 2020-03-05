; -*-   mode: lisp ; coding: koi8   -*- ----------------------------------------

;-------------------------------------------------------------------------------
;===============================================================================
; *                                                                            *
; *  Имя этого файла: s_func.c                                                 *
; *                                                                            *
;-------------------------------------------------------------------------------
                                                                             
; ANKOCA : A NEW KIND OF CELLULAR AUTOMATA      !
; GI-CA  : Global Integrality Cellular Automata !
; 
; сразу удовлeтворяeм нeкоторым законам сохранeния и ищeм движeниe
; как минимальный по каким-то парамeтрам путь

;===============================================================================

;#include "a_comm.h"
;#include "a_plot.h"

;#include "b_plox.h"
;#include "gaul.h"

;#include "m_corp.h"  
;#include "m_fgsl.h" 

;#include "gaul.h" 
;#include "m_gaul.h" 

;#include "s_func.h"

;===============================================================================


;typedef double (*YT_FUNC) (int message, long long1, long long2, long long3, long long4);
;#define CI_MAX 10 

;typedef double (*YT_CALC_REZI) (void *mf, double *xyz);

;//-----------------------------------------

(defclass MT_STEP () (
;  double    rezi; // невязка (текущая и конечная)
  (rezi :accessor P_REZI)

;/*   double   *fval[CI_MAX][FI_MAX];  */

;  double   *fval[FI_MAX]; 
  (fval :accessor P_FVAL)
))

(defclass MT_FUNC () (
;  char      name[80]; // 
  (name :accessor P_NAME)

;  double    fmin;  // ожидаемые границы решения
;  double    fmax;  // ожидаемые границы решения
;  double    ferr;  // допускаемая погрешность решения (на каждую функцию???)
  (fmin :accessor P_FMIN)
  (fmax :accessor P_FMAX)
  (ferr :accessor P_FERR)

;  int      *mval;  // признак неизменяемости значений !!! mval[CI]
  (mval :accessor P_MVAL)
))
  

(defclass YT_MINFUNC () (
;  char     name[80];  // имя функции-проекта 
  (name :accessor P_NAME)

;  // параметры по x-оси
;  int      mdim;
;  double   xmin, xmax,  ymin, ymax;
  (mdim :accessor P_MDIM)
  (xmin :accessor P_XMIN)
  (xmax :accessor P_XMAX)
  (ymin :accessor P_YMIN)
  (ymax :accessor P_YMAX)

;  int      cnum; // количесво приближенных калькуляций (1 - обычный расчет)
;  int      ccur; // текущая калькуляция

;  //---------------------------------------------
;  // каждая калькуляция - просто отдельная задача !!
;  // сделать отдельной структурой
;  int      xnum /* [CI_MAX] */, ynum; 
;  double   xstep/* [CI_MAX] */, ystep;
  (xnum  :accessor P_XNUM)
  (ynum  :accessor P_YNUM)
  (xstep :accessor P_XSTEP)
  (ystep :accessor P_YSTEP)

;  // параметры по t-оси
;  int      tnum, told; 
;  double   tstep;
  (tnum  :accessor P_TNUM)
  (told  :accessor P_TOLD)
  (tstep :accessor P_TSTEP)

;  MT_STEP  steps[TI_MAX]; // основные массивы расчетов !!
  (steps  :accessor P_STEPS)

;  int      fnum;     // количество неизвестных функций системы
  (fnum  :accessor P_FNUM)

;  MT_FUNC  funcs[FI_MAX]; // описания функций (в т.ч. фиксация)
  (funcs  :accessor P_FUNCS)

;  //int      *mval[FI_MAX];  // признак неизменяемости значений !!! mval[CI]
;  //---------------------------------------------

;  void    (*calc_rezi_beg) (void *mf);
;  void    (*calc_rezi_end) (void *mf);
;  YT_CALC_REZI calc_rezi;
;  void     *param;
  (calc_rezi_beg :accessor CALC_REZI_BEG)
  (calc_rezi_end :accessor CALC_REZI_END)
  (calc_rezi     :accessor CALC_REZI)
  (param         :accessor PARAM)

;  YT_TIMER *solv_timer;
))

;//-----------------------------------------
;typedef double (*FUN_REZI) (void *mf, double *xyz);

;===============================================================================

(defmacro mDIM () `(P_MDIM minfunc))

;//---------------------------------
;/* #define XNUM  (minfunc->xnum [CI]) */
;/* #define XSTEP (minfunc->xstep[CI]) */

(defvar   X_BEG 0)
(defmacro X_END () `(- (XNUM) 1))

(defmacro XMIN () `(P_XMIN minfunc))
(defmacro XMAX () `(P_XMAX minfunc))
(defmacro XNUM () `(P_XNUM minfunc))

(defmacro XSTEP () `(P_XSTEP minfunc))
(defmacro XVAL (xi) `(+ (XMIN) (* (XSTEP) ,xi)))

;//---------------------------------
; // уже заняты: YMIN, Y_MIN ..

;#define Y_BEG 0
;#define Y_END yNUM-1

(defmacro YMIN () `(P_YMIN minfunc))
(defmacro YMAX () `(P_YMAX minfunc))
(defmacro YNUM () `(P_YNUM minfunc))

;#define yVAL(yi) (minfunc->ymin + ySTEP * (yi))
(defmacro YSTEP () `(P_YSTEP minfunc))

;//---------------------------------
;// степень дискретизации (0-самый грубый, ....) 
;/* #define CI 0  */
;// вариант решения
;// #define DI 0 
;#define NUMER(xi,yi) ((yi)*(XNUM)+(xi))

(defmacro FVAl_ARR (ti fi)    `(nth ,fi (P_FVAL (nth ,ti (P_STEPS minfunc)))))
(defmacro FVAL     (ti fi xi) `(aref (FVAl_ARR ,ti ,fi) ,xi))

(defmacro FVAL_2D (ti fi xi yi) (list 'aref (list 'FVAl_ARR ti fi) xi yi))

(defmacro Fn   (fi)    `(FVAL  ti ,fi xi))
(defmacro Fun_ (xi ti) `(FVAL ,ti  0 ,xi))

;#define Fun_2D(xi,yi,ti) (FVAL_2D((ti),0,(xi),(yi)))

;//---------------------------------

(defmacro TVAL (ti) `(* (P_TSTEP minfunc) ,ti)) ; (minfunc->tstep * (ti))

(defmacro FNUM () `(P_FNUM minfunc))

(defmacro FMIN (fi) `(P_FMIN (nth ,fi (P_FUNCS minfunc))))
(defmacro FMAX (fi) `(P_FMAX (nth ,fi (P_FUNCS minfunc))))
(defmacro FERR (fi) `(P_FERR (nth ,fi (P_FUNCS minfunc))))
(defmacro FIMQ (fi) `(P_NAME (nth ,fi (P_FUNCS minfunc))))

(defmacro FMOD_ARR (fi)       `(P_MVAL (nth ,fi (P_FUNCS minfunc))))
(defmacro FMOD     (fi xi)    `(aref (FMOD_ARR ,fi) ,xi))
(defmacro FMOD_2D  (fi xi yi) `(aref (FMOD_ARR ,fi) ,xi ,yi))
(defmacro REZI     (ti) `(P_REZI (nth ,ti (P_STEPS minfunc))))

;//---------------------------------

(defmacro TNUM  () `(P_TNUM minfunc)) ;/* зарезервированно слоев для оасчета  */
(defmacro TOLD  () `(P_TOLD minfunc)) ;/* последний значимый (известный) слой */
(defmacro TI    () `(+ (TOLD) 1))
(defmacro TSTEP () `(P_TSTEP minfunc))

(defmacro XX () `(XVAL xi)) 
;#define X (XVAL (xi))
;#define T (TVAL (ti))

(defmacro FF () `(Fn 0)) ;#define F (Fn(0))
;#define G (Fn(1))

;===============================================================================
;/******************************************************************************/

;#define FUN(x, p_status) (function_get (minfunc, 0/*fi*/, ti, (x), p_status))

;//void  make_diff_xx (YT_MINFUNC *minfunc, /* static  */double *y, /* static  */double *u, 
;//                    double *y_xx);

;typedef void (*YT_SXEM_SOLVER) (YT_MINFUNC *minfunc, int ti, int sxem);

;//--------------------------------------------

;typedef struct {
(defclass YT_ONEFUN () (
  (on_name   :accessor ON_NAME)   ;  char     *name;

  (task_init :accessor TASK_INIT) ;  YT_MINFUNC* (*task_init) (void *o);
  (solv_init :accessor SOLV_INIT) ;  YT_MINBOT * (*solv_init) (void *o);

  (param :accessor PARAM) ;  int      param;
  (tt    :accessor TT)    ;  int      tt;
  (dt    :accessor DT)    ;  double   dt;
))
;} YT_ONEFUN;

;===============================================================================

;//- для расчета градиента использовать (также) gsl_diff_central
;//- масштабные коеффициенты для разных уравнений
;//- свести к решению нелинейного уравнения (multidimensional Root-Finding) ??

;//- максимально точное интегрирование (numerical integration)
;//- разные режимы перебора контуров
;//- оптимизировать само суммирование по контурам

;//- грубый расчет начального приближения (измельчение сетки)
;//- упрощенный расчет невязки (другая метрика?)

;//- исключить или оптимизировать minfunc<->minproc
;//- OpenMP
;//- тесты и преимущесво интегр-го подхода
;//- добавить генетические алгоритмы
;//- поиск минимума с отжигом (simulated annealing)
 
;-------------------------------------------------------------------------------
(defun fval_set_2d (minfunc fi 
                            xi yi 
                            ti  val)

  (setf (FVAL_2D ti fi xi yi) val)

)
;-------------------------------------------------------------------------------
(defun fval_set (minfunc fi xi ti  val)

  (setf (FVAL ti fi xi) val)

)
;-------------------------------------------------------------------------------
(defun minfunc_print_prepare (minfunc xmin xmax)

(let* (
  (tnum  (1+ (TOLD))) ;/* последний значимый слой */ + 1

  (plot  (plot_create (FNUM) (XNUM) tnum))
  )

;(format *error-output* "41 ... ~%")

  (setf (XMIN_SET plot) xmin) ; // навязанные границы графиков
  (setf (XMAX_SET plot) xmax)
	
;(format *error-output* "42 ... ~%")
  ;; значeния иксов
  (dotimes (xi (L_XNUM plot))
    (setf (nth xi (X plot))  (XVAL xi))
    )

;(format *error-output* "43 ... ~%")
  ;; имeна всeх функций
  (dotimes (fi (L_FNUM plot))
    (setf (PP_NAME plot fi) (FIMQ fi))
    )

;(format *error-output* "44 ... ~%")
  ;; цикл по врeмeнным шагам
  (dotimes (ti (L_TNUM plot))
    (setf (PP_STEP_NAME plot ti) 
          (format nil "MINFUNC_PRINT:  ~s (t = ~d/~d  rezi = ~,8f)" 
                  (P_NAME minfunc) ti (TOLD) (REZI ti)
                  ))    
    ;; 
    (dotimes (fi (L_FNUM plot))
      (setf (PP_STEP_F plot ti fi) (coerce (FVAL_ARR ti fi) 'list))  ;??   
      )
    )

;(format *error-output* "45 ... ~%")

;(when is_libc ; пока не знаю какими функциями заменить Y-system
#+CLISP  (plot_save plot)
;)
  ;(format t ".................. plot_save ~%")
;(format *error-output* "46 ... ~%")

  plot
))
;-------------------------------------------------------------------------------
;YT_PLOT *
(defun minfunc_print_tt_prepare (minfunc)

(let* (
  (xi  0);  int  ti, fi, xi=0;
;  YT_PLOT *plot;
  f_line ;  double  *f_line;

  (xnum  (+ (TOLD) 1)) ; // интересуют тольок посчитанные точки
  (plot  (plot_create (FNUM) xnum 1))
  )

;  sprintf (P_TITLE (plot,/* ti */0), "MINFUNC_PRINT_tt:");
  (setf (PP_STEP_NAME plot 0) "MINFUNC_PRINT_tt:")

;  for (fi=0 ; fi < plot->fnum ; fi++) {
  (dotimes (fi (L_FNUM plot))
;    P_NAME(plot, fi) = FIMQ(fi);
    (setf (PP_NAME plot fi) (FIMQ fi))

    (setf f_line (make-list xnum))    ;    YMALLOC (f_line, double, xnum);    
    ;(setf (PP_STEP_F plot 0 fi) f_line) ;    P_LINE (plot,fi,0) = f_line;
    

;    for (ti=0 ; ti<plot->xnum; ti++) {
    (dotimes (ti xnum)
;      plot->x[ti] = TVAL(ti);
      (setf (nth ti (X plot))  (TVAL ti)) ; в массив Х записали врeмeна

;      //f_line[ti]  = FVAL(fi,xi,ti);
;      f_line[ti]  = FVAL(ti,fi,xi);

      (setf (nth ti f_line) (FVAL ti fi xi))   
      ;(setf (nth ti (PP_STEP_F plot ti fi) (FVAL ti fi xi))   
      ;(setf (PP_STEP_F plot ti fi) (coerce (FVAL_ARR ti fi) 'list))  ;??   

      )

    ;(format t "fi=~s  name=~s  f_line=~s  ~%" fi (PP_NAME plot fi) f_line) 

    ;; попробуeм тут приклeить сформированную линию значeний
    (setf (PP_STEP_F plot 0 fi) f_line) 
;    }
    )
;  }

  ;(format t "minfunc_print_tt_prepare ... 999 ~%")
  ;(plot_print_info plot)
	
  plot ;  return (plot);
))
;-------------------------------------------------------------------------------
;void
;minfunc_print (BOOL is_win, BOOL is_gnu, YT_MINFUNC *minfunc, 
;               double xmin, double xmax)
;{
;  YT_PLOT *plot;

;  plot = minfunc_print_prepare (minfunc, xmin, xmax);

;  // после подготовительного этапа непосредственно печатаем график
;  plotbig_print (plot, 0,0,0,0);

;  return;
;}
;-------------------------------------------------------------------------------
(defun minfunc_print_oneti_1d (minfunc ti)

;(format *error-output* "40 ... ~%")

(let (
  (plot (minfunc_print_prepare minfunc +0 -0))
  )

;(format *error-output* "49 ... ~%")

;  // после подготовительного этапа непосредственно печатаем график
  (plot_print_one plot ti)

  ;(format t "9 ..... ~%")

  ;(plot_save plot)
))
;-------------------------------------------------------------------------------
;void
;minfunc_print_oneti_2d (YT_MINFUNC *minfunc, int ti)
;{

;  int  xi, yi, fi=0;
;  double f;

;  for (yi=yNUM-1 ; yi>=0;   yi--) {
;  for (xi=0      ; xi<XNUM; xi++) {

;    f = FVAL_2D (ti,fi,xi,yi);
;    printf ("%3.1f ", f);
;  }
;  printf ("\n");
;  }
	
;  return;
;}
;-------------------------------------------------------------------------------
(defun minfunc_print_one (minfunc ti)

  (when (< ti 0) (setf ti (TOLD))) ;// последний из расчитанных слоев

  (if (= (mDIM) 1) (minfunc_print_oneti_1d minfunc ti))
;  else
;  if (mDIM == 2) minfunc_print_oneti_2d (minfunc, ti);

)
;-------------------------------------------------------------------------------
(defun minfunc_print_all (minfunc)

(let (
  (plot (minfunc_print_prepare minfunc +0 -0))
  )

  (plot_print plot)

))
;-------------------------------------------------------------------------------
(defun minfunc_print_gui (minfunc)

(let (
  (plot (minfunc_print_prepare minfunc +0 -0))
  )

  ;(plot_print plot)
  (plot_print_gui plot)

))
;-------------------------------------------------------------------------------
;void
(defun minfunc_print_one_tt (minfunc)

(let (
;  YT_PLOT *plot = minfunc_print_tt_prepare (minfunc);
  (plot (minfunc_print_tt_prepare  minfunc))
  )

  (plot_print_one  plot 0)

))
;-------------------------------------------------------------------------------
;void
;minfunc_print_tt (YT_MINFUNC *minfunc)
;{

;  YT_PLOT *plot = minfunc_print_tt_prepare (minfunc);

;  // здесь надо загнать все графики в один фрейм..
;  plot_frames_init0 (plot);
;  plot_frames_init9 (plot);

;  plotbig_print (plot, 0,0,0,0);

;  return;
;}
;-------------------------------------------------------------------------------
(defun minfunc_named (fi minfunc name)

;  strncpy (FIMQ(fi), name, 80);
  
  (setf (FIMQ fi) name)
)
;-------------------------------------------------------------------------------
;void
(defun minfunc_make_malloc (
       minfunc         ; YT_MINFUNC *minfunc
       fnum xnum ynum  ; int 
       )

  (setf (FNUM) fnum)
  (setf (XNUM) xnum)
  (setf (YNUM) ynum)

(let (
  (xint (- (XNUM) 1)) ; // количество интервалов
  (yint (- (YNUM) 1)) ; // количество интервалов
  )

  (if (= xint 0)  (setf (XSTEP) 0)
                  (setf (XSTEP) (/ (- (XMAX) (XMIN)) xint))
                  )

  (if (= yint 0)  (setf (YSTEP) 0)
                  (setf (YSTEP) (/ (- (YMAX) (YMIN)) yint))
                  )

  (dotimes (fi (FNUM))
    (setf (FMOD_ARR fi) (make-array (list xnum))) ;!!! пока сдeлаeм одномeрныe !!

    ;;  for (ti=0; ti <= TOLD; ti++) // выделяем массивы по временным слоям
    (dotimes (ti (1+ (TOLD)))
      (setf (FVAL_ARR ti fi) (make-array (list xnum))) ;!!! пока сдeлаeм одномeрныe !!
      )
    )

))
;-------------------------------------------------------------------------------
(defun create_step ()

(let (
  (step (make-instance 'MT_STEP))
  )

;  double   *fval[FI_MAX]; 
  (setf (P_FVAl step) (make-list FI_MAX))

  step
))
;-------------------------------------------------------------------------------
(defun minfunc_create_2d (fnum name  
                               xmin xmax xnum
                               ymin ymax ynum)

(let (
;  //int  cnum = 1; // количесво приближенных калькуляций (1 - обычный расчет)
  fi_name

  (minfunc (make-instance 'YT_MINFUNC))
  )

  ;; --------------------------------------------------------
  ;;  MT_STEP  steps[TI_MAX]; // основные массивы расчетов !!
  (setf (P_STEPS minfunc) (make-list TI_MAX))
  (dotimes (i TI_MAX)
    ;(setf (nth i (P_STEPS minfunc)) (make-instance 'MT_STEP)) ; надо явно их создать!
    (setf (nth i (P_STEPS minfunc)) (create_step)) ; надо явно их создать!
    )

  ;;  MT_FUNC  funcs[FI_MAX]; // описания функций (в т.ч. фиксация)
  (setf (P_FUNCS minfunc) (make-list FI_MAX))
  (dotimes (i FI_MAX)
    (setf (nth i (P_FUNCS minfunc)) (make-instance 'MT_FUNC)) 
    )
  ;; --------------------------------------------------------

  (setf (MDIM) 2)

  (setf (P_NAME minfunc) name)

  (setf (XMIN) xmin) ; ?????
  (setf (XMAX) xmax)
  (setf (YMIN) ymin)
  (setf (YMAX) ymax)

  (setf (TOLD)  0) ; пока выделяем один счетный временной слой
  (setf (TNUM)  1)
  (setf (TSTEP) 0)

  ;;  //CI = 0;
  (minfunc_make_malloc  minfunc fnum xnum ynum)

  (dotimes (fi (FNUM))
    (minfunc_fmin_fmax_ferr  fi minfunc -5.0 5.0 0.1) ; ?????

    (setf fi_name (format nil "~D" fi))
    (minfunc_named fi minfunc fi_name)
   
    ;; занулим маcсивы (на всякий случай) 
    (dotimes (yi (YNUM))
    (dotimes (xi (XNUM))
      (minfunc_put_2d  fi minfunc xi yi 0  0.0)
      ))
    )


  (setf (REZI 0) 0.0)

  minfunc
))
;-------------------------------------------------------------------------------
;
; здeсь нeльзя использовать си-шный трюк с массивами, поэтому будeм 
; использовать чeстно 1-мeрный (пока).
;
;-------------------------------------------------------------------------------
(defun minfunc_create_1d (fnum name  
                               xmin xmax xnum
                               ymin ymax ynum)

(let (
;  //int  cnum = 1; // количесво приближенных калькуляций (1 - обычный расчет)

;  YT_MINFUNC *minfunc;
;  int  xi, yi, fi;
;  char fi_name[80];
  fi_name

  (minfunc (make-instance 'YT_MINFUNC))
  )

  ;; --------------------------------------------------------
;  MT_STEP  steps[TI_MAX]; // основные массивы расчетов !!
  (setf (P_STEPS minfunc) (make-list TI_MAX))
  (dotimes (i TI_MAX)
    (setf (nth i (P_STEPS minfunc)) (create_step)) ; надо явно их создать!
    )

;  MT_FUNC  funcs[FI_MAX]; // описания функций (в т.ч. фиксация)
  (setf (P_FUNCS minfunc) (make-list FI_MAX))
  (dotimes (i FI_MAX)
    (setf (nth i (P_FUNCS minfunc)) (make-instance 'MT_FUNC)) 
    )
  ;; --------------------------------------------------------

  (setf (MDIM) 2)

  (setf (P_NAME minfunc) name)

  (setf (XMIN) xmin)
  (setf (XMAX) xmax)
  (setf (YMIN) ymin)
  (setf (YMAX) ymax)

  (setf (TOLD)  0) ; пока выделяем один счетный временной слой
  (setf (TNUM)  1)
  (setf (TSTEP) 0)

;  //CI = 0;
  (minfunc_make_malloc  minfunc fnum xnum ynum)

  (dotimes (fi (FNUM))
    (minfunc_fmin_fmax_ferr  fi minfunc -5.0 5.0 0.1)
    (setf fi_name (format nil "~D" fi))
    (minfunc_named fi minfunc fi_name)
   
    ;; // занулим маcсивы (на всякий случай) 
    (dotimes (xi (XNUM))
      (minfunc_put  fi minfunc xi 0  0.0)
      )    
    )


  (setf (REZI 0) 0.0)

  minfunc
))
;-------------------------------------------------------------------------------
;YT_MINFUNC*
;minfunc_create (int fnum, const char *name,  double xmin, double xmax, int xnum)
;-------------------------------------------------------------------------------
(defun minfunc_create (fnum name xmin xmax xnum)

(let (
;  (minfunc (minfunc_create_2d  fnum name  
;                               xmin xmax xnum
;                               0 0 1))
  (minfunc (minfunc_create_1d  fnum name  
                               xmin xmax xnum
                               0 0 1))
  )

;  mDIM = 1;
  (setf (MDIM) 1)

  minfunc
))
;-------------------------------------------------------------------------------
;void
;minfunc_add_params (YT_MINFUNC *minfunc, 
;                    void   (*calc_rezi_beg) (void *mf),
;                    void   (*calc_rezi_end) (void *mf),
;                    //double (*calc_rezi)     (void *mf, double *xyz),  
;                    FUN_REZI calc_rezi,                
;                    void *param)
;-------------------------------------------------------------------------------
(defun minfunc_add_params (minfunc 
                           calc_rezi_beg
                           calc_rezi_end
                           calc_rezi                
                           param)

  (setf (CALC_REZI_BEG minfunc) calc_rezi_beg)
  (setf (CALC_REZI_END minfunc) calc_rezi_end)
  (setf (CALC_REZI     minfunc) calc_rezi)

  (setf (PARAM         minfunc) param)
)
;-------------------------------------------------------------------------------
; размножим заданные нач. условия на все временные слои
; однако можно потом переписать (если они меняются)
;-------------------------------------------------------------------------------
(defun minfunc_add_fix_points (minfunc fi)

(let (
  val mod 
  )

  ;(format t "minfunc_add_fix_points ~%")

;  for (ti=1; ti < TNUM; ti++) 
;  for (xi=0; xi < XNUM; xi++) {
  (loop for ti from 1 to (- (TNUM) 1) do
  (dotimes (xi (XNUM))

    (setf mod (FMOD fi xi))

;    if (mod == FALSE) continue;
;    val = FVAL (/* ti */0, fi, xi);

;    (when *BOT_DEBUG* 
;      (format t "minfunc_add_fix_points:  ti= ~S  xi= ~S  mod= ~S  ~%" ti xi mod)
;      )

    ;(when (not (eq mod FALSE))
    (unless (equal mod FALSE)
      (setf val (FVAL 0 fi xi))

      (fval_set  minfunc fi xi ti  val)
      ;(format t "fval_set: ~s ~s mod=~s ~s ~s ~%" ti xi mod fi  val)
      (setf (FMOD fi xi) mod)
      ;(format t "................. ~%")
      )
    ))

))
;-------------------------------------------------------------------------------
(defun minfunc_add_fix_points_all (minfunc)

  (dotimes (fi (FNUM))
    (minfunc_add_fix_points  minfunc fi) ; или здeсь 
    )
)
;-------------------------------------------------------------------------------
;void
(defun minfunc_add_tt (
       minfunc ; YT_MINFUNC *minfunc
       tt      ; int tt
       tstep)  ; double tstep


  (if (>= tt TI_MAX)  (error "tt >= TI_MAX"))

  (setf (TSTEP) tstep)
  (setf (TNUM)  (1+ tt)) ; // добавим временных слоев

  (dotimes (fi (FNUM))
    (loop for ti from 1 to (- (TNUM) 1) do
       (setf (REZI ti) 0) ;;; ?? чтоб было

      ;; выделяем массивы по временным слоям
      ;; YMALLOC (FVAL_ARR(ti, fi), double, XNUM);
      ;(setf (FVAL_ARR ti fi) (make-array (list (XNUM)))) 
      (setf (FVAL_ARR ti fi) (make-array (list (XNUM)) :initial-element 0)
            ) ; надо бы и обнулить их?

      
      ;; размножим заданные нач. условия на все временные слои
      ;; однако можно потом переписать (если они меняются)
      ;(minfunc_add_fix_points  minfunc fi) ; только зачeм это дeлать в циклe?????
      ;; да eщe до инициализации нач. данных ??? !!!
      )
    
    ;(minfunc_add_fix_points  minfunc fi) ; уж хотя бы здeсь 
    )

;  (dotimes (fi (FNUM))
;    (minfunc_add_fix_points  minfunc fi) ; или здeсь 
;    )
;  (minfunc_add_fix_points_all minfunc)

)
;-------------------------------------------------------------------------------

(defvar *minfunc_read_save* :unbound) ; эмуляция "minfunc_read_save"

;-------------------------------------------------------------------------------
;YT_MINFUNC *
;minfunc_read_save (char *fname, int act, YT_MINFUNC *minfunc_old)
;-------------------------------------------------------------------------------
(defun minfunc_read_save (fname act minfunc_old)

(declare (ignore fname))

(let (
;  FILE *fp;
;  int  fi, ti, xi;
;  int    i;
;  double f;
  minfunc
  )

;  char *open_type;
;  if      (act == YREAD)   open_type = "r";
;  else if (act == YWRITE)  open_type = "w";
;  else Error("act");
  (cond
      ((= act  YREAD)  (setf minfunc *minfunc_read_save*))
      ((= act YWRITE)  (setf *minfunc_read_save* minfunc_old))
      )

;  if ((fp = fopen (fname, open_type)) == NULL) {
;    fprintf (STD_ERR, "Cannot open file:  %s \n", fname);
;    return (NULL);
;  }
;  //------------------------------
;  minfunc = minfunc_old;

;  if (act == YREAD) { 
;    YMALLOC (minfunc, YT_MINFUNC, 1);
;  }

;  YDataRW (1, act, minfunc->name, 80, fp);
;  YDataRW (11, act, &mDIM,  sizeof(int), fp);

;  YDataRW (2, act, &XNUM,  sizeof(int), fp);
;  YDataRW (3, act, &XMIN,  sizeof(double), fp);
;  YDataRW (4, act, &XMAX,  sizeof(double), fp);
;  YDataRW (5, act, &XSTEP, sizeof(double), fp);

;  YDataRW (22, act, &yNUM,  sizeof(int), fp);
;  YDataRW (23, act, &yMIN,  sizeof(double), fp);
;  YDataRW (24, act, &yMAX,  sizeof(double), fp);
;  YDataRW (25, act, &ySTEP, sizeof(double), fp);

;  YDataRW (6, act, &TOLD,  sizeof(int), fp);
;  YDataRW (9, act, &TSTEP, sizeof(double), fp);

;  YDataRW (10, act, &FNUM, sizeof(int), fp);
;  //-------------------------------------------------------

;  //int tt = TOLD+1; // записываемых слоев (включая нулевой)

;  //-------------------------------------------------------
;  for (ti=0; ti <= TOLD; ti++) 
;    YDataRW (13, act, &(REZI(ti)), sizeof(double), fp);

;  // записать/прочитать fmin_fmax_ferr
;  for (fi=0; fi < FNUM; fi++) {
;    YDataRW (12, act, &(FMIN(fi)), sizeof(double), fp);
;    YDataRW (12, act, &(FMAX(fi)), sizeof(double), fp);
;    YDataRW (12, act, &(FERR(fi)), sizeof(double), fp);
;  }
;  //-------------------------------------------------------

;  // записать/прочитать основные данные: значения и статусы 
;  //-------------------------------------------------------
;  if (act == YREAD) {
;    minfunc_make_malloc (minfunc, FNUM, XNUM, yNUM);
;  }

;  for (fi=0; fi < FNUM; fi++) {
;    YDataRW (12, act, FIMQ(fi), 80, fp);

;    for (ti=0; ti <=TOLD; ti++) 
;    for (xi=0; xi < XNUM; xi++) {
;      if (act == YWRITE) f = FVAL (ti, fi, xi);  
;      YDataRW (11, act, &f, sizeof(double), fp);

;      if (act == YREAD)  fval_set (minfunc, fi, xi, ti,  f);
;    }

;    for (xi=0; xi < XNUM; xi++) {
;      if (act == YWRITE) i = FMOD (fi, xi);  
;      YDataRW (11, act, &i, sizeof(int), fp);

;      if (act == YREAD)  FMOD (fi, xi) = i;
;    }
;  }
;  //-------------------------------------------------------

;  fclose (fp);

 minfunc  
))
;-------------------------------------------------------------------------------
(defun minfunc_put_old_2d (fi minfunc xi yi 
                              ti 
                              val mod)

  (fval_set_2d  minfunc fi xi yi ti  val)
  (setf (FMOD_2D  fi xi yi) mod) ; // только на нижней границе

)
;-------------------------------------------------------------------------------
;void
;minfunc_put_old (int fi, YT_MINFUNC *minfunc, int xi, int ti, 
;                 double val, int mod)
;-------------------------------------------------------------------------------
(defun minfunc_put_old (fi minfunc xi ti val mod)

;  minfunc_put_old_2d (fi, minfunc, xi, /* yi */0, 
;                      ti, 
;                      val, mod);

  (minfunc_put_old_2d  fi minfunc xi 0 
                       ti 
                       val mod)

)
;-------------------------------------------------------------------------------
;void
;minfunc_put_fix (int fi, YT_MINFUNC *minfunc, int xi, int ti, double val)
;-------------------------------------------------------------------------------
(defun minfunc_put_fix (fi minfunc xi ti val)

; minfunc_put_old (fi, minfunc, xi, ti, val, /* mod */TRUE);

;-------------------------
; сдeлаeм чeстно 1-мeрныe массивы
  (setf (FVAL ti fi xi) val)
  (setf (FMOD    fi xi) TRUE)

)
;-------------------------------------------------------------------------------
(defun minfunc_put_2d (fi minfunc xi yi 
                          ti val)

;  minfunc_put_old_2d (fi, minfunc, xi, yi, ti, val, /* mod */FALSE);
  (minfunc_put_old_2d  fi minfunc xi yi ti val FALSE)

)
;-------------------------------------------------------------------------------
(defun minfunc_put (fi minfunc xi ti val)

;-------------------------
;  minfunc_put_2d (fi, minfunc, xi, /* yi */0, ti, val);
;-------------------------
; сдeлаeм чeстно 1-мeрныe массивы

  ;(setf (FVAL_2D ti fi xi yi) val)
  ;(setf (FMOD_2D    fi xi yi) FALSE) ; // только на нижней границе

  (setf (FVAL ti fi xi) val)
  (setf (FMOD    fi xi) FALSE) ; // только на нижней границе

)
;-------------------------------------------------------------------------------
(defun minfunc_t0_fix (fi minfunc xi val)

  ;minfunc_put_old (fi, minfunc, xi, /* ti */0, val, /* mod */TRUE);
  ;(minfunc_put_old  fi minfunc xi 0 val t)

  ;; сдeлаeм чeстно 1-мeрныe массивы

  (setf (FVAL 0  fi xi) val)
  (setf (FMOD    fi xi) t)

)
;-------------------------------------------------------------------------------
;void
;minfunc_t0_put_int (int fi, YT_MINFUNC *minfunc, double val, 
;                           int xi_beg, int xi_end)
;-------------------------------------------------------------------------------
(defun minfunc_t0_put_int (fi minfunc val xi_beg xi_end)

;  // установить начальные условия (t=0)
;  int xi;

  ;(format t "fi=~s  xi_beg=~s  xi_end=~s ~%" fi xi_beg xi_end)

;  for (xi=xi_beg; xi <= xi_end; xi++)
  (loop for xi from xi_beg to xi_end do
    (minfunc_put  fi minfunc xi 0 val)
    )

)
;-------------------------------------------------------------------------------
;void
;minfunc_t0_put_all (int fi, YT_MINFUNC *minfunc, double val)
;-------------------------------------------------------------------------------
(defun minfunc_t0_put_all (fi minfunc val)

;  установить начальные условия (t=0)

  (minfunc_t0_put_int  fi minfunc val X_BEG (X_END))

)
;-------------------------------------------------------------------------------
(defun minfunc_fmin_fmax_ferr (n minfunc fmin fmax ferr)

  (setf (FMIN n) fmin)
  (setf (FMAX n) fmax)
  (setf (FERR n) ferr)

)
;-------------------------------------------------------------------------------
(defun minfunc_to_minproc (minfunc minproc)

(let (
  (ti  (+ (TOLD) 1))
;  // сформировать основные константы
  (ind 0) size
  v
  )

  ;(format t "minfunc_to_minproc .. ~%")

;  for (fi=0; fi < FNUM; fi++)
;  for (xi=X_BEG; xi <= X_END; xi++) 
;  {
;    if (FMOD(fi, xi) == TRUE) // значение постоянно
;      continue;

  (dotimes (fi (FNUM))
  (loop for xi from X_BEG to (X_END) do
  (unless (eq (FMOD fi xi) t)

    (setf (nth ind (XYZ_MIN)) (FMIN fi))
;    XYZ_MAX[ind] = FMAX(fi);
;    XYZ_ERR[ind] = FERR(fi);
    (setf (nth ind (XYZ_MAX)) (FMAX fi))
    (setf (nth ind (XYZ_ERR)) (FERR fi))

    (incf ind)
  )
  ))

;  DIM  = size = ind; // свободных точек функции 
  (setf size  ind)
  (setf (DIM) ind)

;  if (!DIM) {
;    Error ("!DIM");
;  }
  (when (= (DIM) 0) (error "!DIM"))

;  // представить неизвестную функцию в виде пространства для минимизации
  (setf ind 0)

;  for (fi=0; fi < FNUM; fi++)
;  for (xi=X_BEG; xi <= X_END; xi++) 
;  {
;    if (FMOD(fi, xi) == TRUE) // значение постоянно
;      continue;

  (dotimes (fi (FNUM))
  (loop for xi from X_BEG to (X_END) do
  (unless (eq (FMOD fi xi) t)

;    // задать одно начальное приближение ???
;    XYZ_BEG[0][ind++] = FVAL (ti, fi, xi);
    (setf v (FVAL ti fi xi))
    ;(format t "v= ~s ~%" v)

    (setf (aref (XYZ_BEG) 0 ind) v)
    (incf ind)
  )
  ))

  (setf (NUM_BEG) 1)

))
;-------------------------------------------------------------------------------
(defun minproc_read_xyzend_n (minproc n)

(let (
  (xyz (make-list (DIM)))
  v
  )

  ;(format t "minproc_read_xyzend_n: ~%")

  (dotimes (i (DIM))
    (setf v (aref (XYZ_END) n i))
    (setf (nth i xyz) v)    
    )

  xyz
))
;-------------------------------------------------------------------------------
;void
(defun minproc_to_minfunc (
                           minproc ; YT_MINPROC *
                           minfunc ; YT_MINFUNC *
                           xyz_cur ; double *
                           )

(let (
;  int    ind;
;  int    fi, xi, 
  (ti  (TI))
  ind val rezi
  )

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  ;(format *error-output* "~%")
  ;(format *error-output* "minproc_to_minfunc: ~s ~%" xyz_cur)
  ;(format t "xyz_cur= ~s ~%" xyz_cur)
  ;(format t "PROVERKA : ~%")

  ;(minfunc_print_lines_ti  minfunc 1) ; eщe нормально !

  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

  ;; if (!xyz_cur) { // окончательное (а не текущее) решение
  (when (eq xyz_cur NIL)
    ;(format t "(eq xyz_cur NIL)~%")

    (when (/= (NUM_END) 1)
      (format t "NUM_END != 1  Don't solver!!! %")
      )

    ;; xyz_cur = XYZ_END[0]; 
    (setf xyz_cur (minproc_read_xyzend_n  minproc 0)) ; ??? здeсь ОШИБКА ???
    ;; это мы бeрeм из  minproc  тeкущую точку (а туда она когда попала)

    ;; REZI(ti) = FUN_END[0]-0.0; // в пошаговой схеме: T_CALC_BEG==T_CALC_END
    (setf rezi (- (nth 0 (FUN_END)) 0.0))

    ;(format *error-output* "REZI(~D) = ~S " ti rezi)
    (setf (REZI ti) rezi)
  )

  (setf ind 0)
;  for (fi=0;     fi <  FNUM;  fi++)
;  for (xi=X_BEG; xi <= X_END; xi++) {

;    if (FMOD (fi, xi) == TRUE) // значение постоянно
;      continue;

  ;(minfunc_print_lines_ti  minfunc 1) ; !!!!!!!!!!!!!!!!!!!!!

  
  (dotimes (fi (FNUM))
  (loop for xi from X_BEG to (X_END) do
  (unless (eq (FMOD fi xi) t)

    ;(setf val = xyz_cur[ind++])
    (setf val (nth ind xyz_cur))

    ;(format t "xi=~2s ti=~2s val=~s ~%" xi ti val )

    (fval_set minfunc fi xi ti  val)
;  }
  (incf ind)
  )
  ))


  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;(format t "~%")
  ;(format t "PROVERKA : ~%")
  ;(minfunc_print_lines_ti  minfunc 1) ; подбортился ужe гдeто!!
  ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
  ;(format *error-output* "~%")  (quit)

))
;-------------------------------------------------------------------------------
;void
;minfunc_pik_tstart (int fi, YT_MINFUNC *minfunc, double w, double fc)
;{
;  int hand = w / 2 * XNUM; 
;  int xi;
;  double /* ret, */ a, b, xc, x1, /* x2, */ f;
;  int xi_c, xi_1, /* xi_2, */ i;

;  xi_c = XNUM / 2; 
;  xi_1 = xi_c - hand + 1;
;  xc = XVAL (xi_c);
;  x1 = XVAL (xi_1);
;  a  = fc / (xc - x1); b = - x1 / (xc - x1) * fc;
	
;  minfunc_t0_put_all (fi, minfunc, 0);

;  minfunc_put (fi, minfunc, xi_c, 0, fc);
;  for (i=1; i<hand; i++) {
;    xi = xi_c-i;
;    f  = a*X+b;
;    minfunc_put (fi, minfunc, xi,     0, f);
;    minfunc_put (fi, minfunc, xi_c+i, 0, f);
;  }
	
;  return;
;}
;-------------------------------------------------------------------------------
;void
;minfunc_cos_tstart (int fi, YT_MINFUNC *minfunc, double v_null, double v_pike)
;-------------------------------------------------------------------------------
(defun minfunc_cos_tstart (fi minfunc v_null v_pike)

(let* (
;  //double v_null = 0.0;
  (v_diff  (- v_pike v_null))

  (w  0.5) 
;  int hand = w / 2 * XNUM; 
  (hand (floor (* (/ w 2) (XNUM))))

  xc x2 f dhand
  xi_c xi_2 xi ; int
  )

  (minfunc_t0_put_all  fi minfunc v_null)
;  //--------------------------------------

  (setf xi_c (floor (/ (XNUM) 2)))
  (setf xi_2 (+ xi_c hand -1))
  ;xi_2 = xi_c + hand - 1;

  (setf xc  (XVAL xi_c))
  (setf x2  (XVAL xi_2))
  (setf dhand (- x2 xc))
	
;  // задать центральную точку
;  minfunc_put (fi, minfunc, xi_c, 0, v_pike/* , TRUE */);
  (minfunc_put  fi minfunc xi_c 0 v_pike)

;  (format t "minfunc_cos_tstart: ~%")
;  (format t "v_null = ~s ~%" v_null)
;  (format t "v_diff = ~s ~%" v_diff)
;  (format t "dhand  = ~s ~%" dhand)
;  (format t " hand  = ~s ~%" hand)
;  (format t "  xi_c = ~s ~%" xi_c)
;  (format t "  xi_2 = ~s ~%" xi_2)

;  // задать саму "горку"
;  for (i=1; i<hand; i++) {
  (loop for i from 1 to (- hand 1) do

;    xi = xi_c+i;
;    f  = v_null + 0.5*v_diff * (cos (X*G_PI/dhand)+1);
;    //f  = v_null + 0.5*v_diff * (cos (X*YPI/dhand));

    (setf xi (+ xi_c i))
    (setf f  (+ v_null (* 0.5 v_diff (+ (cos (/ (* (XX) G_PI) dhand)) 1))))

    ;(format t "i=~s  xi=~s  x=~s  f=~s ~%" i xi (XX) f)

    (minfunc_put fi minfunc    xi      0 f)
    (minfunc_put fi minfunc (- xi_c i) 0 f)
    )
	
))
;-------------------------------------------------------------------------------
;void
;minfunc_t0_cos_i (int fi, YT_MINFUNC *minfunc, double v0, double v1,
;                        int xi_beg, int xi_end)
;-------------------------------------------------------------------------------
(defun minfunc_t0_cos_i (fi minfunc v0 v1 xi_beg xi_end)

(let* (
  (xbeg  (+ (XMIN) (* xi_beg (XSTEP))))     ; double
  (xend  (+ (XMIN) (* xi_end (XSTEP))))

  (h    (- v1 v0))       ; // высота пупыря
  (w    (- xend xbeg)) ; // ширина пупыря
  (hand (/ w 2))         ; // полуширина
  (xc   (+ xbeg hand))  ; // центр          ; double - всe пeрeмeнныe были такиe

  ;----------------------------------
  (ti  0) ;  int   xi, ti = 0;
  f       ;  double f;
  )
	
  ;(format t "fi=~s  xi_beg=~s  xi_end=~s ~%" fi xi_beg xi_end)
  ;(format t "5) xi_beg=~s  xi_end=~s ~%" X_BEG (X_END))
	
  (minfunc_t0_put_all  fi minfunc v0)

;  for (xi=xi_beg; xi <= xi_end; xi++) {
;    f = v0 + h * 0.5 * (1 + cos ((X-xc)*G_PI / hand));
;    minfunc_put (fi, minfunc, xi, ti, f);
;  }
	
  ;(format t "2 ... ~%")
  ;; надо проэммулировать нeявноe привидeниe к типу int в циклe Си: ??
  (setf xi_beg (floor xi_beg))
  (setf xi_end (floor xi_end))

  (loop for xi from xi_beg to xi_end do
    (setf f  (+ v0 (* h 0.5 (1+ (cos (/ (* (- (XX) xc) G_PI) hand))))))
    (minfunc_put  fi minfunc xi ti f)
  )
	
))
;-------------------------------------------------------------------------------
;void
;minfunc_t0_cos (int fi, YT_MINFUNC *minfunc, double v0, double v1,
;                double x_beg, double x_end)
;-------------------------------------------------------------------------------
;
; помeнял x_beg -> xbeg, x_end -> xend , а иначe похожe тихо конфликтуeт 
; с глоб. пeрeмeнной X_BEG !!
;
(defun minfunc_t0_cos (fi minfunc v0 v1 xbeg xend)

(let (
  (xi_beg  (YInt (/ (- xbeg (XMIN)) (XSTEP)))) ; она нe приводит к типу Int ??
  (xi_end  (YInt (/ (- xend (XMIN)) (XSTEP)))) ; да нeт, у мeня ужe приводит (a_plot.cl)
  )

  (minfunc_t0_cos_i  fi minfunc v0 v1 xi_beg xi_end)

))
;-------------------------------------------------------------------------------
;void
;minfunc_t0_gap_i (int fi, YT_MINFUNC *minfunc, double v0, double v1,
;                        int xi_beg, int xi_end)
;{
;  //double x_beg = XMIN + xi_beg * XSTEP;
;  //double x_end = XMIN + xi_end * XSTEP;

;  //double h = v1 - v0;         // высота пупыря
;  //double w = x_end - x_beg;   // ширина пупыря
;  //double hand = w / 2;        // полуширина
;  //double xc   = x_beg + hand; // центр
	
;  minfunc_t0_put_all (fi, minfunc, v0);

;  int   xi, ti = 0;
;  double f;
;  for (xi=xi_beg; xi <= xi_end; xi++) {
;    f = v1;
;    minfunc_put (fi, minfunc, xi, ti, f);
;  }
	
;  return;
;}
;-------------------------------------------------------------------------------
;void
;minfunc_t0_gap (int fi, YT_MINFUNC *minfunc, double v0, double v1,
;                double x_beg, double x_end)
;{
;  int xi_beg = YInt ((x_beg - XMIN) / XSTEP);
;  int xi_end = YInt ((x_end - XMIN) / XSTEP);
	
;  minfunc_t0_gap_i (fi, minfunc, v0, v1, xi_beg, xi_end);

;  return;
;}
;-------------------------------------------------------------------------------
;void
;minfunc_lef_tstart (int fi, YT_MINFUNC *minfunc, double w, double fc)
;{
;  // сделать ступеньку                                                         
;  int i, i_right;

;  i_right = XNUM / w; 

;  for (i=0; i<i_right; i++)
;    minfunc_put (0, minfunc, i, 0, fc);

;  for (i=i_right; i<XNUM; i++)
;    minfunc_put (0, minfunc, i, 0, 0.0);
	
;  return;
;}
;-------------------------------------------------------------------------------
(defun minfunc_info (minfunc)

;  fprintf (STD_ERR, "xx= %3d  dx= %g  \n", XNUM-1, XSTEP);
;  fprintf (STD_ERR, "t0= %3d  dt= %g  \n", TOLD, TSTEP);

  (format t "xx= ~3d  dx= ~,6f  ~%"  (- (XNUM) 1) (XSTEP))
  (format t "t0= ~3d  dt= ~,6f  ~%"        (TOLD) (TSTEP))

)
;-------------------------------------------------------------------------------
(defun minfunc_print_info (minfunc)

(let (
      tnum fnum
)

  (format t "----------- MINFUNC_PRINT_INFO ---------------------------  ~%")
  (format t "~%")

  (minfunc_info  minfunc)

;  set tnum  [expr 1 + [TOLD_get]] ;#/* последний значимый слой */ + 1  
;  set fnum  [FNUM_get]
  (setf tnum (+ 1 (TOLD)))
  (setf fnum      (FNUM))

  (format t "tnum = ~s ~%" tnum)
  (format t "fnum = ~s ~%" fnum)

  (dotimes (ti tnum)
  (dotimes (fi fnum)

    (format t "ti= ~s  fi= $~s  FVAL= ~s  ~%"   ti fi (FVAL_ARR  ti fi))
    ))


  (format t "~%")
  (format t "----------------------------------------------------------  ~%")
  (format t "~%")

))
;-------------------------------------------------------------------------------
;char*
;get_argcargv (int argc, char *argv[], int i0)
;{
;  int i;
;  static char buffer[180];

;  strcpy (buffer, "");

;  for (i=i0; i<argc; i++) {
;    strcat (buffer, argv[i]);
;    strcat (buffer, " ");
;  }

;  return (buffer);
;}
;-------------------------------------------------------------------------------
;void
;dinamic_t_solver_beg (char *buff, YT_MINFUNC *minfunc)
;-------------------------------------------------------------------------------
(defun dinamic_t_solver_beg (buff minfunc)

;  time_t t;

;  fprintf (STD_ERR, "---------------------------------------------- \n");
  (format t "---------------------------------------------- ~%")
;  t = time (NULL);

;  fprintf (STD_ERR, "> <ProgName> ");
  (format (STD_ERR) "> <ProgName> ")

;  //for (i=0; i<argc; i++) // нафига печатать непостоянное имя проги
;  // 
;  // надо будет сдвинуть строку параметров, начиная ее с предметных параметров!

;  fprintf (STD_ERR, "%s", buff);
;  fprintf (STD_ERR, "\n");
;  fprintf (STD_ERR, "\n");
  (format (STD_ERR) "~S ~%~%" buff)

  (minfunc_info minfunc)
;  fprintf (STD_ERR, "\n");
  (format (STD_ERR) "~%")

;  minfunc->solv_timer = timer_beg ();

)
;-------------------------------------------------------------------------------
(defun dinamic_t_solver_end (minfunc)

  (declare (ignore minfunc))

;  char solv_hms_time[80], *p_time;

  (format (STD_ERR) "~%")

;  timer_end (minfunc->solv_timer, solv_hms_time);

;  //if (IS_TEST) p_time = "#######";
;  /* else */     p_time = solv_hms_time;

;  fprintf (STD_ERR, "Solv-Elapsed Time = %s \n", p_time);

;  //kill_pid_free ();
  (format (STD_ERR) "---------------------------------------------- ~%")

)
;-------------------------------------------------------------------------------
;T_PROC_RETURN
;minfun_proc (PROC_VAR)
;{
;  static YT_MINPROC *minproc;
;  static YT_MINFUNC *minfunc;

;  double rezi;

;  switch (message) {
;  case YINIT:
;    // пока это расчет одного шага по времени ?
;    minproc = (YT_MINPROC*) ptr;
;    minfunc = (YT_MINFUNC*) long1;

;    if (minfunc->calc_rezi_beg)
;    minfunc->calc_rezi_beg (minfunc);
;    break;
;  case YFREE:
;    if (minfunc->calc_rezi_end)
;    minfunc->calc_rezi_end (minfunc);
;    break;
;  case YCALC:
;    minproc_to_minfunc (minproc, minfunc, xyz);
;    rezi = minfunc->calc_rezi (minfunc, xyz);

;    if (ret) *ret = rezi;
;    return (0);
;  }

;  RETURN;
;}
;-------------------------------------------------------------------------------
;T_PROC_RETURN
;minfun_proc (PROC_VAR)

;  static YT_MINPROC *minproc;
;  static YT_MINFUNC *minfunc;
;-------------------------------------------------------------------------------

(defvar *minproc* :unbound)
(defvar *minfunc* :unbound)

;-------------------------------------------------------------------------------
(defun minfun_proc_calc (xi)

(let (
  (xyz xi)
  )

  (minproc_to_minfunc *minproc* *minfunc* xyz) ;; !!!! здeсь портит !!!

  (funcall (CALC_REZI *minfunc*) *minfunc* xyz)  ; напримeр 'berger_calc_rezi

))
;-------------------------------------------------------------------------------
(defun minfun_proc (message xyz fun long1 long2 ptr ret)

(declare (ignore fun long2 ret))

(cond
 ;; ---------------------------------------

 ((= message YINIT)
;    // пока это расчет одного шага по времени ?
;    minproc = (YT_MINPROC*) ptr;
;    minfunc = (YT_MINFUNC*) long1;
    (setf *minproc* ptr)
    (setf *minfunc* long1)

  ;(minfunc_print_lines_ti *minfunc* 1)

;    if (minfunc->calc_rezi_beg)
;    minfunc->calc_rezi_beg (minfunc);
    (unless (eq (CALC_REZI_BEG *minfunc*) NIL) 
      (funcall (CALC_REZI_BEG *minfunc*) *minfunc*)
      )
    
    (setf *calc_xi* 'minfun_proc_calc) ;; !!!!!!!!!!
   )

 ;; ---------------------------------------

 ((= message YFREE)
;    if (minfunc->calc_rezi_end)
;    minfunc->calc_rezi_end (minfunc);
  (unless (eq (CALC_REZI_END *minfunc*) NIL) 
    (funcall (CALC_REZI_END *minfunc*) *minfunc*))
   )
 ;; ---------------------------------------

 ((= message YCALC)
  ;;????? сюда попадаeм, напримeр, при пeрeборe
  ;(format *error-output* "YCALC.. xyz= ~s ~%" xyz) 

;;    double rezi;
;;    minproc_to_minfunc (minproc, minfunc, xyz);
;;    rezi = minfunc->calc_rezi (minfunc, xyz);
;;    if (ret) *ret = rezi;
  
  ;(format t "YCALC:   xyz= ~s ~%" xyz)
  ;(quit) ; !!!!!!!!!!!!1

  (funcall *calc_xi* (coerce xyz 'list))
 )
 ;; ---------------------------------------
)


;  RETURN;
)
;-------------------------------------------------------------------------------
(defun minfunc_solver (minfunc mbot)

(let (
  (minproc (minproc_create 'minfun_proc))
  )

  (minproc_begin  minproc minfunc 0) ;; 

  (minfunc_to_minproc  minfunc minproc)

  ;;------------------------------------------------
  ;(d_print 331)
  (funcall (BOT_DATA mbot) mbot minproc) ; прицeпляeм к боту данныe
  ;(d_print 332)
  ;; вот и надо провeрить..

  ;(minfunc_print_lines_ti minfunc 1)


  ;  //------------------------------------------------
  ;(when *BOT_DEBUG* 

    ;(format t "bot = ~s ~%" (BOT_TODO mbot))
    ;#bot = botgslspusk_4_todo

    ;(minbot_print  mbot)

    ;(quit) 
  ;)
  ;  //------------------------------------------------

  (funcall (BOT_TODO mbot) mbot) ; напускаем бота на данные
  ;(d_print 333)
;  //------------------------------------------------

  (minproc_to_minfunc  minproc minfunc NUL)	
  ;(d_print 333)
;  minproc_free (minproc);

))
;-------------------------------------------------------------------------------
;void
;minfunc_print_lines_ti (YT_MINFUNC *minfunc, int ti)
;{

;  //  (dotimes (fi (FNUM))
;  //    (format t "~A= ~S ~%" (FIMQ fi) (coerce (FVAL_ARR ti fi) 'list))
;  //    )
;  int fi, xi;

;  for (fi=0; fi < FNUM; fi++) {
;    fprintf (STD_ERR, "\n");
;    fprintf (STD_ERR, "%s=  \n", FIMQ(fi));

;    for (xi=X_BEG; xi <= X_END; xi++) 
;      fprintf (STD_ERR, "%g ", FVAL (ti, fi, xi));

;    fprintf (STD_ERR, "\n");
;  }

;}
;-------------------------------------------------------------------------------
;void
(defun dinamic_t_solver (minfunc mbot)

(let (
  (is_2_slice  FALSE)
  ft_1 ft_2 ft_d

;  YT_TIMER *step_timer;
;  //char  fname[80];
;  char  step_hms_time[80], *p_time;
  p_time val
  )

  (format (STD_ERR) "  true ti=~3D  r= ~S  ~%" (TOLD) (REZI (TOLD)))

  ;;  динамический счет по шагам времени
  ;;  ------------------------------------------------------
  (loop for ti from (+ (TOLD) 1) to (- (TNUM) 1) do

;    //TI = /* ti */ (TOLD+1); // новый (текущий) слой, требующий расчета
;    //TOLD++;  // предыдущий (последний из расчитанных) слой
;    step_timer = timer_beg ();

    ;; -----------------------------
    ;; начальное приближение с предыдущего слоя
    ;; ("хитрый" предиктор по двум слоям)
     (setf ft_d 0)

    (dotimes (fi (FNUM))
    (loop for xi from X_BEG to (X_END) do
      ;; нельзя забивать константные значения!!
      (unless (eq (FMOD fi xi) t)

        ;; значeния ближнeго прeдыдущeго слоя
        (setf ft_1 (FVAL (- ti 1) fi xi))

        ;; эта часть вообщe-то нe работаeт:
        (when (and is_2_slice (/= ti 1)) ; не первый счетный слой
          (setf ft_2 (FVAL (- ti 2) fi xi)) ; с дальнeго (второго) слоя
          (setf ft_d (- ft_1 ft_2))
          )
        
        (setf val (+ ft_1 ft_d)) ; пока просто ft_1

        ;(format t "ti=~s xi=~s val=~s ~%" ti xi val)
        (fval_set  minfunc fi xi ti  val)
        
        )
      ))
    ;; -----------------------------
    ;(format t "~% ~%")
    ;(minfunc_print_lines_ti minfunc 0)
    ;(format t "~% ~%")
    ;(minfunc_print_lines_ti minfunc 1)
    ;(exit)

    (format (STD_ERR) "  calc ")
    ;(d_print 222)

    (minfunc_solver minfunc mbot)

    ;;  timer_end (step_timer, step_hms_time);
    ;;  p_time = step_hms_time;
    (setf p_time "12345")

    (format (STD_ERR) "ti=~3d  r= ~,8f  t= ~A  " ti (REZI ti) p_time)
    (format (STD_ERR) "~%")
    ;; -----------------------------

;    (minfunc_print_one minfunc 0)
;    (format (STD_ERR) "FVAL_ARR(0 0)= ~S ~%" (coerce (FVAL_ARR 0 0) 'list))

    (incf (TOLD)) ; предыдущий (последний из расчитанных) слой

;    (minfunc_print_one minfunc 0) ; чe за брeд почeму тут мeняeтся ??
;    (format (STD_ERR) "FVAL_ARR(0 0)= ~S ~%" (coerce (FVAL_ARR 0 0) 'list))
;    (format (STD_ERR) "~% ~% ~% ~% ~% ~% ")

    ;; всегда записывать основной файл
    (minfunc_read_save  "LAST_SOL" YWRITE minfunc)
  )
  ;;  ------------------------------------------------------

))
;-------------------------------------------------------------------------------
;void
(defun dinamic_t_solver_main (cmd_1 minfunc mbot)

;  //char *cmd_1 = get_argcargv (argc, argv, 1);
;
  (dinamic_t_solver_beg  cmd_1 minfunc)
  (dinamic_t_solver      minfunc mbot)
  (dinamic_t_solver_end  minfunc)

)
;-------------------------------------------------------------------------------
;double
;minfunc_integral (YT_MINFUNC *minfunc, int xi_min, int xi_max, YT_SUBFUNC func, double x_param)
;{
;  int    xi;
;  double sum, val, k;
;  int mode = 2;
;  //XSTEP???

;  sum = 0;

;  switch (mode) {
;  case 1: // прямоугольники
;    for (xi=xi_min; xi <= xi_max; xi++) {
;      val = func (minfunc, xi, (long)(&x_param), 0,0);
;      sum += val;
;    }
;    sum = sum * XSTEP;
;    break;

;  case 2: // тпапеции
;    for (xi=xi_min; xi <= xi_max; xi++) {
;      val = func (minfunc, xi, (long)(&x_param), 0,0);
;      if (xi==xi_min && xi==xi_max) k = 1;
;      else                          k = 2;
;      sum += (k*val);
;    }
;    sum = sum * XSTEP/2;
;    break;

;  default: ;;;;;
;  }

;  return (sum);
;}
;===============================================================================
;-------------------------------------------------------------------------------
;void
;minfunc_file_info (char *fname)
;{
;  YT_MINFUNC *minfunc = minfunc_read_save (fname, YREAD, NULL);

;  minfunc_info (minfunc);

;  fprintf (STD_ERR, "\n");
;  return;
;}
;-------------------------------------------------------------------------------
;void
;minfunc_file_print (char *fname, int argc, char *argv[])
;{
;  double  xmin, xmax;

;  YT_MINFUNC *minfunc = minfunc_read_save (fname, YREAD, NULL);

;  xmin = +0;
;  xmax = -0;

;  if (argc == 4) {
;    xmin = atof (argv[2]);
;    xmax = atof (argv[3]);
;  }
;  minfunc_print (1/*win*/, 1/*gnu*/, minfunc,  xmin, xmax);

;  return;
;}
;-------------------------------------------------------------------------------
;void
;minfunc_file_print_tt (char *fname)
;{

;  YT_MINFUNC *minfunc = minfunc_read_save (fname, YREAD, NULL);
;  minfunc_print_tt (minfunc);

;  return;
;}
;-------------------------------------------------------------------------------
;void
;minfunc_file_print_one (char *fname)
;{

;  YT_MINFUNC *minfunc = minfunc_read_save (fname, YREAD, NULL);
;  minfunc_print_one (minfunc, -1000/*последний шаг*/);

;  return;
;}
;-------------------------------------------------------------------------------

;/* #define argv_1(str) (YStrCmp (argv[1], str)) */
;/* #define argv_new_1(str) (YStrCmp (argv_new[1], str)) */
;//#define argv_0(str) (YStrCmp (argv_new[0], str))
;#define argv_0(str) (YStrCmp (argv[0], str))

;-------------------------------------------------------------------------------
;YT_BOOL
;minfunc_info_print_ (int argc, char *argv[])
;{
;  char  *fname;

;  if (argc == 1)  fname = LAST_SOL;
;  else            fname = argv[1];

;/*   printf ("argc= %d  ", argc); */
;/*   int i; */
;/*   for (i=0; i<argc; i++) { */
;/*     printf ("%s ", argv[i]); */
;/*   } */
;/*   printf ("\n"); */

;  if (argv_0 ("-i")) {
;    minfunc_file_info (fname);
;    return (TRUE);
;  }

;  if (argv_0 ("-p")) {
;    minfunc_file_print (fname, argc, argv);
;    return (TRUE);
;  }

;  if (argv_0 ("-t")) {
;    minfunc_file_print_tt (fname);
;    return (TRUE);
;  }

;  if (argv_0 ("-w")) {
;    minfunc_file_print_one (fname);
;    return (TRUE);
;  }

;  return (FALSE);
;}
;-------------------------------------------------------------------------------
;double
;function_get (YT_MINFUNC *minfunc, int fi, int ti, double x_value, int *status_ok)
;{
;-------------------------------------------------------------------------------
(defun function_get (minfunc fi ti x_value)

(declare (ignore fi))

(let* (
;  double f;
;  int    xi;
;  f = (x_value - minfunc->xmin) / XSTEP;
; xi = YInt (f);

  (xreal  (/ (- x_value (XMIN)) (XSTEP)))
  (xi     (YInt  xreal))
  )

;  if ((xi < 0) || (xi > XNUM-1)) {
;    *status_ok = FALSE;
;    return (0);
;  }
;  *status_ok = TRUE;
;  return (F);

  (if (or (< xi 0) (> xi (- (XNUM) 1)))  (values  0   FALSE)
                                         (values (FF)  TRUE)
    )
))
;-------------------------------------------------------------------------------
;void
;make_diff_c (YT_MINFUNC *minfunc, double *y, double *y_x/* , int x_beg, int x_end */)
;{
;  double  f1, /* f2, */ f3;
;  int     xi;

;  for (xi=X_BEG+1; xi <= X_END-1; xi++) {    
;    f1 = y[xi-1];
;    //f2 = y[xi];
;    f3 = y[xi+1];

;    y_x[xi] = (f3 - f1) / (2 *XSTEP); // центральная разность
;  }
;  y_x[X_BEG] = (y[X_BEG+1] - y[X_BEG])   / XSTEP;
;  y_x[X_END] = (y[X_END]   - y[X_END-1]) / XSTEP;

;  return;
;}
;-------------------------------------------------------------------------------
;void
(defun make_diff_r (
           minfunc ; YT_MINFUNC *minfunc, 
           y   ; double *y, 
           y_x ; double *y_x
           )

(let (
  f1 f2 ;  double  f1, f2;
;  int     xi;
  )

;  for (xi = X_BEG; xi <= X_END-1; xi++) { 
  (loop for xi from X_BEG to (- (X_END) 1) do
   
    (setf f1 (nth     xi  y)) ;    f1 = y[xi];
    (setf f2 (nth (1+ xi) y)) ;    f2 = y[xi+1];

    (setf (nth xi y_x) (/ (- f2 f1) (XSTEP))) ; y_x[xi] = (f2 - f1) / XSTEP; // правая производная 
    )

;  // на правом конце делаем левую производную
;  y_x[X_END] = (y[X_END] - y[X_END-1]) / XSTEP; 

  (setf (nth (X_END) y_x) (/ (- (nth (X_END) y) (nth (- (X_END) 1) y)) (XSTEP))) 

))
;-------------------------------------------------------------------------------
;void
(defun make_diff_l (
       minfunc ; YT_MINFUNC *minfunc, 
       y   ; double *y, 
       y_x ; double *y_x /* , int x_beg, int x_end */
       )

(let (
  f1 f2 ;  double  f1, f2;
;  int     xi;
  )

;  for (xi = X_BEG+1; xi <= X_END; xi++) {    
  (loop for xi from (1+ X_BEG) to (X_END) do
    (setf f1 (nth (- xi 1)  y)) ;    f1 = y[xi-1];
    (setf f2 (nth    xi     y)) ;    f2 = y[xi];

    (setf (nth xi y_x) (/ (- f2 f1) (XSTEP))) ; y_x[xi] = (f2 - f1) / XSTEP; // правая производная 
    )

;  // на левом конце делаем правую производную
;  y_x[X_BEG] = (y[X_BEG+1] - y[X_BEG]) / XSTEP; 
  (setf (nth X_BEG y_x) (/ (- (nth (1+ X_BEG) y) (nth X_BEG y)) 
                             (XSTEP))) 

))
;-------------------------------------------------------------------------------
;void
(defun make_func (
           minfunc ; YT_MINFUNC *minfunc, 
           y  ; double *y, 
           ti ; int ti
           )

;  int     xi/* , ti = TI */;
;  for (xi=X_BEG; xi <= X_END; xi++) {    
;    y[xi] = Fun(xi, ti);
;  }

(let (
      f
)

;  (when *BOT_DEBUG* 
;    (format t "~%")
;    (format t "make_func: ti= ~s X_BEG= ~s  X_END= ~s  ~%" ti X_BEG (X_END))
;    (format t "~%")
;    (minfunc_print_info  minfunc)
;    (format t "ti= 1  fi= 0  FVAL= ~s  ~%"   (FVAL_ARR  1 0))
;    )

  (loop for xi from X_BEG to (X_END) do

    (setf f (Fun_ xi ti))

;    (when *BOT_DEBUG* 
;      (format t "ti= ~s  xi= ~s  f= ~s ~%" ti xi f)
;      )

    (setf (nth xi y)  f)
    )

;  (when *BOT_DEBUG*  
;    (format t "~%")
;    (quit)
;    )


))
;-------------------------------------------------------------------------------
;void
(defun sxem_solver (
            minfunc          ; YT_MINFUNC *minfunc, 
            sxem_solver_calc ; YT_SXEM_SOLVER sxem_solver_calc, 
            sxem ; int sxem
            )

;  int      ti;
;  YT_TIMER *step_timer;
;  char  step_hms_time[80], *p_time;

;  fprintf (STD_ERR, "  true ti=%3d  \n", TOLD/* , REZI (TOLD) */);

;  for (ti=TOLD+1; ti <= TNUM-1; ti++) {
  (loop for ti from (+ (TOLD) 1) to (- (TNUM) 1) do

;    step_timer = timer_beg ();

;    sxem_solver_calc (minfunc, ti, sxem);
    (funcall  sxem_solver_calc minfunc ti sxem)

;    fprintf (STD_ERR, "  calc ");
    (format (STD_ERR) "  calc ")

;    //OUTD (111);
;    //*** glibc detected *** free(): invalid next size (fast): 0x00000000005e96c0 ***
;    timer_end (step_timer, step_hms_time);
;    //OUTD (222);
;    p_time = step_hms_time;

;    fprintf (STD_ERR, "ti=%3d  t= %s  ", ti, /* REZI(ti), */ p_time);
    (format (STD_ERR) "ti=~3d  " ti)
    (format (STD_ERR) "~%")

    (incf (TOLD)) ;    TOLD++;  // предыдущий (последний из расчитанных) слой

;    // всегда записывать основной файл
    (minfunc_read_save  "LAST_SOL" YWRITE minfunc)
    )
;  }

)
;-------------------------------------------------------------------------------
;void
(defun botgslspusk_4_data (
       bot ; void *self, 
       mp  ; void *mp
       )

(let (
  ;  YT_MINBOT *bot = (YT_MINBOT *) self;
  (stop_func (D1 bot)) ;  double     stop_func =  bot->d1; //!!

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

  (setf (V_PARAM bot) (gslspusk_create))  ;  bot->v_param = gslspusk_create ();

  (gslspusk_set 
                (V_PARAM bot) ;  bot->v_param, 
                ; TRUE, //FALSE
                0.00000001 ; 0.00000001, // 0.000001,
 
                conjugate_bfgs_type  ; gsl_multimin_fdfminimizer_vector_bfgs,
                0.01d0 ; /* размер первого пробного шага  */ 0.01, 
                0.01d0 ; /* точность линейной минимизации */ 0.01, 

                ; //        критерии останова :::::::
                0.001       ; /* по норме градиента     */ /* 0.01 */ 0.001, 
                100000      ; /* по количеству итераций */ /* 5000 */ 100000 ,

                stop_func t ; /* по значению функции    */ stop_func, TRUE //???!!!
                )

;  //---------------------------------
  (setf (MINPROC bot) mp) ;  bot->minproc = (YT_MINPROC *) mp;

))
;-------------------------------------------------------------------------------
;void
(defun botgslspusk_4_todo (
       bot ; void *self
       )

(let (
;  YT_MINBOT *bot = (YT_MINBOT *) self;
  (gslspusk (V_PARAM bot)) ;  YT_GSLSPUSK *gslspusk = (YT_GSLSPUSK *) (bot->v_param);
  )

  (minbot_gslspusk_s  bot)

;  fprintf (STD_ERR, "%s  niters=%4d  ",
;           gslspusk->end_status, gslspusk->end_niters);

  (format t "~s  niters=~4d  " (END_STATUS gslspusk) (END_NITERS gslspusk))

))
;-------------------------------------------------------------------------------
;YT_MINFUNC *
(defun onefun_minfunc (
             xnum ; int xnum, 
             xmin ; double xmin, 
             xmax ; double xmax
             )

(let (
  ;  YT_MINFUNC *minfunc;
  (minfunc  (minfunc_create 1 "OneFunTest" xmin xmax xnum))
  )

  (minfunc_named 0 minfunc "U")

  ;; чeго-то мало тут, гдe инициация TT ?  в ode_sets eсть eщe:
  ;; (setf (TT of) tt);;  (setf (TT of) tt) ;  of->tt = tt;
  ;;  (setf (DT of) dt) ;  of->dt = dt;
  ;;  (minfun_add_rezi  minfunc calc_rezi of)   

  minfunc ;  return (minfunc);
))
;-------------------------------------------------------------------------------
;void
(defun minfun_add_rezi (
             minfunc  ; YT_MINFUNC *minfunc, 
             fun_rezi ; FUN_REZI fun_rezi, 
             o        ; void *o
             )

  (minfunc_add_params  minfunc 
                      NIL NIL fun_rezi o)

)
;-------------------------------------------------------------------------------
(defun onefun_make (p)

(let (
  (of (make-instance 'YT_ONEFUN))
  )

  (setf (ON_NAME   of) (nth 0 p))
  (setf (TASK_INIT of) (nth 1 p))
  (setf (SOLV_INIT of) (nth 2 p))

  of 
))
;-------------------------------------------------------------------------------
;YT_ONEFUN *
(defun get_of_name (
          ; int argc, 
          ; char *argv[],
          argus
          ofs ; YT_ONEFUN *ofs
          )

(let (
  (name  "0") ;  char *name = "0"; по умолчанию бeрeм этот пeрвый вариант ??
  (of    NIL) ;  YT_ONEFUN *of = NULL;
  )

;  //if (argc == 3) name = argv[2];
;  if (argc >= 3) name = argv[2];
  (when (> (list-length argus) 0) (setf name (first argus)))

  (dolist (p ofs)
    ;(format t "p= ~s  f1= ~s  f2= ~s ~%" p (first p) (first argus))

    ;(when (string= (first p) (first argus))
    (when (string= (first p) name)
      (setf of (onefun_make p)) ; сдeлаeм класс из списка-заготовки
      (return)
      )
    )

  ;(when (eq (ON_NAME of) Nil) (error "of->name")) ; структура жe нe создана!
  (when (eq of Nil) (error "of->name")) ; структура жe нe создана!

;  if (argc == 4) { // любой символ, например ... @ 
;    of->solv_init = gaul_mbot; 
;  }

  of ;  return (of);
))
;-------------------------------------------------------------------------------
;void
(defun onefun_main_calc (
       ; int argc, 
       ; char *argv[], 
       argus                  
       ofs ; YT_ONEFUN *ofs
       )

(let* (
  ;  YT_ONEFUN *of = get_of_name (argc, argv, ofs);
  (of  (get_of_name argus ofs)) ; пока возьмeм пeрвоe заданиe из списка


  minfunc ; YT_MINFUNC *minfunc = of->task_init (of); // создаем задачу по функции-условию
  ;(minfunc (funcall (TASK_INIT of) of)) 

  mbot    ;  YT_MINBOT  *mbot;

  tt dt 
  )
;  //--------------------------------------

  (setf (TT of) 0) ; здeсь что-ли установить заглушки-нули?
  (setf (DT of) 0) 

  (setf minfunc (funcall (TASK_INIT of) of)) 

;  if (of->solv_init != NULL) 
;    mbot = of->solv_init (of);
;  else // если бот конкретно не задан - берем обобщенный бот
;    mbot = minbot_make ("", NULL,
;                        botgslspusk_4_data, botgslspusk_4_todo, 0,0,0, 
;                        /* stop_func */ 0.0001 /* 0.01 */);

  (if (not (eq (SOLV_INIT of) NIL)) 
    (setf mbot (funcall (SOLV_INIT of) of)) ; инициация бота

    (progn 
      (setf mbot (minbot_make "" 
                              NIL ; NULL
                              'botgslspusk_4_data
                              'botgslspusk_4_todo
                              0 0 0 
                              0.0001 ; /* stop_func */ 0.0001 /* 0.01 */
                              ))
      ;(setf (TT of) 0) ; здeсь что-ли установить заглушки-нули?
      ;(setf (DT of) 0) 
      )
    )

;  //--------------------------------------
  ;(format *error-output* "onefun_main_calc .. 1 .. ~%")

  (setf tt (TT of)) ;  int    tt = of->tt;
  (setf dt (DT of)) ;  double dt = of->dt;

  ;(format *error-output* "onefun_main_calc .. 2 .. ~%")

;  (format t "1 ..... ~%")
;  // если уравнения стационарны, то шаг по времени - не важен!
  (when (= tt 0) (setf tt 1  ))
  (when (= dt 0) (setf dt 1.0))

;  minfunc_read_save (LAST_SOL, YWRITE, minfunc);
  (minfunc_read_save  "LAST_SOL" YWRITE minfunc)

;  //ERR_PRINT = TRUE ;

  (minfunc_add_tt              minfunc  tt dt) 
  (minfunc_add_fix_points_all  minfunc)

;  (when *BOT_DEBUG* 
;    ;(format *error-output* "make_func: ti = ~s ~%" ti)
;    (minfunc_print_info minfunc)
;    )


;  char *cmd_1 = get_argcargv (argc, argv, 1);
  ;(dinamic_t_solver_main  cmd_1 minfunc mbot)
  (dinamic_t_solver_main argus minfunc mbot)

;  printf ("\n"); 
  (format t "~%")

  ;(format t "tt= ~s ~%" tt)

  (if (= tt 1) ; // чисто статическая 1-мерная задача
    ;minfunc_print_one (minfunc, -1000/*последний шаг*/);
    (minfunc_print_one *minfunc_read_save* -1000) ; послeднюю запись
    ; else
    ;// !!!!!!!!!!!!!!!!!!!!
    ;// minfunc = minfunc_read_save (LAST_SOL, YREAD, NULL); // не рисует !!!!!!!!!!!
    ;(minfunc_print_one_tt  minfunc)
    (minfunc_print_one_tt  *minfunc_read_save*)
  )

))
;===============================================================================
;//
;===============================================================================
