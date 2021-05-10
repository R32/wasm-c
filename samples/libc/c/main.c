#include "stdint.h"
#include "stddef.h"
#include "stdarg.h"
#include "stdio.h"
#include "float.h"
#include "limits.h"
#include "ctype.h"
#include "_malloc.h"
#include "math.h"
#include "string.h"
#include "WASM.h"

extern const int __heap_base;
extern const int __data_end;
extern const int __global_base;

EM_EXPORT(test) double arbitrary_name(double v) {
	printf("-%s %ls-", "hello", L"世界");
	printf("global_base: %d, data_end: %d, heap_base: %d, stack size: %d\n",
		(int)&__global_base,
		(int)&__data_end,
		(int)&__heap_base,
		(&__data_end == &__heap_base) // --stack-first
			? (int)&__global_base
			: (int)&__heap_base - (int)&__data_end
	);
	return sqrt(v);
}
