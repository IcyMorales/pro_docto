import 'package:flutter/material.dart';
import 'package:expandable/expandable.dart';
import 'package:provider/provider.dart';
import 'package:camera/camera.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
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
  // ignore: library_private_types_in_public_api
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late CameraController _cameraController;
  late Future<void> _initializeCameraController;
  String? detected_produce; // Initial value

  @override
  void initState() {
    super.initState();
    _cameraController = CameraController(
      widget.camera,
      ResolutionPreset.high,
    );
    _initializeCameraController = _cameraController.initialize();
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  void onProduceDetected(String produceName) {
    setState(() {
      detected_produce = produceName;
    });
  }

  Widget _buildProduceInfo() {
    if (detected_produce == null) {
      return const Center(
        child: Text('No produce detected yet'),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('Produce')
          .where('Name', isEqualTo: detected_produce)
          .limit(1)
          .snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return const Text('Something went wrong');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.data!.docs.isEmpty) {
          return Center(
            child: Text('No data found for $detected_produce'),
          );
        }

        final produceData =
            snapshot.data!.docs.first.data() as Map<String, dynamic>;
        final produceId = snapshot.data!.docs.first.id;
        print('Produce ID: $produceId'); // Debugging line

        // Changed nutrients query to independent collection
        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('Nutrition') // Changed from 'Nutrient' to 'Nutrition'
              .where('Produce_ID', isEqualTo: produceId)
              .snapshots(),
          builder: (BuildContext context,
              AsyncSnapshot<QuerySnapshot> nutritionSnapshot) {
            // Changed variable name for consistency
            if (nutritionSnapshot.hasError) {
              return const Text('Error loading nutrition data');
            }

            if (nutritionSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Produce Information
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ListTile(
                      title: Text(
                        'Details',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        produceData['Description'] ??
                            'No description available',
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      child: Row(
                        children: [
                          const Text(
                            'Price: ',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '₱${produceData['Price'] ?? '0.00'}',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Color(0xFFD67A0F),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
                const Divider(),
                // Nutrients List
                Expanded(
                  child: ListView.builder(
                    itemCount: nutritionSnapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      final nutrientData = nutritionSnapshot.data!.docs[index]
                          .data() as Map<String, dynamic>;
                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        child: ListTile(
                          title: Text(
                            nutrientData['Name'] ?? 'Unknown Nutrient',
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                          subtitle: Row(
                            children: [
                              Text(
                                'Value: ${nutrientData['Value']} ',
                                style: const TextStyle(
                                  color: Color(0xFFD67A0F),
                                ),
                              ),
                              Text(
                                'DV: ${nutrientData['DV']}%',
                                style: const TextStyle(
                                  color: Color(0xFFD67A0F),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildNutrientDetail(String label, dynamic value) {
    if (value == null || value.toString().isEmpty)
      return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFFD67A0F),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value.toString(),
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraButton() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFDB7307),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: const Icon(Icons.camera, size: 40, color: Colors.white),
        onPressed: () {
          // Simulate detection - replace with actual detection logic
          onProduceDetected(
              'Malunggay'); // Replace with actual detected produce name
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
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
                            ? MediaQuery.of(context).size.height * 0.85
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
                          controller: ExpandableController(
                              initialExpanded: appState.maxDetails),
                          child: ExpandablePanel(
                            header: GestureDetector(
                              onTap: () {
                                appState.toggleDetails();
                              },
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      detected_produce ?? 'No Produce Detected',
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                    Icon(
                                      appState.maxDetails
                                          ? Icons.arrow_drop_down
                                          : Icons.arrow_drop_up,
                                      color: Colors.black,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            collapsed: SizedBox(
                              height: 100,
                              child: _buildProduceInfo(),
                            ),
                            expanded: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.75,
                                child: _buildProduceInfo(),
                              ),
                            ),
                            theme: const ExpandableThemeData(
                              tapHeaderToExpand: true,
                              hasIcon: false,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  _buildCameraButton(),
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
