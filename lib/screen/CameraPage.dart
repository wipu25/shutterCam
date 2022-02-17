import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:shutter_app/module.dart';
import 'package:shutter_app/service/ImageConvert.dart';
import 'package:shutter_app/utils/CustomTextField.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  List<String> countTakePhoto = [];
  double sliderValue = 10.0;
  int dropDownValue = 1;
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  final TextEditingController widthController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  @override
  void initState() {
    super.initState();
    _prefs.then((value) {
      setState(() {
        dropDownValue = value.getInt('dropDownValue')!;
        sliderValue = value.getDouble('sliderValue')!;
      });
      widthController.text = value.getString('width')!;
      heightController.text = value.getString('height')!;
    });

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
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text("Shutter Cam"),
        centerTitle: false,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
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
                              return Center(
                                child:Transform.scale(
                                  scale: 0.8/(screenWidth/screenHeight),
                                  child: new CameraPreview(_controller),
                                ),
                              );
                            } else {
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
                            backgroundColor: Colors.green,
                              shape: CircleBorder(side: BorderSide(color: Colors.black, width: 2)),
                              onPressed: () async {
                                onTakePicture();
                              }
                          ),
                        ),
                        SizedBox(height: 16),
                      ],
                    ),
                  ]
                )),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8,vertical: 4),
              color: Colors.blue,
              child: Column(
                children: [
                  exposureBar(),
                  widthHeightBar(),
                  SizedBox(height: 8,),
                  dropDownPhotoBar(),
                  SizedBox(height: 8,)
                ],
              ),
            )
          ],
        ),
      )
    );
  }

  Widget exposureBar() {
    return Row(
      children: [
        SizedBox(
            width: 60,
            child: Text("Exposure")
        ),
        Expanded(
            child: Slider(
                activeColor: Colors.black,
                inactiveColor: Colors.black.withOpacity(0.4),
                min: 10.0,
                max: 60.0,
                value: sliderValue,
                onChanged: (value) {
                  _prefs.then((pref) => pref.setDouble('sliderValue', value));
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
        SizedBox(
            width: 60,
            child: Text("Width")
        ),
        SizedBox(width: 16),
        CustomTextField(
          controller: widthController,
          onChanged: (value) {
            _prefs.then((pref) => pref.setString('width', value));
          },
        ),
        SizedBox(width: 16),
        Text("Height"),
        SizedBox(width: 16),
        CustomTextField(
          controller: heightController,
          onChanged: (value) {
            _prefs.then((pref) => pref.setString('height', value));
          },
        ),
      ],
    );
  }

  Widget dropDownPhotoBar() {
    return Row(
        children: [
          SizedBox(
              width: 60,
              child: Text("Photos")
          ),
          SizedBox(width: 16,),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
            ),
            child: DropdownButton<int>(
              underline: SizedBox(),
              icon: Icon(Icons.keyboard_arrow_up),
              onChanged: (value) {
                if(countTakePhoto.length > value!){
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text("Photo are more than that"),
                  ));
                } else if(countTakePhoto.length == value) {
                  toPhotoList();
                } else {
                  _prefs.then((pref) => pref.setInt('dropDownValue', value));
                  setState(() {
                    dropDownValue = value;
                  });
                }
              },
              value: dropDownValue,
              items: <int>[1,2,3,4,5,6,7,8,9,10].map<DropdownMenuItem<int>>((int value){
                return DropdownMenuItem<int>(
                    value: value,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text(value.toString()),
                    )
                );
              }).toList(),),
          )
        ]
    );
  }

  void toPhotoList() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => PhotoList(totalPhoto: countTakePhoto)))
        .then((value) => {
      setState(() {
        countTakePhoto.clear();
      })
    });
  }

  Future<void> onTakePicture() async {
    await _initializeControllerFuture;
    final width = widthController.value.text;
    final height = heightController.value.text;
    if(width.isNotEmpty && height.isNotEmpty){
      try{
        final image = await _controller.takePicture();
        final crop = await cropImage(CropImageRequest(image.path, width, height));
        setState(() {
          countTakePhoto.add(crop.path);
        });
        if (countTakePhoto.length != dropDownValue) {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  contentPadding: EdgeInsets.all(4.0),
                  alignment: Alignment.center,
                  title: Text("Taking Photos",textAlign: TextAlign.center,),
                  actions: [
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black)
                      ),
                      child: LinearProgressIndicator(
                        value: countTakePhoto.length/dropDownValue,
                        color: Colors.grey,
                        backgroundColor: Colors.white,
                        minHeight: 20,
                      ),
                    ),
                  ],
                );
              }
          );
        } else {
          toPhotoList();
        }
      } catch(e) {
        print(e);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Please Enter Width and Height"),
      ));
    }
  }
}
