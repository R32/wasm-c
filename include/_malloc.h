/*
* (c)2021 Liu WeiMin
*
* SPDX-License-Identifier: GPL-2.0
*/

#ifndef __MALLOC_H
#define __MALLOC_H    1
#include "_cdefs.h"

C_FUNCTION_BEGIN

void* malloc(int size);
void* calloc(int size);
void* realloc(void* ptr, int size);
void free(void* ptr);

C_FUNCTION_END

#endif
