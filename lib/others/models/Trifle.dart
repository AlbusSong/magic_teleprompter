import 'package:camera/camera.dart';

class Trifle {
  // 单例公开访问点
  factory Trifle() => _sharedInfo();

  // 静态私有成员，没有初始化
  static Trifle _instance = Trifle._();

  // 静态、同步、私有访问点
  static Trifle _sharedInfo() {
    return _instance;
  }

  // 私有构造函数
  Trifle._() {
    // 具体初始化代码
    _initSomeThings();
  }

  void _initSomeThings() async {
    // 相机
    _initCamera();
  }

  Future _initCamera() async {
    cameras = await availableCameras();
    firstCamera = cameras.first;
    print("firstCamera: $firstCamera");
  }

  // 相机
  List cameras;
  CameraDescription firstCamera;

  // 颜色
  // 首页颜色
  final List<String> homeColorList = [
    "BFDB8D",
    "DD8383",
    "83D2DD",
    "CD84D7",
    "9F0F58",
    "416ABF",
    "BF5741",
    "41BF47"
  ];

  final List<String> textColorStrings = [
    "FFFFFF",
    "EDC055",
    "27B3BF",
    "BF27AA",
    "E67366",
    "EDC055",
    "27B3BF",
    "BF27AA"
  ];
}
