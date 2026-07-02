import 'dart:math' as math;
import 'dart:typed_data';

import 'package:image/image.dart' as img;

class ImageSharpnessMetrics {
  final bool decoded;
  final int width;
  final int height;
  final double variance;
  final double effectiveThreshold;
  final String? rejectionReason;

  const ImageSharpnessMetrics({
    required this.decoded,
    required this.width,
    required this.height,
    required this.variance,
    required this.effectiveThreshold,
    required this.rejectionReason,
  });

  bool get isAcceptable => decoded && rejectionReason == null;

  Map<String, Object?> toMap() => {
        'decoded': decoded,
        'width': width,
        'height': height,
        'variance': variance,
        'effectiveThreshold': effectiveThreshold,
        'rejectionReason': rejectionReason,
      };

  factory ImageSharpnessMetrics.fromMap(Map<Object?, Object?> map) {
    return ImageSharpnessMetrics(
      decoded: map['decoded'] as bool? ?? false,
      width: map['width'] as int? ?? 0,
      height: map['height'] as int? ?? 0,
      variance: (map['variance'] as num?)?.toDouble() ?? -1,
      effectiveThreshold: (map['effectiveThreshold'] as num?)?.toDouble() ?? 0,
      rejectionReason: map['rejectionReason'] as String?,
    );
  }

  static ImageSharpnessMetrics undecoded({
    required double threshold,
    String? reason,
  }) {
    return ImageSharpnessMetrics(
      decoded: false,
      width: 0,
      height: 0,
      variance: -1,
      effectiveThreshold: threshold,
      rejectionReason: reason ?? 'No se pudo decodificar la imagen.',
    );
  }
}

class ImageSharpnessValidator {
  static const double defaultThreshold = 100.0;
  static const int _maxAnalysisSide = 800;
  static const int _sampleStep = 3;

  static double calculateVariance(Uint8List imageBytes) {
    return analyze(imageBytes).variance;
  }

  static bool isSharp(double variance, {double threshold = defaultThreshold}) =>
      variance >= threshold;

  static ImageSharpnessMetrics analyze(
    Uint8List imageBytes, {
    double threshold = defaultThreshold,
  }) {
    final effectiveThreshold =
        (threshold.isFinite && threshold > 0) ? threshold : defaultThreshold;

    try {
      final decoded = img.decodeImage(imageBytes);
      if (decoded == null) {
        return ImageSharpnessMetrics.undecoded(threshold: effectiveThreshold);
      }

      final gray = _prepareForAnalysis(decoded);
      final variance = _laplacianVariance(gray);

      final rejectionReason = variance < effectiveThreshold
          ? 'La foto se ve borrosa. Mantén el teléfono quieto y asegúrate de tener buena luz.'
          : null;

      return ImageSharpnessMetrics(
        decoded: true,
        width: decoded.width,
        height: decoded.height,
        variance: variance,
        effectiveThreshold: effectiveThreshold,
        rejectionReason: rejectionReason,
      );
    } catch (e) {
      return ImageSharpnessMetrics.undecoded(
        threshold: effectiveThreshold,
        reason: 'Error inesperado al analizar la imagen: $e',
      );
    }
  }

  static img.Image _prepareForAnalysis(img.Image source) {
    final longestSide = math.max(source.width, source.height);
    final resized = longestSide > _maxAnalysisSide
        ? img.copyResize(
            source,
            width: source.width >= source.height ? _maxAnalysisSide : null,
            height: source.height > source.width ? _maxAnalysisSide : null,
          )
        : source;
    return img.grayscale(resized);
  }

  static double _laplacianVariance(img.Image gray) {
    final width = gray.width;
    final height = gray.height;
    var count = 0;
    var mean = 0.0;
    var m2 = 0.0;

    for (var y = 1; y < height - 1; y += _sampleStep) {
      for (var x = 1; x < width - 1; x += _sampleStep) {
        final center = img.getLuminance(gray.getPixel(x, y)).toDouble();
        final top = img.getLuminance(gray.getPixel(x, y - 1)).toDouble();
        final bottom = img.getLuminance(gray.getPixel(x, y + 1)).toDouble();
        final left = img.getLuminance(gray.getPixel(x - 1, y)).toDouble();
        final right = img.getLuminance(gray.getPixel(x + 1, y)).toDouble();
        final laplacian = top + bottom + left + right - 4 * center;

        count++;
        final delta = laplacian - mean;
        mean += delta / count;
        m2 += delta * (laplacian - mean);
      }
    }

    if (count == 0) return 0;
    return m2 / count;
  }
}
