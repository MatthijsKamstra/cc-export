package model.constants;

import haxe.macro.Context;

class App {
	public static var NAME:String = "[cc-export]";
	public static var PORT:String = "5000";

	public static inline macro function getBuildDate() {
		#if !display
		var date = Date.now().toString();
		return macro $v{date};
		#else
		var date = Date.now().toString();
		return macro $v{date};
		#end
	}
}
