# -*-   mode: tcl  ; coding: koi8   -*- ----------------------------------------

#!/bin/sh
# \
exec tclsh "$0" ${1+"$@"}

#-------------------------------------------------------------------------------
#
# set MAIN_JIM "JIMTCL" 
# set auto_path [linsert $auto_path 0 $MAIN_JIM]

#-------------------------------------------------------------------------------

#set COMPOT "./COMPOT"

#set auto_path [linsert $auto_path 0 $COMPOT]

set auto_path [linsert $auto_path 0 ..] ;# for JIM

#set auto_path [linsert $auto_path 0 $COMPOT/src/common] ;# for JIM
#set auto_path [linsert $auto_path 0 $COMPOT/src/random] ;# for JIM

#-------------------------------------------------------------------------------

#source "a-comm.tl"

package require compot::common 
#package require compot::random 


#-------------------------------------------------------------------------------

# package require name ?version?

# Searches for the package with the given name by examining each path in
#  $::auto_path and trying to load $path/$name.so as a dynamic extension, or 
# $path/$name.tcl as a script package.

# The first such file which is found is considered to provide the package. (The 
# version number is ignored).

# If $name.so exists, it is loaded with the load command, otherwise if $name.tcl 
# exists it is loaded with the source command.

# If load or source fails, package require will fail immediately. No further 
# attempt will be made to locate the file.

#-------------------------------------------------------------------------------
# установить ссылку для конкретного окружения

#set_debian_OUT_add


#-------------------------------------------------------------------------------
proc RAND {} {

  #  my_source "g-rand.tl"
  #  my_source "random.tl"

  #source "knuth.tl"
  source "g-rand.tl"

  global argc argv
  eval [lindex $argv 1] ;# вызываем вспомогательную секонд-функцию


  # a~.jm RAND permutation_test
  # a~.jm RAND random_test
  # a~.jm RAND TEST_lrand

}
#-------------------------------------------------------------------------------
proc TEST_all {} {

  puts ""
  puts "TEST_all"
  puts ""

  comm_random_seed_null 0

  for {set i 0} {$i < 15} {incr i} {

    set ret [comm_random_boolean_prob 0.9]
    puts "ret = $ret"
  }

  puts ""

  for {set i 0} {$i < 15} {incr i} {

    set ret [comm_random_boolean_prob 0.1]
    puts "ret = $ret"
  }

  puts ""
}
#-------------------------------------------------------------------------------

set CUR_DIR "g"
  
READ_AND_CALL_ARGUS  $CUR_DIR

#-------------------------------------------------------------------------------
#
# r~.tl TEST_all

# a~.tl DICT_tests
# a~.tl TEST_5
# a~.tl TEST_color
# 
#-------------------------------------------------------------------------------
#
################################################################################

