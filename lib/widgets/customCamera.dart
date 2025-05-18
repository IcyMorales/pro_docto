import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class CameraPreviewWidget extends StatefulWidget {
  final CameraDescription camera;
  final Function(XFile)? onPictureTaken;
  final GlobalKey<CameraPreviewWidgetState>? cameraKey;

  const CameraPreviewWidget({
    super.key,
    required this.camera,
    this.onPictureTaken,
    this.cameraKey,
  });

  @override
  State<CameraPreviewWidget> createState() => CameraPreviewWidgetState();
}

class CameraPreviewWidgetState extends State<CameraPreviewWidget> {
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
    _initializeCameraController = _cameraController.initialize();
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  Future<void> takePicture() async {
    if (!_cameraController.value.isInitialized) {
      print('Camera not initialized');
      return;
    }

    try {
      print('Taking picture...');
      final XFile image = await _cameraController.takePicture();
      print('Picture taken: ${image.path}');
      if (widget.onPictureTaken != null) {
        widget.onPictureTaken!(image);
        print('Picture sent to handler');
      } else {
        print('No picture handler available');
      }
    } catch (e) {
      print('Error taking picture: $e');
    }
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

class CustomCamera extends StatefulWidget {
  const CustomCamera({Key? key}) : super(key: key);

  @override
  CustomCameraState createState() => CustomCameraState();
}

class CustomCameraState extends State<CustomCamera> {
  Future<void> takePicture() async {
    // Implement your camera capture logic here
  }

  @override
  Widget build(BuildContext context) {
    // Implement your camera UI here
    return Container();
  }
}
