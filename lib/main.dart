import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'states/maxDetStatus.dart';
import 'screens/homePage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  final cameras = await availableCameras();
  final firstCamera = cameras.first;

  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Debug prints to verify loading
  print('Environment variables loaded: ${dotenv.env}');
  print('API_URL: ${dotenv.env['API_URL'] ?? 'NOT FOUND'}');

  runApp(
    ChangeNotifierProvider(
      create: (context) => AppState(),
      child: MyApp(camera: firstCamera),
    ),
  );
}

class MyApp extends StatelessWidget {
  final CameraDescription camera;

  const MyApp({super.key, required this.camera});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter App',
      theme: ThemeData(primarySwatch: Colors.blue),
      debugShowCheckedModeBanner: false,
      home: HomePage(camera: camera),
    );
  }
}
