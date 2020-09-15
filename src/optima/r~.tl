# -*-   mode: tcl  ; coding: koi8   -*- ------------------------------------------

#!/bin/sh
# \
exec tclsh "$0" ${1+"$@"}

#-------------------------------------------------------------------------------
#
#set COMPOT "./COMPOT"

set auto_path [linsert $auto_path 0 "COMPOT/src"]

package require compot::common 

# ;===============================================================================
# ;
# ;
# ;===============================================================================

# lappend auto_path \
#   [file join [file dirname [info script]] "."] 


set auto_path [linsert $auto_path 0 "COMPOT/src/optima"]

package require compot::optima

# ;===============================================================================
# ;-------------------------------------------------------------------------------
# (defun GENA (argus)

#   (my_load "a-func.cl" CUR_DIR)
#   (my_load "a-pops.cl" CUR_DIR)

#   ;(my_load "l-gena.cl" CUR_DIR)
#   (my_load "n-mgen.cl" CUR_DIR) 
 
#   (run_cdr_argus (first argus) argus " ..")
# )
# ;-------------------------------------------------------------------------------
# (defun VALS (argus)
  
#   (my_load "a-func.cl" CUR_DIR)

#   (my_load "a-pops.cl" CUR_DIR)
#   ;(my_load "l-gena.cl" CUR_DIR)
#   (my_load "n-mgen.cl" CUR_DIR)  
#   (my_load "n-mbee.cl" CUR_DIR) 
 
#   (my_load "n_vals.li" CUR_DIR)

#   (run_cdr_argus (first argus) argus "VALS ..")
# )
# ;-------------------------------------------------------------------------------
# ;-------------------------------------------------------------------------------
proc MINF {} {

  
  #source "a-func.tl"
  #source "n-mbee.tl"
  
  #source "a-dict.tl"
  source "COMPOT/src/common/b-mfor.tl" ;# для перебора

  #source "m-gsl0.tl"

  source "r-ogsl.tl"
  
  source "r-obot.tl"  
  source "r-otst.tl"
  

  global argc argv
  eval [lindex $argv 1] ;#

  #   (run_cdr_argus (first argus) argus "MINF ..")

}
# ;===============================================================================

# (READ_AND_CALL_ARGUS  CUR_DIR)

set CUR_DIR "r"
  
READ_AND_CALL_ARGUS  $CUR_DIR

# ; ==============================================================================
# ; TODO: 

# ; - описаниe счeтных функций (в видe объeктов);
# ; - выдeлить объeктно-сорeвноватeльную систeму из m-obot.cl;
# ; - 
# ; - нeсколько хромосом (и вообщe додeлать GA);
# ; - провeрить на тeстах как в Матлабe;
# ; - поиск с ограничeниями;
# ; - соeдинить с пчeлиным поиском;

# ;===============================================================================

# ; cl n~.cl VALS vals_find t5 0.1 1 5 @ GA 40 8 0.7 0.2

#n~.tl BEES bees_test

#n~.tl MINF more_test -1

#n~.tl MINF simp_test  
 

# ;===============================================================================
