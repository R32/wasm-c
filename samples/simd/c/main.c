#include "WASM.h"
#include "simd128.h" // defined(__wasm_simd128__)
#include "stdlib.h"

EM_IMPORT(trace) void trace(double a, double b, double c, double d);
EM_IMPORT(stamp) double stamp();
EM_IMPORT(rand) int __rand(int n);
EM_IMPORT(frand) double frand();

EM_EXPORT(test) void test() {
	float a[] = {1.0f, 2.0f, 3.0f, 4.0f};
	float b[] = {10.f, 20.f, 30.f, 40.f};
	float r[] = {0.f, 0.f, 0.f, 0.f};
	v128_t va = wasm_v128_load(a);
	v128_t vb = wasm_v128_load(b);
	v128_t vr = wasm_f32x4_add(va, vb);
	wasm_v128_store(r, vr);
	trace(r[0], r[1], r[2], r[3]);
}
