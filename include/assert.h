/*
 * SPDX-License-Identifier: GPL-2.0
 */

#ifndef _ASSERT_H
#define _ASSERT_H    1
#include "_cdefs.h"
#include "_javascript_call.h"
C_FUNCTION_BEGIN

#ifdef NDEBUG
#  define assert(e)    ((void)0)
#  define _assert(e)   ((void)0)
#else
#  define _assert(e)   assert(e)
#  define assert(e)    ((e) ? ((void)0) : ((void)js_sendmsg(J_ASSERT, (int)__FILE__, __LINE__)))
#endif

C_FUNCTION_END
#endif
