package;

import js.html.Request;
import js.html.Response;
import js.html.RequestInit;
import haxe.Constraints.Function;

class Global {

	public static inline var SIGN_NSF  = 'N'.code | 'E'.code << 8 | 'S'.code << 16 | 'M'.code << 24;
	public static inline var SIGN_WASM = 'a'.code << 8 | 's'.code << 16 | 'm'.code << 24;

	public static inline var SAMPLE_RATE = 22050;

	public static inline var FRAME_COUNTLIMIT = 128 * 8;

	public static inline var CHANNEL = 2;

	public static inline var GME_WORKER = "gme-worker";

	public static inline var CSS_NONE = "none";
	public static inline var CSS_BLOCK = "block";
	public static inline var CSS_INLINE_BLOCK = "inline-block";
	public static inline var CSS_EMPTY = "";

	public static inline function int_of_string( s : String ) : Int return (cast s) | 0;
}

@:native("console") extern var console : js.html.ConsoleInstance;
@:native("document") extern var document : js.html.Document;
@:native("window") extern var window : js.html.Window;
@:native("location") extern var location : js.html.Location;
@:native("fetch") extern function fetch( input : Request, ?init : RequestInit ) : Promise<Response>;
