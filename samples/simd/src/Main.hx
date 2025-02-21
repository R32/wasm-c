package;

import js.lib.WebAssembly;
import js.wasm.FMS;

typedef MyExports = wasm.TypedExports<"bin/app.wasm">;

class Main {
	static function main() {
		var buffer = haxe.Resource.getBytes("wasm").getData();
		if (!WebAssembly.validate(buffer))
			return;
		FMS.init(buffer, {
			env : {
				trace : (console : Dynamic).log, // prevent haxe $bind
				rand : Std.random,
				frand : Math.random,
				stamp: performance.now,
			}
		}).then(function(inst) {
			var clib = new MyExports(inst);
			clib.test();
		});
	}
}

@:native("window") extern var window : js.html.Window;
@:native("document") extern var document : js.html.Document;
@:native("console") extern var console : js.html.ConsoleInstance;
@:native("performance") extern var performance : js.html.Performance;
