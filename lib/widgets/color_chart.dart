import 'package:flutter/material.dart';
import 'package:flutter_circular_chart/flutter_circular_chart.dart';

import '../models/nippon_color.dart';
import '../actions/event_actions.dart';
import '../utils/utils.dart';

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
  final double ratio;

  RGBCircularChart({this.color, ratio}) : ratio = ratio ?? 1;

  @override
  State<StatefulWidget> createState() => _RGBCircularState();
}

class _RGBCircularState extends State<RGBCircularChart> {
  List<int> rgb;
  bool isLight;

  @override
  Widget build(BuildContext context) {
    // 设置环形图大小为屏幕宽度的0.12
    final ratio = widget.ratio;
    final screenWidth = MediaQuery.of(context).size.width*ratio;
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
  final double ratio;

  CMYKCircularChart({this.color, ratio}) : ratio = ratio ?? 1;

  @override
  State<StatefulWidget> createState() => _CMYKCircularState();
}

class _CMYKCircularState extends State<CMYKCircularChart> {
  List<int> cmyk;
  bool isLight;

  @override
  Widget build(BuildContext context) {
    // 设置环形图大小为屏幕宽度的0.12
    final double ratio = widget.ratio;
    final screenWidth = MediaQuery.of(context).size.width * ratio;
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
