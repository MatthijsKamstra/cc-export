package;

import js.Node.*;
import js.Node;
import js.Node.console;
import js.node.Fs;
import js.node.Path;
import js.node.Require;
import js.node.Buffer;
import js.node.*;
import js.npm.Express;
import js.npm.express.*;
import js.npm.SocketIo;
// constants
import model.constants.SocketName.*;
import model.constants.App;
import model.config.Config;
//
import js.node.ChildProcess.*;

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
		console.log('SERVER/START :: ${App.NAME} :: build: ${App.BUILD} ');

		var port = config.PORT;
		// trace('port: $port');

		app = new js.npm.Express();
		server = js.node.Http.createServer(cast app);
		io = new js.npm.socketio.Server(server);

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

		io.on('connection', function(socket) {
			socket.emit('message', {message: 'Welcome from the Node.js server'});

			socket.on(MESSAGE, function(d:Dynamic) {
				var message : AST.Message = d;
				trace(message);
			});

			socket.on(SEND, function(data:Dynamic) {
				io.sockets.emit('id', data.id);
				trace('send data -> ' + data.id);
			});

			socket.on(MARKDOWN, function(d:Dynamic) {
				var data : AST.MarkDown = d;
				trace('markdown');

				validatePath (data.exportFolder, data.folder);
				var path : FsPath = Node.__dirname + '/${data.exportFolder}/${data.folder}/${data.name}';

				Fs.writeFile(path, data.content, function(err) {
				if (err != null) console.log(err);
					console.log("Successfully Written to File.");
				});


			});
			socket.on(COMBINE, function(d:Dynamic) {
				var data : AST.ConvertVideo = d;
				trace('combine: ${data}');

				// ChildProcess.exec('echo "The \\$$HOME variable is $$HOME"', function (err, stdout, stderr) {
				// 	trace('err: $err');
				// 	trace('stdout: $stdout');
				// 	trace('stderr: $stderr');
				// });

				var _exportFolder = validateExportfolder (data.exportFolder);
				var dir = validatePath (_exportFolder, data.folder);

				trace('ffmpeg -y -r 30 -i ${dir}/frame-%04d.png -vcodec libx264 -threads 0 ${dir}/output.mp4');


				ChildProcess.exec('ffmpeg -y -r 30 -i ${dir}/frame-%04d.png -vcodec libx264 -threads 0 ${dir}/output.mp4', function (err, stdout, stderr) {
					trace('err: $err');
					trace('stdout: $stdout');
					trace('stderr: $stderr');
				});

				// just video
				// ffmpeg -r 60 -i /tmp/frame-%04d.png -vcodec libx264 -vpre lossless_slow -threads 0 output.mp4

				// instagram
				// ffmpeg -loop 1 -i image.jpg  -i music.ogg -c:v libx264 -strict -2 -c:a aac -ar 44100 -r 30 -pix_fmt yuv420p -shortest out.mov

				// insta
				// ffmpeg -threads 2 -i input.3gp -vf crop=720:720:0:0 -framerate 30 -strict experimental -qscale 0 cropped-square.mp4

			});
			socket.on(SEQUENCE, function(d:Dynamic) {
				var data : AST.IMAGE = d;
				data.file = data.file.split(',')[1]; // Get rid of the data:image/png;base64 at the beginning of the file data
				var buffer = Buffer.from(data.file, 'base64');

				var _exportFolder = validateExportfolder (data.exportFolder);
				var dir = validatePath (_exportFolder, data.folder);

				Fs.writeFile(
					'${dir}/${data.name}.png',
					buffer, function (e){
						if(e != null){
							trace('something wrong $e');
						} else {
							trace('WRITE :: ${dir}/${data.name}.png');
						}
					});

			});

			socket.on(IMAGE, function(d:Dynamic) {
				var data : AST.IMAGE = d;
				data.file = data.file.split(',')[1]; // Get rid of the data:image/png;base64 at the beginning of the file data
				var buffer = Buffer.from(data.file, 'base64');



				trace(Node.__dirname);
				trace('_id: ${data._id}');
				trace('_type: ${data._type}');
				trace('name: ${data.name}');
				trace('exportFolder: ${data.exportFolder}');
				trace('folder: ${data.folder}');

				var _type = data._type.replace('image/','');
				if(_type == null) _type = 'jpg'; // check for jpg/

				var _folder = data.folder;
				if(_folder == null) _folder = 'tmp';

				var _exportFolder = data.exportFolder;
				if(_exportFolder == null) _exportFolder = 'export';

				var dir = validatePath (_exportFolder, _folder);

				trace('dir" $dir');
				trace('path : ${dir}/${data.name}.${_type}');

				Fs.writeFile(
					Node.__dirname + '/${_exportFolder}/${_folder}/${data.name}.${_type}',
					buffer, function (e){
						if(e != null){
							trace('something wrong $e');
						} else {
							trace(e);
						}
					});
			});
			socket.on(RENDER_FRAME, function(d:Dynamic) {
				var data : AST.RENDER_FRAME = d;
				data.file = data.file.split(',')[1]; // Get rid of the data:image/png;base64 at the beginning of the file data
				// var buffer = new Buffer(data.file, 'base64'); // deprecated
				var buffer = Buffer.from(data.file, 'base64');
				trace(data._id);
				trace(data.name);
				trace(Node.__dirname);
				Fs.writeFile(
					Node.__dirname + '/tmp/frame-' + data.frame + '.png',
					buffer, function (e){
						if(e != null){
							trace('something wrong $e');
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
		trace('Listening on port: ${port} (http://localhost:${port})');
	}

	function validateName (name:String) : String {
		var id = Std.string(Date.now().getTime());
		if (name == ""){
			name = 'frame-$id';
		}
		return name;
	}

	function validateExportfolder (name:String) : String {
		var _exportFolder = name;
		if(_exportFolder == null) _exportFolder = 'export';
		return _exportFolder;
	}

	function validatePath (exportFolder:String, folder:String):FsPath{

				// var _folder = data.folder;
				// if(_folder == null) _folder = 'tmp';

				// var _exportFolder = data.exportFolder;
				// if(_exportFolder == null) _exportFolder = 'export';

		var dir = Node.__dirname + '/${exportFolder}/${folder}';
		if (!Fs.existsSync(dir)){
    		Fs.mkdirSync(dir);
		}
		return dir;
	}

	function saveFile(filename:String, str:String) {
		sys.io.File.saveContent(Node.__dirname + '/_data/${filename}', str);
	}

	static public function main() {
		var app = new MainServer();
	}
}
