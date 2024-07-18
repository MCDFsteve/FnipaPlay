import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
// ignore: depend_on_referenced_packages
import 'package:fvp/fvp.dart';
// ignore: depend_on_referenced_packages
import 'package:fnipaplay/videos.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  WindowOptions windowOptions = const WindowOptions(
    //size: Size(800, 600),
    center: true,
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.hidden,
    title: "FnipaPlay播放视图",
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    //await windowManager.setIcon('lib/icon.png');
    await windowManager.show();
    await windowManager.focus();
    await windowManager.maximize();
  });
  registerWith(options: {'platforms': ['windows', 'macos', 'linux']});
  runApp(const FnipaPlay());
}
