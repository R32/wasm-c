/*
 * SPDX-License-Identifier: GPL-2.0
 */

#ifndef __CDEFS_H
#define __CDEFS_H    1

#ifndef C_FUNCTION_BEGIN
#  ifdef __cplusplus
#      define C_FUNCTION_BEGIN extern "C" {
#      define C_FUNCTION_END };
#  else
#      define C_FUNCTION_BEGIN
#      define C_FUNCTION_END
#  endif
#endif

#endif
