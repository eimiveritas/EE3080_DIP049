import 'dart:io';
import 'package:ee3080_dip049/folderManager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share/share.dart';

import 'export_page_pdf_preview.dart';

class ExportPage extends StatefulWidget {
  @override
  _ExportPageState createState() => _ExportPageState();
}

class _ExportPageState extends State<ExportPage> {
  final _titleController = TextEditingController(text: "Untitled File");

  FolderManager folderManager = new FolderManager();

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

  Future<String> createPdfFromImages(String folderPath) async {
    List<String> listOfImages = await populate(folderPath);

    final pdf = pw.Document();
    for (String imgPath in listOfImages) {
      var image = pw.MemoryImage(File(imgPath).readAsBytesSync());
      pdf.addPage(pw.Page(build: (pw.Context context) {
        return pw.FullPage(
          child: pw.Image(image),
          ignoreMargins: true,
        );
      }));
    }
    final file = File(
        "${await folderManager.tempFolderPath}${_titleController.text}.pdf");
    await file.writeAsBytes(await pdf.save());

    print("Inside createPDF method: " + file.path);
    return file.path;
  }

  Future<String> pathOfPDFCreated() async {
    final file = File(
        "${await folderManager.tempFolderPath}${_titleController.text}.pdf");
    return file.path;
  }

  @override
  Widget build(BuildContext context) {
    final Map arguments = ModalRoute.of(context)!.settings.arguments as Map;

    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Container(
            color: Colors.blue,
            child: TextField(
              textAlign: TextAlign.center,
              decoration: InputDecoration(
                labelText: "Enter the title of file here",
              ),
              controller: _titleController,
            ),
          ),
          Container(
            width: 200,
            height: 200,
            child: IconButton(
              onPressed: () {
                print("Icon pressed");

                // String pdfPath = '';
                createPdfFromImages(arguments['folderPath']).then((pdfPath) {
                  print("onPressed, in then(), pdfPath: " + pdfPath);

                  // be able to pass arguments which can then be used outside build() method;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            PdfPreviewPage(_titleController.text, pdfPath)),
                  );
                });
                // print("onPressed, pdfPath: " + pdfPath);

                // Navigator.push(
                //   context,
                //   MaterialPageRoute(
                //       builder: (context) => PdfPreviewPage(pdfPath)),
                // );
              },
              icon: Image.network(
                "https://learnenglishteens.britishcouncil.org/sites/teens/files/b2w_a_for_and_against_essay_0.jpg",
              ),
            ),
          ),
          Container(
            width: 140,
            height: 40,
            child: ElevatedButton(
              onPressed: () {
                print("SHARE button pressed. ready to share the pdf file");
                pathOfPDFCreated().then((pdfPAth) {
                  Share.shareFiles([pdfPAth]);
                });
              },
              child: Text("SHARE"),
            ),
          ),
          Container(
            width: 150,
            height: 60,
            child: ElevatedButton(
                onPressed: () {
                  print(_titleController.text);
                },
                child: Text(
                  "Export",
                  style: TextStyle(fontSize: 18),
                )),
          )
        ],
      ),
    );
  }
}
