package;

import js.lib.WebAssembly;
import js.lib.webassembly.Module;
import js.lib.webassembly.Instance;
import js.Browser.console;

class Main {

	static function proc( msg : Int, lparam : Int, wparam : Int ) : Int {
		return 0;
	}

	static function dowasm() {
		var buffer = haxe.Resource.getBytes("wasm").getData();
		if (!WebAssembly.validate(buffer))
			return;
		var mod = new Module(buffer);
		var lib = new Instance(mod, {
			env : {
				log: function(a, b, c) {
					console.log('pchar: $a, pword: $b, heapBase: $c');
				}
			}
		});
		var clib = lib.exports;
		js.Lib.global.lib = clib;
		trace(clib.test());
	}

	static function main() {
		wasm.AutoImports.readWASM( "bin/app.wasm" );
		dowasm();
	}
}
