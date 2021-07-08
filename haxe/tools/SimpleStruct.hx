package tools;

#if macro

import haxe.macro.Expr;
import haxe.macro.Type;
import haxe.macro.Context;
using haxe.macro.Tools;

/**

 This class intends to automatically build a simple struct to interact with c language

 ```c
 // c language
 struct rect {
 	int x, y, width, height;
 }
 ```

 is equal to

 ```haxe
 import js.wasm.Ptr;

 #if !macro
 @:build(tools.SimpleStruct.build())
 #end
 extern abstract Rect(Ptr) to Ptr {
 	@size var x;
 	@size var y;
 	@size var width;
 	@size var height;
 }

 //...
 var rect = new Rect();    // -> malloc(sizeof(struct rect))
 rect.x = 2;
 rect.y = 6;
 trace(rect.x + rect.y);
 rect.free();              // -> free(rect)
 ```

 NOTE: Only uint8, uint16, int32, float(32), double(64), String and UCS2String types are available.

 ```haxe
 import js.wasm.Ptr;

 #if !macro
 @:build(tools.SimpleStruct.build())
 #end
 abstract WhatEver(Ptr) to Ptr {
 	@size(1) var u8_1;                 // unsigned char, the default haxe type is Int.
 	@size(1) var u8_2  : Int;          // unsigned char
 	@size(2) var u16   : Int;          // unsigned short
 	@size    var i32_1 : Int;          // int, the default sizeof is 4
 	@size(4) var i32_2 : Int;          // int

 	@size(4, 32) var a_i32 : Int;      // int[32];             (Array)
 	@size(2, 32) var a_u16 : Int;      // unsigned short[32];  (Array)
 	@size(1, 32) var a_u8  : Int;      // unsigned char[32;    (Array)

 	@size    var f32_1 : Float;        // float
 	@size(4) var f32_2 : Float;        // float
 	@size(8) var f64   : Float;        // double

 	@size(16) var cstr_1 : String;     // char[16];
	@size(16) var ustr_1 : UCS2String; // wchar_t[16];

 	@size(0)  var cstr_2 : String;     // char[0]; flexible array member
 }

 // If you want to know what the macro generates, uses `-D dump=pretty`
 ```
*/
class SimpleStruct {

	public static inline var IDMETA = "size";

	var fms : Expr; // ref to js.wasm.CStub.fms
	var offset : Int;
	var flexible : Bool;
	var fields : Array<Field>;
	var reserves : Map<String,Bool>;

	public function new() {
		fms = macro js.wasm.CStub.fms;
		offset = 0;
		flexible = false;
		reserves = new Map();
		fields = Context.getBuildFields();
	}

	public function make( cname : String ) {
		var cls : ClassType = Context.getLocalClass().get();
		switch (cls.kind) {
		case KAbstractImpl(_.get() => t) if (t.type.follow().toString() == cname):
		default:
			fatalError("UnSupported Type", cls.pos);
		}

		// Retrieves all IDMETA fields
		var fds = fields.filter(function(f){
			reserves.set(f.name, true);
			switch(f.kind) {
			case FVar(_, _) if (f.meta != null):
				for (meta in f.meta) {
					if (meta.name == IDMETA)
						return true;
				}
			default:
			}
			return false;
		});
		// loop
		for (f in fds) {
			switch(f.kind) {
			case FVar(ct, _):
				rewrite(f, ct);
			default:
			}
		}
		if (offset == 0)
			return null;
		fields.push({
			name : "CAPACITY",
			access: [AStatic, AInline, APublic],
			kind: FVar(macro :Int, macro $v{offset}),
			pos: cls.pos
		});
		if (!reserves.exists("_new")) {
			fields.push({
				name : "new",
				access: [AInline, APublic],
				kind: flexible ? FFun({
					args: [{name: "extra", type: macro :Int}],
					ret : null,
					expr: macro this = js.wasm.CStub.lib.malloc(CAPACITY + extra)
				}) : FFun({
					args: [],
					ret : null,
					expr: macro this = js.wasm.CStub.lib.malloc(CAPACITY)
				}),
				pos: cls.pos
			});
		}
		if (!reserves.exists("free")) {
			fields.push({
				name : "free",
				access: [AInline, APublic],
				kind: FFun({
					args: [],
					ret : macro :Void,
					expr: macro js.wasm.CStub.lib.free(this)
				}),
				pos: cls.pos
			});
		}
		return fields;
	}

	// make sure "size" is pow of 2.
	function offsetAlign( size : Int ) {
		if ((offset & (size - 1)) == 0)
			return;
		offset = ((offset - 1) | (size - 1)) + 1;
	}

	function rewrite( f : Field, ct : ComplexType, enumfollow = false ) {
		if (ct == null)
			ct = macro :Int;
		var ts = enumfollow ? ct.toType().followWithAbstracts().toString() : ct.toType().toString();
		var getter : Expr = null;
		var setter : Expr = null;
		var opUnit : OpUnit  = OpNul;
		var idx = new IDXMeta(f, ts);
		offsetAlign(idx.sizeof);
		switch(ts) {
		case "Int":
			if (idx.count > 1) {
				ct = macro :Array<$ct>;
				opUnit = OpUnit.int(idx.sizeof);
			} else {
				switch (idx.sizeof) {
				case 1:
					getter = macro $fms.vu8[this + $v{offset}];
					setter = macro $fms.vu8[this + $v{offset}] = v;
				case 2:
					getter = macro $fms.view.getUint16(this + $v{offset}, true);
					setter = macro $fms.view.setUint16(this + $v{offset}, v, true);
				default:
					getter = macro $fms.view.getInt32(this + $v{offset}, true);
					setter = macro $fms.view.setInt32(this + $v{offset}, v, true);
				}
			}
		case "Float":
			if (idx.count > 1) {
				ct = macro :Array<$ct>;
				opUnit = OpUnit.float(idx.sizeof);
			} else {
				if (idx.sizeof == 8) {
					getter = macro $fms.view.getFloat64(this + $v{offset}, true);
					setter = macro $fms.view.setFloat64(this + $v{offset}, v, true);
				} else {
					getter = macro $fms.view.getFloat32(this + $v{offset}, true);
					setter = macro $fms.view.setFloat32(this + $v{offset}, v, true);
				}
			}
		case "String":      // UTF8String
			setter = macro $fms.writeUTF8(this + $v{offset}, $v{idx.bytes}, v);
			getter = macro $fms.readUTF8(this + $v{offset}, $v{idx.bytes});
		case "js.wasm.UCS2String":
			ct = macro :String;
			setter = macro $fms.writeUCS2(this + $v{offset}, $v{idx.bytes}, v);
			getter = macro $fms.readUCS2(this + $v{offset}, $v{idx.bytes});
		default:
			if (!enumfollow)
				return rewrite(f, ct, true);
			fatalError("Type (" + ts +") is not supported for field: " + f.name , f.pos);
		}
		if (opUnit != OpNul) { // int/float array
			getter = macro cast $fms.readArray(this + $v{offset}, $v{ idx.count }, cast $v{opUnit});
			setter = macro $fms.writeArray(this + $v{offset}, v,  $v{ idx.count }, cast $v{opUnit});
		}
		if (flexible)
			fatalError("flexible array member is not at the end of the struct: " + f.name , f.pos);
		if (idx.count <= 0)
			flexible = true;

		fields.push({
			name : "POS_" + f.name.toUpperCase(),
			access: [AStatic, AInline, APublic],
			kind: FVar(macro :Int, macro $v{offset}),
			pos: f.pos
		});
		offset += idx.bytes;

		if (getter == null) {
			fields.remove(f);
			return;
		}
		if (enumfollow)
			getter = macro cast $getter;

		// overwrite
		var setname = "set_" + f.name;
		var setprop = setter == null && !reserves.exists(setname) ? "never" : "set";
		f.kind = FProp("get", setprop, ct, null);
		if (f.access.length == 0) {
			f.access = f.name.charCodeAt(0) == "_".code ? [APrivate] : [APublic];
		}
		var getname = "get_" + f.name;
		if (!reserves.exists(getname)) {
			fields.push({
				name : getname,
				access: [AInline, APrivate],
				kind: FFun({
					args: [],
					ret : ct,
					expr: macro @:pos(f.pos) {
						return $getter;
					}
				}),
				pos: f.pos
			});
		}
		if (!reserves.exists(setname)) {
			fields.push({
				name: setname,
				access: [AInline, APrivate],
				kind: FFun({
					args: [{name: "v", type: ct}],
					ret : ct,
					expr: macro @:pos(f.pos) {
						$setter;
						return v;
					}
				}),
				pos: f.pos
			});
		}
	}

	static public function build() return new SimpleStruct().make("js.wasm.Ptr");

	static function fatalError(msg, pos) return Context.fatalError("[struct]: " + msg, pos);
}
private class IDXMeta {
	public var bytes(get, never) : Int;
	public var sizeof : Int;
	public var count : Int;
	public function new( f : Field, ts : String ) {
		count = 1;
		sizeof = 0; // init to 0 for String/UCS2String
		for (meta in f.meta) {
			if (meta.name != SimpleStruct.IDMETA)
				continue;
			loop(meta);
			break;
		}
		normalize(ts);
	}
	function normalize( ts : String ) {
		switch(ts){
		case "Int":
			switch(sizeof) {
			case 1, 2, 4:
			default:
				sizeof = 4;
			}
		case "Float":
			switch(sizeof) {
			case 4, 8:
			default:
				sizeof = 4;
			}
		case "String":
			count = sizeof;
			sizeof = 1;
		case "js.wasm.UCS2String":
			count = sizeof;
			sizeof = 2;
		default:
			sizeof = 1;
		}
	}
	function loop( entry : MetadataEntry ) {
		for (i in 0...entry.params.length) {
			var item = entry.params[i];
			switch(item.expr) {
			case EConst(CInt(s)):
				var n = Std.parseInt(s);
				switch(i) {
				case 0:
					sizeof = n;
				case 1:
					count = n;
				default:
				}
			default:
			}
		}
	}
	inline function get_bytes() return sizeof * count;
}

// Same as FMS::OpUnit
private enum abstract OpUnit(Int) to Int {
	var OpNul = 0;
	var OpU8  = 1;
	var OpU16 = 2;
	var OpI32 = 3;
	var OpF32 = 4;
	var OpF64 = 5;

	public static inline function int( size : Int ) : OpUnit
		return size == 4 ? OpI32 : size == 1 ? OpU8 : OpU16;

	public static inline function float( size : Int ) : OpUnit
		return size == 4 ? OpF32 : OpF64;
}

#else
class SimpleStruct {}
#end