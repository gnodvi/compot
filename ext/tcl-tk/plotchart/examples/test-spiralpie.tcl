#! /bin/sh
# -*- tcl -*- \
exec wish "$0" ${1+"$@"}

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------

# test-spiralpie.tcl --
#
# Options:
# -shownumbers
# -sorted
#

#-------------------------------------------------------------------------------

# source plotchart.tcl
# package require Plotchart

source "../lib/plotchart.tcl" ;# загружает остальное 

#-------------------------------------------------------------------------------

pack [canvas .c1 -width 300 -height 300] \
     [canvas .c2 -width 300 -height 300]

::Plotchart::plotstyle configure default spiralpie labels sorted      1 \
                                         spiralpie labels shownumbers 1 \
                                         spiralpie labels formatright "(%g) %s" \
                                         piechart  labels sorted      1 \
                                         piechart  labels shownumbers 1


set p1 [::Plotchart::createSpiralPie .c1]
set p2 [::Plotchart::createPiechart  .c2]

$p1 plot {Red 10 Green 3 Blue 5 Yellow 15}
$p2 plot {Red 10 Green 3 Blue 5 Yellow 15}

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
