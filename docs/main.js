(function ($global) { "use strict";
class Main {
	constructor() {
		let files = ["gme.wasm","Double Dragon 3.nsf"];
		let _gthis = this;
		let f = fetch;
		let result = new Array(files.length);
		let _g = 0;
		let _g1 = files.length;
		while(_g < _g1) {
			let i = _g++;
			result[i] = f(files[i]);
		}
		Promise.all(result).then(function(ar) {
			let result = new Array(ar.length);
			let _g = 0;
			let _g1 = ar.length;
			while(_g < _g1) {
				let i = _g++;
				result[i] = ar[i].arrayBuffer();
			}
			return Promise.all(result);
		}).then(function(ab) {
			if(new Int32Array(ab[0],0,1)[0] == 1836278016) {
				_gthis.wasm = ab[0];
				_gthis.nsf = ab[1];
			} else {
				_gthis.wasm = ab[1];
				_gthis.nsf = ab[0];
			}
			_gthis.infotab = document.querySelector("#info table");
			_gthis.player = document.querySelector("#player");
			_gthis.btngroup = _gthis.player.children[1];
			_gthis.progress = _gthis.player.children[2];
			_gthis.fileopen = _gthis.player.children[0];
			_gthis.progress.children[0].max = "" + 90000;
			_gthis.progress.children[0].step = "" + 100;
			_gthis.infotab.children[0].innerText = "AudioWorkletNode Initialization...";
			document.querySelector("#page").onclick = function(e) {
				e.stopPropagation();
				_gthis.asynInit();
			};
		});
	}
	toggle() {
		if(this.playing) {
			this.wnode.port.postMessage({ type : 1, value : false});
			this.wnode.disconnect();
			this.btngroup.children[1].innerText = "Play";
			this.btngroup.children[1].classList.remove("running");
			this.playing = false;
		} else {
			this.wnode.port.postMessage({ type : 1, value : true});
			this.wnode.connect(this.audio.destination);
			this.btngroup.children[1].innerText = "Pause";
			this.btngroup.children[1].classList.add("running");
			this.playing = true;
		}
	}
	trackUpdate(offset) {
		this.track += offset;
		if(this.track == this.trackMax) {
			this.track = 0;
		} else if(this.track < 0) {
			this.track = this.trackMax - 1;
		}
		this.infotab.children[1].children[3].children[1].innerText = "" + (this.track + 1) + "/" + this.trackMax;
		this.wnode.port.postMessage({ type : 3, value : this.track});
		if(!this.playing) {
			this.toggle();
		}
	}
	timeString(sec) {
		let s = sec % 60;
		return "0" + (0 | (sec / 60)) + ":" + (s < 10 ? "0" : "") + s;
	}
	onMessage(me) {
		let m = me.data;
		switch(m.type) {
		case 10:
			this.trackTime = m.value;
			if(this.startFadeOut) {
				if(this.trackTime > 90000) {
					this.trackTime = 0;
					this.trackUpdate(1);
					this.startFadeOut = false;
				}
			} else if(this.trackTime >= 85000) {
				this.startFadeOut = true;
				this.wnode.port.postMessage({ type : 5, value : this.trackTime + 1000});
			}
			if(!this.slidePendding) {
				let tmp = (0 | this.trackTime);
				this.progress.children[0].value = "" + tmp;
			}
			let tmp = this.timeString((0 | (this.trackTime / 1000))) + "/";
			let tmp1 = this.timeString(90);
			this.progress.children[1].innerText = tmp + tmp1;
			break;
		case 11:
			if(m.value) {
				this.trackUpdate(1);
			}
			break;
		case 12:
			break;
		case 13:
			let v = m.value;
			if(this.wasm != null) {
				this.wasm = null;
				this.nsf = null;
				this.btngroup.children[1].innerText = "Play";
				this.infotab.children[0].innerText = "Ready!";
			}
			this.track = v.intro;
			this.trackMax = v.count;
			this.infotab.children[1].children[0].children[1].innerText = v.game;
			this.infotab.children[1].children[1].children[1].innerText = v.author;
			this.infotab.children[1].children[2].children[1].innerText = v.copyright;
			this.infotab.children[0].innerText = "";
			this.infotab.children[1].children[3].children[1].innerText = "" + (this.track + 1) + "/" + this.trackMax;
			break;
		}
	}
	evtBinds() {
		document.querySelector("#page").onclick = null;
		this.infotab.children[0].innerText = "WASM Initialization...";
		let _gthis = this;
		this.wnode.port.onmessage = function(me) {
			_gthis.onMessage(me);
		};
		this.btngroup.children[1].onclick = function() {
			_gthis.toggle();
		};
		this.btngroup.children[0].onclick = function() {
			_gthis.trackUpdate(-1);
		};
		this.btngroup.children[2].onclick = function() {
			_gthis.trackUpdate(1);
		};
		this.progress.children[0].onchange = function() {
			let value = (0 | this.value);
			_gthis.wnode.port.postMessage({ type : 4, value : value});
		};
		this.progress.children[0].onmousedown = function() {
			_gthis.slidePendding = true;
		};
		this.progress.children[0].onmouseup = function() {
			_gthis.slidePendding = false;
		};
		this.fileopen.children[1].onclick = function(e) {
			_gthis.fileopen.children[0].click();
		};
		this.fileopen.children[0].onchange = function(e) {
			let file = new FileReader();
			file.onload = function() {
				let ab = this.result;
				_gthis.wnode.port.postMessage({ type : 2, value : ab});
			};
			let files = this.files;
			if(files.length > 0) {
				file.readAsArrayBuffer(files[0]);
			}
		};
	}
	asynInit() {
		if(this.audio != null) {
			return;
		}
		this.audio = new AudioContext({ sampleRate : 44100});
		let _gthis = this;
		this.audio.audioWorklet.addModule("work.js").then(function(a) {
			_gthis.wnode = new AudioWorkletNode(_gthis.audio,"gme-worker",{ outputChannelCount : [2], processorOptions : { wasm : _gthis.wasm, nsf : _gthis.nsf}});
			_gthis.evtBinds();
		});
	}
	static main() {
		if(location.protocol == "file:") {
			return;
		}
		new Main();
	}
}
{
}
Main.main();
})({});
