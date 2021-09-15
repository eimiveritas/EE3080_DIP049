import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:ee3080_dip049/folderManager.dart';
import 'package:http/http.dart' show get;
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  File? imageFile;
  FolderManager folderManager = new FolderManager();
  List<Widget> listArray = [];

  Future _openCamera() async {
    var picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.camera);
    var imagePathString = "";
    //File('/storage/emulated/0/Download/counter.txt')
    folderManager.tempFolderPath.then((value) {
      print(value);
      imagePathString = "${value}${image!.path.split('/').last}";

      File(image.path).copy(imagePathString);

      setState(() {
        Navigator.pushNamed(context, '/post_process',
            arguments: {'imagePath': imagePathString});
      });
    });
  }

  Future _openGallery() async {
    var picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    var imagePathString = "";
    //File('/storage/emulated/0/Download/counter.txt')
    folderManager.tempFolderPath.then((value) {
      print(value);
      imagePathString = "${value}${image!.path.split('/').last}";

      File(image.path).copy(imagePathString);

      setState(() {
        Navigator.pushNamed(context, '/post_process',
            arguments: {'imagePath': imagePathString});
      });
    });
  }

  void _downloadAndSavePhoto() async {
    //var url = "https://www.tottus.cl/static/img/productos/20104355_2.jpg";
    var url = "https://picsum.photos/200/300";
    var response = await get(Uri.parse(url)); //%%%
    var documentDirectory = await getApplicationDocumentsDirectory();
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd-kk-mm').format(now);
    var firstPath = documentDirectory.path + "/$formattedDate";
    await Directory(firstPath).create(recursive: true);
    // Name the file, create the file, and save in byte form.
    var filePathAndName = documentDirectory.path + '/$formattedDate/pic.jpg';
    File file2 = new File(filePathAndName); //%%%
    file2.writeAsBytesSync(response.bodyBytes); //%%%
  }

  Future<List<String>> populate() async {
    List<String> listOfDir = [];
    var systemTempDir = await getApplicationDocumentsDirectory();

    // List directory contents, recursing into sub-directories,
    // but not following symbolic links.
    await for (var entity
        in systemTempDir.list(recursive: false, followLinks: false)) {
      print(entity.path);
      listOfDir.add(entity.path);
    }
    return listOfDir;
  }

  void _getListings() {
    // <<<<< Note this change for the return type
    populate().then((value) {
      List<Widget> listings = [];
      for (var i = 0; i < value.length; i++) {
        print("Done");
        listings.add(new Card(
          child: ListTile(
            title: Text(value[i].split('/').last),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/edit_page',
                        arguments: {'folderPath': value[i]});
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
        ));
      }
      setState(() {
        listArray = listings;
      });
      print(listings.length.toString());
    });
  }

  Future<void> _showChoiceDialog(BuildContext context) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
              title: Text('Launch App'),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(15))),
              elevation: 24.0,
              content: SingleChildScrollView(
                child: ListBody(
                  children: [
                    GestureDetector(
                      child: Text('Camera'),
                      onTap: () {
                        _openCamera();
                      },
                    ),
                    Padding(padding: EdgeInsets.all(8.0)),
                    GestureDetector(
                      child: Text('Gallery'),
                      onTap: () {
                        _openGallery();
                      },
                    )
                  ],
                ),
              ));
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
            child: ListView(
              children: [
                Column(
                  children: listArray,
                ),
                TextButton(
                    onPressed: () {
                      _getListings();
                    },
                    child: Text("Test")),
                TextButton(
                    onPressed: () {
                      _downloadAndSavePhoto();
                    },
                    child: Text("Populate"))
              ],
            )),
        floatingActionButton: Container(
          height: 100,
          width: 100,
          child: FittedBox(
            child: FloatingActionButton(
                child: Icon(Icons.photo_camera_outlined),
                onPressed: () async {
                  await _showChoiceDialog(context);
                }),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }
}
