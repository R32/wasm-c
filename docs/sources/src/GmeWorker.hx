package;

import js.html.audio.AudioWorkletProcessor;
import js.html.MessageEvent;
import js.lib.Float32Array;
import js.lib.Int16Array;
import js.wasm.FMS;
import js.wasm.Ptr;
import js.wasm.CStub;
import NsfHeader;
import Message;

class GmeWorker extends AudioWorkletProcessor {

	var gme : Gme;
	var ptr16 : Ptr;
	var abi16 : Int16Array;
	var connecting : Bool;
	var volume(default, set) : Float;
	var vol : Float;
	var nsfptr : Ptr;

	function new(opt) {
		super(opt);
		volume = 1.0;
		tellTime = endedTime = 0.;
		port.onmessage = FUNC(onMessage);
		FMS.init(opt.processorOptions.wasm, {}).then(function(moi) {
			ptr16 = lib.malloc(FRAME_COUNT * CHANNEL * 2);
			gme = new Gme(cast sampleRate);
			gme.stereo(1.0);
			nsfptr = lib.malloc(128 * 1024);
			loadNsf(opt.processorOptions.nsf);
		});
	}

	inline function postMessage( type : EQuery, value : Dynamic )
		port.postMessage({type: type, value: value});

	function loadNsf( nsf : ArrayBuffer ) {
		nsfptr = lib.realloc(nsfptr, nsf.byteLength); // for reduces memory fragments
		var ptr = nsfptr;
		fms.writeBuffs(ptr, nsf, nsf.byteLength);
		var hnsf : NsfHeader = cast ptr; // powered by haxe macro;
		if (hnsf.sign != SIGN_NSF) {
			lib.free(ptr);
			throw new js.lib.Error("Invalid NSF File.");
		}
		var intro = hnsf.first_track - 1;
		gme.load(ptr, nsf.byteLength);
		var err = gme.start(intro);
		if (err.failed())
			throw new js.lib.Error(err.toString());
		postMessage(NsfInfo, {
			intro : intro,
			count : hnsf.track_count,
			game  : hnsf.game,
			copyright : hnsf.copyright,
			author : hnsf.author,
		});
		abi16 = new Int16Array(fms.cmem.buffer, ptr16, FRAME_COUNT * CHANNEL);
	}

	function onMessage( me : MessageEvent ) {
		var m : Message<EAction> = me.data;
		switch( m.type ) {
		case Attach:
			connecting = m.value;
		case Load:
			loadNsf(m.value);
		case Play:
			gme.start(m.value);
		case Seek:
			gme.seek(m.value);
		case FadeOut:
			gme.fadeout(m.value);
		case Volume:
			volume = m.value;
		case Query:
			var q : EQuery = m.value;
			var v : Dynamic = switch(q) {
			case Tell:       gme.tell();
			case TrackEnded: gme.isEnded();
			case Volume:     volume;
			case NsfInfo:
				return; // nsf has been released
			}
			postMessage(q, v);
		}
	}

	var tellTime : Float;
	var endedTime : Float;
	@:keep function process( input , output : Array<Array<Float32Array>>, params : Dynamic ) {
		if (!connecting)
			return true;
		var now = currentTime;
		if (now - tellTime > 0.5) { // sec
			postMessage(Tell, gme.tell());
			tellTime = now;
		}
		if (now - endedTime > 8.) {
			postMessage(TrackEnded, gme.isEnded());
			endedTime = now;
		}
		var outL = output[0][0];
		var outR = output[0][1];
		gme.play(FRAME_COUNT * CHANNEL, ptr16);
		var src = abi16;
		var i = 0, j = 0;
		var v = vol;
		while(i < FRAME_COUNT) {
			outL[i] = src[j++] * v;
			outR[i] = src[j++] * v;
			i++;
		}
		return true;
	}

	function set_volume(v) {
		volume = v;
		vol = 1 / 32768 * v;
		return v;
	}

	static function main() {
		registerProcessor(GME_WORKER, GmeWorker);
	}
}

// copy from js.html.audio.AudioWorkletGlobalScope
@:native("registerProcessor") extern function registerProcessor( name : String, cls : Dynamic ) : Void;
@:native("sampleRate") extern var sampleRate(default, never) : Float;
@:native("currentTime") extern var currentTime(default, never) : Float;
@:native("currentFrame") extern var currentFrame(default, never) : Int;
