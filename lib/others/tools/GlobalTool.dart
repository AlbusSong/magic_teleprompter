import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:convert';
import 'dart:ui';
import 'package:convert/convert.dart';
import 'package:crypto/crypto.dart';

// 获取一个字符串的所有子字符串
List<String> getAllSubStrings(String fatherStr,
    [int threshold = 1, fromEnding = false]) {
  int length = stringLength(fatherStr);
  if (length <= 1) {
    return [fatherStr];
  }
  List<String> result = [];
  // for (int i = 0; i < stringLength(fatherStr); i++) {
  //   for (int j = threshold; j <= length - i; j++) {
  //     String sub = fatherStr.substring(i, i + j);
  //     print("sub: $sub");
  //     result.add(sub);
  //   }
  // }
  if (fromEnding == false) {
    for (int i = length; i >= threshold; i--) {
      for (int j = 0; j + i <= length; j++) {
        String sub = fatherStr.substring(j, j + i);
        print("sub: $sub");
        result.add(sub);
      }
    }
  } else {
    for (int i = length; i >= threshold; i--) {
      for (int j = length - 1; (j + 1) - i >= 0; j--) {
        String sub = fatherStr.substring((j + 1) - i, j + 1);
        print("sub: $sub");
        result.add(sub);
      }
    }
  }
  return result;
}

// 将字符串分割成数组
List<String> splitStringByPunctuation(String ori) {
  List<String> result = [];
  String cpString = '$ori';
  cpString = cpString.trim();
  List<String> puncList = [
    ",",
    ".",
    "!",
    "?",
    "，",
    "。",
    "！",
    "？",
    "...",
    "......"
  ];
  String p = "#&&^%^&&#";
  for (String punc in puncList) {
    cpString = cpString.replaceAll(punc, p);
  }
  // print("cpString: $cpString");
  // print("ori: $ori");
  List<String> tmp = cpString.split(p);
  for (String str in tmp) {
    if (stringLength(str) > 0) {
      result.add(str);
    }
  }
  return result;
}

// kmp算法
List computeLPS(String pattern) {
  List lps = new List(pattern.length);
  lps[0] = 0;
  int m = pattern.length;
  int j = 0;
  int i = 1;

  while (i < m) {
    if (pattern[j] == pattern[i]) {
      lps[i] = j + 1;
      i++;
      j++;
    } else if (j > 0) {
      j = lps[j - 1];
    } else {
      // no match
      lps[i] = 0;
      i++;
    }
  }

  return lps;
}

List<int> kmp(String text, String pattern) {
  List<int> foundIndexes = new List<int>();
  int n = text.length;
  int m = pattern.length;

  int i = 0;
  int j = 0;
  List lps = computeLPS(pattern);

  while (i < n) {
    if (pattern[j] == text[i]) {
      i++;
      j++;
    }

    if (j == m) {
      foundIndexes.add(i - m); // Match
      // print(j);
      j = lps[j - 1];
      i += m - 1;
    } else if (i < n && pattern[j] != text[i]) {
      if (j != 0) {
        j = lps[j - 1];
      } else {
        i = i + 1;
      }
    }
  }

  return foundIndexes;
}

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
