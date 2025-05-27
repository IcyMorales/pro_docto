import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import '../widgets/customCamera.dart';
import '../widgets/producePanel.dart';
import '../methods/checkProduce.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Cloud Firestore

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
  List<String> produces = []; // Add this line to store produce names
  String? selectedProduce;

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
          detectedProduce = selectedProduce;
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
  void initState() {
    super.initState();
    _fetchProduces(); // Fetch produces when widget initializes
  }

  Future<void> _fetchProduces() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('Produce')
          .orderBy('Name')
          .get();

      setState(() {
        produces =
            querySnapshot.docs.map((doc) => doc['Name'] as String).toList();
      });
    } catch (e) {
      print('Error fetching produces: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SizedBox.expand(
          child: Stack(
            fit: StackFit.expand,
            children: [
              SizedBox.expand(
                child: CameraPreviewWidget(
                  key: _cameraKey,
                  camera: widget.camera,
                  onPictureTaken: processXFileImage,
                ),
              ),
              // Add ProduceSelector at top right
              Positioned(
                top: MediaQuery.of(context).padding.top + 16,
                right: 16,
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.4,
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(
                      color: const Color(0xFFDB7307).withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedProduce,
                      hint: const Text(
                        'Select Produce',
                        style: TextStyle(color: Colors.black54),
                      ),
                      isExpanded: true,
                      icon: const Icon(
                        Icons.arrow_drop_down,
                        color: Color(0xFFDB7307),
                      ),
                      items: produces.map((String name) {
                        return DropdownMenuItem<String>(
                          value: name,
                          child: Text(
                            name[0].toUpperCase() + name.substring(1),
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        if (newValue != null) {
                          setState(() {
                            selectedProduce = newValue;
                            detectedProduce = newValue;
                            produceAccuracy = null;
                            produceQuality = 'Unknown';
                          });
                        }
                      },
                    ),
                  ),
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
