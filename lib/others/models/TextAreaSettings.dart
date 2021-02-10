import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart';

class TextAreaSettings {
  // 单例公开访问点
  factory TextAreaSettings() => _sharedInfo();

  // 静态私有成员，没有初始化
  static TextAreaSettings _instance = TextAreaSettings._();

  // 静态、同步、私有访问点
  static TextAreaSettings _sharedInfo() {
    return _instance;
  }

  // 私有构造函数
  TextAreaSettings._() {
    // 具体初始化代码
    loadLocalSettings();
  }

  Future loadLocalSettings() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    this.fontSize = (pref.getDouble("fontSize") ?? 13.0);
    this.textHexColorString =
        (pref.getString("textHexColorString") ?? "FFFFFF");
    this.backgroundHexColorString =
        (pref.getString("backgroundHexColorString") ?? "FFFFFF");
    this.backgroundAlpha = (pref.getDouble("backgroundAlpha") ?? 0.3);
    this.textScrollingSpeed = (pref.getDouble("textScrollingSpeed") ?? 10.0);
  }

  Future cacheLocalSettings() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setDouble("fontSize", this.fontSize);
    pref.setString("textHexColorString", this.textHexColorString);
    pref.setString("backgroundHexColorString", this.backgroundHexColorString);
    pref.setDouble("backgroundAlpha", this.backgroundAlpha);
    pref.setDouble("textScrollingSpeed", this.textScrollingSpeed);
  }

  double fontSize = 13.0;
  String textHexColorString = "FFFFFF";
  String backgroundHexColorString = "FFFFFF";
  double backgroundAlpha = 0.3;
  double textScrollingSpeed = 30.0;
  // 语音识别模式还是滚动模式
  bool isAISpeechAvailable = false;
  bool isAISpeechMode = false;
  LocaleName systemLocaleName;
  LocaleName selectedLocaleName;
  List<LocaleName> localeNames;
}
