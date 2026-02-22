import 'dart:async';
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

  static const int _clusterIconSize = 64;
  static const int _placeIconSize = 160;

  static final Map<String, BitmapDescriptor> _clusterCache = {};
  static BitmapDescriptor? _placeLightCache;
  static BitmapDescriptor? _placeDarkCache;
  static final Map<String, BitmapDescriptor> _placePhotoCache = {};

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

  /// Marker de lugar individual: globo con opción de foto.
  /// Visualmente distinto del cluster para identificar lugares individuales.
  static Future<BitmapDescriptor> placeDescriptor({
    required bool isDark,
  }) async {
    if (isDark && _placeDarkCache != null) return _placeDarkCache!;
    if (!isDark && _placeLightCache != null) return _placeLightCache!;

    final bytes = await _drawPlaceBubble(isDark: isDark);
    final descriptor = BitmapDescriptor.bytes(bytes);
    if (isDark) {
      _placeDarkCache = descriptor;
    } else {
      _placeLightCache = descriptor;
    }
    return descriptor;
  }

  /// Marker de lugar con foto primaria desde URL remota.
  static Future<BitmapDescriptor> placePhotoDescriptor({
    required bool isDark,
    required String imageUrl,
  }) async {
    final key = '$imageUrl-$isDark';
    final cached = _placePhotoCache[key];
    if (cached != null) return cached;

    try {
      final image = await _loadNetworkImage(imageUrl);
      final bytes = await _drawPlaceBubble(isDark: isDark, image: image);
      final descriptor = BitmapDescriptor.bytes(bytes);
      _placePhotoCache[key] = descriptor;
      return descriptor;
    } catch (_) {
      return placeDescriptor(isDark: isDark);
    }
  }

  /// Versión testable que recibe una imagen ya cargada.
  static Future<BitmapDescriptor> placeDescriptorWithImage({
    required bool isDark,
    required ui.Image image,
  }) async {
    final bytes = await _drawPlaceBubble(isDark: isDark, image: image);
    return BitmapDescriptor.bytes(bytes);
  }

  static Future<Uint8List> _drawCluster({
    required int count,
    required bool isDark,
  }) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final double size = _clusterIconSize.toDouble();

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
    final image = await picture.toImage(_clusterIconSize, _clusterIconSize);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  /// Dibuja un globo para lugar individual, opcionalmente con imagen circular.
  /// Tamaño 64px para que no se corte en el contenedor del mapa.
  static Future<Uint8List> _drawPlaceBubble({
    required bool isDark,
    ui.Image? image,
  }) async {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final double size = _placeIconSize.toDouble();

    final primary = isDark ? AppTheme.darkPrimary : AppTheme.lightPrimary;

    final center = Offset(size / 2, size / 2 - 14);
    const double radius = 40.0;

    // Base circular (para fallback sin imagen)
    final bubbleRect = Rect.fromCircle(center: center, radius: radius);
    final bubbleRRect = RRect.fromRectAndRadius(
      bubbleRect,
      const Radius.circular(radius),
    );
    final bubblePath = Path()..addRRect(bubbleRRect);

    final bubblePaint = Paint()
      ..color = primary
      ..style = PaintingStyle.fill;
    // Sólo dibujamos el círculo de color si no hay imagen;
    // cuando hay foto, la burbuja será básicamente la foto con borde y sombra.
    if (image == null) {
      canvas.drawPath(bubblePath, bubblePaint);
    }

    // Sombra suave alrededor de la burbuja/foto
    final shadowPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.22)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(center.translate(0, 2), radius - 2, shadowPaint);

    // Imagen circular recortada dentro del globo (si existe)
    if (image != null) {
      final double clipRadius = radius - 6;
      final clipRect = Rect.fromCircle(center: center, radius: clipRadius);
      final clipPath = Path()
        ..addRRect(
          RRect.fromRectAndRadius(clipRect, Radius.circular(clipRadius)),
        );

      canvas.save();
      canvas.clipPath(clipPath);

      final dstRect = clipRect;
      paintImage(
        canvas: canvas,
        rect: dstRect,
        image: image,
        fit: BoxFit.cover,
      );

      canvas.restore();

      final borderPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.0;
      canvas.drawCircle(center, clipRadius - 1.0, borderPaint);
    }

    final picture = recorder.endRecording();
    final markerImage = await picture.toImage(_placeIconSize, _placeIconSize);
    final byteData = await markerImage.toByteData(
      format: ui.ImageByteFormat.png,
    );
    return byteData!.buffer.asUint8List();
  }

  static Future<ui.Image> _loadNetworkImage(String url) async {
    final completer = Completer<ui.Image>();
    final imageProvider = NetworkImage(url);
    final stream = imageProvider.resolve(ImageConfiguration());

    late ImageStreamListener listener;
    listener = ImageStreamListener(
      (ImageInfo info, bool synchronousCall) {
        completer.complete(info.image);
        stream.removeListener(listener);
      },
      onError: (Object error, StackTrace? stackTrace) {
        completer.completeError(Exception('Failed to load image'));
        stream.removeListener(listener);
      },
    );

    stream.addListener(listener);
    return completer.future;
  }
}
