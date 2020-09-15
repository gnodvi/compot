# -*-   mode: tcl  ; coding: koi8   -*- ----------------------------------------

#-------------------------------------------------------------------------------
# 
if [info exists ::F_RAND_TL] {
  return
} else {
  set  ::F_RAND_TL ""
}

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

#   Usage:	o First call random_init().

# 		o Call random_seed() to seed the PRNG (like srand()).
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
proc random_rand {} {

  #   unsigned int val;

  if {! $::is_initialised} {
    die "Neither random_init() or random_seed() have been called."
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
# GAULFUNC void random_seed (const unsigned int seed)
proc random_seed {seed} {

  #puts "random_seed .............. "

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
# GAULFUNC void random_init (void)
# /*----------------------------------------------------------------------------*/
proc  random_init {} {

  #puts "random_init .............. "

  random_seed  1
  
  # #if RANDOM_DEBUG>0
  #   printf("DEBUG: Random number routines initialised.\n");
  # #endif

  return
}
# /*----------------------------------------------------------------------------*/
# //  Return TRUE 50% of the time.
# /*----------------------------------------------------------------------------*/
# GAULFUNC boolean random_boolean (void)
# /*----------------------------------------------------------------------------*/
proc random_boolean {} {

  set ret [expr {[random_rand] <= $::RANDOM_RAND_MAX / 2}]

  return $ret

  #return (boolean)(random_rand() <= RANDOM_RAND_MAX/2);
}
# /*----------------------------------------------------------------------------*/
# //  Return TRUE (prob * 100)% of the time
# /*----------------------------------------------------------------------------*/
# GAULFUNC boolean random_boolean_prob (const double prob)

# /*----------------------------------------------------------------------------*/
proc random_boolean_prob {prob} {

  set ret [expr {[random_rand] <= $prob * $::RANDOM_RAND_MAX}]

  return $ret

#   return (boolean)(random_rand() <= (unsigned int)(prob * (double)RANDOM_RAND_MAX));
# }
#-------------------------------------------------------------------------------

# некоторые мои функуции
# 
#-------------------------------------------------------------------------------
# rand() - возвращает случайное число с плавающей точкой в интервале [0.0 1.0]
#
# генерируем случайное целое из min-max (оба включены) интервала.
#-------------------------------------------------------------------------------
proc common_rand {min max} {

  expr {$min + int(rand() * (($max-$min)+1))}

}
# /*----------------------------------------------------------------------------*/
# //  Return a random integer between 0 and (N-1) inclusive.
#
# GAULFUNC unsigned int random_int (const unsigned int max)
# /*----------------------------------------------------------------------------*/
proc random_int {max} {

#   /*
#     return (int)((double)random_rand()*max/RANDOM_RAND_MAX);
#     */

  #set ret [common_rand 0 [expr $max - 1]]

  if {$max == 0} {
    set ret 0
  } else {
    set ret [expr {[random_rand] % $max}]
  }

  #puts stderr [format "random_int :  ret = %d " $ret]

  return $ret

 #   return (max==0) ? 0 : random_rand()%max;
} 
# /*----------------------------------------------------------------------------*/
# //  Return a random integer between min and max-1 inclusive.
# /*----------------------------------------------------------------------------*/
# GAULFUNC int random_int_range (const int min, const int max)

# /*----------------------------------------------------------------------------*/
proc random_int_range {min max} \
{
  #   /*
  #     return (random_rand()*(max-min)/RANDOM_RAND_MAX + min);
  #     */
  
  set max_min [expr {$max - $min}]

  if {$max_min == 0} {
    return $max

  } else {
    return [expr {$min + ([random_rand] % $max_min)}]
  }
  
  #   return (max-min==0) ? max : min + (random_rand()%(max-min));
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

  set r [random_rand]

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



  return [expr {($max - $min) * ((1.0 * [random_rand]) / $::RANDOM_RAND_MAX)  + $min}]

#   return ( (max-min) * (((double) random_rand()) / (double) RANDOM_RAND_MAX) + min );
}
# /*----------------------------------------------------------------------------*/
# //  Return a pseudo-random number with a uniform
# //	   distribution in the range 0.0=>r>1.0
# /*----------------------------------------------------------------------------*/
# GAULFUNC double random_unit_uniform (void)
# /*----------------------------------------------------------------------------*/
proc random_unit_uniform {} {

  set r [random_rand]

  # return ( (((double) random_rand()) / (double) RANDOM_RAND_MAX) );

  return [expr {1.0 * $r / $::RANDOM_RAND_MAX}]
}
# /*----------------------------------------------------------------------------*/
# //  Return a pseudo-random number with a normal
# //  distribution with a given mean and standard devaiation.
# /*----------------------------------------------------------------------------*/
# GAULFUNC float random_float_gaussian (const float mean, const float stddev)
# {
#   float	q,u,v,x,y;

#   /* 
#     * Generate P = (u,v) uniform in rectangular acceptance region.
#     */
#   do
#   {
#     u = 1.0f-random_float_unit_uniform();	/* in range 0.0>u>=1.0 */
#     v = 1.7156f * (0.5f - random_float_unit_uniform());	/* in range 0.8578>v>=0.8578 */

#     /* Evaluate the quadratic form. */
#     x = u - 0.449871f;
#     y = 0.386595f + fabs(v);
#     q = x * x + y * (0.19600f * y - 0.25472f * x);

#     /*
#       * Accept P if inside inner ellipse.
#       * Reject P if outside outer ellipse, or outside acceptance region.
#       */
#   } while ((q >= 0.27597) && ((q > 0.27846) || (v * v > -4.0 * log(u) * u * u)));

#   /* Return ratio of P's coordinates as the normal deviate. */
#   return (float)(mean + 2.0 * stddev * v / u);	/* I'm not entirely sure why this *2.0 factor is needed! */
# }
# /*----------------------------------------------------------------------------*/
# //  Random number with normal distribution, average 0.0,
# //	   deviation 1.0
# /*----------------------------------------------------------------------------*/
# GAULFUNC float random_float_unit_gaussian (void)
# {
#   float			r, u, v, fac;
#   static boolean	set = FALSE;
#   static float		dset;

#   if (set)
#   {
#     set = FALSE;
#     return dset;
#   }

#   do
#   {
#     u = 2.0f * random_float_unit_uniform() - 1.0f;
#     v = 2.0f * random_float_unit_uniform() - 1.0f;
#     r = u*u + v*v;
#   } while (r >= 1.0);

#   fac = (float)sqrt(-2.0 * log(r) / r);
#   dset = v*fac;

#   return u*fac;
# }

# /*----------------------------------------------------------------------------*/
# /* The original (thread-safe) version was this: */
# #if 0
# /*----------------------------------------------------------------------------*/
# float random_float_unit_gaussian (void)
# {
#   float	r, u, v;

#   do
#   {
#     u = 2.0 * random_float_unit_uniform() - 1.0;
#     v = 2.0 * random_float_unit_uniform() - 1.0;
#     r = u*u + v*v;
#   } while (r >= 1.0);

#   return u*sqrt(-2.0 * log(r) / r);
# }
# /*----------------------------------------------------------------------------*/
# #endif
# /*----------------------------------------------------------------------------*/
# //  Return a pseudo-random number with a normal
# //	   distribution with a given mean and standard devaiation.
# /*----------------------------------------------------------------------------*/
# /*
#   Kinda based on: (But optimised quite a bit)

#   ALGORITHM 712, COLLECTED ALGORITHMS FROM ACM.
#   THIS WORK PUBLISHED IN TRANSACTIONS ON MATHEMATICAL SOFTWARE,
#   VOL. 18, NO. 4, DECEMBER, 1992, PP. 434-435.
#   The algorithm uses the ratio of uniforms method of A.J. Kinderman
#   and J.F. Monahan augmented with quadratic bounding curves.
#  */
# /*----------------------------------------------------------------------------*/
# #if 0
# /*----------------------------------------------------------------------------*/
# /* Random number with normal distribution, average 0, deviation 1.
#    From Numerical Recipes. */
# /*----------------------------------------------------------------------------*/
# //  Random number with normal distribution, average 0.0,
# //	   deviation 1.0

# GAULFUNC double random_unit_gaussian (void)

# /*----------------------------------------------------------------------------*/
proc random_unit_gaussian {} {

  #   double		r, u, v, fac;
  #   static boolean	set = FALSE;
  #   static double		dset;
  
  #   if (set)
  #   {
  #     set = FALSE;
  #     return dset;
  #   }
  
  #   do
  #   {
  #     u = 2.0 * random_unit_uniform() - 1.0;
  #     v = 2.0 * random_unit_uniform() - 1.0;

  #     r = u*u + v*v;
  #   } while (r >= 1.0);
  
  while {1} {
    
    set u [expr {2.0 * [random_unit_uniform] - 1.0}]
    set v [expr {2.0 * [random_unit_uniform] - 1.0}]

    set r [expr {$u * $u + $v * $v}]

    if {$r < 1.0} {break}
  }

  set fac  [expr {sqrt (-2.0 * log ($r) / $r)}]
  set dset [expr {$v * $fac}]

  return [expr  {$u * $fac}]
}
# /*----------------------------------------------------------------------------*/
# //  Randomize an array of integers.
# /*----------------------------------------------------------------------------*/
# GAULFUNC void 
# random_int_permutation (
#                         const int size, // 
#                         int    *iarray, // Source array.
#                         int    *oarray  // Destination array.
#                         )
# /*----------------------------------------------------------------------------*/
#proc random_int_permutation {size iarray  &oarray}
proc random_int_permutation {size &iarray  &oarray} \
{
  USE_REFS
  #upvar ${&iarray} iarray
  #upvar ${&oarray} oarray

  # int   i,j=0;    /* Loop variables over arrays. */
  # int   pos;	    /* Randomly selected index.    */

  set j 0
  
  #   if (!iarray || !oarray) die ("NULL pointer to int array passed.");
  
  for {set i [expr {$size - 1}]} {$i > 0} {incr i -1} \
  {
    set pos [random_int $i]

    #puts stderr [format "i = %2d  pos = %2d " $i  $pos]

    # oarray[j++] = iarray[pos];
    lappend oarray [lindex $iarray $pos]

    #  iarray[pos] = iarray[i];
    lset iarray $pos [lindex $iarray $i]
  }
  
  #   oarray[j] = iarray[0];
  lappend oarray [lindex $iarray 0]

  return
}
# /*----------------------------------------------------------------------------*/
proc permutation_test {} \
{

  #set ::simp_random 1  
  #set seed       2009
  random_init

  set ordered {1 2 3 4 5}
  set size 5
  set permutation {}

  puts ""
  puts "permutation_test: ordered     = $ordered"

  puts "permutation_test: "

  random_int_permutation  $size  ordered  permutation 

  puts "permutation_test: ordered     = $ordered"
  puts "permutation_test: permutation = $permutation"

  puts ""

  return
}
# /*----------------------------------------------------------------------------*/
# //  synopsis:	Testing.
# //  return:	TRUE if all tests successful.
# /*----------------------------------------------------------------------------*/

#set ::NUM_BINS    200
#set ::NUM_SAMPLES 1000000

#// пока простой тест, просто генерируем сл. даблы
#// 
set ::NUM_BINS    20
set ::NUM_SAMPLES 20

# #define NUM_CHISQ 20

# /*----------------------------------------------------------------------------*/
# GAULFUNC boolean random_test (void)
# /*----------------------------------------------------------------------------*/
proc random_test {} {

#   unsigned int	i, j, k;	/* Loop variables. */
#   double	r;			/* Pseudo-random number. */
#   long		bins[NUM_BINS];	/* Bin. */

#   double	sum=0, sumsq=0;		/* Stats. */
  set sum 0.0

#   int		numtrue=0, numfalse=0;	/* Count booleans. */
#   unsigned int	rchi=100;	/* Number of bins in chisq test. */
#   unsigned int	nchi=1000;	/* Number of samples in chisq test. */
#   double	chisq;			/* Chisq error. */
#   double	elimit = 2*sqrt((double)rchi);	/* Chisq error limit. */
#   double	nchi_rchi = (double)nchi / (double)rchi;	/* Speed calculation. */
#   FILE		*rfile=NULL;	/* Handle for file of random integers. */

#   random_init();

  puts ""
  puts "Testing random numbers."

#   /*
#     * Uniform Distribution.
#     */

  puts "Uniform distribution.  Mean should be about 0.5."
  puts ""

#   for (i=0;i<NUM_BINS;i++) bins[i] = 0;

  for {set i 0} {$i < $::NUM_SAMPLES} {incr i} {
  
    set r [random_unit_uniform]    
    puts "r = $r"

    if {$r >= 0.0 && $r < 1.0} {

      # bins[(int)(r*NUM_BINS)]++;
      # sum += r;
      set sum [expr {$sum + $r}]
      # sumsq += SQU(r);

    } else {
      puts "Number generated out of range 0.0 <= r < 1.0."
    }
  }

  puts ""
  puts [format "Mean random = %f \n" [expr {$sum / $::NUM_SAMPLES}]]

#   printf("Standard deviation = %f\n", (sumsq - sum*sum/NUM_SAMPLES)/NUM_SAMPLES);

#   for (i=0;i<NUM_BINS;i++)
#     printf("%5.3f %ld\n", i/(double)NUM_BINS, bins[i]);


  #//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
  return true ;#  // ????????
  #//~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
}
# ------------------------------------------------------------------------------
proc test_random_seed {i} {

  random_seed $i ;# для random_rand (crossover) - f-rand.tl (c_random_util.c)

  mysrand $i     ;# для lrand (начальная инициация)

}
# /*----------------------------------------------------------------------------*/

# /*----------------------------------------------------------------------------*/
