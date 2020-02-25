package export;

import js.html.CanvasRenderingContext2D;
import js.Browser.*;

class NodeServerSettings {
	@:isVar public var ctx(get, set):js.html.CanvasRenderingContext2D;
	@:isVar public var fileName(get, set):String;
	@:isVar public var timeStamp(get, set):Float;

	// length delay and record time
	@:isVar public var delay(get, set):Int = 0;
	@:isVar public var record(get, set):Int = 0;

	// totally not
	@:isVar public var description(get, set):String = '[empty]';

	@:isVar public var imageStringArray(get, set):Array<String> = [];

	public function new(ctx:CanvasRenderingContext2D, ?fileName:String) {
		if (ctx == null) {
			console.warn('This is not acceptable, I need a context!');
			return;
		}

		this.fileName = (fileName == null) ? 'cc-export' : fileName;
		this.timeStamp = Date.now().getTime();

		this.ctx = ctx;

		// var delay:Int;
		// var record:Int;
		// var delay_in_seconds:Float;
		// var record_in_seconds:Float;
		// var imageStringArray:Array<String>;
		// @:optional var description:String;
	}

	// ____________________________________ getter/setter ____________________________________

	function get_ctx():js.html.CanvasRenderingContext2D {
		return ctx;
	}

	function set_ctx(value:js.html.CanvasRenderingContext2D):js.html.CanvasRenderingContext2D {
		return ctx = value;
	}

	function get_fileName():String {
		return fileName;
	}

	function set_fileName(value:String):String {
		return fileName = value;
	}

	function get_timeStamp():Float {
		return timeStamp;
	}

	function set_timeStamp(value:Float):Float {
		return timeStamp = value;
	}

	function get_delay():Int {
		return delay;
	}

	function set_delay(value:Int):Int {
		return delay = value;
	}

	function get_record():Int {
		return record;
	}

	function set_record(value:Int):Int {
		return record = value;
	}

	function get_description():String {
		return description;
	}

	function set_description(value:String):String {
		return description = value;
	}

	function get_imageStringArray():Array<String> {
		return imageStringArray;
	}

	function set_imageStringArray(value:Array<String>):Array<String> {
		return imageStringArray = value;
	}
}
