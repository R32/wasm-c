/*
* SPDX-License-Identifier: GPL-2.0
*/

#ifndef __UCS2_H
#define __UCS2_H    1
#include "_cdefs.h"
#include "wchar.h"
C_FUNCTION_BEGIN

int wcsto_u(char* dest, const wchar_t* src, size_t max);

int u_towcs(wchar_t* dest, const char* src, size_t max);

C_FUNCTION_END
#endif
