# -*-   mode: tcl  coding: koi8   -*- ------------------------------------------
#
#  Tcl index file for the COMPOT package.
#
#-------------------------------------------------------------------------------


set auto_path [linsert $auto_path 0 "$dir/src"] 
set auto_path [linsert $auto_path 0 "$dir/src/optima"] 
set auto_path [linsert $auto_path 0 "$dir/src/test-s"] 


package ifneeded compot 1.0 "

  package require compot::tensor
  package require compot::common
  package require compot::dialog
  package require compot::optima
  package require compot::recogn

  package provide compot 1.0
"

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------

