package art;

import js.Browser.*;
import js.html.*;
import Sketch;

import cc.tool.Export;

using StringTools;

class CC100 extends SketchBase {
	var shapeArray:Array<Circle> = [];
	var grid:GridUtil = new GridUtil();
	// sizes
	var _radius = 150;
	var _cellsize = 150;
	// colors
	var _color0:RGB = null;
	var _color1:RGB = null;
	var _color2:RGB = null;
	var _color3:RGB = null;
	var _color4:RGB = null;
	// settings
	var panel1:QuickSettings;
	// animate
	var dot:Circle;
	// export to node server
	var export:Export;
	var startTime:Float;

	public function new() {
		// setup Sketch
		var option = new SketchOption();
		option.width = 1080; // 1080
		// option.height = 1000;
		option.autostart = true;
		option.padding = 10;
		option.scale = true;
		var ctx:CanvasRenderingContext2D = Sketch.create("creative_code_mck", option);


		startTime = haxe.Timer.stamp();
		init();

		super(ctx);
	}

	function init() {
		dot = createShape(100, {x: w / 2, y: h / 2});
		// <link href="https://fonts.googleapis.com/css?family=Oswald:200,300,400,500,600,700" rel="stylesheet">
		FontUtil.embedGoogleFont('Oswald:200,300,400,500,600,700', onEmbedHandler);
		FontUtil.embedGoogleFont('Share+Tech+Mono', onEmbedHandler);
		// createQuickSettings();
		onAnimateHandler(dot);
	}

	function onEmbedHandler(e) {
		trace('onEmbedHandler :: ${toString()} -> "${e}"');
		drawShape();

		export.start();
	}

	function createShape(i:Int, ?point:Point) {
		var shape:Circle = {
			_id: '$i',
			_type: 'circle',
			x: point.x,
			y: point.y,
			radius: _radius,
		}
		// onAnimateHandler(shape);
		return shape;
	}

	function onAnimateHandler(obj:Circle) {
		var padding = 50;
		var time = random(1, 2);
		var xpos = random(padding, w - (2 * padding));
		var ypos = random(padding, h - (2 * padding));
		Go.to(obj, time)
			.x(xpos)
			.y(ypos)
			.ease(Sine.easeInOut)
			.onComplete(onAnimateHandler, [obj]);
	}

	function drawShape() {
		ctx.clearRect(0, 0, w, h);
		ctx.backgroundObj(_color0);

		if (isDebug) {
			ShapeUtil.gridField(ctx, grid);
		}

		for (i in 0...shapeArray.length) {
			var sh = shapeArray[i];
		}
		// var rgb = randomColourObject();
		// ctx.strokeColour(rgb.r, rgb.g, rgb.b);
		// ctx.xcross(w/2, h/2, 200);

		ctx.fillStyle = getColourObj(_color2);
		FontUtil.create(ctx, '${export.count}/${export.delay}sec/${export.duration}sec/${export.frames}frames')
			.x(w2)
			.y(h4*1)
			.centerAlign()
			.size(60)
			.font("Share Tech Mono")
			.draw();


		ctx.fillStyle = getColourObj(_color4);
		FontUtil.create(ctx, '${toString()}')
			.x(w2)
			.y(h2)
			.centerAlign()
			.size(260)
			.font("'Oswald', sans-serif;")
			.draw();


		var time = Date.now();
		var hours = time.getHours(); // 24
		var min = time.getMinutes(); // 60
		var sec = time.getSeconds(); // 60
		// var sec = time.get() + 1; // 60

		var text = '${Std.string(hours).lpad('0',2)}:${Std.string(min).lpad('0',2)}:${Std.string(sec).lpad('0',2)}';

		ctx.fillStyle = getColourObj(_color3);
		FontUtil.create(ctx, text)
			.x(w2)
			.y(h4*3)
			.centerAlign()
			.size(160)
			.font("Share Tech Mono")
			.draw();

		ctx.fillStyle = getColourObj(_color2);
		FontUtil.create(ctx, '${haxe.Timer.stamp() - startTime}')
			.x(w4)
			.y(h - 100)
			.leftAlign()
			.size(50)
			.font("Share Tech Mono")
			.draw();

		ctx.strokeColourRGB(_color3);
		ctx.strokeWeight(20);
		ctx.circleStroke(dot.x, dot.y, 100);
	}

	override function setup() {
		trace('SETUP :: ${toString()}');

		var colorArray = ColorUtil.niceColor100SortedString[randomInt(ColorUtil.niceColor100SortedString.length - 1)];
		_color0 = hex2RGB(colorArray[0]);
		_color1 = hex2RGB(colorArray[1]);
		_color2 = hex2RGB(colorArray[2]);
		_color3 = hex2RGB(colorArray[3]);
		_color4 = hex2RGB(colorArray[4]);

		isDebug = true;

		// grid.setDimension(w*2.1, h*2.1);
		// grid.setNumbered(3,3);
		grid.setCellSize(_cellsize);
		grid.setIsCenterPoint(true);

		shapeArray = [];
		for (i in 0...grid.array.length) {
			shapeArray.push(createShape(i, grid.array[i]));
		}

		export = new Export(ctx);
		export.time(3,2);
		export.name('${toString()}');
		export.folder('_test');
		// export.debug(isDebug);
		export.clear(true);


	}

	override function draw() {
		// trace('DRAW :: ${toString()}');
		drawShape();
		// stop();
	}

	override function toString(){
		return 'cc100';
	}
}
