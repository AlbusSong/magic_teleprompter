import 'package:flutter/material.dart';
import 'dart:io';
import 'package:magic_teleprompter/others/tools/GlobalTool.dart';
import 'package:magic_teleprompter/others/tools/HudTool.dart';
// import 'package:video_viewer/video_viewer.dart';
// import 'package:yoyo_player/yoyo_player.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:dough/dough.dart';
import 'package:gallery_saver/gallery_saver.dart';

class VideoPlayerPage extends StatefulWidget {
  VideoPlayerPage(this.localVideoPath);
  final String localVideoPath;

  @override
  State createState() => _VideoPlayerPageState(this.localVideoPath);
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  _VideoPlayerPageState(this.localVideoPath);
  final String localVideoPath;

  // final GlobalKey<VideoViewerState> _key = GlobalKey<VideoViewerState>();
  VideoPlayerController _videoController;
  ChewieController _chewieController;

  File _videoFile;

  @override
  void initState() {
    super.initState();

    _videoFile = File(this.localVideoPath);

    _videoController = VideoPlayerController.file(_videoFile)
      ..initialize().then((_) {
        this._chewieController = ChewieController(
          videoPlayerController: _videoController,
          autoPlay: true,
          looping: true,
        );
        setState(() {});
      });
  }

  @override
  void dispose() {
    if (_videoFile.existsSync()) {
      _videoFile.deleteSync();
    }
    _videoController.dispose();
    _chewieController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                _buildExportButton(),
              ],
            ),
          ),
        ],
      ),
    );
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

  Future _tryToSaveVideo() async {
    HudTool.show();
    bool success = await GallerySaver.saveVideo(this.localVideoPath);
    if (success) {
      HudTool.showInfoWithStatus("保存成功");
      // _tryToGoBackAndRetake();
      _videoFile.deleteSync();
      Navigator.pop(context);
    } else {
      HudTool.showErrorWithStatus("保存失败请重试");
    }
  }

  void _tryToGoBackAndRetake() {
    _videoFile.deleteSync();

    Navigator.pop(context);
  }
}
