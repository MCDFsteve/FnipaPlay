import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:file_picker/file_picker.dart';
import 'package:window_manager/window_manager.dart';
import 'package:flutter/services.dart';
import 'package:fvp/fvp.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();

  windowManager.waitUntilReadyToShow().then((_) async {
    await windowManager.setTitle('FnipaPlay播放视图');
    await windowManager.maximize();
    await windowManager.show();
  });
  registerWith(options: {
    'video.decoders': ['D3D11', 'NVDEC', 'FFmpeg']
    //'lowLatency': 1, // 可选项，用于网络流
  });
  runApp(FnipaPlay());
}

class FnipaPlay extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyVideoPlayer(),
    );
  }
}

class MyVideoPlayer extends StatefulWidget {
  @override
  _MyVideoPlayerState createState() => _MyVideoPlayerState();
}

class _MyVideoPlayerState extends State<MyVideoPlayer> {
  VideoPlayerController? _controller;
  Future<void>? _initializeVideoPlayerFuture;
  bool _isPlaying = false;
  bool _isControlVisible = true;
  double _volume = 0.5;
  OverlayEntry? _volumeOverlay;
  final FocusNode _focusNode = FocusNode();
  Timer? _hideUITimer;
  Timer? _debounceTimer;
  Set<LogicalKeyboardKey> _pressedKeys = {};

  @override
  void initState() {
    super.initState();

    // 确保焦点在初始化时设置
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_focusNode);
    });

    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        RawKeyboard.instance.addListener(_handleRawKeyEvent);
      } else {
        RawKeyboard.instance.removeListener(_handleRawKeyEvent);
      }
    });
  }

  @override
  void dispose() {
    RawKeyboard.instance.removeListener(_handleRawKeyEvent);
    _controller?.dispose();
    _focusNode.dispose();
    _hideUITimer?.cancel(); // 清除定时器
    _debounceTimer?.cancel(); // 清除防抖定时器
    super.dispose();
  }

  void _handleRawKeyEvent(RawKeyEvent event) {
    if (event is RawKeyDownEvent) {
      _handleKeyEvent(event.logicalKey);
    }
  }

  void _handleKeyEvent(LogicalKeyboardKey logicalKey) {
    if (_pressedKeys.contains(logicalKey)) {
      return;
    }
    _pressedKeys.add(logicalKey);

    // 启动或重置延时处理器
    _debounceTimer?.cancel();
    _debounceTimer = Timer(Duration(milliseconds: 100), () {
      // 处理逻辑键按下事件
      print('Key pressed: ${logicalKey.debugName}');
      if (logicalKey == LogicalKeyboardKey.space) {
        // 调用与鼠标点击相同的逻辑
        _togglePlayPause();
      } else if (logicalKey == LogicalKeyboardKey.arrowRight) {
        _seekForward();
      } else if (logicalKey == LogicalKeyboardKey.arrowLeft) {
        _seekBackward();
      } else if (logicalKey == LogicalKeyboardKey.arrowUp) {
        _increaseVolume();
      } else if (logicalKey == LogicalKeyboardKey.arrowDown) {
        _decreaseVolume();
      }
      _pressedKeys.remove(logicalKey); // 处理完成后从集合中移除按键
    });
  }

  void _togglePlayPause() {
    if (_controller == null) {
      return;
    }
    setState(() {
      if (_controller!.value.isPlaying) {
        _controller!.pause();
        _isPlaying = false;
      } else {
        _controller!.play();
        _isPlaying = true;
      }
    });
  }

  void _seekForward() {
    if (_controller != null) {
      _controller!.seekTo(_controller!.value.position + Duration(seconds: 5));
    }
  }

  void _seekBackward() {
    if (_controller != null) {
      _controller!.seekTo(_controller!.value.position - Duration(seconds: 5));
    }
  }

  void _increaseVolume() {
    setState(() {
      _volume = (_volume + 0.1).clamp(0.0, 1.0);
      if (_controller != null) {
        _controller!.setVolume(_volume);
      }
      _showVolumeOverlay();
    });
  }

  void _decreaseVolume() {
    setState(() {
      _volume = (_volume - 0.1).clamp(0.0, 1.0);
      if (_controller != null) {
        _controller!.setVolume(_volume);
      }
      _showVolumeOverlay();
    });
  }

  void _showVolumeOverlay() {
    _volumeOverlay?.remove();
    _volumeOverlay = OverlayEntry(
      builder: (context) => Positioned(
        top: 50,
        right: 50,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: EdgeInsets.all(10),
            color: Colors.black.withOpacity(0.7),
            child: Text(
              '音量：${(_volume * 100).round()}%',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ),
    );

    Overlay.of(context)?.insert(_volumeOverlay!);

    Future.delayed(Duration(seconds: 1), () {
      _volumeOverlay?.remove();
      _volumeOverlay = null;
    });
  }

  void _startHideUITimer() {
    if (_hideUITimer != null && _hideUITimer!.isActive) {
      _hideUITimer!.cancel();
    }
    _hideUITimer = Timer(Duration(milliseconds: 500), () {
      setState(() {
        _isControlVisible = false;
      });
    });
  }
@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.black, // 设置背景为黑色
    body: Center(
      child: MouseRegion(
        onHover: (_) {
          setState(() {
            _isControlVisible = true;
          });
          _startHideUITimer(); // 鼠标移动时启动定时器
        },
        child: Focus(
          focusNode: _focusNode,
          onKeyEvent: (FocusNode node, KeyEvent event) {
            if (event is KeyDownEvent) {
              _handleKeyEvent(event.logicalKey);
              return KeyEventResult.handled; // 确保事件被处理
            }
            return KeyEventResult.ignored;
          },
          child: _controller == null
              ? Text('未选择视频', style: TextStyle(color: Colors.white))
              : FutureBuilder(
                  future: _initializeVideoPlayerFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      return GestureDetector(
                        onTap: _togglePlayPause, // 使用鼠标点击事件控制播放/暂停
                        child: Stack(
                          alignment: Alignment.bottomCenter,
                          children: [
                            SizedBox.expand(
                              child: FittedBox(
                                fit: BoxFit.contain,
                                child: SizedBox(
                                  width: _controller!.value.size.width,
                                  height: _controller!.value.size.height,
                                  child: VideoPlayer(_controller!),
                                ),
                              ),
                            ),
                            if (_isControlVisible)
                              Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: Padding(
                                  padding: const EdgeInsets.all(10),
                                  child: Container(
                                    margin: EdgeInsets.only(top: 20, left: 20, right: 20),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(10),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.3),
                                          offset: Offset(2, 2),
                                          blurRadius: 10,
                                        ),
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.3),
                                          offset: Offset(-2, 2),
                                          blurRadius: 10,
                                        ),
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(10),
                                      child: BackdropFilter(
                                        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 30),
                                          decoration: BoxDecoration(
                                            color: Colors.black.withOpacity(0.2),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          child: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Row(
                                                children: [
                                                  IconButton(
                                                    onPressed: () {}, // 上一话功能
                                                    icon: Icon(Icons.skip_previous, color: Colors.white),
                                                    iconSize: 40.0,
                                                    padding: EdgeInsets.zero,
                                                  ),
                                                  SizedBox(width: 0), // 调整按钮间距
                                                  IconButton(
                                                    onPressed: _togglePlayPause,
                                                    icon: Icon(
                                                      _isPlaying ? Icons.pause : Icons.play_arrow,
                                                      color: Colors.white,
                                                    ),
                                                    iconSize: 34.0,
                                                    padding: EdgeInsets.zero,
                                                  ),
                                                  SizedBox(width: 0), // 调整按钮间距
                                                  IconButton(
                                                    onPressed: () {}, // 下一话功能
                                                    icon: Icon(Icons.skip_next, color: Colors.white),
                                                    iconSize: 34.0,
                                                    padding: EdgeInsets.zero,
                                                  ),
                                                  SizedBox(width: 0), // 调整按钮间距
                                                  IconButton(
                                                    onPressed: _showVolumeDialog,
                                                    icon: Icon(Icons.volume_up, color: Colors.white),
                                                    iconSize: 34.0,
                                                    padding: EdgeInsets.zero,
                                                  ),
                                                  Expanded(
                                                    child: VideoProgressIndicator(
                                                      _controller!,
                                                      allowScrubbing: true,
                                                      padding: EdgeInsets.symmetric(vertical: 0),
                                                      colors: VideoProgressColors(
                                                        playedColor: Color.fromARGB(137, 255, 255, 255),
                                                        backgroundColor: Color.fromARGB(255, 121, 121, 121),
                                                        bufferedColor: Color.fromARGB(189, 216, 216, 216),
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(width: 8), // 调整按钮间距
                                                  ValueListenableBuilder(
                                                    valueListenable: _controller!,
                                                    builder: (context, VideoPlayerValue value, child) {
                                                      return Text(
                                                        '${_formatDuration(value.position)} / ${_formatDuration(value.duration)}',
                                                        style: TextStyle(color: Colors.white),
                                                      );
                                                    },
                                                  ),
                                                  SizedBox(width: 0), // 调整按钮间距
                                                  IconButton(
                                                    onPressed: () {}, // 全屏/窗口化功能
                                                    icon: Icon(Icons.fullscreen, color: Colors.white),
                                                    iconSize: 34.0,
                                                    padding: EdgeInsets.zero,
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    } else {
                      return Center(child: CircularProgressIndicator());
                    }
                  },
                ),
        ),
      ),
    ),
    floatingActionButton: _controller == null
        ? FloatingActionButton(
            onPressed: _pickVideo,
            child: Icon(Icons.video_library),
          )
        : null,
  );
}

  void _showVolumeDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          content: Container(
            height: 150, // 设置滑块的高度
            child: Column(
              children: [
                Text('调整音量', style: TextStyle(color: Colors.black)),
                Expanded(
                  child: RotatedBox(
                    quarterTurns: 3,
                    child: Slider(
                      value: _volume,
                      onChanged: (value) {
                        setState(() {
                          _volume = value;
                          if (_controller != null) {
                            _controller!.setVolume(_volume);
                          }
                        });
                      },
                      min: 0.0,
                      max: 1.0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatDuration(Duration? duration) {
    if (duration == null) return '0:00';
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '${duration.inHours > 0 ? '${twoDigits(duration.inHours)}:' : ''}$minutes:$seconds';
  }

  void _pickVideo() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.video,
    );

    if (result != null) {
      File file = File(result.files.single.path!);
      _controller = VideoPlayerController.file(file);
      _initializeVideoPlayerFuture = _controller!.initialize();
      setState(() {});
    }
  }
}
