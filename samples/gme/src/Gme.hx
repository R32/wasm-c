package;

import js.wasm.Ptr;
import js.wasm.CStub;

/**
 gme.h
*/
@:native("__lib")
extern private class CGme {

	/**
	 Create new *NSF* emulator and set sample rate. Returns NULL if out of memory.
	*/
	static function nsf_new( sample_rate : Int ) : Gme;

	/**
	 Load music file from memory into emulator. Makes a copy of data passed.
	*/
	static function gme_load_data( gme : Gme, data : Ptr, len : Int ) : Void;

	// Basic operations
	/**
	 Number of tracks available
	*/
	static function gme_track_count( gme : Gme ) : Int;

	/**
	 Start a track, where 0 is the first track
	*/
	static function gme_start_track( gme : Gme, index : Int ) : GmeError;

	/**
	 Generate 'count' 16-bit signed samples info 'out'. output is in stereo.
	*/
	static function gme_play( gme : Gme, count : Int, out : Ptr ) : GmeError;

	/**
	 Finish using emulator and free memory
	*/
	static function gme_delete( gme : Gme ) : Void;

	// Track position/length
	/**
	 Set time to start fading track out. Once fade ends track_ended() returns true.
	 Fade time can be changed while track is playing
	*/
	static function gme_set_fade( gme : Gme, msec : Int ) : Void;

	/**
	  True if a track has reached its end
	*/
	static function gme_track_ended( gme : Gme ) : Int;

	/**
	 Number of milliseconds (1000 = one second) played since beginning of track
	*/
	static function gme_tell( gme : Gme ) : Int;

	/**
	 Seek to new time in track. Seeking backwards or far forward can take a while.
	*/
	static function gme_seek( gme : Gme, msec : Int ) : GmeError;

	// Advanced playback
	/**
	 Adjust stereo echo depth, where 0.0 = off and 1.0 = maximum
	*/
	static function gme_set_stereo_depth( gme : Gme, stereo : Float ) : Void;

	/**
	 Adjust song tempo, where 1.0 = normal, 0.5 = half speed, 2.0 = double speed
	*/
	static function gme_set_tempo( gme : Gme, tempo : Float ) : Void;
}


extern abstract GmeError(Ptr) to Ptr {
	inline function success() : Bool return this == Ptr.NUL;
	inline function failed() : Bool return this != Ptr.NUL;
	inline function toString() : String return fms.readUTF8(this, -1);
}

extern abstract Gme(Ptr) to Ptr {

	inline function new( rate : Int ) {
		this = cast CGme.nsf_new(rate);
	}

	inline function load( data : Ptr, len : Int ) : Void {
		CGme.gme_load_data(self, data, len);
	}

	inline function start( i : Int ) : GmeError {
		return CGme.gme_start_track(self, i);
	}

	inline function play( count : Int, out : Ptr ) : GmeError {
		return CGme.gme_play(self, count, out);
	}

	inline function tracks() : Int return CGme.gme_track_count(self);

	inline function tell() : Int return CGme.gme_tell(self);

	inline function seek( msec : Int) : GmeError return CGme.gme_seek(self, msec);

	inline function fadeout( msec : Int) : Void CGme.gme_set_fade(self, msec);

	inline function isEnded() : Bool return CGme.gme_track_ended(self) == 1;

	inline function tempo( t : Float ) : Void CGme.gme_set_tempo(self, t);

	inline function stereo( d : Float ) : Void CGme.gme_set_stereo_depth(self, d);

	inline function destory() : Void CGme.gme_delete(self);

	var self(get, never) : Gme;
	private inline function get_self() : Gme return cast this;
}

/*
extern enum abstract GmeType(Int) {
	var AY   = 0;
	var GBS  = 1;
	var GYM  = 2;
	var HES  = 3;
	var KSS  = 4;
	var NSF  = 5;
	var NSFE = 6;
	var SAP  = 7;
	var SPC  = 8;
	var VGM  = 9;
	var VGZ  = 10;
}
*/