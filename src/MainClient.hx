package;

import js.Browser.*;
import js.html.*;
// art
import art.*;
// settings
import quicksettings.QuickSettings;
// constants
import model.constants.SocketName.*;
import model.constants.App;

using StringTools;

class MainClient {
	var _socket:Dynamic;
	var panel1:QuickSettings;
	var frameCounter = 0;
	var _isRecording : Bool = false;

	public function new() {
		console.log('CLIENT/START :: ${App.NAME} :: build: ${App.BUILD} ');
		document.addEventListener("DOMContentLoaded", function(event) {
			console.log('Dom ready');
			initSocket();
			initCanvas();
			initQuickSettings();
		});
	}

	// ____________________________________ init  ____________________________________

	function initSocket():Void {
		_socket = js.browser.SocketIo.connect('http://localhost:${App.PORT}');
		_socket.on('message', function(data) {
			if (data.message != null) {
				trace("data: " + data);
			} else {
				trace("There is a problem: " + data);
			}
		});
	}

	function initCanvas(){
		var cc = new CC100();
		_socket.emit(SEND,{
			id: 'foo',
			file: 'x'
		});
	}
	function initQuickSettings() {
		// demo/basic example
		panel1 = QuickSettings.create(10, 10, "cc-export")
			// .setGlobalChangeHandler(untyped drawShape)

			.addButton('Send TEST', function (e) sendMessage() )
			.addButton('Send RENDER_FRAME', function (e) renderFrameHandler() )
			.addButton('IMAGE', function (e) renderImage() )
			.addButton('IMAGE - PNG', function (e) renderImage(DataType.PNG) )
			.addButton('IMAGE - JPEG', function (e) renderImage(DataType.JPEG) )
			.addButton('IMAGE _ WEBP', function (e) renderImage(DataType.WEBP) )

			.addBoolean('Recording', false, function (e) toggleRecording(e))

			.addButton('convert', function (e) convertRecording(e) )
			.addButton('markdown', function (e) writeReadme(e) )

			.setKey('h') // use `h` to toggle menu

			.saveInLocalStorage('store-data-cc-export');
	}

	// ____________________________________ set settings vars ____________________________________

	function sendMessage(){
		var data : AST.Message = {
			_id : 'id-message',
			message: "mijn boodschap"
		}
		trace('MESSAGE : $data');
		_socket.emit(MESSAGE, data);
	}

	// ____________________________________ render image/video ____________________________________

	function getId():String{
		var id = Std.string(Date.now().getTime());
		return id;
	}


	function toggleRecording (isRecording:Bool)  {
		trace('toggleRecording: $isRecording');
		_isRecording = isRecording;
		if(_isRecording){
			frameCounter = 0;
			window.requestAnimationFrame(renderSequence);
		}
	}

	function convertRecording (e)  {
		trace(e);
		var data : AST.ConvertVideo = {
			_id: getId(),
			name: 'frame-${Std.string(frameCounter).lpad('0',4)}',
			folder: 'sequence',
		};
		_socket.emit(COMBINE, data);
	}

	// ____________________________________ markdown ____________________________________

	function writeReadme (e)  {
		var data : AST.MarkDown = {
			name: 'readme.md',
			content: 'test me',
			folder:'output',
			exportFolder: 'export'
		}
		_socket.emit(MARKDOWN, data);
	}

	// ____________________________________ RENDERS ____________________________________

	function renderSequence (?timestamp:Float){
		var canvas : js.html.CanvasElement = cast document.getElementById('creative_code_mck');
		var dataString = canvas.toDataURL(); // default png
		var id = Std.string(Date.now().getTime());
		var data : AST.IMAGE = {
			_id : id,
			file: dataString,
			// name: 'frame-${id.lpad('0',4)}',
			name: 'frame-${Std.string(frameCounter).lpad('0',4)}',
			folder: 'sequence',
		}
		trace('renderSequence : ${data._id}');
		_socket.emit(SEQUENCE, data);

		frameCounter++;
		if(_isRecording){
			window.requestAnimationFrame(renderSequence);
		}
	}

	/**
	 *
	 * @param type default 'image/png', other options 'image/jpeg' and 'image/webp' (Chrome)
	 */
	function renderImage(?type:DataType = DataType.PNG){
		var canvas : js.html.CanvasElement = cast document.getElementById('creative_code_mck');
		// var dataString = canvas.toDataURL();
		var dataString = canvas.toDataURL(Std.string(type), 1); // 1 is heighest value, only works with jpg/webp

		var id = Std.string(Date.now().getTime());
		var data : AST.IMAGE = {
			_id : id,
			_type : Std.string(type),
			file: dataString,
			name: 'name-${id.lpad('0',4)}',
			// name: 'name-${Std.string(frameCounter).lpad('0',4)}',
			folder: 'img',
			exportFolder: 'export',
		}
		trace('renderImage : ${data._type}');
		_socket.emit(IMAGE, data);
	}

	function renderFrameHandler(){
		var canvas : js.html.CanvasElement = cast document.getElementById('creative_code_mck');
		var dataString = canvas.toDataURL();

		frameCounter++;
		var data : AST.RENDER_FRAME = {
			_id : 'id-renderframe',
			file: dataString,
			frame: frameCounter,
			name: 'name-${Std.string(frameCounter).lpad('0',4)}',
			folder: 'export'
		}
		trace('renderFrameHandler : ${data.name}');
		_socket.emit(RENDER_FRAME, data);
	}

	static public function main() {
		var main = new MainClient();
	}
}

@:enum abstract DataType (String) {
	var JPG = 'image/jpeg';
	var JPEG = 'image/jpeg';
	var PNG = 'image/png'; // default value
	var WEBP = 'image/webp'; // chrome only
}

