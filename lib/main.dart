import 'package:flutter/material.dart';
import 'screens/timer_screen.dart';

void main() {
  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.dumpErrorToConsole(details);
    // アプリを再起動する
    _restartApp();
  };
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Life timer',
      theme: ThemeData(
        primaryColor: Colors.black45,
        scaffoldBackgroundColor: Colors.grey[200], // 背景色をより暗いグレーに設定
        appBarTheme: const AppBarTheme(
          color: Colors.black45, // アプリバーの色もグレーに合わせる
        ),
      ),
      home: const TimerScreen(),
    );
  }
}

void _restartApp() {
  runApp(const MyApp());
}
