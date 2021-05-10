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

#ifdef __cplusplus
#  define NULL                   0L
#else
#  define NULL                   ((void *)0)
#endif

#define offsetof(type, member) __builtin_offsetof(type, member)

#define container_of(ptr, type, member) ({\
    const __typeof__(((type *)0)->member) * __mptr = (ptr);\
    (type *)((char *)ptr - offsetof(type, member)); })

#ifndef ARRRYSIZE
#  define ARRRYSIZE(a)         (sizeof(a) / sizeof((a)[0]))
#endif

#endif
