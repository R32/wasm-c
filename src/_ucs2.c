/*
* SPDX-License-Identifier: GPL-2.0
*/

#include "_ucs2.h"
#include "stddef.h"

/**
 NOTE: the resulting string stored in dst is not null-terminated.

 cw means wchar length for src
*/
int wcsto_u(char* dst, const unsigned short* src, int cw) {
	int c;
	int i = 0;
	const unsigned short* const end = src + (cw > 0 ? cw : 0x7fffffff);
	if (dst == NULL || cw == 0) {
		while(src < end && (c = *src++)) {
			if (c < 0x80) {
				i++;
			} else if (c < 0x800) {
				i += 2;
			} else if (c >= 0xD800 && c <= 0xDFFF) {
				if (src == end)
					break;
				src++;
				i += 4;
			} else {
				i += 3;
			}
		}
		return i;
	}
	int k;
	while(src < end && (c = *src++)) {
		if (c < 0x80) {
			dst[i++] = c;
		} else if (c < 0x800) {
			dst[i++] = (0xC0 | (c >> 6));
			dst[i++] = (0x80 | (c & 63));
		} else if (c >= 0xD800 && c <= 0xDFFF) {
			if (src == end)
				break;
			k = (((c - 0xD800) << 10) | (((int)*src++) - 0xDC00)) + 0x10000;
			dst[i++] = 0xF0 |(k>>18);
			dst[i++] = 0x80 | ((k >> 12) & 63);
			dst[i++] = 0x80 | ((k >> 6) & 63);
			dst[i++] = 0x80 | (k & 63);
		} else {
			dst[i++] = 0xE0 | (c >> 12);
			dst[i++] = 0x80 | ((c >> 6) & 63);
			dst[i++] = 0x80 | (c & 63);
		}
	}
	return i;
}

/**
 NOTE: the resulting string stored in dst is not null-terminated.

 cb means byte length for src
*/
int u_towcs(unsigned short* dst, const char* src, int cb) {
	int acc = 0, c, c2, c3, c4;
	const char* const end = src + (cb > 0 ? cb : 0x7fffffff);
	if (dst == NULL || cb == 0) {
		while ((src < end) && (c = *src++)) {
			if (c < 0x80) {
			} else if (c < 0xE0) {
				if(!(0x80 & (*src++)))
					break;
			} else if (c < 0xF0) {
				c2 = *src++;
				c3 = *src++;
				if(!(0x80 & c2 & c3))
					break;
			} else {
				c2 = *src++;
				c3 = *src++;
				c4 = *src++;
				if(!(0x80 & c2 & c3 & c4))
					break;
				acc += 2; // surrogate pair
				continue;
			}
			acc++;
		}
		return acc;
	}
	while ((src < end) && (c = *src++)) {
		if (c < 0x80) {
		} else if (c < 0xC0) {
			break;
		} else if (c < 0xE0) {
			c2 = *src++;
			if (!(c2 & 0x80))
				break;
			c = ((c & 0x3F) << 6) | (c2 & 0x7F);
		} else if (c < 0xF0) {
			c2 = *src++;
			c3 = *src++;
			if (!(c2 & c3 & 0x80))
				break;
			c = ((c & 0x1F) << 12) | ((c2 & 0x7F) << 6) | (c3 & 0x7F);
		} else {
			c2 = *src++;
			c3 = *src++;
			c4 = *src++;
			if (!(c2 & c3 & c4 & 0x80))
				break;
			c = ((c & 0x0F) << 18) | ((c2 & 0x7F) << 12) | ((c3 & 0x7F) << 6) | (c4 & 0x7F);
			dst[acc++] = (c >> 10) + 0xD7C0;
			dst[acc++] = (c & 0x3FF) + 0xDC00;
			continue;
		}
		dst[acc++] = c;
	}
	return acc;
}
