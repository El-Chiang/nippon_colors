import 'package:flutter/material.dart';
import 'package:event_bus/event_bus.dart';
import 'dart:math';

import '../utils/utils.dart';
import '../models/nippon_color.dart';
import '../widgets/color_name.dart';
import 'palette_page.dart';

EventBus eventBus = EventBus();

class UpdateColorEvent {
  int updatedIndex;
  NipponColor updatedColor;

  UpdateColorEvent(this.updatedIndex, this.updatedColor);
}

class SelectColorEvent {
  NipponColor selectedColor;
  bool active;

  SelectColorEvent(this.selectedColor, this.active);
}

class HomePage extends StatefulWidget {
  final NipponColor color;
  HomePage({Key key, this.color}) : super(key: key);

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
    debugPrint('init');
    setState(() {
      colors = allColors;
      colorCount = allColors.length;
      colorIndex = Random().nextInt(colorCount - 1); // 随机产生一个颜色编号
      nipponColor = NipponColor.fromMap(colors[colorIndex]); // 实例化NipponColor
    });
    eventBus.on<UpdateColorEvent>().listen((UpdateColorEvent data) {
      if (this.mounted) {
        setState(() {
          colorIndex = data.updatedIndex;
          nipponColor = data.updatedColor;
        });
      }
    });
    eventBus.on<SelectColorEvent>().listen((SelectColorEvent data) {});
  }

  // 点击屏幕事件
  void _handleTapScreen() {
    // 生成一个新的颜色并fire
    final int newIndex = Random().nextInt(colorCount - 1);
    final newColor = NipponColor.fromMap(colors[newIndex]);
    debugPrint('tap screen - new color: ${newColor.cname}');
    eventBus.fire(UpdateColorEvent(newIndex, newColor));
  }

  // 点击颜色名称事件
  void _handleTapName() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => PalettePage(colors: colors),
        maintainState: false,
      ),
      ModalRoute.withName('/'),
    );
  }

  @override
  Widget build(BuildContext context) {
    // setState(() {
    //   colorIndex = Random().nextInt(colorCount - 1); // 随机产生一个颜色编号
    //   nipponColor = NipponColor.fromMap(colors[colorIndex]); // 实例化NipponColor
    // });

    final Size screenSize = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: _handleTapScreen,
      child: Scaffold(
        backgroundColor: nipponColor.color,
        body: Column(
          children: <Widget>[
            Expanded(
              child: SizedBox(),
            ),
            Expanded(
              flex: 4, // 颜色名称离屏幕上边框的距离
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  GestureDetector(
                    child: ColorNameContainer(color: nipponColor), // 颜色名称
                    onTap: _handleTapName,
                  ),
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
