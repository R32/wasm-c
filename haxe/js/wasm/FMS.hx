package js.wasm;

import js.lib.DataView;
import js.lib.WebAssembly;
import js.lib.ArrayBuffer;
import js.lib.Uint8Array;
import js.lib.webassembly.Memory;
import tools.Macros.BIND;
import tools.Macros.FUNC;

@:native("_FMS")
class FMS {

	public var cmem(default, null) : Memory;

	public var view(default, null) : DataView;

	public var vu8(default, null) : Uint8Array;

	var output : js.html.DivElement;

	function new( imports : Dynamic ) {
		if (imports.env == null)
			imports.env = {};
		var env = imports.env;
		this.cmem = env.memory;
		if (env.jproc == null)
			env.jproc = BIND(this.defProc);
		if (env.now == null)
			env.now = js.lib.Date.now;
	}

	function attach( moi : WebAssemblyInstantiatedSource ) {
		if (js.Syntax.typeof(CStub.fms) != "undefined")
			throw new js.lib.Error("single instance only");
		var inst = moi.instance;
		if (cmem == null)
			cmem = cast inst.exports.memory;
		defProc(J_MEMGROW, 0, 0);
		CStub.select(cast inst.exports, this);
		return moi;
	}

	static public function init( buf : ArrayBuffer, imports : Dynamic ) {
		var fms = new FMS(imports);
		return WebAssembly.instantiate(buf, imports).then(FUNC(fms.attach));
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

	public function readBuffs( src : Ptr, len : Int) : ArrayBuffer {
		return cmem.buffer.slice(src, src + len);
	}

	public function writeBuffs( dst : Ptr, buf : ArrayBuffer, len : Int ) : Void {
		vu8.set(new Uint8Array(buf, 0, len), dst);
	}

	public function readArray( src : Ptr, len : Int, unit : OpUnit ) : Array<Dynamic> {
		var a : Array<Dynamic> = js.Syntax.construct(Array, len);
		var i = 0;
		while(i < len) {
			switch(unit) {
			case OpU8:
				a[i] = vu8[src + i];
			case OpU16:
				a[i] = view.getUint16( src + (i << 1), true);
			case OpI32:
				a[i] = view.getInt32(  src + (i << 2), true);
			case OpF32:
				a[i] = view.getFloat32(src + (i << 2), true);
			case OpF64:
				a[i] = view.getFloat64(src + (i << 3), true);
			}
			i++;
		}
		return a;
	}

	public function writeArray( dst : Ptr, src : Array<Dynamic>, len : Int, unit : OpUnit ) : Void {
		var i = 0;
		while(i < len) {
			switch(unit) {
			case OpU8:
				vu8[dst + i] = src[i];
			case OpU16:
				view.setUint16( dst + (i << 1), src[i], true);
			case OpI32:
				view.setInt32(  dst + (i << 2), src[i], true);
			case OpF32:
				view.setFloat32(dst + (i << 2), src[i], true);
			case OpF64:
				view.setFloat64(dst + (i << 3), src[i], true);
			}
			i++;
		}
	}

	public function defProc( msg : JMsg, wparam : Int, lparam : Int) : Int {
		switch(msg) {
		case J_ASSERT if (wparam >= 1024):
			var s = "FILE: " + this.readUTF8(cast wparam, -1) + ", LINE: " + lparam;
			throw new js.lib.Error(s);
		case J_ABORT:
			throw new js.lib.Error("" + wparam);
		case J_MEMGROW:
			view = new DataView(cmem.buffer);
			vu8 = new Uint8Array(cmem.buffer);
		case J_PUTCHAR:
			putchar(wparam);
		default:
		}
		return 0;
	}

	function putchar( c ) {
	#if !no_traces
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
		// Avoid generating "String.fromCodePoint"
		output.innerText += (js.Syntax.code("String.fromCharCode({0})", c) : String);
	#end
	}
}

extern enum abstract JMsg(Int) {
	var J_ASSERT  = 9;
	var J_ABORT   = 10;
	var J_MEMGROW = 11;
	var J_PUTCHAR = 12;
}

extern enum abstract OpUnit(Int) {
	var OpU8  = 1;
	var OpU16 = 2;
	var OpI32 = 3;
	var OpF32 = 4;
	var OpF64 = 5;
}
