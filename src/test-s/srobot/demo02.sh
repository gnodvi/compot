#!/bin/sh
#
#---------------------------------------------------------------------

#IDS=`xdotool search --onlyvisible --name "gnome-terminal"`
#WIDS=`xdotool search --name "Terminal"`

WIDS=`xdotool search --name "Firefox"`

#echo "WIDS = $WIDS" # ?? 

for id in $WIDS; do
  echo "id = $id"
  xdotool windowsize $id 500 500
  #break
done

# As of version 2.20100623, you can do this simpler version of above:
#xdotool search --onlyvisible --classname "gnome-terminal" windowsize %@ 500 500

#---------------------------------------------------------------------
# почему тут список сразу?
#
# id = 65011713
# id = 65011716
# id = 65011718
#---------------------------------------------------------------------
