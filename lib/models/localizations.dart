import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/foundation.dart' show SynchronousFuture;

class MyLocalizations {
  final Locale locale;

  MyLocalizations(this.locale);

  static Map<String, Map<String, String>> _localValues = {
    'en': {
      'IMAGE_SAVED_INFO': 'Image Saved to Album',

      'UNDO': 'Undo',
      'LAST_COLOR': 'Last Color',
      'CANCEL': 'Cancel',

      'GENERATE_PIC': '📲 Generate Pictures',
      'ALL_COLOR': '🌈 All Colors',
      'MARK_FAVORITE': '🌟 Mark Favorite',
      'CANCEL_FAVORITE': '😪 Cancel Favorite',
      'MY_FAVORITE': '💫 My Favorites',
      'USE_TIPS': '❓ Use Tips',
      'BACK': 'Back',

      'TIPS_TITLE': 'Use Tips',
      'TIP_1': 'Click color\'s name to display all colors',
      'TIP_2': '"Shake the device" to undo when you touch the screen by mistake',
      'TIP_3': 'Long press Hex value to copy it',
      'OK': 'OK',

      'SHARE': 'Share Image',

      'COPY': 'Has been copied!',
    },
    'zh': {
      'IMAGE_SAVED_INFO': '图片已保存到相册',

      'UNDO': '撤销操作',
      'LAST_COLOR': '上一个颜色',
      'CANCEL': '取消',

      'GENERATE_PIC': '📲 生成图片',
      'ALL_COLOR': '🌈 所有颜色',
      'MARK_FAVORITE': '🌟 标记喜欢',
      'CANCEL_FAVORITE': '😪 取消喜欢',
      'MY_FAVORITE': '💫 我喜欢的',
      'USE_TIPS': '❓ 使用提示',
      'BACK': '返回',

      'TIPS_TITLE': '使用提示',
      'TIP_1': '首页点击颜色名称，显示所有颜色',
      'TIP_2': '误点屏幕时，“摇一摇设备”撤销操作',
      'TIP_3': '长按十六进制值可复制',
      'OK': '好的',

      'SHARE': '分享图片',

      'COPY': '已复制',
    },
  };
  // 保存图片Bottomsheet
  get savedInfoStr => _localValues[locale.languageCode]['IMAGE_SAVED_INFO'];

  // 撤销Dialog
  get undoTitleStr => _localValues[locale.languageCode]['UNDO'];
  get lastColorStr => _localValues[locale.languageCode]['LAST_COLOR'];
  get cancelStr => _localValues[locale.languageCode]['CANCEL'];
  
  // 点击树枝Dialog
  get generatePicStr => _localValues[locale.languageCode]['GENERATE_PIC'];
  get allColorStr => _localValues[locale.languageCode]['ALL_COLOR'];
  get markFavoriteStr => _localValues[locale.languageCode]['MARK_FAVORITE'];
  get cancelFavoriteStr => _localValues[locale.languageCode]['CANCEL_FAVORITE'];
  get myFavoriteStr => _localValues[locale.languageCode]['MY_FAVORITE'];
  get getUseTipsStr => _localValues[locale.languageCode]['USE_TIPS'];
  get backStr =>  _localValues[locale.languageCode]['BACK'];

  // 使用提示Dialog
  get tipsTitleStr => _localValues[locale.languageCode]['TIPS_TITLE'];
  get tipStr1 => _localValues[locale.languageCode]['TIP_1'];
  get tipStr2 => _localValues[locale.languageCode]['TIP_2'];
  get tipStr3 => _localValues[locale.languageCode]['TIP_3'];
  get okStr => _localValues[locale.languageCode]['OK'];

  // 分享
  get shareStr => _localValues[locale.languageCode]['SHARE'];

  // 已复制
  get copyStr => _localValues[locale.languageCode]['COPY'];

  static MyLocalizations of(BuildContext context) {
    return Localizations.of(context, MyLocalizations);
  }
}

class MyLocalDelegate extends LocalizationsDelegate<MyLocalizations> {
  const MyLocalDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'zh'].contains(locale.languageCode);
  }

  // 初始化
  @override
  Future<MyLocalizations> load(Locale locale) {
    return SynchronousFuture<MyLocalizations>(MyLocalizations(locale));
  }

  @override
  bool shouldReload(LocalizationsDelegate<MyLocalizations> old) {
    return false;
  }

  static MyLocalDelegate delegate = const MyLocalDelegate();
}