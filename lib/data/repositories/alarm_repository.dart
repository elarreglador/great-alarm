import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/alarm.dart';

/// Guarda las alarmas como JSON en las preferencias del dispositivo.
class AlarmRepository {
  static const _key = 'great_alarm.alarms.v1';

  const AlarmRepository();

  /// True cuando el usuario ya guardó (o borró) alarmas al menos una vez.
  Future<bool> hasStoredAlarms() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey(_key);
  }

  Future<List<Alarm>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? const <String>[];
    return raw
        .map(
          (item) => Alarm.fromJson(
            Map<String, dynamic>.from(jsonDecode(item) as Map),
          ),
        )
        .toList();
  }

  Future<void> save(List<Alarm> alarms) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _key,
      alarms.map((a) => jsonEncode(a.toJson())).toList(growable: false),
    );
  }
}
