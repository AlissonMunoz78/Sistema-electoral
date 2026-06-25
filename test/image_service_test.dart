import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:sistema_electoral/core/image_service.dart';

void main() {
  test('detecta una imagen con borde nítido como no borrosa', () {
    final image = img.Image(width: 200, height: 200);
    for (var y = 0; y < image.height; y++) {
      for (var x = 0; x < image.width; x++) {
        image.setPixelRgba(x, y, 255, 255, 255, 255);
      }
    }
    for (var y = 0; y < 100; y++) {
      for (var x = 0; x < 100; x++) {
        image.setPixelRgba(x, y, 0, 0, 0, 255);
      }
    }
    final tempDir = Directory.systemTemp.createTempSync('sharp-image');
    final file = File('${tempDir.path}/sharp.jpg');
    file.writeAsBytesSync(img.encodeJpg(image));
    expect(ImageService.isImageBlurry(file), isFalse);
  });

  test('detecta una imagen muy suave como borrosa', () {
    final image = img.Image(width: 200, height: 200);
    for (var y = 0; y < image.height; y++) {
      for (var x = 0; x < image.width; x++) {
        final value = (x * 0.5 + y * 0.5).round();
        image.setPixelRgba(x, y, value, value, value, 255);
      }
    }
    final tempDir = Directory.systemTemp.createTempSync('blur-image');
    final file = File('${tempDir.path}/blur.jpg');
    file.writeAsBytesSync(img.encodeJpg(image));
    expect(ImageService.isImageBlurry(file), isTrue);
  });
}