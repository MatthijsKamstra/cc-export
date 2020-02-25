package;

import export.ExportNames.*;
import js.Browser.*;
import model.constants.App;
import quicksettings.QuickSettings;

using StringTools;

class MainClient {
	var _socket:Dynamic;
	var panel1:QuickSettings;
	var frameCounter = 0;
	var _isRecording:Bool = false;
	var isDebug = false;

	public function new() {
		console.log('${toString()} START :: ${App.NAME} :: build: ${App.getBuildDate()} ');
		document.addEventListener("DOMContentLoaded", function(event) {
			console.log('${toString()} Dom ready');
			if (isDebug) {
				initSocket();
				initQuickSettings();
			}
			initCanvas();
		});
	}

	// ____________________________________ init  ____________________________________

	function initSocket():Void {
		_socket = js.browser.SocketIo.connect('http://localhost:${App.PORT}');
		_socket.on('message', function(data) {
			if (data.message != null) {
				trace('${toString()} : ${toString()}data: ' + data);
			} else {
				trace('${toString()} : ${toString()}There is a problem: ' + data);
			}
		});
	}

	function initCanvas() {
		var cc = new art.CC100();
		if (isDebug) {
			_socket.emit(SEND, {
				id: 'foo',
				file: 'x'
			});
		}
	}

	function initQuickSettings() {
		// demo/basic example
		panel1 = QuickSettings.create(10, 10, "cc-export") // .setGlobalChangeHandler(untyped drawShape)

			.addButton('Send TEST', function(e) sendMessage())
			.addButton('Send RENDER_FRAME', function(e) renderFrameHandler()).addButton('IMAGE', function(e) renderImage())
			.addButton('IMAGE - PNG', function(e) renderImage(DataType.PNG)).addButton('IMAGE - JPEG', function(e) renderImage(DataType.JPEG))
			.addButton('IMAGE _ WEBP', function(e) renderImage(DataType.WEBP)).addBoolean('Recording', false, function(e) toggleRecording(e))

			.addButton('convert', function(e) convertRecording(e)).addButton('markdown', function(e) writeReadme(e)).setKey('h') // use `h` to toggle menu

			.saveInLocalStorage('store-data-cc-export');
	}

	// ____________________________________ set settings vars ____________________________________

	function sendMessage() {
		var data:export.AST.EXPORT_MESSAGE = {
			_id: 'id-message',
			message: "mijn boodschap"
		}
		trace('${toString()} : MESSAGE : $data');
		_socket.emit(MESSAGE, data);
	}

	// ____________________________________ render image/video ____________________________________

	function getId():String {
		var id = Std.string(Date.now().getTime());
		return id;
	}

	function toggleRecording(isRecording:Bool) {
		trace('${toString()} : toggleRecording: $isRecording');
		_isRecording = isRecording;
		if (_isRecording) {
			frameCounter = 0;
			window.requestAnimationFrame(renderSequence);
		}
	}

	function convertRecording(e) {
		trace(e);
		var data:export.AST.EXPORT_CONVERT_VIDEO = {
			_id: getId(),
			name: 'frame-${Std.string(frameCounter).lpad('0', 4)}',
			folder: 'sequence',
		};
		_socket.emit(COMBINE, data);
	}

	// ____________________________________ markdown ____________________________________

	function writeReadme(e) {
		var data:export.AST.EXPORT_MD = {
			name: 'readme.md',
			content: 'test me',
			folder: 'output',
			exportFolder: 'export'
		}
		_socket.emit(MARKDOWN, data);
	}

	// ____________________________________ RENDERS ____________________________________

	function renderSequence(?timestamp:Float) {
		var canvas:js.html.CanvasElement = cast document.getElementById('creative_code_mck');
		var dataString = canvas.toDataURL(); // default png
		var id = Std.string(Date.now().getTime());
		var data:export.AST.EXPORT_IMAGE = {
			_id: id,
			file: dataString,
			// name: 'frame-${id.lpad('0',4)}',
			name: 'frame-${Std.string(frameCounter).lpad('0', 4)}',
			folder: 'sequence',
		}
		trace('${toString()} : renderSequence : ${data._id}');
		_socket.emit(SEQUENCE, data);

		frameCounter++;
		if (_isRecording) {
			window.requestAnimationFrame(renderSequence);
		}
	}

	/**
	 *
	 * @param type default 'image/png', other options 'image/jpeg' and 'image/webp' (Chrome)
	 */
	function renderImage(?type:DataType = DataType.PNG) {
		var canvas:js.html.CanvasElement = cast document.getElementById('creative_code_mck');
		// var dataString = canvas.toDataURL();
		var dataString = canvas.toDataURL(Std.string(type), 1); // 1 is heighest value, only works with jpg/webp

		var id = Std.string(Date.now().getTime());
		var data:export.AST.EXPORT_IMAGE = {
			_id: id,
			_type: Std.string(type),
			file: dataString,
			name: 'name-${id.lpad('0', 4)}',
			// name: 'name-${Std.string(frameCounter).lpad('0',4)}',
			folder: 'img',
			exportFolder: 'export',
		}
		trace('${toString()} : renderImage : ${data._type}');
		_socket.emit(IMAGE, data);
	}

	function renderFrameHandler() {
		var canvas:js.html.CanvasElement = cast document.getElementById('creative_code_mck');
		var dataString = canvas.toDataURL();

		frameCounter++;
		var data:export.AST.EXPORT_FRAME = {
			_id: 'id-renderframe',
			file: dataString,
			frame: frameCounter,
			name: 'name-${Std.string(frameCounter).lpad('0', 4)}',
			folder: 'export'
		}
		trace('${toString()} : renderFrameHandler : ${data.name}');
		_socket.emit(RENDER_FRAME, data);
	}

	function toString():String {
		return '[Client]';
	}

	static public function main() {
		var main = new MainClient();
	}
}

@:enum abstract DataType(String) {
	var JPG = 'image/jpeg';
	var JPEG = 'image/jpeg';
	var PNG = 'image/png'; // default value
	var WEBP = 'image/webp'; // chrome only
}
