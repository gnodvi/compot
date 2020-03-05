# -*-   mode: tcl  ; coding: koi8   -*- ----------------------------------------

#!/bin/sh
# \
exec tclsh "$0" ${1+"$@"}

#-------------------------------------------------------------------------------
#

# http://www2.tcl.tk/17616
#-------------------------------------------------------------------------------
#
# You can use TkCon as a console for your applications. This is great for 
# debugging, or giving your users a lot of flexibility with the application. 
# The console window interacts directly with the main interpreter. As of TkCon 
# version 2.4, you can source tkcon.tcl and load it as a quasi-package. (There 
# is no pkgIndex.tcl but see below) Put code like this into your GUI 
# construction.

#------------------------------------------------------
#  Tkcon isn't packaged in a library, so we have to
#  source the code, but it provides a package, and
#  the commands [tkcon show] and [tkcon hide]
#------------------------------------------------------
#source tkcon.tcl

# source  consol.tl
# package require tkcon


# But this doesn't actually create the console until the first time you use it. 
# You also might find some behavior you don't like. For example, if you close the 
# tkcon console window by clicking the "X", then the application exits. There 
# isn't a good public interface for just creating the console and attaching 
# show/hide to a radio button, so you might end up using code like this, even 
# after the package require tkcon.

#------------------------------------------------------
#  The console doesn't exist yet.  If we create it
#  with show/hide, then it flashes on the screen.
#  So we cheat, and call tkcon internals to create
#  the console and customize it to our application.
#------------------------------------------------------

# set tkcon::PRIV(showOnStartup) 0
# set tkcon::PRIV(root) .console
# set tkcon::PRIV(protocol) {tkcon hide}
# set tkcon::OPT(exec) ""

# tkcon::Init
# tkcon title "My Application Console"

#tkcon show
#pack [button .b -text Console -command { tkcon show }]

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------

# Google group: comp.lang.tcl
# TkCon in another toplevel window

# Jeff Hobbs :
# Before sourcing tkcon, you have to set a few magic variables.  Something
# like this should work for you:

namespace eval ::tkcon {}
# we want to have only the main interpreter
#set ::tkcon::OPT(exec) ""

# we don't want tkcon to override gets or exit
#set ::tkcon::OPT(gets) ""
#set ::tkcon::OPT(overrideexit) 0

# use the specified window as root
set ::tkcon::PRIV(root) .tkcon
set ::tkcon::PRIV(protocol) "tkcon hide"

#-------------------------------------------------------------------------------

#source tkcon.tcl
source "e-cons.tk"

#-------------------------------------------------------------------------------
# This also requires that you are using the latest tkcon sources for all
# of the above to have an effect.  tkcon wants it's own window, but the
# first time you say 'tkcon show' it will all pop up nice and happy.
tkcon show


# Bob Techentin :
# Thanks, Jeff.  But this is just a bit different from the code snippet
# at http://wiki.tcl.tk/tkcon which suggests setting
# tkcon::PRIV(showOnStartup) to zero.  Now that I look at it, I don't
# see tkcon::PRIV documented on the same page with tkcon::OPT.  Is there
# documentation for the PRIV options?

# Jeff Hobbs :
# No, that's why they are PRIV ;).  I should actually replumb that
# whole pre-integration part, but, alas, time time time ...

#-------------------------------------------------------------------------------

puts ""
puts "A want print this in TKCON !!"
puts ""

tkcon_puts "A want print this in TKCON !!"

# тоже самое !!
# аа, так может это нормально что оно выводит просто в строку с начала
# а не после подсказки?? !!

flush stdout  ;# все данные должны быть выведены
tkcon_puts -nonewline "ENTER: " 

# почему-то печатает вот так:
# ENTER: (compot) 2 % 

# а на след команды вообще зависает: (убрал set ::tkcon::OPT(exec))

flush stdout  ;# все данные должны быть выведены
set answer [gets stdin]

puts " "
puts "ANSWER = $answer"
    
# и вроде бы срабатывает, но потом пытается выполнить команду введеную почему-то.

#-------------------------------------------------------------------------------

