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
  /// Frecuencia del zumbido pulsado; null = alarma silenciosa.
  final int? toneHz;
  final bool vibrate;

  const Alarm({
    required this.id,
    required this.label,
    required this.hour,
    required this.minute,
    this.weekdays = const <int>{},
    this.date,
    this.enabled = true,
    this.toneHz = 700,
    this.vibrate = false,
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
    bool? vibrate,
    bool clearTone = false,
  }) {
    return Alarm(
      id: id,
      label: label ?? this.label,
      hour: hour ?? this.hour,
      minute: minute ?? this.minute,
      weekdays: weekdays ?? this.weekdays,
      date: date ?? this.date,
      enabled: enabled ?? this.enabled,
      toneHz: clearTone ? null : toneHz,
      vibrate: vibrate ?? this.vibrate,
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
        'toneHz': toneHz,
        'vibrate': vibrate,
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
      toneHz: json['toneHz'] as int? ?? 700,
      vibrate: json['vibrate'] as bool? ?? false,
    );
  }
}
