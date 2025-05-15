import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:tflite/tflite.dart';
import '../widgets/customCamera.dart';
import '../widgets/producePanel.dart';

class HomePage extends StatefulWidget {
  final CameraDescription camera;

  const HomePage({super.key, required this.camera});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? detectedProduce;
  bool isProcessing = false;

  Future<void> initializeTflite() async {
    try {
      print('Starting TFLite initialization...');

      // Add a small delay to ensure plugin registration
      await Future.delayed(Duration(milliseconds: 500));

      String? res = await Tflite.loadModel(
          model: "assets/multitask_modelv4.tflite",
          labels: "assets/produceList.txt",
          numThreads: 1,
          isAsset: true,
          useGpuDelegate: false);

      if (res == null) {
        throw Exception('Model loading failed - null response');
      }
      print('Model loading result: $res');
    } catch (e) {
      print('TFLite initialization error: $e');
      rethrow; // Add this to see full stack trace
    }
  }

  Future<void> processImage(CameraImage image) async {
    if (isProcessing) return;
    isProcessing = true;

    try {
      var recognitions = await Tflite.runModelOnFrame(
        bytesList: image.planes.map((plane) => plane.bytes).toList(),
        imageHeight: image.height,
        imageWidth: image.width,
        imageMean: 127.5,
        imageStd: 127.5,
        rotation: 90,
        numResults: 1,
        threshold: 0.5,
        asynch: true,
      );

      print('Raw recognitions: $recognitions');
      if (recognitions != null && recognitions.isNotEmpty) {
        final result = recognitions[0];
        setState(() {
          detectedProduce = result['label'];
          print(
              'Detected: ${result['label']} with confidence: ${result['confidence']}');
        });
      }
    } catch (e) {
      print('Detailed error: $e');
    } finally {
      isProcessing = false;
    }
  }

  @override
  void initState() {
    super.initState();
    initializeTflite();
  }

  @override
  void dispose() {
    Tflite.close();
    super.dispose();
  }

  void onProduceDetected(String produce) {
    setState(() {
      detectedProduce = produce;
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
            CameraPreviewWidget(
              camera: widget.camera,
              onImageAvailable: processImage, // Add this line
            ),
            ProducePanel(
              detected_produce: detectedProduce,
              onProduceDetected: onProduceDetected,
            ),
          ],
        ),
      ),
    );
  }
}
