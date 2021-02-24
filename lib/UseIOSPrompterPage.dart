import 'package:flutter/material.dart';
import 'package:magic_teleprompter/others/tools/GlobalTool.dart';
import 'IOSCameraView.dart';

class UseIOSPrompterPage extends StatefulWidget {
  UseIOSPrompterPage({Key key}) : super(key: key);

  @override
  _UseIOSPrompterPageState createState() => _UseIOSPrompterPageState();
}

class _UseIOSPrompterPageState extends State<UseIOSPrompterPage> {
  IOSCameraView _cameraView = IOSCameraView();

  @override
  void initState() {
    super.initState();

    Future.delayed(Duration(milliseconds: 3000), () {
      print("UseIOSPrompterPage");
      _cameraView.resetSkinFilter();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      color: randomColor(),
      child: Center(
        child: Container(
          width: 300,
          height: 500,
          color: randomColor(),
          child: _cameraView,
        ),
      ),
    );
  }
}
