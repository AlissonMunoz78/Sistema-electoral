import 'dart:io';
import 'package:image/image.dart' as img;

// Limitación conocida: Laplacian variance es un heurístico simple que puede
// clasificar incorrectamente imágenes con patrones repetitivos o texturas finas
// como borrosas. Un enfoque más robusto usaría redes neuronales (p.ej. MobileNet),
// pero incrementa el tamaño de la app y requiere permisos adicionales.
class ImageService {
  static bool isImageBlurry(File file) {
    try {
      final bytes = file.readAsBytesSync();
      final decoded = img.decodeImage(bytes);
      if (decoded == null) return false;

      if (decoded.width < 32 || decoded.height < 32) return false;

      final resized = img.copyResize(
        decoded,
        width: 100,
        height: 100,
        interpolation: img.Interpolation.average,
      );
      final gray = img.grayscale(resized);

      var laplacianVariance = 0.0;
      var count = 0;

      for (var y = 1; y < gray.height - 1; y++) {
        for (var x = 1; x < gray.width - 1; x++) {
          final center = gray.getPixel(x, y).r.toDouble();
          final up = gray.getPixel(x, y - 1).r.toDouble();
          final down = gray.getPixel(x, y + 1).r.toDouble();
          final left = gray.getPixel(x - 1, y).r.toDouble();
          final right = gray.getPixel(x + 1, y).r.toDouble();
          final laplacian = (up + down + left + right - (4 * center)).abs();
          laplacianVariance += laplacian;
          count++;
        }
      }

      if (count == 0) return false;

      final average = laplacianVariance / count;
      return average < 8.0;
    } catch (_) {
      return false;
    }
  }
}