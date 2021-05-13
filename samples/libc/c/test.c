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
	for(int i = 0; i < max; i++) {
		assert(PTRSIZE(aptr[i]) <= 1024);
	}
	qsort(aptr, max, sizeof(aptr[0]), ptr_intersect);

	// release half of the pointers
	for(int i = max / 2; i < max; i++) free(aptr[i]);
	// realloc half of the pointers
	for(int i = max / 2; i < max; i++) aptr[i] = malloc(RAND(1024, 0));
	shuffle(aptr, max);
	qsort(aptr, max, sizeof(char*), ptr_intersect);

	// release half of the pointers
	for(int i = max / 2; i < max; i++) free(aptr[i]);
	// realloc half of the pointers
	for(int i = max / 2; i < max; i++) aptr[i] = malloc(RAND(1024, 0));
	shuffle(aptr, max);
	qsort(aptr, max, sizeof(char*), ptr_intersect);


	for(int i = max / 2; i < max; i++) free(aptr[i]);
	shuffle(aptr, max / 2);
	qsort(aptr, max / 2, sizeof(char*), ptr_intersect);
	for(int i = 0; i < max / 2; i++) free(aptr[i]);
}

static void t_memcpy() {
	const int max = 128;
	const int haf = max / 2;
	char* p1 = malloc(sizeof(uint8_t) * max);
	char* ph = p1 + haf;
	const char* A_T = "ABCD EFGH IJKL MNOP QRST";
	const int len = strlen(A_T);

	strcpy(ph, A_T);
	assert(memcmp(ph, A_T, len) == 0);
	// memcpy
	memcpy(p1, ph, len);
	assert(memcmp(p1, ph, len) == 0);
	// memcpy + 3
	memcpy(p1 + 3, ph, len);
	assert(memcmp(p1 + 3, ph, len) == 0);

	memmove(ph - 1, ph, len);
	assert(memcmp(ph - 1, A_T, len) == 0);

	strcpy(ph, A_T); // reset
	memmove(ph - sizeof(int), ph, len);
	assert(memcmp(ph - sizeof(int), A_T, len) == 0);

	strcpy(ph, A_T); // reset
	memmove(ph + 1, ph, len);
	assert(memcmp(ph + 1, A_T, len) == 0);

	strcpy(ph, A_T); // reset
	memmove(ph + sizeof(int), ph, len);
	assert(memcmp(ph + sizeof(int), A_T, len) == 0);

	strcpy(ph, A_T); // reset
	memmove(ph + len, ph, len);
	assert(memcmp(ph + len, A_T, len) == 0);

	free(p1);
}

void test() {
	int n = 10;
	while(n--)
		t_malloc();
	t_memcpy();
}
