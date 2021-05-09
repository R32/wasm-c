/*
* SPDX-License-Identifier: GPL-2.0
*/

#include "stdlib.h"
#include "ctype.h"
#include "string.h"

/*
double strtod (const char* s, char** endptr) {
	int neg = 0;
	while(isspace(*s))
		s++;
	switch (*s) {
	case '-': neg = 1;
	case '+': s++;
	}
	
	while(*s) {
		switch(*s++) {
		case '0':
			break;
		case '1':
			break;
		case '2':
			break;
		case '3':
			break;
		case '4':
			break;
		case '5':
			break;
		case '6':
			break;
		case '7':
			break;
		case '8':
			break;
		case '9':
			break;
		case '.':
			break;
		case 'E':
		case 'e':
			break;
		default:
		}
	}
	return 0.;
}
*/

// double atof(const char* s) { return strtod(s, NULL); }

long atol(const char* s) {
	long n = 0;
	int neg = 0;
	while (isspace(*s))
		s++;
	switch (*s) {
	case '-': neg = 1;
	case '+': s++;
	}
	/* Compute n as a negative number to avoid overflow on LONG_MIN */
	while (isdigit(*s))
		n = 10 * n - (*s++ - '0');
	return neg ? n : -n;
}

typedef int (*compar)(const void*,const void*);

void* bsearch (const void* key, const void* base, size_t num, size_t size, compar cmp) {
	void* pivot;
	int sign;
	while(num > 0) {
		pivot = (char*)base + size * (num / 2);
		sign = cmp(key, pivot);
		if (sign < 0) {
			num /= 2;
		} else if (sign > 0) {
			base = (char *)pivot + size;
			num -= num / 2 + 1;
		} else {
			return pivot;
		}
	}
	return NULL;
}

// base + i * size
#define BIS(i)        ((char*)base + (i) * size)
#define BISCMP(x, y)  cmp(BIS(x), BIS(y))
static void inline st_swap(void* a, void* b, void* t, size_t size) {
	memcpy(t, a, size);
	memcpy(a, b, size);
	memcpy(b, t, size);
}
/** 
 This function takes last element as pivot, 
 places the pivot element at its correct position in sorted array, 
 and places all smaller (smaller than pivot) to left of pivot 
 and all greater elements to right of pivot 
*/
static int st_partition(void* base, int low, int high, size_t size, compar cmp) {
	char t[size];
	int pivot = high;
	// Index of smaller element and indicates the right position of pivot found so far
	int i = (low - 1);
	for (int j = low; j < high; j++) {
		// If current element is smaller than the pivot
		if (BISCMP(j, pivot) < 0) {
			// increment index of smaller element
			i++;
			st_swap(BIS(i), BIS(j), t, size);
		}
	}
	st_swap(BIS(i + 1), BIS(high), t, size);
	return i + 1;
}
static void st_inner(void* base, int low, int high, size_t size, compar cmp) {
	if (low < high) {
		int pi = st_partition(base, low, high, size, cmp);
		st_inner(base, low, pi - 1, size, cmp);
		st_inner(base, pi + 1, high, size, cmp);
	}
}
/**
 Copied from https://www.geeksforgeeks.org/quick-sort/
 
 Maybe we can move `size` and `cmp` out as STATIC to reduce stack data
 which will prevent stack overflow as much as possible
*/
void qsort(void* base, size_t num, size_t size, compar cmp) {
	st_inner(base, 0, num - 1, size, cmp);
}


