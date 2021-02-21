import 'package:flutter/material.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:magic_teleprompter/others/tools/GlobalTool.dart';
import 'package:magic_teleprompter/others/third_party/flutter_easyhub-0.3.5+0.5/lib/flutter_easy_hub.dart';
import 'package:magic_teleprompter/TabbarPage.dart';

typedef DissmissBlock = void Function();

class HudTool {
  static BuildContext APP_CONTEXT;

  static void showErrorWithStatus(String status) {
    HudTool.showInfoWithStatus(status, isError: true);
  }

  static void showInfoWithStatus(String status, {bool isError = false}) {
    HudTool.dismiss();

    if (isError) {
      BotToast.showText(
        text: status,
        align: Alignment(0.0, -0.8),
        textStyle: TextStyle(fontSize: 17, color: Colors.white),
        contentColor: hexColor("ec5c4f"),
      );
    } else {
      BotToast.showText(
        text: status,
        align: Alignment(0.0, -0.8),
        textStyle: TextStyle(fontSize: 17, color: Colors.white),
        contentColor: hexColor("62d59c"),
      );
    }
  }

  static void show({BuildContext ctx}) {
    Future.delayed(Duration.zero, () async {
      showAction();
    });
  }

  static void showAction({BuildContext ctx}) {
    if (ctx == null) {
      ctx = TabbarPage.globalKey.currentContext;
    }
    if (ctx == null) {
      ctx = APP_CONTEXT;
    }

    BotToast.closeAllLoading();

    // EasyHub.dismiss();

    EasyHub.getInstance.setBackgroundColor(hexColor("000000", 0.75));
    EasyHub.getInstance.indicatorType =
        EasyHubIndicatorType.EasyHubIndicator_movingCube;
    EasyHub.getInstance.textStyle =
        TextStyle(fontSize: 15, color: Colors.white);
    EasyHub.showHub(ctx != null ? ctx : APP_CONTEXT);
  }

  static void showWithStatus(String status, {BuildContext ctx}) {
    EasyHub.getInstance.setBackgroundColor(hexColor("000000", 0.75));
    EasyHub.getInstance.indicatorType =
        EasyHubIndicatorType.EasyHubIndicator_movingCube;
    EasyHub.getInstance.textStyle =
        TextStyle(fontSize: 15, color: Colors.white);
    if (isAvailable(status)) {
      EasyHub.show(ctx != null ? ctx : APP_CONTEXT, status);
    } else {
      EasyHub.showHub(ctx != null ? ctx : APP_CONTEXT);
    }
  }

  static void dismiss({DissmissBlock block}) {
    BotToast.closeAllLoading();
    EasyHub.dismiddAll();
  }
}
