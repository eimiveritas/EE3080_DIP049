import 'dart:convert';
import 'dart:io';

import 'package:ee3080_dip049/export_page.dart';
import 'package:flutter/material.dart';
import 'package:ee3080_dip049/folderManager.dart';
import 'package:image_picker/image_picker.dart';

class EditProjectPage extends StatefulWidget {
  EditProjectPage({Key? key, required this.extraArgs}) : super(key: key);
  final extraArgs;

  @override
  _EditProjectPageState createState() => _EditProjectPageState();
}

class PictureObj extends StatelessWidget {
  PictureObj(
      {Key? key,
      required this.picIndex,
      required this.filePath,
      required this.removePage,
      required this.swapPage})
      : super(key: key);

  int picIndex;
  String filePath;
  final Function(int) removePage;
  final Function(int, int) swapPage;

  @override
  Widget build(BuildContext context) {
    var clip = ClipRect(
      child: Align(
        alignment: Alignment.topCenter,
        heightFactor: 1,
        child: Image.file(File(filePath)),
      ),
    );
    var stack = new Stack(
      children: <Widget>[
        Material(
            color: Colors.amber,
            child: InkWell(
              onTap: () {
                debugPrint("You clicked on page!");
              },
              child: clip,
            )),
        Positioned(
          top: 0,
          right: 0,
          child: TextButton(
            onPressed: () {
              debugPrint("You removed page $this.picIndex");
              removePage(this.picIndex);
            },
            child: Text("X"),
            style: TextButton.styleFrom(
                padding: EdgeInsets.all(0),
                backgroundColor: Colors.blue,
                primary: Colors.white),
          ),
        ),
        Positioned(
            bottom: 0,
            //width: 10,
            child: Padding(
              padding: EdgeInsets.all(10),
              child: Text(
                "Page ${this.picIndex} (${filePath.split("/").last})",
                textAlign: TextAlign.center,
                style: TextStyle(
                    backgroundColor: Colors.blue, color: Colors.white),
              ),
            )),
      ],
    );
    var drag = Draggable<String>(
      data: "${picIndex.toString()}",
      child: stack,
      feedback: Flexible(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: 150),
          child: clip,
        ),
      ),
      childWhenDragging: stack,
    );
    var droptarget = DragTarget<String>(
      builder: (BuildContext context, List<String?> incoming, List rejected) {
        return drag;
      },
      onWillAccept: (data) => true,
      onAccept: (data) {
        print("Transferring from $data to ${picIndex.toString()}");
        swapPage(int.parse(data), picIndex);
      },
      onLeave: (data) {},
    );
    return droptarget;
  }
}

class _EditProjectPageState extends State<EditProjectPage> {
  List<Widget> listArray = [];

  File? imageFile;
  FolderManager folderManager = new FolderManager();

  TextEditingController _controller = TextEditingController();

  Future _openCamera(arguments) async {
    var picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.camera);
    var imagePathString = "";
    //File('/storage/emulated/0/Download/counter.txt')
    folderManager.tempFolderPath.then((value) {
      print(value);
      imagePathString = "${value}${image!.path.split('/').last}";

      File(image.path).copy(imagePathString);

      setState(() {
        Navigator.pushNamed(context, '/post_process', arguments: {
          'imagePath': imagePathString,
          'projectFolderPath': arguments["projectFolderPath"],
        });
      });
    });
  }

  Future _openGallery(arguments) async {
    var picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    var imagePathString = "";
    //File('/storage/emulated/0/Download/counter.txt')
    folderManager.tempFolderPath.then((value) {
      print(value);
      imagePathString = "${value}${image!.path.split('/').last}";

      File(image.path).copy(imagePathString);

      setState(() {
        Navigator.pushNamed(context, '/post_process', arguments: {
          'imagePath': imagePathString,
          'projectFolderPath': arguments["projectFolderPath"],
        });
      });
    });
  }

  Future<void> _showChoiceDialog(BuildContext context, arguments) {
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
                        _openCamera(arguments);
                      },
                    ),
                    Padding(padding: EdgeInsets.all(8.0)),
                    GestureDetector(
                      child: Text('Gallery'),
                      onTap: () {
                        _openGallery(arguments);
                      },
                    )
                  ],
                ),
              ));
        });
  }

  Future<List<String>> getAllPicturesPath(projectFolderPath) async {
    List<String> listOfPicsPath = [];
    var projectFolder = Directory(projectFolderPath);
    await for (var pic
        in projectFolder.list(recursive: false, followLinks: false)) {
      listOfPicsPath.add(pic.path);
    }
    listOfPicsPath.sort();
    return listOfPicsPath;
  }

  void _generateGridOfPics(projectFolderPath, arguments) {
    getAllPicturesPath(projectFolderPath).then((listOfPicsPath) {
      List<Widget> listings = [];
      File configFile = File(arguments["projectFolderPath"] + "/config.json");
      List<String> pictureOrder = [];
      bool wasInitialized = false;

      // check if there is already an order
      if (configFile.existsSync()) {
        Map<String, dynamic> jsonFileContent =
            json.decode(configFile.readAsStringSync());
        if (jsonFileContent.containsKey("picture_order")) {
          pictureOrder = jsonFileContent["picture_order"].cast<String>();
          wasInitialized = true;
        }
      }

      // so that config.json doesnt show up in the grid
      if (!wasInitialized) {
        for (var i = 0; i < listOfPicsPath.length; i++) {
          String filename = listOfPicsPath[i].split("/").last;
          List<String> reservedFiles = ["config.json"];
          if (!reservedFiles.contains(filename)) {
            pictureOrder.add(listOfPicsPath[i]);
          }
        }
      }

      for (var i = 0; i < picture_order.length; i++) {
        PictureObj pic = new PictureObj(
            picIndex: i,
            filePath: picture_order[i],
            removePage: (pageIndex) {
              setState(() {
                listArray.removeAt(pageIndex);
              });
            },
            swapPage: (source, dest) {
              var tempObj = listArray[source];
              print("S ${(listArray[source] as PictureObj).picIndex}");
              (listArray[source] as PictureObj).picIndex = dest;
              print("To ${(listArray[source] as PictureObj).picIndex}");

              print("D ${(listArray[dest] as PictureObj).picIndex}");
              (listArray[dest] as PictureObj).picIndex = source;
              print("To ${(listArray[dest] as PictureObj).picIndex}");

              listArray[source] = listArray[dest];
              listArray[dest] = tempObj;
              setState(() {
                listArray = listArray;
              });
            });
        listings.add(pic);
      }

      listings.add(new Stack(
        children: <Widget>[
          Material(
              color: Colors.amber,
              child: InkWell(
                onTap: () async {
                  debugPrint("You clicked on page!");
                  await _showChoiceDialog(context, arguments);
                },
                child: ClipRect(
                  child: Align(
                    alignment: Alignment.center,
                    //heightFactor: 1,
                    child: Text("+", style: TextStyle(fontSize: 50)),
                  ),
                ),
              )),
        ],
      ));

      setState(() {
        listArray = listings;
      });
      print(listings.length.toString());
    });
  }

  @override
  initState() {
    super.initState();
    _generateGridOfPics(
        widget.extraArgs["projectFolderPath"], widget.extraArgs);
  }

  @override
  Widget build(BuildContext context) {
    final Map arguments = ModalRoute.of(context)!.settings.arguments as Map;

    String project_title = arguments['projectFolderPath'].split('/').last;

    File jsonFile = File(arguments['projectFolderPath'] + "/config.json");
    if (jsonFile.existsSync()) {
      Map<String, dynamic> jsonFileContent =
          json.decode(jsonFile.readAsStringSync());
      if (jsonFileContent.containsKey("project_title")) {
        // the order was alr there
        project_title = jsonFileContent["project_title"];
      }
    }

    _controller.text = project_title;

    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Project"),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          TextFormField(
            controller: _controller,
            decoration: const InputDecoration(
                border: OutlineInputBorder(), hintText: 'Untitled Project'),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: EdgeInsets.all(10),
              child: Text(
                'Last saved: 21 Aug 2021 5.00pm ${arguments["projectFolderPath"]}',
              ),
            ),
          ),
          Expanded(
              child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 200,
                      childAspectRatio: 3 / 2,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20),
                  itemCount: listArray.length,
                  itemBuilder: (BuildContext ctx, index) {
                    return listArray[index];
                  })),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              SizedBox(
                width: 10,
              ),
              Expanded(
                  child: TextButton(
                child: Text("Save"),
                onPressed: () {
                  debugPrint("Saving to project ${listArray.length} files...");
                  debugPrint(arguments["projectFolderPath"] + "/config.json");
                  File jsonFile =
                      File(arguments["projectFolderPath"] + "/config.json");

                  Map<String, dynamic> jsonFileContent = {};
                  if (jsonFile.existsSync()) {
                    Map<String, dynamic> jsonFileContent =
                        json.decode(jsonFile.readAsStringSync());
                    print(jsonFileContent);
                  }

                  List<String> picture_order = [];
                  for (var i = 0; i < listArray.length; i++) {
                    if (i == listArray.length - 1) {
                      continue;
                    }
                    print("jiz");
                    var picObj = (listArray[i] as PictureObj);
                    print(picObj.filePath);
                    picture_order.add(picObj.filePath);
                    //File file = File(picObj.filePath);
                    //String newFileName = "Page ${picObj.picIndex}.jpg";
                    //var path = file.path;
                    //var lastSeparator =
                    //    path.lastIndexOf(Platform.pathSeparator);
                    //var newPath =
                    //    path.substring(0, lastSeparator + 1) + newFileName;
                    //print("From ${picObj.filePath} to $newPath");
                    //file.rename(newPath);
                    //picObj.filePath = newPath;
                  }
                  jsonFileContent["picture_order"] = picture_order;
                  jsonFileContent["project_title"] = _controller.text;

                  // for (var i = 0; i < listArray.length; i++) {
                  //   if (i == listArray.length - 1) {
                  //     continue;
                  //   }
                  //   print("jiz");
                  //   var picObj = (listArray[i] as PictureObj);
                  //   File file = File(picObj.filePath);
                  //   String newFileName = "Page xxxxxx ${picObj.picIndex}.jpg";
                  //   var path = file.path;
                  //   var lastSeparator =
                  //       path.lastIndexOf(Platform.pathSeparator);
                  //   var newPath =
                  //       path.substring(0, lastSeparator + 1) + newFileName;
                  //   print("From ${picObj.filePath} to $newPath");
                  //   file.rename(newPath);
                  //   picObj.filePath = newPath;
                  // }

                  // for (var i = 0; i < listArray.length; i++) {
                  //   if (i == listArray.length - 1) {
                  //     continue;
                  //   }
                  //   print("jiz");
                  //   var picObj = (listArray[i] as PictureObj);
                  //   print(picObj.filePath);
                  //   File file = File(picObj.filePath);
                  //   String newFileName = "Page ${picObj.picIndex}.jpg";
                  //   var path = file.path;
                  //   var lastSeparator =
                  //       path.lastIndexOf(Platform.pathSeparator);
                  //   var newPath =
                  //       path.substring(0, lastSeparator + 1) + newFileName;
                  //   print("From ${picObj.filePath} to $newPath");
                  //   file.rename(newPath);
                  //   picObj.filePath = newPath;
                  // }

                  jsonFile.writeAsStringSync(json.encode(jsonFileContent));
                },
                style: TextButton.styleFrom(
                    primary: Colors.white,
                    backgroundColor: Colors.blue,
                    textStyle: TextStyle(fontSize: 15)),
              )),
              SizedBox(
                width: 10,
              ),
              Expanded(
                  child: TextButton(
                child: Text("Export"),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            ExportPage(arguments['projectFolderPath'])),
                  );
                  // Navigator.pushNamed(
                  //   context,
                  //   '/export_page',
                  //   arguments: {'folderPath': arguments["folderPath"]},
                  // );
                },
                style: TextButton.styleFrom(
                    primary: Colors.white,
                    backgroundColor: Colors.blue,
                    textStyle: TextStyle(fontSize: 15)),
              )),
              SizedBox(
                width: 10,
              )
            ],
          )
        ],
      ),
    );
  }
}
