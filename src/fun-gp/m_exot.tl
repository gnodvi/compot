# -*-   mode: tcl  coding: koi8   -*- ------------------------------------------

#!/bin/sh
# \
exec tclsh "$0" ${1+"$@"}

#-------------------------------------------------------------------------------
# 
#-------------------------------------------------------------------------------

# The Infinite Abacus: Brainfuck's "grand-parent" language

# A version with explicit memory addressing rather than relative moves on a
# stack and a conditional jump instead of loops was introduced by Joachim
# Lambek in 1961 under the name of the Infinite Abacus, consisting of an
# infinite number of cells and two instructions:

# X+ (increment cell X)
# X- else jump T (decrement X if it is positive else jump to T)



# Adding two values

# As a first, simple example, the following code snippet will add the current cell's value to the next cell: Each time the loop is executed, the current cell is decremented, the data pointer moves to the right, that next cell is incremented, and the data pointer moves left again. This sequence is repeated until the starting cell is 0.

# [->+<]

# This can be incorporated into a simple addition program as follows:

# ++       Cell c0 = 2
# > +++++  Cell c1 = 5

# [        Start your loops with your cell pointer on the loop counter (c1 in our case)
# < +      Add 1 to c0
# > -      Subtract 1 from c1
# ]        End your loops with the cell pointer on the loop counter

# At this point our program has added 5 to 2 leaving 7 in c0 and 0 in c1
# but we cannot output this value to the terminal since it is not ASCII encoded.

# To display the ASCII character "7" we must add 48 to the value 7.
# We use a loop to compute 48 = 6 * 8.

# ++++ ++++  c1 = 8 and this will be our loop counter again
# [
# < +++ +++  Add 6 to c0
# > -        Subtract 1 from c1
# ]
# < .        Print out c0 which has the value 55 which translates to "7"!

#-------------------------------------------------------------------------------
# https://wiki.tcl-lang.org/page/Brainfuck
#-------------------------------------------------------------------------------

# A Brainfuck program has an implicit byte pointer, called "the pointer", which
# is free to move around within an array of 30000 bytes, initially all set to zero.
# The pointer itself is initialized to point to the beginning of this array.

# The Brainfuck programming language consists of eight commands, each of which is
# represented as a single character.

# > 	Increment the pointer.
# < 	Decrement the pointer.
# + 	Increment the byte at the pointer.
# - 	Decrement the byte at the pointer.
# . 	Output the byte at the pointer.
# , 	Input a byte and store it in the byte at the pointer.
# [ 	Jump forward past the matching ] if the byte at the pointer is zero.
# ] 	Jump backward to the matching [ unless the byte at the pointer is zero.

# The semantics of the Brainfuck commands can also be succinctly expressed in
# terms of C, as follows (assuming that p has been previously defined as a char*):

# > 	becomes 	++p;
# < 	becomes 	--p;
# + 	becomes 	++*p;
# - 	becomes 	--*p;
# . 	becomes 	putchar(*p);
# , 	becomes 	*p = getchar();
# [ 	becomes 	while (*p) {
# ] 	becomes 	}

#-------------------------------------------------------------------------------

proc getp {} {
  global pc program
  lindex $program $pc
}
proc getd {} {
  global xc data
  while {[llength $data]-1 < $xc} {
    lappend data 0
  }
  lindex $data $xc
}
proc setd {c} {
  global xc data
  while {[llength $data]-1 < $xc} {
    lappend data 0
  }
  lset data $xc $c
}

proc main {commands} {
  
  global program data pc xc

  set program [split $commands ""]
  set plen [llength $program]
  set data {0}
  set xc 0

  for {set pc 0} {$pc < $plen} {incr pc} {
    switch [lindex $program $pc] {
      > {
	incr xc
      }
      < {
	incr xc -1
      }
      + {
	setd [expr {[getd] + 1}]
      }
      - {
	setd [expr {[getd] - 1}]
      }
      . {
	puts -nonewline [format "%c" [getd]]
      }
      , { 
	if {![eof stdin]} {
	  scan [read stdin 1] "%c" var
	  setd $var
	} else {
	  setd 0
	}
      }

      \[ {
	if {[getd] == 0} {
	  incr pc
	  set nest 0
	  while {$nest || [getp] ne "\]"} {
	    switch [getp] {
	      \[ {incr nest}
	      \] {incr nest -1}
	    }
	    incr pc
	  }
	}
      }
      \] {
	if {[getd] != 0} {
	  incr pc -1
	  set nest 0
	  while {$nest || [getp] ne "\["} {
	    switch [getp] {
	      \[ {incr nest -1}
	      \] {incr nest}
	    }
	    incr pc -1
	  }
	}
      }
      \# {
	# Purely for debugging
	puts -nonewline "\nDebug: "
	for {set tmp 0} {$tmp < 10} {incr tmp} {
	  puts -nonewline "[lindex $data $tmp]:"
	}
	puts ""
      }
    }
  }
}

proc readfile {args} {
  switch [llength $args] {
    0 {
      set fd stdin
    }
    1 {
      set fd [open [lindex $args 0]]
    }
    default {
      puts stderr "Usage: [file tail [info script]] ?filename?"
      exit 1
    }
  }
  set text [read $fd]
  if {$fd ne "stdin"} {
    close $fd
  }
  return $text
}
#--------------------------------------------
proc run_main_1 {} {

  fconfigure stdout -buffering none
  fconfigure  stdin -buffering none
  
  set commands [readfile {*}$argv]
  main $commands
  
  puts ""

}
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------

#PT You could try the following program with the above interpreter...

 # =
 # =  badger badger mushroom snake
 # =
 
 # >>++++[<+++++[<+++++>-]>-]<<---[>>+>+>+>+>+>+<<<<<<<-]
 # >>+     b
 # >       a
 # >+++    d
 # >++++++ g
 # >++++   e
 # >>++++[<++++>-]<+ r
 
 # <<<<<<<
 # >++++[<++++>-]<
 # [>+++++[>.>.>.>.>.>.<<<<<<-]<-]
 
 # mushroom
 # ++++[>>+++>+++>+++>>+++<<<<<<-]>>->++++++++>+++>+>+>
 # [>>>>+<<<<-]
 # >>>>[<+<+<+<+>>>>-]
 # <<-----<---<---<
 # <<<<<<
 # print
 # ++[>>.>.>.>.>.>.>.>.<<<<<<<<<-]
 
 # snake!
 # >>>--.-----.>>>[-]>[-]<<[>+>+<<-]>-------.>+++.<++++.
 # <<<[-]>[-]++++++[<+++++>-]<+++.


#-------------------------------------------------------------------------------
#https://www.rosettacode.org/wiki/Execute_Brain****/Tcl
#-------------------------------------------------------------------------------
package require Tcl 8.5

fconfigure stdout -buffering none
fconfigure  stdin -buffering none

if {0} {
  
  if {![llength $argv]} {
    set p [split [read stdin] {}]
  } else {
    set fd [open [lindex $argv 0]]
    set p [split [read $fd] {}]
    close $fd
  }
}

set p [split {++++++++++[>+++++++>++++++++++>+++>+<<<<-]>++.>+.+++++++..+++.>++.<<+++++++++++++++.>.+++.------.--------.>+.>.} {}]


set d [lrepeat 30000 0]
set dc 0

set len [llength $p]

puts ""
puts "p = $p, len = $len"
puts ""

for {set pc 0} {$pc < $len} {incr pc} {
  
  switch [lindex $p $pc] {
    ">" {
      incr dc
    }
    "<" {
      incr dc -1
    }
    "+" {
      lset d $dc [expr {[lindex $d $dc] + 1}]
    }
    "-" {
      lset d $dc [expr {[lindex $d $dc] - 1}]
    }
    "." {
      puts -nonewline [format "%c" [lindex $d $dc]]
    }
    "," {
      lset d $dc [scan [read stdin 1] "%c"]
    }
    "\[" {
      if {![lindex $d $dc]} {
	incr pc
	for {set n 0} {$n || [lindex $p $pc] ne "\]"} {incr pc} {
	  switch -- [lindex $p $pc] "\[" {incr n} "\]" {incr n -1}
	}
      }
    }
    "\]" {
      if {[lindex $d $dc]} {
	incr pc -1
	for {set n 0} {$n || [lindex $p $pc] ne "\["} {incr pc -1} {
	  switch -- [lindex $p $pc] "\[" {incr n -1} "\]" {incr n}
	}
      }
    }
  }
}

#-------------------------------------------------------------------------------
# https://github.com/m-ender/brian-chuck
#-------------------------------------------------------------------------------

# Brian and Chuck are two Brainfuck-like programs. Only one of them is being
# executed at any given time, starting with Brian. The catch is that Brian's
# memory tape is also Chuck's source code. And Chuck's memory tape is also Brian's
# source code. Furthermore, Brian's tape head is also Chuck's instruction pointer
# and vice versa. The tapes are semi-infinite (i.e. infinite to the right) and
# can hold signed arbitrary-precision integers, initialised to zero (unless
# specified otherwise by the source code).

# Since the source code is also a memory tape, commands are technically defined by
# integer values, but they correspond to reasonable characters. The following
# commands exist:

# , (44): Read a character from STDIN into the current memory cell.
# Only Brian can do this. This command is a no-op for Chuck.
# . (46): Write the current memory cell, modulo 256, as a character to STDOUT.
# Only Chuck can do this. This command is a no-op for Brian.
#     + (43): Increment the current memory cell.
#     - (45): Decrement the current memory cell.
# ? (63): If the current memory cell is zero, this is a no-op. Otherwise,
# hand control over to the other program. The tape head on the program which
# uses ? will remain on the ?. The other program's tape head will move one cell
# to the right before executing the first command (so the cell which is used as
# the test is not executed itself).
# < (60): Move the tape head one cell to the left. This is a no-op if the
# tape head is already at the left end of the tape.
#     > (62): Move the tape head one cell to the right.
# { (123): Repeatedly move the tape head to the left until either the current
#   cell is zero or the left end of the tape is reached.
# } (125): Repeatedly move the tape head to the right until the current cell
# is zero.

# The program terminates when the active program's instruction pointer reaches
# a point where there are no more instructions to its right.
# The Source Code

# The source file is processed as follows:

# If the file contains the string ```, the file will be split into two parts
# around the first occurrence of that string. All leading and trailing whitespace
# is stripped and the first part is used as the source code for Brian and the
# second part for Chuck.
# If the file does not contain this string, the first line of the file will
# be used as the source for Brian and the second part for Chuck (apart from
# the delimiting newline, no whitespace will be removed).
# All occurrences of _ in both programs are replaced with NULL bytes. This
# allows you to insert zero cells more easily into the source.
# The two memory tapes are initialised with the character codes corresponding
# to the resulting string.

# As an example, the following source file

#   abc
# ```
# 0_1
# 23

# Would yield the following initial tapes:

# Brian: [97 98 99 0 0 0 0 ...]
# Chuck: [48 0 49 10 50 51 0 0 0 0 ...]

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
