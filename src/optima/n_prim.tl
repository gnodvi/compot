# -*-   mode: tcl  ; coding: koi8   -*- ----------------------------------------

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
proc save_primes_to_file {primes max fname} {

  set f [open $fname  w]

  
  puts $f "#  The Prime Numbers less than  $max "
  puts $f "#  "
  puts $f "set ::primes_less_than  $max "
  puts $f ""

  set str2 "set primes { \n"
  puts $f  $str2

  set strng {}   ;# формируемая строка
  set strngLen 0 ;# счетчик длины "напечатанной" строки
  

  foreach n $primes {

    if {$strngLen > 75} {

      puts $f $strng ;# строку уже пора выводить

      set strng {} ;# и наченм новую
      set strngLen 0 

    } 

    set str [format "%4s " $n]
    append strng $str 

    set nLen [string length $str]
    incr strngLen $nLen
  }


  append strng "\n\n}\n"

  puts $f $strng ;# и наконец выводим готовую строку

  close $f
 
}
#-------------------------------------------------------------------------------
proc calc_primes {max} {
 

} 
#-------------------------------------------------------------------------------
proc primerrun {max} {
  
  #   if {0} {
  
  #     puts -nonewline "\n   ---   Compute all primes that are less than:  "
  #     flush stdout
  
  #     set max [gets stdin]
  #   }
  #--------------------------------------------------

  set primes {}
  
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

  #--------------------------------------------------  
  
  save_primes_to_file  $primes $max "n_2357.tl"

  #--------------------------------------------------  

  puts ""
  puts "There are [llength $primes] primes less than $max"
  puts ""
  puts "primes = $primes"
  puts ""
  
  exit
  
}
#-------------------------------------------------------------------------------

primerrun 10000 ;# 2000

#
#-------------------------------------------------------------------------------
