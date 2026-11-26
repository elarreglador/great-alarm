/// Despertador programado por el usuario.
///
/// [weekdays] usa 1 = lunes ... 7 = domingo. Vacío significa alarma de un
/// solo uso, cuya fecha se guarda en [date].
class Alarm {
  final int id;
  final String label;
  final int hour;
  final int minute;
  final Set<int> weekdays;
  final DateTime? date;
  final bool enabled;

  const Alarm({
    required this.id,
    required this.label,
    required this.hour,
    required this.minute,
    this.weekdays = const <int>{},
    this.date,
    this.enabled = true,
  });

  bool get isRepeating => weekdays.isNotEmpty;

  /// L,M,X,J,V,S,D en el orden natural de la semana.
  String get daysLabel {
    if (!isRepeating) {
      if (date == null) return 'una vez';
      return '${date!.day}/${date!.month}/${date!.year}';
    }
    const letters = <String>['', 'L', 'M', 'X', 'J', 'V', 'S', 'D'];
    final sorted = weekdays.toList()..sort();
    return sorted.map((d) => letters[d]).join(',');
  }

  Alarm copyWith({
    String? label,
    int? hour,
    int? minute,
    Set<int>? weekdays,
    DateTime? date,
    bool? enabled,
  }) {
    return Alarm(
      id: id,
      label: label ?? this.label,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      weekdays: weekdays ?? this.weekdays,
      date: date ?? this.date,
      enabled: enabled ?? this.enabled,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'id': id,
        'label': label,
        'hour': hour,
        'minute': minute,
        'weekdays': weekdays.toList()..sort(),
        'date': date?.toIso8601String(),
        'enabled': enabled,
      };

  factory Alarm.fromJson(Map<String, dynamic> json) {
    final rawDate = json['date'] as String?;
    return Alarm(
      id: json['id'] as int,
      label: json['label'] as String? ?? 'Alarma',
      hour: json['hour'] as int,
      minute: json['minute'] as int,
      weekdays: (json['weekdays'] as List<dynamic>? ?? const <dynamic>[])
          .map((e) => e as int)
          .toSet(),
      date: rawDate == null ? null : DateTime.parse(rawDate),
      enabled: json['enabled'] as bool? ?? true,
    );
  }
}
