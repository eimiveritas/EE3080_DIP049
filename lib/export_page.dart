import 'dart:io';
import 'package:ee3080_dip049/folderManager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share/share.dart';

import 'export_page_pdf_preview.dart';

class ExportPage extends StatefulWidget {
  String _folderPath;
  ExportPage(this._folderPath);

  @override
  _ExportPageState createState() => _ExportPageState(this._folderPath);
}

class _ExportPageState extends State<ExportPage> {
  String _folderPath;
  _ExportPageState(this._folderPath);

  FolderManager folderManager = new FolderManager();

  final _titleController = TextEditingController(text: "Untitled File");
  late String pdfFilePath;
  // CARE: the postfix (name of the pdf) is always Untitled File.pdf;
  // CARE: path not changed when a new title is entered;
  // CARE: when viewing pdf, always view the UntitileD File.pdf;
  // CARE: when sharing, copy to pdf file with current title. share the copied one;

  @override
  void initState() {
    super.initState();
    createSavePdfFile();
  }

  // create the pdf file and save; also referenced by the pdfFilePath field;
  createSavePdfFile() async {
    print("Inside createSavePdfFile()");
    pdfFilePath = await createPdfFromImages(_folderPath);
    print("Finish createSavePdfFile(), " + pdfFilePath);
  }

  // rename and share the file, called when sharing;
  shareRenamedPdf() async {
    String newPath =
        "${await folderManager.tempFolderPath}${_titleController.text}.pdf";
    await File(pdfFilePath).copy(newPath);
    print("file to share: " + newPath);
    Share.shareFiles([newPath]);
  }

  // return a list containing all images under the project folder;
  Future<List<String>> getListOfImages(folderPath) async {
    List<String> listOfDir = [];
    var systemTempDir = Directory(folderPath);
    await for (var entity
        in systemTempDir.list(recursive: false, followLinks: false)) {
      print("Images: " + entity.path);
      listOfDir.add(entity.path);
    }
    return listOfDir;
  }

  // create the pdf file of all images under the project folder, save the pdf file under tempFolder, save a reference as a field;
  Future<String> createPdfFromImages(String folderPath) async {
    List<String> listOfImages = await getListOfImages(folderPath);

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

  @override
  Widget build(BuildContext context) {
    // final Map arguments = ModalRoute.of(context)!.settings.arguments as Map;

    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Container(
            color: Colors.blue,
            child: TextField(
              textAlign: TextAlign.center,
              controller: _titleController,
              // decoration: InputDecoration(
              //   labelText: "Enter the title of file here",
              // ),
            ),
          ),
          Container(
            width: 200,
            height: 200,
            child: IconButton(
              onPressed: () {
                print("Image Icon pressed");
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          PdfPreviewPage(_titleController.text, pdfFilePath)),
                );
              },
              icon: Image.network(
                "https://learnenglishteens.britishcouncil.org/sites/teens/files/b2w_a_for_and_against_essay_0.jpg",
              ),
            ),
          ),
          Container(
            width: 150,
            height: 60,
            child: ElevatedButton(
              onPressed: () {
                print("READY TO SHARE");
                shareRenamedPdf();
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
                  print(pdfFilePath);
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
