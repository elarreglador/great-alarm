import '../entities/alarm.dart';

/// Cálculos puros sobre cuándo sonará una alarma. Sin reloj, sin UI, sin E/S.
class AlarmCalculator {
  const AlarmCalculator._();

  static const Duration window = Duration(days: 7);

  /// Próxima activación estrictamente posterior a [now], o null si ya pasó.
  static DateTime? nextOccurrence(Alarm alarm, DateTime now) {
    if (!alarm.isRepeating) {
      final date = alarm.date;
      if (date == null) return null;
      final moment = DateTime(
        date.year,
        date.month,
        date.day,
        alarm.hour,
        alarm.minute,
      );
      return moment.isAfter(now) ? moment : null;
    }

    for (var offset = 0; offset <= 7; offset++) {
      final day = DateTime(now.year, now.month, now.day + offset);
      if (!alarm.weekdays.contains(day.weekday)) continue;
      final moment = DateTime(
        day.year,
        day.month,
        day.day,
        alarm.hour,
        alarm.minute,
      );
      if (moment.isAfter(now)) return moment;
    }
    return null;
  }

  /// Próxima activación de un día concreto de la semana, después de [now].
  static DateTime? nextWeekday(Alarm alarm, int weekday, DateTime now) {
    for (var offset = 0; offset <= 7; offset++) {
      final day = DateTime(now.year, now.month, now.day + offset);
      if (day.weekday != weekday) continue;
      final moment = DateTime(
        day.year,
        day.month,
        day.day,
        alarm.hour,
        alarm.minute,
      );
      if (moment.isAfter(now)) return moment;
    }
    return null;
  }

  /// Parte llena de la barra: cuánto queda de la semana de ventana.
  static double remainingFraction(DateTime? next, DateTime now) {
    if (next == null) return 0;
    final remaining = next.difference(now);
    if (remaining.isNegative) return 0;
    return (remaining.inSeconds / window.inSeconds).clamp(0.0, 1.0);
  }

  /// «14 h 37 m», «3 d 2 h 52 m»... igual que en el boceto del README.
  static String formatRemaining(DateTime? next, DateTime now) {
    if (next == null) return 'ya sonó';
    var seconds = next.difference(now).inSeconds;
    if (seconds < 0) seconds = 0;
    final days = seconds ~/ 86400;
    seconds -= days * 86400;
    final hours = seconds ~/ 3600;
    seconds -= hours * 3600;
    final minutes = seconds ~/ 60;

    final parts = <String>[];
    if (days > 0) parts.add('$days d');
    if (hours > 0) parts.add('$hours h');
    parts.add('$minutes m');
    return parts.join(' ');
  }
}
