import 'tone_option.dart';

/// Estado de la alarma que está sonando ahora mismo en el teléfono.
class RingingState {
  final int alarmId;
  final String label;
  final int toneHz;
  final bool vibrate;
  final DateTime startedAt;

  const RingingState({
    required this.alarmId,
    required this.label,
    required this.toneHz,
    required this.vibrate,
    required this.startedAt,
  });

  factory RingingState.fromJson(Map<String, dynamic> json) => RingingState(
        alarmId: json['alarmId'] as int,
        label: json['label'] as String? ?? 'Alarma',
        toneHz: json['toneHz'] as int? ?? 700,
        vibrate: json['vibrate'] as bool? ?? false,
        startedAt: DateTime.fromMillisecondsSinceEpoch(
          json['startedAt'] as int,
        ),
      );

  /// Tiempo que falta para el corte automático a los 5 minutos.
  Duration remaining(DateTime now) {
    final elapsed = now.difference(startedAt);
    if (elapsed.isNegative) return ringingLimit;
    final left = ringingLimit - elapsed;
    return left.isNegative ? Duration.zero : left;
  }
}
