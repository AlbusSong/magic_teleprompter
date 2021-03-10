import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';

enum AdEvent {
  loaded,
  failedToLoad,
  clicked,
  impression,
  opened,
  leftApplication,
  closed,
  completed,
  rewarded,
  started,
}

class AdmobTool {
  InterstitialAd interstitialAd;
  AdListener listener;
  Function(AdEvent e) callback;

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
    listener = AdListener(
      onAdLoaded: (Ad ad) {
        print("Ad loaded");
        if (this.callback != null) {
          this.callback(AdEvent.loaded);
        }
      },
      onAdFailedToLoad: (Ad ad, LoadAdError error) {
        print('Ad failed to load: $error');
      },
      // Called when an ad opens an overlay that covers the screen.
      onAdOpened: (Ad ad) {
        print('Ad opened.');
        if (this.callback != null) {
          this.callback(AdEvent.opened);
        }
      },
      // Called when an ad removes an overlay that covers the screen.
      onAdClosed: (Ad ad) {
        print('Ad closed.');
        interstitialAd.load();
        if (this.callback != null) {
          this.callback(AdEvent.closed);
        }
      },
      // Called when an ad is in the process of leaving the application.
      onApplicationExit: (Ad ad) => print('Left application.'),
    );
    // 广告
    MobileAds.instance.initialize();
    interstitialAd = InterstitialAd(
      adUnitId: getInterstitialAdUnitId(),
      request: AdRequest(),
      listener: AdListener(),
    );
    // interstitialAd = AdmobInterstitial(
    //   adUnitId: getInterstitialAdUnitId(),
    //   listener: (AdmobAdEvent event, Map<String, dynamic> args) {
    //     if (event == AdmobAdEvent.closed) {
    //       interstitialAd.load();
    //     }
    //     // handleEvent(event, args, 'Interstitial');
    //     print("ad event: $event, $args");
    //     if (this.callback != null) {
    //       this.callback(event);
    //     }
    //   },
    // );
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
