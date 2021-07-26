# -*-   mode: tcl  ; coding: koi8   -*- ----------------------------------------


# #!/bin/sh
# # \
# exec tclsh "$0" ${1+"$@"}

#-------------------------------------------------------------------------------
#
#------------------------------------------

set this_dir [pwd]

if {$::__JIM__} {
  set name_lib [file join "$this_dir/T" "k_jim.so"]
} else {
  set name_lib [file join "$this_dir/T" "k_tcl.so"]
}

load $name_lib Random ;# -> Random_Init

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
proc TEST_random_rand {seed} {


  puts ""

  knut_random_seed $seed ;# 2021

  for {set i 0} {$i < 10} {incr i} {

    set r [knuth_random_rand]
    puts "r = $r"
  }

  puts ""

}
#-------------------------------------------------------------------------------
proc TEST_random_randint {seed} {


  knut_random_seed $seed ;# 2021

  for {set i 0} {$i < 10} {incr i} {

    set r [knuth_random_randint 20]
    puts "i = $i, r = $r"
  }

  puts ""

}
#-------------------------------------------------------------------------------
proc TEST_all {} {

  global argc argv argv0
  set argv [lrange $argv 2 end]

  puts ""
  puts stderr "argv = $argv"

  set seed [dict_parse $argv "-seed" 0]


  TEST_random_rand    $seed

  puts ""

  TEST_random_randint $seed

}
#-------------------------------------------------------------------------------

#TEST_random 

#-------------------------------------------------------------------------------

# set CUR_DIR "c"
  
# READ_AND_CALL_ARGUS  $CUR_DIR

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#
################################################################################

