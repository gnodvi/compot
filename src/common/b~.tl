# -*-   mode: tcl  ; coding: koi8   -*- ----------------------------------------

#!/bin/sh
# \
exec tclsh "$0" ${1+"$@"}

#-------------------------------------------------------------------------------
#
#-------------------------------------------------------------------------------

set COMPOT "./COMPOT" 

set auto_path [linsert $auto_path 0 $COMPOT]

package require compot::common 1.0

# ------------------------------------------------------------------------------
proc COM_test {} {

  #source "b-comm.tl"

  #WARNING: unknown option COM_0: should be one of -asidefromdir, -constraints, 
  # -debug, -errfile, -file, -limitconstraints, -load, -loadfile, -match, 
  # -notfile, -outfile, -preservecore, -relateddir, -singleproc, -skip, -testdir, 
  # -tmpdir, or -verbose

  global argc argv
  #
  #incr argc -2 
  set argv "" ;# чтоб убрать предупреждение!

  ALLTESTS ;# встроенные тесты пакета struct/record

}
# ;-----------------------------------------------------------------------------
proc COM_0 {} {

  source "b-com0.tl"
  source "b-com1.tl"
  source "b-com2.tl"

  global argc argv
  eval [lindex $argv 1] ;# вызываем вспомогательную секонд-функцию

}
# ;-----------------------------------------------------------------------------
# proc COM_1 {} {

#   source "b-com1.tl"
#   #source "b-com3.tl"
#   source "b-comm.tl"

#   global argc argv
#   eval [lindex $argv 1] ;# вызываем вспомогательную секонд-функцию

# }
# # ;-------------------------------------------------------------------------------
proc TIME_all {} {

  puts ""
  puts "TEST_cloo_time: "
  #
  TEST_cloo_time


  puts ""
  puts "TEST_itcl_time: "
  #
  TEST_itcl_time


  source "b-com0.tl"
  source "b-com1.tl"

  puts ""
  puts "TEST_com0_time: "
  #
  TEST_com0_time

  # надо бы зачистить определения от предыдущего!
  #
  namespace delete ::struct::record 


#   source "b-com1.tl"
#   puts ""
#   puts "TEST_com1_time: "
#   #
#   TEST_com1_time


}
# ;-------------------------------------------------------------------------------
# proc TEST {} {

#   source "b_cloo.tl"
#   source "b_itcl.tl"

#   global argc argv
#   eval [lindex $argv 1] ;# вызываем вспомогательную секонд-функцию

# }
# ;-------------------------------------------------------------------------------
proc MISC {} {

  source "b-com0.tl"
  #source "a-dict.tl"

  source "b-mfor.tl"

  global argc argv
  eval [lindex $argv 1] ;# вызываем вспомогательную секонд-функцию

}
#-------------------------------------------------------------------------------
proc COM0 {} {

  #package require "dicttool"
  #source "dicttool.tcl"

  #source "../common/a-dict.tl"
  source "b-com0.tl"

  global argc argv

  eval [lindex $argv 1] ;# вызываем вспомогательную секонд-функцию

  #   (run_cdr_argus (first argus) argus "COMM ..")

}
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#
#-------------------------------------------------------------------------------

set CUR_DIR "b" ;# фиктивно
  
READ_AND_CALL_ARGUS  $CUR_DIR

puts "" 

#-------------------------------------------------------------------------------
#
#./b~.tl TEST TIME_all

#-------------------------------------------------------------------------------
# VERSION = 8.5.15

# TEST_cloo_time:  

# Create:   3.56 microseconds per iteration
# SetGet:   2.51 microseconds per iteration
# Delete:   3.48 microseconds per iteration

# TEST_itcl_time: 

# Create:   2.97 microseconds per iteration
# SetGet:   3.56 microseconds per iteration
# Delete:   3.34 microseconds per iteration

# TEST_com0_time: 

# Create:   24.88 microseconds per iteration
# SG_1= :   28.96 microseconds per iteration
# SGcget:   20.12 microseconds per iteration
# SGvget:   7.03 microseconds per iteration
# Delete:   75.47 microseconds per iteration

# TEST_com1_time: 

# Create:   44.2 microseconds per iteration
# SetGet:   18.57 microseconds per iteration
# SetGet:   26.35 microseconds per iteration
# Delete:   5.71 microseconds per iteration

#-------------------------------------------------------------------------------
# VERSION = 8.6

# TEST_cloo_time: 

# Create:   2.86 microseconds per iteration
# SetGet:   2.09 microseconds per iteration
# Delete:   2.75 microseconds per iteration

# TEST_itcl_time: 

# Create:   107.17 microseconds per iteration
# SetGet:   4.73 microseconds per iteration
# Delete:   11.59 microseconds per iteration

# TEST_com0_time: 

# Create:   26.46 microseconds per iteration
# SG_1= :   28.44 microseconds per iteration
# SGcget:   18.81 microseconds per iteration
# SGvget:   6.52 microseconds per iteration
# Delete:   79.95 microseconds per iteration

# TEST_com1_time: 

# Create:   42.09 microseconds per iteration
# SetGet:   21.34 microseconds per iteration
# SetGet:   27.43 microseconds per iteration
# Delete:   6.46 microseconds per iteration

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#
# TODO:
#
# сделать ! реализацию "record" как "dict", хотя бы в простом случае без вложений!
#

# b~.tl COM_0 TEST_record_00_NEW

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
