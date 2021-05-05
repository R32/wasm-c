package wasm;

import haxe.io.Input;
import wasm.Data;

class Reader {

	var wasm : WASM;

	var src : Input;

	public function new( r : Input ) {
		wasm = new WASM();
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
			println(sec);
			sec.content = switch(sec.id) {
			case SImport:
				readImportTable();
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
				Index( readLEB() );
			case KTable:
				Table(cast readByte(), readReSizable());
			case KMemory:
				Memory(readReSizable());
			case KGlobal:
				Global(cast readByte(), readByte() == 1);
			}
			var entry = new ImportEntry(module, name, kind, info);
			println("  " + entry);
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
			println("  " + entry);
			acc.push(entry);
		}
		return Export(acc);
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
				return -1;
			step += 7;
		}
		return acc;
	}

	inline function println( s : Dynamic ) : Void {
	#if 1
		Sys.println(s);
	#end
	}
}
