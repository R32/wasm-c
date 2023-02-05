/*
 * SPDX-License-Identifier: GPL-2.0
 */

#include "string.h"
#include "stdint.h"
#include "_builtin.h"

// Copying

#define NOT_ALIGN(p) ((uintptr_t)(p) & (sizeof(int)-1))

EM_EXPORT(memcpy) void* memcpy(void* dst, const void* src, size_t n) {
	char *d = dst;
	const char *s = src;

	while(n && NOT_ALIGN(s)) {
		*d++ = *s++;
		n--;
	}

	if ( !NOT_ALIGN(d) ) {
		while(n >= 16) {
			*(int*)(d + 0)  = *(int*)(s + 0);
			*(int*)(d + 4)  = *(int*)(s + 4);
			*(int*)(d + 8)  = *(int*)(s + 8);
			*(int*)(d + 12) = *(int*)(s + 12);
			n -= 16;
			d += 16;
			s += 16;
		}
		if (n & 8) {
			*(int*)(d + 0) = *(int*)(s + 0);
			*(int*)(d + 4) = *(int*)(s + 4);
			d += 8;
			s += 8;
		}
		if (n & 4) {
			*(int*)(d + 0) = *(int*)(s + 0);
			d += 4;
			s += 4;
		}
		if (n & 2) {
			*d++ = *s++;
			*d++ = *s++;
		}
		if (n & 1) {
			*d = *s;
		}
	} else {
		while (n--)
			*d++ = *s++;
	}
	return dst;
}

void* memmove(void* dst, const void* src, size_t n) {
	char *d = dst;
	const char *s = src;
	const int x = s - d;
	if (x > 0) {
		if (x >= sizeof(int))
			return memcpy(d, s, n);
		while(n--)
			*d++ = *s++;
	} else if (x < 0) {
		if (-x >= n)
			return memcpy(d, s, n);
		while(n--)
			d[n] = s[n];
	}
	return dst;
}

char* strcpy(char* dst, const char* src) {
	char* const r = dst;
	while((*dst = *src)) {
		dst++;
		src++;
	}
	return r;
}

char* strncpy(char* dst, const char* src, size_t n) {
	char* const r = dst;
	while(n-- && (*dst = *src)) {
		dst++;
		src++;
	}
	return r;
}

//// Concatenation

char* strcat(char* dst, const char* src) {
	strcpy(dst + strlen(dst), src);
	return dst;
}

char* strncat(char* dst, const char* src, size_t n) {
	strncpy(dst + strlen(dst), src, n);
	return dst;
}

//// Comparison:

EM_EXPORT(memcmp) int memcmp(const void* v1, const void* v2, size_t n) {
	const unsigned char *l = v1, *r = v2;
	while(n && *l == *r) {
		n--;
		l++;
		r++;
	}
	return n ? *l - *r : 0;
}

int strcmp(const char* s1, const char* s2) {
	while(*s1 == *s2 && *s1) {
		s1++;
		s2++;
	}
	return *(uint8_t*)s1 - *(uint8_t*)s2;
}

int strncmp(const char* s1, const char* s2, size_t n) {
	while(n && *s1 == *s2 && *s1) {
		n--;
		s1++;
		s2++;
	}
	return n ? *(uint8_t*)s1 - *(uint8_t*)s2 : 0;
}

//// Searching:

void* memchr(const void* src, int c, size_t n) {
	const unsigned char* s = src;
	while(n && *s != c) {
		n--;
		s++;
	}
	return n ? (void*)s : NULL;
}

char* strchr(const char* src, int c) {
	int x = *src;
	while(x && x != c) {
		x = *src++;
	}
	return !x ? (char*)src : NULL;
}

#define BITOP(a, b, op) \
    ((a)[(size_t)(b) / (8 * sizeof *(a))]\
    op\
    (size_t) 1 << ((size_t)(b) % (8 * sizeof *(a))))

size_t strcspn(const char* str, const char* sub) {
	if (!sub[0] || !sub[1])
		return strchr(str, *sub) - str;
	size_t c = *(uint8_t*)sub;
	const uint8_t* s = (uint8_t*)str;
	size_t bitmap[32 / sizeof(size_t)] = {0};
	do {
		BITOP(bitmap, c, |=);
		sub++;
		c = *(uint8_t*)sub;
	} while(c);
	while((c = *s) && !BITOP(bitmap, c, &))
		s++;
	return s - (uint8_t*)str;
}

char* strpbrk(const char* str, const char* sub) {
	str += strcspn(str, sub);
	return *str ? (char*)str : NULL;
}

char* strrchr(const char* str, int c) {
	size_t n = strlen(str) + 1;
	while(n--) {
		if (((uint8_t*)str)[n] == c)
			return (char*)str + n;
	}
	return NULL;
}

size_t strspn(const char* str, const char* sub) {
	const uint8_t* s = (uint8_t*)str;
	size_t c = *(uint8_t*)sub;
	if (!c)
		return 0;
	if (!sub[1]) {
		while(*s == c)
			s++;
		return s - (uint8_t*)str;
	}
	size_t bitmap[32 / sizeof(size_t)] = {0};
	do {
		BITOP(bitmap, c, |=);
		sub++;
		c = *(uint8_t*)sub;
	} while(c);

	while((c = *s) && BITOP(bitmap, c, &))
		s++;
	return s - (uint8_t*)str;
}

char* strstr(const char* str, const char* sub) {
	if (*sub == 0)
		return (char*) str;
	const char* a;
	const char* b = sub;
	for(; *str; str++) {
		if (*str != *b)
			continue;
		a = str;
		while(1) {
			if (*b == 0)
				return (char*) str;
			if (*a++ != *b++)
				break;
		}
		b = sub;
	}
	return NULL;
}

//// Other:

EM_EXPORT(memset) void *memset(void *dst, int c, size_t n) {
	c = (char)c;
	char *d = dst;
	int c32 = c | c << 8 | c << 16 | c << 24;
	while(n && NOT_ALIGN(d)) {
		*d++ = c;
		n--;
	}
	while(n >= 16) {
		*(int*)(d + 0)  = c32;
		*(int*)(d + 4)  = c32;
		*(int*)(d + 8)  = c32;
		*(int*)(d + 12) = c32;
		n -= 16;
		d += 16;
	}
	if (n & 8) {
		*(int*)(d + 0) = c32;
		*(int*)(d + 4) = c32;
		d += 8;
	}
	if (n & 4) {
		*(int*)(d + 0) = c32;
		d += 4;
	}
	if (n & 2) {
		*d++ = c;
		*d++ = c;
	}
	if (n & 1) {
		*d = c;
	}
	return dst;
}

size_t strlen(const char* s) {
	const char* const a = s;
	while(*s)
		s++;
	return s - a;
}
