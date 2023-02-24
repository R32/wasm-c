package js.wasm;

import js.wasm.Ptr;

extern class CLib {

	function malloc( size : Int ) : Ptr;

	function calloc( count : Int, elem : Int ) : Ptr;

	function realloc( prev : Ptr, size : Int ) : Ptr;

	function free( ptr : Ptr ) : Void;
}
