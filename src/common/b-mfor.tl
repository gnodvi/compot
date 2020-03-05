# -*-   mode: tcl  ; coding: koi8   -*- ----------------------------------------


#-------------------------------------------------------------------------------
#
#-------------------------------------------------------------------------------
proc ijk_array_make {num {val "@"}} {

  set g_name [MAKE_GLOBAL_NAME] ;# получили глобальное имя (ссылку)

  for {set i 0} {$i < $num} {incr i} {

    lappend $g_name $val
  }

  return $g_name ;# возвращаем имя списка (глобальную ссылку)
}
# ;;;-----------------------------------------------------------------------------
proc ijk_array_set {&ijk value} {

  #USE_REFS
  #upvar $ijk_REF ijk 
  upvar ${&ijk} ijk 

  dotimes index [llength $ijk] {
  
    #     (setf (aref ijk index) value)
    lset ijk $index  $value
  }
  
}
# ;;;-----------------------------------------------------------------------------
proc ijk_array_print {name ijk} {

  puts -nonewline "$name  "

  dotimes index [llength $ijk] {

    puts -nonewline "[lindex $ijk $index] "
  }

  puts ""
}
# ;;;-----------------------------------------------------------------------------
proc ijk_array_incr {&ijk cur} {

  #USE_REFS
  #upvar $ijk_REF ijk 
  upvar ${&ijk} ijk 

  # dotimes index [llength $ijk] {  
  #     (setf (aref ijk index) value)
  #lset ijk $index  $value
  #}

  lset ijk $cur [expr {[lindex $ijk $cur] + 1}]
  
}
# ;;;-----------------------------------------------------------------------------
proc ijk_get {ijk_REF i} {

  upvar $ijk_REF ijk 

  
  return [lindex $ijk $i]

}
# ;;;=============================================================================


#record define MF {

#}

#     IJK
#     dim 
#     ijk_cur
#     index

# ;-------------------------------------------------------------------------------
# ;;;-----------------------------------------------------------------------------
proc MFOR_create_1 {dim ijk_cur IJK} {

  # (let* (
  #   mf
  #   )
  
  #   ;; создадим новую пструктуру
  #   (setf mf (make-MF))
  #set mf [MF \#auto]

  set mf [dict_create]

  #set mf [MAKE_GLOBAL_NAME] ;# получили глобальное имя (ссылку)
  #set mf [MF new]

  
  #   ;; занесем в нее готовые массивы

  #$mf.dim     =  $dim
  dict set $mf "dim" $dim 
  #set ::dim    $dim

  #dict set $mf "dim_1" $::dim_1 
  #dict set $mf "dim_1" [expr {$dim - 1}] ;# интересно, что оно делает?

  set ::dim_1  [expr {$dim - 1}] ;# особо не влияет такое "ускорение"
  #$mf dim_1__SET [expr {$dim - 1}]

  #$mf.IJK     =  $IJK
  set ::IJK    $IJK
  #$mf IJK__SET $IJK

  set ::ijk_cur    $ijk_cur
  #$mf ijk_cur__SET $ijk_cur
  
  dotimes index [llength $ijk_cur] { 
 
    #set ::ijk($index) [lindex $ijk_cur $index]

  }

  #   ;(MFOR_init mf)
  
  return $mf
}
# ;;;-----------------------------------------------------------------------------
# proc MFOR_create_2 {dim ijk_cur IJK} {

#   # (let* (
#   #   mf
#   #   )
  
#   #   ;; создадим новую пструктуру
#   #   (setf mf (make-MF))
#   #set mf [MF \#auto]

#   #set mf [dict create]
#   #set mf [g_get_unicum_name] ;# получили глобальное имя (ссылку)

#   set mf [MF new]

  
#   #   ;; занесем в нее готовые массивы

#   #$mf.dim     =  $dim
#   #dict set $mf "dim" $dim 
#   #set ::dim    $dim

#   #set ::dim_1  [expr {$dim - 1}] ;# особо не влияет такое "ускорение"
#   #dict set $mf "dim_1" $::dim_1 
#   #dict set $mf "dim_1" [expr {$dim - 1}] ;# интересно, что оно делает?

#   $mf dim_1__SET [expr {$dim - 1}]

#   #$mf.IJK     =  $IJK
#   #set ::IJK    $IJK
#   $mf IJK__SET $IJK

#   $mf ijk_cur__SET $ijk_cur
#   #set ::ijk_cur    $ijk_cur
  
#   dotimes index [llength $ijk_cur] {  
#     set ::ijk($index) [lindex $ijk_cur $index]

#   }


#   #   ;(MFOR_init mf)
  
#   return $mf
# }
# ;;;-----------------------------------------------------------------------------
proc MFOR_init_1 {mf} {


  #$mf first__SET 1
  set ::first 1
  #$mf.index  = -1 ;# чтобы первым был нуль
  
  #ijk_array_set [$mf vget -ijk_cur] 0
  #ijk_array_set ::ijk_cur 0
  #$mf ijk_cur__SET 0 ;# это простой индекс !!

  set ::cur $::dim_1
  #set ::cur 0

}
# ;;;-----------------------------------------------------------------------------
# proc MFOR_init_2 {mf} {


#   $mf first__SET 1
#   #$mf.index  = -1 ;# чтобы первым был нуль
  
#   #ijk_array_set [$mf vget -ijk_cur] 0
#   #ijk_array_set ::ijk_cur 0
#   #$mf ijk_cur__SET 0 ;# это простой индекс !!

# }
# ;;;-----------------------------------------------------------------------------
#proc MFOR_r {cur &ijk_cur IJK} {}
#proc MFOR_r {cur &ijk_cur IJK} {}
# proc MFOR_r_2 {mf cur ijk_cur IJK} {

#   set IJK [$mf IJK__GET]

#   #USE_REFS ;# может этот перебор переменных тормозит ?!!!!!!!!!!!!!!!!!!!!!!!!!!!
#   # 
#   #upvar $ijk_cur_REF ijk_cur ;# здесь тчоно в 2.5 раза тормозит !!
#   #upvar ${&ijk_cur} ijk_cur 

#   # просто увеличиваем значение текущего индекса


#   #lset ijk_cur $cur [expr {[lindex [set ${ijk_cur}] $cur] + 1}] 
#   lset $ijk_cur $cur [expr {[lindex [set $ijk_cur] $cur] + 1}] 

#   # 
#   #ijk_array_incr ijk_cur $cur ;# уже приилчно  увеличиваем !! 
#   #                              может upvar долго так работает ??

#   #incr ::ijk($cur) ;# сука ! увеличивает !

  
#   if {! ([lindex [set $ijk_cur] $cur] == [lindex $IJK $cur])} { 
#     #if {! ([ijk_get ijk_cur $cur] == [lindex $IJK $cur])} { }  ;# тоже увеличивает!

#     return 1 ;#       T ; просто уходим, если нет еще границы

#   } else {
#     #     ;; дошли до максимума, значит надо к след. индексу переходить
       
#     if {$cur == 0} { ;# однако, если это был последний (левый) индекс,

#       return 0 ;# NIL       ; то конец

#     } else {
#       #       (setf (aref ijk_cur cur) 0) ; обнуляем текущий индекс
#       #lset ijk_cur $cur   0 ;# обнуляем текущий индекс
#       lset $ijk_cur $cur   0 ;# обнуляем текущий индекс

#       #set ::ijk($cur) 0  - а он вообще зачем???
      
#       #       ;; и начинаем крутить индекс левее
#       #       ;; а что же при этом с правыми происходит?  ну мы же возвращаемся каждый раз

#       return [MFOR_r_2 $mf  [expr {$cur - 1}]  $ijk_cur $IJK]
#     }   
#   }
  
# }
# ;;;-----------------------------------------------------------------------------
#proc MFOR_r {cur &ijk_cur IJK} {}
#proc MFOR_r {cur &ijk_cur IJK} {}
#proc MFOR_r_1 {mf cur ijk_cur IJK} {}
#proc MFOR_r_1 {mf cur } {}
proc MFOR_r_1 {mf cur} {

  #puts "cur = $::cur"
  set ::cur $cur

  #set cur $::cur
  #set IJK [$mf IJK__GET]

  #USE_REFS ;# может этот перебор переменных тормозит ?!!!!!!!!!!!!!!!!!!!!!!!!!!!
  # 
  #upvar $ijk_cur_REF ijk_cur ;# здесь тчоно в 2.5 раза тормозит !!
  #upvar ${&ijk_cur} ijk_cur 

  # просто увеличиваем значение текущего индекса

  #lset ijk_cur $cur [expr {[lindex [set ${ijk_cur}] $cur] + 1}] 
  #lset $ijk_cur $cur [expr {[lindex [set $ijk_cur] $cur] + 1}] 
  #lset $::ijk_cur $cur [expr {[lindex [set $::ijk_cur] $cur] + 1}]
 
  lset $::ijk_cur $::cur [expr {[lindex [set $::ijk_cur] $::cur] + 1}] 

  # 
  #ijk_array_incr ijk_cur $cur ;# уже приилчно  увеличиваем !! 
  #                              может upvar долго так работает ??

  #incr ::ijk($cur) ;# сука ! увеличивает !

  
  #if {! ([lindex [set $ijk_cur] $cur] == [lindex $IJK $cur])} {}
  if {! ([lindex [set $::ijk_cur] $::cur] == [lindex $::IJK $::cur])} { 

    #if {! ([ijk_get ijk_cur $cur] == [lindex $IJK $cur])} { }  ;# тоже увеличивает!

    #return 1 ;#       T ; просто уходим, если нет еще границы

  } else {
    #     ;; дошли до максимума, значит надо к след. индексу переходить
       
    if {$::cur == 0} { ;# однако, если это был последний (левый) индекс,

      return 0 ;# NIL       ; то конец

    } else {
      #       (setf (aref ijk_cur cur) 0) ; обнуляем текущий индекс
      #lset ijk_cur $cur   0 ;# обнуляем текущий индекс
      lset $::ijk_cur $::cur   0 ;# обнуляем текущий индекс

      incr ::cur -1
      #puts "cur = $::cur"

      #set ::ijk($cur) 0  - а он вообще зачем???
      
      #       ;; и начинаем крутить индекс левее
      #       ;; а что же при этом с правыми происходит?  ну мы же возвращаемся каждый раз

      #return [MFOR_r_1 $mf  [expr {$cur - 1}]  $ijk_cur $IJK]

      #return [MFOR_r_1 $mf  [expr {$cur - 1}] ]
      return [MFOR_r_1 $mf $::cur]
    }   
  }
  
  return 1 ;#       T ; просто уходим, если нет еще границы
}
# ;;;-----------------------------------------------------------------------------
proc MFOR_todo_1 {mf} {


  #incf [$mf vget -index]  ;# просто увеличиваем порядковый индекс вызова 
  

  #if {[$mf first__GET]} {} ;# самый первый этап с нулевыми значениями нужно выделить:
  if {$::first} { ;# самый первый этап с нулевыми значениями нужно выделить:
   
    #$mf first__SET 0 ;# NIL
    set ::first 0 ;# NIL

    return 1 ;#   T ; просто ничего не делая уходим 
    
  } else {

    #     ;; иначе
    #     ;; увеличиваем сначала правый индекс и при необходимости сдвигаемся влево
    
    #     (MFOR_r  (- (MF-dim mf) 1)  (MF-ijk_cur mf) (MF-IJK mf))

   # return [MFOR_r  [expr {[$mf.dim] - 1}]  [$mf vget -ijk_cur]  [$mf.IJK] ]
   # return [MFOR_r  [expr {[$mf.dim] - 1}]  ::ijk_cur  [$mf.IJK] ]

    #return [MFOR_r  [expr {$::dim - 1}]  ::ijk_cur  [$mf.IJK] ]
    #return [MFOR_r  $::dim_1  ::ijk_cur  [$mf.IJK] ]

    #set ijk

    # return [MFOR_r_1 $mf  [$mf dim_1__GET]  [$mf ijk_cur__GET]  [$mf IJK__GET] ]
    #return [MFOR_r_1  $mf $::dim_1]

    return [MFOR_r_1  $mf $::dim_1] ;# каждый раз начинаем просматривать справа!!!
  }
}
# ;;;-----------------------------------------------------------------------------
# proc MFOR_todo_2 {mf} {


#   #incf [$mf vget -index]  ;# просто увеличиваем порядковый индекс вызова 
  

#   if {[$mf first__GET]} { ;# самый первый этап с нулевыми значениями нужно выделить:
   
#     $mf first__SET 0 ;# NIL
#     #set ::first 0 ;# NIL

#     return 1 ;#   T ; просто ничего не делая уходим 
    
#   } else {

#     #     ;; иначе
#     #     ;; увеличиваем сначала правый индекс и при необходимости сдвигаемся влево
    
#     #     (MFOR_r  (- (MF-dim mf) 1)  (MF-ijk_cur mf) (MF-IJK mf))

#    # return [MFOR_r  [expr {[$mf.dim] - 1}]  [$mf vget -ijk_cur]  [$mf.IJK] ]
#    # return [MFOR_r  [expr {[$mf.dim] - 1}]  ::ijk_cur  [$mf.IJK] ]

#     #return [MFOR_r  [expr {$::dim - 1}]  ::ijk_cur  [$mf.IJK] ]
#     #return [MFOR_r  $::dim_1  ::ijk_cur  [$mf.IJK] ]

#     #set ijk

#     return [MFOR_r_2 $mf  [$mf dim_1__GET]  [$mf ijk_cur__GET]  [$mf IJK__GET] ]
#     #return [MFOR_r  [dict get [set $mf] "dim_1"]  ::ijk_cur  $::IJK ]
#   }
# }
# ;;;-----------------------------------------------------------------------------
proc MFOR_get_ijk_cur_1 {mf} {


  set ijk_cur  [set $::ijk_cur]
  #set ijk_cur  [$mf ijk_cur__GET]

  return $ijk_cur
}
# ;;;-----------------------------------------------------------------------------
# proc MFOR_get_ijk_cur_2 {mf} {


#   #set ijk_cur  $::ijk_cur
#   set ijk_cur  [$mf ijk_cur__GET]

#   return $ijk_cur
# }
# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
proc MFOR_print_ijk_cur_1 {mf strname} {

  set ijk_cur [MFOR_get_ijk_cur_1 $mf]

  ijk_array_print $strname $ijk_cur
  #ijk_array_print $strname [set $ijk_cur]

}
# ------------------------------------------------------------------------------
# proc MFOR_print_ijk_cur_2 {mf strname} {

#   set ijk_cur [MFOR_get_ijk_cur_2 $mf]

#   #ijk_array_print $strname $::ijk_cur
#   ijk_array_print $strname [set $ijk_cur]

# }
# ------------------------------------------------------------------------------
# ------------------------------------------------------------------------------
proc parse_argv {} {

  global argc argv arg0

  if {$argc >= 3} { # 3 2  , 8 8,  4 4 @

    set print_flag 0

    set dim     [lindex $argv 2] ;# 8 ;# 7
    set ijk_max [lindex $argv 3] ;# 8 ;# 7

    if {$argc == 5} { # например  @
    
      set print_flag 1
    }

  } else {

    set print_flag 1

    set dim     3
    set ijk_max 2
  }

  return [list $dim $ijk_max $print_flag]
}
# ------------------------------------------------------------------------------
# ;;;---------------------------------------------------------------------------
proc MFOR_test5_1 {} {


  foreach {dim ijk_max print_flag} [parse_argv] {break}

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  set ijk_cur [list_create_num_val $dim "0"] 

  set IJK     [list_make $dim "@"]
 
  ijk_array_set IJK  $ijk_max ;# можно было раньше инициировать

  set mf [MFOR_create_1  $dim $ijk_cur $IJK]

  #puts stderr ""
  #puts stderr "mf = [set $mf]"

  #puts stderr "values = [dict values [set $mf] ]"
  #set ijk_d  [dict get [set $mf] ijk]

  #puts stderr "ijk_d = $ijk_d"
  #puts stderr "ijk_l = [dict values $ijk_d]"

  #dict set $mf "dim" 999
  #puts "mf = [set $mf]"

  MFOR_init_1 $mf
  
  puts ""

  ijk_array_print "ijk=" [set $::ijk_cur]

  ijk_array_print "IJK=" $::IJK

  puts ""
  
  while {1} {

    if {! [MFOR_todo_1 $mf]} {break}
  
    if {$print_flag} {

      MFOR_print_ijk_cur_1  $mf "ijk_cur="
    }
  
  }
  
  # можно же и наоборот сделать - постоянный цикл, а из цикла уже вызывать 
  # обработчик вывода !
  # 
  
 # puts ""
}
# ------------------------------------------------------------------------------
# proc MFOR_test5_2 {} {



# foreach {dim ijk_max print_flag} [parse_argv] {break}

#   #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#   #   if {$mintest_flag} {
  
#   #     set dim     3
#   #     set ijk_max 2
  
#   #   } else {
  
#   # #     alias MFOR_create        MFOR_create_1
#   # #     alias MFOR_init          MFOR_init_1
#   # #     alias MFOR_todo          MFOR_todo_1
  
#   # #     alias MFOR_get_ijk_cur   MFOR_get_ijk_cur_1
#   # #     alias MFOR_print_ijk_cur MFOR_print_ijk_cur_1
  
#   #     set dim     8 ;# 7
#   #     set ijk_max 8 ;# 7
#   #   }

#   #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#   #
#   #set ijk_cur [make-array $dim] ;# UNDER CONSTRUCTION: make-array  dim1 dim2 ..

#   set ijk_cur [list_create_num_val $dim "0"] 
#   #set ijk_cur [make_array $dim "0"] 
#   #set ijk_cur [ijk_array_make $dim "0"]

#   set IJK     [list_make $dim "@"]
#   #   mf

  
#   ijk_array_set IJK  $ijk_max ;# можно было раньше инициировать

#   set mf [MFOR_create_2  $dim $ijk_cur $IJK]

#   #puts stderr ""
#   #puts stderr "mf = [set $mf]"

#   #puts stderr "values = [dict values [set $mf] ]"
#   #set ijk_d  [dict get [set $mf] ijk]

#   #puts stderr "ijk_d = $ijk_d"
#   #puts stderr "ijk_l = [dict values $ijk_d]"

#   #dict set $mf "dim" 999
#   #puts "mf = [set $mf]"

#   MFOR_init_2 $mf
  

#   puts ""

#   ijk_array_print "ijk=" [set [$mf ijk_cur__GET]]

#   ijk_array_print "IJK=" [$mf IJK__GET]
#   #ijk_array_print "IJK=" $::IJK

#   puts ""
  
#   #   (loop while (MFOR_todo mf) do (progn
#   while {1} {

#     if {! [MFOR_todo_2 $mf]} {break}
  
#     #ijk_array_print "ijk_cur=" [$mf.ijk_cur]
#     #ijk_array_print "ijk_cur=" $::ijk_cur

#     if {$print_flag} {
#       MFOR_print_ijk_cur_2 $mf "ijk_cur="
#     }
  
#   }
  
#  # puts ""
# }
# ------------------------------------------------------------------------------
proc MFOR_test5 {} {

  MFOR_test5_1

  #MFOR_test5_2

}
# ;=============================================================================


# ;-----------------------------------------------------------------------------
# ;-----------------------------------------------------------------------------
#
#
#
# ;=============================================================================


# ;=============================================================================
# ;
# ;;;---------------------------------------------------------------------------
# (defun test4_ (argus)  (declare (ignore argus))

# (let* (
#   (dim     3)
#   (ijk_cur (make-array dim))
#   (IJK     (make-array dim))
#   mf 
#   )

#   (ijk_array_set IJK     2) ; булевые переменные '(nil t) 
#   (setf mf (MFOR_create  dim ijk_cur IJK))
#   (MFOR_init mf)

#   (format t "~%")

#   (loop while (MFOR_todo mf) do (progn

#     (format t " ~2D)    " (MF-index mf))
#     (dotimes (i (length ijk_cur))
#       (format t "~4S  " (nth (aref ijk_cur i) '(nil t)))
#     )
#     (format t "~%")
#   )) 

#   (format t "~%")
# ))
# ==============================================================================
# 

# ------------------------------------------------------------------------------

# package require TclOO;  
  
# oo::class create MF {
    
#     SET_GET first 1 ;# флажок для начала цикла
#     SET_GET dim_1
#     SET_GET   IJK
#     SET_GET   ijk_cur
#   }
  
  
# ------------------------------------------------------------------------------

# b~.tl MISC MFOR_test5_NEW 

# b~.tl MISC MFOR_test5_1  5 5


# b~.tl MISC MFOR_test5  @
#
# чего-то совсем запутался с алгоритмом!
#
# медленно, может из-за постоянного вызова итерационно функции,
# а в Лиспе какая-то оптимизация!? а почему не арботает "безстековый" вызов?
#

#-------------------------------------------------------------------------------
# ;=============================================================================
