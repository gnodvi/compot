# -*-   mode: tcl  ; coding: koi8   -*- ----------------------------------------

#!/bin/sh
# \
exec tclsh "$0" ${1+"$@"}

#-------------------------------------------------------------------------------
### /usr/bin/tclsh

# $Id: ffbp.tcl,v 1.6 2005/03/04 21:37:31 tang Exp $

#//#
# This program simulates a feed-forward back-propagation learning
# (ffbp) neural network.  Draw nodes by shift-clicking the canvas.
# Add connecting weights by shift-dragging from the start to
# destination node.  Double-click nodes or weights to change their
# properties.  To do batch simulations (i.e., the <strong>Run
# Trials</strong>) button requires the user to write custom code; see
# the three procedures at the bottom of this file.
#
# @author Jason Tang (tang@jtang.org)
#//#

#-------------------------------------------------------------------------------

set auto_path [linsert $auto_path 0 "COMPOT"]

package require compot::common 

#-------------------------------------------------------------------------------


# some default node colors
#

set bg(hidden)  white
set bg(input)  \#8888ff
set bg(output) \#ff8888
set bg(bias)   \#ffff88

#-------------------------------------------------------------------------------
# Adds the Tk/BWidget components to the screen.

proc make_ui {} {

  puts ""
  puts "make_ui ................ "
  puts ""

  global c

  if [winfo exists .sw] {
    destroy .sw
    destroy .sep
    destroy .bot
  }

  set sw [ScrolledWindow .sw -auto both]
  set c  [canvas [$sw getframe].c -bg white -scrollregion {0 0 800 600}]

  $sw setwidget $c
  pack .sw -expand 1 -fill both

  bind $c <Shift-ButtonPress-1>    [list add_thing %x %y]
  bind $c <Shift-B1-Motion>        [list move_thing %x %y]
  bind $c <Shift-ButtonRelease-1>  [list release_thing %x %y]

  $c bind node   <ButtonPress-1>   [list start_move_node %x %y]
  $c bind node   <B1-Motion>       [list move_thing %x %y]
  $c bind node   <ButtonRelease-1> [list release_thing %x %y]
  $c bind node   <Double-Button-1> [list modify_node %x %y]
  $c bind node   <Enter>           [list show_node_status]
  $c bind node   <Leave>           [list clear_status]
  $c bind weight <Double-Button-1> [list modify_weight %x %y]
  $c bind weight <Enter>           [list show_weight_status]
  $c bind weight <Leave>           [list clear_status]
  $c bind text   <Double-Button-1> [list modify_weight_text %x %y]
  $c bind text   <Enter>           [list show_weight_status_text]
  $c bind text   <Leave>           [list clear_status]

  pack  [Separator .sep] -expand 0 -fill x
  frame .bot
  frame .bot.cur

  label .bot.cur.status -textvariable ::status -width 32 -height 3 \
    -justify left -relief ridge

  set rb_s [radiobutton .bot.cur.sigmoid -text "Sigmoid" \
              -value sigmoid -variable ::algo]
  set rb_b [radiobutton .bot.cur.bipolar -text "Bi-Polar" \
              -value bipolar -variable ::algo]
  set le [LabelEntry .bot.cur.eta -textvariable ::eta -width 4 \
            -label "eta: "]
  set lnt [LabelEntry .bot.cur.num -textvariable ::num_iterations \
             -width 4 -label "Iterations: "]
  set cb_sw [checkbutton .bot.cur.showweights -text "Show Weights" \
               -variable ::show_weights -command render_texts]
  set lsw [LabelEntry .bot.cur.weightform -textvariable ::text_format \
             -width 5 -label "Format: " -command render_texts]

  grid .bot.cur.status -  - -sticky nsew -padx 4 -pady 8
  grid $rb_s $le $cb_sw -sticky w -padx 4
  grid $rb_b $lnt $lsw -sticky w -padx 4
  grid rowconfigure    .bot.cur 0 -weight 1
  grid columnconfigure .bot.cur 0 -weight 1
  grid columnconfigure .bot.cur 1 -weight 1
  grid columnconfigure .bot.cur 2 -weight 1

  frame .bot.cmd

  button .bot.cmd.sim    -text "Simulate Once" -command simulate
  button .bot.cmd.sl     -text "Sim & Learn"   -command sim_and_learn
  button .bot.cmd.trials -text "Run Trials"    -command run_trials
  button .bot.cmd.print  -text "Print Weights" -command print_weights
  button .bot.cmd.reset  -text "Reset Network" -command reset_network
  button .bot.cmd.new    -text "New Network"   -command new_network
  button .bot.cmd.save   -text "Save"          -command save
  button .bot.cmd.load   -text "Load"          -command load_cmd
  button .bot.cmd.quit   -text "Quit"          -command exit -bg red

  grid .bot.cmd.sim    .bot.cmd.print .bot.cmd.save -sticky ew
  grid .bot.cmd.sl     .bot.cmd.reset .bot.cmd.load -sticky ew
  grid .bot.cmd.trials .bot.cmd.new   .bot.cmd.quit -sticky ew
  grid .bot.cur        .bot.cmd -sticky nsew
  grid columnconfigure .bot 0 -weight 1
  grid columnconfigure .bot 1 -weight 0
  grid rowconfigure    .bot 0 -weight 1

  pack .bot -expand 1 -fill both -side bottom

  wm geometry . =600x450

  return
}
#-------------------------------------------------------------------------------
# Called when user begins a shift-click/shift-drag to add an item
# (either node or weight link) to the canvas.

proc add_thing {x y} {

  release_thing $x $y
  if {[set n [pick_node $x $y]] == -1} {
    # add a node
    set radius 15
    set x1 [expr {$x - $radius}]
    set x2 [expr {$x + $radius}]
    set y1 [expr {$y - $radius}]
    set y2 [expr {$y + $radius}]
    set tag [$::c create oval $x1 $y1 $x2 $y2 -fill {} -outline black \
               -width 4 -fill $::bg(hidden) -activeoutline cyan \
               -tags [list node]]
    set ::nodes($::next_node_id:in) {}
    set ::nodes($::next_node_id:out) {}
    set ::nodes($::next_node_id:name) "Node $::next_node_id"
    set ::nodes($::next_node_id:type) "hidden"
    set ::nodes($::next_node_id:value) 0.0
    set ::nodes($::next_node_id:target) 0.0
    set ::nodes($::next_node_id:tag) $tag
    set ::node_tags($tag) $::next_node_id
    lappend ::nodes(ids) $::next_node_id
    set ::active_tag $tag
    set ::active_type node
    incr ::next_node_id
  } else {
    # add a weight
    set tag [$::c create line $x $y $x $y -arrow last \
               -arrowshape {10 10 5} -fill black -width 2 \
               -activefill cyan -tags [list weight]]
    set ::start_node $n
    set ::end_node {}
    set ::active_tag $tag
    set ::active_type weight
  }
  $::c configure -cursor crosshair
  $::c itemconfigure $::active_tag -fill cyan
  set ::last_x $x
  set ::last_y $y
  move_thing $x $y
  update

  return
}
#-------------------------------------------------------------------------------
# Called when user begins to drag a node around.

proc start_move_node {x y} {

  if {$::active_tag != ""} {
    return
  }

  set ::active_tag [$::c find withtag current]
  set ::active_type node

  $::c configure -cursor hand1
  $::c itemconfigure $::active_tag -fill cyan

  set ::last_x $x
  set ::last_y $y

  return
}
#-------------------------------------------------------------------------------
# Called as user is moving something.  If it is a node then redraw all
# of weight links.  For nodes just move its end point to where the
# cursor lies.

proc move_thing {x y} {

  if {$::active_tag != ""} {
    if {$::active_type == "node"} {
      $::c move $::active_tag [expr {$x - $::last_x}] \
        [expr {$y - $::last_y}]
      render_network
    } else {
      if {$::end_node != {}} {
        $::c itemconfigure $::nodes($::end_node:tag) \
          -fill $::bg($::nodes($::end_node:type))
        set ::end_node {}
      }
      if {[set top [pick_node $x $y]] > -1 && $top != $::start_node} {
        set ::end_node $top
        $::c itemconfigure $::nodes($::end_node:tag) -fill green
      }
      set start_x [lindex [$::c coords $::active_tag] 0]
      set start_y [lindex [$::c coords $::active_tag] 1]
      $::c coords $::active_tag $start_x $start_y $x $y
    }
    set ::last_x $x
    set ::last_y $y
  }

  return
}
#-------------------------------------------------------------------------------
# Called when user releases mouse button.  For nodes their color is
# set based upon the node type.  For weights, checks that the mouse
# was releaseed over a non-source node.  If so then set the weight and
# add it to the array; if not then delete it.

proc release_thing {x y} {

  $::c configure -cursor {}
  if {$::active_tag != {}} {
    if {$::active_type == "node"} {
      $::c itemconfigure $::active_tag \
        -fill $::bg($::nodes($::node_tags($::active_tag):type))
    } else {
      if {$::end_node != {}} {
        global next_weight_id
        $::c itemconfigure $::nodes($::end_node:tag) \
          -fill $::bg($::nodes($::end_node:type))
        $::c itemconfigure $::active_tag -fill black
        set tag [$::c create text 0 0 -fill black -activefill cyan \
                   -tags [list text]]
        set ::text_tags($tag) $next_weight_id
        set ::weights($next_weight_id:start) $::start_node
        set ::weights($next_weight_id:end) $::end_node
        set ::weights($next_weight_id:init) 1.0
        set ::weights($next_weight_id:cur) 1.0
        set ::weights($next_weight_id:tag) $::active_tag
        set ::weights($next_weight_id:ttag) $tag
        set ::weights($next_weight_id:name) "Weight $next_weight_id"
        set ::weight_tags($::active_tag) $next_weight_id
        lappend ::weights(ids) $next_weight_id
        lappend ::nodes(${::start_node}:out) $next_weight_id
        lappend ::nodes(${::end_node}:in) $next_weight_id
        update_weight_text $next_weight_id
        incr next_weight_id
      } else {
        $::c delete $::active_tag
      }
    }

    set ::active_tag {}
    render_network
  }

  return
}
#-------------------------------------------------------------------------------
# Returns the topmost node id at location $x $y, or -1 if none exists.

proc pick_node {x y} {

  set node_tag -1

  foreach id [$::c find overlapping $x $y $x $y] {
    if {[lsearch -exact [$::c gettags $id] node] >= 0} {
      set node_tag $id
    }
  }

  if {$node_tag == -1} {
    return -1
  } else {
    # convert from a tag number to the id value
    return $::node_tags($node_tag)
  }

  return
}
#-------------------------------------------------------------------------------
# Reposition each of the weight arrows based upon where their anchor
# nodes are now located.

proc render_network {} {

  # for each weight line, set its coordinates to be along the node's
  # circle
  set radius 15.0

  foreach weight_id $::weights(ids) {

    set start $::nodes($::weights($weight_id:start):tag)
    set end   $::nodes($::weights($weight_id:end):tag)

    set ux [expr {[lindex [$::c coords $start] 0] + $radius}]
    set uy [expr {[lindex [$::c coords $start] 1] + $radius}]
    set vx [expr {[lindex [$::c coords $end] 0] + $radius}]
    set vy [expr {[lindex [$::c coords $end] 1] + $radius}]
    set dx [expr {$vx - $ux}]
    set dy [expr {$vy - $uy}]
    set theta [expr {atan2 ($dy, $dx)}]
    set ax [expr {$ux + $radius * cos ($theta)}]
    set ay [expr {$uy + $radius * sin ($theta)}]
    set bx [expr {$vx - $radius * cos ($theta)}]
    set by [expr {$vy - $radius * sin ($theta)}]

    $::c coords $::weights($weight_id:tag) $ax $ay $bx $by

    if {$dx < 0.0} {
      set x_offset 2
      set ew w
    } else {
      set x_offset -2
      set ew e
    }
        if {$dy < 0.0} {
          set y_offset 2
          set ns s
        } else {
          set y_offset -2
          set ns n
        }
        set tx [expr {($ux + $vx) / 2 + $x_offset}]

    set ty [expr {($uy + $vy) / 2 + $y_offset}]

    $::c coords        $::weights($weight_id:ttag) $tx $ty
    $::c itemconfigure $::weights($weight_id:ttag) -anchor ${ns}${ew}
  }

  return
}
#-------------------------------------------------------------------------------
# Redraws all weight texts.
#-------------------------------------------------------------------------------
proc render_texts {} {

  foreach weight_id $::weights(ids) {
    update_weight_text $weight_id
  }
    
  return
}
#-------------------------------------------------------------------------------
# Pop up a dialog to let the user change the properties of a node.
#-------------------------------------------------------------------------------
proc modify_node {x y} {

  destroy .node_dlg
  set node_id $::node_tags([$::c find withtag current])

  set ::tmp_name $::nodes($node_id:name)
  set ::tmp_type $::nodes($node_id:type)
  set ::tmp_value $::nodes($node_id:value)
  set ::tmp_target $::nodes($node_id:target)
  set d [Dialog .node_dlg -homogeneous 1 -padx 10 -title "Modify Node" \
           -separator 1 -modal local -cancel 1 -default 2 -parent .]
  set f [$d getframe]
  set ne [LabelEntry $f.ne -textvariable ::tmp_name -width 16 \
            -label "Node Name: "]

  pack $ne -expand 0 -fill x -anchor w

  set t0 [radiobutton $f.t1 -text "Input Node" -value "input" \
            -variable ::tmp_type]
  set t1 [radiobutton $f.t2 -text "Output Node" -value "output" \
            -variable ::tmp_type]
  set t2 [radiobutton $f.t0 -text "Hidden Node" -value "hidden" \
            -variable ::tmp_type]
  set t3 [radiobutton $f.t3 -text "Bias Node" -value "bias" \
            -variable ::tmp_type -command {set ::tmp_value 1.0}]
  pack $t0 $t1 $t2 $t3 -expand 0 -fill none -anchor w
  set ve [LabelEntry $f.ve -textvariable ::tmp_value -width 8 \
            -label "Value: "]
  pack $ve -expand 0 -fill none -anchor w
  set te [LabelEntry $f.te -textvariable ::tmp_target -width 8 \
            -label "Target Value: "]
  pack $te -expand 0 -fill none -anchor w

  $d add -text "Remove"
  $d add -text "Cancel"
  $d add -text "Ok"

  switch -- [$d draw] {
    0 {
      foreach weight_id $::nodes($node_id:in) {
        remove_weight $weight_id
      }
      foreach weight_id $::nodes($node_id:out) {
        remove_weight $weight_id
      }
      $::c delete $::nodes($node_id:tag)
      if {[set idx [lsearch -exact $::nodes(ids) $node_id]] == -1} {
        error "Could not find index"
      }
      set ::nodes(ids) [lreplace $::nodes(ids) $idx $idx]
      unset ::node_tags($::nodes($node_id:tag))
      array unset ::nodes $node_id:*
    }
    2 {
      set ::nodes($node_id:name) $::tmp_name
      set ::nodes($node_id:type) $::tmp_type
      set ::nodes($node_id:value) $::tmp_value
      set ::nodes($node_id:target) $::tmp_target
      $::c itemconfigure $::nodes($node_id:tag) -fill $::bg($::tmp_type)
    }
  }

  destroy .node_dlg

  return
}
#-------------------------------------------------------------------------------
proc modify_weight {x y} {

  modify_weight_helper $::weight_tags([$::c find withtag current])

}
#-------------------------------------------------------------------------------
proc modify_weight_text {x y} {

    modify_weight_helper $::text_tags([$::c find withtag current])

}
#-------------------------------------------------------------------------------
# Pop up a dialog to let the user change the properties of a weight.
#-------------------------------------------------------------------------------
proc modify_weight_helper {weight_id} {

  destroy .weight_dlg
  set ::tmp_name $::weights($weight_id:name)
  set ::tmp_init $::weights($weight_id:init)
  set ::tmp_cur $::weights($weight_id:cur)
  set d [Dialog .weight_dlg -homogeneous 1 -padx 10 -title "Modify Weight" \
           -separator 1 -modal local -cancel 1 -default 2 -parent .]
  set f [$d getframe]
  set ne [LabelEntry $f.ne -textvariable ::tmp_name -width 16 \
            -label "Weight Name: "]
  set ie [LabelEntry $f.ie -textvariable ::tmp_init -width 16 \
            -label "Initial Weight: "]
  set ce [LabelEntry $f.ce -textvariable ::tmp_cur -width 16 \
            -label "Current Weight: "]
  pack $ne -expand 0 -fill x -anchor w
  pack $ie $ce -expand 0 -fill none -anchor w
  $d add -text "Remove"
  $d add -text "Cancel"
  $d add -text "Ok"
  switch -- [$d draw] {
    0 {
      remove_weight $weight_id
    }
    2 {
      set ::weights($weight_id:name) $::tmp_name
      set ::weights($weight_id:init) $::tmp_init
      set ::weights($weight_id:cur) $::tmp_cur
      update_weight_text $weight_id
    }
  }

  destroy .weight_dlg

  return
}
#-------------------------------------------------------------------------------
# Removes a weight link.
#-------------------------------------------------------------------------------
proc remove_weight {weight_id} {

  set node_id $::weights($weight_id:start)
  if {[set idx [lsearch -exact $::nodes($node_id:out) $weight_id]] == -1} {
    error "Could not find index"
  }
  set ::nodes($node_id:out) [lreplace $::nodes($node_id:out) $idx $idx]    
  set node_id $::weights($weight_id:end)
  if {[set idx [lsearch -exact $::nodes($node_id:in) $weight_id]] == -1} {
    error "Could not find index"
  }
  set ::nodes($node_id:in) [lreplace $::nodes($node_id:in) $idx $idx]
  $::c delete $::weights($weight_id:tag)
  $::c delete $::weights($weight_id:ttag)
  if {[set idx [lsearch -exact $::weights(ids) $weight_id]] == -1} {
    error "Could not find index"
  }
  set ::weights(ids) [lreplace $::weights(ids) $idx $idx]
  unset ::weight_tags($::weights($weight_id:tag))
  unset ::text_tags($::weights($weight_id:ttag))
  array unset ::weights $weight_id:*

  return
}
#-------------------------------------------------------------------------------
# Show the properties of a node in the status bar whenever the mouse
# hovers over it.
#-------------------------------------------------------------------------------
proc show_node_status {} {

  set node_id $::node_tags([$::c find withtag current])
  set ::status "$::nodes($node_id:name) ($::nodes($node_id:type))\n"

  switch -- $::nodes($node_id:type) {
    "input" {
      append ::status "Input Value = $::nodes($node_id:value)"
    }
    "output" {
      append ::status "Current Value = $::nodes($node_id:value)\n"
      append ::status "Target Value= $::nodes($node_id:target)"
    }
    "hidden" {
      append ::status "Current Value = $::nodes($node_id:value)"
    }
    "bias" {
      append ::status "Bias Constant = $::nodes($node_id:value)"
    }
  }

  return
}
#-------------------------------------------------------------------------------
proc show_weight_status {} {

  show_weight_status_helper $::weight_tags([$::c find withtag current])

}
#-------------------------------------------------------------------------------
proc show_weight_status_text {} {

  show_weight_status_helper $::text_tags([$::c find withtag current])

}
#-------------------------------------------------------------------------------
# Show the properties of a weight whenever the mouse hovers over it.
#-------------------------------------------------------------------------------
proc show_weight_status_helper {weight_id} {

  set start $::nodes($::weights($weight_id:start):name)
  set end $::nodes($::weights($weight_id:end):name)

  set ::status "$::weights($weight_id:name) ($start --> $end)\n"

  append ::status "Initial Weight = $::weights($weight_id:init)\n"
  append ::status "Current = $::weights($weight_id:cur)"

  return
}
#-------------------------------------------------------------------------------
# Clear the status bar.
#-------------------------------------------------------------------------------
proc clear_status {} {

  set ::status ""

  return
}
################################################################################
#
# accessors and modifiers
#
#-------------------------------------------------------------------------------
proc get_node {name} {

  foreach node_id $::nodes(ids) {
    if {$::nodes($node_id:name) == $name} {
      return $node_id
    }
  }

  return -1
}
#-------------------------------------------------------------------------------
proc get_node_value {name} {

  if {[set node_id [get_node $name]] == -1} {
    error "Could not find node $name"
  } else {
    return $::nodes($node_id:value)
  }

}
#-------------------------------------------------------------------------------
proc get_weight {name} {

  foreach weight_id $::weights(ids) {
    if {$::weights($weight_id:name) == $name} {
      return $weight_id
    }
  }

  return -1
}
#-------------------------------------------------------------------------------
proc get_weight_cur {name} {

  if {[set weight_id [get_weight $name]] == -1} {
    error "Could not find weight $name"
  } else {
    return $::weights($weight_id:cur)
  }

  return
}
#-------------------------------------------------------------------------------
proc set_node_value {name value} {

  if {[set node_id [get_node $name]] == -1} {
    error "Could not find node $name"
  } else {
    set ::nodes($node_id:value) $value
  }

  return
}
#-------------------------------------------------------------------------------
proc set_node_target {name target} {

  if {[set node_id [get_node $name]] == -1} {
    error "Could not find node $name"
  } else {
    set ::nodes($node_id:target) $target
  }

  return
}
#-------------------------------------------------------------------------------
# Set the current value for a weight.
#-------------------------------------------------------------------------------
proc set_weight_cur {name value} {

  if {[set weight_id [get_weight $name]] == -1} {
    error "Could not find weight $name"
  } else {
    set ::weights($weight_id:cur) $value
    update_weight_text $weight_id
  }

  return
}
#-------------------------------------------------------------------------------
# Displays the current weight using the options given by the user.
#-------------------------------------------------------------------------------
proc update_weight_text {weight_id} {

  set tag $::weights($weight_id:ttag)

  if {$::show_weights == 1} {

    set value $::weights($weight_id:cur)
    if {$::text_format == ""} {
      $::c itemconfigure $tag -text $value
    } else {
      $::c itemconfigure $tag -text [format "%${::text_format}" $value]
    }
  } else {

    $::c itemconfigure $tag -text ""
  }

  return
}
#-------------------------------------------------------------------------------

################################################################################
#
# simulation and learning algorithms for ffbp networks
#
#-------------------------------------------------------------------------------

# squash x using the sigmoid function; also its first derivative
proc sigmoid {x} {
  expr {1.0 / (1.0 + exp(-1.0 * $x))}
}
proc sigmoid-deriv {O} {
  expr {$O * (1.0 - $O)}
}

# squash x using the bi-polar function; also its first derivative
proc bipolar {x} {
  expr {2.0 * [sigmoid $x] - 1.0}
}

proc bipolar-deriv {O} {
  expr {0.5 * (1.0 + $O) * (1.0 - $O)}
}

proc simulate {} {
  set todo {}
  foreach node_id $::nodes(ids) {
    if {$::nodes($node_id:type) == "input" ||
        $::nodes($node_id:type) == "bias"} {
      lappend todo $node_id
    }
  }
  while {[llength $todo] > 0} {
    set next [lindex $todo 0]
    set todo [lrange $todo 1 end]
    set dependencies_ok 1
    if {$::nodes($next:type) == "hidden" ||
        $::nodes($next:type) == "output"} {
      # this node's value is the sum of its children, then
      # squashed
      set x 0.0
      foreach in_weight $::nodes($next:in) {
        # check that all of this node's dependencies are complete
        set in_node $::weights($in_weight:start)
        if {[lsearch $todo $in_node] > 0} {
          lappend todo $next
          set dependencies_ok 0
          break
        }
        set value $::nodes($in_node:value)
        set x [expr {$x + $value * $::weights($in_weight:cur)}]
      }
      if {$dependencies_ok == 1} {
        set ::nodes($next:value) [$::algo $x]
      }
    }
    if {$dependencies_ok == 1} {
      foreach out_weight $::nodes($next:out) {
        set out $::weights($out_weight:end)
        if {[lsearch $todo $out] == -1} {
          lappend todo $out
        }
      }
    }
  }
  set ::status "Node values updated."
  foreach node_id $::nodes(ids) {
    if {$::nodes($node_id:type) == "output"} {
      append ::status "\n$::nodes($node_id:name) = $::nodes($node_id:value)"
    }
  }
}

proc sim_and_learn {} {
  simulate
  update
  foreach weight_id $::weights(ids) {
    set ::deltas($weight_id) 0.0
  }
  set error [learn]
  foreach weight_id $::weights(ids) {
    set ::weights($weight_id:cur) \
      [expr {$::weights($weight_id:cur) + $::deltas($weight_id)}]
    update_weight_text $weight_id
  }
  set ::status "Weights updated.\n"
  append ::status "total error = $error\n"
}

#-------------------------------------------------------------------------------
proc run_trials {{is_gui 1}} {

  if $is_gui {
    foreach w [get_init_weights] {
      set_weight_cur [lindex $w 0] [lindex $w 1]
    }
  }


  for {set iteration 1} {$iteration <= $::num_iterations} {incr iteration} {

    set total_error 0.0

    foreach weight_id $::weights(ids) {
      set total_deltas($weight_id) 0.0
    }

    array unset ::deltas


    foreach datum [get_test_set] {

      foreach w [lindex $datum 0] {
        set_node_value [lindex $w 0] [lindex $w 1]
      }
      foreach t [lindex $datum 1] {
        set_node_target [lindex $t 0] [lindex $t 1]
      }
      simulate

      set error [learn]
      set total_error [expr {$total_error + $error}]

      foreach weight_id $::weights(ids) {
        set total_deltas($weight_id) \
          [expr {$total_deltas($weight_id) + $::deltas($weight_id)}]
      }
    }


    foreach weight_id $::weights(ids) {
      set ::weights($weight_id:cur) \
        [expr {$::weights($weight_id:cur) + $total_deltas($weight_id)}]

      if $is_gui {update_weight_text $weight_id}
    }


    set total_error [expr {$total_error / 2.0}]

    report $iteration $total_error

    set ::status "Iteration $iteration\ntotal_error = $total_error"

    update
  }


  return
}
#-------------------------------------------------------------------------------
# calculate weight deltas using steepest descent heuristic; return the
# sum of errors for each of the output nodes
#-------------------------------------------------------------------------------
proc learn {} {

  set todo {}

  foreach node_id $::nodes(ids) {
    if {$::nodes($node_id:type) == "output"} {
      lappend todo $node_id
    }
  }

  set todo [lsort -unique $todo]
  set error 0.0

  while {[llength $todo] > 0} {
    set next [lindex $todo 0]
    set todo [lrange $todo 1 end]
    set O $::nodes($next:value)
    if {$::nodes($next:type) == "output" ||
        $::nodes($next:type) == "hidden"} {
      if {$::nodes($next:type) == "output"} {
        set d [expr {$::nodes($next:target) - $O}]
        set this_error [expr {pow ($::nodes($next:target) - $O, 2)}]
        set error [expr {$error + $this_error}]
        set dependencies_ok 1
      } else {
        # check that all of this node's parents are done
        foreach parent_weight $::nodes($next:out) {
          if {[lsearch $todo $::weights($parent_weight:end)] > 0} {
            lappend todo $next
            set dependencies_ok 0
            break
          }
        }
        set dependencies_ok 1
        set d 0.0
        foreach out_weight $::nodes($next:out) {
          set d \
            [expr {$d + $delta($out_weight) * $::weights($out_weight:cur)}]
        }
      }
      if {$dependencies_ok} {
        set d [expr {$d * [${::algo}-deriv $O]}]
        foreach in_weight $::nodes($next:in) {
          set I $::nodes($::weights($in_weight:start):value)
          set ::deltas($in_weight) [expr {$::eta * $d * $I}]
          set delta($in_weight) $d
          lappend todo $::weights($in_weight:start)
        }
      }
    }
  }

  return $error
}
################################################################################
#
# utility functions
#
#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
proc new_network {} {

  if [info exists ::c] {
    $::c delete all
  }

  array unset ::nodes
  array unset ::weights
  array unset ::node_tags
  array unset ::weight_tags
  array unset ::text_tags

  set ::nodes(ids) {}
  set ::weights(ids) {}
  set ::next_node_id 0
  set ::next_weight_id 0
  set ::algo "sigmoid"
  set ::eta 1.0
  set ::num_iterations 1
  set ::show_weights 1
  set ::text_format "0.04f"
  set ::status ""

  return
}
#-------------------------------------------------------------------------------
# Print all current weights to stdout.
#-------------------------------------------------------------------------------
proc print_weights {} {

  foreach weight_id $::weights(ids) {

    set start $::nodes($::weights($weight_id:start):name)
    set end $::nodes($::weights($weight_id:end):name)

    puts "$start --> $end\t $::weights($weight_id:cur)"
  }

}
#-------------------------------------------------------------------------------
# Reset all nodes and weights to their initial values.  Hidden and
# output nodes are set to their "value" field"; weights to their
# "init" field.
#-------------------------------------------------------------------------------
proc reset_network {} {

  foreach node_id $::nodes(ids) {
    if {$::nodes($node_id:type) == "hidden" ||
        $::nodes($node_id:type) == "output"} {
      set ::nodes($node_id:value) 0.0
    }
  }
  foreach weight_id $::weights(ids) {
    set ::weights($weight_id:cur) $::weights($weight_id:init)
    update_weight_text $weight_id
  }

  set ::status "Weight values have been reset."

}
#-------------------------------------------------------------------------------
proc save {} {

  set filename [tk_getSaveFile -initialfile $::filename -parent . \
                  -title "Save Neural Network"]
  if {$filename != ""} {
    if [catch {open $filename w} dest] {
      MessageDialog -parent . -icon error -type ok \
        -title "Save Neural Network" \
        -message "Error writing to $filename"
    } else {

      puts $dest [array get ::nodes]
      puts $dest [array get ::weights]
      puts $dest $::next_node_id
      puts $dest $::next_weight_id
      puts $dest $::algo
      puts $dest $::eta
      puts $dest $::num_iterations
      puts $dest $::show_weights
      puts $dest $::text_format

      foreach node_id $::nodes(ids) {
        puts $dest [$::c coords $::nodes($node_id:tag)]
      }
      close $dest
      set ::filename $filename
    }
  }

  return
}
#-------------------------------------------------------------------------------
proc read_net_from_file {fd {is_gui 1}} {

  if $is_gui {$::c delete all}
  
  new_network
  
  array set ::nodes   [gets $fd]
  array set ::weights [gets $fd]
  
  gets $fd ::next_node_id
  gets $fd ::next_weight_id
  gets $fd ::algo
  gets $fd ::eta
  gets $fd ::num_iterations
  gets $fd ::show_weights
  gets $fd ::text_format
  
  foreach node_id $::nodes(ids) {

    gets $fd coords

    if $is_gui {
      set tag [$::c create oval $coords -fill {} -outline black \
                 -width 4 -fill $::bg($::nodes($node_id:type)) \
                 -activeoutline cyan -tags [list node]]
    } else {
      set tag [MAKE_GLOBAL_NAME]
    }
    
    set ::nodes($node_id:tag) $tag
    set ::node_tags($tag)     $node_id
  }
  
  foreach weight_id $::weights(ids) {

    if $is_gui {
      set tag [$::c create line 0 0 0 0 -arrow last \
                 -arrowshape {10 10 5} -fill black -width 2 \
                 -activefill cyan -tags [list weight]]
    } else {
      set tag [MAKE_GLOBAL_NAME]
    }

    set ::weights($weight_id:tag) $tag   
    set ::weight_tags($tag)       $weight_id
    
    if $is_gui {
      set tag [$::c create text 0 0 -fill black -activefill cyan \
                 -tags [list text]]
    } else {
      set tag [MAKE_GLOBAL_NAME]
    }
    
    set ::weights($weight_id:ttag) $tag
    set ::text_tags($tag)          $weight_id
    
    if $is_gui {
      update_weight_text $weight_id
    }
  }
  
  close $fd
  
  return
}
#-------------------------------------------------------------------------------
proc load_cmd {} {

  set filename [tk_getOpenFile -initialfile $::filename -parent . \
                  -title "Load Neural Network"]

  if {$filename != ""} {

    if [catch {open $filename r} fd] {

      MessageDialog -parent . -icon error -type ok \
        -title "Load Neural Network" \
        -message "Error loading from $filename"

    } else {

      read_net_from_file $fd

      set ::filename $filename

      render_network ;# графическая
    }
  }

  return
}
################################################################################
# 
# callbacks by the "run trials" button
# 
#-------------------------------------------------------------------------------

### These are sample code to solve the XOR problem. ###

#-------------------------------------------------------------------------------
# Return a list of initial weights for, applied once at the beginning
# of the trials.
#-------------------------------------------------------------------------------
proc get_init_weights {} {

  return {
    {a_11 1.0} {a_12 1.0} {a_21 -1.0} {a_22 -1.0} {a_31 1.0} {a_32 1.0}
    {b_1 1.0} {b_2 -1.0} {b_3 1.0}
  }

}
#-------------------------------------------------------------------------------
# Each list represents a test set.  The first element is a list of
# 2-ples giving values for input nodes.  The second element is a list
# of 2-ples giving target values for output nodes.
#-------------------------------------------------------------------------------
proc get_test_set {} {

  return {
    {{{x1 -1.0} {x2 -1.0}} {{out -1.0}}}
    {{{x1 -1.0} {x2 1.0}} {{out 1.0}}}
    {{{x1 1.0} {x2 -1.0}} {{out 1.0}}}
    {{{x1 1.0} {x2 1.0}} {{out -1.0}}}
  }

}
#-------------------------------------------------------------------------------
# This function is called each time all patterns from a single
# iteration are complete.  It is the user's job to decide how he wants
# to format the information.
#-------------------------------------------------------------------------------
proc report {iteration_num total_error} {

  puts "Iteration $iteration_num, error = $total_error"

}
################################################################################
#-------------------------------------------------------------------------------
proc gui_init {} {

  
  package require Tk
  
  option add *font "Helvetica 10"
  
  catch {source console.tcl}
  catch {console show}
   
  # Написанный на чистом TCl/Tk набор мегавиджетов, дополняющих функционал Tk.
  # На данный момент распространяется как чать Tcllib (??).
  # 
  lappend ::auto_path "./L" ;# тоже отлично работает
  
  package require BWidget
  
}
#-------------------------------------------------------------------------------
proc main_gui {} {

  #---------------------------
  gui_init
  #---------------------------

  new_network

  make_ui


  set ::active_tag {}
  
  set ::filename "l_ffbp.nt"  ;# "n-ffbp.net"

  return
}
#-------------------------------------------------------------------------------
proc load_from_file {filename} {

  if [catch {open $::filename r} ret] {

    puts "ERROR: $ret"
    exit
  } 
  
  set ::filename $filename

  read_net_from_file  $ret 0
    
  return
}
#-------------------------------------------------------------------------------
proc main_cli {} {

  new_network

  #make_ui


  set ::active_tag {}
  
  load_from_file "l_ffbp.nt" 

  run_trials 0


  return
}
#-------------------------------------------------------------------------------
proc Quit {} {


  exit
}
#-------------------------------------------------------------------------------
proc main_gui_unvisible {} {

  main_gui

  #---------------------------
  if {0} {

    wm iconify   . ;# заменим пиктограммой 
    #wm withdraw  . ;# отменим изображение, не заменяя пиктограммой
    #wm deiconify . ;# восстановим нормальный вид
    
    wm iconname  . "ICONNAME" ;# ??
    
    #image create photo img_icon -file "../../doc/img/4.png"
    image create photo img_icon -file "L/4.png"
    wm iconphoto .     img_icon
    
    wm protocol . WM_DELETE_WINDOW Quit ;# епрехватываем закрытие окна
    
  }
  #---------------------------

  load_from_file "l_ffbp.nt" 

  #sleep 500
  #wait_press_enter
  #flush stdout  ;# ... ...... ...... .... ........
  #set answer [gets stdin]
  #exit

  #tkwait variable gprollSaveScriptFileName

  #render_network ;# графическая

  #run_trials 1

  return
}
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------

set ::filename "l_ffbp.nt"  ;# "n-ffbp.net"

#main_cli ;# TODO

#main_gui_unvisible

main_gui

################################################################################

# tclsh l_ffbp.tl

################################################################################
