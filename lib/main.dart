import 'package:flutter/material.dart';
import 'HomeScreen.dart';
import 'CameraPage.dart';
import 'PostProcessing.dart';
import 'edit_project.dart';
import 'export_page.dart';
import 'export_page_pdf_preview.dart';
import 'ProcessingScreen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      // home: MyHomePage(title: 'Flutter Demo Home Page'),
      routes: {
        '/': (context) => HomeScreen(),
        '/camera': (context) => CameraPage(),
        '/post_process': (context) => PostProcessing(),
        '/edit_page': (context) => EditProjectPage(
            title: "Edit Page",
            ext_args: ModalRoute.of(context)!.settings.arguments),
        '/process': (context) => ProcessingScreen(),
        // '/export_page': (context) => ExportPage(),
      },
    );
  }
}
