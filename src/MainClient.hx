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

	public function new() {
		console.log('CLIENT/START :: ${App.NAME} :: build: ${App.BUILD} ');
		document.addEventListener("DOMContentLoaded", function(event) {
			console.log('Dom ready');
			initSocket();
			createCanvas();
			createQuickSettings();
		});
	}

	function createQuickSettings() {
		// demo/basic example
		panel1 = QuickSettings.create(10, 10, "cc-export")
			// .setGlobalChangeHandler(untyped drawShape)

			// .addHTML("Reason", "Sometimes I need to find the best settings")

			// .addTextArea('Quote', 'text', function(value) trace(value))
			// .addBoolean('All Caps', false, function(value) trace(value))

			.addButton('Send TEST', function (e) sendTest() )
			.addButton('Send RENDER_FRAME', function (e) renderFrameHandler() )
			.addButton('IMAGE', function (e) renderImage() )
			.addButton('IMAGE - PNG', function (e) renderImage(DataType.PNG) )
			.addButton('IMAGE - JPEG', function (e) renderImage(DataType.JPEG) )
			.addButton('IMAGE _ WEBP', function (e) renderImage(DataType.WEBP) )

			.setKey('h') // use `h` to toggle menu

			.saveInLocalStorage('store-data-cc-export');
	}

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

	function createCanvas(){
		var cc = new CC100();
		_socket.emit('send',{
			id: 'foo',
			file: 'x'
		});
	}

	function sendTest(){
		var data : AST.Message = {
			_id : 'id-message',
			message: "mijn boodschape"
		}
		trace('TEST : $data');
		_socket.emit(TEST, data);
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
			defaultFolder: 'export',
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

	function sendMessage():Void {
		_socket.emit('send', {message: 'text', username: '_inputName.value'});
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

