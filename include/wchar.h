/*
 * SPDX-License-Identifier: GPL-2.0
 */

#ifndef _WCHAR_H
#define _WCHAR_H    1
#include "_cdefs.h"
#include "stddef.h"

#ifndef __cplusplus
typedef unsigned short wchar_t;
#endif

#ifndef WCHAR_MIN
#  define WCHAR_MIN      0
#  define WCHAR_MAX      65535
#endif

C_FUNCTION_BEGIN

// double wcstod (const wchar_t* str, wchar_t** endptr);
// long int wcstol (const wchar_t* str, wchar_t** endptr, int base);
// unsigned long int wcstoul(const wchar_t* str, wchar_t** endptr, int base);

wchar_t* wcscat (wchar_t* destination, const wchar_t* source);
wchar_t* wcschr (const wchar_t* ws, wchar_t wc);
int wcscmp (const wchar_t* wcs1, const wchar_t* wcs2);
// #define wcscoll(s1, s2) wcscmp(s1, s2)
wchar_t* wcscpy (wchar_t* destination, const wchar_t* source);
// size_t wcscspn (const wchar_t* wcs1, const wchar_t* wcs2);
size_t wcslen (const wchar_t* wcs);
wchar_t* wcsncat (wchar_t* destination, const wchar_t* source, size_t num);
int wcsncmp (const wchar_t* wcs1, const wchar_t* wcs2, size_t num);
wchar_t* wcsncpy (wchar_t* destination, const wchar_t* source, size_t num);
// wchar_t* wcspbrk (const wchar_t* wcs1, const wchar_t* wcs2);
wchar_t* wcsrchr (const wchar_t* ws, wchar_t wc);
// size_t wcsspn (const wchar_t* wcs1, const wchar_t* wcs2);
// wchar_t* wcsstr (const wchar_t* wcs1, const wchar_t* wcs2);
// wchar_t* wcstok (wchar_t* wcs, const wchar_t* delimiters, wchar_t** p);
// size_t wcsxfrm (wchar_t* destination, const wchar_t* source, size_t num);

// wchar_t* wmemchr (const wchar_t* ptr, wchar_t wc, size_t num);
// int wmemcmp (const wchar_t* ptr1, const wchar_t* ptr2, size_t num);
// wchar_t* wmemcpy (wchar_t* destination, const wchar_t* source, size_t num);
// wchar_t* wmemmove (wchar_t* destination, const wchar_t* source, size_t num);
// wchar_t* wmemset (wchar_t* ptr, wchar_t wc, size_t num);



// wint_t btowc (int c);
// size_t mbrlen (const char* pmb, size_t max, mbstate_t* ps);
// size_t mbrtowc (wchar_t* pwc, const char* pmb, size_t max, mbstate_t* ps);
// int mbsinit (const mbstate_t* ps);
// size_t mbsrtowcs (wchar_t* dest, const char** src, size_t max, mbstate_t* ps);
// size_t wcrtomb (char* pmb, wchar_t wc, mbstate_t* ps);
// int wctob (wint_t wc);
// size_t wcsrtombs (char* dest, const wchar_t** src, size_t max, mbstate_t* ps);

C_FUNCTION_END
#endif
