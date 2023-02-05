#include "WASM.h"

// export by "wasm-ld --export=square" in Makefile
int square(int n) {
	return n * n;
}

EM_IMPORT(trace) void trace(double a, double b, double c, double d);
EM_IMPORT(js_sqrt) double js_sqrt(double x);
EM_IMPORT(stamp) double stamp();
EM_IMPORT(rand) int rand(int n);
EM_IMPORT(frand) double frand();

// export by EM_EXPORT
EM_EXPORT(test) void arbitrary_name() {
	int r1 = rand(100);
	double r2 = frand();
	trace((int)&__memory_base, (int)&__global_base, (int)&__data_end, (int)&__heap_base);

	double last = stamp();
	double acc = 0.;
	for(int i = 0; i < 100; i++) {
		acc += __builtin_sqrt(i / r2);
	}
	trace(stamp() - last, acc, 0, 0);
	// next
	last = stamp();
	acc = 0.;
	for(int i = 0; i < 100; i++) {
		acc += js_sqrt(i / r2);
	}
	trace(stamp() - last, acc, 0, 0);
}
