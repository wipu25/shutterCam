import 'dart:io';
import 'package:flutter/material.dart';

class FullScreenPhoto extends StatelessWidget {
  final String path;
  const FullScreenPhoto({
    Key? key,
    required this.path
  }) : super(key: key);

  //display fullscreen photo
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Shutter Cam"),
        centerTitle: false,
        automaticallyImplyLeading: false,
        actions: [
          GestureDetector(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Icon(Icons.arrow_back_ios),
            ),
            onTap: () {
              Navigator.of(context).pop();
            },
          ),
          SizedBox(width: 16)
        ],
      ),
      body: Image.file(
        File(path),
        fit: BoxFit.fitWidth,
        height: double.infinity,
        width: double.infinity,
        alignment: Alignment.center,
      ),
    );
  }
}
