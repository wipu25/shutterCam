import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shutter_app/service/ImageConvert.dart';
import 'package:shutter_app/utils/CustomTextField.dart';

import 'PhotoList.dart';

class CameraPage extends StatefulWidget {
  final List<CameraDescription> cameras;

  const CameraPage({
    Key? key,
    required this.cameras
  }) : super(key: key);

  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  int dropDownValue = 10;
  List<String> countTakePhoto = [];
  double sliderValue = 10.0;
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.cameras.first,
      ResolutionPreset.medium,
    );

    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text("Shutter Cam"),
          centerTitle: false,
          automaticallyImplyLeading: false,
        ),
        body: Container(
          child: Column(
            children: [
              Expanded(
                  child: Stack(
                    children: [
                      Container(
                        color: Colors.black,
                        child: Center(
                          child: FutureBuilder<void>(
                            future: _initializeControllerFuture,
                            builder: (context, snapshot) {
                              if (snapshot.connectionState == ConnectionState.done) {
                                // If the Future is complete, display the preview.
                                return CameraPreview(_controller);
                              } else {
                                // Otherwise, display a loading indicator.
                                return const Center(child: CircularProgressIndicator());
                              }
                            },
                          ),
                        ),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Center(
                            child: FloatingActionButton(
                                onPressed: () async {
                                  await _initializeControllerFuture;
                                  final image = await _controller.takePicture();
                                  final crop = await cropImage(image.path);
                                  setState(() {
                                    countTakePhoto.add(crop.path);
                                  });
                                  if (countTakePhoto.length != dropDownValue) {
                                    showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return AlertDialog(
                                            title: Text("Progress"),
                                            actions: [
                                              LinearProgressIndicator(
                                                value: countTakePhoto.length/dropDownValue,
                                                color: Colors.blue,
                                                backgroundColor: Colors.blue.withOpacity(0.4),
                                              )
                                            ],
                                          );
                                        }
                                    );
                                  } else {
                                    Navigator.push(context, MaterialPageRoute(builder: (context) => PhotoList(totalPhoto: countTakePhoto)))
                                        .then((value) => {
                                      setState(() {
                                        countTakePhoto.clear();
                                      })
                                    });
                                  }
                                }
                            ),
                          ),
                          SizedBox(height: 16),
                        ],
                      ),
                    ]
                  )),
              Container(
                padding: EdgeInsets.all(8),
                color: Colors.blue,
                child: Column(
                  children: [
                    exposureBar(),
                    widthHeightBar(),
                    SizedBox(height: 8,),
                    dropDownPhotoBar()
                  ],
                ),
              )
            ],
          ),
        )
      ),
    );
  }

  Widget exposureBar() {
    return Row(
      children: [
        Text("Exposure"),
        Expanded(
            child: Slider(
                activeColor: Colors.black,
                inactiveColor: Colors.black.withOpacity(0.4),
                min: 10.0,
                max: 60.0,
                value: sliderValue,
                onChanged: (value) {
                  setState(() {
                    sliderValue = value;
                  });
                })
        )
      ],
    );
  }

  Widget widthHeightBar() {
    return Row(
      children: [
        Text("Width"),
        SizedBox(width: 16),
        CustomTextField(),
        SizedBox(width: 16),
        Text("Height"),
        SizedBox(width: 16),
        CustomTextField(),
      ],
    );
  }

  Widget dropDownPhotoBar() {
    return Row(
        children: [
          Text("Photos"),
          SizedBox(width: 16,),
          DropdownButton<int>(
            icon: Icon(Icons.keyboard_arrow_up),
            onChanged: (value) {
              if(countTakePhoto.length >= dropDownValue){
                setState(() {
                  countTakePhoto.clear();
                });
              }
              setState(() {
                dropDownValue = value!;
              });
            },
            value: dropDownValue,
            items: <int>[1,2,3,4,5,6,7,8,9,10].map<DropdownMenuItem<int>>((int value){
              return DropdownMenuItem<int>(
                  value: value,
                  child: Text(value.toString())
              );
            }).toList(),)
        ]
    );
  }
}
