import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:shutter_app/module.dart';
import 'package:shutter_app/service/ImageConvert.dart';
import 'package:shutter_app/utils/CustomTextField.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'PhotoList.dart';

class CameraPage extends StatefulWidget {
  final List<CameraDescription> cameras;
  final UserSettingData userLastSetting;
  const CameraPage({
    Key? key,
    required this.cameras,
    required this.userLastSetting
  }) : super(key: key);

  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {

  //Init temporary data
  List<String> countTakePhoto = [];
  late double sliderValue = widget.userLastSetting.exposure;
  late int dropDownValue = widget.userLastSetting.choosePhoto;
  //Dummy data if can't retrieve min/max exposure
  double minExposure = -50;
  double maxExposure = 50;
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;
  final TextEditingController widthController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  @override
  void initState() {
    super.initState();
    initCamera();
    setState(() {
      widthController.text = widget.userLastSetting.width;
      heightController.text = widget.userLastSetting.height;
    });
  }

  Future<void> initCamera() async {
    //Binding camera controller with behind camera
    _controller = CameraController(
      widget.cameras.first,
      ResolutionPreset.medium,
    );

    //init camera to retrieve exposure
    _initializeControllerFuture = _controller.initialize();
    await _initializeControllerFuture;
    await _controller.setExposureOffset(sliderValue);
    final minExposure = await _controller.getMinExposureOffset();
    final maxExposure = await _controller.getMaxExposureOffset();

    //set exposure for slider usage
    setState(() {
      this.maxExposure = maxExposure;
      this.minExposure = minExposure;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //For camera size purpose
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text("Shutter Cam"),
        centerTitle: false,
        automaticallyImplyLeading: false,
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        child: SafeArea(
          child: Stack(
            children: [
              Container(
                alignment: Alignment.topCenter,
                color: Colors.black,
                child: FutureBuilder<void>(
                  future: _initializeControllerFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      //scale camera preview according to screen size
                      return Transform.scale(scale: 0.8/screenWidth*screenHeight,child: CameraPreview(_controller));
                    } else {
                      return const Center(child: CircularProgressIndicator());
                    }
                  },
                ),
              ),
              Column(
                children: [
                  Spacer(),
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
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8,vertical: 4),
                    color: Colors.blue,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        exposureBar(),
                        widthHeightBar(),
                        SizedBox(height: 8,),
                        dropDownPhotoBar(),
                        SizedBox(height: 8,)
                      ],
                    ),
                  ),
                ],
              ),
            ]
          ),
        ),
      )
    );
  }

  //Exposure row bar
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
                min: minExposure,
                max: maxExposure,
                value: sliderValue,
                onChanged: (value) {
                  //Save to local anytime user change slider
                  _prefs.then((pref) => pref.setDouble('sliderValue', value));
                  _controller.setExposureOffset(value);
                  setState(() {
                    sliderValue = value;
                  });
                })
        )
      ],
    );
  }

  //width height bar setting
  Widget widthHeightBar() {
    return Row(
      children: [
        SizedBox(
            width: 60,
            child: Text("Width")
        ),
        SizedBox(width: 16),
        //Save to local anytime user change width
        CustomTextField(
          controller: widthController,
          onChanged: (value) {
            _prefs.then((pref) => pref.setString('width', value));
          },
        ),
        SizedBox(width: 16),
        Text("Height"),
        SizedBox(width: 16),
        //Save to local anytime user change height
        CustomTextField(
          controller: heightController,
          onChanged: (value) {
            _prefs.then((pref) => pref.setString('height', value));
          },
        ),
      ],
    );
  }

  //drop down photo setting row
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
                //Check if user have taken more than re-selected max picture each time
                if(countTakePhoto.length > value!){
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text("Photo are more than that"),
                  ));
                } else{
                  //if user select new max picture equal to number they take navigate to photo list
                  if(countTakePhoto.length == value){
                    toPhotoList();
                  }
                  //save change number to local storage
                  _prefs.then((pref) => pref.setInt('dropDownValue', value));
                  setState(() {
                    dropDownValue = value;
                  });
                }
              },
              value: dropDownValue,
              // 10 item generate through int list
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
    //navigate to photo list if return clear the photo that is taken
    Navigator.push(context, MaterialPageRoute(builder: (context) => PhotoList(totalPhoto: countTakePhoto)))
        .then((value) => {
      setState(() {
        countTakePhoto.clear();
      })
    });
  }

  Future<void> onTakePicture() async {
    //re-init cam making sure it still available
    await _initializeControllerFuture;
    final width = widthController.value.text;
    final height = heightController.value.text;
    //if width height is not empty camera will take picture
    if(width.isNotEmpty && height.isNotEmpty){
      try{
        final image = await _controller.takePicture();
        //croping process then return as file
        final crop = await cropImage(CropImageRequest(image.path, width, height));
        setState(() {
          countTakePhoto.add(crop.path);
        });
        //if photo is not at max show loading progress
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
          //to photo list if max photo taken
          toPhotoList();
        }
      } catch(e) {
        print(e);
      }
    } else {
      //alert if width height not enter
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text("Please Enter Width and Height"),
      ));
    }
  }
}
