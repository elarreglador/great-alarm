import 'dart:convert';

import 'package:flutter/services.dart';

import '../../domain/entities/geo_point.dart';

/// Contornos costeros simplificados (Natural Earth 110m), en Memoria.
///
/// Se cargan una sola vez al arrancar: son 127 anillos y ~5000 vértices,
/// suficientes para un mapa de un tercio de pantalla.
class LandGeometry {
  final List<List<GeoPoint>> rings;

  const LandGeometry(this.rings);

  static Future<LandGeometry> load() async {
    final source = await rootBundle.loadString('assets/data/land.json');
    final decoded = json.decode(source) as Map<String, dynamic>;
    final rawRings = decoded['rings'] as List<dynamic>;
    final rings = rawRings.map((raw) {
      final points = raw as List<dynamic>;
      return points
          .map((p) => GeoPoint((p[1] as num).toDouble(), (p[0] as num).toDouble()))
          .toList(growable: false);
    }).toList(growable: false);
    return LandGeometry(rings);
  }
}
