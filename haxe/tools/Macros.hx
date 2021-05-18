package tools;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
import haxe.macro.Type;
using haxe.macro.Tools;
#end

class Macros {
#if macro
	static function fatalError(msg, pos) : Dynamic {
		return Context.fatalError("[macro] " + msg, pos);
	}
#end

	/**
	 wrap into function to avoid haxe $bind

	 ```haxe
	 btn.onclick = FUNC(onClick);
	 ```
	 output:
	 ```js
	 var _thiz = this;
	 btn.onclick = function(e){ _thiz.onClick(e);}
	 ```
	*/
	macro public static function FUNC(func) {
		return switch(Context.typeof(func)) {
		case TFun(a, r):
			var args : Array<FunctionArg> = cast a.map( v -> {name: v.name} );
			var params = a.map( v -> macro $i{ v.name });
			var expr = macro return $func($a{ params });
			var def = EFunction(FArrow, { args: args, expr: expr, ret: r.toComplexType() });
			{expr: def, pos: func.pos}
		default:
			fatalError("Expect 'function': " + func.toString(), func.pos);
		}
	}

	/**
	 uses native .bind to instead of haxe $bind

	 ```haxe
	 btn.onclick = BIND(onClick);
	 ```
	 output:
	 ```js
	 btn.onclick = this.onClick.bind(this);
	 ```
	*/
	macro public static function BIND(func) {
		var t1 = Context.typeof(func);
		var t2 = Context.getExpectedType();
		if (!Context.unify(t1, t2))
			fatalError(t1.toString() + " should be " + t2.toString(), func.pos);
		var ctx : Expr;
		var name : String;
		switch(func.expr) {
		case EConst(CIdent(i)):
			name = i;
			ctx = macro this;
		case EField(e, field):
			name = field;
			ctx = e;
		default:
			fatalError("UnSupported: " + func.toString(), func.pos);
		}
		return macro @:pos(func.pos) ($ctx:Dynamic).$name.bind($ctx);
	}
}
