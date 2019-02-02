import 'package:flutter/material.dart';

import '../models/nippon_color.dart';
import '../widgets/color_name.dart';
import 'home_page.dart';

// 颜色条
class ColorItem extends StatelessWidget {
  final NipponColor nipponColor;

  const ColorItem({Key key, @required this.nipponColor}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    void handleTapItem() {
      debugPrint('tap item ${nipponColor.cname}');
      eventBus.fire(UpdateColorEvent(nipponColor.id - 1, nipponColor));
      // Navigator.pushAndRemoveUntil(
      //   context,
      //   MaterialPageRoute(
      //     builder: (context) => HomePage(),
      //     maintainState: false,
      //   ),
      //   ModalRoute.withName('/'),
      // );
      Navigator.pop(context);
    }
    return GestureDetector(
      onTap: handleTapItem,
      child: Container(
        color: nipponColor.color,
        padding: EdgeInsets.symmetric(vertical: 16),
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

  PalettePage({@required this.colors});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
          itemCount: colors.length - 1,
          itemBuilder: (context, index) {
            NipponColor color = NipponColor.fromMap(colors[index]);
            return ColorItem(nipponColor: color);
          }),
    );
  }
}
