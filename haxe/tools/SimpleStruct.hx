package tools;

#if macro

import haxe.macro.Expr;
import haxe.macro.Type;
import haxe.macro.Context;
using haxe.macro.Tools;

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

	function rewrite( f : Field, ct : ComplexType, enumfollow = false ) {
		if (ct == null)
			ct = macro :Int;
		var ts = enumfollow ? ct.toType().followWithAbstracts().toString() : ct.toType().toString();
		var idx = new IDXMeta(f);
		var getter : Expr = null;
		var setter : Expr = null;
		var opUnit : Int  = 0; // OpU8 = 1, OpU16 = 2, OpI32 = 3, OpF32 = 4, OpF64 = 5
		switch(ts) {
		case "Int":
			if (idx.count > 1) {
				ct = macro :Array<$ct>;
				opUnit = idx.sizeof == 1 ? (1) : (idx.sizeof == 2 ? 2 : 3);
			} else {
				switch (idx.sizeof) {
				case 1:
					getter = macro $fms.vu8[this + $v{offset}];
					setter = macro $fms.vu8[this + $v{offset}] = v;
				case 2:
					getter = macro $fms.view.getUint16(this + $v{offset}, true);
					setter = macro $fms.view.setUint16(this + $v{offset}, v, true);
				default:
					idx.sizeof = 4;
					getter = macro $fms.view.getInt32(this + $v{offset}, true);
					setter = macro $fms.view.setInt32(this + $v{offset}, v, true);
				}
			}
		case "Float":
			if (idx.count > 1) {
				ct = macro :Array<$ct>;
				opUnit = idx.sizeof == 8 ? 5 : 4;
			} else {
				if (idx.sizeof == 8) {
					getter = macro $fms.view.getFloat64(this + $v{offset}, true);
					setter = macro $fms.view.setFloat64(this + $v{offset}, v, true);
				} else {
					idx.sizeof = 4;
					getter = macro $fms.view.getFloat32(this + $v{offset}, true);
					setter = macro $fms.view.setFloat32(this + $v{offset}, v, true);
				}
			}
		case "String":      // UTF8String
			idx.count = idx.sizeof;
			idx.sizeof = 1; // sizeof(char)
			setter = macro $fms.writeUTF8(this + $v{offset}, $v{idx.bytes}, v);
			getter = macro $fms.readUTF8(this + $v{offset}, $v{idx.bytes});
		case "js.wasm.UCS2String":
			ct = macro :String;
			idx.count = idx.sizeof;
			idx.sizeof = 2;
			setter = macro $fms.writeUCS2(this + $v{offset}, $v{idx.bytes}, v);
			getter = macro $fms.readUCS2(this + $v{offset}, $v{idx.bytes});
		default:
			if (!enumfollow)
			return rewrite(f, ct, true);
			fatalError("Type (" + ts +") is not supported for field: " + f.name , f.pos);
		}
		if (opUnit > 0) { // must be int/float array
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
class IDXMeta {
	public var bytes(get, never) : Int;
	public var sizeof : Int;
	public var count : Int;
	public function new( f : Field ) {
		count = 1;
		sizeof = 4;
		for (meta in f.meta) {
			if (meta.name != SimpleStruct.IDMETA)
				continue;
			loop(meta);
			break;
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
#else
class SimpleStruct {}
#end