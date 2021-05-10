#include "stdint.h"
#include "stddef.h"
#include "stdarg.h"
#include "float.h"
#include "limits.h"
#include "ctype.h"
#include "_malloc.h"
#include "math.h"
#include "string.h"
#include "WASM.h"

EM_IMPORT(log) void jslog(double a, double b, double c);

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
	jslog((int)"你好, 世界!", (int)L"你好, 世界!", (int)"hello world!");
	return sqrt(v);
}
