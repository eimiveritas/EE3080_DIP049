import 'dart:io';

import 'package:ee3080_dip049/folderManager.dart';
import 'package:flutter/material.dart';

class PostProcessing extends StatelessWidget {
  FolderManager folderManager = new FolderManager();

  @override
  Widget build(BuildContext context) {
    final Map arguments = ModalRoute.of(context)!.settings.arguments as Map;
    //if string data
    print(arguments['imagePath']);
    return MaterialApp(
      home: Scaffold(
        body: Column(
          textDirection: TextDirection.ltr,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Image.file(File(arguments['imagePath'])),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IconButton(
                    iconSize: 48,
                    color: Colors.black,
                    onPressed: () {
                      print('123');
                    },
                    icon: Icon(Icons.close_outlined),
                  ),
                  IconButton(
                    iconSize: 48,
                    color: Colors.black,
                    onPressed: () {
                      var imagePathString = "";

                      folderManager.createFolderWithCurrentDatetimePath
                          .then((value) {
                        print(value);
                        imagePathString =
                            "${value}${arguments['imagePath'].split('/').last}";

                        File(arguments['imagePath']).copy(imagePathString);

                        print(imagePathString);

                        Navigator.pushNamed(context, '/edit_page',
                            arguments: {'folderPath': value});
                      });
                    },
                    icon: Icon(Icons.done_outlined),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Column(
                children: [
                  IconButton(
                    iconSize: 48,
                    color: Colors.black,
                    onPressed: () {
                      print('123');
                    },
                    icon: Icon(Icons.edit_outlined),
                  ),
                  IconButton(
                    iconSize: 48,
                    color: Colors.black,
                    onPressed: () {
                      print('123');
                    },
                    icon: Icon(Icons.article_outlined),
                  ),
                  IconButton(
                    iconSize: 48,
                    color: Colors.black,
                    onPressed: () {
                      print('123');
                    },
                    icon: Icon(Icons.exposure_outlined),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        IconButton(
                          iconSize: 48,
                          color: Colors.black,
                          onPressed: () {
                            print('123');
                          },
                          icon: Icon(Icons.redo_outlined),
                        ),
                        IconButton(
                          iconSize: 48,
                          color: Colors.black,
                          onPressed: () {
                            print('123');
                          },
                          icon: Icon(Icons.undo_outlined),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        IconButton(
                          iconSize: 48,
                          color: Colors.black,
                          onPressed: () {
                            print('123');
                          },
                          icon: Icon(Icons.rotate_90_degrees_ccw_outlined),
                        ),
                        IconButton(
                          iconSize: 48,
                          color: Colors.black,
                          onPressed: () {
                            print('123');
                          },
                          icon: Icon(Icons.rotate_90_degrees_ccw),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
