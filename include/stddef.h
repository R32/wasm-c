/*
* SPDX-License-Identifier: GPL-2.0
*/

#ifndef _STDDEF_H
#define _STDDEF_H    1

#if __x86_64__
  typedef unsigned long long   size_t;
  typedef long long            ptrdiff_t;
#else
  typedef unsigned long        size_t;
  typedef long                 ptrdiff_t;
#endif

#define NULL                   ((void *)0)

#define offsetof(type, member) __builtin_offsetof(type, member)

#endif
