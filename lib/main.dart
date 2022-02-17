import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shutter_app/Screen/CameraPage.dart';
import 'package:shutter_app/module.dart';

Future<void> main() async {
  //Check for available cameras of the devices
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();

  //Run ths main app with splash screen passing the available camera
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Material App',
    home: SplashScreen(cameras: cameras),
  ));
}

class SplashScreen extends StatelessWidget {
  final List<CameraDescription> cameras;

  const SplashScreen({
    Key? key,
    required this.cameras
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Spacer(),
                Expanded(child: Text("WELCOME TO \nSHUTTER CAM",style: TextStyle(fontSize: 36),textAlign: TextAlign.center,)),
                Spacer(),
                TextButton(
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.all(12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          side: BorderSide(color: Colors.blue, width: 2)
                      ),
                    ),
                    onPressed: () async {
                      //Calling shared preference retrieving local data storage of old user setting
                      final Future<SharedPreferences> prefs = SharedPreferences.getInstance();
                      final userLastSetting = await prefs.then((value) {
                        return UserSettingData(
                            exposure: value.getDouble('sliderValue') ?? 0.5,
                            choosePhoto: value.getInt('dropDownValue') ?? 10,
                            width: value.getString('width') ?? "",
                            height: value.getString('height') ?? ""
                        );
                      });
                      //Push to camera page after collecting user pref and pass to the new page
                      Navigator.push(context, MaterialPageRoute(builder: (context) => CameraPage(cameras: cameras,userLastSetting: userLastSetting)));
                    },
                    child: Text("START")
                ),
                SizedBox(height: 20)
              ],
            ),
          ),
        ),
      );
  }
}

