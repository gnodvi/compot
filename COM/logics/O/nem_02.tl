# -*-   mode: tcl  coding: koi8   -*- ------------------------------------------

#!/bin/sh
# \
exec tclsh "$0" ${1+"$@"}

#-------------------------------------------------------------------------------
# https://wiki.tcl-lang.org/page/A+little+database+with+unification

#      Tcler's Wiki

# A little database with unification

# NEM 1010-07-26: For an updated version see a little backtracking Prolog 
# interpreter.

# NEM 2006-08-05: Following on from a little logic notation editor, here is a small, 
# simple database with a primitive unification implementation that could form the 
# basis of a little logic programming implementation (see playing Prolog). It's 
# not quite a relational database, as rows in this database are ordered tuples 
# rather than unordered sets of named attributes, but it will suffice for my 
# purposes. I quite like the interface to the database here, although the actual 
# implementation is fairly inefficient. The basic interface is:

#-------------------------------------------------------------------------------

# ldb create $name
#     Creates an empty database with the given name. The name is then a command 
#     that can be used to access the database.

# $db relation $name $fields...
#     Creates a new relation (table) in the database, and creates a constructor 
#     command to form tuples for this relation.

# $db assert $fact
#     Adds a new row to the database. $fact must be a tuple that is valid for the 
#     database (i.e., created via a relation constructor).

# $db retract $fact
#     Removes a row from the database, if it exists.

# $db query $query $rowVar $body
#     Executes a query in the database, and for each resulting row sets $rowVar 
#     to an 
#     array of the elements of the row and evaluates $body. Returns the number of 
#     rows that matched. A query is simply a tuple (created with a relation 
#     constructor) 
#     that may contain variables, indicated by a leading ? sign, or a don't care 
#     pattern, "_".

#-------------------------------------------------------------------------------

# The query engine performs unification on queries and candidate rows, in order 
# to see if any instantiation of free variables in either will cause the two 
# structures to be equivalent. However, as in Prolog, we currently leave out an 
# occurs-check which is needed for absolute correctness (this only matters if you 
# are trying to unify a variable with a structure that may contain a reference to 
# the same variable). One interesting thing to note is that we perform full 
# unification, and not just pattern matching -- this means that rows in the 
# database can also contain variables! While this may seem a bit weird, it is a 
# useful property when implementing Prolog or other logic languages (which is 
# what I want this code for).
# The Code

# This requires 8.5 out of habit, but I think the only 8.5-ism I use is namespace 
# ensemble, so you can just comment that out if you want to try with 8.4.

# JFL 2006-10-03: Actually there's also the dict command that's Tcl 8.5 specific. 
# Use forward-compatible dict to emulate it in 8.4

#-------------------------------------------------------------------------------
 # ldb.tcl --
 #
 #       A simple in-memory relational/logic database.
 #
 # Copyright (c) 2006 Neil Madden (nem@cs.nott.ac.uk).
 #
 
 package require Tcl         8.5
 package provide ldb         1.0
 
 namespace eval ldb {
    namespace export create relation assert retract query
    namespace ensemble create 
 
    # create name --
    #
    #       Creates a new empty database called "name". A database consists
    #       of an array variable and a command of the same name. The command
    #       can be used as a short-cut for calling instance methods on the
    #       database.
    #
    proc create name {
        interp alias {} $name {} ::ldb::dispatch $name
        upvar #0 $name var
        array unset var
        array set var { }
        return $name
    }
 
    # dispatch db method ... --
    #
    #       Dispatches a method call to the appropriate implementation.
    #
    proc dispatch {dbVar method args} {
        if {[lsearch -exact [namespace export] $method] < 0} {
            error [concat "bad method \"$method\": must be" \
                [joinlist [namespace export] , " or "]]
        }
        if {[catch {eval [linsert $args 0 $method $dbVar]} msg]} {
            return -code error $msg
        }
        return $msg
    }
 
    # joinlist list sep1 sep2 --
    #
    #       Little utility proc to format a list into a human-readable form.
    #       Each word in the list is joined by $sep1, except for the last
    #       word which is joined using $sep2.
    #
    proc joinlist {list sep1 sep2} {
        if {[llength $list] < 2} {
            return [join $list]
        } elseif {[llength $list] == 2} {
            return [join $list $sep2]
        } else {
            set str [join [lrange $list 0 end-1] $sep1]
            append str $sep1$sep2[lindex $list end]
            return $str
        }
    }
     
    # db relation name args ... --
    #
    #       Creates a new type of relation, named "name". A relation is
    #       essentially a table in the database. For simplicity each
    #       relation consists of a set of ordered tuples, rather than a set
    #       of unordered named attributes. This is a departure from the
    #       relational model but is sufficient for implementing a
    #       Prolog-style logic language. The command created is
    #       free-standing and *not* a new method on the database.
    #
    proc relation {dbVar name args} {
        upvar #0 $dbVar db
        set db($name) [list]
        interp alias {} $name {} ::ldb::construct $name $args
        return $name
    }
 
    # construct name fields args... --
    #
    #       Constructs a row of the specified relation type and returns it.
    #       Note that this does not assert the row into any database and so
    #       can be used for constructing patterns as well as facts.
    #
    proc construct {name fields args} {
        if {[llength $fields] != [llength $args]} {
            error "wrong # args: should be \"$name $fields\""
        }
        return [linsert $args 0 $name]
    }
 
    # db assert fact --
    #
    #       Asserts a fact into the database.
    #
    proc assert {dbVar fact} {
        upvar #0 $dbVar db
        if {[llength $fact] < 1} {
            error "fact has no type"
        }
        set rel [lindex $fact 0]
        if {![info exists db($rel)]} {
            error "no such relation: \"$rel\""
        }
        set idx [lsearch -exact $db($rel) $fact]
        if {$idx < 0} {
            lappend db($rel) $fact
        }
        return
    }
 
    # db retract fact --
    #
    #       Removes a fact from the database.
    #
    proc retract {dbVar fact} {
        upvar #0 $dbVar db
        if {[llength $fact] < 1} {
            error "fact has no type"
        }
        set rel [lindex $fact 0]
        if {![info exists db($rel)]} {
            error "no such relation: \"$rel\""
        }
        set idx [lsearch -exact $db($rel) $fact]
        if {$idx >= 0} {
            set db($rel) [lreplace $db($rel) $idx $idx]
        }
        return
    }
 
    # db query query rowVar body --
    #
    #       Evaluates a query against the database. For each entry that
    #       unifies with the query the rowVar is set to an array of the
    #       variable bindings resulting from the query, and the body script
    #       is evaluated in the caller's scope. Returns the number of
    #       rows that matched the query.
    #
    proc query {dbVar query rowVar body} {
        upvar #0 $dbVar db
        upvar 1 $rowVar row
        if {[llength $query] < 1} {
            error "query has no type"
        }
        set rel [lindex $query 0]
        if {![info exists db($rel)]} {
            error "no such relation: \"$rel\""
        }
        set count 0
        foreach entry $db($rel) {
            set ret "No"
            if {![catch { unify $query $entry } env]} {
                incr count
                array set row $env
                set rc [catch {uplevel 1 $body} result]
                if {$rc == 0 || $rc == [catch continue]} {
                    continue
                } elseif {$rc == [catch break]} {
                    break
                } else {
                    return -code $rc $result
                }
            }
        }
        return $count
    }
 
    # unify x y env --
    #
    #       Implements the unification algorithm. Based on psuedo-code from
    #       Russell/Norvig "Artificial Intelligence: A Modern Approach".
    #
    proc unify {x y {env ""}} {
        if {[string trim $x] eq [string trim $y]} {
            return $env
        } elseif {[list? $x] && [list? $y]} {
            return [unify [tail $x] [tail $y] \
                    [unify [head $x] [head $y] $env]]
        } elseif {[var? $x]} {
            return [unify-var $x $y $env]
        } elseif {[var? $y]} {
            return [unify-var $y $x $env]
        } else {
            error "unification failure"
        }
    }
    proc unify-var {var x env} {
        if {[dict exists $env $var]} {
            return [unify [dict get $env $var] $x $env]
        } elseif {[dict exists $env $x]} {
            return [unify $var [dict get $env $x] $env]
        } elseif {$var eq "_"} {
            # Don't care pattern
            return $env
        } else {
            # TODO: occurs-check goes here...
            return [dict set env $var $x]
        }
    }
    proc var? x {
        expr {$x eq "_" || [string index $x 0] eq "?"}
    }
    proc list? x { expr {[llength $x] > 1} }
    proc head xs { lindex $xs 0 }
    proc tail xs { 
        # Bit of a hack here
        if {[llength $xs] == 2} {
            return [lindex $xs 1]
        } else {
            lrange $xs 1 end
        }
    }
 }
#-------------------------------------------------------------------------------

# Demo

# First we create a little database and add some facts to it.


 ldb create db ; # In Tcl 8.4 use instead: ::ldb::create db
 db relation author name book
 db assert [author "Brent Welch"         "Practical Programming in Tcl/Tk"]
 db assert [author "Jeff Hobbs"          "Practical Programming in Tcl/Tk"]
 db assert [author "Christopher Nelson"  "Tcl/Tk Programmer's Reference"]
 db assert [author "Cliff Flynt"         "Tcl: A Developer's Guide"]


# Now we add a little read-eval-print loop for executing queries. This is very 
# much based on typical Prolog interactive prompts. Just type in a query as a 
# list of elements and press return to execute. If multiple results are available 
# then you can type ";" and press return to get the next result or just type 
# return to skip the remaining results.

while 1 {
    puts -nonewline stdout "?- "
    flush stdout
    gets stdin query
    if {[eof stdin]} {break}
    set count 0
    if {[catch {db query $query row {
        if {[incr count] > 1} {
            if {[gets stdin] ne ";"} { break }
        }
        foreach {var value} [array get row] {
            puts -nonewline "\n$var = $value "
        }
        flush stdout
    }} res]} {
        puts $res
    } elseif {$res} {
        puts \nYes
    } else {
        puts \nNo
    }
}

#An example interactive session:


?- author ?name ?book

?name = Brent Welch 
?book = Practical Programming in Tcl/Tk ;

?name = Jeff Hobbs 
?book = Practical Programming in Tcl/Tk ;

?name = Christopher Nelson 
?book = Tcl/Tk Programmer's Reference ;

?name = Cliff Flynt 
?book = Tcl: A Developer's Guide 
#Yes
?- author ?a "Practical Programming in ?lang"

?a = Brent Welch 
?lang = Tcl/Tk ; 

?a = Jeff Hobbs 
?lang = Tcl/Tk 
#Yes
?- author "Brent Welch" "Practical Programming in Tcl/Tk"

#Yes
?- author "Neil Madden" ?book

#No
?- author "Jeff Hobbs" ?title 

?title = Practical Programming in Tcl/Tk 
#Yes

#And to demonstrate full unification, add the following to the database:

db assert [author ?author "My Latest Novel"]

#and try a query:

?- author "Neil Madden" ?book

?book = My Latest Novel 
?author = Neil Madden 

#Yes

#-------------------------------------------------------------------------------

# Hooray!
# Category Database	Logic programming
# Updated 2015-02-17 05:37:24

#-------------------------------------------------------------------------------
