import 'dart:io';
import 'package:image/image.dart';
import 'package:shutter_app/module.dart';

Future<File> cropImage(CropImageRequest cropImageRequest) async {
  final path = cropImageRequest.imagePath;
  final width = cropImageRequest.width;
  final height = cropImageRequest.height;

  final image = decodeImage(File(path).readAsBytesSync())!;

  //get center position of the image div the width and height get the center point
  //minus crop size to start crop from position that will crop image in center
  final widthCropPosition = (image.width~/2)-width~/2;
  final heightCropPosition = (image.height~/2)-height~/2;

  //return as file back
  final cropImage = copyCrop(image, widthCropPosition, heightCropPosition, width, height);
  return await File(path).writeAsBytes(encodePng(cropImage));
}