# -*-   mode: tcl  ; coding: koi8   -*- ----------------------------------------

#-------------------------------------------------------------------------------
#
#-------------------------------------------------------------------------------
#proc package_require_random {COMPOT_} {


#   uplevel "load [file join "$COMPOT_/ext/random/T" "r_jim.so"] Random" 

#   uplevel "source  $COMPOT_/ext/random/r-knut.tl"
#   uplevel "source  $COMPOT_/ext/random/random.tl"
  
# }
#-------------------------------------------------------------------------------
proc package_require_random {COMPOT_} {


#   set COM $COMPOT_/src/common
  
#   uplevel "load [file join "$COM/T" "r_jim.so"] Random" 

#   uplevel "source  $COM/r-knut.tl"
#   uplevel "source  $COM/random.tl"
  
}
#-------------------------------------------

set COMPOT "./COMPOT"

package_require_random $COMPOT


#-------------------------------------------------------------------------------
