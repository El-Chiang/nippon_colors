import 'package:flutter/material.dart';
import '../models/nippon_color.dart';
import '../utils/utils.dart';

class ColorNameContainer extends StatefulWidget {
  final NipponColor color;
  final double ratio;

  ColorNameContainer({Key key, @required this.color, ratio})
      : ratio = ratio ?? 1,
        super(key: key);

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
    final double ratio = widget.ratio;

    final textStyle = TextStyle(color: createColorStyle(nipponColor.isLight()));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          cname,
          style: textStyle.copyWith(
              fontSize: 36 * ratio, fontFamily: 'Mincho', fontWeight: FontWeight.w200),
        ),
        SizedBox(height: 10 * ratio),
        Text(name,
            style: textStyle.copyWith(
              fontSize: 18 * ratio,
              fontWeight: FontWeight.w200,
            )),
      ],
    );
  }
}
