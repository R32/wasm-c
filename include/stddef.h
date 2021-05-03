/*
* SPDX-License-Identifier: GPL-2.0
*/

#ifndef _STDDEF_H
#define _STDDEF_H    1

typedef unsigned long int      size_t;
typedef long int               ptrdiff_t;

#define NULL                   ((void *)0)

#define offsetof(type, member)  __builtin_offsetof(type, member)

#endif
