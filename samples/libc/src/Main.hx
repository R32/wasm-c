package;

import js.lib.WebAssembly;
import js.lib.webassembly.Module;
import js.lib.webassembly.Instance;
import js.Browser.console;
import js.Browser.window;
import js.wasm.FMS;
import js.wasm.CStub;

//@:eager
typedef MyExports = wasm.TypedExports < "bin/app.wasm" > ;

class Main {
	function new() {
	#if LOCAL
		wasm.Tools.addResource("bin/app.wasm@wasm");
		trace("embed wasm");
		var buffer = haxe.Resource.getBytes("wasm").getData();
		if (!WebAssembly.validate(buffer))
			throw new js.lib.Error("invalid wasm");
		var imports = {};
		FMS.init(buffer, imports).then(function(moi) {
			var clib : MyExports = cast moi.instance.exports;
			var v = clib.test(Math.PI / (180 / 60));
			trace(v);
		});
	#else
		window.fetch("app.wasm")
		.then(function( resp : js.html.Response ) {
			return resp.arrayBuffer();
		}).then(function( buf ) {
			if (!WebAssembly.validate(buf))
				throw new js.lib.Error("invalid wasm");
			var imports = {};
			return FMS.init(buf, imports);
		}).then(function(moi){
			var clib : MyExports = cast moi.instance.exports;
			var v = clib.test(Math.PI / (180 / 60));
			trace(v);
		});
	#end
	}

	static function main() {
		//wasm.Tools.getImports( "bin/app.wasm" );
		new Main();
	}
}
