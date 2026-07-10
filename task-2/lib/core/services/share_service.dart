import 'dart:ui' as ui;
import 'dart:io';
import 'package:flutter/rendering.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ShareService {
  Future<void> shareQuoteImage(GlobalKey repaintBoundaryKey) async {
    try {
      final boundary = repaintBoundaryKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData?.buffer.asUint8List();

      if (pngBytes != null) {
        // Use XFile.fromData which works on Web and Mobile natively without path_provider
        final xFile = XFile.fromData(
          pngBytes,
          mimeType: 'image/png',
          name: 'aura_quote.png',
        );
        
        await Share.shareXFiles([xFile], text: 'Check out this quote from Quotiva!');
      }
    } catch (e) {
      debugPrint('Error sharing image: $e');
      throw Exception('Failed to share: $e');
    }
  }
}
