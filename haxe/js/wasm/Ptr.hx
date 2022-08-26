package js.wasm;

extern abstract Ptr(Int) to Int {

	@:op(A + B) private inline function add( b : Int ) : Ptr
		return cast this + b;

	@:op(A - B) private inline function sub( b : Int ) : Ptr
		return cast this - b;

	public static inline var NUL : Ptr = cast 0;
}

// for tools/simpleStruct
@:coreType
extern abstract UCS2String {}
