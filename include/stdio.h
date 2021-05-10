/*
* SPDX-License-Identifier: GPL-2.0
*/

#ifndef _STDIO_H
#define _STDIO_H    1
#include "stddef.h"
#include "_javascript_call.h"


#define EOF              (-1)
#define BUFSIZ           1024
#define FILENAME_MAX     512
#define putchar(c)       js_sendmessage(J_PUTCHAR, c, 0)

// printf.c
#include "printf.h"
#endif
