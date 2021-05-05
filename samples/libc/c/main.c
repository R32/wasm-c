#include "stdint.h"
#include "stddef.h"
#include "stdarg.h"
#include "float.h"
#include "limits.h"
#include "ctype.h"
#include "_malloc.h"
#include "math.h"
#include "WASM.h"

EM_IMPORT(log) void log(int a, int b, int c);

int sumargs(int n, ...) {
	int count = 0;
	va_list vl;
	va_start(vl, n);
	for(int i=0; i < n; i++) {
		count += va_arg(vl, int);
	}
	va_end(vl);
	return count;
}

EM_EXPORT(test) double arbitrary_name(double v) {
	int* pi = malloc(sizeof(int) * 128);
	log(1, sumargs(3, 1, 2, 3), (int)pi);
	free(pi);
	return sqrt((3.141592653589793) * v / 441000.);
}
