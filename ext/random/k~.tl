# -*-   mode: tcl  ; coding: koi8   -*- ----------------------------------------

#!/bin/sh
# \
exec tclsh "$0" ${1+"$@"}

#-------------------------------------------------------------------------------
#
#-------------------------------------------------------------------------------

# source "a-comm.tl"
# #source "a-rand.tl"

# source "a-disp.tl"

# # подключаем тесты только если  файлы есть;
# # другой способ - заключить их в отдельные процедуры 0-го уровня

# my_source "a-comp.tl"
# my_source "a-menu.tl"


#-------------------------------------------------------------------------------

set COMPOT "./COMPOT"

#set auto_path [linsert $auto_path 0 $COMPOT]

set auto_path [linsert $auto_path 0 $COMPOT/src/common] ;# for JIM
set auto_path [linsert $auto_path 0 $COMPOT/ext/random] ;# for JIM

#-------------------------------------------------------------------------------

#source "a-comm.tl"

package require compot::common 
#package require compot::random 


# ;-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
# proc TEST_random {} {


#   set this_dir [pwd]
#   set name_lib [file join "$this_dir/T" "k-lib.so"]

#   load $name_lib Random ;# -> Random_Init

#   #------------------------------------------

#   puts ""

#   knuth_random_seed 0 ;# 2021

#   for {set i 0} {$i < 10} {incr i} {

#     set r [knuth_random_rand]
#     puts "r = $r"
#   }

#   puts ""

# }
#-------------------------------------------------------------------------------
proc TEST {} {

  #  my_source "g-rand.tl"
  #  my_source "random.tl"

  source "knuth.tl"

  global argc argv
  eval [lindex $argv 1] ;# вызываем вспомогательную секонд-функцию


  # a~.jm RAND permutation_test
  # a~.jm RAND random_test
  # a~.jm RAND TEST_lrand

}
#-------------------------------------------------------------------------------

#TEST_random 

#-------------------------------------------------------------------------------

set CUR_DIR "k"
  
READ_AND_CALL_ARGUS  $CUR_DIR

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#
################################################################################

