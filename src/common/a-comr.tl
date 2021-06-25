# -*-   mode: tcl  ; coding: koi8   -*- ----------------------------------------

#-------------------------------------------------------------------------------
# 
if [info exists ::F_RAND_TL] {
  return
} else {
  set  ::F_RAND_TL ""
}

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------

# RAND  RAND  RAND  RAND  RAND  RAND  RAND  RAND  RAND  RAND  RAND  RAND  RAND  
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#
# похожий есть в l_strugle.tl

set ::is_print 0 

# здесь нужна глобальная переменная для начала отсчета "эффективных" параметров
# т.е. без вспомогательных слов!

set ::ind0 0

#-------------------------------------------------------------------------------
proc parse_opts_3 {&par1    &par2    &par3  
                     def_par1 def_par2 def_par3 {ind 1}} {

  #set ind 1 ;# с какого параметра начинаем обработку (чтение)

  USE_REFS

  global argc argv argv0

  #set ::is_print 0 ;# ?????здесь зачем я это делаю??

  if  {$argc == $ind} { 
    # вызов без параметров, только с одним mode
    
    set par1  $def_par1
    set par2  $def_par2
    set par3  $def_par3
 
  } else {

    set par1 [lindex $argv $ind]  ; incr ind 
    set par2 [lindex $argv $ind]  ; incr ind 
    set par3 [lindex $argv $ind]  ; incr ind 

    if  {$argc == [expr {$ind + 1}]}    {

      #set ::is_print 1 ;# до этого не был установлен, например в 2

      if {$::is_print == 0} {
        set ::is_print 1 ;# до этого не был установлен, например в 2
      }
    }
  }

  return $::is_print
}
#-------------------------------------------------------------------------------
proc read_seedflag {&ind} {

  USE_REFS

  global argv0 argc argv
  
  set flag [lindex $argv $ind]
  #puts "flag = $flag"
  puts ""

  # флажок для постоянства тестов (а обычно какая случайность выдается?) 
  # 
  if {$flag == "@"} {
    #mysrand 2012
    #set s_rand 1020
  } else {
    #set s_rand $flag
    #mysrand $s_rand
    mysrand $flag
  }

  incr ind ;# а так мы увеличиваем его!

}
#-------------------------------------------------------------------------------
proc parse_opt_seed_3 {&par1 &par2 &par3} {

  set def_par1  10
  set def_par2   6
  set def_par3  10

  USE_REFS

  global argv0 argc argv
  
  set ind 1 ;# один параметр у нас уже есть - имя "......."
  #set ind [expr $::ind0 + 1]
  
#   puts stderr "argc = $argc"
#   puts stderr "argc = $argc"

  read_seedflag  ind 

  parse_opts_3  par1 par2 par3  def_par1 def_par2 def_par3   $ind ;# 2 !!

}
#-------------------------------------------------------------------------------
proc parse_opt_seed_3_new {&par1 &par2 &par3} {

  set def_par1  10
  set def_par2   6
  set def_par3  10

  USE_REFS

  global argv0 argc argv
  
  set ind $::ind0 ;# !!!!!!!!!
  
  puts stderr ""
  puts stderr "ind = ::ind0 = $ind"
  puts stderr "argc = $argc"
  puts stderr "argv = $argv"

  read_seedflag  ind 

  parse_opts_3  par1 par2 par3  def_par1 def_par2 def_par3  $ind ;# 2 !!

}
# ;;;=============================================================================

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
proc _RandomInit {seed} {

  #global randomSeed

  set ::randomSeed $seed
}
# ;-------------------------------------------------------------------------------
proc _Random {} {

  #global randomSeed

  #set ::randomSeed [expr {($::randomSeed * 9301 + 49297) % 233280}]
  # 
  set ::randomSeed [expr { fmod (($::randomSeed * 9301 + 49297), 233280) }]


  return [expr {$::randomSeed / double(233280)}]
}
# ;-------------------------------------------------------------------------------
proc _RandomRange {range} {

  expr {int ([_Random] * $range)}

  # int(x) - convert number to integer by truncation/ Limited by the size of long in C.
  # 

}
# ;===============================================================================
# ;
# ; систeмно-зависимыe функции по случайным числам
# ;
# ;-------------------------------------------------------------------------------
proc Y-srandom {seed} {

  # ;#+SBCL (alien-funcall (extern-alien "srandom" (function void unsigned-int)) seed)
  # ;#+CLISP (declare (ignore seed))
  
  
  # (if is_libc 
  
  # #+SBCL  (alien-funcall (extern-alien "srandom" (function void unsigned-int)) seed)
  # #+CLISP (clisp_libc_srandom seed)
  
  # ;    (declare (ignore seed))
  # ;Misplaced declaration: (DECLARE (IGNORE SEED))
  #     )

  return [expr {srand($seed)}]

}
# ;-------------------------------------------------------------------------------
# ;#+SBCL
# ;(defun srandom_set (seed)

# ;  (if (< seed 0) (Y-srandom (Y-time 0)) ; // переменная псевдослучайность
# ;                 (Y-srandom seed)       ; // фиксированная 
# ;                 )
# ;)
# ;-------------------------------------------------------------------------------
# ;#+CLISP
proc srandom_set {seed} {

  # ;#+SBCL
  # ;  (if (< seed 0) (Y-srandom (Y-time 0)) ; // переменная псевдослучайность
  # ;                 (Y-srandom seed)       ; // фиксированная 
  # ;                 )
  
  # ;#+CLISP
  # ;  (if (< seed 0) (setf *random-state* (make-random-state t)) 
  # ;                 (setf *random-state* (srandom_save_or_read seed))      
  # ;                 )
  
  
  # (if is_libc 
  
  #   (if (< seed 0) (Y-srandom (Y-time 0)) ; // переменная псевдослучайность
  #                  (Y-srandom seed)       ; // фиксированная 
  #                  )
  
  #   (if (< seed 0) (setf *random-state* (make-random-state t)) 
  #                  (setf *random-state* (srandom_save_or_read seed))      
  #                  )
  #     )

  if {$seed < 0} {
    set ret [Y-srandom [Y-time 0]] ;# // переменная псевдослучайность
  } else {
    set ret [Y-srandom $seed]      ;# // фиксированная 
  }

  return $ret
}
# ;-------------------------------------------------------------------------------
proc Y-random {} {

  # ;#+SBCL (alien-funcall (extern-alien "random" (function int)) )
  # ;;#+CLISP (random MAXRANDOM )
  # ;#+CLISP (if is_libc (clisp_libc_random)
  # ;                   (random MAXRANDOM)
  # ;                   )
  
  # (if is_libc 
  
  # #+SBCL  (alien-funcall (extern-alien "random" (function int)) )
  # #+CLISP (clisp_libc_random)
  
  #     (random MAXRANDOM)
  #     )

  set r [myrand 0 $::MAXRANDOM]
  #set r [system random]

  return $r
}
# ;-------------------------------------------------------------------------------
# (defun Y-drand48 ()

# ;#+SBCL (alien-funcall (extern-alien "drand48" (function double)) )
# ;#+CLISP (/ (random MAXRANDOM) (* 1.0 MAXRANDOM))

# (if is_libc 

# #+SBCL  (alien-funcall (extern-alien "drand48" (function double)) )
# #+CLISP (clisp_libc_drand48)

#      (/ (random MAXRANDOM) (* 1.0 MAXRANDOM))
#     )

# )
# ;-------------------------------------------------------------------------------
# (defun Y-srand48 (seed)

# #+SBCL  (alien-funcall (extern-alien "srand48" (function void int)) seed)
# ;#+CLISP (declare (ignore seed))
# #+CLISP (clisp_libc_srand48 seed)

# )
# ;-------------------------------------------------------------------------------

# ; в CYGWIN не заработало пока не иницииировал явно тут:
# (Y-srand48 2010)

# ;-------------------------------------------------------------------------------
proc YRAND_F {} {

  # ;#+SBCL (Y-srand48 (Y-time 0))
  # ;#+CLISP (setf *random-state* (make-random-state t)) 
  
  # (if is_libc 
  
  #     (Y-srand48 (Y-time 0))
  #     (setf *random-state* (make-random-state t)) 
  #     )
  
}
# ;-------------------------------------------------------------------------------
# (defun my_sqrt (x)

# #+SBCL  (alien-funcall (extern-alien "sqrt" (function double double)) x)
# #+CLISP (sqrt x) ; похожe он один к одному бeрeт из libc.. ?

# )
# ;===============================================================================
# ;
# ; нe систeмныe (производныe утилиты-функции)
# ;

# (defvar *debug_print*  nil)

set ::debug_print 0
set ::simp_random 0

# ;-------------------------------------------------------------------------------
proc YRAND {imin imax} {

  set ii [expr {$imax - $imin + 1}]


  if {0} {
    # этот способ работает, но не совпаадет с Лиспом !
    #
    set ret [rand  $imin $imax]
    
    return $ret
  }


  if {$::simp_random} {
    set r [_RandomRange $::MAXRANDOM]
  } else {
    set r [Y-random]
  }


  if {0} {

    set rr [expr  {$r * 1.0 * $ii / $::MAXRANDOM}]
    set ir [expr  {int ($rr)}]   ;# floor

  } else {

    #(setf ret (+ imin (mod r (- imax imin -1))))
    set rr [expr {fmod ($r, $ii)}]

    #set ir $rr
    set ir [expr  {int ($rr)}]   ;# floor
  }


  set ret [expr {$imin + $ir}]  

  #puts stderr "YRAND:   imin= $imin  imax= $imax  ii= $ii  r= $r  rr= $rr ir= $ir  ret= $ret "

  return $ret
}
# ;-------------------------------------------------------------------------------
proc  YRandF {fmin fmax} {

  # (let (
  #   (choise (Y-drand48))
  #set choise [expr rand()]

  set choise [expr {1.0 * [_RandomRange $::MAXRANDOM] / $::MAXRANDOM}]

  #   )
  
  #   (+ fmin (* choise (- fmax fmin)))

  set ret [expr {($fmin + ($choise * ($fmax - $fmin)))} ]

  #puts stderr "choise = $choise  YRandF = $ret"

  return $ret
}
# ;-------------------------------------------------------------------------------
proc YRAND_S {} {

  srandom_set -1
}
# ;-------------------------------------------------------------------------------
proc YRAND_C {} {

  srandom_set 2010
}
# ;-------------------------------------------------------------------------------
proc Rand123 {p1 p2 p3} {

  # (declare (ignore p2))

  # (let (
  set y_rand [YRAND 1 100]
  #   )
  
  #   ;(format t "Rand123: ~s ~%" y_rand)
  
  #   (cond 
  #    ((< y_rand p1)  1)
  #    ((> y_rand p3)  3)
  #    (t              2)
  #    )
  
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
# ; Возвращает псевдо-случайное число с плавающей точкой
# ; в диапазоне       0.0 <= number < n
# ;
# ; 0.0 - включен или нет? !
# ;-------------------------------------------------------------------------------
# (defun random-floating-point-number (n)

#   (YRandF 0 n)
# )
# ;-------------------------------------------------------------------------------
# ; Возвращает псевдо-случайное целоев в диапазоне 0 ---> n-1
# ;-------------------------------------------------------------------------------
# (defun random-integer (n)

# (let (
#   )

#   (YRAND 0 (- n 1))
# ))
# ;-------------------------------------------------------------------------------
# (defun seed_set (seed)

#   (if (= 0 seed) 
#       t ;(format t "SEEEED ~%") ;; это сигнал, что глобальный не надо менять

#       ;(srandom_set seed)
#       (srandom_set (round (* 2010 seed)))
#    ) 

# )
# ;-------------------------------------------------------------------------------
# (defun seed_set_random ()
  
#   (YRAND_S)
# )
# ;-------------------------------------------------------------------------------
# ; случайноe значeниe из интeрвала [-max-value, max-value] ??
#
# это с плавающей точкой ??
# ;-------------------------------------------------------------------------------
proc  random-value {max_value} {

  # ;  (- max-value (* 2 (random max-value)))

  #set r [YRAND 0 $max_value]
  set r [YRandF 0 $max_value]
  
  set ret [expr {$max_value - (2 * $r)}]

  #puts "  random-value: max_value= $max_value r= $r ret= $ret"
  
  return $ret

}
# ;-------------------------------------------------------------------------------
proc random_in_interval {fmin fmax} {

  # ;  (coerce (- (random-floating-point-number (- fmax fmin)) (- 0.0 fmin))
  # ;          'single-float)
  
  
  set r [YRandF $fmin $fmax]

  #puts "random_in_interval: r = $r"
  #puts ""
  #exit

  return $r
}
# ;===============================================================================
# ;
# ;-------------------------------------------------------------------------------
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

  set ::simp_random 1  ;# ??!!
  #set ::debug_print 1

  # (let (
  set seed  2009
  #   )
  
  puts ""
  
  srandom_set $seed
  rand_0  ;# вызов вeрхнeго тeста 
  
  puts ""
  
  srandom_set $seed
  rand_0  ;# вызов вeрхнeго тeста 
  
  puts ""
  
}
# ;-------------------------------------------------------------------------------
proc rand_2 {} {

  set ::simp_random 1  ;# ??!!

  # (let (
  set vmin -10.0 
  set vmax   7.0
  #   )
  
  puts ""

  puts [format "time(0)= %s  " [Y-time 0]]
  puts [format "time(0)= %s  " [Y-time 0]]
  puts ""
  
  YRAND_F
  puts [format "v= %s  " [YRandF $vmin $vmax]]
  
  YRAND_F
  puts [format "v= %s  " [YRandF $vmin $vmax]]
  
  puts ""
}
# ;-------------------------------------------------------------------------------
# (defun rand_3 (argus)  (declare (ignore argus))

#   ;(setf *random-state* (make-random-state t))
#   ;(setf *random-state* (make-random-state nil))
  
#   (YRAND_S)
#   ;(YRAND_C)
#   ;(YRAND_F)

#   (dotimes (i 20)
  
#     (format t "  ~A  ~12S   ~A  ~%" 
#             (YRAND 1  4)  ;(gal_irand 4) 
#             (Y-drand48)   ;(gal_frand) 
#             (YRAND 0 1)   ;(gal_brand) 
#             ) 
#     ) 

#   (format t "~%")
# )
# ;-------------------------------------------------------------------------------
proc rand_4 {} {

  # ;#+SBCL (load-shared-object "libc.so.6")

  set ::simp_random 1   ;# для точного сравнения с LISP
  
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
# ;-------------------------------------------------------------------------------
# (defun rand_5 (argus)  (declare (ignore argus))

# (let (
#   ;(seed  2009)
#   )

#   (format t "~%")

# ;(YRAND_C)
# ;(srandom_set seed)
# ;(rand_test_0)

#   (srandom_set 2010)
#   (format t "srandom_set 2010 ~%~%")

#   (dotimes (i 10)
#     (format t "YRAND(-7 +7)= ~s ~%" (YRAND -7 +7))
#     )

#   (format t "~%")
# ))
# ;===============================================================================

# ;-------------------------------------------------------------------------------
# (defun rand_6 (argus) (declare (ignore argus))

#   (setf is_libc NIL) ; используeм чисто лисповскиe прикольныe случ. функции

#   (srandom_set 201)

#   (format t "~%")

#   (dotimes (i 10)
#     (format t "Y-random= ~s ~%" (Y-random))
#     )

#   (format t "~%")
# )
# ;===============================================================================
# ;
# ;
# ;
# ;
# ;===============================================================================

# ;-------------------------------------------------------------------------------
# (defun pick-k-random-individual-indices (k max)

# (let (
#   (numbers nil)
#   )

#   (loop 
#     for n = (random-integer max)

#     unless (member n numbers :test #'eql)
#     do (push n numbers)

#     until (= (length numbers) k)
#     )

#   numbers
# ))
# ;-------------------------------------------------------------------------------
# (defun int_from_bin (genotype bit_num)

# (let (
#   bit pos val
#   (value 0)
#   ) 
  
#   (dotimes (i bit_num)
#     (setf bit (nth i genotype))

#     (when (= bit 1)
#         (setf pos (- bit_num i 1))
#         (setf val (expt 2 pos))
#         (setf value (+ value val))
#     )
#   )

#   value
# ))	                                                             
#-------------------------------------------------------------------------------
proc mysrand {seed} {

  expr {srand($seed)}

}
#-------------------------------------------------------------------------------
#
# rand() - возвращает случайное число с плавающей точкой в интервале [0.0 1.0]
#
# генерируем случайное целое из min-max (оба включены) интервала.
#-------------------------------------------------------------------------------
proc myrand {min max} {

  expr {$min + int(rand() * (($max-$min)+1))}

}
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------










#-------------------------------------------------------------------------------
# /*****************************************************************************
#  *                                                                           *
#  *  Имя этого файла: c_random_util.c                                         *
#  *                                                                           *
                                                                            
#   Synopsis:	Portable routines for generating pseudo random numbers.

# 		Why use these instead of the system routines?
# 		(a) Useful interface functions. (can specify ranges or
# 		specific distributions)
# 		(b) System independant. (Generated numbers are
# 		reproducible across system types.)
# 		(c) Enables saving and restoring state.

# 		SLang intrinsic function wrappers are provided if the
# 		HAVE_SLANG macro is defined

# 		The algorithm I selected is the Mitchell and Moore
# 		variant of the standard additive number generator.
# 		The required array of numbers is populated by a
# 		using single seed value by using a linear
# 		congruential pseudo random number generator.

#   References:	Standard additive number generator and the linear
# 		congruential algorithm:
# 		Knuth D.E., "The Art of Computer Programming",
# 		Vol 2, 2nd ed. (1998)

# 		General information:
# 		Press W., Flannery B.P., Teukolsky S.A., Vetterling W.T.,
# 		"Numerical Recipes in C: The Art of Scientific Computing"
# 		Cambridge University Press, 2nd ed. (1992)

#   Usage:	o First call random_init().

# 		o Call random_seed() to seed the PRNG (like srand()).
# 		  Alternatively, random_tseed() to use system clock for seed.

# 		o random_rand() is a rand() replacement, which is available
# 		  for use but I would recommend the wrapper functions:
# 		  random_int(), random_int_range() etc.

# 		o random_get_state() and random_set_state() may be used
# 		  to set, save, restore, and query the current state.

# 		These functions can be tested by compiling with
# 		something like:
# 		gcc -o testrand random_util.c -DRANDOM_UTIL_TEST

#   To do:	Gaussian/Boltzmann distributions.
# 		Need a proper test of randomness.
# 		Properly implement stack of states.
# 		I could do with some handy documentation.

#  **********************************************************************/

# /*----------------------------------------------------------------------------*/
# /*
#  * Constants.
#  */

set ::RANDOM_RAND_MAX 4294967295

set ::RANDOM_NUM_STATE_VALS  57

# /*
#  * PRNG constants.  Don't mess with these values willie-nillie.
#  */

set ::RANDOM_MM_ALPHA	55
set ::RANDOM_MM_BETA	24
set ::RANDOM_LC_ALPHA	3
set ::RANDOM_LC_BETA	257
set ::RANDOM_LC_GAMMA	RANDOM_RAND_MAX

# static boolean	is_initialised=FALSE;
#set ::is_initialised false
set ::is_initialised 0

# /*----------------------------------------------------------------------------*/
# //  Replacement for the standard rand().
# //  Returns a new pseudo-random value from the sequence, in
# //  the range 0 to RANDOM_RAND_MAX inclusive, and updates
# //  global state for next call.  size should be non-zero,
# //  and state should be initialized.

# GAULFUNC unsigned int random_rand (void)

# /*----------------------------------------------------------------------------*/
proc random_rand {} {

  #   unsigned int val;

  if {! $::is_initialised} {
    die "Neither 'random_init' or 'random_seed' have been called."
  }

  #   THREAD_LOCK(random_state_lock);

  set j  $::current_state_j
  set k  $::current_state_k

  #   val = (current_state.v[current_state.j] + current_state.v[current_state.k])
  #     & RANDOM_RAND_MAX;
  
  set val [expr {($::current_state_v($j) + $::current_state_v($k)) & $::RANDOM_RAND_MAX}]
  
  set ::current_state_x [expr {($::current_state_x + 1) % $::RANDOM_NUM_STATE_VALS}]
  set ::current_state_j [expr {($::current_state_j + 1) % $::RANDOM_NUM_STATE_VALS}]
  set ::current_state_k [expr {($::current_state_k + 1) % $::RANDOM_NUM_STATE_VALS}]

  #set ::current_state_v($::current_state_x)  val
  set ::current_state_v($::current_state_x)  $val
  
  #   THREAD_UNLOCK(random_state_lock);

  #puts stderr "random_rand:  val = $val"
  #exit

  return $val
} 
# /*----------------------------------------------------------------------------*/
# GAULFUNC void random_seed (const unsigned int seed)
proc random_seed {seed} {

  #puts "random_seed .............. "

#   if {$::is_my_random} {
#     # не будем усложнять, воспользуемся встроенными средствами!
#     # 
#     expr {srand ($seed)} 
#     return
#   }

  #   int	i; 
  
  #set ::is_initialised true
  set ::is_initialised 1

  #   current_state.v[0]=(seed & RANDOM_RAND_MAX);
  set ::current_state_v(0) [expr {$seed & $::RANDOM_RAND_MAX}]
  
  #puts "seed= $seed  RANDOM_RAND_MAX= $::RANDOM_RAND_MAX $::current_state_v(0)"


  for {set i 1} {$i < $::RANDOM_NUM_STATE_VALS} {incr i} {

    set iminus1 [expr {$i - 1}]
    set val [expr {($::RANDOM_LC_ALPHA * $::current_state_v($iminus1) + $::RANDOM_LC_BETA) \
                     & $::RANDOM_RAND_MAX}]

    set ::current_state_v($i) $val
  }

  set ::current_state_j  0
  set ::current_state_k [expr {$::RANDOM_MM_ALPHA - $::RANDOM_MM_BETA}]
  set ::current_state_x [expr {$::RANDOM_MM_ALPHA - 0}]
  
  return
} 
# /*----------------------------------------------------------------------------*/
# //  Initialise random number generators.  Should be
# //  called prior to any of these functions being used.
# //  Seeds the PRNG with a seed of 1.
# /*----------------------------------------------------------------------------*/
# GAULFUNC void random_init (void)
# /*----------------------------------------------------------------------------*/
proc  random_init {} {

  #puts "random_init .............. "

  random_seed  1
  
  # #if RANDOM_DEBUG>0
  #   printf("DEBUG: Random number routines initialised.\n");
  # #endif

  return
}
#-----------------------------------------------------------

random_init ;# сразу подготовим к выполнению, на всяк случай.


# /*----------------------------------------------------------------------------*/
# //  Return TRUE 50% of the time.
# /*----------------------------------------------------------------------------*/
# GAULFUNC boolean random_boolean (void)
# /*----------------------------------------------------------------------------*/
proc random_boolean {} {

  set ret [expr {[random_rand] <= $::RANDOM_RAND_MAX / 2}]

  return $ret

  #return (boolean)(random_rand() <= RANDOM_RAND_MAX/2);
}
# /*----------------------------------------------------------------------------*/
# //  Return TRUE (prob * 100)% of the time
# /*----------------------------------------------------------------------------*/
# GAULFUNC boolean random_boolean_prob (const double prob)

# /*----------------------------------------------------------------------------*/
proc random_boolean_prob {prob} {

  set ret [expr {[random_rand] <= $prob * $::RANDOM_RAND_MAX}]

  return $ret

#   return (boolean)(random_rand() <= (unsigned int)(prob * (double)RANDOM_RAND_MAX));
# }
#-------------------------------------------------------------------------------

# некоторые мои функуции
# 
#-------------------------------------------------------------------------------
# rand() - возвращает случайное число с плавающей точкой в интервале [0.0 1.0]
#
# генерируем случайное целое из min-max (оба включены) интервала.
# 
# = myrand из файла a-comm.tl !!!!
#
#-------------------------------------------------------------------------------
proc common_rand {min max} {

  expr {$min + int(rand() * (($max-$min)+1))}

}
#-------------------------------------------------------------------------------
# генерируем случайное целое из min-max (оба включены) интервала.
#-------------------------------------------------------------------------------
proc myrand_new {min max} {

  incr max

  #puts "myrand_new: min= $min, max= $max"

  return [random_int_range  $min $max]
}
#-------------------------------------------------------------------------------
proc YRAND_new {imin imax} {


  return [myrand_new  $imin $imax]
}
#-------------------------------------------------------------------------------
proc rand_0_new {} {

  dotimes i 30 {

    #puts -nonewline [format "random_int_range (1 4)= %d \n" [myrand_new 1 4]]
    #puts -nonewline [format "random_int_range (1 4)= %s \n" [random_int_range 1 4]]
    #puts -nonewline [format "random_int_range (1 4)= %s \n" [random_int_range 1 5]] ;# ????????
    puts -nonewline [format "YRAND_new (1 4)= %s \n" [YRAND_new 1 5]]
  }

}
# /*----------------------------------------------------------------------------*/
# //  Return a random integer between 0 and (N-1) inclusive.
#
# GAULFUNC unsigned int random_int (const unsigned int max)
# /*----------------------------------------------------------------------------*/
proc random_int {max} {

#   /*
#     return (int)((double)random_rand()*max/RANDOM_RAND_MAX);
#     */

  #set ret [common_rand 0 [expr $max - 1]]

  if {$max == 0} {
    set ret 0
  } else {
    set ret [expr {[random_rand] % $max}]
  }

  #puts stderr [format "random_int :  ret = %d " $ret]

  return $ret

 #   return (max==0) ? 0 : random_rand()%max;
} 
# /*----------------------------------------------------------------------------*/
# //  Return a random integer between min and max-1 inclusive.
# /*----------------------------------------------------------------------------*/
# GAULFUNC int random_int_range (const int min, const int max)

# /*----------------------------------------------------------------------------*/
proc random_int_range {min max} \
{
  #   /*
  #     return (random_rand()*(max-min)/RANDOM_RAND_MAX + min);
  #     */
  
  set max_min [expr {$max - $min}]

  if {$max_min == 0} {

    return $max

  } else {

    return [expr {$min + ([random_rand] % $max_min)}]
  }
  
  #   return (max-min==0) ? max : min + (random_rand()%(max-min));
}
# /*----------------------------------------------------------------------------*/
# //  Return a random double within the allowed range.
# /*----------------------------------------------------------------------------*/
# GAULFUNC double random_double_full (void)
# {

#   return ( ((double)random_rand()/(double)RANDOM_RAND_MAX)*
#           (DBL_MAX-DBL_MIN)+DBL_MIN );
# }
# /*----------------------------------------------------------------------------*/
# //  Return a random double within the specified range.

# GAULFUNC double random_double (const double max)

#-------------------------------------------------------------------------------
proc  random_double {max} {

  #  return ( max * (((double) random_rand()) / (double) RANDOM_RAND_MAX) );

  set r [random_rand]

  set ret [expr {$max * ((1.0 * $r) / $::RANDOM_RAND_MAX)}]

  #if {$::is_print} {
  #  puts stderr "random_double : r = $r  ret = $ret"
  #  puts stderr ""
  #}

  return $ret
}
# /*----------------------------------------------------------------------------*/
# //  Return a random double within the specified range.
# /*----------------------------------------------------------------------------*/
# GAULFUNC double random_double_range (const double min, const double max)

# /*----------------------------------------------------------------------------*/
proc random_double_range {min max} {



  return [expr {($max - $min) * ((1.0 * [random_rand]) / $::RANDOM_RAND_MAX)  + $min}]

#   return ( (max-min) * (((double) random_rand()) / (double) RANDOM_RAND_MAX) + min );
}
# /*----------------------------------------------------------------------------*/
# //  Return a pseudo-random number with a uniform
# //	   distribution in the range 0.0=>r>1.0
# /*----------------------------------------------------------------------------*/
# GAULFUNC double random_unit_uniform (void)
# /*----------------------------------------------------------------------------*/
proc random_unit_uniform {} {

  set r [random_rand]

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
    
    set u [expr {2.0 * [random_unit_uniform] - 1.0}]
    set v [expr {2.0 * [random_unit_uniform] - 1.0}]

    set r [expr {$u * $u + $v * $v}]

    if {$r < 1.0} {break}
  }

  set fac  [expr {sqrt (-2.0 * log ($r) / $r)}]
  set dset [expr {$v * $fac}]

  return [expr  {$u * $fac}]
}
# /*----------------------------------------------------------------------------*/
# //  Randomize an array of integers.
# /*----------------------------------------------------------------------------*/
# GAULFUNC void 
# random_int_permutation (
#                         const int size, // 
#                         int    *iarray, // Source array.
#                         int    *oarray  // Destination array.
#                         )
# /*----------------------------------------------------------------------------*/
#proc random_int_permutation {size iarray  &oarray}
proc random_int_permutation {size &iarray  &oarray} \
{
  USE_REFS
  #upvar ${&iarray} iarray
  #upvar ${&oarray} oarray

  # int   i,j=0;    /* Loop variables over arrays. */
  # int   pos;	    /* Randomly selected index.    */

  set j 0
  
  #   if (!iarray || !oarray) die ("NULL pointer to int array passed.");
  
  for {set i [expr {$size - 1}]} {$i > 0} {incr i -1} \
  {
    set pos [random_int $i]

    #puts stderr [format "i = %2d  pos = %2d " $i  $pos]

    # oarray[j++] = iarray[pos];
    lappend oarray [lindex $iarray $pos]

    #  iarray[pos] = iarray[i];
    lset iarray $pos [lindex $iarray $i]
  }
  
  #   oarray[j] = iarray[0];
  lappend oarray [lindex $iarray 0]

  return
}
# /*----------------------------------------------------------------------------*/
proc permutation_test {} \
{

  #set ::simp_random 1  
  #set seed       2009
  random_init

  set ordered {1 2 3 4 5}
  set size 5
  set permutation {}

  puts ""
  puts "permutation_test: ordered     = $ordered"

  puts "permutation_test: "

  random_int_permutation  $size  ordered  permutation 

  puts "permutation_test: ordered     = $ordered"
  puts "permutation_test: permutation = $permutation"

  puts ""

  return
}
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
  
  #   random_init();
  
  puts ""
  puts "Testing random numbers."
  
  #   /*
  #     * Uniform Distribution.
  #     */
  
  puts "Uniform distribution.  Mean should be about 0.5."
  puts ""

  #   for (i=0;i<NUM_BINS;i++) bins[i] = 0;

  for {set i 0} {$i < $::NUM_SAMPLES} {incr i} {
  
    set r [random_unit_uniform]    
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
  return true ;#  // ????????
  #//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

}
# ------------------------------------------------------------------------------
proc test_random_seed {i} {

  random_seed $i ;# для random_rand (crossover) - a-comr.tl (c_random_util.c)

  mysrand $i     ;# для lrand (начальная инициация)

}
#-------------------------------------------------------------------------------
# возвращаем случайный элемент из списка 
#-------------------------------------------------------------------------------
proc lrand {list} {
    
  lindex $list [expr {int(rand()*[llength $list])}]
    
}
#-------------------------------------------------------------------------------
proc lrand_new {list} {
    
  set l [llength $list]

  set r [random_int $l]

  #set i [* $r ]

  #puts "l = $l r = $r"

  lindex $list $r
    
}
#-------------------------------------------------------------------------------
proc TEST_lrand {} {
    
  #set ll {1 2 3 4 5 6 7 8 9}
  #set ll {1 2 3 4 5}
  
  set ll {1 2 3 4 } ;# ???
  #set ll {1 2 } ;# 
 
 
  #-----------------------------------------------------
  test_random_seed 0 ;# in file a-comr.tl

  #random_seed $i ;# для random_rand (crossover) - a-comr.tl (c_random_util.c)
  #mysrand   0     ;# для lrand (начальная инициация)
  #-----------------------------------------------------

  puts ""

  for {set i 0} {$i < 10} {incr i} {

    puts "lrand     = [lrand $ll]"
  }

  puts ""

  #-----------------------------------------------------
  #random_seed 0     ;# для lrand (начальная инициация)

  # !!! тест дает странные (вырожденные) результаты для небольших списков !!
  # 

  puts ""

  for {set i 0} {$i < 10} {incr i} {

    puts "lrand_new = [lrand_new $ll]"
  }

  puts ""

  return
}
##-------------------------------------------------------------------------------
proc TEST_random_int {} {
    
  #-----------------------------------------------------
  #test_random_seed 0 ;# in file a-comr.tl

  #random_seed $i ;# для random_rand (crossover) - a-comr.tl (c_random_util.c)
  #mysrand   0     ;# для lrand (начальная инициация)
  #-----------------------------------------------------

  puts ""

  for {set i 0} {$i < 20} {incr i} {

    puts "[random_int 4]"
  }

  puts ""

  return
}
# /*----------------------------------------------------------------------------*/
# ./f~.tl TEST_lrand
# /*----------------------------------------------------------------------------*/
# /*----------------------------------------------------------------------------*/
