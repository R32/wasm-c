/*
* SPDX-License-Identifier: GPL-2.0
*/

#ifndef _ASSERT_H
#define _ASSERT_H    1

#ifdef NDEBUG
#  define assert(e)    ((void)0)
#  define _assert(e)   ((void)0)
#else
#  define _assert(e)   assert(e)
#  define assert(e)    ((e) ? ((void)0) : TODO(__FILE__, __LINE__, #e))
#endif

#endif
