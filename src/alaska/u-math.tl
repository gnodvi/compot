# -*-   mode: tcl  ; coding: koi8   -*- ----------------------------------------

#-------------------------------------------------------------------------------
# linalg.tcl --
#    Linear algebra package, based partly on Hume's LA package,
#    partly on experiments with various representations of
#    matrices. Also the functionality of the BLAS library has
#    been taken into account.
#
#    General information:
#    - The package provides both a high-level general interface and
#      a lower-level specific interface for various LA functions
#      and tasks.
#    - The general procedures perform some checks and then call
#      the various specific procedures. The general procedures are
#      aimed at robustness and ease of use.
#    - The specific procedures do not check anything, they are
#      designed for speed. Failure to comply to the interface
#      requirements will presumably lead to [expr] errors.
#    - Vectors are represented as lists, matrices as lists of
#      lists, where the rows are the innermost lists:
#
#      / a11 a12 a13 \
#      | a21 a22 a23 | == { {a11 a12 a13} {a21 a22 a23} {a31 a32 a33} }
#      \ a31 a32 a33 /
#

#-------------------------------------------------------------------------------
package require Tcl 8.4

namespace eval ::math::linearalgebra {
    # Define the namespace
    namespace export dim shape conforming symmetric
    namespace export norm norm_one norm_two norm_max normMatrix
    namespace export dotproduct unitLengthVector normalizeStat
    namespace export axpy axpy_vect axpy_mat crossproduct
    namespace export add add_vect add_mat
    namespace export sub sub_vect sub_mat
    namespace export scale scale_vect scale_mat matmul transpose
    namespace export rotate angle choleski
    namespace export getrow getcol getelem setrow setcol setelem
    namespace export mkVector mkMatrix mkIdentity mkDiagonal
    namespace export mkHilbert mkDingdong mkBorder mkFrank
    namespace export mkMoler mkWilkinsonW+ mkWilkinsonW-
    namespace export solveGauss solveTriangular
    namespace export solveGaussBand solveTriangularBand
    namespace export solvePGauss
    namespace export determineSVD eigenvectorsSVD
    namespace export leastSquaresSVD
    namespace export orthonormalizeColumns orthonormalizeRows
    namespace export show to_LA from_LA
    namespace export swaprows swapcols
    namespace export dger dgetrf mkRandom mkTriangular
    namespace export det largesteigen
}

# dim --
#     Return the dimension of an object (scalar, vector or matrix)
# Arguments:
#     obj        Object like a scalar, vector or matrix
# Result:
#     Dimension: 0 for a scalar, 1 for a vector, 2 for a matrix
#
proc ::math::linearalgebra::dim { obj } {
    set shape [shape $obj]
    if { $shape != 1 } {
        return [llength [shape $obj]]
    } else {
        return 0
    }
}

# shape --
#     Return the shape of an object (scalar, vector or matrix)
# Arguments:
#     obj        Object like a scalar, vector or matrix
# Result:
#     List of the sizes: 1 for a scalar, number of components
#     for a vector, number of rows and columns for a matrix
#
proc ::math::linearalgebra::shape { obj } {
    set result [llength $obj]
    if { [llength [lindex $obj 0]] <= 1 } {
       return $result
    } else {
       lappend result [llength [lindex $obj 0]]
    }
    return $result
}

# show --
#     Return a string representing the vector or matrix,
#     for easy printing
# Arguments:
#     obj        Object like a scalar, vector or matrix
#     format     Format to be used (defaults to %6.4f)
#     rowsep     Separator for rows (defaults to \n)
#     colsep     Separator for columns (defaults to " ")
# Result:
#     String representing the vector or matrix
#
proc ::math::linearalgebra::show { obj {format %6.4f} {rowsep \n} {colsep " "} } {
    set result ""
    if { [llength [lindex $obj 0]] == 1 } {
        foreach v $obj {
            append result "[format $format $v]$rowsep"
        }
    } else {
        foreach row $obj {
            foreach v $row {
                append result "[format $format $v]$colsep"
            }
            append result $rowsep
        }
    }
    return $result
}

# conforming --
#     Determine if two objects (vector or matrix) are conforming
#     in shape, rows or for a matrix multiplication
# Arguments:
#     type       Type of conforming: shape, rows or matmul
#     obj1       First object (vector or matrix)
#     obj2       Second object (vector or matrix)
# Result:
#     1 if they conform, 0 if not
#
proc ::math::linearalgebra::conforming { type obj1 obj2 } {
    set shape1 [shape $obj1]
    set shape2 [shape $obj2]
    set result 0
    if { $type == "shape" } {
        set result [expr {[lindex $shape1 0] == [lindex $shape2 0] &&
                          [lindex $shape1 1] == [lindex $shape2 1]}]
    }
    if { $type == "rows" } {
        set result [expr {[lindex $shape1 0] == [lindex $shape2 0]}]
    }
    if { $type == "matmul" } {
        set result [expr {[lindex $shape1 1] == [lindex $shape2 0]}]
    }
    return $result
}

# crossproduct --
#     Return the "cross product" of two 3D vectors
# Arguments:
#     vect1      First vector
#     vect2      Second vector
# Result:
#     Cross product
#
proc ::math::linearalgebra::crossproduct { vect1 vect2 } {

    if { [llength $vect1] == 3 && [llength $vect2] == 3 } {
        foreach {v11 v12 v13} $vect1 {v21 v22 v23} $vect2 {break}
        return [list \
            [expr {$v12*$v23 - $v13*$v22}] \
            [expr {$v13*$v21 - $v11*$v23}] \
            [expr {$v11*$v22 - $v12*$v21}] ]
    } else {
        return -code error "Cross-product only defined for 3D vectors"
    }
}

# angle --
#     Return the "angle" between two vectors (in radians)
# Arguments:
#     vect1      First vector
#     vect2      Second vector
# Result:
#     Angle between the two vectors
#
proc ::math::linearalgebra::angle { vect1 vect2 } {

    set dp [dotproduct $vect1 $vect2]
    set n1 [norm_two $vect1]
    set n2 [norm_two $vect2]

    if { $n1 == 0.0 || $n2 == 0.0 } {
        return -code error "Angle not defined for null vector"
    }

    return [expr {acos($dp/$n1/$n2)}]
}


# norm --
#     Compute the (1-, 2- or Inf-) norm of a vector
# Arguments:
#     vector     Vector (list of numbers)
#     type       Either 1, 2 or max/inf to indicate the type of
#                norm (default: 2, the euclidean norm)
# Result:
#     The (1-, 2- or Inf-) norm of a vector
# Level-1 BLAS :
#     if type = 1, corresponds to DASUM
#     if type = 2, corresponds to DNRM2
#
proc ::math::linearalgebra::norm { vector {type 2} } {
    if { $type == 2 } {
       return [norm_two $vector]
    }
    if { $type == 1 } {
       return [norm_one $vector]
    }
    if { $type == "max" || $type == "inf" } {
       return [norm_max $vector]
    }
    return -code error "Unknown norm: $type"
}

# norm_one --
#     Compute the 1-norm of a vector
# Arguments:
#     vector     Vector
# Result:
#     The 1-norm of a vector
#
proc ::math::linearalgebra::norm_one { vector } {
    set sum 0.0
    foreach c $vector {
        set sum [expr {$sum+abs($c)}]
    }
    return $sum
}

# norm_two --
#     Compute the 2-norm of a vector (euclidean norm)
# Arguments:
#     vector     Vector
# Result:
#     The 2-norm of a vector
# Note:
#     Rely on the function hypot() to make this robust
#     against overflow and underflow
#
proc ::math::linearalgebra::norm_two { vector } {
    set sum 0.0
    foreach c $vector {
        set sum [expr {hypot($c,$sum)}]
    }
    return $sum
}

# norm_max --
#     Compute the inf-norm of a vector (maximum of its components)
# Arguments:
#     vector     Vector
#     index, optional     if non zero, returns a list made of the maximum
#                         value and the index where that maximum was found.
#	                  if zero, returns the maximum value.
# Result:
#     The inf-norm of a vector
# Level-1 BLAS :
#     if index!=0, corresponds to IDAMAX
#
proc ::math::linearalgebra::norm_max { vector {index 0}} {
    set max [lindex $vector 0]
    set imax 0
    set i 0
    foreach c $vector {
        if {[expr {abs($c)>$max}]} then {
          set imax $i
          set max [expr {abs($c)}]
        }
        incr i
    }
    if {$index == 0} then {
      set result $max
    } else {
      set result [list $max $imax]
    }
    return $result
}

# normMatrix --
#     Compute the (1-, 2- or Inf-) norm of a matrix
# Arguments:
#     matrix     Matrix (list of row vectors)
#     type       Either 1, 2 or max/inf to indicate the type of
#                norm (default: 2, the euclidean norm)
# Result:
#     The (1-, 2- or Inf-) norm of the matrix
#
proc ::math::linearalgebra::normMatrix { matrix {type 2} } {
    set v {}

    foreach row $matrix {
        lappend v [norm $row $type]
    }

    return [norm $v $type]
}

# symmetric --
#     Determine if the matrix is symmetric or not
# Arguments:
#     matrix     Matrix (list of row vectors)
#     eps        Tolerance (defaults to 1.0e-8)
# Result:
#     1 if symmetric (within the tolerance), 0 if not
#
proc ::math::linearalgebra::symmetric { matrix {eps 1.0e-8} } {
    set shape [shape $matrix]
    if { [lindex $shape 0] != [lindex $shape 1] } {
       return 0
    }

    set norm_org   [normMatrix $matrix]
    set norm_asymm [normMatrix [sub $matrix [transpose $matrix]]]

    if { $norm_asymm <= $eps*$norm_org } {
        return 1
    } else {
        return 0
    }
}

# dotproduct --
#     Compute the dot product of two vectors
# Arguments:
#     vect1      First vector
#     vect2      Second vector
# Result:
#     The dot product of the two vectors
# Level-1 BLAS : corresponds to DDOT
#
proc ::math::linearalgebra::dotproduct { vect1 vect2 } {
    if { [llength $vect1] != [llength $vect2] } {
       return -code error "Vectors must be of equal length"
    }
    set sum 0.0
    foreach c1 $vect1 c2 $vect2 {
        set sum [expr {$sum + $c1*$c2}]
    }
    return $sum
}

# unitLengthVector --
#     Normalize a vector so that a length 1 results and return the new vector
# Arguments:
#     vector     Vector to be normalized
# Result:
#     A vector of length 1
#
proc ::math::linearalgebra::unitLengthVector { vector } {
    set scale [norm_two $vector]
    if { $scale == 0.0 } {
        return -code error "Can not normalize a null-vector"
    }
    return [scale [expr {1.0/$scale}] $vector]
}

# normalizeStat --
#     Normalize a matrix or vector in a statistical sense and return the result
# Arguments:
#     mv        Matrix or vector to be normalized
# Result:
#     A matrix or vector whose columns are normalised to have a mean of
#     0 and a standard deviation of 1.
#
proc ::math::linearalgebra::normalizeStat { mv } {

    if { [llength [lindex $mv 0]] > 1 } {
        set result {}
        foreach vector [transpose $mv] {
            lappend result [NormalizeStat_vect $vector]
        }
        return [transpose $result]
    } else {
        return [NormalizeStat_vect $mv]
    }
}

# NormalizeStat_vect --
#     Normalize a vector in a statistical sense and return the result
# Arguments:
#     v        Vector to be normalized
# Result:
#     A vector whose elements are normalised to have a mean of
#     0 and a standard deviation of 1. If all coefficients are equal,
#     a null-vector is returned.
#
proc ::math::linearalgebra::NormalizeStat_vect { v } {
    if { [llength $v] <= 1 } {
        return -code error "Vector can not be normalised - too few coefficients"
    }

    set sum   0.0
    set sum2  0.0
    set count 0.0
    foreach c $v {
        set sum   [expr {$sum   + $c}]
        set sum2  [expr {$sum2  + $c*$c}]
        set count [expr {$count + 1.0}]
    }
    set corr   [expr {$sum/$count}]
    set factor [expr {($sum2-$sum*$sum/$count)/($count-1)}]
    if { $factor > 0.0 } {
        set factor [expr {1.0/sqrt($factor)}]
    } else {
        set factor 0.0
    }
    set result {}
    foreach c $v {
        lappend result [expr {$factor*($c-$corr)}]
    }
    return $result
}

# axpy --
#     Compute the sum of a scaled vector/matrix and another
#     vector/matrix: a*x + y
# Arguments:
#     scale      Scale factor (a) for the first vector/matrix
#     mv1        First vector/matrix (x)
#     mv2        Second vector/matrix (y)
# Result:
#     The result of a*x+y
# Level-1 BLAS : if mv1 is a vector, corresponds to DAXPY
#
proc ::math::linearalgebra::axpy { scale mv1 mv2 } {
    if { [llength [lindex $mv1 0]] > 1 } {
        return [axpy_mat $scale $mv1 $mv2]
    } else {
        return [axpy_vect $scale $mv1 $mv2]
    }
}

# axpy_vect --
#     Compute the sum of a scaled vector and another vector: a*x + y
# Arguments:
#     scale      Scale factor (a) for the first vector
#     vect1      First vector (x)
#     vect2      Second vector (y)
# Result:
#     The result of a*x+y
# Level-1 BLAS : corresponds to DAXPY
#
proc ::math::linearalgebra::axpy_vect { scale vect1 vect2 } {
    set result {}

    foreach c1 $vect1 c2 $vect2 {
        lappend result [expr {$scale*$c1+$c2}]
    }
    return $result
}

# axpy_mat --
#     Compute the sum of a scaled matrix and another matrix: a*x + y
# Arguments:
#     scale      Scale factor (a) for the first matrix
#     mat1       First matrix (x)
#     mat2       Second matrix (y)
# Result:
#     The result of a*x+y
#
proc ::math::linearalgebra::axpy_mat { scale mat1 mat2 } {
    set result {}
    foreach row1 $mat1 row2 $mat2 {
        lappend result [axpy_vect $scale $row1 $row2]
    }
    return $result
}

# add --
#     Compute the sum of two vectors/matrices
# Arguments:
#     mv1        First vector/matrix (x)
#     mv2        Second vector/matrix (y)
# Result:
#     The result of x+y
#
proc ::math::linearalgebra::add { mv1 mv2 } {
    if { [llength [lindex $mv1 0]] > 1 } {
        return [add_mat $mv1 $mv2]
    } else {
        return [add_vect $mv1 $mv2]
    }
}

# add_vect --
#     Compute the sum of two vectors
# Arguments:
#     vect1      First vector (x)
#     vect2      Second vector (y)
# Result:
#     The result of x+y
#
proc ::math::linearalgebra::add_vect { vect1 vect2 } {
    set result {}
    foreach c1 $vect1 c2 $vect2 {
        lappend result [expr {$c1+$c2}]
    }
    return $result
}

# add_mat --
#     Compute the sum of two matrices
# Arguments:
#     mat1       First matrix (x)
#     mat2       Second matrix (y)
# Result:
#     The result of x+y
#
proc ::math::linearalgebra::add_mat { mat1 mat2 } {
    set result {}
    foreach row1 $mat1 row2 $mat2 {
        lappend result [add_vect $row1 $row2]
    }
    return $result
}

# sub --
#     Compute the difference of two vectors/matrices
# Arguments:
#     mv1        First vector/matrix (x)
#     mv2        Second vector/matrix (y)
# Result:
#     The result of x-y
#
proc ::math::linearalgebra::sub { mv1 mv2 } {
    if { [llength [lindex $mv1 0]] > 0 } {
        return [sub_mat $mv1 $mv2]
    } else {
        return [sub_vect $mv1 $mv2]
    }
}

# sub_vect --
#     Compute the difference of two vectors
# Arguments:
#     vect1      First vector (x)
#     vect2      Second vector (y)
# Result:
#     The result of x-y
#
proc ::math::linearalgebra::sub_vect { vect1 vect2 } {
    set result {}
    foreach c1 $vect1 c2 $vect2 {
        lappend result [expr {$c1-$c2}]
    }
    return $result
}

# sub_mat --
#     Compute the difference of two matrices
# Arguments:
#     mat1       First matrix (x)
#     mat2       Second matrix (y)
# Result:
#     The result of x-y
#
proc ::math::linearalgebra::sub_mat { mat1 mat2 } {
    set result {}
    foreach row1 $mat1 row2 $mat2 {
        lappend result [sub_vect $row1 $row2]
    }
    return $result
}

# scale --
#     Scale a vector or a matrix
# Arguments:
#     scale      Scale factor (scalar; a)
#     mv         Vector/matrix (x)
# Result:
#     The result of a*x
# Level-1 BLAS : if mv is a vector, corresponds to DSCAL
#
proc ::math::linearalgebra::scale { scale mv } {
    if { [llength [lindex $mv 0]] > 1 } {
        return [scale_mat $scale $mv]
    } else {
        return [scale_vect $scale $mv]
    }
}

# scale_vect --
#     Scale a vector
# Arguments:
#     scale      Scale factor to apply (a)
#     vect       Vector to be scaled (x)
# Result:
#     The result of a*x
# Level-1 BLAS : corresponds to DSCAL
#
proc ::math::linearalgebra::scale_vect { scale vect } {
    set result {}
    foreach c $vect {
        lappend result [expr {$scale*$c}]
    }
    return $result
}

# scale_mat --
#     Scale a matrix
# Arguments:
#     scale      Scale factor to apply
#     mat        Matrix to be scaled
# Result:
#     The result of x+y
#
proc ::math::linearalgebra::scale_mat { scale mat } {
    set result {}
    foreach row $mat {
        lappend result [scale_vect $scale $row]
    }
    return $result
}

# rotate --
#     Apply a planar rotation to two vectors
# Arguments:
#     c          Cosine of the angle
#     s          Sine of the angle
#     vect1      First vector (x)
#     vect2      Second vector (y)
# Result:
#     A list of two elements: c*x-s*y and s*x+c*y
#
proc ::math::linearalgebra::rotate { c s vect1 vect2 } {
    set result1 {}
    set result2 {}
    foreach v1 $vect1 v2 $vect2 {
        lappend result1 [expr {$c*$v1-$s*$v2}]
        lappend result2 [expr {$s*$v1+$c*$v2}]
    }
    return [list $result1 $result2]
}

# transpose --
#     Transpose a matrix
# Arguments:
#     matrix     Matrix to be transposed
# Result:
#     The transposed matrix
# Note:
#     The second transpose implementation is faster on large
#     matrices (100x100 say), there is no significant difference
#     on small ones (10x10 say).
#
#
proc ::math::linearalgebra::transpose_old { matrix } {
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

proc ::math::linearalgebra::transpose { matrix } {
   set transpose {}
   set c 0
   foreach col [lindex $matrix 0] {
       set newrow {}
       foreach row $matrix {
           lappend newrow [lindex $row $c]
       }
       lappend transpose $newrow
       incr c
   }
   return $transpose
}

# MorV --
#     Identify if the object is a row/column vector or a matrix
# Arguments:
#     obj        Object to be examined
# Result:
#     The letter R, C or M depending on the shape
#     (just to make it all work fine: S for scalar)
# Note:
#     Private procedure to fix a bug in matmul
#
proc ::math::linearalgebra::MorV { obj } {
    if { [llength $obj] > 1 } {
        if { [llength [lindex $obj 0]] > 1 } {
            return "M"
        } else {
            return "C"
        }
    } else {
        if { [llength [lindex $obj 0]] > 1 } {
            return "R"
        } else {
            return "S"
        }
    }
}

# matmul --
#     Multiply a vector/matrix with another vector/matrix
# Arguments:
#     mv1        First vector/matrix (x)
#     mv2        Second vector/matrix (y)
# Result:
#     The result of x*y
#
proc ::math::linearalgebra::matmul_org { mv1 mv2 } {
    if { [llength [lindex $mv1 0]] > 1 } {
        if { [llength [lindex $mv2 0]] > 1 } {
            return [matmul_mm $mv1 $mv2]
        } else {
            return [matmul_mv $mv1 $mv2]
        }
    } else {
        if { [llength [lindex $mv2 0]] > 1 } {
            return [matmul_vm $mv1 $mv2]
        } else {
            return [matmul_vv $mv1 $mv2]
        }
    }
}

proc ::math::linearalgebra::matmul { mv1 mv2 } {
    switch -exact -- "[MorV $mv1][MorV $mv2]" {
    "MM" {
         return [matmul_mm $mv1 $mv2]
    }
    "MC" {
         return [matmul_mv $mv1 $mv2]
    }
    "MR" {
         return -code error "Can not multiply a matrix with a row vector - wrong order"
    }
    "RM" {
         return [matmul_vm [transpose $mv1] $mv2]
    }
    "RC" {
         return [dotproduct [transpose $mv1] $mv2]
    }
    "RR" {
         return -code error "Can not multiply a matrix with a row vector - wrong order"
    }
    "CM" {
         return [transpose [matmul_vm $mv1 $mv2]]
    }
    "CR" {
         return [matmul_vv $mv1 [transpose $mv2]]
    }
    "CC" {
         return [matmul_vv $mv1 $mv2]
    }
    "SS" {
        return [expr {$mv1 * $mv2}]
    }
    default {
         return -code error "Can not use a scalar object"
    }
    }
}

# matmul_mv --
#     Multiply a matrix and a column vector
# Arguments:
#     matrix     Matrix (applied left: A)
#     vector     Vector (interpreted as column vector: x)
# Result:
#     The vector A*x
# Level-2 BLAS : corresponds to DTRMV
#
proc ::math::linearalgebra::matmul_mv { matrix vector } {
   set newvect {}
   foreach row $matrix {
      set sum 0.0
      foreach v $vector c $row {
         set sum [expr {$sum+$v*$c}]
      }
      lappend newvect $sum
   }
   return $newvect
}

# matmul_vm --
#     Multiply a row vector with a matrix
# Arguments:
#     vector     Vector (interpreted as row vector: x)
#     matrix     Matrix (applied right: A)
# Result:
#     The vector xtrans*A = Atrans*x
#
proc ::math::linearalgebra::matmul_vm { vector matrix } {
   return [transpose [matmul_mv [transpose $matrix] $vector]]
}

# matmul_vv --
#     Multiply two vectors to obtain a matrix
# Arguments:
#     vect1      First vector (column vector, x)
#     vect2      Second vector (row vector, y)
# Result:
#     The "outer product" x*ytrans
#
proc ::math::linearalgebra::matmul_vv { vect1 vect2 } {
   set newmat {}
   foreach v1 $vect1 {
      set newrow {}
      foreach v2 $vect2 {
         lappend newrow [expr {$v1*$v2}]
      }
      lappend newmat $newrow
   }
   return $newmat
}

# matmul_mm --
#     Multiply two matrices
# Arguments:
#     mat1      First matrix (A)
#     mat2      Second matrix (B)
# Result:
#     The matrix product A*B
# Note:
#     By transposing matrix B we can access the columns
#     as rows - much easier and quicker, as they are
#     the elements of the outermost list.
# Level-3 BLAS :
#     corresponds to DGEMM (alpha op(A) op(B) + beta C) when alpha=1, op(X)=X and beta=0
#     corresponds to DTRMM (alpha op(A) B) when alpha = 1, op(X)=X
#
proc ::math::linearalgebra::matmul_mm { mat1 mat2 } {
   set newmat {}
   set tmat [transpose $mat2]
   foreach row1 $mat1 {
      set newrow {}
      foreach row2 $tmat {
         lappend newrow [dotproduct $row1 $row2]
      }
      lappend newmat $newrow
   }
   return $newmat
}

# mkVector --
#     Make a vector of a given size
# Arguments:
#     ndim       Dimension of the vector
#     value      Default value for all elements (default: 0.0)
# Result:
#     A list with ndim elements, representing a vector
#
proc ::math::linearalgebra::mkVector { ndim {value 0.0} } {
    set result {}

    while { $ndim > 0 } {
        lappend result $value
        incr ndim -1
    }
    return $result
}

# mkUnitVector --
#     Make a unit vector in a given direction
# Arguments:
#     ndim       Dimension of the vector
#     dir        The direction (0, ... ndim-1)
# Result:
#     A list with ndim elements, representing a unit vector
#
proc ::math::linearalgebra::mkUnitVector { ndim dir } {

    if { $dir < 0 || $dir >= $ndim } {
        return -code error "Invalid direction for unit vector - $dir"
    } else {
        set result [mkVector $ndim]
        lset result $dir 1.0
    }
    return $result
}

# mkMatrix --
#     Make a matrix of a given size
# Arguments:
#     nrows      Number of rows
#     ncols      Number of columns
#     value      Default value for all elements (default: 0.0)
# Result:
#     A nested list, representing an nrows x ncols matrix
#
proc ::math::linearalgebra::mkMatrix { nrows ncols {value 0.0} } {
    set result {}

    while { $nrows > 0 } {
        lappend result [mkVector $ncols $value]
        incr nrows -1
    }
    return $result
}

# mkIdent --
#     Make an identity matrix of a given size
# Arguments:
#     size       Number of rows/columns
# Result:
#     A nested list, representing an size x size identity matrix
#
proc ::math::linearalgebra::mkIdentity { size } {
    set result [mkMatrix $size $size 0.0]

    while { $size > 0 } {
        incr size -1
        lset result $size $size 1.0
    }
    return $result
}

# mkDiagonal --
#     Make a diagonal matrix of a given size
# Arguments:
#     diag       List of values to appear on the diagonal
#
# Result:
#     A nested list, representing a diagonal matrix
#
proc ::math::linearalgebra::mkDiagonal { diag } {
    set size   [llength $diag]
    set result [mkMatrix $size $size 0.0]

    while { $size > 0 } {
        incr size -1
        lset result $size $size [lindex $diag $size]
    }
    return $result
}

# mkHilbert --
#     Make a Hilbert matrix of a given size
# Arguments:
#     size       Size of the matrix
# Result:
#     A nested list, representing a Hilbert matrix
# Notes:
#     Hilbert matrices are very ill-conditioned wrt
#     eigenvalue/eigenvector problems. Therefore they
#     are good candidates for testing the accuracy
#     of algorithms and implementations.
#
proc ::math::linearalgebra::mkHilbert { size } {
    set result {}
    for { set j 0 } { $j < $size } { incr j } {
        set row {}
        for { set i 0 } { $i < $size } { incr i } {
            lappend row [expr {1.0/($i+$j+1.0)}]
        }
        lappend result $row
    }
    return $result
}

# mkDingdong --
#     Make a Dingdong matrix of a given size
# Arguments:
#     size       Size of the matrix
# Result:
#     A nested list, representing a Dingdong matrix
# Notes:
#     Dingdong matrices are imprecisely represented,
#     but have the property of being very stable in
#     such algorithms as Gauss elimination.
#
proc ::math::linearalgebra::mkDingdong { size } {
    set result {}
    for { set j 0 } { $j < $size } { incr j } {
        set row {}
        for { set i 0 } { $i < $size } { incr i } {
            lappend row [expr {0.5/($size-$i-$j-0.5)}]
        }
        lappend result $row
    }
    return $result
}

# mkOnes --
#     Make a square matrix consisting of ones
# Arguments:
#     size       Number of rows/columns
# Result:
#     A nested list, representing a size x size matrix,
#     filled with 1.0
#
proc ::math::linearalgebra::mkOnes { size } {
    return [mkMatrix $size $size 1.0]
}

# mkMoler --
#     Make a Moler matrix
# Arguments:
#     size       Size of the matrix
# Result:
#     A nested list, representing a Moler matrix
# Notes:
#     Moler matrices have a very simple Choleski
#     decomposition. It has one small eigenvalue
#     and it can easily upset elimination methods
#     for systems of linear equations
#
proc ::math::linearalgebra::mkMoler { size } {
    set result {}
    for { set j 0 } { $j < $size } { incr j } {
        set row {}
        for { set i 0 } { $i < $size } { incr i } {
            if { $i == $j } {
                lappend row [expr {$i+1}]
            } else {
                lappend row [expr {($i>$j?$j:$i)-1.0}]
            }
        }
        lappend result $row
    }
    return $result
}

# mkFrank --
#     Make a Frank matrix
# Arguments:
#     size       Size of the matrix
# Result:
#     A nested list, representing a Frank matrix
#
proc ::math::linearalgebra::mkFrank { size } {
    set result {}
    for { set j 0 } { $j < $size } { incr j } {
        set row {}
        for { set i 0 } { $i < $size } { incr i } {
            lappend row [expr {($i>$j?$j:$i)-2.0}]
        }
        lappend result $row
    }
    return $result
}

# mkBorder --
#     Make a bordered matrix
# Arguments:
#     size       Size of the matrix
# Result:
#     A nested list, representing a bordered matrix
# Note:
#     This matrix has size-2 eigenvalues at 1.
#
proc ::math::linearalgebra::mkBorder { size } {
    set result {}
    for { set j 0 } { $j < $size } { incr j } {
        set row {}
        for { set i 0 } { $i < $size } { incr i } {
            set entry 0.0
            if { $i == $j } {
                set entry 1.0
            } elseif { $j != $size-1 && $i == $size-1 } {
                set entry [expr {pow(2.0,-$j)}]
            } elseif { $i != $size-1 && $j == $size-1 } {
                set entry [expr {pow(2.0,-$i)}]
            } else {
                set entry 0.0
            }
            lappend row $entry
        }
        lappend result $row
    }
    return $result
}

# mkWilkinsonW+ --
#     Make a Wilkinson W+ matrix
# Arguments:
#     size       Size of the matrix
# Result:
#     A nested list, representing a Wilkinson W+ matrix
# Note:
#     This kind of matrix has pairs of eigenvalues that
#     are very close together. Usually the order is odd.
#
proc ::math::linearalgebra::mkWilkinsonW+ { size } {
    set result {}
    for { set j 0 } { $j < $size } { incr j } {
        set row {}
        for { set i 0 } { $i < $size } { incr i } {
            if { $i == $j } {
                # int(n/2) + 1 - min(i,n-i+1)
                set min   [expr {(($i+1)>$size-($i+1)+1? $size-($i+1)+1 : ($i+1))}]
                set entry [expr {int($size/2) + 1 - $min}]
            } elseif { $i == $j+1 || $i+1 == $j } {
                set entry 1
            } else {
                set entry 0.0
            }
            lappend row $entry
        }
        lappend result $row
    }
    return $result
}

# mkWilkinsonW- --
#     Make a Wilkinson W- matrix
# Arguments:
#     size       Size of the matrix
# Result:
#     A nested list, representing a Wilkinson W- matrix
# Note:
#     This kind of matrix has pairs of eigenvalues with
#     opposite signs (if the order is odd).
#
proc ::math::linearalgebra::mkWilkinsonW- { size } {
    set result {}
    for { set j 0 } { $j < $size } { incr j } {
        set row {}
        for { set i 0 } { $i < $size } { incr i } {
            if { $i == $j } {
                set entry [expr {int($size/2) + 1 - ($i+1)}]
            } elseif { $i == $j+1 || $i+1 == $j } {
                set entry 1
            } else {
                set entry 0.0
            }
            lappend row $entry
        }
        lappend result $row
    }
    return $result
}
# mkRandom --
#     Make a square matrix consisting of random numbers
# Arguments:
#     size       Number of rows/columns
# Result:
#     A nested list, representing a size x size matrix,
#     filled with random numbers
#
proc ::math::linearalgebra::mkRandom { size } {
    set result {}
    for { set j 0 } { $j < $size } { incr j } {
        set row {}
        for { set i 0 } { $i < $size } { incr i } {
            lappend row [expr {rand()}]
        }
        lappend result $row
    }
    return $result
}
# mkTriangular --
#     Make a triangular matrix consisting of a constant
# Arguments:
#     size       Number of rows/columns
#     uplo       U if the matrix is upper triangular (default), L if the
#                matrix is lower triangular.
#     value      Default value for all elements (default: 0.0)
# Result:
#     A nested list, representing a size x size matrix,
#     filled with random numbers
#
proc ::math::linearalgebra::mkTriangular { size {uplo "U"} {value 1.0}} {
    switch -- $uplo {
        "U" {
            set result {}
            for { set j 0 } { $j < $size } { incr j } {
                set row {}
                for { set i 0 } { $i < $size } { incr i } {
                    if {$i<$j} then {
                        lappend row 0.
                    } else {
                        lappend row $value
                    }
                }
                lappend result $row
            }
        }
        "L" {
            set result {}
            for { set j 0 } { $j < $size } { incr j } {
                set row {}
                for { set i 0 } { $i < $size } { incr i } {
                    if {$i>$j} then {
                        lappend row 0.
                    } else {
                        lappend row $value
                    }
                }
                lappend result $row
            }
        }
        default {
            error "Unknown value for parameter uplo : $uplo"
        }
    }
    return $result
}

# getrow --
#     Get the specified row from a matrix
# Arguments:
#     matrix     Matrix in question
#     row        Index of the row
#     imin       Minimum index of the column (default 0)
#     imax       Maximum index of the column (default ncols-1)
#
# Result:
#     A list with the values on the requested row
#
proc ::math::linearalgebra::getrow { matrix row {imin 0} {imax ""}} {
    if {$imax==""} then {
        foreach {nrows ncols} [shape $matrix] {break}
        if {$ncols==""} then {
            # the matrix is a vector
            set imax 0
        } else {
            set imax [expr {$ncols - 1}]
        }
    }
    set row [lindex $matrix $row]
    return [lrange $row $imin $imax]
}

# setrow --
#     Set the specified row in a matrix
# Arguments:
#     matrix     _Name_ of matrix in question
#     row        Index of the row
#     newvalues  New values for the row
#     imin       Minimum column index (default 0)
#     imax       Maximum column index (default ncols-1)
#
# Result:
#     Updated matrix
# Side effect:
#     The matrix is updated
#
proc ::math::linearalgebra::setrow { matrix row newvalues {imin 0} {imax ""}} {
    upvar $matrix mat
    if {$imax==""} then {
        foreach {nrows ncols} [shape $mat] {break}
        if {$ncols==""} then {
            # the matrix is a vector
            set imax 0
        } else {
            set imax [expr {$ncols - 1}]
        }
    }
    set icol $imin
    foreach value $newvalues {
        lset mat $row $icol $value
        incr icol
        if {$icol>$imax} then {
            break
        }
    }
    return $mat
}

# getcol --
#     Get the specified column from a matrix
# Arguments:
#     matrix     Matrix in question
#     col        Index of the column
#     imin       Minimum row index (default 0)
#     imax       Minimum row index (default nrows-1)
#
# Result:
#     A list with the values on the requested column
#
proc ::math::linearalgebra::getcol { matrix col {imin 0} {imax ""}} {
    if {$imax==""} then {
        set nrows [llength $matrix]
        set imax [expr {$nrows - 1}]
    }
    set result {}
    set iline 0
    foreach row $matrix {
        if {$iline>=$imin && $iline<=$imax} then {
            lappend result [lindex $row $col]
        }
        incr iline
    }
    return $result
}

# setcol --
#     Set the specified column in a matrix
# Arguments:
#     matrix     _Name_ of matrix in question
#     col        Index of the column
#     newvalues  New values for the column
#     imin       Minimum row index (default 0)
#     imax       Minimum row index (default nrows-1)
#
# Result:
#     Updated matrix
# Side effect:
#     The matrix is updated
#
proc ::math::linearalgebra::setcol { matrix col newvalues  {imin 0} {imax ""}} {
    upvar $matrix mat
    if {$imax==""} then {
        set nrows [llength $mat]
        set imax [expr {$nrows - 1}]
    }
    set index 0
    for { set i $imin } { $i <= $imax } { incr i } {
        lset mat $i $col [lindex $newvalues $index]
        incr index
    }
    return $mat
}

# getelem --
#     Get the specified element (row,column) from a matrix/vector
# Arguments:
#     matrix     Matrix in question
#     row        Index of the row
#     col        Index of the column (not present for vectors)
#
# Result:
#     The matrix element (row,column)
#
proc ::math::linearalgebra::getelem { matrix row {col {}} } {
    if { $col != {} } {
        lindex $matrix $row $col
    } else {
        lindex $matrix $row
    }
}

# setelem --
#     Set the specified element (row,column) in a matrix or vector
# Arguments:
#     matrix     _Name_ of matrix/vector in question
#     row        Index of the row
#     col        Index of the column/new value
#     newvalue   New value  for the element (not present for vectors)
#
# Result:
#     Updated matrix
# Side effect:
#     The matrix is updated
#
proc ::math::linearalgebra::setelem { matrix row col {newvalue {}} } {
    upvar $matrix mat
    if { $newvalue != {} } {
        lset mat $row $col $newvalue
    } else {
        lset mat $row $col
    }
    return $mat
}
# swaprows --
#     Swap two rows of a matrix
# Arguments:
#     matrix     Matrix defining the coefficients
#     irow1      Index of first row
#     irow2      Index of second row
#     imin       Minimum column index (default 0)
#     imax       Maximum column index (default ncols-1)
#
# Result:
#     The matrix with the two rows swaped.
#
proc ::math::linearalgebra::swaprows { matrix irow1 irow2 {imin 0} {imax ""}} {
    upvar $matrix mat
    #swaprows1 mat $irow1 $irow2 $imin $imax
    swaprows2 mat $irow1 $irow2 $imin $imax
}
proc ::math::linearalgebra::swaprows1 { matrix irow1 irow2 {imin 0} {imax ""}} {
    upvar $matrix mat
    if {$imax==""} then {
        foreach {nrows ncols} [shape $mat] {break}
        if {$ncols==""} then {
            # the matrix is a vector
            set imax 0
        } else {
            set imax [expr {$ncols - 1}]
        }
    }
    set row1 [getrow $mat $irow1 $imin $imax]
    set row2 [getrow $mat $irow2 $imin $imax]
    setrow mat $irow1 $row2 $imin $imax
    setrow mat $irow2 $row1 $imin $imax
    return $mat
}
proc ::math::linearalgebra::swaprows2 { matrix irow1 irow2 {imin 0} {imax ""}} {
    upvar $matrix mat
    if {$imax==""} then {
        foreach {nrows ncols} [shape $mat] {break}
        if {$ncols==""} then {
            # the matrix is a vector
            set imax 0
        } else {
            set imax [expr {$ncols - 1}]
        }
    }
    set row1 [lrange [lindex $mat $irow1] $imin $imax]
    set row2 [lrange [lindex $mat $irow2] $imin $imax]
    setrow mat $irow1 $row2 $imin $imax
    setrow mat $irow2 $row1 $imin $imax
    return $mat
}
# swapcols --
#     Swap two cols of a matrix
# Arguments:
#     matrix     Matrix defining the coefficients
#     icol1      Index of first column
#     icol2      Index of second column
#     imin       Minimum row index (default 0)
#     imax       Minimum row index (default nrows-1)
#
# Result:
#     The matrix with the two columns swaped.
#
proc ::math::linearalgebra::swapcols { matrix icol1 icol2 {imin 0} {imax ""}} {
    upvar $matrix mat
    if {$imax==""} then {
        set nrows [llength $mat]
        set imax [expr {$nrows - 1}]
    }
    set col1 [getcol $mat $icol1 $imin $imax]
    set col2 [getcol $mat $icol2 $imin $imax]
    setcol mat $icol1 $col2 $imin $imax
    setcol mat $icol2 $col1 $imin $imax
    return $mat
}

# solveGauss --
#     Solve a system of linear equations using Gauss elimination
# Arguments:
#     matrix     Matrix defining the coefficients
#     bvect      Right-hand side (may be several columns)
#
# Result:
#     Solution of the system or an error in case of singularity
# LAPACK : corresponds to DGETRS, without row interchanges
#
proc ::math::linearalgebra::solveGauss { matrix bvect } {
    set norows [llength $matrix]
    set nocols $norows

    for { set i 0 } { $i < $nocols } { incr i } {
        set sweep_row   [getrow $matrix $i]
        set bvect_sweep [getrow $bvect  $i]
        # No pivoting yet
        set sweep_fact  [expr {double([lindex $sweep_row $i])}]
        for { set j [expr {$i+1}] } { $j < $norows } { incr j } {
            set current_row   [getrow $matrix $j]
            set bvect_current [getrow $bvect  $j]
            set factor      [expr {-[lindex $current_row $i]/$sweep_fact}]

            lset matrix $j [axpy_vect $factor $sweep_row   $current_row]
            lset bvect  $j [axpy_vect $factor $bvect_sweep $bvect_current]
        }
    }

    return [solveTriangular $matrix $bvect]
}
# solvePGauss --
#     Solve a system of linear equations using Gauss elimination
#     with partial pivoting
# Arguments:
#     matrix     Matrix defining the coefficients
#     bvect      Right-hand side (may be several columns)
#
# Result:
#     Solution of the system or an error in case of singularity
# LAPACK : corresponds to DGETRS
#
proc ::math::linearalgebra::solvePGauss { matrix bvect } {

    set ipiv [dgetrf matrix]
    set norows [llength $matrix]
    set nm1 [expr {$norows - 1}]

    # Perform all permutations on b
    for { set k 0 } { $k < $nm1 } { incr k } {
        # Swap b(k) and b(mu) with mu = P(k)
        set tmp [lindex $bvect $k]
        set mu [lindex $ipiv $k]
        setrow bvect $k [lindex $bvect $mu]
        setrow bvect $mu $tmp
    }

    # Perform forward substitution
    for { set k 0 } { $k < $nm1 } { incr k } {
        set bk [lindex $bvect $k]
        # Substitution
        for { set iline [expr {$k+1}] } { $iline < $norows } { incr iline } {
            set aik [lindex $matrix $iline $k]
            set maik [expr {-1. * $aik}]
            set bi [lindex $bvect $iline]
            setrow bvect $iline [axpy $maik $bk $bi]
        }
    }

    # Perform backward substitution
    return [solveTriangular $matrix $bvect]
}

# solveTriangular --
#     Solve a system of linear equations where the matrix is
#     upper-triangular
# Arguments:
#     matrix     Matrix defining the coefficients
#     bvect      Right-hand side (may be several columns)
#     uplo       U if the matrix is upper triangular (default), L if the
#                matrix is lower triangular.
#
# Result:
#     Solution of the system or an error in case of singularity
# LAPACK : corresponds to DTPTRS, but in the current command, the matrix
#          is in regular format (unpacked).
#
proc ::math::linearalgebra::solveTriangular { matrix bvect {uplo "U"}} {
    set norows [llength $matrix]
    set nocols $norows

    switch -- $uplo {
        "U" {
            for { set i [expr {$norows-1}] } { $i >= 0 } { incr i -1 } {
                set sweep_row   [getrow $matrix $i]
                set bvect_sweep [getrow $bvect  $i]
                set sweep_fact  [expr {double([lindex $sweep_row $i])}]
                set norm_fact   [expr {1.0/$sweep_fact}]

                lset bvect $i [scale $norm_fact $bvect_sweep]

                for { set j [expr {$i-1}] } { $j >= 0 } { incr j -1 } {
                    set current_row   [getrow $matrix $j]
                    set bvect_current [getrow $bvect  $j]
                    set factor     [expr {-[lindex $current_row $i]/$sweep_fact}]

                    lset bvect  $j [axpy_vect $factor $bvect_sweep $bvect_current]
                }
            }
        }
        "L" {
            for { set i 0 } { $i < $norows } { incr i } {
                set sweep_row   [getrow $matrix $i]
                set bvect_sweep [getrow $bvect  $i]
                set sweep_fact  [expr {double([lindex $sweep_row $i])}]
                set norm_fact   [expr {1.0/$sweep_fact}]

                lset bvect $i [scale $norm_fact $bvect_sweep]

                for { set j 0 } { $j < $i } { incr j } {
                set bvect_current [getrow $bvect  $i]
                    set bvect_sweep [getrow $bvect  $j]
                    set factor [lindex $sweep_row $j]
                    set factor [expr { -1. * $factor * $norm_fact }]
                    lset bvect  $i [axpy_vect $factor $bvect_sweep $bvect_current]
                }
            }
        }
        default {
            error "Unknown value for parameter uplo : $uplo"
        }
    }
    return $bvect
}

# solveGaussBand --
#     Solve a system of linear equations using Gauss elimination,
#     where the matrix is stored as a band matrix.
# Arguments:
#     matrix     Matrix defining the coefficients (in band form)
#     bvect      Right-hand side (may be several columns)
#
# Result:
#     Solution of the system or an error in case of singularity
#
proc ::math::linearalgebra::solveGaussBand { matrix bvect } {
    set norows   [llength $matrix]
    set nocols   $norows
    set nodiags  [llength [lindex $matrix 0]]
    set lowdiags [expr {($nodiags-1)/2}]

    for { set i 0 } { $i < $nocols } { incr i } {
        set sweep_row   [getrow $matrix $i]
        set bvect_sweep [getrow $bvect  $i]

        set sweep_fact [lindex $sweep_row [expr {$lowdiags-$i}]]

        for { set j [expr {$i+1}] } { $j <= $lowdiags } { incr j } {
            set sweep_row     [concat [lrange $sweep_row 1 end] 0.0]
            set current_row   [getrow $matrix $j]
            set bvect_current [getrow $bvect  $j]
            set factor      [expr {-[lindex $current_row $i]/$sweep_fact}]

            lset matrix $j [axpy_vect $factor $sweep_row   $current_row]
            lset bvect  $j [axpy_vect $factor $bvect_sweep $bvect_current]
        }
    }

    return [solveTriangularBand $matrix $bvect]
}

# solveTriangularBand --
#     Solve a system of linear equations where the matrix is
#     upper-triangular (stored as a band matrix)
# Arguments:
#     matrix     Matrix defining the coefficients (in band form)
#     bvect      Right-hand side (may be several columns)
#
# Result:
#     Solution of the system or an error in case of singularity
#
proc ::math::linearalgebra::solveTriangularBand { matrix bvect } {
    set norows   [llength $matrix]
    set nocols   $norows
    set nodiags  [llength [lindex $matrix 0]]
    set uppdiags [expr {($nodiags-1)/2}]
    set middle   [expr {($nodiags-1)/2}]

    for { set i [expr {$norows-1}] } { $i >= 0 } { incr i -1 } {
        set sweep_row   [getrow $matrix $i]
        set bvect_sweep [getrow $bvect  $i]
        set sweep_fact  [lindex $sweep_row $middle]
        set norm_fact   [expr {1.0/$sweep_fact}]

        lset bvect $i [scale $norm_fact $bvect_sweep]

        for { set j [expr {$i-1}] } { $j >= $i-$middle && $j >= 0 } \
                { incr j -1 } {
            set current_row   [getrow $matrix $j]
            set bvect_current [getrow $bvect  $j]
            set k             [expr {$i-$middle}]
            set factor     [expr {-[lindex $current_row $k]/$sweep_fact}]

            lset bvect  $j [axpy_vect $factor $bvect_sweep $bvect_current]
        }
    }

    return $bvect
}

# determineSVD --
#     Determine the singular value decomposition of a matrix
# Arguments:
#     A          Matrix to be examined
#     epsilon    Tolerance for the procedure (defaults to 2.3e-16)
#
# Result:
#     List of the three elements U, S and V, where:
#     U, V orthogonal matrices, S a diagonal matrix (here a vector)
#     such that A = USVt
# Note:
#     This is taken directly from Hume's LA package, and adjusted
#     to fit the different matrix format. Also changes are applied
#     that can be found in the second edition of Nash's book
#     "Compact numerical methods for computers"
#
#     To be done: transpose the algorithm so that we can work
#     on rows, rather than columns
#
proc ::math::linearalgebra::determineSVD { A {epsilon 2.3e-16} } {
    foreach {m n} [shape $A] {break}
    set tolerance [expr {$epsilon * $epsilon* $m * $n}]
    set V [mkIdentity $n]

    #
    # Top of the iteration
    #
    set count 1
    for {set isweep 0} {$isweep < 30 && $count > 0} {incr isweep} {
        set count [expr {$n*($n-1)/2}] ;# count of rotations in a sweep
        for {set j 0} {$j < [expr {$n-1}]} {incr j} {
            for {set k [expr {$j+1}]} {$k < $n} {incr k} {
                set p [set q [set r 0.0]]
                for {set i 0} {$i < $m} {incr i} {
                    set Aij [lindex $A $i $j]
                    set Aik [lindex $A $i $k]
                    set p [expr {$p + $Aij*$Aik}]
                    set q [expr {$q + $Aij*$Aij}]
                    set r [expr {$r + $Aik*$Aik}]
                }
                if { $q < $r } {
                    set c 0.0
                    set s 1.0
                } elseif { $q * $r == 0.0 } {
                    # Underflow of small elements
                    incr count -1
                    continue
                } elseif { ($p*$p)/($q*$r) < $tolerance } {
                    # Cols j,k are orthogonal
                    incr count -1
                    continue
                } else {
                    set q [expr {$q-$r}]
                    set v [expr {sqrt(4.0*$p*$p + $q*$q)}]
                    set c [expr {sqrt(($v+$q)/(2.0*$v))}]
                    set s [expr {-$p/($v*$c)}]
                    # s == sine of rotation angle, c == cosine
                    # Note: -s in comparison with original LA!
                }
                #
                # Rotation of A
                #
                set colj [getcol $A $j]
                set colk [getcol $A $k]
                foreach {colj colk} [rotate $c $s $colj $colk] {break}
                setcol A $j $colj
                setcol A $k $colk
                #
                # Rotation of V
                #
                set colj [getcol $V $j]
                set colk [getcol $V $k]
                foreach {colj colk} [rotate $c $s $colj $colk] {break}
                setcol V $j $colj
                setcol V $k $colk
            } ;#k
        } ;# j
        #puts "pass=$isweep skipped rotations=$count"
    } ;# isweep

    set S {}
    for {set j 0} {$j < $n} {incr j} {
        set q [norm_two [getcol $A $j]]
        lappend S $q
        if { $q >= $tolerance } {
            set newcol [scale [expr {1.0/$q}] [getcol $A $j]]
            setcol A $j $newcol
        }
    } ;# j

    #
    # Prepare the output
    #
    set U $A

    if { $m < $n } {
        set U {}
        incr m -1
        foreach row $A {
            lappend U [lrange $row 0 $m]
        }
        #puts $U
    }
    return [list $U $S $V]
}

# eigenvectorsSVD --
#     Determine the eigenvectors and eigenvalues of a real
#     symmetric matrix via the SVD
# Arguments:
#     A          Matrix to be examined
#     eps        Tolerance for the procedure (defaults to 2.3e-16)
#
# Result:
#     List of the matrix of eigenvectors and the vector of corresponding
#     eigenvalues
# Note:
#     This is taken directly from Hume's LA package, and adjusted
#     to fit the different matrix format. Also changes are applied
#     that can be found in the second edition of Nash's book
#     "Compact numerical methods for computers"
#
proc ::math::linearalgebra::eigenvectorsSVD { A {eps 2.3e-16} } {
    foreach {m n} [shape $A] {break}
    if { $m != $n } {
       return -code error "Expected a square matrix"
    }

    #
    # Determine the shift h so that the matrix A+hI is positive
    # definite (the Gershgorin region)
    #
    set h {}
    set i 0
    foreach row $A {
        set aii [lindex $row $i]
        set sum [expr {$aii + abs($aii) - [norm_one $row]}]
        incr i

        if { $h == {} || $sum < $h } {
            set h $sum
        }
    }
    if { $h <= $eps } {
        set h [expr {$h - sqrt($eps)}]
        # try to make smallest eigenvalue positive and not too small
        set A [sub $A [scale_mat $h [mkIdentity $m]]]
    } else {
        set h 0.0
    }

    #
    # Determine the SVD decomposition: this holds the
    # eigenvectors and eigenvalues
    #
    foreach {U S V} [determineSVD $A $eps] {break}

    #
    # Rescale and flip signs if all negative or zero
    #
    for {set j 0} {$j < $n} {incr j} {
        set s 0.0
        set notpositive 0
        for {set i 0} {$i < $n} {incr i} {
            set Uij [lindex $U $i $j]
            if { $Uij <= 0.0 } {
               incr notpositive
            }
            set s [expr {$s + $Uij*$Uij}]
        }
        set s [expr {sqrt($s)}]
        if { $notpositive == $n } {
            set sf [expr {-$s}]
        } else {
            set sf $s
        }
        set colv [getcol $U $j]
        setcol U $j [scale_vect [expr {1.0/$sf}] $colv]
    }
    for {set j 0} {$j < $n} {incr j} {
        lset S $j [expr {[lindex $S $j] + $h}]
    }
    return [list $U $S]
}

# leastSquaresSVD --
#     Determine the solution to the least-squares problem Ax ~ y
#     via the singular value decomposition
# Arguments:
#     A          Matrix to be examined
#     y          Dependent variable
#     qmin       Minimum singular value to be considered (defaults to 0)
#     epsilon    Tolerance for the procedure (defaults to 2.3e-16)
#
# Result:
#     Vector x as the solution of the least-squares problem
#
proc ::math::linearalgebra::leastSquaresSVD { A y {qmin 0.0} {epsilon 2.3e-16} } {

    foreach {m n} [shape $A] {break}
    foreach {U S V} [determineSVD $A $epsilon] {break}

    set tol [expr {$epsilon * $epsilon * $n * $n}]
    #
    # form Utrans*y into g
    #
    set g {}
    for {set j 0} {$j < $n} {incr j} {
        set s 0.0
        for {set i 0} {$i < $m} {incr i} {
            set Uij [lindex $U $i $j]
            set yi  [lindex $y $i]
            set s [expr {$s + $Uij*$yi}]
        }
        lappend g $s ;# g[j] = $s
    }

    #
    # form VS+g = VS+Utrans*g
    #
    set x {}
    for {set j 0} {$j < $n} {incr j} {
        set s 0.0
        for {set i 0} {$i < $n} {incr i} {
            set zi [lindex $S $i]
            if { $zi > $qmin } {
                set Vji [lindex $V $j $i]
                set gi  [lindex $g $i]
                set s   [expr {$s + $Vji*$gi/$zi}]
            }
        }
        lappend x $s
    }
    return $x
}

# choleski --
#     Determine the Choleski decomposition of a symmetric,
#     positive-semidefinite matrix (this condition is not checked!)
#
# Arguments:
#     matrix     Matrix to be treated
#
# Result:
#     Lower-triangular matrix (L) representing the Choleski decomposition:
#        L Lt = matrix
#
proc ::math::linearalgebra::choleski { matrix } {
    foreach {rows cols} [shape $matrix] {break}

    set result $matrix

    for { set j 0 } { $j < $cols } { incr j } {
        if { $j > 0 } {
            for { set i $j } { $i < $cols } { incr i } {
                set sum [lindex $result $i $j]
                for { set k 0 } { $k <= $j-1 } { incr k } {
                    set Aki [lindex $result $i $k]
                    set Akj [lindex $result $j $k]
                    set sum [expr {$sum-$Aki*$Akj}]
                }
                lset result $i $j $sum
            }
        }

        #
        # Take care of a singular matrix
        #
        if { [lindex $result $j $j] <= 0.0 } {
            lset result $j $j 0.0
        }

        #
        # Scale the column
        #
        set s [expr {sqrt([lindex $result $j $j])}]
        for { set i 0 } { $i < $cols } { incr i } {
            if { $i >= $j } {
                if { $s == 0.0 } {
                    lset result $i $j 0.0
                } else {
                    lset result $i $j [expr {[lindex $result $i $j]/$s}]
                }
            } else {
                lset result $i $j 0.0
            }
        }
    }

    return $result
}

# orthonormalizeColumns --
#     Orthonormalize the columns of a matrix, using the modified
#     Gram-Schmidt method
# Arguments:
#     matrix     Matrix to be treated
#
# Result:
#     Matrix with pairwise orthogonal columns, each having length 1
#
proc ::math::linearalgebra::orthonormalizeColumns { matrix } {
    transpose [orthonormalizeRows [transpose $matrix]]
}

# orthonormalizeRows --
#     Orthonormalize the rows of a matrix, using the modified
#     Gram-Schmidt method
# Arguments:
#     matrix     Matrix to be treated
#
# Result:
#     Matrix with pairwise orthogonal rows, each having length 1
#
proc ::math::linearalgebra::orthonormalizeRows { matrix } {
    set result $matrix
    set rowno  0
    foreach r $matrix {
        set newrow [unitLengthVector [getrow $result $rowno]]
        setrow result $rowno $newrow
        incr rowno
        set  rowno2 $rowno

        #
        # Update the matrix immediately: this is numerically
        # more stable
        #
        foreach nextrow [lrange $result $rowno end] {
            set factor  [dotproduct $newrow $nextrow]
            set nextrow [sub_vect $nextrow [scale_vect $factor $newrow]]
            setrow result $rowno2 $nextrow
            incr rowno2
        }
    }
    return $result
}

# dger --
#     Performs the rank 1 operation alpha*x*y' + A
# Arguments:
#     matrix     name of the matrix to process (the matrix must be square)
#     alpha      a real value
#     x          a vector
#     y          a vector
#     scope      if not provided, the operation is performed on all rows/columns of A
#                if provided, it is expected to be the list [list imin imax jmin jmax]
#                where :
#                imin       Minimum  row index
#                imax       Maximum  row index
#                jmin       Minimum  column index
#                jmax       Maximum  column index
#
# Result:
#     Updated matrix
# Level-3 BLAS : corresponds to DGER
#
proc ::math::linearalgebra::dger { matrix alpha x y {scope ""}} {
    upvar $matrix mat
    set nrows [llength $mat]
    set ncols $nrows
    if {$scope==""} then {
        set imin 0
        set imax [expr {$nrows - 1}]
        set jmin 0
        set jmax [expr {$ncols - 1}]
    } else {
        foreach {imin imax jmin jmax} $scope {break}
    }
    set xy [matmul $x $y]
    set alphaxy [scale $alpha $xy]
    for { set iline $imin } { $iline <= $imax } { incr iline } {
        set ilineshift [expr {$iline - $imin}]
        set matiline [lindex $mat $iline]
        set alphailine [lindex $alphaxy $ilineshift]
        for { set icol $jmin } { $icol <= $jmax } { incr icol } {
            set icolshift [expr {$icol - $jmin}]
            set aij [lindex $matiline $icol]
            set shift [lindex $alphailine $icolshift]
            setelem mat $iline $icol [expr {$aij + $shift}]
        }
    }
    return $mat
}
# dgetrf --
#     Computes an LU factorization of a general matrix, using partial,
#     pivoting with row interchanges.
#
# Arguments:
#     matrix     On entry, the matrix to be factored.
#                On exit, the factors L and U from the factorization
#                P*A = L*U; the unit diagonal elements of L are not stored.
#
# Result:
#     Returns the permutation vector, as a list of length n-1.
#     The last entry of the permutation is not stored, since it is
#     implicitely known, with value n (the last row is not swapped
#     with any other row).
#     At index #i of the permutation is stored the index of the row #j
#     which is swapped with row #i at step #i. That means that each
#     index of the permutation gives the permutation at each step, not the
#     cumulated permutation matrix, which is the product of permutations.
#     The factorization has the form
#        P * A = L * U
#     where P is a permutation matrix, L is lower triangular with unit
#     diagonal elements, and U is upper triangular.
#
# LAPACK : corresponds to DGETRF
#
proc ::math::linearalgebra::dgetrf { matrix } {
    upvar $matrix mat
    set norows [llength $mat]
    set nocols $norows

    # Initialize permutation
    set nm1 [expr {$norows - 1}]
    set ipiv {}
    # Perform Gauss transforms
    for { set k 0 } { $k < $nm1 } { incr k } {
        # Search pivot in column n, from lines k to n
        set column [getcol $mat $k $k $nm1]
        foreach {abspivot murel} [norm_max $column 1] {break}
        # Shift mu, because max returns with respect to the column (k:n,k)
        set mu [expr {$murel + $k}]
        # Swap lines k and mu from columns 1 to n
        swaprows mat $k $mu
        set akk [lindex $mat $k $k]
        # Store permutation
        lappend ipiv $mu
        # Store pivots for lines k+1 to n in columns k+1 to n
        set kp1 [expr {$k+1}]
        set akp1 [getcol $mat $k $kp1 $nm1]
        set mult [expr {1. / double($akk)}]
        set akp1 [scale $mult $akp1]
        setcol mat $k $akp1 $kp1 $nm1
        # Perform transform for lines k+1 to n
        set akp1k [getcol $mat $k $kp1 $nm1]
        set akkp1 [lrange [lindex $mat $k] $kp1 $nm1]
        set scope [list $kp1 $nm1 $kp1 $nm1]
        dger mat -1. $akp1k $akkp1 $scope
    }
    return $ipiv
}

# det --
#     Returns the determinant of the given matrix, based on PA=LU
#     decomposition (i.e. dgetrf).
#
# Arguments:
#     matrix     The matrix values.
#     ipiv   The pivots (optionnal).
#       If the pivots are not provided, a PA=LU decomposition
#       is performed.
#       If the pivots are provided, we assume that it
#       contains the pivots and that the matrix A contains the
#       L and U factors, as provided by dgterf.
#
# Result:
#     Returns the determinant
#
proc ::math::linearalgebra::det { matrix {ipiv ""}} {
    if { $ipiv == "" } then {
        set ipiv [dgetrf matrix]
    }
    set det 1.0
    set norows [llength $matrix]
    set i 0
    foreach row $matrix {
        set uu [lindex $row $i]
        set det [expr {$det * $uu}]
        if { $i < $norows - 1 } then {
            set ii [lindex $ipiv $i]
            if {  $ii!=$i  } then {
                set det [expr {-1.0 * $det}]
            }
        }
        incr i
    }
    return $det
}

# largesteigen --
#     Returns a list made of the largest eigenvalue (in magnitude)
#     and associated eigenvector.
#     Uses Power Method.
#
# Arguments:
#     matrix     The matrix values.
#     tolerance  The relative tolerance of the eigenvalue.
#     maxiter    The maximum number of iterations
#
# Result:
#     Returns a list of two items, where the first item
#     is the eigenvalue and the second is the eigenvector.
# Note
#     This is algorithm #7.3.3 of Golub & Van Loan.
#
proc ::math::linearalgebra::largesteigen { matrix {tolerance 1.e-8} {maxiter 10}} {
    set norows [llength $matrix]
    set q [mkVector $norows 1.0]
    set lambda 1.0
    for { set k 0 } { $k < $maxiter } { incr k } {
        set z [matmul $matrix $q]
        set zn [norm $z]
        if { $zn == 0.0 } then {
            return -code error "Cannot continue power method : matrix is singular"
        }
        set s [expr {1.0 / $zn}]
        set q [scale $s $z]
        set prod [matmul $matrix $q]
        set lambda_old $lambda
        set lambda [dotproduct $q $prod]
        if { abs($lambda - $lambda_old) < $tolerance * abs($lambda_old) } then {
            break
        }
    }
    return [list $lambda $q]
}

# to_LA --
#     Convert a matrix or vector to the LA format
# Arguments:
#     mv         Matrix or vector to be converted
#
# Result:
#     List according to LA conventions
#
proc ::math::linearalgebra::to_LA { mv } {
    foreach {rows cols} [shape $mv] {
        if { $cols == {} } {
            set cols 0
        }
    }

    set result [list 2 $rows $cols]
    foreach row $mv {
        set result [concat $result $row]
    }
    return $result
}

# from_LA --
#     Convert a matrix or vector from the LA format
# Arguments:
#     mv         Matrix or vector to be converted
#
# Result:
#     List according to current conventions
#
proc ::math::linearalgebra::from_LA { mv } {
    foreach {rows cols} [lrange $mv 1 2] {break}

    if { $cols != 0 } {
        set result {}
        set elem2  2
        for { set i 0 } { $i < $rows } { incr i } {
            set  elem1 [expr {$elem2+1}]
            incr elem2 $cols
            lappend result [lrange $mv $elem1 $elem2]
        }
    } else {
        set result [lrange $mv 3 end]
    }

    return $result
}

#
# Announce the package's presence
#
package provide math::linearalgebra 1.1.5

if { 0 } {
Te doen:
behoorlijke testen!
matmul
solveGauss_band
join_col, join_row
kleinste-kwadraten met SVD en met Gauss
PCA
}

if { 0 } {
    set matrix {{1.0  2.0 -1.0}
        {3.0  1.1  0.5}
    {1.0 -2.0  3.0}}
    set bvect  {{1.0  2.0 -1.0}
        {3.0  1.1  0.5}
    {1.0 -2.0  3.0}}
    puts [join [::math::linearalgebra::solveGauss $matrix $bvect] \n]
    set bvect  {{4.0   2.0}
        {12.0  1.2}
    {4.0  -2.0}}
    puts [join [::math::linearalgebra::solveGauss $matrix $bvect] \n]
}

if { 0 } {

   set vect1 {1.0 2.0}
   set vect2 {3.0 4.0}
   ::math::linearalgebra::axpy_vect 1.0 $vect1 $vect2
   ::math::linearalgebra::add_vect      $vect1 $vect2
   puts [time {::math::linearalgebra::axpy_vect 1.0 $vect1 $vect2} 50000]
   puts [time {::math::linearalgebra::axpy_vect 2.0 $vect1 $vect2} 50000]
   puts [time {::math::linearalgebra::axpy_vect 1.0 $vect1 $vect2} 50000]
   puts [time {::math::linearalgebra::axpy_vect 1.1 $vect1 $vect2} 50000]
   puts [time {::math::linearalgebra::add_vect      $vect1 $vect2} 50000]
}

if { 0 } {
    set M {{1 2} {2 1}}
    puts "[::math::linearalgebra::determineSVD $M]"
}
if { 0 } {
    set M {{1 2} {2 1}}
    puts "[::math::linearalgebra::normMatrix $M]"
}
if { 0 } {
    set M {{1.3 2.3} {2.123 1}}
    puts "[::math::linearalgebra::show $M]"
    set M {{1.3 2.3 45 3.} {2.123 1 5.6 0.01}}
    puts "[::math::linearalgebra::show $M]"
    puts "[::math::linearalgebra::show $M %12.4f]"
}
if { 0 } {
    set M {{1 0 0}
        {1 1 0}
    {1 1 1}}
    puts [::math::linearalgebra::orthonormalizeRows $M]
}
if { 0 } {
    set M [::math::linearalgebra::mkMoler 5]
    puts [::math::linearalgebra::choleski $M]
}
if { 0 } {
    set M [::math::linearalgebra::mkRandom 20]
    set b [::math::linearalgebra::mkVector 20]
    puts "Gauss A = LU"
    puts [time {::math::linearalgebra::solveGauss $M $b} 5]
    puts "Gauss PA = LU"
    puts [time {::math::linearalgebra::solvePGauss $M $b} 5]
    # Gauss A = LU
    # 7607.4 microseconds per iteration
    # Gauss PA = LU
    # 17428.4 microseconds per iteration
}
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------


#-------------------------------------------------------------------------------
# -*- tcl -*-
# linalg.test --
#    Tests for the linear algebra package
#
# NOTE:
#    Comparison by numbers, not strings, needed!
#
# TODO:
#    Tests for:
#    - show, angle
#    - solveGaussBand, solveTriangularBand
#    - mkHilbert and so on
#    - matmul

#-------------------------------------------------------------------------------


#-------------------------------------------------------------------------------
proc ALLTESTS {} {
#-------------------------------------------------------------------------------


  set regular 1
  
  # if {$regular==1} then {
  #     source [file join \
    #                 [file dirname [file dirname [file join [pwd] [info script]]]] \
    #                 devtools testutilities.tcl]
  
  #     testsNeedTcl     8.4
  #     testsNeedTcltest 2.1
  
  #     support {
  #         useLocal math.tcl math
  #     }
  #     testing {
  #         useLocal linalg.tcl math::linearalgebra
  #     }
  
  # } else {
  #     package require tcltest
  #     tcltest::configure -verbose {start body error pass}
  #     #tcltest::configure -match largesteigen-*
  #     namespace import tcltest::test
  #     namespace import tcltest::customMatch
  #     set basedir [file normalize [file dirname [info script]]]
  #     set ::auto_path [linsert $::auto_path 0 $basedir]
  #     package require -exact math::linearalgebra 1.1.3
  # }
  
  #--------------------------------------------------
  
  package  require tcltest
  namespace import tcltest::test
  namespace import tcltest::customMatch
  
  #package           require math::linearalgebra
  #namespace import -force ::math::linearalgebra::*
  
  
  tcltest::configure -verbose {start body error pass}

  #--------------------------------------------------


  set prec $::tcl_precision
  if {![package vsatisfies [package provide Tcl] 8.5]} {
    set ::tcl_precision 17
  } else {
    set ::tcl_precision 0
  }

# -------------------------------------------------------------------------
#
# Returns 1 if the expected value is close to the actual value,
# that is their relative difference is small with respect to the
# given epsilon.
# If the expected value is zero, use an absolute error instead.
#
proc areClose {expected actual epsilon} {
    if {$actual=="" && $expected!=""} then {
        return 0
    }
    if {$actual!="" && $expected==""} then {
        return 0
    }
    set match 1
    if { [llength [lindex $expected 0]] > 1 } {
        foreach a $actual e $expected {
            set match [matchNumbers $e $a]
            if { $match == 0 } {
                break
            }
        }
    } else {

        foreach a $actual e $expected {
            if {[string is double $a]==0  || [string is double $e]==0} then {
                return 0
            }
            if {$e!=0.0} then {
              set shift [expr {abs($a-$e)/abs($e)}]
            } else {
              set shift [expr {abs($a-$e)}]
            }
            #puts "a=$a, e=$e, shift = $shift"
            if {$shift > $epsilon} {
                set match 0
                break
            }
        }
    }
    return $match
}
#-------------------------------------------------------------------------------
#
# Matching procedure - flatten the lists
#
proc matchNumbers {expected actual} {
    if {$actual=="" && $expected!=""} then {
        return 0
    }
    if {$actual!="" && $expected==""} then {
        return 0
    }
    set match 1
    if { [llength [lindex $expected 0]] > 1 } {
        foreach a $actual e $expected {
            set match [matchNumbers $e $a]
            if { $match == 0 } {
                break
            }
        }
    } else {

        foreach a $actual e $expected {
            if {[string is double $a]==0  || [string is double $e]==0} then {
                return 0
            }
            if {abs($a-$e) > 0.1e-6} {
                set match 0
                break
            }
        }
    }
    return $match
}

#-------------------------------------------------------------------------------

customMatch numbers matchNumbers

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------

test dimshape-1.0 "dimension of scalar" -body {
    dim 1
} -result 0

test dimshape-1.1 "dimension of vector" -body {
    dim {1 2 3}
} -result 1

test dimshape-1.2 "dimension of matrix" -body {
    dim { {1 2 3} {4 5 6} }
} -result 2

test dimshape-2.0 "shape of scalar" -body {
    shape 1
} -result {1}

test dimshape-2.1 "shape of vector" -body {
    shape {1 2 3}
} -result 3

test dimshape-2.2 "shape of matrix" -body {
    shape { {1 2 3} {4 5 6} }
} -result {2 3}

test symmetric-1.0 "non-symmetric matrix" -body {
    symmetric { {1 2 3} {4 5 6} {7 8 9}}
} -result 0

test symmetric-1.1 "symmetric matrix" -body {
    symmetric { {1 2 3} {2 1 4} {3 4 1}}
} -result 1

test symmetric-1.2 "non-square matrix" -body {
    symmetric { {1 2 3} {2 1 4}}
} -result 0

test norm-1.0 "one-norm - 5 components" -match numbers -body {
    norm {1 2 3 0 -1} 1
} -result 7.0

test norm-1.1 "one-norm - 2 components" -match numbers -body {
    norm {1 -1} 1
} -result 2.0

test norm-1.2 "two-norm - 5 components" -match numbers -body {
    norm {1 2 3 0 -1} 2
} -result [expr {sqrt(15)}]

test norm-1.3 "two-norm - 2 components" -match numbers -body {
    norm {1 -1} 2
} -result [expr {sqrt(2)}]

test norm-1.4 "two-norm - no underflow" -match numbers -body {
    norm {3.0e-140 -4.0e-140} 2
} -result 5.0e-140

test norm-1.5 "two-norm - no overflow" -match numbers -body {
    norm {3.0e140 -4.0e140} 2
} -result 5.0e140

test norm-1.6 "max-norm - 5 components" -match numbers -body {
    norm {1 2 3 0 -4} max
} -result 4

test norm-1.7 "max-norm - 2 components" -match numbers -body {
    norm {1 -1} max
} -result 1

test norm-2.0 "matrix-norm - 2x2 - max" -match numbers -body {
    normMatrix {{1 -1} {1 1}} max
} -result 1

test norm-2.1 "matrix-norm - 2x2 - 1" -match numbers -body {
    normMatrix {{1 -1} {1 1}} 1
} -result 4

test norm-2.2 "matrix-norm - 2x2 - 2" -match numbers -body {
    normMatrix {{1 -1} {1 1}} 2
} -result 2

test norm-3.0 "statistical normalisation - vector" -match numbers -body {
    normalizeStat {1 0 0 0}
} -result {1.5 -0.5 -0.5 -0.5}

test norm-3.1 "statistical normalisation - matrix" -match numbers -body {
    normalizeStat {{1 0 0 0} {0 0 0 1} {0 1 1 0} {0 0 0 0}}
} -result {{ 1.5 -0.5 -0.5 -0.5}
           {-0.5 -0.5 -0.5  1.5}
           {-0.5  1.5  1.5 -0.5}
           {-0.5 -0.5 -0.5 -0.5}}

test dotproduct-1.0" "dot-product - 2 components" -match numbers -body {
    dotproduct {1 -1} {1 -1}
} -result 2.0

test dotproduct-1.1" "dot-product - 5 components" -match numbers -body {
    dotproduct {1 2 3 4 5} {5 4 3 2 1}
} -result [expr {5.0+8+9+8+5}]

test unitlength-1.0" "unitlength - 2 components" -match numbers -body {
    unitLengthVector {3 4}
} -result {0.6 0.8}

test unitlength-1.1" "unitlength - 4 components" -match numbers -body {
    unitLengthVector {1 1 1 1}
} -result {0.5 0.5 0.5 0.5}

test axpy-1.0 "axpy - vectors" -body {
    axpy 2 {1 -1} {2 -2}
} -result {4 -4}

test axpy-1.1 "axpy - matrices" -body {
    axpy 2 { {1 -1} {2 -2} {3 4} {-3 4} } \
           { {5 -5} {5 -5} {6 6} {-6 6} }
} -result {{7 -7} {9 -9} {12 14} {-12 14}}

test add-1.0 "add - vectors" -body {
    add {1 -1} {2 -2}
} -result {3 -3}

test add-1.1 "add - matrices" -body {
    add { {1 -1} {2 -2} {3 4} {-3 4} } \
        { {5 -5} {5 -5} {6 6} {-6 6} }
} -result {{6 -6} {7 -7} {9 10} {-9 10}}

test sub-1.0 "sub - vectors" -body {
    sub {1 -1} {2 -2}
} -result {-1 1}

test sub-1.1 "sub - matrices" -body {
    sub { {1 -1} {2 -2} {3 4} {-3 4} } \
        { {5 -5} {5 -5} {6 6} {-6 6} }
} -result {{-4 4} {-3 3} {-3 -2} {3 -2}}

test scale-1.0 "scale - vectors" -body {
    scale 3 {2 -2}
} -result {6 -6}

test scale-1.1 "scale - matrices" -body {
    scale 3 { {5 -5} {5 -5} {6 6} {-6 6} }
} -result {{15 -15} {15 -15} {18 18} {-18 18}}

test make-1.0 "mkVector - create a null vector" -body {
    mkVector 3
} -result {0.0 0.0 0.0}

test make-1.1 "mkVector - create a vector with values 1" -body {
    mkVector 3 1.0
} -result {1.0 1.0 1.0}

test make-2.0 "mkMatrix - create a matrix with 3 rows, 2 columns" -body {
    mkMatrix 3 2 2.0
} -result {{2.0 2.0} {2.0 2.0} {2.0 2.0}}

test make-2.1 "mkMatrix - create a matrix with 2 rows, 3 columns" -body {
    mkMatrix 2 3 1.0
} -result {{1.0 1.0 1.0} {1.0 1.0 1.0}}

test make-3.0 "mkIdentity - create an identity matrix 2x2" -body {
    mkIdentity 2
} -result {{1.0 0.0} {0.0 1.0}}

test make-3.1 "mkIdentity - create an identity matrix 3x3" -body {
    mkIdentity 3
} -result {{1.0 0.0 0.0} {0.0 1.0 0.0} {0.0 0.0 1.0}}

test make-4.0 "mkDiagonal - create a diagonal matrix 2x2" -body {
    mkDiagonal {2.0 3.0}
} -result {{2.0 0.0} {0.0 3.0}}

test make-4.1 "mkDiagonal - create a diagonal matrix 3x3" -body {
    mkDiagonal {2.0 3.0 4.0}
} -result {{2.0 0.0 0.0} {0.0 3.0 0.0} {0.0 0.0 4.0}}

test getset-1.0 "getrow - get first row from a matrix" -body {
    getrow {{1 2 3} {4 5 6} {7 8 9} {10 11 12}} 0
} -result {1 2 3}

test getset-1.1 "getrow - get last row from a matrix" -body {
    getrow {{1 2 3} {4 5 6} {7 8 9} {10 11 12}} 3
} -result {10 11 12}

test getset-1.1b "getrow - get row of a vector" -body {
    getrow {1 2 3} 1
} -result {2}
test getset-1.1c "getrow - get row #1, for columns #2 to #3" -body {
    getrow {{1 2 3 4 5 6} {7 8 9 10 11 12} {13 14 15 16 17 18}} 1 2 3
} -result {9 10}

test getset-1.2 "getcol - get first column from a matrix" -body {
    getcol {{1 2 3} {4 5 6} {7 8 9} {10 11 12}} 0
} -result {1 4 7 10}

test getset-1.3 "getcol - get last column from a matrix" -body {
    getcol {{1 2 3} {4 5 6} {7 8 9} {10 11 12}} 2
} -result {3 6 9 12}
test getset-1.4 "getcol - get column #1 from lines #2 to #3" -body {
    getcol {{1 2 3} {4 5 6} {7 8 9} {10 11 12} {13 14 15}} 1 2 3
} -result {8 11}

test getset-2.0 "setrow - set first row in a matrix" -body {
    set M {{1 2 3} {4 5 6} {7 8 9} {10 11 12}}
    setrow M 0 {3 2 1}
} -result {{3 2 1} {4 5 6} {7 8 9} {10 11 12}}

test getset-2.1 "setrow - set last row in a matrix" -body {
    set M {{1 2 3} {4 5 6} {7 8 9} {10 11 12}}
    setrow M 3 {3 2 1}
} -result {{1 2 3} {4 5 6} {7 8 9} {3 2 1}}

test getset-2.1b "setrow - set row #1 from column #2 to column #3" -body {
    set M {{1 2 3 4 5} {6 7 8 9 10} {11 12 13 14 15}}
    setrow M 1 {99 100} 2 3
} -result {{1 2 3 4 5} {6 7 99 100 10} {11 12 13 14 15}}

test getset-2.2 "setcol - set first column in a matrix" -body {
    set M {{1 2 3} {4 5 6} {7 8 9} {10 11 12}}
    setcol M 0 {3 2 1 0}
} -result {{3 2 3} {2 5 6} {1 8 9} {0 11 12}}

test getset-2.3 "setcol - set last column in a matrix" -body {
    set M {{1 2 3} {4 5 6} {7 8 9} {10 11 12}}
    setcol M 2 {3 2 1 0}
} -result {{1 2 3} {4 5 2} {7 8 1} {10 11 0}}

test getset-2.4 "setcol - set column #1 from lines #2 to #3" -body {
    set M {{1 2 3} {4 5 6} {7 8 9} {10 11 12} {13 14 15}}
    setcol M 1 {99 100} 2 3
} -result {{1 2 3} {4 5 6} {7 99 9} {10 100 12} {13 14 15}}

test getset-3.0 "getelem - get element (0,0) in a matrix" -body {
    getelem {{1 2 3} {4 5 6} {7 8 9} {10 11 12}} 0 0
} -result 1

test getset-3.1 "getelem - set element (1,2) in a matrix" -body {
    getelem {{1 2 3} {4 5 6} {7 8 9} {10 11 12}} 1 2
} -result 6

test getset-3.2 "setelem - set element (0,0) in a matrix" -body {
    set M {{1 2 3} {4 5 6} {7 8 9} {10 11 12}}
    setelem M 0 0 100
} -result {{100 2 3} {4 5 6} {7 8 9} {10 11 12}}

test getset-3.3 "setelem - set element (1,2) in a matrix" -body {
    set M {{1 2 3} {4 5 6} {7 8 9} {10 11 12}}
    setelem M 1 2 100
} -result {{1 2 3} {4 5 100} {7 8 9} {10 11 12}}

test getset-4.0 "getelem - get element 1 from a vector" -body {
    set V {1 2 3}
    getelem $V 1
} -result 2

test getset-4.1 "setelem - set element 1 in a vector" -body {
    set V {1 2 3}
    setelem V 1 4
} -result {1 4 3}

test swaprows-1 "swap two rows of a matrix" -body {
    set M {{1 2 3} {4 5 6} {7 8 9} {10 11 12}}
    swaprows M 1 2
} -result {{1 2 3} {7 8 9} {4 5 6} {10 11 12}}

test swaprows-2 "swap rows #1 and #2 from columns #2 to #3" -body {
    set M {{1 2 3 4 5} {6 7 8 9 10} {11 12 13 14 15} {16 17 18 19 20}}
    swaprows M 1 2 2 3
} -result {{1 2 3 4 5} {6 7 13 14 10} {11 12 8 9 15} {16 17 18 19 20}}

test swapcols-1 "swap two columns of a matrix" -body {
    set M {{1 2 3 4 5} {6 7 8 9 10} {11 12 13 14 15} {16 17 18 19 20}}
    swapcols M 1 2
} -result {{1 3 2 4 5} {6 8 7 9 10} {11 13 12 14 15} {16 18 17 19 20}}

test swapcols-2 "swap columns #1 and #2 from lines #1 to #2" -body {
    set M {{1 2 3 4 5} {6 7 8 9 10} {11 12 13 14 15} {16 17 18 19 20}}
    swapcols M 1 2 1 2
} -result {{1 2 3 4 5} {6 8 7 9 10} {11 13 12 14 15} {16 17 18 19 20}}

test rotate-1.0 "rotate - over 90 degrees" -body {
    set v1 {1 2 3}
    set v2 {4 5 6}
    rotate 0 1 $v1 $v2
} -result {{-4 -5 -6} {1 2 3}}

test rotate-1.1 "rotate - over 180 degrees" -body {
    set v1 {1 2 3 4 5 6}
    set v2 {7 8 9 10 11 12}
    rotate -1 0 $v1 $v2
} -result {{-1 -2 -3 -4 -5 -6} {-7 -8 -9 -10 -11 -12}}

test matmul-1.0 "multiply matrix - vector" -match numbers -body {
    set v1 {1 2 3}
    set m  {{0 0 1} {0 5 0} {-1 0 0}}
    matmul $m $v1
} -result {3 10 -1}

test matmul-1.1 "multiply vector - matrix" -match numbers -body {
    set v1 {{1 2 3}} ;# Row vector
    set m  {{0 0 1} {0 5 0} {-1 0 0}}
    matmul $v1 $m
} -result {{-3 10 1}}

test matmul-1.2 "multiply matrix - matrix" -match numbers -body {
    set m1 {{0 0 1} {0 5 0} {-1 0 0}}
    set m2 {{0 0 1} {1 5 1} {-1 0 0}}
    matmul $m1 $m2
} -result {{-1 0 0} {5 25 5} {0 0 -1}}

test matmul-1.3 "multiply vector - vector" -match numbers -body {
    set v1 {1 2 3}
    set v2 {4 5 6}
    matmul $v1 $v2
} -result {{4 5 6} {8 10 12} {12 15 18}}

test matmul-1.4 "multiply row vector - column vector" -match numbers -body {
    set v1 [transpose {1 2 3}]
    set v2 {4 5 6}
    matmul $v1 $v2
} -result 32

test matmul-1.5 "multiply column vector - row vector" -match numbers -body {
    set v1 {1 2 3}
    set v2 [transpose {4 5 6}]
    matmul $v1 $v2
} -result {{4 5 6} {8 10 12} {12 15 18}}

test matmul-1.6 "multiply scalar - scalar" -match numbers -body {
    set v1 {1}
    set v2 {1}
    matmul $v1 $v2
} -result {1}

test solve-1.1 "solveGauss - 2x2 matrix" -match numbers -body {
    set b {{2 3} {-2 3}}
    set M {{2 3} {-2 3}}
    solveGauss $M $b
} -result {{1 0} {0 1}}

test solve-1.2 "solveGauss - 3x3 matrix" -match numbers -body {
    set b {{2 3 4} {-2 3 4} {1 1 1}}
    set M {{2 3 4} {-2 3 4} {1 1 1}}
    solveGauss $M $b
} -result {{1 0 0} {0 1 0} {0 0 1}}

test solve-1.3 "solveGauss - 3x3 matrix - less trivial" -match numbers -body {
    set b {{6 -3 6} {2 -3 2} {2 -1 2}}
    set M {{2 3 4} {-2 3 4} {1 1 1}}
    solveGauss $M $b
} -result {{1 0 1} {0 -1 0} {1 0 1}}
#
# MB
#
test solve-1.4 "solveGauss - 3x3 matrix - but better pivots may be found" -match numbers -body {
    set b {{67 67} {4 4} {6 6}}
    set M {{3 17 10} {2 4 -2} {6 18 -12}}
    solveGauss $M $b
} -result {{1 1} {2 2} {3 3}}

test solve-1.5 "solveGauss - Hilbert matrix" -match numbers -body {
    set expected [mkVector 10 1.0]
    set M [mkHilbert 10]
    # b is expected as a list of colums
    set b [mkMatrix 10 1]
    setcol b 0 [matmul $M $expected]
    set computed [solveGauss $M $b]
    set diff [sub $computed $expected]
    set norm [normMatrix $diff max]
    # Computed norm : 0.00043691152972824554
    set result [expr {$norm<1.e-3}]
} -result {1}

test solvepgauss-1.6 "solveGauss - 2x2 difficult matrix with necessary permutations" -match numbers -body {
    set M {{1.e-8 1} {1 1}}
    set b [list [expr {1.+1.e-8}] 2.]
    set computed [solveGauss $M $b]
    set expected {1. 1.}
    set diff [sub $computed $expected]
    set norm [norm $diff max]
    # Computed norm : 5.0247592753294157e-09
    set result [expr {$norm<1.e-8}]
} -result {1}

test solvepgauss-1 "solvePGauss - 3x3 matrix with two permutations" -match numbers -body {
    set b {{67} {4} {6}}
    set M {{3 17 10} {2 4 -2} {6 18 -12}}
    solvePGauss $M $b
} -result {{1} {2} {3}}

test solvepgauss-2 "solvePGauss - 3x3 matrix" -match numbers -body {
    set b {{6 -3 6} {2 -3 2} {2 -1 2}}
    set M {{2 3 4} {-2 3 4} {1 1 1}}
    solvePGauss $M $b
} -result {{1 0 1} {0 -1 0} {1 0 1}}

test solvepgauss-3 "solvePGauss - 10x10 Hilbert matrix" -match numbers -body {
    set expected [mkVector 10 1.0]
    set M [mkHilbert 10]
    # b is expected as a list of colums
    set b [mkMatrix 10 1]
    setcol b 0 [matmul $M $expected]
    set computed [solvePGauss $M $b]
    set diff [sub $computed $expected]
    set norm [normMatrix $diff max]
    # Computed norm : 0.00031339500191851499
    set result [expr {$norm<1.e-3}]
} -result {1}

test solvepgauss-4 "solvePGauss - 2x2 difficult matrix with necessary permutations" -match numbers -body {
    set M {{1.e-8 1} {1 1}}
    set b [list [expr {1.+1.e-8}] 2.]
    set computed [solvePGauss $M $b]
    set expected {1. 1.}
    set diff [sub $computed $expected]
    set norm [norm $diff max]
    # Computed norm : 0.
    set result [expr {$norm<1.e-15}]
} -result {1}


test orthon-1.0 "orthonormalize columns - 3x3" -match numbers -body {
    set M {{1 1 1}
           {0 1 1}
           {0 0 1}}
    orthonormalizeColumns $M
} -result {{1 0 0}
           {0 1 0}
           {0 0 1}}

test orthon-1.1 "orthonormalize rows - 3x3" -match numbers -body {
    set M {{1 0 0}
           {1 1 0}
           {1 1 1}}
    orthonormalizeRows $M
} -result {{1 0 0}
           {0 1 0}
           {0 0 1}}

test orthon-1.2 "orthonormalize rows - 3x4" -match numbers -body {
    set M {{1 0 0 0}
           {1 1 0 0}
           {1 1 1 0}}
    orthonormalizeRows $M
} -result {{1 0 0 0}
           {0 1 0 0}
           {0 0 1 0}}

#
# The results from the original LA package have been used
# as a benchmark:
#
#
test svd-1.0 "singular value decomposition - 2x2" -match numbers -body {
    set M {{1.0 2.0} {2.0 1.0}}
    determineSVD $M
} -result {
{{0.70710678118654757  0.70710678118654746}
 {0.70710678118654746 -0.70710678118654757}}
 {3.0 1.0}
{{0.70710678118654757 -0.70710678118654746}
 {0.70710678118654746  0.70710678118654757}}
}

test svd-1.1 "singular value decomposition - 10x10" -match numbers -body {
    set M [mkDingdong 10]
    show [lindex [determineSVD $M] 1] %6.4f
} -result {1.5708 1.5708 1.5708 1.5708 1.5708 1.5707 1.5695 1.5521 1.3935 0.6505}




test LA-1.0 "to_LA - vector" -match numbers -body {
    set vector {1 2 3}
    to_LA $vector
} -result {2 3 0 1 2 3}

test LA-1.1 "to_LA - matrix" -match numbers -body {
    set matrix {{1 2 3} {4 5 6} {7 8 9} {10 11 12}}
    to_LA $matrix
} -result {2 4 3 1 2 3 4 5 6 7 8 9 10 11 12}

test LA-2.0 "from_LA - vector" -match numbers -body {
    set vector {2 3 0 1 2 3}
    from_LA $vector
} -result {1 2 3}

test LA-2.1 "from_LA - matrix" -match numbers -body {
    set matrix {2 4 3 1 2 3 4 5 6 7 8 9 10 11 12}
    from_LA $matrix
} -result {{1 2 3} {4 5 6} {7 8 9} {10 11 12}}

test choleski-1.0 "choleski decomposition of Moler matrix" -match numbers -body {
    set matrix [mkMoler 5]
    choleski $matrix
} -result {{1 0 0 0 0} {-1 1 0 0 0} {-1 -1 1 0 0} {-1 -1 -1 1 0} {-1 -1 -1 -1 1}}

test leastsquares-1.0 "Least-squares solution" -match numbers -body {
    #
    # Known relation: z = 1.0 + x + 0.1*y
    # Model this as: z = z0 + x + 0.1*y
    # (The column of 1s allows us to use a non-zero intercept)
    #
    #          z0   x   y     z
    set Ab { {  1  1.0  1.0} 2.1
             {  1  2.0  1.0} 3.1
             {  1  2.0  2.0} 3.2
             {  1  4.0  2.0} 5.2
             {  1  4.0 22.0} 7.2
             {  1  5.0 -2.0} 5.8 }

    set A {}
    set b {}
    foreach {Ar br} $Ab {
        lappend A $Ar
        lappend b $br
    }
    set x [::math::linearalgebra::leastSquaresSVD $A $b]
} -result {1.0 1.0 0.1}


test eigenvectors-1.0 "Eigenvectors solution" -match numbers -body {
    #
    # Matrix:
    #    /2   1\
    #    \1   2/
    # has eigenvalues 3 and 1 with eigenvectors:
    #    / 1\      /1\
    #    \-1/  and \1/
    # (so include a factor 1/sqrt(2) in the answer)
    #
    set A  { {2 1}
             {1 2} } ;# Note: integer coefficients!

    ::math::linearalgebra::eigenvectorsSVD $A
} -cleanup {
    unset A
} -result {{{0.7071068 -0.7071068} {0.7071068 0.7071068}} {3.0 1.0}}

test eigenvectors-1.1-tkt7f082f8667 {Eigenvector signs} -setup {
    # Test case derived from the example code found in ticket [7f082f8667].
    set A {
	{2.7563361585555084  0.02600440980933252 0.0}
	{0.02600440980933252 2.785766824118953   0.0}
	{0.0                 0.0                -5.542102982674461}
    }
} -body {
    lindex [::math::linearalgebra::eigenvectorsSVD $A] 1
} -cleanup {
    unset A
} -match numbers -result {2.80093075418638 2.7411722284880806 -5.542102982674461}


test mkHilbert-1.0 "Hilbert matrix" -match numbers -body {
    set computed [mkHilbert 3]
    set expected {{1.0 0.5 0.333333333333} {0.5 0.333333333333 0.25} {0.333333333333 0.25 0.2}}
    set diff [sub $computed $expected]
    set norm [normMatrix $diff max]
    set result [expr {$norm<1.e-10}]
} -result {1}

test dger-1 "dger" -match numbers -body {
    set M {{1 2 3} {4 5 6} {7 8 9}}
    set x {1 2 3}
    set y {4 5 6}
    set alpha -1.
    dger M $alpha $x $y
} -result {{-3 -3 -3} {-4 -5 -6} {-5 -7 -9}}

test dger-2 "dger" -match numbers -body {
    set M {{1 2 3 4 5} {6 7 8 9 10} {11 12 13 14 15} {16 17 18 19 20}}
    set x {1 2 3}
    set y {4 5 6}
    set alpha -1.
    set imin 1
    set imax 3
    set jmin 2
    set jmax 4
    set scope [list $imin $imax $jmin $jmax]
    dger M $alpha $x $y $scope
} -result {{1 2 3 4 5} {6 7 4 4 4} {11 12 5 4 3} {16 17 6 4 2}}

test dgetrf-1 "dgetrf" -body {
    set M {{3 17 10} {2 4 -2} {6 18 -12}}
    set ipiv [dgetrf M]
    # Check matrix
    set expectedmat {{6 18 -12} {0.5 8.0 16.0} {0.33333333333333331 -0.25 6.0}}
    set diff [sub $M $expectedmat]
    set norm [normMatrix $diff max]
    set expectation1 [expr {$norm<1.e-10}]
    # Check pivots
    set expectedpivots {2 2}
    set diff [sub $ipiv $expectedpivots]
    set norm [normMatrix $diff max]
    set expectation2 [expr {$norm<1.e-10}]
    set result [list $expectation1 $expectation2]
} -result {1 1}

test solvetriangular-1 "upper triangular matrix" -match numbers -body {
    set M {{3 17 10} {0 4 -2} {0 0 -12}}
    set b {{67 30} {2 2} {-36 -12}}
    set computed [solveTriangular $M $b]
} -result {{1 1} {2 1} {3 1}}

test solvetriangular-2 "lower triangular matrix" -match numbers -body {
    set M {{3 0 0} {2 4 0} {6 18 -12}}
    set b {{3 3} {10 6} {6 12}}
    set computed [solveTriangular $M $b "L"]
} -result {{1 1} {2 1} {3 1}}

test solvetriangular-3 "lower triangular random matrix" -match numbers -body {
    set M [mkTriangular 10 "L" 1.]
    set xexpected [mkVector 10 1.]
    set b [matmul $M $xexpected]
    set computed [solveTriangular $M $b "L"]
} -result {1 1 1 1 1 1 1 1 1 1}

test solvetriangular-4 "upper triangular random matrix" -match numbers -body {
    set M [mkTriangular 10 "U" 1.]
    set xexpected [mkVector 10 1.]
    set b [matmul $M $xexpected]
    set computed [solveTriangular $M $b "U"]
} -result {1 1 1 1 1 1 1 1 1 1}


test mkTriangular-1 "make triangular matrix" -match numbers -body {
    mkTriangular 3
} -result {{1.0 1.0 1.0} {0. 1.0 1.0} {0. 0. 1.0}}

test mkTriangular-2 "make triangular matrix" -match numbers -body {
    mkTriangular 3 "L" 2.
} -result {{2. 0. 0.} {2. 2. 0.} {2. 2. 2.}}

test mkBorder "make border matrix" -match numbers -body {
    mkBorder 5
} -result {
{1.0 0.0 0.0 0.0 1.0}
{0.0 1.0 0.0 0.0 0.5}
{0.0 0.0 1.0 0.0 0.25}
{0.0 0.0 0.0 1.0 0.125}
{1.0 0.5 0.25 0.125 1.0}}

test mkWilkinsonW- "make Wilkinson W- matrix" -match numbers -body {
    mkWilkinsonW- 5
} -result {
{2.0 1.0 0.0 0.0 0.0}
{1.0 1.0 1.0 0.0 0.0}
{0.0 1.0 0.0 1.0 0.0}
{0.0 0.0 1.0 -1.0 1.0}
{0.0 0.0 0.0 1.0 -2.0}}

test mkWilkinsonW+ "make Wilkinson W+ matrix" -match numbers -body {
    mkWilkinsonW+ 7
} -result {
{3.0 1.0 0.0 0.0 0.0 0.0 0.0}
{1.0 2.0 1.0 0.0 0.0 0.0 0.0}
{0.0 1.0 1.0 1.0 0.0 0.0 0.0}
{0.0 0.0 1.0 0.0 1.0 0.0 0.0}
{0.0 0.0 0.0 1.0 1.0 1.0 0.0}
{0.0 0.0 0.0 0.0 1.0 2.0 1.0}
{0.0 0.0 0.0 0.0 0.0 1.0 3.0}}

test det-1 "determinant" -match numbers -body {
    set a [mkBorder 5]
    set det [det $a]
} -result {-0.328125}

test det-2 "determinant" -match numbers -body {
    set a [mkWilkinsonW+ 5]
    set det [det $a]
} -result {-4.0}
test det-3 "determinant" -match numbers -body {
    set a [mkWilkinsonW- 5]
    set det [det $a]
} -result {0.0}
test det-4 "determinant with pre-computed decomposition" -match numbers -body {
    set a [mkWilkinsonW- 5]
    set ipiv [dgetrf a]
    set det [det $a $ipiv]
} -result {0.0}

#set ::tcl_precision 17
test largesteigen-1 "power method" -body {
    set a {{-261 209 -49}
      {-530 422 -98}
      {-800 631 -144}}
    set pm [largesteigen $a 1.e-8 200]
    set eigval [lindex $pm 0]
    set eigvec [lindex $pm 1]
    set res {}
    set expected {-0.2672612419124256177838 -0.5345224838248414656050 -0.8017837257372776305075}
    lappend res -eigvec [areClose $expected $eigvec 1.e-8]
    lappend res -eigval [areClose 10.0 $eigval 1.e-8]
} -result {-eigvec 1 -eigval 1}
test largesteigen-2 "power method" -body {
    set a {{-261 209 -49}
      {-530 422 -98}
      {-800 631 -144}}
    set pm [largesteigen $a]
    set eigval [lindex $pm 0]
    set eigvec [lindex $pm 1]
    set res {}
    set expected {-0.2672612419124256177838 -0.5345224838248414656050 -0.8017837257372776305075}
    lappend res -eigvec [areClose $expected $eigvec 1.e-5]
    lappend res -eigval [areClose 10.0 $eigval 1.e-5]
} -result {-eigvec 1 -eigval 1}
test largesteigen-3 "power method" -body {
    set a {{0.0 0.0 0.0}
      {0.0 0.0 0.0}
      {0.0 0.0 0.0}}
      catch {
        set pm [largesteigen $a]
      } errmsg
    set errmsg
} -result {Cannot continue power method : matrix is singular}

# Additional tests: procedures by Federico Ferri
#source ferri/ferri.test

  #--------------------------------------------------

  # set ::tcl_precision $prec

  # if {$regular==1} then {
  #     testsuiteCleanup
  # } else {
  #     tcltest::cleanupTests
  # }

#-------------------------------------------------------------------------------
} ;# ALLTESTS
#-------------------------------------------------------------------------------
proc TEST_00 {} {

  puts ""
  puts "MATH_test .. "
  puts ""

  #tcltest::configure -verbose {start body error pass}

  ALLTESTS ;# тесты пакета

}
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
proc makevect {N} {

  set result {}

  for { set i 0 } { $i < $N } { incr i } {
    lappend result [expr {double ($i + 1)}]
  }

  return $result
}
#-------------------------------------------------------------------------------
proc TEST_time {} {
  
  
  puts ""
  puts "Measure the relative speeds ..........................."
  puts ""
  

  foreach size {3 10 30 100 300} {
    
    puts "Size: $size"
    puts ""
    
    set mat [makemat1 $size] ;# set m  {{0 0 1} {0 5 0} {-1 0 0}}   
    set vec [makevect $size] ;# set v1 {1 2 3}
    
    puts [time {set newvec [matmul $mat $vec]} 100]

    puts ""
 }

  return
}
#-------------------------------------------------------------------------------


#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
