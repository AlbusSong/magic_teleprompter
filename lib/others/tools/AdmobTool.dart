import 'package:admob_flutter/admob_flutter.dart';
import 'dart:io';

class AdmobTool {
  AdmobInterstitial interstitialAd;
  Function(AdmobAdEvent e) callback;

  // 单例公开访问点
  factory AdmobTool() => _sharedInfo();

  // 静态私有成员，没有初始化
  static AdmobTool _instance = AdmobTool._();

  // 静态、同步、私有访问点
  static AdmobTool _sharedInfo() {
    return _instance;
  }

  // 私有构造函数
  AdmobTool._() {
    // 具体初始化代码
    _initSomeThings();
  }

  void _initSomeThings() async {
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

  String getInterstitialAdUnitId() {
    if (Platform.isIOS) {
      return 'ca-app-pub-8622528197740245/9525202279';
    } else if (Platform.isAndroid) {
      return 'ca-app-pub-8622528197740245/1749819882';
    }
    return null;
  }
}
