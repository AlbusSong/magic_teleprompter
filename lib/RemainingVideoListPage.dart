import 'package:flutter/material.dart';
import 'package:magic_teleprompter/others/models/CommonValues.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'others/tools/GlobalTool.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:date_format/date_format.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:sweetsheet/sweetsheet.dart';
import 'VideoPlayerPage.dart';

class RemainingVideoListPage extends StatefulWidget {
  RemainingVideoListPage({Key key}) : super(key: key);

  @override
  _RemainingVideoListPageState createState() => _RemainingVideoListPageState();
}

class _RemainingVideoListPageState extends State<RemainingVideoListPage> {
  List<String> arrOfData = [];
  List<String> thumbnailImagePaths = [];

  final SweetSheet _sweetSheet = SweetSheet();

  @override
  void initState() {
    super.initState();

    _getLocalVideoList();
  }

  void _getLocalVideoList() async {
    Directory cacheDir = await getTemporaryDirectory();
    Directory videoDir = new Directory('${cacheDir.path}/lsqTempDir');
    final List<FileSystemEntity> children = videoDir.listSync();
    for (final FileSystemEntity fse in children) {
      if (fse is Directory) {
        continue;
      }

      if (fse.path.endsWith(".mp4") || fse.path.endsWith(".MP4")) {
        // String videoName = getFileNameByPath(fse.path);
        this.arrOfData.add(fse.path);
      }
    }

    for (int i = 0; i < listLength(this.arrOfData); i++) {
      String videoFilePath = this.arrOfData[i];
      String thumbnailImagePath = await VideoThumbnail.thumbnailFile(
        video: videoFilePath,
        thumbnailPath: (await getTemporaryDirectory()).path,
      );
      this.thumbnailImagePaths.add(thumbnailImagePath);
      print("thumbnailImagePath: $thumbnailImagePath");
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "未导出视频列表",
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
    return Scrollbar(
      child: StaggeredGridView.countBuilder(
        padding: EdgeInsets.fromLTRB(24, 30, 24, 15),
        crossAxisCount: 4,
        itemCount: listLength(this.arrOfData),
        itemBuilder: (BuildContext context, int index) {
          return GestureDetector(
            child: ((idx) {
              return _buildWaterflowItem(idx);
            })(index),
            onTap: () {},
          );
        },
        staggeredTileBuilder: (int index) {
          return StaggeredTile.fit(2);
        },
        mainAxisSpacing: 30.0,
        crossAxisSpacing: 24.0,
      ),
    );
  }

  Widget _buildWaterflowItem(int index) {
    return Stack(
      children: [
        Container(
          margin: EdgeInsets.only(bottom: 14),
          clipBehavior: Clip.hardEdge,
          decoration: BoxDecoration(
            color: Colors.white,
            // color: hexColor(Trifle().homeColorList[
            //     listLength(Trifle().homeColorList) -
            //         1 -
            //         (index % listLength(Trifle().homeColorList))]),
            borderRadius: BorderRadius.all(Radius.circular(13.0)),
            boxShadow: [
              BoxShadow(
                blurRadius: 10,
                offset: Offset(2, 2),
                spreadRadius: 0,
                color: Color(0x33000000),
              ),
            ],
          ),
          child: _buildItemObject(index),
        ),
        Positioned(
          bottom: 0,
          left: (((CommonValues().screenWidth - 24 * 3) / 2.0) - 34) / 2.0,
          child: Center(
            child: _buildDeleteButton(index),
          ),
        ),
      ],
    );
  }

  Widget _buildDeleteButton(int index) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 34,
        height: 34,
        // color: randomColor(),
        padding: EdgeInsets.all(5),
        decoration: BoxDecoration(
          border: Border.all(width: 1, color: hexColor("CE3535")),
          borderRadius: BorderRadius.all(Radius.circular(17)),
          color: hexColor("F3F3F3"),
        ),
        child: Image.asset(
          "assets/images/视频列表-删除按钮.png",
          width: 30,
          height: 30,
        ),
      ),
      onTap: () {
        _tryToDeleteVideoAtIndex(index);
      },
    );
  }

  Widget _buildItemObject(int index) {
    String path = this.arrOfData[index];
    String fileName = getFileNameByPath(path);
    List subNames = fileName.split(".");
    String unixTimeString = "";
    if (listLength(subNames) > 0) {
      unixTimeString = subNames.first;
    }
    DateTime dt =
        DateTime.fromMillisecondsSinceEpoch(int.parse(unixTimeString) * 1000);
    String dateString = formatDate(dt, [yyyy, '-', mm, '-', dd]);
    String timeString = formatDate(dt, [HH, ':', nn, ':', ss]);

    String thumbnailImagePath = this.thumbnailImagePaths[index];

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: EdgeInsets.only(bottom: 25),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              color: randomColor(),
              child: Image.file(
                File.fromUri(Uri.file(thumbnailImagePath)),
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
            Container(
              // color: randomColor(),
              margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
              child: Text(
                dateString,
                style: TextStyle(
                    fontSize: 20,
                    color: Colors.black,
                    fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              // color: randomColor(),
              margin: EdgeInsets.fromLTRB(10, 3, 10, 0),
              child: Text(
                timeString,
                style: TextStyle(
                    fontSize: 15,
                    color: hexColor("333333"),
                    fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
      onTap: () {
        _gotoVideoDetailPage(index);
      },
    );
  }

  void _tryToDeleteVideoAtIndex(int index) {
    print("_tryToDeleteVideoAtIndex: $index");
    _sweetSheet.show(
        context: context,
        title: Text("确定删除此视频？"),
        description: Text("此视频将从本地被永久删除。"),
        color: SweetSheetColor.DANGER,
        // icon: Icons.portable_wifi_off,
        positive: SweetSheetAction(
          onPressed: () {
            Navigator.of(context).pop();
            _toDeleteVideoAtIndex(index);
          },
          title: "确认",
        ),
        negative: SweetSheetAction(
          title: "取消",
          onPressed: () {
            Navigator.of(context).pop();
          },
        ));
  }

  void _toDeleteVideoAtIndex(int index) {
    String videoFilePath = this.arrOfData[index];
    File f = new File(videoFilePath);
    if (f.existsSync()) {
      f.deleteSync();
    }

    setState(() {
      this.arrOfData.removeAt(index);
      this.thumbnailImagePaths.removeAt(index);
    });
  }

  void _gotoVideoDetailPage(int index) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (BuildContext context) => VideoPlayerPage(
              this.arrOfData[index],
              shouldDeleteVideo: false,
            )));
  }
}
