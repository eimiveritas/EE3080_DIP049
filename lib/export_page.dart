import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:week3_ui/export_page_pdf_preview.dart';

void main() {
  runApp(MaterialApp(
    title: "Last Page UI",
    home: ExportPage(),
  ));
}

class ExportPage extends StatelessWidget {
  final _titleController = TextEditingController();

  @override
  Widget build(BuildContext context) {
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
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PdfPreviewPage()),
                );
              },
              icon: Image.network(
                //  "https://flutter.github.io/assets-for-api-docs/assets/widgets/owl.jpg",
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
