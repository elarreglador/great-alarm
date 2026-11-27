# AGENTS.md — Great Alarm

Despertador Android en Flutter, siempre en horizontal. Dos tercios de pantalla
para alarmas y un tercio para el mapamundi día/noche con relojes GMT y local.

## Estructura (Package by Layer)

- `lib/domain/` — entidades (`Alarm`, `GeoPoint`, `ToneOption`, `RingingState`)
  y lógica pura (`AlarmCalculator`, `SunTerminatorService`). Sin Flutter, sin E/S.
- `lib/data/` — persistencia (`AlarmRepository`), permisos
  (`AlarmPermissionService`), programación nativa (`NativeAlarmScheduler`) y
  zona horaria del dispositivo (en `MainActivity.kt`).
- `lib/presentation/` — única pantalla (`HomePage`) y widgets por
  responsabilidad: `AlarmPanel`, `AlarmTile`, `AddAlarmSheet`, `WorldMapPanel`,
  `WorldMapPainter`, `DigitalClock`, `RingingPanel`.
- `lib/utils/` — colores y formato de horas.
- `assets/data/land.json` — contornos Natural Earth 110m (sin red).
- `android/` — `AlarmNativePlugin.kt` (MethodChannel), `AlarmReceiver`,
  `AlarmRingingService` (MediaPlayer en bucle + notificación con «Silenciar»),
  `BootReceiver`, `SilenceReceiver`, permisos y `raw/buzz_*.wav`. El canal
  nativo es `eu.elarreglador.great_alarm/native`; el de zona horaria es
  `eu.elarreglador.great_alarm/timezone`.

## Convenciones

- Hablar en español; código e identificadores en inglés.
- Paquetes y canales nativos con prefijo `eu.elarreglador`.
- La lógica de fechas va en `domain/services`, nunca en widgets.
- La barra regresiva tiene 24 celdas de una hora: se apagan de derecha a
  izquierda; si falta más de un día, queda llena. Se vacía al sonar.
- El sonido es pulsado (0,4 s / 0,4 s) en bucle, con seis frecuencias
  (440–1600 Hz) y opción «Sin sonido» solo si la vibración está activa. El
  servicio nativo corta a los 5 minutos; ese corte cuenta como alarma atendida.
- No exponer secretos. `SENSIBLE/` queda ignorado por git.
- No hacer commits ni pushes sin petición explícita.
- El silenciado rápido se hace con los botones de volumen: `MainActivity` los captura
  y los consume mientras suena, y llama a `stopRinging`. No se usan sensores ni el
  botón de power.

## Verificación

```bash
flutter analyze
flutter test
flutter build apk --debug
```

## Lanzar la app en el teléfono Android

El móvil se conecta por USB. Primero comprobar que ADB lo ve:

```bash
adb devices -l
```

Si aparece una línea con `device` (no `unauthorized` ni `offline`), tomar el
serial de la primera columna y lanzar:

```bash
flutter run -d <serial>
```

Ejemplo con el teléfono usado durante el desarrollo:

```bash
flutter run -d 5lcqy54d4l4ltspz
```

`flutter run` compila e instala el APK de debug y deja la app abierta en el
móvil. Dentro de la terminal interactiva: `r` recarga el código, `R` reinicia
la app, `q` la cierra y termina la sesión. Para probar la versión de release:

```bash
flutter run --release -d <serial>
```

Si solo se quiere instalar sin abrir la sesión de desarrollo:

```bash
flutter install -d <serial>
adb shell am start -n eu.elarreglador.great_alarm/.MainActivity
```

En móviles MIUI/Xiaomi, `flutter install` instala la APK **release** y puede
fallar con `INSTALL_FAILED_USER_RESTRICTED: Install canceled by user`. Es una
protección del fabricante, no un error del proyecto. Dos salidas:

1. Activar «Instalar vía USB» (`Install via USB`) en Opciones de desarrollador
   y aceptar la advertencia en el teléfono.
2. Usar directamente la APK de debug, que es la que `flutter run` instala:

   ```bash
   adb -s <serial> install -r build/app/outputs/flutter-apk/app-debug.apk
   adb -s <serial> shell am force-stop eu.elarreglador.great_alarm
   adb -s <serial> shell am start -n eu.elarreglador.great_alarm/.MainActivity
   ```

Si ADB no ve el móvil: activar «Depuración USB» en Opciones de desarrollador,
aceptar la huella/PIN del equipo en el teléfono y repetir `adb devices`. Si el
serial aparece como `unauthorized`, hace falta ese paso de autorización; si no
aparece, cambiar el cable o el puerto USB. Sin dispositivo, `flutter build apk`
sigue siendo un control de calidad válido, pero no sustituye probar la alarma
en un teléfono real.

## Documentación

- `README.md` es divulgativo: no menciona el stack.
- `STACK.md` (cuando exista) contendrá tecnologías y decisiones técnicas.
- `TODO.md` mantiene Features, Fix y Tareas finalizadas.
