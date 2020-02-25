# cc-export

Creative Coding video export

When the browser is not able to export the files I use the this node.js server to do that for me.

## test client

- url: `http://127.0.0.1:5500/bin/public/test.html`
- `build_client.hxml`
- `MainClient.hx`
- `CC100.hx`

## how to

lazy start: launch browser, run watch (onchange haxe files livereload)

```
npm run start
```

start without livereload

```
npm run nodemon
```

## Haxelib

cc-export has some class to work with, use them

Use this git directly

```
haxelib git cc-export https://github.com/MatthijsKamstra/cc-export.git
```

You can use this git repos as a development directory:

```
haxelib dev cc-export path/to/folder
```

don't forget to add it to your build file

```
-lib cc-export
```

## use in code

```
// import
import export.NodeServer;
import export.NodeServerSettings;

// export
var export:NodeServer;

// setup export settings
var settings = new NodeServerSettings(sketch.canvas.getContext2d(), 'cc100');
export = new NodeServer(settings);
trace(export.settings); // get the settings

// start recording
export.start();

// stop recording
export.stop();

// connect the pulse

override function draw() {
    // trace('DRAW :: ${toString()}');
    drawShape();
    export.pulse();
    // stop();
}


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
