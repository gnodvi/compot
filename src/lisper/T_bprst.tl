# -*-   mode: tcl  ; coding: koi8   -*- ----------------------------------------

#!/bin/sh
# \
exec tclsh "$0" ${1+"$@"}

################################################################################



set auto_path [linsert $auto_path 0 "COMPOT/src"]

package require compot::common 

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------

puts ""

puts ""

#run_numer_tests  g . E/OUT 
run_numer_tests  b . E/OUT 

puts ""

run_numer_tests  p . E/OUT 

puts ""

run_numer_tests  r . E/OUT 

puts ""

run_numer_tests  s . E/OUT 

puts ""

run_numer_tests  t . E/OUT 

puts ""

#-------------------------------------------------------------------------------
#
################################################################################

