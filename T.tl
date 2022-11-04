# -*-   mode: tcl  coding: koi8   -*- ------------------------------------------

#!/bin/sh
# \
exec tclsh "$0" ${1+"$@"}

#-------------------------------------------------------------------------------

#set auto_path [linsert $auto_path 0 "lib"]
set auto_path [linsert $auto_path 0 "SRC/common"]

package require compot::common 

#-------------------------------------------------------------------------------

puts ""
puts "TEST for package compot"
puts ""

set  val 5
puts "val = $val"
decr val
puts "val = $val"

#catch {cd "src/m"}
#eval exec "make test"

puts ""

# ;-------------------------------------------------------------------------------
# ;-------------------------------------------------------------------------------
