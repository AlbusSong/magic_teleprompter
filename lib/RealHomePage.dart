import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:magic_teleprompter/others/tools/GlobalTool.dart';

class RealHomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _RealHomePageState();
  }
}

class _RealHomePageState extends State<RealHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return Stack(
      children: [
        Container(
          margin: EdgeInsets.only(
              top: MediaQueryData.fromWindow(window).padding.top),
          width: MediaQuery.of(context).size.width,
          color: Colors.white,
          child: _buildWaterflowView(),
        ),

        // 发布按钮
        Positioned(
            bottom: 20,
            left: (MediaQuery.of(context).size.width - 70) / 2.0,
            child: _buildCreatePostButton())
      ],
    );
  }

  Widget _buildWaterflowView() {
    return Scrollbar(
        child: StaggeredGridView.countBuilder(
      padding: EdgeInsets.symmetric(horizontal: 24),
      crossAxisCount: 4,
      itemCount: 100,
      itemBuilder: (BuildContext context, int index) {
        return GestureDetector(
          child: _buildWaterflowItem(index),
          onTap: () {
            // _tryToEnterDetailPage(index);
          },
        );
      },
      staggeredTileBuilder: (int index) {
        return StaggeredTile.fit(2);
      },
      mainAxisSpacing: 30.0,
      crossAxisSpacing: 24.0,
    ));
  }

  Widget _buildWaterflowItem(int index) {
    return Container(
      height: (50 + randomIntUntil(50) * 1.0),
      color: randomColor(),
    );
  }

  Widget _buildCreatePostButton() {
    return Container(
      width: 70,
      height: 70,
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
            colors: [hexColor("7BC1EA"), hexColor("8134B9")]),
        borderRadius: BorderRadius.circular(35.0),
      ),
      child: Stack(
        children: [
          Center(
            child: Image.asset(
              "assets/images/发布按钮.png",
              width: 36,
              height: 36,
              fit: BoxFit.contain,
            ),
          ),
          Container(
            width: 70,
            height: 70,
            child: FlatButton(
              child: null,
              // color: hexColor("00E8EC"),
              // highlightColor: Colors.white70,
              // colorBrightness: Brightness.dark,
              splashColor: Colors.white70,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(35.0)),
              onPressed: () {
                print("kkkkkkkkkkkllllllll");
                // Navigator.pop(context);
                // Navigator.of(context).push(MaterialPageRoute(
                //     builder: (BuildContext context) => CreatePostPage()));
              },
            ),
          ),
        ],
      ),
    );
  }
}
