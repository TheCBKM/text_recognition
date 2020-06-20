import 'dart:io';

import 'package:firebase_ml_vision/firebase_ml_vision.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File pickedImage;
  bool isImageLoaded = false;

  String mytext = "Text will be displayed here ";

  Future pickImage(BuildContext context) async {
    await showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
            padding: EdgeInsets.all(50.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                FlatButton(
                  child: Icon(Icons.camera,color: Colors.red,),
                  onPressed: () {
                    getImage(ImageSource.camera);
                  },
                ),
                FlatButton(
                  child: Icon(Icons.attach_file,color: Colors.red,),
                  onPressed: () {
                    getImage(ImageSource.gallery);
                  },
                )
              ],
            ),
          );
        });
  }

  Future getImage(ImageSource source) async {
    var tmpStore = await ImagePicker.pickImage(source: source);
    if (tmpStore != null)
      setState(() {
        pickedImage = tmpStore;
        isImageLoaded = true;
      });
    Navigator.pop(context);
  }

  Future readText() async {
    if (isImageLoaded) {
      final FirebaseVisionImage ourImage =
          FirebaseVisionImage.fromFile(pickedImage);
      String rtext = "";
      TextRecognizer recognizedText = FirebaseVision.instance.textRecognizer();
      VisionText readText = await recognizedText.processImage(ourImage);
      for (TextBlock block in readText.blocks) {
        for (TextLine line in block.lines) {
//          print(line.text);
          rtext += line.text + '\n';
        }
      }
      setState(() {
        mytext = rtext;
      });
    }
  }

  Future pridictLables() async {
    if (isImageLoaded) {
      final FirebaseVisionImage ourImage =
          FirebaseVisionImage.fromFile(pickedImage);
      String rtext = "";
      ImageLabeler laberer = FirebaseVision.instance
          .imageLabeler(ImageLabelerOptions(confidenceThreshold: 0.5));
      List<ImageLabel> Ilable = await laberer.processImage(ourImage);
      for (ImageLabel l in Ilable) {
//        print('${l.text} with confidence of ${l.confidence*100}');
        rtext +=
            '${l.text} with confidence of ${(l.confidence * 100).round()}%\n';
      }

      setState(() {
        mytext = rtext;
      });
    }
  }

  Future detectFaces() async {
    if (isImageLoaded) {
      final FirebaseVisionImage ourImage =
          FirebaseVisionImage.fromFile(pickedImage);
      String rtext = "";
      FaceDetector detector =
          FirebaseVision.instance.faceDetector(FaceDetectorOptions(
        enableLandmarks: true,
        enableTracking: true,
      ));
      List<Face> LFaces = await detector.processImage(ourImage);
      for (Face f in LFaces) {
        rtext += '${f.boundingBox} \n';
      }

      setState(() {
        mytext = rtext;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Text Recognition app"),
      ),
      body: Center(
        child: ListView(
          padding: EdgeInsets.all(20.0),
          children: <Widget>[
            SizedBox(
              height: 20.0,
            ),
            isImageLoaded
                ? Center(
                    child: Container(
                      height: 200.0,
                      width: 200.0,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: FileImage(pickedImage),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  )
                : Container(),
            SizedBox(
              height: 10.0,
            ),
            SizedBox(
              height: 10.0,
            ),
            RaisedButton(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.camera,
                    color: Colors.white,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    "Pick an image",
                    style: TextStyle(color: Colors.white),
                  )
                ],
              ),
              color: Colors.blue,
              onPressed: () {
                pickImage(context);
              },
            ),
            SizedBox(
              height: 10.0,
            ),
            RaisedButton(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.search,
                    color: Colors.white,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    "Read Text",
                    style: TextStyle(color: Colors.white),
                  )
                ],
              ),
              color: Colors.blue,
              onPressed: readText,
            ),
            SizedBox(
              height: 10.0,
            ),
            RaisedButton(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.label,
                    color: Colors.white,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    "Predict labels",
                    style: TextStyle(color: Colors.white),
                  )
                ],
              ),
              color: Colors.blue,
              onPressed: pridictLables,
            ),
            SizedBox(
              height: 10.0,
            ),
            RaisedButton(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    Icons.fingerprint,
                    color: Colors.white,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    "Detect faces",
                    style: TextStyle(color: Colors.white),
                  )
                ],
              ),
              color: Colors.blue,
              onPressed: detectFaces,
            ),
            Container(
              padding: EdgeInsets.all(20.0),
              child: SelectableText(mytext),
            )
          ],
        ),
      ),
    );
  }
}
