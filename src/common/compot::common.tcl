# -*-   mode: tcl  ; coding: koi8   -*- ----------------------------------------

#-------------------------------------------------------------------------------
#
#set auto_path [linsert $auto_path 0 "./COMPOT/ext/random"]
#set auto_path [linsert $auto_path 0 "./COMPOT/src/random"]

# puts "pwd = [pwd] !!!!!!!!!!!!!!!!!!!!!!"
# puts ".......... [info source [info script]] "

#set CUR_DIR [pwd]

set ::CUR [ file dirname [ file normalize [ info script ] ] ]
#puts "::CUR = $::CUR"


#-------------------------------------------------------------------------------
#proc package_require_compot {COMPOT_} {
proc package_require_compot {} {

  #set COM $COMPOT_/src/common
  #set COM $COMPOT_/src/common
  
  uplevel "source  $::CUR/a-comm.tl"
  uplevel "source  $::CUR/a-dict.tl"
  uplevel "source  $::CUR/a-disp.tl"
  uplevel "source  $::CUR/a-menu.tl"
  uplevel "source  $::CUR/a-comp.tl"
  uplevel "source  $::CUR/a-plot.tl"
  
  uplevel "source  $::CUR/a-como.tl"
  uplevel "source  $::CUR/b-com0.tl"

  #uplevel "source  $COM/b-com1.tl"
  #   source [file join $dir "b_cloo.tl"]
  
  uplevel "source  $::CUR/f-func.tl"
  #   source [file join $dir "f-tabs.tl"]
  #   source [file join $dir "f-tour.tl"]
  
  uplevel "source  $::CUR/f-sort.tl"

  #uplevel "source  $COM/../../ext/random/g-rand.tl"
  #uplevel "source  $COM/a-comr.tl"
  
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  #package require compot::random   
  #~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

  #set COM $COMPOT_/src/common
  #set COM $COMPOT_/COM/common
  
  uplevel "load [file join "$::CUR/RANDOM/T" "r_jim.so"] Random" 
  uplevel "source  $::CUR/RANDOM/r-knut.tl"
  uplevel "source  $::CUR/RANDOM/random.tl"

}

#   uplevel "load [file join "$COM/RANDOM/T" "r_jim.so"] Random" 
#   uplevel "source  $COM/RANDOM/r-knut.tl"
#   uplevel "source  $COM/RANDOM/random.tl"

#   uplevel "load [file join "$COM/T" "r_jim.so"] Random" 
#   uplevel "source  $COM/r-knut.tl"
#   uplevel "source  $COM/random.tl"

#-------------------------------------------
  #   source [file join $dir "a-disp.tl"]
  #   source [file join $dir "a-menu.tl"]
#-------------------------------------------

#set COMPOT "./COMPOT"
#package_require_compot $COMPOT

package_require_compot 

#-------------------------------------------------------------------------------
# 
#-------------------------------------------------------------------------------
