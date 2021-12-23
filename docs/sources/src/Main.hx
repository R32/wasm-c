package;

import js.html.audio.AudioContext;
import js.html.MessageEvent;
import Message;

/**
 https://developer.mozilla.org/en-US/docs/Web/API/BaseAudioContext/audioWorklet
 https://developer.mozilla.org/en-US/docs/Web/API/Worklet/addModule
*/
class Main {
	// tmp varaibles
	var wasm : ArrayBuffer;
	var nsf : ArrayBuffer;
	// ui
	var player   : PlayerUi;
	var infotab  : InfoTableUi;
	var btngroup : BtnGroupUi;
	var progress : ProgressUi;
	var fileopen : FileOpenUi;
	// audio relevant
	var audio : AudioContext;
	var wnode : AudioWorkletNode;
	var playing : Bool;
	var track : Int;
	var trackMax : Int;
	var trackTime : Int;

	function new() {
		var files = ["gme.wasm", "Double Dragon 3.nsf"];
		Promise.all( files.map(cast fetch) ).then(function(ar) {

			return Promise.all( ar.map( r -> r.arrayBuffer()) );

		}).then(function(ab) {
			var sign = new js.lib.Int32Array(ab[0], 0, 1);
			if (sign[0] == SIGN_WASM) {
				wasm = ab[0];
				nsf = ab[1];
			} else {
				wasm = ab[1];
				nsf = ab[0];
			}
			// init ui
			infotab = new InfoTableUi( one("#info table") );
			player = new PlayerUi( one("#player") );
			btngroup = player.btngroup;
			progress = player.progress;
			fileopen = player.fileopen;
			progress.slide.max = "" + (TRACKDURATION * TIMESCALE);
			progress.slide.step = "" + 100;
			text(infotab.desc) = "AudioWorkletNode Initialization...";
			one("#page").onclick = function( e : MouseEvent ) {
				e.stopPropagation();
				asynInit();
			}
		});
	}

	public function toggle() {
		if (playing) {
			postMessage(Attach, false);
			wnode.disconnect();
			text(btngroup.play) = "Play";
			clsl(btngroup.play).remove("running");
			playing = false;
		} else {
			postMessage(Attach, true);
			wnode.connect(audio.destination);
			text(btngroup.play) = "Pause";
			clsl(btngroup.play).add("running");
			playing = true;
		}
	}

	function trackUpdate( offset : Int ) {
		track += offset;
		if (track == trackMax)
			track = 0;
		else if (track < 0)
			track = trackMax - 1;
		trackInfoUpdate();
		postMessage(Play, track);
		if (!playing)
			toggle();
		startFadeOut = false;
	}

	inline function infoUpdate( info : NsfInfo ) {
		track = info.intro;
		trackMax = info.count;
		text(infotab.game) = info.game;
		text(infotab.author) = info.author;
		text(infotab.copyright) = info.copyright;
		text(infotab.desc) = "";
		trackInfoUpdate();
	}

	inline function trackInfoUpdate()
		text(infotab.tracks) = '${track+1}/$trackMax';

	inline function postMessage( type : EAction, value : Dynamic)
		wnode.port.postMessage({type: type, value: value});

	inline function loadNsf( ab : ArrayBuffer) postMessage(Load, ab);

	@:pure function timeString( sec ) {
		var m = Std.int(sec / 60);
		var s = sec % 60;
		return "0" + m + ":" + (s < 10 ? "0" : "") + s;
	}

	var startFadeOut : Bool;
	var slidePendding : Bool;
	function onMessage( me : MessageEvent ) {
		var m : Message<EQuery> = me.data;
		switch(m.type) {
		case Tell:
			var now = trackTime = m.value;
			if (startFadeOut) {
				if (now > (TRACKDURATION * TIMESCALE)){
					trackUpdate(1);
				}
			} else if (now >= ((TRACKDURATION - 6) * TIMESCALE)) {
				startFadeOut = true;
				postMessage(FadeOut, now + (1 * TIMESCALE));
			}
			// update slider
			if (!slidePendding)
				progress.slide.value = "" + Std.int(now);
			text(progress.label) = timeString(Std.int(now / TIMESCALE)) + "/" + timeString(TRACKDURATION);
		case TrackEnded:
			if (m.value)
				trackUpdate(1);
		case Volume:
		case NsfInfo:
			var v : NsfInfo = m.value;
			if (wasm != null) {
				wasm = null; // clear
				nsf = null;
				text(btngroup.play) = "Play";
				text(infotab.desc) = "Ready!";
			}
			infoUpdate(v);
		}
	}

	function evtBinds() {
		one("#page").onclick = null;
		text(infotab.desc) = "WASM Initialization...";
		// message handle
		wnode.port.onmessage = FUNC(onMessage);

		// btn group
		btngroup.play.onclick = FUNC(toggle);
		btngroup.prev.onclick = function() {
			trackUpdate(-1);
		}
		btngroup.next.onclick = function() {
			trackUpdate(1);
		}
		// slider
		progress.slide.onchange = function() { // onchange
			var value = int_of_string(nativeThis.value);
			startFadeOut = false;
			postMessage(Seek, value);
		}
		progress.slide.onmousedown = function() slidePendding = true;
		progress.slide.onmouseup = function() slidePendding = false;

		// file open
		fileopen.button.onclick = function(e) fileopen.filectl.click();
		fileopen.filectl.onchange = function(e) {
			var file = new js.html.FileReader();
			file.onload = function() {
				var ab : ArrayBuffer = nativeThis.result;
				loadNsf(ab);
			}
			var files = nativeThis.files;
			if (files.length > 0)
				file.readAsArrayBuffer(files[0]);
		}
	}

	function asynInit() {
		if (audio != null)
			return;
		audio = new AudioContext({ sampleRate : SAMPLE_RATE });
		(audio:Dynamic).audioWorklet.addModule("work.js").then(function(a) {
			wnode = new AudioWorkletNode(audio, GME_WORKER, {
				outputChannelCount : [CHANNEL],
				processorOptions : {
					wasm : wasm,
					nsf : nsf
				},
			});
			evtBinds();
		});
	}

	static function main() {
		if (location.protocol == "file:")
			return;
		var main = new Main();
	}

	static inline var TIMESCALE = 1000;

	static inline var TRACKDURATION = 90; // sec

	static inline function one( s : String ) return document.querySelector(s);
}



@:build(Nvd.build("../index.html", "#info table", {

	desc       : $("caption"),
	game       : $("td[title=game]"),
	author     : $("td[title=author]"),
	tracks     : $("td[title=tracks]"),
	copyright  : $("td[title=copyright]"),

})) extern abstract InfoTableUi(nvd.Comp) {
}


@:build(Nvd.build("../index.html", "#player .btn-group", {

	prev       : $(".prev"),
	play       : $(".play"),
	next       : $(".next"),

})) extern abstract BtnGroupUi(nvd.Comp) {
}


@:build(Nvd.build("../index.html", "#player .progress-bar", {

	slide      : $("input[type=range]"),
	label      : $("label"),

})) extern abstract ProgressUi(nvd.Comp) {
}

@:build(Nvd.build("../index.html", "#player .file-open", {

	filectl    : $("input[type=file]"),
	button     : $("button"),

})) extern abstract FileOpenUi(nvd.Comp) {
}


@:build(Nvd.build("../index.html", "#player", {

	btngroup  : ($(".btn-group") : BtnGroupUi),
	fileopen  : ($(".file-open") : FileOpenUi),
	progress  : ($(".progress-bar") : ProgressUi),

})) extern abstract PlayerUi(nvd.Comp) {
}
