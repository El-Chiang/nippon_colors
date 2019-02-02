import 'package:flutter/material.dart';
import '../models/nippon_color.dart';

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

  // 如果颜色偏白则设置为黑色，反之则为白色
  Color createColorStyle(bool isLight) => isLight ? Colors.black : Colors.white;

  @override
  Widget build(BuildContext context) {
    nipponColor = widget.color;
    name = nipponColor.name;
    cname = nipponColor.cname;
    final textStyle = TextStyle(color: createColorStyle(nipponColor.isLight()));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Text(cname, style: textStyle.copyWith(fontSize: 36)),
        Text(name, style: textStyle.copyWith(fontSize: 14)),
      ],
    );
  }
}
