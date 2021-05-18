package;

import js.Browser.document;
import js.html.DOMElement;
import js.html.MouseEvent;
import js.html.KeyboardEvent in K;
import js.html.CanvasElement;
import js.html.CanvasRenderingContext2D;
import js.html.audio.AudioContext;
import js.html.audio.ScriptProcessorNode;
import js.lib.ArrayBuffer;
import js.lib.Int16Array;
import js.wasm.CStub;
import js.wasm.FMS;
import js.wasm.Ptr;

class Player {

	static inline var SAMPLE_RATE = 44100;

	/**
	* 0 ~ 1.0
	*/
	public var volume(default, set) : Float;

	var audio : AudioContext;
	var procs : ScriptProcessorNode;
	var shout : Ptr;
	var tai16 : Int16Array;
	var g2d : CanvasRenderingContext2D;
	var gme : Gme;
	var playing : Bool;
	var track : Int;
	var trackMax = 0;
	var vol : Float;

	function set_volume( v ) {
		volume = v;
		vol = 1 / 32768. * v;
		return v;
	}

	public function new() {
		var canvas : CanvasElement = cast document.querySelector("canvas");
		if (canvas == null) {
			canvas = cast document.createElement("canvas");
			canvas.setAttribute("height", "" + STAGE_HEIGHT);
			canvas.setAttribute("width", "" + STAGE_WIDTH);
			document.body.append(canvas);
		}
		g2d = canvas.getContext2d();
		showIntro();
		playing = false;
		shout = Ptr.NUL;
		volume = 1.0;
	}

	public function load( nsf : js.lib.ArrayBuffer ) {
		var ptr = lib.malloc(nsf.byteLength);
		fms.writeBuffs(ptr, nsf, nsf.byteLength);
		gme.load(ptr, nsf.byteLength);
		lib.free(ptr);
		//
		trackMax = gme.tracks();
		track = 0;
		var err = gme.start(track);
		if (err.failed())
			throw new js.lib.Error(err.toString());
	}

	function showIntro() {
		var msg = "click to run";
		g2d.font = "16px consolas";
		g2d.fillStyle = "#ffffff";
		var width = Std.int(g2d.measureText(msg).width);
		g2d.fillText(msg, (STAGE_WIDTH - width) >> 1, ((STAGE_HEIGHT - 16) >> 1));
	}

	function init() {
		if (lib == null)
			throw new js.lib.Error("todo");
		if (audio != null)
			return;
		audio = new AudioContext({ sampleRate: SAMPLE_RATE });
		procs = audio.createScriptProcessor(SAMPLECOUNT);
		procs.onaudioprocess = onProcess;
		shout = lib.malloc(SAMPLECOUNT * (2 * 2)); // sizeof(short) * channels
		tai16 = new Int16Array(fms.cmem.buffer, shout, SAMPLECOUNT * 2);  // c * (2 * 2) / 2
		gme = new Gme(SAMPLE_RATE);
		gme.stereo(1.0); // no effect??
		document.onkeydown = onKeyDown;
	}

	function infoUpdate() {
		g2d.clearRect(0, 0, STAGE_WIDTH, STAGE_HEIGHT);
		var s = "track: " + track + (playing ? "" : " is stoped");
		var w = Std.int(g2d.measureText(s).width);
		g2d.fillText(s, STAGE_WIDTH - w >> 1, STAGE_HEIGHT- 16 >> 1);
	}

	function play() {
		if (!playing) {
			procs.connect(audio.destination);
			playing = true;
			infoUpdate();
		}
	}

	function stop() {
		if (playing) {
			procs.disconnect();
			playing = false;
			infoUpdate();
		}
	}

	function onKeyDown( e : K ) {
		var code = e.keyCode;
		switch(code) {
		case K.DOM_VK_UP, K.DOM_VK_LEFT:
			track--;
			if (track < 0)
				track = trackMax - 1;
		case K.DOM_VK_DOWN, K.DOM_VK_RIGHT:
			track++;
			if (track == trackMax)
				track = 0;
		default:
			return;
		}
		gme.start(track);
		infoUpdate();
	}

	function onProcess( e : js.html.audio.AudioProcessingEvent ) {
		var dst = e.outputBuffer;
		gme.play(SAMPLECOUNT * dst.numberOfChannels, shout);
		var i = 0;
		var j = 0;
		var src = tai16;
		var ch0 = dst.getChannelData(0);
		var ch1 = dst.getChannelData(1);
		var v = vol;
		while (i < SAMPLECOUNT) {
			ch0[i] = src[j++] * v;
			ch1[i] = src[j++] * v;
			i++;
		}
	}

	public function onCCall( msg : JMsg, w : Int, l : Int ) : Int {
		if (msg == J_MEMGROW && shout != Ptr.NUL)
			tai16 = new Int16Array(fms.cmem.buffer, shout, SAMPLECOUNT * 2);  // count * ((2 * 2) / 2)
		return fms.defProc(msg, w, l);
	}

	public static inline var SAMPLECOUNT  = 4096;
	public static inline var SAMPLERATE   = 44100;
	public static inline var STAGE_WIDTH  = 600;
	public static inline var STAGE_HEIGHT = 400;
}
