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
		var imports = {
			env : {
			}
		};
		FMS.init(buffer, imports).then(function(moi) {
			var clib : MyExports = cast moi.instance.exports;
			var v = clib.test(Math.PI / (180 / 60));
			trace(v);
		});
	}

	static function main() {
		//wasm.Tools.getImports( "bin/app.wasm" );
		new Main();
	}
}
