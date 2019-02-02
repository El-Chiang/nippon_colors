import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'pages/home_page.dart';

void main() {
  SystemChrome.setEnabledSystemUIOverlays([]); // 隐藏status bar
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    
    return MaterialApp(
      title: 'Nihon',
      initialRoute: '/',
      routes: <String, WidgetBuilder>{
        '/': (BuildContext context) =>  HomePage(),
      },
      // home: HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
