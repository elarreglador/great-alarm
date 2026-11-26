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

    final landPaint = Paint()
      ..color = AppColors.land
      ..style = PaintingStyle.fill;
    for (final ring in land.rings) {
      canvas.drawPath(_buildPath(ring, size), landPaint);
    }

    if (night.isNotEmpty) {
      canvas.drawPath(
        _buildPath(night, size),
        Paint()..color = AppColors.night..style = PaintingStyle.fill,
      );
    }
  }

  /// Rompe el trazo cuando la longitud salta más de 180° (antimeridiano),
  /// evitando la clásica raya diagonal de un polo al otro.
  Path _buildPath(List<GeoPoint> points, Size size) {
    final path = Path();
    if (points.isEmpty) return path;

    var previous = points.first;
    var current = project(previous, size);
    path.moveTo(current.dx, current.dy);

    for (var i = 1; i < points.length; i++) {
      final point = points[i];
      if ((point.longitude - previous.longitude).abs() > 180) {
        path.close();
        current = project(point, size);
        path.moveTo(current.dx, current.dy);
      } else {
        current = project(point, size);
        path.lineTo(current.dx, current.dy);
      }
      previous = point;
    }
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(covariant WorldMapPainter oldDelegate) =>
      oldDelegate.land != land || oldDelegate.night != night;
}
