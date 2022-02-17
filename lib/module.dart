
class CropImageRequest {
  final String imagePath;
  final int width;
  final int height;

  CropImageRequest(String imagePath, String width, String height) :
    this.imagePath = imagePath,
    this.width = int.parse(width),
    this.height = int.parse(height);
}
