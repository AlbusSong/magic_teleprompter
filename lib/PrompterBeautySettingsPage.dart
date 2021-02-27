import 'package:flutter/material.dart';
import 'package:magic_teleprompter/others/tools/GlobalTool.dart';
import 'package:flutter_advanced_segment/flutter_advanced_segment.dart';
import 'package:magic_teleprompter/others/tools/HudTool.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';
import 'others/models/BeautyEffectSettings.dart';
import 'package:fdottedline/fdottedline.dart';

typedef SliderCallback = void Function(
    String mode, String paraName, double value);
typedef ResetCallback = void Function(String mode);

class PrompterBeautySettingsPage extends StatefulWidget {
  PrompterBeautySettingsPage(this.sCallback, this.rCallback);

  final SliderCallback sCallback;
  final ResetCallback rCallback;

  @override
  _PrompterBeautySettingsPageState createState() =>
      _PrompterBeautySettingsPageState();
}

class _PrompterBeautySettingsPageState
    extends State<PrompterBeautySettingsPage> {
  String beautyMode = "option1";

  List<String> _effectNameList1 = ["重置", "磨皮", "美白", "锐化", "红润"];
  List<String> _effectNameList2 = [
    "重置",
    "大眼",
    "瘦脸",
    "瘦鼻",
    "眉高",
    "细眉",
    "唇厚",
    "嘴型",
    "下巴",
    "眼角",
    "眼距",
    "发际线"
  ];

  int selectedIndex1 = 1;
  int selectedIndex2 = 1;

  Widget _optionsWidget1;
  Widget _optionsWidget2;

  @override
  void initState() {
    super.initState();

    // _optionsWidget1 = _buildOptionListWidget(this._effectNameList1);
    // _optionsWidget2 = _buildOptionListWidget(this._effectNameList2);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: _buildBody(),
      onTap: () {
        Navigator.pop(context);
      },
    );
  }

  Widget _buildBody() {
    return Material(
      color: Colors.transparent,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: SizedBox(width: 1)),
          GestureDetector(
            child: Container(
              constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height - 30),
              padding: EdgeInsets.only(bottom: 80),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
                color: hexColor("ffffff", 0.5),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSegmentControl(),
                    _buildSlider(),
                    Offstage(
                      offstage: (this.beautyMode != "option1"),
                      child: _buildOptionListWidget1(),
                    ),
                    Offstage(
                      offstage: (this.beautyMode != "option2"),
                      child: _buildOptionListWidget2(),
                    ),
                  ],
                ),
              ),
            ),
            onTap: () {
              print("bbbbbbbbbbb");
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSegmentControl() {
    return Container(
      margin: EdgeInsets.fromLTRB(20, 15, 20, 0),
      // height: 45,
      // color: randomColor(),
      child: Center(
        child: AdvancedSegment(
          segments: {
            // Map<String, String>
            'option1': '美颜',
            'option2': '微整',
          },
          activeStyle: TextStyle(
            // TextStyle
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
          inactiveStyle: TextStyle(
            // TextStyle
            color: Colors.white54,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
          sliderColor: hexColor("ea6135"),
          backgroundColor: hexColor("ef9a38"),
          sliderOffset: 2.0,
          value: this.beautyMode,
          onValueChanged: (value) {
            print("onValueChanged: $value");
            setState(() {
              this.beautyMode = value;
            });
          },
        ),
      ),
    );
  }

  Widget _buildSlider() {
    return Container(
      // color: randomColor(),
      margin: EdgeInsets.only(top: 10),
      child: SfSlider(
        min: 0.0,
        max: 100.0,
        value: (this.beautyMode == "option1"
            ? BeautyEffectSettings()
                .beautyEffectValues1[this.selectedIndex1 - 1]
            : BeautyEffectSettings()
                .beautyEffectValues2[this.selectedIndex2 - 1]),
        interval: 10,
        showTicks: true,
        showLabels: false,
        enableTooltip: true,
        minorTicksPerInterval: 1,
        activeColor: hexColor("e15141"),
        inactiveColor: Colors.white54,
        thumbShape: SfThumbShape(),
        tooltipShape: SfRectangularTooltipShape(),
        trackShape: SfTrackShape(),
        tickShape: SfTickShape(),
        tooltipTextFormatterCallback:
            (dynamic actualValue, String formattedText) {
          double actualValue2 = actualValue;
          return "${actualValue2.toInt()}";
        },
        onChanged: (dynamic value) {
          _sliderValueChanged(value);
        },
      ),
    );
  }

  Widget _buildOptionListWidget1() {
    List<Widget> widgetList = [];
    for (int i = 0; i < listLength(this._effectNameList1); i++) {
      String name = this._effectNameList1[i];
      Widget w = _buildOptionWidget(i, name, name);
      widgetList.add(w);
    }
    widgetList.insert(1, _buildDottedLine());
    return Container(
      height: 80,
      margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
      width: MediaQuery.of(context).size.width,
      // color: Colors.white,
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
        scrollDirection: Axis.horizontal,
        physics: BouncingScrollPhysics(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: widgetList,
        ),
      ),
    );
  }

  Widget _buildOptionListWidget2() {
    List<Widget> widgetList = [];
    for (int i = 0; i < listLength(this._effectNameList2); i++) {
      String name = this._effectNameList2[i];
      Widget w = _buildOptionWidget(i, name, name);
      widgetList.add(w);
    }
    widgetList.insert(1, _buildDottedLine());
    return Container(
      height: 80,
      margin: EdgeInsets.fromLTRB(0, 10, 0, 10),
      width: MediaQuery.of(context).size.width,
      // color: Colors.white,
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(15, 0, 15, 0),
        scrollDirection: Axis.horizontal,
        physics: BouncingScrollPhysics(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: widgetList,
        ),
      ),
    );
  }

  Widget _buildOptionWidget(int index, String iconName, String title) {
    bool isSelected = false;
    if (this.beautyMode == "option1" && this.selectedIndex1 == index) {
      isSelected = true;
    } else if (this.beautyMode == "option2" && this.selectedIndex2 == index) {
      isSelected = true;
    }
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      child: Container(
        constraints: BoxConstraints(minWidth: 70),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: 50,
              padding: EdgeInsets.all(5),
              child: ColorFiltered(
                colorFilter: ColorFilter.mode(
                    (isSelected ? hexColor("D92F2F") : hexColor("ffffff")),
                    BlendMode.modulate),
                child: Image.asset(
                  "assets/images/beauty_effect/$iconName.png",
                ),
              ),
            ),
            Text(
              title,
              style: TextStyle(
                  color: (isSelected ? hexColor("D92F2F") : hexColor("ffffff")),
                  fontSize: 15),
            ),
          ],
        ),
      ),
      onTap: () {
        _clickedOptionWidget(index);
      },
    );
  }

  Widget _buildDottedLine() {
    return FDottedLine(
      color: Colors.white,
      height: 60.0,
      strokeWidth: 1.0,
      dottedLength: 6,
      space: 2.0,
    );
  }

  void _clickedOptionWidget(int index) {
    if (index == 0) {
      if (this.beautyMode == "option1") {
        BeautyEffectSettings().resetEffectValues1ToZero();
      } else {
        BeautyEffectSettings().resetEffectValues2ToZero();
      }

      if (widget.rCallback != null) {
        widget.rCallback(this.beautyMode);
      }

      setState(() {});

      HudTool.showInfoWithStatus("已重置");

      return;
    }

    if (this.beautyMode == "option1") {
      if (index == this.selectedIndex1) {
        return;
      }
      setState(() {
        this.selectedIndex1 = index;
      });
    } else {
      if (index == this.selectedIndex2) {
        return;
      }
      setState(() {
        this.selectedIndex2 = index;
      });
    }
  }

  void _sliderValueChanged(double v) {
    print("_sliderValueChanged: $v");

    if (this.beautyMode == "option1") {
      if (widget.sCallback != null) {
        String paramName = BeautyEffectSettings()
            .beautyEffectParaNames1[this.selectedIndex1 - 1];
        widget.sCallback(this.beautyMode, paramName, v);
      }
      setState(() {
        BeautyEffectSettings().beautyEffectValues1[this.selectedIndex1 - 1] = v;
      });
    } else {
      if (widget.sCallback != null) {
        String paramName = BeautyEffectSettings()
            .beautyEffectParaNames2[this.selectedIndex2 - 1];
        widget.sCallback(this.beautyMode, paramName, v);
      }
      setState(() {
        BeautyEffectSettings().beautyEffectValues2[this.selectedIndex2 - 1] = v;
      });
    }
  }
}
