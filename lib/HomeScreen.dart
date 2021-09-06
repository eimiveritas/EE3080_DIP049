import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  File? imageFile;

  Future getImage() async {
    var picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.camera);

    setState(() {
      imageFile = File(image!.path);
      Navigator.pushNamed(context, '/post_process');
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Projects',
      home: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: const Text('Projects'),
          ),
          body: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Card(
              child: ListTile(
                //onLongPress: ()
                title: Text('Project Name'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          '/edit_page',
                        );
                      },
                      icon: Icon(Icons.edit),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.delete),
                    )
                  ],
                ),
              ),
            ),
          ),
          floatingActionButton: Container(
            height: 100.0,
            width: 100.0,
            child: FittedBox(
              child: FloatingActionButton(
                child: Icon(Icons.photo_camera_outlined),
                onPressed: getImage,
              ),
            ),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat),
    );
  }
}
