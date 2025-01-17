import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:magic_teleprompter/others/models/Trifle.dart';
import 'package:magic_teleprompter/others/tools/GlobalTool.dart';
import 'package:fsuper/fsuper.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'others/models/TextAreaSettings.dart';
import 'others/tools/NotificationCenter.dart';
import 'package:xlive_switch/xlive_switch.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:magic_teleprompter/others/tools/HudTool.dart';
import 'package:easy_localization/easy_localization.dart';

class PromterTextAreaSettingPage extends StatefulWidget {
  PromterTextAreaSettingPage();

  @override
  _PromterTextAreaSettingPageState createState() =>
      _PromterTextAreaSettingPageState();
}

class _PromterTextAreaSettingPageState
    extends State<PromterTextAreaSettingPage> {
  final TextAreaSettings txtSettings = TextAreaSettings();

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
                color: hexColor("000000", 0.5),
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildChooesAISpeechMode(),
                    _buildChooseTextColor(),
                    _buildTextFontSizeSlider(),
                    _buildChooseBackgroundColor(),
                    _buildBackgroundAlphaSlider(),
                    _buildTextScrollingSpeedSlider(),
                  ],
                ),
              ),
            ),
            onTap: () {
              print("aaaaaaaaaaa");
            },
          ),
        ],
      ),
    );
  }

  Widget _buildChooesAISpeechMode() {
    return Container(
      padding: EdgeInsets.fromLTRB(15, 20, 15, 10),
      // color: randomColor(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          FSuper(
            margin: EdgeInsets.only(right: 15),
            text: "textarea_settings.ai_speech_mode".tr(),
            style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                decoration: TextDecoration.none),
          ),
          XlivSwitch(
            value: this.txtSettings.isAISpeechMode,
            onChanged: (val) {
              print("val: $val");
              _tryToSwitchTextMode();
            },
          ),
          Spacer(),
          Offstage(
            offstage: (this.txtSettings.isAISpeechMode == false),
            child: GestureDetector(
              child: Container(
                padding: EdgeInsets.fromLTRB(10, 0, 7, 0),
                margin: EdgeInsets.only(right: 15),
                height: 24,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(5)),
                  color: hexColor("ffffff", 0.5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      (TextAreaSettings().selectedLocaleName != null
                          ? TextAreaSettings().selectedLocaleName.name
                          : "Language"),
                      style: TextStyle(color: Colors.white, fontSize: 11),
                    ),
                    Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 18,
                      color: Colors.white,
                    )
                  ],
                ),
              ),
              onTap: () {
                print("_tryToChooseLanguage");
                _tryToChooseAISpeechLanguage();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChooseTextColor() {
    List<Widget> widgets = [];
    FSuper title = FSuper(
      margin: EdgeInsets.only(right: 10),
      text: "textarea_settings.text_color".tr(),
      style: TextStyle(
          color: Colors.white, fontSize: 12, decoration: TextDecoration.none),
    );
    widgets.add(title);
    widgets.addAll(_createTextColorSelections());
    return Container(
      padding: EdgeInsets.fromLTRB(15, 20, 15, 10),
      // color: randomColor(),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: widgets,
        ),
      ),
    );
  }

  List<Widget> _createTextColorSelections() {
    List<Widget> result = [];
    for (int i = 0; i < listLength(Trifle().textColorStrings); i++) {
      String colorString = Trifle().textColorStrings[i];
      GestureDetector g = GestureDetector(
        child: Container(
          width: 18,
          height: 18,
          margin: EdgeInsets.fromLTRB(10, 5, 10, 5),
          decoration: BoxDecoration(
            border: (colorString.toLowerCase() ==
                    this.txtSettings.textHexColorString.toLowerCase())
                ? Border.all(
                    width: 2, color: hexColor(i == 0 ? "f00000" : "ffffff"))
                : null,
            borderRadius: BorderRadius.all(Radius.circular(9)),
            color: hexColor(colorString),
          ),
        ),
        onTap: () {
          setState(() {
            this.txtSettings.textHexColorString = colorString;
          });
          NotificationCenter().postNotification("textAreaSettingsChanged");
        },
      );
      result.add(g);
    }
    return result;
  }

  Widget _buildTextFontSizeSlider() {
    return Container(
      padding: EdgeInsets.fromLTRB(15, 10, 15, 10),
      // color: randomColor(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          FSuper(
            margin: EdgeInsets.only(right: 10),
            text: "textarea_settings.text_fontsize".tr(),
            style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                decoration: TextDecoration.none),
          ),
          Expanded(
            child: Material(
              type: MaterialType.transparency,
              child: Slider(
                value: this.txtSettings.fontSize,
                min: 10,
                max: 100,
                label: this.txtSettings.fontSize.toInt().toString(),
                divisions: 90,
                activeColor: Colors.red,
                inactiveColor: hexColor("1f5f5f"),
                onChanged: (v) {
                  print("kkdkdkdk: $v");
                  setState(() {
                    this.txtSettings.fontSize = v;
                  });
                  NotificationCenter()
                      .postNotification("textAreaSettingsChanged");
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChooseBackgroundColor() {
    List<Widget> widgets = [];
    FSuper title = FSuper(
      margin: EdgeInsets.only(right: 10),
      text: "textarea_settings.background_color".tr(),
      style: TextStyle(
          color: Colors.white, fontSize: 12, decoration: TextDecoration.none),
    );
    widgets.add(title);
    widgets.addAll(_createBackgroundColorSelections());
    return Container(
      padding: EdgeInsets.fromLTRB(15, 10, 15, 10),
      // color: randomColor(),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: widgets,
        ),
      ),
    );
  }

  List<Widget> _createBackgroundColorSelections() {
    List<Widget> result = [];
    for (int i = 0; i < listLength(Trifle().backgroundColorStrings); i++) {
      String colorString = Trifle().backgroundColorStrings[i];
      GestureDetector g = GestureDetector(
        child: Container(
          width: 18,
          height: 18,
          margin: EdgeInsets.fromLTRB(10, 5, 10, 5),
          decoration: BoxDecoration(
            border: ((colorString.toLowerCase() ==
                    this.txtSettings.backgroundHexColorString.toLowerCase())
                ? Border.all(
                    width: 2,
                    color: hexColor(
                        i == (listLength(Trifle().backgroundColorStrings) - 1)
                            ? "f00000"
                            : "ffffff"))
                : null),
            borderRadius: BorderRadius.all(Radius.circular(9)),
            color: hexColor(colorString),
          ),
        ),
        onTap: () {
          setState(() {
            this.txtSettings.backgroundHexColorString = colorString;
          });
          NotificationCenter().postNotification("textAreaSettingsChanged");
        },
      );
      result.add(g);
    }
    return result;
  }

  Widget _buildBackgroundAlphaSlider() {
    return Container(
      padding: EdgeInsets.fromLTRB(15, 10, 15, 10),
      // color: randomColor(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          FSuper(
            margin: EdgeInsets.only(right: 10),
            text: "textarea_settings.background_alpha".tr(),
            style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                decoration: TextDecoration.none),
          ),
          Expanded(
            child: Material(
              type: MaterialType.transparency,
              child: Slider(
                value: this.txtSettings.backgroundAlpha,
                min: 0.01,
                max: 1.0,
                label:
                    '${(this.txtSettings.backgroundAlpha * 100.0).toInt().toString()}%',
                divisions: 100,
                activeColor: Colors.red,
                inactiveColor: hexColor("1f5f5f"),
                onChanged: (v) {
                  print("uuuuuuu: $v");
                  setState(() {
                    this.txtSettings.backgroundAlpha = v;
                  });
                  NotificationCenter()
                      .postNotification("textAreaSettingsChanged");
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextScrollingSpeedSlider() {
    return Container(
      padding: EdgeInsets.fromLTRB(15, 10, 15, 10),
      // color: randomColor(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          FSuper(
            margin: EdgeInsets.only(right: 10),
            text: "textarea_settings.scrolling_speed".tr(),
            style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                decoration: TextDecoration.none),
          ),
          Expanded(
            child: Material(
              type: MaterialType.transparency,
              child: Slider(
                value: this.txtSettings.textScrollingSpeed,
                min: 10.0,
                max: (15.0 * 60),
                label: _generateInteligientScrollingDurationText(
                    this.txtSettings.textScrollingSpeed.toInt()),
                divisions: 15 * 60 - 10,
                activeColor: Colors.red,
                inactiveColor: hexColor("1f5f5f"),
                onChanged: (v) {
                  print("nnnnnn: $v");
                  setState(() {
                    this.txtSettings.textScrollingSpeed = v;
                  });
                  NotificationCenter().postNotification(
                      "textAreaSettingsScrollingDurationChanged");
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _tryToChooseAISpeechLanguage() {
    // showCupertinoModalBottomSheet
    // showMaterialModalBottomSheet
    showBarModalBottomSheet(
        context: context,
        expand: true,
        backgroundColor: Colors.black,
        builder: (context) => Material(
                child: CupertinoPageScaffold(
              navigationBar: CupertinoNavigationBar(
                  // leading: Container(),
                  automaticallyImplyLeading: false,
                  middle: Text(
                      "textarea_settings.choose_ai_language_page_title".tr())),
              child: SafeArea(
                bottom: false,
                child: ListView.builder(
                  // reverse: false,
                  // shrinkWrap: true,
                  controller: ModalScrollController.of(context),
                  physics: ClampingScrollPhysics(),
                  itemCount: listLength(TextAreaSettings().localeNames),
                  itemBuilder: (BuildContext context, int index) {
                    return _buildLanguageCell(index);
                  },
                ),
              ),
            )));
  }

  Widget _buildLanguageCell(int index) {
    LocaleName m = TextAreaSettings().localeNames[index];
    return GestureDetector(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 20),
        height: 45,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              (TextAreaSettings().selectedLocaleName.localeId == m.localeId
                  ? Icons.radio_button_checked_outlined
                  : Icons.radio_button_unchecked_outlined),
              color:
                  (TextAreaSettings().selectedLocaleName.localeId == m.localeId
                      ? Colors.red
                      : Colors.black),
              size: 20,
            ),
            SizedBox(
              width: 15,
            ),
            Text(
              m.name,
              style: TextStyle(color: Colors.black, fontSize: 13),
            ),
          ],
        ),
      ),
      behavior: HitTestBehavior.opaque,
      onTap: () {
        setState(() {
          TextAreaSettings().selectedLocaleName = m;
        });
        NotificationCenter()
            .postNotification("textAreaSettingsAISpeechLanguageChanged", null);
        Navigator.pop(context);
      },
    );
  }

  void _tryToSwitchTextMode() async {
    await [Permission.speech].request();
    PermissionStatus speechStatus = await Permission.speech.status;
    print("speechStatus: $speechStatus");
    if (speechStatus.isGranted == false) {
      HudTool.showErrorWithStatus(
          "textarea_settings.hint_ai_function_unauthorized".tr());
      return;
    } else {
      NotificationCenter()
          .postNotification("AISpeechRecognitionAuthorityGranted", null);
    }

    setState(() {
      this.txtSettings.isAISpeechMode = !this.txtSettings.isAISpeechMode;
      TextAreaSettings().isAISpeechMode = this.txtSettings.isAISpeechMode;
    });
    NotificationCenter()
        .postNotification("textAreaSettingsAISpeechModeChanged", null);
  }

  String _generateInteligientScrollingDurationText(int seconds) {
    if (seconds < 60) {
      return "textarea_settings.will_finish_within_seconds"
          .tr(args: ["$seconds"]);
    } else {
      int minutes = (seconds / 60.0).ceil().toInt();
      return "textarea_settings.will_finish_within_minutes"
          .tr(args: ["$minutes"]);
    }
  }
}
