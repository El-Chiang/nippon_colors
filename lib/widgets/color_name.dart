import 'package:flutter/material.dart';
import '../models/nippon_color.dart';
import '../utils/utils.dart';

class ColorNameContainer extends StatefulWidget {
  final NipponColor color;
  final double ratio; // 比例
  final bool showAnimation; // 是否显示动画

  ColorNameContainer({Key key, @required this.color, ratio, @required this.showAnimation})
      : ratio = ratio ?? 1,
        super(key: key);

  @override
  State<StatefulWidget> createState() => ColorNameState();
}

class ColorNameState extends State<ColorNameContainer> with SingleTickerProviderStateMixin {
  String name;
  String cname;
  NipponColor nipponColor;

  AnimationController _nameController;
  Animation<double> _nameAnimation;

  @override
  void initState() {
    super.initState(); // super.initState()必须放在最开头才会显示动画
    if (widget.showAnimation) {
      _nameController =AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _nameAnimation = Tween<double>(begin: 0, end: 1)
      .animate(_nameController)
      ..addListener(() {
        setState((){});
      });
    _nameController.forward();
    }
  }

  @override
  dispose() {
    if (widget.showAnimation) _nameController.dispose();
    super.dispose();
  }

  void updateOpacity() {
    _nameController.reset();
    _nameController.forward();
  }

  @override
  Widget build(BuildContext context) {
    nipponColor = widget.color;
    name = nipponColor.name;
    cname = nipponColor.cname;
    final double ratio = widget.ratio; 
    final textStyle = TextStyle(color: createColorStyle(nipponColor.isLight()));
    
    return Opacity(
      opacity: widget.showAnimation ? _nameAnimation.value : 1,
      child: Column(
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
      ),
    );
  }
}
