import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../widgets/customCamera.dart';
import '../widgets/producePanel.dart';

class HomePage extends StatefulWidget {
  final CameraDescription camera;

  const HomePage({super.key, required this.camera});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? detected_produce;

  void onProduceDetected(String produceName) {
    setState(() {
      detected_produce = produceName;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            CameraPreviewWidget(camera: widget.camera),
            ProducePanel(
              detected_produce: detected_produce,
              onProduceDetected: onProduceDetected,
            ),
          ],
        ),
      ),
    );
  }
}
