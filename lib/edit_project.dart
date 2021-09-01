import 'package:flutter/material.dart';

void main() {
  runApp(EditProject());
}

class EditProject extends StatelessWidget {
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
      home: EditProjectPage(title: 'Flutter Demo Home Page'),
    );
  }
}

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
  @override
  Widget build(BuildContext context) {
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
                'Last saved: 21 Aug 2021 5.00pm',
              ),
            ),
          ),
          Expanded(
              child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                      maxCrossAxisExtent: 200,
                      childAspectRatio: 3 / 2,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 20),
                  itemCount: data.length,
                  itemBuilder: (BuildContext ctx, index) {
                    return Container(
                      alignment: Alignment.center,
                      child: Stack(
                        children: <Widget>[
                          Material(
                              color: Colors.amber,
                              child: InkWell(
                                onTap: () {
                                  debugPrint(
                                      "You clicked on page ${index + 1}!");
                                },
                                child: ClipRect(
                                  child: Align(
                                    alignment: Alignment.topCenter,
                                    heightFactor: 1,
                                    child:
                                        Image.network(data[index]["picture"]),
                                  ),
                                ),
                              )),
                          Positioned(
                            top: 0,
                            right: 0,
                            child: TextButton(
                              onPressed: () {
                                debugPrint("You removed page ${index + 1}");
                                setState(() {
                                  data.removeAt(index);
                                });
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
                                  data[index]["name"],
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      backgroundColor: Colors.blue,
                                      color: Colors.white),
                                ),
                              )),
                        ],
                      ),
                      decoration: BoxDecoration(
                          color: Colors.amber,
                          borderRadius: BorderRadius.circular(15)),
                    );
                  })),
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
                  debugPrint("Exporting project...");
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
