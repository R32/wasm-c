#include "stdint.h"
#include "limits.h"
#include "ctype.h"
#include "WASM.h"

// export by "wasm-ld --export=square" in Makefile
int square(int n) {
	return n * n;
}
// export by macro
EM_IMPORT(log) void log(int a, int b, int c);

EM_EXPORT(test) int arbitrary_name(int c) {
	int stacksize = &__heap_base - &__data_end;
	log((int)&__data_end, (int)&__heap_base, stacksize);
	return isalpha(c); // ctype.c
}
