package;

import js.lib.WebAssembly;
import js.lib.webassembly.Module;
import js.lib.webassembly.Instance;
import js.Browser.console;

class Main {
	static function main() {
		var buffer = haxe.Resource.getBytes("wasm").getData();
		if (!WebAssembly.validate(buffer))
			return;
		var mod = new Module(buffer);
		var lib = new Instance(mod, {
			env : {
				log: function(a, b, c) {
					console.log('dataEnd: $a, heapBase: $b, stackSize: $c');
				}
			}
		});
		var clib = lib.exports;
		js.Lib.global.lib = clib;
		trace(clib.square(10));
		trace(clib.test("c".code));
	}
}
