/*
* SPDX-License-Identifier: GPL-2.0
*/
#ifndef _STRING_H
#define _STRING_H    1
#include "stddef.h"
#include "_cdefs.h"
C_FUNCTION_BEGIN

//// Copying
void* memcpy(void* dst, const void* src, size_t n);
void* memmove(void* dst, const void* src, size_t n);
char* strcpy(char* dst, const char* src);
char* strncpy(char* dst, const char* src, size_t n);

//// Concatenation
char* strcat(char* dst, const char* src);
char* strncat(char* dst, const char* src, size_t n);

//// Comparison
int memcmp(const void* v1, const void* v2, size_t n);
int strcmp(const char *s1, const char *s2);
int strncmp(const char* s1, const char* s2, size_t n);

//// Searching
void* memchr(const void* src, int c, size_t n);
char* strchr(const char* src, int c);
size_t strcspn(const char* str, const char* sub);
char* strpbrk(const char* str, const char* sub);
char* strrchr(const char* str, int c);
size_t strspn(const char* str, const char* sub);
char* strstr(const char* str, const char* sub);

//// Other
void *memset(void *dst, int c, size_t n);
size_t strlen(const char* s);

// char* strtok(char* str, const char* delim); // useless
// size_t strxfrm(char* dst, const char* src, size_t n);  
// #define strcoll(s1, s2) strcmp(s1, s2)
// char* strerror(int errnum)


C_FUNCTION_END
#endif
