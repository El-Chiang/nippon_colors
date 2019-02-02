import 'package:flutter/material.dart';

// 如果颜色偏白则设置为黑色，反之则为白色
Color createColorStyle(bool isLight) => isLight ? Colors.black : Colors.white;