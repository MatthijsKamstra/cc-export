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
// import cc.tool.Export.*;

using StringTools;

class MainClientIndex {

	var _socket:Dynamic;

	public function new (){
		console.log('${toString()} : START :: ${App.NAME} :: build: ${App.BUILD} ');
		document.addEventListener("DOMContentLoaded", function(event) {
			console.log('${toString()} : Dom ready');
			initSocket();
		});
	}

	function initSocket():Void {
		_socket = js.browser.SocketIo.connect('http://localhost:${App.PORT}');
		_socket.on('message', function(data) {
			if (data.message != null) {
				trace('${toString()} : ${toString()}data: ' + data);
				document.getElementById('feedbackserver').innerText = (data.message);
			} else {
				trace('${toString()} : ${toString()}There is a problem: ' + data);
			}
		});
	}

	function toString():String{
		return '[Client]';
	}

	static public function main() {
		var main = new MainClientIndex();
	}
}


