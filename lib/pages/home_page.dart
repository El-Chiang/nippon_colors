import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:math';

import '../utils/utils.dart';
import '../actions/event_actions.dart';
import '../models/nippon_color.dart';
import '../widgets/color_chart.dart';
import '../widgets/color_name.dart';
import 'palette_page.dart';
import 'favorite_page.dart';
import 'image_page.dart';

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

  void _goToImagePage() {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ImagePage(nipponColor),
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
                onPressed: _goToImagePage,
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
                onPressed: _goToImagePage,
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
                  RGBCircularChart(color: nipponColor), // RGB环状图
                  SizedBox(height: divideH),
                  CMYKCircularChart(color: nipponColor), // CMYK环状图
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
