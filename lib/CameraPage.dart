import 'dart:io';
import 'package:ee3080_dip049/folderManager.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';

class CameraPage extends StatefulWidget {
  const CameraPage({Key? key}) : super(key: key);

  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  File? _imageFile;
  FolderManager folderManager = new FolderManager();

  Future getImage() async {
    var picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.camera);
    var imagePathString =
        "${folderManager.tempFolderPath}${image!.path.split('/').last}";
    setState(() {
      _imageFile = File(imagePathString);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home"),
      ),
      body: Center(
          child: _imageFile == null
              ? Text("No image.")
              : Container(
                  child: Column(
                  children: [
                    Image.file(_imageFile!),
                    TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/post_process',
                              arguments: {'imagePath': _imageFile!.path});
                        },
                        child: Text("Post Possess"))
                  ],
                ))),
      floatingActionButton: FloatingActionButton(
        onPressed: getImage,
        tooltip: 'Scan',
        child: Icon(Icons.add_a_photo),
      ), //
    );
  }
}
