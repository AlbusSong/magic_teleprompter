import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class CustomWebviewPage extends StatefulWidget {
  CustomWebviewPage(this.url, this.title);

  final String url;
  final String title;

  @override
  _CustomWebviewPageState createState() => _CustomWebviewPageState();
}

class _CustomWebviewPageState extends State<CustomWebviewPage> {
  bool _webviewLoaded = false;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: CupertinoPageScaffold(
        navigationBar: CupertinoNavigationBar(
          // leading: Container(),
          automaticallyImplyLeading: false,
          middle: (this._webviewLoaded
              ? Text(widget.title)
              : CupertinoActivityIndicator()),
        ),
        child: SafeArea(
          bottom: false,
          child: Container(
            clipBehavior: Clip.hardEdge,
            decoration: BoxDecoration(
              color: Colors.white,
            ),
            child: WebView(
              initialUrl: widget.url,
              onPageFinished: (s) {
                setState(() {
                  this._webviewLoaded = true;
                });
              },
            ),
          ),
        ),
      ),
    );
  }
}
