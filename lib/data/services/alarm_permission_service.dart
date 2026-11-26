import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Pide los permisos que necesita la alarma: notificaciones, alarmas exactas,
/// acceso a «No molestar» y pantalla completa en bloqueo.
class AlarmPermissionService {
  final FlutterLocalNotificationsPlugin _plugin;

  const AlarmPermissionService(this._plugin);

  static const _askedKey = 'great_alarm.special_permissions_asked.v1';

  AndroidFlutterLocalNotificationsPlugin? get _android =>
      _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

  Future<void> initialize() async {
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
    );
    await _android?.requestNotificationsPermission();
    await _android?.requestExactAlarmsPermission();

    // Estos dos permisos abren Ajustes del sistema: solo se piden una vez.
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(_askedKey) ?? false) return;
    await _android?.requestNotificationPolicyAccess();
    await _android?.requestFullScreenIntentPermission();
    await prefs.setBool(_askedKey, true);
  }
}
