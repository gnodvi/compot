# -*-   mode: tcl  ; coding: koi8   -*- ----------------------------------------

#!/bin/sh
# \
exec tclsh "$0" ${1+"$@"}
#
#-------------------------------------------------------------------------------
#
set auto_path [linsert $auto_path 0 "./COMPOT/COM"]

package require compot::common 

#-------------------------------------------------------------------------------
# установить ссылку для конкретного окружения

#set_debian_OUT_add

#-------------------------------------------------------------------------------

puts ""


# ????? sometimes
# e_i__.jm TEST
# Segmentation fault
# 
# run_numer_tests  e . E/OUT 
#
# puts ""


run_numer_tests  f . E/OUT 

puts ""

run_numer_tests  g . E/OUT 

puts ""

run_numer_tests  m . E/OUT 

#-------------------------------------------------------------------------------

puts ""

run_numer_tests  j . E/OUT 

puts ""

run_numer_tests  p . E/OUT 

puts ""

run_numer_tests  r . E/OUT 

puts ""

#-------------------------------------------------------------------------------

#  time ./T_ALL.tl

# real	1m3.387s
# user	0m51.480s
# sys	0m10.932s

#
################################################################################

