package;

import js.lib.WebAssembly;
import js.lib.webassembly.Module;
import js.lib.webassembly.Instance;
import js.Browser.console;

//@:eager
typedef MyExports = wasm.TypedExports<"bin/app.wasm">;

class Main {
	function new() {
		var buffer = haxe.Resource.getBytes("wasm").getData();
		if (!WebAssembly.validate(buffer))
			return;
		var mod = new Module(buffer);
		var lib = new Instance(mod, {
			env : {
				log: function(a, b, c) {
					console.log('a: $a, b: $b, c: $c');
				}
			}
		});
		var clib : MyExports = cast lib.exports;
		js.Lib.global.lib = clib;
		trace(clib.test(Math.PI));
	}

	static function main() {
		//wasm.Tools.getImports( "bin/app.wasm" );
		new Main();
	}
}
