# -*-   mode: tcl  ; coding: koi8   -*- ----------------------------------------

#!/bin/sh
# \
exec tclsh "$0" ${1+"$@"}
#
#-------------------------------------------------------------------------------


#set COMPOT "./COMPOT"
# set auto_path [linsert $auto_path 0 "COMMON"]

#lappend auto_path \
  [file join [file dirname [info script]] "."] ;# "COM" "../common"


set auto_path [linsert $auto_path 0 "COMMON"]
package require compot::common 

package require tcltest

# source "b-com0.tl"
# source "b-com1.tl"

#-------------------------------------------------------------------------------
#
#-------------------------------------------------------------------------------
proc NEXT_sorted {} {

  set res {{1 one} {3 three} {2 two}}

  # сортируем по 1-му элементу списков

  set sorted [lsort -integer -index 0 $res]

  puts ""
  puts "res origin = $res"
  puts "res sorted = $sorted"

}
#-------------------------------------------------------------------------------
#
#
# ~/.pilot/s/compot/genpro$ j~.tl JOY2 TEST_main b__01.joy 
#
# OPEN_FNAME not find file TEST_main in all PATHS !!
#
# ------------------------------------------------------------------------------
#
#-------------------------------------------------------------------------------
proc ALIB {} {

  source "r_ants.tl"

  global argc argv

  eval [lindex $argv 1] ;# вызываем вспомогательную секонд-функцию

}
#-------------------------------------------------------------------------------
proc ANTS {} {

  #source "j-0000.tl"  ;# общие части
  #source "j-1111.tl"  ;# надо будет подключить и ко всем примерам!!
  #source "j-2222.tl"  ;

  source "j-0123.tl"  ;# общие части
  source "j-3333.tl"  ; #  ????? dict_create

  source "j-prog.tl"
  source "p-corE.tl" 

  #source "t-proJ.tl"  ;# GP, и тесты на Tcl (типа Koza-Lisp)
  source "r_ants.tl"

  global argc argv

  eval [lindex $argv 1] ;# вызываем вспомогательную секонд-функцию

}
#-------------------------------------------------------------------------------
# proc COMM {} {

#  source "f-prog.tl"
#   source "g-corE.tl"
  
#   global argc argv

#   incr ::ind0

#   eval [lindex $argv 1] ;# вызываем вспомогательную секонд-функцию

# }
#-------------------------------------------------------------------------------
proc TEST {} {

  source "p-corE.tl" 
  source "r_test.tl" 
  
  global argc argv

  incr ::ind0 ;# указатель следуюшему обработчику, откуда начинать парсить


  set next_prog [lrange $argv 1 end] 

  if {$next_prog != ""} {

    # вызываем вспомогательную секонд-функцию с параметрами
    #eval [lindex $argv 1] [lrange $argv 2 end] 

    eval $next_prog
    return;
  }

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  #set fit_func     "FITPROC_xx_NEW"
  #set fit_tobest   "MIN"

  #set target_funtion "x pow 3 plus x"
  #set target_funtion "x pow 2 plus x"


  #TEST_xx_NEW  

#   ;# -nums -1 -news 1 -func $target_funtion -print 1 \
#    -init 0 \
#     -fit_func $fit_func  -fit_tobest $fit_tobest \
#     -list "dup * +" 

  # NEXT_01 -seed @ -lpop 5 -size 2 -nums -1 -list "p1 p3 p5" 

  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  return
}
#-------------------------------------------------------------------------------
#
#-------------------------------------------------------------------------------

set CUR_DIR "r"
  
READ_AND_CALL_ARGUS  $CUR_DIR

puts "" 

#-------------------------------------------------------------------------------

# r:r~.tl,TEST,TEST_xx,,-seed,0,-lpop,5,-size,6,-nums,-1,-print,2 ................ PASSED
# r:r~.tl,TEST,TEST_xx,,-seed,2013,,-lpop,10,-size,6,-nums,10 ................ PASSED


#-------------------------------------------------------------------------------

# r~.tl TEST TEST_nn  2013 9 6 1 @  ???????

# -) Усложнить задачи. (ANTS) задавая более сложные рисунки в т.ч. и динамически 
#    меняющиеся; а также  с постепенным усложнением; кроме того, сделать эвлюцию
#    "жизни мурашей" в реальном времени;

#-------------------------------------------------------------------------------
# 
# r~.tl ANTS ANTS_test_shalito_joy 50
# r~.tl ANTS ANTS_test_shalito_joy  0 - в интерактивном виде !!
# r~.tl ANTS ANTS_test_simple_joy

# r~.tl ANTS ANTS_gp @  10 15 2
# 
# r~.tl ANTS ANTS_t2

# r~.tl ANTS ANTS_test_shalito_old
# r~.tl ANTS ANTS_test_simple_old

#-------------------------------------------------------------------------------
#
#-------------------------------------------------------------------------------
