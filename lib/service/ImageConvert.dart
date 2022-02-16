import 'dart:io';
import 'package:image/image.dart';

Future<File> cropImage(String path) async {
  final image = decodeImage(File(path).readAsBytesSync())!;
  final cropImage = copyCrop(image, (image.width~/2)-50, (image.height~/2), 100, 100);
  return await File(path).writeAsBytes(encodePng(cropImage));
}