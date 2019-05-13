# cc-export
Creative Coding video export


## how to

lazy start: launch browser, run watch (onchange haxe files livereload)
```
npm run start
```

start without livereload
```
npm run nodemon
```



## use in code

```
import cc.tool.Export;
// export to node server
var export:Export;

// setup export settings
export = new Export(ctx); 			// bind context
export.time(60,2);					// 60 seconds recording after 2 second delay (optional)
export.name('${toString()}');		// file names start with
export.folder('_test');				// folder name to export in
// export.debug(isDebug);			// debug
export.clear(true);					// empty folder when start/restart recording

// start recording
export.start();
```

additional
```
// might be a good idea to change Sketch, in constructor
// setup Sketch
var option = new SketchOption();
option.width = 1080; // 1080
// option.height = 1000;
option.autostart = true;
option.padding = 10;
option.scale = true;
var ctx:CanvasRenderingContext2D = Sketch.create("creative_code_mck", option);

```


## Instagram

the Instagram video time limit is 3–60 seconds

```
3 * 60 (fps) = 180 frames
60 * 60 (fps) = 3600 frames
```



source: <https://blog.snappa.com/instagram-video-format/>

What Is the Best Instagram Video Format You Should Use?
The best Instagram video format is MP4. The MP4 video file format should include these technical specifications:

- H.264 Codec
- AAC Audio
- 3 500 kbps bitrate for video
- Frame rate of 30 fps (frames per second)
- Maximum file size of 15 mb
- Video must be a maximum of 60 seconds
- Maximum video width is 1080 px (pixels) wide
- The Best Instagram Video Dimensions and Size
- The best Instagram video dimensions you should use are 864 pixels (width) by 1080 pixels (height) amount with an aspect ratio of 4:5.

These dimensions and aspect ratio help are optimized to give you more screen real estate for your followers. Wide screen videos might look great on YouTube or Facebook, but on Instagram where most users are on mobile. It makes sense to maximize the vertical dimensions of a phone.


source: <https://later.com/blog/instagram-image-size/>

They should have an aspect ratio of 1:1. And it’s best to go with a size as close to 1080px by 1080px as possible.