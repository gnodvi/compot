# -*-   mode: sh   ; coding: koi8   -*- ----------------------------------------

#!/bin/sh
# \
exec tclsh "$0" ${1+"$@"}
# 
#-------------------------------------------------------------------------------


#-------------------------------------------------------------------------------
# http://computer-programming-forum.com/57-tcl/ebd6a7ef882219a1.htm

# CODE: Static variables for Tcl procs
#
# Hi Folks,

# Yesterday I hacked together a proc to support true static variables
# for tcl procs. It behaves exactly as its C counterpart does, that
# is the variable is only initialized when it is first created
# (otherwise it wouldn't be "static", I suppose :-). If no
# initialization value is given the static variable is initialized
# with 0.

# The proc looks like this:

# -----------------------------------------------------------------------------
# Proc:         static
# Args:         varname, initval (optional)
# Returns:      The value of the static variable.
# Desc:         Creates varname as a "static" variable for the invoking proc.
#               If varname hasn't been initialized already it is set to
#               $initval.
# Side-FX:      Creates a global array with the name of the invoking proc.
#
# -----------------------------------------------------------------------------
proc static {varname {initval 0}} {

  # determine the name of the proc that invoked us:

  set procname [lindex [info level -1] 0]
  global $procname
  
  # initialize only if the variable doesn't already exist:
  
  if ![info exists [set procname]($varname)] {
      set [set procname]($varname) $initval
    }
    
  # make the global variable accessible from within the invoking proc
  # and return its current value:
    
  uplevel upvar #0 [set procname]($varname) $varname

  return [set [set procname]($varname)]
}
#-------------------------------------------------------------------------------
# Now you can do something like the following:
#-------------------------------------------------------------------------------
proc stest {} {

  static cnt1
  static cnt2 68
  
  incr cnt1
  incr cnt2
  
  puts "cnt1: $cnt1, cnt2: $cnt2"

  return
}
#---------------------------------------------------
# Now call "stest" a few times and watch the static variables as they are
# incremented with each call.

# The "static" proc has been verified to work with both Tcl 7.3 and 7.4.
# I hope you find it useful.

# Cheers,
# -christian


# I'd suggest you use some more complex name. Procedure names are usually
# mnemonic and thus likely to be used for existing array names. Also, you
# can't make static arrays with this scheme. 

#-------------------------------------------------------------------------------
proc main_stest {} {

  puts ""
  puts "static TEST ..."
  puts ""

  stest
  stest

  puts ""

  return
}
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
proc PROC {args} {

  # Unpack arguments.

  if       {[llength $args] == 3} {
    lassign $args  name arguments script

  } elseif {[llength $args] == 4} {
    lassign $args  name arguments statics script

    # и надо добавить статические переменные в скрипт (в начало)
    # 
    set newscript {}

    foreach s $statics {

      if { [llength $s] == 1} {
        set var $s
        #
        # посмотрим, может переменая определена выше?

        set ret [uplevel 1  info exists $var]

        if {$ret} {
          set val [uplevel 1  set $var]
          #puts "this variable exist: $var = ....... $val"
        } else {
          set val ""
        }

      } else {
        set var [lindex $s 0]
        set val [lindex $s 1]
      }

      append newscript "static $var $val"  
      append newscript { ; }
    }

    append newscript $script

    set script $newscript

  } else {
    error "wrong # args: should be\
          \"sproc name arguments ?statics? script\""
  }
    
  proc $name $arguments $script

}
#-------------------------------------------------------------------------------
# In addition to procedure arguments, Jim procedures may declare 
# static variables. These variables scoped to the procedure and 
# initialised at procedure definition. Either from the static variable 
# definition, or from the enclosing scope.
# 
#-------------------------------------------------------------------------------
proc main_PROC_test {} {

  puts ""
  puts "main_PROC_test ..."
  puts ""
  
  #------------------------------------
  PROC notstatic {var1 {var2 "var2"} var3} {
    
    static a 10
    static b
    static c

    #puts "a = $a, b = $b, c = $c"
    puts "var1= $var1, var2= $var2:   a = $a, b = $b, c = $c"

    incr c

  }

  #------------------------------------

  # The static variable a has no initialiser, so it is initialised from 
  # the enclosing scope with the value 1. (Note that it is an error if 
  # there is no variable with the same name in the enclosing scope). 
  # However b has an initialiser, so it is initialised to 2.

  set a 20

  #------------------------------------
  PROC jimstatic  {var1 {var2 "var2"}} {a {b 2}} {

    set c 1

    puts "var1= $var1, var2= $var2:   a = $a, b = $b, c = $c"

    incr a
    incr b
    incr c

  }
  #------------------------------------

  notstatic Gena   @    var3
  notstatic Bory !!!!  var3

  puts ""

  jimstatic "A"
  jimstatic "B" "varC"

  puts ""

  return
}
#-------------------------------------------------------------------------------

main_stest

main_PROC_test

#-------------------------------------------------------------------------------
proc exists_command {comm} {

  #exists -command $comm

  #puts "exists_command: comm = $comm"
  #puts "exists_command: info = [info commands B* ]"
  #puts "exists_command: info = [info commands $comm]"
  #exit

  set ret [info commands $comm]

  return [llength $ret]
}
#-------------------------------------------------------------------------------

PROC class {classname {baseclasses {}} classvars} {

  set baseclassvars {}

  puts "01 ............."

  foreach baseclass $baseclasses {

    # Start by mapping all methods to the parent class
    foreach method [$baseclass methods] { alias "$classname $method" "$baseclass $method" }

    # Now import the base class classvars
    set baseclassvars [dict merge $baseclassvars [$baseclass classvars]]

    # The last baseclass will win here
    PROC "$classname baseclass" {} baseclass { return $baseclass }
  }
  
  # Merge in the baseclass vars with lower precedence
  set classvars [dict merge $baseclassvars $classvars]
  set vars [lsort [dict keys $classvars]]
  
  # This is the class dispatcher for $classname
  # It simply dispatches 'classname cmd' to a procedure named {classname cmd}
  # with a nice message if the class procedure doesn't exist

  PROC $classname {{cmd new} args} classname {

    puts "05 1 ............."
      
    if {![exists_command "$classname $cmd"]} {

      return -code error "$classname, unknown command \"$cmd\": should be [join [$classname methods] ", "]"
    }

    puts "05 2 ............."
    puts "$classname $cmd : {*}$args"
    puts ""

    tailcall "$classname $cmd" {*}$args
  }
  
  puts "02 ............."

  #------------------------------------------------------------------------
  # Constructor
  #------------------------------------------------------------------------
  # gnodvi proc "$classname new" {{instvars {}}} {classname classvars} {}
  PROC "$classname new" {{instvars__ {}}} {classname classvars} {

    # gnodvi: set instvars [dict merge $classvars $instvars]
    # gnodvi: save arglist for next call
    #
    set instvars [dict merge $classvars $instvars__]
    
    # This is the object dispatcher for $classname.
    # Store the classname in both the ref value and tag, for debugging
    # ref tag (for debugging)

    set obj [ref $classname $classname "$classname finalize"]


    PROC $obj {method args} {classname instvars} {

      if {![exists -command "$classname $method"]} {
        if {![exists -command "$classname unknown"]} {
          return -code error "$classname, unknown method \"$method\": should be [join [$classname methods] ", "]"
        }
        return ["$classname unknown" $method {*}$args]
      }

      "$classname $method" {*}$args
    }


    if {[exists -command "$classname constructor"]} {
      #puts "instvars__ = $instvars__"

      set info_args [info args "$classname constructor"]
      #puts "info args = $info_args"

      if {$info_args == ""} {
        $obj constructor 
      } else {
        $obj constructor $instvars__
      }

      #$obj constructor $instvars__
      #$obj constructor 
      #if {$instvars__ != ""} {
      #  $obj constructor $instvars__
      #}
    }

    #puts stderr "!!!!!!!!!!!!!! NEW !!!!!!!!!!!!!!!!!!!!!!"
    #puts stderr "instvars = $instvars ,,,,, instvars__ = $instvars__"
    #puts stderr "!!!!!!!!!!!!!! NEW !!!!!!!!!!!!!!!!!!!!!!"

    return $obj
  }
  #------------------------------------------------------------------------

  puts "03 ............."

  # Finalizer to invoke destructor during garbage collection
  PROC "$classname finalize" {ref classname} { $ref destroy }

  # Method creator
  PROC "$classname method" {method arglist __body} classname {

    PROC "$classname $method" $arglist {__body} {

      # Make sure this isn't incorrectly called without an object
      if {![uplevel exists instvars]} {
        return -code error -level 2 "\"[lindex [info level 0] 0]\" method called with no object"
      }
      set self [lindex [info level -1] 0]
      # Note that we can't use 'dict with' here because
      # the dict isn't updated until the body completes.

      foreach __ [$self vars] {upvar 1 instvars($__) $__}
      unset __
      eval $__body
    }
  }

  puts "04 ............."

  # Other simple class procs

  PROC "$classname vars"      {} vars      { return $vars }
  PROC "$classname classvars" {} classvars { return $classvars }
  PROC "$classname classname" {} classname { return $classname }
  PROC "$classname methods"   {} classname {
    lsort [lmap p [info commands "$classname *"] {
      lindex [split $p " "] 1
    }]
  }

  puts "05 ............."

  # Pre-defined some instance methods

  $classname method destroy {}    { rename $self "" }

  puts "06 ............."
  $classname method get     {var} { set $var }
  puts "07 ............."
  $classname method eval   {{locals {}} __code} {
    foreach var $locals { upvar 2 $var $var }
    eval $__code
  }

  puts "08 ............."

  return $classname
}
#-------------------------------------------------------------------------------
proc test_CLASS {} {


  proc classtest {classname {baseclasses {M N O}} classvars} {

    puts ""
    puts "classname   = $classname"
    puts "baseclasses = $baseclasses"
    puts "classvars   = $classvars"
    puts ""
  }

  classtest C WW {a A}



  class A {} {
    
    balance 0
    name    "Unknown"
  }

# invalid command name "exists"
#     while executing
# "exists -command "$classname $cmd""

}
#-------------------------------------------------------------------------------

test_CLASS

#-------------------------------------------------------------------------------
