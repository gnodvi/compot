# -*-   mode: tcl  ; coding: koi8   -*- ----------------------------------------

#!/bin/sh
# \
exec tclsh "$0" ${1+"$@"}

#-------------------------------------------------------------------------------

puts ""
puts "e_run.tl ............."
puts ""

load ./T/e-0000.so e_0000


set ret [Rand123 50 40 10]

puts "ret = $ret"
puts ""

exit

#-------------------------------------------------------------------------------
# file: runme.tcl
# Try to load as a dynamic module.

catch { load ./T/example[info sharedlibextension] example}
#load ./T/example.so example


# Call our gcd() function
set x 42
set y 105
set g [gcd $x $y]
puts "The gcd of $x and $y is $g"

# Manipulate the Foo global variable

# Output its current value
puts "Foo = $Foo"

# Change its value
set Foo 3.1415926

# See if the change took effect
puts "Foo = $Foo"

puts ""

#-------------------------------------------------------------------------------
