# -*-   mode: sh   ; coding: koi8   -*- ----------------------------------------

#!/bin/sh
# \
exec tclsh "$0" ${1+"$@"}
#-------------------------------------------------------------------------------


set auto_path [linsert $auto_path 0 "../COMPOT/src"]
set auto_path [linsert $auto_path 0 "../COMPOT/ext"]

set auto_path [linsert $auto_path 0 "."]

package require compot::common


# ;-------------------------------------------------------------------------------
proc TEST {} {

  source "../g-graf.tl"

  source "e_meta.tl"

  global argc argv

  set param1 [lindex $argv 1]

  #   eval $param1 ;# вызываем вспомогательную секонд-функцию
  #   return

  switch -- $param1 {

    "0" {loop0  10 5  1706}
    "1" {loop1  10 3  1706}
  }

  return
}
#-------------------------------------------------------------------------------

set CUR_DIR "h"
  
READ_AND_CALL_ARGUS  $CUR_DIR

# ;-------------------------------------------------------------------------------
# ;-------------------------------------------------------------------------------
