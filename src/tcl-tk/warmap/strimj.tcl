#------------------------------------------------------------------------------
# strimj.tcl -- TITLE: strimj - string image routines
# R. Suchenwirth, Konstanz 2001
#------------------------------------------------------------------------------
if 0 {
[Richard Suchenwirth] - "Everything is a string", the old Tcl mantra
goes, so what about images? Image data can indeed be specified as
strings (in XBM format for bitmaps, GIF/PPM for photos), but those are
not exactly nice to look at. Here I explore what can be done with naive
string images ("strimjes"), where one character specifies one pixel's color (except
for newline, which of course starts a new pixel line), using the string
processing typical for Tcl. These routines work best for small images
(area below 10000) with simple colormaps (e.g. icons), but then again they offer us
features that ''photo'' or even more ''bitmap'' lack:
   * rotation (in 90-degrees increments)
   * shearing (slanting)
   * concatenating multiple images
   * zooming, subsampling, flipping (''photo'' has them too)
... and other manipulations can easily be thought of. The concatenation
feature allows a beautifully simple text rendering system, where every
single pixel is under Tcl control (as a side effect, you get old-fashioned
"banner printing" if you were looking for that). Such strimjes
can then be converted to bitmap or photo images for display.

Fonts can be defined in such a clear manner (see code below) that my 11yo daughter Hanke
was able to spot a bug, and rendered into images as simply as
 strimj::text Hello
which returns a banner-like human-readable pattern that can be fed into
the other routines (or ''puts [[string map {. " "} ...]]'':
 @...@.......@.@......
 @...@.......@.@......
 @...@..@@@..@.@..@@@.
 @@@@@.@...@.@.@.@...@
 @...@.@@@@@.@.@.@...@
 @...@.@.....@.@.@...@
 @...@.@...@.@.@.@...@
 @...@..@@@..@.@..@@@.
The ''strimj::char'' command implements a character finding mechanism
that first looks in the specified font, then the default, then all others,
and finally substitutes a "?" if no match was possible. The "font
database" (just a namespaced array) can be used for organizing other
images too - if their names are >1 characters long, you don't risk
having them mistaken for characters.

I could keep most of the routines very short - runtime is
another issue, better stay with icons and such, but it's amazing how
little code can bring great effects. The script below contains a demo
which also displays the time needed in seconds. Play, enjoy, improve on
it!
}
#------------------------------------------------------------------------------

namespace eval strimj {
#------------------------------------------------------------------------------

variable Font
variable defaultColors {
  r red g green b blue c cyan m magenta y yellow o orange . white
  0 #000 1 #080808 2 #111 3 #181818 4 #222 5 #282828 6 #333
  7 #383838 8 #444 9 #484848 A #555 B #585858 C #666 D #686868
  E #777 F #787878 G #888 H #888888 I #999 J #989898 K #AAA
  L #A8A8A8 M #BBB N #B8B8B8 O #CCC P #C8C8C8 Q #DDD R #D8D8D8
  S #EEE T #E8E8E8 U #F0F0F0 V #F8F8F8
}
proc bitmap {si args} {eval [list image create bitmap -data [xbm $si]] $args}
proc char {char {font -}} {
  #--- retrieve an image from the font database
  variable Font
  if [info exist Font($font,$char)] {
    set res $Font($font,$char)
  } else {
    set font $Font(default)
    if [info exist Font($font,$char)] {
      set res $Font($font,$char)
    } else {
      set choices [array names Font *,$char]
      if [llength $choices] {
        set res $Font([lindex $choices 0])
      } else {set res $Font(unknown)}
    }
  }
  set res
}
proc concat {si1 si2 {pad ""}} {
  #--- horizontally join two strimjes
  set si [expand $si1 0 [util::max [height $si1] [height $si2]]]
  set res {}
  foreach line1 [lines $si] line2 [lines $si2]  {
    lappend res "$line1$pad$line2"
  }
  join $res \n
}
proc contour {si color} {
  regsub -all { ([^ ])} [shift $si 1 1] $color\\1 si
  regsub -all {([^ ]) } $si \\1$color si
  set si [rot90 $si]
  regsub -all { ([^ ])} $si $color\\1 si
  regsub -all {([^ ]) } $si \\1$color si
  rotate $si 270
}
proc expand {si {w 0} {h 0}} {
  #--- turn a strimj to specified dim. and equal-length lines
  if {!$w} {set w [width  $si]}
  if {!$h} {set h [height $si]}
  set res {}; set n 0; set filler " "
  foreach line [lines $si] {
    lappend res [util::pad line $w $filler]
    incr n
  }
  set filline [string repeat $filler $w]
  while {$n<$h} {lappend res $filline; incr n}
  join $res \n
}
proc flip {si axis} {
  switch -- $axis {
    x       {join [util::lrevert [lines $si]] \n}
    y       {join [util::map util::revert [lines [expand $si]]] \n}
    default {error "bad axis $axis: must be x or y"}
  }
}
proc font {font data} {
  #--- add one or more images to the font database
  variable Font
  foreach {labels si} $data {
    foreach label $labels {set Font($font,$label) ""}
    foreach line [lines $si] {
      foreach label $labels pixels $line {
        append Font($font,$label) $pixels\n
      }
    }
    foreach label $labels {
      set Font($font,$label) [string map {. " "} $Font($font,$label)]
    }
  }
}
proc height si {llength [lines $si]}
proc kern {si1 si2 {pad ""}} {
  set si [expand $si1 0 [util::max [height $si1] [height $si2]]]
  set minriver 99999
  foreach line1 [lines $si] line2 [lines $si2]  {
    set river1 ""; regexp {([ .]+)$} $line1 -> river1
    set river2 ""; regexp {^([ .]+)} $line2 -> river2
    set river [string length $river1$river2]
    if {$river<$minriver} {set minriver $river}
  }
  set dx [expr {[width $si]-$minriver+[string length $pad]}]
  or $si [shift $si2 $dx]
}
proc lines  si {split [string trim $si \n] \n}
proc new   {width height {color " "}} {zoom $color $width $height}
proc or {si1 si2} {
  set res {}
  foreach l1 [lines $si1] l2 [lines $si2] {
    lappend res [orLine $l1 $l2]
  }
  join $res \n
}
proc orLine {line1 line2} {
  set res ""
  foreach p1 [split $line1 ""] p2 [split $line2 ""] {
    if {$p2==" " || $p2==""} {
      set p $p1
    } else {set p $p2}
    if {$p==""} {set p " "}
    append res $p
  }
  set res
}
proc photo {si {usermap ""}} {
  variable defaultColors
  array set map [concat $defaultColors $usermap]
  set img [image create photo -height [height $si] -width [width $si]]
  set y 0
  foreach line [lines $si] {
    set x 0
    foreach char [split $line ""] {
      if {$char!=" "} {
        if {![info exist map($char)]} {set map($char) black}
        $img put $map($char) -to $x $y
      }
      incr x       
    }
    incr y
  }
  set img
}
proc rotate {si angle} {
  switch -- $angle {
    90      {rot90 $si}
    180     {flip [flip $si x] y}
    270     {rot90 [rotate $si 180]}
    default {error "bad angle $angle: must be 90|180|270"}
  }
}
proc rot90 si {
  set cols [util::range [width $si]]
  foreach line [lines [expand $si]] {
    foreach col $cols char [split $line ""] {
      append $col $char
    }
  }
  join [util::lrevert [util::lget $cols]] \n
}
proc shear {si {gradient 3}} {
  set lines [lines $si]
  set h [llength $lines]
  set bias [expr {$h % $gradient}]
  set res {}
  set n 0
  foreach line $lines {
    set dx [expr {($gradient>0?($h-$n-1):$bias-$n)/$gradient}]
    append res [string repeat " " $dx]$line\n
    incr n
  }
  set res
}
proc shift {si {x 0} {y 0}} {
  set res [string repeat "{ } " $y]
        foreach line [lines $si] {
            lappend res [string repeat " " $x]$line
        }
        join $res \n
    }
    proc subsample {si {xfac 2} {yfac 0}} {
        if {!$yfac} {set yfac $xfac}
        set ilist [string repeat "i " $yfac]
        set res {}
        foreach $ilist [lines $si] {
            lappend res [subsampleLine $i $xfac]
        }
        join $res \n
    }
    proc subsampleLine {string xfac} {
        set ilist [string repeat "i " $xfac]
        set res ""
        foreach $ilist [split $string ""] {append res $i}
        set res
    }
    proc text {string args} {
        #--- render a string into a strimj
        array set opt [::concat {-font - -pad " " -kern 0} $args]
        set si [char [string index $string 0] $opt(-font)]
        set cmd [expr {$opt(-kern)? "kern": "concat"}]
        foreach c [split [string range $string 1 end] ""] {
            set si [$cmd $si [char $c $opt(-font)] $opt(-pad)]
        }
        set si
    }
    proc width si {util::max [util::map "string length" [lines $si]]}
    proc xbm si {
        set si [string map {" " 0 . 0} [expand $si]]
        set lines [lines $si]
        set width [string length [lindex $lines 0]]
        set height [llength $lines]
        set bytes {}
        foreach line $lines {
            regsub -all {[^0]} $line 1 line ;# black pixel
            foreach bin [split [binary format b* $line] ""] {
                    lappend bytes [scan $bin %c]
            }
        }
        set    res "#define i_width $width\n#define i_height $height\n"
        append res "static char i_bits\[\] = {\n[join $bytes ,]\n}"
    }
#------------------------------------------------------------------------------
    proc zoom {si {xfac 2} {yfac 0}} {
        #--- negative zoom factors imply flipping
        if {$xfac<0} {
            set si [flip $si x]
            set xfac [expr {-$xfac}]
        }
        if {$yfac<0} {
            set si [flip $si y]
            set yfac [expr {-$yfac}]
        }
        if {$xfac==1 && $yfac==1} {return $si}
        if {!$yfac} {set yfac $xfac}
        #--- zoom factors<1 imply subsampling
        if {$xfac<1 && $yfac<1} {
            set xfac [expr {round(1./$xfac)}]
            set yfac [expr {round(1./$yfac)}]
            return [subsample $si $xfac $yfac]
        }
        set res {}
        foreach line [lines $si] {
            foreach - [util::range $yfac] {
                lappend res [util::strmul $line $xfac]
            }
        }
        join $res \n
    }
    set Font(default) 5x10
    font 5x10 {
    {\ } ...
    {A B C D E F G H I J K} "
        ..@.. @@@@  .@@@. @@@   @@@@@ @@@@@ .@@@. @...@ @@@ ....@ @...@
        .@.@. @...@ @...@ @..@  @     @     @...@ @...@ .@  ....@ @..@
        @...@ @...@ @     @...@ @     @     @     @...@ .@  ....@ @.@
        @...@ @@@@. @     @...@ @@@@  @@@@  @..@@ @@@@@ .@  ....@ @@
        @@@@@ @...@ @     @...@ @     @     @...@ @...@ .@  ....@ @.@
        @...@ @...@ @     @...@ @     @     @...@ @...@ .@  ....@ @..@
        @...@ @...@ @...@ @..@  @     @     @...@ @...@ .@  @...@ @...@
        @...@ @@@@  .@@@  @@@   @@@@@ @     .@@@  @...@ @@@ .@@@  @....@"
    {L M N O P Q R S T U} "
        @     @...@ @....@ .@@@. @@@@  .@@@. @@@@  .@@@. @@@@@ @...@
        @     @@.@@ @@...@ @...@ @...@ @...@ @...@ @...@ ..@   @...@
        @     @.@.@ @@...@ @...@ @...@ @...@ @...@ @     ..@   @...@
        @     @.@.@ @.@..@ @...@ @...@ @...@ @...@ .@@.  ..@   @...@
        @     @...@ @..@.@ @...@ @@@@  @...@ @@@@  ...@  ..@   @...@
        @     @...@ @..@@@ @...@ @     @.@.@ @.@   ....@ ..@   @...@  
        @     @...@ @...@@ @...@ @     @..@  @..@  @...@ ..@   @...@
        @@@@@ @...@ @....@ .@@@  @     .@@.@ @...@ .@@@. ..@   .@@@."
    {V W X Y Z} "
        @...@ @...@ @...@ @...@ @@@@@@
        @...@ @...@ @...@ @...@ .....@
        @...@ @...@ @...@ .@.@. ....@
        @...@ @.@.@ .@.@. .@.@  ...@
        .@.@. @.@.@ ..@.. ..@   ..@.
        .@.@. @@.@@ .@.@. ..@   .@..
        .@.@. @@.@@ @...@ ..@   @...
        ..@.. @...@ @...@ ..@   @@@@@@"
    {0 1 2 3 4 5 6 7 8 9} "
        .@@@. ..@.. .@@@. .@@@. .@.@. @@@@@ .@@@. @@@@@ .@@@. .@@@.
        @...@ .@@.. @...@ @...@ .@.@. @     @...@ ....@ @...@ @...@
        @@..@ @.@.. ....@ ....@ @..@. @     @     ...@  @...@ @...@
        @.@.@ ..@.. ...@  ..@@  @..@. @.@@  @@@@  ...@  .@@@. @...@
        @..@@ ..@.. ..@   ....@ @@@@@ @@..@ @...@ ..@   @...@ .@@@@
        @...@ ..@.. .@    ....@ ...@  ....@ @...@ ..@   @...@ ....@
        @...@ ..@.. @.    @...@ ...@  @...@ @...@ ..@   @...@ @...@
        .@@@. .@@@. @@@@@ .@@@  ...@  .@@@  .@@@. ..@   .@@@. .@@@."
    {a b c d e f h i k l m n} "
        ..... @.... ..... ....@ ..... .@@ @     @ @     @ .       .
        ..... @.... ..... ....@ ..... .@  @     . @     @ .       .
        .@@@. @.@@  .@@@. .@@.@ .@@@. .@. @.@@  @ @..@  @ @@@.@@. @.@@
        ....@ @@..@ @...@ @..@@ @...@ @@@ @@..@ @ @.@   @ @..@..@ @@..@
        .@@@@ @...@ @     @...@ @@@@@ .@  @...@ @ @@    @ @..@..@ @...@
        @...@ @...@ @.... @...@ @.... .@  @...@ @ @.@   @ @..@..@ @...@
        @..@@ @...@ @...@ @..@@ @...@ .@  @...@ @ @..@  @ @..@..@ @...@
        .@@.@ @@@@. .@@@. .@@.@ .@@@. .@  @...@ @ @...@ @ @..@..@ @...@"
    {o r s t u v w x z} "
        ..... .    .     .@. .     .     .         .     .
        ..... .    .     .@. .     .     .         .     .
        .@@@. @.@@ .@@@. @@@ @...@ @...@ @...@...@ @...@ @@@@@
        @...@ @@   @...@ .@. @...@ @...@ @...@...@ .@.@. ...@.
        @...@ @    .@@   .@. @...@ .@.@. .@.@.@.@  ..@.. ..@..
        @...@ @    ...@. .@. @...@ .@.@. .@.@.@.@  .@.@. .@...
        @...@ @    @...@ .@  @..@@ ..@   ..@...@   @...@ @  
        .@@@. @    .@@@. .@. .@@.@ ..@.. ..@...@   @...@ @@@@@"
    {g j p q y} "
        .     .@ .     .     .
        .     .. .     .     .
        .@@.@ .@ @.@@. .@@.@ @...@
        @..@@ .@ @@..@ @..@@ @...@
        @...@ .@ @...@ @...@ @...@
        @...@ .@ @...@ @...@ .@.@.
        @..@@ .@ @...@ @...@ .@.@.
        .@@.@ .@ @@@@. .@@@@ ..@..
        ....@ .@ @     ....@ .@...
        .@@@  @  @     ....@ @"
    {! {"} # {$} % ' ( ) + , - . /} "
        @ @.@ .@.@. ..@.. .@...@ @ ..@ @   ..... .. ..... . ...@
        @ @.@ .@.@. .@@@  @.@..@ @ .@  .@  ..... .. ..... . ...@
        @ .   @@@@@ @.@.@ .@..@  . @   ..@ ..@.. .. ..... . ..@
        @ .   .@.@  @.@   ...@   . @   ..@ ..@.. .. ..... . ..@
        @ .   .@.@. .@@@. ..@..  . @   ..@ @@@@@ .. @@@@@ . .@
        @ .   @@@@@ ..@.@ .@..@. . @   ..@ ..@.. .. ..... . .@
        . .   .@.@  @.@.@ @..@.@ . .@  .@  ..@.. @@ ..... . @
        @ .   .@.@  .@@@  @...@  . ..@ @   ..... @. ..... @ @"
    ? "
        .@@@.
        @...@
        ....@
        ...@.
        ..@..
        ..@..
        .....
        ..@.."
    }
    font kerntest {
    {A V L T} "
        ....@      @.......@ @        @@@@@@@@@
        ...@.@     .@.....@  @        ....@...
        ..@...@    ..@...@   @        ....@...
        .@.....@   ..@...@   @        ....@...
        .@@@@@@@   ...@.@    @        ....@
        @.......@  ...@.@    @        ....@
        @.......@  ....@     @@@@@@@  ....@"
    }
    font demo {
        fx "
        ...@
        ..@@@
        .@@@@@
        @@@@@@@
        ...@
        ...@
        ...@
        @@@@@@@
        .@@@@@
        ..@@@
        ...@"
        fy "
        ...@...@
        ..@@...@@
        .@@@...@@@
        @@@@@@@@@@@
        .@@@...@@@
        ..@@...@@
        ...@...@"
        rot "
        ...@
        ..@@
        .@@@
        @@@@@@@
        .@@@...@
        ..@@...@
        ...@...@
        .......@"
    }
    set Font(unknown) $Font(5x10,?)
 } ;# end namespace strimj
 
 # utilities of general use, may some day go into their own package
 namespace eval util {
    proc lget varlist {
        #-- turn a list of var.names in caller's scope to their values
        set res {}
        foreach var $varlist {lappend res [uplevel 1 set $var]}
        set res
    }
    proc lrevert list {
        #--- e.g. lrevert {a b c} => c b a
        set res {}
        for {set i [expr {[llength $list]-1}]} {$i>=0} {incr i -1} {
            lappend res [lindex $list $i]
        }
        set res
    }
    proc map {func list} {
        #--- apply a function to each element of a list
        set res {}
        foreach i $list {lappend res [eval $func [list $i]]}
        set res
    }
    proc max args {
        if {[llength $args]==1} {set args [lindex $args 0]}
        lindex [lsort -real -decreasing $args] 0
    }
    proc pad {_string length filler} {
        upvar $_string string
        set n [expr {$length-[string length $string]}]
        append string [string repeat $filler $n]
    }
    proc range n {
        #--- produce a list from 0 to n-1 (for unrolling for's) 
        set res {}
        for {set i 0} {$i<$n} {incr i} {lappend res $i}
        set res
    }
    proc revert string {join [lrevert [split $string ""]] ""}
    proc strmul {string factor} {
        #--- multiply a string, e.g. strmul ABC 3 => AAABBBCCC
        set res ""
        foreach char [split $string ""] {
            for {set i 0} {$i<$factor} {incr i} {
                append res $char
            }
        }
        set res
    }
 }
 #--- test and demo code... 
 if {[file tail [info script]]==[file tail $argv0]} {
    proc strimj::demo {} {
        variable Font
        regsub -all {[^ ]+,} [array names Font *,?] "" abc
        #set ::demoimg [text [join [lsort $abc] ""]]
        set ::demoimg [text "Abc 123" -background white]
        trace var ::demoimg w {.l config -image [strimj::bitmap $::demoimg] ;#}
        label .info -textvar ::info
        frame .f
        #set im [bitmap [or [shift [zoom @ 10 1] 0 15] [shift [zoom @ 1 15] 5]]]
        #set im [photo [zoom ry\ngb 12]]
        #set im [photo [zoom 0123456789ABCDEFGHIJKLMNOPQRSTUVW 2 32]]
        set im [photo [zoom roygcbmroygcbm 3 24]]
        label .f.l -image $im
        button .f.fx -image [bitmap [char fx]] -command {
            tell {set ::demoimg [strimj::flip $::demoimg x]}
        }
        button .f.fy -image [bitmap [char fy]] -command {
            tell {set ::demoimg [strimj::flip $::demoimg y]}
        }
        button .f.rot -image [bitmap [char rot]] -command {
            tell {set ::demoimg [strimj::rot90 $::demoimg]}
        }
        button .f.zoom -text "+" -command {
            tell {set ::demoimg [strimj::zoom $::demoimg]}
        }
        button .f.unzoom -text " - " -command {
            tell {set ::demoimg [strimj::subsample $::demoimg]}
        }
        button .f.slant -text "/" -command {
            tell {set ::demoimg [strimj::shear $::demoimg $::slope]}
        }
        entry .f.slope -textvar slope -width 2
        set ::slope 3
        button .f.slant- -text "\\" -command {
            tell {set ::demoimg [strimj::shear $::demoimg -$::slope]}
        }
        bind .f.unzoom <3> {tell {set ::demoimg $::demoimg}}
        eval pack [winfo children .f] -side left -fill both -ipadx 2
        label .l -image [bitmap $::demoimg] -bg white
        pack .info .f .l
    }
     proc tell body {
        set microsec [lindex [time $body] 0]
        set img $::demoimg
        set w [strimj::width $img]
        set h [strimj::height $img]
        set ::info "$w*$h=[expr {$w*$h}]: [expr {$microsec/1000000.}]"
    }
#------------------------------------------------------------------------------

strimj::demo

#------------------------------------------------------------------------------
}
#------------------------------------------------------------------------------
 
