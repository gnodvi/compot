# -*-   mode: tcl  ; coding: koi8   -*- ----------------------------------------


# #!/bin/sh
# # \
# exec tclsh "$0" ${1+"$@"}

#-------------------------------------------------------------------------------
#
#------------------------------------------

# set this_dir [pwd]

# if {$::__JIM__} {
#   set name_lib [file join "$this_dir/T" "k_jim.so"]
# } else {
#   set name_lib [file join "$this_dir/T" "k_tcl.so"]
# }

# load $name_lib Random ;# -> Random_Init

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
proc knut_random_int_minmax {min max} {

  set interval [expr {$max - $min + 1}]

  set r [knut_random_int $interval]

  return [+ $r $min]
}
#-------------------------------------------------------------------------------
proc knut_random_int_minmax_1 {min max} {


  return [knut_random_int_minmax  $min [- $max 1]]
}
#-------------------------------------------------------------------------------
# 
#-------------------------------------------------------------------------------
proc TEST_random_rand {seed} {


  puts ""

  knut_random_seed $seed ;# 2021

  for {set i 0} {$i < 10} {incr i} {

    set r [knut_random_rand]
    puts "r = $r"
  }

  puts ""

}
#-------------------------------------------------------------------------------
proc TEST_random_randint {seed} {


  knut_random_seed $seed ;# 2021

  for {set i 0} {$i < 10} {incr i} {

    #//gives a random integer uniformly in [0..upto-1]
    set r [knut_random_int 20]
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

  puts ""

  for {set i 0} {$i < 20} {incr i} {

    set r [knut_random_int_minmax  1 5]    
    puts "i = $i, r = $r"
  }

  puts ""

  for {set i 0} {$i < 20} {incr i} {

    set r [knut_random_int_minmax_1  1 5]    
    puts "i = $i, r = $r"
  }

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

