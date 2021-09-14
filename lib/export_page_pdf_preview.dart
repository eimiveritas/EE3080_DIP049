import 'dart:io';

import 'package:flutter/material.dart';
import 'package:advance_pdf_viewer/advance_pdf_viewer.dart';

class PdfPreviewPage extends StatefulWidget {
  final String pdfFilePath;
  final String pdfTitle;

  PdfPreviewPage(this.pdfTitle, this.pdfFilePath);

  @override
  _PdfPreviewPageState createState() =>
      _PdfPreviewPageState(pdfTitle, pdfFilePath);
}

class _PdfPreviewPageState extends State<PdfPreviewPage> {
  final String pdfTitle;
  final String pdfFilePath;

  _PdfPreviewPageState(this.pdfTitle, this.pdfFilePath);

  bool _isLoading = true;
  late PDFDocument document;

  @override
  void initState() {
    super.initState();
    loadDocument();
  }

  loadDocument() async {
    print("inside loadDocument: " + pdfFilePath);

    document = await PDFDocument.fromFile(File(pdfFilePath));
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("PDF Preview: " + pdfTitle),
      ),
      body: Center(
          child: _isLoading
              ? Center(child: CircularProgressIndicator())
              : PDFViewer(
                  document: document,
                  zoomSteps: 1,
                )),
    );
  }
}
