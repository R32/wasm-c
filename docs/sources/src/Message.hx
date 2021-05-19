package;

typedef NsfInfo = {
	intro : Int,  // first_track
	count : Int,  // track_count
	game  : String,
	copyright : String,
	author : String,
}

typedef Message<T> = {
	type   : T,
	value  : Dynamic,
}

/*
enum NsfMessage {
	Play(track : Int, ?nsf : ArrayBuffer);
	Seek(msec : Int);
	FadeOut(msec : Int);
	Volume(v : Float);
	Query(q : QueryType); // the result will be passed back through postMessage()
}
*/

extern enum abstract EAction(Int) {
	var Attach  = 1; // value : Bool(connect/disconnect)
	var Load    = 2; // value : ArrayBuffer(NSF)
	var Play    = 3; // value : Int(track), extra :
	var Seek    = 4; // value : Int
	var FadeOut = 5; // value : Int
	var Volume  = 6; // value : Float
	var Query   = 7; // value : QueryType
}

extern enum abstract EQuery(Int) {
	var Tell       = 10;  // value = mirco second
	var TrackEnded = 11;  // value = bool|false
	var Volume     = 12;  // value = 0~1.0
	var NsfInfo    = 13;  // value = NsfInfo
}
