import 'package:flutter/material.dart';
import 'dart:ui';

class CommonValues {
  // 单例公开访问点
  factory CommonValues() => _sharedInfo();

  // 静态私有成员，没有初始化
  static CommonValues _instance = CommonValues._();

  // 静态、同步、私有访问点
  static CommonValues _sharedInfo() {
    return _instance;
  }

  // 私有构造函数
  CommonValues._() {
    // 具体初始化代码
    _initSomeThings();
  }

  void _initSomeThings() async {
    screenWidth = window.physicalSize.width / dpr;
    screenHeight = window.physicalSize.height / dpr;
    statusHeight = window.padding.top / dpr;
    xBottomHeight = window.padding.bottom / dpr;

    this.makeSure();
  }

  void makeSure() {
    if (screenHeight < screenWidth) {
      double tmp = screenWidth;
      screenWidth = screenHeight;
      screenHeight = tmp;
    }
  }

  final dpr = window.devicePixelRatio;
  double screenWidth;
  double screenHeight;
  double statusHeight;
  double xBottomHeight;
}
