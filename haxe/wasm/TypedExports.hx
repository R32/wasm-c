package wasm;

#if macro
using haxe.macro.Tools;
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;
import StringTools.hex;
import haxe.crypto.Crc32;
import haxe.io.Bytes;
import wasm.format.Data;
import wasm.Tools;

class TypedExports {

	var wasm : WASM;

	var tmap : Map<String, ComplexType>;

	public function new() {
		tmap = [
			"i32"  => macro :Int,
			"f64"  => macro :Float,
			"void" => macro :Void
		];
	}

	inline function S( v : ValueType ) return v.toString();

	function toFunKind( t : FuncDef ) : ComplexType {
		return TFunction(
			t.paramTypes.map( t->tmap.get( S(t) )),
			tmap.get(t.returnType == null ? "void" : S(t.returnType))
		);
	}

	function getExports(e) : Array<Field> {
		wasm = Tools.getWASM(e);
		var exports = [];
		var ctypes = [];
		var funcs = [];
		var extra = 0;
		for (sec in wasm.sections) {
			if (sec.content == null)
				continue;
			switch(sec.content) {
			case Types(ts):
				ctypes = ts.map(toFunKind);
			case Export(a):
				exports = a;
			case Funcindexes(a, x):
				funcs = a;
				extra = x;
			default:
			}
		}
		var fields = [];
		var ctGlobal = macro :js.lib.wasm.Global;
		var ctMemory = macro :js.lib.webassembly.Memory;
		for (n in exports) {
			var kind = switch(n.kind) {
			case KFunction:
				var idx = funcs[n.index - extra];
				FProp("default", "null", ctypes[idx]);
			case KTable:
				continue; // TODO: no idea
			case KMemory:
				FProp("default", "null", ctMemory);
			case KGlobal:
				FProp("default", "null", ctGlobal);
			}
			fields.push({
				name : n.name,
				kind : kind,
				pos  : e.pos,
			});
		}
		return fields;
	}

	function make() {
		var pos = Context.currentPos();
		var expr = switch(Context.getLocalType()) {
			case TInst(_, [TInst(_.get() => { kind: KExpr(expr) }, _)]):
				expr;
			default:
				Context.error("Class expected", pos);
		}
		var path = expr.getValue();
		var clibs = Context.getType("js.wasm.CLib").getClass().fields.get();
		var reserve = new Map<String,Bool>();
		for (f in clibs) {
			reserve.set(f.name, true);
		}
		var cls = macro class extends js.wasm.CLib {};
		cls.isExtern = true;
		cls.name = "W" + hex(Crc32.make(Bytes.ofString(path)));
		cls.pack = ["_wasm"];
		cls.pos = expr.pos;
		cls.fields = getExports(expr).filter( f -> !reserve.exists(f.name) );
		var fullname = cls.pack[0] + "." + cls.name;
		Context.defineModule(fullname, [cls]);
		Context.registerModuleDependency(fullname, path);
		return Context.getType(fullname).toComplexType();
	}
	public static function build() {
		return new TypedExports().make();
	}
}
#else
@:genericBuild(wasm.TypedExports.build())
extern class TypedExports<Const> {
}
#end

/**
e.g:

```haxe
@:eager typedef MyExports = wasm.TypedExports<"bin/app.wasm">;
```

*/
