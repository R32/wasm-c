package;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
using haxe.macro.Tools;
#end

class Macros {
#if macro
	static function fatalError(msg, pos) : Dynamic {
		return Context.fatalError("[macro] " + msg, pos);
	}
#end
	macro public static function text(elem)
		return macro @:pos(elem.pos) ($elem : DOMElement).innerText;

	macro public static function display(elem)
		return macro @:pos(elem.pos) ($elem : DOMElement).style.display;

	macro public static function clsl(elem)
		return macro @:pos(elem.pos) ($elem : DOMElement).classList;

}
