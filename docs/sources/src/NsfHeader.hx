package;

import js.wasm.Ptr;

class NSF {}

#if !macro
@:build(tools.SimpleStruct.build())
#end
extern abstract NsfHeader(Ptr) to Ptr {
	@size(4)    var sign         : Int; // NESM
	@size(1)    var _tag         : Int; // 0x1A
	@size(1)    var ver          : Int; // byte
	@size(1)    var track_count  : Int;
	@size(1)    var first_track  : Int;
	@size(2)    var _load_addr   : Int;
	@size(2)    var _init_addr   : Int;
	@size(2)    var _play_addr   : Int;
	@size(32)   var game         : String;
	@size(32)   var author       : String;
	@size(32)   var copyright    : String;
	@size(2)    var _ntsc_speed  : Int;
	@size(1, 8) var _banks       : Int;
	@size(2)    var _pal_speed   : Int;
	@size(1)    var _speed_flags : Int;
	@size(1)    var _chip_flags  : Int;
	@size(4)    var _unused      : Int;
}
