package js.wasm;

@:keep @:native("__lib") var lib(default, null) : CLib;
@:keep @:native("__fms") var fms(default, null) : FMS;

/**
 This class is only used for macro
*/
extern class CStub {
	public static inline function select( c : CLib, f : FMS ) : Void {
		lib = c;
		fms = f;
	}
}
