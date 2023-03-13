# -*-   mode: tcl  ; coding: koi8   -*- ----------------------------------------

#-------------------------------------------------------------------------------

package require Tk
package require TclOO

#-------------------------------------------------------------------------------

 # GoBoard.tcl
#-------------------------------------------------------------------------------

 proc mv {ax ay} {
    global c
    set x  [.c canvasx $ax]; set y [.c canvasy $ay]
    set id [.c find withtag current]
    .c move $id [expr $x-$c(X)] [expr $y-$c(Y)]
    .c raise $id
    set c(X) $x; set c(Y) $y
 }

 proc drop {ax ay} {
    global c grid size title
    set s2 [expr $size/2]
    set id [.c find withtag current]
    set x [.c canvasx $ax]; set y [.c canvasy $ay]
    set x1 [expr (int($x+$s2)/$grid)*$grid]
    set y1 [expr (int($y+$s2)/$grid)*$grid]
    .c coords $id [expr $x1-$s2] [expr $y1-$s2] \
            [expr $x1+$s2] [expr $y1+$s2]
    wm title . "$title - last: [.c itemcget $id -fill]"
 }

 proc reset {w} {
    global grid size colors title
    wm title . $title
    $w delete mv
    set xm1 [expr $grid-$size]
    set xm2 [expr $grid*19]
    set ym  [expr $grid*20+$size/2]
    set c2  [lindex $colors 2]
    set c3  [lindex $colors 3]
    for {set i 0} {$i<180} {incr i} {  ;# create stones:
      $w create oval $xm1 $ym [expr $xm1+$size] [expr $ym+$size] \
            -fill $c2 -outline $c3 -tags {mv player1}
        $w create oval $xm2 $ym [expr $xm2+$size] [expr $ym+$size] \
                -fill $c3 -outline $c2 -tags {mv player2}
        incr xm1; incr xm2 -1
    }
 }

 proc board {grid colors linewidth} {
   set y  [set x  [set y0 [set x0 $grid]]]
   set y1 [set x1 [expr $grid*19]]
   set fill [lindex $colors 1]
   set dot 3
   for {set i 0} {$i<19} {incr i} {  ;# create playfield:
      .c create line $x  $y0 $x  $y1 -fill $fill -width $linewidth
      .c create line $x0 $y  $x1 $y  -fill $fill -width $linewidth
      if {$i==3 || $i==9 || $i==15} {
        foreach j {3 9 15} {
          set xx [expr $x0 + $j * $grid]
          .c create oval [expr $xx-$dot] [expr $y-$dot] [expr $xx+$dot] [expr $y+$dot] -fill $fill
       }
     }
     .c create text [expr $x0-10]  $y  -text [expr 19-$i]   ;# Labels 1..19
     incr x $grid; incr y $grid
   }
   set  x $x0
   incr y  -8
   for {set i 0} {$i<19} {incr i} {  ;# Labels A..T:
    .c create text $x $y  -text [string index "ABCDEFGHJKLMNOPQRSTx" $i]
    incr x $grid;
   }
   reset .c
 }

 set title "Go"
 set size 18   ;# this determines all other scaling
 set colors {beige brown white black} ;# 2 for board, 2 for men
 set linewidth 2
 set grid [expr int($size*1.2)]
 canvas .c -width [expr $grid*20] -height [expr $grid*20+2*$size]
 pack   .c
 wm resizable . 0 0
 .c bind mv <1>               {set c(X) [.c canvasx %x]; set c(Y) [.c canvasy %y]}
 .c bind mv <B1-Motion>       {mv %x %y}
 .c bind mv <ButtonRelease-1> {drop %x %y}

 button .c.b -text X -command {reset .c} -padx 0 -pady 0
 .c create rect 0 0 [expr $grid*20] [expr $grid*20] -fill [lindex $colors 0]
 .c create window   [expr $grid*10] [expr $grid*21-$size] -window .c.b -anchor n
 board $grid $colors $linewidth
 
#-------------------------------------------------------------------------------
