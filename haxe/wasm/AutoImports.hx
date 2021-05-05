package wasm;

#if macro
using haxe.macro.Tools;
import haxe.macro.Expr;
import haxe.macro.Context;
import wasm.Reader;
import wasm.Data;
#end

/*
 1. Reads import/export table from binary wasm file

 2. Picks the corresponding field to initialize WebAssembly.Instance

 **WIP**
*/
class AutoImports {
	macro static public function readWASM( e : ExprOf<String> ) {
		var path : String = e.getValue();
		var file = sys.io.File.read(path);
		var reader = null;
		try {
			reader = new Reader(file);
		} catch ( s : String ) {
			Context.fatalError(s, e.pos);
		} catch( eof : haxe.io.Eof ) {
		}
		file.close();
		return macro {};
	}
}
