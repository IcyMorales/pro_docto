import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expandable/expandable.dart';
import 'package:image_picker/image_picker.dart';
import '../states/maxDetStatus.dart';
import 'produceInfo.dart';
import 'customCamera.dart';

class ProducePanel extends StatelessWidget {
  final GlobalKey<CameraPreviewWidgetState> cameraKey;

  const ProducePanel({
    Key? key,
    required this.cameraKey,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Get safe area padding
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final screenHeight = MediaQuery.of(context).size.height;

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
                              'No Produce Detected',
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
                      child: ProduceInfo(detected_produce: null),
                    ),
                    expanded: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
                        height: screenHeight * 0.85 -
                            bottomPadding -
                            100, // Adjusted height
                        child: ProduceInfo(detected_produce: null),
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
