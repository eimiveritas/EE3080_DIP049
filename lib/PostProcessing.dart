import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:ee3080_dip049/folderManager.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
//import 'package:image_editor/image_editor.dart';

class PostProcessing extends StatefulWidget {
  @override
  PostProcessingState createState() => PostProcessingState();
}

class PostProcessingState extends State<PostProcessing> {
  // variable to control rotate function
  double currentAngle = 0;
  //Temporary Camera Function for the back button.
  Future getImage() async {
    final image = await ImagePicker().pickImage(source: ImageSource.camera);
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

  //rotate function
  void angleButton() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      currentAngle += pi / 2;
    });
  }

  final FolderManager folderManager = new FolderManager();

  @override
  Widget build(BuildContext context) {
    final Map arguments = ModalRoute.of(context)!.settings.arguments as Map;
    //if string data
    print(arguments['imagePath']);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Stack(
        children: <Widget>[
          Transform.rotate(
            angle: currentAngle,
            child: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  fit: (BoxFit.cover),
                  image: FileImage(
                    File(arguments['imagePath']),
                  ),
                ),
              ),
            ),
          ),
          Scaffold(
            backgroundColor: Colors.transparent,
            body: Container(
              child: Column(
                textDirection: TextDirection.ltr,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        IconButton(
                          iconSize: 48,
                          color: Colors.grey,
                          onPressed: getImage,
                          icon: Icon(Icons.close_outlined),
                        ),
                        IconButton(
                          iconSize: 48,
                          color: Colors.grey,
                          onPressed: () {
                            var imagePathString = "";

                            if (arguments.containsKey('projectFolderPath')) {
                              imagePathString =
                                  "${arguments['projectFolderPath']}/${arguments['imagePath'].split('/').last}";

                              print(imagePathString);

                              File(arguments['imagePath'])
                                  .copy(imagePathString);

                              print(imagePathString);

                              Navigator.pushNamed(context, '/edit_page',
                                  arguments: {
                                    'projectFolderPath':
                                        arguments['projectFolderPath']
                                  });
                            } else {
                              folderManager.createFolderWithCurrentDatetimePath
                                  .then((value) {
                                print(value);
                                imagePathString =
                                    "${value}${arguments['imagePath'].split('/').last}";

                                File(arguments['imagePath'])
                                    .copy(imagePathString);

                                print(imagePathString);

                                Navigator.pushNamed(context, '/edit_page',
                                    arguments: {'projectFolderPath': value});
                              });
                            }
                          },
                          icon: Icon(Icons.done_outlined),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        IconButton(
                          iconSize: 48,
                          color: Colors.grey,
                          onPressed: () {
                            print('123');
                          },
                          icon: Icon(Icons.edit_outlined),
                        ),
                        IconButton(
                          iconSize: 48,
                          color: Colors.grey,
                          onPressed: () {
                            print('123');
                          },
                          icon: Icon(Icons.article_outlined),
                        ),
                        IconButton(
                          iconSize: 48,
                          color: Colors.grey,
                          onPressed: () {
                            print('123');
                          },
                          icon: Icon(Icons.exposure_outlined),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              IconButton(
                                iconSize: 48,
                                color: Colors.grey,
                                onPressed: () {
                                  print('123');
                                },
                                icon: Icon(Icons.redo_outlined),
                              ),
                              IconButton(
                                iconSize: 48,
                                color: Colors.grey,
                                onPressed: () {
                                  print('123');
                                },
                                icon: Icon(Icons.undo_outlined),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              IconButton(
                                iconSize: 48,
                                color: Colors.grey,
                                onPressed: angleButton,
                                icon:
                                    Icon(Icons.rotate_90_degrees_ccw_outlined),
                              ),
                              IconButton(
                                iconSize: 48,
                                color: Colors.grey,
                                onPressed: angleButton,
                                icon: Icon(Icons.rotate_90_degrees_ccw),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// class ImageEditor extends CustomPainter {
//   ImageEditor({
//     required image,
//   });

//   ui.Image? image;

//   List<Offset> points = List();

//   final Paint painter = new Paint()
//     ..color = Color.blue[400]
//     ..style = PaintingStyle.fill;

//   void update(Offset offset) {
//     points.add(offset);
//   }

//   @override
//   void paint(Canvas canvas, Size size) {
//     canvas.drawImage(image!, Offset(0.0, 0.0), Paint());
//     for (Offset offset in points) {
//       canvas.drawCircle(offset, 10, painter);
//     }
//   }

//   @override
//   bool shouldRepaint(CustomPainter oldDelegate) {
//     return true;
//   }
// }
