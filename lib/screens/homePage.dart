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
  double? produceAccuracy;
  String? produceQuality; // Add this line
  bool isProcessing = false;

  Future<void> processXFileImage(XFile image) async {
    setState(() {
      isProcessing = true;
      detectedProduce = null;
      produceAccuracy = null;
      produceQuality = null; // Add this line
    });

    try {
      final result = await ProduceChecker.checkProduce(image);
      if (result != null) {
        setState(() {
          detectedProduce = result['vegetable'];
          produceAccuracy = result['vegetable_confidence'];
          produceQuality = result['freshness']; // Add this line
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
    final size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SizedBox.expand(
          // Makes the Stack take full screen
          child: Stack(
            fit: StackFit.expand, // Makes children expand to fill the Stack
            children: [
              SizedBox.expand(
                // Makes the camera preview take full screen
                child: CameraPreviewWidget(
                  key: _cameraKey,
                  camera: widget.camera,
                  onPictureTaken: processXFileImage,
                ),
              ),
              Positioned(
                // Position the ProducePanel at the bottom
                left: 0,
                right: 0,
                bottom: 0,
                child: ProducePanel(
                  produceName: detectedProduce ?? '',
                  produceAccuracy: produceAccuracy ?? 0.0,
                  produceQuality: produceQuality ?? 'Unknown',
                  cameraKey: _cameraKey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
