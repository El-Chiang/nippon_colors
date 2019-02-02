import 'package:flutter/material.dart';
import 'package:flutter_circular_chart/flutter_circular_chart.dart';
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
    final Size screenSize = MediaQuery.of(context).size;

    return GestureDetector(
      onTap: _handleTapScreen,
      child: Scaffold(
        backgroundColor: nipponColor.color,
        body: Column(
          children: <Widget>[
            Expanded(
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
            Expanded(
              flex: 4, // 颜色名称离屏幕上边框的距离
              child: Column(
                children: <Widget>[
                  RGBCircularChart(nipponColor),
                  CMYKCircularChart(nipponColor),
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
      setState(() => isLight = color.isLight());
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
          v1 =cmyk[0].toDouble();
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
      setState(() {
        _chartKey.currentState.updateData(nextData);
      });
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
          ),
          key: _chartKey,
          size: widget.chartSize,
          initialChartData: data,
          chartType: CircularChartType.Radial,
          edgeStyle: SegmentEdgeStyle.round,
          percentageValues: true,
        ),
        Text(
          // 显示数值
          widget.value.toString(),
          style: TextStyle(color: createColorStyle(isLight)),
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
    // 设置环形图大小为屏幕宽度的1/5
    final screenWidth = MediaQuery.of(context).size.width;
    final chartSize = Size(screenWidth / 8, screenWidth / 8);

    rgb = widget.color.getRGB();
    isLight = widget.color.isLight();

    return Row(
      children: <Widget>[
        // 竖线
        Container(
          height: chartSize.height * 2.8,
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
              ValueChart(
                label: 'G',
                value: rgb[1],
                chartSize: chartSize,
                isLight: isLight,
              ),
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
    // 设置环形图大小为屏幕宽度的1/5
    final screenWidth = MediaQuery.of(context).size.width;
    final chartSize = Size(screenWidth / 8, screenWidth / 8);

    cmyk = widget.color.getCMYK();
    isLight = widget.color.isLight();

    return Row(
      children: <Widget>[
        // 竖线
        Container(
          height: chartSize.height * 2.8,
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
              ValueChart(
                label: 'M',
                value: cmyk[1],
                chartSize: chartSize,
                isLight: isLight,
              ),
              ValueChart(
                label: 'Y',
                value: cmyk[2],
                chartSize: chartSize,
                isLight: isLight,
              ),
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
