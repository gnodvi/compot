# -*-   mode: tcl  ; coding: koi8   -*- ----------------------------------------

#-------------------------------------------------------------------------------
#
#-------------------------------------------------------------------------------
proc package_require_random {COMPOT_} {


  set COM $COMPOT_/src/common
  
  uplevel "source  $COM/../../ext/random/g-rand.tl"
  uplevel "source  $COM/a-comr.tl"
  
}

#-------------------------------------------

set COMPOT "./COMPOT"

package_require_random $COMPOT


#-------------------------------------------------------------------------------
