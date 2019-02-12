import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../models/nippon_color.dart';
import '../widgets/color_name.dart';
import '../actions/event_actions.dart';

/// 颜色条
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
        child: ColorNameContainer(color: nipponColor),
        padding: EdgeInsets.only(right: screenSize.width * 0.05),
        color: nipponColor.color,
      ),
    );
  }
}

/// 调色板页面
class PalettePage extends StatefulWidget {
  final List<Map<String, dynamic>> colors;
  final int index;

  PalettePage({Key key, @required this.colors, index})
      : this.index = index ?? 0,
        super(key: key);

  @override
  State<StatefulWidget> createState() => _PaletteState();
}

/// 调色板状态
class _PaletteState extends State<PalettePage> {
  ScrollController _controller; // 滚动控制
  bool _isVisibled; // ColorBar是否可见
  int _index;
  static const double kItemExtent = 120;

  _scrollListener() {
    // 向上滚动可见
    if (_controller.position.userScrollDirection == ScrollDirection.reverse) {
      setState(() => _isVisibled = true);
    }
    // 向下滚动隐藏
    if (_controller.position.userScrollDirection == ScrollDirection.forward) {
      setState(() => _isVisibled = false);
    }
  }

  @override
  void initState() {
    _index = widget.index;
    _isVisibled = false; // 初始化ColorBar是否可见
    // 初始化滚动控制器并添加滚动监听
    _controller = ScrollController(
      initialScrollOffset: kItemExtent * (widget.index - 3),
    );
    _controller.addListener(_scrollListener);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> colors = widget.colors;
    final double screenWidth = MediaQuery.of(context).size.width;
    List<Widget> colorNavigator = [];
    colorNavigator.addAll(
      colors.map((data) {
        NipponColor nipponColor = NipponColor.fromMap(data);
        return Expanded(
          child: Container(color: nipponColor.color),
        );
      }),
    );

    return Scaffold(
      body: ListView.builder(
        controller: _controller,
        itemExtent: kItemExtent,
        itemCount: colors.length - 1,
        itemBuilder: (context, index) {
          NipponColor color = NipponColor.fromMap(colors[index]);
          return ColorItem(nipponColor: color);
        },
      ),
      bottomNavigationBar: _isVisibled
          ? SizedBox()
          : Container(
              height: 36,
              padding: EdgeInsets.symmetric(horizontal: 10),
              color: Colors.grey[100],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  // Icon Button
                  GestureDetector(
                    child: Container(
                      width: 30,
                      child: Image.asset(
                        'assets/images/1024PNG.png',
                        fit: BoxFit.fitWidth,
                        color: Colors.grey[900],
                      ),
                    ),
                    onTap: () => Navigator.pop(context),
                  ),
                  // Color Bar
                  Container(
                    height: 30,
                    width: screenWidth * 0.6,
                    child: GestureDetector(
                      child: Row(children: colorNavigator),
                      onPanStart: (DragStartDetails details) {
                        double nowPosition = details.globalPosition.dx;
                        double distance = nowPosition - screenWidth * 0.4 + 10;
                        int index =
                            (distance / (screenWidth * 0.6) * 451).round();
                        _controller.animateTo(
                          kItemExtent * (index - 3),
                          curve: Curves.linear,
                          duration: Duration(
                              milliseconds: 200 + (index - _index).abs()),
                        );
                        setState(() => _index = index);
                      },
                      onPanUpdate: (DragUpdateDetails details) {
                        double nowPosition = details.globalPosition.dx;
                        double distance = nowPosition - screenWidth * 0.4 + 10;
                        int index =
                            (distance / (screenWidth * 0.6) * 451).round();
                        _controller.animateTo(
                          kItemExtent * (index - 3),
                          curve: Curves.linear,
                          duration: Duration(
                              milliseconds: 200 + (index - _index).abs()),
                        );
                        setState(() => _index = index);
                      },
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
