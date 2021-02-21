import 'package:flutter/material.dart';
import 'package:magic_teleprompter/others/tools/GlobalTool.dart';
import 'package:rolling_nav_bar/rolling_nav_bar.dart';
import 'RealHomePage.dart';
import 'MinePage.dart';
import 'others/tools/HudTool.dart';

class TabbarPage extends StatefulWidget {
  static GlobalKey<ScaffoldState> globalKey;

  @override
  _TabbarPageState createState() {
    _TabbarPageState s = _TabbarPageState();
    globalKey = s._scaffoldKey;
    return s;
  }
}

class _TabbarPageState extends State<TabbarPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  List<Widget> _pageList = [RealHomePage(), MinePage()];
  int _selectedIndex = 0;
  var _iconData = <IconData>[
    Icons.home,
    Icons.person,
  ];

  var _indicatorColors = <Color>[
    hexColor("7959be"),
    Colors.orange,
  ];

  @override
  Widget build(BuildContext context) {
    HudTool.APP_CONTEXT = context;

    return Scaffold(
        key: _scaffoldKey,
        body: IndexedStack(
          index: _selectedIndex,
          children: _pageList,
        ),
        bottomNavigationBar: Container(
          height: 65.0,
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(width: 1.0, color: hexColor("f1f1f1")),
            ),
          ),
          child: RollingNavBar.iconData(
            iconData: _iconData,
            indicatorColors: _indicatorColors,
            onTap: (idx) {
              print("tab index: $idx");
              setState(() {
                this._selectedIndex = idx;
              });
            },
          ),
        ));
  }
}
