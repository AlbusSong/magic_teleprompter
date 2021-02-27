import 'package:magic_teleprompter/others/tools/GlobalTool.dart';

class BeautyEffectSettings {
  // 单例公开访问点
  factory BeautyEffectSettings() => _sharedInfo();

  // 静态私有成员，没有初始化
  static BeautyEffectSettings _instance = BeautyEffectSettings._();

  // 静态、同步、私有访问点
  static BeautyEffectSettings _sharedInfo() {
    return _instance;
  }

  // 私有构造函数
  BeautyEffectSettings._() {
    // 具体初始化代码
    _initSomeThings();
  }

  void _initSomeThings() {}

  void resetEffectValues1ToZero() {
    for (int i = 0; i < listLength(this.beautyEffectValues1); i++) {
      this.beautyEffectValues1[i] = 0;
    }
  }

  void resetEffectValues2ToZero() {
    for (int i = 0; i < listLength(this.beautyEffectValues2); i++) {
      this.beautyEffectValues2[i] = 0;
    }
  }

  List<String> beautyEffectParaNames1 = [
    "smoothing",
    "whitening",
    "sharpen",
    "ruddy"
  ];
  List<double> beautyEffectValues1 = [0, 0, 0, 0];
  List<String> beautyEffectParaNames2 = [
    "eyeSize",
    "chinSize",
    "noseSize",
    "browPosition",
    "archEyebrow",
    "lips",
    "mouthWidth",
    "jawSize",
    "eyeAngle",
    "eyeDis",
    "forehead"
  ];
  List<double> beautyEffectValues2 = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];
}
