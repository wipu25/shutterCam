import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:shutter_app/Screen/CameraPage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final cameras = await availableCameras();
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
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => CameraPage(cameras: cameras)));
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

