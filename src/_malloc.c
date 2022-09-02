/*
* (c)2021 Liu WeiMin
*
* SPDX-License-Identifier: GPL-2.0
*/
#include "_builtin.h"
#include "_malloc.h"
#include "stddef.h"
#include "_javascript_call.h"

/**
 The starting position of the heap, uses `&__heap_base` to get its value
*/
extern const int __heap_base;

/**
 index : wasm currently only uses one memory block, so the value of index is "0"

 return: The page size of the memory (each one is 64KiB)
*/
extern unsigned long __builtin_wasm_memory_size(int index);

/**
 index : 0

 number: The number of pages you want to grow the memory by (each one is 64KiB in size).

 return: The previous page size of the memory.
*/
extern unsigned long __builtin_wasm_memory_grow(int index, unsigned long number);


#define PAGE_SIZE         (1024 * 64)

#define memory_base()     ((int)&__heap_base)

#define memory_size()     (__builtin_wasm_memory_size(0) * PAGE_SIZE)

#define memory_grow(page) ({             \
    __builtin_wasm_memory_grow(0, page); \
    js_sendmsg(J_MEMGROW, 0, 0);         \
})

struct tag {
	int size;
	void* __data__[0];
};

#define TAG_DATABPTR(tag) ((unsigned char*)&(tag)->__data__)
#define TAG_DATASIZE(tag) ((tag)->size)
#define FREE_NEXT(tag)    ((tag)->__data__[0])
#define FREE_ROOT(idx)    (root.FL[idx])
#define FREE_MAX          10
#define BLK_BASE          8

// memory root
static struct {
	int pos;
	int max;
	struct tag* FL[FREE_MAX + 1];
} root = {
	.pos = memory_base(),
	.max = 0,
};

#define NOT_POW2(size, pow2)   (size & (pow2 - 1))
#define ALIGN_POW2(size, pow2) ((((size) - 1) | (pow2 - 1)) + 1)

static inline int sz_align(int size) {
	if (size < BLK_BASE) {
		size = BLK_BASE;
	} else if (NOT_POW2(size, BLK_BASE)) {
		size = ALIGN_POW2(size, BLK_BASE);
	}
	return size;
}

static inline int fl_index(int mul8) {
	int idx = (mul8 / BLK_BASE) - 1;
	return idx < FREE_MAX ? idx : FREE_MAX;
}

static struct tag* fl_get(int size) {
	int idx = fl_index(size);
	struct tag* curr = FREE_ROOT(idx);
	if (curr && idx < FREE_MAX) {
		FREE_ROOT(idx) = FREE_NEXT(curr);
		return curr;
	}
	struct tag* prev = NULL;
	while(curr) {
		int rest = TAG_DATASIZE(curr) - size;
		if (rest < 0) {
			prev = curr;
			curr = FREE_NEXT(curr);
			continue;
		}
		rest -= sizeof(struct tag);
		if (rest >= size) { // Do Splits
			struct tag* fork = (struct tag*)(TAG_DATABPTR(curr) + size);
			TAG_DATASIZE(curr) = size;
			TAG_DATASIZE(fork) = rest;
			FREE_NEXT(fork) = FREE_NEXT(curr);
			FREE_NEXT(curr) = fork;
		}
		if (prev) {
			FREE_NEXT(prev) = FREE_NEXT(curr);
		} else {
			FREE_ROOT(idx) = FREE_NEXT(curr);
		}
		break;
	}
	return curr;
}

#define GROW_EXTRA    1

EM_EXPORT(malloc) void* malloc(int size) {
	size = sz_align(size);
	struct tag* tag = fl_get(size);
	if (tag)
		return TAG_DATABPTR(tag);
	int diff;
	int fullsize = size + sizeof(struct tag);
Recalc:
	diff = root.pos + fullsize - root.max;
	if (diff > 0) {
		if (root.max == 0) {
			root.max = memory_size();
			goto Recalc;
		}
		// If grow fails, the browser will throw an error.
		memory_grow(GROW_EXTRA + ALIGN_POW2(diff, PAGE_SIZE) / PAGE_SIZE);
		root.max = memory_size();
	}
	tag = (struct tag*)root.pos;
	TAG_DATASIZE(tag) = size;
	root.pos += fullsize;
	return TAG_DATABPTR(tag);
}

EM_EXPORT(calloc) void* calloc(int count, int elem) {
	int size = sz_align(count * elem);
	int* const ptr = malloc(size);
	int*       end = ptr + (size / sizeof(int)) - 1;
	while(end >= ptr) {
		*end-- = 0;
	#if (BLK_BASE >= 8)
		*end-- = 0;
	#endif
	}
	return ptr;
}

static inline void freetag(struct tag* tag) {
	int idx = fl_index(TAG_DATASIZE(tag));
	FREE_NEXT(tag) = FREE_ROOT(idx);
	FREE_ROOT(idx) = tag;
}

EM_EXPORT(realloc) void* realloc(void* ptr, int size) {
	if ((int)ptr < memory_base())
		return malloc(size); // if do realloc(0, size)
	size = sz_align(size);
	struct tag* tag = container_of(ptr, struct tag, __data__);
	if (size <= TAG_DATASIZE(tag))
		return ptr;
	// detects if the tag is at the end of the memory
	if ((int)ptr + TAG_DATASIZE(tag) == root.pos) {
		int diff = (int)ptr + size - root.max;
		if (diff > 0) {
			memory_grow(GROW_EXTRA + ALIGN_POW2(diff, PAGE_SIZE) / PAGE_SIZE);
			root.max = memory_size();
		}
		root.pos = (int)ptr + size;
		TAG_DATASIZE(tag) = size;
		return ptr;
	}
	void* const new = malloc(size);
	int* dst = (int*)new;
	int* src = (int*)ptr;
	int* max = src + TAG_DATASIZE(tag) / sizeof(int);
	while(src < max) {
		*dst++ = *src++;
	#if (BLK_BASE >= 8)
		*dst++ = *src++;
	#endif
	}
	freetag(tag);
	return new;
}

EM_EXPORT(free) void free(void* ptr) {
	if ((int)ptr < memory_base())
		return;
	struct tag* tag = container_of(ptr, struct tag, __data__);
	// if tag is at the end of
	if ((int)ptr + TAG_DATASIZE(tag) == root.pos) {
		root.pos -= TAG_DATASIZE(tag) + sizeof(struct tag);
	} else {
		freetag(tag);
	}
}
