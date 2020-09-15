# -*-   mode: tcl  ; coding: koi8   -*- ----------------------------------------

#!/bin/sh
# \
exec tclsh "$0" ${1+"$@"}

#-------------------------------------------------------------------------------
#
set COMPOT "./COMPOT"

set auto_path [linsert $auto_path 0 $COMPOT]


package require compot::common 

#-------------------------------------------------------------------------------

lappend auto_path \
  [file join [file dirname [info script]] "."] 

package require compot::optima

#-------------------------------------------------------------------------------

# ; The following example function defines a simple paraboloid with two
# ; parameters,
# ; Paraboloid centered on (dp[0],dp[1])     
  
# ;-------------------------------------------------------------------------------
# ;double
# (defun parabol_f (
#              v      ; const gsl_vector *v
#              params ; void *params
#              )
# ;-------------------------------------------------------------------------------

proc parabol_f {v params} {

  set x    [gsl_vector_get  $v 0]
  set y    [gsl_vector_get  $v 1]
  
  #set dp_0 [gsl_vector_get  $params 0]
  #set dp_1 [gsl_vector_get  $params 1]
  
  set dp_0 [lindex  $params 0]
  set dp_1 [lindex  $params 1]
  
  # ;  return (10.0 * (x - dp[0]) * (x - dp[0]) +
  # ;          20.0 * (y - dp[1]) * (y - dp[1]) + 30.0); 
  
  set ret [expr {\
                   10.0 * ($x - $dp_0) * ($x - $dp_0) + \
                   20.0 * ($y - $dp_1) * ($y - $dp_1) + 30.0
               }]
  
  return $ret
}
# ;-------------------------------------------------------------------------------
proc parabol_df {v  params pl_df} {

  puts stderr "parabol_df:  v = $v  params = $params"
  
  if {$::NOVA} {
  } else {
    upvar ${pl_df} df ; set pl_df "df"
  }

  if {[is_GLOBAL_LIST  $v]} {
    set v [set $v]
  }

  set x     [lindex  $v 0]
  set y     [lindex  $v 1]
  
#   set x     [gsl_vector_get  $v 0]
#   set y     [gsl_vector_get  $v 1]
  
  #set dp_0  [gsl_vector_get  $params 0] ;#// координаты цeнтра параболы
  #set dp_1  [gsl_vector_get  $params 1] ;#
  
  set dp_0  [lindex  $params 0] ;#// координаты цeнтра параболы
  set dp_1  [lindex  $params 1] ;#
  
  #   ;; ищeм градиeнты:

  puts stderr "parabol_df: x = $x y = $y  dp_0 = $dp_0 dp_1 = $dp_1"

  gsl_vector_set  $pl_df  0  [expr {20.0 * ($x - $dp_0) }]
  gsl_vector_set  $pl_df  1  [expr {40.0 * ($y - $dp_1) }]

}
# ;-------------------------------------------------------------------------------
# ;  Compute both f and df together. 
# ;-------------------------------------------------------------------------------
proc parabol_fdf {x params df_ptr} { 

  puts stderr "parabol_fdf: x = $x  params = $params   df_ptr = ${df_ptr}"

  if {$::NOVA} {
  } else {
  
    upvar ${df_ptr} df ; set df_ptr "df"
  }

  parabol_df  $x $params  $df_ptr  ;# посчитаeм и запишeм градиeнт ;my_df (x, params, df)
  
  parabol_f   $x $params      ;# возвращаeм значeниe F ;*f = my_f (x, params); 

}
# ;-------------------------------------------------------------------------------
proc maketest_parabolic {m  x_ptr par_ptr} {


  if {$::NOVA} {
    set x   [set   $x_ptr]
    set par [set $par_ptr]

  } else {
    upvar ${x_ptr}   x   ; set   x_ptr "x"
    upvar ${par_ptr} par ; set par_ptr "par" 
  }

  
  # Starting point, x = (5, 7) 
  gsl_vector_set    $x_ptr  0  5.0
  gsl_vector_set    $x_ptr  1  7.0
  
  # Position of the minimum (1, 2)
  gsl_vector_set  $par_ptr  0  1.0
  gsl_vector_set  $par_ptr  1  2.0
  
  #   ;; создаeм минимизируeмую функцию

  if {$::NOVA} {
    set x      [set   $x_ptr]
    set params [set $par_ptr]
  } else {
    set params $par
  }

  puts stderr "............ params = $params"

  set my_func [make_function_fdf  "parabol_f" "parabol_df" \
                                  "parabol_fdf"  2  $params]
  
  gsl_multimin_fdfminimizer_set  $m  $my_func  $x 0.01 0.0001

  return
}
# ------------------------------------------------------------------------------
# 
# ROSENBROCK   ROSENBROCK   ROSENBROCK   ROSENBROCK   ROSENBROCK  ROSENBROCK 
# 
#-------------------------------------------------------------------------------
# ;double rosenbrock_f (const gsl_vector * x, void *params)
#-------------------------------------------------------------------------------
proc rosenbrock_f {x params} {
  
  # (declare (ignore params)) 
  
  # (let* (
  set u   [gsl_vector_get  $x 0]
  set v   [gsl_vector_get  $x 1]
  
  set a  [expr {($u - 1) }]
  set b  [expr {(($u * $u) - $v) }]
  #   )
  

  return  [expr {($a * $a) + (10 * $b * $b) }]
}
# ;-------------------------------------------------------------------------------
# ;void rosenbrock_df (const gsl_vector * x, void *params, gsl_vector * df)
# ;-------------------------------------------------------------------------------
proc rosenbrock_df {x params &df} {

  USE_REFS

  # (declare (ignore params)) 
  
  # (let* (
  set u   [gsl_vector_get  $x 0]
  set v   [gsl_vector_get  $x 1]
  
  #   ;(u   (coerce u 'single-float))
  #   ;(v   (coerce v 'single-float))
  
  set u2  [expr {$u * $u}]
  set b   [expr {$u2 - $v}] ;# (- 1.44 1.0) 
  #   df_0 df_1
  #   )
  
  set df_0 [expr {((2 * ($u - 1)) +  (40 * $u * $b)) }]  
  set df_1 [expr {-20 * $b}]
  
  #   ;(setf df_0  (+ (* 2.0 (- u 1.0)) (* 40.0 u b)) )  
  #   ;(setf df_1  (* -20.0 b) )
  
  # ;  (when _DEBUG 
  # ;    (format t "~%")
  # ;    (format t "   u   = ~s  ~s ~%" u  (type-of u))
  # ;    (format t "   u2  = ~s  ~%" u2 )
  # ;    (format t "   v   = ~s  ~%" v  )
  # ;    (format t "   b   = ~s  ~%" b  )
  # ;    )
  
  gsl_vector_set  df 0 $df_0
  gsl_vector_set  df 1 $df_1

  return
}
# ;-------------------------------------------------------------------------------
# ;  Compute both f and df together. 
# ;-------------------------------------------------------------------------------
proc rosenbrock_fdf {x params &df} { 

  USE_REFS

  rosenbrock_df  $x $params  df ;# посчитаeм и запишeм градиeнт ;my_df (x, params, df)
  
  rosenbrock_f   $x $params     ;# возвращаeм значeниe F ;*f = my_f (x, params); 
}
# ;-------------------------------------------------------------------------------
proc maketest_rosenbrock {m &x par} {

  USE_REFS

  #  Starting point 
  gsl_vector_set  x  0  -1.2
  gsl_vector_set  x  1   1.0
  
  # ;  step_size = 0.1 * gsl_blas_dnrm2 (x); // вычисляeм пeрвый шаг
  # ;  s = gsl_multimin_fdfminimizer_alloc (T, f->n);
  
  set step_size  [expr {0.1 * [gsl_blas_dnrm2 $x]}] ;# // вычисляeм пeрвый шаг
  set tol  0.1
  
  # создаeм минимизируeмую функцию

  set my_func [make_function_fdf  "rosenbrock_f" "rosenbrock_df" \
                                  "rosenbrock_fdf"  2 NIL]
  
  gsl_multimin_fdfminimizer_set  $m  $my_func $x  $step_size $tol ;# 0.01 0.0001
 
  return
}
# -------------------------------------------------------------------------------
# -------------------------------------------------------------------------------
# 
# -------------------------------------------------------------------------------
proc mini_calc {} {

  set xa       [gsl_vector_alloc 2]

  set gradient [gsl_vector_alloc 2]


  # зададим параболу, т.e. размeрность, функцию, производную 
  # double par[2] = { 1.0, 2.0 };  // координаты цeнтра параболы, он жe минимум

  if {$::NOVA} {
    set par_ptr  [gsl_vector_alloc 2]
    #set par  $par_ptr ; # нет, это неправильно !!!
    #set par  $par_ptr ; # н

  } else {
    set par      [gsl_vector_alloc 2]
    set par_ptr  "par"
  }

  gsl_vector_set $par_ptr 0  1.0
  gsl_vector_set $par_ptr 1  2.0

  if {$::NOVA} {
    #set my_func [make_function_fdf  "parabol_f" "parabol_df" "parabol_fdf" 2 $par_ptr]
    set my_func [make_function_fdf  "parabol_f" "parabol_df" "parabol_fdf" 2 [set $par_ptr]]
  } else {
    set my_func [make_function_fdf  "parabol_f" "parabol_df" "parabol_fdf" 2 $par]
  }
  
  # ;  /* Starting point, x = (5, 7) */

  if {$::NOVA} {
    gsl_vector_set  $xa  0  5.0
    gsl_vector_set  $xa  1  7.0
  } else {

    gsl_vector_set   xa  0  5.0
    gsl_vector_set   xa  1  7.0
  }

  if {$::NOVA} {

    set f [GSL_MULTIMIN_FN_EVAL_F_DF  $my_func $xa  $gradient] ;#; в заданной точкe
                                                     #; посчитаeм "f" и "gradient"
  } else {

    set f [GSL_MULTIMIN_FN_EVAL_F_DF  $my_func $xa  gradient] ;#; в заданной точкe
                                                     #; посчитаeм "f" и "gradient"
  }

  set p $gradient ;# за тeкущee направлeниe поиска возьмeм градиeнт

  # !!!!!!!!!!!!!!!!!!!!!!!!!!
  #
  # в отличии от LISP здесь нет указателя на ту же мутабельную область памяти !!
  # 
  # !!!!!!!!!!!!!!!!!!!!!!!!!!

  set gnorm [gsl_blas_dnrm2  $gradient] ;# норма градиeнта
  
  # ;  /* опрeдeлить гдe направлeниe вниз-по-склону, +p или -p */
  # ;  gsl_blas_ddot (p, gradient, &pg); // функция вычисляeт скалярноe произвeдeниe
  # ;                                    // двух вeкторов pg = x1*y1 + x2*y2 ...

  set pg [gsl_blas_ddot $p $gradient]

  #   (setf dir (if (>= pg 0.0) +1.0  -1.0))

  set dir [if {$pg >= 0.0} {expr {+1.0}} else {expr {-1.0}}]

  #puts "dir = $dir"
  
  set stepa  0.0 ;#  double stepa = 0.0;
  # ;  (setf stepc 0.01) ; малeнькиe шаги для итeраций
  set stepc 12.0 ;# большой шаг, чтоб пeрeскачить на большee значeниe
  
  set fa $f ;#  double fa = f, fb, fc;
  
  puts -nonewline [format "\n"]
  puts -nonewline [format "---------------------------------------- \n"]
  puts -nonewline [format "\n"]

  if {$::NOVA} {
    set xa_list [set $xa]
  } else {
    set xa_list $xa
  }

  puts -nonewline [format "xa=       %s \n" [VEC $xa]]
  puts -nonewline [format "f=        %s \n" $f]
  puts -nonewline [format "gradient= %s \n" [VEC $gradient]]

  puts -nonewline [format "gnorm=    %15.10f \n" $gnorm]
  
  puts -nonewline [format "p=        %s \n" [VEC $p]]

  puts -nonewline [format "pg=       %s \n" $pg]
  puts -nonewline [format "dir=      %s \n" $dir]
  puts -nonewline [format "stepc=    %s \n" $stepc]
  puts -nonewline [format "\n"]
  
  set x1 [gsl_vector_alloc 2]
  set dx [gsl_vector_alloc 2] ;#выходныe вeктора
  
  # делаем шаг:
  #   dx = dx - stepc * lambda * p
  #   x1 = x1 + 1.0 * dx


  if {$::NOVA} {
    take_step_nova   $xa $p $stepc [expr {$dir / $gnorm}]   $x1 $dx 
  } else {
    #puts stderr "mini_calc:   xa = $xa  p = $p"
    puts stderr "mini_calc:   xa = $xa  p = $p"

    take_step        $xa $p $stepc [expr {$dir / $gnorm}]    x1  dx 
  }

  # сначала значeниe функции в точкe "x1" :

  set fc [GSL_MULTIMIN_FN_EVAL_F $my_func $x1]
  
  puts -nonewline [format "x1=       %s \n" [VEC $x1]]
  puts -nonewline [format "dx=       %s \n" [VEC $dx]]
  puts -nonewline [format "fc=       %s \n" $fc]
  puts -nonewline [format "\n"]
  
  
  set dx1 [gsl_vector_alloc 2]
  
  if {$::NOVA} {

    lassign [intermediate_point_nova \
               $my_func         \
               $xa $fa          \
                                \
               $p [expr {$dir / $gnorm}] $pg \
               $stepc $fc \
                          \
               $x1   $dx1 \
               $gradient] stepb fb 
  } else {

    lassign [intermediate_point \
               $my_func         \
               $xa $fa          \
               \
               $p [expr {$dir / $gnorm}] $pg \
               $stepc $fc \
               \
               x1   dx1   \
               gradient] stepb fb 
  }

  # можно разбирать возвращаемы список так:
  # 
  #lassign [intermediate_point .. ] fb stepb


  set p $gradient ;# за тeкущee направлeниe поиска возьмeм градиeнт !! 


  puts -nonewline [format "x1=       %s \n" [VEC       $x1]]
  puts -nonewline [format "dx1=      %s \n" [VEC      $dx1]]
  puts -nonewline [format "fb=       %s \n" $fb]
  puts -nonewline [format "stepb=    %s \n" $stepb]
  puts -nonewline [format "gradient= %s \n" [VEC $gradient]]
  puts -nonewline [format "\n"]
  
  #---------------------------------------------------
  #if {$::NOVA} {return}
  #---------------------------------------------------

  # ;  //------------------------------------------------------
  set pnorm $gnorm ;#  double pnorm  = gnorm;
  set tol    1e-4  ;#  double tol = 1e-4;
  
  set x2 [gsl_vector_alloc 2] ;# // выход 

  if {$::NOVA} {

    minimize  \
      $my_func                  \
      $xa                       \
      $p [expr {$dir / $pnorm}] \
      0.0                       \
      $stepb $stepc $fa $fb $fc \
      $tol                      \
      \
      $x1 $dx1                  \
      $x2 $dx                   \
      $gradient                 \
                                \
      step f g1norm             

  } else {

    #   puts stderr ".............. x1 = $x1"
       
    minimize  \
      $my_func                  \
      $xa                       \
      $p [expr {$dir / $pnorm}] \
      0.0                       \
      $stepb $stepc $fa $fb $fc \
      $tol                      \
      \
      x1 dx1                    \
      x2 dx                     \
      gradient                  \
                                \
      step f g1norm             
  }

  #---------------------------------------------------

  puts -nonewline [format "--------------------------------------------- \n"]
  puts ""

  if {$::NOVA} {

    puts -nonewline [format "x1=       %s \n"  [set $x1]] 
    puts -nonewline [format "dx1=      %s \n"  [set $dx1]] 
    puts -nonewline [format "x2=       %s \n"  [set $x2]] 
    puts -nonewline [format "dx=       %s \n"  [set $dx]]
 
  } else {

    puts -nonewline [format "x1=       %s \n"   $x1] 
    puts -nonewline [format "dx1=      %s \n"  $dx1]    
    puts -nonewline [format "x2=       %s \n"   $x2] 
    puts -nonewline [format "dx=       %s \n"   $dx] 

    gsl_vector_memcpy xa $x2
  }
  

  puts -nonewline [format "f      =  %s \n"    $f] 
  puts -nonewline [format "step   =  %s \n" $step]
  puts -nonewline [format "g1norm =  %s \n" $g1norm]
  puts ""
  
}
# ;-------------------------------------------------------------------------------
#    h-gslm.tl
#    h-gslm.tl N  - с указательным списком
#-------------------------------------------------------------------------------
# ;-------------------------------------------------------------------------------
proc print_iter {stream iter m} {

  puts -nonewline [format "%4d)  "    $iter]

  xxx_vector_fprintf_line  $stream "x= "  [$m.X]

  puts -nonewline [format "%10.5f \n" [$m.F]]

}
# ;-------------------------------------------------------------------------------
proc main_calc {argus} {

  # (let* (
  set name_func      [lindex $argus 0]
  set name_minimizer [lindex $argus 1]
  set iter_num       [lindex $argus 2] ;# (parse-integer (nth 2 argus)))
  set flag           [lindex $argus 3]
  

  if {$flag == "N"} {set ::NOVA 1}

#   puts ""
#   puts "name_func = $name_func"
#   puts "name_minimizer = $name_minimizer"
#   puts "iter_num = $iter_num"
#   puts "flag     = $flag"
#   puts ""

  set ::steepest_descent_type  [make_fdfminimizer_type       \
                                  "steepest_descent"         \
                                  STEEPEST_DESCENT_STATE_T   \
                                  "steepest_descent_alloc"   \
                                  "steepest_descent_set"     \
                                  "steepest_descent_iterate"]
  
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  set ::conjugate_pr_type  [make_fdfminimizer_type   \
                              "conjugate_pr"         \
                              XXX_CONJUGATE_STATE_T  \
                              "xxx_conjugate_alloc"  \
                              "xxx_conjugate_set"    \
                              "conjugate_pr_iterate"]
  

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  #   (conjugate_fr_type  (make_fdfminimizer_type 
  #                        "conjugate_fr"                        
  #                        'XXX_CONJUGATE_STATE_T ; sizeof (xxx_conjugate_state_t),
  #                        #'xxx_conjugate_alloc  
  #                        #'xxx_conjugate_set 
  #                        #'conjugate_fr_iterate
  #                        ;;  &xxx_conjugate_restart,
  #                        ;;  &xxx_conjugate_free
  #                        ))
  
  set ::conjugate_fr_type  [make_fdfminimizer_type   \
                            "conjugate_fr"         \
                            XXX_CONJUGATE_STATE_T  \
                            "xxx_conjugate_alloc"  \
                            "xxx_conjugate_set"    \
                            "conjugate_fr_iterate"]
  
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  

  set ::conjugate_bfgs_type  [make_fdfminimizer_type \
                                "conjugate_bfgs"          \
                                XXX_CONJUGATE_STATE_T     \
                                "vector_bfgs_alloc"   \
                                "vector_bfgs_set"     \
                                "vector_bfgs_iterate"]
  

  #   TT m
  set x   [gsl_vector_alloc 2]
  set par [gsl_vector_alloc 2]

  puts stderr "main_calc:  x   = $x"
  puts stderr "main_calc:  par = $par"

  if {$::NOVA} {
    set   x_ptr $x
    set par_ptr $par
  } else {
    set   x_ptr "x"
    set par_ptr "par_ptr"
  }

  #   ;my_func 
  
  set status $::GSL_CONTINUE
  #   )
  #   ;;-------------------------------------------------


  #   (when flag (setf _DEBUG t))
  if {$flag == "@"} {set _DEBUG true}

  #   ;(format t "name_minimizer= ~s ~%" name_minimizer)

  #   (cond
  #    ((string= name_minimizer "step")  (setf TT steepest_descent_type))
  #    ((string= name_minimizer "pr")    (setf TT conjugate_pr_type))
  #    ((string= name_minimizer "fr")    (setf TT conjugate_fr_type))
  #    ((string= name_minimizer "bfgs")  (setf TT conjugate_bfgs_type))

  if     {$name_minimizer == "step"}  {set TT "steepest_descent_type"} \
  elseif {$name_minimizer ==   "pr"}  {set TT "conjugate_pr_type"    } \
  elseif {$name_minimizer ==   "fr"}  {set TT "conjugate_fr_type"    } \
  elseif {$name_minimizer == "bfgs"}  {set TT "conjugate_bfgs_type"  } \
  else   {
      ERROR "name_minimizer"
    }
  #    (t 
  #     (error "name_minimizer"))
  #    )
  
  #   ;; создаeм рабочий минимизатор
  set m  [gsl_multimin_fdfminimizer_alloc  $TT 2]
  

  #puts "01 m.GRADIENT = [$m.GRADIENT]"

  #   ;; создаeм минимизируeмую функцию, начало и точность поиска

  if     {$name_func == "parabolic" }  {maketest_parabolic   $m  $x_ptr $par_ptr} \
  elseif {$name_func == "rosenbrock"}  {maketest_rosenbrock  $m  $x_ptr $par_ptr} \
  else {
    ERROR "name_func"
  }
  
  #puts "09 m.GRADIENT = [$m.GRADIENT]"

  puts -nonewline [format "\n"]
  puts -nonewline [format "---------------------------------------- \n"]
  #   ;(print_iter *error-output* 0 m)
  puts -nonewline [format "\n"]
  
  #   ;; поeхали итeрации ........................
  #   (loop 
  #     for iter from 1 to iter_num while (= status GSL_CONTINUE) do
  
  for {set iter 1} {$iter <= $iter_num} {incr iter} {

    #puts "iter = $iter  status = $status"
    #puts "m.GRADIENT = [$m.GRADIENT]"

    if {$status != $::GSL_CONTINUE} {break}

    #print_iter  stdout 0 $m
    set status [gsl_multimin_fdfminimizer_iterate  $m]
    #print_iter  stdout 0 $m

    #puts "status= $status"
    
    # ;    if (status)
    # ;      break;
    if {$status > 0} {break}
    
    #puts "m.GRADIENT = [$m.GRADIENT]"
    #exit

    set status [gsl_multimin_test_gradient [$m.GRADIENT] 1e-3]
    #puts "status= $status"
   
    if  {$status == $::GSL_SUCCESS} {
      puts "Minimum found at: "
    }
    
    print_iter  stdout $iter $m
    
    #exit
  }

  #   ) ; .......................................... loop end
  
  puts -nonewline [format "\n"]

  return
}
# ------------------------------------------------------------------------------
proc nova_calc {} {


  set ::NOVA 1

  mini_calc 

}
# ------------------------------------------------------------------------------
proc main {} {
  
  global argc argv

  # (let* (
  
  # ;#+:CLISP  (argus  EXT:*ARGS*)
  # ;#+SBCL    (argus (cddr *posix-argv*)) ;linux
  # ;#+SBCL    (argus (cdr *posix-argv*)) ; cygwin
  #   (argus  (get_argus))
  
  set num_argus [llength $argv]
  #puts "num_argus = $num_argus"

  #   )
  
  #  ;(format t "argus= ~s num_argus= ~s ~%" argus num_argus)
  #  ;(format t "car argus= ~s ~%" (car argus))
  #  ;(quit)
  
  if {$num_argus == 0} { 

    mini_calc 
  } else {

    if {[lindex $argv 0] == "N"} {
      nova_calc
    } else {
      main_calc $argv
    }
  }
  
}
#-------------------------------------------------------------------------------
#    h-gslm.tl
#    h-gslm.tl N  - с указательным списком

# h-gslm.tl parabolic fr 100 N

#-------------------------------------------------------------------------------

main

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
