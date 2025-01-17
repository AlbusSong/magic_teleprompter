import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:magic_teleprompter/others/tools/GlobalTool.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class UsageCoursePage extends StatefulWidget {
  UsageCoursePage({Key key}) : super(key: key);

  @override
  _UsageCoursePageState createState() => _UsageCoursePageState();
}

class _UsageCoursePageState extends State<UsageCoursePage> {
  VideoPlayerController _videoController;
  ChewieController _chewieController;

  String videoUrl =
      "https://trifles.oss-cn-beijing.aliyuncs.com/video_course.mp4";

  @override
  void initState() {
    super.initState();

    _initControllers();
  }

  Future _initControllers() async {
    _videoController = VideoPlayerController.network(this.videoUrl);
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
    // if (_videoFile.existsSync()) {
    //   _videoFile.deleteSync();
    // }

    _chewieController.pause();
    _videoController.dispose();
    _chewieController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "使用教程",
          style: TextStyle(
            fontFamily: "PingFangSC-Regular",
            fontSize: 22,
            color: hexColor("1D1E2C"),
          ),
        ),
        iconTheme: IconThemeData(
          color: Colors.black, //change your color here
        ),
        brightness: Brightness.light,
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0.5,
      ),
      backgroundColor: Colors.white,
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_chewieController == null) {
      return Container(
        color: hexColor("f4fffb"),
        child: Center(
          child: CupertinoActivityIndicator(),
        ),
      );
    } else {
      return Container(
        // padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
        color: hexColor("000000"),
        child: Chewie(
          controller: _chewieController,
        ),
      );
    }
  }
}
