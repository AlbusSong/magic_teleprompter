import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:magic_teleprompter/others/models/Trifle.dart';
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
import 'package:admob_flutter/admob_flutter.dart';
import 'others/tools/AdmobTool.dart';

class VideoPlayerPage extends StatefulWidget {
  VideoPlayerPage(this.localVideoPath);
  final String localVideoPath;

  @override
  State createState() => _VideoPlayerPageState(this.localVideoPath);
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  _VideoPlayerPageState(this.localVideoPath);
  final String localVideoPath;

  final SweetSheet _sweetSheet = SweetSheet();

  VideoPlayerController _videoController;
  ChewieController _chewieController;

  File _videoFile;

  bool exportSuccess = false;

  @override
  void initState() {
    super.initState();

    _videoFile = File(this.localVideoPath);

    _initControllers();

    AdmobTool().callback = (AdmobAdEvent e) {
      if (e == AdmobAdEvent.closed) {
        this._exportHandler();
      }
    };
  }

  Future _initControllers() async {
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
      _videoFile.deleteSync();
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
                margin: EdgeInsets.fromLTRB(15, 30, 15, 0),
                child: Chewie(controller: _chewieController),
              ),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(15, 15, 20, 15),
              height: 80,
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
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          gradient: new LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.topRight,
              colors: [hexColor("D7D299"), hexColor("648842")]),
          borderRadius: BorderRadius.circular(90),
        ),
        child: FlatButton(
          child: Text(
            "返回\n重拍",
            textAlign: TextAlign.center,
            style: TextStyle(
                color: hexColor("ffffff"),
                fontSize: 18,
                fontWeight: FontWeight.bold),
          ),
          splashColor: Colors.white70,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(40.0)),
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
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          gradient: new LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.topRight,
              colors: [hexColor("3583C2"), hexColor("88427D")]),
          borderRadius: BorderRadius.circular(90),
        ),
        child: FlatButton(
          child: Text(
            "导出\n相册",
            textAlign: TextAlign.center,
            style: TextStyle(
                color: hexColor("ffffff"),
                fontSize: 18,
                fontWeight: FontWeight.bold),
          ),
          splashColor: Colors.white70,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(40.0)),
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
        width: 80,
        height: 80,
        corner: FCorner.all(40),
        text: "导出\n相册",
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
      HudTool.showErrorWithStatus("相册写入权限未开启");
      return;
    }

    bool isLoaded = await AdmobTool().interstitialAd.isLoaded;
    if (isLoaded) {
      AdmobTool().interstitialAd.show();
      this.exportSuccess = await GallerySaver.saveVideo(this.localVideoPath);
    } else {
      this.exportSuccess = await GallerySaver.saveVideo(this.localVideoPath);
      this._exportHandler();
    }
  }

  void _exportHandler() {
    if (this.exportSuccess) {
      HudTool.showInfoWithStatus("保存成功");
      _videoFile.deleteSync();
      Future.delayed(Duration(seconds: 1), () {
        Navigator.popUntil(context, ModalRoute.withName('/home'));
      });
    } else {
      HudTool.showErrorWithStatus("保存失败请重试");
    }
  }

  void _tryToGoBackAndRetake() {
    _sweetSheet.show(
      context: context,
      title: Text("退出重拍？"),
      description: Text('您拍摄的此段视频文件将被删除。'),
      color: SweetSheetColor.DANGER,
      positive: SweetSheetAction(
        onPressed: () {
          Navigator.of(context).pop();
          _goBackAndRetake();
        },
        title: "退出重拍",
      ),
    );
  }

  void _goBackAndRetake() {
    _chewieController.pause();
    _videoFile.deleteSync();

    Navigator.pop(context);
  }
}
