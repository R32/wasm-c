package wasm;

#if macro
using haxe.macro.Tools;
import haxe.macro.Expr;
import haxe.macro.Context;
import wasm.format.Reader;
import wasm.format.Data;
#end

class Tools {
#if macro
	@:persistent static var cached = new Map<String, {time : Float, wasm : WASM}>();

	public static function getWASM( e : ExprOf<String> ) {
		var path = e.getValue();
		var cache = cached.get(path);
		var mtime = sys.FileSystem.stat(path).mtime.getTime(); // milliseconds
		if (cache != null && mtime - cache.time < 1.)
			return cache.wasm;

		var reader = new Reader();
		var err : Any = null;
		var file = sys.io.File.read(path);
		try {
			reader.run(file);
		} catch (eof : haxe.io.Eof) {
		} catch (x) {
			err = x;
		}
		file.close();
		if (err != null)
			Context.fatalError(err, e.pos);
		cached.set(path, {time: mtime, wasm: reader.wasm});
		return reader.wasm;
	}
#end
}
