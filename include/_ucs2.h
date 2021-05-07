/*
* SPDX-License-Identifier: GPL-2.0
*/

#ifndef __UCS2_H
#define __UCS2_H    1
#include "_cdefs.h"
C_FUNCTION_BEGIN

int wcsto_u(char* dst, const unsigned short* src, int cw);

int u_towcs(unsigned short* dst, const char* src, int cb);

C_FUNCTION_END
#endif
