/*
* SPDX-License-Identifier: GPL-2.0
*/

#ifndef _MATH_H
#define _MATH_H    1
#include "_builtin.h"

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
// #define pow(x, y)           TODO
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
