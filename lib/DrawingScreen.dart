import 'dart:math';

import 'package:extended_image/extended_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'CustomPainter.dart';
import 'animatedFloatingActionButton.dart';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/rendering.dart';
import 'folderManager.dart';
import 'package:uuid/uuid.dart';

class DrawingScreen extends StatefulWidget {
  const DrawingScreen({Key? key}) : super(key: key);

  @override
  _DrawingScreenState createState() => _DrawingScreenState();
}

class _DrawingScreenState extends State<DrawingScreen> {
  GlobalKey globalKey = GlobalKey();
  List<TouchPoints> points = [];
  List<TouchPoints> totalpoints = [];
  double opacity = 1.0;
  StrokeCap strokeType = StrokeCap.round;
  double strokeWidth = 3.0;
  Color selectedColor = Colors.black;
  final TextEditingController _controller = TextEditingController(text: 'yeet');
  Offset offset = Offset.zero;
  Offset logOoffset = Offset.zero;
  bool widgetVisible = false;
  bool textwidgetVisible = false;
  void showandHideWidget() {
    setState(() {
      widgetVisible ^= true;
    });
  }

  void showandHideTextWidget() {
    setState(() {
      textwidgetVisible ^= true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final Map arguments = ModalRoute.of(context)!.settings.arguments as Map;
    //if string data
    print('This is imageString from previous page:');
    print(arguments['editedImagePath']);
    print('This is folderPath from previous page:');
    print(arguments['projectFolderPath']);
    File imageFile = File(arguments['editedImagePath']);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: Text('Draw Image', style: TextStyle(color: Colors.white)),
          actions: <Widget>[
            IconButton(
                tooltip: "Clear",
                icon: Icon(Icons.clear),
                onPressed: () {
                  setState(() {
                    points.clear();
                    widgetVisible = false;
                    textwidgetVisible = false;
                  });
                }),
            IconButton(
                tooltip: "Save",
                icon: Icon(Icons.check),
                onPressed: () async {
                  await _save(arguments['projectFolderPath'],
                      arguments['editedImagePath']);
                }),
            IconButton(
              tooltip: "Sticker",
              icon: Icon(Icons.photo_size_select_actual_rounded),
              onPressed: () {
                setState(
                  () {
                    showandHideWidget();
                  },
                );
              },
            ),
            IconButton(
              tooltip: "Text",
              icon: Icon(Icons.text_fields),
              onPressed: () {
                setState(
                  () {
                    showandHideTextWidget();
                  },
                );
              },
            ),
          ],
        ),
        body: RepaintBoundary(
          key: globalKey,
          child: Stack(
            children: <Widget>[
              Container(
                  child: Image.file(imageFile,
                      height: double.infinity, fit: BoxFit.contain)),
              GestureDetector(
                onPanUpdate: (details) {
                  setState(() {
                    RenderBox renderBox =
                        context.findRenderObject() as RenderBox;
                    points.add(TouchPoints(
                        points: renderBox.globalToLocal(details.globalPosition),
                        paint: Paint()
                          ..strokeCap = strokeType
                          ..isAntiAlias = true
                          ..color = selectedColor
                          ..strokeWidth = strokeWidth));
                  });
                },
                onPanEnd: (details) {
                  setState(() {
                    points.add(TouchPoints(
                        points: Offset.infinite,
                        paint: Paint()
                          ..strokeCap = strokeType
                          ..isAntiAlias = true
                          ..color = selectedColor
                          ..strokeWidth = strokeWidth));
                  });
                },
                child: CustomPaint(
                  size: Size.infinite,
                  painter: MyPainter(
                    pointsList: points,
                  ),
                ),
              ),
              Positioned(
                left: offset.dx,
                top: offset.dy,
                child: GestureDetector(
                  onPanUpdate: (details) {
                    setState(() {
                      offset = Offset(offset.dx + details.delta.dx,
                          offset.dy + details.delta.dy);
                    });
                  },
                  child: Visibility(
                    maintainSize: true,
                    maintainAnimation: true,
                    maintainState: true,
                    visible: textwidgetVisible,
                    child: SizedBox(
                      height: 100,
                      width: 200,
                      child: TextField(
                        textAlign: TextAlign.center,
                        controller: _controller,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                left: logOoffset.dx,
                top: logOoffset.dy,
                child: GestureDetector(
                  onPanUpdate: (details) {
                    setState(() {
                      logOoffset = Offset(logOoffset.dx + details.delta.dx,
                          logOoffset.dy + details.delta.dy);
                    });
                  },
                  child: Visibility(
                    maintainSize: true,
                    maintainAnimation: true,
                    maintainState: true,
                    visible: widgetVisible,
                    child: Container(
                      height: 100,
                      width: 100,
                      color: Colors.transparent,
                      margin: EdgeInsets.only(top: 20, bottom: 20),
                      child: Center(
                        child: (Image.asset('assets/images/NTUlogo.png')),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: Stack(
          children: [
            Positioned(
              bottom: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: AnimatedFloatingActionButton(
                  fabButtons: fabOptionColor(),
                  colorStartAnimation: Colors.blue,
                  colorEndAnimation: Colors.cyan,
                  animatedIconData: AnimatedIcons.menu_close,
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 70,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: FloatingActionButton(
                  tooltip: "Stroke",
                  onPressed: _pickStroke,
                  child: Icon(Icons.brush),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget colorMenuItem(Color color) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedColor = color;
        });
      },
      child: ClipOval(
        child: Container(
          padding: const EdgeInsets.only(bottom: 8.0),
          height: 36,
          width: 36,
          color: color,
        ),
      ),
    );
  }

  Future<void> _pickStroke() async {
    //Shows AlertDialog
    return showDialog<void>(
      context: context,
      //Dismiss alert dialog when set true
      barrierDismissible: true, // user must tap button!
      builder: (BuildContext context) {
        //Clips its child in a oval shape
        return ClipRRect(
          child: AlertDialog(
            title: Center(child: Text('Pick a Stroke size')),
            actionsAlignment: MainAxisAlignment.spaceEvenly,
            actions: <Widget>[
              //Resetting to default stroke value
              TextButton(
                child: Icon(
                  Icons.brush,
                  size: 24,
                ),
                onPressed: () {
                  strokeWidth = 3.0;
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Icon(
                  Icons.brush,
                  size: 40,
                ),
                onPressed: () {
                  strokeWidth = 8.0;
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Icon(
                  Icons.brush,
                  size: 60,
                ),
                onPressed: () {
                  strokeWidth = 12.0;
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _save(String folderPathString, String editedImageString) async {
    RenderRepaintBoundary boundary =
        globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    ui.Image image = await boundary.toImage();
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List result = byteData!.buffer.asUint8List();

    File(editedImageString).delete();
    var uuid = Uuid();
    final fileName = uuid.v1() + ".png";
    print("File name is $fileName");
    String drawImagePath = "$folderPathString$fileName";
    print(drawImagePath);
    File(drawImagePath).writeAsBytes(result);

    setState(() {
      Navigator.pushReplacementNamed(context, '/edit_page', arguments: {
        'projectFolderPath': folderPathString,
      });
    });
  }

  List<Widget> fabOptionColor() {
    return <Widget>[
      FloatingActionButton(
        backgroundColor: Colors.white,
        child: colorMenuItem(Colors.red),
        tooltip: 'Color',
        onPressed: () {
          setState(() {
            selectedColor = Colors.red;
          });
        },
      ),
      FloatingActionButton(
        backgroundColor: Colors.white,
        child: colorMenuItem(Colors.green),
        tooltip: 'Color',
        onPressed: () {
          setState(() {
            selectedColor = Colors.green;
          });
        },
      ),
      FloatingActionButton(
        backgroundColor: Colors.white,
        child: colorMenuItem(Colors.pink),
        tooltip: 'Color',
        onPressed: () {
          setState(() {
            selectedColor = Colors.pink;
          });
        },
      ),
      FloatingActionButton(
        backgroundColor: Colors.white,
        child: colorMenuItem(Colors.blue),
        tooltip: 'Color',
        onPressed: () {
          setState(() {
            selectedColor = Colors.blue;
          });
        },
      ),
      FloatingActionButton(
        backgroundColor: Colors.white,
        child: colorMenuItem(Colors.black),
        tooltip: 'Color',
        onPressed: () {
          setState(() {
            selectedColor = Colors.black;
          });
        },
      ),
    ];
  }
}
