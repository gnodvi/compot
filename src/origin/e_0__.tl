# -*-   mode: tcl  ; coding: koi8   -*- ----------------------------------------

#!/bin/sh
# \
exec tclsh "$0" ${1+"$@"}

#-------------------------------------------------------------------------------

set ::YES -1001.0 ;#define  YES (-1001.0)
set ::NOT -1000.0 ;#define  NOT (-1000.0)

#-------------------------------------------------------------------------------

load ./T/e-0000.so e_0000
  
# -----------------------------------------------------------------------------*/ 
proc test_00_tcl {nn} {

  #   GRAF *graf;
  #   int u;
  
  set graf [GrafCreate $nn]
  
  GrafInit1 $graf  50.0  50.0
  GrafPrint $graf
  
  GrafCheck $graf
  GrafPrint $graf
  
  set u [new_intp] ;# use pointer library 

  #GrafAddNode (graf, &u, YES);
  GrafAddNode $graf $u $::YES

  #   GrafEdgesFill (graf, u, YES);
  #   GrafPrint (graf);
  
  #   GrafCheck (graf);
  #   GrafPrint (graf);
  
  #   GrafDelNode (graf, u);
  #   GrafPrint (graf);
  
  #   return;
}
#-------------------------------------------------------------------------------
proc test_example {} {

  puts ""
  puts "e_run.tl ............."
  puts ""
  
  load ./T/e-0000.so e_0000
  
  
  set ret [Rand123 50 40 10]
  
  puts "ret = $ret"
  puts ""

  return
}
#-------------------------------------------------------------------------------
proc test_all {} {

  puts ""
  puts "....... test_00 4 ........"
  puts ""

  test_00 4

  
  puts ""
  puts "....... test_00_tcl 4 ........"
  puts ""
  
  test_00_tcl 4
 
  return
}
#-------------------------------------------------------------------------------
proc load_example {} {

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
  
}
#-------------------------------------------------------------------------------

global argv

set prog [lindex $argv 0]

#test_example

$prog

#-------------------------------------------------------------------------------
#  e_0__.tl test_example
#------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
