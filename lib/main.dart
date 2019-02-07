import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'pages/home_page.dart';
import 'models/nippon_color.dart';
import 'actions/event_actions.dart';

void main() async {
  SystemChrome.setEnabledSystemUIOverlays([]); // 隐藏status bar
  
  List<String> myFavorite = (await getAllFavorite()) ?? [];
  eventBus.fire(UpdateFavoriteColors(myFavorite));

  runApp(MyApp(myFavorite));
}

class MyApp extends StatelessWidget {
  final List<String> myFavorite;

  MyApp(this.myFavorite);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nihon',
      initialRoute: '/',
      routes: <String, WidgetBuilder>{
        '/': (BuildContext context) => HomePage(myFavorite: myFavorite),
      },
      // home: HomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
