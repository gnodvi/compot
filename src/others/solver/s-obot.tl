# -*-   mode: tcl  ; coding: koi8   -*- ----------------------------------------

# ;;;=============================================================================

# ;(load "c-mbee.cl")  

# ;===============================================================================
# ; 

set ::BOT_DEBUG  0


# ;;;=============================================================================

# (defvar *calc_xi* :un)
set ::calc_xi ":un"

# ;enum keywords_1 {
# ;  YINIT, YFREE, YCALC, YTRUE,  

# ;  YGINT, YRINT, YQINT, 

# ;  Y_BEG, YTODO, 
# ;  Y_PEREBOR, YGSLSPUSK, 
# ;  Y_GENALGO, 
# ;};

# set ::YINIT  0
# set ::YTRUE  1
# set ::YCALC  2
# set ::YFREE  3

# set ::YREAD  4
# set ::YWRITE 5

set ::POWER_DEF  0
set ::POWER_NOT -1

# ;===============================================================================

set ::MAX_DIM 1000 ;# максимальное число переменных !!!!!
set ::MAXB 250     ;# максимальное число нач. приближений, а также кон. ответов

# ;#define FN(n) (fun[(n)-1])
# ;#define XN(n) (xyz[(n)-1])

# (defmacro XN (n)  `(aref xyz (- ,n 1)) )
proc XN        {n} { upvar xyz xyz ; return [lindex $xyz [expr {$n - 1}]]  }


# ;#define X1 (XN(1))
# ;#define X2 (XN(2))

# ;// набор таблично заданных функций

# (defclass YT_FPOINTS () (
# ;  int     num;
# ;  double  xyz[MAXB][MAX_DIM];
# ;  double  fun[MAXB];

#   (num :accessor NUM)
#   (xyz :accessor XYZ)
#   (fun :accessor FUN)
# ))

record define YT_FPOINTS {
  
  NUM
  XYZ
  FUN
}


# (defclass YT_MINPROC () (
# ;  YT_PROC  proc;
#   (proc    :accessor P_PROC)

# ;  char    *name;
# ;  int      dim;
# ;  double  *xyz_min; 
# ;  double  *xyz_max;

#   (name    :accessor P_NAME)
#   (dim     :accessor P_DIM)
#   (xyz_min :accessor P_XYZ_MIN)
#   (xyz_max :accessor P_XYZ_MAX)

# ;  double   xyz_err[MAX_DIM]; // ?? - тоже сделать динамически
#   (xyz_err :accessor P_XYZ_ERR)

# ;  YT_FPOINTS *s_init; // начальное приближение для поиска 
# ;  YT_FPOINTS *s_calc; // найденное (последнее?) решение 
# ;  YT_FPOINTS *s_true; // это уже касается конкретного задания-проверки

#   (s_init  :accessor S_INIT)  
#   (s_calc  :accessor S_CALC)  
#   (s_true  :accessor S_TRUE)  
# ))



record define YT_MINPROC {

  P_PROC
  
  P_NAME
  P_DIM
  P_XYZ_MIN
  P_XYZ_MAX
  
  P_XYZ_ERR
  
  S_INIT
  S_CALC
  S_TRUE
}

# ;-------------------------------------------------------------------------------

# ;#define MM minproc

# ;#define P_DIM(p)  ((p)->dim)
# ;#define DIM       (P_DIM(minproc))
# ;#define PROC      (MM->proc)
# ;#define NAME      (MM->name)

# (defmacro DIM  () `(P_DIM minproc))
# (defmacro NAME () `(P_NAME minproc))

proc DIM        {} { upvar minproc m ; return [$m vget -P_DIM]  }
proc NAME       {} { upvar minproc m ; return [$m vget -P_NAME] }


# ;#define P_XYZ_MIN(p) (((p)->xyz_min))
# ;#define P_XYZ_MAX(p) (((p)->xyz_max))
# ;#define P_XYZ_ERR(p) (((p)->xyz_err))

# (defmacro XYZ_MIN () `(P_XYZ_MIN minproc))
# (defmacro XYZ_MAX () `(P_XYZ_MAX minproc))
# (defmacro XYZ_ERR () `(P_XYZ_ERR minproc))

proc XYZ_MIN    {} { upvar minproc m ; return [$m vget -P_XYZ_MIN] }
proc XYZ_MAX    {} { upvar minproc m ; return [$m vget -P_XYZ_MAX] }
proc XYZ_ERR    {} { upvar minproc m ; return [$m vget -P_XYZ_ERR] }


# ;#define XYZ_MIN (P_XYZ_MIN(minproc))
# ;#define XYZ_MAX (P_XYZ_MAX(minproc))
# ;#define XYZ_ERR (P_XYZ_ERR(minproc))

# ;#define X_MIN   (XYZ_MIN[0])
# ;#define X_MAX   (XYZ_MAX[0])
# ;#define X_ERR   (XYZ_ERR[0])
# ;#define Y_MIN   (XYZ_MIN[1])
# ;#define Y_MAX   (XYZ_MAX[1])
# ;#define Y_ERR   (XYZ_ERR[1])
# ;#define Z_MIN   (XYZ_MIN[2])
# ;#define Z_MAX   (XYZ_MAX[2])
# ;#define Z_ERR   (XYZ_ERR[2])

# ;//---------------------------------------
# ;#define P_NUM(p) ((p)->num)
# ;#define P_XYZ(p) ((p)->xyz)
# ;#define P_FUN(p) ((p)->fun)

# ;(defmacro P_NUM (p) (list 'NUM p))
# ;(defmacro NUM_BEG () (list 'S_INIT (list 'P_NUM 'minproc) ))

# (defmacro NUM_BEG () `(NUM (S_INIT minproc)) )
# (defmacro NUM_END () `(NUM (S_CALC minproc)) )

proc NUM_BEG         {} { upvar minproc m ; return [[$m.S_INIT] vget -NUM] }
proc NUM_END         {} { upvar minproc m ; return [[$m.S_CALC] vget -NUM] }


# (defmacro XYZ_BEG () `(XYZ (S_INIT minproc)) )
# (defmacro XYZ_END () `(XYZ (S_CALC minproc)) )
# (defmacro XYZ_TRU () `(XYZ (S_TRUE minproc)) )

proc XYZ_BEG   {} { upvar minproc m ; return [[$m.S_INIT].XYZ] }
proc XYZ_END   {} { upvar minproc m ; return [[$m.S_CALC].XYZ] }
proc XYZ_TRU   {} { upvar minproc m ; return [[$m.S_TRUE].XYZ] }


# (defmacro FUN_BEG () `(FUN (S_INIT minproc)) )
# (defmacro FUN_END () `(FUN (S_CALC minproc)) )
# (defmacro FUN_TRU () `(FUN (S_TRUE minproc)) )

proc FUN_BEG  {} { upvar minproc m ; return [[$m.S_INIT] vget -FUN] }
proc FUN_END  {} { upvar minproc m ; return [[$m.S_CALC] vget -FUN] }
proc FUN_TRU  {} { upvar minproc m ; return [[$m.S_TRUE] vget -FUN] }

# ;#define NUM_BEG  (P_NUM(MM->s_init))
# ;#define XYZ_BEG  (P_XYZ(MM->s_init))
# ;#define FUN_BEG  (P_FUN(MM->s_init))

# ;#define NUM_END (P_NUM(MM->s_calc))
# ;#define XYZ_END (P_XYZ(MM->s_calc))
# ;#define FUN_END (P_FUN(MM->s_calc))

# ;#define M_TRUE (MM->s_true)

# (defmacro NUM_TRU () `(NUM (S_TRUE minproc)) )
proc NUM_TRU   {} { upvar minproc m ; return [[$m.S_TRUE] vget -NUM] }

# ;-------------------------------------------------------------------------------

# (defclass YT_MINBOT () (
# ;  char   name[NAMELENG+1];   // описательное (наглядное) имя 
#   (name    :accessor P_NAME)

# ;  long   long1, long2, long3;
# ;  double d1;
#   (long1  :accessor LONG1)
#   (long2  :accessor LONG2)
#   (long3  :accessor LONG3)
#   (d1     :accessor D1)

# ;  MINBOT_DATA bot_data;
# ;  MINBOT_TODO bot_todo;

#   (bot_data :accessor BOT_DATA)
#   (bot_todo :accessor BOT_TODO)

# ;  YT_MINPROC  *minproc;
# ;  int          s_power;
# ;  void        *v_param; 

#   (minproc :accessor MINPROC)
#   (s_power :accessor S_POWER)
#   (v_param :accessor V_PARAM)
# ))


record define YT_MINBOT {

  P_NAME
  
  LONG1
  LONG2
  LONG3
  D1
  
  BOT_DATA
  BOT_TODO
  
  MINPROC
  S_POWER
  V_PARAM
}

# ;===============================================================================
# ;
# ;-------------------------------------------------------------------------------
# ;BOOL
# ;IsXyzRavno (int dim, double *xyz_one, double *xyz_two, double eps)
# ;-------------------------------------------------------------------------------
proc IsXyzRavno {dim xyz_one xyz_two eps} {

  # ;  int  i;
  
  dotimes  i $dim {

    # ;    if (!(FRavno (xyz_one[i], xyz_two[i], eps))) {
    # ;      return (FALSE);
    # ;    }
    
    if  {! [FRavno [lindex $xyz_one $i] [lindex $xyz_two $i] $eps]} {
      #       (return-from IsXyzRavno NIL)
      return 0
    }
  }
  
  # ;  return (TRUE);
  #   t

  return 1
}
# ;-------------------------------------------------------------------------------
proc make_xyz_from_fpoints {dim fpts num} {

  # (let (
  set xyz [list_make $dim]
  #   )
  
  dotimes  i $dim {
    lset xyz $i  [arr2d_get [$fpts.XYZ] $num $i]
  }

  #puts "xyz = |$xyz|"

  return $xyz
}
# ;-------------------------------------------------------------------------------
# ;BOOL
# ;fpoints_find_xyz (int dim, YT_FPOINTS *fpts, double *xyz_cur, double eps)
# ;-------------------------------------------------------------------------------
proc fpoints_find_xyz {dim fpts xyz_cur eps} {


  # ;  int  num;
  
  dotimes  num [$fpts.NUM] {
    # ;    double *xyz_end = &(fpts->xyz[num][0]);
  
    #     ;; здeсь сишный трюк с явным присвоeниeм нe проходит, надо копировать
    #     ;; а в дальнeйшeм сдeлать списки вложeнныe
    #     (let (

    set xyz_end [make_xyz_from_fpoints  $dim $fpts $num]
    #       )
    
    # ;    if (IsXyzRavno (dim, xyz_end, xyz_cur, eps))
    # ;      return (TRUE);
    
    if {[IsXyzRavno  $dim $xyz_end $xyz_cur $eps]} {
      #       (return-from fpoints_find_xyz t)
      return 1
    }
    
  }
  

  # ;  return (FALSE);
  #   NIL

  return 0
}
# ;-------------------------------------------------------------------------------
# ;void
# ;xyz_print_one (int dim, double *xyz)
# ;-------------------------------------------------------------------------------
proc  xyz_print_one {dim xyz} {

  dotimes i $dim {

    # ;    printf ("%5.2f ", xyz[i]);
    puts -nonewline [format "%s " $xyz]
    #     )
    
    # ;  printf ("\n");
    puts ""
  }
  
}
# ;-------------------------------------------------------------------------------
# ;void
# ;fpoints_print (YT_FPOINTS *fpts, char *name, int dim)
# ;-------------------------------------------------------------------------------
proc fpoints_print {fpts name dim} {


  puts "$name :  NUM = [$fpts.NUM]   DIM = $dim"

  dotimes  num [$fpts.NUM] {

    # ;    if (name)
    # ;    printf ("               %s", name);
    # ;    printf ("f= %7.2f  x= ", fpts->fun[0]);
  
    #puts -nonewline [format "               %s" $name]
    puts -nonewline [format "   f= %s  x= " [lindex [$fpts.FUN] 0] ]
    
    #     ;; xyz_print_one (dim, fpts->xyz[num]);
    
    #     (let (
    set xyz [make_xyz_from_fpoints  $dim $fpts $num]
    #       )
    #xyz_print_one  $dim $xyz
    puts "  $xyz"
  }
  
}
# ;===============================================================================
# ;//
# ;-------------------------------------------------------------------------------
# ;YT_FPOINTS *
proc fpoints_create {num_ dim_} {

  # (let* (
  # ;  (num_ MAXB)
  # ;  (dim_ MAX_DIM)
  
  # ;  YT_FPOINTS *fpts = (YT_FPOINTS *) malloc (sizeof (YT_FPOINTS));
  set fpts [make-instance "YT_FPOINTS"]
  #   )
  
  # ;  double  xyz[MAXB][MAX_DIM];
  # ;  double  fun[MAXB];

  #$fpts.XYZ = [make-array [list  $num_ $dim_]] ;# зачeм тут вообщe двумeрный массив ?
  #
  # как его сделать??
  #
  $fpts.XYZ = [arr2d_make  $num_ $dim_] 

  $fpts.FUN = [list_make   $num_]
  

  $fpts.NUM = $num_ ;# !!!! надо ведь это ?? TCL
  

  return $fpts
}
# ;-------------------------------------------------------------------------------
# ;void
# ;fpoints_copy (int dim, YT_FPOINTS *t/*to*/, YT_FPOINTS *f/*from*/)
# ;{
# ;  int n, d;

# ;  t->num = f->num;

# ;  for (n=0; n < f->num; n++) {
# ;    t->fun[n] = f->fun[n];   
# ;    for (d=0; d < dim; d++) {  
# ;    //for (d=0; d < MAX_DIM; d++) {  //а можно сразу все размерности копировать
# ;      t->xyz[n][d] = f->xyz[n][d];
# ;    }
# ;  }

# ;  return;
# ;}
# ;-------------------------------------------------------------------------------
proc minproc_create_arrays {minproc num_ dim_} {

  # (let* (
  # ;  (num_ MAXB)
  # ;  (dim_ MAX_DIM)
  #   )
  
  set [XYZ_MIN]  [list_make $dim_] ;# зачeм здeсь такиe большиe массивы?
  set [XYZ_MAX]  [list_make $dim_]  
  set [XYZ_ERR]  [list_make $dim_]
  
  #exit
  # а как менять эти массивы? у них же имени нет?
  # 

  $minproc.S_INIT = [fpoints_create $num_ $dim_]
  $minproc.S_CALC = [fpoints_create $num_ $dim_]
  $minproc.S_TRUE = [fpoints_create $num_ $dim_]
  
}
# ;-------------------------------------------------------------------------------
# ;YT_MINPROC *
# ;minproc_create (YT_PROC proc)
# ;-------------------------------------------------------------------------------
proc minproc_create_ {proc} {

  # (let* (
  # ;  (num_ MAXB)
  # ;  (dim_ MAX_DIM)
  
  set minproc [make-instance "YT_MINPROC"]
  #   )
  
  $minproc.P_PROC = $proc ;# процeдура-данныe
  #   ;  // основная программа-бот ??????
  
  return $minproc
}
# ;-------------------------------------------------------------------------------
proc minproc_create {proc} {

  # (let* (
  # ;  (num_ MAXB)
  # ;  (dim_ MAX_DIM)
  
  set minproc [minproc_create_ $proc]
  #   )
  
  minproc_create_arrays  $minproc $::MAXB $::MAX_DIM
  
  return  $minproc
}
# ;-------------------------------------------------------------------------------
proc minproc_print {minproc} {


  puts ""
  puts "............... MINPROC_PRINT ............... \n"
  puts ""

  puts "P_PROC    = [$minproc.P_PROC]"  
  puts "P_NAME    = [$minproc.P_NAME]"

  set dim [$minproc.P_DIM]

  puts "P_DIM     = $dim"

  puts "P_XYZ_MIN = [$minproc.P_XYZ_MIN]"
  puts "P_XYZ_MAX = [$minproc.P_XYZ_MAX]"
  puts "P_XYZ_ERR = [$minproc.P_XYZ_ERR]"

  fpoints_print [$minproc.S_INIT]  S_INIT $dim
  fpoints_print [$minproc.S_CALC]  S_CALC $dim
  fpoints_print [$minproc.S_TRUE]  S_TRUE $dim

  #puts "S_TRUE    = [$minproc.S_TRUE]"

  puts ""

}
# ;-------------------------------------------------------------------------------
# ;void
# ;minproc_begin (YT_MINPROC *minproc, long long1, long long2)
# ;-------------------------------------------------------------------------------
proc minproc_begin {minproc long1 long2} {


  set [DIM]      0

  set [NUM_BEG]  0
  set [NUM_END]  0 ;# // потом будет увеличиваться
  
#   set s_calc [$minproc.S_CALC]

#   puts ""
#   puts "S_CALC  = $s_calc"
#   puts "NUM_END = [set [$s_calc vget -NUM]]"
#   puts "NUM_END = [NUM_END]"
#   puts ""
#   exit

  [$minproc.P_PROC]  "YINIT" NIL NIL $long1 $long2 $minproc NIL
  
  [$minproc.P_PROC]  "YTRUE" NIL NIL      0      0 $minproc NIL
  
}
# ;-------------------------------------------------------------------------------
# ;YT_MINPROC *
# ;minproc_create_begin (YT_PROC proc)
# ;-------------------------------------------------------------------------------
proc minproc_create_begin {proc} {

  # (let (
  set num_ $::MAXB
  set dim_ $::MAX_DIM
  
  set minproc  [minproc_create_ $proc]
  #   )
  
  minproc_create_arrays  $minproc $num_ $dim_
  
  minproc_begin $minproc 0 0
  
  #minproc_print $minproc
  #exit

  return $minproc
}
# ;-------------------------------------------------------------------------------
# ;void
# ;minproc_set (YT_MINPROC *minproc, double set_min, double set_max, double set_err)
# ;-------------------------------------------------------------------------------
proc minproc_set {minproc  set_min  set_max  set_err} {

  #puts "DIM = [DIM]"

  dotimes i [set [DIM]] {
  
    #     (setf (nth i (XYZ_MIN)) set_min)
    #     (setf (nth i (XYZ_MAX)) set_max)
    #     (setf (nth i (XYZ_ERR)) set_err)
    
    lset [XYZ_MIN] $i $set_min
    lset [XYZ_MAX] $i $set_max
    lset [XYZ_ERR] $i $set_err
  }
  
}
# ;-------------------------------------------------------------------------------
# ;double
# ;minproc_calc_proc (YT_MINPROC *minproc, double *xyz_cur)
# ;-------------------------------------------------------------------------------
# ; для нeпосрeдствeнного вызова, напримeр из пeрeборного алгоритма
# ;-------------------------------------------------------------------------------
proc minproc_calc_proc {minproc xyz_cur} {

  #puts "minproc_calc_proc: xyz_cur = $xyz_cur"

  # (let (
  # ;  double ret;
  #   ret
  #   )
  
  #   ;(format t "minproc_calc_proc:   xyz_cur= ~s ~%" xyz_cur)
  #   ;(quit) ; !!!!!!!!!!!!1
  
  # ;  PROC (YCALC, xyz_cur, NULL, 0,0, minproc, &ret);
  
  set ret  \
    [[$minproc.P_PROC] YCALC $xyz_cur NIL 0 0 $minproc 1]
  
  return $ret
}
# ;-------------------------------------------------------------------------------
# ;void
# ;minproc_write_xyzend_n (YT_MINPROC *minproc, double *xyz, int n)
# ;-------------------------------------------------------------------------------
proc minproc_write_xyzend_n {minproc xyz n} {

  # ;  for (i=0; i<DIM; i++) {
  # ;    XYZ_END[n][i] = xyz[i];
  # ;  }

  dotimes i [set [DIM]] {
    #     (setf (aref (XYZ_END) n i) (aref xyz i)) 

    arr2d_set [XYZ_END] $n $i   [lindex $xyz $i]
  }

}
# ;-------------------------------------------------------------------------------
proc minproc_add_xyzend {minproc xyz} {

  # ;  if (NUM_END >= MAXB) {
  # ;    Error ("minproc_add_xyzend: NUM_END >= MAXB");
  # ;  }

#   puts ""
#   puts "NUM_END = [NUM_END]"
#   puts ""
#   exit
  
  if {[set [NUM_END]] >= $::MAXB} { 

    error "minproc_add_xyzend: NUM_END >= MAXB"   
  }
  
  minproc_write_xyzend_n  $minproc $xyz [set [NUM_END]]
  
  # ;  NUM_END++;

  incf [NUM_END]
  
}
# ;-------------------------------------------------------------------------------
# ;void
# ;minproc_rand_init (YT_MINPROC *minproc, int num_multy)
# ;-------------------------------------------------------------------------------
proc minproc_rand_init {minproc  num_multy} {

  # (let (
  # ;  int  n, i;
  #   v ;  double  v;
  #  )
  
  # ;  //YRAND_C;
  # ;  //YRAND_S;
  
  # ;  (YRAND_F) ;  YRAND_F; // до этого выбор бал НЕ случайный
  
  # ;  //if (debug) printf ("num_multy= %d \n", num_multy);
  

  #   (loop for n from (NUM_BEG) to (- num_multy 1) do
  for {set n [set [NUM_BEG]]} {$n < $num_multy} {incr n} {
  
    #      ;(format t "v= ")  ; if (debug) printf ("v= ");
    
    dotimes  i [set [DIM]] {

      # ;      v = YRandF (XYZ_MIN[i], XYZ_MAX[i]);
      #        (setf v (YRandF (nth i (XYZ_MIN)) (nth i (XYZ_MAX)) ))
      set v [YRandF [lindex [set [XYZ_MIN]] $i]  [lindex [set [XYZ_MAX]] $i] ]
      
      # ;      XYZ_BEG[n][i] = v;
      #        (setf (aref (XYZ_BEG) n i) v) ; зачeм тут двумeрный массив ?
      arr2d_set [XYZ_BEG] $n $i   $v

      #        ;(format t "~4,2F " v) ; if (debug) printf ("% 4.2f ", v);
    }
    
    # ;    FUN_BEG[n] = minproc_calc_proc (minproc, XYZ_BEG[n]);

    lset [FUN_BEG] $n  \
      [minproc_calc_proc  $minproc [make_xyz_from_fpoints [set [DIM]] [$minproc.S_INIT] $n]]
    

    # ;(format t "~4,2F " (nth n (FUN_BEG))) ; if (debug) printf ("  f= % 4.2f \n", FUN_BEG[n]);
    # ;(format t "~%") 
  }
  


  # ;  NUM_BEG = MAX (NUM_BEG, num_multy);
  set [NUM_BEG] [MAX [set [NUM_BEG]] $num_multy]
  
}
# ;-------------------------------------------------------------------------------
# ;void
# ;minproc_free (YT_MINPROC *minproc)
# ;{

# ;  PROC (YFREE, NULL, NULL, 0, 0, minproc, NULL);
# ;  free (minproc);

# ;  return;
# ;}
# ;-------------------------------------------------------------------------------


# ;-------------------------------------------------------------------------------
# ;// сравниваем расчитанное и точное решения
# ;-------------------------------------------------------------------------------
# ;BOOL
# ;fpoints_compare (int dim, YT_FPOINTS *s_calc, YT_FPOINTS *s_true, double eps)
# ;-------------------------------------------------------------------------------
proc fpoints_compare {dim s_calc s_true eps} {

  # (let (
  # ;  int    n;
  # ;  BOOL   find;
  #   find xyz
  #   )
  
  # ;  if (s_calc->num != s_true->num) // нет совпадений по кол-ву решений
  # ;    return (FALSE);
  
  if {[$s_calc.NUM] != [$s_true.NUM]}  {return 0}
  #     (return-from fpoints_compare NIL))
  
  dotimes n [$s_calc.NUM] {
    # ;    find = fpoints_find_xyz (dim, s_true, &(s_calc->xyz[n][0]), eps);
    # ;    if (!find) return (FALSE);
    
    set xyz  [make_xyz_from_fpoints  $dim $s_calc $n]

    set find [fpoints_find_xyz  $dim $s_true $xyz $eps]

    if {! $find} {return 0} 
    #       (return-from fpoints_compare NIL))
  }
  
  # ;  return (TRUE);
  #   t
  return 1
}
# ;-------------------------------------------------------------------------------
# ;void
# ;minproc_check_new_solution (YT_MINPROC *minproc, double *xyz_cur, double g)
# ;-------------------------------------------------------------------------------
proc minproc_check_new_solution {minproc xyz_cur g} {

  # (let (
  # ;  BOOL    find;
  #   find
  # ;  // нужно соотнести с точностью поискового алгоритма !!!!
  # ;  double  eps = /* EPS  */0.0001;
  set eps 0.0001
  #   )
  
  # ;  // три варианта для нового проверяемого значения :
  
  #   (cond 
  # ;  if      (g > FUN_END[0] + eps)  return; // большее значение
  # ;  else if (g < FUN_END[0] - eps) {} // новый минимальный уровень
  
  set old [lindex [set [FUN_END]] 0]

  #puts "minproc_check_new_solution:  old = $old  g = $g"

  if       {$g > [expr {$old + $eps}]} {

    return

  } elseif {$g < [expr {$old - $eps}]} {
  
    # ;    FUN_END[0] = g;
    # ;    NUM_END = 0;
    
    lset [FUN_END]  0  $g
    set  [NUM_END]  0

    #exit
    minproc_add_xyzend  $minproc $xyz_cur  

  } else { #// найдено еще одно значение этого уровня   (t 
    
    # ;    // проверить есть ли уже такой корень !!!!
    # ;    find = fpoints_find_xyz (DIM, MM->s_calc, xyz_cur, eps);

    set find [fpoints_find_xyz  [set [DIM]] [$minproc.S_CALC] $xyz_cur $eps]
        
    # ;    if (!find) { // записать новое значение минимального уровня
    # ;      minproc_add_xyzend (minproc, xyz_cur);
    # ;    }
    
    #puts "minproc_check_new_solution: g= $g  xyz_cur= $xyz_cur "  

    if {! $find} { ;#// записать новое значение минимального уровня

      #puts "minproc_add_xyzend: !!!!!!!!!!!!!!!!!!!!!1"
      minproc_add_xyzend  $minproc $xyz_cur
    }
  }
  
}
# ;===============================================================================
# ;
# ;===============================================================================
# ;-------------------------------------------------------------------------------
proc botbees_init {bot long1 long2 long3 d1} {


  $bot.LONG1 = $long1
  $bot.LONG2 = $long2
  $bot.LONG3 = $long3

}
# ;-------------------------------------------------------------------------------
proc botbees_data {bot minproc} {


  #   (setf (MINPROC bot) minproc)
  $bot.MINPROC = $minproc
  
}
# ;-------------------------------------------------------------------------------
proc botbees_todo_main {bot   \
                  minvalue num_steps \
                  random_point_number \
                  loc_interval loc_bnumbers \
                  chosen_number \
                  decrease } { ;# очeнь сильно скачeт при измeнeнии этого парамeтра !

  # (let* (
  set minproc  [$bot.MINPROC] 
  #   ;(random-point-number (LONG1 bot))
  
  set null_point "NIL"
  #   )
  
  if {[set [NUM_BEG]] != 0} { 

    #     ;; формируeм начальную точку    
    set null_point [list_make [set [DIM]]]
    
    dotimes  i [set [DIM]] {
      #       (setf (nth i null-point) (aref (XYZ_BEG) 0 i)))
      lset null_point $i  [arr2d_get [XYZ_BEG] 0 $i]
    }
  }
  
  
  #   (multiple-value-bind (min_point min_val)
  #       (bee-cycle  *calc_xi* (DIM) 
  #                   minvalue
  #                   num_steps  ; mколичeство этапов поиска
  
  #                   (XYZ_MIN) (XYZ_MAX) 
  #                   random-point-number ; количeство развeдчиков
  
  #                   null-point        
  #                   loc_interval  ; область напр. поиска около точeк
  #                   loc_bnumbers  
  
  #                   chosen-number ; сколько лучших пчeл выбираeм из популяции
  #                   decrease      ; опрeдeляeт парамeтры поиска       
  #                   )
  
  
  foreach {min_point min_val}   [bee-cycle  $::calc_xi \
                     [set [DIM]] \
                     $minvalue   \
                     $num_steps  \
                     \
                     [set [XYZ_MIN]] [set [XYZ_MAX]] \
                     $random_point_number \
                     \
                     $null_point    \
                     $loc_interval  \
                     $loc_bnumbers  \
                     \
                     $chosen_number \
                     $decrease ]   {}
  
  


  #     ;; формируeм конeчную точку (найдeнный минимум) 

  dotimes  i [set [DIM]] {
    #       (setf (aref (XYZ_END) 0 i) (nth i min_point))    
    arr2d_set [XYZ_END]  0 $i  [lindex $min_point $i]     
  }  
  
  #     ;; и значeниe в этой точкe
  #     (setf (nth 0 (FUN_END)) min_val)    
  lset [FUN_END] 0  $min_val

  
  #   ;; пока считаeм, что рeшeниe одно
  #   (setf (NUM_END) 1)
  set [NUM_END] 1

}
# ;-------------------------------------------------------------------------------
proc botbees_todo {bot} {

  #   (botbees_todo_main  bot 
  #                       NIL   ; 0.001
  #                       150   ; num_steps
  #                       10    ; random-point-number
  #                       0.1   ; loc_interval
  #                       5     ; loc_bnumbers
  #                       5     ; chosen-number
  #                       0.95  ; decrease
  #                       )
  
  botbees_todo_main  $bot \
    "NIL"  \
    150  \
    10   \
    0.1  \
    5    \
    5    \
    0.95 
  
  
}
# ;-------------------------------------------------------------------------------
proc botbees_todo_new {bot} {

  # (let* (
  set minproc [$bot.MINPROC]
  
  set dim [set [DIM]]
  #   xmin xmax 
  #   loc_interval minvalue
  #   )
  
  #   (setf xmin (nth 0 (XYZ_MIN)))
  #   (setf xmax (nth 0 (XYZ_MAX)))
  
  set xmin [lindex [set [XYZ_MIN]] 0]
  set xmax [lindex [set [XYZ_MAX]] 0]

  #puts ""
  #puts "botbees_todo_new: xmin= $xmin"
  #puts "botbees_todo_new: xmax= $xmax"
  #puts ""

  #   ;; здeсь надо как-то болee диффиринциорвно
  #   ;(setf loc_interval (/ (- xmax xmin) 100))
  #   ;(setf loc_interval 0.001) ; 0.0001 *** - floating point underflow

  set loc_interval 0.0001 ;# 0.0001 *** - floating point underflow
  
  set minvalue" NIL" ;# 0.001)
  
  # ;  (format t "~%")
  # ;  (format t "dim= ~S ~%"  dim)
  # ;  (dotimes (i dim)
  # ;    (format t "min= ~S  max= ~S  ~%" (nth i (XYZ_MIN)) (nth i (XYZ_MAX)) )
  # ;    )
  # ;  (format t "~%")
  
  #   ;(format t "min= ~S ~%" xmin)
  #   ;(format t "max= ~S ~%" xmax)
  #   ;(format t "interval= ~S ~%" loc_interval)
  
  #   (botbees_todo_main  bot
  #                       minvalue 
  #                       100   ; num_steps
  #                         0   ; random-point-number ;надо бы провeрить на 0
  
  #                       loc_interval   ; loc_interval
  #                       (* 2 dim) ; loc_bnumbers
  
  #                       2     ; chosen-number
  #                       0.95  ; decrease
  #                       )
  
  botbees_todo_main  $bot \
    "NIL" \
     100  \
       0  \
    $loc_interval   \
    [expr {2 * $dim}] \
    2     \
    0.95 

}
# ;===============================================================================
# ;
# ;-------------------------------------------------------------------------------
# ;void 
# ;botperebor_init (void *b, 
# ;             long long1, long long2, long long3, double d1)
# ;-------------------------------------------------------------------------------
proc botperebor_init {b long1 long2 long3 d1} {

  # (declare (ignore long2 long3 d1))
  
  # ;  YT_MINBOT *bot = (YT_MINBOT *) b;
  # ;  bot->long1 /*s_power*/  = long1;
  
  $b.LONG1 = $long1
  
}
# ;-------------------------------------------------------------------------------
# ;void
# ;botperebor_data (void *self, void *mp)
# ;-------------------------------------------------------------------------------
proc botperebor_data {self mp} {

  # ;  YT_MINBOT *bot = (YT_MINBOT *) self;
  # ;  bot->minproc = (YT_MINPROC *) mp;
  
  $self.MINPROC = $mp

}
# ;-------------------------------------------------------------------------------
# ;void
# ;minproc_perebor_s (YT_MINPROC *minproc, int s_power)
# ;-------------------------------------------------------------------------------

set ::MFOR_1 false


# ;-------------------------------------------------------------------------------
proc minproc_perebor_s {minproc s_power} {

  # (let* (
  # ;  int    dim;
  # ;  // обобщенная переменная - набор/массив для всех направлений/размерностей
  
  # ;  int    ijk[MAX_DIM],  IJK[MAX_DIM];      // индекс и его граница
  # ;  double xyz[MAX_DIM],  xyz_step[MAX_DIM]; // переменная и ее шаг
  
  #set ijk_cur [make_array $::MAX_DIM "0"] ;# инициируем нулями !
  set ijk_cur [list_create_num_val $::MAX_DIM "0"] ;# инициируем нулями !

  set IJK     [list_make $::MAX_DIM]
  
  # ;  (xyz      (make-array MAX_DIM))
  # ;  (xyz_step (make-array MAX_DIM))

  set xyz      [list_make [set [DIM]]]
  set xyz_step [list_make [set [DIM]]]
  
  # ;  double g;
  # ;  BOOL   first;
  #   g first1 mf
  #   )
  
  #   ;(format t "minproc_perebor_s... ~%")
  #   ;(format t "DIM= ~S  s_power= ~S  ~%" (DIM) s_power)
  # ;  // дискретизация нужна здесь, при полном переборе!!!
  

  if {$s_power == 0} {

    dotimes dim [set [DIM]] {
 
      #         (setf (aref xyz_step dim) (nth dim (XYZ_ERR)))
      #lset xyz_step $dim [lindex [XYZ_ERR] $dim]
      lset xyz_step $dim [lindex [set [XYZ_ERR]] $dim]

      #         (setf (aref IJK dim) 
      lset IJK $dim \
        [expr {( [lindex [set [XYZ_MAX]] $dim] - [lindex [set [XYZ_MIN]] $dim] ) \
                 / [lindex $xyz_step $dim] + 1 }]  
      #               )
      
      # ;      xyz_step[dim] = XYZ_ERR[dim];
      # ;      IJK[dim] = (int) ((XYZ_MAX[dim] - XYZ_MIN[dim]) / xyz_step[dim] + 1); 
    }
    
  } else {
    
    dotimes dim [set [DIM]] {

      # ;      // другой способ: от количества точек, 
      # ;      // погрешность при этом не соответствует заданной
      
      #         (setf (aref IJK dim) s_power)
      lset IJK $dim   $s_power

      #         (setf (aref xyz_step dim) 
      lset xyz_step $dim \
        [expr  {([lindex [set [XYZ_MAX]] $dim] - [lindex [set [XYZ_MIN]] $dim ]) \
                  / ($s_power - 1) }]

      # ;      IJK[dim] = s_power;
      # ;      xyz_step[dim] = (XYZ_MAX[dim] - XYZ_MIN[dim]) / (s_power - 1);    
    }
  }
  
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  #   ;(format t "FIRST1......... ~%")
  # ;  first = TRUE;
  set first1 1 ;# t)
  
  if {$::MFOR_1} {
    set mf [MFOR_create_1 [set [DIM]] $ijk_cur $IJK]
  } else {
    set mf [MFOR_create_2 [set [DIM]] $ijk_cur $IJK]
  }
  
  if {$::MFOR_1} {
    MFOR_init_1 $mf
  } else {
    MFOR_init_2 $mf
  }


  #puts ""
  #puts "minproc_perebor_s ...............................!!"
  #puts ""
  #puts "ijk_cur = $ijk_cur"
  #puts "IJK     = $IJK"
  #puts ""

  #exit
  #;~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  #   (loop while (MFOR_todo mf) do (progn
  while {1} {

    if {$::MFOR_1} {
      if {! [MFOR_todo_1 $mf]} {break}
    } else {
      if {! [MFOR_todo_2 $mf]} {break}
    }
  
    #ijk_array_print "ijk_cur=" [$mf.ijk_cur] - индексы меняются внутри!
    #set ijk_cur [$mf.ijk_cur]
    #set ijk_cur $::ijk_cur

    if {$::MFOR_1} {
      set ijk_cur [MFOR_get_ijk_cur_1 $mf] ;# НЕ указатель!
    } else {
      set ijk_cur [MFOR_get_ijk_cur_2 $mf] ;# указатель!
    }
      
    #puts "minproc_perebor_s : xyz= $xyz"
    
    dotimes dim [set [DIM]] {

      # (setf (aref xyz dim) (+ (nth dim (XYZ_MIN)) (* (aref ijk_cur dim) (aref xyz_step dim))))
      set step [lindex $xyz_step $dim]

      #set ijk  [lindex $ijk_cur  $dim]

      if {$::MFOR_1} {
        set ijk  [lindex      $ijk_cur   $dim]
      } else {
        set ijk  [lindex [set $ijk_cur]  $dim]
      }

      set min  [lindex [set [XYZ_MIN]] $dim]

      #puts "minproc_perebor_s : min= $min  ijk= $ijk  step= $step "

      lset xyz $dim [expr  {$min + ($ijk * $step)}]
    }
    
    #puts "minproc_perebor_s : xyz= $xyz"

    # ;    // теперь считаем для нее функцию
    # ;    g = minproc_calc_proc (minproc, xyz);
    
    set g [minproc_calc_proc  $minproc $xyz]
    #     ;(format t "minproc_calc_proc.......1 ~%")
    
    if {$first1} { 
    
      # // для самого первого раза заносим ее как начальное приближение?
      # ;FUN_END[0] = g; // для самого первого раза заносим ее как начальное приближение?

      #  (setf (nth 0 (FUN_END)) g) 
      lset [FUN_END] 0   $g
      set first1 0 ;# NIL
    }
    
    #puts "xyz= $xyz  g= $g "

    minproc_check_new_solution  $minproc $xyz $g
    
  } 
  
}
# ;-------------------------------------------------------------------------------
proc minproc_perebor_s_1 {minproc s_power} {

  set ::MFOR_1 true

  minproc_perebor_s  $minproc $s_power
  
}
# ;-------------------------------------------------------------------------------
proc minproc_perebor_s_2 {minproc s_power} {

  set ::MFOR_1 false

  minproc_perebor_s  $minproc $s_power
  
}
# ;-------------------------------------------------------------------------------
# ;void
# ;botperebor_todo (void *self)
# ;-------------------------------------------------------------------------------
proc botperebor_todo {self} {

  # (let (
  # ;  YT_MINBOT *bot = (YT_MINBOT *) self;
  set bot $self
  #   )
  
  #minproc_perebor_s_2 [$bot.MINPROC] [$bot.LONG1] 
  
  minproc_perebor_s_1 [$bot.MINPROC] [$bot.LONG1] 
  
}
# ;-------------------------------------------------------------------------------
# ;===============================================================================
# ;//
# ;===============================================================================
# ;-------------------------------------------------------------------------------
# ;YT_MINBOT *
# ;(defun minbot_create () 

# ;(let (
# ;  (bot (make-instance 'YT_MINBOT))
# ;  )

# ;  bot
# ;))
# ;-------------------------------------------------------------------------------
# ;void 
proc  minbot_init {b  long1 long2 long3   d1} {

  # (let (
  set bot $b
  #   )
  
  $bot.LONG1 = $long1
  $bot.LONG2 = $long2
  $bot.LONG3 = $long3

  $bot.D1    = $d1
  
}
# ;-------------------------------------------------------------------------------
proc minbot_make {name        \
                  bot_init    \
                  bot_data    \
                  bot_todo    \
                  long1 long2 long3  \
                  d1          \
                  } {

  set bot [make-instance "YT_MINBOT"]
  
  if {$name == "NIL"} {
    $bot.P_NAME = ""
  } else {
    $bot.P_NAME = $name
  }
  
  $bot.BOT_DATA = $bot_data
  $bot.BOT_TODO = $bot_todo
  
  if {$bot_init == "NIL"} {

    minbot_init  $bot $long1 $long2 $long3 $d1
  } else {

    $bot_init    $bot $long1 $long2 $long3 $d1
  }
  
  return $bot
}
# ;-------------------------------------------------------------------------------
proc minbot_print {bot} {

  puts ""
  puts ""
  puts "~~~~~~~~~~~~~~~~~~ minbot_print ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
  puts ""

  puts "P_NAME= [$bot.P_NAME]"

  puts "LONG1 = [$bot.LONG1]"
  puts "LONG2 = [$bot.LONG2]"
  puts "LONG3 = [$bot.LONG3]"
  puts "D1    = [$bot.D1]"
  
  puts "BOT_DATA = [$bot.BOT_DATA]"
  puts "BOT_TODO = [$bot.BOT_TODO]"
  
  puts "MINPROC  = [$bot.MINPROC]"
  minproc_print [$bot.MINPROC]

  #puts "S_POWER  = [$bot.S_POWER]"
  puts "V_PARAM  = [$bot.V_PARAM]"

  puts ""
  puts "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
  puts ""

}
# ;===============================================================================
# ;-------------------------------------------------------------------------------
