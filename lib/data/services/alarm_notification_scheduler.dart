import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../../domain/entities/alarm.dart';
import '../../domain/services/alarm_calculator.dart';

/// Programa las alarmas en el AlarmManager de Android para que suenen
/// aunque la aplicación esté cerrada.
class AlarmNotificationScheduler {
  static const _channelId = 'great_alarm';
  static const _channelName = 'Despertador';
  static const _channelDescription = 'Avisos de las alarmas programadas';

  final FlutterLocalNotificationsPlugin _plugin;

  AlarmNotificationScheduler(this._plugin);

  AndroidFlutterLocalNotificationsPlugin? get _android =>
      _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

  Future<void> initialize(String timeZoneId) async {
    tz_data.initializeTimeZones();
    try {
      tz.setLocalLocation(tz.getLocation(timeZoneId));
    } catch (_) {
      // Zona desconocida: GMT sigue siendo una referencia válida.
    }

    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
    );

    await _android?.requestNotificationsPermission();
    await _android?.requestExactAlarmsPermission();
  }

  /// Reprograma todas las alarmas activas. Se llama tras cada cambio.
  Future<void> sync(List<Alarm> alarms, DateTime now) async {
    await _android?.cancelAllPendingNotifications();
    for (final alarm in alarms) {
      if (!alarm.enabled) continue;
      if (alarm.isRepeating) {
        for (final weekday in alarm.weekdays) {
          final moment = AlarmCalculator.nextWeekday(alarm, weekday, now);
          if (moment == null) continue;
          await _schedule(
            id: notificationId(alarm.id, weekday),
            alarm: alarm,
            moment: moment,
            match: DateTimeComponents.dayOfWeekAndTime,
          );
        }
      } else {
        final moment = AlarmCalculator.nextOccurrence(alarm, now);
        if (moment == null) continue;
        await _schedule(
          id: notificationId(alarm.id, 0),
          alarm: alarm,
          moment: moment,
        );
      }
    }
  }

  /// Un id distinto por alarma y día de la semana evita que un aviso
  /// semanal sobrescriba a otro.
  static int notificationId(int alarmId, int weekday) => alarmId * 10 + weekday;

  Future<void> _schedule({
    required int id,
    required Alarm alarm,
    required DateTime moment,
    DateTimeComponents? match,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.max,
      priority: Priority.max,
      category: AndroidNotificationCategory.alarm,
      audioAttributesUsage: AudioAttributesUsage.alarm,
      sound: RawResourceAndroidNotificationSound('alarm'),
      playSound: true,
      enableVibration: true,
      ticker: 'Alarma',
    );
    await _plugin.zonedSchedule(
      id: id,
      title: alarm.label,
      body: 'Sonó a las ${_two(alarm.hour)}:${_two(alarm.minute)}',
      payload: alarm.id.toString(),
      scheduledDate: tz.TZDateTime.from(moment, tz.local),
      notificationDetails: const NotificationDetails(android: androidDetails),
      androidScheduleMode: AndroidScheduleMode.alarmClock,
      matchDateTimeComponents: match,
    );
  }

  static String _two(int value) => value.toString().padLeft(2, '0');
}
