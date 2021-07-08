#include "assert.h"
#include "time.h"
#include "stdint.h"
#include "stddef.h"
#include "stdarg.h"
#include "stdio.h"
#include "float.h"
#include "limits.h"
#include "ctype.h"
#include "math.h"
#include "string.h"
#include "wchar.h"
#include "stdlib.h"
#include "WASM.h"

extern const int __heap_base;
extern const int __data_end;
extern const int __global_base;
extern void test();

struct npc {
	unsigned char x, y;
	unsigned short width, height;
	int health;
	float speed;
	char name[32];
	wchar_t cname[32];
	double power;
};

EM_IMPORT(jojotest) void jojotest(struct npc* npc);

EM_EXPORT(test) double arbitrary_name(double v) {
	srand(time(NULL));
	printf("Only supports ansi characters!\n");
	printf("global_base: %d, data_end: %d, heap_base: %d, stack size: %d\n",
		(int)&__global_base,
		(int)&__data_end,
		(int)&__heap_base,
		(&__data_end == &__heap_base) // --stack-first
			? (int)&__global_base
			: (int)&__heap_base - (int)&__data_end
	);
	printf("wcslen: %d\n", wcslen(L"年年岁岁花相似"));
	struct npc jojo = {
		.x = 8,
		.y = 12,
		.width = 16,
		.height = 20,
		.health = 100,
		.speed = 1.5,
		.name = "jojo",
		.cname = L"乔乔",
		.power = 2.2,
	};
	jojotest(&jojo);
	test();
	return v;
}
