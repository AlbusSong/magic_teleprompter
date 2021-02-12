import 'package:flutter/material.dart';
import 'others/tools/GlobalTool.dart';
import 'package:delayed_display/delayed_display.dart';
import 'RealHomePage.dart';

class SplashPage extends StatelessWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    _dismissSelf();

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 40),
      color: Colors.white,
      child: Center(
          child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          DelayedDisplay(
            slidingBeginOffset: Offset(0.35, 0),
            delay: Duration(seconds: 1),
            child: Text(
              "工欲善其事",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0,
                  color: hexColor("666666"),
                  decoration: TextDecoration.none),
            ),
          ),
          DelayedDisplay(
            slidingBeginOffset: Offset(-0.35, 0),
            delay: Duration(seconds: 2),
            child: Text(
              "必先利其器",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20.0,
                  color: hexColor("666666"),
                  decoration: TextDecoration.none),
            ),
          ),
        ],
      )),
    );
  }

  void _dismissSelf() {
    Future.delayed(Duration(milliseconds: 3000), () {
      print("_dismissSelf");
      // Navigator.of(_scaffoldKey.currentContext).pushReplacementNamed("/home");
      _pushHomePage();
    });
  }

  void _pushHomePage() {
    PageRouteBuilder _router = PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => RealHomePage(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          var begin = Offset(0.0, 1.0);
          var end = Offset.zero;
          var curve = Curves.ease;

          var tween =
              Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        });
    Navigator.pushReplacement(_scaffoldKey.currentContext, _router);
  }
}
