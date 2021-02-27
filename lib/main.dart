import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

Future main() async {
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.dark);

  WidgetsFlutterBinding.ensureInitialized();

  // ignore: await_only_futures
  await EasyLocalization.ensureInitialized();

  // RegExp re = new RegExp(r"(\w|\s|,|')+[，,。.?!]*\s*");
  // // get all the matches:
  // Iterable matches = re.allMatches(ddds);
  // // print("matches: $matches");
  // for (Match m in matches) {
  //   String match = m.group(0);
  //   print("match: $match");
  // }
  // List allSubStrings = getAllSubStrings("我爱你", 2, true);
  // print("allSubStrings: $allSubStrings");

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
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
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
