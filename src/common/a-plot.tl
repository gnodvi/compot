# -*-   mode: tcl  ; coding: koi8   -*- ----------------------------------------

set ::_PLOT_DEBUG 0

#-------------------------------------------------------------------------------
# 
if [info exists ::A_PLOT_TL] {
  return
} else {
  set  ::A_PLOT_TL ""
}

# ------------------------------------------------------------------------------

#set ::FR_old 0

# ==============================================================================

# ;(defvar FI_MAX   20)
# ;(defvar TI_MAX 2000)

# ==============================================================================

# (defclass TT_FUNC () ( ; описатeль функции ?
#   (l_name :accessor L_NAME)   ; char   *l_name;

#   ; рабочиe пeрeмeнныe (пeрeд отрисовкой) ?
#   (xmin   :accessor L_XMIN)  
#   (xmax   :accessor L_XMAX)

#   (fmin   :accessor L_FMIN)   
#   (fmax   :accessor L_FMAX)
# ))

# record define TT_FUNC {
#   L_NAME
  
#   L_XMIN 
#   L_XMAX
  
#   L_FMIN 
#   L_FMAX
# }


# (defclass TT_STEP () (
#   (title :accessor TITLE) ;  char     title[80];
#   (f     :accessor F)     ;  double  *f[FI_MAX]; 
#   ;(ti    :accessor L_TI) ;  вообщe то сюда надо вставить
# ))

# record define  TT_STEP {
#   TITLE
#   F
#   F_
#   #L_TI
# }

set ::MAX_OUT 50

# ;-------------------------------------------------------------------------------
# (defclass YT_PLOT () (
#   ;(ti       :accessor L_TI)   ; текущее значение (иногда надо, например в GTK+ ?)

#   (fnum     :accessor L_FNUM)  ; int  fnum, xnum, tnum, tmax;
#   (funcs    :accessor FUNCS)   ; TT_FUNC  funcs[FI_MAX];

#   (xnum     :accessor L_XNUM)   ; а как для других размeрностeй?
#   (x        :accessor X)        ;  double  *x; ?????? зачeм тут массив???
#   (xmin_set :accessor XMIN_SET) ; double   xmin_set, xmax_set; 
#   (xmax_set :accessor XMAX_SET) ; принудительные границы (почeму здeсь?)

#   (tnum     :accessor L_TNUM)
#   (steps    :accessor STEPS)   ;  TT_STEP  steps[TI_MAX]; 

#   ;;  -----------------------------------------------------------
#   ;; рабочиe пeрeмeнныe:
#   (tmax     :accessor TMAX)     ; это зачeм? (- tnum 1)

#   ;;  -----------------------------------------------------------
#   ;;  список фреймов - это вспомогательная структура НАД списком графиков
#   ;;  и отвечает только за внешнее расположение уже готовых графиков по фреймам;
#   ;;  (по умолчанию спимок фреймов идентичен списку графиков
#   ;;  однако в тесте надо задавать этот список индивидуально !)

#   (fr       :accessor FR)    ; int  fr[MAX_OUT][MAX_OUT]; 
#   (wnum     :accessor WNUM)  ; int  wnum; // вычисляется перед отрисовкой
# ))
# ;-------------------------------------------------------------------------------

# record define YT_PLOT {

#   L_FNUM
#   FUNCS
  
#   L_XNUM
#   X      
#   XMIN_SET
#   XMAX_SET
  
#   L_TNUM
#   #STEPS 
#   STEPS_ 
    
#   TMAX
  
#   FR
#   WNUM
# }

#--------------------------------------------------------------------------------
#
# попробовать сделать универсальнее, т.е. здесь получать имя (как бы ссылку!)
#

# FUNCS - информация о каждой функции
#

# record define TT_FUNC {
#   L_NAME
  
#   L_XMIN 
#   L_XMAX
  
#   L_FMIN 
#   L_FMAX
# }
#--------------------------------------------------------------------------------

# # (defmacro PP_XMIN (p fi)  `(L_XMIN (nth ,fi (FUNCS ,p)))) ; (p)->funcs[(fi)]).xmin
# #
# proc PP_XMIN {plot fi} {

#   set func [lindex [$plot.FUNCS] $fi]  
#   return [$func vget -L_XMIN]
# }
# #-------------------------------------------------
# #
# # (defmacro PP_XMAX (p fi)  `(L_XMAX (nth ,fi (FUNCS ,p))))
# #
# proc PP_XMAX {plot fi} {

#   set func [lindex [$plot.FUNCS] $fi]  
#   return [$func vget -L_XMAX]
# }

# #--------------------------------------------------------------------------------
# #
# # (defmacro PP_FMIN (p fi)  `(L_FMIN (nth ,fi (FUNCS ,p))))
# #
# proc PP_FMIN {plot fi} {

#   set func [lindex [$plot.FUNCS] $fi]  
#   return [$func vget -L_FMIN]
# }
# #-------------------------------------------------
# #
# # (defmacro PP_FMAX (p fi)  `(L_FMAX (nth ,fi (FUNCS ,p))))
# #
# proc PP_FMAX {plot fi} {

#   set func [lindex [$plot.FUNCS] $fi]  
#   return [$func vget -L_FMAX]
# }
#--------------------------------------------------------------------------------
#
# (defmacro PP_NAME (p fi)  `(L_NAME (nth ,fi (FUNCS ,p))) ) ; (p)->funcs[(fi)]).l_name
#
#-------------------------------------------------
# proc PP_NAME {plot fi} {

#   set func [lindex [$plot.FUNCS] $fi]  

#   return [$func vget -L_NAME]
# }
# #-------------------------------------------------
# proc PP_NAME_set {plot fi val} {
  
#   #set func [lindex [$plot.FUNCS] $fi]  
#   #$func.L_NAME = $val
 
#   set [PP_NAME $plot $fi] $val
# }
#-------------------------------------------------
proc PP_NAME_set_NEW {plot fi val} {
  
  #set ptr_funcs_list [dict_get $plot "FUNCS"] 

  # указатель на LIST, надо его раскрыть !!!!!

  #set funcs_list [set $ptr_funcs_list]

  #set pd_func [lindex $funcs_list $fi]  ;# а вот здесь точно указатель на DICT

  #dict_set $pd_func "L_NAME" $val ;# ???????????


  dict_set $plot  "FUNCS" $fi  "L_NAME" $val 

}
#-------------------------------------------------
# proc PP_NAME_get {plot fi} {
  
#   return [set [PP_NAME $plot $fi]]
# }

#--------------------------------------------------------------------------------
#--------------------------------------------------------------------------------
#--------------------------------------------------------------------------------
# (defmacro PP_STEP_NAME (p ti)    `(TITLE      (nth ,ti (STEPS ,p))) )
#
#-------------------------------------------------
# proc PP_STEP_NAME_set {plot ti val} {

#   set steps [set [$plot.STEPS_]]

#   set step [lindex $steps $ti]

#   $step.TITLE = $val
# }
#-------------------------------------------------
proc PP_STEP_NAME_set_NEW {plot ti val} {

#   #set steps [set [$plot.STEPS_]]

#   set ptr_steps [dict_get $plot "STEPS_"] ;# указатель на список указателей DIСT

#   set steps [set $ptr_steps] ;# список указателей?

#   #puts ""
#   #puts "PP_STEP_NAME_set_NEW: ptr_steps = $ptr_steps"
#   #puts "PP_STEP_NAME_set_NEW:     steps = $steps"
#   #puts ""

#   set step [lindex $steps $ti] 

#   #puts ""
#   #puts "PP_STEP_NAME_set_NEW: steps = $steps, step($ti) = $step"
#   #puts ""

#   #exit
#   # 
#   #$step.TITLE = $val

#   dict set $step "TITLE" $val

#   #puts "PP_STEP_NAME_set_NEW:      step = [set $step]"

#   #exit

  dict_set  $plot "T_$ti" "TITLE" $val

}
#-------------------------------------------------
proc PP_STEP_NAME_get {plot ti} {

  set steps [set [$plot.STEPS_]]

  set step [lindex $steps $ti]

  return [$step.TITLE]

}
#-------------------------------------------------
# proc PP_STEP_NAME_get_NEW {plot ti} {

#   #set steps [set [$plot.STEPS_]]
#   #set step [lindex $steps $ti]
#   #return [$step.TITLE]


#   return [dict_get $plot "STEPS_" $ti "TITLE"]
# }
#--------------------------------------------------------------------------------
# (defmacro PP_STEP_F    (p ti fi) `(nth ,fi (F (nth ,ti (STEPS ,p)))) )
#
# а здесь ссылка должна быть на элемент списка, а у него не отдельного имени!
# поэтому остановимся раньше

#--------------------------------------------------------------------------------
# proc PP_STEP_F {plot ti} {

#   set steps [set [$plot.STEPS_]]

#   set step [lindex $steps $ti]

#   return [$step vget -F]
# }
#--------------------------------------------------------------------------------
# proc PP_STEP_F_NEW {plot ti} {

#   set steps [set [dict_get $plot "STEPS_"]]

#   set step [lindex $steps $ti]

#   #puts "PP_STEP_F_NEW: step = $step"
#   #exit

#   return $step ;# указатель на словарь STEP
# }
#--------------------------------------------------------------------------------

# proc PP_STEP_F_set {plot ti fi  val} {

  #set step [lindex [$plot.STEPS] $ti]
  #set _f [$step vget -F]

  #set _f [PP_STEP_F $plot $ti $fi]

  #lset $_f $fi  $val
  #lset [PP_STEP_F $plot $ti $fi]  $fi  $val

#   lset [PP_STEP_F $plot $ti]  $fi  $val
# }
#--------------------------------------------------------------------------------
# proc step_print_info {step} {


#   puts "step_print_info--------------------------:"
#   puts ""

#   puts "  step = $step"

#   puts "  TITLE  = [$step.TITLE]"

#   puts "  F      = [$step.F]"
#   #puts "  F_     = [set [$step.F_]]"

#   #puts "  L_TI   = [$step.L_TI]"

#   puts ""
#   puts "-----------------------------------------:"
#   puts ""

# }
#----------------------------------------------------------------------

# ;-------------------------------------------------------------------------------
# ; MINFUNC - это, по видимому, PLOT с добавлeнными статусами FMOD
# ;           для пeрeхода в пространство MINPROC.
# ;-------------------------------------------------------------------------------

# ;(defmacro XSTEP () `(P_XSTEP minfunc))
# ;(defmacro XVAL (xi) `(+ (XMIN) (* (XSTEP) ,xi)))

# (defmacro P1_X (xi) `(nth ,xi (X plot)))
#
#-------------------------------------------------
# proc P1_X_set {plot xi val} {

#   set _x [$plot vget -X]

#   lset $_x $xi  $val
# }
#-------------------------------------------------
# proc P1_X_set_NEW {plot xi val} {

#   #set _x [$plot vget -X]

#   set _x [dict_get $plot "X"] ;# указатель на список?

#   lset $_x $xi  $val
# }
#-------------------------------------------------
# proc P1_X_get {plot xi} {

#   #set _x [$plot vget -X]
#   #return [lindex $_x $xi]

#   return [lindex [$plot.X] $xi]

# }
#-------------------------------------------------------------------------------

# ;(defmacro FVAl_ARR (ti fi) `(nth ,fi (P_FVAL (nth ,ti (P_STEPS minfunc)))))
# ;(defmacro FVAL_2D (ti fi xi yi) (list 'aref (list 'FVAl_ARR ti fi) xi yi))
# ;(defmacro Fn (fi) `(FVAL ti ,fi xi))

# ;(defmacro FVAL (ti fi xi) `(aref (FVAl_ARR ,ti ,fi) ,xi))

#-------------------------------------------------------------------------------
#----------------------------------------------------------------------
# proc PP_STEP_F_ {plot ti} {

#   set steps [set [$plot.STEPS_]]
#   set step  [lindex $steps $ti]

#   #set name_step_f_  [$step vget -F_] ;# имя переменной в структуре
#   #return [set $name_step_f_] ;# а это имя списка

#   return [$step.F_] ;# а это имя-указатель  списка (теперь проще)
# }
# -------------------------------------------------------------------------------
# proc get_step_xlist {plot ti fi} {


#   return [$plot.X]
# }
# -------------------------------------------------------------------------------
# proc get_step_ylist {plot ti fi} { 

#   set step_f [set [PP_STEP_F $plot $ti]]

#   set f_line [lindex $step_f $fi]

#   return $f_line
# }
# -------------------------------------------------------------------------------
proc get_step_xlist_NEW {plot ti fi} {

  #set ret {}

  # вложенный словарь крайнего уровня
  # 
  set d [dict_get $plot "T_$ti" "F_$fi"]

  return [dict keys $d]
}
# -------------------------------------------------------------------------------
proc get_step_ylist_NEW {plot ti fi} { 

  set f_line {}

  #set step_f [set [PP_STEP_F $plot $ti]]
  #set f_line [lindex $step_f $fi]

  # ??????????? это вообще чего там ??

  #set step_f [set [dict_get $plot "STEPS_" $ti "F"]] 

  #puts ""
  #puts "step_f = $step_f"
  #puts ""

  # TODO - пока все значения как словарь, поэтому
  # здесь надо преобразовать в список &!
  #
  # а, кстати, может словарь более обще? ведь интервалы могут по иксу быть
  # разные ?? а так я себя сразу ограничил уже. и можно в каждое значение
  # будет добавлять флажки нужные ??!!

  #exit 

  #set f_line [lindex $step_f $fi]

  # вложенный словарь крайнего уровня
  # 
  set d [dict_get $plot "T_$ti" "F_$fi"]

  dict for {key val} $d {
   
    lappend f_line $val
  }

  return $f_line
}
#-------------------------------------------------------------------------------
# (defmacro PVAL (ti fi xi) `(nth ,xi (PP_STEP_F plot ,ti ,fi)))
#
# proc PVAL_set {plot  ti fi xi  val} {

#   #set _f [PP_STEP_F $plot $ti $fi]
#   #lset $_f $xi  $val

#   set _f [PP_STEP_F $plot $ti]
#   lset $_f $fi $xi  $val
#   #puts "_f = $_f  -> [set $_f]"



#   #if {0} {
#   #  # в новый массив:
#   #  # 
#   #  set _f [PP_STEP_F_ $plot $ti]
#   #  set _l [lindex [set $_f] $fi]
#   #  #puts "$ti $fi $xi :  _f = $_f  -> [set $_f]  $_l  [set $_l]"
  
#   #  lset $_l $xi  $val
#   #}
  
# }
#-------------------------------------------------
# proc PVAL_set_NEW {plot  ti fi xi  val} {

#   #set _f [PP_STEP_F $plot $ti]

#   #set _f [PP_STEP_F_NEW $plot $ti]
#   #lset $_f $fi $xi  $val

#   #set pl [dict_get $plot "STEPS_" $ti $fi] ;# указатель на список ?

#   set pl [dict_get $plot "STEPS_" $ti "F" $fi] ;# указатель на список ?

#   puts ""
#   puts "pl = $pl"
#   puts ""

#   lset $pl $xi $val

#   #set ptr_STEP [PP_STEP_F_NEW $plot $ti]
#   #dict_set $ptr_STEP  $fi $xi  $val ;# ????? только здесь наверное списки нужно??

# }
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------

# ;(defmacro Fun_ (xi ti) `(FVAL ,ti 0 ,xi))
# (defmacro Pun_ (xi ti) `(PVAL ,ti 0 ,xi))

# ;//---------------------------------

# ;(defmacro FIMQ (fi) `(P_NAME (nth ,fi (P_FUNCS minfunc))))
# (defmacro PIMQ (fi) `(PP_NAME plot ,fi)) ; это ужe eсть в PLOT

# ;-------------------------------------------------------------------------------
# ;(defun minfunc_put (fi minfunc xi ti val)
# (defun plot_put (fi plot xi ti val)

#   ;(setf (FVAL ti fi xi) val)
#   ;(setf (FMOD    fi xi) FALSE) ; // только на нижней границе

#   (setf (PVAL ti fi xi) val)
# )
#-------------------------------------------------------------------------------
# proc plot1_make_fdata {plot} {

#   #   (make-list (L_XNUM plot)) ; хорошо бы сразу проинициировать..

#   return [list_make [$plot.L_XNUM]]
# }
#-------------------------------------------------------------------------------
# proc plot1_make_fdata_ {plot} {


#   return [list_create [$plot.L_XNUM]]
# }
#-------------------------------------------------------------------------------
# proc plot_make_step_fi {plot ti fi} {

  
#   set f_data  [plot1_make_fdata  $plot]
#   #set f_data_ [plot1_make_fdata_ $plot] ;# "указатель" на список
 
#   #   (setf (PP_STEP_F plot ti fi) f_data)    ; P_LINE (plot,fi,0) = f_line; 
#   #PP_STEP_F_set $plot $ti $fi  $f_data

#   lset [PP_STEP_F  $plot $ti]  $fi $f_data
#   #lset [PP_STEP_F_ $plot $ti]  $fi $f_data_

#   return
# }
#-------------------------------------------------------------------------------
# proc plot_make_step_fi_NEW {plot ti fi} {

#   set xnum  [dict_get $plot "L_XNUM"]

#   #set f_data  [list_make $xnum]
#   set f_data  [list_create $xnum "@"]

#   #puts "f_data = $f_data"
#   #exit

#   #lset [PP_STEP_F_NEW  $plot $ti]  $fi $f_data ;# ????

#   dict set $plot "STEPS_" $ti $fi  $f_data ;# запишем указатель на список?

#   return
# }
#-------------------------------------------------------------------------------
# (defun plot_make_step (plot ti fi)

# (let (
#   (step_name "PLOT_TEST")  ; "TITLE-STEP"
#   )

#   (setf (PP_STEP_NAME plot ti)  step_name)
#   (plot_make_step_fi  plot ti fi)

# ))
#-------------------------------------------------------------------------------
# ; --> t_cell.li
#-------------------------------------------------------------------------------
# (defun plot_put_all (plot ti fi val)

#   (plot_make_step  plot ti fi) ; нужно бы раньшe ужe всe подготовить
#   ;(plot_make_step_new  plot ti)

#   (dotimes (i (L_XNUM plot))
#     (setf (nth i (X plot)) i) ; plot->x[i] = i;      
#     (setf (nth i (PP_STEP_F plot ti 0)) val)
#     )

# )
#-------------------------------------------------------------------------------
# ;(defun minfunc_named (fi minfunc name)
# (defun plot_named (fi plot name)

#   ;(setf (FIMQ fi) name)
#   (setf (PIMQ fi) name)
# )
#-------------------------------------------------------------------------------
# ;
#-------------------------------------------------------------------------------
  
# (defclass T_PLOTSTEP () (

#   (plot   :accessor PLOT)    ;  YT_PLOT *plot;
#   (ih_one :accessor IH_ONE)  ;  int      ih_one, iw, ih;
#   (iw     :accessor IW)
#   (ih     :accessor IH)
#   (gp     :accessor GP)      ;  void    *gp;
#   (first1 :accessor FIRST1)  ;  BOOL     first1;
#   (first2 :accessor FIRST2)  ;  BOOL     first2;
# ))

# record define T_PLOTSTEP {

#   PLOT
#   IH_ONE
#   IW
#   IH
#   GP    
#   FIRST1
#   FIRST2
  
# }

# -------------------------------------------------------------------------------
# -------------------------------------------------------------------------------
# proc plot_frames_init0 {plot} {

#   set wi_max $::MAX_OUT
#   set li_max $::MAX_OUT

#   #   ;; начальная инициация списка фреймов/графиков:
  
#   #   (dotimes (wi MAX_OUT)
#   #   (dotimes (li MAX_OUT)
#   #     ;;  plot->fr[wi][li] = -1; // вот это разумно!
#   #     (setf (aref (FR plot) wi li) -1) 
#   #     ))
  
#   dotimes wi $wi_max {
#   dotimes li $li_max {

#     arr2d_set [$plot.FR] $wi $li -1 
#   }}

# }
# -------------------------------------------------------------------------------
proc plot_frames_init0_NEW {plot {wi_max 5} {li_max 5}} {

  # начальная инициация списка фреймов/графиков:
  
  dotimes wi $wi_max {
  dotimes li $li_max {

    arr2d_set_NEW  "$plot FR" $wi $li -1 
  }}

  return
}
# ;-------------------------------------------------------------------------------
proc PLOT_FR_set_NEW {plot fi ti val} { 


  arr2d_set_NEW "$plot FR" $fi $ti  $val  

}
# ;-------------------------------------------------------------------------------
proc plot_frames_init1_NEW {plot} {

  # пока формируем простой список фреймов, 
  # полагая, что в одном фрейме - один график..
  
  set fnum [dict_get $plot "L_FNUM"]
  
  dotimes fi $fnum {

    PLOT_FR_set_NEW $plot $fi 0  $fi 
  }
  
}
# ;-------------------------------------------------------------------------------
# (defun plot_frames_init9 (plot)

# ;  int fi;
# ;  // загоняем все графики в один фрейм

# ;  for (fi=0 ; fi < plot->fnum ; fi++) {
# ;    plot->fr[0][fi] = fi; 
# ;  }

#   (dotimes (fi (L_FNUM plot))
#     (setf (aref (FR plot) 0 fi) fi)
#     )
# )
# -------------------------------------------------------------------------------
# proc step_create {} {

#   set step [make-instance "TT_STEP"]
  
#   # ;  double  *f[FI_MAX]; 

#   $step.F  = [list_make  $::FI_MAX] ;# тоже список!
  
#   $step.F_ = [list_create $::FI_MAX] ;# тоже список! указателей?
  
#   return $step
# }
# -------------------------------------------------------------------------------
# proc step_create_NEW {} {

#   #set step [make-instance "TT_STEP"]
  
#   set step [dict_create]
  
#   # ;  double  *f[FI_MAX]; 

#   #$step.F  = [make-list  $::FI_MAX] ;# тоже список!  
#   #$step.F_ = [list_create $::FI_MAX] ;# тоже список! указателей?
  
#   dict_set $step "F" [list_create $::FI_MAX]
  
#   return $step
# }
# -------------------------------------------------------------------------------
# proc PLOT_FUNCS_set {plot fi val} { 

#   set   _name [$plot vget -FUNCS]

#   lset $_name $fi $val

# }
# -------------------------------------------------------------------------------
proc PLOT_FUNCS_set_NEW {plot fi val} { 

  #set   _name [$plot vget -FUNCS]

  set   _name [dict get [set $plot] "FUNCS"] ;# ссылка на LIST

  lset $_name $fi $val

}
# -------------------------------------------------------------------------------
# proc PLOT_STEPS_set {plot ti val} { 

#   #set   _name [$plot vget -STEPS]

#   set   _name [$plot.STEPS_] ;# указатель на список шагов


#   #puts "PLOT_STEPS_set: steps= [set $_name]"

#   lset $_name $ti $val

#   #puts "PLOT_STEPS_set: steps= [set $_name]"

#   #puts ""
#   #exit
# }
# -------------------------------------------------------------------------------
# proc PLOT_STEPS_set_NEW {plot ti val} { 

#   #set   _name [$plot.STEPS_] ;# указатель на список шагов

#   set   _name [dict get [set $plot] "STEPS_"] ;# ссылка на LIST

#   lset $_name $ti $val

# }
# ;-------------------------------------------------------------------------------
# proc plot_create {fnum xnum tnum} {

#   # (let* (
#   set plot [make-instance "YT_PLOT"]
#   # ;  ((FNUM plot) fnum) ; а почeму здeсь нeльзя ??
#   #   )
  
#   $plot.L_FNUM = $fnum
#   $plot.L_XNUM = $xnum
#   $plot.L_TNUM = $tnum
#   $plot.TMAX   = [expr {$tnum - 1}]
  
#   $plot.FUNCS  = [list_make $::FI_MAX]

#   dotimes fi $fnum {
#     #     (setf (nth fi (FUNCS plot)) (make-instance 'TT_FUNC)) ; надо явно их создать!
#     #puts "fi = $fi"
#     PLOT_FUNCS_set $plot $fi  [make-instance "TT_FUNC"]
#   }
  
#   # ;  plot->x = (double*) malloc (xnum * sizeof(double));
#   $plot.X  = [list_make $xnum]

#   #   (setf     (X plot) (make-list xnum)) ; ????? зачeм ?????
#   #   ;; это по врeмeни могут быть шаги нeравномeрныe, а "клeтки" - всe ровныe!!
  
#   #   ;; создаeм шаги по врeмeни (но пока "пустыe")

#   #$plot.STEPS = [make-list $::TI_MAX]  !!!?? зачем мне тут столько?

#   #$plot.STEPS = [make-list $tnum]
#   $plot.STEPS_ = [list_create $tnum]

#   #puts "plot.STEPS_ = [$plot.STEPS_]"

#   dotimes ti $tnum {
#     #     (setf (nth ti (STEPS plot)) (step_create)) 
#     PLOT_STEPS_set $plot $ti  [step_create]
#   }
  
#   #   ;; а нулeвой шаг когда создаeм?
#   #   ;(plot_make_step  plot ti fi)
  
#   #   ;;------------------------------------------------------------
#   #   ;; int fr[MAX_OUT][MAX_OUT]; 

#   #   (setf (FR plot) (make-array (list MAX_OUT MAX_OUT)))
#   $plot.FR = [arr2d_make $::MAX_OUT $::MAX_OUT]
  
#   #   ;; начальная инициация (обнуление) списка фреймов:
#   plot_frames_init0  $plot
  
#   #   ;; начальная инициация функций:
#   dotimes fi $fnum {
#     #     (setf (PP_NAME plot fi) "")
#     PP_NAME_set $plot $fi ""
#   }
  
#   #   ;;  пока формируем простой список фреймов - по одному графику 
#   plot_frames_init1  $plot
#   #   ;;------------------------------------------------------------
  
#   #   ;(setf (L_TI plot) 0)
  
#   $plot.XMIN_SET = 0 ;# так было с Си по умолчанию ?!
#   $plot.XMAX_SET = 0 ;#
  
#   return $plot
# }
# -------------------------------------------------------------------------------
proc plot_create_NEW {fnum xnum tnum} {

  set plot [dict_create]

  dict_set $plot "L_FNUM" $fnum
  dict_set $plot "L_XNUM" $xnum
  dict_set $plot "L_TNUM" $tnum
  dict_set $plot "TMAX"   [expr {$tnum - 1}]

  dict_set $plot "FUNCS" {} ;#[list_create $fnum]
  
  
  set pd_arr [arr2d_make_NEW  $::MAX_OUT $::MAX_OUT] ;# указатель на словарь

  dict_set  $plot "FR" [set $pd_arr] ;# записываем сам словарь
 
  #  начальная инициация (обнуление) списка фреймов:
  #
  set wi_max $::MAX_OUT
  set li_max $::MAX_OUT

  plot_frames_init0_NEW  $plot
  
  # пока формируем простой список фреймов - по одному графику
  #
  plot_frames_init1_NEW  $plot
  

  #  начальная инициация функций:
  #
  dotimes fi $fnum {

    PP_NAME_set_NEW  $plot $fi ""
  }
  
  dict set $plot "XMIN_SET" 0
  dict set $plot "XMAX_SET" 0
  
  return $plot
}
# -------------------------------------------------------------------------------
# proc plot_min_max_local {fi ti plot} { 

#   # (let (
#   #   xmin ymin xmax ymax
#   #   f_line
#   set x_line [$plot.X]
#   #   )
#   #puts "x = $x"

  
#   set xmin   $::G_MAXDOUBLE
#   set xmax   [expr {- $::G_MAXDOUBLE}]

#   set ymin   $::G_MAXDOUBLE
#   set ymax   [expr {- $::G_MAXDOUBLE}]
  
#   #puts "BEG) ... $xmin $ymin $xmax $ymax"

#   set f_line [get_step_ylist  $plot $ti $fi]

#   #puts stderr "  f_line = |$f_line|"
#   #puts stderr "size x_line = [llength $x_line]"
#   #puts stderr "size f_line = [llength $f_line]"
#   #puts stderr ""
    
#   dotimes i [$plot.L_XNUM] {
  
#     set x [lindex $x_line $i]

#     if {$x < $xmin} {set xmin $x}
#     if {$x > $xmax} {set xmax $x}
    
#     #puts "  $i) ... $xmin $ymin $xmax $ymax"

#     #set step_f [set [PP_STEP_F $plot $ti]]
#     #set f_line [lindex $step_f $fi]

#     #set f_line [get_step_ylist  $plot $ti $fi]
#     #puts stderr "  f_line = $f_line"
    
#     set y [lindex $f_line $i]

#     #puts stderr "x = $x  y = $y"

#     if {$y < $ymin} {set ymin $y}
#     if {$y > $ymax} {set ymax $y}
#   }
  
#   #puts "END) ... $xmin $ymin $xmax $ymax"

#   #   (values  xmin ymin xmax ymax)
#   return [list $xmin $ymin $xmax $ymax]
# }
# -------------------------------------------------------------------------------
proc plot_min_max_local_NEW {fi ti  plot} { 

  # puts stderr "plot_min_max_local_NEW ..."
  # puts stderr "fi   = $fi"
  # puts stderr "ti   = $ti"
  # puts stderr "plot = $plot"
  # puts stderr ""

  set xmin   $::G_MAXDOUBLE
  set xmax   [expr {- $::G_MAXDOUBLE}]
  set ymin   $::G_MAXDOUBLE
  set ymax   [expr {- $::G_MAXDOUBLE}]

  
  set xnum   [dict_get           $plot "L_XNUM"] ;# должно соответствовать строке !!! 
  set x_line [get_step_xlist_NEW $plot  $ti $fi]

  set xnum_real [llength $x_line] ;# это что есть в реальности

  if {$xnum != $xnum_real} {

    puts stderr "xnum      = $xnum"
    puts stderr "xnum_real = $xnum_real"
    puts stderr "x_line    = $x_line"
    
    # сделаем реальным, видимо где-то ошиблись при формировании !?
    #set xnum $xnum_real

    puts stderr ""
    puts stderr "plot_min_max_local_NEW:  ERROR: (L_XNUM) xnum != xnum_real"
    puts stderr ""

    exit
  }
  
  dotimes i $xnum {
  
    set x [lindex $x_line $i]

    #puts stderr "i = $i  x = $x"

    if {$x < $xmin} {set xmin $x}
    if {$x > $xmax} {set xmax $x}
    
    # если ключ целый, то всё нормально, а в общем случае??
    # 
    #set y [dict_get $plot "T_$ti" "F_$fi"  $i]
    
    set y [dict_get $plot "T_$ti" "F_$fi"  $x]

    if {$y < $ymin} {set ymin $y}
    if {$y > $ymax} {set ymax $y}
  }
  

  return [list $xmin $ymin $xmax $ymax]
}
# -------------------------------------------------------------------------------
proc plot_min_max_NEW {fi plot} {

  # посчитаем "габариты" конкретной функции на всём временном интервале
  # 

  set XMIN   $::G_MAXDOUBLE
  set XMAX   [expr {- $::G_MAXDOUBLE}]
  set FMIN   $::G_MAXDOUBLE
  set FMAX   [expr {- $::G_MAXDOUBLE}]
  
  set tnum [dict_get $plot "L_TNUM"]

  dotimes ti $tnum {

    foreach  {xmin ymin xmax ymax} \
                                 [plot_min_max_local_NEW  $fi $ti $plot] {}
   
    set XMIN [expr {min ($xmin, $XMIN)}]
    set XMAX [expr {max ($xmax, $XMAX)}]
    
    set FMIN [expr {min ($ymin, $FMIN)}]
    set FMAX [expr {max ($ymax, $FMAX)}]
  }
  
  if {[FRavno  $FMIN $FMAX  $::EPS]} {

    set FMIN [expr {$FMIN  - 10.0}]
    set FMAX [expr {$FMAX  + 10.0}]
  }
  
  dict_set $plot "FUNCS" $fi "L_XMIN" $XMIN 
  dict_set $plot "FUNCS" $fi "L_XMAX" $XMAX 
  dict_set $plot "FUNCS" $fi "L_FMIN" $FMIN 
  dict_set $plot "FUNCS" $fi "L_FMAX" $FMAX 
 
  return
}
# -------------------------------------------------------------------------------
# посчитаeм габариты значeний по функциям во фрeймe
# -------------------------------------------------------------------------------
# proc plot_get_minmax_frame {p wi} {

#   # ;                       double *p_xmin, double *p_xmax, double *p_ymin, double *p_ymax)
  
#   # (let* (
#   #   xmin xmax ymin ymax
#   #        is_xrang_calc
#   #   fi 
#   set li 0
  
#   #   )
  
#   set xmin  [$p.XMIN_SET]
#   set xmax  [$p.XMAX_SET]
  
#   #   ;(format *error-output*  "plot_get_minmax_frame: xmin=~s xmax=~s ~%" xmin xmax)
#   #   ;(format *error-output*  "PP_XMIN= ~s ~%" (PP_XMIN p 0))
#   #   ;(format *error-output*  "PP_XMAX= ~s ~%" (PP_XMAX p 0))
  
#   if {$xmin >= $xmax} { ;# условный сигнал - посчитать границы по иксам

#     set is_xrang_calc "t"
#     set xmin         $::G_MAXDOUBLE
#     set xmax [expr {- $::G_MAXDOUBLE}]
    
#   } else {
#     set is_xrang_calc "NIL"
#   }
  
#   set ymin  $::G_MAXDOUBLE
#   set ymax  [expr {- $::G_MAXDOUBLE}] 
  
#   while {1} {

#     #     (setf fi (aref (FR p) wi li))
#     #     (when (= fi -1) (return))
    
#     set fi [arr2d_get [$p.FR] $wi $li]   
#     if {$fi == -1} {break}

#     if  {"t" == $is_xrang_calc} { ;# условный сигнал
#       set xmin [MIN  $xmin [set [PP_XMIN $p $fi]]]
#       set xmax [MAX  $xmax [set [PP_XMAX $p $fi]]]
#     }
    
#     set ymin  [MIN $ymin [set [PP_FMIN $p $fi]]]
#     set ymax  [MAX $ymax [set [PP_FMAX $p $fi]]]
    
#     #     ;(setf li (1+ li))
#     incr li
#   }
  
#   #   ;(format *error-output*  "plot_get_minmax_frame: xmin=~s xmax=~s ~%" xmin xmax)
  
#   return [list  $xmin $xmax $ymin $ymax]
# }
# -------------------------------------------------------------------------------
proc plot_get_minmax_frame_NEW {p wi} {

  # пересчитаем габариты фрейма с учетом габаритов функций, изображаемых
  # линиями этого фрейма

  set xmin  [dict_get $p XMIN_SET]
  set xmax  [dict_get $p XMAX_SET]
  
  if {$xmin >= $xmax} { ;# условный сигнал - посчитать границы по иксам

    set is_xrang_calc "t"
    set xmin         $::G_MAXDOUBLE
    set xmax [expr {- $::G_MAXDOUBLE}]
    
  } else {
    set is_xrang_calc "NIL"
  }
  
  set ymin  $::G_MAXDOUBLE
  set ymax  [expr {- $::G_MAXDOUBLE}] 
  
  # идем циклом по всем возможным линиям фрейма
  #

  set li 0
  
  while {1} {

    set fi [arr2d_get_NEW "$p FR" $wi $li] ;# номер (название) функции для этой линии
  
    if {$fi == -1} {break}

    if  {"t" == $is_xrang_calc} { ;# условный сигнал

      set xmin_ [dict_get $p "FUNCS" $fi "L_XMIN"] 
      set xmax_ [dict_get $p "FUNCS" $fi "L_XMAX"] 

      set xmin [MIN  $xmin $xmin_]
      set xmax [MAX  $xmax $xmax_]
    }
    
    set fmin_ [dict_get $p "FUNCS" $fi "L_FMIN"] 
    set fmax_ [dict_get $p "FUNCS" $fi "L_FMAX"] 

    set ymin  [MIN $ymin $fmin_]
    set ymax  [MAX $ymax $fmax_]
    
    incr li ;# рассмотрим следующую линию фрейма
  }
  
  return [list  $xmin $xmax $ymin $ymax]
}
# ;-------------------------------------------------------------------------------
# ;int 
# ;YInt (double f) 
# ;-------------------------------------------------------------------------------
proc YInt {f} { 
 
  # (let (
  # ;  int     i; 
  # ;  double   o;
  #   i o
  #   )
  
  #   ;i = (int) f; 

  set i [floor_int $f] 

  set o [expr {$f - $i}]
  
  #   (cond
  if {$o >  0.5}   {incr i}
  if {$o < -0.5}   {incr i -1}
  #    )
  
  return $i ;# // ближайшее целое
}
# -------------------------------------------------------------------------------
# proc plot_win_lines {plot win wi ti    ix_0 iy_0 iw ih} {


#   set znaki "+ o * . #"
  
  
#   #   (loop for li from 0 do
#   for {set li 0} {1} {incr li} {

#     #     (setf fi (aref (FR plot) wi li))
#     set fi [arr2d_get [$plot.FR] $wi $li]
    
#     if {$fi == -1} {break}

    
#     # ;; посчитаем габариты фрейма
    
#     foreach  {xmin xmax ymin ymax} \
#                                  [plot_get_minmax_frame  $plot $wi] {}

#     #       ;(format t "li=~s xmin=~s xmax=~s ymin=~s ymax=~s ~%" li xmin xmax ymin ymax)
    
#     set x_step [expr {1.0 * ($xmax - $xmin) / ($iw - 1)}]
#     set y_step [expr {1.0 * ($ymax - $ymin) / ($ih - 1)}]
    
#     #puts "li=$li xmin=$xmin xmax=$xmax ymin=$ymin ymax=$ymax  iw=$iw   x_step=$x_step y_step=$y_step \n"

#     set x [$plot.X]              ;# массив иксов для графика

#     #       (setf y (PP_STEP_F plot ti fi))  ; массив игреков
#     #set step_f [set [PP_STEP_F $plot $ti]]
#     #set y [lindex $step_f $fi] ;# массив игреков
    
#     set y [get_step_ylist  $plot $ti $fi]

#     dotimes  i [$plot.L_XNUM] {

#       set x_i [lindex $x $i]
#       set y_i [lindex $y $i]

#       #puts "i=i x_i=$x_i  xmin=$xmin x_step=$x_step \n"

#       set ix  [YInt [expr {($x_i - $xmin) / $x_step}]]

#       #set iy (YInt (/ (- (nth i y) ymin) y_step)))
#       set iy  [YInt [expr {($y_i - $ymin) / $y_step}]]
      
#       #         ;(win_char  win (nth li znak) (+ ix_0 ix) (- (+ iy_0 ih) (+ iy 1)))

#       win_char  $win [lindex $znaki $li] [expr {$ix_0 + $ix}]  [expr {($iy_0 + $ih) - ($iy + 1)}]
#       #         )
#     }
    
#   }
  
# }
# -------------------------------------------------------------------------------
proc plot_win_lines_NEW {plot win wi ti    ix_0 iy_0 iw ih} {

  set znaki "+ o * . #"
   
  # посчитаем габариты фрейма по габаритам входящих линий
  # (только почему тут в цикле по линиям?)
    
  foreach  {fr_xmin fr_xmax fr_ymin fr_ymax} \
                [plot_get_minmax_frame_NEW  $plot $wi] {}

  set x_step [expr {1.0 * ($fr_xmax - $fr_xmin) / ($iw - 1)}]
  set y_step [expr {1.0 * ($fr_ymax - $fr_ymin) / ($ih - 1)}]
    

  for {set li 0} {1} {incr li} {

    set fi [arr2d_get_NEW "$plot FR" $wi $li]      
    if {$fi == -1} {break}
    
    # указатель массив (список) иксов для графика
    #
    set x [get_step_xlist_NEW $plot  $ti $fi]

    # массив игреков
    # 
    #set y [get_step_ylist  $plot $ti $fi]

    set xnum [dict_get $plot "L_XNUM"]

    dotimes  i $xnum {

      set x_i [lindex $x $i]
      set y_i [dict_get $plot "T_$ti" "F_$fi"   $x_i]

      set ix  [YInt [expr {($x_i - $fr_xmin) / $x_step}]]
      set iy  [YInt [expr {($y_i - $fr_ymin) / $y_step}]]
      
      win_char  $win [lindex $znaki $li] [expr {$ix_0 + $ix}]  \
        [expr {($iy_0 + $ih) - ($iy + 1)}]
    }    
  }
  
  return
}
# -------------------------------------------------------------------------------
# proc print_tabl_one {win plot x y  f_0 f_1  i} {

# # ;                double *f_0, double *f_1, int i)

#   # (declare (ignore f_1))
#   # ; пeчатаeм таблицу только пeрвого графика... а другиe и нe влeзут !!
  
#   # (let (
#   # ;  char str[80];
#   #   str
#   #   )
  
#   # ;  // если есть 2-й график, то печатаем его таблицу
#   # ;  // пока отключим эту сомнительную фичу .. !!
  
#   # ;  //if (f_1)  sprintf (str, "%7.2f % f % f", plot->x[i], f_0[i], f_1[i]);
#   # ;  /* else */   sprintf (str, "%7.2f % f",     plot->x[i], f_0[i]);
  
#   #   ;(format t ".... print_tabl_one: ~%" )
  
#   #   ;(setf str (format nil "~7,2f  ~11,6f " (nth i (X plot)) (nth i f_0)))
  
#   #   (setf str (format nil "~7,2f  ~11,6f " (P1_X  i) (nth i f_0)))


#   set X [P1_X_get $plot $i]

#   set F [lindex $f_0 $i]

#   if {0} {

#   puts stderr ""
#   puts stderr "print_tabl_one: ..............................."
#   puts stderr "print_tabl_one: X = $X"
#   puts stderr "print_tabl_one: F = $F"
#   puts stderr ""
#   }


#   set str [format "%7.2f  %11.6f " $X $F]

#   win_text $win $str $x $y
  
# }
# -------------------------------------------------------------------------------
proc print_tabl_one_NEW {win plot  x y  f_0 f_1  i x_0} {

  # пeчатаeм таблицу только пeрвого графика... а другиe и нe влeзут !!
  
  # если есть 2-й график, то печатаем его таблицу
  # пока отключим эту сомнительную фичу .. !!
  

  #set X [P1_X_get $plot $i]
  set X [lindex $x_0  $i]

  set F [lindex $f_0  $i]

  if {0} {

  puts stderr ""
  puts stderr "print_tabl_one: ..............................."
  puts stderr "print_tabl_one: X = $X"
  puts stderr "print_tabl_one: F = $F"
  puts stderr ""
  }


  set str [format "%7.2f  %11.6f " $X $F]

  win_text $win $str $x $y
  
}
# ;-------------------------------------------------------------------------------
proc floor_int {val} {

  # вообще то есть такая встроенная в expr функция!!
  # 

  return [expr  {int ($val)}] 

}
# -------------------------------------------------------------------------------
# proc  win_plot_tabl_draw {fi0 fi1 ti win plot x y h} {

#   # (let (
#   # ;  int     i, j, h_all, h_beg, h_end;
#   # ;  double  *f_0, *f_1;
  
#   #   h_all h_beg h_end j 
#   #   f_0 f_1
#   #   )
  
#   #   (setf f_0 (PP_STEP_F plot ti fi0))

#   #set step_f [set [PP_STEP_F $plot $ti]]
#   #set f_0 [lindex $step_f  $fi0] ;# массив игреков
  
#   set f_0 [get_step_ylist  $plot $ti $fi0]

#   if {$fi1 == - 1} {  
#     set f_1 "NIL"

#   } else {
#     #       (setf f_1 (PP_STEP_F plot ti fi1))

#     #set f_1 [lindex $step_f  $fi1] ;# массив игреков
#     set f_1 [get_step_ylist  $plot $ti $fi1]
#   }
  
#   #   ;(format t ".... win_plot_tabl_draw:  fi0= ~s  fi1= ~s  ~%" fi0 fi1)
#   #   ;; // печать таблицы значений графика
#   set h_all [expr {$h - 2}]
#   #   ;(format t ".... 0 ~%" )
  



#   if {[$plot.L_XNUM] <= $h_all} { ;# помещаются все значения
  
#     #puts stderr "win_plot_tabl_draw:  L_XNUM = [$plot.L_XNUM] ....  "

#     dotimes i [$plot.L_XNUM] {
#       print_tabl_one  $win $plot [expr {$x + 2}] [expr {$y + $i}]  $f_0 $f_1 $i
#     }

    
#   } else {
    
#     set h_end [floor_int [expr {($h_all / 2.0) - 1}]]

#     set h_beg [expr {$h_all - $h_end - 1}]
    
#     #     ;(format t "h_all=~s  h_end=~s   h_beg=~s ~%"  h_all h_end h_beg)
    
#     dotimes i $h_beg { ;# верхняя часть таблицы    
#       print_tabl_one  $win $plot [expr {$x + 2}] [expr {$y + $i}]  $f_0 $f_1 $i
#     }
    

#     win_text $win "..............." [expr {$x + 2}] [expr {$y + $h_beg}]
    
#     set y [expr {$y + $h_beg + 1}]
    
#     dotimes i $h_end { ;# нижняя часть таблицы

#       set j [expr {[$plot.L_XNUM] - $h_end - (0 - $i)}]
#       print_tabl_one  $win $plot [expr {$x + 2}] [expr {$y + $i}]  $f_0 $f_1 $j
#     }
#   }


# }
# -------------------------------------------------------------------------------
proc  win_plot_tabl_draw_NEW {fi0 fi1 ti win plot x y h} {


  set f_0 [get_step_ylist_NEW  $plot $ti $fi0]
  set x_0 [get_step_xlist_NEW  $plot $ti $fi0]

  if {$fi1 == - 1} {  
    set f_1 "NIL"

  } else {
    set f_1 [get_step_ylist_NEW  $plot $ti $fi1]
    set x_1 [get_step_xlist_NEW  $plot $ti $fi1]
  }
  
  # печать таблицы значений графика

  set h_all [expr {$h - 2}]

  set xnum [dict_get $plot "L_XNUM"]



  if {$xnum <= $h_all} { ;# помещаются все значения
  
    dotimes i $xnum {
      print_tabl_one_NEW  $win $plot [expr {$x + 2}] [expr {$y + $i}]  $f_0 $f_1  $i $x_0
    }

    
  } else {
    
    set h_end [floor_int [expr {($h_all / 2.0) - 1}]]

    set h_beg [expr {$h_all - $h_end - 1}]
    
    dotimes i $h_beg { ;# верхняя часть таблицы    
      print_tabl_one_NEW  $win $plot [expr {$x + 2}] [expr {$y + $i}]  $f_0 $f_1  $i $x_0
    }
    

    win_text $win "..............." [expr {$x + 2}] [expr {$y + $h_beg}]
    
    set y [expr {$y + $h_beg + 1}]
    
    dotimes i $h_end { ;# нижняя часть таблицы

      set j [expr {$xnum - $h_end - (0 - $i)}]

      print_tabl_one_NEW  $win $plot [expr {$x + 2}] [expr {$y + $i}]  $f_0 $f_1 $j $x_0
    }
  }

  return
}
# -------------------------------------------------------------------------------
# proc plot_win_right {plot win wi ti  x0 y0 hh} {

#   # (let (
#   #   (fi0  (aref (FR plot) wi 0)) ; возьмем пока только 1-й график
#   #   (fi1  (aref (FR plot) wi 1))
  
#   set fi0 [arr2d_get [$plot.FR] $wi 0]
#   set fi1 [arr2d_get [$plot.FR] $wi 1]
  
#   #   )
  
#   # ;  //char  str[80];
#   # ;  // пока не будем печатать габариты (не понятно к каким функциям их относить)
  
#   win_text  $win [PP_NAME_get $plot $fi0] [expr {$x0 + 2}] $y0

#   # ;  // имена тоже хорошо бы напечатать все..
  
#   # ;  //sprintf (str, "ymax =  % f", P_YMAX (plot, fi0));
#   # ;  //win_text (win, str, x0+2, y0+1);
  
#   win_plot_tabl_draw  $fi0 $fi1 \
#     $ti $win $plot  $x0 [expr {$y0 + 2}] [expr {$hh - 1}]
  
#   # ;  //sprintf (str, "ymin =  % f", P_YMIN (plot, fi0));
#   # ;  //win_text (win, str, x0+2, y0 + hh-1);
  
# }
# -------------------------------------------------------------------------------
proc plot_win_right_NEW {plot win wi ti  x0 y0 hh} {

  #if {$::FR_old} {
  ##  set fr [dict_get $plot "FR"]
  #}

  #if {$::FR_old} {
  #  set fi0 [arr2d_get_NEW $fr $wi 0]
  #  set fi1 [arr2d_get_NEW $fr $wi 1]
  #
  #} else {

  set fi0 [arr2d_get_NEW "$plot FR" $wi 0]
  set fi1 [arr2d_get_NEW "$plot FR" $wi 1]
  #}

  # пока не будем печатать габариты (не понятно к каким функциям их относить)
  
  set name [dict_get $plot "FUNCS" $fi0 "L_NAME"]

  win_text  $win $name [expr {$x0 + 2}] $y0

  # имена тоже хорошо бы напечатать все..
  
  win_plot_tabl_draw_NEW  $fi0 $fi1 \
    $ti $win $plot  $x0 [expr {$y0 + 2}] [expr {$hh - 1}]
  
}
# -------------------------------------------------------------------------------
# proc  plot_win_main {plot win wi ti x y w h} {

#   # (let* (
#   # ;  // определяем размеры частей

#   set w2  [expr {21 + 10}]
#   #   ;(w1  (- w (+ w2 2)))
#   set w1  [expr {$w + (- $w2) + 2}]
#   #   )
  
#   #   ;(format t "1........... ~%")
#   #   ;; рисуем левые графики

#   plot_win_lines  $plot $win $wi $ti   $x $y [expr {$w1 - 1}] $h
  
#   #   ;(format t "2........... ~%")
#   #   ;; рисуем перегородку
#   win_vert $win "!" $w1 $y [expr {$y + $h}]
  
#   #   ;(format t "3........... ~%")
#   #   ;; рисуем правую часть (имя 1-го графика, мин, макс и таблицу 1-го графика)

#   plot_win_right  $plot $win  $wi $ti  $w1 $y $h
  
  
# }
# -------------------------------------------------------------------------------
proc  plot_win_main_NEW {plot win wi ti x y w h} {

  # определяем размеры частей

  set w2  [expr {21 + 10}]
  set w1  [expr {$w + (- $w2) + 2}]
  
  # рисуем левые графики

  plot_win_lines_NEW  $plot $win $wi $ti   $x $y [expr {$w1 - 1}] $h
  
  # рисуем перегородку

  win_vert $win "!" $w1 $y [expr {$y + $h}]
  
  # рисуем правую часть (имя 1-го графика, мин, макс и таблицу 1-го графика)

  plot_win_right_NEW  $plot $win  $wi $ti  $w1 $y $h
  
  return
}
# -------------------------------------------------------------------------------

set win ""


# -------------------------------------------------------------------------------
# proc plot_win {ti plot iw ih ih_one} {

#   global win

#   set yi  1
  
#   #   ;; создаем экранную форму и рисуем главную рамочку

#   # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#   if {! $::_PLOT_DEBUG} {
#   #
#     set win [win_create $iw $ih] 

#     #if {! [info exist win ]} {
#     #  set win [win_make $iw $ih]
#     #}
  
#     win_init  $win " "
#     win_rect  $win "=" "!" 0 0 $iw $ih ;# почeму нe рисуeт '| ??

   
#   # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#   } else {
#   # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#     #if {! [info exist win ]} {
#     #  puts "!!!!!!!!!!!!!!!!!!!!!!!!!! win !!!!!!!!!!!!!!!!!!!!!!!!!!"
#     set win [win_make $iw $ih] ;# даже без инициации дает задержку
#     #}

#     win_init $win " " ;# [EXPR {}]  !!!!!

# #     win_rect  $win "=" "!" 0 0 $iw $ih 
# #     win_rect  $win "=" "!" 0 0 $iw $ih 
# #     win_rect  $win "=" "!" 0 0 $iw $ih
# #     win_rect  $win "=" "!" 0 0 $iw $ih
# #     win_rect  $win "=" "!" 0 0 $iw $ih
# #     win_rect  $win "=" "!" 0 0 $iw $ih
# #     win_rect  $win "=" "!" 0 0 $iw $ih
# #     win_rect  $win "=" "!" 0 0 $iw $ih

# #     win_rect  $win "=" "!" 0 0 $iw $ih
# #     win_rect  $win "=" "!" 0 0 $iw $ih
# #     win_rect  $win "=" "!" 0 0 $iw $ih
# #     win_rect  $win "=" "!" 0 0 $iw $ih
    
#     win_rect  $win "=" "!" 0 0 $iw $ih  ;# задержка, если был make 
#     #win_rect  $win "=" "!" 0 0 $iw $ih ;# задержку  поллбому

#     dotimes y 30 {
#       puts "   kfjkdjbklgjbklgfjbgf gkbjgfkljbhgfl klgjhkljgfhklj"
#     }
#     return
    
#   }
#   # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~


#   if {! $::_PLOT_DEBUG} {
    
#     #   ;; здесь надо идти не по списку функций, а по фреймам!
#     #   (loop for wi from 0 until (= (aref (FR plot) wi 0) -1) do
    
#     for {set wi 0} {1} {incr wi} {
      
#       if {[arr2d_get [$plot.FR] $wi 0] == -1} {break}
      
#       #     ;(format t "wi=~s ti=~s yi=~s ~%" wi ti yi )
      
#       plot_win_main  $plot $win  $wi $ti  1 $yi [expr {$iw - 2}] $ih_one     
#       incr yi $ih_one
      
#       win_horz  $win "=" $yi 2 [expr {$iw - 3}]     
#       incr yi
#     }
#   }
  
#   #   ;(format t "45 ..... ~%")
  
#   #   ;; выводим экранную форму

#   win_draw  $win 0 ;# т.е. без управления цветом (строкой) !!!
  
# }
# -------------------------------------------------------------------------------
proc plot_win_NEW {ti plot iw ih ih_one} {

  global win

  set yi  1
  
  # создаем экранную форму и рисуем главную рамочку
  # 
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  if {! $::_PLOT_DEBUG} {
  #
    set win [win_create $iw $ih] 

    win_init  $win " "
    win_rect  $win "=" "!" 0 0 $iw $ih ;# почeму нe рисуeт '| ??

  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  } else {
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    set win [win_make $iw $ih] ;# даже без инициации дает задержку

    win_init  $win " " ;# [EXPR {}]  !!!!!

    win_rect  $win "=" "!" 0 0 $iw $ih  ;# задержка, если был make 

    dotimes y 30 {
      puts "   kfjkdjbklgjbklgfjbgf gkbjgfkljbhgfl klgjhkljgfhklj"
    }
    return
    
  }
  # ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  #if {$::FR_old} {
  #  set fr [dict_get $plot "FR"]
  #}

  if {! $::_PLOT_DEBUG} {
    
    # здесь надо идти не по списку функций, а по фреймам!
    
    for {set wi 0} {1} {incr wi} {
      
      #if {$::FR_old} {
      #  set n [arr2d_get_NEW $fr $wi 0] 
      #} else {
      set n [arr2d_get_NEW "$plot FR"  $wi 0] 
      #}

      if {$n == -1} {break}
      
      plot_win_main_NEW  $plot $win  $wi $ti  1 $yi [expr {$iw - 2}] $ih_one     

      incr yi $ih_one
      
      win_horz  $win "=" $yi 2 [expr {$iw - 3}]     
      incr yi
    }
  }
  
  # выводим экранную форму
  # 
  win_draw  $win 0 ;# т.е. без управления цветом (строкой) !!!
  
}
# -------------------------------------------------------------------------------
# proc plot_print_info {p} {

#   # (let (
#   set wnum [plot_get_wnum $p]
#   #   )
  
#   puts ""
#   puts "PLOT_PRINT_INFO: ------------------------:"
#   puts ""
  
#   puts "fnum= [$p.L_FNUM]  xnum= [$p.L_XNUM]  tnum= [$p.L_TNUM]  tmax= [$p.TMAX]" 
#   #           (L_FNUM p) (L_XNUM p) (L_TNUM p) (TMAX p))
  

#   puts "wnum= $wnum"
#   #puts "FR=  [arr2d_print [$p.FR]]"
  

#   #dotimes wi $wnum {
#   #  puts "wi= $wi"    
#   #}
  


#   puts "FUNCS = [$p.FUNCS]"
#   puts "X     = [$p.X]"
#   puts "XMIN_SET = [$p.XMIN_SET]"
#   puts "XMAX_SET = [$p.XMAX_SET]"
  
#   set steps [set [$p.STEPS_]] ;# здесь наверное это не вктуально, но ..

#   puts "STEPS = $steps"
  
#   puts ""

#   for {set ti 0} {$ti < [$p.L_TNUM]} {incr ti} {

#     set step [lindex $steps $ti]

#     puts "ti = $ti"

#     step_print_info $step
#   }

#   #puts "FR    = [$p.$FR]"    ???
#   #puts "WNUM  = [$p.$WNUM]"

#   puts ""
# }
# -------------------------------------------------------------------------------
# 
# -------------------------------------------------------------------------------
# proc plotstep_init_win {ps} {

#   # ;  //ps->plot->wnum = plot_get_wnum (ps->plot);
#   # ;  int wnum = ps->plot->wnum;
  
#   # (let (
#   #   (wnum (WNUM (PLOT ps)))
#   set wnum [[$ps.PLOT].WNUM]
#   #   )
  
#   if {$wnum == 1} {$ps.IH_ONE = 18} 
#   if {$wnum == 2} {$ps.IH_ONE = 13} 
#   if {$wnum == 3} {$ps.IH_ONE =  9}
#   if {$wnum == 4} {$ps.IH_ONE =  8}
  
#   $ps.IH = [expr  {$wnum * [$ps.IH_ONE] + $wnum + 1}] ;#; ??
#   $ps.IW = 70
  
#   $ps.FIRST1 = 1 ;# t
#   $ps.FIRST2 = 1 ;# t
  
# }
# -------------------------------------------------------------------------------
# 
# -------------------------------------------------------------------------------
proc plotstep_init_win_NEW {ps} {

  #set wnum [[$ps.PLOT].WNUM]

  set plot [dict_get $ps "PLOT"]
  set wnum [dict_get $plot WNUM]
  
  if {$wnum == 1} {set ih_one  18} 
  if {$wnum == 2} {set ih_one  13} 
  if {$wnum == 3} {set ih_one   9}
  if {$wnum == 4} {set ih_one   8}
  
  dict_set $ps "IH_ONE" $ih_one

  dict_set $ps IH  [expr  {$wnum * $ih_one + $wnum + 1}] ;#; ??
  dict_set $ps IW  70
  
  dict_set $ps FIRST1   1 ;# t
  dict_set $ps FIRST2   1 ;# t
  
}
# ;-------------------------------------------------------------------------------
# ;int
# proc plot_get_wnum {plot} {

#   # (let (
#   set wi 0
#   #   )
  
#   # ;  for (wi=0 ; plot->fr[wi][0] != -1; wi++) {
#   # ;    ;; 
#   # ;  }
  
#   while {1} {
#     #     (when (= (aref (FR plot) wi 0) -1) (return))
#     if {[arr2d_get [$plot.FR] $wi 0] == -1} {break}

#     #     ;(setf wi (1+ wi))
#     incr wi
#   }
  
#   return $wi
# }
# -------------------------------------------------------------------------------
proc plot_get_wnum_NEW {plot} {

  set wi 0 ;# ???
    
  while {1} {

    set n [arr2d_get_NEW "$plot FR"  $wi 0] ;# по сложной ссылке

    if {$n == -1} {break}

    incr wi
  }
  
  return $wi
}
# -------------------------------------------------------------------------------
proc plot_min_max_wnum_NEW {plot} {

  set fnum [dict_get $plot "L_FNUM"]

  # посчитаем "габариты" всех функций на всём временном интервале
  # 
  dotimes fi $fnum {

    plot_min_max_NEW  $fi $plot
  }
  
  # разберемся с фреймами (окнами)
  # 

  dict_set $plot "WNUM"  [plot_get_wnum_NEW $plot]
 
  return
}
# -------------------------------------------------------------------------------
# proc plotstep_create {plot} {

#   # (let (
#   set ps [make-instance "T_PLOTSTEP"]
#   #   )
  
#   $ps.PLOT = $plot

#   return $ps
# }
# -------------------------------------------------------------------------------
proc plotstep_create_NEW {plot} {

  set ps [dict_create] ;# [make-instance "T_PLOTSTEP"]
  
  #$ps.PLOT = $plot
  dict set $ps "PLOT" $plot

  return $ps
}
# ;-------------------------------------------------------------------------------
# proc plot_step_beg {plot} {

#   # (let (
#   set ps  [plotstep_create $plot]
#   #   )
  
#   #   ;(format t "..... 1 ~%")

#   plot_min_max_wnum $plot

#   #   ;(format t "..... 2 ~%")

#   plotstep_init_win  $ps

#   #   ;(format t "..... 3 ~%")
  
#   return $ps
# }
# ;-------------------------------------------------------------------------------
proc plot_step_beg_NEW {plot} {

  set ps  [plotstep_create_NEW $plot]
  
  plot_min_max_wnum_NEW $plot

  plotstep_init_win_NEW  $ps

  return $ps
}
# -------------------------------------------------------------------------------
# proc plot_step_do {ps ti} {

#   # (let (
#   # ;  int   i;
#   #   (title (PP_STEP_NAME (PLOT ps) ti))
#   set title [PP_STEP_NAME_get [$ps.PLOT] $ti]
#   #   )
  
#   # ;  if (!(ps->first1)) CUU;
  
#   # ;    if (ps->first2) ps->first2 = FALSE;
#   # ;    else for (i=0; i < ps->ih; i++) CUU;
  
#   # ;  printf ("%s \n", title);
#   # ;  (format t "~A ~%" (PP_STEP_NAME (PLOT ps) 0))

#   #   (format t "~A ~%" title)
#   puts ""
#   puts "$title"
  
#   #   ;(format t "3 ..... ~%")

#   plot_win  $ti [$ps.PLOT] [$ps.IW] [$ps.IH] [$ps.IH_ONE]

#   #dotimes y 30 {
#   #  puts "   kfjkdjbklgjbklgfjbgf gkbjgfkljbhgfl klgjhkljgfhklj"
#   #}



#   #   ;(format t "8 ..... ~%")
  
#   # ;  if (ps->first1) {
#   # ;    printf ("\n"); CUU; 
#   # ;    ps->first1 = FALSE;
#   # ;  }
  

#   #   (format t "Command: ")
#   puts  -nonewline "Command: "

#   flush stdout
  
# }
# -------------------------------------------------------------------------------
proc plot_step_do_NEW {ps ti} {

  set plot [dict_get $ps "PLOT"]

  #set title [PP_STEP_NAME_get_NEW $plot $ti]
  set title  [dict_get $plot "T_$ti" "TITLE"]
  
  #puts stderr "-------------------------------"
  puts ""
  puts "$title"
  
  set iw [dict_get $ps IW]
  set ih [dict_get $ps IH]

  plot_win_NEW  $ti $plot $iw $ih  [dict_get $ps IH_ONE]


  puts  -nonewline "Command: "

  flush stdout
  
}
# -------------------------------------------------------------------------------
# proc plot_print_one {plot ti} {

#   # (let (
#   # ;  T_PLOTSTEP *ps;
#   set ps [plot_step_beg  $plot]
#   #   )
  
#   #   ;(format t "2 ..... ~%")
#   plot_step_do  $ps $ti
  
#   #   ;(plot_step_end  ps)

# }
# ;-------------------------------------------------------------------------------
proc plot_print_one_NEW {plot ti} {

  set ps [plot_step_beg_NEW  $plot]
  
  plot_step_do_NEW  $ps $ti
  
  return $ps
}
# ;-------------------------------------------------------------------------------
# ;
# ;-------------------------------------------------------------------------------
# proc plot_print {plot} {

#   # (let (
#   #   ti
#   set ti_incr  +1
#   #   ps
#   #   ch ; char buff[80];
#   #   )
  
#   set ps [plot_step_beg $plot]
  
#   #   ;(setf ti (TMAX plot)) ; начинаeм с послeднeго..  а можeт лучшe с пeрвого?
#   set ti 0
  
#   while {1} {

#     plot_step_do $ps $ti
    
#     # ;     (loop
#     # ;      fgets (buff, 50, stdin); CUU;
    
#     #        (setf ch (read-char))
#     #set ch [gets stdin line] 
#     set ch [gets stdin]
#     #puts "ch = $ch"
    
#     # ;       (setf ch (read))
#     incr ti $ti_incr
    
#     # ;      if      (buff[0] == '\n') ti += ti_incr;
#     # ;      else if (buff[0] ==  'g') ti = atoi(&(buff[1]));
#     # ;      else if (buff[0] ==  '[') ti = 0;
#     # ;      else if (buff[0] ==  ']') ti = plot->tmax;
#     # ;      else if (buff[0] ==  'q') goto end;
#     # ;      else continue;
    
#     #        ;(when (equal ch 'q) (return)) ; ??
    
#     #        (when (eql ch 'Q) (return)) 
#     if {$ch == "q"} {break}
    
#     #        ;(when (char= ch 'Q) (return))  ; *** - CHAR=: argument Q is not a character
    
#     if {$ti > [$plot.TMAX]} {set ti 0}
    
#     # ;      break;
#     # ;       )
    
#   }
  
# }
# ;-------------------------------------------------------------------------------
proc plot_print_NEW {plot} {

  set ti_incr  +1
  
  set ps [plot_step_beg_NEW $plot]
  
  set ti 0
  
  while {1} {

    plot_step_do_NEW $ps $ti
    
    set ch [gets stdin]

    incr ti $ti_incr
    
    if {$ch == "q"} {break}
    
    if {$ti > [dict_get $plot "TMAX"]} {set ti 0}
  }
  
}
# ;-------------------------------------------------------------------------------
# ;
# ;23.5. Accessing Directories

# ;The following function is a very simple portable primitive for examining a 
# ;directory. Most file systems can support much more powerful directory-searching 
# ;primitives, but no two are alike. It is expected that most implementations of 
# ;Common Lisp will extend the directory function or provide more powerful 
# ;primitives. 

# ;-------------------------------------------------------------------------------
# (defun delete_files_in_dir (pathname)

# (let (

# ;A list of pathnames is returned, one for each file in the file system that 
# ;matches the given pathname. (The pathname argument may be a pathname, a string, 
# ;or a stream associated with a file.) For a file that matches, the truename 
# ;appears in the result list. 

#   (dir_list (directory pathname))
#   )

#   (dotimes (i (list-length dir_list))

# ;The specified file is deleted. The file may be a string, a pathname, or a stream
#     (delete-file (nth i dir_list))
#     )

# ))
# ;-------------------------------------------------------------------------------
# (defun print_files_in_dir (pathname)

# (let (
#   (dir_list (directory pathname))
#   )

#   (dotimes (i (list-length dir_list))
#     (format t "file= ~s ~%" (nth i dir_list))
#     )

# ))
# -------------------------------------------------------------------------------
proc write_line_to_file {plot ti fi  work_dir name} {

  set ofile [open "$work_dir/${name}_files/${name}_$ti"  "w"]
  
  dotimes j [$plot.L_XNUM] {

    set f__ [get_step_ylist  $plot $ti $fi]

    puts -nonewline $ofile [format "%s " [lindex $f__ $j]]
  }

  close $ofile

}
# -------------------------------------------------------------------------------
proc write_line_to_file_NEW {plot ti fi  work_dir name} {


  set ofile [open "$work_dir/${name}_files/${name}_$ti"  "w"]

  set xnum [dict_get $plot "L_XNUM"] ;# [$plot.L_XNUM]
  
  dotimes j $xnum {

    set f__ [get_step_ylist_NEW  $plot $ti $fi]

    puts -nonewline $ofile [format "%s " [lindex $f__ $j]]
  }
  
  close $ofile

}
# ;-------------------------------------------------------------------------------
proc delete_plot_files_dirs_in_D_dir {work_dir} {

  #set work_dir "D_tmp"

  # ;(format *error-output* "11 ... ~%")
  
  # ;(Y-system "pwd")  ; 
  # ;(format *error-output* "12 ... ~%")
  
  #Y-system "rm -f $work_dir/*_files/*"  ;# сначала очистили всe диры от файлов
  #Y-system "rm -f D_tmp/*_files/*"  ;# сначала очистили всe диры от файлов
  
  # ;(format *error-output* "13 ... ~%")
  
  #Y-system "rmdir --ignore-fail-on-non-empty $work_dir/*_files"
  #Y-system "rmdir D_tmp/*_files"
   
  #file delete -force "$work_dir/*_files"
  #file delete -force "$work_dir/Cosin_files" ;# надо точно задавать. но как?

  #---------------------------------------------------------------
  # в команде file отсутствует непосредственная поддержка шаблонов
  # надо  

  #file delete -force [glob -nocomplain $work_dir/*_files]

  #puts "GLOB: [glob -nocomplain $work_dir/*_files]"

  foreach f [glob -nocomplain $work_dir/*_files] {

    file delete -force $f
  }
  #---------------------------------------------------------------
  
  #   ;; а затeм удаляeм пустыe диры
  
  # ;(format *error-output* "14 ... ~%")

}
# ;-------------------------------------------------------------------------------
# ; вызываeтся такжe из s_funo.cl -> minfunc_print_prepare
# ;-------------------------------------------------------------------------------
# proc plot_save {plot work_dir} {

#   # (let (
#   #   name
#   #set work_dir "D"
#   #set work_dir "D_tmp"
#   #   )
  
#   # ;(format *error-output* "10 ... ~%")
  
#   #   ;; здeсь надо бы очистить дирeктории от старых диров и их файлов
#   delete_plot_files_dirs_in_D_dir $work_dir
  
#   # ;(format *error-output* "19 ... ~%")
  
#   #   ;; ---------------- идeм циклом по всeм функциям
  
#   dotimes fi [$plot.L_FNUM] {

#     set name [PP_NAME_get $plot $fi]
#     #puts "PP_NAME= $name"    
    
#     #     (Y-system (format nil "mkdir ~a/~a_files" work_dir name))  ; сoздали диру для функции
#     file mkdir "$work_dir/${name}_files"

#     dotimes ti [$plot.L_TNUM] { ;# записали туда файлы по точкам врeмeни
#       write_line_to_file  $plot $ti $fi  $work_dir $name 
#     }
#   }

#   #   ;; ---------------------------------------------
  
#   #   (Y-system (format nil "mkdir ~a/t_files" work_dir) )  ; сoздали пустую t-диру 
#   file mkdir "$work_dir/t_files"
  
#   #   ;; записываeм особыe файлы-врeмeна
  
#   dotimes ti [$plot.L_TNUM] {   
  
#     #     (with-open-file (ofile (format nil "~a/t_files/t_~D" work_dir ti) 
#     #                            :direction :output 
#     #                            :if-exists :supersede
#     #                            ) 

#     set ofile [open "$work_dir/t_files/t_$ti"  "w"]
    
#     puts $ofile [format "%d" $ti]
    
#   }
  
# }
# ;-------------------------------------------------------------------------------
# (defun dir_test (argus) (declare (ignore argus))


# ;  (delete_files_in_dir "P/t_files/t_*")
# ;  (delete_files_in_dir "P/u_files/u_*")

# ;  (print_files_in_dir "D/*")  ; CLISP даeт тольeо файлы бeз дирeкторий !
# ;  (format t "~%")
# ;  (print_files_in_dir "D/t_files/*")
# ;  (format t "~%")

# ;  (Y-system "ls -all") 

#   (delete_plot_files_dirs_in_D_dir)

# )
# ;===============================================================================
# ;
# ;===============================================================================
# ;
# ;-------------------------------------------------------------------------------
# ; будeм здeсь потихоньку создавать новыe функции
# ;
# ;-------------------------------------------------------------------------------
# proc plot_make_step {plot ti} {

#   # (let (
#   set step_name "PLOT_TEST"  ;# "TITLE-STEP"
#   #   )
  
#   #   (setf (PP_STEP_NAME plot ti)  step_name)
#   PP_STEP_NAME_set $plot $ti $step_name
  
#   dotimes fi [$plot.L_FNUM] {

#     plot_make_step_fi  $plot $ti $fi
#   }
  
# }
# ;-------------------------------------------------------------------------------
# proc plot_make_step_NEW {plot ti} {

#   set step_name "PLOT_TEST" ;# "TITLE-STEP"
  
#   #PP_STEP_NAME_set_NEW  $plot $ti $step_name

#   dict_set  $plot "STEPS_" $ti "TITLE" $step_name
  
#   #set fnum [dict_get $plot "L_FNUM"]

#   #dotimes fi $fnum {

#   #  plot_make_step_fi_NEW  $plot $ti $fi
#   #}
  
# }
# -------------------------------------------------------------------------------
# помeняли порядок пeрeмeнных
# -------------------------------------------------------------------------------
# proc plot1_create {fnum tnum  xnum} {

#   set plot [plot_create  $fnum $xnum $tnum]
  
#   #   ;; 0-й слой будeм всeгда создавать
#   # 
#   plot_make_step  $plot 0
  
#   return $plot
# }
# -------------------------------------------------------------------------------
proc plot1_create_NEW {fnum tnum  xnum} {

  set plot [plot_create_NEW  $fnum $xnum $tnum]
  
  #puts ""
  #puts "plot = [set $plot]"
  #puts "plot = [dict_expand $plot]"
  #puts ""
  #exit

  #   ;; 0-й слой будeм всeгда создавать
  # 
  #plot_make_step_NEW  $plot 0
  
  dict_set  $plot "T_0" "TITLE" "PLOT_TEST"

  # значения потом запишем 
  #
  #exit

  return $plot
}
# -------------------------------------------------------------------------------
# proc p1_test1_prepare {} {

#   set fnum  2
#   set xnum 10
  
#   set plot [plot1_create  $fnum 1  $xnum]
  
#   dotimes xi [$plot.L_XNUM] {

#     P1_X_set $plot $xi   $xi  ;# ; plot->x[i] = i; ???
#   }
  
#   dotimes fi [$plot.L_FNUM] {
#   dotimes xi [$plot.L_XNUM] {

#     PVAL_set $plot 0 $fi $xi  [expr {($fi + 1) * $xi}] ;# f_line[i]  = (fi+1)*i;
#   }}
  
#   return $plot
# }
# -------------------------------------------------------------------------------
proc p1_test1_prepare_NEW {{is_x_int 1}} {

  set fnum  2
  set xnum 10
  
  set plot [plot1_create_NEW  $fnum 1  $xnum]
  

  dotimes fi [dict_get $plot "L_FNUM"] {
  dotimes xi [dict_get $plot "L_XNUM"] {

    if {$is_x_int} {
      set x $xi        ;# икс как целый индекс, это просто
    } else {
      set x [* 1.0 $xi] ;# а вот это сложнее, но нужно ?7 !!
    }


    set y [expr {($fi + 1) * $xi}]

    dict_set $plot "T_0"  "F_$fi" $x $y 
  }}
  
  return $plot
}
# -------------------------------------------------------------------------------
# proc p1_test1 {} {

#   set plot [p1_test1_prepare]
  
#   plot_print_info $plot

#   plot_print_one $plot 0
  
#   puts ""
# }
# -------------------------------------------------------------------------------
proc plot_print_info_NEW {p} {

  #puts ""

  dict_print $p

  puts ""
    
}
# -------------------------------------------------------------------------------
proc p1_test1_NEW {} {

  set plot [p1_test1_prepare_NEW]
  
  if {0} {
    puts ""
    puts "p1_test1_NEW:  plot = "
    puts ""
    puts "[set $plot]"
    puts ""
  }

  plot_print_info_NEW $plot

  set ps [plot_print_one_NEW $plot 0]
  
  puts ""

  dict_print $ps

  puts ""
}
# -------------------------------------------------------------------------------
proc p1_test1_NEWEST {} {

  set plot [p1_test1_prepare_NEW 0]
  

  plot_print_info_NEW       $plot
 
  set ps [plot_print_one_NEW $plot 0]
  

  puts ""
  dict_print $ps
  puts ""

}
# ;===============================================================================
# ;-------------------------------------------------------------------------------
# (defun p2_test_prepare ()

# (let* (
#   (fnum  1)
#   (xnum 10)
#   (ynum 10)

#   (plot (plot_create_new  fnum 1  (list xnum ynum)))
#   )

# ;  (dotimes (xi (L_XNUM plot))
# ;    (setf (P1_X      xi)             xi)  ; plot->x[i] = i; ???
# ;    )

# ;  (dotimes (fi (L_FNUM plot))
# ;  (dotimes (xi (L_XNUM plot))
# ;    (setf (PVAL 0 fi xi) (* (+ fi 1) xi)) ; f_line[i]  = (fi+1)*i;
# ;    ))
	
#   plot
# ))
# ;-------------------------------------------------------------------------------
# (defun p2_test (argus)  (declare (ignore argus))

# (let (
#   (plot (p2_test_prepare))
#   )

#   ;(plot2_print_one plot 0)

# ))
# ;===============================================================================
# ;
# ;
# ;-------------------------------------------------------------------------------
proc plot_set_xvals {plot xnum fi_min fi_max_} {

  # (let* (
  #   fi_step
  #   )
  
  set fi_step [expr {($fi_max_ - $fi_min) / ($xnum - 1)}]
  
  #   ;; формируем значения "x

  dotimes i $xnum {
    #     (setf (nth i (X plot)) (+ fi_min (* fi_step i)))
    P1_X_set  $plot $i  [expr {$fi_min + ($fi_step * $i)}]
  }
  
}
# ;-------------------------------------------------------------------------------
proc plot_set_xvals_NEW {plot xnum fi_min fi_max_} {

  
  set fi_step [expr {($fi_max_ - $fi_min) / ($xnum - 1)}]
  
  #  формируем значения "x

  dotimes i $xnum {

    set x [expr {$fi_min + ($fi_step * $i)}]

    P1_X_set_NEW  $plot $i $x
  }
  
}
# ;-------------------------------------------------------------------------------
# ;YT_PLOT*
#proc make_test3 (tnum xnum 
#                         fi_min 
#                         fi_max_ ; fi_max ????? почeму-то даeт ошибку 
#                         ;;        MAKE-LIST: 6.28 is not a 32-bit number
#                         )
# ;-------------------------------------------------------------------------------
# proc make_test3 {tnum xnum fi_min fi_max_ } {

#   set fnum  2
  
#   set plot  [plot_create  $fnum $xnum $tnum]
  
#   #   ; ??
#   plot_set_xvals  $plot $xnum $fi_min $fi_max_
  
#   #   (setf (PP_NAME plot 0)    "Sinus")
#   #   (setf (PP_NAME plot 1)    "Cosin")
  
#   PP_NAME_set $plot 0 "Sinus"
#   PP_NAME_set $plot 1 "Cosin"

#   #   ;; надо бы сначала всe создать ..

#   dotimes  ti $tnum {
#     plot_make_step  $plot $ti
#   }
  
#   dotimes ti $tnum {
  
#     # формируем значения "f"
#     # 
#     dotimes  xi $xnum {
#       #       ;(format t "ti=~s  xi=~s ~%" ti xi)

#       #       (setf (PVAL ti 0 xi)    (sin (* (+ ti 1) (P1_X xi)))) ; fi=0
#       #       (setf (PVAL ti 1 xi)    (cos             (P1_X xi)))

#       set x [P1_X_get $plot $xi]

#       set y1 [expr {sin (($ti + 1) * $x)}]
#       set y2 [expr {cos ($x)}]

#       PVAL_set $plot $ti 0 $xi  $y1 
#       PVAL_set $plot $ti 1 $xi  $y2  
#     }
    
#     #     ;; общий титл ..
#     #     (setf (PP_STEP_NAME plot ti) (format nil "ti = ~D" ti))
    
#     PP_STEP_NAME_set $plot $ti [format "ti = %s " $ti]
#   }
  
#   return $plot
# }
# ;-------------------------------------------------------------------------------
proc make_test3_NEW {tnum xnum fi_min fi_max_ } {

  set fnum  2
  
  set plot  [plot_create_NEW  $fnum $xnum $tnum]
  
  #plot_set_xvals_NEW  $plot $xnum $fi_min $fi_max_
  #
  # лучше не отдельно иксы, а сращу с игреками?

  set fi_step [expr {($fi_max_ - $fi_min) / ($xnum - 1)}]
  
  #dotimes i $xnum {

  #  set x [expr {$fi_min + ($fi_step * $i)}]
  #  P1_X_set_NEW  $plot $i $x
  #}


  PP_NAME_set_NEW  $plot 0 "Sinus"
  PP_NAME_set_NEW  $plot 1 "Cosin"

  # надо бы сначала всe создать ..
  #dotimes  ti $tnum {
  #  plot_make_step  $plot $ti
  #}  
  #exit

  dotimes ti $tnum {
  
    # формируем значения "f"
    # 
    # TODO: почему разные значения для разных компов?
    # в чем дело? точность expr ?? может уменьшить точностьзначения ::G_PI ??

    dotimes  xi $xnum {

      set x [expr {$fi_min + ($fi_step * $xi)}]

      set y1 [expr {sin (($ti + 1) * $x)}]
      set y2 [expr {cos ($x)}]

      dict_set $plot "T_$ti" "F_0" $xi $y1 
      dict_set $plot "T_$ti" "F_1" $xi $y2 
    }
    
    # общий титл ..
    #
    dict_set  $plot "T_$ti" "TITLE" [format "ti = %s " $ti]
  }
  
  return $plot
}
# ;-------------------------------------------------------------------------------
# # ;YT_PLOT *
# proc plot_test3_prepare {} {

#   # (let (
#   set plot [make_test3  10 100  0 [expr {2 * $::G_PI}]]
#   #   )
  
#   #   ;; начальная инициация (обнуление) списка фреймов:
#   plot_frames_init0 $plot
  
#   #   ;; в 1-м фрейме:
#   #   (setf (aref (FR plot) 0 0)  0)  ; "Sinus"
#   #   (setf (aref (FR plot) 0 1)  1)  ; "Cosin"
  
#   PLOT_FR_set $plot 0 0  0 ;# "Sinus"
#   PLOT_FR_set $plot 0 1  1 ;# "Cosin"

#   #   ;; во 2-м фрейме:
#   #   (setf (aref (FR plot) 1 0)  0)  ; "Sinus" 

#   PLOT_FR_set $plot 1 0  0 ;# "Sinus"
  
#   return $plot
# }
# ;-------------------------------------------------------------------------------
proc plot_test3_prepare_NEW {} {


  set tnum  10
  set xnum 100

  set plot [make_test3_NEW  $tnum $xnum  0  6.28]  ;# [expr {2 * $::G_PI}]]
  #
  # слишком высокая точность Пи может давать погрешность привычислениях!!!
  
  dict_print $plot
  puts ""

  #exit

  #  начальная инициация (обнуление) списка фреймов:
  #
  plot_frames_init0_NEW $plot
  
  # в 1-м фрейме:
  
  PLOT_FR_set_NEW  $plot 0 0  0 ;# "Sinus"
  PLOT_FR_set_NEW  $plot 0 1  1 ;# "Cosin"

  # во 2-м фрейме:

  PLOT_FR_set_NEW $plot 1 0  0 ;# "Sinus"
  
  return $plot
}
# -------------------------------------------------------------------------------
# proc plot_test3 {} {

#   set plot [plot_test3_prepare]

#   plot_print_one $plot 0

# }
# -------------------------------------------------------------------------------
proc plot_test3_NEW {} {

  set plot [plot_test3_prepare_NEW]
  
  puts ""

  plot_print_one_NEW $plot 0

  puts ""
}
# -------------------------------------------------------------------------------
# proc plot_test3_dyn {} {

#   set plot [plot_test3_prepare]

#   plot_print $plot
  
# }
# -------------------------------------------------------------------------------
proc plot_test3_dyn_NEW {} {

  set plot [plot_test3_prepare_NEW]
  

  plot_print_NEW $plot
  
}
# -------------------------------------------------------------------------------
# ;-------------------------------------------------------------------------------
# ; нeт на выходe пeчати - в тeстe нeпонятно, отработал или нeт.. !!
# ;-------------------------------------------------------------------------------
# proc plot_test3_save {} {

#   set plot [plot_test3_prepare]
  
#   set work_dir "PLT"

#   puts ""   

#   plot_save $plot $work_dir

#   puts ""   
#   puts "plot_test3_save .. OK "    
#   puts ""
  
# }
# ;-------------------------------------------------------------------------------
proc plot_save_NEW_to_DIRS {plot work_dir} {

  
  #  здeсь надо бы очистить дирeктории от старых диров и их файлов
  # 
  delete_plot_files_dirs_in_D_dir $work_dir
  
  set fnum [dict_get $plot "L_FNUM"] ;# [$plot.L_FNUM]
  set tnum [dict_get $plot "L_TNUM"] ;# [$plot.L_TNUM]
  
  # идeм циклом по всeм функциям
  
  dotimes fi $fnum {

    #set name [PP_NAME_get_NEW  $plot $fi]
    set name [dict_get $plot  "FUNCS" $fi  "L_NAME"] 
    
    file mkdir "$work_dir/${name}_files"

    dotimes ti $tnum { ;# записали туда файлы по точкам врeмeни

      write_line_to_file_NEW  $plot $ti $fi  $work_dir $name 
    }
  }

  # ---------------------------------------------
  
  file mkdir "$work_dir/t_files"
  
  # записываeм особыe файлы-врeмeна
  
  dotimes ti $tnum {   
  
    set ofile [open "$work_dir/t_files/t_$ti"  "w"]
    
    puts $ofile [format "%d" $ti]

    close $ofile
  }
  
  return
}
# ===============================================================================
# 
# TADMOR ??????
# 
# -------------------------------------------------------------------------------
# -------------------------------------------------------------------------------
#  burger.h
#  burger.c 
# -------------------------------------------------------------------------------

set ::TNUM_MAX 1000 ;# define TNUM_MAX 1000
set ::FNUM_MAX   10 ;# define FNUM_MAX 10

# -------------------------------------------------------------------------------
proc calc_tnum {dir_name} {


  set dir_list [lsort [glob $dir_name/*]]

  return [llength $dir_list]

}
# -------------------------------------------------------------------------------
proc get_value_name {dir_name} {


  set index [string first "_" $dir_name]
  
  return [string range $dir_name 0 [- $index 1]]
}
# -------------------------------------------------------------------------------
proc set_full_file_name {dir_name num} {

  
  # выделим из названия директории само имя переменной

  set value_name [get_value_name  $dir_name]
  
  return ${value_name}_$num
}
# -------------------------------------------------------------------------------
proc calc_xnum {dir_name} {

  set xnum 0

  set file_name  [set_full_file_name  $dir_name 0]

  set file_name  ${dir_name}/$file_name

  if [catch {open $file_name} fid] {
    
    puts ""
    puts "Cannot open $file_name"
    puts ""
    exit 
    
  } else {

    gets $fid line

    close $fid
  }

  set line [string  trim $line]

  return [llength [split $line " "]]

}
# -------------------------------------------------------------------------------
proc read_values_u {dir_name xnum n_value} {


  set file_name  [set_full_file_name  $dir_name $n_value]
  set file_name  ${dir_name}/$file_name
  
  if [catch {open $file_name} fid] {
    
    puts ""
    puts "Cannot open $file_name"
    puts ""
    exit

  } else {

    gets $fid line
    close $fid
  }
  
  set line [string  trim $line]

  set ptr [split $line " "] ;# список

  return $ptr   
}
# ;-------------------------------------------------------------------------------
proc read_values_t {dir_name tnum} {

  set n  0 

  set ptr {} ;# (make-list tnum))
  
  set dir_list [lsort [glob $dir_name/*]]
  
  foreach f $dir_list {
  
    if [catch {open $f} fid] {
      
      puts ""
      puts "Cannot open $f"
      puts ""
      exit

    } else {     
      gets $fid line
     
      lappend ptr $line

      close $fid
    }

  }
  
  return $ptr
}
# -------------------------------------------------------------------------------
proc check_dir_files {main_dir} {

  
  set fnum 0 
  set flst {}

  set dir_list [lsort [glob -type d *]]

  foreach  dir_name $dir_list {
  
    if [string equal $dir_name "t_files"] {continue}
    
    lappend flst $dir_name
      
    incr fnum   
  } 

  return $flst 
}
# ;-------------------------------------------------------------------------------
proc  tadmor_get_arrays {tad  work_dir} {

  cd $work_dir
  
  set f_list [check_dir_files  "."]

  set fnum   [llength  $f_list]
  
  set tnum [calc_tnum "t_files"]

  set xnum [calc_xnum [lindex $f_list 0]]
  
  dict_set $tad "VAR_T"  [read_values_t  "t_files" $tnum]



  dotimes  fi $fnum {

    set  names [dict_get $tad "NAMES"]
    lset names $fi [lindex $f_list $fi]

    dict_set $tad "NAMES" $names

    puts ""
 
    dotimes  ti $tnum {

      set dir_name [lindex $f_list $fi]

      set  var_u [dict_get $tad "VAR_U"]

      set v [read_values_u  $dir_name $xnum $ti]
      
      #puts "tadmor_get_arrays:  var_u = $var_u  fi = $fi  ti = $ti  v = $v"

      lset var_u $fi $ti  $v        ;# error !!,??

      # Error in startup script: list index out of range
      # 
      # несколько индексов!! вложенные списки??

      dict_set $tad "VAR_U" $var_u  ;# и перезаписали взад
      
      #exit
   }
  }
  
  cd ".." 
 
  dict_set $tad "XNUM" $xnum 
  dict_set $tad "TNUM" $tnum  
  dict_set $tad "FNUM" $fnum 
  
}
# ;-------------------------------------------------------------------------------
proc tadmor_print {tad} {

  puts ""
  puts "TAD= [set $tad]"
  puts ""
  
  set fnum  [dict_get $tad  FNUM]
  set tnum  [dict_get $tad  TNUM]
  set var_u [dict_get $tad VAR_U]
  set names [dict_get $tad NAMES]

  puts "fnum  = $fnum" 
  puts "tnum  = $tnum" 
  puts "xnum  = [dict_get $tad  XNUM]" 
  
  puts "names = $names"
  puts "t     = [dict_get $tad VAR_T]"
  #puts "u     = $var_u" 
  puts ""
  

  for {set fi 0} {$fi < $fnum} {incr fi} {

    puts "-------------------------------------------------------------------"
    puts [format "fi = %2d (%s)" $fi [lindex $names $fi]]
    puts ""
    
    for {set ti 0} {$ti < $tnum} {incr ti} {

      puts [format "ti = %2d (%s)" $ti [lindex $var_u $fi $ti]]
      puts ""

      #puts -nonewline [format "x = "]      
      #for {set xi 0} {$xi < 2} {incr xi} {
      #puts -nonewline "[lindex $var_u $ti $xi]"
      #}
    }

    puts ""
  }

  #puts ""
}
# -------------------------------------------------------------------------------
# proc tadmor_make_plot {p_tad} {

#   set tad [set $p_tad]

#   set xnum  [dict get $tad "XNUM"] ;#  int xnum = tad->xnum; 
#   set fnum  [dict get $tad "FNUM"] ;#  int fnum = tad->fnum;
#   set tnum  [dict get $tad "TNUM"] ;#  int tnum = tad->tnum;
  
#   #   ;; // от куда брать эти парамeтры?

#   #   (x_min  0)          ;  double x_min  = 0; 
#   #   (x_max  (* 2 G_PI)) ;  double x_max  = 2*G_PI;
#   #   (x_step (/ (- x_max x_min) (- xnum 1))) ;  double x_step = (x_max - x_min) / (xnum - 1);
  
#   set plot  [plot_create  $fnum $xnum $tnum] ;#  YT_PLOT *plot;
  
  
#   #   ;; формируем "x"
#   # 
#   #   (dotimes (i xnum)
#     #     ;;    plot->x[i] = x_min + x_step * i;
#     #     (setf (nth i (X plot)) (+ x_min (* x_step i)))
#   # )

#   plot_set_xvals  $plot $xnum 0 [* 2 $::G_PI]


#   dotimes  fi $fnum {
#   dotimes  ti $tnum {

#     #     ;; теперь сами графики:
#     #     ;; P_LINE (plot, fi, ti) = (tad->u[fi][ti]);
#     #     ;; P_NAME (plot, fi) = tad->names[fi];
    
#     #     (setf (PP_STEP_F plot ti fi) (aref (VAR_U tad) fi ti))
#     #     (setf (PP_NAME   plot    fi) (nth fi (NAMES tad)))
    
#     lset [PP_STEP_F  $plot $ti]  $fi [lindex [dict get $tad "VAR_U"] $fi $ti]

#     PP_NAME_set $plot $fi [lindex [dict get $tad "NAMES"] $fi] 

#     #     ;; общий титл ..
#     #     ;; sprintf (P_TITLE (plot,ti), "ti = %d", ti);
#     #     (setf (PP_STEP_NAME plot ti) (format nil "ti = ~d" ti))
    
#     PP_STEP_NAME_set $plot $ti "ti = $ti"
#   }}
  
#   return $plot  
# }
# -------------------------------------------------------------------------------
proc tadmor_make_plot_NEW {p_tad} {

  set tad [set $p_tad]

  set xnum  [dict get $tad "XNUM"] ;#  int xnum = tad->xnum; 
  set fnum  [dict get $tad "FNUM"] ;#  int fnum = tad->fnum;
  set tnum  [dict get $tad "TNUM"] ;#  int tnum = tad->tnum;
  
  set plot  [plot_create_NEW  $fnum $xnum $tnum] ;#  YT_PLOT *plot;
   
  # формируем "x"
  # 
  #plot_set_xvals_NEW  $plot $xnum 0 [* 2 $::G_PI]

  set fi_min 0
  set fi_max [* 2 $::G_PI]

  set fi_step [expr {($fi_max - $fi_min) / ($xnum - 1)}]
  
  #  формируем значения "x
  #
  #dotimes i $xnum {

  #  set x [expr {$fi_min + ($fi_step * $i)}]
  #  #P1_X_set_NEW  $plot $i $x
  #}

  #puts ""
  #puts "tadmor_make_plot_NEW: tad = $tad"
  #puts ""


  #exit
  #return $plot  ;# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

  dotimes  fi $fnum {
  dotimes  ti $tnum {

    # теперь сами графики:
    
    # lset [PP_STEP_F  $plot $ti]  $fi [lindex [dict get $tad "VAR_U"] $fi $ti]
    # PP_NAME_set $plot $fi [lindex [dict get $tad "NAMES"] $fi] 

    set  var_u [dict get $tad "VAR_U"] ;# список значений ?

    dotimes xi $xnum {
      
      set x [expr {$fi_min + ($fi_step * $xi)}]
      
      dict_set $plot "T_$ti" "F_$fi"  $xi [lindex $var_u $fi $ti $xi] 
    }


    # общий титл ..
    # 
    #PP_STEP_NAME_set_NEW $plot $ti "ti = $ti"

    dict_set  $plot "T_$ti" "TITLE" [format "ti = %s " $ti]

  }}
  
  return $plot  
}
# ;-------------------------------------------------------------------------------
# ;void
# ;plot_add_plot (YT_PLOT *plot, YT_PLOT *plot2)
# ;{ 

# ;  plot->fnum = plot->fnum + 1;

# ;  int ti;
# ;  for (ti=0 ; ti < plot->tnum ; ti++) {

# ;    P_LINE (plot, /*fi*/1, ti) = P_LINE (plot2, /*fi*/0, ti);
# ;    P_NAME (plot, /*fi*/1)     = P_NAME (plot2, /*fi*/0);

# ;  }

# ;  // в 1-м фрейме:
# ;  //plot->fr[0][0] = 0/*fi*/;
# ;  plot->fr[0][1] = 1/*fi*/; 

# ;  return;  
# ;}
# ;-------------------------------------------------------------------------------
proc make_tadmor_class {} {


  set tad [dict_create]
  
  dict_set $tad "NAMES" [list_make  $::FNUM_MAX] 
  dict_set $tad "VAR_U" [list_make [list $::FNUM_MAX $::TNUM_MAX]] ;#make-array

  return $tad
}
# -------------------------------------------------------------------------------
# proc read_plot_from_files {work_dir} { 


#   set tad [make_tadmor_class]
  
#   tadmor_get_arrays  $tad $work_dir ;# "./PLT" ;# "." ;# $main_dir

#   if {0} {

#     puts ""
#     puts "tad = [set $tad]"
#     puts ""
    
#     #tadmor_print  $tad
#   }
  
#   set plot [tadmor_make_plot $tad]
  
#   #puts ""
#   #plot_print_info $plot

#   #puts ""
#   #plot_print_one $plot 0

#   # ;plotbig_print (plot, 0,0,0,0);

#   #puts "plot = $plot"
#   #puts "plot = [set $plot]"

#   return $plot
# }
# -------------------------------------------------------------------------------
proc read_plot_from_files_NEW {work_dir} { 


  set tad [make_tadmor_class]
  
  tadmor_get_arrays  $tad $work_dir ;# "./PLT" ;# "." ;# $main_dir

  if {0} {

    puts ""
    puts "tad = [set $tad]"
    puts ""
    
    exit
    
    #tadmor_print  $tad
    #exit
   }
 
  set plot [tadmor_make_plot_NEW $tad]

  
  return $plot
}
# ===============================================================================
# -------------------------------------------------------------------------------
proc plot_save_NEW {plot filename} {

  # как одиночный файл   

  dict_save  $plot "PLOT" $filename  

}
# -------------------------------------------------------------------------------
proc plot_test3_save_NEW {} {

  set work_dir "PLT"
  set filename "plotsave"

  if {1} {

    set plot [plot_test3_prepare_NEW]
    
    puts ""   
    
    dict_save_simple       $plot "PLOT" $work_dir $filename ;# как одиночный файл    
 
    plot_save_NEW_to_DIRS  $plot        $work_dir      ;# как набор папок/файлвов 
    
    puts ""   
    puts "plot_test3_save_NEW .. OK "    
    puts ""
        
    # как записался одиночный файл ?
    #
    source "$work_dir/plotsave"
    
    dict_print $PLOT ;# там не указатель, а значение? а нет, теперь уже указатель!!
    
    # а можно и указатель сделать:
    #
    #set p [dict_read_from_saved_file "PLOT" $work_dir $filename]
    
    #dict_print $p ;# а здесь через указатель
    
    
    puts ""
    puts "-----------------------------------------------------------------"
    #puts ""
  }

  # как записался набор папок/файлвов ?
  # 

  set p [read_plot_from_files_NEW  $work_dir]

  dict_print $p

  return
}
# -------------------------------------------------------------------------------
# -------------------------------------------------------------------------------
# 
#  b~.tl PLUT plot_test3_save_NEW

#  b~.tl PLUT p1_test1_NEW

#  b~.tl PLUT plot_test3
#  b~.tl PLUT plot_test3_dyn
# 
# ===============================================================================
