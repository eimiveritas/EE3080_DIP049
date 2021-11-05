import 'package:flutter/material.dart';
import 'HomeScreen.dart';
import 'CameraPage.dart';
import 'PostProcessing.dart';
import 'edit_project.dart';
//import 'export_page.dart';
//import 'export_page_pdf_preview.dart';
import 'ProcessingScreen.dart';
import 'export_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      routes: {
        '/': (context) => HomeScreen(),
        '/camera': (context) => CameraPage(),
        '/post_process': (context) => PostProcessing(),
        '/edit_page': (context) => EditProjectPage(
            extraArgs: ModalRoute.of(context)!.settings.arguments),
        '/process': (context) => ProcessingScreen(),
      },
    );
  }
}
