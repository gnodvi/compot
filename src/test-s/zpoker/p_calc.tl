#!/bin/sh
#
# the next line restarts using tclsh \
exec wish "$0" "$0 $@"

#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------


# Poker Probability and Calculator Demo Example

# This page is under development. Comments are welcome, but please load any 
# comments in the comments section at the bottom of the page. Please include your 
# wiki MONIKER in your comment with the same courtesy that I will give you. Its 
# very hard to reply intelligibly without some background of the correspondent. 
# Thanks,gold

# Page contents

#  Poker Probability and Calculator Demo Example
#  Introduction
#  Testcases Section
#   Testcase 1 
#   Testcase 2 
#   Testcase 3 
#   Testcase 4 
#   Testcase 5 
#  Screenshots Section
#  References:
#  Appendix Code
#  appendix TCL programs and scripts 
#  Comments Section
# Introduction edit

# gold Here is some starter code for poker probability. The impetus for this 
# calculator was checking some poker probabilities of 5 card draw in a book. 
# Its easy enough to plug in formulas into the calculating subroutine. Most of 
# the checked testcases involve 5 card poker.
# Testcases Section

# In planning any software, it is advisable to gather a number of testcases to 
# check the results of the program. The math for the testcases can be checked 
# by pasting statements in the TCL console. Also, some of the pseudocode 
# statements were checked in the google search engine which will take math 
# expressions. The factorial procedure used below was posted by Suchenworth. 
# Aside from the TCL calculator display, when one presses the report button on 
# the calculator, one will have console show access to the factorial function.
# Testcase 1

# For a system of dealing 5 cards from a 52 card deck, the sample space would 
# be factorial(52)/((factorial(5)*factorial(52-5)) or 52!/(5!*47!). Most of 
# these TCL expressions can be pasted into the console window.

#-------------------------------------------------------------------------------

#  set space [ expr {  [f 52]/[f 5]/[f 47]} ] ;# generic TCL
#     answer%      2598960

# The probability of four of a kind would be frequency/ sample space:

#   set probability [ expr { (1.* 4 )/2598960} ]
#   answer%    1.5391E-6           

# The probability of four of a kind would be frequency/ sample space:

#  set probability [ expr { (1.* 624 )/2598960} ]
#   answer%    2.40E-4           

# The probability of three of a kind would be frequency/ sample space:

#  set probability [ expr { (1.* 54912 )/2598960} ] 
#   answer%   0.021

#-------------------------------------------------------------------------------
# Testcase 2

# Continuing with dealing 5 cards from a 52 card deck, there is an alternate 
# way of estimating the factorial, which is the Swerling formula. The Swerling 
# formula is less accurate for small numbers (<60!), but has some interest in 
# estimating the factorial with large numbers (>60!). The Swerling formula is 
# sometimes used to check the magnitude of large N! in computing. The Swerling 
# formula is implemented and accessible from the report console window.

#  set swerlingspace [ expr {  [fact 52]/[fact 5]/[fact 47]} ] 
#     answer%      2599403
#  # and the answers for probabilites would slightly different
#  set probability [ expr { (1.* 4 )/2599403 } ]
#   answer%    1.53881E-6  vis previous 1.5391E-6           

#-------------------------------------------------------------------------------
# Testcase 3

# There are 55 poker players who wish to sit four at a table. What is the number 
# of combinations? The sample space would be 
# factorial(55)/((factorial(4)*factorial(55-4)) or 55!/(5!*50!). The calculator 
# gives an answer of 341055.

#-------------------------------------------------------------------------------
# Testcase 4

# Picking up a five card hand, what is the probability and odds of a straight 
# flush, less royal flush ? As caulated before, the sample space is 
# 52!/((5!* (52-5)!) or 2598960. The frequency is 
# (10 choose 1)*(4 choose 1) -(4 choose 1) , 10!/((1!* (10-1)!) * 
# 4!/((1!* (4-1)!) - 4!/((1!* (4-1)!) , 40-4,or 36.

# set straight_flush  [expr { (1.*36)/ 2598960    } ]
# set straight_flush_odds  [expr { 1./( (1.*36)/ 2598960 )   } ]
# answer%  1.39E-5 ,  72192.0

# hand 	choose formula 	frequency 	division terms 	probability 	odds
# royal flush 	(4 choose 1) 	4 	4/258960 	1.54E-5 	64739
# straight flush less royal flush 	(10 choose 1)* (4 choose 1) -(4 choose 1) 	36 	36/258960 	1.39E-5	72192
# four of kind 	(13 choose 1)* (12 choose 1) *(4 choose 1) 	624 	624/258960 	2.4E-4	4164
# full house	(13 choose 1)* (4 choose 3) *(12 choose 2) 	858 	858/258960 	2.11E-2	46.3
# three of kind 	(13 choose 1)* (4 choose 3) *(12 choose 2)* (4 choose 2) 	156 	156/258960 	1.44E-3	693

#-------------------------------------------------------------------------------
# Testcase 5

# Three cards are bought at 100 cents each. Possibly wrongly, but I am told that 
# the chance of receiving a royal card on each draw is "30 percent". The chance
#  of not receiving a royal card on a draw is "70 percent". If all 3 cards are
#  royal, 300 cents are paid;if 2 cards are royal, 150 cents are paid; if one 
# card is royal, 10 cents are paid. What is the weighted pay off or expectation?
# choose term 	term1 * 	term2 *	term3 	= wg p(x)	pay off	wg p(x)* pay off
# 3 choose 0 	1.0 	0.7**3 	0.3**0 	0.343 	-100	-34.3
# 3 choose 1 	3. 	0.7**2 	0.3**1 	0.441 	-90	-39.89
# 3 choose 2 	3. 	0.7**1 	0.3**2 	0.22 	50	11.0
# 3 choose 3 	1.0 	0.7**0 	0.3**3 	0.027 	200	5.4
# 			sum >> 	1.0 	expectation >> 	-57.79

# Now, if there are 3 royal cards and 10 common cards in a suit, the 
# probability of a royal card is 3/(10+3),3/13, or 0.2307. The probability of 
# not receivng a royal card is 10/(10+3),10/13, or 0.769. Checking, the total 
# chances of either a royal card or a common card are 0.2307 + 0.769 or 1. 
# Since the probabilities are different than first represented, the expectation 
# of pay off should be recalculated.
# weighted probability 	pay off 	p(x)*pay off
# .454 	-100 	-45.4
# 0.5322 	-90 	-47.898
# 0.2076 	50 	+10.38
# 0.027 	200 	+5.4
# 	expectation>> 	-77.52

# So in buying three cards for three dollars, the expectation is a loss of 78 cents.
# Screenshots Section

#-------------------------------------------------------------------------------
# figure 1.
# References:

#     5-CARD POKER HANDS ,http://www.math.hawaii.edu/~ramsey/Probability/PokerHands.html
#     Durango Bill's Poker Probabilities, http://www.durangobill.com/Poker.html
#     Poker probability, http://mathforum.org/library/drmath/view/56616.html
#     Poker probability, http://www.princeton.edu/~achaney/tmve/wiki100k/docs/Poker_probability.html

#-------------------------------------------------------------------------------
# Appendix Code
# appendix TCL programs and scripts
#-------------------------------------------------------------------------------

        # pretty print from autoindent and ased editor
        # poker probability calculator
        # written on Windows XP on eTCL
        # working under TCL version 8.5.6 and eTCL 1.0.1
        # gold on TCL WIKI , 12jul2013
        package require Tk
        frame .frame -relief flat -bg aquamarine4
        pack .frame -side top -fill y -anchor center
        set names {{} {number of cards in deck:} }
        lappend names {distinct hands:}
        lappend names {frequency: }
        lappend names {sample space:}
        lappend names {probability:}
        lappend names {odds:1}
        foreach i {1 2 3 4 5 6} {
            label .frame.label$i -text [lindex $names $i] -anchor e
            entry .frame.entry$i -width 35 -textvariable side$i
            grid .frame.label$i .frame.entry$i -sticky ew -pady 2 -padx 1 }
        proc about {} {
            set msg "Calculator for Poker Probability
            from TCL WIKI,
            written on eTCL "
            tk_messageBox -title "About" -message $msg }
       proc f n { expr {$n < 2 ? 1 : $n * [f [incr n -1]]} }
       proc fact n {expr {            
            $n<2? 1:
            $n>20? pow($n,$n)*exp(-$n)*sqrt(2*acos(-1)*$n):
            wide($n)*[fact [incr n -1]]}}   
       proc calculate {     } {
            global answer2
            global side1 side2 side3 side4 side5
            global side6
        set aa [ expr { int($side1) } ]
        set bb [ expr { int($side2) } ]
        set cc [ expr { $aa-$bb } ]
        set cc [ expr { int($cc) } ]
        set dd [ expr { int($side3) } ]
        set term1 [ f $aa ]
        set term2 [ f $bb ]
        set term3 [ f $cc ] 
        set samplespace [ expr {$term1*1./(1.*$term2*$term3)} ]
        set pokerprob [ expr { (1.*$dd)/$samplespace } ]
        set pokerodds [ expr { 1./$pokerprob } ]
        set side4 $samplespace
        set side5 $pokerprob
        set side6 $pokerodds }
        proc fillup {aa bb cc dd ee ff} {
            .frame.entry1 insert 0 "$aa"
            .frame.entry2 insert 0 "$bb"
            .frame.entry3 insert 0 "$cc"
            .frame.entry4 insert 0 "$dd"
            .frame.entry5 insert 0 "$ee"
            .frame.entry6 insert 0 "$ff" }
        proc clearx {} {
            foreach i {1 2 3 4 5 6 } {
                .frame.entry$i delete 0 end } }
        proc reportx {} {
            global side1 side2 side3 side4 side5
            global side6
            console show;
            puts "number of cards: $side1 "
            puts "distinct hards: $side2 "
            puts "frequency: $side3    "
            puts "answer sample space: $side4    "
            puts "hand probability: $side5    "
            puts "integer odds:1 $side6    " }
        frame .buttons -bg aquamarine4
        ::ttk::button .calculator -text "Solve" -command { calculate   }
        ::ttk::button .test2 -text "Testcase1" -command {clearx;fillup 52. 5. 4. 2.59E6  1.5E-6 6.49E5 }
        ::ttk::button .test3 -text "Testcase2" -command {clearx;fillup 52. 5. 624. 8.  2.4E-4 4164 }
        ::ttk::button .test4 -text "Testcase3" -command {clearx;fillup 52. 5. 54912. 4096.  2.11E-2 47.3 }
        ::ttk::button .clearallx -text clear -command {clearx }
        ::ttk::button .about -text about -command about
        ::ttk::button .cons -text report -command { reportx }
        ::ttk::button .exit -text exit -command {exit}
        pack .calculator  -in .buttons -side top -padx 10 -pady 5
        pack  .clearallx .cons .about .exit .test4 .test3 .test2   -side bottom -in .buttons
        grid .frame .buttons -sticky ns -pady {0 10}
        . configure -background aquamarine4 -highlightcolor brown -relief raised -border 30
        wm title . "Poker Probability Calculator "

#-------------------------------------------------------------------------------

# For the push buttons, the recommended procedure is push testcase and fill 
# frame, change first three entries etc, push solve, and then push report. 
# Report allows copy and paste from console. While the testcases are in units 
# of cards, the units cancel out in the calculator equations.

# gold This page is copyrighted under the TCL/TK license terms, this license.
# Comments Section edit

# Please place any comments here, Thanks.


#-------------------------------------------------------------------------------

#-------------------------------------------------------------------------------
