package wasm.format;

/**
 https://github.com/WebAssembly/design/blob/master/BinaryEncoding.md
*/
class WASM {

	/**
	 Magic number 0x6d736100.         (uint32)
	*/
	public var sign(default, null) : Int;

	/**
	 Version number, 0x1.             (uint32)
	*/
	public var version(default, null) : Int;

	/**
	 sequence of sections.
	*/
	public var sections : Array<Section>;

	public function new() {
		sign = SIGN;
		version = 1;
		sections = [];
	}

	public function toString() {
		var str = "";
		for (sec in sections)
			str += sec.toString();
		return str;
	}

	static inline var SIGN = 'a'.code << 8 | 's'.code << 16 | 'm'.code << 24;
}

class Section {
	/**
	 section code,                    (varuint7)
	*/
	public var id      : SId;

	/**
	 size of this section in bytes,   (varuint32)
	*/
	public var bytes   : Int;

	public var content : Content;

	public function new() {
	}

	public function toString() {
		var str = '* $id [$bytes]\n';
		if (content == null)
			return str;
		switch(content) {
		case Types(a):
			for (v in a)
				str += "    " + v.toString() + "\n";
		case Import(a):
			for (v in a)
				str += "    " + v.toString() + "\n";
		case Funcindexes(a, start):
			for (i in 0...a.length)
				str += '    (func (${i + start}) (type ${a[i]}))\n';
		case Memory(a):
			for (i in 0...a.length)
				str += '    (memory ($i) (${a[i]}))\n';
		case Export(a):
			for (v in a)
				str += "    " + v.toString() + "\n";
		default:
		}
		return str;
	}
}

enum Content {
	TODO; // Not yet recognized
	Types(t : Array<FuncDef>);
	Import(i : Array<ImportEntry>);
	Funcindexes(f : Array<Int>, start : Int);
	Memory(m : Array<ReSizable>);
	Export(e : Array<ExportEntry>);
}

enum EntryInfo {
	EIndex(idx : Int);                // varuint32s
	EMemory(limit : ReSizable);
	ETable(type : ElemType, limit : ReSizable);
	EGlobal(type : ValueType, mut : Bool);  // (varint7, varuint1)
}

/**
 #import-section
*/
class ImportEntry {

	public var module : String;       // (len=varuint32, str = bytes)

	public var name : String;         // (len=varuint32, str = bytes)

	public var kind : ExternalKind;   // (single-byte)

	public var info : EntryInfo;      // (depends on what kind of)

	public function new(mod, name, kind, info) {
		this.module = mod;
		this.name = name;
		this.kind = kind;
		this.info = info;
	}

	public function toString() {
		return '(import "$module.$name" ($kind ${s_info(info)})';
	}

	static function s_info( e ) {
		return switch(e) {
		case EIndex(idx):          'type($idx)';
		case EMemory(limit):       "" + limit;
		case ETable(type, limit):  "" + type + " " + limit;
		case EGlobal(type, mut):   "" + type + ", mut: " + mut;
		}
	}
}

/**
 #export-section
*/
class ExportEntry {

	public var name : String;         // (len=varuint32, str = bytes)

	public var kind : ExternalKind;   // (single-byte)

	public var index : Int;           // (varuint32)

	public function new(name, kind, i) {
		this.name = name;
		this.kind = kind;
		this.index = i;
	}

	public function toString() return '(export "$name" ($kind ($index))';
}

/**
 #func_type
*/
class FuncDef {

	public var idx : Int;

	public var form : Int;            // (varint7)

	public var paramCount : Int;      // (varuint32)

	public var paramTypes : Array<ValueType>;

	public var returnCount : Int;     // (varuint1)

	public var returnType : Null<ValueType>;

	public function new(i, fm, pc, pt, rc, rt) {
		idx = i;
		form = fm; // aways 0x60;
		paramCount  = pc;
		paramTypes  = pt;
		returnCount = rc;
		returnType  = rt;
	}

	public function toString() {
		var sparam = paramTypes.map( v -> v.toString() ).join(" ");
		var sret = returnCount > 0 ? returnType.toString() : "void";
		return '(type ($idx) (func ($sparam)) : $sret )';
	}
}

enum abstract SId(Int) {
	var SCustom = 0;
	var SType;
	var SImport;
	var SFunction;
	var STable;
	var SMemory;
	var SGlobal;
	var SExport;
	var SStart;
	var SElem;
	var SCode;
	var SData;
	var SDataCount;

	public function toString() : String {
		return switch(cast this) {
			case SCustom:   "Custom";
			case SType:     "Type";
			case SImport:   "Import";
			case SFunction: "Function";
			case STable:    "Table";
			case SMemory:   "Memory";
			case SGlobal:   "Global";
			case SExport:   "Export";
			case SStart:    "Start";
			case SElem:     "Elem";
			case SCode:     "Code";
			case SData:     "Data";
			case SDataCount:"DataCount";
		}
	}
}

enum abstract ExternalKind(Int) {
	var KFunction = 0;
	var KTable;
	var KMemory;
	var KGlobal;

	public function toString() {
		return switch(cast this) {
			case KFunction:  "func";
			case KTable:     "table";
			case KMemory:    "memory";
			case KGlobal:    "global";
		}
	}
}

/**
 #resizable_limits
*/
class ReSizable {
	public var initial : Int;
	public var maxinum : Int;
	public function new(init , ?max) {
		initial = init;
		maxinum = max == null ? -1 : max;
	}
	public function toString() {
		return 'init: $initial' + (maxinum == -1 ? '' : ', max: $maxinum');
	}
}

enum abstract ValueType(Int) {
	var I32 = 0x7f;
	var I64 = 0x7e;
	var F32 = 0x7d;
	var F64 = 0x7c;
	var V128 = 0x7b;
	var Funcref = 0x70;
	var Externref = 0x6f;

	public function toString() {
		return switch(cast this) {
		case I32: "i32";
		case I64: "i64";
		case F32: "f32";
		case F64: "f64";
		case V128: "v128";
		case Funcref: "funcref";
		case Externref: "externref";
		}
	}
}

enum abstract ElemType(Int) {

	var AnyFunc = 0x70;

	public function toString() return "anyfunc";
}
