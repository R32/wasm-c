package;

import js.lib.WebAssembly;
import js.lib.webassembly.Module;
import js.lib.webassembly.Instance;
import js.Browser.console;
import js.Browser.window;
import js.wasm.Ptr;
import js.wasm.FMS;
import js.wasm.CStub;

//@:eager
typedef MyExports = wasm.TypedExports < "bin/app.wasm" > ;

class Main {
	function eq( b, ?pos : haxe.PosInfos ) {
		if (!b)
			throw pos;
	}
	function new() {
		var imports = {
			env : {
				jojotest : function( jojo : Npc ) {
					eq(jojo.x == 8);
					eq(jojo.y == 12);
					eq(jojo.width == 16);
					eq(jojo.height == 20);
					eq(jojo.health == 100);
					eq(jojo.speed == 1.5);
					eq(jojo.power == 2.2);
					eq(jojo.name == "jojo");
					eq(jojo.cname == "乔乔");
					trace("strnpc is done!");
				}
			}
		};
		trace(Npc.POS_HEALTH, Npc.POS_NAME);
	#if LOCAL
		wasm.Tools.addResource("bin/app.wasm@wasm");
		trace("embed wasm");
		var buffer = haxe.Resource.getBytes("wasm").getData();
		if (!WebAssembly.validate(buffer))
			throw new js.lib.Error("invalid wasm");

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

#if !macro
@:build(tools.SimpleStruct.build())
#end
abstract Npc(Ptr) to Ptr {
	@size(1)  var x;
	@size(1)  var y;

	@size(2)  var width;
	@size(2)  var height;

	@size(4)  var health : Int;
	@size(4)  var speed  : Float;
	@size(32) var name   : String;
	@size(32) var cname  : UCS2String;
	@size(8)  var power  : Float;
}
