# -*-   mode: tcl  ; coding: koi8   -*- ----------------------------------------

#!/bin/sh
# \
exec tclsh "$0" ${1+"$@"}

#-------------------------------------------------------------------------------
#
set auto_path [linsert $auto_path 0 "COMPOT/src"]

package require compot::common 


# ;===============================================================================
# ;
# ;
# ;===============================================================================

set  ::CUR_DIR  "r"

# ;(load "../a-comm.cl")
# (load "./a-comm.cl")

#source "./a-comm.cl.tl"
#source "../common/a-como.tl"


# ;---------------------------- hfjgh-------------hfjgh-
# ;(load "../../a-comm.cl")
# ;
# ; TODO: на такое "длинное" имя плохо реагирует функция my_load - надо
# ;       или исправить или вообще уж на TCL переписать
# ;  ghgjghjg ghgjghjg ghgjghjg hfjgh ;ljklj
# ;  привет гена !!!!! ура из Xming !!!! jhjhjh роролроро гена !!!
# ;-----------------------------------------



# ;-------------------------------------------------------------------------------
proc  TEST {} {

  #my_load "f-tabs.tl" $::CUR_DIR ;# (use-package :a-ctab)
  #my_load "f-tour.tl" $::CUR_DIR
  
  my_load "r_test.tl" $::CUR_DIR
  my_load "r-rsb-.tl" $::CUR_DIR
  my_load "r_rsb1.tl" $::CUR_DIR
  
  #   ;(load "v_test.cl")
  #   ;(load "v-rsb-.cl")
  #   ;
  
  #   (run_cdr_argus (first argus) argus "TEST ..")
  global argc argv
  eval [lindex $argv 1] ;#
  
}
# ;===============================================================================

# (READ_AND_CALL_ARGUS  CUR_DIR)

# (format t "~%") ; поскольку main нe сдeлан ...


READ_AND_CALL_ARGUS  $::CUR_DIR

# ;===============================================================================

