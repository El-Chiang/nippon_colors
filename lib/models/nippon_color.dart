import 'package:meta/meta.dart';
import 'package:flutter/material.dart';
import 'dart:math';

class NipponColor {
  final int id;
  final String name; // 日文名罗马音
  final String cname; // 中文名
  final String hex; // 16进制颜色值
  final Color color; // 生成Color

  NipponColor({@required this.id, this.name, this.cname, this.hex, this.color});

  NipponColor.fromMap(Map<String, dynamic> data)
      : id = data['id'],
        name = data['name'],
        cname = data['cname'],
        hex = data['hex'],
        color = Color(int.parse('0x${data['hex']}')).withOpacity(1.0);

  // 获取RGB值
  List<int> getRGB() => [color.red, color.green, color.blue];

  // 获取CMYK值
  List<int> getCMYK() {
    final List<int> rgb = getRGB();
    if (rgb[0] == 0 && rgb[1] == 0 && rgb[2] == 0)
      return [0, 0, 0, 100];
    else {
      double calcR = 1 - (rgb[0] / 255);
      double calcG = 1 - (rgb[1] / 255);
      double calcB = 1 - (rgb[2] / 255);
      double K = min(calcR, min(calcG, calcB));
      double C = (calcR - K) / (1 - K);
      double M = (calcG - K) / (1 - K);
      double Y = (calcB - K) / (1 - K);
      return [
        (C * 100).round(),
        (M * 100).round(),
        (Y * 100).round(),
        (C * 100).round(),
      ];
    }
  }

  // 判断颜色是否偏白以便设置字体颜色
  bool isLight() {
    final List<int> rgb = getRGB();
    final double brightness = rgb[0]/255*0.299 + rgb[1]/255*0.587 + rgb[2]/255*0.114;
    if (brightness > 0.8)
      return true;
    else
      return false;
  }

  @override
  String toString() => 'NipponColor id: $id, name: $name, cname: $cname, hex: #$hex';
}
