import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// import 'package:camerawesome/camerawesome_plugin.dart';
// import 'package:camerawesome/models/orientations.dart';
import 'package:flutter/services.dart';
import 'package:magic_teleprompter/others/tools/GlobalTool.dart';
import 'package:magic_teleprompter/others/tools/OrientationTool.dart';
import 'package:camera/camera.dart';
import 'package:magic_teleprompter/others/tools/HudTool.dart';
import 'others/models/Trifle.dart';
import 'models/PromterModel.dart';
import 'others/models/TextAreaSettings.dart';
import 'others/tools/NotificationCenter.dart';
import 'package:sweetsheet/sweetsheet.dart';
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:speech_to_text_platform_interface/speech_to_text_platform_interface.dart';
import 'others/third_party/Dart-Searchify/Dart_Searchify.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import 'PromterTextAreaSettingPage.dart';
import 'VideoPlayerPage.dart';
import 'CustomCameraPreview.dart';

class UsePrompterPage extends StatefulWidget {
  UsePrompterPage(this.dataModel);
  PromterModel dataModel;

  @override
  State<StatefulWidget> createState() {
    return _UsePrompterPageState(this.dataModel);
  }
}

class _UsePrompterPageState extends State<UsePrompterPage>
    with TickerProviderStateMixin {
  _UsePrompterPageState(this.dataModel);
  PromterModel dataModel;

  final SweetSheet _sweetSheet = SweetSheet();

  Timer timer;
  Timer timerForRecording;

  CameraController _cameraController;
  TextEditingController _txtController;
  ScrollController _txtScrollController;
  double txtOffsetY = 0.0;
  bool isBeingScrolled = false;

  // 文字区域
  double textAreaLeft = 20;
  double textAreaTop = 300;
  double textAreaWidth = 300;
  double textAreaHeight = 200;

  // 拖动偏移、点击事件
  Offset initialLocalPanOffset = Offset.zero;
  Offset initialGlobalPanOffset = Offset.zero;
  Offset tapGlobalPanOffset = Offset.zero;

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
  // 与宽高比相应的遮照高度
  double cameraRadioMaskAreaHeight = 0;

  // 闪光灯是否开启
  bool isFlashLightOn = false;

  // 是否是前置摄像头
  bool isFrontCamera = true;

  // 是否正在录制
  bool isRecording = false;
  int startingRecordTimeStamp = 0;
  String recordingTimeString = "00:00";
  // 录制按钮的属性
  double recordBtnSize = 42;
  double recordBtnRadius = 21;
  String recordBtnColorHexString = "69C53B";

  // 动画
  AnimationController _animController;
  Animation<double> _focusRectAnim;
  bool _shouldAppearFocusRect = false;

  // 语音识别模式还是滚动模式
  bool _isAISpeechMode = true;
  // 语音模式下的滚动控制器
  final ItemScrollController _itemScrollController = ItemScrollController();
  // 语音转文字
  final SpeechToText speech = SpeechToText();
  List<String> sentenceList;
  int currentRecognitionIndex = 0;

  @override
  void initState() {
    super.initState();

    _resetCameraController();

    _initTextToSpeechFunction();

    _animController =
        AnimationController(duration: Duration(milliseconds: 200), vsync: this)
          ..addStatusListener((status) {
            if (status == AnimationStatus.completed) {
              _animController.reset();
              setState(() {
                this._shouldAppearFocusRect = false;
              });
            }
          });
    _focusRectAnim =
        Tween<double>(begin: 1.25, end: 1).animate(_animController);

    OrientationTool().addOrientationChangeHandler((o1, o2) {
      print("o1: $o1, o2: $o2");
      OrientationTool().forceOrientation(o2).then((v) {
        // _tryToRePositionTextArea(o1, o2);
        setState(() {});
      });
    });

    // 预估大概时间
    this.txtSettings.textScrollingSpeed =
        ((stringLength(this.dataModel.content) * 60.0) / 190.0);

    _txtController = TextEditingController(text: dataModel.content);
    _txtScrollController = ScrollController();
    _txtScrollController.addListener(() {
      // print("dkksddddlsl: ${this._txtScrollController.offset}");
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

  void _initTextToSpeechFunction() async {
    this.sentenceList = splitStringByPunctuation(this.dataModel.content);
    print("this.sentenceList: ${this.sentenceList}");
    bool available = await speech.initialize();
    List localeNames = await speech.locales();
    var systemLocale = await speech.systemLocale();
    print("ldldldlld; ${systemLocale.localeId}, ${systemLocale.name}");
    List cc = [];
    for (var l in localeNames) {
      cc.add(l.localeId);
    }
    // print("localeNames: $cc");
    if (available) {
      speech.listen(
          onResult: _tryToHandleSpeechRecognitionResult,
          listenFor: Duration(minutes: 15),
          pauseFor: Duration(seconds: 20),
          partialResults: true,
          localeId: "zh-CN",
          onSoundLevelChange: null,
          cancelOnError: false,
          listenMode: ListenMode.dictation);
    } else {
      print("The user has denied the use of speech recognition.");
    }
  }

  Future _resetCameraController() async {
    int count = listLength(Trifle().cameras);
    if (count == 0) {
      return;
    }

    int cameraIndex = 0;
    if (count == 2 && this.isFrontCamera) {
      cameraIndex = 1;
    }

    _cameraController = CameraController(
      // Get a specific camera from the list of available cameras.
      Trifle().cameras[cameraIndex],
      // Define the resolution to use.
      ResolutionPreset.veryHigh,
    );
    await _cameraController.initialize();
    _cameraController.prepareForVideoRecording();
    setState(() {});
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    if (_cameraController != null) {
      _cameraController.dispose();
    }
    if (_txtController != null) {
      _txtController.dispose();
    }
    if (_txtScrollController != null) {
      _txtScrollController.dispose();
    }

    if (_animController != null) {
      _animController.dispose();
    }
    this.killTimer();
    this.killTimerForRecording();
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
    return WillPopScope(
        child: _realBody(),
        onWillPop: () async {
          return false;
        });
    // return FutureBuilder<void>(
    //   future: _initializeControllerFuture,
    //   builder: (context, snapshot) {
    //     return _realBody();
    //     if (snapshot.connectionState == ConnectionState.done) {
    //       // If the Future is complete, display the preview.
    //       return _realBody();
    //     } else {
    //       // Otherwise, display a loading indicator.
    //       return Center(child: CircularProgressIndicator());
    //     }
    //   },
    // );
  }

  Widget _realBody() {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: Stack(
        alignment: Alignment.center,
        children: [
          _buildCameraArea(),
          _buildFocusRect(),
          _buildCameraEdgeArea1(),
          _buildCameraEdgeArea2(),
          _buildTextArea(),
          _buildBackBtn(),
          _buildMenuBtn(),
          _buildRecordBtnArea(),
          _buildCameraFunctionPillar(),
          _buildCameraRatioPillar(),
        ],
      ),
    );
  }

  Widget _buildCameraArea() {
    if (_cameraController == null) {
      return Container();
    } else {
      return GestureDetector(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: CustomCameraPreview(_cameraController),
        ),
        onTapDown: (TapDownDetails details) {
          this.tapGlobalPanOffset = details.globalPosition;
        },
        onTap: () {
          _tryToSetCameraFocus();
        },
      );
      // return AspectRatio(
      //     aspectRatio: (OrientationTool().isPortrait()
      //         ? (1.0 / _cameraController.value.aspectRatio)
      //         : _cameraController.value.aspectRatio),
      //     child: CameraPreview(_cameraController));
    }
  }

  Widget _buildFocusRect() {
    return Positioned(
      left: this.tapGlobalPanOffset.dx - 25,
      top: this.tapGlobalPanOffset.dy - 25,
      child: Offstage(
        offstage: (this._shouldAppearFocusRect == false),
        child: ScaleTransition(
          scale: _focusRectAnim,
          child: Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(1)),
              border: new Border.all(
                width: 2,
                color: hexColor("E5B353"),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCameraEdgeArea1() {
    if (OrientationTool().isPortrait()) {
      return Positioned(
        left: 0,
        top: 0,
        width: MediaQuery.of(context).size.width,
        height: this.cameraRadioMaskAreaHeight,
        child: Container(color: Colors.black),
      );
    } else {
      return Positioned(
        left: 0,
        top: 0,
        width: this.cameraRadioMaskAreaHeight,
        height: MediaQuery.of(context).size.height,
        child: Container(color: Colors.black),
      );
    }
  }

  Widget _buildCameraEdgeArea2() {
    if (OrientationTool().isPortrait()) {
      return Positioned(
        right: 0,
        bottom: 0,
        width: MediaQuery.of(context).size.width,
        height: this.cameraRadioMaskAreaHeight,
        child: Container(color: Colors.black),
      );
    } else {
      return Positioned(
        right: 0,
        bottom: 0,
        width: this.cameraRadioMaskAreaHeight,
        height: MediaQuery.of(context).size.height,
        child: Container(color: Colors.black),
      );
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
              border: new Border.all(width: 1, color: hexColor("bbbbbb")),
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
            border: new Border.all(width: 1, color: hexColor("666666")),
            color: hexColor("000000", 0.4),
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
                  _tryToFlipCamera();
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
                  _tryToSwitchFlashLight();
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
            border: new Border.all(width: 1, color: hexColor("666666")),
            color: hexColor("000000", 0.4),
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
    if (this._isAISpeechMode) {
      return Expanded(
        child: Container(
          padding: EdgeInsets.fromLTRB(15, 5, 15, 5),
          // color: randomColor(),
          child: ScrollablePositionedList.builder(
            itemScrollController: _itemScrollController,
            itemCount: listLength(this.sentenceList),
            itemBuilder: (context, index) {
              return _buildSentenceItem(index);
            },
          ),
        ),
      );
    } else {
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
        ),
      );
    }
  }

  Widget _buildSentenceItem(int index) {
    String sentenceStr = this.sentenceList[index];
    return Container(
      // color: randomColor(),
      margin: EdgeInsets.only(top: 10),
      child: Center(
        child: Text(
          avoidNull(sentenceStr),
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: this.txtSettings.fontSize,
              color: (this.currentRecognitionIndex != index)
                  ? hexColor(this.txtSettings.textHexColorString)
                  : Colors.red),
        ),
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
          border: Border.all(width: 3, color: hexColor("ffffff", 0.8)),
          // color: hexColor("D8D8D8", 0.5),
        ),
        child: Center(
          child: AnimatedContainer(
            width: this.recordBtnSize,
            height: this.recordBtnSize,
            curve: Curves.linear,
            duration: Duration(milliseconds: 300),
            decoration: BoxDecoration(
                borderRadius:
                    BorderRadius.all(Radius.circular(this.recordBtnRadius)),
                color: hexColor(this.recordBtnColorHexString)),
          ),
        ),
      ),
      onTap: () {
        _tryToRecordVideo();
      },
    );
  }

  Widget _buildRecordedTime() {
    return Container(
      margin: EdgeInsets.only(top: 3),
      height: 14,
      // color: randomColor(),
      child: Text(
        this.recordingTimeString,
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
            _tryToGoBack();
          },
        ),
      ),
    );
  }

  void _tryToGoBack() {
    _sweetSheet.show(
      context: context,
      title: Text("退出拍摄？"),
      description: Text('退出拍摄，重新选词'),
      color: SweetSheetColor.WARNING,
      // icon: Icons.portable_wifi_off,
      positive: SweetSheetAction(
        onPressed: () {
          Navigator.of(context).pop();
          _goBack();
        },
        title: "退出",
      ),
    );
  }

  void _goBack() {
    if (_cameraController != null) {
      _cameraController.dispose();
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

  void killTimerForRecording() {
    if (this.timerForRecording != null) {
      this.timerForRecording.cancel();
      this.timerForRecording = null;
    }

    setState(() {
      this.isRecording = false;
      this.startingRecordTimeStamp = 0;
      this.recordingTimeString = "00:00";
    });
  }

  void startTimerForRecording() {
    this.killTimerForRecording();

    this.isRecording = true;
    this.startingRecordTimeStamp = DateTime.now().millisecondsSinceEpoch;
    this.timerForRecording = Timer.periodic(Duration(milliseconds: 100), (tm) {
      if (tm.tick % 10 == 0) {
        int newTimeStamp = DateTime.now().millisecondsSinceEpoch;
        int diffSeconds = (newTimeStamp - startingRecordTimeStamp) ~/ 1000;
        _showRecordingTime(diffSeconds);
      }
      print("lssdkssk: ${tm.tick}");
    });
  }

  void _showRecordingTime(int d) {
    if (d < 10) {
      this.recordingTimeString = '00:0$d';
    } else if (d < 60) {
      this.recordingTimeString = '00:$d';
    } else {
      int minutes = d ~/ 60;
      int remnantSeconds = d - minutes * 60;
      if (minutes < 10) {
        if (remnantSeconds < 10) {
          this.recordingTimeString = '0$minutes:0$remnantSeconds';
        } else {
          this.recordingTimeString = '0$minutes:$remnantSeconds';
        }
      } else {
        if (remnantSeconds < 10) {
          this.recordingTimeString = '$minutes:0$remnantSeconds';
        } else {
          this.recordingTimeString = '$minutes:$remnantSeconds';
        }
      }
    }

    setState(() {});
  }

  Future _tryToRecordVideo() async {
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

    if (this.isRecording) {
      _cameraController.startVideoRecording();
      this.startTimerForRecording();
    } else {
      this.killTimerForRecording();
      XFile f = await _cameraController.stopVideoRecording();
      Navigator.of(context).push(MaterialPageRoute(
          builder: (BuildContext context) => VideoPlayerPage(f.path)));
      print("path: ${f.path}");
    }
  }

  void _tryToSwitchFlashLight() {
    if (this.isFrontCamera) {
      HudTool.showInfoWithStatus("前置摄像头无闪光灯");
      return;
    }
    setState(() {
      this.isFlashLightOn = !this.isFlashLightOn;
    });

    FlashMode m = FlashMode.torch;
    if (this.isFlashLightOn == false) {
      m = FlashMode.off;
    }
    _cameraController.setFlashMode(m);
    print("kkkkkk");
  }

  Future _tryToFlipCamera() async {
    if (listLength(Trifle().cameras) == 1) {
      HudTool.showErrorWithStatus("只有一个相机可用");
      return;
    }

    this.isFrontCamera = !this.isFrontCamera;
    await _resetCameraController();

    setState(() {});
  }

  void _tryToChangeCameraRadio(int r) {
    double screenW = MediaQuery.of(context).size.width;
    double screenH = MediaQuery.of(context).size.height;
    if (OrientationTool().isPortrait() == false) {
      double tmp = screenH;
      screenH = screenW;
      screenW = tmp;
    }
    double h = 0;
    double showingAreaH = screenH;
    if (r > 0) {
      if (r == 1) {
        showingAreaH = screenW * 16 / 9.0;
      } else if (r == 2) {
        showingAreaH = screenW * 4 / 3.0;
      } else if (r == 3) {
        showingAreaH = screenW;
      }
    }
    h = (screenH - showingAreaH) / 2.0;
    if (h < 0) {
      h = 0;
    }
    setState(() {
      this.cameraRatio = r;
      this.cameraRadioMaskAreaHeight = h;
    });
  }

  Future _tryToSetCameraFocus() async {
    setState(() {
      this._shouldAppearFocusRect = true;
    });
    _animController.forward();

    double x = this.tapGlobalPanOffset.dx / MediaQuery.of(context).size.width;
    double y = this.tapGlobalPanOffset.dy / MediaQuery.of(context).size.height;
    Offset focusPoint = Offset(x, y);
    print("focusPoint: $focusPoint");
    await _cameraController.setFocusPoint(focusPoint);
  }

  void _tryToHandleSpeechRecognitionResult(SpeechRecognitionResult result) {
    // print("alternates: ${result.alternates}");
    // print("recognizedWords: ${result.recognizedWords}");
    // print("SpeechRecognitionResult: $result");
    if (stringLength(result.recognizedWords) == 0) {
      return;
    }
    List allPossibleSentences =
        splitStringByPunctuation(result.recognizedWords);
    String currentSentence =
        '${allPossibleSentences[listLength(allPossibleSentences) - 1]}';
    // print("currentSentence: $currentSentence");
    _seekPosOfCurrentSentence(currentSentence);
  }

  void _seekPosOfCurrentSentence(String currentSentence) {
    List<String> allSubStrings = getAllSubStrings(currentSentence, 2, true);
    // print("allSubStrings: $allSubStrings");
    for (int i = this.currentRecognitionIndex;
        i < listLength(this.sentenceList);
        i++) {
      bool found = false;
      String originalSentence = this.sentenceList[i];
      for (int j = 0; j < listLength(allSubStrings); j++) {
        Pattern pattern = Pattern(allSubStrings[j]);
        if (pattern.matches(originalSentence, Search.KNUTH_MORRIS)) {
          found = true;
          break;
        }
      }
      if (found) {
        this.currentRecognitionIndex = i;
        break;
      }
    }

    print("currentRecognitionIndex: $currentRecognitionIndex");
    setState(() {});
    _itemScrollController.scrollTo(
        index: this.currentRecognitionIndex,
        duration: Duration(milliseconds: 300),
        curve: Curves.linear);
  }

  // void _tryToRePositionTextArea(DeviceOrientation o1, DeviceOrientation o2) {
  //   double oldScreenWidth = MediaQuery.of(context).size.width;
  //   double oldScreenHeight = MediaQuery.of(context).size.height;
  //   double newScreenWidth = MediaQuery.of(context).size.height;
  //   double newScreenHeight = MediaQuery.of(context).size.width;
  //   print(
  //       "oldScreenWidth: $oldScreenWidth, oldScreenHeight: $oldScreenHeight, newScreenWidth: $newScreenWidth, newScreenHeight: $newScreenHeight");
  //   if (OrientationTool().isPortrait(o2)) {
  //   } else {
  //     double oldRatioW = this.textAreaLeft / oldScreenWidth;
  //     double oldRatioH = this.textAreaTop / oldScreenWidth;
  //     setState(() {
  //       this.textAreaLeft = oldRatioW * newScreenWidth;
  //       this.textAreaTop = oldRatioH * newScreenHeight;
  //     });
  //   }
  // }
}
