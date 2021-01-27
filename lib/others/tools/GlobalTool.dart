import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:convert';
import 'dart:ui';
import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';

// md5 加密
String generateMd5(String data) {
  var content = new Utf8Encoder().convert(data);
  var digest = md5.convert(content);
  // 这里其实就是 digest.toString()
  return hex.encode(digest.bytes);
}

//  Image Base64字符串 转为 image
Image convertToImageByBase64String(base64String) {
  Uint8List bytes = Base64Decoder().convert(base64String);
  if (bytes != null) {
    return Image.memory(bytes);
  } else {
    return null;
  }
}

MaterialColor createMaterialColor(Color color) {
  List strengths = <double>[.05];
  Map swatch = <int, Color>{};
  final int r = color.red, g = color.green, b = color.blue;

  for (int i = 1; i < 10; i++) {
    strengths.add(0.1 * i);
  }
  strengths.forEach((strength) {
    final double ds = 0.5 - strength;
    swatch[(strength * 1000).round()] = Color.fromRGBO(
      r + ((ds < 0 ? r : (255 - r)) * ds).round(),
      g + ((ds < 0 ? g : (255 - g)) * ds).round(),
      b + ((ds < 0 ? b : (255 - b)) * ds).round(),
      1,
    );
  });
  return MaterialColor(color.value, swatch);
}

Color hexColor(String hexString, [double opacity = 1.0]) {
  // 如果传入的十六进制颜色值不符合要求，返回默认值
  if (hexString == null ||
      hexString.length != 6 ||
      int.tryParse(hexString.substring(0, 6), radix: 16) == null) {
    hexString = 'ffffff';
  }

  final c = Color(int.parse(hexString.substring(0, 6), radix: 16) + 0xFF000000);
  if (opacity < 0) {
    opacity = 0.0;
  } else if (opacity > 1.0) {
    opacity = 1.0;
  }
  return c.withOpacity(opacity);
}

Color randomColor([double opacity = 1.0]) {
  final Random _rgn = new Random();
  Color result = Color.fromARGB(
      255, _rgn.nextInt(255), _rgn.nextInt(255), _rgn.nextInt(255));
  if (opacity < 0) {
    opacity = 0.0;
  } else if (opacity > 1.0) {
    opacity = 1.0;
  }
  return result.withOpacity(opacity);
}

int randomIntUntil(int max) {
  return randomIntWithRange(0, max);
}

int randomIntWithRange(int min, int max) {
  final Random _rgn = new Random();
  return min + _rgn.nextInt(max - min + 1);
}

void hideKeyboard(BuildContext context) {
  FocusScope.of(context).requestFocus(FocusNode());
}

int listLength(List list) {
  if (list == null) {
    return 0;
  }

  return list.length;
}

int avoidNullIntValue(int i) {
  if (i == null) {
    return 0;
  }
  return i;
}

String avoidNull(String s) {
  if (s == null) {
    return "";
  }

  return s;
}

int stringLength(String s) {
  if (s == null) {
    return 0;
  }

  return s.length;
}

bool isAvailable(String s) {
  if (s == null) {
    return false;
  }

  if (s == "") {
    return false;
  }

  return true;
}
