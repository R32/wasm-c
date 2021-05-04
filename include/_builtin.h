/*
* SPDX-License-Identifier: GPL-2.0
*/
#ifndef __BUILTIN_H
#define __BUILTIN_H    1

#define likely(x)      __builtin_expect(!!(x), 1)
#define unlikely(x)    __builtin_expect(!!(x), 0)

#ifndef EM_EXPORT
#  define EM_EXPORT(name)  __attribute__((used, export_name(#name)))
#endif

#ifndef EM_IMPORT
#  define EM_IMPORT(NAME)  __attribute__((import_module("env"), import_name(#NAME)))
#endif

#endif
