import 'package:flutter/material.dart';

import '../models/nippon_color.dart';
import '../widgets/color_name.dart';
import '../actions/event_actions.dart';

// 颜色条
class ColorItem extends StatelessWidget {
  final NipponColor nipponColor;

  const ColorItem({Key key, @required this.nipponColor}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    // 点击相应颜色
    void handleTapItem() {
      debugPrint('tap item ${nipponColor.cname}');
      eventBus.fire(UpdateColorEvent(nipponColor.id - 1, nipponColor));
      Navigator.pop(context);
    }

    return GestureDetector(
      onTap: handleTapItem,
      child: Container(
        color: nipponColor.color,
        padding: EdgeInsets.symmetric(vertical: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            ColorNameContainer(color: nipponColor),
            SizedBox(width: screenSize.width * 0.05),
          ],
        ),
      ),
    );
  }
}

// 调色板页面
class PalettePage extends StatelessWidget {
  final List<Map<String, dynamic>> colors;
  final int index;

  PalettePage({@required this.colors, index}) : this.index = index ?? 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
          // 设置ListView偏移量
          controller: ScrollController(
            // 用index-3代替index为了让当前颜色在屏幕中间显示
            initialScrollOffset: 100.0 * (index - 3),
          ),
          itemExtent: 110,
          itemCount: colors.length - 1,
          itemBuilder: (context, index) {
            NipponColor color = NipponColor.fromMap(colors[index]);
            return ColorItem(nipponColor: color);
          }),
    );
  }
}
