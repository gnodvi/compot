# -*-   mode: tcl  ; coding: koi8   -*- ----------------------------------------

#!/bin/sh
# \
exec tclsh "$0" ${1+"$@"}

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------


set auto_path [linsert $auto_path 0 "COMPOT/COM"]

package require compot::common 


#-------------------------------------------------------------------------------
proc MATH {} {

  source "u-math.tl"

  package           require math::linearalgebra
  namespace import -force ::math::linearalgebra::*

  #------------------------
  global argc argv
  eval [lindex $argv 1] ;# вызываем вспомогательную секонд-функцию
  #------------------------

  # m~.tl TENS TEST_00
  # m~.tl TENS TEST_time

}
#-------------------------------------------------------------------------------
proc SIMP {} {

  source "u-simp.tl"

  #------------------------
  global argc argv
  eval [lindex $argv 1] ;# вызываем вспомогательную секонд-функцию
  #------------------------

  # m~.tl SIMP TEST_01
  # m~.tl SIMP TEST_02

}
#-------------------------------------------------------------------------------
proc TENS {} {

  global auto_path

  set name "L_TENS"

  set auto_path   [linsert $auto_path 0 $name]

  #set auto_path   [linsert $auto_path 0 "."]
  #
  #package require TensorNew

  #------------------------
  if {1} {
    # for test гружу непосредственно без участия pkgIndex.tcl
    # 
    set this_dir [pwd]
    set libs_dir $this_dir/L_TENS
    set name_lib [file join $libs_dir libtensor4.0.so]

    load $name_lib TensorNew
  } else {
    #------------------------
    
    package require compot::tensor
  }

  source "u_tens.tl"

  #------------------------
  global argc argv
  eval [lindex $argv 1] ;# вызываем вспомогательную секонд-функцию
  #------------------------

  # m~.tl TENS TEST_01
  # m~.tl TENS TEST_02

}
#-------------------------------------------------------------------------------
# proc VECT {} {


#   global auto_path

#   #set name "L_VECT/VecTcl-0.2-new"
#   #set name "L_VECT/VecTcl-0.2-old"
#   #set name "L_VECT/VecTcl-0.2-000/VecTcl-0.2"
#   #set name "L_VECT/L"
#   set name "L_VECT"

#   set auto_path   [linsert $auto_path 0 $name]

#   #
#   # не обязательно, потому что уже установлено в системе ??
#   #
#   package require vectcl
#   namespace import -force ::vectcl::*

#   #package require vectclnew
#   #namespace import -force ::vectclnew::*

#   source "u_vect.tl"

#   #------------------------
#   global argc argv
#   eval [lindex $argv 1] ;# вызываем вспомогательную секонд-функцию
#   #------------------------

#   # m~.tl VECT TEST_00
#   # m~.tl VECT TEST_time

# }
#-------------------------------------------------------------------------------
# 
#-------------------------------------------------------------------------------

set CUR_DIR "u" ;# фиктивно
  
READ_AND_CALL_ARGUS  $CUR_DIR

puts "" 

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
