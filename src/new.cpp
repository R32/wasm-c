/*
 * SPDX-License-Identifier: GPL-2.0
 */
#include "stddef.h"
#include "_malloc.h"

void* operator new(size_t n) {
	return malloc(n);
}

void operator delete(void *p) {
	free(p);
}

#include "_javascript_call.h"
extern "C" void __cxa_pure_virtual() { // no idea what's this
	js_sendmsg(J_ASSERT, (int)__FILE__, __LINE__);
}
