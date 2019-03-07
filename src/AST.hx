package;

class AST {}

typedef Base = {
	@:optional var _id:String;
	@:optional var _type:String;
}

typedef Message = {
	> Base,
	var message:String;
};

typedef RENDER_FRAME = {
	> Base,
	var file:String;
	@:optional var frame:Int;
	@:optional var name:String;
	@:optional var folder:String;
};

typedef IMAGE = {
	> Base,
	var file:String;
	var name:String;
	var folder:String;
	@:optional var exportFolder:String;
	// @:optional var name:String;
	// @:optional var folder:String;
	// @:optional var exportFolder:String;
};

typedef MarkDown = {
	> Base,
	var name:String;
	var content:String;
	@:optional var folder:String;
	@:optional var exportFolder:String;
};

typedef ConvertVideo = {
	> Base,
	var name:String;
	var folder:String;
	@:optional var exportFolder:String;
};
