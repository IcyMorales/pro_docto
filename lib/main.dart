import 'package:flutter/material.dart';
import 'package:expandable/expandable.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  final firstCamera = cameras.first;

  runApp(
    ChangeNotifierProvider(
      create: (context) => AppState(),
      child: MyApp(camera: firstCamera),
    ),
  );
}

class AppState extends ChangeNotifier {
  bool maxDetails = false;

  void toggleDetails() {
    maxDetails = !maxDetails;
    notifyListeners();
  }
}

class MyApp extends StatelessWidget {
  final CameraDescription camera;

  const MyApp({super.key, required this.camera});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: HomePage(camera: camera),
    );
  }
}

class HomePage extends StatefulWidget {
  final CameraDescription camera;

  const HomePage({super.key, required this.camera});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ExpandableController _expandableController =
      ExpandableController(initialExpanded: false);
  late CameraController _cameraController;
  late Future<void> _initializeCameraController;

  @override
  void initState() {
    super.initState();
    _cameraController = CameraController(
      widget.camera,
      ResolutionPreset.high,
    );
    _initializeCameraController = _cameraController.initialize();

    _expandableController.addListener(() {
      final appState = Provider.of<AppState>(context, listen: false);
      if (_expandableController.expanded != appState.maxDetails) {
        appState.toggleDetails();
      }
    });
  }

  @override
  void dispose() {
    _cameraController.dispose();
    _expandableController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            FutureBuilder<void>(
              future: _initializeCameraController,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return CameraPreview(_cameraController);
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
            Positioned(
              top: MediaQuery.of(context).size.height * 0.05,
              right: MediaQuery.of(context).size.width * 0.1,
              child: Container(
                width: MediaQuery.of(context).size.width * 0.25,
                height: MediaQuery.of(context).size.height * 0.03,
                decoration: BoxDecoration(
                  color: Color(0xFFD07712),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    isExpanded: true,
                    icon: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: Colors.white,
                      size: 25,
                    ),
                    dropdownColor: Color(0xFFD07712),
                    borderRadius: BorderRadius.circular(8),
                    items: [
                      DropdownMenuItem(
                        value: 'Option 1',
                        child: Text('Option 1',
                            style: TextStyle(color: Colors.white)),
                      ),
                      DropdownMenuItem(
                        value: 'Option 2',
                        child: Text('Option 2',
                            style: TextStyle(color: Colors.white)),
                      ),
                      DropdownMenuItem(
                        value: 'Option 3',
                        child: Text('Option 3',
                            style: TextStyle(color: Colors.white)),
                      ),
                    ],
                    onChanged: (value) {
                      print('Selected: $value');
                    },
                    hint: Text(
                      'Select...',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Consumer<AppState>(
                    builder: (context, appState, child) {
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        width: MediaQuery.of(context).size.width * 0.9,
                        height: appState.maxDetails
                            ? MediaQuery.of(context).size.height * 0.6
                            : 200,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(10)),
                          border: Border.all(
                            color: const Color(0xFFD67A0F),
                            width: 4,
                          ),
                        ),
                        child: ExpandableNotifier(
                          controller: _expandableController,
                          child: ExpandablePanel(
                            header: GestureDetector(
                              onTap: () {
                                _expandableController.toggle();
                              },
                              child: const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text(
                                  'Header',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                            collapsed: const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                'Collapsed body text',
                                style: TextStyle(color: Colors.black87),
                              ),
                            ),
                            expanded: const Padding(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                'Expanded body text',
                                style: TextStyle(color: Colors.black87),
                              ),
                            ),
                            theme: const ExpandableThemeData(
                              tapHeaderToExpand: false,
                              hasIcon: true,
                              expandIcon: Icons.arrow_drop_up,
                              collapseIcon: Icons.arrow_drop_down,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  Container(
                    decoration: const BoxDecoration(
                      color: Color(0xFFDB7307),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.camera,
                          size: 40, color: Colors.white),
                      onPressed: () {
                        print('CameraButton pressed ...');
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
