import 'package:flutter/material.dart';

class AppState extends ChangeNotifier {
  bool maxDetails = false;

  void toggleDetails() {
    maxDetails = !maxDetails;
    notifyListeners();
  }
}
