/*
* SPDX-License-Identifier: GPL-2.0
*/

#ifndef _STDINT_H
#define _STDINT_H    1

// Types
#if __x86_64__
  typedef long long  intptr_t;
#else
  typedef long       intptr_t;
#endif
typedef long long    int64_t;
typedef char         int8_t;
typedef short        int16_t;
typedef int          int32_t;
typedef int64_t      intmax_t;
typedef char         int_fast8_t;
typedef int          int_fast16_t;
typedef int          int_fast32_t;
typedef int64_t      int_fast64_t;
typedef char         int_least8_t;
typedef short        int_least16_t;
typedef int          int_least32_t;
typedef int64_t      int_least64_t;

#if __x86_64__
  typedef unsigned long long  uintptr_t;
#else
  typedef unsigned long       uintptr_t;
#endif
typedef unsigned long long    uint64_t;
typedef unsigned char         uint8_t;
typedef unsigned short        uint16_t;
typedef unsigned int          uint32_t;
typedef          uint64_t     uintmax_t;
typedef unsigned char         uint_fast8_t;
typedef unsigned int          uint_fast16_t;
typedef unsigned int          uint_fast32_t;
typedef          uint64_t     uint_fast64_t;
typedef unsigned char         uint_least8_t;
typedef unsigned short        uint_least16_t;
typedef unsigned int          uint_least32_t;
typedef          uint64_t     uint_least64_t;

// Function-like macros
#define INT8_C(c)        c
#define INT16_C(c)       c
#define INT32_C(c)       c
#if __x86_64__
  #define INT64_C(c)     c ## L
#else
  #define INT64_C(c)     c ## LL
#endif

#define UINT8_C(c)       c
#define UINT16_C(c)      c
#define UINT32_C(c)      c ## U
#if __x86_64__
#  define UINT64_C(c)    c ## UL
#else
#  define UINT64_C(c)    c ## ULL
#endif

#if __x86_64__
#  define INTMAX_C(c)    c ## L
#  define UINTMAX_C(c)   c ## UL
#else
#  define INTMAX_C(c)    c ## LL
#  define UINTMAX_C(c)   c ## ULL
#endif

// Limits of stdint types

#define INT8_MIN         (-128)
#define INT16_MIN        (-32767-1)
#define INT32_MIN        (-2147483647-1)
#define INT64_MIN        (-INT64_C(9223372036854775807)-1)

#define INT8_MAX         (127)
#define INT16_MAX        (32767)
#define INT32_MAX        (2147483647)
#define INT64_MAX        (INT64_C(9223372036854775807))

#define UINT8_MAX        (255)
#define UINT16_MAX       (65535)
#define UINT32_MAX       (4294967295U)
#define UINT64_MAX       (UINT64_C(18446744073709551615))

#define INT_LEAST8_MIN   (-128)
#define INT_LEAST16_MIN  (-32767-1)
#define INT_LEAST32_MIN  (-2147483647-1)
#define INT_LEAST64_MIN  (-INT64_C(9223372036854775807)-1)

#define INT_LEAST8_MAX   (127)
#define INT_LEAST16_MAX  (32767)
#define INT_LEAST32_MAX  (2147483647)
#define INT_LEAST64_MAX  (INT64_C(9223372036854775807))

#define UINT_LEAST8_MAX  (255)
#define UINT_LEAST16_MAX (65535)
#define UINT_LEAST32_MAX (4294967295U)
#define UINT_LEAST64_MAX (UINT64_C(18446744073709551615))

#define INT_FAST8_MIN    (-128)
#define INT_FAST16_MIN   (-2147483647-1)
#define INT_FAST32_MIN   (-2147483647-1)
#define INT_FAST64_MIN   (-INT64_C(9223372036854775807)-1)

#define INT_FAST8_MAX    (127)
#define INT_FAST16_MAX   (2147483647)
#define INT_FAST32_MAX   (2147483647)
#define INT_FAST64_MAX   (INT64_C(9223372036854775807))

#define UINT_FAST8_MAX   (255)
#define UINT_FAST16_MAX  (4294967295U)
#define UINT_FAST32_MAX  (4294967295U)
#define UINT_FAST64_MAX  (UINT64_C(18446744073709551615))

#if __x86_64__
#  define INTPTR_MIN     (-9223372036854775807L-1)
#  define INTPTR_MAX     (9223372036854775807L)
#  define UINTPTR_MAX    (18446744073709551615UL)
#else
#  define INTPTR_MIN     (-2147483647-1)
#  define INTPTR_MAX     (2147483647)
#  define UINTPTR_MAX    (4294967295U)
#endif

// Limits of other types
#define INTMAX_MIN       (-INT64_C(9223372036854775807)-1)
#define INTMAX_MAX       (INT64_C(9223372036854775807))
#define UINTMAX_MAX      (UINT64_C(18446744073709551615))

#if __x86_64__
#  define PTRDIFF_MIN    (-9223372036854775807L-1)
#  define PTRDIFF_MAX    (9223372036854775807L)
#  define SIZE_MAX       (18446744073709551615UL)
#else
#  define PTRDIFF_MIN    (-2147483647-1)
#  define PTRDIFF_MAX    (2147483647)
#  define SIZE_MAX       (4294967295U)
#endif

#define SIG_ATOMIC_MIN   (-2147483647-1)
#define SIG_ATOMIC_MAX   (2147483647)

#ifndef WCHAR_MIN
#  define WCHAR_MIN      (0u)
#  define WCHAR_MAX      (UINT16_MAX)
#endif

#define WINT_MIN         (0u)
#define WINT_MAX         (4294967295u)

#endif
