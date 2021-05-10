/*
* SPDX-License-Identifier: GPL-2.0
*/

#include "stdio.h"

void _putchar (char c) {
	js_sendmessage(J_PUTCHAR, c, 0);
}

//
FILE* fopen(const char* path, const char* mod) {
	return 0;
}

size_t fread(void* dst, size_t size, size_t count, FILE* stream) {
	return 0;
}

size_t fwrite(const void* src, size_t size, size_t count, FILE* stream) {
	return 0;
}

int fseek(FILE* stream, long offset, int origin) {
	return EOF;
}

int fclose(FILE* stream) {
	return EOF;
}
int fflush(FILE* stream) {
	return EOF;
}
