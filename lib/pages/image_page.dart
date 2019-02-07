import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;

import '../models/nippon_color.dart';
import '../utils/utils.dart';
import '../widgets/color_name.dart';
import '../widgets/color_chart.dart';
import 'home_page.dart';

class _ImageSelector extends StatelessWidget {
  final List<Widget> images;
  final NipponColor nipponColor;

  const _ImageSelector({this.images, this.nipponColor});

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final TabController controller = DefaultTabController.of(context);
    return Column(
      children: <Widget>[
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
                  child: Container(
                    margin: EdgeInsets.only(top: 36),
                    padding: EdgeInsets.only(bottom: 18),
                    child: Card(
                      color: nipponColor.color,
                      child: image,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        TabPageSelector(
          controller: controller,
          indicatorSize: 8.0,
          selectedColor: nipponColor.color,
        ),
        Container(
          padding: EdgeInsets.only(top: screenSize.height * 0.15, bottom: 8),
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
                    // onTap: () => images[0].,
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
        // RaisedButton(
        //   child: Text('image'),
        //   onPressed: () => image.toImage(),
        // ),
      ],
    );
  }
}

class ImagePage extends StatelessWidget {
  final NipponColor nipponColor;
  ImagePage(this.nipponColor);

  @override
  Widget build(BuildContext context) {
    final List<GenerateImage> images = [
      GenerateImage(
        nipponColor: this.nipponColor,
        showName: true,
        showChart: true,
        isNameCenter: false,
      ),
      GenerateImage(
        nipponColor: this.nipponColor,
        showName: true,
        showChart: false,
        isNameCenter: false,
      ),
      GenerateImage(
        nipponColor: this.nipponColor,
        showName: true,
        showChart: true,
        isNameCenter: true,
      ),
      GenerateImage(
        nipponColor: this.nipponColor,
        showName: true,
        showChart: false,
        isNameCenter: true,
      ),
      GenerateImage(
        nipponColor: this.nipponColor,
        showName: false,
        showChart: false,
        isNameCenter: false,
      ),
    ];
    return Scaffold(
      backgroundColor: Colors.white,
      body: DefaultTabController(
        length: images.length,
        child: Container(
          color: nipponColor.color.withOpacity(0.25),
          child: _ImageSelector(images: images, nipponColor: nipponColor),
        ),
      ),
    );
  }
}

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
    final double newWidth = screenSize.width * scaleRatio;
    final double newHeight = screenSize.height * scaleRatio;
    final double divideH = newWidth * 0.012;
    double nameDistance;

    if (isNameCenter && showChart) nameDistance = newHeight * 0.38;
    else if (isNameCenter && !showChart) nameDistance = newHeight * 0.53;
    else nameDistance = newHeight * 0.15;

    return RepaintBoundary(
      key: key,
      child: Card(
        elevation: 0.0,
        child: Container(
          width: newWidth,
          height: newHeight,
          color: nipponColor.color,
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
                          RGBCircularChart(
                              color: nipponColor, ratio: scaleRatio),
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
      ),
    );
  }

  toImage() async {
    try {
      RenderRepaintBoundary boundary = key.currentContext.findRenderObject();
      var image = await boundary.toImage();
      var byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      var pngBytes = byteData.buffer.asUint8List();
      print(pngBytes);
    } catch (e) {
      print(e);
    }
  }
}
