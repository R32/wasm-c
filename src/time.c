/*
 * SPDX-License-Identifier: GPL-2.0
 */

#include "time.h"
#include "_builtin.h"

EM_IMPORT(now) double js_datenow();

clock_t clock() {
	static time_t prev = 0;
	if (prev == 0) {
		prev = (time_t)js_datenow();
		return 0;
	}
	return (clock_t)((time_t)js_datenow() - prev);
}

time_t time(time_t* t) {
	time_t now = (time_t)js_datenow();
	if (t != NULL)
		*t = now;
	return now;
}

double difftime(time_t end, time_t beginning) {
	return (double)(end - beginning);
}
