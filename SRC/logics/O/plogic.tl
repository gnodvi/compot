# -*-   mode: tcl  coding: koi8   -*- ------------------------------------------

#!/bin/sh
# \
exec tclsh "$0" ${1+"$@"}

#-------------------------------------------------------------------------------
# https://wiki.tcl-lang.org/page/Playing+predicate+logic

#      Tcler's Wiki

# Playing predicate logic

proc test {} {

# Richard Suchenwirth 2002-04-17 - As one more little step in playing Prolog, 
# here is some predicate logic in Tcl, where predicates are implemented as procs 
# created by string manipulation. The procedure with the fancy name "!" takes a 
# Horn clause (one or more assertions) as arguments, for instance

 ! {human Socrates}
 ! {mortal $x} {human $x}

# With one assertion, it is taken for granted (read, in the example, "it is true 
# that the predicate 'human' holds for Socrates", or, "Socrates is a human"). With 
# more than one, the first assertion is true if all other assertions are true, with 
# variables (prefixed with a dollar sign) acting as expected ("something is mortal 
# if it is human"). Such non-first assertions may also be negated by prepending an 
# exclamation mark:

#  ! {bad Satan}         ;# must have been asserted at least once
#  ! {good $x} {!bad $x} ;# so everyone except Satan is considered good...

# Each first assertion creates or extends a proc of same name (which returns truth 
# values 1 or 0), so you can try

#  mortal Socrates ;# => 1
#  mortal Diogenes ;# 0 - binary logic: all that's not true is false

# The generated procedures look like this:

#  proc human {0} {expr {$0 == "Socrates"}}
#  proc mortal {x} {expr {[human $x]}}

# (remember that digits are valid variable names in Tcl - for one-arg assertions, 
# the arguments are just numbered from 0 up with the index generator iota). After 
# another call like

#  ! {human Plato}

# proc human is rewritten to

#  proc human {0} {expr {$0 == "Socrates" || $0 == "Plato"}}

# Similarly, ! {mortal $x} {animal $x} extends mortal to

#  proc mortal {x} {expr {[human $x] || [animal $x]}}

# and so on. This is still far from Prolog: backtracking is missing, as well as 
# semi-free variables, e.g.

#  ! {famous $x} {founderOf $x $y} {bigCompany $y}

# where $y should be filled with a suitable value, but currently just raises errors. 
# Also, predicates of different arity cannot yet be mixed. However, mildly complex 
# structures like

#  ! {healthy $x} {early2bed $x} {early2rise $x} {man $x}
#  ! {wealthy $x} {early2bed $x} {early2rise $x} {man $x}
#  ! {wise $x} {early2bed $x} {early2rise $x} {man $x}
#  ! {man Bill}
#  ! {early2bed  Bill}
#  ! {early2rise Bill}

# can be used and go to prove that "early to bed and early to rise, makes a man 
# healthy, wealthy, and wise", even if that may not be true in reality...

}

#-------------------------------------------------------------------------------

proc ! {args} {
    set head [lindex $args 0]
    set pred [lindex $head 0]
    set argl [lrange $head 1 end]    
    if {[info proc $pred] != ""} {
        set ebody "[lindex [info body $pred] 1] || "
    } else { 
        set ebody ""
    }
    if {[llength $args]==1} {
        set argv [iota [llength $argl]]
        foreach name $argv value $argl {
            lappend body "\$$name == \"$value\""
        }
        append ebody [join $body { && }]
    } else {
        set argv [string map {$ ""} $argl]
        set body "\[[join [lrange $args 1 end] {] && [}]\]"
        append ebody [string map "\[! !\[" $body] 
        }
     proc $pred $argv "[list expr $ebody] " ;# bug 545644 workaround
 }
 proc iota n {
    set res {}
    for {set i 0} {$i<$n} {incr i} {lappend res $i}
    set res
 }

#-------------------------------------------------------------------------------

# Unification (tentative assignment of possible values to an unbound variable) 
# is a harder nut to crack. For the moment, all I have is the following proc all 
# that extracts all possible values from a "terminal" proc body, and one could 
# iterate over that with foreach:

#-------------------------------------------------------------------------------

 proc all {what} {
    set ebody [lindex [info body $what] 1]
    if  {[string first == $ebody]<0} {error "$what is not a terminal predicate"}
    set res {}
    foreach {- - word -} $ebody {lappend res $word}
    set res
 }

#Then the famous example above can be rewritten (pedestrianly for now) as

 proc famous x {
    foreach y [all bigCompany] {
        if {[founderOf $y $x]} {return 1}
    }
    return 0
 }

#-------------------------------------------------------------------------------

proc main {} {


 ! {bigCompany MS}
 ! {founderOf MS Bill}

 # famous Bill   => 1


 test

}
#-------------------------------------------------------------------------------

main

#-------------------------------------------------------------------------------

# but this format cannot be correctly extended from the ! proc...

# NEM See a little database with unification.
# Arts and Crafts of Tcl-Tk Programming
# Updated 2011-07-06 01:03:39

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
