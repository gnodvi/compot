# -*-   mode: tcl  ; coding: koi8   -*- ----------------------------------------

#-------------------------------------------------------------------------------

# #!/bin/sh
# # \
# exec tclsh "$0" ${1+"$@"}

#-------------------------------------------------------------------------------

# set auto_path [linsert $auto_path 0 "../../ext/expect/R/lib/expect5.45"]

# package require Expect

#-------------------------------------------------------------------------------

#!/bin/sh
#\
exec expect -f "$0" ${1+"$@"}   

#-----------------------------------------------------------

# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
# QNX: почему-то выходит с ошибкой?
#
#spawn a~.tl TEST_menu @
#ldd:FATAL: Unresolved symbol "openpty" called from libexpect5.45.so
#
# configure:
# checking for openpty... yes
# 
# openpty:
# in libc.a, but not in libc.so
# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

# in Ubuntu:
# configure:
# checking for openpty... no
# checking for openpty in -lutil... yes
# 
 
#-------------------------------------------------------------------------------
proc expect_press_enter_and_send {spawn_id cmd} {

  expect {
    " ENTER: " {
      send "$cmd\r"
      #puts ""
    }
    timeout {puts "No response from"}
  }

  #  "and PRESS ENTER: " {}

}
#-------------------------------------------------------------------------------

puts ""
puts "CHECK TEST_menu ... "
puts ""

#set timeout 2

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# залазим поуправлять программкой с меню (через EXPECT)

#spawn  a~.tl TEST_menu @
spawn  a~.tl MENU TEST_menu @

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#expect "and PRESS ENTER: " {puts "\nURRRRAAA!"}
#expect "FIGNY"

#log_user 0 ;# останавливает вывод логаута из вызванного процесса !!
#
# вообще такой дубовый способ анализа вывода  LOGOUT не очень хорошо,
# надо бы получать инфу из переменных ... !!

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

expect_press_enter_and_send $spawn_id "st"

expect_press_enter_and_send $spawn_id "q"

expect_press_enter_and_send $spawn_id "q"

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

puts ""

#-------------------------------------------------------------------------------
