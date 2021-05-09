package;

import js.lib.WebAssembly;
import js.lib.webassembly.Module;
import js.lib.webassembly.Instance;
import js.Browser.console;
import js.Browser.window;
import js.wasm.FMS;
import js.wasm.CStub;

//@:eager
typedef MyExports = wasm.TypedExports<"bin/app.wasm">;

class Main {
	function new() {
		var buffer = haxe.Resource.getBytes("wasm").getData();
		if (!WebAssembly.validate(buffer))
			return;
		var mod = new Module(buffer);
		var fms = new FMS();
		var inst = fms.instance(mod, {
			env : {
				log: function(a, b, c) {
					trace("UTF8: " + CStub.fms.readUTF8(a, -1));
					trace("UCS2: " + CStub.fms.readUCS2(b, -1));
					trace("UCS8: " + CStub.fms.readUTF8(c, -1));
					trace(a, b, c);
				},
				sin: Math.sin,
			}
		});
		var clib : MyExports = cast inst.exports;
		trace(clib.test(16));
	}

	static function main() {
		//wasm.Tools.getImports( "bin/app.wasm" );
		new Main();
	}
}
