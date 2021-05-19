#if js

import js.lib.Promise;
import js.lib.ArrayBuffer;
import js.html.DOMElement;
import js.html.MouseEvent;
import js.html.KeyboardEvent;
import js.html.KeyboardEvent in VK;

// from -lib wasm-c
import tools.Macros.FUNC;
import tools.Macros.BIND;
//
import Macros.text;
import Macros.display;
import Macros.clsl;
//
import Global.CHANNEL;
import Global.SAMPLE_RATE;
import Global.FRAME_COUNT;
import Global.GME_WORKER;

import Global.CSS_INLINE_BLOCK;
import Global.CSS_BLOCK;
import Global.CSS_NONE;
import Global.CSS_EMPTY;
//
import Global.console;
import Global.document;
import Global.window;
import Global.location;
import Global.fetch;
import Global.strint;
import Global.numint;

#end
