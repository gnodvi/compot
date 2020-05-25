# -*-   mode: tcl  ; coding: koi8   -*- ----------------------------------------

#!/bin/sh
# \
exec tclsh "$0" ${1+"$@"}

#-------------------------------------------------------------------------------
#
#-------------------------------------------------------------------------------


# set COMPOT ".."  ;# "../compot"

# set auto_path [linsert $auto_path 0 $COMPOT]

# #lappend auto_path \
#   [file join [file dirname [info script]] "COM"] ;# "../common"


# package require compot::common 1.0

#-------------------------------------------------------------------------------
#
#
#
#-------------------------------------------------------------------------------
# function_finder.tcl
# test_finder.tcl
#
###!/bin/tclsh8.3
#-------------------------------------------------------------------------------
proc finder_proc {argc argv} {

  array set functions ""
  
  foreach f $argv {

    puts stderr "PROCESSING FILE $f"
    
    # cc --help
    # -E Preprocess only; do not compile, assemble or link
    # -DNeedFunctionPrototypes  ???????????? ‹‘œ –“œ”‘œ ÀœÕÕ≈Œ‘¡“…  ??

    catch {exec cc -DNeedFunctionPrototypes -E $f} data

    #set functionList [regexp -all -inline {[a-zA-Z0-9_-]+[ \t\n\r]+([a-zA-Z0-9_-]+)[ \t\n\r]+\([ \t\n\r]*([^\)]+)[ \t\n\r]*\)[ \t\n\r]*;} $data]

    set functionList [regexp -all -inline {[a-zA-Z0-9_\-\*]+[ \t\n\r\*]+([a-zA-Z0-9_\-\*]+)[ \t\n\r]*\(([^\)]*)\)[ \t\n\r]*;} $data]

    set functionList [concat $functionList \
			[regexp -all -inline {[a-zA-Z0-9_\-\*]+[ \t\n\r\*]+([a-zA-Z0-9_\-\*]+)[ \t\n\r]*_ANSI_ARGS_\(\(([^\)]*)\)\)[ \t\n\r]*;} $data]]

    #puts "FL $functionList"

    foreach {junk function args} $functionList {
      #puts "FUNC $function ARGS $args"
      set args [string map {"\n" "" "\r" "" "\t" " " "," ", "} $args]
      regsub -all {\s{2,}} $args " " args
      set functions($function) $args
    }
  }
  
  puts "array set ::functions \{"
  foreach function [lsort -dictionary [array names functions]] {
    if {"_" == [string index $function 0] || "_" == [string index $function end]} {
      continue
    }
    puts "\t$function [list [set functions($function)]]"
  }
  puts "\}"

}
#-------------------------------------------------------------------------------
proc sglob {pattern} {

  return [glob -nocomplain $pattern]
}
#-------------------------------------------------------------------------------
proc FIND {} {

  global argc argv

  #finder_proc $argc /usr/local/include/tclDecls.h
  #return
  
  finder_proc $argc [concat [sglob /usr/include/*.h] [sglob /usr/include/*/*.h] \
         [sglob /usr/local/include/*.h] [sglob /usr/local/include/*/*.h] \
         [sglob /usr/X11R6/include/*.h] [sglob /usr/X11R6/include/*/*.h] \
         [sglob /usr/X11R6/include/*/*/*.h] [sglob /usr/local/include/X11/*.h] \
         [sglob /usr/local/include/X11/*/*.h]]

  return
}
#-------------------------------------------------------------------------------
#
# SES1
#
#-------------------------------------------------------------------------------
# http://wiki.tcl.tk/36750
#-------------------------------------------------------------------------------

#SeS Enabling mousebutton sensitivity to a ctext widget's highlighted texts

# A typical use-case would be to enable the user to click on a highlighted text 
# and process this, ie. one could startup a help database with regard to the 
# highlighted & clicked text...

# tG≤ v1.06.01.41 has this feature included for the ctext widget of it's Source 
# Code Editor.

# ctextBindings.tcl
#
# Copyright (C) 2012 Sedat Serper
# A similar script and functionality is implemented in tG≤ as of v1.06.01.41 
#

# ------------------------------------------------------------------------------
proc ses1_ctext_execTagCmd {str} {

  # place here your customized script to process the string
  
  # console show # for WINDOWS !
  #
  puts $str

  return
}
# ------------------------------------------------------------------------------
# Purpose : to provide the ability to click on ctext highlights and process the 
#           string underneath the pointer

# Usage   : ctext::binding4Tag <ctext widget path> <list of tags>
# ------------------------------------------------------------------------------
proc ses1_ctext_binding4Tag {w tags} {

  foreach tag $tags {

    $w tag bind $tag <Enter> {%W config -cursor hand2}
    $w tag bind $tag <Leave> {%W config -cursor xterm}

    $w tag bind $tag <ButtonRelease-1> {

      set cur [::tk::TextClosestGap %W %x %y]

      if {[catch {%W index anchor}]} {%W mark set anchor $cur}
      set anchor [%W index anchor]
      set last  [::tk::TextNextPos %W "$cur - 1c" tcl_wordBreakAfter]
      set first [::tk::TextPrevPos %W anchor tcl_wordBreakBefore]

      if {![catch {set tmp [%W get $first $last]}]} {

        ses1_ctext_execTagCmd $tmp
      }
    }
  }

  return
}
# ------------------------------------------------------------------------------
# ----------------------------- demo -------------------------------------------
proc SES1 {} {

  # Open a new wish console and copy/paste the following complete script.
  # Clicking on parts that are highlighted and observe the console output...
  # Adjust procedure 'ses1_ctext_execTagCmd' to customize the handling 4 your 
  # application.
  
  #package require ctext
  source "e-0000.tl"

  pack [ctext .t] -fill both -expand 1
  
  ctext::addHighlightClass .t bindings purple [list <Enter> <Leave> <ButtonRelease-1>]
  ctext::addHighlightClass .t commands orange [list foreach proc if set catch]
  
  .t fastinsert end [info body ses1_ctext_binding4Tag]
  .t highlight 1.0 end
  
  ses1_ctext_binding4Tag .t {bindings commands}
  
}
# ------------------------------------------------------------------------------
#
# SES2
#
# ------------------------------------------------------------------------------
# http://wiki.tcl.tk/1499
# Easy Ctext Commenting

# easyCtextCommenting.tcl for [tG≤]
# Copyright (C) 2012-2013 by Sedat Serper

# ------------------------------------------------------------------------------

# Purpose       : set's bindings of ctext widget to enable user to insert or remove
#                 hash character by mouse control, assumes line numbers of ctext 
#                 widget is set visible
# Scripting & idea : Sedat Serper [SeS]
# Related wiki pages: http://wiki.tcl.tk/24080
# Implementation: easyCtextCommenting <ctext widget path>
# Usage         : click with button-3, drag along the line numbers to toggle hash character
# Note          : As implemented in Source Editor of tG≤ (C) 2011-2013

# ------------------------------------------------------------------------------
# OVER-QUOTED VERSION (less preferred way of scripting)
# ------------------------------------------------------------------------------
proc ses2_easyCtextCommenting {wid} {

  set ::oLS 0
  set ::lineSelected -1

  eval "
    bind \$wid.l <ButtonPress-3> {
      set markChar \[$wid.l index @0,%y\]
      set ::lineSelected \[lindex \[split \$markChar .\] 0\]
      set ::lineSelected \[$wid.l get \$lineSelected.0 \$lineSelected.end\]
      set ::oLs -1
      $wid configure -autoseparators false
    }
    
    bind \$wid.l <ButtonRelease-3> {
      set ::lineSelected -1
      $wid configure -autoseparators true
    }
    
    bind \$wid.l <Motion> {
      if {\$::lineSelected >=0} {
        catch {
          set markChar \[$wid.l index @0,%y\]
          set ::lineSelected \[lindex \[split \$markChar .\] 0\]
          set ::lineSelected \[$wid.l get \$lineSelected.0 \$lineSelected.end\]
          if {\$::oLs != \$::lineSelected} {
            set ::oLs \$::lineSelected
            if {\[$wid get \$::oLs.0 \$::oLs.1\] != \"\#\"} {
              $wid insert \$::oLs.0 \#
            } else {
              $wid delete \$::oLs.0 \$::oLs.1
            }
          }
        }
      }
    } 
  "

  return
}
# ------------------------------------------------------------------------------
# BRACED VERSION (more preferred way of scripting)
# ------------------------------------------------------------------------------
proc ses2_easyCtextCommenting {wid {sensButton 3}} {

  set ::oLS 0
  set ::lineSelected -1
  bind $wid.l <ButtonPress-$sensButton> {
      set markChar [%W index @0,%y]
      set ::lineSelected [lindex [split $markChar .] 0]
      set ::lineSelected [%W get $lineSelected.0 $lineSelected.end]
      set ::oLs -1
      [file rootname %W] configure -autoseparators false
  }
    
  bind $wid.l <ButtonRelease-$sensButton> {
    set ::lineSelected -1
    [file rootname %W] configure -autoseparators true
  }
    
  bind $wid.l <Motion> {
    if {$::lineSelected >=0} {
      catch {
        set markChar [%W index @0,%y]
        set ::lineSelected [lindex [split $markChar .] 0]
        set ::lineSelected [%W get $lineSelected.0 $lineSelected.end]
        if {$::oLs != $::lineSelected} {
          set ::oLs $::lineSelected
          if {[[file rootname %W] get $::oLs.0 $::oLs.1] != "#"} {
            [file rootname %W] insert $::oLs.0 #
          } else {
            [file rootname %W] delete $::oLs.0 $::oLs.1
          }
        }
      }
    }
  } 

}  
# ------------------------------------------------------------------------------
# Test code (tested with ActiveState's tcl/tk v8.4.19 on a Win Vista machine)
# ------------------------------------------------------------------------------
proc SES2 {} {

  #package require ctext
  source "e-0000.tl"

  pack [ctext .ct] -expand 1 -fill both

  ses2_easyCtextCommenting .ct
  
}
# ------------------------------------------------------------------------------
# 
#-------------------------------------------------------------------------------

# set CUR_DIR "e"
  
# READ_AND_CALL_ARGUS  $CUR_DIR

# puts "" 

#-------------------------------------------------------------------------------
#

SES2
SES1

#./e~.tl SES1
#./e~.tl SES2

#-------------------------------------------------------------------------------
