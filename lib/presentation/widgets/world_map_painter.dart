import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../data/models/land_geometry.dart';
import '../../domain/entities/geo_point.dart';
import '../../utils/app_colors.dart';

/// Dibuja el mapamundi: agua azul casi negro, tierra gris y sombra negra.
///
/// Proyección Mercator recortada a ±85.05°, la misma que usa el cálculo del
/// terminador solar, para que la franja nocturna encaje con los continentes.
class WorldMapPainter extends CustomPainter {
  final LandGeometry land;
  final List<GeoPoint> night;

  const WorldMapPainter({required this.land, required this.night});

  static const double _maxLat = 85.05112878;

  static Offset project(GeoPoint point, Size size) {
    final lat = point.latitude.clamp(-_maxLat, _maxLat) * math.pi / 180.0;
    final mercatorY = math.log((1 + math.sin(lat)) / (1 - math.sin(lat)));
    return Offset(
      (point.longitude + 180.0) / 360.0 * size.width,
      (0.5 - mercatorY / (4 * math.pi)) * size.height,
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
      Offset.zero & size,
      Paint()..color = AppColors.water,
    );

    // Los anillos que cruzan el antimeridiano se desbobinan a longitudes
    // continuas y se recortan al lienzo. Partir el trazo en el salto cerraba
    // el polígono a escondidas y dibujaba diagonales desde las esquinas.
    canvas.save();
    canvas.clipRect(Offset.zero & size);

    final landPaint = Paint()
      ..color = AppColors.land
      ..style = PaintingStyle.fill;
    for (final ring in land.rings) {
      _drawWrapped(canvas, _buildPath(ring, size), landPaint, size.width);
    }

    if (night.isNotEmpty) {
      _drawWrapped(
        canvas,
        _buildPath(night, size),
        Paint()..color = AppColors.night..style = PaintingStyle.fill,
        size.width,
      );
    }

    canvas.restore();
  }

  /// Dibuja el mismo contorno en las tres vueltas del mundo para que cloques
  /// lo que quede a un lado del antimeridiano aparezca por el otro.
  void _drawWrapped(Canvas canvas, Path path, Paint paint, double width) {
    // Un píxel de solape evita la costura antiparalela entre copias.
    for (final shift in <double>[-width + 1, 0, width - 1]) {
      canvas.save();
      canvas.translate(shift, 0);
      canvas.drawPath(path, paint);
      canvas.restore();
    }
  }

  /// Construye el trazo con longitudes continuas (sin saltos de 360°).
  ///
  /// Los anillos polares que dan la vuelta al mundo no se cierran con una
  /// cuerda entre costa y costa: bajan (o suben) por el borde del polo, que es
  /// lo que evita la línea recta que partía el mapa en dos.
  Path _buildPath(List<GeoPoint> points, Size size) {
    final path = Path();
    if (points.isEmpty) return path;

    var shift = 0.0;
    var wrapped = false;
    var previous = points.first.longitude;
    var current = project(GeoPoint(points.first.latitude, previous), size);
    path.moveTo(current.dx, current.dy);

    for (var i = 1; i < points.length; i++) {
      final point = points[i];
      var longitude = point.longitude + shift;
      if ((longitude - previous).abs() > 180) {
        wrapped = true;
        shift += longitude > previous ? -360 : 360;
        longitude = point.longitude + shift;
      }
      current = project(GeoPoint(point.latitude, longitude), size);
      path.lineTo(current.dx, current.dy);
      previous = longitude;
    }

    if (wrapped) {
      final meanLat = points.map((p) => p.latitude).reduce((a, b) => a + b) /
          points.length;
      final poleLat = meanLat < 0 ? -_maxLat : _maxLat;
      final firstLongitude = points.first.longitude;
      final steps = ((previous - firstLongitude).abs() / 5).round();
      for (var i = 1; i <= steps; i++) {
        final longitude = previous + (firstLongitude - previous) * i / steps;
        current = project(GeoPoint(poleLat, longitude), size);
        path.lineTo(current.dx, current.dy);
      }
    }

    path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant WorldMapPainter oldDelegate) =>
      oldDelegate.land != land || oldDelegate.night != night;
}
