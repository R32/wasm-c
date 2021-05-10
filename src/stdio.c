/*
* SPDX-License-Identifier: GPL-2.0
*/

#include "stdio.h"

void _putchar (char c) {
	js_sendmessage(J_PUTCHAR, c, 0);
}
