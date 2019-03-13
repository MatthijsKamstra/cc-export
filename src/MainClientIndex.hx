package;

import js.Browser.*;
import js.html.*;
// art
import art.*;
// settings
import quicksettings.QuickSettings;
// constants
import model.constants.App;
// AST and Export
import cc.*;
import cc.tool.Export.*;

using StringTools;

class MainClientIndex {

	public function new (){
		trace('yep');
	}

	function toString():String{
		return '[Client]';
	}

	static public function main() {
		var main = new MainClientIndex();
	}
}


