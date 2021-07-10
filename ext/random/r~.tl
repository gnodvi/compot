# -*-   mode: tcl  ; coding: koi8   -*- ----------------------------------------

#!/bin/sh
# \
exec tclsh "$0" ${1+"$@"}

#-------------------------------------------------------------------------------
#
# set MAIN_JIM "JIMTCL" 
# set auto_path [linsert $auto_path 0 $MAIN_JIM]

#-------------------------------------------------------------------------------

set COMPOT "./COMPOT"

#set auto_path [linsert $auto_path 0 $COMPOT]

set auto_path [linsert $auto_path 0 $COMPOT/src/common] ;# for JIM
set auto_path [linsert $auto_path 0 $COMPOT/ext/random] ;# for JIM

#-------------------------------------------------------------------------------

#source "a-comm.tl"

package require compot::common 
#package require compot::random 


#-------------------------------------------------------------------------------
# установить ссылку для конкретного окружения

#set_debian_OUT_add


#-------------------------------------------------------------------------------
proc RAND {} {

#  my_source "g-rand.tl"
#  my_source "random.tl"

  global argc argv
  eval [lindex $argv 1] ;# вызываем вспомогательную секонд-функцию


  # a~.jm RAND permutation_test
  # a~.jm RAND random_test
  # a~.jm RAND TEST_lrand

}
#-------------------------------------------------------------------------------

set CUR_DIR "r"
  
READ_AND_CALL_ARGUS  $CUR_DIR

#-------------------------------------------------------------------------------
# 
# a~.tl DICT_tests
# a~.tl TEST_5
# a~.tl TEST_color
# 
#-------------------------------------------------------------------------------
#
################################################################################

