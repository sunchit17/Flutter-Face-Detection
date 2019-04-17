import 'dart:io';
import 'dart:ui' as ui;
import 'dart:math' show Point, Rectangle, max;

import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Face Detector',
      home: FacePage(),
    );
  }
}

class FacePage extends StatefulWidget {
  @override
  createState() => _FacePageState();
}

class _FacePageState extends State<FacePage> {
  File _imageFile;
  List<Face> _faces;

  //fetching the images from the gallery and processing the image
  void _getImageAndDetectFaces() async {
    final imageFile = await ImagePicker.pickImage(
      source: ImageSource.gallery,
    );
    final image = FirebaseVisionImage.fromFile(imageFile);
    final faceDetector = FirebaseVision.instance.faceDetector(
      FaceDetectorOptions(
        enableClassification: true, //smile probability classification
        mode: FaceDetectorMode.accurate,
        enableLandmarks: true,
      ),
    );
    final faces = await faceDetector.detectInImage(image);
    if (mounted) {
      setState(() {
        _imageFile = imageFile;
        _faces = faces;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _imageFile == null
          ? NoImage()
          : SimpleImageAndFaces(imageFilePath: _imageFile, faces: _faces),
      floatingActionButton: FloatingActionButton(
        onPressed: _getImageAndDetectFaces,
        tooltip: 'Pick an image',
        backgroundColor: Colors.teal[700],
        child: Icon(Icons.add_a_photo),
      ),
    );
  }
}

class NoImage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        padding: EdgeInsets.all(20.0),
        decoration: myBoxDecoration(),
        child: Text(
          'Please Select an Image',
          style: TextStyle(fontSize: 20.0),
        ),
      ),
    );
  }
}

BoxDecoration myBoxDecoration() {
  return BoxDecoration(
    border: Border(
      left: BorderSide(
        color: Colors.teal[500],
        width: 20,
      ),
      top: BorderSide(
        color: Colors.teal[300],
        width: 15,
      ),
      right: BorderSide(
        color: Colors.teal[700],
        width: 20.0,
      ),
      bottom: BorderSide(
        color: Colors.teal[300],
        width: 15,
      ),
    ),
  );
}

class SimpleImageAndFaces extends StatelessWidget {
  SimpleImageAndFaces({@required this.imageFilePath, @required this.faces});

  final File imageFilePath;
  final List<Face> faces;

  @override
  Widget build(BuildContext context) {
    return Column(children: <Widget>[
      Flexible(
        flex: 2,
        child: Container(
            constraints: BoxConstraints.expand(),
            child: Image.file(
              imageFilePath,
              fit: BoxFit.cover,
            )),
      ),
      Flexible(
        flex: 1,
        child: ListView(
          children: faces.map<Widget>((f) => FaceCoordinates(f)).toList(),
        ),
      ),
    ]);
  }
}

class FaceCoordinates extends StatelessWidget {
  FaceCoordinates(this.face);

  final Face face;

  @override
  Widget build(BuildContext context) {
    final pos = face.boundingBox;
    return ListTile(
      title: Text(
          '(T:${pos.top}, L:${pos.left}), (B:${pos.bottom}, R:${pos.right})'),
      subtitle: Text('Probability of smiling: ${face.smilingProbability}'),
    );
  }
}
