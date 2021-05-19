package;

import js.html.audio.AudioWorkletNodeOptions;
import js.html.audio.AudioContext;
import js.html.audio.AudioParam;
import js.html.audio.AudioNode;
import js.html.ErrorEvent;

// haxe doesn't have this extern file
extern class AudioWorkletNode extends AudioNode {

	var port(default, null) : js.html.MessagePort;

	var parameters(default, null) : js.lib.Map<String, AudioParam>;

	var onprocessorerror : ErrorEvent->Void;

	function new( ctx : AudioContext, name : String, ?options : AudioWorkletNodeOptions );
}
