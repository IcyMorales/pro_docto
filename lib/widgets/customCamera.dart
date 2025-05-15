import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class CameraPreviewWidget extends StatefulWidget {
  final CameraDescription camera;
  final Function(CameraImage)? onImageAvailable;

  const CameraPreviewWidget({
    super.key,
    required this.camera,
    this.onImageAvailable,
  });

  @override
  State<CameraPreviewWidget> createState() => _CameraPreviewWidgetState();
}

class _CameraPreviewWidgetState extends State<CameraPreviewWidget> {
  late CameraController _cameraController;
  late Future<void> _initializeCameraController;

  @override
  void initState() {
    super.initState();
    _cameraController = CameraController(
      widget.camera,
      ResolutionPreset.medium,
      enableAudio: false,
    );
    _initializeCameraController = _cameraController.initialize().then((_) {
      if (!mounted) return;

      _cameraController.startImageStream((image) {
        widget.onImageAvailable?.call(image);
      });
    });
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initializeCameraController,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return CameraPreview(_cameraController);
        }
        return const Center(child: CircularProgressIndicator());
      },
    );
  }
}
