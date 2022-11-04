# -*-   mode: sh   ; coding: koi8   -*- ----------------------------------------

#!/bin/sh
#
#-------------------------------------------------------------------------
# http://stackoverflow.com/questions/630372/
# determine-the-path-of-the-executing-bash-script
#

SCRIPT_PATH=$(dirname $(readlink -f $0))     

SCRIPT_PATH="`( cd \"$SCRIPT_PATH\" && pwd )`"  # absolutized and normalized


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

mkdir -p ~/common-lisp

NAME=asdf-encodings.asd

(cd ~/common-lisp; ln -f -s ${SCRIPT_PATH}/$NAME $NAME)


#-------------------------------------------------------------------------
