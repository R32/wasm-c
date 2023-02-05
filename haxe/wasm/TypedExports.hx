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
	#if print_wasm
		Sys.print(wasm.toString());
	#end
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
				FProp("default", "never", ctypes[idx]);
			case KTable:
				continue; // TODO: no idea
			case KMemory:
				FProp("default", "never", ctMemory);
			case KGlobal:
				FProp("default", "never", ctGlobal);
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
		var url = expr.getValue();
		var hxclibs = Context.getType("js.wasm.CLib").getClass().fields.get();
		var predefs = new Map<String, ClassField>();
		for (f in hxclibs) {
			predefs.set(f.name, f);
		}
		var wasmfs = getExports(expr);
		var fields = [];
		for (f in wasmfs) {
			var cf = predefs.get(f.name);
			if (cf == null) {
				fields.push( f );
			} else {
				fields.push( toField(cf) );
			}
		}
		var path = new haxe.io.Path(url);
		var cdef = {
			isExtern : true,
			pack : ["_wasm"],
			meta : [{name : ":forward", pos : pos}],
			name : "W" + path.file,
			kind : TDAbstract(TAnonymous(fields)),
			pos  : pos,
			fields : [{
				name : "new",
				access : [AInline, APublic],
				kind : FFun({
					args : [{name : "inst", type : macro :js.lib.WebAssembly.WebAssemblyInstantiatedSource}],
					expr : macro this = cast inst.instance.exports,
				}),
				pos : pos,
			}],
		};
		var fullname = cdef.pack.join(".") + "." + cdef.name;
		Context.defineModule(fullname, [cdef]);
		Context.registerModuleDependency(fullname, url);
		return Context.getType(fullname).toComplexType();
	}

	function toField( cf : ClassField ) : Field {
		return {
			name : cf.name,
			kind: FProp("default", "null", cf.type.toComplexType()),
			pos: cf.pos
		}
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
typedef MyExports = wasm.TypedExports<"bin/app.wasm">;

var clib = new MyExports(inst); // inst is js.lib.WebAssembly.WebAssemblyInstantiatedSource
```
*/
