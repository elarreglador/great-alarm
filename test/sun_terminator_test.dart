import 'package:flutter_test/flutter_test.dart';
import 'package:great_alarm/domain/services/sun_terminator_service.dart';

void main() {
  test('el punto subsolar se mantiene dentro de los trópicos', () {
    for (final day in <DateTime>[
      DateTime.utc(2026, 1, 1, 12),
      DateTime.utc(2026, 3, 20, 12),
      DateTime.utc(2026, 6, 21, 12),
      DateTime.utc(2026, 9, 23, 12),
      DateTime.utc(2026, 12, 21, 12),
    ]) {
      final point = SunTerminatorService.subsolarPoint(day);
      expect(point.latitude, greaterThanOrEqualTo(-23.5));
      expect(point.latitude, lessThanOrEqualTo(23.5));
      expect(point.longitude, greaterThanOrEqualTo(-180));
      expect(point.longitude, lessThanOrEqualTo(180));
    }
  });

  test('la sombra es un polígono cerrado y sin saltos de longitud', () {
    final polygon = SunTerminatorService.nightPolygon(
      DateTime.utc(2026, 6, 21, 12),
    );
    expect(polygon.length, 2 * 180 + 2);
    for (var i = 1; i < polygon.length; i++) {
      expect(
        (polygon[i].longitude - polygon[i - 1].longitude).abs(),
        lessThanOrEqualTo(180),
      );
      expect(
        polygon[i].latitude.abs(),
        lessThanOrEqualTo(SunTerminatorService.maxMercatorLat),
      );
    }
  });

  test('la sombra se desplaza hacia el oeste con las horas', () {
    final morning = SunTerminatorService.subsolarPoint(
      DateTime.utc(2026, 7, 1, 0),
    );
    final evening = SunTerminatorService.subsolarPoint(
      DateTime.utc(2026, 7, 1, 12),
    );
    // Doce horas después el punto subsolar está casi en la antípoda; la
    // diferencia se mide en el círculo de 360° para no tropezar con el envolvente.
    final delta = (evening.longitude - morning.longitude + 540) % 360 - 180;
    expect(delta, closeTo(-180, 1));
  });
}
