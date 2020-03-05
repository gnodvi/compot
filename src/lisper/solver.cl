; -*-   mode: lisp ; coding: koi8   -*- ----------------------------------------

;-------------------------------------------------------------------------------
;-------------------------------------------------------------------------------
;void
;temp_argv (int argc, char *argv[],
;           char **p_mode, int *p_xx, double *p_xmin, double *p_xmax, int *p_tt, double *p_tstep)
;{
;-------------------------------------------------------------------------------
(defun temp_argv (argus)

  ;(format t "temp_argv: argus= ~s  len= ~s ~%" argus (list-length argus))
  ;(when (/= (list-length argus) 6) (error "argc-len"))

(let (
  ;(len (list-length argus))

  (mode  (nth 0 argus))
  (xx    (parse-integer    (nth 1 argus)))
  (xmin  (read-from-string (nth 2 argus)))
  (xmax  (read-from-string (nth 3 argus)))
  (tt    (parse-integer    (nth 4 argus)))
  (tstep (read-from-string (nth 5 argus)))
  )

;  if (argc == 8) { 
;    *p_mode  = argv[2];
;    *p_xx    = atoi (argv[3]);
;    *p_xmin  = atof (argv[4]);
;    *p_xmax  = atof (argv[5]); 
;    *p_tt    = atoi (argv[6]);
;    *p_tstep = atof (argv[7]);
;   )
;  } else
;   (error "argc-len")
;   )

  (values  mode  xx xmin xmax  tt tstep)
))
;-------------------------------------------------------------------------------
;YT_MINFUNC *
;temp_minfunc_create (char *name_test, char *name_func, 
;                     int xx, double xmin, double xmax)
;-------------------------------------------------------------------------------
(defun temp_minfunc_create (name_test name_func xx xmin xmax)

(let (
;  YT_MINFUNC *m;
;  m = minfunc_create (1, name_test, xmin, xmax, /* xnum */xx+1);
  (m (minfunc_create  1 name_test xmin xmax (+ xx 1)))
  )

  (minfunc_named  0 m name_func)

  m
))
;-------------------------------------------------------------------------------
;void
(defun temp_main (argus ; int argc, char *argv[]
                  name_test ; char *
                  name_func ; char *
                  temp_argv ; YT_TEMP_ARGV 
                  temp_sets ; YT_TEMP_SETS 
                  mbot      ; YT_MINBOT *
                  )

  ;; -------------------------------------
  (when (eq mbot NIL) 
    (setf mbot  (minbot_make "" 
                             NIL
                             'botgslspusk_3_data
                             'botgslspusk_3_todo 
                             0 0 0  0.000000001))
    )
  ;; -------------------------------------

(let (
  mode xx xmin xmax tt tstep
  make_null calc_rezi
  minfunc
  )

  (multiple-value-setq (mode xx xmin xmax tt tstep)
      (funcall temp_argv argus)
      )

;  char *cmd_1 = get_argcargv (argc, argv, 1);
;  //-------------------------------------

  (multiple-value-setq (make_null calc_rezi)
      (funcall temp_sets mode)
      )

  (setf minfunc (temp_minfunc_create  name_test name_func xx xmin xmax))

  ;;  // make_null (minfunc); - надо бы задавать здесь начальные условия,
  ;;  // однако пока для переменных граничных условий (например heat_200_null) 
  ;;  // требуется создать сначала развертку по T..

  ;;  //minfunc_read_save (LAST_SOL, YWRITE, minfunc);

  ;(format t "01 ..........~%")
  (minfunc_add_tt  minfunc tt tstep)
  (funcall make_null minfunc)
  ;(format t "02 ..........~%")
  
  (minfunc_add_fix_points_all minfunc) ; выдeлили отдeльно 
  ;(format t "03 ..........~%")
  
  ;;(funcall make_null minfunc) ; но тогда что с "постоянными" граничными условиями? 
  
  (minfunc_add_params minfunc 
                      NUL  ;/* calc_rezi_beg */
                      NUL  ;/* calc_rezi_end */
                      calc_rezi NUL)
  
  ;;(minfunc_print_lines_ti minfunc 1)
  (dinamic_t_solver_main  "cmd_1" minfunc mbot)
  ;(format t "04 ..........~%")
  
(minfunc_print_one minfunc -1000) ;/*последний шаг*/
;#-SBCL  (minfunc_print_one minfunc -1000) ;/*последний шаг*/
;#+SBCL  (format t "~%Problems with Windows SBCL in solver.cl -> temp_main -> minfunc_print_one ~%")

  ;(format t "05 ..........~%")
  ;;(minfunc_print_all minfunc) 
  ;;(minfunc_print_gui   *minfunc_read_save*)

  minfunc
))
;===============================================================================
;
;             B E R G E R    M O T I O N      
;
;===============================================================================

;-------------------------------------------------------------------------------
;double
;berger_calc_rezi (void *mf, double *xyz)
;-------------------------------------------------------------------------------
;double
(defun berger_calc_rezi (
             minfunc  ; void *mf 
             xyz      ; double *xyz
             )

;  YT_MINFUNC *minfunc = (YT_MINFUNC *) mf;
(declare (ignore xyz))

;(minfunc_print_lines_ti minfunc 1)

(let (
  v1 v2  u1 u2 v1_ 
  r1 r2 rezi

  (ti   (TI))
  )

  ;(format *error-output* "berger_calc_rezi.. ~%") 

  ;;  inviscid Burgers' equation :
  ;;  d/dt[u] + d/dx[u^2/2] = 0
  ;;   

  ;;  подсчитаем невязку, т.е. расстояние до точного решения
  (setf rezi  0.0)

  ;; здeсь надо бы пeрeйти к интeгралам !

  (loop for xi from (1+ X_BEG) to (X_END) do ; !!!!!!!!!!!!
    

    (setf u1  (Fun_ xi  (- ti 1))) ; прeдыдущий слой
    (setf u2  (Fun_ xi     ti  ))

    (setf v2  (/ (* u2  u2) 2))
    (setf v1_ (Fun_ (- xi 1)  ti))
    (setf v1  (/ (* v1_ v1_) 2))

    (setf r1    (/ (- u2 u1) (TSTEP)))
    (setf r2    (/ (- v2 v1) (XSTEP)))

    (incf rezi (* (+ r1 r2) (+ r1 r2)))

    ;(format *error-output* "xi=~2d  u1=~9,6f u2=~9,6f r1=~9,6f ~%" xi u1 u2 r1)
    )

  ;(format *error-output* "~%")  (quit) ; !! для огтладки !!

  (sqrt rezi)
))
;-------------------------------------------------------------------------------
(defun berger_null (minfunc)

(let (
;  // x := [0, 2*PI]
;  // t := [0, 5.0]
;  // 
;  // initial conditions:    u(x, 0) = sin(x) + 0.5*sin(x/2)
;  // periodic boundary conditions:     u(0, t) = u(2*PI, t)

;  int    xi;
;  double f;
  f x
  )

  ;(format *error-output* "XMIN = ~s ~%" (XMIN))
  ;(format *error-output* "XMAX = ~s ~%" (XMAX))
  ;(format *error-output* "XSTEP= ~s ~%" (XSTEP))
  ;(format *error-output* "~%") 

  (dotimes (xi (XNUM))
    (setf x (XX))
    (setf f  (+ (sin x) (* 0.5 (sin (/ x 2)))))

    ;(format *error-output* "xi= ~2d  x= ~s  f= ~s ~%" xi x f)

;    minfunc_put (/* fi */0, minfunc, xi, /* ti */0, f); // подвижные значения!
    (minfunc_put  0 minfunc xi 0 f) ; // подвижные значения!
    )

  ;(format *error-output* "~%")  (quit) ; !! для огтладки !!

;  // граничные условия (сплошные неподвижные стенки)
  (minfunc_t0_fix  0 minfunc  X_BEG  0.0)
  (minfunc_t0_fix  0 minfunc (X_END) 0.0)

))
;-------------------------------------------------------------------------------
;void
;berger_sets (char *mode, YT_MAKE_NULL *p_make_null, YT_CALC_REZI *p_calc_rezi)
;-------------------------------------------------------------------------------
(defun berger_sets (mode)

  (declare (ignore mode))

;  *p_make_null = berger_null;
;  *p_calc_rezi = berger_calc_rezi;
  (values  'berger_null 'berger_calc_rezi)
)
;-------------------------------------------------------------------------------
;void
;berger_argv (int argc, char *argv[],
;           char **p_mode, int *p_xx, double *p_xmin, double *p_xmax, int *p_tt, double *p_tstep)
;-------------------------------------------------------------------------------
(defun berger_argv (argus)

;(declare (ignore argus))

(let (
  (mode  "")

  ;(xx    10) ; здeсь похожe нeт сходимости.. для бeргeрса !
  (xx    20) 
  (tt    2)  ;; 50 было
  (tstep 0.005) ;; какой точности ?

  (xmin  0.0)
  (xmax  (* 2 G_PI))

  (argc (list-length argus))
  )

;  //argc = argc - 2;
;  //argv = argv + 2;

  ;(format t "argc= ~S ~%" (list-length argus))
  ;(format *error-output* "berger_argv  tstep= ~s ~%" tstep)

  (when (= argc 3)   
    (setf xx       (parse-integer (nth 0 argus)))   ;atoi (argv[/* 2 */ 0]);
    (setf tt       (parse-integer (nth 1 argus)))   ;atoi (argv[/* 3 */ 1]);
    (setf tstep (read-from-string (nth 2 argus)))   ;atof (argv[/* 4 */ 2]);
    )

  (values mode xx xmin xmax tt tstep)
))
;-------------------------------------------------------------------------------
;// Jorge Balbas and Eitan Tadmor
;// CentPack-1.0
;// 
;// One Dimensional Burgers' Equation
;-------------------------------------------------------------------------------
(defun berger_main (argus) 

(let (
  mbot ; YT_MINBOT *mbot

  (num       100) ;  int     num = 100;
  (stop_func 0.1) ; double  stop_func = 0.1 /* 0.08 */; 
  )

  (YRAND_C)

  (setf mbot (minbot_make "" 
                          'botspusk_fun_init
                          'botspusk_fun_data 
                          'botspusk_fun_todo
                          num 0 0 stop_func))

;  temp_main (argc, argv, "BergerTest", "U", berger_argv, berger_sets,
;             mbot);
  (temp_main  argus "BergerTest" "U" 'berger_argv 'berger_sets
              mbot)


;  sl s~.cl SOLV berger_main 200 150 0.005
;  // solver B 200 150 0.005    
; была осциляция справа от фронта - ИСПРАВЛЕНО подбором параметров спуска

;  sl s~.cl SOLV berger_main 200 200 0.005
;  // solver B 200 200 0.005    - снова осциляция (но уже позже!)

; для малeнького тeста запустим :
; sl s~.cl SOLV berger_main 100 5 0.005
))
;-------------------------------------------------------------------------------
;void
;berger_main (int argc, char *argv[])
;-------------------------------------------------------------------------------
(defun berger_bees (argus) 

(let (
  mbot ; YT_MINBOT *mbot
  )

  (YRAND_C)

  (setf mbot (minbot_make "BeesFind"  'botbees_init
                     'botbees_data 'botbees_todo_new 
                     0 0 0 0))

  (temp_main  argus "BergerTest" "U" 'berger_argv 'berger_sets
              mbot)

))
;-------------------------------------------------------------------------------
;void
;berger_main_gaul (int argc, char *argv[])
;{

;  // debug = TRUE;
;  //
;  // заработало! но дает сразу болшую осциляцию справа (на отрицательной части
;  // синусоиды), а потом может и варавняться..

;  //YT_MINBOT *mbot = gaulbot_make (400, 400);
;  YT_MINBOT *mbot = gaulbot_de_make (300, 200); // все равно не очень !

;  temp_main (argc, argv, "BergerGaul", "U", berger_argv, berger_sets,
;             mbot);

;  return;
;}
;===============================================================================
;// 
;===============================================================================
;-------------------------------------------------------------------------------
;===============================================================================
