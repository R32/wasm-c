/*
* SPDX-License-Identifier: GPL-2.0
*/

#ifndef _TIME_H
#define _TIME_H    1
#include "stddef.h"

#define CLOCKS_PER_SEC   1000L

typedef unsigned long    clock_t;

typedef long long        time_t;

struct tm {
	int tm_sec;          // seconds after the minute [0-60]
	int tm_min;          // minutes after the hour [0-59]
	int tm_hour;         // hours since midnight [0-23]
	int tm_mday;         // day of the month [1-31]
	int tm_mon;          // months since January [0-11]
	int tm_year;         // years since 1900
	int tm_wday;         // days since Sunday [0-6]
	int tm_yday;         // days since January 1 [0-365]
	int tm_isdst;        // Daylight Savings Time flag
	long __tm_gmtoff;    // offset from CUT in seconds
	char* __tm_zone;     // timezone abbreviation
};

#include "_cdefs.h"
C_FUNCTION_BEGIN

clock_t clock();

time_t time(time_t* t);

double difftime(time_t end, time_t start);

// time_t mktime(struct tm* pt);
// char* asctime(const struct tm * timeptr);
// char* ctime(const time_t * timer);
// struct tm* gmtime(const time_t * timer);
// struct tm* localtime(const time_t* t); 
// size_t strftime(char* ptr, size_t maxsize, const char* format, const struct tm* timeptr);

C_FUNCTION_END
#endif
