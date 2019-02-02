import 'package:flutter/material.dart';
import 'dart:math';

import '../utils/utils.dart';
import '../models/nippon_color.dart';

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> colors;
  int colorCount;
  int colorIndex;
  NipponColor nipponColor;

  void initState() {
    super.initState();
    setState(() {
      colors = allColors;
      colorCount = allColors.length;
    });
  }

  void _handleTap() {
    setState(() {
      colorIndex = Random().nextInt(colorCount - 1);
      nipponColor = NipponColor.fromMap(colors[colorIndex]);
    });
  }

  @override
  Widget build(BuildContext context) {
    setState(() {
     colorIndex = Random().nextInt(colorCount - 1); // 随机产生一个颜色编号
     nipponColor = NipponColor.fromMap(colors[colorIndex]); // 实例化NipponColor
    });

    return GestureDetector(
      onTap: _handleTap,
      child: Scaffold(
        backgroundColor: nipponColor.color,
      ),
    );
  }
}