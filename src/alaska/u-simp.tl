# -*-   mode: tcl  ; coding: koi8   -*- ----------------------------------------

#-------------------------------------------------------------------------------
# https://wiki.tcl-lang.org/page/Experiments+with+matrix+operations


# Experiments with matrix operations

# Arjen Markus (1 april 2004 and dead-serious!) I wanted to get some feeling for
# the ease by which you can do matrix operations in Tcl (I mean: the kind of
# things that you deal with in Linear Algebra). So the script below explores three
# methods of representation and the performance you get with them. Since two of
# these methods are very similar I used a different approach in the matrix*vector
# computation for the third.

# Warning: the results here are for a single matrix operation only, so it is
# much too early to draw any conclusions.

# If, and only if, these results are representative, then the first
# implementation, using lists of lists, is the fastest and easiest to program.
# However, the matrix*vector computation used here is very suitable for that
# structure. Matrix*matrix computations would require more jumping in the two
# levels of lists, so probably the other two would be faster then (Still to
# be measured!)

#-------------------------------------------------------------------------------

 # testmat.tcl --

 #    Test the speed of several matrix implementations:
 #    The code below is meant to investigate the consequences
 #    of three different implementations of a matrix data type:
 #    1. As a list of lists
 #    2. As a flat list with the first few elements representing the size
 #    3. As a pair of lists, one the matrix sizes and the other the matrix
 #       as a flat list
 #    The algorithm is simple: multiple a vector by the matrix
 #    The matrix is simple:
 #    1 2 3 ... N-1 0
 #    2 3 .....  0  1
 #    3 4 .....  1  2
 #    ...
 #    The vector is too: (1,2,3,4,...)
 #    Note: all numbers are double precision reals!
 #

 catch {console show}

#-------------------------------------------------------------------------------
proc makemat1 {N} {

  set result {}

  for {set j 0} {$j < $N} {incr j} {
    set row {}

    for {set i 0} {$i < $N} {incr i} {
      lappend row [expr {double (($i + $j + 1) % $N)}]
    }

    lappend result $row
  }

  return $result
}
#-------------------------------------------------------------------------------
proc makemat2 {N} {

  set result [list 2 $N $N] ;# Two-dimensional

  for { set j 0 } { $j < $N } { incr j } {
  for { set i 0 } { $i < $N } { incr i } {

    lappend result [expr {double (($i + $j + 1) % $N)}]
  }
  }

  return $result
}
#-------------------------------------------------------------------------------
proc makemat3 {N} {

  set result [list [list $N $N]]
  set values {}

  for { set j 0 } { $j < $N } { incr j } {
  for { set i 0 } { $i < $N } { incr i } {

    lappend values [expr {double (($i + $j + 1) % $N)}]
    }
  }

  lappend result $values
}
#-------------------------------------------------------------------------------
proc makevect {N} {

  set result {}

  for { set i 0 } { $i < $N } { incr i } {
    lappend result [expr {double($i+1)}]
  }

  return $result
}
#-------------------------------------------------------------------------------
proc matmul1 { matrix vector } {

  set newvect {}

  foreach row $matrix {
    set sum 0.0

    foreach v $vector c $row {
      set sum [expr {$sum + $v * $c}]
    }
    lappend newvect $sum
  }

  return $newvect
}
#-------------------------------------------------------------------------------
proc matmul2 { matrix vector } {

  foreach {dummy ncol nrow} $matrix {break}
  
  set newvect {}
  
  set idx 3

  for {set j 0} {$j < $nrow} {incr j} {
    set sum 0.0

    foreach v $vector {

      set c [lindex $matrix $idx]
      set sum [expr {$sum+$v*$c}]

      incr idx
    }

    lappend newvect $sum
  }

  return $newvect
}
#-------------------------------------------------------------------------------
proc matmul3 { matrix vector } {

  foreach {ncol nrow} [lindex $matrix 0] {break}

  set values [lindex $matrix 1]
  
  set newvect {}
  
  for {set j 0} {$j < $nrow} {incr j} {

    set idx1 [expr {$j*$ncol}]
    set idx2 [expr {$idx1+$ncol-1}]
    set sum  0.0

    foreach v $vector c [lrange $values $idx1 $idx2] {
      set sum [expr {$sum + $v * $c}]
    }

    lappend newvect $sum
  }

  return $newvect
}
#-------------------------------------------------------------------------------
proc TEST_time {} {
  
  #
  # Test and measure
  #
  
  puts ""
  puts "Test the matrix construction .........................."
  puts ""
  
  puts [set matrix1 [makemat1 4]]
  puts [set matrix2 [makemat2 4]]
  puts [set matrix3 [makemat3 4]]
  
  puts ""
  puts "Test the matrix multiplication ........................"
  puts ""
  
  set matrix1 [makemat1 10]
  set matrix2 [makemat2 10]
  set matrix3 [makemat3 10]
  
  set vector  [makevect 10]
  
  puts [set newvect1 [matmul1 $matrix1 $vector]]
  puts [set newvect2 [matmul2 $matrix2 $vector]]
  puts [set newvect3 [matmul3 $matrix3 $vector]]
  
  puts ""
  puts "-------------------------------------------------------"
  puts ""

  puts ""
  puts "Measure the relative speeds ..........................."
  puts ""
  
  foreach size {3 10 30 100 300} {
    
    puts "Size: $size"
    puts ""
    
    set matrix1 [makemat1 $size]
    set matrix2 [makemat2 $size]
    set matrix3 [makemat3 $size]
    
    set vector  [makevect $size]

    puts [time {set newvect1 [matmul1 $matrix1 $vector]} 100]
    puts [time {set newvect2 [matmul2 $matrix2 $vector]} 100]
    puts [time {set newvect3 [matmul3 $matrix3 $vector]} 100]

    # Size: 300
    # 25524.6 microseconds per iteration
    # 23768.29 microseconds per iteration
    # 25636.06 microseconds per iteration

    puts ""
 }

  return
}
#-------------------------------------------------------------------------------

#TEST_01

#-------------------------------------------------------------------------------

# The result (on a Windows XP machine with Tcl 8.4.1):

# Test the matrix construction
#  {1.0 2.0 3.0 0.0} {2.0 3.0 0.0 1.0} {3.0 0.0 1.0 2.0} {0.0 1.0 2.0 3.0}
#  2 4 4 1.0 2.0 3.0 0.0 2.0 3.0 0.0 1.0 3.0 0.0 1.0 2.0 0.0 1.0 2.0 3.0
#  {4 4} {1.0 2.0 3.0 0.0 2.0 3.0 0.0 1.0 3.0 0.0 1.0 2.0 0.0 1.0 2.0 3.0}
#  Test the matrix multiplication
#  285.0 250.0 225.0 210.0 205.0 210.0 225.0 250.0 285.0 330.0
#  285.0 250.0 225.0 210.0 205.0 210.0 225.0 250.0 285.0 330.0
#  285.0 250.0 225.0 210.0 205.0 210.0 225.0 250.0 285.0 330.0
#  Measure the relative speeds
#  Size: 3
#  14 microseconds per iteration
#  16 microseconds per iteration
#  21 microseconds per iteration
#  Size: 10
#  85 microseconds per iteration
#  102 microseconds per iteration
#  105 microseconds per iteration
#  Size: 30
#  650 microseconds per iteration
#  864 microseconds per iteration
#  728 microseconds per iteration
#  Size: 100
#  6998 microseconds per iteration
#  9193 microseconds per iteration
# 7340 microseconds per iteration

#-------------------------------------------------------------------------------
# Lars H: Here is an alternative matmul3:

proc matmul3b { matrix vector } {
  
  foreach {ncol nrow} [lindex $matrix 0] {break}
  set values [lindex $matrix 1]
  
  set newvect [list]

  for {set i 0; set i_flat 0} {$i < $nrow} {incr i} {
    set sum 0.0
    foreach v $vector {
      set sum [expr {$sum + $v*[lindex $values $i_flat]}]
      incr i_flat
    }
    lappend newvect $sum
  }

  return $newvect
}

# Interestingly enough, I find that this is faster than matmul3 for matrices
# of side 3 and 10, but slower for matrices of side 30 and 100. Apparently
# lrange+foreach outperforms lindex+incr on long lists. That's curious (and
# would be an argument in favour of the first matrix format, if the operations
# are supposed to be implemented in Tcl rather than by a compiled extension).

# AM Yes, it goes against the somewhat anecdotal evidence I have. So I think
# it is important to do these measurements systematically ....

#-------------------------------------------------------------------------------

# AM (8 april 2004) I have implemented two versions of a matrix-matrix
# multiplication and the trend continues: even though I create two transposed
# versions of the matrix in the list-of-lists implementation, it is still faster
# by a factor of two than the other one, which uses a flat list.

# Here is the code:

# Matrix multiplication
#
#-------------------------------------------------------------------------------
#
# Transpose the matrix
#
proc transpose1 {matrix} {

  set row {}
  set transpose {}

  foreach c [lindex $matrix 0] {
    lappend row 0.0
  }

  foreach r $matrix {
    lappend transpose $row
  }
  
  set nr 0

  foreach r $matrix {
    set nc 0
    foreach c $r {
      lset transpose $nc $nr $c
      incr nc
    }
    incr nr
  }

  return $transpose
}
#-------------------------------------------------------------------------------
proc matxmat1 { matrix1 matrix2 } {

  set transpose [transpose1 $matrix2]
  set newmat {}

  foreach row $transpose {
    lappend newmat [matmul1 $matrix1 $row]
  }

  transpose1 $newmat
}
#-------------------------------------------------------------------------------
#
# Too much alike to matxmat3 to merit the actual implementation ...
#proc matxmat2 { matrix1 matrix2 } {
#   
#}
proc matxmat3 {matrix1 matrix2} {

  foreach {ncol nrow} [lindex $matrix1 0] {break}

  set values1 [lindex $matrix1 1]
  set values2 [lindex $matrix2 1]
  
  set newmat [list [lindex $matrix1 0]]
  set newvalues {}
  
  for { set j 0 } { $j < $nrow } { incr j } {
  for { set i 0 } { $i < $ncol } { incr i } {

    set v1idx [expr {$j*$ncol}]
    set v2idx $i
    set sum   0.0

    for { set k 0 } { $k < $ncol } { incr k } {
      set v1 [lindex $values1 $v1idx]
      set v2 [lindex $values2 $v2idx]
      set sum [expr {$sum+$v1*$v2}]
      
      incr v1idx 1
      incr v2idx $ncol
    }

    lappend newvalues $sum
  }
  }

  lappend newmat $newvalues
}
#-------------------------------------------------------------------------------
proc TEST_02 {} {

 puts ""
 puts "-------------------------------------------------------"
 puts "---------------------TEST_02---------------------------"
 puts ""

 set matrix {{1.0 1.0 1.0} {0.0 0.0 0.0} {2.0 2.0 2.0}}

 puts ""
 puts $matrix
 puts [transpose1 $matrix]

 puts ""
 puts "-------------------------------------------------------"
 puts ""

 set matrix1 { {1.0  2.0} 
               {0.0  1.0} }

 set matrix2 { {0.0 -1.0} 
               {1.0  0.0} }

 puts [matxmat1 $matrix1 $matrix2]

 puts ""
 puts "-------------------------------------------------------"
 puts ""

 set matrix1 { {2 2} {1.0 2.0 0.0 1.0} }
 set matrix2 { {2 2} {0.0 -1.0 1.0 0.0} }

 puts [matxmat3 $matrix1 $matrix2]

 puts ""
 puts "-------------------------------------------------------"
 puts ""

 puts "Measure the relative speeds: "
 puts ""

 foreach size {3 10 30 100} {

    puts "Size: $size"
    puts ""

    set matrix1 [makemat1 $size]
    set matrix3 [makemat3 $size]

    puts [time {set newvect1 [matxmat1 $matrix1 $matrix1]} 10]
    puts [time {set newvect3 [matxmat3 $matrix3 $matrix3]} 10]
    puts ""
 }

 return
}
#-------------------------------------------------------------------------------

#TEST_02


#-------------------------------------------------------------------------------
# And here are the results:

#   {1.0 1.0 1.0} {0.0 0.0 0.0} {2.0 2.0 2.0} 
#  {1.0 0.0 2.0} {1.0 0.0 2.0} {1.0 0.0 2.0}
#  {2.0 -1.0} {1.0 0.0}
#  {2 2} {2.0 -1.0 1.0 0.0}
#  Measure the relative speeds
#  Size: 3
#  82 microseconds per iteration
#  58 microseconds per iteration
#  Size: 10
#  1012 microseconds per iteration
#  1403 microseconds per iteration
#  Size: 30
#  20817 microseconds per iteration
#  35235 microseconds per iteration
#  Size: 100
#  729725 microseconds per iteration
# 1316396 microseconds per iteration

#-------------------------------------------------------------------------------

# AD - 2015-02-25 10:02:52

# The transpose1 procedure computes wrong results for a non-quadratic matrix.
# ::math::linearalgebra::transpose works fine.

#-------------------------------------------------------------------------------
											  
