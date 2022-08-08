# -*-   mode: tcl  ; coding: koi8   -*- ----------------------------------------

#-------------------------------------------------------------------------------

if [info exists ::G_RAND_TL] {
  return
} else {
  set  ::G_RAND_TL ""
}


#-------------------------------------------------------------------------------
# /*****************************************************************************
#  *                                                                           *
#  *  Имя этого файла: c_random_util.c                                         *
#  *                                                                           *
                                                                            
#   Synopsis:	Portable routines for generating pseudo random numbers.

# 		Why use these instead of the system routines?
# 		(a) Useful interface functions. (can specify ranges or
# 		specific distributions)
# 		(b) System independant. (Generated numbers are
# 		reproducible across system types.)
# 		(c) Enables saving and restoring state.

# 		SLang intrinsic function wrappers are provided if the
# 		HAVE_SLANG macro is defined

# 		The algorithm I selected is the Mitchell and Moore
# 		variant of the standard additive number generator.
# 		The required array of numbers is populated by a
# 		using single seed value by using a linear
# 		congruential pseudo random number generator.

#   References:	Standard additive number generator and the linear
# 		congruential algorithm:
# 		Knuth D.E., "The Art of Computer Programming",
# 		Vol 2, 2nd ed. (1998)

# 		General information:
# 		Press W., Flannery B.P., Teukolsky S.A., Vetterling W.T.,
# 		"Numerical Recipes in C: The Art of Scientific Computing"
# 		Cambridge University Press, 2nd ed. (1992)

#   Usage:	o First call gaul_random_init().

# 		o Call gaul_random_seed() to seed the PRNG (like srand()).
# 		  Alternatively, random_tseed() to use system clock for seed.

# 		o random_rand() is a rand() replacement, which is available
# 		  for use but I would recommend the wrapper functions:
# 		  random_int(), random_int_range() etc.

# 		o random_get_state() and random_set_state() may be used
# 		  to set, save, restore, and query the current state.

# 		These functions can be tested by compiling with
# 		something like:
# 		gcc -o testrand random_util.c -DRANDOM_UTIL_TEST

#   To do:	Gaussian/Boltzmann distributions.
# 		Need a proper test of randomness.
# 		Properly implement stack of states.
# 		I could do with some handy documentation.

#  **********************************************************************/

# /*----------------------------------------------------------------------------*/
# /*
#  * Constants.
#  */

set ::RANDOM_RAND_MAX 4294967295

set ::RANDOM_NUM_STATE_VALS  57

# /*
#  * PRNG constants.  Don't mess with these values willie-nillie.
#  */

set ::RANDOM_MM_ALPHA	55
set ::RANDOM_MM_BETA	24
set ::RANDOM_LC_ALPHA	3
set ::RANDOM_LC_BETA	257
set ::RANDOM_LC_GAMMA	RANDOM_RAND_MAX

# static boolean	is_initialised=FALSE;
#set ::is_initialised false
set ::is_initialised 0

# /*----------------------------------------------------------------------------*/
# //  Replacement for the standard rand().
# //  Returns a new pseudo-random value from the sequence, in
# //  the range 0 to RANDOM_RAND_MAX inclusive, and updates
# //  global state for next call.  size should be non-zero,
# //  and state should be initialized.

# GAULFUNC unsigned int random_rand (void)

# /*----------------------------------------------------------------------------*/
proc gaul_random_rand {} {

  #   unsigned int val;

  if {! $::is_initialised} {
    die "Neither 'gaul_random_init' or 'gaul_random_seed' have been called."
  }

  #   THREAD_LOCK(random_state_lock);

  set j  $::current_state_j
  set k  $::current_state_k

  #   val = (current_state.v[current_state.j] + current_state.v[current_state.k])
  #     & RANDOM_RAND_MAX;
  
  set val [expr {($::current_state_v($j) + $::current_state_v($k)) & $::RANDOM_RAND_MAX}]
  
  set ::current_state_x [expr {($::current_state_x + 1) % $::RANDOM_NUM_STATE_VALS}]
  set ::current_state_j [expr {($::current_state_j + 1) % $::RANDOM_NUM_STATE_VALS}]
  set ::current_state_k [expr {($::current_state_k + 1) % $::RANDOM_NUM_STATE_VALS}]

  #set ::current_state_v($::current_state_x)  val
  set ::current_state_v($::current_state_x)  $val
  
  #   THREAD_UNLOCK(random_state_lock);

  #puts stderr "random_rand:  val = $val"
  #exit

  return $val
} 
# /*----------------------------------------------------------------------------*/
# GAULFUNC void gaul_random_seed (const unsigned int seed)
proc gaul_random_seed {seed} {

  #puts "gaul_random_seed .............. "

#   if {$::is_my_random} {
#     # не будем усложнять, воспользуемся встроенными средствами!
#     # 
#     expr {srand ($seed)} 
#     return
#   }

  #   int	i; 
  
  #set ::is_initialised true
  set ::is_initialised 1

  #   current_state.v[0]=(seed & RANDOM_RAND_MAX);
  set ::current_state_v(0) [expr {$seed & $::RANDOM_RAND_MAX}]
  
  #puts "seed= $seed  RANDOM_RAND_MAX= $::RANDOM_RAND_MAX $::current_state_v(0)"


  for {set i 1} {$i < $::RANDOM_NUM_STATE_VALS} {incr i} {

    set iminus1 [expr {$i - 1}]
    set val [expr {($::RANDOM_LC_ALPHA * $::current_state_v($iminus1) + $::RANDOM_LC_BETA) \
                     & $::RANDOM_RAND_MAX}]

    set ::current_state_v($i) $val
  }

  set ::current_state_j  0
  set ::current_state_k [expr {$::RANDOM_MM_ALPHA - $::RANDOM_MM_BETA}]
  set ::current_state_x [expr {$::RANDOM_MM_ALPHA - 0}]
  
  return
} 
# /*----------------------------------------------------------------------------*/
# //  Initialise random number generators.  Should be
# //  called prior to any of these functions being used.
# //  Seeds the PRNG with a seed of 1.
# /*----------------------------------------------------------------------------*/
# GAULFUNC void gaul_random_init (void)
# /*----------------------------------------------------------------------------*/
proc  gaul_random_init {} {

  #puts "gaul_random_init .............. "

  gaul_random_seed  1
  
  # #if RANDOM_DEBUG>0
  #   printf("DEBUG: Random number routines initialised.\n");
  # #endif

  return
}
#-----------------------------------------------------------

gaul_random_init ;# сразу подготовим к выполнению, на всяк случай.


#-------------------------------------------------------------------------------

# некоторые мои функуции
# 
# /*----------------------------------------------------------------------------*/
# //  Return a random integer between 0 and (N-1) inclusive.
#
# /*----------------------------------------------------------------------------*/
proc gaul_random_int {max} {

#   /*
#     return (int)((double)random_rand()*max/RANDOM_RAND_MAX);
#     */

  #set ret [common_rand 0 [expr $max - 1]]

  if {$max == 0} {
    set ret 0
  } else {
    set ret [expr {[gaul_random_rand] % $max}]
  }

  #puts stderr [format "random_int :  ret = %d " $ret]

  return $ret

 #   return (max==0) ? 0 : random_rand()%max;
} 
# /*----------------------------------------------------------------------------*/
# //  Return a random integer between min and max-1 inclusive.
# /*----------------------------------------------------------------------------*/
proc gaul_random_int_range {min max} \
{
  
  set max_min [expr {$max - $min}]

  if {$max_min == 0} {

    return $max

  } else {

    return [expr {$min + ([gaul_random_rand] % $max_min)}]
  }
  
}
# /*----------------------------------------------------------------------------*/
# //  Return a random double within the allowed range.
# /*----------------------------------------------------------------------------*/
# GAULFUNC double random_double_full (void)
# {

#   return ( ((double)random_rand()/(double)RANDOM_RAND_MAX)*
#           (DBL_MAX-DBL_MIN)+DBL_MIN );
# }
# /*----------------------------------------------------------------------------*/
# //  Return a random double within the specified range.

# GAULFUNC double random_double (const double max)

#-------------------------------------------------------------------------------
proc  random_double {max} {

  #  return ( max * (((double) random_rand()) / (double) RANDOM_RAND_MAX) );

  set r [gaul_random_rand]

  set ret [expr {$max * ((1.0 * $r) / $::RANDOM_RAND_MAX)}]

  #if {$::is_print} {
  #  puts stderr "random_double : r = $r  ret = $ret"
  #  puts stderr ""
  #}

  return $ret
}
# /*----------------------------------------------------------------------------*/
# //  Return a random double within the specified range.
# /*----------------------------------------------------------------------------*/
# GAULFUNC double random_double_range (const double min, const double max)

# /*----------------------------------------------------------------------------*/
proc random_double_range {min max} {



  return [expr {($max - $min) * ((1.0 * [gaul_random_rand]) / $::RANDOM_RAND_MAX)  + $min}]

#   return ( (max-min) * (((double) random_rand()) / (double) RANDOM_RAND_MAX) + min );
}
# /*----------------------------------------------------------------------------*/
proc random_test {} {


  puts ""
  puts "Testing random numbers."
  puts ""
  
  foreach i {1 2 3 4 5} {
    puts "[gaul_random_int_range 1 9]  [random_double_range 1.0 9.0]"
  }

  puts ""
}
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------


