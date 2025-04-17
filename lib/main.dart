import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'face_landmark_detection.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Face Landmark Detection',
      home: MyHomePage(title: 'Face Landmark Detection'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, this.title});

  final String? title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File? _image;
  ui.Image? _uiImage;
  List<double>? _landmarks;
  final ImagePicker _picker = ImagePicker();

  Future<void> _loadImage(File imageFile) async {
    final Completer<ImageInfo> completer = Completer();
    final image = Image.file(imageFile).image;
    image
        ?.resolve(const ImageConfiguration())
        .addListener(
          ImageStreamListener((ImageInfo info, _) {
            completer.complete(info);
          }),
        );
    final info = await completer.future;
    setState(() {
      _uiImage = info.image;
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    final XFile? pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      final File imageFile = File(pickedFile.path);
      setState(() {
        _image = imageFile;
        _landmarks = null;
        _uiImage = null;
      });
      await _loadImage(imageFile);
      final List<double> landmarks =
          await FaceLandmarkDetection.detectFaceLandmarks(imageFile.path);
      setState(() {
        _landmarks = landmarks;
      });
      print('Detected landmarks: $_landmarks');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title!)),
      body: Center(
        child:
            _image == null
                ? const Text('No image selected.')
                : Stack(
                  children: [
                    Image.file(_image!),
                    if (_landmarks != null && _uiImage != null)
                      CustomPaint(
                        painter: FaceLandmarkPainter(_uiImage!, _landmarks!),
                        child: Container(),
                      ),
                  ],
                ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          FloatingActionButton(
            onPressed: () => _pickImage(ImageSource.gallery),
            tooltip: 'Pick Image from gallery',
            child: const Icon(Icons.photo),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: FloatingActionButton(
              onPressed: () => _pickImage(ImageSource.camera),
              tooltip: 'Take a Photo',
              child: const Icon(Icons.camera_alt),
            ),
          ),
        ],
      ),
    );
  }
}

class FaceLandmarkPainter extends CustomPainter {
  final ui.Image image;
  final List<double> landmarks;

  FaceLandmarkPainter(this.image, this.landmarks);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint =
        Paint()
          ..color = Colors.red
          ..style = PaintingStyle.fill
          ..strokeWidth = 2;

    final width = image.width.toDouble();
    final height = image.height.toDouble();

    for (int i = 0; i < landmarks.length; i += 2) {
      canvas.drawCircle(
        Offset(landmarks[i] * width, landmarks[i + 1] * height),
        2,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(FaceLandmarkPainter oldDelegate) => true;
}
