import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:magic_teleprompter/others/models/CommonValues.dart';
import 'dart:io';
import 'package:magic_teleprompter/others/tools/GlobalTool.dart';
import 'package:magic_teleprompter/others/tools/HudTool.dart';
// import 'package:video_viewer/video_viewer.dart';
// import 'package:yoyo_player/yoyo_player.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:dough/dough.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:fbutton/fbutton.dart';
import 'package:sweetsheet/sweetsheet.dart';
import 'package:permission_handler/permission_handler.dart';
import 'others/tools/AdmobTool.dart';
import 'package:easy_localization/easy_localization.dart';

class VideoPlayerPage extends StatefulWidget {
  VideoPlayerPage(this.localVideoPath, {this.shouldDeleteVideo = true});
  final String localVideoPath;
  final bool shouldDeleteVideo;

  @override
  State createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  final SweetSheet _sweetSheet = SweetSheet();

  VideoPlayerController _videoController;
  ChewieController _chewieController;

  File _videoFile;

  bool exportSuccess = false;

  @override
  void initState() {
    super.initState();

    _videoFile = File(widget.localVideoPath);

    _initControllers();

    if (mounted) {}

    AdmobTool().callback = (AdEvent e) {
      if (e == AdEvent.closed) {
        this._exportHandler();
      }
    };
  }

  void _initControllers() async {
    _videoController = VideoPlayerController.file(_videoFile);
    await _videoController.initialize();
    this._chewieController = ChewieController(
      videoPlayerController: _videoController,
      autoPlay: true,
      looping: true,
    );
    setState(() {});
  }

  @override
  void dispose() {
    if (_videoFile.existsSync()) {
      if (widget.shouldDeleteVideo) {
        _videoFile.deleteSync();
      }
    }

    _chewieController.pause();
    _videoController.dispose();
    _chewieController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_chewieController == null) {
      return Container(
        color: Colors.white,
      );
    } else {
      return Material(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              child: Container(
                height: 200,
                margin: EdgeInsets.fromLTRB(
                    15, 30 + (CommonValues().statusHeight / 2.0), 15, 0),
                child: Chewie(controller: _chewieController),
              ),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(
                  15, 15, 20, 15 + (CommonValues().xBottomHeight / 2.0)),
              height: 90,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildBackButton(),
                  _buildExportButton2(),
                ],
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildBackButton() {
    return PressableDough(
      child: Container(
        width: 90,
        height: 90,
        decoration: BoxDecoration(
          gradient: new LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.topRight,
              colors: [hexColor("D7D299"), hexColor("648842")]),
          borderRadius: BorderRadius.circular(90 / 2.0),
        ),
        child: FlatButton(
          child: Text(
            widget.shouldDeleteVideo ? "video_player.btn_back".tr() : "返回",
            textAlign: TextAlign.center,
            style: TextStyle(
                color: hexColor("ffffff"),
                fontSize: 18,
                fontWeight: FontWeight.bold),
          ),
          splashColor: Colors.white70,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(90.0 / 2.0)),
          onPressed: () {
            _tryToGoBackAndRetake();
          },
        ),
      ),
    );
  }

  Widget _buildExportButton() {
    return PressableDough(
      child: Container(
        width: 90,
        height: 90,
        decoration: BoxDecoration(
          gradient: new LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.topRight,
              colors: [hexColor("3583C2"), hexColor("88427D")]),
          borderRadius: BorderRadius.circular(90 / 2.0),
        ),
        child: FlatButton(
          child: Text(
            "video_player.btn_export".tr(),
            textAlign: TextAlign.center,
            style: TextStyle(
                color: hexColor("ffffff"),
                fontSize: 18,
                fontWeight: FontWeight.bold),
          ),
          splashColor: Colors.white70,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(90 / 2.0)),
          onPressed: () {
            _tryToSaveVideo();
          },
        ),
      ),
    );
  }

  Widget _buildExportButton2() {
    return PressableDough(
      child: FButton(
        width: 90,
        height: 90,
        corner: FCorner.all(90 / 2.0),
        text: "video_player.btn_export".tr(),
        alignment: Alignment.center,
        style: TextStyle(
            color: hexColor("ffffff"),
            fontSize: 18,
            fontWeight: FontWeight.bold),
        gradient: LinearGradient(colors: [
          hexColor("3583C2"),
          hexColor("88427D"),
        ]),
        clickLoading: true,
        clickEffect: true,
        loadingColor: Colors.white,
        loadingSize: 20,
        hideTextOnLoading: true,
        onPressed: () {
          _tryToSaveVideo();
        },
      ),
    );
  }

  void _tryToSaveVideo() async {
    await [Permission.photosAddOnly].request();
    PermissionStatus photosStatus = await Permission.photos.status;
    if (photosStatus.isGranted == false) {
      HudTool.showErrorWithStatus(
          "video_player.hint_photoes_unauthorized".tr());
      return;
    }

    // 弹出广告追踪权限弹窗
    AdmobTool().popOutAppTrackingWindow();
    bool isLoaded = await AdmobTool().interstitialAd.isLoaded();
    if (isLoaded) {
      AdmobTool().interstitialAd.show();
      this.exportSuccess = await GallerySaver.saveVideo(widget.localVideoPath);
    } else {
      this.exportSuccess = await GallerySaver.saveVideo(widget.localVideoPath);
      this._exportHandler();
    }
    // this.exportSuccess = await GallerySaver.saveVideo(this.localVideoPath);
    // this._exportHandler();
  }

  void _exportHandler() {
    if (this.exportSuccess) {
      HudTool.showInfoWithStatus("video_player.hint_exported_success".tr());
      if (widget.shouldDeleteVideo) {
        _videoFile.deleteSync();
      }
      Future.delayed(Duration(seconds: 1), () {
        // Navigator.popUntil(context, ModalRoute.withName('/home'));
        Navigator.of(context).pop();
      });
    } else {
      HudTool.showErrorWithStatus("video_player.hint_exported_failure".tr());
    }
  }

  void _tryToGoBackAndRetake() {
    if (widget.shouldDeleteVideo == false) {
      Navigator.of(context).pop();
    } else {
      _sweetSheet.show(
        context: context,
        title: Text("video_player.hint_quit_title".tr()),
        description: Text("video_player.hint_quit_desc".tr()),
        color: SweetSheetColor.DANGER,
        positive: SweetSheetAction(
          onPressed: () {
            Navigator.of(context).pop();
            _goBackAndRetake();
          },
          title: "video_player.hint_quit_confirmation".tr(),
        ),
      );
    }
  }

  void _goBackAndRetake() {
    _chewieController.pause();
    if (widget.shouldDeleteVideo) {
      _videoFile.deleteSync();
    }

    Navigator.pop(context);
  }
}
