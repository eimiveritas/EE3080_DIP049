import 'dart:convert';
import 'dart:io';
import 'package:ee3080_dip049/folderManager.dart';
import 'package:firebase_ml_vision/firebase_ml_vision.dart' as ml_vision;
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart' as oldpdf;
import 'package:pdf/widgets.dart' as pw;
import 'package:share/share.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:path/path.dart' as Path;
import 'package:rounded_loading_button/rounded_loading_button.dart';

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

  final RoundedLoadingButtonController _encryptButtonController =
      RoundedLoadingButtonController();
  final RoundedLoadingButtonController _titleButtonController =
      RoundedLoadingButtonController();

  final _titleController = TextEditingController(text: "Untitled");
  final _passwordController = TextEditingController(text: "");

  String _pdfFilePath = "";
  String _pdfFilePathEncrypted = "";

  String _previewImgPath = "";
  bool _isImgLoading = true;

  String _textMultiImages = "";
  final RoundedLoadingButtonController _extractTextController =
      RoundedLoadingButtonController();

  final RoundedLoadingButtonController _shareController =
      RoundedLoadingButtonController();

  @override
  void initState() {
    super.initState();
    // print("inside initState: " + _folderPath);
    setPreviewImg();
    setTitle();
    createPdf();
  }

  // share as txt file or share as plain text
  shareText(bool inFile) async {
    Directory dir = Directory(_folderPath);

    File txtFile = File(Path.join(dir.path, "textExtracted.txt"));
    await txtFile.writeAsString(_textMultiImages);
    // print(">>>>>>>>>>>Txt file to share: " + txtFile.path);

    if (inFile) {
      Share.shareFiles([txtFile.path]);
    } else {
      Share.share(_textMultiImages);
    }
  }

  // extract texts from multiple images forming the pdf file.
  extractTextFromImages() async {
    // assume alr extracted since we have only one pdf file to share;
    if (_textMultiImages != "") {
      return;
    }
    Directory imageDir = Directory(_folderPath);
    await for (var eneity
        in imageDir.list(recursive: false, followLinks: false)) {
      var imagePath = eneity.path;
      // print("extrating image: " + imagePath);

      if (imagePath.endsWith(".jpg") ||
          imagePath.endsWith(".png") ||
          imagePath.endsWith(".jpeg")) {
        ml_vision.FirebaseVisionImage visionImage =
            ml_vision.FirebaseVisionImage.fromFile(File(imagePath));
        ml_vision.TextRecognizer textRecognizer =
            ml_vision.FirebaseVision.instance.textRecognizer();
        ml_vision.VisionText visionText =
            await textRecognizer.processImage(visionImage);

        for (ml_vision.TextBlock block in visionText.blocks) {
          for (ml_vision.TextLine line in block.lines) {
            for (ml_vision.TextElement word in line.elements) {
              _textMultiImages = _textMultiImages + word.text + ' ';
            }
            _textMultiImages = _textMultiImages + '\n';
          }
        }
        _textMultiImages = _textMultiImages + "\n\n";

        textRecognizer.close();
      }
    }
  }

  // show dialog window, relative funtion already in onPressed() body. deprecated with forgottion reason.
  // after modification, can replace the function in onPressed() body for the purpose of modularization
  void _showExtractedText(String text) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Extracted Page'),
            content: Scrollbar(
              child: SingleChildScrollView(
                child: Text(text),
                physics: BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics()),
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () async {
                  final File file = File(Path.join(
                      await folderManager.tempFolderPath,
                      "/extracted-text.txt"));
                  file.writeAsString(text);
                  Share.shareFiles([file.path]);
                },
                child: Text('Save'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Close'),
              ),
            ],
          );
        });
  }

  setTitle() async {
    File jsonFile = File(Path.join(_folderPath, 'config.json'));
    if (jsonFile.existsSync()) {
      Map<String, dynamic> jsonFileContent =
          json.decode(jsonFile.readAsStringSync());
      if (jsonFileContent.containsKey("project_title")) {
        _titleController.text = jsonFileContent["project_title"];
      }
    }
  }

  // use the first page of pdf file to be the preview image
  setPreviewImg() async {
    File jsonFile = File(Path.join(_folderPath, 'config.json'));
    Map<String, dynamic> jsonFileContent =
        json.decode(jsonFile.readAsStringSync());
    if (jsonFileContent.containsKey("picture_order")) {
      List<String> imgs = jsonFileContent["picture_order"].cast<String>();
      _previewImgPath = imgs[0];
      // print("setPreviewImg1: " + _previewImgPath);
    } else {
      var projectDir = Directory(_folderPath);
      await for (var entity
          in projectDir.list(recursive: false, followLinks: false)) {
        _previewImgPath = entity.path;
        if (_previewImgPath.endsWith(".jpg") ||
            _previewImgPath.endsWith(".png") ||
            _previewImgPath.endsWith(".jpeg")) {
          // print("setPreviewImg2: " + _previewImgPath);
          break;
        }
      }
    }
    setState(() {
      _isImgLoading = false;
    });
    // print("Preview Image path: " + _previewImgPath);
  }

  // create the pdf file and save; file path referenced by the pdfFilePath field;
  createPdf() async {
    // print("Inside createSavePdfFile()");
    this._pdfFilePath = await createPdfFromImages();
    // print("Finish createSavePdfFile(), " + _pdfFilePath);
  }

  // rename the pdf file (path & title) upon inputing the new title
  renamePdf(String newTitle) async {
    // var lastSeparator = this.pdfFilePath.lastIndexOf(Platform.pathSeparator);
    // var newPath =
    //     this.pdfFilePath.substring(0, lastSeparator + 1) + newTitle + ".pdf";
    var newPath =
        Path.join(await folderManager.tempFolderPath, "$newTitle.pdf");
    this._pdfFilePath = File(this._pdfFilePath).renameSync(newPath).path;

    _titleButtonController.success();
    // print("Renamed pdf path: " + this._pdfFilePath);
  }

  // share the file; if password is set, share the encrypted one
  sharePdf() async {
    String pdfToShare = this._pdfFilePath;
    if (this._pdfFilePathEncrypted != "") {
      pdfToShare = this._pdfFilePathEncrypted;
    }

    // print("file to share: " + pdfToShare);
    Share.shareFiles([pdfToShare]);
    _shareController.reset();
  }

  // use the _passwordController.text to set the password for pdf
  // called when sharing;
  encryptPdf(String pdfToEncryptPath, String password) async {
    if (password == "") {
      this._pdfFilePathEncrypted = "";
      _encryptButtonController.success(); // terminate if empty password is set;
      return;
    }

    Map map = Map();
    map["pdfToEncryptPath"] = pdfToEncryptPath;
    map["password"] = password;
    _pdfFilePathEncrypted = await compute(
        encryptPdfHelper, map); // another thread for dealing with encrypt
    _encryptButtonController.success();
  }

  // create the pdf file, save the pdf file under tempFolder, save a reference as a field;
  createPdfFromImages() async {
    List<String> listOfImages = await getListOfImages();

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

    _titleController.text = cleanUpPDFTitle(_titleController.text);
    final file = File(Path.join(
        await folderManager.tempFolderPath, _titleController.text + ".pdf"));
    await file.writeAsBytes(await pdf.save());

    // print("Inside createPdfFromImages method: " + file.path);
    return file.path;
  }

  //clean up the name of pdf file, replace special chars with _ and limit length
  String cleanUpPDFTitle(String originTitle) {
    String newTitle = originTitle.replaceAll(RegExp(r'[^A-Za-z0-9-_ ]'), '_');
    if (newTitle.length > 255) {
      newTitle = newTitle.substring(0, 255);
    }
    return newTitle;
  }

  // using json file;
  Future<List<String>> getListOfImages() async {
    File jsonFile = File(Path.join(_folderPath, 'config.json'));
    // print("json file: " + jsonFile.path);
    if (jsonFile.existsSync()) {
      // print("json file exists. ");
      Map<String, dynamic> jsonFileContent =
          json.decode(jsonFile.readAsStringSync());
      if (jsonFileContent.containsKey("picture_order")) {
        // print("picture_order exists");
        return jsonFileContent["picture_order"].cast<String>();
      }
    }
    return getListOfImagesWithoutJson();
  }

  // return a list containing all images under the project folder;
  Future<List<String>> getListOfImagesWithoutJson() async {
    // print("Inside getListOfImagesWithoutJson");
    List<String> listOfDir = [];
    var systemTempDir = Directory(_folderPath);
    await for (var entity
        in systemTempDir.list(recursive: false, followLinks: false)) {
      var path = entity.path;
      if (path.endsWith(".jpg") ||
          path.endsWith(".png") ||
          path.endsWith(".jpeg")) {
        // print("Images: " + path);
        listOfDir.add(path);
      }
    }
    return listOfDir;
  }

  @override
  Widget build(BuildContext context) {
    // final Map arguments = ModalRoute.of(context)!.settings.arguments as Map;
    // _titleController.text = Path.basename(_folderPath);

    return Scaffold(
      appBar: AppBar(
        title: Text("Exporting Page"),
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(
              height: 40,
            ),
            SizedBox(
              height: 200,
              width: 260,
              child: IconButton(
                padding: const EdgeInsets.all(0),
                onPressed: () {
                  // print("Image Icon pressed");
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => PdfPreviewPage(
                            _titleController.text, _pdfFilePath)),
                  );
                },
                icon: _isImgLoading
                    ? Center(child: CircularProgressIndicator())
                    : Image.file(File(_previewImgPath)),
                // icon: Image.network(
                //   "https://learnenglishteens.britishcouncil.org/sites/teens/files/b2w_a_for_and_against_essay_0.jpg",
                // ),
              ),
            ),
            SizedBox(
              height: 30,
            ),
            Card(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: TextField(
                      textAlign: TextAlign.start,
                      decoration: InputDecoration(
                        labelText: "Set Title",
                      ),
                      controller: _titleController,
                      onSubmitted: (_) {
                        _titleButtonController.start();
                        _titleController.text =
                            cleanUpPDFTitle(_titleController.text);
                        renamePdf(_titleController.text);
                      },
                      onChanged: (_) {
                        _titleButtonController.reset();
                      },
                      // onEditingComplete: () {
                      //   renamePdf(_titleController.text);
                      // },
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(8.0),
                    height: 50,
                    width: 50,
                    child: RoundedLoadingButton(
                      successIcon: Icons.check,
                      failedIcon: Icons.cottage,
                      child: Icon(Icons.edit),
                      controller: _titleButtonController,
                      onPressed: () {
                        _titleController.text =
                            cleanUpPDFTitle(_titleController.text);
                        renamePdf(_titleController.text);
                      },
                    ),
                  ),
                ],
              ),
            ),
            Card(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: TextField(
                      textAlign: TextAlign.start,
                      decoration: InputDecoration(labelText: "Set Password"),
                      controller: _passwordController,
                      onChanged: (_) {
                        _encryptButtonController.reset();
                      },
                      onSubmitted: (_) {
                        _encryptButtonController.start();
                        encryptPdf(this._pdfFilePath, _passwordController.text);
                      },
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(8.0),
                    height: 50,
                    width: 50,
                    child: RoundedLoadingButton(
                      successIcon: Icons.check,
                      failedIcon: Icons.cottage,
                      child: Icon(Icons.edit),
                      controller: _encryptButtonController,
                      onPressed: () {
                        encryptPdf(this._pdfFilePath, _passwordController.text);
                        // encryptePdf(this.pdfFilePath, _passwordController.text);
                      },
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 30),
            RoundedLoadingButton(
              controller: _shareController,
              onPressed: () {
                // print("READY TO SHARE");
                sharePdf();
                // Navigator.popUntil(
                //     context, (Route<dynamic> predicate) => predicate.isFirst);
              },
              child: Text("Share"),
            ),
            const SizedBox(height: 10.0),
            RoundedLoadingButton(
              controller: _extractTextController,
              onPressed: () async {
                await extractTextFromImages();
                showDialog<String>(
                  context: context,
                  builder: (BuildContext context) => AlertDialog(
                    title: const Text('Extracted text'),
                    content: Expanded(
                      child: SingleChildScrollView(
                        child: Text(_textMultiImages),
                      ),
                    ),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                          _extractTextController.reset();
                          Navigator.pop(context, 'Cancel');
                        },
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () async {
                          await shareText(true);
                          _extractTextController.reset();
                          Navigator.pop(context, 'Share');
                        },
                        child: const Text('Share'),
                      ),
                    ],
                  ),
                );
              },
              child: const Text("Extract Text"),
            ),
            // SizedBox(height: 30),
            // Container(
            //   width: 150,
            //   height: 60,
            //   child: ElevatedButton(
            //       onPressed: () {
            //         print("folderPath: " + _folderPath);
            //         print(_titleController.text);
            //         print(_pdfFilePath);
            //         print(_passwordController.text);
            //         print(_pdfFilePathEncrypted);
            //       },
            //       child: Text(
            //         "PRINT",
            //         style: TextStyle(fontSize: 18),
            //       )),
            // )
          ],
        ),
      ),
    );
  }
}

Future<String> encryptPdfHelper(Map map) async {
  // print(">>>>>>>>>>> inside encryptPdfHelper - start");
  String pdfToEncryptPath = map["pdfToEncryptPath"];
  String password = map["password"];

  final PdfDocument document =
      PdfDocument(inputBytes: await File(pdfToEncryptPath).readAsBytes());
  final PdfSecurity security = document.security;
  // print(">>>>>>>>>>> inside encryptPdfHelper - document created");
  security.userPassword = password;

  int lastSeperator = pdfToEncryptPath.lastIndexOf(Platform.pathSeparator);
  String encryptedFilePath = pdfToEncryptPath.substring(0, lastSeperator + 1) +
      "Encrypted-" +
      pdfToEncryptPath.substring(lastSeperator + 1);
  File encryptedFile =
      await File(encryptedFilePath).writeAsBytes(document.save());
  // print(">>>>>>>>>>> inside encryptPdfHelper - encryptedPFilePath: " +
  //     encryptedFilePath);

  document.dispose();
  return encryptedFile.path;
}
