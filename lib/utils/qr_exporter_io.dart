import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class QRExporter {
  static const MethodChannel _downloadsChannel = MethodChannel(
    'qr_studio/downloads',
  );

  static Future<String?> exportQRCodeAsPNG(
    Uint8List imageData,
    String filename,
  ) async {
    try {
      final savedPath = await _downloadsChannel.invokeMethod<String>(
        'savePngToDownloads',
        {
          'bytes': imageData,
          'filename': '$filename.png',
        },
      );
      if (savedPath != null && savedPath.isNotEmpty) return savedPath;
    } catch (_) {
      // Fall through to a non-Android fallback for desktop/iOS builds.
    }

    try {
      final directory = await getDownloadsDirectory() ??
          await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$filename.png');
      await file.writeAsBytes(imageData, flush: true);
      return file.path;
    } catch (_) {
      return null;
    }
  }

  static Future<bool> shareQRCodeAsPNG(
    Uint8List imageData,
    String filename,
  ) async {
    try {
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/$filename.png');
      await file.writeAsBytes(imageData, flush: true);

      await Share.shareXFiles(
        [XFile(file.path, mimeType: 'image/png', name: '$filename.png')],
        text: 'QR Code',
      );
      return true;
    } catch (_) {
      return false;
    }
  }
}
