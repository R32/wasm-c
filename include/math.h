/*
 * SPDX-License-Identifier: GPL-2.0
 */

#ifndef _MATH_H
#define _MATH_H    1
#include "_builtin.h"
#include "_cdefs.h"

#ifndef NO_OPENLIBM
C_FUNCTION_BEGIN
// https://github.com/JuliaMath/openlibm
// Trigonometric functions
double cos(double x);
double sin(double x);
double tan(double x);
double acos(double x);
double asin(double x);
double atan(double x);
double atan2(double x, double y);
float  cosf(float x);
float  sinf(float x);
float  tanf(float x);
float  acosf(float x);
float  asinf(float x);
float  atanf(float x);
float  atan2f(float x, float y);

// Hyperbolic functions
double cosh(double x);
double sinh(double x);
double tanh(double x);
double acosh(double x);
double asinh(double x);
double atanh(double x);
float  coshf(float x);
float  sinhf(float x);
float  tanhf(float x);
float  acoshf(float x);
float  asinhf(float x);
float  atanhf(float x);

// Exponential and logarithmic functions
double exp(double x);
double frexp(double x, int* i);
double ldexp(double x, int i);
double log(double x);
double log10(double x);
double modf(double x, double y);
double exp2(double x);
double expm1(double x);
double ilogb(double x);
double log1p(double x);
double log2(double x);
double logb(double x);
double scalbn(double x, int i);
double scalbln(double x, int l);

float  expf(float x);
float  frexpf(float x, int* i);
float  ldexpf(float x, int i);
float  logf(float x);
float  log10f(float x);
float  modff(float x, float y);
float  exp2f(float x);
float  expm1f(float x);
float  ilogbf(float x);
float  log1pf(float x);
float  log2f(float x);
float  logbf(float x);
float  scalbnf(float x, int i);
float  scalblnf(float x, int l);

// Power functions
//// double sqrt(double)
//// float  sqrtf(float)
double pow(double, double);
float  powf(float, float);
double cbrt(double x);
double hypot(double x, double y);
float  cbrtf(float x);
float  hypotf(float x, float y);

// Error and gamma functions
double erf(double x);
double erfc(double x);
double tgamma(double x);
double lgamma(double x);
float  erff(float x);
float  erfcf(float x);
float  tgammaf(float x);
float  lgammaf(float x);

// Rounding and remainder functions
//// double ceil(double)
//// float  ceilf(float)
//// double floor(double);
//// float  floorf(float)
//// double trunc(double);
////  float truncf(float);
//// double rint(double);
////  float rintf(float);
//// double nearbyint(double);
////  float nearbyintf(float);

double fmod(double x, double y);
double round(double x);
double lround(double x);
double llround(double x);
double lrint(double x);
double llrint(double x);
double remainder(double x, double y);
double remquo(double x, double y, int* quot);
float  fmodf(float x, float y);
float  roundf(float x);
float  lroundf(float x);
float  llroundf(float x);
float  lrintf(float x);
float  llrintf(float x);
float  remainderf(float x, float y);
float  remquof(float x, float y, int* quot);

// Floating-point manipulation functions
//// double copysign(double, double);
//// float  copysignf(float, float);
double nan(const char* tag);
double nextafter(double x, double y);
double nexttoward(double x, long double y);
float  nanf(const char* tag);
float  nextafterf(float x, float y);
float  nexttowardf(float x, long double y);

// Others
double fma(double x, double y, double z);
float  fmaf(float x, float y, float z);

C_FUNCTION_END
#endif



// Trigonometric functions
// #define cos(x)              TODO
// #define sin(x)              TODO
// #define tan(x)              TODO
// #define acos(x)             TODO
// #define asin(x)             TODO
// #define atan(x)             TODO
// #define atan2(x, y)         TODO

// Hyperbolic functions
// #define cosh(x)             TODO
// #define sinh(x)             TODO
// #define tanh(x)             TODO
// acosh(x)                    c++11
// asinh(x)                    c++11
// atanh(x)                    c++11

// Exponential and logarithmic functions
// #define exp(x)              TODO
// #define frexp(x, i)         TODO
// #define ldexp(x, i)         TODO
// #define log(x)              TODO
// #define log10(x)            TODO
// #define modf(x, y)          TODO
// exp2(x)                     c++11
// expm1(x)                    c++11
// ilogb(x)                    c++11
// log1p(x)                    c++11
// log2(x)                     c++11
// logb(x)                     c++11
// scalbn(x, i)                c++11
// scalbln(x, l)               c++11

// Power functions
#define sqrt(x)                __builtin_sqrt(x)
#define sqrtf(x)               __builtin_sqrtf(x)
// cbrt(x)                     c++11
// hypot(x, y)                 c++11

// Error and gamma functions
// erf(x)                      c++11
// erfc(x)                     c++11
// tgamma(x)                   c++11
// lgamma(x)                   c++11

// Rounding and remainder functions
#define ceil(x)                __builtin_ceil(x)
#define ceilf(x)               __builtin_ceilf(x)
#define floor(x)               __builtin_floor(x)
#define floorf(x)              __builtin_floorf(x)
// #define fmod(x, y)          TODO
#define trunc(x)               __builtin_trunc(x)
#define truncf(x)              __builtin_truncf(x)
// round(x)                    c++11
// lround(x)                   c++11
// llround(x)                  c++11
#define rint(x)                __builtin_rint(x)
#define rintf(x)               __builtin_rintf(x)
// lrint(x)                    c++11
// llrint(x)                   c++11
#define nearbyint(x)           __builtin_nearbyint(x)
#define nearbyintf(x)          __builtin_nearbyintf(x)
// remainder(x, y)             c++11
// remquo(x, y, pi)            c++11

// Floating-point manipulation functions
#define copysign(x, y)         __builtin_copysign(x, y)
#define copysignf(x, y)        __builtin_copysignf(x, y)
// nan(pc)                     c++11
// nextafter(x, y)             c++11
// nexttoward(x, y)            c++11

// Minimum, maximum, difference functions
// fdim(x, y)                  c++11
#define fmax(x, y)             __builtin_wasm_max_f64(x, y)
#define fmaxf(x, y)            __builtin_wasm_max_f32(x, y)
#define fmin(x, y)             __builtin_wasm_min_f64(x, y)
#define fminf(x, y)            __builtin_wasm_min_f32(x, y)

// Other functions
#define fabs(x)                __builtin_fabs(x)
#define fabsf(x)               __builtin_fabsf(x)
#define abs(x)                 __builtin_fabs(x)
// fma(x, y, z)                c++11

// Classification macro / functions
// fpclassify(x)               c++11
#define isfinite(x)            __builtin_isfinite(x)
#define isinf(x)               __builtin_isinf(x)
#define isnan(x)               __builtin_isnan(x)
#define isnormal(x)            __builtin_isnormal(x)
#define signbit(x)             __builtin_signbit(x)

// Comparison macro / functions
#define isgreater(x, y)        __builtin_isgreater(x, y)
#define isgreaterequal(x, y)   __builtin_isgreaterequal(x, y)
#define isless(x, y)           __builtin_isless(x, y)
#define islessequal(x, y)      __builtin_islessequal(x, y)
#define islessgreater(x, y)    __builtin_islessgreater(x, y)
#define isunordered(x, y)      __builtin_isunordered(x, y)

// Macro constants
#define math_errhandling       2
#define INFINITY               __builtin_inff()
#define NAN                    __builtin_nanf("")
#define HUGE_VAL               INFINITY
#define HUGE_VALF              ((double)INFINITY)
#define HUGE_VALL              ((long double)INFINITY)


typedef float                  float_t;
typedef double                 double_t;

#endif
