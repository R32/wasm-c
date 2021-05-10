/*
* SPDX-License-Identifier: GPL-2.0
*/

#ifndef _JAVASCRIPT_CALL_H
#define _JAVASCRIPT_CALL_H    1
#include "_builtin.h"

enum JS_MESSAGE {
	J_ASSERT = 9, // reserve 0~8
	J_ABORT, 
	J_MEMGROW,
	J_PUTCHAR,
};

EM_IMPORT(jproc) int js_sendmessage(enum JS_MESSAGE msg, int wparam, int lparam);


#endif


