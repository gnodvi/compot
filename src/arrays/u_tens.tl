# -*-   mode: tcl  ; coding: koi8   -*- ----------------------------------------

#-------------------------------------------------------------------------------
#
# -*- tcl -*-
#-------------------------------------------------------------------------------



#-------------------------------------------------------------------------------
proc apply_test {} {

  # Tensor "apply" tests

  catch {rename t0 {}}

  test apply-1.1 {tensor "apply" command} {
    catch {rename t0 {}}
    tensor::create t0 -size 5
    set r1 [catch {t0 apply}]
    set r2 [catch {t0 apply foo}]
    set r3 [catch {t0 apply log bar}]
    list $r1 $r2 $r3
  } {1 1 1}
  
  test apply-2.1 {tensor "apply" command} {
    catch {rename t5 {}}
    tensor::create t5 -initial {-2 -1 0 1 2}
    t5 apply fabs
    t5
  } {2.0 1.0 0.0 1.0 2.0}
  
  test apply-2.2 {tensor "apply" command} {
    catch {rename t5 {}}
    tensor::create t5 -initial {-2 -1 0 1 2}
    t5 section {{1 3}} apply fabs
    t5
  } {-2.0 1.0 0.0 1.0 2.0}
  
  test apply-2.3 {tensor "apply" command} {
    catch {rename t0 {}}
    tensor::create t0 -size {}
    t0 = scalar -3
    t0 apply fabs
    t0
  } {3.0}
  
  
  return
}
#-------------------------------------------------------------------------------
proc bool_test {} {

  # Tensor "boolean" operand tests

  catch {rename t0 {}}
  
  test bool-1.1 {tensor "boolean" operands} {
    catch {rename t0 {}}
    catch {rename foo {}}
    tensor::create t0 -size 5
    set r1 [catch {t0 = boolean}]
    set r2 [catch {t0 = boolean foo}]
    set r3 [catch {t0 = boolean foo ==}]
    set r4 [catch {t0 = boolean foo == scalar}]
    set r5 [catch {t0 = boolean foo == scalar 0}]
    set r6 [catch {t0 = boolean t0 == scalar grok}]
    set r7 [catch {t0 = boolean t0 == scalar 0 1}]
    set r8 [catch {t0 = boolean t0 == junk 0}]
    set r9 [catch {t0 = boolean t0 section == scalar 0}]
    list $r1 $r2 $r3 $r4 $r5 $r6 $r7 $r8 $r9
  } {1 1 1 1 1 1 1 1 1}
  
  test bool-1.2 {tensor "boolean" operands} {
    catch {rename t0 {}}
    catch {rename foo {}}
    tensor::create t0 -size 5
    set r1 [catch {t0 = boolean t0 section {{1 3}} == scalar 0 0}]
    set r2 [catch {t0 = boolean t0 section {{1 3}} == scalar 0}]
    set r3 [catch {t0 section {{0 2}} = boolean t0 section {{1 4}} == scalar 0}]
    set r4 [catch {t0 section {{0 2}} = boolean t0 section {{1 3}} == tensor foo}]
    set r5 [catch {t0 section {{0 2}} = boolean t0 section {{1 3}} == tensor t0}]
    set r6 [catch {t0 section {{0 2}} = boolean t0 section {{1 3}} == tensor t0 section}]
    set r7 [catch {t0 section {{0 2}} = boolean t0 section {{1 3}} == tensor t0 section {{1 4}}}]
    list $r1 $r2 $r3 $r4 $r5 $r6 $r7
  } {1 1 1 1 1 1 1}
  
  test bool-2.1 {tensor "boolean" operands} {
    catch {rename t5 {}}
    catch {rename b5 {}}
    tensor::create t5 -initial {-2 -1 0 1 2}
    tensor::create b5 -type byte -size 5
    b5 = boolean t5 >= scalar 0
    b5
  } {0 0 1 1 1}
  
  test bool-2.2 {tensor "boolean" operands} {
    catch {rename ta5 {}}
    catch {rename tb5 {}}
    catch {rename b5 {}}
    tensor::create ta5 -initial {-2 -1 0 1 2}
    tensor::create tb5 -initial {2 1 0 -1 -2}
    tensor::create b5 -type byte -size 5
    b5 = boolean ta5 >= tensor tb5
    b5
  } {0 0 1 1 1}
  
  test bool-2.3 {tensor "boolean" operands} {
    catch {rename ta5 {}}
    catch {rename tb5 {}}
    catch {rename b5 {}}
    tensor::create ta5 -initial {-2 -1 0 1 2}
    tensor::create tb5 -initial {2 1 0 -1 -2}
    tensor::create b5 -type byte -size 5
    b5 section {{0 2}} = boolean ta5 section {{1 3}} >= tensor tb5 section {{1 3}}
    b5
  } {0 1 1 0 0}
  
  
  return
}
#-------------------------------------------------------------------------------
proc compare_test {} {
  
  # Tensor comparison tests

  test compare-1.1 {tensor comparison - scalar} {
    catch {rename t23 {}}
    tensor::create t23 -type int -size {2 3}
    t23 = scalar 1
    list [t23 == scalar 1] [t23 == scalar 2] \
      [t23 < scalar 0] [t23 >= scalar 0] \
      [t23 == scalar 0] [t23 != scalar 0] \
      [t23 > scalar 0] [t23 <= scalar 0]
  } {1 0 0 1 0 1 1 0}
  
  test compare-1.2 {tensor comparison - scalar} {
    catch {rename t23 {}}
    tensor::create t23 -type int -size {2 3}
    t23 section {0 *} = scalar 1
    t23 section {1 *} = scalar 2
    list [t23 == scalar 0] [t23 == scalar 1] \
      [t23 section {0 *} == scalar 0] [t23 section {0 *} == scalar 1] \
      [t23 section {1 *} == scalar 1] [t23 section {1 *} == scalar 2] \
      [t23 == scalar 0] [t23 != scalar 0] \
      [t23 == scalar 1] [t23 != scalar 1] \
      [t23 < scalar 1] [t23 >= scalar 1] \
      [t23 > scalar 1] [t23 <= scalar 1]
  } {0 0 0 1 0 1 0 1 0 0 0 1 0 0}
  
  test compare-1.3 {tensor comparison - array} {
    catch {rename t23 {}}
    tensor::create t23 -type int -size {2 3}
    t23 = array { { 1 2 3 } { 4 5 6 } }
    list [t23 == array { { 1 2 3 } { 4 5 6 } }] \
      [t23 section {* 0} == array {1 4}] \
      [t23 section {1 *} == array {4 5 6}] \
      [t23 == array { { 1 2 3 } { 4 5 7 } }] \
      [t23 != array { { 1 2 3 } { 4 5 7 } }] \
      [t23 <= array { { 1 2 3 } { 4 5 7 } }]
  } {1 1 1 0 0 1}
  
  test compare-1.4 {tensor comparison - tensor} {
    catch {rename t23 {}}
    catch {rename u23 {}}
    tensor::create t23 -type int -initial { { 1 2 3 } { 4 5 6 } }
    tensor::create u23 -type int -initial { { 4 5 6 } { 7 8 9 } }
    list [t23 == tensor u23] [t23 != tensor u23] \
      [t23 < tensor u23] [t23 >= tensor u23] \
      [t23 > tensor u23] [t23 <= tensor u23] \
      [t23 section {1 *} == tensor u23 section {0 *}]
  } {0 1 1 0 0 1 1}
  
  
  test compare-2.1 {tensor minmax} {
    catch {rename t23 {}}
    tensor::create t23 -type double -initial { { -1 2 3 } { 4 5 6 } }
    set mm [t23 minmax]
    set mm2 [t23 section {1 *} minmax]
    set res {}
    set tcl_precision 17
    lappend res [expr abs([lindex $mm 0] + 1) <= 0.00001]
    lappend res [expr abs([lindex $mm 1] - 6) <= 0.00001]
    lappend res [expr abs([lindex $mm2 0] - 4) <= 0.00001]
    lappend res [expr abs([lindex $mm2 1] - 6) <= 0.00001]
  } {1 1 1 1}
  
  test compare-2.2 {tensor minmax} {
    catch {rename t23 {}}
    tensor::create t23 -type float -initial { { -1 2 3 } { 4 5 6 } }
    set mm [t23 minmax]
    set mm2 [t23 section {1 *} minmax]
    set res {}
    set tcl_precision 17
    lappend res [expr abs([lindex $mm 0] + 1) <= 0.00001]
    lappend res [expr abs([lindex $mm 1] - 6) <= 0.00001]
    lappend res [expr abs([lindex $mm2 0] - 4) <= 0.00001]
    lappend res [expr abs([lindex $mm2 1] - 6) <= 0.00001]
  } {1 1 1 1}
  
  test compare-2.3 {tensor minmax} {
    catch {rename t23 {}}
    tensor::create t23 -type int -initial { { -1 2 3 } { 4 5 6 } }
    set mm [t23 minmax]
    set mm2 [t23 section {1 *} minmax]
    set res {}
    set tcl_precision 17
    lappend res [expr abs([lindex $mm 0] + 1) <= 0.00001]
    lappend res [expr abs([lindex $mm 1] - 6) <= 0.00001]
    lappend res [expr abs([lindex $mm2 0] - 4) <= 0.00001]
    lappend res [expr abs([lindex $mm2 1] - 6) <= 0.00001]
  } {1 1 1 1}
  
  test compare-2.4 {tensor minmax} {
    catch {rename t23 {}}
    tensor::create t23 -type byte -initial { { 1 2 3 } { 4 5 6 } }
    set mm [t23 minmax]
    set mm2 [t23 section {1 *} minmax]
    set res {}
    set tcl_precision 17
    lappend res [expr abs([lindex $mm 0] - 1) <= 0.00001]
    lappend res [expr abs([lindex $mm 1] - 6) <= 0.00001]
    lappend res [expr abs([lindex $mm2 0] - 4) <= 0.00001]
    lappend res [expr abs([lindex $mm2 1] - 6) <= 0.00001]
  } {1 1 1 1}
  
  test compare-2.5 {tensor minmax} {
    catch {rename t23 {}}
    tensor::create t23 -type short -initial { { 1 2 3 } { 4 5 6 } }
    set mm [t23 minmax]
    set mm2 [t23 section {1 *} minmax]
    set res {}
    set tcl_precision 17
    lappend res [expr abs([lindex $mm 0] - 1) <= 0.00001]
    lappend res [expr abs([lindex $mm 1] - 6) <= 0.00001]
    lappend res [expr abs([lindex $mm2 0] - 4) <= 0.00001]
    lappend res [expr abs([lindex $mm2 1] - 6) <= 0.00001]
  } {1 1 1 1}
  
  test compare-2.6 {tensor minmax} {
    catch {rename t23 {}}
    tensor::create t23 -type unsigned -initial { { 1 2 3 } { 4 5 6 } }
    set mm [t23 minmax]
    set mm2 [t23 section {1 *} minmax]
    set res {}
    set tcl_precision 17
    lappend res [expr abs([lindex $mm 0] - 1) <= 0.00001]
    lappend res [expr abs([lindex $mm 1] - 6) <= 0.00001]
    lappend res [expr abs([lindex $mm2 0] - 4) <= 0.00001]
    lappend res [expr abs([lindex $mm2 1] - 6) <= 0.00001]
  } {1 1 1 1}
  
  test compare-2.7 {tensor minmax} {
    catch {rename t23 {}}
    tensor::create t23 -type unsigned -initial { { 1 2 3 } { 4 5 6 } }
    set mm [t23 minmax -indices]
    set mm2 [t23 section {1 *} minmax -indices]
    list $mm $mm2
  } {{{0 0} {1 2}} {{1 0} {1 2}}}
  
  
  return
}
#-------------------------------------------------------------------------------
proc credel_test {} {
  
# Tensor creation/deletion tests

  catch {rename t0 {}}
  
  test credel-1.1 {tensor command} {
    catch {rename t0 {}}
    tensor::create t0 -size {}
    list [t0 type] [t0 order]
  } {double 0}
  
  test credel-1.2 {tensor command} {
    catch {rename t5 {}}
    tensor::create t5 -size 5 -type float
    list [t5 type] [t5 order] [t5 dimensions]
  } {float 1 5}
  
  test credel-1.3 {tensor command} {
    catch {rename t23 {}}
    tensor::create t23 -type int -initial { { 1 2 3 } { 4 5 6 } }
    list [t23 type] [t23 order] [t23 dimensions]
  } {int 2 {2 3}}
  
  test credel-1.4 {tensor command} {
    catch {rename t23 {}}
    tensor::create t23 -type byte -initial { { 1 2 3 } { 4 5 6 } }
    list [t23 type] [t23 order] [t23 dimensions]
  } {byte 2 {2 3}}
  
  test credel-1.5 {tensor command} {
    catch {rename t23 {}}
    tensor::create t23 -type short -initial { { 1 2 3 } { 4 5 6 } }
    list [t23 type] [t23 order] [t23 dimensions]
  } {short 2 {2 3}}
  
  test credel-1.6 {tensor command} {
    catch {rename t23 {}}
    tensor::create t23 -type unsigned -initial { { 1 2 3 } { 4 5 6 } }
    list [t23 type] [t23 order] [t23 dimensions]
  } {unsigned 2 {2 3}}
  
  test credel-1.7 {tensor command} {
    catch {rename t23 {}}
    tensor::create t23 -type short -initial { { 1 2 3 } { 4 5 6 } }
    set retcode [catch {tensor::create t23 -size {2 3}} emsg]
    list $retcode $emsg
  } {1 {A tensor named "t23" already exists}}
  
  test credel-1.8 {tensor command} {
    catch {rename t1 {}}
    catch {tensor::create t1 -type double -initial {}}
  } {0}
  
  test credel-2.1 {Check tensor for proper contents} {
    catch {rename t23 {}}
    tensor::create t23 -type short -initial { { 1 2 3 } { 4 5 6 } }
    set l {}
    for {set i 0} {$i < 2} {incr i} {
      for {set j 0} {$j < 3} {incr j} {
	lappend l [t23 section "$i $j"]
      }
    }
    set l
  } {1 2 3 4 5 6}
  
  
  return
}
#-------------------------------------------------------------------------------
proc delete_test {} {

  # Tensor row/column delete tests

  test delete-1.1 {tensor delete command} {
    catch {rename t {}}
    tensor::create t -size 5
    t sequence
    t delete rows {0 3}
    t
  } {1.0 2.0 4.0}
  
  test delete-1.2 {tensor delete command} {
    catch {rename t35 {}}
    tensor::create t35 -size {3 5}
    t35 sequence
    t35 delete row 1
    t35
  } {{0.0 1.0 2.0 3.0 4.0} {10.0 11.0 12.0 13.0 14.0}}
  
  test delete-1.3 {tensor delete command} {
    catch {rename t35 {}}
    tensor::create t35 -size {3 5}
    t35 sequence
    t35 delete cols {1 3 4}
    t35
  } {{0.0 2.0} {5.0 7.0} {10.0 12.0}}
  
  test delete-1.4 {tensor delete command} {
    catch {rename t12 {}}
    tensor::create t12 -size {1 2}
    t12 delete 0 0
    t12
  } {}

  
  return
}
#-------------------------------------------------------------------------------
proc expr_test {} {

  # Tensor expression tests


  test expr-1.1 {Existence of tensor::expr command} {
    catch {tensor::expr}
  } {0}
  
  
  test expr-2.1 {Assignments in tensor::expr} {
    catch {rename a23 {}}
    catch {rename b23 {}}
    
    tensor::create a23 -size {2 3}
    tensor::create b23 -size {2 3}
    
    b23 sequence
    
    tensor::expr a23(i,j) = b23(i,j)
    
    a23
  } {{0.0 1.0 2.0} {3.0 4.0 5.0}}
  
  test expr-2.2 {Assignments in tensor::expr} {
    catch {rename a23 {}}
    catch {rename b23 {}}
    
    tensor::create a23 -size {2 3}
    tensor::create b23 -size {2 3}
    
    a23 sequence
    b23 sequence
    
    tensor::expr a23(i,j) += b23(i,j)
    
    a23
  } {{0.0 2.0 4.0} {6.0 8.0 10.0}}
  
  test expr-2.3 {Assignments in tensor::expr} {
    catch {rename a23 {}}
    catch {rename b23 {}}
    
    tensor::create a23 -size {2 3}
    tensor::create b23 -size {2 3}
    
    a23 sequence
    b23 sequence
    
    tensor::expr a23(i,j) -= b23(i,j)
    
    a23
  } {{0.0 0.0 0.0} {0.0 0.0 0.0}}
  
  test expr-2.4 {Assignments in tensor::expr} {
    catch {rename a23 {}}
    catch {rename b23 {}}
    
    tensor::create a23 -size {2 3}
    tensor::create b23 -size {2 3}
    
    a23 sequence
    b23 sequence
    
    tensor::expr a23(i,j) *= b23(i,j)
    
    a23
  } {{0.0 1.0 4.0} {9.0 16.0 25.0}}
  
  test expr-2.5 {Assignments in tensor::expr} {
    catch {rename a23 {}}
    catch {rename b23 {}}
    
    tensor::create a23 -size {2 3}
    tensor::create b23 -size {2 3}
    
    a23 sequence
    b23 sequence
    
    tensor::expr a23(i,j) /= b23(i,j)
    
    a23
  } {{0.0 1.0 1.0} {1.0 1.0 1.0}}
  
  
  test expr-3.1 {Simple addition in tensor::expr} {
    catch {rename a23 {}}
    catch {rename b23 {}}
    catch {rename c23 {}}
    
    tensor::create a23 -size {2 3}
    tensor::create b23 -size {2 3}
    tensor::create c23 -size {2 3}
    
    b23 sequence
    c23 = scalar 2.0
    
    tensor::expr a23(i,j) = b23(i,j) + c23(i,j)
    
    a23
  } {{2.0 3.0 4.0} {5.0 6.0 7.0}}
  
  test expr-4.1 {Transpose, multiply and contract in tensor::expr} {
    catch {rename a22 {}}
    catch {rename b23 {}}
    catch {rename c32 {}}
    
    tensor::create a22 -size {2 2}
    tensor::create b23 -size {2 3}
    tensor::create c32 -size {3 2}
    
    b23 sequence
    tensor::expr c32(i,j) = b23(j,i)
    
    tensor::expr a22(i,k) = b23(i,j)*c32(j,k)
    
    a22
  } {{5.0 14.0} {14.0 50.0}}
  
  test expr-5.1 {Simple contraction in tensor::expr} {
    catch {rename a {}}
    catch {rename b33 {}}
    
    tensor::create a -size {}
    tensor::create b33 -size {3 3}
    
    b33 sequence
    tensor::expr a() = b33(i,i)
    
    a
  } {12.0}
  
  test expr-6.1 {Scalar handling in tensor::expr} {
    catch {rename a23 {}}
    catch {rename b23 {}}
    
    tensor::create a23 -size {2 3}
    tensor::create b23 -size {2 3}
    
    b23 sequence
    tensor::expr a23(i,j) = 2.0*b23(i,j)
    
    a23
  } {{0.0 2.0 4.0} {6.0 8.0 10.0}}
  
  test expr-6.2 {Scalar handling in tensor::expr} {
    catch {rename a23 {}}
    
    tensor::create a23 -size {2 3}
    
    tensor::expr a23(i,j) = 2.0
    
    a23
  } {{2.0 2.0 2.0} {2.0 2.0 2.0}}
  
  test expr-7.1 {Subexpression handling in tensor::expr} {
    catch {rename a22 {}}
    catch {rename b23 {}}
    catch {rename c23 {}}
    catch {rename d23 {}}
    
    tensor::create a22 -size {2 2}
    tensor::create b23 -size {2 3}
    tensor::create c23 -size {2 3}
    tensor::create d23 -size {2 3}
    
    a22 sequence
    b23 sequence
    c23 sequence
    c23 *= scalar 2
    
    tensor::expr d23(i,j) = a22(i,k)*(b23(k,j) + c23(k,j))
    
    d23
  } {{9.0 12.0 15.0} {27.0 42.0 57.0}}
  
  #@@@ NOTE: We need "-0.0" in the expected result to make
  #@@@ this work on Linux. This may fail on other architectures.
  
  test expr-8.1 {Unary minus handling in tensor::expr} {
    catch {rename a23 {}}
    catch {rename b23 {}}
    
    tensor::create a23 -size {2 3}
    tensor::create b23 -size {2 3}
    
    b23 sequence
    
    tensor::expr a23(i,j) = -b23(i,j)
    
    a23
  } {{-0.0 -1.0 -2.0} {-3.0 -4.0 -5.0}}
  
  test expr-9.1 {Index set specification in tensor::expr} {
    catch {rename a23 {}}
    catch {rename b23 {}}
    
    tensor::create a23 -size {2 3}
    tensor::create b23 -size {2 3}
    
    b23 sequence
    
    tensor::expr a23(i,j) = b23(i=1:0:-1,j)
    
    a23
  } {{3.0 4.0 5.0} {0.0 1.0 2.0}}
  
  test expr-9.2 {Index set specification in tensor::expr} {
    catch {rename a23 {}}
    
    tensor::create a23 -size {2 3}
    
    tensor::expr a23(i=0,j) = 11
    
    a23
  } {{11.0 11.0 11.0} {0.0 0.0 0.0}}
  
  
  return
}
#-------------------------------------------------------------------------------
proc insert_test {} {
  
  # Tensor row/column insert tests
  
  test insert-1.1 {tensor insert command} {
    catch {rename t {}}
    tensor::create t -size 5
    t sequence
    t insert 2 rows before 0
    t
  } {0.0 0.0 0.0 1.0 2.0 3.0 4.0}
  
  test insert-1.2 {tensor insert command} {
    catch {rename t {}}
    tensor::create t -size 5
    t sequence
    t insert 2 rows after 1
    t
  } {0.0 1.0 0.0 0.0 2.0 3.0 4.0}
  
  test insert-1.3 {tensor insert command} {
    catch {rename t {}}
    tensor::create t -size 5
    t sequence
    t insert 1 row after 4
    t
  } {0.0 1.0 2.0 3.0 4.0 0.0}
  
  test insert-2.1 {tensor insert command} {
    catch {rename t35 {}}
    tensor::create t35 -size {3 5}
    t35 sequence
    t35 insert 1 row before 0
    t35
  } {{0.0 0.0 0.0 0.0 0.0} {0.0 1.0 2.0 3.0 4.0} {5.0 6.0 7.0 8.0 9.0} {10.0 11.0 12.0 13.0 14.0}}
  
  test insert-2.2 {tensor insert command} {
    catch {rename t35 {}}
    tensor::create t35 -size {3 5}
    t35 sequence
    t35 insert 1 row after 0
    t35
  } {{0.0 1.0 2.0 3.0 4.0} {0.0 0.0 0.0 0.0 0.0} {5.0 6.0 7.0 8.0 9.0} {10.0 11.0 12.0 13.0 14.0}}
  
  test insert-2.3 {tensor insert command} {
    catch {rename t35 {}}
    tensor::create t35 -size {3 5}
    t35 sequence
    t35 insert 1 row after 2
    t35
  } {{0.0 1.0 2.0 3.0 4.0} {5.0 6.0 7.0 8.0 9.0} {10.0 11.0 12.0 13.0 14.0} {0.0 0.0 0.0 0.0 0.0}}
  
  test insert-3.1 {tensor insert command} {
    catch {rename t35 {}}
    tensor::create t35 -size {3 5}
    t35 sequence
    t35 insert 1 column before 0
    t35
  } {{0.0 0.0 1.0 2.0 3.0 4.0} {0.0 5.0 6.0 7.0 8.0 9.0} {0.0 10.0 11.0 12.0 13.0 14.0}}
  
  test insert-3.2 {tensor insert command} {
    catch {rename t35 {}}
    tensor::create t35 -size {3 5}
    t35 sequence
    t35 insert 1 column after 0
    t35
  } {{0.0 0.0 1.0 2.0 3.0 4.0} {5.0 0.0 6.0 7.0 8.0 9.0} {10.0 0.0 11.0 12.0 13.0 14.0}}
  
  test insert-3.3 {tensor insert command} {
    catch {rename t35 {}}
    tensor::create t35 -size {3 5}
    t35 sequence
    t35 insert 1 column after 4
    t35
  } {{0.0 1.0 2.0 3.0 4.0 0.0} {5.0 6.0 7.0 8.0 9.0 0.0} {10.0 11.0 12.0 13.0 14.0 0.0}}
  
  test insert-3.4 {tensor insert command} {
    catch {rename t35 {}}
    tensor::create t35 -size {3 5}
    t35 sequence
    t35 insert 1 column after end
    t35
  } {{0.0 1.0 2.0 3.0 4.0 0.0} {5.0 6.0 7.0 8.0 9.0 0.0} {10.0 11.0 12.0 13.0 14.0 0.0}}
  
  
  return
}
#-------------------------------------------------------------------------------
proc isempty_test {} {

  # Tensor "is_empty" tests
  
  catch {rename t0 {}}
  
  test isempty-1.1 {tensor "is_empty" command} {
    catch {rename t0 {}}
    tensor::create t0 -size 5
    set r1 [catch "t0 is_empty foo"]
    set r2 [catch "t0 is_empty yes no"]
    list $r1 $r2
  } {1 1}
  
  test isempty-2.1 {tensor "is_empty" command} {
    catch {rename t0 {}}
    tensor::create t0 -type float -initial {-2 -1 0 1 2}
    t0 is_empty
  } {0}
  
  test isempty-2.2 {tensor "is_empty" command} {
    catch {rename t0 {}}
    tensor::create t0 -type int -size {3 5}
    t0 is_empty
  } {0}
  
  test isempty-2.3 {tensor "is_empty" command} {
    catch {rename t0 {}}
    tensor::create t0 -type int -size {3 0 5}
    t0 is_empty
  } {1}
  
  test isempty-2.4 {tensor "is_empty" command} {
    catch {rename t0 {}}
    tensor::create t0 -type int -size {0 5}
    t0 is_empty
  } {1}
  
  test isempty-2.5 {tensor "is_empty" command} {
    catch {rename t0 {}}
    tensor::create t0 -type int -size {0}
    t0 is_empty
  } {1}
  
  return
}
#-------------------------------------------------------------------------------
proc istns_test {} {

  # Tensor renaming/deletion tests
  
  test istns-1.1 {tensor::exists command} {
    set r1 [catch {tensor::exists}]
    set r2 [catch {tensor::exists foo bar}]
    list $r1 $r2
  } {1 1}

  test istns-1.2 {tensor::exists command} {
    catch {rename t1 {}}
    catch {rename t2 {}}
    catch {rename t33 {}}
    catch {rename foo {}}
    tensor::create t1 -size 1
    tensor::create t2 -size 2
    tensor::create t33 -size {3 3}
    list [tensor::exists t1] [tensor::exists t2] [tensor::exists t33] [tensor::exists if] [tensor::exists foo]
  } {1 1 1 0 0}

  test istns-1.3 {tensor::exists command} {
    catch {rename t1 {}}
    tensor::create t1 -size 1
    rename t1 a1
    list [tensor::exists t1] [tensor::exists a1]
  } {0 1}
  
  
  return
}
#-------------------------------------------------------------------------------
proc listind_test {} {

  # Tensor "listindices" tests
  
  catch {rename t0 {}}

  test listind-1.1 {tensor "listindices" command} {
    catch {rename t0 {}}
    tensor::create t0 -size 5
    set r1 [catch {t0 listindices}]
    set r2 [catch {t0 listindices where}]
    set r3 [catch {t0 listindices 0 where}]
    set r4 [catch {t0 listindices where <=}]
    set r5 [catch {t0 listindices where foo}]
    set r6 [catch {t0 listindices 1 where <= scalar 1}]
    list $r1 $r2 $r3 $r4 $r5 $r6
  } {1 1 1 1 1 1}
  
  test listind-2.1 {tensor "listindices" command} {
    catch {rename t5 {}}
    tensor::create t5 -type float -initial {-2 -1 0 1 2}
    t5 listindices where >= scalar 0
  } {2 3 4}
  
  test listind-2.2 {tensor "listindices" command} {
    catch {rename t5 {}}
    tensor::create t5 -type float -initial {-2 -1 0 1 2}
    t5 section {{0 2}} listindices where >= scalar 0
  } {2}
  
  test listind-2.3 {tensor "listindices" command} {
    catch {rename t23 {}}
    tensor::create t23 -size {2 3}
    t23 listindices where >= scalar 0
  } {{0 0} {0 1} {0 2} {1 0} {1 1} {1 2}}
  
  test listind-2.4 {tensor "listindices" command} {
    catch {rename t23 {}}
    tensor::create t23 -size {2 3}
    t23 listindices 1 where >= scalar 0
  } {0 1 2 0 1 2}
  
  
  return
}
#-------------------------------------------------------------------------------
proc ops_test {} {

  # Tensor operation tests

  test ops-1.1 {tensor assignment - scalar} {
    catch {rename t23 {}}
    tensor::create t23 -type int -size {2 3}
    t23 = scalar 1
    set l {}
    for {set i 0} {$i < 2} {incr i} {
    for {set j 0} {$j < 3} {incr j} {
      lappend l [t23 section "$i $j"]
    }
    }
    set l
  } {1 1 1 1 1 1}
  
  test ops-1.2 {tensor assignment - scalar} {
    catch {rename t23 {}}
    tensor::create t23 -type int -size {2 3}
    t23 section {0 *} = scalar 1
    t23 section {1 *} = scalar 2
    set l {}
    for {set i 0} {$i < 2} {incr i} {
    for {set j 0} {$j < 3} {incr j} {
      lappend l [t23 section "$i $j"]
    }
    }
    set l
  } {1 1 1 2 2 2}
  
  test ops-1.3 {tensor assignment - scalar} {
    catch {rename t23 {}}
    tensor::create t23 -type int -size {2 3}
    t23 section {* 0} = scalar 1
    t23 section {* 1} = scalar 2
    t23 section {* 2} = scalar 3
    set l {}
    for {set i 0} {$i < 2} {incr i} {
    for {set j 0} {$j < 3} {incr j} {
      lappend l [t23 section "$i $j"]
    }
    }
    set l
  } {1 2 3 1 2 3}
  
  test ops-1.4 {tensor assignment - array} {
    catch {rename t23 {}}
    tensor::create t23 -type int -size {2 3}
    t23 = array { { 1 2 3 } { 4 5 6 } }
    set l {}
    for {set i 0} {$i < 2} {incr i} {
    for {set j 0} {$j < 3} {incr j} {
      lappend l [t23 section "$i $j"]
    }
    }
    set l
  } {1 2 3 4 5 6}
  
  test ops-1.5 {tensor assignment - array, scalar} {
    catch {rename t23 {}}
    tensor::create t23 -type int -size {2 3}
    t23 = array { { 1 2 3 } { 4 5 6 } }
    t23 section {{0 1} {0 1}} = scalar 10
    set l {}
    for {set i 0} {$i < 2} {incr i} {
    for {set j 0} {$j < 3} {incr j} {
      lappend l [t23 section "$i $j"]
    }
    }
    set l
  } {10 10 3 10 10 6}
  
  test ops-1.6 {tensor assignment - tensor} {
    catch {rename t23 {}}
    catch {rename u23 {}}
    tensor::create t23 -type int -initial { { 1 2 3 } { 4 5 6 } }
    tensor::create u23 -type int -initial { { 4 5 6 } { 7 8 9 } }
    t23 = tensor u23
    set l {}
    for {set i 0} {$i < 2} {incr i} {
    for {set j 0} {$j < 3} {incr j} {
      lappend l [t23 section "$i $j"]
    }
    }
    set l
  } {4 5 6 7 8 9}
  
  test ops-1.7 {tensor assignment - tensor} {
    catch {rename t23 {}}
    catch {rename u23 {}}
    tensor::create t23 -type int -initial { { 1 2 3 } { 4 5 6 } }
    tensor::create u23 -type int -initial { { 4 5 6 } { 7 8 9 } }
    t23 section {0 *} = tensor u23 section {1 *}
    set l {}
    for {set i 0} {$i < 2} {incr i} {
    for {set j 0} {$j < 3} {incr j} {
      lappend l [t23 section "$i $j"]
    }
    }
    set l
  } {7 8 9 4 5 6}
  
  test ops-1.8 {tensor assignment - contraction} {
    catch {rename t0  {}}
    catch {rename t33 {}}
    tensor::create t0  -size {}
    tensor::create t33 -initial { { 1 0 0 } { 0 1 0 } { 0 0 1 } }
    t0 = contraction t33 {0 1}
    t0
  } {3.0}
  
  test ops-1.9 {tensor assignment - contraction} {
    catch {rename t5 {}}
    catch {rename t335 {}}
    tensor::create t5 -size 5
    tensor::create t335 -size {3 3 5}
    for {set i 0} {$i < 5} {incr i} {
      t335 section "* * $i" = scalar $i
    }
    t5 = contraction t335 {0 1}
    t5
  } {0.0 3.0 6.0 9.0 12.0}
  
  test ops-1.10 {tensor assignment - product} {
    catch {rename t34 {}}
    catch {rename t45 {}}
    catch {rename t35 {}}
    tensor::create t34 -size {3 4}
    tensor::create t45 -size {4 5}
    tensor::create t35 -size {3 5}
    set c 1
    for {set i 0} {$i < 3} {incr i} {
    for {set j 0} {$j < 4} {incr j} {
      t34 section "$i $j" = scalar $c
      incr c
    }
    }
    set c 1
    for {set i 0} {$i < 4} {incr i} {
    for {set j 0} {$j < 5} {incr j} {
      t45 section "$i $j" = scalar $c
      incr c
    }
    }
    t35 = multensor t34 t45 {1 0}
    t35
  } {{110.0 120.0 130.0 140.0 150.0} {246.0 272.0 298.0 324.0 350.0} {382.0 424.0 466.0 508.0 550.0}}
  
  test ops-1.11 {tensor assignment - outer product} {
    catch {rename t3 {}}
    catch {rename t4 {}}
    catch {rename t34 {}}
    tensor::create t3  -size {3}
    tensor::create t4  -size {4}
    tensor::create t34 -size {3 4}
    set c 1
    for {set i 0; set j 1} {$i < 3} {incr i; incr j} {
      t3 section $i = scalar $j
    }
    for {set i 0; set j 1} {$i < 4} {incr i; incr j} {
      t4 section $i = scalar $j
    }
    t34 = outer t3 t4
    t34
  } {{1.0 2.0 3.0 4.0} {2.0 4.0 6.0 8.0} {3.0 6.0 9.0 12.0}}
  
  test ops-1.12 {tensor assignment - outer product} {
    catch {rename t422 {}}
    catch {rename t42 {}}
    catch {rename t2 {}}
    tensor::create t422 -size {4 2 2}
    tensor::create t42 -initial {{1 2} {3 4} {5 6} {7 8}}
    tensor::create t2 -initial {1 2}
    t422 = outer t42 t2
    t422
  } {{{1.0 2.0} {2.0 4.0}} {{3.0 6.0} {4.0 8.0}} {{5.0 10.0} {6.0 12.0}} {{7.0 14.0} {8.0 16.0}}}
  
  test ops-2.0 {tensor addition - scalar} {
    catch {rename t23 {}}
    tensor::create t23 -type int -initial { { 1 2 3 } { 4 5 6 } }
    t23 += scalar 1
    set l {}
    for {set i 0} {$i < 2} {incr i} {
    for {set j 0} {$j < 3} {incr j} {
      lappend l [t23 section "$i $j"]
    }
    }
    set l
  } {2 3 4 5 6 7}

  test ops-2.1 {tensor addition - tensor} {
    catch {rename t23 {}}
    catch {rename u23 {}}
    tensor::create t23 -type int -initial { { 1 2 3 } { 4 5 6 } }
    tensor::create u23 -type int -initial { { 4 5 6 } { 7 8 9 } }
    t23 += tensor u23
    set l {}
    for {set i 0} {$i < 2} {incr i} {
    for {set j 0} {$j < 3} {incr j} {
      lappend l [t23 section "$i $j"]
    }
    }
    set l
  } {5 7 9 11 13 15}

  test ops-2.2 {tensor subtraction - scalar} {
    catch {rename t23 {}}
    tensor::create t23 -type int -initial { { 1 2 3 } { 4 5 6 } }
    t23 -= scalar 1
    set l {}
    for {set i 0} {$i < 2} {incr i} {
    for {set j 0} {$j < 3} {incr j} {
      lappend l [t23 section "$i $j"]
    }
    }
    set l
  } {0 1 2 3 4 5}

  test ops-2.3 {tensor multiplication - scalar} {
    catch {rename t23 {}}
    tensor::create t23 -type int -initial { { 1 2 3 } { 4 5 6 } }
    t23 *= scalar 2
    set l {}
    for {set i 0} {$i < 2} {incr i} {
    for {set j 0} {$j < 3} {incr j} {
      lappend l [t23 section "$i $j"]
    }
    }
    set l
  } {2 4 6 8 10 12}

  test ops-2.4 {tensor division - scalar} {
    catch {rename t23 {}}
    tensor::create t23 -type int -initial { { 2 4 6 } { 8 10 12 } }
    t23 /= scalar 2
    set l {}
    for {set i 0} {$i < 2} {incr i} {
    for {set j 0} {$j < 3} {incr j} {
      lappend l [t23 section "$i $j"]
    }
    }
    set l
  } {1 2 3 4 5 6}
  
  # This caused a core dump.
  
  test ops-3.1 {tensor assignment - bogus array} {
    catch {rename t44 {}}
    tensor::create t44 -type float -size {4 4}
    catch { t44 section {* 2} = array {{} {} {} {}} }
  } {1}
  
  
  
  return
}
#-------------------------------------------------------------------------------
proc permute_test {} {

  
  test permute-1.1 {tensor command} {
    catch {rename t {}}
    tensor::create t -size 5
    t sequence
    t permute rows {0 3 2 1 4}
    t
  } {0.0 3.0 2.0 1.0 4.0}
  
  test permute-1.2 {tensor command} {
    catch {rename t35 {}}
    tensor::create t35 -size {3 5}
    t35 sequence
    t35 permute rows {2 1 0}
    t35
  } {{10.0 11.0 12.0 13.0 14.0} {5.0 6.0 7.0 8.0 9.0} {0.0 1.0 2.0 3.0 4.0}}
  
  test permute-1.3 {tensor command} {
    catch {rename t35 {}}
    tensor::create t35 -size {3 5}
    t35 sequence
    t35 permute cols {2 1 0 3 4}
    t35
  } {{2.0 1.0 0.0 3.0 4.0} {7.0 6.0 5.0 8.0 9.0} {12.0 11.0 10.0 13.0 14.0}}
  
  return
}
#-------------------------------------------------------------------------------
proc put_test {} {

  # Tensor "put" tests
  
  test put-1.1 {tensor put into array} {
    catch {rename t23 {}}
    global a23
    catch {unset a23}
    tensor::create t23 -type int -size {2 3}
    t23 = scalar 1
    t23 put into a23
    lsort [array names a23]
  } {0,0 0,1 0,2 1,0 1,1 1,2}
  
  test put-1.2 {tensor put into array} {
    catch {rename t23 {}}
    global a23
    catch {unset a23}
    tensor::create t23 -type int -size {2 3}
    t23 sequence
    t23 put into a23
    list $a23(0,0) $a23(0,1) $a23(0,2) $a23(1,0) $a23(1,1) $a23(1,2)
  } {0 1 2 3 4 5}
  
  test put-1.3 {tensor put into array} {
    catch {rename t5 {}}
    global a5
    catch {unset a5}
    tensor::create t5 -type float -size 5
    t5 = scalar 1
    t5 put into a5
    lsort [array names a5]
  } {0 1 2 3 4}
  
  test put-1.4 {tensor put into array} {
    catch {rename t5 {}}
    global a5
    catch {unset a5}
    tensor::create t5 -type float -size 5
    t5 sequence
    t5 put into a5
    list $a5(0) $a5(1) $a5(2) $a5(3) $a5(4)
  } {0.0 1.0 2.0 3.0 4.0}
  
  test put-1.5 {tensor put into array} {
    catch {rename t0 {}}
    global a0
    catch {unset a0}
    tensor::create t0 -type double -size {}
    t0 = scalar 1
    t0 put into a0
    list [array names a0] $a0()
  } {{{}} 1.0}
  
  test put-1.6 {tensor put into array} {
    catch {rename t232 {}}
    global a232
    catch {unset a232}
    tensor::create t232 -type float -size {2 3 2}
    t232 sequence
    t232 put into a232
    lsort [array names a232]
  } {0,0,0 0,0,1 0,1,0 0,1,1 0,2,0 0,2,1 1,0,0 1,0,1 1,1,0 1,1,1 1,2,0 1,2,1}
  
  test put-1.7 {tensor put into array} {
    catch {rename t232 {}}
    global a232
    catch {unset a232}
    tensor::create t232 -type float -size {2 3 2}
    t232 sequence
    t232 put into a232
    list $a232(0,0,0) $a232(0,0,1) \
      $a232(0,1,0) $a232(0,1,1) \
      $a232(0,2,0) $a232(0,2,1) \
      $a232(1,0,0) $a232(1,0,1) \
      $a232(1,1,0) $a232(1,1,1) \
      $a232(1,2,0) $a232(1,2,1)
  } {0.0 1.0 2.0 3.0 4.0 5.0 6.0 7.0 8.0 9.0 10.0 11.0}
  
  test put-2.1 {tensor put into array} {
    catch {rename t1 {}}
    global a1
    catch {unset a1}
    tensor::create t1 -type int -initial {2 4 6 8 10}
    t1 put into a1
    list $a1(0) $a1(1) $a1(2) $a1(3) $a1(4)
  } {2 4 6 8 10}
  
  test put-2.2 {tensor put into array} {
    catch {rename t1 {}}
    global a1
    catch {unset a1}
    tensor::create t1 -type short -initial {65 66 67 68 69}
    t1 put into a1
    list $a1(0) $a1(1) $a1(2) $a1(3) $a1(4)
  } {65 66 67 68 69}
  
  test put-2.3 {tensor put into array} {
    catch {rename t1 {}}
    global a1
    catch {unset a1}
    tensor::create t1 -type unsigned -initial {65 66 67 68 69}
    t1 put into a1
    list $a1(0) $a1(1) $a1(2) $a1(3) $a1(4)
  } {65 66 67 68 69}
  
  test put-3.1 {tensor put into array} {
    catch {rename t1 {}}
    global a1
    catch {unset a1}
    tensor::create t1 -type unsigned -initial {1 2 3 4 5}
    t1 put into a1 -offset 1
    lsort [array names a1]
  } {1 2 3 4 5}
  
  test put-3.2 {tensor put into array} {
    catch {rename t1 {}}
    global a1
    catch {unset a1}
    tensor::create t1 -type unsigned -initial {1 2 3 4 5}
    t1 put into a1 -offset 1
    list $a1(1) $a1(2) $a1(3) $a1(4) $a1(5)
  } {1 2 3 4 5}
  
  test put-4.1 {tensor put into array} {
    catch {rename t1 {}}
    global a1
    catch {unset a1}
    tensor::create t1 -type unsigned -initial {1 2 3 4 5}
    for {set i 0} {$i < 5} {incr i} {
      set a1($i) x
    }
    t1 put into a1 if >= 3
    list $a1(0) $a1(1) $a1(2) $a1(3) $a1(4)
  } {x x 3 4 5}
  
  
  return
}
#-------------------------------------------------------------------------------
proc readwrite_test {} {
  
  # Tensor read/write tests

  # Temp file setup
  
  global tcl_platform

  switch $tcl_platform(platform) {
    {unix} {
      set TNSRWTMP "/tmp"
    }
    {windows} {
      file mkdir [file join [pwd] tmp]
      set TNSRWTMP "[file join [pwd] tmp]"
    }
  }

  test readwrite-1.1 {tensor read/write} {
    catch {rename t23 {}}
    catch {rename u23 {}}
    tensor::create t23 -type int -size {2 3}
    t23 = scalar 1
    set tmpfname "[file join $TNSRWTMP readwrite[pid]]"
    t23 write $tmpfname
    tensor::create u23 -initfile $tmpfname
    file delete $tmpfname
    list [u23 type] [u23 order] [u23 dimensions] [t23 == tensor u23]
  } {int 2 {2 3} 1}
  
  test readwrite-1.2 {tensor read/write} {
    catch {rename t23 {}}
    catch {rename u23 {}}
    tensor::create t23 -type int -size {2 3}
    t23 = scalar 1
    set tmpfname "[file join $TNSRWTMP readwrite[pid]]"
    set f [open $tmpfname "w"]
    t23 writechannel $f
    close $f
    tensor::create u23 -initfile $tmpfname
    file delete $tmpfname
    list [u23 type] [u23 order] [u23 dimensions] [t23 == tensor u23]
  } {int 2 {2 3} 1}
  
  test readwrite-1.3 {tensor read/write} {
    catch {rename t23 {}}
    catch {rename u23 {}}
    tensor::create t23 -type int -size {2 3}
    t23 = scalar 1
    set tmpfname "[file join $TNSRWTMP readwrite[pid]]"
    t23 write $tmpfname
    set f [open $tmpfname "r"]
    tensor::create u23 -initchannel $f
    close $f
    file delete $tmpfname
    list [u23 type] [u23 order] [u23 dimensions] [t23 == tensor u23]
  } {int 2 {2 3} 1}
  
  test readwrite-1.4 {tensor read/write} {
    catch {rename t23 {}}
    catch {rename u23 {}}
    tensor::create t23 -type int -size {2 3}
    t23 = scalar 1
    set tmpfname "[file join $TNSRWTMP readwrite[pid]]"
    t23 write $tmpfname
    tensor::create u23 -type int -size {2 3}
    set f [open $tmpfname "r"]
    u23 = channel $f
    close $f
    file delete $tmpfname
    list [u23 type] [u23 order] [u23 dimensions] [t23 == tensor u23]
  } {int 2 {2 3} 1}
  
  test readwrite-1.5 {tensor read/write} {
    catch {rename t23 {}}
    catch {rename u23 {}}
    tensor::create t23 -type int -size {2 3}
    t23 = scalar 1
    set tmpfname "[file join $TNSRWTMP readwrite[pid]]"
    t23 write $tmpfname
    tensor::create u23 -type int -size {2 3}
    u23 = file $tmpfname
    file delete $tmpfname
    list [u23 type] [u23 order] [u23 dimensions] [t23 == tensor u23]
  } {int 2 {2 3} 1}
  
  test readwrite-1.6 {tensor read/write} {
    catch {rename t113 {}}
    catch {rename u113 {}}
    tensor::create t113 -type int -size {1 1 3}
    t113 = scalar 1
    set tmpfname "[file join $TNSRWTMP readwrite[pid]]"
    t113 write $tmpfname
    tensor::create u113 -initfile $tmpfname
    file delete $tmpfname
    list [u113 type] [u113 order] [u113 dimensions] [t113 == tensor u113]
  } {int 3 {1 1 3} 1}
  
  test readwrite-2.1 {tensor read/write (binary)} {
    catch {rename t23 {}}
    catch {rename u23 {}}
    tensor::create t23 -type int -size {2 3}
    t23 = scalar 1
    t23 section {0 0} = scalar 2
    set tmpfname "[file join $TNSRWTMP readwrite[pid]]"
    t23 write $tmpfname binary
    tensor::create u23 -type int -size {2 3}
    u23 = file $tmpfname
    file delete $tmpfname
    list [u23 type] [u23 order] [u23 dimensions] [t23 == tensor u23]
  } {int 2 {2 3} 1}
  
  test readwrite-2.2 {tensor read/write (binary)} {
    catch {rename t23 {}}
    catch {rename u23 {}}
    tensor::create t23 -type short -size {2 3}
    t23 = scalar 1
    t23 section {0 0} = scalar 2
    set tmpfname "[file join $TNSRWTMP readwrite[pid]]"
    t23 write $tmpfname binary
    tensor::create u23 -type short -size {2 3}
    u23 = file $tmpfname
    file delete $tmpfname
    list [u23 type] [u23 order] [u23 dimensions] [t23 == tensor u23]
  } {short 2 {2 3} 1}
  
  test readwrite-2.3 {tensor read/write (binary)} {
    catch {rename t23 {}}
    catch {rename u23 {}}
    tensor::create t23 -type byte -size {2 3}
    t23 = scalar 1
    t23 section {0 0} = scalar 2
    set tmpfname "[file join $TNSRWTMP readwrite[pid]]"
    t23 write $tmpfname binary
    tensor::create u23 -type byte -size {2 3}
    u23 = file $tmpfname
    file delete $tmpfname
    list [u23 type] [u23 order] [u23 dimensions] [t23 == tensor u23]
  } {byte 2 {2 3} 1}
  
  test readwrite-2.4 {tensor read/write (binary)} {
    catch {rename t23 {}}
    catch {rename u23 {}}
    tensor::create t23 -type unsigned -size {2 3}
    t23 = scalar 1
    t23 section {0 0} = scalar 2
    set tmpfname "[file join $TNSRWTMP readwrite[pid]]"
    t23 write $tmpfname binary
    tensor::create u23 -type unsigned -size {2 3}
    u23 = file $tmpfname
    file delete $tmpfname
    list [u23 type] [u23 order] [u23 dimensions] [t23 == tensor u23]
  } {unsigned 2 {2 3} 1}
  
  test readwrite-2.5 {tensor read/write (binary)} {
    catch {rename t23 {}}
    catch {rename u23 {}}
    tensor::create t23 -type double -size {2 3}
    t23 = scalar 1
    t23 section {0 0} = scalar 2
    set tmpfname "[file join $TNSRWTMP readwrite[pid]]"
    t23 write $tmpfname binary
    tensor::create u23 -type double -size {2 3}
    u23 = file $tmpfname
    file delete $tmpfname
    list [u23 type] [u23 order] [u23 dimensions] [t23 == tensor u23]
  } {double 2 {2 3} 1}
  
  test readwrite-2.6 {tensor read/write (binary)} {
    catch {rename t23 {}}
    catch {rename u23 {}}
    tensor::create t23 -type float -size {2 3}
    t23 = scalar 1
    t23 section {0 0} = scalar 2
    set tmpfname "[file join $TNSRWTMP readwrite[pid]]"
    t23 write $tmpfname binary
    tensor::create u23 -type float -size {2 3}
    u23 = file $tmpfname
    file delete $tmpfname
    list [u23 type] [u23 order] [u23 dimensions] [t23 == tensor u23]
  } {float 2 {2 3} 1}
  
  test readwrite-2.7 {tensor read/write (binary)} {
    catch {rename t3 {}}
    tensor::create t3 -type float -initial {2256.08 -565.60 2257.14}
    set tmpfname "[file join $TNSRWTMP readwrite[pid]]"
    t3 write $tmpfname binary
    tensor::create u3 -initfile $tmpfname
    file delete $tmpfname
    u3 -= tensor t3
    list [u3 <= scalar 0.01] [u3 >= scalar -0.01]
  } {1 1}
  
  
  test readwrite-3.1 {tensor read/write (ascii)} {
    catch {rename t23 {}}
    catch {rename u23 {}}
    tensor::create t23 -type int -size {2 3}
    t23 = scalar 1
    t23 section {0 0} = scalar 2
    set tmpfname "[file join $TNSRWTMP readwrite[pid]]"
    t23 write $tmpfname text
    tensor::create u23 -type int -size {2 3}
    u23 = file $tmpfname
    file delete $tmpfname
    list [u23 type] [u23 order] [u23 dimensions] [t23 == tensor u23]
  } {int 2 {2 3} 1}
  
  test readwrite-3.2 {tensor read/write (ascii)} {
    catch {rename t23 {}}
    catch {rename u23 {}}
    tensor::create t23 -type short -size {2 3}
    t23 = scalar 1
    t23 section {0 0} = scalar 2
    set tmpfname "[file join $TNSRWTMP readwrite[pid]]"
    t23 write $tmpfname ascii
    tensor::create u23 -type short -size {2 3}
    u23 = file $tmpfname
    file delete $tmpfname
    list [u23 type] [u23 order] [u23 dimensions] [t23 == tensor u23]
  } {short 2 {2 3} 1}
  
  test readwrite-3.3 {tensor read/write (ascii)} {
    catch {rename t23 {}}
    catch {rename u23 {}}
    tensor::create t23 -type byte -size {2 3}
    t23 = scalar 1
    t23 section {0 0} = scalar 2
    set tmpfname "[file join $TNSRWTMP readwrite[pid]]"
    t23 write $tmpfname ascii
    tensor::create u23 -type byte -size {2 3}
    u23 = file $tmpfname
    file delete $tmpfname
    list [u23 type] [u23 order] [u23 dimensions] [t23 == tensor u23]
  } {byte 2 {2 3} 1}
  
  test readwrite-3.4 {tensor read/write (ascii)} {
    catch {rename t23 {}}
    catch {rename u23 {}}
    tensor::create t23 -type unsigned -size {2 3}
    t23 = scalar 1
    t23 section {0 0} = scalar 2
    set tmpfname "[file join $TNSRWTMP readwrite[pid]]"
    t23 write $tmpfname ascii
    tensor::create u23 -type unsigned -size {2 3}
    u23 = file $tmpfname
    file delete $tmpfname
    list [u23 type] [u23 order] [u23 dimensions] [t23 == tensor u23]
  } {unsigned 2 {2 3} 1}
  
  test readwrite-3.5 {tensor read/write (ascii)} {
    catch {rename t23 {}}
    catch {rename u23 {}}
    tensor::create t23 -type double -size {2 3}
    t23 = scalar 1
    t23 section {0 0} = scalar 2
    set tmpfname "[file join $TNSRWTMP readwrite[pid]]"
    t23 write $tmpfname ascii
    tensor::create u23 -type double -size {2 3}
    u23 = file $tmpfname
    file delete $tmpfname
    list [u23 type] [u23 order] [u23 dimensions] [t23 == tensor u23]
  } {double 2 {2 3} 1}
  
  test readwrite-3.6 {tensor read/write (ascii)} {
    catch {rename t23 {}}
    catch {rename u23 {}}
    tensor::create t23 -type float -size {2 3}
    t23 = scalar 1
    t23 section {0 0} = scalar 2
    set tmpfname "[file join $TNSRWTMP readwrite[pid]]"
    t23 write $tmpfname ascii
    tensor::create u23 -type float -size {2 3}
    u23 = file $tmpfname
    file delete $tmpfname
    list [u23 type] [u23 order] [u23 dimensions] [t23 == tensor u23]
  } {float 2 {2 3} 1}
  
  # Temp file cleanup
  
  switch $tcl_platform(platform) {
    {unix} {
      # Don't need to do anything
    }
    {windows} {
      # Remove the temporary directory.
      
      file delete -force [file join [pwd] tmp]
    }
  }
   
  
  return
}
#-------------------------------------------------------------------------------
proc rearrange_test {} {

  # Tensor "storage rearrangement" tests

  test rearrange-1.1 {tensor storage rearrangement} {
    catch {rename t23 {}}
    tensor::create t23 -type int -size {2 3}
    t23 permuteindices {1 0}
    list [t23 type] [t23 order] [t23 dimensions]
  } {int 2 {3 2}}
  
  test rearrange-1.2 {tensor storage rearrangement} {
    catch {rename t23 {}}
    tensor::create t23 -type int -initial { { 1 2 3 } { 4 5 6 } }
    t23 permuteindices {1 0}
    t23
  } {{1 4} {2 5} {3 6}}
  
  test rearrange-1.3 {tensor storage rearrangement} {
    catch {rename t23 {}}
    tensor::create t23 -type int -initial { { 1 2 3 } { 4 5 6 } }
    t23 flipindices {1}
    t23
  } {{3 2 1} {6 5 4}}
  
  test rearrange-1.4 {tensor storage rearrangement} {
    catch {rename t23 {}}
    tensor::create t23 -type int -initial { { 1 2 3 } { 4 5 6 } }
    t23 flipindices {0}
    t23
  } {{4 5 6} {1 2 3}}
  
  test rearrange-1.5 {tensor storage rearrangement} {
    catch {rename t23 {}}
    tensor::create t23 -type int -initial { { 1 2 3 } { 4 5 6 } }
    t23 flipindices {0 1}
    t23
  } {{6 5 4} {3 2 1}}
  
  test rearrange-1.6 {tensor storage rearrangement} {
    catch {rename t234 {}}
    tensor::create t234 -type int -size {2 3 4}
    t234 permuteindices {0 2 1}
    t234 dimensions
  } {2 4 3}
  
  test rearrange-1.7 {tensor storage rearrangement} {
    catch {rename t234 {}}
    tensor::create t234 -type int -initial {
      {
        {1 2 3 4}
        {5 6 7 8}
        {9 10 11 12}
      }
      {
        {13 14 15 16}
        {17 18 19 20}
        {21 22 23 24}
      }
    }
    t234 permuteindices {0 2 1}
    t234
  } {{{1 5 9} {2 6 10} {3 7 11} {4 8 12}} {{13 17 21} {14 18 22} {15 19 23} {16 20 24}}}
  
  test rearrange-2.1 {tensor reshape test} {
    catch {rename t20 {}}
    tensor::create t20 -size 20
    t20 sequence
    set e1 [catch {t20 reshape}]
    set e2 [catch {t20 reshape foo}]
    set e3 [catch {t20 reshape {5 4} 0}]
    set e4 [catch {t20 reshape {5 5}}]
    list $e1 $e2 $e3 $e4
  } {1 1 1 1}
  
  test rearrange-2.2 {tensor reshape test} {
    catch {rename t20 {}}
    tensor::create t20 -size 20
    t20 reshape {5 4}
    t20 reshape {2 2 5}
    t20 reshape 20
  } {}
  
  test rearrange-2.3 {tensor reshape test} {
    catch {rename t20 {}}
    tensor::create t20 -size 20
    t20 reshape {2 2 5}
    t20 dimensions
  } {2 2 5}
  
  test rearrange-3.1 {tensor permuteindices test} {
    catch {rename t345 {}}
    catch {rename u345 {}}
    
    tensor::create t345 -size {3 4 5}
    t345 sequence
    t345 permuteindices {2 0 1}
    t345 permuteindices {1 2 0}
    
    tensor::create u345 -size {3 4 5}
    u345 sequence
    
    t345 == tensor u345
  } {1}
  
  
  
  return
}
#-------------------------------------------------------------------------------
proc sat_test {} {

  # Tensor "saturate" tests
  
  catch {rename t0 {}}

  test sat-1.1 {tensor "saturate" command} {
    catch {rename t0 {}}
    tensor::create t0 -size 5
    set r1 [catch {t0 saturate}]
    set r2 [catch {t0 saturate -1}]
    set r3 [catch {t0 saturate -1 1 1}]
    set r4 [catch {t0 saturate -1 foo}]
    set r5 [catch {t0 saturate foo 1}]
    list $r1 $r2 $r3 $r4 $r5
  } {1 1 1 1 1}
  
  test sat-2.1 {tensor "saturate" command} {
    catch {rename t5 {}}
    tensor::create t5 -type float -initial {-2 -1 0 1 2}
    t5 saturate -1 1
    t5
  } {-1.0 -1.0 0.0 1.0 1.0}
  
  test sat-2.2 {tensor "saturate" command} {
    catch {rename t5 {}}
    tensor::create t5 -type int -initial {-2 -1 0 1 2}
    t5 section {{2 4}} saturate -1 1
    t5
  } {-2 -1 0 1 1}
  
  test sat-2.3 {tensor "saturate" command} {
    catch {rename t23 {}}
    tensor::create t23 -initial {{1 2 3} {4 5 6}}
    t23 section {* {1 2}} saturate 3 5
    t23
  } {{1.0 3.0 3.0} {4.0 5.0 5.0}}

  
  return
}
#-------------------------------------------------------------------------------
proc sequ_test {} {

  # Tensor "sequence" tests
  
  catch {rename t0 {}}

  test sequ-1.1 {tensor "sequence" command} {
    catch {rename t0 {}}
    tensor::create t0 -size 5
    set r1 [catch {t0 sequence 1}]
    set r2 [catch {t0 section 2 sequence 1}]
    list $r1 $r2
  } {1 1}

  test sequ-2.1 {tensor "sequence" command} {
    catch {rename t5 {}}
    tensor::create t5 -type float -initial {-2 -1 0 1 2}
    t5 sequence
    t5
  } {0.0 1.0 2.0 3.0 4.0}

  test sequ-2.2 {tensor "sequence" command} {
    catch {rename t53 {}}
    tensor::create t53 -size {5 3}
    t53 = scalar 0
    t53 sequence
    t53
  } {{0.0 1.0 2.0} {3.0 4.0 5.0} {6.0 7.0 8.0} {9.0 10.0 11.0} {12.0 13.0 14.0}}

  test sequ-2.3 {tensor "sequence" command} {
    catch {rename t55 {}}
    tensor::create t55 -size {5 5}
    t55 = scalar 0
    t55 section {{1 3} {1 3}} sequence
    t55
  } {{0.0 0.0 0.0 0.0 0.0} {0.0 0.0 1.0 2.0 0.0} {0.0 3.0 4.0 5.0 0.0} {0.0 6.0 7.0 8.0 0.0} {0.0 0.0 0.0 0.0 0.0}}

  
  return
}
#-------------------------------------------------------------------------------
proc subst_test {} {

  # Tensor "substitute" tests

  catch {rename t0 {}}

  test subst-1.1 {tensor "substitute" command} {
    catch {rename t0 {}}
    catch {rename foo {}}
    catch {rename bar {}}
    tensor::create t0 -size 5
    tensor::create bar -size {3 5}
    set r1 [catch {t0 substitute}]
    set r2 [catch {t0 substitute 1 1}]
    set r3 [catch {t0 section 2 substitute 1 1}]
    set r4 [catch {t0 section 2 substitute foo}]
    set r5 [catch {t0 section 2 substitute bar}]
    set r6 [catch {t0 substitute {1 2 foo}}]
    list $r1 $r2 $r3 $r4 $r5 $r6
  } {1 1 1 1 1 1}

  test subst-2.1 {tensor "substitute" command} {
    catch {rename t5 {}}
    tensor::create t5 -type float -initial {-2 -1 0 1 2}
    t5 substitute {10 11 12}
    t5
  } {10.0 10.0 10.0 11.0 12.0}
  
  test subst-2.2 {tensor "substitute" command} {
    catch {rename t5 {}}
    catch {rename t3 {}}
    tensor::create t5 -type float -initial {-2 -1 0 1 2}
    tensor::create t3 -type float -initial {10 11 12}
    t5 substitute t3
    t5
  } {10.0 10.0 10.0 11.0 12.0}

  test subst-2.3 {tensor "substitute" command} {
    catch {rename t5 {}}
    tensor::create t5 -initial {-2 -1 0 1 2}
    t5 section {{2 4}} substitute {10 11 12}
    t5
  } {-2.0 -1.0 10.0 11.0 12.0}

  test subst-2.4 {tensor "substitute" command} {
    catch {rename t5 {}}
    catch {rename t3 {}}
    tensor::create t5 -type float -initial {-2 -1 0 1 2}
    tensor::create t3 -type double -initial {10 11 12}
    t5 section {{2 4}} substitute t3
    t5
  } {-2.0 -1.0 10.0 11.0 12.0}

  test subst-2.5 {tensor "substitute" command} {
    catch {rename t53 {}}
    catch {rename t3 {}}
    tensor::create t53 -size {5 3}
    tensor::create t3 -type double -initial {10 11 12}
    t53 sequence
    t53 section {{0 1} {0 1}} substitute t3
    t53
  } {{10.0 11.0 2.0} {12.0 12.0 5.0} {6.0 7.0 8.0} {9.0 10.0 11.0} {12.0 13.0 14.0}}
 
  return
}
#-------------------------------------------------------------------------------
proc swap_test {} {

  # Tensor swap tests

  test swap-1.1 {tensor command} {
    catch {rename t {}}
    tensor::create t -size 5
    t sequence
    t swap 0 {1 3}
    t
  } {0.0 3.0 2.0 1.0 4.0}

  test swap-1.2 {tensor command} {
    catch {rename t {}}
    tensor::create t -size 5
    t sequence
    t swap rows {1 3}
    t
  } {0.0 3.0 2.0 1.0 4.0}

  test swap-1.3 {tensor command} {
    catch {rename t35 {}}
    tensor::create t35 -size {3 5}
    t35 sequence
    t35 swap rows {0 2}
    t35
  } {{10.0 11.0 12.0 13.0 14.0} {5.0 6.0 7.0 8.0 9.0} {0.0 1.0 2.0 3.0 4.0}}

  test swap-1.4 {tensor command} {
    catch {rename t35 {}}
    tensor::create t35 -size {3 5}
    t35 sequence
    t35 swap cols {0 2}
    t35
  } {{2.0 1.0 0.0 3.0 4.0} {7.0 6.0 5.0 8.0 9.0} {12.0 11.0 10.0 13.0 14.0}}


  return
}
#-------------------------------------------------------------------------------
proc ALLTESTS {} {

  package  require tcltest
  namespace import tcltest::test
  
  tcltest::configure -verbose {start body error pass}

  #--------------------------------------------

  apply_test
  bool_test
  compare_test
  credel_test
  delete_test
  expr_test
  insert_test
  isempty_test
  istns_test
  listind_test
  ops_test
  permute_test
  put_test
  readwrite_test
  sat_test
  sequ_test
  subst_test
  swap_test

} 
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
proc TEST_01_run {} {

  puts ""
  puts "MAIN"
  puts ""


  #tensor A -size {5 3}
  #tensor B -size {3 2}

  #A = array { {1 5 3} {4 8 2} {3 7 6} {1 4 3} {5 5 5} }
  #B = array { {4 2} {2 4} {9 1} }
  
  #tensor C -size {5 2}
  #C = multensor A B {1 0}
  

  #---------------------------------------------
  #set ret [tensor::create t -size 5]

  tensor::create t -size 5

  t sequence
  puts "t   = [t]"

  t permute rows {0 3 2 1 4}
  puts "t   = [t]"

  t
}
#-------------------------------------------------------------------------------
proc TEST_01 {} {

  set ret [TEST_01_run]
  
  puts "ret = $ret"
  puts ""
  
}
#-------------------------------------------------------------------------------
proc TEST_02 {} {

  
  #   Typical matrix operations are easily performed with tensor objects. For
  #   example,  to  multiply a 5-by-3 matrix A by a 3-by-2 matrix B, we could
  #   do the following:

  #tensor A -size {5 3}
  #tensor B -size {3 2}

  tensor::create A -size {5 3}
  tensor::create B -size {3 2}

  A = array { {1 5 3} {4 8 2} {3 7 6} {1 4 3} {5 5 5} }
  B = array { {4 2} {2 4} {9 1} }
  
  puts ""
  puts "A   = [A]"
  puts ""
  puts "B   = [B]"

  tensor::create C -size {5 2}

  C = multensor A B  {1 0}
  
  puts ""
  puts "C   = [C]"
  puts ""

  #   The {1 0} index pair indicates that index 1 of tensor A and index 0  of
  #   tensor B will be indexed over during the multiplication.  (Note that if
  #   B were a 2-by-3 matrix instead of 3-by-2, we could have used {1  1}  as
  #   the  index  pair,  which  would  be  equivalent of multiplying A by the
  #   transpose of B.)

  return
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
proc TEST_00 {} {

 
  puts ""
  puts "ALLTESTS ... "
  puts ""

  ALLTESTS ;# тесты пакета

  return
} 
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
proc TEST_time {} {

  puts ""
  puts "Measure the relative speeds ..........................."
  puts ""
  
  foreach size {3 10 30 100 300} {
    
    puts "Size: $size"
    puts ""
    
    catch {rename t34 {}}
    catch {rename t45 {}}
    catch {rename t35 {}}

    set siz $size

    tensor::create t34 -size [list $siz $siz]
    tensor::create t45 -size [list $siz 1]
    tensor::create t35 -size [list $siz 1]

    set c 1
    for {set i 0} {$i < $siz} {incr i} {
    for {set j 0} {$j < $siz} {incr j} {
      t34 section "$i $j" = scalar $c
      incr c
    }
    }

    set c 1
    for {set i 0} {$i < $siz} {incr i} {
    for {set j 0} {$j < 1}    {incr j} {
      t45 section "$i $j" = scalar $c
      incr c
    }
    }

    #set matrix1 [makemat1 $size]  
    #set vector  [makevect $size]
    #puts [time {set newvect1 [matmul1 $matrix1 $vector]} 100]
    #t35 = multensor t34 t45 {1 0}

    puts [time {t35 = multensor t34 t45 {1 0}}   100]

    # Size: 300    
    # 1425.73 microseconds per iteration

    #puts "t35 = [t35]"

    puts ""
 }

}
#-------------------------------------------------------------------------------
