# -*-   mode: tcl  coding: koi8   -*- ------------------------------------------

#!/bin/sh
# \
exec tclsh "$0" ${1+"$@"}

#-------------------------------------------------------------------------------
# https://wiki.tcl-lang.org/page/
# Texas+Hold+Dem+Poker+Cards%2C+Game%2C+and+Probability%2C+numerical+analyis

# Texas Hold Dem Poker Cards, Game, and Probability, numerical analyis

#-------------------------------------------------------------------------------

# This page is under development. Comments are welcome, but please load any 
# comments in the comments section at the bottom of the page. Please include your
#  wiki MONIKER and date in your comment with the same courtesy that I will give 
# you. Its very hard to reply reasonably without some background of the 
# correspondent on their Wiki bio page. Thanks,gold

#         Preface
#         Introduction
#         Texas Holdem Poker into TCL.
#         Testcases are important in development of TCL programs.
#         Screenshots Section
#             figure 1. Calculator Screenshot
#             figure 2. Console Screenshot , shows list of cards
#         Table 1: Betting Gist
#         Table 2: Probabilities in Texas Holdem
#         Table 3: Probabilities in 5 Card Poker
#         References:
#         Pseudocode & Equations Section
#     Appendix Code
#         Trial Shell 
#     Comments Section

# Preface

# gold Here are some calculations for poker probability using TCL expressions in 
# the Windows console with the easy eye line calculator. The impetus for these 
# calculations was checking some poker probabilities, mostly on Texas Holdem Poker, 
# but also 5 Card Poker. Its easy enough to cut and paste TCL based formulas into 
# the easy eye calculator console. Most of the checked testcases involve TCLLIB 
# math functions.

# Introduction
# Texas Holdem Poker into TCL.

# The baby game engine in Mahjong Deletion can be converted or hacked into a set 
# of 52 poker cards. In Texas Holdem Poker, there are four stages of deals and 
# four stages of betting until the final round. All suits are equal and no suit 
# is worth more than another. No Joker cards are used. The winner has the best 
# five-card hand possible using the player\u2019s two cards as pocket cards and 
# the five dealt in the middle of the table. The odds change with each deal, so 
# betting is tricky for the players or exciting for the spectators. On most deals, 
# players have betting options for check, call, raise, or fold. The end of game or 
# last betting session is sometimes called a showdown. Usually a chip marked dealer 
# is passed or shared among the players for the responsibility of dealing the cards. 
# Two antes or blinds are placed for the responsibility of different players as 
# the places of the binds are relative to the selected dealer for the hand. The 
# "Big Blind" is placed on the right of the dealer and the "Small Blind" is placed 
# on the left of the dealer. For only two players or small player games, some of 
# the "Big Blind" and "Small Blind" rules are omitted or handled differently. On 
# the canvas widget of TCL, the four stages of deals can be raised or lowered 
# into spectator view from the underscreen with buttons and keyed canvas tags. 
# In the internal TCL code, each card can be dealt from a fresh deck of electrons. 
# Initially and unlike the Las Vegas tables, a dealt card will not be removed from 
# the 52 total deck.

# Testcases are important in development of TCL programs.

# In planning any software, it is advisable to gather a number of testcases to 
# check the results of the program. The math for the testcases can be checked by 
# pasting statements with added brackets in the TCL console. Also, some of the 
# pseudocode statements were checked in the google search engine which will take 
# math expressions. Ref factorial procedure in original routines was posted by 
# Suchenwirth RS, but the factorial and derived choose functions are included in 
# the TCLLIB math library.

#-------------------------------------------------------------------------------

# Screenshots Section
# figure 1. Calculator Screenshot

# Texas Hold Dem Poker Cards screenshoot png second
# figure 2. Console Screenshot , shows list of cards

# Texas Hold Dem Poker Cards png screenshot first

#-------------------------------------------------------------------------------

# Table 1: Betting Gist

# table. Four 
# styles of Texas 
# Holdem odds 
#                 | dealt 
#                   cards in 
#                   a hand    | Bet 
#                               numbers | player options     | comment if any

# preflop odds 	      2         bet1      After pocket, call, 
#                                         raise, or fold      first 2 called 
#                                                             pocket 
#                                                             or hole card

# flop odds 	      3 	bet2 	  After flop, check, raise, or fold	

# turn odds 	      1 	bet3 	  After turn, check, raise, or fold	

# river odds          1 	bet4 	  After river, check, raise, or fold	
# 		             >> gist <<< 		

# totals 	    7 cards 	4 bets 	  12 possible actions, expected in 
#                                         typical game	

#-------------------------------------------------------------------------------

# Table 2: Probabilities in Texas Holdem

# quantity 	        P_probability, 
#                          S_space etc  100X, 
#                                       alternate 
#                                       percent, if 
#                                       applicable   formula TCL         comments 
#                                                                           if any

# texas_pocket_pair_space 	1326 		     expr { math::choose 
#                                                                 52 2 } 	

# texas_pocket_pair 	  0.004524886 	0.4524886    expr { (1.*math::choose 4 
#                                                    2 )/ math::choose 
#                                                    52 2 }             odds 220:1

# any_texas_pocket_pair 	0.0588 	    5.88     expr { 78/1326 } 	odds 16:1

# specific_texas_suited combination 4 		     expr { math::choose 4 1 } 	

# specific_texas_suited_hand 	0.003 	     0.3     expr { 4/1326 } 	odds 331:1

# any_texas_suited combination 	  312 		     expr { 4*78 } 	

# any_texas_suited_hand        0.2352      23.52     expr { 312/1326 } 	odds 3.25:1

#-------------------------------------------------------------------------------

# Table 3: Probabilities in 5 Card Poker

# Picking up a five card hand, what is the probability and odds of a straight 
# flush, less royal flush ? The sample space is 52!/((5!* (52-5)!) or 2598960. 
# The frequency is (10 choose 1)*(4 choose 1) -(4 choose 1) , 10!/((1!* (10-1)!) 
# * 4!/((1!* (4-1)!) - 4!/((1!* (4-1)!) , 40-4,or 36. The text books use the
#  expression <4 choose 1>, but the TCLLIB math library is invoked by the 
# expression <math::choose 4 1>.

# set straight_flush  [expr { (1.*36)/ 2598960    } ]
# set straight_flush_odds  [expr { 1./( (1.*36)/ 2598960 )   } ]
# answer%  1.39E-5 ,  72192.0

#-------------------------------------------------------------------------------

# Probabilities in 5 Card Poker 
					
# hand 	         choose formula           frequency  division 
#                                                       terms probability  odds


# royal flush 	 (4 choose 1) 	              4      4/258960  1.54E-5    64739

# straight flush 
# less royal 
#          flush (10 choose 1)* (4 choose 
#                        1) -(4 choose 1)    36      36/258960  1.39E-5    72192

# four of kind 	(13 choose 1)* (12 choose 
#                        1) *(4 choose 1)   624      624/258960  2.4E-4	    4164

# full house	(13 choose 1)* (4 choose 
#                       3) *(12 choose 2)   858      858/258960  2.11E-2    46.3

# three of kind (13 choose 1)* (4 choose 
#        3) *(12 choose 2)* (4 choose 2)    156      156/258960  1.44E-3     693

#-------------------------------------------------------------------------------

# References:

#     google < Texas Poker Wikipedia >
#     Wikipedia search engine < Texas Poker algorithm >
#     Wikipedia search engine < multiplication algorithm >
#     Wikipedia search engine < Texas Poker Math >
#     Wikipedia search engine < Texas Poker lograrithms >
#     Wikipedia search engine <Texas Poker >
#     Wolfram Alpha search engine < Texas Poker >
#     Mahjong_Style_Deletion
#     Poker Probability and Calculator Demo Example
#     precision math procedure used in TCL calculator Arjen Markus AM
#     Computers and real numbers
#     Floating-point formatting
#     Texas Hold \u2019em poker solved by computer Science, AAAS.
#     Sklansky, David (2005). The Theory of Poker (Fourth ed.). Las Vegas: Two plus two.
#     Harrington, Dan and Bill Robertie (2004). Harrington on Hold'em:
#     Expert Strategy For No-Limit T ournaments; Volume I: Strategic Play. Two Plus Two Publications.
#     D. Purdy, The Illustrated Guide to Texas Hold\u2019em, Sourcebooks, Inc., 2005.
#     pokerproj
#     Wikipedia, Poker_probability.pdf
#     Wikipedia, Texas_hold_'em.pdf
#     Poker probability (Texas hold 'em)
#     Estimating Winning Probability for Texas Hold'em Poker,
#     Wenkai Li and Lin Shang
#     Probabilities in Texas Hold'em,
#     The mathematics of Texas Hold'em Poker Probability-based analyses on concrete hands.
#     Alspach's Mathematics and Poker Page
#     Probabilities in Texas Hold'em, Brian Alspach, 22 August 2001
#     Probabilities in Texas Hold'em
#     Hold'Em Solitaire , on wiki, Keith Vetter 2005-10-26 

# Pseudocode & Equations Section

#         more than one formula for 1) tables and 2) calculator shell
   

# Appendix Code
# Trial Shell

#-------------------------------------------------------------------------------

######))))))  TCL source code follows
# pretty print from autoindent and ased editor
# program Texas Hold Dem Cards.
# adapted from Mahjong_Style_Deletion
# written on Windows XP for TCL
# working under TCL version 8.6
# The original base M. was adapted
# from aricb on the Ask page.
# Probably could start a post,
# since it is a good baby game
# engine. Wish to study dealt values and
# probability of Texas Hold Dem Cards.
# Need to evaluate hands and bet on them.
# I added a few buttons at the bottom
# and tried to keep the clean code separate up top.
# Richard Suchenwirth RS wrote lpick routine below.
# de on  TCL Club, 15nov2018

package require Tk

set auto_path [linsert $auto_path 0 "EXT/tcl-tk/tcllib"]
#
# ????
package require math
namespace path {::tcl::mathop ::tcl::mathfunc }

global deck suit
global selectedid selectedtext
global new_card_state

set new_card_state 0
set deck {}
set suitfrenchblack { \u2665 \u2666 \u2663 \u2660 }
set suitfrenchblanc { \u2664 \u2661 \u2662 \u2667 }
# utilities
# suchenwirth_subroutine RS

proc lpick L {lindex $L [expr {int(rand()*[llength $L])} ];}
proc plainsub {text item replacewith} {
  set text [string map [list $item $replacewith] $text]
}

proc deal {args} {
            global deck suit
            foreach suit { \u2665 \u2666 \u2663 \u2660  } {
                foreach item $args {
                    set kay "$item $suit "
                    set value 1
                    if {$item == "J"} {set value 10}
                    if {$item == "Q"} {set value 10}
                    if {$item == "K"} {set value 10}
                    if {$item == "A"} {set value 10}
                    set kay "[append item $suit \ $value ]"
                    lappend deck $kay
                }}
            return  $deck
        }
        deal 2 3 4 5 6 7 8 9 10 A J Q K
        puts "$deck new_card state equals $new_card_state"
        proc self_help {} {
            set msg "Texas Hold Dem Cards V2
            from TCL ,
            # self help listing
            # >>>>  Copyright Notice  <<<<<
            # This posting, screenshots, and TCL source code is
            # copyrighted under the TCL/TK 8.6 license terms.
            # Editorial rights retained under
            # the TCL/TK license terms
            # and will be defended as necessary in court.
            # >>>>   Push Button Operation <<<<
            # Push left mouse to activate buttons.
            # Deal shuffles all hands.
            # Move_right_mouse_for_one_card deal.
            # All cards listed with value.
            # Deck is 52 cards, no jokers.
            # Report allows copy and paste
            # from console to conventional
            # texteditor. For testcases,
            # the testcase number is internal
            # to the calculator and
            # will not be printed until
            # the report button is pushed
            # for the current result numbers.
            # Where the program defaults are recalled,
            # canvas colors/features/variables/globals/calculations/clear displays
            # may reset prior to calculation
            # ( in push button list) .
            # Buttons on the calculator are not
            # limited to a single action procedure
            # or single shot. A button command may
            # call multiple statements and procs,
            # effectively a separate program or
            # subprogram installed as
            # a list of procedures in a button.
            # Alternately, the list of procedures
            # need not be installed in a button,
            # but in a separate procedure.
            Conventional text editor formulas
            or  grabbed from internet
            screens can be pasted into green console.
            Try copy and paste following
            into green screen console
            set answer [* 1. 2. 3. 4. 5. ]
            returns  120
            # gold on  TCL Club, 15nov2018 "
            tk_messageBox -title "self_help" -message $msg }
        proc populateCanvas {canvas cols rows} {
            variable ids ;# links text ids with respective rect ids
            variable boxes ;# lists text id and text associated with each rect id
            global deck suitfrenchblack suitfrenchblanc
            catch {unset ids boxes}
            # parameters for drawing boxes
            set boxwidth 50
            set boxheight 20
            set padx 10
            set pady 10
            set colors {red orange yellow green blue purple}
            set money_color { red  }
            set labels {one two three four}
            # draw the boxes
            for {set row 0} {$row < $rows} {incr row} {
                for {set col 0} {$col < $cols} {incr col} {
                    # calculate coordinates
                    set x1 [expr {$col * ($boxwidth + $padx) + $padx}]
                    set x2 [expr {$x1 + $boxwidth}]
                    set x3 [expr {$x1 + ($boxwidth / 2)}]
                    set y1 [expr {$row * ($boxheight + $pady) + $pady}]
                    set y2 [expr {$y1 + $boxheight}]
                    set y3 [expr {$y1 + ($boxheight / 2)}]
                    # choose color and text
                    set color [lindex $colors [expr {int(rand() * [llength $colors])}]]
                    #set text [lindex $labels [expr {int(rand() * [llength $labels])}]]
                    set text [lindex $deck [expr {int(rand() * [llength $deck])}]]
                    # create the boxes
                    set boxid [$canvas create rectangle $x1 $y1 $x2 $y2 -fill $color -outline black]
                    set textid [$canvas create text $x3 $y3 -text $text]
                    # remember which text item goes with which box and what the text says
                    set boxes($boxid) [list $textid $text]
                    set ids($textid) $boxid
                    set ids($boxid) $boxid
                }
            }
        }
        proc clearSelection {canvas} {
            # if there is an existing currently selected box, change its border back to
            # black; set variables selectedid and selectedtext to empty strings
            variable selectedid
            variable selectedtext
            if {$selectedid ne "" && [$canvas find withtag $selectedid] ne ""} {
                $canvas itemconfigure $selectedid -outline black
            }
            set selectedid ""
            set selectedtext ""
        }
        proc handleSelection {canvas id} {
            # determine the "next step" by comparing the newly selected box id and text
            # to the box id and text of the previously selected box (contained in
            # the variables $selectedid and $selectedtext)
            variable ids
            variable boxes
            variable selectedid
            variable selectedtext
            set boxid $ids($id)
            lassign $boxes($boxid) textid text
            if {$boxid eq $selectedid} {
                # user has selected the same box twice; deselect the box
                clearSelection $canvas
                return
            } elseif {$text eq $selectedtext} {
                # user has selected two boxes with the same text; delete both boxes
                $canvas delete $boxid $textid $selectedid [lindex $boxes($selectedid) 0]
                clearSelection $canvas
                return
            } else {
                # user has selected a box when there is no selection, or user has
                # selected a box with different text than the previously selected box;
                # try to deselect the previous box, then select the new box
                clearSelection $canvas
                set selectedid $boxid
                set selectedtext $text
                $canvas itemconfigure $boxid -outline white
                return
            }
        }
        proc processClick {canvas x y} {
            # determine whether the user has
            # clicked on something; if so, call
            # proc handleSelection
            set id [$canvas find overlapping $x $y $x $y]
            if {[llength $id] > 0} {
                handleSelection $canvas [lindex $id 0]
            }
        }
        set win [toplevel .demo]
        wm title $win "Texas Hold Dem Cards"
        set canvas [canvas $win.canvas]
        pack $canvas  -expand 1 -fill both
        bind $canvas <Button-1> [list processClick %W %x %y]
        set state 1
        proc deal2 {} {
            global selectedid selectedtext
            global coloritem canvas details
            set coloritem gray
            # mahjongstyle { $state }
            populateCanvas $canvas 7 5
            set selectedid ""
            set selectedtext ""
        }
        proc uncover {} {
            global coloritem canvas details
            global deal1 deal2 deal3 deal4 deal5 deal6 deal7
            set state2 1
            #$canvas create rectangle 10 10 500 300 -fill blue -outline red -tag deal1
            if { $state2 == 5 } { $canvas raise deal1 ;}
            if { $state2 == 1 } { $canvas lower deal1 ;}
        }
        proc flip_new_card {} {
            global deck suit canvas  x y
            global selectedid selectedtext
            global new_card_state
            # determine whether the user has clicked on something;
            # if so, flip to random new card
            # set id [$canvas find overlapping $x $y $x $y]
            set id ""
            if {[llength $id] > 0} {
                configure $id -text "switch"
            }
        }
        proc mahjongstyle { state } {
            global coloritem canvas details
            set coloritem gray
            set details {
                # program Texas Hold Dem Cards.
                # adapted from Mahjong_Style_Deletion
                # written on Windows XP for TCL
                # working under TCL version 8.6
                # The original base M. was adapted
                # from aricb on the Ask page.
                # Probably could start a post,
                # since it is a good baby game
                # engine. Wish to study value and
                # probability of Texas Hold Dem cards.
                # Need to evaluate hands and bet on them.
                # I added a few buttons at the bottom
                # and tried to keep the clean code separate up top.
                Mahjong-style deletion.
                press in succession two tiles with the same text.
                both tiles should be deleted.
                The Mahjong-style deletion is for
                the right mouse press.}
            $canvas create window 100 200 -window [button $canvas.a -width 10 -text deal \
                    -bg $coloritem    -command {deal2;}]
            $canvas create window 100 250 -window [button $canvas.b -width 10 -text swap_card \
                    -bg $coloritem    -command {swap_new_cards 2 ;}]
            $canvas create window 200 200 -window [button $canvas.c -width 10 -text about \
                    -bg $coloritem    -command {tk_messageBox -message $details}]
            $canvas create window 200 250 -window [button $canvas.d -width 10 -height 1 -text report \
                    -bg $coloritem     -command {puts "new_card_state equals $new_card_state"; console show }]
            $canvas create window 300 200 -window [button $canvas.e -width 10 -text self_help \
                    -bg $coloritem    -command {self_help}]
            $canvas create window 300 250 -window [button $canvas.f -width 10 -height 1 -text exit \
                    -bg $coloritem     -command {exit }]
            $canvas create window 400 200 -window [button $canvas.g -width 10 -text uncover_3-5 \
                    -bg $coloritem    -command {uncover}]
            $canvas create window 400 250 -window [button $canvas.h -width 10 -height 1 -text uncover_6-7 \
                    -bg $coloritem     -command {uncover }]
        }
        mahjongstyle { $state }
        populateCanvas $canvas 7 5
        set selectedid ""
        set selectedtext ""
        $canvas configure -background aquamarine4 -highlightcolor brown -relief raised -border 10
        proc swap_new_cards { state } {
            global new_card_state
            set new_card_state 1
            flip_new_card
            return 1
        }
        proc moveobject {object x y} {
            global deck suitfrenchblack suitfrenchblanc
            global canvas
            $canvas coords $object [expr $x-25] [expr $y-25]
            set new_card  [ lpick $deck ]
            puts $new_card
            $canvas itemconfigure $object -text $new_card -fill orange
        }
        # set boxid [$canvas create rectangle $x1 $y1 $x2 $y2 -fill $color -outline black]
        set egg [$canvas create text 550  200 -text move_right_mouse_for_new_card -fill red ]
        $canvas bind $egg <B3-Motion>  {moveobject $egg %x %y}

if {0} {
        console hide
        console eval {wm title . "Texas Hold Dem Cards, screen grab and paste from console 2 to texteditor"}
        console eval {.console config -bg palegreen}
        console eval {.console config -font {fixed 20 bold}}
        console eval {wm geometry . 40x20}
        console eval {. configure -background orange -highlightcolor brown -relief raised -border 30}
}

        puts " math = [ math::choose 52 2 ]                  "
        $canvas configure -highlightcolor brown -relief raised -border 10
        $canvas configure -width 700 -height 300
        # This posting, screenshots, and TCL source code is
        # copyrighted under the TCL/TK license terms.
        # Editorial rights retained under the TCL/TK license terms
        # and will be defended as necessary in court.
        # end of file
        # gold on TCL club, 5nov2018

#-------------------------------------------------------------------------------

# gold This page is copyrighted under the TCL/TK license terms, this license .
# Updated 2018-12-03 22:21:13


# ;-------------------------------------------------------------------------------
