// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:camera_platform_interface/src/method_channel/method_channel_camera.dart';
import 'package:shutter_app/module.dart';
import 'package:shutter_app/screen/CameraPage.dart';
import 'package:shutter_app/screen/FullScreenPhoto.dart';
import 'package:shutter_app/screen/PhotoList.dart';
import 'package:shutter_app/utils/CustomTextField.dart';

import 'splashScreen_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SplashScreenTest().main();
  cameraScreen();
  photoListScreen();
  fullScreen();
}

Future<void> photoListScreen() async {
  testWidgets('Testing Photo List Screen Widget', (WidgetTester tester) async {
    final totalTestPath = ["","","","",""];
    await tester.pumpWidget(MaterialApp(home: PhotoList(totalPhoto: totalTestPath)));
    expect(find.byType(GestureDetector), findsNWidgets(totalTestPath.length));
    expect(find.widgetWithIcon(GestureDetector, Icons.arrow_back_ios), findsOneWidget);
    expect(find.text("Shutter Cam"), findsWidgets);
  });
}

Future<void> cameraScreen() async {
  testWidgets('Testing Camera Page Screen Widget', (WidgetTester tester) async {
    final cameraDescription = CameraDescription(
        name: 'Test',
        lensDirection: CameraLensDirection.back,
        sensorOrientation: 0
    );

    final userSetting = UserSettingData(exposure: 0.5,width: "100",height: "200",choosePhoto: 10);
    await tester.pumpWidget(MaterialApp(home: CameraPage(userLastSetting: userSetting, cameras: [cameraDescription],)));
    expect(find.byType(FloatingActionButton), findsOneWidget);
    expect(find.byType(Slider), findsOneWidget);
    expect(find.byType(CustomTextField), findsNWidgets(2));
    Slider slider = find.byType(Slider).evaluate().first.widget as Slider;
    expect(slider.value, 0.5);
  });
}

Future<void> fullScreen() async {
  testWidgets('Testing FullScreen Image Widget', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: FullScreenPhoto(path: "")));
    expect(find.byType(Image), findsOneWidget);
    expect(find.widgetWithIcon(GestureDetector, Icons.arrow_back_ios), findsOneWidget);
    expect(find.text("Shutter Cam"), findsWidgets);
  });
}