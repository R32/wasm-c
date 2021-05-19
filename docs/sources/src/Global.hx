package;

import js.html.Request;
import js.html.Response;
import js.html.RequestInit;
import haxe.Constraints.Function;

class Global {

	public static inline var SAMPLE_RATE = 44100;

	public static inline var FRAME_COUNT = 128;

	public static inline var CHANNEL = 2;

	public static inline var GME_WORKER = "gme-worker";

	public static inline var CSS_NONE = "none";
	public static inline var CSS_BLOCK = "block";
	public static inline var CSS_INLINE_BLOCK = "inline-block";
	public static inline var CSS_EMPTY = "";

	public static inline function strint( s : String ) : Int return js.Syntax.code("(0 | {0})", s);
	public static inline function numint( n : Float ) : Int return js.Syntax.code("(0 | {0})", n);
}

@:native("console") extern var console : js.html.ConsoleInstance;
@:native("document") extern var document : js.html.Document;
@:native("window") extern var window : js.html.Window;
@:native("location") extern var location : js.html.Location;
@:native("fetch") extern function fetch( input : Request, ?init : RequestInit ) : Promise<Response>;
