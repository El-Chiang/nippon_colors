import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'pages/home_page.dart';

void main() {
  SystemChrome.setEnabledSystemUIOverlays([]); // 隐藏status bar
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nihon',
      home: HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(),
    );
  }
}
