package wasm;

import haxe.io.Input;
import wasm.Data;

class Reader {

	public var wasm : WASM;

	var src : Input;

	public function new() {
		wasm = new WASM();
	}

	public function run( r ) {
		src = r;
		readWASM();
	}

	function readWASM() {
		if (readInt32() != wasm.sign)
			throw "non-wasm file";
		readInt32(); // skip version
		while(true) {
			var sec = new Section();
			sec.id = cast readByte();
			sec.bytes = readLEB();
			sec.content = switch(sec.id) {
			case SType:
				readTypes();
			case SImport:
				readImportTable();
			case SFunction:
				readFuncIndexes();
			case SMemory:
				readMemInfo();
			case SExport:
				readExportTable();
			default:
				readTODO(sec.bytes);
			}
			wasm.sections.push(sec);
		}
	}

	function readImportTable() {
		var count = readLEB();
		var acc = [];
		for (i in 0...count) {
			var module = readString( readLEB() );
			var name = readString( readLEB() );
			var kind : ExternalKind = cast readByte();
			var info = switch(kind) {
			case KFunction:
				EIndex( readLEB() );
			case KTable:
				ETable(cast readByte(), readReSizable());
			case KMemory:
				EMemory(readReSizable());
			case KGlobal:
				EGlobal(cast readByte(), readByte() == 1);
			}
			var entry = new ImportEntry(module, name, kind, info);
			acc.push(entry);
		}
		return Import(acc);
	}

	function readExportTable() {
		var count = readLEB();
		var acc = [];
		for (i in 0...count) {
			var name = readString( readLEB() );
			var kind : ExternalKind = cast readByte();
			var index = readLEB();
			var entry = new ExportEntry(name, kind, index);
			acc.push(entry);
		}
		return Export(acc);
	}

	function readTypes(){
		var count = readLEB();
		var acc = [];
		for (i in 0...count) {
			var form = readByte();
			var paramCount = readLEB();
			var paramTypes : Array<ValueType> = [];
			for (j in 0...paramCount) {
				paramTypes.push( cast readByte() );
			}
			var retCount = readByte();
			var retType : ValueType = null;
			if (retCount > 0)
				retType = cast readByte();
			var funcdef = new FuncDef(i, form, paramCount, paramTypes, retCount, retType);
			acc.push(funcdef);
		}
		return Types(acc);
	}

	function readFuncIndexes() {
		var count = readLEB();
		var acc = [];
		for (i in 0...count) {
			acc.push(readLEB());
		}
		var start = 0;
		for (sec in wasm.sections) {
			switch(sec.content) {
			case Import(a):
				for (x in a) {
					switch(x.kind) {
					case KFunction:
						start++;
					default:
					}
				}
			default:
			}
		}
		return Funcindexes(acc, start);
	}

	function readMemInfo(){
		var count = readLEB();
		var acc = [];
		for (i in 0...count) {
			acc.push( readReSizable() );
		}
		return Memory(acc);
	}

	function readTODO( bytes : Int ) {
		for (i in 0...bytes)
			src.readByte();
		return TODO;
	}

	inline function readByte() return src.readByte();
	inline function readInt32() return src.readInt32();
	inline function readString(w) return src.readString(w, UTF8);

	function readReSizable() : ReSizable {
		var flags = readByte();
		var init = readLEB();
		var max : Null<Int> = null;
		if (flags == 1) {
			max = readByte();
		}
		return new ReSizable(init, max);
	}

	function readLEB() : Int {
		var acc = 0;
		var step = 0;
		while(true) {
			var u8 = readByte();
			acc += (0x7F & u8) << step;
			if (u8 < 0x7F)
				break;
			if (step == (4 * 7))
				throw "readLEB";
			step += 7;
		}
		return acc;
	}
}
