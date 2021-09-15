import 'dart:io';
import 'package:ee3080_dip049/folderManager.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share/share.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart' as syncpdf;
import 'package:path/path.dart' as Path;

import 'export_page_pdf_preview.dart';

class ExportPage extends StatefulWidget {
  final String _folderPath;
  ExportPage(this._folderPath);

  @override
  _ExportPageState createState() => _ExportPageState(this._folderPath);
}

class _ExportPageState extends State<ExportPage> {
  final String _folderPath;
  _ExportPageState(this._folderPath);

  FolderManager folderManager = new FolderManager();

  final _titleController = TextEditingController(text: "Untitled");
  final _passwordController = TextEditingController(text: "");
  late String pdfFilePath;

  @override
  void initState() {
    super.initState();
    createPdf();
  }

  // create the pdf file and save; file path referenced by the pdfFilePath field;
  createPdf() async {
    print("Inside createSavePdfFile()");
    this.pdfFilePath = await createPdfFromImages(_folderPath);
    print("Finish createSavePdfFile(), " + pdfFilePath);
  }

  // rename the pdf file (path & title) upon inputing the new title
  renamePdf(String newTitle) async {
    // var lastSeparator = this.pdfFilePath.lastIndexOf(Platform.pathSeparator);
    // var newPath =
    //     this.pdfFilePath.substring(0, lastSeparator + 1) + newTitle + ".pdf";
    var newPath =
        Path.join(await folderManager.tempFolderPath, "$newTitle.pdf");
    this.pdfFilePath = File(this.pdfFilePath).renameSync(newPath).path;
    print("Renamed pdf path: " + this.pdfFilePath);
  }

  // share the file; if password is set, share the encrypted one
  sharePdf() async {
    String pdfToShare = this.pdfFilePath;
    if (_passwordController.text != "") {
      pdfToShare =
          await encryptePdf(this.pdfFilePath, _passwordController.text);
      var newPath = Path.join(await folderManager.tempFolderPath,
          "Encrypted-${this._titleController.text}.pdf");
      pdfToShare = File(pdfToShare).renameSync(newPath).path;
    }
    print("file to share: " + pdfToShare);
    Share.shareFiles([pdfToShare]);
  }

  // use the _passwordController.text to set the password for pdf
  // called when sharing;
  Future<String> encryptePdf(String pdfToEncryptPath, String password) async {
    final syncpdf.PdfDocument document = syncpdf.PdfDocument(
        inputBytes: File(pdfToEncryptPath).readAsBytesSync());

    final syncpdf.PdfSecurity security = document.security;

    security.userPassword = password;
    // security.ownerPassword = 'ownerpassword@123';

    security.algorithm = syncpdf.PdfEncryptionAlgorithm.aesx256Bit;

    File encryptedFile = await File(
            Path.join(await folderManager.tempFolderPath, "Encrypted.pdf"))
        .writeAsBytes(document.save());
    document.dispose();
    return encryptedFile.path;
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

    final file =
        File(Path.join(await folderManager.tempFolderPath, "Untitled.pdf"));
    await file.writeAsBytes(await pdf.save());

    print("Inside createPdfFromImages method: " + file.path);
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
              decoration: InputDecoration(
                labelText: "Enter the title of file here",
              ),
              onSubmitted: (_) {
                renamePdf(_titleController.text);
              },
              // onEditingComplete: () {
              //   renamePdf(_titleController.text);
              // },
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
            color: Colors.blue,
            child: TextField(
              textAlign: TextAlign.start,
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: "Set Password for PDF?",
              ),
            ),
          ),
          Container(
            width: 150,
            height: 60,
            child: ElevatedButton(
              onPressed: () {
                print("READY TO SHARE");
                sharePdf();
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
                  print(_passwordController.text);
                },
                child: Text(
                  "PRINT",
                  style: TextStyle(fontSize: 18),
                )),
          )
        ],
      ),
    );
  }
}
