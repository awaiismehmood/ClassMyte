import 'dart:io';
import 'package:image/image.dart' as img;

void main() {
  final file = File('assets/logo_no_bg.png');
  final image = img.decodePng(file.readAsBytesSync());
  if (image == null) return;
  
  // Scans for the literal bounding box
  int minX = image.width, minY = image.height, maxX = 0, maxY = 0;
  for (int y = 0; y < image.height; y++) {
    for (int x = 0; x < image.width; x++) {
      if (image.getPixel(x, y).a > 0) {
        if (x < minX) minX = x;
        if (x > maxX) maxX = x;
        if (y < minY) minY = y;
        if (y > maxY) maxY = y;
      }
    }
  }
  
  // Crop off invisible padding
  final cropped = img.copyCrop(image, x: minX, y: minY, width: maxX - minX + 1, height: maxY - minY + 1);
  
  // Maintain a square with slight padding, fully transparent
  int maxDim = cropped.width > cropped.height ? cropped.width : cropped.height;
  int targetSize = (maxDim * 1.2).toInt(); 
  
  final squared = img.Image(width: targetSize, height: targetSize, numChannels: 4);
  // Do NOT fill with color (remains transparent)
  
  // Draw the cropped logo neatly
  img.compositeImage(
    squared, 
    cropped, 
    dstX: (targetSize - cropped.width) ~/ 2, 
    dstY: (targetSize - cropped.height) ~/ 2
  );
  
  File('assets/logo_transparent_square.png').writeAsBytesSync(img.encodePng(squared));
}
