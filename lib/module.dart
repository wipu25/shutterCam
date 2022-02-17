
import 'dart:ui';

class CropImageRequest {
  final String imagePath;
  final int width;
  final int height;

  CropImageRequest(String imagePath, String width, String height) :
    this.imagePath = imagePath,
    this.width = int.parse(width),
    this.height = int.parse(height);
}

class UserSettingData {
  final double exposure;
  final int choosePhoto;
  final String width;
  final String height;

  UserSettingData({required this.exposure, required this.choosePhoto, required this.width, required this.height});
}
