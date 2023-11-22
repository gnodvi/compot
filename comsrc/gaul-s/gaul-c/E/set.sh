#!/bin/sh
#
################################################################################

# подцепить библиотеку "тестовых" утилит
#source ./lib.sh
. ./lib.sh

# перейти в корневую директорию для выполнения заданий
cd ..

echo ""
#-------------------------------------------------------------------------------

#tst  A1 E/OUT . "test_bitstrings"
#tst  T1 E/OUT . "l_test_prng.sh"

#tst  T1 E/OUT . "ga_x_tester.sh"

#tst  X1 E/OUT . "l_pingpong  _sa  4 5 200"

#-------------------------------------------------------------------------------
#tst  A1 E/OUT . "test_bitstrings"

# tst  A1 E/OUT . "onemax"
# tst  A1 E/OUT . "all5s_ALL 1"
# tst  A1 E/OUT . "all5s_ALL 2"

# tst  A1 E/OUT . "goldberg_ALL 1"
# tst  A1 E/OUT . "goldberg_ALL 2"

# tst  A1 E/OUT . "polynomial_ALL ga"
# tst  A1 E/OUT . "polynomial_ALL sa"
# tst  A1 E/OUT . "polynomial_ALL sd"
# tst  A1 E/OUT . "polynomial_ALL simplex"
# tst  A1 E/OUT . "polynomial_ALL de"

#tst  A1 E/OUT . "royalroad"
#tst  A1 E/OUT . "royalroad_bitstring"

# tst  A1 E/OUT . "royalroad_mutation_prob_demo"
# tst  A1 E/OUT . "royalroad_ss"

# tst  A1 E/OUT . "struggle_ALL 1"
# tst  A1 E/OUT . "struggle_ALL 2"
# tst  A1 E/OUT . "struggle_ALL 3"
# tst  A1 E/OUT . "struggle_ALL 4"
# tst  A1 E/OUT . "struggle_ALL 5"

# tst  A1 E/OUT . "struggle_ALL dc"
# tst  A1 E/OUT . "struggle_ALL rs"
# tst  A1 E/OUT . "struggle_ALL ss"

#tst  A2 E/OUT . "wildfire"
#tst  A2 E/OUT . "wildfire_loadbalancing"

# tst  X11 E/OUT . "l_saveload -o l_saveload.1"
# tst  X12 E/OUT . "l_saveload -i l_saveload.1 -o l_saveload.2"

# pingpong_ALL 01  >  $OUT/pingpong_ALL.01
# pingpong_ALL 09  >  $OUT/pingpong_ALL.09
# pingpong_ALL t1  >  $OUT/pingpong_ALL.t1
# pingpong_ALL t2  >  $OUT/pingpong_ALL.t2

# tst  A1 E/OUT . "fitting_ALL 0"
# tst  A1 E/OUT . "fitting_ALL 1"
# tst  A1 E/OUT . "fitting_ALL 2"

#-------------------------------------------------------------------------------



#######################################################################
#OUT=./testout

# polynomial_ALL de >  $OUT/polynomial_ALL.de
# polynomial_ALL ga >  $OUT/polynomial_ALL.ga
# polynomial_ALL sa >  $OUT/polynomial_ALL.sa
# polynomial_ALL sd >  $OUT/polynomial_ALL.sd
# polynomial_ALL simplex > $OUT/polynomial_ALL.simplex

# goldberg_ALL 1 >  $OUT/goldberg_ALL.1
# goldberg_ALL 2 >  $OUT/goldberg_ALL.2

# all5s_ALL 1 >  $OUT/all5s_ALL.1
# all5s_ALL 2 >  $OUT/all5s_ALL.2

# struggle_ALL 1 >  $OUT/struggle_ALL.1
# struggle_ALL 2 >  $OUT/struggle_ALL.2
# struggle_ALL 3 >  $OUT/struggle_ALL.3
# struggle_ALL 4 >  $OUT/struggle_ALL.4
# struggle_ALL 5 >  $OUT/struggle_ALL.5
# struggle_ALL dc  >  $OUT/struggle_ALL.dc
# struggle_ALL rs  >  $OUT/struggle_ALL.rs
# struggle_ALL ss  >  $OUT/struggle_ALL.ss

#-------------------------------------------------------------------------------

# pingpong       >  $OUT/pingpong
# pingpong9      >  $OUT/pingpong9
# pingpong_tabu  >  $OUT/pingpong_tabu
# pingpong_tabu2 >  $OUT/pingpong_tabu2

# pingpong       >  $OUT/pingpong_ALL.01
# pingpong9      >  $OUT/pingpong_ALL.09
# pingpong_tabu  >  $OUT/pingpong_ALL.t1
# pingpong_tabu2 >  $OUT/pingpong_ALL.t2


# wildfire               > $OUT/wildfire.out
# wildfire_loadbalancing > $OUT/wildfire_loadbalancing.out

# royalroad    >  $OUT/royalroad.out
# royalroad_ss >  $OUT/royalroad_ss.out
# royalroad_mutation_prob_demo >  $OUT/royalroad_mutation_prob_demo.out
# royalroad_bitstring          >  $OUT/royalroad_bitstring.out

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
echo ""
#-------------------------------------------------------------------------------

