# -*-   mode: tcl  ; coding: koi8   -*- ----------------------------------------

#-------------------------------------------------------------------------------
#
#-------------------------------------------------------------------------------
proc package_require_random {COMPOT_} {


  uplevel "source  $COMPOT_/ext/random/g-rand.tl"
  uplevel "source  $COMPOT_/ext/random/random.tl"
  
}

#-------------------------------------------

set COMPOT "./COMPOT"

package_require_random $COMPOT


#-------------------------------------------------------------------------------
