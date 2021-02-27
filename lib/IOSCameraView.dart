import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const String vType = "ios_camera_view";

// class IOSCameraView extends StatefulWidget {
//   @override
//   State<StatefulWidget> createState() {
//     // TODO: implement createState
//     return _IOSCameraViewState();
//   }

//   void resetSkinFilter() {}
// }

// ignore: must_be_immutable
class IOSCameraView extends StatelessWidget {
  MethodChannel _channel;

  @override
  Widget build(BuildContext context) {
    return UiKitView(
      viewType: vType,
      creationParams: "hello",
      creationParamsCodec: StandardMessageCodec(),
      onPlatformViewCreated: (int d) {
        _onPlatformViewCreated(d);
      },
    );
  }

  void _onPlatformViewCreated(int theId) {
    _channel = MethodChannel('camera_view_$theId');
    // 设置平台通道的响应函数
    _channel.setMethodCallHandler(_handleMethod);
  }

  Future<void> _handleMethod(MethodCall call) async {
    // if (!mounted) {
    //   return Future.value();
    // }
    print("_handleMethod: ${call.method}");
    // switch (call.method) {
    //   default:
    //     throw UnsupportedError("Unrecognized method");
    // }
  }

  void resetSkinFilter() {
    print("resetSkinFilter");
    _channel.invokeMethod("resetSkinFilter", {"value": 3});
  }

  void changeSkinEffect(String paramName, double argPercent) {
    _channel.invokeMethod(
        "changeSkinEffect", {"paramName": paramName, "argPercent": argPercent});
  }

  void changePlasticEffect(String paramName, double argPercent) {
    _channel.invokeMethod("changePlasticEffect",
        {"paramName": paramName, "argPercent": argPercent});
  }
}
