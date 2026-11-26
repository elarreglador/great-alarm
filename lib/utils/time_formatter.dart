/// Etiqueta legible para la hora local, derivada del id IANA de Android.
class TimezoneLabel {
  const TimezoneLabel._();

  static const _countries = <String, String>{
    'Europe/Paris': 'Francia',
    'Europe/London': 'Reino Unido',
    'Europe/Berlin': 'Alemania',
    'Europe/Madrid': 'España',
    'Europe/Rome': 'Italia',
    'Europe/Amsterdam': 'Países Bajos',
    'America/New_York': 'Estados Unidos',
    'America/Chicago': 'Estados Unidos',
    'America/Los_Angeles': 'Estados Unidos',
    'America/Mexico_City': 'México',
    'America/Sao_Paulo': 'Brasil',
    'America/Argentina/Buenos_Aires': 'Argentina',
    'Asia/Tokyo': 'Japón',
    'Asia/Shanghai': 'China',
    'Asia/Kolkata': 'India',
    'Australia/Sydney': 'Australia',
    'Pacific/Auckland': 'Nueva Zelanda',
  };

  /// «París (Francia)», «Madrid (España)», «Sydney (Australia)»...
  static String fromTimezoneId(String id) {
    final parts = id.split('/');
    final city = parts.last.replaceAll('_', ' ');
    final country = _countries[id] ?? (parts.length > 1 ? parts[1] : id);
    return '$city ($country)';
  }

  static String clock(DateTime value) =>
      '${_two(value.hour)}:${_two(value.minute)}:${_two(value.second)}';

  static String _two(int value) => value.toString().padLeft(2, '0');
}
