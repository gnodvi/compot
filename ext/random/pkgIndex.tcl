# -*-   mode: tcl  ; coding: koi8   -*- ----------------------------------------


#-------------------------------------------------------------------------------
package ifneeded compot::random 1.0 "

  source [file join $dir "g-rand.tl"]

  load   [file join "$dir/T" "k_tcl.so"] Random 

  source [file join $dir "knuth.tl" ]
  source [file join $dir "random.tl"]

  package provide compot::random 1.0
"
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
