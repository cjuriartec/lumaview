import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:lumaview/core/theme/app_theme.dart';

/// Utilidad para crear BitmapDescriptor de marcadores en el mapa.
///
/// E3-2: Define markers distintos para clusters (badge con count) y lugares
/// (pin clásico), con estilos coherentes al tema de la app.
class MapMarkerUtils {
  MapMarkerUtils._();

  static const int _iconSize = 64;

  static final Map<String, BitmapDescriptor> _clusterCache = {};
  static BitmapDescriptor? _placeLightCache;
  static BitmapDescriptor? _placeDarkCache;

  /// Marker de cluster: círculo con contador, claramente diferenciado del pin.
  /// Usa cache por (count, isDark) para evitar regenerar iconos.
  static Future<BitmapDescriptor> clusterDescriptor({
    required int count,
    required bool isDark,
  }) async {
    final key = '$count-$isDark';
    if (_clusterCache.containsKey(key)) {
      return _clusterCache[key]!;
    }
    final bytes = await _drawCluster(count: count, isDark: isDark);
    final descriptor = BitmapDescriptor.bytes(bytes);
    _clusterCache[key] = descriptor;
    return descriptor;
  }

  /// Marker de lugar individual: pin clásico (teardrop).
  /// Visualmente distinto del cluster para identificar lugares individuales.
  static Future<BitmapDescriptor> placeDescriptor({
    required bool isDark,
  }) async {
    if (isDark && _placeDarkCache != null) return _placeDarkCache!;
    if (!isDark && _placeLightCache != null) return _placeLightCache!;

    final bytes = await _drawPlace(isDark: isDark);
    final descriptor = BitmapDescriptor.bytes(bytes);
    if (isDark) {
      _placeDarkCache = descriptor;
    } else {
      _placeLightCache = descriptor;
    }
    return descriptor;
  }

  static Future<Uint8List> _drawCluster({
    required int count,
    required bool isDark,
  }) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    const size = 64.0;

    final primary = isDark ? AppTheme.darkPrimary : AppTheme.lightPrimary;
    final onPrimary = isDark ? AppTheme.lightOnSurface : Colors.white;

    final circlePaint = Paint()
      ..color = primary
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(size / 2, size / 2), size / 2 - 10, circlePaint);

    final displayCount = count > 999 ? '999+' : '$count';
    final textPainter = TextPainter(
      text: TextSpan(
        text: displayCount,
        style: TextStyle(
          color: onPrimary,
          fontSize: count > 99 ? 14 : 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset((size - textPainter.width) / 2, (size - textPainter.height) / 2),
    );

    final picture = recorder.endRecording();
    final image = await picture.toImage(_iconSize, _iconSize);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  /// Dibuja un pin clásico (teardrop) para lugar individual.
  /// Tamaño 64px para que no se corte en el contenedor del mapa.
  static Future<Uint8List> _drawPlace({required bool isDark}) async {
    const size = 64.0;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    final primary = isDark ? AppTheme.darkPrimary : AppTheme.lightPrimary;

    final pinPath = _createPinPath(size, 0, 0);
    final pinPaint = Paint()
      ..color = primary
      ..style = PaintingStyle.fill;
    canvas.drawPath(pinPath, pinPaint);

    final picture = recorder.endRecording();
    final image = await picture.toImage(_iconSize, _iconSize);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  /// Path del pin en forma de teardrop, ajustado a [size] para que no se corte.
  static Path _createPinPath(double size, double offsetX, double offsetY) {
    final cx = size / 2;
    final path = Path();
    path.moveTo(cx + offsetX, size - 2 + offsetY); // punta (anchor 0.5, 1.0)
    path.lineTo(cx + 14 + offsetX, 28 + offsetY);
    path.quadraticBezierTo(
      cx + 18 + offsetX,
      14 + offsetY,
      cx + offsetX,
      6 + offsetY,
    );
    path.quadraticBezierTo(
      cx - 18 + offsetX,
      14 + offsetY,
      cx - 14 + offsetX,
      28 + offsetY,
    );
    path.close();
    return path;
  }
}
