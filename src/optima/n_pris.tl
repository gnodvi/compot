# -*-   mode: tcl  ; coding: koi8   -*- ----------------------------------------

#!/bin/sh
# \
exec tclsh "$0" ${1+"$@"}
#-------------------------------------------------------------------------------


#-------------------------------------------------------------------------------
# http://wiki.tcl.tk/5996
# 
# Primes
# Updated 2013-02-21 06:13:50 by pooryorick ▲
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------

# Primes are positive integers >1 that can only be divided (without remainder)
# by 1 and themselves. Examples from RS's collection:

# 1234567891 987654321987654329 9223372036854775783

# Two more primes, which may be algorithmically useful since they are close
# to pow(2,15) and pow(2,16):

# 32003 65521

# Here's a very simple prime checker, which returns 1 for primes, else the
# first found divisor (and the quotient):

#-------------------------------------------------------------------------------
proc primetest n {
  
  set max [expr wide(sqrt($n))]

  if {$n%2==0} {return [list 2 [expr $n/2]]}

  for {set i 3} {$i<=$max} {incr i 2} {
    if {$n%$i==0} {return [list $i [expr $n/$i]]}
  }

  return 1

}
#-------------------------------------------------------------------------------

# LV 2009-May-4: One mathematical nit. I seem to recall that the number 1 is not
# considered a prime because it has only one factor - itself, whereas the
# definition for a prime number is that the number has only 2 distinct factors -
# 1 and itself. the primetest function returns a 1 when called with a 1. I have
# no idea what primetest should return in this case - perhaps a [list 1 1] ?

# AM commented in the Tcl chatroom: The trick: divide by the first ten or twenty
# primes, after that: numbers of the form 6n+1 and 6n+5 may act as divisors. If
# you use only numbers of the form I mentioned, you gain about 50% with no loss
# of information.

# This uses the first part of the proposal:

#-------------------------------------------------------------------------------
proc primetest2 n {

  set max [expr int(sqrt($n))]

  foreach i {
    2 3 5 7 11 13 17 19 23 29 31 37 41 43 47 53 59 61 67 71 73 79 83 89 97
    101 103 107 109 113 127 131 137 139 149 151 157 163 167 173 179 181 191
    193 197 199
  } {
    if {$i>$max} break
    if {$n%$i == 0} {return [list $i [expr $n/$i]]}
  }

  for {incr i 2} {$i<$max} {incr i 2} {
    if {$n%$i == 0} {return [list $i [expr $n/$i]]}
  }

  return 1
} ;# RS
#-------------------------------------------------------------------------------

# CL: A comment on prime calculations: for modest sizes--up to a few tens of
# decimal digits--I've always found it much the most satisfying to cache a list
# of known primes. I'm working in a stateful environment. My basic algorithm:
# test a trial number for quotients against my list of known primes, up to the
# square root of the trial number. Extend the list of primes if it doesn't reach
# that high. It's a compact algorithm, it takes little space to keep the list,
# and I get excellent speed, especially for the frequent case where I want to
# know the primality of several different integers.

# CL offers an example implementation

#-------------------------------------------------------------------------------
proc TEST_2 {} {

  namespace eval primes {
    
  variable list {}
  
  proc is_prime candidate {
    variable list
    
    foreach prime $list {
      
      if {![expr $candidate % $prime]} {
        # If a candidate has a factor, then it's composite.
        return false
      }
      
      if {[expr $prime * $prime > $candidate]} {
        
        # The a candidate has no prime factor smaller than or equal to its
        # square root, so it has no prime factor, and therefore no
        # factor, and therefore is itself prime.
        return true
      }             
    }
    
    while true {
      # Use the list of primes we know to test the primality of the
      # candidate.  If the tests are inconclusive, extend the list, until
      # the question is settled.  In any case, be careful to maintain the
      # list of known primes; this is valuable in consideration of new
      # candidates.
      
      set largest [get_next_prime]
      if {[expr $largest * $largest >= $candidate]} {
        return [is_prime $candidate]
      }
    }
  }

  proc get_next_prime {} {
    variable list
    
    if {![llength $list]} {
      set candidate 2
    } else {
      set candidate [lindex $list end]
      while true {
        incr candidate
        if {[is_prime $candidate]} break
      }
    }
    lappend list $candidate
    return $candidate             
  }

}

  
  # Print the first thousand primes.

  set i_max 20 ;# 1000

  puts ""

  for {set i 1} {$i <= $i_max} {incr i} {

    puts [primes::get_next_prime]
  }                          
  
  puts ""

#-------------------------------------------------------------------------------
}
#-------------------------------------------------------------------------------

TEST_2


#-------------------------------------------------------------------------------

# DPE 2006-08-08: I've optimised the above code by simple changes such as
# removing [expr] where [if] is used. On my machine it runs approximately 20x
# faster (e.g. primes::is_prime 1234567891 takes 0.17s vs 4.08s).

# glennj 2009-04-20: small optimization in get_next_prime: incr by 2 as even
# numbers are obviously not prime. Also, add "restart" proc to complement "reset"
# without throwing away the known primes.

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
proc TEST_3 {} {


  namespace eval primes {} 

  proc primes::reset {} {
    variable list [list]
    variable current_index end
  }
  
  namespace eval primes {reset}
  
  proc primes::restart {} {
    variable list
    variable current_index
    if {[llength $list] > 0} {
      set current_index 0
    }
  }
  
  proc primes::is_prime {candidate} {
    variable list
    
    foreach prime $list {
      if {$candidate % $prime == 0} {
        # Candidate has a factor, so it's composite.
        return false
      }
      if {$prime * $prime > $candidate} {
        # Candidate has no prime factor smaller than or equal to its square
        # root, so it has no prime factor, and therefore no factor, and
        # therefore is itself prime.
        return true
      }
    }
    while true {
      # Use the list of primes we know to test the primality of the
      # candidate.  If the tests are inconclusive, extend the list, until the
      # question is settled.  In any case, be careful to maintain the list of
      # known primes; this is valuable in consideration of new candidates.
      set largest [get_next_prime]
      if {$largest * $largest >= $candidate} {
        return [is_prime $candidate]
      }
    }
  }
  
  proc primes::get_next_prime {} {
    variable list
    variable current_index
    
    if {$current_index ne "end"} {
      set p [lindex $list $current_index]
      if {[incr current_index] == [llength $list]} {
        set current_index end
      }
      return $p
    }
    
    switch -exact -- [llength $list] {
      0 {set candidate 2}
      1 {set candidate 3}
      default {
        set candidate [lindex $list end]
        while true {
          incr candidate 2
          if {[is_prime $candidate]} break
        }
      }
    }
    lappend list $candidate
    return $candidate
  }

  
  # For testing
  # Print the first .. primes.
  
  proc printAllPrimes {num} {

    for {set i 1} {$i <= $num} {incr i} {
      puts [primes::get_next_prime]
    }
  }
  
  
 # printAllPrimes 1000
  
  puts ""

  printAllPrimes 20
  
  puts ""

#-------------------------------------------------------------------------------
}
#-------------------------------------------------------------------------------

TEST_3


#-------------------------------------------------------------------------------

# The first 6 million primes
# The largest known prime as of 2012 is the Mersenne prime 2**43112609 - 1
# A prime tester on the Web

# Another useful prime-related concept is that of co-primality. Two numbers are
# co-prime if the greatest common divisor is 1.

# Note that if P is a prime number, then for any Q, P and Q are co-prime.

# RS wrote this cute recursive prime tester for breakfast fun:
#-------------------------------------------------------------------------------

proc prime i {
    prime0 $i [expr {int(sqrt($i))}]
}

proc prime0 {i div} {
    expr {!($i%$div)? 0: $div<=2? 1: [prime0 $i [incr div -1]]}
}

#-------------------------------------------------------------------------------

# DL wrote a Tcl script to let kids experiment with Eratosthenes Sieves.

# RS wrote A little primes toy to a similar end.

# Complex factorization of primes: Carl Friedrich Gauss knew it some 200 years
# ago, RS just read Easter 2005 that some (very roughly, half of the) primes can
# be factorized into a pair of complex numbers, where the second is the conjugate
# of the first, e.g. for 2:

#     (1+i)*(1-i) = 1 + i - i*(1+i) = 1 + i - i - i² = 2

# I first tested this using Complex math with TOOT, but as the product of a
# complex number a+ib and its conjugate a-ib is just a² + b², the test can be
# done easier as the sum of the two squares. The following proc returns the first
# list of {a b} found (the second is always {b a}), so that a²+b² == x, or an
# empty list when nothing was found:

#-------------------------------------------------------------------------------
proc gaussfactor x {
  
  for {set real 1} {$real <=sqrt($x)} {incr real} {
    for {set im 1} {$im<=sqrt($x)} {incr im} {
      if {$real*$real+$im*$im == $x} {
        return [list $real $im]
      }
    }
  }

}
#-------------------------------------------------------------------------------

# Here's the first few primes tested - five of ten have a complex factorization:

# % gaussfactor 2
# 1 1
# % gaussfactor 3
# % gaussfactor 5
# 1 2
# % gaussfactor 7
# % gaussfactor 11
# % gaussfactor 13
# 2 3
# % gaussfactor 17
# 1 4
# % gaussfactor 19
# % gaussfactor 23
# % gaussfactor 29
# 2 5

# AM 2005-03-29: I am not sure about the details but it seems that certain
# problems regarding prime numbers are easier to solve using this complex
# factorisation than if you stick to ordinary integers. Complex numbers with
# integer real and imaginary fractions are also known as Gaussian integers.

# SMH 2006-01-05: The inner loop (for im) is not necessary. For any value of
# $real only one $im is possible.

#-------------------------------------------------------------------------------
proc gaussfactor2 x {

  set sx [expr {int(sqrt($x))}]

  for {set real 1} {$real < $sx} {incr real} {
    set d [expr {$x - $real * $real}]
    set im [expr {int(sqrt($d))}]
    if { $im * $im == $d } { return [list $real $im] }
  }

  return ""
}
#-------------------------------------------------------------------------------

# A SourceForge bug 1513763 brought this very cute, regexp-based prime finder
# (based on an old perl hack):

#-------------------------------------------------------------------------------
proc isprime x {

  expr {$x>1 && ![regexp {^(oo+?)\1+$} [string repeat o $x]]}
}
#-------------------------------------------------------------------------------

# Twylite: If you need primes for cryptographic purposes (e.g. RSA keys),
# consider using the prime-finding algorithms in FIPS 186-3. It is often
# preferable (and quicker) to find a prime p such that (p-1) and (p+1) have large
# prime factors, as described in that standard. To speed up the process use trial
# division by small primes to sieve the candidates before performing the
# Miller-Rabin test.

# alexex I did some work in implementing The Miller-Rabin algorhithm in pure
# TCL, it is a really fast way to check whether a number is prime or not, every
# round leaves you with a 25% chance, that your number is not a prime number,
# so doing the test 5 times (which is standard in my proc), leaves you with a
# probability of 0.0009765625 % that your number is not a prime number.

# rwm - Be careful with the code below. It has a few problems that make it
# slower and possibly wrong.

#-------------------------------------------------------------------------------
#from #tcl @ quakenet "+ rand"
#-------------------------------------------------------------------------------
proc rand {min max} {

  return [expr {int(rand()*($max-$min+1))+$min}]
}

#rwm - note the rand has a ?double? float precision linit of 17 decimal
#digits.  This implies that for large numbers (say 1024 bits as in RSA) this
#will snap to ## the nearest integer leaving huge gaps of "never reachable"
#integers between.

# this proc was written by rmax - http://wiki.tcl.tk/4709 - thanks for that :)
#-------------------------------------------------------------------------------
# 
proc powm {n r m} {

  expr {$r & 1 ? $n * [powm $n [expr {$r-1}] $m] % $m : $r ? [set nn [powm $n [expr {$r >> 1}] $m]] * $nn % $m : 1 }
}

## - rwm the non-recursive versions of this are probably slightly faster

proc rabinmiller {n {rounds 5}} {

  if {$n % 2 == 0} {
    error "Even numbers cant be prime."
  }

  set s 1

  while {($n - 1) % (2**($s+1)) == 0} {
    incr s
  }

  set d [expr {($n - 1)/(2**$s)}]

  for {set i 0} {$i < $rounds} {incr i} {
    set a [rand 2 [expr {$n - 1}]]
    while {[powm $a $d $n] == 1 % $n} {
      ## rwm (unnecessary)-----^^^^
      ## rwm in fact precedence says   == (1 % $n)
      set a [rand 2 [expr {$n - 1}]]
      # if a^d mod n == 1 then do the next round, it has passed
      #this round, so this should be an 'if' not a 'while'
    }
    set p 0
    for {set r 0} {$r < $s} {incr r} {
      if {[powm $a [expr {(2**$r)*$d}] $n] == -1 % $n} {
        # rwm, again precedence -1 % $n and that evaluates to ($n-1),
        # while I believe it should be '1' as I understand it 'a'
        # should evolve by squaring in each of these loops
        set p 1
        break
      } else {
      }
    }
    if {!$p} {break}
  }

  return $p
}
#-------------------------------------------------------------------------------

# I first implemented it with a powm function, but apparently calculating
# moderate high powers and modulo them takes ages, so i took the powm proc from
# the wiki, and now the speed is alright.

# AM 2010-01-18: Computing 99991 to the power 49995 does indeed take a long time -
# the example we chatted about (in the order of a half minute). But the result is
# a number consisting of, roughly, 250000 digits. Dealing with such large numbers
# simply does take a long time. Luckily the powm procedure can use some fairly
# elementary properties of modulo computation to reduce the size of the numbers
# and thereby the computation time.

# rwm I used the above rabin-miller routine in some RSA keygen experiments, and
# found the run-time unacceptable. (I killed every one of them before they
# finished) I then wrote a different miller-rabin based on the
# "Applied Cryptography" and the wikipedia entry for miller-rabin. I am
# including the commented version below to help Tcl'ers understand the algorithm.
# It runs 17 rounds in less than 1 second for most 1024-bit numbers. I believe
# it correctly implements miller-rabin... I didn't include the modExpo function
# which can be taken from above or elsewhere, nor did I include the random function.

#-------------------------------------------------------------------------------

set debug(millerRabin) 0

proc primeCheckMillerRabin {n {desiredRounds 17}} {

  # coded by randy melton 9/17/12 following 
  # http://en.wikipedia.org/wiki/Millel-Rabin_primality_test
  variable debug
  #Input: n > 3, an odd integer to be tested for primality;
  #Input: k, a parameter that determines the accuracy of the test
  #Output: composite if n is composite, otherwise probably prime
  #write n - 1 as 2s·d with d odd by factoring powers of 2 from n - 1
  ## rwm: example n       =0b100101101011010001
  ##              n-1     =0b100101101011010000
  ##              n-1/2^4 =0b10010110101101       (ie divide out 2, 4 times)
  ## so                  d=0b10010110101101
  ## and                 s=4
  for {set s 0; set d [expr {$n-1}]} {($d&1) == 0} {incr s} {
    set d [expr {$d>>1}]
  }
  if {$debug(millerRabin)} {
    puts -nonewline stderr "${::STATUS}: primeCheckMillerRabin round:"
  }

  #LOOP: repeat k times:

  for {set round 0} {$round < $desiredRounds} {incr round} {

    if {$debug(millerRabin)} {
      puts -nonewline stderr " $round"
    }

    #pick a random integer a in the range [2, n - 2] (** see next line)
    ## ** RWM NOTE: should be 1 < a < n
    set a [primes::rand 2 [expr {$n-1}]]

    #x ← a^d mod n
    set x [binaryModExpo $a $d $n]

    #if x = 1 or x = n - 1 then do next LOOP
    if {($x == 1) || ($x == ($n-1))} {continue}

    #for r = 1 .. s - 1
    for {set r 1} {$r <= ($s-1)} {incr r} {
      #x ← x^2 mod n
      set x [binaryModExpo $x 2 $n]
      #if x = 1 then return composite
      if {$x == 1} {
        if {$debug(millerRabin)} {
          puts stderr "$k is composite"
        }
        return 0};#composite
      #if x = n - 1 then do next LOOP
      if {$x == ($n - 1)} {break}
    }
    if {$x == ($n - 1)} {continue}
    if {$debug(millerRabin)} {
      #puts stderr "composite"
    }
    return 0 ;#composite
  }

  if {$debug(millerRabin)} {
    #puts stderr "possible prime"
  }

  return 1 ;#probably prime
}
#-------------------------------------------------------------------------------

# rwm -- I added one more pretty good/fast primality test based on fermats little
# theorem at primeCheckFermat

# rwm -- I added primeCheckLucas as per fips186-3

#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
											  
