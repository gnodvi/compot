# -*-   mode: tcl  ; coding: koi8   -*- ----------------------------------------

#-------------------------------------------------------------------------------
# 
if [info exists ::A_COMR_TL] {
  return
} else {
  set  ::A_COMR_TL ""
}

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------


# RAND  RAND  RAND  RAND  RAND  RAND  RAND  RAND  RAND  RAND  RAND  RAND  RAND  
#-------------------------------------------------------------------------------

#source "g-rand.tl"


# can't import command "rand": already exists  : переименовал rand -> myrand
#     while executing
# "namespace import ::tcl::mathfunc::*"

# ;;;=============================================================================
# ;
# ; RANDOM    RANDOM    RANDOM    RANDOM    RANDOM    RANDOM    RANDOM    RANDOM    
# ;
# ;;;=============================================================================

# (defvar *random_state_save* (make-random-state t)) 

set ::MAXRANDOM 1000000000

#set ::MAXRANDOM 0xFFFFFFFFL

# ;-------------------------------------------------------------------------------
# ; чисто лисповскиe приколы
# ;-------------------------------------------------------------------------------
# (defun srandom_save_or_read (seed)

# ; провeрить - eсли такой сиид-файл ужe eсть, то прочитать eго
# ;             а иначe - взять готовый стайт и записать eго в файл
# ; 
# (let* (
#   ;(fname "random-state.txt")
#   ;(fname (concatenate 'string "R/a-rand." (format nil "~s" seed)))
#   (fname (concatenate 'string "T/a-rand." (format nil "~s" seed) rand_SUF))
#   )

#   (with-open-file (finput fname 
#                           :direction         :input      
#                           :if-does-not-exist nil)

#     (when (eq finput NIL) ; файла нeт, надо eго записать
#       ;(format t "FILE NOT EXIST !!!~%")  
#       (with-open-file (foutput fname 
#                                :direction :output)
#         (print *random_state_save* foutput)
#       )
#     )
#   )

#   ; тeпeрь файл точно eсть, по любому прочитаeм eго
#   (with-open-file (finput fname 
#                           :direction         :input)
#     (setf *random_state_save* (read finput))
#     )

#   ; и установим наконeц затравку для рандомизатора
#   (make-random-state *random_state_save*)
# ))
# ;===============================================================================
#
# ;-------------------------------------------------------------------------------
# 
# примеры из книжки. стр. 168
#
set ::randomSeed 5049

# ;-------------------------------------------------------------------------------
# proc _RandomInit {seed} {

#   #global randomSeed

#   set ::randomSeed $seed
# }
# ;-------------------------------------------------------------------------------
# proc _Random {} {

#   #global randomSeed

#   #set ::randomSeed [expr {($::randomSeed * 9301 + 49297) % 233280}]
#   # 
#   set ::randomSeed [expr { fmod (($::randomSeed * 9301 + 49297), 233280) }]


#   return [expr {$::randomSeed / double(233280)}]
# }
# ;-------------------------------------------------------------------------------
# proc _RandomRange {range} {

#   expr {int ([_Random] * $range)}

#   # int(x) - convert number to integer by truncation/ Limited by the size of long in C.
#   # 

# }
# ;===============================================================================
# ;
# ; систeмно-зависимыe функции по случайным числам
# ;
#-------------------------------------------------------------------------------
proc math_random_seed {seed} {

  # if {$seed == 0} {
  #   set seed [Y-time 0] ;# // переменная псевдослучайность
  # } 

  expr {srand($seed)}

}
#-------------------------------------------------------------------------------
proc math_random_seed_null {seed} {

  if {$seed == 0} {
    set seed [Y-time 0] ;# // переменная псевдослучайность
  } 

  return [math_random_seed $seed]
}
#-------------------------------------------------------------------------------
proc comm_random_seed_null {seed} {

  if {$seed == 0 || $seed == "@"} {
    
    set seed [Y-time 0] ;# // переменная псевдослучайность
  } 

  return [comm_random_seed $seed]
}
#-------------------------------------------------------------------------------
proc Y-random {} {

  ##set r [myrand 0 $::MAXRANDOM]

  set r  [knut_random_int_minmax  0 $::MAXRANDOM]
  #set r  [math_random_int_minmax  0 $::MAXRANDOM]

  return $r
}
# ;===============================================================================
# ;
# ; нe систeмныe (производныe утилиты-функции)
# ;

# (defvar *debug_print*  nil)

set ::debug_print 0
#set ::simp_random 0

# ;-------------------------------------------------------------------------------
proc  YRandF {fmin fmax} {

#   if {0} {
#     set choise [expr {1.0 * [_RandomRange $::MAXRANDOM] / $::MAXRANDOM}]
#     set ret [expr {($fmin + ($choise * ($fmax - $fmin)))} ]

#   } else {
    set interval [- $fmax $fmin]

    set r [knut_random_float $interval]
    set ret [+ $fmin $r]
#   }


  return $ret
}
# ;-------------------------------------------------------------------------------
# proc YRAND_S {} {

#   srandom_set -1
# }
# ;-------------------------------------------------------------------------------
proc YRAND_C {} {

  #math_random_seed_null 2010
  comm_random_seed_null 2010
  
}
# ;-------------------------------------------------------------------------------
proc Rand123 {p1 p2 p3} {

  set y_rand [YRAND 1 100]
  
  if     {$y_rand < $p1}  {return 1} \
  elseif {$y_rand > $p3}  {return 3} \
  else                    {return 2}

}
# ;-------------------------------------------------------------------------------
# ;BOOL
proc RandYes {procent} {

  if {[Rand123 $procent 0.0 [expr {100.0 - $procent}]] == 1} { 
    #puts "RandYes = 1"
    return 1 ;#       TRUE
  } else {
    #puts "RandYes = 0"
    return 0 ;#       FALSE
  }

}
# ;-------------------------------------------------------------------------------
# proc YRAND____ {imin imax} {

#   set ii [expr {$imax - $imin + 1}]


#   if {0} {
#     # этот способ работает, но не совпаадет с Лиспом !
#     #
#     set ret [rand  $imin $imax]
    
#     return $ret
#   }

#   if {$::simp_random} {
#     set r [_RandomRange $::MAXRANDOM]
#   } else {
#     set r [Y-random]
#   }


#   if {0} {

#     set rr [expr  {$r * 1.0 * $ii / $::MAXRANDOM}]
#     set ir [expr  {int ($rr)}]   ;# floor

#   } else {

#     #(setf ret (+ imin (mod r (- imax imin -1))))
#     set rr [expr {fmod ($r, $ii)}]

#     #set ir $rr
#     set ir [expr  {int ($rr)}]   ;# floor
#   }


#   set ret [expr {$imin + $ir}]  

#   #puts stderr "YRAND:   imin= $imin  imax= $imax  ii= $ii  r= $r  rr= $rr ir= $ir  ret= $ret "

#   return $ret
# }
#-------------------------------------------------------------------------------
#
# rand() - возвращает случайное число с плавающей точкой в интервале [0.0 1.0]
#
# генерируем случайное целое из min-max (оба включены) интервала.
#-------------------------------------------------------------------------------
# proc math_random_int_minmax {min max} {

#   expr {$min + int(rand() * (($max-$min)+1))}

# }
#-------------------------------------------------------------------------------
# генерируем случайное целое из min-max (оба включены) интервала.
#-------------------------------------------------------------------------------
proc comm_random_int_minmax {min max} {

  incr max ;# правую границу сдвинули вправо

  return [comm_random_int_minmax_1  $min $max]
}
#-------------------------------------------------------------------------------
proc myrand {min max} {

##  return [math_random_int_minmax $min $max]

  return [comm_random_int_minmax $min $max]
}
#-------------------------------------------------------------------------------

# /*----------------------------------------------------------------------------*/
# //  Return TRUE (prob * 100)% of the time
# /*----------------------------------------------------------------------------*/
proc knut_random_boolean_prob {prob} {

  set number 1000000000
  
  set rnd [knut_random_int $number]
  
  set ret [expr {$rnd < $prob * $number}]

  return $ret
}
# /*----------------------------------------------------------------------------*/
# //  Return TRUE 50% of the time.
# /*----------------------------------------------------------------------------*/
proc knut_random_boolean {} {

  set ret [knut_random_boolean_prob 0.5]

  return $ret
}
# ------------------------------------------------------------------------------
proc comm_random_seed {i} {

  incr i ;# на всяк случай, чтобы не было нуля

  #gaul_random_seed $i  ;# для random_rand (crossover) - a-comr.tl (c_random_util.c)

  math_random_seed $i  ;# для lrand (начальная инициация)

  knut_random_seed $i
}
#-------------------------------------------------------------------------------
# /*----------------------------------------------------------------------------*/
proc comm_random_int_permutation {size &iarray  &oarray} \
{
  USE_REFS
  set j 0
  
  
  for {set i [expr {$size - 1}]} {$i > 0} {incr i -1} \
  {
    set pos [comm_random_int $i]

    lappend oarray [lindex $iarray $pos]

    lset iarray $pos [lindex $iarray $i]
  }
  
  lappend oarray [lindex $iarray 0]

  return
}
# /*----------------------------------------------------------------------------*/
proc permutation_test {} \
{

  #set ::simp_random 1  
  #set seed       2009
  #gaul_random_init
  #gaul_random_seed  1
  comm_random_seed  1

  set ordered {1 2 3 4 5}
  set size 5
  set permutation {}

  puts ""
  puts "permutation_test: ordered     = $ordered"

  #puts "permutation_test: "

  comm_random_int_permutation  $size  ordered  permutation 

  #puts "permutation_test: ordered     = $ordered"
  puts "permutation_test: permutation = $permutation"

  puts ""

  return
}
#===============================================================================
#

alias  comm_random_boolean_prob   knut_random_boolean_prob
alias  comm_random_boolean        knut_random_boolean

# Return a random integer between 0 and (N-1) inclusive.
#
#alias  comm_random_int             gaul_random_int
# 
alias  comm_random_int              knut_random_int
#
# при этой, вроде логичной замене, выдает непостоянные значения! seed ?
#                                         или ошибку !!
# g_ping.jm _sa 2 5 20
# g_ping.jm _09 1 5  1  @
#
# но лучше проверять на попроще и покороче тесте:
# g_ping.jm  _sa 1 5 2

#alias  comm_random_int_permutation  gaul_random_int_permutation

# Return a random integer between min and max-1 inclusive.
#
#alias  comm_random_int_minmax_1     gaul_random_int_range
#
alias  comm_random_int_minmax_1     knut_random_int_minmax_1
#
#
# t~.tl ANTS ANTS_gp 2012  10 15 2  - error !
#

alias YRAND comm_random_int_minmax

alias random_double       knut_random_float
alias random_double_range YRandF

#===============================================================================
#
#-------------------------------------------------------------------------------
proc rand_0 {} {

  #puts stderr "......... 05-stderr"
  #puts stdout "......... 05-stdout"

  dotimes i 10 {

    set str [format "YRAND(1 4)= %s \n" [YRAND 1 4]]

    puts -nonewline $str 
  }

  # a~.jm COMM rand_1
  #a-comm.tl:3506: Error: wrong # args: should be "stdout switch ?file?"

}
# ;-------------------------------------------------------------------------------
proc rand_1 {} {

  #puts stderr "......... 04-stderr"
  #puts stdout "......... 04-stdout"

  #set ::simp_random 1  ;# ??!!
  #set ::debug_print 1

  # (let (
  set seed  2009
  #   )
  
  puts ""
  
  comm_random_seed_null $seed
  rand_0  ;# вызов вeрхнeго тeста 
  
  puts ""
  
  comm_random_seed_null $seed
  rand_0  ;# вызов вeрхнeго тeста 
  
  puts ""
  
}
# ;-------------------------------------------------------------------------------
proc rand_2 {} {

  #set ::simp_random 1  ;# ??!!

  # (let (
  set vmin -10.0 
  set vmax +10.0
  #   )
  
  puts ""

  #puts [format "time(0)= %s  " [Y-time 0]]
  #puts [format "time(0)= %s  " [Y-time 0]]
  #puts ""
  
  puts [format "v= %s  " [YRandF $vmin $vmax]]
  
  for {set i 0} {$i < 20} {incr i} {

    #set r [knut_random_int_minmax  1 5]    
    #puts "i = $i, r = $r"
    puts [format "v= %s  " [YRandF $vmin $vmax]]
  }
  
  puts ""
}
# ;-------------------------------------------------------------------------------
proc rand_4 {} {

  # ;#+SBCL (load-shared-object "libc.so.6")

  #set ::simp_random 1   ;# для точного сравнения с LISP
  
  puts ""

  dotimes i 10 {
    puts "Y-random= [Y-random]"
  }
  
  puts ""

  rand_0
  
#   puts ""

#   dotimes i 10 {
#     puts "Y-drand48= [Y-drand48]"
#   }
  
  puts ""

  dotimes i 10 {
    puts "YRandF(1, 4)= [YRandF 1 4]"
  }
  
  puts ""
}
#-------------------------------------------------------------------------------
proc rand_0_new {} {

  dotimes i 30 {

    #puts -nonewline [format "YRAND_new (1 4)= %s \n" [YRAND_new 1 5]]
    puts -nonewline [format "YRAND_new (1 4)= %s \n" [comm_random_int_minmax 1 5]]
  }

}
#-------------------------------------------------------------------------------
# возвращаем случайный элемент из списка 
#-------------------------------------------------------------------------------
# proc lrand {list} {
    
#   lindex $list [expr {int(rand()*[llength $list])}]
    
# }
#-------------------------------------------------------------------------------
proc lrand_new {list} {
    
  set l [llength $list]

  set r [comm_random_int $l]

  #set i [* $r ]

  #puts "l = $l r = $r"

  lindex $list $r
    
}

alias lrand lrand_new

#-------------------------------------------------------------------------------
proc TEST_lrand {} {
    
  #set ll {1 2 3 4 5 6 7 8 9}
  #set ll {1 2 3 4 5}
  
  set ll {1 2 3 4 } ;# ???
  #set ll {1 2 } ;# 
 
 
  #-----------------------------------------------------
  comm_random_seed 1 ;# 0 ;# in file a-comr.tl

  #-----------------------------------------------------

  puts ""

#   for {set i 0} {$i < 10} {incr i} {

#     puts "lrand     = [lrand $ll]"
#   }

#   puts ""

  #-----------------------------------------------------
  #gaul_random_seed 0     ;# для lrand (начальная инициация)

  # !!! тест дает странные (вырожденные) результаты для небольших списков !!
  # 

  puts ""

  for {set i 0} {$i < 10} {incr i} {

    puts "lrand_new = [lrand_new $ll]"
  }

  puts ""

  return
}
#-------------------------------------------------------------------------------
proc TEST_random_int {} {
    
  #-----------------------------------------------------
  #comm_random_seed 0 ;# in file a-comr.tl

  #-----------------------------------------------------

  puts ""

  for {set i 0} {$i < 20} {incr i} {

    puts "[comm_random_int 4]"
  }

  puts ""

  return
}
# /*----------------------------------------------------------------------------*/
# ./f~.tl TEST_lrand


# /*----------------------------------------------------------------------------*/
# //  Return a pseudo-random number with a uniform
# //	   distribution in the range 0.0=>r>1.0
# /*----------------------------------------------------------------------------*/
# GAULFUNC double random_unit_uniform (void)
# /*----------------------------------------------------------------------------*/
proc random_unit_uniform {} {

  set r [gaul_random_rand]

  # return ( (((double) random_rand()) / (double) RANDOM_RAND_MAX) );

  return [expr {1.0 * $r / $::RANDOM_RAND_MAX}]
}
# /*----------------------------------------------------------------------------*/
# //  Return a pseudo-random number with a normal
# //  distribution with a given mean and standard devaiation.
# /*----------------------------------------------------------------------------*/
# GAULFUNC float random_float_gaussian (const float mean, const float stddev)
# {
#   float	q,u,v,x,y;

#   /* 
#     * Generate P = (u,v) uniform in rectangular acceptance region.
#     */
#   do
#   {
#     u = 1.0f-random_float_unit_uniform();	/* in range 0.0>u>=1.0 */
#     v = 1.7156f * (0.5f - random_float_unit_uniform());	/* in range 0.8578>v>=0.8578 */

#     /* Evaluate the quadratic form. */
#     x = u - 0.449871f;
#     y = 0.386595f + fabs(v);
#     q = x * x + y * (0.19600f * y - 0.25472f * x);

#     /*
#       * Accept P if inside inner ellipse.
#       * Reject P if outside outer ellipse, or outside acceptance region.
#       */
#   } while ((q >= 0.27597) && ((q > 0.27846) || (v * v > -4.0 * log(u) * u * u)));

#   /* Return ratio of P's coordinates as the normal deviate. */
#   return (float)(mean + 2.0 * stddev * v / u);	/* I'm not entirely sure why this *2.0 factor is needed! */
# }
# /*----------------------------------------------------------------------------*/
# //  Random number with normal distribution, average 0.0,
# //	   deviation 1.0
# /*----------------------------------------------------------------------------*/
# GAULFUNC float random_float_unit_gaussian (void)
# {
#   float			r, u, v, fac;
#   static boolean	set = FALSE;
#   static float		dset;

#   if (set)
#   {
#     set = FALSE;
#     return dset;
#   }

#   do
#   {
#     u = 2.0f * random_float_unit_uniform() - 1.0f;
#     v = 2.0f * random_float_unit_uniform() - 1.0f;
#     r = u*u + v*v;
#   } while (r >= 1.0);

#   fac = (float)sqrt(-2.0 * log(r) / r);
#   dset = v*fac;

#   return u*fac;
# }

# /*----------------------------------------------------------------------------*/
# /* The original (thread-safe) version was this: */
# #if 0
# /*----------------------------------------------------------------------------*/
# float random_float_unit_gaussian (void)
# {
#   float	r, u, v;

#   do
#   {
#     u = 2.0 * random_float_unit_uniform() - 1.0;
#     v = 2.0 * random_float_unit_uniform() - 1.0;
#     r = u*u + v*v;
#   } while (r >= 1.0);

#   return u*sqrt(-2.0 * log(r) / r);
# }
# /*----------------------------------------------------------------------------*/
# #endif
# /*----------------------------------------------------------------------------*/
# //  Return a pseudo-random number with a normal
# //	   distribution with a given mean and standard devaiation.
# /*----------------------------------------------------------------------------*/
# /*
#   Kinda based on: (But optimised quite a bit)

#   ALGORITHM 712, COLLECTED ALGORITHMS FROM ACM.
#   THIS WORK PUBLISHED IN TRANSACTIONS ON MATHEMATICAL SOFTWARE,
#   VOL. 18, NO. 4, DECEMBER, 1992, PP. 434-435.
#   The algorithm uses the ratio of uniforms method of A.J. Kinderman
#   and J.F. Monahan augmented with quadratic bounding curves.
#  */
# /*----------------------------------------------------------------------------*/
# #if 0
# /*----------------------------------------------------------------------------*/
# /* Random number with normal distribution, average 0, deviation 1.
#    From Numerical Recipes. */
# /*----------------------------------------------------------------------------*/
# //  Random number with normal distribution, average 0.0,
# //	   deviation 1.0

# GAULFUNC double random_unit_gaussian (void)

# /*----------------------------------------------------------------------------*/
proc random_unit_gaussian {} {

  #   double		r, u, v, fac;
  #   static boolean	set = FALSE;
  #   static double		dset;
  
  #   if (set)
  #   {
  #     set = FALSE;
  #     return dset;
  #   }
  
  #   do
  #   {
  #     u = 2.0 * random_unit_uniform() - 1.0;
  #     v = 2.0 * random_unit_uniform() - 1.0;

  #     r = u*u + v*v;
  #   } while (r >= 1.0);
  
  while {1} {
    
    #set u [expr {2.0 * [random_unit_uniform] - 1.0}]
    #set v [expr {2.0 * [random_unit_uniform] - 1.0}]

    set u [expr {2.0 * [knut_random_float 1.0] - 1.0}]
    set v [expr {2.0 * [knut_random_float 1.0] - 1.0}]

    set r [expr {$u * $u + $v * $v}]

    if {$r < 1.0} {break}
  }

  set fac  [expr {sqrt (-2.0 * log ($r) / $r)}]
  set dset [expr {$v * $fac}]

  return [expr  {$u * $fac}]
}
#-------------------------------------------------------------------------------
# /*----------------------------------------------------------------------------*/
# //  synopsis:	Testing.
# //  return:	TRUE if all tests successful.
# /*----------------------------------------------------------------------------*/

#set ::NUM_BINS    200
#set ::NUM_SAMPLES 1000000

#// пока простой тест, просто генерируем сл. даблы
#// 
set ::NUM_BINS    20
set ::NUM_SAMPLES 20

# #define NUM_CHISQ 20

# /*----------------------------------------------------------------------------*/
# GAULFUNC boolean random_test (void)
# /*----------------------------------------------------------------------------*/
proc random_test {} {

  #   unsigned int	i, j, k;	/* Loop variables. */
  #   double	r;			/* Pseudo-random number. */
  #   long		bins[NUM_BINS];	/* Bin. */
  
  #   double	sum=0, sumsq=0;		/* Stats. */
  set sum 0.0
  
  #   int		numtrue=0, numfalse=0;	/* Count booleans. */
  #   unsigned int	rchi=100;	/* Number of bins in chisq test. */
  #   unsigned int	nchi=1000;	/* Number of samples in chisq test. */
  #   double	chisq;			/* Chisq error. */
  #   double	elimit = 2*sqrt((double)rchi);	/* Chisq error limit. */
  #   double	nchi_rchi = (double)nchi / (double)rchi;	/* Speed calculation. */
  #   FILE		*rfile=NULL;	/* Handle for file of random integers. */
  
  #   gaul_random_init();
  
  comm_random_seed 2022

  puts ""
  puts "Testing random numbers."
  
  #   /*
  #     * Uniform Distribution.
  #     */
  
  puts "Uniform distribution.  Mean should be about 0.5."
  puts ""

  #   for (i=0;i<NUM_BINS;i++) bins[i] = 0;

  for {set i 0} {$i < $::NUM_SAMPLES} {incr i} {
  
    #set r [random_unit_uniform] 
    set r [YRandF 0 1] 
   
    puts [format "r = %f" $r]

    if {$r >= 0.0 && $r < 1.0} {

      # bins[(int)(r*NUM_BINS)]++;
      # sum += r;
      set sum [expr {$sum + $r}]
      # sumsq += SQU(r);

    } else {
      puts "Number generated out of range 0.0 <= r < 1.0."
    }
  }

  puts ""
  puts [format "Mean random = %f \n" [expr {$sum / $::NUM_SAMPLES}]]

  #   printf("Standard deviation = %f\n", (sumsq - sum*sum/NUM_SAMPLES)/NUM_SAMPLES);
  
  #   for (i=0;i<NUM_BINS;i++)
  #     printf("%5.3f %ld\n", i/(double)NUM_BINS, bins[i]);
  

  #//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  set gaus [random_unit_gaussian]

  puts "gaus = $gaus"
  puts ""


  return true ;#  // ????????
  #//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

}
#-------------------------------------------------------------------------------
# /*----------------------------------------------------------------------------*/
# /*----------------------------------------------------------------------------*/
