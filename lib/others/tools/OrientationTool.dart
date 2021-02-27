import 'package:flutter/services.dart';
import 'package:orientation/orientation.dart';

typedef DeviceOrientationChangedCallback = void Function(
    DeviceOrientation oldOrien, DeviceOrientation newOrien);

class OrientationTool {
  DeviceOrientation _orientation;

  // 单例公开访问点
  factory OrientationTool() => _sharedInfo();

  // 静态私有成员，没有初始化
  static OrientationTool _instance = OrientationTool._();

  // 静态、同步、私有访问点
  static OrientationTool _sharedInfo() {
    return _instance;
  }

  // 私有构造函数
  OrientationTool._() {
    // 具体初始化代码
    _orientation = DeviceOrientation.portraitUp;
  }

  DeviceOrientation currentOrientation() {
    return this._orientation;
  }

  void addOrientationChangeHandler(DeviceOrientationChangedCallback callback) {
    OrientationPlugin.onOrientationChange.listen((newOrien) {
      if (newOrien != _orientation) {
        if (callback != null) {
          callback(_orientation, newOrien);
        }
        _orientation = newOrien;
      }
    });
  }

  bool isPortrait([DeviceOrientation orien]) {
    if (orien == null) {
      return (this._orientation == DeviceOrientation.portraitUp ||
          this._orientation == DeviceOrientation.portraitDown);
    } else {
      return (orien == DeviceOrientation.portraitUp ||
          orien == DeviceOrientation.portraitDown);
    }
  }

  Future<void> setEnabledSystemUIOverlays(List<SystemUiOverlay> overlays) {
    return OrientationPlugin.setEnabledSystemUIOverlays(overlays);
  }

  Future<void> setPreferredOrientations(List<DeviceOrientation> orientations) {
    return OrientationPlugin.setPreferredOrientations(orientations);
  }

  Future<void> forceOrientation(DeviceOrientation orientation) {
    return OrientationPlugin.forceOrientation(orientation);
  }
}
