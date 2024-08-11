import 'dart:ui';

import 'package:fnipaplay/danmaku/lib/canvas_danmaku.dart';
// ignore: depend_on_referenced_packages
import 'package:video_player/video_player.dart';
import 'package:fnipaplay/videos.dart';
import 'package:flutter/material.dart';
double _iconOpacity7 = 0.5;
void _handleMouseHover7(bool isHovering) {
  _iconOpacity7 = isHovering ? 1.0 : 0.5;
}

class DanmakuControl extends StatelessWidget {
  final VideoPlayerController controller;
  // ignore: non_constant_identifier_names
  // ignore: prefer_typing_uninitialized_variables, non_constant_identifier_names
  final double IconOpacity6;
  final Function(DanmakuController) onControllerCreated; // 新增回调

  const DanmakuControl({
    super.key,
    required this.controller,
    // ignore: non_constant_identifier_names
    required this.IconOpacity6,
    required this.onControllerCreated, // 接收回调
  });
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // 弹幕组件
        DanmakuScreen(
          createdController: (DanmakuController e) {
            onControllerCreated(e);
          },
          option: DanmakuOption(
            fontSize: 30,
          ),
        ),
        Positioned(
          top: 45,
          left: 0,
          child: MouseRegion(
              onEnter: (_) {
                conop = true;
              },
              onExit: (_) {
                conop = false;
              },
              child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 150),
                  opacity: IconOpacity6,
                  child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 5, horizontal: 6),
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
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(5),
                          child: Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 5, horizontal: 10),
                              child: BackdropFilter(
                                  filter:
                                      ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                                  child: MouseRegion(
                                      onEnter: (_) {
                                        _handleMouseHover7(
                                            true); // 鼠标进入时，设置为完全不透明
                                      },
                                      onExit: (_) {
                                        _handleMouseHover7(
                                            false); // 鼠标离开时，恢复为默认透明度
                                      },
                                      child: AnimatedOpacity(
                                        duration:
                                            const Duration(milliseconds: 200),
                                        opacity: _iconOpacity7,
                                        child: Text(
                                          '${anime.animeTitle ?? ''} ${anime.episodeTitle ?? ''}',
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 15),
                                        ),
                                      )))))))),
        ),
      ],
    );
  }
}
