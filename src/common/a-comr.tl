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


#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
# генерируем случайное целое из min-
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


#source "../../ext/random/g-rand.tl"
#source "g-rand.tl"


#-------------------------------------------------------------------------------
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
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
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
