#include "WASM.h"

// the builtin variables & function
extern const int __memory_base;
extern const int __global_base;
extern const int __data_end;
extern const int __heap_base;
extern const int __table_base;
extern const int __dso_handle;
void __wasm_call_ctors();

// export by "wasm-ld --export=square" in Makefile
int square(int n) {
	return n * n;
}

EM_IMPORT(log) void log(int a, int b, int c);

// export by macro
EM_EXPORT(test) int arbitrary_name(int c) {
	int stacksize = &__heap_base - &__data_end;
	log((int)&__data_end, (int)&__heap_base, stacksize);
	return c;
}
