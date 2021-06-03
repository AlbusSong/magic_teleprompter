import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'RealHomePage.dart';
import 'others/tools/SqliteTool.dart';
import 'package:bot_toast/bot_toast.dart';
import 'others/models/Trifle.dart';
import 'others/models/TextAreaSettings.dart';
import 'others/tools/GlobalTool.dart';
import 'package:bubble_lens/bubble_lens.dart';
import 'others/third_party/Dart-Searchify/Dart_Searchify.dart';
import 'others/tools/AdmobTool.dart';
import 'SplashPage.dart';
import 'package:flutter_bugly/flutter_bugly.dart';

Future main() async {
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);

  WidgetsFlutterBinding.ensureInitialized();

  // ignore: await_only_futures
  await EasyLocalization.ensureInitialized();

  if (Platform.isAndroid) {
    SystemUiOverlayStyle systemUiOverlayStyle = SystemUiOverlayStyle(
      statusBarColor: Colors.white,
      statusBarBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.dark,
    );
    SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
  }

  Pattern pattern = Pattern("ABC");
  String testString = "ABCABCDEFGABC";
  print("kksldkfasdfafda: ${pattern.matches(testString, Search.KNUTH_MORRIS)}");

  print("llllssl: ${kmp('ABCABCDEFGABC', 'ABC')}"); // Output: [0, 3, 10]
  // print(
  //     "lldkdksssss: ${kmp('AAAAAAAAAAAAAAABBCCDDAAA', 'AAAA')}"); // Output: [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11]
  // print(kmp('AAAABBCCDDAAA', 'ABAAB'));

  Trifle();
  TextAreaSettings();
  AdmobTool();
  SqliteTool();

  FlutterBugly.init(androidAppId: "2827cefc38", iOSAppId: "907467ede5");

  runApp(EasyLocalization(
      supportedLocales: [Locale('zh')],
      path: 'assets/translations',
      fallbackLocale: Locale('zh'),
      child: MyApp()));
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      title: "Magic Teleprompter",
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: SplashPage(),
      builder: BotToastInit(),
      navigatorObservers: [BotToastNavigatorObserver()],
      routes: <String, WidgetBuilder>{
        '/home': (_) => RealHomePage(),
      },
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Container(
          color: Colors.black,
          child: BubbleLens(width: 300, height: 300, widgets: [
            for (var i = 0; i < 7; i++)
              GestureDetector(
                child: Container(
                  width: 100,
                  height: 100,
                  color: [Colors.red, Colors.green, Colors.blue][i % 3],
                ),
                onTap: () {
                  print("llllllaaaaaaa");
                },
              )
          ]),
        ),
      ),
    );
  }
}

// flutter pub run build_runner watch
