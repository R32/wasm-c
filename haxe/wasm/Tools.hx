package wasm;

#if macro
using haxe.macro.Tools;
import haxe.macro.Expr;
import haxe.macro.Context;
import wasm.Reader;
import wasm.Data;
#end

class Tools {
#if macro
	@:persistent static var cached = new Map<String, WASM>();

	public static function getWASM( e : ExprOf<String> ) {
		var path = e.getValue();
		var wasm = cached.get(path);
		if (wasm != null) {
			return wasm;
		}
		var reader = new Reader();
		var err : Any = null;
		var file = sys.io.File.read(path);
		try {
			reader.run(file);
		} catch( eof : haxe.io.Eof ) {
		} catch ( x ) {
			err = x;
		}
		file.close();
		if (err != null)
			Context.fatalError(err, e.pos);
		cached.set(path, reader.wasm);
		return reader.wasm;
	}
#end
	/*
	 1. Reads the import table from binary wasm file

	 2. Picks the corresponding field to initialize WebAssembly.Instance

	 **WIP**
	*/
	macro static public function getImports( e : ExprOf<String> ) {
		var wasm = getWASM(e);
		Sys.println(wasm.toString());
		return macro {}
	}
}
