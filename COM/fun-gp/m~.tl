# -*-   mode: sh   ; coding: koi8   -*- ----------------------------------------

#!/bin/sh
# \
exec tclsh "$0" ${1+"$@"}
#-------------------------------------------------------------------------------


set auto_path [linsert $auto_path 0 "COMPOT/COM"]
set auto_path [linsert $auto_path 0 "."]

package require compot::common 

package require compot::graphs 

# -------------------------------------------------------------------------------
# proc TEST {} {

#   source "t_meta.tl"

#   global argc argv

#   # надо оставить только словарные параметры
#   # 
#   set argv [lrange $argv 1 end]

#   puts stderr "argc = $argc   argv = $argv"

#   set prog  [dict_parse $argv "-prog"    "loop1" ] 
 
#   set size  [dict_parse $argv "-size"    10] 
#   set nums  [dict_parse $argv "-nums"     5] 
#   set seed  [dict_parse $argv "-seed"  1706] 

#   $prog  -size $size -nums $nums -seed $seed 
  

#   return
# }
#-------------------------------------------------------------------------------

set CUR_DIR "m"
  
READ_AND_CALL_ARGUS  $CUR_DIR

# -------------------------------------------------------------------------------

# t~.tl TEST -prog loop1 .........
# t_test.tl -mode test -prog loop1 -size 10 -nums 5 -seed 1706

# -------------------------------------------------------------------------------
