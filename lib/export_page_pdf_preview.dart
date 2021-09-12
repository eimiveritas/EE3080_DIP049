import 'dart:io';

import 'package:flutter/material.dart';
import 'package:advance_pdf_viewer/advance_pdf_viewer.dart';

class PdfPreviewPage extends StatefulWidget {
  @override
  _PdfPreviewPageState createState() => _PdfPreviewPageState();
}

class _PdfPreviewPageState extends State<PdfPreviewPage> {
  bool _isLoading = true;
  late PDFDocument document;

  List<String> pathsOfImages = [];

  String testMessage = "Original";

  @override
  void initState() {
    super.initState();
    loadDocument();
  }

  loadDocument() async {
    // document shoud be replaced by the pdf file we created in the future.
    document = await PDFDocument.fromURL(
        "http://conorlastowka.com/book/CitationNeededBook-Sample.pdf");
    setState(() {
      _isLoading = false;
    });
  }

  // to list all images under a file
  Future<List<String>> populate(folderPath) async {
    List<String> listOfDir = [];
    var systemTempDir = Directory(folderPath);
    await for (var entity
        in systemTempDir.list(recursive: false, followLinks: false)) {
      print(entity.path);
      listOfDir.add(entity.path);
    }
    return listOfDir;
  }

  @override
  Widget build(BuildContext context) {
    final Map arguments = ModalRoute.of(context)!.settings.arguments as Map;

    print("Inside build() - 1");
    populate(arguments['folderPath']).then((value) {
      for (String path in value) {
        print("Looping - inside build()");
        print(path);

        pathsOfImages.add(path);
      }
    });
    print("Inside build() - 2");

    return Scaffold(
      appBar: AppBar(
        // title of the file will be replaced by the title set
        title: const Text("PDF PREVIEW: TITLE HERE"),
      ),
      // body to view the pdf file
      // body: Center(
      //     child: _isLoading
      //         ? Center(child: CircularProgressIndicator())
      //         : PDFViewer(
      //             document: document,
      //             zoomSteps: 1,
      //           )),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              print("Set Button pressed");
              testMessage = "Set";
              populate(arguments['folderPath']).then((value) {
                for (String path in value) {
                  print("Looping");
                  print(path);
                  setState(() {
                    pathsOfImages.add(path);
                  });
                }
              });
            },
            child: Text('Set'),
          ),
          ElevatedButton(
            onPressed: () {
              print("print button pressed");
              print(testMessage);
              print("length = ${pathsOfImages.length}");
              for (var path in pathsOfImages) {
                print(">>>PATHS IN pathOfImages: " + path);
              }
            },
            child: Text("print"),
          ),
        ],
      ),
    );
  }
}
