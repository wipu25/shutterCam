import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shutter_app/main.dart';
import 'package:shutter_app/module.dart';

class SplashScreenTest {
  void main() {
    splashScreenTest();
    dataClassTest();
  }

  Future<void> splashScreenTest() async {
    testWidgets('Testing Splash Screen Widget', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(home: SplashScreen(cameras: [])));
      expect(find.byType(TextButton), findsOneWidget);
      expect(find.text("WELCOME TO \nSHUTTER CAM"), findsWidgets);
    });
  }

  void dataClassTest() {
    test('Testing Data Class and Preferences', () async{
      SharedPreferences.setMockInitialValues({}); //set values here
      SharedPreferences pref = await SharedPreferences.getInstance();

      final userLastSetting = UserSettingData(
          exposure: pref.getDouble('sliderValue') ?? 0.5,
          choosePhoto: pref.getInt('dropDownValue') ?? 10,
          width: pref.getString('width') ?? "",
          height: pref.getString('height') ?? ""
      );

      expect(userLastSetting.height, "");
      expect(userLastSetting.width, "");
      expect(userLastSetting.exposure, 0.5);
      expect(userLastSetting.choosePhoto, 10);

      pref.setString('height', "aaa");
      pref.setString('width', "bbb");
      pref.setDouble('sliderValue', 0.9);
      pref.setInt('dropDownValue', 12);

      final userPrefSetting = UserSettingData(
          exposure: pref.getDouble('sliderValue') ?? 0.5,
          choosePhoto: pref.getInt('dropDownValue') ?? 10,
          width: pref.getString('width') ?? "",
          height: pref.getString('height') ?? ""
      );

      expect(userPrefSetting.height, "aaa");
      expect(userPrefSetting.width, "bbb");
      expect(userPrefSetting.exposure, 0.9);
      expect(userPrefSetting.choosePhoto, 12);

      final cropImageRequest = CropImageRequest("", "100", "200");
      expect(cropImageRequest.width, 100);
      expect(cropImageRequest.height, 200);
      expect(cropImageRequest.imagePath, "");
    });
  }

}