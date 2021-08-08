# -*-   mode: tcl  ; coding: koi8   -*- ----------------------------------------

# ;#define PROC_VAR  int message, double *xyz, double *fun, long long1, long long2, void *ptr, double *ret
# ;#define T_PROC_RETURN int
# ;#define RETURN {fun++; long1++; long2++; return (1);}

# ;-------------------------------------------------------------------------------
# ;/*  Сложная синусоида                                                         */
# ;-------------------------------------------------------------------------------
# ;T_PROC_RETURN
# ;mp_data_02 (PROC_VAR)
# ;-------------------------------------------------------------------------------
proc mp_data_02 {message xyz fun long1 long2 ptr ret} {


  set minproc $ptr
  
  switch -glob $message  {
      
  "YINIT" {  
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    set [DIM] 1 
  
    # ;    //	minproc_set (minproc, -10, +10,  0.1); вправо уходит вниз!!!
  
    minproc_set  $minproc -10.0 +7.0  0.1  ;#0.2 
    set [NAME]    "sin(x)*x^2"

    #    ;; (setf (NUM_BEG) 1) ; одно начальное приближение
    #    ;; //XYZ_BEG[0][0] = -6.0;
  
    set ::calc_xi "proc_sinusoida" ;#; !!!!!!!!!!
  
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  }      
  "YTRUE" {
   #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    set [NUM_TRU] 1
  
    #    (setf (aref (XYZ_TRU) 0 0)  -8.1)
    #    (setf (nth 0 (FUN_TRU))   -63.63)
  
    arr2d_set [XYZ_TRU] 0 0 -8.1
    lset [FUN_TRU] 0  -63.63

  
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  }    
  "YCALC" {    
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  
    #   ;(format t ".......YCALC ~%") ; мы сюда попадаeм (eсли нe пчeлами ищeм!)
    #   (funcall *calc_xi* (coerce xyz 'list))

    return [$::calc_xi $xyz]

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  }
  }
  
  # ;  RETURN;
}
# ;===============================================================================

# ;#define x1 (((double *) this_entity->chromosome[0])[0])
# ;#define x2 (((double *) this_entity->chromosome[0])[1])
# ;#define x3 (((double *) this_entity->chromosome[0])[2])

# ;===============================================================================

# ;//* Функция Растригина. Число переменных 2. Максимумов - 96 локальных, 4 глобальных.

# ;//          #define PI 3.14159265358979323846
# ;//          y=20+x[0]*x[0]+x[1]*x[1]-10*cos(2*PI*x[0])-10*cos(2*PI*x[1]);

# ;//          Пространство: -5.12<=x[t]<=5.12
# ;//          Максимум: F(4.52299,4.52299)  =80.7065
# ;//                    F(-4.52299,4.52299) =80.7065
# ;//                    F(4.52299,-4.52299) =80.7065
# ;//                    F(-4.52299,-4.52299)=80.7065

# ;//* Функция Растригина. Число переменных 10. Максимумов - (10^10)-1 локальных и 1 глобальный.

# ;//          #define PI 3.14159265358979323846
# ;//          y = -100;
# ;//          for(t=0; t<XNum; t++) 
# ;//            y += 10* cos (2*PI*x[t]) - x[t]*x[t];

# ;//          Пространство: -5.12<=x[t]<=5.12
# ;//          Максимум: F(0,..,0)=0

# ;-------------------------------------------------------------------------------

# ;// ф-ия (из отчета),  FMIN (1, 2, 3) = 1.0
# ;/*   case 4:  */
# ;/*     gaul->dim  =     3; */
# ;/*     gaul->xmin = -10.0; */
# ;/*     gaul->xmax = +10.0; */
# ;/*     A = x1-1; */
# ;/*     B = x2-2; */
# ;/*     C = x3-3; */
# ;/*     fitness = - (2*(A*A+B*B+C*C) + sin(A*B*C)*sin(A*B*C) + 1); */
# ;/*     break; */

# ;-------------------------------------------------------------------------------
# proc setf_aref_XYZ_BEG {i j val} { 

#   upvar minproc minproc ; 

#   #set arrname [$minproc vget -P_XYZ_BEG]
#   #set arrname [XYZ_BEG]

#   #proc XYZ_BEG   {} { upvar minproc m ; return [$m.S_INIT].XYZ }

#   set arrname [$minproc vget -S_INIT]

#   #puts "arrname = $arrname"

#   set points_name [set $arrname]
#   #puts "points_name = $points_name"
#   #puts "            = [$points_name vget -XYZ]"

#   # XYZ  [set [$points_name vget -XYZ]]
#   #set xyz  [$points_name vget -XYZ]
#   set xyz  [set [$points_name vget -XYZ]]

#   arr2d_set $xyz $i $j  $val 

#   #puts "            = [set [$points_name vget -XYZ]]"
  
#   #arr2d_print [set [$points_name vget -XYZ]]

#   #set arrname [$minproc vget -S_INIT]

#   #exit
#   #set $arrname($i,$j) $val 

#   #arr2d_set $arrname $i $j  $val 
# }
# ;-------------------------------------------------------------------------------
# ;/*  Простейшая парабола                                                       */

# ;-------------------------------------------------------------------------------
# ;T_PROC_RETURN
# ;mp_data_01 (PROC_VAR)
# ;-------------------------------------------------------------------------------
proc mp_data_01 {message xyz fun long1 long2 ptr ret} {

  # (let (
  set minproc $ptr
  #   )
  
  #puts "mp_data_01 .... message= $message  xyz= $xyz"
  
  switch -glob $message  {
      
  "YINIT" {  
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    #puts "YINIT ....."
    
    set [DIM] 1 ;# DIM  = 4;
    
    minproc_set  $minproc -2.0 2.0  0.1
    set [NAME]    "x1^2+x2^2+.."
    
    #  ;; как быть тут?  чья это забота?
    #setf_NUM_BEG 1 ;# одно начальное приближение
    set [NUM_BEG] 1 ;# одно начальное приближение
    
    #puts "DIM_val = $[DIM]" -  забыл, как сделать короткий вариант !!

    dotimes i [set [DIM]] {
      #puts "i = $i"
      #
      #      (setf (aref (XYZ_BEG) 0 i) 1.0)

      #setf_aref_XYZ_BEG  0 $i  1.0 ;# надо подумать про массивы произвольной 
                                    # размерности 

      arr2d_set [XYZ_BEG] 0 $i 1.0  

      # (tcllib/modules/struct/matrix ??) - двумерный массив
      # хотя в данном конкретном случае можно сделать маcсивы простые ARR($i,$j)
      #
    }

    set ::calc_xi "proc_hsphere" ;#; !!!!!!!!!!
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  }      
  "YTRUE" {
   #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
     
    #puts "YTRUE ....."
      
    set [NUM_TRU] 1
    
    dotimes  d [set [DIM]] {
      #      (setf (aref (XYZ_TRU) 0 d)  0)
      arr2d_set [XYZ_TRU]  0 $d   0
    }

    #    ;; а гдe значeниe функции ? (нужно для get_stopfun)
    #    (setf (nth 0 (FUN_TRU)) 0.0) 
    lset [FUN_TRU] 0  0.0
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  }    
  "YCALC" {    
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
      
    #puts "YCALC  ....."    
    #   (funcall *calc_xi* (coerce xyz 'list))

    return [$::calc_xi $xyz]

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  }
  

  }
    
  # ;  RETURN;
}
# ;-------------------------------------------------------------------------------
# ;/*  Функция Розенброка N-го порядка                                           */
# ;/*  В 2-d случае это функция "Банана"                                         */
# ;-------------------------------------------------------------------------------
# ;T_PROC_RETURN
# ;mp_data_03 (PROC_VAR)
# ;{
# ;  YT_MINPROC *minproc = (YT_MINPROC *)ptr;

# ;  int    i, d;
# ;  double /* s, */ sum/* , koef_100 */;

# ;  switch (message) {

# ;  case YINIT:
# ;    DIM  = 2; // порядок функции
# ;    //minproc_set (minproc, 10.0, +10.0,  0.1); 
# ;    //minproc_set (minproc, -1.28, +1.28,  0.1); 
# ;    minproc_set (minproc, -1.28, +1.28,  0.1); 
# ;    NAME = "Rozenbrok";

# ;    NUM_BEG = 1; // одно начальное приближение
# ;                 // а вот нач. приближение тут совсем не к месту !!
# ;    // ну или выделить в опциональную функцию, т.е. для тестирования, например
# ;    for (i=0; i < DIM; i++)
# ;      XYZ_BEG[0][i] = 0.7;

# ;    break;

# ;  case YCALC:

# ;    // ф-ия Розенброка (из отчета),  FMIN (1.0, 1.0) = 1.0
# ;    //gaul->population_size = 500;
# ;    //gaul->dim  =     2;
# ;    //gaul->xmin = -10.0;
# ;    //gaul->xmax = +10.0;
# ;    //fitness = - (100 * (x2-x1*x1)*(x2-x1*x1) + (1-x1)*(1-x1) + 1);

# ;    // тестовая функция j1 
# ;    sum = 100 / (100*(X1*X1-X2)*(X1*X1-X2) + (1-X1)*(1-X1) + 1); 
# ;    sum = - sum;

# ;    if (ret) {
# ;      *ret = sum;
# ;    }
# ;    return (0);

# ;  case YTRUE:
# ;    P_NUM(M_TRUE) = 1;
# ;    for (d=0; d < DIM; d++) {
# ;      P_XYZ(M_TRUE)[0][d] = 1;
# ;    }
# ;    P_FUN(M_TRUE)[0]    = -100.0;

# ;    break;
# ;  }

# ;  RETURN;
# ;}
# ;-------------------------------------------------------------------------------
# ;  Функция Пауэла                                                           
# ;  пока не получается находить по градиетну - только по абс. минимуму (0.0) !!
# ; 
# ;-------------------------------------------------------------------------------
proc proc_powell {xi} {

  
  #   (s1  (+ (XN 1) (* 10 (XN 2))))
  #   (s2  (- (XN 3) (XN 4))     )
  #   (s3  (- (XN 2) (* 2 (XN 3))) )
  #   (s4  (- (XN 1) (XN 4))     )
  
  set x1 [lindex $xi 0] 
  set x2 [lindex $xi 1] 
  set x3 [lindex $xi 2] 
  set x4 [lindex $xi 3] 

  set s1  [expr {$x1 + (10 * $x2)}]
  set s2  [expr {$x3 - $x4}]    
  set s3  [expr {$x2 - (2 * $x3)}]
  set s4  [expr {$x1 - $x4}]

  #   (+ (* s1 s1) (* 5 s2 s2) (* s3 s3 s3 s3) (* 10 s4 s4 s4 s4))

  return [expr {($s1 * $s1) + (5 * $s2 * $s2) + ($s3 * $s3 * $s3 * $s3) + \
                  + (10 * $s4 * $s4 * $s4 * $s4)}]
}
# ;-------------------------------------------------------------------------------
# ;-------------------------------------------------------------------------------
proc mp_data_04 {message xyz fun long1 long2 ptr ret} {


  set minproc $ptr

  switch -glob $message  {
      
  "YINIT" {  
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    set [DIM] 4
    
    minproc_set  $minproc  -2.0 2.0 1.0

    set [NAME] "Powell"

    set ::calc_xi "proc_powell" ;# !!!!!!!!!!
    
    #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  }    
  "YCALC" {    
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    # ;  (format t "mp_data_04........YCALC ~%") ; мы сюда попадаeм, eсли eщeм нe пчeлами!
    # ;  (funcall *calc_xi* (coerce xyz 'list))

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  }      
  "YTRUE" {
   #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    set [NUM_TRU] 1
    lset [FUN_TRU] 0  0
     
    dotimes d [set [DIM]] {
      #      (setf (aref (XYZ_TRU) 0 d)  0)
      arr2d_set [XYZ_TRU] 0 $d  0
    }

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  }
  }

  # ;  RETURN;
}
# ;-------------------------------------------------------------------------------
# ;/*  Пример из библиотеки GSL (p. 346)                                         */
# ;-------------------------------------------------------------------------------
proc proc_gslfunc {xi} {

  # (let* (
  #   (xyz (coerce xi 'array))
  
  #   (x  (XN 1))
  #   (y  (XN 2))
  set x [lindex $xi 0] 
  set y [lindex $xi 1] 
  
  set x0 1
  set y0 2 

  #   ;;  Position of the minimum (1, 2)
  
  # ;    sum = 10.0 * (x - x0) * (x - x0) +
  # ;          20.0 * (y - y0) * (y - y0) + 30.0;
  
  #   (sum  (+ (* 10.0 (- x x0) (- x x0)) 
  #            (* 20.0 (- y y0) (- y y0)) 
  #            30.0))
  #   )
  
  set sum [expr {10.0 * ($x - $x0) * ($x - $x0) + \
                 20.0 * ($y - $y0) * ($y - $y0) + 30.0}]

  # ;    if (ret) *ret = sum;
  # ;    return (/* sum */ 0);
  
  return $sum
}
# ;-------------------------------------------------------------------------------
# ;T_PROC_RETURN
# ;mp_data_05 (PROC_VAR)
# ;-------------------------------------------------------------------------------
proc mp_data_05 {message xyz fun long1 long2 ptr ret} {


  set minproc $ptr
  
  # ;  double x0= 1, y0= 2, x, y;
  # ;  /* Position of the minimum (1, 2). */
  

  switch -glob $message  {
      
  "YINIT" {  
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    set [DIM] 2 

    # ;    minproc_set (minproc, -10.0, 10.0,  0.1);
    # ;    NAME = "SGL-func";
    
    minproc_set  $minproc -10.0 10.0  0.1
    set [NAME]    "SGL-func"
    
    # ;    // ---------------------------------------
    # ;    // как быть тут?  чья это забота?
    # ;    NUM_BEG = 1; // одно начальное приближение
    
    set [NUM_BEG] 1 ;# одно начальное приближение
    
    # ;    XYZ_BEG[0][0] = 5.0;
    # ;    XYZ_BEG[0][1] = 7.0;
    
    #    (setf (aref (XYZ_BEG) 0 0) 5.0)
    #    (setf (aref (XYZ_BEG) 0 1) 7.0)
    
    arr2d_set [XYZ_BEG] 0 0  5.0
    arr2d_set [XYZ_BEG] 0 1  7.0
    
    set ::calc_xi "proc_gslfunc" ;#; !!!!!!!!!!
    
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  }      
  "YTRUE" {
   #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  
    # ;  case YTRUE:
    # ;    P_NUM(M_TRUE) = 1;
    # ;    P_XYZ(M_TRUE)[0][0] = 1.0;
    # ;    P_XYZ(M_TRUE)[0][1] = 2.0;
    # ;    P_FUN(M_TRUE)[0] = 30.0;
    # ;    break;
    #    ;(format *error-output* "mp_data_05 - YTRUE ~%")
    
    set [NUM_TRU] 1
    
    #    (setf (aref (XYZ_TRU) 0 0)  1.0)
    #    (setf (aref (XYZ_TRU) 0 1)  2.0)
    
    arr2d_set [XYZ_TRU] 0 0  1.0
    arr2d_set [XYZ_TRU] 0 1  2.0
    
    #    (setf (nth 0 (FUN_TRU))    30.0) ; это значeниe бeрeтся в stop_func !!
    lset [FUN_TRU] 0  30.0
    
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  }    
  "YCALC" {    
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    # ;  case YCALC:
    # ;    x = XN(1);
    # ;    y = XN(2);
    # ;    sum = 10.0 * (x - x0) * (x - x0) +
    # ;          20.0 * (y - y0) * (y - y0) + 30.0;
    # ;    if (ret) *ret = sum;
    # ;    return (/* sum */ 0);
    
    return [$::calc_xi $xyz]

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  }
  }
  
}
# ;-------------------------------------------------------------------------------
# ;//* Griewank. Число переменных 2. Максимумов - множество локальных и 1 глобальный.

# ;//  y=1/(((x[0]*x[0]+x[1]*x[1])/200)-cos(x[0])*cos(x[1]/sqrt(2))+2);

# ;//  Пространство: -20<=x[t]<=20
# ;//  Максимум: F(0,0)=1
# ;-------------------------------------------------------------------------------
# ;T_PROC_RETURN
# ;mp_data_j5 (PROC_VAR)
# ;{
# ;  YT_MINPROC *minproc = (YT_MINPROC *)ptr;
# ;  double sum;

# ;  switch (message) {
# ;  case YINIT:
# ;    DIM = 2;
# ;    //minproc_set (minproc, -20.0, +20.0,  0.1 /*XYZ_ERR*/);
# ;    minproc_set (minproc, -5.0, +5.0,  0.1);
# ;    NAME = "Griewank2";

# ;    break;
# ;  case YCALC:
# ;    sum = - (1 / (((X1*X1 +X2*X2)/200) - cos(X1)*cos(X2/sqrt(2))+2));

# ;    if (ret) *ret = sum;
# ;    return (0);

# ;  case YTRUE:
# ;    P_NUM(M_TRUE) = 1;
 
# ;    P_XYZ(M_TRUE)[0][0] = 0.0;
# ;    P_XYZ(M_TRUE)[0][1] = 0.0;
# ;    P_FUN(M_TRUE)[0]    = -1.0;

# ;    break;
# ;  default:
# ;    ;;;;;;;;;;;;;;;;;;;;;
# ;  }

# ;  RETURN;
# ;}
# ;-------------------------------------------------------------------------------
# ;// Растригина ; размерность 10 ; один глобальный экстремум и 10^10-1 локальных
# ;-------------------------------------------------------------------------------
# ;T_PROC_RETURN
# ;mp_data_j6 (PROC_VAR)
# ;{
# ;  YT_MINPROC *minproc = (YT_MINPROC *)ptr;
# ;  double sum/* , mul */;

# ;  switch (message) {
# ;  case YINIT:
# ;    DIM = 10;
# ;    minproc_set (minproc, -5.12, +5.12, 0.1 /*XYZ_ERR*/);
# ;    NAME = "Rastrigin";

# ;    break;
# ;  case YCALC:
# ;    sum = 0;
# ;    int   i;
# ;    for (i=0; i<DIM; i++) {
# ;      sum += (10* cos (2*PI*XN(i)) - XN(i)*XN(i));
# ;    }

# ;    if (ret) {
# ;      *ret = - (sum - 100);
# ;    }
# ;    return (0);

# ;  case YTRUE:
# ;    P_NUM(M_TRUE) = 1;
# ;    for (i=0; i<DIM; i++) {
# ;      P_XYZ(M_TRUE)[0][i] = 0.0;
# ;    }
# ;    P_FUN(M_TRUE)[0] = 0.0;

# ;    break;
# ;  default:
# ;    ;;;;;;;;;;;;;;;;;;;;;
# ;  }

# ;  RETURN;
# ;}
# ;-------------------------------------------------------------------------------
# ; Griewank ; размерность 10 ; один глобальный и множество локальных максимумов
# ;-------------------------------------------------------------------------------
proc proc_griewank10 {xi} {

  # (let* (
  #   (xyz (coerce xi 'array))
  set xyz $xi ;# для макроса XN
  
  set sum  0
  set mul  1
  set dim [llength $xi]
  #   )
  
  #   (loop for i from 1 to dim do
  for {set i 1} {$i < $dim} {incr i} {

    incf sum [expr {[XN $i] * [XN $i] }]
    set mul [expr {$mul * (cos ( [XN $i] / sqrt($i) ))}]
  }
  
  #   (- (- 10 (- (/ sum 4000) mul -1.0)))
  return [expr {- (10 - (($sum / 4000) - $mul - -1.0))}]
}
# ;-------------------------------------------------------------------------------
# ;-------------------------------------------------------------------------------
proc mp_data_j7 {message xyz fun long1 long2 ptr ret} {

  set minproc $ptr
  
  
  switch -glob $message  {
      
  "YINIT" {  
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    #set [DIM] 10 -- слишком долго тля тестов
    set [DIM] 4
  
    #    ;(minproc_set  minproc  -512.0 +512.0  0.1)
    minproc_set  $minproc  -0.1 +0.1  0.1
  
    set [NAME] "Griewank10"

    set ::calc_xi "proc_griewank10" ;# !!!!!!!!!!
  
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  }      
  "YTRUE" {
   #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

    #    (setf (NUM_TRU) 1)
    set [NUM_TRU] 1

    #    (setf (nth 0 (FUN_TRU)) -10.0)
    lset [FUN_TRU] 0  -10.0
    
     dotimes d [set [DIM]] {
       #set (aref (XYZ_TRU) 0 d)  0.0)
       arr2d_set [XYZ_TRU] 0 $d  0.0
     }

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  }    
  "YCALC" {    
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  
    # Почему-то пропущено! А как же оно работает в Лисп?
    # (может нули по умолчанию?)
    #
    # ААА! Ну так для пчел мы сюда не попадаем?
    
    #return [$::calc_xi $xyz]

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  }
  }
  
  # ;  RETURN;
}
# ;===============================================================================
# ;//
# ;===============================================================================
# ;//
# ;-------------------------------------------------------------------------------
proc minproc_print_name {minproc} {

  # ;  printf ("%-13s  D=%d ", NAME, (int)DIM); 

  puts -nonewline [format "%13s  D=%d " [set [NAME]] [set [DIM]] ]

}
# ;-------------------------------------------------------------------------------
proc minproc_check_print {minproc} {

  set dim [set [DIM]]
  

  set eps [lindex [set [XYZ_ERR]] 0]

  set is_compare \
    [fpoints_compare $dim [$minproc.S_CALC] [$minproc.S_TRUE]  $eps]

  
  if {$is_compare} {
    puts " .... O-KEY!"
  } else {
    puts " .... ERROR!"

    fpoints_print [$minproc.S_TRUE] "true: " $dim
    fpoints_print [$minproc.S_CALC] "calc: " $dim
  }

 # puts ""
  
#   if  {! $is_compare} {

#   }

}
# ;-------------------------------------------------------------------------------
# ;void
# ;bot_calc_data (YT_MINBOT *bot, YT_MINPROC *minproc)  
# ;-------------------------------------------------------------------------------
proc bot_calc_data {bot minproc} {  

  minproc_begin  $minproc 0 0  ;# // вообще то это тут лишнее, но пока

  # ;  // почему то создаются дубликат решения  ..NUM_END..
  
  $bot.LONG3 = $minproc  ;# // ????

  [$bot.BOT_DATA]  $bot $minproc
  
  [$bot.BOT_TODO]  $bot ;# !!!!!!  напускаем бота на данные
  

  # ;  //minproc_true (minproc);
  
  puts -nonewline [format "%s --> " [$bot.P_NAME]]

  minproc_print_name $minproc ;# // печатаем имя данных
  
  puts -nonewline [format " --> "]

  minproc_check_print $minproc

}
# ;-------------------------------------------------------------------------------
# ;double
# ;get_stopfun (YT_MINPROC *minproc)  
# ;-------------------------------------------------------------------------------
proc get_stopfun {minproc} {  

  # (let (
  #   ;  double sf;
  #   ;sf =  P_FUN(M_TRUE)[0];

  #set sf (nth 0 (FUN_TRU)))

  set sf [lindex [set [FUN_TRU]] 0]
  #   )
  
  return $sf
}
# ;-------------------------------------------------------------------------------
proc  simp_test {} { 

  #set ::simp_random 1   ;# для точного сравнения с LISP
  comm_random_seed 20


  puts ""

  # (let* (
  set m_dat01  [minproc_create_begin "mp_data_01"]
  set m_dat02  [minproc_create_begin "mp_data_02"]
  set m_dat05  [minproc_create_begin "mp_data_05"]
  

  set m_botperebor  [minbot_make "PereborS"  "botperebor_init"  \
                            "botperebor_data" "botperebor_todo" \
                             $::POWER_DEF 0 0  0]
  
  set m_botbees     [minbot_make "BeesFind"  "botbees_init"     \
                                 "botbees_data" "botbees_todo"  \
                                  0 0 0 0]
  
  set m_botgslspusk [minbot_make "GSLspusk"        \
                            "botgslspusk_1_init"   \
                            "botspusk_fun_data"    \
                            "botgslspusk_1_todo"   \
                            10 "0"  0 0]
  
  # ; здeсь eщe нe вызван жe "minproc_begin"? и соотвeтствeнно YTRUE, а значит нeт
  # ; значeния (nth 0 (FUN_TRU));   так вeдь вызван "minproc_create_begin" !!
  # ; нe к той функции обращался !!

  set stopfun       [get_stopfun  $m_dat05] ;# double 

  #puts stderr "stopfun = $stopfun" ;# возьме истиное решенеи ?

  set m_botfunspusk [minbot_make  "GSLspuskFUN"   \
                            "botspusk_fun_init"   \
                            "botspusk_fun_data"   \
                            "botspusk_fun_todo"   \
                       1000 0 0 $stopfun]
 

  #   ;(format *error-output* "stopfunc= ~s  ~%" stopfun)
  
  bot_calc_data  $m_botperebor $m_dat01
  bot_calc_data  $m_botperebor $m_dat02 

  #bot_calc_data  $m_botperebor $m_dat05  ;#  СЛИШКОМ долго !!! TODO: оптимизация
  
  puts ""
  
  bot_calc_data  $m_botbees  $m_dat01
  bot_calc_data  $m_botbees  $m_dat02
  
  #   ;(bot_calc_data  m_botbees m_dat05)
  # ;BeesFind --> SGL-func       D=2  -->  .... ERROR!
  # ;     true: f= 30.0  x= #(1.0 2.0) #(1.0 2.0) 
  # ;     calc: f= 31.058596  x= #(1.2684754f0 1.8700376f0) #(1.2684754f0 1.8700376f0) 
  
  #   (format t "~%")
  puts ""
  
  bot_calc_data  $m_botgslspusk $m_dat01
  bot_calc_data  $m_botgslspusk $m_dat02

  bot_calc_data  $m_botgslspusk $m_dat05 ;# -- !! пока ошибка !!
  
  #   (format t "~%")
  puts ""  

  #set ::_DEBUG 1

  bot_calc_data  $m_botfunspusk $m_dat05

  puts ""
  
}
# ;-------------------------------------------------------------------------------
proc  simp_tester {} { 

  comm_random_seed 20

  puts ""

  set m_dat01  [minproc_create_begin "mp_data_01"]
  
  set m_botgslspusk [minbot_make "GSLspusk"        \
                            "botgslspusk_1_init"   \
                            "botspusk_fun_data"    \
                            "botgslspusk_1_todo"   \
                            2 "0"  0 0]
  
  puts ""
  
  bot_calc_data  $m_botgslspusk $m_dat01

  puts ""
  
}
# ;===============================================================================
# ;-------------------------------------------------------------------------------
proc  more_test {} { 

  # (let* (
  #   (n   (parse-integer (nth 0 argus)))
  
  global argc argv
  set ind 2
  set n   [lindex $argv $ind] ; incr ind

  puts ""
  #puts "n = $n"
  #puts ""

  #   (arr '(
  #     mp_data_01  ;// m_test 0 ..
  #     mp_data_02  ;// 1
  #     mp_data_05  ;// 2
  #     mp_data_03  ;// Функция Розенброка : m_test 3 @ : не всегда дает результат
  #     mp_data_04  ;// 4
  #     mp_data_j5  ;// 5
  #     mp_data_j6  ;// 6
  #     mp_data_j7  ;// 7
  #          ))
  
  #   m_dat
  #   m_botbees 
  
  #   stopfun ; double  !!
  #   m_botfunspusk 
  #   )
  
  # ;  if (ch == '@')  m_bot = gaulbot_make (300, 200);
  # ;  if (ch == '$')  m_bot = gaulbot_de_make (300, 200);
  # ;  if (ch == '=') { }

  # ;    debug = TRUE;
  # ;    int size = /* 300 */ 30;
  # ;    int gens = /* 200 */ /* 200 */4;
  # ;    m_bot = gaulbot_make (size , gens);
  # ;  {}
  
  if {$n < 0} { 
  
    set m_botbees [minbot_make "BEEspusk" "botbees_init"  \
                   "botbees_data" "botbees_todo_new"      \
                   0 0 0 0]

    bot_calc_data  $m_botbees [minproc_create_begin "mp_data_04"]
    bot_calc_data  $m_botbees [minproc_create_begin "mp_data_j7"]
    
  } else {
    
    # эта часть даже в лиспе не особо работает. за исключением первых тестов,
    # но они уже охвачены в "simp_test" !!


    #     (setf m_dat    (minproc_create_begin (nth n arr)))
    #     (setf stopfun  (get_stopfun  m_dat)) 
    #     (setf m_botfunspusk (minbot_make "GSLspuskFUN" 
    #                                      'botspusk_fun_init
    #                                      'botspusk_fun_data
    #                                      'botspusk_fun_todo  
    #                                      1000 0 0 stopfun))
    #     (bot_calc_data  m_botfunspusk m_dat)
  }
  
  puts ""
  
}
# ;===============================================================================
# ;int 
# ;main (int argc, char** argv) 
# ;{
# ;  char *name = argv[1];
# ;  int   num;
# ;  char   ch;

# ;  printf ("\n");

# ;  if      (!strcmp (name, "simp"))  simp_test ();

# ;  else {
# ;    num = atoi (name);
# ;    ch = (argv[2])[0];
   
# ;    more_test (num, ch); 
# ;  }

# ;  printf ("\n");
# ;  return (0);
# ;}
# ;-------------------------------------------------------------------------------
proc  speed_test {} { 

  set ::simp_random 1   ;# для точного сравнения с LISP

  puts ""

  set m_dat05  [minproc_create_begin "mp_data_05"]
  

  set m_botperebor  [minbot_make "PereborS"  "botperebor_init"  \
                            "botperebor_data" "botperebor_todo" \
                             $::POWER_DEF 0 0  0]
  

  bot_calc_data  $m_botperebor $m_dat05  ;#  СЛИШКОМ долго !!! TODO: оптимизация
  
  puts ""
  
}
# ;===============================================================================
