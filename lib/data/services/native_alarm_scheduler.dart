import 'dart:convert';

import 'package:flutter/services.dart';

import '../../domain/entities/alarm.dart';
import '../../domain/entities/ringing_state.dart';
import '../../domain/services/alarm_calculator.dart';

/// Programa AlarmManager nativo y consulta el estado del timbre en curso.
class NativeAlarmScheduler {
  static const _channel = MethodChannel('eu.elarreglador.great_alarm/native');

  const NativeAlarmScheduler();

  /// Guarda el horario y lo reprograma en el lado nativo.
  Future<void> sync(List<Alarm> alarms, DateTime now) async {
    final specs = <Map<String, dynamic>>[];
    for (final alarm in alarms) {
      if (!alarm.enabled) continue;
      if (alarm.isRepeating) {
        for (final weekday in alarm.weekdays) {
          final moment = AlarmCalculator.nextWeekday(alarm, weekday, now);
          if (moment == null) continue;
          specs.add(_spec(alarm, moment, weekday));
        }
      } else {
        final moment = AlarmCalculator.nextOccurrence(alarm, now);
        if (moment == null) continue;
        specs.add(_spec(alarm, moment, 0));
      }
    }
    await _channel.invokeMethod<void>('saveSchedule', jsonEncode(specs));
  }

  Map<String, dynamic> _spec(Alarm alarm, DateTime moment, int weekday) =>
      <String, dynamic>{
        'alarmId': alarm.id,
        'notificationId': AlarmCalculator.notificationKey(alarm.id, weekday),
        'triggerMillis': moment.millisecondsSinceEpoch,
        'label': alarm.label,
        'toneHz': alarm.toneHz ?? 0,
        'vibrate': alarm.vibrate,
      };

  Future<RingingState?> current() async {
    final raw = await _channel.invokeMethod<String>('isRinging');
    if (raw == null || raw.isEmpty) return null;
    return RingingState.fromJson(
      Map<String, dynamic>.from(jsonDecode(raw) as Map),
    );
  }

  Future<void> stop() => _channel.invokeMethod<void>('stopRinging');
}
