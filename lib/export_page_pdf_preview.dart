import 'dart:io';

import 'package:flutter/material.dart';
import 'package:advance_pdf_viewer/advance_pdf_viewer.dart';

class PdfPreviewPage extends StatefulWidget {
  final String _pdfFilePath;
  final String _pdfTitle;

  PdfPreviewPage(this._pdfTitle, this._pdfFilePath);

  @override
  _PdfPreviewPageState createState() =>
      _PdfPreviewPageState(_pdfTitle, _pdfFilePath);
}

class _PdfPreviewPageState extends State<PdfPreviewPage> {
  final String _pdfTitle;
  final String _pdfFilePath;

  _PdfPreviewPageState(this._pdfTitle, this._pdfFilePath);

  bool _isLoading = true;
  late PDFDocument document;

  @override
  void initState() {
    super.initState();
    loadDocument();
  }

  loadDocument() async {
    print("inside loadDocument: " + _pdfFilePath);

    document = await PDFDocument.fromFile(File(_pdfFilePath));
    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("PDF Preview: " + _pdfTitle),
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
