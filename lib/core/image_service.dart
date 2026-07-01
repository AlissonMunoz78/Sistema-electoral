import 'dart:io';
import 'package:image/image.dart' as img;

class ImageService {
  static bool isImageBlurry(File file) {
    try {
      final bytes = file.readAsBytesSync();
      final original = img.decodeImage(bytes);
      if (original == null) return true;

      if (original.width < 64 || original.height < 64) return true;

      final resized = img.copyResize(
        original,
        width: 300,
        interpolation: img.Interpolation.nearest,
      );

      final gray = img.grayscale(resized);

      double sum = 0;
      double sumSq = 0;
      int count = 0;

      for (var y = 1; y < gray.height - 1; y++) {
        for (var x = 1; x < gray.width - 1; x++) {
          final c = gray.getPixel(x, y).r.toDouble();
          final u = gray.getPixel(x, y - 1).r.toDouble();
          final d = gray.getPixel(x, y + 1).r.toDouble();
          final l = gray.getPixel(x - 1, y).r.toDouble();
          final r = gray.getPixel(x + 1, y).r.toDouble();
          final lap = (u + d + l + r - 4 * c).abs();
          sum += lap;
          sumSq += lap * lap;
          count++;
        }
      }

      if (count == 0) return true;

      final mean = sum / count;
      final variance = sumSq / count - mean * mean;
      return variance < 30.0;
    } catch (_) {
      return true;
    }
  }
}
