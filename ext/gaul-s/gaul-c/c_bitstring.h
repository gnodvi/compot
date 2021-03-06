/*******************************************************************************
  ga_bitstring.h
  ******************************************************************************

  ga_bitstring - GAUL's low-level bitstring routines.
  Copyright ©2001-2006, Stewart Adcock <stewart@linux-domain.com>
  All rights reserved.

  Synopsis:     Low-level bitstring handling functions.

 ******************************************************************************/

#ifndef GA_BITSTRING_H_INCLUDED
#define GA_BITSTRING_H_INCLUDED

//------------------------------------------------------------------------------
/*
 * Includes.
 */
//#include "gaul.h"
#include "c_all_util.h"

#include <stdio.h>
#include <math.h>
#include <stdlib.h>
#include <string.h>

#ifdef HAVE_LIMITS_H
#include <limits.h>
#endif

/*
 * Prototypes.
 */
gaulbyte *ga_bit_new (int length);
void      ga_bit_free (gaulbyte *bstr);
void      ga_bit_set (gaulbyte *bstr, int n);
void      ga_bit_clear (gaulbyte *bstr, int n);
void      ga_bit_invert (gaulbyte *bstr, int n);
boolean   ga_bit_get (gaulbyte *bstr, int n);
void      ga_bit_randomize (gaulbyte *bstr, int n);
void      ga_bit_copy (gaulbyte *dest, gaulbyte *src, int ndest, int nsrc, int length);
size_t    ga_bit_sizeof (int length);
gaulbyte *ga_bit_clone (gaulbyte *dest, gaulbyte *src, int length);

/* Integer conversion. */
unsigned int ga_bit_decode_binary_uint (gaulbyte *bstr, int n, int length);
void    ga_bit_encode_binary_uint (gaulbyte *bstr, int n, int length, unsigned int value);
int     ga_bit_decode_binary_int (gaulbyte *bstr, int n, int length);
void    ga_bit_encode_binary_int (gaulbyte *bstr, int n, int length, int value);
int     ga_bit_decode_gray_int (gaulbyte *bstr, int n, int length);
void    ga_bit_encode_gray_int (gaulbyte *bstr, int n, int length, int value);
unsigned int ga_bit_decode_gray_uint (gaulbyte *bstr, int n, int length);
void    ga_bit_encode_gray_uint (gaulbyte *bstr, int n, int length, unsigned int value);

/* Real conversion. */
double  ga_bit_decode_binary_real (gaulbyte *bstr, int n, int mantissa, int exponent);
void    ga_bit_encode_binary_real (gaulbyte *bstr, int n, int mantissa, int exponent, double value);
double  ga_bit_decode_gray_real (gaulbyte *bstr, int n, int mantissa, int exponent);
void    ga_bit_encode_gray_real (gaulbyte *bstr, int n, int mantissa, int exponent, double value);

/* Test. */
boolean ga_bit_test (void);

//------------------------------------------------------------------------------
#endif	/* GA_BITSTRING_H_INCLUDED */
//------------------------------------------------------------------------------
