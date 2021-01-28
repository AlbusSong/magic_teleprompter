import 'package:flutter/material.dart';
import 'package:magic_teleprompter/others/tools/GlobalTool.dart';
import 'package:magic_teleprompter/others/tools/SqliteTool.dart';
import 'others/widgets/GradientText.dart';
import 'others/tools/HudTool.dart';
import 'others/models/PromterModel.dart';

class CreatePromterPage extends StatefulWidget {
  CreatePromterPage({this.data});

  PromterModel data;
  @override
  State<StatefulWidget> createState() {
    return _CreatePromterPageState(data: this.data);
  }
}

class _CreatePromterPageState extends State<CreatePromterPage> {
  _CreatePromterPageState({this.data});

  PromterModel data;
  String title;
  String content;

  @override
  void initState() {
    super.initState();

    this.title = this.data.title;
    this.content = this.data.content;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text(
            this.data == null ? "创建" : "修改",
            style: TextStyle(
                fontFamily: "PingFangSC-Regular",
                fontSize: 22,
                color: hexColor("1D1E2C")),
          ),
          iconTheme: IconThemeData(
            color: Colors.black, //change your color here
          ),
          brightness: Brightness.light,
          backgroundColor: Colors.white,
          centerTitle: true,
          elevation: 0.5,
          actions: <Widget>[
            FlatButton(
                onPressed: () {
                  _tryToSave();
                },
                child: Text(
                  "保存",
                  style: TextStyle(fontSize: 19, color: hexColor("819847")),
                ))
          ]),
      backgroundColor: Colors.white,
      body: GestureDetector(
        child: _buildBody(),
        onTap: () {
          hideKeyboard(context);
        },
      ),
    );
    ;
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 标题
          Container(
            margin: EdgeInsets.fromLTRB(15, 25, 15, 0),
            height: 39,
            // color: randomColor(),
            child: ShaderMask(
              shaderCallback: (bounds) {
                return LinearGradient(
                        colors: [hexColor("94BA68"), hexColor("C5CC38")])
                    .createShader(Offset.zero & bounds.size);
              },
              child: Text(
                "标题",
                style: TextStyle(
                    fontFamily: "PingFangTC-Regular",
                    fontSize: 30,
                    color: Colors.white),
              ),
            ),
          ),

          // 标题输入框
          Container(
            margin: EdgeInsets.fromLTRB(15, 15, 15, 10),
            height: 65,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  blurRadius: 10,
                  offset: Offset(3, 3.0),
                  spreadRadius: 0,
                  color: Color(0xaa000000),
                ),
              ],
              gradient: new LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.topRight,
                  colors: [hexColor("1F6919"), hexColor("2055A0")]),
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextField(
              controller: TextEditingController(text: this.title),
              onChanged: (text) {
                this.title = text;
              },
              style: TextStyle(
                  fontFamily: "PingFangTC-Regular",
                  fontSize: 24,
                  color: Colors.white),
              maxLines: 1,
              decoration: InputDecoration(
                  contentPadding: EdgeInsets.fromLTRB(10, 15, 10, 0),
                  border: InputBorder.none,
                  hintText: "请输入...",
                  hintStyle: TextStyle(
                      fontFamily: "PingFangTC-Regular",
                      fontSize: 24,
                      color: hexColor("BBBBBB"))),
            ),
          ),

          Container(
            margin: EdgeInsets.fromLTRB(15, 25, 15, 0),
            height: 39,
            child: GradientText(
              "提词内容",
              gradient: LinearGradient(
                  colors: [hexColor("AA0D7D"), hexColor("C3BBA5")]),
              style: TextStyle(fontFamily: "PingFangTC-Regular", fontSize: 30),
            ),
          ),

          // 内容输入框
          Container(
            margin: EdgeInsets.fromLTRB(15, 15, 15, 10),
            height: 215,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  blurRadius: 10,
                  offset: Offset(3, 3.0),
                  spreadRadius: 0,
                  color: Color(0xaa000000),
                ),
              ],
              gradient: new LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.topRight,
                  colors: [hexColor("9A8D8A"), hexColor("365588")]),
              borderRadius: BorderRadius.circular(8),
            ),
            child: TextField(
              controller: TextEditingController(text: this.content),
              onChanged: (text) {
                this.content = text;
              },
              style: TextStyle(
                  fontFamily: "PingFangTC-Regular",
                  fontSize: 20,
                  color: Colors.white),
              maxLines: 500,
              decoration: InputDecoration(
                  contentPadding: EdgeInsets.fromLTRB(10, 15, 10, 10),
                  border: InputBorder.none,
                  hintText: "请输入...",
                  hintStyle: TextStyle(
                      fontFamily: "PingFangTC-Regular",
                      fontSize: 20,
                      color: hexColor("BBBBBB"))),
            ),
          ),
        ],
      ),
    );
  }

  Future _tryToSave() async {
    if (isAvailable(this.title) == false) {
      HudTool.showErrorWithStatus("请输入标题");
      return;
    }
    if (isAvailable(this.content) == false) {
      HudTool.showErrorWithStatus("请输入内容");
      return;
    }

    bool isEmpty = (this.data == null);
    if (isEmpty) {
      int the_id = await SqliteTool().createPrompter(this.title, this.content);
      this.data = PromterModel(the_id, this.title, this.content);
    } else {
      int res = await SqliteTool()
          .updatePrompter(this.data.the_id, this.title, this.content);
      print("updatePrompter res: $res");
      this.data.title = this.title;
      this.data.content = this.content;
    }
    HudTool.showInfoWithStatus(isEmpty ? "创建成功" : "修改成功");
    Navigator.of(context).pop(this.data);
  }
}
