/*
 * (c)2021 Liu WeiMin
 *
 * SPDX-License-Identifier: GPL-2.0
 */
#include "_builtin.h"
#include "_malloc.h"
#include "stddef.h"
#include "_javascript_call.h"

struct tag {
	int size;
	char __data__[0];
};

#define TAG_BYTES(ptag)   ((ptag)->size + sizeof(struct tag))
#define TAG_OF_ALLOC(ptr) (container_of(ptr, struct tag, __data__))
#define TAG_DATABPTR(tag) ((unsigned char*)(tag)->__data__)
#define TAG_DATASIZE(tag) ((tag)->size)
#define FREE_NEXT(tag)    (*(void**)(tag)->__data__)
#define FREE_ROOT(idx)    (root.FL[idx])
#define FREE_MAX          (12)

#if defined(__wasm_simd128__ ) || defined(__LP64__)
#   define BLK_BASE       (16)
#else
#   define BLK_BASE       ( 8)
#endif

#define PAGE_SIZE         (1024 * 64)
// This aligns the "ptr" returned by "malloc"
#define memory_base()     (((size_t)&__heap_base) + (BLK_BASE - sizeof(struct tag)))
#define memory_size()     (__builtin_wasm_memory_size(0) * PAGE_SIZE)
#define memory_grow(page) do {           \
    __builtin_wasm_memory_grow(0, page); \
    js_sendmsg(J_MEMGROW, 0, 0);         \
} while(0)

// memory root
static struct {
	size_t pos;
	size_t max;
	struct tag* FL[FREE_MAX + 1];
} root = {
	.pos = memory_base(),
	.max = 0,
};

#define NOT_ALIGNED(size, pow2)    (size & (pow2 - 1))
#define ALIGN_POW2(size, pow2)     ((((size) - 1) | (pow2 - 1)) + 1)

static inline int sz_align(int size) {
	if (size < BLK_BASE)
		return BLK_BASE;
	return ALIGN_POW2(size, BLK_BASE);
}

static inline int fl_index(int size) {
	int idx = (size / BLK_BASE) - 1;
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
	while (curr) {
		int full = TAG_BYTES(curr);
		if (full < size) {
			prev = curr;
			curr = FREE_NEXT(curr);
			continue;
		}
		if (full >= size + (BLK_BASE * (FREE_MAX + 1))) { // Do Splits
			struct tag* fork = (struct tag*)((char*)curr + size);
			TAG_DATASIZE(curr) = size - sizeof(struct tag);
			TAG_DATASIZE(fork) = full - sizeof(struct tag) - size;
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
	size = sz_align(size + sizeof(struct tag));
	struct tag* tag = fl_get(size);
	if (tag)
		return TAG_DATABPTR(tag);
	int diff;
Recalc:
	diff = root.pos + size - root.max;
	if (diff > 0) {
		if (!root.max) {
			root.max = memory_size();
			goto Recalc;
		}
		// If grow fails, the browser will throw an error.
		memory_grow(GROW_EXTRA + ALIGN_POW2(diff, PAGE_SIZE) / PAGE_SIZE);
		root.max = memory_size();
	}
	tag = (struct tag*)root.pos;
	TAG_DATASIZE(tag) = size - sizeof(struct tag);
	root.pos += size;
	return TAG_DATABPTR(tag);
}

EM_EXPORT(calloc) void* calloc(int count, int elem) {
	void *const ptr = malloc(count * elem);
	int *i = ptr;
	int *const max = i + (TAG_DATASIZE(TAG_OF_ALLOC(ptr)) / sizeof(int));
	while (i < max) {
		*i++ = 0;
	}
	return ptr;
}

static inline void freetag(struct tag* tag) {
	int idx = fl_index(TAG_BYTES(tag));
	FREE_NEXT(tag) = FREE_ROOT(idx);
	FREE_ROOT(idx) = tag;
}

EM_EXPORT(realloc) void* realloc(void* ptr, int size) {
	if (ptr == NULL)
		return malloc(size);
	if (size <= 0) {
		free(ptr);
		return NULL;
	}
	if ((size_t)ptr < memory_base() || NOT_ALIGNED((size_t)ptr, BLK_BASE))
		return NULL;

	size = sz_align(size + sizeof(struct tag));
	struct tag* tag = TAG_OF_ALLOC(ptr);
	if (size <= TAG_BYTES(tag))
		return ptr;
	// detects if the tag is at the end of the memory
	if ((size_t)ptr + TAG_DATASIZE(tag) == root.pos) {
		int diff = (size_t)tag + size - root.max;
		if (diff > 0) {
			memory_grow(GROW_EXTRA + ALIGN_POW2(diff, PAGE_SIZE) / PAGE_SIZE);
			root.max = memory_size();
		}
		root.pos = (size_t)tag + size;
		TAG_DATASIZE(tag) = size - sizeof(struct tag);
		return ptr;
	}
	void* const new = malloc(size - sizeof(struct tag));
	int* dst = (int*)new;
	int* src = (int*)ptr;
	int* max = src + TAG_DATASIZE(tag) / sizeof(int);
	while(src < max) {
		*dst++ = *src++;
	}
	freetag(tag);
	return new;
}

EM_EXPORT(free) void free(void* ptr) {
	if ((size_t)ptr < memory_base() || NOT_ALIGNED((size_t)ptr, BLK_BASE))
		return;
	struct tag* tag = TAG_OF_ALLOC(ptr);
	// if tag is at the end of
	if ((size_t)ptr + TAG_DATASIZE(tag) == root.pos) {
		root.pos -= TAG_BYTES(tag);
	} else {
		freetag(tag);
	}
}
