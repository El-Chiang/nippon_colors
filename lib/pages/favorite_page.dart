import 'package:flutter/material.dart';
import 'palette_page.dart';
import '../models/nippon_color.dart';

class FavoritePage extends StatelessWidget {
  final List<NipponColor> favoriteColors;

  FavoritePage({@required this.favoriteColors});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemExtent: 110,
        itemCount: favoriteColors.length,
        itemBuilder: (context, index) {
          return ColorItem(nipponColor: favoriteColors[index]);
        },
      ),
    );
  }
}
