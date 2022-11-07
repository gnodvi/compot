# -*-   mode: tcl  ; coding: koi8   -*- ----------------------------------------

#-------------------------------------------------------------------------------
# 
if [info exists ::A_DISP_TL] {
  return
} else {
  set  ::A_DISP_TL ""
}

#-------------------------------------------------------------------------------
# http://wiki.tcl.tk/924

# MAK: While working on optimizations for TkPNG, alternating between using time 
# and gprof for various measurements, I was sometimes seeing my numbers change 
# in odd ways with some going up and some going down for a change that should 
# affect all images in one direction or the other. So I was interested in seeing 
# error margins to prove to myself I wasn't insane. So I whipped up this 
# "errortime" proc. It works similarly to time, but it runs the script through 
# time with a given group size and does so the specified number of times, then 
# calculates a new average and error margin.

proc errortime {script groupsize {iters 2}} {

  set i 0
  set times {} 
  if {$iters < 2} {set iters 2}
  
  for {set i 0} {$i < $iters} {incr i} {
    set result [uplevel [list time $script $groupsize]]
    lappend times [lindex $result 0]
  }
  
  set average 0.0
  set s2 0.0
  
  foreach time $times {
    set average [expr {$average + double($time)/$iters}]
  }
  
  foreach time $times {
    set s2 [expr {$s2 + (($time-$average)*($time-$average) / ($iters-1))}]
  }
  
  set sigma [expr {int(sqrt($s2))}]
  set average [expr int($average)]
  
  return "$average +/- $sigma microseconds per iteration"
}
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------

# http://wiki.tcl.tk/4715

# dispatch
# Updated 2013-01-06 21:58:48 by dkf
#-------------------------------------------------------------------------------

# Joe Mistachkin

# https://github.com/mistachkin

#-------------------------------------------------------------------------------

# This is a new control structure that I created an use extensively in my own 
# code. I am posting it because I think it may be useful to other people as well. 
# Please feel free to comment and/or criticize this code.

# 22Nov02 - Brian Theado - How about a brief description on what is does/what it 
# is good for? I'm pretty slow at reading code and it is taking me longer to 
# figure out what this is than I want to spend. By glancing at the code, it looks 
# similar to the switch statement. Is that the case?

# 24Nov02 - Joe Mistachkin - Yes, it is similar to a switch statement. The primary 
# way that they differ is that dispatch supports fully "dynamic" cases. Cases can 
# be matched on any valid literals, variables, or commands. Matching can be done 
# in all "standard" modes (exact, glob, regexp, and nocase). In the situation 
# where there may be more than one match, only the first matching case is 
# evaluated. Conforms to all other "standard" switch command behavior. See below 
# for examples.

# 21Aug03 - Lars H - While examples of making your own control structures are 
# often useful, it looks to me as though this is mostly doing things that the 
# first form of switch (no {} around the list of patterns and bodies, hence one 
# can subject the patterns to all sorts of substitutions) already provides. Or 
# am I overlooking something? The -nocase option can be done with explicit 
# [string tolower], although with variable patterns one might need a lot of 
# these. The -expr option I don't quite understand.

#-------------------------------------------------------------------------------
proc examples {} {

 puts ""

 #
 # Example #1 (variables and commands)
 #

 set case_1 "this"
 set case_2 "that"
 set case_3 "foo"

 set string_to_match "THIS"

 dispatch -exact -nocase -- $string_to_match {
   $case_1 {
     # NOTICE we used a variable for this?
     puts stdout "MATCHED case #1."
   }
   $case_2 {
     # NOTICE we used a variable for this?
     puts stdout "MATCHED case #2."
   }
   $case_3 {
     # NOTICE we used a variable for this?
     puts stdout "MATCHED case #3."
   }
   [string trim $string_to_match] {
     # this case refers to the trimmed version of itself 
     # (the variable being matched), variations on this 
     # could prove quite useful.
     puts stdout "MATCHED trimmed version of self."
   }
   "literal" -
   default {
     # NOTE: the above "literal" case would fall through to this case.
     puts stdout "MATCHED default."
   }
 }

 #---------------------------------------
 #
 # Example #2 (use with regexp):
 #

 set email_regexp {^([0-9A-Za-z])([0-9A-Za-z_\.\-]*)@([0-9A-Za-z])([0-9A-Za-z\.\-]*)$}

 set string_to_match "billy@mistachkin.com"
 
 dispatch -regexp -nocase -- $string_to_match {
   $email_regexp {
     # NOTICE we used a variable for this?
     puts stdout "MATCHED, valid email address."
   }
   default {
     puts stdout "MATCHED default."
   }
 } 

 puts ""

 return
}
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
# Main Source File (dispatch.tcl)
#-------------------------------------------------------------------------------


###############################################################################
#
# Tcl dispatch command
#
# Copyright (c) 2001-2003 by Joe Mistachkin.  All rights reserved.
#
#  written by: Joe Mistachkin <joe@mistachkin.com>
#  created on: 10/07/2001
# modified on: 08/21/2003
#
#-------------------------------------------------------------------------------
 
 # REQUIRES Tcl 8.0+
 #package require "Tcl" "8.0"
 
 # maximum possible number of arguments for dispatch proc
 set dispatch_maximum_arguments "8"
 
 # dispatch error string
 set dispatch_argument_error "wrong # args: should be \"dispatch ?switches? string pattern body ... ?default body?\""
 
 # THESE are ALL the allowed switches for the dispatch proc
 # (except for "--", which is a special case)
 set dispatch_switches [list "-exact" "-nocase" "-expr" "-glob" "-regexp" "-all"]
 
 # dispatch switch error string
 set dispatch_switch_error "bad option, must be one of: $dispatch_switches"
 
 # do not change this
 set dispatch_name "Tcl_dispatch"
 
 # do not change this
 set dispatch_version "2.7"

#-------------------------------------------------------------------------------
proc dispatch_terminate {} {

  global dispatch_name
  #
  # forget package
  #
  package forget $dispatch_name
  
  #
  # kill vars
  #
  foreach this_global [info globals] {
    if {[string match "dispatch_*" $this_global] != "0"} then {
      # nuke variable in global scope... (dead)
      uplevel "#0" unset $this_global
    }
  }
  
  #
  # kill procs
  #
  rename dispatch ""
  rename dispatch_internal ""
  rename valid_switch ""
  rename check_switch ""
  rename dispatch_terminate ""
  
  return "0"
}
#-------------------------------------------------------------------------------
proc dispatch_internal {dispatch_exact dispatch_nocase dispatch_expr 
                          dispatch_glob dispatch_regexp dispatch_all 
                          dispatch_end dispatch_level dispatch_string 
                          dispatch_body } {

  global dispatch_argument_error
  #
  # NOTE: This does NOT function EXACTLY the same as the "switch" command, but it's pretty darn close.
  #
  # 1. ALL of the standard switches for "switch" are supported plus "-nocase".
  # 2. default case can be anywhere (matching STOPS when it is found).
  # 3. string variables ARE supported (the main reason this proc exists).
  # 4. commands are supported for the PATTERNS as well as the script bodies
  #    (must be enclosed in curly braces)...
  #
  # NOTE: Obviously, the length of the dispatch_body argument list must be divisible by 2.
  #
  set result ""
  
  # must have some elements dispatch_body...

  if {[llength $dispatch_body] > "0"} then {

    # must have even number of elements in dispatch_body
    if {[llength $dispatch_body] % "2" == "0"} then {
      #
      # initially, we will return null if nothing matches...
      # same as switch
      #
      set evaluated "0"
      set matched "0"

      foreach {this_pattern this_body} $dispatch_body {
        #
        # make sure we aren't just searching for a proc body
        #
        if {$matched == "0"} then {
          #
          # check if it's the default
          #
          if {$this_pattern == "default"} then {
            # THIS ALWAYS MATCHES, regardless of switches
             # presumably, default is the last one
            set matched "1"
          } else {
            #
            # check if string variable
            #
            if {[string index $this_pattern "0"] == "\$"} then {
              # get variable name portion only
              set variable_name [string range $this_pattern "1" "end"]
              
              # unset in case we set it previously
              # BUGFIX: SQUASH annoying error messages in errorInfo!
              if {[info exists variable_value] != "0"} then {
                catch {unset variable_value}
              }
              #
              # get variable value from calling proc
              # (could this be done better with upvar?)
              #
              # this needs the [list] command to account for the pathological 
              # case of {this_happy variable_name}.
              #
              set variable_value [uplevel $dispatch_level [list set $variable_name]]
            } else {
              #
              # command, interesting...
              #
              if {[string index $this_pattern "0"] == "\["} then {
                # get command portion only
                set variable_name [string range $this_pattern "1" "end-1"]
                
                # just evaluate the command using uplevel...
                # [list] is not required here, $variable_name contains a 
                # complete command in proper form list form.
                set variable_value [uplevel $dispatch_level $variable_name]
              } else {
                #
                # must be some kind of string constant
                #
                set variable_value $this_pattern
              }
            }
            
            if {$dispatch_regexp != "0"} then {
              #
              # regexp (for experts only!)
              #
              if {$dispatch_nocase != "0"} then {
                #
                # case insensitive specified
                # check if we matched the value...
                #
                if {[regexp -nocase -- $variable_value $dispatch_string] != "0"} then {
                  set matched "1"
                } else {
                  set matched "0"
                }
              } else {
                #
                # case sensitive is the default
                # check if we matched the value...
                #
                if {[regexp -- $variable_value $dispatch_string] != "0"} then {
                  set matched "1"
                } else {
                  set matched "0"
                }
              }
            } else {

              if {$dispatch_glob != "0"} then {
                #
                # string match (always a family favorite)
                #
                if {$dispatch_nocase != "0"} then {
                  #
                  # case insensitive specified
                  # check if we matched the value...
                  #
                  if {[string match [string tolower $variable_value] [string tolower $dispatch_string]] != "0"} then {
                    set matched "1"
                  } else {
                    set matched "0"
                  }
                } else {
                  #
                  # case sensitive is the default
                  # check if we matched the value...
                  #
                  if {[string match $variable_value $dispatch_string] != "0"} then {
                    set matched "1"
                  } else {
                    set matched "0"
                  }
                }
              } else {
                if {$dispatch_expr != "0"} then {
                  #
                  # NEW: check to see if the truth value of the dispatch arm by itself is non-zero
                  #      (it may have a dynamic value).
                  #
                  if {[expr {int($variable_value)}]} then {
                    set matched "1"
                  } else {
                    set matched "0"
                  }
                } else {
                  # dispatch_exact is the default
                  if {$dispatch_nocase != "0"} then {
                    #
                    # case insensitive specified
                    # check if we matched the value...
                    #
                    if {[string tolower $dispatch_string] == [string tolower $variable_value]} then {
                      set matched "1"
                    } else {
                      set matched "0"
                    }
                  } else {
                    #
                    # case sensitive is the default
                    # check if we matched the value...
                    #
                    if {$dispatch_string == $variable_value} then {
                      set matched "1"
                    } else {
                      set matched "0"
                    }
                  }
                }
              }
            }
          }
        }
        
        if {$matched != "0"} then {
          #
          # check for "search for next proc body" like switch does
          #
          if {$this_body == "-"} then {

            #puts "this_body == -"  ;# pilot
            #
            # skill skipping to next script body...
            #
            continue

          } elseif {$this_body == "+"} {

            # TODO: нужно выполнить код и сразу на след. шаблон
            # 

            continue

          } else {
            #
            # evaluate this script body (IN THE PROPER LEVEL) and exit loop
            # [list] is not required at this level because the body is a script, not a command.
            #
            set result [uplevel $dispatch_level $this_body]
            set evaluated "1"
            set matched "0"
            
            if {$dispatch_all == "0"} then {
              #
              # if they are NOT allowing multiple (default)
              # break out of loop
              #
              break
            }
          }

        }
      }
      
      set dispatch_error "0"
    } else {
      set dispatch_error "1"
    }
  } else {
    set dispatch_error "1"
  }
  
  if {$dispatch_error != "0"} then {
    error $dispatch_argument_error
  }
  
  return $result
} 
#-------------------------------------------------------------------------------
proc check_switch { argument variable_name force } {

  #
  # simply see if passed argument is a supported option
  #
  if {[string index $argument "0"] == "-"} then {

    if {$variable_name != ""} then {

      set switch_name [string range $argument "1" "end"]
      
      # get a handle on the variable (array) that we need to modify
      upvar "1" $variable_name switches
      
      # if always allow or if the switch is actually considered valid...
      if {(($force != "0") || ([info exists switches($switch_name)] != "0"))} then {
        # value 1 means "switch enabled"
        set switches($switch_name) "1"
        
        # value 1 means "processed switch"
        set result "1"
      } else {
        if {[string is integer -strict $argument] != "0"} then {
          # set the integer value for use in the future...
          set switches(value) $argument
          
          # value 1 means "processed switch"
          set result "1"
        } else {
          # value 2 means "invalid switch"
          set result "2"
        }
      }
    } else {
      # value 0 means "did NOT process switch"
      set result "0"
    }
  } else {
    # value 0 means "did NOT process switch"
    set result "0"
  }
  
  return $result
}
#-------------------------------------------------------------------------------
proc valid_switch { argument variable_name } {

  #
  # check if valid switch (is it in the list?)...
  #
  if {[string index $argument "0"] == "-"} then {

    if {$variable_name != ""} then {

      if {$argument == "--"} then {
        # value 4 means "end of switches"
        # (this is always a valid switch)
        set result "4"
      } else {
        if {(([string index $argument "0"] == "-") && ([string is integer -strict [string range $argument "1" "end"]] != "0"))} then {
          # this is the integer value for use in the future...
          # value 3 means "valid switch"
          set result "3"
        } else {
          upvar "1" $variable_name valid_switches
          
          if {[lsearch $valid_switches $argument] != "-1"} then {
            # value 3 means "valid switch"
            set result "3"
          } else {
            # value 2 means "not a supported switch"
            set result "2"
          }
        }
      }
    } else {
      # value 1 means "invalid variable name" (in this context)
      set result "1"
    }
  } else {
    # value 0 means "not a switch OR not a supported switch"
    set result "0"
  }
  
  return $result
}
#-------------------------------------------------------------------------------
proc dispatch { args } {

  #
  # This is the OUTER dispatch proc.  It handles translation of switches
  # and then forwards the request to dispatch_internal.
  #
  global dispatch_argument_error
  global dispatch_maximum_arguments
  global dispatch_switch_error
  global dispatch_switches
  
  set result ""
  
  # the integer value for use in the future...
  set switches(value) "0"
  
  # all the possible switches...
  set switches(exact)  "0"
  set switches(nocase) "0"
  set switches(expr)   "0"
  set switches(glob)   "0"
  set switches(regexp) "0"
  set switches(all)    "0"
  set switches(end)    "0"
  
  set count [llength $args]
  
  if {$count <= $dispatch_maximum_arguments} then {
    #
    # this loop is trying to find "the first non-switch argument"...
    #
    set invalid "0"
    set found "0"
    set index "0"

    while {(($index < $count) && ($found == "0") && ($invalid == "0"))} {

      set is_switch [valid_switch [lindex $args $index] dispatch_switches]
      
      switch -exact -- $is_switch {
        "0" {
          #
          # we are done, we found an actual non-switch argument...
          #
          set found "1"
        }
        "1" {
          #
          # invalid...
          #
          set invalid "1"
        }
        "2" {
          #
          # we are done, we found an invalid switch...
          #
          set invalid "1"
        }
        "3" {
          #
          # found a valid switch, process it
          #
          check_switch [lindex $args $index] switches "1"
          
          # skip to next index now
          set index [expr {$index + "1"}]
        }
        "4" {
          #
          # found FINAL switch, process it
          #
          check_switch [lindex $args $index] switches "1"
          
          # skip to next index now
          # next argument, this is still a switch
          set index [expr {$index + "1"}]
          
          set found "1"
        }
        default {
          # we found something invalid...???
          set invalid "1"
        }
      }
    }
    
    if {$found != "0"} then {

      # we must have at least two arguments left...

      if {$index < ($count - "1")} then {
        # what are we dispatching on?
        set dispatch_string [lindex $args $index]
        # advance to the next argument.
        set index [expr {$index + "1"}]
        # this is the body that contains the different possible matches...
        set dispatch_body [lindex $args $index]
        #
        # the magic number "2" in this command is the
        # parameter required for the uplevel commands
        # contained within dispatch_internal
        #

        set result [dispatch_internal \
                      $switches(exact) $switches(nocase) $switches(expr) $switches(glob) $switches(regexp) $switches(all) $switches(end) "2" \
                      $dispatch_string $dispatch_body]
        
        set dispatch_error "0"
      } else {
        set dispatch_error "1"
      }
    } else {
      if {$invalid != "0"} then {
        set dispatch_error "2"
      } else {
        set dispatch_error "1"
      }
    }
  } else {
    set dispatch_error "1"
  }
  
  switch -exact -- $dispatch_error {
    "1" {
      error $dispatch_argument_error
    }
    "2" {
      error $dispatch_switch_error
    }
  }
  
  return $result
}
#-------------------------------------------------------------------------------
 
# loaded OK, provide package
# package provide $dispatch_name $dispatch_version

# // end of file
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------

# Version History

#   07/Oct/2001 Version 1.00 -- initial version
#   19/Nov/2002 Version 2.40 -- initial public release version
#   06/May/2003 Version 2.60 -- updated, various internal changes
#   21/Aug/2003 Version 2.70 -- updated, added -expr switch, minor tweaks

# elfring 2003-11-01 Is there a relationship to the function library "liboop"? 
# Can an adaptor be created to achieve a cooperation?

#-------------------------------------------------------------------------------
#Tests File (dispatch_sample.tcl)

###############################################################################
#
# Tcl dispatch command sample and [torture] test suite
#
# Copyright (c) 2001-2003 by Joe Mistachkin.  All rights reserved.
#
#  written by: Joe Mistachkin <joe@mistachkin.com>
#  created on: 10/07/2001
# modified on: 05/06/2003
#
###############################################################################
#

# require Tcl 8.0+
#package require Tcl 8.0

# attempt to load dispatch package
#source "dispatch.tcl"
#source "a-disp.tl"

# require dispatch package 2.0+ to be loaded...
#package require Tcl_dispatch 2.0

#-------------------------------------------------------------------------------
proc DispatchSample1 {string_to_match} {

  set test_1 "this"
  set test_2 "that"
  set test_3 "foo"
  set test_4 "not used"
  set test_5 "bar"
  set test_6 "FOO"
  set test_7 "BAR"
  
  dispatch $string_to_match {

    $test_1 {
      puts stdout "MATCHED #1\n"
    }
    $test_2 {
      puts stdout "MATCHED #2\n"
    }
    $test_3 {
      puts stdout "MATCHED #3\n"
    }
    "test 4" {
      puts stdout "MATCHED #4\n"
    }
    $test_5 -
    $test_6 -
    $test_7 {
      puts stdout "MATCHED #5,#6,#7\n"
    }
    default {
      puts stdout "MATCHED DEFAULT!\n"
    }
  }

  return
}
#-------------------------------------------------------------------------------
proc DispatchSample2 {string_to_match} {
  
  set test_1 "this"
  set test_2 "that"
  set test_3 "foo"
  set test_4 "not used"
  set test_5 "bar"
  set test_6 "FOO"
  set test_7 "BAR"
  set test_8 "NOEVAL"
  
  dispatch $string_to_match {

    $test_1 {
      puts stdout "MATCHED #1\n"
    }
    $test_2 {
      puts stdout "MATCHED #2\n"
    }
    $test_3 {
      puts stdout "MATCHED #3\n"
    }
    "test 4" {
      puts stdout "MATCHED #4\n"
    }
    $test_5 -
    $test_6 -
    $test_7 {
      puts stdout "MATCHED #5,#6,#7\n"
    }
    $test_8 -
  }

  return
}
#------------------------------------------------------------------------------- 
proc DispatchSample3 {string_to_match} {
 
  dispatch -glob -- $string_to_match {

    "1" {
      puts stdout "MATCHED #1\n"
    }
    "2" {
      puts stdout "MATCHED #2\n"
    }
    "3" {
      error "cannot match #3"
    }
    "*" {
      puts stdout "MATCHED *\n"
    }
  }

  return
}
#-------------------------------------------------------------------------------
proc DispatchSample4 {string_to_match} {
  
  # MALFORMED dispatch statement test
  
  dispatch $string_to_match {
    "1" {
      puts stdout "MATCHED #1\n"
    }
    "2" {
      puts stdout "MATCHED #2\n"
    }
    "3"
  }

  return
}
#------------------------------------------------------------------------------- 
proc DispatchSample5 { string_to_match } {

  set email_regexp {^([0-9A-Za-z])([0-9A-Za-z_\.\-]*)@([0-9A-Za-z])([0-9A-Za-z\.\-]*)$}
  
  dispatch -regexp -nocase -- $string_to_match {
    {^([01]?\d\d?|2[0-4]\d|25[0-5])\.([01]?\d\d?|2[0-4]\d|25[0-5])\.([01]?\d\d?|2[0-4]\d|25[0-5])\.([01]?\d\d?|2[0-4]\d|25[0-5])$} {
      puts stdout "MATCHED, VALID IP\n"
    }
    {^([01]?[0123456789][0123456789]?|2[0-4][0123456789]|25[0-5])\.([01]?[0123456789][0123456789]?|2[0-4][0123456789]|25[0-5])\.([01]?[0123456789][0123456789]?|2[0-4][0123456789]|25[0-5])\.([01]?[0123456789][0123456789]?|2[0-4][0123456789]|25[0-5])$} {
      puts stdout "MATCHED, VALID IP, PRE 8.0\n"
    }
    $email_regexp {
      # NOTICE we used a variable for this?
      puts stdout "MATCHED, VALID EMAIL ADDRESS\n"
    }
    {(<A )(.*?)(HREF=\")(.*?)(\")} {
      puts stdout "MATCHED, VALID HYPERLINK\n"
    }
    default {
      puts stdout "NOT MATCHED REGEXP\n"
    }
  }

  return
}
#-------------------------------------------------------------------------------
proc DispatchSample6 {string_to_match} {
  
  set sample6_var "this_is_a_test"
  
  dispatch -exact -nocase -- $string_to_match {
    "test" {
      puts stdout "MATCHED TEST\n"
    }
    {[string repeat $sample6_var "2"]} {
      puts stdout "MATCHED TEST * 2\n"
    }
    {\[fakecommand\]} {
      puts stdout "MATCHED FAKE COMMAND\n"
    }
    {[string repeat $sample6_var "3"]} -
    {[string repeat $sample6_var "4"]} {
      puts stdout "MATCHED TEST * 3 OR 4\n"
      
      if {$string_to_match == "this_is_a_testthis_is_a_testthis_is_a_testthis_is_a_test"} then {
        puts stdout "MATCHED TEST * 4\n"
      } else {
        puts stdout "MATCHED TEST * 3\n"
      }
    }
    default {
      puts stdout "NOT MATCHED SAMPLE\n"
    }
  }

  return
}
#-------------------------------------------------------------------------------
proc DispatchSample7 {string_to_match} {

  #
  # default string test
  #
  dispatch $string_to_match {
    "1" {
      puts stdout "MATCHED #1\n"
    }
    "2" {
      puts stdout "MATCHED #2\n"
    }
    "3" {
      puts stdout "MATCHED #3\n"
    }
    "4" {
      puts stdout "MATCHED #4\n"
    }
    "5" {
      puts stdout "MATCHED #5\n"
    }
    "6" {
      puts stdout "MATCHED #6\n"
    }
    "default" {
      puts stdout "MATCHED DEFAULT!\n"
    }
  }

  return
}
#------------------------------------------------------------------------------- 
proc DispatchSample8 {string_to_match} {

  #
  # multiple glob test...
  #
  dispatch -glob -all -- $string_to_match {
    "1" {
      puts stdout "MATCHED #1\n"
    }
    "1*" {
      puts stdout "MATCHED GLOB 1*\n"
    }
    "2" {
      puts stdout "MATCHED #2\n"
    }
    "2*" {
      puts stdout "MATCHED GLOB 2*\n"
    }
    "default" {
      puts stdout "MATCHED DEFAULT!\n"
    }
  }

  return
}
#-------------------------------------------------------------------------------
proc DispatchSample9 {string_to_match} {
  
  #
  # invalid switch test
  #
  dispatch -glob -all -notvalid -- $string_to_match {
    "1" {
      puts stdout "MATCHED #1\n"
    }
    "2" {
      puts stdout "MATCHED #2\n"
    }
    "default" {
      puts stdout "MATCHED DEFAULT!\n"
    }
  }

  return
}
#-------------------------------------------------------------------------------
proc DispatchSample10 {string_to_match} {

  #
  # valid switch-like looking argument after end of switches
  #
  dispatch -glob -- -notvalid {
    "-notvalid" {
      puts stdout "MATCHED -notvalid\n"
    }
    "default" {
      puts stdout "MATCHED DEFAULT!\n"
    }
  }

  return
}
#-------------------------------------------------------------------------------
proc testold {} { 

 ###############################################################################
 # series 1, test ``normal`` usage
 ###############################################################################

 puts stdout "TEST #1, should match #1..."
 DispatchSample1 "this"

 puts stdout "TEST #2, should match #2..."
 DispatchSample1 "that"

 puts stdout "TEST #3, should match #3..."
 DispatchSample1 "foo"

 puts stdout "TEST #4, should match #4..."
 DispatchSample1 "test 4"

 puts stdout "TEST #4a, should DEFAULT..."
 DispatchSample1 "not_in_list"

 puts stdout "TEST #5, should match #5,#6,#7..."
 DispatchSample1 "bar"

 puts stdout "TEST #6, should match #5,#6,#7..."
 DispatchSample1 "FOO"

 puts stdout "TEST #7, should match #5,#6,#7..."
 DispatchSample1 "BAR"
 
 ###############################################################################
 # series 2, do bad things
 ###############################################################################

 puts stdout "TEST #8, should not match anything..."
 DispatchSample2 "not_in_list"
 puts stdout ""
 
 puts stdout "TEST #9, should match, but not evaluate anything..."
 DispatchSample2 "NOEVAL"
 puts stdout ""
 
 puts stdout "TEST #10, should give error..."
 catch {DispatchSample3 "3"} dispatch_error
 puts stdout "ERROR: `` $dispatch_error ``"
 puts stdout ""
 
 puts stdout "TEST #11, should give error (malformed dispatch)..."
 catch {DispatchSample4 "1"} dispatch_error
 puts stdout "ERROR: `` $dispatch_error ``"
 puts stdout ""
 
 puts stdout "TEST #12, should match glob..."
 DispatchSample3 "4"
 
 puts stdout "TEST #13, should match regexp IP..."
 DispatchSample5 "198.102.29.10"
 
 puts stdout "TEST #14, should NOT match regexp..."
 DispatchSample5 "198.102.29.290"
 
 puts stdout "TEST #15, should NOT match regexp..."
 DispatchSample5 "*"
 
 puts stdout "TEST #16, should match regexp email..."
 DispatchSample5 "me@me.org"
 
 puts stdout "TEST #17, should match regexp hyperlink..."
 DispatchSample5 "<A HREF=\"http://www.scriptics.com/\">"
 
 puts stdout "TEST #18, should match command test..."
 DispatchSample6 "test"
 
 puts stdout "TEST #19, should match command test * 2..."
 DispatchSample6 "this_is_a_testthis_is_a_test"
 
 puts stdout "TEST #20, should match fake command..."
 set test20_var {\[fakecommand\]}
 DispatchSample6 $test20_var
 
 puts stdout "TEST #21, should match command test * 3 OR 4..."
 DispatchSample6 "this_is_a_testthis_is_a_testthis_is_a_test"
 
 puts stdout "TEST #22, should match command test * 3 OR 4..."
 DispatchSample6 "this_is_a_testthis_is_a_testthis_is_a_testthis_is_a_test"
 
 puts stdout "TEST #23, default string test..."
 DispatchSample7 "8"
 
 puts stdout "TEST #24, multiple test 1, should match 1, glob 1*, and default..."
 DispatchSample8 "1"
 
 puts stdout "TEST #25, multiple test 2, should match 2, glob 2*, and default..."
 DispatchSample8 "2"
 
 puts stdout "TEST #26, multiple test 3, should match default..."
 DispatchSample8 "3"
 
 puts stdout "TEST #27, invalid switch test, should give error..."
 catch {DispatchSample9 "3"} dispatch_error
 puts stdout "ERROR: `` $dispatch_error ``"
 
 puts stdout "TEST #28, switch-like argument after end of switches test, should match -notvalid..."
 DispatchSample10 ""

}
#-------------------------------------------------------------------------------
proc switch_this {string_to_match} {

  puts -nonewline "$string_to_match : "

  foreach n {1 2 3 4 5 6 7 8 9} {
    set test_$n $n
  }

  # подстановку можно делать, но в "плоской" команде, без скобок:

   switch $string_to_match \
    \
    $test_1 {
      puts "MATCHED #1 \n"
    } \
    $test_2 {
      puts "MATCHED #2 \n"
    } \
    $test_3 {
      puts "MATCHED #3 \n"
    } \
    "4" {
      puts "MATCHED #4 \n"
    } \
    $test_5 - \
    $test_6 - \
    $test_7 {
      puts "MATCHED #5,#6,#7 \n"
    } \
      \
    default {
      puts "MATCHED DEFAULT! \n"
    }
  
  return
}
#-------------------------------------------------------------------------------
proc dispatch_this {string_to_match} {

  puts -nonewline "$string_to_match : "

  foreach n {1 2 3 4 5 6 7 8 9} {
    set test_$n $n
  }

  dispatch $string_to_match {

    $test_1 {
      puts "MATCHED #1 \n"
    }
    $test_2 {
      puts "MATCHED #2 \n"
    }
    $test_3 {
      puts "MATCHED #3 \n"
    }
    "4" {
      puts "MATCHED #4 \n"
    }

    $test_5 -
    $test_6 -
    $test_7 {
      puts "MATCHED #5,#6,#7 \n"
    }

    $test_8 + 
    $test_9   {
      puts "MATCHED #8,#9 \n"
    }

    default {
      puts "MATCHED DEFAULT! \n"
    }
  }

  return
}
#-------------------------------------------------------------------------------
proc test_DISPATCH {} {
  
  puts ""

  foreach n {1 2 3 4 5 6 7 8 9} {
    switch_this $n
  }
    
  puts "--------------------------------------------------------------"
  puts ""

  foreach n {1 2 3 4 5 6 7 8 9} {
    dispatch_this $n
  }
    
  puts "--------------------------------------------------------------"
  puts ""


  return
}
#-------------------------------------------------------------------------------
# http://wiki.tcl.tk/1045
# ...
# rwm: I recently needed to run some 8.5 code in 8.4. I wrote the following code 
# to mimic the 8.5 switch in 8.4. (I looked for but could not find a 
# compatibility library...) Note the many errors for cases that I did not need. 
# Maybe someone else will cover fix/post those ;) Feel free to edit/move this as 
# appropriate.

#-------------------------------------------------------------------------------
proc regexp_do_find {rexp string matchvar} {

  upvar $matchvar matchvar  ;# ??


  set ret [regexp -- $rexp $string match 1 2 3 4 5 6 7 8 9]

  if {$ret} {

    # нашли соответсвие шаблону и подшаблонам и если есть
    # епременная matchvar запишем в нее этот список
    
    if {[info exists matchvar]} {
      upvar $matchvar m
      
      set m [list $match $1 $2 $3 $4 $5 $6 $7 $8 $9]
    }
  }
  
  return $ret
}
#-------------------------------------------------------------------------------
# #-------------------------------------------------------------------------------
#  Performance of -regexp  edit

# DrASK:

# Is there any speed improvement when using -exact over -regexp? As in:

# switch -exact -- $value {
#     a - b - c match
# }

# switch -regexp -- $value {
#     [abc] match
# }

# Lars H: Comments by DKF above suggest that the answer should be yes, but why 
# not check for yourself? time it!

# Also note that the two switches aren't exactly equivalent: the latter checks 
# whether the $value contains a, b, or c, not whether it is. To do that, you 
# need to change the regexp pattern as follows:

# switch -regexp -- $value {
#    ^[abc]$ {match}
# }

# DrASK: Yeah, I failed to mention that $value is known to be a single character. 
# Thanks. Here is the test and the results:

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
proc testproc_switch_exact {value {is_print 0}} {

  switch -exact -- $value {
    a - b - c {return true}
    default {return false}
  }
}
#--------------------------------------------------
proc testproc_switch_regex {value {is_print 0}} {

  switch -regexp -- $value {

    [abc] {return true}
    default {return false}
  }

}
#--------------------------------------------------
# proc first value {

#   return [expr {[string first $value abc] != -1}]

# }
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#--------------------------------------------------
proc switch_regex_test value {

  switch -regexp -- $value {

    [abc]   {puts "\[abc\]"}
    [e-f]   {puts "\[e-f\]"}
    gh*     {puts "gh*"}

    default {puts "default"}
  }

  return
}
#--------------------------------------------------
proc regex_test value {


  regexp {([^:]*):} $value   0 1

  puts -nonewline "value = $value |||  "

  foreach v {0 1} {

    if {[info exists $v]} {
      puts -nonewline "$v = [set $v]  "
    }
  }

  puts ""

  return
}
#-------------------------------------------------------------------------------
proc test_02 {} {

  puts ""

  switch_regex_test "a"
  switch_regex_test "b"
  switch_regex_test "c"
  switch_regex_test "d"
  switch_regex_test "e"
  switch_regex_test "f"
  switch_regex_test "ghhhhh"

  puts ""
  puts "-------------------------------------------------"
  puts ""
  
  regex_test "a"
  regex_test "b"
  regex_test "sage:0.1"

  puts ""
  
  return
}
#-------------------------------------------------------------------------------
proc testproc_metaswitch_regex {value {is_print 1}} {

  if {$is_print} {puts  -nonewline "testproc_metaswitch_regex  value = $value : " }  


  metaswitch -regexp -- $value {

    [abc] {
      if {$is_print} {puts "MATCHED #a,#b,#c"}
    }
    default {
      if {$is_print} {puts "MATCHED  default"}
    }
  }

  return
}
#------------------------------------------------=-
proc testproc_metaswitch_exact {value {is_print 1}} {

  if {$is_print} {
    puts ""
    puts "------------------------------------------------"
    puts "metaswitch_exact  value = $value : "   
    puts "------------------------------------------------"
    puts ""
  }

  # exact - по умолчанию
  # 
  metaswitch -- $value {

    a {
      if {$is_print} {puts "MATCHED #a"}
    }
    b - 
    c -
    d   {
      if {$is_print} {puts "MATCHED #b,#c,#d"}
    }

    e + {
      if {$is_print} {puts "MATCHED #e ................. \n\n "}
    }
    f   {
      if {$is_print} {puts "MATCHED #e,#f"}
    }

    default {
      if {$is_print} {puts "MATCHED  default"}
    }
  }

  return
}
#-------------------------------------------------------------------------------
proc testnew {} {


  #test_DISPATCH 


  puts ""
 
  testproc_metaswitch_regex  a 
  testproc_metaswitch_regex  b 
  testproc_metaswitch_regex  c 
  testproc_metaswitch_regex  d 

  puts ""

  testproc_metaswitch_exact  a 
  testproc_metaswitch_exact  b 
  testproc_metaswitch_exact  c 
  testproc_metaswitch_exact  d 
  testproc_metaswitch_exact  e 
  testproc_metaswitch_exact  f 

  #testproc_metaswitch_exact  g 

  testproc_metaswitch_exact  z 

  puts ""


  return
}  
#-------------------------------------------------------------------------------
proc metabreak {} {

  # можно было бы выбрасывать тут исключение и в скрипте ":" его отлавливать, но
  # это не слишком гибко с учетом того, что хочется еще операторов 
  # metagoto, metacall, ..

  # будет работать только в ":", но не в "+" ?
  # 

  error "metabreak"

}
#-------------------------------------------------------------------------------
proc metagoto {bukva} {


  error "metagoto $bukva"

}
#-------------------------------------------------------------------------------
# proc metarunscript {script} {

#   eval {*}$script

# }
#-------------------------------------------------------------------------------
# 
#-------------------------------------------------------------------------------
proc metaswitch_main {type string body} {



}
#-------------------------------------------------------------------------------
proc metaswitch {args} {

  ## this is an 8.4 version of the 8.5 switch (incomplete)

  if {[llength $args] < 2} {
    error "usage: switch ?options? string {pattern body ?pattern body ...?}"
  }

  set type glob ;# exact ;# по умолчанию

  # читаем циклом все входные ключи/опции (пока не встретим --)
  # 
  while {[string match -* [lindex $args 0]]} {

    set option [lindex $args 0]     ;# отделили опцию (одну?)
    set args   [lrange $args 1 end]

    switch -- $option {

      -exact    {set type exact}
      -nocase   {set type nocase}
      -glob     {set type glob}
      -regexp   {set type regexp}
      -matchvar {set matchvar [lindex $args 0]; set args [lrange $args 1 end]}
      -indexvar {error "unimplemented"}
      -- break

      default {error "bad switch option=$option"}
    }
  }

  set string [lindex $args 0] ;# а это сама строка/сообщение

  if {[llength $args] == 2} {
    set body [lindex $args 1]
  } else { 
    set body [lrange $args 1 end]
  }

  switch -- $type {

    nocase {error unimplemented}

    glob   -
    regexp -
    exact  {

      #metaswitch_main $type $string $body -----------------------------------

      set todo_next_script 0 ;# флаг безусловного выполнения следующего скрипта
      set is_print 0
      set metagoto_flag 0

      # основное цикл поиска соответсвия строки string -----------------------
      #
      for {set i 0} {$i < [llength $body]} {incr i +2} {

        # if $metagoto_flag {} - !! такая конструкция без скобок 
        #                           очень сильно тормозит!!
        #
        if {$metagoto_flag} {
          set i 0
          set metagoto_flag 0
        }

        set val  [lindex $body $i]
        set flag [lindex $body [+ $i 1]]

        if {$is_print} {
          puts "i      = $i"
          puts "val    = $val"
          puts "flag   = $flag"
          puts ""
        }

        if {$val eq {default}} {
          set script $flag
          uplevel 1 $script
          break
        }

        # если встретился оператор default, то выполнили его и вышли.
        # а иначе, если нет безусловного выполнения, то выполняем 
        # сравнение с образцом:
        #
        # -----------------------------------------------------------
        #
        if {$todo_next_script == 0} {

          # если нет безусловного выполнения, то займемся сравнением
          #

          if {$type == "exact"} {  # простое сравнение
            set is_finding [expr {$val == $string}]
          }
          if {$type == "regexp"} { # сложное сравнение
            
            set is_finding [regexp -- $val $string  0  1 2 3 4 5 6 7 8 9]
            if {$is_finding} {
              # нашли соответсвие шаблону и подшаблонам и если есть
              # епременная matchvar запишем в нее этот список
              
              if {[info exists matchvar]} {
                upvar $matchvar m
                set m [list $0  $1 $2 $3 $4 $5 $6 $7 $8 $9]
              }
            }
          }
          if {$type == "glob"} {  # простое сравнение
            set is_finding [string match $val $string]
          }
        
          if {! $is_finding} {
            
            # если сравнение не сработало, то
            # если у нас не пара, а тройка (шаблон, флаг, скрипт) для +, :
            # продвиuагемся  вперед в цикле чтения пар и идем на это самое чтение
            
            if {$flag == "+"} {incr i} 
            if {$flag == ":"} {incr i} 
            continue 
          }
          
        } ;# --------------------------------------------------------

        # и, наконец, в зависимости от флага разбираемся со скриптом
        # 
        #set ::switch_flag $$flag

        switch -- $flag {

          "-"     {
            set todo_next_script 1
          }

          "*" {
            set script [lindex $body [+ $i 2]]
            incr i
            uplevel 1 $script ;# просто выполняем скрипт?? и ищем дальше?
          }

          "+"     -
          ":"     {
            set todo_next_script 1

            set script [lindex $body [+ $i 2]]
            incr i

            # выполняем скрипт, перехватывая прерывания meta*
            # здесь основной тормоз !
            # 
            if [catch {uplevel 1 $script} errmsg] {
              
              #------------------------------------------------------
              #if {0} {
              #------------------------------------------------------

              set msg0 [lindex $errmsg 0]
              set msg1 [lindex $errmsg 1]

              switch -- $msg0 {

                "metabreak" {
                  set todo_next_script 0
                  break ;# from operator for
                }
                "metagoto" {

                  set todo_next_script 0
                  set metagoto_flag    1
                  set string           $msg1 ;# а это сама строка/сообщение

                  #set is_print 1 ;# дальше будем печатать отладку
                }
                default {
                  puts "errmsg = $errmsg !!!!!!!!!!!!!1"
                  puts ""
                }
              }
              #------------------------------------------------------
              #}
              #------------------------------------------------------


            } ;# end of catch

            # может выполнить скрипт покомандно, интерпретируя
            # команды  metabreak, metagoto, metacall ??
            # да не, это сложновато, лучше исключения выбрасывать!
            #
            #uplevel 2 [list metarunscript $script]
          }

           default {  # нет флажка, а есть программа
            set script $flag

            uplevel 1 $script
            set todo_next_script 0
            break
          }

        } ;# end of switch -- $flag
      } ;# end of for
      
      #---------------------------------------------------------------------


    } ;# end of exact

    default {error "ERROR:  type = $type !!! \n\n"}
  }

  return
}
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
proc testproc_metaswitch_more {value {is_print 1}} {

  if {$is_print} {
    puts ""
    puts "------------------------------------------------"
    puts "metaswitch_more  value = $value : "   
    puts "------------------------------------------------"
    puts ""
  }


  metaswitch -- $value {

    a {
      if {$is_print} {puts "MATCHED #a"}
    }

    b : {
      if {$is_print} {puts "MATCHED #b"}
      metabreak
    }

    c : {
      if {$is_print} {puts "MATCHED #c"}
      metagoto a
    }


    default {
      if {$is_print} {puts "MATCHED  default"}
    }
  }

  return
}
#-------------------------------------------------------------------------------
proc test_more {} {


  testproc_metaswitch_more  a 
  testproc_metaswitch_more  b 
  testproc_metaswitch_more  c 
  testproc_metaswitch_more  d 

  testproc_metaswitch_more  z 

  puts ""


  return
}  
#-------------------------------------------------------------------------------
proc testproc_metaswitch_glob {value {is_print 1}} {

  if {$is_print} {
    puts ""
    puts "------------------------------------------------"
    puts "metaswitch_glob  value = $value : "   
    puts "------------------------------------------------"
    puts ""
  }


  metaswitch -glob -- $value {

    *MOUSE* {
      if {$is_print} {puts "MATCHED *MOUSE*"}
    }

    default {
      if {$is_print} {puts "MATCHED  default"}
    }
  }

  return
}
#-------------------------------------------------------------------------------
proc test_glob {} {


  testproc_metaswitch_glob  LMOUSEUP 
  testproc_metaswitch_glob  LMOUSEDOWN 
  testproc_metaswitch_glob  RMOUSEUP
  testproc_metaswitch_glob  RMOUSEDOWN

  testproc_metaswitch_glob  KEYDOWN

  puts ""


  return
}  
#-------------------------------------------------------------------------------
proc runtestproc {testproc value} {

  for {set i 0} {$i < 100} {incr i} {

    $testproc $value 0 
  }

}
#--------------------------------------------------
proc test_PERFORMANCE {} {

  foreach testproc {\
                      testproc_switch_exact     \
                      testproc_metaswitch_exact \
                      testproc_metaswitch_more  \
                      \
                      testproc_switch_regex     \
                      testproc_metaswitch_regex \
  } {

    foreach value {a b c d} {

      puts "$testproc $value  [errortime  {runtestproc $testproc $value} 100 10]"
    }
    puts ""
  }

  puts ""

  return
}
#--------------------------------------------------

# exact a 66 +/- 0 microseconds per iteration
# exact b 67 +/- 0 microseconds per iteration
# exact c 67 +/- 0 microseconds per iteration
# exact d 66 +/- 0 microseconds per iteration
# regexp a 151 +/- 0 microseconds per iteration
# regexp b 140 +/- 0 microseconds per iteration
# regexp c 142 +/- 0 microseconds per iteration
# regexp d 121 +/- 0 microseconds per iteration
# first a 71 +/- 0 microseconds per iteration
# first b 71 +/- 0 microseconds per iteration
# first c 71 +/- 0 microseconds per iteration
# first d 70 +/- 0 microseconds per iteration

# It's interesting to note the dropoff when regexp hit the default case. But 
# -regexp is clearly is 2-2.5x slower. I used MAK's errortime proc for timing.

# ferrieux: Indeed, timing shows that the jump table is roughly 3x faster than 
# if..elseif..elseif, which is itself 1.25x faster than regexp. Notice that the 
# regexp compilation overhead is not in the picture, since it is cached. Not 
# sure whether we should worry about the 1.25...
# An Implementation in Tcl  edit

#-------------------------------------------------------------------------------
proc test_perf {} {

  puts ""

  test_PERFORMANCE

  puts ""

}
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
# 
# TODO: 
# 
# + сделать тесьы на regexp и matchvar для обычного switch и для metaswitch
# + объеденить эти алгоритмы в один.
# + добавить флаг ":" и операторы  meta* (a~.tl DISP test_more)
# + еще раз посмотреть как работает dispath, что-то взять? тесты на время?
# 
# - сделать вложенные metaswitch c переходами между ними;
# - седлать возможность подстановок переменных (как в [sl ..] - scripted list или 
#                                               как в dispatch);
# - а также возможность подстановок черех команды?
# - такая гибкая система OO/мультиметоды/конечный автомат/шаблоны/подстановки - 
#   позволит описывать сложные иерархические системы в т.ч. и протоколы;

#-------------------------------------------------------------------------------

# a~.tl DISP testold
# a~.tl DISP testnew

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
