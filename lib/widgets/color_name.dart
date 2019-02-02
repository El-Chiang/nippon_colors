import 'package:flutter/material.dart';
import '../models/nippon_color.dart';
import '../utils/utils.dart';

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
    final textStyle = TextStyle(color: createColorStyle(nipponColor.isLight()));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Text(
          cname,
          style: textStyle.copyWith(
            fontSize: 36,
            fontFamily: 'Mincho',
          ),
        ),
        Text(name, style: textStyle.copyWith(fontSize: 14)),
      ],
    );
  }
}
