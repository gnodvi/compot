#!/bin/sh
#
#---------------------------------------------------------------------

WID=`xdotool search "Mozilla Firefox" | head -1`

xdotool windowactivate --sync $WID
xdotool key --clearmodifiers ctrl+l


# As of version 2.20100623, you can do this simpler version of above:
# xdotool search "Mozilla Firefox" windowactivate --sync key --clearmodifiers ctrl+l

#---------------------------------------------------------------------
