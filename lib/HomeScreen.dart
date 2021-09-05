import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Projects',
      home: Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: const Text('Projects'),
          ),
          body: Padding(
            padding: const EdgeInsets.all(18.0),
            child: Card(
              child: ListTile(
                //onLongPress: ()
                title: Text('Project Name'),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          '/edit_page',
                        );
                      },
                      icon: Icon(Icons.edit),
                    ),
                    IconButton(
                      onPressed: () {},
                      icon: Icon(Icons.delete),
                    )
                  ],
                ),
              ),
            ),
          ),
          floatingActionButton: Container(
            height: 100.0,
            width: 100.0,
            child: FittedBox(
              child: FloatingActionButton(
                child: Icon(Icons.photo_camera_outlined),
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/camera',
                  );
                },
              ),
            ),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat),
    );
  }
}
