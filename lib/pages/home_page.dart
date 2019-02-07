import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_circular_chart/flutter_circular_chart.dart';
import 'dart:math';

import '../utils/utils.dart';
import '../actions/event_actions.dart';
import '../models/nippon_color.dart';
import '../widgets/color_name.dart';
import 'palette_page.dart';
import 'favorite_page.dart';

class HomePage extends StatefulWidget {
  final NipponColor color;
  final List<String> myFavorite;

  HomePage({Key key, this.color, this.myFavorite}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> colors; // 所有日本传统色
  List<String> allFavorite; // 所有用户喜欢的颜色
  int colorCount;
  int colorIndex;
  NipponColor nipponColor;

  /// 初始化状态并绑定监听事件
  void initState() {
    super.initState();
    if (this.mounted) {
      setState(() {
        colors = allColors;
        colorCount = allColors.length;
        allFavorite = widget.myFavorite;
        colorIndex = Random().nextInt(colorCount - 1); // 随机产生一个颜色编号
        nipponColor = NipponColor.fromMap(colors[colorIndex]); // 实例化NipponColor
      });
    }
    // 当颜色改变时更新状态
    eventBus.on<UpdateColorEvent>().listen((UpdateColorEvent data) {
      if (this.mounted) {
        setState(() {
          colorIndex = data.updatedIndex;
          nipponColor = data.updatedColor;
        });
      }
    });
    // 当用户选择一个颜色时更新状态
    eventBus.on<SelectColorEvent>().listen((SelectColorEvent data) {});
    // 当用户标记一个喜欢的颜色时更新状态
    eventBus.on<UpdateFavoriteColors>().listen((UpdateFavoriteColors data) {
      if (this.mounted) setState(() => allFavorite = data.favoriteColors);
    });
  }

  /// 点击屏幕事件 -> 随机产生一个新的颜色
  void _handleTapScreen() {
    final int newIndex = Random().nextInt(colorCount - 1);
    final newColor = NipponColor.fromMap(colors[newIndex]);
    eventBus.fire(UpdateColorEvent(newIndex, newColor));
  }

  /// 点击颜色名称事件 -> 跳转到调色板界面显示所有颜色
  void _handleTapName() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => PalettePage(colors: colors, index: colorIndex),
        maintainState: false,
      ),
      ModalRoute.withName('/'),
    );
  }

  /// 点击“标记喜欢”事件
  void _markAsFavorite() async {
    List<String> myFavorite = await nipponColor.saveToFavorite();
    eventBus.fire(UpdateFavoriteColors(myFavorite));
    Navigator.pop(context);
  }

  /// 点击“取消喜欢”事件
  void _cancelFavorite() async {
    List<String> myFavorite = await nipponColor.cancelFavorite();
    eventBus.fire(UpdateFavoriteColors(myFavorite));
    Navigator.pop(context);
  }

  /// 点击“我喜欢的”事件
  void _getMyFavorite() async {
    List<NipponColor> favoriteColors = allFavorite.map((favoriteId) {
      int index = int.parse(favoriteId) - 1; // 因为id从1开始所以实际列表中的index要-1
      return NipponColor.fromMap(colors[index]);
    }).toList();
    debugPrint(favoriteColors.toString());
    Navigator.pop(context); // 先关闭dialog再push
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FavoritePage(favoriteColors: favoriteColors),
      ),
    );
  }

  /// 点击树枝 -> 弹出菜单dialog
  void _handleTapBranch() {
    debugPrint(allFavorite.length.toString());
    bool isFavorite;
    if (allFavorite.contains(nipponColor.id.toString()))
      isFavorite = true; // 当isFavorite为true显示“取消喜欢”
    else
      isFavorite = false; // 当isFavorite为false显示“标记喜欢”
    showCupertinoDialog(
      context: context,
      builder: (context) { // 当用户没有任何喜欢颜色时隐藏“我喜欢的”入口
        if (allFavorite.length == 0) {
          return CupertinoAlertDialog(
            actions: <Widget>[
              isFavorite
                  ? CupertinoDialogAction(
                      child: Text(
                        '😪取消喜欢',
                        style: TextStyle(color: Colors.black),
                      ),
                      onPressed: _cancelFavorite,
                    )
                  : CupertinoDialogAction(
                      child: Text(
                        '🌟标记喜欢',
                        style: TextStyle(color: Colors.black),
                      ),
                      onPressed: _markAsFavorite,
                    ),
              CupertinoDialogAction(
                child: Text('📲生成图片', style: TextStyle(color: Colors.black)),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              CupertinoDialogAction(
                child: Text('❓使用提示', style: TextStyle(color: Colors.black)),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              CupertinoDialogAction(
                child: const Text('返回'),
                isDefaultAction: true,
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        } else {
          return CupertinoAlertDialog(
            actions: <Widget>[
              isFavorite
                  ? CupertinoDialogAction(
                      child: Text(
                        '😪取消喜欢',
                        style: TextStyle(color: Colors.black),
                      ),
                      onPressed: _cancelFavorite,
                    )
                  : CupertinoDialogAction(
                      child: Text(
                        '🌟标记喜欢',
                        style: TextStyle(color: Colors.black),
                      ),
                      onPressed: _markAsFavorite,
                    ),
              CupertinoDialogAction(
                child: Text('🌠我喜欢的', style: TextStyle(color: Colors.black)),
                onPressed: _getMyFavorite,
              ),
              CupertinoDialogAction(
                child: Text('📲生成图片', style: TextStyle(color: Colors.black)),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              CupertinoDialogAction(
                child: Text('❓使用提示', style: TextStyle(color: Colors.black)),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
              CupertinoDialogAction(
                child: const Text('返回'),
                isDefaultAction: true,
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double divideH = screenSize.width * 0.012;
    return GestureDetector(
      onTap: _handleTapScreen,
      child: Scaffold(
        backgroundColor: nipponColor.color,
        body: Column(
          children: <Widget>[
            SizedBox(height: screenSize.height * 0.15), // 颜色名称离屏幕上边框的距离
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                GestureDetector(
                  child: ColorNameContainer(color: nipponColor), // 颜色名称
                  onTap: _handleTapName,
                ),
                SizedBox(width: screenSize.width * 0.05), // 颜色名称离屏幕右边框的距离
              ],
            ),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  GestureDetector(
                    child: Container(
                      width: 30,
                      child: Image.asset(
                        'assets/images/branch.png', // 树枝图片
                        fit: BoxFit.fitWidth,
                        color: createColorStyle(nipponColor.isLight()),
                      ),
                    ),
                    onTap: _handleTapBranch,
                  ),
                  SizedBox(height: divideH),
                  RGBCircularChart(nipponColor), // RGB环状图
                  SizedBox(height: divideH),
                  CMYKCircularChart(nipponColor), // CMYK环状图
                  Container(
                    // Hex值
                    padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                    child: Text(
                      '#${nipponColor.hex}',
                      style: TextStyle(
                        color: createColorStyle(nipponColor.isLight()),
                        fontSize: 16,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 根据数据显示环状图
class ValueChart extends StatefulWidget {
  final String label; // 显示文字
  final int value; // 数据值
  final bool isLight; // 当前背景是否偏白
  final Size chartSize;

  ValueChart({Key key, this.label, this.value, this.isLight, this.chartSize})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _ValueChartState();
}

class _ValueChartState extends State<ValueChart> {
  final _chartKey = GlobalKey<AnimatedCircularChartState>();
  bool isLight;

  double v1, v2;

  void initState() {
    super.initState();
    eventBus.on<UpdateColorEvent>().listen((UpdateColorEvent data) {
      NipponColor color = data.updatedColor;
      if (this.mounted) setState(() => isLight = color.isLight());
      List rgb = color.getRGB();
      List cmyk = color.getCMYK();
      double v1, v2;

      switch (widget.label) {
        case 'R':
          v1 = rgb[0] / 255 * 100;
          break;
        case 'G':
          v1 = rgb[1] / 255 * 100;
          break;
        case 'B':
          v1 = rgb[2] / 255 * 100;
          break;
        case 'C':
          v1 = cmyk[0].toDouble();
          break;
        case 'M':
          v1 = cmyk[1].toDouble();
          break;
        case 'Y':
          v1 = cmyk[2].toDouble();
          break;
        case 'K':
          v1 = cmyk[3].toDouble();
          break;
      }
      v2 = 100 - v1;
      List<CircularStackEntry> nextData = <CircularStackEntry>[
        CircularStackEntry(
          <CircularSegmentEntry>[
            CircularSegmentEntry(
              v1, // 数值
              createColorStyle(isLight),
              rankKey: 'value',
            ),
            CircularSegmentEntry(
              v2, // 数值
              createColorStyle(isLight).withOpacity(0.3),
              rankKey: 'remaining',
            ),
          ],
        ),
      ];
      if (this.mounted)
        setState(() => _chartKey.currentState.updateData(nextData));
    });
  }

  @override
  Widget build(BuildContext context) {
    // 转换为百分比的分子
    v1 = widget.value / 255 * 100;
    v2 = 100 - v1;

    isLight = widget.isLight;

    List<CircularStackEntry> data = <CircularStackEntry>[
      CircularStackEntry(
        <CircularSegmentEntry>[
          CircularSegmentEntry(
            v1, // 数值
            createColorStyle(widget.isLight),
            rankKey: 'value',
          ),
          CircularSegmentEntry(
            v2, // 数值
            createColorStyle(widget.isLight).withOpacity(0.3),
            rankKey: 'remaining',
          ),
        ],
      ),
    ];

    return Row(
      children: <Widget>[
        AnimatedCircularChart(
          holeLabel: widget.label, // 显示label
          labelStyle: TextStyle(
            fontSize: widget.chartSize.width * 0.5,
            color: createColorStyle(isLight), // 动态创建黑白字体颜色
            fontWeight: FontWeight.w300,
          ),
          key: _chartKey,
          size: widget.chartSize,
          initialChartData: data,
          chartType: CircularChartType.Radial,
          edgeStyle: SegmentEdgeStyle.round,
          percentageValues: true,
        ),
        SizedBox(width: widget.chartSize.width * 0.1),
        Text(
          // 显示数值
          widget.value.toString(),
          style: TextStyle(
            color: createColorStyle(isLight),
            fontSize: widget.chartSize.width * 0.3,
            fontWeight: FontWeight.w300,
          ),
        ),
      ],
    );
  }
}

class RGBCircularChart extends StatefulWidget {
  final NipponColor color;

  RGBCircularChart(this.color);

  @override
  State<StatefulWidget> createState() => _RGBCircularState();
}

class _RGBCircularState extends State<RGBCircularChart> {
  List<int> rgb;
  bool isLight;

  @override
  Widget build(BuildContext context) {
    // 设置环形图大小为屏幕宽度的0.12
    final screenWidth = MediaQuery.of(context).size.width;
    final chartSize = Size(screenWidth * 0.12, screenWidth * 0.12);
    final double divideH = chartSize.width * 0.1;

    rgb = widget.color.getRGB();
    isLight = widget.color.isLight();

    return Row(
      children: <Widget>[
        // 竖线
        Container(
          height: chartSize.height * 3,
          width: 1.0,
          color: createColorStyle(isLight),
          margin: const EdgeInsets.only(left: 10.0, right: 8.0),
        ),
        Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ValueChart(
                label: 'R',
                value: rgb[0],
                chartSize: chartSize,
                isLight: isLight,
              ),
              SizedBox(height: divideH),
              ValueChart(
                label: 'G',
                value: rgb[1],
                chartSize: chartSize,
                isLight: isLight,
              ),
              SizedBox(height: divideH),
              ValueChart(
                label: 'B',
                value: rgb[2],
                chartSize: chartSize,
                isLight: isLight,
              )
            ],
          ),
        ),
      ],
    );
  }
}

class CMYKCircularChart extends StatefulWidget {
  final NipponColor color;

  CMYKCircularChart(this.color);

  @override
  State<StatefulWidget> createState() => _CMYKCircularState();
}

class _CMYKCircularState extends State<CMYKCircularChart> {
  List<int> cmyk;
  bool isLight;

  @override
  Widget build(BuildContext context) {
    // 设置环形图大小为屏幕宽度的0.12
    final screenWidth = MediaQuery.of(context).size.width;
    final chartSize = Size(screenWidth * 0.12, screenWidth * 0.12);
    final double divideH = chartSize.width * 0.1;

    cmyk = widget.color.getCMYK();
    isLight = widget.color.isLight();

    return Row(
      children: <Widget>[
        // 竖线
        Container(
          height: chartSize.height * 4,
          width: 1.0,
          color: createColorStyle(isLight),
          margin: const EdgeInsets.only(left: 10.0, right: 8.0),
        ),
        Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ValueChart(
                label: 'C',
                value: cmyk[0],
                chartSize: chartSize,
                isLight: isLight,
              ),
              SizedBox(height: divideH),
              ValueChart(
                label: 'M',
                value: cmyk[1],
                chartSize: chartSize,
                isLight: isLight,
              ),
              SizedBox(height: divideH),
              ValueChart(
                label: 'Y',
                value: cmyk[2],
                chartSize: chartSize,
                isLight: isLight,
              ),
              SizedBox(height: divideH),
              ValueChart(
                label: 'K',
                value: cmyk[3],
                chartSize: chartSize,
                isLight: isLight,
              )
            ],
          ),
        ),
      ],
    );
  }
}
