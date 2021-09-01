import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File? _imageFile;

  Future getImage() async {
    var picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.camera);

    setState(() {
      _imageFile = File(image!.path);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home"),
      ),
      body: Center(
          child:
              _imageFile == null ? Text("No image.") : Image.file(_imageFile!)),
      floatingActionButton: FloatingActionButton(
        onPressed: getImage,
        tooltip: 'Scan',
        child: Icon(Icons.add_a_photo),
      ), //
    );
  }
}
