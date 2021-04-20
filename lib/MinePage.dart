import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:magic_teleprompter/others/models/CommonValues.dart';
import 'package:magic_teleprompter/others/tools/GlobalTool.dart';
import 'package:magic_teleprompter/others/tools/HudTool.dart';
import 'package:magic_teleprompter/others/tools/NotificationCenter.dart';
import 'package:magic_teleprompter/others/tools/OrientationTool.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sweetsheet/sweetsheet.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'CustomWebviewPage.dart';
import 'RemainingVideoListPage.dart';

class MinePage extends StatefulWidget {
  MinePage({Key key}) : super(key: key);

  @override
  _MinePageState createState() => _MinePageState();
}

class _MinePageState extends State<MinePage> {
  List<String> _backgroundColorList = [
    "B1AA2C",
    "518A26",
    "986529",
    "15244B",
  ];

  String cacheSize = "0M";
  String qqCode = "724907020";
  String privacyUrl =
      "https://magic-teleprompter-app.herokuapp.com/privacy.html";
  String developmentStoryUrl =
      "https://magic-teleprompter-app.herokuapp.com/app_story.html";
  int unhandledVideoCount = 0;

  final SweetSheet _sweetSheet = SweetSheet();

  double itemRadio = 1.0;

  @override
  void initState() {
    super.initState();

    NotificationCenter().addObserver("MineTabbarClicked", (params) {
      print("MineTabbarClicked");
      _calculateCache();
      _calculateVideoCount();
    });

    OrientationTool().addOrientationChangeHandler((o1, o2) {
      print("o1: $o1, o2: $o2");
      if (o2 == DeviceOrientation.portraitDown ||
          o2 == DeviceOrientation.portraitUp) {
        CommonValues().makeSure();
        this.itemRadio = ((CommonValues().screenWidth - 3 * 20.0) /
            (CommonValues().screenHeight - 50 * 4.0 - 20));
      } else {
        this.itemRadio = 1.0;
      }
      setState(() {});
    });

    if (OrientationTool().isPortrait()) {
      this.itemRadio = ((CommonValues().screenWidth - 3 * 20.0) /
          (CommonValues().screenHeight - 50 * 4.0 - 20));
    } else {
      this.itemRadio = 1.0;
    }

    _calculateCache();
    _calculateVideoCount();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    print("didChangeDependencies");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return Container(
      color: Colors.white,
      child: GridView(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          mainAxisSpacing: 20,
          crossAxisSpacing: 20,
          childAspectRatio: this.itemRadio,
          crossAxisCount: 2,
        ),
        padding: EdgeInsets.fromLTRB(20, 50, 20, 50),
        children: [
          _buildMineItem(0, "我的-清理缓存", "清理缓存", "当前缓存：${this.cacheSize}\n点击清理"),
          _buildMineItem(1, "我的-隐私条款", "隐私条款", "关于您的数据的隐私条款"),
          _buildMineItem(2, "我的-问题反馈", "问题反馈", "请加QQ群：\n${this.qqCode}"),
          _buildMineItem(
              3, "我的-视频列表", "未导视频", "尚未导出的视频列表(${this.unhandledVideoCount})"),
        ],
      ),
    );
  }

  Widget _buildMineItem(
      int index, String imageName, String title, String subtitle) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: EdgeInsets.fromLTRB(15, 20, 15, 20),
        decoration: BoxDecoration(
          color: hexColor(this._backgroundColorList[index]),
          borderRadius: BorderRadius.all(Radius.circular(23.0)),
          boxShadow: [
            BoxShadow(
              blurRadius: 10,
              offset: Offset(2, 2),
              spreadRadius: 0,
              color: Color(0x33000000),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset(
              "assets/images/$imageName.png",
              width: 45,
              height: 45,
              fit: BoxFit.contain,
            ),
            Container(
              margin: EdgeInsets.fromLTRB(0, 15, 0, 10),
              child: Text(
                title,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.bold),
              ),
            ),
            Text(
              subtitle,
              style: TextStyle(color: hexColor("DDDDDD"), fontSize: 18),
            ),
          ],
        ),
      ),
      onTap: () {
        _clickedAtIndex(index);
      },
    );
  }

  void _clickedAtIndex(int index) {
    print("_clickedAtIndex: $index");

    if (index == 0) {
      _tryToClearCache();
    } else if (index == 1) {
      _tryToEnterWebPage(this.privacyUrl, "隐私条款");
    } else if (index == 2) {
      _tryToCopyQQCode();
    } else {
      // _tryToEnterWebPage(this.developmentStoryUrl, "开发小传");
      _tryToEnterVideoListPage();
    }
  }

  void _tryToEnterVideoListPage() async {
    if (this.unhandledVideoCount == 0) {
      HudTool.showErrorWithStatus("尚无未导出的视频");
      _calculateVideoCount();
      return;
    }
    Navigator.of(context).push(MaterialPageRoute(
        builder: (BuildContext context) => RemainingVideoListPage()));
    _calculateVideoCount();
  }

  void _tryToEnterWebPage(String url, String title) {
    showBarModalBottomSheet(
      context: context,
      expand: true,
      enableDrag: false,
      backgroundColor: Colors.black,
      builder: (context) => CustomWebviewPage(url, title),
    );
  }

  void _tryToCopyQQCode() {
    Clipboard.setData(ClipboardData(text: this.qqCode));
    HudTool.showInfoWithStatus("QQ群号已复制到剪切板：\n${this.qqCode}");
  }

  void _tryToClearCache() {
    _sweetSheet.show(
      context: context,
      title: Text("确定要清理缓存？"),
      description: Text("您创建的提词列表不会被删除；但您所拍摄的视频文件可能因此而丢失。"),
      color: SweetSheetColor.WARNING,
      // icon: Icons.portable_wifi_off,
      positive: SweetSheetAction(
        onPressed: () {
          Navigator.of(context).pop();
          _clearApplicationCache();
        },
        title: "确定",
      ),
    );
  }

  void _calculateVideoCount() async {
    Directory cacheDir = await getTemporaryDirectory();
    Directory videoDir = new Directory(cacheDir.path);
    if (Platform.isIOS) {
      videoDir = new Directory('${cacheDir.path}/lsqTempDir');
    }
    final List<FileSystemEntity> children = videoDir.listSync();
    int result = 0;
    for (final FileSystemEntity fse in children) {
      if (fse is Directory) {
        continue;
      }

      if (fse.path.endsWith(".mp4") || fse.path.endsWith(".MP4")) {
        print("paththt: ${fse.path}");
        String videoName = getFileNameByPath(fse.path);
        print("videoName: $videoName");
        result++;
      }
    }

    setState(() {
      this.unhandledVideoCount = result;
    });
  }

  void _calculateCache() async {
    Directory cacheDir = await getTemporaryDirectory();
    double value = await getTotalSizeOfFilesInDir(cacheDir);
    print("_calculateCache: $value");
    setState(() {
      this.cacheSize = this._formatSize(value);
    });
  }

  /// 循环计算文件的大小（递归）
  Future<double> getTotalSizeOfFilesInDir(final FileSystemEntity file) async {
    if (file is File) {
      int length = await file.length();
      return double.parse(length.toString());
    }
    if (file is Directory) {
      final List<FileSystemEntity> children = file.listSync();
      double total = 0;
      if (children != null)
        for (final FileSystemEntity child in children)
          total += await getTotalSizeOfFilesInDir(child);
      return total;
    }
    return 0;
  }

  String _formatSize(double value) {
    if (null == value || value < (1024.0)) {
      return '0M';
    }

    if (value < (1024.0 * 1024.0)) {
      double kValue = value / 1024.0;
      int k = kValue.toInt();
      return "${k}K";
    } else if (value < (1024 * 1024 * 1024.0)) {
      double mValue = value / (1024 * 1024.0);
      int m = mValue.toInt();
      return "${m}M";
    } else {
      double gValue = value / (1024 * 1024 * 1024.0);
      int g = gValue.toInt();
      return "${g}G";
    }
  }

  /// 删除缓存
  void _clearApplicationCache() async {
    HudTool.show();
    Directory directory = await getTemporaryDirectory();
    print("directory: $directory");
    //删除缓存目录
    await _deleteDirectory(directory);
    HudTool.showInfoWithStatus("已清理");

    setState(() {
      this.cacheSize = "0M";
    });
  }

  /// 递归方式删除目录
  Future<Null> _deleteDirectory(FileSystemEntity file) async {
    if (file is Directory) {
      final List<FileSystemEntity> children = file.listSync();
      for (final FileSystemEntity child in children) {
        // await _deleteDirectory(child);
        if (child is File) {
          await child.delete();
        }
      }
    }
    // await file.delete();
  }
}
