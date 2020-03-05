# -*-   mode: tcl  ; coding: koi8   -*- ----------------------------------------

#!/bin/sh
# \
exec tclsh "$0" ${1+"$@"}

#-----------------------------------------------------------------------------
#
set COMPOT "./COMPOT"

set auto_path [linsert $auto_path 0 $COMPOT]


package require compot::common 1.0

# -----------------------------------------------------------------------------

lappend auto_path \
  [file join [file dirname [info script]] "."] 

package require compot::optima

# -----------------------------------------------------------------------------
proc BEES {} {

  #   ;(my_load "a-func.cl" CUR_DIR)
  #   ;(my_load "n-mbee.cl" CUR_DIR)
  
  #source "./a-func.tl"
  #source   "n-mbee.tl"
  
  global argc argv
  eval [lindex $argv 1] ;#

  #   (run_cdr_argus (first argus) argus "BEES ..")
}
# -----------------------------------------------------------------------------

# (READ_AND_CALL_ARGUS  CUR_DIR)


set CUR_DIR "h"
  
READ_AND_CALL_ARGUS  $CUR_DIR

# ;=============================================================================

# m-gslm.tl rosenbrock pr   100  
# m-gslm.tl parabolic  step 100 
# m-gslm.tl parabolic  bfgs 100 
# m-gslm.tl parabolic  pr   100  
# m-gslm.tl rosenbrock fr   100 
# m-gslm.tl  
# m-gslm.tl rosenbrock bfgs 100  
# m-gslm.tl parabolic  fr   100 

# ;-----------------------------------------------------------------------------

# TODO: 

# 1) седлать идентичными :

#    h-gslm.tl
#    h-gslm.tl N  - с указательным списком

# 2) добавить ::NEWEST и затем dictrecord !!

# 3) интегрировать в MyGaul
# 
 
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
