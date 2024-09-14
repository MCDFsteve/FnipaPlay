## 0.23.0

* add `Player.snapshot()`
* fix sometimes no intialized event
* enable http(s) reconnect
* fix Player.state is not current state

## 0.22.0

* windows: fix d3d11 sync issue
* android: min api level is 21, target sdk 34

## 0.21.0

* add `Player.setAsset()`
* android 16KB page size
* compatible with vcrt 14.20

## 0.20.2

* fix macos and ios dependency

## 0.20.1

* fix dependencies install

## 0.20.0

* android: use SurfaceProducer only for impeller, fix surface lifetime if impeller not enabled
* force upgrade dependencies via environment var `FVP_DEPS_LATEST=1`(except macOS and iOS)
* support http(s) cache via `registerOpts['player']['demux.buffer.ranges'] = '$positive_int'`

## 0.19.0

* registerWith() can register official backends if a platform is not specified in platforms
* check seekable range for live streams
* live stream duration.inMicroseconds is int max
* fix wasm build
* fix log level

## 0.18.0

* support Impeller for android. may require flutter 3.19+ to build

## 0.17.0

* fix initialized event

## 0.16.1

* compatible with dart < 3.3

## 0.16.0

* `import 'package:fvp/fvp.dart'` and `registerWith(...)` are optional on windows and linux
* don't hardcode ffmpeg library name. prepare for ffmpeg 7.0

## 0.15.0

* fix deprecated methods
* delay texture creation if video size is unknown, improve low latency streams
* Player: support registing multiple event and state callbacks

## 0.14.0

* set default subtitle file, required by android subtitle rendering

## 0.13.1

* fix build in flutter installed via snap

## 0.13.0

* support video with rotation
* support tunnel mode for android

## 0.12.0

* make libfvp_plugin.so optional on android

## 0.11.0

* support flutter 3.16, fix runtime error
* fix isCompleted is never true since previous version

## 0.10.0

* keep open when play to end
* fix texture aspect ratio
* add lowLatency option

## 0.9.0

* remove callbacks before StreamController close, avoid add event when closed

## 0.8.0

* fix rtsp, rtmp open error
* fix music cover art sometimes is not displayed. ensure texture is created before the 1st video frame.

## 0.7.0

* fix seek ignored if previous is not finished
* add `fastSeek` option in `registerWith()`. default is accurate seek

## 0.6.0

* fix incorrect dxgi adapter used on windows
* fix video may be not displayed on windows 7
* support audio without video

## 0.5.0

* fix s16p audio play on android
* `Player.seek()` is async

## 0.4.0

* free for all platforms
* fix android x86 load error
* enable x11 multi-thread on linux
* VideoEvent.completed
* better error handling if failed to open a media

## 0.3.0

* use software decoder in android emulator, fix black screen
* able to pass global options and player properties to libmdk
* improve log
* add arm64 ios simulater

## 0.2.1

* fix cmake include
* allow http in m3u8 local file
* add D3D11 decoder for windows

## 0.2.0

* fix web build. web will use official implementation
* add 'platforms' option for `registerWith()` to enable plugin for given platforms, other platforms will use official implementation
* `Player.prepare()` is async
* no longer export `MdkVideoPlayer`

## 0.1.0

* fix fail to convert metadata to dart string
* rename `State` to `PlaybackState`

## 0.0.9

* add textureId notifier for Player
* improve documentation

## 0.0.8

* support httpHeaders
* export backend apis for creating your own players

## 0.0.7

* texture size can be set by user via `MdkVideoPlayer.registerWith({'maxWidth': width, 'maxHeight': height});`
* fix crash for some streams containing subtitle

## 0.0.6

* fix local file path encoding
* use objc instead of swift. simpler code, smaller binary size, less dependencies.

## 0.0.5

* fix macos, ios build for flutter without sharedDarwinSource support
* fix StreamController close

## 0.0.4

* supports assets
* improve bufferingUpdate event
* support backend logging
* customize decoders via `MdkVideoPlayer.registerWith({'video.decoders': [...]})`

## 0.0.3

* fix macos build from pub

## 0.0.2

* fix macos build

## 0.0.1

* video playback for windows, linux, macos, ios, android
* hardware decoding, optimal gpu rendering
