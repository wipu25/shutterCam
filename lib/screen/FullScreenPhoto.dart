import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FullScreenPhoto extends StatelessWidget {
  final String path;
  const FullScreenPhoto({
    Key? key,
    required this.path
  }) : super(key: key);

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
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: Center(
            child: Image.file(File(path))
        ),
      ),
    );
  }
}
