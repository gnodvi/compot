# -*-   mode: sh   ; coding: koi8   -*- ----------------------------------------

#!/bin/sh
# \
exec tclsh "$0" ${1+"$@"}
# 
#-------------------------------------------------------------------------------
# https://wiki.tcl-lang.org/page/sproc
#-------------------------------------------------------------------------------

# sproc

# AMG: I developed the following code so I could have multiple "instantiations" 
# of a static-enabled proc, where each instantiation has its own independent copies 
# of the static variables. All instantiations share the same bytecode-compiled proc 
# body.
# Implementation
#-------------------------------------------------------------------------------

proc sproc {args} {

  # Unpack arguments.

  if       {[llength $args] == 4} {
    lassign $args name arguments statics script

  } elseif {[llength $args] == 5} {
    lassign $args name arguments statics init script

  } else {
    error "wrong # args: should be\
          \"sproc name arguments statics ?init? script\""
  }
    
  # Bind to the sproc's data array.

  set ns [uplevel 1 {namespace current}]
  upvar #0 $ns\::Sproc-$name data
  if {[info exists data]} {
      error "sproc \"$name\" already exists"
  }

  # Initialize the data array.

  set data(next) 0
  set data(instances) [dict create]

  set data(lambda) [list $arguments\
      "dict with [list $ns\::Sproc-$name](\[namespace tail\
          \[lindex \[info level 0\] 0\]\]) {$script}"]

  set data(statics) $statics
  if {[info exists init]} {
      set data(init) $init
  }

  #----------------------------------------------------------------
  # Create the sproc's instantiation proc.
  #----------------------------------------------------------------
  proc $ns\::$name {args} {

    # Bind to the sproc's data array.
    set name [namespace tail [lindex [info level 0] 0]]
    upvar #0 [namespace current]::Sproc-$name data

    # Find a unique name for the sproc instance proc.
    set others [info commands $name*]
    while {1} {
      set nameid $name$data(next)
      incr data(next)
      if {$nameid ni $others} {
          break
        }
    }
    dict set data(instances) $nameid ""
    
    # Create the sproc instance proc.
    proc $nameid {*}$data(lambda)

    # When the sproc instance proc is deleted, remove the sproc instance
    # from the sproc's data array.
    trace add command $nameid delete [list apply {{ns name cmd args} {
        upvar #0 $ns\::Sproc-$name data
        unset data([namespace tail $cmd])
        dict unset data(instances) [namespace tail $cmd]
    }} [namespace current] $name]

    # Add the sproc instance's statics to the data array.  Customize the
    # statics for this instance with any arguments which may have been
    # passed to the instantiation proc, and execute the initialization
    # script, if one was provided when the sproc was defined.
    set data($nameid) [dict replace $data(statics) {*}$args]
    if {[info exists data(init)]} {
        if {[catch {dict with data($nameid) $data(init)} result options]} {
          # If the script raised an error, delete the sproc instance and
          # pass the error to the caller.
          rename $nameid ""
          return -options $options $result
       }
    }

    # Return the name of the sproc instance proc.

    return [namespace current]::$nameid
  }
  #----------------------------------------------------------------

  # When the sproc instantiation proc is deleted, delete the sproc's data
  # array and all instances of the sproc.
  trace add command $ns\::$name delete [list apply {{ns name args} {
    upvar #0 $ns\::Sproc-$name data
    foreach instance [dict keys $data(instances)] {
      catch {rename $ns\::$instance ""}
    }
    unset data

  }} $ns $name]

  # Return the name of the sproc instantiation proc.

  return $ns\::$name
}
#-------------------------------------------------------------------------------

# Documentation
# Defining a sproc

# [sproc name args statics ?init? script] creates a sproc called name that accepts 
# arguments args, has static variables statics, and has body script. It returns 
# name. If init is provided, it is executed every time the sproc is instantiated 
# (see below).

#  - name can be any name.
#  - args can be any proc-style argument list. Ordinary, defaulted, and variadic 
#    arguments are supported.
#  - statics is a dict mapping from static variable names to initial values. 
#    Contrast this with defaulted arguments, in which each argument is a two-element 
#    list.
#  - init can be any script. It is executed with the static variables in scope, and 
#    it can modify or unset them. It cannot create new static variables.
#  - script can be any script. It does not need to do anything special in order to 
#    access or modify static variables or any other kind of variables.

# Creating an instance

# [name ?var1 val1 var2 val2 ...?], where name is a previously-defined sproc, 
# creates an instance of the sproc with optionally overridden or augmented static 
# variables var1, var2, etc. assigned to have initial values val1, val2, etc., 
# respectively. It returns the name of the instance. If an init script was 
# provided to [sproc] (above), it is executed with the static variables in 
# scope so it can further customize them and/or access other resources, such 
# as files, a GUI, or the console. If the init script fails, the instance command 
# is not created, and the error is passed to the caller.

#  - name must be a sproc already defined by [sproc], above.
#  - var1, var2, etc. are the names of additional static variables to define for 
#    this instance. They can optionally be the same as names defined in the initial 
#    [sproc] invocation.
#  - val1, val2, etc. are the initial values of the additional or overridden 
#    static variables.

#-------------------------------------------------------------------------------
# Invoking an instance

# [instance ?...?], where instance is a name returned by the name sproc invocation, 
# calls the sproc instance. Arguments are passed as normal. The sproc script body 
# is able to freely access and modify static variables, which persist between 
# subsequent invocations of the same instance. Static variables are not shared 
# between separate instances of the same sproc.
# Deleting an instance

# Deleting instance (a sproc instance) with rename instance "" removes it from 
# the sproc's associated data structure.

# Deleting a sproc

# Deleting name (a sproc) with rename name "" deletes its associated data structure 
# and all its instances.

# Internal data structure

# Each sproc has an associated data structure named Sproc-name, where name is 
# the name of the sproc. It is an array containing the following variables:

#  - Sproc-name(next): The numeric ID of the next instance to be created.
#  - Sproc-name(init): Initialization script to run when each instance is created. 
#    This element is only present in the array if an initialization script was 
#    provided when the sproc was defined.
#  - Sproc-name(instances): Dictionary whose keys are the names of all current 
#    instances of the sproc. The values are all empty string.
#  - Sproc-name(lambda): Lambda definition of an instance of the sproc.
#  - Sproc-name(statics): Default dictionary mapping from static variable names 
#    to initial values. This mapping can be augmented or overridden when creating 
#    an instance of the sproc.
#  - Sproc-name(instance): Dictionary mapping from static variable names to 
#    current values for the sproc instance named instance.

# Demonstration and testing
# Basic functionality

#-------------------------------------------------------------------------------
proc basic_functionality {} {


sproc counter {{increment 1}} {value 0} {

  incr value $increment
}
# ::::counter

set p [counter]
# ::::counter0

set q [counter value 10]
# ::::counter1

puts [$p]
# 1

puts [$p 5]
# 6

puts [$q 0]
# 10

#---------------------------------------------------------------------
sproc logger {text} {} {puts "$id: instantiating"} {

  puts "$id: $text"
}

# ::::logger

#set r [logger]
# can't read "id": no such variable

# % set r [logger id test]
# test: instantiating

# ::::logger1

# % $r "message #1"
# test: message #1

puts ""
}
#-------------------------------------------------------------------------------

#Internal data structure

# % parray Sproc-counter

# Sproc-counter(counter0)  = value 6
# Sproc-counter(counter1)  = value 10
# Sproc-counter(instances) = counter0 {} counter1 {}
# Sproc-counter(lambda)    = {{increment 1}} {dict with ::::Sproc-counter([list [namespace tail [lindex [info level 0] 0]]]) {incr value $increment}}
# Sproc-counter(next)      = 2
# Sproc-counter(statics)   = value 0
# % parray Sproc-logger
# Sproc-logger(init)      = puts "$id: instantiating"
# Sproc-logger(instances) = logger1 {}
# Sproc-logger(lambda)    = text {dict with ::::Sproc-logger([namespace tail [lindex [info level 0] 0]]) {puts "$id: $text"}}
# Sproc-logger(logger1)   = id test
# Sproc-logger(next)      = 2
# Sproc-logger(statics)   = 

#-------------------------------------------------------------------------------
# Instance deletion

# % rename $p ""
# % parray Sproc-counter
# Sproc-counter(counter1)  = value 10
# Sproc-counter(instances) = counter1 {}
# Sproc-counter(lambda)    = {{increment 1}} {dict with ::::Sproc-counter([list [namespace tail [lindex [info level 0] 0]]]) {incr value $increment}}
# Sproc-counter(next)      = 2
# Sproc-counter(statics)   = value 0

#-------------------------------------------------------------------------------

# Sproc deletion


#-------------------------------------------------------------------------------
# % rename counter ""
# % parray Sproc-counter
# "Sproc-counter" isn't an array
# % $q
# invalid command name "counter1"

#-------------------------------------------------------------------------------

# Namespace support

#-------------------------------------------------------------------------------

# % namespace eval child {
#      sproc counter2 {prefix {increment 1}} {value 0} {
#         puts "$prefix[incr value $increment]"
#      }
#   }
# ::child::counter2
# % counter2 value 20
# invalid command name "counter2"
# % namespace eval child {counter2 value 20}
# ::child::counter20
# % counter20
# invalid command name "counter20"
# % ::child::counter20
# wrong # args: should be "::child::counter20 prefix ?increment?"
# % ::child::counter20 value=
# value=21
# % namespace delete child

#-------------------------------------------------------------------------------

# Limitations
# No arrays

# Static variables cannot be arrays. Use dicts instead. This makes it impossible 
# to create traces or upvar aliases on individual elements of an array-like static 
# variable.
# Limited traces

# Traces can be set on static variables, but they have to be set inside the sproc 
# script body. In other words, they have to be recreated every time the sproc 
# instance is invoked. They will not detect access to the static variables outside 
# of the sproc script body, e.g. by directly modifying the internal data structure.
# No renaming

# Renaming sprocs or sproc instances is not supported, and using rename to move 
# from one namespace to another is certainly out-of-bounds. Instead use [interp alias]. 
# The only allowed use of [rename] is to delete sprocs and sproc instances.
# Techniques used in implementation

# AMG: I wanted to avoid customizing each sproc instance's script body, so I needed 
# some other way of communicating its unique ID into the (generic) script body. 
# Since I want this code to be easy to use, this must be done automatically. I guess 
# I could have used [interp alias] to curry an ID argument into the invocation, but 
# I didn't want to confuse [info args]. Instead I took advantage of the proc name 
# being a sort of hidden parameter, which is accessed using [lindex [info level 0] 0]. 
# In the case of the sproc (the procedure that creates instances), this gives the 
# name of the sproc. In the case of the instances themselves, this gives the 
# instance name, and the sproc name was already compiled into the lambda and doesn't 
# need to be looked up dynamically.

# To make accessing the sproc or instance data easier, I used [upvar #0] to link a 
# global variable to a local variable simply named "data".

# I didn't want to generate any procs not intended to be called by the user of this
#  code, so I instead used [apply] to do the [trace] scripts.

# I did my best to facilitate bytecode sharing between all sprocs or between 
# all instances of any given sproc. To do the former, I wrote generic code that 
# dynamically figures out the sproc name using the trick described above. To 
# do the latter, I generate one lambda to be used for all instances of a sproc, 
# again dynamically figuring out the instance name. The name works somewhat 
# like a "this" pointer in C++.

# I was disappointed to discover that [info level 0] is not fooled by [interp 
# alias], that it gives the real target proc name not the alias. If not for this, 
# I would have simply made a generic instance proc and instantiated the sproc 
# by creating aliases. But so it turned out, I had to make a separate proc for 
# each instance. (This is better anyway because it enables deletion through 
# rename instance "".) I wanted for the separate procs to share bytecode, so I 
# wrote proc $nameid {*}$data(lambda).

# To support deleting all instances when the sproc is deleted, I must maintain 
# a list of instances. But I didn't want to write code to search-and-destroy 
# through the instance list on instance deletion, so I used [dict unset] on a 
# dict with empty string for the values. In this way I make a set using a dict.

# I mix arrays and dicts for a couple reasons. I use arrays in the first place 
# to make it possible to use [upvar #0] to link an element to a local variable. 
# But I need further hierarchy, and since arrays don't nest (anymore...), I use 
# a dict.

# Invoking [namespace current] inside a proc returns the namespace in which the 
# proc is currently located. To get the namespace of the caller, I use [uplevel 
# 1 [namespace current]]].

# To facilitate sharing lambdas between all the command deletion traces, I don't 
# make use of the third lambda element. Instead I pass the desired namespace as 
# an argument to [apply]. Besides, [upvar] doesn't seem to do what I want anyway, 
# so I would have needed to call [namespace current] inside the lambda to get the 
# right variable. Might as well just pass the namespace name as an argument!

#-------------------------------------------------------------------------------

# Change history

# AMG, 2009 Jan 26: Initial implementation.

# AMG, 2009 Jan 27: Corrected namespace support. Corrected possible collisions 
# when sproc names end in numerals.

# AMG, 2009 Jan 31: Added comments and blank lines. Changed to four-space tabs. 
# Added support for initialization scripts.
# Discussion

# AMG: Do all sproc instances really share the same bytecode-compiled script body? 
# Somebody please confirm this for me.

# DKF: Probably not (procedures mostly don't share for various reasons) but I'd 
# not guarantee it.

# AMG: How can I check? Is there something I can look at in gdb? If they don't 
# share, is there a way I can make them share? In other words, under what 
# circumstances will two procs share bytecode?

# AMG: It seems that upvar #0 globalvar localvar always binds to ::globalvar (i.e. 
# in the global namespace). I would have expected it to bind to globalvar in the 
# proc's [namespace current] namespace. Why?

# AMG: The man page for [namespace current] reads: Returns the fully-qualified 
# name for the current namespace. The actual name of the global namespace is "" 
# (i.e., an empty string), but this command returns :: for the global namespace 
# as a convenience to programmers.

# More like inconvenience! This behavior is the reason for all the ::::'s. What 
# should I do about this?

# Lars H: They're mostly harmless \u2014 any sequence of two or more colons 
# count as a namespace separator, so ::::my and ::my are equivalent as names of 
# commands, variables, and namespaces. The case where they can be awkward is 
# when working with aliases, since actions on existing aliases (e.g. interp 
# target, interp alias for introspection, etc.) requires exact string equality, 
# but this is because ::::my and ::my can really be two distinct aliases; see 
# interp aliases for details.

# AMG: See also Procedures stored in arrays.

#-------------------------------------------------------------------------------
proc main {} {

  puts ""
  puts "s_proc TEST ..."
  puts ""

  basic_functionality 

  return
}
#-------------------------------------------------------------------------------

main

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
