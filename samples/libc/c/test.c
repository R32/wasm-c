#include "assert.h"
#include "time.h"
#include "stdint.h"
#include "stddef.h"
#include "stdarg.h"
#include "float.h"
#include "limits.h"
#include "ctype.h"
#include "math.h"
#include "string.h"
#include "wchar.h"
#include "stdio.h"
#include "stdlib.h"
#include "WASM.h"

// Only used for pointers returned by malloc
#define BLK_BASE           (16)
#define IS_ALIGNED(ptr)    (((size_t)(ptr) & (BLK_BASE - 1)) == 0)

#define PTRSIZE(ptr)       (*(((int*)(ptr)) - 1))

// [min, max)
#define RAND(max, min)     ((rand() % ((max) - (min))) + (min))

static void shuffle(char* a[], int len) {
	char* tmp = NULL;
	int t;
	for(int i =0; i < len; i++) {
		t = RAND(len, 0);
		tmp = a[t];
		a[t] = a[i];
		a[i] = tmp;
	}
}

int ptr_intersect(const void* aa, const void* bb) {
	char* a = *(char**)aa;
	char* b = *(char**)bb;

	assert(IS_ALIGNED(a));

	assert(IS_ALIGNED(b));

	const int MAX = 1036; // ALIGN_16(1024 + sizeof(struct tag)) - sizeof(struct tag);

	assert(PTRSIZE(a) <= MAX);

	assert(PTRSIZE(b) <= MAX);

	if (a > b) {
		assert(b + PTRSIZE(b) < a);
	} else if (a < b) {
		assert(a + PTRSIZE(a) < b);
	} else {
		assert(0);
	}
	return a - b;
}

static void t_malloc() {
	const int max = 1024;
	char* aptr[max];

	for(int i = 0; i < max; i++) {
		aptr[i] = malloc(RAND(1024, 0));
	}
	shuffle(aptr, max);
	qsort(aptr, max, sizeof(aptr[0]), ptr_intersect);
	qsort(aptr, max, sizeof(aptr[0]), ptr_intersect);

	// release half of the pointers
	for(int i = max / 2; i < max; i++) free(aptr[i]);
	// realloc half of the pointers
	for(int i = max / 2; i < max; i++) aptr[i] = malloc(RAND(1024, 0));
	shuffle(aptr, max);
	qsort(aptr, max, sizeof(char*), ptr_intersect);
	qsort(aptr, max, sizeof(char*), ptr_intersect);

	// release half of the pointers
	for(int i = max / 2; i < max; i++) free(aptr[i]);
	// realloc half of the pointers
	for(int i = max / 2; i < max; i++) aptr[i] = malloc(RAND(1024, 0));
	shuffle(aptr, max);
	qsort(aptr, max, sizeof(char*), ptr_intersect);
	qsort(aptr, max, sizeof(char*), ptr_intersect);


	for(int i = max / 2; i < max; i++) free(aptr[i]);
	shuffle(aptr, max / 2);
	qsort(aptr, max / 2, sizeof(char*), ptr_intersect);
	qsort(aptr, max / 2, sizeof(char*), ptr_intersect);
	for(int i = 0; i < max / 2; i++) free(aptr[i]);
}

static void t_realloc() {
	// copied from _malloc.c
	struct tag {
		int size;
		void* __data__[0];
	};
	#define tag_of_ptr(ptr) container_of((void*)(ptr), struct tag, __data__)

	const char* cstr = "0123456789abcdefLOL";
	const int len = strlen(cstr);
	char* org = malloc(32);
	assert(tag_of_ptr(org)->size >= 32);
	strcpy(org, cstr);

	char* mid = realloc(org, 64);  // "org" will be released by realloc
	assert(tag_of_ptr(mid)->size >= 64);
	assert(strcmp(cstr, mid) == 0);

	char* nop = malloc(32);
	char* new = realloc(mid, 128); // "mid" will be released by realloc
	assert(new != mid);
	assert(tag_of_ptr(new)->size >= 128);
	assert(strcmp(cstr, new) == 0);
	free(new);
	free(nop);

	// TODO:

	// calloc
	int* pint = calloc(32, sizeof(int));
	assert(tag_of_ptr(pint)->size >= sizeof(int) * 32);
	for(int i =0; i < 32; i++)
		assert(pint[i] == 0);
	free(pint);
}

static void t_memcpy() {
	const int max = 128;
	const int haf = max / 2;
	char* p1 = malloc(sizeof(uint8_t) * max);
	char* ph = p1 + haf;
	const char* cstr = "ABCD EFGH IJKL MNOP QRST";
	const int len = strlen(cstr);

	strcpy(ph, cstr);
	assert(memcmp(ph, cstr, len) == 0);
	// memcpy
	memcpy(p1, ph, len);
	assert(memcmp(p1, ph, len) == 0);
	// memcpy + 3
	memcpy(p1 + 3, ph, len);
	assert(memcmp(p1 + 3, ph, len) == 0);

	memmove(ph - 1, ph, len);
	assert(memcmp(ph - 1, cstr, len) == 0);

	strcpy(ph, cstr); // reset
	memmove(ph - sizeof(int), ph, len);
	assert(memcmp(ph - sizeof(int), cstr, len) == 0);

	strcpy(ph, cstr); // reset
	memmove(ph + 1, ph, len);
	assert(memcmp(ph + 1, cstr, len) == 0);

	strcpy(ph, cstr); // reset
	memmove(ph + sizeof(int), ph, len);
	assert(memcmp(ph + sizeof(int), cstr, len) == 0);

	strcpy(ph, cstr); // reset
	memmove(ph + len, ph, len);
	assert(memcmp(ph + len, cstr, len) == 0);

	free(p1);
}

void t_math() {
	#define EPSILON          0.0000000001
	#define EPSILON_F        0.000001
	#define R30              (30 * 3.141592653589793 / 180)
	#define R30F             (float)R30
	#define FD(a, b)         assert(fabs((a) - (b)) < EPSILON)
	#define FF(a, b)         assert(fabsf((a) - (b)) < EPSILON_F)

	// Trigonometric functions
	FD(asin(sin(R30)), R30);
	FD(acos(cos(R30)), R30);
	FD(atan(tan(R30)), R30);
	FD(atan2(tan(R30), 1.0), R30);

	FF(asinf(sinf(R30F)), R30F);
	FF(acosf(cosf(R30F)), R30F);
	FF(atanf(tanf(R30F)), R30F);
	FF(atan2f(tanf(R30F),  1.0f), R30F);

	// Hyperbolic functions
	FD(asinh(sinh(R30)), R30);
	FD(acosh(cosh(R30)), R30);
	FD(atanh(tanh(R30)), R30);
	FF(asinhf(sinhf(R30F)), R30F);
	FF(acoshf(coshf(R30F)), R30F);
	FF(atanhf(tanhf(R30F)), R30F);

	// Exponential and logarithmic functions
	double fract = 0.;
	int e = 0;
}

void test() {
	t_realloc();
	int n = 10;
	while(n--)
		t_malloc();
	printf("malloc test done.\n");

	t_memcpy();
	printf("memory test done.\n");

	t_math();
	printf("  math test done.\n");
}
