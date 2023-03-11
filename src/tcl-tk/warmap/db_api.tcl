# dbapi.tcl - TITLE: A simple database API
if 0 { 
[Richard Suchenwirth] - Tcl [array]s can be used for implementing [a
simple database]. Here is an "API" that wraps typical accesses, which
I originally needed for [Tclworld], but it's general enough to be
factored out. Let's start with the

USAGE
   * '''db''' ''name'' -- declare a database (no harm if repeated)
   * ''name'' -- returns all defined keys in no particular order
   * ''name'' {} -- clears the whole database
   * ''name key'' -- returns all item/value pairs associated with ''key''
   * ''name key'' {} -- removes entry ''key'' from database
   * ''name key item'' -- returns the value for ''item'' of ''key''
   * ''name key item value...'' -- sets ''item'' of ''key'' to ''value''
   
Pretty abstract, but very concise - it's amazing how much functionality
can be expressed with a keyword-less language (if you except the initial
''db''), just controlled by the number of arguments. Examples:
 db geo::info
 geo::info Hamburg pop 1234560
 geo::info Hamburg it: Amburgo
 geo::info             ;#=> Hamburg
 geo::info Hamburg     ;#=> pop 1234560 it: Amburgo
 geo::info Hamburg pop ;#=> 1234560
}
 proc db {database args} {
    upvar #0 $database db
    set key "" ;# in case args is empty
    foreach {- key item value} $args break
    set exists [info exists db($key)]
    set res {}
    switch [llength $args] {
        0 {
            array set db {} ;# force to be an array
            interp alias {} $database {} db $database -
            set res $database
        }
        1 {set res [array names db]}
        2 {if {$key != ""} {
                if {$exists} {set res $db($key)}
           } else {array unset db}
        }
        3 {if {$item != ""} {
                if {$exists} {
                    set t $db($key)
                    if {!([set pos [lsearch $t $item]]%2)} {
                        set res [lindex $t [incr pos]]
                    }
                }
           } elseif {$exists} {unset db($key)}
        }
        4 {
            if {$exists} {
                if {!([set pos [lsearch $db($key) $item]]%2)} {
                    if {$value != ""} {
                      set db($key) [lreplace $db($key) [incr pos] $pos $value]
                    } else {set db($key) [lreplace $db($key) $pos [incr pos]]}
                } elseif {$value != ""} {
                    lappend db($key) $item $value
                }
            } elseif {$value != ""} {set db($key) [list $item $value]}
            set res $value ;# to be returned
        }
        default {
            if {[llength $args]%2} {error "non-paired item/value list"}
            foreach {item value} [lrange $args 2 end] {
                db $database - $key $item $value
            }
        }
    }
    set res
 }
 if {[file tail $argv]==[file tail [info script]]} {
    foreach test [split {
        db Test
        Test Hamburg pop 1234560 cn: Hanbao
        Test Hamburg it: Amburgo
        Test  ;#=> Hamburg
        Test Hamburg ;#=> pop 1234560 it: Amburgo
        Test Hamburg pop ;#=> 1234560
    } \n] {
        puts -nonewline "$test --> " 
        puts [eval $test]
    }
 }
 
