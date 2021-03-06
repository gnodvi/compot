#!/bin/sh
# \
exec tclsh "$0" ${1+"$@"}

#-------------------------------------------------------------------------------
#
#-------------------------------------------------------------------------------

source "./a-comm.tl"

#source "../common/a-comm.tl"
#package require common 1.0

#-------------------------------------------

source "g_list.tl"
#source "g_memt.tl"

#namespace import TESTLIST::*

#-------------------------------------------------------------------------------
proc TEST_gaulgena {} {

  # чего-то не грузится "random_seed"
  # 
  #load ../gaul-c/T/libgaul.so gaul
  #load ../gaul-c/T/gaul_util.so gaul_util

  load T/tclgaul_gena.so Gaulgena


  set ret1 [gaulgena  -seedrand 2013]
  puts ""
  puts "RET1 = $ret1"

}
#-------------------------------------------------------------------------------
# 
#-------------------------------------------------------------------------------
#  
set CUR_DIR "g"
  
READ_AND_CALL_ARGUS  $CUR_DIR

#-------------------------------------------------------------------------------
#
# g~.tl TEST_list 2013
# g_memt.tl 2013
# g_nams.tl 2013
#
# g~.tl TEST_gaulgena
#
################################################################################

