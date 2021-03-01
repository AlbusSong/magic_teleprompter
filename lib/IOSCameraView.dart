import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:magic_teleprompter/others/models/BeautyEffectSettings.dart';

const String vType = "ios_camera_view";

typedef CameraViewHandler = void Function(String videoPath, String error);
typedef CameraViewUpdateDurationHandler = void Function(double duration);

// ignore: must_be_immutable
class IOSCameraView extends StatelessWidget {
  IOSCameraView(this.resultHandler, this.updateDurationHandler);

  MethodChannel _channel;

  final CameraViewHandler resultHandler;
  final CameraViewUpdateDurationHandler updateDurationHandler;

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
    Map params = call.arguments;
    if (call.method == "returnVideoRecordedPath") {
      String videoPath = params["videoPath"];
      debugPrint("returnVideoRecordedPath: $videoPath");
      if (this.resultHandler != null) {
        this.resultHandler(videoPath, null);
      }
    } else if (call.method == "updateRecordingDuration") {
      double duration = params["duration"];
      debugPrint("updateRecordingDuration: $duration");
      if (this.updateDurationHandler != null) {
        this.updateDurationHandler(duration);
      }
    } else if (call.method == "reportRecordingError") {
      String error = params["error"];
      debugPrint('reportRecordingError: $error');
      if (this.resultHandler != null) {
        this.resultHandler(null, error);
      }
    }
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

  void rotateCamera() {
    _channel.invokeMethod("rotateCamera", null);
  }

  void turnFlashLight(bool on) {
    _channel.invokeMethod("turnFlashLight", {"on": on});
  }

  void resetCameraRatio(String ratio) {
    _channel.invokeMethod("resetCameraRatio", {"ratio": ratio});
  }

  void startToRecord() {
    _channel.invokeMethod("startToRecord", null);
  }

  void finishRecording() {
    _channel.invokeMethod("finishRecording", null);
  }

  void resetSkinEffect() {
    for (String p in BeautyEffectSettings().beautyEffectParaNames1) {
      this.changeSkinEffect(p, 0);
    }
  }

  void resetPlasticEffect() {
    for (String p in BeautyEffectSettings().beautyEffectParaNames2) {
      this.changePlasticEffect(p, 0);
    }
  }

  void destoryCamera() {
    _channel.invokeMethod("destoryCamera", null);
  }

  void dispose() {
    this._channel = null;
  }
}
