# -*-   mode: sh   ; coding: koi8   -*- ----------------------------------------

#!/bin/sh
#
#-------------------------------------------------------------------------------
#

echo ""

#-------------------------------------------------------------------------------

FNAME="-*-fixed-bold-*-*-*-15-*-*-*-*-*-iso8859-5"
SIZES="87x47+400+200"

md=`date +%m%d%H%M`

#exit

#DIR=../../../../Y/t_test/$md
DIR=./Y/$md

#-------------------------------------------------------------------------------

PROG=t_test.tl

(mkdir $DIR ; \
\
cp $PROG      $DIR ; \
cp t_meta.tl  $DIR ; \
cp g-graf.tl  $DIR ; \
\
cd $DIR ; ln -s ../C  COMPOT; \
xterm -fn $FNAME -geometry $SIZES -bg black -fg white -cr yellow   -e mc \
)

echo ""

#cd $DIR ; ln -s ../../../compot  COMPOT; \

#-------------------------------------------------------------------------------

# urxvt -fn $FNAME -geometry $SIZES -bg black -fg white -cr yellow -e sh -c "$PROG @ ; read -p Pres ENTER to continue !" & )

# TODO:  
# 
# запускать с параемтрами частоты сохранений (сначала удалив всё)
# как сделать, чтоб окошко само не азкрывалось??
# 
#-------------------------------------------------------------------------------
#       -e command [arguments]
#            Run the command with its command-line arguments in the urxvt window;
#            also sets the window title and icon name to be the basename of the
#            program being executed if neither -title (-T) nor -n are given on the
#            command line. If this option is used, it must be the last on the
#            command-line. If there is no -e option then the default is to run the
#            program specified by the SHELL environment variable or, failing that,
#            sh(1).

#            Please note that you must specify a program with arguments. If you want
#            to run shell commands, you have to specify the shell, like this:

#              urxvt -e sh -c "shell commands"
#-------------------------------------------------------------------------------



