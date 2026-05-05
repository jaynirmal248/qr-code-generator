import 'package:flutter/material.dart';

class QRConfig {
  final int size; // 160 to 1000 pixels
  final int patternDetail; // 0-100, typically 25%, 50%, 75%, 100%
  final DotStyle dotStyle;
  final DotFill dotFill;
  final Color foregroundColor;
  final Color backgroundColor;

  QRConfig({
    this.size = 320,
    this.patternDetail = 100,
    this.dotStyle = DotStyle.square,
    this.dotFill = DotFill.fill100,
    this.foregroundColor = const Color(0xFF000000),
    this.backgroundColor = const Color(0xFFFFFFFF),
  });

  QRConfig copyWith({
    int? size,
    int? patternDetail,
    DotStyle? dotStyle,
    DotFill? dotFill,
    Color? foregroundColor,
    Color? backgroundColor,
  }) {
    return QRConfig(
      size: size ?? this.size,
      patternDetail: patternDetail ?? this.patternDetail,
      dotStyle: dotStyle ?? this.dotStyle,
      dotFill: dotFill ?? this.dotFill,
      foregroundColor: foregroundColor ?? this.foregroundColor,
      backgroundColor: backgroundColor ?? this.backgroundColor,
    );
  }

  int get previewSize => (size / 2).toInt(); // Smaller preview
}

enum DotStyle {
  square('Square'),
  circle('Circle'),
  diamond('Diamond'),
  rounded('Rounded');

  final String label;
  const DotStyle(this.label);
}

enum DotFill {
  fill55('55%', 0.55),
  fill90('90%', 0.90),
  fill100('100%', 1.0);

  final String label;
  final double value;
  const DotFill(this.label, this.value);
}

class QRQuality {
  final int scanabilityScore; // 0-100
  final List<String> warnings;
  final bool isSafe;

  QRQuality({
    required this.scanabilityScore,
    this.warnings = const [],
    this.isSafe = true,
  });

  String get statusMessage {
    if (scanabilityScore >= 85) return 'Excellent';
    if (scanabilityScore >= 70) return 'Good';
    if (scanabilityScore >= 50) return 'Fair';
    return 'Poor';
  }
}
