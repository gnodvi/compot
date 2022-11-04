# -*-   mode: tcl  ; coding: koi8   -*- ----------------------------------------

#-------------------------------------------------------------------------------

#!/bin/sh
# \
exec tclsh "$0" ${1+"$@"}

package require Tk ;# тогда в Windows CMD виден вывод в STDOUT

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
# http://wiki.tcl.tk/819
# 
# A little primes toy
# Updated 2016-01-16 05:12:57 by pooryorick Б√╡# Б√╡ Б√╡
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------

# Richard Suchenwirth 2003-06-24: This educational Tcltoy (written on a PocketPC,
# but should run anywhere) shows the numbers from 1 to 100 on a canvas - see
# $about for more. Maybe not a good starter to teach programming to children, but
# a nice visualitation of the Sieve of Erastothenes, and a factorization helper...

#-------------------------------------------------------------------------------
set about "primes.tcl

Richard Suchenwirth 2003
Powered by Tcl/Tk!

Click on a number to highlight its multiples, and see its prime factors on top.
Click Clear to remove highlighting.
Primes are never highlighted. They are multiples only of 1, which is no prime.
(Hint: 2 3 5 7)"

#-------------------------------------------------------------------------------
# to make it work with tclkit...

package require Tk

#-------------------------------------------------------------------------------

proc hilite w {
    set id [$w find withtag current]
    set ::info $id=[join [primefactors $id] *]
    if {$id == 1} return
    for {set i [expr $id+1]} {$i<=100} {incr i} {
        if {$i%$id == 0} {
            $w itemconfig $i -fill orange
        }
    }
}
proc primefactors n {
    set res {}
    for {set i 2} {$i <= $n} {incr i} {
        while {$n%$i == 0} {
            set n [expr {$n/$i}]
            lappend res $i
        }
    }
    set res
}
#-------------------------------------------------------------------------------
proc main_GUI {} {

  frame .f

  label .f.l -width 26 -bg white -textvar info

  button .f.a -text About  -command {tk_messageBox -message $about}
  button .f.c -text Clear -command {.c itemconfig txt -fill black}
  button .f.x -text X -command exit

  eval pack [winfo children .f] -side left -fill y

  pack .f [canvas .c]

  set x 20; set y 20
  set n 0

  foreach row {1 2 3 4 5 6 7 8 9 10} {
  foreach col {1 2 3 4 5 6 7 8 9 10} {
    .c create text $x $y -text [incr n] -tag txt
    incr x 20
  }
    set x 20; incr y 20
  }
  
  .c bind txt <1> {hilite .c}
  wm geometry . 240x268+0+0

}
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
# http://wiki.tcl.tk/819
#Prime factors of an integer 
#-------------------------------------------------------------------------------
proc primefactors__ n {

  # a number x is prime if [llength [primefactors $x]]==1
  set res {}
  set f 2

  while {$f<=$n} {

    while {$n%$f==0} {
      set n [expr {$n/$f}]
      lappend res $f
    }

    set f [expr {$f+2-($f==2)}]
  }

  set res

} ;#RS
#-------------------------------------------------------------------------------
proc MAIN {} {


  main_GUI

  set res [primefactors__ 15]

  puts ""
  
  foreach n {6 15 30} {

    puts "primefactors $n = [primefactors__ $n]"
  }

  puts ""

  return
}
#-------------------------------------------------------------------------------

MAIN

#-------------------------------------------------------------------------------
											  
