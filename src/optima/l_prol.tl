#!/bin/sh
# \
exec tclsh "$0" ${1+"$@"}

#-------------------------------------------------------------------------------
#
# http://wiki.tcl.tk/26731
#
#-------------------------------------------------------------------------------

# A little backtracking Prolog interpreter
# Updated 2010-10-18 14:25:10 by "nem"

#-------------------------------------------------------------------------------


# NEM 2010-07-25: Following on from a little database with unification, Playing 
# Prolog and Playing Predicate Logic, here is a more fully fleshed-out (but still 
# lacking many features) Prolog interpreter, loosely based on that given in Chapter 
# 11 of Paradigms of Artificial Intelligence Programming, but optimised and adapted 
# considerably for Tcl.

# The interpreter here supports basic backtracking (depth-first search) resolution 
# of Horn clauses in a simple interpreter. However, it currently doesn't support 
# negation-as-failure, disjunction, or any of the built-in predicates that make 
# Prolog a full-featured language. It also is a toy interpreter rather than a 
# compiler, so performance will not be anywhere near competitive with modern 
# Prolog implementations. However, it suffices to demonstrate the principles.

#-------------------------------------------------------------------------------
# prolog.tcl --
#
#       Prolog interpreter in Tcl. Loosely based on Chapter 11, "Paradigms of
#       Artificial Intelligence Programming", Peter Norvig.
#
# Copyright (c) 2010 by Neil Madden
# License: Same as Tcl (BSD-style).
#
#-------------------------------------------------------------------------------

package require Tcl     8.5
package provide prolog  0.1

namespace eval ::prolog {
    namespace export function relation assert query
    namespace ensemble create
}

#-------------------------------------------------------------------------------

# Syntax

# The syntax of Prolog is based on a restricted form of first-order predicate 
# logic using Horn clauses. A Horn clause is a disjunction ("OR") of literals 
# with at most one positive atom. A literal here is either an atomic formula (such 
# as parent(x,y)) or its negation. The arguments to an atomic formula are terms, 
# which are either function symbols or variables. Real Prolog implementations 
# usually also support numbers, strings and other concrete datatypes.

# Note: function symbols are distinct from functions. Function symbols are 
# uninterpreted structures consisting of an initial symbol (the functor) such as 
# father followed by a tuple of arguments, e.g., father(mary) is a function symbol, 
# which may denote the father of Mary. (Whether it does or not depends on the 
# interpretation you give these symbols). Function symbols generally denote individuals 
# or objects, whereas formulas denote statements which are either true or false.

# Translating this to Tcl, we will represent variables by strings of the form ?xyz 
# and function symbols will be represented by a list where the first element is the 
# functor and the remaining elements are the argument terms. Constants (0-arity 
# function symbols) are therefore just lists with a single element. This 
# representation allows us to represent arbitrary string constants and keep them 
# distinct from other function symbols. The only clash we have is that strings that 
# begin with a question-mark will always be interpreted as variables. This is a minor 
# drawback, which seems unlikely to be a problem in practice.

#-------------------------------------------------------------------------------
# Terms:
#
#       A term is either a variable or a function symbol.
#
#-------------------------------------------------------------------------------

proc prolog::var? s { string match {\?*} $s }
proc prolog::fun? s { expr {![var? $s]} }

# In addition to normal variables, we will also allow a lone question-mark as a 
# "wild-card" match-anything variable, which can be useful when you do not care 
# what the value of that variable is.

proc prolog::wildcard? s { string equal $s "?" }

# In order to make working with function symbols easier, we can provide some 
# getter functions to access some basic properties. This also allows us to easily 
# change the representation at a later date if we wish. The properties we are 
# interested in are the functor, the arguments and the arity (number of arguments) 
# of the symbol.

# functor symbol
#
#       Returns the functor of a function symbol.
#
proc prolog::functor symbol { lindex $symbol 0 }

# arguments symbol
#
#       Returns the argument terms of an atomic formula or function symbol.
#
proc prolog::arguments symbol { lrange $symbol 1 end }

# arity symbol
#
#       Returns the arity (number of arguments) of a symbol.
#
proc prolog::arity symbol { expr {[llength $symbol] - 1} }

# Additionally, to make function symbols easier to construct, we can introduce 
# a means to declare constructor commands for function symbols.

# function name ?args ...?
#
#       Creates a constructor command for function symbols.
#
proc prolog::function {name args} {
    set name [qualify 1 $name]
    interp alias {} $name {} ::prolog::symbol $name $args
    return $name
}

#-------------------------------------------------------------------------------
# symbol name params ?args ...?
#
#       Constructs a symbol with the given name and arguments.
#
proc prolog::symbol {name params args} {
    if {[llength $params] != [llength $args]} {
        return -code error "wrong # args: should be \"$name $params\""
    }
    return [linsert $args 0 $name]
}

#-------------------------------------------------------------------------------
# qualify level name
#
#       Returns a fully-qualified version of $name, relative to the
#       current namespace at level $level (where $level is a level
#       acceptable to [uplevel]). This command differs from [namespace
#       which] in that it is intended for constructing fully-qualified names
#       for commands which have yet to be created.
#
proc prolog::qualify {level name} {
    if {[string match ::* $name]} { return $name }
    if {[string is integer -strict $level] && $level >= 0} { incr level }
    set ns [uplevel $level { namespace current }]
    if {$ns eq "::"} { return ::$name }
    return $ns\::$name
}

#-------------------------------------------------------------------------------

# This allows us to write code such as the following, which makes constructing 
# complex terms simpler in many cases.

prolog function father x
set y [father mary]      ;# => {::father mary}
set z [father $y]        ;# => {::father {::father mary}}

# Given terms, we can now build up formulas. An atomic formula (or atom) is similar 
# to a function symbol in that it consists of a predicate symbol and a list of 
# arguments. For example, parent(john,mary) might state that John is a parent of 
# Mary. We can reuse the representation of function symbols for atoms:

interp alias {} prolog::atom      {} prolog::symbol
interp alias {} prolog::predicate {} prolog::functor

# Real Prolog would then extend this syntax to literals, allowing negation, but 
# for now we stick with simple positive atoms. The final piece of syntax is a 
# clause, which is a disjunction of literals (i.e., a OR b OR c...). Prolog 
# restricts these to Horn clauses, with at most one positive atom (i.e., NOT a 
# or NOT b OR c). Such clauses can always be written in the form: a AND b => c 
# ("a and b implies c"), which Prolog writes as c :- a, b. The following procedure 
# will construct a clause, ensuring correct syntax.

#-------------------------------------------------------------------------------
# clause head ?:- body...?
#
#       Constructs a (Horn) clause
#
#-------------------------------------------------------------------------------
proc prolog::clause {head args} {
    if {[llength $args] == 1} {
        return -code error \
            "wrong # args: should be \"clause head ?:- body...?\""
    }
    if {[llength $args] > 0 && [lindex $args 0] ne ":-"} {
        return -code error \
            "invalid syntax: expecting ':-' but got '[lindex $args 0]'"
    }

    return [list $head {*}[lrange $args 1 end]]
}
proc prolog::head clause { lindex $clause 0 }
proc prolog::body clause { lrange $clause 1 end }

#-------------------------------------------------------------------------------

# Unification

# The core of any logic programming implementation is the unification algorithm. 
# This algorithm has been discussed elsewhere on this wiki before, so we just 
# present the core algorithm here with little commentary. The code is fairly 
# well commented, so shouldn't be too hard to decipher.

#-------------------------------------------------------------------------------
# Variable binding environments are implemented as dictionaries

proc prolog::lookup {env var}     { dict get $env $var }
proc prolog::extend {env var val} { dict set env $var $val }
proc prolog::bound? {env var}     { dict exists $env $var }

# fail
#
#       Signals a unification failure. Failure is indicated with the
#       exception return code 3245 ("fail" on a telephone keypad).
#
proc prolog::fail {} { return -code 3245 "unification failure" }

#-------------------------------------------------------------------------------
# unify x y ?env?
#
#       Unifies two symbols by finding substitutions for free variables in
#       each formula/term which would make the terms equal. If successful,
#       returns the successful substitution, otherwise throws a unification
#       failure exception.
#
proc prolog::unify {x y {env ""}} {
    if {$x eq $y} { return $env } ;# cheap check
    if {[var? $x]} { return [unify-var $x $y $env] }
    if {[var? $y]} { return [unify-var $y $x $env] }

    # Check arity and functors are identical first
    if {[arity $x] != [arity $y] ||
        [functor $x] != [functor $y]} { fail }

    # Attempt to unify each pair of arguments in turn
    foreach xarg [arguments $x] yarg [arguments $y] {
        set env [unify $xarg $yarg $env]
    }

    # Success!
    return $env
}

# unify-var x y env
#
#       Unify a variable with another value.
#
proc prolog::unify-var {x y env} {

    # If either term is an already-bound variable, then retry unification
    # after performing this substitution.
    if {[bound? $env $x]} { return [unify [lookup $env $x] $y $env] }
    if {[bound? $env $y]} { return [unify $x [lookup $env $y] $env] }

    # Otherwise, create a new binding for this variable.
    # First, perform the occurs-check to ensure that we are not creating an
    # infinite structure.
    if {[occurs-in $x $y]} { fail }

    return [extend $env $x $y]
}

#-------------------------------------------------------------------------------
# occurs-in var exp
#
#       Returns 1 if the given var occurs anywhere within the term exp,
#       otherwise returns 0. This is the expensive "occurs check", which is
#       usually omitted in Prolog for efficiency. If we leave out this
#       check, then there is a possibility of creating infinite structures,
#       e.g., from unifying ?x and [f ?x], which will create the structure
#       [f [f [f ...]]]. This would then result in an infinite loop when
#       resolving the structure.
#
proc prolog::occurs-in {var exp} {
    if {$var eq $exp} { return 1 }
    foreach arg [arguments $exp] {
        if {[occurs-in $var $arg]} { return 1 }
    }
    return 0
}
#-------------------------------------------------------------------------------

# Storage 

# A predicate can be seen as denoting a relation (as in relational databases), 
# which contains all tuples of individuals that satisfy the predicate. For example, 
# the predicate parent is true if the first argument individual is a parent of the 
# second argument individual. The corresponding relation consists of all pairs of 
# individuals that satisfy this relationship, e.g., our parent predicate might be 
# represented by the relation parent = { (John, Mary), (Susan, Jill), ... } (where 
# John is a parent of Mary, Susan a parent of Jill, and so on).

# In contrast to the earlier a little database with unification, we here adopt an 
# approach of storing data in individual relations rather than in a database. 
# This reduces the boilerplate a little as you now no longer need to create a 
# database before creating relations, but as the relations are namespaced there 
# is no loss of modularity. Each relation consists of a command (similar to the 
# commands for constructing function symbols), and a variable of the same name 
# that contains the data. The data itself is stored as a list of clauses, with 
# new clauses added to the end of the relation.

#-------------------------------------------------------------------------------
# relation name ?args ...?
#
#       Creates a relation and a command for constructing elements of that
#       relation.
#
proc prolog::relation {name args} {
    set name [qualify 1 $name]
    interp alias {} $name {} ::prolog::atom $name $args
    set $name [list]
    trace add command $name delete ::prolog::DeleteRelation
    return
}

proc prolog::DeleteRelation {name args} {
    upvar #0 $name relation
    unset relation
}

# assert head ?:- body ...?
#
#       Asserts a clause is true (adds it to the relation of the head).
#
proc prolog::assert args {
    set clause [clause {*}$args]

    set pred [predicate [head $clause]]
    upvar #0 $pred relation
    lappend relation $clause

    return
}

# clauses predicate
#
#       Returns a list of all clauses in the relation denoted by the predicate.
#
proc prolog::clauses predicate {
    upvar #0 $predicate relation
    return $relation
}
#-------------------------------------------------------------------------------

# Interpreter

# The interpretation of Prolog consists of answering queries by finding facts 
# which are implied by the clauses we have asserted which satisfy the query. We 
# can see this as being a bit like querying a database in SQL, but in Prolog we 
# can do much more sophisticated logical inference to answer the questions. The 
# basic approach is based on a variation of the resolution rule of inference 
# developed for classical predicate logic. Essentially, we employ a depth-first 
# search technique, which tries to find a clause whose head unifies with the goal 
# in the query. We then adopt any sub-goals in the body of that clause as new 
# goals and repeat the process. If we manage to solve all of these goals in a 
# consistent manner, then we have found a solution to our original query. If we 
# fail, then we back-track to a previous solution and try a different clause. 
# This approach broadly corresponds to proof by contradiction, and is reasonably 
# efficient in time and memory usage. The current implementation, of course, 
# misses many possible optimisations, and so is by no means production-ready. 
# However, it has the advantage of simplicity.

# The first step then in our search is to find all clauses that unify with our 
# goal. The following procedure expands a goal into a list of sub-goals which 
# are candidates for a solution. We rename all variables in each candidate clause 
# before attempting unification, to ensure that variables in distinct clause 
# instances are distinct, even if they have the same name. Otherwise, some 
# solutions will be missed due to variable name clashes.

#-------------------------------------------------------------------------------
# expand goal solution rest
#
#       Returns a list of new possible solutions to $goal. Each element of the
#       list returned consists of a partial solution and a list of further goals
#       yet to be solved for this solution.
#
proc prolog::expand {goal partial rest} {
    set subgoals [list]

    foreach clause [clauses [predicate $goal]] {
        set clause [rename-vars $clause]
        try {
            unify $goal [head $clause] $partial
        } on [success] solution {
            lappend subgoals [list $solution [list {*}[body $clause] {*}$rest]]
        } on [failure] {} {
            continue
        }
    }

    return $subgoals
}

# sugar to make [try] look nicer :-)
proc prolog::success {} { return 0    }
proc prolog::failure {} { return 3245 }

# rename-vars clause
#
#       Renames all variables in the given clause to be globally-unique.
#       All variables with the same name in the expression (e.g., ?a) will
#       be renamed to the same unique variable name (e.g., ?a123). All
#       wildcard variables (?) are renamed to completely distinct variables.
#       This process ensures that variables in distinct clauses are kept
#       distinct.
#
proc prolog::rename-vars clause {
    set scope [dict create]
    set result [list]
    foreach literal $clause {
        lappend result [rename-vars-in $literal scope]
    }
    return $result
}
proc prolog::rename-vars-in {exp envVar} {
    upvar 1 $envVar env
    if {[wildcard? $exp]} { return [gensym "?"] }
    if {[var? $exp]} {
        if {![dict exists $env $exp]} {
            dict set env $exp [gensym $exp]
        }
        return [dict get $env $exp]
    }
    if {[llength $exp] > 1} {
        set res [list [predicate $exp]]
        foreach arg [arguments $exp] {
            lappend res [rename-vars-in $arg env]
        }
        return $res
    }

    return $exp
}
# gensym prefix
#
#       Generates a unique string starting with the given prefix.
#
proc prolog::gensym prefix {
    return [format "%s%d" $prefix [incr ::prolog::gensym($prefix)]]
}

#-------------------------------------------------------------------------------
# The remainder of the algorithm is then a simple state-space search, similar to 
# state space searching in Tcl. The basic approach is to start with a set of 
# goals (a query) to be solved. Given a query, which consists of a set of goals 
# (atoms with free variables), we try to find a solution that satisfies all of 
# the goals together. We do this by maintaining a queue of search nodes, which 
# initially consists of just our original goals. We then pop a node at a time from 
# the queue and expand it, creating a new list of nodes to explore. We use a LIFO 
# queue (stack) here to get depth-first search behaviour as in Prolog. You could 
# try a FIFO queue to get breadth-first searching, or perhaps try one of the more 
# exotic heuristic searches. Each node in our search space consists of the partial 
# solution found so far (a set of variable bindings) and a list of goals yet to 
# solve. If we find a node that has no more goals to solve, then we have solved 
# our original query. If not then we try the next partial solution. Once we find 
# a solution, we clean-up the solution, resolving all temporary variables used 
# in solving sub-goals, and then execute a user-supplied script, providing a 
# dictionary of bindings.

# query goal ?goal ...? rowVar body
#
#       Queries the database for solutions to the given goals (taken as a
#       conjunction). For each solution found, rowVar is set to a dictionary
#       of the bound variables and then body is executed in the caller's
#       scope. As in other loop constructs, if the body returns a [break]
#       then further results are skipped, and a [continue] can be used to
#       retrieve the next result.
#
proc prolog::query args {
    if {[llength $args] < 3} {
        set usage "prolog query goal ?goal ...? rowVar body"
        return -code error "wrong # args: should be \"$usage\""
    }
    set body    [lindex $args end]
    set rowVar  [lindex $args end-1]
    set goals   [lrange $args 0 end-2]

    upvar 1 $rowVar row
    set vars [vars $goals]

    # Perform a depth-first search to find solutions to the goals
    # Nodes in the queue consist of a environment (partial solution) and a
    # list of goals yet to be solved.
    set queue [list [list {} $goals]]

    while {[llength $queue]} {
        set node [pop queue]
        lassign $node solution goals

        if {[llength $goals] == 0} {
            # Found a complete solution: execute the loop body
            set row [cleanup $vars $solution]
            try {
                uplevel 1 $body
            } on break {} {
                break
            } on continue {} {
                continue
            }
        } else {
            # Still more goals to solve: solve the first
            set goal [pop goals]
            push queue {*}[expand $goal $solution $goals]
        }
    }
}
# pop queueVar
#
#       Pops an element off the end of a LIFO queue (stack).
#       Note: change this if you want something other than depth-first
#       search (e.g., change to FIFO for breadth-first).
#
proc prolog::pop queueVar {
    upvar 1 $queueVar queue
    set item [lindex $queue end]
    # Inline [K] trick to ensure unshared queue
    set queue [lrange $queue [set queue 0] end-1]
    return $item
}

# push queueVar element ?...?
#
#       Pushes one or more elements on to the end of a LIFO queue.
#
proc prolog::push {queueVar args} {
    upvar 1 $queueVar queue
    lappend queue {*}$args
}

# cleanup vars env
#
#       Cleans up the variables in a solution, ensuring all variables that
#       were present in the query are resolved as much as possible in the
#       result.
#
proc prolog::cleanup {vars env} {
    set ret [dict create]
    foreach var $vars {
        set val $var
        while {[dict exists $env $val]} { set val [dict get $env $val] }
        set var [string trimleft $var ?]
        dict set ret $var $val
    }
    return $ret
}

#-------------------------------------------------------------------------------
# vars goals
#
#       Returns a list of the free variables present in a list of goals.
#
proc prolog::vars goals {
    set vars [list]
    foreach goal $goals {
        if {[var? $goal] && ($goal ni $vars)} {
            lappend vars $goal
        } else {
            foreach arg [arguments $goal] {
                lappend vars {*}[vars $arg]
            }
        }
    }
    return $vars
}

#-------------------------------------------------------------------------------
# Example

# So, that's our core Prolog interpreter implementation. The next steps would be 
# to explore optimisations, or enhancements. Simple optimisations can come from 
# use of memoizing (e.g., on the "expand" procedure). Enhancements would be support 
# for things like negation-as-failure, disjunction, datatypes, and built-in 
# predicates.

# Some examples, showing the use of the software:
#-------------------------------------------------------------------------------

proc ? args {
    prolog query {*}$args row {
        set result [list]
        dict for {var val} $row { lappend result "$var = $val" }
        puts [join $result ", "]
    }
}

prolog relation father x y
prolog relation mother x y
prolog relation parent x y

prolog assert [father john mary]
prolog assert [mother mary bob]
prolog assert [father peter bob]
prolog assert [father bob susan]

puts "Fathers:"
? [father ?x ?y]

prolog assert [parent ?x ?y] :- [mother ?x ?y]
prolog assert [parent ?x ?y] :- [father ?x ?y]

puts "Parents:"
? [parent ?x ?y]

prolog relation ancestor x y
prolog assert [ancestor ?x ?y] :- [parent ?x ?y]
prolog assert [ancestor ?x ?y] :- [parent ?x ?z] [ancestor ?z ?y]

puts "Ancestors:"
? [ancestor ?x ?y]

puts "Susan's ancestors:"
? [ancestor ?a susan]

puts "Mary's descendents:"
? [ancestor mary ?d]

#-------------------------------------------------------------------------------
# And the output:

# Fathers:
# x = bob, y = susan
# x = peter, y = bob
# x = john, y = mary
# Parents:
# x = bob, y = susan
# x = peter, y = bob
# x = john, y = mary
# x = mary, y = bob
# Ancestors:
# x = john, y = susan
# x = peter, y = susan
# x = john, y = bob
# x = mary, y = susan
# x = bob, y = susan
# x = peter, y = bob
# x = john, y = mary
# x = mary, y = bob
# Susan's ancestors:
# a = john
# a = peter
# a = mary
# a = bob
# Mary's descendents:
# d = susan
# d = bob

#-------------------------------------------------------------------------------

# NEM 2010-07-26: Fixed a bug where variables in clauses were renamed incorrectly. 
# We need to rename variables in clauses in expand rather than assert as the same 
# clause can be used more than once in a single execution, and the variables in 
# each instance should also be distinct from each other to avoid clashes.

#-------------------------------------------------------------------------------
#
#-------------------------------------------------------------------------------
