#!/bin/sh
# \
exec tclsh "$0" ${1+"$@"}
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
# Primer.tcl 
#
#   ---   Compute all primes that are less than:  2000
#   There are 303 primes less than 2000
#
#  Version of May 4, 2017
#
#-------------------------------------------------------------------------------
proc primerrun {max} {

  set primes {}
  
  if {0} {

    puts -nonewline "\n   ---   Compute all primes that are less than:  "
    flush stdout
    
    set max [gets stdin]
  }
  #--------------------------------------------------

  if {$max < 2} {
    set max 2
  }
  
  set primes [list 2]

  for {set test 3} {$test <= $max} {incr test 2} {
    set maxTest [expr {int(sqrt($test))}]
    foreach prime $primes {
      if {$prime  > $maxTest} {
        lappend primes $test
        break
      }
      if {![expr {$test % $prime}]} {
        break
      }
    }
  }

  
  
  set strng "#  The Prime Numbers less than  $max \n# \nset primes { \n"
  
  set strngLen 2
  set f [open "n_prim.tl.out" w]
  
  foreach n $primes {

    if {$strngLen > 75} {
      puts $f $strng
      set strng {}
      set nLen [string length "$n "]
      set strngLen $nLen 

      append strng "$n "

    } else {

      set nLen [string length "$n "]
      incr strngLen $nLen

      append strng "$n "
    }
  }

  append strng "\n}"

  puts $f $strng

  close $f
 
  puts ""
  puts "There are [llength $primes] primes less than $max \n"
  
  exit
  
}
#-------------------------------------------------------------------------------

primerrun 200 ;# 2000

#
#-------------------------------------------------------------------------------
