import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:qr_studio/models/qr_config.dart';

class _QrPainter extends CustomPainter {
  final String data;
  final QRConfig config;

  _QrPainter(this.data, this.config);

  @override
  void paint(Canvas canvas, Size size) {
    try {
      final validationResult = QrValidator.validate(
        data: data,
        version: QrVersions.auto,
      );

      if (!validationResult.isValid || validationResult.qrCode == null) {
        return;
      }

      final qrImage = QrImage(validationResult.qrCode!);
      final moduleCount = qrImage.moduleCount;
      const quietZoneModules = 4;
      final moduleSize = size.shortestSide / (moduleCount + quietZoneModules * 2);
      final qrOffset = moduleSize * quietZoneModules;
      final detailOpacity = (0.45 + (config.patternDetail / 100) * 0.55)
          .clamp(0.0, 1.0);
      final darkPaint = Paint()
        ..color = config.foregroundColor.withValues(alpha: detailOpacity);

      canvas.drawRect(Offset.zero & size, Paint()..color = config.backgroundColor);

      for (var row = 0; row < moduleCount; row++) {
        for (var col = 0; col < moduleCount; col++) {
          if (!qrImage.isDark(row, col)) continue;

          final dotSize = moduleSize * config.dotFill.value;
          final left = qrOffset + col * moduleSize + (moduleSize - dotSize) / 2;
          final top = qrOffset + row * moduleSize + (moduleSize - dotSize) / 2;
          final rect = Rect.fromLTWH(left, top, dotSize, dotSize);

          switch (config.dotStyle) {
            case DotStyle.square:
              canvas.drawRect(rect, darkPaint);
              break;
            case DotStyle.circle:
              canvas.drawOval(rect, darkPaint);
              break;
            case DotStyle.diamond:
              final path = Path()
                ..moveTo(rect.center.dx, rect.top)
                ..lineTo(rect.right, rect.center.dy)
                ..lineTo(rect.center.dx, rect.bottom)
                ..lineTo(rect.left, rect.center.dy)
                ..close();
              canvas.drawPath(path, darkPaint);
              break;
            case DotStyle.rounded:
              canvas.drawRRect(
                RRect.fromRectAndRadius(rect, Radius.circular(dotSize * 0.28)),
                darkPaint,
              );
              break;
          }
        }
      }
    } catch (e) {
      debugPrint('QR Painter error: $e');
    }
  }

  @override
  bool shouldRepaint(_QrPainter oldDelegate) {
    return oldDelegate.data != data ||
        oldDelegate.config.size != config.size ||
        oldDelegate.config.patternDetail != config.patternDetail ||
        oldDelegate.config.dotStyle != config.dotStyle ||
        oldDelegate.config.dotFill != config.dotFill ||
        oldDelegate.config.foregroundColor != config.foregroundColor ||
        oldDelegate.config.backgroundColor != config.backgroundColor;
  }
}

class QRPreview extends StatelessWidget {
  final String qrValue;
  final QRConfig config;
  final bool showPreview;
  final GlobalKey? qrImageKey;

  const QRPreview({
    Key? key,
    required this.qrValue,
    required this.config,
    this.showPreview = true,
    this.qrImageKey,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          height: 360,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFE5E7EB), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: !showPreview || qrValue.isEmpty
              ? Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey[100],
                    ),
                    child: Icon(
                      Icons.qr_code_2,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    qrValue.isEmpty
                        ? 'Ready to generate'
                        : 'Create a QR code first',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[600],
                      letterSpacing: 0.2,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Fill in the content and click Generate QR',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey[500],
                      letterSpacing: 0.1,
                    ),
                    textAlign: TextAlign.center,
                  ),
            ],
          )
              : Center(
              child: RepaintBoundary(
                key: qrImageKey,
                child: ColoredBox(
                  color: config.backgroundColor,
                  child: SizedBox(
                    width: config.previewSize.toDouble(),
                    height: config.previewSize.toDouble(),
                    child: CustomPaint(
                      painter: _QrPainter(qrValue, config),
                      size: Size(
                        config.previewSize.toDouble(),
                        config.previewSize.toDouble(),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        if (showPreview && qrValue.isNotEmpty) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              border: Border.all(color: Colors.blue.shade200, width: 1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_rounded,
                  color: Colors.blue.shade700,
                  size: 18,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Preview: ${config.previewSize}px | Export: ${config.size}px',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue.shade700,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}
