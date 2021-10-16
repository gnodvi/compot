# -*-   mode: tcl  ; coding: koi8   -*- ----------------------------------------


#-------------------------------------------------------------------------------
package ifneeded compot::random 1.0 "


  load   [file join "$dir/T" "r_tcl.so"] Random 

  source [file join $dir "r-knut.tl"]
  source [file join $dir "random.tl"]

  package provide compot::random 1.0
"

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
