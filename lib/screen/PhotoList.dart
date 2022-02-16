import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'FullScreenPhoto.dart';

class PhotoList extends StatefulWidget {
  final List<String> totalPhoto;
  const PhotoList({
    Key? key,
    required this.totalPhoto
  }) : super(key: key);

  @override
  _PhotoListState createState() => _PhotoListState();
}

class _PhotoListState extends State<PhotoList> {
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
        body: SafeArea(
          child: Container(
            child: GridView.count(
              crossAxisSpacing: 2,
                mainAxisSpacing: 2,
                crossAxisCount: 2,
              children:
                List<Widget>.generate(widget.totalPhoto.length, (index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => FullScreenPhoto(path: widget.totalPhoto[index])));
                    },
                    child: Hero(
                      tag: 'image_list_$index',
                      child: Container(
                        child: Image.file(File(widget.totalPhoto[index]),fit: BoxFit.fill,),
                      ),
                    ),
                  );
                })
            ),
          ),
        )
    );
  }
}
