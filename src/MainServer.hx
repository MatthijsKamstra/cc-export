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
			socket.on(TEST, function(d:Dynamic) {
				var message : AST.Message = d;
				trace(message);
			});

			socket.on('send', function(data:Dynamic) {
				io.sockets.emit('id', data.id);
				trace('send data -> ' + data.id);
			});
			socket.on(IMAGE, function(d:Dynamic) {
				var data : AST.IMAGE = d;
				data.file = data.file.split(',')[1]; // Get rid of the data:image/png;base64 at the beginning of the file data
				var buffer = Buffer.from(data.file, 'base64');



				trace(Node.__dirname);
				trace('_id: ${data._id}');
				trace('_type: ${data._type}');
				trace('name: ${data.name}');
				trace('defaultFolder: ${data.defaultFolder}');
				trace('folder: ${data.folder}');

				var _type = data._type;
				if(_type == null) _type = 'jpg'; // check for jpg/

				var _folder = data.folder;
				if(_folder == null) _folder = 'tmp';

				var _defaultFolder = data.defaultFolder;
				if(_defaultFolder == null) _defaultFolder = 'export';

				var dir = Node.__dirname + '/${_defaultFolder}/${_folder}';


				if (!Fs.existsSync(dir)){
    				Fs.mkdirSync(dir);
				}

				trace('dir" $dir');
				trace('path : ${dir}/${data.name}');

				Fs.writeFile(
					Node.__dirname + '/${_defaultFolder}/${_folder}/${data.name}.png',
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

	function saveFile(filename:String, str:String) {
		sys.io.File.saveContent(Node.__dirname + '/_data/${filename}', str);
	}

	static public function main() {
		var app = new MainServer();
	}
}
