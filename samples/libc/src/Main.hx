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
				log : function(a, b, c) {
					trace("UTF8: " + CStub.fms.readUTF8(a, -1));
					trace("UCS2: " + CStub.fms.readUCS2(b, -1));
					trace("UCS8: " + CStub.fms.readUTF8(c, -1));
					trace(a, b, c);
				}
			}
		};
		FMS.init(buffer, imports).then(function(moi) {
			var clib : MyExports = cast moi.instance.exports;
			trace(clib.test(Math.PI / (180 / 60)));
		});
	}

	static function main() {
		//wasm.Tools.getImports( "bin/app.wasm" );
		new Main();
	}
}
