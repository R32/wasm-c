(function ($global) { "use strict";
class GmeWorker extends AudioWorkletProcessor {
	constructor(opt) {
		super(opt);
		this.set_volume(1.0);
		this.tellTime = this.endedTime = 0.;
		let _gthis = this;
		this.port.onmessage = function(me) {
			_gthis.onMessage(me);
		};
		_$FMS.init(opt.processorOptions.wasm,{ }).then(function(moi) {
			_gthis.ptr16 = __lib.malloc(512);
			_gthis.abi16 = new Int16Array(__fms.cmem.buffer,_gthis.ptr16,256);
			let this1 = __lib.nsf_new(44100);
			_gthis.gme = this1;
			__lib.gme_set_stereo_depth(_gthis.gme,1.0);
			_gthis.loadNsf(opt.processorOptions.nsf);
		});
	}
	loadNsf(nsf) {
		let ptr = __lib.malloc(nsf.byteLength);
		__fms.writeBuffs(ptr,nsf,nsf.byteLength);
		let hnsf = ptr;
		if(__fms.view.getInt32(hnsf,true) != 1297302862) {
			__lib.free(ptr);
			throw new Error("Invalid NSF File.");
		}
		let intro = __fms.vu8[hnsf + 7] - 1;
		__lib.gme_load_data(this.gme,ptr,nsf.byteLength);
		let err = __lib.gme_start_track(this.gme,intro);
		if(err != 0) {
			throw new Error(__fms.readUTF8(err,-1));
		}
		let value = { intro : intro, count : __fms.vu8[hnsf + 6], game : __fms.readUTF8(hnsf + 14,32), copyright : __fms.readUTF8(hnsf + 78,32), author : __fms.readUTF8(hnsf + 46,32)};
		this.port.postMessage({ type : 13, value : value});
		__lib.free(ptr);
	}
	onMessage(me) {
		let m = me.data;
		switch(m.type) {
		case 1:
			this.connecting = m.value;
			break;
		case 2:
			this.loadNsf(m.value);
			break;
		case 3:
			__lib.gme_start_track(this.gme,m.value);
			break;
		case 4:
			__lib.gme_seek(this.gme,m.value);
			break;
		case 5:
			__lib.gme_set_fade(this.gme,m.value);
			break;
		case 6:
			this.set_volume(m.value);
			break;
		case 7:
			let q = m.value;
			let v;
			switch(q) {
			case 10:
				v = __lib.gme_tell(this.gme);
				break;
			case 11:
				v = __lib.gme_track_ended(this.gme) == 1;
				break;
			case 12:
				v = this.volume;
				break;
			case 13:
				return;
			}
			this.port.postMessage({ type : q, value : v});
			break;
		}
	}
	process(input,output,params) {
		if(!this.connecting) {
			return true;
		}
		let now = currentTime;
		if(now - this.tellTime > 0.5) {
			let value = __lib.gme_tell(this.gme);
			this.port.postMessage({ type : 10, value : value});
			this.tellTime = now;
		}
		if(now - this.endedTime > 8.) {
			let value = __lib.gme_track_ended(this.gme) == 1;
			this.port.postMessage({ type : 11, value : value});
			this.endedTime = now;
		}
		let outL = output[0][0];
		let outR = output[0][1];
		__lib.gme_play(this.gme,256,this.ptr16);
		let src = this.abi16;
		let i = 0;
		let j = 0;
		let v = this.vol;
		while(i < 128) {
			outL[i] = src[j++] * v;
			outR[i] = src[j++] * v;
			++i;
		}
		return true;
	}
	set_volume(v) {
		this.volume = v;
		this.vol = 3.0517578125e-005 * v;
		return v;
	}
	static main() {
		registerProcessor("gme-worker",GmeWorker);
	}
}
var __lib = null;
var __fms = null;
class _$FMS {
	constructor(imports) {
		if(imports.env == null) {
			imports.env = { };
		}
		let env = imports.env;
		this.cmem = env.memory;
		if(env.jproc == null) {
			env.jproc = this.defProc.bind(this);
		}
		if(env.now == null) {
			env.now = Date.now;
		}
	}
	attach(moi) {
		if(__fms != null) {
			throw new Error("single instance only");
		}
		let inst = moi.instance;
		if(this.cmem == null) {
			this.cmem = inst.exports.memory;
		}
		this.defProc(11,0,0);
		__lib = inst.exports;
		__fms = this;
		return moi;
	}
	readUTF8(ptr,max) {
		if(max < 0) {
			max = this.view.byteLength;
		} else {
			max = ptr + max;
		}
		let a = [];
		let c;
		let c2;
		let c3;
		let c4;
		while(ptr < max) {
			c = this.view.getUint8(ptr++);
			if(c < 128) {
				if(c == 0) {
					break;
				}
			} else if(c < 224) {
				c2 = this.view.getUint8(ptr++);
				if((c2 & 128) == 0) {
					break;
				}
				c = (c & 63) << 6 | c2 & 127;
			} else if(c < 240) {
				c2 = this.view.getUint8(ptr++);
				c3 = this.view.getUint8(ptr++);
				if((c2 & c3 & 128) == 0) {
					break;
				}
				c = (c & 31) << 12 | (c2 & 127) << 6 | c3 & 127;
			} else {
				c2 = this.view.getUint8(ptr++);
				c3 = this.view.getUint8(ptr++);
				c4 = this.view.getUint8(ptr++);
				if((c2 & c3 & c4 & 128) == 0) {
					break;
				}
				c = (c & 15) << 18 | (c2 & 127) << 12 | (c3 & 127) << 6 | c4 & 127;
				a.push((c >> 10) + 55232);
				a.push((c & 1023) + 56320);
				continue;
			}
			a.push(c);
		}
		return String.fromCharCode.apply(null, a);
	}
	writeBuffs(dst,buf,len) {
		this.vu8.set(new Uint8Array(buf,0,len),dst);
	}
	defProc(msg,wparam,lparam) {
		switch(msg) {
		case 9:
			if(wparam >= 1024) {
				throw new Error("FILE: " + this.readUTF8(wparam,-1) + ", LINE: " + lparam);
			}
			break;
		case 10:
			throw new Error("" + wparam);
		case 11:
			this.view = new DataView(this.cmem.buffer);
			this.vu8 = new Uint8Array(this.cmem.buffer);
			break;
		case 12:
			this.putchar(wparam);
			break;
		default:
		}
		return 0;
	}
	putchar(c) {
	}
	static init(buf,imports) {
		let fms = new _$FMS(imports);
		return WebAssembly.instantiate(buf,imports).then(function(moi) {
			return fms.attach(moi);
		});
	}
}
{
}
GmeWorker.main();
})({});