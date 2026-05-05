// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:typed_data';
// ignore: deprecated_member_use
import 'dart:html' as html;

class QRExporter {
  static Future<String?> exportQRCodeAsPNG(
    Uint8List imageData,
    String filename,
  ) async {
    try {
      final blob = html.Blob([imageData], 'image/png');
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.document.createElement('a') as html.AnchorElement
        ..href = url
        ..style.display = 'none'
        ..download = '$filename.png';

      html.document.body?.children.add(anchor);
      anchor.click();
      html.document.body?.children.remove(anchor);
      html.Url.revokeObjectUrl(url);
      return '$filename.png';
    } catch (_) {
      return null;
    }
  }

  static Future<bool> shareQRCodeAsPNG(
    Uint8List imageData,
    String filename,
  ) async {
    return await exportQRCodeAsPNG(imageData, filename) != null;
  }
}
