# -*-   mode: tcl  ; coding: koi8   -*- ----------------------------------------


#-------------------------------------------------------------------------------
# package ifneeded compot::random 1.0 "

#   source [file join $dir "../../ext/random/g-rand.tl"]
#   source [file join $dir "../../ext/random/a-comr.tl"]

#   package provide compot::random 1.0
# "
#-------------------------------------------------------------------------------

set auto_path [linsert $auto_path 0 "./COMPOT/ext/random"]

package ifneeded compot::common 1.0 "

  source [file join $dir "a-comm.tl"]
  source [file join $dir "a-como.tl"]

  source [file join $dir "a-dict.tl"]
  source [file join $dir "a-menu.tl"]
  source [file join $dir "a-comp.tl"]
  source [file join $dir "a-plot.tl"]
  source [file join $dir "a-disp.tl"]

  source [file join $dir "b-com0.tl"]
  source [file join $dir "b-com1.tl"]
  source [file join $dir "b_cloo.tl"]

  source [file join $dir "f-func.tl"]
  source [file join $dir "f-tabs.tl"]
  source [file join $dir "f-tour.tl"]
  source [file join $dir "f-sort.tl"]

  package require compot::random 

  package provide compot::common 1.0
"


#-------------------------------------------------------------------------------
#  source [file join $dir "g-graf.tl"]

#  source [file join $dir "b-com0.tl"]
#  load   [file join $dir ./a_capt.so] Capture

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------

