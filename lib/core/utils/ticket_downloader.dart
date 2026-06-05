import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:image_gallery_saver_plus/image_gallery_saver_plus.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:screenshot/screenshot.dart';

class TicketDownloader {
  /// Captures the widget inside [controller] and saves it to the device gallery.
  /// Returns true on success, false on failure.
  static Future<bool> downloadFromController(
    ScreenshotController controller, {
    String fileName = 'GoalZone_Ticket',
  }) async {
    try {
      final Uint8List? bytes = await controller.capture(pixelRatio: 3.0);
      if (bytes == null) return false;
      return await _saveToGallery(bytes, fileName);
    } catch (e) {
      debugPrint('TicketDownloader.downloadFromController error: $e');
      return false;
    }
  }

  /// Renders a self-contained ticket image with QR code + booking details
  /// and saves it directly to the device gallery (no widget capture needed).
  static Future<bool> renderAndDownload({
    required String qrData,
    required String stadiumName,
    required String date,
    required String time,
    required String location,
    required String totalPrice,
    required String sport,
    String fileName = 'GoalZone_Ticket',
  }) async {
    try {
      final Uint8List bytes = await _renderTicketImage(
        qrData: qrData,
        stadiumName: stadiumName,
        date: date,
        time: time,
        location: location,
        totalPrice: totalPrice,
        sport: sport,
      );
      return await _saveToGallery(bytes, fileName);
    } catch (e) {
      debugPrint('TicketDownloader.renderAndDownload error: $e');
      return false;
    }
  }

  // ─── Private helpers ─────────────────────────────────────────────────────────

  static Future<bool> _saveToGallery(
      Uint8List bytes, String fileName) async {
    try {
      final result = await ImageGallerySaverPlus.saveImage(
        bytes,
        quality: 100,
        name: '${fileName}_${DateTime.now().millisecondsSinceEpoch}',
      );
      final bool success = result != null &&
          result['isSuccess'] == true;
      return success;
    } catch (e) {
      debugPrint('TicketDownloader._saveToGallery error: $e');
      return false;
    }
  }

  static Future<Uint8List> _renderTicketImage({
    required String qrData,
    required String stadiumName,
    required String date,
    required String time,
    required String location,
    required String totalPrice,
    required String sport,
  }) async {
    const double width = 800;
    const double qrSize = 220.0;

    // --- Paint helpers ---
    final bgPaint = Paint()..color = const Color(0xFF1A1A2E);
    final cardPaint = Paint()..color = const Color(0xFF2C2C2C);
    final accentPaint = Paint()..color = const Color(0xFF4CAF50);
    final dividerPaint = Paint()
      ..color = const Color(0xFF444444)
      ..strokeWidth = 1;
    final qrBgPaint = Paint()..color = Colors.white;

    // Render QR to image
    final qrPainter = QrPainter(
      data: qrData.isEmpty || qrData == 'NO_QR' ? 'GOALZONE' : qrData,
      version: QrVersions.auto,
      errorCorrectionLevel: QrErrorCorrectLevel.H,
      eyeStyle: const QrEyeStyle(
        eyeShape: QrEyeShape.square,
        color: Color(0xFF000000),
      ),
      dataModuleStyle: const QrDataModuleStyle(
        dataModuleShape: QrDataModuleShape.square,
        color: Color(0xFF000000),
      ),
    );
    final qrUiImage = await qrPainter.toImage(qrSize);
    final qrByteData =
        await qrUiImage.toByteData(format: ui.ImageByteFormat.png);

    // Calculate height
    const double headerH = 160;
    const double padding = 40;
    const double pillH = 36;
    const double nameH = 60;
    const double divH = 20;
    const double rowH = 50;
    const double qrAreaH = qrSize + 80;
    const double footerH = 80;
    const double totalH =
        headerH + padding + pillH + nameH + divH + rowH * 3 + divH + rowH + divH + qrAreaH + footerH;

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, width, totalH));

    // --- Background ---
    canvas.drawRect(Rect.fromLTWH(0, 0, width, totalH), bgPaint);

    // --- Header gradient band ---
    final headerPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF4CAF50), Color(0xFF1B5E20)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, width, headerH));
    canvas.drawRect(Rect.fromLTWH(0, 0, width, headerH), headerPaint);

    // --- Header logo text ---
    _drawText(
      canvas,
      '⚽  GOAL ZONE',
      Offset(width / 2, 48),
      const TextStyle(
        color: Colors.white,
        fontSize: 36,
        fontWeight: FontWeight.w900,
        letterSpacing: 4,
      ),
      width,
      textAlign: TextAlign.center,
    );
    _drawText(
      canvas,
      'BOOKING TICKET',
      Offset(width / 2, 100),
      const TextStyle(
        color: Color(0xCCFFFFFF),
        fontSize: 18,
        letterSpacing: 6,
      ),
      width,
      textAlign: TextAlign.center,
    );

    // --- Card body ---
    const double cardTop = headerH - 20;
    final cardRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(padding, cardTop, width - padding * 2, totalH - cardTop - padding),
      const Radius.circular(20),
    );
    canvas.drawRRect(cardRect, cardPaint);

    double y = cardTop + 30;

    // Sport pill
    final pillRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(width / 2 - 70, y, 140, pillH),
      const Radius.circular(18),
    );
    canvas.drawRRect(pillRect, accentPaint);
    _drawText(
      canvas,
      sport.toUpperCase(),
      Offset(width / 2, y + pillH / 2 - 2),
      const TextStyle(
        color: Colors.white,
        fontSize: 14,
        fontWeight: FontWeight.bold,
        letterSpacing: 2,
      ),
      width,
      textAlign: TextAlign.center,
    );
    y += pillH + 16;

    // Stadium name
    _drawText(
      canvas,
      stadiumName,
      Offset(width / 2, y),
      const TextStyle(
        color: Colors.white,
        fontSize: 28,
        fontWeight: FontWeight.bold,
      ),
      width - padding * 2,
      textAlign: TextAlign.center,
    );
    y += nameH;

    // Divider
    canvas.drawLine(
      Offset(padding + 20, y),
      Offset(width - padding - 20, y),
      dividerPaint,
    );
    y += divH;

    // Detail rows
    y = _drawDetailRow(canvas, '📅', 'Date', date, y, width, padding);
    y = _drawDetailRow(canvas, '🕐', 'Time', time, y, width, padding);
    y = _drawDetailRow(canvas, '📍', 'Location', location, y, width, padding);

    // Divider
    canvas.drawLine(
      Offset(padding + 20, y),
      Offset(width - padding - 20, y),
      dividerPaint,
    );
    y += divH;

    // Price row
    _drawText(
      canvas,
      'Total Paid',
      Offset(padding + 40, y + 10),
      const TextStyle(
        color: Color(0xFFCCCCCC),
        fontSize: 18,
      ),
      200,
    );
    _drawText(
      canvas,
      totalPrice,
      Offset(width - padding - 40, y + 10),
      const TextStyle(
        color: Color(0xFF4CAF50),
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
      200,
      textAlign: TextAlign.right,
    );
    y += rowH;

    // Divider
    canvas.drawLine(
      Offset(padding + 20, y),
      Offset(width - padding - 20, y),
      dividerPaint,
    );
    y += divH;

    // --- QR Code ---
    if (qrByteData != null) {
      final codec = await ui.instantiateImageCodec(
        qrByteData.buffer.asUint8List(),
      );
      final frame = await codec.getNextFrame();
      final qrImage = frame.image;

      // White background
      const double qrPad = 16;
      final qrBgRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          width / 2 - qrSize / 2 - qrPad,
          y + 16,
          qrSize + qrPad * 2,
          qrSize + qrPad * 2,
        ),
        const Radius.circular(12),
      );
      canvas.drawRRect(qrBgRect, qrBgPaint);

      // QR image
      paintImage(
        canvas: canvas,
        rect: Rect.fromLTWH(width / 2 - qrSize / 2, y + 16 + qrPad,
            qrSize, qrSize),
        image: qrImage,
        fit: BoxFit.contain,
      );
    }
    y += qrSize + 60;

    // --- Footer ---
    _drawText(
      canvas,
      'goalzone.app  •  Scan QR at entrance',
      Offset(width / 2, y + 16),
      const TextStyle(
        color: Color(0xFF888888),
        fontSize: 14,
        letterSpacing: 1,
      ),
      width,
      textAlign: TextAlign.center,
    );

    // Convert to image
    final picture = recorder.endRecording();
    final img = await picture.toImage(width.toInt(), totalH.toInt());
    final byteData = await img.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  static double _drawDetailRow(Canvas canvas, String emoji, String label,
      String value, double y, double width, double padding) {
    _drawText(
      canvas,
      '$emoji  $label',
      Offset(padding + 40, y + 10),
      const TextStyle(color: Color(0xFFAAAAAA), fontSize: 16),
      200,
    );
    _drawText(
      canvas,
      value,
      Offset(width - padding - 40, y + 10),
      const TextStyle(
          color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
      280,
      textAlign: TextAlign.right,
    );
    return y + 50.0;
  }

  static void _drawText(
    Canvas canvas,
    String text,
    Offset offset,
    TextStyle style,
    double maxWidth, {
    TextAlign textAlign = TextAlign.left,
  }) {
    final tp = TextPainter(
      text: TextSpan(text: text, style: style),
      textAlign: textAlign,
      textDirection: TextDirection.ltr,
      maxLines: 2,
    );
    tp.layout(maxWidth: maxWidth);
    double dx = offset.dx;
    if (textAlign == TextAlign.center) {
      dx = offset.dx - tp.width / 2;
    } else if (textAlign == TextAlign.right) {
      dx = offset.dx - tp.width;
    }
    tp.paint(canvas, Offset(dx, offset.dy));
  }
}
