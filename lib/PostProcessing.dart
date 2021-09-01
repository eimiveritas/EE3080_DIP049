import 'package:flutter/material.dart';

void main() => runApp(PostProcessing());

class PostProcessing extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Column(
          textDirection: TextDirection.ltr,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
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
                      print('123');
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
