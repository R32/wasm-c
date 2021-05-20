package;

class Macros {

	macro public static function text(elem)
		return macro @:pos(elem.pos) ($elem : DOMElement).innerText;

	macro public static function display(elem)
		return macro @:pos(elem.pos) ($elem : DOMElement).style.display;

	macro public static function clsl(elem)
		return macro @:pos(elem.pos) ($elem : DOMElement).classList;

}
