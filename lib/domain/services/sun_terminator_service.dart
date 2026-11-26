import 'dart:math' as math;

import '../entities/geo_point.dart';

/// Cálculo del terminador solar (frontera día/noche) con fórmula NOAA.
///
/// Adaptado del servicio del proyecto «80 días: la herencia de Phoebe»:
/// misma declinación y mismo punto subsolar, pero sin depender de latlong2.
/// El resultado se dibuja con la misma proyección Mercator recortada a 85.05°.
class SunTerminatorService {
  const SunTerminatorService._();

  static const double degToRad = math.pi / 180.0;
  static const double maxMercatorLat = 85.05112878;

  static double _mod360(double value) {
    final result = value % 360.0;
    return result < 0 ? result + 360.0 : result;
  }

  static double _daysSinceJ2000(DateTime utc) {
    const j2000 = 2000;
    final epoch = DateTime.utc(j2000, 1, 1, 12).millisecondsSinceEpoch;
    return (utc.millisecondsSinceEpoch - epoch) / 86400000.0;
  }

  /// Latitud declinación y longitud del punto donde el Sol está en el cenit.
  static GeoPoint subsolarPoint(DateTime utc) {
    final n = _daysSinceJ2000(utc);
    final lDeg = _mod360(280.460 + 0.9856474 * n);
    final gRad = _mod360(357.528 + 0.9856003 * n) * degToRad;
    final lambdaRad =
        (lDeg + 1.915 * math.sin(gRad) + 0.020 * math.sin(2 * gRad)) *
            degToRad;
    final epsilonRad = (23.439 - 0.0000004 * n) * degToRad;

    final alphaRad = math.atan2(
      math.cos(epsilonRad) * math.sin(lambdaRad),
      math.cos(lambdaRad),
    );
    final declRad = math.asin(math.sin(epsilonRad) * math.sin(lambdaRad));
    final gmstDeg = _mod360(280.46061837 + 360.98564736629 * n);

    var longitude = _mod360(alphaRad / degToRad) - gmstDeg;
    while (longitude > 180) {
      longitude -= 360;
    }
    while (longitude < -180) {
      longitude += 360;
    }

    return GeoPoint(declRad / degToRad, longitude);
  }

  /// Polígono de la zona nocturna, de [-180, 180] y vuelta por el polo oscuro.
  ///
  /// Un único polígono sin saltos de longitud: el painter lo rellena directamente.
  static List<GeoPoint> nightPolygon(DateTime utc, {double stepLng = 2.0}) {
    final subsolar = subsolarPoint(utc);
    final subLatRad = subsolar.latitude * degToRad;
    final tanSub = math.tan(subLatRad);
    final terminator = <GeoPoint>[];

    final steps = (360.0 / stepLng).round();
    for (var i = 0; i <= steps; i++) {
      final lng = (-180.0 + i * stepLng).clamp(-180.0, 180.0);
      final hRad = (lng - subsolar.longitude) * degToRad;
      final cosH = math.cos(hRad);
      double latDeg;
      if (tanSub.abs() < 1e-12) {
        latDeg = cosH > 0 ? -maxMercatorLat : maxMercatorLat;
      } else {
        latDeg = math.atan(-cosH / tanSub) / degToRad;
      }
      terminator.add(
        GeoPoint(latDeg.clamp(-maxMercatorLat, maxMercatorLat), lng),
      );
    }

    // El polo oscuro es el opuesto al punto subsolar.
    final poleLat =
        subsolar.latitude > 0 ? -maxMercatorLat : maxMercatorLat;
    final edge = <GeoPoint>[];
    for (var i = steps; i >= 0; i--) {
      edge.add(GeoPoint(poleLat, (-180.0 + i * stepLng).clamp(-180.0, 180.0)));
    }
    return <GeoPoint>[...terminator, ...edge];
  }
}
