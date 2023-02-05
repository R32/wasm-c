package js.wasm;

@:keep @:native("__lib") var lib(default, null) : Dynamic;
@:keep @:native("__fms") var fms(default, null) : FMS;

/**
 This class is only used for macro
*/
extern class CStub {
	public static inline function select( c : Dynamic, f : FMS ) : Void {
		lib = c;
		fms = f;
	}
}
