import 'package:flutter/services.dart';

/// Lee el identificador IANA de la zona horaria del dispositivo (p. ej.
/// `Europe/Paris`) mediante un canal nativo de Android, sin plugins extra.
class DeviceTimezoneService {
  static const _channel = MethodChannel('eu.elarreglador.great_alarm/timezone');

  const DeviceTimezoneService();

  Future<String> read() async {
    try {
      final value = await _channel.invokeMethod<String>('getTimezoneId');
      if (value != null && value.isNotEmpty) return value;
    } on PlatformException {
      // Dispositivo sin el canal: seguimos con la zona por defecto.
    }
    return 'UTC';
  }
}
