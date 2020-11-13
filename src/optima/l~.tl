# -*-   mode: tcl  ; coding: koi8   -*- ----------------------------------------

#!/bin/sh
# \
exec tclsh "$0" ${1+"$@"}
#
#-------------------------------------------------------------------------------


set COMPOT "./COMPOT"

set auto_path [linsert $auto_path 0 $COMPOT]

#lappend auto_path \
  [file join [file dirname [info script]] "."] ;# "COM" "../common"


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

  source "l_ants.tl"

  global argc argv

  eval [lindex $argv 1] ;# вызываем вспомогательную секонд-функцию

}
#-------------------------------------------------------------------------------
proc ANTS {} {


  source "k-0000.tl"  ;# общие части

  source "k-1111.tl"  ;# надо будет подключить и ко всем примерам!!
  source "k-2222.tl"  ;

  source "k-3333.tl"  ;

  source "g-corE.tl"
 
  source "l-proJ.tl"  ;# GP, и тесты на Tcl (типа Koza-Lisp)

  source "l_ants.tl"


  global argc argv

  eval [lindex $argv 1] ;# вызываем вспомогательную секонд-функцию

}
#-------------------------------------------------------------------------------
proc TEST {} {

  source "k-0000.tl"  ;# общие части
  source "k-1111.tl"  ;# простой jOY 

  source "g-corE.tl"

  source "l-proJ.tl"  ; # тесты на JOY
  
  global argc argv

  incr ::ind0

  eval [lindex $argv 1] ;# вызываем вспомогательную секонд-функцию

}
#-------------------------------------------------------------------------------
proc COMM {} {

  source "g-corE.tl"
  
  global argc argv

  incr ::ind0

  eval [lindex $argv 1] ;# вызываем вспомогательную секонд-функцию

}
#-------------------------------------------------------------------------------
#
#-------------------------------------------------------------------------------

set CUR_DIR "l"
  
READ_AND_CALL_ARGUS  $CUR_DIR

puts "" 

#-------------------------------------------------------------------------------



#-------------------------------------------------------------------------------

# t~.tl TEST TEST_xx  @     10 6 10
# t~.tl TEST TEST_xx  2013  10 6 10


# t~.tl TEST TEST_nn  2013 9 6 1 @  ???????

# -) Усложнить задачи. (ANTS) задавая более сложные рисунки в т.ч. и динамически 
#    меняющиеся; а также  с постепенным усложнением; кроме того, сделать эвлюцию
#    "жизни мурашей" в реальном времени;

#-------------------------------------------------------------------------------
# 
# t~.tl ANTS ANTS_test_shalito_joy 50
# t~.tl ANTS ANTS_test_shalito_joy  0 - в интерактивном виде !!
# t~.tl ANTS ANTS_test_simple_joy

# t~.tl ANTS ANTS_gp @  10 15 2
# 
# t~.tl ANTS ANTS_t2

# t~.tl ANTS ANTS_test_shalito_old
# t~.tl ANTS ANTS_test_simple_old

#-------------------------------------------------------------------------------
#
#-------------------------------------------------------------------------------
