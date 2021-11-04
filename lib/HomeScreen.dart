import 'dart:io';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:ee3080_dip049/folderManager.dart';
import 'package:path_provider/path_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  File? imageFile;
  FolderManager folderManager = new FolderManager();
  List<Widget> listOfProjects = [];

  Future _openCamera() async {
    var picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.camera);
    _storeImageInTempFolderAndProcessIt(image);
  }

  void _storeImageInTempFolderAndProcessIt(originalImage) {
    folderManager.tempFolderPath.then((tempFolderPath) {
      final newPathOfImageTakenStoredInTempFolder =
          "$tempFolderPath${originalImage!.path.split('/').last}";
      // a File consisiting an image is created from the image path. This file is now stored in the imagePathString.
      File(originalImage.path).copy(newPathOfImageTakenStoredInTempFolder);
      setState(() {
        Navigator.pushNamed(context, '/process',
            arguments: {'imagePath': newPathOfImageTakenStoredInTempFolder});
      });
    });
  }

  Future _openGallery() async {
    var picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    _storeImageInTempFolderAndProcessIt(image);
  }

  Future<List<String>> getAllProjectsFolderPath() async {
    List<String> listOfDirPath = [];
    var appDocsDir = await getApplicationDocumentsDirectory();
    var projectRoot = Directory("${appDocsDir.path}/Projects");
    projectRoot.createSync();
    await for (var dir
        in projectRoot.list(recursive: false, followLinks: false)) {
      listOfDirPath.add(dir.path);
    }
    return listOfDirPath;
  }

  void onReturnToHomeScreen(dynamic _) {
    _generateListOfProjects();
    setState(() {});
  }

  void _generateListOfProjects() {
    getAllProjectsFolderPath().then((allProjectsFolderPath) {
      List<Widget> listOfProjectsTemp = [];
      for (var i = 0; i < allProjectsFolderPath.length; i++) {
        String projectTitle = allProjectsFolderPath[i].split('/').last;
        List<String> protectedFolders = ['flutter_assets', 'res_timestamp'];
        if (projectTitle != protectedFolders[0]) {
          File configFile = File(allProjectsFolderPath[i] + "/config.json");
          if (configFile.existsSync()) {
            Map<String, dynamic> jsonFileContent =
                json.decode(configFile.readAsStringSync());
            if (jsonFileContent.containsKey("project_title")) {
              projectTitle = jsonFileContent["project_title"];
            }
          }

          listOfProjectsTemp.add(new Card(
            key: Key(allProjectsFolderPath[i]),
            child: ListTile(
              title: Text(projectTitle),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/edit_page', arguments: {
                        'projectFolderPath': allProjectsFolderPath[i]
                      }).then(onReturnToHomeScreen);
                    },
                    icon: Icon(Icons.edit),
                  ),
                  IconButton(
                    onPressed: () {
                      _deleteProjWarning(
                          listOfProjectsTemp, allProjectsFolderPath, i);
                    },
                    icon: Icon(Icons.delete),
                  )
                ],
              ),
            ),
          ));
        }
      }
      setState(() {
        listOfProjects = listOfProjectsTemp;
      });
    });
  }

  Future<dynamic> _deleteProjWarning(
      List<Widget> listOfProjects, List<String> allProjectsFolderPath, int i) {
    return showDialog(
        context: context,
        builder: (context) => AlertDialog(
                title: Text('Delete Project?'),
                content: Text('Deleted projects cannot be recovered.'),
                actions: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        listOfProjects.removeAt(listOfProjects
                            .map((e) => e.key)
                            .toList()
                            .indexOf(Key(allProjectsFolderPath[i])));

                        Directory deleteDir =
                            Directory(allProjectsFolderPath[i]);
                        deleteDir.deleteSync(recursive: true);
                        allProjectsFolderPath.removeAt(i);
                      });
                      print(i);
                      Navigator.pop(context);
                    },
                    child: Text('DELETE'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: Text('CANCEL'),
                  )
                ]));
  }

  Future<void> _addImageShowChoiceDialog(BuildContext context) {
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
                    ),
                  ],
                ),
              ));
        });
  }

  @override
  initState() {
    super.initState();
    _generateListOfProjects();
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
                  children: listOfProjects,
                ),
              ],
            )),
        floatingActionButton: Container(
          height: 100,
          width: 100,
          child: FittedBox(
            child: FloatingActionButton(
                child: Icon(Icons.photo_camera_outlined),
                onPressed: () async {
                  await _addImageShowChoiceDialog(context);
                }),
          ),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      ),
    );
  }
}
