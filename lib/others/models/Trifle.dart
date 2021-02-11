import 'package:camera/camera.dart';
import 'package:admob_flutter/admob_flutter.dart';
import 'dart:io';

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
    // 广告
    Admob.initialize();
    interstitialAd = AdmobInterstitial(
      adUnitId: getInterstitialAdUnitId(),
      listener: (AdmobAdEvent event, Map<String, dynamic> args) {
        if (event == AdmobAdEvent.closed) {
          interstitialAd.load();
        }
        // handleEvent(event, args, 'Interstitial');
        print("ad event: $event, $args");
        if (this.callback != null) {
          this.callback(event);
        }
      },
    );
    interstitialAd.load();
    print("interstitialAd: $interstitialAd");
  }

  Future _initCamera() async {
    cameras = await availableCameras();
    firstCamera = cameras.first;
    print("firstCamera: $firstCamera");
  }

  String getInterstitialAdUnitId() {
    if (Platform.isIOS) {
      return 'ca-app-pub-8622528197740245/9525202279';
    } else if (Platform.isAndroid) {
      return 'ca-app-pub-8622528197740245/1749819882';
    }
    return null;
  }

  // 相机
  List cameras;
  CameraDescription firstCamera;

  AdmobInterstitial interstitialAd;
  Function(AdmobAdEvent e) callback;
}
