# -*-   mode: tcl  ; coding: koi8   -*- ----------------------------------------

#-------------------------------------------------------------------------------
#
#-------------------------------------------------------------------------------
proc package_require_compot {COMPOT_} {


  set COM $COMPOT_/src/common
  
  uplevel "source  $COM/a-comm.tl"
  uplevel "source  $COM/a-dict.tl"
  #   source [file join $dir "a-disp.tl"]
  #   source [file join $dir "a-menu.tl"]
  uplevel "source  $COM/a-comp.tl"
  uplevel "source  $COM/a-plot.tl"
  
  uplevel "source  $COM/a-como.tl"
  uplevel "source  $COM/b-com0.tl"

  #   source [file join $dir "b-com1.tl"]
  #   source [file join $dir "b_cloo.tl"]
  
  uplevel "source  $COM/f-func.tl"
  #   source [file join $dir "f-tabs.tl"]
  #   source [file join $dir "f-tour.tl"]
  
  uplevel "source  $COM/f-sort.tl"
  uplevel "source  $COM/f-rand.tl"
  
}
#-------------------------------------------

set COMPOT "./COMPOT"

package_require_compot $COMPOT


#-------------------------------------------------------------------------------