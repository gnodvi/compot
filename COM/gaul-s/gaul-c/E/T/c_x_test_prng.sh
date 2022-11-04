#!/bin/sh
#
#######################################################################

#echo ""

#######################################################################
#
# Random number generator test script special case.
#

echo -n "l_test_prng... "
if [ `expr 1 + \`./c_x_tester prng | grep FAILED | wc -l\`` -gt 31 ]; then
  echo "FAILED - please check on the chi squared tests from './test_prng'."
else
  echo "PASSED"
fi

#######################################################################
#echo ""
#######################################################################


