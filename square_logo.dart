import 'dart:io';
import 'package:image/image.dart' as img;

void main() {
  final file = File('assets/logo_no_bg.png');
  if (!file.existsSync()) return;
  final image = img.decodePng(file.readAsBytesSync());
  if (image == null) return;
  
  // 1. Find the exact bounding box of the actual logo by checking for alpha pixels
  int minX = image.width, minY = image.height, maxX = 0, maxY = 0;
  for (int y = 0; y < image.height; y++) {
    for (int x = 0; x < image.width; x++) {
      final pixel = image.getPixel(x, y);
      if (pixel.a > 0) {
        if (x < minX) minX = x;
        if (x > maxX) maxX = x;
        if (y < minY) minY = y;
        if (y > maxY) maxY = y;
      }
    }
  }
  
  // 2. Crop the image to just the logo (removes massive invisible paddings)
  final cropped = img.copyCrop(image, x: minX, y: minY, width: maxX - minX + 1, height: maxY - minY + 1);
  
  // 3. Make the ultimate canvas a perfect square
  int maxDim = cropped.width > cropped.height ? cropped.width : cropped.height;
  int targetSize = (maxDim * 1.5).toInt(); // 50% extra room relative to the core logo
  
  final squared = img.Image(width: targetSize, height: targetSize, numChannels: 4);
  
  // 4. Fill with the beautiful #0F172A dark slate color from your theme
  // This solves Android and iOS forcing ugly grey/white default backgrounds
  img.fill(squared, color: img.ColorRgba8(15, 23, 42, 255));
  
  // 5. Draw the cropped logo into the direct center
  img.compositeImage(
    squared, 
    cropped, 
    dstX: (targetSize - cropped.width) ~/ 2, 
    dstY: (targetSize - cropped.height) ~/ 2
  );
  
  File('assets/logo_square.png').writeAsBytesSync(img.encodePng(squared));
  print("SUCCESSFUL TRIM AND CROP");
}
