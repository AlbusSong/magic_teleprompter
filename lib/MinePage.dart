import 'package:flutter/material.dart';
import 'package:magic_teleprompter/others/tools/GlobalTool.dart';

class MinePage extends StatefulWidget {
  MinePage({Key key}) : super(key: key);

  @override
  _MinePageState createState() => _MinePageState();
}

class _MinePageState extends State<MinePage> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: randomColor(),
    );
  }
}
