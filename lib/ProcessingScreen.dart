import 'package:ee3080_dip049/edit_project.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:image_editor/image_editor.dart';
import 'package:extended_image/extended_image.dart';
import 'package:oktoast/oktoast.dart';

class ProcessingScreen extends StatefulWidget {
  const ProcessingScreen({Key? key}) : super(key: key);

  @override
  _ProcessingScreenState createState() => _ProcessingScreenState();
}

class _ProcessingScreenState extends State<ProcessingScreen> {
  final GlobalKey<ExtendedImageEditorState> editorKey = GlobalKey();

  double sat = 1;
  double bright = 0;
  double con = 1;

  ImageProvider provider = ExtendedExactAssetImageProvider(
    'imagePath',
    cacheRawData: true,
  );

  final defaultColorMatrix = const <double>[
    1,
    0,
    0,
    0,
    0,
    0,
    1,
    0,
    0,
    0,
    0,
    0,
    1,
    0,
    0,
    0,
    0,
    0,
    1,
    0
  ];
  List<double> calculateSaturationMatrix(double saturation) {
    final m = List<double>.from(defaultColorMatrix);
    final invSat = 1 - saturation;
    final R = 0.213 * invSat;
    final G = 0.715 * invSat;
    final B = 0.072 * invSat;

    m[0] = R + saturation;
    m[1] = G;
    m[2] = B;
    m[5] = R;
    m[6] = G + saturation;
    m[7] = B;
    m[10] = R;
    m[11] = G;
    m[12] = B + saturation;

    return m;
  }

  List<double> calculateContrastMatrix(double contrast) {
    final m = List<double>.from(defaultColorMatrix);
    m[0] = contrast;
    m[6] = contrast;
    m[12] = contrast;
    return m;
  }

  @override
  Widget build(BuildContext context) {
    final Map arguments = ModalRoute.of(context)!.settings.arguments as Map;
    //if string data
    print(arguments['imagePath']);
    provider = ExtendedFileImageProvider(File(arguments['imagePath']),
        cacheRawData: true);

    return MaterialApp(
        home: Scaffold(
      appBar: AppBar(
        title: Text('Edit Image', style: TextStyle(color: Colors.white)),
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.settings_backup_restore),
              onPressed: () {
                setState(() {
                  sat = 1;
                  bright = 0;
                  con = 1;
                });
              }),
          IconButton(
              icon: Icon(Icons.check),
              onPressed: () async {
                await crop();
              }),
        ],
      ),
      body: Container(
          height: double.infinity,
          child: Column(
            children: <Widget>[
              AspectRatio(
                aspectRatio: 1,
                child: buildImage(),
              ),
              Expanded(
                child: SliderTheme(
                  data: const SliderThemeData(
                    showValueIndicator: ShowValueIndicator.never,
                  ),
                  child: Container(
                    color: Colors.white,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Spacer(flex: 3),
                        _buildSat(),
                        Spacer(flex: 1),
                        _buildBrightness(),
                        Spacer(flex: 1),
                        _buildCon(),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          )),
      bottomNavigationBar: _buildFunctions(),
    ));
  }

  Widget buildImage() {
    return ColorFiltered(
        colorFilter: ColorFilter.matrix(calculateContrastMatrix(con)),
        child: ColorFiltered(
            colorFilter: ColorFilter.matrix(calculateSaturationMatrix(sat)),
            child: ExtendedImage(
                color: bright > 0
                    ? Colors.white.withOpacity(bright)
                    : Colors.black.withOpacity(-bright),
                colorBlendMode:
                    bright > 0 ? BlendMode.lighten : BlendMode.darken,
                image: provider,
                height: MediaQuery.of(context).size.width,
                width: MediaQuery.of(context).size.width,
                extendedImageEditorKey: editorKey,
                mode: ExtendedImageMode.editor,
                fit: BoxFit.contain,
                initEditorConfigHandler: (_) => EditorConfig(
                      maxScale: 8.0,
                      cropRectPadding: const EdgeInsets.all(20.0),
                      hitTestSize: 20.0,
                    ))));
  }

  Widget _buildFunctions() {
    return BottomNavigationBar(
      items: <BottomNavigationBarItem>[
        BottomNavigationBarItem(
          icon: Icon(Icons.flip),
          label: 'Flip',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.rotate_left),
          label: 'Rotate left',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.rotate_right),
          label: 'Rotate right',
        ),
      ],
      onTap: (int index) {
        switch (index) {
          case 0:
            flip();
            break;
          case 1:
            rotate(false);
            break;
          case 2:
            rotate(true);
            break;
        }
      },
      currentIndex: 0,
      selectedItemColor: Theme.of(context).primaryColor,
      unselectedItemColor: Theme.of(context).primaryColor,
    );
  }

  Future<void> crop([bool test = false]) async {
    final ExtendedImageEditorState? state = editorKey.currentState;
    if (state == null) {
      return;
    }
    final Rect? rect = state.getCropRect();
    if (rect == null) {
      showToast('The crop rect is null.');
      return;
    }
    final EditActionDetails action = state.editAction!;
    final double radian = action.rotateAngle;

    final bool flipHorizontal = action.flipY;
    final bool flipVertical = action.flipX;
    final Uint8List? img = state.rawImageData;

    if (img == null) {
      showToast('The img is null.');
      return;
    }

    final ImageEditorOption option = ImageEditorOption();

    option.addOption(ClipOption.fromRect(rect));
    option.addOption(
        FlipOption(horizontal: flipHorizontal, vertical: flipVertical));
    if (action.hasRotateAngle) {
      option.addOption(RotateOption(radian.toInt()));
    }

    option.addOption(ColorOption.saturation(sat));
    option.addOption(ColorOption.brightness(bright + 1));
    option.addOption(ColorOption.contrast(con));

    option.outputFormat = const OutputFormat.png(88);

    print(const JsonEncoder.withIndent('  ').convert(option.toJson()));

    final DateTime start = DateTime.now();
    final Uint8List? result = await ImageEditor.editImage(
      image: img,
      imageEditorOption: option,
    );

    print('result.length = ${result?.length}');

    final Duration diff = DateTime.now().difference(start);

    print('image_editor time : $diff');
    showToast('handle duration: $diff',
        duration: const Duration(seconds: 5), dismissOtherToast: true);

    if (result == null) return;
    Future.delayed(Duration(seconds: 0)).then(
      (value) => Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => EditProjectPage(title: 'Edit Page'
//                  arguments: [image],
                )),
      ),
    );
  }

  void flip() {
    editorKey.currentState?.flip();
  }

  void rotate(bool right) {
    editorKey.currentState?.rotate(right: right);
  }

  Widget _buildSat() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.03,
        ),
        Column(
          children: <Widget>[
            Icon(
              Icons.brush,
              color: Theme.of(context).colorScheme.secondary,
            ),
            Text(
              "Saturation",
              style: TextStyle(color: Theme.of(context).colorScheme.secondary),
            )
          ],
        ),
        Container(
          width: MediaQuery.of(context).size.width * 0.6,
          child: Slider(
            label: 'sat : ${sat.toStringAsFixed(2)}',
            onChanged: (double value) {
              setState(() {
                sat = value;
              });
            },
            divisions: 50,
            value: sat,
            min: 0,
            max: 2,
          ),
        ),
        Padding(
          padding:
              EdgeInsets.only(right: MediaQuery.of(context).size.width * 0.08),
          child: Text(sat.toStringAsFixed(2)),
        ),
      ],
    );
  }

  Widget _buildBrightness() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.03,
        ),
        Column(
          children: <Widget>[
            Icon(
              Icons.brightness_4,
              color: Theme.of(context).colorScheme.secondary,
            ),
            Text(
              "Brightness",
              style: TextStyle(color: Theme.of(context).colorScheme.secondary),
            )
          ],
        ),
        Container(
          width: MediaQuery.of(context).size.width * 0.6,
          child: Slider(
            label: '${bright.toStringAsFixed(2)}',
            onChanged: (double value) {
              setState(() {
                bright = value;
              });
            },
            divisions: 50,
            value: bright,
            min: -1,
            max: 1,
          ),
        ),
        Padding(
          padding:
              EdgeInsets.only(right: MediaQuery.of(context).size.width * 0.08),
          child: Text(bright.toStringAsFixed(2)),
        ),
      ],
    );
  }

  Widget _buildCon() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        SizedBox(
          width: MediaQuery.of(context).size.width * 0.03,
        ),
        Column(
          children: <Widget>[
            Icon(
              Icons.color_lens,
              color: Theme.of(context).colorScheme.secondary,
            ),
            Text(
              "Contrast",
              style: TextStyle(color: Theme.of(context).colorScheme.secondary),
            )
          ],
        ),
        Container(
          width: MediaQuery.of(context).size.width * 0.6,
          child: Slider(
            label: 'con : ${con.toStringAsFixed(2)}',
            onChanged: (double value) {
              setState(() {
                con = value;
              });
            },
            divisions: 50,
            value: con,
            min: 0,
            max: 4,
          ),
        ),
        Padding(
          padding:
              EdgeInsets.only(right: MediaQuery.of(context).size.width * 0.08),
          child: Text(con.toStringAsFixed(2)),
        ),
      ],
    );
  }
}
