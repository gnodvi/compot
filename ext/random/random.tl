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
#-------------------------------------------------------------------------------
proc math_random_seed {seed} {

  # if {$seed == 0} {
  #   set seed [Y-time 0] ;# // переменная псевдослучайность
  # } 

  expr {srand($seed)}

}
# ;-------------------------------------------------------------------------------
# srandom_set -> math_random_seed_null 
proc math_random_seed_null {seed} {

  if {$seed == 0} {
    set seed [Y-time 0] ;# // переменная псевдослучайность
  } 

  #   if {$seed == 0} {
  
  #     set ret [math_random_seed [Y-time 0]] ;# // переменная псевдослучайность
  #   } else {
  #     set ret [math_random_seed $seed]      ;# // фиксированная 
  #   }

  return [math_random_seed $seed]
  #return $ret
}
# ;-------------------------------------------------------------------------------
proc Y-random {} {

  ##set r [myrand 0 $::MAXRANDOM]

  set r  [math_random_int_minmax  0 $::MAXRANDOM]

  return $r
}
# ;===============================================================================
# ;
# ; нe систeмныe (производныe утилиты-функции)
# ;

# (defvar *debug_print*  nil)

set ::debug_print 0
set ::simp_random 0

# ;-------------------------------------------------------------------------------
proc  YRandF {fmin fmax} {

  set choise [expr {1.0 * [_RandomRange $::MAXRANDOM] / $::MAXRANDOM}]

  set ret [expr {($fmin + ($choise * ($fmax - $fmin)))} ]

  return $ret
}
# ;-------------------------------------------------------------------------------
# proc YRAND_S {} {

#   srandom_set -1
# }
# ;-------------------------------------------------------------------------------
proc YRAND_C {} {

  math_random_seed_null 2010
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
proc  random-value {max_value} {

  set r [YRandF 0 $max_value]
  
  set ret [expr {$max_value - (2 * $r)}]

  #puts "  random-value: max_value= $max_value r= $r ret= $ret"
  
  return $ret

}
# ;-------------------------------------------------------------------------------
proc random_in_interval {fmin fmax} {

  
  set r [YRandF $fmin $fmax]

  return $r
}
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
#-------------------------------------------------------------------------------
#
# rand() - возвращает случайное число с плавающей точкой в интервале [0.0 1.0]
#
# генерируем случайное целое из min-max (оба включены) интервала.
#-------------------------------------------------------------------------------
proc math_random_int_minmax {min max} {

  expr {$min + int(rand() * (($max-$min)+1))}

}
#-------------------------------------------------------------------------------
proc myrand {min max} {

 # expr {$min + int(rand() * (($max-$min)+1))}

  return [math_random_int_minmax $min $max]
}
#-------------------------------------------------------------------------------
# генерируем случайное целое из min-max (оба включены) интервала.
#-------------------------------------------------------------------------------
proc myrand_new {min max} {

  incr max

  return [comm_random_int_range  $min $max]
}
#-------------------------------------------------------------------------------

alias comm_random_int_minmax myrand_new

#-------------------------------------------------------------------------------
# proc YRAND_new {imin imax} {


#   #return [myrand_new  $imin $imax]
#   return [comm_random_int_minmax  $imin $imax]
# }
#-------------------------------------------------------------------------------
# TODO: 
#       test_random_seed -> comm_random_seed !! везде !!

# ------------------------------------------------------------------------------
proc comm_random_seed {i} {

  gaul_random_seed $i  ;# для random_rand (crossover) - a-comr.tl (c_random_util.c)

  math_random_seed $i  ;# для lrand (начальная инициация)

  ##knut_random_seed $i
}
#-------------------------------------------------------------------------------

alias  comm_random_int_permutation  gaul_random_int_permutation

# Return a random integer between min and max-1 inclusive.
alias  comm_random_int_range        gaul_random_int_range

# Return a random integer between 0 and (N-1) inclusive.
alias  comm_random_int              gaul_random_int

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
  
  math_random_seed_null $seed
  rand_0  ;# вызов вeрхнeго тeста 
  
  puts ""
  
  math_random_seed_null $seed
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
  
  #YRAND_F
  puts [format "v= %s  " [YRandF $vmin $vmax]]
  
  #YRAND_F
  puts [format "v= %s  " [YRandF $vmin $vmax]]
  
  puts ""
}
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
proc lrand {list} {
    
  lindex $list [expr {int(rand()*[llength $list])}]
    
}
#-------------------------------------------------------------------------------
proc lrand_new {list} {
    
  set l [llength $list]

  set r [comm_random_int $l]

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
  comm_random_seed 1 ;# 0 ;# in file a-comr.tl

  #-----------------------------------------------------

  puts ""

  for {set i 0} {$i < 10} {incr i} {

    puts "lrand     = [lrand $ll]"
  }

  puts ""

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
##-------------------------------------------------------------------------------
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
# /*----------------------------------------------------------------------------*/
