package export;

class AST {}

// enum ExportType {
// 	ZIP;
// 	NODE;
// 	NONE;
// 	TEST;
// }
// typedef ExportSettings = {
// 	var type:ExportType;
// 	var record:Int;
// 	@:optional var delay:Int; // default 0
// 	@:optional var isDebug:Bool; // default false
// };
// typedef ExportWrapperObj = {
// 	// @:optional var _id : Int;
// 	var filename:String; // filename is for zip the foldername where the files in exported are
// 	@:optional var export_type:ExportType;
// 	var delay:Int;
// 	var record:Int;
// 	var delay_in_seconds:Float;
// 	var record_in_seconds:Float;
// 	var imageStringArray:Array<String>;
// 	var timestamp:Float;
// 	@:optional var description:String;
// };
// ____________________________________ export typedef ____________________________________

typedef Base = {
	@:optional var _id:String;
	@:optional var _type:String; // make possible to switch draw
	// [mck] perhaps enum? ShapeType
}

typedef EXPORT_MESSAGE = {
	> Base,
	var message:String;
};

typedef EXPORT_FRAME = {
	> Base,
	var file:String;
	@:optional var frame:Int;
	@:optional var name:String;
	@:optional var folder:String;
};

typedef EXPORT_IMAGE = {
	> Base,
	var file:String;
	var name:String;
	var folder:String;
	@:optional var exportFolder:String;
	// @:optional var name:String;
	// @:optional var folder:String;
	// @:optional var exportFolder:String;
};

typedef EXPORT_MD = {
	> Base,
	var name:String;
	var content:String;
	@:optional var folder:String;
	@:optional var exportFolder:String;
};

typedef EXPORT_FILE = {
	> Base,
	var name:String;
	var content:String;
	@:optional var folder:String;
	@:optional var exportFolder:String;
};

typedef EXPORT_CONVERT_VIDEO = {
	> Base,
	var name:String;
	var folder:String;
	@:optional var exportFolder:String;
	@:optional var clear:Bool;
	@:optional var description:String;
	@:optional var fps:Int; // 60 default
};
