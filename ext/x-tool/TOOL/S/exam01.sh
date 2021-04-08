#!/bin/sh
#
#---------------------------------------------------------------------

# http://blog.sleeplessbeastie.eu/2013/01/21/how-to-automate-mouse-and-keyboard/

# First script is very simple as it will only print date anywhere 
# you execute it.

#---------------------------------------------------------------------

# used command
xte_command=`which xte`
 
if [ -n "$xte_command" ]; then
  # set desired date format
  date=`date +%d.%m.%Y`

  # generate fake input
  $xte_command "str ${date}"
fi

#---------------------------------------------------------------------
