package art;

import Sketcher.Globals.*;
import sketcher.AST.Circle;
import sketcher.AST.Point;
import sketcher.draw.Text.TextAlignType;
import sketcher.lets.Go;
import sketcher.lets.easing.Sine;
import sketcher.util.ColorUtil.*;
import sketcher.util.ColorUtil;
import sketcher.util.EmbedUtil;
import sketcher.util.GridUtil;
import sketcher.util.MathUtil.*;
import sketcher.util.MathUtil;
// export
import export.NodeServer;
import export.NodeServerSettings;

using StringTools;

class CC100 extends SketcherBase {
	// size
	var stageW = 1080; // 1024; // video?
	var stageH = 1080; // 1024; // video?
	var padding = 50;
	// family
	var oswaldFamily:String;
	var monoFamily:String;
	//
	var grid:GridUtil;
	var shapeArray:Array<Circle> = [];
	// sizes
	var _radius = 150;
	var _cellsize = 150;
	// colors
	var _color0:RGB = null;
	var _color1:RGB = null;
	var _color2:RGB = null;
	var _color3:RGB = null;
	var _color4:RGB = null;

	// animate
	var dot:Circle;
	var startTime:Float;

	// export
	var export:NodeServer;

	public function new() {
		// setup Sketch
		var settings:Settings = new Settings(stageW, stageH, 'canvas');
		settings.autostart = true;
		settings.padding = 0;
		settings.scale = true;
		settings.elementID = 'creative_code_mck';

		super(settings);
	}

	function init() {
		var settings = new NodeServerSettings(sketch.canvas.getContext2d(), 'cc100');
		export = new NodeServer(settings);
		trace(export.settings); // get the settings
		haxe.Timer.delay(function() {
			trace('start forced recording');
			export.start();
		}, 500);
		haxe.Timer.delay(function() {
			trace('stop forced recording');
			export.stop();
		}, 5000);
	}

	function onEmbedHandler(e) {
		trace('${toString()} onEmbedHandler :: ${toString()} -> "${e}"');
		drawShape();
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
		if (dot == null)
			return;

		// reset previous sketch
		sketch.clear();

		// background color
		var bg = sketch.makeRectangle(0, 0, w, h, false);
		bg.id = "bg color";
		bg.fillColor = getColourObj(_color0);

		// quick generate grid
		if (isDebug) {
			sketcher.debug.Grid.gridDots(sketch, grid);
		}

		for (i in 0...shapeArray.length) {
			var sh = shapeArray[i];
		}

		var text = sketch.makeText('delay ${export.settings.delay} frames/record ${export.settings.record} frames', w2, h4 * 1);
		text.setFill(getColourObj(_color2));
		text.fontFamily = monoFamily;
		text.fontSizePx = 60;
		text.textAlign = TextAlignType.Center;

		var text = sketch.makeText('${toString()}', w2, h2);
		text.setFill(getColourObj(_color4));
		text.fontFamily = oswaldFamily;
		text.fontSizePx = 260;
		text.textAlign = TextAlignType.Center;

		var time = Date.now();
		var hours = time.getHours(); // 24
		var min = time.getMinutes(); // 60
		var sec = time.getSeconds(); // 60
		// // var sec = time.get() + 1; // 60

		var str = '${Std.string(hours).lpad('0', 2)}:${Std.string(min).lpad('0', 2)}:${Std.string(sec).lpad('0', 2)}';
		var text = sketch.makeText(str, w2, h4 * 3);
		text.setFill(getColourObj(_color3));
		text.fontFamily = monoFamily;
		text.fontSizePx = 160;
		text.textAlign = TextAlignType.Center;

		var text = sketch.makeText('${haxe.Timer.stamp() - startTime}', w4, h - 100);
		text.setFill(getColourObj(_color2));
		text.fontFamily = monoFamily;
		text.fontSizePx = 50;
		text.textAlign = TextAlignType.Left;

		var circle = sketch.makeCircle(dot.x, dot.y, 100).setStroke(getColourObj(_color3), 20).noFill();

		sketch.update();
	}

	override function setup() {
		trace('${toString()} SETUP :: ${toString()}');

		init();

		oswaldFamily = EmbedUtil.embedGoogleFont('Oswald:200,300,400,500,600,700', onEmbedHandler);
		monoFamily = EmbedUtil.embedGoogleFont('Share+Tech+Mono', onEmbedHandler);

		trace(oswaldFamily, monoFamily);

		startTime = haxe.Timer.stamp();
		dot = createShape(100, {x: w2, y: h2});
		onAnimateHandler(dot);

		var colorArray = ColorUtil.niceColor100SortedString[randomInt(ColorUtil.niceColor100SortedString.length - 1)];
		_color0 = hex2RGB(colorArray[0]);
		_color1 = hex2RGB(colorArray[1]);
		_color2 = hex2RGB(colorArray[2]);
		_color3 = hex2RGB(colorArray[3]);
		_color4 = hex2RGB(colorArray[4]);
		isDebug = true;

		// grid
		grid = new GridUtil(w, h);
		// grid.setDimension(w*2.1, h*2.1);
		// grid.setNumbered(3,3);
		grid.setCellSize(_cellsize);
		grid.setIsCenterPoint(true);

		// set default values
		shapeArray = [];
		for (i in 0...grid.array.length) {
			shapeArray.push(createShape(i, grid.array[i]));
		}
	}

	override function draw() {
		// trace('DRAW :: ${toString()}');
		drawShape();
		export.pulse();
		// stop();
	}
}
