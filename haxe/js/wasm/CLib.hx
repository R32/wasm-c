package js.wasm;

import js.wasm.Ptr;

extern class CLib {

	function malloc( size : Int ) : Ptr;

	function calloc( count : Int, elem : Int ) : Ptr;

	function realloc( prev : Ptr, size : Int ) : Ptr;

	function free( ptr : Ptr ) : Void;

	function memcpy( dst : Ptr, src : Ptr, size : Int ) : Ptr;

	function memset( dst : Ptr, val : Int, size : Int ) : Ptr;

	function memcmp( pt1 : Ptr, pt2 : Ptr, size : Int ) : Int;
}
