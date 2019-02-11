import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:image_picker_saver/image_picker_saver.dart';

import '../models/nippon_color.dart';
import '../utils/utils.dart';
import '../widgets/color_name.dart';
import '../widgets/color_chart.dart';

/// 图片分页预览
class _ImageSelector extends StatelessWidget {
  final List<GenerateImage> images; // 生成图片列表
  final NipponColor nipponColor;

  const _ImageSelector({this.images, this.nipponColor});

  /// 点击保存按钮
  void _onTapSave(int index) async {
    final Uint8List imgBytes = await images[index].toImage(); // 生成相应图片
    await ImagePickerSaver.saveFile(fileData: imgBytes); // 保存到相册
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final TabController controller = DefaultTabController.of(context);
    print('page: ${controller.index}');
    return Column(
      children: <Widget>[
        // 图片预览
        Expanded(
          child: IconTheme(
            data: IconThemeData(
              size: 128,
              color: nipponColor.color,
            ),
            child: TabBarView(
              children: images.map<Widget>((image) {
                return Align(
                  alignment: Alignment.bottomCenter,
                  child: Card(
                    color: nipponColor.color,
                    child: Container(
                      margin: EdgeInsets.all(6),
                      child: image,
                    ),
                    margin: EdgeInsets.only(bottom: 12.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        // 分页条
        TabPageSelector(
          controller: controller,
          indicatorSize: 8.0,
          selectedColor: nipponColor.color,
        ),
        // 底部图标
        Container(
          padding: EdgeInsets.only(top: screenSize.height * 0.1, bottom: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              Icon(Icons.tag_faces),
              Row(
                children: <Widget>[
                  // 使用帮助
                  GestureDetector(
                    child: Icon(Icons.help, color: nipponColor.color),
                  ),
                  SizedBox(width: 6),
                  // 保存图片
                  GestureDetector(
                    child: Icon(Icons.archive, color: nipponColor.color),
                    onTap: () => _onTapSave(controller.index),
                  ),
                  SizedBox(width: 6),
                  // 分享
                  GestureDetector(
                    child: Icon(Icons.share, color: nipponColor.color),
                  ),
                  SizedBox(width: 6),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// 预览生成图片页面
class ImagePage extends StatelessWidget {
  final NipponColor nipponColor;
  ImagePage(this.nipponColor);

  @override
  Widget build(BuildContext context) {
    final List<GenerateImage> images = [
      // 带颜色名（靠上）和颜色值
      GenerateImage(
        nipponColor: this.nipponColor,
        showName: true,
        showChart: true,
        isNameCenter: false,
      ),
      // 带颜色名 不带颜色值
      GenerateImage(
        nipponColor: this.nipponColor,
        showName: true,
        showChart: false,
        isNameCenter: false,
      ),
      // 带颜色名（靠中）和颜色值
      GenerateImage(
        nipponColor: this.nipponColor,
        showName: true,
        showChart: true,
        isNameCenter: true,
      ),
      // 带颜色名 不带颜色值
      GenerateImage(
        nipponColor: this.nipponColor,
        showName: true,
        showChart: false,
        isNameCenter: true,
      ),
      // 不带颜色名 不带颜色值
      GenerateImage(
        nipponColor: this.nipponColor,
        showName: false,
        showChart: false,
        isNameCenter: false,
      ),
    ];
    return Scaffold(
      backgroundColor: Colors.white,
      body: DefaultTabController( // 分页
        length: images.length,
        child: Container(
          color: nipponColor.color.withOpacity(0.28), // 背景透明度
          child: _ImageSelector(images: images, nipponColor: nipponColor),
        ),
      ),
    );
  }
}

/// 生成的图片
class GenerateImage extends StatelessWidget {
  final NipponColor nipponColor;
  final bool showName;
  final bool showChart;
  final bool isNameCenter;

  GlobalKey key;

  GenerateImage(
      {this.nipponColor, this.showName, this.showChart, this.isNameCenter});

  @override
  Widget build(BuildContext context) {
    key = GlobalKey();
    final Size screenSize = MediaQuery.of(context).size;
    final double scaleRatio = 0.7;
    final double newHeight = screenSize.height * scaleRatio;
    final double newWidth = screenSize.width * scaleRatio;
    final double divideH = newWidth * 0.012;
    double nameDistance;

    if (isNameCenter && showChart)
      nameDistance = newHeight * 0.3;
    else if (isNameCenter && !showChart)
      nameDistance = newHeight * 0.53;
    else
      nameDistance = newHeight * 0.15;

    return RepaintBoundary(
      key: key,
      child: Container(
        width: newWidth,
        height: newHeight,
        color: nipponColor.color,
        margin: EdgeInsets.all(0),
        padding: EdgeInsets.all(0),
        child: Stack(
          children: <Widget>[
            isNameCenter
                ? SizedBox(height: newHeight * 0.47)
                : SizedBox(height: newHeight * 0.15),
            Positioned(
              top: nameDistance,
              right: newWidth * 0.05,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  showName
                      ? ColorNameContainer(
                          color: nipponColor, ratio: scaleRatio)
                      : SizedBox(), // 颜色名称
                  // SizedBox(width: newWidth * 0.05),
                ],
              ),
            ),
            Positioned(
              child: showChart
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Container(
                          width: 30 * scaleRatio,
                          child: Image.asset(
                            'assets/images/branch.png', // 树枝图片
                            fit: BoxFit.fitWidth,
                            color: createColorStyle(nipponColor.isLight()),
                          ),
                        ),
                        SizedBox(height: divideH),
                        RGBCircularChart(color: nipponColor, ratio: scaleRatio),
                        SizedBox(height: divideH),
                        CMYKCircularChart(
                            color: nipponColor, ratio: scaleRatio),
                        Container(
                          padding: EdgeInsets.symmetric(
                              vertical: 10 * scaleRatio,
                              horizontal: 10 * scaleRatio),
                          child: Text(
                            '#${nipponColor.hex}',
                            style: TextStyle(
                              color: createColorStyle(nipponColor.isLight()),
                              fontSize: 16 * scaleRatio,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                        ),
                      ],
                    )
                  : SizedBox(),
            ),
          ],
        ),
      ),
    );
  }

  Future<Uint8List> toImage() async {
    RenderRepaintBoundary boundary = key.currentContext.findRenderObject();
    ui.Image image = await boundary.toImage(pixelRatio: 4.285); // 将screenshot放大到手机屏幕尺寸
    ByteData byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData.buffer.asUint8List();
  }
}
