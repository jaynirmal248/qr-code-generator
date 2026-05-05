import 'package:qr_studio/models/qr_config.dart';

class QRQualityEvaluator {
  static QRQuality evaluateQuality(
    String qrValue,
    QRConfig config,
  ) {
    final warnings = <String>[];
    var score = 100;

    // Content length affects scanability
    if (qrValue.length > 500) {
      score -= 20;
      warnings.add('Large content may reduce scan speed');
    }

    // Pattern detail affects visibility
    if (config.patternDetail < 50) {
      score -= 15;
      warnings.add('Low pattern detail may reduce scanability');
    }

    // Small size can be problematic
    if (config.size < 200) {
      score -= 20;
      warnings.add('Small QR code size may be hard to scan');
    }

    // Dot fill affects readability
    if (config.dotFill == DotFill.fill55) {
      score -= 10;
      warnings.add('Low dot fill may affect scan reliability');
    }

    // Apply small penalty for non-square styles (they're still scannable)
    if (config.dotStyle != DotStyle.square) {
      score -= 5;
    }

    // Ensure score is between 0-100
    score = score.clamp(0, 100);

    final isSafe = warnings.isEmpty;

    return QRQuality(
      scanabilityScore: score,
      warnings: warnings,
      isSafe: isSafe,
    );
  }

  static String getQualityDescription(int score) {
    if (score >= 85) return 'Excellent - Ready for production';
    if (score >= 70) return 'Good - Should scan reliably';
    if (score >= 50) return 'Fair - May have scanning issues';
    return 'Poor - Not recommended for use';
  }
}
