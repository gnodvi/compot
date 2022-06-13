# -*-   mode: tcl  ; coding: koi8   -*- ----------------------------------------

#-------------------------------------------------------------------------------
#!/bin/sh
# Restart with tcl:  \
exec wish $0 ${1+"$@"}

#-------------------------------------------------------------------------------
#  http://wiki.tcl.tk/17067
# Widgets on a canvas
# Updated 2016-01-31 05:34:02 by HJG
#-------------------------------------------------------------------------------
# Summary edit

# HJG 2006-10-16: This is an example of how to put widgets onto a canvas.

# It shows a simplified schema of a neuron [1], which is summing up its input-signals,
# and 'fires' when this sum exceeds a threshold.
# With the sliders you can change the input, their weight and the threshold.
# Code edit

 # neuro1.tcl - HaJo Gurt - 2006-10-17 - http://wiki.tcl.tk/17067
 #: Widgets on a canvas : Sliders + Entryfields
 # Simple Schema of a neuron, summing its input-signals,
 # and firing when the sum exceeds a threshold.
#-------------------------------------------------------------------------------

  package require Tk

  array set S { x1 20  w1 1   x2 50  w2  8 \
                t1 500 title "Neuronal Processing" \
                s1 0   s2 0  sum 0  out 0 }

  proc int x { expr int($x) }

  proc Calc x {
  #: Calculate results + update display
    global S

    set S(s1)  [expr {$S(x1) * $S(w1)} ]
    set S(s2)  [expr {$S(x2) * $S(w2)} ]
    set S(sum) [expr {$S(s1) + $S(s2)} ]
    set S(out) [expr {$S(sum) >= $S(t1)} ]
    if { $S(out) } {
      .c itemconfig out -fill red
    } else {
      .c itemconfig out -fill cyan
    }
  }

  proc Init {} {
  #: Build GUI
    global S

    wm title . "Neuro1"
    canvas .c -relief raised  -borderwidth 0  -height 400  -width 560  -bg white
    pack   .c

    option add *Scale.highlightThickness 0
    option add *Scale.orient vertical
    option add *Scale.relief ridge
    option add *Entry.relief sunken

    scale .c.sx1 -from 100 -to    0 -variable S(x1) -command Calc -label "x1"  
    scale .c.sx2 -from 100 -to    0 -variable S(x2) -command Calc -label "x2"  
    scale .c.sw1 -from  10 -to    0 -variable S(w1) -command Calc -label "w1"  
    scale .c.sw2 -from  10 -to    0 -variable S(w2) -command Calc -label "w2"  
    scale .c.st1 -from   0 -to 2000 -variable S(t1) -command Calc -label "Threshold" -orient horizontal 

    entry .c.es1 -width 5 -textvar S(s1)  -state readonly
    entry .c.es2 -width 5 -textvar S(s2)  -state readonly
   #entry .c.es3 -width 5 -textvar S(sum) -state readonly  ;##
    scale .c.ss3 -from 2000 -to   0 -variable S(sum) -length 200 -sliderlength 5 -state disabled -bg green2
    entry .c.es4 -width 3 -textvar S(out) -state readonly

    #.c create text   280  20          -text $S(title) -font {Times 24 bold}
    .c create text   280  20          -text $S(title) -font {Times 12 bold}

    .c create text    12  80          -text "Input 1"   -anchor w
    .c create line    30 100  310 100 -width 5 -arrow last
    .c create window  50  50          -window .c.sx1    -anchor nw
    .c create window  50 200          -window .c.sx2    -anchor nw
    .c create window 240  75          -window .c.es1    -anchor w

    .c create text    12 230          -text "Input 2"   -anchor w
    .c create line    30 250  310 250 -width 5 -arrow last
    .c create window 150  50          -window .c.sw1    -anchor nw
    .c create window 150 200          -window .c.sw2    -anchor nw
    .c create window 240 225          -window .c.es2    -anchor w

    .c create text   160 315          -text "Weight"    -anchor w

    .c create window 275 320          -window .c.st1    -anchor nw
    .c create line   350 320  350 300 -width 1 -arrow last

    .c create oval   300  50  400 300 -width 3 -fill green2
    .c create text   350  65          -text "Sum"
    .c create window 350 175          -window .c.ss3  ;## .c.es3 / .c.ss3
    .c create line   400 175  450 175 -width 5 -arrow last

    .c create oval   450 125  530 225 -width 3 -tag out
    .c create text   490 150          -text "Output"
    .c create window 490 175          -window .c.es4

    # Debug: show cursor-position :
   #bind .c <Motion>  {wm title . [int [%W canvasx %x]],[int [%W canvasy %y]]}
  }

  Init
  return
#-------------------------------------------------------------------------------

# Comments edit

# ?who?: while this is a nice little demo, I think a better demo would be to have
# the widgets be children of the canvas. The point is not illustrated with this
# demo, but if they aren't children of the canvas they won't be clipped by the
# canvas, and that will be noticible in certain contexts.

# HJG: On this wiki, nearly every program using the canvas puts all the controls
# and widgets outside it. Horoscope pie plotter was the only example I could
# find, where widgets are placed onto the canvas.

# ?who?: ... which is why it's best if examples on the wiki are as proper as
# possible. Otherwise, poor form is propagated. :-)

# Obviously, it is perfectly valid to have embedded widgets that are not
# children of the canvas, but sooner or later you'll be bit by the fact they
# aren't clipped by the canvas borders. Here's code that illustrates the point:

#-------------------------------------------------------------------------------

canvas .c -width 100 -height 100 -bd 0 -bg bisque  ;# ahh, bisque!
place  .c -relx .5 -rely .5 -anchor c
. configure -width 250 -height 250

button .c.b -text "Child of canvas"
button .b   -text "Child of \".\""

.c create window 10 25 -window .c.b -anchor c
.c create window 10 75 -window .b   -anchor c

#-------------------------------------------------------------------------------

# HJG: Every ".xxx" now changed to ".c.xxx". I'm not sure how much that will
# gain in practice - if users can resize an application-window, other problems
# might show up...

# uniquename 2014jan27

# For those who do not have the facilities or time to implement the code samples
# above, here is (1) an image of Gurt's 'Neuro1' widgets-on-canvas demo (with
# the widgets as children of the canvas) and (2) an image of the code above
# that shows how clipping of a widget can occur when the widget is a child of
# the canvas, thus assuring that the widget does not appear outside the bounds
# of the canvas.

# I plan to use a widgets-on-canvas technique like this --- in combination
# with a canvas-tiling technique seen on wiki page tiled image --- to make
# some nice Linux Tk GUI's --- about as nice as Tk GUI's on Apple and
# Microsoft OSes.

# Note that Gurt uses canvas 'create window' to place the widgets on the
# canvas. And he uses relief 'ridge' on the 'scale' widgets and relief
# 'sunken' on the 'entry' widgets, which seems to embed the scale and entry
# troughs into the canvas.

# (I also removed brackets from around 4 strings on this page which did not
#  resolve to a web page. This was causing my web browser --- and probably
#  web browsers of others --- to 'hang' in a continued-processing mode,
# apparently trying to resolve the links.)

# See also: box3d.tcl

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------

