import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../widgets/customCamera.dart';
import '../widgets/producePanel.dart';
import '../methods/checkProduce.dart';

class HomePage extends StatefulWidget {
  final CameraDescription camera;

  const HomePage({super.key, required this.camera});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<CameraPreviewWidgetState> _cameraKey = GlobalKey();
  String? detectedProduce;
  bool isProcessing = false;

  // Add new method for XFile
  Future<void> processXFileImage(XFile image) async {
    setState(() {
      isProcessing = true;
      detectedProduce = null;
    });

    try {
      final result = await ProduceChecker.checkProduce(image);
      if (result != null) {
        setState(() {
          detectedProduce = result['vegetable'];
        });
      }
    } catch (e) {
      print('Processing error: $e');
    } finally {
      setState(() {
        isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            CameraPreviewWidget(
              key: _cameraKey,
              camera: widget.camera,
              onPictureTaken: processXFileImage,
            ),
            ProducePanel(
              cameraKey: _cameraKey,
            ),
          ],
        ),
      ),
    );
  }
}
