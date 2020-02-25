package export;

import sketcher.util.EmbedUtil;
import js.Browser.*;
import export.ExportNames.*;

using StringTools;

class NodeServer {
	var _port:String;
	var _host:String;
	var _socket:Dynamic;

	// bools
	var _isEmbeded:Bool = false;
	var _isDebug:Bool = true;
	var _isExportServerReady:Bool = false;
	var _isSocketReady:Bool = false;
	var _isTimer:Bool = false;
	var _isClear:Bool = false;
	var _isRecording:Bool = false;

	//
	var _exportCounter = 0;
	// var _exportArray:Array<String>;
	// default export settings
	var _name:String = 'image'; // default file name
	var _folder:String = 'test'; // default folder name in the export folder

	var imageStringArray:Array<String> = [];

	var isExportActive:Bool = false;

	// timer
	var _startT:Float;
	var _endT:Float;

	@:isVar public var settings(get, set):NodeServerSettings;

	public function new(settings:NodeServerSettings) {
		trace('constructor ${toString()}');
		this.settings = settings;

		this._folder = settings.fileName;

		// might not be bullit proof!!!
		embedScripts(onEmbedComplete);
	}

	// ____________________________________ public  ____________________________________

	public function start() {
		console.log('${toString()} -- start');

		_startT = Date.now().getTime();
		isExportActive = true;
		imageStringArray = [];
		// _delayCounter = 0;
		// _recordCounter = 0;
		if (_isDebug) {
			trace(toString() + ' - start export - 0ms');
			// trace(toExportObj());
		}
	}

	public function stop() {
		console.log('${toString()} -- stop');

		_endT = Date.now().getTime();

		// recordInSeconds((_endT - _startT) / 1000); // calculate the time... might be not the best idea... but
		// record(imageStringArray.length);
		isExportActive = false;
		// out(toString() + ' - stop export - ${(_endT - _startT) / 1000}sec');
		if (_isDebug) {
			trace(toString() + ' - stop export - ${(_endT - _startT) / 1000}sec');
			// trace(toExportObj());
		}

		// if (Reflect.isFunction(_onComplete)) {
		// 	var arr = (_onCompleteParams != null) ? _onCompleteParams : [];
		// 	Reflect.callMethod(_onComplete, _onComplete, arr);
		// }
		// if (Reflect.isFunction(_onRecordComplete)) {
		// 	var arr = (_onRecordCompleteParams != null) ? _onRecordCompleteParams : [];
		// 	Reflect.callMethod(_onRecordComplete, _onRecordComplete, arr);
		// }

		var timeStamp = _endT;

		settings.imageStringArray = imageStringArray;

		startExport();
	}

	public function pulse() {
		if (isExportActive) {
			console.log('${toString()} -- pulse');
			imageStringArray.push(settings.ctx.canvas.toDataURL('image/png').split('base64,')[1]);
			// progressRecording((_recordCounter / _record) * 100);
			// _recordCounter++;
		}
	}

	// ____________________________________ getter/setter ____________________________________

	function get_settings():NodeServerSettings {
		return settings;
	}

	function set_settings(value:NodeServerSettings):NodeServerSettings {
		return settings = value;
	}

	// ____________________________________ private functions ____________________________________

	function startExport() {
		if (_isDebug)
			trace('startExport: ${_exportCounter} / ${imageStringArray.length}');

		// if (Reflect.isFunction(_onProgressHandler)) {
		// 	Reflect.callMethod(_onProgressHandler, _onProgressHandler, [(_exportCounter / _exportArray.length) * 100]);
		// }
		if (_exportCounter >= imageStringArray.length) {
			_isRecording = false;
			// if (Reflect.isFunction(_onExportComplete)) {
			// 	Reflect.callMethod(_onExportComplete, _onExportComplete, []);
			// }
			if (_isDebug)
				trace('${toString()} STOP recording base on total frames');
			convertExport();
			return;
		}
		var id = Std.string(Date.now().getTime());
		var data:AST.EXPORT_IMAGE = {
			_id: id,
			file: imageStringArray[_exportCounter],
			name: '${_name}_${Std.string(_exportCounter).lpad('0', 4)}',
			folder: '${_folder}',
		}

		if (_isDebug)
			trace('${toString()} renderSequence : ${data._id}');

		_socket.emit(SEQUENCE, data);

		// per 60 frames a mention in the browser
		if (_exportCounter % 60 == 1) {
			if (_isDebug)
				trace('current frame render: $_exportCounter/${imageStringArray.length}');
		}
	}

	function deleteFolder() {
		var data:AST.EXPORT_CONVERT_VIDEO = {
			name: '${_name}',
			clear: _isClear,
			folder: '${_folder}',
		};
		this._socket.emit(RENDER_CLEAR, data);
	}

	// ____________________________________ convert to video ____________________________________

	function convertExport() {
		var data:AST.EXPORT_CONVERT_VIDEO = {
			name: '${_name}',
			folder: '${_folder}',
			clear: _isClear,
			description: 'export this file '
		};
		_socket.emit(COMBINE, data);
		var data:AST.EXPORT_FILE = {
			name: '${_name}',
			folder: '${_folder}',
			content: getMarkdown(settings)
		};
		Reflect.setField(data, 'name', 'README.MD');
		Reflect.setField(data, 'content', getMarkdown(settings));
		_socket.emit('export.file', data);
		Reflect.setField(data, 'name', 'convert.sh');
		Reflect.setField(data, 'content', getBashConvert(settings));
		_socket.emit('export.file', data);
		Reflect.setField(data, 'name', 'png.sh');
		Reflect.setField(data, 'content', getBashConvertPng(settings));
		_socket.emit('export.file', data);
	}

	// ____________________________________ init socket (script is embedded) ____________________________________

	function initSocket() {
		// if (_isDebug)
		trace('${toString()} Init Socket');

		if (!_isEmbeded) {
			trace('_isEmbeded : ${_isEmbeded}');
			return;
		}

		console.log(_host, _port);
		_socket = untyped io('http://localhost:5000');

		// _socket = untyped io();

		// trace(this._socket);

		// _socket = untyped __js__('io.connect({0},{upgradeTimeout: 30000});', '${_host}:${_port}');
		// check possible ways to make sure the server is active
		_socket.on('connect_error', function(err) {
			// handle server error here
			console.group('Connection error export server');
			console.warn('${toString()} Error connecting to server "${err}", closing connection');
			console.info('this probably means that cc-export project isn\'t running');
			console.groupEnd();
			_socket.close();
			_isRecording = false;
			_isExportServerReady = false;
		});
		_socket.on("connect", function(err) {
			if (err == 'undefined') {
				trace('${toString()} connect: $err');
			} else {
				trace('${toString()} connect');
			}
			if (err == null) {
				_isSocketReady = true;
			}
		});
		_socket.on("disconnect", function(err) {
			trace('${toString()} disconnect: $err');
			// _currentFrame = _frameCounter;
			// trace('_currentFrame : $_currentFrame');
		});
		_socket.on("connect_failed", function(err) {
			trace('${toString()} connect_failed: $err');
		});
		_socket.on("error", function(err) {
			trace('${toString()} error: $err');
		});
		// messages from the server back
		// _socket.emit('message', 'checkin');
		_socket.on('message', function(data) {
			if (data.message != null) {
				console.log('${toString()} message: ' + data.message);
			} else {
				console.log('${toString()} There is a problem: ' + data);
			}
		});
		_socket.emit(CHECKIN);
		_socket.on(SERVER_CHECKIN, function(data) {
			if (data.checkin != null && data.checkin == true) {
				_isExportServerReady = true;
				console.log('${toString()} data:  + $data, & _isExportServerReady: $_isExportServerReady');
			} else {
				console.log('${toString()} There is a problem: ' + data);
			}
		});
		_socket.on(RENDER_DONE, function(data) {
			console.log(data);
		});
		_socket.on(RENDER_CLEAR_DONE, function(data) {
			if (_isDebug)
				console.log(data.message);
			startExport();
		});
		_socket.on(SEQUENCE_NEXT, function(data) {
			if (_isDebug)
				console.log('SEQUENCE_NEXT: ' + data.message);
			_exportCounter++;
			startExport();
		});
	}

	// ____________________________________ inject script into page ____________________________________

	function onEmbedComplete(?value:String) {
		if (_isDebug)
			console.log('${toString()} ${value}');

		console.warn('$value = Embedded');

		this._isEmbeded = true;
		haxe.Timer.delay(function() {
			initSocket();
		}, 1);
	}

	/**
	 * embedScripts(onEmbedComplete);
	 *
	 * @param callback
	 * @param callbackArray
	 */
	public function embedScripts(?callback:Dynamic, ?callbackArray:String->Void) {
		var id = 'embedSocketIO';
		trace('Check if "${id}" is embedded');

		if (!EmbedUtil.check(id)) {
			console.warn('$id = not Embedded');
			this._isEmbeded = false;
			EmbedUtil.script(id, 'https://cdnjs.cloudflare.com/ajax/libs/socket.io/2.2.0/socket.io.js', onEmbedComplete, ['socket.io is embedded and loaded']);
		} else {
			console.warn('$id = already embeded');
			// onEmbedComplete();
		}
	}

	// ____________________________________ get export files ____________________________________

	public function getMarkdownLite():String {
		var md = '# ${toString()}

- Generated on: ${Date.now()}

## Instagram

```
#codeart #coding #creativecode #generative #generativeArt
#minimalism #minimalist #minimal
#haxe #javascript #js #nodejs
#illustration #graphicdesign #graphic
#animation #motion #motiondesign #motiongraphics
```

## convert

open terminal

```
sh convert.sh
```

';

		return md;
	}

	public function getMarkdown(obj:NodeServerSettings):String {
		var md = '# ${toString()}

- Generated on: ${Date.now()}
- total images: ${obj.imageStringArray.length}
- calculated time: ${obj.imageStringArray.length / 60} sec (60 fps)
- file name: `_${obj.fileName}_${obj.timeStamp}.zip`
- delay: ${obj.delay} frames (${obj.delay / 60} sec)
- record: ${obj.record} frames (${obj.record / 60} sec)

## Instagram

```
sketch.${obj.fileName} :: ${obj.description}

#codeart #coding #creativecode #generative #generativeArt
#minimalism #minimalist #minimal
#haxe #javascript #js #nodejs
#illustration #graphicdesign #graphic
#animation #motion #motiondesign #motiongraphics
```

## convert

open terminal

```
sh convert.sh
```

## Folder structure

```
+ _${obj.fileName}_${obj.timeStamp}.zip
+ _${obj.fileName}
	- convert.sh
	- README.MD
	+ sequence
		- image_${Std.string(0).lpad('0', 4)}.png
		- image_${Std.string(1).lpad('0', 4)}.png
		- ...
```
';

		return md;
	}

	public function getBashConvert(obj:NodeServerSettings):String {
		var bash = '#!/bin/bash

echo \'Start convertions png sequence to mp4\'

ffmpeg -y -r 30 -i sequence/image_%04d.png -c:v libx264 -strict -2 -pix_fmt yuv420p -shortest -filter:v "setpts=0.5*PTS"  ${obj.fileName}_output_30fps.mp4

# convert a short sequence to a mp4, one frame per second
# ffmpeg -y -r 1 -i sequence/image_%04d.png -c:v libx264 -strict -2 -pix_fmt yuv420p -shortest -filter:v "setpts=0.5*PTS"  ${obj.fileName}_output_1fps.mp4

# rendercan fix
# ffmpeg -y -r 30 -i framescemage_%09d.png -c:v libx264 -strict -2 -pix_fmt yuv420p -shortest -filter:v "setpts=0.5*PTS"  sequence/_output_30fps.mp4

echo \'End convertions png sequence to mp4\'

';

		return bash;
	}

	public function getBashConvertPng(obj:NodeServerSettings):String {
		var bash2 = '
#!/bin/bash

echo \'Start remove transparancy from images sequence\'

cd sequence
mkdir output
for i in *.png; do
   convert "$$i" -background white -alpha remove output/"$$i"
   echo "$$i"
done

echo \'End remove transparancy from images sequence\'
echo \'Start convertions png sequence to mp4\'

ffmpeg -y -r 30 -i output/image_%04d.png -c:v libx264 -strict -2 -pix_fmt yuv420p -shortest -filter:v "setpts=0.5*PTS"  ../${obj.fileName}_white_output_30fps.mp4

echo \'End convertions png sequence to mp4\'

';

		return bash2;
	}

	// ____________________________________ misc ____________________________________

	function toString() {
		return '[NodeServer]';
	}
}
