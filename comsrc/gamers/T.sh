#!/bin/bash
#
#-------------------------------------------------------------------------------
#

source ./E/lib.sh

echo ""

#-------------------------------------------------------------------------------

run_tests  r  E/OUT .

#echo ""

(cd SROBOT; T.sh)

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------


