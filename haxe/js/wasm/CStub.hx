package js.wasm;

import js.lib.webassembly.Memory;

/**
 This class is only used for macro, except the `.select` field
*/
@:native("") extern class CStub {

	@:native("__lib") static var lib(default, never) : CLib;
	@:native("__fms") static var fms(default, never) : FMS;

	public static inline function select( c : CLib, f : FMS ) : Void {
		js.Lib.global.__lib = c;
		js.Lib.global.__fms = f;
	}
}
