import 'dart:convert';
import 'package:camera/camera.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ProduceChecker {
  static Future<Map<String, dynamic>?> checkProduce(XFile image) async {
    try {
      final apiUrl = dotenv.env['API_URL']!;
      print('Attempting to connect to: $apiUrl');

      var request = http.MultipartRequest('POST', Uri.parse('$apiUrl/predict'));

      // Add captured image to request
      request.files.add(
        await http.MultipartFile.fromPath('file', image.path),
      );

      print('Sending image from: ${image.path}');
      var response = await request.send();
      print('Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final responseString = await response.stream.bytesToString();
        print('Response body: $responseString');
        return json.decode(responseString);
      } else {
        final errorResponse = await response.stream.bytesToString();
        print('Error response: $errorResponse');
        throw Exception(
            'API Error: ${json.decode(errorResponse)['error'] ?? 'Status ${response.statusCode}'}');
      }
    } catch (e) {
      print('Connection error: $e');
      return null;
    }
  }
}
