import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;
import 'dart:typed_data';
import 'package:typed_data/typed_buffers.dart';
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
  Interpreter? _interpreter;

  Future<void> initializeTflite() async {
    try {
      print('Starting TFLite initialization...');

      // Add delegate options
      final options = InterpreterOptions()
        ..threads = 1
        ..useNnApiForAndroid = true; // Enable Android Neural Networks API

      final modelPath = 'assets/multitask_modelv4.tflite';
      print('Loading model from: $modelPath');

      _interpreter = await Interpreter.fromAsset(
        modelPath,
        options: options,
      );

      if (_interpreter == null) {
        throw Exception('Failed to create interpreter.');
      }

      print('Model loaded successfully');
      print('Input tensor shape: ${_interpreter!.getInputTensor(0).shape}');
      print('Output tensor shape: ${_interpreter!.getOutputTensor(0).shape}');
    } catch (e) {
      print('TFLite initialization error: $e');
      rethrow;
    }
  }

  Future<void> processImage(CameraImage image) async {
    if (isProcessing || _interpreter == null) return;
    isProcessing = true;

    try {
      // Convert image to float32 array
      final inputShape = _interpreter!.getInputTensor(0).shape;
      final outputShape = _interpreter!.getOutputTensor(0).shape;

      // Prepare input data - normalize pixels
      var inputArray =
          Float32List(inputShape[1] * inputShape[2] * inputShape[3]);
      var pixels = image.planes[0].bytes;

      for (var i = 0; i < pixels.length; i++) {
        inputArray[i] = (pixels[i] / 255.0);
      }

      // Prepare output buffer
      var outputBuffer = Float32List(outputShape.reduce((a, b) => a * b));

      // Run inference
      _interpreter!.run(inputArray.buffer, outputBuffer.buffer);

      // Process results
      print('Raw results: ${outputBuffer.toList()}');

      setState(() {
        detectedProduce = "Detected Object"; // Replace with actual detection
      });
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
    _interpreter?.close();
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
