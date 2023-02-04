/*
 * SPDX-License-Identifier: GPL-2.0
 */

#ifndef _WASM_H
#define _WASM_H    1
#include <stddef.h>

#ifndef EM_EXPORT
#  define EM_EXPORT(name)  __attribute__((used, export_name(#name)))
#endif

#ifndef EM_IMPORT
#  define EM_IMPORT(NAME)  __attribute__((import_module("env"), import_name(#NAME)))
#endif

#define likely(x)      __builtin_expect(!!(x), 1)
#define unlikely(x)    __builtin_expect(!!(x), 0)
#define PURE           __attribute__((pure))

// EM_IMPORT(now)     => time.c
// EM_IMPORT(jproc)   => _javascript_call.js


/*
 * memory layout. e.g: int stacksize = &__heap_base - &__data_end; // if no --stack-first
 *
 * |__memory_base
 * |    |__global_base
 * |    |          |__data_end     |__heap_base
 * |----+----------+---------------+----------------|
 * |    |          |               |                |
 * |    |   Data   |    Stack <--- |  ---> Heap     |
 * |    |          |               |                |
 * |----+----------+---------------+----------------|
 *
 * Some parameters associated with "wasm-ld.exe"
 *
 *   --initial-memory=<bytes>   Initial size of the linear memory
 *   --stack-first              Place STACK at start of linear memory rather than after DATA
 *   -z stack-size=<bytes>      Specifies the size of the STACK
 */
extern const int __memory_base;
extern const int __global_base;
extern const int __data_end;
extern const int __heap_base;
extern const int __table_base;   // unknown

/*
 * index : wasm currently only uses one memory block, so the value of index is "0"
 *
 * return: The page size of the memory (each one is 64KiB)
 */
extern size_t __builtin_wasm_memory_size(int index);

/*
 * index : 0
 *
 * number: The number of pages you want to grow the memory by (each one is 64KiB in size).
 *
 * return: The previous page size of the memory.
 *
 */
extern size_t __builtin_wasm_memory_grow(int index, size_t number);

/*
 * "-fwasm-exceptions" is required for clang.exe
 *
 * TODO: LLVM ERROR: undefined event symbol cannot be weak
 */
// extern void __builtin_wasm_throw(unsigned int, void*);
// extern void __builtin_wasm_rethrow();

#endif
