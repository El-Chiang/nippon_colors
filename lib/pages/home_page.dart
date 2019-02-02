import 'package:flutter/material.dart';
import 'package:event_bus/event_bus.dart';
import 'dart:math';

import '../utils/utils.dart';
import '../models/nippon_color.dart';

EventBus eventBus = EventBus();

class UpdateColorEvent {
  int updatedIndex;
  NipponColor updatedColor;

  UpdateColorEvent(this.updatedIndex, this.updatedColor);
}

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
    eventBus.on<UpdateColorEvent>().listen((UpdateColorEvent data) {
      if (this.mounted) {
        setState(() {
          colorIndex = data.updatedIndex;
          nipponColor = data.updatedColor;
        });
      }
    });
  }

  void _handleTap() {
    final int newIndex = Random().nextInt(colorCount - 1);
    final newColor = NipponColor.fromMap(colors[newIndex]);
    eventBus.fire(UpdateColorEvent(newIndex, newColor));
  }

  @override
  Widget build(BuildContext context) {
    setState(() {
      colorIndex = Random().nextInt(colorCount - 1); // 随机产生一个颜色编号
      nipponColor = NipponColor.fromMap(colors[colorIndex]); // 实例化NipponColor
    });

    final Size screenSize = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: _handleTap,
      child: Scaffold(
        backgroundColor: nipponColor.color,
        body: Column(
          children: <Widget>[
            Expanded(
              child: SizedBox(),
            ),
            Expanded(
              flex: 3, // 颜色名称离屏幕上边框的距离
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  ColorNameContainer(color: nipponColor),
                  SizedBox(width: screenSize.width * 0.05), // 颜色名称离屏幕右边框的距离
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 颜色名称组件
class ColorNameContainer extends StatefulWidget {
  final NipponColor color;

  ColorNameContainer({Key key, @required this.color}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ColorNameState();
}

class _ColorNameState extends State<ColorNameContainer> {
  String name;
  String cname;
  NipponColor nipponColor;

  @override
  Widget build(BuildContext context) {
    nipponColor = widget.color;
    name = nipponColor.name;
    cname = nipponColor.cname;
    var textStyle = TextStyle(color: createColorStyle(nipponColor.isLight()));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Text(cname, style: textStyle.copyWith(fontSize: 36)),
        Text(name, style: textStyle),
      ],
    );
  }
}

// 如果颜色偏白则设置为黑色，反之则为白色
Color createColorStyle(bool isLight) => isLight ? Colors.black : Colors.white;
