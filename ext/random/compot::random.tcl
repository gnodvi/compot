# -*-   mode: tcl  ; coding: koi8   -*- ----------------------------------------

#-------------------------------------------------------------------------------
#
#-------------------------------------------------------------------------------
proc package_require_random {COMPOT_} {


  uplevel "load [file join "$COMPOT_/ext/random/T" "r_jim.so"] Random" 

  uplevel "source  $COMPOT_/ext/random/r-knut.tl"
  uplevel "source  $COMPOT_/ext/random/random.tl"
  
}
#-------------------------------------------

set COMPOT "./COMPOT"

package_require_random $COMPOT


#-------------------------------------------------------------------------------
