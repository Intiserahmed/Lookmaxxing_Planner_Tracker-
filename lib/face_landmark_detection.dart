import 'package:flutter/services.dart';

class FaceLandmarkDetection {
  static const MethodChannel _channel = MethodChannel(
    'face_landmark_detection',
  );

  static Future<List<double>> detectFaceLandmarks(String imagePath) async {
    try {
      final List<double> landmarks = await _channel.invokeMethod(
        'detectFaceLandmarks',
        imagePath,
      );
      return landmarks;
    } on PlatformException catch (e) {
      print("Failed to detect face landmarks: '${e.message}'.");
      return [];
    }
  }
}
