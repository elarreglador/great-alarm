import 'package:flutter_test/flutter_test.dart';
import 'package:great_alarm/domain/entities/alarm.dart';
import 'package:great_alarm/domain/services/alarm_calculator.dart';

void main() {
  // Miércoles 19:52:08, el instante del boceto del README.
  final now = DateTime(2026, 2, 18, 19, 52, 8);

  final weekdays = Alarm(
    id: 1,
    label: 'cafetería con amigos',
    hour: 10,
    minute: 30,
    weekdays: const <int>{1, 2, 3, 4, 5},
  );
  final weekend = Alarm(
    id: 2,
    label: 'ir a dormir',
    hour: 22,
    minute: 45,
    weekdays: const <int>{6, 7},
  );

  test('la alarma de lunes a viernes salta al jueves', () {
    expect(
      AlarmCalculator.nextOccurrence(weekdays, now),
      DateTime(2026, 2, 19, 10, 30),
    );
    expect(
      AlarmCalculator.formatRemaining(
        AlarmCalculator.nextOccurrence(weekdays, now),
        now,
      ),
      '14 h 37 m',
    );
  });

  test('la alarma de fin de semana salta al sábado', () {
    expect(
      AlarmCalculator.nextOccurrence(weekend, now),
      DateTime(2026, 2, 21, 22, 45),
    );
    expect(
      AlarmCalculator.formatRemaining(
        AlarmCalculator.nextOccurrence(weekend, now),
        now,
      ),
      '3 d 2 h 52 m',
    );
  });

  test('la barra crece con el tiempo restante y se vacía al sonar', () {
    final near = AlarmCalculator.nextOccurrence(weekdays, now)!;
    final far = AlarmCalculator.nextOccurrence(weekend, now)!;
    expect(
      AlarmCalculator.remainingFraction(far, now),
      greaterThan(AlarmCalculator.remainingFraction(near, now)),
    );
    expect(
      AlarmCalculator.remainingFraction(near, near),
      0,
    );
    expect(AlarmCalculator.remainingFraction(null, now), 0);
  });

  test('la lista se ordena por próxima activación', () {
    final sorted = AlarmCalculator.sortByNext(
      <Alarm>[weekend, weekdays],
      now,
    );
    expect(sorted.map((a) => a.id), <int>[1, 2]);
  });

  test('una alarma de un solo uso vencida no tiene próxima activación', () {
    final once = Alarm(
      id: 3,
      label: 'vuelo',
      hour: 6,
      minute: 0,
      date: DateTime(2026, 2, 17),
    );
    expect(AlarmCalculator.nextOccurrence(once, now), isNull);
  });
}
