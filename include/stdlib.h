/*
* SPDX-License-Identifier: GPL-2.0
*/

#ifndef _STDLIB_H
#define _STDLIB_H    1
#include "_cdefs.h"
#include "stdint.h"
#include "string.h"
#include "wchar.h"
#include "_ucs2.h"
#include "_malloc.h"

#define EXIT_SUCCESS                 0
#define EXIT_FAILURE                 1
#define RAND_MAX                     (0x7fffffff)
#define mblen(mbs, mb)               strnlen(mbs, len)
#define mbstowcs(dst, src, mb)       u_towcs(dst, src, mb)
#define wcstombs(dst, src, wc)       wcsto_u(dst, src, wc)
#define atoi(s)                      atol(s)
#define atof(str)                    strtod(str, NULL)

C_FUNCTION_BEGIN
// int wctomb (char* pmb, wchar_t wc);
// int mbtowc (wchar_t* pwc, const char* pmb, size_t max);

long int atol(const char *str);
double strtod(const char* str, char** endptr);

long int strtol (const char* str, char** endptr, int base);
// unsigned long int strtoul (const char* str, char** endptr, int base);

int rand (void);
void srand (unsigned int seed);

// void abort (void);
// int atexit (void (*func)(void));
// void exit (int status);
// char* getenv (const char* name);
// int system (const char* command);

inline int abs (int n) { return n < 0 ? -n : n; }
inline long int labs (long int n) { return n < 0 ? -n : n; }

// typedef struct { long quot; long rem; } div_t, ldiv_t;
// div_t div (int numer, int denom);
// ldiv_t ldiv (long int numer, long int denom);

void* bsearch (const void* key, const void* base, size_t num, size_t size,
	int (*compar)(const void*, const void*));

void qsort (void* base, size_t num, size_t size,
	int (*compar)(const void*, const void*));

C_FUNCTION_END
#endif
