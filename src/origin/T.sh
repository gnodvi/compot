# -*-   mode: tcl  ; coding: koi8   -*- ----------------------------------------

#!/bin/sh
# \
exec tclsh "$0" ${1+"$@"}
#
#-------------------------------------------------------------------------------
#
set auto_path [linsert $auto_path 0 "../common"]

package require compot::common 

#-------------------------------------------------------------------------------
# ���������� ������ ��� ����������� ���������

#set_debian_OUT_add

puts ""


# run_numer_tests  f . E/OUT 

# puts ""

run_numer_tests  g . E/OUT 

puts ""


run_numer_tests  m . E/OUT 

puts ""

#-------------------------------------------------------------------------------
################################################################################

