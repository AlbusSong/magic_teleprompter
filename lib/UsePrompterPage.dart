import 'package:flutter/material.dart';
// import 'package:camerawesome/camerawesome_plugin.dart';
// import 'package:camerawesome/models/orientations.dart';
import 'package:flutter/services.dart';
import 'package:magic_teleprompter/others/tools/GlobalTool.dart';
import 'package:camera/camera.dart';
import 'others/models/Trifle.dart';

class UsePrompterPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _UsePrompterPageState();
  }
}

class _UsePrompterPageState extends State<UsePrompterPage> {
  CameraController _controller;
  Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();

    _controller = CameraController(
      // Get a specific camera from the list of available cameras.
      Trifle().cameras[1],
      // Define the resolution to use.
      ResolutionPreset.veryHigh,
    );
    _initializeControllerFuture = _controller.initialize();
    _controller.prepareForVideoRecording();
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      // appBar: AppBar(
      //   title: Text("OCR拍照"),
      //   centerTitle: true,
      // ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return FutureBuilder<void>(
      future: _initializeControllerFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          // If the Future is complete, display the preview.
          return _realBody();
        } else {
          // Otherwise, display a loading indicator.
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Widget _realBody() {
    return Container(
      child: Stack(
        alignment: Alignment.center,
        children: [
          AspectRatio(
              aspectRatio: 1.0 / _controller.value.aspectRatio,
              child: CameraPreview(_controller))
        ],
      ),
    );
  }
}
