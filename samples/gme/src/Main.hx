package;

import js.lib.WebAssembly;
import js.lib.ArrayBuffer;
import js.lib.Promise;
import js.html.Response;
import js.Browser.window;
import js.wasm.FMS;
import js.wasm.CStub;
import Gme;

class Main {
	function new() {
		var nsf : ArrayBuffer = null;
		var player = new Player();
		player.volume = 0.25;
		var canvas = window.document.querySelector("canvas");
		canvas.onclick = function() @:privateAccess {
			if (player.audio == null) {
				player.init();
				player.load(nsf);
			}
			player.playing ? player.stop() : player.play();
		}
	#if LOCAL
		wasm.Tools.addResource("bin/gme.wasm@wasm");
		wasm.Tools.addResource("bin/Zelda 2.nsf@zelda");
		trace("embed wasm");
		var buffer = haxe.Resource.getBytes("wasm").getData();
		nsf = haxe.Resource.getBytes("zelda").getData();
		if (!WebAssembly.validate(buffer))
			throw new js.lib.Error("invalid wasm");
		FMS.init(buffer, {}).then(function(moi){
			fms.ongrows.push(player.onGrow);
		});
	#else
		var list = ["gme.wasm", "Zelda 2.nsf"];
		Promise.all(list.map(cast window.fetch)).then(function(ar) {
			return Promise.all(ar.map( r -> r.arrayBuffer() ));
		}).then(function( ab ) {
			var wasm : ArrayBuffer = null;
			var sign = new js.lib.Int32Array(ab[0], 0, 1);
			if (sign[0] == ('a'.code << 8 | 's'.code << 16 | 'm'.code << 24)) {
				wasm = ab[0];
				nsf = ab[1];
			} else {
				wasm = ab[1];
				nsf = ab[0];
			}
			if (!WebAssembly.validate(wasm))
				throw new js.lib.Error("invalid wasm");

			FMS.init(wasm, {}).then(function(moi) {
				fms.ongrows.push(player.onGrow);
			});
		});
	#end
	}

	static function main() {
		//wasm.Tools.getImports( "bin/gme.wasm" );
		new Main();
		// canvas
	}
}
