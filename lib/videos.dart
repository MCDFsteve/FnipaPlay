// ignore_for_file: sized_box_for_whitespace, prefer_typing_uninitialized_variables

library videos;

import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';
import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:window_manager/window_manager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// ignore: depend_on_referenced_packages
import 'package:video_player/video_player.dart';
// ignore: depend_on_referenced_packages
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:fnipaplay/audio_video_progress_bar.dart';
import 'dart:convert';
import 'package:fnipaplay/danmaku/lib/canvas_danmaku.dart';
// ignore: depend_on_referenced_packages
import 'package:ionicons/ionicons.dart';
import 'package:fnipaplay/danmaku.dart';

var videofile;
var zentime;
double masteropac = 1;
bool isMaximized = true;
bool isFullScreen = false;
bool _isMouseMoving = true;
double _iconOpacity = 0.5;
double _iconOpacity2 = 0.5;
double _iconOpacity3 = 0.5;
double _iconOpacity4 = 0.5;
double _iconOpacity5 = 0.5;
double _iconOpacity6 = 1.0;
double _iconOpacity8 = 0.5;
bool conop = false;
bool isWinOrLin = Platform.isWindows || Platform.isLinux;

//bool isWinOrLin = Platform.isMacOS;
class AnimeMatch {
  int? episodeId;
  int? animeId;
  String? animeTitle;
  String? episodeTitle;

  AnimeMatch(
      {this.episodeId, this.animeId, this.animeTitle, this.episodeTitle});
}

// 全局变量
AnimeMatch anime = AnimeMatch();
List<Map<String, dynamic>> danmakuList = [];
Set<String> displayedDanmaku = {};

class MyVideoPlayer extends StatefulWidget {
  const MyVideoPlayer({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _MyVideoPlayerState createState() => _MyVideoPlayerState();
}

class FnipaPlay extends StatelessWidget {
  const FnipaPlay({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyVideoPlayer(),
    );
  }
}

class VideoPosa extends State<MyVideoPlayer> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('绘制圆角矩形示例'),
        ),
        body: CustomPaint(
          size: const Size(100, 3), // 指定画布大小
          painter: MyRectanglePainter(),
        ),
      ),
    );
  }
}

class MyRectanglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.fill;

    // 定义圆角矩形的路径
    Path path = Path();
    path.moveTo(0, size.height); // 左下角起点
    path.lineTo(0, size.height - 1); // 左上角
    path.arcToPoint(Offset(3, size.height - 1),
        radius: const Radius.circular(1)); // 右上角
    path.lineTo(3, size.height); // 右下角
    path.close();

    // 绘制圆角矩形
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}

class _MyVideoPlayerState extends State<MyVideoPlayer> {
  late DanmakuController _controllerdanmaku;
  VideoPlayerController? _controller;
  Future<void>? _initializeVideoPlayerFuture;
  bool _isPlaying = false;
  double _volume = 0.5;
  OverlayEntry? _volumeOverlay;
  final FocusNode _focusNode = FocusNode();
  Timer? _hideUITimer;
  Timer? _debounceTimer;
  // ignore: unused_field
  Timer? _timer;
  final Set<LogicalKeyboardKey> _pressedKeys = {};
  get none => null;

  @override
  void initState() {
    super.initState();
    // 确保焦点在初始化时设置
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_focusNode);
    });
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        // ignore: deprecated_member_use
        RawKeyboard.instance.addListener(_handleRawKeyEvent);
      } else {
        // ignore: deprecated_member_use
        RawKeyboard.instance.removeListener(_handleRawKeyEvent);
      }
    });
  }

  @override
  void dispose() {
    // ignore: deprecated_member_use
    RawKeyboard.instance.removeListener(_handleRawKeyEvent);
    _controller?.dispose();
    _focusNode.dispose();
    _hideUITimer?.cancel(); // 清除定时器
    _debounceTimer?.cancel(); // 清除防抖定时器
    super.dispose();
  }

  void _handleMouseHover(bool isHovering) {
    setState(() {
      _iconOpacity = isHovering ? 1.0 : 0.5;
    });
  }

  void _handleMouseHover2(bool isHovering) {
    setState(() {
      _iconOpacity2 = isHovering ? 1.0 : 0.5;
    });
  }

  void _handleMouseHover3(bool isHovering) {
    setState(() {
      _iconOpacity3 = isHovering ? 1.0 : 0.5;
    });
  }

  void _handleMouseHover4(bool isHovering) {
    setState(() {
      _iconOpacity4 = isHovering ? 1.0 : 0.5;
    });
  }

  void _handleMouseHover5(bool isHovering) {
    setState(() {
      _iconOpacity5 = isHovering ? 1.0 : 0.5;
    });
  }

  void _handleMouseHover6() {
    if (_hideUITimer != null && _hideUITimer!.isActive) {
      _hideUITimer!.cancel();
    }
    if (!conop) {
      _hideUITimer = Timer(const Duration(milliseconds: 1500), () {
        setState(() {
          _iconOpacity6 = 0.0;
          _isMouseMoving = false;
        });
      });
    }
  }

  void _handleMouseHover8(bool isHovering) {
    setState(() {
      _iconOpacity8 = isHovering ? 1.0 : 0.5;
    });
  }

  // ignore: deprecated_member_use
  void _handleRawKeyEvent(RawKeyEvent event) {
    // ignore: deprecated_member_use
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
    _debounceTimer = Timer(const Duration(milliseconds: 100), () {
      // 处理逻辑键按下事件
      //print('Key pressed: ${logicalKey.debugName}');
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
      } else if (logicalKey == LogicalKeyboardKey.enter && !isFullScreen) {
        isFullScreen = true;
        masteropac = 0;
        windowManager.setFullScreen(isFullScreen);
      } else if (logicalKey == LogicalKeyboardKey.escape && isFullScreen) {
        isFullScreen = false;
        masteropac = 1;
        windowManager.setFullScreen(isFullScreen);
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
        _controllerdanmaku.pause();
      } else {
        _controller!.play();
        _isPlaying = true;
        _controllerdanmaku.resume();
      }
    });
  }

  void _seekForward() {
    if (_controller != null) {
      _controller!
          .seekTo(_controller!.value.position + const Duration(seconds: 5));
      _onSeekComplete();
    }
  }

  void _seekBackward() {
    if (_controller != null) {
      _controller!
          .seekTo(_controller!.value.position - const Duration(seconds: 5));
      _onSeekComplete();
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
        top: 80,
        left: 0,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 6),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 255, 255, 255).withOpacity(0),
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: const Color.fromARGB(52, 0, 0, 0).withOpacity(0.1),
                  offset: const Offset(2, 2),
                  blurRadius: 10,
                ),
                BoxShadow(
                  color: const Color.fromARGB(33, 0, 0, 0).withOpacity(0.1),
                  offset: const Offset(-2, 2),
                  blurRadius: 10,
                ),
              ],
            ),
            child: ClipRRect(
                borderRadius: BorderRadius.circular(5),
                child: Container(
                    padding:
                        const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                    child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                        child: MouseRegion(
                            onEnter: (_) {
                              _handleMouseHover8(true); // 鼠标进入时，设置为完全不透明
                            },
                            onExit: (_) {
                              _handleMouseHover8(false); // 鼠标离开时，恢复为默认透明度
                            },
                            child: AnimatedOpacity(
                              duration: const Duration(milliseconds: 200),
                              opacity: _iconOpacity8,
                              child: Text(
                                '音量：${(_volume * 100).round()}%',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ))))),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_volumeOverlay!);

    Future.delayed(const Duration(seconds: 2), () {
      _volumeOverlay?.remove();
      _volumeOverlay = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // 设置背景为黑色
      body: Stack(children: [
        Center(
          child: MouseRegion(
            onHover: (_) {
              setState(() {
                _iconOpacity6 = 1.0;
                _handleMouseHover6();
                _isMouseMoving = true;
              }); // 鼠标移动时启动定时器
            }, // 这里使用一个变量来控制图标的透明度
            cursor: _isMouseMoving
                ? SystemMouseCursors.basic
                : SystemMouseCursors.none,
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
                  ? const Text('未选择视频', style: TextStyle(color: Colors.white))
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
                                MouseRegion(onEnter: (_) {
                                  setState(() {});
                                }, onExit: (_) {
                                  setState(() {});
                                }),
                                //显示集数名字
                                DanmakuControl(
                                  controller: _controller!,
                                  IconOpacity6: _iconOpacity6,
                                  onControllerCreated: (controller) {
                                    _controllerdanmaku = controller;
                                  },
                                ),
                                //播放器控制栏
                                Positioned(
                                  bottom: 0,
                                  left: 0,
                                  right: 0,
                                  child: MouseRegion(
                                      onEnter: (_) {
                                        setState(() {
                                          conop = true;
                                        });
                                      },
                                      onExit: (_) {
                                        setState(() {
                                          conop = false;
                                        });
                                      },
                                      child: AnimatedOpacity(
                                        duration:
                                            const Duration(milliseconds: 150),
                                        opacity: _iconOpacity6,
                                        child: Padding(
                                          padding: const EdgeInsets.all(10),
                                          child: Container(
                                            margin: const EdgeInsets.only(
                                                top: 20, left: 20, right: 20),
                                            decoration: BoxDecoration(
                                              color:
                                                  Colors.white.withOpacity(0),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.3),
                                                  offset: const Offset(2, 2),
                                                  blurRadius: 10,
                                                ),
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withOpacity(0.3),
                                                  offset: const Offset(-2, 2),
                                                  blurRadius: 10,
                                                ),
                                              ],
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              child: BackdropFilter(
                                                filter: ImageFilter.blur(
                                                    sigmaX: 30, sigmaY: 30),
                                                child: Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      vertical: 0,
                                                      horizontal: 7),
                                                  margin: const EdgeInsets.only(
                                                      top: 0,
                                                      left: 0,
                                                      right: 0),
                                                  decoration: BoxDecoration(
                                                    color: Colors.black
                                                        .withOpacity(0),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.max,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          MouseRegion(
                                                              onEnter: (_) {
                                                                _handleMouseHover(
                                                                    true); // 鼠标进入时，设置为完全不透明
                                                              },
                                                              onExit: (_) {
                                                                _handleMouseHover(
                                                                    false); // 鼠标离开时，恢复为默认透明度
                                                              },
                                                              child:
                                                                  AnimatedOpacity(
                                                                      duration: const Duration(
                                                                          milliseconds:
                                                                              200),
                                                                      opacity:
                                                                          _iconOpacity, // 这里使用一个变量来控制图标的透明度
                                                                      child:
                                                                          IconButton(
                                                                        onPressed:
                                                                            () {}, // 上一话功能
                                                                        icon: const Icon(
                                                                            CupertinoIcons
                                                                                .backward_fill,
                                                                            color:
                                                                                Colors.white),
                                                                        iconSize:
                                                                            25.0,
                                                                        padding:
                                                                            EdgeInsets.zero,
                                                                      ))),
                                                          const SizedBox(
                                                              width:
                                                                  0), // 调整按钮间距
                                                          MouseRegion(
                                                              onEnter: (_) {
                                                                _handleMouseHover2(
                                                                    true); // 鼠标进入时，设置为完全不透明
                                                              },
                                                              onExit: (_) {
                                                                _handleMouseHover2(
                                                                    false); // 鼠标离开时，恢复为默认透明度
                                                              },
                                                              child:
                                                                  AnimatedOpacity(
                                                                      duration: const Duration(
                                                                          milliseconds:
                                                                              200),
                                                                      opacity:
                                                                          _iconOpacity2, // 这里使用一个变量来控制图标的透明度
                                                                      child:
                                                                          IconButton(
                                                                        onPressed:
                                                                            _togglePlayPause,
                                                                        icon:
                                                                            Icon(
                                                                          _isPlaying
                                                                              ? CupertinoIcons.pause_solid
                                                                              : CupertinoIcons.play_arrow_solid,
                                                                          color:
                                                                              Colors.white,
                                                                        ),
                                                                        iconSize:
                                                                            35.0,
                                                                        padding:
                                                                            EdgeInsets.zero,
                                                                      ))),
                                                          const SizedBox(
                                                              width:
                                                                  0), // 调整按钮间距
                                                          MouseRegion(
                                                              onEnter: (_) {
                                                                _handleMouseHover3(
                                                                    true); // 鼠标进入时，设置为完全不透明
                                                              },
                                                              onExit: (_) {
                                                                _handleMouseHover3(
                                                                    false); // 鼠标离开时，恢复为默认透明度
                                                              },
                                                              child:
                                                                  AnimatedOpacity(
                                                                      duration: const Duration(
                                                                          milliseconds:
                                                                              200),
                                                                      opacity:
                                                                          _iconOpacity3, // 这里使用一个变量来控制图标的透明度
                                                                      child:
                                                                          IconButton(
                                                                        onPressed:
                                                                            () {}, // 下一话功能
                                                                        icon: const Icon(
                                                                            CupertinoIcons
                                                                                .forward_fill,
                                                                            color:
                                                                                Colors.white),
                                                                        iconSize:
                                                                            25.0,
                                                                        padding:
                                                                            EdgeInsets.zero,
                                                                      ))),
                                                          const SizedBox(
                                                              width:
                                                                  0), // 调整按钮间距
                                                          MouseRegion(
                                                              onEnter: (_) {
                                                                _handleMouseHover4(
                                                                    true); // 鼠标进入时，设置为完全不透明
                                                              },
                                                              onExit: (_) {
                                                                _handleMouseHover4(
                                                                    false); // 鼠标离开时，恢复为默认透明度
                                                              },
                                                              child:
                                                                  AnimatedOpacity(
                                                                      duration: const Duration(
                                                                          milliseconds:
                                                                              200),
                                                                      opacity:
                                                                          _iconOpacity4, // 这里使用一个变量来控制图标的透明度
                                                                      child:
                                                                          IconButton(
                                                                        onPressed:
                                                                            _showVolumeDialog,
                                                                        icon: const Icon(
                                                                            CupertinoIcons
                                                                                .speaker_3_fill,
                                                                            color:
                                                                                Colors.white),
                                                                        iconSize:
                                                                            25.0,
                                                                        padding:
                                                                            EdgeInsets.zero,
                                                                      ))),
                                                          Expanded(
                                                            child: Stack(
                                                              children: [
                                                                ClipRRect(
                                                                  borderRadius:
                                                                      const BorderRadius
                                                                          .all(
                                                                          Radius.circular(
                                                                              2.0)),
                                                                  child:
                                                                      ProgressBar(
                                                                    progress: Duration(
                                                                        milliseconds: _controller!
                                                                            .value
                                                                            .position
                                                                            .inMilliseconds),
                                                                    buffered: const Duration(
                                                                        milliseconds:
                                                                            2000),
                                                                    total: Duration(
                                                                        milliseconds: _controller!
                                                                            .value
                                                                            .duration
                                                                            .inMilliseconds),
                                                                    progressBarColor: const Color
                                                                            .fromARGB(
                                                                            255,
                                                                            255,
                                                                            255,
                                                                            255)
                                                                        .withOpacity(
                                                                            0.5),
                                                                    baseBarColor: const Color
                                                                            .fromARGB(
                                                                            255,
                                                                            216,
                                                                            216,
                                                                            216)
                                                                        .withOpacity(
                                                                            0.3),
                                                                    bufferedBarColor: Colors
                                                                        .white
                                                                        .withOpacity(
                                                                            0.24),
                                                                    thumbColor:
                                                                        Colors
                                                                            .white,
                                                                    barHeight:
                                                                        4.5,
                                                                    thumbRadius:
                                                                        9,
                                                                    thumbGlowRadius:
                                                                        8,
                                                                    thumbGlowColor: Colors
                                                                        .white
                                                                        .withOpacity(
                                                                            0.3),
                                                                    timeLabelLocation:
                                                                        TimeLabelLocation
                                                                            .none,
                                                                    onSeek:
                                                                        (duration) {
                                                                      if (kDebugMode) {
                                                                        print(
                                                                            'User selected a new time: $duration');
                                                                      }
                                                                      _controller!
                                                                          .seekTo(
                                                                              duration);
                                                                      _onSeekComplete();
                                                                      // videopos(
                                                                      //_controller!.value.position.inMilliseconds + _controller!.value.duration.inMilliseconds * videopos);
                                                                    },
                                                                  ),
                                                                ),
                                                                const Positioned(
                                                                  top: 0,
                                                                  bottom: 0,
                                                                  left: 0,
                                                                  right: 0,
                                                                  child: Center(
                                                                    child:
                                                                        SizedBox(
                                                                      width: 20,
                                                                      height:
                                                                          20,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          const SizedBox(
                                                              width:
                                                                  8), // 调整按钮间距
                                                          ValueListenableBuilder(
                                                            valueListenable:
                                                                _controller!,
                                                            builder: (context,
                                                                VideoPlayerValue
                                                                    value,
                                                                child) {
                                                              return Text(
                                                                '${_formatDuration(value.position)} / ${_formatDuration(value.duration)}',
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .white
                                                                        .withOpacity(
                                                                            0.5)),
                                                              );
                                                            },
                                                          ),
                                                          const SizedBox(
                                                              width:
                                                                  0), // 调整按钮间距
                                                          MouseRegion(
                                                              onEnter: (_) {
                                                                _handleMouseHover5(
                                                                    true); // 鼠标进入时，设置为完全不透明
                                                              },
                                                              onExit: (_) {
                                                                _handleMouseHover5(
                                                                    false); // 鼠标离开时，恢复为默认透明度
                                                              },
                                                              child:
                                                                  AnimatedOpacity(
                                                                      duration: const Duration(
                                                                          milliseconds:
                                                                              200),
                                                                      opacity:
                                                                          _iconOpacity5, // 这里使用一个变量来控制图标的透明度
                                                                      child:
                                                                          IconButton(
                                                                        onPressed:
                                                                            () async {
                                                                          if (isFullScreen) {
                                                                            isFullScreen =
                                                                                false;
                                                                            windowManager.setFullScreen(false);
                                                                            masteropac =
                                                                                1;
                                                                          } else {
                                                                            isFullScreen =
                                                                                true;
                                                                            windowManager.setFullScreen(true);
                                                                            masteropac =
                                                                                0;
                                                                          }
                                                                        }, // 全屏/窗口化功能
                                                                        icon:
                                                                            Icon(
                                                                          isFullScreen
                                                                              ? CupertinoIcons.fullscreen_exit
                                                                              : CupertinoIcons.fullscreen,
                                                                          color:
                                                                              Colors.white,
                                                                        ),
                                                                        iconSize:
                                                                            35.0,
                                                                        padding:
                                                                            EdgeInsets.zero,
                                                                      ))),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      )),
                                )
                              ],
                            ),
                          );
                        } else {
                          return const Center(
                              child: CircularProgressIndicator());
                        }
                      },
                    ),
            ),
          ),
        ),
        if (!isFullScreen)
          Positioned(
            top: 0,
            right: 0,
            child: isWinOrLin
                ? MouseRegion(
                    onEnter: (_) {
                      setState(() {
                        conop = true;
                      });
                    },
                    onExit: (_) {
                      setState(() {
                        conop = false;
                      });
                    },
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 150),
                      opacity: _iconOpacity6 * masteropac,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 1.5, horizontal: 3),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 255, 255, 255)
                              .withOpacity(0),
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: const Color.fromARGB(52, 0, 0, 0)
                                  .withOpacity(0.1),
                              offset: const Offset(2, 2),
                              blurRadius: 10,
                            ),
                            BoxShadow(
                              color: const Color.fromARGB(33, 0, 0, 0)
                                  .withOpacity(0.1),
                              offset: const Offset(-2, 2),
                              blurRadius: 10,
                            ),
                          ],
                        ),
                        child: Row(children: [
                          // Minimize Button
                          IconButton(
                            icon: const Icon(CupertinoIcons.minus,
                                color: Colors.white, size: 20),
                            onPressed: () {
                              windowManager.minimize();
                            },
                          ),
                          // Fullscreen Button
                          IconButton(
                            onPressed: () async {
                              isMaximized = await windowManager.isMaximized();
                              if (isMaximized) {
                                await windowManager.unmaximize();
                              } else {
                                await windowManager.maximize();
                              }
                              setState(() {
                                isMaximized = !isMaximized;
                              });
                            },
                            icon: Transform(
                              alignment: Alignment.center,
                              transform: Matrix4.rotationY(3.14159),
                              child: Icon(
                                isMaximized
                                    ? Ionicons.copy_outline
                                    : Ionicons.square_outline,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                          // Close Button
                          IconButton(
                            icon: const Icon(CupertinoIcons.clear,
                                color: Colors.white, size: 20),
                            onPressed: () {
                              windowManager.close();
                            },
                          )
                        ]),
                      ),
                    ),
                  )
                : const MouseRegion(),
          ),
      ]),
      floatingActionButton: _controller == null
          ? FloatingActionButton(
              onPressed: _pickVideo,
              child: const Icon(Icons.video_library),
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
                const Text('调整音量', style: TextStyle(color: Colors.black)),
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

  Future<void> _handleFileProcessingAndPostRequest(File file) async {
    try {
      final fileBytes = await file
          .openRead(0, 16 * 1024 * 1024)
          .fold<List<int>>(
              [], (previous, element) => previous..addAll(element));
      final fileHash = md5.convert(fileBytes).toString();
      final fileSize = await file.length();

      final tempController = VideoPlayerController.file(file);
      await tempController.initialize();
      final videoDuration = tempController.value.duration.inSeconds;

      final response = await Dio().post(
        'https://api.dandanplay.net/api/v2/match',
        options: Options(headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        }),
        data: jsonEncode({
          'fileName': file.path.split('/').last,
          'fileHash': fileHash,
          'fileSize': fileSize,
          'videoDuration': videoDuration,
          'matchMode': 'hashAndFileName',
        }),
      );

      if (response.statusCode == 200) {
        final jsonResponse = response.data;
        if (jsonResponse['isMatched'] == true) {
          final match = jsonResponse['matches'][0];
          anime = AnimeMatch(
            episodeId: match['episodeId'],
            animeId: match['animeId'],
            animeTitle: match['animeTitle'],
            episodeTitle: match['episodeTitle'],
          );
          await _fetchComments(anime.episodeId!);
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error: $e');
      }
    }
  }

  Future<void> _fetchComments(int episodeId) async {
    try {
      final response = await Dio().get(
          'https://api.dandanplay.net/api/v2/comment/$episodeId?withRelated=true&chConvert=1',
          options: Options(headers: {'Accept': 'application/json'}));
      if (response.statusCode == 200) {
        final List<dynamic> jsonResponse = response.data['comments'];
        danmakuList = jsonResponse.map((comment) {
          final List<String> pValues = comment['p'].split(',');
          String space;
          switch (pValues[1]) {
            case '1':
              space = 'scroll';
              break;
            case '5':
              space = 'top';
              break;
            case '4':
              space = 'bottom';
              break;
            default:
              space = 'scroll';
          }
          final int colorValue = int.parse(pValues[2]);
          final int red = (colorValue >> 16) & 0xFF;
          final int green = (colorValue >> 8) & 0xFF;
          final int blue = colorValue & 0xFF;
          return {
            'time': (double.parse(pValues[0]) * 1000).toInt(),
            'space': space,
            'color': 'rgb($red,$green,$blue)',
            'content': comment['m'],
          };
        }).toList();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading comments: $e');
      }
    }
    if (kDebugMode) {
      print('Formatted Comments: ${jsonEncode(danmakuList)}');
    }
  }

  void _startDanmakuTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(milliseconds: 200), (timer) {
      if (!_isPlaying) {
        timer.cancel();
        return;
      }
      _checkDanmaku();
    });
  }

  void _checkDanmaku() {
    final currentPosition = _controller!.value.position.inMilliseconds;
    const int timeWindow = 200; // 允许的时间误差
    final List<Map<String, dynamic>> currentDanmaku = danmakuList
        .where((danmaku) =>
            (currentPosition - danmaku['time']).abs() <= timeWindow)
        .toList();
    for (var danmaku in currentDanmaku) {
      final colorValues = danmaku['color']
          .replaceAll('rgb(', '')
          .replaceAll(')', '')
          .split(',')
          .map((s) => int.parse(s))
          .toList();
      final color =
          Color.fromARGB(255, colorValues[0], colorValues[1], colorValues[2]);
      final type = danmaku['space'] == 'scroll'
          ? DanmakuItemType.scroll
          : danmaku['space'] == 'top'
              ? DanmakuItemType.top
              : DanmakuItemType.bottom;

      final danmakuKey =
          '${danmaku['time']}-${danmaku['space']}-${danmaku['color']}-${danmaku['content']}';
      if (!displayedDanmaku.contains(danmakuKey)) {
        displayedDanmaku.add(danmakuKey);
        _controllerdanmaku.addDanmaku(
            DanmakuContentItem(danmaku['content'], color: color, type: type));
      }
    }
  }

  void _onVideoPositionChanged() {
    if (_controller!.value.isPlaying) {
      if (!_isPlaying) {
        setState(() {
          _isPlaying = true;
        });
        _startDanmakuTimer();
      }
    } else {
      if (_isPlaying) {
        setState(() {
          _isPlaying = false;
        });
        _timer?.cancel();
      }
    }
  }

  void _onSeekComplete() {
    _controllerdanmaku.clear();
    _controllerdanmaku.updateOption(DanmakuOption(fontSize: 30));
    displayedDanmaku.clear();
    _checkDanmaku();
  }

  void _loadVideoPosition() async {
    await Future.delayed(const Duration(milliseconds: 500));
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      int inMilliseconds = prefs.getInt(videofile ?? '') ?? 0;
      Duration duration = Duration(milliseconds: inMilliseconds);
      zentime = duration;
      _controller!.seekTo(zentime);
    });
  }

  void _pickVideo() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(type: FileType.video);
    if (result != null) {
      File file = File(result.files.single.path!);
      final fileName = file.path.split('/').last;
      if (Directory(file.path).existsSync() &&
          (file.path.endsWith('.mp4') || file.path.endsWith('.mkv'))) {
        file = File('${file.path}/$fileName');
      }
      await _handleFileProcessingAndPostRequest(file);
      if (_controller != null) {
        _controller!.removeListener(_onVideoPositionChanged);
        _controller = null;
      }
      _controller = VideoPlayerController.file(file);
      videofile = fileName;
      _initializeVideoPlayerFuture = _controller!.initialize();
      setState(() {
        windowManager.setFullScreen(false);
        _loadVideoPosition();
        _handleMouseHover6();
        _controller!.play();
        _isPlaying = true;
        _startDanmakuTimer();
      });
      _controller!.addListener(_onVideoPositionChanged);
    }
  }
}
