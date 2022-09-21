#!/bin/sh
#
#---------------------------------------------------------------------

# This is an extended version of the previous script as it will 
# send defined keys only if Google Chrome is an active window. 
# You can extend it to support other browsers or even perform different 
# tasks in different applications using the same keyboard shortcut.

#---------------------------------------------------------------------


# used commands
xprop_command=`which xprop`
xdotool_command=`which xdotool`
xte_command=`which xte`

if [ -n "$xprop_command" -a -n "$xdotool_command" -a -n "$xte_command" ]; then

  # get active window id
  active_window_id=`$xdotool_command getactivewindow`

  # get class of the active window
  window_class=`$xprop_command -id $active_window_id | sed -n -e "s/^WM_CLASS(STRING).*\"\(.*\)\", \".*\"/\1/ p"`

  echo 
  echo "WINDOW_CLASS = $window_class"
  echo 

  # execute only when active windows is Google Chrome 
  if [ "$window_class" = "google-chrome" ]; then
    # press F6, Home, enter "https://" string and press return
    $xte_command "sleep 1" "key F6" "usleep 10000" "key Home" "str https://" "key Return"
  fi
fi

#---------------------------------------------------------------------
