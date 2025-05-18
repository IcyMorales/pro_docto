import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expandable/expandable.dart';
import '../states/maxDetStatus.dart';
import 'produceInfo.dart';
import 'customCamera.dart';

class ProducePanel extends StatelessWidget {
  final GlobalKey<CameraPreviewWidgetState> cameraKey;
  final String? produceName;
  final double? produceAccuracy;
  final String? produceQuality;

  const ProducePanel({
    Key? key,
    required this.cameraKey,
    required this.produceName,
    required this.produceAccuracy,
    required this.produceQuality,
  }) : super(key: key);

  Future<Map<String, dynamic>?> _getProduceData() async {
    if (produceName == null) return null;

    try {
      final produceRef = FirebaseFirestore.instance
          .collection('Produce')
          .where('Name', isEqualTo: produceName);

      final querySnapshot = await produceRef.get();

      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first.data();
      } else {
        print('No produce found with name: $produceName');
        return null;
      }
    } catch (e) {
      print('Error fetching produce data: $e');
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get safe area padding
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final screenHeight = MediaQuery.of(context).size.height;

    return FutureBuilder<Map<String, dynamic>?>(
      future: _getProduceData(),
      builder: (context, snapshot) {
        String displayText = 'No Produce Detected';
        if (snapshot.connectionState == ConnectionState.waiting) {
          displayText = 'Loading...';
        } else if (snapshot.hasData && snapshot.data != null) {
          String name = snapshot.data!['Name'] ?? 'Unknown Produce';
          displayText = name[0].toUpperCase() + name.substring(1);
        }

        return Align(
          alignment: Alignment.bottomCenter,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Consumer<AppState>(
                builder: (context, appState, child) {
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    width: MediaQuery.of(context).size.width * 0.9,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(10)),
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
                          onTap: () => appState.toggleDetails(),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  displayText,
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
                          height: 160, // Reduced height
                          child: ProduceInfo(
                            produceData: snapshot.data,
                            produceAccuracy: produceAccuracy,
                            produceQuality: produceQuality,
                          ),
                        ),
                        expanded: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: SizedBox(
                            height: screenHeight * 0.85 -
                                bottomPadding -
                                100, // Adjusted height
                            child: ProduceInfo(
                              produceData: snapshot.data,
                              produceAccuracy: produceAccuracy,
                              produceQuality: produceQuality,
                            ),
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
              const SizedBox(height: 8),
              Padding(
                padding: EdgeInsets.only(bottom: bottomPadding + 8),
                child: _buildCameraButton(),
              ),
            ],
          ),
        );
      },
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
          print('Camera button pressed');
          if (cameraKey.currentState != null) {
            cameraKey.currentState!.takePicture();
          } else {
            print('Camera state is null');
          }
        },
      ),
    );
  }
}
