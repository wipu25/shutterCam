import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:shutter_app/Screen/CameraPage.dart';
import 'package:shutter_app/Screen/PhotoList.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final cameras = await availableCameras();
  runApp(MaterialApp(
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
                Expanded(child: Text("WELCOME TO SHUTTER CAM",style: TextStyle(fontSize: 36),textAlign: TextAlign.center,)),
                Spacer(),
                TextButton(
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

