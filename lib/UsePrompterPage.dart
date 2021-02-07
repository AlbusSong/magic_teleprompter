import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// import 'package:camerawesome/camerawesome_plugin.dart';
// import 'package:camerawesome/models/orientations.dart';
import 'package:flutter/services.dart';
import 'package:magic_teleprompter/others/tools/GlobalTool.dart';
import 'package:camera/camera.dart';
import 'package:magic_teleprompter/others/tools/HudTool.dart';
import 'others/models/Trifle.dart';
import 'models/PromterModel.dart';
import 'others/models/TextAreaSettings.dart';
import 'others/tools/NotificationCenter.dart';

import 'PromterTextAreaSettingPage.dart';

class UsePrompterPage extends StatefulWidget {
  UsePrompterPage(this.dataModel);
  PromterModel dataModel;

  @override
  State<StatefulWidget> createState() {
    return _UsePrompterPageState(this.dataModel);
  }
}

class _UsePrompterPageState extends State<UsePrompterPage> {
  _UsePrompterPageState(this.dataModel);
  PromterModel dataModel;

  Timer timer;

  CameraController _controller;
  Future<void> _initializeControllerFuture;
  TextEditingController _txtController;
  ScrollController _txtScrollController;
  double txtOffsetY = 0.0;
  bool isBeingScrolled = false;

  // 文字区域
  double textAreaLeft = 20;
  double textAreaTop = 300;
  double textAreaWidth = 300;
  double textAreaHeight = 200;

  // 拖动偏移
  Offset initialLocalPanOffset = Offset.zero;
  Offset initialGlobalPanOffset = Offset.zero;

  // 文字设置相关
  TextAreaSettings txtSettings = TextAreaSettings();

  // 弹出相机设置条
  bool isCameraSettingsShowing = false;
  // 弹出视频比例设置条
  bool isCameraRatioSettingsShowing = false;

  /// 视频宽高比
  /// 0， 全屏
  /// 1， 9:16
  /// 2， 3:4
  /// 3， 1:1
  int cameraRatio = 0;

  // 闪光灯是否开启
  bool isFlashLightOn = false;

  // 是否是前置摄像头
  bool isFrontCamera = true;

  // 是否正在录制
  bool isRecording = false;
  // 录制按钮的属性
  double recordBtnSize = 42;
  double recordBtnRadius = 21;
  String recordBtnColorHexString = "69C53B";

  @override
  void initState() {
    super.initState();

    if (listLength(Trifle().cameras) > 0) {
      _controller = CameraController(
        // Get a specific camera from the list of available cameras.
        Trifle().cameras[0],
        // Define the resolution to use.
        ResolutionPreset.veryHigh,
      );
      _initializeControllerFuture = _controller.initialize();
      _controller.prepareForVideoRecording();
    }
    // 预估大概时间
    this.txtSettings.textScrollingSpeed =
        ((stringLength(this.dataModel.content) * 60.0) / 190.0);

    _txtController = TextEditingController(text: dataModel.content);
    _txtScrollController = ScrollController();
    _txtScrollController.addListener(() {
      print("dkksddddlsl: ${this._txtScrollController.offset}");
      this.txtOffsetY = this._txtScrollController.offset;
    });

    // observer
    NotificationCenter().addObserver("textAreaSettingsChanged", (obj) {
      setState(() {
        TextAreaSettings newSettings = (obj as TextAreaSettings);
        this.txtSettings = newSettings;
        print("textAreaSettingsChanged: $newSettings");
      });
      this.txtSettings.cacheLocalSettings();
    });

    // textAreaSettingsScrollingDurationChanged
    // observer
    NotificationCenter().addObserver("textAreaSettingsScrollingDurationChanged",
        (obj) {
      TextAreaSettings newSettings = (obj as TextAreaSettings);
      this.txtSettings = newSettings;
      if (this.isBeingScrolled == true) {
        this.startTimer();
      }
    });
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    if (_controller != null) {
      _controller.dispose();
    }
    if (_txtController != null) {
      _txtController.dispose();
    }
    if (_txtScrollController != null) {
      _txtScrollController.dispose();
    }
    this.killTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      // appBar: AppBar(
      //   backgroundColor: Colors.transparent,
      //   brightness: Brightness.dark,
      //   automaticallyImplyLeading: false,
      // ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return FutureBuilder<void>(
      future: _initializeControllerFuture,
      builder: (context, snapshot) {
        return _realBody();
        // if (snapshot.connectionState == ConnectionState.done) {
        //   // If the Future is complete, display the preview.
        //   return _realBody();
        // } else {
        //   // Otherwise, display a loading indicator.
        //   return Center(child: CircularProgressIndicator());
        // }
      },
    );
  }

  Widget _realBody() {
    return Container(
      child: Stack(
        alignment: Alignment.center,
        children: [
          _buildCameraArea(),
          _buildBackBtn(),
          _buildMenuBtn(),
          _buildRecordBtnArea(),
          _buildTextArea(),
          _buildCameraFunctionPillar(),
          _buildCameraRatioPillar(),
        ],
      ),
    );
  }

  Widget _buildCameraArea() {
    if (_controller == null) {
      return Container();
    } else {
      return AspectRatio(
          aspectRatio: 1.0 / _controller.value.aspectRatio,
          child: CameraPreview(_controller));
    }
  }

  Widget _buildTextArea() {
    return Positioned(
      left: this.textAreaLeft,
      top: this.textAreaTop,
      child: GestureDetector(
        child: Container(
          // color: randomColor(),
          width: this.textAreaWidth,
          height: this.textAreaHeight,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(6)),
              border: new Border.all(width: 1, color: hexColor("999999")),
              color: hexColor(this.txtSettings.backgroundHexColorString,
                  this.txtSettings.backgroundAlpha)),
          clipBehavior: Clip.hardEdge,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildTextAreaFunctionBar(),
              _buildTextAreaContent(),
            ],
          ),
        ),
        onPanStart: (DragStartDetails details) {
          print("onPanStart: ${details.localPosition}");
          this.initialLocalPanOffset = details.localPosition;
          this.initialGlobalPanOffset = details.globalPosition;
        },
        onPanUpdate: (DragUpdateDetails details) {
          // print("onPanUpdate: ${details.globalPosition}");
          double deltaX =
              details.globalPosition.dx - this.initialGlobalPanOffset.dx;
          double deltaY =
              details.globalPosition.dy - this.initialGlobalPanOffset.dy;
          double comingX = this.textAreaLeft + deltaX;
          double comingY = this.textAreaTop + deltaY;
          this.initialGlobalPanOffset = details.globalPosition;
          setState(() {
            // this.textAreaLeft = comingX;
            // this.textAreaTop = comingY;

            if (this.initialLocalPanOffset.dx > 0 &&
                this.initialLocalPanOffset.dx < (10 + 24 + 10) &&
                this.initialLocalPanOffset.dy > 0 &&
                this.initialLocalPanOffset.dy < 32) {
              // 更改尺寸
              this.textAreaWidth -= deltaX;
              this.textAreaHeight -= deltaY;
              this.textAreaLeft += deltaX;
              this.textAreaTop += deltaY;
            } else {
              this.textAreaLeft += deltaX;
              this.textAreaTop += deltaY;
            }
          });
        },
        onPanCancel: () {
          this.initialLocalPanOffset = Offset.zero;
          this.initialGlobalPanOffset = Offset.zero;
        },
        onPanDown: (DragDownDetails details) {
          this.initialLocalPanOffset = Offset.zero;
          this.initialGlobalPanOffset = Offset.zero;
        },
      ),
    );
  }

  Widget _buildTextAreaFunctionBar() {
    return Container(
      height: 32,
      // color: randomColor(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            // color: randomColor(),
            padding: EdgeInsets.fromLTRB(10, 7, 10, 7),
            child: Image.asset(
              "assets/images/拍摄-设置大小按钮.png",
              width: 24,
              height: 20,
              fit: BoxFit.contain,
            ),
          ),
          Expanded(child: SizedBox(height: 1)),
          Container(
            // color: randomColor(),
            padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
            child: GestureDetector(
              child: Image.asset(
                (this.isBeingScrolled
                    ? "assets/images/拍摄-暂停文本按钮.png"
                    : "assets/images/拍摄-播放文本按钮.png"),
                width: 24,
                height: 24,
                fit: BoxFit.contain,
              ),
              onTap: () {
                print("lllll");
                if (this.isBeingScrolled == false) {
                  this.startTimer();
                } else {
                  this.killTimer();
                }
                setState(() {});
              },
            ),
          ),
          Expanded(child: SizedBox(height: 1)),
          Container(
            // color: randomColor(),
            padding: EdgeInsets.fromLTRB(10, 4, 10, 4),
            child: GestureDetector(
              child: Image.asset(
                "assets/images/拍摄-设置文本按钮.png",
                width: 24,
                height: 24,
                fit: BoxFit.contain,
              ),
              onTap: () {
                print("lllll");
                _popTextAreaSettings();
              },
            ),
          )
        ],
      ),
    );
  }

  Widget _buildCameraFunctionPillar() {
    return Positioned(
      right: 15,
      bottom: 72,
      width: 50,
      child: Offstage(
        offstage: (this.isCameraSettingsShowing == false),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(6)),
            border: new Border.all(width: 1, color: hexColor("999999")),
            color: hexColor("ffffff", 0.3),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                child: Container(
                  width: 50,
                  height: 50,
                  padding: EdgeInsets.all(13),
                  child: ColorFiltered(
                    colorFilter: ColorFilter.mode(
                        (this.isFrontCamera
                            ? Colors.white
                            : hexColor("bbbbbb")),
                        BlendMode.modulate),
                    child: Image.asset(
                      "assets/images/拍摄-反转相机按钮.png",
                      width: 24,
                      height: 24,
                    ),
                  ),
                ),
                onTap: () {
                  setState(() {
                    this.isFrontCamera = !this.isFrontCamera;
                  });
                },
              ),
              GestureDetector(
                child: Container(
                  width: 50,
                  height: 50,
                  padding: EdgeInsets.all(13),
                  child: ColorFiltered(
                    colorFilter: ColorFilter.mode(
                        (this.isFlashLightOn
                            ? hexColor("E8D23A")
                            : Colors.white),
                        BlendMode.modulate),
                    child: Image.asset(
                      "assets/images/拍摄-闪光灯按钮.png",
                      width: 24,
                      height: 24,
                    ),
                  ),
                ),
                onTap: () {
                  setState(() {
                    this.isFlashLightOn = !this.isFlashLightOn;
                  });
                },
              ),
              GestureDetector(
                child: Container(
                  width: 50,
                  height: 50,
                  padding: EdgeInsets.all(14),
                  child: ColorFiltered(
                    colorFilter: ColorFilter.mode(
                        this.isCameraRatioSettingsShowing
                            ? Colors.red
                            : Colors.white,
                        BlendMode.modulate),
                    child: Image.asset(
                      "assets/images/拍摄-屏幕比例按钮.png",
                      width: 24,
                      height: 24,
                    ),
                  ),
                ),
                onTap: () {
                  print("拍摄-屏幕比例");
                  setState(() {
                    this.isCameraRatioSettingsShowing =
                        !this.isCameraRatioSettingsShowing;
                  });
                },
              ),
              GestureDetector(
                child: Container(
                  width: 50,
                  height: 50,
                  padding: EdgeInsets.all(13),
                  child: Image.asset(
                    "assets/images/拍摄-美颜滤镜按钮.png",
                    width: 24,
                    height: 24,
                  ),
                ),
                onTap: () {
                  print("美颜滤镜");
                  HudTool.showInfoWithStatus("美颜功能尚未开通\n敬请期待下一版本");
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCameraRatioPillar() {
    return Positioned(
      left: 15,
      bottom: 72,
      width: 50,
      child: Offstage(
        offstage: (this.isCameraRatioSettingsShowing == false),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(6)),
            border: new Border.all(width: 1, color: hexColor("999999")),
            color: hexColor("ffffff", 0.3),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                child: Container(
                  width: 50,
                  height: 50,
                  padding: EdgeInsets.all(8),
                  child: ColorFiltered(
                    colorFilter: ColorFilter.mode(
                        (this.cameraRatio == 0 ? Colors.red : Colors.white),
                        BlendMode.modulate),
                    child: Image.asset(
                      "assets/images/拍摄-屏幕比例-全屏-按钮.png",
                      width: 24,
                      height: 24,
                    ),
                  ),
                ),
                onTap: () {
                  _tryToChangeCameraRadio(0);
                },
              ),
              GestureDetector(
                child: Container(
                  width: 50,
                  height: 50,
                  padding: EdgeInsets.all(8),
                  child: ColorFiltered(
                    colorFilter: ColorFilter.mode(
                        (this.cameraRatio == 1 ? Colors.red : Colors.white),
                        BlendMode.modulate),
                    child: Image.asset(
                      "assets/images/拍摄-屏幕比例-9-16-按钮.png",
                      width: 24,
                      height: 24,
                    ),
                  ),
                ),
                onTap: () {
                  _tryToChangeCameraRadio(1);
                },
              ),
              GestureDetector(
                child: Container(
                  width: 50,
                  height: 50,
                  padding: EdgeInsets.all(8),
                  child: ColorFiltered(
                    colorFilter: ColorFilter.mode(
                        (this.cameraRatio == 2 ? Colors.red : Colors.white),
                        BlendMode.modulate),
                    child: Image.asset(
                      "assets/images/拍摄-屏幕比例-3-4-按钮.png",
                      width: 24,
                      height: 24,
                    ),
                  ),
                ),
                onTap: () {
                  _tryToChangeCameraRadio(2);
                },
              ),
              GestureDetector(
                child: Container(
                  width: 50,
                  height: 50,
                  padding: EdgeInsets.all(8),
                  child: ColorFiltered(
                    colorFilter: ColorFilter.mode(
                        (this.cameraRatio == 3 ? Colors.red : Colors.white),
                        BlendMode.modulate),
                    child: Image.asset(
                      "assets/images/拍摄-屏幕比例-1-1-按钮.png",
                      width: 24,
                      height: 24,
                    ),
                  ),
                ),
                onTap: () {
                  _tryToChangeCameraRadio(3);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextAreaContent() {
    return Expanded(
      child: Container(
        padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
        // color: randomColor(),
        child: Scrollbar(
          thickness: 3,
          child: TextField(
            controller: _txtController,
            scrollController: _txtScrollController,
            minLines: 1,
            maxLines: null,
            // maxLines: 100000,
            readOnly: true,
            style: TextStyle(
                fontSize: this.txtSettings.fontSize,
                color: hexColor(this.txtSettings.textHexColorString)),
            decoration: InputDecoration(
              border: InputBorder.none,
            ),
          ),
        ),

        // child: Text(
        //   this.dataModel.content,
        //   style: TextStyle(
        //       fontSize: this.txtSettings.fontSize,
        //       color: hexColor(this.txtSettings.textHexColorString)),
        // ),
      ),
    );
  }

  Widget _buildRecordBtnArea() {
    return Positioned(
      bottom: 5,
      child: Container(
        // color: randomColor(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _buildRecordBtn(),
            _buildRecordedTime(),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordBtn() {
    return GestureDetector(
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(50.0 / 2)),
          border: Border.all(width: 3, color: hexColor("D8D8D8", 0.5)),
          // color: hexColor("D8D8D8", 0.5),
        ),
        child: Center(
          child: AnimatedContainer(
            width: this.recordBtnSize,
            height: this.recordBtnSize,
            curve: Curves.linear,
            duration: Duration(milliseconds: 500),
            decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.all(Radius.circular(this.recordBtnRadius)),
                color: hexColor(this.recordBtnColorHexString)),
          ),
        ),
      ),
      onTap: () {
        setState(() {
          this.isRecording = !this.isRecording;
          if (this.isRecording) {
            this.recordBtnSize = 25;
            this.recordBtnRadius = 6;
            this.recordBtnColorHexString = "C9371C";
          } else {
            this.recordBtnSize = 42;
            this.recordBtnRadius = 21;
            this.recordBtnColorHexString = "69C53B";
          }
        });
      },
    );
  }

  Widget _buildRecordedTime() {
    return Container(
      margin: EdgeInsets.only(top: 3),
      height: 14,
      // color: randomColor(),
      child: Text(
        "0:00",
        style: TextStyle(color: Colors.white, fontSize: 10),
      ),
    );
  }

  Widget _buildMenuBtn() {
    return Positioned(
      right: 5,
      bottom: 5,
      child: Container(
        child: IconButton(
          splashRadius: 25,
          icon: Image.asset(
            "assets/images/拍摄-菜单按钮.png",
            width: 23,
            height: 23,
            fit: BoxFit.contain,
          ),
          onPressed: () {
            print("Go back");
            setState(() {
              this.isCameraSettingsShowing = !this.isCameraSettingsShowing;
              if (this.isCameraSettingsShowing == false) {
                this.isCameraRatioSettingsShowing = false;
              }
            });
          },
        ),
      ),
    );
  }

  Widget _buildBackBtn() {
    return Positioned(
      left: 5,
      bottom: 5,
      child: Container(
        child: IconButton(
          splashRadius: 25,
          icon: Image.asset(
            "assets/images/拍摄-返回按钮.png",
            width: 25,
            height: 25,
            fit: BoxFit.contain,
          ),
          onPressed: () {
            print("Go back");
            _goBack();
          },
        ),
      ),
    );
  }

  void _goBack() {
    if (_controller != null) {
      _controller.dispose();
    }
    Navigator.pop(context);
  }

  void _popTextAreaSettings() {
    PageRouteBuilder _router = PageRouteBuilder(
        opaque: false,
        pageBuilder: (context, animation, secondaryAnimation) =>
            PromterTextAreaSettingPage(this.txtSettings),
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
    Navigator.push(context, _router);
  }

  void killTimer() {
    if (this.timer != null) {
      this.timer.cancel();
      this.timer = null;
    }
    this.isBeingScrolled = false;
  }

  void startTimer() {
    this.killTimer();

    this.isBeingScrolled = true;
    // double duration = this.txtSettings.textScrollingSpeed * 10.0;
    double totolOffsetDistance =
        this._txtScrollController.position.maxScrollExtent +
            this.textAreaHeight -
            40;
    double offsetPerSecond =
        totolOffsetDistance / (this.txtSettings.textScrollingSpeed * 1.0);

    this.timer = Timer.periodic(Duration(milliseconds: 1000), (tm) {
      // print("llll:  ${tm.tick}");
      if (this.txtOffsetY >= totolOffsetDistance) {
        this.killTimer();
        return;
      }
      this.txtOffsetY += offsetPerSecond;
      // print(
      // "lllllllaaaa: ${this._txtScrollController.position.maxScrollExtent}, ${this.txtOffsetY}");
      this._txtScrollController.animateTo(this.txtOffsetY,
          duration: Duration(milliseconds: 1000), curve: Curves.linear);
    });
  }

  void _tryToChangeCameraRadio(int r) {
    setState(() {
      this.cameraRatio = r;
    });
  }
}
