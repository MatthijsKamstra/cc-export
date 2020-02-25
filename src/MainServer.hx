package;

import js.Node.*;
import js.Node;
import js.Node.console;
import js.node.Fs;
import js.node.Path;
import js.node.Buffer;
import js.node.*;
import js.npm.Express;
import js.npm.express.*;
// get the cc lib for export and AST
import Sketch;
import cc.*;
import cc.tool.export.ExportNames.*;
// constants
import model.constants.App;
import model.config.Config;

//
using StringTools;

/**
 * @author Matthijs Kamstra aka [mck]
 * MIT
 */
class MainServer {
	var app:Dynamic;
	var server:Dynamic;
	var io:Dynamic;
	var config:Config = new Config();

	public function new() {
		console.log('${toString()}/START :: ${App.NAME} :: build: ${App.getBuildDate()} ');

		var port = config.PORT;
		// trace('${toString()} : port: $port');

		app = new js.npm.Express();
		server = js.node.Http.createServer(cast app);
		io = new js.npm.socketio.Server(server, null, untyped {
			pingTimeout: 60000, // default 5000
			pingInterval: 25000, // default 25000
		});

		// setup
		// app.set('port', port);

		// use
		// app.use(new Favicon(Node.__dirname + '/public/favicon.gif'));
		app.use(new Favicon(Node.__dirname + '/favicon.ico')); // because I like favicons
		app.use(new Morgan('dev')); // set morgan to log info about our requests for development use.
		app.use(BodyParser.json()); // support json encoded bodies
		app.use(BodyParser.urlencoded({extended: true})); // initialize body-parser to parse incoming parameters requests to req.body
		app.use(new Static(Path.join(Node.__dirname, 'public')));
		app.use(new CookieParser()); // initialize cookie-parser to allow us access the cookies stored in the browser.
		// initialize express-session to allow us track the logged-in user across sessions.

		// app.get( '/' , function (req, res) {
		// 	res.send('Welcome to the Node.js server');
		// });

		// Statics routes
		app.get('/', function(req:Request, res:Response) {
			res.sendFile(Node.__dirname + '/public/index.html');
		});
		app.get('/test', function(req:Request, res:Response) {
			res.sendFile(Node.__dirname + '/public/test.html');
		});

		io.on('connection', function(socket) {
			socket.emit(MESSAGE, {message: 'Welcome from the Export Node.js server'});

			socket.on(MESSAGE, function(d:Dynamic) {
				var message:AST.EXPORT_MESSAGE = d;
				trace('${toString()} : ' + message);
			});

			socket.on(CHECKIN, function(d:Dynamic) {
				trace('${toString()} : Server :: ${CHECKIN}');
				socket.emit(SERVER_CHECKIN, untyped {checkin: true});
			});
			socket.on(RENDER_CLEAR, function(d:Dynamic) {
				var data:AST.EXPORT_CONVERT_VIDEO = d;
				trace('${toString()} : combine: ${data}');

				var _exportFolder = validateExportfolder(data.exportFolder);
				var dir = validatePath(_exportFolder, '${data.folder}/sequence/');

				var child = ChildProcess.exec('rm -rf ${dir}', function(err, stdout, stderr) {
					trace('${toString()} : err: $err');
					trace('${toString()} : stdout: $stdout');
					trace('${toString()} : stderr: $stderr');
				});

				child.stdout.pipe(process.stdout);
				child.on('exit', function() {
					trace('${toString()} delete folder "${dir}"');
					socket.emit(MESSAGE, {message: 'Folder "${dir}" is deleted'});
					socket.emit(RENDER_CLEAR_DONE, {message: 'Folder "${dir}" is deleted'});
					// process.exit(process.exitCode);
				});
			});

			socket.on(SEND, function(data:Dynamic) {
				io.sockets.emit('id', data.id);
				trace('${toString()} : send data -> ' + data.id);
			});

			socket.on(MARKDOWN, function(d:Dynamic) {
				var data:AST.EXPORT_MD = d;
				trace('${toString()} : markdown');
				console.warn('this doesn\'t work yet');

				return;

				// var dir = validatePath(_exportFolder, '${data.folder}/sequence/');
				var path:FsPath = Node.__dirname + '/${data.exportFolder}/${data.folder}/${data.name}';

				Fs.writeFile(path, data.content, function(err) {
					if (err != null) {
						console.log(err);
					}
					console.log("Successfully Written to File.");
				});
			});
			socket.on('export.file', function(d:Dynamic) {
				var data:AST.EXPORT_FILE = d;

				var _exportFolder = validateExportfolder(data.exportFolder);
				var dir = validatePath(_exportFolder, '${data.folder}');

				Fs.writeFile('${dir}/${data.name}', data.content, function(err) {
					if (err != null) {
						console.log(err);
					}
					console.log("!!!! Successfully Written to File.");
					socket.emit(MESSAGE, {message: 'Write file "${data.name}" is done "${dir}/${data.name}"'});
				});
			});
			socket.on(COMBINE, function(d:Dynamic) {
				var data:AST.EXPORT_CONVERT_VIDEO = d;
				trace('${toString()} : combine: ${data}');

				// writeMarkdown(data);

				// ChildProcess.exec('echo "The \\$$HOME variable is $$HOME"', function (err, stdout, stderr) {
				// 	trace('${toString()} : err: $err');
				// 	trace('${toString()} : stdout: $stdout');
				// 	trace('${toString()} : stderr: $stderr');
				// });

				// if(data.clear != null){
				// 	trace('${toString()} clear folder: ${data.clear}');
				// }

				var _exportFolder = validateExportfolder(data.exportFolder);
				var dir = validatePath(_exportFolder, '${data.folder}/sequence/');

				// trace('${toString()} : ffmpeg -y -r 60 -i ${dir}/${data.name}-%04d.png -vcodec libx264 -threads 0 ${dir}/${data.name}_output_60fps.mp4');
				// ChildProcess.exec('ffmpeg -y -r 60 -i ${dir}/${data.name}-%04d.png -vcodec libx264 -threads 0 ${dir}/${data.name}_output_60fps.mp4', function (err, stdout, stderr) {
				// 	trace('${toString()} : err: $err');
				// 	trace('${toString()} : stdout: $stdout');
				// 	trace('${toString()} : stderr: $stderr');
				// });

				socket.emit(MESSAGE, {message: 'Start rendering video with ffmpg (${Date.now()})'});
				trace('${toString()} : ffmpeg -y -r 30 -i ${dir}/${data.name}_%04d.png -c:v libx264 -strict -2 -pix_fmt yuv420p -shortest -filter:v "setpts=0.5*PTS"  ${dir}/${data.name}_output_30fps.mp4');
				var child = ChildProcess.exec('ffmpeg -y -r 30 -i ${dir}/${data.name}_%04d.png -c:v libx264 -strict -2 -pix_fmt yuv420p -shortest -filter:v "setpts=0.5*PTS"  ${dir}/${data.name}_output_30fps.mp4',
				function(err, stdout, stderr) {
					trace('${toString()} : err: $err');
					trace('${toString()} : stdout: $stdout');
					trace('${toString()} : stderr: $stderr');
				});

				// trace('${toString()} : ffmpeg -y -r 30 -i ${dir}/${data.name}-%04d.png -vcodec libx264 -filter:v "setpts=0.5*PTS" -threads 0 ${dir}/${data.name}_output_30fps.mp4');
				// trace('${toString()} : ffmpeg -y -r 30 -i ${dir}/${data.name}-%04d.png -c:v libx264 -strict -2 -pix_fmt yuv420p -shortest ${dir}/${data.name}_output_30fps.mp4');
				// var child = ChildProcess.exec('ffmpeg -y -r 30 -i ${dir}/${data.name}-%04d.png -vcodec libx264 -filter:v "setpts=0.5*PTS" -threads 0 ${dir}/${data.name}_output_30fps.mp4',function(err, stdout, stderr) {
				// 		trace('${toString()} : err: $err');
				// 		trace('${toString()} : stdout: $stdout');
				// 		trace('${toString()} : stderr: $stderr');
				// });

				child.stdout.pipe(process.stdout);
				child.on('exit', function() {
					trace('${toString()} generate is done');
					trace('ffmpeg -i ${dir}/${data.name}_output_30fps.mp4 -hide_banner');
					// ChildProcess.execFile('ffmpeg', ['-i ${dir}/${data.name}_output_30fps.mp4', '-hide_banner'],function (err, stdout, stderr)  {
					// 	trace('${toString()} : err: $err');
					// 	trace('${toString()} : stdout: $stdout');
					// 	trace('${toString()} : stderr: $stderr');
					// });

					socket.emit(RENDER_DONE, {message: 'render is done'});
					socket.emit(MESSAGE, {message: 'Render file is ready "${dir}/${data.name}_output_30fps.mp4" (${Date.now()})'});
					// process.exit(process.exitCode);
					// process.exit(0);
				});

				// just video
				// ffmpeg -r 60 -i /tmp/frame-%04d.png -vcodec libx264 -vpre lossless_slow -threads 0 output.mp4

				// instagram
				// ffmpeg -loop 1 -i image.jpg  -i music.ogg -c:v libx264 -strict -2 -c:a aac -ar 44100 -r 30 -pix_fmt yuv420p -shortest out.mov

				// insta
				// ffmpeg -threads 2 -i inpugp -vf crop=720:720:0:0 -framerate 30 -strict experimental -qscale 0 cropped-square.mp4
			});
			socket.on(SEQUENCE, function(d:Dynamic) {
				var data:AST.EXPORT_IMAGE = d;
				// data.file = data.file.split(',')[1]; // Get rid of the data:image/png;base64 at the beginning of the file data
				var buffer = Buffer.from(data.file, 'base64');

				var _exportFolder = validateExportfolder(data.exportFolder);
				var dir = validatePath(_exportFolder, '${data.folder}/sequence/');

				Fs.writeFile('${dir}/${data.name}.png', buffer, function(e) {
					if (e != null) {
						trace('${toString()} : something wrong $e');
					} else {
						trace('${toString()} : WRITE :: ${dir}/${data.name}.png');
						socket.emit(SEQUENCE_NEXT, {message: 'next file can be send'});
					}
				});
			});

			socket.on(IMAGE, function(d:Dynamic) {
				var data:AST.EXPORT_IMAGE = d;
				data.file = data.file.split(',')[1]; // Get rid of the data:image/png;base64 at the beginning of the file data
				var buffer = Buffer.from(data.file, 'base64');

				trace(Node.__dirname);
				trace('${toString()} : _id: ${data._id}');
				trace('${toString()} : _type: ${data._type}');
				trace('${toString()} : name: ${data.name}');
				trace('${toString()} : exportFolder: ${data.exportFolder}');
				trace('${toString()} : folder: ${data.folder}');

				var _type = data._type.replace('image/', '');
				if (_type == null)
					_type = 'jpg'; // check for jpg/

				var _folder = data.folder;
				if (_folder == null)
					_folder = 'tmp';

				var _exportFolder = data.exportFolder;
				if (_exportFolder == null)
					_exportFolder = 'export';

				var dir = validatePath(_exportFolder, '${data.folder}/sequence/');

				trace('${toString()} : dir" $dir');
				trace('${toString()} : path : ${dir}/${data.name}.${_type}');

				Fs.writeFile(Node.__dirname + '/${_exportFolder}/${_folder}/${data.name}.${_type}', buffer, function(e) {
					if (e != null) {
						trace('${toString()} : something wrong $e');
					} else {
						trace(e);
					}
				});
			});
			socket.on(RENDER_FRAME, function(d:Dynamic) {
				var data:AST.EXPORT_FRAME = d;
				data.file = data.file.split(',')[1]; // Get rid of the data:image/png;base64 at the beginning of the file data
				// var buffer = new Buffer(data.file, 'base64'); // deprecated
				var buffer = Buffer.from(data.file, 'base64');
				trace(data._id);
				trace(data.name);
				trace(Node.__dirname);
				Fs.writeFile(Node.__dirname + '/tmp/frame-' + data.frame + '.png', buffer, function(e) {
					if (e != null) {
						trace('${toString()} : something wrong $e');
					} else {
						trace(e);
					}
				});
				// Fs.writeFile(
				// 	Node.__dirname + '/tmp/frame-' + data.frame + '.png',
				// 	buffer.toString('binary'), 'binary');
			});
		});

		server.listen(port);
		trace('${toString()} : Listening on port: ${port} (http://localhost:${port})');
	}

	function writeMarkdown(data:AST.EXPORT_CONVERT_VIDEO) {
		var _exportFolder = validateExportfolder(data.exportFolder);
		var dir = validatePath(_exportFolder, '${data.folder}/sequence/');
		var description = (data.description != null) ? data.description : 'nothing to mention about this project';
		var path:FsPath = dir + '/${data.name}_.md';
		var _content = '# ${data.name}\n\n${description}';
		Fs.writeFile(path, _content, function(err) {
			if (err != null)
				console.log(err);
			console.log("Successfully Written to File.");
		});
	}

	function validateName(name:String):String {
		var id = Std.string(Date.now().getTime());
		if (name == "") {
			name = 'frame-$id';
		}
		return name;
	}

	function validateExportfolder(name:String):String {
		var _exportFolder = name;
		if (_exportFolder == null)
			_exportFolder = 'export';
		return _exportFolder;
	}

	function validatePath(exportFolder:String, folder:String):FsPath {
		// var _folder = data.folder;
		// if(_folder == null) _folder = 'tmp';

		// var _exportFolder = data.exportFolder;
		// if(_exportFolder == null) _exportFolder = 'export';

		var dir = Node.__dirname + '/${exportFolder}/${folder}';
		if (!Fs.existsSync(dir)) {
			Fs.mkdirSync(dir, untyped {recursive: true});
		}
		return dir;
	}

	function saveFile(filename:String, str:String) {
		sys.io.File.saveContent(Node.__dirname + '/_data/${filename}', str);
	}

	function toString():String {
		return '[SERVER]';
	}

	static public function main() {
		var app = new MainServer();
	}
}
