import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class EditProjectPage extends StatefulWidget {
  EditProjectPage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  _EditProjectPageState createState() => _EditProjectPageState();
}

List<Map> data = List.generate(
    5,
    (index) => {
          "id": index,
          "name": "Page ${index + 1}",
          "picture": "https://picsum.photos/250?image=$index"
        }).toList();

class _EditProjectPageState extends State<EditProjectPage> {
  List<Widget> listArray = [];

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

  void _getListings(folderPath) {
    // <<<<< Note this change for the return type
    populate(folderPath).then((value) {
      List<Widget> listings = [];
      for (var i = 0; i < value.length; i++) {
        print("Done");
        listings.add(new Stack(
          children: <Widget>[
            Material(
                color: Colors.amber,
                child: InkWell(
                  onTap: () {
                    debugPrint("You clicked on page!");
                  },
                  child: ClipRect(
                    child: Align(
                      alignment: Alignment.topCenter,
                      heightFactor: 1,
                      child: Image.file(File(value[i])),
                    ),
                  ),
                )),
            Positioned(
              top: 0,
              right: 0,
              child: TextButton(
                onPressed: () {
                  debugPrint("You removed page}");
                  setState(() {});
                },
                child: Text("X"),
                style: TextButton.styleFrom(
                    padding: EdgeInsets.all(0),
                    backgroundColor: Colors.blue,
                    primary: Colors.white),
              ),
            ),
            Positioned(
                bottom: 0,
                //width: 10,
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Text(
                    value[i].split("/").last,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        backgroundColor: Colors.blue, color: Colors.white),
                  ),
                )),
          ],
        ));
      }
      setState(() {
        listArray = listings;
      });
      print(listings.length.toString());
    });
  }

  @override
  Widget build(BuildContext context) {
    final Map arguments = ModalRoute.of(context)!.settings.arguments as Map;
    //if string data
    //data.add({
    //  "id": data.length,
    //  "name": "Product",
    //  "picture": "https://picsum.photos/250?image=1"
    //});

    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the EditProjectPage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          TextField(
            decoration: const InputDecoration(
                border: OutlineInputBorder(), hintText: 'Untitled Project'),
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: EdgeInsets.all(10),
              child: Text(
                'Last saved: 21 Aug 2021 5.00pm ${arguments["folderPath"]}',
              ),
            ),
          ),
          Expanded(
              child: GridView.count(crossAxisCount: 2, children: listArray)),
          TextButton(
              onPressed: () {
                _getListings(arguments["folderPath"]);
              },
              child: Text("Get")),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              SizedBox(
                width: 10,
              ),
              Expanded(
                  child: TextButton(
                child: Text("Save"),
                onPressed: () {
                  debugPrint("Saving to project...");
                },
                style: TextButton.styleFrom(
                    primary: Colors.white,
                    backgroundColor: Colors.blue,
                    textStyle: TextStyle(fontSize: 15)),
              )),
              SizedBox(
                width: 10,
              ),
              Expanded(
                  child: TextButton(
                child: Text("Export"),
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/export_page',
                  );
                },
                style: TextButton.styleFrom(
                    primary: Colors.white,
                    backgroundColor: Colors.blue,
                    textStyle: TextStyle(fontSize: 15)),
              )),
              SizedBox(
                width: 10,
              )
            ],
          )
        ],
      ),
    );
  }
}
