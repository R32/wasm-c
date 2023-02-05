/*
 * SPDX-License-Identifier: GPL-2.0
 */

#include "_ucs2.h"
#include "stddef.h"

/**
 wchar_t* to UTF8

 @param max: Maximum number of bytes to be written to dest.
*/
int wcsto_u(char* dst, const wchar_t* src, size_t max) {
	int c;
	size_t i = 0;
	if (dst == NULL || max == 0) {
		while((c = *src++)) {
			if (c < 0x80) {
				i++;
			} else if (c < 0x800) {
				i += 2;
			} else if (c >= 0xD800 && c <= 0xDFFF) {
				if (*src++ == 0)
					break;
				i += 4;
			} else {
				i += 3;
			}
		}
		return i;
	}
	int k, c2;
	while(i < max && (c = *src++)) {
		if (c < 0x80) {
			dst[i++] = c;
		} else if (c < 0x800) {
			dst[i++] = (0xC0 | (c >> 6));
			dst[i++] = (0x80 | (c & 63));
		} else if (c >= 0xD800 && c <= 0xDFFF) {
			c2 = *src++;
			if (!c2)
				break;
			k = (((c - 0xD800) << 10) | (c2 - 0xDC00)) + 0x10000;
			dst[i++] = 0xF0 |  (k >> 18);
			dst[i++] = 0x80 | ((k >> 12) & 63);
			dst[i++] = 0x80 | ((k >> 6) & 63);
			dst[i++] = 0x80 |  (k & 63);
		} else {
			dst[i++] = 0xE0 |  (c >> 12);
			dst[i++] = 0x80 | ((c >> 6) & 63);
			dst[i++] = 0x80 |  (c & 63);
		}
	}
	if (i < max)
		dst[i] = 0;
	return i;
}

/**
 UTF8 to wchar_t*

 @param max: maximum number of wchar_t characters to write to dest
*/
int u_towcs(wchar_t* dest, const char* src, size_t max) {
	size_t acc = 0, c, c2, c3, c4;
	if (dest == NULL || max == 0) {
		while ((c = *src++)) {
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
	while ((acc < max) && (c = *src++)) {
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
			dest[acc++] = (c >> 10) + 0xD7C0;
			dest[acc++] = (c & 0x3FF) + 0xDC00;
			continue;
		}
		dest[acc++] = c;
	}
	if (acc < max)
		dest[acc] = 0;
	return acc;
}
