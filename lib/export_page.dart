import 'dart:io';

import 'package:ee3080_dip049/folderManager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class ExportPage extends StatelessWidget {
  final _titleController = TextEditingController();

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
        return pw.Center(
          child: pw.Image(image),
        ); // Center
      }));
    }
    final file = File("${await folderManager.tempFolderPath}/currentPDF.pdf");
    await file.writeAsBytes(await pdf.save());

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
                Future<String> pdfPath =
                    createPdfFromImages(arguments['folderPath']);
                Navigator.pushNamed(
                  context,
                  '/pdf_view',
                  arguments: {
                    'folderPath': arguments['folderPath'],
                    'pdfFilePath': pdfPath
                  },
                );
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
              onPressed: () {},
              child: Text("Choose Location"),
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
