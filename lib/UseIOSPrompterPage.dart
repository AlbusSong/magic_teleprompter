import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:magic_teleprompter/others/tools/GlobalTool.dart';
import 'package:magic_teleprompter/others/tools/OrientationTool.dart';
import 'package:magic_teleprompter/others/tools/HudTool.dart';
import 'others/models/CommonValues.dart';
import 'models/PromterModel.dart';
import 'others/models/TextAreaSettings.dart';
import 'others/tools/NotificationCenter.dart';
import 'package:sweetsheet/sweetsheet.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'others/third_party/Dart-Searchify/Dart_Searchify.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:permission_handler/permission_handler.dart';

import 'PromterTextAreaSettingPage.dart';
import 'IOSCameraView.dart';
import 'PrompterBeautySettingsPage.dart';
import 'VideoPlayerPage.dart';

// ignore: must_be_immutable
class UseIOSPrompterPage extends StatefulWidget {
  UseIOSPrompterPage(this.dataModel);
  PromterModel dataModel;

  @override
  State<StatefulWidget> createState() {
    return _UseIOSPrompterPageState(this.dataModel);
  }
}

class _UseIOSPrompterPageState extends State<UseIOSPrompterPage>
    with TickerProviderStateMixin {
  _UseIOSPrompterPageState(this.dataModel);
  PromterModel dataModel;

  final SweetSheet _sweetSheet = SweetSheet();

  IOSCameraView _cameraView;

  Timer timer;

  TextEditingController _txtController;
  ScrollController _txtScrollController;
  double txtOffsetY = 0.0;
  bool isBeingScrolled = false;

  // 文字区域
  double textAreaMinWidth = 150;
  double textAreaMinHeight = 80;
  double textAreaLeft = 30;
  double textAreaTop = CommonValues().statusHeight + 20;
  double textAreaWidth = (CommonValues().screenWidth - 30 * 2);
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

  // 闪光灯是否开启
  bool isFlashLightOn = false;

  // 是否是前置摄像头
  bool isFrontCamera = true;

  // 是否正在录制
  bool isRecording = false;
  double duration = 0;
  String recordingTimeString = "00:00";
  // 录制按钮的属性
  double recordBtnSize = 42;
  double recordBtnRadius = 21;
  String recordBtnColorHexString = "69C53B";

  // 动画
  AnimationController _animController;
  Animation<double> _focusRectAnim;
  bool _shouldAppearFocusRect = false;

  // 语音模式下的滚动控制器
  final ItemScrollController _itemScrollController = ItemScrollController();
  final ItemPositionsListener _itemPositionsListener =
      ItemPositionsListener.create();
  // 语音转文字
  SpeechToText speech;
  List<String> sentenceList;
  int currentRecognitionIndex = 0;

  @override
  void initState() {
    super.initState();

    CameraViewHandler resultHdl = (String videoPath, String error) {
      if (error != null) {
        HudTool.showErrorWithStatus(error);
      } else {
        print("videoPath: $videoPath");
        HudTool.dismiss();
        Navigator.of(context).push(MaterialPageRoute(
            builder: (BuildContext context) => VideoPlayerPage(videoPath)));
      }
    };
    CameraViewUpdateDurationHandler durationHdl = (double d) {
      this.duration = d;
      _showRecordingTime(d.toInt());
    };
    _cameraView = IOSCameraView(resultHdl, durationHdl);

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

    // _itemPositionsListener.itemPositions.addListener(() {
    //   print(
    //       "_itemPositionsListener.itemPositions: ${_itemPositionsListener.itemPositions}");
    // });

    // 预估大概时间
    this.txtSettings.textScrollingSpeed =
        ((stringLength(this.dataModel.content) * 60.0) / 190.0);
    if (this.txtSettings.textScrollingSpeed < 10.0) {
      this.txtSettings.textScrollingSpeed = 10.0;
    }

    _txtController = TextEditingController(text: dataModel.content);
    _txtScrollController = ScrollController();
    _txtScrollController.addListener(() {
      // print("dkksddddlsl: ${this._txtScrollController.offset}");
      this.txtOffsetY = this._txtScrollController.offset;
    });

    // observer
    NotificationCenter().addObserver("textAreaSettingsChanged", (obj) {
      // TextAreaSettings newSettings = (obj as TextAreaSettings);
      setState(() {});
      this.txtSettings.cacheLocalSettings();
    });

    // textAreaSettingsScrollingDurationChanged
    // observer
    NotificationCenter().addObserver("textAreaSettingsScrollingDurationChanged",
        (obj) {
      if (this.isBeingScrolled == true) {
        this.startTimer();
      }
    });

    _tryToInitSpeechTextFunction();
    NotificationCenter().addObserver("AISpeechRecognitionAuthorityGranted",
        (obj) {
      _tryToInitSpeechTextFunction();
    });

    NotificationCenter().addObserver("textAreaSettingsAISpeechModeChanged",
        (obj) {
      print("AI speech mode changed");
      setState(() {
        this.isBeingScrolled = false;
      });
      this.killTimer();
      this._tryToStopAISpeechListenning();
    });

    NotificationCenter().addObserver("textAreaSettingsAISpeechLanguageChanged",
        (obj) {
      print("language changed");
      if (TextAreaSettings().isAISpeechMode && this.isBeingScrolled) {
        _tryToStartAISpeechListenning();
      }
    });
  }

  Future _tryToInitSpeechTextFunction() async {
    PermissionStatus speechStatus = await Permission.speech.status;
    print("speechStatus: $speechStatus");
    if (speechStatus.isGranted == false) {
      print("AI语音识别功能未开启");
      return;
    }

    if (speech != null) {
      return;
    }

    speech = SpeechToText();
    this.sentenceList = splitStringByPunctuation(this.dataModel.content);
    print("this.sentenceList: ${this.sentenceList}");
    this.txtSettings.isAISpeechAvailable = await speech.initialize();
    this.txtSettings.localeNames = await speech.locales();
    // print("txtSettings.localeNames: ${txtSettings.localeNames}");
    LocaleName systemLocale = await speech.systemLocale();
    this.txtSettings.systemLocaleName = systemLocale;
    this.txtSettings.selectedLocaleName = systemLocale;
    print("ldldldlld; ${systemLocale.localeId}, ${systemLocale.name}");

    if (this.txtSettings.isAISpeechAvailable) {
    } else {
      print("The user has denied the use of speech recognition.");
    }
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    if (_cameraView != null) {
      _cameraView.destoryCamera();
      _cameraView.dispose();
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
    if (this.speech != null) {
      this.speech.stop();
      this.speech = null;
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return WillPopScope(
      child: _realBody(),
      onWillPop: () async {
        return false;
      },
    );
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

  /*
  https://cdn.pixabay.com/photo/2021/02/26/19/31/snowdrop-6052942_1280.jpg
  https://cdn.pixabay.com/photo/2017/09/01/12/52/girl-2704119_1280.jpg
  https://cdn.pixabay.com/photo/2011/09/27/18/52/bird-9950_1280.jpg
  */

  Widget _buildCameraArea() {
    // return Container(
    //   width: MediaQuery.of(context).size.width,
    //   height: MediaQuery.of(context).size.height,
    //   color: randomColor(),
    //   child: Image.network(
    //     "https://cdn.pixabay.com/photo/2011/09/27/18/52/bird-9950_1280.jpg",
    //     fit: BoxFit.cover,
    //   ),
    // );
    Function decideQuarterTurns = () {
      if (OrientationTool().currentOrientation() ==
          DeviceOrientation.portraitUp) {
        return 0;
      } else if (OrientationTool().currentOrientation() ==
          DeviceOrientation.landscapeLeft) {
        return 1;
      } else if (OrientationTool().currentOrientation() ==
          DeviceOrientation.landscapeRight) {
        return 3;
      } else if (OrientationTool().currentOrientation() ==
          DeviceOrientation.portraitDown) {
        if (OrientationTool().previousOrientation() ==
            DeviceOrientation.landscapeLeft) {
          return 1;
        } else if (OrientationTool().previousOrientation() ==
            DeviceOrientation.landscapeRight) {
          return 3;
        }
      }
      return 0;
    };
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height,
      child: RotatedBox(
        quarterTurns: decideQuarterTurns(),
        child: _cameraView,
      ),
    );
    // return GestureDetector(
    //   child: Container(
    //     width: MediaQuery.of(context).size.width,
    //     height: MediaQuery.of(context).size.height,
    //     child: RotatedBox(
    //       quarterTurns: decideQuarterTurns(),
    //       child: _cameraView,
    //     ),
    //   ),
    //   onTapDown: (TapDownDetails details) {
    //     this.tapGlobalPanOffset = details.globalPosition;
    //   },
    //   onTap: () {
    //     print("_tryToSetCameraFocus");
    //     _tryToSetCameraFocus();
    //   },
    // );
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
              if (this.textAreaWidth < this.textAreaMinWidth) {
                this.textAreaWidth = this.textAreaMinWidth;
              }
              this.textAreaHeight -= deltaY;
              if (this.textAreaHeight < this.textAreaMinHeight) {
                this.textAreaHeight = this.textAreaMinHeight;
              }
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
              behavior: HitTestBehavior.opaque,
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
                _playBtnClicked();
              },
            ),
          ),
          Expanded(child: SizedBox(height: 1)),
          Container(
            // color: randomColor(),
            padding: EdgeInsets.fromLTRB(10, 4, 10, 4),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
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
                behavior: HitTestBehavior.opaque,
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
                behavior: HitTestBehavior.opaque,
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
                behavior: HitTestBehavior.opaque,
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
                behavior: HitTestBehavior.opaque,
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
                  // HudTool.showInfoWithStatus(
                  //     "textarea_settings.hint_beauty_effect_unavailable_now"
                  //         .tr());
                  setState(() {
                    this.isCameraSettingsShowing = false;
                  });
                  _tryToPopBeautySettingsPage();
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
                behavior: HitTestBehavior.opaque,
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
                behavior: HitTestBehavior.opaque,
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
                behavior: HitTestBehavior.opaque,
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
                behavior: HitTestBehavior.opaque,
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
    if (this.txtSettings.isAISpeechMode) {
      return Expanded(
        child: Container(
          padding: EdgeInsets.fromLTRB(15, 5, 15, 5),
          // color: randomColor(),
          child: ScrollablePositionedList.builder(
            itemScrollController: _itemScrollController,
            itemPositionsListener: _itemPositionsListener,
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
      bottom: 5 + (CommonValues().xBottomHeight / 2.0),
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
        // Navigator.of(context).push(MaterialPageRoute(
        //     builder: (BuildContext context) => VideoPlayerPage(
        //         "https://stream7.iqilu.com/10339/upload_transcode/202002/18/20200218114723HDu3hhxqIT.mp4")));
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
      bottom: 5 + (CommonValues().xBottomHeight / 2.0),
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
      bottom: 5 + (CommonValues().xBottomHeight / 2.0),
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
      title: Text("camera_page.hint_quit_camera_title".tr()),
      description: Text("camera_page.hint_quit_camera_desc".tr()),
      color: SweetSheetColor.WARNING,
      // icon: Icons.portable_wifi_off,
      positive: SweetSheetAction(
        onPressed: () {
          Navigator.of(context).pop();
          _goBack();
        },
        title: "camera_page.hint_quit_confimation_title".tr(),
      ),
    );
  }

  void _goBack() {
    if (_cameraView != null) {
      _cameraView.destoryCamera();
    }
    this.txtSettings.isAISpeechMode = false;
    this.txtSettings.selectedLocaleName = this.txtSettings.systemLocaleName;
    if (this.speech != null) {
      this.speech.stop();
      this.speech = null;
    }
    Navigator.pop(context);
  }

  void _popTextAreaSettings() {
    PageRouteBuilder _router = PageRouteBuilder(
        opaque: false,
        pageBuilder: (context, animation, secondaryAnimation) =>
            PromterTextAreaSettingPage(),
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

  void _tryToPopBeautySettingsPage() {
    SliderCallback sc = (String beautyMode, String paraName, double value) {
      print("sc: $beautyMode, $paraName, $value");
      if (beautyMode == "option1") {
        _cameraView.changeSkinEffect(paraName, value / 100.0);
      } else {
        _cameraView.changePlasticEffect(paraName, value / 100.0);
      }
    };
    ResetCallback rc = (String mode) {
      print("rc: $mode");
      if (mode == "option1") {
        _cameraView.resetSkinEffect();
      } else if (mode == "option2") {
        _cameraView.resetPlasticEffect();
      }
    };
    PrompterBeautySettingsPage ts = PrompterBeautySettingsPage(sc, rc);
    PageRouteBuilder _router = PageRouteBuilder(
        opaque: false,
        pageBuilder: (context, animation, secondaryAnimation) => ts,
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
  }

  void startTimer() {
    this.killTimer();

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

  void _playBtnClicked() {
    if (this.isBeingScrolled == false) {
      if (this.txtSettings.isAISpeechMode) {
        _tryToStartAISpeechListenning();
        setState(() {
          this.isBeingScrolled = true;
        });
      } else {
        this.startTimer();
        setState(() {
          this.isBeingScrolled = true;
        });
      }
    } else {
      if (this.txtSettings.isAISpeechMode) {
        _tryToStopAISpeechListenning();
        setState(() {
          this.isBeingScrolled = false;
        });
      } else {
        this.killTimer();
        setState(() {
          this.isBeingScrolled = false;
        });
      }
    }
  }

  void _tryToStopAISpeechListenning() async {
    await speech.stop();
  }

  void _tryToStartAISpeechListenning() async {
    if (speech == null) {
      await _tryToInitSpeechTextFunction();
    }

    if (speech.isListening) {
      await speech.cancel();
    }
    await speech.listen(
        onResult: _tryToHandleSpeechRecognitionResult,
        listenFor: Duration(minutes: 15),
        pauseFor: Duration(seconds: 60),
        partialResults: true,
        localeId: this.txtSettings.selectedLocaleName.localeId,
        onSoundLevelChange: null,
        cancelOnError: false,
        listenMode: ListenMode.dictation);
  }

  Future _tryToRecordVideo() async {
    if (this.isRecording && this.duration < 10.0) {
      // 如果正在录制并且录制时长小于10秒
      HudTool.showErrorWithStatus("至少录制10秒");
      return;
    }

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
      _cameraView.startToRecord();
    } else {
      setState(() {
        this.recordingTimeString = "00:00";
        this.isBeingScrolled = false;
      });
      this.killTimer();
      HudTool.showWithStatus("正在合成视频");
      _cameraView.finishRecording();
    }
  }

  void _tryToSwitchFlashLight() {
    if (this.isFrontCamera) {
      HudTool.showInfoWithStatus(
          "camera_page.hint_front_camera_does_not_support_flash_light".tr());
      return;
    }
    setState(() {
      this.isFlashLightOn = !this.isFlashLightOn;
    });

    _cameraView.turnFlashLight(this.isFlashLightOn);
  }

  Future _tryToFlipCamera() async {
    _cameraView.rotateCamera();

    setState(() {
      this.isFrontCamera = !this.isFrontCamera;
    });
  }

  void _tryToChangeCameraRadio(int r) {
    String ratio = "0";
    if (r == 0) {
      ratio = "0";
    } else if (r == 1) {
      ratio = "9:16";
    } else if (r == 2) {
      ratio = "3:4";
    } else if (r == 3) {
      ratio = "1:1";
    }
    _cameraView.resetCameraRatio(ratio);
    setState(() {
      this.cameraRatio = r;
    });
  }

  void _tryToHandleSpeechRecognitionResult(SpeechRecognitionResult result) {
    // print("alternates: ${result.alternates}");
    // print("recognizedWords: ${result.recognizedWords}");
    print("SpeechRecognitionResult: $result");
    if (result.finalResult &&
        this.txtSettings.isAISpeechMode &&
        this.isBeingScrolled) {
      _tryToStartAISpeechListenning();
      return;
    }
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
}
