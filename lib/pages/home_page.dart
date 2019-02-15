import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'dart:math';
import 'dart:async';
import 'package:sensors/sensors.dart';

import '../utils/utils.dart';
import '../actions/event_actions.dart';
import '../models/nippon_color.dart';
import '../models/localizations.dart';
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
  NipponColor nipponColor, prevColor;
  bool _isChartVisibled; // Chart是否可见
  bool _isBranchVisibled; // 树枝是否可见
  bool _isShake; // 是否摇动设备
  StreamSubscription shakeSubscription;

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
        _isChartVisibled = false;
        _isBranchVisibled = false;
        _isShake = false;
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

  /// 移除掉时取消监听
  void deactivate() {
    super.deactivate();
    shakeSubscription.cancel();
  }

  void dispose() {
    super.dispose();
    shakeSubscription.cancel();
  }

  /// 跳转到上一个颜色
  void _goToPrevColor() {
    Navigator.pop(context);
    eventBus.fire(UpdateColorEvent(prevColor.id - 1, prevColor));
  }

  /// 点击屏幕事件 -> 随机产生一个新的颜色
  void _handleTapScreen() {
    final int newIndex = Random().nextInt(colorCount - 1);
    final newColor = NipponColor.fromMap(colors[newIndex]);
    setState(() => prevColor = nipponColor); // 将当前颜色保存到prevColor
    eventBus.fire(UpdateColorEvent(newIndex, newColor));
  }

  /// 点击颜色名称事件 -> 跳转到调色板界面显示所有颜色
  void _handleTapName() {
    shakeSubscription.pause();
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
    Navigator.pop(context); // 先关闭dialog再push
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FavoritePage(favoriteColors: favoriteColors),
      ),
    );
  }

  /// 点击“生成图片”事件
  void _goToImagePage() {
    Navigator.pop(context);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ImagePage(nipponColor),
      ),
    );
  }

  /// 点击“使用提示”事件
  void _getHelp() {
    Navigator.pop(context);
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
            title: Text(MyLocalizations.of(context).tipsTitleStr, textAlign: TextAlign.center), // 使用提示
            // 首页点击颜色名称，显示所有颜色
            // 手误误点屏幕时，“摇一摇设备”撤销操作
            // 长按十六进制值可复制
            children: <Widget>[
              Text('· ${MyLocalizations.of(context).tipStr1}\n· ${MyLocalizations.of(context).tipStr2}\n· ${MyLocalizations.of(context).tipStr3}'),
              CupertinoDialogAction(
                child: Text(MyLocalizations.of(context).okStr, style: TextStyle(color: _getFontColor())), // 好的
                isDefaultAction: true,
                onPressed: () => Navigator.pop(context),
              ),
            ],
            contentPadding: EdgeInsets.fromLTRB(12, 16, 12, 12),
          ),
    );
  }

  /// 根据Color得到字体颜色
  Color _getFontColor() {
    List<int> oldRGB = nipponColor.getRGB();
    if (nipponColor.isLight()) {
      List<int> newRGB = oldRGB.map((data) => (data * 0.6).round()).toList(); // 将RGB等比例减小
      Color color = Color.fromARGB(255, newRGB[0], newRGB[1], newRGB[2]);
      return color;
    } else {
      return nipponColor.color;
    }
  }

  /// 点击树枝 -> 弹出菜单dialog
  void _handleTapBranch() {
    bool isFavorite;
    if (allFavorite.contains(nipponColor.id.toString()))
      isFavorite = true; // 当isFavorite为true显示“取消喜欢”
    else
      isFavorite = false; // 当isFavorite为false显示“标记喜欢”
    showDialog(
      context: context,
      builder: (context) {
        // 当用户没有任何喜欢颜色时隐藏“我喜欢的”入口
        if (allFavorite.length == 0) {
          return SimpleDialog(
            children: <Widget>[
              isFavorite
                  ? CupertinoDialogAction(
                      child: Text(
                        MyLocalizations.of(context).cancelFavoriteStr, // 取消喜欢
                        style: TextStyle(color: Colors.black),
                      ),
                      onPressed: _cancelFavorite,
                    )
                  : CupertinoDialogAction(
                      child: Text(
                        MyLocalizations.of(context).markFavoriteStr, // 标记喜欢
                        style: TextStyle(color: Colors.black),
                      ),
                      onPressed: _markAsFavorite,
                    ),
              CupertinoDialogAction(
                child: Text(MyLocalizations.of(context).generatePicStr, style: TextStyle(color: Colors.black)), // 生成图片
                onPressed: _goToImagePage,
              ),
              CupertinoDialogAction(
                child: Text(MyLocalizations.of(context).getUseTipsStr, style: TextStyle(color: Colors.black)), // 使用提示
                onPressed: _getHelp,
              ),
              CupertinoDialogAction(
                child: Text(MyLocalizations.of(context).backStr, style: TextStyle(color: _getFontColor())), // 返回
                isDefaultAction: true,
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          );
        } else {
          return SimpleDialog(
            children: <Widget>[
              isFavorite
                  ? CupertinoDialogAction(
                      child: Text(
                        MyLocalizations.of(context).cancelFavoriteStr, // 取消喜欢
                        style: TextStyle(color: Colors.black),
                      ),
                      onPressed: _cancelFavorite,
                    )
                  : CupertinoDialogAction(
                      child: Text(
                        MyLocalizations.of(context).markFavoriteStr, // 标记喜欢
                        style: TextStyle(color: Colors.black),
                      ),
                      onPressed: _markAsFavorite,
                    ),
              CupertinoDialogAction(
                child: Text(MyLocalizations.of(context).myFavoriteStr, style: TextStyle(color: Colors.black)), // 我喜欢的
                onPressed: _getMyFavorite,
              ),
              CupertinoDialogAction(
                child: Text(MyLocalizations.of(context).generatePicStr, style: TextStyle(color: Colors.black)), // 生成图片
                onPressed: _goToImagePage,
              ),
              CupertinoDialogAction(
                child: Text(MyLocalizations.of(context).getUseTipsStr, style: TextStyle(color: Colors.black)), // 使用提示
                onPressed: _getHelp,
              ),
              CupertinoDialogAction(
                child: Text(MyLocalizations.of(context).backStr, style: TextStyle(color: _getFontColor())), // 返回
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

  /// 长按Hex -> 复制Hex值
  void _handleLongPressHex() {
    Clipboard.setData(ClipboardData(text: '#${nipponColor.hex}'));
  }

  @override
  Widget build(BuildContext context) {
    final Size screenSize = MediaQuery.of(context).size;
    final double divideH = screenSize.width * 0.012;

    // 震动检测
    shakeSubscription = accelerometerEvents.listen((AccelerometerEvent event) {
      // 如果检测到摇一摇 且存在上一个颜色
      if (((event.x > 20) || (event.y > 20) || (event.z > 20)) && !_isShake && (prevColor != null)) {
        setState(() => _isShake = true);
        showDialog(
          context: context,
          builder: (context) => SimpleDialog(
                title: Text(MyLocalizations.of(context).undoTitleStr, textAlign: TextAlign.center), // 撤销操作
                children: <Widget>[
                  CupertinoDialogAction(
                      child: Text(
                        MyLocalizations.of(context).lastColorStr, // 上一个颜色
                        style: TextStyle(color: _getFontColor()),
                      ),
                      onPressed: _goToPrevColor,
                    ),
                    CupertinoDialogAction(
                      child: Text(
                        MyLocalizations.of(context).cancelStr, // 取消
                        style: TextStyle(color: _getFontColor()),
                      ),
                      onPressed: () => Navigator.pop(context),
                      isDefaultAction: true,
                    ),
                ],
              ),
        );
        // 这里设置等待4秒是为了给shake加一个延迟
        Future.delayed(const Duration(seconds: 4), () {
          setState(() => _isShake = false);
        });
      }
    });
    shakeSubscription.resume();

    return GestureDetector(
      // 点击屏幕
      onTap: _handleTapScreen,
      // 垂直滑动
      onVerticalDragEnd: (DragEndDetails details) {
        double nowPosition = details.primaryVelocity;
        if (nowPosition < 0) {
          // 上滑可见
          setState(() => _isChartVisibled = true);
          Future.delayed(const Duration(milliseconds: 300), () {
            setState(() => _isBranchVisibled = true);
          });
        }
        if (nowPosition > 0) {
          // 下滑隐藏
          setState(() {
            _isChartVisibled = false;
            _isBranchVisibled = false;
          });
        }
      },
      // 水平滑动
      onHorizontalDragEnd: (DragEndDetails details) {
        double nowPosition = details.primaryVelocity;
        if (nowPosition < 0) // 左滑
          print('left');
        if (nowPosition > 0) // 右滑
          print('right');
      },

      child: Scaffold(
        backgroundColor: nipponColor.color,
        body: Stack(
          children: <Widget>[
            // 颜色名行
            Positioned(
              top: screenSize.height * 0.15, // 颜色名称离屏幕上边框的距离
              right: screenSize.width * 0.05, // 颜色名称离屏幕右边框的距离
              child: GestureDetector(
                child: ColorNameContainer(color: nipponColor), // 颜色名称
                onTap: _handleTapName,
              ),
            ),
            // 树枝 RGB值 CMYK值 Hex值
            AnimatedPositioned(
              duration: Duration(milliseconds: 300),
              bottom: _isChartVisibled ? 0 : -screenSize.height * 0.65,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // 树枝图片
                  AnimatedOpacity(
                    duration: Duration(milliseconds: 500),
                    opacity: _isBranchVisibled ? 1 : 0.0,
                    child: GestureDetector(
                      child: Container(
                        width: 30,
                        child: Image.asset(
                          'assets/images/branch.png',
                          fit: BoxFit.fitWidth,
                          color: createColorStyle(nipponColor.isLight()),
                        ),
                      ),
                      onTap: _handleTapBranch,
                    ),
                  ),
                  SizedBox(height: divideH),
                  // RGB环状图
                  RGBCircularChart(color: nipponColor),
                  SizedBox(height: divideH),
                  // CMYK环状图
                  CMYKCircularChart(color: nipponColor),
                  // Hex值
                  GestureDetector(
                    onLongPress: _handleLongPressHex,
                    child: Tooltip(
                      message: MyLocalizations.of(context).copyStr, // 已复制
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                        child: Text(
                          '#${nipponColor.hex}',
                          style: TextStyle(
                            color: createColorStyle(nipponColor.isLight()),
                            fontSize: screenSize.width * 0.05, // hex字体大小为screenWidth * 0.05
                            fontWeight: FontWeight.w300,
                          ),
                        ),
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
