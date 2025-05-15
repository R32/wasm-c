/*
 * SPDX-License-Identifier: GPL-2.0
 */

#include "stdlib.h"
#include "ctype.h"
#include "string.h"
#include "math.h"

/*
 * simple strtod
 */
double strtod (const char *restrict s, char **restrict endptr)
{
	while(isspace(*s))
		s++;
	int neg = 0;
	switch (*s) {
	case '-': neg = 1;
	case '+': s++;
	}
	double value = 0.;
	while (isdigit(*s))
		value = value * 10.0 + (*s++ - '0');
	if (*s == '.') {
		s++;
		double fract = 1.;
		while(isdigit(*s)) {
			fract *= 0.1;
			value += (double)(*s++ - '0') * fract;
		}
	}
	if (*s == 'e' || *s == 'E') {
		s++;
		int exp = 0;
		double fract = 10.;
		switch(*s) {
		case '-': fract = 0.1;
		case '+': s++;
		}
		while(isdigit(*s))
			exp = 10 * exp + (*s++ - '0');
		while(1) {
			if (exp & 1)
				value *= fract;
			if (!(exp >>= 1))
				break;
			fract *= fract;
		}
	}
	if (*s == 'f' || *s == 'F' || *s == 'l' || *s == 'L')
		s++;
	if (endptr) *endptr = (char*)s;
	return neg ? -value : value;
}

long atol(const char *s)
{
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

typedef int (*compare)(const void*,const void*);

void *bsearch (const void *key, const void *base, size_t num, size_t size, compare cmp)
{
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
static void inline st_swap(void *a, void *b, void *t, size_t size)
{
	if (a == b)
		return;
	memcpy(t, a, size);
	memcpy(a, b, size);
	memcpy(b, t, size);
}
/*
 * This function takes last element as pivot,
 * places the pivot element at its correct position in sorted array,
 * and places all smaller (smaller than pivot) to left of pivot
 * and all greater elements to right of pivot
 */
static int st_partition(void *base, int low, int high, size_t size, compare cmp)
{
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
static void st_inner(void *base, int low, int high, size_t size, compare cmp)
{
	if (low < high) {
		int pi = st_partition(base, low, high, size, cmp);
		st_inner(base, low, pi - 1, size, cmp);
		st_inner(base, pi + 1, high, size, cmp);
	}
}
/*
 * Copied from https://www.geeksforgeeks.org/quick-sort/
 */
void qsort(void *base, size_t num, size_t size, compare cmp)
{
	st_inner(base, 0, num - 1, size, cmp);
}
