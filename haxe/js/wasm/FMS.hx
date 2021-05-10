package js.wasm;

import js.lib.DataView;
import js.lib.WebAssembly;
import js.lib.ArrayBuffer;
import js.lib.webassembly.Memory;

@:native("_FMS")
class FMS {

	var cmem : Memory;

	var view : DataView;

	var output : js.html.DivElement;

	function new( imports : Dynamic ) {
		if (imports.env == null)
			imports.env = {};
		this.cmem = imports.env.memory;
		if (imports.env.jproc == null)
			imports.env.jproc = this.defProc;
	}

	static public function init( buf : ArrayBuffer, imports : Dynamic ) {
		if (js.Syntax.typeof(CStub.fms) != "undefined")
			throw new js.lib.Error("single instance only");
		var fms = new FMS(imports);
		return WebAssembly.instantiate(buf, imports).then(function( moi ) {
			var inst = moi.instance;
			if (fms.cmem == null)
				fms.cmem = cast inst.exports.memory;
			fms.view = new DataView(fms.cmem.buffer);
			CStub.select(cast inst.exports, fms);
			return moi;
		});
	}

	inline function atostr(a) return js.Syntax.code("String.fromCharCode.apply(null, {0})", a);

	public function readUTF8( ptr : Ptr, max : Int ) : String {
		if (max < 0) {
			max = view.byteLength;
		} else {
			max = ptr + max;
		}
		var a = [];
		var i = 0;
		var c, c2, c3, c4;
		inline function CHAR(p) return view.getUint8(p);
		while((ptr : Int) < max) {
			c = CHAR(ptr++);
			if (c < 0x80) {
				if (c == 0)
					break;
			} else if (c < 0xE0) {
				c2 = CHAR(ptr++);
				if ((c2 & 0x80) == 0)
					break;
				c = ((c & 0x3F) << 6) | (c2 & 0x7F);
			} else if (c < 0xF0) {
				c2 = CHAR(ptr++);
				c3 = CHAR(ptr++);
				if ((c2 & c3 & 0x80) == 0)
					break;
				c = ((c & 0x1F) << 12) | ((c2 & 0x7F) << 6) | (c3 & 0x7F);
			} else {
				c2 = CHAR(ptr++);
				c3 = CHAR(ptr++);
				c4 = CHAR(ptr++);
				if ((c2 & c3 & c4 & 0x80) == 0)
					break;
				c = ((c & 0x0F) << 18) | ((c2 & 0x7F) << 12) | ((c3 & 0x7F) << 6) | (c4 & 0x7F);
				a.push((c >> 10) + 0xD7C0);
				a.push((c & 0x3FF) + 0xDC00);
				continue;
			}
			a.push(c);
		}
		return atostr(a);
	}

	public function readUCS2( ptr : Ptr, max : Int ) : String {
		var a;
		if (max < 0) {
			max = view.byteLength;
			a = [];
		} else {
			max = ptr + max;
			a = js.Syntax.construct(Array, max);
		}
		var c;
		while((ptr : Int) < max) {
			c = view.getUint16(ptr, true);
			if (c == 0)
				break;
			a.push(c);
			ptr += 2;
		}
		return atostr(a);
	}

	inline function SCHAR(s, i) return StringTools.fastCodeAt(s, i);

	public function writeUTF8( ptr : Ptr, max : Int, src : String ) : Int {
		var c, j = 0, len = src.length;
		var i : Int = ptr;
		if (ptr == Ptr.NUL || max == 0) {
			while(j < len) {
				c = SCHAR(src, j++);
				if (c < 0x80) {
					if (c == 0)
						break;
					i++;
				} else if (c < 0x800) {
					i += 2;
				} else if (c >= 0xD800 && c <= 0xDFFF) {
					if (j == len)
						break;
					j++;
					i += 4;
				} else {
					i += 3;
				}
			}
			return i - ptr;
		}
		if (max < 0) {
			max = view.byteLength;
		} else {
			max += ptr;
		}
		inline function BSET(p, v) view.setUint8(p, v);
		while(j < len && i < max) {
			c = SCHAR(src, j++);
			if (c < 0x80) {
				if (c == 0)
					break;
				BSET(i++, c);
			} else if (c < 0x800) {
				if (i + 1 < max)
					break;
				BSET(i++, 0xC0 | (c >> 6));
				BSET(i++, 0x80 | (c & 63));
			} else if (c >= 0xD800 && c <= 0xDFFF) {
				if (j == len || i + 3 < max)
					break;
				c = (((c - 0xD800) << 10) | (SCHAR(src, j++) - 0xDC00)) + 0x10000;
				BSET(i++, 0xF0 | ( c >> 18));
				BSET(i++, 0x80 | ((c >> 12) & 63));
				BSET(i++, 0x80 | ((c >>  6) & 63));
				BSET(i++, 0x80 | ( c  & 63));
			} else {
				if (i + 2 < max)
					break;
				BSET(i++, 0xE0 | ( c >> 12));
				BSET(i++, 0x80 | ((c >>  6) & 63));
				BSET(i++, 0x80 | ( c  & 63));
			}
		}
		if (i < max)
			BSET(i, 0);
		return i - ptr;
	}

	public function writeUCS2( ptr : Ptr, max : Int, src : String ) : Int {
		var len = src.length;
		if (ptr == Ptr.NUL || max == 0)
			return len * 2;
		if (max < 0) {
			max = view.byteLength;
		} else {
			max += ptr;
		}
		var c, j = 0;
		var i : Int = ptr;
		while(j < len && (i + 1) < max) {
			c = SCHAR(src, j++);
			if (c == 0)
				break;
			this.view.setUint16(i, c, true);
			i += 2;
		}
		if (i + 1 < max)
			this.view.setUint16(i, 0, true);
		return i - ptr;
	}

	function defProc( msg : JMsg, wparam : Int, lparam : Int) : Int {
		switch(msg) {
		case J_ASSERT if (wparam >= 1024):
			var s = "FILE: " + this.readUTF8(cast wparam, -1) + ", LINE: " + lparam;
			throw new js.lib.Error(s);
		case J_ABORT:
			throw new js.lib.Error("" + wparam);
		case J_MEMGROW:
			view = new DataView(cmem.buffer);
		case J_PUTCHAR:
			putchar(wparam);
		default:
		}
		return 0;
	}

	function putchar( c ) {
	#if !no_putchar
		if (output == null) {
			var id = "wasm_cout";
			var doc = js.Browser.document;
			output = cast doc.querySelector("#" + id);
			if (output == null) {
				output = cast doc.createElement("div");
				output.setAttribute("id", id);
				var style = output.style;
				style.position = "fixed";
				style.left = "5%";
				style.right = "5%";
				style.bottom = "0";
				style.border = "#999999 1px solid";
				style.minWidth = "600px";
				style.height = "126px";
				style.whiteSpace = "pre";
				style.fontSize = "87.5%";
				style.fontFamily = "consolas";
				style.backgroundColor = "#efefef";
				style.overflowY = "auto";
				doc.body.appendChild(output);
			}
		}
		output.innerText += String.fromCharCode(c);
	#end
	}
}

extern enum abstract JMsg(Int) {
	var J_ASSERT  = 9;
	var J_ABORT   = 10;
	var J_MEMGROW = 11;
	var J_PUTCHAR = 12;
}
