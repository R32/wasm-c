/*
 * SPDX-License-Identifier: GPL-2.0
 */
#include "wchar.h"

size_t wcslen (const wchar_t* ws) {
	const wchar_t* const a = ws;
	while(*ws)
		ws++;
	return ws - a;
}

wchar_t* wcscpy(wchar_t* dst, const wchar_t* src) {
	while((*dst = *src)) {
		dst++;
		src++;
	}
	return dst;
}

wchar_t* wcsncpy(wchar_t* dst, const wchar_t* src, size_t n) {
	while(n-- && (*dst = *src)) {
		dst++;
		src++;
	}
	return dst;
}

int wcscmp(const wchar_t* wcs1, const wchar_t* wcs2) {
	while(*wcs1 == *wcs2 && *wcs1) {
		wcs1++;
		wcs2++;
	}
	return *(wchar_t*)wcs1 - *(wchar_t*)wcs2;
}

int wcsncmp(const wchar_t* wcs1, const wchar_t* wcs2, size_t n) {
	while(n && *wcs1 == *wcs2 && *wcs1) {
		n--;
		wcs1++;
		wcs2++;
	}
	return n ? *(wchar_t*)wcs1 - *(wchar_t*)wcs2 : 0;
}

wchar_t* wcscat(wchar_t* dst, const wchar_t* src) {
	wcscpy(dst + wcslen(dst), src);
	return dst;
}

wchar_t* wcsncat(wchar_t* dst, const wchar_t* src, size_t n) {
	wcsncpy(dst + wcslen(dst), src, n);
	return dst;
}

wchar_t* wcschr(const wchar_t* ws, wchar_t c) {
	int x = *ws;
	while(x && x != c) {
		x = *ws++;
	}
	return !x ? (wchar_t*)ws : NULL;
}

wchar_t* wcsrchr(const wchar_t* ws, wchar_t c) {
	size_t n = wcslen(ws) + 1;
	while(n--) {
		if (ws[n] == c)
			return (wchar_t*)ws + n;
	}
	return NULL;
}
