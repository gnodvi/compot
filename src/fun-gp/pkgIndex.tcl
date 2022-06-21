# -*-   mode: tcl  ; coding: koi8   -*- ----------------------------------------


#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------

# package ifneeded compot::optima 1.0 "

#   package require tcltest

#   source [file join $dir "f-item.tl"]
#   source [file join $dir "f-prog.tl"]

#   source [file join $dir "h-gsl0.tl"]
#   source [file join $dir "h-mbee.tl"]

#   package provide compot::optima 1.0
# "

package ifneeded compot::optima 1.0 "

  package require tcltest


  source [file join $dir "h-gsl0.tl"]
  source [file join $dir "h-mbee.tl"]

  package provide compot::optima 1.0
"

#-------------------------------------------------------------------------------

package ifneeded compot::graphs 1.0 "

  source [file join $dir "g-graf.tl"]

  package provide compot::graphs 1.0
"

#-------------------------------------------------------------------------------

#  source [file join $dir "b-com0.tl"]
#  load   [file join $dir ./a_capt.so] Capture

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------

