/*
* SPDX-License-Identifier: GPL-2.0
*/

#ifndef _STDIO_H
#define _STDIO_H    1
#include "stddef.h"
#include "stdint.h"
#include "_javascript_call.h"

#define EOF              (-1)
#define BUFSIZ           1024
#define FILENAME_MAX     512
#define putchar(c)       js_sendmessage(J_PUTCHAR, c, 0)

// printf, sprintf, snprintf, vsnprintf, vprintf
#include "printf.h"


// None of the following functions have been implemented
typedef long             FILE;
#define SEEK_SET         0
#define SEEK_CUR         1
#define SEEK_END         2

// Operations on files:
int remove(const char*);
int rename(const char*, const char*);
char* tmpnam(char*);
FILE* tmpfile(void);

// File access:
int fclose(FILE*);
int fflush(FILE*);
FILE* fopen(const char*, const char*);
FILE* freopen(const char*, const char*, FILE*);
void setbuf(FILE*, char*);
int setvbuf(FILE*, char*, int, size_t);

// Formatted input/output:
int fprintf(FILE*, const char*, ...);
int fscanf(FILE*, const char*, ...);
int scanf(const char*, ...);
int sscanf(const char*, const char*, ...);
int sscanf(const char*, const char*, ...);
int vfprintf(FILE*, const char*, __builtin_va_list);
int vfscanf(FILE*, const char*, __builtin_va_list);
int vscanf(const char*, __builtin_va_list);
int vsprintf(char*, const char*, __builtin_va_list);
int vsscanf(const char*, const char*, __builtin_va_list);

// Character input/output:
int fgetc(FILE*);
char* fgets(char*, int, FILE*);
int fputc(int, FILE*);
int fputs(const char*, FILE*);
int getc(FILE*);
int getchar(void);
char* gets(char*);
int putc(int, FILE*);
int fputs(const char*, FILE*);
int ungetc(int, FILE*);

// Direct input/output:
size_t fread(void*, size_t, size_t, FILE*);
size_t fwrite(const void*, size_t, size_t, FILE*);

// File positioning:
typedef union {
	char __opaque[16];
	long long __lldata;
	double __align;
} fpos_t;
int fgetpos(FILE*, fpos_t*);
int fseek(FILE*, long, int);
int fsetpos(FILE*, const fpos_t*);
long ftell(FILE*);
void rewind(FILE*);

// Error-handling:
void clearerr(FILE*);
int feof(FILE*);
int ferror(FILE*);
void perror(const char*);

#endif
