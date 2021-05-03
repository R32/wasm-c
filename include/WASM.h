/*
* SPDX-License-Identifier: GPL-2.0
*/

#ifndef _WASM_H
#define _WASM_H    1

#ifndef EM_EXPORT
#  define EM_EXPORT(name)  __attribute__((used, export_name(#name)))
#endif

#ifndef EM_IMPORT
#  define EM_IMPORT(NAME)  __attribute__((import_module("env"), import_name(#NAME)))
#endif

// stack_size = (&__heap_base - &__data_end)
extern const int __data_end;     // the end offset of the data section
extern const int __global_base;  // __data_base ???
extern const int __heap_base;    // the start offset of the heap
extern const int __memory_base;  // ths start offset of the whole memeory???
extern const int __dso_handle;   // ???
extern const int __table_base;   // ???
extern void __wasm_call_ctors(); // ???

#endif
